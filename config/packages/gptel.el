;;; config/packages/gptel.el -*- lexical-binding: t; -*-

;; Note: Global keybindings have been moved to config/keybindings/gptel.el


;; Safe wrapper for gptel-rewrite (define outside use-package for immediate availability)
(defun gptel-rewrite-safe ()
  "Safely rewrite selection with error handling."
  (interactive)
  (if (use-region-p)
      (condition-case err
          (gptel-rewrite)
        (error
         (message "gptel-rewrite failed: %s. Try selecting text first." (error-message-string
                                                                         err))))
    (message "Please select text to rewrite first.")))

(require 'gptel-auth
         (expand-file-name "gptel-auth.el"
                           (file-name-directory (or load-file-name buffer-file-name))))

(defconst luyangliuable/gptel-copilot-default-model 'claude-opus-5.5)

(defvar luyangliuable/gptel-portkey-model-command '("lem" "models")
  "Command used to list models for the active Portkey profile.")

(defun luyangliuable/gptel-parse-portkey-models (lines)
  "Return provider-qualified model symbols parsed from LINES."
  (delete-dups
   (delq nil
         (mapcar
          (lambda (line)
            (when (string-match
                   "^[[:space:]]*\\(@[^[:space:]]+\\)[[:space:]]*$" line)
              (intern (match-string 1 line))))
          lines))))

;; Portkey model catalog, cached so startup does not wait on `lem models'.
(defun luyangliuable/gptel-portkey-model-cache-file ()
  (expand-file-name "gptel-portkey-models" doom-cache-dir))

(defun luyangliuable/gptel-read-portkey-model-cache ()
  "Return cached model IDs, or nil if the cache is missing or invalid."
  (let ((file (luyangliuable/gptel-portkey-model-cache-file)))
    (when (file-readable-p file)
      (let ((lines (with-temp-buffer
                     (insert-file-contents file)
                     (split-string (buffer-string) "\n" t))))
        (when (and lines
                   (cl-every (lambda (line) (string-match-p "^@[^[:space:]]+$" line))
                             lines))
          (luyangliuable/gptel-parse-portkey-models lines))))))

(defun luyangliuable/gptel-fetch-portkey-models ()
  "Fetch models with `lem models' and atomically cache them; nil on failure."
  (let ((models (ignore-errors
                  (luyangliuable/gptel-parse-portkey-models
                   (apply #'process-lines luyangliuable/gptel-portkey-model-command))))
        (file (luyangliuable/gptel-portkey-model-cache-file)))
    (when models
      (make-directory (file-name-directory file) t)
      (let ((temporary (make-temp-file (expand-file-name ".gptel-models-"
                                                         (file-name-directory file)))))
        (unwind-protect
            (progn
              (with-temp-file temporary
                (insert (mapconcat #'symbol-name models "\n") "\n"))
              (rename-file temporary file t))
          (when (file-exists-p temporary)
            (delete-file temporary)))))
    models))

(defun luyangliuable/gptel-portkey-fallback-models (&optional previous)
  "Return PREVIOUS, else the env-configured Portkey models, else signal."
  (or previous
      (delete-dups
       (luyangliuable/gptel-parse-portkey-models
        (delq nil (list (getenv "PORTKEY_ANTHROPIC_MODEL")
                        (getenv "PORTKEY_OPENAI_MODEL")))))
      (user-error "Unable to load Portkey models; run `lem models'")))

(defun luyangliuable/gptel-portkey-models ()
  "Return cached Portkey models, fetching them on a cache miss."
  (or (luyangliuable/gptel-read-portkey-model-cache)
      (luyangliuable/gptel-fetch-portkey-models)
      (luyangliuable/gptel-portkey-fallback-models)))

(defun luyangliuable/gptel-refresh-portkey-models ()
  "Refetch Portkey models and re-register backends, keeping the old catalog on failure."
  (interactive)
  (let* ((previous (luyangliuable/gptel-read-portkey-model-cache))
         (models (luyangliuable/gptel-fetch-portkey-models)))
    (when (and models (fboundp 'gptel-backend-name) (fboundp 'gptel-make-openai))
      (let ((selected (and (boundp 'gptel-backend) gptel-backend
                           (gptel-backend-name gptel-backend)))
            (model (and (boundp 'gptel-model) gptel-model)))
        (luyangliuable/gptel-register-portkey-backends models)
        (when (member selected '("Portkey Anthropic" "Portkey OpenAI"))
          (setq gptel-backend (cdr (assoc selected gptel--known-backends))
                gptel-model model))))
    (or models (luyangliuable/gptel-portkey-fallback-models previous))))

(defun luyangliuable/gptel-models-with-override (model-name models)
  "Return MODELS with MODEL-NAME moved first when it is one of them."
  (let ((id (and model-name (not (string-empty-p model-name)) (intern model-name))))
    (if (and id (memq id models))
        (cons id (remq id models))
      models)))

(defun luyangliuable/gptel-register-portkey-backends (portkey-models)
  "Register each Portkey backend whose base URL is set, using PORTKEY-MODELS."
  (let ((portkey-key (getenv "PORTKEY_API_KEY")))
    (unless (string-empty-p (or portkey-key ""))
      (pcase-dolist (`(,name ,make ,url-var ,path ,model-var)
                     '(("Portkey Anthropic" gptel-make-anthropic "ANTHROPIC_BASE_URL"
                        "/messages" "PORTKEY_ANTHROPIC_MODEL")
                       ("Portkey OpenAI" gptel-make-openai "OPENAI_BASE_URL"
                        "/chat/completions" "PORTKEY_OPENAI_MODEL")))
        (let ((base-url (getenv url-var)))
          (unless (string-empty-p (or base-url ""))
            (let ((components (luyangliuable/gptel-api-components base-url path)))
              (funcall make name
                       :stream nil
                       :protocol (plist-get components :protocol)
                       :host (plist-get components :host)
                       :endpoint (plist-get components :endpoint)
                       :models (luyangliuable/gptel-models-with-override
                                (getenv model-var) portkey-models)
                       :header (lambda (_info)
                                 `(("x-portkey-api-key" . ,portkey-key)))))))))))

(when (fboundp 'luyangliuable/gptel-refresh-pi-copilot-auth)
  (advice-remove 'gptel--gh-auth
                 #'luyangliuable/gptel-refresh-pi-copilot-auth)
  (fmakunbound 'luyangliuable/gptel-refresh-pi-copilot-auth))
(when (fboundp 'luyangliuable/gptel-sync-pi-copilot-auth)
  (fmakunbound 'luyangliuable/gptel-sync-pi-copilot-auth))

(use-package! gptel
  :defer t
  :config
  (require 'gptel-gh)
  (require 'gptel-anthropic)
  (require 'gptel-openai)
  (setq gptel--known-backends
        (assoc-delete-all "Anthropic" gptel--known-backends))
  (defun luyangliuable/gptel-cache-pi-copilot-auth (credential)
    "Seed gptel's native Copilot token cache from Pi CREDENTIAL."
    (gptel-oauth--write-token
     gptel-gh-github-token-file
     (plist-get credential :refresh))
    (gptel-oauth--write-token
     gptel-gh-token-file
     (list :token (plist-get credential :access)
           :expires_at (plist-get credential :expires-at))))
  (let* ((copilot-auth
          (luyangliuable/gptel-read-pi-copilot-auth
           luyangliuable/gptel-pi-auth-file
           luyangliuable/gptel-copilot-default-model))
         (copilot
          (gptel-make-gh-copilot "GitHub Copilot"
                                  :stream nil
                                  :models (plist-get copilot-auth :models))))
    (luyangliuable/gptel-cache-pi-copilot-auth copilot-auth)
    (when (and (not (string-empty-p (or (getenv "PORTKEY_API_KEY") "")))
               (or (not (string-empty-p (or (getenv "ANTHROPIC_BASE_URL") "")))
                   (not (string-empty-p (or (getenv "OPENAI_BASE_URL") "")))))
      (luyangliuable/gptel-register-portkey-backends
       (luyangliuable/gptel-portkey-models)))
    (setq gptel-stream nil
          gptel-backend copilot
          gptel-model luyangliuable/gptel-copilot-default-model))
  ;; Additional gptel configuration to prevent errors
  (setq gptel-default-mode 'markdown-mode) ; Use markdown mode for gptel buffers
  ;; Fix for gptel-rewrite timer errors - add error handling
  (defadvice! gptel--rewrite-with-error-handling (orig-fun &rest args)
    "Add error handling to gptel rewrite functions to prevent timer errors."
    :around #'gptel--suffix-rewrite
    (condition-case err
        (apply orig-fun args)
      (beginning-of-buffer
       (message
        "gptel-rewrite: Cursor at beginning of buffer, skipping operation"))
      (end-of-buffer
       (message "gptel-rewrite: Cursor at end of buffer, skipping operation"))
      (error
       (message "gptel-rewrite error: %s" (error-message-string err)))))
  ;; Local leader keybindings for gptel-mode
  (map! :localleader
        :map gptel-mode-map
        :desc "Send message" "s" #'gptel-send
        :desc "Regenerate response" "r" #'gptel-send
        :desc "Set system message" "S" #'gptel-system-prompt
        :desc "Open menu" "m" #'gptel-menu
        :desc "Add context file" "f" #'gptel-add-file
        :desc "Rewrite selection" "R" #'gptel-rewrite-safe
        :desc "Kill current request" "k" #'gptel-abort
        :desc "Save conversation" "w" #'gptel-save-session
        :desc "End of response" "e" #'gptel-end-of-response
        :desc "Beginning of response" "b" #'gptel-beginning-of-response
        :desc "Next prompt" "n" #'gptel-next-prompt
        :desc "Previous prompt" "p" #'gptel-previous-prompt)
  ;; Additional convenient keybindings in gptel buffers
  (map!
   :map gptel-mode-map
   :gi "C-c C-c" #'gptel-send
   :gi "C-c C-k" #'gptel-abort
   :gi "C-c C-r" #'gptel-rewrite-safe
   :n "gr" #'gptel-send
   :n "]]" #'gptel-next-prompt
   :n "[[" #'gptel-previous-prompt))
