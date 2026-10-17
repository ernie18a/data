# TRADION Adaptive Momentum Matrix

- url: https://www.tradingview.com/script/rkjp7Oyx/
- type: indicator
- pine_id: PUB;c7e93f963ec4489fa3ea2b091fefa16e
- version: 1.0

## Description

A normalized multi-factor momentum framework combining RSI structure, ROC velocity, MACD impulse and stochastic pressure into a unified -100 to +100 momentum regime model.

────────────────────────────
OVERVIEW
────────────────────────────

TRADION Adaptive Momentum Matrix (AMM) is a composite momentum oscillator designed to evaluate not only the direction of momentum, but also its intensity, acceleration and regime.

Rather than displaying several conventional oscillators independently, AMM transforms four different momentum dimensions into normalized components and combines them into a single bounded Momentum Score ranging from -100 to +100.

The engine integrates:

• RSI Momentum Structure
• Rate of Change (ROC) Velocity
• ATR-Normalized MACD Impulse
• Stochastic Pressure
• Weighted Composite Momentum Scoring
• Multi-Level Momentum Regimes
• Momentum Signal Line
• Compression Detection
• Confirmed-Bar Momentum Transitions
• Six Dedicated Alert Conditions

The objective is to provide a unified interpretation of momentum conditions while preserving the information contributed by different momentum methodologies.


────────────────────────────
COMPOSITE MOMENTUM ARCHITECTURE
────────────────────────────

The core of TRADION AMM is a weighted composite model.

Each momentum component measures a different characteristic of price behavior and is transformed into a normalized range before entering the final calculation.

The four default components are:

RSI Momentum — 30%
ROC Velocity — 25%
MACD Impulse — 25%
Stochastic Pressure — 20%

The component weights are user-adjustable.

The engine automatically normalizes the total weighting, allowing users to modify the relative importance of individual components without requiring the weights to manually sum to 100.


────────────────────────────
1. RSI MOMENTUM STRUCTURE
────────────────────────────

RSI is transformed around its 50 equilibrium level.

Values above 50 contribute positively to the composite momentum model, while values below 50 contribute negatively.

The distance from the 50 level represents the relative intensity of the RSI component.

This allows RSI to function as a normalized directional momentum input rather than simply as an overbought/oversold condition.


────────────────────────────
2. ROC VELOCITY
────────────────────────────

Rate of Change measures the velocity of price movement over the selected lookback period.

Positive ROC contributes to bullish momentum.

Negative ROC contributes to bearish momentum.

Because raw ROC magnitude can vary considerably between instruments and market regimes, the component is normalized using a configurable ROC scale before entering the composite calculation.


────────────────────────────
3. ATR-NORMALIZED MACD IMPULSE
────────────────────────────

The MACD component focuses on impulse rather than the absolute MACD level.

The engine calculates the difference between the MACD line and its signal line and then normalizes this histogram relative to ATR.

This is an important part of the architecture.

A raw MACD histogram value cannot be directly compared across instruments with different price scales and volatility characteristics.

ATR normalization expresses MACD impulse relative to the instrument's current volatility environment before it contributes to the composite score.


────────────────────────────
4. STOCHASTIC PRESSURE
────────────────────────────

The Stochastic component evaluates the position of price within its recent high-low range.

The result is smoothed and transformed around the neutral 50 level.

Values above the midpoint contribute positive pressure, while values below the midpoint contribute negative pressure.

This component adds a shorter-term measure of directional price pressure to the broader momentum framework.


────────────────────────────
THE -100 TO +100 MOMENTUM SCORE
────────────────────────────

After normalization and weighting, the four components are combined into the Adaptive Momentum Score.

The final oscillator is bounded between:

-100 = Maximum bearish momentum classification
0 = Momentum equilibrium
+100 = Maximum bullish momentum classification

The score is not intended to predict a specific future return.

Instead, it measures the degree of directional agreement between the underlying momentum components at the current point in time.


────────────────────────────
MOMENTUM REGIME MODEL
────────────────────────────

Instead of treating momentum as simply positive or negative, TRADION AMM separates the oscillator into multiple regimes.

Default bullish regimes:

+15 to +40
BULLISH

+40 to +70
STRONG BULLISH

+70 to +100
EXTREME BULLISH


Default bearish regimes:

-15 to -40
BEARISH

-40 to -70
STRONG BEARISH

-70 to -100
EXTREME BEARISH


