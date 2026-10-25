;;; config/keybindings/shell/core.el -*- lexical-binding: t; -*-

(pcase luyangliuable-shell-backend
  ('shell
   (load! "shell"))

  ('vterm
   (load! "vterm"))

  ('eat
   (load! "eat"))

  (_
   (error "Invalid `luyangliuable-shell-backend': %S"
          luyangliuable-shell-backend)))
