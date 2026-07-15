;;; config/packages/beacon.el -*- lexical-binding: t; -*-
;; Beacon - highlight cursor position on big movements.
;; Lazy load after 5 seconds to improve startup performance.

(use-package! beacon
  :defer 5
  :init
  ;; Beacon appearance settings (optimized for faster animation)
  (setq beacon-blink-duration 0.3 ;; Faster animation (was 0.8)
    beacon-blink-delay 0.1        ;; Faster start (was 0.3)
    beacon-size 40                ;; Size of the beacon
    beacon-color "#ff9d00"        ;; Color of the beacon
    beacon-push-mark 35 ;; Number of moves before pushing a new mark onto the ring
    beacon-dont-blink-commands '() ;; Commands that won't trigger a blink
    beacon-blink-when-buffer-changes t     ;; Blink when switching buffers
    beacon-blink-when-window-changes t     ;; Blink when switching windows
    beacon-blink-when-point-moves t        ;; Blink when point moves
    beacon-blink-when-window-scrolls t     ;; Blink when window scrolls
    beacon-blink-when-focused t)           ;; Blink when the frame gains focus
  :config
  (beacon-mode 1))
