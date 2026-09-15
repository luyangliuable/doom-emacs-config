;;; config/packages/copilot.el -*- lexical-binding: t; -*-
;; GitHub Copilot configuration.
;;
;; TAB is intentionally left to YASnippet in this Doom config, and C-TAB is
;; reserved for workspace switching.  Copilot uses M-RET / M-l while a ghost
;; completion is visible, plus SPC a c for explicit commands.

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("M-RET" . copilot-accept-completion)
              ("M-l" . copilot-accept-completion-by-word)
              ("M-n" . copilot-next-completion)
              ("M-p" . copilot-previous-completion))
  :config
  (map! :leader
        (:prefix-map ("a" . "applications")
         (:prefix ("c" . "copilot")
          :desc "Complete now" "c" #'copilot-complete
          :desc "Chat" "h" #'copilot-chat
          :desc "Install/update server" "i" #'copilot-install-server
          :desc "Login" "l" #'copilot-login
          :desc "Copilot menu" "m" #'copilot-menu
          :desc "Diagnose" "d" #'copilot-diagnose))))
