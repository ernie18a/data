# Adaptive RSI Momentum Engine [AlgoChief]

- url: https://www.tradingview.com/script/JIgeanYD-Adaptive-RSI-Momentum-Engine-AlgoChief/
- type: indicator
- pine_id: PUB;11fa39ac1906446b8b6094d409bd4cc9
- version: 1.0

## Description

ABOUT THE INDICATOR

The Relative Strength Index is a core component of technical momentum analysis. However, standard RSI values can remain pinned at extreme levels during strong trending markets and may not fully communicate multi-timeframe momentum conditions.

The Adaptive RSI Momentum Engine expands traditional oscillator analysis into a multi-layered momentum framework designed to identify potential market exhaustion, trend continuation, and momentum turning points.

By combining volatility-adaptive channels, regular and hidden divergence detection, post-signal deviation levels, and an integrated multi-timeframe dashboard, the indicator provides a broader structural view of momentum.

Traders can evaluate whether momentum is expanding or weakening in relation to current volatility conditions and higher-timeframe market trends.


HOW IT WORKS

The indicator operates through several coordinated analytical layers.

1. RSI Momentum Calculation

The core Relative Strength Index is calculated using a user-defined lookback period and price source.

An optional smoothing moving average can be applied to the RSI using SMA, EMA, SMMA/RMA, WMA, or VWMA. This helps reduce market noise and provides a smoother view of the underlying momentum direction.

2. Dynamic Volatility Channels

Dynamic volatility channels can be applied directly to the RSI curve, including Bollinger Bands, Keltner Channels, and Donchian Channels.

These channels allow traders to evaluate momentum expansion relative to current market conditions. When RSI moves beyond the channel boundaries, it can highlight momentum extremes or periods of increased volatility.

3. Divergence Detection

The automated divergence engine analyzes the relationship between price swing points and RSI swing points.

Regular divergences are used to identify potential momentum exhaustion and reversal conditions, while hidden divergences are used to identify potential trend continuation during corrective pullbacks.

4. Deviation Levels

Following confirmed reversal or divergence signals, the indicator can project +1 and +2 standard deviation milestone levels.

These levels provide objective reference points for evaluating whether momentum continues to develop after the initial signal.

5. Multi-Timeframe Dashboard

The integrated multi-timeframe dashboard can monitor divergence conditions, overbought and oversold states, reversal triggers, channel breakouts, and moving-average crosses across up to eight configurable timeframes.

Interactive tooltips also display the number of bars elapsed since a signal was triggered, with signals automatically expiring after 50 bars.


SIGNALS

The indicator provides several visual signals for evaluating changes in momentum and market conditions.

Momentum Reversal Signals

Green upward triangles indicate bullish reversal conditions, while red downward triangles indicate bearish reversal conditions.

A bullish reversal is triggered when RSI pivots upward from an oversold condition or from below the lower dynamic channel.

A bearish reversal is triggered when RSI pivots downward from an overbought condition or from above the upper dynamic channel.

Regular Bullish and Bearish Divergences

Regular bullish divergence occurs when price forms lower swing lows while RSI forms higher lows, indicating weakening downward momentum.

Regular bearish divergence occurs when price forms higher swing highs while RSI forms lower highs, indicating weakening upward momentum.

Hidden Continuation Divergences

Hidden bullish divergence occurs when price forms higher lows while RSI forms lower lows during an established uptrend.

Hidden bearish divergence occurs when price forms lower highs while RSI forms higher highs during an established downtrend.

These patterns are designed to highlight potential continuation conditions following corrective movements.

Smoothing MA Crossovers

Yellow circular markers indicate momentum shifts when the RSI crosses above or below its selected smoothing moving average.

Volatility Channel Breakouts

Circular breakout markers identify instances where RSI moves beyond the upper or lower volatility channel, highlighting potential momentum expansion.

Deviation Level Crossings

Deviation signals occur when RSI crosses the projected +1 or +2 standard deviation levels following an initial reversal or divergence signal.

These signals represent statistical changes in momentum and volatility and should not be interpreted as guaranteed reversal or continuation signals.


KEY FEATURES

• Dynamic volatility channel models including Bollinger Bands, Keltner Channels, and Donchian Channels applied directly to RSI.

• Regular and hidden divergence detection for potential reversal and continuation conditions.

• Forward-projected +1 and +2 standard deviation levels for monitoring post-signal momentum.

• Multi-timeframe dashboard supporting up to eight configurable timeframes.

• Interactive bar-age information showing how recently a signal occurred.

• Visual overbought and oversold exhaustion zones.

• Multiple RSI smoothing methods including SMA, EMA, SMMA/RMA, WMA, and VWMA.

• Comprehensive alerts covering divergences, reversals, channel breakouts, moving-average crosses, and deviation levels.


SETTINGS EXPLANATION

RSI Configuration

Price Source

Selects the price series used for RSI calculation. The default source is Close.

RSI Period

Defines the lookback period used for the core Relative Strength Index calculation.


Exhaustion Horizons

Overbought Horizon

Defines the upper threshold for overbought conditions and exhaustion-zone rendering. Default: 65.

Oversold Horizon

Defines the lower threshold for oversold conditions and exhaustion-zone rendering. Default: 35.


Dynamic Volatility Channels

Channel Model

Selects the volatility channel applied to RSI. Available options include None, Bollinger Bands, Keltner Channel, and Donchian Channel.

Channel Period

Controls the lookback period used for volatility calculations.

Band Multiplier

