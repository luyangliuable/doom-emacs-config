;;; config/packages/valign.el -*- lexical-binding: t; -*-
;; Visual (pixel) alignment of org/markdown tables via casouri/valign.
;; Display-only: the table text on disk is never rewritten.

(defun luyangliuable/valign-maybe-enable ()
  "Enable `valign-mode' only in GUI file buffers outside gptel chats.
Non-file buffers (gptel/agent output, scratch) stay untouched so streaming
text doesn't trigger table realignment."
  (when (and buffer-file-name
             (display-graphic-p)
             (not (bound-and-true-p gptel-mode)))
    (valign-mode 1)))

(defun luyangliuable/valign-disable-in-gptel ()
  "Turn off `valign-mode' when a buffer becomes a gptel chat."
  (when (bound-and-true-p valign-mode)
    (valign-mode -1)))

(defun luyangliuable/valign-toggle-size-limit ()
  "Toggle aligning tables larger than `valign-max-table-size' in this buffer.
Huge tables stay unaligned by default because realigning them makes every
keystroke slow; use this to align them on demand and toggle back after."
  (interactive)
  (if (local-variable-p 'valign-max-table-size)
      (progn
        (kill-local-variable 'valign-max-table-size)
        (message "valign: size limit restored (%s)" valign-max-table-size))
    (setq-local valign-max-table-size 0)
    (unless (bound-and-true-p valign-mode)
      (valign-mode 1))
    (message "valign: aligning all tables in this buffer (may be slow)"))
  (font-lock-flush))

(add-hook 'org-mode-hook #'luyangliuable/valign-maybe-enable)
(add-hook 'markdown-mode-hook #'luyangliuable/valign-maybe-enable)
(add-hook 'gptel-mode-hook #'luyangliuable/valign-disable-in-gptel)

(after! valign
  (setq valign-fancy-bar nil
        valign-max-table-size 4000))
