;;; init.el --- plain config  -*- lexical-binding: t; coding:utf-8; fill-column: 119 -*-

;;; Commentary:
;; My personal config. Use `outshine-cycle-buffer' (<S-Tab> or (C-M i)) to navigate through sections, and `counsel-imenu' (C-c i)
;; to locate individual use-package definition.
;; M-x describe-personal-keybindings to see all personally defined keybindings

(progn ;startup
  (defvar before-user-init-time (current-time)
    "Value of `current-time' when Emacs begins loading `user-init-file'.")
  (message "Loading Emacs...done (%.3fs)"
           (float-time (time-subtract before-user-init-time
                                      before-init-time)))
  (setq user-init-file (or load-file-name buffer-file-name))
  (setq user-emacs-directory (file-name-directory user-init-file))
  (message "Loading %s..." user-init-file))


;; Speed up bootstrapping
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)
(add-hook 'after-init-hook `(lambda ()
                              (setq gc-cons-threshold 800000
                                    gc-cons-percentage 0.1)
                              (garbage-collect)) t)





;;;;  package.el
;;; so package-list-packages includes them
(require 'package)
(customize-set-variable 'package-archives
                        `(,@package-archives
                          ("melpa" . "https://melpa.org/packages/")
                          ("org" . "https://orgmode.org/elpa/")
                          ))
(customize-set-variable 'package-enable-at-startup nil)
(package-initialize)


;; Bootstrap `use-package'
(setq-default use-package-always-defer t ; Always defer load package to speed up startup time
              use-package-verbose nil ; Don't report loading details
              use-package-expand-minimally t  ; make the expanded code as minimal as possible
              use-package-enable-imenu-support t) ; Let imenu finds use-package definitions

;;; use-package setup
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(put 'use-package 'lisp-indent-function 1)

;; use-package always ensure
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;;; Garbage collector
(use-package gcmh
  :ensure t
  :init
  (gcmh-mode 1))


;; Turn off mouse interface early in startup to avoid momentary display
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;;; Personal keybindings
;; Personal map activate as early as possible
(unbind-key [f12])
(bind-keys :prefix [f12]
           :prefix-map my-personal-map)

;; (bind-keys :prefix "C-c c"
;;            :prefix-map my-code-map)

(unbind-key [f6])
(bind-keys :prefix [f6]
           :prefix-map my-prog-map)


;; Early unbind keys for customization
(unbind-key "C-s") ; Reserve for search related commands
(bind-keys :prefix "C-s"
           :prefix-map my-search-map)

(unbind-key [f9]) ;; Reserve for hydra related commands
(bind-keys :prefix [f9]
           :prefix-map my-assist-map)


;; C-x C-c is originally bound to kill emacs. I accidentally type this
;; from time to time which is super-frustrating.  Get rid of it:
(unbind-key "C-x C-c")


;;; Symbolic link and folders
(use-package my-personal-choices
  ;; add some general keys to my-personal-map
  :ensure nil
  :bind (:map my-personal-map
              ("y" . my-init-file)
              ("0" . save-buffers-kill-emacs)
              ("Q" . delete-frame) ;C-x 5 0
              )
  :init
  (defun my-init-file ()
    "Open my emacs init.el file"
    (interactive)
    (find-file (concat user-emacs-directory "init.el")))
  )


;; Setup catch folder to put related files at one place
(defvar my-emacs-cache (concat user-emacs-directory "cache/")
  "Folder to store cache files in. Should end with a forward slash.")

;; Customize to be pc specific if customize.el exist
(setq custom-file (concat my-emacs-cache "customize.el"))
;; (when (load custom-file t)
;;   (load custom-file))
(when (file-exists-p custom-file)
  (load custom-file :noerror))

;;; General setup
(setq-default ;; Use setq-default to define global default
 ;; Don't show scratch message, and use fundamental-mode for *scratch*
 ;; Remove splash screen and the echo area message
 inhibit-startup-message t
 inhibit-startup-echo-area-message t
 initial-scratch-message 'nil
 initial-major-mode 'fundamental-mode
 ;; Emacs modes typically provide a standard means to change the
 ;; indentation width -- eg. c-basic-offset: use that to adjust your
 ;; personal indentation width, while maintaining the style (and
 ;; meaning) of any files you load.
 indent-tabs-mode nil ; don't use tabs to indent
 tab-width 8 ; but maintain correct appearance
 ;; Use one space as sentence end
 sentence-end-double-space 'nil
 ;; Newline at end of file
 require-final-newline t
 ;; Don't adjust window-vscroll to view tall lines.
 auto-window-vscroll nil
 ;; Leave some rooms when recentering to top, useful in emacs ipython notebook.
 recenter-positions '(middle 1 bottom)
 ;; Move files to trash when deleting
 delete-by-moving-to-trash t
 ;; Show column number
 column-number-mode t
 ;; More message logs
 message-log-max 16384
 ;; No electric indent
 electric-indent-mode nil
 ;; Place all auto-save files in one directory.
 backup-directory-alist `(("." . ,(concat my-emacs-cache "backups")))
 ;; more useful frame title, that show either a file or a
 ;; buffer name (if the buffer isn't visiting a file)
 frame-title-format '((:eval (if (buffer-file-name)
                                 (abbreviate-file-name (buffer-file-name))
                               "%b")))
 ;; warn when opening files bigger than 100MB
 large-file-warning-threshold 100000000
 ;; Don't create backup files
 make-backup-files nil ; stop creating backup~ files
 ;; Remember my location when the file is last opened
 ;; activate it for all buffers
 save-place-file (expand-file-name "saveplace" my-emacs-cache)
 save-place t
 ;; smooth scrolling
 scroll-conservatively 101
 ;; Reserve one line when scrolling
 scroll-margin 1
 ;; turn off the bell
 ring-bell-function 'ignore
 ;; Smoother scrolling
 mouse-wheel-scroll-amount '(1 ((shift) . 1)) ;; one line at a time
 mouse-wheel-progressive-speed nil ;; don't accelerate scrolling
 mouse-wheel-follow-mouse 't ;; scroll window under mouse
 scroll-step 1 ;; keyboard scroll one line at a time
 scroll-preserve-screen-position 'always
 ;; Hide warning redefinition
 ad-redefinition-action 'accept
 )


;;; Misc
;; Misc
(set-frame-name "Emacs the Great")
(delete-selection-mode 1)
;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)
;; Set paste system
;; (set-clipboard-coding-system 'utf-16le-dos)
;; Set paste error under linux
(set-selection-coding-system 'utf-8)
;; Allow pasting selection outside of Emacs
(setq x-select-enable-clipboard t)
;; Don't blink
(blink-cursor-mode 0)
;; Start maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))
;; ESC is mapped as metakey by default, very counter-intuitive.

(defun the-the ()
  ;; https://www.gnu.org/software/emacs/manual/html_node/eintr/the_002dthe.html
  "Search forward for for a duplicated word."
  (interactive)
  (message "Searching for for duplicated words ...")
  (push-mark)
  ;; This regexp is not perfect
  ;; but is fairly good over all:
  (if (re-search-forward
       "\\b\\([^@ \n\t]+\\)[ \n\t]+\\1\\b" nil 'move)
      (message "Found duplicated word.")
    (message "End of buffer")))

(use-package beacon
  ;; Highlight the cursor whenever it scrolls
  :ensure t
  :defer 5
  :bind (("C-<f12>" . beacon-blink)) ;; useful when multiple windows
  :config
  (setq beacon-size 10)
  (beacon-mode 1))

;; don't bind C-x C-z to suspend-frame:
(unbind-key "C-x C-z")
;; if frame freeze then use xkill -frame $emacs

(use-package which-key
  :defer 3
  :custom
  (which-key-show-early-on-C-h t "Allow C-h to trigger which-key b4 it's done automatically")
  (which-key-idle-delay 10000)
  (which-key-idle-secondary-delay 0.05)
  :config
  ;; (setq which-key-idle-delay 1.0)
  (which-key-mode)

  ;; Rename for resize-buffer menu
  (which-key-add-key-based-replacements
    "<f12> v" "resize buffer")
  )

(use-package whole-line-or-region
  ;; If no region is active, C-w and M-w will act on current line
  :defer 5
  ;; Right click to paste: I don't use the popup
  ;; :bind ("<mouse-3>" . whole-line-or-region-
  :bind (:map whole-line-or-region-local-mode-map
              ("C-w" . kill-region-or-backward-word)) ;; Reserve for backward-kill-word
  :init
  (defun kill-region-or-backward-word ()
    "Kill selected region if region is active. Otherwise kill a backward word."
    (interactive)
    (if (region-active-p)
        (kill-region (region-beginning) (region-end))
      (backward-kill-word 1)))
  :config
  (whole-line-or-region-global-mode)
  )

;;; Cache related
;;;; Things that use the catche folder
(use-package recentf
  :defer 5
  :init
  (defun suppress-messages (func &rest args)
    "Suppress message output from FUNC."
    ;; Some packages are too noisy.
    ;; https://superuser.com/questions/669701/emacs-disable-some-minibuffer-messages
    (cl-flet ((silence (&rest args1) (ignore)))
      (advice-add 'message :around #'silence)
      (unwind-protect
          (apply func args)
        (advice-remove 'message #'silence))))
  :config
  (setq recentf-save-file (expand-file-name "recentf" my-emacs-cache)
        recentf-max-saved-items 'nil ;; Save the whole list
        recentf-max-menu-items 50
        ;; Cleanup list if idle for 10 secs
        recentf-auto-cleanup 10)
  ;; save it every 10 minutes
  (run-at-time t (* 10 60) 'recentf-save-list)
  ;;Suppress output "Wrote /home/ybka/.emacs.d/catche/recentf"
  (advice-add 'recentf-save-list :around #'suppress-messages)
  ;;Suppress output "Cleaning up the recentf list...done (0 removed)"
  (advice-add 'recentf-cleanup :around #'suppress-messages)
  (recentf-mode +1)
  )

;;; Font
;; Text scale
(use-package default-text-scale
  :init
  ;; ;; For Linux
  ;; (global-set-key (kbd "<C-mouse-5>") 'text-scale-decrease)
  ;; (global-set-key (kbd "<C-mouse-4>") 'text-scale-increase)
  ;; For Windows
  (global-set-key (kbd "<C-wheel-up>") 'text-scale-decrease)
  (global-set-key (kbd "<C-wheel-down>") 'text-scale-increase)
  :ensure t
  :bind (("C--" . default-text-scale-decrease)
         ("C-+" . default-text-scale-increase))
  :config
  (default-text-scale-mode))


;;; Commenting
(defun comment-eclipse ()
  (interactive)
  (let ((start (line-beginning-position))
        (end (line-end-position)))
    (when (or (not transient-mark-mode) (region-active-p))
      (setq start (save-excursion
                    (goto-char (region-beginning))
                    (beginning-of-line)
                    (point))
            end (save-excursion
                  (goto-char (region-end))
                  (end-of-line)
                  (point))))
    (comment-or-uncomment-region start end)))

(global-set-key (kbd "M-'") 'comment-eclipse)



(use-package crux
  ;; A handful of useful functions
  :defer 1
  :bind (("C-a" . crux-move-beginning-of-line)
         ("C-k" . crux-smart-kill-line) ;first kill end of line then kill whole line
         ("C-x t"         . 'crux-swap-windows)
         ("C-c b"         . 'crux-create-scratch-buffer)
         ("C-x o"         . 'crux-open-with)
         ;; ("C-x f"         . 'crux-recentf-find-file) ;C-s f counsel-recent-file
         ;; ("C-x 4 t"       . 'crux-transpose-windows)
         ("C-c r" . crux-rename-file-and-buffer) ;rename current buffer
         ("C-c k" . crux-kill-other-buffers) ;kill all open buffers but not this
         ("C-x C-k"       . 'crux-delete-buffer-and-file)
         ("C-c n"         . 'crux-cleanup-buffer-or-region)
         (:map my-assist-map
               ("<backspace>" . crux-kill-line-backwards) ;C-S-backspace sp-kill-whole-line
               ;; ("t" . crux-transpose-windows)
               )
         (:map my-personal-map
               ("<return>" . crux-cleanup-buffer-or-region))
         )
  :init
  (global-set-key [remap move-beginning-of-line] #'crux-move-beginning-of-line)
  (global-set-key [(shift return)] #'crux-smart-open-line)
  (global-set-key [remap kill-whole-line] #'crux-kill-whole-line)

  :config
  ;; Retain indentation in these modes.
  (add-to-list 'crux-indent-sensitive-modes 'markdown-mode)
  )



(use-package simple
  ;; Improvements over simple editing commands
  :ensure nil
  :defer 5
  :hook ((prog-mode) . auto-fill-mode)
  ;; resize buffer accordingly
  :bind
  ;; binding changed named with which-key
  ("<f12> v" . (lambda () (interactive) (progn (visual-line-mode)
                                          (follow-mode))))
  ;; M-backspace to backward-delete-word
  ;; C-S-backspace is used by sp-kill-whole-line
  ("M-S-<backspace>" . backward-kill-sentence)
  ("M-C-<backspace>" . backward-kill-paragraph)
  ("C-x C-o"         . remove-extra-blank-lines)
  ("C-z" . undo)
  ;; The -dwim versions of these three commands are new in Emacs 26 and
  ;; better than their non-dwim counterparts, so override those default
  ;; bindings:
  ("M-l" . downcase-dwim)
  ("M-c" . capitalize-dwim)
  ("M-u" . upcase-dwim)
  ("C-8" . xah-toggle-letter-case)
  ;; Super useful for "merging" lines together, overrides the much less
  ;; useful tab-to-tab-stop:
  ("M-i" . delete-indentation)

  :init
  ;; Move more quickly
  (global-set-key (kbd "C-S-n")
                  (lambda ()
                    (interactive)
                    (ignore-errors (next-line 5))))
  (global-set-key (kbd "C-S-p")
                  (lambda ()
                    (interactive)
                    (ignore-errors (previous-line 5))))

  ;; Show line num temporarily
  (defun goto-line-with-feedback ()
    "Show line numbers temporarily, while prompting for the line number input"
    (interactive)
    (unwind-protect
        (progn
          (linum-mode 1)
          (goto-line (read-number "Goto line: ")))
      (linum-mode -1)))
  (global-set-key [remap goto-line] 'goto-line-with-feedback)

  (defun kill-region-or-backward-word ()
    (interactive)
    (if (region-active-p)
        (kill-region (region-beginning) (region-end))
      (backward-kill-word 1)))
  ;; (global-set-key (kbd "M-h") 'kill-region-or-backward-word)

  (defun remove-extra-blank-lines (&optional beg end)
    "If called with region active, replace multiple blank lines
with a single one.
Otherwise, call `delete-blank-lines'."
    (interactive)
    (if (region-active-p)
        (save-excursion
          (goto-char (region-beginning))
          (while (re-search-forward "^\\([[:blank:]]*\n\\)\\{2,\\}" (region-end) t)
            (replace-match "\n")
            (forward-char 1)))
      (delete-blank-lines)))

  (defun alert-countdown ()
    "Show a message after timer expires. Based on run-at-time and can understand time like it can."
    (interactive)
    (let* ((msg-to-show (read-string "Message to show: "))
           (time-duration (read-string "Time: ")))
      (message time-duration)
      (run-at-time time-duration nil #'alert msg-to-show)))

  (use-package visual-fill-column)
  ;; Activate `visual-fill-column-mode' in every buffer that uses `visual-line-mode'
  (add-hook 'visual-line-mode-hook #'visual-fill-column-mode)
  (setq-default visual-fill-column-width 119
                visual-fill-column-center-text nil)
  :config

  ;; Toggle letter-case
  ;; Instead of using M-u/l/c
  (defun xah-toggle-letter-case ()
    "Toggle the letter case of current word or text selection.
Always cycle in this order: Init Caps, ALL CAPS, all lower.
URL `http://ergoemacs.org/emacs/modernization_upcase-word.html'
Version 2019-11-24"
    (interactive)
    (let (
          (deactivate-mark nil)
          $p1 $p2)
      (if (use-region-p)
          (setq $p1 (region-beginning) $p2 (region-end))
        (save-excursion
          (skip-chars-backward "0-9A-Za-z")
          (setq $p1 (point))
          (skip-chars-forward "0-9A-Za-z")
          (setq $p2 (point))))
      (when (not (eq last-command this-command))
        (put this-command 'state 0))
      (cond
       ((equal 0 (get this-command 'state))
        (upcase-initials-region $p1 $p2)
        (put this-command 'state 1))
       ((equal 1 (get this-command 'state))
        (upcase-region $p1 $p2)
        (put this-command 'state 2))
       ((equal 2 (get this-command 'state))
        (downcase-region $p1 $p2)
        (put this-command 'state 0)))))

  ;; (bind-key "C-8" 'xah-toggle-letter-case)
  )


(use-package expand-region
  ;; Incrementally select a region
  ;; :after org ;; When using straight, er should byte-compiled with the latest Org
  :bind (("C-\\" . er/expand-region)
         ("M-\\" . er/contract-region))
  :config
  (defun org-table-mark-field ()
    "Mark the current table field."
    (interactive)
    ;; Do not try to jump to the beginning of field if the point is already there
    (when (not (looking-back "|[[:blank:]]?"))
      (org-table-beginning-of-field 1))
    (set-mark-command nil)
    (org-table-end-of-field 1))

  (defun er/add-org-mode-expansions ()
    (make-variable-buffer-local 'er/try-expand-list)
    (setq er/try-expand-list (append
                              er/try-expand-list
                              '(org-table-mark-field))))

  (add-hook 'org-mode-hook 'er/add-org-mode-expansions)

  (setq expand-region-fast-keys-enabled nil
        er--show-expansion-message t))


;;; Text Editing / Substitution / Copy-Pasting
(use-package iedit
  ;;to combine iedit with mc can use idedit-switch-to-mc-mode
  ;;use C-; to start and end iedit
  :ensure t
  :bind ("C-;" . iedit-mode)
  )


(use-package multiple-cursors
  ;; Read https://github.com/magnars/multiple-cursors.el for common use cases
  :ensure t
  :defer 10
  :commands (mc/mark-next-like-this)
  :bind (:map my-assist-map
              ("m" . hydra-multiple-cursors/body))
  :init
  (defhydra hydra-multiple-cursors (:hint nil)
    "
 Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Next     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search
 [Click] Cursor at point       [_q_] Quit"
    ("l" mc/edit-lines :exit t)
    ("a" mc/mark-all-like-this :exit t)
    ("n" mc/mark-next-like-this :exit nil)
    ("N" mc/skip-to-next-like-this)
    ("M-n" mc/unmark-next-like-this)
    ("p" mc/mark-previous-like-this :exit nil)
    ("P" mc/skip-to-previous-like-this)
    ("M-p" mc/unmark-previous-like-this)
    ("s" mc/mark-all-in-region-regexp :exit t)
    ("0" mc/insert-numbers :exit t)
    ("A" mc/insert-letters :exit t)
    ("<mouse-1>" mc/add-cursor-on-click)
    ;; Help with click recognition in this hydra
    ("<down-mouse-1>" ignore)
    ("<drag-mouse-1>" ignore)
    ("q" nil))
  :bind
  (
   ;; Common use case: er/expand-region, then add curors.
   ("<C-S-next>" . mc/mark-next-like-this)
   ("<C-S-prior>" . mc/mark-previous-like-this)
   ;; After selecting all, we may end up with cursors outside of view
   ;; Use C-' to hide/show unselected lines.
   ("C-*" . mc/mark-all-like-this)
   ;; HOLLLY>>>> Praise Magnars.
   ("C-S-<mouse-1>" . mc/add-cursor-on-click)
   ;; highlighting symbols only
   ("C->" . mc/mark-next-word-like-this)
   ("C-<" . mc/mark-previous-word-like-this)
   ("C-M-*" . mc/mark-all-words-like-this)
   ;; Region edit.
   ("C-S-c C-S-c" . mc/edit-lines)
   )
  :config
  (define-key mc/keymap (kbd "<return>") nil)
  ;; ;; specify mc list
  ;; (setq mc/list-file (expand-file-name "mc-list.el" my-private-conf-directory))
  )


(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode
  :bind ("C-x u" . undo-tree-visualize)
  :config
  ;; make ctrl-Z redo
  (defalias 'redo 'undo-tree-redo)

  (setq undo-tree-visualizer-timestamps t)
  (setq undo-tree-visualizer-diff t)

  (defun ybk/undo-tree-enable-save-history ()
    "Enable auto saving of the undo history."
    (interactive)

    (setq undo-tree-auto-save-history t)

    ;; Compress the history files as .gz files
    ;; (advice-add 'undo-tree-make-history-save-file-name :filter-return
    ;;             (lambda (return-val) (concat return-val ".gz")))

    ;; Persistent undo-tree history across emacs sessions
    (setq my-undo-tree-history-dir (let ((dir (concat my-emacs-cache
                                                      "undo-tree-history/")))
                                     (make-directory dir :parents)
                                     dir))
    (setq undo-tree-history-directory-alist `(("." . ,my-undo-tree-history-dir)))

    (add-hook 'write-file-functions #'undo-tree-save-history-hook)
    (add-hook 'find-file-hook #'undo-tree-load-history-hook))

  (defun my-undo-tree-disable-save-history ()
    "Disable auto saving of the undo history."
    (interactive)

    (setq undo-tree-auto-save-history nil)

    (remove-hook 'write-file-functions #'undo-tree-save-history-hook)
    (remove-hook 'find-file-hook #'undo-tree-load-history-hook))

  ;; Aktifkan
  (global-undo-tree-mode 1)

  )


;;; Completion Framework: Ivy / Swiper / Counsel
;; Create folder with mkdir -p if folder doesn't exist when using find-file
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir)))))

