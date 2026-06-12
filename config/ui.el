;;; config/ui.el -*- lexical-binding: t; -*-
;; UI Package Configurations

;;; ============================================================================
;;; UI CONFIGURATION
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

  ;; Beacon - highlight cursor position on big movements
  ;; Lazy load after 5 seconds to improve startup performance
  (use-package! beacon
    :defer 5
    :ensure t
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
  ;; Lazy load after 10 seconds - use M-x minimap-mode when needed
  (use-package! minimap
    :defer 10
    :ensure t
    :init
    (setq minimap-window-location 'right) ;; Position minimap on the right
    :config
    (defun luyangliuable/minimap-for-long-files ()
      (when (and buffer-file-name
              (> (count-lines (point-min) (point-max)) 100))
        (minimap-mode 1)))

    (add-hook 'find-file-hook #'luyangliuable/minimap-for-long-files))


  ;; zoom in on find file so default file text size is bigger
  ;; (dolist (hook '(find-file-hook magit-mode-hook shell-mode-hook fundamental-mode-hook))
  ;;   (add-hook hook (lambda () (text-scale-increase 3))))
  (add-hook 'change-major-mode-after-body-hook
    (lambda ()
      (unless (derived-mode-p 'treemacs-mode)
        (text-scale-increase 3))))

  ;; Good scroll - smooth scrolling
  ;; Lazy load after 3 seconds with optimized settings
  (use-package good-scroll
    :defer 3
    :ensure t
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
