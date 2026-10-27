# Multi-Factor Market Score v2.0 [DE]

- url: https://www.tradingview.com/script/rdaBoCOQ-Multi-Factor-Market-Score-v2-0-DE/
- type: indicator
- pine_id: PUB;c48d7c6467eb4c2da5082aa5f47b0e2a
- version: 5.0

## Description

Multi-Factor Market Score v2.0 is a multi-factor ranking and analysis tool for stocks, ETFs/indices, and other liquid markets based on daily data.

It combines relative strength, trend quality, and—when stock fundamentals are available—earnings quality into a unified score from 0.00 to 1.00.

The script includes automatic instrument classification, benchmark logic, history checks, data coverage/model confidence, safety filters, and clear zones for watchlist, buy, and strong buy conditions.

Its panel shows the main score drivers, including relative strength, trend quality, distance from the 52-week high, benchmark context, fundamental metrics, and the current model assessment.

Important: the current public version of the script is available in German only.

All labels, tooltips, table entries, and alert texts inside the script are currently written in German, even though this publication description is in English.

This script is a structured analysis tool, not an autonomous trading system.

Depending on the TradingView data feed, small caps, or special cases, some fundamental inputs may be incomplete, delayed, or unusual despite mathematically correct processing, so score, coverage, and individual data points should always be interpreted together.

## Source Code

````pine
//@version=6
var string APP_TITLE      = "Multi-Factor Market Score v2.0"
var string APP_SHORTTITLE = "MFMS"

indicator(APP_TITLE, shorttitle=APP_SHORTTITLE, overlay=false, precision=2)

// === TEXTKONSTANTEN =========================================================
var string DEFAULT_BENCHMARK    = "SPY"

var string S_EMPTY              = ""
var string S_AUTO                  = "Auto"
var string S_MANUELL               = "Manuell"

var string S_AKTIE_IN              = "Aktie"
var string S_ETF_INDEX_IN          = "ETF/Index"
var string S_ANLEIHE_IN            = "Anleihe"
var string S_OTHER_IN              = "Forex/Krypto/Rohstoff"

var string S_MODE_AKTIE            = "AKTIE"
var string S_MODE_ETF              = "ETF"
var string S_MODE_INDEX            = "INDEX"
var string S_MODE_BOND             = "BOND"
var string S_MODE_KRYPTO           = "KRYPTO"
var string S_MODE_FOREX            = "FOREX"
var string S_MODE_ROHSTOFF         = "ROHSTOFF"

var string S_TOPRIGHT              = "topright"
var string S_MIDDLERIGHT           = "middleright"
var string S_BOTTOMRIGHT           = "bottomright"
var string S_TOPLEFT               = "topleft"
var string S_MIDDLELEFT            = "middleleft"
var string S_BOTTOMLEFT            = "bottomleft"

var string S_TINY                  = "tiny"
var string S_SMALL                 = "small"
var string S_NORMAL                = "normal"
var string S_LARGE                 = "large"

var string S_DASH                  = "-"
var string S_NA                    = "–"
var string S_PLUS                  = "+"
var string S_PERCENT               = " %"
var string S_MULT                  = "x"

var string S_HIST_FULL             = "Vollstaendig"
var string S_HIST_LIMITED          = "Eingeschraenkt"
var string S_HIST_SHORT            = "Zu kurz"

var string S_MARKET_POSITIVE       = "Positiv"
var string S_MARKET_WEAK           = "Schwach"

var string S_FILTER_PASS           = "✓ BESTANDEN"
var string S_FILTER_FAIL           = "✗ NICHT BESTANDEN"
var string S_FILTER_TREND_OK       = "✓ TREND OK"
var string S_FILTER_TREND_WEAK     = "✗ TREND SCHWACH"
var string S_FILTER_BENCH_MISSING  = "⚠ BENCHMARK FEHLT"

var string S_REC_AVOID             = "VERKAUFEN / MEIDEN"
var string S_REC_BUY_STRONG        = "KAUFEN - Starkes Signal"
var string S_REC_BUY_GOOD          = "KAUFEN - Gutes Signal"
var string S_REC_WATCH             = "BEOBACHTEN"
var string S_REC_WEAK_DATA         = "DATENLAGE SCHWACH"
var string S_REC_NEUTRAL           = "NEUTRAL - Abwarten"

var string S_ACT_AVOID             = "Meiden – Score zu schwach fuer Einstieg"
var string S_ACT_BUY_STRONG        = "Position aufbauen (6-8 % Depot)"
var string S_ACT_BUY_GOOD          = "Position aufbauen (3-5 % Depot)"
var string S_ACT_WATCH             = "Auf Watchlist setzen, nicht kaufen"
var string S_ACT_WEAK_DATA         = "Nicht handeln – Daten/Historie unzureichend"
var string S_ACT_NEUTRAL           = "Abwarten – keine neue Position eingehen"

var string S_EARN_RECENT           = "Kuerzlich gemeldet"
var string S_EARN_TODAY            = "⚠ HEUTE"
var string S_IN_PREFIX             = "In "
var string S_IN_SUFFIX             = " Tagen"

var string S_VOL_BIO               = "Bio"
var string S_VOL_MRD               = "Mrd"
var string S_VOL_MIO               = "Mio"
var string S_CHECK                 = "✓"
var string S_CROSS                 = "✗"
var string S_TREND_SMA200          = " SMA200  "
var string S_TREND_GC              = " GC  "
var string S_TREND_DD              = " DD"

var string G_HELP                     = "📖 Hilfe & Erklaerungen"
var string G_MARKET                   = "🌍 Marktlogik"
var string G_SETTINGS                 = "⚙️ Grundeinstellungen"
var string G_THRESHOLDS               = "📊 Schwellen"
var string G_FILTER                   = "🛡️ Sicherheitsfilter"
var string G_DISPLAY                  = "🖥️ Darstellung"

var string I_HELP_CHART               = "ℹ️ Erklaerung: Kurven im Chart"
var string I_HELP_SIGNALE             = "ℹ️ Erklaerung: Signale im Chart"
var string I_HELP_EMPFEHLUNG          = "ℹ️ Erklaerung: Empfehlung"
var string I_HELP_ACTION              = "ℹ️ Erklaerung: Handlungsvorschlag"

var string I_BENCH_MODE               = "Benchmark-Modus"
var string I_BENCH_MANUAL             = "Benchmark manuell"
var string I_W_RS                     = "Gewicht Relative Staerke"
var string I_W_EARN                   = "Gewicht Gewinn-Qualitaet"
var string I_W_TREND                  = "Gewicht Trend-Qualitaet"
var string I_THR_STRONG               = "Schwelle Starkes Kaufsignal"
var string I_THR_GOOD                 = "Schwelle Gutes Kaufsignal"
var string I_THR_WATCH                = "Schwelle Beobachten"
var string I_THR_FAIL                 = "Schwelle Verkaufen/Meiden"
var string I_USE_FILTER               = "Sicherheits-Filter aktiv"
var string I_MAX_DD                   = "Max. 60-Tage-Drawdown (%)"
var string I_MIN_VOL                  = "Min. Tagesumsatz (USD)"
var string I_ASSET_MODE               = "Instrument-Modus"
var string I_MIN_COV_BUY              = "Min. Coverage fuer Kauf"
var string I_MIN_COV_WATCH            = "Min. Coverage fuer Beobachten"
var string I_MIN_HIST                 = "Min. Historie fuer Vollmodus"
var string I_STRICT_BENCH             = "Benchmark fuer Kauf zwingend gueltig"
var string I_TABLE_POS                = "Tabellen-Position"
var string I_TABLE_SIZE               = "Tabellen-Schriftgroesse"
var string I_SHOW_BG                  = "Hintergrund-Farbe anzeigen"
var string I_SHOW_LEGEND              = "Chart-Legende einblenden"

var string PLOT_EARN_SOON             = "Earnings < 5 Tage"
var string PLOT_EARN_WINDOW           = "Earnings < 14 Tage"
var string PLOT_BG_MARKET             = "Markt-Hintergrund"

var string SIG_BUY                    = "✓ KAUFSIGNAL"
var string SIG_EXIT                   = "⚠ AUSSTIEG"
var string SIG_BUY_STRONG             = "★ STARKES KAUFSIGNAL"
var string SIG_DIVERGENZ              = "⚠ DIVERGENZ"

var string ROW_SEKTOR                 = "  Sektor"
var string ROW_INDUSTRIE              = "  Industrie"
var string ROW_MODUS                  = "  Modus"
var string ROW_HISTORIE               = "  Historie"
var string ROW_COVERAGE               = "  Datenbasis / Modellvertrauen"
var string ROW_GESAMT                 = "  Gesamt-Score"
var string ROW_RS                     = "  Relative Staerke"
var string ROW_TREND                  = "  Trendqualitaet"
var string ROW_DIST_ATH               = "  Abstand Jahreshoch"
var string ROW_BENCHMARK              = "  Benchmark"
var string ROW_FILTER                 = "  Sicherheitsfilter"
var string ROW_MARKTREGIME            = "  Marktregime"
var string ROW_EMPFEHLUNG             = "  Empfehlung"
var string ROW_ACTION                 = "  Was tun?"
var string ROW_KURVEN                 = "  Kurven"
var string ROW_KURVEN_VALUES          = "① Score  ② RS  ③ Gewinn  ④ Schwung"
var string ROW_SIGNALE                = "  Signale"
var string ROW_SIGNALE_VALUES         = "↑ Kauf   ↓ Ausstieg   ★ Stark   ▽ Divergenz"

var string ROW_EARNINGS_EQUITY        = "  Naechste Quartalszahlen"
var string ROW_EARNINGS_GENERIC       = "  Naechster Unternehmens-Termin"
var string ROW_EARN_EQUITY            = "  Gewinn-Qualitaet"
var string ROW_EARN_GENERIC           = "  Fundamentaldaten"
var string ROW_EPS_EQUITY             = "  Gewinnwachstum (1J)"
var string ROW_EPS_GENERIC            = "  Gewinnwachstum"
var string ROW_REV_EQUITY             = "  Umsatzwachstum (1J)"
var string ROW_REV_GENERIC            = "  Umsatzwachstum"
var string ROW_ROE_EQUITY             = "  Eigenkapitalrendite"
var string ROW_ROE_GENERIC            = "  Kapitalrendite"
var string ROW_DE_EQUITY              = "  Verschuldung (D/E)"
var string ROW_DE_GENERIC             = "  Verschuldung"
var string ROW_FCF                    = "  Cashflow-Rendite"
var string ROW_PEG                    = "  Bewertung vs. Wachstum"

var string ROW_VOL_EQUITY             = "  Handelsvolumen (20T-Ø)"
var string ROW_VOL_ETF                = "  Handelsvolumen (20T-Ø)"
var string ROW_VOL_BOND               = "  Handelbarkeit / Volumen"
var string ROW_VOL_INDEX              = "  Volumen / Handelbarkeit"
var string ROW_VOL_OTHER              = "  Volumen / Handelbarkeit"

var string MODE_SECTOR_BOND           = "ANLEIHE / RENTENMARKT"
var string MODE_SECTOR_ETF            = "ETF / INDEX"
var string MODE_SECTOR_FOREX          = "DEVISENMARKT"
var string MODE_SECTOR_KRYPTO         = "KRYPTO-MARKT"
var string MODE_SECTOR_ROHSTOFF       = "ROHSTOFFMARKT"
var string MODE_SECTOR_OTHER          = "SONSTIGER MARKT"

var string MODE_INDUSTRY_BOND         = "ZINSSENSITIVES FESTVERZINSLICHES INSTRUMENT"
var string MODE_INDUSTRY_ETF          = "PASSIVES / MARKTBASIERTES INSTRUMENT"
var string MODE_INDUSTRY_FOREX        = "WAEHRUNGSPAAR / FX-INSTRUMENT"
var string MODE_INDUSTRY_KRYPTO       = "DIGITALES ASSET"
var string MODE_INDUSTRY_ROHSTOFF     = "PHYSISCHER ODER TERMINBASIERTER ROHSTOFF"
var string MODE_INDUSTRY_OTHER        = "NICHT-UNTERNEHMENSINSTRUMENT"