The area between -15 and +15 represents the neutral momentum region.

All major regime thresholds are configurable.


────────────────────────────
ADAPTIVE HISTOGRAM
────────────────────────────

The histogram provides the primary visual representation of the composite Momentum Score.

Its color changes according to the active momentum regime.

Bullish momentum progresses through increasingly stronger green / turquoise classifications as the score rises.

Bearish momentum progresses through increasingly stronger red classifications as the score falls.

The histogram therefore communicates two variables simultaneously:

• Momentum direction
• Momentum intensity

This makes transitions between neutral, directional, strong and extreme momentum regimes immediately visible.


────────────────────────────
MOMENTUM SIGNAL LINE
────────────────────────────

A configurable EMA of the Momentum Score is plotted as a secondary signal line.

This provides a smoothed reference for interpreting changes in the composite oscillator.

The relationship between the Momentum Score and its signal line can help identify:

• Momentum acceleration
• Momentum deceleration
• Changes in short-term impulse
• Potential regime transitions

The signal line can be enabled or disabled from the settings.


────────────────────────────
MOMENTUM ACCELERATION
────────────────────────────

The engine also calculates the bar-to-bar change in the composite Momentum Score.

Positive momentum that continues to increase represents bullish momentum acceleration.

Negative momentum that continues to decrease represents bearish momentum acceleration.

This internal measurement allows the framework to distinguish momentum level from changes in momentum intensity.


────────────────────────────
COMPRESSION ENGINE
────────────────────────────

Markets do not remain in directional momentum regimes continuously.

TRADION AMM therefore includes a Momentum Compression model.

The engine evaluates the standard deviation of the composite Momentum Score over a configurable lookback period.

Compression is identified when:

• Momentum variability falls below the selected threshold
• The composite score remains inside the neutral momentum region

These conditions identify periods where directional momentum has contracted.

Compression does NOT predict the direction of a future breakout.

It simply identifies a low-dispersion momentum environment that may deserve additional attention.


────────────────────────────
CONFIRMED MOMENTUM TRANSITIONS
────────────────────────────

TRADION AMM includes six momentum transition classifications:

BULLISH SHIFT
STRONG BULLISH
EXTREME BULLISH

BEARISH SHIFT
STRONG BEARISH
EXTREME BEARISH

These events are generated when the composite Momentum Score crosses the corresponding regime threshold.

When Confirm Signals At Bar Close is enabled, a transition is accepted only after the current chart bar has been confirmed.

This helps prevent temporary intrabar threshold crossings from being treated as completed momentum transitions.


────────────────────────────
VISUAL REGIME MAP
────────────────────────────

The oscillator panel is divided into visually distinct momentum zones.

This provides a structured map of the current momentum environment:

EXTREME BULLISH
↑
STRONG BULLISH
↑
BULLISH
↑
NEUTRAL / COMPRESSION
↓
BEARISH
↓
STRONG BEARISH
↓
EXTREME BEARISH

The visual design is intended to make changes in momentum regime readable without requiring constant interpretation of individual indicator values.


────────────────────────────
USER CONTROLS
────────────────────────────

Momentum Engine:

• Source
• RSI Period
• ROC Period
• MACD Fast Length
• MACD Slow Length
• MACD Signal Length
• Stochastic Period
• Stochastic Smoothing


Component Weights:

• RSI Weight
• ROC Weight
• MACD Weight
• Stochastic Weight


Normalization:

• ROC Normalization Scale
• MACD ATR Normalization Period
• MACD Normalization Sensitivity


Momentum Regimes:

• Bullish Threshold
• Strong Threshold
• Extreme Threshold


Signal Engine:

• Momentum Signal Length
• Show Momentum Shift Signals
• Confirm Signals At Bar Close


Compression:

• Compression Lookback
• Compression Threshold
• Highlight Compression


Visual Settings:

• Show Momentum Histogram
• Show Signal Line
• Show Regime Zones


────────────────────────────
ALERT SYSTEM
────────────────────────────

Six dedicated TradingView alert conditions are included:

• TRADION BULLISH SHIFT
• TRADION STRONG BULLISH
• TRADION EXTREME BULLISH
• TRADION BEARISH SHIFT
• TRADION STRONG BEARISH
• TRADION EXTREME BEARISH

Each momentum classification can therefore be monitored independently.


────────────────────────────
PRACTICAL INTERPRETATION
────────────────────────────

