;;; config/keybindings/undo-tree.el -*- lexical-binding: t; -*-
;; Spacemacs-compatible undo-tree behavior.


(use-package! undo-tree
  :defer t
  :init
  (setq undo-tree-visualizer-timestamps t
    undo-tree-visualizer-diff nil
    undo-tree-visualizer-spacing t
    undo-tree-visualizer-lazy-drawing nil
    undo-tree-enable-undo-in-region t
    undo-tree-mode-lighter nil)

  ;; Give the undo tree a Spacemacs-like wide right-hand split.
  (set-popup-rule! "^ \\*undo-tree\\*$"
    :side 'right
    :size 0.25
    :select t
    :quit nil
    :ttl nil)

  ;; Spacemacs enables undo-tree globally during initialization.  Doing the
  ;; same here loads `undo-tree' before `SPC a u' is installed, so the binding
  ;; always points at an interactive command rather than an unloaded symbol.
  (global-undo-tree-mode 1)

  ;; Evil explicitly recommends this for non-file buffers such as *scratch*.
  ;; It also covers buffers whose Evil local mode is enabled after startup.
  (add-hook 'evil-local-mode-hook #'turn-on-undo-tree-mode)

  (map! :leader
    :desc "Undo tree" "au" #'undo-tree-visualize)

  :config

  ;; Spacemacs restores this default because quitting the visualizer can leave
  ;; `undo-tree-visualizer-diff' disabled for the next invocation.
  (defadvice! luyangliuable/undo-tree-restore-default-diff-a (&rest _)
    :after #'undo-tree-visualizer-quit
    (setq undo-tree-visualizer-diff t))

  (evil-set-initial-state 'undo-tree-visualizer-mode 'normal)

  ;; Match Spacemacs's evilified visualizer controls while retaining the
  ;; visualizer's useful native commands where Evil would otherwise shadow
  ;; them.  `n'/`N' and the usual Evil scrolling keys remain Evil commands.
  (map! :map undo-tree-visualizer-mode-map
    :n "j" #'undo-tree-visualize-redo
    :n "k" #'undo-tree-visualize-undo
    :n "h" #'undo-tree-visualize-switch-branch-left
    :n "l" #'undo-tree-visualize-switch-branch-right
    :n "p" #'undo-tree-visualize-undo
    :n "b" #'undo-tree-visualize-switch-branch-left
    :n "f" #'undo-tree-visualize-switch-branch-right
    :n "t" #'undo-tree-visualizer-toggle-timestamps
    :n "d" #'undo-tree-visualizer-toggle-diff
    :n "s" #'undo-tree-visualizer-selection-mode
    :n "q" #'undo-tree-visualizer-quit
    :n "C-q" #'undo-tree-visualizer-abort
    :n "," #'undo-tree-visualizer-scroll-left
    :n "." #'undo-tree-visualizer-scroll-right
    :n "<" #'undo-tree-visualizer-scroll-left
    :n ">" #'undo-tree-visualizer-scroll-right
    :n "<up>" #'undo-tree-visualize-undo
    :n "<down>" #'undo-tree-visualize-redo
    :n "<left>" #'undo-tree-visualize-switch-branch-left
    :n "<right>" #'undo-tree-visualize-switch-branch-right
    :n "C-p" #'undo-tree-visualize-undo
    :n "C-n" #'undo-tree-visualize-redo
    :n "M-{" #'undo-tree-visualize-undo-to-x
    :n "M-}" #'undo-tree-visualize-redo-to-x
    :n "C-<up>" #'undo-tree-visualize-undo-to-x
    :n "C-<down>" #'undo-tree-visualize-redo-to-x
    :n "M-v" #'undo-tree-visualizer-scroll-down
    :n "C-v" #'undo-tree-visualizer-scroll-up
    :n "<prior>" #'undo-tree-visualizer-scroll-down
    :n "<next>" #'undo-tree-visualizer-scroll-up)

  ;; Keep selection mode usable from Evil normal state too.
  (map! :map undo-tree-visualizer-selection-mode-map
    :n "j" #'undo-tree-visualizer-select-next
    :n "k" #'undo-tree-visualizer-select-previous
    :n "h" #'undo-tree-visualizer-select-left
    :n "l" #'undo-tree-visualizer-select-right
    :n "p" #'undo-tree-visualizer-select-previous
    :n "b" #'undo-tree-visualizer-select-left
    :n "f" #'undo-tree-visualizer-select-right
    :n "RET" #'undo-tree-visualizer-set
    :n "d" #'undo-tree-visualizer-selection-toggle-diff))
