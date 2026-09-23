(require 'char-fold)

;; =========================================================================
;; 1. BUCHSTABEN-FALTUNG (MathBold & MathItalic für die Suche)
;; =========================================================================
(defun my-algol68-setup-char-fold-include ()
  "Trägt die Algol68 MathBold und MathItalic Paare nativ in char-fold-include ein."
  (let ((i 0))
    (while (< i 26)
      (let* ((char-lower (+ ?a i))
             (char-upper (+ ?A i))
             (mb-lower (+ 119808 i))
             (mb-upper (+ 119782 i))
             (mi-lower (if (= i 7) #x210e (+ 119860 i)))
             (mi-upper (+ 119834 i)))

        (let ((existing-lower (assoc char-lower char-fold-include)))
          (if existing-lower
              (let ((current-list (cdr existing-lower)))
                (unless (member (char-to-string mb-lower) current-list)
                  (nconc existing-lower (list (char-to-string mb-lower))))
                (unless (member (char-to-string mi-lower) current-list)
                  (nconc existing-lower (list (char-to-string mi-lower)))))
            (push (list char-lower (char-to-string mb-lower) (char-to-string mi-lower))
                  char-fold-include)))

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

  (setq char-fold-table (char-fold--make-table)))

(my-algol68-setup-char-fold-include)

(setq search-default-mode 'char-fold-to-regexp)
(setq char-fold-symmetric t)


;; =========================================================================
;; 2. GLOBALE LIVE-EINGABE-TRANSFORMATION (NOT, AND, OR)
;; =========================================================================

(defun my-algol68-input-transformer-hook ()
  "Prüft nach jedem Tastendruck global, ob logische Algol68-Muster getippt wurden."
  (when (not buffer-read-only)
    
    ;; A) Wenn eine Tilde ~ getippt wurde -> sofort durch ¬ ersetzen
    (when (or (eq last-command-event ?~) 
              (eq last-command-event 126))
      (delete-char -1)
      (insert "¬"))
    
    ;; B) Wenn ein zweites & getippt wurde (also && dasteht) -> ∧
    (when (and (eq last-command-event ?&)
               (>= (point) 2)
               (eq (char-before (1- (point))) ?&))
      (delete-char -2)
      (insert "∧"))
    
    ;; C) Wenn ein zweites | getippt wurde (also || dasteht) -> ∨
    (when (and (eq last-command-event ?|)
               (>= (point) 2)
               (eq (char-before (1- (point))) ?|))
      (delete-char -2)
      (insert "∨"))))

;; Wir hängen die Funktion GLOBAL an, damit sie in jedem Puffer beim Tippen bereitsteht.
;; Da sie nur auf ~, && und || reagiert, schont das die Performance systemweit komplett.
(add-hook 'post-self-insert-hook #'my-algol68-input-transformer-hook)

(provide 'unicode68.6)
