;;; unicode68.6.el --- Transparent Isearch for Algol68 Unicode Glyphs -*- lexical-binding: t; -*-

(require 'isearch)
(require 'cl-lib)

(defun unicode68-math-transform-regexp (string &optional lax)
  "Transformiert einen ASCII-Suchstring in eine Regex, die MathBold ODER MathItalic findet."
  (let ((regexp ""))
    (cl-loop for char across string
             do (let* ((ch (string char))
                       (code (string-to-char ch)))
                  (cond
                   ;; Buchstaben (a-z, A-Z) können fett (Keyword) ODER kursiv (Variable) sein!
                   ((or (and (>= code ?a) (<= code ?z))
                        (and (>= code ?A) (<= code ?Z)))
                    (let* ((is-lower (and (>= code ?a) (<= code ?z)))
                           ;; Berechne fetten Codepoint
                           (bold-ch (if is-lower (+ #x1D41A (- code ?a)) (+ #x1D400 (- code ?A))))
                           ;; Berechne kursiven Codepoint (Ausnahme für kleines 'h' -> Planck-Konstante U+210E)
                           (italic-ch (if (and is-lower (= code ?h))
                                          #x210E
                                        (if is-lower (+ #x1D44E (- code ?a)) (+ #x1D434 (- code ?A))))))
                      ;; Generiert eine Regex-Gruppe, z.B. [b\|𝐛\|𝑏] für den Buchstaben b
                      (setq regexp (concat regexp (format "\\(%s\\|%c\\|%c\\)" ch bold-ch italic-ch)))))
                   ;; Ziffern (0-9) können fett sein
                   ((and (>= code ?0) (<= code ?9))
                    (setq regexp (concat regexp (format "\\(%s\\|%c\\)" ch (+ #x1D7CE (- code ?0))))))
                   ;; Alles andere (Satzzeichen, Operatoren) bleibt im Regex normal geschützt
                   (t (setq regexp (concat regexp (regexp-quote ch)))))))
    (if lax (concat regexp "\\b") regexp)))

(defun unicode68-isearch-search-fun ()
  "Gibt die angepasste Suchfunktion für den isearch-Mechanismus zurück."
  (lambda (string &optional bound noerror count)
    (let ((isearch-regexp t)
          (isearch-regexp-function nil)
          (transformed (unicode68-math-transform-regexp string)))
      (isearch-search-string transformed bound noerror count))))

;;;###autoload
(define-minor-mode unicode68-search-mode
  "Minor Mode für die transparente Suche von MathBold/MathItalic Glyphen über C-s."
  :init-value nil
  :lighter " U68-Search"
  (if unicode68-search-mode
      (setq-local isearch-search-fun-function #'unicode68-isearch-search-fun)
    (kill-local-variable 'isearch-search-fun-function)))

(provide 'unicode68.6)
;;; unicode68.6.el ends here

