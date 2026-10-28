# Momentum Engine - [DecodingFlowLab]

- url: https://www.tradingview.com/script/Vh05Alkv-Momentum-Engine-DecodingFlowLab/
- type: indicator
- pine_id: PUB;f04a75e1fe3f49438e320d803fc55596
- version: 1.0

## Description

Decoding Lab – Momentum Engine is a quantitative momentum analysis indicator designed to detect real market expansion and institutional-grade directional pressure.

Unlike traditional momentum indicators that rely on a single source such as RSI or MACD, Momentum Engine combines multiple market dynamics into one unified scoring model, including:

• Volatility Expansion (ATR Expansion)
• Candle Body Strength
• Relative Volume Activity
• Breakout Velocity
• Pullback Efficiency

The indicator calculates a dynamic Momentum Score ranging from 0 to 100, helping traders identify whether the current move is supported by genuine market participation or simply random price fluctuation.

━━━━━━━━━━━━━━━━━━
How It Works
━━━━━━━━━━━━━━━━━━

Momentum Engine analyzes five core components of market behavior:

• ATR Expansion
Measures whether volatility is expanding relative to normal market conditions.

• Candle Body Strength
Evaluates the dominance of buyers or sellers through candle body size relative to total range.

• Volume Expansion
Detects abnormal trading activity compared to average market participation.

• Breakout Speed
Measures how aggressively price moves after breaking key highs or lows.

• Pullback Efficiency
Analyzes whether retracements remain shallow or become excessively deep.

All factors are normalized and combined into a weighted Momentum Score to classify market conditions as:

• Bullish Momentum
• Bearish Momentum
• Weak / No Momentum

The indicator also prints “M” labels when strong momentum first appears.

━━━━━━━━━━━━━━━━━━
How Traders Use It
━━━━━━━━━━━━━━━━━━

Traders use Momentum Engine to:

• Detect strong breakout conditions
• Confirm trend continuation strength
• Filter weak or low-quality market moves
• Identify institutional momentum expansion
• Avoid trading during weak or ranging conditions
• Improve timing for entries during impulsive moves

Common use cases include:

• Breakout Trading
• Momentum Trading
• Smart Money Concepts (SMC)
• Scalping & Intraday Trading
• Trend Continuation Strategies

The indicator is especially powerful when combined with:
• Market Structure
• BOS / CHOCH
• Liquidity Sweeps
• Higher Timeframe Bias
• Volume Analysis

━━━━━━━━━━━━━━━━━━
Main Features
━━━━━━━━━━━━━━━━━━

• Detects strong bullish and bearish momentum
• Identifies explosive breakout conditions
• Measures trend continuation quality
• Detects early momentum ignition using M labels
• Includes real-time quantitative momentum dashboard
• Combines Price Action + Volume + Volatility in one engine

Momentum Engine is built for traders who want to move beyond traditional oscillators and analyze the true strength behind market movements.


Disclaimer:

This indicator is provided for educational and informational purposes only and should not be considered financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

The indicator does not provide guaranteed entry or exit signals for trading positions. Financial markets involve significant risk, and past performance does not guarantee future results.

Users are solely responsible for their own trading decisions, risk management, and use of this indicator in any market or trading environment.

The publisher, developer, and distributor of this indicator assume no responsibility or liability for any financial losses, damages, or outcomes resulting from the use or misuse of this indicator.

## Source Code

````pine
//@version=6
indicator(title = "Decoding Lab- Momentum Engine", shorttitle = "[DF_Lab] - MomentumEngine", overlay=true, max_labels_count=500)

//======================
// Inputs
//======================
atrFastLen       = input.int(5,  "ATR Fast Length")
atrSlowLen       = input.int(20, "ATR Slow Length")
volEmaLen        = input.int(20, "Volume EMA Length")
breakoutLookback = input.int(20, "Breakout Lookback")
pullbackLen      = input.int(20, "Pullback Swing Lookback")

strongLevel      = input.float(70.0, "Strong Momentum Level")
weakLevel        = input.float(40.0, "Weak Momentum Level")

showTable        = input.bool(true, "Show Table")
showScorePlot    = input.bool(false, "Show Momentum Plot")

