(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 10)

(menu-bar-mode -1)

;; Font
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font Mono" :height 110)


;; Setup Package Manager
(require 'package)

(add-to-list 'package-archives '(("melpa" . "https://melpa.org/packages/")
				("org" . "https://orgmode.org/elpa/")
				("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Theme
(use-package dracula-theme
  :config
  (load-theme 'dracula t))

;; evil
(use-package evil
  :init
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-C-u-scroll t)
  (setq evil-search-module 'swiper)
  :config
  (evil-mode 1))

;; ivy (minibuffer auto complete)
(use-package ivy
  :bind (:map ivy-minibuffer-map
	 ("C-l" . ivy-alt-done)
	 ("TAB" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line))
  :config
  (ivy-mode 1))

(use-package swiper)

;; Line numbers
(column-number-mode)
(setq-default display-line-numbers 'relative)

;; Rainbow Delims
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Auto Tangleing
(add-hook 'org-mode-hook
    (lambda ()
	(add-hook 'after-save-hook #'org-babel-tangle
		nil 'make-it-local)))
