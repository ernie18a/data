# EMA Cloud

- url: https://www.tradingview.com/script/KVryk4ME-EMA-Cloud/
- type: indicator
- pine_id: PUB;e7e2c53a8b3345768127fe06d46a877f
- version: 1.0

## Description

3 ema cloud - Crossover on uptrend signals buy signals and crossovers on downtrend signals sell signals.

Do not go against the trend. Best use on 1H time frame.

If the market is bullish, do not take sell signals.

## Source Code

````pine
//@version=6
indicator("EMA Cloud", overlay = true, max_labels_count = 500)

//──────────────────────────────────────────────────────────────────────────────
// Groups
//──────────────────────────────────────────────────────────────────────────────
const string GROUP_EMA       = "1. EMA Settings"
const string GROUP_CLOUD     = "2. Cloud Settings"
const string GROUP_TREND     = "3. Trend Settings"
const string GROUP_SIGNAL    = "4. Signal Settings"
const string GROUP_VISUAL    = "5. Visual Settings"
const string GROUP_DASHBOARD = "6. Dashboard / Alerts"

//──────────────────────────────────────────────────────────────────────────────
// EMA inputs
//──────────────────────────────────────────────────────────────────────────────
showFastEma   = input.bool(true, "Show Fast EMA", group = GROUP_EMA)
fastLength    = input.int(9, "Fast EMA Length", minval = 1, group = GROUP_EMA)
fastSource    = input.source(close, "Fast EMA Source", group = GROUP_EMA)
fastColor     = input.color(color.aqua, "Fast EMA Color", group = GROUP_EMA)
fastWidth     = input.int(2, "Fast EMA Width", minval = 1, maxval = 5, group = GROUP_EMA)

showMediumEma = input.bool(true, "Show Medium EMA", group = GROUP_EMA)
mediumLength  = input.int(21, "Medium EMA Length", minval = 1, group = GROUP_EMA)
mediumSource  = input.source(close, "Medium EMA Source", group = GROUP_EMA)
mediumColor   = input.color(color.orange, "Medium EMA Color", group = GROUP_EMA)
mediumWidth   = input.int(2, "Medium EMA Width", minval = 1, maxval = 5, group = GROUP_EMA)

showSlowEma   = input.bool(true, "Show Slow EMA", group = GROUP_EMA)
slowLength    = input.int(50, "Slow EMA Length", minval = 1, group = GROUP_EMA)
slowSource    = input.source(close, "Slow EMA Source", group = GROUP_EMA)
slowColor     = input.color(color.fuchsia, "Slow EMA Color", group = GROUP_EMA)
slowWidth     = input.int(2, "Slow EMA Width", minval = 1, maxval = 5, group = GROUP_EMA)

//──────────────────────────────────────────────────────────────────────────────
// Cloud inputs
//──────────────────────────────────────────────────────────────────────────────
showCloud          = input.bool(true, "Show EMA Cloud", group = GROUP_CLOUD)
bullCloudColor     = input.color(color.green, "Bullish Cloud Color", group = GROUP_CLOUD)
bearCloudColor     = input.color(color.red, "Bearish Cloud Color", group = GROUP_CLOUD)
neutralCloudColor  = input.color(color.gray, "Neutral Cloud Color", group = GROUP_CLOUD)
cloudTransparency  = input.int(82, "Cloud Transparency", minval = 0, maxval = 100, group = GROUP_CLOUD)

//──────────────────────────────────────────────────────────────────────────────
// Trend inputs
//──────────────────────────────────────────────────────────────────────────────
trendMode = input.string("Price Only", "Trend Mode", options = ["Price Only", "Price + EMA Stack"], group = GROUP_TREND)

