;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Personal Doom Emacs Configuration (OPTIMIZED & REORGANIZED)
;; Split into organized modules in lisp/ directory for better maintainability

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

;;; ============================================================================
;;; CORE SETTINGS
;;; ============================================================================

(load! "lisp/core/settings")  ;; exec-path, fonts, display, ripgrep
(load! "lisp/core/ui")         ;; UI packages, theme management
(load! "lisp/core/modes")      ;; Mode hooks, file handling

;;; ============================================================================
;;; CUSTOM FUNCTIONS
;;; ============================================================================

(load! "lisp/functions/buffer")  ;; Buffer operations
(load! "lisp/functions/window")  ;; Window management
(load! "lisp/functions/file")    ;; File operations
(load! "lisp/functions/magit")   ;; Magit & shell integration
(load! "lisp/functions/text")    ;; Text operations & UI toggles

;;; ============================================================================
;;; PACKAGE CONFIGURATIONS
;;; ============================================================================

(load! "lisp/packages/evil")            ;; Evil configuration EARLY
(load! "lisp/packages/agent-shell")
(load! "lisp/packages/auto-highlight-symbol")
(load! "lisp/packages/centered-buffer")
(load! "lisp/packages/consult")
(load! "lisp/packages/drag-stuff")
(load! "lisp/packages/editorconfig")
(load! "lisp/packages/git-timemachine")
(load! "lisp/packages/golden-ratio")
(load! "lisp/packages/gptel")
(load! "lisp/packages/lsp")
(load! "lisp/packages/org-jira")
(load! "lisp/packages/projectile")
(load! "lisp/packages/treemacs")
(load! "lisp/packages/vertico")
(ignore-errors
  (load! "lisp/packages/lsp-vtsls"))

;;; ============================================================================
;;; KEYBINDINGS
;;; ============================================================================

;; Load individual keybinding modules with proper error handling
(dolist (file '("gptel" "evil" "treemacs" "lsp" "shell" "magit" "emacs-lisp"
                "zone" "good-scroll" "undo-tree" "narrow" "frames"))
  (let* ((filepath (concat "lisp/keybindings/" file))
         (fullpath (concat doom-private-dir filepath ".el")))
    (if (file-exists-p fullpath)
        (condition-case err
            (load! filepath)
          (error
           (message "ERROR: Failed to load keybindings file %s: %s"
                    filepath (error-message-string err))))
      (message "WARNING: Keybinding file not found: %s" filepath))))

;; Load core keybindings (main keybinding block)
(load! "lisp/keybindings/core")

;;; ============================================================================
;;; MISC SETTINGS
;;; ============================================================================

; Source - https://stackoverflow.com/a
; Posted by Trey Jackson, modified by community. See post 'Timeline' for change history
; Retrieved 2026-01-06, License - CC BY-SA 4.0
(setq debug-on-error nil)

;;; config.el ends here
