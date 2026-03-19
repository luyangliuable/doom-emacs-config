;;; config/packages/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Package Configuration

;; LSP configuration (consolidated from multiple blocks)
(after! lsp-mode
  ;; LSP headerline breadcrumb navigation
  (setq lsp-headerline-breadcrumb-enable t)
  (lsp-headerline-breadcrumb-mode 1)

  ;; Ensure electric-indent works in LSP buffers
  (add-hook 'lsp-mode-hook #'electric-indent-local-mode)

  ;; TypeScript/JavaScript server preferences
  (setq lsp-disabled-clients '(jsts-ls))
  (setq lsp-clients-typescript-prefer-use-project-ts-server nil)

  ;; Language ID configuration for multiple languages
  ;; TypeScript/JavaScript
  (add-to-list 'lsp-language-id-configuration '(typescript-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(typescript-ts-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(tsx-ts-mode . "typescriptreact"))
  (add-to-list 'lsp-language-id-configuration '(js2-mode . "javascript"))
  (add-to-list 'lsp-language-id-configuration '(rjsx-mode . "javascriptreact"))

  ;; Python
  (add-to-list 'lsp-language-id-configuration '(python-mode . "python"))
  (add-to-list 'lsp-language-id-configuration '(python-ts-mode . "python"))

  ;; Rust
  (add-to-list 'lsp-language-id-configuration '(rust-mode . "rust"))
  (add-to-list 'lsp-language-id-configuration '(rust-ts-mode . "rust"))

  ;; Go
  (add-to-list 'lsp-language-id-configuration '(go-mode . "go"))
  (add-to-list 'lsp-language-id-configuration '(go-ts-mode . "go"))

  ;; C/C++
  (add-to-list 'lsp-language-id-configuration '(c-mode . "c"))
  (add-to-list 'lsp-language-id-configuration '(c++-mode . "cpp"))
  (add-to-list 'lsp-language-id-configuration '(c-ts-mode . "c"))
  (add-to-list 'lsp-language-id-configuration '(c++-ts-mode . "cpp"))

  ;; Java
  (add-to-list 'lsp-language-id-configuration '(java-mode . "java"))
  (add-to-list 'lsp-language-id-configuration '(java-ts-mode . "java")))

;; LSP-Treemacs integration
(use-package! lsp-treemacs
  :after lsp-mode
  :config
  (map! :map lsp-mode-map
        :localleader
        :desc "lsp-treemacs-errors-list" "ge" #'lsp-treemacs-errors-list))

;; Note: Standalone map!/after! blocks moved to config/keybindings/lsp.el
