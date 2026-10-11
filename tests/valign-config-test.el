;;; tests/valign-config-test.el -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defvar valign-config-test--after nil)
(defvar valign-fancy-bar)
(defvar valign-max-table-size)
(defmacro after! (feature &rest body)
  `(push (cons ',feature (lambda () ,@body)) valign-config-test--after))

(defvar valign-config-test--enabled nil)
(defun valign-mode (&optional arg)
  (push (or arg 1) valign-config-test--enabled))

(load (expand-file-name "../config/packages/valign.el"
                        (file-name-directory (or load-file-name buffer-file-name)))
      nil t)

(defmacro valign-config-test--with-buffer (file gui &rest body)
  (declare (indent 2))
  `(with-temp-buffer
     (setq-local buffer-file-name ,file)
     (setq valign-config-test--enabled nil)
     (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) ,gui)))
       ,@body)))

(ert-deftest valign-config-test/hooks-registered ()
  (should (memq #'luyangliuable/valign-maybe-enable org-mode-hook))
  (should (memq #'luyangliuable/valign-maybe-enable markdown-mode-hook)))

(ert-deftest valign-config-test/not-loaded-at-startup ()
  (should-not (featurep 'valign)))

(ert-deftest valign-config-test/enables-in-gui-file-buffer ()
  (valign-config-test--with-buffer "/tmp/x.org" t
    (luyangliuable/valign-maybe-enable)
    (should (equal valign-config-test--enabled '(1)))))

(ert-deftest valign-config-test/skips-non-file-buffer ()
  (valign-config-test--with-buffer nil t
    (luyangliuable/valign-maybe-enable)
    (should-not valign-config-test--enabled)))

(ert-deftest valign-config-test/skips-terminal ()
  (valign-config-test--with-buffer "/tmp/x.md" nil
    (luyangliuable/valign-maybe-enable)
    (should-not valign-config-test--enabled)))

(ert-deftest valign-config-test/skips-gptel ()
  (valign-config-test--with-buffer "/tmp/chat.md" t
    (setq-local gptel-mode t)
    (luyangliuable/valign-maybe-enable)
    (should-not valign-config-test--enabled)))

(ert-deftest valign-config-test/gptel-mode-turns-valign-off ()
  (valign-config-test--with-buffer "/tmp/chat.md" t
    (setq-local valign-mode t)
    (luyangliuable/valign-disable-in-gptel)
    (should (equal valign-config-test--enabled '(-1)))))

(ert-deftest valign-config-test/settings-keep-defaults ()
  (let ((entry (assq 'valign valign-config-test--after)))
    (should entry)
    (let (valign-fancy-bar valign-max-table-size)
      (funcall (cdr entry))
      (should-not valign-fancy-bar)
      (should (= valign-max-table-size 4000)))))

(ert-deftest valign-config-test/toggle-size-limit-is-buffer-local ()
  (valign-config-test--with-buffer "/tmp/big.md" t
    (setq-default valign-max-table-size 4000)
    (cl-letf (((symbol-function 'font-lock-flush) #'ignore))
      (luyangliuable/valign-toggle-size-limit)
      (should (local-variable-p 'valign-max-table-size))
      (should (= valign-max-table-size 0))
      (should (equal valign-config-test--enabled '(1)))
      (should (= (default-value 'valign-max-table-size) 4000))
      (luyangliuable/valign-toggle-size-limit)
      (should-not (local-variable-p 'valign-max-table-size))
      (should (= valign-max-table-size 4000)))))
