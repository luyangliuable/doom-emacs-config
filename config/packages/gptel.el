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
    (setq gptel-stream nil)))
