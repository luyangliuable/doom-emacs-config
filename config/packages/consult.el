;;; config/packages/consult.el -*- lexical-binding: t; -*-
;; Consult Package Configuration - Ripgrep Integration

(after! consult
  (when (executable-find "rg")
    ;; Use ripgrep for consult-grep
    (setq consult-grep-args "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --line-number --hidden .")

    ;; Use ripgrep for consult-ripgrep (explicit)
    (setq consult-ripgrep-args "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --search-zip --hidden")

    ;; Use ripgrep as default search backend
    (setq consult-find-args "rg --files --hidden"))

  ;; Configure preview delay (regardless of ripgrep availability)
  (setq consult-preview-key 'any))
