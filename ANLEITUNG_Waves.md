# Waves anlegen und Share-Bilder erzeugen

Jede Wave steht in einer eigenen Markdown-Datei im Ordner `content/de/homepage/waves/`. Die Website baut daraus die Liste im Abschnitt "Waves" automatisch. Die Seite bleibt ein One-Pager: Jede Wave bekommt nur zusätzlich einen eigenen Anker zum Verlinken.

## 1. Neue Wave anlegen

1. Im Ordner `content/de/homepage/waves/` eine vorhandene Datei kopieren und umbenennen: `JJJJ-MM-TT-name.md`, z. B. `2027-01-15-felicitas.md`.
2. Den Kopf (zwischen den `---`) ausfüllen. Längere Texte (z. B. ein wichtiger Hinweis) kommen darunter in den Text der Datei:

```markdown
---
title: "Freitags-Wave mit Felicitas Franz"   # Überschrift auf der Website
date: 2027-01-15                             # Pflicht
teacher: "Felicitas Franz"                   # für den Untertitel der Share-Bilder
image: "/images/Wave_Felicitas.jpg"          # quadratisches Bild aus static/images/
time: "18:30–20:30"
arrival: "bitte bis 18:15 da sein"           # optional
place: "Probehaus Salzburg"
place_link: "/#locations"                    # optional (Standard: /#locations), z. B. Google-Maps-Link bei Outdoor-Waves
room: "Proberaum 1"                          # optional
price: "15-25 Euro, siehe [Preise](#teilnahme)"   # Markdown erlaubt
facebook: "https://fb.me/e/..."              # optional
info: 'Dies ist eine "extended" Wave (2,5 Stunden).'   # optional, kurzer Hinweis mit (i)-Symbol
# nur für die Share-Bilder (kurz halten):
share_name: "Freitags-Wave"                  # max. ca. 16 Zeichen
share_price: "15–25 € · Drop-in"
share_extra: "Extended Wave · 2,5 Stunden"   # optional, zusätzliche Zeile
# Nicht als eigener Abschnitt der Startseite anzeigen (immer so lassen):
detailed_page_homepage_content: false
---

Optional: Längerer Text, frei formatiert (**fett**, Links, Listen, mehrere Absätze).
Er erscheint unterhalb des Kastens mit Bild in voller Breite.
```

3. Website bauen wie gewohnt: `blogdown::build_site()` (oder `blogdown::serve_site()` zum Anschauen).

**Hinweise**
- Die Zeile `detailed_page_homepage_content: false` muss in jeder Wave-Datei stehen. Ohne sie würde das Theme die Wave als eigenen Abschnitt auf der Startseite zeigen.
- Vergangene Waves verschwinden beim nächsten Build automatisch von der Seite. Die Datei kann liegen bleiben (als Archiv) oder gelöscht werden.
- Die Reihenfolge ergibt sich aus dem Datum.
- Zwei Waves am selben Tag: in einer der Dateien zusätzlich `id: "wave-2027-01-15-abend"` setzen.
- `info` steht in der Textspalte neben dem Bild, automatisch mit (i)-Symbol. Enthält der Text doppelte Anführungszeichen `"`, den ganzen Wert in einfache `'…'` setzen (wie im Beispiel). Markdown (z. B. Links) ist erlaubt.
- Absagen: Datei löschen oder für einen roten Hinweis den Text oben in `content/de/homepage/dates.md` nutzen.

## 2. Direkter Link zu einer Wave

Jede Wave hat einen Anker nach ihrem Datum: **`https://tanzmeditation.at/#wave-2027-01-15`**
Auf der Website steht bei jeder Wave die Zeile "🔗 Link zu dieser Wave". Rechtsklick → "Link kopieren" liefert genau diesen Link.

## 3. Share-Bilder erzeugen

Einmalig: `install.packages(c("yaml", "png"))`. Google Chrome muss installiert sein.

Im RStudio-Projekt:

```r
source("R/make_share_images.R")

make_share_images("2027-01-15")                    # eine Wave
make_share_images(c("2027-01-15", "2027-01-16"))   # zwei Waves auf einem Bild
make_share_images(c("2027-01-15", "2027-01-16"),
                  title = "5Rhythmen tanzen im Jänner",
                  subtitle = "mit Felicitas Franz in Salzburg")  # Titel selbst wählen
```

Ergebnis im Ordner `share_images/` (wird nicht auf die Website hochgeladen und nicht in git gespeichert):
- `…_insta.png`: 1080 × 1350 (Instagram, 4:5)
- `…_fb.png`: 1200 × 630 (Facebook, Querformat)

**Aussehen ändern:** Das Design steht in den HTML-Vorlagen in `R/share_templates/`, nicht im R-Skript:
- `insta_1.html`, `fb_1.html`: eine Wave (großes Bild, Text darunter bzw. daneben)
- `insta_2.html`, `fb_2.html`: zwei Waves mit dunklem Titelbalken
- `style.css`: gemeinsame Schriften und Farben

Die Vorlagen lassen sich direkt im Browser öffnen (dann stehen dort noch die Platzhalter wie `{{date1}}`). Schriftgrößen, Abstände und Reihenfolge lassen sich dort wie auf einer Webseite ändern.

Verfügbare Platzhalter: `{{title}}`, `{{subtitle}}` und pro Wave (1 bzw. 2): `{{name1}}`, `{{date1}}`, `{{time1}}`, `{{place1}}`, `{{price1}}`, `{{extra1}}`, `{{image1}}`.
Sie kommen aus der Wave-Datei: `share_name` (sonst `title`), Datum, `time`, `place`, `share_price` (sonst `price`), `share_extra`, `image`.

Falls Chrome woanders liegt: `Sys.setenv(CHROME_PATH = "/Pfad/zu/Chrome")`.
