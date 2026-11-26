# VolaSync

- url: https://www.tradingview.com/script/JI95SALG/
- type: indicator
- pine_id: PUB;8e02c22ef8e84aea8d1dbc5ad4288583
- version: 1.0

## Description

## VolaSync

**VolaSync is a session-based trend and momentum indicator designed to simplify intraday market reading by combining directional momentum, persistent market regimes, dynamic trend visualization, and session context in a single chart.**

The main purpose of VolaSync is not to predict the next candle, but to help traders identify when market conditions have transitioned from one directional state to another.

### How it works

VolaSync combines three main elements:

- **Momentum:** a composite reading based on RSI and Money Flow Index.
- **Direction:** short-term EMA slope is used as directional confirmation.
- **Persistent regime logic:** once a bullish or bearish state is confirmed, the indicator maintains that state until a complete opposite condition occurs.

This helps reduce unnecessary regime changes during small price fluctuations and consolidations.

### Market Regimes

VolaSync works with persistent directional states.

**Bullish regime**
- Positive momentum condition is confirmed.
- Short-term direction is rising.
- Candles are displayed in green.

**Bearish regime**
- Negative momentum condition is confirmed.
- Short-term direction is falling.
- Candles are displayed in red.

The area between the bullish and bearish momentum thresholds acts as a transition zone. Entering this zone alone does not reverse the active market regime.

### Entry Markers

VolaSync displays minimalist directional markers when a confirmed regime transition occurs:

▲ Bullish transition  
▼ Bearish transition

Markers are only generated when the underlying regime actually changes.

Signals are confirmed on closed candles to provide a more consistent historical and real-time reading.

### VolaSync Trend Band

The indicator includes a dynamic trend band based on:

- candle range weighting;
- market volatility;
- ATR;
- current directional regime.

The band provides a visual reference for trend structure and directional context.

It does not independently generate the entry signal.

### Asia Session

VolaSync includes an integrated Asia Session module designed to provide additional context for traders who focus on this trading window.

The module can:

- highlight the Asia trading session;
- identify the session range;
- track Asia High and Asia Low;
- extend session levels;
- filter directional signals to the Asia Session only.

The session window can be adjusted through the indicator settings.

### Signal Modes

Users can choose between:

**Asia Session Only**

Displays regime-transition signals occurring inside the configured Asia Session.

**All Day**

Displays every confirmed VolaSync regime transition throughout the trading day.

### Suggested workflow

A simple way to use VolaSync is:

**Session context → directional regime → confirmed transition → trade evaluation**

The indicator is intended to simplify market structure and directional reading rather than replace risk management or execution rules.

### Customization

Users can configure:

- Momentum Length
- Bullish / Bearish thresholds
- EMA Length
- Trend Band parameters
- Signal marker size and distance
- Bull / Bear colors
- Asia Session hours
- Asia High / Low visualization
- Session signal filter

### Important

VolaSync is a technical analysis and educational tool.

It does not guarantee profitable trades or future market performance. Market conditions can change, and signals should always be evaluated together with appropriate risk management and the trader's own execution criteria.

## Source Code

````pine
//@version=6
indicator("VolaSync", shorttitle="VolaSync", overlay=true, max_boxes_count=50, max_lines_count=100, max_labels_count=100)

plot(close, title="VolaSync Output Anchor", display=display.none)

//==============================================================================
// VolaSync Engine V1
// Original baseline indicator:
// - Confirmed momentum + EMA direction switches regime.
// - Regime persists until a full opposite confirmed condition appears.
// - Signals are generated only on regime transitions and only on confirmed bars.
// - No lookahead, negative signal offsets, or future data in the signal engine.
//==============================================================================

//------------------------------------------------------------------------------
// INPUTS
//------------------------------------------------------------------------------
groupEngine = "VolaSync Engine"
momentumLengthInput = input.int(14, "Momentum Length", minval=2, group=groupEngine)
bullThresholdInput = input.float(66.0, "Bull Threshold", minval=50.0, maxval=100.0, step=0.1, group=groupEngine)
bearThresholdInput = input.float(30.0, "Bear Threshold", minval=0.0, maxval=50.0, step=0.1, group=groupEngine)
emaLengthInput = input.int(5, "EMA Length", minval=1, group=groupEngine)

