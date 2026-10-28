# Bollinger Band [scoopup]

- url: https://www.tradingview.com/script/7USguXkV/
- type: indicator
- pine_id: PUB;dc2c4c6f5a8d4e869a8be4aa9d1d2ce0
- version: 1.0

## Description

Overview
A Bollinger Bands–based indicator that shows trend direction (up/down) through the basis line color, displays band width (volatility) as a percentage, and marks the most recent meaningful lows (demand zones) on the weekly and daily timeframes as boxes. It lets you view statistical volatility and the real low zones where buying previously stepped in — all on a single chart.

Default settings are Length 21 and StdDev 1.618, based on the Fibonacci number (21) and the golden ratio (1.618).

Components
1. Bollinger Bands (Upper / Basis / Lower)

Defaults: Length 21, StdDev 1.618
Upper band, basis (middle), and lower band. The bands widen and narrow with volatility.
2. Basis Line Trend Color (Daily-based)

The color of the middle basis line indicates trend direction.
Logic: over a set lookback, it compares the cumulative size of the "close-to-lower" area (red) versus the "upper-to-close" area (green).
Red area dominant → uptrend → basis line GREEN
Green area dominant → downtrend → basis line RED
The longer the close stays near the lower band (larger red area), the more it is read as base-building before a move higher.
This color is always calculated from Daily data, regardless of the chart timeframe. Whether you view it on the 15m, 1h, or 4h chart, the daily trend color stays consistent.
3. Fill

Upper band ↔ close: semi-transparent green
Close ↔ lower band: semi-transparent red
Lets you quickly read where the close sits within the bands.
4. Band Width (%)

Formula: (Upper − Lower) / Basis × 100
Displays the current band width in a corner table as Band Width: X.XX%.
Lower = volatility contraction (squeeze) → often precedes a large move; higher = volatility expansion.
The Data Window also shows band width % and band width (price difference), including on historical bars.
5. Recent Lows

Weekly recent low = yellow box / Daily recent low = red box
Shows only the most recent pivot (swing) low that sits below the current close. (Lows above the close are skipped; if the latest low is above the close, the prior low is used instead.)
Box height spans the low ↔ the close at that point, and extends to the right to show a still-valid support/demand zone.
How to Read It
Basis green + close near the lower band → watch for a potential bounce after base-building.
Basis red + close near the upper band → watch for overextension/pullback risk.
Band Width % contracting (squeeze) → watch for an upcoming volatility expansion.
Recent low boxes (yellow/red) act as first support candidates on a pullback. A close below the box signals support failure.
Key Settings
Bollinger Bands: Source, Length (default 21), StdDev (default 1.618), Band Color / Width / Style
Basis Line: Show Basis, Basis Width, Ratio Length, Up / Down Color
Fill: Show Fill, Upper / Lower Fill Transparency
Band Width: Show Band Width %, Table Position, Text Size
Recent Lows: weekly/daily toggles, Pivot Length, Box Color
Tips
This is a supporting tool for reading trend direction + volatility + support zones together, not a standalone trade signal.
Reliability increases when the daily trend color and a recent low box line up in the same area.
Adjust StdDev and Ratio Length to fit each instrument's volatility.
Disclaimer
This indicator is for reference only and does not guarantee trading profits. All trading decisions and responsibility rest solely with the user.

## Source Code

````pine
//@version=6
indicator("Bollinger Band [scoopup]", overlay=true, max_boxes_count=20)

// ===== Inputs =====
src    = input.source(close, "Source",  group="Bollinger Bands")
length = input.int(21, "Length", minval=1, group="Bollinger Bands")
mult   = input.float(1.618, "StdDev", minval=0.1, step=0.1, group="Bollinger Bands")

