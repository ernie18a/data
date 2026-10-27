# Market Structure HH/HL/LH/LL + MTF Trend Table

- url: https://www.tradingview.com/script/tm7I266J/
- type: indicator
- pine_id: PUB;5d52979a78d04671a3370869cc26e0f3
- version: 1.0

## Description

WHAT IT DOES
 
This indicator marks swing structure - higher highs, higher lows,
lower highs, lower lows - draws a horizontal level line from every
swing point, and adds a multi-timeframe trend table that stays
visible regardless of the chart's timeframe.
 
 
WHAT IS DIFFERENT ABOUT IT
 
Two design decisions set it apart from the usual structure scripts.
 
First, swings are detected on closing prices by default, not on
wicks. The structure drawn on a candle chart is therefore identical
to the structure of the same instrument's line chart. Most structure
tools read highs and lows, which means the picture changes the moment
you switch chart type. A wick-based mode is available as an option
for those who want it.
 
Second, the structure drawing is bound to the chart's own timeframe.
Every timeframe is enabled separately and carries its own maximum
line length in bars - 30 for weekly, 40 for daily, 200 for 4H by
default - so higher timeframe levels do not clutter an intraday
chart. The trend table is independent of that and always reports
weekly, daily and 4H no matter where you are.
 
 
HOW THE LEVELS BEHAVE
 
Each swing point receives a line that extends to the right until one
of two things happens: price closes through it, or the timeframe's
maximum bar count is reached. Breaks are evaluated on closed bars
only, so an intrabar spike that is reversed before the close does not
terminate a level.
 
Two optional filters change what stays on the chart:
 
Only unbroken levels - line and label are removed the moment a level
is crossed, leaving only the levels that have not been taken yet.
 
Only relevant points (enabled by default) - keeps every point of the
current trend leg. In an uptrend that means all HH and HL back to the
low the move originated from, including highs that have already been
broken. The whole set is cleared only when the trend reverses, and
collection then starts in the opposite direction.
 
 
THE TREND TABLE
 
Trend is derived from breaks of structure: a close above the last
swing high sets UP, a close below the last swing low sets DOWN.
 
Each row compares two states - the trend as of the last closed bar,
and the trend right now. While they agree the cell reads UP or DOWN.
When price is breaking the opposite level and the candle is still
open, the cell reads UP SWITCH DOWN in orange. If the bar closes that
way it becomes a plain DOWN on the next bar; if price recovers before
the close, the switch state disappears by itself and leaves no mark
in the history.
 
Weekly, daily and 4H are always present. Monthly, 1H, 30m, 15m, 5m
and 1m can be added individually. The table can sit in any of the
four corners, with an offset setting that keeps it clear of
TradingView's own chart buttons.
 
 
SETTINGS - THE INTERFACE IS IN GERMAN
 
General (Allgemein)
  Pivot: Bars links / rechts - pivot strength, bars left and right.
    Left filters noise, right controls how quickly a point is
    confirmed. They are deliberately separate.
  Berechnungsbasis - calculation basis: Close (line chart) or
    High/Low (wicks)
  Nur relevante Punkte (aktueller Trendabschnitt) - only relevant
    points (current trend leg)
  Nur ungebrochene Level (gebrochene loeschen) - only unbroken
    levels, delete broken ones
  Sonst: Linie beim Kreuzen beenden - otherwise end the line at the
    cross
  Linien anzeigen / Labels anzeigen - show lines / show labels
  Max. gespeicherte Strukturpunkte - maximum stored structure points
 
Structure timeframes (Struktur-Timeframes)
  aktiv | max. Linienlaenge in Bars - active | maximum line length
    in bars
  Bars - bars
  Sonstige TFs - other timeframes
 
Structure appearance (Darstellung Struktur)
  Label HH / HL, Label LH / LL - label colors
  Linienfarbe / Breite - line color / width
  Linienstil - line style: Solide (solid), Gestrichelt (dashed),
    Gepunktet (dotted)
  Labelgroesse - label size: Winzig (tiny), Klein (small), Normal,
    Gross (large)
 
Trend table (Trend-Tabelle)
  Trend-Tabelle anzeigen - show trend table
  Position - Links oben (top left), Rechts oben (top right),
    Links unten (bottom left), Rechts unten (bottom right)
  Abstand vom Rand (Leerzeilen) - offset from the corner, in empty
    rows
  Textgroesse - text size
  Hintergrund - background color
 
 
NOTES AND LIMITATIONS
 