//──────────────────────────────────────────────────────────────────────────────
// Signal inputs
//──────────────────────────────────────────────────────────────────────────────
signalMode = input.string("Fast crosses Medium with Slow EMA filter", "Signal Mode", options = ["Fast crosses Medium", "Fast crosses Slow", "Fast crosses Medium with Slow EMA filter", "EMA stack flip"], group = GROUP_SIGNAL)
useTrendFilter         = input.bool(true, "Use Trend Filter", group = GROUP_SIGNAL)
confirmOnBarClose      = input.bool(true, "Confirm Signals On Candle Close", group = GROUP_SIGNAL)
minimumBarsBetweenSigs = input.int(5, "Minimum Bars Between Signals", minval = 0, group = GROUP_SIGNAL)
showSignalLabels       = input.bool(true, "Show Buy/Sell Signal Labels", group = GROUP_SIGNAL)

//──────────────────────────────────────────────────────────────────────────────
// Visual inputs
//──────────────────────────────────────────────────────────────────────────────
buySignalColor   = input.color(color.lime, "Buy Signal Color", group = GROUP_VISUAL)
sellSignalColor  = input.color(color.red, "Sell Signal Color", group = GROUP_VISUAL)
signalTextColor  = input.color(color.white, "Signal Text Color", group = GROUP_VISUAL)
signalSizeInput  = input.string("Small", "Signal Size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_VISUAL)

colorBarsByTrend = input.bool(false, "Color Bars By Trend", group = GROUP_VISUAL)
bullBarColor     = input.color(color.green, "Bullish Bar Color", group = GROUP_VISUAL)
bearBarColor     = input.color(color.red, "Bearish Bar Color", group = GROUP_VISUAL)
neutralBarColor  = input.color(color.gray, "Neutral Bar Color", group = GROUP_VISUAL)

//──────────────────────────────────────────────────────────────────────────────
// Dashboard inputs
//──────────────────────────────────────────────────────────────────────────────
showDashboard     = input.bool(true, "Show Trend Dashboard", group = GROUP_DASHBOARD)
dashboardPosInput = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_DASHBOARD)

//──────────────────────────────────────────────────────────────────────────────
// Helper functions
//──────────────────────────────────────────────────────────────────────────────
f_dashboardPosition(string pos) =>
    switch pos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_trendText(int state) =>
    state == 1 ? "Bullish" : state == -1 ? "Bearish" : "Neutral"

//──────────────────────────────────────────────────────────────────────────────
// EMA calculations
//──────────────────────────────────────────────────────────────────────────────
fastEma   = ta.ema(fastSource, fastLength)
mediumEma = ta.ema(mediumSource, mediumLength)
slowEma   = ta.ema(slowSource, slowLength)

plot(showFastEma ? fastEma : na, "Fast EMA", color = fastColor, linewidth = fastWidth)
plot(showMediumEma ? mediumEma : na, "Medium EMA", color = mediumColor, linewidth = mediumWidth)
plot(showSlowEma ? slowEma : na, "Slow EMA", color = slowColor, linewidth = slowWidth)

//──────────────────────────────────────────────────────────────────────────────
// EMA cloud
//──────────────────────────────────────────────────────────────────────────────
highestEma = math.max(fastEma, math.max(mediumEma, slowEma))
lowestEma  = math.min(fastEma, math.min(mediumEma, slowEma))

emaStackBullish = fastEma > mediumEma and mediumEma > slowEma
emaStackBearish = fastEma < mediumEma and mediumEma < slowEma

cloudBaseColor = emaStackBullish ? bullCloudColor : emaStackBearish ? bearCloudColor : neutralCloudColor
cloudColor = showCloud ? color.new(cloudBaseColor, cloudTransparency) : na

cloudTopPlot = plot(highestEma, "EMA Cloud Top", color = color.new(color.white, 100), editable = false)
cloudBotPlot = plot(lowestEma, "EMA Cloud Bottom", color = color.new(color.white, 100), editable = false)
fill(cloudTopPlot, cloudBotPlot, color = cloudColor, title = "EMA Cloud")

//──────────────────────────────────────────────────────────────────────────────
// Trend logic
//──────────────────────────────────────────────────────────────────────────────
priceOnlyBullish = close > fastEma and close > mediumEma and close > slowEma
priceOnlyBearish = close < fastEma and close < mediumEma and close < slowEma

strictBullish = priceOnlyBullish and emaStackBullish
strictBearish = priceOnlyBearish and emaStackBearish

