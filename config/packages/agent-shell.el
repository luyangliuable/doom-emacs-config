;;; config/packages/agent-shell.el -*- lexical-binding: t; -*-
;; Agent Shell Package Configuration

;; Agent Shell loads after startup, but its agents inherit the startup environment.
(defvar luyangliuable/agent-shell-startup-environment nil)
(setq luyangliuable/agent-shell-startup-environment process-environment)
(defvar luyangliuable/agent-shell-preload-timer nil)

(use-package agent-shell
  :commands (agent-shell)
  :init
  ;; Load Agent Shell (and its :config) before any agent's own library.
  (dolist (command '(agent-shell-openai-start-codex agent-shell-pi-start-agent))
    (autoload command "agent-shell" nil t))
  ;; Preload once idle, a file per step, then LSP (see lsp.el); reloading the
  ;; config replaces the pending timer.
  (when (timerp luyangliuable/agent-shell-preload-timer)
    (cancel-timer luyangliuable/agent-shell-preload-timer))
  (setq luyangliuable/agent-shell-preload-timer
        (unless (featurep 'agent-shell)
          (run-with-idle-timer 1.5 nil #'luyangliuable/preload-when-idle
                               'agent-shell #'luyangliuable/preload-lsp)))
  (map! :leader
        :desc "run agent shell" "o S" #'agent-shell)
  (map! :leader
        :desc "run codex shell" "o C" #'agent-shell-openai-start-codex)
  (map! :leader
        :desc "run pi shell" "o P" #'agent-shell-pi-start-agent)
  :config
  (setq agent-shell-header-style 'text
        agent-shell-show-config-icons nil)
  (map! :map agent-shell-mode-map
        :localleader
        :desc "Send prompt" "s" #'agent-shell-submit
        :desc "Interrupt turn" "k" #'agent-shell-interrupt
        :desc "Help menu" "h" #'agent-shell-help-menu
        :desc "Other buffer" "o" #'agent-shell-other-buffer
        :desc "New session" "n" #'agent-shell-new-shell
        :desc "Fork session" "f" #'agent-shell-fork
        :desc "Session mode" "m" #'agent-shell-set-session-mode
        :desc "Model" "M" #'agent-shell-set-session-model
        :desc "Thinking level" "t" #'agent-shell-set-session-thought-level
        :desc "Config option" "c" #'agent-shell-set-session-config-option
        :desc "Toggle sidebar" "a" #'agent-shell-sidebar-toggle
        :desc "Toggle sidebar focus" "A" #'agent-shell-sidebar-toggle-focus
        :desc "Toggle fragment" "RET" #'agent-shell-ui-toggle-fragment
        :desc "Toggle all fragments" "z" #'agent-shell-ui-toggle-all-fragments
        :desc "Toggle logging" "l" #'agent-shell-toggle-logging
        (:prefix ("j" . "navigate")
         :desc "Next item" "n" #'agent-shell-next-item
         :desc "Previous item" "p" #'agent-shell-previous-item
         :desc "Up item" "u" #'agent-shell-backward-up-item)
        (:prefix ("y" . "copy")
         :desc "Last output" "o" #'agent-shell-copy-last-output
         :desc "Session ID" "s" #'agent-shell-copy-session-id
         :desc "Link URL" "l" #'agent-shell-copy-link-url-at-point
         :desc "Source block" "c" #'agent-shell-copy-source-block-at-point
         :desc "Region as Markdown" :v "m" #'agent-shell-copy-as-markdown)
        (:prefix ("i" . "insert")
         :desc "File" "f" #'agent-shell-send-file
         :desc "Clipboard image" "c" #'agent-shell-send-clipboard-image
         :desc "Screenshot" "s" #'agent-shell-send-screenshot)
        (:prefix ("p" . "permission")
         :desc "Next" "n" #'agent-shell-next-permission-button
         :desc "Previous" "p" #'agent-shell-previous-permission-button
         :desc "Latest" "l" #'agent-shell-jump-to-latest-permission-button-row)
        (:prefix ("e" . "export")
         :desc "Transcript" "t" #'agent-shell-open-transcript)
        :desc "Increase image scale" "+" #'agent-shell-image-scale-increase
        :desc "Decrease image scale" "-" #'agent-shell-image-scale-decrease
        :desc "Reset image scale" "0" #'agent-shell-image-scale-reset)

  ;; Agent clients inherit credentials and provider settings from the environment.
  ;; Never store endpoint or credential overrides in shared configuration.
  (let ((process-environment luyangliuable/agent-shell-startup-environment))
    (setq agent-shell-anthropic-claude-environment
          (agent-shell-make-environment-variables :inherit-env t)
          agent-shell-opencode-environment
          (agent-shell-make-environment-variables :inherit-env t)
          agent-shell-openai-codex-environment
          (agent-shell-make-environment-variables :inherit-env t)
          agent-shell-pi-environment
          (agent-shell-make-environment-variables
           "PI_ACP_PI_COMMAND" (expand-file-name "config/pi-emacs-rpc" doom-user-dir)
           :inherit-env t)
          agent-shell-anthropic-default-model-id nil
          agent-shell-openai-default-model-id nil)))

;; Check for the client at startup, not when the deferred package loads.
(use-package agent-shell
  :no-require t
  :ensure-system-package ((claude-code-acp . "npm install -g @zed-industries/claude-code-acp")))

;; Resolve optional agent CLIs from the current Emacs environment.
(setq agent-shell-openai-codex-executable
      (or (executable-find "codex") "codex"))

;; Pi coding agent configuration
(setq agent-shell-pi-acp-command
      (list (or (executable-find "pi-acp") "pi-acp")))
