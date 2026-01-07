;;; Theme Configuration

(defvar luyangliuable/themes
  '(doom-zenburn
    doom-nord
    doom-challenger-deep
    doom-one
    doom-plain
    doom-plain-dark)
  "List of available themes to cycle through.")

(defvar luyangliuable/current-theme-index 0
  "Index of the currently active theme.")

;;; Theme Management

;; Disable other themes before loading new one
(defadvice load-theme (before theme-dont-propagate activate)
  "Disable theme before loading new one."
  (mapc #'disable-theme custom-enabled-themes))

(defun luyangliuable/cycle-theme-next ()
  "Cycle to the next theme."
  (interactive)
  (setq luyangliuable/current-theme-index
        (mod (1+ luyangliuable/current-theme-index)
             (length luyangliuable/themes)))
  (let ((theme (nth luyangliuable/current-theme-index luyangliuable/themes)))
    (load-theme theme t)
    (message "Loaded theme: %s (press 'n' for next, 'N' for previous)" theme))
  (set-transient-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "n") #'luyangliuable/cycle-theme-next)
     (define-key map (kbd "N") #'luyangliuable/cycle-theme-previous)
     map)
   t))

(defun luyangliuable/cycle-theme-previous ()
  "Cycle to the previous theme."
  (interactive)
  (setq luyangliuable/current-theme-index
        (mod (1- luyangliuable/current-theme-index)
             (length luyangliuable/themes)))
  (let ((theme (nth luyangliuable/current-theme-index luyangliuable/themes)))
    (load-theme theme t)
    (message "Loaded theme: %s (press 'n' for next, 'N' for previous)" theme))
  (set-transient-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "n") #'luyangliuable/cycle-theme-next)
     (define-key map (kbd "N") #'luyangliuable/cycle-theme-previous)
     map)
   t))

;;; Keybindings

(map!
 :leader
 :desc "cycle theme next"     "Tn" #'luyangliuable/cycle-theme-next
 :desc "cycle theme previous" "TN" #'luyangliuable/cycle-theme-previous)
