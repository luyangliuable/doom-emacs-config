;;; config/keybindings/magit.el -*- lexical-binding: t; -*-
;; Magit Mode Keybindings - Standalone after! blocks only

;; Override magit quit function to handle window cleanup properly
(after! magit
  (define-key magit-mode-map "q" #'luyangliuable/magit-quit))

;; Also handle evil-collection-magit if it's loaded
(after! evil-collection-magit
  (map! :map magit-mode-map :nv "q" #'luyangliuable/magit-quit))
