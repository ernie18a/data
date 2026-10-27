# Time Flow Money Flow Dashboard

- url: https://www.tradingview.com/script/HkZ15T51-Time-Flow-Money-Flow-Dashboard/
- type: indicator
- pine_id: PUB;40b1c1504d4b4c11821f585e7ea0ccbd
- version: 2.0

## Description

Time Flow Money Flow Dashboard is a multi-timeframe bias and execution dashboard designed to show money-flow direction, dot signals, divergence, and 1/16th strategy alignment in one compact row.

Each box represents a configurable higher timeframe. The box turns green when smoothed Money Flow Index is rising and red when it is lowering. The dashboard also reports whether that timeframe has a fresh green dot, red dot, or no new dot.

The script includes:

• Multi-timeframe money-flow direction
• Green dot / red dot flip detection
• Bullish and bearish money-flow divergence detection
• 1/16th strategy alignment
• Automatic lower-timeframe derivation from each higher timeframe
• Lower-timeframe EMA crossover confirmation
• Configurable dashboard position
• Configurable MFI length, smoothing, divergence pivots, and EMA crossover settings

The 1/16th strategy logic uses the higher timeframe for directional bias and the 1/16 lower timeframe for execution timing. A long setup appears when higher-timeframe bias is bullish, lower-timeframe money flow is rising, and the lower timeframe fast EMA crosses above the slow EMA. A short setup appears when higher-timeframe bias is bearish, lower-timeframe money flow is lowering, and the lower timeframe fast EMA crosses below the slow EMA.

This tool is intended as a visual confluence dashboard, not a standalone buy/sell system. Always confirm with market structure, liquidity, volume, and risk management.

## Source Code

````pine
//@version=6
indicator("Time Flow Money Flow Dashboard", shorttitle="TF Money Flow", overlay=true)

// Dashboard settings
moneyFlowLength = input.int(14, "Money flow length", minval=1)
smoothLength = input.int(3, "Money flow smoothing", minval=1)
useClosedTimeFlowBars = input.bool(false, "Use only closed time-flow candles")
showMoneyFlowValue = input.bool(true, "Show money flow value")
showDivergence = input.bool(true, "Show divergence")
divergencePivotLeft = input.int(3, "Divergence pivot left bars", minval=1)
divergencePivotRight = input.int(3, "Divergence pivot right bars", minval=1)
divergenceActiveBars = input.int(8, "Divergence stays active for bars", minval=1)
showOneSixteenthStrategy = input.bool(true, "Show 1/16 strategy")
showOneSixteenthChartSignals = input.bool(true, "Print 1/16 setup on chart")
allowSecondsForOneSixteenth = input.bool(false, "Allow seconds for 1/16 lower flows")
oneSixteenthFastLength = input.int(9, "1/16 fast EMA length", minval=1)
oneSixteenthSlowLength = input.int(21, "1/16 slow EMA length", minval=1)
oneSixteenthCrossoverActiveBars = input.int(16, "1/16 crossover stays active for lower bars", minval=1)
dashboardPositionInput = input.string(
     "Top left",
     "Dashboard position",
     options=[
         "Top left",
         "Top center",
         "Top right",
         "Middle left",
         "Middle center",
         "Middle right",
         "Bottom left",
         "Bottom center",
         "Bottom right"])

// Time-flow slots
tf1 = input.timeframe("1", "Time Flow 1")
tf1Label = input.string("1m", "Label 1")
tf2 = input.timeframe("3", "Time Flow 2")
tf2Label = input.string("3m", "Label 2")
tf3 = input.timeframe("5", "Time Flow 3")
tf3Label = input.string("5m", "Label 3")
tf4 = input.timeframe("15", "Time Flow 4")
tf4Label = input.string("15m", "Label 4")
tf5 = input.timeframe("30", "Time Flow 5")
tf5Label = input.string("30m", "Label 5")
tf6 = input.timeframe("60", "Time Flow 6")
tf6Label = input.string("1H", "Label 6")
tf7 = input.timeframe("240", "Time Flow 7")
tf7Label = input.string("4H", "Label 7")
tf8 = input.timeframe("D", "Time Flow 8")
tf8Label = input.string("1D", "Label 8")

// Colors
risingColor = input.color(color.rgb(24, 148, 78), "Rising money flow box")
loweringColor = input.color(color.rgb(180, 45, 45), "Lowering money flow box")
neutralColor = input.color(color.rgb(72, 78, 88), "Not enough data box")
headerColor = input.color(color.rgb(22, 25, 31), "Header box")
textColor = input.color(color.white, "Text")

