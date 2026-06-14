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

(use-package! gptel
  :defer t
  :config
  ;; Completely reset and reconfigure gptel to disable streaming
  (setq gptel-stream nil)               ; Global streaming disable
  ;; Set the API key and backend configuration with explicit non-streaming
  (require 'url-parse)
  (require 'gptel-anthropic)
  (let*
      ((base-url (or (getenv "ANTHROPIC_BASE_URL")
                     "https://portkey.aipe.cba"))
       (parsed-url (url-generic-parse-url base-url))
       (base-path (replace-regexp-in-string
                   "/\\'" ""
                   (or (url-filename parsed-url) "")))
       (endpoint (if (string-suffix-p "/messages" base-path)
                     base-path
                   (concat (if (string= base-path "") "/v1" base-path)
                           "/messages")))
       (api-key (or (getenv "AIPE_PORTKEY_API_KEY")
                    (getenv "ANTHROPIC_AUTH_TOKEN")
                    (getenv "ANTHROPIC_API_KEY")
                    ""))
       (default-model-name (or (getenv "ANTHROPIC_MODEL") ""))
       (small-model-name (getenv "ANTHROPIC_SMALL_FAST_MODEL"))
       (default-model (intern default-model-name))
       (models
        (delete-dups
         (mapcar #'intern
                 (delq nil (list default-model-name small-model-name))))))
    (setq gptel-model default-model
          gptel-backend (gptel-make-anthropic "Custom-Claude"
                          :stream nil   ; Explicit streaming disable
                          :protocol (or (url-type parsed-url) "https")
                          :host (or (url-host parsed-url) "portkey.aipe.cba")
                          :key api-key
                          :header `(("Authorization" . ,(concat "Bearer " api-key))
                                    ("anthropic-version" . "2023-06-01"))
                          :endpoint endpoint
                          :models models)))
  ;; Force disable any existing streaming processes
  (when (boundp 'gptel-stream)
    (setq gptel-stream nil))
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
