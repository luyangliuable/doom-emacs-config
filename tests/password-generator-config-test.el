;;; tests/password-generator-config-test.el -*- lexical-binding: t; -*-

(require 'ert)

(defconst luyangliuable-test/password-generator-packages-file
  (expand-file-name "../packages.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defconst luyangliuable-test/password-generator-keybindings-file
  (expand-file-name "../config/keybindings.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defconst luyangliuable-test/org-rollover-file
  (expand-file-name "../config/packages/org.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defun luyangliuable-test/file-contents (file)
  "Return FILE contents as a string."
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(ert-deftest luyangliuable-test/password-generator-is-installed-and-bound ()
  (let ((packages (luyangliuable-test/file-contents
                   luyangliuable-test/password-generator-packages-file))
        (keybindings (luyangliuable-test/file-contents
                      luyangliuable-test/password-generator-keybindings-file)))
    (should (string-match-p "(package! password-generator)" packages))
    (should-not (string-match-p "(require 'password-generator)" keybindings))
    (should (string-match-p (regexp-quote ":leader \"ip\" nil")
                            keybindings))
    (should (string-match-p
             (regexp-quote "(:prefix (\"ip\" . \"passwords\")")
             keybindings))
    (should (string-match-p
             (regexp-quote
              "   :desc \"Numeric password\" \"n\" #'password-generator-numeric)

  ;; Search operations")
             keybindings))
    (dolist (binding '("\"1\" #'password-generator-simple"
                       "\"2\" #'password-generator-strong"
                       "\"3\" #'password-generator-paranoid"
                       "\"p\" #'password-generator-phonetic"
                       "\"n\" #'password-generator-numeric"))
      (should (string-match-p (regexp-quote binding) keybindings)))
    (dolist (command '(password-generator-simple
                       password-generator-strong
                       password-generator-paranoid
                       password-generator-phonetic
                       password-generator-numeric))
      (should (string-match-p
               (regexp-quote
                (format "(autoload '%s \"password-generator\" nil t)" command))
               keybindings)))))

(ert-deftest luyangliuable-test/org-rollover-is-a-namespaced-command ()
  (let ((org-config (luyangliuable-test/file-contents
                     luyangliuable-test/org-rollover-file)))
    (should (string-match-p
             (regexp-quote "(defun luyangliuable/org-rollover (&optional dry-run)")
             org-config))
    (should (string-match-p
             (regexp-quote "(defalias 'rollover #'luyangliuable/org-rollover)")
             org-config))))
