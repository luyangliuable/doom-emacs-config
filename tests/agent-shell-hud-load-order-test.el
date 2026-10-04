;;; tests/agent-shell-hud-load-order-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'use-package)

(defvar luyangliuable-test/hud-config-root
  (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name))))

(defvar luyangliuable-test/hud-log nil)
(defvar doom-local-dir temporary-file-directory)

(defconst luyangliuable-test/hud-features
  '(agent-shell workspace-hud agent-shell-hud agent-shell-workspace))

(defmacro use-package! (name &rest plist)
  (declare (indent 1))
  `(use-package ,name ,@plist))

(defmacro map! (&rest _)
  '(push 'map! luyangliuable-test/hud-log))

(defun luyangliuable-test/hud-config-files ()
  "Return the HUD stack config files in the order config.el loads them."
  (let ((wanted '("agent-shell-hud" "agent-shell-workspace" "workspace-hud"))
        files)
    (with-temp-buffer
      (insert-file-contents
       (expand-file-name "config.el" luyangliuable-test/hud-config-root))
      (condition-case nil
          (while t
            (let ((form (read (current-buffer))))
              (when (and (eq (car-safe form) 'load!)
                         (stringp (cadr form))
                         (member (file-name-nondirectory (cadr form)) wanted))
                (push (expand-file-name (concat (cadr form) ".el")
                                        luyangliuable-test/hud-config-root)
                      files))))
        (end-of-file nil)))
    (should (= (length wanted) (length files)))
    (nreverse files)))

(defun luyangliuable-test/hud-write-package (dir feature body &optional quiet)
  "Write fake FEATURE to DIR; it logs its load unless QUIET."
  (with-temp-file (expand-file-name (format "%s.el" feature) dir)
    (insert ";;; -*- lexical-binding: t; -*-\n"
            (if quiet "" (format "(push '%s-load luyangliuable-test/hud-log)\n" feature))
            body
            (format "\n(provide '%s)\n" feature))))

(defun luyangliuable-test/hud-write-packages (dir)
  (luyangliuable-test/hud-write-package
   dir 'agent-shell-dep
   "(define-minor-mode agent-shell-dep-mode \"\" :lighter \" Dep\"
      :keymap (make-sparse-keymap))"
   t)
  (luyangliuable-test/hud-write-package
   dir 'agent-shell
   "(require 'agent-shell-dep)
    (load \"agent-shell-lazy\" nil t)
    (defvar agent-shell-mode-map (make-sparse-keymap))
    (define-minor-mode agent-shell-list-edit-mode \"\" :lighter \" ListEdit\"
      :keymap (make-sparse-keymap))")
  ;; Loaded without `require', like files pulled in through autoloads.
  (luyangliuable-test/hud-write-package
   dir 'agent-shell-lazy
   "(define-minor-mode agent-shell-lazy-mode \"\" :lighter \" Lazy\"
      :keymap (make-sparse-keymap))"
   t)
  (luyangliuable-test/hud-write-package
   dir 'late-package
   "(require 'agent-shell-dep)
    (define-minor-mode late-package-mode \"\" :lighter \" Late\"
      :keymap (make-sparse-keymap))"
   t)
  (luyangliuable-test/hud-write-package dir 'agent-shell-workspace "")
  (luyangliuable-test/hud-write-package
   dir 'workspace-hud
   "(defun workspace-hud-auto-mode (&optional arg)
      (push (list 'workspace-hud-auto-mode arg) luyangliuable-test/hud-log))")
  (luyangliuable-test/hud-write-package
   dir 'agent-shell-hud
   "(defun agent-shell-hud-mode (&optional arg)
      (push (list 'agent-shell-hud-mode arg) luyangliuable-test/hud-log))"))

(defmacro luyangliuable-test/with-hud-config (&rest body)
  "Load the HUD stack configs against fake packages, then run BODY."
  (declare (indent 0))
  `(let* ((root (make-temp-file "agent-shell-hud-order" t))
          (packages (expand-file-name "packages/" root))
          (use-package-expand-minimally t))
     (unwind-protect
         (progn
           (make-directory packages)
           (luyangliuable-test/hud-write-packages packages)
           (dlet ((features (cl-set-difference
                             features
                             (append '(agent-shell-dep agent-shell-lazy late-package)
                                     luyangliuable-test/hud-features)))
                  (minor-mode-map-alist (copy-sequence minor-mode-map-alist))
                  (minor-mode-alist (copy-sequence minor-mode-alist))
                  (after-load-alist nil)
                  (after-load-functions nil)
                  (load-path (cons packages load-path))
                  (doom-local-dir (file-name-as-directory root))
                  (luyangliuable-test/hud-log nil))
             (dolist (file (luyangliuable-test/hud-config-files))
               (load file nil t t))
             ,@body))
       (delete-directory root t))))

(defun luyangliuable-test/hud-events ()
  (reverse luyangliuable-test/hud-log))

(ert-deftest luyangliuable-test/agent-shell-loads-hud-stack-in-eager-order ()
  (luyangliuable-test/with-hud-config
    ;; Nothing in the stack loads during startup.
    (should-not (cl-some #'featurep luyangliuable-test/hud-features))
    (should-not luyangliuable-test/hud-log)
    (require 'agent-shell)
    ;; Same relative order as when Workspace HUD loaded eagerly at startup:
    ;; its config disables auto mode before Agent Shell HUD starts.
    (should (equal '(agent-shell-load
                     workspace-hud-load
                     (workspace-hud-auto-mode -1)
                     agent-shell-hud-load
                     (agent-shell-hud-mode 1)
                     agent-shell-workspace-load
                     map!)
                   (luyangliuable-test/hud-events)))))

(ert-deftest luyangliuable-test/workspace-hud-config-runs-when-it-loads-first ()
  (luyangliuable-test/with-hud-config
    ;; A Workspace HUD command used before Agent Shell loads gets the same
    ;; configured package that eager startup loading provided.
    (require 'workspace-hud)
    (should (equal '(workspace-hud-load (workspace-hud-auto-mode -1))
                   (luyangliuable-test/hud-events)))
    (should-not (featurep 'agent-shell-hud))
    (require 'agent-shell)
    (should (equal '(workspace-hud-load
                     (workspace-hud-auto-mode -1)
                     agent-shell-load
                     agent-shell-hud-load
                     (agent-shell-hud-mode 1)
                     agent-shell-workspace-load
                     map!)
                   (luyangliuable-test/hud-events)))))

(ert-deftest luyangliuable-test/hud-stack-reload-keeps-eager-order ()
  (luyangliuable-test/with-hud-config
    (require 'agent-shell)
    (setq luyangliuable-test/hud-log nil)
    ;; Reloading the configs once everything is loaded reruns each config
    ;; immediately, in config.el order.
    (dolist (file (luyangliuable-test/hud-config-files))
      (load file nil t t))
    (should (equal '((agent-shell-hud-mode 1)
                     map!
                     (workspace-hud-auto-mode -1))
                   (luyangliuable-test/hud-events)))))

(defun luyangliuable-test/hud-mode-prefix (alist anchor)
  "Return the modes of ALIST entries in front of the ANCHOR tail."
  (should (cl-tailp anchor alist))
  (cl-loop for tail on alist until (eq tail anchor) collect (caar tail)))

(ert-deftest luyangliuable-test/deferred-stack-keeps-eager-minor-mode-precedence ()
  (luyangliuable-test/with-hud-config
    (let ((map-anchor minor-mode-map-alist)
          (lighter-anchor minor-mode-alist))
      ;; A package loaded after startup, before Agent Shell, pulls in one of
      ;; the stack's dependencies early.
      (require 'late-package)
      (require 'agent-shell)
      ;; Eager startup loading put the stack's modes at the config.el load
      ;; point, below everything loaded later, so later keymaps take
      ;; precedence exactly as before.
      (dolist (pair `((,minor-mode-map-alist . ,map-anchor)
                      (,minor-mode-alist . ,lighter-anchor)))
        (should (equal '(late-package-mode
                         agent-shell-list-edit-mode
                         agent-shell-lazy-mode
                         agent-shell-dep-mode)
                       (luyangliuable-test/hud-mode-prefix (car pair) (cdr pair)))))
      ;; Tracking stops once the stack has loaded.
      (should-not (memq #'luyangliuable/agent-shell-stack-restore-mode-order
                        after-load-functions))
      (should-not (memq #'luyangliuable/agent-shell-stack-note-modes
                        after-load-functions))
      ;; Packages loaded after Agent Shell still go in front.
      (eval '(define-minor-mode after-stack-mode "" :keymap (make-sparse-keymap)) t)
      (should (eq 'after-stack-mode (caar minor-mode-map-alist))))))
