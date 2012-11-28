
(setq load-path (append load-path (list "/usr/share/emacs/site-lisp")))
(load "/usr/share/emacs/site-lisp/site-start.el")
(rc-schemers)

(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(setq make-backup-files nil)
