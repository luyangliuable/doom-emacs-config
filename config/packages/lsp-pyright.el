;;; config/packages/lsp-pyright.el -*- lexical-binding: t; -*-
;; Pyright Language Server Configuration

(use-package! lsp-pyright
  :after lsp-mode
  :config
  ;; Automatically detect Python virtual environments
  (setq lsp-pyright-venv-path
        (expand-file-name (or (getenv "WORKON_HOME") "~/.virtualenvs")))
  (setq lsp-pyright-auto-import-completions t)
  (setq lsp-pyright-auto-search-paths t)
  (setq lsp-pyright-use-library-code-for-types t))
