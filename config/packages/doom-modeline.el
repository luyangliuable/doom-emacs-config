;;; config/packages/doom-modeline.el -*- lexical-binding: t; -*-
;; Doom modeline customization

(defun luyangliuable/doom-modeline-safe-buffer-file-truename (orig-fn file-name)
  "Avoid resolving a truename for a deleted local FILE-NAME."
  (if (and (stringp file-name)
           (not (file-remote-p file-name))
           (not (file-exists-p file-name)))
      file-name
    (funcall orig-fn file-name)))

(defun luyangliuable/doom-modeline-set-project-detection (value)
  "Set project detection after detaching buffers visiting deleted files."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (and buffer-file-name (not (file-exists-p buffer-file-name)))
        (set-visited-file-name nil t))))
  (setq doom-modeline-project-detection value))

(defvar luyangliuable/doom-modeline-state-icon-interval 1.0
  "Seconds a buffer's state icon is reused while its in-memory state is unchanged.")

(defvar-local luyangliuable/doom-modeline--state-icon-cache nil
  "(TIME KEY . ICON) from the buffer's last full state icon update.")

(defun luyangliuable/doom-modeline-throttle-state-icon (orig-fn &rest args)
  "Call ORIG-FN with ARGS unless the buffer state icon was just computed.
The icon is rebuilt on every redisplay, and each rebuild stats the visited
file.  Changes to buffer state still show immediately; only on-disk changes
\(file modified or deleted elsewhere) can lag, by at most
`luyangliuable/doom-modeline-state-icon-interval' seconds."
  (let ((key (list buffer-file-name buffer-read-only (buffer-modified-p)
                   (buffer-narrowed-p)
                   (and (bound-and-true-p fancy-narrow-mode)
                        (fboundp 'fancy-narrow-active-p)
                        (fancy-narrow-active-p))
                   (bound-and-true-p dired-narrow-mode)
                   doom-modeline-buffer-state-icon
                   doom-modeline-buffer-modification-icon
                   doom-modeline-icon doom-modeline-unicode-fallback))
        (cache luyangliuable/doom-modeline--state-icon-cache)
        (now (float-time)))
    (if (and cache
             (< (- now (car cache)) luyangliuable/doom-modeline-state-icon-interval)
             (equal key (cadr cache)))
        (setq doom-modeline--buffer-file-state-icon (cddr cache))
      (let ((icon (apply orig-fn args)))
        (setq luyangliuable/doom-modeline--state-icon-cache
              (cons now (cons key icon)))
        icon))))

(with-eval-after-load 'doom-modeline
  (unless (advice-member-p
           #'luyangliuable/doom-modeline-safe-buffer-file-truename
           'doom-modeline--format-buffer-file-truename)
    (advice-add 'doom-modeline--format-buffer-file-truename :around
                #'luyangliuable/doom-modeline-safe-buffer-file-truename))
  (advice-add 'doom-modeline-update-buffer-file-state-icon :around
              #'luyangliuable/doom-modeline-throttle-state-icon))

(defvar luyangliuable/doom-modeline--bongo-cat-candidate nil
  "Bongo Cat string being measured, or nil when not measuring.")

(defvar luyangliuable/doom-modeline--main-forms-cache nil
  "(FORMAT-FN LHS-FORMS RHS-FORMS) of the main mode-line.")

(defun luyangliuable/doom-modeline--main-forms ()
  "Return the main mode-line's left and right segment forms.
`doom-modeline-def-modeline' fixes them when it defines the mode-line, so
they are only re-read after `doom-modeline-format--main' is redefined."
  (let ((fn (symbol-function 'doom-modeline-format--main)))
    (unless (eq fn (car luyangliuable/doom-modeline--main-forms-cache))
      (let ((parts (funcall fn)))
        (setq luyangliuable/doom-modeline--main-forms-cache
              (list fn (nth 0 parts) (nth 2 parts)))))
    (cdr luyangliuable/doom-modeline--main-forms-cache)))

(defun luyangliuable/doom-modeline--bongo-cat-fits-p (cat)
  "Return non-nil if the main mode-line, drawing CAT, fits the selected window.
The width matches how `doom-modeline-def-modeline' right-aligns its right side."
  (let* ((luyangliuable/doom-modeline--bongo-cat-candidate cat)
         (line (format-mode-line (luyangliuable/doom-modeline--main-forms))))
    (add-face-text-property 0 (length line) 'mode-line t line)
    (<= (doom-modeline-string-pixel-width line)
        (- (window-pixel-width)
           (window-scroll-bar-width)
           (window-right-divider-width)
           (* (or (cdr (window-margins)) 1) (frame-char-width))))))

(defvar luyangliuable/doom-modeline--bongo-cat-window nil
  "Window whose main mode-line last drew Bongo Cat.")

(defun luyangliuable/doom-modeline--bongo-cat-wanted-p ()
  "Return non-nil if this mode-line should show Bongo Cat or its bar/HUD."
  (and (bound-and-true-p bongo-cat-scroll-mode) (doom-modeline--active)))

(defun luyangliuable/doom-modeline-bongo-cat ()
  "Return Bongo Cat if the focused main mode-line fits it, else nil.
doom-modeline evaluates the right side before the left, so this also
records whether `luyangliuable/doom-modeline-bongo-cat-bar' should draw."
  (or luyangliuable/doom-modeline--bongo-cat-candidate
      (let ((cat (and (luyangliuable/doom-modeline--bongo-cat-wanted-p)
                      (bongo-cat-scroll-mode-format))))
        (setq luyangliuable/doom-modeline--bongo-cat-window
              (and (> (length cat) 0)
                   (luyangliuable/doom-modeline--bongo-cat-fits-p cat)
                   (selected-window)))
        (and luyangliuable/doom-modeline--bongo-cat-window cat))))

(defun luyangliuable/doom-modeline-bongo-cat-bar ()
  "Return Doom's bar/HUD in the focused main mode-line when Bongo Cat doesn't fit."
  (and (not luyangliuable/doom-modeline--bongo-cat-candidate)
       (luyangliuable/doom-modeline--bongo-cat-wanted-p)
       (not (eq luyangliuable/doom-modeline--bongo-cat-window (selected-window)))
       (doom-modeline-segment--bar)))

(use-package! doom-modeline
  :init
  (setq doom-modeline-hud t) ;; Enable the HUD feature

  ;; Modeline appearance settings
  (display-battery-mode 1)
  (display-time-mode 1)

  ;; Height 1 sizes bars/HUDs to the mode-line text, so they never overflow it.
  (setq doom-modeline-height 1
    doom-modeline-icon t
    doom-modeline-time-icon nil
    doom-modeline-buffer-encoding t
    doom-modeline-buffer-file-name-style nil ;; Disable file path in modeline
    doom-modeline-minor-modes nil ;; minor-mode-badges handles selected minor modes
    doom-modeline-major-mode-icon t
    doom-modeline-major-mode t
    doom-modeline-linenumber t
    doom-modeline-display-misc-in-all-mode-lines nil
    doom-modeline-bar-width 6)

  (luyangliuable/doom-modeline-set-project-detection 'projectile)

  :config
  (doom-modeline-def-segment luyangliuable-modeline-space
    (propertize " " 'display '(space :width 2)))

  (doom-modeline-def-segment luyangliuable-modeline-divider
    (let ((pad (propertize " " 'display '(space :width .2))))
      (concat
       pad
       (propertize "/" 'face '(:inherit doom-modeline-info :box nil))
       ;; (propertize "" 'face '(:inherit doom-modeline-info :box nil))
       pad)))

  (require 'minor-mode-badges nil t)

  (doom-modeline-def-segment minor-mode-badges
    (when (fboundp 'minor-mode-badges-format)
      (minor-mode-badges-format)))

  (doom-modeline-def-segment bongo-cat
    "Bongo Cat, when the mode-line has room for it."
    (luyangliuable/doom-modeline-bongo-cat))

  (doom-modeline-def-segment bongo-cat-bar
    "Doom's bar/HUD, when Bongo Cat doesn't fit."
    (luyangliuable/doom-modeline-bongo-cat-bar))

  (doom-modeline-def-modeline 'main
    '(bongo-cat-bar  ; Doom's bar/HUD when Bongo Cat doesn't fit
       eldoc          ; Show eldoc/help text in the modeline
       ;; bar            ; Doom's built-in modeline bar/HUD
       ;; parrot         ; Parrot mode indicator, if enabled
       window-state   ; Window state indicator
       workspace-name ; Current workspace name
       window-number  ; Current window number
       modals         ; Modal state indicators, e.g. Evil state
       matches        ; Search/match count information
       follow         ; Follow mode indicator
       buffer-info    ; Buffer name, modified state, and file status
       remote-host    ; Remote host indicator for TRAMP buffers
       word-count     ; Word count for supported modes/regions
       selection-info) ; Active selection size/count
    '(compilation    ; Compilation status
       objed-state    ; objed mode state indicator
       misc-info      ; Miscellaneous mode-line info
       bongo-cat      ; Bongo Cat, when the mode-line has room for it
       project-name   ; Current project name
       persp-name     ; Current perspective/workspace name
       grip           ; Markdown preview/grip status
       irc            ; IRC status
       mu4e           ; mu4e/mail status
       gnus           ; Gnus mail/news status
       github         ; GitHub notification/status segment
       debug          ; Debugger status
       repl           ; REPL status
       lsp            ; LSP server/status indicator
       input-method   ; Active input method
       indent-info    ; Indentation style/width
       buffer-encoding ; File encoding and line ending style
       major-mode     ; Current major mode
       process        ; Process status for process-backed buffers
       vcs            ; Version control branch/status
       check          ; Flycheck/Flymake diagnostics
       ;; luyangliuable-modeline-divider ; Visual separator before battery
       minor-mode-badges ; Active minor modes as clickable badges
       ;; luyangliuable-modeline-divider ; Visual separator before battery
       time           ; Current time from display-time-mode
       ;; luyangliuable-modeline-divider ; Visual separator before battery
       battery        ; Laptop battery status
       luyangliuable-modeline-space)) ; Right padding

  (defun luyangliuable/use-main-doom-modeline ()
    "Use the main Doom modeline layout in the current buffer."
    (when (bound-and-true-p doom-modeline-mode)
      (ignore-errors
        (doom-modeline-set-modeline 'main))))

  (add-hook 'fundamental-mode-hook #'luyangliuable/use-main-doom-modeline)

  ;; `doom-modeline-segment--media-info' calls `image-size' on any `image-mode'
  ;; buffer's image. During a re-render (e.g. the PlantUML preview) the buffer
  ;; briefly holds raw bytes that are not yet a valid image, so `image-size'
  ;; signals "Invalid image specification" on every redisplay. Make the segment
  ;; fail-safe so a transient/invalid image never breaks the modeline.
  (advice-add 'doom-modeline-segment--media-info :around
              (lambda (orig-fn &rest args)
                (ignore-errors (apply orig-fn args))))

  (ignore-errors
    (doom-modeline-mode 1))

  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (eq major-mode 'fundamental-mode)
        (ignore-errors
          (luyangliuable/use-main-doom-modeline))))))
