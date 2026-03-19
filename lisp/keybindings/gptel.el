;;; config/keybindings/gptel.el -*- lexical-binding: t; -*-
;; GPTel Keybindings - Standalone map! blocks only

;; Global keybindings for gptel (available immediately, not deferred)
(map! :leader
      (:prefix-map ("a" . "applications")
       (:prefix ("g" . "gptel")
        :desc "Start gptel chat" "g" #'gptel
        :desc "Send region/buffer" "s" #'gptel-send
        :desc "Open gptel menu" "m" #'gptel-menu
        :desc "Set system message" "S" #'gptel-system-prompt
        :desc "Add context from file" "f" #'gptel-add-file
        :desc "Rewrite selection" "r" #'gptel-rewrite-safe
        :desc "Kill gptel session" "k" #'gptel-abort)))
