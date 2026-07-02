;;; config/packages/evil.el -*- lexical-binding: t; -*-
;; Evil Mode Package Configuration

;;; ============================================================================
;;; PACKAGE CONFIGURATION
;;; ============================================================================

;; Pre-load evil variables are centralized in early-init.el.
(use-package! evil
  :config
  ;; Force initialize operator system after evil loads
  (when (fboundp 'evil-normalize-keymaps)
    (evil-normalize-keymaps)))

;; Configure evil-collection to not interfere with operators
(use-package! evil-collection
  :after evil
  :config
  ;; PERFORMANCE: Removed (evil-collection-init) to enable lazy per-mode loading
  ;; Evil-collection will automatically load modes when they're first activated
  ;; This prevents loading 20+ modes synchronously at startup
  ;; Keep evil-collection lazy without logging every mode it initializes.
  nil)

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