;;; Theme Configuration

(defvar luyangliuable/themes
  '(doom-zenburn
    doom-nord
    doom-solarized-light
    doom-solarized-dark
    doom-challenger-deep
    doom-one
    doom-plain
    doom-plain-dark)
  "List of available themes to cycle through.")


(let ((current-hour (nth 2 (decode-time))))
  (if (or (< current-hour 6) (>= current-hour 20))
      ;; Night time (before 6 AM or after 8 PM)
      (progn
        (message "Good evening!")
        (setq doom-theme 'doom-solarized-dark)
        (defvar luyangliuable/current-theme-index 3
          "Index of the currently active theme.")
        ;; Add your night-time actions here
        )
    ;; Day time
    (progn
      (message "Good day!")
      (setq doom-theme 'doom-solarized-light)
      (defvar luyangliuable/current-theme-index 2
        ;; Add your day-time actions here
        ))))


(load-theme doom-theme t)

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
