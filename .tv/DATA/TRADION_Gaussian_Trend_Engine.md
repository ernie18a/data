<!-- tradingview-pine-id: PUB;0f4f4ad56c444c50834401e5737337de -->
<!-- tradingviewscripts-format: 1 -->
# TRADION Gaussian Trend Engine

Source: https://www.tradingview.com/script/aQigxlQY/

## Description

TRADION Gaussian Trend Engine

OVERVIEW

TRADION Gaussian Trend Engine is a multi-factor trend analysis framework designed to evaluate market direction, trend strength, momentum alignment and volatility within a unified model.

The indicator is built around an independently implemented multi-pole Gaussian cascade. Instead of using Gaussian direction alone as a trading signal, the engine evaluates several additional dimensions of market behavior before qualifying a directional transition.

The framework combines:

• Configurable multi-pole Gaussian smoothing
• ATR-normalized Gaussian slope
• Price displacement from the Gaussian baseline
• RSI momentum analysis
• Rate of Change (ROC)
• A composite 0–100 Trend Strength Score
• Volatility-adaptive trend ribbons
• Three-level BUY / SELL classification
• Confirmed-bar signal generation
• Dedicated TradingView alerts

The design objective is selective trend qualification rather than generating a signal on every minor directional fluctuation.

────────────────────────────
GAUSSIAN TREND ENGINE
────────────────────────────

The core of the indicator is a configurable multi-pole Gaussian cascade.

The user can control two primary parameters:

Gaussian Period:
Controls the smoothing horizon of the filter.

Gaussian Poles:
Controls the number of sequential Gaussian smoothing stages used by the engine, from 1 to 6.

Each additional pole applies another stage of Gaussian smoothing to the previous output.

This architecture provides a configurable balance between responsiveness and noise reduction.

The final output of the selected pole becomes the Gaussian trend baseline used by the rest of the engine.

────────────────────────────
TREND DIRECTION
────────────────────────────

Directional state is determined from the slope of the Gaussian baseline.

When the current Gaussian value is above its previous value, the engine identifies a bullish directional state.

When the current Gaussian value is below its previous value, the engine identifies a bearish directional state.

The Gaussian line changes dynamically:

Green = Bullish Gaussian direction
Red = Bearish Gaussian direction

An unchanged Gaussian value preserves the previous directional state.

────────────────────────────
VOLATILITY NORMALIZATION
────────────────────────────

Raw price movement has different significance across instruments and volatility regimes.

For this reason, ATR is used as a normalization reference within the engine.

Two important measurements are normalized relative to ATR:

• Gaussian slope magnitude
• Distance between price and the Gaussian baseline

This allows the strength model to evaluate movement relative to current market volatility rather than relying only on absolute price changes.

────────────────────────────
TREND STRENGTH SCORE
────────────────────────────

TRADION Gaussian Trend Engine calculates a composite Trend Strength Score ranging from 0 to 100.

The score combines four normalized components:

1. Gaussian Slope Strength — 40%
2. Price Distance from Gaussian — 20%
3. RSI Momentum Intensity — 25%
4. ROC Magnitude — 15%

Gaussian Slope Strength measures the magnitude of directional movement in the Gaussian baseline relative to ATR.

Price Distance measures the absolute displacement of price from the Gaussian baseline relative to ATR.

RSI Momentum Intensity measures the distance of RSI from its neutral 50 level.

ROC Magnitude measures the absolute velocity of price movement.

Each component is normalized before being incorporated into the final weighted score.

The result is a single 0–100 metric designed to describe the degree of agreement between trend movement, price expansion and momentum.

────────────────────────────
MOMENTUM CONFIRMATION
────────────────────────────

Momentum confirmation can be enabled or disabled by the user.

For bullish confirmation, the default model requires:

• RSI above 50 plus the selected Neutral Zone
• Positive ROC

For bearish confirmation, it requires:

• RSI below 50 minus the selected Neutral Zone
• Negative ROC

This layer prevents every Gaussian slope change from automatically qualifying as a BUY or SELL event.

The RSI Neutral Zone is configurable, allowing the user to control how much momentum separation is required around the RSI 50 equilibrium level.

────────────────────────────
DIRECTIONAL QUALIFICATION
────────────────────────────

A qualified bullish setup requires:

• Rising Gaussian direction
• Price above the Gaussian baseline
• Valid bullish momentum when momentum confirmation is enabled
• Trend Strength above the configured minimum threshold