showMLabels      = input.bool(true, "Show Momentum M Labels")
labelText        = input.string("M", "Momentum Label Text")
labelLocationInp = input.string("Auto", "M Label Location", options=["Auto", "Above Bar", "Below Bar"])
labelTextSizeInp = input.string("Small", "M Label Text Size", options=["Tiny", "Small", "Normal"])

tablePos         = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
tableTextSizeInp = input.string("Tiny", "Table Text Size", options=["Tiny", "Small", "Normal"])

//======================
// Colors
//======================
headerBg = color.rgb(55, 60, 72)
titleBg  = color.rgb(47, 52, 63)
cellBg   = color.rgb(35, 38, 45)
bullBg   = color.rgb(42, 92, 54)
bearBg   = color.rgb(120, 45, 52)
weakBg   = color.rgb(95, 95, 95)
txt      = color.white

//======================
// Helpers
//======================
normalize(value, minVal, maxVal) =>
    v = math.max(minVal, math.min(value, maxVal))
    100.0 * (v - minVal) / (maxVal - minVal)

pos =
     tablePos == "Top Right"    ? position.top_right :
     tablePos == "Top Left"     ? position.top_left :
     tablePos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

txtSize =
     tableTextSizeInp == "Tiny"   ? size.tiny :
     tableTextSizeInp == "Small"  ? size.small :
     size.normal

labelTxtSize =
     labelTextSizeInp == "Tiny"   ? size.tiny :
     labelTextSizeInp == "Small"  ? size.small :
     size.normal

//======================
// 1. ATR Expansion
//======================
atrFast  = ta.atr(atrFastLen)
atrSlow  = ta.atr(atrSlowLen)
atrRatio = atrSlow != 0 ? atrFast / atrSlow : 0.0
atrScore = normalize(atrRatio, 0.8, 1.8)

//======================
// 2. Candle Body Ratio
//======================
candleRange = high - low
bodySize    = math.abs(close - open)
bodyRatio   = candleRange != 0 ? bodySize / candleRange : 0.0
bodyScore   = normalize(bodyRatio, 0.2, 0.9)

//======================
// 3. Volume Spike
//======================
volEma   = ta.ema(volume, volEmaLen)
volRatio = volEma != 0 ? volume / volEma : 0.0
volScore = normalize(volRatio, 0.8, 2.0)

//======================
// 4. Breakout Speed
//======================
prevHigh = ta.highest(high[1], breakoutLookback)
prevLow  = ta.lowest(low[1], breakoutLookback)

bullBreak = close > prevHigh
bearBreak = close < prevLow

bullDistance = bullBreak ? close - prevHigh : 0.0
bearDistance = bearBreak ? prevLow - close : 0.0

breakDistance = bullBreak ? bullDistance : bearBreak ? bearDistance : 0.0
breakSpeed    = atrSlow != 0 ? breakDistance / atrSlow : 0.0
speedScore    = normalize(breakSpeed, 0.0, 1.2)

//======================
// 5. Pullback Depth
//======================
swingHigh  = ta.highest(high, pullbackLen)
swingLow   = ta.lowest(low, pullbackLen)
swingRange = swingHigh - swingLow

bullPullbackDepth = swingRange != 0 ? (swingHigh - close) / swingRange : 1.0
bearPullbackDepth = swingRange != 0 ? (close - swingLow) / swingRange : 1.0

emaTrend  = ta.ema(close, 20)
direction = close > emaTrend ? 1 : close < emaTrend ? -1 : 0

currentPullbackDepth = direction == 1 ? bullPullbackDepth : direction == -1 ? bearPullbackDepth : 0.5

bullPullbackScore = 100.0 - normalize(bullPullbackDepth, 0.0, 0.7)
bearPullbackScore = 100.0 - normalize(bearPullbackDepth, 0.0, 0.7)

pullbackScore = direction == 1 ? bullPullbackScore : direction == -1 ? bearPullbackScore : 50.0

//======================
// Final Momentum Score
//======================
momentumScore =
     atrScore       * 0.25 +
     bodyScore      * 0.20 +
     volScore       * 0.20 +
     speedScore     * 0.20 +
     pullbackScore  * 0.15

bullMomentum = momentumScore >= strongLevel and direction == 1
bearMomentum = momentumScore >= strongLevel and direction == -1
hasMomentum  = bullMomentum or bearMomentum
weakMomentum = momentumScore < weakLevel

