# MTF Stoch RSI Snapshot 9 Timeframe Overview

- url: https://www.tradingview.com/script/qUTcCCdM-MTF-Stoch-RSI-Snapshot-9-Timeframe-Overview/
- type: indicator
- pine_id: PUB;0fa8f697caa848d6a3b5edc9d4d4d9c7
- version: 2.0

## Description

This indicator provides a compact multi-timeframe view of the Stochastic RSI across 9 different timeframes:

1m, 5m, 15m, 30m, 45m, 1h, 2h, 6h, 1D

Instead of switching between charts, the script displays all selected timeframes side by side in a clean column layout. Each column represents one timeframe and shows the current position of the two Stoch RSI lines, making it easier to quickly understand momentum conditions across multiple market structures.

Main Features
Multi-timeframe Stoch RSI visualization
9 fixed timeframe columns
K and D lines shown inside each column
Gradient background based on oscillator level
Quick visual identification of overbought and oversold areas
20 / 50 / 80 reference levels
Optional numeric K and D values
Compact layout designed for fast market reading
How to Read It

Each column represents a timeframe.

The vertical position of the lines shows where the Stoch RSI currently is:

Near the bottom: oversold / weak momentum area
Around the middle: neutral zone
Near the top: overbought / strong momentum area

The background gradient helps identify the oscillator zone immediately, while the two plotted lines allow you to see the current relationship between K and D.

This is useful when you want to compare short-term and higher-timeframe momentum at a glance.

Typical Use Cases
Scalping confirmation
Multi-timeframe momentum alignment
Spotting overbought / oversold conditions across timeframes
Filtering entries based on higher-timeframe context
Quickly checking whether short-term movement agrees with broader market structure
Notes

This indicator does not generate buy or sell signals by itself.
It is intended as a visual decision-support tool and should be used together with price action, trend analysis, support and resistance, and proper risk management.

Disclaimer

This script is for educational and informational purposes only.
It is not financial advice. Always test any trading approach carefully before using it in live markets.

## Source Code

````pine
//@version=6
indicator("MTF Stoch RSI 9 Colonne", overlay=false, max_boxes_count=500, max_lines_count=100, max_labels_count=100)


// ==========================
// INPUT
// ==========================
rsiLen        = input.int(14, "RSI Length", minval=1)
stochLen      = input.int(14, "Stoch Length", minval=1)
smoothK       = input.int(3, "Smooth K", minval=1)
smoothD       = input.int(3, "Smooth D", minval=1)

colWidth      = input.int(6, "Larghezza colonna in barre", minval=2, maxval=30)
colGap        = input.int(2, "Spazio tra colonne in barre", minval=0, maxval=20)
leftOffset    = input.int(2, "Offset da ultima candela", minval=0, maxval=100)

gradientSteps = input.int(20, "Step gradiente", minval=5, maxval=40)
showValues    = input.bool(true, "Mostra valori")

// ==========================
// COLORI
// ==========================
colK      = color.rgb(0, 190, 255)
colD      = color.rgb(255, 170, 0)

colLow    = color.rgb(255, 70, 70)
colMid    = color.rgb(45, 45, 45)
colHigh   = color.rgb(70, 200, 255)

colBorder = color.new(color.white, 45)
colLevel  = color.new(color.white, 78)
colText   = color.new(color.white, 0)

// ==========================
// TIMEFRAME
// ==========================
var string[] tfs   = array.from("1", "5", "15", "30", "45", "60", "120", "360", "D")
var string[] names = array.from("1m", "5m", "15m", "30m", "45m", "1h", "2h", "6h", "1D")

// ==========================
// OGGETTI
// ==========================
var box[]   bgBoxes     = array.new_box()
var box[]   borderBoxes = array.new_box()
var line[]  kLines      = array.new_line()
var line[]  dLines      = array.new_line()
var line[]  l20s        = array.new_line()
var line[]  l80s        = array.new_line()
var label[] tfLabels    = array.new_label()
var label[] valLabels   = array.new_label()

// ==========================
// STOCH RSI
// ==========================
f_stochRsi() =>
    r = ta.rsi(close, rsiLen)
    s = ta.stoch(r, r, r, stochLen)
    k = ta.sma(s, smoothK)
    d = ta.sma(k, smoothD)
    [k, d, k[1], d[1]]

// ==========================
// CLAMP MANUALE
// ==========================
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(value, maxValue))

// ==========================
// COLORE GRADIENTE 0-100
// ==========================
f_levelColor(float level) =>
    level <= 50 ?
         color.from_gradient(level, 0, 50, colLow, colMid) :
         color.from_gradient(level, 50, 100, colMid, colHigh)

