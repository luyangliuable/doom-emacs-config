;;; frutiger-aero-v2-theme-test.el --- Aero v2 theme checks -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defvar frutiger-aero-v2-humanist-font)

(defconst luyangliuable/frutiger-v2-test-root
  (expand-file-name ".." (file-name-directory load-file-name)))

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" luyangliuable/frutiger-v2-test-root))

(defconst luyangliuable/frutiger-v2-themes
  '(frutiger-aero-v2 frutiger-aero-v2-light))

(defun luyangliuable/frutiger-v2-test-face (theme face)
  "Return THEME's true-color attributes for FACE."
  (let ((spec (cadr (assq theme (get face 'theme-face)))))
    (should spec)
    (cadr (car spec))))

(defun luyangliuable/frutiger-v2-test-attr (theme face attribute)
  (plist-get (luyangliuable/frutiger-v2-test-face theme face) attribute))

(defun luyangliuable/frutiger-v2-test-rgb (hex)
  (should (string-match-p "\\`#[[:xdigit:]]\\{6\\}\\'" hex))
  (cl-loop for i in '(1 3 5)
           collect (string-to-number (substring hex i (+ i 2)) 16)))

(defun luyangliuable/frutiger-v2-test-luminance (hex)
  "Return the relative luminance of sRGB HEX."
  (let ((channels (cl-loop for channel in (luyangliuable/frutiger-v2-test-rgb hex)
                           for c = (/ channel 255.0)
                           collect (if (<= c 0.04045)
                                       (/ c 12.92)
                                     (expt (/ (+ c 0.055) 1.055) 2.4)))))
    (+ (* 0.2126 (nth 0 channels))
       (* 0.7152 (nth 1 channels))
       (* 0.0722 (nth 2 channels)))))

(defun luyangliuable/frutiger-v2-test-contrast (a b)
  "Return WCAG contrast ratio between colors A and B."
  (let ((x (luyangliuable/frutiger-v2-test-luminance a))
        (y (luyangliuable/frutiger-v2-test-luminance b)))
    (/ (+ (max x y) 0.05) (+ (min x y) 0.05))))

(defun luyangliuable/frutiger-v2-test-readable (theme face background)
  (let ((fg (luyangliuable/frutiger-v2-test-attr theme face :foreground)))
    (should (stringp fg))
    (should (>= (luyangliuable/frutiger-v2-test-contrast fg background) 4.5))))

(defconst luyangliuable/frutiger-v2-syntax-faces
  '(font-lock-keyword-face font-lock-function-name-face font-lock-string-face
    font-lock-type-face font-lock-comment-face font-lock-constant-face
    font-lock-variable-name-face warning error success))

(ert-deftest luyangliuable/frutiger-v2-dark-is-a-lit-lagoon-not-black-or-slate ()
  (load-theme 'frutiger-aero-v2 t)
  (let* ((theme 'frutiger-aero-v2)
         (bg (luyangliuable/frutiger-v2-test-attr theme 'default :background))
         (rgb (luyangliuable/frutiger-v2-test-rgb bg))
         (hl (luyangliuable/frutiger-v2-test-attr theme 'hl-line :background)))
    (should (custom-theme-enabled-p theme))
    ;; v1 sits at ~0.009; old v2 slate sat at ~0.085.  Aim for the middle.
    (should (< 0.025 (luyangliuable/frutiger-v2-test-luminance bg) 0.06))
    ;; saturated cerulean, not grey: blue clearly dominates red
    (should (>= (- (nth 2 rgb) (nth 0 rgb)) 48))
    ;; glass reflection: the current line is lighter than the water
    (should (> (luyangliuable/frutiger-v2-test-luminance hl)
               (luyangliuable/frutiger-v2-test-luminance bg)))
    (should (>= (luyangliuable/frutiger-v2-test-contrast
                 (luyangliuable/frutiger-v2-test-attr theme 'default :foreground) bg)
                7.0))
    (dolist (face luyangliuable/frutiger-v2-syntax-faces)
      (luyangliuable/frutiger-v2-test-readable theme face bg)
      (luyangliuable/frutiger-v2-test-readable theme face hl))))

(ert-deftest luyangliuable/frutiger-v2-light-is-sky-with-white-glass ()
  (load-theme 'frutiger-aero-v2-light t)
  (let* ((theme 'frutiger-aero-v2-light)
         (bg (luyangliuable/frutiger-v2-test-attr theme 'default :background))
         (rgb (luyangliuable/frutiger-v2-test-rgb bg))
         (hl (luyangliuable/frutiger-v2-test-attr theme 'hl-line :background)))
    (should (custom-theme-enabled-p theme))
    ;; tinted sky, not paper white
    (should (>= (- (nth 2 rgb) (nth 0 rgb)) 12))
    ;; frosted glass panes are brighter than the sky behind them
    (should (> (luyangliuable/frutiger-v2-test-luminance hl)
               (luyangliuable/frutiger-v2-test-luminance bg)))
    (dolist (face '(corfu-default company-tooltip org-block))
      (should (> (luyangliuable/frutiger-v2-test-luminance
                  (luyangliuable/frutiger-v2-test-attr theme face :background))
                 (luyangliuable/frutiger-v2-test-luminance bg))))
    (should (>= (luyangliuable/frutiger-v2-test-contrast
                 (luyangliuable/frutiger-v2-test-attr theme 'default :foreground) bg)
                7.0))
    (dolist (face luyangliuable/frutiger-v2-syntax-faces)
      (luyangliuable/frutiger-v2-test-readable theme face bg)
      (luyangliuable/frutiger-v2-test-readable theme face hl))))

(ert-deftest luyangliuable/frutiger-v2-chrome-is-rimmed-glass-without-bevels ()
  (dolist (theme luyangliuable/frutiger-v2-themes)
    (load-theme theme t)
    (let ((ml-bg (luyangliuable/frutiger-v2-test-attr theme 'mode-line :background)))
      (dolist (face '(mode-line header-line tab-bar-tab))
        (should (stringp (luyangliuable/frutiger-v2-test-attr theme face :overline))))
      ;; chunky released-button bevels made the previous v2 look dated
      (dolist (face '(mode-line mode-line-inactive header-line vertico-current
                      company-tooltip-selection show-paren-match isearch
                      minibuffer-prompt tab-bar-tab org-block))
        (let ((box (luyangliuable/frutiger-v2-test-attr theme face :box)))
          (should-not (and (consp box) (plist-get box :style)))))
      (luyangliuable/frutiger-v2-test-readable theme 'mode-line ml-bg)
      (dolist (face '(doom-modeline-buffer-file doom-modeline-buffer-path
                      doom-modeline-project-dir doom-modeline-buffer-modified
                      doom-modeline-buffer-major-mode mode-line-buffer-id))
        (luyangliuable/frutiger-v2-test-readable theme face ml-bg))
      (let ((inactive (luyangliuable/frutiger-v2-test-face theme 'mode-line-inactive)))
        (should (>= (luyangliuable/frutiger-v2-test-contrast
                     (plist-get inactive :foreground) (plist-get inactive :background))
                    4.5))))))

(ert-deftest luyangliuable/frutiger-v2-completion-is-readable ()
  (dolist (theme luyangliuable/frutiger-v2-themes)
    (load-theme theme t)
    (dolist (pair '((vertico-current . vertico-current)
                    (company-tooltip-selection . company-tooltip-selection)
                    (corfu-current . corfu-current)
                    (company-tooltip . company-tooltip)
                    (corfu-default . corfu-default)))
      (luyangliuable/frutiger-v2-test-readable
       theme (car pair)
       (luyangliuable/frutiger-v2-test-attr theme (cdr pair) :background)))
    (let ((selected (luyangliuable/frutiger-v2-test-attr theme 'vertico-current :background)))
      (dolist (face '(orderless-match-face-0 orderless-match-face-1
                      orderless-match-face-2 orderless-match-face-3
                      company-tooltip-common))
        (luyangliuable/frutiger-v2-test-readable
         theme face
         (or (luyangliuable/frutiger-v2-test-attr theme face :background) selected))))))

(ert-deftest luyangliuable/frutiger-v2-headings-are-humanist-and-tiered ()
  (let ((frutiger-aero-v2-humanist-font "Test Humanist Sans"))
    (dolist (theme luyangliuable/frutiger-v2-themes)
      (load-theme theme t)
      (dolist (face '(org-document-title org-level-1 org-level-2 org-level-3
                      markdown-header-face-1))
        (should (equal (luyangliuable/frutiger-v2-test-attr theme face :family)
                       "Test Humanist Sans")))
      (let ((title (luyangliuable/frutiger-v2-test-attr theme 'org-document-title :height))
            (h1 (luyangliuable/frutiger-v2-test-attr theme 'org-level-1 :height))
            (h2 (luyangliuable/frutiger-v2-test-attr theme 'org-level-2 :height)))
        (should (> title h1 h2 1.0))))))

(ert-deftest luyangliuable/frutiger-v2-headings-fall-back-without-humanist-font ()
  (let ((frutiger-aero-v2-humanist-font nil))
    (dolist (theme luyangliuable/frutiger-v2-themes)
      (load-theme theme t)
      (should-not (stringp (luyangliuable/frutiger-v2-test-attr theme 'org-level-1 :family))))))

(ert-deftest luyangliuable/frutiger-v2-delimiters-are-a-water-spectrum ()
  (dolist (theme luyangliuable/frutiger-v2-themes)
    (load-theme theme t)
    (let* ((bg (luyangliuable/frutiger-v2-test-attr theme 'default :background))
           (colors (cl-loop for depth from 1 to 9
                            for face = (intern (format "rainbow-delimiters-depth-%d-face" depth))
                            do (luyangliuable/frutiger-v2-test-readable theme face bg)
                            collect (luyangliuable/frutiger-v2-test-attr theme face :foreground))))
      (should (>= (length (delete-dups colors)) 8)))))

(ert-deftest luyangliuable/frutiger-v2-theme-cycle-keeps-v1-first-and-defaults ()
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name "themes.el" luyangliuable/frutiger-v2-test-root))
    (goto-char (point-min))
    (search-forward "(setq luyangliuable/themes")
    (goto-char (match-beginning 0))
    (let* ((form (read (current-buffer)))
           (themes (cadr (nth 2 form))))
      (should (equal (cl-subseq themes 0 4)
                     '(frutiger-aero frutiger-aero-light
                       frutiger-aero-v2 frutiger-aero-v2-light))))
    (dolist (setting '((default-dark-theme . doom-monokai-machine)
                       (default-light-theme . doom-one-light)))
      (goto-char (point-min))
      (search-forward (format "(setq %s" (car setting)))
      (goto-char (match-beginning 0))
      (should (eq (cadr (nth 2 (read (current-buffer))))
                  (cdr setting))))))

;;; frutiger-aero-v2-theme-test.el ends here
