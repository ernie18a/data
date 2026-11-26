# iD EMARSI on Chart

- url: https://www.tradingview.com/script/sN5HznKE-iD-EMARSI-on-Chart/
- type: strategy
- pine_id: PUB;3589e07a2747474582a77bcc256394dc
- version: 2.0

## Description

[b]SCRIPT OVERVIEW[/b]
The EMARSI indicator is an advanced technical analysis tool that maps RSI values directly onto price charts. With adaptive scaling capabilities, it provides a unique visualization of momentum that flows naturally with price action, making it particularly valuable for FOREX and low-priced securities trading.

[b]KEY FEATURES[/b]

[b]1 PRICE MAPPED RSI VISUALIZATION[/b]
Unlike traditional RSI that displays in a separate window, EMARSI plots the RSI directly on the price chart, creating a flowing line that identifies momentum shifts within the context of price action:

[pine]
// Map RSI to price chart with better scaling
mappedRsi = useAdaptiveScaling ? 
    median + ((rsi - 50) / 50 * (pQH - pQL) / 2 * math.min(1.0, 1/scalingFactor)) : 
    down == pQL ? pQH : up == pQL ? pQL : median - (median / (1 + up / down))
[/pine]

[b]2 ADAPTIVE SCALING SYSTEM[/b]
The script features an intelligent scaling system that automatically adjusts to different market conditions and price levels:

[pine]
// Calculate adaptive scaling factor based on selected method
scalingFactor = if scalingMethod == "ATR-Based"
    math.min(maxScalingFactor, math.max(1.0, minTickSize / (atrValue/avgPrice)))
else if scalingMethod == "Price-Based"
    math.min(maxScalingFactor, math.max(1.0, math.sqrt(100 / math.max(avgPrice, 0.01))))
else // Volume-Based
    math.min(maxScalingFactor, math.max(1.0, math.sqrt(1000000 / math.max(volume, 100))))
[/pine]

[b]3 MODIFIED RSI CALCULATION[/b]
EMARSI uses a specially formulated RSI calculation that works with an adaptive base value to maintain consistency across different price ranges:

[pine]
// Adaptive RSI Base based on price levels to improve flow
adaptiveRsiBase = useAdaptiveScaling ? rsiBase * scalingFactor : rsiBase

// Calculate RSI components with adaptivity
up = ta.rma(math.max(ta.change(rsiSourceInput), adaptiveRsiBase), emaSlowLength)
down = ta.rma(-math.min(ta.change(rsiSourceInput), adaptiveRsiBase), rsiLengthInput)

// Improved RSI calculation with value constraint
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
[/pine]

[b]4 MOVING AVERAGE CROSSOVER SYSTEM[/b]
The indicator creates a smooth moving average of the RSI line, enabling a crossover system that generates trading signals:

[pine]
// Calculate MA of mapped RSI
rsiMA = ma(mappedRsi, emaSlowLength, maTypeInput)

// Strategy entries
if ta.crossover(mappedRsi, rsiMA)
    strategy.entry("RSI Long", strategy.long)
if ta.crossunder(mappedRsi, rsiMA)
    strategy.entry("RSI Short", strategy.short)
[/pine]

[b]5 VISUAL REFERENCE FRAMEWORK[/b]
The script includes visual guides that help interpret the RSI movement within the context of recent price action:

[pine]
// Calculate pivot high and low
pQH = ta.highest(high, hlLen)
pQL = ta.lowest(low, hlLen)
median = (pQH + pQL) / 2

// Plotting
plot(pQH, "Pivot High", color=color.rgb(82, 228, 102, 90))
plot(pQL, "Pivot Low", color=color.rgb(231, 65, 65, 90))
med = plot(median, style=plot.style_steplinebr, linewidth=1, color=color.rgb(238, 101, 59, 90))
[/pine]

[b]6 DYNAMIC COLOR SYSTEM[/b]
The indicator uses color fills to clearly visualize the relationship between the RSI and its moving average:

[pine]
// Color fills based on RSI vs MA
colUp = mappedRsi > rsiMA ? input.color(color.rgb(128, 255, 0), '', group= 'RSI > EMA', inline= 'up') : 
                   input.color(color.rgb(240, 9, 9, 95), '', group= 'RSI < EMA', inline= 'dn')
colDn = mappedRsi > rsiMA ? input.color(color.rgb(0, 230, 35, 95), '', group= 'RSI > EMA', inline= 'up') : 
                   input.color(color.rgb(255, 47, 0), '', group= 'RSI < EMA', inline= 'dn')
fill(rsiPlot, emarsi, mappedRsi > rsiMA ? pQH : rsiMA, mappedRsi > rsiMA ? rsiMA : pQL, colUp, colDn)
[/pine]

