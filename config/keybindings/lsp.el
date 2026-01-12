;;; config/keybindings/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Keybindings - Standalone after! blocks only

;; LSP keybindings (standalone after! block)
(after! lsp-mode
  (map! :map lsp-mode-map
        :localleader
        :desc "Describe" "hh" #'lsp-describe-thing-at-point
        :desc "Find implementation" "gi" #'lsp-find-implementation
        :desc "Find references" "gr" #'lsp-find-references
        :desc "Jump to definition" "gg" #'lsp-find-definition))