A qualified bearish setup requires:

• Falling Gaussian direction
• Price below the Gaussian baseline
• Valid bearish momentum when momentum confirmation is enabled
• Trend Strength above the configured minimum threshold

This means that Gaussian direction, price structure, momentum and trend strength are evaluated together before a directional event is accepted.

────────────────────────────
THREE-LEVEL SIGNAL CLASSIFICATION
────────────────────────────

Qualified transitions are classified according to their Trend Strength Score.

Bullish classifications:

BUY
STRONG BUY
EXTREME BUY

Bearish classifications:

SELL
STRONG SELL
EXTREME SELL

The default thresholds are:

Minimum Signal Strength: 25
Strong Signal Threshold: 55
Extreme Signal Threshold: 75

These thresholds are fully configurable.

A standard signal represents a qualified directional transition below the Strong threshold.

A STRONG signal represents a transition whose Trend Strength reaches the Strong threshold.

An EXTREME signal represents a transition whose Trend Strength reaches the highest configured classification threshold.

These labels describe the strength of the conditions detected by the model. They are not predictions of future returns.

────────────────────────────
CONFIRMED-BAR SIGNAL ENGINE
────────────────────────────

Signal generation uses confirmed-bar logic.

A new directional signal is accepted only when the current chart bar is confirmed.

This prevents temporary intrabar conditions from being treated as completed signals before the candle closes.

The engine also maintains directional signal state.

Once a bullish signal has been generated, another bullish signal is not repeatedly produced while the signal state remains bullish.

A new bullish event becomes possible after the engine has transitioned through the opposite qualified state, and vice versa.

This creates cleaner transition-based signal behavior.

────────────────────────────
VOLATILITY-ADAPTIVE TREND RIBBON
────────────────────────────

The trend ribbon provides a visual representation of directional state and adaptive market conditions.

Its base width is calculated using ATR.

The final ribbon width also incorporates the current Trend Strength Score.

As calculated trend strength increases, the ribbon can expand according to the user-defined Trend Strength Width Effect.

During bullish states, the ribbon is positioned below the Gaussian baseline.

During bearish states, the ribbon is positioned above the Gaussian baseline.

The ribbon consists of multiple visual layers, creating a clear distinction between the Gaussian baseline and the outer volatility-adjusted trend zone.

This makes direction and changes in trend intensity easier to interpret directly from the chart.

────────────────────────────
VISUAL INTERPRETATION
────────────────────────────

GREEN GAUSSIAN / GREEN RIBBON

The Gaussian baseline is rising and the engine is operating in a bullish directional regime.

RED GAUSSIAN / RED RIBBON

The Gaussian baseline is falling and the engine is operating in a bearish directional regime.

BUY / SELL

A new directional setup has passed the minimum qualification requirements.

STRONG BUY / STRONG SELL

A qualified transition has reached the configured Strong Trend Strength threshold.

EXTREME BUY / EXTREME SELL

A qualified transition has reached the configured Extreme Trend Strength threshold.

────────────────────────────
USER CONTROLS
────────────────────────────

Gaussian Engine:

• Source
• Gaussian Period
• Gaussian Poles

Momentum Confirmation:

• Enable / Disable Momentum Confirmation
• RSI Period
• ROC Period
• RSI Neutral Zone

Trend Strength:

• ATR Period
• Gaussian Slope Sensitivity
• Price Distance Sensitivity
• Minimum Signal Strength
• Strong Signal Threshold
• Extreme Signal Threshold

Adaptive Trend Ribbon:

• Show / Hide Adaptive Trend Ribbon
• Ribbon ATR Width
• Trend Strength Width Effect

Visual Settings:

• Show Trading Signals
• Color Price Bars
• Show Gaussian Trend Line

────────────────────────────
ALERTS
────────────────────────────

Six dedicated TradingView alert conditions are included:

• TRADION BUY
• TRADION STRONG BUY
• TRADION EXTREME BUY
• TRADION SELL
• TRADION STRONG SELL
• TRADION EXTREME SELL

This allows each signal classification to be monitored independently.

────────────────────────────
PRACTICAL USE
────────────────────────────

TRADION Gaussian Trend Engine can be used as:

• A directional trend filter
• A trend-strength visualization tool
• A momentum-confirmed transition detector
• A volatility-adaptive trend framework
• A confirmation layer for discretionary analysis
• An alert-based trend monitoring system

Because sensitivity depends on the selected parameters, instrument and timeframe, users should evaluate settings according to their own methodology.

