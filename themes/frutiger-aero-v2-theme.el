;;; frutiger-aero-v2-theme.el --- Frutiger Aero v2: Vista aurora lagoon -*- lexical-binding: t; no-byte-compile: t; -*-

;; Version: 2.1.0
;; Package-Requires: ((emacs "29.1") (doom-themes "2.2"))
;; Keywords: faces, theme, frutiger, aero, dark

;;; Commentary:
;;
;; "Vista aurora lagoon": the dark half of Frutiger Aero, lit from within.
;;
;; - Canvas: a saturated cerulean lagoon (#143A55) -- deeper than a Vista
;;   wallpaper, far lighter than midnight, never grey slate.
;; - Glass: highlights are *lighter* than the water (light refracting through
;;   a pane); the mode-line is smoky Vista-taskbar glass with an aqua
;;   reflection rim; popups float as darker pools with an aqua edge.
;; - Nature: aqua foam, sky blue, grass green, sun yellow and aurora violet.
;; - Frutiger: headings use a humanist sans (Frutiger, or Avenir -- also an
;;   Adrian Frutiger design -- when installed).  See
;;   `frutiger-aero-v2-humanist-font'.
;;
;; The original `frutiger-aero' theme is untouched; see
;; `frutiger-aero-v2-light' for the daytime "sky & glass" counterpart.

;;; Code:

(require 'cl-lib)
(require 'doom-themes)

(defgroup frutiger-aero-v2-theme nil
  "Options for the `frutiger-aero-v2' themes."
  :group 'doom-themes)

(defcustom frutiger-aero-v2-humanist-font 'auto
  "Humanist sans family used for headings in the Frutiger Aero v2 themes.
`auto' picks the first installed family in
`frutiger-aero-v2-humanist-candidates', a string names a family
explicitly, and nil keeps headings in the default font."
  :type '(choice (const :tag "Auto-detect" auto)
                 (const :tag "Default font" nil)
                 (string :tag "Font family"))
  :group 'frutiger-aero-v2-theme)

(defcustom frutiger-aero-v2-humanist-candidates
  '("Frutiger" "Frutiger LT Std" "Frutiger Next LT W1G" "Avenir Next" "Avenir"
    "Myriad Pro" "Segoe UI" "Helvetica Neue" "Noto Sans" "Open Sans")
  "Humanist sans families tried, in order, when the heading font is `auto'."
  :type '(repeat string)
  :group 'frutiger-aero-v2-theme)

(defun frutiger-aero-v2--humanist-family ()
  "Return the heading family for the v2 themes, or `unspecified'."
  (let ((choice frutiger-aero-v2-humanist-font))
    (cond ((stringp choice) choice)
          ((eq choice 'auto)
           (let ((families (ignore-errors (font-family-list))))
             (or (cl-find-if (lambda (family) (member family families))
                             frutiger-aero-v2-humanist-candidates)
                 'unspecified)))
          (t 'unspecified))))

(def-doom-theme frutiger-aero-v2
  "Dark Frutiger Aero v2: a lit cerulean lagoon under aqua glass."
  :family 'frutiger-aero
  :background-mode 'dark

  ;; name        default   256       16
  ((bg         '("#143A55" "#143a55" "black"        ))
   (fg         '("#EAF6FC" "#eaf6fc" "brightwhite"  ))

   (bg-alt     '("#10304A" "#10304a" "black"        ))
   (fg-alt     '("#9CBDD0" "#9cbdd0" "white"        ))

   ;; abyss -> foam
   (base0      '("#0A2133" "#0a2133" "black"        ))
   (base1      '("#1A4462" "#1a4462" "brightblack"  ))
   (base2      '("#1F4D6D" "#1f4d6d" "brightblack"  ))
   (base3      '("#275A7C" "#275a7c" "brightblack"  ))
   (base4      '("#3A6E90" "#3a6e90" "brightblack"  ))
   (base5      '("#5F8FAC" "#5f8fac" "brightblack"  ))
   (base6      '("#7FA7BF" "#7fa7bf" "brightblack"  ))
   (base7      '("#A9C8DA" "#a9c8da" "white"        ))
   (base8      '("#F4FBFF" "#f4fbff" "brightwhite"  ))

   (grey       base5)
   (red        '("#FF959E" "#ff959e" "red"          )) ; coral
   (orange     '("#FFB46B" "#ffb46b" "brightred"    )) ; sunset
   (green      '("#A6E86E" "#a6e86e" "green"        )) ; grass
   (teal       '("#5EE6C3" "#5ee6c3" "brightgreen"  )) ; lagoon
   (yellow     '("#FFE07A" "#ffe07a" "yellow"       )) ; sun
   (blue       '("#7CCBFF" "#7ccbff" "brightblue"   )) ; sky
   (dark-blue  '("#2F86D6" "#2f86d6" "blue"         ))
   (magenta    '("#FF9EDC" "#ff9edc" "magenta"      )) ; orchid
   (violet     '("#C0B0FF" "#c0b0ff" "brightmagenta")) ; aurora
   (cyan       '("#66F0F0" "#66f0f0" "brightcyan"   )) ; aqua
   (dark-cyan  '("#4FD3DE" "#4fd3de" "cyan"         ))

   ;; universal syntax classes
   (highlight      cyan)
   (vertical-bar   base0)
   (selection      '("#1E5478" "#1e5478" "blue"))
   (builtin        dark-cyan)
   (comments       '("#94BAD0" "#94bad0" "brightblack"))
   (doc-comments   '("#9BDDB8" "#9bddb8" "green"))
   (constants      violet)
   (functions      blue)
   (keywords       cyan)
   (methods        blue)
   (operators      '("#A8E4F2" "#a8e4f2" "cyan"))
   (type           teal)
   (strings        green)
   (variables      '("#CFE8F5" "#cfe8f5" "white"))
   (numbers        orange)
   (region         selection)
   (error          red)
   (warning        orange)
   (success        green)
   (vc-modified    blue)
   (vc-added       green)
   (vc-deleted     red)

   ;; glass & water
   (glass          (doom-blend cyan bg 0.18))
   (rim            '("#8FF3F7" "#8ff3f7" "brightcyan"))
   (foam           '("#8FF7F7" "#8ff7f7" "brightcyan"))
   (lime           '("#B8F07E" "#b8f07e" "brightgreen"))
   (blossom        '("#FFB0E3" "#ffb0e3" "brightmagenta"))
   (pool           (doom-darken bg 0.22))
   (modeline-fg          fg)
   (modeline-fg-alt      fg-alt)
   (modeline-bg          '("#0B2639" "#0b2639" "black"))
   (modeline-bg-inactive '("#113049" "#113049" "black"))
   (modeline-rim         (doom-blend cyan modeline-bg 0.6)))

  ;;;; Face overrides
  (((font-lock-comment-face &override) :slant 'italic)
   ((font-lock-doc-face &override) :slant 'italic)
   ((font-lock-keyword-face &override) :weight 'semi-bold)
   ((font-lock-function-name-face &override) :weight 'semi-bold)
   ((font-lock-constant-face &override) :weight 'semi-bold)

   (cursor :background cyan)
   (hl-line :background base1 :extend t)
   ((line-number &override) :foreground base5)
   ((line-number-current-line &override) :foreground cyan :background base1 :weight 'bold)
   (fringe :background bg :foreground base5)
   (vertical-border :foreground base0 :background base0)
   ;; bevelled glass edges when window dividers are wider than 2px
   (window-divider :foreground base0)
   (window-divider-first-pixel :foreground (doom-blend cyan bg 0.35))
   (window-divider-last-pixel :foreground base0)
   (child-frame-border :background (doom-blend cyan bg 0.55))
   (internal-border :background bg-alt)

   (show-paren-match :background glass :foreground rim :weight 'bold)
   (show-paren-mismatch :background red :foreground base0 :weight 'bold)
   (secondary-selection :background glass :extend t)
   (lazy-highlight :background (doom-blend blue bg 0.32) :foreground base8 :distant-foreground base0)
   (isearch :background yellow :foreground base0 :weight 'bold)
   (isearch-fail :background (doom-blend red bg 0.3) :foreground base8)
   (link :foreground blue :underline t)
   (link-visited :foreground violet :underline t)
   (minibuffer-prompt :foreground cyan :weight 'bold)
   (tooltip :background base0 :foreground fg)
   (widget-field :background base1 :foreground fg)
   (nav-flash-face :background (doom-blend cyan bg 0.4) :foreground base8 :weight 'bold :extend t)
   (pulse-highlight-start-face :background (doom-blend cyan bg 0.5))
   (pulse-highlight-face :background (doom-blend cyan bg 0.5) :extend t)

   ;;;; Vista taskbar: smoky glass with an aqua reflection along the top
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :overline modeline-rim :box (list :line-width (quote (1 . 5)) :color modeline-bg))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :overline base2 :box (list :line-width (quote (1 . 5)) :color modeline-bg-inactive))
   (mode-line-emphasis :foreground cyan :weight 'bold)
   (mode-line-buffer-id :foreground cyan :weight 'bold)
   (mode-line-highlight :background glass :foreground base8)
   (header-line
    :background pool :foreground fg
    :overline (doom-blend cyan bg 0.45) :box (list :line-width (quote (1 . 4)) :color pool))
   (tab-bar :background base0 :foreground fg-alt)
   (tab-bar-tab
    :background selection :foreground base8 :weight 'bold
    :overline rim :box (list :line-width (quote (6 . 4)) :color selection))
   (tab-bar-tab-inactive
    :background base0 :foreground fg-alt
    :box (list :line-width (quote (6 . 4)) :color base0))
   (tab-line :background base0 :foreground fg-alt)
   (tab-line-tab-current :background selection :foreground base8 :overline rim)
   (tab-line-tab-inactive :background base0 :foreground fg-alt)

   ;;;; doom-modeline -- the aqua "start orb" bar
   (doom-modeline-bar :background cyan)
   (doom-modeline-bar-inactive :background base2)
   (doom-modeline-buffer-file :foreground fg :weight 'bold)
   (doom-modeline-buffer-path :foreground blue)
   (doom-modeline-project-dir :foreground green :weight 'bold)
   (doom-modeline-buffer-modified :foreground orange :weight 'bold)
   (doom-modeline-buffer-major-mode :foreground cyan :weight 'bold)
   (doom-modeline-info :foreground green)
   (doom-modeline-warning :foreground yellow)
   (doom-modeline-urgent :foreground red)
   (doom-modeline-panel :background selection :foreground base8 :weight 'bold)
   (doom-modeline-evil-normal-state :foreground cyan)
   (doom-modeline-evil-insert-state :foreground green)
   (doom-modeline-evil-visual-state :foreground violet)
   (doom-modeline-evil-emacs-state :foreground magenta)
   (doom-modeline-evil-replace-state :foreground red)
   (doom-modeline-evil-operator-state :foreground blue)

   ;;;; solaire-mode -- sidebars sink into slightly deeper water
   (solaire-default-face :inherit 'default :background bg-alt)
   (solaire-hl-line-face :background base1 :extend t)
   (solaire-mode-line-face :inherit 'mode-line :background modeline-bg)
   (solaire-mode-line-inactive-face :inherit 'mode-line-inactive :background modeline-bg-inactive)

   ;;;; completion -- popups are dark pools with aqua glass selections
   (vertico-current :background selection :foreground base8 :weight 'bold :extend t)
   (vertico-posframe-border :background (doom-blend cyan bg 0.55))
   (corfu-default :background pool :foreground fg)
   (corfu-current :background selection :foreground base8 :weight 'bold)
   (corfu-border :background (doom-blend cyan bg 0.55))
   (corfu-bar :background cyan)
   (company-tooltip :background pool :foreground fg)
   (company-tooltip-selection :background selection :foreground base8 :weight 'bold)
   (company-tooltip-common :foreground foam :weight 'bold)
   (company-tooltip-annotation :foreground fg-alt)
   (company-scrollbar-bg :background base1)
   (company-scrollbar-fg :background cyan)
   (orderless-match-face-0 :foreground foam :weight 'bold)
   (orderless-match-face-1 :foreground lime :weight 'bold)
   (orderless-match-face-2 :foreground yellow :weight 'bold)
   (orderless-match-face-3 :foreground blossom :weight 'bold)

   ;;;; org / outline -- aqua to aurora ramp, humanist headings
   ((outline-1 &override) :foreground cyan)
   ((outline-2 &override) :foreground blue)
   ((outline-3 &override) :foreground green)
   ((outline-4 &override) :foreground teal)
   ((outline-5 &override) :foreground violet)
   ((outline-6 &override) :foreground yellow)
   ((outline-7 &override) :foreground magenta)
   ((outline-8 &override) :foreground orange)
   (org-document-title
    :foreground rim :weight 'bold :height 1.6
    :family (frutiger-aero-v2--humanist-family))
   (org-document-info :foreground blue :family (frutiger-aero-v2--humanist-family))
   (org-document-info-keyword :foreground comments)
   (org-level-1
    :inherit 'outline-1 :height 1.35 :overline (doom-blend cyan bg 0.35)
    :family (frutiger-aero-v2--humanist-family))
   (org-level-2 :inherit 'outline-2 :height 1.2 :family (frutiger-aero-v2--humanist-family))
   (org-level-3 :inherit 'outline-3 :height 1.1 :family (frutiger-aero-v2--humanist-family))
   (org-level-4 :inherit 'outline-4 :family (frutiger-aero-v2--humanist-family))
   (org-level-5 :inherit 'outline-5 :family (frutiger-aero-v2--humanist-family))
   (org-level-6 :inherit 'outline-6 :family (frutiger-aero-v2--humanist-family))
   (org-level-7 :inherit 'outline-7 :family (frutiger-aero-v2--humanist-family))
   (org-level-8 :inherit 'outline-8 :family (frutiger-aero-v2--humanist-family))
   ((org-block &override) :background pool :extend t)
   ((org-block-begin-line &override)
    :background (doom-blend cyan pool 0.1) :foreground dark-cyan :extend t)
   ((org-block-end-line &override)
    :background (doom-blend cyan pool 0.1) :foreground dark-cyan :extend t)
   ((org-quote &override) :background pool :slant 'italic)
   (org-code :foreground yellow :background pool)
   (org-verbatim :foreground green)
   (org-todo :foreground lime :background (doom-blend green bg 0.15) :weight 'bold)
   (org-done :foreground base6 :weight 'bold)
   (org-headline-done :foreground base6)
   (org-tag :foreground fg-alt :weight 'normal)
   (org-date :foreground violet)
   (org-checkbox :foreground cyan :background 'unspecified :weight 'bold)
   (org-ellipsis :underline nil :foreground cyan)

   ;;;; markdown
   (markdown-header-face :inherit 'bold :foreground cyan)
   (markdown-header-face-1
    :inherit 'outline-1 :height 1.35 :family (frutiger-aero-v2--humanist-family))
   (markdown-header-face-2
    :inherit 'outline-2 :height 1.2 :family (frutiger-aero-v2--humanist-family))
   (markdown-header-face-3
    :inherit 'outline-3 :height 1.1 :family (frutiger-aero-v2--humanist-family))
   ((markdown-code-face &override) :background pool :extend t)

   ;;;; rainbow-delimiters -- water spectrum
   (rainbow-delimiters-depth-1-face :foreground cyan)
   (rainbow-delimiters-depth-2-face :foreground blue)
   (rainbow-delimiters-depth-3-face :foreground green)
   (rainbow-delimiters-depth-4-face :foreground yellow)
   (rainbow-delimiters-depth-5-face :foreground magenta)
   (rainbow-delimiters-depth-6-face :foreground violet)
   (rainbow-delimiters-depth-7-face :foreground teal)
   (rainbow-delimiters-depth-8-face :foreground orange)
   (rainbow-delimiters-depth-9-face :foreground dark-cyan)
   (rainbow-delimiters-unmatched-face :foreground red :weight 'bold :inverse-video t)

   ;;;; magit
   (magit-section-heading :foreground blue :weight 'bold)
   (magit-section-highlight :background base1 :extend t)
   (magit-branch-local :foreground cyan)
   (magit-branch-remote :foreground green)
   (magit-diff-hunk-heading :background base2 :foreground fg-alt)
   (magit-diff-hunk-heading-highlight :background base3 :foreground fg :weight 'bold)

   ;;;; treemacs / dashboard / which-key
   (treemacs-root-face :foreground cyan :weight 'bold :height 1.15)
   (treemacs-directory-face :foreground blue)
   (doom-themes-treemacs-root-face :foreground cyan :weight 'bold :height 1.15)
   (doom-dashboard-banner :foreground cyan)
   (doom-dashboard-menu-title :foreground blue)
   (doom-dashboard-menu-desc :foreground fg)
   (doom-dashboard-footer-icon :foreground cyan)
   (doom-dashboard-loaded :foreground fg-alt)
   (which-key-key-face :foreground cyan :weight 'bold)
   (which-key-group-description-face :foreground blue)
   (which-key-command-description-face :foreground fg)

   ;;;; lsp
   (lsp-face-highlight-textual :background glass :foreground base8 :weight 'bold)
   (lsp-face-highlight-read :background glass :foreground base8 :weight 'bold)
   (lsp-face-highlight-write :background (doom-blend green bg 0.2) :foreground base8 :weight 'bold)
   (lsp-ui-doc-background :background pool))

  ;;;; Variable overrides
  ())

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

;;; frutiger-aero-v2-theme.el ends here
