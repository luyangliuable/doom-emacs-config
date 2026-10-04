;;; git.el --- Run git without the macOS xcrun shim -*- lexical-binding: t; -*-

;; /usr/bin/git is an xcrun shim that adds ~12 ms to every git call. Once a
;; background lookup at first idle finds the git it runs, Magit and vc-git run
;; that git directly, with the environment the shim would have given it
;; (SDKROOT, CPATH, ... as seen by hooks and aliases). Until then, and for
;; remote directories or custom git programs, the shim is used as before.

(defvar luyangliuable/git-shim "/usr/bin/git")

(defvar luyangliuable/git-direct 'unset
  "(GIT . ENVIRONMENT) to run instead of the git shim, nil to keep the shim,
or `unset'/`pending' before the lookup finishes.
ENVIRONMENT is prepended to `process-environment'.")

(defun luyangliuable/git--run (command callback)
  "Run COMMAND in the background; call CALLBACK with its output, or nil."
  (let ((out (generate-new-buffer " *git-direct*" t))
        (err (generate-new-buffer " *git-direct-err*" t))
        (default-directory temporary-file-directory))
    (condition-case nil
        (make-process
         :name "git-direct" :command command :buffer out :stderr err
         :connection-type 'pipe :noquery t
         :sentinel (lambda (proc _event)
                     (unless (process-live-p proc)
                       (let ((output (and (eq 0 (process-exit-status proc))
                                          (with-current-buffer out (buffer-string)))))
                         (kill-buffer out)
                         (kill-buffer err)
                         (funcall callback output)))))
      (error (kill-buffer out)
             (kill-buffer err)
             (funcall callback nil)))))

(defun luyangliuable/git--set-direct (git shim-env direct-env)
  "Use GIT with the entries that differ between SHIM-ENV and DIRECT-ENV."
  (let ((key (lambda (entry) (car (split-string entry "=")))))
    (setq luyangliuable/git-direct
          (and git shim-env direct-env
               (cons git
                     (append (cl-set-difference shim-env direct-env :test #'equal)
                             (cl-set-difference (mapcar key direct-env)
                                                (mapcar key shim-env)
                                                :test #'equal))))))
  (when (featurep 'magit-git)
    (luyangliuable/magit-git-direct-h)))

(defun luyangliuable/git-direct-resolve ()
  "Look up the git behind the shim and the environment the shim adds."
  (when (eq luyangliuable/git-direct 'unset)
    (if (not (equal (executable-find "git") luyangliuable/git-shim))
        (setq luyangliuable/git-direct nil)
      (setq luyangliuable/git-direct 'pending)
      (let ((alias-env '("-c" "alias.e=!env -0" "e"))
            (env (lambda (output) (and output (split-string output "\0" t)))))
        (luyangliuable/git--run
         '("xcrun" "--find" "git")
         (lambda (found)
           (let ((git (and found (string-trim found))))
             (if (not (and git (file-executable-p git)))
                 (luyangliuable/git--set-direct nil nil nil)
               (luyangliuable/git--run
                (cons luyangliuable/git-shim alias-env)
                (lambda (shim-out)
                  (luyangliuable/git--run
                   (cons git alias-env)
                   (lambda (direct-out)
                     (luyangliuable/git--set-direct
                      git (funcall env shim-out) (funcall env direct-out))))))))))))))

(run-with-idle-timer 1 nil #'luyangliuable/git-direct-resolve)

(defun luyangliuable/vc-git-direct-a (fn &rest args)
  "Run vc-git's git (FN with ARGS) without the shim when local."
  (let ((direct (and (consp luyangliuable/git-direct)
                     (equal vc-git-program "git")
                     (not (file-remote-p default-directory))
                     luyangliuable/git-direct)))
    (if (not direct)
        (apply fn args)
      ;; Resolve "git" to the real one; the program name stays "git".
      (let ((exec-path (cons (file-name-directory (car direct)) exec-path))
            (process-environment (append (cdr direct) process-environment)))
        (apply fn args)))))

(advice-add 'vc-git--call :around #'luyangliuable/vc-git-direct-a)
(advice-add 'vc-git-command :around #'luyangliuable/vc-git-direct-a)

(defun luyangliuable/magit-git-direct-env-a (env)
  "Prepend the shim's environment to magit's ENV when it runs the real git."
  (let ((direct (and (consp luyangliuable/git-direct)
                     (equal magit-git-executable (car luyangliuable/git-direct))
                     (not (file-remote-p default-directory))
                     luyangliuable/git-direct)))
    (if direct (append (cdr direct) env) env)))

(defun luyangliuable/magit-git-direct-h ()
  (when (and (consp luyangliuable/git-direct)
             (equal (executable-find magit-git-executable) luyangliuable/git-shim))
    (setq magit-git-executable (car luyangliuable/git-direct))))

(advice-add 'magit-process-environment :filter-return
            #'luyangliuable/magit-git-direct-env-a)
(with-eval-after-load 'magit-git
  (luyangliuable/magit-git-direct-h))