;;;; Find-replace
(use-package xah-find
  ;; find text from all files in a folder
  :bind (
         :map my-search-map
         ("w" . xah-find-text)
         ("o" . xah-find-replace-text)
         ("e" . xah-find-text-regex)
         ("k" . xah-find-count))
  )

(use-package counsel
  ;; specifying counsel will bring ivy and swiper as dependencies
  :demand t
  :ensure ivy-hydra
  :ensure ivy-rich
  :ensure counsel-projectile
  :ensure ivy-posframe
  :ensure smex
  :bind (
         :map my-search-map
         ("s" . swiper)
         ("S" . ivy-resume) ;continue C-s C-r
         ("a" . counsel-ag)
         ("d" . counsel-dired-jump)
         ("f" . counsel-find-file)
         ("g" . counsel-git-grep)
         ("i" . counsel-imenu)
         ("j" . counsel-file-jump)
         ("l" . counsel-find-library)
         ("r" . counsel-recentf)
         ("L" . counsel-locate)
         ("u" . counsel-unicode-char)
         ("v" . counsel-set-variable)
         )

  :init
  (setq ivy-rich--display-transformers-list
        '(ivy-switch-buffer
          (:columns
           ((ivy-rich-candidate (:width 50))  ; return the candidate itself
            (ivy-rich-switch-buffer-size (:width 7))  ; return the buffer size
            (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right)); return the buffer indicators
            (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))          ; return the major mode info
            (ivy-rich-switch-buffer-project (:width 15 :face success))             ; return project name using `projectile'
            (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))  ; return file path relative to project root or `default-directory' if project is nil
           :predicate
           (lambda (cand) (get-buffer cand)))
          counsel-M-x
          (:columns
           ((counsel-M-x-transformer (:width 40))  ; thr original transformer
            (ivy-rich-counsel-function-docstring (:face font-lock-doc-face))))  ; return the docstring of the command
          counsel-describe-function
          (:columns
           ((counsel-describe-function-transformer (:width 40))  ; the original transformer
            (ivy-rich-counsel-function-docstring (:face font-lock-doc-face))))  ; return the docstring of the function
          counsel-describe-variable
          (:columns
           ((counsel-describe-variable-transformer (:width 40))  ; the original transformer
            (ivy-rich-counsel-variable-docstring (:face font-lock-doc-face))))  ; return the docstring of the variable
          counsel-recentf
          (:columns
           ((ivy-rich-candidate (:width 0.8)) ; return the candidate itself
            (ivy-rich-file-last-modified-time (:face font-lock-comment-face)))))) ; return the last modified time of the file
  :config
  (ivy-mode 1)
  (ivy-rich-mode 1)
  (counsel-mode 1)
  (minibuffer-depth-indicate-mode 1)
  (counsel-projectile-mode 1)
  ;; (setq smex-save-file (expand-file-name "smex-items" my-private-conf-directory))
  (setq ivy-height 10
        ivy-fixed-height-minibuffer t
        ivy-use-virtual-buffers t ;; show recent files as buffers in C-x b
        ivy-use-selectable-prompt t ;; C-M-j to rename similar filenames
        enable-recursive-minibuffers t
        ivy-re-builders-alist '((t . ivy--regex-plus))
        ivy-count-format "(%d/%d) "
        ;; Useful settings for long action lists
        ;; See https://github.com/tmalsburg/helm-bibtex/issues/275#issuecomment-452572909
        max-mini-window-height 0.30
        ;; Don't parse remote files
        ivy-rich-parse-remote-buffer 'nil
        )

  ;;   ;; Do not show "./" and "../" in the `counsel-find-file' completion list
  ;;   ;; But can be a problem when running R from root directory
  ;; (setq ivy-extra-directories nil) ; default value: ("../" "./")

  (defvar dired-compress-files-alist
    '(("\\.tar\\.gz\\'" . "tar -c %i | gzip -c9 > %o")
      ("\\.zip\\'" . "zip %o -r --filesync %i"))
    "Control the compression shell command for `dired-do-compress-to'.
