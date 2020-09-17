;;; init.el --- straight config  -*- lexical-binding: t; coding:utf-8; fill-column: 119 -*-

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


;;; Bootstrap `straight.el'
;; Clone straight.el to ~/.emacs.d/straight/repos/straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Bootstrap `use-package'
(setq-default use-package-always-defer t ; Always defer load package to speed up startup time
              use-package-verbose nil ; Don't report loading details
              use-package-expand-minimally t  ; make the expanded code as minimal as possible
              use-package-enable-imenu-support t) ; Let imenu finds use-package definitions


;; Integration with use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t) ;always-ensure
(use-package git) ;;ensure to be able to install from git source


;;; Garbage collector
(use-package gcmh
  :straight t
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
  :straight nil
  :bind (:map my-personal-map
              ("y" . my-init-file)
              ("0" . save-buffers-kill-emacs)
              ("q" . delete-frame) ;C-x 5 0
              ("<delete>" . kill-emacs)
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
;; Use setq-default to define global default
(setq-default 
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

;;;; Windows paths
(when (string-equal system-type "windows-nt") ())

;;;; Encoding
;; Encoding for all system
;; https://stackoverflow.com/questions/2901541/which-coding-system-should-i-use-in-emacs/2903256#2903256
;; Else use C-x RET f (set-buffer-file-coding-system) then save the file
;; with selected encoding
(setq utf-translate-cjk-mode nil) ; disable CJK coding/encoding (Chinese/Japanese/Korean characters)
(set-language-environment 'utf-8)
(set-keyboard-coding-system 'utf-8-mac) ; For old Carbon emacs on OS X only
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-selection-coding-system
 (if (eq system-type 'windows-nt)
     'utf-16-le  ;; https://rufflewind.com/2014-07-20/pasting-unicode-in-emacs-on-windows
   'utf-8))
(prefer-coding-system 'utf-8)

;;; Misc
(set-frame-name "Emacs the Great")
;; replaced active region by typing txt or DEL
(delete-selection-mode 1)
;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)
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
  :straight t
  :bind (("C-<f12>" . beacon-blink)) ;; useful when multiple windows
  :config
  (setq beacon-size 10)
  (beacon-mode 1))

;; don't bind C-x C-z to suspend-frame:
(unbind-key "C-x C-z")
;; if frame freeze then use xkill -frame $emacs

;; (require 'cl) ;Old Common Lisp library eg. defstruct, incf etc
(require 'cl-lib) ;;include Common Lisp compatibility eg. cl-defstruct, cl-incf etc
(use-package f :demand t) ;; files
(use-package dash :demand t) ;; lists
(use-package ht :demand t) ;; hash-tables
(use-package s :demand t) ;; strings
(use-package a :demand t) ;; association lists
(use-package anaphora :demand t) ;; anaphora for implicit temp variable of Emacs Lisp expressions
(use-package hydra)

(use-package which-key
  :custom
  ;; (which-key-show-early-on-C-h t "Allow C-h to trigger which-key b4 it's done automatically")
  (which-key-idle-delay 1.0)
  (which-key-idle-secondary-delay 0.05)
  (which-key-popup-type 'minibuffer)
  :config
  ;; (setq which-key-idle-delay 1.0)
  (which-key-mode)

  ;; Rename for resize-buffer menu
  (which-key-add-key-based-replacements
    "C-c w" "eyebrowse")
  )

(use-package whole-line-or-region
  ;; If no region is active, C-w and M-w will act on current line
  :bind (:map whole-line-or-region-local-mode-map
              ("<M-backspace>" . kill-region-or-backward-word)) ;; Reserve for backward-kill-word
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
  :straight t
  :bind (("C--" . default-text-scale-decrease)
         ("C-+" . default-text-scale-increase))
  :config
  (default-text-scale-mode))


;;; General for programming
(defun comment-eclipse ()
  "For commenting code."
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
               ("<return>" . crux-cleanup-buffer-or-region)
               ("K" . crux-kill-other-buffers))
         )
  :init
  (global-set-key [remap move-beginning-of-line] #'crux-move-beginning-of-line)
  (global-set-key [(shift return)] #'crux-smart-open-line)
  (global-set-key [remap kill-whole-line] #'crux-kill-whole-line)

  :config
  ;; Retain indentation in these modes.
  (add-to-list 'crux-indent-sensitive-modes 'markdown-mode)
  )

(use-package page-scrolling
  ;; http://pragmaticemacs.com/emacs/scrolling-and-moving-by-line/
  :straight nil
  :init
  ;; preserve cursor position when scrolling
  (setq scroll-preserve-screen-position 1)
  ;; scrool windows up/down by 3 lines
  (global-set-key (kbd "C-<prior>") (kbd "C-u 3 M-v"))
  (global-set-key (kbd "C-<next>") (kbd "C-u 3 C-v"))
  )


(use-package simple
  ;; Improvements over simple editing commands
  :straight nil
  :defer 5
  :hook ((prog-mode) . auto-fill-mode)
  ;; resize buffer accordingly
  :bind
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
  :straight t
  :bind ("C-:" . iedit-mode)
  )


(use-package multiple-cursors
  ;; Read https://github.com/magnars/multiple-cursors.el for common use cases
  :straight t
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
  :straight t
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
  :straight ivy-hydra ;activated with C-o in ivy-minor-mode
  :straight ivy-rich
  :straight counsel-projectile
  :straight ivy-posframe
  :straight smex
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
  :straight t
  :config
  (add-hook 'shell-mode-hook  'with-editor-export-editor)
  (add-hook 'term-exec-hook   'with-editor-export-editor)
  (add-hook 'eshell-mode-hook 'with-editor-export-editor)
  )

(use-package magit
  :defer 10
  ;;:straight gitignore-templates
  :straight diff-hl
  :straight git-gutter
  :straight ov
  :straight smerge-mode
  :straight git-timemachine
  ;;display flycheck errors only on added/modified lines
  :straight magit-todos
  :straight ediff
  :straight magit-diff-flycheck
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
  :straight t
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
    :straight t
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
  :straight t
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
  :straight nil
  :bind (:map my-assist-map
              ("E" . ediff)
              ("B" . diff-buffer-with-file) ;view changes in the buffer to file
              ("C" . ediff-current-file) ;for interactive ediff buffer and file
              )
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
(use-package resize-window
  :straight nil
  :init
  (defun win-resize-top-or-bot ()
    "Figure out if the current window is on top, bottom or in the
  middle"
    (let* ((win-edges (window-edges))
           (this-window-y-min (nth 1 win-edges))
           (this-window-y-max (nth 3 win-edges))
           (fr-height (frame-height)))
      (cond
       ((eq 0 this-window-y-min) "top")
       ((eq (- fr-height 1) this-window-y-max) "bot")
       (t "mid"))))

  (defun win-resize-left-or-right ()
    "Figure out if the current window is to the left, right or in the
  middle"
    (let* ((win-edges (window-edges))
           (this-window-x-min (nth 0 win-edges))
           (this-window-x-max (nth 2 win-edges))
           (fr-width (frame-width)))
      (cond
       ((eq 0 this-window-x-min) "left")
       ((eq (+ fr-width 4) this-window-x-max) "right")
       (t "mid"))))

  (defun win-resize-enlarge-horiz ()
    (interactive)
    (cond
     ((equal "top" (win-resize-top-or-bot)) (enlarge-window -1))
     ((equal "bot" (win-resize-top-or-bot)) (enlarge-window 1))
     ((equal "mid" (win-resize-top-or-bot)) (enlarge-window -1))
     (t (message "nil"))))

  (defun win-resize-minimize-horiz ()
    (interactive)
    (cond
     ((equal "top" (win-resize-top-or-bot)) (enlarge-window 1))
     ((equal "bot" (win-resize-top-or-bot)) (enlarge-window -1))
     ((equal "mid" (win-resize-top-or-bot)) (enlarge-window 1))
     (t (message "nil"))))

  (defun win-resize-enlarge-vert ()
    (interactive)
    (cond
     ((equal "left" (win-resize-left-or-right)) (enlarge-window-horizontally -1))
     ((equal "right" (win-resize-left-or-right)) (enlarge-window-horizontally 1))
     ((equal "mid" (win-resize-left-or-right)) (enlarge-window-horizontally -1))))

  (defun win-resize-minimize-vert ()
    (interactive)
    (cond
     ((equal "left" (win-resize-left-or-right)) (enlarge-window-horizontally 1))
     ((equal "right" (win-resize-left-or-right)) (enlarge-window-horizontally -1))
     ((equal "mid" (win-resize-left-or-right)) (enlarge-window-horizontally 1))))

  (global-set-key [C-S-down] 'win-resize-minimize-vert)
  (global-set-key [C-S-up] 'win-resize-enlarge-vert)
  (global-set-key [C-S-left] 'win-resize-minimize-horiz)
  (global-set-key [C-S-right] 'win-resize-enlarge-horiz)
  (global-set-key [C-S-up] 'win-resize-enlarge-horiz)
  (global-set-key [C-S-down] 'win-resize-minimize-horiz)
  (global-set-key [C-S-left] 'win-resize-enlarge-vert)
  (global-set-key [C-S-right] 'win-resize-minimize-vert)
  )


(use-package windmove
  :straight nil
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
  :straight nil
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
  :straight t
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
  ;; make backgound gray for different buffer with aw-background
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
  :straight t
  :bind* (:map my-personal-map
               ("V" . golden-ratio-mode)
               ("v" . golden-ratio))
  :diminish golden-ratio-mode
  :init
  ;; (golden-ratio-mode 1)
  (setq golden-ratio-auto-scale t))


(use-package transpose-frame
  :straight t
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
  :straight nil
  :bind* (:map my-assist-map
               ("<SPC>" . point-to-register)
               ("j" . jump-to-register)))

;;;; Bookmark
(use-package bookmark
  :straight t
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
  :straight ripgrep ;; required by projectile-ripgrep
  :straight which-key ;; to rename C-c p
  :bind-keymap
  ("C-c p" . projectile-command-map)
  ;; :bind* (("C-c p f" . 'projectile-find-file))
  :bind (:map projectile-command-map
              ("f" . projectile-find-file)
              ("p" . counsel-switch-project))
  :init
  ;; catch projects
  (setq projectile-enable-caching t)
  ;; for ignoring by file .projectile
  (setq projectile-indexing-method 'native)
  ;; reorder
  (setq projectile-project-root-files #'( ".projectile"))
  (setq projectile-project-root-files-functions  #'(projectile-root-top-down
                                                    projectile-root-top-down-recurring
                                                    projectile-root-bottom-up
                                                    projectile-root-local))
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
  :straight t
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
  :straight rainbow-delimiters
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
  :straight t
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
         ;; ("C-S-<right>"     . sp-forward-slurp-sexp) ;include exp4 when in exp3
         ;; ("C-S-<left>"      . sp-backward-slurp-sexp) ;include exp1 when in exp2
         ;; ("C-M-<right>"   . sp-forward-barf-sexp) ;remove exp4 from ()
         ;; ("C-M-<left>"    . sp-backward-barf-sexp) ;remove exp2 from ()
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
  :straight t
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
  :straight t
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
  (find-function-after . reposition-window)
  :config
  
  ;; Rename for find-function
  (which-key-add-key-based-replacements
    "C-s x" "find-xxx")
  )


(use-package aggressive-indent
  :straight t
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


(use-package company
  :straight company-quickhelp ; Show short documentation at point
  :straight company-shell
  ;; :bind* ("C-i" . company-complete) ;activate globally doesn't work in Swiper
  :bind (
         :map company-active-map
         ("C-c ?" . company-quickhelp-manual-begin)
         ;; Deactivate default M-n and M-h for convinence in inferior-R buffer
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous)
         ("C-d" . company-show-doc-buffer)
         ("<tab>" . company-complete)
         ("C-i" . company-complete-common)
         :map my-search-map
         ("c" . company-mode)
         ("<tab>" . company-complete-selection)
         )
  :custom
  (company--show-numbers nil "Show number not optimal when writing R code")
  (company-tooltip-flip-when-above t "Invert navigation when at the bottom windows")
  (company-tooltip-align-annotations t "Align")
  (company-tooltip-limit 6 "List to show")
  (company-idle-delay .2 "Delay before autocomplete popup")
  (company-minimum-prefix-length 4 "Number of prefix before popup")
  (company-abort-manual-when-too-short t "No autocomplete if below minimum prefix")
  :config
  (global-company-mode t)

  ;; Directly press [1..9] to insert candidates
  ;; See http://oremacs.com/2017/12/27/company-numbers/
  (defun ora-company-number ()
    "Forward to `company-complete-number'.
Unless the number is potentially part of the candidate.
In that case, insert the number."
    (interactive)
    (let* ((k (this-command-keys))
           (re (concat "^" company-prefix k)))
      (if (or (cl-find-if (lambda (s) (string-match re s))
                          company-candidates)
              (> (string-to-number k)
                 (length company-candidates)))
          (self-insert-command 1)
        (company-complete-number
         (if (equal k "0")
             10
           (string-to-number k))))))

  (let ((map company-active-map))
    (mapc (lambda (x) (define-key map (format "%d" x) 'ora-company-number))
          (number-sequence 0 9))
    (define-key map " " (lambda ()
                          (interactive)
                          (company-abort)
                          (self-insert-command 1)))
    (define-key map (kbd "<return>") nil))

  ;; company-shell
  (add-to-list 'company-backends 'company-shell)

  ;; aktifkan di org-mode selepas pastikan company-capf di company-backends
  ;; https://github.com/company-mode/company-mode/issues/50
  (defun add-pcomplete-to-capf ()
    (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t))
  (add-hook 'org-mode-hook #'add-pcomplete-to-capf)


  )



;;;; Heuristic text completion: hippie expand + dabbrev
(use-package hippie-exp
  :straight nil
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
  :straight nil
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
                eshell-prompt-function 'epe-theme-dakrone))

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
  :straight t
  :config
  (eshell-git-prompt-use-theme 'powerline)
  )

;; Shell Pop
(use-package shell-pop
  :straight t
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
  :straight t
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
         :map my-prog-map
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
  :straight t
  :defer 3
  :bind (:map my-neotree-map
              ("<f4>"       . neotree-toggle)
              ("<prior>"    . ybk/neotree-go-up-dir)
              ("+"          . ybk/find-file-next-in-dir)
              ("-"          . ybk/find-file-prev-in-dir)
              ("<C-return>" . neotree-change-root)
              ("C"          . neotree-change-root)
              ("c"          . neotree-create-node)
              ("+"          . neotree-create-node)
              ("d"          . neotree-delete-node)
              ("r"          . neotree-rename-node)
              ("h"          . neotree-hidden-file-toggle)
              ("g"          . neotree-refresh)
              ("A"          . neotree-stretch-toggle)
              )
  
  :init
  (unbind-key [f4])
  (bind-keys :prefix [f4]
             :prefix-map my-neotree-map)

  (progn
    (setq-default neo-smart-open t) ;  every time when the neotree window is
                                        ;  opened, it will try to find current
                                        ;  file and jump to node.
    (setq-default neo-dont-be-alone t) ; Don't allow neotree to be the only open
                                        ; window
    )
  :config
  ;; (setq neo-theme 'classic) ; 'classic, 'nerd, 'ascii, 'arrow
  ;;use icon for window and arrow for terminal
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))

  ;; https://emacs.stackexchange.com/questions/37678/neotree-window-not-resizable
  (setq neo-window-fixed-size nil)
  ;; Set the neo-window-width to the current width of the
  ;; neotree window, to trick neotree into resetting the
  ;; width back to the actual window width.
  ;; Fixes: https://github.com/jaypei/emacs-neotree/issues/262
  (eval-after-load "neotree"
    '(add-to-list 'window-size-change-functions
                  (lambda (frame)
                    (let ((neo-window (neo-global--get-window)))
                      (unless (null neo-window)
                        (setq neo-window-width (window-width neo-window)))))))

  (progn
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

    ;; (bind-keys
    ;;  :map neotree-mode-map
    ;;  ("<prior>"          . ybk/neotree-go-up-dir)
    ;;  ("C-c +"      . ybk/find-file-next-in-dir)
    ;;  ("C-c -"      . ybk/find-file-prev-in-dir)
    ;;  ("<C-return>" . neotree-change-root)
    ;;  ("C"          . neotree-change-root)
    ;;  ("c"          . neotree-create-node)
    ;;  ("+"          . neotree-create-node)
    ;;  ("d"          . neotree-delete-node)
    ;;  ("r"          . neotree-rename-node)
    ;;  ("h"          . neotree-hidden-file-toggle)
    ;;  ("g"          . neotree-refresh))
    )
  )


(use-package ztree
  ;;Had diff mode with M-x ztree-diff or ordinary tree with ztree-dir
  ;; https://github.com/fourier/ztree
  :straight t
  :bind (
         :map my-neotree-map
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
  :straight ess
  :bind ((:map my-prog-map
               ("r" . run-ess-r-newest))
         (:map inferior-ess-mode-map
               ;; Usually I bind C-z to `undo', but I don't really use `undo' in
               ;; inferior buffers. Use it to switch to the R script (like C-c
               ;; C-z):
               ([S-return] . ess-switch-to-inferior-or-script-buffer)))
  :config
  (defun ess-company-stop-hook ()
    "Disabled company in inferior ess."
    (interactive)
    (company-mode -1))
  (add-hook 'inferior-ess-mode-hook 'ess-company-stop-hook)
  ;; Alternative
  ;; (setq company-global-modes '(not inferior-ess-mode))
  )

;;;; R
(use-package ess-r-mode
  :straight ess
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
  ;; (inferior-R-program-name "c:/Program Files/R/R-4.0.2/bin/R.exe")
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
  :straight nil
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

;;;; Stata
;; specify PATH guide https://emacs.stackexchange.com/questions/27326/gui-emacs-sets-the-exec-path-only-from-windows-environment-variable-but-not-from
(use-package ess-stata-mode
  ;; This has been taken out from ESS https://github.com/emacs-ess/ESS/issues/1033
  :disabled
  :straight ess
  :mode (("\\.do" . stata-mode)
         ("\\.ado" . stata-mode))
  :init
  ;; (add-to-list 'exec-path "C:/Program Files/Stata16")
  ;; (setenv "PATH" (mapconcat #'identity exec-path path-separator))
  (if (eq system-type 'windows-nt)
      (progn
        (add-to-list 'exec-path "C:/Program Files/Stata16")
        (setenv "PATH" (mapconcat #'identity exec-path path-separator))
        ))
  )

;; Ado-mode consiste script (send2stata.exe) and template dir which is not in lisp that need
;; to be specified. Therefore using straight will give errors since straight does
;; not include those directories. Else clone repos from github.
;; Open Stata and M-RET to run code ie. send2stata
(use-package ado-mode
  ;; https://github.com/louabill/ado-mode
  ;; :straight (ado-mode :type git :host github :repo "louabill/ado-mode")
  :straight nil
  :load-path "C:/Users/ybka/AppData/Roaming/lisp/ado-mode-1.16.1.1/lisp"
  :mode (("\\.do" . ado-mode)
         ("\\.ado" . ado-mode))
  ;; :hook (ado-mode . company-mode)
  :hook (ado-mode . auto-complete-mode)
  :hook (ado-mode . rainbow-delimiters-mode)
  :hook (ado-mode . smartparens-mode)
  :hook (ado-mode . smartparens-strict-mode)
  :custom
  ;; (ado-script-dir "C:/Users/ybka/AppData/Roaming/lisp/ado-mode-1.16.1.1/scripts")
  (ado-mode-home "C:/Users/ybka/AppData/Roaming/lisp/ado-mode-1.16.1.1/")
  (ado-script-dir
   "C:/Users/ybka/AppData/Roaming/lisp/ado-mode-1.16.1.1/scripts")
  (ado-site-template-dir
   "C:/Users/ybka/AppData/Roaming/lisp/ado-mode-1.16.1.1/templates/")
  )

;;; Markdown
;; Code highlighting via polymode
(use-package markdown-mode
  :straight t
  :mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-command "markdown")
  )

(use-package polymode
  :straight markdown-mode
  :straight poly-R
  :straight poly-noweb
  :straight fold-this
  :config
  ;; R/tex polymodes
  (add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.rnw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))

  )


(use-package poly-markdown
  :straight polymode
  :straight markdown-mode
  :defer t
  :config
  ;; Wrap lines at column limit, but don't put hard returns in
  (add-hook 'markdown-mode-hook (lambda () (visual-line-mode 1)))
  ;; Flyspell on
  (add-hook 'markdown-mode-hook (lambda () (flyspell-mode 1)))
  )

;; poly-R
(use-package poly-R
  :straight polymode
  :straight poly-markdown
  :straight poly-noweb
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
  :straight t
  :mode (("\\.yml\\'" . yaml-mode)))



;;; Latex
;;pdf-tools is better but difficult to get it in Windows
(use-package doc-view
  :defer t
  :custom
  ;; Use MikTeX's utilities for PDF conversion and searching
  (doc-view-ghostscript-program "mgs.exe")
  (doc-view-pdf->png-converter-function 'doc-view-pdf->png-converter-ghostscript)
  (doc-view-pdftotext-program "miktex-pdftotext.exe")
  ;; MikTeX's utilities also for vieweing DVI files
  (doc-view-dvipdfm-program "dvipdfm.exe")
  ;; I install Libreoffice using Scoop as a portable, standalone
  ;; executable. This is the location of the utility within there.
  (doc-view-odf->pdf-converter-program "~/scoop/apps/libreoffice-stable/current/App/libreoffice/program/soffice.exe")
  (doc-view-odf->pdf-converter-function 'doc-view-odf->pdf-converter-soffice)
  )

;;; Org
(use-package org
  ;; Org mode is a great thing. I use it for writing academic papers,
  ;; managing my schedule, managing my references and notes, writing
  ;; presentations, writing lecture slides, and pretty much anything
  ;; else.
  :straight org-plus-contrib
  :bind
  (("C-c l" . org-store-link)
   ("C-'" . org-cycle-agenda-files) ; quickly access agenda files
   :map org-mode-map
   ("C-a" . org-beginning-of-line)
   ("C-e" . org-end-of-line)
   ;; Bind M-p and M-n to navigate heading more easily (these are bound to
   ;; C-c C-p/n by default):
   ("M-p" . my/org-previous-visible-heading)
   ("M-n" . my/org-next-visible-heading)
   ;; C-c C-t is bound to `org-todo' by default, but I want it
   ;; bound to C-c t as well:
   ("C-c t" . org-todo)
   ;; Show hidden link
   ("M-L" . my/org-toggle-link-display)
   )
  :hook
  (org-mode . my/setup-org-mode)
  :custom
  (org-blank-before-new-entry nil)
  (org-cycle-separator-lines 0)
  (org-pretty-entities t "UTF8 all the things!")
  (org-support-shift-select t "Holding shift and moving point should select things.")
  (org-fontify-quote-and-verse-blocks t "Provide a special face for quote and verse blocks.")
  (org-M-RET-may-split-line nil "M-RET may never split a line.")
  (org-enforce-todo-dependencies t "Can't finish parent before children.")
  (org-enforce-todo-checkbox-dependencies t "Can't finish parent before children.")
  (org-hide-emphasis-markers t "Make words italic or bold, hide / and *.")
  (org-catch-invisible-edits 'show-and-error "Don't let me edit things I can't see.")
  (org-special-ctrl-a/e t "Make C-a and C-e work more like how I want:.")
  (org-preview-latex-default-process 'imagemagick "Let org's preview mechanism use imagemagick instead of dvipng.")
  ;; Let imenu go deeper into menu structure
  (org-imenu-depth 6)
  (org-image-actual-width '(300))
  (org-blank-before-new-entry '((heading . nil)
                                (plain-list-item . nil)))
  ;; For whatever reason, I have to explicitely tell org how to open pdf
  ;; links.  I use pdf-tools.  If pdf-tools isn't installed, it will use
  ;; doc-view (shipped with Emacs) instead.
  (org-file-apps
   '((auto-mode . emacs)
     ("\\.mm\\'" . default)
     ("\\.x?html?\\'" . default)
     ("\\.pdf\\'" . emacs)))
  (org-highlight-latex-and-related '(latex entities) "set up fontlocking for latex")
  (org-startup-with-inline-images t "Show inline images.")
  (org-log-done 'time)
  (org-goto-interface 'outline-path-completion)
  (org-ellipsis "..►") ;; symbol for hiding content 
  ;; tags within start-endgroup will allow only one of those in a file
  ;; C-c C-q for setting tags
  (org-tag-persistent-alist '(("annent" . ?a)
                              ("prog" . ?p)
                              ("fhi" . ?f)
                              (:startgroup . nil)
                              ("@work" . ?w)
                              ("@home" . ?h)
                              (:endgroup . nil)))

  ;; I keep my recipes in an org file and tag them based on what kind of
  ;; dish they are.  The level one headings are names, and each gets two
  ;; level two headings --- ingredients and directions.  To easily search via
  ;; tag, I can restrict org-agenda to that buffer using < then hit m to
  ;; match based on a tag.
  (org-tags-exclude-from-inheritance
   '("BREAKFAST" "DINNER" "DESSERT" "SIDE" "CHICKEN" "SEAFOOD"
     "BEEF" "PASTA" "SOUP" "SNACK" "DRINK" "LAMB" "VEGETARIAN"))
  ;; Org-refile lets me quickly move around headings in org files.  It
  ;; plays nicely with org-capture, which I use to turn emails into TODOs
  ;; easily (among other things, of course)
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-refile-use-outline-path 'file)
  (org-refile-targets '((org-agenda-files . (:maxlevel . 6)))"Up to 6 level deep headlines")

  :custom-face
  (org-block ((t (:inherit default))))

  :config
  ;; Exclude DONE state tasks from refile targets
  (defun ybk/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets"
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))

  (setq org-refile-target-verify-function 'ybk/verify-refile-target)
  

  ;; These are the programming languages org should teach itself:
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (latex . t)
     (python . t)
     (R . t)
     (shell . t)))

  ;; remove C-c [ from adding or excluding org file to front of agenda
  ;; other then those specified in org-agenda-files
  (unbind-key "C-c [" org-mode-map)
  (unbind-key "C-c ]" org-mode-map)

  (defun my/setup-org-mode ()
    "Setup org-mode."
    ;; An alist of symbols to prettify, see `prettify-symbols-alist'.
    ;; Whether the symbol actually gets prettified is controlled by
    ;; `org-pretty-compose-p', which see.
    (setq-local prettify-symbols-unprettify-at-point nil)
    (setq-local prettify-symbols-alist '(("*" . ?●)))
    (setq-local prettify-symbols-compose-predicate #'my/org-pretty-compose-p))

  (defun my/org-next-visible-heading (arg)
    "Go to next heading and beginning of line."
    (interactive "p")
    (org-next-visible-heading arg)
    (org-beginning-of-line))

  (defun my/org-previous-visible-heading (arg)
    "Go to previous heading and beginning of line."
    (interactive "p")
    (org-previous-visible-heading arg)
    (org-beginning-of-line))

  (defun my/org-pretty-compose-p (start end match)
    "Return it if the symbol should be prettified.
START and END are the start and end points, MATCH is the string
match.  See also `prettify-symbols-compose-predicate'."
    (if (string= match "*")
        ;; prettify asterisks in headings
        (and (org-match-line org-outline-regexp-bol)
             (< end (match-end 0)))
      ;; else rely on the default function
      (prettify-symbols-default-compose-p start end match)))

  ;; use font-lock-mode or this function
  (defun my/org-toggle-link-display ()
    "Toggle the literal or descriptive display of links."
    (interactive)
    (if org-descriptive-links
        (progn (org-remove-from-invisibility-spec '(org-link))
               (org-restart-font-lock)
               (setq org-descriptive-links nil))
      (progn (add-to-invisibility-spec '(org-link))
             (org-restart-font-lock)
             (setq org-descriptive-links t))))


  ;; to enable <s[TAB] https://github.com/syl20bnr/spacemacs/issues/11798
  ;; else M-x org-insert-structure-template
  (require 'org-tempo)

  ;; Code block shortcuts instead of <s[TAB]
  (defun my-org-insert-src-block (src-code-type)
    "Insert a `SRC-CODE-TYPE' type source code block in org-mode."
    (interactive
     (let ((src-code-types
            '("emacs-lisp" "python" "sh" "calc" "R" "latex")))
       (list (ivy-completing-read "Source code type: " src-code-types))))
    (progn
      (newline-and-indent)
      (insert "#+END_SRC\n")
      (previous-line 2)
      (insert (format "#+BEGIN_SRC %s\n" src-code-type))
      (org-edit-src-code)))

  (bind-key "C-c s" #'my-org-insert-src-block org-mode-map)


  ;; ;; ---- for ESS souce block start ----
  ;; ;; This will use defined :dir in properties as the working directory
  ;; ;; https://emacs.stackexchange.com/questions/57907/set-ess-working-directory-from-header-args-with-org-babel-sessions
  ;; ;; Get :dir
  ;; (defun org-header-arg (p)
  ;;   (setq args (org-babel-get-src-block-info))
  ;;   (assoc-default p (nth 2 args)))

  ;; ;; Get language of source block
  ;; (defun get-src-language ()
  ;;   (setq args (org-babel-get-src-block-info))
  ;;   (nth 0 args))

  ;; ;; Send message to R process
  ;; (defun send-msg-r (w)
  ;;   (ess-send-string 
  ;;    (get-process "R")
  ;;    (format "setwd(\"%s\")" w)))

  ;; ;; If point is in an R code block then if R is running: setwd()
  ;; ;; Else if R is not running, run R and setwd().  
  ;; (defun setwd-dir ()
  ;;   (if (string= (get-src-language) "R")
  ;;       (if (eq (get-process "R") nil)
  ;;           (progn 
  ;;             (setq w (org-header-arg :dir)) ;; Capture before R redirects
  ;;             (defadvice R (after set-working-dir-R activate) (send-msg-r w))
  ;;             (save-excursion (R)))
  ;;         (send-msg-r (org-header-arg :dir)))))

  ;; ;; Advise org-edit-special
  ;; (defadvice org-edit-special (before set-working-dir activate)
  ;;   (setwd-dir))

  ;; ;; Advise org-babel-execute-src-block
  ;; (defadvice org-babel-execute-src-block (before set-working-dir-b activate) 
  ;;   (setwd-dir))
  ;; ;;-------- ESS end -------
  
  
  ;; surround command https://github.com/alphapapa/unpackaged.el#surround-region-with-emphasis-or-syntax-characters
  ;; block the text and use the surround selected KEY
  ;;###autoload
  (defmacro unpackaged/def-org-maybe-surround (&rest keys)
    "Define and bind interactive commands for each of KEYS that surround the region or insert text.
Commands are bound in `org-mode-map' to each of KEYS.  If the
region is active, commands surround it with the key character,
otherwise call `org-self-insert-command'."
    `(progn
       ,@(cl-loop for key in keys
                  for name = (intern (concat "unpackaged/org-maybe-surround-" key))
                  for docstring = (format "If region is active, surround it with \"%s\", otherwise call `org-self-insert-command'." key)
                  collect `(defun ,name ()
                             ,docstring
                             (interactive)
                             (if (region-active-p)
                                 (let ((beg (region-beginning))
                                       (end (region-end)))
                                   (save-excursion
                                     (goto-char end)
                                     (insert ,key)
                                     (goto-char beg)
                                     (insert ,key)))
                               (call-interactively #'org-self-insert-command)))
                  collect `(define-key org-mode-map (kbd ,key) #',name))))

  ;; activate surround command
  (unpackaged/def-org-maybe-surround "~" "=" "*")


  ;; how to use org-return https://github.com/alphapapa/unpackaged.el#org-return-dwim
  (defun unpackaged/org-element-descendant-of (type element)
    "Return non-nil if ELEMENT is a descendant of TYPE.
TYPE should be an element type, like `item' or `paragraph'.
ELEMENT should be a list like that returned by `org-element-context'."
    ;; MAYBE: Use `org-element-lineage'.
    (when-let* ((parent (org-element-property :parent element)))
      (or (eq type (car parent))
          (unpackaged/org-element-descendant-of type parent))))

  ;;###autoload
  (defun unpackaged/org-return-dwim (&optional default)
    "A helpful replacement for `org-return'.  With prefix, call `org-return'.
On headings, move point to position after entry content.  In
lists, insert a new item or end the list, with checkbox if
appropriate.  In tables, insert a new row or end the table."
    ;; Inspired by John Kitchin: http://kitchingroup.cheme.cmu.edu/blog/2017/04/09/A-better-return-in-org-mode/
    (interactive "P")
    (if default
        (org-return)
      (cond
       ;; Act depending on context around point.

       ;; NOTE: I prefer RET to not follow links, but by uncommenting this block, links will be
       ;; followed.

       ;; ((eq 'link (car (org-element-context)))
       ;;  ;; Link: Open it.
       ;;  (org-open-at-point-global))

       ((org-at-heading-p)
        ;; Heading: Move to position after entry content.
        ;; NOTE: This is probably the most interesting feature of this function.
        (let ((heading-start (org-entry-beginning-position)))
          (goto-char (org-entry-end-position))
          (cond ((and (org-at-heading-p)
                      (= heading-start (org-entry-beginning-position)))
                 ;; Entry ends on its heading; add newline after
                 (end-of-line)
                 (insert "\n\n"))
                (t
                 ;; Entry ends after its heading; back up
                 (forward-line -1)
                 (end-of-line)
                 (when (org-at-heading-p)
                   ;; At the same heading
                   (forward-line)
                   (insert "\n")
                   (forward-line -1))
                 ;; FIXME: looking-back is supposed to be called with more arguments.
                 (while (not (looking-back (rx (repeat 3 (seq (optional blank) "\n")))))
                   (insert "\n"))
                 (forward-line -1)))))

       ((org-at-item-checkbox-p)
        ;; Checkbox: Insert new item with checkbox.
        (org-insert-todo-heading nil))

       ((org-in-item-p)
        ;; Plain list.  Yes, this gets a little complicated...
        (let ((context (org-element-context)))
          (if (or (eq 'plain-list (car context))  ; First item in list
                  (and (eq 'item (car context))
                       (not (eq (org-element-property :contents-begin context)
                                (org-element-property :contents-end context))))
                  (unpackaged/org-element-descendant-of 'item context))  ; Element in list item, e.g. a link
              ;; Non-empty item: Add new item.
              (org-insert-item)
            ;; Empty item: Close the list.
            ;; TODO: Do this with org functions rather than operating on the text. Can't seem to find the right function.
            (delete-region (line-beginning-position) (line-end-position))
            (insert "\n"))))

       ((when (fboundp 'org-inlinetask-in-task-p)
          (org-inlinetask-in-task-p))
        ;; Inline task: Don't insert a new heading.
        (org-return))

       ((org-at-table-p)
        (cond ((save-excursion
                 (beginning-of-line)
                 ;; See `org-table-next-field'.
                 (cl-loop with end = (line-end-position)
                          for cell = (org-element-table-cell-parser)
                          always (equal (org-element-property :contents-begin cell)
                                        (org-element-property :contents-end cell))
                          while (re-search-forward "|" end t)))
               ;; Empty row: end the table.
               (delete-region (line-beginning-position) (line-end-position))
               (org-return))
              (t
               ;; Non-empty row: call `org-return'.
               (org-return))))
       (t
        ;; All other cases: call `org-return'.
        (org-return)))))

  ;; TODO keywords
  (setq org-todo-keywords
        (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
                (sequence "HOLD(h@/!)" "CANCELLED(c@/!)"))))

  ;;Menyenagkan utk tukar kekunci TODO dengan C-c C-t KEKUNCI (org-todo-keywords)
  (setq org-use-fast-todo-selection t)

  ;;Tetapkan warna keyword
  (setq org-todo-keyword-faces
        (quote (("TODO" :foreground "red" :weight bold)
                ("NEXT" :foreground "purple" :weight bold)
                ("DONE" :foreground "forest green" :weight bold)
                ("HOLD" :foreground "magenta" :weight bold)
                ("CANCELLED" :foreground "dark green" :weight bold)
                )))


  ;;== Buat TAGS automatik
  ;; Status TODO memberikan atau menukarkan tag secara automatisk. Cth ke status 'HOLD'
  ;; memberikan tag 'HOLD' dan ke status 'DONE' membuang tag 'HOLD' dan 'CANCELLED'
  (setq org-todo-state-tags-triggers
        (quote (("CANCELLED" ("CANCELLED" . t))
                ("HOLD" ("HOLD" . t))
                (done ("HOLD"))
                ("TODO" ("CANCELLED") ("HOLD"))
                ("NEXT" ("CANCELLED") ("HOLD"))
                ("DONE" ("CANCELLED") ("HOLD")))))

  ;; Utk tukar status TODO menggunakan S-kiri dan S-kanan dan elakkan proses biasa seperti memasukkan masa
  ;; atau nota utk HOLD atau CANCELLED sekiranya yang ingin dibuat ialah pertukaran status TODO sahaja
  (setq org-treat-S-cursor-todo-selection-as-state-change nil)

  ;;== Tukar parents status ke "DONE" hanya bila semua child tasks sudah ke status "DONE"
  (setq org-enforce-todo-dependencies t
        org-enforce-todo-checkbox-dependencies t)

  ;;== Masukkan annotation di task bila tukar status
  (setq org-log-done (quote time))

  ;;== Masukkan annotation bila tukar tarikh DEADLINE
  (setq org-log-redeadline (quote time))

  ;;== Masukkan annotation bila tukar tarikh SCHEDULE
  (setq org-log-reschedule (quote time))


  ;; =================================
  ;; Export HTML with usefule anchors
  ;; https://github.com/alphapapa/unpackaged.el#export-to-html-with-useful-anchors
  (define-minor-mode unpackaged/org-export-html-with-useful-ids-mode
    "Attempt to export Org as HTML with useful link IDs.
Instead of random IDs like \"#orga1b2c3\", use heading titles,
made unique when necessary."
    :global t
    (if unpackaged/org-export-html-with-useful-ids-mode
        (advice-add #'org-export-get-reference :override #'unpackaged/org-export-get-reference)
      (advice-remove #'org-export-get-reference #'unpackaged/org-export-get-reference)))

  (defun unpackaged/org-export-get-reference (datum info)
    "Like `org-export-get-reference', except uses heading titles instead of random numbers."
    (let ((cache (plist-get info :internal-references)))
      (or (car (rassq datum cache))
          (let* ((crossrefs (plist-get info :crossrefs))
                 (cells (org-export-search-cells datum))
                 ;; Preserve any pre-existing association between
                 ;; a search cell and a reference, i.e., when some
                 ;; previously published document referenced a location
                 ;; within current file (see
                 ;; `org-publish-resolve-external-link').
                 ;;
                 ;; However, there is no guarantee that search cells are
                 ;; unique, e.g., there might be duplicate custom ID or
                 ;; two headings with the same title in the file.
                 ;;
                 ;; As a consequence, before re-using any reference to
                 ;; an element or object, we check that it doesn't refer
                 ;; to a previous element or object.
                 (new (or (cl-some
                           (lambda (cell)
                             (let ((stored (cdr (assoc cell crossrefs))))
                               (when stored
                                 (let ((old (org-export-format-reference stored)))
                                   (and (not (assoc old cache)) stored)))))
                           cells)
                          (when (org-element-property :raw-value datum)
                            ;; Heading with a title
                            (unpackaged/org-export-new-title-reference datum cache))
                          ;; NOTE: This probably breaks some Org Export
                          ;; feature, but if it does what I need, fine.
                          (org-export-format-reference
                           (org-export-new-reference cache))))
                 (reference-string new))
            ;; Cache contains both data already associated to
            ;; a reference and in-use internal references, so as to make
            ;; unique references.
            (dolist (cell cells) (push (cons cell new) cache))
            ;; Retain a direct association between reference string and
            ;; DATUM since (1) not every object or element can be given
            ;; a search cell (2) it permits quick lookup.
            (push (cons reference-string datum) cache)
            (plist-put info :internal-references cache)
            reference-string))))

  (defun unpackaged/org-export-new-title-reference (datum cache)
    "Return new reference for DATUM that is unique in CACHE."
    (cl-macrolet ((inc-suffixf (place)
                               `(progn
                                  (string-match (rx bos
                                                    (minimal-match (group (1+ anything)))
                                                    (optional "--" (group (1+ digit)))
                                                    eos)
                                                ,place)
                                  ;; HACK: `s1' instead of a gensym.
                                  (-let* (((s1 suffix) (list (match-string 1 ,place)
                                                             (match-string 2 ,place)))
                                          (suffix (if suffix
                                                      (string-to-number suffix)
                                                    0)))
                                    (setf ,place (format "%s--%s" s1 (cl-incf suffix)))))))
      (let* ((title (org-element-property :raw-value datum))
             (ref (url-hexify-string (substring-no-properties title)))
             (parent (org-element-property :parent datum)))
        (while (--any (equal ref (car it))
                      cache)
          ;; Title not unique: make it so.
          (if parent
              ;; Append ancestor title.
              (setf title (concat (org-element-property :raw-value parent)
                                  "--" title)
                    ref (url-hexify-string (substring-no-properties title))
                    parent (org-element-property :parent parent))
            ;; No more ancestors: add and increment a number.
            (inc-suffixf ref)))
        ref)))
  )


(use-package ob-core
  :straight org
  ;; ob is org-babel, which lets org know about code and code blocks
  :defer t
  :custom
  ;; I know what I'm getting myself into.
  (org-confirm-babel-evaluate nil "Don't ask to confirm evaluation."))


(use-package org-agenda
  ;; Here's where I set which files are added to org-agenda, which controls
  ;; org's global todo list, scheduling, and agenda features.  I use
  ;; Syncthing to keep these files in sync across computers.
  :straight org
  :bind
  (("C-c a" . org-agenda)
   ("<f5>" . org-agenda)
   :map org-agenda-mode-map
   ;; overrides org-agenda-redo, which I use "g" for anyway
   ("r" . org-agenda-refile)
   ;; overrides saving all org buffers, also bound to C-x C-s
   ("t" . org-agenda-schedule)
   ("d" . my/org-agenda-mark-done)
   ("n" . my/org-agenda-mark-next)
   )

  :init
  ;; create org folder if doesn't exist
  (defvar my-org-directory "~/Dropbox/org")
  ;;(defvar my-org-directory "C:/Users/ybka/OneDrive - Folkehelseinstituttet/Dropbox/org")
  (unless (file-exists-p my-org-directory)
    (make-directory my-org-directory))

  (defvar my-org-todo (expand-file-name "todo.org" my-org-directory)
    "Unstructure capture")
  (defvar my-org-misc (expand-file-name "misc.org" my-org-directory)
    "All other info for diary.")
  (defvar my-org-note (expand-file-name "notes.org" my-org-directory)
    "All other info for diary.")
  (defvar my-org-meet (expand-file-name "meeting.org" my-org-directory)
    "All other info for diary.")
  (defvar my-org-cook (expand-file-name "cooking.org" my-org-directory)
    "All other info for diary.")


  ;;Include all files under these folder in org-agenda-files
  (setq org-agenda-files `(,org-default-notes-file
                           ,my-org-todo
                           ,my-org-misc
                           ,my-org-meet
                           ,my-org-cook))
  (setq org-agenda-text-search-extra-files `(,my-org-note))

  :custom
  (org-directory "~/Dropbox/org/" "Kept in sync with syncthing.")
  ;; (org-directory "C:/Users/ybka/OneDrive - Folkehelseinstituttet/Dropbox/org/" "Kept in sync with sync thing")
  (org-default-notes-file (concat org-directory "refile.org"))
  (org-agenda-skip-deadline-if-done t "Remove done deadlines from agenda.")
  (org-agenda-skip-scheduled-if-done t "Remove done scheduled from agenda.")
  (org-agenda-skip-timestamp-if-done t "Don't show timestamped things in agenda if they're done.")
  (org-agenda-skip-scheduled-if-deadline-is-shown 'not-today "Don't show scheduled if the deadline is visible unless it's also scheduled for today.")
  (org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled "Skip deadline warnings if it is scheduled.")
  (org-deadline-warning-days 3 "warn me 3 days before a deadline")
  (org-agenda-tags-todo-honor-ignore-options t "Ignore scheduled items in tags todo searches.")
  (org-agenda-tags-column 'auto)
  (org-agenda-window-setup 'only-window "Use current window for agenda.")
  (org-agenda-restore-windows-after-quit t "Restore previous config after I'm done.")
  (org-agenda-span 'day) ; just show today. I can "vw" to view the week
  (org-agenda-time-grid
   '((daily today remove-match) (800 1000 1200 1400 1600 1800 2000)
     "" "") "By default, the time grid has a lot of ugly '-----' lines. Remove those.")
  (org-agenda-scheduled-leaders '("" "%2dx ") "I don't need to know that something is scheduled.  That's why it's appearing on the agenda in the first place.")
  (org-agenda-block-separator ?- "Use nice unicode character instead of ugly = to separate agendas:")
  (org-agenda-deadline-leaders '("Deadline: " "In %d days: " "OVERDUE %d day: ") "Make deadlines, especially overdue ones, stand out more:")
  (org-agenda-current-time-string "---> NOW <---")
  ;; The agenda is ugly by default. It doesn't properly align items and it
  ;; includes weird punctuation. Fix it:
  (org-agenda-prefix-format '((agenda . "%-12c%-14t%s")
                              (todo . " %i %-12:c")
                              (tags . " %i %-12:c")
                              (search . " %i %-12:c")))

  ;; Custom agenda
  (org-agenda-custom-commands
   '(
     ("h" "Home Agenda"
      ((agenda "" nil)
       (todo "NEXT"
             ((org-agenda-max-entries 5)
              (org-agenda-overriding-header "Dagens oppgaver:")
              ))
       (tags "@home"
             ((org-agenda-overriding-header "Samlet oppgaver:")
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "NEXT" "CANCELLED")))))
       (tags "REFILE"
             ((org-agenda-overriding-header "Refile:")
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "NEXT" "CANCELLED"))))))
      ((org-agenda-tag-filter-preset '("-@work"))))
     ("w" "Work Agenda"
      ((agenda "" nil)
       (todo "NEXT"
             ((org-agenda-max-entries 5)
              (org-agenda-overriding-header "Dagens oppgaver:")
              ))
       (tags "@work"
             ((org-agenda-overriding-header "Skal gjøres:")
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "NEXT" "CANCELLED")))))
       (tags "REFILE"
             ((org-agenda-overriding-header "Refile:")
              (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DONE" "NEXT" "CANCELLED"))))))
      ((org-agenda-tag-filter-preset '("-@home"))))
     ("d" "deadlines"
      ((agenda ""
               ((org-agenda-entry-types '(:deadline))
                (org-agenda-span 'fortnight)
                (org-agenda-time-grid nil)
                (org-deadline-warning-days 0)
                (org-agenda-skip-deadline-prewarning-if-scheduled nil)
                (org-agenda-skip-deadline-if-done nil)))))
     ("m" "Meetings"
      ((agenda "" nil)
       (tags "@meeting")))
     ("b" "bibliography"
      ((tags "CATEGORY=\"bib\"+LEVEL=2"
             ((org-agenda-overriding-header "")))))
     ("u" "unscheduled"
      ((todo  "TODO"
              ((org-agenda-overriding-header "Unscheduled tasks")
               (org-agenda-todo-ignore-with-date t)))))
     ("c" "Recepies"
      ((agenda "" nil)
       (tags "recepi")))
     ))

  :config
  (defun my/org-agenda-mark-done (&optional _arg)
    "Mark current TODO as DONE.
See `org-agenda-todo' for more details."
    (interactive "P")
    (org-agenda-todo "DONE"))

  (defun my/org-agenda-mark-next (&optional _arg)
    "Mark current TODO as NEXT.
See `org-agenda-todo' for more details."
    (interactive "P")
    (org-agenda-todo "NEXT"))
  )


(use-package org-capture
  ;; %^G to use tags
  :straight org
  :bind*
  ("C-c c" . org-capture)
  :bind
  ((:map org-capture-mode-map
         ("C-c C-j" . my/org-capture-refile-and-jump))
   (:map my-personal-map
         ("p" . ybk/org-task-capture)))
  :custom
  (org-capture-templates
   (quote (("t" "Todo" entry (file org-default-notes-file)
            "* TODO %? \nDEADLINE: %^T \n:PROPERTIES:\n:CREATED: %U\n:END:\n%i")
           ("d" "Task" entry (file org-default-notes-file)
            "* TODO %? \n:PROPERTIES:\n:CREATED: %U\n:END:\n%i")
           ("m" "Meeting" entry (file my-org-meet)
            "* %? \nSCHEDULED: %^T \n:PROPERTIES:\n:END:\n\n")
           ("e" "Mail" entry (file org-default-notes-file)
            "* TODO [#A] %?\nSCHEDULED: %(org-insert-time-stamp (org-read-date nil t \"+0d\"))\n%a\n")
           ("n" "Note" entry (file my-org-note)
            "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n %i")
           ("r" "Recepies" entry (file my-org-cook)
            "* %?\n:PROPERTIES:\n:TYPE:\n:CREATED: %U\n:END:\n %i")
           )))
  :config
  (defun my/org-capture-refile-and-jump ()
    (interactive)
    (org-capture-refile)
    (org-refile-goto-last-stored))

  ;; Org-capture shortcut
  (defun ybk/org-task-capture ()
    "Capture a task with my default template."
    (interactive)
    (org-capture nil "t"))
  )

;; Perhaps should define org-export-define-backend 
(use-package ox-pandoc
  ;; export with pandoc
  :after org
  :config
  ;; default options for all output formats
  (setq org-pandoc-options '((standalone . t)))
  )

(use-package ox-hugo
  ;; Use Hugo to build site https://ox-hugo.scripter.co/
  :after ox
  :config
  ;; Populates only the EXPORT_FILE_NAME property in the inserted headline.
  (with-eval-after-load 'org-capture
    (defun org-hugo-new-subtree-post-capture-template ()
      "Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more information."
      (let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
             (fname (org-hugo-slug title)))
        (mapconcat #'identity
                   `(
                     ,(concat "* TODO " title)
                     ":PROPERTIES:"
                     ,(concat ":EXPORT_FILE_NAME: " fname)
                     ":END:"
                     "%?\n")          ;Place the cursor here finally
                   "\n")))

    (add-to-list 'org-capture-templates
                 '("h"                ;`org-capture' binding + h
                   "Hugo post"
                   entry
                   ;; It is assumed that below file is present in `org-directory'
                   ;; and that it has a "Blog Ideas" heading. It can even be a
                   ;; symlink pointing to the actual location of all-posts.org!
                   (file+olp "all-posts.org" "Blog Ideas")
                   (function org-hugo-new-subtree-post-capture-template))))
  )


(use-package org-eww
  ;; Org-eww lets me capture eww webpages with org-mode
  :straight org
  :straight eww
  :after eww)

(use-package org-indent
  ;; org-indent-mode nicely aligns text with the outline level
  :straight org
  :hook
  (org-mode . org-indent-mode))

(use-package ox-gfm
  ;; to export to markdown
  ;; M-x org-gfm-export-to-markdown
  :straight t
  :after org
  :bind (:map my-assist-map
              ("d m" . org-gfm-export-to-markdown) ;export as file
              ("d a" . org-gfm-export-as-markdown) ;export as buffer
              )
  :init
  (eval-after-load "org"
    '(require 'ox-gfm nil t))

  :config
  (which-key-add-key-based-replacements
    "<f9> d" "org-exp-md")
  )

;;; JSON
(use-package json-mode
  :mode ("\\.json"))

;; M-x json-navigator-navigate-after-point
(use-package json-navigator)

;;; Spellcheck
;; This setting specifically for Windows
;; http://juanjose.garciaripoll.com/blog/my-emacs-windows-configuration/
;; https://www.reddit.com/r/emacs/comments/8by3az/how_to_set_up_sell_check_for_emacs_in_windows/
;; general guide for downloading hundspell http://www.nextpoint.se/?p=656
;; Dictionary https://github.com/LibreOffice/dictionaries
(use-package flyspell
  :init
  ;; Dictionary folder. Download from https://github.com/LibreOffice/dictionaries
  (setenv "DICTPATH" "C:/Users/ybka/AppData/Roaming/hunspell-1.3.2-3-w32/share/hunspell")
  ;; (setenv "DICTPATH" "C:/Users/ybka/scoop/apps/msys2/current/mingw64/share/hunspell")
  ;; (setenv "DICTIONARY"  "C:\\Users\\ybka\\AppData\\Roaming\\hunspell-1.3.2-3-w32\\share\\hunspell\\en_GB")
  :custom
  (ispell-program-name "C:\\Users\\ybka\\AppData\\Roaming\\hunspell-1.3.2-3-w32\\bin\\hunspell.exe")
  ;; ;;use the newest version installed via MSYS2
  ;; (ispell-program-name "C:/Users/ybka/scoop/apps/msys2/2020-09-03/mingw64/bin/hunspell.exe") 
  (ispell-extra-args '("-p" ,(expand-file-name "hunspell" my-emacs-cache)) "Save dict common location")
  :hook ((text-mode markdown-mode) . flyspell-mode)
  :hook ((prog-mode
          ess-mode
          ado-mode
          emacs-lisp-mode) . flyspell-prog-mode) ;check only for comments
  :bind (:map my-assist-map
              ("L n" . lang-norsk)
              ("L e" . lang-eng))
  :config
  (setq ispell-extra-args '("--sug-mude=ultra" ;normal|fast|ultra for speed
                            "--lang=en_GB"))
  
  (which-key-add-key-based-replacements
    "<f9> L" "change lang")
  
  (defun lang-norsk ()
    "Change to Norwegian."
    (interactive)
    (ispell-change-dictionary "nb_NO")
    (flyspell-buffer))

  (defun lang-eng ()
    "Change to English."
    (interactive)
    (ispell-change-dictionary "nb_GB")
    (flyspell-buffer))

  (add-to-list 'ispell-skip-region-alist '("^#+BEGIN_SRC" . "^#+END_SRC"))
  )

(use-package flyspell-correct
  ;; https://github.com/d12frosted/flyspell-correct
  :after flyspell
  :bind (
         :map flyspell-mode-map
         ("C-;" . flyspell-correct-wrapper)
         :map my-assist-map
         ("L-<left>" . flyspell-correct-previous)
         ("L-<right>" . flyspell-correct-next)
         ("L-<return>" . flyspell-corrent-at-point )))

(use-package flyspell-correct-ivy
  :after flyspell-correct)
;; How to ignore some words if flyspell can read here
;; https://stackoverflow.com/questions/4671908/how-to-make-flyspell-bypass-some-words-by-context


;;; Appearance
;; (use-package naysayer-theme)
;; (load-theme 'naysayer t)

(use-package doom-themes
  :straight t
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
                    doom-acario-light
                    doom-acario-dark
                    ;; doom-gruvbox
                    ;; doom-tomorrow-day
                    ;; doom-solarized-dark
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
     (:foreground "green" :inherit bold)) ;#0be
    (((type tty))
     (:foreground "dark red")))
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


(use-package all-the-icons
  :config
  (all-the-icons-octicon "file-binary")  ;; GitHub Octicon for Binary File
  (all-the-icons-faicon  "cogs")         ;; FontAwesome icon for cogs
  (all-the-icons-wicon   "tornado")      ;; Weather Icon for tornado

  ;; A workaround for missing all-the-icons in neotree when starting emacs in client mode
  ;; Ref:
  ;;   - https://github.com/jaypei/emacs-neotree/issues/194
  ;;   - https://emacs.stackexchange.com/questions/24609/determine-graphical-display-on-startup-for-emacs-server-client
  (defun new-frame-setup (frame)
    (if (display-graphic-p frame)
        (setq neo-theme 'icons)))
  ;; Run for already-existing frames (For single instance emacs)
  (mapc 'new-frame-setup (frame-list))
  ;; Run when a new frame is created (For emacs in client/server mode)
  (add-hook 'after-make-frame-functions 'new-frame-setup)
  )

(use-package doom-modeline
  ;; Run M-x all-the-icons-install-fonts to install all-the-icons
  :straight t
  :custom
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-icon (display-graphic-p))
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t "Display the colorful icon for major-mode")
  (doom-modeline-minor-modes nil)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-project-detection 'project)
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

  ;; enable modeline icons with daemon mode
  ;; http://sodaware.sdf.org/notes/emacs-daemon-doom-modeline-icons/
  (defun enable-doom-modeline-icons (_frame)
    (setq doom-modeline-icon t))
  
  (add-hook 'after-make-frame-functions 
            #'enable-doom-modeline-icons)
  
  )



;; Show hexadecimal color in the background they represent
(use-package rainbow-mode
  :straight t
  :diminish rainbow-mode
  :hook
  ((prog-mode
    inferior-ess-mode
    ess-mode text-mode
    markdown-mode
    LaTeX-mode) . rainbow-mode)
  )



;;; Extra
;;;; Straight related
;; https://www.manueluberti.eu/emacs/2019/11/02/thirty-straight-days/
(defun mu-straight-pull-or-prune (&optional prune)
  "Update all available packages via `straight'.
With PRUNE, prune the build cache and the build directory."
  (interactive "P")
  (if prune
      (when (y-or-n-p "Prune build cache and build directory?")
        (straight-prune-build-cache)
        (straight-prune-build-directory))
    (when (y-or-n-p "Update all available packages?")
      (straight-pull-all))))

(bind-key* "<f7>" #'mu-straight-pull-or-prune)

;;;; Calendar
;; Manual setup
(setq calendar-week-start-day 1
      calendar-day-name-array ["Søndag" "Mandag" "Tirsdag" "Onsdag"
                               "Torsdag" "Fredag" "Lørdag"]
      calendar-month-name-array ["Januar" "Februar" "Mars" "April" "Mai"
                                 "Juni" "Juli" "August" "September"
                                 "Oktober" "November" "Desember"])

(use-package calendar-norway
  ;; :custom
  ;; (calendar-holidays 'calendar-norway-raude-dagar "Include days where you don't have to work")
  ;; (calendar-holidays 'calendar-norway-andre-merkedagar "Include other days that people celebrate")
  ;; (calendar-holidays 'calendar-norway-dst "Daylight saving")
  :config
  ;; Set what holidays you want in your calendar:
  (setq calendar-holidays
        (append
         ;; Include days where you don't have to work:
         calendar-norway-raude-dagar
         ;; Include other days that people celebrate:
         calendar-norway-andre-merkedagar
         ;; Include daylight savings time:
         calendar-norway-dst
         ;; And then you can add some non-Norwegian holidays etc. if you like:
         '((holiday-fixed 3 17 "St. Patricksdag")
           (holiday-fixed 10 31 "Hallowe'en")
           (holiday-float 11 4 4 "Thanksgiving")
           (solar-equinoxes-solstices))))
  )

;;;; Weather
(use-package weather-metno
  :bind (:map my-personal-map
              ("w" . weather-metno-forecast))
  :init
  (setq weather-metno-location-name "Oslo, Norge"
        weather-metno-location-latitude 59
        weather-metno-location-longitude 10
        )
  (setq with-editor-emacsclient-executable "emacsclient")

  :config
  ;; ;; change icon size
  ;; (setq weather-metno-use-imagemagick t)
  ;; (setq weather-metno-get-image-props '(:width 10 :height 10 :ascent center))
  (setq weather-metno-get-image-props '(:ascent center))
  )

