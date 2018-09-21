;;sl mode
(defvar sl-highlights nil "highlight for Soul language")
(setq sl-highlights
      '(
				("\\/\\/.*" . font-lock-comment-face)
				("\\/\\*[^\\*]*\\*\\/" . font-lock-comment-face)
        ("\\\\." . font-lock-constant-face)
        ("\\([A-Za-z0-9_$]+\\) *= *\\&" . (1 font-lock-function-name-face))
        ("\\&(\\([^)]+\\))" . (1 font-lock-variable-name-face))
        ("\\#?\\#[A-Za-z0-9_$]+" . font-lock-variable-name-face)
        ("\\@foreach \\([a-zA-Z0-9_$]+\\)" . (1 font-lock-variable-name-face))
        ("\\@each \\([a-zA-Z0-9_$]+ [a-zA-Z0-9_$]+\\)" . (1 font-lock-variable-\
name-face))
        ("\\@[a-z]+" . font-lock-keyword-face)))
(define-derived-mode sl-mode c-mode "Soul"
  "major mode for editing Soul language code."
  (setq font-lock-defaults '(sl-highlights)))
(add-to-list 'auto-mode-alist '("\\.sl$" . sl-mode))

;;slt mode
(defvar slt-highlights nil "highlight for Soul template language")
(setq slt-highlights
      '(
        ;;        ("~=\\(\\\\.\\|[^\\\\~]\\)+~" . font-lock-function-name-face)
        ("~=[^~]+~" . font-lock-string-face)
        ("~[^~]+~" . font-lock-comment-face)
				("&[0-9A-Za-z_$]+" . font-lock-constant-face)
        ))
(defun test-font-lock-extend-region ()
  "Extend the search region to include an entire block of text."
	;; https://stackoverflow.com/questions/9452615/emacs-is-there-a-clear-example-of-multi-line-font-locking/15239704#15239704
  ;; Avoid compiler warnings about these global variables from font-lock.el.
  ;; See the documentation for variable `font-lock-extend-region-functions'.
  (eval-when-compile (defvar font-lock-beg) (defvar font-lock-end))
  (save-excursion
    (goto-char font-lock-beg)
    (let ((found (or (re-search-backward "\n\n" nil t) (point-min))))
      (goto-char font-lock-end)
      (when (re-search-forward "\n\n" nil t)
        (beginning-of-line)
        (setq font-lock-end (point)))
      (setq font-lock-beg found))))
(define-derived-mode slt-mode fundamental-mode "Soul template"
  "major mode for editing Soul template language code."
  (setq font-lock-defaults '(slt-highlights t))
  (set (make-local-variable 'font-lock-multiline) t)
  (add-hook 'font-lock-extend-region-functions
            'test-font-lock-extend-region)
  )
(add-to-list 'auto-mode-alist '("\\.slt$" . slt-mode))
