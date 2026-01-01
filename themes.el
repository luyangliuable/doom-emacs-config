(defvar luyangliuable/themes '(doom-zenburn doom-challenger-deep doom-plain doom-plain-dark))
(defvar luyangliuable/current-theme-index 0)

;; disable other themes before loading new one
(defadvice load-theme (before theme-dont-propagate activate)
  "Disable theme before loading new one."
  (mapc #'disable-theme custom-enabled-themes))

(defun luyangliuable/cycle-theme-next ()
  "Cycle to the next theme."
  (interactive)
  (setq luyangliuable/current-theme-index
        (mod (1+ luyangliuable/current-theme-index) (length luyangliuable/themes)))
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
        (mod (1- luyangliuable/current-theme-index) (length luyangliuable/themes)))
  (let ((theme (nth luyangliuable/current-theme-index luyangliuable/themes)))
    (load-theme theme t)
    (message "Loaded theme: %s (press 'n' for next, 'N' for previous)" theme))
  (set-transient-map
   (let ((map (make-sparse-keymap)))
     (define-key map (kbd "n") #'luyangliuable/cycle-theme-next)
     (define-key map (kbd "N") #'luyangliuable/cycle-theme-previous)
     map)
   t))

(map!
 ;; Leader keybindings
 :leader
 ;; Themes
 :desc "cycle theme next" "Tn" #'luyangliuable/cycle-theme-next
 :desc "cycle theme previous" "TN" #'luyangliuable/cycle-theme-previous)
