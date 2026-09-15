;;; tests/agent-shell-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defconst luyangliuable-test/agent-shell-config-file
  (expand-file-name "../config/packages/agent-shell.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(ert-deftest luyangliuable-test/agent-shell-startup-does-not-provision-codex ()
  (let ((test-bin-dir (getenv "CODEX_TEST_BIN_DIR"))
        (original-exec-path exec-path)
        commands)
    (should (stringp test-bin-dir))
    (should (executable-find "codex"))
    (unwind-protect
        (progn
          (setq exec-path (delete test-bin-dir (copy-sequence exec-path)))
          (should-not (executable-find "codex"))
          (cl-letf (((symbol-function 'async-shell-command)
                     (lambda (command &rest _)
                       (push command commands))))
            (load-file luyangliuable-test/agent-shell-config-file))
          (should-not (member "brew install codex" commands)))
      (setq exec-path original-exec-path))))
