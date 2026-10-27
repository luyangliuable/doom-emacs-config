;;; config/keybindings/shell/vterm.el -*- lexical-binding: t; -*-

;;; ---------------------------------------------------------------------------
;;; Terminal editing helpers
;;; ---------------------------------------------------------------------------

(defun luyangliuable/vterm-beginning-of-command ()
  "Move to the beginning of the current shell command."
  (interactive)
  (vterm-send-C-a))

(defun luyangliuable/vterm-end-of-command ()
  "Move to the end of the current shell command."
  (interactive)
  (vterm-send-C-e))

(defun luyangliuable/vterm-delete-char (&optional count)
  "Delete COUNT characters under the shell cursor."
  (interactive "p")
  (dotimes (_ (max 0 (or count 1)))
    ;; Let the shell perform forward deletion instead of modifying vterm's
    ;; read-only Emacs buffer.
    (vterm-send-key "<delete>")))

(defun luyangliuable/vterm-kill-command ()
  "Kill the entire current shell command."
  (interactive)
  ;; Move to the beginning of shell input and kill to the end.
  (vterm-send-C-a)
  (vterm-send-C-k))

(defun luyangliuable/vterm-kill-to-end ()
  "Kill from the shell cursor to the end of the current command."
  (interactive)
  (vterm-send-C-k))

(defun luyangliuable/vterm-change-command ()
  "Kill the entire shell command and enter Evil insert state."
  (interactive)
  (luyangliuable/vterm-kill-command)
  (evil-insert-state))

(defun luyangliuable/vterm-change-to-end ()
  "Kill to the end of the shell command and enter Evil insert state."
  (interactive)
  (luyangliuable/vterm-kill-to-end)
  (evil-insert-state))

(defun luyangliuable/vterm-interrupt-and-clear ()
  "Interrupt the current process and clear the vterm buffer."
  (interactive)
  (vterm-send-C-c)
  (vterm-clear))


;;; ---------------------------------------------------------------------------
;;; Vterm bindings
;;; ---------------------------------------------------------------------------

