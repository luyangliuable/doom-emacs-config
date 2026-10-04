;;; config/packages/notebook.el -*- lexical-binding: t; -*-
;; Edit Jupyter notebooks as Python cells and evaluate them in a Jupyter REPL.

(use-package! jupyter
  :commands (jupyter-run-repl
             jupyter-repl-associate-buffer
             jupyter-repl-interrupt-kernel
             jupyter-repl-restart-kernel))

(defun luyangliuable/notebook-ensure-jupyter-repl ()
  "Start and associate a Jupyter REPL when this buffer has none."
  (unless (bound-and-true-p jupyter-repl-interaction-mode)
    (let ((current-prefix-arg nil))
      (save-window-excursion
        (save-current-buffer
          (call-interactively #'jupyter-run-repl)))))
  (unless (bound-and-true-p jupyter-repl-interaction-mode)
    (user-error "No Jupyter REPL associated with this notebook")))

(defun luyangliuable/notebook-eval-cell ()
  "Evaluate the current cell, starting a Jupyter REPL if needed."
  (interactive)
  (luyangliuable/notebook-ensure-jupyter-repl)
  (call-interactively #'code-cells-eval))

(defun luyangliuable/notebook-eval-cell-and-step ()
  "Evaluate the current cell and advance, starting Jupyter if needed."
  (interactive)
  (luyangliuable/notebook-ensure-jupyter-repl)
  (call-interactively #'code-cells-eval-and-step))

(defun luyangliuable/notebook-eval-buffer ()
  "Evaluate all cells, starting a Jupyter REPL if needed."
  (interactive)
  (luyangliuable/notebook-ensure-jupyter-repl)
  (call-interactively #'code-cells-eval-whole-buffer))

(defun luyangliuable/notebook-eval-above ()
  "Evaluate cells above point, starting a Jupyter REPL if needed."
  (interactive)
  (luyangliuable/notebook-ensure-jupyter-repl)
  (call-interactively #'code-cells-eval-above))

(use-package! code-cells
  :mode ("\\.ipynb\\'" . code-cells-convert-ipynb)
  :hook ((python-mode python-ts-mode) . code-cells-mode-maybe)
  :config
  (keymap-set code-cells--prefix-map "e" #'luyangliuable/notebook-eval-cell)
  (keymap-set code-cells--prefix-map "s" #'luyangliuable/notebook-eval-cell-and-step)
  (keymap-set code-cells--prefix-map "a" #'luyangliuable/notebook-eval-above)
  (map! :map code-cells-mode-map
        :localleader
        (:prefix ("c" . "cells")
         :desc "Start Jupyter REPL" "r" #'jupyter-run-repl
         :desc "Associate Jupyter REPL" "a" #'jupyter-repl-associate-buffer
         :desc "Evaluate cell" "e" #'luyangliuable/notebook-eval-cell
         :desc "Evaluate cell and step" "E" #'luyangliuable/notebook-eval-cell-and-step
         :desc "Evaluate all cells" "b" #'luyangliuable/notebook-eval-buffer
         :desc "Next cell" "n" #'code-cells-forward-cell
         :desc "Previous cell" "p" #'code-cells-backward-cell
         :desc "Interrupt kernel" "i" #'jupyter-repl-interrupt-kernel
         :desc "Restart kernel" "R" #'jupyter-repl-restart-kernel)))
