;;; config/packages/agent-shell.el -*- lexical-binding: t; -*-
;; Agent Shell Package Configuration

;; Agent shell configuration
(use-package agent-shell
  :ensure-system-package ((claude-code-acp . "npm install -g @zed-industries/claude-code-acp")
                          (codex . "brew install codex"))
  :config
  (map! :leader
        :desc "run agent shell" "o S" #'agent-shell)
  (map! :leader
        :desc "run codex shell" "o C" #'agent-shell-openai-codex))

;; Claude Code configuration
(setq agent-shell-anthropic-claude-environment
      (agent-shell-make-environment-variables
       "ANTHROPIC_BASE_URL" "https://api.studio.genai.cba"
       "ANTHROPIC_API_KEY" (or (getenv "ANTHROPIC_API_KEY") "")
       "ANTHROPIC_MODEL" "aipe-bedrock-claude-4-sonnet"
       "ANTHROPIC_SMALL_FAST_MODEL" "aipe-bedrock-claude-4-sonnet"))

;; Codex configuration
(setq agent-shell-openai-codex-environment
      (agent-shell-make-environment-variables
       "OPENAI_API_KEY" (or (getenv "OPENAI_API_KEY") "")
       "ANTHROPIC_BASE_URL" "https://api.studio.genai.cba"
       "NODE_TLS_REJECT_UNAUTHORIZED" "0"))

;; Explicitly set the default models
(setq agent-shell-anthropic-default-model-id "aipe-bedrock-claude-4-sonnet")
(setq agent-shell-openai-codex-default-model-id "aipe-bedrock-claude-4-5-sonnet")

;; Set codex executable path if needed
(setq agent-shell-openai-codex-executable "/opt/homebrew/bin/codex")
