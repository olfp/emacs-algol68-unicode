(require 'char-fold)

(defun my-algol68-setup-char-fold-include ()
  "Trägt die Algol68 MathBold und MathItalic Paare nativ in char-fold-include ein."
  (let ((i 0))
    (while (< i 26)
      (let* ((char-lower (+ ?a i))
             (char-upper (+ ?A i))
             ;; Mathematische Unicode-Codepoints berechnen
             (mb-lower (+ 119808 i))
             (mb-upper (+ 119782 i))
             (mi-lower (if (= i 7) #x210e (+ 119860 i)))
             (mi-upper (+ 119834 i)))

        ;; 1. Kleinbuchstaben zu char-fold-include hinzufügen
        (let ((existing-lower (assoc char-lower char-fold-include)))
          (if existing-lower
              ;; Falls ein Eintrag existiert, hängen wir unsere Zeichen als Strings an
              (let ((current-list (cdr existing-lower)))
                (unless (member (char-to-string mb-lower) current-list)
                  (nconc existing-lower (list (char-to-string mb-lower))))
                (unless (member (char-to-string mi-lower) current-list)
                  (nconc existing-lower (list (char-to-string mi-lower)))))
            ;; Falls kein Eintrag existiert, legen wir ihn neu an
            (push (list char-lower (char-to-string mb-lower) (char-to-string mi-lower))
                  char-fold-include)))

        ;; 2. Großbuchstaben zu char-fold-include hinzufügen
        (let ((existing-upper (assoc char-upper char-fold-include)))
          (if existing-upper
              (let ((current-list (cdr existing-upper)))
                (unless (member (char-to-string mb-upper) current-list)
                  (nconc existing-upper (list (char-to-string mb-upper))))
                (unless (member (char-to-string mi-upper) current-list)
                  (nconc existing-upper (list (char-to-string mi-upper)))))
            (push (list char-upper (char-to-string mb-upper) (char-to-string mi-upper))
                  char-fold-include))))
      (setq i (1+ i))))

  ;; Zwinge Emacs, die Tabelle basierend auf char-fold-include komplett neu zu backen
  (setq char-fold-table (char-fold--make-table)))

;; Starte die Konfiguration
(my-algol68-setup-char-fold-include)

;; Wichtige Komfort-Einstellungen für die Suche:
;; Aktiviert die Faltung standardmäßig für die inkrementelle Suche (C-s)
(setq search-default-mode 'char-fold-to-regexp)

;; Erlaubt es, dass die Suche in BEIDE Richtungen funktioniert 
;; (Sucht man nach einem fetten '𝐩', findet Emacs auch das normale 'p')
(setq char-fold-symmetric t)

(provide 'unicode68.6)
