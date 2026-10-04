;;; tests/agent-shell-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defconst luyangliuable-test/agent-shell-config-file
  (expand-file-name "../config/packages/agent-shell.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defvar doom-user-dir temporary-file-directory)
(defvar luyangliuable-test/agent-shell-commands nil)
(defvar luyangliuable-test/agent-shell-environment-calls 0)
(defvar luyangliuable-test/agent-shell-deferred-config nil
  "The :config forms of the last deferred `use-package' form.")

(defmacro map! (&rest args)
  `(progn
     ,@(cl-loop for value in args
                when (and (listp value) (eq (car value) 'function))
                collect `(push ',(cadr value)
                               luyangliuable-test/agent-shell-commands))))

(defmacro use-package (_name &rest args)
  (let ((config (cl-loop for form in (cdr (memq :config args))
                         until (keywordp form) collect form)))
    `(progn
       ,@(cl-loop for form in (cdr (memq :init args))
                  until (keywordp form) collect form)
       ,@(if (or (memq :defer args) (memq :after args) (memq :commands args))
             `((setq luyangliuable-test/agent-shell-deferred-config ',config))
           config))))

(defun agent-shell-make-environment-variables (&rest _)
  (cl-incf luyangliuable-test/agent-shell-environment-calls))

(defun luyangliuable-test/agent-shell-run-deferred-config ()
  "Run the deferred :config forms as loading Agent Shell would."
  (cl-letf (((symbol-function 'agent-shell-make-environment-variables)
             (lambda (&rest vars)
               (append (cl-loop for (name value) on vars by #'cddr
                                unless (keywordp name)
                                collect (format "%s=%s" name value))
                       (and (plist-get (cl-member-if #'keywordp vars) :inherit-env)
                            process-environment)))))
    (eval (macroexp-progn luyangliuable-test/agent-shell-deferred-config) t)))

(defun luyangliuable-test/agent-shell-preload-timers ()
  "Return pending idle timers that load Agent Shell, then LSP."
  (cl-remove-if-not
   (lambda (timer)
     (and (eq (timer--function timer) #'luyangliuable/preload-when-idle)
          (equal (timer--args timer) '(agent-shell luyangliuable/preload-lsp))))
   timer-idle-list))

(ert-deftest luyangliuable-test/agent-shell-load-defers-environment-work ()
  (let ((luyangliuable-test/agent-shell-environment-calls 0)
        (luyangliuable-test/agent-shell-commands nil))
    (load luyangliuable-test/agent-shell-config-file nil t t)
    (should (= 0 luyangliuable-test/agent-shell-environment-calls))
    (should (memq 'agent-shell luyangliuable-test/agent-shell-commands))
    (should (memq 'agent-shell-openai-start-codex luyangliuable-test/agent-shell-commands))
    (should (memq 'agent-shell-pi-start-agent luyangliuable-test/agent-shell-commands))))

(ert-deftest luyangliuable-test/agent-shell-leader-commands-load-agent-shell-first ()
  (cl-letf (((symbol-function 'agent-shell-openai-start-codex) nil)
            ((symbol-function 'agent-shell-pi-start-agent) nil))
    ;; Doom installs package autoloads, which name each agent's library, first.
    (autoload 'agent-shell-openai-start-codex "agent-shell-openai" nil t)
    (autoload 'agent-shell-pi-start-agent "agent-shell-pi" nil t)
    (load luyangliuable-test/agent-shell-config-file nil t t)
    (dolist (command '(agent-shell-openai-start-codex agent-shell-pi-start-agent))
      (should (equal "agent-shell" (cadr (symbol-function command)))))))

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

(ert-deftest luyangliuable-test/agent-shell-environment-is-captured-at-startup ()
  (let ((process-environment (cons "LUYANGLIUABLE_TEST_STARTUP=1" process-environment)))
    (load luyangliuable-test/agent-shell-config-file nil t t)
    ;; Agent Shell loads later, after the environment has changed.
    (let ((process-environment (cons "LUYANGLIUABLE_TEST_LATER=1" process-environment)))
      (luyangliuable-test/agent-shell-run-deferred-config))
    (dolist (environment (list agent-shell-anthropic-claude-environment
                               agent-shell-opencode-environment
                               agent-shell-openai-codex-environment
                               agent-shell-pi-environment))
      (should (member "LUYANGLIUABLE_TEST_STARTUP=1" environment))
      (should-not (member "LUYANGLIUABLE_TEST_LATER=1" environment)))
    (should (equal (car agent-shell-pi-environment)
                   (concat "PI_ACP_PI_COMMAND="
                           (expand-file-name "config/pi-emacs-rpc" doom-user-dir))))))

(ert-deftest luyangliuable-test/agent-shell-resolves-executables-at-startup ()
  (let* ((bin-dir (make-temp-file "agent-shell-bin" t))
         (pi-acp (expand-file-name "pi-acp" bin-dir))
         (codex (expand-file-name "codex" bin-dir))
         (exec-path (cons bin-dir exec-path)))
    (unwind-protect
        (progn
          (dolist (file (list pi-acp codex))
            (with-temp-file file (insert "#!/bin/sh\n"))
            (set-file-modes file #o755))
          (load luyangliuable-test/agent-shell-config-file nil t t)
          (should (equal (list pi-acp) agent-shell-pi-acp-command))
          (should (equal codex agent-shell-openai-codex-executable)))
      (delete-directory bin-dir t))))

(ert-deftest luyangliuable-test/agent-shell-preloads-once-when-idle ()
  ;; `features' is not special, so only `dlet' changes what `featurep' sees.
  (dlet ((features (remq 'agent-shell features)))
    (unwind-protect
        (progn
          (load luyangliuable-test/agent-shell-config-file nil t t)
          ;; `doom/reload' loads the configuration again.
          (load luyangliuable-test/agent-shell-config-file nil t t)
          (let ((timers (luyangliuable-test/agent-shell-preload-timers)))
            (should (= 1 (length timers)))
            (should (= 1.5 (float-time (timer--time (car timers)))))
            (should-not (timer--repeat-delay (car timers)))))
      (mapc #'cancel-timer (luyangliuable-test/agent-shell-preload-timers)))))

(ert-deftest luyangliuable-test/agent-shell-skips-preload-when-loaded ()
  (dlet ((features (cons 'agent-shell features)))
    (unwind-protect
        (progn
          (load luyangliuable-test/agent-shell-config-file nil t t)
          (should-not (luyangliuable-test/agent-shell-preload-timers)))
      (mapc #'cancel-timer (luyangliuable-test/agent-shell-preload-timers)))))