Adjusts the width of the channel bands by changing the standard deviation or range multiplier.


RSI Smoothing

Smoothing Type

Selects the moving-average method applied to RSI. Available options include None, SMA, EMA, SMMA/RMA, WMA, and VWMA.

Smoothing Period

Defines the lookback period used by the selected smoothing moving average.


Momentum Reversals

Show Momentum Reversal Triggers

Controls the visibility of bullish and bearish reversal markers on the oscillator.

Plot Reversal Deviation Levels (+1/+2)

Enables or disables forward-projected deviation levels following reversal signals.

Reversal Deviation Multiplier

Controls the spacing of the projected reversal deviation levels.


Divergence Engine

Enable Divergence Detection

Activates the pivot-based divergence detection system.

Pivot Lookback

Defines the number of confirmation bars used on the left and right side of swing pivots.

Detect Hidden Continuation Divergence

Enables detection of hidden bullish and bearish continuation divergence.

Plot Divergence Deviation Levels (+1/+2)

Enables or disables projected deviation levels following confirmed divergence signals.

Divergence Deviation Multiplier

Controls the deviation factor used for divergence follow-through projections.


Multi-Timeframe Dashboard

Show Multi-Timeframe Dashboard

Controls the visibility of the multi-timeframe dashboard.

Dashboard Position

Controls the dashboard position within the chart pane.

Available positions include Top Right, Bottom Right, Top Left, and Bottom Left.

Dashboard Size

Controls the dashboard scale with Tiny, Small, Normal, and Large options.

Dashboard Timeframes

Slots 1 through 8 allow individual timeframe selection and enable complete customization of the monitored intervals.


HOW TO USE

For more effective analysis, the indicator should be interpreted together with broader market structure and price action.

1. Identify Exhaustion at Key Structural Levels

When price approaches major support or resistance while RSI enters an overbought or oversold zone, monitor for reversal signals or regular divergences as potential confirmation of momentum exhaustion.

2. Confirm Trend Continuation

During established trends, use hidden divergences and volatility channel breakouts in the direction of the dominant trend to identify potential continuation conditions following corrective pullbacks.

3. Check Multi-Timeframe Alignment

Use the dashboard to determine whether multiple timeframes are showing aligned conditions.

Signals supported across several timeframes can provide stronger analytical context than an isolated signal from a single timeframe.

4. Evaluate Post-Signal Momentum

After a reversal or divergence signal, monitor whether RSI reaches and holds beyond the +1 and +2 deviation levels.

This can help evaluate whether sufficient momentum follow-through is developing before managing trade risk.

Always combine momentum analysis with market structure, appropriate position sizing, and disciplined risk management.


ALERTS

The indicator includes dedicated alert conditions that can be connected to TradingView notifications.

• Bullish Divergence / Bearish Divergence

Triggers when a regular bullish or bearish divergence pattern is confirmed.

• Hidden Bullish Divergence / Hidden Bearish Divergence

Triggers when a hidden continuation divergence is confirmed.

• Bullish Reversal / Bearish Reversal

Triggers when an RSI momentum reversal condition is confirmed.

• Channel Break Up / Channel Break Down

Triggers when RSI moves outside the selected dynamic volatility channel.

• RSI Smoothing Bullish Cross / Bearish Cross

Triggers when RSI crosses above or below its selected smoothing moving average.

• Reversal Deviation +1 / +2 Cross

Triggers when RSI crosses the projected reversal deviation levels.

• Divergence Deviation +1 / +2 Cross

Triggers when RSI crosses the projected divergence deviation levels.


IMPORTANT NOTES

Pivot Confirmation

Divergence patterns and swing pivots require completed right-side confirmation bars. As a result, divergence signals and labels are confirmed only after the required lookback bars have closed.

Real-Time Bar Dynamics

Unclosed real-time candles can change as new price data arrives. For more reliable signal evaluation, wait for candle-close confirmation.

Multi-Timeframe Sampling

The dashboard uses closed historical data while continuously updating developing higher-timeframe values in real time.

Strong Trending Markets

During strong and persistent trends, RSI can remain in overbought or oversold territory for extended periods.

Counter-trend divergence signals should therefore not be used in isolation. Always consider the broader price structure and market conditions.


DISCLAIMER

This indicator is published strictly for analytical, research, and educational purposes. It does not constitute financial, investment, or trading advice.

Past technical behavior, signals, and pattern recognition do not guarantee future market outcomes.

Financial trading involves significant risk of capital loss. Users are solely responsible for their own trading decisions, position sizing, and risk-management parameters.

## Source Code

