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
  (defhydra +my/snippets-hydra (:color blue :hint nil)
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

;; Convenient localleader bindings inside *.snippet buffers.
(map! :after yasnippet
      :map snippet-mode-map
      :localleader
      :desc "Save & reload" "s" #'yas-load-snippet-buffer-and-close
      :desc "Try out"       "t" #'yas-tryout-snippet
      :desc "Abort"         "k" #'+snippet--abort)
