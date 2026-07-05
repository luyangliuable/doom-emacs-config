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
      '((t (:inherit mode-line :weight bold :background unspecified)))
      "Face for compact minor mode indicators.")

    (defface luyangliuable-modeline-minor-mode-inactive
      '((t (:inherit (mode-line warning)
             :weight bold
             :strike-through t
             :background unspecified)))
      "Face for modeline minor modes disabled from their circle button.")

    (defface luyangliuable-modeline-minor-mode-hover
      '((t (:inherit mode-line-highlight :weight bold)))
      "Hover face for active modeline minor mode indicators.")

    (defface luyangliuable-modeline-minor-mode-inactive-hover
      '((t (:inherit (mode-line-highlight warning)
             :weight bold
             :strike-through t)))
      "Hover face for disabled modeline minor mode indicators.")

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

    (defvar luyangliuable/modeline-minor-mode-button-disabled nil
      "Minor modes disabled from their modeline circle button.")

    (defun luyangliuable/circled-letter (char)
      "Return uppercase circled unicode version of CHAR."
      (let ((char (upcase char)))
        (if (eq char ?M)
            "M"
          (let ((index (- char ?A)))
            (if (and (>= index 0) (< index 26))
                (char-to-string (+ ?Ⓐ index))
              (char-to-string char))))))

    (defun luyangliuable/modeline-minor-mode-active-p (mode)
      "Return non-nil when MODE is active."
      (and (boundp mode) (symbol-value mode)))

    (defun luyangliuable/active-modeline-minor-modes ()
      "Return active whitelisted minor modes."
      (seq-filter #'luyangliuable/modeline-minor-mode-active-p
                  luyangliuable/modeline-minor-mode-whitelist))

    (defun luyangliuable/modeline-shown-minor-modes ()
      "Return active modes plus modes disabled through circle buttons."
      (setq luyangliuable/modeline-minor-mode-button-disabled
            (seq-filter (lambda (mode)
                          (not (luyangliuable/modeline-minor-mode-active-p mode)))
                        luyangliuable/modeline-minor-mode-button-disabled))
      (seq-filter (lambda (mode)
                    (or (luyangliuable/modeline-minor-mode-active-p mode)
                        (memq mode luyangliuable/modeline-minor-mode-button-disabled)))
                  luyangliuable/modeline-minor-mode-whitelist))

    (defun luyangliuable/modeline-toggle-minor-mode (mode)
      "Toggle MODE from the modeline."
      (interactive)
      (when (fboundp mode)
        (call-interactively mode)
        (if (luyangliuable/modeline-minor-mode-active-p mode)
            (setq luyangliuable/modeline-minor-mode-button-disabled
                  (delq mode luyangliuable/modeline-minor-mode-button-disabled))
          (add-to-list 'luyangliuable/modeline-minor-mode-button-disabled mode))
        (force-mode-line-update t)
        (redraw-display)))

    (defun luyangliuable/modeline-minor-mode-hover-face (mode index active)
      "Return a unique hover face for MODE at INDEX."
      (let ((face (intern (format "luyangliuable-modeline-%s-%s-%s-hover"
                                  mode index
                                  (if active "active" "inactive")))))
        (unless (facep face)
          (make-empty-face face)
          (set-face-attribute
           face nil :inherit
           (if active
               'luyangliuable-modeline-minor-mode-hover
             'luyangliuable-modeline-minor-mode-inactive-hover)))
        face))

    (defun luyangliuable/modeline-minor-mode-button (mode label)
      "Return clickable modeline LABEL for MODE."
      (let* ((active (luyangliuable/modeline-minor-mode-active-p mode))
             (face (if active
                       'luyangliuable-modeline-minor-mode
                     'luyangliuable-modeline-minor-mode-inactive))
             (index 0))
        (mapconcat
         (lambda (char)
           (let ((button
                  (propertize
                   (char-to-string char)
                   'face face
                   'mouse-face
                   (luyangliuable/modeline-minor-mode-hover-face
                    mode index active)
                   'help-echo (symbol-name mode)
                   'local-map
                   (let ((map (make-sparse-keymap)))
                     (define-key map [mode-line mouse-1]
                       (lambda ()
                         (interactive)
                         (luyangliuable/modeline-toggle-minor-mode mode)))
                     map))))
             (setq index (1+ index))
             button))
         (string-to-list label) "")))

    (defun luyangliuable/minor-mode-label (mode duplicate-firsts)
      "Return a compact circled label for MODE."
      (let* ((name (replace-regexp-in-string "-mode\\'" "" (symbol-name mode)))
             (chars (string-to-list (replace-regexp-in-string "[^[:alpha:]]" "" name)))
             (len (if (memq (car chars) duplicate-firsts) 2 1)))
        (mapconcat #'luyangliuable/circled-letter (seq-take chars len) "")))

    (doom-modeline-def-segment luyangliuable-minor-mode-circles
      (let* ((active-modes
              (luyangliuable/modeline-shown-minor-modes))
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
             (buttons (mapcar (lambda (mode)
                                (luyangliuable/modeline-minor-mode-button
                                 mode
                                 (luyangliuable/minor-mode-label
                                  mode duplicate-firsts)))
                              active-modes)))
        (when buttons
          (string-join buttons ""))))

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

  ;; Minimap configuration. Uses standalone `minimap', not Doom `demap'.
  (use-package! minimap
    :defer t
    :init
    (setq minimap-window-location 'right
          minimap-major-modes '(prog-mode))

    (defvar luyangliuable/minimap-debug nil)
    (defvar luyangliuable/minimap--last-buffer nil)
    (defvar luyangliuable/minimap--last-tick nil)
    (defvar luyangliuable/minimap--last-eligible nil)

    (defun luyangliuable/minimap-buffer-over-100-lines-p ()
      (save-excursion
        (goto-char (point-min))
        (forward-line 100)
        (not (eobp))))

    (defun luyangliuable/minimap-eligible-buffer-p ()
      (and buffer-file-name
           (not (minibufferp))
           (not (string= (buffer-name) " *MINIMAP*"))
           (luyangliuable/minimap-buffer-over-100-lines-p)))

    (defun luyangliuable/minimap-auto-sync ()
      (unless (or (active-minibuffer-window)
                  (minibufferp)
                  (string= (buffer-name) " *MINIMAP*"))
        (let ((buffer (current-buffer))
              (tick (buffer-chars-modified-tick)))
          (unless (and (eq buffer luyangliuable/minimap--last-buffer)
                       (eq tick luyangliuable/minimap--last-tick))
            (let* ((eligible (luyangliuable/minimap-eligible-buffer-p))
                   (buffer-changed
                    (not (eq buffer luyangliuable/minimap--last-buffer)))
                   (eligibility-changed
                    (not (eq eligible luyangliuable/minimap--last-eligible))))
              (setq luyangliuable/minimap--last-buffer buffer
                    luyangliuable/minimap--last-tick tick
                    luyangliuable/minimap--last-eligible eligible)
              (when luyangliuable/minimap-debug
                (message "minimap auto: buffer=%s eligible=%s active=%s"
                         (buffer-name) eligible
                         (bound-and-true-p minimap-mode)))
              (when (or buffer-changed eligibility-changed)
                (cond
                 (eligible
                  (add-to-list 'minimap-major-modes major-mode)
                  (unless (or (bound-and-true-p minimap-mode)
                              (memq 'minimap-mode
                                    (bound-and-true-p
                                     luyangliuable/modeline-minor-mode-button-disabled)))
                    (minimap-mode 1)))
                 ((bound-and-true-p minimap-mode)
                  (minimap-mode -1)))))))))

    (add-hook 'post-command-hook
              #'luyangliuable/minimap-auto-sync))

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
