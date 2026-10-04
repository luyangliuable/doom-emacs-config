;;; tests/minimap-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defvar minimap-mode nil)

(defconst luyangliuable-test/minimap-config-file
  (expand-file-name "../config/packages/minimap.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defmacro use-package! (_name &rest args)
  `(progn ,@(cl-loop for form in (cdr (memq :init args))
                     until (keywordp form)
                     collect form)))

(cl-letf (((symbol-function 'run-with-idle-timer) (lambda (&rest _) nil)))
  (load luyangliuable-test/minimap-config-file nil t t))

(ert-deftest luyangliuable-test/minimap-reload-keeps-one-repeating-idle-timer ()
  (let ((timer-idle-list nil))
    (unwind-protect
        (progn
          ;; An orphan from an earlier load, then two more loads.
          (run-with-idle-timer 0.5 t #'luyangliuable/minimap-auto-sync)
          (load luyangliuable-test/minimap-config-file nil t t)
          (load luyangliuable-test/minimap-config-file nil t t)
          (let ((timers (cl-remove-if-not
                         (lambda (timer)
                           (eq (timer--function timer)
                               #'luyangliuable/minimap-auto-sync))
                         timer-idle-list)))
            (should (= 1 (length timers)))
            (should (time-equal-p 0.5 (timer--time (car timers))))
            (should (timer--repeat-delay (car timers)))))
      (mapc #'cancel-timer timer-idle-list))))

(ert-deftest luyangliuable-test/minimap-excludes-all-image-mode-buffers ()
  (dolist (extension '("svg" "png" "jpg" "jpeg" "gif" "webp"))
    (with-temp-buffer
      (setq buffer-file-name (concat "/tmp/example." extension))
      (setq major-mode 'image-mode)
      (cl-letf (((symbol-function 'luyangliuable/minimap-only-window-p)
                 (lambda () t))
                ((symbol-function 'luyangliuable/minimap-buffer-over-100-lines-p)
                 (lambda () t)))
        (should-not (luyangliuable/minimap-eligible-buffer-p))))))

(ert-deftest luyangliuable-test/minimap-creation-falls-back-when-line-height-is-nil ()
  (cl-letf (((symbol-function 'window-line-height)
             (lambda (&rest _) nil))
            ((symbol-function 'frame-char-height)
             (lambda (&rest _) 17)))
    (should
     (= (luyangliuable/minimap-new-minimap-safely
         (lambda ()
           (floor (/ 170 (car (window-line-height))))))
        10))))

;; Run BODY with fresh sync state and a stubbed `minimap-mode' that records
;; each change in TRANSITIONS; ONLY-WINDOW and DISABLED drive the stubs.
(defmacro luyangliuable-test/with-minimap-sync (&rest body)
  (declare (indent 0))
  `(let ((luyangliuable/minimap--last-buffer nil)
         (luyangliuable/minimap--last-tick nil)
         (luyangliuable/minimap--last-eligible nil)
         (luyangliuable/minimap--last-only-window nil)
         (luyangliuable/minimap--last-major-mode nil)
         (minimap-mode nil)
         (only-window t)
         (disabled nil)
         transitions)
     (ignore only-window disabled)
     (cl-letf (((symbol-function 'luyangliuable/minimap-only-window-p)
                (lambda () only-window))
               ((symbol-function 'minor-mode-badges-disabled-p)
                (lambda (_mode) disabled))
               ((symbol-function 'minimap-mode)
                (lambda (arg)
                  (setq minimap-mode (> arg 0))
                  (push minimap-mode transitions))))
       ,@body)))

(ert-deftest luyangliuable-test/minimap-idle-sync-tracks-buffer-lines-and-layout ()
  (luyangliuable-test/with-minimap-sync
    (with-temp-buffer
      (setq buffer-file-name "/tmp/minimap-test.el")
      (emacs-lisp-mode)
      (insert (make-string 101 ?\n))
      (luyangliuable/minimap-auto-sync)
      (should minimap-mode)
      (setq only-window nil)
      (luyangliuable/minimap-auto-sync)
      (should-not minimap-mode)
      (setq only-window t)
      (luyangliuable/minimap-auto-sync)
      (should minimap-mode)
      (erase-buffer)
      (luyangliuable/minimap-auto-sync)
      (should-not minimap-mode)
      (insert (make-string 101 ?\n))
      (luyangliuable/minimap-auto-sync)
      (should minimap-mode))
    (with-temp-buffer
      (setq buffer-file-name "/tmp/minimap-other.el")
      (emacs-lisp-mode)
      (luyangliuable/minimap-auto-sync)
      (should-not minimap-mode))
    (should (equal (nreverse transitions) '(t nil t nil t nil)))))

(ert-deftest luyangliuable-test/minimap-idle-sync-keeps-disabled-badge-semantics ()
  (luyangliuable-test/with-minimap-sync
    (with-temp-buffer
      (setq buffer-file-name "/tmp/minimap-test.el")
      (emacs-lisp-mode)
      (insert (make-string 101 ?\n))
      (setq disabled t)
      (luyangliuable/minimap-auto-sync)
      (should-not minimap-mode)
      ;; Only the badge command toggles minimap; losing the buffer-local
      ;; flag (e.g. via `kill-all-local-variables') must not re-show it.
      (setq disabled nil)
      (luyangliuable/minimap-auto-sync)
      (should-not minimap-mode))
    (should-not transitions)))

(ert-deftest luyangliuable-test/minimap-idle-sync-tracks-in-place-major-mode ()
  (luyangliuable-test/with-minimap-sync
    (with-temp-buffer
      (setq buffer-file-name "/tmp/minimap-test.svg")
      (emacs-lisp-mode)
      (insert (make-string 101 ?\n))
      (luyangliuable/minimap-auto-sync)
      (should minimap-mode)
      ;; Same buffer and text, e.g. `image-toggle-display' back to the image.
      (setq major-mode 'image-mode)
      (luyangliuable/minimap-auto-sync)
      (should-not minimap-mode)
      (setq major-mode 'emacs-lisp-mode)
      (luyangliuable/minimap-auto-sync)
      (should minimap-mode))
    (should (equal (nreverse transitions) '(t nil t)))))
