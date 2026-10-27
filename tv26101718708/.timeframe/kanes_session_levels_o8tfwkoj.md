# Kane's Session Levels

- url: https://www.tradingview.com/script/o8tfwkoj-Kane-s-Session-Levels/
- type: indicator
- pine_id: PUB;f2955a9151624c2e857de1a22f040d1f
- version: 1.0

## Description

**Kane’s Session Levels** plots the most important overnight and previous-day reference levels as clean horizontal lines with right-side labels designed for intraday trading.

Includes:

* Overnight High (ONH)
* Overnight Low (ONL)
* Previous Day High (PDH)
* Previous Day Low (PDL)

Features:

* Clean horizontal level plotting
* Right-side price labels
* Custom colors
* Adjustable line width
* Adjustable label distance
* Minimal chart clutter
* Institutional-style layout focused on key liquidity and reaction levels

Designed for:

* Index Futures
* Gold & Silver Futures
* Oil Futures
* Forex
* Any intraday market with session-based trading

Best used for:

* Liquidity sweeps
* Support & resistance reactions
* Overnight range analysis
* Previous day range reactions
* Intraday bias
* High probability trade location mapping

## Source Code

````pine
//@version=6
indicator("Kane's Session Levels", overlay=true, max_lines_count=50, max_labels_count=50)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tz = input.string("America/New_York", "Timezone")

showONH = input.bool(true, "Overnight High")
showONL = input.bool(true, "Overnight Low")
showPDH = input.bool(true, "Previous Day High")
showPDL = input.bool(true, "Previous Day Low")

labelOffset = input.int(20, "Label Offset Bars", minval=1, maxval=200)
lineBackBars = input.int(500, "Line Back Bars", minval=50, maxval=5000)
lineWidth = input.int(1, "Line Width", minval=1, maxval=5)

onhColor = input.color(color.red, "Overnight High Color")
onlColor = input.color(color.lime, "Overnight Low Color")
pdhColor = input.color(color.red, "Prev Day High Color")
pdlColor = input.color(color.lime, "Prev Day Low Color")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Previous Day Levels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Overnight High / Low
// Session: 6:00 PM → 9:30 AM NY
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
// Horizontal Level Function
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
f_level(showONH, finalONH, "ONH", onhColor)
f_level(showONL, finalONL, "ONL", onlColor)

f_level(showPDH, pdh, "PDH", pdhColor)
f_level(showPDL, pdl, "PDL", pdlColor)
````
