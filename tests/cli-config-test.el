;;; cli-config-test.el --- Tests for cli.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defvar doom-after-sync-hook nil)

(defconst cli-config-test--file
  (expand-file-name "../cli.el" (file-name-directory (or load-file-name buffer-file-name))))

(load cli-config-test--file t t)

(defun cli-config-test--write (file &rest lines)
  (make-directory (file-name-directory file) t)
  (with-temp-file file
    (insert ";;; -*- lexical-binding: t; -*-\n" (string-join lines "\n") "\n")))

(defmacro cli-config-test--with-build (&rest body)
  "Run BODY with `build', a straight build dir whose packages need
undeclared packages (one in a lisp/ subdir, one in sly/contrib/)."
  (declare (indent 0))
  `(let* ((build (file-name-as-directory (make-temp-file "cli-build" t))))
     (unwind-protect
         (progn
           (cli-config-test--write (expand-file-name "dep/dep.el" build)
                                   "(defmacro dep-m () 1)" "(provide 'dep)")
           (cli-config-test--write (expand-file-name "workspace-hud/lisp/hud.el" build)
                                   "(defmacro hud-m () 2)" "(provide 'hud)")
           (cli-config-test--write (expand-file-name "sly/contrib/sly-x.el" build)
                                   "(defmacro sly-x-m () 3)" "(provide 'sly-x)")
           (cli-config-test--write (expand-file-name "pkg/pkg.el" build)
                                   "(require 'dep)" "(require 'hud)" "(require 'sly-x)"
                                   "(defun pkg-f () (+ (dep-m) (hud-m) (sly-x-m)))"
                                   "(provide 'pkg)")
           (cli-config-test--write (expand-file-name "pkg/pkg-autoloads.el" build)
                                   ";; Local Variables:" ";; version-control: never"
                                   ";; no-byte-compile: t" ";; End:")
           (cli-config-test--write (expand-file-name "other/other.el" build)
                                   "(provide 'other)")
           ,@body)
       (delete-directory build t))))

(defun cli-config-test--elc (build file)
  (file-exists-p (expand-file-name file build)))

(ert-deftest cli-config-compiles-missing-elc-with-runtime-load-path ()
  (cli-config-test--with-build
    (should (equal '("pkg") (luyangliuable/compile-missing-elc build '("pkg"))))
    (should (cli-config-test--elc build "pkg/pkg.elc"))
    (should-not (cli-config-test--elc build "other/other.elc"))
    (should-not (cli-config-test--elc build "dep/dep.elc"))
    (should (equal "6" (with-output-to-string
                         (call-process (expand-file-name invocation-name invocation-directory)
                                       nil standard-output nil "-Q" "--batch" "--eval"
                                       (format "(progn (setq load-path (append '%S load-path))
                                                       (load %S nil t t) (prin1 (pkg-f)))"
                                               (mapcar (lambda (d) (expand-file-name d build))
                                                       '("dep" "workspace-hud/lisp" "sly/contrib"))
                                               (expand-file-name "pkg/pkg.elc" build))))))))

(ert-deftest cli-config-skips-packages-already-compiled ()
  (cli-config-test--with-build
    (luyangliuable/compile-missing-elc build '("pkg"))
    (let ((stamp (file-attribute-modification-time
                  (file-attributes (expand-file-name "pkg/pkg.elc" build)))))
      (should-not (luyangliuable/compile-missing-elc build '("pkg")))
      (should (equal stamp (file-attribute-modification-time
                            (file-attributes (expand-file-name "pkg/pkg.elc" build))))))))

(ert-deftest cli-config-ignores-missing-and-failing-packages ()
  (cli-config-test--with-build
    (cli-config-test--write (expand-file-name "bad/bad.el" build) "(require 'nope)")
    (should (equal '("bad") (luyangliuable/compile-missing-elc build '("absent" "bad"))))
    (should-not (cli-config-test--elc build "bad/bad.elc"))))

(ert-deftest cli-config-runs-after-doom-sync ()
  (should (memq #'luyangliuable/compile-missing-elc-h doom-after-sync-hook))
  (should (equal '("agent-shell-hud" "evil-markdown" "lsp-vtsls" "sly-stepper" "stylus-mode")
                 luyangliuable/compile-missing-elc-packages)))

(ert-deftest cli-config-hook-uses-straight-build-dir ()
  (cli-config-test--with-build
    (cl-letf (((symbol-function 'straight--build-dir) (lambda (&rest _) build)))
      (let ((luyangliuable/compile-missing-elc-packages '("pkg")))
        (luyangliuable/compile-missing-elc-h)))
    (should (cli-config-test--elc build "pkg/pkg.elc"))))

;;; cli-config-test.el ends here
