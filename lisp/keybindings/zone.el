;;; config/keybindings/zone.el -*- lexical-binding: t; -*-
;; Zone Keybindings - Standalone map! blocks only

;; Global keybindings for zone (available immediately, not deferred)
(map! :leader
      (:prefix-map ("a" . "applications")
                   (:prefix ("z" . "zone")
                            "d" #'zone-pgm-drip
                            "r" #'zone-pgm-rotate
                            "s" #'zone-pgm-stress)))
