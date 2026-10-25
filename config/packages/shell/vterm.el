;;; config/packages/vterm.el -*- lexical-binding: t; -*-
;; Project terminals backed by vterm.

(declare-function projectile-run-vterm "projectile")
(declare-function vterm "vterm")
(declare-function doom-project-root "doom-lib")
(declare-function treemacs-current-button "treemacs-core-utils")
(declare-function treemacs-button-get "treemacs-core-utils")
(declare-function luyangliuable/split-window-right-and-run-callback "functions")
(declare-function luyangliuable/split-window-below-and-run-callback "functions")

(defun luyangliuable/project-vterm (&optional new)
  "Open the project's vterm in the selected window.
With NEW non-nil, always create a fresh vterm buffer."
  (interactive "P")
  ;; Bypass Doom's "^\\*vterm" popup rule so the terminal uses the current window.
  (let ((display-buffer-alist nil))
    (projectile-run-vterm new)))

(defun luyangliuable/project-vterm-new ()
  "Open a fresh vterm for the current project in the selected window."
  (interactive)
  (luyangliuable/project-vterm t))

(defun luyangliuable/project-vterm-new-split ()
  "Open a fresh project vterm in a new window split to the right."
  (interactive)
  (luyangliuable/split-window-right-and-run-callback #'luyangliuable/project-vterm-new))

(defun luyangliuable/vterm--target-directory ()
  "Return the treemacs node directory, project root, or `default-directory'."
  (or (condition-case err
          (cond
           ((and (eq major-mode 'treemacs-mode)
                 (treemacs-current-button))
            (let ((node (treemacs-button-get (treemacs-current-button) :path)))
              (when (stringp node)
                (if (file-directory-p node) node (file-name-directory node)))))
           ((doom-project-root))
           (t default-directory))
        (error
         (message "Treemacs error, using fallback directory: %s" (error-message-string err))
         (doom-project-root)))
      default-directory))

(defun luyangliuable/treemacs-vterm-here-horizontal ()
  "Open a vterm below, in the treemacs node directory or project root."
  (interactive)
  (let* ((target-dir (file-name-as-directory (luyangliuable/vterm--target-directory)))
         (buffer-name (generate-new-buffer-name
                       (format "*vterm %s*"
                               (file-name-nondirectory (directory-file-name target-dir))))))
    (luyangliuable/split-window-below-and-run-callback
     (lambda ()
       (let ((default-directory target-dir)
             (display-buffer-alist nil))
         (vterm buffer-name))))))
