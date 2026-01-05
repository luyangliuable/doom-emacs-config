;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-
;; Personal Doom Emacs Configuration
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;;; ============================================================================
;;; SECTION 1: FILE HEADER & IMPORTS
;;; ============================================================================

;; Load custom functions and themes
(load! "elisp-functions/functions")
(load! "themes")

;;; ============================================================================
;;; SECTION 2: CORE SETTINGS
;;; ============================================================================

;; Theme and appearance
(setq doom-theme 'doom-nord)

;; Font configuration
(setq doom-font (font-spec :family "Fira Code" :size 13 :weight 'semi-light))

;; Display settings
(setq display-line-numbers-type 'relative)
(setq blink-cursor-mode t)
(scroll-bar-mode -1)
(evil-goggles-mode t)

;; Window management - maximize on startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Focus Emacs window on startup (bring to front)
(when (display-graphic-p)
  (add-hook 'after-init-hook
    (lambda ()
      (when (eq system-type 'darwin) ; macOS
        (call-process "osascript" nil nil nil
          "-e" "tell application \"Emacs\" to activate")))))

;; Local leader key configuration
(setq doom-localleader-key ",")
(setq doom-localleader-alt-key "M-,")

;;; ============================================================================
;;; SECTION 3: UI CONFIGURATION
;;; ============================================================================

;; Doom modeline customization
(use-package! doom-modeline
  :ensure t
  :init
  (setq doom-modeline-hud t) ;; Enable the HUD feature

  ;; Modeline appearance settings
  (setq doom-modeline-height 28
        doom-modeline-icon t
        doom-modeline-buffer-encoding t
        doom-modeline-project-detection 'projectile
        doom-modeline-buffer-file-name-style nil ;; Disable file path in modeline
        doom-modeline-minor-modes nil
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode t
        doom-modeline-linenumber t
        doom-modeline-bar-width 6)

  :config
  (doom-modeline-mode 1))

;; Beacon - highlight cursor position on big movements
(use-package! beacon
  :ensure t
  :init
  ;; Beacon appearance settings
  (setq beacon-blink-duration 0.8       ;; Duration of the blink
        beacon-blink-delay 0.3          ;; Delay before the blink starts
        beacon-size 40                  ;; Size of the beacon
        beacon-color "#ff9d00"          ;; Color of the beacon
        beacon-push-mark 35             ;; Number of moves before pushing a new mark onto the ring
        beacon-dont-blink-commands '() ;; Commands that won't trigger a blink
        beacon-blink-when-buffer-changes t  ;; Blink when switching buffers
        beacon-blink-when-window-changes t  ;; Blink when switching windows
        beacon-blink-when-point-moves t     ;; Blink when point moves
        beacon-blink-when-window-scrolls t  ;; Blink when window scrolls
        beacon-blink-when-focused t)        ;; Blink when the frame gains focus
  :config
  (beacon-mode 1))

;; Minimap configuration
(use-package! minimap
  :ensure t
  :init
  (setq minimap-window-location 'right) ;; Position minimap on the right
  :config)

;; Good scroll - smooth scrolling
(use-package good-scroll
  :ensure t
  :config
  ;; Smooth scrolling settings
  (setq good-scroll-duration 0.1) ;; Set a faster duration for scrolling
  (setq good-scroll-amount 3)     ;; Set the amount of lines to scroll at a time
  (setq good-scroll-algorithm #'good-scroll-linear) ;; Use a linear scrolling algorithm

  ;; Disabled due to poor performance
  (good-scroll-mode 1))

;; Global breadcrumb navigation for all files (non-LSP files)
(defun my/set-header-line-breadcrumb ()
  "Set header line breadcrumb for file buffers only."
  (when (and buffer-file-name
             (file-exists-p buffer-file-name)
             (not (string-match-p "^\\*" (buffer-name)))
             (not (string-match-p "^magit" (buffer-name)))
             (not (derived-mode-p 'special-mode))
             (not (derived-mode-p 'help-mode))
             (not (derived-mode-p 'compilation-mode)))
    (let ((project-root (and (featurep 'projectile) (projectile-project-root)))
          (file-path (file-name-directory buffer-file-name))
          (file-name (file-name-nondirectory buffer-file-name)))
      (setq header-line-format
        (concat
          (propertize " " 'display '(space :align-to 0))
          (when project-root
            (propertize (file-name-nondirectory (directory-file-name project-root))
                        'face 'font-lock-string-face))
          (when project-root " > ")
          (propertize (if project-root
                          (file-relative-name file-path project-root)
                        (abbreviate-file-name file-path))
                      'face 'font-lock-comment-face)
          (propertize file-name 'face 'mode-line-buffer-id))))))

;; Apply breadcrumb to file buffers
(add-hook 'find-file-hook #'my/set-header-line-breadcrumb)
(add-hook 'after-change-major-mode-hook #'my/set-header-line-breadcrumb)

;;; ============================================================================
;;; SECTION 4: KEYBINDINGS
;;; ============================================================================

;; Unmap conflicting keybindings
(map!
 :leader "tm" nil
 :leader "*" nil
 :leader "x" nil
 :leader ";" nil
 :leader "fy" nil
 :leader "tl" nil)

;; Visual mode text wrapping keybindings
(map!
 :v "s`" (lambda () (interactive) (luyangliuable/wrap-with-char ?`))
 :v "s\"" (lambda () (interactive) (luyangliuable/wrap-with-char ?\"))
 :v "s'" (lambda () (interactive) (luyangliuable/wrap-with-char ?'))
 :v "s(" (lambda () (interactive) (luyangliuable/wrap-with-char ?\())
 :v "s[" (lambda () (interactive) (luyangliuable/wrap-with-char ?\[))
 :v "s{" (lambda () (interactive) (luyangliuable/wrap-with-char ?{))
 :v "s*" (lambda () (interactive) (luyangliuable/wrap-with-char ?*)))

;; Good scroll keybindings
(map!
 :n "C-u" #'good-scroll-down
 :n "C-d" #'good-scroll-up
 :n "C-b" #'good-scroll-up-full-screen
 :n "C-f" #'good-scroll-down-full-screen)

;; File operations
(map!
 :n "c-u" (lambda () (interactive) (revert-buffer nil t)))

(map! :map emacs-lisp-mode-map
        :localleader
        :desc "flycheck-errors-list" "ge" #'flycheck-list-errors)

;; Main keybinding block - organized by category
(map!
 ;; Global keybindings (non-leader)
 :n "C-c a" #'org-agenda
 :n "C-c c" #'org-capture

 :n "RET" (lambda () (interactive) (delete-trailing-whitespace) (save-buffer)) ;; RET remove trailing whitespace and save file

 ;; Leader keybindings organized by prefix
 :leader
 ;; Buffer operations
 :desc "Switch to last buffer" "TAB" #'luyangliuable/switch-to-last-buffer
 :desc "Go to scratch buffer" "bs" #'luyangliuable/goto-scratch-buffer
 :desc "Copy entire buffer to clipboard" "bY" #'luyangliuable/copy-whole-buffer-to-clipboard

 ;; Window management
 :desc "Split window right and open shell" "p$" (lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'shell))
 :desc "Split window bottom and open shell" "p|" (lambda () (interactive) (luyangliuable/split-window-below-and-run-callback #'shell))
 :desc "Maximize buffer" "wm" #'luyangliuable/toggle-maximize-buffer
 :desc "Ace window" "wW" #'ace-window
 :desc "Window management transient state" "w." #'hydra-window-management/body

 ;; File operations
 :desc "treemacs" "ft" #'treemacs
 :desc "yank file directory" "fyd" #'luyangliuable/copy-directory-path
 :desc "yank file name" "fyn" #'luyangliuable/copy-file-name
 :desc "yank file file path" "fyy" #'luyangliuable/copy-file-path
 :desc "yank file file path with line number" "fyl" #'luyangliuable/copy-file-path-with-line

 ;; Git operations
 :desc "browse-at-remote" "xb" #'browse-at-remote
 :desc "magit" "gs" (lambda () (interactive) (luyangliuable/split-window-right-and-run-callback #'magit))

 ;; Jump operations
 :desc "avy goto char" "jw" #'avy-goto-char
 :desc "goto last change" "jc" #'goto-last-change

 ;; Toggle operations
 :desc "absolute lineno toggle" "tna" #'luyangliuable/toggle-absolute-line-numbers
 :desc "relative lineno toggle" "tnr" #'luyangliuable/toggle-relative-line-numbers
 :desc "toggle mode line" "tmT" #'luyangliuable/toggle-mode-line
 :desc "toggle minimap" "tmM" #'minimap-mode

 ;; Text operations
 :desc "drag stuff down" "xJ" #'luyangliuable/drag-stuff-down-repeatable
 :desc "drag stuff up" "xK" #'luyangliuable/drag-stuff-up-repeatable
 :desc "delete trailing whitespace" "xdw" #'delete-trailing-whitespace
 :desc "link-hint-copy-link-at-point" "xo" #'link-hint-open-link-at-point

 ;; Project operations
 :desc "projectile find file based on string" "*s" #'helm-projectile-grep
 :desc "projectile find file based on string" "*f" #'helm-projectile-find-file

 ;; Help operations
 :desc "describe key" "hdk" #'describe-key

 ;; Misc operations
 :desc "M-x" "SPC" #'execute-extended-command
 :desc "evilnc comment operator" ";" #'evilnc-comment-operator)

;;; ============================================================================
;;; SECTION 5: PACKAGE CONFIGURATIONS
;;; ============================================================================

;; EditorConfig - respect project .editorconfig files
(use-package! editorconfig
  :config
  (editorconfig-mode 1)
  ;; Ensure EditorConfig takes precedence over mode defaults
  (setq editorconfig-get-properties-function
        'editorconfig-get-properties)
  ;; Apply to all relevant file types
  (add-hook 'prog-mode-hook (lambda () (editorconfig-apply)))
  (add-hook 'text-mode-hook (lambda () (editorconfig-apply))))

;; LSP configuration (consolidated from multiple blocks)
(after! lsp-mode
  ;; LSP headerline breadcrumb navigation
  (setq lsp-headerline-breadcrumb-enable t)
  (lsp-headerline-breadcrumb-mode 1)

  ;; TypeScript/JavaScript server preferences
  (setq lsp-disabled-clients '(jsts-ls))
  (setq lsp-clients-typescript-prefer-use-project-ts-server nil)

  ;; Language ID configuration for TypeScript files
  (add-to-list 'lsp-language-id-configuration '(typescript-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(typescript-ts-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(tsx-ts-mode . "typescriptreact"))

  ;; LSP keybindings
  (map! :map lsp-mode-map
        :localleader
        :desc "Describe" "hh" #'lsp-describe-thing-at-point
        :desc "Find implementation" "gi" #'lsp-find-implementation
        :desc "Find references" "gr" #'lsp-find-references
        :desc "Jump to definition" "gg" #'lsp-find-definition))

;; LSP-Treemacs integration
(use-package! lsp-treemacs
  :after lsp-mode
  :config
  (map! :map lsp-mode-map
        :localleader
        :desc "lsp-treemacs-errors-list" "ge" #'lsp-treemacs-errors-list))

;; Projectile configuration
(after! projectile
  ;; Add directories to ignore list
  (add-to-list 'projectile-globally-ignored-directories ".git")
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  ;; Add file suffixes to ignore
  (add-to-list 'projectile-globally-ignored-file-suffixes ".git"))

;; Agent shell configuration
(use-package agent-shell
    :ensure t
    :ensure-system-package
    ;; Add agent installation configs here
    ((claude-code-acp . "npm install -g @zed-industries/claude-code-acp")))

(setq agent-shell-anthropic-claude-environment
      (agent-shell-make-environment-variables
       "ANTHROPIC_BASE_URL" "https://api.studio.genai.cba"
       "ANTHROPIC_API_KEY" (auth-source-pass-get "secret" "(or (getenv "OPENAI_API_KEY") "")")
       "ANTHROPIC_MODEL" "aipe-bedrock-claude-4-sonnet"
       "ANTHROPIC_SMALL_FAST_MODEL" "aipe-bedrock-claude-4-sonnet"))

;; Explicitly set the default model for agent shell to override any defaults
(setq agent-shell-anthropic-default-model-id "aipe-bedrock-claude-4-sonnet")

;;; ============================================================================
;;; SECTION 6: MODE HOOKS & CUSTOM FUNCTIONS
;;; ============================================================================

;; Web mode configuration
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

(add-hook 'web-mode-hook 'my-web-mode-hook)

;;; ============================================================================
;;; SECTION 7: EVIL MODE FIXES
;;; ============================================================================

;; Fix for c$ and cw commands in evil mode
;; evil-collection sometimes disables these commands in certain contexts
;; This restores the proper bindings
(after! evil
  ;; Ensure change commands are properly bound in normal state
  (define-key evil-normal-state-map "c" #'evil-change)
  (define-key evil-normal-state-map "C" #'evil-change-line)

  ;; Additional fix: ensure the change operator can accept motions
  (evil-define-key 'normal 'global "c" #'evil-change)
  (evil-define-key 'normal 'global "C" #'evil-change-line)

  ;; Make sure motion state has the necessary motions
  (define-key evil-motion-state-map "$" #'evil-end-of-line)
  (define-key evil-motion-state-map "w" #'evil-forward-word-begin))

;;; ============================================================================
;;; END OF CONFIGURATION
;;; ============================================================================
