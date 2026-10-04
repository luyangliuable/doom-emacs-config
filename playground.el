;; (insert (format "%S" initial-buffer-choice))

;; Let's boldify the names:

(defun boldify-names ()
    (switch-to-buffer-other-window "*test*")
    (goto-char (point-min))
    (while (re-search-forward "Bonjour \\(.+\\)!" nil t)
      (add-text-properties (match-beginning 1)
                           (match-end 1)
                           (list 'face 'bold)))
    (other-window 1))

;; This functions introduces `re-search-forward': instead of
;; searching for the string "Bonjour", you search for a pattern,
;; using a "regular expression" (abbreviated in the prefix "re-").

;; The regular expression is "Bonjour \\(.+\\)!" and it reads:
;; the string "Bonjour ", and
;; a group of            | this is the \\( ... \\) construct
;;   any character       | this is the .
;;   possibly repeated   | this is the +
;; and the "!" string.

;; Ready?  Test it!

(boldify-names)