calcTimeFlowReport() =>
    rawMoneyFlow = ta.mfi(hlc3, moneyFlowLength)
    moneyFlow = ta.ema(rawMoneyFlow, smoothLength) - 50.0
    moneyFlowIsRising = moneyFlow >= moneyFlow[1]
    greenDot = moneyFlowIsRising and not moneyFlowIsRising[1]
    redDot = not moneyFlowIsRising and moneyFlowIsRising[1]

    pricePivotLow = ta.pivotlow(low, divergencePivotLeft, divergencePivotRight)
    pricePivotHigh = ta.pivothigh(high, divergencePivotLeft, divergencePivotRight)
    moneyFlowAtLowPivot = moneyFlow[divergencePivotRight]
    moneyFlowAtHighPivot = moneyFlow[divergencePivotRight]

    previousPricePivotLow = ta.valuewhen(not na(pricePivotLow), pricePivotLow, 1)
    previousMoneyFlowAtLowPivot = ta.valuewhen(not na(pricePivotLow), moneyFlowAtLowPivot, 1)
    previousPricePivotHigh = ta.valuewhen(not na(pricePivotHigh), pricePivotHigh, 1)
    previousMoneyFlowAtHighPivot = ta.valuewhen(not na(pricePivotHigh), moneyFlowAtHighPivot, 1)

    newBullishDivergence = not na(pricePivotLow) and
         not na(previousPricePivotLow) and
         pricePivotLow < previousPricePivotLow and
         moneyFlowAtLowPivot > previousMoneyFlowAtLowPivot

    newBearishDivergence = not na(pricePivotHigh) and
         not na(previousPricePivotHigh) and
         pricePivotHigh > previousPricePivotHigh and
         moneyFlowAtHighPivot < previousMoneyFlowAtHighPivot

    barsSinceBullishDivergence = nz(ta.barssince(newBullishDivergence), 1000000)
    barsSinceBearishDivergence = nz(ta.barssince(newBearishDivergence), 1000000)
    bullishDivergenceInPlay = barsSinceBullishDivergence <= divergenceActiveBars and
         barsSinceBullishDivergence <= barsSinceBearishDivergence
    bearishDivergenceInPlay = barsSinceBearishDivergence <= divergenceActiveBars and
         barsSinceBearishDivergence < barsSinceBullishDivergence
    divergenceSignal = bullishDivergenceInPlay ? 1 : bearishDivergenceInPlay ? -1 : 0

    reportMoneyFlow = useClosedTimeFlowBars ? moneyFlow[1] : moneyFlow
    reportIsRising = useClosedTimeFlowBars ? moneyFlowIsRising[1] : moneyFlowIsRising
    reportGreenDot = useClosedTimeFlowBars ? greenDot[1] : greenDot
    reportRedDot = useClosedTimeFlowBars ? redDot[1] : redDot
    reportDivergenceSignal = useClosedTimeFlowBars ? divergenceSignal[1] : divergenceSignal

    [reportMoneyFlow, reportIsRising, reportGreenDot, reportRedDot, reportDivergenceSignal]

