;;; init --- Emacs configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(font . "Iosevka-12"))

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

(column-number-mode)
(global-hl-line-mode)
(global-auto-revert-mode)
(electric-pair-mode)
(show-paren-mode)

(setq ring-bell-function 'ignore)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq org-directory "~/org")
(setq compilation-read-command nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(add-to-list 'completion-styles 'flex)

(require 'grep)
(grep-apply-setting
 'grep-find-command
 '("rg -n -H --no-heading -e '' $(git rev-parse --show-toplevel || pwd)" . 27))

(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (ansi-color-apply-on-region compilation-filter-start (point-max)))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(recentf-mode)
(setq vc-handled-backends '(Git))
(customize-set-variable
 'tramp-ssh-controlmaster-options
 (concat
  "-o ControlPath=/tmp/ssh-ControlPath-%%r@%%h:%%p "
  "-o ControlMaster=auto -o ControlPersist=yes"))

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
  :config
  (if (daemonp)
      (add-hook 'after-make-frame-functions
                (lambda (frame)
                  (select-frame frame)
                  (load-theme 'nord t)))
    (load-theme 'nord t)))

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
    "k" 'kill-buffer-and-window
    "e" 'eval-buffer
    "g" 'grep-find
    "i" 'counsel-imenu)
  (general-nmap
    "]q" 'next-error
    "[q" 'previous-error))

(use-package evil-surround
  :config (global-evil-surround-mode))
(use-package evil-commentary
  :delight
  :config (evil-commentary-mode))
(use-package evil-lion
  :config (evil-lion-mode))
(use-package undo-tree
  :delight)

(use-package counsel
  :delight ivy-mode
  :init (setq ivy-use-virtual-buffers t)
  :config
  (require 'ivy)
  (ivy-mode))
(use-package amx
  :config
  (setq amx-show-key-bindings nil)
  (amx-mode))

(use-package company
  :delight
  :config (global-company-mode))

(use-package projectile
  :demand
  :delight
  :config
  (setq projectile-completion-system 'ivy)
  (setq projectile-project-search-path '("~/devel"))
  (projectile-mode)
  :general
  (leader "p" 'projectile-command-map)
  (:keymaps 'prog-mode-map
            "C-c c" 'projectile-compile-project
            "C-c t" 'projectile-test-project
            "C-c r" 'projectile-run-project))

(use-package magit
  :general (leader "m" 'magit-file-dispatch))

(use-package yasnippet
  :delight yas-minor-mode
  :config (yas-global-mode))
(use-package yasnippet-snippets)

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

(use-package go-mode
  :general
  (:keymaps 'go-mode-map
            "C-c f" 'gofmt))

(use-package terraform-mode
  :general
  (:keymaps 'terraform-mode-map
            "C-c f" 'terraform-format-buffer))

(use-package zig-mode
  :general
  (:keymaps 'zig-mode-map
            "C-c f" 'zig-format-buffer))

(use-package dockerfile-mode
  :mode (("Dockerfile\\'" . dockerfile-mode)))

(use-package yaml-mode
  :mode (("\\.yml\\'" . yaml-mode)
         ("\\.yaml\\'" . yaml-mode)))

(use-package slime
  :config (setq inferior-lisp-program "sbcl"))

(use-package typescript-mode)

(defun black-format-buffer () (interactive)
       (shell-command (concat "black " buffer-file-name)))

(general-def python-mode-map
  "C-c f" 'black-format-buffer)

(provide 'init.el)
;;; init.el ends here
