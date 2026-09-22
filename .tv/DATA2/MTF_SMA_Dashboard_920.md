<!-- tradingview-pine-id: PUB;4e7a9c51dacc432abe38f12e73c3f607 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MTF SMA Dashboard (9/20)

Source: https://www.tradingview.com/script/KfGeDm38-MTF-SMA-Dashboard/

## Description

[image]https://www.tradingview.com/x/0YpfQ4eJ/[/image]

Overview
This indicator answers one question at a glance: on which timeframes is the fast SMA above the slow SMA, and on which is it below? It reads the relationship between two simple moving averages (default lengths 9 and 20) on up to seven timeframes and shows the result as a compact table of colored badges directly on the chart. Each badge reads "Bull" when the fast SMA is above the slow SMA and "Bear" when it is below.

The goal is not to introduce a new moving average. The goal is to remove the need to flip through seven charts to check whether the short-term and higher-timeframe trend agree. Two things set the script apart:

[*]A multi-timeframe overlay table that sits on the price chart itself. Seven timeframes are condensed into one small block of badges, with an alignment count, an alignment background tint, alignment alerts and an explicit choice between confirmed and live higher-timeframe data.
[*]Customization down to the single element. Every timeframe slot, every optional row, every color, both text sizes, the grid, the frame, the position and the margin on each edge can be set independently, so the table fits an existing chart layout instead of forcing the layout to fit the table.

What is displayed

[*]One badge pair per timeframe, for example "H4 | Bear". Defaults are D1, H4, H1, M30, M15, M5 and M1. Every timeframe can be changed or switched off individually.
[*]An optional header row showing the SMA lengths in use.
[*]An optional summary badge that counts the majority side across the active timeframes, for example "5/7 Bull".
[*]Optionally the two SMA lines of the chart timeframe.
[*]An optional light background tint on bars where all active timeframes point the same way.

If the two averages are exactly equal, or a timeframe does not yet have enough bars to calculate the slow SMA, the badge shows a neutral dash instead of Bull or Bear.

Built to fit your chart, not the other way round
Dashboard tables often collide with what is already on the chart: the legend at the top, the logo at the bottom left, other indicator tables in the corners. This script treats the layout as a first-class feature.

[*]Nine positions, vertical or horizontal arrangement, and a separate margin for the top, bottom, left and right edge. A margin only takes effect on the edge the table is actually placed on, so the table can be moved clear of the legend or the logo without shifting anything else.
[*]A compact mode merges the timeframe label and the state into a single badge per timeframe, which roughly halves the width of the table.
[*]Timeframe slots that are switched off disappear and the remaining badges close the gap, so the table is never larger than it needs to be. The same applies to the optional header and summary rows.
[*]Background color and text color are independent for Bull, Bear, neutral and the timeframe label. Text color is never derived from the background, so the text stays readable with any opacity setting.
[*]The grid between the badges can follow the chart background, which makes the badges look detached, or take a custom color for a classic table look. The gap width and an optional outer frame are adjustable.
[*]Text sizes are set separately for the timeframe label and the state, and the font can be switched to monospace for evenly aligned columns.
[*]The badge texts are available in English and German, or can be replaced by any custom wording.

How it works
For each timeframe the script requests the state of the two SMAs through request.security() on the chart's own symbol. The state is +1 when SMA(fast) > SMA(slow), -1 when SMA(fast) < SMA(slow) and 0 otherwise. The table is drawn once on the last bar, while the states themselves are calculated on every bar so that the background tint and the alerts work across the whole chart history.

The summary badge counts how many active timeframes are bullish and how many are bearish and displays the larger group. Timeframes that are switched off are excluded from the count, from the tint and from the alerts.

Repainting: please read
The input "Live mode" controls how higher-timeframe data is read, and it changes the behavior of the script materially.

[*]Live mode ON (default): the state of the bar that is still forming on each timeframe is used. The dashboard reacts immediately, but a badge can flip back and forth until the bar of that timeframe closes. On historical bars only confirmed values exist, so the background tint you see in history can differ from what was visible in real time. In this mode the script repaints.
[*]Live mode OFF: the script reads the state of the last completed bar of each timeframe, using the value offset by one bar together with barmerge.lookahead_on. This is the documented pattern for non-repainting higher-timeframe requests. It does not look into the future on historical bars, and in real time a badge changes only when a bar of that timeframe closes. History and real time match. The trade-off is a delay of up to one bar of the respective timeframe.

