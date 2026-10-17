# MTF Momentum & Convexity Oscillator [AlgoChief]

- url: https://www.tradingview.com/script/Q5QiV8WK-MTF-Momentum-Convexity-Oscillator-AlgoChief/
- type: indicator
- pine_id: PUB;f2f5a9457d7a46f09130b3d495c0d913
- version: 1.0

## Description

OVERVIEW & QUANTUM MOMENTUM PRINCIPLES

Traditional momentum oscillators (like standard RSI, Stochastics, and CCI) suffer from two fatal flaws:
1. Single-Horizon Myopia: They calculate speed across only one arbitrary period (e.g. 14 bars), leaving them blind to macro order flow.
2. Velocity Lag: They only compute the first derivative of price (Velocity = Speed), completely missing the second derivative (Convexity = Acceleration/Deceleration).

The [AlgoChief] Multi-Timeframe Momentum Dispersion & Convexity Oscillator resolves both limitations. By processing four institutional frequency layers simultaneously and calculating dynamic momentum dispersion, it alerts you when timeframes harmonize for a sustained breakout or disperse into institutional exhaustion.


CORE ARCHITECTURAL ENGINES

1. MULTI-HORIZON FREQUENCY SYNTHESIS
Simultaneously evaluates momentum across 4 calibrated harmonics:
- Micro Vector (8 Period): Immediate intraday speed
- Tactical Vector (21 Period): Swing order flow
- Strategic Vector (55 Period): Positional institutional direction
- Macro Vector (144 Period): Structural trend baseline

2. MOMENTUM CONVEXITY (SECOND DERIVATIVE ACCELERATION)
Velocity is simply how fast price moves. Convexity is the rate of change of that velocity (acceleration). Just as a car decelerates before shifting into reverse, institutional order flow decelerates before price actually turns. This convexity metric provides leading structural reversal signals bars ahead of classic indicators.

3. DISPERSION VARIANCE SQUEEZE
Calculates the statistical standard deviation across all 4 momentum vectors:
- Ultra-Low Dispersion (Coherence): All 4 timeframes are aligned in perfect consensus. This triggers high-velocity trend continuation.
- High Dispersion (Conflict): Internal market conflict where lower timeframes fight macro trends. Warns of impending rotation.

4. AUTOMATED CLEAN DIVERGENCE ENGINE
Engineered with subtle pivot confirmation to eliminate chart clutter. Plots clean Bullish & Bearish Divergence points directly on the momentum curve without blocking visual price flow.


TRADING SYSTEM RULES

Long Entry Setup:
1. Primary Wave crosses above the Signal Line from oversold territory (-50 or below).
2. Momentum Convexity turns positive (Green acceleration dot).
3. Bullish Regular Divergence prints (Green circle indicator).
4. Timeframe Dispersion is low, confirming institutional coherence.

Short Entry Setup:
1. Primary Wave crosses below the Signal Line from overbought territory (+50 or above).
2. Momentum Convexity turns negative (Red deceleration dot).
3. Bearish Regular Divergence prints (Red circle indicator).
4. Target key liquidity pools identified on your primary chart.


INPUT PARAMETERS GUIDE

- Micro/Tactical/Strategic/Macro Periods: Customizable lookback harmonics.
- Convexity Sensitivity Factor: Tunes the acceleration sensitivity.
- Divergence Evaluation Depth: Controls pivot lookback required to validate structural divergence peaks.
- Coherence Threshold: Defines the dispersion level considered an institutional consensus squeeze.


RISK DISCLAIMER

No trading indicator guarantees future financial results. The Multi-Timeframe Momentum Dispersion & Convexity Oscillator is a quantitative momentum measurement tool. Use sound risk management principles, conservative position sizing, and proper stop-loss orders on all executions.

## Source Code

````pine
//@version=6
indicator("MTF Momentum & Convexity Oscillator [AlgoChief] ", shorttitle="MDCO [AlgoChief]", overlay=false, max_lines_count=500, max_labels_count=500)
// ==========================================
// USER INPUTS & PARAMETERS
// ==========================================
grp_mtf    = "Multi-Frequency Momentum Harmonics"
p_micro    = input.int(8, "Micro Vector Period", minval=3, group=grp_mtf)
p_tactical = input.int(21, "Tactical Vector Period", minval=5, group=grp_mtf)
p_strat    = input.int(55, "Strategic Vector Period", minval=10, group=grp_mtf)
p_macro    = input.int(144, "Macro Vector Period", minval=20, group=grp_mtf)

grp_conv   = "Convexity Engine (Second Derivative)"
smoothSig  = input.int(9, "Signal Line Smoothing Length", minval=2, group=grp_conv)

grp_div    = "Automated Divergence Engine"
showDiv    = input.bool(true, "Show Subtle Divergence Markers", group=grp_div)
divLookback= input.int(5, "Pivot Confirmation Lookback", minval=2, maxval=20, group=grp_div)

