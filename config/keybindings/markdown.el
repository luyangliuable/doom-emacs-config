;;; config/keybindings/markdown.el -*- lexical-binding: t; -*-
;; Markdown Mode Keybindings

;; Spacemacs layout; Doom binds these two the other way round.
(after! markdown-mode
  (map! :map markdown-mode-map
        :localleader
        (:prefix ("i" . "insert")
         :desc "Table of contents" "t" #'markdown-toc-generate-toc
         :desc "Table"             "T" #'markdown-insert-table)))
