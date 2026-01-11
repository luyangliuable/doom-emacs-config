;; Treemacs mode keybindings - override leader gs to use treemacs-aware magit
(map! :map treemacs-mode-map
      :leader
      :desc "magit with treemacs directory" "gs" #'luyangliuable/treemacs-magit-here)
