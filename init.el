;;
;; Core behaviorial changes
;;
;; Avoid constant errors on Windows about the coding system by setting the default to UTF-8.
(set-default-coding-systems 'utf-8)
;; Enable line numbers
(column-number-mode)
(global-display-line-numbers-mode t)
(global-hl-line-mode +1)
;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
;; ALways can type Y or N
(defalias 'yes-or-no-p 'y-or-n-p)
;; Ability to delete selections
(delete-selection-mode t)
;; Ability to move between panes/windows with Shift+arrows
(windmove-default-keybindings)
                                      ;
;; TRAMP
(setq tramp-default-method "sshx")
(setq tramp-verbose 10)
;; from Andrew Tropin's RDE. This fixes the bug where you can't open files with sudo 
(eval-when-compile (require 'tramp))
(with-eval-after-load
    'tramp
    (add-to-list 'tramp-remote-path 'tramp-own-remote-path))


;; "If I edit a file outside of Emacs, the default setting is for Emacs to ask you to reload the file manually. I task Emacs to reload the file automatically."
(global-auto-revert-mode t)

;;
;; Basic visual settings
;;
(if (window-system) (set-frame-size (selected-frame) 124 40)) ; Set a default window size
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar
(setq visible-bell t)       ; Set up the visible bell
(size-indication-mode t)    ; Show filesize
(setq frame-title-format    ; Use the titlebar to show full filename
      '((:eval (if (buffer-file-name)
       (abbreviate-file-name (buffer-file-name))
       "%b"))))

;; Initial theme
(set-face-attribute 'default nil :font "Iosevka SS05 Slab" :height 128)
;; (load-theme 'tango-dark)

;;
;; Initialize package sources
;;
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")))  
(package-initialize)
   (unless package-archive-contents
      (package-refresh-contents))
;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit minions abbrev modus-themes centaur-tabs general evil-tutor evil-collection evil counsel ivy-rich ivy helpful emojify which-key rainbow-delimiters doom-modeline no-littering use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;
;; No Littering
;;
;; Load the feature no-littering as early as possible in your init file. 
;; Make sure you load it at least before you change any path variables using some other method.
(use-package no-littering
   :ensure t
   :config
   ;; One of the most common types of files that Emacs creates automatically is auto-save files. 
   ;; By default, these appear in the current directory of a visited file. 
   ;; No-littering does not change this, but you can add the following code to your init.el file to store these files in the var directory:
   (setq auto-save-file-name-transforms 
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))


;; "Emacs likes to strew its backup and temporary files everywhere. Lets give them a home in the temporary file directory."
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;;
;; Makes startup faster by reducing the frequency of garbage collection
;;
;; Using garbage magic hack.
 (use-package gcmh :config (gcmh-mode 1))
; Setting garbage collection threshold
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)
;; Profile emacs startup
(add-hook 'emacs-startup-hook
    (lambda ()
      (message "*** Emacs loaded in %s with %d garbage collections."
               (format "%.2f seconds"
                       (float-time
                        (time-subtract after-init-time before-init-time)))
               gcs-done)))

;;
;; Packages
;;

;; Evil is an extensible ‘vi’ layer for Emacs. It emulates the main features of Vim, and provides facilities for writing custom extensions.
(use-package evil
  :init      ;; tweak evil's configuration before loading it
  (setq evil-undo-system 'undo-fu)
  (setq evil-want-C-i-jump nil) ; be able to use tab
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode))
;; Evil Collection is also installed since it adds ‘evil’ bindings to parts of Emacs that the standard Evil package does not cover, such as: calenda, help-mode and ibuffer.
(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))
(use-package evil-tutor)

(use-package undo-fu)
(use-package smartparens :config (smartparens-global-mode t) (setq sp-highlight-pair-overlay nil))

(use-package aggressive-indent
  :diminish aggressive-indent-mode
  :config
  (add-hook 'prog-mode-hook #'aggressive-indent-global-mode))

(setq tab-always-indent nil)
(setq-default tab-width 2
              indent-tabs-mode nil)
(use-package company :ensure t :hook (after-init . global-company-mode))

;; General keybindings
;; General.el allows us to set keybindings.  
;; SPC as the prefix key.  General makes setting keybindings (especially with SPC) much easier.
;; All of the keybindings we set later in the config depend on general being loaded.
(use-package general :config (general-evil-setup t))

;; zoom in/out like we do everywhere else.
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

