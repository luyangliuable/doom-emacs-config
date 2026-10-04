;;; config/packages/gptel-auth.el -*- lexical-binding: t; -*-

(defconst luyangliuable/gptel-pi-auth-file
  "/Users/blackfish/.pi/agent/auth.json"
  "Pi agent credential file used for GitHub Copilot authentication.")

(defun luyangliuable/gptel--require-string (value field)
  "Return VALUE when it is a non-empty string, otherwise signal for FIELD."
  (unless (and (stringp value) (not (string-empty-p value)))
    (user-error "Invalid GitHub Copilot credential field: %s" field))
  value)

(defun luyangliuable/gptel-required-environment (variable)
  "Return non-empty environment VARIABLE or signal a configuration error."
  (luyangliuable/gptel--require-string (getenv variable) variable))

(defun luyangliuable/gptel-api-components (base-url operation)
  "Return connection details for BASE-URL and API OPERATION.

When BASE-URL has no path, use the conventional `/v1' API prefix."
  (unless (and (stringp base-url) (not (string-empty-p base-url)))
    (user-error "Missing API base URL"))
  (require 'url-parse)
  (let* ((parsed-url (url-generic-parse-url base-url))
         (protocol (url-type parsed-url))
         (host (url-host parsed-url))
         (base-path (replace-regexp-in-string
                     "/\\'" "" (or (url-filename parsed-url) "")))
         (operation (concat "/" (string-remove-prefix "/" operation)))
         (base-path (if (string-empty-p base-path) "/v1" base-path)))
    (unless (and (stringp protocol) (stringp host))
      (user-error "Invalid API base URL"))
    (list :protocol protocol
          :host host
          :endpoint (if (string-suffix-p operation base-path)
                        base-path
                      (concat base-path operation)))))

(defun luyangliuable/gptel-read-pi-copilot-auth (file required-model)
  "Read the GitHub Copilot credential from Pi FILE.

REQUIRED-MODEL must be authorized by Pi's `availableModelIds' list."
  (unless (file-readable-p file)
    (user-error "GitHub Copilot credential file is not readable: %s" file))
  (let* ((auth (condition-case nil
                   (with-temp-buffer
                     (insert-file-contents file)
                     (json-parse-buffer :object-type 'plist :array-type 'list))
                 (json-parse-error
                  (user-error "GitHub Copilot credential file is not valid JSON"))))
         (credential (plist-get auth :github-copilot))
         (type (plist-get credential :type))
         (refresh (luyangliuable/gptel--require-string
                   (plist-get credential :refresh) "refresh"))
         (access (luyangliuable/gptel--require-string
                  (plist-get credential :access) "access"))
         (expires (plist-get credential :expires))
         (model-ids (plist-get credential :availableModelIds)))
    (unless (and (listp credential) (equal type "oauth"))
      (user-error "Invalid GitHub Copilot credential type"))
    (unless (numberp expires)
      (user-error "Invalid GitHub Copilot credential field: expires"))
    (unless (and (listp model-ids) model-ids)
      (user-error "Invalid GitHub Copilot credential field: availableModelIds"))
    (let ((models
           (mapcar
            (lambda (model-id)
              (unless (and (stringp model-id)
                           (string-match-p
                            "\\`[[:alnum:]][[:alnum:]._-]*\\'" model-id))
                (user-error
                 "Invalid GitHub Copilot credential field: availableModelIds"))
              (intern model-id))
            model-ids)))
      (unless (memq required-model models)
        (user-error "GitHub Copilot model is not authorized: %s" required-model))
      (list :refresh refresh
            :access access
            :expires-at (floor (/ expires 1000))
            :models models))))

(provide 'gptel-auth)