Higher sensitivity may detect directional changes earlier but can increase exposure to market noise.

Greater smoothing and higher qualification thresholds can reduce signal frequency but may identify transitions later.

────────────────────────────
DESIGN PHILOSOPHY
────────────────────────────

The central idea behind TRADION Gaussian Trend Engine is that trend direction alone provides incomplete information.

A rising filter does not necessarily represent a strong trend.

For this reason, the engine evaluates four questions:

1. What direction is the Gaussian structure moving?
2. How significant is that movement relative to volatility?
3. Is price positioned consistently with that direction?
4. Does momentum support the directional structure?

The Trend Strength model then measures the degree of alignment between these components.

This creates a unified framework for analyzing direction, momentum, volatility and trend intensity rather than treating each component as an isolated indicator.

────────────────────────────
IMPORTANT NOTES
────────────────────────────

TRADION Gaussian Trend Engine is an analytical indicator, not a strategy and not a prediction system.

BUY, STRONG BUY, EXTREME BUY, SELL, STRONG SELL and EXTREME SELL labels represent mathematical classifications produced by the indicator's current conditions.

They do not guarantee future price direction, profitability or trade outcomes.

Signals are confirmed at bar close, but confirmed-bar processing does not eliminate normal market risk or signal lag.

Users should independently evaluate the indicator and apply appropriate risk management.

For research and educational purposes.

---

## Source Code

````pine
//@version=6
indicator("TRADION Gaussian Trend Engine", shorttitle="TRADION GTE", overlay=true)

//====================================================================
// TRADION GAUSSIAN TREND ENGINE
// Gaussian Cascade + Adaptive Ribbon + Trend Strength
// Momentum Confirmation + Confirmed-Bar Signal Architecture
//====================================================================

//--------------------------------------------------------------------
// COLORS
//--------------------------------------------------------------------

bullColor = #00E676
bullStrongColor = #00C853
bullExtremeColor = #00FF88

bearColor = #FF1744
bearStrongColor = #D50000
bearExtremeColor = #FF003C

neutralColor = #9E9E9E

//--------------------------------------------------------------------
// FUNCTIONS
//--------------------------------------------------------------------

f_clamp(float value, float minValue, float maxValue)=>
    math.max(minValue, math.min(maxValue, value))

//--------------------------------------------------------------------
// 01 - GAUSSIAN ENGINE
//--------------------------------------------------------------------

src = input.source(close, "Source", group="01 - Gaussian Engine")

gaussPeriod = input.int(25, "Gaussian Period", minval=2, maxval=300, group="01 - Gaussian Engine")

gaussPoles = input.int(4, "Gaussian Poles", minval=1, maxval=6, group="01 - Gaussian Engine")

//--------------------------------------------------------------------
// 02 - MOMENTUM CONFIRMATION
//--------------------------------------------------------------------

useMomentum = input.bool(true, "Enable Momentum Confirmation", group="02 - Momentum Confirmation")

rsiLen = input.int(14, "RSI Period", minval=2, group="02 - Momentum Confirmation")

rocLen = input.int(9, "ROC Period", minval=1, group="02 - Momentum Confirmation")

rsiBuffer = input.float(2.0, "RSI Neutral Zone", minval=0.0, maxval=20.0, step=0.5, group="02 - Momentum Confirmation")

//--------------------------------------------------------------------
// 03 - TREND STRENGTH
//--------------------------------------------------------------------

atrLen = input.int(14, "ATR Period", minval=1, group="03 - Trend Strength")

slopeTarget = input.float(0.20, "Gaussian Slope Sensitivity", minval=0.05, step=0.05, group="03 - Trend Strength")

distanceTarget = input.float(1.50, "Price Distance Sensitivity", minval=0.10, step=0.10, group="03 - Trend Strength")

minSignalStrength = input.float(25.0, "Minimum Signal Strength", minval=0.0, maxval=100.0, step=1.0, group="03 - Trend Strength")

strongThreshold = input.float(55.0, "Strong Signal Threshold", minval=1.0, maxval=100.0, step=1.0, group="03 - Trend Strength")

extremeThreshold = input.float(75.0, "Extreme Signal Threshold", minval=1.0, maxval=100.0, step=1.0, group="03 - Trend Strength")

//--------------------------------------------------------------------
// 04 - ADAPTIVE TREND RIBBON
//--------------------------------------------------------------------

