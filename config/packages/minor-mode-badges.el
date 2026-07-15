;;; config/packages/minor-mode-badges.el -*- lexical-binding: t; -*-
;; Active minor modes rendered as clickable badges in the doom-modeline.
;; config/packages/doom-modeline.el defines the segment before layout setup;
;; this file sets modes early and refreshes the segment after package load.

(use-package! minor-mode-badges
  :demand t
  :init
  (setq minor-mode-badges-modes
    '(yas-minor-mode
       smartparens-mode
       minimap-mode
       company-mode
       flycheck-mode
       projectile-mode
       magit-auto-revert-mode
       auto-highlight-symbol-mode
       good-scroll-mode
       beacon-mode))
  :config
  (minor-mode-badges-setup-doom-modeline)
  (force-mode-line-update t))
