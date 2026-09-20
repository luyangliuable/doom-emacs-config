;;; tests/treemacs-keybindings-test.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'treemacs)

(ert-deftest luyangliuable-test/treemacs-add-project-keybinding-is-consistent ()
  (let ((command #'luyangliuable/treemacs-add-project-to-current-workspace))
    (should (eq (lookup-key global-map (kbd "C-c C-p a")) command))
    (should (eq (lookup-key treemacs-mode-map (kbd "C-c C-p a")) command))))
