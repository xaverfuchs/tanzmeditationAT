# Share-Bilder für Instagram und Facebook aus den Wave-Dateien erzeugen
#
# Das Aussehen steht NICHT hier, sondern in den HTML-Vorlagen in R/share_templates/:
#   insta_1.html / fb_1.html  = eine Wave,   insta_2.html / fb_2.html = zwei Waves,
#   style.css                 = gemeinsame Farben und Schriften.
# Die Vorlagen lassen sich im Browser öffnen und wie eine Webseite anpassen.
# Dieses Skript setzt nur die Daten in die Platzhalter {{...}} ein und macht mit
# Google Chrome einen Screenshot.
#
# Einmalig: install.packages(c("yaml", "png"))
#
# Beispiele:
#   source("R/make_share_images.R")
#   make_share_images("2026-11-28")                  # eine Wave
#   make_share_images(c("2026-10-30", "2026-10-31")) # zwei Waves auf einem Bild
#   make_share_images(c("2026-10-30", "2026-10-31"), title = "Halloween-Wochenende")

make_share_images <- function(dates, title = NULL, subtitle = NULL,
                              chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome") {
  if (Sys.getenv("CHROME_PATH") != "") chrome <- Sys.getenv("CHROME_PATH")
  tpl_dir <- "R/share_templates"
  dir.create("share_images", showWarnings = FALSE)

  # 1. Wave-Dateien lesen (nur den Kopf zwischen den ersten beiden "---")
  waves <- lapply(dates, function(d) {
    f <- Sys.glob(sprintf("content/de/homepage/waves/%s*.md", d))[1]
    if (is.na(f)) stop("Keine Wave-Datei für ", d)
    lines <- readLines(f, encoding = "UTF-8")
    yaml::yaml.load(paste(lines[2:(which(lines == "---")[2] - 1)], collapse = "\n"))
  })

  # 2. Werte für die Platzhalter zusammenstellen
  tage   <- c("Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag")
  monate <- c("Jänner", "Februar", "März", "April", "Mai", "Juni", "Juli",
              "August", "September", "Oktober", "November", "Dezember")
  d1 <- as.POSIXlt(as.Date(waves[[1]]$date))
  teachers <- unique(sapply(waves, `[[`, "teacher"))
  values <- list(
    title    = title    %||% paste("5Rhythmen tanzen im", monate[d1$mon + 1]),
    subtitle = subtitle %||% if (length(teachers) == 1) paste("mit", teachers, "in Salzburg") else "in Salzburg"
  )
  for (i in seq_along(waves)) {
    w <- waves[[i]]
    d <- as.POSIXlt(as.Date(w$date))
    values[[paste0("name",  i)]] <- w$share_name %||% w$title
    values[[paste0("date",  i)]] <- sprintf("%s, %d. %s", tage[d$wday + 1], d$mday, monate[d$mon + 1])
    values[[paste0("time",  i)]] <- w$time
    values[[paste0("place", i)]] <- w$place
    values[[paste0("price", i)]] <- w$share_price %||% w$price
    values[[paste0("extra", i)]] <- w$share_extra %||% ""
    values[[paste0("image", i)]] <- w$image
  }

  # 3. Für jedes Format: Vorlage füllen, Screenshot machen
  sizes <- list(insta = c(1080, 1350), fb = c(1200, 630))
  for (format in names(sizes)) {
    html <- readLines(file.path(tpl_dir, sprintf("%s_%d.html", format, length(waves))), encoding = "UTF-8")
    for (key in names(values)) html <- gsub(sprintf("{{%s}}", key), values[[key]], html, fixed = TRUE)
    tmp <- file.path(tpl_dir, "_tmp.html")   # im Vorlagen-Ordner, damit die Bildpfade stimmen
    writeLines(enc2utf8(html), tmp, useBytes = TRUE)

    # Chrome rendert ein etwas höheres Fenster; danach wird exakt zugeschnitten
    size <- sizes[[format]]
    raw <- tempfile(fileext = ".png")
    system2(chrome, shQuote(c(
      "--headless=new", "--hide-scrollbars", "--force-device-scale-factor=1",
      "--allow-file-access-from-files", "--virtual-time-budget=3000",
      if (Sys.info()[["sysname"]] == "Linux") "--no-sandbox",
      sprintf("--window-size=%d,%d", size[1], size[2] + 400),
      paste0("--screenshot=", raw), paste0("file://", normalizePath(tmp)))),
      stdout = FALSE, stderr = FALSE)
    img <- png::readPNG(raw)
    out <- sprintf("share_images/%s_%s.png", paste(dates, collapse = "_"), format)
    png::writePNG(img[1:size[2], 1:size[1], ], out)
    unlink(c(raw, tmp))
    message("Erstellt: ", out)
  }
}

`%||%` <- function(a, b) if (is.null(a)) b else a
