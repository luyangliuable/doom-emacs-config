;;; tests/persistent-scratch-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'use-package)

(defconst persistent-scratch-config-test--file
  (expand-file-name "../config/packages/persistent-scratch.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defmacro use-package! (&rest args)
  `(use-package ,@args))

(defvar persistent-scratch-config-test--log nil)

(defmacro persistent-scratch-config-test--with-config (&rest body)
  "Load the config with a fake persistent-scratch library, then run BODY."
  (declare (indent 0))
  `(let* ((dir (make-temp-file "persistent-scratch-config-test" t))
          (load-path (cons dir load-path))
          (doom-cache-dir (file-name-as-directory (expand-file-name "cache" dir)))
          (after-load-alist nil)
          (timer-idle-list nil)
          (window-buffer-change-functions nil)
          (persistent-scratch-config-test--log nil))
     (with-temp-file (expand-file-name "persistent-scratch.el" dir)
       (prin1 '(progn
                 (defvar persistent-scratch-autosave-interval 'idle)
                 (defun persistent-scratch-setup-default ()
                   (push (list 'setup persistent-scratch-autosave-interval
                               (file-exists-p persistent-scratch-save-file))
                         persistent-scratch-config-test--log))
                 (provide 'persistent-scratch))
               (current-buffer)))
     (dlet ((features features)
            (doom-cache-dir doom-cache-dir))
       (unwind-protect
           (progn
             (load persistent-scratch-config-test--file nil t t)
             ,@body)
         (makunbound 'persistent-scratch-autosave-interval)
         (makunbound 'persistent-scratch-save-file)
         (delete-directory dir t)))))

(defun persistent-scratch-config-test--run-idle-timers ()
  (dolist (timer timer-idle-list)
    (cancel-timer timer)
    (apply (timer--function timer) (timer--args timer))))

(ert-deftest persistent-scratch-config-waits-for-idle ()
  (persistent-scratch-config-test--with-config
    (should-not (featurep 'persistent-scratch))
    (should (equal (expand-file-name ".persistent-scratch" doom-cache-dir)
                   persistent-scratch-save-file))
    (persistent-scratch-config-test--run-idle-timers)
    (should (featurep 'persistent-scratch))
    (should (equal '((setup 300 t)) persistent-scratch-config-test--log))
    (should-not window-buffer-change-functions)))

(ert-deftest persistent-scratch-config-loads-when-scratch-is-shown ()
  (persistent-scratch-config-test--with-config
    (let ((scratch (get-buffer-create "*scratch*")))
      (switch-to-buffer (get-buffer-create "other"))
      (run-hook-with-args 'window-buffer-change-functions (selected-frame))
      (should-not (featurep 'persistent-scratch))
      (switch-to-buffer scratch)
      (run-hook-with-args 'window-buffer-change-functions (selected-frame))
      (should (equal '((setup 300 t)) persistent-scratch-config-test--log))
      (should-not window-buffer-change-functions)
      ;; The idle timer then finds it loaded.
      (persistent-scratch-config-test--run-idle-timers)
      (should (equal '((setup 300 t)) persistent-scratch-config-test--log)))))

(ert-deftest persistent-scratch-config-reload-after-loading-adds-nothing ()
  (persistent-scratch-config-test--with-config
    (persistent-scratch-config-test--run-idle-timers)
    (load persistent-scratch-config-test--file nil t t)
    (should-not timer-idle-list)
    (should-not window-buffer-change-functions)
    ;; As before: reloading runs :config again.
    (should (equal '((setup 300 t) (setup 300 t))
                   persistent-scratch-config-test--log))))
