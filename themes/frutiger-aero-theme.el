;;; frutiger-aero-theme.el --- Frutiger Aero, deep ocean / aurora night -*- lexical-binding: t; no-byte-compile: t; -*-

;; Version: 3.0.0
;; Package-Requires: ((emacs "27.1") (doom-themes "2.2"))
;; Keywords: faces, theme, frutiger, aero, dark

;;; Commentary:
;;
;; A dark Frutiger Aero theme (mid-2000s Vista/Win7 Aero, Wii, Web 2.0 gloss):
;; "technology in harmony with nature" seen at night -- deep ocean water,
;; aqua glass, sky blue, grass green and soft aurora tones, never harsh neon.
;; Built on `def-doom-theme' so the palette covers every doom-themes package face.
;; See `frutiger-aero-light' for the daytime "sky & grass" variant.

;;; Code:

(require 'doom-themes)

(defgroup frutiger-aero-theme nil
  "Options for the `frutiger-aero' theme."
  :group 'doom-themes)

(def-doom-theme frutiger-aero
  "Dark Frutiger Aero: deep ocean water, aqua glass, sky blue and grass green."
  :family 'frutiger-aero
  :background-mode 'dark

  ;; name        default   256       16
  ((bg         '("#0A1A24" "#081c26" "black"        ))
   (fg         '("#D8ECF4" "#dfefff" "brightwhite"  ))

   (bg-alt     '("#07141C" "#06121a" "black"        ))
   (fg-alt     '("#6E8E9E" "#6e8e9e" "white"        ))

   ;; deep water -> ice
   (base0      '("#050F15" "#050f15" "black"        ))
   (base1      '("#0D2130" "#0d2130" "brightblack"  ))
   (base2      '("#112939" "#112939" "brightblack"  ))
   (base3      '("#173345" "#173345" "brightblack"  ))
   (base4      '("#24485E" "#24485e" "brightblack"  ))
   (base5      '("#3E6378" "#3e6378" "brightblack"  ))
   (base6      '("#5D8396" "#5d8396" "brightblack"  ))
   (base7      '("#8EAFBF" "#8eafbf" "brightblack"  ))
   (base8      '("#E4F3F9" "#e4f3f9" "white"        ))

   (grey       base5)
   (red        '("#FF6B7A" "#ff6b7a" "red"          ))
   (orange     '("#FFA857" "#ffa857" "brightred"    ))
   (green      '("#8CD656" "#8cd656" "green"        )) ; grass
   (teal       '("#3CCFB0" "#3ccfb0" "brightgreen"  ))
   (yellow     '("#F5D76E" "#f5d76e" "yellow"       )) ; sun
   (blue       '("#5CB8FF" "#5cb8ff" "brightblue"   )) ; sky
   (dark-blue  '("#2F7AD0" "#2f7ad0" "blue"         ))
   (magenta    '("#F08BD8" "#f08bd8" "magenta"      )) ; orchid
   (violet     '("#A99BFF" "#a99bff" "brightmagenta")) ; aurora
   (cyan       '("#4FE0E8" "#4fe0e8" "brightcyan"   )) ; aqua
   (dark-cyan  '("#2BB0C0" "#2bb0c0" "cyan"         ))

   ;; universal syntax classes
   (highlight      cyan)
   (vertical-bar   base3)
   (selection      dark-blue)
   (builtin        dark-cyan)
   (comments       '("#6A93A8" "#6a93a8" "brightblack"))
   (doc-comments   '("#7FC8A6" "#7fc8a6" "green"))
   (constants      yellow)
   (functions      blue)
   (keywords       cyan)
   (methods        blue)
   (operators      '("#9FD8E8" "#9fd8e8" "cyan"))
   (type           teal)
   (strings        green)
   (variables      '("#B9DDF0" "#b9ddf0" "white"))
   (numbers        orange)
   (region         '("#1A3A50" "#1a3a50" "brightblack"))
   (error          red)
   (warning        orange)
   (success        green)
   (vc-modified    blue)
   (vc-added       green)
   (vc-deleted     red)

   ;; theme-local
   (glass          (doom-blend cyan bg 0.16))
   (modeline-fg          fg)
   (modeline-fg-alt      fg-alt)
   (modeline-bg          '("#10293A" "#10293a" "brightblack"))
   (modeline-bg-inactive bg-alt)
   (modeline-gloss       (doom-blend cyan modeline-bg 0.45)))

  ;;;; Face overrides
  (((font-lock-comment-face &override) :slant 'italic)
   ((font-lock-doc-face &override) :slant 'italic)
   ((font-lock-keyword-face &override) :weight 'semi-bold)
   ((font-lock-function-name-face &override) :weight 'semi-bold)
   (cursor :background cyan)
   (hl-line :background base1)
   ((line-number &override) :foreground "#4E7488")
   ((line-number-current-line &override) :foreground cyan :background base1 :weight 'bold)
   (fringe :background bg :foreground base5)
   (show-paren-match :background glass :foreground cyan :weight 'bold)
   (secondary-selection :background glass :extend t)
   (lazy-highlight :background (doom-blend blue bg 0.3) :foreground base8 :distant-foreground base0)
   (isearch :background yellow :foreground bg :weight 'bold)
   (link :foreground blue :underline t)
   (minibuffer-prompt :foreground cyan :weight 'bold)
   (tooltip :background base2 :foreground fg)

   ;; glossy glass mode-line with an aqua top edge
   (mode-line
    :background modeline-bg :foreground modeline-fg
    :overline modeline-gloss :box `(:line-width 3 :color ,modeline-bg))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :overline base3 :box `(:line-width 3 :color ,modeline-bg-inactive))
   (mode-line-emphasis :foreground cyan)
   (mode-line-buffer-id :foreground cyan :weight 'bold)
   (header-line :background base1 :foreground fg :overline modeline-gloss)

   ;;;; doom-modeline
   (doom-modeline-bar :background cyan)
   (doom-modeline-bar-inactive :background base3)
   (doom-modeline-buffer-file :foreground fg :weight 'bold)
   (doom-modeline-buffer-path :foreground blue)
   (doom-modeline-project-dir :foreground green :weight 'bold)
   (doom-modeline-buffer-modified :foreground orange :weight 'bold)
   (doom-modeline-buffer-major-mode :foreground cyan :weight 'bold)
   (doom-modeline-evil-normal-state :foreground cyan)
   (doom-modeline-evil-insert-state :foreground green)
   (doom-modeline-evil-visual-state :foreground violet)
   ;;;; solaire-mode
   (solaire-mode-line-face :inherit 'mode-line :background modeline-bg)
   (solaire-mode-line-inactive-face :inherit 'mode-line-inactive :background modeline-bg-inactive)
   (solaire-hl-line-face :background base1)

   ;;;; completion
   (vertico-current :background glass :foreground base8 :weight 'bold :extend t)
   (corfu-default :background base1 :foreground fg)
   (corfu-current :background glass :foreground base8 :weight 'bold)
   (corfu-border :background base4)
   (company-tooltip :background base1 :foreground fg)
   (company-tooltip-selection :background glass :foreground base8 :weight 'bold)
   (orderless-match-face-0 :foreground cyan :weight 'bold)
   (orderless-match-face-1 :foreground green :weight 'bold)
   (orderless-match-face-2 :foreground blue :weight 'bold)
   (orderless-match-face-3 :foreground yellow :weight 'bold)

   ;;;; org / outline -- sky to aurora ramp
   ((outline-1 &override) :foreground cyan)
   ((outline-2 &override) :foreground blue)
   ((outline-3 &override) :foreground green)
   ((outline-4 &override) :foreground teal)
   ((outline-5 &override) :foreground violet)
   ((outline-6 &override) :foreground yellow)
   ((outline-7 &override) :foreground magenta)
   ((outline-8 &override) :foreground orange)
   ((org-block &override) :background base1)
   ((org-block-begin-line &override) :background base1 :foreground comments)
   ((org-quote &override) :background base1)
   (org-ellipsis :underline nil :foreground cyan)
   ;;;; markdown
   (markdown-header-face :inherit 'bold :foreground cyan)
   ((markdown-code-face &override) :background base1)

   ;;;; magit
   (magit-section-heading :foreground blue :weight 'bold)
   (magit-branch-local :foreground cyan)
   (magit-branch-remote :foreground green)
   (magit-diff-hunk-heading :background base2 :foreground fg-alt)
   (magit-diff-hunk-heading-highlight :background base3 :foreground fg :weight 'bold)

   ;;;; treemacs
   (treemacs-root-face :foreground cyan :weight 'bold :height 1.15)
   (treemacs-directory-face :foreground blue)
   (doom-themes-treemacs-root-face :foreground cyan :weight 'bold :height 1.15)

   ;;;; which-key
   (which-key-key-face :foreground cyan :weight 'bold)
   (which-key-group-description-face :foreground blue)
   (which-key-command-description-face :foreground fg)

   ;;;; lsp
   (lsp-face-highlight-textual :background glass :foreground base8 :weight 'bold)
   (lsp-face-highlight-read :background glass :foreground base8 :weight 'bold)
   (lsp-face-highlight-write :background (doom-blend green bg 0.2) :foreground base8 :weight 'bold)
   (lsp-ui-doc-background :background base1))

  ;;;; Variable overrides
  ())

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

;;; frutiger-aero-theme.el ends here
