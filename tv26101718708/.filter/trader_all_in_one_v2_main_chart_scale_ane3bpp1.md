# Trader All In One V2 | Main Chart Scale

- url: https://www.tradingview.com/script/ANE3BPp1-Trader-All-In-One-V2-Main-Chart-Scale/
- type: indicator
- pine_id: PUB;db3d3e876e344662b8403051e53cacb4
- version: 1.0

## Description

Trader All In One is a customizable indicator that combines trend, market structure, liquidity, and momentum tools on a single chart.

Features:

• 15 Moving Average slots, each with selectable EMA/SMA type, length, colour, and visibility.
• Daily anchored VWAP and Supertrend.
• Swing-based support/resistance and previous day high/low.
• Confirmed swing labels: HH, HL, LH, and LL.
• Automatic trendlines connecting the latest two confirmed swing highs/lows.
• Candle-close-based BOS and CHoCH markings.
• Three-candle Fair Value Gap zones and rule-based order blocks.
• Swing liquidity sweep markings.
• Asia, London, and New York session ranges, completed session high/low levels, and first BSL/SSL sweep alerts.
• RSI, MACD, and market structure dashboard.

Each feature can be enabled or disabled in the settings. Session hours and timezone are also customizable.

Important notes: Swing markings appear after the selected number of confirmation candles. Order blocks follow defined price-action rules and do not prove the presence of institutional orders. RSI and MACD readings appear in the dashboard and Data Window. Session features are designed for intraday charts, and the default UTC session hours do not automatically adjust for daylight saving time.

This indicator supports chart analysis. It is not an automated trading strategy or a guaranteed buy/sell signal system.

## Source Code

````pine
//@version=6
indicator("Trader All In One V2 | Main Chart Scale", overlay=true, scale=scale.none, max_lines_count=300, max_labels_count=300, max_boxes_count=200, max_bars_back=1000)
// SCALE FIX V2: All price visuals force the main chart scale. Remove old instance and re-add.
// INSTALL: TradingView > Pine Editor > replace old code > paste > Save > Add to chart.
// Standard time-based candles recommended. All SMC events use chart timeframe.
// RSI/MACD appear in dashboard and Data Window, not separate oscillator panes.
// Pivots confirm after 'Swing confirmation candles' right-hand bars. Historical
// pivot labels are placed on the original candle ONLY after confirmation.
// BOS = close through latest unbroken confirmed swing in structure direction.
// CHoCH = opposite-direction break. First break is BOS (initial direction unknown).
// OB = nearest opposite candle before a structure break; full candle range.
// This is a rule-based OB approximation, not evidence of institutional orders.
// FVG = three-candle wick gap, filtered by ATR size. Removed on full wick fill.
// OB removed on candle close beyond far edge. No automatic trade entries.
// Previous day uses exchange/feed daily candles, not a custom Indian-day boundary.

