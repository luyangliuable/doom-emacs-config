;;; config/keybindings/snippets.el -*- lexical-binding: t; -*-
;; YASnippet keybindings - lives under SPC a s (applications > snippets)

(map! :leader
      (:prefix-map ("a" . "applications")
                   (:prefix ("s" . "snippets")
                    :desc "New snippet"            "n" #'+snippets/new
                    :desc "Edit snippet"           "e" #'+snippets/edit
                    :desc "Insert snippet"         "i" #'yas-insert-snippet
                    :desc "Find private snippet"   "f" #'+snippets/find-private
                    :desc "Find any snippet"       "F" #'+snippets/find
                    :desc "Snippets for this mode" "m" #'+snippets/find-for-current-mode
                    :desc "New alias"              "a" #'+snippets/new-alias
                    :desc "Reload all"             "r" #'yas-reload-all
                    :desc "Snippet menu (hydra)"   "s" #'+my/snippets-hydra/body)))

;; Hydra popup so you don't have to memorize sub-keys.
(after! hydra
  (defhydra +my/snippets-hydra (:color blue
                                :hint nil)
    "
 Snippets   _n_ew   _e_dit   _i_nsert   _a_lias
            _f_ind-private   _F_ind-any   _m_ode
            _r_eload                       _q_uit
"
    ("n" +snippets/new)
    ("e" +snippets/edit)
    ("i" yas-insert-snippet)
    ("a" +snippets/new-alias)
    ("f" +snippets/find-private)
    ("F" +snippets/find)
    ("m" +snippets/find-for-current-mode)
    ("r" yas-reload-all)
    ("q" nil)))

(after! yasnippet
  (advice-add #'yas-expand :before #'evil-insert-state)

  ;; 1. Bind TAB inside an ACTIVE snippet field (yas-keymap wins here).
  (define-key yas-keymap        [tab] #'yas-next-field-or-maybe-expand)
  (define-key yas-keymap (kbd "TAB") #'yas-next-field-or-maybe-expand)

  ;; 2. Bind TAB for triggering expansion outside a field.
  (define-key yas-minor-mode-map        [tab] #'yas-maybe-expand-from-keymap)
  (define-key yas-minor-mode-map (kbd "TAB") #'yas-maybe-expand-from-keymap)

  ;; 3. Make sure evil insert-state in yas-minor-mode also routes TAB
  ;;    to yasnippet, so Doom's company/indent bindings don't shadow it.
  (evil-define-key 'insert yas-minor-mode-map
    [tab]      #'yas-maybe-expand-from-keymap
    (kbd "TAB") #'yas-maybe-expand-from-keymap)

  (evil-define-key 'insert yas-keymap
    [tab]      #'yas-next-field-or-maybe-expand
    (kbd "TAB") #'yas-next-field-or-maybe-expand)

  ;; Convenient localleader bindings inside *.snippet buffers.
  (map!
   :map snippet-mode-map
   :localleader
   :desc "Save & reload" "s" #'yas-load-snippet-buffer-and-close
   :desc "Try out"       "t" #'yas-tryout-snippet
   :desc "Abort"         "k" #'+snippet--abort))
