;;; config/keybindings/emacs-lisp.el -*- lexical-binding: t; -*-
;; Emacs Lisp Mode Keybindings

(defun luyangliuable/prettier-elisp ()
  "Format current defun with prettier-elisp."
  (interactive)
  (if (require 'prettier-elisp nil t)
      (call-interactively #'prettier-elisp)
    (user-error "prettier-elisp is unavailable; run doom sync")))

(defun luyangliuable/prettier-elisp-buffer ()
  "Format current buffer with prettier-elisp."
  (interactive)
  (if (require 'prettier-elisp nil t)
      (call-interactively #'prettier-elisp-buffer)
    (user-error "prettier-elisp-buffer is unavailable; run doom sync")))

(defun luyangliuable/prettier-elisp-mode ()
  "Toggle prettier-elisp defun formatting on save."
  (interactive)
  (if (require 'prettier-elisp nil t)
      (call-interactively #'prettier-elisp-mode)
    (user-error "prettier-elisp-mode is unavailable; run doom sync")))

(defun luyangliuable/prettier-elisp-buffer-mode ()
  "Toggle prettier-elisp buffer formatting on save."
  (interactive)
  (if (require 'prettier-elisp nil t)
      (call-interactively #'prettier-elisp-buffer-mode)
    (user-error "prettier-elisp-buffer-mode is unavailable; run doom sync")))

(map! :map emacs-lisp-mode-map
      :localleader
      :desc "flycheck-errors-list" "ge" #'flycheck-list-errors
      (:prefix ("f" . "format")
       :desc "format defun" "d" #'luyangliuable/prettier-elisp
       :desc "format defun" "f" #'luyangliuable/prettier-elisp
       :desc "format buffer" "b" #'luyangliuable/prettier-elisp-buffer
       :desc "format defun on save" "m" #'luyangliuable/prettier-elisp-mode
       :desc "format buffer on save" "M" #'luyangliuable/prettier-elisp-buffer-mode))
