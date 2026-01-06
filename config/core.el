;;; config/core.el -*- lexical-binding: t; -*-
;; Core Doom Emacs Settings

;;; ============================================================================
;;; CORE SETTINGS
;;; ============================================================================

;; Theme and appearance
(setq doom-theme 'doom-nord)

;; Font configuration
(setq doom-font (font-spec :family "Fira Code" :size 13 :weight 'semi-light))

;; Display settings
(setq display-line-numbers-type 'relative)
(setq blink-cursor-mode t)
(scroll-bar-mode -1)
(evil-goggles-mode t)

;; Window management - maximize on startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Focus Emacs window on startup (bring to front)
(when (display-graphic-p)
  (add-hook 'after-init-hook
    (lambda ()
      (when (eq system-type 'darwin) ; macOS
        (call-process "osascript" nil nil nil
          "-e" "tell application \"Emacs\" to activate")))))

;; Local leader key configuration
(setq doom-localleader-key ",")
(setq doom-localleader-alt-key "M-,")