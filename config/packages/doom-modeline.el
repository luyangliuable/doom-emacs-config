;;; config/packages/doom-modeline.el -*- lexical-binding: t; -*-
;; Doom modeline customization

(use-package! doom-modeline
  :init
  (setq doom-modeline-hud t) ;; Enable the HUD feature

  ;; Modeline appearance settings
  (display-battery-mode 1)
  (display-time-mode 1)

  (setq doom-modeline-height 28
    doom-modeline-icon t
    doom-modeline-time-icon nil
    doom-modeline-buffer-encoding t
    doom-modeline-project-detection 'projectile
    doom-modeline-buffer-file-name-style nil ;; Disable file path in modeline
    doom-modeline-minor-modes nil ;; minor-mode-badges handles selected minor modes
    doom-modeline-major-mode-icon t
    doom-modeline-major-mode t
    doom-modeline-linenumber t
    doom-modeline-bar-width 6)

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
       bar            ; Doom's built-in modeline bar/HUD
       window-state   ; Window state indicator
       workspace-name ; Current workspace name
       window-number  ; Current window number
       modals         ; Modal state indicators, e.g. Evil state
       matches        ; Search/match count information
       follow         ; Follow mode indicator
       buffer-info    ; Buffer name, modified state, and file status
       remote-host    ; Remote host indicator for TRAMP buffers
       word-count     ; Word count for supported modes/regions
       parrot         ; Parrot mode indicator, if enabled
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
       luyangliuable-modeline-divider ; Visual separator before battery
       minor-mode-badges ; Active minor modes as clickable badges
       luyangliuable-modeline-divider ; Visual separator before battery
       time           ; Current time from display-time-mode
       luyangliuable-modeline-divider ; Visual separator before battery
       battery        ; Laptop battery status
       luyangliuable-modeline-space)) ; Right padding

  (doom-modeline-mode 1))
