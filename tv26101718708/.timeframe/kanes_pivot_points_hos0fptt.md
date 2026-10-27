# Kane's Pivot Points

- url: https://www.tradingview.com/script/hos0fPTt-Kane-s-Pivot-Points/
- type: indicator
- pine_id: PUB;615a9c96231648bf99dbdb7931849d1f
- version: 1.0

## Description

**Kane’s Pivot Points** plots key higher-timeframe levels and session reference levels as clean horizontal price zones with right-side labels designed for intraday futures trading.

Includes:

* Daily 50 SMA
* Daily 200 SMA
* 4H 50 SMA
* 4H 200 SMA
* 1H 50 SMA
* 1H 200 SMA
* Overnight High (ONH)
* Overnight Low (ONL)
* Previous Day High (PDH)
* Previous Day Low (PDL)
* Opening Price Line

Features:

* Clean horizontal level plotting
* Right-side price labels
* Custom colors
* Adjustable line width
* Adjustable label distance
* Minimal chart clutter
* Institutional-style layout focused on reaction levels and higher timeframe confluence

Designed for:

* Index Futures
* Gold & Silver Futures
* Oil Futures
* Forex
* Any intraday market with session-based trading

Best used for:

* Trend continuation analysis
* Support & resistance reactions
* Liquidity mapping
* Session bias
* Higher timeframe confluence
* Intraday trade location framework

## Source Code

````pine
//@version=6
indicator("Kane's Pivot Points", overlay=true, max_lines_count=100, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tz = input.string("America/New_York", "Timezone")

labelOffset = input.int(20, "Label Offset Bars", minval=1, maxval=200)
lineBackBars = input.int(500, "Line Back Bars", minval=50, maxval=5000)
lineWidth = input.int(1, "Line Width", minval=1, maxval=5)

showD50   = input.bool(true, "Daily 50 SMA")
showD200  = input.bool(true, "Daily 200 SMA")
show4H50  = input.bool(true, "4H 50 SMA")
show4H200 = input.bool(true, "4H 200 SMA")
show1H50  = input.bool(true, "1H 50 SMA")
show1H200 = input.bool(true, "1H 200 SMA")

showONH = input.bool(true, "Overnight High")
showONL = input.bool(true, "Overnight Low")
showPDH = input.bool(true, "Previous Day High")
showPDL = input.bool(true, "Previous Day Low")
showOpen = input.bool(true, "Opening Price Line")

d50Color   = input.color(color.red, "Daily 50 SMA Color")
d200Color  = input.color(color.red, "Daily 200 SMA Color")
h4_50Color = input.color(color.orange, "4H 50 SMA Color")
h4_200Color = input.color(color.orange, "4H 200 SMA Color")
h1_50Color = input.color(color.rgb(255, 100, 140), "1H 50 SMA Color")
h1_200Color = input.color(color.fuchsia, "1H 200 SMA Color")

onhColor = input.color(color.red, "Overnight High Color")
onlColor = input.color(color.lime, "Overnight Low Color")
pdhColor = input.color(color.red, "Prev Day High Color")
pdlColor = input.color(color.lime, "Prev Day Low Color")
openColor = input.color(color.aqua, "Opening Price Line Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Values
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
d50   = request.security(syminfo.tickerid, "D", ta.sma(close, 50))
d200  = request.security(syminfo.tickerid, "D", ta.sma(close, 200))
h4_50 = request.security(syminfo.tickerid, "240", ta.sma(close, 50))
h4_200 = request.security(syminfo.tickerid, "240", ta.sma(close, 200))
h1_50 = request.security(syminfo.tickerid, "60", ta.sma(close, 50))
h1_200 = request.security(syminfo.tickerid, "60", ta.sma(close, 200))

pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Overnight High / Low
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inON = not na(time(timeframe.period, "1800-0930", tz))
newON = inON and not inON[1]

var float onh = na
var float onl = na
var float finalONH = na
var float finalONL = na

if newON
    onh := high
    onl := low

if inON
    onh := math.max(onh, high)
    onl := math.min(onl, low)

if not inON and inON[1]
    finalONH := onh
    finalONL := onl

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Opening Price
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inOpenMinute = not na(time(timeframe.period, "0930-0931", tz))

var float openPrice = na

if inOpenMinute and not inOpenMinute[1]
    openPrice := open

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Draw Horizontal Level Function
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_level(_show, _price, _txt, _col) =>
    var line ln = na
    var label lb = na

    if barstate.islast
        line.delete(ln)
        label.delete(lb)

        if _show and not na(_price)
            ln := line.new(
                 bar_index - lineBackBars,
                 _price,
                 bar_index + labelOffset,
                 _price,
                 color=_col,
                 width=lineWidth)

            lb := label.new(
                 bar_index + labelOffset,
                 _price,
                 str.tostring(_price, format.mintick) + " " + _txt,
                 style=label.style_label_left,
                 color=_col,
                 textcolor=color.white,
                 size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Draw Levels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_level(showD50, d50, "D 50", d50Color)
f_level(showD200, d200, "D 200", d200Color)

f_level(show4H50, h4_50, "4H 50", h4_50Color)
f_level(show4H200, h4_200, "4H 200", h4_200Color)

f_level(show1H50, h1_50, "1H 50", h1_50Color)
f_level(show1H200, h1_200, "1H 200", h1_200Color)

f_level(showONH, finalONH, "ONH", onhColor)
f_level(showONL, finalONL, "ONL", onlColor)

f_level(showPDH, pdh, "PDH", pdhColor)
f_level(showPDL, pdl, "PDL", pdlColor)

f_level(showOpen, openPrice, "OPEN", openColor)
````
