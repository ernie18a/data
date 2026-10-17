# Bull vs Bear Candle Count

- url: https://www.tradingview.com/script/EBN98jSL-Bull-vs-Bear-Candle-Count/
- type: indicator
- pine_id: PUB;7eff4760aebe4a9c8a6f7a83dd6d6c3b
- version: 1.0

## Description

Bull vs Bear Candle Count

Bull vs Bear Candle Count is a market participation and directional bias indicator designed to measure whether buyers or sellers have been dominating recent price action.

Instead of relying on traditional moving averages or oscillators, this indicator simply analyzes the number of bullish and bearish candles over a customizable lookback period to determine whether the market environment is currently Bullish, Bearish, or Balanced. Based on the candle distribution, the indicator calculates net directional pressure and visually highlights shifts in market conditions.

Features:

• Customizable lookback period
• Bullish, Bearish, and Balanced market state detection
• Net Bias histogram for directional strength visualization
• Bull % and Bear % comparison lines
• Adjustable balanced threshold sensitivity
• Optional background highlighting based on market state
• State transition markers for environment changes
• Summary table displaying:

Bull count
Bear count
Doji count
Bull percentage
Current market state

Alerts Included:

• Bullish State Shift
• Bearish State Shift
• Balanced State Shift

Potential use cases:

• Identify directional market pressure
• Filter trades based on overall market environment
• Confirm trend continuation or weakening momentum
• Spot transitions between trending and balanced conditions
• Add confluence to existing strategies and systems

Interpretation:

Bullish

Bullish candles are dominating the selected lookback period

Bearish

Bearish candles are dominating the selected lookback period

Balanced

Bull and bear participation are relatively equal, potentially indicating consolidation or indecision

Bull vs Bear Candle Count is intended as a simple way to visualize market participation and directional behavior without introducing excessive complexity.

About TrendGenY Indicators
[i]TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to bring greater clarity, deeper understanding, and help traders develop a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Bull vs Bear Candle Count", shorttitle="BullBear Count", overlay=false)

//====================================================
// Inputs
//====================================================
grpCore = "Core"
lookback = input.int(20, "Lookback Bars", minval=1, group=grpCore)
balanceThreshold = input.float(0.10, "Balanced Threshold", minval=0.0, maxval=1.0, step=0.01, group=grpCore, tooltip="If bull % and bear % are within this difference, market is considered balanced")

grpDisplay = "Display"
showHistogram = input.bool(true, "Show Net Bias Histogram", group=grpDisplay)
showBullLine = input.bool(true, "Show Bull % Line", group=grpDisplay)
showBearLine = input.bool(true, "Show Bear % Line", group=grpDisplay)
showBackground = input.bool(true, "Show Background", group=grpDisplay)
showTable = input.bool(true, "Show Summary Table", group=grpDisplay)
showMarkers = input.bool(true, "Show State Change Markers", group=grpDisplay)

grpColors = "Colors"
bullColor = input.color(color.lime, "Bull Color", group=grpColors)
bearColor = input.color(color.red, "Bear Color", group=grpColors)
balancedColor = input.color(color.orange, "Balanced Color", group=grpColors)
bullBgColor = input.color(color.new(color.lime, 88), "Bull Background", group=grpColors)
bearBgColor = input.color(color.new(color.red, 88), "Bear Background", group=grpColors)
balancedBgColor = input.color(color.new(color.orange, 88), "Balanced Background", group=grpColors)

grpTable = "Table"
tblPosIn  = input.string("Top Right", "Table Location", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpTable)
tblSizeIn = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grpTable)

//====================================================
// Helpers
//====================================================
tblPos =
     tblPosIn == "Top Left" ? position.top_left :
     tblPosIn == "Top Center" ? position.top_center :
     tblPosIn == "Top Right" ? position.top_right :
     tblPosIn == "Middle Left" ? position.middle_left :
     tblPosIn == "Middle Center" ? position.middle_center :
     tblPosIn == "Middle Right" ? position.middle_right :
     tblPosIn == "Bottom Left" ? position.bottom_left :
     tblPosIn == "Bottom Center" ? position.bottom_center :
     position.bottom_right

