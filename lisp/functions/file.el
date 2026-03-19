;;; lisp/functions/file.el -*- lexical-binding: t; -*-
;; File operations functions

(defun luyangliuable/copy-directory-path ()
  "Copy the directory path of the current buffer to the clipboard."
  (interactive)
  (let ((directory-path (if buffer-file-name
                            (file-name-directory buffer-file-name)
                          default-directory)))
    (when directory-path
      (kill-new directory-path)
      (message "Copied directory path: %s" directory-path))))

(defun luyangliuable/copy-file-path ()
  "Copy the directory path of the current buffer to the clipboard."
  (interactive)
  (let ((directory-path (if buffer-file-name buffer-file-name default-directory)))
    (when directory-path
      (kill-new directory-path)
      (message "Copied directory path: %s" directory-path))))

(defun luyangliuable/copy-file-path-with-line ()
  "Copy and show the file path of the current buffer, including the line number."
  (interactive)
  (if-let* ((file-path (buffer-file-name))
            (line-number (line-number-at-pos))
            (full-path (format "%s:%d" file-path line-number)))
      (progn
        (kill-new full-path)
        (message "Copied: %s" full-path))
    (message "WARNING: Current buffer is not attached to a file!")))

(defun luyangliuable/copy-file-name ()
  "Copy and show the file name of the current buffer."
  (interactive)
  (if-let* ((file-path (buffer-file-name))
            (file-name (file-name-nondirectory file-path)))
      (progn
        (kill-new file-name)
        (message "%s" file-name))
    (message "WARNING: Current buffer is not attached to a file!")))

(defun luyangliuable/wrap-with-char (char)
  "Wrap the selected region with the corresponding CHAR pair."
  (interactive "Wrap with char: ")
  (let ((pairs '((?` . ?`)
                 (?\" . ?\")
                 (?' . ?')
                 (?\( . ?\))
                 (?\[ . ?\])
                 (?{ . ?})
                 (?* . ?*)))
        (beg (region-beginning))
        (end (region-end)))
    (save-excursion
      (goto-char end)
      (insert (or (cdr (assoc char pairs)) char))
      (goto-char beg)
      (insert char))))

(provide 'file)
;;; file.el ends here
