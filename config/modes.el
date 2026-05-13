;;; config/modes.el -*- lexical-binding: t; -*-
;; Mode Hooks and Custom Functions

;;; ============================================================================
;;; MODE HOOKS & CUSTOM FUNCTIONS
;;; ============================================================================

;; Web mode configuration
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

(add-hook 'web-mode-hook 'my-web-mode-hook)

;;; ============================================================================
;;; FILE TYPE HANDLING
;;; ============================================================================

;; Open unsupported files literally (e.g., PDFs, binary files)
(setq auto-mode-alist
      (append '(("\\.pdf\\'" . fundamental-mode)
                ("\\.docx?\\'" . fundamental-mode)
                ("\\.xlsx?\\'" . fundamental-mode)
                ("\\.pptx?\\'" . fundamental-mode)
                ("\\.zip\\'" . fundamental-mode)
                ("\\.tar\\.gz\\'" . fundamental-mode)
                ("\\.gz\\'" . fundamental-mode)
                ("\\.bz2\\'" . fundamental-mode)
                ("\\.7z\\'" . fundamental-mode)
                ("\\.rar\\'" . fundamental-mode)
                ("\\.exe\\'" . fundamental-mode)
                ("\\.dll\\'" . fundamental-mode)
                ("\\.so\\'" . fundamental-mode)
                ("\\.dylib\\'" . fundamental-mode)
                ("\\.app\\'" . fundamental-mode)
                ("\\.dmg\\'" . fundamental-mode)
                ("\\.iso\\'" . fundamental-mode)
                ("\\.img\\'" . fundamental-mode))
              auto-mode-alist))

;; Open unsupported files with external applications AND show info in Emacs
;; Optimized: Check extension FIRST before expensive operations
(defun my-open-with-external-app ()
  "Open unsupported files with their default system application and show info in Emacs."
  (when buffer-file-name
    (let ((ext (downcase (or (file-name-extension buffer-file-name) ""))))
      ;; Fast extension check first
      (when (member ext '("pdf" "docx" "doc" "xlsx" "xls" "pptx" "ppt"
                          "zip" "gz" "bz2" "7z" "rar"
                          "exe" "dll" "so" "dylib" "app" "dmg" "iso" "img"))
        ;; Only run expensive operations if extension matches
        (let ((file-path buffer-file-name))
          (my-display-binary-file-info)
          (cond
           ((eq system-type 'darwin)
            (start-process "open-external" nil "open" file-path))
           ((eq system-type 'gnu/linux)
            (start-process "open-external" nil "xdg-open" file-path))
           ((eq system-type 'windows-nt)
            (start-process "open-external" nil "cmd" "/c" "start" "" file-path)))
          (message "Opening %s with default application... (Info displayed in buffer)" (file-name-nondirectory file-path)))))))

(defun my-display-binary-file-info ()
  "Display informative content for binary files instead of raw data."
  (let ((file-size (file-attribute-size (file-attributes buffer-file-name)))
        (file-type (file-name-extension buffer-file-name))
        (inhibit-read-only t))
    (erase-buffer)
    (insert (format "BINARY FILE: %s\n" (file-name-nondirectory buffer-file-name)))
    (insert (format "Path: %s\n" buffer-file-name))
    (insert (format "Type: .%s\n" (or file-type "unknown")))
    (insert (format "Size: %s bytes (%.2f KB)\n" 
                    file-size 
                    (/ file-size 1024.0)))
    (insert (format "Modified: %s\n\n" 
                    (format-time-string "%Y-%m-%d %H:%M:%S" 
                                       (file-attribute-modification-time 
                                        (file-attributes buffer-file-name)))))
    (insert "This is a binary file opened in literal mode.\n")
    (insert "Commands:\n")
    (insert "  M-x hexl-mode    - View in hexadecimal format\n")
    (insert "  M-x revert-buffer - Reload file\n")
    (insert "  C-x C-f          - Open a different file\n\n")
    (insert "To view raw binary content, use: M-x hexl-mode\n")
    (when (string-equal file-type "pdf")
      (insert "\nFor PDF files, consider using an external viewer:\n")
      (insert "  - Preview.app (macOS default)\n")
      (insert "  - Adobe Acrobat Reader\n")
      (insert "  - Or install pdf-tools package for Emacs PDF viewing\n"))
    (goto-char (point-min))
    (setq buffer-read-only t)
    (fundamental-mode)
    (message "Binary file opened literally - use M-x hexl-mode for hex view")))

(add-hook 'find-file-hook 'my-open-with-external-app)

;; Enhanced binary file detection with better handling
(defun my-check-binary-file ()
  "Check if file contains binary data and switch to literal mode."
  (when (and buffer-file-name
             (not (derived-mode-p 'image-mode 'doc-view-mode 'pdf-view-mode))
             (not (string-match-p "\\.\\(pdf\\|docx?\\|xlsx?\\|pptx?\\|zip\\|gz\\|bz2\\|7z\\|rar\\|exe\\|dll\\|so\\|dylib\\|app\\|dmg\\|iso\\|img\\)\\'" 
                                  buffer-file-name)) ; Skip files already handled above
             (save-excursion
               (goto-char (point-min))
               (search-forward-regexp "[\000-\010\013\014\016-\037]" 
                                      (min 1024 (point-max)) t)))
    (my-display-binary-file-info)))

(add-hook 'find-file-hook 'my-check-binary-file)