Each element is (REGEXP . CMD), where REGEXP is the name of the
archive to which you want to compress, and CMD the the
corresponding command.
Within CMD, %i denotes the input file(s), and %o denotes the
output file. %i path(s) are relative, while %o is absolute.")

  ;; Offer to create parent directories if they do not exist
  ;; http://iqbalansari.github.io/blog/2014/12/07/automatically-create-parent-directories-on-visiting-a-new-file-in-emacs/
  (defun my-create-non-existent-directory ()
    (let ((parent-directory (file-name-directory buffer-file-name)))
      (when (and (not (file-exists-p parent-directory))
                 (y-or-n-p (format "Directory `%s' does not exist! Create it?" parent-directory)))
        (make-directory parent-directory t))))
  (add-to-list 'find-file-not-found-functions 'my-create-non-existent-directory)

  ;; Kill virtual buffer too
  ;; https://emacs.stackexchange.com/questions/36836/how-to-remove-files-from-recentf-ivy-virtual-buffers
  (defun my-ivy-kill-buffer (buf)
    (interactive)
    (if (get-buffer buf)
        (kill-buffer buf)
      (setq recentf-list (delete (cdr (assoc buf ivy--virtual-buffers)) recentf-list))))

  (ivy-set-actions 'ivy-switch-buffer
                   '(("k" (lambda (x)
                            (my-ivy-kill-buffer x)
                            (ivy--reset-state ivy-last))  "kill")
                     ("j" switch-to-buffer-other-window "other window")
                     ("x" browse-file-directory "open externally")
                     ))

  (ivy-set-actions 'counsel-find-file
                   '(("j" find-file-other-window "other window")
                     ("b" counsel-find-file-cd-bookmark-action "cd bookmark")
                     ("f" (lambda (x)
                            (with-ivy-window (insert(file-relative-name x)))) "insert relative file name")
                     ("x" counsel-find-file-extern "open externally")
                     ("d" delete-file "delete")
                     ("g" magit-status-internal "magit status")
                     ("r" counsel-find-file-as-root "open as root")
                     ))
  ;; display at `ivy-posframe-style'
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-point)))
  ;; (ivy-posframe-mode 1)
  )

;;; Version-control

;;need to specify editor in git terminal with
;;git config core.editor '"c:/path_to/bin/emacsclient.exe"'
(use-package with-editor
  :ensure t
  :config
  (add-hook 'shell-mode-hook  'with-editor-export-editor)
  (add-hook 'term-exec-hook   'with-editor-export-editor)
  (add-hook 'eshell-mode-hook 'with-editor-export-editor)
  )

(use-package magit
  :defer 10
  ;;:ensure gitignore-templates
  :ensure diff-hl
  :ensure git-gutter
  :ensure ov
  :ensure smerge-mode
  :ensure git-timemachine
  ;;display flycheck errors only on added/modified lines
  :ensure magit-todos
  :ensure ediff
  :ensure magit-diff-flycheck
  ;; use M-x v for vc-prefix-map
  :bind (:map vc-prefix-map
              ("s" . 'git-gutter:stage-hunk)
              ("c" . 'magit-clone))
  :bind (("C-x v r" . 'diff-hl-revert-hunk)
         ("C-x v n" . 'diff-hl-next-hunk)
         ("C-x v p" . 'diff-hl-previous-hunk))
  :bind (("C-x M-g" . 'magit-dispatch-popup)
         ("C-x g" . magit-status)
         ("C-x G" . magit-dispatch))
  :config
  ;; Enable magit-file-mode, to enable operations that touches a file, such as log, blame
  (global-magit-file-mode)

  ;; Prettier looks, and provides dired diffs
  (use-package diff-hl
    :defer 3
    :commands (diff-hl-mode diff-hl-dired-mode)
    :hook (magit-post-refresh . diff-hl-magit-post-refresh)
    :hook (dired-mode . diff-hl-dired-mode)
    :config
    (global-diff-hl-mode)
    )

  ;; Someone says this will make magit on Windows faster.
  (setq w32-pipe-read-delay 0)

  (set-default 'magit-push-always-verify nil)
  (set-default 'magit-revert-buffers 'silent)
  (set-default 'magit-no-confirm '(stage-all-changes
                                   unstage-all-changes))
  (set-default 'magit-diff-refine-hunk t)
  ;; change default display behavior
  (setq magit-completing-read-function 'ivy-completing-read
        magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1
        magit-clone-set-remote.pushDefault nil
        magit-clone-default-directory "~/projects/")


  ;; autoload https://github.com/alphapapa/unpackaged.el#magit
  (defun my-magit-status ()
    "Open a `magit-status' buffer and close the other window so only Magit is visible.
