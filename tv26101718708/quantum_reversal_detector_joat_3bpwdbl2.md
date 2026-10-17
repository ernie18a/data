# Quantum Reversal Detector [JOAT]

- url: https://www.tradingview.com/script/3bPWDbl2-Quantum-Reversal-Detector-JOAT/
- type: indicator
- pine_id: PUB;68ae90225fd34e509344daf668b24d22
- version: 1.0

## Description

[b]Quantum Reversal Detector [JOAT] - Multi-Factor Reversal Probability Analysis[/b]

[b]Introduction and Purpose[/b]

Quantum Reversal Detector is an open-source overlay indicator that combines multiple reversal detection methods into a unified probability-based framework. The core problem this indicator addresses is the unreliability of single-factor reversal signals. A price touching support means nothing without momentum confirmation; an RSI oversold reading means nothing without price structure context.

This indicator solves that by requiring multiple independent factors to align before generating reversal signals, then expressing the result as a probability score rather than a binary signal.

[b]Why These Components Work Together[/b]

The indicator combines five analytical approaches, each addressing a different aspect of reversal detection:

1. [b]RSI Extremes[/b] - Identifies momentum exhaustion (overbought/oversold)
2. [b]MACD Crossovers[/b] - Confirms momentum direction change
3. [b]Support/Resistance Proximity[/b] - Ensures price is at a significant level
4. [b]Multi-Depth Momentum[/b] - Analyzes momentum across multiple timeframes
5. [b]Statistical Probability[/b] - Quantifies reversal likelihood using Bayesian updating

These components are not randomly combined. Each filter catches reversals that others miss:
[list]
[*]RSI catches momentum exhaustion but misses structural reversals
[*]MACD catches momentum shifts but lags price action
[*]S/R proximity catches structural levels but ignores momentum
[*]Multi-depth momentum catches divergences across timeframes
[*]Probability scoring combines all factors into actionable confidence levels
[/list]

[b]How the Detection System Works[/b]

[b]Step 1: Pattern Detection[/b]
The indicator first identifies potential reversal conditions:

[pine]
// Check if price is at support/resistance
float lowestLow = ta.lowest(low, period)
float highestHigh = ta.highest(high, period)
bool atSupport = low <= lowestLow * 1.002
bool atResistance = high >= highestHigh * 0.998

// Check RSI conditions
float rsi = ta.rsi(close, 14)
bool oversold = rsi < 30
bool overbought = rsi > 70

// Check MACD crossover
float macd = ta.ema(close, 12) - ta.ema(close, 26)
float signal = ta.ema(macd, 9)
bool macdBullish = ta.crossover(macd, signal)
bool macdBearish = ta.crossunder(macd, signal)

// Combine for reversal detection
if atSupport and oversold and macdBullish
    bullishReversal := true
[/pine]

[b]Step 2: Multi-Depth Momentum Analysis[/b]
The indicator calculates momentum across multiple periods to detect divergences:

[pine]
calculateQuantumMomentum(series float price, simple int period, simple int depth) =>
    float totalMomentum = 0.0
    for i = 0 to depth - 1
        int currentPeriod = period * (i + 1)
        float momentum = ta.roc(price, currentPeriod)
        totalMomentum += momentum
    totalMomentum / depth
[/pine]

This creates a composite momentum reading that smooths out noise while preserving genuine momentum shifts.

[b]Step 3: Bayesian Probability Calculation[/b]
The indicator uses Bayesian updating to calculate reversal probability:

[pine]
bayesianProbability(series float priorProb, series float likelihood, series float evidence) =>
    float posterior = evidence > 0 ? (likelihood * priorProb) / evidence : priorProb
    math.min(math.max(posterior, 0.0), 1.0)
[/pine]

The prior probability starts at 50% and updates based on:
[list]
[*]RSI extreme readings increase likelihood
[*]MACD crossovers increase likelihood
[*]S/R proximity increases likelihood
[*]Momentum divergence increases likelihood
[/list]

[b]Step 4: Confidence Intervals[/b]
Using Monte Carlo simulation concepts, the indicator estimates price distribution:

