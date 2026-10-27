# Market Structure Suite [ZOM]

- url: https://www.tradingview.com/script/rfDoIBeQ-Market-Structure-Suite-ZOM/
- type: indicator
- pine_id: PUB;bdda0cd483cb41329dfe09880e1b1c74
- version: 1.0

## Description

[b]Market Structure Suite [ZOM][/b] is a comprehensive, all-in-one technical analysis toolkit designed to help traders visualize price structure, identify trend direction, and locate high-probability continuation and reversal zones.

[b]At its core:[/b] the indicator maps market structure using pivot-based logic to identify higher highs [b](HH)[/b], lower highs [b](LH)[/b], higher lows [b](HL)[/b], and lower lows [b](LL)[/b]. These structural shifts are dynamically connected with a pathing system, allowing users to clearly see the evolving trend and momentum of the market in real time.

The script introduces a retracement-based entry model, where signals are only triggered after price pulls back a defined percentage of the current structural leg. This approach encourages entering on value rather than chasing momentum, aligning with disciplined trading practices.
Beyond structure, the suite integrates a wide range of optional tools to provide deeper market context, including:

- Previous day, week, and month high/low levels for key liquidity zones
- ATR-based volatility bands to highlight expansion and exhaustion
- Anchor VWAP tied to structural pivots for dynamic fair value tracking
- RSI divergence detection for early reversal signals
- Bollinger/Keltner squeeze detection for identifying breakout conditions
- Liquidity sweep labeling to highlight stop-runs and reversals
- Session and killzone visualization for timing market activity
- Round number highlighting for psychological levels
- Initial balance range for intraday structure
- A built-in multi-timeframe dashboard provides higher timeframe trend alignment, alongside additional metrics such as ADR, ADX strength, correlation, and volume spikes. This allows traders to quickly assess whether conditions support continuation or caution.

The indicator is highly customizable, enabling users to toggle features on or off depending on their trading style — whether focused on pure structure, intraday execution, or broader contextual analysis.

This tool is designed to act as a unified decision-support system, combining structure, volatility, momentum, and liquidity concepts into a single streamlined interface.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quant

