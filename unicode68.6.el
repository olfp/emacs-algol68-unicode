;;; unicode68.6.el --- Transparent Isearch for Algol68 Unicode Glyphs -*- lexical-binding: t; -*-

(require 'isearch)

(defun unicode68-math-transform-regexp (string &optional lax)
  "Transformiert einen ASCII-Suchstring in eine Regex für MathBold/MathItalic."
  (let ((regexp ""))
    (cl-loop for char across string
             do (let* ((ch (string char))
                       (code (string-to-char ch)))
                  (cond
                   ;; 1. Keywords / MathBold Kleinbuchstaben (a-z -> 𝐚-𝐳)
                   ((and (>= code ?a) (<= code ?z))
                    (setq regexp (concat regexp (format "[%s%c]" ch (+ #x1D41A (- code ?a))))))
                   ;; 2. Keywords / MathBold Großbuchstaben (A-Z -> 𝐀-𝐙)
                   ((and (>= code ?A) (<= code ?Z))
                    (setq regexp (concat regexp (format "[%s%c]" ch (+ #x1D400 (- code ?A))))))
                   ;; 3. Variablen / MathItalic Kleinbuchstaben (a-z -> 𝑎-𝑧)
                   ;; Ausnahme für 'h' -> Planck-Konstante U+210E
                   ((and (>= code ?a) (<= code ?z))
                    (let ((italic-ch (if (= code ?h) #x210E (+ #x1D44E (- code ?a)))))
                      (setq regexp (concat regexp (format "[%s%c]" ch italic-ch)))))
                   ;; 4. Variablen / MathItalic Großbuchstaben (A-Z -> 𝐴-𝑍)
                   ((and (>= code ?A) (<= code ?Z))
                    (setq regexp (concat regexp (format "[%s%c]" ch (+ #x1D434 (- code ?A))))))
                   ;; Alles andere bleibt im Regex unverändert
                   (t (setq regexp (concat regexp (regexp-quote ch)))))))
    (if lax (concat regexp "\\b") regexp)))

(defun unicode68-isearch-search-fun ()
  "Gibt die angepasste Suchfunktion für den isearch-Mechanismus zurück."
  (lambda (string &optional bound noerror count)
    (let ((isearch-regexp t) ;; Erzwinge Regex-Suche im Hintergrund
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