If a file was visited in the buffer that was active when this
command was called, go to its unstaged changes section."
    (interactive)
    (let* ((buffer-file-path (when buffer-file-name
                               (file-relative-name buffer-file-name
                                                   (locate-dominating-file buffer-file-name ".git"))))
           (section-ident `((file . ,buffer-file-path) (unstaged) (status))))
      (call-interactively #'magit-status)
      (delete-other-windows)
      (when buffer-file-path
        (goto-char (point-min))
        (cl-loop until (when (equal section-ident (magit-section-ident (magit-current-section)))
                         (magit-section-show (magit-current-section))
                         (recenter)
                         t)
                 do (condition-case nil
                        (magit-section-forward)
                      (error (cl-return (magit-status-goto-initial-section-1))))))))

  ;; autoload
  (defun my-magit-save-buffer-show-status ()
    "Save buffer and show its changes in `magit-status'."
    (interactive)
    (save-buffer)
    (my-magit-status))


  ;; Set magit password authentication source to auth-source
  (add-to-list 'magit-process-find-password-functions
               'magit-process-password-auth-source)


  ;; Always expand file in ediff.
  ;; show help in same windows
  (add-hook 'ediff-prepare-buffer-hook #'show-all)
  ;; Do everything in one frame
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)


  ;; Add date headers to Magit log buffers https://github.com/alphapapa/unpackaged.el#magit
  ;; require ov package
  (defun my-magit-log--add-date-headers (&rest _ignore)
    "Add date headers to Magit log buffers."
    (when (derived-mode-p 'magit-log-mode)
      (save-excursion
        (ov-clear 'date-header t)
        (goto-char (point-min))
        (cl-loop with last-age
                 for this-age = (-some--> (ov-in 'before-string 'any (line-beginning-position) (line-end-position))
                                  car
                                  (overlay-get it 'before-string)
                                  (get-text-property 0 'display it)
                                  cadr
                                  (s-match (rx (group (1+ digit) ; number
                                                      " "
                                                      (1+ (not blank))) ; unit
                                               (1+ blank) eos)
                                           it)
                                  cadr)
                 do (when (and this-age
                               (not (equal this-age last-age)))
                      (ov (line-beginning-position) (line-beginning-position)
                          'after-string (propertize (concat " " this-age "\n")
                                                    'face 'magit-section-heading)
                          'date-header t)
                      (setq last-age this-age))
                 do (forward-line 1)
                 until (eobp)))))

  (define-minor-mode my-magit-log-date-headers-mode
    "Display date/time headers in `magit-log' buffers."
    :global t
    (if my-magit-log-date-headers-mode
        (progn
          ;; Disable mode
          (remove-hook 'magit-post-refresh-hook #'my-magit-log--add-date-headers)
          (advice-remove #'magit-setup-buffer-internal #'my-magit-log--add-date-headers)
          ;; Enable mode
          (add-hook 'magit-post-refresh-hook #'my-magit-log--add-date-headers)
          (advice-add #'magit-setup-buffer-internal :after #'my-magit-log--add-date-headers))
      )
    )

  ;; activate magit-log header with date
  (my-magit-log-date-headers-mode 1)

  )


(use-package git-gutter
  :ensure t
  ;; :when window-system
  :defer t
  :bind (("C-x P" . git-gutter:popup-hunk)
         ("C-x p" . git-gutter:previous-hunk)
         ("C-x n" . git-gutter:next-hunk)
         ("C-c G" . git-gutter:popup-hunk))
  :diminish ""
  :init
  (add-hook 'prog-mode-hook #'git-gutter-mode)
  (add-hook 'text-mode-hook #'git-gutter-mode)
  :config
  (use-package git-gutter-fringe
    :ensure t
    :init
    (require 'git-gutter-fringe)
    (when (fboundp 'define-fringe-bitmap)
      (define-fringe-bitmap 'git-gutter-fr:added
        [224 224 224 224 224 224 224 224 224 224 224 224 224
             224 224 224 224 224 224 224 224 224 224 224 224]
        nil nil 'center)
      (define-fringe-bitmap 'git-gutter-fr:modified
        [224 224 224 224 224 224 224 224 224 224 224 224 224
             224 224 224 224 224 224 224 224 224 224 224 224]
        nil nil 'center)
      (define-fringe-bitmap 'git-gutter-fr:deleted
        [0 0 0 0 0 0 0 0 0 0 0 0 0 128 192 224 240 248]
        nil nil 'center))))



;;; Diff text - ediff/diff

(use-package smerge-mode
  ;; For comparing conflict better than ediff with Magit
  ;; https://github.com/alphapapa/unpackaged.el#smerge-mode
  :ensure t
  :after hydra
  :bind (:map my-assist-map
              ("e" . my-smerge-hydra/body))
  :config
  (defhydra my-smerge-hydra
    (:color pink :hint nil :post (smerge-auto-leave))
    "
^Move^       ^Keep^               ^Diff^                 ^Other^
^^-----------^^-------------------^^---------------------^^-------
_n_ext       _b_ase               _<_: upper/base        _C_ombine
_p_rev       _u_pper              _=_: upper/lower       _r_esolve
^^           _l_ower              _>_: base/lower        _k_ill current
^^           _a_ll                _R_efine
^^           _RET_: current       _E_diff
"
    ("n" smerge-next)
    ("p" smerge-prev)
    ("b" smerge-keep-base)
    ("u" smerge-keep-upper)
    ("l" smerge-keep-lower)
    ("a" smerge-keep-all)
    ("RET" smerge-keep-current)
    ("\C-m" smerge-keep-current)
    ("<" smerge-diff-base-upper)
    ("=" smerge-diff-upper-lower)
    (">" smerge-diff-base-lower)
    ("R" smerge-refine)
    ("E" smerge-ediff)
    ("C" smerge-combine-with-next)
    ("r" smerge-resolve)
    ("k" smerge-kill-current)
    ("ZZ" (lambda ()
            (interactive)
            (save-buffer)
            (bury-buffer))
     "Save and bury buffer" :color blue)
    ("q" nil "cancel" :color blue))
  :hook (magit-diff-visit-file . (lambda ()
                                   (when smerge-mode
                                     (my-smerge-hydra/body)))))

;;;; Ediff
;; In windows it's important to put Git/usr/bin to path to use diff.exe file
(use-package ediff
  ;; source https://oremacs.com/2015/01/17/setting-up-ediff/
  :ensure nil
  :bind (:map my-assist-map
              ("E" . ediff))
  :custom
  (ediff-diff-options "-w" "ignore whitespace")
  ;; (ediff-window-setup-function 'ediff-setup-windows-plain "Don't use separate frame for control panel")
  (ediff-split-window-function 'split-window-horizontally)
  :config
  
  ;; Bagi key bindings
  (defun ora-ediff-hook ()
    (ediff-setup-keymap)
    (define-key ediff-mode-map "j" 'ediff-next-difference)
    (define-key ediff-mode-map "k" 'ediff-previous-difference))

  (add-hook 'ediff-mode-hook 'ora-ediff-hook)

  ;; Pasang semula window configuration bila keluar (q)
  ;; (winner-mode) ;aktifkan winner-mode kalau tidak dipasang secara global
  (add-hook 'ediff-after-quit-hook-internal 'winner-undo)
  )


;;; Window and Buffer management
(use-package windmove
  :ensure nil
  :bind (
         ("s-j" . windmove-down)
         ("s-k" . windmove-up)
         ("s-h" . windmove-left)
         ("s-l" . windmove-right)
         ("C-x <down>" . windmove-down)
         ("C-x <up>" . windmove-up)
         ("C-x <left>" . windmove-left)
         ("C-x <right>" . windmove-right)
         )
  )



(use-package window
  ;; Handier movement over default window.el
  :ensure nil
  :bind (
         ("C-x 2"             . split-window-below-and-move-there)
         ("C-x 3"             . split-window-right-and-move-there)
         ("C-x \\"            . toggle-window-split)
         ("C-0"               . delete-window)
         ("C-1"               . delete-other-windows)
         ("C-2"               . split-window-below-and-move-there)
         ("C-3"               . split-window-right-and-move-there)
         ("M-o"               . 'other-window)
         ("M-O"               . (lambda () (interactive) (other-window -1))) ;; Cycle backward
         ("M-<tab>" . 'other-frame)
         ("<M-S-iso-lefttab>" . (lambda () (interactive) (other-frame -1))) ;; Cycle backwards
         )
  :init
  ;; Functions for easier navigation
  (defun split-window-below-and-move-there ()
    (interactive)
    (split-window-below)
    (windmove-down))

  (defun split-window-right-and-move-there ()
    (interactive)
    (split-window-right)
    (windmove-right))

  (defun toggle-window-split ()
    "When there are two windows, toggle between vertical and
horizontal mode."
    (interactive)
    (if (= (count-windows) 2)
        (let* ((this-win-buffer (window-buffer))
               (next-win-buffer (window-buffer (next-window)))
               (this-win-edges (window-edges (selected-window)))
               (next-win-edges (window-edges (next-window)))
               (this-win-2nd (not (and (<= (car this-win-edges)
                                           (car next-win-edges))
                                       (<= (cadr this-win-edges)
                                           (cadr next-win-edges)))))
               (splitter
                (if (= (car this-win-edges)
                       (car (window-edges (next-window))))
                    'split-window-horizontally
                  'split-window-vertically)))
          (delete-other-windows)
          (let ((first-win (selected-window)))
            (funcall splitter)
            (if this-win-2nd (other-window 1))
            (set-window-buffer (selected-window) this-win-buffer)
            (set-window-buffer (next-window) next-win-buffer)
            (select-window first-win)
            (if this-win-2nd (other-window 1))))))
  )


(use-package winum
  :ensure t
  :defer 1
  :init
  (setq winum-keymap
        (let ((map (make-sparse-keymap)))
          ;; (define-key map (kbd "<f2> w") 'winum-select-window-by-number)
          (define-key map (kbd "M-0") 'winum-select-window-0-or-10)
          (define-key map (kbd "M-1") 'winum-select-window-1)
          (define-key map (kbd "M-2") 'winum-select-window-2)
          (define-key map (kbd "M-3") 'winum-select-window-3)
          (define-key map (kbd "M-4") 'winum-select-window-4)
          (define-key map (kbd "M-5") 'winum-select-window-5)
          (define-key map (kbd "M-6") 'winum-select-window-6)
          (define-key map (kbd "M-7") 'winum-select-window-7)
          (define-key map (kbd "M-8") 'winum-select-window-8)
          map))
  :config
  (winum-mode))


(use-package ace-window
  :disabled
  :defer 3
  :bind ([S-return] . ace-window)
  :custom-face (aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0))))
  :config
  (setq
   ;; Home row is more convenient. Use home row keys that prioritize fingers that don't move.
   aw-keys '(?j ?k ?l ?f ?d ?s ?g ?h ?\; ?a)
   aw-scope 'visible)
  )

(use-package winner
  ;; Enable window restoration
  :defer 1
  :config
  (winner-mode 1))


(use-package nswbuff
  ;; Quickly switching buffers. Quite useful!
  :bind (("<C-tab>"           . nswbuff-switch-to-next-buffer)
         ("<C-S-iso-lefttab>" . nswbuff-switch-to-previous-buffer))
  :config
  (setq nswbuff-display-intermediate-buffers t)
  )

(use-package golden-ratio
  ;; Resize windows with ratio https://github.com/roman/golden-ratio.el
  :ensure t
  :defer 5
  :bind* (:map my-personal-map
               ("V" . golden-ratio-mode))
  :diminish golden-ratio-mode
  :init
  (golden-ratio-mode 1)
  (setq golden-ratio-auto-scale t))


(use-package transpose-frame
  :ensure t
  :defer 4
  :commands (transpose-frame)
  :init
  (use-package crux)
  (bind-keys :prefix "C-t"
             :prefix-map transpose-map
             ("t" . my/toggle-window-split)
             ("f" . transpose-frame)
             ("c" . transpose-chars)
             ("w" . transpose-words) ;similar to M-t
             ("l" . transpose-lines)
             ("p" . transpose-paragraphs)
             ("s" . transpose-sentences)
             ("x" . transpose-sexps)
             ("b" . crux-transpose-windows) ;transpose-buffer
             )


  :config
  (defun my/toggle-window-split (&optional arg)
    "Switch between 2 windows split horizontally or vertically.
With ARG, swap them instead."
    (interactive "P")
    (unless (= (count-windows) 2)
      (user-error "Not two windows"))
    ;; Swap two windows
    (if arg
        (let ((this-win-buffer (window-buffer))
              (next-win-buffer (window-buffer (next-window))))
          (set-window-buffer (selected-window) next-win-buffer)
          (set-window-buffer (next-window) this-win-buffer))
      ;; Swap between horizontal and vertical splits
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))
  )



;;; Navigation
;;;; Register
(use-package register
  :ensure nil
  :bind* (:map my-assist-map
               ("<SPC>" . point-to-register)
               ("j" . jump-to-register)))

;;;; Bookmark
(use-package bookmark
  :ensure t
  :init
  (setq bookmark-default-file (concat my-emacs-cache "bookmarks") ;bookmarks dir
        bookmark-save-flag 1) ;auto save when chnage else use "t" to autosave when emacs quits
  :bind (:map my-assist-map
              ("b" . bookmark-set)
              ("c" . bookmark-jump)
              ("l" . bookmark-bmenu-list))
  :config
  ;; bookmark+ harus di download di GitHub dan pasang di load-path
  ;; http://blog.binchen.org/posts/hello-ivy-mode-bye-helm.html
  (defun ivy-bookmark-goto ()
    "Open ANY bookmark"
    (interactive)
    (let (bookmarks filename)
      ;; load bookmarks
      (unless (featurep 'bookmark)
        (require 'bookmark))
      (bookmark-maybe-load-default-file)
      (setq bookmarks (and (boundp 'bookmark-alist) bookmark-alist))

      ;; do the real thing
      (ivy-read "bookmarks:"
                (delq nil (mapcar (lambda (bookmark)
                                    (let (key)
                                      ;; build key which will be displayed
                                      (cond
                                       ((and (assoc 'filename bookmark) (cdr (assoc 'filename bookmark)))
                                        (setq key (format "%s (%s)" (car bookmark) (cdr (assoc 'filename bookmark)))))
                                       ((and (assoc 'location bookmark) (cdr (assoc 'location bookmark)))
                                        ;; bmkp-jump-w3m is from bookmark+
                                        (unless (featurep 'bookmark+)
                                          (require 'bookmark+))
                                        (setq key (format "%s (%s)" (car bookmark) (cdr (assoc 'location bookmark)))))
                                       (t
                                        (setq key (car bookmark))))
                                      ;; re-shape the data so full bookmark be passed to ivy-read:action
                                      (cons key bookmark)))
                                  bookmarks))
                :action (lambda (bookmark)
                          (bookmark-jump bookmark)))
      ))


  ;; Last visited bookmark on top
  (defadvice bookmark-jump (after bookmark-jump activate)
    (let ((latest (bookmark-get-bookmark bookmark)))
      (setq bookmark-alist (delq latest bookmark-alist))
      (add-to-list 'bookmark-alist latest)))
  )

;;;; Avy

(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)

(use-package avy
  :bind  (("C-,"   . avy-goto-char-2)
          ("C-M-," . avy-goto-line))
  :commands (avy-with)
  :config
  (setq avy-timeout-seconds 0.3
        avy-all-windows 'all-frames
        avy-style 'at-full)
  )

(use-package avy-zap
  :bind (("M-z" . avy-zap-to-char-dwim)
         ("M-Z" . avy-zap-up-to-char-dwim)))


;;;; Copy file path
(defun xah-copy-file-path (&optional @dir-path-only-p)
  "Copy the current buffer's file path or dired path to `kill-ring'.
Result is full path.
If `universal-argument' is called first, copy only the dir path.

If in dired, copy the file/dir cursor is on, or marked files.

If a buffer is not file and not dired, copy value of `default-directory' (which is usually
the current dir when that buffer was created)

URL `http://ergoemacs.org/emacs/emacs_copy_file_path.html'
Version 2017-09-01"
  (interactive "P")
  (let (($fpath
         (if (string-equal major-mode 'dired-mode)
             (progn
               (let (($result (mapconcat 'identity (dired-get-marked-files) "\n")))
                 (if (equal (length $result) 0)
                     (progn default-directory )
                   (progn $result))))
           (if (buffer-file-name)
               (buffer-file-name)
             (expand-file-name default-directory)))))
    (kill-new
     (if @dir-path-only-p
         (progn
           (message "Directory path copied: ?%s?" (file-name-directory $fpath))
           (file-name-directory $fpath))
       (progn
         (message "File path copied: ?%s?" $fpath)
         $fpath )))))

(global-set-key (kbd "C-c x") 'xah-copy-file-path)
(bind-key "x" 'xah-copy-file-path my-assist-map)

;;; Workspace Mgmt: eyebrowse + projectile


(use-package projectile
  :defer 2
  :ensure ripgrep ;; required by projectile-ripgrep
  :ensure which-key ;; to rename C-c p
  :bind-keymap
  ("C-c p" . projectile-command-map)
  ;; :bind* (("C-c p f" . 'projectile-find-file))
  :bind (:map projectile-command-map
              ("f" . projectile-find-file)
              ("p" . counsel-switch-project))
  :config
  (which-key-add-key-based-replacements
    "C-c p" "projectile-map"
    "C-c p x" "projectile-shell")
  
  ;; ;; Where my projects and clones are normally placed.
  ;; (setq projectile-project-search-path '("~/projects")
  ;;       projectile-completion-system 'ivy)
  ;; (projectile-mode +1)

  ;; Tetapkan project folder
  (setq projectile-project-search-path '("c:/Users/ybka/Documents/GitFH"
                                         "c:/Users/ybka/Documents/GitHub"))

  ;; Don't consider my home dir as a project
  (add-to-list 'projectile-ignored-projects `,(concat (getenv "HOME") "/"))

  ;; catch projects
  (setq projectile-enable-caching t)

  
  ;; Different than projectile-switch-project coz this works globally
  (defun counsel-switch-project ()
    (interactive)
    (ivy-read "Switch to project: "
              projectile-known-projects
              :sort t
              :require-match t
              :preselect (when (projectile-project-p) (abbreviate-file-name (projectile-project-root)))
              :action '(1
                        ("o" projectile-switch-project-by-name "goto")
                        ("g" magit-status "magit")
                        ("s" (lambda (a) (setq default-directory a) (counsel-git-grep)) "git grep"))
              :caller 'counsel-switch-project))
  ;; (bind-key* "C-c p p" 'counsel-switch-project)
  )

;;integrerer ivy i projectile
(use-package counsel-projectile
  :ensure t
  :after projectile
  :defer 3
  :config
  (counsel-projectile-mode 1))

(setq projectile-completion-system 'ivy)


(use-package eyebrowse
  :defer 2
  :init
  (setq eyebrowse-keymap-prefix (kbd "C-c w")) ;; w for workspace
  :bind
  (
   ;; ("<f9>"      . 'eyebrowse-last-window-config)
   ;; ("<f10>"     . 'eyebrowse-prev-window-config)
   ;; ("<f11>"     . 'eyebrowse-switch-to-window-config)
   ;; ("<f12>"     . 'eyebrowse-next-window-config)
   ("C-c w s"   . 'eyebrowse-switch-to-window-config)
   ("C-c w k"   . 'eyebrowse-close-window-config)
   ("C-c w w"   . 'eyebrowse-last-window-config)
   ("C-c w n"   . 'eyebrowse-next-window-config)
   ("C-c w p"   . 'eyebrowse-prev-window-config))
  :config
  (setq eyebrowse-wrap-around t
        eyebrowse-close-window-config-prompt t
        eyebrowse-mode-line-style 'smart
        eyebrowse-tagged-slot-format "%t"
        eyebrowse-new-workspace t)
  (eyebrowse-mode)
  )


;;; Programming

;; General conventions on keybindings:
;; Use C-c C-z to switch to inferior process
;; Use C-c C-c to execute current paragraph of code


;;;; General settings: prog-mode, whitespaces, symbol-prettifying, highlighting
(use-package prog-mode
  ;; Generic major mode for programming
  :ensure rainbow-delimiters
  :defer 5
  :hook (org-mode . prettify-symbols-mode)
  :hook (prog-mode . rainbow-delimiters-mode) ; Prettify parenthesis
  :hook (prog-mode . show-paren-mode)
  :init
  ;; Default to 80 fill-column
  (setq-default fill-column 100)
  ;; Prettify symbols
  (setq-default prettify-symbols-alist
                '(("#+BEGIN_SRC"     . "λ")
                  ("#+END_SRC"       . "λ")
                  ("#+RESULTS"       . ">")
                  ("#+BEGIN_EXAMPLE" . "¶")
                  ("#+END_EXAMPLE"   . "¶")
                  ("#+BEGIN_QUOTE"   . "『")
                  ("#+END_QUOTE"     . "』")
                  ("#+begin_src"     . "λ")
                  ("#+end_src"       . "λ")
                  ("#+results"       . ">")
                  ("#+begin_example" . "¶")
                  ("#+end_example"   . "¶")
                  ("#+begin_quote"   . "『")
                  ("#+end_quote"     . "』")
                  ))
  (setq prettify-symbols-unprettify-at-point 'right-edge)
  :config
  (global-prettify-symbols-mode +1) ;; This only applies to prog-mode derived modes.
  )


;; Check the great gist at
;; https://gist.github.com/pvik/8eb5755cc34da0226e3fc23a320a3c95
;; And this tutorial: https://ebzzry.io/en/emacs-pairs/
;; Example: exp1 (exp2 (exp3)) exp4
(use-package smartparens
  :ensure t
  :defer 2
  :bind (([f8] . hydra-smartparens/body)
         :map my-assist-map
         ("p" . hydra-smartparens/body)
         :map smartparens-mode-map
         ;; exp1 ((exp2 (exp3)) exp4)
         ("M-("           . sp-wrap-round)
         ("M-["           . sp-wrap-square)
         ("M-{"           . sp-wrap-curly)
         ("M-<backspace>" . sp-backward-unwrap-sexp) ;unwrap outside exp2 when in exp3
         ("M-<del>"       . sp-unwrap-sexp) ;unwrap exp3 when in exp3
         ("C-S-<right>"     . sp-forward-slurp-sexp) ;include exp4 when in exp3
         ("C-S-<left>"      . sp-backward-slurp-sexp) ;include exp1 when in exp2
         ("C-M-<right>"   . sp-forward-barf-sexp) ;remove exp4 from ()
         ("C-M-<left>"    . sp-backward-barf-sexp) ;remove exp2 from ()
         ("C-M-a"         . sp-beginning-of-sexp)
         ("C-M-z"         . sp-end-of-sexp)
         ("C-M-k"         . sp-kill-sexp)
         ("C-M-f"         . sp-forward-sexp)
         ("C-M-b"         . sp-backward-sexp)
         :map my-personal-map
         ("a" . sp-beginning-of-sexp)
         ("e" . sp-end-of-sexp)
         ("u" . sp-unwrap-sexp) ;sama seperti sp-splice-sexp
         ("k" . sp-kill-sexp)
         )
  :init
  (defhydra hydra-smartparens (:hint nil)
    "
 Moving^^^^                       Slurp & Barf^^   Wrapping^^            Sexp juggling^^^^               Destructive
------------------------------------------------------------------------------------------------------------------------
 [_a_] beginning  [_n_] down      [_h_] bw slurp   [_R_]   rewrap        [_S_] split   [_t_] transpose   [_c_] change inner  [_w_] copy
 [_e_] end        [_N_] bw down   [_H_] bw barf    [_u_]   unwrap        [_s_] splice  [_A_] absorb      [_C_] change outer
 [_f_] forward    [_p_] up        [_l_] slurp      [_U_]   bw unwrap     [_r_] raise   [_E_] emit        [_k_] kill          [_g_] quit
 [_b_] backward   [_P_] bw up     [_L_] barf       [_(__{__[_] wrap (){}[]   [_j_] join    [_o_] convolute   [_K_] bw kill       [_q_] quit"
    ;; Moving
    ("a" sp-beginning-of-sexp)
    ("e" sp-end-of-sexp)
    ("f" sp-forward-sexp)
    ("b" sp-backward-sexp)
    ("n" sp-down-sexp)
    ("N" sp-backward-down-sexp)
    ("p" sp-up-sexp)
    ("P" sp-backward-up-sexp)

    ;; Slurping & barfing
    ("h" sp-backward-slurp-sexp)
    ("H" sp-backward-barf-sexp)
    ("l" sp-forward-slurp-sexp)
    ("L" sp-forward-barf-sexp)

    ;; Wrapping
    ("R" sp-rewrap-sexp)
    ("u" sp-unwrap-sexp)
    ("U" sp-backward-unwrap-sexp)
    ("(" sp-wrap-round)
    ("{" sp-wrap-curly)
    ("[" sp-wrap-square)

    ;; Sexp juggling
    ("S" sp-split-sexp)
    ("s" sp-splice-sexp)
    ("r" sp-raise-sexp)
    ("j" sp-join-sexp)
    ("t" sp-transpose-sexp)
    ("A" sp-absorb-sexp)
    ("E" sp-emit-sexp)
    ("o" sp-convolute-sexp)

    ;; Destructive editing
    ("c" sp-change-inner :exit t)
    ("C" sp-change-enclosing :exit t)
    ("k" sp-kill-sexp)
    ("K" sp-backward-kill-sexp)
    ("w" sp-copy-sexp)

    ("q" nil)
    ("g" nil))

  :config
  (require 'smartparens-config)
  (setq sp-show-pair-from-inside t)

  (--each '(css-mode-hook
            restclient-mode-hook
            js-mode-hook
            java-mode
            emacs-lisp-mode-hook
            ruby-mode
            ;; org-mode-hook
            org-src-mode-hook
            ess-mode-hook
            inferior-ess-mode-hook
            markdown-mode
            groovy-mode
            scala-mode)
    (add-hook it 'turn-on-smartparens-strict-mode))
  :hook ((ess-mode
          inferior-ess-mode
          markdown-mode
          prog-mode) . smartparens-mode)
  ;; (add-hook 'inferior-ess-mode-hook #'smartparens-mode)
  ;; (add-hook 'LaTeX-mode-hook #'smartparens-mode)
  ;; (add-hook 'markdown-mode-hook #'smartparens-mode)
  )


;; gives spaces automatically
(use-package electric-operator
  :ensure t
  :hook ((ess-r-mode python-mode) . electric-operator-mode)
  :config
  ;; edit rules for ESS mode
  (electric-operator-add-rules-for-mode 'ess-r-mode
                                        (cons ":=" " := ")
                                        ;; (cons "%" "%")
                                        (cons "%in%" " %in% ")
                                        (cons "%>%" " %>% "))

  (setq electric-operator-R-named-argument-style 'spaced) ;if unspaced will be f(foo=1)
  ;; (add-hook 'ess-r-mode-hook #'electric-operator-mode)
  ;; (add-hook 'python-mode-hook #'electric-operator-mode)
  )

(use-package csv-mode
  :ensure t
  :mode "\\.csv$"
  :init
  (setq csv-separators '(";"))
  )


(use-package find-func
  :defer t
  :bind (:map my-search-map
              ("x f" . find-function)
              ("x v" . find-variable)
              ("x l" . find-library))
  :hook
  (find-function-after . reposition-window))


(use-package aggressive-indent
  :ensure t
  :defer t
  ;; Aggressive indent mode
  :hook ((emacs-lisp-mode ess-r-mode org-src-mode) . aggressive-indent-mode) ;;inferior-ess-r-mode 
  :config
  ;; ;; problem with Error running timer https://github.com/Malabarba/aggressive-indent-mode/issues/137
  ;; (defun aggressive-indent--indent-if-changed (buffer)
  ;;   "Indent any region that changed in BUFFER in the last command loop."
  ;;   (if (not (buffer-live-p buffer))
  ;;       (and aggressive-indent--idle-timer
  ;;            (cancel-timer aggressive-indent--idle-timer))
  ;;     (with-current-buffer buffer
  ;;       (when (and aggressive-indent-mode aggressive-indent--changed-list)
  ;;         (save-excursion
  ;;           (save-selected-window
  ;;             (aggressive-indent--while-no-input
  ;;               (aggressive-indent--proccess-changed-list-and-indent))))
  ;;         (when (timerp aggressive-indent--idle-timer)
  ;;           (cancel-timer aggressive-indent--idle-timer))))))
  )



;;;; Auto-completion
(use-package auto-complete
  :defer 3
  :hook (inferior-ess-r-mode . auto-complete-mode)
  :bind (:map ac-complete-mode-map
              ("C-n" . ac-next)
              ("C-p" . ac-previous)
              ([?\t] . ac-expand)
              ([?\r] . ac-complete)
              :map my-search-map
              ("C" . auto-complete-mode)
              )
  :custom
  (ac-use-quick-help 'nil)
  (ac-auto-start 3 "Start after 3 letters")
  (ac-dwim t "Do what I mean")
  (ac-candidate-limit 5 "Number of candidates to show")
  (ac-menu-height 5 "Height of candidate menu")
  )


;;;; Heuristic text completion: hippie expand + dabbrev
(use-package hippie-exp
  :ensure nil
  :defer 3
  :bind (("M-/"   . hippie-expand-no-case-fold)
         ("C-M-/" . dabbrev-completion)
         :map my-assist-map
         ("h" . hippie-expand)
         ([?\t] . dabbrev-completion))
  :config
  ;; Activate globally
  ;; (global-set-key (kbd "") 'hippie-expand)

  ;; Don't case-fold when expanding with hippe
  (defun hippie-expand-no-case-fold ()
    (interactive)
    (let ((case-fold-search nil))
      (hippie-expand nil)))

  ;; hippie expand is dabbrev expand on steroids
  (setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                           try-expand-dabbrev-all-buffers
                                           try-expand-dabbrev-from-kill
                                           try-complete-file-name-partially
                                           try-complete-file-name
                                           try-expand-all-abbrevs
                                           try-expand-list
                                           try-expand-line
                                           try-complete-lisp-symbol-partially
                                           try-complete-lisp-symbol)))



;;;; Eshell
;; Emacs command shell
(use-package eshell
  :ensure nil
  :defines eshell-prompt-function
  :functions eshell/alias
  :bind (:map my-personal-map
              ("s" . eshell))
  :hook (eshell-mode . (lambda ()
                         (bind-key "C-l" 'eshell/clear eshell-mode-map)
                         (eshell/alias "f" "find-file $1")
                         (eshell/alias "fo" "find-file-other-window $1")
                         (eshell/alias "d" "dired $1")
                         (eshell/alias "ll" "ls -l")
                         (eshell/alias "la" "ls -al")
                         ;;Git things
                         (eshell/alias "gitp" "cd c:/Users/ybka/Documents/GitHub/$1 && ls -la")
                         (eshell/alias "gitpp" "cd c:/Users/ybka/Documents/GitHub && ls -la")
                         (eshell/alias "gitf" "cd c:/Users/ybka/Documents/GitFH/$1 && ls -la")
                         (eshell/alias "gitff" "cd c:/Users/ybka/Documents/GitFH && ls -la")
                         (eshell/alias "gc" "git checkout $1")
                         (eshell/alias "gf" "git fetch $1")
                         (eshell/alias "gm" "git merge $1")
                         (eshell/alias "gb" "git branch $1")
                         (eshell/alias "gw" "git worktree list")
                         (eshell/alias "gs" "git status")
                         ;; (eshell/alias "gp" "cd ~/Git-personal")
                         ;; (eshell/alias "gf" "cd ~/Git-fhi")
                         (eshell/alias "cdc" "cd C:/")
                         (eshell/alias "cdy" "cd c:/Users/ybka") ;personal folder
                         (eshell/alias "cd1" "cd c:/Users/ybka/OneDrive - Folkehelseinstituttet/")
                         ;; folkehelseprofil mappen
                         (eshell/alias "cdf" "cd F:/Prosjekter/Kommunehelsa")
                         (eshell/alias "cdt" "cd f:/Prosjekter/Kommunehelsa/TESTOMRAADE/TEST_KHFUN")))
  :config
  (setq eshell-list-files-after-cd t) ;ls after cd

  (with-no-warnings
    (unless (fboundp #'flatten-tree)
      (defalias #'flatten-tree #'eshell-flatten-list))

    (defun eshell/clear ()
      "Clear the eshell buffer."
      (interactive)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (eshell-send-input)))

    (defun eshell/emacs (&rest args)
      "Open a file (ARGS) in Emacs.  Some habits die hard."
      (if (null args)
          ;; If I just ran "emacs", I probably expect to be launching
          ;; Emacs, which is rather silly since I'm already in Emacs.
          ;; So just pretend to do what I ask.
          (bury-buffer)
        ;; We have to expand the file names or else naming a directory in an
        ;; argument causes later arguments to be looked for in that directory,
        ;; not the starting directory
        (mapc #'find-file (mapcar #'expand-file-name (flatten-tree (reverse args))))))

    (defalias 'eshell/e 'eshell/emacs)

    (defun eshell/ec (&rest args)
      "Compile a file (ARGS) in Emacs.  Use `compile' to do background make."
      (if (eshell-interactive-output-p)
          (let ((compilation-process-setup-function
                 (list 'lambda nil
                       (list 'setq 'process-environment
                             (list 'quote (eshell-copy-environment))))))
            (compile (eshell-flatten-and-stringify args))
            (pop-to-buffer compilation-last-buffer))
        (throw 'eshell-replace-command
               (let ((l (eshell-stringify-list (flatten-tree args))))
                 (eshell-parse-command (car l) (cdr l))))))
    (put 'eshell/ec 'eshell-no-numeric-conversions t)

    (defun eshell-view-file (file)
      "View FILE.  A version of `view-file' which properly rets the eshell prompt."
      (interactive "fView file: ")
      (unless (file-exists-p file) (error "%s does not exist" file))
      (let ((buffer (find-file-noselect file)))
        (if (eq (get (buffer-local-value 'major-mode buffer) 'mode-class)
                'special)
            (progn
              (switch-to-buffer buffer)
              (message "Not using View mode because the major mode is special"))
          (let ((undo-window (list (window-buffer) (window-start)
                                   (+ (window-point)
                                      (length (funcall eshell-prompt-function))))))
            (switch-to-buffer buffer)
            (view-mode-enter (cons (selected-window) (cons nil undo-window))
                             'kill-buffer)))))

    (defun eshell/less (&rest args)
      "Invoke `view-file' on a file (ARGS).  \"less +42 foo\" will go to line 42 in the buffer for foo."
      (while args
        (if (string-match "\\`\\+\\([0-9]+\\)\\'" (car args))
            (let* ((line (string-to-number (match-string 1 (pop args))))
                   (file (pop args)))
              (eshell-view-file file)
              (forward-line line))
          (eshell-view-file (pop args)))))

    (defalias 'eshell/more 'eshell/less))

  ;;  Display extra information for prompt
  (use-package eshell-prompt-extras
    :after esh-opt
    :defines eshell-highlight-prompt
    :commands (epe-theme-lambda epe-theme-dakrone epe-theme-pipeline)
    :init (setq eshell-highlight-prompt nil
                eshell-prompt-function 'epe-theme-lambda))

  (use-package esh-autosuggest
    ;; Fish-like history autosuggestions https://github.com/dieggsy/esh-autosuggest
    ;; C-f select suggestion and M-f select next word in suggestion
    :defines ivy-display-functions-alist
    :preface
    (defun setup-eshell-ivy-completion ()
      (setq-local ivy-display-functions-alist
                  (remq (assoc 'ivy-completion-in-region ivy-display-functions-alist)
                        ivy-display-functions-alist)))
    :bind (:map eshell-mode-map
                ([remap eshell-pcomplete] . completion-at-point))
    :hook ((eshell-mode . esh-autosuggest-mode)
           (eshell-mode . setup-eshell-ivy-completion)))

  ;; Eldoc support
  (use-package esh-help
    :init (setup-esh-help-eldoc))

  ;; `cd' to frequent directory in eshell
  (use-package eshell-z
    :hook (eshell-mode
           .
           (lambda () (require 'eshell-z)))))


(use-package eshell-git-prompt
  ;; show git status and branch
  :ensure t
  :config
  (eshell-git-prompt-use-theme 'powerline)
  )

;; Shell Pop
(use-package shell-pop
  :ensure t
  :defer 2
  :bind (:map my-personal-map
              ("x" . shell-pop))
  ;; :bind ([f9] . shell-pop)
  :custom
  (shell-pop-full-span t)
  (shell-pop-shell-type '("eshell" "*eshell" (lambda nil (eshell))))
  :config
  ;; ;;shell terminal
  ;; (setq shell-pop-shell-type (quote ("ansi-term" "*ansi-term*" (lambda nil (ansi-term shell-pop-term-shell)))))
  ;; (setq shell-pop-term-shell "/bin/bash")
  ;; (setq shell-pop-universal-key "C-t") ;use for eshell keybind

  ;; need to do this manually or not picked up by `shell-pop'
  (shell-pop--set-shell-type 'shell-pop-shell-type shell-pop-shell-type)
  )


;;; Code folding
(use-package outshine
  ;; Hide/show header for easy navigation to give a feel of Org Mode
  ;; outside Org major-mode. Use <C-M i> or <S-Tab>
  ;; use set-selective-display (C-x $) for ad-hock prefix argument
  :ensure t
  :defer 3
  :bind (:map outshine-mode-map
              ("<S-<backtab>" . outshine-cycle-buffer)
              ;; ("<backtab>" . outshine-cycle-buffer) ;; For Windows
              )
  :hook ((emacs-lisp-mode ess-r-mode prog-mode) . outshine-mode)
  :config
  (setq outshine-cycle-emulate-tab t))

(use-package hideshow
  :bind (("C-c TAB" . hs-toggle-hiding)
         ;; ("C-c h" . hs-toggle-hiding)
         ("M-+" . hs-show-all)
         :map my-assist-map
         ("-" . hs-toggle-hiding)
         ("+" . hs-show-all)
         )
  :init (add-hook #'prog-mode-hook #'hs-minor-mode)
  :diminish hs-minor-mode
  :config
  ;; Automatically open a block if you search for something where it matches
  (setq hs-isearch-open t)

  ;; Add `json-mode' and `javascript-mode' to the list
  (setq hs-special-modes-alist
        (mapcar 'purecopy
                '((c-mode "{" "}" "/[*/]" nil nil)
                  (ess-mode "{" "}" "/(*/)" nil nil)
                  (c++-mode "{" "}" "/[*/]" nil nil)
                  (java-mode "{" "}" "/[*/]" nil nil)
                  (js-mode "{" "}" "/[*/]" nil)
                  (json-mode "{" "}" "/[*/]" nil)
                  (javascript-mode  "{" "}" "/[*/]" nil))))

  ;; only show method names and signatures, hiding the bodies
  (defvar eos/hs-level 2
    "Default level to hide at when calling
    `eos/fold-show-only-methods'. This is buffers may set this to
    be buffer-local.")

  (setq eos/hs-fold-show-only-methods-active-p nil)
  (defun eos/hs-fold-show-only-methods ()
    "Toggle between hiding all methods using `eos/hs-level' or
showing them."
    (interactive)
    (save-excursion
      (if eos/hs-fold-show-only-methods-active-p
          (progn
            (hs-show-all)
            (setq-local eos/hs-fold-show-only-methods-active-p nil))
        (progn
          (goto-char (point-min))
          (hs-hide-level eos/hs-level)
          (setq-local eos/hs-fold-show-only-methods-active-p t)))))

  (global-set-key (kbd "C-c h") 'eos/hs-fold-show-only-methods)
  )


;;;; File explorer
(use-package neotree
  :ensure t
  :defer 3
  :bind ("<f4>" . neotree-toggle)
  :init
  (progn
    (setq-default neo-smart-open t) ;  every time when the neotree window is
                                        ;  opened, it will try to find current
                                        ;  file and jump to node.
    (setq-default neo-dont-be-alone t) ; Don't allow neotree to be the only open
                                        ; window
    )
  :config
  (progn
    (setq neo-theme 'ascii) ; 'classic, 'nerd, 'ascii, 'arrow

    (setq neo-vc-integration '(face char))

    ;; Patch to fix vc integration
    (defun neo-vc-for-node (node)
      (let* ((backend (vc-backend node))
             (vc-state (when backend (vc-state node backend))))
        ;; (message "%s %s %s" node backend vc-state)
        (cons (cdr (assoc vc-state neo-vc-state-char-alist))
              (cl-case vc-state
                (up-to-date       neo-vc-up-to-date-face)
                (edited           neo-vc-edited-face)
                (needs-update     neo-vc-needs-update-face)
                (needs-merge      neo-vc-needs-merge-face)
                (unlocked-changes neo-vc-unlocked-changes-face)
                (added            neo-vc-added-face)
                (removed          neo-vc-removed-face)
                (conflict         neo-vc-conflict-face)
                (missing          neo-vc-missing-face)
                (ignored          neo-vc-ignored-face)
                (unregistered     neo-vc-unregistered-face)
                (user             neo-vc-user-face)
                (t                neo-vc-default-face)))))

    (defun ybk/neotree-go-up-dir ()
      (interactive)
      (goto-char (point-min))
      (forward-line 2)
      (neotree-change-root))

    ;; http://emacs.stackexchange.com/a/12156/115
    (defun ybk/find-file-next-in-dir (&optional prev)
      "Open the next file in the directory.
    When PREV is non-nil, open the previous file in the directory."
      (interactive "P")
      (let ((neo-init-state (neo-global--window-exists-p)))
        (if (null neo-init-state)
            (neotree-show))
        (neo-global--select-window)
        (if (if prev
                (neotree-previous-line)
              (neotree-next-line))
            (progn
              (neo-buffer--execute nil
                                   (quote neo-open-file)
                                   (lambda (full-path &optional arg)
                                     (message "Reached dir: %s/" full-path)
                                     (if prev
                                         (neotree-next-line)
                                       (neotree-previous-line)))))
          (progn
            (if prev
                (message "You are already on the first file in the directory.")
              (message "You are already on the last file in the directory."))))
        (if (null neo-init-state)
            (neotree-hide))))

    (defun ybk/find-file-prev-in-dir ()
      "Open the next file in the directory."
      (interactive)
      (ybk/find-file-next-in-dir :prev))

    (bind-keys
     :map neotree-mode-map
     ("^"          . ybk/neotree-go-up-dir)
     ("C-c +"      . ybk/find-file-next-in-dir)
     ("C-c -"      . ybk/find-file-prev-in-dir)
     ("<C-return>" . neotree-change-root)
     ("C"          . neotree-change-root)
     ("c"          . neotree-create-node)
     ("+"          . neotree-create-node)
     ("d"          . neotree-delete-node)
     ("r"          . neotree-rename-node)
     ("h"          . neotree-hidden-file-toggle)
     ("f"          . neotree-refresh)))
  )


(use-package ztree
  ;;Had diff mode with M-x ztree-diff or ordinary tree with ztree-dir
  ;; https://github.com/fourier/ztree
  :ensure t
  :bind (
         :map my-personal-map
         ("z" . ztree-dir)
         ("Z" . ztree-diff)
         )
  :config
  ;; ignore case and whitespace differences
  (setq ztree-diff-additional-options '("-w" "-i"))
  )

;;; ESS
;; C-c general keymap for ESS
;; C-c C-t for debugging
;; C-c C-d explore object
;; Tooltips
;; C-c C-d C-e ess-describe-object-at-point
(use-package ess-mode
  :ensure ess
  :bind ((:map my-prog-map
               ("r" . run-ess-r-newest))
         (:map inferior-ess-mode-map
               ;; Usually I bind C-z to `undo', but I don't really use `undo' in
               ;; inferior buffers. Use it to switch to the R script (like C-c
               ;; C-z):
               ("C-z" . ess-switch-to-inferior-or-script-buffer)))
  :config
  (defun ess-company-stop-hook ()
    "Disabled company in inferior ess."
    (interactive)
    (company-mode -1))
  (add-hook 'inferior-ess-mode-hook 'ess-company-stop-hook)
  ;; Alternative
  ;; (setq company-global-modes '(not inferior-ess-mode))
  )

(use-package ess-r-mode
  :ensure ess
  ;; :mode ("\\.r[R]\\'" . ess-r-mode)
  ;; :commands (R
  ;;            R-mode
  ;;            r-mode)
  :init
  ;; Tetapkan Rsetting folder
  (defvar ybk/r-dir "~/Rsetting/") ;definere hvor epost skal være
  ;; lage direktori om ikke allerede finnes
  (unless (file-exists-p ybk/r-dir)
    (make-directory ybk/r-dir t))

  :bind (("C-c d" . ess-r-package-dev-map)
         ("C-c +" . my-add-column)
         ("C-c ," . my-add-match)
         :map ess-r-mode-map
         ("M--" . ess-cycle-assign)
         ;; ("C-c +" . my-add-column)
         ;; ("C-c ," . my-add-match)
         ("C-c \\" . my-add-pipe)
         ("M-|" . my-ess-eval-pipe-through-line)
         ("C-S-<return>" . ess-eval-region-or-function-or-paragraph-and-step)
         ("C-." . ess-eval-paragraph-and-step)
         ("M-." . ess-eval-paragraph-and-go)
         ("C-S-<tab>" . ess-indent-region-with-styler)

         :map inferior-ess-r-mode-map
         ("C-S-<up>" . ess-readline) ;previous command from script
         ("M--" . ess-cycle-assign)
         ("M-Q" . ess-interrupt)
         )

  :custom
  (inferior-R-program-name "c:/Program Files/R/R-4.0.2/bin/R.exe")
  (ess-plain-first-buffername nil "Name first R process R:1")
  (ess-tab-complete-in-script t "TAB should complete.")
  (ess-style 'RStudio)
  ;; (ess-use-company t "ESS company")
  (ess-use-auto-complete 'script-only "use auto-complete instead of company")

  :config
  ;; Must-haves for ESS
  ;; http://www.emacswiki.org/emacs/CategoryESS
  (setq ess-eval-visibly 'nowait) ;print input without waiting the process to finish

  ;; Auto-scrolling of R console to bottom and Shift key extension
  ;; http://www.kieranhealy.org/blog/archives/2009/10/12/make-shift-enter-do-a-lot-in-ess/
  ;; Adapted with one minor change from Felipe Salazar at
  ;; http://www.emacswiki.org/emacs/ESSShiftEnter
  (setq ess-local-process-name "R")
  (setq ansi-color-for-comint-mode 'filter)
  (setq comint-prompt-read-only t)
  (setq comint-scroll-to-bottom-on-input t)
  (setq comint-scroll-to-bottom-on-output t)
  (setq comint-move-point-for-output t)

  ;; inferior not read-only
  ;; https://github.com/emacs-ess/ESS/issues/300#issuecomment-231314374
  (add-hook 'inferior-ess-mode-hook
            (lambda()
              (setq-local comint-use-prompt-regexp nil)
              (setq-local inhibit-field-text-motion nil)))

  ;; ;; Don't indent comments with one #
  ;; (defun my-ess-settings ()
  ;;   (setq ess-indent-with-fancy-comments nil))
  ;; (add-hook 'ess-mode-hook #'my-ess-settings)

  ;; ess-trace-bug.el
  (setq ess-use-tracebug t) ; permanent activation
  (setq ess-tracebug-inject-source-p t)

  ;;
  ;; Tooltip included in ESS
  (setq ess-describe-at-point-method 'tooltip) ; 'tooltip or nil (buffer)

  ;; (require 'ess-r-args)
  ;; (require 'ess-R-object-tooltip)
  ;; (define-key ess-mode-map (kbd "C-c 1") 'r-show-head)
  ;; (define-key ess-mode-map (kbd "C-c 2") 'r-show-str)

  (setq inferior-R-args "--no-save")
  (setq ess-R-font-lock-keywords
        '((ess-R-fl-keyword:modifiers . t)
          (ess-R-fl-keyword:fun-defs . t)
          (ess-R-fl-keyword:keywords . t)
          (ess-R-fl-keyword:assign-ops . t)
          (ess-R-fl-keyword:constants . t)
          (ess-fl-keyword:fun-calls . nil)
          (ess-fl-keyword:numbers . t)
          (ess-fl-keyword:operators . t)
          (ess-fl-keyword:delimiters . nil)
          (ess-fl-keyword:= . t)
          (ess-R-fl-keyword:F&T . t)
          (ess-R-fl-keyword:%op% . t)))
  (setq inferior-ess-r-font-lock-keywords
        '((ess-S-fl-keyword:prompt . t)
          (ess-R-fl-keyword:messages . t)
          (ess-R-fl-keyword:modifiers . t)
          (ess-R-fl-keyword:fun-defs . t)
          (ess-R-fl-keyword:keywords . t)
          (ess-R-fl-keyword:assign-ops . t)
          (ess-R-fl-keyword:constants . t)
          (ess-fl-keyword:matrix-labels . t)
          (ess-fl-keyword:fun-calls . nil)
          (ess-fl-keyword:numbers . nil)
          (ess-fl-keyword:operators . nil)
          (ess-fl-keyword:delimiters . nil)
          (ess-fl-keyword:= . nil)
          (ess-R-fl-keyword:F&T . nil)))


  ;; use styler package but it has to be install first
  (defun ess-indent-region-with-styler (beg end)
    "Format region of code R using styler::style_text()."
    (interactive "r")
    (let ((string
           (replace-regexp-in-string
            "\"" "\\\\\\&"
            (replace-regexp-in-string ;; how to avoid this double matching?
             "\\\\\"" "\\\\\\&"
             (buffer-substring-no-properties beg end))))
          (buf (get-buffer-create "*ess-command-output*")))
      (ess-force-buffer-current "Process to load into:")
      (ess-command
       (format
        "local({options(styler.colored_print.vertical = FALSE);styler::style_text(text = \"\n%s\", reindention = styler::specify_reindention(regex_pattern = \"###\", indention = 0), indent_by = 4)})\n"
        string) buf)
      (with-current-buffer buf
        (goto-char (point-max))
        ;; (skip-chars-backward "\n")
        (let ((end (point)))
          (goto-char (point-min))
          (goto-char (1+ (point-at-eol)))
          (setq string (buffer-substring-no-properties (point) end))
          ))
      (delete-region beg end)
      (insert string)
      (delete-char -1)
      ))


  ;; data.table update
  (defun my-add-column ()
    "Adds a data.table update."
    (interactive)
    ;;(just-one-space 1) ;delete whitespace around cursor
    (insert " := "))

  ;; Match
  (defun my-add-match ()
    "Adds match."
    (interactive)
    (insert " %in% "))

  ;; pipe
  (defun my-add-pipe ()
    "Adds a pipe operator %>% with one space to the left and then
  starts a newline with proper indentation"
    (interactive)
    (just-one-space 1)
    (insert "%>%")
    (ess-newline-and-indent))

  ;; Get commands run from script or console
  ;; https://stackoverflow.com/questions/27307757/ess-retrieving-command-history-from-commands-entered-in-essr-inferior-mode-or
  (defun ess-readline ()
    "Move to previous command entered from script *or* R-process and copy
     to prompt for execution or editing"
    (interactive)
    ;; See how many times function was called
    (if (eq last-command 'ess-readline)
        (setq ess-readline-count (1+ ess-readline-count))
      (setq ess-readline-count 1))
    ;; Move to prompt and delete current input
    (comint-goto-process-mark)
    (end-of-buffer nil) ;; tweak here
    (comint-kill-input)
    ;; Copy n'th command in history where n = ess-readline-count
    (comint-previous-prompt ess-readline-count)
    (comint-copy-old-input)
    ;; Below is needed to update counter for sequential calls
    (setq this-command 'ess-readline)
    )

  ;; I sometimes want to evaluate just part of a piped sequence. The
  ;; following lets me do so without needing to insert blank lines or
  ;; something:
  (defun my/ess-beginning-of-pipe-or-end-of-line ()
    "Find point position of end of line or beginning of pipe %>%"
    (if (search-forward "%>%" (line-end-position) t)
        (let ((pos (progn
                     (beginning-of-line)
                     (search-forward "%>%" (line-end-position))
                     (backward-char 3)
                     (point))))
          (goto-char pos))
      (end-of-line)))

  (defun my-ess-eval-pipe-through-line (vis)
    "Like `ess-eval-paragraph' but only evaluates up to the pipe on this line.
 If no pipe, evaluate paragraph through the end of current line.
 Prefix arg VIS toggles visibility of ess-code as for `ess-eval-region'."
    (interactive "P")
    (save-excursion
      (let ((end (progn
                   (my/ess-beginning-of-pipe-or-end-of-line)
                   (point)))
            (beg (progn (backward-paragraph)
                        (ess-skip-blanks-forward 'multiline)
                        (point))))
        (ess-eval-region beg end vis))))


  ;; Run ShinyApp
  ;; Source  https://jcubic.wordpress.com/2018/07/02/run-shiny-r-application-from-emacs/
  (defun shiny ()
    "run shiny R application in new shell buffer
if there is displayed buffer that have shell it will use that window"
    (interactive)
    (let* ((R (concat "shiny::runApp('" default-directory "')"))
           (name "*shiny*")
           (new-buffer (get-buffer-create name))
           (script-proc-buffer
            (apply 'make-comint-in-buffer "script" new-buffer "R" nil `("-e" ,R)))
           (window (get-window-with-mode '(comint-mode eshell-mode)))
           (script-proc (get-buffer-process script-proc-buffer)))
      (if window
          (set-window-buffer window new-buffer)
        (switch-to-buffer-other-window new-buffer))))

  (defun search-window-buffer (fn)
    "return first window for which given function return non nil value"
    (let ((buffers (buffer-list))
          (value))
      (dolist (buffer buffers value)
        (let ((window (get-buffer-window buffer)))
          (if (and window (not value) (funcall fn buffer window))
              (setq value window))))))

  (defun get-window-with-mode (modes)
    "return window with given major modes"
    (search-window-buffer (lambda (buff window)
                            ((let ((mode (with-current-buffer buffer major-mode)))
                               (member mode modes))))))

  )




;; View data like View()
(use-package ess-R-data-view
  ;; Use M-x ess-R-dv-ctable or ess-R-dv-pprint
  :after ess
  :bind (:map my-prog-map
              ("t" . ess-R-dev-ctable)
              ("p" . ess-R-dev-pprint)))

;; Open buffer to test R code
(use-package test-r
  :ensure nil
  :bind (:map my-prog-map
              ("b" . test-R-buffer))
  :init
  (defun test-R-buffer ()
    "Create a new empty buffer with R-mode."
    (interactive)
    (let (($buf (generate-new-buffer "*r-test*"))
          (test-mode2 (quote R-mode)))
      (switch-to-buffer $buf)
      (insert (format "## == Test %s == \n\n" "R script"))
      (funcall test-mode2)
      (setq buffer-offer-save t)
      $buf
      ))
  )




;;; Markdown
;; Code highlighting via polymode
(use-package markdown-mode
  :ensure t
  :mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-command "markdown")
  )

(use-package polymode
  :ensure markdown-mode
  :ensure poly-R
  :ensure poly-noweb
  :ensure fold-this
  :config
  ;; R/tex polymodes
  (add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.rnw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))

  )


(use-package poly-markdown
  :ensure polymode
  :ensure markdown-mode
  :defer t
  :config
  ;; Wrap lines at column limit, but don't put hard returns in
  (add-hook 'markdown-mode-hook (lambda () (visual-line-mode 1)))
  ;; Flyspell on
  (add-hook 'markdown-mode-hook (lambda () (flyspell-mode 1)))
  )

;; poly-R
(use-package poly-R
  :ensure polymode
  :ensure poly-markdown
  :ensure poly-noweb
  :defer t
  :bind(:map polymode-map
             ("i" . rmd-insert-r-chunk))
  :config
  ;; Add a chunk for rmarkdown
  ;; Need to add a keyboard shortcut
  ;; https://emacs.stackexchange.com/questions/27405/insert-code-chunk-in-r-markdown-with-yasnippet-and-polymode
  ;; (defun insert-r-chunk (header)
  ;;   "Insert an r-chunk in markdown mode. Necessary due to interactions between polymode and yas snippet"
  ;;   (interactive "sHeader: ")
  ;;   (insert (concat "```{r " header "}\n\n\n```"))
  ;;   (forward-line -2))
  ;; (define-key poly-markdown+r-mode-map (kbd "M-c") #'insert-r-chunk)
  ;;Masukkan R-chunk M-n M-i

  (defun polymode-insert-new-chunk ()
    (interactive)
    (insert "\n```{r}\n")
    (save-excursion
      (newline)
      (insert "```\n")
      (previous-line)))

  ;; Masukkan R-chunk cara lain
  ;; https://emacs.stackexchange.com/questions/27405/insert-code-chunk-in-r-markdown-with-yasnippet-and-polymode
  (defun rmd-insert-r-chunk (header)
    "Insert an r-chunk in markdown mode. Necessary due to interactions between polymode and yas snippet"
    (interactive "sHeader: ")
    (insert (concat "```{r " header "}\n\n```"))
    (forward-line -1))
  )

;; Add yaml to markdown an .yml files
(use-package yaml-mode
  :ensure t
  :mode (("\\.yml\\'" . yaml-mode)))



;;; Appearance
;; (use-package naysayer-theme)
;; (load-theme 'naysayer t)

(use-package doom-themes
  :ensure t
  :init
  ;; need to load at init for cyclye theme to work
  (load-theme 'doom-one t)
  :bind ("C-9" . cycle-my-theme)
  :config
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)

  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)

  ;; utk tukar tema f10-t
  (setq my-themes '(doom-nord
                    doom-nord-light
                    doom-vibrant
                    doom-acario-light
                    doom-gruvbox
                    doom-tomorrow-day
                    doom-solarized-dark
                    ))

  (setq my-cur-theme nil)
  (defun cycle-my-theme ()
    "Cycle through a list of themes, my-themes"
    (interactive)
    (when my-cur-theme
      (disable-theme my-cur-theme)
      (setq my-themes (append my-themes (list my-cur-theme))))
    (setq my-cur-theme (pop my-themes))
    (load-theme my-cur-theme :no-confirm)
    (message "Tema dipakai: %s" my-cur-theme))

  ;; Switch to the first theme in the list above
  (cycle-my-theme)
  )

(use-package solaire-mode
  ;; visually distinguish file-visiting windows from other types of windows (like popups or sidebars) by giving them a
  ;; slightly different -- often brighter -- background
  :defer 3
  ;; :hook
  ;; ((change-major-mode after-revert ediff-prepare-buffer) . turn-on-solaire-mode)
  ;; (minibuffer-setup . solaire-mode-in-minibuffer)
  :config
  (solaire-mode-swap-bg)
  (solaire-global-mode +1))


;; Adjust for time display in modeline
(defface egoge-display-time
  '((((type x w32 mac))
     ;; #006655 is the background colour of my default face.
     (:foreground "#0be" :inherit bold))
    (((type tty))
     (:foreground "blue")))
  "Face used to display the time in the mode line.")


;; This causes the current time in the mode line to be displayed in
;; `egoge-display-time-face' to make it stand out visually.
(setq display-time-string-forms
      '((propertize (concat " " 24-hours ":" minutes " ")
                    'face 'egoge-display-time)))

;; display time
(display-time-mode 1)

;; from https://dev.to/gonsie/beautifying-the-mode-line-3k10
(setq-default mode-line-format
              (list
               ;; day and time
               '(:eval (propertize (format-time-string " %b %d %H:%M ")
                                   'face 'font-lock-builtin-face))


               '(:eval (propertize (substring vc-mode 5)
                                   'face 'font-lock-comment-face))

               ;; the buffer name; the file name as a tool tip
               '(:eval (propertize " %b "
                                   'face
                                   (let ((face (buffer-modified-p)))
                                     (if face 'font-lock-warning-face
                                       'font-lock-type-face))
                                   'help-echo (buffer-file-name)))

               ;; line and column
               " (" ;; '%02' to set to 2 chars at least; prevents flickering
               (propertize "%02l" 'face 'font-lock-keyword-face) ","
               (propertize "%02c" 'face 'font-lock-keyword-face)
               ") "

               ;; relative position, size of file
               " ["
               (propertize "%p" 'face 'font-lock-constant-face) ;; % above top
               "/"
               (propertize "%I" 'face 'font-lock-constant-face) ;; size
               "] "

               ;; spaces to align right
               '(:eval (propertize
                        " " 'display
                        `((space :align-to (- (+ right right-fringe right-margin)
                                              ,(+ 3 (string-width mode-name)))))))

               ;; the current major mode
               (propertize " %m " 'face 'font-lock-string-face)
               ;;minor-mode-alist
               ))


(use-package doom-modeline
  ;; Run M-x all-the-icons-install-fonts to install all-the-icons
  :ensure t
  :custom
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon nil)
  (doom-modeline-minor-modes nil)
  (inhibit-compacting-font-caches t "Don't compact font caches during GC in windows")
  :hook
  (after-init . doom-modeline-mode)
  :config
  ;;https://github.com/seagle0128/doom-modeline/issues/93
  (defvar doom-modeline-icon (display-graphic-p)
    "Whether show `all-the-icons' or not.

Non-nil to show the icons in mode-line.
The icons may not be showed correctly in terminal and on Windows.")
  
  (set-face-attribute 'mode-line nil
                      :background "#353644"
                      :foreground "white"
                      :box '(:line-width 6 :color "#353644")
                      :overline nil
                      :underline nil)

  (set-face-attribute 'mode-line-inactive nil
                      :background "#565063"
                      :foreground "white"
                      :box '(:line-width 6 :color "#565063")
                      :overline nil
                      :underline nil)

  )

;; Show hexadecimal color in the background they represent
(use-package rainbow-mode
  :ensure t
  :diminish rainbow-mode
  :hook
  ((prog-mode
    inferior-ess-mode
    ess-mode text-mode
    markdown-mode
    LaTeX-mode) . rainbow-mode)
  )

