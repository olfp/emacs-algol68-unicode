(with-eval-after-load 'char-fold
  ;; Hilfsfunktion, um ein Zeichen zur Faltungstabelle hinzuzufügen
  (defun my-add-char-fold (ascii-char unicode-char)
    (aset char-fold-table ascii-char
          (cons (char-to-string unicode-char)
                (aref char-fold-table ascii-char))))

  ;; Schleife über das gesamte Alphabet (a bis z)
  (dotimes (i 26)
    (let ((ascii-lowercase (+ ?a i))
          ;; MathBold-Kleinbuchstaben sind sequentiell ab U+1D41A
          (math-bold-lowercase (+ #x1D41A i)))
      
      ;; 1. MathBold (fett) für alle Buchstaben hinzufügen
      (my-add-char-fold ascii-lowercase math-bold-lowercase)
      
      ;; 2. MathItalic (kursiv) mit Sonderbehandlung für das kleine 'h'
      (if (= ascii-lowercase ?h)
          ;; Wenn es das 'h' ist, nutze die Planck-Konstante (U+210E)
          (my-add-char-fold ?h #x210E)
        ;; Für alle anderen Buchstaben: Sequentiell ab U+1D44E rechnen
        ;; Da 'h' der 8. Buchstabe ist (Index 7), müssen wir ab 'i' um 1 versetzen,
        ;; weil U+1D455 im Unicode-Block komplett übersprungen wird!
        (let ((math-italic-lowercase (if (> i 7)
                                         (+ #x1D44E i -1)
                                       (+ #x1D44E i))))
          (my-add-char-fold ascii-lowercase math-italic-lowercase))))))

;; Aktiviert das Character-Folding standardmäßig für die Suche
(setq search-default-mode 'char-fold-to-regexp)