showRibbon = input.bool(true, "Show Adaptive Trend Ribbon", group="04 - Adaptive Trend Ribbon")

ribbonATRMult = input.float(0.80, "Ribbon ATR Width", minval=0.10, maxval=5.0, step=0.05, group="04 - Adaptive Trend Ribbon")

ribbonStrengthEffect = input.float(0.50, "Trend Strength Width Effect", minval=0.0, maxval=1.5, step=0.05, group="04 - Adaptive Trend Ribbon")

//--------------------------------------------------------------------
// 05 - VISUAL SETTINGS
//--------------------------------------------------------------------

showSignals = input.bool(true, "Show Trading Signals", group="05 - Visual Settings")

colorBars = input.bool(true, "Color Price Bars", group="05 - Visual Settings")

showGaussian = input.bool(true, "Show Gaussian Trend Line", group="05 - Visual Settings")

//====================================================================
// GAUSSIAN ALPHA
//====================================================================

piValue = 3.141592653589793

beta = (1.0 - math.cos(2.0 * piValue / gaussPeriod)) / (math.pow(1.41421356237, 2.0 / gaussPoles) - 1.0)

alphaRaw = -beta + math.sqrt(beta * beta + 2.0 * beta)

alpha = f_clamp(alphaRaw, 0.001, 0.999)

//====================================================================
// MULTI-POLE GAUSSIAN CASCADE
//====================================================================

float pole1 = na
float pole2 = na
float pole3 = na
float pole4 = na
float pole5 = na
float pole6 = na

pole1 := alpha * src + (1.0 - alpha) * nz(pole1[1], src)

pole2 := alpha * pole1 + (1.0 - alpha) * nz(pole2[1], pole1)

pole3 := alpha * pole2 + (1.0 - alpha) * nz(pole3[1], pole2)

pole4 := alpha * pole3 + (1.0 - alpha) * nz(pole4[1], pole3)

pole5 := alpha * pole4 + (1.0 - alpha) * nz(pole5[1], pole4)

pole6 := alpha * pole5 + (1.0 - alpha) * nz(pole6[1], pole5)

gaussian = gaussPoles == 1 ? pole1 : gaussPoles == 2 ? pole2 : gaussPoles == 3 ? pole3 : gaussPoles == 4 ? pole4 : gaussPoles == 5 ? pole5 : pole6

//====================================================================
// TREND DIRECTION ENGINE
//====================================================================

var int trendDirection = 0

trendDirection := gaussian > gaussian[1] ? 1 : gaussian < gaussian[1] ? -1 : nz(trendDirection[1], 0)

//====================================================================
// VOLATILITY ENGINE
//====================================================================

atrValue = ta.atr(atrLen)

safeATR = math.max(atrValue, syminfo.mintick)

//====================================================================
// MOMENTUM ENGINE
//====================================================================

rsiValue = ta.rsi(close, rsiLen)

rocValue = ta.roc(close, rocLen)

bullMomentum = rsiValue > 50.0 + rsiBuffer and rocValue > 0.0

bearMomentum = rsiValue < 50.0 - rsiBuffer and rocValue < 0.0

//====================================================================
// TREND STRENGTH ENGINE
//====================================================================

gaussianSlope = gaussian - gaussian[1]

normalizedSlope = math.abs(gaussianSlope) / safeATR

normalizedDistance = math.abs(close - gaussian) / safeATR

slopeScore = f_clamp(normalizedSlope / slopeTarget, 0.0, 1.0)

distanceScore = f_clamp(normalizedDistance / distanceTarget, 0.0, 1.0)

rsiScore = f_clamp(math.abs(rsiValue - 50.0) / 25.0, 0.0, 1.0)

rocScore = f_clamp(math.abs(rocValue) / 3.0, 0.0, 1.0)

trendStrengthRaw = 100.0 * (slopeScore * 0.40 + distanceScore * 0.20 + rsiScore * 0.25 + rocScore * 0.15)

trendStrength = f_clamp(trendStrengthRaw, 0.0, 100.0)

//====================================================================
// DIRECTIONAL QUALIFICATION
//====================================================================

bullPriceStructure = close > gaussian

bearPriceStructure = close < gaussian

bullMomentumOK = not useMomentum or bullMomentum

bearMomentumOK = not useMomentum or bearMomentum

bullSetup = trendDirection == 1 and bullPriceStructure and bullMomentumOK and trendStrength >= minSignalStrength

