;;; config/ui.el -*- lexical-binding: t; -*-
;; UI Package Configurations

;;; ============================================================================
;;; UI CONFIGURATION
;;; ============================================================================

;; Doom modeline customization
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

;; Beacon - highlight cursor position on big movements
(use-package! beacon
  :ensure t
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

;; Minimap configuration
(use-package! minimap
  :ensure t
  :init
  (setq minimap-window-location 'right) ;; Position minimap on the right
  :config)

;; Good scroll - smooth scrolling
(use-package good-scroll
  :ensure t
  :config
  ;; Smooth scrolling settings
  (setq good-scroll-duration 0.1) ;; Set a faster duration for scrolling
  (setq good-scroll-amount 3)     ;; Set the amount of lines to scroll at a time
  (setq good-scroll-algorithm #'good-scroll-linear) ;; Use a linear scrolling algorithm

  ;; Disabled due to poor performance
  (good-scroll-mode 1))

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

;; Apply breadcrumb to file buffers
(add-hook 'find-file-hook #'my/set-header-line-breadcrumb)
(add-hook 'after-change-major-mode-hook #'my/set-header-line-breadcrumb)