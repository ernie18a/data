<!-- tradingview-pine-id: PUB;bce71546d69548c098d1a4e872ca740e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Ayoub SMC Analyst

Source: https://www.tradingview.com/script/Di7VUABz-Ayoub-SMC-Analyst/

## Description

Ayoub SMC Analyst is a market-structure and price-action analysis indicator designed to help traders study market structure, liquidity behavior, Fair Value Gaps (FVGs), premium/discount areas, trend direction, and potential price targets from a single chart.

WHY THIS SCRIPT WAS CREATED

The purpose of Ayoub SMC Analyst is to organize important market-structure information directly on the chart without requiring multiple separate indicators.
https://www.tradingview.com/x/GWRRZSLe/

The script focuses on structured market analysis rather than presenting guaranteed buy or sell signals. Its objective is to help traders identify important areas and build their own trading scenarios.

CORE FEATURES

• Higher High (HH)
• Higher Low (HL)
• Lower High (LH)
• Lower Low (LL)
• Bullish and Bearish Break of Structure (BOS)
• Buy-side and sell-side liquidity sweep detection
• Bullish and bearish Fair Value Gap (FVG) identification
• Premium and Discount areas
• Equilibrium level
• Major support and resistance levels
• Short-term and long-term trend direction
• Conditional bullish and bearish target levels
• Projected market scenarios
• Configurable structure sensitivity
• Optional labels and target visibility

HOW IT WORKS

The indicator uses confirmed swing highs and swing lows to evaluate market structure. It compares recent structural points to identify HH, HL, LH and LL formations.

Break of Structure conditions are detected when price crosses important structural levels.

Liquidity sweep conditions are identified when price temporarily moves beyond a structural high or low and closes back across that level.

Fair Value Gaps are identified using a three-candle price imbalance condition.

Premium and Discount areas are calculated from the most recent valid structural range, with the midpoint used as equilibrium.

Potential target levels are calculated from the current structural range. These levels are scenario-based reference points and are not guaranteed future price destinations.

HOW TO USE

1. Add the indicator to a standard candlestick chart.
2. Adjust Structure Sensitivity according to the timeframe and market.
3. Use HH, HL, LH and LL to understand the current market structure.
4. Monitor BOS and liquidity sweep markers around important structural levels.
5. Use FVG and Premium/Discount information as additional confluence.
6. Treat projected targets as analytical reference levels rather than guaranteed outcomes.
7. Combine the indicator with your own risk management and market analysis.

ORIGINALITY AND PURPOSE

Ayoub SMC Analyst is designed as a unified market-structure analysis tool with a specific focus on organizing structural levels, liquidity events, imbalance conditions, trend direction and scenario-based targets in one visual framework.

The goal is to reduce unnecessary chart clutter while keeping the main structural information visible and understandable.

LIMITATIONS

This indicator does not predict the future with certainty and does not guarantee profitable trades.

Market structure can change as new price information develops. Swing-based calculations can also change as new confirmed pivots appear.

The indicator is an analytical tool and should not be considered financial advice. Traders should independently evaluate market conditions, position sizing and risk before making any trading decision.

CHART EXAMPLES

TradingView chart examples:

https://www.tradingview.com/x/Ikk6pFy5/

---

## Source Code

````pine
//@version=6
indicator("Ayoub SMC Analyst", shorttitle="AYOUB SMC", overlay=true, max_lines_count=20, max_labels_count=30)

// SETTINGS
sensitivity = input.int(5, "Structure Sensitivity", minval=2, maxval=15)
showLabels = input.bool(true, "Show Labels")
showTargets = input.bool(true, "Show Targets")
showPath = input.bool(true, "Show Analyst Path")

// COLORS
bull = color.rgb(0, 170, 145)
bear = color.rgb(215, 70, 80)
gold = color.rgb(210, 165, 60)
gray = color.rgb(120, 125, 135)

// SWING POINTS
swingHigh = ta.pivothigh(high, sensitivity, sensitivity)
swingLow = ta.pivotlow(low, sensitivity, sensitivity)

lastHigh = ta.valuewhen(not na(swingHigh), swingHigh, 0)
lastLow = ta.valuewhen(not na(swingLow), swingLow, 0)

