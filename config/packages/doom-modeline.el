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

(with-eval-after-load 'doom-modeline
  (unless (advice-member-p
           #'luyangliuable/doom-modeline-safe-buffer-file-truename
           'doom-modeline--format-buffer-file-truename)
    (advice-add 'doom-modeline--format-buffer-file-truename :around
                #'luyangliuable/doom-modeline-safe-buffer-file-truename)))

(use-package! doom-modeline
  :init
  (setq doom-modeline-hud t) ;; Enable the HUD feature

  ;; Modeline appearance settings
  (display-battery-mode 1)
  (display-time-mode 1)

  (setq doom-modeline-height 24
    doom-modeline-icon t
    doom-modeline-time-icon nil
    doom-modeline-buffer-encoding t
    doom-modeline-buffer-file-name-style nil ;; Disable file path in modeline
    doom-modeline-minor-modes nil ;; minor-mode-badges handles selected minor modes
    doom-modeline-major-mode-icon t
    doom-modeline-major-mode t
    doom-modeline-linenumber t
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

  (doom-modeline-def-modeline 'main
    '(eldoc          ; Show eldoc/help text in the modeline
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