;; General keybindings 
(nvmap :keymaps 'override :prefix "SPC"
       "SPC"   '(counsel-M-x :which-key "M-x")
       "c c"   '(compile :which-key "Compile")
       "c C"   '(recompile :which-key "Recompile")
       "h r r" '((lambda () (interactive) (load-file "~/.emacs.d/init.el")) :which-key "Reload emacs config")
       "t t"   '(toggle-truncate-lines :which-key "Toggle truncate lines"))
;; (nvmap :keymaps 'override :prefix "SPC"
       ; "m *"   '(org-ctrl-c-star :which-key "Org-ctrl-c-star")
       ; "m +"   '(org-ctrl-c-minus :which-key "Org-ctrl-c-minus")
       ; "m ."   '(counsel-org-goto :which-key "Counsel org goto")
       ; "m e"   '(org-export-dispatch :which-key "Org export dispatch")
       ; "m f"   '(org-footnote-new :which-key "Org footnote new")
       ; "m h"   '(org-toggle-heading :which-key "Org toggle heading")
       ; "m i"   '(org-toggle-item :which-key "Org toggle item")
       ; "m n"   '(org-store-link :which-key "Org store link")
       ; "m o"   '(org-set-property :which-key "Org set property")
       ; "m t"   '(org-todo :which-key "Org todo")
       ; "m x"   '(org-toggle-checkbox :which-key "Org toggle checkbox")
       ; "m B"   '(org-babel-tangle :which-key "Org babel tangle")
       ; "m I"   '(org-toggle-inline-images :which-key "Org toggle inline imager")
       ; "m T"   '(org-todo-list :which-key "Org todo list")
       ; "o a"   '(org-agenda :which-key "Org agenda")
       ; )

;; File-related keybindings
(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
       "."     '(find-file :which-key "Find file")
       "f f"   '(find-file :which-key "Find file")
       "f r"   '(counsel-recentf :which-key "Recent files")
       "f s"   '(save-buffer :which-key "Save file")
       "f u"   '(sudo-edit-find-file :which-key "Sudo find file")
       "f y"   '(dt/show-and-copy-buffer-path :which-key "Yank file path")
       "f C"   '(copy-file :which-key "Copy file")
       "f D"   '(delete-file :which-key "Delete file")
       "f R"   '(rename-file :which-key "Rename file")
       "f S"   '(write-file :which-key "Save file as...")
       "f U"   '(sudo-edit :which-key "Sudo edit file"))

;; Eval keybindings
(nvmap :states '(normal visual) :keymaps 'override :prefix "SPC"
       "e b"   '(eval-buffer :which-key "Eval elisp in buffer")
       "e d"   '(eval-defun :which-key "Eval defun")
       "e e"   '(eval-expression :which-key "Eval elisp expression")
       "e l"   '(eval-last-sexp :which-key "Eval last sexression")
       "e r"   '(eval-region :which-key "Eval region"))

;;
;; Interactions
;;
(use-package counsel :after ivy :config (counsel-mode))
(use-package ivy
  :defer 0.1
  :diminish
  :bind
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))
(use-package ivy-rich
  :after ivy
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer)
  (ivy-rich-mode 1)) ;; this gets us descriptions in M-x.
(use-package swiper :after ivy :bind (("C-s" . swiper)("C-r" . swiper)))

;; (use-package helpful
;;   :custom
;;   (counsel-describe-function-function #'helpful-callable)
;;  (counsel-describe-variable-function #'helpful-variable)
;;   :bind
;;   ([remap describe-function] . counsel-describe-function)
;;   ([remap describe-command] . helpful-command)
;;   ([remap describe-variable] . counsel-describe-variable)
;;   ([remap describe-key] . helpful-key))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

;;
;; Pretty graphics
;;

;; (use-package monokai-pro-theme :ensure t :config (load-theme 'monokai-pro t))
(use-package modus-themes
  :ensure
  :init

  ;; Load the theme files before enabling a theme
  (modus-themes-load-themes)
  :config
  ;; Load the theme of your choice:
  (modus-themes-load-operandi))

;;
;; NOTE: The first time you load your configuration on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly:
;;
;; M-x all-the-icons-install-fonts
;; (use-package all-the-icons :if (display-graphic-p))
;; (use-package doom-modeline :ensure t :init (doom-modeline-mode 1) :custom ((doom-modeline-height 15)))

(use-package smart-mode-line
  :ensure t
  :config
  (add-hook 'after-init-hook 'sml/setup))

(use-package highlight-parentheses :ensure t)
(add-hook 'prog-mode-hook #'highlight-parentheses-mode)
(add-hook 'minibuffer-setup-hook #'highlight-parentheses-minibuffer-setup)

;; (use-package emojify :hook (after-init . global-emojify-mode))
;; (add-hook 'after-init-hook #'global-emojify-mode)

;; (use-package centaur-tabs
;;   :demand
;;   :config
;;   (centaur-tabs-mode t)
;;   :bind
;;   ("C-<prior>" . centaur-tabs-backward)
;;   ("C-<next>" . centaur-tabs-forward))
;; (centaur-tabs-change-fonts "Iosevka SS05 Slab" 128)
;; (centaur-tabs-headline-match)
;; (setq centaur-tabs-style "rounded")
;; (setq centaur-tabs-height 48)
;; (setq centaur-tabs-set-bar 'over)
;; (setq centaur-tabs-set-modified-marker t)

(use-package magit
  :bind ("C-M-;" . magit-status)
  :commands (magit-status magit-get-current-branch)
  ;; :custom
  ;; (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  )
