;;; config/keybindings/magit.el -*- lexical-binding: t; -*-
;; Magit Mode Keybindings - Standalone after! blocks only

;; Override magit quit function to handle window cleanup properly
(with-eval-after-load 'magit
  (define-key magit-mode-map "q" #'luyangliuable/magit-quit))

;; Also handle evil-collection-magit if it's loaded
(with-eval-after-load 'evil-collection-magit
  (with-eval-after-load 'magit
    (define-key magit-mode-map (kbd "q") #'luyangliuable/magit-quit)))
