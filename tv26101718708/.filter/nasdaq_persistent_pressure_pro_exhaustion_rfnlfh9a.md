# NASDAQ Persistent Pressure PRO  Exhaustion

- url: https://www.tradingview.com/script/rfNLFH9A/
- type: indicator
- pine_id: PUB;221dce5a43254b58a92c6f03cedc99de
- version: 1.0

## Description

A professional-grade momentum and pressure-flow oscillator specifically optimized for NASDAQ intraday trading, especially M1 scalping and fast momentum environments.

This indicator is designed to visualize:

Persistent buyer/seller pressure
Momentum continuation
Pressure exhaustion
Pullback quality
Trend acceleration
Higher timeframe confirmation
Early expansion behavior

Unlike traditional oscillators, this system focuses on flow persistence instead of simple momentum snapshots.

Core Concept

The indicator measures the relationship between:

candle positioning inside the range
relative buying vs selling pressure
volume-weighted directional intent
persistent pressure memory
acceleration and exhaustion shifts

The result is a dynamic pressure engine that behaves much closer to real NASDAQ intraday flow.

Main Components
1. Persistent Pressure Histogram

The histogram visualizes active buyer and seller dominance.

Green Histogram

Shows persistent buying pressure.

Bright green = increasing bullish pressure
Dark green = bullish pressure slowing down
Red Histogram

Shows persistent selling pressure.

Bright red = increasing bearish pressure
Dark red = bearish pressure weakening

This allows traders to instantly identify:

trend continuation
pullbacks
weakening momentum
pressure transitions
2. Relative Pressure Engine

Instead of using absolute volume alone, the indicator calculates:

relative buyer dominance
relative seller dominance
pressure normalized against volume

This makes the oscillator far more adaptive to:

NASDAQ volatility spikes
NY Open
Power Hour
liquidity sweeps
low-volume consolidations
3. Persistent Memory System

A custom decay engine stores previous pressure information.

This prevents the oscillator from reacting too randomly while still remaining fast enough for M1 scalping.

The pressure memory helps identify:

sustained trend flow
institutional continuation
fake reversals
pullback structure
4. x5 Higher Timeframe Confirmation

The smooth line represents higher timeframe pressure flow.

This acts as a directional filter for the lower timeframe histogram.

Typical interpretation:

Histogram pullback + HTF still bullish
→ continuation probability increases
Histogram weakens while HTF flips
→ possible trend transition

This feature is extremely useful for filtering false M1 signals.

5. Exhaustion Detection

The indicator includes a pressure acceleration engine that detects when momentum begins to lose strength.

Yellow Markers

Bullish exhaustion warnings.

Often appear when:

bullish momentum slows
pressure acceleration fades
local tops begin forming
Blue Markers

Bearish exhaustion warnings.

Often appear when:

selling pressure weakens
bearish acceleration fades
local bottoms begin forming

These are NOT reversal signals by themselves.

They are early warnings that:

pressure velocity is changing
continuation may weaken
a pullback or reversal becomes more likely
Best Use Cases

This indicator performs especially well on:

NASDAQ / US100
M1 scalping
Momentum continuation
Pullback entries
NY Open volatility
Power Hour moves
Liquidity sweeps
Intraday trend trading
How To Read The Indicator
Strong Trend Continuation
Histogram expands
HTF line agrees
Pressure stays above/below zero
Pullback Inside Trend
Histogram weakens temporarily
HTF line remains strong
Momentum resumes afterward
Possible Exhaustion
Exhaustion markers appear
Histogram loses expansion
Pressure acceleration slows
Trend Transition
Histogram crosses zero
HTF pressure changes direction
Opposite pressure cluster builds
Optimized Settings

Default settings are specifically tuned for NASDAQ M1 flow behavior.

The current configuration balances:

speed
smoothness
pressure persistence
expansion detection
exhaustion sensitivity

without becoming overly noisy.

Important Notes

This indicator is not designed as a standalone buy/sell system.

It works best when combined with:

market structure
liquidity zones
VWAP
session levels
trend context
price action

The strength of the system comes from understanding:

pressure behavior
flow continuation
momentum persistence
exhaustion timing

rather than relying on simple signal markers alone.

## Source Code

````pine
//@version=6
indicator("NASDAQ Persistent Pressure PRO + Exhaustion", overlay=false)

//━━━━━━━━━━━━━━━━━━ INPUTS
groupCore = "Core"

smoothLen = input.int(2, "Pressure Smoothing", minval=1, group=groupCore)
decay     = input.float(0.93, "Pressure Memory", step=0.01, group=groupCore)
scale     = input.float(12.0, "Histogram Scale", step=1, group=groupCore)

showZero  = input.bool(true, "Show Zero Line", group=groupCore)

//━━━━━━━━━━━━━━━━━━ HTF
groupHTF = "HTF Pressure"

