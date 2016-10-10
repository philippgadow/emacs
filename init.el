;;; Commentary
;; Emacs configuration file
;; pgadow@mpp.mpg.de

;; Packages

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(require 'package)
(add-to-list 'package-archives
       '("melpa" . "http://melpa.milkbox.net/packages/") t)


;; General Navigation
;; helm - incremental completion and selection narrowing framework
(require 'helm)
(require 'helm-config)
(helm-mode 1)
(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t
      helm-echo-input-in-header-line t)
(global-set-key (kbd "C-c h") 'helm-command-prefix) ;; set helm-key to C-c h
(global-unset-key (kbd "C-x c"))
(define-key global-map [remap find-file] 'helm-find-files)
(define-key global-map [remap occur] 'helm-occur)
(define-key global-map [remap list-buffers] 'helm-buffers-list)
(define-key global-map [remap dabbrev-expand] 'helm-dabbrev)
(global-set-key (kbd "M-x") 'helm-M-x)

;; projectile - improved navigation in projects
;(projectile-global-mode)

;; ibuffer - use ibuffer for buffer menu
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; improved navigation for minibuffers
(windmove-default-keybindings)

;; multiple cursors
(global-set-key (kbd "C-c C-f") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c C-b") 'mc/mark-previous-like-this)

;; auto-wrap interactive search
(defadvice isearch-search (after isearch-no-fail activate)
  (unless isearch-success
    (ad-disable-advice 'isearch-search 'after 'isearch-no-fail)
    (ad-activate 'isearch-search)
    (isearch-repeat (if isearch-forward 'forward))
    (ad-enable-advice 'isearch-search 'after 'isearch-no-fail)
    (ad-activate 'isearch-search)))

;; Tramp mode for ssh access
(setq tramp-default-method "ssh")


;; General Layout
;; disable startup screen
(setq inhibit-startup-screen t)
;; set layout
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'monokai t)
;; set font
(setq default-frame-alist '((font . "Inconsolata-11")))
(set-face-attribute 'italic nil
                    :family "Inconsolata-Italic")

;; non-blinking cursor
(blink-cursor-mode -1)

;; set more useful frame title
(setq frame-title-format
      '("" invocation-name " - " (:eval (if (buffer-file-name)
                                                    (abbreviate-file-name (buffer-file-name))
                                                  "%b"))))

;; disable menu-bar, scroll-bar and tool-bar
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; volatile-highlights - yanked regions are highlighted
(require 'volatile-highlights)
(volatile-highlights-mode t)

;; golden-ratio - resize multiple windows according to golden ratio
(require 'golden-ratio)
(add-to-list 'golden-ratio-exclude-modes "ediff-mode")
(add-to-list 'golden-ratio-exclude-modes "helm-mode")
(add-to-list 'golden-ratio-exclude-modes "dired-mode")
(add-to-list 'golden-ratio-inhibit-functions 'pl/helm-alive-p)

(defun pl/helm-alive-p ()
  (if (boundp 'helm-alive-p)
      (symbol-value 'helm-alive-p)))
;; do not enable golden-raio in these modes
(setq golden-ratio-exclude-modes '("ediff-mode"
                                   "gud-mode"
                                   "gdb-locals-mode"
                                   "gdb-registers-mode"
                                   "gdb-breakpoints-mode"
                                   "gdb-threads-mode"
                                   "gdb-frames-mode"
                                   "gdb-inferior-io-mode"
                                   "gud-mode"
                                   "gdb-inferior-io-mode"
                                   "gdb-disassembly-mode"
                                   "gdb-memory-mode"
                                   "IELM"
                                   "eshell-mode" "dired-mode"))
(golden-ratio-mode)




;; General Editing
;; set back-up folder
(setq backup-directory-alist '(("." . "~/.emacs.d/.saves")))

;;company - complete anything (text-completion framework)
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)

;;flyspell - autocorrect
(if (executable-find "aspell")
    (progn
      (setq ispell-program-name "aspell")
      (setq ispell-extra-args '("--sug-mode=ultra")))
  (setq ispell-program-name "ispell"))

;; smartparens - auto-complete parenthesis
(require 'smartparens-config)
(setq sp-base-key-bindings 'paredit)
(setq sp-autoskip-closing-pair 'always)
(setq sp-hybrid-kill-entire-symbol nil)
(sp-use-paredit-bindings)

;; clean-aindent-mode - clean unnecessary indents
(require 'clean-aindent-mode)
(add-hook 'prog-mode-hook 'clean-aindent-mode)

;; insert new line at end of buffer
(setq next-line-add-newlines t)

;; autoindent
(define-key global-map (kbd "RET") 'newline-and-indent)

;; Manage Hooks for Modes
;; enable ggtags-mode when programming in c, c++, java, or assembly
(add-hook 'c-mode-common-hook
    (lambda ()
      (when (derived-mode-p 'c-mode 'c++-mode 'java-mode 'asm-mode)
  (ggtags-mode 1))))

;; enable line numbering only in programming modes
(add-hook 'prog-mode-hook 'linum-mode)

;; use flyspell in text and coding modes
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'org-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)


;; Specific Settings for Coding
;; flycheck - syntax checking
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
;(require 'flycheck-tip)

;; yasnippet - provide snippets (TAB: expand statement) for C, C++, Python and many more
;; find documentation here: https://github.com/AndreaCrotti/yasnippet-snippets/tree/master
(require 'yasnippet)
(yas-global-mode 1)

;; set up gdb or debugging
(setq gdb-many-windows t        ; use gdb-many-windows by default
      gdb-show-main t)          ; Non-nil means display source file containing the main routine at startup


;; Specific settings for LaTex

;; auctex - LaTex support in emacs
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)


;; OS specific settings
(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path (append exec-path '("/usr/local/bin")))


;; Custom set variables (set automatically, don't edit)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (auctex lua-mode multiple-cursors helm-gtags helm yasnippet volatile-highlights undo-tree smartparens projectile golden-ratio ggtags flycheck-tip company color-theme-sanityinc-tomorrow clean-aindent-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
