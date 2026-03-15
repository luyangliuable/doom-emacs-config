;;; config/packages/projectile.el -*- lexical-binding: t; -*-
;; Projectile Package Configuration

;; Projectile configuration
(after! projectile
  ;; Add directories to ignore list
  (add-to-list 'projectile-globally-ignored-directories ".git")
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  ;; Add file suffixes to ignore
  (add-to-list 'projectile-globally-ignored-file-suffixes ".git")

  ;; Use ripgrep for project file indexing if available
  (when (executable-find "rg")
    (setq projectile-indexing-method 'alien)
    (setq projectile-enable-caching nil)
    (setq projectile-generic-command "rg --files --color=never --hidden")))