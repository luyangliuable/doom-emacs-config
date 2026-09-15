;;; config/packages/agent-shell.el -*- lexical-binding: t; -*-
;; Agent Shell Package Configuration

(use-package agent-shell
  :ensure-system-package ((claude-code-acp . "npm install -g @zed-industries/claude-code-acp"))
  :config
  (map! :leader
        :desc "run agent shell" "o S" #'agent-shell)
  (map! :leader
        :desc "run codex shell" "o C" #'agent-shell-openai-codex)
  (map! :leader
        :desc "run pi shell" "o P" #'agent-shell-pi-start-agent)
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
        :desc "Reset image scale" "0" #'agent-shell-image-scale-reset))

;; Use Doom-managed package paths so this configuration is portable.
(defun my/doom-straight-build-dir (package)
  "Return the Doom-managed Straight build directory for PACKAGE."
  (expand-file-name
   (format "straight/build-%s/%s/" emacs-version package)
   doom-local-dir))

(dolist (package '("agent-shell-workspace" "agent-shell-hud"))
  (add-to-list 'load-path (my/doom-straight-build-dir package)))
(add-to-list 'load-path
             (expand-file-name "lisp/"
                               (my/doom-straight-build-dir "workspace-hud")))

(use-package! agent-shell-workspace
  :after agent-shell
  :config
  (map! :map agent-shell-mode-map
        :localleader
        :desc "Toggle agent workspace" "w" #'agent-shell-workspace-toggle))

(use-package! workspace-hud
  :demand t
  :config
  ;; Keep the HUD framework available for Agent Shell status tracking, but do
  ;; not create or update the graphical panel automatically.
  (workspace-hud-auto-mode -1))

(use-package! agent-shell-hud
  :after (workspace-hud agent-shell)
  :demand t
  :config
  (agent-shell-hud-mode 1))

;; Agent clients inherit credentials and provider settings from the environment.
;; Never store endpoint or credential overrides in shared configuration.
(setq agent-shell-anthropic-claude-environment
      (agent-shell-make-environment-variables :inherit-env t)
      agent-shell-opencode-environment
      (agent-shell-make-environment-variables :inherit-env t)
      agent-shell-openai-codex-environment
      (agent-shell-make-environment-variables :inherit-env t)
      agent-shell-anthropic-default-model-id nil
      agent-shell-openai-default-model-id nil)

;; Resolve optional agent CLIs from the current Emacs environment.
(setq agent-shell-openai-codex-executable
      (or (executable-find "codex") "codex"))

;; Pi coding agent configuration
(setq agent-shell-pi-acp-command
      (list (or (executable-find "pi-acp") "pi-acp")))
(setq agent-shell-pi-environment
      (agent-shell-make-environment-variables
       "PI_ACP_PI_COMMAND" (expand-file-name "config/pi-emacs-rpc" doom-user-dir)
       :inherit-env t))
