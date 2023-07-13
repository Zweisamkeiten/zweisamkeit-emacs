;;; init-elpa.el --- Initialize package configurations.	-*- lexical-binding: t -*-

;;; Commentary:
;;
;; Emacs Package source configurations.
;;

;;; Code:

(setq package-archives
    '(("melpa" . "http://mirrors.bfsu.edu.cn/elpa/melpa/")
      ("org"   . "http://mirrors.bfsu.edu.cn/elpa/org/")
      ("gnu"   . "http://mirrors.bfsu.edu.cn/elpa/gnu/")))

(setq package-check-signature nil) ;

(require 'package)

(unless (bound-and-true-p package--initialize)
  (package-initialize))

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-and-compile
  (setq use-package-always-ensure t)
  (setq use-package-always-defer t)
  (setq use-package-always-demand nil)
  (setq use-package-expand-minimally t)
  (setq use-package-verbose t))

(require 'use-package)

(provide 'init-elpa)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-elpa.el ends here
