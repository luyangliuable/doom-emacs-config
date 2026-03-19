;;; lisp/functions/magit.el -*- lexical-binding: t; -*-
;; Magit and shell integration functions (require magit to be loaded)

(after! magit
  (defun luyangliuable/magit ()
  "Smart magit function that refreshes if already in magit-status-mode, otherwise opens magit in a split window."
  (interactive)
  (if (eq major-mode 'magit-status-mode)
      ;; If already in magit-status-mode, just refresh
      (magit-refresh)
    ;; Otherwise, open magit in a split window and mark it for cleanup
    (let ((original-window (selected-window)))
      (luyangliuable/split-window-right-and-run-callback #'magit)
      ;; Store the original window for cleanup purposes
      (with-current-buffer (magit-get-mode-buffer 'magit-status-mode)
        (setq-local luyangliuable--magit-original-window original-window)))))

(defun luyangliuable/magit-quit ()
  "Custom magit quit function that properly handles split window cleanup."
  (interactive)
  (let ((magit-window (selected-window))
        (magit-buffer (current-buffer))
        (original-window (when (local-variable-p 'luyangliuable--magit-original-window)
                           luyangliuable--magit-original-window)))

    ;; Store values before calling +magit/quit which might change the buffer context
    (let ((should-cleanup (and original-window
                               (window-live-p original-window)
                               (not (eq magit-window original-window))
                               (> (length (window-list)) 1)))) ;; Don't delete if it's the only window

      ;; Call the standard Doom magit quit function
      (+magit/quit)

      ;; If we should clean up and the magit window still exists, do the cleanup
      (when (and should-cleanup (window-live-p magit-window))
        (delete-window magit-window)
        (select-window original-window)))))

(defun luyangliuable/treemacs-magit-here ()
  "Open magit in the directory of the current treemacs node, or project root if not in treemacs."
  (interactive)
  (let ((target-dir
         (condition-case err
             (cond
              ;; If we're in treemacs, get the directory of the current node
              ((and (eq major-mode 'treemacs-mode)
                    (treemacs-current-button))
               (let* ((button (treemacs-current-button))
                      (node (when button (treemacs-button-get button :path))))
                 (when node
                   (if (file-directory-p node)
                       node
                     (file-name-directory node)))))
              ;; If we have a project root, use that
              ((doom-project-root) (doom-project-root))
              ;; Otherwise use current directory
              (t default-directory))
           ;; If there's any error with treemacs, fall back to project root or default
           (error
            (message "Treemacs error, using fallback directory: %s" (error-message-string err))
            (or (doom-project-root) default-directory)))))

    ;; Ensure we have a valid directory
    (setq target-dir (or target-dir default-directory))
    (message "Opening magit in: %s" target-dir)

    ;; Check if already in magit-status-mode in the target directory
    (if (and (eq major-mode 'magit-status-mode)
             (let ((current-repo (magit-toplevel))
                   (target-repo (magit-toplevel target-dir)))
               (and current-repo target-repo
                    (string= (file-truename current-repo) (file-truename target-repo)))))
        ;; If already in magit-status-mode in the same repository, just refresh
        (magit-refresh)
      ;; Otherwise, open magit in a split window for the target directory
      (let ((original-window (selected-window)))
        (luyangliuable/split-window-right-and-run-callback
         (lambda () (magit-status target-dir)))
        ;; Store the original window for cleanup purposes
        (with-current-buffer (magit-get-mode-buffer 'magit-status-mode)
          (setq-local luyangliuable--magit-original-window original-window))))))

) ;; End of (after! magit)

;;; ============================================================================
;;; SHELL FUNCTIONS (Don't require magit)
;;; ============================================================================

(defun luyangliuable/shell-clear-buffer ()
  "Clear the shell buffer content, similar to 'clear' command."
  (interactive)
  (let ((comint-buffer-maximum-size 0))
    (comint-truncate-buffer))
  (goto-char (point-max))
  (comint-send-input))

(defun luyangliuable/shell-kill-current-command ()
  "Kill the current command being typed in shell."
  (interactive)
  (comint-kill-input))

(defun luyangliuable/shell-send-eof ()
  "Send EOF (Ctrl-D) to shell process."
  (interactive)
  (comint-send-eof))

(defun luyangliuable/shell-interrupt-process ()
  "Send interrupt signal (Ctrl-C) to shell process."
  (interactive)
  (comint-interrupt-subjob))

(defun luyangliuable/shell-copy-last-output ()
  "Copy the last command output to kill ring."
  (interactive)
  (let ((start (save-excursion
                 (comint-previous-prompt 1)
                 (forward-line 1)
                 (point)))
        (end (save-excursion
               (comint-next-prompt 1)
               (forward-line -1)
               (end-of-line)
               (point))))
    (when (< start end)
      (kill-ring-save start end)
      (message "Copied last output to kill ring"))))

(defun luyangliuable/treemacs-shell-here ()
  "Open shell in the directory of the current treemacs node, or project root if not in treemacs."
  (interactive)
  (let ((target-dir
         (condition-case err
             (cond
              ;; If we're in treemacs, get the directory of the current node
              ((and (eq major-mode 'treemacs-mode)
                    (treemacs-current-button))
               (let* ((button (treemacs-current-button))
                      (node (when button (treemacs-button-get button :path))))
                 (when node
                   (if (file-directory-p node)
                       node
                     (file-name-directory node)))))
              ;; If we have a project root, use that
              ((doom-project-root) (doom-project-root))
              ;; Otherwise use current directory
              (t default-directory))
           ;; If there's any error with treemacs, fall back to project root or default
           (error
            (message "Treemacs error, using fallback directory: %s" (error-message-string err))
            (or (doom-project-root) default-directory)))))

    ;; Ensure we have a valid directory
    (setq target-dir (or target-dir default-directory))
    (message "Opening shell in: %s" target-dir)

    ;; Use safe window splitting and open shell
    (luyangliuable/split-window-right-and-run-callback
     (lambda ()
       (let ((default-directory target-dir))
         (shell))))))

(defun luyangliuable/treemacs-shell-here-horizontal ()
  "Open shell horizontally in the directory of the current treemacs node, or project root if not in treemacs."
  (interactive)
  (let ((target-dir
         (condition-case err
             (cond
              ;; If we're in treemacs, get the directory of the current node
              ((and (eq major-mode 'treemacs-mode)
                    (treemacs-current-button))
               (let* ((button (treemacs-current-button))
                      (node (when button (treemacs-button-get button :path))))
                 (when node
                   (if (file-directory-p node)
                       node
                     (file-name-directory node)))))
              ;; If we have a project root, use that
              ((doom-project-root) (doom-project-root))
              ;; Otherwise use current directory
              (t default-directory))
           ;; If there's any error with treemacs, fall back to project root or default
           (error
            (message "Treemacs error, using fallback directory: %s" (error-message-string err))
            (or (doom-project-root) default-directory)))))

    ;; Ensure we have a valid directory
    (setq target-dir (or target-dir default-directory))
    (message "Opening shell in: %s" target-dir)

    ;; Use safe window splitting and open shell
    (luyangliuable/split-window-below-and-run-callback
     (lambda ()
       (let ((default-directory target-dir))
         (shell))))))

(defun luyangliuable/new-shell-for-project ()
  "Create a new shell session for the current project.
Always spawns a fresh shell instead of reusing existing ones."
  (interactive)
  (let* ((project-root (or (doom-project-root) default-directory))
         (project-name (file-name-nondirectory (directory-file-name project-root)))
         (timestamp (format-time-string "%H%M%S"))
         (shell-buffer-name (format "*shell-%s-%s*" project-name timestamp))
         (default-directory project-root))

    ;; Create the new shell buffer with unique name
    (let ((shell-buffer (shell shell-buffer-name)))
      ;; Switch to the new shell buffer
      (switch-to-buffer shell-buffer)
      (message "New shell created for project '%s' in %s" project-name project-root))))

(defun luyangliuable/new-shell-for-project-split ()
  "Create a new shell session for the current project in a split window.
Always spawns a fresh shell instead of reusing existing ones."
  (interactive)
  (let* ((project-root (or (doom-project-root) default-directory))
         (project-name (file-name-nondirectory (directory-file-name project-root)))
         (timestamp (format-time-string "%H%M%S"))
         (shell-buffer-name (format "*shell-%s-%s*" project-name timestamp)))

    ;; Use the existing split window function but with our new shell logic
    (luyangliuable/split-window-right-and-run-callback
     (lambda ()
       (let ((default-directory project-root))
         (let ((shell-buffer (shell shell-buffer-name)))
           (switch-to-buffer shell-buffer)
           (message "New shell created for project '%s' in %s" project-name project-root)))))))

(provide 'magit)
;;; magit.el ends here
