;;; config/keybindings/shell.el -*- lexical-binding: t; -*-
;; Shell Mode Keybindings - Standalone after! blocks only

;; Shell mode local leader keybindings
(map! :map shell-mode-map
      :localleader
      :desc "Clear shell buffer" "c" (lambda ()
                                       (interactive)
                                       (luyangliuable/shell-clear-buffer)
                                       (sit-for 0.1) ; Brief pause for buffer updates
                                       (redisplay t) ; Force redisplay
                                       (evil-scroll-line-to-top (line-number-at-pos)))
      :desc "Command history" "h" #'comint-history-isearch-backward-regexp
      :desc "Previous command" "p" #'comint-previous-input
      :desc "Next command" "n" #'comint-next-input
      :desc "Kill current command" "k" #'luyangliuable/shell-kill-current-command
      :desc "Interrupt process (C-c)" "i" #'luyangliuable/shell-interrupt-process
      :desc "Send EOF (C-d)" "d" #'luyangliuable/shell-send-eof
      :desc "Copy last output" "y" #'luyangliuable/shell-copy-last-output
      :desc "Previous prompt" "[" #'comint-previous-prompt
      :desc "Next prompt" "]" #'comint-next-prompt
      :desc "Beginning of line" "a" #'comint-bol
      :desc "List input ring" "l" #'comint-dynamic-list-input-ring)
