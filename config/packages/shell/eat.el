;;; config/packages/shell/eat.el -*- lexical-binding: t; -*-
;; Eat shell backend.

(load! "eat-terminfo")

(use-package! eat
  :defer t
  :config
  (luyangliuable/eat-use-compiled-terminfo))

(load! "eat-evil")
