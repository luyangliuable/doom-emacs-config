;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

(load! "elisp-functions/functions")

;; Layers
;; Theme
;; (load-file "/Users/blackfish/.config/doom/themes.el")
(load! "themes")

;; Unmap keybindings
(map!
 :leader "tm" nil
 :leader "*" nil
 :leader "x" nil
 :leader ";" nil
 :leader "fy" nil
 :leader "tl" nil)

(map!
 :v "s`" (lambda () (interactive) (luyangliuable/wrap-with-char ?`))
 :v "s\"" (lambda () (interactive) (luyangliuable/wrap-with-char ?\"))
 :v "s'" (lambda () (interactive) (luyangliuable/wrap-with-char ?'))
 :v "s(" (lambda () (interactive) (luyangliuable/wrap-with-char ?\())
 :v "s[" (lambda () (interactive) (luyangliuable/wrap-with-char ?\[))
 :v "s{" (lambda () (interactive) (luyangliuable/wrap-with-char ?{))
 :v "s*" (lambda () (interactive) (luyangliuable/wrap-with-char ?*)))


;; Good scroll
;; Load good-scroll and configure it
(use-package good-scroll
  :ensure nil
  :config

  ;; Disable beacon-mode if it is already enabled
  ;; (when (bound-and-true-p good-scroll-mode)
  ;;   (good-scroll-mode -1))

  ;; Customize good-scroll settings
  (setq good-scroll-duration 0.1) ;; Set a faster duration for scrolling
  (setq good-scroll-amount 3)     ;; Set the amount of lines to scroll at a time
  (setq good-scroll-algorithm #'good-scroll-linear) ;; Use a linear scrolling algorithm for less motion sickness

  ;; (map!
  ;;  :n "C-u" #'good-scroll-down
  ;;  :n "C-d" #'good-scroll-up
  ;;  :n "C-b" #'good-scroll-up-full-screen
  ;;  :n "C-f" #'good-scroll-down-full-screen)

  ;; Disabled due to poor performance
  (good-scroll-mode -1))


;; Map keybindings
(map!
 ;; Global keybindings
 :n "C-c a" #'org-agenda
 :n "C-c c" #'org-capture

 ;; RET save file i love it!
 :n "RET" #'save-buffer

 ;; Leader keybindings
 :leader
 ;; Window
 :desc "Switch to last buffer" "TAB" #'luyangliuable/switch-to-last-buffer
 :desc "Split window right and open shell" "p$" (lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'shell))
 :desc "Split window bottom and open shell" "p|" (lambda () (interactive) (luyangliuable/split-window-below-and-run-callback #'shell))
 :desc "Maximize buffer" "wm" #'luyangliuable/toggle-maximize-buffer

 ;; Jump
 :desc "avy goto char" "jw" #'avy-goto-char
 :desc "goto last change" "jc" #'goto-last-change

 :desc "Window management transient state" "w." #'hydra-window-management/body
 :desc "M-x" "SPC" #'execute-extended-command
 :desc "Go to scratch buffer" "bs" #'luyangliuable/goto-scratch-buffer

 ;; Line
 :desc "absolute lineno toggle" "tna" #'luyangliuable/toggle-absolute-line-numbers
 :desc "relative lineno toggle" "tnr" #'luyangliuable/toggle-relative-line-numbers

 ;; Toggle
 :desc "toggle mode line" "tmT" #'luyangliuable/toggle-mode-line
 :desc "toggle minimap" "tmM" #'minimap-mode

 ;; Key
 :desc "describe key" "hdk" #'describe-key

 ;; Treemacs
 :desc "treemacs" "ft" #'treemacs

 ;; Projectile
 :desc "projectile find file based on string" "*s" #'helm-projectile-grep
 :desc "projectile find file based on string" "*f" #'helm-projectile-find-file

 ;; Text
 :desc "drag stuff down" "xJ" #'luyangliuable/drag-stuff-down-repeatable
 :desc "drag stuff up" "xK" #'luyangliuable/drag-stuff-up-repeatable

 ;; file
 :desc "yank file directory" "fyd" #'luyangliuable/copy-directory-path
 :desc "yank file name" "fyn" #'luyangliuable/copy-file-name
 :desc "yank file file path" "fyy" #'luyangliuable/copy-file-path
 :desc "yank file file path with line number" "fyl" #'luyangliuable/copy-file-path-with-line

 ;; Buffer
 :desc "Copy entire buffer to clipboard" "bY" #'luyangliuable/copy-whole-buffer-to-clipboard
 :desc "link-hint-copy-link-at-point" "xo" #'link-hint-open-link-at-point

 ;; Git
 :desc "browse-at-remote" "xb" #'browse-at-remote
 :desc "magit" "gs" (lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'magit))
 :desc "magit blame" "gs" (lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'magit))

 ;; Commenting
 :desc "evilnc comment operator" ";" #'evilnc-comment-operator)

;; Theme
(setq doom-theme 'doom-challenger-deep)

;; Other
(setq blink-cursor-mode t)

;; Projectile
(after! projectile
  ;; Add .git directory to the ignored directories
  (add-to-list 'projectile-globally-ignored-directories ".git")
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  ;; Optionally add more patterns to ignore
  (add-to-list 'projectile-globally-ignored-file-suffixes ".git"))

;; Fonts
(setq doom-font (font-spec :family "Fira Code" :size 13 :weight 'semi-light))

(setq display-line-numbers-type 'relative)

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

(add-hook 'web-mode-hook 'my-web-mode-hook)

;; Define `,` as the major mode leader key
(setq doom-localleader-key ",")

;; Define a local leader key for insert mode if needed
(setq doom-localleader-alt-key "M-,")

;; lsp-mode
(after! lsp-mode
  (map! :map lsp-mode-map
        :localleader
        :desc "Describe" "hh" #'lsp-describe-thing-at-point
        :desc "Find implementation" "gi" #'lsp-find-implementation
        :desc "Find references" "gr" #'lsp-find-references
        :desc "lsp-treemacs-errors-list" "ge" #'lsp-treemacs-errors-list
        :desc "Jump to definition" "gg" #'lsp-find-definition))

;; Doom modeline customization
(use-package! doom-modeline
  :ensure t
  :init

  (setq doom-modeline-hud t) ;; Enable the HUD feature

  ;; Additional customizations (optional)
  (setq doom-modeline-height 28
        doom-modeline-icon t
        doom-modeline-buffer-encoding t
        doom-modeline-project-detection 'projectile
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-minor-modes nil
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode t
        doom-modeline-linenumber t
        doom-modeline-bar-width 6)

  :config
  (doom-modeline-mode 1))    ;; Enable doom-modeline mode

;; Minimap
(use-package! minimap
  :ensure t
  :init
  (setq minimap-window-location 'right) ;; Example: position the minimap on the right
  :config)

;; Beacon
(use-package! beacon
  :ensure t
  :init
  ;; Customize beacon settings
  (setq beacon-blink-duration 0.8       ;; Duration of the blink
        beacon-blink-delay 0.3          ;; Delay before the blink starts
        beacon-size 40                  ;; Size of the beacon
        beacon-color "#ff9d00"          ;; Color of the beacon
        beacon-push-mark 35             ;; Number of moves before pushing a new mark onto the ring
        beacon-dont-blink-commands '() ;; Commands that won't trigger a blink
        beacon-blink-when-buffer-changes t  ;; Blink when switching buffers
        beacon-blink-when-window-changes t  ;; Blink when switching windows
        beacon-blink-when-point-moves t     ;; Blink when point moves
        beacon-blink-when-window-scrolls t  ;; Blink when window scrolls
        beacon-blink-when-focused t)        ;; Blink when the frame gains focus
  :config
  (beacon-mode 1))
