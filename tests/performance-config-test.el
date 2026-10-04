;;; tests/performance-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

;; Stubs below replace primitives only for the (interpreted) code under test;
;; trampolines would make each one a slow native compile that needs gcc.
(setq native-comp-enable-subr-trampolines nil)

(defmacro after! (&rest _))

;; Doom's version native-compiles in a blocking subprocess; it must never run.
(defun doom-compile-functions (&rest _)
  (error "Doom's native `doom-compile-functions' ran"))

(load (expand-file-name "../config/packages/performance.el"
                        (file-name-directory (or load-file-name buffer-file-name)))
      nil t)

(defvar performance-config-test--log nil)

(defvar performance-config-test--now 0.0
  "Fake `float-time'; feature files advance it to simulate their load time.")

(defun performance-config-test--spend (secs)
  (setq performance-config-test--now (+ performance-config-test--now secs)))

(defun performance-config-test--dir (specs)
  "Make a directory with one feature file per (FEATURE . BODY) in SPECS.
String elements of BODY are inserted verbatim."
  (let ((dir (make-temp-file "performance-config-test" t)))
    (pcase-dolist (`(,feature . ,body) specs)
      (with-temp-file (expand-file-name (format "%s.el" feature) dir)
        (insert ";;; -*- lexical-binding: t; -*-\n")
        (dolist (form body)
          (if (stringp form) (insert form) (prin1 form (current-buffer)))
          (insert "\n"))
        (prin1 `(push ',feature performance-config-test--log) (current-buffer))
        (prin1 `(provide ',feature) (current-buffer))))
    dir))

(defun performance-config-test--slice-timers ()
  (cl-remove-if-not (lambda (timer)
                      (eq (timer--function timer) #'luyangliuable/require-when-idle))
                    timer-idle-list))

(defmacro performance-config-test--with-features (specs &rest body)
  "Run BODY with SPECS on `load-path', none of their features loaded, and a fake clock."
  (declare (indent 1))
  `(let* ((dir (performance-config-test--dir ,specs))
          (load-path (cons dir load-path))
          (performance-config-test--log nil)
          (performance-config-test--now 0.0)
          (real-float-time (symbol-function 'float-time)))
     (unwind-protect
         (cl-letf (((symbol-function 'float-time)
                    (lambda (&optional time)
                      (if time (funcall real-float-time time) performance-config-test--now))))
           (dlet ((features features))
             ,@body))
       (cancel-function-timers #'luyangliuable/require-when-idle)
       (delete-directory dir t))))

(ert-deftest performance-config-require-when-idle-loads-in-order-then-calls-then ()
  (performance-config-test--with-features '((pct-a) (pct-b) (pct-c))
    (let (called)
      (cl-letf (((symbol-function 'input-pending-p) #'ignore))
        (luyangliuable/require-when-idle
         '(pct-a (pct-missing nil t) pct-b pct-c)
         (lambda () (setq called (reverse performance-config-test--log)))))
      (should (equal '(pct-a pct-b pct-c) called))
      (should-not (performance-config-test--slice-timers)))))

(ert-deftest performance-config-require-when-idle-yields-to-input ()
  (performance-config-test--with-features '((pct-a) (pct-b) (pct-c))
    (let (called)
      (cl-letf (((symbol-function 'input-pending-p) #'always)
                ((symbol-function 'current-idle-time) (lambda () 2.0)))
        (luyangliuable/require-when-idle '(pct-a pct-b pct-c)
                                         (lambda () (setq called t))))
      ;; One whole file per slice, then it waits until idle again.
      (should (equal '(pct-a) performance-config-test--log))
      (should-not called)
      (let ((timers (performance-config-test--slice-timers)))
        (should (= 1 (length timers)))
        (should (equal '(pct-b pct-c) (car (timer--args (car timers)))))
        (should (functionp (cadr (timer--args (car timers)))))
        (should (< (abs (- (float-time (timer--time (car timers))) 2.05)) 1e-6))
        ;; The next idle slice continues where it stopped.
        (cancel-timer (car timers))
        (cl-letf (((symbol-function 'input-pending-p) #'ignore))
          (apply #'luyangliuable/require-when-idle (timer--args (car timers)))))
      (should (equal '(pct-c pct-b pct-a) performance-config-test--log))
      (should called))))

(ert-deftest performance-config-require-when-idle-yields-after-50ms ()
  (performance-config-test--with-features
      '((pct-a (performance-config-test--spend 0.03))
        (pct-b (performance-config-test--spend 0.03))
        (pct-c))
    (cl-letf (((symbol-function 'input-pending-p) #'ignore))
      (luyangliuable/require-when-idle '(pct-a pct-b pct-c)))
    (should (equal '(pct-b pct-a) performance-config-test--log))
    (should (equal '((pct-c) nil)
                   (timer--args (car (performance-config-test--slice-timers)))))))

(ert-deftest performance-config-require-when-idle-runs-then-in-a-fresh-slice ()
  (performance-config-test--with-features
      '((pct-a (performance-config-test--spend 0.06))
        (pct-b (performance-config-test--spend 0.06)))
    (let (called)
      (cl-letf (((symbol-function 'input-pending-p) #'ignore))
        ;; Nothing left to do: no slice is scheduled.
        (luyangliuable/require-when-idle '(pct-a))
        (should-not (performance-config-test--slice-timers))
        (luyangliuable/require-when-idle '(pct-b) (lambda () (setq called t)))
        (should (equal '(pct-b pct-a) performance-config-test--log))
        (should-not called)
        (let ((timer (car (performance-config-test--slice-timers))))
          (should (equal nil (car (timer--args timer))))
          (cancel-timer timer)
          (apply #'luyangliuable/require-when-idle (timer--args timer))))
      (should called)
      (should-not (performance-config-test--slice-timers)))))

(ert-deftest performance-config-require-when-idle-surfaces-errors ()
  (performance-config-test--with-features '((pct-a) (pct-b (error "Boom")) (pct-c))
    (let (called)
      (cl-letf (((symbol-function 'input-pending-p) #'ignore))
        (should (equal '(error "Boom")
                       (should-error
                        (luyangliuable/require-when-idle
                         '(pct-a pct-b pct-c) (lambda () (setq called t)))))))
      (should (equal '(pct-a) performance-config-test--log))
      (should-not called)
      (should-not (performance-config-test--slice-timers)))))

(ert-deftest performance-config-preload-when-idle-loads-header-requires-first ()
  (performance-config-test--with-features
      '((pct-a) (pct-b) (pct-c) (pct-d)
        (pct-lib "(defconst pct-lib-version \"1\")\n;;; Code:"
                 (require 'pct-a)
                 (eval-when-compile (require 'pct-b))
                 (require 'pct-c nil :noerror)
                 (require 'pct-missing nil 'noerror)
                 (defvar pct-lib-var nil)
                 (require 'pct-d)))
    (let (called)
      (cl-letf (((symbol-function 'input-pending-p) #'always)
                ((symbol-function 'current-idle-time) (lambda () 2.0)))
        (luyangliuable/preload-when-idle 'pct-lib (lambda () (setq called t))))
      ;; One file per slice: the requires opening its code (minus compile-time
      ;; ones, as when loading its compiled file), then the library itself.
      (should (equal '(pct-a) performance-config-test--log))
      (let ((timer (car (performance-config-test--slice-timers))))
        (should (equal '((pct-c nil :noerror) (pct-missing nil noerror) pct-lib)
                       (car (timer--args timer))))
        (cancel-timer timer)
        (cl-letf (((symbol-function 'input-pending-p) #'ignore))
          (apply #'luyangliuable/require-when-idle (timer--args timer))))
      (should (equal '(pct-a pct-c pct-b pct-d pct-lib)
                     (reverse performance-config-test--log)))
      (should called))))

(ert-deftest performance-config-doom-compile-functions-byte-compiles-once-idle ()
  (fset 'pct-square (eval '(lambda (x) (* x x)) t))
  (fset 'pct-cube (eval '(lambda (x) (* x x x)) t))
  (byte-compile 'pct-cube)
  (let ((cube (symbol-function 'pct-cube)))
    (unwind-protect
        (progn
          (doom-compile-functions #'pct-square #'pct-cube)
          (should (interpreted-function-p (symbol-function 'pct-square)))
          (let ((timers (cl-remove-if-not
                         (lambda (timer)
                           (eq (timer--function timer) #'luyangliuable/byte-compile-functions))
                         timer-idle-list)))
            (should (= 1 (length timers)))
            (should (= 1.5 (float-time (timer--time (car timers)))))
            (should-not (timer--repeat-delay (car timers)))
            (cl-letf (((symbol-function 'native-compile) (lambda (&rest _) (error "native"))))
              (apply #'luyangliuable/byte-compile-functions (timer--args (car timers)))))
          (should (byte-code-function-p (symbol-function 'pct-square)))
          (should (= 9 (pct-square 3)))
          (should (eq cube (symbol-function 'pct-cube))))
      (cancel-function-timers #'luyangliuable/byte-compile-functions)
      (fmakunbound 'pct-square)
      (fmakunbound 'pct-cube))))

;;; performance-config-test.el ends here