previousHigh = ta.valuewhen(not na(swingHigh), swingHigh, 1)
previousLow = ta.valuewhen(not na(swingLow), swingLow, 1)

// MARKET STRUCTURE
isHH = not na(swingHigh) and not na(previousHigh) and swingHigh > previousHigh
isLH = not na(swingHigh) and not na(previousHigh) and swingHigh < previousHigh
isHL = not na(swingLow) and not na(previousLow) and swingLow > previousLow
isLL = not na(swingLow) and not na(previousLow) and swingLow < previousLow

// BOS
bullBOS = not na(lastHigh) and ta.crossover(close, lastHigh)
bearBOS = not na(lastLow) and ta.crossunder(close, lastLow)

// RANGE
validRange = not na(lastHigh) and not na(lastLow) and lastHigh > lastLow
equilibrium = validRange ? (lastHigh + lastLow) / 2.0 : na
rangeSize = validRange ? lastHigh - lastLow : ta.atr(14)

// PREMIUM DISCOUNT
premiumTop = validRange ? lastHigh : na
premiumBase = validRange ? equilibrium : na
discountTop = validRange ? equilibrium : na
discountBottom = validRange ? lastLow : na

premiumPlot1 = plot(premiumTop, "Premium High", color=color.new(bear, 100))
premiumPlot2 = plot(premiumBase, "Premium Base", color=color.new(bear, 100))
discountPlot1 = plot(discountTop, "Discount Base", color=color.new(bull, 100))
discountPlot2 = plot(discountBottom, "Discount Low", color=color.new(bull, 100))

fill(premiumPlot1, premiumPlot2, color=color.new(bear, 94), title="Premium Zone")
fill(discountPlot1, discountPlot2, color=color.new(bull, 94), title="Discount Zone")

// KEY STRUCTURE LEVELS
plot(lastHigh, "Major Resistance", color=color.new(bear, 25), linewidth=2, style=plot.style_stepline)
plot(lastLow, "Major Support", color=color.new(bull, 25), linewidth=2, style=plot.style_stepline)
plot(equilibrium, "Equilibrium", color=color.new(gray, 55), linewidth=1)

// TREND
ema21 = ta.ema(close, 21)
ema55 = ta.ema(close, 55)

bullTrend = ema21 > ema55
bearTrend = ema21 < ema55

plot(ema21, "Short Trend", color=color.new(bull, 85), linewidth=1)
plot(ema55, "Long Trend", color=color.new(bear, 85), linewidth=1)

// FVG
bullFVG = low > high[2]
bearFVG = high < low[2]

// LIQUIDITY SWEEPS
buySideSweep = not na(lastHigh) and high > lastHigh and close < lastHigh
sellSideSweep = not na(lastLow) and low < lastLow and close > lastLow

// MARKET SCENARIO
bullScenario = bullTrend and validRange and close > equilibrium
bearScenario = bearTrend and validRange and close < equilibrium

// BULL TARGETS
bullTarget1 = validRange ? lastHigh : na
bullTarget2 = validRange ? lastHigh + rangeSize * 0.50 : na
bullTarget3 = validRange ? lastHigh + rangeSize : na

// BEAR TARGETS
bearTarget1 = validRange ? lastLow : na
bearTarget2 = validRange ? lastLow - rangeSize * 0.50 : na
bearTarget3 = validRange ? lastLow - rangeSize : na

// TARGET PLOTS
plot(showTargets and bullScenario ? bullTarget1 : na, "Bull Target 1", color=color.new(bull, 30), linewidth=1, style=plot.style_linebr)
plot(showTargets and bullScenario ? bullTarget2 : na, "Bull Target 2", color=color.new(bull, 50), linewidth=1, style=plot.style_linebr)
plot(showTargets and bullScenario ? bullTarget3 : na, "Bull Target 3", color=color.new(bull, 70), linewidth=1, style=plot.style_linebr)

plot(showTargets and bearScenario ? bearTarget1 : na, "Bear Target 1", color=color.new(bear, 30), linewidth=1, style=plot.style_linebr)
plot(showTargets and bearScenario ? bearTarget2 : na, "Bear Target 2", color=color.new(bear, 50), linewidth=1, style=plot.style_linebr)
plot(showTargets and bearScenario ? bearTarget3 : na, "Bear Target 3", color=color.new(bear, 70), linewidth=1, style=plot.style_linebr)

