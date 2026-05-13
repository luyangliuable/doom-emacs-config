;;; performance.el --- Performance optimizations -*- lexical-binding: t; -*-
;;;
;;; This file contains performance optimizations that don't disable features.
;;; Focus: Reduce unnecessary work, optimize timings, improve GC behavior.

;;; ============================================================================
;;; GARBAGE COLLECTION OPTIMIZATION
;;; ============================================================================

;; Increase GC threshold during startup (Doom already does this, but we ensure it)
(setq gc-cons-threshold most-positive-fixnum)  ; Disable GC during startup

;; After startup, use a more reasonable threshold
(add-hook 'emacs-startup-hook
  (lambda ()
    ;; 100MB threshold (vs default 800KB) - fewer GC pauses
    (setq gc-cons-threshold (* 100 1024 1024))
    ;; Increase memory limit before warning
    (setq gc-cons-percentage 0.1)))

;; GC when idle for 5 seconds
(run-with-idle-timer 5 t #'garbage-collect)

;; GC when Emacs loses focus (out of the way)
(add-function :after after-focus-change-function #'garbage-collect)

;;; ============================================================================
;;; FILE HANDLING OPTIMIZATIONS
;;; ============================================================================

;; Increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024))  ; 1MB (default is 4KB)

;; Don't ping remote servers for file-name-handlers
(setq remote-file-name-inhibit-cache nil)
(setq vc-ignore-dir-regexp
      (format "\\(%s\\)\\|\\(%s\\)"
              vc-ignore-dir-regexp
              tramp-file-name-regexp))

;; Reduce auto-save frequency
(setq auto-save-interval 300)        ; keystrokes (default 300)
(setq auto-save-timeout 30)          ; seconds (default 30)

;;; ============================================================================
;;; FONT RENDERING OPTIMIZATION
;;; ============================================================================

;; Reduce font rendering overhead
(setq inhibit-compacting-font-caches t)  ; Don't compact font caches during GC

;;; ============================================================================
;;; PACKAGE-SPECIFIC OPTIMIZATIONS
;;; ============================================================================

;; Flycheck: Optimize timing without disabling features
(after! flycheck
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled))
  (setq flycheck-idle-change-delay 1.0)       ; Check after 1s idle (was 2s)
  (setq flycheck-idle-buffer-switch-delay 1.0) ; Check after switching buffers
  (setq flycheck-display-errors-delay 0.5))   ; Show errors faster

;; Company: Optimize popup timing
(after! company
  (setq company-idle-delay 0.3)               ; Show completions after 0.3s (was 0.5s)
  (setq company-minimum-prefix-length 2)      ; Start after 2 chars
  (setq company-show-quick-access t)          ; Show quick access numbers
  (setq company-tooltip-limit 10)             ; Show max 10 candidates
  (setq company-tooltip-idle-delay 0.2))      ; Show tooltip faster

;; Diff-hl: Optimize git diff updates
(after! diff-hl
  (setq diff-hl-flydiff-delay 1.0)            ; Update after 1s idle (was 2s)
  (setq diff-hl-update-delay 0.5))            ; Visual update faster

;; Projectile: Cache aggressively
(after! projectile
  (setq projectile-enable-caching t)          ; Cache file lists
  (setq projectile-indexing-method 'alien)    ; Use external tools (faster)
  (setq projectile-sort-order 'recentf))      ; Sort by recent first

;; Which-key: Faster popup
(after! which-key
  (setq which-key-idle-delay 0.5)             ; Show after 0.5s (was 1s)
  (setq which-key-idle-secondary-delay 0.05)) ; Immediate for subsequent

;; Treemacs: Lazy refresh
(after! treemacs
  (setq treemacs-file-event-delay 2000)       ; Refresh every 2s (was 5s)
  (setq treemacs-file-follow-delay 0.1))      ; Follow quickly

;; Magit: Optimize status buffer
(after! magit
  (setq magit-refresh-status-buffer nil)      ; Don't auto-refresh (manual: g r)
  (setq magit-diff-refine-hunk t)             ; Show word-level diffs
  (setq magit-revision-show-gravatars nil))   ; Disable gravatar loading

;;; ============================================================================
;;; DISPLAY OPTIMIZATIONS
;;; ============================================================================

;; Reduce redisplay overhead
(setq-default bidi-display-reordering nil)    ; Disable bidirectional text (for Latin-only)
(setq-default cursor-in-non-selected-windows nil)  ; Hide cursors in other windows

;; Fast scrolling
(setq fast-but-imprecise-scrolling t)
(setq scroll-conservatively 101)              ; Smooth scrolling
(setq scroll-margin 0)
(setq scroll-preserve-screen-position t)

;; Reduce echo area message delay
(setq echo-keystrokes 0.02)                   ; Show keystrokes immediately
