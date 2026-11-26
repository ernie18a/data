# SuperTrend + Multi-MA + CVD Confluence

- url: https://www.tradingview.com/script/p6Tz0GnK-SuperTrend-Multi-MA-CVD-Confluence/
- type: indicator
- pine_id: PUB;ef052ccbb0c641348cd69d757ee8db7e
- version: 1.0

## Description

The [b]SuperTrend + Multi-MA + CVD Confluence[/b] indicator is a comprehensive trading suite designed to solve the common issue of "false signals" in trend-following strategies. While standard moving average crossovers often fail in sideways or low-volume markets, this script integrates [b]Volume Delta (CVD)[/b] and [b]Volatility Filtering[/b] to ensure that price momentum is supported by real market conviction.

The originality of this script lies in its "triple-filter" approach:

[b]Structural Trend:[/b] Defined by a customizable Multi-MA crossover.
[b]Momentum Confirmation:[/b] Provided by the SuperTrend algorithm.
[b]Volume Conviction:[/b] Validated through Cumulative Volume Delta (CVD) alignment.

[b]How It Works[/b]
[b]Multi-MA Crossover Engine:[/b] Traders can choose from six different Moving Average types (SMA, EMA, WMA, SMMA, DEMA, and TEMA). This flexibility allows the script to adapt to different asset classes—for example, using TEMA for fast-paced scalping or SMMA for smoother trend following.
[b]CVD (Cumulative Volume Delta) Alignment: [/b]Buy and Sell signals are only triggered if the MA crossover aligns with the current Volume Delta momentum. A BUY signal requires the CVD to be rising, indicating that aggressive buyers are in control, while a SELL signal requires a falling CVD.
[b]Chop Zone & ATR Filtering:[/b] To prevent overtrading, the script uses the[b] ADX (Average Directional Index)[/b] to identify "Chop Zones" where the market lacks a clear trend. Additionally, an optional ATR Volatility Filter ensures signals only appear when the market has sufficient range to reach a target.
[b]Signal Cooldown:[/b] A built-in "Cooldown" setting prevents signal spamming during volatile price action, requiring a minimum number of bars between consecutive trade labels.
[b]Multi-Timeframe Dashboard:[/b] A theme-aware table provides a high-level view of the trend across 7 different timeframes (1m through 4h), alongside real-time Net Delta, Ask Volume, and Bid Volume metrics for current and previous bars.

[b]How to Use It[/b]
[b]Entries:[/b] Look for "BUY" or "SELL" labels. These represent the confluence of the MA crossover, CVD momentum, and volatility.
[b]Trend Reference: [/b]Use the SuperTrend line as your primary trend guard. If price is above the SuperTrend, look primarily for long confluence; if below, focus on shorts.
[b]No-Trade Zones:[/b] Avoid taking trades when candles turn Grey, as this indicates a "Chop Zone" where trend-following strategies are likely to be whipsawed.
[b]Institutional Pressure:[/b] Monitor the Net Delta in the dashboard. Large positive delta alongside a bullish crossover provides the highest probability for a successful trade.
[b]Exits:[/b] The SuperTrend line or the opposite MA crossover can serve as dynamic exit points or trailing stop-loss guides.

[b]Customization[/b]
[b]Independently Change Colors:[/b] You can customize the colors of Bullish/Bearish bars, Chop bars, and signal labels to match your specific chart theme.
[b]Dashboard Settings:[/b] The table can be resized (Tiny, Small, Normal) and positioned in any corner of the chart.
[b]Volatility Tuning:[/b] Adjust the ATR and ADX thresholds to tighten or loosen the signal frequency based on the asset's specific volatility profile.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb


//@version=6
indicator("SuperTrend + Multi-MA + CVD Confluence", overlay = true, max_bars_back = 500)

// --- Inputs ---
// Moving Averages
maGroup = "Moving Averages"
maTypeInput = input.string("EMA", "MA Type", options = ["SMA", "EMA", "WMA", "SMMA", "DEMA", "TEMA"], group = maGroup, tooltip = "Select the type of Moving Average for the crossover strategy.")
fastLenInput = input.int(9, "Fast MA Length", minval = 1, group = maGroup)
slowLenInput = input.int(21, "Slow MA Length", minval = 1, group = maGroup)

// ATR Filter
atrGroup = "ATR Volatility Filter"
useAtrFilter = input.bool(true, "Use ATR Volatility Filter", group = atrGroup, tooltip = "Only allow signals when ATR is above its average, ensuring sufficient volatility.")
atrLen = input.int(14, "ATR Length", group = atrGroup)

// Signal Cooldown
cooldownGroup = "Signal Cooldown"
cooldownInput = input.int(5, "Cooldown (Bars)", minval = 0, group = cooldownGroup, tooltip = "Minimum number of bars between consecutive signals of the same type.")

