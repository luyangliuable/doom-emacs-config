;;; lisp/core/ui.el -*- lexical-binding: t; -*-
;; UI Configuration and Theme Management

;;; ============================================================================
;;; THEME CONFIGURATION (OPTIMIZED: Cached time calculation)
;;; ============================================================================

(defvar luyangliuable/themes
  '(frutiger-aero
    doom-zenburn
    doom-nord
    doom-solarized-light
    doom-solarized-dark
    doom-challenger-deep
    doom-one
    doom-plain
    doom-plain-dark)
  "List of available themes to cycle through.")

;; Cache theme selection based on time of day (calculated once at startup)
(defvar luyangliuable--cached-theme-time nil
  "Cached hour when theme was selected.")
(defvar luyangliuable--cached-theme nil
  "Cached theme selection.")

(let* ((current-hour (nth 2 (decode-time)))
       (is-night (or (< current-hour 6) (>= current-hour 20))))
  (setq luyangliuable--cached-theme-time current-hour
        luyangliuable--cached-theme (if is-night 'doom-solarized-dark 'doom-solarized-light)
        doom-theme luyangliuable--cached-theme
        luyangliuable/current-theme-index (if is-night 4 3))
  (message (if is-night "Good evening!" "Good day!")))

(load-theme doom-theme t)

;;; Theme Management

;; Disable other themes before loading new one
(defadvice load-theme (before theme-dont-propagate activate)
  "Disable theme before loading new one."
  (mapc #'disable-theme custom-enabled-themes))

(defun luyangliuable/cycle-theme-next ()
  "Cycle to the next theme."
  (interactive)
  (setq luyangliuable/current-theme-index
        (mod (1+ luyangliuable/current-theme-index)
             (length luyangliuable/themes)))
  (let ((theme (nth luyangliuable/current-theme-index luyangliuable/themes)))
    (load-theme theme t)
    (message "Loaded theme: %s (press 'n' for next, 'N' for previous)" theme))
  (set-transient-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "n") #'luyangliuable/cycle-theme-next)
     (define-key map (kbd "N") #'luyangliuable/cycle-theme-previous)
     map)
   t))

(defun luyangliuable/cycle-theme-previous ()
  "Cycle to the previous theme."
  (interactive)
  (setq luyangliuable/current-theme-index
        (mod (1- luyangliuable/current-theme-index)
             (length luyangliuable/themes)))
  (let ((theme (nth luyangliuable/current-theme-index luyangliuable/themes)))
    (load-theme theme t)
    (message "Loaded theme: %s (press 'n' for next, 'N' for previous)" theme))
  (set-transient-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "n") #'luyangliuable/cycle-theme-next)
     (define-key map (kbd "N") #'luyangliuable/cycle-theme-previous)
     map)
   t))

;;; Keybindings

(map!
 :leader
 :desc "cycle theme next"     "Tn" #'luyangliuable/cycle-theme-next
 :desc "cycle theme previous" "TN" #'luyangliuable/cycle-theme-previous)

;;; ============================================================================
;;; UI PACKAGES (OPTIMIZED: Lazy-loading, deferred activation)
;;; ============================================================================

;; Doom modeline customization
(progn
  (use-package! doom-modeline
    :ensure t
    :init
    (setq doom-modeline-hud t) ;; Enable the HUD feature

    ;; Modeline appearance settings
    (setq doom-modeline-height 28
          doom-modeline-icon t
          doom-modeline-buffer-encoding t
          doom-modeline-project-detection 'projectile
          doom-modeline-buffer-file-name-style nil ;; Disable file path in modeline
          doom-modeline-minor-modes nil
          doom-modeline-major-mode-icon t
          doom-modeline-major-mode t
          doom-modeline-linenumber t
          doom-modeline-bar-width 6)

    :config
    (doom-modeline-mode 1))

  ;; Beacon - highlight cursor position on big movements (OPTIMIZED: Deferred loading)
  (use-package! beacon
    :ensure t
    :defer t
    :hook ((window-scroll-functions . beacon-mode)
           (window-configuration-change-hook . beacon-mode))
    :init
    ;; Beacon appearance settings
    (setq beacon-blink-duration 0.8       ;; Duration of the blink
          beacon-blink-delay 0.3          ;; Delay before the blink starts
          beacon-size 40                  ;; Size of the beacon
          beacon-color "#ff9d00"          ;; Color of the beacon
          beacon-push-mark 35             ;; Number of moves before pushing a new mark onto the ring
          beacon-dont-blink-commands '() ;; Commands that won't trigger a blink
          beacon-blink-when-buffer-changes t  ;; Blink when switching buffers
          beacon-blink-when-window-changes t  ;; Blink when switching windows
          beacon-blink-when-point-moves t     ;; Blink when point moves
          beacon-blink-when-window-scrolls t  ;; Blink when window scrolls
          beacon-blink-when-focused t)        ;; Blink when the frame gains focus
    :config
    (beacon-mode 1))

  ;; Minimap configuration (OPTIMIZED: Not auto-enabled, toggle with SPC t m M)
  (use-package! minimap
    :ensure t
    :defer t
    :commands (minimap-mode)
    :init
    (setq minimap-window-location 'right) ;; Position minimap on the right
    :config
    (message "Minimap available - toggle with SPC t m M"))

  ;; Good scroll - smooth scrolling (OPTIMIZED: Lazy-loaded after idle)
  (use-package good-scroll
    :ensure t
    :defer t
    :init
    ;; Smooth scrolling settings (set before loading)
    (setq good-scroll-duration 0.1) ;; Set a faster duration for scrolling
    (setq good-scroll-amount 3)     ;; Set the amount of lines to scroll at a time
    (setq good-scroll-algorithm #'good-scroll-linear) ;; Use a linear scrolling algorithm
    ;; Enable after 2 seconds of idle time to avoid startup lag
    (run-with-idle-timer 2 nil #'good-scroll-mode)
    :config
    (message "Good-scroll loaded after idle timer"))

  ;; Global breadcrumb navigation for all files (non-LSP files)
  (defun my/set-header-line-breadcrumb ()
    "Set header line breadcrumb for file buffers only."
    (when (and buffer-file-name
               (file-exists-p buffer-file-name)
               (not (string-match-p "^\\*" (buffer-name)))
               (not (string-match-p "^magit" (buffer-name)))
               (not (derived-mode-p 'special-mode))
               (not (derived-mode-p 'help-mode))
               (not (derived-mode-p 'compilation-mode)))
      (let ((project-root (and (featurep 'projectile) (projectile-project-root)))
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

  ;; Apply breadcrumb to file buffers (OPTIMIZED: Deferred to after-init-hook)
  (add-hook 'after-init-hook
    (lambda ()
      (add-hook 'find-file-hook #'my/set-header-line-breadcrumb)
      (add-hook 'after-change-major-mode-hook #'my/set-header-line-breadcrumb))))

(provide 'ui)
;;; ui.el ends here
