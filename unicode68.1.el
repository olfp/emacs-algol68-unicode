;; -----------------------------------------------------------------------------
;; 1. TEXT-TRANSFORMATIONEN (ASCII <-> MATHEMATICAL UNICODE) - UNICODE-H-FIX
;; -----------------------------------------------------------------------------

(require 'ucs-normalize)

(defun x-transform-word-to-lower-unicode (offset-lower)
  "Hilfsfunktion: Wandelt das Wort am Point um und setzt den Cursor sauber DAHINTER.
Berücksichtigt die historische Unicode-Lücke beim kursiven Kleinbuchstaben h."
  (let* ((bounds (bounds-of-thing-at-point 'word)))
    (when bounds
      (let* ((start (car bounds))
             (end (cdr bounds))
             (cursor-offset-from-end (- end (point)))
             (word (downcase (buffer-substring-no-properties start end))))
        (delete-region start end)
        (goto-char start)
        (insert
         (mapconcat
          (lambda (ch)
            (cond
             ;; SONDERFALL KURSIV-H: Wenn wir Kursivschrift anwenden (- #x1D44E ?a)
             ;; und der Buchstabe ein 'h' ist, nutze das Planck-Zeichen (U+210E)
             ((and (= offset-lower (- #x1D44E ?a)) (= ch ?h))
              (char-to-string #x210E))
             
             ;; Normaler Standardfall für alle anderen Buchstaben
             ((and (>= ch ?a) (<= ch ?z)) 
              (char-to-string (+ ch offset-lower)))
             (t (char-to-string ch))))
          word ""))
        (goto-char (- (point) cursor-offset-from-end))))))

(defun algol68-make-word-unicode-bold ()
  "Wandelt das Wort am Point in mathematische Fettschrift (z. B. 𝐩𝐫𝐨𝐜) um."
  (interactive)
  (x-transform-word-to-lower-unicode (- #x1D41A ?a)))

(defun algol68-make-word-unicode-italic ()
  "Wandelt das Wort am Point in mathematische Kursivschrift (z. B. 𝑛𝑒𝑥𝑡) um."
  (interactive)
  (x-transform-word-to-lower-unicode (- #x1D44E ?a)))

(defun algol68-normalize-word ()
  "Wandelt ein Unicode-Wort am Point zurück in normalen ASCII-Text."
  (interactive)
  (let* ((bounds (bounds-of-thing-at-point 'word)))
    (when bounds
      (let* ((start (car bounds))
             (end (cdr bounds))
             (cursor-offset-from-end (- end (point)))
             (word (buffer-substring-no-properties start end)))
        (delete-region start end)
        (goto-char start)
        (insert
         (mapconcat
          (lambda (ch)
            (cond
             ;; SONDERFALL RÜCKTRANSFORMATION FÜR KURSIV-H:
             ;; Erkennt das Planck-Zeichen (U+210E) und wandelt es zurück in ein ASCII 'h'
             ((= ch #x210E) (char-to-string ?h))
             
             ;; Normale Standard-Rücktransformationen
             ((and (>= ch #x1D41A) (<= ch #x1D433)) (char-to-string (+ ?a (- ch #x1D41A))))
             ((and (>= ch #x1D44E) (<= ch #x1D467)) (char-to-string (+ ?a (- ch #x1D44E))))
             ((and (>= ch #x1D400) (<= ch #x1D419)) (char-to-string (+ ?a (- ch #x1D400))))
             ((and (>= ch #x1D434) (<= ch #x1D44D)) (char-to-string (+ ?a (- ch #x1D434))))
             (t (char-to-string ch))))
          word ""))
        (goto-char (- (point) cursor-offset-from-end))))))

