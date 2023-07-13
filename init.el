;;; init.el --- emacs init

;;; Commentary:
;;
;; Zweisamkeit Emacs - My personal Emacs Configuration.
;;

;;; Code:

(when (version< emacs-version "28.0")
  (error "This requires Emacs 28.0 and above!"))

(add-to-list 'load-path
	     (expand-file-name (concat user-emacs-directory "lisp")))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

(require 'init-base)
(require 'init-elpa)
(require 'init-packages)
(require 'init-ui)
(require 'init-lsp)

(when (file-exists-p custom-file)
  (load-file custom-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init.el ends here