TRADION Adaptive Momentum Matrix can be used as:

• A composite momentum oscillator
• A momentum regime classifier
• A momentum-strength confirmation layer
• A momentum acceleration/deceleration reference
• A compression detection framework
• A confirmation tool alongside independent trend analysis
• An alert-based momentum monitoring system

For example, a positive Momentum Score does not automatically imply that momentum is strong.

The regime model distinguishes between ordinary bullish momentum, strong bullish momentum and extreme bullish momentum.

The same principle applies to bearish conditions.

This distinction is central to the design of the indicator.


────────────────────────────
DESIGN PHILOSOPHY
────────────────────────────

Momentum is multidimensional.

RSI measures momentum differently from ROC.

ROC measures velocity differently from MACD impulse.

Stochastic positioning provides different information from all three.

TRADION Adaptive Momentum Matrix does not attempt to replace these concepts with a single conventional oscillator.

Instead, it asks a broader question:

How strongly do multiple independent momentum measurements agree on the current directional state?

The individual components are normalized, weighted and aggregated into a common -100 to +100 framework.

The resulting Momentum Score is then classified into structured regimes, allowing direction and intensity to be interpreted within the same analytical model.


────────────────────────────
IMPORTANT NOTES
────────────────────────────

TRADION Adaptive Momentum Matrix is an analytical oscillator, not a trading strategy or prediction system.

BULLISH, STRONG BULLISH, EXTREME BULLISH, BEARISH, STRONG BEARISH and EXTREME BEARISH classifications describe conditions calculated by the indicator.

They do not guarantee future price direction, profitability or trade outcomes.

EXTREME momentum should not automatically be interpreted as a reversal condition.

Strong momentum can remain elevated or depressed for extended periods during directional markets.

Similarly, Momentum Compression does not predict the direction or timing of a future breakout.

Confirmed-bar processing can reduce temporary intrabar signals, but it does not eliminate market risk, signal lag or false transitions.

Users should evaluate the indicator within their own analytical framework and apply appropriate risk management.

For research and educational purposes.

## Source Code

````pine
//@version=6
indicator("TRADION Adaptive Momentum Matrix", shorttitle="TRADION AMM", overlay=false)

//====================================================================
// TRADION ADAPTIVE MOMENTUM MATRIX
// Composite Momentum + Adaptive Regimes + Compression + Confirmed Signals
//====================================================================

//--------------------------------------------------------------------
// COLORS
//--------------------------------------------------------------------

extremeBullColor = #00FF88
strongBullColor  = #00E5A8
bullColor        = #19D37E

neutralColor     = #9C27FF
compressionColor = #7C4DFF

bearColor        = #FF3B5C
strongBearColor  = #FF1744
extremeBearColor = #FF003C

zeroColor        = #90A4AE

//--------------------------------------------------------------------
// FUNCTIONS
//--------------------------------------------------------------------

f_clamp(float value, float minValue, float maxValue)=>
    math.max(minValue, math.min(maxValue, value))

f_normalize(float value, float scale)=>
    scale == 0.0 ? 0.0 : f_clamp(value / scale, -1.0, 1.0)

//--------------------------------------------------------------------
// 01 - CORE SETTINGS
//--------------------------------------------------------------------

src = input.source(close, "Source", group="01 - Momentum Engine")

rsiLen = input.int(14, "RSI Period", minval=2, group="01 - Momentum Engine")

rocLen = input.int(9, "ROC Period", minval=1, group="01 - Momentum Engine")

macdFast = input.int(12, "MACD Fast Length", minval=1, group="01 - Momentum Engine")

macdSlow = input.int(26, "MACD Slow Length", minval=2, group="01 - Momentum Engine")

macdSignalLen = input.int(9, "MACD Signal Length", minval=1, group="01 - Momentum Engine")

stochLen = input.int(14, "Stochastic Period", minval=2, group="01 - Momentum Engine")

stochSmooth = input.int(3, "Stochastic Smoothing", minval=1, group="01 - Momentum Engine")

//--------------------------------------------------------------------
// 02 - COMPONENT WEIGHTS
//--------------------------------------------------------------------

rsiWeight = input.float(30.0, "RSI Weight", minval=0.0, maxval=100.0, step=5.0, group="02 - Component Weights")

rocWeight = input.float(25.0, "ROC Weight", minval=0.0, maxval=100.0, step=5.0, group="02 - Component Weights")