bandColor    = input.color(#2962FF, "Band Color", group="Bollinger Bands")
bandWidth    = input.int(1, "Band Width", minval=1, maxval=5, group="Bollinger Bands")
bandStyleStr = input.string("Line", "Band Style", options=["Line","Step Line","Circles"], group="Bollinger Bands")

showBasis  = input.bool(true, "Show Basis", group="Basis Line")
basisWidth = input.int(2, "Basis Width", minval=1, maxval=5, group="Basis Line")
ratioLen   = input.int(20, "Ratio Length", minval=1, group="Basis Line")
upColor    = input.color(color.green, "Up Color",   group="Basis Line")
downColor  = input.color(color.red,   "Down Color", group="Basis Line")

showFill = input.bool(true, "Show Fill", group="Fill")
upFill   = input.int(82, "Upper Fill Transparency", minval=0, maxval=100, group="Fill")
dnFill   = input.int(82, "Lower Fill Transparency", minval=0, maxval=100, group="Fill")

showBW   = input.bool(true, "Show Band Width %", group="Band Width")
bwPosStr = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Band Width")
bwSizeStr= input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large"], group="Band Width")

showW = input.bool(true, "Show Weekly Lows", group="Recent Lows")
pivW  = input.int(5, "Weekly Pivot Length", minval=1, group="Recent Lows")
colW  = input.color(color.new(color.yellow, 75), "Weekly Box Color", group="Recent Lows")
showD = input.bool(true, "Show Daily Lows", group="Recent Lows")
pivD  = input.int(5, "Daily Pivot Length", minval=1, group="Recent Lows")
colD  = input.color(color.new(color.red, 75), "Daily Box Color", group="Recent Lows")

// ===== Bollinger Bands (chart timeframe) =====
basis = ta.sma(src, length)
dev   = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

// ===== Band Width % = (upper - lower) / basis * 100 =====
bandWidthPct = basis != 0 ? (upper - lower) / basis * 100 : na

// ===== Daily area-ratio trend (timeframe independent) =====
redRatioDaily() =>
    float b  = ta.sma(close, length)
    float dv = mult * ta.stdev(close, length)
    float u  = b + dv
    float l  = b - dv
    float rA = math.max(0.0, close - l)   // red area (close to lower)
    float gA = math.max(0.0, u - close)   // green area (upper to close)
    float sR = math.sum(rA, ratioLen)
    float sG = math.sum(gA, ratioLen)
    (sR + sG) > 0 ? sR / (sR + sG) : 0.5

float dRedRatio  = request.security(syminfo.tickerid, "D", redRatioDaily(), lookahead=barmerge.lookahead_off)
bool  isUp       = dRedRatio > 0.5        // red area dominant = trending up
color basisColor = isUp ? upColor : downColor

// ===== Band style mapping =====
bandStyle = bandStyleStr == "Step Line" ? plot.style_stepline : bandStyleStr == "Circles" ? plot.style_circles : plot.style_line

// ===== Plots =====
uP   = plot(upper, "Upper", color=color.new(bandColor, 0), linewidth=bandWidth, style=bandStyle)
bP   = plot(showBasis ? basis : na, "Basis", color=basisColor, linewidth=basisWidth)
lP   = plot(lower, "Lower", color=color.new(bandColor, 0), linewidth=bandWidth, style=bandStyle)
cRef = plot(close, "Close Ref", color=na, editable=false, display=display.none)

fill(uP, cRef, color=showFill ? color.new(upColor, upFill)   : na, title="Upper Fill")
fill(cRef, lP, color=showFill ? color.new(downColor, dnFill) : na, title="Lower Fill")

plot(bandWidthPct, "Band Width %", color=na, display=display.data_window)
plot(upper - lower, "Band Width (price)", color=na, display=display.data_window)

// ===== Band Width % table =====
bwPos = bwPosStr == "Top Left" ? position.top_left : bwPosStr == "Bottom Right" ? position.bottom_right : bwPosStr == "Bottom Left" ? position.bottom_left : position.top_right
bwSize = bwSizeStr == "Tiny" ? size.tiny : bwSizeStr == "Small" ? size.small : bwSizeStr == "Large" ? size.large : size.normal

var table bwTable = table.new(bwPos, 1, 1, border_width=1)
if barstate.islast and showBW
    table.cell(bwTable, 0, 0, "Band Width: " + str.tostring(bandWidthPct, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=bwSize)

// ===== Recent low boxes (Weekly / Daily) =====
pivotData(int L, int R) =>
    float pl = ta.pivotlow(low, L, R)
    [pl, close[R], time[R]]

findSupport(array<float> lows, array<float> clos, array<int> tims, float ref) =>
    float sl = na
    float sc = na
    int   st = na
    int n = array.size(lows)
    if n > 0
        for i = (n - 1) to 0
            if array.get(lows, i) < ref
                sl := array.get(lows, i)
                sc := array.get(clos, i)
                st := array.get(tims, i)
                break
    [sl, sc, st]

updateBox(box bx, bool show, array<float> lows, array<float> clos, array<int> tims, color c) =>
    box result = bx
    [sl, sc, st] = findSupport(lows, clos, tims, close)
    if show and not na(sl)
        if na(result)
            result := box.new(st, math.max(sc, sl), time, math.min(sc, sl), xloc=xloc.bar_time, extend=extend.right, border_color=c, bgcolor=c, border_width=1)
        else
            box.set_lefttop(result, st, math.max(sc, sl))
            box.set_rightbottom(result, time, math.min(sc, sl))
    else
        if not na(result)
            box.delete(result)
            result := na
    result

[wPL, wClose, wTime] = request.security(syminfo.tickerid, "W", pivotData(pivW, pivW), lookahead=barmerge.lookahead_off)
[dPL, dClose, dTime] = request.security(syminfo.tickerid, "D", pivotData(pivD, pivD), lookahead=barmerge.lookahead_off)

var array<float> wLows = array.new<float>()
var array<float> wClos = array.new<float>()
var array<int>   wTims = array.new<int>()
var array<float> dLows = array.new<float>()
var array<float> dClos = array.new<float>()
var array<int>   dTims = array.new<int>()

bool newW = not na(wPL) and (na(wPL[1]) or wPL != wPL[1])
if newW
    array.push(wLows, wPL)
    array.push(wClos, wClose)
    array.push(wTims, wTime)
    if array.size(wLows) > 60
        array.shift(wLows)
        array.shift(wClos)
        array.shift(wTims)

bool newD = not na(dPL) and (na(dPL[1]) or dPL != dPL[1])
if newD
    array.push(dLows, dPL)
    array.push(dClos, dClose)
    array.push(dTims, dTime)
    if array.size(dLows) > 60
        array.shift(dLows)
        array.shift(dClos)
        array.shift(dTims)

var box wBox = na
var box dBox = na
wBox := updateBox(wBox, showW, wLows, wClos, wTims, colW)
dBox := updateBox(dBox, showD, dLows, dClos, dTims, colD)
````
