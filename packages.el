;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

(package! shell-maker
  :recipe (:host github :repo "xenodium/shell-maker")
  :pin "43ee9e1862994cbaa89715d324edb7a424181f22")
(package! acp
  :recipe (:host github :repo "xenodium/acp.el")
  :pin "c8ee1d7f70105fba8efa964ca63f38ca94a1e759")
(package! agent-shell)
(package! anki-editor)
(package! auto-highlight-symbol)
(package! beacon)
(package! doom-modeline)
(package! drag-stuff)
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
(package! org-brain
  :recipe (:host github :repo "Kungsgeten/org-brain"))
(package! persistent-scratch)
(package! projectile)
(package! terminal-here)
(package! undo-tree)
(package! zone)
;; enime + its elisp deps (dash & s ship with Doom already)
(package! mpv)
(package! esxml)
(package! request)
(package! enime :recipe (:host github :repo "xl666/enime" :files ("*.el" "video_scrapping.sh")))
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
