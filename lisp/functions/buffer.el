;;; lisp/functions/buffer.el -*- lexical-binding: t; -*-
;; Buffer-related functions

(defun luyangliuable/goto-scratch-buffer ()
  "Switch to the *scratch* buffer."
  (interactive)
  (switch-to-buffer "*scratch*"))

(defun luyangliuable/switch-to-last-buffer (&optional window)
  "Switch back and forth between current and last buffer in the
current window.

If `doom-workspaces-restrict-spc-tab' is `t' then this only switches between
the current workspace's buffers."
  (interactive)
  (let ((window (or window (selected-window))))
    (cl-destructuring-bind (buf start pos)
        (if (bound-and-true-p doom-workspaces-restrict-spc-tab)
            (let ((buffer-list (doom-buffer-list))
                  (current-buffer (window-buffer window)))
              ;; Find buffer of the same workspace in window
              (seq-find (lambda (it) ;; Predicate
                          (and (not (eq (car it) current-buffer))
                               (member (car it) buffer-list)))
                        (window-prev-buffers window)
                        ;; Default if none found
                        (list nil nil nil)))
          (or (cl-find (window-buffer window) (window-prev-buffers window)
                       :key #'car :test-not #'eq)
              (list (other-buffer) nil nil)))
      (if (not buf)
          (message "Last buffer not found.")
        (set-window-buffer-start-and-point window buf start pos)))))

(defun luyangliuable/copy-whole-buffer-to-clipboard ()
  "Copy entire buffer to clipboard"
  (interactive)
  (clipboard-kill-ring-save (point-min) (point-max))
  (message "Yanked entire buffer"))

(defun luyangliuable/toggle-maximize-buffer ()
  "Maximize buffer"
  (interactive)
  (save-excursion
    (if (and (= 1 (length (window-list)))
             (assoc ?_ register-alist))
        (jump-to-register ?_)
      (progn
        (window-configuration-to-register ?_)
        (delete-other-windows)))))

(defun luyangliuable/yank-active-minor-modes ()
  "Yank the names of all active minor modes into the kill ring."
  (interactive)
  (let ((active-minor-modes '()))
    (mapc (lambda (mode)
            (when (and (boundp mode) (symbol-value mode))
              (push (symbol-name mode) active-minor-modes)))
          minor-mode-list)
    (let ((modes-string (string-join active-minor-modes ", ")))
      (kill-new modes-string)
      (message "Yanked active minor modes: %s" modes-string))))

(defun luyangliuable/yank-major-mode ()
  "Yank the name of the current major mode into the kill ring."
  (interactive)
  (let ((major-mode-name (symbol-name major-mode)))
    (kill-new major-mode-name)
    (message "Yanked major mode: %s" major-mode-name)))

(provide 'buffer)
;;; buffer.el ends here
