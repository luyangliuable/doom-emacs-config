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
;; Font configuration with dynamic screen-based sizing
(defvar doom-font-base-size nil
  "Base font size for global text scaling. Calculated on startup based on display height.")

(defun doom/calculate-font-size-for-display ()
  "Calculate appropriate font size based on display height.
Returns ~14pt for 1080p, ~20pt for 1440p, ~27pt for 4K displays."
  (max 14 (/ (display-pixel-height) 70)))

;; Calculate initial font size based on display
(setq doom-font-base-size (doom/calculate-font-size-for-display))
(setq doom-font (font-spec :family "Fira Code"
                           :size doom-font-base-size
                           :weight 'semi-light))

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

;;; ============================================================================
;;; GLOBAL TEXT SCALING FUNCTIONS
;;; ============================================================================

(defun doom/global-text-scale-adjust (increment)
  "Adjust font size globally across all buffers and frames.
INCREMENT is added to the current font size."
  (interactive "p")
  (let* ((current-size (or doom-font-base-size 16))
         (new-size (+ current-size increment)))
    (when (> new-size 0)
      (setq doom-font-base-size new-size)
      (set-frame-font (format "%s-%d"
                              (font-get doom-font :family)
                              new-size)
                      nil t)
      (message "Global font size: %d" new-size))))

(defun doom/global-text-scale-increase ()
  "Increase font size globally by 1 point."
  (interactive)
  (doom/global-text-scale-adjust 1))

(defun doom/global-text-scale-decrease ()
  "Decrease font size globally by 1 point."
  (interactive)
  (doom/global-text-scale-adjust -1))

(defun doom/global-text-scale-reset ()
  "Reset font size to display-calculated base size."
  (interactive)
  (let ((base-size (doom/calculate-font-size-for-display)))
    (setq doom-font-base-size base-size)
    (set-frame-font (format "%s-%d"
                            (font-get doom-font :family)
                            base-size)
                    nil t)
    (message "Reset global font size to: %d" base-size)))
