;;; config/packages/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Package Configuration

;; LSP configuration (consolidated from multiple blocks)
(after! lsp-mode
  ;; Performance: Balance responsiveness with resource usage
  (setq lsp-idle-delay 0.5)                    ; Start LSP after 0.5s of idle time
  (setq lsp-enable-file-watchers t)            ; Enable file watching for auto-updates
  (setq lsp-log-io nil)                        ; Keep logging disabled for performance

  ;; UI Features: Enable all features for full functionality
  (setq lsp-ui-doc-enable t)                   ; Enable popup documentation
  (setq lsp-ui-doc-delay 0.5)                  ; Show docs after 0.5s hover
  (setq lsp-ui-doc-show-with-cursor t)         ; Show docs on cursor hover
  (setq lsp-ui-doc-position 'at-point)         ; Show docs at point

  (setq lsp-ui-sideline-enable t)              ; Enable sideline information
  (setq lsp-ui-sideline-show-hover t)          ; Show hover messages in sideline
  (setq lsp-ui-sideline-show-diagnostics t)    ; Show diagnostics in sideline
  (setq lsp-ui-sideline-delay 0.5)             ; Update sideline after 0.5s

  (setq lsp-lens-enable t)                     ; Enable code lens
  (setq lsp-modeline-code-actions-enable t)    ; Enable modeline code actions
  (setq lsp-modeline-diagnostics-enable t)     ; Show diagnostics in modeline
  (setq lsp-signature-auto-activate t)         ; Auto-show function signatures
  (setq lsp-signature-render-documentation t)  ; Include documentation in signatures

  ;; LSP headerline breadcrumb navigation
  (setq lsp-headerline-breadcrumb-enable t)
  (lsp-headerline-breadcrumb-mode 1)

  ;; Ensure electric-indent works in LSP buffers
  (add-hook 'lsp-mode-hook #'electric-indent-local-mode)

  ;; TypeScript/JavaScript server preferences
  (setq lsp-disabled-clients '(jsts-ls))
  (setq lsp-clients-typescript-prefer-use-project-ts-server nil)

  ;; Language ID configuration for multiple languages
  ;; TypeScript/JavaScript
  (add-to-list 'lsp-language-id-configuration '(typescript-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(typescript-ts-mode . "typescript"))
  (add-to-list 'lsp-language-id-configuration '(tsx-ts-mode . "typescriptreact"))
  (add-to-list 'lsp-language-id-configuration '(js2-mode . "javascript"))
  (add-to-list 'lsp-language-id-configuration '(rjsx-mode . "javascriptreact"))

  ;; Python
  (add-to-list 'lsp-language-id-configuration '(python-mode . "python"))
  (add-to-list 'lsp-language-id-configuration '(python-ts-mode . "python"))

  ;; Rust
  (add-to-list 'lsp-language-id-configuration '(rust-mode . "rust"))
  (add-to-list 'lsp-language-id-configuration '(rust-ts-mode . "rust"))

  ;; Go
  (add-to-list 'lsp-language-id-configuration '(go-mode . "go"))
  (add-to-list 'lsp-language-id-configuration '(go-ts-mode . "go"))

  ;; C/C++
  (add-to-list 'lsp-language-id-configuration '(c-mode . "c"))
  (add-to-list 'lsp-language-id-configuration '(c++-mode . "cpp"))
  (add-to-list 'lsp-language-id-configuration '(c-ts-mode . "c"))
  (add-to-list 'lsp-language-id-configuration '(c++-ts-mode . "cpp"))

  ;; Java
  (add-to-list 'lsp-language-id-configuration '(java-mode . "java"))
  (add-to-list 'lsp-language-id-configuration '(java-ts-mode . "java")))

;; PERFORMANCE: Use standard LSP deferred loading
;; This ensures LSP starts properly and updates automatically on code changes
;; The lsp-deferred function already handles optimal startup timing
(after! lsp-mode
  ;; Auto-refresh configuration for real-time updates
  (setq lsp-auto-configure t)                  ; Auto-configure LSP features
  (setq lsp-response-timeout 10)               ; Increase timeout for slower servers
  (setq lsp-completion-provider :capf)         ; Use completion-at-point

  ;; File watcher optimization
  (setq lsp-file-watch-threshold 5000)         ; Watch up to 5000 files
  (setq lsp-enable-on-type-formatting nil)     ; Disable format-on-type for better perf

  ;; Ensure LSP updates on buffer changes
  (setq lsp-enable-snippet t)                  ; Enable snippet support
  (setq lsp-keep-workspace-alive nil))         ; Kill workspace when last buffer closes

;; Standard deferred loading - works properly with auto-updates
(after! typescript-mode
  ;; Use standard lsp-deferred for proper auto-update behavior
  (add-hook 'typescript-mode-hook #'lsp-deferred)
  (add-hook 'typescript-tsx-mode-hook #'lsp-deferred))

(after! python-mode
  (add-hook 'python-mode-hook #'lsp-deferred))

(after! rust-mode
  (add-hook 'rust-mode-hook #'lsp-deferred))

;; LSP-Treemacs integration
(use-package! lsp-treemacs
  :after lsp-mode
  :config
  (map! :map lsp-mode-map
        :localleader
        :desc "lsp-treemacs-errors-list" "ge" #'lsp-treemacs-errors-list))

;; Note: Standalone map!/after! blocks moved to config/keybindings/lsp.el
