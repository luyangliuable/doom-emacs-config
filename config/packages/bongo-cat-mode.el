;;; config/packages/bongo-cat-mode.el -*- lexical-binding: t; -*-
;; Bongo cat modeline companion

(use-package! bongo-cat-mode
  :init
  (setq bongo-cat-color-scheme 'white
    bongo-cat-height 22)
  :config
  (bongo-cat-mode-clear-cache)
  (bongo-cat-mode 1))
