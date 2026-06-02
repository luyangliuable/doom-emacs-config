;;; check-native-comp.el --- Check native compilation status -*- lexical-binding: t; -*-

;; Run this with M-x eval-buffer or M-: (load-file "~/.doom.d/check-native-comp.el")

(defun check-native-compilation-status ()
  "Check and display native compilation status."
  (interactive)
  (let ((result-buffer (get-buffer-create "*Native Compilation Status*")))
    (with-current-buffer result-buffer
      (erase-buffer)
      (insert "=== NATIVE COMPILATION STATUS ===\n\n")

      ;; Check if native compilation is available
      (insert (format "Native compilation available: %s\n"
                      (if (and (fboundp 'native-comp-available-p)
                               (native-comp-available-p))
                          "✓ YES"
                        "✗ NO")))

      ;; Check Emacs version
      (insert (format "Emacs version: %s\n" emacs-version))

      ;; Check system type
      (insert (format "System type: %s\n\n" system-type))

      ;; Native comp paths
      (when (boundp 'native-comp-eln-load-path)
        (insert "=== ELN CACHE PATHS ===\n")
        (dolist (path native-comp-eln-load-path)
          (insert (format "  - %s %s\n"
                          path
                          (if (file-exists-p path) "✓" "✗"))))
        (insert "\n"))

      ;; Check async compilation settings
      (when (boundp 'native-comp-async-report-warnings-errors)
        (insert (format "Async warnings/errors: %s\n"
                        native-comp-async-report-warnings-errors)))

      (when (boundp 'native-comp-deferred-compilation)
        (insert (format "Deferred compilation: %s\n"
                        native-comp-deferred-compilation)))

      (when (boundp 'native-comp-async-jobs-number)
        (insert (format "Async jobs: %s\n\n"
                        native-comp-async-jobs-number)))

      ;; Count compiled files
      (insert "=== COMPILED FILES ===\n")
      (when (boundp 'native-comp-eln-load-path)
        (let ((total-files 0))
          (dolist (path native-comp-eln-load-path)
            (when (file-exists-p path)
              (let ((files (directory-files-recursively path "\\.eln$")))
                (setq total-files (+ total-files (length files)))
                (insert (format "  %s: %d .eln files\n"
                                (file-name-nondirectory (directory-file-name path))
                                (length files))))))
          (insert (format "\nTotal native compiled files: %d\n\n" total-files))))

      ;; Check if current buffer's mode is natively compiled
      (insert "=== CURRENT SESSION ===\n")
      (insert (format "Current major mode: %s\n" major-mode))
      (when (fboundp 'subr-native-elisp-p)
        (insert (format "Major mode natively compiled: %s\n"
                        (if (subr-native-elisp-p (symbol-function major-mode))
                            "✓ YES"
                          "- NO"))))

      ;; Check some common functions
      (insert "\n=== SAMPLE FUNCTIONS ===\n")
      (dolist (func '(evil-mode lsp-mode projectile-mode))
        (when (fboundp func)
          (insert (format "  %s: %s\n"
                          func
                          (if (and (fboundp 'subr-native-elisp-p)
                                   (subr-native-elisp-p (symbol-function func)))
                              "✓ native"
                            "- bytecode")))))

      ;; Instructions
      (insert "\n=== HOW TO USE ===\n")
      (insert "1. If native compilation is available but few .eln files exist,\n")
      (insert "   packages will be compiled on-demand as you use them.\n\n")
      (insert "2. To force recompilation: M-x native-compile-async\n\n")
      (insert "3. To compile a specific file: M-x native-compile\n\n")
      (insert "4. Native compilation is working if you see ✓ YES above.\n")

      (goto-char (point-min)))

    (display-buffer result-buffer)))

;; Run the check
(check-native-compilation-status)

(provide 'check-native-comp)
;;; check-native-comp.el ends here
