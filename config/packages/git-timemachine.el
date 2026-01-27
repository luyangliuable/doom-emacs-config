;;; config/packages/git-timemachine.el -*- lexical-binding: t; -*-
;; Git timemachine configuration with transient state

(use-package! git-timemachine
  :defer t
  :config
  (defhydra time-machine-transient-state (:color blue :hint nil)
    "
Git Time Machine
^^^^^^^^-----------------------
_c_: show current revision
_g_: show nth revision  
_p_: show previous revision
_n_: show next revision
_N_: show previous revision
_Y_: kill revision
_q_: quit
"
    ("c" git-timemachine-show-current-revision)
    ("g" git-timemachine-show-nth-revision)
    ("p" git-timemachine-show-previous-revision)
    ("n" git-timemachine-show-next-revision)
    ("N" git-timemachine-show-previous-revision)
    ("Y" git-timemachine-kill-revision)
    ("q" nil)))
