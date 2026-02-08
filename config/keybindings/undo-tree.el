;;; config/keybindings/undo-tree.el -*- lexical-binding: t; -*-
;; Undo Tree Keybindings

(map! :map undo-tree-mode
      :leader
      :desc "undo tree" "au" #'undo-tree-visualize)