gTrend = "1. Trend"
// 15 fixed MA slots: enable only those you need. MA 1/2 define dashboard trend.
gMA = "1A. Moving Averages (15 slots: EMA / SMA)"
maSource = input.source(close, "MA source", group=gMA)
ma1On = input.bool(true, "MA 1", group=gMA, inline="ma1")
ma1Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma1")
ma1Len = input.int(9, "Length", minval=1, maxval=5000, group=gMA, inline="ma1")
ma1Color = input.color(color.orange, "Color", group=gMA, inline="ma1")
ma2On = input.bool(true, "MA 2", group=gMA, inline="ma2")
ma2Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma2")
ma2Len = input.int(20, "Length", minval=1, maxval=5000, group=gMA, inline="ma2")
ma2Color = input.color(color.blue, "Color", group=gMA, inline="ma2")
ma3On = input.bool(false, "MA 3", group=gMA, inline="ma3")
ma3Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma3")
ma3Len = input.int(50, "Length", minval=1, maxval=5000, group=gMA, inline="ma3")
ma3Color = input.color(color.purple, "Color", group=gMA, inline="ma3")
ma4On = input.bool(false, "MA 4", group=gMA, inline="ma4")
ma4Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma4")
ma4Len = input.int(100, "Length", minval=1, maxval=5000, group=gMA, inline="ma4")
ma4Color = input.color(color.yellow, "Color", group=gMA, inline="ma4")
ma5On = input.bool(false, "MA 5", group=gMA, inline="ma5")
ma5Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma5")
ma5Len = input.int(200, "Length", minval=1, maxval=5000, group=gMA, inline="ma5")
ma5Color = input.color(color.aqua, "Color", group=gMA, inline="ma5")
ma6On = input.bool(false, "MA 6", group=gMA, inline="ma6")
ma6Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma6")
ma6Len = input.int(5, "Length", minval=1, maxval=5000, group=gMA, inline="ma6")
ma6Color = input.color(color.fuchsia, "Color", group=gMA, inline="ma6")
ma7On = input.bool(false, "MA 7", group=gMA, inline="ma7")
ma7Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma7")
ma7Len = input.int(10, "Length", minval=1, maxval=5000, group=gMA, inline="ma7")
ma7Color = input.color(color.lime, "Color", group=gMA, inline="ma7")
ma8On = input.bool(false, "MA 8", group=gMA, inline="ma8")
ma8Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma8")
ma8Len = input.int(21, "Length", minval=1, maxval=5000, group=gMA, inline="ma8")
ma8Color = input.color(color.red, "Color", group=gMA, inline="ma8")
ma9On = input.bool(false, "MA 9", group=gMA, inline="ma9")
ma9Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma9")
ma9Len = input.int(34, "Length", minval=1, maxval=5000, group=gMA, inline="ma9")
ma9Color = input.color(color.white, "Color", group=gMA, inline="ma9")
ma10On = input.bool(false, "MA 10", group=gMA, inline="ma10")
ma10Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma10")
ma10Len = input.int(55, "Length", minval=1, maxval=5000, group=gMA, inline="ma10")
ma10Color = input.color(color.gray, "Color", group=gMA, inline="ma10")
ma11On = input.bool(false, "MA 11", group=gMA, inline="ma11")
ma11Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma11")
ma11Len = input.int(89, "Length", minval=1, maxval=5000, group=gMA, inline="ma11")
ma11Color = input.color(color.orange, "Color", group=gMA, inline="ma11")
ma12On = input.bool(false, "MA 12", group=gMA, inline="ma12")
ma12Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma12")
ma12Len = input.int(144, "Length", minval=1, maxval=5000, group=gMA, inline="ma12")
ma12Color = input.color(color.blue, "Color", group=gMA, inline="ma12")
ma13On = input.bool(false, "MA 13", group=gMA, inline="ma13")
ma13Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma13")
ma13Len = input.int(233, "Length", minval=1, maxval=5000, group=gMA, inline="ma13")
ma13Color = input.color(color.purple, "Color", group=gMA, inline="ma13")
ma14On = input.bool(false, "MA 14", group=gMA, inline="ma14")
ma14Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma14")
ma14Len = input.int(300, "Length", minval=1, maxval=5000, group=gMA, inline="ma14")
ma14Color = input.color(color.yellow, "Color", group=gMA, inline="ma14")
ma15On = input.bool(false, "MA 15", group=gMA, inline="ma15")
ma15Type = input.string("EMA", "Type", options=["EMA", "SMA"], group=gMA, inline="ma15")
ma15Len = input.int(400, "Length", minval=1, maxval=5000, group=gMA, inline="ma15")
ma15Color = input.color(color.aqua, "Color", group=gMA, inline="ma15")
showVWAP = input.bool(true, "Daily anchored VWAP dikhao", group=gTrend)
showST = input.bool(true, "Supertrend dikhao", group=gTrend)
stLen = input.int(10, "Supertrend ATR length", minval=1, group=gTrend)
stFactor = input.float(3.0, "Supertrend multiplier", minval=0.1, step=0.1, group=gTrend)

gLevels = "2. Levels"
showSR = input.bool(true, "Latest swing support/resistance", group=gLevels)
showPD = input.bool(true, "Previous day high/low (intraday/daily)", group=gLevels)

gStructure = "3. Structure"
swingLen = input.int(5, "Swing confirmation candles (har side)", minval=2, maxval=50, group=gStructure)
showSwings = input.bool(true, "Swing HH/HL/LH/LL labels", group=gStructure)
showTL = input.bool(true, "Latest two highs/lows ki trendline", group=gStructure)
showBreaks = input.bool(true, "BOS / CHoCH dikhao", group=gStructure)