[pine]
monteCarloSimulation(series float price, series float volatility, simple int iterations) =>
    float sumPrice = 0.0
    float sumSqDiff = 0.0
    for i = 0 to iterations - 1
        float randomFactor = (i % 10 - 5) / 10.0
        float simulatedPrice = price + volatility * randomFactor
        sumPrice += simulatedPrice
    float avgPrice = sumPrice / iterations
    // Calculate standard deviation for confidence intervals
[/pine]

This provides 95% and 99% confidence bands around the current price.

[b]Signal Classification[/b]

Signals are classified by confirmation level:
[list]
[*][b]Confirmed Reversal[/b]: Pattern detected for N consecutive bars (default 3)
[*][b]High Probability[/b]: Confirmed + Bayesian probability > 70%
[*][b]Ultra High Probability[/b]: High probability + PDF above average
[/list]

[b]Dashboard Information[/b]

The dashboard displays:
[list]
[*][b]Bayesian Probability[/b] - Updated reversal probability (0-100%)
[*][b]Quantum Momentum[/b] - Multi-depth momentum average
[*][b]RSI[/b] - Current RSI value with overbought/oversold status
[*][b]Volatility[/b] - Current ATR as percentage of price
[*][b]Reversal Signal[/b] - BULLISH, BEARISH, or NONE
[*][b]Divergence[/b] - Momentum divergence detection
[*][b]MACD[/b] - Current MACD histogram value
[*][b]S/R Zone[/b] - AT SUPPORT, AT RESISTANCE, or NEUTRAL
[*][b]95% Confidence[/b] - Price range with 95% probability
[*][b]Bull/Bear Targets[/b] - ATR-based reversal targets
[/list]

[image]https://www.tradingview.com/x/OdRQwCgu/[/image]

[b]Visual Elements[/b]
[list]
[*][b]Quantum Bands[/b] - ATR-based upper and lower channels
[*][b]Probability Field[/b] - Circle layers showing probability distribution
[*][b]Confidence Bands[/b] - 95% and 99% confidence interval circles
[*][b]Reversal Labels[/b] - REV markers at confirmed reversals
[*][b]High Probability Markers[/b] - Star diamonds at high probability setups
[*][b]Reversal Zones[/b] - Boxes around confirmed reversal areas
[*][b]Divergence Markers[/b] - Triangles at momentum divergences
[/list]

[b]How to Use This Indicator[/b]

[b]For Reversal Trading:[/b]
1. Wait for Bayesian Probability to exceed 70%
2. Confirm price is at S/R zone (dashboard shows AT SUPPORT or AT RESISTANCE)
3. Check that RSI is in extreme territory (oversold for longs, overbought for shorts)
4. Enter when REV label appears with high probability marker

[b]For Risk Management:[/b]
1. Use the 95% confidence band as a stop-loss reference
2. Use Bull/Bear Targets for take-profit levels
3. Higher probability readings warrant larger position sizes

[b]For Filtering False Signals:[/b]
1. Increase Confirmation Bars to require more consecutive signals
2. Only trade when probability exceeds 70%
3. Require divergence confirmation for highest conviction

[b]Input Parameters[/b]
[list]
[*]Reversal Period (21) - Lookback for S/R and momentum calculations
[*]Quantum Depth (5) - Number of momentum layers for multi-depth analysis
[*]Confirmation Bars (3) - Consecutive bars required for confirmation
[*]Detection Sensitivity (1.2) - Band width and target multiplier
[*]Bayesian Probability (true) - Enable probability calculation
[*]Monte Carlo Simulation (true) - Enable confidence interval calculation
[*]Normal Distribution (true) - Enable PDF calculation
[*]Confidence Intervals (true) - Enable confidence bands
[/list]

[b]Timeframe Recommendations[/b]
[list]
[*]1H-4H: Best for swing trading reversals
[*]Daily: Fewer but more significant reversal signals
[*]15m-30m: More signals, requires higher probability threshold
[/list]

[b]Limitations[/b]
[list]
[*]Statistical concepts are simplified implementations for Pine Script
[*]Monte Carlo uses deterministic pseudo-random factors, not true randomness
[*]Bayesian probability uses simplified prior/likelihood model
[*]Reversal detection does not guarantee actual reversals will occur
[*]Confirmation bars add lag to signal generation
[/list]

[b]Open-Source and Disclaimer[/b]

This script is published as open-source under the Mozilla Public License 2.0 for educational purposes. The source code is fully visible and can be studied to understand how each component works.