[b]7 REAL TIME PARAMETER MONITORING[/b]
A transparent information panel provides real-time feedback on the adaptive parameters being applied:

[pine]
// Information display
var table infoPanel = table.new(position.top_right, 2, 3, bgcolor=color.rgb(0, 0, 0, 80))
if barstate.islast
    table.cell(infoPanel, 0, 0, "Current Scaling Factor", text_color=color.white)
    table.cell(infoPanel, 1, 0, str.tostring(scalingFactor, "#.###"), text_color=color.white)
    table.cell(infoPanel, 0, 1, "Adaptive RSI Base", text_color=color.white)
    table.cell(infoPanel, 1, 1, str.tostring(adaptiveRsiBase, "#.####"), text_color=color.white)
[/pine]

[b]BENEFITS FOR TRADERS[/b]

[b]INTUITIVE MOMENTUM VISUALIZATION[/b]
By mapping RSI directly onto the price chart, traders can immediately see the relationship between momentum and price without switching between different indicator windows.

[b]ADAPTIVE TO ANY MARKET CONDITION[/b]
The three scaling methods (ATR-Based, Price-Based, and Volume-Based) ensure the indicator performs consistently across different market conditions, volatility regimes, and price levels.

[b]PREVENTS EXTREME VALUES[/b]
The adaptive scaling system prevents the RSI from generating extreme values that exceed chart boundaries when trading low-priced securities or during high volatility periods.

[b]CLEAR TRADING SIGNALS[/b]
The RSI and moving average crossover system provides clear entry signals that are visually reinforced through color changes, making it easy to identify potential trading opportunities.

[b]SUITABLE FOR MULTIPLE TIMEFRAMES[/b]
The indicator works effectively across multiple timeframes, from intraday to daily charts, making it versatile for different trading styles and strategies.

[b]TRANSPARENT PARAMETER ADJUSTMENT[/b]
The information panel provides real-time feedback on how the adaptive system is adjusting to current market conditions, helping traders understand why the indicator is behaving as it is.

[b]CUSTOMIZABLE VISUALIZATION[/b]
Multiple visualization options including Bollinger Bands, different moving average types, and customizable colors allow traders to adapt the indicator to their personal preferences.

[b]CONCLUSION[/b]
The EMARSI indicator represents a significant advancement in RSI visualization by directly mapping momentum onto price charts with adaptive scaling. This approach makes momentum shifts more intuitive to identify and helps prevent the scaling issues that commonly affect RSI-based indicators when applied to low-priced securities or volatile markets.

## Source Code

````pine
//@version=6
//Author: ennoiD
//NOTES: MUCH OF THIS PROJECT HAS YET TO BE FULLY IMPLEMENTED
/////////////YOU WILL SEE DRAMATIC CHANGES AS TIME PROGRESSES
////////////////////////////SUGGESTIONS AND COMMENTS WELCOMED
// Modified: with improvements for better price alignment and value constraint
strategy("EMARSI on Chart - FOREX", overlay=true)

// Custom MA function
ma(source, length, type) =>
    switch type
        "SMA" => ta.sma(source, length)
        "Bollinger Bands" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
 
