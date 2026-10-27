;;; config/packages/shell/eat-evil.el -*- lexical-binding: t; -*-
;; Evil editing for Eat terminals.
;;
;; Eat draws the terminal into the buffer, so editing that text directly only
;; corrupts the display: the shell never sees the change.  Instead, every
;; command runs against the buffer as usual, the change it made to the shell
;; command line is replayed as line-editor keystrokes, and the buffer is
;; restored from undo.  Operators, text objects, counts, registers, `.',
;; macros, surround, case changes and ex commands therefore all work without
;; being reimplemented one by one.

(require 'cl-lib)
(require 'subr-x)

(defvar eat-terminal)
(defvar eat--line-mode)
(defvar eat--pending-output-chunks)
(defvar eat--shell-prompt-begin)
(defvar eat-term-name)
(defvar eat-term-terminfo-directory)
(defvar evil-state)
(defvar evil-this-type)
(declare-function eat-term-display-cursor "eat")
(declare-function eat-term-input-event "eat")
(declare-function eat-term-send-string "eat")
(declare-function eat-term-send-string-as-yank "eat")
(declare-function eat-term-parameter "eat")
(declare-function eat-term-size "eat")
(declare-function eat-term-in-alternative-display-p "eat")
(declare-function eat--process-output-queue "eat")
(declare-function evil-adjust-cursor "evil-common")
(declare-function evil-get-register "evil-common")
(declare-function evil-normal-state-p "evil-states")
(declare-function undo-tree-mode "undo-tree")


;;; ---------------------------------------------------------------------------
;;; Settings
;;; ---------------------------------------------------------------------------

(defvar luyangliuable/eat-evil-prompt-regexp "^[^\n]*?[#$%>❯»] "
  "Regexp matching the shell prompt when Eat shell integration is off.")

(defvar luyangliuable/eat-evil-detect-rprompt t
  "Non-nil means right-aligned prompt text (zsh RPROMPT) is not command input.")

(defvar luyangliuable/eat-evil-sync-timeout 0.3
  "Maximum seconds to wait for the shell to redraw after sending keys.")

(defvar luyangliuable/eat-evil-history-limit 200
  "Maximum number of command line edits remembered for `u' and `C-r'.")

;; Emacs-style line editor keys; these work in zsh, bash and most REPLs.
(defvar luyangliuable/eat-evil-backward-char-key ?\C-b)
(defvar luyangliuable/eat-evil-forward-char-key ?\C-f)
(defvar luyangliuable/eat-evil-backspace-key ?\C-?)
(defvar luyangliuable/eat-evil-shell-undo-key ?\C-_
  "Key sent to the shell when its command line changed outside Evil.")