gSMC = "4. SMC"
showFVG = input.bool(true, "FVG dikhao", group=gSMC)
minGap = input.float(0.10, "Minimum FVG size / ATR", minval=0, step=0.05, group=gSMC)
showOB = input.bool(true, "Order blocks dikhao", group=gSMC)
obLookback = input.int(20, "Opposite candle search bars", minval=1, maxval=100, group=gSMC)
showSweeps = input.bool(true, "Liquidity sweeps dikhao", group=gSMC)
zoneLimit = input.int(20, "Maximum active zones per type", minval=1, maxval=50, group=gSMC)
zoneLife = input.int(500, "Zone expiry bars", minval=20, maxval=5000, group=gSMC)

gMomentum = "5. Momentum dashboard"
showDash = input.bool(true, "Dashboard dikhao", group=gMomentum)
showRSI = input.bool(true, "RSI reading", group=gMomentum)
rsiLen = input.int(14, "RSI length", minval=1, group=gMomentum)
showMACD = input.bool(true, "MACD readings", group=gMomentum)
macdFast = input.int(12, "MACD fast", minval=1, group=gMomentum)
macdSlow = input.int(26, "MACD slow", minval=1, group=gMomentum)
macdSignal = input.int(9, "MACD signal", minval=1, group=gMomentum)

// Calculate both averages on every bar for consistent series history.
calculateMA(float source, int length, string kind) =>
    emaResult = ta.ema(source, length)
    smaResult = ta.sma(source, length)
    kind == "EMA" ? emaResult : smaResult