bearSetup = trendDirection == -1 and bearPriceStructure and bearMomentumOK and trendStrength >= minSignalStrength

//====================================================================
// CONFIRMED-BAR SIGNAL ENGINE
//====================================================================

var int signalState = 0

bool newLongSignal = false
bool newShortSignal = false

newLongSignal := barstate.isconfirmed and bullSetup and signalState != 1

newShortSignal := barstate.isconfirmed and bearSetup and signalState != -1

if barstate.isconfirmed
    if newLongSignal
        signalState := 1
    else if newShortSignal
        signalState := -1

//====================================================================
// SIGNAL CLASSIFICATION
//====================================================================

longExtreme = newLongSignal and trendStrength >= extremeThreshold

longStrong = newLongSignal and trendStrength >= strongThreshold and trendStrength < extremeThreshold

longNormal = newLongSignal and trendStrength < strongThreshold

shortExtreme = newShortSignal and trendStrength >= extremeThreshold

shortStrong = newShortSignal and trendStrength >= strongThreshold and trendStrength < extremeThreshold

shortNormal = newShortSignal and trendStrength < strongThreshold

//====================================================================
// ADAPTIVE RIBBON WIDTH ENGINE
//====================================================================

strengthFactor = 1.0 + (trendStrength / 100.0) * ribbonStrengthEffect

ribbonWidth = safeATR * ribbonATRMult * strengthFactor

//====================================================================
// BULLISH TREND RIBBON
//====================================================================

bullRibbon1 = trendDirection == 1 ? gaussian - ribbonWidth * 0.25 : na

bullRibbon2 = trendDirection == 1 ? gaussian - ribbonWidth * 0.50 : na

bullRibbon3 = trendDirection == 1 ? gaussian - ribbonWidth * 0.75 : na

bullRibbon4 = trendDirection == 1 ? gaussian - ribbonWidth : na

//====================================================================
// BEARISH TREND RIBBON
//====================================================================

bearRibbon1 = trendDirection == -1 ? gaussian + ribbonWidth * 0.25 : na

bearRibbon2 = trendDirection == -1 ? gaussian + ribbonWidth * 0.50 : na

bearRibbon3 = trendDirection == -1 ? gaussian + ribbonWidth * 0.75 : na

bearRibbon4 = trendDirection == -1 ? gaussian + ribbonWidth : na

//====================================================================
// DYNAMIC COLORS
//====================================================================

gaussianColor = trendDirection == 1 ? bullColor : trendDirection == -1 ? bearColor : neutralColor

barTrendColor = trendDirection == 1 ? bullColor : trendDirection == -1 ? bearColor : na

//====================================================================
// MAIN GAUSSIAN TREND LINE
//====================================================================

mainPlot = plot(showGaussian ? gaussian : na, title="Gaussian Trend Line", color=gaussianColor, linewidth=3)

//====================================================================
// BULLISH RIBBON LAYERS
//====================================================================

bullPlot1 = plot(showRibbon ? bullRibbon1 : na, title="Bullish Ribbon Layer 1", color=color.new(bullColor, 100))

bullPlot2 = plot(showRibbon ? bullRibbon2 : na, title="Bullish Ribbon Layer 2", color=color.new(bullColor, 100))

bullPlot3 = plot(showRibbon ? bullRibbon3 : na, title="Bullish Ribbon Layer 3", color=color.new(bullColor, 100))

bullPlot4 = plot(showRibbon ? bullRibbon4 : na, title="Bullish Ribbon Outer Edge", color=color.new(bullColor, 15), linewidth=2)

//====================================================================
// BEARISH RIBBON LAYERS
//====================================================================

bearPlot1 = plot(showRibbon ? bearRibbon1 : na, title="Bearish Ribbon Layer 1", color=color.new(bearColor, 100))

bearPlot2 = plot(showRibbon ? bearRibbon2 : na, title="Bearish Ribbon Layer 2", color=color.new(bearColor, 100))

bearPlot3 = plot(showRibbon ? bearRibbon3 : na, title="Bearish Ribbon Layer 3", color=color.new(bearColor, 100))

bearPlot4 = plot(showRibbon ? bearRibbon4 : na, title="Bearish Ribbon Outer Edge", color=color.new(bearColor, 15), linewidth=2)

//====================================================================
// BULLISH RIBBON FILLS
//====================================================================

fill(mainPlot, bullPlot1, color=showRibbon and trendDirection == 1 ? color.new(bullExtremeColor, 84) : na, title="Bullish Ribbon Inner Zone")

