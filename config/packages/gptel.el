;;; config/packages/gptel.el -*- lexical-binding: t; -*-

(use-package! gptel
  :defer t
  :config
  ;; Completely reset and reconfigure gptel to disable streaming
  (setq gptel-stream nil)  ; Global streaming disable

  ;; Set the API key and backend configuration with explicit non-streaming
  (setq gptel-api-key "(or (getenv "OPENAI_API_KEY") "")"
        gptel-model 'bedrock-claude-4-sonnet
        gptel-backend (gptel-make-openai "Custom-Claude"
                        :stream nil  ; Explicit streaming disable
                        :protocol "https"
                        :host "api.studio.genai.cba"
                        :key "(or (getenv "OPENAI_API_KEY") "")"
                        :endpoint "/v1/chat/completions"
                        :models '("bedrock-claude-4-sonnet")))

  ;; Force disable any existing streaming processes
  (when (boundp 'gptel-stream)
    (setq gptel-stream nil))

  ;; Additional gptel configuration to prevent errors
  (setq gptel-default-mode 'markdown-mode)  ; Use markdown mode for gptel buffers

  ;; Fix for gptel-rewrite timer errors - add error handling
  (defadvice! gptel--rewrite-with-error-handling (orig-fun &rest args)
    "Add error handling to gptel rewrite functions to prevent timer errors."
    :around #'gptel--suffix-rewrite
    (condition-case err
        (apply orig-fun args)
      (beginning-of-buffer
       (message "gptel-rewrite: Cursor at beginning of buffer, skipping operation"))
      (end-of-buffer
       (message "gptel-rewrite: Cursor at end of buffer, skipping operation"))
      (error
       (message "gptel-rewrite error: %s" (error-message-string err)))))

  ;; Safe wrapper for gptel-rewrite
  (defun gptel-rewrite-safe ()
    "Safely rewrite selection with error handling."
    (interactive)
    (if (use-region-p)
        (condition-case err
            (gptel-rewrite)
          (error
           (message "gptel-rewrite failed: %s. Try selecting text first." (error-message-string err))))
      (message "Please select text to rewrite first.")))

  ;; Global keybindings for gptel
  (map! :leader
        (:prefix-map ("a" . "applications")
         (:prefix ("g" . "gptel")
          :desc "Start gptel chat" "g" #'gptel
          :desc "Send region/buffer" "s" #'gptel-send
          :desc "Open gptel menu" "m" #'gptel-menu
          :desc "Set system message" "S" #'gptel-system-prompt
          :desc "Add context from file" "f" #'gptel-add-file
          :desc "Rewrite selection" "r" #'gptel-rewrite-safe
          :desc "Kill gptel session" "k" #'gptel-abort)))

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
  (map! :map gptel-mode-map
        :gi "C-c C-c" #'gptel-send
        :gi "C-c C-k" #'gptel-abort
        :gi "C-c C-r" #'gptel-rewrite-safe
        :n "gr" #'gptel-send
        :n "]]" #'gptel-next-prompt
        :n "[[" #'gptel-previous-prompt))
