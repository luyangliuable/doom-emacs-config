;;; config/packages/gptel/core.el -*- lexical-binding: t; -*-

;; Note: Global keybindings live in config/keybindings/gptel.el

;; Load shared/provider definitions first.
(load! "auth")
(load! "github-copilot")
(load! "anthropic")
(load! "openai")
(load! "portkey")

(defun gptel-rewrite-safe ()
  "Safely rewrite selection with error handling."
  (interactive)
  (if (use-region-p)
      (condition-case err
          (gptel-rewrite)
        (error
         (message
          "gptel-rewrite failed: %s. Try selecting text first."
          (error-message-string err))))
    (message "Please select text to rewrite first.")))


(use-package! gptel
  :defer t
  :config
  (require 'gptel-gh)
  (require 'gptel-anthropic)
  (require 'gptel-openai)

  ;; Preserve existing behavior: remove gptel's stock Anthropic backend.
  (setq gptel--known-backends
        (assoc-delete-all "Anthropic" gptel--known-backends))

  ;; Preserve existing default-backend initialization.
  (let* ((copilot-auth
          (luyangliuable/gptel-read-pi-copilot-auth
           luyangliuable/gptel-pi-auth-file
           luyangliuable/gptel-copilot-default-model))
         (copilot
          (gptel-make-gh-copilot
           "GitHub Copilot"
           :stream nil
           :models (plist-get copilot-auth :models))))

    (luyangliuable/gptel-cache-pi-copilot-auth copilot-auth)

    ;; Preserve Portkey's exact conditional registration behavior.
    (when (and
           (not (string-empty-p
                 (or (getenv "PORTKEY_API_KEY") "")))
           (or
            (not (string-empty-p
                  (or (getenv "ANTHROPIC_BASE_URL") "")))
            (not (string-empty-p
                  (or (getenv "OPENAI_BASE_URL") "")))))
      (luyangliuable/gptel-register-portkey-backends
       (luyangliuable/gptel-portkey-models)))

    ;; Preserve existing defaults exactly.
    (setq gptel-stream nil
          gptel-backend copilot
          gptel-model luyangliuable/gptel-copilot-default-model))

  (setq gptel-default-mode 'markdown-mode)

  ;; Keep your existing rewrite advice here unchanged.
  ;; Keep your existing :localleader map here unchanged.
  ;; Keep your existing direct gptel-mode map here unchanged.
  )