var string LEGEND_TITLE               = "── MFMS – LEGENDE ──"
var string LEGEND_1                   = "① Gelb = Gesamt-Note (0.00–1.00)"
var string LEGEND_2                   = "② Blau = Kurs-Staerke"
var string LEGEND_3                   = "③ Orange = Unternehmensqualitaet"
var string LEGEND_4                   = "④ Weiss = Bewertungs-Schwung"
var string LEGEND_5                   = "↑gruen Kauf · ↓rot Ausstieg · ★ stark"
var string LEGEND_6                   = "▽orange = Divergenz-Warnung"

var string ALERT_TITLE_STRONG_BUY     = "Starkes Kaufsignal"
var string ALERT_MSG_STRONG_BUY       = "MFMS: Starkes Kaufsignal aktiv"
var string ALERT_TITLE_GOOD_BUY       = "Gutes Kaufsignal"
var string ALERT_MSG_GOOD_BUY         = "MFMS: Gutes Kaufsignal aktiv"
var string ALERT_TITLE_SELL           = "Verkaufssignal"
var string ALERT_MSG_SELL             = "MFMS: Verkaufen / Meiden"

var string HLINE_STRONG               = "Score >= 0.80"
var string HLINE_GOOD                 = "Score >= 0.65"
var string HLINE_WATCH                = "Score >= 0.50"
var string HLINE_FAIL                 = "Score < 0.30"

var string S_GT_50_PERCENT            = ">50 %"
var string S_SPACE                    = " "

