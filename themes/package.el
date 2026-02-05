;;; themes/package.el --- Theme package configuration

;;; Commentary:
;;
;; Package configuration for custom themes

;;; Code:

;; Define the frutiger-aero theme package
(package! frutiger-aero-theme
  :recipe (:local-repo "themes"
           :files ("*.el")))

;;; package.el ends here