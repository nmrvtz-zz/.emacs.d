;;; init.el --- Initialization file for Emacs
;;; Commentary:
;;; Suitable for web and clojure development

;;; Code:
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6
      file-name-handler-alist-original file-name-handler-alist
      file-name-handler-alist nil
      site-run-file nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 20000000
                  gc-cons-percentage 0.1
                  file-name-handler-alist file-name-handler-alist-original)
            (makunbound 'file-name-handler-alist-original)))

(add-hook 'minibuffer-setup-hook (lambda () (setq gc-cons-threshold 40000000)))
(add-hook 'minibuffer-exit-hook (lambda ()
                                  (garbage-collect)
                                  (setq gc-cons-threshold 20000000)))

;; Fullscreen
;; WORKAROUND: To address blank screen issue with child-frame in fullscreen
(add-hook 'window-setup-hook (lambda ()
                               (setq ns-use-native-fullscreen nil)))

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"   . "http://orgmode.org/elpa/")
                         ("gnu"   . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; Bootstrap `use-package`
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(global-set-key (kbd "C-x k") 'kill-this-buffer)
(add-hook 'before-save-hook 'whitespace-cleanup)

(setq-default tab-width 2)

;; Recompile
(defun my/byte-compile
    ()
    "Byte compile config."
    (byte-recompile-directory (expand-file-name "~/.emacs.d") 0))

;; Set default font
(set-face-attribute 'default nil
                    :family "Monoid Nerd Font"
                    :height 120
                    :weight 'normal
                    :width 'normal)

;; Disable lock files
(setq create-lockfiles nil)

;; y-n instead of yes/no
(fset 'yes-or-no-p 'y-or-n-p)

;; Line numbers
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(use-package diminish
  :ensure t)

(use-package better-defaults
             :ensure t)

(use-package exec-path-from-shell
             :ensure t
             :init
             (setq exec-path-from-shell-check-startup-files nil
                   exec-path-from-shell-variables '("PATH" "MANPATH" "PYTHONPATH" "GOPATH")
                   exec-path-from-shell-arguments '("-l"))
             (exec-path-from-shell-initialize))

;; Editing
(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode 1)
    (show-paren-mode t)))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package crux
  :ensure t
  :bind
  ("C-k" . crux-smart-kill-line)
  ("C-c n" . crux-cleanup-buffer-or-region)
  ("C-c f" . crux-recentf-find-file)
  ("C-a" . crux-move-beginning-of-line))

(use-package avy
  :ensure t
  :bind (("C-'" . avy-goto-char)
         ("M-g w" . avy-goto-word-0))
  :config
  (setq avy-background t))

(use-package dtrt-indent
  :ensure t
  :commands dtrt-indent-mode
  :hook (after-init . dtrt-indent-global-mode))

(make-variable-buffer-local 'undo-tree-visualizer-diff)
(use-package undo-tree
  :ensure t
  :diminish
  :hook (after-init . global-undo-tree-mode)
  :init (setq undo-tree-visualizer-timestamps t
              undo-tree-visualizer-diff t
              undo-tree-enable-undo-in-region nil
              undo-tree-auto-save-history nil
              undo-tree-history-directory-alist
              `(("." . ,(locate-user-emacs-file "undo-tree-hist/")))))

(use-package imenu
  :ensure nil
  :bind (("C-." . imenu)))

(use-package goto-chg
  :ensure t
  :bind ("C-," . goto-last-change))

; Themes
;; (use-package base16-theme
;;   :ensure t
;;   :config
;;   (load-theme 'base16-nord t))

;; (use-package kaolin-themes
;;   :ensure t
;;   :config
;;   (load-theme 'kaolin-galaxy t))

(use-package doom-themes
  :ensure t
  :defines doom-themes-treemacs-theme
  :init
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  :config
  (doom-themes-visual-bell-config)
  (setq doom-themes-treemacs-theme "doom-colors")
  (doom-themes-treemacs-config)
  (load-theme 'doom-palenight t))

(use-package solaire-mode
  :ensure t
  :defines solaire-mode-remap-fringe
  :hook (((change-major-mode after-revert ediff-prepare-buffer) . turn-on-solaire-mode)
         (minibuffer-setup . solaire-mode-in-minibuffer)
         (after-load-theme . solaire-mode-swap-bg))
  :config
  (setq solaire-mode-remap-fringe nil)
  (solaire-global-mode 1)
  (solaire-mode-swap-bg))

(use-package highlight-numbers
  :ensure t
  :hook (prog-mode . highlight-numbers-mode))

(use-package highlight-operators
  :ensure t
  :hook (rjsx-mode . highlight-operators-mode))

(use-package highlight-escape-sequences
  :ensure t
  :hook (prog-mode . hes-mode))

;; Modeline
;; (use-package smart-mode-line
;;   :ensure t
;;   :config
;;   (setq sml/theme 'respectful)
;;   (setq sml/no-confirm-load-theme t)
;;   (sml/setup))

(use-package all-the-icons
  :ensure t
  :init
  (setq inhibit-compacting-font-caches t))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

;;Tabs
(use-package centaur-tabs
  :ensure t
  :demand
  :init (setq centaur-tabs-set-bar 'over)
  :config
  (centaur-tabs-mode +1)
  (centaur-tabs-headline-match)
  (setq centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker " ● "
        centaur-tabs-cycle-scope 'tabs
        centaur-tabs-height 30
        centaur-tabs-set-icons t
        centaur-tabs-close-button " × ")
  (centaur-tabs-change-fonts "Arial" 130)
  :bind
  ("C-S-<tab>" . centaur-tabs-backward)
  ("C-<tab>" . centaur-tabs-forward))

;; Helm
(use-package helm
  :ensure t
  :defines (helm-command-prefix-key
            helm-M-x-fuzzy-match
            helm-buffers-fuzzy-matching
            helm-recentf-fuzzy-match
            helm-semantic-fuzzy-match
            helm-imenu-fuzzy-match
            helm-locate-fuzzy-match
            helm-apropos-fuzzy-match
            helm-lisp-fuzzy-completion
            helm-mode-fuzzy-match
            helm-completion-in-region-fuzzy-match
            helm-candidate-number-list
            helm-window-prefer-horizontal-split)
  :bind (("M-x" . helm-M-x)
         ("M-y" . helm-show-kill-ring)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-mini)
         ("C-c p s s" . helm-projectile-ag))
         ;; ("C-x b" . helm-buffers-list))
  :config
  (require 'helm-config)
  (setq helm-split-window-inside-p t
    helm-move-to-line-cycle-in-source t)
  (setq helm-autoresize-max-height 0)
  (setq helm-autoresize-min-height 20)
  (setq helm-command-prefix-key "C-c h")
  (setq helm-M-x-fuzzy-match t)
  (setq helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match    t)
  (setq helm-semantic-fuzzy-match t
        helm-imenu-fuzzy-match    t)
  (setq helm-locate-fuzzy-match t)
  (setq helm-apropos-fuzzy-match t)
  (setq helm-lisp-fuzzy-completion t)
  (setq helm-mode-fuzzy-match t)
  (setq helm-completion-in-region-fuzzy-match t)
  (setq helm-candidate-number-list 50)
  (setq helm-window-prefer-horizontal-split t)
  (setq helm-grep-ag-command
         "rg --color=always --colors 'match:fg:black' --colors 'match:bg:yellow' --smart-case --no-heading --line-number %s %s %s"
         helm-grep-ag-pipe-cmd-switches
         '("--colors 'match:fg:black'" "--colors 'match:bg:yellow'"))
  (helm-autoresize-mode 1)
  (helm-mode 1))

(use-package helm-descbinds
  :ensure t
  :config
  (helm-descbinds-mode))

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on))

(use-package helm-ag
  :ensure t)

;; Projectile
(use-package projectile
  :ensure t
  :diminish projectile-mode
  :commands projectile-mode
  :bind (("C-c p f" . helm-projectile-find-file)
         ("C-c p p" . helm-projectile-switch-project))
         ;; ("C-c p s" . projectile-save-project-buffers))
  :init
  (setq projectile-completion-system 'helm)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode))

(use-package treemacs
  :ensure t
  :defer t
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-follow-delay             0.2
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-desc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-width                         35)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

;; (use-package treemacs-icons-dired
;;   :after treemacs dired
;;   :ensure t
;;   :config (treemacs-icons-dired-mode))

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)


;; Which Key
(use-package which-key
  :ensure t
  :diminish whick-key-mode
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  :config
  (which-key-mode))

;; Javascript
(use-package rjsx-mode
  :ensure t
  :config
  (unbind-key "M-." rjsx-mode-map)
  (add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode)))

(use-package typescript-mode
  :ensure t)

;; Clojure
(use-package clojure-mode
  :ensure t)

(use-package cider
  :ensure t
  :defines
  nrepl-hide-special-buffers
  cider-eval-result-prefix
  cider-font-lock-dynamically
  :config
  (setq
   nrepl-hide-special-buffers t
   cider-eval-result-prefix ";; => "
   cider-font-lock-dynamically '(macro core function var)))

;; Company
(use-package company
  :diminish company-mode
  :defines (company-dabbrev-ignore-case company-dabbrev-downcase)
  :commands company-abort
  :bind (("M-/" . company-complete)
         ("<backtab>" . company-yasnippet)
         :map company-active-map
         ("C-p" . company-select-previous)
         ("C-n" . company-select-next)
         ("<tab>" . company-complete-common-or-cycle)
         ("<backtab>" . my-company-yasnippet)
         ;; ("C-c C-y" . my-company-yasnippet)
         :map company-search-map
         ("C-p" . company-select-previous)
         ("C-n" . company-select-next))
  :hook (after-init . global-company-mode)
  :init
  (defun my-company-yasnippet ()
    (interactive)
    (company-abort)
    (call-interactively 'company-yasnippet))
  :config
  (setq company-tooltip-align-annotations t
        company-tooltip-limit 12
        company-idle-delay 0
        company-echo-delay (if (display-graphic-p) nil 0)
        company-minimum-prefix-length 2
        company-require-match nil
        company-dabbrev-ignore-case nil
        company-dabbrev-downcase nil
        company-transformers '(company-sort-by-backend-importance)))

(use-package company-box
  :ensure t
  :defer t
  :after (all-the-icons company)
  :init
  (setq company-box-icons-alist 'company-box-icons-all-the-icons)
  :hook (company-mode . company-box-mode)
  :config
  (setq company-box-backends-colors '((company-lsp      . "#e0f9b5")
                                      (company-elisp    . "#e0f9b5")
                                      (company-files    . "#ffffc2")
                                      (company-keywords . "#ffa5a5")
                                      (company-capf     . "#bfcfff")
                                      (company-dabbrev  . "#bfcfff")))
  (setq company-box-icons-unknown (concat (all-the-icons-material "find_in_page") " "))
  (setq company-box-icons-elisp
        (list
         (concat (all-the-icons-faicon "tag") " ")
         (concat (all-the-icons-faicon "cog") " ")
         (concat (all-the-icons-faicon "cube") " ")
         (concat (all-the-icons-material "color_lens") " ")))
  (setq company-box-icons-yasnippet (concat (all-the-icons-faicon "bookmark") " "))
  (setq company-box-icons-lsp
        `((1 .  ,(concat (all-the-icons-faicon   "text-height")    " ")) ;; Text
          (2 .  ,(concat (all-the-icons-faicon   "tags")           " ")) ;; Method
          (3 .  ,(concat (all-the-icons-faicon   "tag" )           " ")) ;; Function
          (4 .  ,(concat (all-the-icons-faicon   "tag" )           " ")) ;; Constructor
          (5 .  ,(concat (all-the-icons-faicon   "cog" )           " ")) ;; Field
          (6 .  ,(concat (all-the-icons-faicon   "cog" )           " ")) ;; Variable
          (7 .  ,(concat (all-the-icons-faicon   "cube")           " ")) ;; Class
          (8 .  ,(concat (all-the-icons-faicon   "cube")           " ")) ;; Interface
          (9 .  ,(concat (all-the-icons-faicon   "cube")           " ")) ;; Module
          (10 . ,(concat (all-the-icons-faicon   "cog" )           " ")) ;; Property
          (11 . ,(concat (all-the-icons-material "settings_system_daydream") " ")) ;; Unit
          (12 . ,(concat (all-the-icons-faicon   "cog" )           " ")) ;; Value
          (13 . ,(concat (all-the-icons-material "storage")        " ")) ;; Enum
          (14 . ,(concat (all-the-icons-material "closed_caption") " ")) ;; Keyword
          (15 . ,(concat (all-the-icons-faicon   "bookmark")       " ")) ;; Snippet
          (16 . ,(concat (all-the-icons-material "color_lens")     " ")) ;; Color
          (17 . ,(concat (all-the-icons-faicon   "file-text-o")    " ")) ;; File
          (18 . ,(concat (all-the-icons-material "refresh")        " ")) ;; Reference
          (19 . ,(concat (all-the-icons-faicon   "folder-open")    " ")) ;; Folder
          (20 . ,(concat (all-the-icons-material "closed_caption") " ")) ;; EnumMember
          (21 . ,(concat (all-the-icons-faicon   "square")         " ")) ;; Constant
          (22 . ,(concat (all-the-icons-faicon   "cube")           " ")) ;; Struct
          (23 . ,(concat (all-the-icons-faicon   "calendar")       " ")) ;; Event
          (24 . ,(concat (all-the-icons-faicon   "square-o")       " ")) ;; Operator
          (25 . ,(concat (all-the-icons-faicon   "arrows")         " "))) ;; TypeParameter
        ))

(use-package company-lsp
  :ensure t
  :init (setq company-lsp-cache-candidates 'auto
              company-lsp-async t))

(use-package lsp-mode
  :diminish lsp-mode
  :ensure t
  :hook (prog-mode . lsp-deferred)
  :bind (:map lsp-mode-map
              ("C-c C-d" . lsp-describe-thing-at-point))
  :init (setq lsp-auto-guess-root t
              lsp-prefer-flymake nil
              ;; lsp-enable-indentation nil
              lsp-enable-on-type-formatting nil)
  :commands lsp)

(use-package lsp-ui
  :ensure t
  :functions my-lsp-ui-imenu-hide-mode-line
  :commands lsp-ui-doc-hide
  :custom-face
  (lsp-ui-doc-background ((t (:background ,(face-background 'tooltip)))))
  (lsp-ui-sideline-code-action ((t (:inherit warning))))
  :bind (:map lsp-ui-mode-map
              ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
              ([remap xref-find-references] . lsp-ui-peek-find-references)
              ("C-c u" . lsp-ui-imenu))
  :init (setq lsp-ui-doc-enable nil
              lsp-ui-doc-use-webkit nil
              lsp-ui-doc-delay 1.0
              lsp-ui-doc-include-signature t
              lsp-ui-doc-position 'at-point
              lsp-ui-doc-border (face-foreground 'default)

              lsp-ui-sideline-enable nil
              lsp-ui-sideline-show-hover nil
              lsp-ui-sideline-show-diagnostics nil
              lsp-ui-sideline-ignore-duplicate t

              lsp-eldoc-enable-hover nil)
  :config
  (flycheck-add-next-checker 'lsp-ui 'javascript-eslint)
  ;; (add-to-list 'lsp-ui-doc-frame-parameters '(right-fringe . 8))
  (add-to-list 'lsp-ui-doc-frame-parameters '(left . -20))

  ;; `C-g'to close doc
  (advice-add #'keyboard-quit :before #'lsp-ui-doc-hide)

  ;; Reset `lsp-ui-doc-background' after loading theme
  (add-hook 'after-load-theme-hook
            (lambda ()
              (setq lsp-ui-doc-border (face-foreground 'default))
              (set-face-background 'lsp-ui-doc-background
                                   (face-background 'tooltip))))

  ;; WORKAROUND Hide mode-line of the lsp-ui-imenu buffer
  ;; @see https://github.com/emacs-lsp/lsp-ui/issues/243
  (defun my-lsp-ui-imenu-hide-mode-line ()
    "Hide the mode-line in lsp-ui-imenu."
    (setq mode-line-format nil))
  (advice-add #'lsp-ui-imenu :after #'my-lsp-ui-imenu-hide-mode-line))

(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :config
  (defun my/use-eslint-from-node-modules ()
    (let* ((root (locate-dominating-file
                  (or (buffer-file-name) default-directory)
                  "node_modules"))
           (eslint (and root
                        (expand-file-name "node_modules/eslint/bin/eslint.js"
                                          root))))
      (when (and eslint (file-executable-p eslint))
        (setq-local flycheck-javascript-eslint-executable eslint))))

  (setq flycheck-indication-mode 'right-fringe)
  (when (fboundp 'define-fringe-bitmap)
    (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
      [16 48 112 240 112 48 16] nil nil 'center))

  (add-hook 'after-init-hook #'global-flycheck-mode)
  (add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules))

(use-package yasnippet
  :ensure t)

(use-package yasnippet-snippets
  :ensure t)

(use-package dashboard
  :ensure t
  :after (all-the-icons projectile)
  :bind
  ;; https://github.com/rakanalh/emacs-dashboard/issues/45
  (:map dashboard-mode-map
        ("<down-mouse-1>" . nil)
        ("<mouse-1>"      . widget-button-click)
        ("<mouse-2>"      . widget-button-click)
        ("<up>"           . widget-backward)
        ("<down>"         . widget-forward))
  :diminish (dashboard-mode page-break-lines-mode)
  :hook ((dashboard-mode . (lambda () (setq-local tab-width 1))))
  :init
  (setq dashboard-startup-banner    'official
        dashboard-center-content    t
        dashboard-show-shortcuts    t
        dashboard-set-heading-icons t
        dashboard-set-file-icons    t
        dashboard-set-init-info     t
        show-week-agenda-p          t
        dashboard-items '((recents   . 10)
                          (bookmarks . 5)
                          (projects  . 5)
                          (agenda    . 5)))
  ;; (registers . 5 )
  (dashboard-setup-startup-hook)
  :config
  (use-package page-break-lines :ensure t))

(use-package magit
  :ensure t
  :defer 5
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)
         ("C-c M-g" . magit-file-popup))
  :config
  ;; (setq eieio-backward-compatibility nil)

  (if (fboundp 'transient-append-suffix)
      ;; Add switch: --tags
      (transient-append-suffix 'magit-fetch
        "-p" '("-t" "Fetch all tags" ("-t" "--tags"))))

  ;; Access Git forges from Magit
  (when (executable-find "cc")
    (use-package forge
      :ensure t
      :demand)))

(use-package diff-hl
  :ensure t
  :defines (diff-hl-margin-symbols-alist desktop-minor-mode-table)
  :commands diff-hl-magit-post-refresh
  :functions  my-diff-hl-fringe-bmp-function
  :custom-face (diff-hl-change ((t (:foreground ,(face-background 'highlight)))))
  :bind (:map diff-hl-command-map
         ("SPC" . diff-hl-mark-hunk))
  :hook ((after-init . global-diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :config
  ;; Highlight on-the-fly
  (diff-hl-flydiff-mode 1)

  ;; Set fringe style
  (setq-default fringes-outside-margins t)

  (defun my-diff-hl-fringe-bmp-function (_type _pos)
    "Fringe bitmap function for use as `diff-hl-fringe-bmp-function'."
    (define-fringe-bitmap 'my-diff-hl-bmp
      (vector #b11100000)
      1 8
      '(center t)))
  (setq diff-hl-fringe-bmp-function #'my-diff-hl-fringe-bmp-function)

  (unless (display-graphic-p)
    (setq diff-hl-margin-symbols-alist
          '((insert . " ") (delete . " ") (change . " ")
            (unknown . " ") (ignored . " ")))
    ;; Fall back to the display margin since the fringe is unavailable in tty
    (diff-hl-margin-mode 1)
    ;; Avoid restoring `diff-hl-margin-mode'
    (with-eval-after-load 'desktop
      (add-to-list 'desktop-minor-mode-table
                   '(diff-hl-margin-mode nil))))

  ;; Integration with magit
  (with-eval-after-load 'magit
    (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)))

;; Highlight the current line
(use-package hl-line
  :ensure nil
  :hook (after-init . global-hl-line-mode))

;; Highlight matching parens
(use-package paren
  :ensure nil
  :hook (after-init . show-paren-mode)
  :config (setq show-paren-when-point-inside-paren t
                show-paren-when-point-in-periphery t))

;; Highlight brackets according to their depth
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))


(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))
(setq-default ns-use-proxy-icon  nil)
(setq frame-title-format nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("e7666261f46e2f4f42fd1f9aa1875bdb81d17cc7a121533cad3e0d724f12faf2" "a2286409934b11f2f3b7d89b1eaebb965fd63bc1e0be1c159c02e396afb893c8" "7f74a3b9a1f5e3d31358b48b8f8a1154aab2534fae82c9e918fb389fca776788" "2a3ffb7775b2fe3643b179f2046493891b0d1153e57ec74bbe69580b951699ca" "071f5702a5445970105be9456a48423a87b8b9cfa4b1f76d15699b29123fb7d8" "018c8326bced5102b4c1b84e1739ba3c7602019c645875459f5e6dfc6b9d9437" "cdb3e7a8864cede434b168c9a060bf853eeb5b3f9f758310d2a2e23be41a24ae" "423435c7b0e6c0942f16519fa9e17793da940184a50201a4d932eafe4c94c92d" "34dc2267328600f3065630e161a8ae59939700684c232073cdd5afbf78456670" "0f1733ad53138ddd381267b4033bcb07f5e75cd7f22089c7e650f1bb28fc67f4" "a9d67f7c030b3fa6e58e4580438759942185951e9438dd45f2c668c8d7ab2caf" "ff829b1ac22bbb7cee5274391bc5c9b3ddb478e0ca0b94d97e23e8ae1a3f0c3e" "51043b04c31d7a62ae10466da95a37725638310a38c471cc2e9772891146ee52" "fa477d10f10aa808a2d8165a4f7e6cee1ab7f902b6853fbee911a9e27cf346bc" "53760e1863395dedf3823564cbd2356e9345e6c74458dcc8ba171c039c7144ed" "030346c2470ddfdaca479610c56a9c2aa3e93d5de3a9696f335fd46417d8d3e4" "886fe9a7e4f5194f1c9b1438955a9776ff849f9e2f2bbb4fa7ed8879cdca0631" "7d4340a89c1f576d1b5dec57635ab93cdc006524bda486b66d01a6f70cffb08e" "e62b66040cb90a4171aa7368aced4ab9d8663956a62a5590252b0bc19adde6bd" "11e0bc5e71825b88527e973b80a84483a2cfa1568592230a32aedac2a32426c1" "2d1fe7c9007a5b76cea4395b0fc664d0c1cfd34bb4f1860300347cdad67fb2f9" "0d087b2853473609d9efd2e9fbeac088e89f36718c4a4c89c568dd1b628eae41" "001c2ff8afde9c3e707a2eb3e810a0a36fb2b466e96377ac95968e7f8930a7c5" "0fe9f7a04e7a00ad99ecacc875c8ccb4153204e29d3e57e9669691e6ed8340ce" "428754d8f3ed6449c1078ed5b4335f4949dc2ad54ed9de43c56ea9b803375c23" "d6f04b6c269500d8a38f3fabadc1caa3c8fdf46e7e63ee15605af75a09d5441e" "5e0b63e0373472b2e1cf1ebcc27058a683166ab544ef701a6e7f2a9f33a23726" "f951343d4bbe5a90dba0f058de8317ca58a6822faa65d8463b0e751a07ec887c" "2878517f049b28342d7a360fd3f4b227086c4be8f8409f32e0f234d129cee925" "332e009a832c4d18d92b3a9440671873187ca5b73c2a42fbd4fc67ecf0379b8c" "f589e634c9ff738341823a5a58fc200341b440611aaa8e0189df85b44533692b" "f2b83b9388b1a57f6286153130ee704243870d40ae9ec931d0a1798a5a916e76" "527df6ab42b54d2e5f4eec8b091bd79b2fa9a1da38f5addd297d1c91aa19b616" "70ed3a0f434c63206a23012d9cdfbe6c6d4bb4685ad64154f37f3c15c10f3b90" "93268bf5365f22c685550a3cbb8c687a1211e827edc76ce7be3c4bd764054bad" "6daa09c8c2c68de3ff1b83694115231faa7e650fdbb668bc76275f0f2ce2a437" "8c1dd3d6fdfb2bee6b8f05d13d167f200befe1712d0abfdc47bb6d3b706c3434" "9be1d34d961a40d94ef94d0d08a364c3d27201f3c98c9d38e36f10588469ea57" "1025e775a6d93981454680ddef169b6c51cc14cea8cb02d1872f9d3ce7a1da66" "808b47c5c5583b5e439d8532da736b5e6b0552f6e89f8dafaab5631aace601dd" "80930c775cef2a97f2305bae6737a1c736079fdcc62a6fdf7b55de669fbbcd13" "6145e62774a589c074a31a05dfa5efdf8789cf869104e905956f0cbd7eda9d0e" "bc75dfb513af404a26260b3420d1f3e4131df752c19ab2984a7c85def9a2917e" default))
 '(package-selected-packages
   '(rjsx-mode diminish yasnippet-snippets which-key use-package smartparens smart-mode-line-powerline-theme smart-mode-line-atom-one-dark-theme js2-mode helm-projectile helm-descbinds helm-ag forge expand-region exec-path-from-shell dtrt-indent doom-themes diff-hl crux company-lsp company-dcd better-defaults base16-theme avy))
 '(send-mail-function 'smtpmail-send-it)
 '(smtpmail-smtp-server "smtp.gmail.com")
 '(smtpmail-smtp-service 25))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-hl-change ((t (:foreground "#c792ea"))))
 '(lsp-ui-doc-background ((t (:background "#1c202c"))))
 '(lsp-ui-sideline-code-action ((t (:inherit warning)))))
