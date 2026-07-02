;;; persistent-scratch.el --- Persistent scratch buffer -*- lexical-binding: t; -*-

(use-package! persistent-scratch
  :init
  (setq persistent-scratch-save-file
        (expand-file-name ".persistent-scratch" doom-cache-dir))
  :config
  (make-directory (file-name-directory persistent-scratch-save-file) t)
  (unless (file-exists-p persistent-scratch-save-file)
    (with-temp-file persistent-scratch-save-file
      (insert "nil\n")))
  (setq persistent-scratch-autosave-interval 300)
  (persistent-scratch-setup-default))
