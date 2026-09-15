;;; Theme Configuration

(require 'cl-lib)

(defvar luyangliuable/themes nil
  "List of available themes to cycle through.")

;; `defvar` preserves its old value when this file is reloaded.
(setq luyangliuable/themes
      '(frutiger-aero
        doom-monokai-machine
        doom-one-light
        doom-ayu-light
        doom-zenburn
        doom-nord
        doom-solarized-light
        doom-solarized-dark
        doom-moonlight
        doom-challenger-deep
        doom-one
        doom-plain
        doom-plain-dark))

(setq default-dark-theme 'doom-monokai-machine)
(setq default-light-theme 'doom-one-light)

(defvar luyangliuable/current-theme-index nil
  "Index of the active theme in `luyangliuable/themes`.")

(defvar luyangliuable/theme-cycle-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") #'luyangliuable/cycle-theme-next)
    (define-key map (kbd "N") #'luyangliuable/cycle-theme-previous)
    map)
  "Keymap active while cycling themes.")

(defun luyangliuable/theme-index (theme)
  "Return THEME's index in `luyangliuable/themes`."
  (or (cl-position theme luyangliuable/themes)
      (user-error "Theme `%s' is not available for cycling" theme)))

(defun luyangliuable/set-doom-theme (theme)
  "Load THEME and update the current theme index."
  (setq doom-theme theme
        luyangliuable/current-theme-index
        (luyangliuable/theme-index theme))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t))

(let ((current-hour (nth 2 (decode-time))))
  (luyangliuable/set-doom-theme
   (if (or (< current-hour 6) (>= current-hour 19))
       (progn
         (message "Good evening!")
         default-dark-theme)
     (progn
       (message "Good day!")
        default-light-theme))))

;;; Theme Management

(defun luyangliuable/cycle-theme (offset)
  "Load the theme OFFSET positions from the current theme."
  (let* ((current-index (luyangliuable/theme-index doom-theme))
         (next-index (mod (+ current-index offset)
                          (length luyangliuable/themes)))
         (theme (nth next-index luyangliuable/themes)))
    (luyangliuable/set-doom-theme theme)
    (message "Loaded theme: %s (press 'n' for next, 'N' for previous)" theme))
  (set-transient-map luyangliuable/theme-cycle-map t))

(defun luyangliuable/cycle-theme-next ()
  "Cycle to the next theme."
  (interactive)
  (luyangliuable/cycle-theme 1))

(defun luyangliuable/cycle-theme-previous ()
  "Cycle to the previous theme."
  (interactive)
  (luyangliuable/cycle-theme -1))

;;; Keybindings

(map!
  :leader
  :desc "cycle theme next"     "Tn" #'luyangliuable/cycle-theme-next
  :desc "cycle theme previous" "TN" #'luyangliuable/cycle-theme-previous)
