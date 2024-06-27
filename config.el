;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(load-file "/Users/blackfish/.config/doom/elisp-functions/functions.el")

;; Unmap keybindings
(map! :leader "tl" nil)

(map!
 :v "s`" (lambda () (interactive) (wrap-with-char "`"))
 :v "s\"" (lambda () (interactive) (wrap-with-char "\""))
 :v "s'" (lambda () (interactive) (wrap-with-char "'"))
 :v "s(" (lambda () (interactive) (wrap-with-char "("))
 :v "s*" (lambda () (interactive) (wrap-with-char "*"))
 :v "s{" (lambda () (interactive) (wrap-with-char "{"))
 :v "s[" (lambda () (interactive) (wrap-with-char "[")))

;; Map keybindings
(map!
 ;; Global keybindings
 :n "C-c a" #'org-agenda
 :n "C-c c" #'org-capture

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
 :desc "treemacs" "ft" #'treemacs

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
