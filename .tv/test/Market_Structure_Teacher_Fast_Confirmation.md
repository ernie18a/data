<!-- tradingview-pine-id: PUB;230b5ed1c14e4f52bb7f8b6eb1954d8e -->
<!-- tradingviewscripts-format: 1 -->
# Market Structure Teacher — Fast Confirmation

Source: https://www.tradingview.com/script/qgJjAgtW-Market-structure-framework/

## Description

This is a beginner-friendly market structure indicator designed to help identify market structure on any chart. 

This indicator confirms Higher Highs (HH), Higher Lows (HL), Lower Highs (LH), and Lower Lows (LL), making it easier to understand weather price is trending or rangebound.

---

## Source Code

````pine
//@version=6
indicator("Market Structure Teacher — Fast Confirmation", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ── Pivot timing ──
// A strong left side keeps pivots meaningful.
// A shorter right side confirms them more quickly.
leftBars = input.int(7, "Swing strength", minval = 2,
     tooltip = "Bars required before a pivot. Higher values find more significant swings.")

rightBars = input.int(3, "Confirmation bars", minval = 1,
     tooltip = "Bars required after a pivot. Lower values make labels appear sooner.")

// ── Noise filter ──
atrLength = input.int(14, "ATR length", minval = 1)

minimumMoveATR = input.float(1.0, "Minimum swing size (ATR)", minval = 0.1, step = 0.1,
     tooltip = "A pivot must move this many ATRs from the previous accepted pivot. Increase it to reduce noise.")

// ── Display settings ──
showPullbacks = input.bool(true, "Show HL and LH pullbacks",
     tooltip = "Shows the complete HH, HL, LH, and LL structure sequence.")

showLines = input.bool(true, "Connect meaningful swings")
showStatus = input.bool(true, "Show market status")

// ── Chop / trend settings ──
adxLength = input.int(14, "Trend-strength length", minval = 2)
chopThreshold = input.float(20.0, "Chop threshold", minval = 5, maxval = 50, step = 0.5)

// ── Market regime ──
[_, _, adx] = ta.dmi(adxLength, adxLength)
isChoppy = adx < chopThreshold

// ── Confirmed pivots ──
swingHigh = ta.pivothigh(high, leftBars, rightBars)
swingLow = ta.pivotlow(low, leftBars, rightBars)
atrAtPivot = ta.atr(atrLength)[rightBars]

var float previousHigh = na
var float previousLow = na
var float lastAcceptedPivotPrice = na
var int lastAcceptedPivotBar = na

bullishColor = color.rgb(0, 160, 100)
bearishColor = color.rgb(210, 65, 65)
neutralColor = color.rgb(110, 110, 120)
chopColor = color.rgb(220, 145, 0)

isMeaningful(_price) =>
    na(lastAcceptedPivotPrice) or math.abs(_price - lastAcceptedPivotPrice) >= atrAtPivot * minimumMoveATR

drawStructure(_bar, _price, _text, _color, _isHigh) =>
    label.new(
         _bar, _price, _text,
         yloc = _isHigh ? yloc.abovebar : yloc.belowbar,
         style = _isHigh ? label.style_label_down : label.style_label_up,
         color = _color,
         textcolor = color.white,
         size = size.small
     )

// ── Swing highs: HH or LH ──
if not na(swingHigh) and isMeaningful(swingHigh)
    pivotBar = bar_index - rightBars
    structure = na(previousHigh) ? "SH" : swingHigh > previousHigh ? "HH" : "LH"
    labelColor = structure == "HH" ? bullishColor : structure == "LH" ? bearishColor : neutralColor

    if structure != "SH" and (structure != "LH" or showPullbacks)
        drawStructure(pivotBar, swingHigh, structure, labelColor, true)

    if showLines and not na(lastAcceptedPivotPrice)
        line.new(
             lastAcceptedPivotBar, lastAcceptedPivotPrice,
             pivotBar, swingHigh,
             xloc = xloc.bar_index,
             color = color.new(labelColor, 35),
             width = 2
         )

    previousHigh := swingHigh
    lastAcceptedPivotPrice := swingHigh
    lastAcceptedPivotBar := pivotBar

// ── Swing lows: HL or LL ──
if not na(swingLow) and isMeaningful(swingLow)
    pivotBar = bar_index - rightBars
    structure = na(previousLow) ? "SL" : swingLow > previousLow ? "HL" : "LL"
    labelColor = structure == "HL" ? bullishColor : structure == "LL" ? bearishColor : neutralColor

    if structure != "SL" and (structure != "HL" or showPullbacks)
        drawStructure(pivotBar, swingLow, structure, labelColor, false)

    if showLines and not na(lastAcceptedPivotPrice)
        line.new(
             lastAcceptedPivotBar, lastAcceptedPivotPrice,
             pivotBar, swingLow,
             xloc = xloc.bar_index,
             color = color.new(labelColor, 35),
             width = 2
         )

    previousLow := swingLow
    lastAcceptedPivotPrice := swingLow
    lastAcceptedPivotBar := pivotBar

// ── Compact market-status badge ──
var table status = table.new(position.top_right, 1, 1, border_width = 1)

if barstate.islast
    if showStatus
        statusText = isChoppy ? "Market: CHOPPY — wait for clear structure" : "Market: TRENDING — follow major swings"
        statusColor = isChoppy ? chopColor : bullishColor
        table.cell(status, 0, 0, statusText, text_color = color.white, bgcolor = statusColor)
    else
        table.clear(status, 0, 0, 0, 0)
````
