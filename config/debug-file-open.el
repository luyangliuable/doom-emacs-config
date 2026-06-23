;;; config/debug-file-open.el -*- lexical-binding: t; -*-
;; Temporary instrumentation for debugging file-opening/display issues.

(defvar luyangliuable/file-open-debug-enabled nil
  "Whether file-open debugging is enabled.")

(defun luyangliuable/file-open-debug-log (fmt &rest args)
  "Log file-open debugging message."
  (when luyangliuable/file-open-debug-enabled
    (apply #'message (concat "[file-open-debug] " fmt) args)))

(defun luyangliuable/file-open-debug-window-state (label)
  "Log current buffer/window state with LABEL."
  (luyangliuable/file-open-debug-log
   "%s: buffer=%S mode=%S window=%S dedicated=%S popup=%S side=%S quit-restore=%S"
   label
   (buffer-name) major-mode (selected-window) (window-dedicated-p)
   (window-parameter nil 'popup)
   (window-parameter nil 'window-side)
   (window-parameter nil 'quit-restore)))

(defun luyangliuable/file-open-debug-buffer-for-file (file)
  "Return the buffer visiting FILE, if any."
  (when file
    (get-file-buffer (expand-file-name file))))

(defun luyangliuable/debug-find-file-advice (orig-fun filename &rest args)
  "Debug advice around ORIG-FUN for FILENAME and ARGS."
  (luyangliuable/file-open-debug-window-state "BEFORE find-file")
  (luyangliuable/file-open-debug-log
   "find-file filename=%S expanded=%S args=%S this-command=%S"
   filename (and filename (expand-file-name filename)) args this-command)
  (let ((result (apply orig-fun filename args)))
    (luyangliuable/file-open-debug-window-state "AFTER find-file")
    (luyangliuable/file-open-debug-log
     "find-file result=%S target-buffer=%S selected-buffer=%S"
     result
     (luyangliuable/file-open-debug-buffer-for-file filename)
     (current-buffer))
    result))

(defun luyangliuable/debug-find-file-noselect-advice (orig-fun filename &rest args)
  "Debug advice around `find-file-noselect'."
  (luyangliuable/file-open-debug-log
   "find-file-noselect filename=%S expanded=%S args=%S from=%S mode=%S"
   filename (and filename (expand-file-name filename)) args (buffer-name) major-mode)
  (let ((result (apply orig-fun filename args)))
    (luyangliuable/file-open-debug-log
     "find-file-noselect result=%S selected-buffer=%S"
     result (current-buffer))
    result))

(defun luyangliuable/debug-switch-to-buffer-advice (orig-fun buffer-or-name &rest args)
  "Debug advice around `switch-to-buffer'."
  (luyangliuable/file-open-debug-log
   "switch-to-buffer buffer=%S args=%S from=%S mode=%S dedicated=%S"
   buffer-or-name args (buffer-name) major-mode (window-dedicated-p))
  (apply orig-fun buffer-or-name args))
(defun luyangliuable/debug-display-buffer-advice (orig-fun buffer-or-name &rest args)
  "Debug advice around `display-buffer'."
  (luyangliuable/file-open-debug-log
   "display-buffer buffer=%S args=%S from=%S mode=%S dedicated=%S popup=%S"
   buffer-or-name args (buffer-name) major-mode
   (window-dedicated-p) (window-parameter nil 'popup))
  (apply orig-fun buffer-or-name args))

(defun luyangliuable/debug-pop-to-buffer-advice (orig-fun buffer-or-name &rest args)
  "Debug advice around `pop-to-buffer'."
  (luyangliuable/file-open-debug-log
   "pop-to-buffer buffer=%S args=%S from=%S mode=%S"
   buffer-or-name args (buffer-name) major-mode)
  (apply orig-fun buffer-or-name args))

(defun luyangliuable/debug-display-buffer-same-window-advice
    (orig-fun buffer alist)
  "Debug advice around `display-buffer-same-window'."
  (luyangliuable/file-open-debug-log
   "display-buffer-same-window buffer=%S alist=%S from=%S mode=%S dedicated=%S"
   buffer alist (buffer-name) major-mode (window-dedicated-p))
  (funcall orig-fun buffer alist))
(defun luyangliuable/enable-file-open-debug ()
  "Enable file-open debugging."
  (interactive)
  (setq luyangliuable/file-open-debug-enabled t)
  (advice-add #'find-file :around #'luyangliuable/debug-find-file-advice)
  (advice-add #'find-file-noselect :around
              #'luyangliuable/debug-find-file-noselect-advice)
  (advice-add #'switch-to-buffer :around
              #'luyangliuable/debug-switch-to-buffer-advice)
  (advice-add #'display-buffer :around
              #'luyangliuable/debug-display-buffer-advice)
  (advice-add #'pop-to-buffer :around
              #'luyangliuable/debug-pop-to-buffer-advice)
  (advice-add #'display-buffer-same-window :around
              #'luyangliuable/debug-display-buffer-same-window-advice)
  (message "[file-open-debug] enabled"))
(defun luyangliuable/disable-file-open-debug ()
  "Disable file-open debugging."
  (interactive)
  (advice-remove #'find-file #'luyangliuable/debug-find-file-advice)
  (advice-remove #'find-file-noselect
                 #'luyangliuable/debug-find-file-noselect-advice)
  (advice-remove #'switch-to-buffer
                 #'luyangliuable/debug-switch-to-buffer-advice)
  (advice-remove #'display-buffer
                 #'luyangliuable/debug-display-buffer-advice)
  (advice-remove #'pop-to-buffer
                 #'luyangliuable/debug-pop-to-buffer-advice)
  (advice-remove #'display-buffer-same-window
                 #'luyangliuable/debug-display-buffer-same-window-advice)
  (setq luyangliuable/file-open-debug-enabled nil)
  (message "[file-open-debug] disabled"))
