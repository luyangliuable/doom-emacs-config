;;; config/core.el -*- lexical-binding: t; -*-
;; Core Doom Emacs Settings

;;; ============================================================================
;;; CORE SETTINGS
;;; ============================================================================

;; Ensure Emacs inherits shell PATH (macOS fix for npm/node/LSP)
(use-package! exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))
;; Font configuration
(setq doom-font (font-spec :family "Fira Code" :size 13 :weight 'semi-light))

;; Display settings
(setq display-line-numbers-type 'relative)  ;; show relative line number
(setq blink-cursor-mode t)                  ;; show blinking cursor
(scroll-bar-mode -1)                         ;; don't show scrollbar
(evil-goggles-mode t)                       ;; enable evil-goggles-mode
;; (add-hook 'find-file-hook 'undo-tree-mode)  ;; enable undo-tree-mode for all buffer
;; (set-fringe-mode 1)                      ;; fringe mode minimal

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

;; Proxy configuration
;; (setq url-proxy-services
;;       '(("http" . "localhost:3128")
;;         ("https" . "localhost:3128")
;;         ("ftp" . "localhost:3128")))

;; Ensure proxy is used for all HTTP/HTTPS requests
;; (setq url-gateway-method 'native)

;;; ============================================================================
;;; RIPGREP CONFIGURATION
;;; ============================================================================

;; Use ripgrep if available, otherwise use default grep
(when (executable-find "rg")
  ;; Ensure ripgrep is found
  (setq-default grep-command "rg --color=never --no-heading --line-number --smart-case ")
  (setq-default grep-use-null-device nil)

  ;; Use ripgrep for project-wide searches
  (setq xref-search-program 'ripgrep))
