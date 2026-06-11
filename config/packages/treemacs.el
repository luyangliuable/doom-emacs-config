;;; config/packages/treemacs.el -*- lexical-binding: t; -*-
;; Treemacs Package Configuration

;; Note: Keybindings have been moved to config/keybindings/treemacs.el
;; This file now contains only configuration settings, no keybindings

;; Hide Treemacs' dedicated modeline.
(setq treemacs-user-mode-line-format 'none)

(add-hook 'treemacs-mode-hook
          (lambda ()
            (setq-local truncate-lines t)
            (setq-local word-wrap nil)))
