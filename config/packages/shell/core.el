;;; config/packages/shell/core.el -*- lexical-binding: t; -*-

(pcase luyangliuable-shell-backend
  ('shell
   (load! "shell"))

  ('vterm
   (load! "vterm"))

  ('eat
   (load! "eat"))

  (backend
   (error "Unknown shell backend: %S" backend)))
