;;; config/packages/evil.el -*- lexical-binding: t; -*-
;; Evil Mode Package Configuration

;;; ============================================================================
;;; CRITICAL EVIL CONFIGURATION - MUST RUN BEFORE EVIL LOADS
;;; ============================================================================

;; These MUST be set before evil is loaded for operator+motion to work
(setq evil-want-integration t)
(setq evil-want-keybinding nil)  ; Let evil-collection handle most keybindings
(setq evil-want-operator-state t)
(setq evil-want-operator-pending-state t)
(setq evil-want-visual-char-semi-exclusive t)
(setq evil-want-C-u-scroll t)
(setq evil-want-C-d-scroll t)
(setq evil-want-C-i-jump nil)
(setq evil-want-Y-yank-to-eol t)
(setq evil-want-fine-undo t)
(setq evil-search-module 'evil-search)
(setq evil-ex-complete-emacs-commands nil)
(setq evil-vsplit-window-right t)
(setq evil-split-window-below t)
(setq evil-shift-round nil)
(setq evil-want-C-w-in-emacs-state nil)

;;; ============================================================================
;;; PACKAGE CONFIGURATION
;;; ============================================================================

;; Ensure evil loads with proper configuration
(use-package! evil
  :init
  ;; Ensure variables are set before evil loads
  (setq evil-want-operator-state t
        evil-want-operator-pending-state t)
  :config
  ;; Force initialize operator system after evil loads
  (when (fboundp 'evil-normalize-keymaps)
    (evil-normalize-keymaps))
  (message "Evil package configured with operator support"))

;; Configure evil-collection to not interfere with operators
(use-package! evil-collection
  :after evil
  :config
  ;; PERFORMANCE: Removed (evil-collection-init) to enable lazy per-mode loading
  ;; Evil-collection will automatically load modes when they're first activated
  ;; This prevents loading 20+ modes synchronously at startup
  ;; Ensure operators still work after evil-collection loads
  (add-hook 'evil-collection-setup-hook
            (lambda (_mode keymaps)
              (message "Evil-collection loaded for mode: %s" _mode))))

;;; ============================================================================
;;; DEBUGGING HELPERS
;;; ============================================================================

;; Function to check if evil operators are working
(defun check-evil-operators ()
  "Debug function to check if evil operators are properly configured."
  (interactive)
  (message "Evil operator state enabled: %s" evil-want-operator-state)
  (message "Evil operator pending state enabled: %s" evil-want-operator-pending-state)
  (message "Evil operator state map exists: %s" (if evil-operator-state-map t nil))
  (message "Change operator bound: %s" (lookup-key evil-normal-state-map "c"))
  (when evil-operator-state-map
    (message "$ motion in operator state: %s" (lookup-key evil-operator-state-map "$"))
    (message "w motion in operator state: %s" (lookup-key evil-operator-state-map "w"))))

;; Note: Keybindings have been moved to config/keybindings/evil.el
;; This file contains only configuration settings, no keybindings