// === TOOLTIPS ============================================
var string tt_bench = "Hier waehlst du den Vergleichsmarkt, gegen den das Instrument gemessen wird.\n\nWarum ist das wichtig?\nDie Benchmark beeinflusst vor allem die Relative Staerke und das Marktregime. Das Skript prueft also nicht nur, ob der Kurs steigt, sondern ob er besser laeuft als der gewaehlte Vergleichsmarkt.\n\nBeispiele:\n• SPY = breiter US-Aktienmarkt\n• DAX = deutscher Aktienmarkt\n• ACWI = weltweiter Aktienmarkt\n\nWichtig: Eine unpassende Benchmark macht die Relative Staerke zwar nicht technisch falsch, aber inhaltlich weniger sinnvoll."
var string tt_w_rs = "Das Gewicht der Relativen Staerke in der Gesamt-Note.\n\nWie wirkt das?\nDie Gesamt-Note setzt sich aus mehreren Bausteinen zusammen. Dieses Gewicht legt fest, wie stark die Kursentwicklung gegenueber den anderen Bausteinen zaehlt.\n\nStandard:\n0.50 = 50 % Gewicht.\nHoeher = Kursverhalten zaehlt mehr.\nNiedriger = Fundamentaldaten und Trend bekommen relativ mehr Einfluss.\n\nSinnvoll fuer:\nNutzer, die Momentum und Marktstaerke bewusst stark gewichten wollen."
var string tt_w_earn = "Das Gewicht der Gewinn-Qualitaet in der Gesamt-Note.\n\nWas steckt dahinter?\nDieser Block bewertet nicht den Kurs, sondern die Qualitaet des Unternehmens. Verwendet werden Gewinnwachstum, Umsatzwachstum und Eigenkapitalrendite.\n\nStandard:\n0.35 = 35 % Gewicht.\nHoeher = das Skript bevorzugt staerker Unternehmen mit guten Zahlen.\n\nSinnvoll fuer:\nNutzer, die weniger auf reine Kursdynamik und mehr auf wirtschaftliche Substanz achten."
var string tt_w_trend = "Das Gewicht der Trend-Qualitaet in der Gesamt-Note.\n\nWas prueft dieser Block?\nOb der Kurs technisch in einem gesunden Aufwaertstrend liegt. Dazu zaehlen Lage ueber dem SMA200, Golden Cross und ein begrenzter Rueckgang vom letzten Hoch.\n\nStandard:\n0.15 = 15 % Gewicht.\nHoeher = das Skript wird vorsichtiger gegenueber angeschlagenen Trends.\n\nDieser Baustein wirkt eher wie ein technisches Sicherheitsnetz als wie ein Wachstumsfaktor."
var string tt_thr_S = "Die Schwelle fuer ein starkes Kaufsignal.\n\nWie wird das genutzt?\nUeberschreitet die Gesamt-Note diesen Wert und die noetigen Sicherheitsbedingungen sind erfuellt, stuft das Skript den Titel als besonders stark ein.\n\nStandard:\n0.80.\nDas ist bewusst hoch angesetzt. Ein Wert ueber 0.80 bedeutet meist: Kurs, Trend und Datenlage sind gleichzeitig sehr stark.\n\nHoeher = seltener, strenger.\nNiedriger = haeufiger, aber weniger selektiv."
var string tt_thr_A = "Die Schwelle fuer ein normales Kaufsignal.\n\nWie wird das genutzt?\nAb diesem Bereich gilt ein Titel als kaufbar, sofern die weiteren Sicherheitsregeln ebenfalls passen.\n\nStandard:\n0.65.\nDas ist die eigentliche Hauptschwelle fuer einen moeglichen Einstieg.\n\nPraktisch:\nZwischen 0.65 und 0.79 = guter Kandidat.\nAb 0.80 = besonders starker Kandidat."
var string tt_thr_B = "Die Schwelle fuer 'Beobachten'.\n\nWie liest man das?\nAb diesem Wert ist ein Titel interessant, aber noch nicht stark genug fuer ein klares Kaufsignal. Das ist typischerweise eine Watchlist-Zone.\n\nStandard:\n0.50.\nUnterhalb davon ist die Qualitaet meist zu durchwachsen, oberhalb davon kann sich ein Titel in Richtung Kaufsignal entwickeln."
var string tt_thr_F = "Die Untergrenze fuer schwache Titel.\n\nWie liest man das?\nFaellt die Gesamt-Note unter diesen Wert, sprechen Kurs, Trend oder Unternehmensdaten aktuell eher gegen einen Einstieg.\n\nStandard:\n0.30.\nDas bedeutet nicht automatisch 'sofort verkaufen', aber es ist klar die schwache Zone des Modells."
var string tt_filter = "Ob der Sicherheitsfilter aktiv sein soll.\n\nWie funktioniert der Filter?\nVor einem Kaufsignal prueft das Skript, ob wichtige Mindestbedingungen stimmen. Dazu gehoeren vor allem ein intakter Trend und ein noch vertretbarer Rueckgang vom letzten Hoch. Bei Aktien kommt zusaetzlich die Handelbarkeit ueber den durchschnittlichen Tagesumsatz hinzu. Bei ETFs kann Volumen ebenfalls sinnvoll sein. Bei Indizes wird Volumen meist nicht als harte Mindestbedingung verwendet.\n\nSinn des Filters:\nEin hoher Score allein soll nicht reichen, wenn ein Instrument technisch angeschlagen ist oder sich nur schwer handeln laesst.\n\nEmpfehlung:\nFuer die meisten Nutzer eingeschaltet lassen."
var string tt_max_dd = "Der maximal erlaubte Rueckgang vom letzten 60-Tage-Hoch.\n\nWie wird das berechnet?\nDas Skript vergleicht den aktuellen Kurs mit dem hoechsten Kurs der letzten 60 Handelstage. Daraus ergibt sich der Drawdown in Prozent.\n\nBeispiel:\nStand der Kurs beim Hoch bei 100 und heute bei 78, dann liegt der Drawdown bei -22 %.\n\nNutzen:\nSo werden Titel herausgefiltert, die trotz gutem Score gerade in einem deutlichen Abwaertsschub stecken."
var string tt_min_vol = "Der minimale durchschnittliche Tagesumsatz, den ein Instrument fuer den Sicherheitsfilter erreichen soll.\n\nWie wird das berechnet?\nDas Skript nutzt ungefaehr Kurs x Volumen und bildet daraus den Durchschnitt ueber 20 Handelstage.\n\nWarum ist das wichtig?\nEin hoher Handelsumsatz bedeutet meist bessere Handelbarkeit. Bei sehr niedrigem Umsatz kann schon ein mittelgrosser Kauf oder Verkauf den Kurs spuerbar bewegen.\n\nWichtig:\nBei klassischen Aktien ist dieser Wert meist besonders wichtig. Bei ETFs kann er ebenfalls nuetzlich sein. Bei Indizes ist er oft nicht sinnvoll, weil ein Index selbst meist kein direkt gehandeltes Einzelinstrument ist."
var string tt_tbl_pos = "Die Position der Info-Tabelle im Chart.\n\nDas hat keinen Einfluss auf die Berechnung, sondern nur auf die Darstellung. Wenn die Tabelle wichtige Bereiche verdeckt, einfach eine andere Position waehlen."
var string tt_tbl_sz = "Die Schriftgroesse der Info-Tabelle.\n\nAuch das ist nur eine Anzeige-Einstellung. 'small' ist meist ein guter Standard, 'large' ist auf grossen Monitoren angenehmer."
var string tt_show_bg = "Ob der Hintergrund das Signal des Titels oder eher das Marktumfeld zeigen soll.\n\nWenn aktiviert:\nDer Hintergrund folgt staerker dem aktuellen Urteil des Skripts.\n\nWenn deaktiviert:\nDer Hintergrund zeigt vor allem das Marktregime, also ob der gewaehlte Benchmark eher in einer starken oder schwachen Phase liegt."
var string tt_chart = "① Die gelbe Linie ist die Gesamt-Note von 0.00 bis 1.00.\n② Die blaue Linie zeigt Relative Staerke.\n③ Die orange Linie zeigt Gewinn-Qualitaet.\n④ Die weisse Linie zeigt den Bewertungs-Schwung.\n\nWie liest man das?\nDie Hauptlinie zeigt das Endergebnis. Die anderen Linien erklaeren, warum die Bewertung hoch oder niedrig ist.\n\nWichtig:\nDie Berechnungen basieren auf Tagesdaten, auch wenn dein sichtbarer Chart ein anderes Zeitfenster hat."
var string tt_signale = "Gruener Pfeil nach oben:\nDie Gesamt-Note hat die Kauf-Schwelle ueberschritten.\n\nGrosser gruener Pfeil:\nDie starke Kauf-Schwelle wurde ueberschritten.\n\nRoter Pfeil nach unten:\nDie Gesamt-Note ist wieder unter die Kauf-Schwelle gefallen.\n\nOranges Dreieck:\nDivergenz-Warnung. Der Kurs macht noch ein neues Hoch, aber die innere Staerke laesst schon nach.\n\nWichtig:\nDiese Signale nie isoliert lesen, sondern immer zusammen mit Score, Tabelle und Marktumfeld."
var string tt_empfehlung = "Das zusammengefasste Urteil des Skripts.\n\nWie entsteht es?\nDie Empfehlung basiert auf der Gesamt-Note, den eingestellten Schwellen und den aktiven Sicherheitsregeln. In der v2 fliessen zusaetzlich Datenabdeckung, Historie und je nach Modus die Gueltigkeit der Benchmark mit ein.\n\nPraktisch:\n'Kaufen' bedeutet nicht Sicherheit, sondern dass der Titel die Regeln des Modells aktuell erfuellt. 'Datenlage schwach' bedeutet, dass das Modell sich bewusst zurueckhaelt.\n\nWichtig:\nDas Urteil des Modells beruht auf verfuegbaren Markt- und Fundamentaldaten. Bei fehlerhaften, lueckenhaften oder verzoegerten Quelldaten koennen einzelne Kennzahlen trotz korrekter Berechnung unerwartet ausfallen."
var string tt_action = "Ein praktischer Handlungsvorschlag passend zur aktuellen Empfehlung.\n\nWie ist das gemeint?\nDie Texte sind keine starre Vorschrift, sondern eine strukturierte Uebersetzung des Signals in eine moegliche Aktion: kaufen, beobachten, abwarten oder nicht handeln.\n\nDie genannten Depot-Prozentwerte sind nur grobe Richtwerte fuer Risikosteuerung, nicht fuer jeden Nutzer gleich passend."
var string tt_earn_days = "Diese Zeile zeigt den naechsten bekannten Unternehmenstermin, soweit fuer das Instrument sinnvoll verfuegbar.\n\nBei Aktien:\nMeist ist damit der naechste Quartalszahlen-Termin gemeint.\n\nBei ETFs, Indizes und anderen Maerkten:\nSolche Termine sind oft nicht vorhanden oder fuer das Modell nicht gleich sinnvoll nutzbar. Dann bleibt die Anzeige leer oder neutral.\n\nWie liest man das?\nEin naher Termin kann bei Aktien zusaetzliche Unsicherheit und staerkere Kursschwankungen ausloesen."
var string tt_master = "Die Gesamt-Note des Modells auf einer Skala von 0.00 bis 1.00.\n\nWie wird sie berechnet?\nDie Note setzt sich aus den aktiven Bausteinen zusammen:\n• Relative Staerke\n• Gewinn-Qualitaet\n• Trend-Qualitaet\nDie Standard-Gewichte sind 50 % / 35 % / 15 %. In der v2 werden nur Bausteine gewertet, fuer die auch wirklich nutzbare Daten vorliegen.\n\nWie liest man den Wert?\nJe hoeher, desto besser. Ab 0.50 wird ein Titel interessant, ab 0.65 kommt er in die Kaufzone, ab 0.80 wird das Signal besonders stark.\n\nWichtig:\nEine hohe Note ist nur dann besonders belastbar, wenn auch Coverage, Confidence, Historie und die zugelieferten Daten selbst plausibel sind. Das Skript kann mathematisch korrekt rechnen und trotzdem auf Basis fehlerhafter, lueckenhafter oder verzoegerter Quelldaten zu unerwarteten Einzelwerten kommen."
var string tt_rs = "Die Relative Staerke bzw. Kurs-Staerke.\n\nWie wird sie berechnet?\nEs fliessen fuenf Teilbereiche ein:\n• 12-Monats-Entwicklung ohne den letzten Monat = 40 %\n• 6-Monats-Entwicklung = 20 %\n• 3-Monats-Entwicklung = 15 %\n• Naehe zum 52-Wochen-Hoch = 15 %\n• Entwicklung der RS-Linie gegen die Benchmark = 10 %\n\nWichtig:\nIn der v2 wird nur gewertet, was auch wirklich vorhanden ist. Fehlen Teilkomponenten, sinkt die Datenabdeckung dieses Blocks.\n\nWie liest man den Wert?\nEin hoher RS-Wert bedeutet: Der Titel zeigt aktuell starkes Kursverhalten relativ zu seiner Historie und zur gewaehlten Benchmark."
var string tt_trend = "Die technische Trend-Qualitaet des Titels.\n\nWie wird sie berechnet?\nDrei Bedingungen fliessen ein:\n• Kurs ueber SMA200 = 40 %\n• 50-Tage-Durchschnitt ueber 200-Tage-Durchschnitt (Golden Cross) = 30 %\n• Rueckgang vom 60-Tage-Hoch noch im erlaubten Rahmen = 30 %\n\nWie liest man die Anzeige?\n✓ bedeutet: Bedingung erfuellt.\n✗ bedeutet: Bedingung nicht erfuellt.\n\nEin hoher Trend-Wert heisst nicht automatisch 'Kaufsignal', aber er zeigt, dass der Titel technisch sauberer aussieht als ein Wert im Abwaertstrend."
var string tt_earn = "Diese Zeile zeigt die fundamentale Qualitaet des Instruments, soweit solche Unternehmensdaten sinnvoll vorliegen.\n\nBei Aktien:\nDer Wert basiert auf Gewinnwachstum, Umsatzwachstum und Eigenkapitalrendite.\n\nBei ETFs, Indizes und vielen anderen Maerkten:\nSolche Fundamentaldaten sind oft nicht direkt vergleichbar oder nicht passend. Dann zeigt das Skript hier bewusst keinen vollwertigen Fundamentalwert an.\n\nWie liest man das?\nHoher Wert = aus Sicht des Modells bessere fundamentale Unternehmensqualitaet.\nKein Wert = nicht automatisch schlecht, sondern oft fuer diesen Instrumenttyp nicht passend."
var string tt_eps = "Das Gewinnwachstum pro Aktie gegenueber dem gleichen Zeitraum des Vorjahres, soweit der Datenfeed dafuer nutzbare Werte liefert.\n\nWas bedeutet das?\nEPS steht fuer Earnings per Share, also Gewinn pro Aktie. Verglichen wird, wie stark dieser Wert gegenueber dem Vorjahr gestiegen oder gefallen ist.\n\nWichtig:\nDiese Kennzahl ist vor allem fuer Aktien sinnvoll. Bei ETFs, Indizes und vielen anderen Maerkten ist sie meist nicht passend oder nicht verfuegbar.\n\nWie liest man das?\nPositiv ist meist gut, stark negativ ist ein Warnsignal. Immer zusammen mit der Datenbasis und den uebrigen Fundamentaldaten lesen."
var string tt_rev = "Das Umsatzwachstum gegenueber dem Vorjahr.\n\nWas ist Umsatz?\nUmsatz ist das Geld, das ein Unternehmen mit seinen Produkten oder Dienstleistungen einnimmt, bevor Kosten abgezogen werden.\n\nWichtig:\nDiese Kennzahl ist vor allem fuer Aktien sinnvoll. Bei ETFs, Indizes und vielen anderen Maerkten ist sie meist nicht passend oder nicht verfuegbar.\n\nWie liest man das?\nSteigender Umsatz deutet oft auf Nachfrage oder Wachstum hin. Sinkender Umsatz kann ein fruehes Warnzeichen sein."
var string tt_roe = "Die Eigenkapitalrendite, meist auf Basis der letzten 12 Monate.\n\nWie wird sie gedacht?\nSie zeigt, wie effizient ein Unternehmen mit dem Kapital seiner Eigentuemer Geld verdient.\n\nWichtig:\nDiese Kennzahl ist vor allem fuer Aktien sinnvoll. Bei ETFs, Indizes und vielen anderen Maerkten ist sie meist nicht direkt passend.\n\nWie liest man das?\nHoeher ist oft besser. Sehr niedrige oder negative Werte sind eher schwach. Sehr hohe Werte koennen allerdings auch durch hohe Verschuldung beeinflusst sein."
var string tt_de = "Das Verschuldungsverhaeltnis Debt/Equity.\n\nWie wird es gedacht?\nEs setzt die Schulden eines Unternehmens ins Verhaeltnis zum Eigenkapital.\n\nWichtig:\nDiese Kennzahl ist vor allem fuer Aktien sinnvoll. Bei ETFs, Indizes und vielen anderen Maerkten ist sie oft nicht passend oder nicht direkt vergleichbar.\n\nWie liest man das?\nNiedriger ist oft stabiler. Hohe Werte bedeuten meist mehr finanzielle Hebelwirkung und damit potenziell mehr Risiko."
var string tt_sektor = "Der Wirtschaftssektor des Unternehmens.\n\nWarum ist das wichtig?\nKennzahlen sind nicht in jeder Branche gleich zu bewerten. Hohe Verschuldung kann bei Banken normal sein, bei Softwarefirmen eher nicht. Der Sektor hilft also, Zahlen wie ROE und D/E realistischer einzuordnen."
var string tt_industrie = "Die genauere Unterbranche innerhalb des Sektors.\n\nNutzen:\nSie hilft besser zu verstehen, womit das Unternehmen konkret sein Geld verdient. Das ist besonders hilfreich, wenn zwei Firmen zwar im gleichen Sektor liegen, aber in sehr unterschiedlichen Geschaeftsmodellen arbeiten."
var string tt_peg = "Das PEG-Verhaeltnis. Diese Kennzahl ist informativ und fliesst nicht direkt in den Score ein.\n\nWie wird es gedacht?\nEs verbindet Bewertung und Wachstum, vereinfacht gesagt: KGV geteilt durch EPS-Wachstum.\n\nWichtig:\nDiese Kennzahl ist vor allem fuer Aktien sinnvoll. Bei ETFs, Indizes und vielen anderen Maerkten ist sie meist nicht passend oder nicht belastbar.\n\nWie liest man das?\nNiedriger ist meist guenstiger im Verhaeltnis zum Wachstum. Sehr hohe oder fehlende Werte sollte man vorsichtig lesen."
var string tt_fcf = "Die Cashflow-Rendite auf Basis des freien Cashflows.\n\nWie wird sie gedacht?\nSie vergleicht den freien Cashflow mit dem aktuellen Boersenwert des Unternehmens.\n\nWichtig:\nDiese Kennzahl ist vor allem fuer Aktien sinnvoll. Bei ETFs, Indizes und vielen anderen Maerkten ist sie meist nicht passend.\n\nWie liest man das?\nHoeher ist oft besser. Negative Werte bedeuten, dass aktuell kein positiver freier Cashflow vorhanden ist."
var string tt_dist = "Der Abstand des aktuellen Kurses zum 52-Wochen-Hoch.\n\nWie wird das berechnet?\nAktueller Kurs im Verhaeltnis zum hoechsten Kurs der letzten 252 Handelstage.\n\nWie liest man das?\nEin kleiner Abstand bedeutet oft Staerke. Ein grosser Abstand zeigt meist, dass der Titel deutlich unter frueheren Hochs notiert.\n\nWichtig:\nNicht jeder Titel nahe am Hoch ist automatisch guenstig, aber starke Titel handeln statistisch oft naeher an ihren Hochs als schwache."
var string tt_vol = "Der durchschnittliche Tagesumsatz der letzten 20 Handelstage, soweit fuer das Instrument sinnvoll verfuegbar.\n\nWie wird das berechnet?\nUngefaehr Kurs x Volumen, gemittelt ueber 20 Tage.\n\nWie liest man das?\nHoher Wert = meist bessere Handelbarkeit.\nNiedriger Wert = hoeheres Ausfuehrungs- und Slippage-Risiko.\n\nWichtig:\nBei Aktien und vielen ETFs ist dieser Wert gut nutzbar. Bei Indizes oder manchen anderen Maerkten ist er oft nicht oder nur eingeschraenkt sinnvoll zu interpretieren."
var string tt_filter_row = "Das Ergebnis der Sicherheitspruefung.\n\nWas wird geprueft?\nJe nach Instrument vor allem:\n• Trend ueber dem langfristigen Durchschnitt\n• Rueckgang vom letzten Hoch noch im erlaubten Rahmen\n• bei Aktien zusaetzlich ausreichender durchschnittlicher Tagesumsatz\n• bei ETFs optional ebenfalls Handelbarkeit\n\nWie liest man das?\n✓ BESTANDEN = die Mindestbedingungen fuer Kaufsignale sind erfuellt.\n✗ NICHT BESTANDEN = mindestens eine Sicherheitsbedingung blockiert das Kaufsignal.\n✓ TREND OK = bei Maerkten ohne klassischen Handelsfilter ist der technische Mindestzustand erfuellt.\n⚠ BENCHMARK FEHLT = fuer Teile der Logik fehlt ein wichtiger Vergleichsmarkt."
var string tt_markt_regime = "Er zeigt das allgemeine Marktumfeld (Marktregime) des gewaehlten Vergleichsmarkts.\n\nWie wird das berechnet?\nDie Benchmark wird mit ihrem 200-Tage-Durchschnitt verglichen.\n• ueber SMA200 = eher freundliches Marktumfeld\n• unter SMA200 = eher schwaches Marktumfeld\n\nWie liest man das?\nPositiv = der Gesamtmarkt liefert eher Rueckenwind.\nNegativ = der Gesamtmarkt liefert eher Gegenwind.\n\nWarum ist das wichtig?\nKaufsignale funktionieren in starken Gesamtmaerkten oft besser als in schwachen."
var string tt_score_mom = "Den Bewertungs-Schwung des Gesamt-Scores.\n\nWie wird er berechnet?\nHeutiger Gesamt-Score minus Gesamt-Score von vor 20 Handelstagen.\n\nWie liest man das?\n• Positiv = der Score hat sich in den letzten Wochen verbessert\n• Negativ = der Score hat sich verschlechtert\n• Nahe null = wenig Veraenderung\n\nNutzen:\nDas ist ein Fruehindikator fuer Beschleunigung oder Ermuedung, aber kein eigenstaendiges Kaufsignal."
var string tt_earnings_zone = "Sie markieren die Phase vor Quartalszahlen.\n\nWarum ist das wichtig?\nKurz vor Earnings steigt oft das Kursrisiko, weil neue Unternehmenszahlen und Ausblicke veroeffentlicht werden.\n\nWie liest man die Farben?\nGelb = Termin rueckt naeher.\nOrange = sehr nah, erhoehtes Risiko.\n\nPraktisch:\nViele Nutzer vermeiden neue Einstiege direkt vor Earnings."
var string tt_divergenz = "Eine Divergenz-Warnung.\n\nWie entsteht sie im Skript?\nDas Signal erscheint, wenn der Kurs ein neues 20-Tage-Hoch macht, waehrend der Gesamt-Score zuletzt faellt und noch nicht komplett schwach ist.\n\nWas bedeutet das inhaltlich?\nDer Kurs sieht nach aussen noch stark aus, aber die innere Qualitaet des Signals laesst bereits nach.\n\nDas ist kein automatischer Verkaufsbefehl, aber ein klarer Hinweis auf nachlassende innere Staerke."
var string tt_rib_master = "Die dicke Hauptlinie ist die Gesamt-Note des Modells zwischen 0.00 und 1.00.\n\nSie ist die Zusammenfassung aller aktiven Bausteine und damit die wichtigste Linie im Fenster.\n\nJe hoeher die Linie, desto besser der Titel nach den Regeln des Skripts."
var string tt_rib_rs = "Die blaue Linie zeigt die Relative Staerke.\n\nSie ist ein eigener Teilscore von 0.00 bis 1.00 und misst, wie stark das Kursverhalten im Vergleich zur Historie und zur Benchmark ist.\n\nDa sie standardmaessig 50 % Gewicht hat, ist sie der wichtigste Einzelbaustein."
var string tt_rib_earn = "Die orange Linie zeigt die Gewinn-Qualitaet bzw. fundamentale Qualitaet.\n\nSie basiert auf EPS-Wachstum, Umsatzwachstum und ROE. Bei fehlenden Fundamentaldaten kann sie in der v2 ausbleiben, statt kuenstlich eine vollwertige Aussage vorzutäuschen."
var string tt_rib_mom = "Die weisse Linie zeigt den Bewertungs-Schwung.\n\nAnders als die anderen Linien bewegt sie sich um den Nullpunkt. Positiv bedeutet: Der Score ist besser als vor 20 Handelstagen. Negativ bedeutet: Er ist schwächer geworden.\n\nDiese Linie ist besonders nuetzlich, um fruehe Verbesserungen oder erste Ermuedung zu erkennen."
var string tt_mode = "Der Modus legt fest, welche Art von Instrument das Skript vor sich hat.\n\nMoegliche Faelle:\n• Aktie = einzelnes Unternehmen\n• ETF = boersengehandelter Fonds\n• Index = Marktbarometer wie DAX oder S&P 500\n• Anleihe = zinssensitives Renteninstrument\n• sonstiger Markt = z. B. Forex, Krypto oder Rohstoffe\n\nWarum ist das wichtig?\nNicht jede Art von Instrument hat dieselben Daten. Aktien haben oft Fundamentaldaten und Earnings-Termine. ETFs, Indizes und Anleihen dagegen vor allem Markt-, Trend- und Benchmark-Logik. Der Modus sorgt dafuer, dass das Skript Kennzahlen nicht dort erzwingt, wo sie inhaltlich nicht sauber passen.\n\nWie wird das ermittelt?\nIm Auto-Modus nutzt das Skript Angaben wie Boersenplatz, Symboltyp, Beschreibung und verfuegbare Stammdaten. Dadurch trennt es Aktien, ETFs, Indizes, Anleihen und sonstige Maerkte sauberer als zuvor.\n\nWie liest man das?\nDer angezeigte Modus ist die Grundlage dafuer, welche Teile des Modells gewertet und welche Zeilen in der Tabelle sinnvoll angezeigt werden."
var string tt_cov = "Datenbasis und Modellvertrauen.\n\nWas zeigt das?\nDer erste Wert zeigt, wie viele der fuer dieses Instrument wichtigen Teilinformationen aktuell wirklich nutzbar sind. Der zweite Wert verbindet diese Datenabdeckung zusaetzlich mit der verfuegbaren Kurshistorie zu einem vorsichtigen Modellvertrauen.\n\nWie wird das ermittelt?\nJe nach Instrument zaehlen unterschiedliche Bausteine:\n• Aktie: Relative Staerke + Gewinn-Qualitaet + Trend\n• ETF: Relative Staerke + Trend\n• Index: Relative Staerke + Trend\n• Anleihe: Relative Staerke + Trend\n• sonstiger Markt: Relative Staerke + Trend\n\nWichtig:\nHohe Werte bedeuten vor allem, dass das Modell auf einer breiteren und technisch besser nutzbaren Datenbasis rechnet. Das ist kein direkter Guetestempel fuer die inhaltliche Plausibilitaet jedes einzelnen Fundamentalwerts.\n\nWie liest man das?\nHohe Werte = stabilere Berechnungsbasis.\nNiedrige Werte = Ergebnis vorsichtiger lesen, auch wenn der Gesamt-Score ordentlich aussieht."
var string tt_hist = "Der Historienstatus des Titels.\n\nWie wird das beurteilt?\nDas Skript prueft, ob genug Kurshistorie fuer 63, 126, 200 und 252 Handelstage vorhanden ist. Erst mit ausreichend Historie koennen Relative Staerke, Trend und Abstaende sauber berechnet werden.\n\nWie liest man das?\n• Vollstaendig = gute Datenbasis\n• Eingeschraenkt = einige Teile sind nutzbar, andere nur begrenzt\n• Zu kurz = das Signal ist deutlich weniger belastbar"

