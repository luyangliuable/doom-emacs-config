;;; tests/markdown-keybindings-test.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'markdown-mode)

(defun markdown-keybindings-test--binding (mode keys)
  "Return the normal-state command bound to localleader KEYS in a MODE buffer."
  (with-temp-buffer
    (delay-mode-hooks (funcall mode))
    (evil-local-mode 1)
    (evil-normal-state)
    (key-binding (kbd (concat doom-localleader-key " " keys)))))

(ert-deftest luyangliuable-test/markdown-insert-keys-follow-spacemacs ()
  (dolist (mode '(markdown-mode gfm-mode))
    (should (equal (list mode
                         (markdown-keybindings-test--binding mode "i T")
                         (markdown-keybindings-test--binding mode "i t"))
                   (list mode #'markdown-insert-table #'markdown-toc-generate-toc)))))