tblSize =
     tblSizeIn == "Tiny" ? size.tiny :
     tblSizeIn == "Small" ? size.small :
     tblSizeIn == "Normal" ? size.normal :
     tblSizeIn == "Large" ? size.large :
     size.huge

//====================================================
// Candle classification
//====================================================
bullCandle = close > open
bearCandle = close < open
dojiCandle = close == open

bullCount = math.sum(bullCandle ? 1 : 0, lookback)
bearCount = math.sum(bearCandle ? 1 : 0, lookback)
dojiCount = math.sum(dojiCandle ? 1 : 0, lookback)

countedBars = bullCount + bearCount
bullPct = countedBars > 0 ? bullCount / countedBars : 0.0
bearPct = countedBars > 0 ? bearCount / countedBars : 0.0

netBias = bullPct - bearPct

//====================================================
// State logic
//====================================================
isBalanced = math.abs(bullPct - bearPct) <= balanceThreshold
isBullish = not isBalanced and bullPct > bearPct
isBearish = not isBalanced and bearPct > bullPct

state = isBullish ? 1 : isBearish ? -1 : 0
stateChanged = state != nz(state[1])

stateText = isBullish ? "Bullish" : isBearish ? "Bearish" : "Balanced"
stateColor = isBullish ? bullColor : isBearish ? bearColor : balancedColor
stateBg = isBullish ? bullBgColor : isBearish ? bearBgColor : balancedBgColor

//====================================================
// Plots
//====================================================
hline(0, "Zero", color=color.gray)
hline(balanceThreshold, "Balanced +", color=color.new(color.gray, 70))
hline(-balanceThreshold, "Balanced -", color=color.new(color.gray, 70))

plot(showHistogram ? netBias : na, title="Net Bias", style=plot.style_histogram, linewidth=3, color=stateColor)
plot(showBullLine ? bullPct : na, title="Bull %", color=bullColor, linewidth=2)
plot(showBearLine ? bearPct : na, title="Bear %", color=bearColor, linewidth=2)

bgcolor(showBackground ? stateBg : na)

//====================================================
// State change markers
//====================================================
plotshape(showMarkers and stateChanged and isBullish, title="Bullish State", style=shape.triangleup, location=location.bottom, size=size.tiny, color=bullColor, text="Bull")
plotshape(showMarkers and stateChanged and isBearish, title="Bearish State", style=shape.triangledown, location=location.top, size=size.tiny, color=bearColor, text="Bear")
plotshape(showMarkers and stateChanged and isBalanced, title="Balanced State", style=shape.circle, location=location.bottom, size=size.tiny, color=balancedColor, text="Bal")

//====================================================
// Table
//====================================================
var table t = table.new(tblPos, 2, 6)

if barstate.islast
    table.cell(t, 0, 0, "Metric", text_color=color.white, bgcolor=color.black, text_size=tblSize)
    table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.black, text_size=tblSize)

    table.cell(t, 0, 1, "Bull Count", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 1, str.tostring(bullCount), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 2, "Bear Count", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 2, str.tostring(bearCount), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 3, "Doji Count", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 3, str.tostring(dojiCount), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 4, "Bull %", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 4, str.tostring(bullPct * 100, "#.0") + "%", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 5, "State", text_color=color.white, bgcolor=stateColor, text_size=tblSize)
    table.cell(t, 1, 5, stateText, text_color=color.white, bgcolor=stateColor, text_size=tblSize)

//====================================================
// Alerts
//====================================================
alertcondition(stateChanged and isBullish, title="Bullish State", message="Bull vs Bear Candle Count shifted to Bullish on {{ticker}} {{interval}}")
alertcondition(stateChanged and isBearish, title="Bearish State", message="Bull vs Bear Candle Count shifted to Bearish on {{ticker}} {{interval}}")
alertcondition(stateChanged and isBalanced, title="Balanced State", message="Bull vs Bear Candle Count shifted to Balanced on {{ticker}} {{interval}}")
````
