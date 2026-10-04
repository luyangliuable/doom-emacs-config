;;; config/packages/bongo-cat-mode.el -*- lexical-binding: t; -*-
;; Bongo cat modeline companion

(defun luyangliuable/bongo-cat-mode-line-dark-p ()
  "Return non-nil when the active mode-line background is dark."
  (let* ((background (face-background 'mode-line nil 'default))
         (rgb (and background (ignore-errors (color-values background)))))
    (if rgb
        (color-dark-p (mapcar (lambda (component) (/ component 65535.0)) rgb))
      (eq (frame-parameter nil 'background-mode) 'dark))))

(defun luyangliuable/bongo-cat-contrasting-rail-scheme ()
  "Return the rail asset scheme that contrasts with the active mode-line.
The package's white rail asset is black and its black rail asset is amber."
  (if (luyangliuable/bongo-cat-mode-line-d
ark-p) 'black 'white))

(defun luyangliuable/bongo-cat-rail-image-with-contrast
    (function kind &optional _scheme)
  "Render KIND with a rail asset that contrasts with the active mode-line."
  (funcall function kind (luyangliuable/bongo-cat-contrasting-rail-scheme)))

(defun luyangliuable/bongo-cat-refresh-rail (&rest _)
  "Clear cached Bongo Cat rail images after a theme change."
  (when (fboundp 'bongo-cat-mode-clear-cache)
    (bongo-cat-mode-clear-cache)))

(use-package! bongo-cat-mode
  :init
  ;; Keep the cat white regardless of theme; the rail is selected separately.
  (setq bongo-cat-color-scheme 'white
    bongo-cat-height 20
    bongo-cat-track-width 10)
  :config
  (advice-add 'bongo-cat-mode--rail-image :around
              #'luyangliuable/bongo-cat-rail-image-with-contrast)
  (luyangliuable/bongo-cat-refresh-rail)
  (bongo-cat-scroll-mode 1)
  (advice-add 'load-theme :after #'luyangliuable/bongo-cat-refresh-rail)
  (advice-add 'enable-theme :after #'luyangliuable/bongo-cat-refresh-rail))
