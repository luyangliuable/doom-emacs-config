;;; tests/notebook-config-test.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'python)
(require 'code-cells)
(require 'jupyter)

(ert-deftest luyangliuable-test/ipynb-files-use-code-cells-conversion ()
  (should (eq (cdr (assoc "\\.ipynb\\'" auto-mode-alist))
              #'code-cells-convert-ipynb)))

(ert-deftest luyangliuable-test/python-buffers-enable-code-cells-when-needed ()
  (should (memq #'code-cells-mode-maybe python-mode-hook))
  (should (memq #'code-cells-mode-maybe python-ts-mode-hook)))

(ert-deftest luyangliuable-test/notebooks-use-jupytext-conversion ()
  (should (equal (caar code-cells-convert-ipynb-style) "jupytext"))
  (should (equal (caadr code-cells-convert-ipynb-style) "jupytext")))

(ert-deftest luyangliuable-test/notebook-eval-starts-jupyter-when-unassociated ()
  (let (startup-prefix eval-prefix evaluated-in)
    (save-window-excursion
      (with-temp-buffer
        (switch-to-buffer (current-buffer))
        (python-mode)
        (code-cells-mode 1)
        (let ((source-buffer (current-buffer))
              (source-window (selected-window))
              (jupyter-repl-interaction-mode nil)
              (current-prefix-arg 4))
          (cl-letf (((symbol-function 'jupyter-run-repl)
                     (lambda ()
                       (interactive)
                       (setq startup-prefix current-prefix-arg
                             jupyter-repl-interaction-mode t)
                       (switch-to-buffer (get-buffer-create "*mock-jupyter-repl*"))))
                    ((symbol-function 'code-cells-eval)
                     (lambda (&rest _)
                       (interactive)
                       (setq eval-prefix current-prefix-arg
                             evaluated-in (current-buffer)))))
            (call-interactively #'luyangliuable/notebook-eval-cell))
          (should (eq evaluated-in source-buffer))
          (should (eq (window-buffer source-window) source-buffer)))))
    (should-not startup-prefix)
    (should (equal eval-prefix 4))
    (when-let ((buffer (get-buffer "*mock-jupyter-repl*")))
      (kill-buffer buffer))))

(ert-deftest luyangliuable-test/notebook-localleader-bindings ()
  (dolist (binding '(("r" . jupyter-run-repl)
                     ("a" . jupyter-repl-associate-buffer)
                     ("e" . luyangliuable/notebook-eval-cell)
                     ("E" . luyangliuable/notebook-eval-cell-and-step)
                     ("b" . luyangliuable/notebook-eval-buffer)
                     ("n" . code-cells-forward-cell)
                     ("p" . code-cells-backward-cell)
                     ("i" . jupyter-repl-interrupt-kernel)
                     ("R" . jupyter-repl-restart-kernel)))
    (should (eq (lookup-key
                 (evil-get-auxiliary-keymap code-cells-mode-map 'normal t)
                 (kbd (format "%s c %s"
                              doom-localleader-key
                              (car binding))))
                (cdr binding)))))
