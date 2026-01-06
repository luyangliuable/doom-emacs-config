;;; config/packages/editorconfig.el -*- lexical-binding: t; -*-
;; EditorConfig Package Configuration

;; EditorConfig - respect project .editorconfig files
(use-package! editorconfig
  :config
  (editorconfig-mode 1)
  ;; Ensure EditorConfig takes precedence over mode defaults
  (setq editorconfig-get-properties-function
        'editorconfig-get-properties)
  ;; Apply to all relevant file types
  (add-hook 'prog-mode-hook (lambda () (editorconfig-apply)))
  (add-hook 'text-mode-hook (lambda () (editorconfig-apply))))