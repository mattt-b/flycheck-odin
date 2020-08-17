;;; flycheck-odin.el - Flycheck support for Odin

(require 'flycheck)
;; Flycheck requires seq so this shouldn't be an issue?
;; Older versions may not require this
(require 'seq)

(defgroup flycheck-odin nil
  "Flycheck checker for Odin"
  :group 'odin)

(defcustom flycheck-odin-project-path nil
  "Project to run odin check on.
Will usually be a directory, but can be a single file."
  :type 'string
  :group 'flycheck-odin)

(defcustom flycheck-odin-error-filters '()
  "Regexes for flycheck to ignore when reporting errors"
  :type '(repeat string)
  :group 'flycheck-odin)

(defcustom flycheck-odin-command-arguments '("-vet")
  "Arguments passed to the odin compiler to check the code in the project"
  :type '(repeat string)
  :group 'flycheck-odin)

(defun flycheck-odin-check-path ()
  (or flycheck-odin-project-path default-directory))

(defun flycheck-odin-error-to-check-string (err)
  "Takes a flycheck-error struct and turns it back into
the format that odin check spits out"
  (format "%s(%d:%d) %s"
          (flycheck-error-filename err)
          (flycheck-error-line err)
          (flycheck-error-column err)
          (flycheck-error-message err)))

(defun flycheck-odin-error-is-not-filtered (filters error)
  (not (seq-some (lambda (filter)
                   (string-match-p
                    filter
                    (flycheck-odin-error-to-check-string error)))
                 filters)))

(defun flycheck-odin-error-filter (errors)
  (if (not flycheck-odin-error-filters)
      errors
    (seq-filter
     (apply-partially 'flycheck-odin-error-is-not-filtered flycheck-odin-error-filters)
     errors)))

(flycheck-define-checker odin
  "Flycheck checker using odin check -vet"
  :command ("odin"
            "check"
            (eval (flycheck-odin-check-path))
            (eval flycheck-odin-command-arguments))
  :error-patterns
  ((error line-start (file-name) "(" line ":" column ") " (message) line-end))
  :error-filter flycheck-odin-error-filter
  :modes (odin-mode)
  :predicate flycheck-buffer-saved-p)

;;;###autoload
(defun flycheck-odin-setup ()
  (interactive)
  (add-to-list 'flycheck-checkers 'odin))

(provide 'flycheck-odin)

;;; flycheck-odin.el ends here
