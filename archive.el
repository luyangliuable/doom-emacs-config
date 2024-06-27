;; Archived config file codes

(use-package lsp-mode
  ;; add this to defer loading of lsp until lsp or lsp-deferred is called
  :commands (lsp lsp-deferred))

(use-package typescript-mode
  :after lsp-mode
  :mode ("\.ts$")
  :hook (typescript-mode . lsp-deferred))

;; Svelte configuration
(after! lsp-mode
  (add-to-list 'lsp-language-id-configuration '(svelte-mode . "svelte"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection "svelteserver")
                    :activation-fn (lsp-activate-on "svelte")
                    :server-id 'svelte-ls)))
