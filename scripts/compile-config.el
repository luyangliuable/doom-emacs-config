;;; compile-config.el --- Compile Doom configuration -*- lexical-binding: t; -*-
;;;
;;; This script byte-compiles and native-compiles all config files for faster loading.
;;; Usage: emacs --batch -l ~/.doom.d/scripts/compile-config.el

;;; Code:

(require 'bytecomp)

(defvar doom-config-dir (expand-file-name "~/.doom.d/")
  "The root directory of Doom configuration.")

(defun compile-doom-config ()
  "Byte-compile and native-compile all .el files in Doom config."
  (interactive)
  (let* ((config-files (directory-files-recursively
                        doom-config-dir "\\.el$"))
         (compiled-files 0)
         (native-compiled-files 0)
         (failed-files 0))

    (message "Starting compilation of %d files..." (length config-files))

    ;; Byte compile
    (dolist (file config-files)
      ;; Skip already compiled files and temporary files
      (unless (or (string-match-p "\\.elc$" file)
                  (string-match-p "~$" file)
                  (string-match-p "^\\." (file-name-nondirectory file))
                  (string-match-p "/\\." file)
                  (member (file-name-nondirectory file)
                          '("compile-config.el" "doom-startup.log")))
        (condition-case err
            (progn
              (message "Compiling: %s" file)
              (byte-compile-file file)
              (setq compiled-files (1+ compiled-files))

              ;; Native compile if available (Emacs 28+)
              (when (and (fboundp 'native-compile)
                         (featurep 'native-compile))
                (message "Native compiling: %s" file)
                (native-compile file)
                (setq native-compiled-files (1+ native-compiled-files))))
          (error
           (message "ERROR compiling %s: %s" file (error-message-string err))
           (setq failed-files (1+ failed-files))))))

    ;; Summary
    (message "\n========================================")
    (message "Compilation Summary:")
    (message "  Byte-compiled: %d files" compiled-files)
    (when (> native-compiled-files 0)
      (message "  Native-compiled: %d files" native-compiled-files))
    (when (> failed-files 0)
      (message "  FAILED: %d files" failed-files))
    (message "========================================\n")

    ;; Return status
    (if (> failed-files 0)
        (message "  Compilation completed with errors")
      (message " Compilation completed successfully"))))

;; Clean up old compiled files
(defun clean-doom-config-compiled ()
  "Remove all .elc files from Doom config directory."
  (interactive)
  (let* ((compiled-files (directory-files-recursively
                          doom-config-dir "\\.elc$"))
         (count (length compiled-files)))
    (message "Removing %d compiled files..." count)
    (dolist (file compiled-files)
      (delete-file file)
      (message "Deleted: %s" file))
    (message " Cleaned %d compiled files" count)))

;; If running in batch mode, compile automatically
(when noninteractive
  (clean-doom-config-compiled)  ; Clean old files first
  (compile-doom-config)
  (kill-emacs (if (> failed-files 0) 1 0)))

(provide 'compile-config)
;;; compile-config.el ends here
