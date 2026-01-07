;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Personal Doom Emacs Configuration
;; Split into organized modules for better maintainability

;; Load existing custom modules
(load! "elisp-functions/functions")
(load! "themes")

;; Load core configuration modules (order matters)
(load! "config/core")              ; Core settings first
(load! "config/ui")                ; UI packages after core
(load! "config/packages/editorconfig")
(load! "config/packages/lsp")
(load! "config/packages/projectile")
(load! "config/packages/agent-shell")
(load! "config/modes")             ; Mode hooks
(load! "config/keybindings")       ; Keybindings after packages
(load! "config/packages/evil")     ; Evil fixes last
(load! "config/packages/drag-stuff")

; Source - https://stackoverflow.com/a
; Posted by Trey Jackson, modified by community. See post 'Timeline' for change history
; Retrieved 2026-01-06, License - CC BY-SA 4.0
(setq debug-on-error t)


;; (load! "config/packages/gptel")     ; gptel

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
