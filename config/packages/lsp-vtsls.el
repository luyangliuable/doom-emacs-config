;;; config/packages/lsp-vtsls.el -*- lexical-binding: t; -*-
;; vtsls Language Server Configuration

(use-package! lsp-vtsls
  :after lsp-mode
  :config
  ;; Ensure vtsls activates for TypeScript/JavaScript modes
  (setq lsp-vtsls-activate-languages
        '("typescript" "typescriptreact" "javascript" "javascriptreact"))
  
  ;; Enable fuzzy matching for better completions (optional)
  (setq lsp-vtsls-server-side-fuzzy-match t)
  
  ;; Auto-use workspace TypeScript version (optional)
  (setq lsp-vtsls-auto-use-workspace-tsdk t))
