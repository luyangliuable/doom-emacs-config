;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Personal Doom Emacs Configuration
;; Split into organized modules for better maintainability

;; CRITICAL: Evil operator configuration MUST happen early
;; These variables need to be set before evil loads
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(setq evil-want-operator-state t)
(setq evil-want-operator-pending-state t)
(setq evil-want-visual-char-semi-exclusive t)
(setq evil-want-C-u-scroll t)
(setq evil-want-C-d-scroll t)
(setq evil-want-Y-yank-to-eol t)

;; Load existing custom modules
(load! "elisp-functions/functions")
(load! "themes")

;; Load core configuration modules (order matters)
(load! "config/core")                     ; Core settings first
(load! "config/modes")                    ; Mode hooks
(load! "config/packages/evil")            ; Evil configuration EARLY
(load! "config/packages/agent-shell")     ; agent-shell
(load! "config/packages/auto-highlight-symbol") ; auto-highlight-symbol
(load! "config/packages/drag-stuff")      ; dragstuff
(load! "config/packages/editorconfig")    ; editorconfig
(load! "config/packages/gptel")           ; gptel
(load! "config/packages/lsp")             ; lsp
(load! "config/packages/projectile")      ; projectile
(load! "config/packages/consult")         ; consult + ripgrep
(load! "config/packages/vertico")         ; vertico optimization
(load! "config/packages/treemacs")        ; treemacs
(load! "config/packages/org-jira")        ; org jira
(load! "config/keybindings")              ; Keybindings after packages
(load! "config/ui")                       ; UI packages after core
(ignore-errors
    (load! "config/packages/lsp-vtsls")) ; lsp-vtsls

; Source - https://stackoverflow.com/a
; Posted by Trey Jackson, modified by community. See post 'Timeline' for change history
; Retrieved 2026-01-06, License - CC BY-SA 4.0
(setq debug-on-error nil)

;; anki-editor configuration
;; (use-package! anki-editor
;;   :after org
;;   :bind (("C-c a c" . anki-editor-cloze-region-auto-incr)
;;          ("C-c a r" . anki-editor-retry-failure-notes)
;;          ("C-c a p" . anki-editor-push-tree)
;;          ("C-c a P" . anki-editor-push-notes)
;;          ("C-c a b" . anki-editor-browse-notes)
;;          ("C-c a g" . anki-editor-gui-browse))
;;   :config
;;   (setq anki-editor-create-decks t
;;         anki-editor-org-tags-as-anki-tags t))
