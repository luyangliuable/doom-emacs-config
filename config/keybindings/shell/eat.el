;;; config/keybindings/shell/eat.el -*- lexical-binding: t; -*-
;; Eat shell keybindings.


;;; ---------------------------------------------------------------------------
;;; Project Eat helpers
;;; ---------------------------------------------------------------------------

(defun luyangliuable/project-eat ()
  "Open or switch to the Eat terminal for the current project."
  (interactive)
  (let ((default-directory
         (or (projectile-project-root)
             default-directory)))
    (eat-project)))


(defun luyangliuable/project-eat-new ()
  "Create a new Eat terminal for the current project."
  (interactive)
  (let ((default-directory
         (or (projectile-project-root)
             default-directory)))
    ;; `eat-project' with a prefix argument creates another project terminal.
    (let ((current-prefix-arg '(4)))
      (call-interactively #'eat-project))))


(defun luyangliuable/project-eat-new-split ()
  "Create a new Eat terminal for the current project in a right split."
  (interactive)
  (split-window-right)
  (other-window 1)
  (luyangliuable/project-eat-new))


(defun luyangliuable/treemacs-eat-here-horizontal ()
  "Open Eat below, rooted at the selected Treemacs directory."
  (interactive)
  (let ((dir
         (cond
          ((and (derived-mode-p 'treemacs-mode)
                (fboundp 'treemacs-current-button)
                (treemacs-current-button))
           (let ((path
                  (treemacs-button-get
                   (treemacs-current-button)
                   :path)))
             (if (file-directory-p path)
                 path
               (file-name-directory path))))
          (t default-directory))))

    (split-window-below)
    (other-window 1)

    (let ((default-directory dir))
      (eat))))


;;; ---------------------------------------------------------------------------
;;; Eat terminal input
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-send-event (event &optional count)
  "Send EVENT COUNT times to the current Eat terminal."
  (unless (derived-mode-p 'eat-mode)
    (user-error "Not in an Eat buffer"))
  (eat-term-input-event eat-terminal (or count 1) event))


;;; ---------------------------------------------------------------------------
;;; Terminal editing helpers
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-beginning-of-command ()
  "Move to the beginning of the current shell command."
  (interactive)
  (luyangliuable/eat-send-event ?\C-a))


(defun luyangliuable/eat-end-of-command ()
  "Move to the end of the current shell command."
  (interactive)
  (luyangliuable/eat-send-event ?\C-e))


(defun luyangliuable/eat-send-C-c ()
  "Send C-c to the terminal."
  (interactive)
  (luyangliuable/eat-send-event ?\C-c))


(defun luyangliuable/eat-send-C-d ()
  "Send C-d to the terminal."
  (interactive)
  (luyangliuable/eat-send-event ?\C-d))


(defun luyangliuable/eat-kill-to-end ()
  "Kill from the shell cursor to the end of the current command."
  (interactive)
  (luyangliuable/eat-send-event ?\C-k))


(defun luyangliuable/eat-kill-command ()
  "Kill the entire current shell command."
  (interactive)
  ;; C-a followed by C-k.
  (luyangliuable/eat-send-event ?\C-a)
  (luyangliuable/eat-send-event ?\C-k))


(defun luyangliuable/eat-change-command ()
  "Kill the entire shell command and enter Evil insert state."
  (interactive)
  (luyangliuable/eat-kill-command)
  (evil-insert-state))


(defun luyangliuable/eat-change-to-end ()
  "Kill to the end of the shell command and enter Evil insert state."
  (interactive)
  (luyangliuable/eat-kill-to-end)
  (evil-insert-state))


(defun luyangliuable/eat-delete-char (&optional count)
  "Delete COUNT characters under the shell cursor."
  (interactive "p")
  (dotimes (_ (max 0 (or count 1)))
    ;; Send a real Delete keyboard event through Eat.
    (luyangliuable/eat-send-event 'delete)))


;;; ---------------------------------------------------------------------------
;;; Shell history helpers
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-previous-command ()
  "Request the previous command from the shell."
  (interactive)
  (luyangliuable/eat-send-event 'up))


(defun luyangliuable/eat-next-command ()
  "Request the next command from the shell."
  (interactive)
  (luyangliuable/eat-send-event 'down))


(defun luyangliuable/eat-command-history ()
  "Start reverse history search in the shell."
  (interactive)
  (luyangliuable/eat-send-event ?\C-r))


;;; ---------------------------------------------------------------------------
;;; Terminal management
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-interrupt-and-clear ()
  "Interrupt the current process and reset the Eat terminal."
  (interactive)
  (luyangliuable/eat-send-C-c)
  (eat-reset))


;;; ---------------------------------------------------------------------------
;;; Eat localleader
;;; ---------------------------------------------------------------------------

(after! eat
  (map! :map eat-mode-map
        :localleader

        :desc "Clear terminal"
        "c" #'luyangliuable/eat-interrupt-and-clear

        :desc "Command history"
        "h" #'luyangliuable/eat-command-history

        :desc "Previous command"
        "p" #'luyangliuable/eat-previous-command

        :desc "Next command"
        "n" #'luyangliuable/eat-next-command

        :desc "Kill current command"
        "k" #'luyangliuable/eat-send-C-c

        :desc "Interrupt process (C-c)"
        "i" #'luyangliuable/eat-send-C-c

        :desc "Send EOF (C-d)"
        "d" #'luyangliuable/eat-send-C-d

        :desc "Copy last output"
        "y" #'luyangliuable/shell-copy-last-output

        :desc "Beginning of command"
        "a" #'luyangliuable/eat-beginning-of-command))


;;; ---------------------------------------------------------------------------
;;; Evil-snipe / comma localleader
;;; ---------------------------------------------------------------------------

(after! evil-snipe
  ;; `,' is Doom's localleader in this configuration.
  (define-key evil-normal-state-map (kbd ",") nil)
  (define-key evil-motion-state-map (kbd ",") nil)
  (define-key evil-visual-state-map (kbd ",") nil))


;;; ---------------------------------------------------------------------------
;;; Evil normal-state terminal editing
;;; ---------------------------------------------------------------------------

(after! eat
  ;; Eat installs its terminal-input bindings through
  ;; `eat-semi-char-mode-map'.  Bind our Evil terminal operations there
  ;; instead of treating Eat's rendered buffer as editable text.
  ;;
  ;; Each command below operates on the shell's live input by sending
  ;; keyboard events through Eat.
  (evil-define-key 'normal eat-semi-char-mode-map

    ;; `0' -> shell C-a.
    (kbd "0")
    #'luyangliuable/eat-beginning-of-command

    ;; `$' -> shell C-e.
    (kbd "$")
    #'luyangliuable/eat-end-of-command

    ;; `x' -> terminal Delete.
    (kbd "x")
    #'luyangliuable/eat-delete-char

    ;; `dd' -> C-a followed by C-k.
    (kbd "dd")
    #'luyangliuable/eat-kill-command

    ;; `D' -> shell C-k.
    (kbd "D")
    #'luyangliuable/eat-kill-to-end

    ;; `C' -> shell C-k, then Evil insert state.
    (kbd "C")
    #'luyangliuable/eat-change-to-end))


;;; ---------------------------------------------------------------------------
;;; Project Eat keybindings
;;; ---------------------------------------------------------------------------

(map! :leader

      ;; ---------------------------------------------------------------------
      ;; Existing/reusable project Eat
      ;; ---------------------------------------------------------------------

      :desc "Project Eat"
      "p$." #'luyangliuable/project-eat

      :desc "Split right and open project Eat"
      "p$v"
      (lambda ()
        (interactive)
        (split-window-right)
        (other-window 1)
        (luyangliuable/project-eat))

      :desc "Split below and open project Eat"
      "p$s"
      (lambda ()
        (interactive)
        (split-window-below)
        (other-window 1)
        (luyangliuable/project-eat))

      :desc "Split right and open project Eat (stay)"
      "p$V"
      (lambda ()
        (interactive)
        (split-window-right)
        (other-window 1)
        (luyangliuable/project-eat)
        (other-window -1))

      :desc "Split below and open project Eat (stay)"
      "p$S"
      (lambda ()
        (interactive)
        (split-window-below)
        (other-window 1)
        (luyangliuable/project-eat)
        (other-window -1))


      ;; ---------------------------------------------------------------------
      ;; New project Eat
      ;; ---------------------------------------------------------------------

      :desc "New project Eat"
      "p!." #'luyangliuable/project-eat-new

      :desc "Split right and open new project Eat"
      "p!v"
      (lambda ()
        (interactive)
        (split-window-right)
        (other-window 1)
        (luyangliuable/project-eat-new))

      :desc "Split below and open new project Eat"
      "p!s"
      (lambda ()
        (interactive)
        (split-window-below)
        (other-window 1)
        (luyangliuable/project-eat-new))

      :desc "Split right and open new project Eat (stay)"
      "p!V"
      (lambda ()
        (interactive)
        (split-window-right)
        (other-window 1)
        (luyangliuable/project-eat-new)
        (other-window -1))

      :desc "Split below and open new project Eat (stay)"
      "p!S"
      (lambda ()
        (interactive)
        (split-window-below)
        (other-window 1)
        (luyangliuable/project-eat-new)
        (other-window -1))


      ;; ---------------------------------------------------------------------
      ;; Treemacs / convenience
      ;; ---------------------------------------------------------------------

      :desc "Split below and open Eat here"
      "p|" #'luyangliuable/treemacs-eat-here-horizontal

      :desc "New project Eat (split right)"
      "p@" #'luyangliuable/project-eat-new-split)
