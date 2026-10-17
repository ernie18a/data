# Infinity Signal StochRSI Projection + Auto Flip Deluxe

- url: https://www.tradingview.com/script/fUVfU9SY-Infinity-Signal-StochRSI-Projection-Auto-Flip-Deluxe/
- type: indicator
- pine_id: PUB;5990cadbf5de45f1ac951826124f92b5
- version: 1.0

## Description

Infinity Signal StochRSI Projection Plus Auto Flip is a standalone StochRSI projection tool. It displays the live percent K and percent D lines, then clones a selected historical StochRSI pattern forward so traders can visually compare current momentum with a possible future rhythm.

The projection includes optional Auto Flip. When the current StochRSI direction disagrees with the copied pattern direction, Auto Flip can invert the projection so the projected rhythm better aligns with live momentum.

The indicator also marks projected potential buy and potential sell crosses, lightly shades bullish and bearish projection zones, and shows whether the current projection is normal or auto flipped.

Suggested Pattern Start Bars Back settings for an approximate one hundred twenty-two day cycle:

1 Hour: 2928
2 Hour: 1464
4 Hour: 732
6 Hour: 488
8 Hour: 366
12 Hour: 244
1 Day: 122

This tool is for visual momentum study, cycle comparison, and educational analysis only. It does not predict the future and does not provide financial advice. Always do your own research.

## Source Code

