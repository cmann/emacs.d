;;; init --- Emacs configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(font . "Iosevka-12"))

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(blink-cursor-mode -1)

(column-number-mode)
(global-hl-line-mode)
(global-auto-revert-mode)
(electric-pair-mode)
(show-paren-mode)
(recentf-mode)

(setq ring-bell-function 'ignore)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq org-directory "~/org")
(setq mode-require-final-newline t)
(setq custom--inhibit-theme-enable nil)
(setq create-lockfiles nil)
(setq vc-make-backup-files t
      version-control t
      backup-by-copying t
      kept-new-versions 10
      kept-old-versions 0
      delete-old-versions t
      backup-directory-alist '(("." . "~/.emacs.d/backups/")))

(setq-default indent-tabs-mode nil
              tab-width 4)

(add-to-list 'completion-styles 'flex)

(add-hook 'dired-mode-hook 'auto-revert-mode)

(require 'grep)
(grep-apply-setting
 'grep-find-command
 '("rg -n -H --no-heading -e '' $(git rev-parse --show-toplevel || pwd)" . 27))

(require 'ansi-color)
(add-hook
 'compilation-filter-hook
 (lambda ()
   (when (eq major-mode 'compilation-mode)
     (ansi-color-apply-on-region compilation-filter-start (point-max)))))
(setq compilation-read-command nil
      compilation-always-kill t)

(setq vc-handled-backends '(Git))
(customize-set-variable
 'tramp-ssh-controlmaster-options
 (concat
  "-o ControlPath=/tmp/ssh-ControlPath-%%r@%%h:%%p "
  "-o ControlMaster=auto "
  "-o ControlPersist=yes "))

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
  :init (setq nord0 "#2E3440"
              nord1 "#3B4252"
              nord2 "#434C5E"
              nord3 "#4C566A"
              nord4 "#D8DEE9"
              nord5 "#E5E9F0"
              nord6 "#ECEFF4"
              nord7 "#8FBCBB"
              nord8 "#88C0D0"
              nord9 "#81A1C1"
              nord10 "#5E81AC"
              nord11 "#BF616A"
              nord12 "#D08770"
              nord13 "#EBCB8B"
              nord14 "#A3BE8C"
              nord15 "#B48EAD")
  :config
  (if (daemonp)
      (add-hook 'after-make-frame-functions
                (lambda (frame)
                  (select-frame frame)
                  (load-theme 'nord t)))
    (load-theme 'nord t)))

(use-package highlight-numbers
  :hook (prog-mode . highlight-numbers-mode)
  :config (custom-set-faces `(highlight-numbers-number ((t (:foreground ,nord15))))))

(use-package delight)

(use-package which-key
  :delight
  :config (which-key-mode))

(use-package general
  :config
  (general-evil-setup)
  (general-create-definer leader
    :states '(normal visual)
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
    "i" 'counsel-imenu
    "o" 'other-window
    "1" 'delete-other-windows
    "2" 'split-window-below
    "3" 'split-window-right
    "0" 'delete-window)
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

(use-package flyspell
  :hook ((text-mode . flyspell-mode)
         (org-mode  . flyspell-mode)
         (prog-mode . flyspell-prog-mode))
  :config
  (custom-set-faces
   `(flyspell-incorrect ((t (:weight bold :underline (:color ,nord11 :style wave))))))
  (setq ispell-program-name "aspell"
        ispell-extra-args '("--sug-mode=ultra")
        flyspell-prog-text-faces (delq 'font-lock-string-face flyspell-prog-text-faces)))

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

(use-package ace-jump-mode
  :config
  (custom-set-faces
   `(ace-jump-face-background ((t (:foreground ,nord3))))
   `(ace-jump-face-foreground ((t (:foreground ,nord8)))))
  (setq ace-jump-mode-scope 'global)
  :general (leader "j" 'ace-jump-word-mode))

(use-package company
  :delight
  :config (global-company-mode))

(use-package projectile
  :delight
  :config
  (setq projectile-completion-system 'ivy)
  (setq projectile-project-search-path '("~/devel"))
  (projectile-mode)
  :general
  (leader "p" '(:keymap projectile-command-map))
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

(use-package sh-script
  :config (custom-set-faces `(sh-heredoc ((t (:foreground ,nord14))))))

(use-package rust-mode
  :general (:keymaps 'rust-mode-map
                     "C-c C-f" nil
                     "C-c c" 'rust-compile
                     "C-c f" 'rust-format
                     "C-c r" 'rust-run
                     "C-c t" 'rust-test))

(use-package go-mode
  :hook (go-mode . (lambda () (add-hook 'before-save-hook 'gofmt-before-save)))
  :general (:keymaps 'go-mode-map
                     "C-c f" 'gofmt))

(use-package terraform-mode
  :general (:keymaps 'terraform-mode-map
                     "C-c f" 'terraform-format-buffer))

(use-package zig-mode
  :general (:keymaps 'zig-mode-map
                     "C-c f" 'zig-format-buffer))

(use-package slime
  :config (setq inferior-lisp-program "sbcl"))

(use-package yaml-mode)
(use-package markdown-mode)
(use-package dockerfile-mode)
(use-package protobuf-mode)
(use-package typescript-mode)

(defun black-format-buffer () (interactive)
       (shell-command (concat "black " buffer-file-name)))

(general-def python-mode-map
  "C-c f" 'black-format-buffer)

(provide 'init.el)
;;; init.el ends here
