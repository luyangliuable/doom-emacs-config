;;; snippet-identities-test.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'yasnippet)

(defconst luyangliuable-test/snippet-root
  (expand-file-name "../snippets"
                    (file-name-directory (or load-file-name buffer-file-name))))

(ert-deftest luyangliuable-test/snippet-identities-are-unique-per-mode ()
  (dolist (mode-dir (directory-files luyangliuable-test/snippet-root t "^[^.]"))
    (when (file-directory-p mode-dir)
      (let ((identities (make-hash-table :test 'equal)))
        (dolist (file (directory-files-recursively mode-dir "^[^.].*"))
          (when (file-regular-p file)
            (with-temp-buffer
              (insert-file-contents file)
              (let* ((snippet (yas--parse-template file))
                     (name (nth 2 snippet))
                     (uuid (or (nth 8 snippet) name)))
                (should (and (stringp name) (not (string-empty-p name))))
                (should (and (stringp uuid) (not (string-empty-p uuid))))
                (should-not (gethash uuid identities))
                (puthash uuid file identities)))))))))
