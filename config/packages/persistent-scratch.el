;;; persistent-scratch.el --- Persistent scratch buffer -*- lexical-binding: t; -*-

(defun luyangliuable/load-persistent-scratch (&optional frame)
  "Load persistent-scratch, which restores *scratch*.
Called when idle, and on window buffer changes in FRAME until *scratch* shows."
  (when (or (null frame) (get-buffer-window "*scratch*" t))
    (remove-hook 'window-buffer-change-functions #'luyangliuable/load-persistent-scratch)
    (require 'persistent-scratch)))

(use-package! persistent-scratch
  :defer t
  :init
  (setq persistent-scratch-save-file
        (expand-file-name ".persistent-scratch" doom-cache-dir))
  ;; Restoring *scratch* starts its major mode (and Copilot), so wait for the
  ;; first idle moment, unless *scratch* is shown before then.
  (unless (featurep 'persistent-scratch)
    (add-hook 'window-buffer-change-functions #'luyangliuable/load-persistent-scratch)
    (run-with-idle-timer 0 nil #'luyangliuable/load-persistent-scratch))
  :config
  (make-directory (file-name-directory persistent-scratch-save-file) t)
  (unless (file-exists-p persistent-scratch-save-file)
    (with-temp-file persistent-scratch-save-file
      (insert "nil\n")))
  (setq persistent-scratch-autosave-interval 300)
  (persistent-scratch-setup-default))