finalResult = bullMomentum ? "BULL MOMENTUM" : bearMomentum ? "BEAR MOMENTUM" : "NO MOMENTUM"
finalBg     = bullMomentum ? bullBg : bearMomentum ? bearBg : weakBg

//======================
// M Label: first candle momentum appears
//======================
momentumStarted = hasMomentum and not hasMomentum[1]

labelStyle =
     labelLocationInp == "Above Bar" ? label.style_label_down :
     labelLocationInp == "Below Bar" ? label.style_label_up :
     bullMomentum ? label.style_label_up : label.style_label_down

labelY =
     labelLocationInp == "Above Bar" ? high :
     labelLocationInp == "Below Bar" ? low :
     bullMomentum ? low : high

labelBg =
     bullMomentum ? color.green : color.red

if showMLabels and momentumStarted
    label.new(
         bar_index,
         labelY,
         labelText,
         style=labelStyle,
         color=labelBg,
         textcolor=color.white,
         size=labelTxtSize
     )

//======================
// Hidden Plot Optional
//======================
plot(showScorePlot ? momentumScore : na, "Momentum Score", linewidth=2, display=display.none)

//======================
// Alerts
//======================
alertcondition(bullMomentum, "Bullish Momentum", "Strong Bullish Momentum Detected")
alertcondition(bearMomentum, "Bearish Momentum", "Strong Bearish Momentum Detected")
alertcondition(weakMomentum, "Weak Momentum", "Weak Momentum Detected")
alertcondition(momentumStarted, "Momentum Started", "Momentum Started: M Label Printed")

//======================
// Table
//======================
var table t = table.new(pos, 4, 8, border_width=1, frame_width=1, frame_color=color.gray)

if showTable and barstate.islast
    table.cell(t, 0, 0, "Decoding Lab®", bgcolor=titleBg, text_color=txt, text_size=txtSize)
    table.merge_cells(t, 0, 0, 3, 0)

    table.cell(t, 0, 1, "Factor", bgcolor=headerBg, text_color=txt, text_size=txtSize)
    table.cell(t, 1, 1, "Reference", bgcolor=headerBg, text_color=txt, text_size=txtSize)
    table.cell(t, 2, 1, "Current", bgcolor=headerBg, text_color=txt, text_size=txtSize)
    table.cell(t, 3, 1, "Score", bgcolor=headerBg, text_color=txt, text_size=txtSize)

    table.cell(t, 0, 2, "ATR Exp.", bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 1, 2, "ATR" + str.tostring(atrSlowLen) + "=" + str.tostring(atrSlow, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 2, 2, "ATR" + str.tostring(atrFastLen) + "=" + str.tostring(atrFast, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 3, 2, str.tostring(atrScore, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)

    table.cell(t, 0, 3, "Body", bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 1, 3, "> 0.60", bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 2, 3, str.tostring(bodyRatio, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 3, 3, str.tostring(bodyScore, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)

    table.cell(t, 0, 4, "Volume", bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 1, 4, "EMA=" + str.tostring(volEma, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 2, 4, str.tostring(volume, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 3, 4, str.tostring(volScore, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)

    table.cell(t, 0, 5, "Break Speed", bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 1, 5, "ATR=" + str.tostring(atrSlow, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 2, 5, str.tostring(breakSpeed, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 3, 5, str.tostring(speedScore, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)

    table.cell(t, 0, 6, "Pullback", bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 1, 6, "< 0.50", bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 2, 6, str.tostring(currentPullbackDepth, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)
    table.cell(t, 3, 6, str.tostring(pullbackScore, "#.##"), bgcolor=cellBg, text_color=txt, text_size=txtSize)

    table.cell(t, 0, 7, finalResult, bgcolor=finalBg, text_color=txt, text_size=txtSize)
    table.cell(t, 1, 7, "Ref=" + str.tostring(strongLevel, "#.##"), bgcolor=finalBg, text_color=txt, text_size=txtSize)
    table.cell(t, 2, 7, "Now=" + str.tostring(momentumScore, "#.##"), bgcolor=finalBg, text_color=txt, text_size=txtSize)
    table.cell(t, 3, 7, direction == 1 ? "UP" : direction == -1 ? "DOWN" : "FLAT", bgcolor=finalBg, text_color=txt, text_size=txtSize)
````
