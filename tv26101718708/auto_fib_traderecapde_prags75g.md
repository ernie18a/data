# Auto Fib - TradeRecap.de

- url: https://www.tradingview.com/script/prAGs75g/
- type: indicator
- pine_id: PUB;72e5280f62f24ccaac55e2c4e3635ebf
- version: 1.0

## Description

Auto Fib Pro ist ein professionelles Fibonacci-Execution-Tool für struktur- und liquiditybasierte Trader.

Der Indikator zeichnet dynamische Fibonacci-Level ab einem frei wählbaren Startpunkt und aktualisiert automatisch das aktuelle Hoch/Tief der Bewegung. Entwickelt für präzise Entries, Management und Take-Profits im Intraday- und Scalping-Bereich.

Features
Dynamische Fibonacci-Projektion
Long- und Short-Modus
Automatische Aktualisierung der Bewegung
Frei anpassbare Fibonacci-Level
Eigene Label-Texte möglich
Tick- und Punktanzeige
Individuelle Farben & Linienstile
Erweiterung nach rechts optional
Anpassbare Schriftgrößen
Optimiert für Execution & Risk Management
Standard-Setup


Der Startpunkt kann manuell gesetzt werden.
Alle Levels sind vollständig personalisierbar.
Tick-Distanzen werden automatisch vom gewählten Referenz-Level berechnet.
Der Indikator dient ausschließlich zur Chartanalyse und stellt keine Finanzberatung dar.

## Source Code

````pine
//@version=5
indicator("Auto Fib - TradeRecap.de", overlay=true, max_lines_count=200, max_labels_count=200)

//━━━━━━━━━━━━━━━━━━━
// GRUPPEN
//━━━━━━━━━━━━━━━━━━━
groupGeneral = "Allgemein"
groupStyle   = "Darstellung"
groupLabels  = "Fenster-Label"
groupTicks   = "Tick Anzeige"
groupLevels  = "Fibonacci Level"

//━━━━━━━━━━━━━━━━━━━
// ALLGEMEIN
//━━━━━━━━━━━━━━━━━━━
direction = input.string(
     "Short",
     "Richtung",
     options=["Long", "Short"],
     group=groupGeneral)

startTime = input.time(
     timestamp("2026-05-19 13:03"),
     "Startzeit",
     group=groupGeneral)

//━━━━━━━━━━━━━━━━━━━
// DARSTELLUNG
//━━━━━━━━━━━━━━━━━━━
extendRight = input.bool(
     false,
     "Nach rechts verlängern",
     group=groupStyle)

lineWidth = input.int(
     2,
     "Linienbreite",
     minval=1,
     maxval=5,
     group=groupStyle)

lineStyleInput = input.string(
     "Gestrichelt",
     "Linienstil",
     options=["Durchgezogen", "Gestrichelt", "Gepunktet"],
     group=groupStyle)

lineStyle =
     lineStyleInput == "Gestrichelt" ? line.style_dashed :
     lineStyleInput == "Gepunktet" ? line.style_dotted :
     line.style_solid

//━━━━━━━━━━━━━━━━━━━
// LABELS
//━━━━━━━━━━━━━━━━━━━
showLabels = input.bool(
     true,
     "Labels anzeigen",
     group=groupLabels)

showPrices = input.bool(
     true,
     "Preis anzeigen",
     group=groupLabels)

useCustomText = input.bool(
     true,
     "Eigenen Text statt %",
     group=groupLabels)

labelOffset = input.int(
     2,
     "Abstand rechts",
     minval=0,
     maxval=100,
     group=groupLabels)

