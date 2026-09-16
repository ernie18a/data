<!-- tradingview-pine-id: PUB;b34ad850997849e5a0ade02e139a9791 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# 52 Week High/Low (Current & Offset)

Source: https://www.tradingview.com/script/R7YAnkjH/

## Description

Title:
52 Week High/Low (Current & Offset)

Visibility: Open (recommended) or Protected
Category: Overlay / indicator
Companion script: 52 Week High/Low Offset Screener

----- Description (paste below; English first) -----

[A German description follows the English text.]

█ OVERVIEW

This indicator plots two 52-week ranges at once:

• Current 52-week high/low, including today’s price, as two horizontal lines.
• Historical 52-week high/low, lagged by a user-defined number of weeks, as a full history.

The current range always moves with price. After a sharp rally or sell-off that can make the live 52-week band less useful for context (for example dollar-cost averaging). The offset range shows where the 52-week high and low stood N weeks ago, before the latest move fully rewrote those extremes.

A distance label shows how far the close is from the nearer offset level, in percent of the current price. Positive = price is above that level, negative = below.

This is a positioning tool, not a buy or sell signal.

█ HOW IT WORKS

Current 52-week high/low
Calculated on the weekly timeframe over 52 weeks and combined with the developing week’s high/low on the chart timeframe, so today’s price is included.

Historical 52-week high/low (offset)
The same 52-week calculation, shifted by N weekly bars (default: 52). The offset is applied on the weekly timeframe, not in chart bars, so “52 weeks” remains 52 weeks on a daily chart.

Distance %
(close − offset level) / close × 100

The label is attached to whichever offset level is closer in price:
• Orange = nearer the offset high
• Teal = nearer the offset low

If the current 52-week high and the offset high print as the same price, they are merged into one label: “52W High = Offset”. The same logic applies independently to the low.

█ HOW TO USE

1. Add the script to a chart (daily is a typical timeframe).
2. Set Historical offset (weeks). Default is 52 (about one year); 13 ≈ one quarter, 4 ≈ one month.
3. Read price against the white historical path, not only against the green/red current lines.
4. Use the distance label and the table (Current vs −Nw) for a quick readout.

Reading for DCA-style context (not advice):
• Near the offset low, slightly negative or slightly positive → closer to the older low.
• Near the offset high, small negative → still below the older high, relatively expensive vs that band.
• Near the offset high, positive → price has left the older high.

█ SETTINGS

52-week setup
• Basis for 52-week values: Highs/Lows (default) or Close
• Historical offset (weeks)

Current 52W High/Low
• Horizontal lines, colors, width, style (solid / dashed / dotted), price labels

Historical 52W High/Low (Offset)
• History on/off, colors, fill, fill color
• In the Style tab, historical lines default to dashed and can be switched to solid or dotted

Info panel
• Table on/off, position, distance label

█ NOTES AND LIMITS

• 52 weeks means 52 weekly bars, not exactly 365 calendar days.
• The current 52-week high/low updates with the developing week.
• The offset uses closed weekly values (no lookahead inside the forming week).
• Companion screener: “52 Week High/Low Offset Screener” (add to Favorites, then Products → Screeners → Pine).

This script does not generate trading signals and is not investment advice.

--------------------------------------------------------------------------------
DEUTSCH

█ ÜBERBLICK

Der Indikator zeigt zwei 52-Wochen-Spannen gleichzeitig:

• Das aktuelle 52-Wochen-Hoch/-Tief inklusive heutigem Kurs, als zwei horizontale Linien.
• Das historische 52-Wochen-Hoch/-Tief, um eine wählbare Anzahl Wochen versetzt, als vollständigen Verlauf.

Die aktuelle Range wandert immer mit dem Kurs. Nach einer starken Rally oder einem Ausverkauf ist das live 52-Wochen-Band für den Kontext oft weniger nützlich (zum Beispiel beim Averagen / DCA). Die Offset-Range zeigt, wo Hoch und Tief vor N Wochen standen, bevor die jüngste Bewegung diese Extreme überschrieben hat.

Das Abstands-Label zeigt, wie weit der Schlusskurs vom näheren Offset-Niveau entfernt ist (in % vom aktuellen Kurs). Positiv = Kurs liegt darüber, negativ = darunter.

Das ist eine Lagehilfe, kein Kauf- oder Verkaufssignal.

█ BERECHNUNG

Aktuelles 52-Wochen-Hoch/-Tief
Berechnung auf dem Wochen-Timeframe über 52 Wochen, kombiniert mit dem laufenden Wochenhoch/-tief auf dem Chart-Timeframe, damit der heutige Kurs einbezogen wird.

