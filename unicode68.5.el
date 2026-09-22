;; -----------------------------------------------------------------------------
;; 5. OPTISCHE ANPASSUNG (SCHRIFTEN & FONTSETS)
;; -----------------------------------------------------------------------------

(defun algol68-setup-fonts (&optional frame)
  "Erzwingt die STIX Two Zuweisung für mathematische Zeichen via explizitem Font-Spec."
  (interactive)
  (let ((stix-font "STIX Two Text"))
    (when (member stix-font (font-family-list))
      
      ;; Variable-Pitch-Profil systemweit auf STIX Two Text einrasten
      (set-face-attribute 'variable-pitch nil :family stix-font :height 135)
      
      ;; Explizite Font-Spezifikationen für das macOS-Rendering-System erzeugen
      (let ((bold-spec   (font-spec :family stix-font :weight 'bold))
            (italic-spec (font-spec :family stix-font :slant 'italic)))
        
        ;; Mathematische Blöcke im Standard-Fontset überschreiben (t = global)
        ;; Mathematical Bold Block (Schlüsselwörter)
        (set-fontset-font t '(#x1D400 . #x1D433) bold-spec frame)
        
        ;; Mathematical Italic Block (Identifikatoren/Variablen)
        (set-fontset-font t '(#x1D434 . #x1D467) italic-spec frame)
        
        ;; Puffer-Aktualisierung erzwingen
        (when (called-interactively-p 'any)
          (message "Algol 68 Schriftset erfolgreich für den Mac neu geladen!"))))))

;; HINWEIS: Kein automatischer Aufruf mehr am Ende, um Systemabstrüche zu verhindern.
;; Falls Sie die STIX-Schrift explizit erzwingen wollen, führen Sie M-x algol68-setup-fonts aus.

