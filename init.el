;;; init --- Emacs configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(when (member "Iosevka" (font-family-list))
  (add-to-list 'default-frame-alist '(font . "Iosevka-12")))

(setq ring-bell-function 'ignore)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

(column-number-mode)
(global-hl-line-mode)
(global-auto-revert-mode)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq indent-tabs-mode nil)

(require 'grep)
(grep-apply-setting
 'grep-find-command
 '("rg -n -H --no-heading -e '' $(git rev-parse --show-toplevel || pwd)" . 27))

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package-ensure)
(setq use-package-always-ensure t)

(use-package nord-theme
  :config (load-theme 'nord t))

(use-package highlight-numbers
  :hook (prog-mode . highlight-numbers-mode)
  :config (set-face-attribute 'highlight-numbers-number nil :foreground "#B48EAD"))

(use-package delight)

(use-package which-key
  :delight
  :config (which-key-mode))

(use-package general
  :config
  (general-evil-setup)
  (general-create-definer leader
    :states '(normal)
    :prefix "SPC"))

(use-package evil
  :init (setq evil-want-Y-yank-to-eol t)
  :config (evil-mode)
  :general
  (leader
    "SPC" 'execute-extended-command
    "f" 'find-file
    "b" 'switch-to-buffer
    "g" 'grep-find
    "e" 'eval-buffer)
  (general-nmap
    "]q" 'next-error
    "[q" 'previous-error))

(use-package evil-surround
  :config (global-evil-surround-mode))
(use-package evil-commentary
  :delight
  :config (evil-commentary-mode))
(use-package undo-tree
  :delight)

(use-package counsel
  :delight ivy-mode
  :init (setq ivy-use-virtual-buffers t)
  :config
  (require 'ivy)
  (ivy-mode))

(use-package smartparens
  :delight
  :config
  (require 'smartparens-config)
  (smartparens-global-mode))

(use-package projectile
  :demand
  :delight
  :config
  (setq projectile-completion-system 'ivy)
  (setq projectile-project-search-path '("~/devel"))
  (projectile-mode)
  :general (leader "p" 'projectile-command-map))

(use-package magit
  :general (leader "m" 'magit-status))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
	 ("\\.md\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package rust-mode
  :general
  (:keymaps 'rust-mode-map
            "C-c C-f" nil
            "C-c c" 'rust-compile
            "C-c f" 'rust-format
            "C-c r" 'rust-run
            "C-c t" 'rust-test))

(use-package terraform-mode)
(use-package go-mode)
(use-package zig-mode)

(defun black-format-buffer () (interactive)
       (shell-command (concat "black " buffer-file-name)))

(general-def python-mode-map
  "C-c f" 'black-format-buffer)

(setq org-directory "~/org")

(provide 'init.el)
;;; init.el ends here
