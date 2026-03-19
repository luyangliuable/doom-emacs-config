;;; config/keybindings/emacs-lisp.el -*- lexical-binding: t; -*-
;; Emacs Lisp Mode Keybindings

(map! :map emacs-lisp-mode-map
      :localleader
      :desc "flycheck-errors-list" "ge" #'flycheck-list-errors)
