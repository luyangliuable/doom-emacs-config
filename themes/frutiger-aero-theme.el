;;; frutiger-aero-theme.el --- Authentic Frutiger Aero Dark theme for Emacs

;; Copyright (C) 2026

;; Author: Custom Theme
;; Version: 2.0.0
;; Package-Requires: ((emacs "25.1"))
;; Keywords: faces, theme, frutiger, aero, dark

;;; Commentary:
;;
;; An authentic Frutiger Aero Dark theme inspired by the VSCode theme,
;; featuring deep space backgrounds, electric neon accents,
;; and the signature glass-like translucent aesthetic.

;;; Code:

(deftheme frutiger-aero
  "Authentic Frutiger Aero Dark theme with deep backgrounds and neon accents.")

;; Authentic Frutiger Aero Dark Color Palette
(let* (
       ;; Background Colors - Deep Ocean/Space
       (frutiger-bg-primary   "#0B0F1A")    ; Very dark blue-black
       (frutiger-bg-secondary "#111827")    ; Dark slate blue
       (frutiger-bg-tertiary  "#1E293B")    ; Darker slate
       (frutiger-bg-highlight "#2D3748")    ; Highlighted background
       (frutiger-bg-selection "#334155")    ; Selection background

       ;; Foreground Colors - Ice and Glass
       (frutiger-fg-primary   "#E2E8F0")    ; Icy white
       (frutiger-fg-secondary "#CBD5E0")    ; Cool gray
       (frutiger-fg-tertiary  "#A0AEC0")    ; Muted blue-gray
       (frutiger-fg-comment   "#64748B")    ; Darker blue-gray

       ;; Accent Colors - Neon Blues and Cyans
       (frutiger-cyan-bright  "#00E5FF")    ; Electric cyan
       (frutiger-cyan-medium  "#26C6DA")    ; Medium cyan
       (frutiger-cyan-soft    "#4DD0E1")    ; Soft cyan
       (frutiger-blue-electric "#1E90FF")   ; Electric blue
       (frutiger-blue-deep    "#0066CC")    ; Deep blue
       (frutiger-blue-soft    "#4FC3F7")    ; Soft blue

       ;; Nature Colors - Neon Greens
       (frutiger-green-neon   "#00FF80")    ; Neon green
       (frutiger-green-bright "#26A69A")    ; Bright teal-green
       (frutiger-green-soft   "#66BB6A")    ; Soft green
       (frutiger-green-lime   "#9CCC65")    ; Lime green

       ;; Warning/Error Colors - Neon Accents
       (frutiger-orange-neon  "#FF9500")    ; Neon orange
       (frutiger-red-neon     "#FF1744")    ; Neon red
       (frutiger-pink-neon    "#E91E63")    ; Neon pink
       (frutiger-purple-neon  "#AA00FF")    ; Neon purple
       (frutiger-yellow-neon  "#FFEB3B")    ; Neon yellow

       ;; Glass Effects - Translucent Colors
       (frutiger-glass-blue   "#1565C020")  ; Translucent blue
       (frutiger-glass-cyan   "#00ACC120")  ; Translucent cyan
       (frutiger-glass-green  "#2E7D3220")  ; Translucent green

       ;; Semantic Colors - Green-Cyan Frutiger Aero Style
       (frutiger-success      frutiger-green-neon)
       (frutiger-warning      frutiger-orange-neon)
       (frutiger-error        frutiger-red-neon)
       (frutiger-info         frutiger-cyan-bright))

  ;; Base theme faces
  (custom-theme-set-faces
   'frutiger-aero

   ;; Basic faces - Dark Background
   `(default ((t (:background ,frutiger-bg-primary :foreground ,frutiger-fg-primary))))
   `(cursor ((t (:background ,frutiger-cyan-bright))))
   `(region ((t (:background ,frutiger-bg-selection :foreground ,frutiger-fg-primary))))
   `(highlight ((t (:background ,frutiger-bg-highlight :foreground ,frutiger-cyan-bright))))
   `(hl-line ((t (:background ,frutiger-bg-secondary))))
   `(fringe ((t (:background ,frutiger-bg-primary :foreground ,frutiger-fg-tertiary))))
   `(show-paren-match ((t (:background ,frutiger-cyan-bright :foreground ,frutiger-bg-primary :weight bold))))
   `(show-paren-mismatch ((t (:background ,frutiger-error :foreground ,frutiger-fg-primary :weight bold))))

   ;; Font lock (syntax highlighting) - Balanced Cyan-Green Mix
   `(font-lock-builtin-face ((t (:foreground ,frutiger-cyan-bright :weight semi-bold))))
   `(font-lock-comment-face ((t (:foreground ,frutiger-fg-comment :slant italic))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,frutiger-fg-comment))))
   `(font-lock-constant-face ((t (:foreground ,frutiger-green-neon :weight bold))))
   `(font-lock-function-name-face ((t (:foreground ,frutiger-cyan-bright :weight bold))))
   `(font-lock-keyword-face ((t (:foreground ,frutiger-green-bright :weight bold))))
   `(font-lock-string-face ((t (:foreground ,frutiger-cyan-soft))))
   `(font-lock-type-face ((t (:foreground ,frutiger-cyan-medium :weight semi-bold))))
   `(font-lock-variable-name-face ((t (:foreground ,frutiger-green-soft))))
   `(font-lock-warning-face ((t (:foreground ,frutiger-warning :weight bold))))
   `(font-lock-doc-face ((t (:foreground ,frutiger-green-lime :slant italic))))

   ;; Line numbers - Aqua Blue Theme
   `(line-number ((t (:foreground ,frutiger-cyan-medium :background ,frutiger-bg-primary))))
   `(line-number-current-line ((t (:foreground ,frutiger-cyan-bright :background ,frutiger-bg-secondary :weight bold))))

   ;; Mode line - Green-Cyan Mixed Glass Effect
   `(mode-line ((t (:background ,frutiger-bg-secondary :foreground ,frutiger-green-neon
                   :box (:line-width 1 :color ,frutiger-green-bright)))))
   `(mode-line-inactive ((t (:background ,frutiger-bg-primary :foreground ,frutiger-green-soft
                             :box (:line-width 1 :color ,frutiger-green-lime)))))
   `(mode-line-buffer-id ((t (:foreground ,frutiger-cyan-bright :weight bold))))

   ;; Minibuffer
   `(minibuffer-prompt ((t (:foreground ,frutiger-cyan-bright :weight bold))))

   ;; Search - Neon Highlights
   `(isearch ((t (:background ,frutiger-orange-neon :foreground ,frutiger-bg-primary :weight bold))))
   `(lazy-highlight ((t (:background ,frutiger-bg-highlight :foreground ,frutiger-cyan-bright))))

   ;; Links
   `(link ((t (:foreground ,frutiger-blue-electric :underline t))))
   `(link-visited ((t (:foreground ,frutiger-blue-soft :underline t))))

   ;; Org mode - No Purple Headers
   `(org-level-1 ((t (:foreground ,frutiger-cyan-bright :weight bold :height 1.3))))
   `(org-level-2 ((t (:foreground ,frutiger-blue-electric :weight bold :height 1.2))))
   `(org-level-3 ((t (:foreground ,frutiger-orange-neon :weight bold :height 1.1))))
   `(org-level-4 ((t (:foreground ,frutiger-cyan-medium :weight semi-bold))))
   `(org-link ((t (:foreground ,frutiger-blue-electric :underline t))))
   `(org-done ((t (:foreground ,frutiger-green-neon :weight bold))))
   `(org-todo ((t (:foreground ,frutiger-warning :weight bold))))

   ;; Company (completion) - Glass Effect
   `(company-tooltip ((t (:background ,frutiger-bg-tertiary :foreground ,frutiger-fg-primary))))
   `(company-tooltip-selection ((t (:background ,frutiger-bg-highlight :foreground ,frutiger-cyan-bright))))
   `(company-tooltip-common ((t (:foreground ,frutiger-cyan-bright :weight bold))))
   `(company-scrollbar-bg ((t (:background ,frutiger-bg-secondary))))
   `(company-scrollbar-fg ((t (:background ,frutiger-cyan-medium))))

   ;; Doom specific - Green-Blue Mix
   `(doom-modeline-bar ((t (:background ,frutiger-green-bright))))
   `(doom-modeline-project-dir ((t (:foreground ,frutiger-green-neon :weight bold))))
   `(doom-modeline-buffer-file ((t (:foreground ,frutiger-cyan-bright :weight bold))))
   `(doom-modeline-buffer-modified ((t (:foreground ,frutiger-orange-neon))))

   ;; Treemacs - No Purple File Tree
   `(treemacs-directory-face ((t (:foreground ,frutiger-cyan-bright :weight bold))))
   `(treemacs-file-face ((t (:foreground ,frutiger-fg-primary))))
   `(treemacs-root-face ((t (:foreground ,frutiger-orange-neon :weight bold :height 1.2))))

   ;; Magit - Green-Blue Git Interface
   `(magit-branch-local ((t (:foreground ,frutiger-green-bright :weight bold))))
   `(magit-branch-remote ((t (:foreground ,frutiger-blue-electric :weight bold))))
   `(magit-diff-added ((t (:background ,frutiger-glass-green :foreground ,frutiger-green-neon))))
   `(magit-diff-removed ((t (:background ,frutiger-bg-highlight :foreground ,frutiger-red-neon))))
   `(magit-hash ((t (:foreground ,frutiger-fg-comment))))
   `(magit-section-heading ((t (:foreground ,frutiger-green-lime :weight bold))))

   ;; Flycheck/Flymake - Neon Underlines
   `(flycheck-error ((t (:underline (:style wave :color ,frutiger-error)))))
   `(flycheck-warning ((t (:underline (:style wave :color ,frutiger-warning)))))
   `(flycheck-info ((t (:underline (:style wave :color ,frutiger-info)))))

   ;; Shell and compilation errors
   `(compilation-error ((t (:foreground ,frutiger-orange-neon :weight bold))))
   `(compilation-warning ((t (:foreground ,frutiger-warning :weight bold))))
   `(compilation-info ((t (:foreground ,frutiger-info :weight bold))))
   `(compilation-line-number ((t (:foreground ,frutiger-cyan-medium))))
   `(compilation-column-number ((t (:foreground ,frutiger-cyan-soft))))

   ;; LSP - Glass Highlights
   `(lsp-face-highlight-textual ((t (:background ,frutiger-glass-cyan))))
   `(lsp-face-highlight-read ((t (:background ,frutiger-glass-cyan))))
   `(lsp-face-highlight-write ((t (:background ,frutiger-glass-blue))))

   ;; Ivy/Counsel/Swiper - Aqua Blue Selection
   `(ivy-current-match ((t (:background ,frutiger-bg-highlight :foreground ,frutiger-cyan-bright :weight bold))))
   `(ivy-minibuffer-match-face-1 ((t (:background ,frutiger-glass-cyan))))
   `(ivy-minibuffer-match-face-2 ((t (:background ,frutiger-glass-blue :foreground ,frutiger-cyan-bright))))

   ;; Which-key - Aqua Blue
   `(which-key-key-face ((t (:foreground ,frutiger-cyan-bright :weight bold))))
   `(which-key-description-face ((t (:foreground ,frutiger-fg-primary))))
   `(which-key-group-description-face ((t (:foreground ,frutiger-blue-electric :weight bold))))
   `(which-key-command-description-face ((t (:foreground ,frutiger-blue-soft))))

   ;; Success/Warning/Error states - Neon
   `(success ((t (:foreground ,frutiger-success :weight bold))))
   `(warning ((t (:foreground ,frutiger-warning :weight bold))))
   `(error ((t (:foreground ,frutiger-error :weight bold))))

   ;; Selection - Glass Effect
   `(secondary-selection ((t (:background ,frutiger-glass-cyan))))

   ;; Trailing whitespace
   `(trailing-whitespace ((t (:background ,frutiger-red-neon))))

   ;; YAML mode - Balanced colors for config files
   `(yaml-tab-face ((t (:background ,frutiger-bg-highlight))))

   ;; Recentf - Fix purple text issue
   `(recentf-file-face ((t (:foreground ,frutiger-fg-primary))))

   ;; Additional mode-specific fixes - No Purple
   `(default-italic ((t (:foreground ,frutiger-fg-primary :slant italic))))
   `(emphasize ((t (:foreground ,frutiger-fg-primary))))
   `(font-lock-negation-char-face ((t (:foreground ,frutiger-orange-neon))))
   `(font-lock-preprocessor-face ((t (:foreground ,frutiger-cyan-bright))))
   `(font-lock-regexp-grouping-construct ((t (:foreground ,frutiger-cyan-medium))))
   `(font-lock-regexp-grouping-backslash ((t (:foreground ,frutiger-cyan-medium)))))

  ;; Custom theme variables - Green-Blue Terminal Colors
  (custom-theme-set-variables
   'frutiger-aero
   `(ansi-color-names-vector
     [,frutiger-bg-primary ,frutiger-red-neon ,frutiger-green-neon ,frutiger-orange-neon
      ,frutiger-blue-electric ,frutiger-cyan-medium ,frutiger-cyan-bright ,frutiger-fg-primary])))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'frutiger-aero)

;;; frutiger-aero-theme.el ends here