macdWeight = input.float(25.0, "MACD Weight", minval=0.0, maxval=100.0, step=5.0, group="02 - Component Weights")

stochWeight = input.float(20.0, "Stochastic Weight", minval=0.0, maxval=100.0, step=5.0, group="02 - Component Weights")

//--------------------------------------------------------------------
// 03 - NORMALIZATION
//--------------------------------------------------------------------

rocScale = input.float(3.0, "ROC Normalization Scale", minval=0.1, step=0.1, group="03 - Normalization")

macdAtrLen = input.int(14, "MACD ATR Normalization Period", minval=1, group="03 - Normalization")

macdScale = input.float(0.30, "MACD Normalization Sensitivity", minval=0.05, step=0.05, group="03 - Normalization")

//--------------------------------------------------------------------
// 04 - REGIME LEVELS
//--------------------------------------------------------------------

bullLevel = input.float(15.0, "Bullish Threshold", minval=1.0, maxval=50.0, step=1.0, group="04 - Momentum Regimes")

strongLevel = input.float(40.0, "Strong Threshold", minval=10.0, maxval=80.0, step=1.0, group="04 - Momentum Regimes")

extremeLevel = input.float(70.0, "Extreme Threshold", minval=20.0, maxval=100.0, step=1.0, group="04 - Momentum Regimes")

//--------------------------------------------------------------------
// 05 - SIGNAL SETTINGS
//--------------------------------------------------------------------

signalLen = input.int(5, "Momentum Signal Length", minval=1, group="05 - Signal Engine")

showSignals = input.bool(true, "Show Momentum Shift Signals", group="05 - Signal Engine")

confirmedSignals = input.bool(true, "Confirm Signals At Bar Close", group="05 - Signal Engine")

//--------------------------------------------------------------------
// 06 - COMPRESSION SETTINGS
//--------------------------------------------------------------------

compressionLookback = input.int(20, "Compression Lookback", minval=5, group="06 - Compression")

compressionThreshold = input.float(12.0, "Compression Threshold", minval=2.0, maxval=30.0, step=1.0, group="06 - Compression")

showCompression = input.bool(true, "Highlight Compression", group="06 - Compression")

//--------------------------------------------------------------------
// 07 - VISUAL SETTINGS
//--------------------------------------------------------------------

showHistogram = input.bool(true, "Show Momentum Histogram", group="07 - Visual Settings")

showSignalLine = input.bool(true, "Show Signal Line", group="07 - Visual Settings")

showRegimeCloud = input.bool(true, "Show Regime Zones", group="07 - Visual Settings")

//====================================================================
// RSI COMPONENT
//====================================================================

rsiValue = ta.rsi(src, rsiLen)

rsiComponent = f_clamp((rsiValue - 50.0) / 50.0, -1.0, 1.0)

//====================================================================
// ROC COMPONENT
//====================================================================

rocValue = ta.roc(src, rocLen)

rocComponent = f_normalize(rocValue, rocScale)

//====================================================================
// MACD IMPULSE COMPONENT
//====================================================================

fastEMA = ta.ema(src, macdFast)

slowEMA = ta.ema(src, macdSlow)

macdLine = fastEMA - slowEMA

macdSignal = ta.ema(macdLine, macdSignalLen)

macdHistogram = macdLine - macdSignal

atrValue = ta.atr(macdAtrLen)

safeATR = math.max(atrValue, syminfo.mintick)

macdNormalized = macdHistogram / safeATR

macdComponent = f_normalize(macdNormalized, macdScale)

//====================================================================
// STOCHASTIC PRESSURE COMPONENT
//====================================================================

lowestLow = ta.lowest(low, stochLen)

highestHigh = ta.highest(high, stochLen)

stochRange = math.max(highestHigh - lowestLow, syminfo.mintick)

rawStoch = 100.0 * (src - lowestLow) / stochRange

stochValue = ta.sma(rawStoch, stochSmooth)

stochComponent = f_clamp((stochValue - 50.0) / 50.0, -1.0, 1.0)

//====================================================================
// WEIGHT NORMALIZATION
//====================================================================

totalWeight = math.max(rsiWeight + rocWeight + macdWeight + stochWeight, 1.0)

normalizedRsiWeight = rsiWeight / totalWeight

normalizedRocWeight = rocWeight / totalWeight

normalizedMacdWeight = macdWeight / totalWeight

normalizedStochWeight = stochWeight / totalWeight

