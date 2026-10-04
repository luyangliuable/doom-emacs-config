;;; tests/git-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defconst git-config-test--file
  (expand-file-name "../config/packages/git.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defun git-config-test--script (file body)
  (with-temp-file file (insert "#!/bin/sh\n" body "\n"))
  (set-file-modes file #o755)
  file)

(defmacro git-config-test--with-fakes (&rest body)
  "Run BODY with a fake git shim, the real git it runs, and `xcrun'.
Bind `shim-log', which records every run of the shim.  The fake git prints
the environment it was given."
  (declare (indent 0))
  `(let* ((root (make-temp-file "git-config-test" t))
          (bin (expand-file-name "bin" root))
          (dev (expand-file-name "dev" root))
          (shim-log (expand-file-name "shim.log" root)))
     (make-directory bin)
     (make-directory dev)
     (let* ((direct (git-config-test--script
                     (expand-file-name "git" dev)
                     "if [ \"$3\" = e ]; then exec /usr/bin/env -0; else exec /usr/bin/env; fi"))
            (shim (git-config-test--script
                   (expand-file-name "git" bin)
                   (format "echo run >> %s\nexport SDKROOT=/sdk CPATH=/inc\nunset DROPME\nexec %s \"$@\""
                           shim-log direct))))
       (git-config-test--script (expand-file-name "xcrun" bin)
                                (format "[ \"$*\" = '--find git' ] && echo %s" direct))
       (ignore shim)
       (unwind-protect
           (let ((exec-path (list bin "/usr/bin" "/bin"))
                 (process-environment
                  ;; Never the real environment: failures would print secrets.
                  (list "DROPME=1" "PATH=/usr/bin:/bin" (concat "HOME=" root)))
                 (default-directory (file-name-as-directory root))
                 (luyangliuable/git-shim shim)
                 (luyangliuable/git-direct 'unset))
             ,@body)
         (delete-directory root t)))))

(defun git-config-test--shim-runs (shim-log)
  (if (file-exists-p shim-log)
      (with-temp-buffer
        (insert-file-contents shim-log)
        (count-lines (point-min) (point-max)))
    0))

(defun git-config-test--env (lines)
  (sort (cl-remove-if (lambda (line) (string-prefix-p "_=" line)) (copy-sequence lines))
        #'string<))

(defun git-config-test--resolve ()
  "Run the background lookup and wait for it; return the result."
  (luyangliuable/git-direct-resolve)
  (with-timeout (10 (error "git lookup did not finish"))
    (while (eq luyangliuable/git-direct 'pending)
      (accept-process-output nil 0.02)))
  luyangliuable/git-direct)

(load git-config-test--file t t)
(require 'vc-git)
(require 'magit-process)

(ert-deftest git-config-finds-real-git-and-shim-environment ()
  (git-config-test--with-fakes
    (let ((direct (git-config-test--resolve)))
      (should (equal (expand-file-name "dev/git" root) (car direct)))
      (should (equal '("CPATH=/inc" "DROPME" "SDKROOT=/sdk")
                     (sort (cl-remove-if (lambda (e) (string-prefix-p "_=" e))
                                         (copy-sequence (cdr direct)))
                           #'string<)))
      (let ((runs (git-config-test--shim-runs shim-log)))
        (luyangliuable/git-direct-resolve)
        (should (eq direct luyangliuable/git-direct))
        (should (= runs (git-config-test--shim-runs shim-log)))))))

(ert-deftest git-config-keeps-shim-when-git-is-not-the-shim ()
  (git-config-test--with-fakes
    (let ((exec-path (list "/usr/bin" "/bin"))
          (luyangliuable/git-shim (expand-file-name "bin/git" root)))
      (luyangliuable/git-direct-resolve)
      (should-not luyangliuable/git-direct))))

(ert-deftest git-config-vc-runs-real-git-with-shim-environment ()
  (git-config-test--with-fakes
    (let ((via-shim
           (let ((luyangliuable/git-direct nil))
             (git-config-test--env (split-string (vc-git--out-str "status") "\n" t)))))
      (should (= 1 (git-config-test--shim-runs shim-log)))
      (git-config-test--resolve)
      (let ((runs (git-config-test--shim-runs shim-log))
            (direct (git-config-test--env
                     (split-string (vc-git--out-str "status") "\n" t))))
        (should (= runs (git-config-test--shim-runs shim-log)))
        (should (equal via-shim direct))
        (should (member "SDKROOT=/sdk" direct)))
      (cl-flet ((command-env ()
                  (with-temp-buffer
                    (vc-git-command t 0 nil "status")
                    (git-config-test--env (split-string (buffer-string) "\n" t)))))
        (let ((via-shim (let ((luyangliuable/git-direct nil)) (command-env)))
              (runs (git-config-test--shim-runs shim-log)))
          (should (equal via-shim (command-env)))
          (should (= runs (git-config-test--shim-runs shim-log))))))))

(ert-deftest git-config-vc-keeps-shim-for-remote-and-custom-program ()
  (git-config-test--with-fakes
    (git-config-test--resolve)
    (let (seen)
      (dolist (case '(("/ssh:nohost:/tmp/" . "git") ("/tmp/" . "/opt/git")))
        (let ((default-directory (car case))
              (vc-git-program (cdr case)))
          (luyangliuable/vc-git-direct-a
           (lambda () (push (list exec-path process-environment) seen)))))
      (dolist (s seen)
        (should (equal (list exec-path process-environment) s))))))

(ert-deftest git-config-magit-runs-real-git-with-shim-environment ()
  (git-config-test--with-fakes
    (let* ((magit-git-executable luyangliuable/git-shim)
           (via-shim (git-config-test--env (magit-git-lines "status"))))
      (should (= 1 (git-config-test--shim-runs shim-log)))
      (git-config-test--resolve)
      (should (equal (expand-file-name "dev/git" root) magit-git-executable))
      (let ((runs (git-config-test--shim-runs shim-log)))
        (should (equal via-shim (git-config-test--env (magit-git-lines "status"))))
        (should (= runs (git-config-test--shim-runs shim-log))))
      (let ((default-directory "/ssh:nohost:/tmp/"))
        (should-not (member "SDKROOT=/sdk" (magit-process-environment)))))))

(ert-deftest git-config-magit-keeps-custom-executable ()
  (git-config-test--with-fakes
    (let ((magit-git-executable "/opt/git"))
      (git-config-test--resolve)
      (luyangliuable/magit-git-direct-h)
      (should (equal "/opt/git" magit-git-executable))
      (should-not (member "SDKROOT=/sdk" (magit-process-environment))))))

(ert-deftest git-config-loading-runs-no-git ()
  (git-config-test--with-fakes
    (dlet ((features (remq 'magit-git (remq 'vc-git features)))
           (after-load-alist nil))
      (load git-config-test--file nil t))
    (should (eq 'unset luyangliuable/git-direct))
    (should (= 0 (git-config-test--shim-runs shim-log)))))

(ert-deftest git-config-resolves-at-first-idle ()
  (git-config-test--with-fakes
    (let ((timer-idle-list nil))
      (dlet ((features (remq 'magit-git (remq 'vc-git features)))
             (after-load-alist nil))
        (load git-config-test--file nil t))
      (should (equal '(luyangliuable/git-direct-resolve)
                     (mapcar #'timer--function timer-idle-list))))))

(ert-deftest git-config-uses-shim-until-resolved ()
  (git-config-test--with-fakes
    (let ((magit-git-executable "git"))
      (luyangliuable/git-direct-resolve)
      (should (eq 'pending luyangliuable/git-direct))
      (vc-git--out-str "status")
      (should (= 1 (git-config-test--shim-runs shim-log)))
      (git-config-test--resolve)
      (should (equal (expand-file-name "dev/git" root) magit-git-executable)))))

(ert-deftest git-config-keeps-shim-when-lookup-fails ()
  (git-config-test--with-fakes
    (git-config-test--script (expand-file-name "bin/xcrun" root)
                             (format "echo %s; exit 1" (expand-file-name "dev/git" root)))
    (should-not (git-config-test--resolve))
    (let ((magit-git-executable "git"))
      (luyangliuable/magit-git-direct-h)
      (should (equal "git" magit-git-executable)))))

(ert-deftest git-config-keeps-shim-without-xcrun ()
  (git-config-test--with-fakes
    (delete-file (expand-file-name "bin/xcrun" root))
    (let ((exec-path (list (expand-file-name "bin" root))))
      (should-not (git-config-test--resolve)))))
