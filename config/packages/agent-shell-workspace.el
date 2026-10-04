;;; config/packages/agent-shell-workspace.el -*- lexical-binding: t; -*-

(add-to-list 'load-path
             (expand-file-name
              (format "straight/build-%s/agent-shell-workspace/" emacs-version)
              doom-local-dir))

(use-package! agent-shell-workspace
  :after agent-shell
  :config
  (map! :map agent-shell-mode-map
        :localleader
        :desc "Toggle agent workspace" "w" #'agent-shell-workspace-toggle))