Historisches 52-Wochen-Hoch/-Tief (Offset)
Dieselbe 52-Wochen-Berechnung, um N Wochenkerzen verschoben (Standard: 52). Der Versatz greift auf dem Wochen-Chart, nicht in Chart-Balken. „52 Wochen“ bleiben also auch auf dem Tageschart 52 Wochen.

Abstand %
(Schlusskurs − Offset-Niveau) / Schlusskurs × 100

Das Label hängt an dem Offset-Niveau, das preislich näher liegt:
• Orange = näher am Offset-Hoch
• Türkis = näher am Offset-Tief

Sind aktuelles 52W-Hoch und Offset-Hoch als derselbe Preis dargestellt, werden sie in einem Label zusammengefasst: „52W High = Offset“. Dieselbe Logik gilt unabhängig fürs Tief.

█ NUTZUNG

1. Skript auf einen Chart legen (Tageschart ist ein üblicher Timeframe).
2. Historical offset (weeks) einstellen. Standard ist 52 (ca. ein Jahr); 13 ≈ ein Quartal, 4 ≈ ein Monat.
3. Den Kurs gegen den weißen historischen Verlauf lesen, nicht nur gegen die grünen/roten aktuellen Linien.
4. Abstands-Label und Tabelle (Current vs. −Nw) für die schnelle Ablesung nutzen.

Lesart für DCA-Kontext (keine Empfehlung):
• Nah am Offset-Tief, leicht negativ oder leicht positiv → näher am älteren Tief.
• Nah am Offset-Hoch, leicht negativ → noch unter dem älteren Hoch, relativ teuer zu diesem Band.
• Nah am Offset-Hoch, positiv → der Kurs hat das ältere Hoch verlassen.

█ EINSTELLUNGEN

52-week setup
• Basis for 52-week values: Highs/Lows (Standard) oder Close
• Historical offset (weeks)

Current 52W High/Low
• Horizontale Linien, Farben, Stärke, Stil (solid / dashed / dotted), Preis-Labels

Historical 52W High/Low (Offset)
• Verlauf an/aus, Farben, Füllung, Füllfarbe
• Im Tab Style sind die historischen Linien standardmäßig gestrichelt und können auf durchgezogen oder gepunktet gestellt werden

Info panel
• Tabelle an/aus, Position, Abstands-Label

█ HINWEISE UND GRENZEN

• 52 Wochen bedeutet 52 Wochenkerzen, nicht exakt 365 Kalendertage.
• Das aktuelle 52-Wochen-Hoch/-Tief aktualisiert sich mit der laufenden Woche.
• Der Offset verwendet geschlossene Wochenwerte (kein Vorgriff innerhalb der entstehenden Woche).
• Begleit-Screener: „52 Week High/Low Offset Screener“ (zu den Favoriten, dann Products → Screeners → Pine).

Dieses Skript erzeugt keine Handelssignale und ist keine Anlageberatung.

---

## Source Code

````pine
//@version=6
// by makurypt
// Companion screener: https://www.tradingview.com/script/48vB0ple/
indicator("52 Week High/Low (Current & Offset)", shorttitle="52W H/L Offset", overlay=true, max_lines_count=10, max_labels_count=10)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
grpCalc = "52-week setup"
grpCurr = "Current 52W High/Low"
grpHist = "Historical 52W High/Low (Offset)"
grpInfo = "Info panel"

basis = input.string("Highs/Lows", "Basis for 52-week values", options=["Highs/Lows", "Close"], group=grpCalc, tooltip="Highs/Lows: classic 52-week high/low from candle extremes.\nClose: highest/lowest closing price of the last 52 weeks.", display=display.none)
offsetWeeks = input.int(52, "Historical offset (weeks)", minval=1, group=grpCalc, tooltip="Shifts the historical 52-week high/low by this many weeks. The full history of those lagged values is plotted. Useful for DCA: price is compared with a range that has not yet been stretched by the latest move.", display=display.none)

