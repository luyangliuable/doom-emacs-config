;;; config/keybindings/frames.el -*- lexical-binding: t; -*-

(defun doom/find-file-other-frame ()
  "Find file in another frame."
  (interactive)
  (call-interactively 'find-file-other-frame))

(defun doom/switch-to-buffer-other-frame ()
  "Switch to buffer in another frame."
  (interactive)
  (call-interactively 'switch-to-buffer-other-frame))

(defun doom/display-buffer-other-frame ()
  "Display buffer in another frame."
  (interactive)
  (call-interactively 'display-buffer-other-frame))

(defun doom/dired-other-frame ()
  "Open dired in another frame."
  (interactive)
  (call-interactively 'dired-other-frame))

(defhydra doom/frame-transient-state (:hint nil)
  "
Frame commands
[_f_] find file  [_b_] switch buffer  [_B_] display buffer  [_o_] other frame
[_n_] new frame  [_d_] delete frame   [_D_] delete others   [_O_] dired
[_q_] quit
"
  ("f" doom/find-file-other-frame "find file")
  ("d" delete-frame "delete")
  ("D" delete-other-frames "delete others")
  ("b" doom/switch-to-buffer-other-frame "switch buffer")
  ("B" doom/display-buffer-other-frame "display buffer")
  ("o" other-frame "other frame")
  ("O" doom/dired-other-frame "dired")
  ("n" make-frame "new frame")
  ("q" nil "quit" :exit t))

(map! :leader
      :desc "Frame transient state" "t F" #'toggle-frame-fullscreen)
