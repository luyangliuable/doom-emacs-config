;;; lisp/functions/text.el -*- lexical-binding: t; -*-
;; Text operations and UI toggle functions

(defvar-local hidden-mode-line-mode nil
  "Non-nil if Hidden-Mode-Line mode is enabled.")

(defvar hidden-mode-line-format nil
  "Store the current mode-line-format.")

(define-minor-mode hidden-mode-line-mode
  "Minor mode to hide the mode-line in the current buffer."
  :init-value nil
  :global t
  :group 'editing-basics
  (if hidden-mode-line-mode
      (setq hidden-mode-line-format mode-line-format
            mode-line-format nil)
    (setq mode-line-format hidden-mode-line-format
          hidden-mode-line-format nil))
  (force-mode-line-update)
  (redraw-display))

(defun luyangliuable/toggle-mode-line ()
  "Toggle the modeline on and off."
  (interactive)
  (if hidden-mode-line-mode
      (hidden-mode-line-mode -1)
    (hidden-mode-line-mode 1)))

(defun luyangliuable/toggle-absolute-line-numbers ()
  "Toggle between absolute line numbers and no line numbers."
  (interactive)
  (if (eq display-line-numbers t)
      (setq display-line-numbers nil)
    (setq display-line-numbers t))
  (redraw-display))

(defun luyangliuable/toggle-relative-line-numbers ()
  "Toggle between relative line numbers and no line numbers."
  (interactive)
  (if (eq display-line-numbers 'relative)
      (setq display-line-numbers nil)
    (setq display-line-numbers 'relative))
  (redraw-display))

(defun luyangliuable/drag-stuff-up-repeatable ()
  "Drag stuff up with repeatable key."
  (interactive)
  (drag-stuff-up 1)
  (message "Press K to move up, J to move down, any other key to exit")
  (set-transient-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "K") #'luyangliuable/drag-stuff-up-repeatable)
     (define-key map (kbd "J") #'luyangliuable/drag-stuff-down-repeatable)
     map)
   nil)) ; Simplified - just use nil without the message parameter

(defun luyangliuable/drag-stuff-down-repeatable ()
  "Drag stuff down with repeatable key."
  (interactive)
  (drag-stuff-down 1)
  (message "Press J to move down, K to move up, any other key to exit")
  (set-transient-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "J") #'luyangliuable/drag-stuff-down-repeatable)
     (define-key map (kbd "K") #'luyangliuable/drag-stuff-up-repeatable)
     map)
   nil)) ; Simplified - just use nil without the message parameter

(defun luyangliuable/sort-lines (&optional reverse)
  "Sort the lines within a selected region or entire buffer.
When given a non-nil argument, sort in descending order instead."
  (interactive "P")
  (let* ((region-active (or (region-active-p) (evil-visual-state-p)))
         (beg (if region-active (region-beginning) (point-min)))
         (end (if region-active (region-end) (point-max))))
    (sort-lines reverse beg end)))

(provide 'text)
;;; text.el ends here
