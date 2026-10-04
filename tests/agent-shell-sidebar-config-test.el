;;; tests/agent-shell-sidebar-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'use-package)

(defconst luyangliuable-test/agent-shell-sidebar-config-file
  (expand-file-name "../config/packages/agent-shell-sidebar.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defconst luyangliuable-test/agent-shell-sidebar-commands
  '(agent-shell-sidebar-toggle
    agent-shell-sidebar-toggle-focus
    agent-shell-sidebar-change-provider
    agent-shell-sidebar-reset))

(defvar luyangliuable-test/agent-shell-sidebar-leader-commands nil)

(defmacro map! (&rest args)
  (when (eq (car args) :leader)
    `(progn
       ,@(cl-loop for value in args
                  when (and (listp value) (eq (car value) 'function))
                  collect `(push ',(cadr value)
                                 luyangliuable-test/agent-shell-sidebar-leader-commands)))))

(defun luyangliuable-test/install-sidebar-package-autoloads ()
  "Install the autoloads Doom generates from the sidebar package."
  (dolist (command luyangliuable-test/agent-shell-sidebar-commands)
    (autoload command "agent-shell-sidebar" nil t)))

(ert-deftest luyangliuable-test/agent-shell-sidebar-binds-key-before-agent-shell-loads ()
  (let ((agent-shell-loaded (featurep 'agent-shell))
        (luyangliuable-test/agent-shell-sidebar-leader-commands nil))
    (cl-letf (((symbol-function 'agent-shell-sidebar-toggle) nil)
              ((symbol-function 'agent-shell-sidebar-toggle-focus) nil)
              ((symbol-function 'agent-shell-sidebar-change-provider) nil)
              ((symbol-function 'agent-shell-sidebar-reset) nil))
      (luyangliuable-test/install-sidebar-package-autoloads)
      (load luyangliuable-test/agent-shell-sidebar-config-file nil t t)
      (dolist (command luyangliuable-test/agent-shell-sidebar-commands)
        (should (equal "agent-shell" (cadr (symbol-function command))))))
    (should (eq agent-shell-loaded (featurep 'agent-shell)))
    (should (memq 'agent-shell-sidebar-toggle
                  luyangliuable-test/agent-shell-sidebar-leader-commands))))

(ert-deftest luyangliuable-test/agent-shell-sidebar-command-keeps-user-config ()
  (skip-unless (and (locate-library "agent-shell")
                    (locate-library "agent-shell-sidebar")
                    (not (featurep 'agent-shell))))
  (luyangliuable-test/install-sidebar-package-autoloads)
  (load luyangliuable-test/agent-shell-sidebar-config-file nil t t)
  (autoload-do-load (symbol-function 'agent-shell-sidebar-toggle)
                    'agent-shell-sidebar-toggle)
  (should (featurep 'agent-shell))
  (should (equal "20%" agent-shell-sidebar-width))
  (should (equal "Return the configured sidebar agent using Agent Shell's config resolver."
                 (documentation 'agent-shell-sidebar--select-config t))))
