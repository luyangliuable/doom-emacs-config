;;; config/packages/minimap.el -*- lexical-binding: t; -*-
;; Minimap configuration. Uses standalone `minimap', not Doom `demap'.

(require 'cl-lib)

(defun luyangliuable/minimap-new-minimap-safely (orig-fn &rest args)
  "Create a minimap even before its window has a measurable line height."
  (let ((window-line-height-function (symbol-function 'window-line-height)))
    (cl-letf (((symbol-function 'window-line-height)
               (lambda (&rest height-args)
                 (or (apply window-line-height-function height-args)
                     (list (frame-char-height))))))
      (apply orig-fn args))))

(use-package! minimap
  :defer t
  :init
  (setq minimap-window-location 'right
    minimap-minimum-width 17
    minimap-width-fraction 0.07
    minimap-major-modes '(prog-mode))

  (defvar luyangliuable/minimap-debug nil)
  (defvar luyangliuable/minimap--last-buffer nil)
  (defvar luyangliuable/minimap--last-tick nil)
  (defvar luyangliuable/minimap--last-eligible nil)
  (defvar luyangliuable/minimap--last-only-window nil)
  (defvar luyangliuable/minimap--last-major-mode nil)

  (defun luyangliuable/minimap-only-window-p ()
    (let ((window-count 0))
      (dolist (window (window-list nil 'nomini))
        (unless (string= (buffer-name (window-buffer window)) " *MINIMAP*")
          (setq window-count (1+ window-count))))
      (= window-count 1)))

  (defun luyangliuable/minimap-buffer-over-100-lines-p ()
    (save-excursion
      (goto-char (point-min))
      (forward-line 100)
      (not (eobp))))

  (defun luyangliuable/minimap-eligible-buffer-p ()
    (and buffer-file-name
      (not (minibufferp))
      (not (derived-mode-p 'org-mode))
      (not (derived-mode-p 'plantuml-mode))
      (not (derived-mode-p 'image-mode))
      (not (string= (buffer-name) " *MINIMAP*"))
      (luyangliuable/minimap-only-window-p)
      (luyangliuable/minimap-buffer-over-100-lines-p)))

  (defun luyangliuable/minimap-auto-sync ()
    (unless (or (active-minibuffer-window)
              (minibufferp)
              (string= (buffer-name) " *MINIMAP*"))
      (let ((buffer (current-buffer))
             (tick (buffer-chars-modified-tick))
             (only-window (luyangliuable/minimap-only-window-p)))
        (unless (and (eq buffer luyangliuable/minimap--last-buffer)
                  (eq tick luyangliuable/minimap--last-tick)
                  (eq only-window luyangliuable/minimap--last-only-window)
                  (eq major-mode luyangliuable/minimap--last-major-mode))
          (let* ((eligible (luyangliuable/minimap-eligible-buffer-p))
                  (buffer-changed
                    (not (eq buffer luyangliuable/minimap--last-buffer)))
                  (eligibility-changed
                    (not (eq eligible luyangliuable/minimap--last-eligible))))
            (setq luyangliuable/minimap--last-buffer buffer
              luyangliuable/minimap--last-tick tick
              luyangliuable/minimap--last-eligible eligible
              luyangliuable/minimap--last-only-window only-window
              luyangliuable/minimap--last-major-mode major-mode)
            (when luyangliuable/minimap-debug
              (message "minimap auto: buffer=%s eligible=%s only-window=%s active=%s"
                (buffer-name) eligible only-window
                (bound-and-true-p minimap-mode)))
            (when (or buffer-changed eligibility-changed)
              (cond
                (eligible
                  (add-to-list 'minimap-major-modes major-mode)
                  (unless (or (bound-and-true-p minimap-mode)
                            (minor-mode-badges-disabled-p 'minimap-mode))
                    (minimap-mode 1)))
                ((bound-and-true-p minimap-mode)
                  (minimap-mode -1)))))))))

  ;; Sync once typing pauses; drop earlier timers so reloads keep just one.
  (dolist (timer timer-idle-list)
    (when (eq (timer--function timer) #'luyangliuable/minimap-auto-sync)
      (cancel-timer timer)))
  (run-with-idle-timer 0.5 t #'luyangliuable/minimap-auto-sync)

  :config
  (unless (advice-member-p #'luyangliuable/minimap-new-minimap-safely
                           'minimap-new-minimap)
    (advice-add 'minimap-new-minimap :around
                #'luyangliuable/minimap-new-minimap-safely)))
