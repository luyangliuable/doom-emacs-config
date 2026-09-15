;;; config/packages/plantuml-mode.el -*- lexical-binding: t; -*-
;; PlantUML diagram authoring + preview.
;; Requires the `plantuml` CLI (and Graphviz `dot`):
;;   brew install plantuml graphviz temurin

(defvar +plantuml--preview-display-request nil
  "One-shot placement request for the next rendered PlantUML preview.
The value is a plist containing the target `:window' and `:maximize' intent.")

(defvar +plantuml--preview-other-frame nil
  "Where to send the next PlantUML preview render.
`focus' sends it to another frame and selects that frame.
`keep' refreshes the frame it already lives on without stealing focus.
nil uses the normal docked side-popup.")

(use-package! plantuml-mode
  :mode ("\\.\\(plantuml\\|puml\\|pum\\|plu\\)\\'" . plantuml-mode)
  :init
  (setq plantuml-default-exec-mode 'executable ; use the `plantuml` CLI (no jar juggling)
        plantuml-executable-path "plantuml"
        plantuml-indent-level 2
        ;; Use PNG, not SVG. plantuml-mode's SVG preview manually `insert-image's
        ;; the data, which bypasses image-mode's display setup and breaks
        ;; `image-transform-fit-to-window' / `image-auto-resize' with
        ;; "Cannot determine image type". PNG lets image-mode manage display.
        plantuml-output-type "png"
        ;; Raise PlantUML's image cap (default 4096 px) so wide diagrams are
        ;; not clipped in the preview. Flows into `plantuml -headless
        ;; -DPLANTUML_LIMIT_SIZE=16384 -tpng -p'.
        plantuml-executable-args '("-headless" "-DPLANTUML_LIMIT_SIZE=16384"))
  :config
  (defun +plantuml--read-preview-file ()
    "Prompt for an existing PlantUML source file to preview."
    (let ((file (expand-file-name
                 (read-file-name "Preview PlantUML file: " nil nil t))))
      (unless (file-regular-p fil )
        (user-error "PlantUML preview requires a regular file: %s" file))
      file))

  (defun +plantuml--preview-file (file prefix)
    "Preview FILE's entire contents, ignoring any active narrowing."
    (with-current-buffer (find-file-noselect file)
      (save-restriction
        (widen)
        (plantuml-preview-buffer prefix))))

  (defun +plantuml/preview-file (prefix)
    "Prompt for a PlantUML file and preview its entire contents."
    (interactive "p")
    (+plantuml--preview-file (+plantuml--read-preview-file) prefix))

  (defun +plantuml--preview-target-window ()
    "Return a regular window suitable for displaying a preview."
    (if (window-parameter (selected-window) 'window-side)
        (or (get-mru-window nil nil t) (selected-window))
      (selected-window)))

  (defun +plantuml--start-preview (window maximize preview)
    "Run PREVIEW and place its completed result in WINDOW.
When MAXIMIZE is non-nil, the preview window is maximized after rendering."
    (let ((request (list :window window :maximize maximize)))
      (setq +plantuml--preview-other-frame nil
            +plantuml--preview-display-request request)
      (condition-case err
          (funcall preview)
        (error
         (when (eq +plantuml--preview-display-request request)
           (setq +plantuml--preview-display-request nil))
         (signal (car err) (cdr err))))))

  (defun +plantuml--preview-in-split (splitter preview)
    "Create a split with SPLITTER and run PREVIEW in its completed window."
    (funcall splitter
             (lambda ()
               (+plantuml--start-preview (selected-window) nil preview))))

  (defun +plantuml--preview-buffer-in-split (splitter)
    "Preview the current buffer in a split created by SPLITTER."
    (+plantuml--preview-in-split
     splitter
     (lambda ()
       (plantuml-preview-buffer 0))))

  (defun +plantuml--preview-file-in-split (splitter)
    "Prompt for a file and preview it in a split created by SPLITTER."
    (let ((file (+plantuml--read-preview-file)))
      (+plantuml--preview-in-split
       splitter
       (lambda ()
         (+plantuml--preview-file file 0)))))

  (defun +plantuml/preview-buffer-vertically ()
    "Preview the current buffer in a vertical split."
    (interactive)
    (+plantuml--preview-buffer-in-split
     #'luyangliuable/split-window-right-and-run-callback))

  (defun +plantuml/preview-buffer-horizontally ()
    "Preview the current buffer in a horizontal split."
    (interactive)
    (+plantuml--preview-buffer-in-split
     #'luyangliuable/split-window-below-and-run-callback))

  (defun +plantuml/preview-buffer-maximized ()
    "Preview the current buffer and maximize the result when it is ready."
    (interactive)
    (+plantuml--start-preview
     (+plantuml--preview-target-window) t
     (lambda ()
       (plantuml-preview-buffer 0))))

  (defun +plantuml/preview-file-vertically ()
    "Prompt for a file and preview it in a vertical split."
    (interactive)
    (+plantuml--preview-file-in-split
     #'luyangliuable/split-window-right-and-run-callback))

  (defun +plantuml/preview-file-horizontally ()
    "Prompt for a file and preview it in a horizontal split."
    (interactive)
    (+plantuml--preview-file-in-split
     #'luyangliuable/split-window-below-and-run-callback))

  (defun +plantuml/preview-file-maximized ()
    "Prompt for a file and maximize its preview when it is ready."
    (interactive)
    (let ((file (+plantuml--read-preview-file)))
      (+plantuml--start-preview
       (+plantuml--preview-target-window) t
       (lambda ()
         (+plantuml--preview-file file 0)))))

  ;; Export the current diagram to a real file next to the source, prompting
  ;; for the format. Uses the plantuml CLI directly (with the raised size
  ;; limit) so exports are full-size and never clipped. SVG is vector/crisp.
  (defun +plantuml/export (fmt)
    "Export the current PlantUML file to FMT (png/svg/pdf) beside the source."
    (interactive
     (list (completing-read "Export format: " '("png" "svg" "pdf") nil t nil nil "png")))
    (unless buffer-file-name
      (user-error "Buffer is not visiting a file; save it first"))
    (when (buffer-modified-p)
      (save-buffer))
    (let* ((src  buffer-file-name)
           (out  (concat (file-name-sans-extension src) "." fmt))
           (code (call-process plantuml-executable-path nil "*plantuml-export*" nil
                               "-headless" "-DPLANTUML_LIMIT_SIZE=16384"
                               (concat "-t" fmt) src)))
      (if (and (integerp code) (zerop code) (file-exists-p out))
          (message "PlantUML exported: %s" out)
        (pop-to-buffer "*plantuml-export*")
        (user-error "PlantUML export failed (exit %s) -- see *plantuml-export*" code))))

  ;; Render the preview and throw it onto another frame (e.g. a second
  ;; monitor). See `+plantuml--update-preview-buffer-a' for why this relies on
  ;; a persistent flag rather than a `let'-bound `display-buffer-alist'.
  (defun +plantuml/preview-other-frame ()
    "Render the PlantUML preview and display it on another frame."
    (interactive)
    (setq +plantuml--preview-display-request nil
          +plantuml--preview-other-frame 'focus)
    (message "PlantUML: rendering preview to another frame...")
    (save-restriction
      (widen)
      (plantuml-preview-buffer 0)))

  (map! :map plantuml-mode-map
        :localleader
        (:prefix ("p" . "preview")
          (:prefix ("b" . "buffer")
           :desc "Split window vertically then preview buffer" "v"
           #'+plantuml/preview-buffer-vertically
           :desc "Split window horizontally then preview buffer" "s"
           #'+plantuml/preview-buffer-horizontally
           :desc "Preview buffer maximized" "."
           #'+plantuml/preview-buffer-maximized)
          (:prefix ("f" . "file")
           :desc "Split window vertically then preview file" "v"
           #'+plantuml/preview-file-vertically
           :desc "Split window horizontally then preview file" "s"
           #'+plantuml/preview-file-horizontally
           :desc "Preview file maximized" "."
           #'+plantuml/preview-file-maximized)
          :desc "Preview region" "r" #'plantuml-preview-region
          :desc "Preview on other frame" "o" #'+plantuml/preview-other-frame
          :desc "Export to file" "s" #'+plantuml/export)))

;; ---------------------------------------------------------------------------
;; Image preview UX: auto-fit big diagrams to the window + easy zoom/nav keys.
;; The PlantUML preview opens in `image-mode'; by default it shows the image at
;; full (often huge) resolution, so only a corner is visible. `fit-window'
;; scales it down to fit, and re-fits on window resize.
;; ---------------------------------------------------------------------------
(setq image-auto-resize 'fit-window
      image-auto-resize-on-window-resize 1)

(defvar +image-pan-step 12
  "Number of units hjkl pans by in `image-mode' (bigger = faster).")

(defun +image-pan-left  () (interactive) (image-backward-hscroll +image-pan-step))
(defun +image-pan-right () (interactive) (image-forward-hscroll  +image-pan-step))
(defun +image-pan-down  () (interactive) (image-next-line        +image-pan-step))
(defun +image-pan-up    () (interactive) (image-previous-line    +image-pan-step))

(after! image-mode
  ;; Evil-friendly bindings inside image buffers (read-only view buffers, so
  ;; overriding normal-state motion keys here is safe and convenient).
  (map! :map image-mode-map
        :n "+" #'image-increase-size           ; zoom in
        :n "=" #'image-increase-size
        :n "-" #'image-decrease-size           ; zoom out
        :n "f" #'image-transform-fit-to-window ; fit whole image to window
        :n "F" #'image-transform-fit-both
        :n "0" #'image-transform-reset         ; back to original size
        ;; hjkl = moderate-step panning (not 1-unit crawl)
        :n "h" #'+image-pan-left
        :n "l" #'+image-pan-right
        :n "j" #'+image-pan-down
        :n "k" #'+image-pan-up
        ;; big screenful jumps
        :n "C-d" #'image-scroll-up
        :n "C-u" #'image-scroll-down
        :n "C-f" #'image-scroll-left
        :n "C-b" #'image-scroll-right))

;; ---------------------------------------------------------------------------
;; Refresh the preview on save (Option A). Stays in `executable' mode so opening
;; a file never contacts a server; saving just re-renders (if the preview is
;; visible). Also dock the preview in a persistent right-side window.
;; ---------------------------------------------------------------------------

(defun +plantuml--frame-to-other-monitor (fr ref)
  "Move frame FR onto a monitor other than REF\='s, maximized.
Frames inherit `(fullscreen . maximized)\=' from `default-frame-alist\=', so a
fresh preview frame is created maximized on the CURRENT monitor and would be
hidden behind the editing frame.  Relocate it to a second monitor when one
exists; otherwise leave it maximized where it is."
  (let* ((monitors (display-monitor-attributes-list))
         (ref-geom (alist-get 'geometry (frame-monitor-attributes ref)))
         (target (cl-find-if
                  (lambda (m) (not (equal (alist-get 'geometry m) ref-geom)))
                  monitors)))
    (when target
      (let* ((area (or (alist-get 'workarea target) (alist-get 'geometry target)))
             (x (nth 0 area))
             (y (nth 1 area)))
        (set-frame-parameter fr 'fullscreen nil)
        (set-frame-position fr x y)
        (set-frame-parameter fr 'fullscreen 'maximized)))))

(defun +plantuml--display-preview-in-window (orig-fn buf window)
  "Update BUF through ORIG-FN, forcing its display into WINDOW."
  (let ((display-buffer-fn (symbol-function 'display-buffer)))
    (cl-letf (((symbol-function 'display-buffer)
               (lambda (buffer-or-name &rest args)
                 (if (eq (get-buffer buffer-or-name) buf)
                     (progn
                       (set-window-buffer window buf)
                       window)
                   (apply display-buffer-fn buffer-or-name args)))))
      (funcall orig-fn 0 buf)))
  (with-current-buffer buf
    (set-window-point window (point-min)))
  (select-window window))

(defun +plantuml--display-preview-request (orig-fn prefix buf request)
  "Apply REQUEST to the completed preview BUF, or use the normal display."
  (let ((window (plist-get request :window)))
    (if (window-live-p window)
        (progn
          (+plantuml--display-preview-in-window orig-fn buf window)
          (when (plist-get request :maximize)
            (delete-other-windows window)))
      (funcall orig-fn prefix buf))))

(defun +plantuml--update-preview-buffer-a (orig-fn prefix buf)
  "Around advice for `plantuml-update-preview-buffer'.
Handle explicit window requests and other-frame previews after rendering.
The executable/jar/server backends call this from a process sentinel, so
display choices must be stored persistently rather than dynamically bound at
command time.  Prefix 16 maps to `switch-to-buffer-other-frame' upstream."
  (let ((request +plantuml--preview-display-request)
        (mode +plantuml--preview-other-frame)
        (orig (selected-frame)))
    (setq +plantuml--preview-display-request nil
          +plantuml--preview-other-frame nil)
    (cond
     (request
      (+plantuml--display-preview-request orig-fn prefix buf request))
     (mode
      (let ((display-buffer-alist nil))
        (funcall orig-fn 16 buf))
      (let* ((win (get-buffer-window buf t))
             (fr (and (window-live-p win) (window-frame win))))
        (when (frame-live-p fr)
          (pcase mode
            ('focus
             (+plantuml--frame-to-other-monitor fr orig)
             (select-frame-set-input-focus fr)
             (raise-frame fr))
            (_
             (when (frame-live-p orig)
               (select-frame-set-input-focus orig)))))))
     (t
      (funcall orig-fn prefix buf)))))

(defun +plantuml/auto-preview-on-save ()
  "Re-render the PlantUML preview after saving, only if it is already visible.
If the preview currently lives on another frame, keep it there instead of
docking a duplicate copy in the editing frame."
  (when (and (derived-mode-p 'plantuml-mode)
             (get-buffer-window plantuml-preview-buffer 'visible))
    (let ((win (get-buffer-window plantuml-preview-buffer 'visible)))
      (setq +plantuml--preview-display-request nil
            +plantuml--preview-other-frame
            (and win (not (eq (window-frame win) (selected-frame))) 'keep)))
    (save-window-excursion
      (save-restriction
        (widen)
        (plantuml-preview-buffer 0)))))

(add-hook 'plantuml-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'+plantuml/auto-preview-on-save nil t)))

(after! plantuml-mode
  (set-popup-rule! (regexp-quote plantuml-preview-buffer)
    :side 'right :size 0.5 :select nil :quit nil :ttl nil)
  ;; Let `+plantuml/preview-other-frame' bypass the docked popup above and send
  ;; the preview to a separate frame instead (async render, see the advice).
  (advice-add 'plantuml-update-preview-buffer :around #'+plantuml--update-preview-buffer-a))

;; Render fenced ```plantuml blocks in Org and run them via the CLI.
(after! org
  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
  (setq org-plantuml-exec-mode 'plantuml))
