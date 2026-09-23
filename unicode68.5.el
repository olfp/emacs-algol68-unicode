;; -----------------------------------------------------------------------------
;; 5. OPTISCHE ANPASSUNG (SCHRIFTEN & FONTSETS)
;; -----------------------------------------------------------------------------

(defun algol68-setup-fonts (&optional frame)
  "Erzwingt die STIX Two Zuweisung für mathematische Zeichen via explizitem Font-Spec."
  (interactive)
  (let ((stix-math-font "STIX Two Math")
        (stix-text-font "STIX Two Text"))
    
    (when (member stix-math-font (font-family-list))

      ;; Variable-Pitch-Profil systemweit auf STIX Two Text einrasten
      (when (member stix-text-font (font-family-list))
        (set-face-attribute 'variable-pitch nil :family stix-text-font :height 135))

      ;; 1. Aktuelle Schriftgröße des Standard-Fonts auslesen (in Points oder Pixeln)
      (let* ((current-frame (or frame (selected-frame)))
             (default-font (face-attribute 'default :font current-frame))
             (base-size (font-get default-font :size))
             ;; 2. Basisgröße mit 1.2 multiplizieren und kaufmännisch runden
             (scaled-size (round (* base-size 1.2)))
             
             ;; 3. Font-Specs mit der errechneten absoluten Zielgröße erzeugen
             (bold-spec   (font-spec :family stix-math-font :weight 'bold :size scaled-size))
             (italic-spec (font-spec :family stix-math-font :slant 'italic :size scaled-size)))

        ;; Mathematische Blöcke im Standard-Fontset überschreiben (t = global)
        ;; Mathematical Bold Block (Schlüsselwörter)
        (set-fontset-font t '(#x1D400 . #x1D433) bold-spec frame)

        ;; Mathematical Italic Block (Identifikatoren/Variablen)
        (set-fontset-font t '(#x1D434 . #x1D467) italic-spec frame)

        ;; Puffer-Aktualisierung erzwingen
        (when (called-interactively-p 'any)
          (message "Algol 68 Schriftset erfolgreich auf %dpt (130%%) skaliert!" scaled-size))))))

;; -----------------------------------------------------------------------------
;; AUTOMATISCHER START
;; -----------------------------------------------------------------------------

(add-hook 'emacs-startup-hook #'algol68-setup-fonts)
(add-hook 'after-make-frame-functions #'algol68-setup-fonts)

