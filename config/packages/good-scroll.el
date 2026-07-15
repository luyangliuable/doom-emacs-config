;;; config/packages/good-scroll.el -*- lexical-binding: t; -*-
;; Good scroll - smooth scrolling.
;; Lazy load after 3 seconds with optimized settings.

(use-package good-scroll
  :defer 3
  :config
  ;; Optimized scrolling settings for better performance
  (setq good-scroll-duration 0.05) ;; Faster duration for better performance (was 0.1)
  (setq good-scroll-amount 2)      ;; Smaller scroll amount (was 3)
  (setq good-scroll-algorithm #'good-scroll-linear)

  (good-scroll-mode 1))
