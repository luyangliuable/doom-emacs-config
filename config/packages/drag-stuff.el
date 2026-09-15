;;; config/packages/drag-stuff.el -*- lexical-binding: t; -*-
;; Drag-stuff and Origami package configuration.

(use-package! drag-stuff
  :config
  (drag-stuff-mode t))

(use-package! origami
  :commands origami-mode
  :hook (prog-mode . origami-mode)
  :init
  (when (bound-and-true-p global-origami-mode)
    (global-origami-mode -1))
  :config
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'prog-mode)
        (origami-mode 1)))))

(after! (hydra origami)
  (defhydra luyangliuable/origami-hydra (:hint nil)
    "
Close             Open              Toggle          Go to          Other
^^^^^^-----------------------------------------------------------------------
_c_: at point     _o_: at point     _a_: at point    _n_: next      _s_: isolate
_C_: recursively  _O_: recursively  _A_: all         _p_: previous  _R_: reset
_m_: all          _r_: all          _TAB_: cycle                    _q_: quit
"
    ("a" origami-forward-toggle-node)
    ("A" origami-toggle-all-nodes)
    ("c" origami-close-node)
    ("C" origami-close-node-recursively)
    ("o" origami-open-node)
    ("O" origami-open-node-recursively)
    ("r" origami-open-all-nodes)
    ("m" origami-close-all-nodes)
    ("n" origami-next-fold)
    ("p" origami-previous-fold)
    ("s" origami-show-only-node)
    ("R" origami-reset)
    ("TAB" origami-recursively-toggle-node)
    ("<tab>" origami-recursively-toggle-node)
    ("q" nil :exit t)
    ("C-g" nil :exit t)
    ("SPC" nil :exit t)))
