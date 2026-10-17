# SMC CLEAN FINAL FIXED

- url: https://www.tradingview.com/script/RupJ1AFZ-SMC-CLEAN-FINAL-FIXED/
- type: indicator
- pine_id: PUB;ddc4655773614847bc7b8b61a201a0de
- version: 1.0

## Description

SMC Clean Final is a precision-based Smart Money Concepts indicator designed to simplify market structure and highlight high-probability imbalance zones. It automatically marks BOS and CHOCH with centered labeling, detects CISD confirmation levels, and displays only the most relevant Fair Value Gaps (FVG) that transition into IFVG upon mitigation.

The script focuses on clarity by limiting visual clutter—showing only recent active zones and removing outdated structures—making it ideal for traders who rely on clean chart analysis. Built for lower timeframes (M1–M5), it helps identify reaction areas aligned with price action and liquidity concepts.

Key features include:
• Clean BOS / CHOCH structure labeling
• CISD detection with adjustable extension
• Smart FVG → IFVG transition logic
• Automatic removal of mitigated zones
• Optimized for scalping and precision entries

This tool is best used alongside a solid understanding of Smart Money Concepts and market structure.

## Source Code

````pine

//@version=5
indicator("SMC CLEAN FINAL FIXED", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =====================
// SETTINGS
// =====================
showBOS  = input.bool(true, "Show BOS / CHOCH")
showCISD = input.bool(true, "Show CISD (Recent Only)")
showFVG  = input.bool(true, "Show High Prob FVG")

swingLen = input.int(7, "Swing Length")

// CISD
cisdExtend = input.int(5, "CISD Extend Bars")
maxCISD    = input.int(5, "Max CISD (3–5 Recommended)")

// 🔥 NEW CISD TOGGLE
extendCISD_toggle = input.bool(true, "Extend CISD to 10 Bars")
cisdExtendBars    = input.int(10, "CISD Extend (Toggle ON)")

// FVG
extendFVG_toggle = input.bool(true, "Extend FVG Right")
extendFVG_bars   = input.int(10, "FVG Extend Bars")

minGapSize = input.float(0.00005, "Min FVG Size")
minSpacing = input.int(10, "Label Spacing")

bosColor   = color.teal
chochColor = color.red

// =====================
// STRUCTURE
// =====================
var float lastHigh = na
var float lastLow  = na
var int lastHighBar = na
var int lastLowBar  = na
var int trend = 0
var int lastLabelBar = na

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

if not na(ph)
    lastHigh := ph
    lastHighBar := bar_index - swingLen

if not na(pl)
    lastLow := pl
    lastLowBar := bar_index - swingLen

bullBreak = not na(lastHigh) and close > lastHigh and close[1] <= lastHigh
bearBreak = not na(lastLow) and close < lastLow and close[1] >= lastLow

canDraw = na(lastLabelBar) or (bar_index - lastLabelBar > minSpacing)

if showBOS and bullBreak and canDraw
    mid = lastHighBar + int((bar_index - lastHighBar)/2)
    isCHOCH = trend == -1
    line.new(lastHighBar, lastHigh, bar_index, lastHigh, color=isCHOCH ? chochColor : bosColor)
    label.new(mid, lastHigh, text=isCHOCH ? "CHOCH" : "BOS", style=label.style_none, textcolor=isCHOCH ? chochColor : bosColor, size=size.tiny)
    trend := 1
    lastLabelBar := bar_index

if showBOS and bearBreak and canDraw
    mid = lastLowBar + int((bar_index - lastLowBar)/2)
    isCHOCH = trend == 1
    line.new(lastLowBar, lastLow, bar_index, lastLow, color=isCHOCH ? chochColor : bosColor)
    label.new(mid, lastLow, text=isCHOCH ? "CHOCH" : "BOS", style=label.style_none, textcolor=isCHOCH ? chochColor : bosColor, size=size.tiny)
    trend := -1
    lastLabelBar := bar_index

// =====================
// CISD (CONFIRMED)
// =====================
m1o = request.security(syminfo.tickerid, "1", open)
m1c = request.security(syminfo.tickerid, "1", close)

m3o = request.security(syminfo.tickerid, "3", open)
m3c = request.security(syminfo.tickerid, "3", close)

m5o = request.security(syminfo.tickerid, "5", open)
m5c = request.security(syminfo.tickerid, "5", close)

body = math.abs(close - open)
Colorrange = high - low
strong = body > Colorrange * 0.6

bullCISD = strong and ((m1c > m1o and m1c[1] < m1o[1]) or (m3c > m3o and m3c[1] < m3o[1]) or (m5c > m5o and m5c[1] < m5o[1]))
bearCISD = strong and ((m1c < m1o and m1c[1] > m1o[1]) or (m3c < m3o and m3c[1] > m3o[1]) or (m5c < m5o and m5c[1] > m5o[1]))

var line[] cisdArr = array.new_line()
var int lastCISDBar = na

newSignal = (bullCISD or bearCISD) and barstate.isconfirmed and (na(lastCISDBar) or bar_index != lastCISDBar)

if showCISD and newSignal
    priceLevel = bullCISD ? high : low

    l = line.new(bar_index, priceLevel, bar_index + (extendCISD_toggle ? cisdExtendBars : cisdExtend), priceLevel, color=color.yellow, width=2)

    array.push(cisdArr, l)
    lastCISDBar := bar_index

if array.size(cisdArr) > maxCISD
    old = array.shift(cisdArr)
    line.delete(old)

//// =====================
// FVG → IFVG (SMART)
// =====================
bullFVG = low > high[2]
bearFVG = high < low[2]

gapBull = low - high[2]
gapBear = low[2] - high

validBull = bullFVG and gapBull > minGapSize
validBear = bearFVG and gapBear > minGapSize

var box[] bullFVGs = array.new_box()
var box[] bearFVGs = array.new_box()

// NEW: IFVG STORAGE (MAX 3)
var box[] bullIFVGs = array.new_box()
var box[] bearIFVGs = array.new_box()

// CREATE FVG
if showFVG and validBull
    b = box.new(bar_index - 2, high[2], bar_index + (extendFVG_toggle ? extendFVG_bars : 1), low, bgcolor=color.new(color.green, 85))
    array.push(bullFVGs, b)

if showFVG and validBear
    b = box.new(bar_index - 2, high, bar_index + (extendFVG_toggle ? extendFVG_bars : 1), low[2], bgcolor=color.new(color.red, 85))
    array.push(bearFVGs, b)

// FOLLOW
if array.size(bullFVGs) > 0
    for i = 0 to array.size(bullFVGs) - 1
        box.set_right(array.get(bullFVGs, i), bar_index + (extendFVG_toggle ? extendFVG_bars : 1))

if array.size(bearFVGs) > 0
    for i = 0 to array.size(bearFVGs) - 1
        box.set_right(array.get(bearFVGs, i), bar_index + (extendFVG_toggle ? extendFVG_bars : 1))

// =====================
// MITIGATION → IFVG
// =====================
if array.size(bullFVGs) > 0
    for i = array.size(bullFVGs) - 1 to 0
        b = array.get(bullFVGs, i)

        if low <= box.get_top(b)
            // convert to IFVG (orange)
            box.set_bgcolor(b, color.new(color.orange, 80))

            array.push(bullIFVGs, b)
            array.remove(bullFVGs, i)

            // keep only 3 IFVG
            if array.size(bullIFVGs) > 3
                old = array.shift(bullIFVGs)
                box.delete(old)

if array.size(bearFVGs) > 0
    for i = array.size(bearFVGs) - 1 to 0
        b = array.get(bearFVGs, i)

        if high >= box.get_bottom(b)
            box.set_bgcolor(b, color.new(color.orange, 80))

            array.push(bearIFVGs, b)
            array.remove(bearFVGs, i)

            if array.size(bearIFVGs) > 3
                old = array.shift(bearIFVGs)
                box.delete(old)
plot(na)
````