getTimeFlowReport(timeFlow) =>
    request.security(
         syminfo.tickerid,
         timeFlow,
         calcTimeFlowReport(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

getOneSixteenthTimeFlow(timeFlow) =>
    oneSixteenthSeconds = timeframe.in_seconds(timeFlow) / 16.0
    roundedSeconds = allowSecondsForOneSixteenth
         ? math.max(1, int(math.round(oneSixteenthSeconds)))
         : math.max(60, int(math.round(oneSixteenthSeconds / 60.0)) * 60)
    timeframe.from_seconds(roundedSeconds)

calcOneSixteenthExecution() =>
    fastAverage = ta.ema(close, oneSixteenthFastLength)
    slowAverage = ta.ema(close, oneSixteenthSlowLength)
    bullishCrossover = ta.crossover(fastAverage, slowAverage)
    bearishCrossover = ta.crossunder(fastAverage, slowAverage)
    bullishCrossoverActive = nz(ta.barssince(bullishCrossover), 1000000) <= oneSixteenthCrossoverActiveBars
    bearishCrossoverActive = nz(ta.barssince(bearishCrossover), 1000000) <= oneSixteenthCrossoverActiveBars

    rawMoneyFlow = ta.mfi(hlc3, moneyFlowLength)
    moneyFlow = ta.ema(rawMoneyFlow, smoothLength) - 50.0
    moneyFlowIsRising = moneyFlow >= moneyFlow[1]

    [moneyFlowIsRising, bullishCrossoverActive, bearishCrossoverActive]

getOneSixteenthExecution(timeFlow) =>
    request.security(
         syminfo.tickerid,
         timeFlow,
         calcOneSixteenthExecution(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_off)

getOneSixteenthSignal(higherMoneyFlowIsRising, lowerMoneyFlowIsRising, lowerBullishCrossoverActive, lowerBearishCrossoverActive) =>
    higherMoneyFlowIsRising and lowerMoneyFlowIsRising and lowerBullishCrossoverActive ? 1 :
         not higherMoneyFlowIsRising and not lowerMoneyFlowIsRising and lowerBearishCrossoverActive ? -1 : 0

[mf1, rising1, greenDot1, redDot1, div1] = getTimeFlowReport(tf1)
[mf2, rising2, greenDot2, redDot2, div2] = getTimeFlowReport(tf2)
[mf3, rising3, greenDot3, redDot3, div3] = getTimeFlowReport(tf3)
[mf4, rising4, greenDot4, redDot4, div4] = getTimeFlowReport(tf4)
[mf5, rising5, greenDot5, redDot5, div5] = getTimeFlowReport(tf5)
[mf6, rising6, greenDot6, redDot6, div6] = getTimeFlowReport(tf6)
[mf7, rising7, greenDot7, redDot7, div7] = getTimeFlowReport(tf7)
[mf8, rising8, greenDot8, redDot8, div8] = getTimeFlowReport(tf8)

tf1OneSixteenth = getOneSixteenthTimeFlow(tf1)
tf2OneSixteenth = getOneSixteenthTimeFlow(tf2)
tf3OneSixteenth = getOneSixteenthTimeFlow(tf3)
tf4OneSixteenth = getOneSixteenthTimeFlow(tf4)
tf5OneSixteenth = getOneSixteenthTimeFlow(tf5)
tf6OneSixteenth = getOneSixteenthTimeFlow(tf6)
tf7OneSixteenth = getOneSixteenthTimeFlow(tf7)
tf8OneSixteenth = getOneSixteenthTimeFlow(tf8)

[mfRising1OneSixteenth, bullishCross1OneSixteenth, bearishCross1OneSixteenth] = getOneSixteenthExecution(tf1OneSixteenth)
[mfRising2OneSixteenth, bullishCross2OneSixteenth, bearishCross2OneSixteenth] = getOneSixteenthExecution(tf2OneSixteenth)
[mfRising3OneSixteenth, bullishCross3OneSixteenth, bearishCross3OneSixteenth] = getOneSixteenthExecution(tf3OneSixteenth)
[mfRising4OneSixteenth, bullishCross4OneSixteenth, bearishCross4OneSixteenth] = getOneSixteenthExecution(tf4OneSixteenth)
[mfRising5OneSixteenth, bullishCross5OneSixteenth, bearishCross5OneSixteenth] = getOneSixteenthExecution(tf5OneSixteenth)
[mfRising6OneSixteenth, bullishCross6OneSixteenth, bearishCross6OneSixteenth] = getOneSixteenthExecution(tf6OneSixteenth)
[mfRising7OneSixteenth, bullishCross7OneSixteenth, bearishCross7OneSixteenth] = getOneSixteenthExecution(tf7OneSixteenth)
[mfRising8OneSixteenth, bullishCross8OneSixteenth, bearishCross8OneSixteenth] = getOneSixteenthExecution(tf8OneSixteenth)

oneSixteenthSignal1 = getOneSixteenthSignal(rising1, mfRising1OneSixteenth, bullishCross1OneSixteenth, bearishCross1OneSixteenth)
oneSixteenthSignal2 = getOneSixteenthSignal(rising2, mfRising2OneSixteenth, bullishCross2OneSixteenth, bearishCross2OneSixteenth)
oneSixteenthSignal3 = getOneSixteenthSignal(rising3, mfRising3OneSixteenth, bullishCross3OneSixteenth, bearishCross3OneSixteenth)
oneSixteenthSignal4 = getOneSixteenthSignal(rising4, mfRising4OneSixteenth, bullishCross4OneSixteenth, bearishCross4OneSixteenth)
oneSixteenthSignal5 = getOneSixteenthSignal(rising5, mfRising5OneSixteenth, bullishCross5OneSixteenth, bearishCross5OneSixteenth)
oneSixteenthSignal6 = getOneSixteenthSignal(rising6, mfRising6OneSixteenth, bullishCross6OneSixteenth, bearishCross6OneSixteenth)
oneSixteenthSignal7 = getOneSixteenthSignal(rising7, mfRising7OneSixteenth, bullishCross7OneSixteenth, bearishCross7OneSixteenth)
oneSixteenthSignal8 = getOneSixteenthSignal(rising8, mfRising8OneSixteenth, bullishCross8OneSixteenth, bearishCross8OneSixteenth)

chartMoneyFlow = ta.ema(ta.mfi(hlc3, moneyFlowLength), smoothLength) - 50.0
chartMoneyFlowIsRising = chartMoneyFlow >= chartMoneyFlow[1]
chartOneSixteenthTimeFlow = getOneSixteenthTimeFlow(timeframe.period)
[chartOneSixteenthMoneyFlowIsRising, chartOneSixteenthBullishCrossover, chartOneSixteenthBearishCrossover] = getOneSixteenthExecution(chartOneSixteenthTimeFlow)
chartOneSixteenthSignal = getOneSixteenthSignal(
     chartMoneyFlowIsRising,
     chartOneSixteenthMoneyFlowIsRising,
     chartOneSixteenthBullishCrossover,
     chartOneSixteenthBearishCrossover)

chartOneSixteenthLongSetup = showOneSixteenthChartSignals and chartOneSixteenthSignal == 1
chartOneSixteenthShortSetup = showOneSixteenthChartSignals and chartOneSixteenthSignal == -1
newOneSixteenthLongSetup = chartOneSixteenthLongSetup and not chartOneSixteenthLongSetup[1]
newOneSixteenthShortSetup = chartOneSixteenthShortSetup and not chartOneSixteenthShortSetup[1]

dashboardPosition = switch dashboardPositionInput
    "Top center" => position.top_center
    "Top right" => position.top_right
    "Middle left" => position.middle_left
    "Middle center" => position.middle_center
    "Middle right" => position.middle_right
    "Bottom left" => position.bottom_left
    "Bottom center" => position.bottom_center
    "Bottom right" => position.bottom_right
    => position.top_left

var table dashboard = table.new(
     dashboardPosition,
     9,
     1,
     border_width=1,
     frame_color=color.new(textColor, 70),
     border_color=color.new(textColor, 80))

drawBox(column, label, moneyFlow, moneyFlowIsRising, greenDot, redDot, divergenceSignal, oneSixteenthTimeFlow, oneSixteenthSignal) =>
    hasData = not na(moneyFlow)
    dotText = greenDot ? "GREEN DOT" : redDot ? "RED DOT" : "NO DOT"
    divergenceText = divergenceSignal == 1 ? "BULL DIV" : divergenceSignal == -1 ? "BEAR DIV" : "NO DIV"
    oneSixteenthText = oneSixteenthSignal == 1 ? "1/16 " + oneSixteenthTimeFlow + " LONG" : oneSixteenthSignal == -1 ? "1/16 " + oneSixteenthTimeFlow + " SHORT" : "1/16 " + oneSixteenthTimeFlow + " WAIT"
    directionText = moneyFlowIsRising ? "RISING" : "LOWERING"
    valueText = showMoneyFlowValue and hasData ? "\nMF " + str.tostring(moneyFlow, "#.0") : ""
    divergenceLine = showDivergence ? "\n" + divergenceText : ""
    oneSixteenthLine = showOneSixteenthStrategy ? "\n" + oneSixteenthText : ""
    boxText = label + "  " + directionText + "\n" + dotText + divergenceLine + oneSixteenthLine + valueText
    boxColor = hasData ? (moneyFlowIsRising ? risingColor : loweringColor) : neutralColor

    table.cell(
         dashboard,
         column,
         0,
         boxText,
         text_color=textColor,
         bgcolor=boxColor,
         text_size=size.small,
         text_halign=text.align_center)

if barstate.islast
    liveText = useClosedTimeFlowBars ? "CLOSED" : "LIVE"
    table.cell(
         dashboard,
         0,
         0,
         "TIME FLOW REPORT\n" + liveText,
         text_color=textColor,
         bgcolor=headerColor,
         text_size=size.small,
         text_halign=text.align_center)

    drawBox(1, tf1Label, mf1, rising1, greenDot1, redDot1, div1, tf1OneSixteenth, oneSixteenthSignal1)
    drawBox(2, tf2Label, mf2, rising2, greenDot2, redDot2, div2, tf2OneSixteenth, oneSixteenthSignal2)
    drawBox(3, tf3Label, mf3, rising3, greenDot3, redDot3, div3, tf3OneSixteenth, oneSixteenthSignal3)
    drawBox(4, tf4Label, mf4, rising4, greenDot4, redDot4, div4, tf4OneSixteenth, oneSixteenthSignal4)
    drawBox(5, tf5Label, mf5, rising5, greenDot5, redDot5, div5, tf5OneSixteenth, oneSixteenthSignal5)
    drawBox(6, tf6Label, mf6, rising6, greenDot6, redDot6, div6, tf6OneSixteenth, oneSixteenthSignal6)
    drawBox(7, tf7Label, mf7, rising7, greenDot7, redDot7, div7, tf7OneSixteenth, oneSixteenthSignal7)
    drawBox(8, tf8Label, mf8, rising8, greenDot8, redDot8, div8, tf8OneSixteenth, oneSixteenthSignal8)

plotshape(
     newOneSixteenthLongSetup,
     title="1/16 Long setup",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(risingColor, 0),
     text="1/16\nLONG",
     textcolor=textColor,
     size=size.small)

plotshape(
     newOneSixteenthShortSetup,
     title="1/16 Short setup",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(loweringColor, 0),
     text="1/16\nSHORT",
     textcolor=textColor,
     size=size.small)
````
