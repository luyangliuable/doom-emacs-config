;;; config/packages/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Package Configuration

(use-package! org-jira
  :defer t
  :config
  (make-directory "~/.org-jira")
  (setq jiralib-url "https://commbank.atlassian.net"))
