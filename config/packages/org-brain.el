;;; config/packages/org-brain.el -*- lexical-binding: t; -*-
;; Concept-map/wiki support with org-brain.

(use-package! org-brain
  :after org
  :init
  (setq org-brain-path (expand-file-name "brain" org-directory))
  (setq-default tab-width 8)

  (after! evil
    (evil-set-initial-state 'org-brain-visualize-mode 'emacs))

  (map! :leader
        (:prefix ("n b" . "org-brain")
         :desc "Visualize brain" "v" #'org-brain-visualize
         :desc "Visualize DWIM" "d" #'org-brain-visualize-dwim
         :desc "Goto entry" "g" #'org-brain-goto
         :desc "Add entry" "a" #'org-brain-add-entry
         :desc "Coding notes map" "c" #'luyangliuable/org-brain-visualize-coding-notes
         :desc "Update ID locations" "u" #'org-brain-update-id-locations
         :desc "Switch brain" "s" #'org-brain-switch-brain
         :desc "Brain agenda" "A" #'org-brain-agenda))

  :config
  (make-directory org-brain-path t)

  (setq org-id-track-globally t
        org-id-locations-file (expand-file-name "org-id-locations" doom-cache-dir)
        org-brain-visualize-default-choices 'all
        org-brain-title-max-length 20)

  (defun luyangliuable/org-force-tab-width ()
    "Keep Org buffers on the parser-required tab width."
    (when (derived-mode-p 'org-mode 'org-brain-visualize-mode)
      (setq-local tab-width 8)))

  (add-hook 'org-mode-hook #'luyangliuable/org-force-tab-width t)
  (add-hook 'org-brain-visualize-mode-hook #'luyangliuable/org-force-tab-width t)
  (add-hook 'hack-local-variables-hook #'luyangliuable/org-force-tab-width)
  (after! editorconfig
    (add-hook 'editorconfig-after-apply-functions
              (lambda (_props) (luyangliuable/org-force-tab-width))))

  (add-to-list 'org-capture-templates
               '("b" "Brain" plain (function org-brain-goto-end)
                 "* %i%?" :empty-lines 1))

  (defun luyangliuable/org-brain-buffer-p ()
    "Return non-nil when the current buffer is an Org file in `org-brain-path'."
    (and buffer-file-name
         (derived-mode-p 'org-mode)
         (file-in-directory-p (file-truename buffer-file-name)
                              (file-truename org-brain-path))))

  (defun luyangliuable/org-brain-ensure-ids ()
    "Ensure Org IDs for headings in org-brain files."
    (when (luyangliuable/org-brain-buffer-p)
      (org-brain-ensure-ids-in-buffer)))

  (add-hook 'before-save-hook #'luyangliuable/org-brain-ensure-ids)

  (defun luyangliuable/org-brain-visualize-coding-notes (&optional depth)
    "Visualize the generated coding-notes brain as a mind map."
    (interactive "P")
    (let* ((depth (if depth (prefix-numeric-value depth) 3))
           (entry (or (org-brain-entry-from-id "coding-notes")
                      (progn
                        (org-brain-update-id-locations)
                        (org-brain-entry-from-id "coding-notes")))))
      (unless entry
        (user-error "Could not find coding-notes entry; run the sync script first"))
      (setq org-brain-visualizing-mind-map t)
      (org-brain-visualize entry)
      (setq-local org-brain-mind-map-child-level depth)
      (setq-local org-brain-mind-map-parent-level 1)
      (org-brain-visualize entry)))

  (defvar luyangliuable/org-brain-visualize-help-map
    (let ((map (make-sparse-keymap)))
      (dolist (binding '(("j" . forward-button)
                         ("TAB" . forward-button)
                         ("k" . backward-button)
                         ("<backtab>" . backward-button)
                         ("RET" . push-button)
                         ("m" . org-brain-visualize-mind-map)
                         ("+" . org-brain-show-descendant-level)
                         ("-" . org-brain-hide-descendant-level)
                         ("z" . org-brain-show-ancestor-level)
                         ("Z" . org-brain-hide-ancestor-level)
                         ("u" . org-brain-visualize-parent)
                         ("b" . org-brain-visualize-back)
                         ("v" . org-brain-visualize)
                         ("o" . org-brain-goto-current)
                         ("O" . org-brain-goto)))
        (define-key map (kbd (car binding)) (cdr binding)))
      map)
    "Which-key help map for `org-brain-visualize-mode'.")

  (dolist (binding '(("c" . org-brain-add-child)
                     ("p" . org-brain-add-parent)
                     ("f" . org-brain-add-friendship)
                     ("l" . org-brain-add-resource)
                     ("r" . org-brain-open-resource)
                     ("n" . org-brain-pin)
                     ("R" . org-brain-visualize-random)
                     ("W" . org-brain-visualize-wander)
                     ("?" . luyangliuable/org-brain-show-visualize-help)
                     ("q" . org-brain-visualize-quit)))
    (define-key luyangliuable/org-brain-visualize-help-map
                (kbd (car binding)) (cdr binding)))

  (defun luyangliuable/org-brain-show-visualize-help ()
    "Show org-brain visualization shortcuts in a which-key popup."
    (interactive)
    (if (fboundp 'which-key-show-keymap)
        (progn
          (message "Global: SPC n b c opens Coding Notes map directly")
          (which-key-show-keymap 'luyangliuable/org-brain-visualize-help-map t))
      (describe-mode)))

  (after! which-key
    (which-key-add-keymap-based-replacements luyangliuable/org-brain-visualize-help-map
      "j" '("Next button/link" . forward-button)
      "TAB" '("Next button/link" . forward-button)
      "k" '("Previous button/link" . backward-button)
      "<backtab>" '("Previous button/link" . backward-button)
      "RET" '("Open/follow button at point" . push-button)
      "m" '("Toggle mind-map mode" . org-brain-visualize-mind-map)
      "+" '("Show one more child/descendant level" . org-brain-show-descendant-level)
      "-" '("Hide one child/descendant level" . org-brain-hide-descendant-level)
      "z" '("Show one more parent/ancestor level" . org-brain-show-ancestor-level)
      "Z" '("Hide one parent/ancestor level" . org-brain-hide-ancestor-level)
      "u" '("Go up to parent" . org-brain-visualize-parent)
      "b" '("Back" . org-brain-visualize-back)
      "v" '("Choose another entry to visualize" . org-brain-visualize)
      "o" '("Open current entry for editing" . org-brain-goto-current)
      "O" '("Choose entry and open it" . org-brain-goto)
      "c" '("Add child" . org-brain-add-child)
      "p" '("Add parent" . org-brain-add-parent)
      "f" '("Add friend" . org-brain-add-friendship)
      "l" '("Add resource/link" . org-brain-add-resource)
      "r" '("Open resource" . org-brain-open-resource)
      "n" '("Pin/unpin" . org-brain-pin)
      "R" '("Random entry" . org-brain-visualize-random)
      "W" '("Wander randomly" . org-brain-visualize-wander)
      "?" '("Show this help" . luyangliuable/org-brain-show-visualize-help)
      "q" '("Quit visualization" . org-brain-visualize-quit)))

  (define-key org-brain-visualize-mode-map
              (kbd "?") #'luyangliuable/org-brain-show-visualize-help)
  (define-key org-brain-visualize-mode-map (kbd "R") #'org-brain-visualize-random)
  (define-key org-brain-visualize-mode-map (kbd "w") #'forward-word)

  (map! :map org-mode-map
        :localleader
        (:prefix ("b" . "org-brain")
         :desc "Org brain prefix" "b" #'org-brain-prefix-map
         :desc "Visualize entry" "v" #'org-brain-visualize
         :desc "Get/create ID" "i" #'org-brain-get-id
         :desc "Add child" "c" #'org-brain-add-child
         :desc "Add parent" "p" #'org-brain-add-parent
         :desc "Add friend" "f" #'org-brain-add-friendship)))

