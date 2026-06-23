;;; config/packages/latex-preview.el -*- lexical-binding: t; -*-
;; LaTeX/math preview support for Org and Markdown buffers.

(after! org
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.6))
  (setq org-startup-with-latex-preview nil)
  (map! :map org-mode-map
        :localleader
        :desc "Preview LaTeX fragment" "l" #'org-latex-preview))

(use-package! math-preview
  :defer t)

(after! markdown-mode
  (setq markdown-enable-math t)
  (map! :map markdown-mode-map
        :localleader
        :desc "Preview math at point" "l" #'math-preview-at-point
        :desc "Preview all math" "L" #'math-preview-all)
  (map! :map gfm-mode-map
        :localleader
        :desc "Align table" "ta" #'markdown-table-align))
