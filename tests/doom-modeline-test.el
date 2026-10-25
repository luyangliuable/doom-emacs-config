;;; tests/doom-modeline-test.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

;; Stubs below replace primitives only for the (interpreted) code under test;
;; trampolines would make each one a slow native compile that needs gcc.
(setq native-comp-enable-subr-trampolines nil)

(defmacro use-package! (&rest _))

(defvar doom-modeline-buffer-state-icon t)
(defvar doom-modeline-buffer-modification-icon t)
(defvar doom-modeline-icon t)
(defvar doom-modeline-unicode-fallback nil)
(defvar-local doom-modeline--buffer-file-state-icon nil)
(defvar doom-modeline-test--state-icon-calls 0)
(defvar bongo-cat-scroll-mode nil)

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

(defmacro doom-modeline-test--with-bongo-cat (active cat fits &rest body)
  "Run BODY with Bongo Cat drawing CAT in an ACTIVE window where it FITS."
  (declare (indent 3))
  `(let ((bongo-cat-scroll-mode t)
         (luyangliuable/doom-modeline--bongo-cat-window nil))
     (cl-letf (((symbol-function 'doom-modeline--active) (lambda () ,active))
               ((symbol-function 'bongo-cat-scroll-mode-format) (lambda () ,cat))
               ((symbol-function 'doom-modeline-segment--bar) (lambda () "bar"))
               ((symbol-function 'luyangliuable/doom-modeline--bongo-cat-fits-p)
                (lambda (_) ,fits)))
       ,@body)))

(defun doom-modeline-test--bongo-cat-line ()
  "Return (LEFT RIGHT) as doom-modeline draws them: right side first."
  (let ((right (luyangliuable/doom-modeline-bongo-cat)))
    (list (luyangliuable/doom-modeline-bongo-cat-bar) right)))

(ert-deftest luyangliuable-test/doom-modeline-bongo-cat-shown-when-it-fits ()
  (doom-modeline-test--with-bongo-cat t "cat" t
    (should (equal (doom-modeline-test--bongo-cat-line) '(nil "cat")))))

(ert-deftest luyangliuable-test/doom-modeline-bongo-cat-yields-to-left-bar-without-room ()
  (doom-modeline-test--with-bongo-cat t "cat" nil
    (should (equal (doom-modeline-test--bongo-cat-line) '("bar" nil))))
  (doom-modeline-test--with-bongo-cat t "" t
    (should (equal (doom-modeline-test--bongo-cat-line) '("bar" nil)))))

(ert-deftest luyangliuable-test/doom-modeline-bongo-cat-hidden-unfocused-or-off ()
  (doom-modeline-test--with-bongo-cat nil "cat" t
    (should (equal (doom-modeline-test--bongo-cat-line) '(nil nil))))
  (doom-modeline-test--with-bongo-cat t "cat" t
    (let ((bongo-cat-scroll-mode nil))
      (should (equal (doom-modeline-test--bongo-cat-line) '(nil nil))))))

(ert-deftest luyangliuable-test/doom-modeline-bongo-cat-measured-as-candidate ()
  (doom-modeline-test--with-bongo-cat t "" nil
    (let ((luyangliuable/doom-modeline--bongo-cat-candidate "measured"))
      (should (equal (doom-modeline-test--bongo-cat-line) '(nil "measured"))))))

(ert-deftest luyangliuable-test/doom-modeline-bongo-cat-fit-uses-right-align-width ()
  (cl-letf (((symbol-function 'luyangliuable/doom-modeline--main-forms)
             (lambda () 'main-forms))
            ;; The real one returns "" in batch Emacs.
            ((symbol-function 'format-mode-line)
             (lambda (forms &rest _)
               (should (eq forms 'main-forms))
               (concat "left" luyangliuable/doom-modeline--bongo-cat-candidate)))
            ((symbol-function 'doom-modeline-string-pixel-width)
             (lambda (str) (* 10 (length str))))
            ((symbol-function 'window-pixel-width) (lambda (&rest _) 200))
            ((symbol-function 'window-scroll-bar-width) (lambda (&rest _) 20))
            ((symbol-function 'window-right-divider-width) (lambda (&rest _) 0))
            ((symbol-function 'window-margins) (lambda (&rest _) '(nil)))
            ((symbol-function 'frame-char-width) (lambda (&rest _) 10)))
    ;; 200 - 20 scroll bar - 10 (one char) leaves 170px: "left" + 13 chars.
    (should (luyangliuable/doom-modeline--bongo-cat-fits-p "13-char-catxx"))
    (should-not (luyangliuable/doom-modeline--bongo-cat-fits-p "14-char-catxxx"))))

(ert-deftest luyangliuable-test/doom-modeline-main-forms-cached-until-redefined ()
  (let ((luyangliuable/doom-modeline--main-forms-cache nil)
        (calls 0))
    (cl-letf (((symbol-function 'doom-modeline-format--main)
               (lambda () (setq calls (1+ calls)) '(lhs space rhs))))
      (should (equal (luyangliuable/doom-modeline--main-forms) '(lhs rhs)))
      (should (equal (luyangliuable/doom-modeline--main-forms) '(lhs rhs)))
      (should (= calls 1)))
    (cl-letf (((symbol-function 'doom-modeline-format--main)
               (lambda () '(new-lhs space new-rhs))))
      (should (equal (luyangliuable/doom-modeline--main-forms)
                     '(new-lhs new-rhs))))))
