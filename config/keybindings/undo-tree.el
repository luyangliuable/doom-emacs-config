;;; config/keybindings/undo-tree.el -*- lexical-binding: t; -*-
;; Undo Tree Keybindings

(map! :leader
  :desc "narrow to region" "nr" #'narrow-to-region
  :desc "Kill gptel session" "np" #'widen)
