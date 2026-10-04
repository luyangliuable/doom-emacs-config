;;; frutiger-aero-light-theme.el --- Frutiger Aero, sky & grass -*- lexical-binding: t; no-byte-compile: t; -*-

;; Version: 3.0.0
;; Package-Requires: ((emacs "27.1") (doom-themes "2.2"))
;; Keywords: faces, theme, frutiger, aero, light

;;; Commentary:
;;
;; A light Frutiger Aero theme (mid-2000s Vista/Win7 Aero, Wii, Web 2.0 gloss):
;; pale sky-white canvas, Aero blue, ocean aqua and leaf green, with a glossy
;; sky-blue mode-line. Built on `def-doom-theme' so the palette covers every
;; doom-themes package face. See `frutiger-aero' for the night variant.

;;; Code:

(require 'doom-themes)

(defgroup frutiger-aero-light-theme nil
  "Options for the `frutiger-aero-light' theme."
  :group 'doom-themes)

(def-doom-theme frutiger-aero-light
  "Light Frutiger Aero: pale sky, Aero blue, ocean aqua and leaf green."
  :family 'frutiger-aero
  :background-mode 'light

  ;; name        default   256       16
  ((bg         '("#F3F9FD" "#f5faff" "white"        ))
   (fg         '("#13303F" "#13303f" "black"        ))

   (bg-alt     '("#E7F2FA" "#e7f2fa" "white"        ))
   (fg-alt     '("#8BA6B6" "#8ba6b6" "brightblack"  ))

   ;; cloud white -> deep ocean
   (base0      '("#FFFFFF" "#ffffff" "white"        ))
   (base1      '("#EAF4FB" "#eaf4fb" "brightwhite"  ))
   (base2      '("#DCEBF5" "#dcebf5" "brightwhite"  ))
   (base3      '("#C5DCEC" "#c5dcec" "brightblack"  ))
   (base4      '("#9CBACE" "#9cbace" "brightblack"  ))
   (base5      '("#6F8FA3" "#6f8fa3" "brightblack"  ))
   (base6      '("#4A6B7F" "#4a6b7f" "brightblack"  ))
   (base7      '("#2C4A5C" "#2c4a5c" "brightblack"  ))
   (base8      '("#0E2533" "#0e2533" "black"        ))

   (grey       base4)
   (red        '("#C42F3A" "#c42f3a" "red"          ))
   (orange     '("#B35500" "#b35500" "brightred"    ))
   (green      '("#2F7F16" "#2f7f16" "green"        )) ; leaf
   (teal       '("#00796B" "#00796b" "brightgreen"  ))
   (yellow     '("#8A6300" "#8a6300" "yellow"       )) ; sun
   (blue       '("#1763C4" "#1763c4" "brightblue"   )) ; Aero blue
   (dark-blue  '("#8FC1EE" "#8fc1ee" "blue"         ))
   (magenta    '("#A8388F" "#a8388f" "magenta"      )) ; orchid
   (violet     '("#5E4CC0" "#5e4cc0" "brightmagenta"))
   (cyan       '("#00789A" "#00789a" "brightcyan"   )) ; ocean aqua
   (dark-cyan  '("#00627C" "#00627c" "cyan"         ))

   ;; universal syntax classes
   (highlight      blue)
   (vertical-bar   base3)
   (selection      dark-blue)
   (builtin        dark-cyan)
   (comments       '("#5F8296" "#5f8296" "brightblack"))
   (doc-comments   '("#3C7F5E" "#3c7f5e" "green"))
   (constants      violet)
   (functions      blue)
   (keywords       cyan)
   (methods        blue)
   (operators      '("#0F4FA8" "#0f4fa8" "blue"))
   (type           teal)
   (strings        green)
   (variables      '("#1F4E6B" "#1f4e6b" "black"))
   (numbers        orange)
   (region         '("#CBE6F7" "#cbe6f7" "brightwhite"))
   (error          red)
   (warning        orange)
   (success        green)
   (vc-modified    blue)
   (vc-added       green)
   (vc-deleted     red)

   ;; theme-local
   (glass          (doom-blend cyan bg 0.14))
   (modeline-fg          base8)
   (modeline-fg-alt      '("#557A8E" "#557a8e" "brightblack"))
   (modeline-bg          '("#BFDDF5" "#bfddf5" "brightwhite"))
   (modeline-bg-inactive '("#E2EEF7" "#e2eef7" "white"))
   (modeline-gloss       base0))

  ;;;; Face overrides
  (((font-lock-comment-face &override) :slant 'italic)
   ((font-lock-doc-face &override) :slant 'italic)
   ((font-lock-keyword-face &override) :weight 'semi-bold)
   ((font-lock-function-name-face &override) :weight 'semi-bold)
   (cursor :background blue)
   (hl-line :background bg-alt)
   ((line-number &override) :foreground "#7F9DB0")
   ((line-number-current-line &override) :foreground blue :background bg-alt :weight 'bold)
   (fringe :background bg :foreground base4)
   (show-paren-match :background glass :foreground blue :weight 'bold)
   (secondary-selection :background glass :extend t)
   (lazy-highlight :background (doom-blend blue bg 0.2) :foreground base8 :distant-foreground base0)
   (isearch :background "#FFE58A" :foreground base8 :weight 'bold)
   (link :foreground blue :underline t)
   (minibuffer-prompt :foreground blue :weight 'bold)
   (tooltip :background base0 :foreground fg)

   ;; glossy sky-blue mode-line with a white highlight on top
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :overline modeline-gloss :underline `(:color ,(doom-darken modeline-bg 0.15) :position t)
    :box `(:line-width 3 :color ,modeline-bg))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :overline base0 :box `(:line-width 3 :color ,modeline-bg-inactive))
   (mode-line-emphasis :foreground blue)
   (mode-line-buffer-id :foreground blue :weight 'bold)
   (header-line :background base1 :foreground fg :overline base0)

   ;;;; doom-modeline
   (doom-modeline-bar :background blue)
   (doom-modeline-bar-inactive :background base3)
   (doom-modeline-buffer-file :foreground base8 :weight 'bold)
   (doom-modeline-buffer-path :foreground blue)
   (doom-modeline-project-dir :foreground green :weight 'bold)
   (doom-modeline-buffer-modified :foreground orange :weight 'bold)
   (doom-modeline-buffer-major-mode :foreground blue :weight 'bold)
   (doom-modeline-evil-normal-state :foreground blue)
   (doom-modeline-evil-insert-state :foreground green)
   (doom-modeline-evil-visual-state :foreground violet)
   ;;;; solaire-mode
   (solaire-mode-line-face :inherit 'mode-line :background modeline-bg)
   (solaire-mode-line-inactive-face :inherit 'mode-line-inactive :background modeline-bg-inactive)
   (solaire-hl-line-face :background base2)

   ;;;; completion
   (vertico-current :background region :foreground base8 :weight 'bold :extend t)
   (corfu-default :background base0 :foreground fg)
   (corfu-current :background region :foreground base8 :weight 'bold)
   (corfu-border :background base3)
   (company-tooltip :background base0 :foreground fg)
   (company-tooltip-selection :background region :foreground base8 :weight 'bold)
   (orderless-match-face-0 :foreground blue :weight 'bold)
   (orderless-match-face-1 :foreground green :weight 'bold)
   (orderless-match-face-2 :foreground cyan :weight 'bold)
   (orderless-match-face-3 :foreground magenta :weight 'bold)

   ;;;; org / outline -- sky to grass ramp
   ((outline-1 &override) :foreground blue)
   ((outline-2 &override) :foreground cyan)
   ((outline-3 &override) :foreground green)
   ((outline-4 &override) :foreground teal)
   ((outline-5 &override) :foreground violet)
   ((outline-6 &override) :foreground orange)
   ((outline-7 &override) :foreground magenta)
   ((outline-8 &override) :foreground yellow)
   ((org-block &override) :background base1)
   ((org-block-begin-line &override) :background base1 :foreground comments)
   ((org-quote &override) :background base1)
   (org-ellipsis :underline nil :foreground blue)
   ;;;; markdown
   (markdown-header-face :inherit 'bold :foreground blue)
   (markdown-markup-face :foreground base5)
   ((markdown-code-face &override) :background base1)

   ;;;; magit
   (magit-section-heading :foreground blue :weight 'bold)
   (magit-branch-local :foreground cyan)
   (magit-branch-remote :foreground green)
   (magit-diff-hunk-heading :background base2 :foreground base6)
   (magit-diff-hunk-heading-highlight :background base3 :foreground base8 :weight 'bold)
   (magit-diff-removed :foreground (doom-darken red 0.2) :background (doom-blend red bg 0.1))
   (magit-diff-removed-highlight :foreground red :background (doom-blend red bg 0.2) :weight 'bold)

   ;;;; ediff
   (ediff-current-diff-A :foreground red   :background (doom-lighten red 0.85))
   (ediff-current-diff-B :foreground green :background (doom-lighten green 0.85))
   (ediff-current-diff-C :foreground blue  :background (doom-lighten blue 0.85))

   ;;;; treemacs
   (treemacs-root-face :foreground blue :weight 'bold :height 1.15)
   (treemacs-directory-face :foreground cyan)
   (doom-themes-treemacs-root-face :foreground blue :weight 'bold :height 1.15)

   ;;;; which-key
   (which-key-key-face :foreground blue :weight 'bold)
   (which-key-group-description-face :foreground cyan)
   (which-key-command-description-face :foreground fg)

   ;;;; lsp
   (lsp-face-highlight-textual :background glass :foreground base8 :weight 'bold)
   (lsp-face-highlight-read :background glass :foreground base8 :weight 'bold)
   (lsp-face-highlight-write :background (doom-blend green bg 0.15) :foreground base8 :weight 'bold)
   (lsp-ui-doc-background :background base0)

   ;;;; web-mode
   (web-mode-current-element-highlight-face :background dark-blue :foreground base8)
   ;;;; whitespace
   ((whitespace-tab &override) :background (if (not (default-value 'indent-tabs-mode)) base1 'unspecified))
   ((whitespace-indentation &override) :background (if (default-value 'indent-tabs-mode) base1 'unspecified)))

  ;;;; Variable overrides
  ())

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

;;; frutiger-aero-light-theme.el ends here
