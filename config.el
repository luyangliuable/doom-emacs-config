;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(load-file "/Users/blackfish/.config/doom/elisp-functions/functions.el")

;; Unmap keybindings
(map!
 :leader "tm" nil
 :leader "*" nil
 :leader "tl" nil)

(map!
 :v "s`" (lambda () (interactive) (luyangliuable/wrap-with-char "`"))
 :v "s\"" (lambda () (interactive) (luyangliuable/wrap-with-char "\""))
 :v "s'" (lambda () (interactive) (luyangliuable/wrap-with-char "'"))
 :v "s(" (lambda () (interactive) (luyangliuable/wrap-with-char "("))
 :v "s*" (lambda () (interactive) (luyangliuable/wrap-with-char "*"))
 :v "s{" (lambda () (interactive) (luyangliuable/wrap-with-char "{"))
 :v "s[" (lambda () (interactive) (luyangliuable/wrap-with-char "[")))

;; Map keybindings
(map!
 ;; Global keybindings
 :n "C-c a" #'org-agenda
 :n "C-c c" #'org-capture

 ;; RET save file i love it!
 :n "RET" #'save-buffer

 ;; Leader keybindings
 :leader
 :desc "Switch to last buffer" "TAB" #'luyangliuable/switch-to-last-buffer
 :desc "Split window right and open shell" "p$" #'(lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'shell))
 :desc "Split window bottom and open shell" "p|" #'(lambda () (interactive) (luyangliuable/split-window-below-and-run-callback #'shell))
 :desc "Maximize buffer" "wm" #'luyangliuable/toggle-maximize-buffer
 :desc "magit" "gs" #'(lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'magit))
 :desc "avy goto char" "jw" #'avy-goto-char
 :desc "goto last change" "jc" #'goto-last-change
 :desc "Window management transient state" "w." #'hydra-window-management/body
 :desc "M-x" "SPC" #'execute-extended-command
 :desc "Go to scratch buffer" "bs" #'luyangliuable/goto-scratch-buffer
 :desc "absolute lineno toggle" "tna" #'luyangliuable/toggle-absolute-line-numbers
 :desc "relative lineno toggle" "tnr" #'luyangliuable/toggle-relative-line-numbers
 :desc "toggle mode line" "tmT" #'luyangliuable/toggle-mode-line
 :desc "toggle minimap" "tmM" #'minimap-mode
 :desc "treemacs" "ft" #'treemacs
 :desc "projectile find file based on string" "*s" #'helm-projectile-grep
 :desc "projectile find file based on string" "*f" #'helm-projectile-find-file

 ;; Mode-specific keybindings
 (:after python
   (:map python-mode-map
    :localleader
    :desc "Run Python file" "r" #'python-shell-run-file)))

;; Svelte configuration
(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(svelte-mode . "svelte"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "svelteserver")
                    :activation-fn (lsp-activate-on "svelte")
                    :server-id 'svelte-ls)))

;; Theme
(setq doom-theme 'doom-tomorrow-night)

;; Other
(setq blink-cursor-mode t)

;; Projectile
(after! projectile
  ;; Add .git directory to the ignored directories
  (add-to-list 'projectile-globally-ignored-directories ".git")
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  ;; Optionally add more patterns to ignore
  (add-to-list 'projectile-globally-ignored-file-suffixes ".git"))

