;;; config/keybindings.el -*- lexical-binding: t; -*-
;; All Keybinding Configurations

;; Load individual keybinding files (standalone map!/after! blocks only)
(ignore-errors
  (load! "keybindings/gptel")
  (load! "keybindings/evil")
  (load! "keybindings/treemacs")
  (load! "keybindings/lsp")
  (load! "keybindings/shell")
  (load! "keybindings/magit")
  (load! "keybindings/emacs-lisp")
  (load! "keybindings/zone")
  (load! "keybindings/good-scroll")
  (load! "keybindings/undo-tree")
  (load! "keybindings/narrow")
  (load! "keybindings/frames")
  (load! "keybindings/snippets")
  (load! "keybindings/workspaces"))

;;; ============================================================================
;;; KEYBINDINGS
;;; ============================================================================

;; Unmap conflicting keybindings
(map!
  :leader "tm" nil
  :leader "wr" nil
  :leader "wc" nil
  :leader "gs" nil
  :leader "*" nil
  :leader "p!" nil
  :leader "x" nil
  :leader ";" nil
  :leader "fy" nil
  :leader "tl" nil
  :leader "tz" nil
  :leader "tZ" nil
  :leader "tc" nil
  :leader "se" nil)

;; Visual mode text wrapping keybindings
(map!
  :v "s`" (lambda () (interactive) (luyangliuable/wrap-with-char ?`))
  :v "s\"" (lambda () (interactive) (luyangliuable/wrap-with-char ?\"))
  :v "s'" (lambda () (interactive) (luyangliuable/wrap-with-char ?'))
  :v "s(" (lambda () (interactive) (luyangliuable/wrap-with-char ?\())
  :v "s[" (lambda () (interactive) (luyangliuable/wrap-with-char ?\[))
  :v "s{" (lambda () (interactive) (luyangliuable/wrap-with-char ?{))
  :v "s*" (lambda () (interactive) (luyangliuable/wrap-with-char ?*)))

;; File operations
;; (map!
;; :n "c-u" (lambda () (interactive) (revert-buffer nil t)))

;; Main keybinding block - organized by category
(defun luyangliuable/agent-shell-activate-control-at-point ()
  "Toggle the nearest Agent Shell collapsible fragment at point."
  (when (fboundp 'agent-shell-ui-toggle-fragment)
    (agent-shell-ui-toggle-fragment)))

(map!
  ;; Global keybindings (non-leader)
  :n "RET" (lambda ()
             (interactive)
             (if (derived-mode-p 'agent-shell-mode)
                 (luyangliuable/agent-shell-activate-control-at-point)
               (delete-trailing-whitespace)
               (save-buffer)))

  ;; Leader keybindings organized by prefix
  :leader
  ;; Buffer operations
  :desc "Switch to last buffer" "TAB" #'luyangliuable/switch-to-last-buffer
  :desc "Go to scratch buffer" "bs" #'luyangliuable/goto-scratch-buffer
  :desc "Open dashboard" "bh" #'+doom-dashboard/open
  :desc "Copy entire buffer to clipboard" "bY" #'luyangliuable/copy-whole-buffer-to-clipboard

  :desc "Run shell in project" "p$." #'projectile-run-shell
  :desc "Split window vertically and run shell"
  "p$v" (lambda ()
          (interactive)
          (split-window-right)
          (other-window 1)
          (projectile-run-shell))

  ;; :desc "Split window vertically and temp run shell"
  ;; "p$t" (cmd! (split-window-right)
  ;;             (other-window 1)
  ;;             (projectile-run-shell)
  ;;             (evil-local-set-key 'normal (kbd "q") 'kill-current-buffer)
  ;;             (local-set-key (kbd "q") 'kill-current-buffer))
  ;;
  :desc "Split window horizontally and run shell" "p$s" (lambda () (interactive) (split-window-below) (other-window 1) (projectile-run-shell))
  :desc "Split window vertically and run shell" "p$V" (lambda () (interactive) (split-window-right) (other-window 1) (projectile-run-shell) (other-window -1))
  :desc "Split window horizontally and run shell" "p$S" (lambda () (interactive) (split-window-below) (other-window 1) (projectile-run-shell) (other-window -1))

  ;; :desc "new shell for project" "p!" #'luyangliuable/new-shell-for-project
  :desc "Run shell in project" "p!." #'luyangliuable/new-shell-for-project
  :desc "Split window vertically and run shell" "p!v" (lambda () (interactive) (split-window-right) (other-window 1) (luyangliuable/new-shell-for-project))
  :desc "Split window horizontally and run shell" "p!s" (lambda () (interactive) (split-window-below) (other-window 1) (luyangliuable/new-shell-for-project))
  :desc "Split window vertically and run shell" "p!V" (lambda () (interactive) (split-window-right) (other-window 1) (luyangliuable/new-shell-for-project) (other-window -1))
  :desc "Split window horizontally and run shell" "p!S" (lambda () (interactive) (split-window-below) (other-window 1) (luyangliuable/new-shell-for-project) (other-window -1))

  :desc "Resize window width %" "wrw" (lambda () (interactive)
                                        (let* ((pct (read-number "Window width %: "))
                                                (target-width (round (* (frame-width) (/ pct 100.0)))))
                                          (window-resize nil (- target-width (window-width)) t)))
  :desc "Resize window height %" "wrh" (lambda () (interactive)
                                         (let* ((pct (read-number "Window height %: "))
                                                 (target-height (round (* (frame-height) (/ pct 100.0)))))
                                           (window-resize nil (- target-height (window-height)))))

  :desc "Split window bottom and open shell" "p|" #'luyangliuable/treemacs-shell-here-horizontal
  :desc "New shell for project (split)" "p@" #'luyangliuable/new-shell-for-project-split
  :desc "Maximize buffer" "wm" #'luyangliuable/toggle-maximize-buffer
  :desc "Ace window" "wW" #'ace-window
  :desc "Window management transient state" "w." #'hydra-window-management/body

  ;; File operations
  :desc "treemacs" "ft" #'treemacs
  :desc "Open file externally" "fo" #'luyangliuable/open-file-or-directory-in-external-app
  :desc "yank file directory" "fyd" #'luyangliuable/copy-directory-path
  :desc "yank file name" "fyn" #'luyangliuable/copy-file-name
  :desc "yank file file path" "fyy" #'luyangliuable/copy-file-path
  :desc "yank file file path with line number" "fyl" #'luyangliuable/copy-file-path-with-line

  ;; Git operations
  :desc "browse-at-remote" "xb" #'browse-at-remote

  ;;:desc "magit" "gs" #'luyangliuable/magit
  :desc "Run shell in project" "gs." #'magit
  :desc "Split window vertically and run shell" "gsv" (lambda () (interactive) (split-window-right) (other-window 1) (magit))
  :desc "Split window horizontally and run shell" "gss" (lambda () (interactive) (split-window-below) (other-window 1) (magit))
  :desc "Split window vertically and run shell" "gsV" (lambda () (interactive) (split-window-right) (other-window 1) (magit) (other-window -1))
  :desc "Split window horizontally and run shell" "gsS" (lambda () (interactive) (split-window-below) (other-window 1) (magit) (other-window -1))

  ;; Jump operations
  :desc "avy goto char" "jw" #'avy-goto-char
  :desc "goto last change" "jc" #'goto-last-change

  ;; Toggle operations
  :desc "absolute lineno toggle" "tna" #'luyangliuable/toggle-absolute-line-numbers
  :desc "relative lineno toggle" "tnr" #'luyangliuable/toggle-relative-line-numbers
  :desc "toggle mode line" "tmT" #'luyangliuable/toggle-mode-line
  :desc "toggle minimap" "tmM" #'minimap-mode
  :desc "toggle good scroll" "ts" #'good-scroll-mode
  :desc "centered buffer" "wcc" #'luyangliuable/toggle-centered-buffer
  :desc "distraction-free zen" "wcC" #'+zen/toggle-fullscreen
  :desc "centered buffer transient" "wc." #'luyangliuable/centered-buffer-transient-state
  :desc "set buffer font" "xf" #'luyangliuable/set-buffer-font
  :desc "reset buffer font" "xF" #'luyangliuable/reset-buffer-font
  :desc "whitespace mode" "tW" #'whitespace-mode
  :desc "golden ratio" "tG" #'golden-ratio-mode

  ;; Text operations
  :desc "drag stuff down" "xJ" #'luyangliuable/drag-stuff-down-repeatable
  :desc "drag stuff up" "xK" #'luyangliuable/drag-stuff-up-repeatable
  :desc "delete trailing whitespace" "xdw" #'delete-trailing-whitespace
  :desc "link-hint-copy-link-at-point" "xo" #'link-hint-open-link-at-point

  :desc "sort lines" "xls" #'luyangliuable/sort-lines

  ;; Project operations
  :desc "projectile find file based on string" "*s" #'helm-projectile-grep
  :desc "projectile find file based on string" "*f" #'helm-projectile-find-file

  ;; Help operations
  :desc "describe key" "hdk" #'describe-key

  ;; Misc operations
  :desc "M-x" "SPC" #'execute-extended-command
  :desc "evilnc comment operator" ";" #'evilnc-comment-operator

  ;; Search operations
  :desc "iedit mode" "s e" (cmd! (require 'evil-iedit-state)
                             (call-interactively #'evil-iedit-state/iedit-mode))
  :desc "Toggle symbol highlight" "sh" #'auto-highlight-symbol-mode

  ;; Frame operations
  :desc "Frame commands" "F" #'doom/frame-transient-state/body

  ;; Audio operations
  :desc "Say text" "ok" (lambda () (interactive)
                          (let ((text (read-string "Say: ")))
                            (when (not (string-empty-p text))
                              (start-process "say-text" nil "say" text)))))

;; Use plain Consult buffer switching instead of Doom workspace-aware switching.
(map! :leader
  (:prefix ("b" . "buffer")
    :desc "Switch buffer" "b" #'consult-buffer
    :desc "Switch buffer" "B" #'consult-buffer))

;; Browse remote links with explicit line/region anchors.
(map! :leader
  :desc "Browse remote line" "gol" #'luyangliuable/browse-at-remote-line)

(map! :leader
  :desc "Browse remote region" :v "goL" #'luyangliuable/browse-at-remote-region)

(after! origami
  (map! :map origami-mode-map
    :nm "za" #'origami-forward-toggle-node
    :nm "zc" #'origami-close-node
    :nm "zC" #'origami-close-node-recursively
    :nm "zo" #'origami-open-node
    :nm "zO" #'origami-open-node-recursively
    :nm "zr" #'origami-open-all-nodes
    :nm "zm" #'origami-close-all-nodes
    :nm "zs" #'origami-show-only-node
    :nm "zn" #'origami-next-fold
    :nm "zp" #'origami-previous-fold
    :nm "zR" #'origami-reset
    :nm "z <tab>" #'origami-recursively-toggle-node
    :nm "z TAB" #'origami-recursively-toggle-node))

(map! :leader
  (:prefix ("z" . "fold")
    :desc "Fold menu" "." #'luyangliuable/origami-hydra/body))

(map! :n "H" #'luyangliuable/close-fold-at-point)