isBullishTrend = trendMode == "Price Only" ? priceOnlyBullish : strictBullish
isBearishTrend = trendMode == "Price Only" ? priceOnlyBearish : strictBearish

trendState = isBullishTrend ? 1 : isBearishTrend ? -1 : 0
trendTurnsBullish = trendState == 1 and nz(trendState[1], 0) != 1
trendTurnsBearish = trendState == -1 and nz(trendState[1], 0) != -1
trendTurnsNeutral = trendState == 0 and nz(trendState[1], 0) != 0

trendBarColor = trendState == 1 ? bullBarColor : trendState == -1 ? bearBarColor : neutralBarColor
barcolor(colorBarsByTrend ? trendBarColor : na)

//──────────────────────────────────────────────────────────────────────────────
// Signal logic
//──────────────────────────────────────────────────────────────────────────────
fastCrossAboveMedium = ta.crossover(fastEma, mediumEma)
fastCrossBelowMedium = ta.crossunder(fastEma, mediumEma)
fastCrossAboveSlow   = ta.crossover(fastEma, slowEma)
fastCrossBelowSlow   = ta.crossunder(fastEma, slowEma)

rawBuySignal = switch signalMode
    "Fast crosses Medium" => fastCrossAboveMedium
    "Fast crosses Slow" => fastCrossAboveSlow
    "Fast crosses Medium with Slow EMA filter" => fastCrossAboveMedium and close > slowEma
    "EMA stack flip" => emaStackBullish and not (emaStackBullish[1] == true)
    => false

rawSellSignal = switch signalMode
    "Fast crosses Medium" => fastCrossBelowMedium
    "Fast crosses Slow" => fastCrossBelowSlow
    "Fast crosses Medium with Slow EMA filter" => fastCrossBelowMedium and close < slowEma
    "EMA stack flip" => emaStackBearish and not (emaStackBearish[1] == true)
    => false

trendFilterBuyOk  = not useTrendFilter or isBullishTrend
trendFilterSellOk = not useTrendFilter or isBearishTrend
barCloseOk        = not confirmOnBarClose or barstate.isconfirmed

var int lastSignalBar = na
var string lastSignalText = "None"

spacingOk = na(lastSignalBar) or bar_index - lastSignalBar >= minimumBarsBetweenSigs
buySignal = rawBuySignal and trendFilterBuyOk and barCloseOk and spacingOk
sellSignal = rawSellSignal and trendFilterSellOk and barCloseOk and spacingOk and not buySignal

if buySignal
    lastSignalBar := bar_index
    lastSignalText := "Buy"
else if sellSignal
    lastSignalBar := bar_index
    lastSignalText := "Sell"

//──────────────────────────────────────────────────────────────────────────────
// Signal visuals
//──────────────────────────────────────────────────────────────────────────────
buyVisual = showSignalLabels and buySignal
sellVisual = showSignalLabels and sellSignal

plotshape(buyVisual and signalSizeInput == "Tiny", title = "Buy Signal Tiny", style = shape.labelup, location = location.belowbar, color = buySignalColor, text = "BUY", textcolor = signalTextColor, size = size.tiny)
plotshape(buyVisual and signalSizeInput == "Small", title = "Buy Signal Small", style = shape.labelup, location = location.belowbar, color = buySignalColor, text = "BUY", textcolor = signalTextColor, size = size.small)
plotshape(buyVisual and signalSizeInput == "Normal", title = "Buy Signal Normal", style = shape.labelup, location = location.belowbar, color = buySignalColor, text = "BUY", textcolor = signalTextColor, size = size.normal)
plotshape(buyVisual and signalSizeInput == "Large", title = "Buy Signal Large", style = shape.labelup, location = location.belowbar, color = buySignalColor, text = "BUY", textcolor = signalTextColor, size = size.large)

