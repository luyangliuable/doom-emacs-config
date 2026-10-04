;;; tests/gptel-backends-test.el -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)

(defconst luyangliuable-test/gptel-core-config-file
  (expand-file-name "../config/core.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(defconst luyangliuable-test/gptel-auth-file
  (expand-file-name "../config/packages/gptel-auth.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(load luyangliuable-test/gptel-auth-file t t t)

(defconst luyangliuable-test/gptel-config-file
  (expand-file-name "../config/packages/gptel.el"
                    (file-name-directory (or load-file-name buffer-file-name))))

(cl-defstruct (gptel--gh (:constructor make-gptel--gh))
  github-token token)

(defvar luyangliuable-test/gptel-backends nil)
(defvar gptel-backend nil)
(defvar gptel-model nil)
(defvar gptel-stream nil)
(defvar gptel-default-mode nil)
(defvar gptel--known-backends nil)
(defvar gptel-gh-github-token-file nil)
(defvar gptel-gh-token-file nil)
(defvar luyangliuable/gptel-portkey-model-command nil)
(defvar doom-cache-dir nil)

(defvar gptel--anthropic-models
  '((claude-sonnet-5 :capabilities (tool-use))))
(defvar gptel--openai-models
  '((gpt-5.4 :capabilities (tool-use))))

(defun gptel-oauth--write-token (file token)
  (make-directory (file-name-directory file) t)
  (with-temp-file file
    (prin1 token (current-buffer)))
  token)

(defun luyangliuable-test/gptel-register (name args)
  (push (cons name args) luyangliuable-test/gptel-backends)
  (if (equal name "GitHub Copilot")
      (make-gptel--gh)
    (let ((backend (cons name args)))
      (setf (alist-get name gptel--known-backends nil nil #'equal) backend)
      backend)))

(defun gptel-make-gh-copilot (name &rest args)
  (luyangliuable-test/gptel-register name args))

(defun gptel-make-anthropic (name &rest args)
  (luyangliuable-test/gptel-register name args))

(defun gptel-make-openai (name &rest args)
  (luyangliuable-test/gptel-register name args))

(defun gptel-backend-name (backend)
  (car backend))

(defun gptel--gh-auth () :authenticated)
(defun gptel-rewrite ())
(defun gptel--suffix-rewrite ())

(provide 'gptel-gh)
(provide 'gptel-anthropic)
(provide 'gptel-openai)

(defvar luyangliuable-test/gptel-run-config t)
(defmacro use-package! (_name &rest args)
  `(when luyangliuable-test/gptel-run-config
     ,@(cdr (memq :config args))))

(let ((luyangliuable-test/gptel-run-config nil))
  (load luyangliuable-test/gptel-config-file nil t t))

(defmacro defadvice! (&rest _) nil)

(defmacro map! (&rest _) nil)

(defvar exec-path-from-shell-variables nil)
(defvar luyangliuable-test/exec-path-from-shell-initialize-calls 0)

(defun exec-path-from-shell-initialize ()
  (cl-incf luyangliuable-test/exec-path-from-shell-initialize-calls))

(defun evil-goggles-mode (&rest _))

(ert-deftest luyangliuable-test/core-does-not-scrape-shell-environment-at-startup ()
  (let ((luyangliuable-test/exec-path-from-shell-initialize-calls 0))
    (load luyangliuable-test/gptel-core-config-file nil nil t)
    (should (= 0 luyangliuable-test/exec-path-from-shell-initialize-calls))))

(ert-deftest luyangliuable-test/gptel-reads-pi-copilot-auth ()
  (let ((auth-file (make-temp-file "gptel-pi-auth-" nil ".json")))
    (unwind-protect
        (progn
          (with-temp-file auth-file
            (insert "{\"github-copilot\":{\"type\":\"oauth\","
                    "\"refresh\":\"refresh-token\","
                    "\"access\":\"access-token\","
                    "\"expires\":1234000,"
                    "\"availableModelIds\":[\"claude-opus-5.5\","
                    "\"gpt-5.6-terra\"]}}"))
          (let ((credential
                 (luyangliuable/gptel-read-pi-copilot-auth
                  auth-file 'claude-opus-5.5)))
            (should (equal (plist-get credential :refresh) "refresh-token"))
            (should (equal (plist-get credential :access) "access-token"))
            (should (= (plist-get credential :expires-at) 1234))
            (should (equal (plist-get credential :models)
                           '(claude-opus-5.5 gpt-5.6-terra)))))
      (delete-file auth-file))))

(ert-deftest luyangliuable-test/gptel-rejects-unauthorized-pi-model ()
  (let ((auth-file (make-temp-file "gptel-pi-auth-" nil ".json")))
    (unwind-protect
        (progn
          (with-temp-file auth-file
            (insert "{\"github-copilot\":{\"type\":\"oauth\","
                    "\"refresh\":\"refresh-token\","
                    "\"access\":\"access-token\","
                    "\"expires\":1234000,"
                    "\"availableModelIds\":[\"gpt-5.6-terra\"]}}"))
          (let ((error
                 (should-error
                  (luyangliuable/gptel-read-pi-copilot-auth
                   auth-file 'claude-opus-5.5)
                  :type 'user-error)))
            (should-not (string-match-p
                         "refresh-token\\|access-token"
                         (error-message-string error)))))
      (delete-file auth-file))))

(ert-deftest luyangliuable-test/gptel-normalizes-portkey-api-endpoints ()
  (should
   (equal
    (luyangliuable/gptel-api-components
     "https://gateway.example.test/v1/" "/messages")
    '(:protocol "https"
		:host "gateway.example.test"
		:endpoint "/v1/messages")))
  (should
   (equal
    (luyangliuable/gptel-api-components
     "https://gateway.example.test/v1/chat/completions"
     "/chat/completions")
    '(:protocol "https"
		:host "gateway.example.test"
		:endpoint "/v1/chat/completions")))
  (should
   (equal
    (luyangliuable/gptel-api-components
     "https://gateway.example.test" "/messages")
    '(:protocol "https"
		:host "gateway.example.test"
		:endpoint "/v1/messages"))))

(ert-deftest luyangliuable-test/gptel-rejects-empty-required-environment ()
  (let ((process-environment (copy-sequence process-environment)))
    (setenv "PORTKEY_OPENAI_MODEL" "")
    (should-error
     (luyangliuable/gptel-required-environment "PORTKEY_OPENAI_MODEL")
     :type 'user-error)))

(ert-deftest luyangliuable-test/gptel-registers-copilot-and-portkey-backends ()
  (let ((auth-file (make-temp-file "gptel-pi-auth-" nil ".json"))
        (cache-directory (make-temp-file "gptel-copilot-cache-" t))
        (doom-cache-dir (make-temp-file "gptel-model-cache-" t))
        (process-environment (copy-sequence process-environment))
        (luyangliuable/gptel-portkey-model-command
         '("printf" "  @provider/model-a\n  @provider/model-b\n"))
        (luyangliuable-test/gptel-backends nil)
        (gptel--known-backends '(("Anthropic" . legacy-backend)))
        (gptel-backend nil)
        (gptel-model nil)
        (gptel-stream t))
    (unwind-protect
        (let ((gptel-gh-github-token-file
               (expand-file-name "github-token" cache-directory))
              (gptel-gh-token-file
               (expand-file-name "token" cache-directory)))
          (with-temp-file auth-file
            (insert "{\"github-copilot\":{\"type\":\"oauth\","
                    "\"refresh\":\"refresh-token\","
                    "\"access\":\"access-token\","
                    "\"expires\":1234000,"
                    "\"availableModelIds\":[\"claude-opus-5.5\","
                    "\"gpt-5.6-terra\"]}}"))
          (setenv "PORTKEY_API_KEY" "portkey-token")
          (setenv "ANTHROPIC_BASE_URL" "https://gateway.example.test")
          (setenv "OPENAI_BASE_URL" "https://gateway.example.test/v1/")
          (setenv "PORTKEY_ANTHROPIC_MODEL" "@provider/model-a")
          (setenv "PORTKEY_OPENAI_MODEL" "@provider/model-b")
          (fset 'luyangliuable/gptel-refresh-pi-copilot-auth
                (lambda () :obsolete-advice-ran))
          (advice-add 'gptel--gh-auth :before
                      #'luyangliuable/gptel-refresh-pi-copilot-auth)
          (let ((luyangliuable/gptel-pi-auth-file auth-file))
            (load luyangliuable-test/gptel-config-file nil nil t))
          (should-not
           (advice-member-p #'luyangliuable/gptel-refresh-pi-copilot-auth
                            'gptel--gh-auth))
          (should (gptel--gh-p gptel-backend))
          (should (eq gptel-model 'claude-opus-5.5))
          (should-not gptel-stream)
          (should (equal (with-temp-buffer
                           (insert-file-contents gptel-gh-github-token-file)
                           (read (current-buffer)))
                         "refresh-token"))
          (should (equal (with-temp-buffer
                           (insert-file-contents gptel-gh-token-file)
                           (read (current-buffer)))
                         '(:token "access-token" :expires_at 1234)))
          (let ((copilot (assoc "GitHub Copilot" luyangliuable-test/gptel-backends))
                (portkey-anthropic
                 (assoc "Portkey Anthropic" luyangliuable-test/gptel-backends))
                (portkey-openai
                 (assoc "Portkey OpenAI" luyangliuable-test/gptel-backends)))
            (should (equal (plist-get (cdr copilot) :models)
                           '(claude-opus-5.5 gpt-5.6-terra)))
            (should (equal (plist-get (cdr portkey-anthropic) :endpoint)
                           "/v1/messages"))
            (should (equal (plist-get (cdr portkey-anthropic) :models)
                           '(@provider/model-a @provider/model-b)))
            (should-not
             (assoc "x-portkey-provider"
                    (funcall (plist-get (cdr portkey-anthropic) :header) nil)))
            (should (equal (plist-get (cdr portkey-openai) :endpoint)
                           "/v1/chat/completions"))
            (should (equal (plist-get (cdr portkey-openai) :models)
                           '(@provider/model-b @provider/model-a)))
            (should-not
             (assoc "x-portkey-provider"
                    (funcall (plist-get (cdr portkey-openai) :header) nil)))
            (should-not (assoc "Anthropic"
                               luyangliuable-test/gptel-backends))
            (should-not (assoc "Anthropic" gptel--known-backends))))
      (advice-remove 'gptel--gh-auth
                     #'luyangliuable/gptel-refresh-pi-copilot-auth)
      (fmakunbound 'luyangliuable/gptel-refresh-pi-copilot-auth)
      (delete-file auth-file)
      (delete-directory cache-directory t)
      (delete-directory doom-cache-dir t))))

(ert-deftest luyangliuable-test/gptel-caches-qualified-portkey-models ()
  (let* ((doom-cache-dir (make-temp-file "gptel-model-cache-" t))
         (luyangliuable/gptel-portkey-model-command
          '("printf" "@provider/model-a\ninvalid\n@provider/model-b\n"))
         (process-environment (copy-sequence process-environment)))
    (unwind-protect
        (progn
          (setenv "PORTKEY_ANTHROPIC_MODEL" nil)
          (setenv "PORTKEY_OPENAI_MODEL" nil)
          (should (equal (luyangliuable/gptel-portkey-models)
                         '(@provider/model-a @provider/model-b)))
          (let ((luyangliuable/gptel-portkey-model-command '("false")))
            (should (equal (luyangliuable/gptel-portkey-models)
                           '(@provider/model-a @provider/model-b))))
          (let ((contents (with-temp-buffer
                            (insert-file-contents
                             (expand-file-name "gptel-portkey-models" doom-cache-dir))
                            (buffer-string))))
            (should-not (string-match-p "invalid\\|secret" contents))))
      (delete-directory doom-cache-dir t))))

(ert-deftest luyangliuable-test/gptel-refreshes-cache-and-retains-on-error ()
  (let* ((doom-cache-dir (make-temp-file "gptel-model-cache-" t))
         (process-environment (copy-sequence process-environment))
         (luyangliuable/gptel-portkey-model-command '("printf" "@one/a\n")))
    (unwind-protect
        (progn
          (setenv "PORTKEY_ANTHROPIC_MODEL" nil)
          (setenv "PORTKEY_OPENAI_MODEL" nil)
          (should (equal (luyangliuable/gptel-portkey-models) '(@one/a)))
          (let ((luyangliuable/gptel-portkey-model-command '("printf" "@two/b\n")))
            (should (equal (luyangliuable/gptel-refresh-portkey-models) '(@two/b)))
            (should (equal (luyangliuable/gptel-portkey-models) '(@two/b))))
          (let ((luyangliuable/gptel-portkey-model-command '("false")))
            (should (equal (luyangliuable/gptel-refresh-portkey-models) '(@two/b))))
          (with-temp-file (expand-file-name "gptel-portkey-models" doom-cache-dir)
            (insert "not a model catalog"))
          (let ((luyangliuable/gptel-portkey-model-command '("printf" "@three/c\n")))
            (should (equal (luyangliuable/gptel-portkey-models) '(@three/c)))))
      (delete-directory doom-cache-dir t))))

(ert-deftest luyangliuable-test/gptel-refresh-preserves-selected-portkey-backend ()
  (let* ((doom-cache-dir (make-temp-file "gptel-model-cache-" t))
         (process-environment (copy-sequence process-environment))
         (luyangliuable/gptel-portkey-model-command '("printf" "@provider/new\n"))
         (gptel-backend '("Portkey OpenAI" . old))
         (gptel-model '@provider/old)
         (gptel--known-backends '(("Portkey OpenAI" . old)))
         (luyangliuable-test/gptel-backends nil))
    (unwind-protect
        (progn
          (setenv "PORTKEY_API_KEY" "fake-token")
          (setenv "OPENAI_BASE_URL" "https://example.test/v1")
          (setenv "ANTHROPIC_BASE_URL" nil)
          (should (equal (luyangliuable/gptel-refresh-portkey-models)
                         '(@provider/new)))
          (should (eq gptel-backend
                      (cdr (assoc "Portkey OpenAI" gptel--known-backends))))
          (should (eq gptel-model '@provider/old)))
      (delete-directory doom-cache-dir t))))

(ert-deftest luyangliuable-test/gptel-keeps-portkey-catalogs-without-model-overrides ()
  (let ((auth-file (make-temp-file "gptel-pi-auth-" nil ".json"))
        (cache-directory (make-temp-file "gptel-copilot-cache-" t))
        (doom-cache-dir (make-temp-file "gptel-model-cache-" t))
        (process-environment (copy-sequence process-environment))
        (luyangliuable/gptel-portkey-model-command
         '("printf" "  @provider/model-a\n  @provider/model-b\n"))
        (luyangliuable-test/gptel-backends nil)
        (gptel-backend nil))
    (unwind-protect
        (let ((gptel-gh-github-token-file
               (expand-file-name "github-token" cache-directory))
              (gptel-gh-token-file
               (expand-file-name "token" cache-directory)))
          (with-temp-file auth-file
            (insert "{\"github-copilot\":{\"type\":\"oauth\","
                    "\"refresh\":\"refresh-token\","
                    "\"access\":\"access-token\","
                    "\"expires\":1234000,"
                    "\"availableModelIds\":[\"claude-opus-5.5\"]}}"))
          (setenv "PORTKEY_API_KEY" "portkey-token")
          (setenv "ANTHROPIC_BASE_URL" "https://gateway.example.test")
          (setenv "OPENAI_BASE_URL" "https://gateway.example.test/v1/")
          (setenv "PORTKEY_ANTHROPIC_MODEL" nil)
          (setenv "PORTKEY_OPENAI_MODEL" nil)
          (let ((luyangliuable/gptel-pi-auth-file auth-file))
            (load luyangliuable-test/gptel-config-file nil nil t))
          (should (gptel--gh-p gptel-backend))
          (should
           (equal (plist-get
                   (cdr (assoc "Portkey Anthropic"
                               luyangliuable-test/gptel-backends))
                   :models)
                  '(@provider/model-a @provider/model-b)))
          (should
           (equal (plist-get
                   (cdr (assoc "Portkey OpenAI"
                               luyangliuable-test/gptel-backends))
                   :models)
                  '(@provider/model-a @provider/model-b))))
      (delete-file auth-file)
      (delete-directory cache-directory t)
      (delete-directory doom-cache-dir t))))

(ert-deftest luyangliuable-test/gptel-auth-loads-url-parse-on-demand ()
  (let* ((form
          `(progn
             (load ,luyangliuable-test/gptel-auth-file nil t t)
             (prin1 (list (featurep 'json) (featurep 'url-parse)))
             (prin1 (luyangliuable/gptel-api-components
                     "https://example.test/v1/" "/messages"))
             (prin1 (featurep 'url-parse))))
         (output
          (with-output-to-string
            (with-current-buffer standard-output
              (should (zerop (call-process
                              (expand-file-name invocation-name invocation-directory)
                              nil t nil "-Q" "--batch"
                              "--eval" (prin1-to-string form))))))))
    (should (equal (car (read-from-string (concat "(" output ")")))
                   '((nil nil)
                     (:protocol "https" :host "example.test" :endpoint "/v1/messages")
                     t)))))
