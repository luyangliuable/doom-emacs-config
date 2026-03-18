;;; config/keybindings/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Keybindings

(after! lsp-mode
  (map! :map lsp-mode-map
        :localleader
        ;; Format
        "=" "format"
        :desc "Format buffer" "=b" #'lsp-format-buffer
        :desc "Format region" "=r" #'lsp-format-region
        :desc "Organize imports" "=o" #'lsp-organize-imports

        ;; Code actions
        "a" "code actions"
        :desc "Execute code action" "aa" #'lsp-execute-code-action

        ;; Goto
        "g" "goto"
        :desc "Jump to definition" "gg" #'lsp-find-definition
        :desc "Find implementation" "gi" #'lsp-find-implementation
        :desc "Find references" "gr" #'lsp-find-references
        :desc "Find type definition" "gt" #'lsp-find-type-definition

        ;; Help
        "h" "help"
        :desc "Describe thing at point" "hh" #'lsp-describe-thing-at-point

        ;; Refactor
        "r" "refactor"
        :desc "Rename" "rr" #'lsp-rename

        ;; Backend
        "b" "backend"
        :desc "Describe session" "bd" #'lsp-describe-session
        :desc "Restart workspace" "br" #'lsp-workspace-restart
        :desc "Shutdown workspace" "bs" #'lsp-workspace-shutdown
        :desc "LSP version" "bv" #'lsp-version

        ;; Folders
        "F" "folder"
        :desc "Add folder" "Fa" #'lsp-workspace-folders-add
        :desc "Remove folder" "Fr" #'lsp-workspace-folders-remove
        :desc "Switch folder" "Fs" #'lsp-workspace-folders-switch))