groupVisual = "Visual"
colorCandlesInput = input.bool(true, "Color Candles", group=groupVisual)
showSignalsInput = input.bool(true, "Show Signals", group=groupVisual)
signalMarkerSizeInput = input.string("Small", "Signal Marker Size", options=["Tiny", "Small", "Normal"], group=groupVisual)
signalOffsetMultiplierInput = input.float(0.35, "Signal Offset Multiplier", minval=0.1, step=0.05, group=groupVisual)
showEntryDotInput = input.bool(false, "Show Entry Dot", group=groupVisual)
bullColorInput = input.color(color.rgb(0, 184, 148), "Bull Color", group=groupVisual)
bearColorInput = input.color(color.rgb(225, 70, 70), "Bear Color", group=groupVisual)
neutralColorInput = input.color(color.rgb(128, 135, 145), "Neutral Color", group=groupVisual)

groupBand = "Trend Band"
showTrendBandInput = input.bool(true, "Show Trend Band", group=groupBand)
bandMaLengthInput = input.int(20, "Band MA Length", minval=1, group=groupBand)
atrLengthInput = input.int(30, "ATR Length", minval=1, group=groupBand)
atrMultiplierInput = input.float(0.30, "ATR Multiplier", minval=0.01, step=0.01, group=groupBand)
maxPricePercentageInput = input.float(0.30, "Max Price Percentage (%)", minval=0.01, step=0.01, group=groupBand)
bandLookbackInput = input.int(20, "Band Lookback", minval=0, group=groupBand)
bandExpansionInput = input.float(4.0, "Band Expansion", minval=0.1, step=0.1, group=groupBand)

groupAsia = "Asia Session"
showAsiaSessionInput = input.bool(true, "Show Asia Session", group=groupAsia)
asiaSessionInput = input.session("2000-0000", "Asia Session", group=groupAsia)
showAsiaRangeInput = input.bool(true, "Show Asia Range", group=groupAsia)
showAsiaHighLowInput = input.bool(true, "Show Asia High/Low", group=groupAsia)
extendAsiaLevelsInput = input.bool(true, "Extend Asia Levels", group=groupAsia)
historicalAsiaSessionsInput = input.int(5, "Historical Asia Sessions", minval=1, maxval=20, group=groupAsia)
signalWindowInput = input.string("Asia Session Only", "Signal Window", options=["Asia Session Only", "All Day"], group=groupAsia)
asiaColorInput = input.color(color.rgb(80, 160, 255), "Asia Color", group=groupAsia)

groupDevelopment = "Development"
debugModeInput = input.bool(false, "Debug Mode", group=groupDevelopment)

if barstate.isfirst and bearThresholdInput >= bullThresholdInput
    runtime.error("VolaSync input error: Bear Threshold must be lower than Bull Threshold.")

//------------------------------------------------------------------------------
// HELPERS
//------------------------------------------------------------------------------
f_boolToInt(bool value) =>
    value ? 1 : 0

f_rangeWeightedMa(int length) =>
    float weightedSum = 0.0
    float weightSum = 0.0

    for index = 0 to length - 1
        float candleRange = high[index] - low[index]
        float candleClose = close[index]
        bool validSample = not na(candleRange) and not na(candleClose) and candleRange > 0.0

        if validSample
            weightedSum += candleClose * candleRange
            weightSum += candleRange

    weightSum > 0.0 ? weightedSum / weightSum : na

//------------------------------------------------------------------------------
// MODULE 1 - MOMENTUM ENGINE
//------------------------------------------------------------------------------
rsiValue = ta.rsi(close, momentumLengthInput)
mfiValue = ta.mfi(hlc3, momentumLengthInput)
volaSyncMomentum = (rsiValue + mfiValue) / 2.0

//------------------------------------------------------------------------------
// MODULE 2 - DIRECTION ENGINE
//------------------------------------------------------------------------------
directionEma = ta.ema(close, emaLengthInput)
emaRising = not na(directionEma[1]) and directionEma > directionEma[1]
emaFalling = not na(directionEma[1]) and directionEma < directionEma[1]

bullCondition = volaSyncMomentum > bullThresholdInput and emaRising and barstate.isconfirmed
bearCondition = volaSyncMomentum < bearThresholdInput and emaFalling and barstate.isconfirmed

//------------------------------------------------------------------------------
// MODULE 3 - REGIME / STATE ENGINE
//------------------------------------------------------------------------------
var int regime = 0
int previousRegime = nz(regime[1], 0)

if barstate.isconfirmed
    if bullCondition
        regime := 1
    else if bearCondition
        regime := -1
    else
        regime := previousRegime
