;;; config/packages/bongo-cat-mode.el -*- lexical-binding: t; -*-
;; Bongo cat modeline companion

(use-package! bongo-cat-mode
  :init
  ;; White cat on every theme; the rail contrasts with the mode-line.
  (setq bongo-cat-color-scheme 'white
        bongo-cat-rail-color-scheme 'auto
        bongo-cat-height 20
        bongo-cat-track-width 10)
  :config
  (bongo-cat-scroll-mode 1))
