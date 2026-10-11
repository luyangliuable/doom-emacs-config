;;; config/packages/copilot.el -*- lexical-binding: t; -*-
;; GitHub Copilot configuration.
;;
;; TAB is intentionally left to YASnippet in this Doom config, and C-TAB is
;; reserved for workspace switching.  Copilot uses M-RET / M-l while a ghost
;; completion is visible, plus SPC a c for explicit commands.

(defvar luyangliuable/copilot--missing-server-reported nil
  "Non-nil once the missing Copilot server hint has been shown.")

(defun luyangliuable/copilot-server-installed-p ()
  "Return non-nil when the Copilot language server executable exists."
  (and (require 'copilot nil t)
       (let ((executable (ignore-errors (copilot-server-executable))))
         (and executable (file-exists-p executable)))))

(defun luyangliuable/copilot-maybe-enable ()
  "Enable `copilot-mode' only when its language server is installed.
A missing server or startup failure must not abort the mode hook, otherwise
later hook functions such as `display-line-numbers-mode' never run."
  (if (luyangliuable/copilot-server-installed-p)
      (condition-case err
          (copilot-mode 1)
        (error (message "Copilot disabled: %s" (error-message-string err))))
    (unless luyangliuable/copilot--missing-server-reported
      (setq luyangliuable/copilot--missing-server-reported t)
      (message "Copilot server not installed; run M-x copilot-install-server (SPC a c i)"))))

(use-package! copilot
  :hook (prog-mode . luyangliuable/copilot-maybe-enable)
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
