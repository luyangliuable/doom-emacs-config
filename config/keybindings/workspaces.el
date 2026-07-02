;;; config/keybindings/workspaces.el -*- lexical-binding: t; -*-
;; Workspace Keybindings

(require 'cl-lib)

(when (modulep! :ui workspaces)
  (defun luyangliuable/current-workspace-number ()
    "Return the 1-based number of the current Doom workspace."
    (when (and (fboundp '+workspace-current-name)
               (fboundp '+workspace-list-names))
      (let* ((name (+workspace-current-name))
             (names (+workspace-list-names))
             (index (cl-position name names :test #'equal)))
        (when index (1+ index)))))

  (defun luyangliuable/frame-title-with-workspace ()
    "Return a frame title that includes the current workspace number."
    (let ((number (ignore-errors (luyangliuable/current-workspace-number)))
          (name (ignore-errors (+workspace-current-name))))
      (format "WS%s%s - %s"
              (if number (format " %d" number) "")
              (if name (format " (%s)" name) "")
              (buffer-name))))

  (defun luyangliuable/close-window-or-workspace ()
    "Close window/workspace, but do not close the main workspace."
    (interactive)
    (if (and (boundp '+workspaces-main)
             (fboundp '+workspace-current-name)
             (fboundp '+workspace-message)
             (string= (+workspace-current-name) +workspaces-main)
             (not (cdr (doom-visible-windows))))
        (+workspace-message "Refusing to close main workspace" 'warn)
      (+workspace/close-window-or-workspace)))

  (setq frame-title-format
        '((:eval (luyangliuable/frame-title-with-workspace))))

  ;; Help terminals that emit distinct escape sequences for C-Tab.
  ;; If a terminal sends plain TAB/C-i, Emacs cannot distinguish it.
  (dolist (seq '("\e[27;5;9~" "\e[9;5u" "\e[1;5I"))
    (define-key input-decode-map seq [C-tab]))

  (map!
   :g "s-w" #'luyangliuable/close-window-or-workspace
   :g [C-tab] #'+workspace/switch-right
   :g [C-S-tab] #'+workspace/switch-left
   :g [C-backtab] #'+workspace/switch-left
   :nvi [C-tab] #'+workspace/switch-right
   :nvi [C-S-tab] #'+workspace/switch-left
   :nvi [C-backtab] #'+workspace/switch-left)

  ;; Put the bindings in Doom/general's override map too, so package/local
  ;; maps like auto-yasnippet or company cannot shadow C-Tab.
  (when (and (boundp 'general-override-mode-map)
             (keymapp general-override-mode-map))
    (define-key general-override-mode-map [C-tab] #'+workspace/switch-right)
    (define-key general-override-mode-map [C-S-tab] #'+workspace/switch-left)
    (define-key general-override-mode-map [C-backtab] #'+workspace/switch-left)))