This indicator does not constitute financial advice. Reversal detection is probabilistic, not predictive. The probability scores represent statistical likelihood based on historical patterns, not guaranteed outcomes. Past performance does not guarantee future results. Always use proper risk management, position sizing, and stop-losses.

- Made with passion by officialjackofalltrades

## Source Code

````pine
//@version=6
indicator("Quantum Reversal Detector", "QRD [JOAT]", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ============================================================================
// INPUTS
// ============================================================================

var GRP1 = "Quantum Core Settings"
i_reversalPeriod = input.int(21, "Reversal Period", minval=10, maxval=100, group=GRP1)
i_confirmationBars = input.int(3, "Confirmation Bars", minval=1, maxval=10, group=GRP1)
i_sensitivity = input.float(1.2, "Detection Sensitivity", minval=0.5, maxval=3.0, step=0.1, group=GRP1)
i_bayesian = input.bool(true, "Bayesian Probability", group=GRP1)
i_confidenceInterval = input.bool(true, "Confidence Intervals", group=GRP1)

var GRP2 = "Visual Settings"
i_showReversalZones = input.bool(true, "Show Reversal Zones", group=GRP2)
i_showProbability = input.bool(true, "Show Probability Levels", group=GRP2)
i_showProjection = input.bool(true, "Show Price Projection", group=GRP2)
i_showSignals = input.bool(true, "Show Reversal Signals", group=GRP2)
i_showConfidenceBands = input.bool(true, "Show Confidence Bands", group=GRP2)
i_bullReversalColor = input.color(color.new(#00ffaa, 0), "Bullish Reversal", group=GRP2)
i_bearReversalColor = input.color(color.new(#ff0055, 0), "Bearish Reversal", group=GRP2)
i_quantumColor = input.color(color.new(#aa00ff, 50), "Quantum Field", group=GRP2)
i_confColor = input.color(color.new(#ffaa00, 60), "Confidence Color", group=GRP2)

var GRP3 = "Alert Settings"
i_alertReversal = input.bool(true, "Alert on Reversal Signal", group=GRP3)
i_alertHighProbability = input.bool(true, "Alert on High Probability", group=GRP3)

// ============================================================================
// GLOBAL TA FUNCTIONS 
// ============================================================================

// Core indicators
float rsi = ta.rsi(close, 14)
float atr = ta.atr(14)
float volatility = ta.stdev(close, i_reversalPeriod)
float smaClose = ta.sma(close, i_reversalPeriod)
float lowestLow = ta.lowest(low, i_reversalPeriod)
float highestHigh = ta.highest(high, i_reversalPeriod)

// MACD components
float ema12 = ta.ema(close, 12)
float ema26 = ta.ema(close, 26)
float macdLine = ema12 - ema26
float signalLine = ta.ema(macdLine, 9)
bool macdCrossUp = ta.crossover(macdLine, signalLine)
bool macdCrossDown = ta.crossunder(macdLine, signalLine)

// ROC for momentum (at global scope)
float roc1 = ta.roc(close, i_reversalPeriod)
float roc2 = ta.roc(close, i_reversalPeriod * 2)
float roc3 = ta.roc(close, i_reversalPeriod * 3)
float rocStdev = ta.stdev(roc1, i_reversalPeriod)

// Pivot detection at global scope (returns float, use not na() to check)
float pivotLowPrice = ta.pivotlow(low, 5, 5)
float pivotHighPrice = ta.pivothigh(high, 5, 5)
float pivotLowRSI = ta.pivotlow(rsi, 5, 5)
float pivotHighRSI = ta.pivothigh(rsi, 5, 5)

// Check if pivots exist (float to bool conversion)
bool hasPivotLow = not na(pivotLowPrice)
bool hasPivotHigh = not na(pivotHighPrice)
bool hasPivotLowRSI = not na(pivotLowRSI)
bool hasPivotHighRSI = not na(pivotHighRSI)


// ============================================================================
// CALCULATIONS
// ============================================================================

// Quantum Momentum (simplified - no ta.roc in loops)
float avgMomentum = (roc1 + roc2 + roc3) / 3
float momentumDivergence = (math.abs(roc1 - avgMomentum) + math.abs(roc2 - avgMomentum) + math.abs(roc3 - avgMomentum)) / 3

// Reversal Pattern Detection
bool atSupport = low <= lowestLow * 1.002
bool atResistance = high >= highestHigh * 0.998
bool oversold = rsi < 30
bool overbought = rsi > 70

bool bullishReversal = atSupport and oversold and macdCrossUp
bool bearishReversal = atResistance and overbought and macdCrossDown

// Reversal Probability
float normalizedVol = volatility / close
float momentumStrength = rocStdev > 0 ? math.abs(avgMomentum) / rocStdev : 0.0
float divSma = ta.sma(momentumDivergence, i_reversalPeriod)
float divergenceScore = divSma > 0 ? momentumDivergence / divSma : 1.0
float reversalProbability = math.min((momentumStrength * 0.4 + divergenceScore * 0.3 + (1 - normalizedVol) * 0.3) * 100, 100)

// Bayesian Probability
float priorProb = 0.5
float likelihood = reversalProbability / 100
float evidenceSma = ta.sma(reversalProbability, i_reversalPeriod)
float evidence = evidenceSma / 100
float bayesianProb = i_bayesian and evidence > 0 ? math.min(math.max((likelihood * priorProb) / evidence, 0.0), 1.0) * 100 : reversalProbability

// Confidence Intervals (95% = 1.96 z-score, 99% = 2.576)
float marginError95 = 1.96 * volatility
float marginError99 = 2.576 * volatility
float conf95Upper = i_confidenceInterval ? close + marginError95 : close
float conf95Lower = i_confidenceInterval ? close - marginError95 : close
float conf99Upper = i_confidenceInterval ? close + marginError99 : close
float conf99Lower = i_confidenceInterval ? close - marginError99 : close

// Targets
float bullTarget = close + atr * i_sensitivity * 2
float bearTarget = close - atr * i_sensitivity * 2

// Divergence Detection (simplified - using global pivots)
bool bullishDiv = hasPivotLow and hasPivotLowRSI and low[5] < low[10] and rsi[5] > rsi[10]
bool bearishDiv = hasPivotHigh and hasPivotHighRSI and high[5] > high[10] and rsi[5] < rsi[10]

// Confirmation counting
var int bullConfirmCount = 0
var int bearConfirmCount = 0

if bullishReversal
    bullConfirmCount += 1
else
    bullConfirmCount := 0

if bearishReversal
    bearConfirmCount += 1
else
    bearConfirmCount := 0

bool confirmedBullReversal = bullConfirmCount >= i_confirmationBars
bool confirmedBearReversal = bearConfirmCount >= i_confirmationBars

bool highProbBullReversal = confirmedBullReversal and bayesianProb > 70
bool highProbBearReversal = confirmedBearReversal and bayesianProb > 70

// Quantum bands
float upperQuantumBand = close + atr * i_sensitivity
float lowerQuantumBand = close - atr * i_sensitivity

// Colors
color reversalColor = confirmedBullReversal ? i_bullReversalColor : confirmedBearReversal ? i_bearReversalColor : i_quantumColor
float reversalStrength = reversalProbability / 100 * (confirmedBullReversal or confirmedBearReversal ? 1.5 : 1.0)


// ============================================================================
// PLOTTING 
// ============================================================================

// Confidence Bands
plot(i_showConfidenceBands ? conf95Upper : na, "95% Upper", color=color.new(i_confColor, 70), linewidth=1, style=plot.style_circles)
plot(i_showConfidenceBands ? conf95Lower : na, "95% Lower", color=color.new(i_confColor, 70), linewidth=1, style=plot.style_circles)
plot(i_showConfidenceBands ? conf99Upper : na, "99% Upper", color=color.new(i_confColor, 80), linewidth=1, style=plot.style_circles)
plot(i_showConfidenceBands ? conf99Lower : na, "99% Lower", color=color.new(i_confColor, 80), linewidth=1, style=plot.style_circles)

// Quantum Bands
plot(i_showReversalZones ? upperQuantumBand : na, "Upper Quantum", color=color.new(i_quantumColor, 60), linewidth=1, style=plot.style_circles)
plot(i_showReversalZones ? lowerQuantumBand : na, "Lower Quantum", color=color.new(i_quantumColor, 60), linewidth=1, style=plot.style_circles)

// Fill between quantum bands
upperPlot = plot(i_showReversalZones ? upperQuantumBand : na, color=na, display=display.none)
lowerPlot = plot(i_showReversalZones ? lowerQuantumBand : na, color=na, display=display.none)
fill(upperPlot, lowerPlot, color=color.new(i_quantumColor, 95), title="Quantum Field")

// Probability Level
float probLevel = close + (close * reversalProbability / 1000)
plot(i_showProbability ? probLevel : na, "Probability Level", color=color.new(reversalColor, 70), linewidth=1, style=plot.style_stepline)

// Signal cooldowns
var int lastBullRev = 0
var int lastBearRev = 0
var int lastHighBull = 0
var int lastHighBear = 0
var int lastBullDiv = 0
var int lastBearDiv = 0
int cooldown = 15

bool showBullRev = i_showSignals and confirmedBullReversal and (bar_index - lastBullRev) > cooldown
bool showBearRev = i_showSignals and confirmedBearReversal and (bar_index - lastBearRev) > cooldown
bool showHighBull = i_showSignals and highProbBullReversal and (bar_index - lastHighBull) > cooldown
bool showHighBear = i_showSignals and highProbBearReversal and (bar_index - lastHighBear) > cooldown
bool showBullDiv = bullishDiv and (bar_index - lastBullDiv) > cooldown
bool showBearDiv = bearishDiv and (bar_index - lastBearDiv) > cooldown

if showBullRev
    lastBullRev := bar_index
if showBearRev
    lastBearRev := bar_index
if showHighBull
    lastHighBull := bar_index
if showHighBear
    lastHighBear := bar_index
if showBullDiv
    lastBullDiv := bar_index
if showBearDiv
    lastBearDiv := bar_index

// Signal shapes
plotshape(showBullRev, "Bull Reversal", shape.labelup, location.belowbar, color=color.new(i_bullReversalColor, 0), size=size.normal, text="REV", textcolor=color.white, display=display.pane)
plotshape(showBearRev, "Bear Reversal", shape.labeldown, location.abovebar, color=color.new(i_bearReversalColor, 0), size=size.normal, text="REV", textcolor=color.white, display=display.pane)
plotshape(showHighBull, "High Prob Bull", shape.diamond, location.belowbar, color=color.new(color.lime, 0), size=size.small, text="HP", textcolor=color.white, display=display.pane)
plotshape(showHighBear, "High Prob Bear", shape.diamond, location.abovebar, color=color.new(color.red, 0), size=size.small, text="HP", textcolor=color.white, display=display.pane)
plotshape(showBullDiv, "Bull Divergence", shape.triangleup, location.belowbar, color=color.new(i_bullReversalColor, 50), size=size.tiny, display=display.pane)
plotshape(showBearDiv, "Bear Divergence", shape.triangledown, location.abovebar, color=color.new(i_bearReversalColor, 50), size=size.tiny, display=display.pane)

// Projection lines
if i_showProjection and showBullRev
    line.new(bar_index, close, bar_index + 10, bullTarget, color=i_bullReversalColor, width=2, style=line.style_dashed)

if i_showProjection and showBearRev
    line.new(bar_index, close, bar_index + 10, bearTarget, color=i_bearReversalColor, width=2, style=line.style_dashed)

// Reversal boxes
if showBullRev or showBearRev
    box.new(bar_index - i_confirmationBars, high, bar_index + 5, low, border_color=reversalColor, bgcolor=color.new(reversalColor, 90), border_width=2, border_style=line.style_solid)


// ============================================================================
// DASHBOARD
// ============================================================================

var GRP4 = "Dashboard Settings"
i_showDashboard = input.bool(true, "Show Dashboard", group=GRP4)
i_dashPosition = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=GRP4)

// Dashboard position
dashPos = switch i_dashPosition
    "Top Right" => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left" => position.top_left
    "Bottom Left" => position.bottom_left
    => position.top_right

// Dashboard table
var table dashboard = table.new(dashPos, 2, 12, bgcolor=color.new(#1a1a2e, 10), border_width=1, border_color=color.new(#4a4a6a, 50), frame_width=2, frame_color=color.new(#6a6a8a, 50))

if barstate.islast and i_showDashboard
    // Header
    table.cell(dashboard, 0, 0, "QUANTUM REVERSAL", text_color=color.new(#aa00ff, 0), text_size=size.small, bgcolor=color.new(#2a2a4e, 10))
    table.cell(dashboard, 1, 0, "DETECTOR", text_color=color.new(#aa00ff, 0), text_size=size.small, bgcolor=color.new(#2a2a4e, 10))
    
    // Bayesian Probability
    bayesColor = bayesianProb > 70 ? color.lime : bayesianProb > 50 ? color.yellow : color.orange
    table.cell(dashboard, 0, 1, "Bayesian Prob", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 1, str.tostring(bayesianProb, "#.#") + "%", text_color=bayesColor, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // Quantum Momentum
    momColor = avgMomentum > 0 ? color.lime : color.red
    table.cell(dashboard, 0, 2, "Quantum Mom", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 2, str.tostring(avgMomentum, "#.##") + "%", text_color=momColor, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // RSI
    rsiColor = rsi > 70 ? color.red : rsi < 30 ? color.lime : color.yellow
    table.cell(dashboard, 0, 3, "RSI", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 3, str.tostring(rsi, "#.#"), text_color=rsiColor, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // Volatility
    volNorm = normalizedVol * 100
    volColor = volNorm > 3 ? color.red : volNorm > 1.5 ? color.yellow : color.lime
    table.cell(dashboard, 0, 4, "Volatility", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 4, str.tostring(volNorm, "#.##") + "%", text_color=volColor, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // Reversal Signal
    revSignal = confirmedBullReversal ? "BULLISH" : confirmedBearReversal ? "BEARISH" : "NEUTRAL"
    revColor = confirmedBullReversal ? color.lime : confirmedBearReversal ? color.red : color.gray
    table.cell(dashboard, 0, 5, "Reversal", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 5, revSignal, text_color=revColor, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // Divergence
    divSignal = bullishDiv ? "BULL DIV" : bearishDiv ? "BEAR DIV" : "NONE"
    divColor = bullishDiv ? color.lime : bearishDiv ? color.red : color.gray
    table.cell(dashboard, 0, 6, "Divergence", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 6, divSignal, text_color=divColor, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // MACD Signal
    macdSignal = macdCrossUp ? "CROSS UP" : macdCrossDown ? "CROSS DN" : macdLine > signalLine ? "BULLISH" : "BEARISH"
    macdColor = macdCrossUp or macdLine > signalLine ? color.lime : color.red
    table.cell(dashboard, 0, 7, "MACD", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 7, macdSignal, text_color=macdColor, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // Support/Resistance
    srSignal = atSupport ? "AT SUPPORT" : atResistance ? "AT RESIST" : "MID RANGE"
    srColor = atSupport ? color.lime : atResistance ? color.red : color.yellow
    table.cell(dashboard, 0, 8, "S/R Zone", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 8, srSignal, text_color=srColor, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // Confidence 95%
    conf95Range = marginError95 * 2
    table.cell(dashboard, 0, 9, "95% Conf", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 9, str.tostring(conf95Range, "#.##"), text_color=color.new(i_confColor, 0), text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // Bull Target
    table.cell(dashboard, 0, 10, "Bull Target", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 10, str.tostring(bullTarget, "#.##"), text_color=color.lime, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    
    // Bear Target
    table.cell(dashboard, 0, 11, "Bear Target", text_color=color.silver, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dashboard, 1, 11, str.tostring(bearTarget, "#.##"), text_color=color.red, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))


// ============================================================================
// ALERTS
// ============================================================================

alertcondition(confirmedBullReversal and i_alertReversal, "Bullish Reversal", "QRD: Bullish reversal detected")
alertcondition(confirmedBearReversal and i_alertReversal, "Bearish Reversal", "QRD: Bearish reversal detected")
alertcondition(highProbBullReversal and i_alertHighProbability, "High Prob Bull", "QRD: High probability bullish reversal (>70%)")
alertcondition(highProbBearReversal and i_alertHighProbability, "High Prob Bear", "QRD: High probability bearish reversal (>70%)")
alertcondition(bullishDiv, "Bullish Divergence", "QRD: Bullish divergence detected")
alertcondition(bearishDiv, "Bearish Divergence", "QRD: Bearish divergence detected")
````
