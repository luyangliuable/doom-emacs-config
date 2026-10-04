;;; tests/agent-shell-startup-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'use-package)

(defconst luyangliuable-test/agent-shell-startup-config-file
  (expand-file-name "../config/packages/agent-shell.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defvar doom-user-dir temporary-file-directory)
(defvar luyangliuable/agent-shell-preload-timer)

(defmacro map! (&rest _))

(ert-deftest luyangliuable-test/agent-shell-checks-claude-code-acp-once-at-startup ()
  (let ((exec-path (list (make-temp-file "agent-shell-empty-bin" t)))
        (use-package-expand-minimally t)
        commands)
    (unwind-protect
        (cl-letf (((symbol-function 'async-shell-command)
                   (lambda (command &rest _) (push command commands)))
                  ((symbol-function 'agent-shell-make-environment-variables)
                   #'ignore))
          (dlet ((features (remq 'agent-shell features)))
            (load luyangliuable-test/agent-shell-startup-config-file nil t t)
            ;; Agent Shell has not loaded yet, but the missing client is
            ;; installed at startup.
            (should (equal '("npm install -g @zed-industries/claude-code-acp")
                           commands))
            ;; Loading Agent Shell later does not check again.
            (provide 'agent-shell)
            (should (equal '("npm install -g @zed-industries/claude-code-acp")
                           commands))))
      (when (timerp (bound-and-true-p luyangliuable/agent-shell-preload-timer))
        (cancel-timer luyangliuable/agent-shell-preload-timer))
      (delete-directory (car exec-path) t))))