plotshape(sellVisual and signalSizeInput == "Tiny", title = "Sell Signal Tiny", style = shape.labeldown, location = location.abovebar, color = sellSignalColor, text = "SELL", textcolor = signalTextColor, size = size.tiny)
plotshape(sellVisual and signalSizeInput == "Small", title = "Sell Signal Small", style = shape.labeldown, location = location.abovebar, color = sellSignalColor, text = "SELL", textcolor = signalTextColor, size = size.small)
plotshape(sellVisual and signalSizeInput == "Normal", title = "Sell Signal Normal", style = shape.labeldown, location = location.abovebar, color = sellSignalColor, text = "SELL", textcolor = signalTextColor, size = size.normal)
plotshape(sellVisual and signalSizeInput == "Large", title = "Sell Signal Large", style = shape.labeldown, location = location.abovebar, color = sellSignalColor, text = "SELL", textcolor = signalTextColor, size = size.large)

//──────────────────────────────────────────────────────────────────────────────
// Dashboard
//──────────────────────────────────────────────────────────────────────────────
dashPos = f_dashboardPosition(dashboardPosInput)
var table dashboard = table.new(dashPos, 2, 7, border_width = 1, frame_width = 1)

if barstate.islast
    if showDashboard
        dashBg = trendState == 1 ? color.new(bullBarColor, 72) : trendState == -1 ? color.new(bearBarColor, 72) : color.new(neutralBarColor, 72)
        headerBg = trendState == 1 ? color.new(bullBarColor, 35) : trendState == -1 ? color.new(bearBarColor, 35) : color.new(neutralBarColor, 35)
        table.cell(dashboard, 0, 0, "3 EMA Cloud", text_color = color.white, bgcolor = headerBg, text_size = size.small)
        table.cell(dashboard, 1, 0, syminfo.ticker, text_color = color.white, bgcolor = headerBg, text_size = size.small)
        table.cell(dashboard, 0, 1, "Timeframe", text_color = color.white, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 1, 1, timeframe.period, text_color = color.white, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 0, 2, "Fast EMA", text_color = fastColor, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 1, 2, str.tostring(fastEma, format.mintick), text_color = fastColor, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 0, 3, "Medium EMA", text_color = mediumColor, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 1, 3, str.tostring(mediumEma, format.mintick), text_color = mediumColor, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 0, 4, "Slow EMA", text_color = slowColor, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 1, 4, str.tostring(slowEma, format.mintick), text_color = slowColor, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 0, 5, "Trend", text_color = color.white, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 1, 5, f_trendText(trendState), text_color = color.white, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 0, 6, "Last Signal", text_color = color.white, bgcolor = dashBg, text_size = size.small)
        table.cell(dashboard, 1, 6, lastSignalText, text_color = color.white, bgcolor = dashBg, text_size = size.small)
    else
        table.clear(dashboard, 0, 0, 1, 6)

//──────────────────────────────────────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────────────────────────────────────
alertcondition(buySignal, title = "Buy Signal", message = "BUY signal on {{ticker}} {{interval}}")
alertcondition(sellSignal, title = "Sell Signal", message = "SELL signal on {{ticker}} {{interval}}")

alertcondition(trendTurnsBullish, title = "Trend Turns Bullish", message = "Trend turned Bullish on {{ticker}} {{interval}}")
alertcondition(trendTurnsBearish, title = "Trend Turns Bearish", message = "Trend turned Bearish on {{ticker}} {{interval}}")
alertcondition(trendTurnsNeutral, title = "Trend Turns Neutral", message = "Trend turned Neutral on {{ticker}} {{interval}}")

alertcondition(fastCrossAboveMedium, title = "Fast EMA Crosses Above Medium EMA", message = "Fast EMA crossed above Medium EMA on {{ticker}} {{interval}}")
alertcondition(fastCrossBelowMedium, title = "Fast EMA Crosses Below Medium EMA", message = "Fast EMA crossed below Medium EMA on {{ticker}} {{interval}}")
alertcondition(fastCrossAboveSlow, title = "Fast EMA Crosses Above Slow EMA", message = "Fast EMA crossed above Slow EMA on {{ticker}} {{interval}}")
alertcondition(fastCrossBelowSlow, title = "Fast EMA Crosses Below Slow EMA", message = "Fast EMA crossed below Slow EMA on {{ticker}} {{interval}}")
````