else
    regime := previousRegime

//------------------------------------------------------------------------------
// MODULE - VOLASYNC ASIA SESSION CONTEXT
//------------------------------------------------------------------------------
asiaTime = time(timeframe.period, asiaSessionInput, "America/New_York")
inAsia = not na(asiaTime)
wasInAsia = bar_index > 0 ? inAsia[1] : false
asiaStart = inAsia and not wasInAsia
asiaEnd = not inAsia and wasInAsia

string standardTicker = ticker.new(syminfo.prefix, syminfo.ticker)
[realHigh, realLow] = request.security(standardTicker, timeframe.period, [high, low], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

var float asiaHigh = na
var float asiaLow = na

var box currentAsiaBox = na
var line currentAsiaHighLine = na
var line currentAsiaLowLine = na
var label currentAsiaLabel = na
var label currentAsiaHighLabel = na
var label currentAsiaLowLabel = na

var array<box> asiaBoxes = array.new<box>()
var array<line> asiaHighLines = array.new<line>()
var array<line> asiaLowLines = array.new<line>()
var array<label> asiaLabels = array.new<label>()
var array<label> asiaHighLabels = array.new<label>()
var array<label> asiaLowLabels = array.new<label>()

asiaBoxBgColor = color.new(asiaColorInput, 93)
asiaBoxBorderColor = color.new(asiaColorInput, 72)
asiaLineColor = color.new(asiaColorInput, 20)
asiaLabelBgColor = color.new(asiaColorInput, 82)

//------------------------------------------------------------------------------
// MODULE 4 - SIGNAL ENGINE
//------------------------------------------------------------------------------
buySignal = barstate.isconfirmed and regime == 1 and previousRegime != 1
sellSignal = barstate.isconfirmed and regime == -1 and previousRegime != -1

asiaBuySignal = buySignal and inAsia
asiaSellSignal = sellSignal and inAsia
showAllDaySignals = signalWindowInput == "All Day"
visibleBuySignal = showSignalsInput and (showAllDaySignals ? buySignal : asiaBuySignal)
visibleSellSignal = showSignalsInput and (showAllDaySignals ? sellSignal : asiaSellSignal)

//------------------------------------------------------------------------------
// MODULE 5 - TREND BAND CALCULATION
//------------------------------------------------------------------------------
// VolaSync Trend Band is visual only. It does not affect regime or signals.
rangeWeightedMa = f_rangeWeightedMa(bandMaLengthInput)
atrValue = ta.atr(atrLengthInput)
atrBandWidth = atrValue * atrMultiplierInput
percentageBandWidth = close * (maxPricePercentageInput / 100.0)
rawBand = math.min(atrBandWidth, percentageBandWidth)
bandWidth = rawBand[bandLookbackInput] * bandExpansionInput

trendCenter = regime == 1 ? rangeWeightedMa - bandWidth : regime == -1 ? rangeWeightedMa + bandWidth : na
upperBand = not na(trendCenter) ? trendCenter + bandWidth : na
lowerBand = not na(trendCenter) ? trendCenter - bandWidth : na

bandMainColor = regime == 1 ? color.rgb(0, 200, 170) : regime == -1 ? color.rgb(225, 70, 70) : color.rgb(128, 135, 145)
bandFillColor = color.new(bandMainColor, 86)
bandEdgeColor = color.new(bandMainColor, 65)

//------------------------------------------------------------------------------
// MODULE 6 - CUSTOM CANDLE RENDERING
//------------------------------------------------------------------------------
candleColor = regime == 1 ? bullColorInput : regime == -1 ? bearColorInput : neutralColorInput

plotcandle(colorCandlesInput ? open : na, colorCandlesInput ? high : na, colorCandlesInput ? low : na, colorCandlesInput ? close : na, title="VolaSync Candles", color=candleColor, wickcolor=candleColor, bordercolor=candleColor)

//------------------------------------------------------------------------------
// MODULE 7 - TREND BAND RENDERING
//------------------------------------------------------------------------------
centerPlot = plot(showTrendBandInput ? trendCenter : na, "VolaSync Trend Band Center", color=bandMainColor, linewidth=2)
upperPlot = plot(showTrendBandInput ? upperBand : na, "VolaSync Trend Band Upper", color=bandEdgeColor, linewidth=1)
lowerPlot = plot(showTrendBandInput ? lowerBand : na, "VolaSync Trend Band Lower", color=bandEdgeColor, linewidth=1)
fill(upperPlot, lowerPlot, color=showTrendBandInput ? bandFillColor : na, title="VolaSync Trend Band Fill")

//------------------------------------------------------------------------------
// MODULE 8 - ENTRY MARKER RENDERING
//------------------------------------------------------------------------------
buyMarkerY = not na(lowerBand) and not na(bandWidth) ? lowerBand - (bandWidth * signalOffsetMultiplierInput) : low
sellMarkerY = not na(upperBand) and not na(bandWidth) ? upperBand + (bandWidth * signalOffsetMultiplierInput) : high
buyEntryDotY = visibleBuySignal and showEntryDotInput ? low : na
sellEntryDotY = visibleSellSignal and showEntryDotInput ? high : na

useTinySignalMarker = signalMarkerSizeInput == "Tiny"
useSmallSignalMarker = signalMarkerSizeInput == "Small"
useNormalSignalMarker = signalMarkerSizeInput == "Normal"

plotshape(visibleBuySignal and useTinySignalMarker ? buyMarkerY : na, title="VolaSync BUY Marker Tiny", style=shape.triangleup, location=location.absolute, color=bullColorInput, size=size.tiny)
plotshape(visibleSellSignal and useTinySignalMarker ? sellMarkerY : na, title="VolaSync SELL Marker Tiny", style=shape.triangledown, location=location.absolute, color=bearColorInput, size=size.tiny)
plotshape(visibleBuySignal and useSmallSignalMarker ? buyMarkerY : na, title="VolaSync BUY Marker Small", style=shape.triangleup, location=location.absolute, color=bullColorInput, size=size.small)
plotshape(visibleSellSignal and useSmallSignalMarker ? sellMarkerY : na, title="VolaSync SELL Marker Small", style=shape.triangledown, location=location.absolute, color=bearColorInput, size=size.small)
plotshape(visibleBuySignal and useNormalSignalMarker ? buyMarkerY : na, title="VolaSync BUY Marker Normal", style=shape.triangleup, location=location.absolute, color=bullColorInput, size=size.normal)
plotshape(visibleSellSignal and useNormalSignalMarker ? sellMarkerY : na, title="VolaSync SELL Marker Normal", style=shape.triangledown, location=location.absolute, color=bearColorInput, size=size.normal)
plotshape(buyEntryDotY, title="VolaSync BUY Entry Dot", style=shape.circle, location=location.absolute, color=bullColorInput, size=size.tiny)
plotshape(sellEntryDotY, title="VolaSync SELL Entry Dot", style=shape.circle, location=location.absolute, color=bearColorInput, size=size.tiny)

//------------------------------------------------------------------------------
// MODULE 9 - VOLASYNC ASIA SESSION VISUALS
//------------------------------------------------------------------------------
if asiaStart
    if not na(currentAsiaHighLine)
        line.set_x2(currentAsiaHighLine, math.max(bar_index - 1, 0))
    if not na(currentAsiaLowLine)
        line.set_x2(currentAsiaLowLine, math.max(bar_index - 1, 0))

    asiaHigh := realHigh
    asiaLow := realLow
    currentAsiaBox := na
    currentAsiaHighLine := na
    currentAsiaLowLine := na
    currentAsiaLabel := na
    currentAsiaHighLabel := na
    currentAsiaLowLabel := na

    if showAsiaSessionInput and showAsiaRangeInput and not na(asiaHigh) and not na(asiaLow)
        currentAsiaBox := box.new(left=bar_index, top=asiaHigh, right=bar_index, bottom=asiaLow, xloc=xloc.bar_index, bgcolor=asiaBoxBgColor, border_color=asiaBoxBorderColor, border_width=1)
        array.push(asiaBoxes, currentAsiaBox)

        currentAsiaLabel := label.new(x=bar_index, y=asiaHigh, text="ASIA", xloc=xloc.bar_index, style=label.style_label_down, color=asiaLabelBgColor, textcolor=asiaLineColor, size=size.tiny)
        array.push(asiaLabels, currentAsiaLabel)

    if showAsiaSessionInput and showAsiaHighLowInput and not na(asiaHigh) and not na(asiaLow)
        currentAsiaHighLine := line.new(x1=bar_index, y1=asiaHigh, x2=bar_index, y2=asiaHigh, xloc=xloc.bar_index, color=asiaLineColor, style=line.style_solid, width=1)
        currentAsiaLowLine := line.new(x1=bar_index, y1=asiaLow, x2=bar_index, y2=asiaLow, xloc=xloc.bar_index, color=asiaLineColor, style=line.style_solid, width=1)
        array.push(asiaHighLines, currentAsiaHighLine)
        array.push(asiaLowLines, currentAsiaLowLine)

        currentAsiaHighLabel := label.new(x=bar_index, y=asiaHigh, text="AH", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(asiaColorInput, 100), textcolor=asiaLineColor, size=size.tiny)
        currentAsiaLowLabel := label.new(x=bar_index, y=asiaLow, text="AL", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(asiaColorInput, 100), textcolor=asiaLineColor, size=size.tiny)
        array.push(asiaHighLabels, currentAsiaHighLabel)
        array.push(asiaLowLabels, currentAsiaLowLabel)

    while array.size(asiaBoxes) > historicalAsiaSessionsInput
        box.delete(array.shift(asiaBoxes))
    while array.size(asiaLabels) > historicalAsiaSessionsInput
        label.delete(array.shift(asiaLabels))
    while array.size(asiaHighLines) > historicalAsiaSessionsInput
        line.delete(array.shift(asiaHighLines))
    while array.size(asiaLowLines) > historicalAsiaSessionsInput
        line.delete(array.shift(asiaLowLines))
    while array.size(asiaHighLabels) > historicalAsiaSessionsInput
        label.delete(array.shift(asiaHighLabels))
    while array.size(asiaLowLabels) > historicalAsiaSessionsInput
        label.delete(array.shift(asiaLowLabels))
else if inAsia
    if not na(realHigh)
        asiaHigh := na(asiaHigh) ? realHigh : math.max(asiaHigh, realHigh)
    if not na(realLow)
        asiaLow := na(asiaLow) ? realLow : math.min(asiaLow, realLow)

if inAsia and showAsiaSessionInput and not na(asiaHigh) and not na(asiaLow)
    if showAsiaRangeInput and not na(currentAsiaBox)
        box.set_right(currentAsiaBox, bar_index)
        box.set_top(currentAsiaBox, asiaHigh)
        box.set_bottom(currentAsiaBox, asiaLow)
    if showAsiaRangeInput and not na(currentAsiaLabel)
        label.set_x(currentAsiaLabel, bar_index)
        label.set_y(currentAsiaLabel, asiaHigh)
    if showAsiaHighLowInput and not na(currentAsiaHighLine)
        line.set_x2(currentAsiaHighLine, bar_index)
        line.set_y1(currentAsiaHighLine, asiaHigh)
        line.set_y2(currentAsiaHighLine, asiaHigh)
    if showAsiaHighLowInput and not na(currentAsiaLowLine)
        line.set_x2(currentAsiaLowLine, bar_index)
        line.set_y1(currentAsiaLowLine, asiaLow)
        line.set_y2(currentAsiaLowLine, asiaLow)
    if showAsiaHighLowInput and not na(currentAsiaHighLabel)
        label.set_x(currentAsiaHighLabel, bar_index)
        label.set_y(currentAsiaHighLabel, asiaHigh)
    if showAsiaHighLowInput and not na(currentAsiaLowLabel)
        label.set_x(currentAsiaLowLabel, bar_index)
        label.set_y(currentAsiaLowLabel, asiaLow)

if not inAsia and extendAsiaLevelsInput and showAsiaSessionInput and showAsiaHighLowInput
    if not na(currentAsiaHighLine)
        line.set_x2(currentAsiaHighLine, bar_index)
    if not na(currentAsiaLowLine)
        line.set_x2(currentAsiaLowLine, bar_index)
    if not na(currentAsiaHighLabel) and not na(asiaHigh)
        label.set_x(currentAsiaHighLabel, bar_index)
        label.set_y(currentAsiaHighLabel, asiaHigh)
    if not na(currentAsiaLowLabel) and not na(asiaLow)
        label.set_x(currentAsiaLowLabel, bar_index)
        label.set_y(currentAsiaLowLabel, asiaLow)

if asiaEnd and not extendAsiaLevelsInput and showAsiaSessionInput and showAsiaHighLowInput
    if not na(currentAsiaHighLine)
        line.set_x2(currentAsiaHighLine, math.max(bar_index - 1, 0))
    if not na(currentAsiaLowLine)
        line.set_x2(currentAsiaLowLine, math.max(bar_index - 1, 0))

//------------------------------------------------------------------------------
// MODULE 10 - ALERT ENGINE
//------------------------------------------------------------------------------
alertcondition(buySignal, title="VolaSync BUY", message="VolaSync BUY confirmed")
alertcondition(sellSignal, title="VolaSync SELL", message="VolaSync SELL confirmed")
alertcondition(buySignal or sellSignal, title="VolaSync Signal", message="VolaSync Signal confirmed")
alertcondition(asiaBuySignal, title="VolaSync Asia BUY", message="VolaSync BUY confirmed during Asia Session")
alertcondition(asiaSellSignal, title="VolaSync Asia SELL", message="VolaSync SELL confirmed during Asia Session")

//------------------------------------------------------------------------------
// MODULE 11 - DEBUG ENGINE
//------------------------------------------------------------------------------
plot(debugModeInput ? volaSyncMomentum : na, "Debug - VolaSync Momentum", color=color.new(color.blue, 0), display=display.data_window)
plot(debugModeInput ? rsiValue : na, "Debug - RSI", color=color.new(color.purple, 0), display=display.data_window)
plot(debugModeInput ? mfiValue : na, "Debug - MFI", color=color.new(color.orange, 0), display=display.data_window)
plot(debugModeInput ? directionEma : na, "Debug - EMA", color=color.new(color.yellow, 0), display=display.data_window)
plot(debugModeInput ? f_boolToInt(emaRising) : na, "Debug - EMA Rising", color=color.new(color.green, 0), display=display.data_window)
plot(debugModeInput ? f_boolToInt(emaFalling) : na, "Debug - EMA Falling", color=color.new(color.red, 0), display=display.data_window)
plot(debugModeInput ? f_boolToInt(bullCondition) : na, "Debug - Bull Condition", color=color.new(color.green, 0), display=display.data_window)
plot(debugModeInput ? f_boolToInt(bearCondition) : na, "Debug - Bear Condition", color=color.new(color.red, 0), display=display.data_window)
plot(debugModeInput ? regime : na, "Debug - Current Regime", color=color.new(color.gray, 0), display=display.data_window)
plot(debugModeInput ? f_boolToInt(buySignal) : na, "Debug - Buy Signal", color=color.new(color.green, 0), display=display.data_window)
plot(debugModeInput ? f_boolToInt(sellSignal) : na, "Debug - Sell Signal", color=color.new(color.red, 0), display=display.data_window)
plot(debugModeInput ? bandWidth : na, "Debug - Band Width", color=color.new(color.aqua, 0), display=display.data_window)
plot(debugModeInput ? rangeWeightedMa : na, "Debug - Range Weighted MA", color=color.new(color.teal, 0), display=display.data_window)

var table debugTable = table.new(position.top_right, 2, 8, border_width=1)

if debugModeInput and barstate.islast
    table.cell(debugTable, 0, 0, "VolaSync", bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(debugTable, 1, 0, "Debug", bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(debugTable, 0, 1, "Momentum", text_color=color.white)
    table.cell(debugTable, 1, 1, str.tostring(volaSyncMomentum, "#.##"), text_color=color.white)
    table.cell(debugTable, 0, 2, "RSI / MFI", text_color=color.white)
    table.cell(debugTable, 1, 2, str.tostring(rsiValue, "#.##") + " / " + str.tostring(mfiValue, "#.##"), text_color=color.white)
    table.cell(debugTable, 0, 3, "EMA Direction", text_color=color.white)
    table.cell(debugTable, 1, 3, emaRising ? "Rising" : emaFalling ? "Falling" : "Flat", text_color=color.white)
    table.cell(debugTable, 0, 4, "Regime", text_color=color.white)
    table.cell(debugTable, 1, 4, regime == 1 ? "Bullish" : regime == -1 ? "Bearish" : "Neutral", text_color=color.white)
    table.cell(debugTable, 0, 5, "Bull / Bear", text_color=color.white)
    table.cell(debugTable, 1, 5, str.tostring(bullCondition) + " / " + str.tostring(bearCondition), text_color=color.white)
    table.cell(debugTable, 0, 6, "Buy / Sell", text_color=color.white)
    table.cell(debugTable, 1, 6, str.tostring(buySignal) + " / " + str.tostring(sellSignal), text_color=color.white)
    table.cell(debugTable, 0, 7, "Band Width", text_color=color.white)
    table.cell(debugTable, 1, 7, str.tostring(bandWidth, format.mintick), text_color=color.white)
else if not debugModeInput and barstate.islast
    table.clear(debugTable, 0, 0, 1, 7)
````