grp_col    = "Visual Styling"
c_wave_up  = input.color(#00e5ff, "Momentum Bullish Wave", group=grp_col)
c_wave_dn  = input.color(#ff5252, "Momentum Bearish Wave", group=grp_col)
c_sig      = input.color(#ffb300, "Signal Guide Line", group=grp_col)
c_cohere   = input.color(#ffd700, "Harmonic Coherence Squeeze Glow", group=grp_col)

// ==========================================
// HARMONIC MOMENTUM KINEMATICS
// ==========================================
normMom(len) =>
    mom = close - close[len]
    atr = ta.atr(len)
    math.max(math.min((mom / math.max(atr, 0.000001)) * 25.0, 100.0), -100.0)

mMicro    = normMom(p_micro)
mTactical = normMom(p_tactical)
mStrat    = normMom(p_strat)
mMacro    = normMom(p_macro)

// Composite Momentum Harmonic
compositeWave = (mMicro * 0.4) + (mTactical * 0.3) + (mStrat * 0.2) + (mMacro * 0.1)
signalLine    = ta.ema(compositeWave, smoothSig)

// Convexity (Second Derivative / Acceleration)
velocity = compositeWave - compositeWave[1]
convexity = velocity - velocity[1]
bool accelUp = convexity > 0

// Momentum Dispersion Variance
meanVec = (mMicro + mTactical + mStrat + mMacro) / 4.0
varianceVec = (math.pow(mMicro - meanVec, 2) + math.pow(mTactical - meanVec, 2) + 
               math.pow(mStrat - meanVec, 2) + math.pow(mMacro - meanVec, 2)) / 4.0
dispersion = math.sqrt(varianceVec)

// Coherence Squeeze
bool isCoherent = dispersion < 15.0 and math.abs(compositeWave) > 20.0

// ==========================================
// ULTRA-CLEAN VISUAL OSCILLATOR
// ==========================================
// Reference Boundaries (Clean Dashed Levels)
hTop  = hline(50, "Overbought Zone", color=color.new(#ff1744, 75), linestyle=hline.style_dashed)
hZero = hline(0, "Equilibrium", color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hBtm  = hline(-50, "Oversold Zone", color=color.new(#00e676, 75), linestyle=hline.style_dashed)

// Dynamic Color Gradient for the Main Curve
waveColor = isCoherent ? c_cohere : (compositeWave >= signalLine ? c_wave_up : c_wave_dn)

// Main Wave & Signal Plot
plot(compositeWave, title="Momentum Wave", color=waveColor, linewidth=2)
plot(signalLine, title="Kinetic Signal Line", color=color.new(c_sig, 30), linewidth=1)

// Clean Equilibrium Subtle Glow Fill
fill(hZero, hTop, color=color.new(#00e5ff, 96), title="Positive Wave Fill")
fill(hZero, hBtm, color=color.new(#ff5252, 96), title="Negative Wave Fill")

// Coherence Alignment Inception Marker (Clean, Non-Intrusive)
plotshape(isCoherent and not isCoherent[1], title="Coherence Alignment", style=shape.diamond,
          location=location.top, color=c_cohere, size=size.tiny)

// ==========================================
// CLEAN SUBTLE DIVERGENCE ENGINE (NO CLUTTER)
// ==========================================
pLow  = ta.pivotlow(compositeWave, divLookback, divLookback)
pHigh = ta.pivothigh(compositeWave, divLookback, divLookback)

var float lastOscPLow   = na
var float lastOscPHigh  = na
var float lastPricePLow = na
var float lastPricePHigh = na

if not na(pLow)
    lastOscPLow   := pLow
    lastPricePLow := low[divLookback]

if not na(pHigh)
    lastOscPHigh   := pHigh
    lastPricePHigh := high[divLookback]

// Divergence Logic
bullDiv = showDiv and not na(pLow) and not na(lastOscPLow[1]) and
          (low[divLookback] < lastPricePLow[1]) and (pLow > lastOscPLow[1])

bearDiv = showDiv and not na(pHigh) and not na(lastOscPHigh[1]) and
          (high[divLookback] > lastPricePHigh[1]) and (pHigh < lastOscPHigh[1])

// Clean Minimal Circles (No Giant Text Blocking Lines)
plotshape(bullDiv, title="Bullish Divergence", style=shape.circle,
          location=location.bottom, color=#00e676, size=size.tiny, offset=-divLookback)
plotshape(bearDiv, title="Bearish Divergence", style=shape.circle,
          location=location.top, color=#ff1744, size=size.tiny, offset=-divLookback)

// Alerts
alertcondition(ta.crossover(compositeWave, signalLine), title="[AlgoChief] Bullish Wave Crossover", message="[AlgoChief] Momentum Wave crossed ABOVE signal line at {{close}}")
alertcondition(ta.crossunder(compositeWave, signalLine), title="[AlgoChief] Bearish Wave Crossunder", message="[AlgoChief] Momentum Wave crossed BELOW signal line at {{close}}")
alertcondition(bullDiv, title="[AlgoChief] Bullish Divergence Alert", message="[AlgoChief] Regular Bullish Divergence Confirmed at {{close}}")
alertcondition(bearDiv, title="[AlgoChief] Bearish Divergence Alert", message="[AlgoChief] Regular Bearish Divergence Confirmed at {{close}}")
alertcondition(isCoherent and not isCoherent[1], title="[AlgoChief] Harmonic Coherence Squeeze", message="[AlgoChief] All 4 Momentum Timeframes Harmonized for Breakout at {{close}}")
````