A swing point is confirmed only after the number of bars set under
"rechts" has closed. With the default of 1, the newest point on the
live bar can still move or disappear until that bar closes. This is
inherent to pivot detection rather than a defect. Raise the right
value if you need points to be final once printed.
 
Requesting a timeframe lower than the chart's for the trend table -
5m rows on a daily chart, for example - returns dependable data only
for the most recent value. Higher timeframes viewed from a lower
chart are not affected by this.
 
The indicator describes structure. It generates no entries, no
targets, no directional advice and makes no claim about profitability.
 
 
-- Deutsch --
 
Der Indikator markiert die Swing-Struktur (HH, HL, LH, LL), zieht von
jedem Punkt eine Levellinie nach rechts und zeigt eine
Multi-Timeframe-Trendtabelle, die auf jedem Chart-Zeitrahmen sichtbar
bleibt.
 
Die Pivots rechnen standardmaessig auf Schlusskursen statt auf Wicks.
Dadurch ist das Bild im Kerzenchart identisch mit dem Linienchart -
der Unterschied zu den meisten Struktur-Skripten, die auf Hoch und
Tief lesen. Die Struktur wird nur auf den Zeitrahmen gezeichnet, die
in den Einstellungen aktiv sind, jeweils mit eigener maximaler
Linienlaenge. Jede Linie endet beim Kreuzen oder beim Erreichen
dieser Laenge, wobei der Bruch nur auf geschlossenen Kerzen gewertet
wird.
 
Der Trend leitet sich aus dem Strukturbruch ab. Laeuft ein Bruch
gerade, ist die Kerze aber noch offen, steht in der Tabelle
UP SWITCH DOWN in Orange. Schliesst die Kerze so, wird daraus ein
sauberes DOWN, dreht der Kurs vorher zurueck, verschwindet der
Hinweis rueckstandsfrei.
 
Der Indikator beschreibt Struktur. Er liefert keine Einstiege, keine
Ziele und keine Richtungsempfehlung.

## Source Code

