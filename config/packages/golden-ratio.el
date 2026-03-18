;;; config/packages/golden-ratio.el -*- lexical-binding: t; -*-

(use-package! golden-ratio
  :defer t
  :config
  (setq golden-ratio-exclude-modes '(ediff-mode
                                      treemacs-mode
                                      dired-mode))
  (setq golden-ratio-extra-commands '(evil-window-left
                                       evil-window-right
                                       evil-window-up
                                       evil-window-down)))