````pine
//@version=6
indicator("Infinity Signal StochRSI Projection + Auto Flip Deluxe", overlay=false, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

//====================================================
// INPUTS
//====================================================
lengthRSI     = input.int(14, "RSI Length", minval=1)
lengthStoch   = input.int(14, "Stoch Length", minval=1)
smoothK       = input.int(3, "Smooth K", minval=1)
smoothD       = input.int(3, "Smooth D", minval=1)

startBarsBack = input.int(494, "Pattern Start Bars Back", minval=1)
endBarsBack   = input.int(464, "Pattern End Bars Back", minval=1)
shiftForward  = input.int(50, "Shift Pattern Forward", minval=0)

normalize      = input.bool(true, "Normalize Projection To Recent Range")
showProjection = input.bool(true, "Show Projection")

autoFlipProjection = input.bool(true, "Auto Flip Projection")
showNormalGhost    = input.bool(true, "Show Normal Ghost When Flipped")
flipSensitivity    = input.int(3, "Auto Flip Direction Lookback", minval=1, maxval=20)

showVLines       = input.bool(true, "Show Projected Cross Vertical Lines")
showArrows       = input.bool(true, "Show Projected Cross Arrows")
showBuySellLabel = input.bool(true, "Show Potential Buy/Sell Balloon")
showProjectionFill = input.bool(true, "Shade Projection K/D Space")
showStatusBadge = input.bool(true, "Show Projection Status Badge")
showCrossDots   = input.bool(true, "Show Projected Cross Dots")

//====================================================
// COLORS
//====================================================
liveKColor = input.color(color.green, "Live %K Color")
liveDColor = input.color(color.red, "Live %D Color")

projKColor = input.color(color.new(color.white, 45), "Projected %K Color")
projDColor = input.color(color.new(color.gray, 45), "Projected %D Color")

flipKColor = input.color(color.aqua, "Flipped %K Color")
flipDColor = input.color(color.orange, "Flipped %D Color")

ghostKColor = input.color(color.new(color.white, 82), "Normal Ghost %K Color")
ghostDColor = input.color(color.new(color.gray, 82), "Normal Ghost %D Color")

bullFillColor = input.color(color.new(color.green, 88), "Projection Bullish Fill")
bearFillColor = input.color(color.new(color.red, 88), "Projection Bearish Fill")

buyLabelBg  = input.color(color.green, "Potential Buy Balloon BG")
buyLabelTxt = input.color(color.white, "Potential Buy Balloon Text")

sellLabelBg  = input.color(color.red, "Potential Sell Balloon BG")
sellLabelTxt = input.color(color.white, "Potential Sell Balloon Text")

statusBg  = input.color(color.new(color.black, 15), "Status Badge BG")
statusTxt = input.color(color.white, "Status Badge Text")

arrowUpColor = input.color(color.green, "Projected Bull Cross Arrow")
arrowDnColor = input.color(color.red, "Projected Bear Cross Arrow")

cycleCol1 = input.color(color.green, "Cross Line Color 1")
cycleCol2 = input.color(color.blue, "Cross Line Color 2")
cycleCol3 = input.color(color.yellow, "Cross Line Color 3")
cycleCol4 = input.color(color.red, "Cross Line Color 4")

//====================================================
// STOCH RSI
//====================================================
rsiVal = ta.rsi(close, lengthRSI)
stoch  = ta.stoch(rsiVal, rsiVal, rsiVal, lengthStoch)

K = ta.sma(stoch, smoothK)
D = ta.sma(K, smoothD)

//====================================================
// HELPERS
//====================================================
array_min_f(_arr) =>
    float m = na
    for i = 0 to array.size(_arr) - 1
        float v = array.get(_arr, i)
        m := na(m) ? v : math.min(m, v)
    m

array_max_f(_arr) =>
    float m = na
    for i = 0 to array.size(_arr) - 1
        float m2 = array.get(_arr, i)
        m := na(m) ? m2 : math.max(m, m2)
    m

scale_val(val, oldMin, oldMax, newMin, newMax) =>
    oldMax == oldMin ? newMin : newMin + (val - oldMin) * (newMax - newMin) / (oldMax - oldMin)

//====================================================
// ARRAYS
//====================================================
var float[] patternK = array.new_float()
var float[] patternD = array.new_float()

var line[] linesK = array.new_line()
var line[] linesD = array.new_line()
var line[] ghostLinesK = array.new_line()
var line[] ghostLinesD = array.new_line()
var line[] vlines = array.new_line()

var linefill[] projectionFills = array.new_linefill()

var label[] arrowLabels = array.new_label()
var label[] crossDots = array.new_label()

var int[] crossBars = array.new_int()
var float[] crossYs = array.new_float()
var int[] crossDirections = array.new_int()

var label buySellBalloon = na
var label statusBadge = na

var color[] cycleColors = array.new_color()
if barstate.isfirst
    array.push(cycleColors, cycleCol1)
    array.push(cycleColors, cycleCol2)
    array.push(cycleColors, cycleCol3)
    array.push(cycleColors, cycleCol4)

//====================================================
// SAFETY LIMIT
//====================================================
maxLinesAllowed = 500
reserveLines = 100
maxPatternPoints = math.floor((maxLinesAllowed - reserveLines) / 4) + 1

//====================================================
// CLEAR OLD DRAWINGS
//====================================================
while array.size(linesK) > 0
    line.delete(array.pop(linesK))

while array.size(linesD) > 0
    line.delete(array.pop(linesD))

while array.size(ghostLinesK) > 0
    line.delete(array.pop(ghostLinesK))

while array.size(ghostLinesD) > 0
    line.delete(array.pop(ghostLinesD))

while array.size(vlines) > 0
    line.delete(array.pop(vlines))

while array.size(projectionFills) > 0
    linefill.delete(array.pop(projectionFills))

while array.size(arrowLabels) > 0
    label.delete(array.pop(arrowLabels))

while array.size(crossDots) > 0
    label.delete(array.pop(crossDots))

while array.size(crossBars) > 0
    array.pop(crossBars)

while array.size(crossYs) > 0
    array.pop(crossYs)

while array.size(crossDirections) > 0
    array.pop(crossDirections)

if not na(buySellBalloon)
    label.delete(buySellBalloon)
    buySellBalloon := na

if not na(statusBadge)
    label.delete(statusBadge)
    statusBadge := na

//====================================================
// BUILD HISTORICAL PATTERN
//====================================================
startIdx = math.max(startBarsBack, endBarsBack)
endIdx   = math.min(startBarsBack, endBarsBack)

count = startIdx - endIdx + 1
count := math.max(count, 1)

if count > maxPatternPoints
    count := maxPatternPoints
    startIdx := endIdx + count - 1

array.clear(patternK)
array.clear(patternD)

for j = 0 to count - 1
    idx = startIdx - j
    array.push(patternK, K[idx])
    array.push(patternD, D[idx])

//====================================================
// NORMALIZE PROJECTION
//====================================================
if normalize and array.size(patternK) > 0
    minK = array_min_f(patternK)
    maxK = array_max_f(patternK)
    minD = array_min_f(patternD)
    maxD = array_max_f(patternD)

    lookback = array.size(patternK)

    curMinK = ta.lowest(K, lookback)
    curMaxK = ta.highest(K, lookback)
    curMinD = ta.lowest(D, lookback)
    curMaxD = ta.highest(D, lookback)

    for i = 0 to array.size(patternK) - 1
        oldK = array.get(patternK, i)
        oldD = array.get(patternD, i)

        newK = scale_val(oldK, minK, maxK, curMinK, curMaxK)
        newD = scale_val(oldD, minD, maxD, curMinD, curMaxD)

        array.set(patternK, i, newK)
        array.set(patternD, i, newD)

//====================================================
// AUTO FLIP DECISION
//====================================================
liveDirSmoothed = ta.sma(K - K[1], flipSensitivity)
liveDirection = liveDirSmoothed > 0 ? 1 : liveDirSmoothed < 0 ? -1 : 0

projectedDirection = 0
if array.size(patternK) > flipSensitivity
    projNow   = array.get(patternK, 0)
    projLater = array.get(patternK, flipSensitivity)
    projectedDirection := projLater > projNow ? 1 : projLater < projNow ? -1 : 0

shouldFlipProjection = autoFlipProjection and liveDirection != 0 and projectedDirection != 0 and liveDirection != projectedDirection

//====================================================
// DRAW PROJECTION
//====================================================
if showProjection
    lenp = array.size(patternK)

    if lenp >= 2
        vcolIndex = 0

        for i = 0 to lenp - 2
            rawK1 = array.get(patternK, i)
            rawK2 = array.get(patternK, i + 1)
            rawD1 = array.get(patternD, i)
            rawD2 = array.get(patternD, i + 1)

            k1 = shouldFlipProjection ? 100.0 - rawK1 : rawK1
            k2 = shouldFlipProjection ? 100.0 - rawK2 : rawK2
            d1 = shouldFlipProjection ? 100.0 - rawD1 : rawD1
            d2 = shouldFlipProjection ? 100.0 - rawD2 : rawD2

            x1 = bar_index + shiftForward + i
            x2 = x1 + 1

            if shouldFlipProjection and showNormalGhost
                gk = line.new(x1, rawK1, x2, rawK2, xloc=xloc.bar_index, color=ghostKColor, width=1)
                gd = line.new(x1, rawD1, x2, rawD2, xloc=xloc.bar_index, color=ghostDColor, width=1)
                array.push(ghostLinesK, gk)
                array.push(ghostLinesD, gd)

            activeKColor = shouldFlipProjection ? flipKColor : projKColor
            activeDColor = shouldFlipProjection ? flipDColor : projDColor

            lk = line.new(x1, k1, x2, k2, xloc=xloc.bar_index, color=activeKColor, width=2)
            ld = line.new(x1, d1, x2, d2, xloc=xloc.bar_index, color=activeDColor, width=2)

            array.push(linesK, lk)
            array.push(linesD, ld)

            if showProjectionFill
                fillColor = k2 >= d2 ? bullFillColor : bearFillColor
                lf = linefill.new(lk, ld, fillColor)
                array.push(projectionFills, lf)

            crossedUp = k1 < d1 and k2 > d2
            crossedDn = k1 > d1 and k2 < d2

            if crossedUp or crossedDn
                array.push(crossBars, x2)

                denom = (k2 - k1) - (d2 - d1)
                t = denom == 0.0 ? 0.5 : (-(k1 - d1)) / denom
                t := math.max(0.0, math.min(1.0, t))

                crossY = k1 + (k2 - k1) * t
                array.push(crossYs, crossY)
                array.push(crossDirections, crossedUp ? 1 : -1)

                if showVLines
                    vcol = array.get(cycleColors, vcolIndex % array.size(cycleColors))
                    vl = line.new(x2, 100.0, x2, 0.0, xloc=xloc.bar_index, extend=extend.none, color=vcol, style=line.style_dotted, width=1)
                    array.push(vlines, vl)
                    vcolIndex += 1

                if showArrows
                    arrowText = crossedUp ? "▲" : "▼"
                    arrowCol  = crossedUp ? arrowUpColor : arrowDnColor
                    al = label.new(x2, crossY, text=arrowText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=arrowCol, color=color.new(color.white, 100))
                    array.push(arrowLabels, al)

                if showCrossDots
                    dotText = "●"
                    dotCol = crossedUp ? arrowUpColor : arrowDnColor
                    dot = label.new(x2, crossY, text=dotText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=dotCol, color=color.new(color.white, 100), size=size.tiny)
                    array.push(crossDots, dot)

//====================================================
// POTENTIAL BUY / SELL BALLOON
//====================================================
if showBuySellLabel and array.size(crossBars) > 0
    int earliest = na
    float earliestY = na
    int earliestDir = na

    for i = 0 to array.size(crossBars) - 1
        cb = array.get(crossBars, i)
        cy = array.get(crossYs, i)
        cd = array.get(crossDirections, i)

        if cb >= bar_index
            if na(earliest) or cb < earliest
                earliest := cb
                earliestY := cy
                earliestDir := cd

    if na(earliest)
        earliest := array.get(crossBars, 0)
        earliestY := array.get(crossYs, 0)
        earliestDir := array.get(crossDirections, 0)

    labelText = earliestDir == 1 ? "Potential Buy" : "Potential Sell"
    labelBg   = earliestDir == 1 ? buyLabelBg : sellLabelBg
    labelTxt  = earliestDir == 1 ? buyLabelTxt : sellLabelTxt
    labelStyle = earliestDir == 1 ? label.style_label_up : label.style_label_down

    if shouldFlipProjection
        labelText += "\nAuto Flipped"

    buySellBalloon := label.new(
         earliest,
         earliestY,
         text=labelText,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=labelStyle,
         color=labelBg,
         textcolor=labelTxt
    )

//====================================================
// STATUS BADGE
//====================================================
if showStatusBadge
    badgeText = shouldFlipProjection ? "Projection: AUTO FLIPPED" : "Projection: Normal"
    badgeY = shouldFlipProjection ? 96.0 : 92.0

    statusBadge := label.new(
         bar_index,
         badgeY,
         text=badgeText,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_left,
         color=statusBg,
         textcolor=statusTxt,
         size=size.tiny
    )

//====================================================
// LIVE STOCH RSI
//====================================================
plotK = plot(K, "%K Live", color=liveKColor, linewidth=2)
plotD = plot(D, "%D Live", color=liveDColor, linewidth=2)

liveFillColor = K >= D ? color.new(color.green, 92) : color.new(color.red, 92)
fill(plotK, plotD, color=liveFillColor, title="Live K/D Light Fill")

hline(80, "Overbought", color=color.gray)
hline(50, "Midline", color=color.new(color.gray, 60))
hline(20, "Oversold", color=color.gray)
````