// === HILFE & ERKLAERUNGEN ===================================================
i_help_chart   = input.bool(false, I_HELP_CHART, tooltip=tt_chart, group=G_HELP)
i_help_signale = input.bool(false, I_HELP_SIGNALE, tooltip=tt_signale, group=G_HELP)
i_help_empfehlung = input.bool(false, I_HELP_EMPFEHLUNG, tooltip=tt_empfehlung, group=G_HELP)
i_help_action  = input.bool(false, I_HELP_ACTION, tooltip=tt_action, group=G_HELP)

// === INPUTS =================================================================
bench_mode      = input.string(S_AUTO, I_BENCH_MODE, options=[S_AUTO, S_MANUELL], group=G_MARKET)
bench_manual    = input.symbol(DEFAULT_BENCHMARK, I_BENCH_MANUAL, group=G_MARKET)

w_rs            = input.float(0.50, I_W_RS, step=0.05, minval=0, maxval=1, tooltip=tt_w_rs, group=G_SETTINGS)
w_earn          = input.float(0.35, I_W_EARN, step=0.05, minval=0, maxval=1, tooltip=tt_w_earn, group=G_SETTINGS)
w_trend         = input.float(0.15, I_W_TREND, step=0.05, minval=0, maxval=1, tooltip=tt_w_trend, group=G_SETTINGS)

thr_S           = input.float(0.80, I_THR_STRONG, step=0.05, tooltip=tt_thr_S, group=G_THRESHOLDS)
thr_A           = input.float(0.65, I_THR_GOOD, step=0.05, tooltip=tt_thr_A, group=G_THRESHOLDS)
thr_B           = input.float(0.50, I_THR_WATCH, step=0.05, tooltip=tt_thr_B, group=G_THRESHOLDS)
thr_F           = input.float(0.30, I_THR_FAIL, step=0.05, tooltip=tt_thr_F, group=G_THRESHOLDS)

use_filter      = input.bool(true, I_USE_FILTER, tooltip=tt_filter, group=G_FILTER)
max_dd60d_pct   = input.float(-25.0, I_MAX_DD, step=1, tooltip=tt_max_dd, group=G_FILTER)
min_avg_vol_usd = input.float(5e6, I_MIN_VOL, step=1e6, tooltip=tt_min_vol, group=G_FILTER)

asset_mode_in   = input.string(S_AUTO, I_ASSET_MODE, options=[S_AUTO, S_AKTIE_IN, S_ETF_INDEX_IN, S_ANLEIHE_IN, S_OTHER_IN], tooltip=tt_mode, group=G_MARKET)
min_cov_buy     = input.float(0.70, I_MIN_COV_BUY, step=0.05, minval=0, maxval=1, tooltip=tt_cov, group=G_MARKET)
min_cov_watch   = input.float(0.45, I_MIN_COV_WATCH, step=0.05, minval=0, maxval=1, tooltip=tt_cov, group=G_MARKET)
min_hist_bars   = input.int(252, I_MIN_HIST, minval=50, tooltip=tt_hist, group=G_MARKET)
strict_bench    = input.bool(true, I_STRICT_BENCH, tooltip=tt_bench, group=G_MARKET)

table_pos       = input.string(S_TOPRIGHT, I_TABLE_POS, options=[S_TOPRIGHT, S_MIDDLERIGHT, S_BOTTOMRIGHT, S_TOPLEFT, S_MIDDLELEFT, S_BOTTOMLEFT], tooltip=tt_tbl_pos, group=G_DISPLAY)
table_sz        = input.string(S_SMALL, I_TABLE_SIZE, options=[S_TINY, S_SMALL, S_NORMAL, S_LARGE], tooltip=tt_tbl_sz, group=G_DISPLAY)
show_bg         = input.bool(false, I_SHOW_BG, tooltip=tt_show_bg, group=G_DISPLAY)
show_legend     = input.bool(false, I_SHOW_LEGEND, group=G_DISPLAY)