// ==========================
// CREAZIONE OGGETTI
// ==========================
if barstate.isfirst
    for i = 0 to array.size(tfs) - 1
        for s = 0 to gradientSteps - 1
            array.push(bgBoxes, box.new(na, na, na, na, border_color=color.new(color.black, 100)))

        array.push(borderBoxes, box.new(na, na, na, na, bgcolor=color.new(color.black, 100), border_color=colBorder))
        array.push(kLines, line.new(na, na, na, na, width=3))
        array.push(dLines, line.new(na, na, na, na, width=3))
        array.push(l20s, line.new(na, na, na, na, width=1, style=line.style_dotted))
        array.push(l80s, line.new(na, na, na, na, width=1, style=line.style_dotted))
        array.push(tfLabels, label.new(na, na, "", style=label.style_none, textcolor=colText, size=size.small))
        array.push(valLabels, label.new(na, na, "", style=label.style_none, textcolor=colText, size=size.tiny))

// ==========================
// DISEGNO 9 COLONNE AFFIANCATE
// ==========================
if barstate.islast
    totalCols  = array.size(tfs)
    totalWidth = totalCols * colWidth + (totalCols - 1) * colGap
    startX     = bar_index - totalWidth - leftOffset

    for i = 0 to totalCols - 1
        tf = array.get(tfs, i)
        nm = array.get(names, i)

        [k, d, kPrev, dPrev] = request.security(syminfo.tickerid, tf, f_stochRsi(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

        kSafe     = f_clamp(nz(k, 50), 0, 100)
        dSafe     = f_clamp(nz(d, 50), 0, 100)
        kPrevSafe = f_clamp(nz(kPrev, kSafe), 0, 100)
        dPrevSafe = f_clamp(nz(dPrev, dSafe), 0, 100)

        avgNow = math.avg(kSafe, dSafe)

        x1 = startX + i * (colWidth + colGap)
        x2 = x1 + colWidth
        xc = int(math.round((x1 + x2) / 2.0))

        // ==========================
        // SFONDO GRADIENTE PER COLONNA
        // ==========================
        for s = 0 to gradientSteps - 1
            bandBottom = (100.0 / gradientSteps) * s
            bandTop    = (100.0 / gradientSteps) * (s + 1)
            bandLevel  = (100.0 / gradientSteps) * (s + 0.5)

            distanceFromLines = math.abs(bandLevel - avgNow)
            proximityBoost    = math.max(0.0, 28.0 - distanceFromLines) / 28.0

            baseColor    = f_levelColor(bandLevel)
            transparency = int(math.round(90.0 - proximityBoost * 45.0))
            bandColor    = color.new(baseColor, transparency)

            bgIndex = i * gradientSteps + s
            bgBox   = array.get(bgBoxes, bgIndex)

            box.set_lefttop(bgBox, x1, bandTop)
            box.set_rightbottom(bgBox, x2, bandBottom)
            box.set_bgcolor(bgBox, bandColor)
            box.set_border_color(bgBox, color.new(color.black, 100))

        // ==========================
        // BORDO COLONNA
        // ==========================
        borderBox = array.get(borderBoxes, i)
        box.set_lefttop(borderBox, x1, 100)
        box.set_rightbottom(borderBox, x2, 0)
        box.set_bgcolor(borderBox, color.new(color.black, 100))
        box.set_border_color(borderBox, colBorder)

        // ==========================
        // LINEA K
        // ==========================
        kl = array.get(kLines, i)
        line.set_xy1(kl, x1, kPrevSafe)
        line.set_xy2(kl, x2, kSafe)
        line.set_color(kl, colK)

        // ==========================
        // LINEA D
        // ==========================
        dl = array.get(dLines, i)
        line.set_xy1(dl, x1, dPrevSafe)
        line.set_xy2(dl, x2, dSafe)
        line.set_color(dl, colD)

        // ==========================
        // LIVELLO 20
        // ==========================
        l20 = array.get(l20s, i)
        line.set_xy1(l20, x1, 20)
        line.set_xy2(l20, x2, 20)
        line.set_color(l20, colLevel)

        // ==========================
        // LIVELLO 80
        // ==========================
        l80 = array.get(l80s, i)
        line.set_xy1(l80, x1, 80)
        line.set_xy2(l80, x2, 80)
        line.set_color(l80, colLevel)

        // ==========================
        // LABEL TIMEFRAME
        // ==========================
        tfLabel = array.get(tfLabels, i)
        label.set_xy(tfLabel, xc, 108)
        label.set_text(tfLabel, nm)
        label.set_textcolor(tfLabel, colText)

        // ==========================
        // LABEL VALORI
        // ==========================
        valLabel = array.get(valLabels, i)
        txt = showValues ? "K " + str.tostring(kSafe, "#") + "\nD " + str.tostring(dSafe, "#") : ""
        label.set_xy(valLabel, xc, -12)
        label.set_text(valLabel, txt)
        label.set_textcolor(valLabel, colText)

// ==========================
// SCALA FISSA VISIVA 0-100
// ==========================
plot(115, color=color.new(color.white, 100))
plot(-15, color=color.new(color.white, 100))
hline(80, "80", color=color.new(color.white, 75), linestyle=hline.style_dotted)
hline(50, "50", color=color.new(color.white, 88), linestyle=hline.style_dotted)
hline(20, "20", color=color.new(color.white, 75), linestyle=hline.style_dotted)
````
