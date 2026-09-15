;;; config/keybindings/good-scroll.el -*- lexical-binding: t; -*-
;; Good scroll keybindings.

;; Associate these bindings with the minor mode instead of overriding Evil's
;; global map, so Evil restores its normal key resolution when it is disabled.
(after! evil
  ;; Repair direct bindings left in a running Emacs by older config versions.
  ;; Read the fallback from the motion map to preserve the configured defaults.
  (dolist (binding '(("C-u" . good-scroll-down)
                     ("C-d" . good-scroll-up)
                     ("C-b" . good-scroll-up-full-screen)
                     ("C-f" . good-scroll-down-full-screen)))
    (let ((key (kbd (car binding))))
      (when (eq (lookup-key evil-normal-state-map key) (cdr binding))
        (evil-global-set-key 'normal key
                             (lookup-key evil-motion-state-map key)))))

  (evil-define-minor-mode-key 'normal 'good-scroll-mode
    (kbd "C-u") #'good-scroll-down
    (kbd "C-d") #'good-scroll-up
    (kbd "C-f") #'good-scroll-up-full-screen
    (kbd "C-b") #'good-scroll-down-full-screen))

;; Clean up the old comint-local override on configuration reload.  When no
;; legacy binding is present, Evil's normal comint mapping remains untouched.
(with-eval-after-load 'evil-collection-comint
  (let ((map (evil-get-auxiliary-keymap comint-mode-map 'normal)))
    (when (and map
               (eq (lookup-key map (kbd "C-d")) #'good-scroll-up))
      (define-key map (kbd "C-d") nil))))
