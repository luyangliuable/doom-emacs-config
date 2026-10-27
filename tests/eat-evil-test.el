;;; tests/eat-evil-test.el -*- lexical-binding: t; -*-
;; End-to-end tests for Evil editing in Eat: a real zsh runs in an Eat buffer
;; and key sequences go through the command loop like interactive typing.
;;
;; Run with:
;;   emacs -Q --batch -l ert -l tests/eat-evil-test.el \
;;     -f ert-run-tests-batch-and-exit

(require 'cl-lib)
(require 'ert)

(defconst eat-evil-test--straight
  (expand-file-name "~/.config/emacs/.local/straight/"))

(defconst eat-evil-test--build
  (expand-file-name (format "build-%s/" emacs-version) eat-evil-test--straight))

(dolist (package '("eat" "evil" "goto-chg" "compat" "evil-surround" "evil-snipe"
                   "evil-exchange" "evil-numbers" "evil-goggles"))
  (let ((dir (expand-file-name package eat-evil-test--build)))
    (when (file-directory-p dir)
      (add-to-list 'load-path dir))))

(defconst eat-evil-test--available
  (and (executable-find "zsh")
       (require 'eat nil t)
       (require 'evil nil t)))

(defconst eat-evil-test--config
  (expand-file-name "../config/packages/shell/"
                    (file-name-directory (or load-file-name buffer-file-name))))

(when eat-evil-test--available
  (evil-mode 1)
  (evil-set-initial-state 'eat-mode 'insert)
  (load (expand-file-name "eat-terminfo.el" eat-evil-test--config) nil t)
  (load (expand-file-name "eat-evil.el" eat-evil-test--config) nil t)
  ;; Set terminfo up the way the config does, and use the terminal type a
  ;; graphical Emacs picks; batch Emacs would otherwise pick `eat-mono'.
  (setq luyangliuable/eat-terminfo-directory (make-temp-file "eat-terminfo" t))
  (luyangliuable/eat-use-compiled-terminfo)
  (setq eat-term-name "eat-truecolor"
        eat-term-shell-integration-directory
        (expand-file-name "integration" eat--install-path))
  ;; Mirror config/keybindings/shell/eat.el, which needs Doom's `map!'.
  (evil-define-key* 'normal eat-mode-map
    [remap evil-undo] #'luyangliuable/eat-evil-undo
    [remap evil-redo] #'luyangliuable/eat-evil-redo
    (kbd "RET") #'luyangliuable/eat-evil-send-return))

(defvar eat-evil-test--buffers nil
  "Shell buffers keyed by whether shell integration is on.")

(defun eat-evil-test--wait (&optional seconds)
  "Process terminal output for SECONDS."
  (let ((end (+ (float-time) (or seconds 0.3))))
    (while (< (float-time) end)
      (accept-process-output nil 0.02)))
  (luyangliuable/eat-evil--process-pending-output))

(defun eat-evil-test--start-shell (integration)
  "Start zsh in an Eat buffer, with shell INTEGRATION when non-nil."
  (let* ((dir (make-temp-file "eat-evil-test" t))
         (buffer (generate-new-buffer "*eat-evil-test*")))
    (with-temp-file (expand-file-name ".zshrc" dir)
      (insert "PROMPT='%d 💻 $ '\n"
              "RPROMPT='%D{%H:%M:%S} 🕝'\n"
              "HISTFILE=/dev/null\n"
              (if integration
                  "source \"$EAT_SHELL_INTEGRATION_DIR/zsh\"\n"
                "")))
    (with-current-buffer buffer
      (eat-mode)
      (let ((process-environment (cons (concat "ZDOTDIR=" dir) process-environment))
            (default-directory dir))
        (eat-exec buffer "eat-evil-test" "zsh" nil '("-i")))
      (eat-semi-char-mode)
      (evil-local-mode 1))
    (set-window-buffer (selected-window) buffer)
    (with-current-buffer buffer
      (eat-evil-test--wait 1.5))
    buffer))

(defun eat-evil-test--shell (integration)
  "Return a live shell buffer, with shell INTEGRATION when non-nil."
  (let ((buffer (alist-get integration eat-evil-test--buffers)))
    (unless (buffer-live-p buffer)
      (setq buffer (eat-evil-test--start-shell integration))
      (setf (alist-get integration eat-evil-test--buffers) buffer))
    (set-window-buffer (selected-window) buffer)
    buffer))

(defun eat-evil-test--parse-keys (keys)
  "Return the key vector for KEYS.
Characters stand for themselves, including spaces; `{NAME}' is a `kbd' key
such as {escape}, {RET} or {C-r}."
  (let ((pos 0)
        (events []))
    (while (< pos (length keys))
      (if (and (eq (aref keys pos) ?{)
               (string-match "{\\([^}]+\\)}" keys pos)
               (= (match-beginning 0) pos))
          (let ((name (match-string 1 keys)))
            (setq events (vconcat events (kbd (if (string-match-p "\\`[a-z]+\\'" name)
                                                  (format "<%s>" name)
                                                name)))
                  pos (match-end 0)))
        (setq events (vconcat events (vector (aref keys pos)))
              pos (1+ pos))))
    events))

(defun eat-evil-test--keys (keys)
  "Press KEYS (see `eat-evil-test--parse-keys') in the selected window."
  (execute-kbd-macro (eat-evil-test--parse-keys keys))
  (eat-evil-test--wait 0.15))

(defun eat-evil-test--line ()
  "Return the shell command line text."
  (let ((bounds (luyangliuable/eat-evil--input-bounds)))
    (luyangliuable/eat-evil--text (car bounds) (cdr bounds))))

(defun eat-evil-test--cursor ()
  "Return the shell cursor's index in the command line."
  (luyangliuable/eat-evil--cursor-index (luyangliuable/eat-evil--input-bounds)))

(defun eat-evil-test--start (text &optional integration)
  "Leave TEXT on an empty command line in normal state.
Use a shell with integration unless INTEGRATION is `none'."
  (with-current-buffer (eat-evil-test--shell (not (eq integration 'none)))
    (unless (evil-insert-state-p)
      (eat-evil-test--keys "i"))
    ;; Clear whatever an earlier test left behind.
    (eat-term-input-event eat-terminal 1 ?\C-e)
    (eat-term-input-event eat-terminal 1 ?\C-u)
    (eat-evil-test--wait 0.2)
    (setq luyangliuable/eat-evil--undo-stack nil
          luyangliuable/eat-evil--redo-stack nil)
    (eat-term-send-string eat-terminal text)
    (eat-evil-test--wait 0.2)
    (eat-evil-test--keys "{escape}")
    (should (evil-normal-state-p))
    (should (equal (eat-evil-test--line) text))))

(defmacro eat-evil-test--case (name text keys expected &rest options)
  "Define a test: KEYS turn command line TEXT into EXPECTED.
OPTIONS may contain :cursor (expected shell cursor index), :state
(expected Evil state), :integration (`none' to test the prompt regexp)
and :with (a function enabling a package for the test; it is called with
1 before and -1 after)."
  (declare (indent 1))
  (let ((with (plist-get options :with)))
    `(ert-deftest ,(intern (format "eat-evil/%s" name)) ()
       (skip-unless eat-evil-test--available)
       ,@(when with `((skip-unless (fboundp ',with))))
       (eat-evil-test--start ,text ',(plist-get options :integration))
       (with-current-buffer (window-buffer (selected-window))
         (unwind-protect
             (progn
               ,@(when with `((,with 1)))
               (eat-evil-test--keys ,keys)
               (should (equal (eat-evil-test--line) ,expected))
               ,@(when (plist-member options :cursor)
                   `((should (= (eat-evil-test--cursor) ,(plist-get options :cursor)))))
               (should (eq evil-state ',(or (plist-get options :state) 'normal))))
           ,@(when with `((,with -1))))))))


;;; ---------------------------------------------------------------------------
;;; Terminfo
;;; ---------------------------------------------------------------------------

(ert-deftest eat-evil/compiled-terminfo-is-readable ()
  (skip-unless eat-evil-test--available)
  (should (equal eat-term-terminfo-directory luyangliuable/eat-terminfo-directory))
  (dolist (term '("eat-mono" "eat-color" "eat-256color" "eat-truecolor"))
    (should (luyangliuable/eat-evil--terminfo-readable-p term eat-term-terminfo-directory))
    ;; zsh itself must see cursor movement, or it redraws in single-line mode.
    (should (equal (with-temp-buffer
                     (let ((process-environment
                            (append (list (concat "TERMINFO=" eat-term-terminfo-directory)
                                          (concat "TERM=" term))
                                    process-environment)))
                       (call-process "zsh" nil t nil "-f" "-c"
                                     "zmodload zsh/terminfo; print -rn -- ${+terminfo[cuf1]}"))
                     (buffer-string))
                   "1"))))

(ert-deftest eat-evil/terminfo-compiles-once ()
  (skip-unless eat-evil-test--available)
  (let ((target (make-temp-file "eat-terminfo" t))
        (source (expand-file-name "eat.ti" eat--install-path))
        (calls 0))
    (advice-add 'call-process :before (lambda (&rest _) (cl-incf calls)) '((name . count)))
    (unwind-protect
        (progn
          (should (equal (luyangliuable/eat-compile-terminfo source target) target))
          (should (equal (luyangliuable/eat-compile-terminfo source target) target))
          (should (= calls 1)))
      (advice-remove 'call-process 'count))))

(ert-deftest eat-evil/unreadable-terminfo-blocks-edits ()
  (skip-unless eat-evil-test--available)
  (eat-evil-test--start "echo hello world")
  (with-current-buffer (window-buffer (selected-window))
    (setq luyangliuable/eat-evil--terminfo-ok nil)
    (unwind-protect
        (let ((display (buffer-string)))
          (eat-evil-test--keys "0x")
          (eat-evil-test--keys "dd")
          (should (equal (buffer-string) display)))
      (setq luyangliuable/eat-evil--terminfo-ok t))
    (should (equal (eat-evil-test--line) "echo hello world"))))

(ert-deftest eat-evil/missing-terminfo-is-detected ()
  (skip-unless eat-evil-test--available)
  (should-not (luyangliuable/eat-evil--terminfo-readable-p
               "eat-truecolor" (make-temp-file "empty-terminfo" t))))


;;; ---------------------------------------------------------------------------
;;; Character and word deletion
;;; ---------------------------------------------------------------------------

(eat-evil-test--case x-at-start "echo hello world" "0x" "cho hello world" :cursor 0)
(eat-evil-test--case x-after-motion "echo hello world" "0wx" "echo ello world" :cursor 5)
(eat-evil-test--case x-with-count "echo hello world" "03x" "o hello world")
(eat-evil-test--case x-count-containing-zero "echo hello world" "010x" " world")
(eat-evil-test--case X-deletes-backward "echo hello world" "0wX" "echohello world")
(eat-evil-test--case x-at-end "echo hello world" "$x" "echo hello worl")
(eat-evil-test--case dw "echo hello world" "0dw" "hello world" :cursor 0)
(eat-evil-test--case dw-middle "echo hello world" "0wdw" "echo world")
(eat-evil-test--case dw-last-word "echo hello world" "0wwdw" "echo hello ")
(eat-evil-test--case de "echo hello world" "0de" " hello world")
(eat-evil-test--case db "echo hello world" "$db" "echo hello d")
(eat-evil-test--case d2w "echo hello world" "0d2w" "world")
(eat-evil-test--case diw "echo hello world" "0wldiw" "echo  world")
(eat-evil-test--case daw "echo hello world" "0wdaw" "echo world")
(eat-evil-test--case di-quote "echo \"a b\" c" "0f\"di\"" "echo \"\" c")
(eat-evil-test--case da-paren "echo (a b) c" "0f(da(" "echo  c")
(eat-evil-test--case dfo "echo hello world" "0dfo" " hello world")
(eat-evil-test--case dt-space "echo hello world" "0dt " " hello world")


;;; ---------------------------------------------------------------------------
;;; Line-oriented operators and motions
;;; ---------------------------------------------------------------------------

(eat-evil-test--case dd "echo hello world" "dd" "" :cursor 0)
(eat-evil-test--case D "echo hello world" "0wD" "echo ")
(eat-evil-test--case d-dollar "echo hello world" "0wd$" "echo ")
(eat-evil-test--case d-zero "echo hello world" "$d0" "d")
(eat-evil-test--case d-caret "echo hello world" "0wd^" "hello world")
(eat-evil-test--case zero-goes-to-command-start "echo hello world" "$0x" "cho hello world")
(eat-evil-test--case caret-goes-to-command-start "echo hello world" "$^x" "cho hello world")
(eat-evil-test--case dollar-skips-rprompt "echo hello world" "0$x" "echo hello worl")
(eat-evil-test--case J-leaves-line-alone "echo hello world" "J" "echo hello world")


;;; ---------------------------------------------------------------------------
;;; Change operators and insert state
;;; ---------------------------------------------------------------------------

(eat-evil-test--case cw "echo hello world" "0wcwhi{escape}" "echo hi world")
(eat-evil-test--case ciw "echo hello world" "0wciwbye{escape}" "echo bye world")
(eat-evil-test--case C "echo hello world" "0wCthere{escape}" "echo there")
(eat-evil-test--case cc "echo hello world" "ccls{escape}" "ls")
(eat-evil-test--case S "echo hello world" "Sls{escape}" "ls")
(eat-evil-test--case s "echo hello world" "0sE{escape}" "Echo hello world")
(eat-evil-test--case c-stays-in-insert "echo hello world" "0cw" " hello world"
  :cursor 0 :state insert)
(eat-evil-test--case i "echo hello world" "0wibig {escape}" "echo big hello world")
(eat-evil-test--case a "echo hello world" "0aX{escape}" "eXcho hello world")
(eat-evil-test--case A "echo hello world" "0A now{escape}" "echo hello world now")
(eat-evil-test--case I "echo hello world" "$Isudo {escape}" "sudo echo hello world")
(eat-evil-test--case o-appends "echo hello world" "0o!{escape}" "echo hello world!")
(eat-evil-test--case insert-cursor-follows-point "echo hello world" "0wi" "echo hello world"
  :cursor 5 :state insert)


;;; ---------------------------------------------------------------------------
;;; Replace and case
;;; ---------------------------------------------------------------------------

(eat-evil-test--case r "echo hello world" "0rX" "Xcho hello world")
(eat-evil-test--case r-with-count "echo hello world" "03rX" "XXXo hello world")
(eat-evil-test--case tilde "echo hello world" "0~" "Echo hello world")
(eat-evil-test--case gUiw "echo hello world" "0gUiw" "ECHO hello world")
(eat-evil-test--case gu-dollar "ECHO HELLO" "0wgu$" "ECHO hello")
(eat-evil-test--case g-tilde "echo hello" "0g~w" "ECHO hello")


;;; ---------------------------------------------------------------------------
;;; Yank, paste and registers
;;; ---------------------------------------------------------------------------

(eat-evil-test--case p-after-end "echo hello world" "0yiw$p" "echo hello worldecho")
(eat-evil-test--case P-at-start "echo hello world" "0yiwP" "echoecho hello world")
(eat-evil-test--case p-with-count "echo x" "0yiw$2p" "echo xechoecho")
(eat-evil-test--case yy-p-linewise "echo hi" "yy$p" "echo hiecho hi")
(eat-evil-test--case named-register "echo hello world" "0w\"ayiw$\"ap" "echo hello worldhello")
(eat-evil-test--case dw-then-p "echo hello world" "0dw$p" "hello worldecho ")
(eat-evil-test--case xp-swaps "echo hello" "0xp" "ceho hello")


;;; ---------------------------------------------------------------------------
;;; Visual state
;;; ---------------------------------------------------------------------------

(eat-evil-test--case v-e-x "echo hello world" "0vex" " hello world")
(eat-evil-test--case v-iw-c "echo hello world" "0wviwcbye{escape}" "echo bye world")
(eat-evil-test--case V-d "echo hello world" "Vd" "")
(eat-evil-test--case v-U "echo hello world" "0veU" "ECHO hello world")
(eat-evil-test--case v-y-p "echo hello world" "0vey$p" "echo hello worldecho")
(eat-evil-test--case v-p-replaces "echo hello world" "0yiwwviwp" "echo echo world")


;;; ---------------------------------------------------------------------------
;;; Undo, redo and repeat
;;; ---------------------------------------------------------------------------

(eat-evil-test--case undo-dw "echo hello world" "0dwu" "echo hello world" :cursor 0)
(eat-evil-test--case redo-dw "echo hello world" "0dwu{C-r}" "hello world")
(eat-evil-test--case undo-twice "echo hello world" "0dwdwuu" "echo hello world")
(eat-evil-test--case undo-count "echo hello world" "0dwdw2u" "echo hello world")
(eat-evil-test--case undo-insert-session "echo hello world" "0wcwhi{escape}u" "echo hello world")
(eat-evil-test--case undo-append "echo hello world" "A now{escape}u" "echo hello world")
(eat-evil-test--case repeat-dw "echo hello world" "0dw." "world")
(eat-evil-test--case repeat-x "echo hello world" "0x.." "o hello world")
(eat-evil-test--case repeat-cw "echo hello world" "0wcwX{escape}w." "echo X X")


;;; ---------------------------------------------------------------------------
;;; Wrapped commands, wide characters and the plain prompt fallback
;;; ---------------------------------------------------------------------------

(defconst eat-evil-test--long (concat "echo " (make-string 100 ?a)))

(eat-evil-test--case long-zero-x eat-evil-test--long "0x" (substring eat-evil-test--long 1))
(eat-evil-test--case long-dollar-x eat-evil-test--long "$x" (substring eat-evil-test--long 0 -1))
(eat-evil-test--case long-dd eat-evil-test--long "$dd" "")
(eat-evil-test--case long-cc eat-evil-test--long "$ccls{escape}" "ls")
(eat-evil-test--case long-db eat-evil-test--long "$bdw" "echo ")
(eat-evil-test--case emoji-dw "echo 💻 ok" "0wdw" "echo ok")
(eat-evil-test--case emoji-x-after "echo 💻 ok" "$x" "echo 💻 o")
(eat-evil-test--case emoji-diw-after "echo 💻 ok" "$diw" "echo 💻 ")
(eat-evil-test--case no-integration-x "echo hello world" "0x" "cho hello world"
  :integration none)
(eat-evil-test--case no-integration-dd "echo hello world" "dd" ""
  :integration none)
(eat-evil-test--case no-integration-dollar "echo hello world" "0$x" "echo hello worl"
  :integration none)


;;; ---------------------------------------------------------------------------
;;; More Evil commands
;;; ---------------------------------------------------------------------------

(eat-evil-test--case R-overwrites "echo hello world" "0Rxy{escape}" "xyho hello world")
(eat-evil-test--case count-insert-repeats "echo" "03iab{escape}" "abababecho")
(eat-evil-test--case repeat-append "echo" "A 1{escape}." "echo 1 1")
(eat-evil-test--case ex-substitute "echo hello world" ":s/hello/bye/{RET}" "echo bye world")
(eat-evil-test--case ex-substitute-all "echo a a a" ":s/a/b/g{RET}" "echo b b b")
(eat-evil-test--case execute-register "echo hello world" "@a" "cho hello world"
  :with eat-evil-test--register-a)
(eat-evil-test--case visual-block-d "echo hello" "0{C-v}lld" "o hello")
(eat-evil-test--case gi-resumes-insert "echo hello world" "0wiX{escape}$giY{escape}"
  "echo XYhello world")

(defun eat-evil-test--register-a (enable)
  "Put \"0x\" in register a when ENABLE is positive."
  (when (> enable 0)
    (evil-set-register ?a "0x")))


;;; ---------------------------------------------------------------------------
;;; Doom's Evil packages
;;; ---------------------------------------------------------------------------

(defun eat-evil-test--surround (enable)
  "Turn `evil-surround-mode' on or off according to ENABLE."
  (when (require 'evil-surround nil t)
    (evil-surround-mode enable)))

(defun eat-evil-test--snipe (enable)
  "Turn `evil-snipe-local-mode' on or off according to ENABLE."
  (when (require 'evil-snipe nil t)
    (evil-snipe-local-mode enable)))

(defun eat-evil-test--goggles (enable)
  "Turn `evil-goggles-mode' on or off according to ENABLE."
  (when (require 'evil-goggles nil t)
    (evil-goggles-mode enable)))

(defun eat-evil-test--doom-g-keys (enable)
  "Bind Doom's gx, g= and g- when ENABLE is positive."
  (when (and (> enable 0)
             (require 'evil-exchange nil t)
             (require 'evil-numbers nil t))
    (evil-define-key* '(normal visual) 'global (kbd "gx") #'evil-exchange)
    (evil-define-key* 'normal 'global
      (kbd "g=") #'evil-numbers/inc-at-pt
      (kbd "g-") #'evil-numbers/dec-at-pt)))

(eat-evil-test--case surround-add "echo hello" "0wysiw\"" "echo \"hello\""
  :with eat-evil-test--surround)
(eat-evil-test--case surround-change "echo \"hello\"" "0wlcs\"'" "echo 'hello'"
  :with eat-evil-test--surround)
(eat-evil-test--case surround-delete "echo (hello)" "0wlds(" "echo hello"
  :with eat-evil-test--surround)
(eat-evil-test--case snipe-motion "echo hello world" "0swox" "echo hello orld"
  :with eat-evil-test--snipe)
(eat-evil-test--case snipe-operator-inclusive "echo hello world" "0dzwo" "rld"
  :with eat-evil-test--snipe)
(eat-evil-test--case snipe-operator-exclusive "echo hello world" "0dxwo" "world"
  :with eat-evil-test--snipe)
(eat-evil-test--case exchange "echo hello world" "0wgxiwwgxiw" "echo world hello"
  :with eat-evil-test--doom-g-keys)
(eat-evil-test--case numbers-increment "sleep 41" "0g=" "sleep 42"
  :with eat-evil-test--doom-g-keys)
(eat-evil-test--case numbers-decrement-count "sleep 41" "05g-" "sleep 36"
  :with eat-evil-test--doom-g-keys)
(eat-evil-test--case goggles-dw "echo hello world" "0dw" "hello world"
  :with eat-evil-test--goggles)
(eat-evil-test--case goggles-yank-paste "echo hello world" "0yiw$p" "echo hello worldecho"
  :with eat-evil-test--goggles)
(eat-evil-test--case goggles-cw "echo hello world" "0wcwbye{escape}" "echo bye world"
  :with eat-evil-test--goggles)
(eat-evil-test--case goggles-undo "echo hello world" "0dwu" "echo hello world"
  :with eat-evil-test--goggles)


;;; ---------------------------------------------------------------------------
;;; Terminal output and running commands
;;; ---------------------------------------------------------------------------

(ert-deftest eat-evil/output-is-read-only ()
  (skip-unless eat-evil-test--available)
  (eat-evil-test--start "echo marker-output")
  (with-current-buffer (window-buffer (selected-window))
    (eat-evil-test--keys "{RET}")
    (eat-evil-test--wait 0.3)
    (let ((display (buffer-substring-no-properties (point-min) (point-max))))
      (should (string-match-p "^marker-output *$" display))
      ;; Delete on the output line, then check nothing changed.
      (goto-char (point-min))
      (re-search-forward "^marker-output *$")
      (forward-line 0)
      (eat-evil-test--keys "x")
      (eat-evil-test--keys "dd")
      (should (equal (buffer-substring-no-properties (point-min) (point-max))
                     display))
      (should (equal (eat-evil-test--line) "")))))

(ert-deftest eat-evil/return-runs-command ()
  (skip-unless eat-evil-test--available)
  (eat-evil-test--start "echo ran-$((40 + 2))")
  (with-current-buffer (window-buffer (selected-window))
    (eat-evil-test--keys "{RET}")
    (should (string-match-p "^ran-42 *$" (buffer-substring-no-properties
                                        (point-min) (point-max))))
    (should (equal (eat-evil-test--line) ""))))

(ert-deftest eat-evil/insert-from-output-goes-to-prompt ()
  (skip-unless eat-evil-test--available)
  (eat-evil-test--start "echo above")
  (with-current-buffer (window-buffer (selected-window))
    (eat-evil-test--keys "{RET}")
    (eat-evil-test--keys "ils{escape}")
    (eat-evil-test--keys "kk")
    (should-not (luyangliuable/eat-evil--command-line-at-point))
    (eat-evil-test--keys "A -l{escape}")
    (should (equal (eat-evil-test--line) "ls -l"))))

(ert-deftest eat-evil/yank-from-output-and-paste ()
  (skip-unless eat-evil-test--available)
  (eat-evil-test--start "echo copied-word")
  (with-current-buffer (window-buffer (selected-window))
    (eat-evil-test--keys "{RET}")
    (eat-evil-test--keys "iecho {escape}")
    (goto-char (point-min))
    (re-search-forward "^copied-word")
    (forward-line 0)
    (eat-evil-test--keys "yiW")
    (goto-char (point-max))
    (eat-evil-test--keys "$p")
    (should (equal (eat-evil-test--line) "echo copied-word"))))

(ert-deftest eat-evil/full-screen-program-is-not-edited ()
  (skip-unless eat-evil-test--available)
  (eat-evil-test--start "printf '\\e[?1049h\\e[2Jfullscreen'; sleep 2; printf '\\e[?1049l'")
  (with-current-buffer (window-buffer (selected-window))
    (eat-evil-test--keys "{RET}")
    (eat-evil-test--wait 0.3)
    (should (eat-term-in-alternative-display-p eat-terminal))
    (should-not (luyangliuable/eat-evil--input-bounds))
    (let ((display (buffer-string)))
      (eat-evil-test--keys "0x")
      (eat-evil-test--keys "dd")
      (should (equal (buffer-string) display)))
    (eat-evil-test--wait 2.2)
    (should-not (eat-term-in-alternative-display-p eat-terminal))))

(ert-deftest eat-evil/history-resets-on-new-prompt ()
  (skip-unless eat-evil-test--available)
  (eat-evil-test--start "echo one")
  (with-current-buffer (window-buffer (selected-window))
    (eat-evil-test--keys "0x")
    (eat-evil-test--keys "{RET}")
    (eat-evil-test--keys "ils{escape}")
    (eat-evil-test--keys "u")
    (should (equal (eat-evil-test--line) ""))
    ;; The edit from the previous prompt must not be replayed.
    (eat-evil-test--keys "u")
    (should (equal (eat-evil-test--line) ""))))

;;; eat-evil-test.el ends here
