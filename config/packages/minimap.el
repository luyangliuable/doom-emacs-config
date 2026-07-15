;;; config/packages/minimap.el -*- lexical-binding: t; -*-
;; Minimap configuration. Uses standalone `minimap', not Doom `demap'.

(use-package! minimap
  :defer t
  :init
  (setq minimap-window-location 'right
    minimap-major-modes '(prog-mode))

  (defvar luyangliuable/minimap-debug nil)
  (defvar luyangliuable/minimap--last-buffer nil)
  (defvar luyangliuable/minimap--last-tick nil)
  (defvar luyangliuable/minimap--last-eligible nil)

  (defun luyangliuable/minimap-buffer-over-100-lines-p ()
    (save-excursion
      (goto-char (point-min))
      (forward-line 100)
      (not (eobp))))

  (defun luyangliuable/minimap-eligible-buffer-p ()
    (and buffer-file-name
      (not (minibufferp))
      (not (string= (buffer-name) " *MINIMAP*"))
      (luyangliuable/minimap-buffer-over-100-lines-p)))

  (defun luyangliuable/minimap-auto-sync ()
    (unless (or (active-minibuffer-window)
              (minibufferp)
              (string= (buffer-name) " *MINIMAP*"))
      (let ((buffer (current-buffer))
             (tick (buffer-chars-modified-tick)))
        (unless (and (eq buffer luyangliuable/minimap--last-buffer)
                  (eq tick luyangliuable/minimap--last-tick))
          (let* ((eligible (luyangliuable/minimap-eligible-buffer-p))
                  (buffer-changed
                    (not (eq buffer luyangliuable/minimap--last-buffer)))
                  (eligibility-changed
                    (not (eq eligible luyangliuable/minimap--last-eligible))))
            (setq luyangliuable/minimap--last-buffer buffer
              luyangliuable/minimap--last-tick tick
              luyangliuable/minimap--last-eligible eligible)
            (when luyangliuable/minimap-debug
              (message "minimap auto: buffer=%s eligible=%s active=%s"
                (buffer-name) eligible
                (bound-and-true-p minimap-mode)))
            (when (or buffer-changed eligibility-changed)
              (cond
                (eligible
                  (add-to-list 'minimap-major-modes major-mode)
                  (unless (or (bound-and-true-p minimap-mode)
                            (minor-mode-badges-disabled-p 'minimap-mode))
                    (minimap-mode 1)))
                ((bound-and-true-p minimap-mode)
                  (minimap-mode -1)))))))))

  (add-hook 'post-command-hook
    #'luyangliuable/minimap-auto-sync))
