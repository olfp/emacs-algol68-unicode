(with-eval-after-load 'char-fold
  ;; Funktion, um eine Zeichen-Gruppe zur Emacs Suchtabelle hinzuzufügen
  (defun my-add-char-fold (ascii-char unicode-char)
    (let ((definition (aset char-fold-table ascii-char
                            (cons (char-to-string unicode-char)
                                  (aref char-fold-table ascii-char)))))
      definition))

  ;; Schleife über das Alphabet (a bis z)
  (dotimes (i 26)
    (let ((ascii-lowercase (+ ?a i))
          ;; Mathematisch-fette Kleinbuchstaben beginnen bei U+1D41A (𝐩)
          (math-bold-lowercase (+ #x1D41A i))
          ;; Mathematisch-kursive Kleinbuchstaben beginnen bei U+1D44E (𝑎)
          (math-italic-lowercase (+ #x1D44E i)))
      
      ;; Verknüpfe das normale ASCII-Zeichen mit den Unicode-Varianten
      (my-add-char-fold ascii-lowercase math-bold-lowercase)
      (my-add-char-fold ascii-lowercase math-italic-lowercase))))

;; Aktiviert das Character-Folding standardmäßig für die Suche
(setq search-default-mode 'char-fold-to-regexp)
