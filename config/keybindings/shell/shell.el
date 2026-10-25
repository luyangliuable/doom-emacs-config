;;; config/keybindings/shell/shell.el -*- lexical-binding: t; -*-
;; Original shell backend keybindings.

(map! :leader
  :desc "Run shell in project"
  "p$." #'projectile-run-shell

  :desc "Split window vertically and run shell"
  "p$v"
  (lambda ()
    (interactive)
    (split-window-right)
    (other-window 1)
    (projectile-run-shell))

  :desc "Split window horizontally and run shell"
  "p$s"
  (lambda ()
    (interactive)
    (split-window-below)
    (other-window 1)
    (projectile-run-shell))

  :desc "Split window vertically and run shell (stay)"
  "p$V"
  (lambda ()
    (interactive)
    (split-window-right)
    (other-window 1)
    (projectile-run-shell)
    (other-window -1))

  :desc "Split window horizontally and run shell (stay)"
  "p$S"
  (lambda ()
    (interactive)
    (split-window-below)
    (other-window 1)
    (projectile-run-shell)
    (other-window -1))

  :desc "Run new shell in project"
  "p!." #'luyangliuable/new-shell-for-project

  :desc "Split window vertically and run new shell"
  "p!v"
  (lambda ()
    (interactive)
    (split-window-right)
    (other-window 1)
    (luyangliuable/new-shell-for-project))

  :desc "Split window horizontally and run new shell"
  "p!s"
  (lambda ()
    (interactive)
    (split-window-below)
    (other-window 1)
    (luyangliuable/new-shell-for-project))

  :desc "Split window vertically and run new shell (stay)"
  "p!V"
  (lambda ()
    (interactive)
    (split-window-right)
    (other-window 1)
    (luyangliuable/new-shell-for-project)
    (other-window -1))

  :desc "Split window horizontally and run new shell (stay)"
  "p!S"
  (lambda ()
    (interactive)
    (split-window-below)
    (other-window 1)
    (luyangliuable/new-shell-for-project)
    (other-window -1))

  :desc "Split window bottom and open shell"
  "p|" #'luyangliuable/treemacs-shell-here-horizontal

  :desc "New shell for project (split)"
  "p@" #'luyangliuable/new-shell-for-project-split)

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
