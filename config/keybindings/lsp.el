;;; config/keybindings/lsp.el -*- lexical-binding: t; -*-
;; LSP Mode Keybindings

(defconst luyangliuable/lsp-localleader-prefixes
  '(("=" . "format")
    ("a" . "code actions")
    ("g" . "goto")
    ("h" . "help")
    ("r" . "refactor")
    ("b" . "backend")
    ("F" . "folder"))
  "Which-key labels for LSP local-leader prefix maps.")

(defconst luyangliuable/lsp-treemacs-localleader-prefixes
  '(("t" . "treemacs")
    ("t a" . "actions")
    ("t m" . "modes"))
  "Which-key labels for LSP Treemacs local-leader prefix maps.")

(defun luyangliuable/lsp-label-localleader-prefixes (map prefix prefixes)
  "Set LSP local-leader PREFIXES in MAP below PREFIX."
  (dolist (entry prefixes)
    (let* ((key (concat prefix " " (car entry)))
           (binding (lookup-key map (kbd key))))
      (unless (and (consp binding)
                   (stringp (car binding))
                   (equal (car binding) (cdr entry)))
        (which-key-add-keymap-based-replacements map key (cdr entry))))))

(defun luyangliuable/lsp-apply-localleader-prefix-labels (prefixes)
  "Set LSP local-leader PREFIXES in every supported Evil state."
  (dolist (state-and-prefix
           `((normal . ,doom-localleader-key)
             (visual . ,doom-localleader-key)
             (motion . ,doom-localleader-key)
             (emacs . ,doom-localleader-alt-key)
             (insert . ,doom-localleader-alt-key)))
    (let ((map (evil-get-auxiliary-keymap lsp-mode-map
                                           (car state-and-prefix))))
      (when map
        (luyangliuable/lsp-label-localleader-prefixes
         map (cdr state-and-prefix) prefixes)))))

(defun luyangliuable/lsp-keymap-has-bindings-p (map bindings)
  "Return non-nil when MAP contains every key-command pair in BINDINGS."
  (catch 'missing-binding
    (dolist (binding bindings)
      (unless (eq (lookup-key map (kbd (car binding))) (cdr binding))
        (throw 'missing-binding nil)))
    t))

(defun luyangliuable/lsp-clear-relocated-treemacs-bindings ()
  "Remove the temporary relocated Treemacs bindings from a config reload."
  (dolist (state-and-prefix
           `((normal . ,doom-localleader-key)
             (visual . ,doom-localleader-key)
             (motion . ,doom-localleader-key)
             (emacs . ,doom-localleader-alt-key)
             (insert . ,doom-localleader-alt-key)))
    (let ((map (evil-get-auxiliary-keymap lsp-mode-map
                                           (car state-and-prefix)))
          (prefix (cdr state-and-prefix)))
      (when map
        (dolist (binding '(("d" . lsp-treemacs-deps-list-mode)
                           ("g" . lsp-treemacs-generic-mode)))
          (let ((key (concat prefix " t " (car binding))))
            (when (eq (lookup-key map (kbd key)) (cdr binding))
              (define-key map (kbd key) nil))))
        (let ((key (concat prefix " T")))
          (when (and (keymapp (lookup-key map (kbd key)))
                     (luyangliuable/lsp-keymap-has-bindings-p
                      map
                      (mapcar
                       (lambda (binding)
                         (cons (concat prefix " T " (car binding))
                               (cdr binding)))
                       '(("e" . lsp-treemacs-errors-list)
                         ("s" . lsp-treemacs-symbols)
                         ("r" . lsp-treemacs-references)
                         ("i" . lsp-treemacs-implementations)
                         ("c" . lsp-treemacs-call-hierarchy)
                         ("h" . lsp-treemacs-type-hierarchy)
                         ("a g" . lsp-treemacs-go-to)
                         ("a s" . lsp-treemacs-goto-symbol)
                         ("a S" . lsp-treemacs-symbols-goto-symbol)
                         ("a q" . lsp-treemacs-quick-fix)
                         ("a v" . lsp-treemacs-cycle-severity)
                         ("a RET" . lsp-treemacs-perform-ret-action)))))
            (define-key map (kbd key) nil)))))))

