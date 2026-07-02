;;; config/ui.el -*- lexical-binding: t; -*-
;; UI Package Configurations

;;; ============================================================================
;;; UI CONFIGURATION
;;; ============================================================================

;; Doom modeline customization
(progn
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
      doom-modeline-minor-modes nil ;; disable showing modeline minor mode  luyangliuable/modeline-minor-mode-whitelist already handles this
      doom-modeline-major-mode-icon t
      doom-modeline-major-mode t
      doom-modeline-linenumber t
      doom-modeline-bar-width 6)

    :config
    (doom-modeline-def-segment luyangliuable-modeline-space
      (propertize " " 'display '(space :width 2)))

    (doom-modeline-def-segment luyangliuable-modeline-divider
      (propertize "│" 'face 'mode-line-inactive))

    (defface luyangliuable-modeline-minor-mode
      '((t (:inherit mode-line :foreground "black" :background unspecified)))
      "Face for compact minor mode indicators.")

    (defvar luyangliuable/modeline-minor-mode-whitelist
      '(yas-minor-mode
        smartparens-mode
        minimap-mode
        company-mode
        flycheck-mode
        projectile-mode
        magit-auto-revert-mode
        auto-highlight-symbol-mode
        good-scroll-mode
        beacon-mode)
      "Minor modes allowed in the compact modeline indicator.")

    (defun luyangliuable/circled-letter (char)
      "Return uppercase circled unicode version of CHAR."
      (let ((char (upcase char)))
        (if (eq char ?M)
            "M"
          (let ((index (- char ?A)))
            (if (and (>= index 0) (< index 26))
                (char-to-string (+ ?Ⓐ index))
              (char-to-string char))))))

    (defun luyangliuable/active-modeline-minor-modes ()
      "Return active whitelisted minor modes."
      (seq-filter (lambda (mode)
                    (and (boundp mode) (symbol-value mode)))
                  luyangliuable/modeline-minor-mode-whitelist))

    (defun luyangliuable/modeline-minor-mode-menu ()
      "Show active whitelisted minor modes in a completion menu."
      (interactive)
      (let* ((modes (luyangliuable/active-modeline-minor-modes))
             (names (mapcar #'symbol-name modes))
             (choice (and names
                          (completing-read "Toggle minor mode: " names nil t))))
        (if (and choice (not (string-empty-p choice)))
            (let ((mode (intern choice)))
              (call-interactively mode)
              (force-mode-line-update t)
              (redraw-display)
              (luyangliuable/modeline-minor-mode-menu))
          (unless modes
            (message "No active whitelisted minor modes")))))

    (defun luyangliuable/minor-mode-label (mode duplicate-firsts)
      "Return a compact circled label for MODE."
      (let* ((name (replace-regexp-in-string "-mode\\'" "" (symbol-name mode)))
             (chars (string-to-list (replace-regexp-in-string "[^[:alpha:]]" "" name)))
             (len (if (memq (car chars) duplicate-firsts) 2 1)))
        (mapconcat #'luyangliuable/circled-letter (seq-take chars len) "")))

    (doom-modeline-def-segment luyangliuable-minor-mode-circles
      (let* ((active-modes
              (luyangliuable/active-modeline-minor-modes))
             (firsts (mapcar (lambda (mode)
                               (car (string-to-list
                                     (replace-regexp-in-string
                                      "[^[:alpha:]]" ""
                                      (replace-regexp-in-string
                                       "-mode\\'" "" (symbol-name mode))))))
                             active-modes))
             (duplicate-firsts
              (seq-filter (lambda (char)
                            (> (cl-count char firsts) 1))
                          (delete-dups (copy-sequence firsts))))
             (labels (mapcar (lambda (mode)
                               (luyangliuable/minor-mode-label mode duplicate-firsts))
                             active-modes)))
        (when labels
          (propertize (string-join labels "")
                      'face 'luyangliuable-modeline-minor-mode
                      'mouse-face 'mode-line-highlight
                      'help-echo "mouse-1: show active minor modes"
                      'local-map (let ((map (make-sparse-keymap)))
                                   (define-key map [mode-line mouse-1]
                                     #'luyangliuable/modeline-minor-mode-menu)
                                   map)))))

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
        luyangliuable-minor-mode-circles ; Active minor modes as circled letters
        input-method   ; Active input method
        indent-info    ; Indentation style/width
        buffer-encoding ; File encoding and line ending style
        major-mode     ; Current major mode
        process        ; Process status for process-backed buffers
        vcs            ; Version control branch/status
        check          ; Flycheck/Flymake diagnostics
        luyangliuable-modeline-divider ; Visual separator before battery
        time           ; Current time from display-time-mode
        luyangliuable-modeline-divider ; Visual separator before battery
        battery        ; Laptop battery status
        luyangliuable-modeline-space)) ; Right padding

    (doom-modeline-mode 1))

  ;; Beacon - highlight cursor position on big movements
  ;; Lazy load after 5 seconds to improve startup performance
  (use-package! beacon
    :defer 5
    :init
    ;; Beacon appearance settings (optimized for faster animation)
    (setq beacon-blink-duration 0.3 ;; Faster animation (was 0.8)
      beacon-blink-delay 0.1        ;; Faster start (was 0.3)
      beacon-size 40                ;; Size of the beacon
      beacon-color "#ff9d00"        ;; Color of the beacon
      beacon-push-mark 35 ;; Number of moves before pushing a new mark onto the ring
      beacon-dont-blink-commands '() ;; Commands that won't trigger a blink
      beacon-blink-when-buffer-changes t     ;; Blink when switching buffers
      beacon-blink-when-window-changes t     ;; Blink when switching windows
      beacon-blink-when-point-moves t        ;; Blink when point moves
      beacon-blink-when-window-scrolls t     ;; Blink when window scrolls
      beacon-blink-when-focused t)           ;; Blink when the frame gains focus
    :config
    (beacon-mode 1))

  ;; Minimap configuration
  ;; Enable minimap automatically for long files, but defer activation until
  ;; after `find-file' finishes. Running `minimap-mode' inside
  ;; `find-file-hook' can make first-time opens from gptel/magit stay in the
  ;; original buffer because minimap temporarily switches buffers.
  (use-package! minimap
    :defer t
    :init
    (setq minimap-window-location 'right)
    :config
    (defun luyangliuable/minimap-for-long-files ()
      "Enable minimap for file buffers longer than 100 lines."
      (when (and buffer-file-name
              (> (count-lines (point-min) (point-max)) 100))
        (let ((buf (current-buffer)))
          (run-at-time
            0.5 nil
            (lambda ()
              (when (buffer-live-p buf)
                (with-current-buffer buf
                  (when (and buffer-file-name
                          (> (count-lines (point-min) (point-max)) 100)
                          (not (bound-and-true-p minimap-mode)))
                    (require 'minimap)
                    (minimap-mode 1)))))))))

    (add-hook 'find-file-hook #'luyangliuable/minimap-for-long-files)
    (add-hook 'after-change-major-mode-hook
      #'luyangliuable/minimap-for-long-files))


  ;; zoom in on find file so default file text size is bigger
  ;; (dolist (hook '(find-file-hook magit-mode-hook shell-mode-hook fundamental-mode-hook))
  ;;   (add-hook hook (lambda () (text-scale-increase 3))))
  (defvar my-scaled-mode-exclusions '(treemacs-mode magit-diff-mode +doom-dashboard-mode))

  (add-hook 'change-major-mode-after-body-hook
    (lambda ()
      (unless (apply #'derived-mode-p my-scaled-mode-exclusions)
        (text-scale-increase 3))))


  ;; Good scroll - smooth scrolling
  ;; Lazy load after 3 seconds with optimized settings
  (use-package good-scroll
    :defer 3
    :config
    ;; Optimized scrolling settings for better performance
    (setq good-scroll-duration 0.05) ;; Faster duration for better performance (was 0.1)
    (setq good-scroll-amount 2)      ;; Smaller scroll amount (was 3)
    (setq good-scroll-algorithm #'good-scroll-linear)

    (good-scroll-mode 1))

  ;; Global breadcrumb navigation for all files (non-LSP files)
  ;; Optimized version with project root caching
  (defun my/set-header-line-breadcrumb ()
    "Set header line breadcrumb for file buffers only."
    (when (and buffer-file-name
            (file-exists-p buffer-file-name)
            (not (string-match-p "^\\*" (buffer-name)))
            (not (string-match-p "^magit" (buffer-name)))
            (not (derived-mode-p 'special-mode))
            (not (derived-mode-p 'help-mode))
            (not (derived-mode-p 'compilation-mode)))
      ;; Use cached project root if available for better performance
      (let* ((project-root (or (and (boundp 'projectile-cached-project-root)
                                 projectile-cached-project-root)
                             (and (featurep 'projectile)
                               (ignore-errors (projectile-project-root)))))
              (file-path (file-name-directory buffer-file-name))
              (file-name (file-name-nondirectory buffer-file-name)))
        (setq header-line-format
          (concat
            (propertize " " 'display '(space :align-to 0))
            (when project-root
              (propertize (file-name-nondirectory (directory-file-name project-root))
                'face 'font-lock-string-face))
            (when project-root " > ")
            (propertize (if project-root
                          (file-relative-name file-path project-root)
                          (abbreviate-file-name file-path))
              'face 'font-lock-comment-face)
            (propertize file-name 'face 'mode-line-buffer-id))))))

  ;; Apply breadcrumb to file buffers
  (add-hook 'find-file-hook #'my/set-header-line-breadcrumb)
  (add-hook 'after-change-major-mode-hook #'my/set-header-line-breadcrumb))
