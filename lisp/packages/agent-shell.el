;;; config/packages/agent-shell.el -*- lexical-binding: t; -*-
;; Agent Shell Package Configuration (SECURITY: API keys from env vars only)

(use-package agent-shell
  :ensure-system-package ((claude-code-acp . "npm install -g @zed-industries/claude-code-acp")
                          (codex . "brew install codex"))
  :config
  (map! :leader
        :desc "run agent shell" "o S" #'agent-shell)
  (map! :leader
        :desc "run codex shell" "o C" #'agent-shell-openai-codex))

;; Claude Code configuration (uses environment variables only)
(setq agent-shell-anthropic-claude-environment
      (agent-shell-make-environment-variables
       "ANTHROPIC_BASE_URL" (getenv "ANTHROPIC_BASE_URL")
       "ANTHROPIC_API_KEY" (getenv "ANTHROPIC_API_KEY")
       "ANTHROPIC_MODEL" (or (getenv "ANTHROPIC_MODEL") "kimi-k2.5")
       "ANTHROPIC_SMALL_FAST_MODEL" (or (getenv "ANTHROPIC_SMALL_FAST_MODEL") "kimi-k2.5")))

;; Warn if API keys not set
(unless (getenv "ANTHROPIC_API_KEY")
  (message "WARNING: ANTHROPIC_API_KEY environment variable not set"))

;; OpenCode configuration (uses environment variables only)
(setq agent-shell-opencode-environment
      (agent-shell-make-environment-variables
       "ANTHROPIC_BASE_URL" (getenv "ANTHROPIC_BASE_URL")
       "ANTHROPIC_API_KEY" (getenv "ANTHROPIC_API_KEY")
       "ANTHROPIC_MODEL" (or (getenv "ANTHROPIC_MODEL") "kimi-k2.5")
       "ANTHROPIC_SMALL_FAST_MODEL" (or (getenv "ANTHROPIC_SMALL_FAST_MODEL") "kimi-k2.5")))

;; Codex configuration (uses environment variables only)
(setq agent-shell-openai-codex-environment
      (agent-shell-make-environment-variables
       "OPENAI_API_KEY" (getenv "OPENAI_API_KEY")
       "ANTHROPIC_BASE_URL" "https://api.studio.genai.cba"
       "NODE_TLS_REJECT_UNAUTHORIZED" "0"))

;; Warn if API keys not set
(unless (getenv "OPENAI_API_KEY")
  (message "WARNING: OPENAI_API_KEY environment variable not set"))

;; Explicitly set the default models
(setq agent-shell-anthropic-default-model-id "aipe-bedrock-claude-4-5-sonnet")
(setq agent-shell-openai-codex-default-model-id "aipe-bedrock-claude-4-5-sonnet")

;; Set codex executable path if needed
(setq agent-shell-openai-codex-executable "/opt/homebrew/bin/codex")
