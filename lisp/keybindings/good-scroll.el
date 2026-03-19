;;; config/keybindings/good-scroll.el -*- lexical-binding: t; -*-
;; Good scroll Keybindings - Complete operator+motion fix

(map!
 :n "C-u" #'good-scroll-down
 :n "C-d" #'good-scroll-up
 :n "C-b" #'good-scroll-up-full-screen
 :n "C-f" #'good-scroll-down-full-screen)
