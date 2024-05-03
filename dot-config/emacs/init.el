(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; Block until current queue processed.
(elpaca-wait)

(use-package evil
  :after which-key
  :ensure t
  :custom
  (evil-undo-system 'undo-redo)
  (evil-want-C-d-scroll t)
  (evil-want-C-u-scroll t)
  (evil-search-module 'swiper)
  ; follow is required by evil-collection
  (evil-want-integration t)
  (evil-want-keybinding nil)
  :init
  (evil-mode 1)
  :config
  ; Define leader key
  (evil-set-leader nil (kbd "SPC"))
  ; Better vim keys
  (evil-define-key '(normal visual) 'global
    (kbd "C-u") (lambda () (interactive) (evil-scroll-up 0) (evil-scroll-line-to-center nil))
    (kbd "C-d") (lambda () (interactive) (evil-scroll-down 0) (evil-scroll-line-to-center nil))
  )
  ; QUICK ACTIONS ;
  (evil-define-key 'normal 'global
    (kbd "<leader> RET") 'dashboard-open
    (kbd "<leader> t") 'vterm
    (kbd "C-o") 'find-file
    (kbd "C-e") 'treemacs-select-window
    (kbd "C-i") 'lsp-ui-imenu
    (kbd "<leader> r") (lambda () (interactive)
                            (load-file "~/.config/emacs/init.el")
                            (ignore (elpaca-process-queues)))
  )
  ; PROJECTILE ;
  (evil-define-key 'normal 'global
    (kbd "C-p") 'projectile-find-file
    (kbd "C-S-o") 'projectile-switch-project
    (kbd "C-S-f") 'projectile-ripgrep
  )
  ; BUFFER MANAGEMENT ;
  (which-key-add-key-based-replacements "SPC b" "Buffer Management")
  (evil-define-key 'normal 'global
    (kbd "<leader> b l") 'ibuffer
    (kbd "<leader> b i") 'switch-to-buffer
    (kbd "<leader> b j") 'next-buffer
    (kbd "<leader> b k") 'previous-buffer
    (kbd "<leader> b h") 'kill-current-buffer
  )
  ; LSP ;
  (which-key-add-key-based-replacements "SPC l" "LSP hotkeys")
  (evil-define-key 'normal 'global
    (kbd "<leader> l d") 'lsp-find-definition
    (kbd "<leader> l f") 'lsp-find-references
    (kbd "<leader> l .") 'lsp-execute-code-action
    (kbd "<leader> l r") 'lsp-rename
    (kbd "<leader> l R") 'lsp-workspace-restart
    (kbd "<leader> l k") 'lsp-ui-doc-toggle
    (kbd "<leader> l TAB") 'lsp-ui-doc-focus-frame
    (kbd "<leader> l <backtab>") 'lsp-ui-doc-unfocus-frame
  )
)

(use-package evil-collection
  :after evil
  :ensure t
  :custom
  (evil-collection-setup-debugger-keys nil)
  (evil-collection-want-find-usages-bindings nil)
  :init
  (evil-collection-init))

(global-set-key [escape] 'keyboard-escape-quit)

(global-set-key (kbd "RET") 'newline)
(global-set-key (kbd "C-j") 'newline-and-indent)

(use-package which-key
  :ensure t
  :config
  (which-key-mode)
)

(set-locale-environment "en_US.UTF-8")
(set-language-environment "English")
(setenv "LANG" "en_US.UTF-8")

(use-package dracula-theme
  :ensure t
  :config
  (load-theme 'dracula t)
)

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-hud t)
  (doom-modeline-modal-modern-icon nil)
  (doom-modeline-always-show-macro-register t)
  (doom-modeline-unicode-fallback t)
  (doom-modeline-enable-word-count t)
  (doom-modeline-github t)
)

(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font-11"))
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font-11")

(use-package ligature
  :ensure t
  :config
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  (global-ligature-mode 't)
)

(use-package nerd-icons
  :ensure t
 )

(use-package all-the-icons :ensure t)

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)

(menu-bar-mode -1)

(setq-default vertical-scroll-bar nil)

;; Line numbers
(column-number-mode)
(setq-default display-line-numbers 'relative)

;; Disable dialogs/popup windows'
(setq use-file-dialog nil)   ;; No file dialog
(setq use-dialog-box nil)    ;; No dialog box
(setq pop-up-windows nil)    ;; No popup windows

;; remove line wrap
(setq-default truncate-lines t)

; little bit of margin
(setq-default left-margin-width 1 right-margin-width 1)
(set-window-buffer nil (current-buffer))

(set-frame-parameter nil 'alpha-background 75)
(add-to-list 'default-frame-alist '(alpha-background . 75))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :ensure t
  :hook org-mode prog-mode)

(use-package ivy
  :ensure t
  :bind (:map ivy-minibuffer-map
          ("C-l" . ivy-alt-done)
          ("TAB" . ivy-alt-done)
          ("C-j" . ivy-next-line)
          ("C-k" . ivy-previous-line))
  :config
  (setq ivy-switch-buffer-map nil) ; Remove default kill buffer binding
  (ivy-mode 1))

(use-package swiper :ensure t)

(use-package projectile
  :ensure t
  :config
  (projectile-mode 1))

(use-package ripgrep :ensure t)

(use-package dashboard
  :ensure t
  :requires (nerd-icons projectile)
  :hook (dashboard-mode . (lambda () (setq display-line-numbers nil)))
  :custom
  (dashboard-banner-logo-title nil)
  (dashboard-startup-banner "~/.config/emacs/logo.txt")
  (dashboard-display-icons-p t)
  (dashboard-center-content t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-projects-backend 'projectile)
  (dashboard-items '((projects . 10)
                     (recents  . 10)))
  :config
  (dashboard-setup-startup-hook))

(setq initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name)))

(use-package org
  :after evil
  :ensure t
  :custom
  (org-hide-emphasis-markers t)
  (org-startup-indented t)
  (org-startup-with-latex-preview t)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(0.5))
  (org-edit-src-content-indentation 0)
  (org-hide-leading-stars t)
  (org-return-follows-link t)
  :config
  (custom-set-faces
    '(org-level-1 ((t (:inherit outline-1 :height 1.5))))
    '(org-level-2 ((t (:inherit outline-2 :height 1.3))))
    '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
    '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
    '(org-level-5 ((t (:inherit outline-5 :height 1.0))))
  )
  (evil-define-key 'normal 'org-mode-map (kbd "<leader> i") 'org-edit-latex-fragment)
)

(use-package org-superstar
  :ensure t
  :after org
  :hook (org-mode . (lambda () (org-superstar-mode 1)))
  :config
  (setq org-superstar-leading-bullet "  ")
  (setq org-superstar-special-todo-items t))

(setq org-format-latex-options
  '(:foreground default
    :background default
    :scale 3
    :html-foreground "Black"
    :html-background "Transparent"
    :html-scale 1.0
    :matchers ("begin" "$1" "$" "$$" "\\(" "\\[")))
(add-hook 'org-mode-hook
  (lambda ()
      (add-hook 'after-save-hook 'org-latex-preview nil 'make-local)))

(add-hook 'org-mode-hook
  (lambda ()
      (add-hook 'after-save-hook (lambda () (org-display-inline-images)))))

(add-hook 'org-mode-hook
    (lambda ()
        (add-hook 'after-save-hook #'org-babel-tangle
                nil 'make-it-local)))

(use-package toc-org
  :ensure t
  :after org
  :hook (org-mode . toc-org-mode)
  :custom
  (toc-org-max-depth 3) ; default 2
)

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'right
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (when treemacs-python-executable
      (treemacs-git-commit-diff-mode t))

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil)))

(use-package treemacs-evil
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package vterm
  :ensure t
  :hook (vterm-mode . (lambda () (setq display-line-numbers nil)))
  :custom
  (vterm-kill-buffer-on-exit t)
)

(use-package evil-anzu
  :ensure t
  :after (evil)
)
(use-package anzu
  :ensure t
  :config
  (global-anzu-mode +1)
)

(use-package golden-ratio
  :ensure t
  :custom
  (golden-ratio-auto-scale t)
  :config
  (setq golden-ratio-extra-commands
    (append golden-ratio-extra-commands
    '(evil-window-left
      evil-window-right
      evil-window-up
      evil-window-down
      buf-move-left
      buf-move-right
      buf-move-up
      buf-move-down
      window-number-select
      select-window
      select-window-1
      select-window-2
      select-window-3
      select-window-4
      select-window-5
      select-window-6
      select-window-7
      select-window-8
      select-window-9)
    )
  )
  (golden-ratio-mode 1)
)

(require 'treesit)
(customize-set-variable 'treesit-font-lock-level 4)

(use-package treesit-auto
  :ensure t
  :config
  (global-treesit-auto-mode))

(use-package markdown-mode :ensure t)

(use-package lsp-mode
  :ensure t
  :hook (
    (css-ts-mode . lsp)
  )
  :commands lsp
)

(use-package lsp-ui
  :ensure t
  :hook (lsp-ui-doc-frame-mode . (lambda () (setq display-line-numbers nil)))
  :custom
  (lsp-ui-doc-position 'at-point)
  :config
  (add-to-list 'lsp-ui-doc-frame-parameters '(alpha-background . 100))
)

(use-package web-mode
  :ensure t
  :hook (
    (html-mode . web-mode)
    (mhtml-mode . web-mode)
    (web-mode . lsp)
  )
)

(use-package lsp-pyright
  :ensure t
  :hook
  (python-ts-mode . (lambda () (lsp) ));(flycheck-add-next-checker 'lsp 'python-pylint)))
  :init
  (setq lsp-pyright-multi-root nil)
)

(use-package lsp-java
  :ensure t
  :hook (java-ts-mode . lsp)
)

(setq backup-directory-alist '(("." . "~/.config/emacs/backup"))
      backup-by-copying      t  ; Don't de-link hard links
      version-control        t  ; Use version numbers on backups
      delete-old-versions    t  ; Automatically delete excess backups:
      kept-new-versions      20 ; how many of the newest versions to keep
      kept-old-versions      2) ; and how many of the old

(setq custom-file "~/.config/emacs/emacs-custom.el")
(ignore-errors (load custom-file))

(add-hook 'prog-mode-hook 'hs-minor-mode)

(global-auto-revert-mode)

(use-package flycheck
  :ensure t
  :config
  (global-flycheck-mode)
)

(use-package company
  :ensure t
  :config
  (company-mode)
)

(setq-default indent-tabs-mode nil)

(add-hook 'before-save-hook
    (lambda ()
        (whitespace-cleanup)
    )
)
