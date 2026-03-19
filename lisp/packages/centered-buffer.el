;;; config/packages/centered-buffer.el -*- lexical-binding: t; -*-

(defun doom/toggle-centered-buffer-on ()
  "Enable centered buffer mode."
  (interactive)
  (+zen/toggle))

(defhydra doom/centered-buffer-transient-state (:hint nil)
  "
Center buffer
[_c_] center  [_C_] uncenter  [_+_] wider  [_-_] narrower  [_=_] reset  [_q_] quit
"
  ("c" doom/toggle-centered-buffer-on "center")
  ("C" +zen/toggle "uncenter")
  ("+" text-scale-increase "wider")
  ("-" text-scale-decrease "narrower")
  ("=" text-scale-adjust "reset")
  ("q" nil "quit" :exit t))

(defun doom/centered-buffer-transient-state ()
  "Center buffer and enable centering transient state."
  (interactive)
  (doom/toggle-centered-buffer-on)
  (doom/centered-buffer-transient-state/body))
