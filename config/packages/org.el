;;; config/packages/org.el -*- lexical-binding: t; -*-
;; Daily task rollover: carry unfinished tasks into today's daily org file.
;;
;; Daily files live in `luyangliuable/org-daily-dir' named "YYYY-MM-DD-todo.org".
;; A task is "unfinished" if its TODO keyword is NOT in `org-done-keywords'
;; (so DONE and CANCELLED are left behind as a record of what was completed).
;;
;; Usage:
;;   M-x rollover                              ; move unfinished tasks into today
;;   C-u M-x rollover                          ; dry-run (report only)
;; Runs automatically at most once per calendar day on Emacs startup.

(after! org
  (require 'org-element)

  (defgroup luyangliuable/org-rollover nil
    "Carry unfinished daily tasks forward."
    :group 'org)

  (defcustom luyangliuable/org-daily-dir
    "/Users/lucas.liu/Dev/today/"
    "Directory containing per-day org files."
    :type 'directory
    :group 'luyangliuable/org-rollover)

  (defcustom luyangliuable/org-daily-template
    (expand-file-name "templates/daily.org" luyangliuable/org-daily-dir)
    "Template used when today's file does not yet exist."
    :type 'file
    :group 'luyangliuable/org-rollover)

  (defcustom luyangliuable/org-schedule-file
    (expand-file-name "schedule.org" luyangliuable/org-daily-dir)
    "Optional shared schedule file included in the Org agenda."
    :type '(choice (const :tag "No shared schedule" nil)
                   file)
    :group 'luyangliuable/org-rollover)

  (setq luyangliuable/org-daily-dir "/Users/lucas.liu/Dev/today/"
        luyangliuable/org-daily-template
        (expand-file-name "templates/daily.org" luyangliuable/org-daily-dir)
        luyangliuable/org-schedule-file
        (expand-file-name "schedule.org" luyangliuable/org-daily-dir))

  (defcustom luyangliuable/org-rollover-heading "Carried Over"
    "Top-level heading under which carried tasks are filed in today's file."
    :type 'string
    :group 'luyangliuable/org-rollover)

  (defcustom luyangliuable/org-rollover-tag "carried"
    "Tag added to each carried task."
    :type 'string
    :group 'luyangliuable/org-rollover)

  (defun luyangliuable/org-daily-file (&optional time)
    "Return the daily file path for TIME (defaults to now)."
    (expand-file-name
      (format-time-string "%Y-%m-%d-todo.org" (or time (current-time)))
      luyangliuable/org-daily-dir))

  (defun luyangliuable/org-daily-files ()
    "Return sorted list of existing daily files (oldest first)."
    (when (file-directory-p luyangliuable/org-daily-dir)
      (sort (directory-files
              luyangliuable/org-daily-dir t
              "^[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}-todo\\.org$")
        #'string<)))

  (defun luyangliuable/org-agenda-files ()
    "Return daily Org files and an existing shared schedule."
    (append (luyangliuable/org-daily-files)
            (when (and luyangliuable/org-schedule-file
                       (file-exists-p luyangliuable/org-schedule-file))
              (list luyangliuable/org-schedule-file))))

  ;; Add daily todo files and an optional shared schedule to the Org agenda.
  (setq org-agenda-files (luyangliuable/org-agenda-files))

  (defun luyangliuable/org-previous-daily-files (today-file)
    "Return daily files strictly older than TODAY-FILE."
    (seq-filter (lambda (f) (string< (file-name-nondirectory f)
                              (file-name-nondirectory today-file)))
      (luyangliuable/org-daily-files)))

  (defun luyangliuable/org--expand-template (template-file)
    "Return TEMPLATE-FILE contents with %<...> timestamps expanded."
    (with-temp-buffer
      (insert-file-contents template-file)
      ;; Expand %<FMT> capture-style timestamps.
      (goto-char (point-min))
      (while (re-search-forward "%<\\([^>]*\\)>" nil t)
        (replace-match (format-time-string (match-string 1)) t t))
      ;; Strip capture-only placeholders that make no sense outside org-capture.
      (goto-char (point-min))
      (while (re-search-forward "%\\^{[^}]*}\\|%\\?" nil t)
        (replace-match "" t t))
      (buffer-string)))

  (defun luyangliuable/org-ensure-today-file ()
    "Create today's daily file from the template if absent. Return its path."
    (let ((file (luyangliuable/org-daily-file)))
      (unless (file-exists-p file)
        (make-directory (file-name-directory file) t)
        (with-temp-file file
          (if (file-exists-p luyangliuable/org-daily-template)
            (insert (luyangliuable/org--expand-template
                      luyangliuable/org-daily-template))
            (insert (format-time-string
                      "#+TITLE: Daily Plan — %Y-%m-%d %A\n\n")))))
      file))

  (defun luyangliuable/org--ensure-rollover-heading (buffer)
    "Ensure a top-level rollover heading exists in BUFFER; return its marker."
    (with-current-buffer buffer
      (org-with-wide-buffer
        (goto-char (point-min))
        (if (re-search-forward
              (format "^\\* %s"
                (regexp-quote luyangliuable/org-rollover-heading))
              nil t)
          (copy-marker (line-beginning-position))
          (goto-char (point-max))
          (unless (bolp) (insert "\n"))
          (insert (format "* %s\n" luyangliuable/org-rollover-heading))
          (copy-marker (line-beginning-position 0))))))

  (defun luyangliuable/org--unfinished-p ()
    "Non-nil if heading at point is a TODO not in `org-done-keywords'."
    (let ((kw (org-get-todo-state)))
      (and kw (not (member kw org-done-keywords)))))

  (defun rollover (&optional dry-run)
    "Move unfinished tasks from previous daily files into today's file.
With DRY-RUN (\\[universal-argument]) only report what would move."
    (interactive "P")
    (let* ((today-file (luyangliuable/org-ensure-today-file))
            (today-buf  (find-file-noselect today-file))
            (target     (luyangliuable/org--ensure-rollover-heading today-buf))
            (moved 0))
      (dolist (src (luyangliuable/org-previous-daily-files today-file))
        (with-current-buffer (find-file-noselect src)
          (org-with-wide-buffer
            (goto-char (point-max))
            ;; Iterate bottom-to-top so cutting subtrees doesn't shift positions.
            (while (re-search-backward org-heading-regexp nil t)
              (when (luyangliuable/org--unfinished-p)
                (setq moved (1+ moved))
                (unless dry-run
                  (org-toggle-tag luyangliuable/org-rollover-tag 'on)
                  (let ((n (string-to-number
                             (or (org-entry-get nil "CARRIED_COUNT") "0"))))
                    (org-entry-put nil "CARRIED_COUNT" (number-to-string (1+ n))))
                  (org-entry-put nil "CARRIED_FROM"
                    (file-name-base (buffer-file-name)))
                  (org-cut-subtree)
                  (with-current-buffer today-buf
                    (goto-char target)
                    (org-end-of-subtree t t)
                    (org-paste-subtree 2)))))
            (unless dry-run (save-buffer)))))
      (unless dry-run
        (with-current-buffer today-buf (save-buffer)))
      (message "%s %d unfinished task(s)%s"
        (if dry-run "Would carry" "Carried")
        moved
        (if dry-run " (dry run)"
          (format " into %s" (file-name-nondirectory today-file))))
      (when (called-interactively-p 'any)
        (switch-to-buffer today-buf))))

  ;; Run automatically at most once per calendar day.
  (defvar luyangliuable/org-rollover--last-run nil)
  (defun luyangliuable/org-rollover-maybe ()
    "Run `rollover' at most once per calendar day."
    (let ((today (format-time-string "%Y-%m-%d")))
      (unless (equal luyangliuable/org-rollover--last-run today)
        (setq luyangliuable/org-rollover--last-run today)
        (ignore-errors (rollover)))))

  (add-hook 'emacs-startup-hook #'luyangliuable/org-rollover-maybe)

  (org-babel-do-load-languages
    'org-babel-load-languages
    '((shell . t))))
