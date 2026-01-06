;;; config/packages/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Package Configuration

;; LSP configuration (consolidated from multiple blocks)
(after! lsp-mode
  ;; LSP headerline breadcrumb navigation
  (setq lsp-headerline-breadcrumb-enable t)
  (lsp-headerline-breadcrumb-mode 1)

  ;; TypeScript/JavaScript server preferences
  (setq lsp-disabled-clients '(jsts-ls))
  (setq lsp-clients-typescript-prefer-use-project-ts-server nil)

  ;; Language ID configuration for TypeScript files
  (add-to-list 'lsp-language-id-configuration '(typescript-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(typescript-ts-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(tsx-ts-mode . "typescriptreact"))

  ;; LSP keybindings
  (map! :map lsp-mode-map
        :localleader
        :desc "Describe" "hh" #'lsp-describe-thing-at-point
        :desc "Find implementation" "gi" #'lsp-find-implementation
        :desc "Find references" "gr" #'lsp-find-references
        :desc "Jump to definition" "gg" #'lsp-find-definition))

;; LSP-Treemacs integration
(use-package! lsp-treemacs
  :after lsp-mode
  :config
  (map! :map lsp-mode-map
        :localleader
        :desc "lsp-treemacs-errors-list" "ge" #'lsp-treemacs-errors-list))