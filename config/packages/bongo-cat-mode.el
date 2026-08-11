;;; config/packages/bongo-cat-mode.el -*- lexical-binding: t; -*-
;; Bongo cat modeline companion

(use-package! bongo-cat-mode
  :init
  (setq bongo-cat-color-scheme 'white
    bongo-cat-height 20
    bongo-cat-track-baseline 0.79
    bongo-cat-track-width 18)
  :config
  (bongo-cat-mode-clear-cache)
  (bongo-cat-scroll-mode 1))
