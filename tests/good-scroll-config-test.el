;;; tests/good-scroll-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'use-package)

;; The `input-pending-p' stub below only needs to reach bytecode callers;
;; a trampoline would make it a slow native compile that needs gcc.
(setq native-comp-enable-subr-trampolines nil)

(load (expand-file-name "../config/packages/good-scroll.el"
                        (file-name-directory (or load-file-name buffer-file-name)))
      nil t)
(require 'good-scroll)

(defun good-scroll-config-test--active-timers ()
  "Return the active timers that run `good-scroll--render'."
  (cl-remove-if-not (lambda (timer) (eq (timer--function timer) #'good-scroll--render))
                    timer-list))

(defun good-scroll-config-test--due (timer)
  (float-time (timer--time timer)))

(defmacro good-scroll-config-test--with-mode (&rest body)
  "Run BODY with a freshly enabled `good-scroll-mode' and no scroll pending."
  (declare (indent 0))
  `(cl-letf (((symbol-function 'input-pending-p) #'ignore))
     (unwind-protect
         (progn
           (good-scroll-mode -1)
           (setq good-scroll-destination nil
                 good-scroll-direction 0
                 good-scroll--window nil)
           (good-scroll-mode 1)
           ,@body)
       (good-scroll-mode -1)
       (setq good-scroll--window nil)
       (cancel-function-timers #'good-scroll--render))))

(ert-deftest good-scroll-config-has-no-render-timer-while-idle ()
  (good-scroll-config-test--with-mode
    (should (timerp good-scroll--timer))
    (should (= (timer--repeat-delay good-scroll--timer) good-scroll-render-rate))
    (should-not (good-scroll-config-test--active-timers))))

(ert-deftest good-scroll-config-move-resumes-the-timer-on-its-grid ()
  (good-scroll-config-test--with-mode
    (let ((origin (timer--time good-scroll--timer))
          (rate good-scroll-render-rate))
      (sleep-for (* 3.5 rate))
      (let ((before (float-time)))
        (good-scroll-move 80)
        (good-scroll-move 80)
        (let* ((after (float-time))
               (due (good-scroll-config-test--due good-scroll--timer))
               (steps (/ (float-time (time-subtract (timer--time good-scroll--timer)
                                                    origin))
                         rate)))
          (should (equal (good-scroll-config-test--active-timers)
                         (list good-scroll--timer)))
          (should (= (timer--repeat-delay good-scroll--timer) rate))
          (should (< (abs (- steps (round steps))) 1e-6))
          (should (>= due (- before 1e-6)))
          (should (< due (+ after rate))))))))

(ert-deftest good-scroll-config-render-pauses-only-when-scroll-ends ()
  (good-scroll-config-test--with-mode
    (good-scroll-move 80)
    ;; Like today, the timer keeps running while the scrolled window is
    ;; invalid (it can come back, e.g. via `winner-undo').
    (setq good-scroll--window nil)
    (good-scroll--render)
    (should (equal (good-scroll-config-test--active-timers)
                   (list good-scroll--timer)))
    (setq good-scroll-destination 0)
    (good-scroll--render)
    (should-not (good-scroll-config-test--active-timers))
    (good-scroll-move -80)
    (should (equal (good-scroll-config-test--active-timers)
                   (list good-scroll--timer)))))

(ert-deftest good-scroll-config-mode-toggle-keeps-original-semantics ()
  (good-scroll-config-test--with-mode
    (good-scroll-move 80)
    (good-scroll-mode -1)
    (should-not (good-scroll-config-test--active-timers))
    ;; Without the mode nothing renders, as today.
    (good-scroll-move 80)
    (should-not (good-scroll-config-test--active-timers))
    ;; Enabling the mode with a pending scroll renders it at once, as today.
    (let ((before (float-time)))
      (good-scroll-mode 1)
      (should (equal (good-scroll-config-test--active-timers)
                     (list good-scroll--timer)))
      (should (<= (good-scroll-config-test--due good-scroll--timer)
                  (+ (float-time) 1e-6)))
      (should (>= (good-scroll-config-test--due good-scroll--timer)
                  (- before 1e-6))))))

(ert-deftest good-scroll-config-reenabling-leaves-one-timer ()
  (good-scroll-config-test--with-mode
    (good-scroll-mode 1)
    (should-not (good-scroll-config-test--active-timers))
    (good-scroll-move 80)
    (good-scroll-mode 1)
    (setq good-scroll--window nil
          good-scroll-destination 0)
    (good-scroll--render)
    (should-not (good-scroll-config-test--active-timers))
    (good-scroll-move 80)
    (should (equal (good-scroll-config-test--active-timers)
                   (list good-scroll--timer)))))

;;; good-scroll-config-test.el ends here