fill(bullPlot1, bullPlot2, color=showRibbon and trendDirection == 1 ? color.new(bullColor, 78) : na, title="Bullish Ribbon Middle Zone 1")

fill(bullPlot2, bullPlot3, color=showRibbon and trendDirection == 1 ? color.new(bullStrongColor, 72) : na, title="Bullish Ribbon Middle Zone 2")

fill(bullPlot3, bullPlot4, color=showRibbon and trendDirection == 1 ? color.new(bullStrongColor, 64) : na, title="Bullish Ribbon Outer Zone")

//====================================================================
// BEARISH RIBBON FILLS
//====================================================================

fill(mainPlot, bearPlot1, color=showRibbon and trendDirection == -1 ? color.new(bearExtremeColor, 84) : na, title="Bearish Ribbon Inner Zone")

fill(bearPlot1, bearPlot2, color=showRibbon and trendDirection == -1 ? color.new(bearColor, 78) : na, title="Bearish Ribbon Middle Zone 1")

fill(bearPlot2, bearPlot3, color=showRibbon and trendDirection == -1 ? color.new(bearStrongColor, 72) : na, title="Bearish Ribbon Middle Zone 2")

fill(bearPlot3, bearPlot4, color=showRibbon and trendDirection == -1 ? color.new(bearStrongColor, 64) : na, title="Bearish Ribbon Outer Zone")

//====================================================================
// PRICE BAR COLORING
//====================================================================

barcolor(colorBars ? barTrendColor : na)

//====================================================================
// STANDARD BUY / SELL SIGNALS
//====================================================================

plotshape(showSignals and longNormal, title="TRADION BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=bullColor, textcolor=color.black, size=size.tiny)

plotshape(showSignals and shortNormal, title="TRADION SELL", text="SELL", style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=color.white, size=size.tiny)

//====================================================================
// STRONG BUY / SELL SIGNALS
//====================================================================

plotshape(showSignals and longStrong, title="TRADION STRONG BUY", text="STRONG BUY", style=shape.labelup, location=location.belowbar, color=bullStrongColor, textcolor=color.white, size=size.small)

plotshape(showSignals and shortStrong, title="TRADION STRONG SELL", text="STRONG SELL", style=shape.labeldown, location=location.abovebar, color=bearStrongColor, textcolor=color.white, size=size.small)

//====================================================================
// EXTREME BUY / SELL SIGNALS
//====================================================================

plotshape(showSignals and longExtreme, title="TRADION EXTREME BUY", text="EXTREME BUY", style=shape.labelup, location=location.belowbar, color=bullExtremeColor, textcolor=color.black, size=size.normal)

plotshape(showSignals and shortExtreme, title="TRADION EXTREME SELL", text="EXTREME SELL", style=shape.labeldown, location=location.abovebar, color=bearExtremeColor, textcolor=color.white, size=size.normal)

//====================================================================
// DATA WINDOW METRICS
//====================================================================

plot(trendStrength, title="Trend Strength Score", color=color.new(color.white, 100), display=display.data_window)

plot(rsiValue, title="Momentum RSI", color=color.new(color.white, 100), display=display.data_window)

plot(rocValue, title="Momentum ROC", color=color.new(color.white, 100), display=display.data_window)

//====================================================================
// ALERT CONDITIONS
//====================================================================

alertcondition(longNormal, title="TRADION BUY", message="TRADION Gaussian Trend Engine | BUY | Symbol: {{ticker}} | Price: {{close}}")

alertcondition(longStrong, title="TRADION STRONG BUY", message="TRADION Gaussian Trend Engine | STRONG BUY | Symbol: {{ticker}} | Price: {{close}}")

alertcondition(longExtreme, title="TRADION EXTREME BUY", message="TRADION Gaussian Trend Engine | EXTREME BUY | Symbol: {{ticker}} | Price: {{close}}")

alertcondition(shortNormal, title="TRADION SELL", message="TRADION Gaussian Trend Engine | SELL | Symbol: {{ticker}} | Price: {{close}}")

alertcondition(shortStrong, title="TRADION STRONG SELL", message="TRADION Gaussian Trend Engine | STRONG SELL | Symbol: {{ticker}} | Price: {{close}}")

alertcondition(shortExtreme, title="TRADION EXTREME SELL", message="TRADION Gaussian Trend Engine | EXTREME SELL | Symbol: {{ticker}} | Price: {{close}}")
````