ma1Value = calculateMA(maSource, ma1Len, ma1Type)
ma2Value = calculateMA(maSource, ma2Len, ma2Type)
ma3Value = calculateMA(maSource, ma3Len, ma3Type)
ma4Value = calculateMA(maSource, ma4Len, ma4Type)
ma5Value = calculateMA(maSource, ma5Len, ma5Type)
ma6Value = calculateMA(maSource, ma6Len, ma6Type)
ma7Value = calculateMA(maSource, ma7Len, ma7Type)
ma8Value = calculateMA(maSource, ma8Len, ma8Type)
ma9Value = calculateMA(maSource, ma9Len, ma9Type)
ma10Value = calculateMA(maSource, ma10Len, ma10Type)
ma11Value = calculateMA(maSource, ma11Len, ma11Type)
ma12Value = calculateMA(maSource, ma12Len, ma12Type)
ma13Value = calculateMA(maSource, ma13Len, ma13Type)
ma14Value = calculateMA(maSource, ma14Len, ma14Type)
ma15Value = calculateMA(maSource, ma15Len, ma15Type)
vwapValue = ta.vwap(hlc3, timeframe.change("1D"))
[stValue, stDirection] = ta.supertrend(stFactor, stLen)
rsiValue = ta.rsi(close, rsiLen)
[macdValue, signalValue, histValue] = ta.macd(close, macdFast, macdSlow, macdSignal)
atrValue = ta.atr(14)
[pdh, pdl] = request.security(syminfo.tickerid, "1D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
dailyOrLower = timeframe.in_seconds() <= timeframe.in_seconds("1D")

plot(ma1On ? ma1Value : na, "MA 1", color=ma1Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma2On ? ma2Value : na, "MA 2", color=ma2Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma3On ? ma3Value : na, "MA 3", color=ma3Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma4On ? ma4Value : na, "MA 4", color=ma4Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma5On ? ma5Value : na, "MA 5", color=ma5Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma6On ? ma6Value : na, "MA 6", color=ma6Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma7On ? ma7Value : na, "MA 7", color=ma7Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma8On ? ma8Value : na, "MA 8", color=ma8Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma9On ? ma9Value : na, "MA 9", color=ma9Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma10On ? ma10Value : na, "MA 10", color=ma10Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma11On ? ma11Value : na, "MA 11", color=ma11Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma12On ? ma12Value : na, "MA 12", color=ma12Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma13On ? ma13Value : na, "MA 13", color=ma13Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma14On ? ma14Value : na, "MA 14", color=ma14Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(ma15On ? ma15Value : na, "MA 15", color=ma15Color, linewidth=2, display=display.pane + display.data_window, force_overlay=true)
plot(showVWAP and timeframe.isintraday ? vwapValue : na, "Daily VWAP", color=color.fuchsia, linewidth=2, force_overlay=true)
plot(showST and stDirection < 0 ? stValue : na, "Bullish Supertrend", color=color.lime, style=plot.style_linebr, linewidth=2, force_overlay=true)
plot(showST and stDirection > 0 ? stValue : na, "Bearish Supertrend", color=color.red, style=plot.style_linebr, linewidth=2, force_overlay=true)
plot(showPD and dailyOrLower ? pdh : na, "Previous Day High", color=color.new(color.red, 30), style=plot.style_stepline, force_overlay=true)
plot(showPD and dailyOrLower ? pdl : na, "Previous Day Low", color=color.new(color.green, 30), style=plot.style_stepline, force_overlay=true)
plot(showRSI ? rsiValue : na, "RSI (Data Window)", display=display.data_window)
plot(showMACD ? macdValue : na, "MACD (Data Window)", display=display.data_window)
plot(showMACD ? signalValue : na, "MACD Signal (Data Window)", display=display.data_window)
plot(showMACD ? histValue : na, "MACD Histogram (Data Window)", display=display.data_window)

type Zone
    box drawing
    bool bull
    int born

var array<Zone> gaps = array.new<Zone>()
var array<Zone> blocks = array.new<Zone>()

addZone(array<Zone> zones, int leftTime, float topPrice, float bottomPrice, bool bull, string caption) =>
    zoneColor = bull ? color.teal : color.red
    b = box.new(left=leftTime, top=topPrice, right=time, bottom=bottomPrice, xloc=xloc.bar_time, bgcolor=color.new(zoneColor, 86), border_color=color.new(zoneColor, 50), text=caption, text_color=zoneColor, text_size=size.tiny, force_overlay=true)
    array.push(zones, Zone.new(b, bull, bar_index))
    if array.size(zones) > zoneLimit
        old = array.shift(zones)
        box.delete(old.drawing)

updateZones(array<Zone> zones, bool isGap) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            z = array.get(zones, i)
            topPrice = box.get_top(z.drawing)
            bottomPrice = box.get_bottom(z.drawing)
            expired = bar_index - z.born > zoneLife
            invalid = isGap ? (z.bull ? low <= bottomPrice : high >= topPrice) : (z.bull ? close < bottomPrice : close > topPrice)
            if expired or invalid
                array.remove(zones, i)
                // End both branches with a void drawing operation.
                box.delete(z.drawing)
            else
                box.set_right(z.drawing, time)

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)
var float swingHigh = na
var float swingLow = na
var int highTime = na
var int lowTime = na
var int highBar = na
var int lowBar = na
var bool highBroken = false
var bool lowBroken = false
var bool highSwept = false
var bool lowSwept = false
var int bias = 0
var line highTrend = na
var line lowTrend = na

// Breaks are evaluated against swings already known before this candle.
bullBreak = barstate.isconfirmed and not na(swingHigh) and not highBroken and close > swingHigh
bearBreak = barstate.isconfirmed and not na(swingLow) and not lowBroken and close < swingLow
bullChoch = bullBreak and bias == -1
bearChoch = bearBreak and bias == 1
highSweep = barstate.isconfirmed and not na(swingHigh) and not highBroken and not highSwept and high > swingHigh and close < swingHigh
lowSweep = barstate.isconfirmed and not na(swingLow) and not lowBroken and not lowSwept and low < swingLow and close > swingLow

if barstate.isconfirmed
    updateZones(gaps, true)
    updateZones(blocks, false)
    if highSweep
        highSwept := true
    if lowSweep
        lowSwept := true
    if bullBreak or bearBreak
        isBull = bullBreak
        isChoch = isBull ? bullChoch : bearChoch
        level = isBull ? swingHigh : swingLow
        origin = isBull ? highTime : lowTime
        if showBreaks
            line.new(origin, level, time, level, xloc=xloc.bar_time, color=isBull ? color.lime : color.red, style=line.style_dashed, force_overlay=true)
            label.new(bar_index, level, (isBull ? "UP " : "DOWN ") + (isChoch ? "CHoCH" : "BOS"), style=isBull ? label.style_label_down : label.style_label_up, color=isBull ? color.green : color.red, textcolor=color.white, size=size.tiny, force_overlay=true)
        if showOB
            for k = 1 to obLookback
                // Only search between the broken swing and the break candle.
                afterSwing = bar_index - k >= (isBull ? highBar : lowBar)
                opposite = isBull ? close[k] < open[k] : close[k] > open[k]
                if afterSwing and opposite
                    // Reject zones already invalidated before the break.
                    validZone = true
                    for j = 0 to k - 1
                        if isBull ? close[j] < low[k] : close[j] > high[k]
                            validZone := false
                    if validZone
                        addZone(blocks, time[k], high[k], low[k], isBull, isBull ? "Bull OB" : "Bear OB")
                    break
        if isBull
            highBroken := true
            bias := 1
        else
            lowBroken := true
            bias := -1
    if showFVG and not na(atrValue)
        if low > high[2] and low - high[2] >= atrValue * minGap
            addZone(gaps, time[2], low, high[2], true, "Bull FVG")
        if high < low[2] and low[2] - high >= atrValue * minGap
            addZone(gaps, time[2], low[2], high, false, "Bear FVG")
    if not na(ph)
        pivotTime = time[swingLen]
        if showSwings
            caption = na(swingHigh) ? "SH" : ph > swingHigh ? "HH" : ph < swingHigh ? "LH" : "EQH"
            label.new(bar_index - swingLen, ph, caption, style=label.style_label_down, color=color.new(color.red, 25), textcolor=color.white, size=size.tiny, force_overlay=true)
        if showTL and not na(swingHigh)
            if not na(highTrend)
                line.delete(highTrend)
            highTrend := line.new(highTime, swingHigh, pivotTime, ph, xloc=xloc.bar_time, extend=extend.right, color=color.red, width=2, force_overlay=true)
        swingHigh := ph
        highTime := pivotTime
        highBar := bar_index - swingLen
        highBroken := close > ph
        highSwept := false
    if not na(pl)
        pivotTime = time[swingLen]
        if showSwings
            caption = na(swingLow) ? "SL" : pl > swingLow ? "HL" : pl < swingLow ? "LL" : "EQL"
            label.new(bar_index - swingLen, pl, caption, style=label.style_label_up, color=color.new(color.green, 25), textcolor=color.white, size=size.tiny, force_overlay=true)
        if showTL and not na(swingLow)
            if not na(lowTrend)
                line.delete(lowTrend)
            lowTrend := line.new(lowTime, swingLow, pivotTime, pl, xloc=xloc.bar_time, extend=extend.right, color=color.lime, width=2, force_overlay=true)
        swingLow := pl
        lowTime := pivotTime
        lowBar := bar_index - swingLen
        lowBroken := close < pl
        lowSwept := false

plot(showSR ? swingHigh : na, "Swing Resistance", color=color.new(color.red, 45), style=plot.style_stepline, force_overlay=true)
plot(showSR ? swingLow : na, "Swing Support", color=color.new(color.green, 45), style=plot.style_stepline, force_overlay=true)
plotshape(showSweeps and highSweep, title="High liquidity sweep", text="Sweep", style=shape.triangledown, location=location.abovebar, color=color.red, textcolor=color.red, size=size.tiny, force_overlay=true)
plotshape(showSweeps and lowSweep, title="Low liquidity sweep", text="Sweep", style=shape.triangleup, location=location.belowbar, color=color.lime, textcolor=color.lime, size=size.tiny, force_overlay=true)

var table dashboard = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 15), border_width=1)
row(int n, string name, string value, color tint) =>
    table.cell(dashboard, 0, n, name, text_color=color.white, text_size=size.small)
    table.cell(dashboard, 1, n, value, text_color=tint, text_size=size.small)

