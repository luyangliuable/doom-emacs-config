;;; config/packages/org-parallel-clock.el -*- lexical-binding: t; -*-
;; Parallel (overlapping) Org clocks.
;;
;; Org's built-in clock is single: clocking into a task stops the previous one.
;; This adds independent clocks that can run at the same time by writing open
;; CLOCK: lines straight into each entry's LOGBOOK and closing them with Org's
;; own duration math. It does NOT touch the global `org-clock-marker', so your
;; normal `org-clock-in'/`org-clock-out' keep working alongside it.
;;
;; Usage:
;;   M-x luyangliuable/org-parallel-clock-in     ; start a clock on entry at point
;;   M-x luyangliuable/org-parallel-clock-out    ; close the open clock at point
;;   M-x luyangliuable/org-parallel-clock-out-all ; close every open parallel clock
;;   M-x luyangliuable/org-parallel-clock-status  ; list currently open clocks

(after! org
  (defvar luyangliuable/org-parallel-clocks nil
    "List of markers pointing at entries with an open parallel clock.")

  (defun luyangliuable/org--open-clock-re ()
    "Regexp matching an OPEN clock line (single timestamp, no `--')."
    (concat "^[ \t]*" org-clock-string
            "[ \t]*\\(\\[[^]]+\\]\\)[ \t]*$"))

  (defun luyangliuable/org--find-open-clock-in-entry ()
    "Move point to the open clock line in the current entry, or return nil."
    (let ((end (save-excursion (org-end-of-subtree t t) (point)))
          found)
      (save-excursion
        (org-back-to-heading t)
        (while (and (not found)
                    (re-search-forward (luyangliuable/org--open-clock-re) end t))
          (setq found (line-beginning-position))))
      (when found (goto-char found) found)))

  (defun luyangliuable/org-parallel-clock-in ()
    "Start a parallel clock on the entry at point without stopping other clocks."
    (interactive)
    (save-excursion
      (org-back-to-heading t)
      (when (luyangliuable/org--find-open-clock-in-entry)
        (user-error "This entry already has an open parallel clock"))
      (org-back-to-heading t)
      ;; Position inside (or create) the LOGBOOK drawer for this entry.
      (org-clock-find-position org-clock-into-drawer)
      (insert org-clock-string " "
              (format-time-string
               (org-time-stamp-format 'long 'inactive))
              "\n")
      (forward-line -1)
      (add-to-list 'luyangliuable/org-parallel-clocks
                   (copy-marker (line-beginning-position) t)))
    (message "Parallel clock started: %s" (org-get-heading t t t t)))

  (defun luyangliuable/org--close-open-clock-at-point ()
    "Close the open clock in the entry at point. Return non-nil on success."
    (when (luyangliuable/org--find-open-clock-in-entry)
      (end-of-line)
      (insert "--"
              (format-time-string (org-time-stamp-format 'long 'inactive)))
      ;; Let Org compute the `=> H:MM' duration.
      (org-clock-update-time-maybe)
      t))

  (defun luyangliuable/org-parallel-clock-out ()
    "Close the open parallel clock in the entry at point."
    (interactive)
    (save-excursion
      (org-back-to-heading t)
      (if (luyangliuable/org--close-open-clock-at-point)
          (progn
            ;; Drop any stored marker that now points at a closed clock.
            (setq luyangliuable/org-parallel-clocks
                  (seq-remove
                   (lambda (m)
                     (and (marker-buffer m)
                          (>= (marker-position m) (point-min))
                          (save-excursion
                            (goto-char m)
                            (looking-at-p (luyangliuable/org--open-clock-re))
                            nil)))
                   luyangliuable/org-parallel-clocks))
            (message "Parallel clock stopped: %s" (org-get-heading t t t t)))
        (user-error "No open parallel clock in this entry"))))

  (defun luyangliuable/org-parallel-clock-out-all ()
    "Close every tracked open parallel clock."
    (interactive)
    (let ((n 0))
      (dolist (m luyangliuable/org-parallel-clocks)
        (when (marker-buffer m)
          (with-current-buffer (marker-buffer m)
            (save-excursion
              (goto-char m)
              (when (luyangliuable/org--close-open-clock-at-point)
                (setq n (1+ n)))))))
      (setq luyangliuable/org-parallel-clocks nil)
      (message "Closed %d parallel clock(s)" n)))

  (defun luyangliuable/org-parallel-clock-status ()
    "Report entries that currently have an open parallel clock."
    (interactive)
    (let (open)
      (dolist (m luyangliuable/org-parallel-clocks)
        (when (marker-buffer m)
          (with-current-buffer (marker-buffer m)
            (save-excursion
              (goto-char m)
              (when (looking-at-p (luyangliuable/org--open-clock-re))
                (org-back-to-heading t)
                (push (org-get-heading t t t t) open))))))
      (if open
          (message "Open parallel clocks: %s" (string-join (nreverse open) " | "))
        (message "No open parallel clocks"))))

  ;; Keybindings under the org localleader clock prefix: , c p ...
  (map! :map org-mode-map
        :localleader
        (:prefix ("c" . "clock")
         (:prefix ("p" . "parallel")
          :desc "Clock in (parallel)"   "i" #'luyangliuable/org-parallel-clock-in
          :desc "Clock out (parallel)"  "o" #'luyangliuable/org-parallel-clock-out
          :desc "Clock out all"         "O" #'luyangliuable/org-parallel-clock-out-all
          :desc "Status"               "s" #'luyangliuable/org-parallel-clock-status))))