// === DAILY-DATEN ============================================================
d_close  = request.security(syminfo.tickerid, "D", close,  lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
d_high   = request.security(syminfo.tickerid, "D", high,   lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
d_low    = request.security(syminfo.tickerid, "D", low,    lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
d_volume = request.security(syminfo.tickerid, "D", volume, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
float d_bench  = na
d_atr    = request.security(syminfo.tickerid, "D", ta.atr(14), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

// === HILFSFUNKTIONEN ========================================================
winsor(float v, float lo, float hi) =>
    na(v) ? na : math.max(math.min(v, hi), lo)

clamp01(float v) =>
    math.max(math.min(v, 1), 0)

f_bool_score(bool cond, float w) =>
    cond ? w : 0.0

f_has_hist(series float s, int barsBack) =>
    not na(s[barsBack])

// === FARBEN & HILFSFUNKTIONEN ===============================================
color bg_label   = #000000
color bg_value   = #2C2F36
color txt_main   = #FFFFFF
color col_green  = #00C853
color col_lime   = #64DD17
color col_yellow = #FFD600
color col_orange = #FF6D00
color col_red    = #D50000
color col_none   = #2C2F36
color col_info   = #1565C0

score_col(float s) =>
    na(s) ? col_none : s >= 0.80 ? col_green : s >= 0.65 ? col_lime : s >= 0.50 ? col_yellow : s >= 0.30 ? col_orange : col_red

f_pct(float v) =>
    na(v) ? S_NA : (v >= 0 ? S_PLUS : S_EMPTY) + str.tostring(v, "0.0") + S_PERCENT

f_mult(float v) =>
    na(v) ? S_NA : str.tostring(v, "0.00") + S_MULT

f_roe(float v) =>
    na(v) ? S_NA : v > 50 ? S_GT_50_PERCENT : (v >= 0 ? S_PLUS : S_EMPTY) + str.tostring(v, "0.0") + S_PERCENT

f_de(float v) =>
    na(v) ? S_NA : str.tostring(v, "0.00") + S_MULT

f_dist(float raw) =>
    if na(raw)
        S_NA
    else
        float pct = (raw - 1.0) * 100.0
        (pct >= 0 ? S_PLUS : S_EMPTY) + str.tostring(pct, "0.0") + S_PERCENT

col_eps(float v) =>
    na(v) ? col_none : v > 25 ? col_green : v >= 0 ? col_yellow : v >= -25 ? col_orange : col_red

col_rev(float v) =>
    na(v) ? col_none : v > 15 ? col_green : v >= 0 ? col_yellow : v >= -15 ? col_orange : col_red

col_roe(float v) =>
    na(v) ? col_none : v > 25 ? col_green : v >= 10 ? col_yellow : v >= 0 ? col_orange : col_red

col_de(float v) =>
    na(v) ? col_none : v < 0.5 ? col_green : v < 1.5 ? col_yellow : v < 3.0 ? col_orange : col_red

col_peg(float v) =>
    na(v) ? col_none : v < 0 ? col_red : v < 1.0 ? col_green : v < 2.0 ? col_yellow : col_orange

col_fcf(float v) =>
    na(v) ? col_none : v > 8 ? col_green : v >= 4 ? col_lime : v >= 0 ? col_orange : col_red

col_dist(float r) =>
    if na(r)
        col_none
    else
        float p = (r - 1.0) * 100.0
        p >= -10.0 ? col_green : p >= -20.0 ? col_yellow : p >= -35.0 ? col_orange : col_red

// === INSTRUMENT-MODUS =======================================================
bool has_sector   = not na(syminfo.sector) and syminfo.sector != ""
bool has_industry = not na(syminfo.industry) and syminfo.industry != ""
bool has_volume   = not na(d_volume)

string ticker_upper      = str.upper(syminfo.ticker)
string tickerid_upper    = str.upper(syminfo.tickerid)
string description_upper = str.upper(syminfo.description)
string type_upper        = str.upper(syminfo.type)
string prefix_upper_mode = str.upper(syminfo.prefix)

bool looks_crypto =
     str.contains(tickerid_upper, "CRYPTO:") or
     type_upper == "CRYPTO" or
     str.contains(description_upper, "BITCOIN") or
     str.contains(description_upper, "ETHEREUM") or
     str.contains(ticker_upper, "BTC") or
     str.contains(ticker_upper, "ETH") or
     str.contains(ticker_upper, "SOL") or
     str.contains(ticker_upper, "XRP") or
     str.contains(ticker_upper, "ADA") or
     str.contains(ticker_upper, "DOGE") or
     str.contains(ticker_upper, "BNB") or
     str.contains(ticker_upper, "AVAX")

bool is_bitcoin =
     str.contains(tickerid_upper, "BTC") or
     str.contains(ticker_upper, "BTC") or
     str.contains(description_upper, "BITCOIN")

bool looks_fx =
     str.contains(tickerid_upper, "FX:") or
     str.contains(tickerid_upper, "OANDA:") or
     str.contains(tickerid_upper, "FOREXCOM:") or
     type_upper == "FOREX"

bool looks_commodity =
     type_upper == "FUTURES" or
     str.contains(description_upper, "GOLD") or
     str.contains(description_upper, "SILVER") or
     str.contains(description_upper, "CRUDE") or
     str.contains(description_upper, "OIL") or
     str.contains(description_upper, "NATURAL GAS")

bool looks_index =
     type_upper == "INDEX" or
     str.contains(tickerid_upper, "TVC:") or
     str.contains(description_upper, "INDEX")

bool looks_bond =
     type_upper == "BOND" or
     str.contains(description_upper, "BOND") or
     str.contains(description_upper, "ANLEIHE") or
     str.contains(description_upper, "TREASURY") or
     str.contains(description_upper, "T-NOTE") or
     str.contains(description_upper, "TREASURY NOTE") or
     str.contains(description_upper, "BUND") or
     str.contains(description_upper, "GILT") or
     str.contains(description_upper, "SCHATZ")

bool looks_etf =
     (type_upper == "FUND" or
     str.contains(description_upper, "ETF") or
     str.contains(description_upper, "ETN")) and not looks_bond

bool looks_stock_by_exchange =
     str.contains(prefix_upper_mode, "NASDAQ") or
     str.contains(prefix_upper_mode, "NYSE") or
     str.contains(prefix_upper_mode, "AMEX") or
     str.contains(prefix_upper_mode, "TSX") or
     str.contains(prefix_upper_mode, "TSXV") or
     str.contains(prefix_upper_mode, "XETR") or
     str.contains(prefix_upper_mode, "FWB") or
     str.contains(prefix_upper_mode, "LSE") or
     str.contains(prefix_upper_mode, "ASX") or
     str.contains(prefix_upper_mode, "NSE") or
     str.contains(prefix_upper_mode, "BSE") or
     str.contains(prefix_upper_mode, "HKEX") or
     str.contains(prefix_upper_mode, "SSE") or
     str.contains(prefix_upper_mode, "SZSE") or
     str.contains(prefix_upper_mode, "KRX") or
     str.contains(prefix_upper_mode, "KOSDAQ") or
     str.contains(prefix_upper_mode, "TWSE") or
     str.contains(prefix_upper_mode, "TPEX") or
     str.contains(prefix_upper_mode, "SGX") or
     str.contains(prefix_upper_mode, "BMV") or
     str.contains(prefix_upper_mode, "BMFBOVESPA") or
     str.contains(prefix_upper_mode, "JSE") or
     str.contains(prefix_upper_mode, "SIX") or
     str.contains(prefix_upper_mode, "OMX")

bool auto_other_like =
     looks_crypto or looks_fx or looks_commodity

bool auto_bond_like =
     not auto_other_like and looks_bond

bool auto_index_like =
     not auto_other_like and not auto_bond_like and looks_index and not looks_etf

bool auto_etf_like =
     not auto_other_like and not auto_bond_like and not auto_index_like and looks_etf

bool auto_equity_like =
     not auto_other_like and not auto_bond_like and not auto_index_like and not auto_etf_like and
     (has_sector or has_industry or looks_stock_by_exchange)

string asset_class =
     looks_crypto      ? S_MODE_KRYPTO :
     looks_fx          ? S_MODE_FOREX :
     looks_commodity   ? S_MODE_ROHSTOFF :
     auto_bond_like    ? S_MODE_BOND :
     auto_index_like   ? S_MODE_INDEX :
     auto_etf_like     ? S_MODE_ETF :
     auto_equity_like  ? S_MODE_AKTIE :
                         S_MODE_ETF

string asset_mode =
     asset_mode_in == S_AKTIE_IN     ? S_MODE_AKTIE :
     asset_mode_in == S_ETF_INDEX_IN ? (asset_class == S_MODE_INDEX ? S_MODE_INDEX : S_MODE_ETF) :
     asset_mode_in == S_ANLEIHE_IN   ? S_MODE_BOND :
     asset_mode_in == S_OTHER_IN     ? asset_class :
                                       asset_class

bool mode_equity    = asset_mode == S_MODE_AKTIE
bool mode_etf       = asset_mode == S_MODE_ETF
bool mode_index     = asset_mode == S_MODE_INDEX
bool mode_bond      = asset_mode == S_MODE_BOND
bool mode_crypto    = asset_mode == S_MODE_KRYPTO
bool mode_fx        = asset_mode == S_MODE_FOREX
bool mode_commodity = asset_mode == S_MODE_ROHSTOFF
bool mode_other     = mode_crypto or mode_fx or mode_commodity

bool use_bench_rs = mode_equity or mode_etf or mode_index or mode_bond or (mode_crypto and not is_bitcoin)

// === BENCHMARK-LOGIK ========================================================
string prefix_upper = str.upper(syminfo.prefix)
string desc_upper   = str.upper(syminfo.description)
string country_upper = str.upper(syminfo.country)
string cur_upper     = str.upper(syminfo.currency)

bool is_japan =
     str.contains(prefix_upper, "TSE") or str.contains(country_upper, "JAPAN") or cur_upper == "JPY"

bool is_korea =
     str.contains(prefix_upper, "KRX") or str.contains(prefix_upper, "KOSDAQ") or
     str.contains(country_upper, "KOREA") or str.contains(country_upper, "SOUTH KOREA") or cur_upper == "KRW"

bool is_china =
     str.contains(prefix_upper, "SSE") or str.contains(prefix_upper, "SZSE") or
     str.contains(country_upper, "CHINA") or cur_upper == "CNY"

bool is_hongkong =
     str.contains(prefix_upper, "HKEX") or str.contains(country_upper, "HONG KONG") or cur_upper == "HKD"

bool is_taiwan =
     str.contains(prefix_upper, "TWSE") or str.contains(prefix_upper, "TPEX") or
     str.contains(country_upper, "TAIWAN") or cur_upper == "TWD"

bool is_india =
     str.contains(prefix_upper, "NSE") or str.contains(prefix_upper, "BSE") or
     str.contains(country_upper, "INDIA") or cur_upper == "INR"

bool is_australia =
     str.contains(prefix_upper, "ASX") or str.contains(country_upper, "AUSTRALIA") or cur_upper == "AUD"

bool is_singapore =
     str.contains(prefix_upper, "SGX") or str.contains(country_upper, "SINGAPORE") or cur_upper == "SGD"

bool is_germany =
     str.contains(prefix_upper, "XETR") or str.contains(prefix_upper, "FWB") or
     str.contains(country_upper, "GERMANY")

bool is_france =
     (str.contains(prefix_upper, "EURONEXT") and str.contains(desc_upper, "PARIS")) or
     str.contains(country_upper, "FRANCE")

bool is_netherlands =
     (str.contains(prefix_upper, "EURONEXT") and str.contains(desc_upper, "AMSTERDAM")) or
     str.contains(country_upper, "NETHERLANDS")

bool is_spain =
     str.contains(prefix_upper, "BME") or str.contains(country_upper, "SPAIN")

bool is_italy =
     str.contains(prefix_upper, "MIL") or str.contains(country_upper, "ITALY")

bool is_switzerland =
     str.contains(prefix_upper, "SIX") or str.contains(country_upper, "SWITZERLAND") or cur_upper == "CHF"

bool is_sweden =
     str.contains(prefix_upper, "OMXSTO") or str.contains(country_upper, "SWEDEN") or cur_upper == "SEK"

bool is_denmark =
     str.contains(prefix_upper, "OMXCOP") or str.contains(country_upper, "DENMARK") or cur_upper == "DKK"

bool is_norway =
     str.contains(prefix_upper, "OSE") or str.contains(country_upper, "NORWAY") or cur_upper == "NOK"

bool is_finland =
     str.contains(prefix_upper, "OMXHEX") or str.contains(country_upper, "FINLAND")

bool is_uk =
     str.contains(prefix_upper, "LSE") or str.contains(country_upper, "UNITED KINGDOM") or
     str.contains(country_upper, "UK") or cur_upper == "GBP"

bool is_canada =
     str.contains(prefix_upper, "TSX") or str.contains(prefix_upper, "TSXV") or
     str.contains(country_upper, "CANADA") or cur_upper == "CAD"

bool is_brazil =
     str.contains(prefix_upper, "BMFBOVESPA") or str.contains(country_upper, "BRAZIL") or cur_upper == "BRL"

bool is_mexico =
     str.contains(prefix_upper, "BMV") or str.contains(country_upper, "MEXICO") or cur_upper == "MXN"

bool is_south_africa =
     str.contains(prefix_upper, "JSE") or str.contains(country_upper, "SOUTH AFRICA") or cur_upper == "ZAR"

bool is_us =
     str.contains(prefix_upper, "NASDAQ") or str.contains(prefix_upper, "NYSE") or
     str.contains(prefix_upper, "AMEX") or str.contains(country_upper, "UNITED STATES")

string auto_bench_primary =
     mode_crypto and not is_bitcoin ? "CRYPTO:BTCUSD" :
     mode_fx or mode_commodity      ? na :
     mode_bond and is_us            ? "TVC:US10Y" :
     mode_bond and is_germany       ? "TVC:DE10Y" :
     mode_bond and is_uk            ? "TVC:UK10Y" :
     mode_bond and is_japan         ? "TVC:JP10Y" :
     mode_bond and is_canada        ? "TVC:CA10Y" :
     mode_bond                      ? "TVC:US10Y" :
     is_us                          ? "SPY" :
     is_canada                      ? "TSX:TSX" :
     is_germany                     ? "XETR:DAX" :
     is_france                      ? "TVC:CAC40" :
     is_netherlands                 ? "EURONEXT:AEX" :
     is_spain                       ? "TVC:IBEX35" :
     is_italy                       ? "TVC:FTMIB" :
     is_switzerland                 ? "TVC:SMI" :
     is_uk                          ? "TVC:UKX" :
     is_sweden                      ? "OMXSTO:OMXS30" :
     is_denmark                     ? "OMXCOP:OMXC25" :
     is_norway                      ? "OSE:OBX" :
     is_finland                     ? "OMXHEX:OMXH25" :
     is_japan                       ? "TVC:NI225" :
     is_korea                       ? "TVC:KOSPI" :
     is_china                       ? "TVC:SHCOMP" :
     is_hongkong                    ? "HSI:HSI" :
     is_taiwan                      ? "TWSE:TAIEX" :
     is_india                       ? "NSE:NIFTY" :
     is_australia                   ? "ASX:XJO" :
     is_singapore                   ? "SGX:STI" :
     is_brazil                      ? "BMFBOVESPA:IBOV" :
     is_mexico                      ? "BMV:ME" :
     is_south_africa                ? "JSE:J200" :
     mode_etf                       ? "ACWI" :
     mode_equity                    ? "ACWI" :
     na

string auto_bench_fallback =
     mode_crypto and not is_bitcoin ? "BTCUSD" :
     mode_fx or mode_commodity      ? na :
     mode_bond                      ? "TVC:US10Y" :
     is_us                          ? "AMEX:SPY" :
     mode_etf                       ? "AMEX:ACWI" :
     mode_equity                    ? "AMEX:ACWI" :
     na

string bench_candidate = bench_mode == S_MANUELL ? str.tostring(bench_manual) : auto_bench_primary

float d_bench_primary =
     not na(bench_candidate) ?
     request.security(bench_candidate, "D", close, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off, ignore_invalid_symbol=true) :
     na

float d_bench_fallback =
     not na(auto_bench_fallback) and na(d_bench_primary) and bench_mode == S_AUTO ?
     request.security(auto_bench_fallback, "D", close, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off, ignore_invalid_symbol=true) :
     na

string bench_use =
     bench_mode == S_MANUELL ? str.tostring(bench_manual) :
     not na(d_bench_primary) ? bench_candidate :
     not na(d_bench_fallback) ? auto_bench_fallback :
     na

d_bench := not na(d_bench_primary) ? d_bench_primary : d_bench_fallback

// === HISTORIE ===============================================================
bool hist_252 = f_has_hist(d_close, 252)
bool hist_200 = f_has_hist(d_close, 200)
bool hist_126 = f_has_hist(d_close, 126)
bool hist_63  = f_has_hist(d_close, 63)

bool hist_meets_full =
     min_hist_bars >= 252 ? hist_252 and hist_200 :
     min_hist_bars >= 200 ? hist_200 :
     min_hist_bars >= 126 ? hist_126 :
     hist_63

bool hist_meets_min =
     min_hist_bars >= 252 ? hist_126 and hist_63 :
     min_hist_bars >= 200 ? hist_126 and hist_63 :
     min_hist_bars >= 126 ? hist_63 :
     true

bool hist_ok_full = hist_meets_full
bool hist_ok_min  = hist_meets_min

float hist_score = hist_ok_full ? 1.0 : hist_ok_min ? 0.6 : 0.2
string hist_txt = hist_ok_full ? S_HIST_FULL : hist_ok_min ? S_HIST_LIMITED : S_HIST_SHORT

// === MARKT-REGIME ===========================================================
bench_exists   = not na(d_bench)
bench_sma200   = ta.sma(d_bench, 200)
bench_regime_ok = bench_exists and not na(bench_sma200)

bench_valid = bench_exists
bull_market = bench_regime_ok and d_bench > bench_sma200

// === FAKTOR 1: RELATIVE STAERKE =============================================
ar_12_1 = hist_252 and nz(d_close[252]) != 0 ? (d_close[21] / d_close[252] - 1) * 100 : na
br_12_1 = use_bench_rs and bench_exists and hist_252 and nz(d_bench[252]) != 0 ? (d_bench[21] / d_bench[252] - 1) * 100 : na
ex_12_1 = use_bench_rs ? (not na(ar_12_1) and not na(br_12_1) ? ar_12_1 - br_12_1 : na) : ar_12_1

ar_6m   = hist_126 and nz(d_close[126]) != 0 ? (d_close / d_close[126] - 1) * 100 : na
br_6m   = use_bench_rs and bench_exists and hist_126 and nz(d_bench[126]) != 0 ? (d_bench / d_bench[126] - 1) * 100 : na
ex_6m   = use_bench_rs ? (not na(ar_6m) and not na(br_6m) ? ar_6m - br_6m : na) : ar_6m

ar_3m   = hist_63 and nz(d_close[63]) != 0 ? (d_close / d_close[63] - 1) * 100 : na
br_3m   = use_bench_rs and bench_exists and hist_63 and nz(d_bench[63]) != 0 ? (d_bench / d_bench[63] - 1) * 100 : na
ex_3m   = use_bench_rs ? (not na(ar_3m) and not na(br_3m) ? ar_3m - br_3m : na) : ar_3m

hh_252d   = ta.highest(d_close, 252)
dist_52wh = hist_252 and nz(hh_252d) != 0 ? d_close / hh_252d : na
rs_line = use_bench_rs ? (bench_exists and nz(d_bench) != 0 ? d_close / d_bench : na) : d_close
rs_slope  = not na(rs_line) and not na(rs_line[50]) and nz(rs_line[50]) != 0 ? (rs_line - rs_line[50]) / rs_line[50] * 100 : na

pr_12_1_raw   = ta.percentrank(ex_12_1, 252)
pr_6m_raw     = ta.percentrank(ex_6m, 252)
pr_3m_raw     = ta.percentrank(ex_3m, 252)
pr_dist_raw   = ta.percentrank(dist_52wh, 252)
pr_rslope_raw = ta.percentrank(rs_slope, 252)

pr_12_1   = na(ex_12_1)   ? na : pr_12_1_raw / 100
pr_6m     = na(ex_6m)     ? na : pr_6m_raw / 100
pr_3m     = na(ex_3m)     ? na : pr_3m_raw / 100
pr_dist   = na(dist_52wh) ? na : pr_dist_raw / 100
pr_rslope = na(rs_slope)  ? na : pr_rslope_raw / 100

rs_cov_n = (na(pr_12_1)?0:1) + (na(pr_6m)?0:1) + (na(pr_3m)?0:1) + (na(pr_dist)?0:1) + (na(pr_rslope)?0:1)
rs_cov   = rs_cov_n / 5.0

float rs_score_raw = rs_cov_n > 0 ? clamp01(
     (na(pr_12_1)?0:0.40*pr_12_1) +
     (na(pr_6m)?0:0.20*pr_6m) +
     (na(pr_3m)?0:0.15*pr_3m) +
     (na(pr_dist)?0:0.15*pr_dist) +
     (na(pr_rslope)?0:0.10*pr_rslope)
     ) / ((na(pr_12_1)?0:0.40)+(na(pr_6m)?0:0.20)+(na(pr_3m)?0:0.15)+(na(pr_dist)?0:0.15)+(na(pr_rslope)?0:0.10)) : na

float rs_score_smooth = ta.ema(rs_score_raw, 5)
rs_score = mode_index ? rs_score_smooth : rs_score_raw

// === FAKTOR 2: GEWINN-QUALITAET =============================================
eps_growth_yoy = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC_ONE_YEAR_GROWTH", "FQ", ignore_invalid_symbol=true)
rev_growth_fq  = request.financial(syminfo.tickerid, "TOTAL_REVENUE_ONE_YEAR_GROWTH", "FQ", ignore_invalid_symbol=true)
rev_growth_ttm = request.financial(syminfo.tickerid, "TOTAL_REVENUE_ONE_YEAR_GROWTH", "TTM", ignore_invalid_symbol=true)
rev_growth_yoy = not na(rev_growth_fq) ? rev_growth_fq : not na(rev_growth_ttm) ? rev_growth_ttm : na

roe_ttm    = request.financial(syminfo.tickerid, "RETURN_ON_EQUITY", "TTM", ignore_invalid_symbol=true)
roe_fy     = request.financial(syminfo.tickerid, "RETURN_ON_EQUITY", "FY", ignore_invalid_symbol=true)
ni_ttm     = request.financial(syminfo.tickerid, "NET_INCOME", "TTM", ignore_invalid_symbol=true)
eq_fq      = request.financial(syminfo.tickerid, "TOTAL_EQUITY", "FQ", ignore_invalid_symbol=true)
roe_calc   = not na(ni_ttm) and not na(eq_fq) and eq_fq > 0 ? ni_ttm / eq_fq * 100 : na
roe_raw    = not na(roe_ttm) ? roe_ttm : not na(roe_fy) ? roe_fy : roe_calc
roe_capped = winsor(roe_raw, -50, 50)

total_debt = request.financial(syminfo.tickerid, "TOTAL_DEBT", "FQ", ignore_invalid_symbol=true)
total_eq   = request.financial(syminfo.tickerid, "TOTAL_EQUITY", "FQ", ignore_invalid_symbol=true)
de_ratio   = not na(total_debt) and not na(total_eq) and total_eq > 0 ? total_debt / total_eq : na

fcf_ttm   = request.financial(syminfo.tickerid, "FREE_CASH_FLOW", "TTM", ignore_invalid_symbol=true)
shares    = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol=true)
mcap_now  = not na(shares) and shares > 0 ? close * shares : na
fcf_yield = not na(fcf_ttm) and not na(mcap_now) and mcap_now > 0 ? fcf_ttm / mcap_now * 100 : na

pe_ratio    = request.financial(syminfo.tickerid, "PRICE_EARNINGS", "FQ", ignore_invalid_symbol=true)
peg_extreme = not na(eps_growth_yoy) and math.abs(eps_growth_yoy) > 100
peg_raw     = not na(pe_ratio) and not na(eps_growth_yoy) and eps_growth_yoy != 0 ? pe_ratio / eps_growth_yoy : na
peg_ratio   = peg_extreme ? na : peg_raw

eps_w = winsor(eps_growth_yoy, -50, 75)
rev_w = winsor(rev_growth_yoy, -30, 50)
eps_score = na(eps_w)      ? na : clamp01((eps_w + 50) / 125)
rev_score = na(rev_w)      ? na : clamp01((rev_w + 30) / 80)
roe_score = na(roe_capped) ? na : clamp01(roe_capped / 30)

earn_cov_n  = (na(eps_score)?0:1) + (na(rev_score)?0:1) + (na(roe_score)?0:1)
earn_cov    = earn_cov_n / 3.0
earn_sum_w  = (na(eps_score)?0:0.50) + (na(rev_score)?0:0.30) + (na(roe_score)?0:0.20)
earn_sum    = (na(eps_score)?0:0.50*eps_score) + (na(rev_score)?0:0.30*rev_score) + (na(roe_score)?0:0.20*roe_score)
earn_available_raw = earn_sum_w > 0
earn_available = mode_equity and earn_available_raw
earn_score = earn_available ? earn_sum / earn_sum_w : na

// === EARNINGS IN X TAGEN ====================================================
next_earn_ts = request.financial(syminfo.tickerid, "EARNINGS_RELEASE_NEXT_DATE", "FQ", ignore_invalid_symbol=true)
days_to_earn = not na(next_earn_ts) ? math.floor((next_earn_ts - time) / 86400000) : na

is_earn_soon   = mode_equity and not na(days_to_earn) and days_to_earn >= 0 and days_to_earn < 5
is_earn_window = mode_equity and not na(days_to_earn) and days_to_earn >= 0 and days_to_earn < 14

bgcolor(is_earn_soon   ? color.new(color.orange, 85) : na, title=PLOT_EARN_SOON)
bgcolor(is_earn_window ? color.new(color.yellow, 93) : na, title=PLOT_EARN_WINDOW)

// === FAKTOR 3: TREND-QUALITAET ==============================================
sma50d   = ta.sma(d_close, 50)
sma200d  = ta.sma(d_close, 200)
above200 = not na(sma200d) and d_close > sma200d
golden   = not na(sma50d) and not na(sma200d) and sma50d > sma200d
hh_60d   = ta.highest(d_close, 60)
dd_60d   = nz(hh_60d) != 0 ? (d_close / hh_60d - 1) * 100 : na

atr_pct   = nz(d_close) != 0 and not na(d_atr) ? d_atr / d_close * 100 : na
dd_thresh = not na(atr_pct) ? math.min(max_dd60d_pct, -2.5 * atr_pct) : max_dd60d_pct
dd_ok     = not na(dd_60d) and dd_60d >= dd_thresh

trend_cov_n = (not na(sma200d)?1:0) + (not na(sma50d) and not na(sma200d)?1:0) + (not na(hh_60d)?1:0)
trend_cov   = trend_cov_n / 3.0

dist_sma200_pct = not na(sma200d) and sma200d != 0 ? (d_close / sma200d - 1) * 100 : na
ma_spread_pct   = not na(sma50d) and not na(sma200d) and sma200d != 0 ? (sma50d / sma200d - 1) * 100 : na

trend_above_score  = na(dist_sma200_pct) ? na : clamp01((dist_sma200_pct + 10.0) / 20.0)
trend_golden_score = na(ma_spread_pct)   ? na : clamp01((ma_spread_pct + 5.0) / 10.0)
trend_dd_score     = na(dd_60d) or na(dd_thresh) ? na : clamp01((dd_60d - dd_thresh) / math.max(math.abs(dd_thresh), 0.01))

trend_sum_w =
     (na(trend_above_score)  ? 0 : 0.40) +
     (na(trend_golden_score) ? 0 : 0.30) +
     (na(trend_dd_score)     ? 0 : 0.30)

trend_sum =
     (na(trend_above_score)  ? 0 : 0.40 * trend_above_score) +
     (na(trend_golden_score) ? 0 : 0.30 * trend_golden_score) +
     (na(trend_dd_score)     ? 0 : 0.30 * trend_dd_score)

trend_score = trend_sum_w > 0 ? clamp01(trend_sum / trend_sum_w) : na

// === SICHERHEITS-FILTER =====================================================
avg_vol_usd = ta.sma(d_close * d_volume, 20)

bool vol_valid_equity = not na(avg_vol_usd) and avg_vol_usd >= min_avg_vol_usd
bool vol_valid_etf    = not na(avg_vol_usd) and avg_vol_usd >= min_avg_vol_usd

bool filter_pass_equity = vol_valid_equity and dd_ok and above200
bool filter_pass_etf    = (dd_ok and above200) and (not has_volume or vol_valid_etf)
bool filter_pass_bond   = dd_ok and above200
bool filter_pass_index  = dd_ok and above200
bool filter_pass_other  = dd_ok and above200

bool filter_pass =
     mode_equity ? filter_pass_equity :
     mode_etf    ? filter_pass_etf :
     mode_bond   ? filter_pass_bond :
     mode_index  ? filter_pass_index :
     filter_pass_other

// === COVERAGE / CONFIDENCE ==================================================
float cov_rs    = rs_cov
float cov_earn  = mode_equity ? earn_cov : na
float cov_trend = trend_cov

float coverage_total =
     mode_equity ? cov_rs * 0.45 + nz(cov_earn) * 0.35 + cov_trend * 0.20 :
     mode_etf    ? cov_rs * 0.65 + cov_trend * 0.35 :
     mode_bond   ? cov_rs * 0.65 + cov_trend * 0.35 :
     mode_index  ? cov_rs * 0.65 + cov_trend * 0.35 :
     cov_rs * 0.65 + cov_trend * 0.35

float confidence = clamp01(0.50 * coverage_total + 0.50 * hist_score)

bool rs_has_min_data   = not na(rs_score) and cov_rs >= 0.40
bool bench_is_required = mode_equity or mode_etf or mode_index or mode_bond or (mode_crypto and not is_bitcoin)
bool bench_is_usable   = use_bench_rs ? bench_exists : true
bool can_use_rs        = rs_has_min_data and (not use_bench_rs or bench_is_usable)

bool can_use_earn  = mode_equity and earn_available
bool can_use_trend = trend_cov > 0

// === GESAMT-SCORE ===========================================================
float eff_w_rs    = can_use_rs ? w_rs : 0.0
float eff_w_earn  = can_use_earn ? w_earn : 0.0
float eff_w_trend = can_use_trend ? w_trend : 0.0

if not mode_equity
    eff_w_earn := 0.0

float w_sum      = eff_w_rs + eff_w_earn + eff_w_trend
float rs_part    = can_use_rs ? rs_score : 0.0
float earn_part  = can_use_earn ? earn_score : 0.0
float trend_part = can_use_trend ? trend_score : 0.0

float master_raw = w_sum > 0 ? clamp01((eff_w_rs*rs_part + eff_w_earn*earn_part + eff_w_trend*trend_part) / w_sum) : na
float master_smooth = ta.ema(master_raw, 3)
float master        = mode_index ? master_smooth : master_raw

// === GATES ==================================================================
bool gate_hist       = hist_ok_full
bool gate_cov_buy    = coverage_total >= min_cov_buy
bool gate_cov_watch  = coverage_total >= min_cov_watch
bool gate_bench      = bench_is_required ? (strict_bench ? bench_exists : true) : true
bool gate_conf       = confidence >= min_cov_buy
bool gate_conf_watch = confidence >= min_cov_watch

bool gate_strong_rs    = can_use_rs and rs_score >= 0.75
bool gate_strong_trend = can_use_trend and trend_score >= 0.70
bool gate_strong_conf  = confidence >= math.max(min_cov_buy, 0.80)
bool gate_strong_cov   = coverage_total >= math.max(min_cov_buy, 0.80)
bool gate_strong_dd    = dd_60d >= math.max(dd_thresh, -12.0)
bool gate_strong_earn  = not mode_equity or (can_use_earn and earn_score >= 0.60)

bool buy_gate_good =
     gate_hist and
     gate_cov_buy and
     gate_bench and
     gate_conf and
     (not use_filter or filter_pass)

bool buy_gate_strong =
     buy_gate_good and
     gate_strong_rs and
     gate_strong_trend and
     gate_strong_conf and
     gate_strong_cov and
     gate_strong_dd and
     gate_strong_earn

bool watch_gate =
     gate_cov_watch and
     hist_ok_min and
     gate_conf_watch and
     gate_bench

// === BERECHNUNGEN VOR DEN PLOTS =============================================
score_mom_raw = not na(master) and not na(master[20]) ? master - master[20] : na
score_mom     = ta.sma(score_mom_raw, 3)

bool score_above_A_2bars = master >= thr_A and master[1] >= thr_A
bool score_above_S_2bars = master >= thr_S and master[1] >= thr_S
bool score_rising_3bars  = not na(master) and not na(master[3]) and master > master[3]

// Vorberechnete Hochs für Konsistenz
float price_high_20_prev  = ta.highest(d_close, 20)[1]
float price_high_60_prev  = ta.highest(d_close, 60)[1]
float master_high_20_prev = ta.highest(master, 20)[1]

bool new_price_high_20 = not na(price_high_20_prev) and d_close >= price_high_20_prev
bool new_price_high_60 = not na(price_high_60_prev) and d_close >= price_high_60_prev

bool good_confirm =
     buy_gate_good and
     score_above_A_2bars

bool strong_confirm =
     buy_gate_strong and
     score_above_S_2bars and
     score_rising_3bars and
     score_mom > 0 and
     new_price_high_20

bool score_falling_short = not na(master) and not na(master[3]) and master <= master[3]
bool score_not_confirming_high = not na(master) and not na(master_high_20_prev) and master < master_high_20_prev

divergence_warn =
     hist_ok_min and
     gate_cov_watch and
     new_price_high_20 and
     score_not_confirming_high and
     score_falling_short

// === PLOTS ==================================================================
color master_col = score_col(master)

plot(master, tt_rib_master, color=master_col, linewidth=3)
plot(rs_score, tt_rib_rs, color=color.new(color.blue, 20))
plot(mode_equity and earn_available ? earn_score : na, tt_rib_earn, color=color.new(color.orange, 20))
plot(score_mom, tt_rib_mom, color=color.new(color.white, 20))

// === SIGNALE ================================================================
buy_sig =
     good_confirm and
     not good_confirm[1] and
     not strong_confirm

strong_buy_sig =
     strong_confirm and
     not strong_confirm[1]

exit_sig =
     master < thr_A and
     master[1] >= thr_A and
     hist_ok_min and
     gate_cov_watch

plotshape(buy_sig,         SIG_BUY,        shape.arrowup,      location.bottom, color.new(col_green, 0),  size=size.small,  display=display.pane)
plotshape(exit_sig,        SIG_EXIT,       shape.arrowdown,    location.top,    color.new(col_red, 0),    size=size.small,  display=display.pane)
plotshape(strong_buy_sig,  SIG_BUY_STRONG, shape.arrowup,      location.bottom, color.new(col_green, 0),  size=size.normal, display=display.pane)
plotshape(divergence_warn, SIG_DIVERGENZ,  shape.triangledown, location.top,    color.new(color.orange, 0), size=size.tiny, display=display.pane)

// === EMPFEHLUNG =============================================================
string tier_txt   = S_REC_AVOID
string action_txt = S_ACT_AVOID
color tier_col    = color.new(#D50000, 0)

if strong_confirm
    tier_txt   := S_REC_BUY_STRONG
    action_txt := S_ACT_BUY_STRONG
    tier_col   := color.new(#00C853, 0)
else if good_confirm
    tier_txt   := S_REC_BUY_GOOD
    action_txt := S_ACT_BUY_GOOD
    tier_col   := color.new(#64DD17, 0)
else if master >= thr_B and watch_gate
    tier_txt   := S_REC_WATCH
    action_txt := S_ACT_WATCH
    tier_col   := color.new(#FFD600, 0)
else if coverage_total < min_cov_watch or not hist_ok_min
    tier_txt   := S_REC_WEAK_DATA
    action_txt := S_ACT_WEAK_DATA
    tier_col   := color.new(#FF6D00, 0)
else if master >= thr_F
    tier_txt   := S_REC_NEUTRAL
    action_txt := S_ACT_NEUTRAL
    tier_col   := color.new(#FF6D00, 0)

// === SCHWELLEN-LINIEN =======================================================
hS = hline(thr_S, HLINE_STRONG, color=color.new(color.green, 30), linestyle=hline.style_dashed, linewidth=2)
hA = hline(thr_A, HLINE_GOOD,   color=color.new(color.green, 50), linestyle=hline.style_dashed)
hB = hline(thr_B, HLINE_WATCH,  color=color.new(color.yellow, 50), linestyle=hline.style_dotted)
hF = hline(thr_F, HLINE_FAIL,   color=color.new(color.red, 50), linestyle=hline.style_dashed)
hZ = hline(0,     S_EMPTY,      color=color.new(color.red, 100), linestyle=hline.style_dotted)
fill(hA, hS, color=color.new(color.green, 90))
fill(hF, hZ, color=color.new(color.red, 93))

// === HINTERGRUND ============================================================
bgcolor(show_bg ? color.new(tier_col, 92) : not bench_regime_ok ? na : bull_market ? color.new(color.green, 97) : color.new(color.red, 94), title=PLOT_BG_MARKET)

// === ANZEIGEVARIABLEN =======================================================
string peg_txt = na(peg_ratio) ? "–" : f_mult(peg_ratio)
color  peg_bg  = na(peg_ratio) ? col_none : col_peg(peg_ratio)

string fcf_txt = f_pct(fcf_yield)
color  fcf_bg  = na(fcf_yield) ? col_none : col_fcf(fcf_yield)

// === EARNINGS-ANZEIGE =======================================================
string earn_txt = S_NA
color earn_bg   = col_none

if mode_equity and not na(days_to_earn)
    if days_to_earn < 0
        earn_txt := S_EARN_RECENT
        earn_bg  := color.new(#3A3D44, 0)
    else if days_to_earn == 0
        earn_txt := S_EARN_TODAY
        earn_bg  := col_red
    else if days_to_earn <= 9
        earn_txt := S_IN_PREFIX + str.tostring(days_to_earn) + S_IN_SUFFIX
        earn_bg  := col_orange
    else if days_to_earn <= 30
        earn_txt := S_IN_PREFIX + str.tostring(days_to_earn) + S_IN_SUFFIX
        earn_bg  := bg_value
    else
        earn_txt := S_IN_PREFIX + str.tostring(days_to_earn) + S_IN_SUFFIX
        earn_bg  := col_green

string trend_txt =
     (above200 ? S_CHECK : S_CROSS) + S_TREND_SMA200 +
     (golden   ? S_CHECK : S_CROSS) + S_TREND_GC +
     (dd_ok    ? S_CHECK : S_CROSS) + S_TREND_DD

string vol_unit = avg_vol_usd >= 1e12 ? S_VOL_BIO : avg_vol_usd >= 1e9 ? S_VOL_MRD : S_VOL_MIO
vol_div  = avg_vol_usd >= 1e12 ? 1e12 : avg_vol_usd >= 1e9 ? 1e9 : 1e6
vol_txt  = na(avg_vol_usd) ? S_DASH : str.tostring(avg_vol_usd / vol_div, "0.00") + " " + vol_unit
vol_bg   = mode_equity ? (na(avg_vol_usd) or avg_vol_usd < min_avg_vol_usd ? col_red : bg_value) : bg_value

string cov_txt = str.tostring(coverage_total, "0.00") + " / " + str.tostring(confidence, "0.00")
color cov_bg = confidence >= min_cov_buy ? col_green : confidence >= min_cov_watch ? col_yellow : col_orange

// === MODUS-SPEZIFISCHE TABELLENANZEIGE ======================================
string na_mode_txt = S_DASH
color  na_mode_bg  = col_none

string sector_display =
     mode_equity ? (na(syminfo.sector) or syminfo.sector == "" ? S_DASH : str.upper(syminfo.sector)) :
     mode_bond   ? MODE_SECTOR_BOND :
     mode_etf    ? MODE_SECTOR_ETF :
     asset_mode == S_MODE_FOREX    ? MODE_SECTOR_FOREX :
     asset_mode == S_MODE_KRYPTO   ? MODE_SECTOR_KRYPTO :
     asset_mode == S_MODE_ROHSTOFF ? MODE_SECTOR_ROHSTOFF :
     mode_other  ? MODE_SECTOR_OTHER :
     S_DASH

string industry_display =
     mode_equity ? (na(syminfo.industry) or syminfo.industry == "" ? S_DASH : str.upper(syminfo.industry)) :
     mode_bond   ? MODE_INDUSTRY_BOND :
     mode_etf    ? MODE_INDUSTRY_ETF :
     asset_mode == S_MODE_FOREX    ? MODE_INDUSTRY_FOREX :
     asset_mode == S_MODE_KRYPTO   ? MODE_INDUSTRY_KRYPTO :
     asset_mode == S_MODE_ROHSTOFF ? MODE_INDUSTRY_ROHSTOFF :
     mode_other  ? MODE_INDUSTRY_OTHER :
     S_DASH

string earn_score_display = mode_equity and can_use_earn ? str.tostring(earn_score, "0.00") : na_mode_txt
color  earn_score_bg      = mode_equity and can_use_earn ? score_col(earn_score) : na_mode_bg
string eps_txt = f_pct(eps_growth_yoy)
color  eps_bg  = na(eps_growth_yoy) ? col_none : col_eps(eps_growth_yoy)

string rev_txt = f_pct(rev_growth_yoy)
color  rev_bg  = na(rev_growth_yoy) ? col_none : col_rev(rev_growth_yoy)

string roe_txt = f_roe(roe_raw)
color  roe_bg  = na(roe_raw) ? col_none : col_roe(roe_raw)

string de_txt = f_de(de_ratio)
color  de_bg  = na(de_ratio) ? col_none : col_de(de_ratio)

string eps_txt_display = mode_equity ? eps_txt : na_mode_txt
color  eps_bg_display  = mode_equity ? eps_bg  : na_mode_bg

string rev_txt_display = mode_equity ? rev_txt : na_mode_txt
color  rev_bg_display  = mode_equity ? rev_bg  : na_mode_bg

string roe_txt_display = mode_equity ? roe_txt : na_mode_txt
color  roe_bg_display  = mode_equity ? roe_bg  : na_mode_bg

string de_txt_display = mode_equity ? de_txt : na_mode_txt
color  de_bg_display  = mode_equity ? de_bg  : na_mode_bg

string fcf_txt_display = mode_equity ? fcf_txt : na_mode_txt
color  fcf_bg_display  = mode_equity ? fcf_bg  : na_mode_bg

string peg_txt_display = mode_equity ? peg_txt : na_mode_txt
color  peg_bg_display  = mode_equity ? peg_bg  : na_mode_bg

string bench_display = bench_exists and not na(bench_use) ? str.tostring(bench_use) : S_DASH
color  bench_bg      = bench_exists and not na(bench_use) ? bg_value : na_mode_bg

string vol_label =
     mode_equity ? ROW_VOL_EQUITY :
     mode_etf    ? ROW_VOL_ETF :
     mode_bond   ? ROW_VOL_BOND :
     mode_index  ? ROW_VOL_INDEX :
                   ROW_VOL_OTHER

string vol_txt_display =
     (mode_index and na(avg_vol_usd)) ? S_DASH :
     na(avg_vol_usd) ? S_DASH :
     str.tostring(avg_vol_usd / vol_div, "0.00") + S_SPACE + vol_unit

color vol_bg_display =
     mode_equity ? vol_bg :
     mode_etf    ? vol_bg :
     mode_index  ? na_mode_bg :
                   na_mode_bg

string filter_txt = filter_pass ? S_FILTER_PASS : S_FILTER_FAIL
color  filter_bg  = filter_pass ? col_green : col_red

if mode_index or mode_fx or mode_commodity
    filter_txt := filter_pass ? S_FILTER_TREND_OK : S_FILTER_TREND_WEAK
    filter_bg  := filter_pass ? col_green : col_red
else if not bench_exists and strict_bench and bench_is_required
    filter_txt := S_FILTER_BENCH_MISSING
    filter_bg  := col_orange

string earn_row_txt = earn_txt
color  earn_row_bg  = earn_bg

bool use_market_regime = mode_equity or mode_etf or mode_index

string market_regime_txt =
     not use_market_regime ? S_DASH :
     not bench_regime_ok   ? S_DASH :
     bull_market           ? S_MARKET_POSITIVE :
                             S_MARKET_WEAK

color market_regime_bg =
     not use_market_regime ? col_none :
     not bench_regime_ok   ? col_none :
     bull_market           ? col_green :
                             col_red

// === TABELLEN-SETUP =========================================================
tbl_position = switch table_pos
    S_TOPRIGHT    => position.top_right
    S_MIDDLERIGHT => position.middle_right
    S_BOTTOMRIGHT => position.bottom_right
    S_TOPLEFT     => position.top_left
    S_MIDDLELEFT  => position.middle_left
    => position.bottom_left

tbl_size = switch table_sz
    S_TINY   => size.tiny
    S_SMALL  => size.small
    S_NORMAL => size.normal
    => size.large

var table tbl = table.new(position.top_right, 2, 25, border_width=1, border_color=#2A2D33)

if barstate.isfirst
    table.set_position(tbl, tbl_position)
else if barstate.islast
    table.set_position(tbl, tbl_position)

string row_earnings_label =
     mode_equity ? ROW_EARNINGS_EQUITY : ROW_EARNINGS_GENERIC

string row_earn_label =
     mode_equity ? ROW_EARN_EQUITY : ROW_EARN_GENERIC

string row_eps_label =
     mode_equity ? ROW_EPS_EQUITY : ROW_EPS_GENERIC

string row_rev_label =
     mode_equity ? ROW_REV_EQUITY : ROW_REV_GENERIC

string row_roe_label =
     mode_equity ? ROW_ROE_EQUITY : ROW_ROE_GENERIC

string row_de_label =
     mode_equity ? ROW_DE_EQUITY : ROW_DE_GENERIC

string row_fcf_label = ROW_FCF
string row_peg_label = ROW_PEG

if barstate.islast
    table.cell(tbl, 0, 0,  ROW_SEKTOR, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 0,  sector_display, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, tooltip=tt_sektor)

    table.cell(tbl, 0, 1,  ROW_INDUSTRIE, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 1,  industry_display, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, tooltip=tt_industrie)

    table.cell(tbl, 0, 2,  ROW_MODUS, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 2,  asset_mode, bgcolor=bg_value, text_color=txt_main, text_size=tbl_size, tooltip=tt_mode)

    table.cell(tbl, 0, 3,  ROW_HISTORIE, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 3,  hist_txt, bgcolor=score_col(hist_score), text_color=txt_main, text_size=tbl_size, tooltip=tt_hist)

    table.cell(tbl, 0, 4,  ROW_COVERAGE, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 4,  cov_txt, bgcolor=cov_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_cov)

    table.cell(tbl, 0, 5,  row_earnings_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 5,  earn_row_txt, bgcolor=earn_row_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_earn_days)

    table.cell(tbl, 0, 6,  ROW_GESAMT, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 6,  na(master) ? S_NA : str.tostring(master, "0.00"), bgcolor=score_col(master), text_color=txt_main, text_size=tbl_size, tooltip=tt_master)

    table.cell(tbl, 0, 7,  ROW_RS, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 7,  can_use_rs ? str.tostring(rs_score, "0.00") : S_NA, bgcolor=can_use_rs ? score_col(rs_score) : na_mode_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_rs)

    table.cell(tbl, 0, 8,  ROW_TREND, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 8,  trend_txt, bgcolor=score_col(trend_score), text_color=txt_main, text_size=tbl_size, tooltip=tt_trend)

    table.cell(tbl, 0, 9,  ROW_DIST_ATH, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 9,  f_dist(dist_52wh), bgcolor=col_dist(dist_52wh), text_color=txt_main, text_size=tbl_size, tooltip=tt_dist)

    table.cell(tbl, 0, 10, row_earn_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 10, earn_score_display, bgcolor=earn_score_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_earn)

    table.cell(tbl, 0, 11, row_eps_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 11, eps_txt_display, bgcolor=eps_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_eps)

    table.cell(tbl, 0, 12, row_rev_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 12, rev_txt_display, bgcolor=rev_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_rev)

    table.cell(tbl, 0, 13, row_roe_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 13, roe_txt_display, bgcolor=roe_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_roe)

    table.cell(tbl, 0, 14, row_de_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 14, de_txt_display, bgcolor=de_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_de)

    table.cell(tbl, 0, 15, row_fcf_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 15, fcf_txt_display, bgcolor=fcf_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_fcf)

    table.cell(tbl, 0, 16, row_peg_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 16, peg_txt_display, bgcolor=peg_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_peg)

    table.cell(tbl, 0, 17, vol_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 17, vol_txt_display, bgcolor=vol_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_vol)

    table.cell(tbl, 0, 18, ROW_BENCHMARK, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 18, bench_display, bgcolor=bench_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_bench)

    table.cell(tbl, 0, 19, ROW_MARKTREGIME, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 19, market_regime_txt, bgcolor=market_regime_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_markt_regime)

    table.cell(tbl, 0, 20, ROW_FILTER, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 20, filter_txt, bgcolor=filter_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_filter_row)

    table.cell(tbl, 0, 21, ROW_EMPFEHLUNG, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 21, tier_txt, bgcolor=tier_col, text_color=txt_main, text_size=tbl_size, tooltip=tt_empfehlung)

    table.cell(tbl, 0, 22, ROW_ACTION, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 22, action_txt, bgcolor=bg_value, text_color=txt_main, text_size=tbl_size, tooltip=tt_action)

    table.cell(tbl, 0, 23, ROW_KURVEN, bgcolor=col_info, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 23, ROW_KURVEN_VALUES, bgcolor=col_info, text_color=txt_main, text_size=tbl_size, tooltip=tt_chart)

    table.cell(tbl, 0, 24, ROW_SIGNALE, bgcolor=col_info, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 24, ROW_SIGNALE_VALUES, bgcolor=col_info, text_color=txt_main, text_size=tbl_size, tooltip=tt_chart)

// === CHART-LEGENDE ==========================================================
var table legend = table.new(
     position.bottom_left, 1, 7,
     bgcolor=color.new(color.black, 12),
     border_color=color.new(color.gray, 40), border_width=1,
     frame_color=color.new(color.gray, 40), frame_width=1)

if barstate.islast
    if show_legend
        table.cell(legend, 0, 0, LEGEND_TITLE, text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color.blue, 70))
        table.cell(legend, 0, 1, LEGEND_1, text_color=color.yellow, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 2, LEGEND_2, text_color=color.blue, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 3, LEGEND_3, text_color=color.orange, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 4, LEGEND_4, text_color=color.white, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 5, LEGEND_5, text_color=color.lime, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 6, LEGEND_6, text_color=color.orange, text_size=size.small, text_halign=text.align_left)
    else
        for r = 0 to 6
            table.cell(legend, 0, r, S_EMPTY, text_color=color.new(color.white, 100), bgcolor=color.new(color.black, 100))

// === ALERTS =================================================================
alertcondition(strong_buy_sig, ALERT_TITLE_STRONG_BUY, ALERT_MSG_STRONG_BUY)
alertcondition(buy_sig,        ALERT_TITLE_GOOD_BUY,   ALERT_MSG_GOOD_BUY)
alertcondition(ta.crossunder(master, thr_F), ALERT_TITLE_SELL, ALERT_MSG_SELL)
````