if barstate.islast
    if showDash
        row(0, "ALL IN ONE", "Current TF: " + timeframe.period, color.aqua)
        row(1, "MA 1 / MA 2 trend", not ma1On or not ma2On ? "Enable MA 1 & 2" : na(ma1Value) or na(ma2Value) ? "Warming up" : ma1Value > ma2Value ? "Bullish" : ma1Value < ma2Value ? "Bearish" : "Flat", ma1Value > ma2Value ? color.lime : ma1Value < ma2Value ? color.red : color.gray)
        row(2, "Supertrend", showST ? (na(stValue) ? "Warming up" : stDirection < 0 ? "Bullish" : "Bearish") : "OFF", stDirection < 0 ? color.lime : color.red)
        row(3, "Structure", bias == 1 ? "Bullish" : bias == -1 ? "Bearish" : "Waiting for break", bias == 1 ? color.lime : bias == -1 ? color.red : color.gray)
        rsiText = str.tostring(rsiValue, "#.0") + (rsiValue >= 70 ? " | Overbought" : rsiValue <= 30 ? " | Oversold" : " | Neutral")
        row(4, "RSI", showRSI ? rsiText : "OFF", rsiValue >= 70 ? color.orange : rsiValue <= 30 ? color.aqua : color.white)
        row(5, "MACD / Signal", showMACD ? str.tostring(macdValue, "#.####") + " / " + str.tostring(signalValue, "#.####") : "OFF", macdValue > signalValue ? color.lime : color.red)
        row(6, "MACD histogram", showMACD ? str.tostring(histValue, "#.####") : "OFF", histValue >= 0 ? color.lime : color.red)
        row(7, "Daily VWAP", not showVWAP ? "OFF" : not timeframe.isintraday ? "Intraday only" : na(vwapValue) ? "Volume unavailable" : close >= vwapValue ? "Price above" : "Price below", color.white)
        row(8, "Active FVG / OB", str.tostring(array.size(gaps)) + " / " + str.tostring(array.size(blocks)), color.aqua)
    else
        table.clear(dashboard, 0, 0, 1, 8)

