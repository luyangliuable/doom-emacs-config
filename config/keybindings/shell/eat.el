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


(defun luyangliuable/eat-send-C-c ()
  "Send C-c to the terminal."
  (interactive)
  (luyangliuable/eat-send-event ?\C-c))


(defun luyangliuable/eat-send-C-d ()
  "Send C-d to the terminal."
  (interactive)
  (luyangliuable/eat-send-event ?\C-d))


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
;;; Evil normal-state editing
;;; ---------------------------------------------------------------------------

;; Edits themselves are translated by `luyangliuable/eat-evil-mode'
;; (config/packages/shell/eat-evil.el); these keys need shell-specific commands.
(after! eat
  (map! :map eat-mode-map
        :n [remap evil-undo]           #'luyangliuable/eat-evil-undo
        :n [remap evil-redo]           #'luyangliuable/eat-evil-redo
        :n [remap evil-paste-pop]      #'luyangliuable/eat-evil-previous-input
        :n [remap evil-paste-pop-next] #'luyangliuable/eat-evil-next-input
        :n "RET"                       #'luyangliuable/eat-evil-send-return))


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