(defvar luyangliuable/eat-evil-overwrite-keys "\C-x\C-o"
  "Keys toggling the shell's overwrite mode, used by Evil replace state.
This is zsh's default binding; set to nil for shells without one.")

(defvar luyangliuable/eat-evil-passthrough-command-regexp
  "\\`\\(?:eat-\\|eat--\\|evil-collection-eat-\\|luyangliuable/eat-\\)"
  "Commands matching this regexp drive the terminal themselves.")

(defvar luyangliuable/eat-evil-paste-commands
  '(evil-paste-after evil-paste-before
    evil-paste-after-cursor-after evil-paste-before-cursor-after
    evil-visual-paste evil-paste-from-register
    yank yank-pop)
  "Commands whose inserted newlines are sent to the shell.
Newlines from any other command (such as `o' or `cc') are dropped because
the command line is a single logical line.")


;;; ---------------------------------------------------------------------------
;;; State
;;; ---------------------------------------------------------------------------

(defvar luyangliuable/eat-evil--pending nil
  "Plist describing the Eat buffer command in progress.")

(defvar-local luyangliuable/eat-evil--last-state nil
  "Evil state at the end of the previous command.")

(defvar-local luyangliuable/eat-evil--last-input-time 0
  "When input was last sent to the shell, as a `float-time'.")

(defvar-local luyangliuable/eat-evil--hold-output nil
  "Non-nil while a command runs, so Eat redraws cannot shift undo entries.")

(defvar-local luyangliuable/eat-evil--undo-stack nil
  "Command line edits as (BEFORE . AFTER), newest first.")

(defvar-local luyangliuable/eat-evil--redo-stack nil
  "Undone command line edits as (BEFORE . AFTER), newest first.")

(defvar-local luyangliuable/eat-evil--insert-origin nil
  "Command line text when the current insert session started.")

(defvar-local luyangliuable/eat-evil--prompt nil
  "Marker at the start of the command line the edit history belongs to.")

(defvar-local luyangliuable/eat-evil--terminfo-ok t
  "Nil when the shell cannot read this terminal's terminfo.
The shell then redraws its command line in a degraded way that no longer
matches the screen, so edits are refused instead of sent to the wrong place.")

(defvar luyangliuable/eat-evil--terminfo-cache (make-hash-table :test 'equal)
  "Whether each (TERM . DIRECTORY) terminfo entry is readable.")

(defvar-local luyangliuable/eat-evil--known-line nil
  "Command line text last sent to or read from the shell.
Used to tell trailing spaces of the command apart from the gap before
RPROMPT, which look the same on screen.")


;;; ---------------------------------------------------------------------------
;;; Reading the command line
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil--padding-p (pos)
  "Return non-nil if the character at POS is Eat display padding.
Eat pads wide characters with invisible spaces and wraps long lines with
newlines; neither exists in the shell's command line."
  (or (get-text-property pos 'eat--t-invisible-space)
      (get-text-property pos 'eat--t-wrap-line)))

(defun luyangliuable/eat-evil--text (beg end)
  "Return the shell text between BEG and END without Eat display padding."
  (let ((chars nil))
    (while (< beg end)
      (unless (luyangliuable/eat-evil--padding-p beg)
        (push (char-after beg) chars))
      (setq beg (1+ beg)))
    (concat (nreverse chars))))

(defun luyangliuable/eat-evil--line-beginning (pos)
  "Return the start of the logical line at POS, joining wrapped lines."
  (save-excursion
    (goto-char pos)
    (forward-line 0)
    (while (and (> (point) (point-min))
                (get-text-property (1- (point)) 'eat--t-wrap-line))
      (forward-line -1))
    (point)))

(defun luyangliuable/eat-evil--line-end (pos)
  "Return the end of the logical line at POS, joining wrapped lines."
  (save-excursion
    (goto-char pos)
    (let ((inhibit-field-text-motion t))
      (end-of-line)
      (while (and (< (point) (point-max))
                  (get-text-property (point) 'eat--t-wrap-line))
        (forward-char)
        (end-of-line)))
    (point)))

(defun luyangliuable/eat-evil--prompt-end (line-start cursor)
  "Return where input starts after the shell-integration prompt, or nil.
Only the logical line from LINE-START to CURSOR is searched."
  (let ((pos cursor)
        (found nil))
    (while (and (not found) (> pos line-start))
      (if (get-text-property (1- pos) 'eat--shell-prompt-end)
          (setq found pos)
        (setq pos (1- pos))))
    found))

(defun luyangliuable/eat-evil--prompt-regexp-end (line-start cursor)
  "Return where input starts after a prompt matched by regexp, or nil."
  (save-excursion
    (goto-char line-start)
    (when (and (looking-at luyangliuable/eat-evil-prompt-regexp)
               (<= (match-end 0) cursor))
      (match-end 0))))

(defun luyangliuable/eat-evil--rprompt-start (start end)
  "Return where right-aligned prompt text begins between START and END.
zsh draws RPROMPT flush with the right margin after a gap of spaces, so a
line reaching the margin is split at its last run of two or more visible
spaces.  Return nil when there is no such text."
  (let ((width (car (eat-term-size eat-terminal)))
        (line-start (save-excursion
                      (goto-char start)
                      (forward-line 0)
                      (point))))
    (when (>= (- end line-start) (- width 2))
      (let ((pos end)
            (run 0)
            (found nil))
        (while (and (not found) (> pos start))
          (setq pos (1- pos))
          (if (and (eq (char-after pos) ?\s)
                   (not (get-text-property pos 'eat--t-invisible-space)))
              (setq run (1+ run))
            (when (>= run 2)
              (setq found (1+ pos)))
            (setq run 0)))
        (or found (and (>= run 2) start))))))

(defun luyangliuable/eat-evil--known-trailing-spaces (start end limit)
  "Return END moved past spaces that `luyangliuable/eat-evil--known-line' has.
START is where the command line starts; END may not move past LIMIT."
  (let* ((known luyangliuable/eat-evil--known-line)
         (text (and known (luyangliuable/eat-evil--text start end)))
         (extra (and text
                     (string-prefix-p text known)
                     (substring known (length text)))))
    (if (and extra
             (string-match-p "\\` +\\'" extra)
             (<= (+ end (length extra)) limit)
             (equal (buffer-substring-no-properties end (+ end (length extra)))
                    extra))
        (+ end (length extra))
      end)))

(defun luyangliuable/eat-evil--blank-p (beg end)
  "Return non-nil if BEG to END holds only spaces and line breaks."
  (save-excursion
    (goto-char beg)
    (skip-chars-forward " \n" end)
    (>= (point) end)))

(defun luyangliuable/eat-evil--input-end (start cursor)
  "Return the end of the command line that starts at START.
CURSOR is the shell cursor, which is always inside the command line.
Blank cells after the command look the same as typed spaces, so they only
count when the cursor is past them or `luyangliuable/eat-evil--known-line'
has them."
  (let* ((line-end (luyangliuable/eat-evil--line-end cursor))
         (first-line-end (save-excursion
                           (goto-char start)
                           (let ((inhibit-field-text-motion t))
                             (end-of-line))
                           (point)))
         (limit line-end))
    ;; Eat keeps the wrap mark of a row that once overflowed, so a short
    ;; command can be followed by blank continuation rows.
    (when (and (<= cursor first-line-end)
               (luyangliuable/eat-evil--blank-p first-line-end line-end))
      (setq limit first-line-end))
    ;; zsh drops RPROMPT once the command wraps, so only check single lines.
    (when (and luyangliuable/eat-evil-detect-rprompt (= limit first-line-end))
      (when-let ((rprompt (luyangliuable/eat-evil--rprompt-start start limit)))
        ;; Typed trailing spaces merge with the gap, so stop before its text.
        (setq limit (save-excursion
                      (goto-char rprompt)
                      (skip-chars-forward " " limit)
                      (1- (point))))))
    (let ((end (save-excursion
                 (goto-char limit)
                 (skip-chars-backward " \n" (max start cursor))
                 (point))))
      (luyangliuable/eat-evil--known-trailing-spaces start end limit))))

(defun luyangliuable/eat-evil--terminfo-readable-p (term directory)
  "Return non-nil if the system ncurses can read TERM from DIRECTORY."
  (let ((key (cons term directory)))
    (pcase (gethash key luyangliuable/eat-evil--terminfo-cache 'unknown)
      ('unknown
       (let* ((tput (let ((system "/usr/bin/tput"))
                      (if (file-executable-p system) system (executable-find "tput"))))
              (readable (or (null tput)
                            (let ((process-environment
                                   (cons (concat "TERMINFO=" directory) process-environment)))
                              (zerop (call-process tput nil nil nil "-T" term "colors"))))))
         (puthash key readable luyangliuable/eat-evil--terminfo-cache)
         readable))
      (cached cached))))

(defun luyangliuable/eat-evil--check-terminfo ()
  "Refuse edits in this buffer when the shell cannot read its terminfo."
  (let ((term (if (functionp eat-term-name) (funcall eat-term-name) eat-term-name)))
    (setq luyangliuable/eat-evil--terminfo-ok
          (luyangliuable/eat-evil--terminfo-readable-p term eat-term-terminfo-directory))
    (unless luyangliuable/eat-evil--terminfo-ok
      (message "Eat: the shell cannot read terminfo for %s in %s; Evil editing is off"
               term eat-term-terminfo-directory))))

(defun luyangliuable/eat-evil--live-p ()
  "Return non-nil when this buffer has an Eat terminal in a key-sending mode."
  (and (bound-and-true-p eat-terminal)
       (not (bound-and-true-p eat--line-mode))))

(defun luyangliuable/eat-evil--input-bounds ()
  "Return (START . END) of the shell command line, or nil.
Return nil when no line editor is on screen, such as when a full-screen
program uses the alternative display."
  (when (and (luyangliuable/eat-evil--live-p)
             luyangliuable/eat-evil--terminfo-ok
             (not (eat-term-in-alternative-display-p eat-terminal)))
    (let* ((cursor (marker-position (eat-term-display-cursor eat-terminal)))
           (line-start (luyangliuable/eat-evil--line-beginning cursor))
           (start (or (luyangliuable/eat-evil--prompt-end line-start cursor)
                      (luyangliuable/eat-evil--prompt-regexp-end line-start cursor)
                      line-start)))
      (cons start (luyangliuable/eat-evil--input-end start cursor)))))

(defun luyangliuable/eat-evil--cursor-index (bounds)
  "Return the shell cursor's index within the command line BOUNDS."
  (let ((cursor (marker-position (eat-term-display-cursor eat-terminal))))
    (length (luyangliuable/eat-evil--text
             (car bounds) (min (max cursor (car bounds)) (cdr bounds))))))

(defun luyangliuable/eat-evil--current-bounds ()
  "Return the command line bounds, using the running command's if any.
While a command runs, the display padding is removed and the text may be
edited, so the bounds saved before it started are tracked with markers."
  (let ((pending luyangliuable/eat-evil--pending))
    (if (and pending (eq (plist-get pending :buffer) (current-buffer)))
        (when-let ((start (plist-get pending :start)))
          (cons (marker-position start)
                (marker-position (plist-get pending :end))))
      (luyangliuable/eat-evil--input-bounds))))

(defun luyangliuable/eat-evil--command-line-at-point ()
  "Return the command line bounds when point is on its logical line."
  (when (bound-and-true-p luyangliuable/eat-evil-mode)
    (when-let ((bounds (luyangliuable/eat-evil--current-bounds)))
      (when (and (>= (point) (luyangliuable/eat-evil--line-beginning (car bounds)))
                 (<= (point) (luyangliuable/eat-evil--line-end (car bounds))))
        bounds))))


;;; ---------------------------------------------------------------------------
;;; Restoring Eat's display state
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil--terminal-markers ()
  "Return (MARKER . POSITION) for every marker Eat keeps in this buffer.
Undo restores text but not markers sitting at the edge of replaced text,
such as Eat's cursor, so they are saved before a command edits anything."
  (let ((seen (make-hash-table :test 'eq))
        (found nil))
    (cl-labels ((walk (object depth)
                  (cond
                   ((markerp object)
                    (when (eq (marker-buffer object) (current-buffer))
                      (push (cons object (marker-position object)) found)))
                   ((or (> depth 4) (gethash object seen)))
                   ((or (recordp object) (vectorp object))
                    (puthash object t seen)
                    (dotimes (i (length object))
                      (walk (aref object i) (1+ depth))))
                   ((hash-table-p object)
                    (puthash object t seen)
                    (maphash (lambda (_key value) (walk value (1+ depth))) object))
                   ((consp object)
                    (puthash object t seen)
                    (walk (car object) (1+ depth))
                    (walk (cdr object) depth)))))
      (walk eat-terminal 0)
      (walk (bound-and-true-p eat--shell-prompt-begin) 0))
    found))

(defun luyangliuable/eat-evil--snapshot (&rest _)
  "Save Eat's markers and overlays before the first change of a command."
  (let ((pending luyangliuable/eat-evil--pending))
    (when (and pending
               (eq (plist-get pending :buffer) (current-buffer))
               (not (plist-member pending :markers)))
      (setq luyangliuable/eat-evil--pending
            (append pending
                    (list :markers (luyangliuable/eat-evil--terminal-markers)
                          :overlays (mapcar (lambda (overlay)
                                              (list overlay
                                                    (overlay-start overlay)
                                                    (overlay-end overlay)))
                                            (overlays-in (point-min) (point-max)))))))))

(defun luyangliuable/eat-evil--restore-snapshot (pending)
  "Put back the markers and overlays saved in PENDING."
  (pcase-dolist (`(,marker . ,position) (plist-get pending :markers))
    (when (eq (marker-buffer marker) (current-buffer))
      (set-marker marker position)))
  (pcase-dolist (`(,overlay ,start ,end) (plist-get pending :overlays))
    (when (eq (overlay-buffer overlay) (current-buffer))
      (move-overlay overlay start end))))


;;; ---------------------------------------------------------------------------
;;; Talking to the shell
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil--process-pending-output ()
  "Render output Eat has received but not drawn yet."
  (when (and (bound-and-true-p eat--pending-output-chunks)
             (fboundp 'eat--process-output-queue))
    (eat--process-output-queue (current-buffer))))

(defun luyangliuable/eat-evil--wait-for-output ()
  "Give the shell a moment to redraw after recent input, then render it.
Nothing is waited for when the last input is older than
`luyangliuable/eat-evil-sync-timeout', so normal typing never stalls."
  (let ((process (ignore-errors (eat-term-parameter eat-terminal 'eat--process)))
        (deadline (+ luyangliuable/eat-evil--last-input-time
                     luyangliuable/eat-evil-sync-timeout))
        (wait 0.08))
    (when (process-live-p process)
      (while (and (< (float-time) deadline)
                  (accept-process-output process wait nil t))
        ;; Keep reading until the shell has been quiet for a moment.
        (setq wait 0.02))))
  (luyangliuable/eat-evil--process-pending-output))

(defun luyangliuable/eat-evil--follow-cursor ()
  "Wait for the shell to redraw and put point on its cursor."
  (luyangliuable/eat-evil--wait-for-output)
  (goto-char (eat-term-display-cursor eat-terminal))
  (when (and (fboundp 'evil-normal-state-p) (evil-normal-state-p))
    (evil-adjust-cursor)))

(defun luyangliuable/eat-evil--send-move (from to)
  "Move the shell cursor from index FROM to index TO."
  (let ((delta (- to from)))
    (cond
     ((> delta 0)
      (eat-term-input-event eat-terminal delta luyangliuable/eat-evil-forward-char-key))
     ((< delta 0)
      (eat-term-input-event eat-terminal (- delta) luyangliuable/eat-evil-backward-char-key)))))

(defun luyangliuable/eat-evil--send-text (text)
  "Type TEXT into the shell.
Text with control characters goes through bracketed paste, so a newline or
tab is inserted literally instead of running the command or completing."
  (unless (string-empty-p text)
    (if (string-match-p "[[:cntrl:]]" text)
        (eat-term-send-string-as-yank eat-terminal (list text))
      (eat-term-send-string eat-terminal text))))

(defun luyangliuable/eat-evil--common-prefix (a b)
  "Return the length of the common prefix of strings A and B."
  (let ((limit (min (length a) (length b)))
        (i 0))
    (while (and (< i limit) (eq (aref a i) (aref b i)))
      (setq i (1+ i)))
    i))

(defun luyangliuable/eat-evil--replay (old new from target)
  "Turn the shell command line OLD into NEW with keystrokes.
FROM is the shell cursor's index in OLD.  Afterwards the cursor is moved to
index TARGET in NEW."
  (let* ((prefix (luyangliuable/eat-evil--common-prefix old new))
         (limit (- (min (length old) (length new)) prefix))
         (suffix 0))
    (while (and (< suffix limit)
                (eq (aref old (- (length old) suffix 1))
                    (aref new (- (length new) suffix 1))))
      (setq suffix (1+ suffix)))
    (let ((deleted-end (- (length old) suffix))
          (inserted (substring new prefix (- (length new) suffix)))
          (pos from))
      (when (or (> deleted-end prefix) (not (string-empty-p inserted)))
        ;; Backspace is used rather than Delete: it is bound in every line
        ;; editor and cannot send EOF the way C-d can.
        (luyangliuable/eat-evil--send-move pos deleted-end)
        (when (> deleted-end prefix)
          (eat-term-input-event eat-terminal (- deleted-end prefix)
                                luyangliuable/eat-evil-backspace-key))
        (luyangliuable/eat-evil--send-text inserted)
        (setq pos (+ prefix (length inserted))))
      (luyangliuable/eat-evil--send-move pos (min (max target 0) (length new))))))


;;; ---------------------------------------------------------------------------
;;; Edit history
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil--same-prompt-p (bounds)
  "Return non-nil if BOUNDS is the command line the edit history belongs to.
Otherwise forget the history and start tracking BOUNDS."
  (let ((prompt luyangliuable/eat-evil--prompt))
    (if (and (markerp prompt)
             (eq (marker-buffer prompt) (current-buffer))
             (= prompt (car bounds)))
        t
      (setq luyangliuable/eat-evil--undo-stack nil
            luyangliuable/eat-evil--redo-stack nil
            luyangliuable/eat-evil--insert-origin nil
            luyangliuable/eat-evil--known-line nil)
      (when (markerp prompt)
        (set-marker prompt nil))
      (setq luyangliuable/eat-evil--prompt (copy-marker (car bounds)))
      nil)))

(defun luyangliuable/eat-evil--remember (before after)
  "Record that the command line changed from BEFORE to AFTER."
  (unless (equal before after)
    (push (cons before after) luyangliuable/eat-evil--undo-stack)
    (setq luyangliuable/eat-evil--redo-stack nil)
    (when (> (length luyangliuable/eat-evil--undo-stack)
             luyangliuable/eat-evil-history-limit)
      (setcdr (nthcdr (1- luyangliuable/eat-evil-history-limit)
                      luyangliuable/eat-evil--undo-stack)
              nil))))

(defun luyangliuable/eat-evil--history-step (count undo)
  "Undo (when UNDO is non-nil) or redo COUNT command line edits."
  (unless (luyangliuable/eat-evil--live-p)
    (user-error "No running terminal"))
  (luyangliuable/eat-evil--wait-for-output)
  (catch 'done
    (dotimes (_ (max 1 count))
      (let ((bounds (luyangliuable/eat-evil--input-bounds)))
        (unless bounds
          (user-error "Not at a shell prompt"))
        (luyangliuable/eat-evil--same-prompt-p bounds)
        (let* ((entry (car (if undo
                               luyangliuable/eat-evil--undo-stack
                             luyangliuable/eat-evil--redo-stack)))
               (current (luyangliuable/eat-evil--text (car bounds) (cdr bounds)))
               (expected (and entry (if undo (cdr entry) (car entry))))
               (target (and entry (if undo (car entry) (cdr entry)))))
          (cond
           ((and entry (equal current expected))
            (if undo
                (push (pop luyangliuable/eat-evil--undo-stack)
                      luyangliuable/eat-evil--redo-stack)
              (push (pop luyangliuable/eat-evil--redo-stack)
                    luyangliuable/eat-evil--undo-stack))
            ;; Like Vim, leave the cursor where the change starts.
            (luyangliuable/eat-evil--replay
             current target
             (luyangliuable/eat-evil--cursor-index bounds)
             (luyangliuable/eat-evil--common-prefix current target))
            (setq luyangliuable/eat-evil--known-line target))
           ((and undo entry)
            ;; The shell changed the line on its own (history, completion),
            ;; so the remembered edits no longer apply: let it undo instead.
            (setq luyangliuable/eat-evil--undo-stack nil
                  luyangliuable/eat-evil--redo-stack nil
                  luyangliuable/eat-evil--known-line nil)
            (eat-term-input-event eat-terminal 1 luyangliuable/eat-evil-shell-undo-key))
           (t
            (message (if undo "Already at oldest change" "Already at newest change"))
            (throw 'done nil)))
          (luyangliuable/eat-evil--follow-cursor))))))


;;; ---------------------------------------------------------------------------
;;; Command interception
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil--passthrough-p (command)
  "Return non-nil if COMMAND drives the terminal itself."
  (and (symbolp command)
       command
       (string-match-p luyangliuable/eat-evil-passthrough-command-regexp
                       (symbol-name command))))

(defun luyangliuable/eat-evil--insert-state-p (state)
  "Return non-nil if Evil STATE sends typed keys to the shell."
  (memq state '(insert replace)))

(defun luyangliuable/eat-evil--pre-command ()
  "Let the next command edit the terminal buffer and record what it does."
  (condition-case-unless-debug err
      (luyangliuable/eat-evil--start-command)
    (error (message "Eat Evil: %s" (error-message-string err)))))

(defun luyangliuable/eat-evil--start-command ()
  "Prepare the current Eat buffer for the command about to run."
  (when (and (not luyangliuable/eat-evil--pending)
             (bound-and-true-p luyangliuable/eat-evil-mode)
             (luyangliuable/eat-evil--live-p)
             (not (luyangliuable/eat-evil--passthrough-p this-command)))
    (luyangliuable/eat-evil--wait-for-output)
    (let ((bounds (luyangliuable/eat-evil--input-bounds)))
      (setq luyangliuable/eat-evil--pending
            (list :buffer (current-buffer)
                  :state (bound-and-true-p evil-state)
                  :start (and bounds (copy-marker (car bounds)))
                  :end (and bounds (copy-marker (cdr bounds) t))
                  :undo-list buffer-undo-list
                  :inhibit-local (local-variable-p 'inhibit-read-only)
                  :inhibit inhibit-read-only)))
    (setq buffer-undo-list nil
          luyangliuable/eat-evil--hold-output t)
    (setq-local inhibit-read-only t)
    (add-hook 'before-change-functions #'luyangliuable/eat-evil--snapshot nil t)
    (let ((start (plist-get luyangliuable/eat-evil--pending :start)))
      (when start
        (luyangliuable/eat-evil--snapshot)
        (let ((inhibit-modification-hooks t))
          (luyangliuable/eat-evil--remove-padding
           start (plist-get luyangliuable/eat-evil--pending :end)))))
    (setq luyangliuable/eat-evil--pending
          (append luyangliuable/eat-evil--pending
                  (list :base-undo-list buffer-undo-list)))))

(defun luyangliuable/eat-evil--remove-padding (start end)
  "Delete Eat display padding between START and END for one command.
Without it, Evil sees a wrapped command as several lines and a wide
character as a space plus the character.  The finished command's undo
puts the padding back."
  (let ((pos (1- end)))
    (while (>= pos start)
      (when (luyangliuable/eat-evil--padding-p pos)
        (delete-region pos (1+ pos)))
      (setq pos (1- pos)))))

(defun luyangliuable/eat-evil--post-command ()
  "Replay the finished command's edit to the shell and restore the buffer.
Errors are reported rather than raised: Emacs drops a failing
`post-command-hook' function, which would leave the terminal frozen."
  (let ((pending luyangliuable/eat-evil--pending))
    (when pending
      (setq luyangliuable/eat-evil--pending nil)
      (let ((buffer (plist-get pending :buffer)))
        (when (buffer-live-p buffer)
          (with-current-buffer buffer
            (condition-case-unless-debug err
                (luyangliuable/eat-evil--finish pending)
              (error (message "Eat Evil: %s" (error-message-string err)))))))))
  (when (and (bound-and-true-p luyangliuable/eat-evil-mode)
             (luyangliuable/eat-evil--live-p))
    (condition-case-unless-debug err
        (luyangliuable/eat-evil--track-insert-session)
      (error (message "Eat Evil: %s" (error-message-string err))))))

(defun luyangliuable/eat-evil--edit-p (entries)
  "Return non-nil if undo ENTRIES include a text insertion or deletion."
  (cl-some (lambda (entry)
             (and (consp entry)
                  (or (integerp (car entry)) (stringp (car entry)))))
           entries))

(defun luyangliuable/eat-evil--finish (pending)
  "Finish the command described by PENDING in the current Eat buffer."
  (let* ((undo-list (and (listp buffer-undo-list) buffer-undo-list))
         (entries (delq nil (copy-sequence undo-list)))
         (edited (luyangliuable/eat-evil--edit-p
                  (cl-ldiff undo-list (plist-get pending :base-undo-list))))
         (passthrough (luyangliuable/eat-evil--passthrough-p this-command))
         (start (plist-get pending :start))
         (end (plist-get pending :end))
         (new nil)
         (new-index nil))
    (when (and start (not passthrough))
      (let* ((keep-newlines (memq this-command luyangliuable/eat-evil-paste-commands))
             (clean (lambda (text)
                      (if keep-newlines text (string-replace "\n" "" text))))
             (inside (<= start (point) end))
             (before-point (funcall clean (luyangliuable/eat-evil--text
                                           start (min (max (point) start) end)))))
        (setq new (funcall clean (luyangliuable/eat-evil--text start end)))
        (setq new-index
              (pcase this-command
                ('evil-insert-line 0)
                ('evil-append-line (length new))
                (_ (and inside (length before-point)))))))
    (when start
      (set-marker start nil)
      (set-marker end nil))
    (unwind-protect
        ;; Put the buffer back exactly as Eat drew it.  Undo moves point to
        ;; each change, so keep it where the command left it.
        (when (and entries (not passthrough))
          (let ((inhibit-read-only t)
                (inhibit-modification-hooks t)
                (buffer-undo-list t)
                (point (point-marker)))
            (primitive-undo 1 entries)
            (goto-char point)
            (set-marker point nil))
          (luyangliuable/eat-evil--restore-snapshot pending))
      (remove-hook 'before-change-functions #'luyangliuable/eat-evil--snapshot t)
      (setq buffer-undo-list (plist-get pending :undo-list))
      (if (plist-get pending :inhibit-local)
          (setq inhibit-read-only (plist-get pending :inhibit))
        (kill-local-variable 'inhibit-read-only))
      (setq luyangliuable/eat-evil--hold-output nil)
      (luyangliuable/eat-evil--process-pending-output))
    (unless passthrough
      (luyangliuable/eat-evil--apply (plist-get pending :state)
                                     (and edited new) new-index edited))))

(defun luyangliuable/eat-evil--apply (state-before new new-index edited)
  "Send the command line edit NEW to the shell.
STATE-BEFORE is the Evil state before the command.  NEW-INDEX is where point
ended up in NEW, or nil if point left the command line.  EDITED is non-nil
if the command changed any buffer text."
  (let* ((bounds (luyangliuable/eat-evil--input-bounds))
         (state (bound-and-true-p evil-state))
         (entered-insert (and (luyangliuable/eat-evil--insert-state-p state)
                              (not (luyangliuable/eat-evil--insert-state-p state-before)))))
    (if (not bounds)
        (when edited
          (message (cond
                    ((not (luyangliuable/eat-evil--live-p))
                     "The terminal is read-only")
                    ((not luyangliuable/eat-evil--terminfo-ok)
                     "Eat terminfo is unreadable, so Evil editing is off")
                    (t
                     "Use insert state to type into the running program"))))
      (luyangliuable/eat-evil--same-prompt-p bounds)
      (let* ((old (luyangliuable/eat-evil--text (car bounds) (cdr bounds)))
             (cursor (luyangliuable/eat-evil--cursor-index bounds))
             (changed (and new (not (equal old new)))))
        (cond
         (changed
          (luyangliuable/eat-evil--replay old new cursor (or new-index (length new)))
          (setq luyangliuable/eat-evil--known-line new))
         ((and entered-insert new-index)
          (luyangliuable/eat-evil--send-move cursor (min new-index (length old)))))
        (cond
         (entered-insert
          (setq luyangliuable/eat-evil--insert-origin old))
         (changed
          (luyangliuable/eat-evil--remember old new))
         (edited
          (message "Only the shell command line can be edited")))
        (when (or changed entered-insert)
          (luyangliuable/eat-evil--follow-cursor))))))

(defun luyangliuable/eat-evil--track-insert-session ()
  "Remember an insert session as a single edit once it ends, like Vim."
  (let ((previous luyangliuable/eat-evil--last-state)
        (state (bound-and-true-p evil-state)))
    (setq luyangliuable/eat-evil--last-state state)
    (when (and luyangliuable/eat-evil--insert-origin
               (luyangliuable/eat-evil--insert-state-p previous)
               (not (luyangliuable/eat-evil--insert-state-p state)))
      (let ((origin luyangliuable/eat-evil--insert-origin))
        (setq luyangliuable/eat-evil--insert-origin nil)
        (luyangliuable/eat-evil--wait-for-output)
        (let ((bounds (luyangliuable/eat-evil--input-bounds)))
          (when (and bounds (luyangliuable/eat-evil--same-prompt-p bounds))
            (let ((text (luyangliuable/eat-evil--text (car bounds) (cdr bounds))))
              (setq luyangliuable/eat-evil--known-line text)
              (luyangliuable/eat-evil--remember origin text))))))))


;;; ---------------------------------------------------------------------------
;;; Advice
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil--hold-output-a (fn buffer)
  "Call FN to draw BUFFER's output unless a command is editing BUFFER.
Drawing mid-command would shift the positions recorded in undo entries.
Output still flows while the minibuffer is open, since that can take long."
  (unless (and (buffer-live-p buffer)
               (buffer-local-value 'luyangliuable/eat-evil--hold-output buffer)
               (not (active-minibuffer-window)))
    (funcall fn buffer)))

(defun luyangliuable/eat-evil--note-input-a (&rest _)
  "Note that the shell has input it may not have echoed yet."
  (when (derived-mode-p 'eat-mode)
    (setq luyangliuable/eat-evil--last-input-time (float-time))))

(defun luyangliuable/eat-evil--beginning-of-line-a (fn &rest args)
  "Make `0' go to the start of the command line instead of the prompt."
  (if-let ((bounds (luyangliuable/eat-evil--command-line-at-point)))
      (goto-char (car bounds))
    (apply fn args)))

(defun luyangliuable/eat-evil--first-non-blank-a (fn &rest args)
  "Make `^' and `I' skip the prompt."
  (if-let ((bounds (luyangliuable/eat-evil--command-line-at-point)))
      (progn
        (goto-char (car bounds))
        (skip-chars-forward " \t" (cdr bounds)))
    (apply fn args)))

(defun luyangliuable/eat-evil--end-of-line-a (fn &optional count &rest args)
  "Make `$' stop at the end of the command line, before any RPROMPT."
  (if-let ((bounds (and (memq count '(nil 1))
                        (luyangliuable/eat-evil--command-line-at-point))))
      (progn
        (goto-char (cdr bounds))
        (if (= (car bounds) (cdr bounds))
            ;; Like Evil at an empty line: nothing for `d$' to take.
            (setq evil-this-type 'exclusive)
          (backward-char)))
    (apply fn count args)))

(defun luyangliuable/eat-evil--linewise-range-a (args)
  "Limit a linewise operator range in ARGS on the command line to the command.
`dd', `cc' and `yy' then work on the command alone, without the prompt or
RPROMPT, so a yanked command can be pasted back as it was typed."
  (let ((beg (nth 0 args))
        (end (nth 1 args))
        (bounds (and (eq (nth 2 args) 'line)
                     (luyangliuable/eat-evil--command-line-at-point))))
    (if (and bounds
             (integer-or-marker-p beg)
             (integer-or-marker-p end)
             (<= beg (car bounds))
             (>= end (cdr bounds)))
        (let ((line-end (luyangliuable/eat-evil--line-end (car bounds))))
          (if (> end (1+ line-end))
              ;; The range spans other lines too; leave it to Evil.
              args
            (append (list (car bounds) (cdr bounds)) (nthcdr 2 args))))
      args)))

(defun luyangliuable/eat-evil--paste (after fn count register args)
  "Paste on the command line even if the register holds whole lines.
Evil pastes linewise text onto a new line, which is not part of the command
line, so paste it at point instead (after it when AFTER is non-nil).
Pasting with point outside the command line goes to the shell cursor.
FN, COUNT, REGISTER and ARGS are the advised paste command and its arguments."
  (let ((bounds (and luyangliuable/eat-evil--pending
                     (luyangliuable/eat-evil--current-bounds))))
    (if (not bounds)
        (apply fn count register args)
      (let* ((text (if register
                       (evil-get-register register)
                     (current-kill 0)))
             (linewise (eq (car-safe (get-text-property 0 'yank-handler text))
                           'evil-yank-line-handler))
             (inside (<= (car bounds) (point) (cdr bounds))))
        (cond
         ((and inside (not linewise))
          (apply fn count register args))
         (t
          (unless inside
            (goto-char (eat-term-display-cursor eat-terminal)))
          (when (and inside after (< (point) (cdr bounds)))
            (forward-char))
          (let ((text (string-remove-suffix "\n" (substring-no-properties text))))
            (dotimes (_ (max 1 (prefix-numeric-value count)))
              (insert text)))
          (unless (bobp)
            (backward-char))))))))

(defun luyangliuable/eat-evil--paste-after-a (fn count &optional register &rest args)
  "Advice for `evil-paste-after'; see `luyangliuable/eat-evil--paste'."
  (luyangliuable/eat-evil--paste t fn count register args))

(defun luyangliuable/eat-evil--paste-before-a (fn count &optional register &rest args)
  "Advice for `evil-paste-before'; see `luyangliuable/eat-evil--paste'."
  (luyangliuable/eat-evil--paste nil fn count register args))

(with-eval-after-load 'eat
  (advice-add 'eat--process-output-queue :around #'luyangliuable/eat-evil--hold-output-a)
  (advice-add 'eat-term-input-event :after #'luyangliuable/eat-evil--note-input-a)
  (advice-add 'eat-term-send-string :after #'luyangliuable/eat-evil--note-input-a)
  (advice-add 'eat-term-send-string-as-yank :after #'luyangliuable/eat-evil--note-input-a))

(with-eval-after-load 'evil
  (advice-add 'evil-beginning-of-line :around #'luyangliuable/eat-evil--beginning-of-line-a)
  (advice-add 'evil-first-non-blank :around #'luyangliuable/eat-evil--first-non-blank-a)
  (advice-add 'evil-end-of-line :around #'luyangliuable/eat-evil--end-of-line-a)
  (dolist (operator '(evil-delete evil-change evil-yank))
    (advice-add operator :filter-args #'luyangliuable/eat-evil--linewise-range-a))
  (advice-add 'evil-paste-after :around #'luyangliuable/eat-evil--paste-after-a)
  (advice-add 'evil-paste-before :around #'luyangliuable/eat-evil--paste-before-a))

(with-eval-after-load 'undo-tree
  (defvar undo-tree-incompatible-major-modes)
  (add-to-list 'undo-tree-incompatible-major-modes 'eat-mode))

(with-eval-after-load 'evil-escape
  (defvar evil-escape-excluded-major-modes)
  (add-to-list 'evil-escape-excluded-major-modes 'eat-mode))


;;; ---------------------------------------------------------------------------
;;; Commands
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil-undo (count)
  "Undo the last COUNT changes to the shell command line."
  (interactive "p")
  (luyangliuable/eat-evil--history-step count t))

(defun luyangliuable/eat-evil-redo (count)
  "Redo the last COUNT undone changes to the shell command line."
  (interactive "p")
  (luyangliuable/eat-evil--history-step count nil))

(defun luyangliuable/eat-evil--send-key (key)
  "Send KEY to the shell and follow its cursor."
  (unless (luyangliuable/eat-evil--live-p)
    (user-error "No running terminal"))
  (eat-term-input-event eat-terminal 1 key)
  (luyangliuable/eat-evil--follow-cursor))

(defun luyangliuable/eat-evil-send-return ()
  "Run the shell command line."
  (interactive)
  (luyangliuable/eat-evil--send-key ?\C-m))

(defun luyangliuable/eat-evil-previous-input ()
  "Show the previous command from shell history."
  (interactive)
  (luyangliuable/eat-evil--send-key ?\C-p))

(defun luyangliuable/eat-evil-next-input ()
  "Show the next command from shell history."
  (interactive)
  (luyangliuable/eat-evil--send-key ?\C-n))


;;; ---------------------------------------------------------------------------
;;; Replace state
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil--toggle-overwrite ()
  "Toggle the shell's overwrite mode so text typed after `R' replaces text.
Moving the shell cursor to point is left to the post-command replay."
  (when (and luyangliuable/eat-evil-overwrite-keys
             (luyangliuable/eat-evil--input-bounds))
    (eat-term-send-string eat-terminal luyangliuable/eat-evil-overwrite-keys)))


;;; ---------------------------------------------------------------------------
;;; Minor mode
;;; ---------------------------------------------------------------------------

(defun luyangliuable/eat-evil--disable-undo-tree ()
  "Keep `undo-tree-mode' off; it can move undo entries out mid-command."
  (when (bound-and-true-p undo-tree-mode)
    (undo-tree-mode -1)))

(define-minor-mode luyangliuable/eat-evil-mode
  "Send Evil edits of the shell command line to the shell as keystrokes."
  :lighter nil
  (if luyangliuable/eat-evil-mode
      (progn
        (setq luyangliuable/eat-evil--last-state (bound-and-true-p evil-state))
        (luyangliuable/eat-evil--check-terminfo)
        (luyangliuable/eat-evil--disable-undo-tree)
        (add-hook 'undo-tree-mode-hook #'luyangliuable/eat-evil--disable-undo-tree nil t)
        (add-hook 'evil-replace-state-entry-hook
                  #'luyangliuable/eat-evil--toggle-overwrite nil t)
        (add-hook 'evil-replace-state-exit-hook
                  #'luyangliuable/eat-evil--toggle-overwrite nil t))
    (remove-hook 'undo-tree-mode-hook #'luyangliuable/eat-evil--disable-undo-tree t)
    (remove-hook 'evil-replace-state-entry-hook
                 #'luyangliuable/eat-evil--toggle-overwrite t)
    (remove-hook 'evil-replace-state-exit-hook
                 #'luyangliuable/eat-evil--toggle-overwrite t)))

(add-hook 'pre-command-hook #'luyangliuable/eat-evil--pre-command)
(add-hook 'post-command-hook #'luyangliuable/eat-evil--post-command)
(add-hook 'eat-mode-hook #'luyangliuable/eat-evil-mode)

;;; eat-evil.el ends here
