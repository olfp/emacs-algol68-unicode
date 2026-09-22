;; -----------------------------------------------------------------------------
;; 4. MAJOR-MODE DEFINITION (EINRÜCKUNG VIA ELECTRIC-INDENT-BACKDOOR FIXIERT)
;; -----------------------------------------------------------------------------

(defvar unicode-algol68-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c b") 'algol68-make-word-unicode-bold)
    (define-key map (kbd "C-c i") 'algol68-make-word-unicode-italic)
    (define-key map (kbd "C-c n") 'algol68-normalize-word)
    (define-key map [backtab] 'algol68-outdent-line)
    map))

(defun algol68-trigger-format-manually ()
  "Hilfsfunktion: Triggert die Wort-Analyse manuell."
  (let ((last-command-event ?\s))
    (algol68-electric-transformer)))

(defun algol68-indent-line-simple ()
  "Strikte, einfache Einrückung: Kopiert auf leeren Zeilen stumpf die Vorzeile.
Rückt erst bei explizitem, wiederholtem TAB-Druck weiter ein."
  (interactive)
  (algol68-trigger-format-manually)
  
  (let* ((current-indent (current-indentation))
         (current-col (current-column))
         (prev-indent
          (save-excursion
            (forward-line -1)
            (while (and (looking-at "^[ \t]*$") (not (bobp)))
              (forward-line -1))
            (current-indentation))))
    (cond
     ;; Fall A: Die aktuelle Zeile ist komplett leer
     ((looking-at "^[ \t]*$")
      (delete-region (line-beginning-position) (line-end-position))
      (if (= current-col prev-indent)
          ;; Wenn wir schon auf Höhe der Vorzeile sind, rücke einen Schritt weiter ein
          (insert-char ?\s (+ current-col tab-width))
        ;; Wenn wir noch nicht auf der Höhe sind, springe zuerst genau dorthin
        (when (> prev-indent 0)
          (insert-char ?\s prev-indent))))
     
     ;; Fall B: Der Cursor steht VOR dem ersten Text einer beschriebenen Zeile
     ((<= current-col current-indent)
      (save-excursion
        (goto-char (line-beginning-position))
        (insert-char ?\s tab-width)))
     
     ;; Fall C: Der Cursor steht mitten im Text -> Normalen Tab-Sprung ausführen
     (t
      (insert-char ?\s tab-width))))
  
  (when (looking-at-p "$")
    (end-of-line)))

(defun algol68-outdent-line ()
  "Verringert die Einrückung der aktuellen Zeile durch physisches Löschen von Spaces."
  (interactive)
  (algol68-trigger-format-manually)
  
  (save-excursion
    (goto-char (line-beginning-position))
    (let ((spaces-to-delete 0))
      (while (and (< spaces-to-delete tab-width)
                  (char-equal (char-after) ?\s))
        (setq spaces-to-delete (1+ spaces-to-delete))
        (forward-char 1))
      (when (> spaces-to-delete 0)
        (delete-region (line-beginning-position) (+ (line-beginning-position) spaces-to-delete)))))
  
  (end-of-line))

(defun algol68-electric-indent-decision (char)
  "Die unfehlbare Hintertür: Entscheidet beim Drücken von Return, ob eingerückt wird.
Wenn die Vorzeile bei Spalte 0 steht, wird jegliche Zwangseinrückung blockiert."
  (if (and (or (char-equal char ?\n) (char-equal char ?\r)) ; Wenn Return gedrückt wurde
           (not (bobp)))
      (let ((prev-indent
             (save-excursion
               (forward-line -1)
               (while (and (looking-at "^[ \t]*$") (not (bobp)))
                 (forward-line -1))
               (current-indentation))))
        (if (= prev-indent 0)
            'no-indent  ;; Zwinge Emacs, in Spalte 0 zu bleiben!
          nil))         ;; Überlasse es ansonsten dem normalen Kopier-Verhalten
    nil))

;; Globale Übersetzung für macOS-Terminals/GUIs, um Shift-Tab zu vereinheitlichen
(define-key local-function-key-map [S-tab] [backtab])
(define-key local-function-key-map [iso-lefttab] [backtab])
(define-key local-function-key-map (kbd "<backtab>") [backtab])

(define-derived-mode unicode-algol68-mode prog-mode "Unicode-Algol68"
  "Major-Modus für ALGOL 68 Code in der originalen Publishing Language mit einfacher Einrückung."
  (variable-pitch-mode 1)
  (face-remap-add-relative 'default :inherit 'fixed-pitch)
  
  ;; --- EINFACHE EINRÜCKUNG & LEERZEICHEN ---
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (setq-local indent-line-function #'algol68-indent-line-simple)
  
  ;; --- DIE UNFEHLBARE HINTERTÜR BEI ELECTRIC-INDENT AKTIVIEREN ---
  (add-hook 'electric-indent-functions #'algol68-electric-indent-decision nil t)
  
  ;; Hooks für die Hintergrundanalyse aktivieren
  (add-hook 'post-self-insert-hook #'algol68-electric-transformer nil t))

(add-to-list 'auto-mode-alist '("\\.u68\\'" . unicode-algol68-mode))

