# Adaptive Trend Ribbon [Alpha Extract]

- url: https://www.tradingview.com/script/LHnnFK90-Adaptive-Trend-Ribbon-Alpha-Extract/
- type: indicator
- pine_id: PUB;52d770d71ade49738a97d447c4cbb2ed
- version: 2.0

## Description

A sophisticated adaptive trend-following framework that combines volatility-responsive moving averages, ribbon stack analysis, ATR-based trend rails, ADX confirmation, pullback continuation signals, and a real-time confidence dashboard into one complete market regime tool. The indicator is designed to identify bullish and bearish trend environments, filter weak conditions, highlight confirmed trend flips, and provide structured stop guidance through an adaptive ATR rail. By adjusting ribbon sensitivity based on current volatility, the system aims to stay responsive during expansion phases while remaining smoother during quieter market conditions.

🔶 Adaptive Volatility-Based Ribbon Engine

Implements a multi-layer adaptive EMA ribbon that automatically modifies its effective moving-average lengths based on current volatility conditions. When volatility expands, the ribbon becomes more responsive by shortening its dynamic length. When volatility contracts, the ribbon lengthens to reduce noise and avoid unnecessary whipsaw.

[pine]volRatioRaw = atrAverage > 0 ? atr / atrAverage : 1.0
volRatio = clamp(volRatioRaw, 0.35, 2.75)
emaFast = adaptiveEma(src, baseFast, volRatio, adaptStrength)[/pine]

This creates a trend ribbon that adapts to the market environment instead of relying on fixed moving-average behaviour across all conditions.

🔶 Six-Layer Trend Structure

Uses six adaptive moving averages ranging from fast to anchor length to define market structure across multiple trend speeds. The ribbon includes fast, mid, slow, and anchor components, allowing traders to see whether short-term momentum is aligned with broader trend direction.

A clean bullish trend forms when the ribbon is stacked from fastest above slowest, while a clean bearish trend forms when the ribbon is stacked from fastest below slowest. Mixed ribbon conditions indicate compression, transition, or weaker directional conviction.

🔶 Bullish & Bearish Stack Detection

Identifies strong directional alignment through full ribbon stack confirmation. Bullish stack conditions require every faster ribbon layer to sit above the slower layer beneath it, while bearish stack conditions require the opposite alignment.

This gives traders a simple way to distinguish clean trend environments from sideways or indecisive price action.

🔶 ATR Trend Rail System

Features a built-in ATR-based trend stop that acts as the main regime rail. The rail flips direction when price breaks through the active stop level, creating a clear bullish or bearish trend state.

[pine]longCandidateStop = railBasis - atr * atrMult
shortCandidateStop = railBasis + atr * atrMult
railDirection := close < trendStop ? -1 : 1[/pine]

The stop can be based on the ribbon midline, close, or HL2, giving traders flexibility in how the trend rail is anchored.

🔶 Regime Flip Signal Logic

Generates long and short signals when the trend rail flips direction and the confirmation conditions are satisfied. A bullish signal occurs when the regime flips into bullish structure, while a bearish signal occurs when the regime flips into bearish structure.

Signals are filtered through ADX and directional movement confirmation when enabled, helping reduce low-quality flips during weak or choppy market conditions.

🔶 ADX & Directional Movement Confirmation

Integrates ADX confirmation to measure whether the market has enough directional strength to justify a trend signal. The system also checks directional movement by comparing +DI and -DI, allowing bullish regimes to favour positive directional pressure and bearish regimes to favour negative directional pressure.

This confirmation layer helps separate true trend expansion from random price movement.

🔶 Pullback Continuation Alerts

Includes optional pullback continuation logic designed to identify trend resumption after price interacts with the adaptive ribbon. When price pulls into the ribbon area and then closes back in the trend direction, the system can trigger continuation alerts.

This is useful for traders who prefer entering after a trend has already been established rather than only trading the initial regime flip.

🔶 Confidence Scoring Framework

Calculates a real-time trend confidence score by combining multiple components of trend quality, including ribbon stack alignment, price position relative to the ATR rail, ADX strength, directional movement, and spread between fast and anchor ribbon layers.

