;;; tests/vterm-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defconst luyangliuable-test/vterm-config-file
  (expand-file-name "../config/packages/vterm.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defconst luyangliuable-test/keybindings-file
  (expand-file-name "../config/keybindings.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(load luyangliuable-test/vterm-config-file nil t)

(ert-deftest luyangliuable-test/project-vterm-bypasses-popup-rules ()
  (let ((display-buffer-alist '(("^\\*vterm" (display-buffer-in-side-window))))
        seen)
    (cl-letf (((symbol-function 'projectile-run-vterm)
               (lambda (&optional arg)
                 (setq seen (list arg display-buffer-alist)))))
      (luyangliuable/project-vterm)
      (should (equal seen '(nil nil)))
      (luyangliuable/project-vterm t)
      (should (equal seen '(t nil))))))

(ert-deftest luyangliuable-test/project-vterm-new-forces-new-buffer ()
  (let (arg-seen)
    (cl-letf (((symbol-function 'projectile-run-vterm)
               (lambda (&optional arg) (setq arg-seen arg))))
      (luyangliuable/project-vterm-new)
      (should arg-seen))))

(ert-deftest luyangliuable-test/project-vterm-new-split-uses-right-split ()
  (let (callback)
    (cl-letf (((symbol-function 'luyangliuable/split-window-right-and-run-callback)
               (lambda (fn) (setq callback fn))))
      (luyangliuable/project-vterm-new-split)
      (should (eq callback #'luyangliuable/project-vterm-new)))))

(ert-deftest luyangliuable-test/treemacs-vterm-here-opens-in-project-root ()
  (let ((root (file-name-as-directory temporary-file-directory))
        (display-buffer-alist '(("^\\*vterm" (display-buffer-in-side-window))))
        seen)
    (cl-letf (((symbol-function 'doom-project-root) (lambda (&rest _) root))
              ((symbol-function 'luyangliuable/split-window-below-and-run-callback)
               (lambda (fn) (funcall fn)))
              ((symbol-function 'vterm)
               (lambda (&optional name)
                 (setq seen (list name default-directory display-buffer-alist)))))
      (with-temp-buffer
        (luyangliuable/treemacs-vterm-here-horizontal))
      (should (string-prefix-p "*vterm " (nth 0 seen)))
      (should (equal (nth 1 seen) root))
      (should (null (nth 2 seen))))))

(ert-deftest luyangliuable-test/project-terminal-keys-use-vterm ()
  (let ((source (with-temp-buffer
                  (insert-file-contents luyangliuable-test/keybindings-file)
                  (buffer-string))))
    (should-not (string-match-p "projectile-run-shell" source))
    (should-not (string-match-p "new-shell-for-project" source))
    (should-not (string-match-p "treemacs-shell-here-horizontal" source))
    (dolist (key '("p$." "p$v" "p$s" "p$V" "p$S"))
      (should (string-match-p
               (format "\"%s\" .*luyangliuable/project-vterm\\b" (regexp-quote key))
               source)))
    (dolist (key '("p!." "p!v" "p!s" "p!V" "p!S"))
      (should (string-match-p
               (format "\"%s\" .*luyangliuable/project-vterm-new" (regexp-quote key))
               source)))))

;;; vterm-config-test.el ends here
