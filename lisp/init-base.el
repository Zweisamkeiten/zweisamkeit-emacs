;; init-base.el --- Better default configurations.

;;; Commentary:
;;
;; Better defaults.
;;

;;; Code:

(defalias 'yes-or-no-p 'y-or-n-p)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

(setq gc-cons-threshold most-positive-fixnum)

(setq make-backup-file nil)
(setq auto-save-default nil)
(setq backup-inhibited t)
(setq backup-directory-alist `(("." . "~/.cache/.saves")))

(provide 'init-base)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-base.el ends here