// RSI Settings
rsiLengthInput = input.int(16, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")
rsiBase = input.float(0, title = "RSI Base", tooltip = "Adjust this until the rsi and price are in equilbrium within a sideways trading period.", step = 5)

// MA Settings
maTypeInput = input.string("EMA", title="MA Type", options=["SMA", "Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="MA Settings")
emaFastLength = (1)
emaSlowLength = input.int(42, "EMARSI Length")
hlLen = input.int(55, title="Deviation from Median")
bbMultInput = input.float(2.0, minval=0.001, maxval=50, title="BB StdDev", group="MA Settings", display = display.data_window)

// Adaptive constraint settings
useAdaptiveScaling = input.bool(true, "Use Adaptive Scaling", group="Adaptive Settings")
minTickSize = input.float(0.0001, "Minimum Tick Size", minval=0.00001, group="Adaptive Settings")
maxScalingFactor = input.float(5.0, "Maximum Scaling Factor", minval=1.0, group="Adaptive Settings")
scalingMethod = input.string("Price-Based", "Scaling Method", options=["ATR-Based", "Price-Based", "Volume-Based"], group="Adaptive Settings")

// Simplified Strategy Settings
minTrendDuration = input.int(20, title="Minimum Trend Duration (bars)", minval=1, maxval=100, group="Strategy Settings", tooltip="Minimum number of bars required for a trend before a crossover signal is valid")
useFilteredSignals = input.bool(true, title="Use Filtered Signals", group="Strategy Settings", tooltip="When enabled, signals require a minimum trend duration before triggering")

// Exit Strategy Settings
enableTrailingStop = input.bool(true, title="Enable Trailing Stop", group="Exit Strategy")
trailingStopPercent = input.float(2.0, title="Trailing Stop %", minval=0.1, step=0.1, group="Exit Strategy")
enableTakeProfit = input.bool(true, title="Enable Take Profit", group="Exit Strategy")
takeProfitPercent = input.float(5.0, title="Take Profit %", minval=0.1, step=0.1, group="Exit Strategy")
positionSize = input.float(1.0, title="Position Size", minval=0.1, group="Exit Strategy")

// Signal visualization settings
showSignalMarkers = input.bool(true, title="Show Signal Markers", group="Visuals")
showRSILine = input.bool(true, title="Show RSI Line", group="Visuals")
showRSIMA = input.bool(true, title="Show RSI MA", group="Visuals")
bullSignalColor = input.color(color.rgb(0, 150, 0), title="Bullish Signal Color", group="Visuals")
bearSignalColor = input.color(color.rgb(150, 0, 0), title="Bearish Signal Color", group="Visuals")

// Calculate ATR for adaptive scaling
atrPeriod = input.int(14, "ATR Period", minval=1, group="Adaptive Settings")
atrValue = ta.atr(atrPeriod)
avgPrice = ta.sma(close, hlLen)

// Calculate adaptive scaling factor based on selected method
scalingFactor = if scalingMethod == "ATR-Based"
    math.min(maxScalingFactor, math.max(1.0, minTickSize / (atrValue/avgPrice)))
else if scalingMethod == "Price-Based"
    math.min(maxScalingFactor, math.max(1.0, math.sqrt(100 / math.max(avgPrice, 0.01))))
else // Volume-Based
    math.min(maxScalingFactor, math.max(1.0, math.sqrt(1000000 / math.max(volume, 100))))

// Calculate pivot high and low
pQH = ta.highest(high, hlLen)
pQL = ta.lowest(low, hlLen)
median = (pQH + pQL) / 2

// Calculate RSI with improved formulation
isBB = maTypeInput == "Bollinger Bands"

// Adaptive RSI Base based on price levels to improve flow
adaptiveRsiBase = useAdaptiveScaling ? rsiBase * scalingFactor : rsiBase

// Calculate RSI components with adaptivity
up = ta.rma(math.max(ta.change(rsiSourceInput), adaptiveRsiBase), emaSlowLength)
down = ta.rma(-math.min(ta.change(rsiSourceInput), adaptiveRsiBase), rsiLengthInput)

// Improved RSI calculation with value constraint
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// Map RSI to price chart with better scaling - single line for simplicity
mappedRsi = useAdaptiveScaling ? median + ((rsi - 50) / 50 * (pQH - pQL) / 2 * math.min(1.0, 1/scalingFactor)) : down == pQL ? pQH : up == pQL ? pQL : median - (median / (1 + up / down))

// Calculate MA of mapped RSI
rsiMA = ma(mappedRsi, emaSlowLength, maTypeInput)

// Detect crossovers
bullishCross = ta.crossover(mappedRsi, rsiMA)
bearishCross = ta.crossunder(mappedRsi, rsiMA)

// Track trend direction and duration
var int bullishTrendBars = 0
var int bearishTrendBars = 0

// Update trend counters
if mappedRsi > rsiMA
    bullishTrendBars := bullishTrendBars + 1
    bearishTrendBars := 0
else if mappedRsi < rsiMA
    bearishTrendBars := bearishTrendBars + 1
    bullishTrendBars := 0

// Simplified signal generation
bool validBullishSignal = bullishCross and (not useFilteredSignals or bearishTrendBars >= minTrendDuration)
bool validBearishSignal = bearishCross and (not useFilteredSignals or bullishTrendBars >= minTrendDuration)

// Counter for monitoring signals
var int totalBullishSignals = 0
var int totalBearishSignals = 0

// Update signal counters
if validBullishSignal
    totalBullishSignals := totalBullishSignals + 1
if validBearishSignal
    totalBearishSignals := totalBearishSignals + 1



// Plotting
plot(pQH, "Pivot High", color=color.rgb(82, 228, 102, 85))
plot(pQL, "Pivot Low", color=color.rgb(231, 65, 65, 85))
med = plot(median, style=plot.style_steplinebr, linewidth=1, color=color.rgb(238, 101, 59, 90))
rsiPlot = plot(showRSILine ? mappedRsi : na, "RSI", color=color.rgb(222, 6, 6, 55), linewidth=1)
emarsi = plot(showRSIMA ? rsiMA : na, "RSI-based MA", color=color.rgb(44, 55, 22, 77), linewidth=1)

// Signal visualization
plotshape(showSignalMarkers and validBullishSignal, "Bullish Signal", style=shape.triangleup, location=location.belowbar, color=color.new(bullSignalColor, 0), size=size.large)
plotshape(showSignalMarkers and validBearishSignal, "Bearish Signal", style=shape.triangledown, location=location.abovebar, color=color.new(bearSignalColor, 0), size=size.large)

// Crossover visualization
plotshape(showSignalMarkers and bullishCross, "RSI Crosses Above MA", style=shape.xcross, location=location.belowbar, color=color.new(#00ff26, 0), size=size.tiny)
plotshape(showSignalMarkers and bearishCross, "RSI Crosses Below MA", style=shape.xcross, location=location.abovebar, color=color.rgb(237, 81, 29), size=size.tiny)

// Strategy execution
if bullishCross
    strategy.entry("Bull Signal", strategy.long, qty=positionSize, comment="Buy")
    
if bearishCross
    strategy.entry("Bear Signal", strategy.short, qty=positionSize, comment="Sell")

// Apply trailing stop and take profit
if enableTrailingStop
    strategy.exit("Bull Trail", "Bull Signal", trail_points=close * trailingStopPercent / 100 * syminfo.pointvalue, trail_offset=0)
    strategy.exit("Bear Trail", "Bear Signal", trail_points=close * trailingStopPercent / 100 * syminfo.pointvalue, trail_offset=0)

if enableTakeProfit
    strategy.exit("Bull TP", "Bull Signal", limit=close * (1 + takeProfitPercent / 100))
    strategy.exit("Bear TP", "Bear Signal", limit=close * (1 - takeProfitPercent / 100))

// Bollinger Bands
stdDev = ta.stdev(mappedRsi, emaSlowLength)
bbUpperBand = plot(isBB ? rsiMA + stdDev * bbMultInput : na, title = "Upper Bollinger Band", color= color.black)
bbLowerBand = plot(isBB ? rsiMA - stdDev * bbMultInput : na, title = "Lower Bollinger Band", color=color.black)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.rgb(0, 0, 0, 17) : na, title="Bollinger Bands Background Fill")

// Color fills based on RSI vs MA - single line expressions
colUp = mappedRsi > rsiMA ? input.color(color.rgb(128, 255, 0), '', group= 'RSI > EMA', inline= 'up') : input.color(color.rgb(240, 9, 9, 95), '', group= 'RSI < EMA', inline= 'dn')
colDn = mappedRsi > rsiMA ? input.color(color.rgb(0, 230, 35, 95), '', group= 'RSI > EMA', inline= 'up') : input.color(color.rgb(255, 47, 0), '', group= 'RSI < EMA', inline= 'dn')

// Fill with properly structured parameters - single line for fill with direct parameter passing
fill(rsiPlot, emarsi, mappedRsi > rsiMA ? pQH : rsiMA, mappedRsi > rsiMA ? rsiMA : pQL, colUp, colDn)

// Information display
var table infoPanel = table.new(position.top_right, 2, 6, bgcolor=color.rgb(0, 0, 0, 80))
if barstate.islast
    table.cell(infoPanel, 0, 0, "Current Scaling Factor", text_color=color.white)
    table.cell(infoPanel, 1, 0, str.tostring(scalingFactor, "#.###"), text_color=color.white)
    table.cell(infoPanel, 0, 1, "Adaptive RSI Base", text_color=color.white)
    table.cell(infoPanel, 1, 1, str.tostring(adaptiveRsiBase, "#.####"), text_color=color.white)
    
    // Show current trend info
    table.cell(infoPanel, 0, 2, "Current Trend", text_color=color.white)
    table.cell(infoPanel, 1, 2, mappedRsi > rsiMA ? "Bullish" : "Bearish", text_color=mappedRsi > rsiMA ? bullSignalColor : bearSignalColor)
    table.cell(infoPanel, 0, 3, "Trend Duration", text_color=color.white)
    table.cell(infoPanel, 1, 3, str.tostring(mappedRsi > rsiMA ? bullishTrendBars : bearishTrendBars), text_color=color.white)
    
    // Signal counters
    table.cell(infoPanel, 0, 4, "Bullish Signals", text_color=color.white)
    table.cell(infoPanel, 1, 4, str.tostring(totalBullishSignals), text_color=bullSignalColor)
    table.cell(infoPanel, 0, 5, "Bearish Signals", text_color=color.white)
    table.cell(infoPanel, 1, 5, str.tostring(totalBearishSignals), text_color=bearSignalColor)
````