labelBg = input.color(
     color.new(#aeaeae, 100),
     "Hintergrund",
     group=groupLabels)

labelTxtCol = input.color(
     color.black,
     "Textfarbe",
     group=groupLabels)

labelSizeInput = input.string(
     "Normal",
     "Schriftgröße",
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group=groupLabels)

labelSize =
     labelSizeInput == "Tiny" ? size.tiny :
     labelSizeInput == "Small" ? size.small :
     labelSizeInput == "Normal" ? size.normal :
     labelSizeInput == "Large" ? size.large :
     size.huge

//━━━━━━━━━━━━━━━━━━━
// TICK ANZEIGE
//━━━━━━━━━━━━━━━━━━━
showTicks = input.bool(
     true,
     "Ticks anzeigen",
     group=groupTicks)

tickReferenceLevel = input.float(
     0.786,
     "Referenz-Level",
     group=groupTicks)

showPoints = input.bool(
     false,
     "Punkte anzeigen",
     group=groupTicks)

ticksBetween(price1, price2) =>
    math.round(math.abs(price1 - price2) / syminfo.mintick)

//━━━━━━━━━━━━━━━━━━━
// FIB LEVELS
//━━━━━━━━━━━━━━━━━━━
show0 = input.bool(true, "", inline="L0", group=groupLevels)
lvl0  = input.float(0.0, "", inline="L0", group=groupLevels)
col0  = input.color(color.gray, "", inline="L0", group=groupLevels)
txt0  = input.string("0", "", inline="L0", group=groupLevels)

show1 = input.bool(true, "", inline="L1", group=groupLevels)
lvl1  = input.float(0.258, "", inline="L1", group=groupLevels)
col1  = input.color(color.gray, "", inline="L1", group=groupLevels)
txt1  = input.string("2R", "", inline="L1", group=groupLevels)

show2 = input.bool(true, "", inline="L2", group=groupLevels)
lvl2  = input.float(0.522, "", inline="L2", group=groupLevels)
col2  = input.color(color.gray, "", inline="L2", group=groupLevels)
txt2  = input.string("Management", "", inline="L2", group=groupLevels)

show3 = input.bool(true, "", inline="L3", group=groupLevels)
lvl3  = input.float(0.5, "", inline="L3", group=groupLevels)
col3  = input.color(color.gray, "", inline="L3", group=groupLevels)
txt3  = input.string("50%", "", inline="L3", group=groupLevels)

show4 = input.bool(false, "", inline="L4", group=groupLevels)
lvl4  = input.float(0.618, "", inline="L4", group=groupLevels)
col4  = input.color(color.gray, "", inline="L4", group=groupLevels)
txt4  = input.string("61.8%", "", inline="L4", group=groupLevels)

show5 = input.bool(true, "", inline="L5", group=groupLevels)
lvl5  = input.float(0.786, "", inline="L5", group=groupLevels)
col5  = input.color(color.gray, "", inline="L5", group=groupLevels)
txt5  = input.string("78.6%", "", inline="L5", group=groupLevels)

show6 = input.bool(true, "", inline="L6", group=groupLevels)
lvl6  = input.float(1.0, "", inline="L6", group=groupLevels)
col6  = input.color(color.gray, "", inline="L6", group=groupLevels)
txt6  = input.string("100%", "", inline="L6", group=groupLevels)

show7 = input.bool(true, "", inline="L7", group=groupLevels)
lvl7  = input.float(1.05, "", inline="L7", group=groupLevels)
col7  = input.color(color.rgb(54, 54, 54), "", inline="L7", group=groupLevels)
txt7  = input.string("Stoploss", "", inline="L7", group=groupLevels)

show8 = input.bool(false, "", inline="L8", group=groupLevels)
lvl8  = input.float(1.414, "", inline="L8", group=groupLevels)
col8  = input.color(color.gray, "", inline="L8", group=groupLevels)
txt8  = input.string("", "", inline="L8", group=groupLevels)

show9 = input.bool(false, "", inline="L9", group=groupLevels)
lvl9  = input.float(1.618, "", inline="L9", group=groupLevels)
col9  = input.color(color.gray, "", inline="L9", group=groupLevels)
txt9  = input.string("", "", inline="L9", group=groupLevels)

//━━━━━━━━━━━━━━━━━━━
// VARIABLEN
//━━━━━━━━━━━━━━━━━━━
var float startPrice = na
var float endPrice   = na
var int startBar     = na

var line[] fibLines = array.new_line()
var label[] fibLabels = array.new_label()

if barstate.isfirst
    for i = 0 to 9
        array.push(fibLines, na)
        array.push(fibLabels, na)

//━━━━━━━━━━━━━━━━━━━
// RESET
//━━━━━━━━━━━━━━━━━━━
var int lastStartTime = na
var string lastDirection = na

if startTime != lastStartTime or direction != lastDirection
    startPrice := na
    endPrice := na
    startBar := na
    lastStartTime := startTime
    lastDirection := direction

//━━━━━━━━━━━━━━━━━━━
// STARTPUNKT
//━━━━━━━━━━━━━━━━━━━
if time >= startTime and na(startPrice)
    startPrice := direction == "Long" ? low : high
    endPrice := startPrice
    startBar := bar_index

//━━━━━━━━━━━━━━━━━━━
// ENDPUNKT
//━━━━━━━━━━━━━━━━━━━
if not na(startPrice)

    if direction == "Long" and high > endPrice
        endPrice := high

    if direction == "Short" and low < endPrice
        endPrice := low

//━━━━━━━━━━━━━━━━━━━
// FIB PREIS
//━━━━━━━━━━━━━━━━━━━
fib(level) =>
    direction == "Long"
         ? endPrice - (endPrice - startPrice) * level
         : endPrice + (startPrice - endPrice) * level

//━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━
levels = array.from(lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7, lvl8, lvl9)

shows = array.from(show0, show1, show2, show3, show4, show5, show6, show7, show8, show9)

colors = array.from(col0, col1, col2, col3, col4, col5, col6, col7, col8, col9)

texts = array.from(txt0, txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9)

//━━━━━━━━━━━━━━━━━━━
// UPDATE FUNKTION
//━━━━━━━━━━━━━━━━━━━
updateFib(index, enabled, level, lvlColor, customTxt) =>

    price = fib(level)

    ln = array.get(fibLines, index)
    lb = array.get(fibLabels, index)

    if enabled

        if na(ln)

            ln := line.new(
                 startBar,
                 price,
                 bar_index,
                 price,
                 color=lvlColor,
                 width=lineWidth,
                 style=lineStyle,
                 extend=extendRight ? extend.right : extend.none)

            array.set(fibLines, index, ln)

        else

            line.set_xy1(ln, startBar, price)
            line.set_xy2(ln, bar_index, price)
            line.set_color(ln, lvlColor)
            line.set_width(ln, lineWidth)
            line.set_style(ln, lineStyle)
            line.set_extend(ln, extendRight ? extend.right : extend.none)

        if showLabels

            txt =
                 useCustomText and customTxt != ""
                 ? customTxt
                 : str.tostring(level * 100, "#.###") + "%"

            if showPrices
                txt += "  " + str.tostring(price, format.mintick)

            if showTicks

                refPrice = fib(tickReferenceLevel)

                tickDistance = ticksBetween(price, refPrice)

                txt += " | " + str.tostring(tickDistance) + "T"

                if showPoints

                    pointDistance = math.abs(price - refPrice)

                    txt += " / " + str.tostring(pointDistance, format.mintick) + "P"

            if na(lb)

                lb := label.new(
                     bar_index + labelOffset,
                     price,
                     txt,
                     style=label.style_label_left,
                     textcolor=labelTxtCol,
                     color=labelBg,
                     size=labelSize)

                array.set(fibLabels, index, lb)

            else

                label.set_xy(lb, bar_index + labelOffset, price)
                label.set_text(lb, txt)
                label.set_textcolor(lb, labelTxtCol)
                label.set_color(lb, labelBg)
                label.set_size(lb, labelSize)

    else

        if not na(ln)
            line.delete(ln)
            array.set(fibLines, index, na)

        if not na(lb)
            label.delete(lb)
            array.set(fibLabels, index, na)

//━━━━━━━━━━━━━━━━━━━
// ZEICHNEN
//━━━━━━━━━━━━━━━━━━━
if not na(endPrice)

    updateFib(0, show0, lvl0, col0, txt0)
    updateFib(1, show1, lvl1, col1, txt1)
    updateFib(2, show2, lvl2, col2, txt2)
    updateFib(3, show3, lvl3, col3, txt3)
    updateFib(4, show4, lvl4, col4, txt4)
    updateFib(5, show5, lvl5, col5, txt5)
    updateFib(6, show6, lvl6, col6, txt6)
    updateFib(7, show7, lvl7, col7, txt7)
    updateFib(8, show8, lvl8, col8, txt8)
    updateFib(9, show9, lvl9, col9, txt9)
````
