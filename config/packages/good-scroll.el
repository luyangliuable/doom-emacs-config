;;; config/packages/good-scroll.el -*- lexical-binding: t; -*-
;; Good scroll - smooth scrolling.
;; Lazy load after 3 seconds with optimized settings.

;; `good-scroll-mode' renders from a 50 Hz timer that runs forever, but
;; `good-scroll--render' does nothing unless a scroll is pending.  Pause that
;; same timer while idle and resume it on its original grid when a scroll starts.
(defun luyangliuable/good-scroll-pending-p ()
  "Return non-nil while `good-scroll--render' has a scroll to render."
  (and (numberp good-scroll-destination) (/= good-scroll-destination 0)))

(defun luyangliuable/good-scroll-pause (&rest _)
  "Stop the render timers while no scroll is pending."
  (unless (luyangliuable/good-scroll-pending-p)
    (cancel-function-timers #'good-scroll--render)))

(defun luyangliuable/good-scroll-resume (&rest _)
  "Resume `good-scroll--timer' on its original grid once a scroll is pending."
  (when (and good-scroll-mode
             (timerp good-scroll--timer)
             (luyangliuable/good-scroll-pending-p)
             (not (memq good-scroll--timer timer-list)))
    (let ((late (float-time (time-since (timer--time good-scroll--timer))))
          (rate (timer--repeat-delay good-scroll--timer)))
      (when (> late 0)
        (timer-inc-time good-scroll--timer (* rate (ceiling late rate))))
      (timer-activate good-scroll--timer))))

(use-package good-scroll
  :defer 3
  :config
  ;; Optimized scrolling settings for better performance
  (setq good-scroll-duration 0.05) ;; Faster duration for better performance (was 0.1)
  (setq good-scroll-amount 2)      ;; Smaller scroll amount (was 3)
  (setq good-scroll-algorithm #'good-scroll-linear)

  (advice-add 'good-scroll-mode :after #'luyangliuable/good-scroll-pause)
  (advice-add 'good-scroll--render :after #'luyangliuable/good-scroll-pause)
  (advice-add 'good-scroll-move :after #'luyangliuable/good-scroll-resume)
  (good-scroll-mode 1))