The score provides a quick snapshot of how strong and confirmed the current trend environment is.

🔶 Dynamic Trend Coloring System

Uses adaptive color logic to visually represent bullish, bearish, and neutral/mixed conditions. Candles, ribbon lines, fills, the ATR stop rail, and the status panel all update according to the current regime.

When ADX confirmation is enabled but the filter has not passed, the system fades the trend color to show that the regime exists but confirmation is weaker.

🔶 Real-Time Status Panel

Features a compact dashboard that displays the most important trend information directly on the chart. The panel includes:

• Current regime
• Confidence percentage
• Confirmation status
• ADX value
• Volatility ratio
• Ribbon stack condition
• Active stop level

This allows traders to quickly assess whether the market is bullish, bearish, filtered, mixed, or entering a stronger trend phase.

🔶 Flexible Risk Rail Basis

Allows the ATR stop rail to be calculated from different price references depending on the trader’s preferred style. Ribbon Mid creates a smoother institutional-style trend rail, Close makes the rail more reactive, and HL2 provides a balanced price reference.

This flexibility makes the indicator suitable for both faster trend-following styles and slower swing-trend systems.

🔶 Clean Overlay Visual Design

Displays the full adaptive ribbon directly on price with optional candle coloring, background regime shading, trend stop plotting, and signal markers. The ribbon uses layered transparency to maintain chart readability while still showing the strength and direction of the trend structure.

The result is a clean visual layout that can be used as a primary trend framework or as a confirmation layer alongside other systems.

🔶 Comprehensive Alert System

Includes alerts for the most important trend events:

• Adaptive Ribbon Long
• Adaptive Ribbon Short
• Bullish Pullback Continuation
• Bearish Pullback Continuation
• Long Trend Exit
• Short Trend Exit

These alerts allow traders to monitor trend flips, pullback continuations, and invalidation events without needing to constantly watch the chart.

🔶 Why Choose Adaptive Trend Ribbon [Alpha Extract]?

This indicator provides a complete adaptive trend-following environment by combining responsive moving-average structure, volatility-adjusted behaviour, ATR-based trend rails, ADX confirmation, continuation logic, and live confidence scoring. Instead of relying on a single moving average or fixed trend signal, it evaluates multiple layers of trend quality before confirming direction.

The adaptive ribbon helps traders understand whether the market is strongly aligned, weakening, transitioning, or mixed. The ATR rail provides a clear trend invalidation reference, while the confidence panel gives immediate context on whether the trend has enough structure and strength behind it. Perfect for trend-following traders, swing traders, momentum traders, and systematic traders who want a cleaner way to identify confirmed bullish and bearish regimes with built-in risk guidance.

## Source Code

````pine
//@version=6
indicator("Adaptive Trend Ribbon [Alpha Extract]", shorttitle = "ATRibbon Pro", overlay = true, max_labels_count = 200, behind_chart = false)

// INPUTS
src = input.source(close, "Source", group = "Trend Engine")
baseFast = input.int(8, "Fast Base Length", minval = 2, maxval = 100, group = "Trend Engine")
baseMid1 = input.int(13, "Mid 1 Base Length", minval = 3, maxval = 150, group = "Trend Engine")
baseMid2 = input.int(21, "Mid 2 Base Length", minval = 4, maxval = 200, group = "Trend Engine")
baseSlow1 = input.int(34, "Slow 1 Base Length", minval = 5, maxval = 250, group = "Trend Engine")
baseSlow2 = input.int(55, "Slow 2 Base Length", minval = 6, maxval = 300, group = "Trend Engine")
baseAnchor = input.int(89, "Anchor Base Length", minval = 8, maxval = 400, group = "Trend Engine")
volLookback = input.int(100, "Volatility Lookback", minval = 20, maxval = 300, group = "Trend Engine")
adaptStrength = input.float(0.55, "Adapt Strength", minval = 0.0, maxval = 1.5, step = 0.05, group = "Trend Engine", tooltip = "Higher values shorten the ribbon in high volatility and lengthen it in quiet ranges.")

