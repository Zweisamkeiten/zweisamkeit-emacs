;; init-ui.el --- Better lookings and appearances.

;;; Commentary:
;;
;; Visual (UI) configurations for better lookings and appearances.
;;

;;; Code:

(setq inhibit-startup-message t)

(scroll-bar-mode -1)		; Disable visible scrollbar
(tool-bar-mode -1)		; Disable the toolbar
(tooltip-mode -1)		; Disable tooltips
(set-fringe-mode 5)		; Give some breathing room
(menu-bar-mode -1)

;; 设置光标形状
(setq-default cursor-type 'bar)

;; Set up the visible bell
(setq visible-bell t)

(add-to-list 'default-frame-alist '(font . "monospace 12"))

(use-package doom-themes
  ;;:init (load-theme 'doom-tokyo-night t))
  )

(use-package catppuccin-theme
  :init (load-theme 'catppuccin t))

(use-package smart-mode-line
  :init
  (setq sml/no-confirm-load-theme t
	sml/theme 'respectful)
  (sml/setup))

(use-package emacs
  :config
  (setq display-line-numbers-type 'relative)
  (global-display-line-numbers-mode t))

(provide 'init-ui)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-ui.el ends here