If you use the alerts or evaluate the tint on past data, switch Live mode off.

How to use it
The dashboard is a context tool. A typical use is to check whether the lower timeframes you trade on agree with the higher-timeframe direction before acting on your own setup, or to be notified when all selected timeframes line up. It does not generate entries, exits, stops or targets, and an SMA relationship alone is not a trading system. Moving averages lag by construction, and in ranging markets the badges will flip frequently.

Alerts
Two alert conditions are available: all active timeframes have turned Bull, and all active timeframes have turned Bear. Each fires on the bar where full alignment is first reached. The alerts can be silenced with a single input. For stable alerts, switch Live mode off and set the alert to trigger once per bar close.

Settings

[*]Display language of the badges: English, German or custom text.
[*]On/off switches: dashboard, header row, summary badge, compact single-badge mode, SMA lines, alignment tint, alerts.
[*]SMA: fast length, slow length, source, Live mode, line colors.
[*]Timeframes: seven slots, each with its own on/off switch and timeframe selector. Badge labels such as H4 or M15 are derived automatically.
[*]Position and margins, grid and frame, font, colors: as described in the layout section above.

The settings are grouped and numbered in the dialog, starting with the display language.

Limitations

[*]Timeframes lower than the chart timeframe are supported, but the badge then shows the state of the last lower-timeframe bar inside the current chart bar. For a consistent reading, use the dashboard on a chart timeframe that is equal to or lower than the lowest active timeframe, or switch the lower slots off.
[*]The script issues two data requests per timeframe slot, fourteen in total with the default configuration.
[*]Timeframes without sufficient history show the neutral dash until the slow SMA can be calculated.
[*]Input labels in the settings dialog are shown in English and German at the same time, because Pine Script does not allow input titles to change at runtime.

This script is provided for informational and educational purposes. It is not financial advice.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  MTF SMA Dashboard  ·  SMA 9 / SMA 20 auf sieben Zeitebenen
//  MTF SMA Dashboard  ·  SMA 9 / SMA 20 on seven timeframes
// ───────────────────────────────────────────────────────────────────────────
//  Zeigt als kompakte "Pillen"-Tabelle, ob auf D1, H4, H1, M30, M15, M5 und M1
//  der schnelle SMA (Standard 9) über dem langsamen SMA (Standard 20) liegt
//  (Bulle, grün) oder darunter (Bär, rot).
//
//  Repainting-Ansatz
//  ─────────────────
//  Live-Modus aus ("Nur geschlossene Kerzen"):
//      request.security(sym, tf, zustand[1], lookahead = barmerge.lookahead_on)
//  → Pro Zeitebene wird der Zustand der LETZTEN ABGESCHLOSSENEN Kerze
//    geliefert. Der [1]-Offset verhindert, dass lookahead_on auf historischen
//    Daten in die Zukunft schaut, und in Echtzeit springt der Wert erst beim
//    Kerzenschluss der jeweiligen Zeitebene um. Historie und Live-Anzeige
//    sind damit identisch (kein Repainting).
//
//  Live-Modus an (Standard):
//      request.security(sym, tf, zustand, lookahead = barmerge.lookahead_off)
//  → Wertet die noch offene Kerze aus. Reagiert schneller, kann aber bis zum
//    Kerzenschluss noch hin- und herspringen.
//
//  Aufbau der Tabelle
//  ──────────────────
//  Die Anzeige besteht aus einer Liste von "Pillen-Paaren" [ Label | Wert ]:
//      optionale Kopfzeile  →  aktive Zeitebenen  →  optionale Zusammenfassung
//  Vertikal wird pro Paar eine Zeile, horizontal pro Paar zwei Spalten belegt.
//  Im Kompakt-Modus verschmelzen Label und Wert zu einer einzigen Pille.
//
//  Sprache
//  ───────
//  Die Pillen-Texte (Bulle/Bär, Kopfzeile) gibt es auf Deutsch und Englisch,
//  dazu "Benutzerdefiniert" mit freien Textfeldern. Die Beschriftungen im
//  Einstellungsdialog sind in Pine Script feste Konstanten und lassen sich
//  nicht per Dropdown umschalten – deshalb sind sie zweisprachig angelegt
//  ("Deutsch / English").
//
//  Ränder
//  ──────
//  Oben links/rechts sitzt die Chart-Legende (Symbol + Indikatornamen), unten
//  links das TradingView-Logo. Deshalb lassen sich pro Kante unsichtbare
//  Abstandszeilen bzw. -spalten einstellen, die nur an der jeweils gewählten
//  Position wirken.
//
//  Hinweis: Liegt eine Zeitebene UNTER der Chart-Zeitebene (z. B. M5 auf
//  einem H1-Chart), liefert request.security den Zustand der letzten
//  M5-Kerze innerhalb der aktuellen Chart-Kerze. Das Dashboard ist daher
//  am aussagekräftigsten auf dem M1-Chart.
// ═══════════════════════════════════════════════════════════════════════════
indicator("MTF SMA Dashboard (9/20)", shorttitle = "MTF SMA 9/20", overlay = true)

