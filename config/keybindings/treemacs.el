;;; config/keybindings/treemacs.el -*- lexical-binding: t; -*-
;; Treemacs Keybindings

;; Treemacs mode keybindings - override leader gs to use treemacs-aware magit
(defun luyangliuable/treemacs-add-project-to-current-workspace ()
  "Add a project to the active Treemacs workspace and display its tree."
  (interactive)
  (require 'treemacs)
  (call-interactively #'treemacs-add-project-to-workspace)
  (unless (derived-mode-p 'treemacs-mode)
    (treemacs-select-window)))

(after! treemacs
  (global-set-key (kbd "C-c C-p a")
                  #'luyangliuable/treemacs-add-project-to-current-workspace)
  (define-key treemacs-mode-map (kbd "C-c C-p a")
              #'luyangliuable/treemacs-add-project-to-current-workspace))

(map! :map treemacs-mode-map
      :leader
      :desc "magit with treemacs directory" "gs" #'luyangliuable/treemacs-magit-here)
