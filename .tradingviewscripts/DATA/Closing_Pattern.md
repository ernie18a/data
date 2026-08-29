<!-- tradingview-pine-id: PUB;41c6c947396c4e2aa8d29508eb4a8a26 -->
<!-- tradingviewscripts-format: 1 -->
# Closing Pattern

Source: https://www.tradingview.com/script/8jyrVGDc-Closing-Pattern/

## Description

Closing pattern:

Shows D1 and 12H directional bias in a table, based on the last candle that closed outside the full range (incl. wicks) of the previous candle. Adds a separate, configurable alert (any timeframe, any direction) that fires once, exactly on confirmed candle close, with push-ready...

Improvements over the original S&D Direction:
- Fixed lookback counting: scans actual bars of the target timeframe (D1/12H), not bars of whatever chart timeframe you're viewing from — same signal regardless of chart view.
- Fixed lookahead handling: closed-bar values only, no intrabar flicker on freshly forming candles.
- Added a real alert layer: original script only displayed a table, couldn't trigger notifications at all.
- Alert works correctly whether its timeframe matches the chart's or not (dedicated same-timeframe path avoids the off-by-one marker shift MTF logic caused).
- Simplified from five generic TF slots to the two timeframes actually needed, plus a separately configurable alert timeframe.

All praises to Liqva.

---

## Source Code

````pine
//@version=6
indicator("Closing Pattern", overlay=true, dynamic_requests=true)

// ================= Direction table: D1 + 12H =================
lookbackBars = input.int(50, "Direction lookback (bars)", minval=5, maxval=500)

f_scanDirection(int n) =>
    int dir = 0
    for i = 0 to n - 1
        cc = close[i + 1]
        hh = high[i + 2]
        ll = low[i + 2]
        if not na(cc) and not na(hh) and cc > hh
            dir := 1
            break
        if not na(cc) and not na(ll) and cc < ll
            dir := -1
            break
    dir

getDirection(tf, n) =>
    request.security(syminfo.tickerid, tf, f_scanDirection(n), lookahead=barmerge.lookahead_on)

var color longColor  = color.rgb(76, 175, 79)
var color shortColor = color.rgb(244, 67, 54)
var color neutralCol = color.new(color.white, 40)
col(dir) => dir == 1 ? longColor : dir == -1 ? shortColor : neutralCol

dir_D1  = getDirection("D", lookbackBars)
dir_12H = getDirection("720", lookbackBars)

var table dirTable = table.new(position.top_right, 1, 2, bgcolor=#00000000, border_width=0)
table.cell(dirTable, 0, 0, "D1 Direction",  text_color=col(dir_D1),  text_size=size.normal)
table.cell(dirTable, 0, 1, "12H Direction", text_color=col(dir_12H), text_size=size.normal)

// ================= Discrete alert: any timeframe =================
alertTf  = input.timeframe("240", "Alert timeframe (240 = 4 hours)")
dirInput = input.string("Both", "Alert direction", options=["Below", "Above", "Both"])

alertBelowOn = dirInput == "Below" or dirInput == "Both"
alertAboveOn = dirInput == "Above" or dirInput == "Both"

sameTf = timeframe.in_seconds(alertTf) == timeframe.in_seconds(timeframe.period)

secClose = request.security(syminfo.tickerid, alertTf, close[1], lookahead=barmerge.lookahead_on)
secHigh  = request.security(syminfo.tickerid, alertTf, high[2],  lookahead=barmerge.lookahead_on)
secLow   = request.security(syminfo.tickerid, alertTf, low[2],   lookahead=barmerge.lookahead_on)
secTime  = request.security(syminfo.tickerid, alertTf, time[1],  lookahead=barmerge.lookahead_on)

isNewHtfBar = not na(secTime) and secTime != secTime[1]

signalBelowMtf  = alertBelowOn and isNewHtfBar and secClose < secLow
signalAboveMtf  = alertAboveOn and isNewHtfBar and secClose > secHigh

signalBelowSame = alertBelowOn and barstate.isconfirmed and close < low[1]
signalAboveSame = alertAboveOn and barstate.isconfirmed and close > high[1]

signalBelow = sameTf ? signalBelowSame : signalBelowMtf
signalAbove = sameTf ? signalAboveSame : signalAboveMtf

plotshape(signalBelow, title="Close Below Previous Range", location=location.belowbar, style=shape.triangledown, color=color.red,   size=size.tiny)
plotshape(signalAbove, title="Close Above Previous Range", location=location.abovebar, style=shape.triangleup,  color=color.green, size=size.tiny)

alertcondition(signalBelow, title="Close Below Previous Range", message="{{ticker}} closed below the previous {{interval}} candle range")
alertcondition(signalAbove, title="Close Above Previous Range", message="{{ticker}} closed above the previous {{interval}} candle range")
````
