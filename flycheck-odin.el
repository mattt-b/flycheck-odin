;;; flycheck-odin.el - Flycheck support for Odin

(require 'flycheck)
;; Flycheck requires seq so this shouldn't be an issue?
;; Older versions may not require this
(require 'seq)


(defun flycheck-odin-check-path ()
  (let ((odin-check-dir (locate-dominating-file default-directory ".odin-check"))
        (check-path buffer-file-name))
    (if (not odin-check-dir)
        ;; No .odin-check file. Run the equivalent of odin check '.'
        (expand-file-name check-path)
      ;; There is a .odin-check file
      ;; Set the check-path to the dir of the .odin-check file
      ;; If there is no 'path' line in .odin-check this is the result that
      ;; will be returned. Otherwise the path param will be parsed and returned
      (setq check-path odin-check-dir)
      (with-temp-buffer
        (insert-file-contents (concat odin-check-dir ".odin-check"))
        (goto-char (point-min))
        (if (re-search-forward "^[[:blank:]]*path[[:blank:]]+[^\n]" (point-max) t)
            ;; Matched a 'path' line
            (progn
              ;; The regex above overmatches by one char in order to not
              ;; match 'path \n'. Move back one char to get actual boundary
              (backward-char)
              (if (or (equal (following-char) ?/)
                      (equal (following-char) ?~)
                      ;; TODO: Windows absolute paths
                      )
                  ;; Absolute path
                  (setq check-path (thing-at-point 'filename 'no-properties))
                ;; Relative path
                (setq check-path (concat odin-check-dir (thing-at-point 'filename 'no-properties)))))
          )
        (expand-file-name check-path)))))

(defun flycheck-odin-filter-regexes (odin-check-dir)
  (let ((regexes '()))
    (with-temp-buffer
      (insert-file-contents (concat odin-check-dir ".odin-check"))
      (goto-char (point-min))
      (while (re-search-forward "^[[:blank:]]*filter[[:blank:]]+[^\n]" (point-max) t)
        ;; The regex above overmatches by one char in order to not
        ;; match 'filter \n'. Move back one char to get actual boundary
        (backward-char)
        (push (buffer-substring-no-properties (point) (line-end-position))
              regexes)))
    regexes))

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
  (let ((odin-check-dir (locate-dominating-file default-directory ".odin-check"))
        (filter-regexes '()))
    (if (not odin-check-dir)
        ;; No .odin-check file, don't filter errors
        errors
      ;; .odin-check file. See if there are filters to apply and apply them to the errors list
      (setq filter-regexes (flycheck-odin-filter-regexes odin-check-dir))
      (if (not filter-regexes)
          ;; There were no regexes in the .odin-check file
          errors
        ;; We have regexes, filter and return the filtered errors
        (seq-filter
         (apply-partially 'flycheck-odin-error-is-not-filtered filter-regexes)
         errors)))))

(flycheck-define-checker odin
  "Flycheck checker using odin check -vet"
  :command ("odin"
            "check"
            (eval (flycheck-odin-check-path))
            "-vet")
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
