;;; config/packages/shell/eat-terminfo.el -*- lexical-binding: t; -*-
;; Terminfo for Eat that the system ncurses can read.
;;
;; Eat ships `eat-256color' and `eat-truecolor' compiled in ncurses' extended
;; number format.  macOS's ncurses 6.0, which /bin/zsh uses, cannot read that
;; format, so zsh reports "unknown terminal type" and falls back to a
;; single-line redraw that no longer matches the command line.  Compiling
;; eat.ti with the system `tic' writes entries every ncurses can read.

(require 'subr-x)

(defvar eat--install-path)
(defvar eat-term-terminfo-directory)

(defvar luyangliuable/eat-terminfo-directory
  (expand-file-name "eat-terminfo/"
                    (if (boundp 'doom-cache-dir) doom-cache-dir temporary-file-directory))
  "Where Eat's terminfo is compiled with the system `tic'.")

(defun luyangliuable/eat--system-program (name)
  "Return the system copy of program NAME, preferring /usr/bin.
Homebrew's ncurses writes the extended format that the system one cannot read."
  (let ((system (expand-file-name name "/usr/bin/")))
    (if (file-executable-p system) system (executable-find name))))

(defun luyangliuable/eat-compile-terminfo (source target)
  "Compile terminfo SOURCE (eat.ti) into directory TARGET with the system `tic'.
Skip the work when TARGET is newer than SOURCE.  Return TARGET on success
and nil otherwise."
  (let ((tic (luyangliuable/eat--system-program "tic"))
        (stamp (expand-file-name "eat-terminfo.stamp" target)))
    (cond
     ((not (and tic (file-readable-p source)))
      nil)
     ((file-newer-than-file-p stamp source)
      target)
     (t
      (make-directory target t)
      (with-temp-buffer
        (if (zerop (call-process tic nil t nil "-x" "-o" target source))
            (progn
              (write-region "" nil stamp nil 'silent)
              target)
          (message "Could not compile Eat terminfo: %s" (string-trim (buffer-string)))
          nil))))))

(defun luyangliuable/eat-use-compiled-terminfo ()
  "Point Eat at terminfo compiled by the system `tic', when that works."
  (when-let ((directory (luyangliuable/eat-compile-terminfo
                         (expand-file-name "eat.ti" eat--install-path)
                         luyangliuable/eat-terminfo-directory)))
    (setq eat-term-terminfo-directory directory)))

;;; eat-terminfo.el ends here
