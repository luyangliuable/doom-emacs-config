;;; tests/workspace-hud-package-test.el -*- lexical-binding: t; -*-

(require 'ert)

(defconst luyangliuable-test/workspace-hud-packages-file
  (expand-file-name "../packages.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defvar luyangliuable-test/workspace-hud-declaration nil)

(defmacro package! (name &rest args)
  `(when (eq ',name 'workspace-hud)
     (setq luyangliuable-test/workspace-hud-declaration ',args)))

(load luyangliuable-test/workspace-hud-packages-file nil t t)

(defun luyangliuable-test/workspace-hud-build-command ()
  "Return the shell command from the Workspace HUD pre-build recipe."
  (caddar
   (plist-get
    (plist-get luyangliuable-test/workspace-hud-declaration :recipe)
    :pre-build)))

(defun luyangliuable-test/write-file (file contents)
  "Write CONTENTS to FILE, creating its parent directory."
  (make-directory (file-name-directory file) t)
  (with-temp-file file
    (insert contents)))

(defun luyangliuable-test/write-executable (file contents)
  "Write executable CONTENTS to FILE."
  (luyangliuable-test/write-file file contents)
  (set-file-modes file #o755))

(defun luyangliuable-test/workspace-hud-fixture (root)
  "Create a complete, fresh Workspace HUD build fixture below ROOT."
  (let ((old-time (time-subtract (current-time) (seconds-to-time 60))))
    (dolist (file '("ui/Cargo.toml"
                    "ui/src/lib.rs"
                    "emacs-egui/sdk/Cargo.toml"
                    "emacs-egui/sdk/src/lib.rs"))
      (let ((path (expand-file-name file root)))
        (luyangliuable-test/write-file path "source\n")
        (set-file-times path old-time)))
    (dolist (file '("ui/pkg/package.json"
                    "ui/pkg/workspace_hud.d.ts"
                    "ui/pkg/workspace_hud.js"
                    "ui/pkg/workspace_hud_bg.wasm.d.ts"
                    "ui/pkg/workspace_hud_bg.wasm"))
      (luyangliuable-test/write-file (expand-file-name file root) "built\n"))))

(defun luyangliuable-test/run-workspace-hud-build (root)
  "Run the Workspace HUD recipe in ROOT and return (STATUS . BUILD-CALLED)."
  (let* ((bin (expand-file-name "bin" root))
         (marker (expand-file-name "wasm-pack-called" root))
         (fake-rustc (expand-file-name "toolchain/rustc" root))
         (process-environment (copy-sequence process-environment))
         (default-directory root))
    (luyangliuable-test/write-executable
     (expand-file-name "git" bin)
     "#!/bin/sh\nexit 0\n")
    (luyangliuable-test/write-executable
     (expand-file-name "rustup" bin)
     "#!/bin/sh\nif [ \"$1\" = which ]; then printf '%s\\n' \"$FAKE_RUSTC\"; fi\nexit 0\n")
    (luyangliuable-test/write-executable
     (expand-file-name "wasm-pack" bin)
     "#!/bin/sh\nprintf 'called\\n' > \"$WASM_PACK_MARKER\"\n")
    (luyangliuable-test/write-file fake-rustc "")
    (setenv "CARGO_HOME" (expand-file-name "cargo-home" root))
    (setenv "FAKE_RUSTC" fake-rustc)
    (setenv "WASM_PACK_MARKER" marker)
    (setenv "PATH" (concat bin path-separator (getenv "PATH")))
    (cons (with-temp-buffer
            (call-process "/bin/bash" nil t nil "-c"
                          (luyangliuable-test/workspace-hud-build-command)))
          (file-exists-p marker))))

(ert-deftest luyangliuable-test/workspace-hud-reuses-fresh-build ()
  (let ((root (make-temp-file "workspace-hud-test-" t)))
    (unwind-protect
        (progn
          (luyangliuable-test/workspace-hud-fixture root)
          (let ((result (luyangliuable-test/run-workspace-hud-build root)))
            (should (= 0 (car result)))
            (should-not (cdr result))))
      (delete-directory root t))))

(ert-deftest luyangliuable-test/workspace-hud-builds-stale-bundle ()
  (let ((root (make-temp-file "workspace-hud-test-" t)))
    (unwind-protect
        (progn
          (luyangliuable-test/workspace-hud-fixture root)
          (set-file-times (expand-file-name "ui/src/lib.rs" root)
                          (time-add (current-time) (seconds-to-time 60)))
          (let ((result (luyangliuable-test/run-workspace-hud-build root)))
            (should (= 0 (car result)))
            (should (cdr result))))
      (delete-directory root t))))

(ert-deftest luyangliuable-test/workspace-hud-builds-incomplete-bundle ()
  (let ((root (make-temp-file "workspace-hud-test-" t)))
    (unwind-protect
        (progn
          (luyangliuable-test/workspace-hud-fixture root)
          (delete-file (expand-file-name "ui/pkg/workspace_hud.js" root))
          (let ((result (luyangliuable-test/run-workspace-hud-build root)))
            (should (= 0 (car result)))
            (should (cdr result))))
      (delete-directory root t))))

(ert-deftest luyangliuable-test/workspace-hud-builds-after-sdk-manifest-change ()
  (let ((root (make-temp-file "workspace-hud-test-" t)))
    (unwind-protect
        (progn
          (luyangliuable-test/workspace-hud-fixture root)
          (set-file-times (expand-file-name "emacs-egui/sdk/Cargo.toml" root)
                          (time-add (current-time) (seconds-to-time 60)))
          (let ((result (luyangliuable-test/run-workspace-hud-build root)))
            (should (= 0 (car result)))
            (should (cdr result))))
      (delete-directory root t))))