// HH HL LH LL
plotshape(showLabels and isHH, title="Higher High", style=shape.labeldown, location=location.abovebar, color=color.new(gold, 15), text="HH", textcolor=color.white, size=size.tiny)
plotshape(showLabels and isHL, title="Higher Low", style=shape.labelup, location=location.belowbar, color=color.new(bull, 25), text="HL", textcolor=color.white, size=size.tiny)
plotshape(showLabels and isLH, title="Lower High", style=shape.labeldown, location=location.abovebar, color=color.new(bear, 30), text="LH", textcolor=color.white, size=size.tiny)
plotshape(showLabels and isLL, title="Lower Low", style=shape.labelup, location=location.belowbar, color=color.new(bear, 30), text="LL", textcolor=color.white, size=size.tiny)

// BOS
plotshape(showLabels and bullBOS, title="Bullish BOS", style=shape.labelup, location=location.belowbar, color=bull, text="BOS", textcolor=color.white, size=size.tiny)
plotshape(showLabels and bearBOS, title="Bearish BOS", style=shape.labeldown, location=location.abovebar, color=bear, text="BOS", textcolor=color.white, size=size.tiny)

// LIQUIDITY
plotshape(showLabels and buySideSweep, title="Buy Side Liquidity", style=shape.labeldown, location=location.abovebar, color=bear, text="LIQ", textcolor=color.white, size=size.tiny)
plotshape(showLabels and sellSideSweep, title="Sell Side Liquidity", style=shape.labelup, location=location.belowbar, color=bull, text="LIQ", textcolor=color.white, size=size.tiny)

// FVG
plotshape(showLabels and bullFVG, title="Bullish FVG", style=shape.diamond, location=location.belowbar, color=bull, text="FVG", textcolor=color.white, size=size.tiny)
plotshape(showLabels and bearFVG, title="Bearish FVG", style=shape.diamond, location=location.abovebar, color=bear, text="FVG", textcolor=color.white, size=size.tiny)

// ANALYST PATH VARIABLES
var line pathA = na
var line pathB = na
var line pathC = na

// DELETE OLD PATH
if barstate.islast and not na(pathA)
    line.delete(pathA)

if barstate.islast and not na(pathB)
    line.delete(pathB)

if barstate.islast and not na(pathC)
    line.delete(pathC)

// RESET PATH
if barstate.islast
    pathA := na

if barstate.islast
    pathB := na

if barstate.islast
    pathC := na

// BULLISH PROJECTED PATH
if barstate.islast and showPath and showTargets and bullScenario
    pathA := line.new(bar_index, close, bar_index + 8, bullTarget1, color=color.new(bull, 25), width=2)

if barstate.islast and showPath and showTargets and bullScenario
    pathB := line.new(bar_index + 8, bullTarget1, bar_index + 16, bullTarget2, color=color.new(bull, 40), width=2)

if barstate.islast and showPath and showTargets and bullScenario
    pathC := line.new(bar_index + 16, bullTarget2, bar_index + 24, bullTarget3, color=color.new(bull, 55), width=2)

// BEARISH PROJECTED PATH
if barstate.islast and showPath and showTargets and bearScenario
    pathA := line.new(bar_index, close, bar_index + 8, bearTarget1, color=color.new(bear, 25), width=2)

if barstate.islast and showPath and showTargets and bearScenario
    pathB := line.new(bar_index + 8, bearTarget1, bar_index + 16, bearTarget2, color=color.new(bear, 40), width=2)

if barstate.islast and showPath and showTargets and bearScenario
    pathC := line.new(bar_index + 16, bearTarget2, bar_index + 24, bearTarget3, color=color.new(bear, 55), width=2)

// ALERTS
alertcondition(bullBOS, title="Bullish BOS", message="Bullish market structure breakout detected.")
alertcondition(bearBOS, title="Bearish BOS", message="Bearish market structure breakdown detected.")
alertcondition(buySideSweep, title="Buy Side Liquidity Sweep", message="Buy side liquidity sweep detected.")
alertcondition(sellSideSweep, title="Sell Side Liquidity Sweep", message="Sell side liquidity sweep detected.")
````
