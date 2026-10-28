# Lion Share Trading (Structure)

- url: https://www.tradingview.com/script/llNOIbcG-Lion-Share-Trading-Structure/
- type: indicator
- pine_id: PUB;4cc48ae15b35427ab219c354b448e8b5
- version: 1.0

## Description

The Lion Share Academy Indicator is designed to simplify the trading process by combining two essential components of our edge: market structure and daily directional bias.

This tool automatically analyzes yesterday’s price range and determines whether the market has broken above yesterday’s high or below yesterday’s low, establishing a clear directional bias for the trading day.

At the same time, the indicator highlights Higher Highs (HH), Higher Lows (HL), Lower Highs (LH), and Lower Lows (LL) directly on the chart, allowing traders to quickly visualize market structure and trend development.

The goal of this indicator is not to generate signals, but to provide clarity and discipline by helping traders focus only on the direction the market has chosen for the day.

Features include:

• Clear Bullish / Bearish / No Break dashboard
• Market structure labeling (HH, HL, LH, LL)
• Clean visual design for minimal chart clutter

This tool is built around the Lion Share Academy trading framework, where traders first determine the daily bias and then execute setups aligned with that direction.

⚠️ This indicator is intended exclusively for Lion Share Academy students and educational purposes.

## Source Code

````pine
//@version=5
indicator("Lion Share Academy", overlay=true)

// ==============================
// STRUCTURE SETTINGS
// ==============================

lb = input.int(5, "Left Bars", minval=1)
rb = input.int(5, "Right Bars", minval=1)

// ==============================
// PIVOT DETECTION
// ==============================

ph = ta.pivothigh(high, lb, rb)
pl = ta.pivotlow(low, lb, rb)

// ==============================
// PREVIOUS PIVOTS
// ==============================

var float lastHigh = na
var float lastLow = na

// ==============================
// STRUCTURE LOGIC
// ==============================

hh = false
hl = false
lh = false
ll = false

if not na(ph)
    hh := na(lastHigh) ? false : ph > lastHigh
    lh := na(lastHigh) ? false : ph < lastHigh
    lastHigh := ph

if not na(pl)
    hl := na(lastLow) ? false : pl > lastLow
    ll := na(lastLow) ? false : pl < lastLow
    lastLow := pl

// ==============================
// STRUCTURE LABELS
// ==============================

plotshape(hh, title="Higher High", text="HH", style=shape.labeldown, color=color.green, textcolor=color.white, location=location.abovebar, offset=-rb)

plotshape(hl, title="Higher Low", text="HL", style=shape.labelup, color=color.green, textcolor=color.white, location=location.belowbar, offset=-rb)

plotshape(lh, title="Lower High", text="LH", style=shape.labeldown, color=color.red, textcolor=color.white, location=location.abovebar, offset=-rb)

plotshape(ll, title="Lower Low", text="LL", style=shape.labelup, color=color.red, textcolor=color.white, location=location.belowbar, offset=-rb)

// ==============================
// DAILY LEVELS
// ==============================

yHigh = request.security(syminfo.tickerid, "D", high[1])
yLow  = request.security(syminfo.tickerid, "D", low[1])

// ==============================
// DAILY BREAK MEMORY
// ==============================

newDay = ta.change(time("D"))

var int bias = 0

if newDay
    bias := 0

if bias == 0
    if high > yHigh
        bias := 1
    else if low < yLow
        bias := -1

// ==============================
// BIAS TEXT
// ==============================

biasText =
     bias == 1 ? "BULLISH" :
     bias == -1 ? "BEARISH" :
     "NO DAILY BREAK"

// ==============================
// BIAS COLORS
// ==============================

biasColor =
     bias == 1 ? color.rgb(0,150,80) :
     bias == -1 ? color.rgb(180,40,40) :
     color.rgb(90,90,90)

headerColor = color.rgb(30,30,30)

// ==============================
// DISPLAY BIAS DASHBOARD
// ==============================

var table biasTable = table.new(position.top_right, 1, 3)

if barstate.islast

    table.cell(
         biasTable,
         0,
         0,
         "LION SHARE ACADEMY",
         bgcolor=headerColor,
         text_color=color.white,
         text_size=size.normal)

    table.cell(
         biasTable,
         0,
         1,
         "DAILY BIAS",
         bgcolor=headerColor,
         text_color=color.silver,
         text_size=size.small)

    table.cell(
         biasTable,
         0,
         2,
         biasText,
         bgcolor=biasColor,
         text_color=color.white,
         text_size=size.large)
````