````pine
//@version=6
indicator("Marktstruktur HH / HL / LH / LL", "MS", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════
//  Swing-Struktur HH / HL / LH / LL  +  Levellinien  +  Trend-Dashboard
//
//  • Berechnung standardmäßig auf CLOSE  ->  identisches Bild im
//    Linienchart UND im Kerzenchart
//  • Struktur wird nur auf aktivierten Timeframes gezeichnet
//  • Trend-Tabelle ist IMMER sichtbar, unabhängig vom Chart-TF
//    UP = HH/HL, DOWN = LH/LL, "UP SWITCH DOWN" = Bruch läuft gerade,
//    Kerze aber noch nicht geschlossen
// ═══════════════════════════════════════════════════════════════════════

type MS
    line  ln
    label lb
    float lvl
    bool  isHigh
    int   x1
    bool  live

// ───────────────────────────── Allgemein ──────────────────────────────
g1      = "Allgemein"
pvtL    = input.int(1, "Pivot: Bars links", minval = 1, maxval = 50, group = g1, inline = "pv", tooltip = "LINKS = Filter. Wie viele Bars links vom Punkt tiefer/höher sein müssen. 1 = jeder kleine Schwung, 3 = nur grobe Struktur.\n\nRECHTS = Bestätigung. Wie viele abgeschlossene Bars nach dem Punkt vergehen müssen. 1 = schnellste Anzeige.")
pvtR    = input.int(1, "rechts", minval = 1, maxval = 50, group = g1, inline = "pv")
basis   = input.string("Close (Linienchart)", "Berechnungsbasis", options = ["Close (Linienchart)", "High / Low (Wicks)"], group = g1)
onlyRel = input.bool(true, "Nur relevante Punkte (aktueller Trendabschnitt)", group = g1, tooltip = "An: es bleiben ALLE Punkte des laufenden Trends stehen - im Aufwärtstrend also sämtliche HH und HL ab dem Tief, aus dem der Trend gestartet ist, auch die bereits gebrochenen. Gelöscht wird erst bei einer Trendumkehr, dann beginnt die Sammlung in der Gegenrichtung.")
onlyUnb = input.bool(false, "Nur ungebrochene Level (gebrochene löschen)", group = g1)
stopBrk = input.bool(true,  "Sonst: Linie beim Kreuzen beenden", group = g1)
showLn  = input.bool(true,  "Linien anzeigen", group = g1)
showLbl = input.bool(true,  "Labels anzeigen", group = g1)
keep    = input.int(60, "Max. gespeicherte Strukturpunkte", minval = 5, maxval = 200, group = g1)

// ──────────────────────── Timeframes + Länge ──────────────────────────
g2      = "Struktur-Timeframes  (aktiv  |  max. Linienlänge in Bars)"
onMN    = input.bool(false, "Monthly", group = g2, inline = "mn")
lenMN   = input.int(24,  "Bars", minval = 1, group = g2, inline = "mn")
onW     = input.bool(true,  "Weekly",  group = g2, inline = "w")
lenW    = input.int(30,  "Bars", minval = 1, group = g2, inline = "w")
onD     = input.bool(true,  "Daily",   group = g2, inline = "d")
lenD    = input.int(40,  "Bars", minval = 1, group = g2, inline = "d")
on4H    = input.bool(true,  "4H",      group = g2, inline = "h4")
len4H   = input.int(200, "Bars", minval = 1, group = g2, inline = "h4")
on1H    = input.bool(false, "1H",      group = g2, inline = "h1")
len1H   = input.int(200, "Bars", minval = 1, group = g2, inline = "h1")
on30    = input.bool(false, "30m",     group = g2, inline = "m30")
len30   = input.int(200, "Bars", minval = 1, group = g2, inline = "m30")
on15    = input.bool(false, "15m",     group = g2, inline = "m15")
len15   = input.int(200, "Bars", minval = 1, group = g2, inline = "m15")
on5     = input.bool(false, "5m",      group = g2, inline = "m5")
len5    = input.int(200, "Bars", minval = 1, group = g2, inline = "m5")
on1     = input.bool(false, "1m",      group = g2, inline = "m1")
len1    = input.int(200, "Bars", minval = 1, group = g2, inline = "m1")
onOth   = input.bool(false, "Sonstige TFs", group = g2, inline = "oth")
lenOth  = input.int(100, "Bars", minval = 1, group = g2, inline = "oth")

// ──────────────────────────── Darstellung ─────────────────────────────
g3      = "Darstellung Struktur"
cBull   = input.color(#9C27B0, "Label HH / HL", group = g3)
cBear   = input.color(#9C27B0, "Label LH / LL", group = g3)
cLine   = input.color(#000000, "Linienfarbe", group = g3, inline = "ln")
wLine   = input.int(1, "Breite", minval = 1, maxval = 4, group = g3, inline = "ln")
sLine   = input.string("Solide", "Linienstil", options = ["Solide", "Gestrichelt", "Gepunktet"], group = g3)
zLbl    = input.string("Normal", "Labelgröße", options = ["Winzig", "Klein", "Normal", "Groß"], group = g3)

// ────────────────────────── Trend-Tabelle ─────────────────────────────
g4      = "Trend-Tabelle"
showTbl = input.bool(true, "Trend-Tabelle anzeigen", group = g4)
tblPos  = input.string("Rechts oben", "Position", options = ["Links oben", "Rechts oben", "Links unten", "Rechts unten"], group = g4)
tblPad  = input.int(2, "Abstand vom Rand (Leerzeilen)", minval = 0, maxval = 8, group = g4)
tblTxt  = input.string("Groß", "Textgröße", options = ["Winzig", "Klein", "Normal", "Groß"], group = g4)
addMN   = input.bool(false, "+ Monthly", group = g4, inline = "a1")
add1H   = input.bool(false, "+ 1H",      group = g4, inline = "a1")
add30   = input.bool(false, "+ 30m",     group = g4, inline = "a2")
add15   = input.bool(false, "+ 15m",     group = g4, inline = "a2")
add5    = input.bool(false, "+ 5m",      group = g4, inline = "a3")
add1    = input.bool(false, "+ 1m",      group = g4, inline = "a3")
cUp     = input.color(#089981, "UP",     group = g4, inline = "c1")
cDn     = input.color(#F23645, "DOWN",   group = g4, inline = "c1")
cSw     = input.color(#FF9800, "SWITCH", group = g4, inline = "c1")
cTblBg  = input.color(color.new(#000000, 80), "Hintergrund", group = g4)

lineStyle = sLine == "Gestrichelt" ? line.style_dashed : sLine == "Gepunktet" ? line.style_dotted : line.style_solid
lblSize   = zLbl == "Winzig" ? size.tiny : zLbl == "Klein" ? size.small : zLbl == "Groß" ? size.large : size.normal
tSz       = tblTxt == "Winzig" ? size.tiny : tblTxt == "Klein" ? size.small : tblTxt == "Normal" ? size.normal : size.large
tPos      = tblPos == "Links oben" ? position.top_left : tblPos == "Rechts oben" ? position.top_right : tblPos == "Links unten" ? position.bottom_left : position.bottom_right
isTop     = tblPos == "Links oben" or tblPos == "Rechts oben"

useClose = basis == "Close (Linienchart)"
srcH     = useClose ? close : high
srcL     = useClose ? close : low

// ══════════════ 1) Ist der aktuelle Chart-Timeframe aktiv? ════════════
bool tfOn  = false
int  tfLen = 0
int  secs  = timeframe.in_seconds()

if timeframe.ismonthly
    tfOn  := onMN
    tfLen := lenMN
else if timeframe.isweekly
    tfOn  := onW
    tfLen := lenW
else if timeframe.isdaily
    tfOn  := onD
    tfLen := lenD
else if secs == 14400
    tfOn  := on4H
    tfLen := len4H
else if secs == 3600
    tfOn  := on1H
    tfLen := len1H
else if secs == 1800
    tfOn  := on30
    tfLen := len30
else if secs == 900
    tfOn  := on15
    tfLen := len15
else if secs == 300
    tfOn  := on5
    tfLen := len5
else if secs == 60
    tfOn  := on1
    tfLen := len1
else
    tfOn  := onOth
    tfLen := lenOth

// ══════════════════════ 2) Struktur zeichnen ══════════════════════════
ph = ta.pivothigh(srcH, pvtL, pvtR)
pl = ta.pivotlow(srcL,  pvtL, pvtR)

var array<MS> store  = array.new<MS>()
var float     lastPH = na
var float     lastPL = na

// Chart-TF Trend + Ursprung des laufenden Abschnitts (für Relevanz-Filter)
var float swHi    = na
var float swLo    = na
var int   swHiX   = na
var int   swLoX   = na
var int   trChart = 0

f_kill(MS o) =>
    if not na(o.ln)
        line.delete(o.ln)
        o.ln := na
    if not na(o.lb)
        label.delete(o.lb)
        o.lb := na
    o.live := false

addPoint(float lvl, bool isHigh, string txt) =>
    int   px = bar_index - pvtR
    line  ln = na
    label lb = na
    if showLn
        ln := line.new(px, lvl, bar_index, lvl, xloc = xloc.bar_index, color = cLine, style = lineStyle, width = wLine)
    if showLbl and str.length(txt) > 0
        lb := label.new(px, lvl, txt, xloc = xloc.bar_index, yloc = yloc.price, style = isHigh ? label.style_label_down : label.style_label_up, color = color.new(color.white, 100), textcolor = (txt == "HH" or txt == "HL") ? cBull : cBear, size = lblSize)
    array.push(store, MS.new(ln, lb, lvl, isHigh, px, true))
    if array.size(store) > keep
        MS old = array.shift(store)
        if not na(old.ln)
            line.delete(old.ln)
        if not na(old.lb)
            label.delete(old.lb)

if tfOn
    if array.size(store) > 0
        for i = 0 to array.size(store) - 1
            MS s = array.get(store, i)
            if s.live and not na(s.ln)
                bool hit = barstate.isconfirmed and (s.isHigh ? srcH > s.lvl : srcL < s.lvl)
                if hit and onlyUnb
                    f_kill(s)
                else if hit and stopBrk
                    line.set_x2(s.ln, bar_index)
                    s.live := false
                else if bar_index - s.x1 >= tfLen
                    line.set_x2(s.ln, s.x1 + tfLen)
                    s.live := false
                else
                    line.set_x2(s.ln, bar_index)

    if not na(ph)
        string tH = na(lastPH) ? "" : ph > lastPH ? "HH" : "LH"
        addPoint(ph, true, tH)
        lastPH := ph
        swHi   := ph
        swHiX  := bar_index - pvtR

    if not na(pl)
        string tL = na(lastPL) ? "" : pl < lastPL ? "LL" : "HL"
        addPoint(pl, false, tL)
        lastPL := pl
        swLo   := pl
        swLoX  := bar_index - pvtR

    // Trendumkehr auf dem Chart-TF -> alten Abschnitt wegräumen
    if barstate.isconfirmed
        int prevTr = trChart
        if not na(swHi) and srcH > swHi
            trChart := 1
        if not na(swLo) and srcL < swLo
            trChart := -1
        if onlyRel and trChart != prevTr and trChart != 0
            int cutX = trChart == 1 ? nz(swLoX, 0) : nz(swHiX, 0)
            if array.size(store) > 0
                for q = 0 to array.size(store) - 1
                    MS o = array.get(store, q)
                    if o.x1 < cutX
                        f_kill(o)

// ══════════════════ 3) Trend-Engine (MTF-fähig) ═══════════════════════
f_trend(bool uc, int pL_, int pR_) =>
    float sH = uc ? close : high
    float sL = uc ? close : low
    float pvH = ta.pivothigh(sH, pL_, pR_)
    float pvL = ta.pivotlow(sL, pL_, pR_)
    var float sh = na
    var float sl = na
    var int   t  = 0
    if not na(pvH)
        sh := pvH
    if not na(pvL)
        sl := pvL
    if not na(sh) and sH > sh
        t := 1
    if not na(sl) and sL < sl
        t := -1
    [t[1], t]

[mnC, mnL]   = request.security(syminfo.tickerid, "M",   f_trend(useClose, pvtL, pvtR))
[wkC, wkL]   = request.security(syminfo.tickerid, "W",   f_trend(useClose, pvtL, pvtR))
[dyC, dyL]   = request.security(syminfo.tickerid, "D",   f_trend(useClose, pvtL, pvtR))
[h4C, h4L]   = request.security(syminfo.tickerid, "240", f_trend(useClose, pvtL, pvtR))
[h1C, h1L]   = request.security(syminfo.tickerid, "60",  f_trend(useClose, pvtL, pvtR))
[m30C, m30L] = request.security(syminfo.tickerid, "30",  f_trend(useClose, pvtL, pvtR))
[m15C, m15L] = request.security(syminfo.tickerid, "15",  f_trend(useClose, pvtL, pvtR))
[m5C, m5L]   = request.security(syminfo.tickerid, "5",   f_trend(useClose, pvtL, pvtR))
[m1C, m1L]   = request.security(syminfo.tickerid, "1",   f_trend(useClose, pvtL, pvtR))

f_word(int v) =>
    v == 1 ? "UP" : v == -1 ? "DOWN" : "–"

f_text(int c, int l) =>
    c != l and c != 0 and l != 0 ? f_word(c) + " SWITCH " + f_word(l) : f_word(l)

f_color(int c, int l) =>
    c != l and c != 0 and l != 0 ? cSw : l == 1 ? cUp : l == -1 ? cDn : color.gray

// ══════════════════════ 4) Trend-Tabelle ══════════════════════════════
var table tbl = table.new(tPos, 2, 22, border_width = 1)

f_pad(int r) =>
    table.cell(tbl, 0, r, " ", text_size = tSz, bgcolor = color.new(color.black, 100))
    table.cell(tbl, 1, r, " ", text_size = tSz, bgcolor = color.new(color.black, 100))

f_row(int r, string lbl, int c, int l) =>
    table.cell(tbl, 0, r, lbl, text_color = color.gray, text_size = tSz, bgcolor = cTblBg, text_halign = text.align_left)
    table.cell(tbl, 1, r, f_text(c, l), text_color = f_color(c, l), text_size = tSz, bgcolor = cTblBg, text_halign = text.align_right)

if showTbl and barstate.islast
    table.clear(tbl, 0, 0, 1, 21)
    int r = 0
    if isTop and tblPad > 0
        for k = 0 to tblPad - 1
            f_pad(r)
            r += 1
    table.cell(tbl, 0, r, "TF",    text_color = color.gray, text_size = tSz, bgcolor = cTblBg, text_halign = text.align_left)
    table.cell(tbl, 1, r, "TREND", text_color = color.gray, text_size = tSz, bgcolor = cTblBg, text_halign = text.align_right)
    r += 1
    if addMN
        f_row(r, "Monthly", mnC, mnL)
        r += 1
    f_row(r, "Weekly", wkC, wkL)
    r += 1
    f_row(r, "Daily", dyC, dyL)
    r += 1
    f_row(r, "4H", h4C, h4L)
    r += 1
    if add1H
        f_row(r, "1H", h1C, h1L)
        r += 1
    if add30
        f_row(r, "30m", m30C, m30L)
        r += 1
    if add15
        f_row(r, "15m", m15C, m15L)
        r += 1
    if add5
        f_row(r, "5m", m5C, m5L)
        r += 1
    if add1
        f_row(r, "1m", m1C, m1L)
        r += 1
    if not isTop and tblPad > 0
        for k2 = 0 to tblPad - 1
            f_pad(r)
            r += 1
````
