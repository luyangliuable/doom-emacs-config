;;; config/packages/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Package Configuration

(use-package! org-jira
  :defer t
  :config
  (make-directory "~/.org-jira" t)
  (setq jiralib-url
        (let ((url (getenv "JIRA_URL")))
          (and url (not (equal url "")) url))))
