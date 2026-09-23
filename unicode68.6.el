;;; unicode68.6.el --- Transparent Isearch for Algol68 Unicode Glyphs -*- lexical-binding: t; -*-

(require 'isearch)
(require 'cl-lib)

(defun unicode68-math-transform-regexp (string &optional _lax)
  "Transformiert einen ASCII-Suchstring in eine Regex, die ASCII ODER MathBold ODER MathItalic findet."
  (let ((regexp ""))
    (cl-loop for char across string
             do (let* ((ch (string char))
                       (code (string-to-char ch)))
                  (cond
                   ;; Buchstaben (a-z, A-Z) -> Findet ASCII ODER MathBold ODER MathItalic
                   ((or (and (>= code ?a) (<= code ?z))
                        (and (>= code ?A) (<= code ?Z)))
                    (let* ((is-lower (and (>= code ?a) (<= code ?z)))
                           ;; Fetter Unicode-Codepoint (𝐚)
                           (bold-code (if is-lower (+ #x1D41A (- code ?a)) (+ #x1D400 (- code ?A))))
                           ;; Kursiver Unicode-Codepoint (𝑎), Ausnahme 'h' -> #x210E
                           (italic-code (if (and is-lower (= code ?h))
                                           #x210E
                                         (if is-lower (+ #x1D44E (- code ?a)) (+ #x1D434 (- code ?A))))))
                      ;; CRUCIAL FIX: Erst in Strings wandeln, dann via %s einsetzen! Prevents encoding corruption.
                      (setq regexp (concat regexp (format "\\(%s\\|%s\\|%s\\)" 
                                                          (regexp-quote ch) 
                                                          (string bold-code) 
                                                          (string italic-code))))))
                   ;; Ziffern (0-9) -> Findet ASCII ODER fett
                   ((and (>= code ?0) (<= code ?9))
                    (let ((bold-digit (+ #x1D7CE (- code ?0))))
                      (setq regexp (concat regexp (format "\\(%s\\|%s\\)" 
                                                          (regexp-quote ch) 
                                                          (string bold-digit))))))
                   ;; Alles andere bleibt geschützt
                   (t (setq regexp (concat regexp (regexp-quote ch)))))))
    regexp))

(defun unicode68-isearch-search-fun ()
  "Gibt die mathematisch transformierte Suchfunktion an das Isearch-System zurück."
  (lambda (string &optional bound noerror count)
    (let ((transformed (unicode68-math-transform-regexp string)))
      (if isearch-forward
          (re-search-forward transformed bound noerror count)
        (re-search-backward transformed bound noerror count)))))

(defun unicode68-isearch-setup-hook ()
  "Aktiviert die mathematische Suche nativ und zwingt Isearch in den Regex-Modus."
  ;; Greift, wenn wir uns im Algol68-Unicode-Modus befinden
  (when (eq major-mode 'unicode68-mode)
    (setq isearch-regexp t)
    (setq isearch-regexp-function nil)
    (setq-local isearch-search-fun-function #'unicode68-isearch-search-fun)))

;; Aktiviert die transparente Suche nativ im globalen Isearch-System von Emacs
(add-hook 'isearch-mode-hook #'unicode68-isearch-setup-hook)

(provide 'unicode68.6)
;;; unicode68.6.el ends here