// ───────────────────────────────────────────────────────────────────────────
//  1) Inputs  (Beschriftungen zweisprachig: Deutsch / English)
// ───────────────────────────────────────────────────────────────────────────
grpLang = "1 · Sprache / Language"
string langInp = input.string("English", "Sprache der Anzeige / Display language",
     options = ["Deutsch", "English", "Benutzerdefiniert / Custom"], group = grpLang,
     tooltip = "Betrifft die Texte in den Pillen (Bulle/Bär, Kopfzeile). 'Benutzerdefiniert' nutzt die Felder darunter.\n" +
               "Affects the pill texts (Bull/Bear, header). 'Custom' uses the fields below.")
string cusBull    = input.string("Bulle", "Eigener Text Bulle / Custom text Bull",       group = grpLang)
string cusBear    = input.string("Bär",   "Eigener Text Bär / Custom text Bear",         group = grpLang)
string cusTf      = input.string("TF",    "Eigener Text Kopfzeile / Custom header text", group = grpLang)
string txtNeutInp = input.string("–",     "Text neutral / Neutral text",                 group = grpLang)
string txtSumInp  = input.string("Σ",     "Label Zusammenfassung / Summary label",       group = grpLang)

grpOn = "2 · Ein-Aus / On-Off"
bool showDash    = input.bool(true,  "Dashboard anzeigen / Show dashboard",                              group = grpOn)
bool showHeader  = input.bool(true,  "Kopfzeile / Header  [ TF | SMA 9/20 ]",                            group = grpOn)
bool showSummary = input.bool(true,  "Zusammenfassung / Summary  [ Σ | 5/7 ]",                           group = grpOn)
bool compactMode = input.bool(false, "Kompakt (eine Pille) / Compact (single pill)",                     group = grpOn)
bool showSma     = input.bool(true,  "SMA-Linien zeichnen / Plot SMA lines (chart TF)",                  group = grpOn)
bool bgTint      = input.bool(true,  "Hintergrund bei Gleichlauf einfärben / Tint background on alignment", group = grpOn)
bool alertsOn    = input.bool(true,  "Alerts bei Gleichlauf / Alerts on alignment",                      group = grpOn)

