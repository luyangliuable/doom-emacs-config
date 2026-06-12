;;; config/packages/centered-buffer.el -*- lexical-binding: t; -*-

(defun luyangliuable/toggle-centered-buffer-status ()
  "Check if centered buffer mode is on."
  (bound-and-true-p writeroom-mode))

(defun luyangliuable/toggle-centered-buffer ()
  "Toggle centered buffer mode on and off.

Centerize current buffer."
  (interactive)
  (require 'writeroom-mode)
  (setq writeroom-mode-line-toggle-position 'mode-line-format)
  (if (luyangliuable/toggle-centered-buffer-status)
      (progn
        (writeroom-mode -1)
        (when (called-interactively-p 'any)
          (message "Centered-buffer is disabled.")))
    (let ((writeroom-maximize-window nil)
          (writeroom-mode-line t))
      (writeroom-mode 1))
    (when (called-interactively-p 'any)
      (message "Centered-buffer is enabled."))))

(defun luyangliuable/toggle-centered-buffer-on ()
  "Toggle centered buffer mode on."
  (interactive)
  (unless (luyangliuable/toggle-centered-buffer-status)
    (luyangliuable/toggle-centered-buffer)))

(defun luyangliuable/toggle-centered-buffer-off ()
  "Toggle centered buffer mode off."
  (interactive)
  (when (luyangliuable/toggle-centered-buffer-status)
    (luyangliuable/toggle-centered-buffer)))

(defhydra luyangliuable/centered-buffer-transient-state (:hint nil)
  "
Centered Buffer Transient State
[_m_] modeline  [_[_] shrink  [_]_] enlarge  [_=_] adjust width  [_q_] quit
"
  ("m" writeroom-toggle-mode-line "modeline")
  ("[" writeroom-decrease-width "shrink")
  ("]" writeroom-increase-width "enlarge")
  ("=" writeroom-adjust-width "adjust width")
  ("q" nil "quit" :exit t))

(defun luyangliuable/centered-buffer-transient-state ()
  "Center buffer and enable centering transient state."
  (interactive)
  (luyangliuable/toggle-centered-buffer-on)
  (luyangliuable/centered-buffer-transient-state/body))
