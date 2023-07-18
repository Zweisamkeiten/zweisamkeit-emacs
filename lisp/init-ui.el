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

(defun font-installed-p (font-name)
  "Check if font with FONT-NAME is available."
  (find-font (font-spec :name font-name)))

(defconst sys/win32p
  (eq system-type 'windows-nt)
  "Are we running on a WinTel system?")

(defconst sys/linuxp
  (eq system-type 'gnu/linux)
  "Are we running on a GNU/Linux system?")

(defconst sys/macp
  (eq system-type 'darwin)
  "Are we running on a Mac system?")

(defun centaur-setup-fonts ()
  "Setup fonts."
  (interactive)
  (when (display-graphic-p)
    ;; Set default font
    (cl-loop for font in '("monospace" "Cascadia Code" "Fira Code" "Jetbrains Mono"
                           "SF Mono" "Hack" "Menlo"
                           "Monaco" "DejaVu Sans Mono" "Consolas")
             when (font-installed-p font)
             return (set-face-attribute 'default nil
                                        :family font
                                        :height (cond (sys/macp 130)
                                                      (sys/win32p 110)
                                                      (t 120))))
    ;; Set mode-line font
     (cl-loop for font in '("Bookerly" "Fira Code" "Menlo" "SF Pro Display" "Helvetica")
              when (font-installed-p font)
              return (progn
                       (set-face-attribute 'mode-line nil :family font :height 100)
                       (when (facep 'mode-line-active)
                         (set-face-attribute 'mode-line-active nil :family font :height 100))
                       (set-face-attribute 'mode-line-inactive nil :family font :height 100)))

    ;; Specify font for all unicode characters
    (cl-loop for font in '("Segoe UI Symbol" "Symbola" "Symbol")
             when (font-installed-p font)
             return (if (< emacs-major-version 27)
                        (set-fontset-font "fontset-default" 'unicode font nil 'prepend)
                      (set-fontset-font t 'symbol (font-spec :family font) nil 'prepend)))

    ;; Emoji
    (cl-loop for font in '("Noto Color Emoji" "Apple Color Emoji" "Segoe UI Emoji")
             when (font-installed-p font)
             return (cond
                     ((< emacs-major-version 27)
                      (set-fontset-font "fontset-default" 'unicode font nil 'prepend))
                     ((< emacs-major-version 28)
                      (set-fontset-font t 'symbol (font-spec :family font) nil 'prepend))
                     (t
                      (set-fontset-font t 'emoji (font-spec :family font) nil 'prepend))))

    ;; Specify font for Chinese characters
    (cl-loop for font in '("LXGW WenKai" "WenQuanYi Micro Hei" "PingFang SC" "Microsoft Yahei" "STFangsong")
             when (font-installed-p font)
             return (progn
                      (setq face-font-rescale-alist `((,font . 1.0)))
                      (set-fontset-font t '(#x4e00 . #x9fff) (font-spec :family font))))))

(use-package doom-themes
  :init (load-theme 'doom-one t)
  :config
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
	doom-themes-enable-italic t) ; if nil, italics is universally disabled
					;(doom-themes-neotree-config)  ; all-the-icons fonts must be installed!
					; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config))

;; (use-package catppuccin-theme
;;  :init (load-theme 'catppuccin t))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-icon t
        doom-modeline-height 1
        doom-modeline-window-width-limit 110
        doom-modeline-minor-modes t))

(use-package emacs
  :config
  (setq display-line-numbers-type 'relative)
  (global-display-line-numbers-mode t))

;; A minor-mode menu for mode-line
(use-package minions
  :hook (doom-modeline-mode . minions-mode))

;; Fonts
(defun centaur-install-fonts ()
  "Install necessary fonts."
  (interactive)

  (let* ((font-dest (cond
                     ;; Default Linux install directories
                     ((member system-type '(gnu gnu/linux gnu/kfreebsd))
                      (concat (or (getenv "XDG_DATA_HOME")
                                  (concat (getenv "HOME") "/.local/share"))
                              "/fonts/"))
                     ;; Default MacOS install directory
                     ((eq system-type 'darwin)
                      (concat (getenv "HOME") "/Library/Fonts/"))))
         (known-dest? (stringp font-dest))
         (font-dest (or font-dest (read-directory-name "Font installation directory: " "~/"))))

    (unless (file-directory-p font-dest) (mkdir font-dest t))

    ;; Download `all-the-fonts'
    (when (bound-and-true-p all-the-icons-font-names)
      (let ((url-format "https://raw.githubusercontent.com/domtronn/all-the-icons.el/master/fonts/%s"))
        (mapc (lambda (font)
                (url-copy-file (format url-format font) (expand-file-name font font-dest) t))
              all-the-icons-font-names)))

    ;; Download `Symbola'
    ;; See https://dn-works.com/wp-content/uploads/2020/UFAS-Fonts/Symbola.zip
    (let* ((url (concat centaur-homepage "/files/6135060/symbola.zip"))
           (temp-file (make-temp-file "symbola-" nil ".zip"))
           (dir (concat (file-name-directory temp-file) "/symbola/"))
           (unzip-script (cond ((executable-find "unzip")
                                (format "mkdir -p %s && unzip -qq %s -d %s"
                                        dir temp-file dir))
                               ((executable-find "powershell")
                                (format "powershell -noprofile -noninteractive \
  -nologo -ex bypass Expand-Archive -path '%s' -dest '%s'" temp-file dir))
                               (t (user-error "Unable to extract '%s' to '%s'! \
  Please check unzip, powershell or extract manually." temp-file dir)))))
      (url-copy-file url temp-file t)
      (when (file-exists-p temp-file)
        (shell-command-to-string unzip-script)
        (let* ((font-name "Symbola.otf")
               (temp-font (expand-file-name font-name dir)))
          (if (file-exists-p temp-font)
              (copy-file temp-font (expand-file-name font-name font-dest) t)
            (message "Failed to download `Symbola'!")))))

    (when known-dest?
      (message "Fonts downloaded, updating font cache... <fc-cache -f -v> ")
      (shell-command-to-string (format "fc-cache -f -v")))

    (message "Successfully %s `all-the-icons' and `Symbola' fonts to `%s'!"
             (if known-dest? "installed" "downloaded")
             font-dest)))

(centaur-setup-fonts)
(add-hook 'window-setup-hook #'centaur-setup-fonts)
(add-hook 'server-after-make-frame-hook #'centaur-setup-fonts)

;; Icons
;; NOTE: Must run `M-x all-the-icons-install-fonts', and install fonts manually on Windows
(when t
  (use-package all-the-icons
    :custom (all-the-icons-scale-factor 1.1)
    :init (unless (or sys/win32p
                      (daemonp)
                      (font-installed-p "all-the-icons"))
            (centaur-install-fonts))
    :config
    ;; Support more icons
    (let ((extension-icon-alist
           '(("bat"  all-the-icons-alltheicon "terminal" :face all-the-icons-lsilver)
             ("cmd"  all-the-icons-alltheicon "terminal" :face all-the-icons-lsilver)
             ("conf" all-the-icons-octicon "settings"    :v-adjust 0.0 :face all-the-icons-yellow)
             ("eln"  all-the-icons-octicon "file-binary" :v-adjust 0.0 :face all-the-icons-dsilver)
             ("epub" all-the-icons-faicon "book"         :height 1.0 :v-adjust -0.1 :face all-the-icons-green)
             ("exe"  all-the-icons-octicon "file-binary" :v-adjust 0.0 :face all-the-icons-dsilver)
             ("make" all-the-icons-fileicon "gnu"        :face all-the-icons-dorange)
             ("rss"  all-the-icons-octicon "rss"         :height 1.1 :v-adjust 0.0 :face all-the-icons-lorange)
             ("toml" all-the-icons-octicon "settings"    :v-adjust 0.0 :face all-the-icons-yellow)
             ("tsx"  all-the-icons-fileicon "tsx"        :height 1.0 :v-adjust -0.1 :face all-the-icons-cyan-alt)
             ("xpm"  all-the-icons-octicon "file-media"  :v-adjust 0.0 :face all-the-icons-dgreen))))
      (dolist (icon extension-icon-alist)
        (add-to-list 'all-the-icons-extension-icon-alist icon)))

    (let ((regexp-icon-alist
           '(("\\.[bB][iI][nN]$"               all-the-icons-octicon "file-binary" :v-adjust 0.0 :face all-the-icons-yellow)
             ("^config$"                       all-the-icons-octicon "settings"    :v-adjust 0.0 :face all-the-icons-dorange)
             ("\\.\\(ba\\|z\\)shrc$"           all-the-icons-alltheicon "script"   :height 0.9 :face all-the-icons-dpink)
             ("\\.\\(bash\\|zsh\\)*_?profile$" all-the-icons-alltheicon "script"   :height 0.9 :face all-the-icons-dred)
             ("\\.\\(ba\\|z\\)sh_history$"     all-the-icons-alltheicon "script"   :height 0.9 :face all-the-icons-dsilver)
             ("\\.zshenv$"                     all-the-icons-alltheicon "script"   :height 0.9 :face all-the-icons-dred)
             ("\\.org_archive$"                all-the-icons-fileicon "org"        :face all-the-icons-dsilver)
             ("Cask\\'"                        all-the-icons-fileicon "elisp"      :height 1.0 :v-adjust -0.2 :face all-the-icons-blue)
             ("NEWS$"                          all-the-icons-faicon "newspaper-o"  :height 0.9 :v-adjust -0.2)
             ("^Rakefile$"                     all-the-icons-alltheicon "ruby-alt" :face all-the-icons-red))))
      (dolist (icon regexp-icon-alist)
        (add-to-list 'all-the-icons-regexp-icon-alist icon)))

    (let ((mode-icon-alist
           '((xwidget-webkit-mode           all-the-icons-faicon "chrome"          :v-adjust -0.1 :face all-the-icons-blue)
             (bongo-playlist-mode           all-the-icons-material "queue_music"   :height 1.3 :face all-the-icons-green)
             (bongo-library-mode            all-the-icons-material "library_music" :height 1.1 :face all-the-icons-green)
             (simple-mpc-mode               all-the-icons-faicon "music"           :v-adjust -0.1 :face all-the-icons-green)
             (mingus-playlist-mode          all-the-icons-faicon "music"           :v-adjust -0.1 :face all-the-icons-green)
             (mingus-help-mode              all-the-icons-material "music_note"    :height 1.2 :face all-the-icons-green)
             (mingus-browse-mode            all-the-icons-material "library_music" :height 1.1 :face all-the-icons-green)
             (mingus-burn-mode              all-the-icons-material "queue_music"   :height 1.3 :face all-the-icons-green)
             (gnus-group-mode               all-the-icons-fileicon "gnu"           :face all-the-icons-silver)
             (gnus-summary-mode             all-the-icons-octicon "inbox"          :height 1.0 :v-adjust 0.0 :face all-the-icons-orange)
             (gnus-article-mode             all-the-icons-octicon "mail"           :height 1.1 :v-adjust 0.0 :face all-the-icons-lblue)
             (message-mode                  all-the-icons-octicon "mail"           :height 1.1 :v-adjust 0.0 :face all-the-icons-lblue)
             (diff-mode                     all-the-icons-octicon "git-compare"    :v-adjust 0.0 :face all-the-icons-lred)
             (flycheck-error-list-mode      all-the-icons-octicon "checklist"      :height 1.1 :v-adjust 0.0 :face all-the-icons-lred)
             (newsticker-mode               all-the-icons-faicon "rss-square"      :v-adjust -0.1 :face all-the-icons-orange)
             (newsticker-treeview-mode      all-the-icons-faicon "rss-square"      :v-adjust -0.1 :face all-the-icons-orange)
             (newsticker-treeview-list-mode all-the-icons-octicon "rss"            :height 1.1 :v-adjust 0.0 :face all-the-icons-orange)
             (newsticker-treeview-item-mode all-the-icons-octicon "rss"            :height 1.1 :v-adjust 0.0 :face all-the-icons-lorange)
             (conf-mode                     all-the-icons-octicon "settings"       :v-adjust 0.0 :face all-the-icons-yellow)
             (conf-space-mode               all-the-icons-octicon "settings"       :v-adjust 0.0 :face all-the-icons-yellow)
             (gitconfig-mode                all-the-icons-octicon "settings"       :v-adjust 0.0 :face all-the-icons-dorange)
             (forge-topic-mode              all-the-icons-alltheicon "git"         :face all-the-icons-blue)
             (help-mode                     all-the-icons-faicon "info-circle"     :height 1.1 :v-adjust -0.1 :face all-the-icons-purple)
             (helpful-mode                  all-the-icons-faicon "info-circle"     :height 1.1 :v-adjust -0.1 :face all-the-icons-purple)
             (Info-mode                     all-the-icons-faicon "info-circle"     :height 1.1 :v-adjust -0.1)
             (cask-mode                     all-the-icons-fileicon "elisp"         :height 1.0 :v-adjust -0.2 :face all-the-icons-blue)
             (ein:notebooklist-mode         all-the-icons-faicon "book"            :face all-the-icons-lorange)
             (ein:notebook-mode             all-the-icons-fileicon "jupyter"       :height 1.2 :face all-the-icons-orange)
             (ein:notebook-multilang-mode   all-the-icons-fileicon "jupyter"       :height 1.2 :face all-the-icons-dorange)
             (nov-mode                      all-the-icons-faicon "book"            :height 1.0 :v-adjust -0.1 :face all-the-icons-green)
             (gfm-mode                      all-the-icons-octicon "markdown"       :face all-the-icons-lblue)
             (osx-dictionary-mode           all-the-icons-material "library_books" :face all-the-icons-lblue)
             (youdao-dictionary-mode        all-the-icons-material "library_books" :face all-the-icons-lblue)
             (fanyi-mode                    all-the-icons-material "library_books" :face all-the-icons-lblue))))
      (dolist (icon mode-icon-alist)
        (add-to-list 'all-the-icons-mode-icon-alist icon)))))


(use-package simple
  :ensure nil
  :hook ((after-init . size-indication-mode)
         (text-mode . visual-line-mode)
         ((prog-mode markdown-mode conf-mode) . enable-trailing-whitespace))
  :init
  (setq column-number-mode t
        line-number-mode t
        ;; kill-whole-line t               ; Kill line including '\n'
        line-move-visual nil
        track-eol t                     ; Keep cursor at end of lines. Require line-move-visual is nil.
        set-mark-command-repeat-pop t)  ; Repeating C-SPC after popping mark pops it again

  ;; Only list the commands of the current modes
  (when (boundp 'read-extended-command-predicate)
    (setq read-extended-command-predicate
          #'command-completion-default-include-p))

  ;; Visualize TAB, (HARD) SPACE, NEWLINE
  (setq-default show-trailing-whitespace nil) ; Don't show trailing whitespace by default
  (defun enable-trailing-whitespace ()
    "Show trailing spaces and delete on saving."
    (setq show-trailing-whitespace t)
    (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

  ;; Prettify the process list
  (with-no-warnings
    (add-hook 'process-menu-mode-hook
              (lambda ()
                (setq tabulated-list-format
                      (vconcat `(("" ,(if (icon-displayable-p) 2 0)))
                               tabulated-list-format))))

    (defun my-list-processes--prettify ()
      "Prettify process list."
      (when-let ((entries tabulated-list-entries))
        (setq tabulated-list-entries nil)
        (dolist (p (process-list))
          (when-let* ((val (cadr (assoc p entries)))
                      (icon (if (icon-displayable-p)
                                (concat
                                 " "
                                 (all-the-icons-faicon "bolt"
                                                       :height 1.0 :v-adjust -0.05
                                                       :face 'all-the-icons-lblue))
                              " x"))
                      (name (aref val 0))
                      (pid (aref val 1))
                      (status (aref val 2))
                      (status (list status
                                    'face
                                    (if (memq status '(stop exit closed failed))
                                        'error
                                      'success)))
                      (buf-label (aref val 3))
                      (tty (list (aref val 4) 'face 'font-lock-doc-face))
                      (thread (list (aref val 5) 'face 'font-lock-doc-face))
                      (cmd (list (aref val (if emacs/>=27p 6 5)) 'face 'completions-annotations)))
            (push (list p (if emacs/>=27p
                              (vector icon name pid status buf-label tty thread cmd)
                            (vector icon name pid status buf-label tty cmd)))
		          tabulated-list-entries)))))
    (advice-add #'list-processes--refresh :after #'my-list-processes--prettify)))

(provide 'init-ui)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-ui.el ends here
