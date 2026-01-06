;;; config/packages/agent-shell.el -*- lexical-binding: t; -*-
;; Agent Shell Package Configuration

;; Agent shell configuration
(use-package agent-shell
  :ensure t
  :ensure-system-package (claude-code-acp . "npm install -g @zed-industries/claude-code-acp")
  :config
  (map! :leader
        :desc "run agent shell" "o S" #'agent-shell))

(setq agent-shell-anthropic-claude-environment
      (agent-shell-make-environment-variables
       "ANTHROPIC_BASE_URL" "https://api.studio.genai.cba"
       "ANTHROPIC_API_KEY" (auth-source-pass-get "secret" "(or (getenv "OPENAI_API_KEY") "")")
       "ANTHROPIC_MODEL" "aipe-bedrock-claude-4-sonnet"
       "ANTHROPIC_SMALL_FAST_MODEL" "aipe-bedrock-claude-4-sonnet"))

;; Explicitly set the default model for agent shell to override any defaults
(setq agent-shell-anthropic-default-model-id "aipe-bedrock-claude-4-sonnet")
