;;; config/packages/vertico.el -*- lexical-binding: t; -*-
;; Vertico Package Configuration

(after! vertico
  ;; Increase candidate count for ripgrep results
  (setq vertico-count 20)

  ;; Enable cycling for command menu
  (setq vertico-cycle t))
