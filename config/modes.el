;;; config/modes.el -*- lexical-binding: t; -*-
;; Mode Hooks and Custom Functions

;;; ============================================================================
;;; MODE HOOKS & CUSTOM FUNCTIONS
;;; ============================================================================

;; Web mode configuration
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

(add-hook 'web-mode-hook 'my-web-mode-hook)