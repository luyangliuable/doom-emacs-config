;;; frutiger-aero-v2-light-theme.el --- Frutiger Aero v2: sky & glass -*- lexical-binding: t; no-byte-compile: t; -*-

;; Version: 2.1.0
;; Package-Requires: ((emacs "29.1") (doom-themes "2.2"))
;; Keywords: faces, theme, frutiger, aero, light

;;; Commentary:
;;
;; "Sky & glass": the daytime half of Frutiger Aero v2.
;;
;; - Canvas: a clear pale sky (#E9F5FC) instead of paper white.
;; - Glass: the current line, popups, code blocks and the header-line are
;;   bright frosted-glass panes floating above the sky.
;; - Aqua: a light sky-glass mode-line with a white gloss across the top
;;   and a deeper shadow beneath, finished with a grass-green "orb" bar.
;; - Explorer: completion selections use Vista's pale-aqua highlight with a
;;   thin flat blue outline.
;; - Frutiger: humanist sans headings, shared with `frutiger-aero-v2'
;;   (see `frutiger-aero-v2-humanist-font').

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

(def-doom-theme frutiger-aero-v2-light
  "Light Frutiger Aero v2: pale sky, frosted glass panes and glossy Aqua chrome."
  :family 'frutiger-aero
  :background-mode 'light

  ;; name        default   256       16
  ((bg         '("#E9F5FC" "#eaf5ff" "white"        ))
   (fg         '("#0F2D40" "#0f2d40" "black"        ))

   (bg-alt     '("#DDEFFA" "#ddeffa" "white"        ))
   (fg-alt     '("#4E7489" "#4e7489" "brightblack"  ))

   ;; frosted glass -> deep ocean
   (base0      '("#FFFFFF" "#ffffff" "white"        ))
   (base1      '("#FAFDFF" "#fafdff" "brightwhite"  ))
   (base2      '("#D6EBF8" "#d6ebf8" "brightwhite"  ))
   (base3      '("#BFDDF1" "#bfddf1" "brightblack"  ))
   (base4      '("#94BCD6" "#94bcd6" "brightblack"  ))
   (base5      '("#6C93AC" "#6c93ac" "brightblack"  ))
   (base6      '("#47697F" "#47697f" "brightblack"  ))
   (base7      '("#2A4A5E" "#2a4a5e" "brightblack"  ))
   (base8      '("#0B2333" "#0b2333" "black"        ))

   (grey       base4)
   (red        '("#C02A37" "#c02a37" "red"          ))
   (orange     '("#AD4F00" "#ad4f00" "brightred"    ))
   (green      '("#2C7A10" "#2c7a10" "green"        )) ; grass
   (teal       '("#00735F" "#00735f" "brightgreen"  ))
   (yellow     '("#7F5C00" "#7f5c00" "yellow"       )) ; sun
   (blue       '("#0A5FC2" "#0a5fc2" "brightblue"   )) ; Aero blue
   (dark-blue  '("#8CC4F0" "#8cc4f0" "blue"         ))
   (magenta    '("#A1307F" "#a1307f" "magenta"      )) ; orchid
   (violet     '("#5A45C0" "#5a45c0" "brightmagenta"))
   (cyan       '("#00748F" "#00748f" "brightcyan"   )) ; ocean aqua
   (dark-cyan  '("#005F78" "#005f78" "cyan"         ))

   ;; universal syntax classes
   (highlight      blue)
   (vertical-bar   base3)
   (selection      '("#CBE8FD" "#cbe8fd" "brightwhite"))
   (builtin        dark-cyan)
   (comments       '("#4B7186" "#4b7186" "brightblack"))
   (doc-comments   '("#2F7656" "#2f7656" "green"))
   (constants      violet)
   (functions      blue)
   (keywords       cyan)
   (methods        blue)
   (operators      '("#0D4C99" "#0d4c99" "blue"))
   (type           teal)
   (strings        green)
   (variables      '("#1C4A66" "#1c4a66" "black"))
   (numbers        orange)
   (region         '("#BFE3F8" "#bfe3f8" "brightwhite"))
   (error          red)
   (warning        orange)
   (success        green)
   (vc-modified    blue)
   (vc-added       green)
   (vc-deleted     red)

   ;; glass, Aqua chrome & grass
   (glass          base1)
   (selection-rim  '("#84C5F2" "#84c5f2" "brightblue"))
   (grass-orb      '("#7AD13A" "#7ad13a" "brightgreen"))
   (deep-grass     '("#256A0C" "#256a0c" "green"))
   (modeline-fg          '("#0B3D6E" "#0b3d6e" "blue"))
   (modeline-fg-alt      '("#3E6378" "#3e6378" "brightblack"))
   (modeline-bg          '("#B4DCF7" "#b4dcf7" "brightblue"))
   (modeline-pill        '("#1565B0" "#1565b0" "blue"))
   (modeline-bg-inactive '("#D3E8F5" "#d3e8f5" "white"))
   (modeline-gloss       '("#FFFFFF" "#ffffff" "brightwhite"))
   (modeline-shadow      '("#6AAEE0" "#6aaee0" "brightblue"))
   (modeline-hover       '("#8CC8F0" "#8cc8f0" "brightblue"))
   (chrome-ice     '("#0A55A8" "#0a55a8" "blue"))
   (chrome-lime    '("#225C0A" "#225c0a" "green"))
   (chrome-sun     '("#7A4100" "#7a4100" "yellow"))
   (chrome-blossom '("#A0185A" "#a0185a" "magenta"))
   (chrome-lilac   '("#5B2FB0" "#5b2fb0" "magenta")))

  ;;;; Face overrides
  (((font-lock-comment-face &override) :slant 'italic)
   ((font-lock-doc-face &override) :slant 'italic)
   ((font-lock-keyword-face &override) :weight 'semi-bold)
   ((font-lock-function-name-face &override) :weight 'semi-bold)
   ((font-lock-constant-face &override) :weight 'semi-bold)

   (cursor :background blue)
   ;; the current line is a pane of glass catching the light
   (hl-line :background glass :extend t)
   ((line-number &override) :foreground base5)
   ((line-number-current-line &override) :foreground blue :background glass :weight 'bold)
   (fringe :background bg :foreground base4)
   (vertical-border :foreground base3 :background base3)
   ;; bevelled glass edges when window dividers are wider than 2px
   (window-divider :foreground base3)
   (window-divider-first-pixel :foreground base0)
   (window-divider-last-pixel :foreground base4)
   (child-frame-border :background selection-rim)
   (internal-border :background bg-alt)

   (show-paren-match :background selection :foreground blue :weight 'bold)
   (show-paren-mismatch :background red :foreground base0 :weight 'bold)
   (secondary-selection :background base2 :extend t)
   (lazy-highlight :background (doom-blend blue base0 0.2) :foreground base8 :distant-foreground base0)
   (isearch :background "#FFE27A" :foreground base8 :weight 'bold)
   (isearch-fail :background (doom-blend red base0 0.2) :foreground base8)
   (link :foreground blue :underline t)
   (link-visited :foreground violet :underline t)
   (minibuffer-prompt :foreground blue :weight 'bold)
   (tooltip :background base0 :foreground fg)
   (widget-field :background base0 :foreground fg)
   (nav-flash-face :background selection :foreground base8 :weight 'bold :extend t)
   (pulse-highlight-start-face :background selection)
   (pulse-highlight-face :background selection :extend t)

   ;;;; light sky-glass mode-line: white gloss on top, aqua shadow beneath
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :overline modeline-gloss :underline `(:color ,modeline-shadow :position t)
    :box (list :line-width (quote (1 . 5)) :color modeline-bg))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :overline base0 :box (list :line-width (quote (1 . 5)) :color modeline-bg-inactive))
   (mode-line-emphasis :foreground chrome-ice :weight 'bold)
   (mode-line-buffer-id :foreground modeline-fg :weight 'bold)
   (mode-line-highlight :background modeline-hover :foreground modeline-fg)
   (header-line
    :background base0 :foreground fg
    :overline selection-rim :box (list :line-width (quote (1 . 4)) :color base0))
   (tab-bar :background bg-alt :foreground fg-alt)
   (tab-bar-tab
    :background modeline-bg :foreground modeline-fg :weight 'bold
    :overline modeline-gloss :box (list :line-width (quote (6 . 4)) :color modeline-bg))
   (tab-bar-tab-inactive
    :background bg-alt :foreground fg-alt
    :box (list :line-width (quote (6 . 4)) :color bg-alt))
   (tab-line :background bg-alt :foreground fg-alt)
   (tab-line-tab-current :background base0 :foreground fg :overline selection-rim)
   (tab-line-tab-inactive :background bg-alt :foreground fg-alt)

   ;;;; doom-modeline -- a grass-green orb on sky glass
   (doom-modeline-bar :background grass-orb)
   (doom-modeline-bar-inactive :background base3)
   (doom-modeline-buffer-file :foreground modeline-fg :weight 'bold)
   (doom-modeline-buffer-path :foreground chrome-ice)
   (doom-modeline-project-dir :foreground chrome-lime :weight 'bold)
   (doom-modeline-buffer-modified :foreground chrome-sun :weight 'bold)
   (doom-modeline-buffer-major-mode :foreground modeline-fg :weight 'bold)
   (doom-modeline-info :foreground chrome-lime)
   (doom-modeline-warning :foreground chrome-sun)
   (doom-modeline-urgent :foreground chrome-blossom)
   (doom-modeline-panel :background modeline-pill :foreground base0 :weight 'bold)
   (doom-modeline-evil-normal-state :foreground chrome-ice)
   (doom-modeline-evil-insert-state :foreground chrome-lime)
   (doom-modeline-evil-visual-state :foreground chrome-lilac)
   (doom-modeline-evil-emacs-state :foreground chrome-blossom)
   (doom-modeline-evil-replace-state :foreground chrome-sun)
   (doom-modeline-evil-operator-state :foreground chrome-ice)

   ;;;; solaire-mode -- sidebars are a slightly deeper sky
   (solaire-default-face :inherit 'default :background bg-alt)
   (solaire-hl-line-face :background glass :extend t)
   (solaire-mode-line-face :inherit 'mode-line :background modeline-bg)
   (solaire-mode-line-inactive-face :inherit 'mode-line-inactive :background modeline-bg-inactive)

   ;;;; completion -- frosted panes with Vista Explorer selections
   (vertico-current
    :background selection :foreground base8 :weight 'bold :extend t
    :box (list :line-width (quote (1 . -1)) :color selection-rim))
   (vertico-posframe-border :background selection-rim)
   (corfu-default :background base0 :foreground fg)
   (corfu-current
    :background selection :foreground base8 :weight 'bold
    :box (list :line-width (quote (1 . -1)) :color selection-rim))
   (corfu-border :background selection-rim)
   (corfu-bar :background blue)
   (company-tooltip :background base0 :foreground fg)
   (company-tooltip-selection :background selection :foreground base8 :weight 'bold)
   (company-tooltip-common :foreground blue :weight 'bold)
   (company-tooltip-annotation :foreground fg-alt)
   (company-scrollbar-bg :background base2)
   (company-scrollbar-fg :background blue)
   (orderless-match-face-0 :foreground blue :weight 'bold)
   (orderless-match-face-1 :foreground deep-grass :weight 'bold)
   (orderless-match-face-2 :foreground magenta :weight 'bold)
   (orderless-match-face-3 :foreground violet :weight 'bold)

   ;;;; org / outline -- sky to grass ramp, humanist headings
   ((outline-1 &override) :foreground blue)
   ((outline-2 &override) :foreground cyan)
   ((outline-3 &override) :foreground green)
   ((outline-4 &override) :foreground teal)
   ((outline-5 &override) :foreground violet)
   ((outline-6 &override) :foreground orange)
   ((outline-7 &override) :foreground magenta)
   ((outline-8 &override) :foreground yellow)
   (org-document-title
    :foreground blue :weight 'bold :height 1.6
    :family (frutiger-aero-v2--humanist-family))
   (org-document-info :foreground cyan :family (frutiger-aero-v2--humanist-family))
   (org-document-info-keyword :foreground comments)
   (org-level-1
    :inherit 'outline-1 :height 1.35 :overline selection-rim
    :family (frutiger-aero-v2--humanist-family))
   (org-level-2 :inherit 'outline-2 :height 1.2 :family (frutiger-aero-v2--humanist-family))
   (org-level-3 :inherit 'outline-3 :height 1.1 :family (frutiger-aero-v2--humanist-family))
   (org-level-4 :inherit 'outline-4 :family (frutiger-aero-v2--humanist-family))
   (org-level-5 :inherit 'outline-5 :family (frutiger-aero-v2--humanist-family))
   (org-level-6 :inherit 'outline-6 :family (frutiger-aero-v2--humanist-family))
   (org-level-7 :inherit 'outline-7 :family (frutiger-aero-v2--humanist-family))
   (org-level-8 :inherit 'outline-8 :family (frutiger-aero-v2--humanist-family))
   ((org-block &override) :background base0 :extend t)
   ((org-block-begin-line &override) :background base2 :foreground dark-cyan :extend t)
   ((org-block-end-line &override) :background base2 :foreground dark-cyan :extend t)
   ((org-quote &override) :background base0 :slant 'italic)
   (org-code :foreground orange :background base0)
   (org-verbatim :foreground green)
   (org-todo :foreground deep-grass :background (doom-blend green base0 0.12) :weight 'bold)
   (org-done :foreground base5 :weight 'bold)
   (org-headline-done :foreground base5)
   (org-tag :foreground fg-alt :weight 'normal)
   (org-date :foreground violet)
   (org-checkbox :foreground blue :background 'unspecified :weight 'bold)
   (org-ellipsis :underline nil :foreground blue)

   ;;;; markdown
   (markdown-header-face :inherit 'bold :foreground blue)
   (markdown-header-face-1
    :inherit 'outline-1 :height 1.35 :family (frutiger-aero-v2--humanist-family))
   (markdown-header-face-2
    :inherit 'outline-2 :height 1.2 :family (frutiger-aero-v2--humanist-family))
   (markdown-header-face-3
    :inherit 'outline-3 :height 1.1 :family (frutiger-aero-v2--humanist-family))
   (markdown-markup-face :foreground base5)
   ((markdown-code-face &override) :background base0 :extend t)

   ;;;; rainbow-delimiters -- water spectrum
   (rainbow-delimiters-depth-1-face :foreground blue)
   (rainbow-delimiters-depth-2-face :foreground cyan)
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
   (magit-section-highlight :background glass :extend t)
   (magit-branch-local :foreground cyan)
   (magit-branch-remote :foreground green)
   (magit-diff-hunk-heading :background base2 :foreground base6)
   (magit-diff-hunk-heading-highlight :background base3 :foreground base8 :weight 'bold)
   (magit-diff-removed :foreground (doom-darken red 0.2) :background (doom-blend red base0 0.1))
   (magit-diff-removed-highlight :foreground red :background (doom-blend red base0 0.2) :weight 'bold)

   ;;;; ediff
   (ediff-current-diff-A :foreground red   :background (doom-lighten red 0.85))
   (ediff-current-diff-B :foreground green :background (doom-lighten green 0.85))
   (ediff-current-diff-C :foreground blue  :background (doom-lighten blue 0.85))

   ;;;; treemacs / dashboard / which-key
   (treemacs-root-face :foreground blue :weight 'bold :height 1.15)
   (treemacs-directory-face :foreground cyan)
   (doom-themes-treemacs-root-face :foreground blue :weight 'bold :height 1.15)
   (doom-dashboard-banner :foreground blue)
   (doom-dashboard-menu-title :foreground cyan)
   (doom-dashboard-menu-desc :foreground fg)
   (doom-dashboard-footer-icon :foreground green)
   (doom-dashboard-loaded :foreground fg-alt)
   (which-key-key-face :foreground blue :weight 'bold)
   (which-key-group-description-face :foreground cyan)
   (which-key-command-description-face :foreground fg)

   ;;;; lsp
   (lsp-face-highlight-textual :background selection :foreground base8 :weight 'bold)
   (lsp-face-highlight-read :background selection :foreground base8 :weight 'bold)
   (lsp-face-highlight-write :background (doom-blend green base0 0.15) :foreground base8 :weight 'bold)
   (lsp-ui-doc-background :background base0)

   ;;;; web-mode / whitespace
   (web-mode-current-element-highlight-face :background dark-blue :foreground base8)
   ((whitespace-tab &override) :background (if (not (default-value 'indent-tabs-mode)) base1 'unspecified))
   ((whitespace-indentation &override) :background (if (default-value 'indent-tabs-mode) base1 'unspecified)))

  ;;;; Variable overrides
  ())

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

;;; frutiger-aero-v2-light-theme.el ends here