//@version=6
indicator("Market Structure Suite [ZOM]", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

macroLookback = input.int(12, "Trend Sensitivity", minval = 5, tooltip = "Adjusts the sensitivity for identifying major market pivots (HH, LL, HL, LH). Higher values filter minor fluctuations to show long-term trends, while lower values reveal short-term cycles.")
retracementReq = input.float(0.382, "Entry Retracement %", minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "The minimum percentage price must retracement from the recent high/low before a trend continuation signal (B/S) can fire. This ensures you enter on value pullbacks rather than chasing at the top.")

bullColor = input.color(#089981, "Bullish Color", tooltip = "Defines the visual color for bullish structural elements and signals.")
bearColor = input.color(#f23645, "Bearish Color", tooltip = "Defines the visual color for bearish structural elements and signals.")
pathColor = input.color(color.new(color.gray, 60), "Path Color", tooltip = "The color of the diagonal path connecting structural pivots.")

showFib        = input.bool(false, "Show Fibonacci Levels", tooltip = "Draws automated Fibonacci retracement levels (0, 0.5, 1) across the current structural leg to visualize key reversal zones.")
showPDHL       = input.bool(true, "Show Prev Day High/Low", tooltip = "Draws horizontal dashed lines at the high and low of the previous trading day. These are critical liquidity pools where institutional orders are often triggered.")
showPWHL       = input.bool(false, "Show Prev Week High/Low", tooltip = "Draws horizontal lines at the previous week's high and low. These represent major psychological and structural support/resistance levels.")
showPMHL       = input.bool(false, "Show Prev Month High/Low", tooltip = "Highlights the high and low of the previous month. These are long-term institutional reference points for quarterly and yearly trend direction.")
showIB         = input.bool(false, "Show Initial Balance (1H)", tooltip = "Highlights the range established during the first hour of the trading day. Breaking this range often dictates the trend for the remainder of the session.")
showVWAP       = input.bool(false, "Show Anchor VWAP", tooltip = "Plots a Volume Weighted Average Price (VWAP) that resets at every confirmed structural pivot. It represents the fair value of the current expansion leg.")
showMTF        = input.bool(true, "Show Multi-Timeframe Trend", tooltip = "Displays a matrix dashboard in the bottom-right corner showing the trend bias of two higher timeframes to ensure multi-timeframe alignment.")
showVolatility = input.bool(true, "Show Volatility Bands", tooltip = "Draws ATR-based bands around the price. These bands help identify points of extreme volatility where pullbacks or reversals are statistically likely.")
showDailyOpen  = input.bool(false, "Show Daily Open Level", tooltip = "Draws a dotted line at the current day's opening price. Price relative to this level often determines intraday bullish or bearish sentiment.")
showSessions   = input.bool(false, "Show Market Sessions", tooltip = "Highlights the New York (Blue) and London (Orange) full trading sessions on the background.")
showRound      = input.bool(false, "Show Round Numbers", tooltip = "Highlights round psychological numbers (e.g., .00 levels). Markets often find support or resistance at these clean mathematical levels.")
showSqueeze    = input.bool(true, "Show Squeeze Detection", tooltip = "Displays circles at the bottom of the chart when Bollinger Bands contract within Keltner Channels, indicating an imminent explosive move.")
showDiv        = input.bool(true, "Show RSI Divergence", tooltip = "Identifies discrepancies between price action and RSI momentum. Bullish/Bearish divergence often signals an upcoming trend reversal.")
showADR        = input.bool(true, "Show ADR Dashboard", tooltip = "Calculates and displays the Average Daily Range (ADR) and trend strength (ADX) to help set realistic targets and gauge market momentum.")
showPivots     = input.bool(false, "Show Monthly Pivots", tooltip = "Draws standard monthly pivot points (P, R1, S1) based on the previous month's price action for high-timeframe institutional targets.")
showSweeps     = input.bool(true, "Show Liquidity Sweeps", tooltip = "Labels instances where price briefly breaks a daily high/low only to reverse. This signals a 'liquidity grab' or stop-run by institutional players.")
showKillZones  = input.bool(false, "Show Market Killzones", tooltip = "Highlights the high-volatility opening windows for the NY (08:30-11:00) and London (02:30-05:00) sessions where major moves often begin.")

htf1 = input.timeframe("60", "HTF 1", tooltip = "The higher timeframe used for the first matrix bias calculation (e.g., 60 for 1-hour).")
htf2 = input.timeframe("240", "HTF 2", tooltip = "The higher timeframe used for the second matrix bias calculation (e.g., 240 for 4-hour).")
correlSymbol = input.symbol("SPY", "Correlation Ticker", tooltip = "The external ticker used to calculate the real-time correlation displayed in the dashboard.")

[pdh, pdl, pdc] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)
dayOpenVal = request.security(syminfo.tickerid, "D", open, lookahead = barmerge.lookahead_on)
adrVal = request.security(syminfo.tickerid, "D", ta.sma(high - low, 14))
correlClose = request.security(correlSymbol, timeframe.period, close)
[h1_htf, l1_htf] = request.security(syminfo.tickerid, htf1, [high, low])
[h2_htf, l2_htf] = request.security(syminfo.tickerid, htf2, [high, low])

type PivotPoint
    int   time
    float price
    bool  isHigh
    string label

var PivotPoint[] pivots = array.new<PivotPoint>()
var chart.point[] pathPoints = array.new<chart.point>()
var polyline zigzagPath = na
var int trendBias = 0 
var float lastHighPrice = na
var float lastLowPrice  = na
var bool signalPossible = false

ph = ta.pivothigh(macroLookback, macroLookback)
pl = ta.pivotlow(macroLookback, macroLookback)

if not na(ph)
    string lbl = "H"
    if not na(lastHighPrice)
        lbl := ph > lastHighPrice ? "HH" : "LH"
        if ph > lastHighPrice
            trendBias := 1
    lastHighPrice := ph
    PivotPoint newP = PivotPoint.new(time[macroLookback], ph, true, lbl)
    array.push(pivots, newP)
    array.push(pathPoints, chart.point.from_time(newP.time, newP.price))
    signalPossible := true
    label.new(newP.time, newP.price, newP.label, xloc = xloc.bar_time, style = label.style_label_down, color = #00000000, textcolor = newP.label == "HH" ? bullColor : bearColor, size = size.small)
    line.new(newP.time, newP.price, time + 86400000 / 4, newP.price, xloc = xloc.bar_time, color = color.new(bearColor, 80), style = line.style_dotted)
    if not na(zigzagPath)
        polyline.delete(zigzagPath)
    zigzagPath := polyline.new(pathPoints, line_color = pathColor, line_width = 1, xloc = xloc.bar_time)

if not na(pl)
    string lbl = "L"
    if not na(lastLowPrice)
        lbl := pl < lastLowPrice ? "LL" : "HL"
        if pl < lastLowPrice
            trendBias := -1
    lastLowPrice := pl
    PivotPoint newP = PivotPoint.new(time[macroLookback], pl, false, lbl)
    array.push(pivots, newP)
    array.push(pathPoints, chart.point.from_time(newP.time, newP.price))
    signalPossible := true 
    label.new(newP.time, newP.price, lbl, xloc = xloc.bar_time, style = label.style_label_up, color = #00000000, textcolor = lbl == "HL" ? bullColor : bearColor, size = size.small)
    line.new(newP.time, newP.price, time + 86400000 / 4, newP.price, xloc = xloc.bar_time, color = color.new(bullColor, 80), style = line.style_dotted)
    if not na(zigzagPath)
        polyline.delete(zigzagPath)
    zigzagPath := polyline.new(pathPoints, line_color = pathColor, line_width = 1, xloc = xloc.bar_time)

buyTrigger  = false
sellTrigger = false
if signalPossible and not na(lastHighPrice) and not na(lastLowPrice)
    float legR = math.abs(lastHighPrice - lastLowPrice)
    if trendBias == 1
        float pbZ = lastHighPrice - (legR * retracementReq)
        if low < pbZ and close > open and close > high[1]
            buyTrigger := true
            signalPossible := false
    if trendBias == -1
        float pbZ = lastLowPrice + (legR * retracementReq)
        if high > pbZ and close < open and close < low[1]
            sellTrigger := true
            signalPossible := false

if buyTrigger
    label.new(time, low, "B", xloc = xloc.bar_time, color = bullColor, textcolor = color.white, style = label.style_label_up, size = size.small)
if sellTrigger
    label.new(time, high, "S", xloc = xloc.bar_time, color = bearColor, textcolor = color.white, style = label.style_label_down, size = size.small)

var line rtLine = line.new(na, na, na, na, xloc = xloc.bar_time, color = pathColor, style = line.style_dashed)
if pivots.size() > 0
    PivotPoint lp = pivots.get(pivots.size()-1)
    line.set_xy1(rtLine, lp.time, lp.price)
    line.set_xy2(rtLine, time, close)

if showFib and not na(lastHighPrice) and not na(lastLowPrice)
    float fR = math.abs(lastHighPrice - lastLowPrice)
    st = pivots.size() > 1 ? pivots.get(pivots.size()-2).time : (pivots.size() > 0 ? pivots.get(0).time : time)
    line.new(st, trendBias == 1 ? lastHighPrice : lastLowPrice, time, trendBias == 1 ? lastHighPrice : lastLowPrice, xloc = xloc.bar_time, color = color.new(color.gray, 50), style = line.style_dashed)
    line.new(st, trendBias == 1 ? lastHighPrice - fR * 0.5 : lastLowPrice + fR * 0.5, time, trendBias == 1 ? lastHighPrice - fR * 0.5 : lastLowPrice + fR * 0.5, xloc = xloc.bar_time, color = color.new(color.gray, 50), style = line.style_solid)
    line.new(st, trendBias == 1 ? lastLowPrice : lastHighPrice, time, trendBias == 1 ? lastLowPrice : lastHighPrice, xloc = xloc.bar_time, color = color.new(color.gray, 50), style = line.style_dashed)

if showPDHL
    line.new(time - 86400000, pdh, time + 86400000 / 10, pdh, xloc = xloc.bar_time, color = color.new(bearColor, 50), style = line.style_dashed)
    line.new(time - 86400000, pdl, time + 86400000 / 10, pdl, xloc = xloc.bar_time, color = color.new(bullColor, 50), style = line.style_dashed)

if showPWHL
    line.new(time - 86400000 * 7, pwh, time + 86400000, pwh, xloc = xloc.bar_time, color = color.new(bearColor, 20), width = 2)
    line.new(time - 86400000 * 7, pwl, time + 86400000, pwl, xloc = xloc.bar_time, color = color.new(bullColor, 20), width = 2)

if showPMHL
    line.new(time - 86400000 * 30, pmh, time + 86400000 * 5, pmh, xloc = xloc.bar_time, color = color.new(bearColor, 10), width = 3)
    line.new(time - 86400000 * 30, pml, time + 86400000 * 5, pml, xloc = xloc.bar_time, color = color.new(bullColor, 10), width = 3)

is_nd = ta.change(time("D")) != 0
var float ibH = na, var float ibL = na, var int ibS = na
if is_nd
    ibH := na, ibL := na, ibS := time
if showIB and not na(ibS) and time <= ibS + 3600000
    ibH := na(ibH) ? high : math.max(ibH, high)
    ibL := na(ibL) ? low : math.min(ibL, low)
if showIB and not na(ibH)
    line.new(ibS, ibH, time, ibH, xloc = xloc.bar_time, color = color.gray, style = line.style_dashed)
    line.new(ibS, ibL, time, ibL, xloc = xloc.bar_time, color = color.gray, style = line.style_dashed)

var float vsV = 0.0, var float vsPV = 0.0
if not na(ph) or not na(pl)
    vsV := 0.0, vsPV := 0.0
vsV += volume, vsPV += volume * hlc3
plot(showVWAP ? vsPV / vsV : na, "Anchor VWAP", color = color.new(color.orange, 50), linewidth = 2)

atr = ta.atr(14)
uB = ta.sma(close, 20) + atr * 2, lB = ta.sma(close, 20) - atr * 2
plot(showVolatility ? uB : na, "Upper Vol", color = color.new(bearColor, 80)), plot(showVolatility ? lB : na, "Lower Vol", color = color.new(bullColor, 80))

if showDailyOpen
    line.new(time - 86400000, dayOpenVal, time + 86400000 / 10, dayOpenVal, xloc = xloc.bar_time, color = color.new(color.gray, 50), style = line.style_dotted)

ny_s = not na(time(timeframe.period, "0800-1700:23456"))
ln_s = not na(time(timeframe.period, "0300-1200:23456"))
sessionColor = showSessions ? (ny_s ? color.new(color.blue, 96) : ln_s ? color.new(color.orange, 96) : na) : na
bgcolor(sessionColor)

if showRound
    rl = math.round(close / (100 * syminfo.mintick)) * (100 * syminfo.mintick)
    if math.abs(close - rl) < 20 * syminfo.mintick
        line.new(time, rl, time + 86400000 / 20, rl, xloc = xloc.bar_time, color = color.new(color.gray, 80))

bbu = ta.sma(close, 20) + 2 * ta.stdev(close, 20), bbl = ta.sma(close, 20) - 2 * ta.stdev(close, 20)
kcu = ta.sma(close, 20) + 1.5 * ta.atr(20), kcl = ta.sma(close, 20) - 1.5 * ta.atr(20)
is_sqz = bbu < kcu and bbl > kcl
plotshape(showSqueeze and is_sqz, "Squeeze", shape.circle, location.bottom, color.gray, size = size.tiny)

rVal = ta.rsi(close, 14), rphVal = ta.pivothigh(rVal, 5, 5), rplVal = ta.pivotlow(rVal, 5, 5)
rphH = ta.valuewhen(not na(rphVal), high[5], 1), rphR = ta.valuewhen(not na(rphVal), rVal[5], 1)
rplL = ta.valuewhen(not na(rplVal), low[5], 1), rplR = ta.valuewhen(not na(rplVal), rVal[5], 1)
if showDiv and not na(rphVal) and high[5] > rphH and rVal[5] < rphR
    label.new(time[5], high[5], "▼ DIV", xloc = xloc.bar_time, color = #00000000, textcolor = bearColor, size = size.small)
if showDiv and not na(rplVal) and low[5] < rplL and rVal[5] > rplR
    label.new(time[5], low[5], "▲ DIV", xloc = xloc.bar_time, color = #00000000, textcolor = bullColor, size = size.small)

if showPivots
    pv = (pdh + pdl + pdc) / 3
    res1 = 2 * pv - pdl, sup1 = 2 * pv - pdh
    line.new(time - 86400000, pv, time + 86400000 / 10, pv, xloc = xloc.bar_time, color = color.gray)
    line.new(time - 86400000, res1, time + 86400000 / 10, res1, xloc = xloc.bar_time, color = bearColor)
    line.new(time - 86400000, sup1, time + 86400000 / 10, sup1, xloc = xloc.bar_time, color = bullColor)

if showSweeps
    if high > pdh and close < pdh
        label.new(time, high, "Sweep", xloc = xloc.bar_time, color = #00000000, textcolor = bearColor, size = size.small)
    if low < pdl and close > pdl
        label.new(time, low, "Sweep", xloc = xloc.bar_time, color = #00000000, textcolor = bullColor, size = size.small)

nyk = not na(time(timeframe.period, "0830-1100:23456"))
lnk = not na(time(timeframe.period, "0230-0500:23456"))
killzoneColor = showKillZones ? (nyk or lnk ? color.new(color.yellow, 94) : na) : na
bgcolor(killzoneColor)

var int b1 = 0, var int b2 = 0
if h1_htf > h1_htf[1] and l1_htf > l1_htf[1]
    b1 := 1
else if h1_htf < h1_htf[1] and l1_htf < l1_htf[1]
    b1 := -1
if h2_htf > h2_htf[1] and l2_htf > l2_htf[1]
    b2 := 1
else if h2_htf < h2_htf[1] and l2_htf < l2_htf[1]
    b2 := -1

corVal = ta.correlation(close, correlClose, 14)
[ax, dp, dm] = ta.dmi(14, 14)

var table info = table.new(position.bottom_right, 2, 12, bgcolor = color.new(chart.bg_color, 10), border_width = 1, border_color = color.gray)
if barstate.islast
    table.cell(info, 0, 0, htf1 + " Bias", text_color = chart.fg_color, text_size = size.small)
    table.cell(info, 1, 0, b1 == 1 ? "Bullish" : "Bearish", text_color = b1 == 1 ? bullColor : bearColor, text_size = size.small)
    table.cell(info, 0, 1, htf2 + " Bias", text_color = chart.fg_color, text_size = size.small)
    table.cell(info, 1, 1, b2 == 1 ? "Bullish" : "Bearish", text_color = b2 == 1 ? bullColor : bearColor, text_size = size.small)
    table.cell(info, 0, 2, "ADR", text_color = chart.fg_color, text_size = size.small), table.cell(info, 1, 2, str.tostring(adrVal, "#.##"), text_color = chart.fg_color, text_size = size.small)
    table.cell(info, 0, 3, "ADX", text_color = chart.fg_color, text_size = size.small), table.cell(info, 1, 3, ax > 25 ? "Strong" : "Weak", text_color = ax > 25 ? bullColor : color.gray, text_size = size.small)
    table.cell(info, 0, 4, "Correl", text_color = chart.fg_color, text_size = size.small), table.cell(info, 1, 4, str.tostring(corVal, "#.##"), text_color = corVal > 0.7 ? bullColor : bearColor, text_size = size.small)
    table.cell(info, 0, 5, "Vol Spike", text_color = chart.fg_color, text_size = size.small), table.cell(info, 1, 5, volume > ta.sma(volume, 20) * 2 ? "YES" : "NO", text_color = volume > ta.sma(volume, 20) * 2 ? bullColor : color.gray, text_size = size.small)

bgcolor(trendBias == 1 ? color.new(bullColor, 97) : trendBias == -1 ? color.new(bearColor, 97) : na)
````
