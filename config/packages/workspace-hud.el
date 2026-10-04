;;; config/packages/workspace-hud.el -*- lexical-binding: t; -*-

(add-to-list 'load-path
             (expand-file-name
              (format "straight/build-%s/workspace-hud/lisp/" emacs-version)
              doom-local-dir))

;; The Agent Shell stack used to load right here at startup, so its minor-mode
;; keymaps and lighters ranked below every package loaded later.  It now loads
;; on idle or first use, and `add-minor-mode' puts its modes in front, so move
;; them back to this position, in the eager load order, once it has loaded.
(defconst luyangliuable/agent-shell-stack-features
  '(workspace-hud agent-shell agent-shell-hud agent-shell-workspace
    agent-shell-sidebar))
(defvar luyangliuable/agent-shell-stack-mode-anchors nil
  "Alist of (VARIABLE . TAIL) marking where the stack's modes belong.")
(defvar luyangliuable/agent-shell-stack-history-anchor nil
  "Tail of `load-history' when tracking started.")
(defvar luyangliuable/agent-shell-stack-loads (make-hash-table :test #'equal)
  "Map each finished file to (LOADER . AFTER).
LOADER is the file whose load loaded it; AFTER is the file whose after-load
forms were running then.")
(defvar luyangliuable/agent-shell-stack-mode-files (make-hash-table :test #'equal)
  "Map (VARIABLE . MODE) to the file whose load added MODE's entry.")
(defvar luyangliuable/agent-shell-stack-finish-timer nil)

(defun luyangliuable/agent-shell-stack--loader (file)
  "Return FILE's loader, or `unfinished' if its after-load forms still run."
  (car (gethash file luyangliuable/agent-shell-stack-loads '(unfinished))))

(defun luyangliuable/agent-shell-stack-mode-rank-function ()
  "Return a function giving a file's position in the eager stack load.
Replay each root in `luyangliuable/agent-shell-stack-features' order, ranking
each file after what it required or loaded in its body, and before what loaded
once it had.  Later files get larger numbers; unrelated files get nil."
  (let ((feature-files (make-hash-table :test #'eq))
        (entries (make-hash-table :test #'equal))
        (positions (make-hash-table :test #'equal))
        (children (make-hash-table :test #'equal))
        (later-children (make-hash-table :test #'equal))
        (ranks (make-hash-table :test #'equal))
        (count 0)
        (position 0))
    (dolist (entry load-history)
      (unless (gethash (car entry) entries)
        (puthash (car entry) (cdr entry) entries)
        (puthash (car entry) (cl-incf position) positions)
        (dolist (item (cdr entry))
          (when (and (eq (car-safe item) 'provide)
                     (not (gethash (cdr item) feature-files)))
            (puthash (cdr item) (car entry) feature-files)))))
    (maphash (lambda (file load)
               (pcase-let ((`(,loader . ,after) load))
                 (if (and after
                          (equal loader (luyangliuable/agent-shell-stack--loader after)))
                     (push file (gethash after later-children))
                   (when loader (push file (gethash loader children))))))
             luyangliuable/agent-shell-stack-loads)
    (cl-labels
        ((visit (file)
           (when (and file (not (gethash file ranks)))
             (puthash file 'visiting ranks)
             (let ((position (gethash file positions))
                   (by-load-order (lambda (a b) (> (gethash a positions 0)
                                                   (gethash b positions 0))))
                   body later)
               ;; Files loaded by FILE's body finished before it did.
               (dolist (child (gethash file children))
                 (if (< (gethash child positions 0) position)
                     (push child later)
                   (push child body)))
               (dolist (item (gethash file entries))
                 (when (eq (car-safe item) 'require)
                   (visit (gethash (cdr item) feature-files))))
               (mapc #'visit (sort body by-load-order))
               (puthash file (cl-incf count) ranks)
               (mapc #'visit (sort (append later (gethash file later-children))
                                   by-load-order))))))
      (mapc (lambda (feature) (visit (gethash feature feature-files)))
            luyangliuable/agent-shell-stack-features))
    (lambda (file)
      (let ((rank (gethash file ranks)))
        (and (numberp rank) rank)))))

(defun luyangliuable/agent-shell-stack--reorder (var anchor rank-of)
  "Move VAR's ranked entries just in front of ANCHOR, sorted by RANK-OF."
  (let ((alist (symbol-value var)) others stack)
    (when (cl-tailp anchor alist)
      (cl-loop for tail on alist until (eq tail anchor)
               for rank = (funcall rank-of
                                   (gethash (cons var (caar tail))
                                            luyangliuable/agent-shell-stack-mode-files))
               do (if rank
                      (push (cons rank (car tail)) stack)
                    (push (car tail) others)))
      (set var (nconc (nreverse others)
                      (mapcar #'cdr (sort (nreverse stack)
                                          (lambda (a b) (> (car a) (car b)))))
                      anchor)))))

(defun luyangliuable/agent-shell-stack-finish-mode-order ()
  "Stop tracking loads for the Agent Shell stack's mode order."
  (remove-hook 'after-load-functions #'luyangliuable/agent-shell-stack-note-modes)
  (remove-hook 'after-load-functions #'luyangliuable/agent-shell-stack-restore-mode-order)
  (when (timerp luyangliuable/agent-shell-stack-finish-timer)
    (cancel-timer luyangliuable/agent-shell-stack-finish-timer))
  (setq luyangliuable/agent-shell-stack-finish-timer nil
        luyangliuable/agent-shell-stack-mode-anchors nil
        luyangliuable/agent-shell-stack-history-anchor nil)
  (clrhash luyangliuable/agent-shell-stack-loads)
  (clrhash luyangliuable/agent-shell-stack-mode-files))

(defun luyangliuable/agent-shell-stack-note-modes (file)
  "Attribute new minor-mode entries to FILE, whose load added them."
  (pcase-dolist (`(,var . ,anchor) luyangliuable/agent-shell-stack-mode-anchors)
    (cl-loop for tail on (symbol-value var) until (eq tail anchor)
             for key = (cons var (caar tail))
             unless (gethash key luyangliuable/agent-shell-stack-mode-files)
             do (puthash key file luyangliuable/agent-shell-stack-mode-files))))

(defun luyangliuable/agent-shell-stack-restore-mode-order (file)
  "Record how FILE loaded; once Agent Shell has loaded, restore mode order."
  (let ((load (list load-file-name)))
    (puthash file load luyangliuable/agent-shell-stack-loads)
    (setcdr load (cl-loop for tail on load-history
                          until (eq tail luyangliuable/agent-shell-stack-history-anchor)
                          for loaded = (caar tail)
                          when (eq (luyangliuable/agent-shell-stack--loader loaded)
                                   'unfinished)
                          return loaded)))
  (luyangliuable/agent-shell-stack-note-modes file)
  (when (featurep 'agent-shell)
    (let ((rank-of (luyangliuable/agent-shell-stack-mode-rank-function)))
      (pcase-dolist (`(,var . ,anchor) luyangliuable/agent-shell-stack-mode-anchors)
        (luyangliuable/agent-shell-stack--reorder var anchor rank-of)))
    ;; Stack files can still be loading further up; finish at top level.
    (cond ((null load-file-name)
           (luyangliuable/agent-shell-stack-finish-mode-order))
          ((not (timerp luyangliuable/agent-shell-stack-finish-timer))
           (setq luyangliuable/agent-shell-stack-finish-timer
                 (run-at-time 0 nil #'luyangliuable/agent-shell-stack-finish-mode-order))))))

(unless (featurep 'agent-shell)
  (clrhash luyangliuable/agent-shell-stack-loads)
  (clrhash luyangliuable/agent-shell-stack-mode-files)
  (setq luyangliuable/agent-shell-stack-mode-anchors
        (list (cons 'minor-mode-map-alist minor-mode-map-alist)
              (cons 'minor-mode-alist minor-mode-alist))
        luyangliuable/agent-shell-stack-history-anchor load-history)
  ;; `eval-after-load' forms also run from this hook and can load more files:
  ;; note FILE's own modes before them, and finish FILE after them.
  (add-hook 'after-load-functions #'luyangliuable/agent-shell-stack-note-modes -100)
  (add-hook 'after-load-functions #'luyangliuable/agent-shell-stack-restore-mode-order 100))

;; Loaded with Agent Shell by config/packages/agent-shell-hud.el, or earlier by
;; a Workspace HUD command; :config runs as soon as it loads either way.
(use-package! workspace-hud
  :defer t
  :config
  ;; Keep the HUD framework available for Agent Shell status tracking, but do
  ;; not create or update the graphical panel automatically.
  (workspace-hud-auto-mode -1))