````pine
//@version=6
indicator("Adaptive RSI Momentum Engine [AlgoChief]", shorttitle="Adaptive RSI [AlgoChief]", overlay=false, precision=2, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. INPUT SETTINGS & CONFIGURATION
// ==========================================

// RSI Configuration
rsiSrc        = input.source(close, "Price Source", group="RSI Configuration")
rsiLen        = input.int(14, "RSI Period", minval=1, group="RSI Configuration")

// Overbought & Oversold Horizons
obLevel       = input.float(65.0, "Overbought Horizon", minval=50.0, maxval=100.0, group="Exhaustion Horizons")
osLevel       = input.float(35.0, "Oversold Horizon", minval=0.0, maxval=50.0, group="Exhaustion Horizons")

// Dynamic RSI Channels
channelType   = input.string("Bollinger Bands", "Channel Model", options=["None", "Bollinger Bands", "Keltner Channel", "Donchian Channel"], group="Dynamic Volatility Channels")
channelLen    = input.int(10, "Channel Period", minval=2, group="Dynamic Volatility Channels")
channelMult   = input.float(2.0, "Band Multiplier", minval=0.1, step=0.1, group="Dynamic Volatility Channels")
colorChanUp   = input.color(color.new(#7e57c2, 40), "Upper Band Color", group="Dynamic Volatility Channels")
colorChanMid  = input.color(color.new(#ffb74d, 60), "Middle Band Color", group="Dynamic Volatility Channels")
colorChanLow  = input.color(color.new(#7e57c2, 40), "Lower Band Color", group="Dynamic Volatility Channels")

// RSI Smoothing Moving Average
smoothType    = input.string("SMA", "Smoothing Type", options=["None", "SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="RSI Smoothing")
smoothLen     = input.int(14, "Smoothing Period", minval=1, group="RSI Smoothing")
colorSmooth   = input.color(color.new(#ffeb3b, 10), "Smoothing Line Color", group="RSI Smoothing")

// Momentum Reversal Signals
showReversals = input.bool(true, "Show Momentum Reversal Triggers", group="Momentum Reversals")
showRevDev    = input.bool(true, "Plot Reversal Deviation Levels (+1/+2)", group="Momentum Reversals")
revDevMult    = input.float(1.0, "Reversal Deviation Multiplier", minval=0.1, step=0.1, group="Momentum Reversals")
colorBullRev  = input.color(color.new(#00e676, 0), "Bullish Signal Color", group="Momentum Reversals")
colorBearRev  = input.color(color.new(#ff1744, 0), "Bearish Signal Color", group="Momentum Reversals")

// Divergence Engine
showDiv       = input.bool(true, "Enable Divergence Detection", group="Divergence Engine")
pivotLookback = input.int(5, "Pivot Lookback", minval=2, maxval=20, group="Divergence Engine")
showHiddenDiv = input.bool(true, "Detect Hidden Continuation Divergence", group="Divergence Engine")
showDivDev    = input.bool(true, "Plot Divergence Deviation Levels (+1/+2)", group="Divergence Engine")
divDevMult    = input.float(3.0, "Divergence Deviation Multiplier", minval=0.5, step=0.5, group="Divergence Engine")
colorBullDiv  = input.color(color.new(#00e676, 0), "Bullish Divergence Color", group="Divergence Engine")
colorBearDiv  = input.color(color.new(#ff1744, 0), "Bearish Divergence Color", group="Divergence Engine")

// Multi-Timeframe Dashboard
showTable     = input.bool(true, "Show Multi-Timeframe Dashboard", group="Multi-Timeframe Dashboard")
tablePosInput = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group="Multi-Timeframe Dashboard")
tableSzInput  = input.string("Small", "Dashboard Size", options=["Tiny", "Small", "Normal", "Large"], group="Multi-Timeframe Dashboard")

// Dashboard Timeframe Selectors
tf1_enable    = input.bool(true, "Slot 1", inline="tf1", group="Dashboard Timeframes")
tf1           = input.timeframe("5", "", inline="tf1", group="Dashboard Timeframes")
tf2_enable    = input.bool(true, "Slot 2", inline="tf2", group="Dashboard Timeframes")
tf2           = input.timeframe("15", "", inline="tf2", group="Dashboard Timeframes")
tf3_enable    = input.bool(true, "Slot 3", inline="tf3", group="Dashboard Timeframes")
tf3           = input.timeframe("60", "", inline="tf3", group="Dashboard Timeframes")
tf4_enable    = input.bool(true, "Slot 4", inline="tf4", group="Dashboard Timeframes")
tf4           = input.timeframe("120", "", inline="tf4", group="Dashboard Timeframes")
tf5_enable    = input.bool(true, "Slot 5", inline="tf5", group="Dashboard Timeframes")
tf5           = input.timeframe("240", "", inline="tf5", group="Dashboard Timeframes")
tf6_enable    = input.bool(true, "Slot 6", inline="tf6", group="Dashboard Timeframes")
tf6           = input.timeframe("720", "", inline="tf6", group="Dashboard Timeframes")
tf7_enable    = input.bool(true, "Slot 7", inline="tf7", group="Dashboard Timeframes")
tf7           = input.timeframe("1D", "", inline="tf7", group="Dashboard Timeframes")
tf8_enable    = input.bool(true, "Slot 8", inline="tf8", group="Dashboard Timeframes")
tf8           = input.timeframe("1W", "", inline="tf8", group="Dashboard Timeframes")

// ==========================================
// 2. CORE CALCULATIONS
// ==========================================

// RSI Value
rsiVal = ta.rsi(rsiSrc, rsiLen)

// Pre-calculated Moving Averages for Smoothing
ma_sma  = ta.sma(rsiVal, smoothLen)
ma_ema  = ta.ema(rsiVal, smoothLen)
ma_rma  = ta.rma(rsiVal, smoothLen)
ma_wma  = ta.wma(rsiVal, smoothLen)
ma_vwma = volume > 0 ? ta.vwma(rsiVal, smoothLen) : ma_sma

smoothVal = smoothType == "SMA" ? ma_sma : smoothType == "EMA" ? ma_ema : smoothType == "SMMA (RMA)" ? ma_rma : smoothType == "WMA" ? ma_wma : smoothType == "VWMA" ? ma_vwma : na

// Dynamic Volatility Channels on RSI
bbBasis = ta.sma(rsiVal, channelLen)
bbDev   = channelMult * ta.stdev(rsiVal, channelLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

kcBasis = ta.ema(rsiVal, channelLen)
kcRng   = ta.ema(math.abs(rsiVal - rsiVal[1]), channelLen)
kcUpper = kcBasis + channelMult * kcRng
kcLower = kcBasis - channelMult * kcRng

dcUpper = ta.highest(rsiVal, channelLen)
dcLower = ta.lowest(rsiVal, channelLen)
dcMid   = (dcUpper + dcLower) / 2.0
dcUpperAdj = dcMid + channelMult * (dcUpper - dcMid)
dcLowerAdj = dcMid - channelMult * (dcMid - dcLower)

chanUpper = channelType == "Bollinger Bands" ? bbUpper : channelType == "Keltner Channel" ? kcUpper : channelType == "Donchian Channel" ? dcUpperAdj : na
chanMid   = channelType == "Bollinger Bands" ? bbBasis : channelType == "Keltner Channel" ? kcBasis : channelType == "Donchian Channel" ? dcMid : na
chanLower = channelType == "Bollinger Bands" ? bbLower : channelType == "Keltner Channel" ? kcLower : channelType == "Donchian Channel" ? dcLowerAdj : na

// Channel Breakouts
chanBreakUp = not na(chanUpper) and ta.crossover(rsiVal, chanUpper)
chanBreakDn = not na(chanLower) and ta.crossunder(rsiVal, chanLower)

// Smoothing Crossovers (Yellow Circle Signals)
rsiCrossUp = not na(smoothVal) and ta.crossover(rsiVal, smoothVal)
rsiCrossDn = not na(smoothVal) and ta.crossunder(rsiVal, smoothVal)
rsiCross   = rsiCrossUp or rsiCrossDn

// Momentum Reversal Triggers
bullRev = rsiVal[1] < rsiVal[2] and rsiVal > rsiVal[1] and (rsiVal[1] <= osLevel or (not na(chanLower) and rsiVal[1] <= chanLower[1]))
bearRev = rsiVal[1] > rsiVal[2] and rsiVal < rsiVal[1] and (rsiVal[1] >= obLevel or (not na(chanUpper) and rsiVal[1] >= chanUpper[1]))

// Standard Deviation on RSI for Deviation Projection
rsiStdev = ta.stdev(rsiVal, 20)

// ==========================================
// 3. DIVERGENCE ENGINE
// ==========================================

pl = ta.pivotlow(rsiVal, pivotLookback, pivotLookback)
ph = ta.pivothigh(rsiVal, pivotLookback, pivotLookback)

var float prevLowRsi   = na
var float prevLowPrice = na
var int   prevLowBar   = na

var float prevHighRsi   = na
var float prevHighPrice = na
var int   prevHighBar   = na

bool regBullDiv = false
bool regBearDiv = false
bool hidBullDiv = false
bool hidBearDiv = false

if not na(pl) and showDiv
    currentRsi   = rsiVal[pivotLookback]
    currentPrice = low[pivotLookback]
    currentBar   = bar_index - pivotLookback
    
    if not na(prevLowRsi) and not na(prevLowBar)
        // Regular Bullish: Lower Price Low, Higher RSI Low
        if currentPrice < prevLowPrice and currentRsi > prevLowRsi
            regBullDiv := true
            line.new(prevLowBar, prevLowRsi, currentBar, currentRsi, color=colorBullDiv, width=2)
            label.new(currentBar, currentRsi, "Bull", color=color.new(color.black, 100), textcolor=colorBullDiv, style=label.style_label_up, size=size.tiny)
        // Hidden Bullish: Higher Price Low, Lower RSI Low
        else if showHiddenDiv and currentPrice > prevLowPrice and currentRsi < prevLowRsi
            hidBullDiv := true
            line.new(prevLowBar, prevLowRsi, currentBar, currentRsi, color=colorBullDiv, width=1, style=line.style_dashed)
            label.new(currentBar, currentRsi, "H-Bull", color=color.new(color.black, 100), textcolor=colorBullDiv, style=label.style_label_up, size=size.tiny)
            
    prevLowRsi   := currentRsi
    prevLowPrice := currentPrice
    prevLowBar   := currentBar

if not na(ph) and showDiv
    currentRsi   = rsiVal[pivotLookback]
    currentPrice = high[pivotLookback]
    currentBar   = bar_index - pivotLookback
    
    if not na(prevHighRsi) and not na(prevHighBar)
        // Regular Bearish: Higher Price High, Lower RSI High
        if currentPrice > prevHighPrice and currentRsi < prevHighRsi
            regBearDiv := true
            line.new(prevHighBar, prevHighRsi, currentBar, currentRsi, color=colorBearDiv, width=2)
            label.new(currentBar, currentRsi, "Bear", color=color.new(color.black, 100), textcolor=colorBearDiv, style=label.style_label_down, size=size.tiny)
        // Hidden Bearish: Lower Price High, Higher RSI High
        else if showHiddenDiv and currentPrice < prevHighPrice and currentRsi > prevHighRsi
            hidBearDiv := true
            line.new(prevHighBar, prevHighRsi, currentBar, currentRsi, color=colorBearDiv, width=1, style=line.style_dashed)
            label.new(currentBar, currentRsi, "H-Bear", color=color.new(color.black, 100), textcolor=colorBearDiv, style=label.style_label_down, size=size.tiny)
            
    prevHighRsi   := currentRsi
    prevHighPrice := currentPrice
    prevHighBar   := currentBar

// ==========================================
// 4. DEVIATION PROJECTIONS (+1 / +2)
// ==========================================

var line revDevLine1 = na
var line revDevLine2 = na
var float revDev1Val = na
var float revDev2Val = na
var int   revDevDir  = 0

if showReversals and showRevDev
    if bullRev
        line.delete(revDevLine1)
        line.delete(revDevLine2)
        revDev1Val := math.min(100.0, rsiVal + 1.0 * revDevMult * rsiStdev)
        revDev2Val := math.min(100.0, rsiVal + 2.0 * revDevMult * rsiStdev)
        revDevDir  := 1
        revDevLine1 := line.new(bar_index, revDev1Val, bar_index + 15, revDev1Val, color=color.new(colorBullRev, 40), style=line.style_dashed, width=1)
        revDevLine2 := line.new(bar_index, revDev2Val, bar_index + 15, revDev2Val, color=color.new(colorBullRev, 60), style=line.style_dotted, width=1)
    else if bearRev
        line.delete(revDevLine1)
        line.delete(revDevLine2)
        revDev1Val := math.max(0.0, rsiVal - 1.0 * revDevMult * rsiStdev)
        revDev2Val := math.max(0.0, rsiVal - 2.0 * revDevMult * rsiStdev)
        revDevDir  := -1
        revDevLine1 := line.new(bar_index, revDev1Val, bar_index + 15, revDev1Val, color=color.new(colorBearRev, 40), style=line.style_dashed, width=1)
        revDevLine2 := line.new(bar_index, revDev2Val, bar_index + 15, revDev2Val, color=color.new(colorBearRev, 60), style=line.style_dotted, width=1)

var line divDevLine1 = na
var line divDevLine2 = na
var float divDev1Val = na
var float divDev2Val = na
var int   divDevDir  = 0

if showDiv and showDivDev
    if regBullDiv or hidBullDiv
        line.delete(divDevLine1)
        line.delete(divDevLine2)
        divDev1Val := math.min(100.0, rsiVal + 1.0 * divDevMult * rsiStdev)
        divDev2Val := math.min(100.0, rsiVal + 2.0 * divDevMult * rsiStdev)
        divDevDir  := 1
        divDevLine1 := line.new(bar_index, divDev1Val, bar_index + 20, divDev1Val, color=color.new(colorBullDiv, 30), style=line.style_dashed, width=1)
        divDevLine2 := line.new(bar_index, divDev2Val, bar_index + 20, divDev2Val, color=color.new(colorBullDiv, 50), style=line.style_dotted, width=1)
    else if regBearDiv or hidBearDiv
        line.delete(divDevLine1)
        line.delete(divDevLine2)
        divDev1Val := math.max(0.0, rsiVal - 1.0 * divDevMult * rsiStdev)
        divDev2Val := math.max(0.0, rsiVal - 2.0 * divDevMult * rsiStdev)
        divDevDir  := -1
        divDevLine1 := line.new(bar_index, divDev1Val, bar_index + 20, divDev1Val, color=color.new(colorBearDiv, 30), style=line.style_dashed, width=1)
        divDevLine2 := line.new(bar_index, divDev2Val, bar_index + 20, divDev2Val, color=color.new(colorBearDiv, 50), style=line.style_dotted, width=1)

// Deviation Crossings (Unconditionally Evaluated)
crossUpRev1  = ta.crossover(rsiVal, revDev1Val)
crossDnRev1  = ta.crossunder(rsiVal, revDev1Val)
revDev1Cross = not na(revDev1Val) and (revDevDir == 1 ? crossUpRev1 : crossDnRev1)

crossUpRev2  = ta.crossover(rsiVal, revDev2Val)
crossDnRev2  = ta.crossunder(rsiVal, revDev2Val)
revDev2Cross = not na(revDev2Val) and (revDevDir == 1 ? crossUpRev2 : crossDnRev2)

crossUpDiv1  = ta.crossover(rsiVal, divDev1Val)
crossDnDiv1  = ta.crossunder(rsiVal, divDev1Val)
divDev1Cross = not na(divDev1Val) and (divDevDir == 1 ? crossUpDiv1 : crossDnDiv1)

crossUpDiv2  = ta.crossover(rsiVal, divDev2Val)
crossDnDiv2  = ta.crossunder(rsiVal, divDev2Val)
divDev2Cross = not na(divDev2Val) and (divDevDir == 1 ? crossUpDiv2 : crossDnDiv2)

// ==========================================
// 5. PLOTTING & VISUALIZATION
// ==========================================

// Horizons & Background Fills
p_top = plot(100.0, "Ceiling", display=display.none)
p_ob  = plot(obLevel, "Overbought Horizon", color=color.new(#ef5350, 40), linewidth=1, display=display.pane)
p_mid = plot(50.0, "Midline 50", color=color.new(color.gray, 60), linewidth=1, display=display.pane)
p_os  = plot(osLevel, "Oversold Horizon", color=color.new(#26a69a, 40), linewidth=1, display=display.pane)
p_bot = plot(0.0, "Floor", display=display.none)

fill(p_top, p_ob, color=color.new(#ef5350, 85), title="Overbought Gradient")
fill(p_os, p_bot, color=color.new(#26a69a, 85), title="Oversold Gradient")

// Dynamic Channel Bands
p_chanUp  = plot(chanUpper, "Channel Upper", color=colorChanUp, linewidth=1, display=display.pane)
p_chanMid = plot(chanMid, "Channel Middle", color=colorChanMid, linewidth=1, display=display.pane)
p_chanLow = plot(chanLower, "Channel Lower", color=colorChanLow, linewidth=1, display=display.pane)
fill(p_chanUp, p_chanLow, color=color.new(#7e57c2, 92), title="Channel Band Fill")

// Smoothing MA Line
plot(smoothVal, "RSI Smoothing MA", color=colorSmooth, linewidth=1, display=display.pane)

// Primary RSI Plot
rsiColor = rsiVal >= obLevel ? #ef5350 : rsiVal <= osLevel ? #26a69a : #ffd54f
plot(rsiVal, "Adaptive RSI", color=rsiColor, linewidth=2, display=display.all)

// Yellow Circle Crossover Markers
plotshape(rsiCross ? rsiVal : na, "RSI Smoothing Cross", shape.circle, location.absolute, color.new(#ffd600, 0), size=size.tiny, display=display.pane)

// Channel Breakout Markers
plotshape(chanBreakUp, "Channel Breakout Up", shape.circle, location.top, color.new(#00e676, 0), size=size.tiny, display=display.pane)
plotshape(chanBreakDn, "Channel Breakout Down", shape.circle, location.bottom, color.new(#ff1744, 0), size=size.tiny, display=display.pane)

// Momentum Reversal Signals
plotshape(showReversals and bullRev ? math.max(0.0, rsiVal - 6.0) : na, "Bullish Reversal", shape.triangleup, location.absolute, colorBullRev, size=size.small, display=display.pane)
plotshape(showReversals and bearRev ? math.min(100.0, rsiVal + 6.0) : na, "Bearish Reversal", shape.triangledown, location.absolute, colorBearRev, size=size.small, display=display.pane)

// ==========================================
// 6. MULTI-TIMEFRAME DASHBOARD CALCULATION
// ==========================================

f_mtf_core(simple int r_len, simple int s_len, simple string s_type, simple int c_len, simple float c_mult, simple string c_type, simple float ob, simple float os) =>
    r = ta.rsi(close, r_len)
    
    // Smoothing MA
    m_sma  = ta.sma(r, s_len)
    m_ema  = ta.ema(r, s_len)
    m_rma  = ta.rma(r, s_len)
    m_wma  = ta.wma(r, s_len)
    m_vwma = volume > 0 ? ta.vwma(r, s_len) : m_sma
    s = s_type == "SMA" ? m_sma : s_type == "EMA" ? m_ema : s_type == "SMMA (RMA)" ? m_rma : s_type == "WMA" ? m_wma : s_type == "VWMA" ? m_vwma : na
    
    // Channels
    b_mid = ta.sma(r, c_len)
    b_dev = c_mult * ta.stdev(r, c_len)
    k_mid = ta.ema(r, c_len)
    k_rng = ta.ema(math.abs(r - r[1]), c_len)
    d_hi  = ta.highest(r, c_len)
    d_lo  = ta.lowest(r, c_len)
    d_mid = (d_hi + d_lo) / 2.0
    
    u_c = c_type == "Bollinger Bands" ? b_mid + b_dev : c_type == "Keltner Channel" ? k_mid + c_mult * k_rng : c_type == "Donchian Channel" ? d_mid + c_mult * (d_hi - d_mid) : na
    l_c = c_type == "Bollinger Bands" ? b_mid - b_dev : c_type == "Keltner Channel" ? k_mid - c_mult * k_rng : c_type == "Donchian Channel" ? d_mid - c_mult * (d_mid - d_lo) : na
    
    // 1. OB/OS State
    obos_st = r >= ob ? 1 : r <= os ? -1 : 0
    
    // 2. Cross State
    cross_st = not na(s) ? (r > s ? 1 : -1) : 0
    
    // 3. Channel Breaks
    brk_u = not na(u_c) and ta.crossover(r, u_c)
    brk_d = not na(l_c) and ta.crossunder(r, l_c)
    bars_brk_u = ta.barssince(brk_u)
    bars_brk_d = ta.barssince(brk_d)
    
    // 4. Momentum Reversals
    bull_r = r[1] < r[2] and r > r[1] and (r[1] <= os or (not na(l_c) and r[1] <= l_c[1]))
    bear_r = r[1] > r[2] and r < r[1] and (r[1] >= ob or (not na(u_c) and r[1] >= u_c[1]))
    bars_bull_r = ta.barssince(bull_r)
    bars_bear_r = ta.barssince(bear_r)
    
    // 5. Divergence (Fixed lookback of 5 for HTF calculation)
    p_lo = ta.pivotlow(r, 5, 5)
    p_hi = ta.pivothigh(r, 5, 5)
    b_div = not na(p_lo) and low[5] < ta.valuewhen(not na(p_lo), low[5], 1) and r[5] > ta.valuewhen(not na(p_lo), r[5], 1)
    s_div = not na(p_hi) and high[5] > ta.valuewhen(not na(p_hi), high[5], 1) and r[5] < ta.valuewhen(not na(p_hi), r[5], 1)
    bars_b_div = ta.barssince(b_div)
    bars_s_div = ta.barssince(s_div)
    
    [obos_st, cross_st, bars_brk_u, bars_brk_d, bars_bull_r, bars_bear_r, bars_b_div, bars_s_div]

// HTF Security Requests
[o1, c1, bup1, bdn1, brev1, srev1, bdiv1, sdiv1] = request.security(syminfo.tickerid, tf1, f_mtf_core(rsiLen, smoothLen, smoothType, channelLen, channelMult, channelType, obLevel, osLevel), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[o2, c2, bup2, bdn2, brev2, srev2, bdiv2, sdiv2] = request.security(syminfo.tickerid, tf2, f_mtf_core(rsiLen, smoothLen, smoothType, channelLen, channelMult, channelType, obLevel, osLevel), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[o3, c3, bup3, bdn3, brev3, srev3, bdiv3, sdiv3] = request.security(syminfo.tickerid, tf3, f_mtf_core(rsiLen, smoothLen, smoothType, channelLen, channelMult, channelType, obLevel, osLevel), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[o4, c4, bup4, bdn4, brev4, srev4, bdiv4, sdiv4] = request.security(syminfo.tickerid, tf4, f_mtf_core(rsiLen, smoothLen, smoothType, channelLen, channelMult, channelType, obLevel, osLevel), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[o5, c5, bup5, bdn5, brev5, srev5, bdiv5, sdiv5] = request.security(syminfo.tickerid, tf5, f_mtf_core(rsiLen, smoothLen, smoothType, channelLen, channelMult, channelType, obLevel, osLevel), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[o6, c6, bup6, bdn6, brev6, srev6, bdiv6, sdiv6] = request.security(syminfo.tickerid, tf6, f_mtf_core(rsiLen, smoothLen, smoothType, channelLen, channelMult, channelType, obLevel, osLevel), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[o7, c7, bup7, bdn7, brev7, srev7, bdiv7, sdiv7] = request.security(syminfo.tickerid, tf7, f_mtf_core(rsiLen, smoothLen, smoothType, channelLen, channelMult, channelType, obLevel, osLevel), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[o8, c8, bup8, bdn8, brev8, srev8, bdiv8, sdiv8] = request.security(syminfo.tickerid, tf8, f_mtf_core(rsiLen, smoothLen, smoothType, channelLen, channelMult, channelType, obLevel, osLevel), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Table Declaration (Constant Position Anchor)
var table mtfTable = table.new(position.bottom_right, 9, 6, bgcolor = color.new(#131722, 15), border_color = color.new(#363c4e, 30), border_width = 1, frame_color = color.new(#363c4e, 20), frame_width = 1)

tableSize = tableSzInput == "Tiny" ? size.tiny : tableSzInput == "Normal" ? size.normal : tableSzInput == "Large" ? size.large : size.small

f_render_col(col, tfTitle, obos, cross, bup, bdn, brev, srev, bdiv, sdiv) =>
    // Header
    table.cell(mtfTable, col, 0, tfTitle, text_color = color.white, text_size = tableSize, bgcolor = color.new(#2a2e39, 20))
    
    // Divergence Row
    divText  = "-"
    divColor = color.new(#787b86, 70)
    divTip   = "No active divergence"
    if not na(bdiv) and bdiv <= 50 and (na(sdiv) or bdiv <= sdiv)
        divText  := "Bull"
        divColor := color.new(#00e676, 30)
        divTip   := "Bullish divergence (" + str.tostring(bdiv) + " bars ago)"
    else if not na(sdiv) and sdiv <= 50 and (na(bdiv) or sdiv <= bdiv)
        divText  := "Bear"
        divColor := color.new(#ff1744, 30)
        divTip   := "Bearish divergence (" + str.tostring(sdiv) + " bars ago)"
    table.cell(mtfTable, col, 1, divText, text_color = color.white, text_size = tableSize, bgcolor = divColor, tooltip = divTip)
    
    // OB / OS Row
    obosText  = "-"
    obosColor = color.new(#787b86, 70)
    if obos == 1
        obosText  := "OB"
        obosColor := color.new(#ff1744, 30)
    else if obos == -1
        obosText  := "OS"
        obosColor := color.new(#00e676, 30)
    table.cell(mtfTable, col, 2, obosText, text_color = color.white, text_size = tableSize, bgcolor = obosColor)
    
    // Signals Row
    sigText  = "-"
    sigColor = color.new(#787b86, 70)
    sigTip   = "No recent reversal"
    if not na(brev) and brev <= 50 and (na(srev) or brev <= srev)
        sigText  := "▲"
        sigColor := color.new(#00e676, 30)
        sigTip   := "Bullish reversal (" + str.tostring(brev) + " bars ago)"
    else if not na(srev) and srev <= 50 and (na(brev) or srev <= brev)
        sigText  := "▼"
        sigColor := color.new(#ff1744, 30)
        sigTip   := "Bearish reversal (" + str.tostring(srev) + " bars ago)"
    table.cell(mtfTable, col, 3, sigText, text_color = color.white, text_size = tableSize, bgcolor = sigColor, tooltip = sigTip)
    
    // Channel Breaks Row
    cbText  = "-"
    cbColor = color.new(#787b86, 70)
    cbTip   = "No recent channel break"
    if not na(bup) and bup <= 50 and (na(bdn) or bup <= bdn)
        cbText  := "▲"
        cbColor := color.new(#00e676, 30)
        cbTip   := "Channel break up (" + str.tostring(bup) + " bars ago)"
    else if not na(bdn) and bdn <= 50 and (na(bup) or bdn <= bup)
        cbText  := "▼"
        cbColor := color.new(#ff1744, 30)
        cbTip   := "Channel break down (" + str.tostring(bdn) + " bars ago)"
    table.cell(mtfTable, col, 4, cbText, text_color = color.white, text_size = tableSize, bgcolor = cbColor, tooltip = cbTip)
    
    // RSI Cross Row
    crText  = "-"
    crColor = color.new(#787b86, 70)
    if cross == 1
        crText  := "Bull"
        crColor := color.new(#00e676, 30)
    else if cross == -1
        crText  := "Bear"
        crColor := color.new(#ff1744, 30)
    table.cell(mtfTable, col, 5, crText, text_color = color.white, text_size = tableSize, bgcolor = crColor)

if barstate.islast and showTable
    // Position Update
    if tablePosInput == "Top Right"
        table.set_position(mtfTable, position.top_right)
    else if tablePosInput == "Top Left"
        table.set_position(mtfTable, position.top_left)
    else if tablePosInput == "Bottom Left"
        table.set_position(mtfTable, position.bottom_left)
    else
        table.set_position(mtfTable, position.bottom_right)
        
    // Metric Labels
    table.cell(mtfTable, 0, 0, "Timeframe", text_color = color.white, text_size = tableSize, bgcolor = color.new(#1e222d, 10))
    table.cell(mtfTable, 0, 1, "Divergence", text_color = color.white, text_size = tableSize, bgcolor = color.new(#1e222d, 10))
    table.cell(mtfTable, 0, 2, "OB / OS", text_color = color.white, text_size = tableSize, bgcolor = color.new(#1e222d, 10))
    table.cell(mtfTable, 0, 3, "Signals", text_color = color.white, text_size = tableSize, bgcolor = color.new(#1e222d, 10))
    table.cell(mtfTable, 0, 4, "Channel Breaks", text_color = color.white, text_size = tableSize, bgcolor = color.new(#1e222d, 10))
    table.cell(mtfTable, 0, 5, "RSI Cross", text_color = color.white, text_size = tableSize, bgcolor = color.new(#1e222d, 10))
    
    // Contiguous Column Population
    var int colIdx = 1
    colIdx := 1
    
    if tf1_enable
        f_render_col(colIdx, tf1, o1, c1, bup1, bdn1, brev1, srev1, bdiv1, sdiv1)
        colIdx := colIdx + 1
    if tf2_enable
        f_render_col(colIdx, tf2, o2, c2, bup2, bdn2, brev2, srev2, bdiv2, sdiv2)
        colIdx := colIdx + 1
    if tf3_enable
        f_render_col(colIdx, tf3, o3, c3, bup3, bdn3, brev3, srev3, bdiv3, sdiv3)
        colIdx := colIdx + 1
    if tf4_enable
        f_render_col(colIdx, tf4, o4, c4, bup4, bdn4, brev4, srev4, bdiv4, sdiv4)
        colIdx := colIdx + 1
    if tf5_enable
        f_render_col(colIdx, tf5, o5, c5, bup5, bdn5, brev5, srev5, bdiv5, sdiv5)
        colIdx := colIdx + 1
    if tf6_enable
        f_render_col(colIdx, tf6, o6, c6, bup6, bdn6, brev6, srev6, bdiv6, sdiv6)
        colIdx := colIdx + 1
    if tf7_enable
        f_render_col(colIdx, tf7, o7, c7, bup7, bdn7, brev7, srev7, bdiv7, sdiv7)
        colIdx := colIdx + 1
    if tf8_enable
        f_render_col(colIdx, tf8, o8, c8, bup8, bdn8, brev8, srev8, bdiv8, sdiv8)
        colIdx := colIdx + 1

// ==========================================
// 7. ALERT CONDITIONS
// ==========================================

alertcondition(regBullDiv, title="Bullish Divergence", message="Bullish Divergence detected on {{ticker}} at {{time}}")
alertcondition(regBearDiv, title="Bearish Divergence", message="Bearish Divergence detected on {{ticker}} at {{time}}")
alertcondition(hidBullDiv, title="Hidden Bullish Divergence", message="Hidden Bullish Divergence detected on {{ticker}} at {{time}}")
alertcondition(hidBearDiv, title="Hidden Bearish Divergence", message="Hidden Bearish Divergence detected on {{ticker}} at {{time}}")
alertcondition(bullRev, title="Bullish Reversal", message="Bullish RSI Reversal signal detected on {{ticker}} at {{time}}")
alertcondition(bearRev, title="Bearish Reversal", message="Bearish RSI Reversal signal detected on {{ticker}} at {{time}}")
alertcondition(chanBreakUp, title="Channel Break Up", message="RSI Channel Breakout Up detected on {{ticker}} at {{time}}")
alertcondition(chanBreakDn, title="Channel Break Down", message="RSI Channel Breakout Down detected on {{ticker}} at {{time}}")
alertcondition(rsiCrossUp, title="RSI Smoothing Bullish Cross", message="RSI crossed above Smoothing MA on {{ticker}} at {{time}}")
alertcondition(rsiCrossDn, title="RSI Smoothing Bearish Cross", message="RSI crossed below Smoothing MA on {{ticker}} at {{time}}")
alertcondition(revDev1Cross, title="Reversal Deviation +1 Cross", message="RSI crossed Reversal Deviation +1 level on {{ticker}} at {{time}}")
alertcondition(revDev2Cross, title="Reversal Deviation +2 Cross", message="RSI crossed Reversal Deviation +2 level on {{ticker}} at {{time}}")
alertcondition(divDev1Cross, title="Divergence Deviation +1 Cross", message="RSI crossed Divergence Deviation +1 level on {{ticker}} at {{time}}")
alertcondition(divDev2Cross, title="Divergence Deviation +2 Cross", message="RSI crossed Divergence Deviation +2 level on {{ticker}} at {{time}}")
````
