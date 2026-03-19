;;; config/packages/auto-highlight-symbol.el -*- lexical-binding: t; -*-
;; Auto-highlight symbol under cursor (VSCode-style)

(use-package! auto-highlight-symbol
  :config
  ;; Idle delay before highlighting (0.35 seconds)
  (setq ahs-idle-interval 0.35)

  ;; Highlight in entire buffer
  (setq ahs-default-range 'ahs-range-whole-buffer)

  ;; Case-sensitive highlighting
  (setq ahs-case-fold-search nil)

  ;; Enable in all programming modes
  (add-hook 'prog-mode-hook #'auto-highlight-symbol-mode))
