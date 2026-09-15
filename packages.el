;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

(package! shell-maker
  :recipe (:host github :repo "xenodium/shell-maker"))
(package! acp
  :recipe (:host github :repo "xenodium/acp.el"))
(package! agent-shell)
(package! agent-shell-workspace
  :recipe (:host github :repo "gveres/agent-shell-workspace"))
(package! workspace-hud
  :recipe (:host github
           :repo "nohzafk/emacs-workspace-hud"
           :pre-build (("bash" "-c" "cargo_bin=\"${CARGO_HOME:-$HOME/.cargo}/bin\"; export PATH=\"$cargo_bin:$PATH\"; if command -v rustup >/dev/null 2>&1; then rustup target add wasm32-unknown-unknown || exit $?; rustc_path=\"$(rustup which rustc)\" || exit $?; export PATH=\"$(dirname \"$rustc_path\"):$PATH\"; fi; git submodule update --init --recursive && cd ui && wasm-pack build --target web --release"))
           :files (("lisp/" "lisp/*.el")
                   ("emacs-egui/lisp/" "emacs-egui/lisp/*.el")
                   ("ui/" "ui/index.html")
                   ("ui/pkg/" "ui/pkg/*"))))
(package! agent-shell-hud
  :recipe (:host github :repo "nohzafk/agent-shell-hud"))
(package! anki-editor)
(package! auto-highlight-symbol)
(package! copilot
  :recipe (:host github :repo "copilot-emacs/copilot.el"
           :files ("*.el")))
(package! beacon)
(package! doom-modeline)
(package! bongo-cat-mode
  :recipe (:host github
           :repo "luyangliuable/bongo-cat-model.el"
           :files ("bongo-cat-mode.el" "img")))
(package! minor-mode-badges
  :recipe (:host github
           :repo "luyangliuable/minor-mode-badges.el"
           :files ("minor-mode-badges.el")))
(package! drag-stuff)
(package! origami)
(package! evil-iedit-state)
(package! prettier-elisp
  :recipe (:host github :repo "KarimAziev/prettier-elisp"))
(package! exec-path-from-shell)
(package! git-timemachine)
(package! golden-ratio)
(package! good-scroll)
(package! gptel :recipe (:nonrecursive t))
(package! lsp-treemacs)
(package! lsp-pyright)
(package! lsp-vtsls :recipe (:host github :repo "sdvcrx/lsp-vtsls"))
(package! math-preview :recipe (:host github :repo "emacsmirror/math-preview"))
(package! minimap)
(package! org-jira)
(package! agent-shell-sidebar
  :recipe (:host github :repo "cmacrae/agent-shell-sidebar"))
(package! org-brain
  :recipe (:host github :repo "Kungsgeten/org-brain"))
(package! persistent-scratch)
;; TODO we need plantuml-mode since plantuml is already declared in init.el
(package! plantuml-mode
:recipe (:host github :repo "skuro/plantuml-mode"))
(package! projectile)
;; undo-tree 0.8.2 requires GNU ELPA queue >= 0.2.  Make the dependency
;; explicit so Doom cannot reach `global-undo-tree-mode' without it installed.
(package! queue)
(package! terminal-here)
(package! zone)
;; enime + its elisp deps (dash & s ship with Doom already)
(package! mpv)
(package! esxml)
(package! request)
;; (package! enime :recipe (:host github :repo "xl666/enime" :files ("*.el" "video_scrapping.sh")))
;;(package! helm-projectile)  ; Removed: Switching to Vertico for better performance

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)
