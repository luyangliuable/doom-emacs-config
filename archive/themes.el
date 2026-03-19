;;; Theme Configuration (OPTIMIZED: Cached time calculation)

(defvar luyangliuable/themes
  '(frutiger-aero
    doom-zenburn
    doom-nord
    doom-solarized-light
    doom-solarized-dark
    doom-challenger-deep
    doom-one
    doom-plain
    doom-plain-dark)
  "List of available themes to cycle through.")

;; Cache theme selection based on time of day (calculated once at startup)
(defvar luyangliuable--cached-theme-time nil
  "Cached hour when theme was selected.")
(defvar luyangliuable--cached-theme nil
  "Cached theme selection.")

(let* ((current-hour (nth 2 (decode-time)))
       (is-night (or (< current-hour 6) (>= current-hour 20))))
  (setq luyangliuable--cached-theme-time current-hour
        luyangliuable--cached-theme (if is-night 'doom-solarized-dark 'doom-solarized-light)
        doom-theme luyangliuable--cached-theme
        luyangliuable/current-theme-index (if is-night 4 3))
  (message (if is-night "Good evening!" "Good day!")))

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
