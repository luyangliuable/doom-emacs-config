;;; tests/doom-modeline-test.el -*- lexical-binding: t; -*-

(require 'ert)

(ert-deftest luyangliuable-test/doom-modeline-project-detection-detaches-deleted-visits ()
  (let ((path (make-temp-file "doom-modeline-deleted-visit-" nil ".json" "{}"))
        buffer)
    (unwind-protect
        (progn
          (setq buffer (find-file-noselect path))
          (with-current-buffer buffer
            (setq buffer-offer-save nil))
          (delete-file path)
          (should (eq (luyangliuable/doom-modeline-set-project-detection
                       'projectile)
                      'projectile))
          (with-current-buffer buffer
            (should-not buffer-file-name)))
      (when (file-exists-p path)
        (delete-file path))
      (when (buffer-live-p buffer)
        (kill-buffer buffer)))))
