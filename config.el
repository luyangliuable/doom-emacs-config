;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Personal Doom Emacs Configuration
;; Split into organized modules for better maintainability

;; ---------------------------------------------------------------------------
;; TEMPORARY DIAGNOSTIC (remove once the face bug is found)
;; Turns the recurring messages into a backtrace so we can see which package/
;; segment builds `:foreground nil'. Reproduce (move cursor / let the modeline
;; animate) and copy the *Backtrace* buffer contents.
(setq debug-on-message
      "Invalid face attribute :foreground nil\\|Buffer is read-only")
;; ---------------------------------------------------------------------------

;; Load existing custom modules
(load! "elisp-functions/functions")
(load! "themes")

;; Load core configuration modules (order matters)
(load! "config/core")                     ; Core settings first
;; Per-machine settings are intentionally kept out of version control.
(let ((local-config (expand-file-name "config/local.el" doom-user-dir)))
  (when (file-exists-p local-config)
    (load local-config nil 'nomessage)))
(load! "config/packages/performance")     ; Performance tuning (GC, read-process-output-max, company/flycheck delays)
(load! "config/packages/git")             ; Magit/vc-git run git without the xcrun shim
(load! "config/modes")                    ; Mode hooks
(load! "config/packages/evil")            ; Evil configuration EARLY
(load! "config/packages/agent-shell-hud") ; agent-shell-hud
(load! "config/packages/agent-shell-workspace") ; agent-shell-workspace
(load! "config/packages/workspace-hud")   ; workspace-hud
(load! "config/packages/agent-shell")     ; agent-shell
(load! "config/packages/agent-shell-sidebar") ; agent-shell-sidebar
(load! "config/packages/auto-highlight-symbol") ; auto-highlight-symbol
(load! "config/packages/drag-stuff")      ; dragstuff
(load! "config/packages/editorconfig")    ; editorconfig
(load! "config/packages/copilot")         ; GitHub Copilot inline completions and chat
(load! "config/packages/gptel")           ; gptel
(load! "config/packages/lsp")             ; lsp
(load! "config/packages/notebook")        ; Jupyter notebooks
(load! "config/packages/projectile")      ; projectile
(load! "config/packages/consult")         ; consult + ripgrep
(load! "config/packages/vertico")         ; vertico optimization
(load! "config/packages/treemacs")        ; treemacs
(load! "config/packages/org-jira")        ; org jira
(load! "config/packages/org-brain")       ; org-brain concept map/wiki
(load! "config/packages/org")             ; daily task rollover
(load! "config/packages/org-parallel-clock") ; overlapping/parallel org clocks
(load! "config/packages/latex-preview")  ; LaTeX previews in org/markdown
(load! "config/packages/golden-ratio")    ; golden-ratio
(load! "config/packages/centered-buffer") ; centered-buffer
(load! "config/packages/persistent-scratch") ; persistent-scratch
(load! "config/packages/plantuml-mode")   ; plantuml diagrams
(load! "config/debug-file-open")           ; temporary file-open debugging
(load! "config/keybindings")              ; Keybindings after packages
(load! "config/packages/beacon")          ; beacon cursor highlight
(load! "config/packages/bongo-cat-mode")  ; bongo cat modeline companion
(load! "config/packages/doom-modeline")   ; doom-modeline
(load! "config/packages/minor-mode-badges") ; minor-mode-badges (after doom-modeline)
(load! "config/packages/good-scroll")     ; smooth scrolling
(load! "config/packages/minimap")         ; code minimap
(load! "config/ui")                       ; package-agnostic UI behaviors
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

;; enime - watch anime in emacs (https://github.com/xl666/enime)
;; (use-package! enime
;;   :commands (enime-main-transient enime-anime-transient)
;;   :config
;;   (setq enime-tmp-dir "/tmp"
;;         enime-storage-file "/tmp/enime.db"))

;; (map! :leader
;;       (:prefix ("a a" . "anime/enime")
;;        :desc "Enime main (search/followed)" "a" #'enime-main-transient
;;        :desc "Enime current anime actions"  "c" #'enime-anime-transient
;;        :desc "Search for anime"             "s" #'enime-main-transient
;;        :desc "Followed animes"              "f" #'enime-main-transient))