(after! lsp-mode
  (map! :map lsp-mode-map
        :localleader

        (:prefix "="
         :desc "Format buffer" "b" #'lsp-format-buffer
         :desc "Format region" "r" #'lsp-format-region
         :desc "Organize imports" "o" #'lsp-organize-imports)

        (:prefix "a"
         :desc "Execute code action" "a" #'lsp-execute-code-action)

        (:prefix "g"
         :desc "Jump to definition" "g" #'lsp-find-definition
         :desc "Find implementation" "i" #'lsp-find-implementation
         :desc "Find references" "r" #'lsp-find-references
         :desc "Find type definition" "t" #'lsp-find-type-definition)

        (:prefix "h"
         :desc "Describe thing at point" "h" #'lsp-describe-thing-at-point)

        (:prefix "r"
         :desc "Rename" "r" #'lsp-rename)

        (:prefix "b"
         :desc "Describe session" "d" #'lsp-describe-session
         :desc "Restart workspace" "r" #'lsp-workspace-restart
         :desc "Shutdown workspace" "s" #'lsp-workspace-shutdown
         :desc "LSP version" "v" #'lsp-version)

        (:prefix "F"
         :desc "Add folder" "a" #'lsp-workspace-folders-add
         :desc "Remove folder" "r" #'lsp-workspace-folders-remove
         :desc "Switch folder" "s" #'lsp-workspace-folders-switch))

  ;; `map!' scopes descriptions for lsp-mode-map to a major mode named
  ;; lsp-mode. Label the active Evil auxiliary maps instead.
  (after! which-key
    (luyangliuable/lsp-apply-localleader-prefix-labels
     luyangliuable/lsp-localleader-prefixes)))

(after! lsp-treemacs
  (luyangliuable/lsp-clear-relocated-treemacs-bindings)

  (defun luyangliuable/lsp-treemacs-toggle-view (buffer-name command &rest args)
    "Toggle BUFFER-NAME, invoking COMMAND without selecting its window."
    (if-let ((window (get-buffer-window buffer-name (selected-frame))))
        (save-selected-window
          (quit-window nil window))
      (save-selected-window
        (apply command args))))

  (defun luyangliuable/lsp-treemacs-toggle-sidebar ()
    "Toggle the Treemacs sidebar without selecting it."
    (interactive)
    (save-selected-window
      (treemacs)))

  (defun luyangliuable/lsp-treemacs-toggle-errors-list ()
    "Toggle the LSP error list without selecting it."
    (interactive)
    (luyangliuable/lsp-treemacs-toggle-view
     lsp-treemacs-errors-buffer-name
     #'lsp-treemacs-errors-list))

  (defun luyangliuable/lsp-treemacs-toggle-symbols ()
    "Toggle the LSP symbols list without selecting it."
    (interactive)
    (luyangliuable/lsp-treemacs-toggle-view
     lsp-treemacs-symbols-buffer-name
     #'lsp-treemacs-symbols))

  (defun luyangliuable/lsp-treemacs-toggle-references ()
    "Toggle the LSP references list without selecting it."
    (interactive)
    (luyangliuable/lsp-treemacs-toggle-view
     "*LSP Lookup*"
     #'lsp-treemacs-references
     0))

  (defun luyangliuable/lsp-treemacs-toggle-implementations ()
    "Toggle the LSP implementations list without selecting it."
    (interactive)
    (luyangliuable/lsp-treemacs-toggle-view
     "*LSP Lookup*"
     #'lsp-treemacs-implementations
     0))

  (defun luyangliuable/lsp-treemacs-toggle-call-hierarchy ()
    "Toggle the LSP call hierarchy without selecting it."
    (interactive)
    (luyangliuable/lsp-treemacs-toggle-view
     "*Call Hierarchy*"
     #'lsp-treemacs-call-hierarchy
     nil))

  (defun luyangliuable/lsp-treemacs-toggle-type-hierarchy ()
    "Toggle the LSP type hierarchy without selecting it."
    (interactive)
    (luyangliuable/lsp-treemacs-toggle-view
     "*lsp-treemacs-call-hierarchy*"
     #'lsp-treemacs-type-hierarchy
     nil))

  (map! :map lsp-mode-map
        :localleader
        (:prefix "t"
         :desc "Toggle Treemacs sidebar" "t" #'luyangliuable/lsp-treemacs-toggle-sidebar
         :desc "Toggle errors list" "e" #'luyangliuable/lsp-treemacs-toggle-errors-list
         :desc "Toggle symbols list" "s" #'luyangliuable/lsp-treemacs-toggle-symbols
         :desc "Toggle references list" "r" #'luyangliuable/lsp-treemacs-toggle-references
         :desc "Toggle implementations list" "i" #'luyangliuable/lsp-treemacs-toggle-implementations
         :desc "Toggle call hierarchy" "c" #'luyangliuable/lsp-treemacs-toggle-call-hierarchy
         :desc "Toggle type hierarchy" "h" #'luyangliuable/lsp-treemacs-toggle-type-hierarchy
         :desc "Toggle workspace folder sync" "S" #'lsp-treemacs-sync-mode

         (:prefix "a"
          :desc "Go to Treemacs item" "g" #'lsp-treemacs-go-to
          :desc "Go to symbol" "s" #'lsp-treemacs-goto-symbol
          :desc "Go to symbols item" "S" #'lsp-treemacs-symbols-goto-symbol
          :desc "Quick fix" "q" #'lsp-treemacs-quick-fix
          :desc "Cycle diagnostic severity" "v" #'lsp-treemacs-cycle-severity
          :desc "Follow Treemacs item" "RET" #'lsp-treemacs-perform-ret-action)

         (:prefix "m"
          :desc "Toggle dependency-list mode" "d" #'lsp-treemacs-deps-list-mode
          :desc "Toggle error-list mode" "e" #'lsp-treemacs-error-list-mode
          :desc "Toggle generic mode" "g" #'lsp-treemacs-generic-mode)))

  (after! which-key
    (luyangliuable/lsp-apply-localleader-prefix-labels
     luyangliuable/lsp-treemacs-localleader-prefixes)))