(after! vterm
  ;; vterm is a terminal, not an ordinary editable Emacs buffer.
  ;; Send Backspace directly to the terminal.
  (map! :map vterm-mode-map
        :i "<backspace>" #'vterm-send-backspace
        :i "DEL"         #'vterm-send-backspace)

  ;; Doom localleader bindings.
  ;;
  ;; Do not manually reference `doom-localleader-map'. Doom's `map!'
  ;; handles the mode-local localleader prefix for us.
  (map! :map vterm-mode-map
        :localleader
        :desc "Clear shell buffer"      "c" #'luyangliuable/vterm-interrupt-and-clear
        :desc "Command history"         "h" #'vterm-yank-pop
        :desc "Previous command"        "p" #'vterm-send-prior
        :desc "Next command"            "n" #'vterm--self-insert
        :desc "Kill current command"    "k" #'vterm-send-C-c
        :desc "Interrupt process (C-c)" "i" #'vterm-send-C-c
        :desc "Send EOF (C-d)"          "d" #'vterm-send-C-d
        :desc "Copy last output"        "y" #'luyangliuable/shell-copy-last-output
        :desc "Beginning of command"    "a" #'luyangliuable/vterm-beginning-of-command))


;;; ---------------------------------------------------------------------------
;;; Clean up obsolete advice from previous versions
;;; ---------------------------------------------------------------------------

(after! evil-collection-vterm
  ;; Remove the old broad :override advice if it still exists in this Emacs
  ;; session. That version caused operations such as `x' to clear the entire
  ;; shell command.
  (when (fboundp 'luyangliuable/vterm-evil-delete)
    (advice-remove #'evil-collection-vterm-delete
                   #'luyangliuable/vterm-evil-delete)))


;;; ---------------------------------------------------------------------------
;;; dd handling
;;; ---------------------------------------------------------------------------

(defun luyangliuable/vterm-delete-around
    (orig-fn beg end &optional type register yank-handler)
  "Make linewise Evil deletion safe in vterm.

A linewise `evil-collection-vterm-delete' corresponds to `dd'. In that
case, clear the editable shell command using terminal operations.

For non-linewise deletes, preserve evil-collection-vterm's normal
implementation."
  (if (eq type 'line)
      (luyangliuable/vterm-kill-command)
    (funcall orig-fn beg end type register yank-handler)))

(after! evil-collection-vterm
  ;; Do NOT replace `evil-collection-vterm-delete' completely.
  ;; Only intercept its linewise (`dd') case.
  (unless (advice-member-p #'luyangliuable/vterm-delete-around
                           #'evil-collection-vterm-delete)
    (advice-add #'evil-collection-vterm-delete
                :around
                #'luyangliuable/vterm-delete-around)))


;;; ---------------------------------------------------------------------------
;;; Evil normal-state terminal editing
;;; ---------------------------------------------------------------------------

(after! evil-collection-vterm
  ;; evil-collection-vterm installs its normal-state bindings in an Evil
  ;; auxiliary map. Modify that map directly for terminal-specific commands.
  (let ((map (evil-get-auxiliary-keymap vterm-mode-map 'normal t)))

    ;; -----------------------------------------------------------------------
    ;; Movement
    ;; -----------------------------------------------------------------------

    ;; `0' -> beginning of editable shell command.
    ;;
    ;; This sends C-a to the shell instead of moving to column zero of the
    ;; rendered terminal line, which includes the prompt.
    (define-key map (kbd "0")
                #'luyangliuable/vterm-beginning-of-command)

    ;; `$' -> end of editable shell command.
    (define-key map (kbd "$")
                #'luyangliuable/vterm-end-of-command)


    ;; -----------------------------------------------------------------------
    ;; Character deletion
    ;; -----------------------------------------------------------------------

    ;; `x' -> delete the character under the shell cursor.
    ;;
    ;; Send Delete directly to the terminal instead of modifying vterm's
    ;; read-only Emacs buffer.
    (define-key map (kbd "x")
                #'luyangliuable/vterm-delete-char)


    ;; -----------------------------------------------------------------------
    ;; Delete/change to end
    ;; -----------------------------------------------------------------------

    ;; Keep `d' owned by evil-collection-vterm.
    ;;
    ;; `dd' reaches `evil-collection-vterm-delete' with TYPE `line', and our
    ;; around-advice above translates that case into C-a followed by C-k.

    ;; `D' -> kill from shell cursor to end of command.
    (define-key map (kbd "D")
                #'luyangliuable/vterm-kill-to-end)

    ;; `C' -> kill from shell cursor to end and enter insert state.
    (define-key map (kbd "C")
                #'luyangliuable/vterm-change-to-end)))

;;; ---------------------------------------------------------------------------
;;; Project vterm keybindings
;;; ---------------------------------------------------------------------------

(map! :leader
      :desc "Project vterm"
      "p$." #'luyangliuable/project-vterm

      :desc "Split right and open project vterm"
      "p$v"
      (lambda ()
        (interactive)
        (split-window-right)
        (other-window 1)
        (luyangliuable/project-vterm))

      :desc "Split below and open project vterm"
      "p$s"
      (lambda ()
        (interactive)
        (split-window-below)
        (other-window 1)
        (luyangliuable/project-vterm))

      :desc "Split right and open project vterm (stay)"
      "p$V"
      (lambda ()
        (interactive)
        (split-window-right)
        (other-window 1)
        (luyangliuable/project-vterm)
        (other-window -1))

      :desc "Split below and open project vterm (stay)"
      "p$S"
      (lambda ()
        (interactive)
        (split-window-below)
        (other-window 1)
        (luyangliuable/project-vterm)
        (other-window -1))

      :desc "New project vterm"
      "p!." #'luyangliuable/project-vterm-new

      :desc "Split right and open new project vterm"
      "p!v"
      (lambda ()
        (interactive)
        (split-window-right)
        (other-window 1)
        (luyangliuable/project-vterm-new))

      :desc "Split below and open new project vterm"
      "p!s"
      (lambda ()
        (interactive)
        (split-window-below)
        (other-window 1)
        (luyangliuable/project-vterm-new))

      :desc "Split right and open new project vterm (stay)"
      "p!V"
      (lambda ()
        (interactive)
        (split-window-right)
        (other-window 1)
        (luyangliuable/project-vterm-new)
        (other-window -1))

      :desc "Split below and open new project vterm (stay)"
      "p!S"
      (lambda ()
        (interactive)
        (split-window-below)
        (other-window 1)
        (luyangliuable/project-vterm-new)
        (other-window -1))

      :desc "Split below and open vterm here"
      "p|" #'luyangliuable/treemacs-vterm-here-horizontal

      :desc "New project vterm (split right)"
      "p@" #'luyangliuable/project-vterm-new-split)