grpSma = "3 · SMA"
int    fastLen    = input.int(9,  "Schneller SMA / Fast SMA", minval = 1, group = grpSma)
int    slowLen    = input.int(20, "Langsamer SMA / Slow SMA", minval = 1, group = grpSma)
float  src        = input.source(close, "Quelle / Source", group = grpSma)
bool   liveMode   = input.bool(true,  "Live-Modus (kann repainten) / Live mode (may repaint)", group = grpSma)
color  smaFastCol = input.color(#2962FF, "Linie schneller SMA / Fast SMA line", group = grpSma)
color  smaSlowCol = input.color(#FF0014, "Linie langsamer SMA / Slow SMA line", group = grpSma)

// Pro Zeitebene: Checkbox "An / On" + Zeitebene in einer Zeile.
// Abgeschaltete Ebenen verschwinden aus der Tabelle und zählen nicht
// in Zusammenfassung, Hintergrund-Tönung und Alerts.
grpTf = "4 · Zeitebenen / Timeframes"
bool   en1 = input.bool(true, "An / On", inline = "tf1", group = grpTf)
string tf1 = input.timeframe("D",   "Zeitebene / Timeframe 1", inline = "tf1", group = grpTf)
bool   en2 = input.bool(true, "An / On", inline = "tf2", group = grpTf)
string tf2 = input.timeframe("240", "Zeitebene / Timeframe 2", inline = "tf2", group = grpTf)
bool   en3 = input.bool(true, "An / On", inline = "tf3", group = grpTf)
string tf3 = input.timeframe("60",  "Zeitebene / Timeframe 3", inline = "tf3", group = grpTf)
bool   en4 = input.bool(true, "An / On", inline = "tf4", group = grpTf)
string tf4 = input.timeframe("30",  "Zeitebene / Timeframe 4", inline = "tf4", group = grpTf)
bool   en5 = input.bool(true, "An / On", inline = "tf5", group = grpTf)
string tf5 = input.timeframe("15",  "Zeitebene / Timeframe 5", inline = "tf5", group = grpTf)
bool   en6 = input.bool(true, "An / On", inline = "tf6", group = grpTf)
string tf6 = input.timeframe("5",   "Zeitebene / Timeframe 6", inline = "tf6", group = grpTf)
bool   en7 = input.bool(true, "An / On", inline = "tf7", group = grpTf)
string tf7 = input.timeframe("1",   "Zeitebene / Timeframe 7", inline = "tf7", group = grpTf)

grpPos = "5 · Position & Ränder / Position & Margins"
string posInp    = input.string("Mitte rechts / Middle right", "Position",
     options = ["Oben links / Top left",       "Oben mitte / Top center",     "Oben rechts / Top right",
                "Mitte links / Middle left",   "Mitte / Middle",              "Mitte rechts / Middle right",
                "Unten links / Bottom left",   "Unten mitte / Bottom center", "Unten rechts / Bottom right"], group = grpPos)
string layoutInp = input.string("Vertikal / Vertical", "Anordnung / Layout",
     options = ["Vertikal / Vertical", "Horizontal"], group = grpPos)
int    padTop    = input.int(0, "Rand oben (Zeilen) / Top margin (rows)",         minval = 0, maxval = 10, group = grpPos,
     tooltip = "Nur an oberen Positionen. Platz für die Chart-Legende.\nTop positions only. Room for the chart legend.")
int    padBottom = input.int(0, "Rand unten (Zeilen) / Bottom margin (rows)",     minval = 0, maxval = 10, group = grpPos,
     tooltip = "Nur an unteren Positionen. Platz für das TradingView-Logo.\nBottom positions only. Room for the TradingView logo.")
int    padLeft   = input.int(0, "Rand links (Spalten) / Left margin (columns)",   minval = 0, maxval = 10, group = grpPos)
int    padRight  = input.int(0, "Rand rechts (Spalten) / Right margin (columns)", minval = 0, maxval = 10, group = grpPos)
int    gapPx     = input.int(2, "Pillenabstand (px) / Pill gap (px)",             minval = 0, maxval = 10, group = grpPos)

grpGrid = "6 · Gitter & Rahmen / Grid & Frame"
bool   gridAuto  = input.bool(true, "Gitter = Chart-Hintergrund / Grid = chart background", group = grpGrid,
     tooltip = "An: Pillen wirken freistehend. Aus: eigene Gitterfarbe.\nOn: pills look detached. Off: custom grid color.")
color  gridCol   = input.color(#131722, "Gitterfarbe / Grid color",             group = grpGrid)
int    frameW    = input.int(0, "Rahmen (px) / Frame (px)", minval = 0, maxval = 10, group = grpGrid)
color  frameCol  = input.color(#434651, "Rahmenfarbe / Frame color",           group = grpGrid)

grpText = "7 · Schrift / Font"
string sizeTfInp    = input.string("Normal", "Größe Zeitebene / Size timeframe",
     options = ["Winzig / Tiny", "Klein / Small", "Normal", "Groß / Large", "Riesig / Huge"], group = grpText)
string sizeStateInp = input.string("Normal", "Größe Zustand / Size state",
     options = ["Winzig / Tiny", "Klein / Small", "Normal", "Groß / Large", "Riesig / Huge"], group = grpText)
string fontInp      = input.string("Standard / Default", "Schriftart / Font",
     options = ["Standard / Default", "Monospace"], group = grpText)

// Deckkraft jeder Farbe lässt sich direkt im Farbwähler einstellen.
// Opacity of every color can be set directly in the color picker.
grpColBull = "8 · Farben Bulle / Colors Bull"
color bullBg   = input.color(#089981, "Hintergrund / Background", group = grpColBull)
color bullTxt  = input.color(#FFFFFF, "Schrift / Text",           group = grpColBull)

grpColBear = "9 · Farben Bär / Colors Bear"
color bearBg   = input.color(#F23645, "Hintergrund / Background", group = grpColBear)
color bearTxt  = input.color(#FFFFFF, "Schrift / Text",           group = grpColBear)

grpColNeut = "10 · Farben Neutral / Colors Neutral"
color neutBg   = input.color(#787B86, "Hintergrund / Background", group = grpColNeut)
color neutTxt  = input.color(#FFFFFF, "Schrift / Text",           group = grpColNeut)

grpColTf = "11 · Farben Zeitebene & Kopfzeile / Colors Timeframe & Header"
color tfBg     = input.color(#2A2E39, "Hintergrund / Background", group = grpColTf)
color tfTxt    = input.color(#D1D4DC, "Schrift / Text",           group = grpColTf)

// ───────────────────────────────────────────────────────────────────────────
//  Wörterbuch: [ Bulle, Bär, Kopfzeile-Label ] je Sprache
// ───────────────────────────────────────────────────────────────────────────
[txtBullInp, txtBearInp, txtTfInp] = switch langInp
    "English" => ["Bull",  "Bear", "TF"]
    "Deutsch" => ["Bulle", "Bär",  "TF"]
    => [cusBull, cusBear, cusTf]

// ───────────────────────────────────────────────────────────────────────────
//  2) Berechnung
// ───────────────────────────────────────────────────────────────────────────
// Zustand auf der jeweils aktuellen Kerze:
//   +1 = Bulle (SMA schnell > SMA langsam)
//   -1 = Bär   (SMA schnell < SMA langsam)
//    0 = neutral (gleich) oder noch keine ausreichenden Daten
f_state() =>
    float fast = ta.sma(src, fastLen)
    float slow = ta.sma(src, slowLen)
    na(fast) or na(slow) ? 0 : fast > slow ? 1 : fast < slow ? -1 : 0

// Zustand einer Zeitebene abrufen (siehe Repainting-Ansatz im Kopf)
f_mtfState(simple string tf) =>
    int closed = request.security(syminfo.tickerid, tf, f_state()[1], lookahead = barmerge.lookahead_on)
    int live   = request.security(syminfo.tickerid, tf, f_state(),    lookahead = barmerge.lookahead_off)
    liveMode ? live : closed

// Zeitebenen-String in Kurzlabel umwandeln: "D" → D1, "240" → H4, "30" → M30 …
f_tfLabel(simple string tf) =>
    int sec = timeframe.in_seconds(tf)
    string lbl = switch
        str.endswith(tf, "M")    => "MN" + str.tostring(int(sec / 2628003))
        sec % 604800 == 0        => "W"  + str.tostring(int(sec / 604800))
        sec % 86400  == 0        => "D"  + str.tostring(int(sec / 86400))
        sec % 3600   == 0        => "H"  + str.tostring(int(sec / 3600))
        sec % 60     == 0        => "M"  + str.tostring(int(sec / 60))
        => "S" + str.tostring(sec)
    lbl

// Alle sieben Zeitebenen auf jeder Kerze auswerten (request.security muss
// auf jeder Kerze aufgerufen werden, daher außerhalb von barstate.islast)
int s1 = f_mtfState(tf1)
int s2 = f_mtfState(tf2)
int s3 = f_mtfState(tf3)
int s4 = f_mtfState(tf4)
int s5 = f_mtfState(tf5)
int s6 = f_mtfState(tf6)
int s7 = f_mtfState(tf7)

// Zähler über die AKTIVEN Zeitebenen
f_cnt(bool en, int st, int want) => en and st == want ? 1 : 0
int nActive = (en1 ? 1 : 0) + (en2 ? 1 : 0) + (en3 ? 1 : 0) + (en4 ? 1 : 0) + (en5 ? 1 : 0) + (en6 ? 1 : 0) + (en7 ? 1 : 0)
int nBull   = f_cnt(en1, s1, 1) + f_cnt(en2, s2, 1) + f_cnt(en3, s3, 1) + f_cnt(en4, s4, 1) + f_cnt(en5, s5, 1) + f_cnt(en6, s6, 1) + f_cnt(en7, s7, 1)
int nBear   = f_cnt(en1, s1, -1) + f_cnt(en2, s2, -1) + f_cnt(en3, s3, -1) + f_cnt(en4, s4, -1) + f_cnt(en5, s5, -1) + f_cnt(en6, s6, -1) + f_cnt(en7, s7, -1)
bool allBull = nActive > 0 and nBull == nActive
bool allBear = nActive > 0 and nBear == nActive

// SMA-Linien der Chart-Zeitebene (nur wenn eingeschaltet)
float smaFast = ta.sma(src, fastLen)
float smaSlow = ta.sma(src, slowLen)
plot(showSma ? smaFast : na, "SMA schnell / fast", color = smaFastCol, linewidth = 1)
plot(showSma ? smaSlow : na, "SMA langsam / slow", color = smaSlowCol, linewidth = 1)

// Hintergrund-Tönung bei Gleichlauf
bgcolor(bgTint and allBull ? color.new(bullBg, 90) : bgTint and allBear ? color.new(bearBg, 90) : na)

// ───────────────────────────────────────────────────────────────────────────
//  3) Dashboard (Tabelle)
// ───────────────────────────────────────────────────────────────────────────
// Input-Text → Pine-Konstanten (Positions-Strings beginnen mit dem deutschen Wort)
string tblPos = switch
    str.startswith(posInp, "Oben links")   => position.top_left
    str.startswith(posInp, "Oben mitte")   => position.top_center
    str.startswith(posInp, "Oben rechts")  => position.top_right
    str.startswith(posInp, "Mitte links")  => position.middle_left
    str.startswith(posInp, "Mitte rechts") => position.middle_right
    str.startswith(posInp, "Mitte")        => position.middle_center
    str.startswith(posInp, "Unten links")  => position.bottom_left
    str.startswith(posInp, "Unten mitte")  => position.bottom_center
    => position.bottom_right

f_size(string s) =>
    switch
        str.startswith(s, "Winzig") => size.tiny
        str.startswith(s, "Klein")  => size.small
        str.startswith(s, "Groß")   => size.large
        str.startswith(s, "Riesig") => size.huge
        => size.normal

string sizeTf    = f_size(sizeTfInp)
string sizeState = f_size(sizeStateInp)
string fontFam   = fontInp == "Monospace" ? font.family_monospace : font.family_default
bool   vertical  = str.startswith(layoutInp, "Vertikal")

// Ränder nur an der Kante anwenden, an der die Tabelle tatsächlich sitzt
bool atTop    = str.startswith(posInp, "Oben")
bool atBottom = str.startswith(posInp, "Unten")
bool atLeft   = str.contains(posInp, "links")
bool atRight  = str.contains(posInp, "rechts")
int  padT = atTop    ? padTop    : 0
int  padB = atBottom ? padBottom : 0
int  padL = atLeft   ? padLeft   : 0
int  padR = atRight  ? padRight  : 0

// Maximale Tabellengröße: bis zu 9 Paare (Kopf + 7 TF + Summe) à 2 Zellen
int cellsPerPair = compactMode ? 1 : 2
int maxPairs     = 9
int maxCols      = (vertical ? cellsPerPair : maxPairs * cellsPerPair) + padL + padR
int maxRows      = (vertical ? maxPairs     : 1) + padT + padB

// Tabelle einmalig anlegen. Das Gitter (border) zwischen den Zellen erzeugt
// den Abstand; in Chart-Hintergrundfarbe wirken die Zellen wie freistehende
// Pillen, in einer eigenen Farbe wie ein klassisches Raster.
color gridColor = gridAuto ? chart.bg_color : gridCol
var table dash = table.new(tblPos, maxCols, maxRows,
     bgcolor      = color.new(color.black, 100),
     frame_width  = frameW,
     frame_color  = frameCol,
     border_width = gapPx,
     border_color = gridColor)

color transparent = color.new(color.black, 100)

// Unsichtbare Abstandszelle (Höhe/Breite kommt aus dem Leerzeichen-Text)
f_spacer(int col, int row, string txt) =>
    table.cell(dash, col, row, txt, bgcolor = transparent, text_size = sizeState)

// Sichtbare Zelle
f_cell(int col, int row, string txt, color bg, color fg, string sz) =>
    table.cell(dash, col, row, txt,
         text_color       = fg,
         bgcolor          = bg,
         text_size        = sz,
         text_font_family = fontFam,
         text_halign      = text.align_center,
         text_valign      = text.align_center)

// Ein Pillen-Paar zeichnen. idx = Position in der Liste (0-basiert).
// kind:  0 = Zeitebene (st = Zustand)   1 = Kopfzeile   2 = Zusammenfassung
f_pill(int idx, int kind, string lbl, int st) =>
    string txt = ""
    color  bg  = tfBg
    color  fg  = tfTxt
    if kind == 1
        txt := "SMA " + str.tostring(fastLen) + "/" + str.tostring(slowLen)
    else if kind == 2
        bool bullish = nBull > nBear
        bool bearish = nBear > nBull
        int    n    = bullish ? nBull : bearish ? nBear : nBull
        string word = bullish ? txtBullInp : bearish ? txtBearInp : txtNeutInp
        txt := str.tostring(n) + "/" + str.tostring(nActive) + " " + word
        bg  := bullish ? bullBg  : bearish ? bearBg  : neutBg
        fg  := bullish ? bullTxt : bearish ? bearTxt : neutTxt
    else
        txt := st > 0 ? txtBullInp : st < 0 ? txtBearInp : txtNeutInp
        bg  := st > 0 ? bullBg  : st < 0 ? bearBg  : neutBg
        fg  := st > 0 ? bullTxt : st < 0 ? bearTxt : neutTxt
    int c = padL + (vertical ? 0   : idx * cellsPerPair)
    int r = padT + (vertical ? idx : 0)
    if compactMode
        f_cell(c, r, "  " + lbl + "  " + txt + "  ", bg, fg, sizeState)
    else
        f_cell(c,     r, "  " + lbl + "  ", tfBg, tfTxt, sizeTf)
        f_cell(c + 1, r, "  " + txt + "  ", bg,   fg,    sizeState)

// Ein Paar an die Anzeigeliste anhängen
f_add(string[] lbls, int[] kinds, int[] sts, string lbl, int kind, int st) =>
    array.push(lbls, lbl)
    array.push(kinds, kind)
    array.push(sts, st)

// Nur auf der letzten Kerze zeichnen – spart Rechenzeit, Werte stammen aus
// den oben auf jeder Kerze berechneten Serien.
if showDash and barstate.islast
    // Liste der anzuzeigenden Paare aufbauen
    string[] lbls  = array.new<string>()
    int[]    kinds = array.new<int>()
    int[]    sts   = array.new<int>()
    if showHeader
        f_add(lbls, kinds, sts, txtTfInp, 1, 0)
    if en1
        f_add(lbls, kinds, sts, f_tfLabel(tf1), 0, s1)
    if en2
        f_add(lbls, kinds, sts, f_tfLabel(tf2), 0, s2)
    if en3
        f_add(lbls, kinds, sts, f_tfLabel(tf3), 0, s3)
    if en4
        f_add(lbls, kinds, sts, f_tfLabel(tf4), 0, s4)
    if en5
        f_add(lbls, kinds, sts, f_tfLabel(tf5), 0, s5)
    if en6
        f_add(lbls, kinds, sts, f_tfLabel(tf6), 0, s6)
    if en7
        f_add(lbls, kinds, sts, f_tfLabel(tf7), 0, s7)
    if showSummary
        f_add(lbls, kinds, sts, txtSumInp, 2, 0)
    int pairs = array.size(lbls)

    // Tatsächlich belegter Bereich (für die Position der Ränder)
    int usedCols = vertical ? cellsPerPair : pairs * cellsPerPair
    int usedRows = vertical ? pairs        : 1

    // Ränder (Zeilen oben/unten, Spalten links/rechts)
    if padT > 0
        for r = 0 to padT - 1
            f_spacer(padL, r, " ")
    if padB > 0
        for r = 0 to padB - 1
            f_spacer(padL, padT + usedRows + r, " ")
    if padL > 0
        for c = 0 to padL - 1
            f_spacer(c, padT, "      ")
    if padR > 0
        for c = 0 to padR - 1
            f_spacer(padL + usedCols + c, padT, "      ")

    // Pillen
    if pairs > 0
        for i = 0 to pairs - 1
            f_pill(i, array.get(kinds, i), array.get(lbls, i), array.get(sts, i))

// ───────────────────────────────────────────────────────────────────────────
//  4) Alerts (alle aktiven Zeitebenen gleichgerichtet)
// ───────────────────────────────────────────────────────────────────────────
alertcondition(alertsOn and allBull and not allBull[1], "Alle Zeitebenen Bulle / All timeframes Bull", "MTF SMA: alle aktiven Zeitebenen Bulle / all active timeframes Bull")
alertcondition(alertsOn and allBear and not allBear[1], "Alle Zeitebenen Bär / All timeframes Bear",   "MTF SMA: alle aktiven Zeitebenen Bär / all active timeframes Bear")
````
