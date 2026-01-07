;;; config/packages/gptel.el -*- lexical-binding: t; -*-

(use-package! gptel
  :config
  ;; Set the global API key
  (setq gptel-api-key "(or (getenv "OPENAI_API_KEY") "")")
  ;; Register as OpenAI-compatible backend to avoid Anthropic beta headers
  (setq gptel-backend
        (gptel-make-openai "Custom-Claude"
          :stream t
          :protocol "https"
          :host "api.studio.genai.cba"
          :key gptel-api-key
          :endpoint "/v1/chat/completions"
          :models '("aipe-bedrock-claude-4-sonnet")))

  ;; Set the default model

  (setq
   gptel-model "aipe-bedrock-claude-4-sonnet"
   gptel-api-key "(or (getenv "OPENAI_API_KEY") "")"
   gptel-backend (gptel-make-openai "Custom-Claude"
                   :stream t
                   :protocol "https"
                   :host "api.studio.genai.cba"
                   :key gptel-api-key
                   :endpoint "/v1/chat/completions"
                   :models '("aipe-bedrock-claude-4-sonnet")))