atrLength = input.int(14, "ATR Length", minval = 1, maxval = 100, group = "Risk Rail")
atrMult = input.float(2.6, "ATR Stop Multiplier", minval = 0.2, maxval = 10.0, step = 0.1, group = "Risk Rail")
railSource = input.string("Ribbon Mid", "ATR Rail Basis", options = ["Ribbon Mid", "Close", "HL2"], group = "Risk Rail")

useAdx = input.bool(true, "Use ADX Filter", group = "Confirmation")
diLength = input.int(14, "DI Length", minval = 1, maxval = 100, group = "Confirmation")
adxSmoothing = input.int(14, "ADX Smoothing", minval = 1, maxval = 100, group = "Confirmation")
adxThreshold = input.float(18.0, "ADX Threshold", minval = 1.0, maxval = 80.0, step = 0.5, group = "Confirmation")
pullbackTolerance = input.float(0.35, "Pullback Touch Tolerance (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = "Confirmation")
usePullbackAlerts = input.bool(true, "Use Pullback Alerts", group = "Confirmation")

showRibbon = input.bool(true, "Show Ribbon", group = "Display")
showRail = input.bool(true, "Show ATR Stop", group = "Display")
showCandles = input.bool(true, "Color Candles", group = "Display")
showBackground = input.bool(false, "Show Regime Background", group = "Display")
showPanel = input.bool(true, "Show Status Panel", group = "Display")
longSignalOffsetAtr = input.float(0.25, "Long Marker Offset (ATR)", minval = -2.0, maxval = 2.0, step = 0.05, group = "Display")
shortSignalOffsetAtr = input.float(0.25, "Short Marker Offset (ATR)", minval = -2.0, maxval = 2.0, step = 0.05, group = "Display")
bullColor = input.color(color.rgb(28, 196, 133), "Bull Color", group = "Display")
bearColor = input.color(color.rgb(221, 64, 92), "Bear Color", group = "Display")
neutralColor = input.color(color.rgb(135, 142, 155), "Neutral Color", group = "Display")

// FUNCTIONS
clamp(float value, float low, float high) =>
    math.max(math.min(value, high), low)

adaptiveEma(series float source, simple int baseLength, series float volRatio, simple float strength) =>
    dynLength = clamp(baseLength * (1.0 - (volRatio - 1.0) * strength), math.max(2.0, baseLength * 0.35), baseLength * 2.25)
    alpha = 2.0 / (dynLength + 1.0)
    var float out = na
    out := na(out[1]) ? source : out[1] + alpha * (source - out[1])
    out

// CALCULATIONS
atr = ta.atr(atrLength)
atrAverage = ta.sma(atr, volLookback)
volRatioRaw = atrAverage > 0 ? atr / atrAverage : 1.0
volRatio = clamp(volRatioRaw, 0.35, 2.75)

emaFast = adaptiveEma(src, baseFast, volRatio, adaptStrength)
emaMid1 = adaptiveEma(src, baseMid1, volRatio, adaptStrength)
emaMid2 = adaptiveEma(src, baseMid2, volRatio, adaptStrength)
emaSlow1 = adaptiveEma(src, baseSlow1, volRatio, adaptStrength)
emaSlow2 = adaptiveEma(src, baseSlow2, volRatio, adaptStrength)
emaAnchor = adaptiveEma(src, baseAnchor, volRatio, adaptStrength)

ribbonHigh = math.max(math.max(math.max(emaFast, emaMid1), math.max(emaMid2, emaSlow1)), math.max(emaSlow2, emaAnchor))
ribbonLow = math.min(math.min(math.min(emaFast, emaMid1), math.min(emaMid2, emaSlow1)), math.min(emaSlow2, emaAnchor))
ribbonMid = (emaMid2 + emaSlow1) / 2.0

bullStack = emaFast > emaMid1 and emaMid1 > emaMid2 and emaMid2 > emaSlow1 and emaSlow1 > emaSlow2 and emaSlow2 > emaAnchor
bearStack = emaFast < emaMid1 and emaMid1 < emaMid2 and emaMid2 < emaSlow1 and emaSlow1 < emaSlow2 and emaSlow2 < emaAnchor

[plusDI, minusDI, adxValue] = ta.dmi(diLength, adxSmoothing)
adxOk = not useAdx or adxValue >= adxThreshold
directionalOkBull = plusDI >= minusDI or not useAdx
directionalOkBear = minusDI >= plusDI or not useAdx

railBasis = railSource == "Close" ? close : railSource == "HL2" ? hl2 : ribbonMid
longCandidateStop = railBasis - atr * atrMult
shortCandidateStop = railBasis + atr * atrMult

var float trendStop = na
var int railDirection = 0
prevStop = nz(trendStop[1], railBasis)
prevDirection = nz(railDirection[1], close >= railBasis ? 1 : -1)

if prevDirection == 1
    trendStop := math.max(longCandidateStop, prevStop)
    railDirection := close < trendStop ? -1 : 1
else
    trendStop := math.min(shortCandidateStop, prevStop)
    railDirection := close > trendStop ? 1 : -1

if railDirection != prevDirection
    trendStop := railDirection == 1 ? longCandidateStop : shortCandidateStop

longTrend = close > trendStop and railDirection == 1
shortTrend = close < trendStop and railDirection == -1

var int regime = 0
if railDirection == 1
    regime := 1
else if railDirection == -1
    regime := -1
else
    regime := nz(regime[1], close >= railBasis ? 1 : -1)

trendFlip = regime != regime[1]
adxDirectionOk = regime == 1 ? directionalOkBull : regime == -1 ? directionalOkBear : false
adxFilterPassed = not useAdx or (adxOk and adxDirectionOk)
confirmedLong = longTrend and bullStack and adxFilterPassed
confirmedShort = shortTrend and bearStack and adxFilterPassed
confirmedTrend = regime == 1 ? confirmedLong : regime == -1 ? confirmedShort : false
bullFlip = trendFlip and regime == 1
bearFlip = trendFlip and regime == -1
longSignal = bullFlip and adxFilterPassed
shortSignal = bearFlip and adxFilterPassed
exitLong = regime[1] == 1 and regime != 1
exitShort = regime[1] == -1 and regime != -1

touchRibbon = low <= ribbonHigh + atr * pullbackTolerance and high >= ribbonLow - atr * pullbackTolerance
resumeBull = usePullbackAlerts and confirmedLong and touchRibbon[1] and close > emaFast and close > open
resumeBear = usePullbackAlerts and confirmedShort and touchRibbon[1] and close < emaFast and close < open

stackScore = (regime == 1 and bullStack) or (regime == -1 and bearStack) ? 40.0 : 0.0
railScore = (regime == 1 and close > trendStop) or (regime == -1 and close < trendStop) ? 25.0 : 0.0
diScore = adxDirectionOk ? 10.0 : 0.0
adxScore = useAdx ? clamp((adxValue - adxThreshold) / math.max(adxThreshold, 1.0) * 15.0, 0.0, 15.0) + diScore : 25.0
spreadScore = clamp(math.abs(emaFast - emaAnchor) / math.max(atr, syminfo.mintick) * 10.0, 0.0, 10.0)
confidence = math.round(stackScore + railScore + adxScore + spreadScore)

baseTrendColor = regime == 1 ? bullColor : regime == -1 ? bearColor : neutralColor
trendColor = useAdx and not adxFilterPassed ? color.new(baseTrendColor, 55) : baseTrendColor
railColor = trendColor
longSignalMarkerPrice = trendStop + atr * longSignalOffsetAtr
shortSignalMarkerPrice = trendStop + atr * shortSignalOffsetAtr

// PLOTS
pFast = plot(showRibbon ? emaFast : na, "Adaptive EMA Fast", color = color.new(trendColor, 0), linewidth = 2)
pMid1 = plot(showRibbon ? emaMid1 : na, "Adaptive EMA Mid 1", color = color.new(trendColor, 18), linewidth = 1)
pMid2 = plot(showRibbon ? emaMid2 : na, "Adaptive EMA Mid 2", color = color.new(trendColor, 28), linewidth = 1)
pSlow1 = plot(showRibbon ? emaSlow1 : na, "Adaptive EMA Slow 1", color = color.new(trendColor, 38), linewidth = 1)
pSlow2 = plot(showRibbon ? emaSlow2 : na, "Adaptive EMA Slow 2", color = color.new(trendColor, 48), linewidth = 1)
pAnchor = plot(showRibbon ? emaAnchor : na, "Adaptive EMA Anchor", color = color.new(trendColor, 0), linewidth = 2)

fill(pFast, pMid2, color.new(trendColor, 86), title = "Fast Ribbon Fill")
fill(pMid2, pAnchor, color.new(trendColor, 90), title = "Slow Ribbon Fill")

plot(showRail ? trendStop : na, "ATR Trend Stop", color = railColor, linewidth = 2, style = plot.style_linebr)

bgcolor(showBackground ? color.new(trendColor, 92) : na)
plotcandle(showCandles ? open : na, showCandles ? high : na, showCandles ? low : na, showCandles ? close : na, title = "Trend Candles", color = trendColor, wickcolor = trendColor, bordercolor = trendColor, force_overlay = true)

plotshape(longSignal ? longSignalMarkerPrice : na, "Long Signal", shape.triangleup, location.absolute, color = bullColor, size = size.small)
plotshape(shortSignal ? shortSignalMarkerPrice : na, "Short Signal", shape.triangledown, location.absolute, color = bearColor, size = size.small)

// STATUS PANEL //
var table panel = table.new(position.top_right, 2, 7, frame_color = color.new(neutralColor, 45), frame_width = 1, border_width = 0)

if barstate.islast
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.cell(panel, 0, 0, "Adaptive Ribbon", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5))
        table.cell(panel, 1, 0, regime == 1 ? "Bull" : regime == -1 ? "Bear" : "Neutral", text_color = color.white, bgcolor = trendColor)
        table.cell(panel, 0, 1, "Confidence", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5))
        table.cell(panel, 1, 1, str.tostring(confidence) + "%", text_color = color.white, bgcolor = color.new(trendColor, 15))
        table.cell(panel, 0, 2, "Confirm", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5))
        table.cell(panel, 1, 2, confirmedTrend ? "Passed" : "Filtered", text_color = color.white, bgcolor = color.new(confirmedTrend ? trendColor : neutralColor, 30))
        table.cell(panel, 0, 3, "ADX", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5))
        table.cell(panel, 1, 3, str.tostring(adxValue, "#.0"), text_color = adxOk ? color.white : neutralColor, bgcolor = color.new(adxOk ? trendColor : neutralColor, 35))
        table.cell(panel, 0, 4, "Vol Ratio", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5))
        table.cell(panel, 1, 4, str.tostring(volRatio, "#.00"), text_color = color.white, bgcolor = color.new(neutralColor, 55))
        table.cell(panel, 0, 5, "Ribbon", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5))
        table.cell(panel, 1, 5, bullStack ? "Bull Stack" : bearStack ? "Bear Stack" : "Mixed", text_color = color.white, bgcolor = color.new(trendColor, bullStack or bearStack ? 20 : 65))
        table.cell(panel, 0, 6, "Stop", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 5))
        table.cell(panel, 1, 6, str.tostring(trendStop, format.mintick), text_color = color.white, bgcolor = color.new(railColor, 25))

// ALERTS
alertcondition(longSignal, "Adaptive Ribbon Long", "Adaptive Trend Ribbon Pro: bullish signal passed confirmation.")
alertcondition(shortSignal, "Adaptive Ribbon Short", "Adaptive Trend Ribbon Pro: bearish signal passed confirmation.")
alertcondition(resumeBull, "Adaptive Ribbon Bull Pullback", "Adaptive Trend Ribbon Pro: bullish pullback continuation.")
alertcondition(resumeBear, "Adaptive Ribbon Bear Pullback", "Adaptive Trend Ribbon Pro: bearish pullback continuation.")
alertcondition(exitLong, "Adaptive Ribbon Long Exit", "Adaptive Trend Ribbon Pro: long trend invalidated.")
alertcondition(exitShort, "Adaptive Ribbon Short Exit", "Adaptive Trend Ribbon Pro: short trend invalidated.")
````
