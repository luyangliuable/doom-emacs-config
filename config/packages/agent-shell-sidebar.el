;; Bind before Agent Shell loads; the commands load it (and this :config) first.
(dolist (command '(agent-shell-sidebar-toggle
                   agent-shell-sidebar-toggle-focus
                   agent-shell-sidebar-change-provider
                   agent-shell-sidebar-reset))
  (autoload command "agent-shell" nil t))
(map! :leader
  :desc "toggle Pi sidebar" "f a" #'agent-shell-sidebar-toggle)

(use-package agent-shell-sidebar
  :after agent-shell
  :config
  ;; Sidebar default agent config (default: nil
  (setq agent-shell-sidebar-default-config 'pi)

  ;; Sidebar width (default: "25%")
  ;; Can be integer (columns) or string with % (percentage of frame)
  (setq agent-shell-sidebar-width "20%")

  ;; Minimum width (default: 80)
  (setq agent-shell-sidebar-minimum-width 40)

  ;; Maximum width (default: "50%")
  (setq agent-shell-sidebar-maximum-width "40%")

  ;; Position: 'left or 'right (default: 'right)
  (setq agent-shell-sidebar-position 'right)

  ;; Lock sidebar position and size (default: t)
  ;; When locked: fixed size, invisible to other-window (C-x o)
  ;; When unlocked: manually resizable, visible to other-window
  (setq agent-shell-sidebar-locked nil)

  (defun agent-shell-sidebar--select-config ()
    "Return the configured sidebar agent using Agent Shell's config resolver."
    (if agent-shell-sidebar-default-config
      (or (agent-shell--resolve-config-designator
            agent-shell-sidebar-default-config)
        (user-error "No agent config found for: %s"
          agent-shell-sidebar-default-config))
      (agent-shell-select-config :prompt "Select agent: "))))
