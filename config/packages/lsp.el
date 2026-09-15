;;; config/packages/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Package Configuration - Optimized for Performance

;;; ============================================================================
;;; SECTION 1: EMACS-LSP-BOOSTER SETUP
;;; ============================================================================

;; Configure emacs-lsp-booster if available. The booster wraps the language
;; server process and streams pre-parsed Emacs bytecode instead of raw JSON,
;; giving ~4x faster deserialization. This is the single biggest win for large
;; payload servers like vtsls (completions, semantic tokens, diagnostics),
;; where unbuffered JSON parsing on the main thread causes typing stutter.
;; Requires `lsp-use-plists' (set in early-init.el) and a `doom build' so the
;; lsp packages are byte-compiled with plist support.
(when (executable-find "emacs-lsp-booster")
  (message "✓ emacs-lsp-booster detected - enabling 4x faster JSON parsing")

  ;; Advice to parse bytecode from booster
  (defun lsp-booster--advice-json-parse (old-fn &rest args)
    "Try to parse bytecode instead of json."
    (or
     (when (equal (following-char) ?#)
       (let ((bytecode (read (current-buffer))))
         (when (byte-code-function-p bytecode)
           (funcall bytecode))))
     (apply old-fn args)))

  (advice-add (if (progn (require 'json)
                         (fboundp 'json-parse-buffer))
                  'json-parse-buffer
                'json-read)
              :around #'lsp-booster--advice-json-parse)

  ;; Advice to wrap LSP server commands with booster (FIXED VERSION)
  (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
    "Prepend emacs-lsp-booster command to lsp CMD."
    (let ((orig-result (funcall old-fn cmd test?)))
      (if (and (not test?)                             ;; Don't wrap during server detection!
               (not (file-remote-p default-directory)) ;; Don't wrap remote servers
               lsp-use-plists                          ;; Only if using plists
               (not (functionp 'json-rpc-connection))  ;; Not native json-rpc
               (executable-find "emacs-lsp-booster"))
          (progn
            ;; Resolve command from exec-path (in case not found in $PATH)
            (when-let ((command-from-exec-path (executable-find (car orig-result))))
              (setcar orig-result command-from-exec-path))
            (message "Using emacs-lsp-booster for %s!" orig-result)
            (cons "emacs-lsp-booster" orig-result))  ;; Use cons, not concat!
        orig-result)))

  (advice-add 'lsp-resolve-final-command
              :around #'lsp-booster--advice-final-command))

;;; ============================================================================
;;; SECTION 2: CORE LSP SETTINGS (PRESERVED FROM ORIGINAL)
;;; ============================================================================

;; LSP configuration (consolidated from multiple blocks)
(after! lsp-mode
  ;; Performance: Balance responsiveness with resource usage
  (setq lsp-idle-delay 0.8)                    ; Start LSP after 0.8s of idle time
  (setq lsp-enable-file-watchers t)            ; Enable file watching for auto-updates
  (setq lsp-log-io nil)                        ; Keep logging disabled for performance

  ;; UI Features: Enable all features for full functionality.
  ;;
  ;; PERF NOTE (Phase 2 - intentionally left ENABLED per user request):
  ;; The following features add per-keystroke / per-cursor-move cost in TSX
  ;; because each one issues extra requests to vtsls or re-renders on change.
  ;; If typing still lags after enabling emacs-lsp-booster, these are the next
  ;; knobs to turn off (set to nil):
  ;;   - lsp-ui-doc-show-with-cursor : fires a `textDocument/hover' request every
  ;;     time the cursor idles on a symbol, then renders a child-frame popup.
  ;;   - lsp-ui-sideline-show-hover  : issues hover requests on cursor movement
  ;;     and repaints the sideline overlay to the right of the current line.
  ;;   - lsp-ui-sideline-show-diagnostics : recomputes/repaints diagnostic text
  ;;     in the sideline as diagnostics arrive and the cursor moves.
  ;;   - lsp-lens-enable : requests code lenses (reference/impl counts) and
  ;;     recomputes them on buffer changes; expensive for TypeScript.
  ;;   - lsp-modeline-code-actions-enable : requests available code actions on
  ;;     cursor move to display the lightbulb/action count in the modeline.
  (setq lsp-ui-doc-enable t)                   ; Enable popup documentation
  (setq lsp-ui-doc-delay 0.5)                  ; Show docs after 0.5s hover
  (setq lsp-ui-doc-show-with-cursor t)         ; Show docs on cursor hover (hover req per idle)
  (setq lsp-ui-doc-position 'at-point)         ; Show docs at point

  (setq lsp-ui-sideline-enable t)              ; Enable sideline information
  (setq lsp-ui-sideline-show-hover t)          ; Show hover messages in sideline (hover req on move)
  (setq lsp-ui-sideline-show-diagnostics t)    ; Show diagnostics in sideline (repaint on move)
  (setq lsp-ui-sideline-delay 0.5)             ; Update sideline after 0.5s

  (setq lsp-lens-enable t)                     ; Enable code lens (recomputed on change)
  (setq lsp-modeline-code-actions-enable t)    ; Enable modeline code actions (req on cursor move)
  (setq lsp-modeline-diagnostics-enable t)     ; Show diagnostics in modeline
  (setq lsp-signature-auto-activate t)         ; Auto-show function signatures
  (setq lsp-signature-render-documentation t)  ; Include documentation in signatures

  ;; LSP enables this buffer-local mode through `lsp-configure-hook`.
  (setq lsp-headerline-breadcrumb-enable t)

  ;; Ensure electric-indent works in LSP buffers
  (add-hook 'lsp-mode-hook #'electric-indent-local-mode)

  ;; TypeScript/JavaScript server preferences
  (setq lsp-disabled-clients '(jsts-ls ts-ls))  ; Disable jsts-ls and ts-ls, use vtsls
  (setq lsp-clients-typescript-prefer-use-project-ts-server nil)

  ;; Language ID configuration for multiple languages
  (dolist (mapping '((typescript-mode . "typescript")
                     (typescript-ts-mode . "typescript")
                     (tsx-ts-mode . "typescriptreact")
                     (js2-mode . "javascript")
                     (rjsx-mode . "javascriptreact")
                     (python-mode . "python")
                     (python-ts-mode . "python")
                     (rust-mode . "rust")
                     (rust-ts-mode . "rust")
                     (go-mode . "go")
                     (go-ts-mode . "go")
                     (c-mode . "c")
                     (c++-mode . "cpp")
                     (c-ts-mode . "c")
                     (c++-ts-mode . "cpp")
                     (java-mode . "java")
                     (java-ts-mode . "java")))
    (add-to-list 'lsp-language-id-configuration mapping)))

;; PERFORMANCE: Standard LSP deferred loading with auto-updates
(after! lsp-mode
  ;; Auto-refresh configuration for real-time updates
  (setq lsp-auto-configure t)                  ; Auto-configure LSP features
  (setq lsp-response-timeout 10)               ; Increase timeout for slower servers
  (setq lsp-completion-provider :capf)         ; Use completion-at-point

  ;; File watcher optimization
  (setq lsp-file-watch-threshold 2000)         ; Watch up to 2000 files
  (setq lsp-enable-on-type-formatting nil)     ; Disable format-on-type for better perf

  ;; Ensure LSP updates on buffer changes
  (setq lsp-enable-snippet t)                  ; Enable snippet support
  (setq lsp-keep-workspace-alive nil))         ; Kill workspace when last buffer closes

;;; ============================================================================
;;; SECTION 3: SMART LOADING HELPERS (Simple Edge-Case Handling)
;;; ============================================================================

(defun my/lsp-should-start-p ()
  "Simple predicate to skip LSP for edge cases only.
Skips LSP for:
- Binary files (already handled by modes.el fundamental-mode check)
- Remote files (TRAMP - slow over network)
- Tiny files (<10 bytes - empty or nearly empty)

Otherwise LSP starts normally (preserves current behavior)."
  (and buffer-file-name                        ; Must have a file
       (not (file-remote-p default-directory)) ; Not remote (TRAMP)
       (> (buffer-size) 10)))                  ; Not empty/tiny file

(defun my/lsp-deferred-smart ()
  "Smart LSP loader - same as lsp-deferred but skips edge cases.
Current behavior preserved: LSP starts for all normal files."
  (when (my/lsp-should-start-p)
    (lsp-deferred)))

;;; ============================================================================
;;; SECTION 4: FILE WATCH IGNORE PATTERNS (Comprehensive)
;;; ============================================================================

(defun my/setup-lsp-file-watch-ignored ()
  "Setup comprehensive file watch ignore patterns.
Ignores common directories that shouldn't trigger LSP file watching."
  (setq lsp-file-watch-ignored-directories
        '(;; Version control
          "[/\\\\]\\.git$"
          "[/\\\\]\\.svn$"
          "[/\\\\]\\.hg$"
          "[/\\\\]\\.bzr$"

          ;; JavaScript/TypeScript
          "[/\\\\]node_modules$"
          "[/\\\\]bower_components$"
          "[/\\\\]\\.npm$"
          "[/\\\\]\\.yarn$"
          "[/\\\\]\\.pnpm-store$"

          ;; Python
          "[/\\\\]\\.venv$"
          "[/\\\\]venv$"
          "[/\\\\]__pycache__$"
          "[/\\\\]\\.pytest_cache$"
          "[/\\\\]\\.mypy_cache$"
          "[/\\\\]\\.tox$"
          "[/\\\\]eggs$"
          "[/\\\\]\\.eggs$"
          "[/\\\\]\\.egg-info$"

          ;; Rust
          "[/\\\\]target$"
          "[/\\\\]Cargo\\.lock$"

          ;; Go
          "[/\\\\]vendor$"
          "[/\\\\]pkg$"

          ;; Java/Gradle/Maven
          "[/\\\\]build$"
          "[/\\\\]target$"
          "[/\\\\]\\.gradle$"
          "[/\\\\]\\.m2$"

          ;; Common build outputs
          "[/\\\\]dist$"
          "[/\\\\]out$"
          "[/\\\\]bin$"
          "[/\\\\]obj$"
          "[/\\\\]\\.cache$"
          "[/\\\\]\\.temp$"
          "[/\\\\]tmp$"
          "[/\\\\]\\.next$"
          "[/\\\\]\\.nuxt$"

          ;; IDE/Editors
          "[/\\\\]\\.idea$"
          "[/\\\\]\\.vscode$"
          "[/\\\\]\\.vs$"
          "[/\\\\]\\.settings$"
          "[/\\\\]\\.eclipse$"

          ;; OS
          "[/\\\\]\\.DS_Store$"
          "[/\\\\]Thumbs\\.db$")))

(defun my/gitignore-to-regex (pattern)
  "Convert gitignore PATTERN to regex for lsp-file-watch-ignored-directories."
  (let ((regex (string-trim-right pattern "/")))
    ;; Escape regex special chars (except *)
    (setq regex (replace-regexp-in-string "[.+^${}()|\\[\\]\\\\]" "\\\\\\&" regex))
    ;; Convert * to .*
    (setq regex (replace-regexp-in-string "\\*" ".*" regex))
    ;; Add anchors
    (format "[/\\\\]%s$" regex)))

(defun my/add-gitignore-to-lsp-watch-ignore ()
  "Parse .gitignore and add patterns to lsp-file-watch-ignored-directories.
Runs immediately during startup to ensure patterns are ready."
  (when (and (fboundp 'projectile-project-root)
             (projectile-project-p))
    (let* ((project-root (projectile-project-root))
           (gitignore-file (expand-file-name ".gitignore" project-root)))
      (when (file-readable-p gitignore-file)
        (ignore-errors
          (with-temp-buffer
            (insert-file-contents gitignore-file)
            (let ((patterns '()))
              (while (not (eobp))
                (let ((line (string-trim (buffer-substring-no-properties
                                          (line-beginning-position)
                                          (line-end-position)))))
                  ;; Skip comments and empty lines
                  (unless (or (string-empty-p line)
                              (string-prefix-p "#" line))
                    ;; Convert gitignore pattern to regex
                    (let ((regex-pattern (my/gitignore-to-regex line)))
                      (push regex-pattern patterns))))
                (forward-line 1))

              ;; Add to lsp-file-watch-ignored-directories
              (when patterns
                (setq lsp-file-watch-ignored-directories
                      (append lsp-file-watch-ignored-directories (nreverse patterns)))
                (message "✓ LSP: Added %d patterns from .gitignore" (length patterns))))))))))

;; Setup file watch ignores immediately after lsp-mode loads
(after! lsp-mode
  (my/setup-lsp-file-watch-ignored)
  ;; Parse .gitignore immediately (adds ~50-100ms, but ensures patterns ready)
  (my/add-gitignore-to-lsp-watch-ignore))

;;; ============================================================================
;;; SECTION 5: LANGUAGE-SPECIFIC HOOKS (Refactored - Symmetric Pattern)
;;; ============================================================================

;; All languages use the same smart loading pattern

(after! typescript-mode
  (add-hook 'typescript-mode-hook #'my/lsp-deferred-smart)
  (add-hook 'typescript-tsx-mode-hook #'my/lsp-deferred-smart))

(after! python-mode
  (add-hook 'python-mode-hook #'my/lsp-deferred-smart))

(after! rust-mode
  (add-hook 'rust-mode-hook #'my/lsp-deferred-smart))

;; Add more languages here following the same pattern:
;; (after! go-mode
;;   (add-hook 'go-mode-hook #'my/lsp-deferred-smart))

;;; ============================================================================
;;; SECTION 6: LSP INTEGRATIONS (PRESERVED FROM ORIGINAL)
;;; ============================================================================

;; LSP-Treemacs integration
(use-package! lsp-treemacs
  :after lsp-mode
  :config
  (map! :map lsp-mode-map
        :localleader
        :desc "lsp-treemacs-errors-list" "ge" #'lsp-treemacs-errors-list))

;; Note: Standalone map!/after! blocks moved to config/keybindings/lsp.el
