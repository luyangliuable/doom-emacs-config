;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-
;;;
;;; This file is loaded before init.el and package.el
;;; Use it for performance-critical early initialization

;;; Code:

;;; ============================================================================
;;; STARTUP PERFORMANCE OPTIMIZATION
;;; ============================================================================

;; Maximize GC threshold during startup (reset in config/packages/performance.el)
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Prevent unwanted runtime compilation
(setq comp-deferred-compilation nil)

;; Prefer loading newer compiled files
(setq load-prefer-newer t)

;; Don't use package.el; Doom uses straight.el
(setq package-enable-at-startup nil)

;;; ============================================================================
;;; UI OPTIMIZATION - Disable Before Frame Creation
;;; ============================================================================

;; Disable UI elements early to avoid flashing
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Disable bidirectional text scanning for performance
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)

;; Reduce rendering overhead
(setq frame-inhibit-implied-resize t)  ; Don't resize frame implicitly
(setq-default inhibit-redisplay t      ; Inhibit redisplay during startup
              inhibit-message t)        ; Inhibit messages during startup

;;; ============================================================================
;;; FILE NAME HANDLER OPTIMIZATION
;;; ============================================================================

;; Store file-name-handler-alist and set to nil during startup
(defvar doom--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Restore file-name-handler-alist after startup
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq file-name-handler-alist doom--file-name-handler-alist)
    (setq-default inhibit-redisplay nil
                  inhibit-message nil)))

;;; ============================================================================
;;; SITE-LISP OPTIMIZATION
;;; ============================================================================

;; Don't scan for autoloads in site-lisp
(setq site-run-file nil)

;; Reduce startup noise
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name)

;; Native compilation settings (Emacs 28+)
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors nil)  ; Silence warnings
  (setq native-comp-deferred-compilation t)            ; Compile in background
  (setq native-comp-speed 2))                          ; Optimize for speed

;;; early-init.el ends here
