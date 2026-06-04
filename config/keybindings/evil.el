;;; config/keybindings/evil.el -*- lexical-binding: t; -*-
;; Evil Mode Keybindings - Complete operator+motion fix

;; Core evil operator and motion system fix
(after! evil
  ;; Ensure evil is fully loaded with operator support
  (when (featurep 'evil)
    (evil-mode 1))

  ;; CRITICAL: Unbind comma from evil-repeat-find-char-reverse
  ;; This allows doom-localleader-key "," to work properly
  (define-key evil-normal-state-map "," nil)
  (define-key evil-motion-state-map "," nil)
  (define-key evil-visual-state-map "," nil)

  ;; Ensure all basic operators are properly defined
  (define-key evil-normal-state-map "c" #'evil-change)
  (define-key evil-normal-state-map "d" #'evil-delete)
  (define-key evil-normal-state-map "y" #'evil-yank)
  (define-key evil-normal-state-map "C" #'evil-change-line)
  (define-key evil-normal-state-map "D" #'evil-delete-line)
  (define-key evil-normal-state-map "Y" #'evil-yank-line)

  ;; Ensure operator-pending state map exists and has all motions
  (unless (and (boundp 'evil-operator-state-map) evil-operator-state-map)
    (setq evil-operator-state-map (copy-keymap evil-motion-state-map)))

  ;; Essential motions in operator-pending state
  (define-key evil-operator-state-map "$" #'evil-end-of-line)
  (define-key evil-operator-state-map "w" #'evil-forward-word-begin)
  (define-key evil-operator-state-map "W" #'evil-forward-WORD-begin)
  (define-key evil-operator-state-map "b" #'evil-backward-word-begin)
  (define-key evil-operator-state-map "B" #'evil-backward-WORD-begin)
  (define-key evil-operator-state-map "e" #'evil-forward-word-end)
  (define-key evil-operator-state-map "E" #'evil-forward-WORD-end)
  (define-key evil-operator-state-map "0" #'evil-beginning-of-line)
  (define-key evil-operator-state-map "^" #'evil-first-non-blank)
  (define-key evil-operator-state-map "g_" #'evil-last-non-blank)
  (define-key evil-operator-state-map "gg" #'evil-goto-first-line)
  (define-key evil-operator-state-map "G" #'evil-goto-line)
  (define-key evil-operator-state-map "h" #'evil-backward-char)
  (define-key evil-operator-state-map "j" #'evil-next-line)
  (define-key evil-operator-state-map "k" #'evil-previous-line)
  (define-key evil-operator-state-map "l" #'evil-forward-char)

  ;; Also ensure these motions work in motion state
  (define-key evil-motion-state-map "$" #'evil-end-of-line)
  (define-key evil-motion-state-map "w" #'evil-forward-word-begin)
  (define-key evil-motion-state-map "W" #'evil-forward-WORD-begin)
  (define-key evil-motion-state-map "b" #'evil-backward-word-begin)
  (define-key evil-motion-state-map "B" #'evil-backward-WORD-begin)
  (define-key evil-motion-state-map "e" #'evil-forward-word-end)
  (define-key evil-motion-state-map "E" #'evil-forward-WORD-end)

  ;; Ensure evil modes are properly initialized
  (when (fboundp 'evil-normalize-keymaps)
    (evil-normalize-keymaps)))

;; Additional hook to restore functionality after evil-collection loads
(add-hook 'evil-collection-setup-hook
          (lambda (_mode keymaps)
            ;; Restore operator functionality if it gets disabled
            (when (bound-and-true-p evil-mode)
              (define-key evil-normal-state-map "c" #'evil-change)
              (define-key evil-normal-state-map "d" #'evil-delete)
              (define-key evil-normal-state-map "y" #'evil-yank))))