// Chop Zone
chopGroup = "Chop Zone / No Trade Area"
useChopColoring = input.bool(true, "Enable Chop Zone Bar Coloring", group = chopGroup, tooltip = "Color bars grey when market is in a low-volatility chop zone based on ADX.")
adxLen = input.int(14, "ADX Length", group = chopGroup)
adxThreshold = input.int(20, "ADX Threshold", group = chopGroup)

// SuperTrend
stGroup = "SuperTrend"
stFactor = input.float(3.0, "Factor", step = 0.1, group = stGroup)
stPeriod = input.int(10, "Period", group = stGroup)

// Dashboard Settings
dashGroup = "Dashboard"
tablePos = input.string("Bottom Right", "Table Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = dashGroup)
tableSize = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = dashGroup)

// Color Settings
colorGroup = "Style / Colors"
bullBarCol = input.color(#5b9cf6, "Bullish Bar Color", group = colorGroup, inline = "bars")
bearBarCol = input.color(#9b59b6, "Bearish Bar Color", group = colorGroup, inline = "bars")
chopBarCol = input.color(#95a5a6, "Chop Bar Color", group = colorGroup)
fastMaCol = input.color(#5b9cf6, "Fast MA Color", group = colorGroup, inline = "ma")
slowMaCol = input.color(#9b59b6, "Slow MA Color", group = colorGroup, inline = "ma")
buyLabelCol = input.color(#5b9cf6, "Buy Signal Color", group = colorGroup, inline = "signals")
sellLabelCol = input.color(#9b59b6, "Sell Signal Color", group = colorGroup, inline = "signals")

// Convert table size input
tSize = tableSize == "Tiny" ? size.tiny : tableSize == "Small" ? size.small : size.normal

// --- Functions ---
getMA(type, src, len) =>
    switch type
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "SMMA" => ta.rma(src, len)
        "DEMA" => 2 * ta.ema(src, len) - ta.ema(ta.ema(src, len), len)
        "TEMA" => 3 * (ta.ema(src, len) - ta.ema(ta.ema(src, len), len)) + ta.ema(ta.ema(ta.ema(src, len), len), len)
        => ta.ema(src, len)

// --- Calculations ---
// Moving Averages
fastMA = getMA(maTypeInput, close, fastLenInput)
slowMA = getMA(maTypeInput, close, slowLenInput)
maBull = fastMA > slowMA
maCrossUp = ta.crossover(fastMA, slowMA)
maCrossDn = ta.crossunder(fastMA, slowMA)

// ATR Filter
atrValue = ta.atr(atrLen)
atrAvg = ta.sma(atrValue, atrLen)
volatilityOk = not useAtrFilter or (atrValue > atrAvg)

// SuperTrend
[stValue, stDirection] = ta.supertrend(stFactor, stPeriod)
stBull = stDirection < 0

// CVD (Volume Delta Approximation)
buyVol = (high == low) ? 0 : volume * (close - low) / (high - low)
sellVol = (high == low) ? 0 : volume * (high - close) / (high - low)
delta = buyVol - sellVol
var float cvd = 0.0
cvd += delta
cvdRising = cvd > cvd[1]

// Chop Logic
[_, _, adx] = ta.dmi(adxLen, adxLen)
isChop = useChopColoring and adx < adxThreshold

// --- Signals ---
var int lastSignalBar = 0
cooldownOk = (bar_index - lastSignalBar) >= cooldownInput

rawBuy = maCrossUp and cvdRising and volatilityOk and cooldownOk
rawSell = maCrossDn and not cvdRising and volatilityOk and cooldownOk

buySignal = false
sellSignal = false

if rawBuy
    buySignal := true
    lastSignalBar := bar_index
if rawSell
    sellSignal := true
    lastSignalBar := bar_index

// --- Bar Coloring ---
barColor = isChop ? chopBarCol : maBull ? bullBarCol : bearBarCol
barcolor(barColor)

// --- Plots ---
plot(fastMA, "Fast MA", color.new(fastMaCol, 20), 1)
plot(slowMA, "Slow MA", color.new(slowMaCol, 20), 2)
plot(stValue, "SuperTrend", stBull ? color.new(color.green, 50) : color.new(color.red, 50), 2, style = plot.style_linebr)

plotshape(buySignal, "Buy Label", shape.labelup, location.belowbar, color.new(buyLabelCol, 0), text = "BUY", textcolor = chart.fg_color, size = size.small)
plotshape(sellSignal, "Sell Label", shape.labeldown, location.abovebar, color.new(sellLabelCol, 0), text = "SELL", textcolor = chart.fg_color, size = size.small)

// --- Dashboard Logic ---
is_ny = not na(time(timeframe.period, "0800-1700:23456", "America/New_York"))
is_london = not na(time(timeframe.period, "0300-1200:23456", "America/New_York"))
is_tokyo = not na(time(timeframe.period, "2000-0500:23456", "America/New_York"))
session_str = is_ny ? "NY" : is_london ? "LDN" : is_tokyo ? "TKY" : "N/A"

t1m  = request.security(syminfo.tickerid, "1", fastMA > slowMA)
t3m  = request.security(syminfo.tickerid, "3", fastMA > slowMA)
t5m  = request.security(syminfo.tickerid, "5", fastMA > slowMA)
t15m = request.security(syminfo.tickerid, "15", fastMA > slowMA)
t30m = request.security(syminfo.tickerid, "30", fastMA > slowMA)
t1h  = request.security(syminfo.tickerid, "60", fastMA > slowMA)
t4h  = request.security(syminfo.tickerid, "240", fastMA > slowMA)

// Table Position
tPos = tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Right" ? position.bottom_right : tablePos == "Top Left" ? position.top_left : position.bottom_left

var dashboard = table.new(tPos, 3, 13, frame_color = chart.fg_color, frame_width = 1, border_color = chart.fg_color, border_width = 1)

if barstate.islast
    headerBg = color.new(chart.fg_color, 15)
    cellBg = color.new(chart.fg_color, 95)

    // Metrics Header
    table.cell(dashboard, 0, 0, "Metrics", bgcolor = headerBg, text_color = chart.bg_color, text_size = tSize)
    table.cell(dashboard, 1, 0, "Current", bgcolor = headerBg, text_color = chart.bg_color, text_size = tSize)
    table.cell(dashboard, 2, 0, "Previous", bgcolor = headerBg, text_color = chart.bg_color, text_size = tSize)
    
    // Net Delta
    table.cell(dashboard, 0, 1, "Net Delta", text_halign = text.align_left, text_color = chart.fg_color, text_size = tSize, bgcolor = cellBg)
    table.cell(dashboard, 1, 1, str.tostring(delta, "#"), text_color = delta >= 0 ? #089981 : #f23645, text_size = tSize, bgcolor = cellBg)
    table.cell(dashboard, 2, 1, str.tostring(delta[1], "#"), text_color = delta[1] >= 0 ? #089981 : #f23645, text_size = tSize, bgcolor = cellBg)
    
    // Ask Volume
    table.cell(dashboard, 0, 2, "Ask Vol", text_halign = text.align_left, text_color = #089981, text_size = tSize, bgcolor = cellBg)
    table.cell(dashboard, 1, 2, str.tostring(buyVol, "#"), text_color = chart.fg_color, text_size = tSize, bgcolor = cellBg)
    table.cell(dashboard, 2, 2, str.tostring(buyVol[1], "#"), text_color = chart.fg_color, text_size = tSize, bgcolor = cellBg)
    
    // Bid Volume
    table.cell(dashboard, 0, 3, "Bid Vol", text_halign = text.align_left, text_color = #f23645, text_size = tSize, bgcolor = cellBg)
    table.cell(dashboard, 1, 3, str.tostring(sellVol, "#"), text_color = chart.fg_color, text_size = tSize, bgcolor = cellBg)
    table.cell(dashboard, 2, 3, str.tostring(sellVol[1], "#"), text_color = chart.fg_color, text_size = tSize, bgcolor = cellBg)

    // Session
    table.cell(dashboard, 0, 4, "Session", text_halign = text.align_left, text_color = chart.fg_color, text_size = tSize, bgcolor = cellBg)
    table.cell(dashboard, 1, 4, session_str, text_color = #5b9cf6, text_size = tSize, bgcolor = cellBg)
    table.cell(dashboard, 2, 4, "", bgcolor = cellBg)

    // TF Trends Header
    table.cell(dashboard, 0, 5, "TF Trends", bgcolor = headerBg, text_color = chart.bg_color, text_size = tSize)
    table.cell(dashboard, 1, 5, "Status", bgcolor = headerBg, text_color = chart.bg_color, text_size = tSize)
    table.cell(dashboard, 2, 5, "", bgcolor = headerBg)
    
    tfs = array.from("1m", "3m", "5m", "15m", "30m", "1h", "4h")
    trends = array.from(t1m, t3m, t5m, t15m, t30m, t1h, t4h)
    
    for i = 0 to 6
        table.cell(dashboard, 0, 6 + i, array.get(tfs, i), text_halign = text.align_left, text_color = chart.fg_color, text_size = tSize, bgcolor = cellBg)
        table.cell(dashboard, 1, 6 + i, array.get(trends, i) ? "BULL" : "BEAR", bgcolor = array.get(trends, i) ? bullBarCol : bearBarCol, text_color = color.white, text_size = tSize)
        table.cell(dashboard, 2, 6 + i, "", bgcolor = cellBg)
````
