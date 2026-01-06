;;; config/keybindings.el -*- lexical-binding: t; -*-
;; All Keybinding Configurations

;;; ============================================================================
;;; KEYBINDINGS
;;; ============================================================================

;; Unmap conflicting keybindings
(map!
 :leader "tm" nil
 :leader "*" nil
 :leader "x" nil
 :leader ";" nil
 :leader "fy" nil
 :leader "tl" nil)

;; Visual mode text wrapping keybindings
(map!
 :v "s`" (lambda () (interactive) (luyangliuable/wrap-with-char ?`))
 :v "s\"" (lambda () (interactive) (luyangliuable/wrap-with-char ?\"))
 :v "s'" (lambda () (interactive) (luyangliuable/wrap-with-char ?'))
 :v "s(" (lambda () (interactive) (luyangliuable/wrap-with-char ?\())
 :v "s[" (lambda () (interactive) (luyangliuable/wrap-with-char ?\[))
 :v "s{" (lambda () (interactive) (luyangliuable/wrap-with-char ?{))
 :v "s*" (lambda () (interactive) (luyangliuable/wrap-with-char ?*)))

;; Good scroll keybindings
(map!
 :n "C-u" #'good-scroll-down
 :n "C-d" #'good-scroll-up
 :n "C-b" #'good-scroll-up-full-screen
 :n "C-f" #'good-scroll-down-full-screen)

;; File operations
(map!
 :n "c-u" (lambda () (interactive) (revert-buffer nil t)))

(map! :map emacs-lisp-mode-map
        :localleader
        :desc "flycheck-errors-list" "ge" #'flycheck-list-errors)

;; Main keybinding block - organized by category
(map!
 ;; Global keybindings (non-leader)
 :n "C-c a" #'org-agenda
 :n "C-c c" #'org-capture

 :n "RET" (lambda () (interactive) (delete-trailing-whitespace) (save-buffer)) ;; RET remove trailing whitespace and save file

 ;; Leader keybindings organized by prefix
 :leader
 ;; Buffer operations
 :desc "Switch to last buffer" "TAB" #'luyangliuable/switch-to-last-buffer
 :desc "Go to scratch buffer" "bs" #'luyangliuable/goto-scratch-buffer
 :desc "Copy entire buffer to clipboard" "bY" #'luyangliuable/copy-whole-buffer-to-clipboard

 ;; Window management
 :desc "Split window right and open shell" "p$" (lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'shell))
 :desc "Split window bottom and open shell" "p|" (lambda () (interactive) (luyangliuable/split-window-below-and-run-callback #'shell))
 :desc "Maximize buffer" "wm" #'luyangliuable/toggle-maximize-buffer
 :desc "Ace window" "wW" #'ace-window
 :desc "Window management transient state" "w." #'hydra-window-management/body

 ;; File operations
 :desc "treemacs" "ft" #'treemacs
 :desc "yank file directory" "fyd" #'luyangliuable/copy-directory-path
 :desc "yank file name" "fyn" #'luyangliuable/copy-file-name
 :desc "yank file file path" "fyy" #'luyangliuable/copy-file-path
 :desc "yank file file path with line number" "fyl" #'luyangliuable/copy-file-path-with-line

 ;; Git operations
 :desc "browse-at-remote" "xb" #'browse-at-remote
 :desc "magit" "gs" (lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'magit))

 ;; Jump operations
 :desc "avy goto char" "jw" #'avy-goto-char
 :desc "goto last change" "jc" #'goto-last-change

 ;; Toggle operations
 :desc "absolute lineno toggle" "tna" #'luyangliuable/toggle-absolute-line-numbers
 :desc "relative lineno toggle" "tnr" #'luyangliuable/toggle-relative-line-numbers
 :desc "toggle mode line" "tmT" #'luyangliuable/toggle-mode-line
 :desc "toggle minimap" "tmM" #'minimap-mode

 ;; Text operations
 :desc "drag stuff down" "xJ" #'luyangliuable/drag-stuff-down-repeatable
 :desc "drag stuff up" "xK" #'luyangliuable/drag-stuff-up-repeatable
 :desc "delete trailing whitespace" "xdw" #'delete-trailing-whitespace
 :desc "link-hint-copy-link-at-point" "xo" #'link-hint-open-link-at-point

 ;; Project operations
 :desc "projectile find file based on string" "*s" #'helm-projectile-grep
 :desc "projectile find file based on string" "*f" #'helm-projectile-find-file

 ;; Help operations
 :desc "describe key" "hdk" #'describe-key

 ;; Misc operations
 :desc "M-x" "SPC" #'execute-extended-command
 :desc "evilnc comment operator" ";" #'evilnc-comment-operator)