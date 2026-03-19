;;; lisp/functions/window.el -*- lexical-binding: t; -*-
;; Window management functions

(defun luyangliuable/split-window-right-and-run-callback (callback)
  "Split the window vertically and run the CALLBACK function in the new window.
   Handles side windows (like Treemacs) by using a regular window instead."
  (interactive "aFunction to run in new window: ")
  ;; Check if we're in a side window
  (let ((current-window (selected-window)))
    (if (window-parameter current-window 'window-side)
        ;; If in a side window, find a regular window to split
        (let ((main-window (get-mru-window nil nil t))) ; Get main regular window
          (if main-window
              (progn
                (select-window main-window)
                (split-window-right)
                (other-window 1)
                (funcall callback))
            ;; If no main window, just call the callback in current window
            (funcall callback)))
      ;; If not in a side window, proceed normally
      (split-window-right)
      (other-window 1)
      (funcall callback))))

(defun luyangliuable/split-window-below-and-run-callback (callback)
  "Split the window horizontally and run the CALLBACK function in the new window.
   Handles side windows (like Treemacs) by using a regular window instead."
  (interactive "aFunction to run in new window: ")
  ;; Check if we're in a side window
  (let ((current-window (selected-window)))
    (if (window-parameter current-window 'window-side)
        ;; If in a side window, find a regular window to split
        (let ((main-window (get-mru-window nil nil t))) ; Get main regular window
          (if main-window
              (progn
                (select-window main-window)
                (split-window-below)
                (other-window 1)
                (funcall callback))
            ;; If no main window, just call the callback in current window
            (funcall callback)))
      ;; If not in a side window, proceed normally
      (split-window-below)
      (other-window 1)
      (funcall callback))))

(defhydra hydra-window-management (:color amaranth :hint nil)
	  "
Movement^^        ^Split^         ^Delete^        ^Other^
----------------------------------------------------------------
_h_: left         _v_: vertical   _d_: delete     _u_: undo
_j_: down         _s_: horizontal _o_: other      _r_: redo
_k_: up           _m_: maximize   _D_: delete     _b_: balance
_l_: right        _}_: minimize
_f_: follow       _{_: enlarge    _F_: fullscreen
_o_: other        _w_: ace-window
"
	  ("h" windmove-left)               ; Move focus to the left window
	  ("j" windmove-down)               ; Move focus to the window below
	  ("k" windmove-up)                 ; Move focus to the window above
	  ("l" windmove-right)              ; Move focus to the right window
	  ("v" split-window-right)          ; Split the window vertically
	  ("s" split-window-below)          ; Split the window horizontally
	  ("d" delete-window)               ; Delete the current window
	  ("D" delete-other-windows)        ; Delete all other windows
	  ("m" delete-other-windows)        ; Maximize the current window
	  ("M" minimize-window)             ; Minimize the current window
	  ("]" enlarge-window-horizontally) ; Enlarge the window horizontally
	  ("[" shrink-window-horizontally)  ; Shrink the window horizontally
	  ("{" shrink-window)               ; Shrink the window horizontally
	  ("}" enlarge-window)              ; Enlarge the window horizontally
	  ("f" follow-mode)                 ; Toggle follow mode
	  ("o" other-window)                ; Switch to the other window
	  ("b" balance-windows)             ; Balance the sizes of all windows
	  ("F" toggle-frame-fullscreen)     ; Toggle fullscreen mode
	  ("u" winner-undo)                 ; Undo window configuration change
	  ("r" winner-redo)                 ; Redo window configuration change
	  ("w" ace-window)                  ; Select window with ace-window
	  ("q" nil "quit" :color blue))     ; Quit the hydra

(provide 'window)
;;; window.el ends here
