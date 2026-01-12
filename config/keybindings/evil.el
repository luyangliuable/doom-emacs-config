;;; config/keybindings/evil.el -*- lexical-binding: t; -*-
;; Evil Mode Keybindings

;; Fix for c$ and cw commands in evil mode
;; evil-collection sometimes disables these commands in certain contexts
;; This restores the proper bindings
(after! evil
  ;; Ensure change commands are properly bound in normal state
  (define-key evil-normal-state-map "c" #'evil-change)
  (define-key evil-normal-state-map "C" #'evil-change-line)

  ;; Additional fix: ensure the change operator can accept motions
  (evil-define-key 'normal 'global "c" #'evil-change)
  (evil-define-key 'normal 'global "C" #'evil-change-line)

  ;; Make sure motion state has the necessary motions
  (define-key evil-motion-state-map "$" #'evil-end-of-line)
  (define-key evil-motion-state-map "w" #'evil-forward-word-begin))