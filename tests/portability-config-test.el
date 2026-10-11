;;; tests/portability-config-test.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defvar portability-test--root
  (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name))))

(defvar portability-test--after nil)
(defmacro after! (feature &rest body)
  `(push (cons ',feature (lambda () ,@body)) portability-test--after))
(defmacro use-package! (&rest _) nil)

(defun portability-test--load (file)
  (load (expand-file-name file portability-test--root) nil t))

;;; Copilot

(defvar copilot-server-executable)
(defvar portability-test--copilot-calls nil)
(defun copilot-mode (&optional arg)
  (push (or arg 1) portability-test--copilot-calls))

(portability-test--load "config/packages/copilot.el")

(defmacro portability-test--with-copilot-server (server &rest body)
  (declare (indent 1))
  `(let ((portability-test--copilot-calls nil)
         (luyangliuable/copilot--missing-server-reported nil))
     (cl-letf (((symbol-function 'require) (lambda (&rest _) t))
               ((symbol-function 'copilot-server-executable)
                (lambda ()
                  (or ,server
                      (error "The package @github/copilot-language-server is not installed")))))
       ,@body)))

(ert-deftest portability-test/copilot-enabled-when-server-installed ()
  (let ((exe (make-temp-file "copilot-server")))
    (unwind-protect
        (portability-test--with-copilot-server exe
          (luyangliuable/copilot-maybe-enable)
          (should (equal portability-test--copilot-calls '(1))))
      (delete-file exe))))

(ert-deftest portability-test/copilot-skipped-when-server-missing ()
  (portability-test--with-copilot-server nil
    (let ((inhibit-message t))
      (luyangliuable/copilot-maybe-enable)
      (luyangliuable/copilot-maybe-enable))
    (should-not portability-test--copilot-calls)
    (should luyangliuable/copilot--missing-server-reported)))

(ert-deftest portability-test/missing-copilot-server-does-not-abort-hook ()
  (portability-test--with-copilot-server nil
    (let ((inhibit-message t)
          (ran nil)
          (test-hook nil))
      (add-hook 'test-hook (lambda () (setq ran t)))
      (add-hook 'test-hook #'luyangliuable/copilot-maybe-enable)
      (run-hooks 'test-hook)
      (should ran))))

(ert-deftest portability-test/copilot-enable-error-does-not-abort-hook ()
  (let ((exe (make-temp-file "copilot-server")))
    (unwind-protect
        (portability-test--with-copilot-server exe
          (cl-letf (((symbol-function 'copilot-mode)
                     (lambda (&rest _) (error "Server failed to start"))))
            (let ((inhibit-message t)
                  (ran nil)
                  (test-hook nil))
              (add-hook 'test-hook (lambda () (setq ran t)))
              (add-hook 'test-hook #'luyangliuable/copilot-maybe-enable)
              (run-hooks 'test-hook)
              (should ran))))
      (delete-file exe))))

;;; Bongo cat

(ert-deftest portability-test/bongo-cat-config-has-no-workarounds ()
  (let ((source (with-temp-buffer
                  (insert-file-contents
                   (expand-file-name "config/packages/bongo-cat-mode.el"
                                     portability-test--root))
                  (buffer-string))))
    (should-not (string-match-p "(defun \\|advice-add" source))
    (should (string-match-p "bongo-cat-rail-color-scheme 'auto" source))))

;;; Machine paths

(ert-deftest portability-test/gptel-auth-file-not-user-specific ()
  (portability-test--load "config/packages/gptel-auth.el")
  (should (string-prefix-p (expand-file-name "~/") luyangliuable/gptel-pi-auth-file))
  (should (string-suffix-p ".pi/agent/auth.json" luyangliuable/gptel-pi-auth-file)))

(defvar org-agenda-files)
(defun portability-test--run-org-config ()
  (setq portability-test--after nil)
  (portability-test--load "config/packages/org.el")
  (let ((emacs-startup-hook nil)
        (org-agenda-files nil))
    (funcall (cdr (assq 'org portability-test--after)))))

(ert-deftest portability-test/org-daily-dir-not-user-specific ()
  (makunbound 'luyangliuable/org-daily-dir)
  (portability-test--run-org-config)
  (should (string-prefix-p (expand-file-name "~/") luyangliuable/org-daily-dir)))

(ert-deftest portability-test/org-daily-dir-respects-local-override ()
  (setq luyangliuable/org-daily-dir "/custom/daily/")
  (unwind-protect
      (progn
        (portability-test--run-org-config)
        (should (equal luyangliuable/org-daily-dir "/custom/daily/")))
    (makunbound 'luyangliuable/org-daily-dir)))

;;; tests/portability-config-test.el ends here
