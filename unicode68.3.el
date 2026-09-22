;; -----------------------------------------------------------------------------
;; 3. LIVE-KONTEXT-ANALYSE (MIT INTEGRATION KOMMENTAR- SOWIE STRING-SPERRE)
;; -----------------------------------------------------------------------------

(defun algol68-is-variable-declared-p (word)
  "Scannt den Puffer rückwärts, um zu prüfen, ob WORD als Variable deklariert wurde."
  (save-excursion
    (let ((found nil)
          (italic-word (with-temp-buffer
                         (insert word)
                         (goto-char (point-min))
                         (algol68-make-word-unicode-italic)
                         (buffer-string))))
      (save-excursion
        (when (search-backward italic-word nil t)
          (setq found t)))
      found)))

(defun algol68-in-comment-or-string-p ()
  "Hilfsfunktion: Prüft via Emacs-Syntax-Parser, ob der Cursor in einem
Kommentar oder innerhalb von Anführungszeichen (String) steht."
  (let ((state (syntax-ppss)))
    (or (nth 3 state)  ; Wahr, wenn innerhalb eines Strings
        (nth 4 state)  ; Wahr, wenn innerhalb eines Kommentars
        ;; Präzise Absicherung für Algol-Sonderzeichen auf Zeilenebene:
        (save-excursion
          (let ((in-co nil)
                (pos (point)))
            (beginning-of-line)
            ;; Wir holen NUR den Text der aktuellen Zeile bis zum Cursor
            (let ((line-str (buffer-substring-no-properties (point) pos)))
              ;; Wir prüfen im Mini-Buffer, ob die Anzahl der Zeichen ungerade ist
              (with-temp-buffer
                (insert line-str)
                (goto-char (point-min))
                (let ((count-cent (count-matches "¢" (point-min) (point-max)))
                      (count-hash (count-matches "#" (point-min) (point-max))))
                  (when (or (not (zerop (% count-cent 2)))
                            (not (zerop (% count-hash 2))))
                    (setq in-co t)))))
            in-co)))))

(defun algol68-electric-transformer ()
  "Ersetzt Operatoren-Ligaturen direkt beim Tippen und formatiert Wörter.
Ignoriert die Formatierung komplett, wenn sich der Cursor in Kommentaren oder Strings befindet."
  
  ;; --- DIE GLOBALE FORMATIERUNGS-SPERRE ---
  ;; Wenn wir uns in einem Kommentar oder String befinden, brechen wir sofort ab!
  (unless (algol68-in-comment-or-string-p)

    ;; --- AUTOMATISCHE OPERATOREN-ERSETZUNG ---
    (cond
     ;; Ungleich: /= zu ≠
     ((and (char-equal last-command-event ?=)
           (not (bobp))
           (char-equal (char-before (1- (point))) ?/))
      (delete-char -2) (insert "≠"))
     
     ;; Zuweisung: := zu ≔
     ((and (char-equal last-command-event ?=)
           (not (bobp))
           (char-equal (char-before (1- (point))) ?:))
      (delete-char -2) (insert "≔"))
     
     ;; Kleiner gleich: <= zu ≤
     ((and (char-equal last-command-event ?=)
           (not (bobp))
           (char-equal (char-before (1- (point))) ?<))
      (delete-char -2) (insert "≤"))
     
     ;; Größer gleich: >= zu ≥
     ((and (char-equal last-command-event ?=)
           (not (bobp))
           (char-equal (char-before (1- (point))) ?>))
      (delete-char -2) (insert "≥"))
     
     ;; Pfeil: -> zu →
     ((and (char-equal last-command-event ?>)
           (not (bobp))
           (char-equal (char-before (1- (point))) ?-))
      (delete-char -2) (insert "→")))

    ;; --- WORT-FORMATIERUNG ---
    (when (not (char-equal (char-syntax last-command-event) ?w))
      (save-excursion
        (backward-char 1)
        (let ((bounds (bounds-of-thing-at-point 'word)))
          (when bounds
            (let* ((current-word (downcase (buffer-substring-no-properties (car bounds) (cdr bounds))))
                   (clean-word (save-excursion
                                 (goto-char (car bounds))
                                 (let ((w (buffer-substring-no-properties (car bounds) (cdr bounds))))
                                   (with-temp-buffer
                                     (insert w)
                                     (algol68-normalize-word)
                                     (buffer-string))))))
              
              (cond
               ((member current-word algol68-keywords)
                (algol68-make-word-unicode-bold))
               
               ((member clean-word algol68-standard-identifiers)
                (algol68-make-word-unicode-italic))
               
               ((algol68-is-variable-declared-p clean-word)
                (algol68-make-word-unicode-italic))
               
               (t
                (save-excursion
                  (goto-char (car bounds))
                  (backward-word 1)
                  (let ((prev-bounds (bounds-of-thing-at-point 'word)))
                    (when prev-bounds
                      (let ((prev-word (buffer-substring-no-properties (car prev-bounds) (cdr prev-bounds))))
                        (with-temp-buffer
                          (insert prev-word)
                          (algol68-normalize-word)
                          (setq prev-word (buffer-string)))
                        
                        (cond
                         ((member prev-word algol68-type-declarators)
                          (goto-char (cdr bounds))
                          (algol68-make-word-unicode-italic))
                         
                         ((string-equal prev-word "int")
                          (backward-word 1)
                          (let ((pre-prev-bounds (bounds-of-thing-at-point 'word)))
                            (when pre-prev-bounds
                              (let ((pre-prev-word (buffer-substring-no-properties (car pre-prev-bounds) (cdr pre-prev-bounds))))
                                (with-temp-buffer
                                  (insert pre-prev-word)
                                  (algol68-normalize-word)
                                  (setq pre-prev-word (buffer-string)))
                                (when (string-equal pre-prev-word "for")
                                  (goto-char (cdr bounds))
                                  (algol68-make-word-unicode-italic))))))))))))))))))))

