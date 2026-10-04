;;; cli.el --- Doom CLI configuration -*- lexical-binding: t; -*-

;; straight byte-compiles each package with only its declared dependencies on
;; `load-path', so these packages, which require undeclared ones, fail to
;; compile and run interpreted. After each sync, compile them the way straight
;; does, but with the `load-path' they get at runtime.

(defvar luyangliuable/compile-missing-elc-packages
  '("agent-shell-hud" "evil-markdown" "lsp-vtsls" "sly-stepper" "stylus-mode"))

(defun luyangliuable/compile-missing-elc (build packages)
  "Byte-compile PACKAGES in straight BUILD dir that lack .elc files.
Return the packages compiled."
  (let ((load-path-dirs
         (append (list (expand-file-name "workspace-hud/lisp/" build)
                       (expand-file-name "sly/contrib/" build))
                 (seq-filter #'file-directory-p (directory-files build t "\\`[^.]"))))
        compiled)
    (dolist (pkg packages (nreverse compiled))
      (let ((dir (expand-file-name pkg build)))
        (when (and (file-directory-p dir)
                   (seq-some (lambda (el) (not (file-exists-p (concat el "c"))))
                             (seq-remove (lambda (el) (string-match-p "-\\(autoloads\\|pkg\\)\\.el\\'" el))
                                         (directory-files dir t "\\.el\\'"))))
          (message "Byte-compiling %s" pkg)
          (let ((print-length nil) (print-level nil) (print-circle nil))
            (call-process (expand-file-name invocation-name invocation-directory) nil nil nil
                          "-Q" "--batch" "--eval"
                          (format "%S" `(progn (setq load-path (append '(,dir) ',load-path-dirs load-path))
                                               (byte-recompile-directory ,dir 0 'force)))))
          (push pkg compiled))))))

(defun luyangliuable/compile-missing-elc-h ()
  (with-demoted-errors "Byte-compiling missing packages: %S"
    (luyangliuable/compile-missing-elc (straight--build-dir)
                                       luyangliuable/compile-missing-elc-packages)))

(add-hook 'doom-after-sync-hook #'luyangliuable/compile-missing-elc-h)
