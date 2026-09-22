;; =============================================================================
;; MASTER-STEUERUNG FÜR ALGOL 68 (GESPEICHERT IN: ~/.emacs.d/algol68/unicode.el)
;; =============================================================================

(defvar algol68-dir (file-name-directory load-file-name)
  "Das aktuelle Verzeichnis, in dem diese Steuerungsdatei liegt.")

(defun algol68-load-module (module-name)
  "Lädt ein spezifisches ALGOL-68-Modul sicher aus dem aktuellen Verzeichnis."
  (let ((full-path (expand-file-name module-name algol68-dir)))
    (if (file-exists-p full-path)
        (load full-path)
      (message "WARNUNG: Algol68-Modul nicht gefunden: %s" full-path))))

;; Lädt alle fünf Teildateien ohne feste Pfade
(algol68-load-module "unicode68.1.el")
(algol68-load-module "unicode68.2.el")
(algol68-load-module "unicode68.3.el")
(algol68-load-module "unicode68.4.el")
(algol68-load-module "unicode68.5.el")