showCurr = input.bool(true, "Show horizontal lines", group=grpCurr, display=display.none)
colCurrH = input.color(color.new(#00E676, 50), "High color", inline="currCol", group=grpCurr, display=display.none)
colCurrL = input.color(color.new(#FF5252, 50), "Low color", inline="currCol", group=grpCurr, display=display.none)
currWidth = input.int(2, "Line width", minval=1, maxval=4, group=grpCurr, display=display.none)
currStyle = input.string("Dashed", "Line style", options=["Solid", "Dashed", "Dotted"], group=grpCurr, display=display.none)
showCurrLbl = input.bool(true, "Price labels", group=grpCurr, display=display.none)

showHist = input.bool(true, "Show history", group=grpHist, display=display.none)
colHistH = input.color(color.new(#FFFFFF, 50), "High color", inline="histCol", group=grpHist, display=display.none)
colHistL = input.color(color.new(#FFFFFF, 50), "Low color", inline="histCol", group=grpHist, display=display.none)
histWidth = input.int(2, "Line width", minval=1, maxval=4, group=grpHist, display=display.none)
showFill = input.bool(true, "Fill between high and low", group=grpHist, display=display.none)
colFill = input.color(color.new(#787878, 85), "Fill color", group=grpHist, display=display.none)

showTable = input.bool(true, "Show table", group=grpInfo, display=display.none)
tablePos = input.string("Top right", "Position", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=grpInfo, display=display.none)
showLageLbl = input.bool(true, "Distance label on offset", group=grpInfo, tooltip="Shows how far the current close is from the nearer offset level (historical 52-week high or low). Positive = price is above that level, negative = below.", display=display.none)

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────
srcH() => basis == "Highs/Lows" ? high : close
srcL() => basis == "Highs/Lows" ? low : close

lineStyleFrom(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

tablePosFrom(s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right : s == "Bottom left" ? position.bottom_left : position.top_right

// Distance in % from the current close to a level.
// Positive = close is above the level, negative = below.
pctFromClose(level) =>
    not na(level) and close != 0 ? (close - level) / close * 100.0 : na

fmtPct(v) =>
    na(v) ? "—" : (v > 0 ? "+" : "") + str.tostring(v, "#.#") + "%"

// ─────────────────────────────────────────────
// 52-week values on a weekly timeframe
// Offset is applied in weeks, not in chart bars.
// lookahead_off: no future values inside the forming week.
// ─────────────────────────────────────────────
[wHigh52, wLow52, histHigh, histLow] = request.security(syminfo.tickerid, "W",
     [ta.highest(srcH(), 52),
      ta.lowest(srcL(), 52),
      ta.highest(srcH(), 52)[offsetWeeks],
      ta.lowest(srcL(), 52)[offsetWeeks]],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

// Developing week high/low on the chart timeframe so the
// current 52-week high/low includes today's price.
var float weekHi = na
var float weekLo = na
if timeframe.change("W") or na(weekHi)
    weekHi := srcH()
    weekLo := srcL()
else
    weekHi := math.max(weekHi, srcH())
    weekLo := math.min(weekLo, srcL())

currHigh = math.max(nz(wHigh52), weekHi)
currLow  = math.min(nz(wLow52, 1e10), weekLo)

distHigh = pctFromClose(histHigh)
distLow  = pctFromClose(histLow)
nearerIsHigh = math.abs(close - histHigh) <= math.abs(close - histLow)
nearerLevel = nearerIsHigh ? histHigh : histLow
nearerDist = nearerIsHigh ? distHigh : distLow
nearerName = nearerIsHigh ? "offset high" : "offset low"
distTxt = fmtPct(nearerDist)
lageLblTxt = distTxt + " current price vs " + nearerName + " (−" + str.tostring(offsetWeeks) + "W)"
colLage = nearerIsHigh ? color.new(#EF6C00, 0) : color.new(#00897B, 0)
farLevel = nearerIsHigh ? histLow : histHigh
farCol = nearerIsHigh ? colHistL : colHistH
farLblTxt = nearerIsHigh ? "52W Low Offset  " + str.tostring(histLow, format.mintick) : "52W High Offset  " + str.tostring(histHigh, format.mintick)
highSame = str.tostring(histHigh, format.mintick) == str.tostring(currHigh, format.mintick)
lowSame = str.tostring(histLow, format.mintick) == str.tostring(currLow, format.mintick)
currHTxt = highSame ? "52W High = Offset  " + str.tostring(currHigh, format.mintick) : "52W High  " + str.tostring(currHigh, format.mintick)
currLTxt = lowSame ? "52W Low = Offset  " + str.tostring(currLow, format.mintick) : "52W Low  " + str.tostring(currLow, format.mintick)
showFarOffsetLbl = not (nearerIsHigh ? lowSame : highSame)

// ─────────────────────────────────────────────
// Historical path (full series)
// ─────────────────────────────────────────────
pHistH = plot(showHist ? histHigh : na, title="52W High (Historical)", color=colHistH, linewidth=histWidth, style=plot.style_line, linestyle=plot.linestyle_dashed, display=display.pane)
pHistL = plot(showHist ? histLow  : na, title="52W Low (Historical)",  color=colHistL, linewidth=histWidth, style=plot.style_line, linestyle=plot.linestyle_dashed, display=display.pane)
fill(pHistH, pHistL, color=showHist and showFill ? colFill : na, title="Fill")

// ─────────────────────────────────────────────
// Current 52W high/low: two horizontal lines only
// ─────────────────────────────────────────────
var line lineCurrH = na
var line lineCurrL = na
var label labCurrH = na
var label labCurrL = na
var label labLage = na
var label labOffsetFar = na

if barstate.islast
    if not na(lineCurrH)
        line.delete(lineCurrH)
    if not na(lineCurrL)
        line.delete(lineCurrL)
    if not na(labCurrH)
        label.delete(labCurrH)
    if not na(labCurrL)
        label.delete(labCurrL)
    if not na(labLage)
        label.delete(labLage)
    if not na(labOffsetFar)
        label.delete(labOffsetFar)

    if showCurr
        lineCurrH := line.new(bar_index, currHigh, bar_index + 1, currHigh, extend=extend.left, color=colCurrH, width=currWidth, style=lineStyleFrom(currStyle))
        lineCurrL := line.new(bar_index, currLow,  bar_index + 1, currLow,  extend=extend.left, color=colCurrL, width=currWidth, style=lineStyleFrom(currStyle))

        if showCurrLbl
            labCurrH := label.new(bar_index, currHigh, currHTxt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(colCurrH, 20), textcolor=color.white, size=size.small)
            labCurrL := label.new(bar_index, currLow, currLTxt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(colCurrL, 20), textcolor=color.white, size=size.small)

    if showLageLbl
        labLage := label.new(bar_index, nearerLevel, lageLblTxt, xloc=xloc.bar_index, style=label.style_label_left, color=colLage, textcolor=color.white, size=size.small)
        if showFarOffsetLbl
            labOffsetFar := label.new(bar_index, farLevel, farLblTxt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(farCol, 0), textcolor=color.black, size=size.small)

// ─────────────────────────────────────────────
// Info table
// ─────────────────────────────────────────────
var table info = table.new(position.top_right, 4, 4, border_width=1)

if barstate.islast
    if showTable
        table.set_position(info, tablePosFrom(tablePos))
        bgHead = color.new(#263238, 10)
        bgH    = color.new(colHistH, 75)
        bgL    = color.new(colHistL, 75)
        bgDist = color.new(colLage, 35)
        txt    = color.white
        padBg  = color.new(color.black, 100)
        padTxt = color.new(color.white, 100)
        pad    = "               "

        table.cell(info, 0, 0, "52W H/L",    bgcolor=bgHead, text_color=txt, text_size=size.small)
        table.cell(info, 1, 0, "Current",    bgcolor=bgHead, text_color=txt, text_size=size.small)
        table.cell(info, 2, 0, "-" + str.tostring(offsetWeeks) + "W", bgcolor=bgHead, text_color=txt, text_size=size.small)
        table.cell(info, 3, 0, pad, bgcolor=padBg, text_color=padTxt, text_size=size.small)

        table.cell(info, 0, 1, "High", bgcolor=bgH, text_color=txt, text_size=size.small)
        table.cell(info, 1, 1, str.tostring(currHigh, format.mintick), bgcolor=bgH, text_color=txt, text_size=size.small)
        table.cell(info, 2, 1, str.tostring(histHigh, format.mintick), bgcolor=bgH, text_color=txt, text_size=size.small)
        table.cell(info, 3, 1, pad, bgcolor=padBg, text_color=padTxt, text_size=size.small)

        table.cell(info, 0, 2, "Low", bgcolor=bgL, text_color=txt, text_size=size.small)
        table.cell(info, 1, 2, str.tostring(currLow, format.mintick), bgcolor=bgL, text_color=txt, text_size=size.small)
        table.cell(info, 2, 2, str.tostring(histLow, format.mintick), bgcolor=bgL, text_color=txt, text_size=size.small)
        table.cell(info, 3, 2, pad, bgcolor=padBg, text_color=padTxt, text_size=size.small)

        table.cell(info, 0, 3, "Distance", bgcolor=bgDist, text_color=txt, text_size=size.small)
        table.cell(info, 1, 3, distTxt, bgcolor=bgDist, text_color=txt, text_size=size.small)
        table.cell(info, 2, 3, nearerIsHigh ? "to high" : "to low", bgcolor=bgDist, text_color=txt, text_size=size.tiny)
        table.cell(info, 3, 3, pad, bgcolor=padBg, text_color=padTxt, text_size=size.small)
    else
        table.clear(info, 0, 0, 3, 3)
````
