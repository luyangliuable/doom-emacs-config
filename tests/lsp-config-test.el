;;; tests/lsp-config-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defconst lsp-config-test--dir
  (file-name-directory (or load-file-name buffer-file-name)))

(defconst lsp-config-test--file
  (expand-file-name "../config/packages/lsp.el" lsp-config-test--dir))

(defmacro after! (feature &rest body)
  `(with-eval-after-load ',feature ,@body))

(defmacro use-package! (&rest args)
  `(use-package ,@args))

(defmacro map! (&rest _))

(load (expand-file-name "../config/packages/performance.el" lsp-config-test--dir)
      nil t)

(defvar lsp-config-test--log nil
  "Features and LSP calls in order, newest first.")

(defvar lsp-config-test--dirs nil
  "Temporary directories to delete after a test.")

(defvar-local lsp-config-test--root nil
  "The project root the Projectile stubs report for the current buffer.")

(defun projectile-project-p (&rest _) lsp-config-test--root)
(defun projectile-project-root (&rest _) lsp-config-test--root)

(defconst lsp-config-test--lsp-variables
  '(lsp-language-id-configuration lsp-file-watch-ignored-directories
    lsp-auto-configure lsp-client-packages lsp--client-packages-required
    lct-clojure-test-tree lsp--buffer-workspaces lsp-managed-mode lsp-mode
    lsp-mode-hook lsp-configure-hook lsp-after-uninitialized-functions))

(defconst lsp-config-test--lsp-functions
  '(lsp lsp-deferred lsp--require-packages lsp-mode lsp-configure-buffer
    lsp-diagnostics-flycheck-enable))