showHTF   = input.bool(true, "Show x5 Pressure", group=groupHTF)
htfTf     = input.timeframe("5", "HTF Timeframe", group=groupHTF)
htfSmooth = input.int(2, "HTF Smoothing", group=groupHTF)

//━━━━━━━━━━━━━━━━━━ EXHAUSTION
groupEx = "Exhaustion"

showExhaustion = input.bool(true, "Show Exhaustion Signals", group=groupEx)
exhaustLen     = input.int(5, "Acceleration Smoothing", minval=1, group=groupEx)
signalStrength = input.float(0.6, "Exhaustion Threshold", step=0.1, group=groupEx)

//━━━━━━━━━━━━━━━━━━ RANGE SAFE
rng = math.max(high - low, syminfo.mintick)

//━━━━━━━━━━━━━━━━━━ BUYER / SELLER PRESSURE
bull = volume * ((close - low) / rng)
bear = volume * ((high - close) / rng)

//━━━━━━━━━━━━━━━━━━ RELATIVE PRESSURE
rawPressure =
     volume != 0 ?
     ((bull - bear) / volume) :
     0

//━━━━━━━━━━━━━━━━━━ SMOOTH PRESSURE
basePressure = ta.ema(rawPressure, smoothLen)

//━━━━━━━━━━━━━━━━━━ PERSISTENT PRESSURE
var float persistentPressure = 0.0
persistentPressure := nz(persistentPressure[1]) * decay + basePressure

//━━━━━━━━━━━━━━━━━━ EXPANSION BOOST
candleExpansion = (high - low) > ta.ema(high - low, 20)

expansionBoost =
     candleExpansion ?
     1.25 :
     1.0

boostedPressure = persistentPressure * expansionBoost

//━━━━━━━━━━━━━━━━━━ NORMALIZATION
maxPressure = ta.highest(math.abs(boostedPressure), 200)

scaledPressure =
     maxPressure != 0 ?
     (boostedPressure / maxPressure) * scale :
     0

//━━━━━━━━━━━━━━━━━━ HTF PRESSURE
htfRaw = request.security(
     syminfo.tickerid,
     htfTf,
     ((volume * ((close - low) / math.max(high - low, syminfo.mintick))) -
     (volume * ((high - close) / math.max(high - low, syminfo.mintick)))) / volume
)

htfSmoothPressure = ta.ema(htfRaw, htfSmooth)

var float htfPersistent = 0.0
htfPersistent := nz(htfPersistent[1]) * decay + htfSmoothPressure

htfMax = ta.highest(math.abs(htfPersistent), 200)

scaledHTF =
     htfMax != 0 ?
     (htfPersistent / htfMax) * scale :
     0

//━━━━━━━━━━━━━━━━━━ PRESSURE ACCELERATION
pressureVelocity = scaledPressure - scaledPressure[1]

pressureAccel = ta.ema(
     pressureVelocity,
     exhaustLen
)

//━━━━━━━━━━━━━━━━━━ EXHAUSTION LOGIC
bullExhaustion =
     scaledPressure > signalStrength and
     pressureAccel < pressureAccel[1] and
     pressureAccel < 0

bearExhaustion =
     scaledPressure < -signalStrength and
     pressureAccel > pressureAccel[1] and
     pressureAccel > 0

//━━━━━━━━━━━━━━━━━━ COLORS
bullStrong = color.rgb(0, 255, 140)
bullWeak   = color.rgb(0, 120, 70)

bearStrong = color.rgb(255, 0, 70)
bearWeak   = color.rgb(120, 0, 30)

//━━━━━━━━━━━━━━━━━━ HISTOGRAM COLOR
histColor =
     scaledPressure > 0 ?
     (scaledPressure > scaledPressure[1] ? bullStrong : bullWeak) :
     scaledPressure < 0 ?
     (scaledPressure < scaledPressure[1] ? bearStrong : bearWeak) :
     color.gray

//━━━━━━━━━━━━━━━━━━ HTF COLOR
htfColor =
     scaledHTF > 0 ?
     color.new(color.lime, 0) :
     color.new(color.red, 0)

//━━━━━━━━━━━━━━━━━━ PLOTS
plot(
     scaledPressure,
     title="NASDAQ Pressure",
     style=plot.style_histogram,
     color=histColor,
     linewidth=5
)

plot(
     showHTF ? scaledHTF : na,
     title="x5 Pressure",
     color=htfColor,
     linewidth=2
)

//━━━━━━━━━━━━━━━━━━ EXHAUSTION SIGNALS
plotshape(
     showExhaustion and bullExhaustion,
     title="Bull Exhaustion",
     style=shape.triangledown,
     location=location.top,
     color=color.yellow,
     size=size.tiny
)

plotshape(
     showExhaustion and bearExhaustion,
     title="Bear Exhaustion",
     style=shape.triangleup,
     location=location.bottom,
     color=color.aqua,
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━ ZERO LINE
plot(
     showZero ? 0 : na,
     title="Zero Line",
     color=color.new(color.white, 70),
     linewidth=1
)
````