//====================================================================
// COMPOSITE MOMENTUM SCORE
//====================================================================

momentumRaw = rsiComponent * normalizedRsiWeight + rocComponent * normalizedRocWeight + macdComponent * normalizedMacdWeight + stochComponent * normalizedStochWeight

momentumScore = f_clamp(momentumRaw * 100.0, -100.0, 100.0)

//====================================================================
// SIGNAL LINE
//====================================================================

momentumSignal = ta.ema(momentumScore, signalLen)

//====================================================================
// MOMENTUM ACCELERATION
//====================================================================

momentumDelta = momentumScore - momentumScore[1]

momentumAcceleratingBull = momentumScore > 0 and momentumDelta > 0

momentumAcceleratingBear = momentumScore < 0 and momentumDelta < 0

//====================================================================
// COMPRESSION ENGINE
//====================================================================

momentumDeviation = ta.stdev(momentumScore, compressionLookback)

isCompression = momentumDeviation < compressionThreshold and math.abs(momentumScore) < bullLevel

//====================================================================
// REGIME CLASSIFICATION
//====================================================================

extremeBull = momentumScore >= extremeLevel

strongBull = momentumScore >= strongLevel and momentumScore < extremeLevel

bullish = momentumScore >= bullLevel and momentumScore < strongLevel

neutral = momentumScore > -bullLevel and momentumScore < bullLevel

bearish = momentumScore <= -bullLevel and momentumScore > -strongLevel

strongBear = momentumScore <= -strongLevel and momentumScore > -extremeLevel

extremeBear = momentumScore <= -extremeLevel

//====================================================================
// DYNAMIC HISTOGRAM COLOR
//====================================================================

momentumColor = extremeBull ? extremeBullColor : strongBull ? strongBullColor : bullish ? bullColor : extremeBear ? extremeBearColor : strongBear ? strongBearColor : bearish ? bearColor : neutralColor

//====================================================================
// MOMENTUM SHIFT ENGINE
//====================================================================

bullShiftRaw = ta.crossover(momentumScore, bullLevel)

bearShiftRaw = ta.crossunder(momentumScore, -bullLevel)

strongBullShiftRaw = ta.crossover(momentumScore, strongLevel)

strongBearShiftRaw = ta.crossunder(momentumScore, -strongLevel)

extremeBullShiftRaw = ta.crossover(momentumScore, extremeLevel)

extremeBearShiftRaw = ta.crossunder(momentumScore, -extremeLevel)

signalConfirmation = confirmedSignals ? barstate.isconfirmed : true

bullShift = bullShiftRaw and signalConfirmation

bearShift = bearShiftRaw and signalConfirmation

strongBullShift = strongBullShiftRaw and signalConfirmation

strongBearShift = strongBearShiftRaw and signalConfirmation

extremeBullShift = extremeBullShiftRaw and signalConfirmation

extremeBearShift = extremeBearShiftRaw and signalConfirmation

//====================================================================
// REGIME LEVELS
//====================================================================

extremeBullLine = hline(70, "Extreme Bullish", color=color.new(extremeBullColor, 55), linestyle=hline.style_dotted)

strongBullLine = hline(40, "Strong Bullish", color=color.new(strongBullColor, 65), linestyle=hline.style_dotted)

bullLine = hline(15, "Bullish Threshold", color=color.new(bullColor, 70), linestyle=hline.style_dotted)

zeroLine = hline(0, "Zero Line", color=color.new(zeroColor, 45), linestyle=hline.style_solid)

bearLine = hline(-15, "Bearish Threshold", color=color.new(bearColor, 70), linestyle=hline.style_dotted)

strongBearLine = hline(-40, "Strong Bearish", color=color.new(strongBearColor, 65), linestyle=hline.style_dotted)

extremeBearLine = hline(-70, "Extreme Bearish", color=color.new(extremeBearColor, 55), linestyle=hline.style_dotted)

//====================================================================
// REGIME CLOUDS
//====================================================================

fill(extremeBullLine, strongBullLine, color=showRegimeCloud ? color.new(extremeBullColor, 88) : na, title="Extreme Bullish Zone")

fill(strongBullLine, bullLine, color=showRegimeCloud ? color.new(strongBullColor, 91) : na, title="Strong Bullish Zone")

fill(bullLine, zeroLine, color=showRegimeCloud ? color.new(bullColor, 94) : na, title="Bullish Zone")

