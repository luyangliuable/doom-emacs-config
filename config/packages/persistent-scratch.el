;;; persistent-scratch.el --- Persistent scratch buffer -*- lexical-binding: t; -*-

(use-package! persistent-scratch
  :config
  (persistent-scratch-setup-default)
  (setq persistent-scratch-save-file
        (expand-file-name "persistent-scratch" doom-local-dir))
  (setq persistent-scratch-autosave-interval 300))

(persistent-scratch-autosave-mode 1)
