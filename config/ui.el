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

(defun my/apply-buffer-text-scale ()
  "Apply the configured text scale after a major mode initializes."
  (unless (apply #'derived-mode-p my-scaled-mode-exclusions)
    (text-scale-set 3)))

(add-hook 'after-change-major-mode-hook #'my/apply-buffer-text-scale)

;; Global breadcrumb navigation for all files (non-LSP files)
;; Optimized version with project root caching
(defun my/disable-inactive-lsp-headerline-breadcrumb ()
  "Disable LSP's buffer-local breadcrumb when `lsp-mode' is inactive."
  (when (and (not (bound-and-true-p lsp-mode))
             (fboundp 'lsp-headerline-breadcrumb-mode)
             (bound-and-true-p lsp-headerline-breadcrumb-mode))
    (lsp-headerline-breadcrumb-mode -1)))

(defun my/set-header-line-breadcrumb ()
  "Set header line breadcrumb for file buffers only."
  (my/disable-inactive-lsp-headerline-breadcrumb)
  (when (and buffer-file-name
          (file-exists-p buffer-file-name)
          (not (string-match-p "^\\*" (buffer-name)))
          (not (string-match-p "^magit" (buffer-name)))
          (not (string-match-p "^\\*scratch\\*" (buffer-name)))
          (not (bound-and-true-p lsp-mode))
          (not (bound-and-true-p lsp-managed-mode))
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
          (propertize " "
            'display '(space
                        :align-to 0
                        :height 1.2
                        :width 1.5
                        :ascent center)
            'my/header-line-breadcrumb t)
          (when project-root
            (propertize (file-name-nondirectory (directory-file-name project-root))
              'face 'font-lock-string-face))
          (when project-root " > ")
          (propertize (if project-root
                        (file-relative-name file-path project-root)
                        (abbreviate-file-name file-path))
            'face 'font-lock-comment-face)
          (propertize file-name 'face 'mode-line-buffer-id))))))

(defun my/update-header-line-breadcrumb-for-lsp ()
  "Let LSP own the header line while `lsp-mode' is active."
  (if (bound-and-true-p lsp-mode)
    (when (and (stringp header-line-format)
            (get-text-property 0 'my/header-line-breadcrumb
              header-line-format))
      (setq-local header-line-format nil))
    (my/set-header-line-breadcrumb)))

;; Apply breadcrumb to file buffers
(add-hook 'find-file-hook #'my/set-header-line-breadcrumb)
(add-hook 'after-change-major-mode-hook #'my/set-header-line-breadcrumb)
(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'my/update-header-line-breadcrumb-for-lsp)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (my/disable-inactive-lsp-headerline-breadcrumb))))

;; Configure the first GUI frame directly because frame alists are applied
;; before this late-loaded user configuration.
(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(undecorated . t))

  (defvar luyangliuable/startup-frame-configured nil
    "Whether the initial GUI frame has entered fullscreen.")

  (defun luyangliuable/activate-startup-frame (&optional frame)
    "Focus FRAME and enter native fullscreen once at startup."
    (let ((frame (or frame (selected-frame))))
      (when (and (not luyangliuable/startup-frame-configured)
                 (frame-live-p frame)
                 (display-graphic-p frame))
        (set-frame-parameter frame 'fullscreen 'fullboth)
        (setq luyangliuable/startup-frame-configured t)
        (select-frame-set-input-focus frame)
        (raise-frame frame))))

  (add-hook 'doom-init-ui-hook #'luyangliuable/activate-startup-frame t)
  (add-hook 'server-after-make-frame-hook
            #'luyangliuable/activate-startup-frame t))