fill(zeroLine, bearLine, color=showRegimeCloud ? color.new(bearColor, 94) : na, title="Bearish Zone")

fill(bearLine, strongBearLine, color=showRegimeCloud ? color.new(strongBearColor, 91) : na, title="Strong Bearish Zone")

fill(strongBearLine, extremeBearLine, color=showRegimeCloud ? color.new(extremeBearColor, 88) : na, title="Extreme Bearish Zone")

//====================================================================
// COMPRESSION BACKGROUND
//====================================================================

bgcolor(showCompression and isCompression ? color.new(compressionColor, 88) : na, title="Momentum Compression")

//====================================================================
// HISTOGRAM
//====================================================================

plot(showHistogram ? momentumScore : na, title="Adaptive Momentum Score", style=plot.style_histogram, linewidth=4, color=momentumColor, histbase=0)

//====================================================================
// MOMENTUM SCORE LINE
//====================================================================

plot(momentumScore, title="Momentum Matrix", color=momentumColor, linewidth=2)

//====================================================================
// SIGNAL LINE
//====================================================================

plot(showSignalLine ? momentumSignal : na, title="Momentum Signal Line", color=color.new(color.white, 15), linewidth=2)

//====================================================================
// BULLISH SHIFT SIGNALS
//====================================================================

plotshape(showSignals and bullShift and not strongBullShift and not extremeBullShift, title="BULLISH SHIFT", text="BULL", style=shape.labelup, location=location.bottom, color=bullColor, textcolor=color.black, size=size.tiny)

plotshape(showSignals and strongBullShift and not extremeBullShift, title="STRONG BULLISH", text="STRONG", style=shape.labelup, location=location.bottom, color=strongBullColor, textcolor=color.black, size=size.small)

plotshape(showSignals and extremeBullShift, title="EXTREME BULLISH", text="EXTREME", style=shape.labelup, location=location.bottom, color=extremeBullColor, textcolor=color.black, size=size.normal)

//====================================================================
// BEARISH SHIFT SIGNALS
//====================================================================

plotshape(showSignals and bearShift and not strongBearShift and not extremeBearShift, title="BEARISH SHIFT", text="BEAR", style=shape.labeldown, location=location.top, color=bearColor, textcolor=color.white, size=size.tiny)

plotshape(showSignals and strongBearShift and not extremeBearShift, title="STRONG BEARISH", text="STRONG", style=shape.labeldown, location=location.top, color=strongBearColor, textcolor=color.white, size=size.small)

plotshape(showSignals and extremeBearShift, title="EXTREME BEARISH", text="EXTREME", style=shape.labeldown, location=location.top, color=extremeBearColor, textcolor=color.white, size=size.normal)

//====================================================================
// DATA WINDOW
//====================================================================

plot(rsiValue, title="RSI Component", color=color.new(color.white, 100), display=display.data_window)

plot(rocValue, title="ROC Component", color=color.new(color.white, 100), display=display.data_window)

plot(macdHistogram, title="MACD Impulse", color=color.new(color.white, 100), display=display.data_window)

plot(stochValue, title="Stochastic Pressure", color=color.new(color.white, 100), display=display.data_window)

//====================================================================
// ALERTS
//====================================================================

alertcondition(bullShift, title="TRADION BULLISH SHIFT", message="TRADION Adaptive Momentum Matrix | BULLISH SHIFT | {{ticker}} | Price: {{close}}")

alertcondition(strongBullShift, title="TRADION STRONG BULLISH", message="TRADION Adaptive Momentum Matrix | STRONG BULLISH | {{ticker}} | Price: {{close}}")

alertcondition(extremeBullShift, title="TRADION EXTREME BULLISH", message="TRADION Adaptive Momentum Matrix | EXTREME BULLISH | {{ticker}} | Price: {{close}}")

alertcondition(bearShift, title="TRADION BEARISH SHIFT", message="TRADION Adaptive Momentum Matrix | BEARISH SHIFT | {{ticker}} | Price: {{close}}")

alertcondition(strongBearShift, title="TRADION STRONG BEARISH", message="TRADION Adaptive Momentum Matrix | STRONG BEARISH | {{ticker}} | Price: {{close}}")

alertcondition(extremeBearShift, title="TRADION EXTREME BEARISH", message="TRADION Adaptive Momentum Matrix | EXTREME BEARISH | {{ticker}} | Price: {{close}}")
````