alertcondition(bullBreak and not bullChoch, "Bullish BOS", "Bullish BOS confirmed on {{ticker}} {{interval}}")
alertcondition(bearBreak and not bearChoch, "Bearish BOS", "Bearish BOS confirmed on {{ticker}} {{interval}}")
alertcondition(bullChoch, "Bullish CHoCH", "Bullish CHoCH confirmed on {{ticker}} {{interval}}")
alertcondition(bearChoch, "Bearish CHoCH", "Bearish CHoCH confirmed on {{ticker}} {{interval}}")
alertcondition(lowSweep, "Low liquidity sweep", "Low sweep confirmed on {{ticker}} {{interval}}")
alertcondition(highSweep, "High liquidity sweep", "High sweep confirmed on {{ticker}} {{interval}}")

// 6. Session Liquidity Map: adapted from user-supplied MonuAlgo script.
// Session times refer to the selected timezone, independently of chart timezone.
// Fixed UTC defaults do NOT automatically shift with London/New York DST.
// Session ranges use complete chart bars whose opening time is inside the session.
// Use intraday bars aligned with session boundaries (e.g. 1m, 5m, 15m).
// Only the latest range per session is retained. Sweeps require a closed candle
// back strictly inside the completed range; each side can trigger once per cycle.
gSessions = "6. Session Liquidity"
sessionTimezone = input.string("Etc/UTC", "Session timezone", options=["Etc/UTC", "America/New_York", "Europe/London", "Asia/Kolkata"], group=gSessions)
asiaEnabled = input.bool(true, "Show", group="6A. Asia", inline="asia")
asiaHours = input.session("0000-0900", "Hours", group="6A. Asia", inline="asia")
asiaColor = input.color(#9C6ADE, "Color", group="6A. Asia", inline="asia")
londonEnabled = input.bool(true, "Show", group="6B. London", inline="london")
londonHours = input.session("0700-1600", "Hours", group="6B. London", inline="london")
londonColor = input.color(#2E9B7A, "Color", group="6B. London", inline="london")
newYorkEnabled = input.bool(true, "Show", group="6C. New York", inline="ny")
newYorkHours = input.session("1300-2200", "Hours", group="6C. New York", inline="ny")
newYorkColor = input.color(#E59B35, "Color", group="6C. New York", inline="ny")
showLiveRange = input.bool(true, "Latest session range box", group=gSessions)
showCompletedLevels = input.bool(true, "Completed high/low extend karo", group=gSessions)
markSessionSweeps = input.bool(true, "First confirmed BSL/SSL sweep dikhao", group=gSessions)
sessionBoxOpacity = input.int(88, "Box transparency", minval=0, maxval=100, group=gSessions)
showSessionDashboard = input.bool(true, "Session dashboard (bottom right)", group=gSessions)

trackSession(bool enabled, string hours, color sessionColor, string sessionName) =>
    bool active = enabled and timeframe.isintraday and not na(time(timeframe.period, hours, sessionTimezone))
    var float buildingHigh = na
    var float buildingLow = na
    var float completedHigh = na
    var float completedLow = na
    var box rangeBox = na
    var line highLevel = na
    var line lowLevel = na
    var bool highAlreadySwept = false
    var bool lowAlreadySwept = false
    // Daily session anchor also detects a new cycle across missing chart bars.
    int sessionAnchor = time("1D", hours, sessionTimezone)
    bool anchorChanged = active and active[1] and not na(sessionAnchor) and not na(sessionAnchor[1]) and sessionAnchor != sessionAnchor[1]
    bool justOpened = active and (not active[1] or na(buildingHigh) or anchorChanged)
    bool justClosed = not active and active[1]
    bool highSweepEvent = false
    bool lowSweepEvent = false

    if justOpened
        buildingHigh := high
        buildingLow := low
        // Retire the previous cycle when the next session starts.
        completedHigh := na
        completedLow := na
        highAlreadySwept := false
        lowAlreadySwept := false
        if not na(rangeBox)
            box.delete(rangeBox)
        if not na(highLevel)
            line.delete(highLevel)
        if not na(lowLevel)
            line.delete(lowLevel)
        highLevel := na
        lowLevel := na
        rangeBox := showLiveRange ? box.new(left=time, top=buildingHigh, right=time_close, bottom=buildingLow, xloc=xloc.bar_time, bgcolor=color.new(sessionColor, sessionBoxOpacity), border_color=color.new(sessionColor, 20), text=sessionName, text_color=sessionColor, text_size=size.tiny, force_overlay=true) : na
    else if active
        buildingHigh := math.max(buildingHigh, high)
        buildingLow := math.min(buildingLow, low)
        if showLiveRange and not na(rangeBox)
            box.set_top(rangeBox, buildingHigh)
            box.set_bottom(rangeBox, buildingLow)
            box.set_right(rangeBox, time_close)

    if justClosed
        completedHigh := buildingHigh
        completedLow := buildingLow
        if showCompletedLevels
            highLevel := line.new(time, completedHigh, time_close, completedHigh, xloc=xloc.bar_time, extend=extend.right, color=sessionColor, style=line.style_dashed, force_overlay=true)
            lowLevel := line.new(time, completedLow, time_close, completedLow, xloc=xloc.bar_time, extend=extend.right, color=sessionColor, style=line.style_dashed, force_overlay=true)

    bool canCheckSweep = enabled and timeframe.isintraday and not active and not na(completedHigh) and not na(completedLow) and barstate.isconfirmed
    // Sweep events/alerts work even when visual sweep labels are switched off.
    if canCheckSweep and not highAlreadySwept and high > completedHigh and close < completedHigh and close > completedLow
        highSweepEvent := true
        highAlreadySwept := true
        if markSessionSweeps
            label.new(bar_index, high, sessionName + " BSL sweep", style=label.style_label_down, color=sessionColor, textcolor=color.white, size=size.tiny, force_overlay=true)
    if canCheckSweep and not lowAlreadySwept and low < completedLow and close > completedLow and close < completedHigh
        lowSweepEvent := true
        lowAlreadySwept := true
        if markSessionSweeps
            label.new(bar_index, low, sessionName + " SSL sweep", style=label.style_label_up, color=sessionColor, textcolor=color.white, size=size.tiny, force_overlay=true)
    [active, buildingHigh, buildingLow, completedHigh, completedLow, highSweepEvent, lowSweepEvent]

[asiaActive, asiaBuildingHigh, asiaBuildingLow, asiaCompletedHigh, asiaCompletedLow, asiaBslSweep, asiaSslSweep] = trackSession(asiaEnabled, asiaHours, asiaColor, "Asia")
[londonActive, londonBuildingHigh, londonBuildingLow, londonCompletedHigh, londonCompletedLow, londonBslSweep, londonSslSweep] = trackSession(londonEnabled, londonHours, londonColor, "London")
[nyActive, nyBuildingHigh, nyBuildingLow, nyCompletedHigh, nyCompletedLow, nyBslSweep, nySslSweep] = trackSession(newYorkEnabled, newYorkHours, newYorkColor, "New York")

sessionState(bool enabled, bool active, float completedHigh) =>
    not enabled ? "OFF" : not timeframe.isintraday ? "Intraday only" : active ? "BUILDING" : na(completedHigh) ? "WAITING" : "COMPLETE"

sessionSize(bool enabled, bool active, float buildingHigh, float buildingLow, float completedHigh, float completedLow) =>
    float rangeHigh = active ? buildingHigh : completedHigh
    float rangeLow = active ? buildingLow : completedLow
    not enabled or not timeframe.isintraday or na(rangeHigh) or na(rangeLow) ? "-" : str.tostring(rangeHigh - rangeLow, format.mintick)

var table sessionDashboard = table.new(position.bottom_right, 3, 5, bgcolor=color.new(#111827, 8), frame_color=color.new(color.white, 75), frame_width=1, border_color=color.new(color.white, 88), border_width=1)
sessionRow(int n, string name, bool enabled, bool active, float buildingHigh, float buildingLow, float completedHigh, float completedLow, color tint) =>
    table.cell(sessionDashboard, 0, n, name, text_color=tint, text_size=size.small)
    table.cell(sessionDashboard, 1, n, sessionState(enabled, active, completedHigh), text_color=active ? color.lime : color.white, text_size=size.tiny)
    table.cell(sessionDashboard, 2, n, sessionSize(enabled, active, buildingHigh, buildingLow, completedHigh, completedLow), text_color=color.white, text_size=size.tiny)

if barstate.islast
    if showSessionDashboard
        table.cell(sessionDashboard, 0, 0, "SESSION", text_color=color.silver, text_size=size.tiny)
        table.cell(sessionDashboard, 1, 0, "STATE", text_color=color.silver, text_size=size.tiny)
        table.cell(sessionDashboard, 2, 0, "RANGE", text_color=color.silver, text_size=size.tiny)
        sessionRow(1, "Asia", asiaEnabled, asiaActive, asiaBuildingHigh, asiaBuildingLow, asiaCompletedHigh, asiaCompletedLow, asiaColor)
        sessionRow(2, "London", londonEnabled, londonActive, londonBuildingHigh, londonBuildingLow, londonCompletedHigh, londonCompletedLow, londonColor)
        sessionRow(3, "New York", newYorkEnabled, nyActive, nyBuildingHigh, nyBuildingLow, nyCompletedHigh, nyCompletedLow, newYorkColor)
        table.cell(sessionDashboard, 0, 4, "Timezone", text_color=color.silver, text_size=size.tiny)
        table.cell(sessionDashboard, 1, 4, sessionTimezone, text_color=color.white, text_size=size.tiny)
        table.cell(sessionDashboard, 2, 4, "", text_size=size.tiny)
    else
        table.clear(sessionDashboard, 0, 0, 2, 4)

alertcondition(asiaBslSweep, "Asia BSL sweep", "Asia high swept; confirmed close back inside session range on {{ticker}} {{interval}}")
alertcondition(asiaSslSweep, "Asia SSL sweep", "Asia low swept; confirmed close back inside session range on {{ticker}} {{interval}}")
alertcondition(londonBslSweep, "London BSL sweep", "London high swept; confirmed close back inside session range on {{ticker}} {{interval}}")
alertcondition(londonSslSweep, "London SSL sweep", "London low swept; confirmed close back inside session range on {{ticker}} {{interval}}")
alertcondition(nyBslSweep, "New York BSL sweep", "New York high swept; confirmed close back inside session range on {{ticker}} {{interval}}")
alertcondition(nySslSweep, "New York SSL sweep", "New York low swept; confirmed close back inside session range on {{ticker}} {{interval}}")
````
