;;; config/packages/agent-shell-hud.el -*- lexical-binding: t; -*-

(add-to-list 'load-path
             (expand-file-name
              (format "straight/build-%s/agent-shell-hud/" emacs-version)
              doom-local-dir))

;; Load Workspace HUD with Agent Shell, before Agent Shell HUD, as at startup.
(with-eval-after-load 'agent-shell
  (require 'workspace-hud))

(use-package! agent-shell-hud
  :after (workspace-hud agent-shell)
  :demand t
  :config
  (agent-shell-hud-mode 1))
