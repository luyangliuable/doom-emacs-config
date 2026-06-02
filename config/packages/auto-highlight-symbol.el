;;; config/packages/auto-highlight-symbol.el -*- lexical-binding: t; -*-
;; Auto-highlight symbol under cursor (VSCode-style)

(use-package! auto-highlight-symbol
  :defer t
  :config
  ;; Increase idle delay to reduce overhead (was 0.35s)
  (setq ahs-idle-interval 1.0)

  ;; Highlight in entire buffer
  (setq ahs-default-range 'ahs-range-whole-buffer)

  ;; Case-sensitive highlighting
  (setq ahs-case-fold-search nil)

  ;; Enable in all programming modes
  (add-hook 'prog-mode-hook #'auto-highlight-symbol-mode))