(defun lsp-config-test--libraries ()
  "Make a directory of fake LSP libraries that log their loading and calls."
  (let ((dir (make-temp-file "lsp-config-test" t)))
    (pcase-dolist
        (`(,feature . ,body)
         '((lct-dep)
           (lct-client-a)
           (lct-client-b)
           (lsp-treemacs)
           ;; As the real one, which loads lsp-treemacs for a capability.
           (lsp-clojure
            (defvar lct-clojure-test-tree (and (require 'lsp-treemacs nil t) t)))
           (lsp-mode
            ";;; Code:"
            (require 'lct-dep)
            (defvar lsp-language-id-configuration nil)
            (defvar lsp-file-watch-ignored-directories nil)
            (defvar lsp-auto-configure t)
            (defvar lsp-client-packages
              '(lct-client-a lct-missing lsp-clojure lct-client-b))
            (defvar lsp--client-packages-required nil)
            (defvar-local lsp--buffer-workspaces nil)
            (defvar-local lsp-managed-mode nil)
            (defvar lsp-configure-hook nil)
            (defvar lsp-after-uninitialized-functions nil)
            (define-minor-mode lsp-mode "Fake.")
            (defun lsp-configure-buffer () (run-hooks 'lsp-configure-hook))
            (defun lsp--require-packages ()
              (when (and lsp-auto-configure (not lsp--client-packages-required))
                (dolist (package lsp-client-packages)
                  (require package nil t))
                (setq lsp--client-packages-required t)))
            (defun lsp (&rest _)
              (lsp--require-packages)
              (push (list 'lsp lsp-config-test--root) lsp-config-test--log))
            (defun lsp-deferred ()
              (push (list 'lsp-deferred lsp-config-test--root)
                    lsp-config-test--log)))))
      (with-temp-file (expand-file-name (format "%s.el" feature) dir)
        (insert ";;; -*- lexical-binding: t; -*-\n")
        (dolist (form body)
          (if (stringp form) (insert form) (prin1 form (current-buffer)))
          (insert "\n"))
        (prin1 `(push ',feature lsp-config-test--log) (current-buffer))
        (prin1 `(provide ',feature) (current-buffer))))
    dir))

(defun lsp-config-test--project (&rest gitignore-lines)
  "Make a project directory whose .gitignore holds GITIGNORE-LINES."
  (let ((dir (file-name-as-directory (make-temp-file "lsp-config-test" t))))
    (push dir lsp-config-test--dirs)
    (with-temp-file (expand-file-name ".gitignore" dir)
      (insert "# comment\n\n" (string-join gitignore-lines "\n") "\n"))
    dir))

(defmacro lsp-config-test--with-config (&rest body)
  "Load lsp.el as Doom does, with fake LSP libraries, then run BODY."
  (declare (indent 0))
  `(let* ((lsp-config-test--dirs (list (lsp-config-test--libraries)))
          (load-path (cons (car lsp-config-test--dirs) load-path))
          (after-load-alist nil)
          (after-load-functions nil)
          (lsp-config-test--log nil))
     (dlet ((features features))
       (unwind-protect
           (progn
             ;; Doom defines package autoloads before it loads the config.
             (autoload 'lsp "lsp-mode" nil t)
             (autoload 'lsp-deferred "lsp-mode")
             (let ((exec-path nil))     ; skip the emacs-lsp-booster setup
               (load lsp-config-test--file nil t t))
             ,@body)
         (dolist (fn lsp-config-test--lsp-functions)
           (fmakunbound fn)
           (put fn 'advice--pending nil))
         (mapc #'makunbound lsp-config-test--lsp-variables)
         (dolist (dir lsp-config-test--dirs)
           (delete-directory dir t))))))

(defun lsp-config-test--run-idle-timers ()
  "Run the pending idle-loading steps, as Emacs would while idle."
  (while-let ((timer (cl-find #'luyangliuable/require-when-idle timer-idle-list
                              :key #'timer--function)))
    (cancel-timer timer)
    (apply (timer--function timer) (timer--args timer))))

(defun lsp-config-test--base-ignored ()
  "Return the watch-ignore list that `my/setup-lsp-file-watch-ignored' sets."
  (dlet ((lsp-file-watch-ignored-directories nil))
    (my/setup-lsp-file-watch-ignored)
    lsp-file-watch-ignored-directories))

(ert-deftest lsp-config-preload-loads-lsp-mode-then-clients ()
  (lsp-config-test--with-config
    (with-temp-buffer
      (setq lsp-config-test--root (lsp-config-test--project "dist/"))
      (luyangliuable/preload-lsp)
      (lsp-config-test--run-idle-timers))
    (should (equal '(lct-dep lsp-mode lct-client-a lct-client-b)
                   (reverse lsp-config-test--log)))
    ;; The project's .gitignore waits for the first LSP start.
    (should (equal (lsp-config-test--base-ignored)
                   lsp-file-watch-ignored-directories))))

(ert-deftest lsp-config-preload-loads-clients-only-when-lsp-would ()
  (lsp-config-test--with-config
    (let (preload required)
      (cl-letf (((symbol-function 'luyangliuable/preload-when-idle)
                 (lambda (&rest args) (setq preload args)))
                ((symbol-function 'luyangliuable/require-when-idle)
                 (lambda (features &rest _) (push features required))))
        (luyangliuable/preload-lsp)
        (should (eq 'lsp-mode (car preload)))
        (pcase-dolist (`(,auto-configure ,already-required)
                       '((t nil) (nil nil) (t t)))
          (dlet ((lsp-client-packages '(pkg-a pkg-b))
                 (lsp-auto-configure auto-configure)
                 (lsp--client-packages-required already-required))
            (funcall (cadr preload)))))
      (should (equal '(((pkg-a nil t) (pkg-b nil t))) required)))))

(ert-deftest lsp-config-first-lsp-start-finishes-setup-once ()
  (lsp-config-test--with-config
    (let ((a (lsp-config-test--project "dist-a/" "*.log"))
          (b (lsp-config-test--project "dist-b/"))
          ignored)
      (require 'lsp-mode)
      (should-not (featurep 'lsp-treemacs))
      (with-temp-buffer
        (setq lsp-config-test--root a)
        (lsp-deferred))
      (setq ignored (append (lsp-config-test--base-ignored)
                            (mapcar #'my/gitignore-to-regex '("dist-a/" "*.log"))))
      (should (equal ignored lsp-file-watch-ignored-directories))
      (with-temp-buffer
        (setq lsp-config-test--root b)
        (lsp))
      (should (equal ignored lsp-file-watch-ignored-directories))
      (should (equal `(lct-dep lsp-mode lsp-treemacs (lsp-deferred ,a)
                       lct-client-a lsp-clojure lct-client-b (lsp ,b))
                     (reverse lsp-config-test--log)))
      (should lct-clojure-test-tree))))

(ert-deftest lsp-config-first-lsp-start-can-load-lsp-mode ()
  (lsp-config-test--with-config
    (let ((a (lsp-config-test--project "dist-a/")))
      (with-temp-buffer
        (setq lsp-config-test--root a)
        (lsp-deferred))
      (should (equal (append (lsp-config-test--base-ignored)
                             (list (my/gitignore-to-regex "dist-a/")))
                     lsp-file-watch-ignored-directories))
      (should (equal `(lct-dep lsp-mode lsp-treemacs (lsp-deferred ,a))
                     (reverse lsp-config-test--log))))))

(ert-deftest lsp-config-server-commands-finish-setup-before-clients-load ()
  ;; `lsp-install-server' and co. load the clients without starting LSP.
  (lsp-config-test--with-config
    (let ((a (lsp-config-test--project "dist-a/")))
      (with-temp-buffer
        (setq lsp-config-test--root a)
        (luyangliuable/preload-lsp)
        (lsp-config-test--run-idle-timers)
        (lsp--require-packages))
      (should (equal (append (lsp-config-test--base-ignored)
                             (list (my/gitignore-to-regex "dist-a/")))
                     lsp-file-watch-ignored-directories))
      (should (equal '(lct-dep lsp-mode lct-client-a lct-client-b
                       lsp-treemacs lsp-clojure)
                     (reverse lsp-config-test--log)))
      (should lct-clojure-test-tree))))

(ert-deftest lsp-config-preload-of-real-clients-leaves-lsp-treemacs-unloaded ()
  "Preload the real client packages in a separate Emacs, then call `lsp':
lsp-treemacs (and treemacs) wait for the first start's setup."
  (skip-unless (locate-library "lsp-mode"))
  (let ((dir (make-temp-file "lsp-config-test" t)))
    (unwind-protect
        (with-temp-buffer
          (should
           (zerop
            (call-process
             (expand-file-name invocation-name invocation-directory) nil
             (list t nil) nil "-Q" "--batch"
             "--eval" (prin1-to-string
                       `(setq load-path ',load-path
                              user-emacs-directory ,(file-name-as-directory dir)
                              native-comp-enable-subr-trampolines nil
                              native-comp-jit-compilation nil))
             "-l" (expand-file-name "lsp-config-test.el" lsp-config-test--dir)
             "--eval"
             (prin1-to-string
              '(progn
                 (let ((exec-path nil))
                   (load lsp-config-test--file nil t t))
                 (luyangliuable/preload-lsp)
                 (lsp-config-test--run-idle-timers)
                 (prin1
                  (list
                   :preloaded
                   (cl-every (lambda (package)
                               (or (featurep package)
                                   (eq package 'lsp-clojure)
                                   (not (locate-library (symbol-name package)))))
                             lsp-client-packages)
                   (featurep 'lsp-clojure)
                   (featurep 'lsp-treemacs)
                   (featurep 'treemacs)))
                 (with-temp-buffer (lsp))
                 (prin1
                  (list
                   :started
                   (and (advice-member-p #'luyangliuable/lsp-first-start-a
                                         'lsp-deferred)
                        t)
                   (featurep 'lsp-treemacs)
                   (thread-last (gethash 'clojure-lsp lsp-clients)
                                lsp--client-custom-capabilities
                                (alist-get 'experimental)
                                (alist-get 'testTree)))))))))
          (should (equal "(:preloaded t nil nil nil)(:started nil t t)"
                         (buffer-string))))
      (delete-directory dir t))))

(ert-deftest lsp-config-typescript-settings-without-typescript-installed ()
  "With lsp-volar loaded but no TypeScript in the project, on PATH or in the
LSP server directory, the \"typescript\" settings a server (vtsls) asks for
leave `typescript.tsdk' empty, as lsp-volar intends, rather than signal."
  (skip-unless (locate-library "lsp-volar"))
  (let ((dir (file-name-as-directory (make-temp-file "lsp-config-test" t))))
    (unwind-protect
        (with-temp-buffer
          (should
           (zerop
            (call-process
             (expand-file-name invocation-name invocation-directory) nil
             (list t nil) nil "-Q" "--batch"
             "--eval" (prin1-to-string
                       `(setq load-path ',load-path
                              user-emacs-directory ,dir
                              native-comp-enable-subr-trampolines nil
                              native-comp-jit-compilation nil))
             "-l" (expand-file-name "lsp-config-test.el" lsp-config-test--dir)
             "--eval"
             (prin1-to-string
              `(let ((exec-path nil))
                 (load lsp-config-test--file nil t t)
                 (require 'lsp-mode)
                 (require 'lsp-volar)
                 (setq lsp-server-install-dir ,dir
                       default-directory ,dir)
                 (prin1
                  (condition-case err
                      (thread-last (lsp-configuration-section "typescript")
                                   (gethash "typescript")
                                   (gethash "tsdk"))
                    (error err))))))))
          (should (equal "\"\"" (buffer-string))))
      (delete-directory dir t))))

;;; Flycheck while LSP starts

(define-derived-mode lsp-config-test-mode prog-mode "LCT")

(defun lsp-config-test--checker-start (checker callback)
  "Log a run of CHECKER, then report no errors to CALLBACK."
  (push (list 'check checker) lsp-config-test--log)
  (funcall callback 'finished nil))

(defmacro lsp-config-test--with-checked-buffer (&rest body)
  "Run BODY in a shown buffer whose file LSP is deferred for.
BODY runs as Emacs opens the file: `lsp-deferred' from the mode hook, then
`flycheck-mode' and a command loop step.  Return the log, oldest first."
  (declare (indent 0))
  `(lsp-config-test--with-config
     (require 'flycheck)
     (require 'lsp-mode)
     (dolist (checker '(lct-eslint lct-lsp))
       (flycheck-define-generic-checker checker "Fake."
         :start #'lsp-config-test--checker-start
         :modes '(lsp-config-test-mode)))
     ;; As the real one, without the parts unrelated to automatic checks.
     (defalias 'lsp-diagnostics-flycheck-enable
       (lambda (&rest _)
         (flycheck-mode 1)
         (flycheck-stop)
         (setq-local flycheck-checker 'lct-lsp)))
     (let ((flycheck-checkers '(lct-eslint))
           (buffer (get-buffer-create "lsp-config-test.lct")))
       (unwind-protect
           (with-current-buffer buffer
             (switch-to-buffer buffer)
             (lsp-config-test-mode)
             (lsp-deferred)
             (setq lsp-config-test--log nil)
             (flycheck-mode 1)
             (flycheck-perform-deferred-syntax-check)
             ,@body
             (flycheck-perform-deferred-syntax-check)
             (reverse lsp-config-test--log))
         (kill-buffer buffer)))))

(defun lsp-config-test--start-lsp (&optional workspaces)
  "Make `lsp' connect the buffer to WORKSPACES, then call it."
  (defalias 'lsp
    (lambda (&rest _)
      (when (setq lsp--buffer-workspaces workspaces)
        (lsp-mode 1))))
  (lsp))

(ert-deftest lsp-config-flycheck-waits-for-lsp-diagnostics ()
  ;; LSP's checker runs at the next command, as without the hold.
  (should (equal '(configured (check lct-lsp))
                 (lsp-config-test--with-checked-buffer
                   (flycheck-buffer-automatically 'save)
                   (flycheck-perform-deferred-syntax-check)
                   (lsp-config-test--start-lsp '(ws))
                   (add-hook 'lsp-configure-hook
                             #'lsp-diagnostics-flycheck-enable nil t)
                   (lsp-configure-buffer)
                   (push 'configured lsp-config-test--log)))))

(ert-deftest lsp-config-flycheck-checks-when-lsp-finds-no-server ()
  (should (equal '((check lct-eslint))
                 (lsp-config-test--with-checked-buffer
                   (lsp-config-test--start-lsp nil)))))

(ert-deftest lsp-config-flycheck-checks-when-lsp-fails ()
  (should (equal '((check lct-eslint))
                 (lsp-config-test--with-checked-buffer
                   (defalias 'lsp (lambda (&rest _) (error "No server")))
                   (should-error (lsp))))))

(ert-deftest lsp-config-flycheck-checks-when-the-server-exits ()
  (should (equal '((check lct-eslint))
                 (lsp-config-test--with-checked-buffer
                   (lsp-config-test--start-lsp '(ws))
                   (run-hook-with-args 'lsp-after-uninitialized-functions 'ws)))))

(ert-deftest lsp-config-flycheck-waits-while-another-server-starts ()
  (should (equal '()
                 (lsp-config-test--with-checked-buffer
                   (lsp-config-test--start-lsp '(ws other))
                   (run-hook-with-args 'lsp-after-uninitialized-functions 'ws)))))

(ert-deftest lsp-config-flycheck-checks-when-lsp-disconnects ()
  (should (equal '((check lct-eslint))
                 (lsp-config-test--with-checked-buffer
                   (lsp-config-test--start-lsp '(ws))
                   (setq lsp--buffer-workspaces nil)
                   (lsp-mode -1)))))

(ert-deftest lsp-config-flycheck-checks-when-lsp-uses-other-diagnostics ()
  (should (equal '((check lct-eslint))
                 (lsp-config-test--with-checked-buffer
                   (lsp-config-test--start-lsp '(ws))
                   (lsp-configure-buffer)))))

(ert-deftest lsp-config-flycheck-manual-check-runs-while-lsp-starts ()
  (should (equal '((check lct-eslint))
                 (lsp-config-test--with-checked-buffer
                   (flycheck-buffer)))))

(ert-deftest lsp-config-flycheck-unchanged-without-lsp-deferred ()
  (should (equal '((check lct-eslint))
                 (lsp-config-test--with-checked-buffer
                   (flycheck-mode -1)
                   (kill-local-variable 'flycheck-deferred-syntax-check)
                   (setq lsp-config-test--log nil)
                   (lsp-config-test-mode)
                   (flycheck-mode 1)))))

(ert-deftest lsp-config-flycheck-unchanged-when-lsp-already-manages-buffer ()
  (should (equal '((lsp-deferred nil) (check lct-eslint))
                 (lsp-config-test--with-checked-buffer
                   (flycheck-mode -1)
                   (lsp-config-test-mode)
                   (setq lsp-managed-mode t)
                   (lsp-deferred)
                   (flycheck-mode 1)))))
