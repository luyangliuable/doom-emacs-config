;;; tests/doom-modeline-test.el -*- lexical-binding: t; -*-

(require 'ert)

(defmacro use-package! (&rest _))

(defvar doom-modeline-buffer-state-icon t)
(defvar doom-modeline-buffer-modification-icon t)
(defvar doom-modeline-icon t)
(defvar doom-modeline-unicode-fallback nil)
(defvar-local doom-modeline--buffer-file-state-icon nil)
(defvar doom-modeline-test--state-icon-calls 0)

(defun doom-modeline-update-buffer-file-state-icon (&rest _)
  "Stand-in for doom-modeline's state icon updater; counts full updates."
  (setq doom-modeline-test--state-icon-calls
        (1+ doom-modeline-test--state-icon-calls))
  (setq doom-modeline--buffer-file-state-icon
        (format "%s%s%s" (if buffer-read-only "lock" "")
                (if (buffer-modified-p) "save" "")
                (if (buffer-narrowed-p) "narrow" ""))))

(load (expand-file-name "../config/packages/doom-modeline.el"
                        (file-name-directory (or load-file-name buffer-file-name)))
      nil t)
(provide 'doom-modeline)

(defmacro doom-modeline-test--with-file-buffer (&rest body)
  "Run BODY in a fresh buffer visiting a temp file, with no prior icon updates."
  (declare (indent 0))
  `(let ((path (make-temp-file "doom-modeline-state-icon-"))
         (doom-modeline-test--state-icon-calls 0))
     (unwind-protect
         (with-current-buffer (find-file-noselect path)
           (unwind-protect (progn ,@body)
             (set-buffer-modified-p nil)
             (kill-buffer)))
       (delete-file path))))

(ert-deftest luyangliuable-test/doom-modeline-project-detection-detaches-deleted-visits ()
  (let ((path (make-temp-file "doom-modeline-deleted-visit-" nil ".json" "{}"))
        buffer)
    (unwind-protect
        (progn
          (setq buffer (find-file-noselect path))
          (with-current-buffer buffer
            (setq buffer-offer-save nil))
          (delete-file path)
          (should (eq (luyangliuable/doom-modeline-set-project-detection
                       'projectile)
                      'projectile))
          (with-current-buffer buffer
            (should-not buffer-file-name)))
      (when (file-exists-p path)
        (delete-file path))
      (when (buffer-live-p buffer)
        (kill-buffer buffer)))))

(ert-deftest luyangliuable-test/doom-modeline-state-icon-reuses-unchanged-state ()
  (doom-modeline-test--with-file-buffer
    (let ((first (doom-modeline-update-buffer-file-state-icon)))
      (should (equal (doom-modeline-update-buffer-file-state-icon) first))
      (should (equal doom-modeline--buffer-file-state-icon first))
      (should (= doom-modeline-test--state-icon-calls 1)))))

(ert-deftest luyangliuable-test/doom-modeline-state-icon-updates-on-buffer-state ()
  (doom-modeline-test--with-file-buffer
    (insert "x")
    (should (equal (doom-modeline-update-buffer-file-state-icon) "save"))
    (setq buffer-read-only t)
    (should (equal (doom-modeline-update-buffer-file-state-icon) "locksave"))
    (narrow-to-region 1 1)
    (should (equal (doom-modeline-update-buffer-file-state-icon) "locksavenarrow"))
    (widen)
    (setq buffer-read-only nil)
    (set-buffer-modified-p nil)
    (should (equal (doom-modeline-update-buffer-file-state-icon) ""))
    (should (= doom-modeline-test--state-icon-calls 4))))

(ert-deftest luyangliuable-test/doom-modeline-state-icon-rechecks-disk-after-interval ()
  (doom-modeline-test--with-file-buffer
    (let ((luyangliuable/doom-modeline-state-icon-interval 0))
      (doom-modeline-update-buffer-file-state-icon)
      (doom-modeline-update-buffer-file-state-icon)
      (should (= doom-modeline-test--state-icon-calls 2)))))

(ert-deftest luyangliuable-test/doom-modeline-state-icon-caches-per-buffer ()
  (doom-modeline-test--with-file-buffer
    (doom-modeline-update-buffer-file-state-icon)
    (with-temp-buffer
      (doom-modeline-update-buffer-file-state-icon))
    (should (= doom-modeline-test--state-icon-calls 2))))
