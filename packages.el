;;; packages.el --- tabbar Layer packages File for Spacemacs
;;
;;
;; save as ~/.emacs.d/private/tabbar/packages.el
;; add to ~/.spacemacs layers `tabbar `
;;
;; please feel free to make this nicer and contribute it back
;;
;; original from: https://gist.github.com/3demax/1264635
;; This are setting for nice tabbar items
;; to have an idea of what it looks like http://imgur.com/b0SNN
;; inspired by Amit Patel screenshot http://www.emacswiki.org/pics/static/NyanModeWithCustomBackground.png

(defvar tabbar-packages
  '(
    ;; tabbar
    )
  "List of all packages to install and/or initialize. Built-in packages
which require an initialization must be listed explicitly in the list.")

(defvar tabbar-excluded-packages '()
  "List of packages to exclude.")

;; For each package, define a function tabbar/init-<package-tabbar>
;;
;; (defun tabbar/init-my-package ()
;;   "Initialize my package"
;;   )
;;
;; Often the body of an initialize function uses `use-package'
;; For more info on `use-package', see readme:
;; https://github.com/jwiegley/use-package
(defun tabbar/init-tabbar ()
  "Initialize tabbar"
  (use-package tabbar
    :config
    (spacemacs|define-transient-state tabbar
      :title "Tabbar"
      :doc "
[_j_] tabbar-forward-tab [_k_] tabbar-backward-tab
[_J_] tabbar-forward-group [_K_] tabbar-forward-group"
      :bindings
      ("q" nil :exit t)
      ("j" tabbar-forward-tab)
      ("k" tabbar-backward-tab)
      ("J" tabbar-forward-group)
      ("K" tabbar-backward-group))
    (spacemacs/set-leader-keys "ot" 'spacemacs/tabbar-transient-state/body)

    (setq tabbar-buffer-groups-function (lambda () '("asdf")))

    (setq jason/buffers ())
    (defun jason/add-to-my-buffers ()
      (interactive) (cl-pushnew (current-buffer) jason/buffers))
    ;; (print jason/buffers)
    ;; (jason/add-to-my-buffers)
    (global-set-key (kbd "H-<return>") #'jason/add-to-my-buffers)
    (defun jason/my-buffers ()
      "Buffers that I've opened. Used for tabbar"
      jason/buffers)

    (setq jason/recent-buffers ())
    ;; Mostly works, but the tabbar disappears whne opening a new buffer
    (defun jason/add-to-recent-buffers ()
      "Hold the most recently opened n buffers"
      (interactive)
      (progn
        (if (>= (length jason/recent-buffers) 10)
            (setq jason/recent-buffers (-drop-last 1 jason/recent-buffers)))
        (cl-pushnew (current-buffer) jason/recent-buffers)))
    (defun jason/remove-from-recent-buffers ()
      "Remove current buffer from recent buffers."
      (interactive)
      (progn
        (delete (current-buffer) jason/recent-buffers)))
    (defun jason/recent-buffers-func () jason/recent-buffers)
    (jason/recent-buffers-func)

    (defun set-tabbar-buffer-list ()
      (setq tabbar-buffer-list-function 'jason/recent-buffers-func))
    (set-tabbar-buffer-list)
    ;; The value is clobbered by persp-mode, so setting it in these hooks
    (add-hook 'prog-mode-hook #'set-tabbar-buffer-list)
    (add-hook 'text-mode-hook #'set-tabbar-buffer-list)
    (add-hook 'kill-buffer-hook #'jason/remove-from-recent-buffers)

    (global-set-key (kbd "H-<return>") #'jason/add-to-recent-buffers)

    :init
    (tabbar-mode 1)
    (set-face-attribute
     'tabbar-default nil
     :background "gray20"
     :foreground "gray20"
     :box '(:line-width 1 :color "gray20" :style nil))
    (set-face-attribute
     'tabbar-unselected nil
     :background "gray30"
     :foreground "white"
     :box '(:line-width 5 :color "gray30" :style nil))
    (set-face-attribute
     'tabbar-selected nil
     :background "gray75"
     :foreground "black"
     :box '(:line-width 5 :color "gray75" :style nil))
    (set-face-attribute
     'tabbar-highlight nil
     :background "white"
     :foreground "black"
     :underline nil
     :box '(:line-width 5 :color "white" :style nil))
    (set-face-attribute
     'tabbar-button nil
     :box '(:line-width 1 :color "gray20" :style nil))
    (set-face-attribute
     'tabbar-separator nil
     :background "gray20"
     :height 0.6)

    ;; Change padding of the tabs
    ;; we also need to set separator to avoid overlapping tabs by highlighted tabs
    (custom-set-variables
     '(tabbar-separator (quote (0.5))))
    ;; adding spaces
    (defun tabbar-buffer-tab-label (tab)
      "Return a label for TAB.
That is, a string used to represent it on the tab bar."
      (let ((label  (if tabbar--buffer-show-groups
                        (format "[%s]  " (tabbar-tab-tabset tab))
                      (format "%s  " (tabbar-tab-value tab)))))
        ;; Unless the tab bar auto scrolls to keep the selected tab
        ;; visible, shorten the tab label to keep as many tabs as possible
        ;; in the visible area of the tab bar.
        (if tabbar-auto-scroll-flag
            label
          (tabbar-shorten
           label (max 1 (/ (window-width)
                           (length (tabbar-view
                                    (tabbar-current-tabset)))))))))))
