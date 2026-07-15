;;; config/ui.el -*- lexical-binding: t; -*-
;; Package-agnostic UI behaviors.
;; Per-package UI configs live in config/packages/ (doom-modeline, beacon,
;; minimap, good-scroll, bongo-cat-mode, minor-mode-badges).

;;; ============================================================================
;;; UI BEHAVIORS
;;; ============================================================================

;; zoom in on find file so default file text size is bigger
;; (dolist (hook '(find-file-hook magit-mode-hook shell-mode-hook fundamental-mode-hook))
;;   (add-hook hook (lambda () (text-scale-increase 3))))
(defvar my-scaled-mode-exclusions '(treemacs-mode magit-diff-mode +doom-dashboard-mode))

(add-hook 'change-major-mode-after-body-hook
  (lambda ()
    (unless (apply #'derived-mode-p my-scaled-mode-exclusions)
      (text-scale-increase 3))))

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
(add-hook 'after-change-major-mode-hook #'my/set-header-line-breadcrumb)
