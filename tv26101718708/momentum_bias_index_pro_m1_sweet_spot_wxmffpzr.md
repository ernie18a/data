# Momentum Bias Index PRO - M1 SWEET SPOT

- url: https://www.tradingview.com/script/wxmFfpzR/
- type: indicator
- pine_id: PUB;80373ff6e6a742d8b7c52e04770ebc92
- version: 1.0

## Description

The original Momentum Bias Index by AlgoAlpha was designed as a general-purpose momentum oscillator for detecting bullish and bearish market pressure. While the original concept worked well for broad market analysis, it was not specifically optimized for the extremely fast and aggressive behavior of NASDAQ on the 1-minute timeframe.

This custom PRO version was completely rebuilt and fine-tuned specifically for NASDAQ M1 scalping and intraday momentum trading.

Instead of measuring only standard momentum, this upgraded version combines:

raw momentum acceleration
EMA flow pressure
directional expansion
adaptive bias smoothing
higher timeframe trend control

into a single institutional-style momentum engine.

Why We Rebuilt the Original

The original version had several limitations when used on NASDAQ M1:

momentum spikes were often too noisy
trend phases were not stable enough
fast reversals created too many false shifts
higher timeframe direction lacked smoothness
momentum strength alone was not enough to measure real market pressure

NASDAQ on the 1-minute chart behaves differently from slower markets. It moves in aggressive liquidity waves, fast momentum expansions, and rapid algorithmic pullbacks.

Because of this, the original oscillator needed a complete restructuring to better detect:

real directional pressure
continuation phases
exhaustion moves
hidden pullbacks
institutional trend flow
What Makes This PRO Version Different
1. Flow Engine Integration

The biggest upgrade is the custom EMA Flow Engine.

The indicator now calculates the pressure difference between fast and slow EMAs and injects this information directly into the momentum calculation.

This creates a much more realistic representation of actual market pressure.

The result:

stronger trend detection
earlier momentum shifts
better continuation signals
cleaner trend structure
2. NASDAQ M1 Sweet Spot Tuning

Every setting was optimized specifically for NASDAQ M1 behavior.

The current tuning focuses on:

ultra-fast reaction speed
controlled smoothing
reduced fake spikes
stable directional bias
high trend responsiveness

This allows the indicator to react early while still filtering a large amount of lower-quality market noise.

3. Smoothed HTF Bias Line

The original higher timeframe logic was redesigned.

Instead of using a raw higher timeframe signal, this version applies additional smoothing to create a stable institutional-style bias filter.

The HTF line now acts as:

a directional trend guide
a trend continuation filter
a pullback confirmation tool
a market state detector

This dramatically improves trend stability during fast NASDAQ sessions.

4. Expansion & Compression Detection

The dynamic average bands now help visualize:

momentum expansion
exhaustion zones
compression phases
pressure imbalance

Strong histogram expansion outside the bands often signals aggressive directional movement, while contraction phases can indicate pullbacks or temporary liquidity pauses.

Advantages Over the Original

Compared to the original Momentum Bias Index, this PRO version offers:

much faster reaction speed
cleaner trend continuation behavior
better NASDAQ adaptation
stronger institutional flow detection
smoother higher timeframe direction
reduced market noise
more stable pullback structure
earlier momentum transitions
improved momentum expansion detection
Best Use Cases

This indicator was specifically designed for:

NASDAQ M1 scalping
intraday momentum trading
trend continuation setups
pullback entries
higher timeframe bias filtering
liquidity expansion detection

It performs especially well during:

New York Open
NASDAQ momentum sessions
breakout environments
trend continuation phases
Final Concept

This is no longer just a standard momentum oscillator.

It has evolved into a hybrid momentum-flow engine that combines:

directional bias
momentum acceleration
EMA pressure flow
higher timeframe structure
dynamic expansion analysis

into one highly responsive NASDAQ M1 trading tool.

The goal was simple:

Create a cleaner, faster, and more institutionally aligned version of the original Momentum Bias Index specifically for high-speed NASDAQ trading.

## Source Code

````pine
//@version=5
indicator("Momentum Bias Index PRO - M1 SWEET SPOT", overlay=false)

//━━━━━━━━━━━━━━━━━━ INPUTS
source = input(close, "Source")

//━━━━━━━━━━━━━━━━━━ SWEET SPOT ENGINE
momentumLength = input.int(2, "Momentum Length", minval=1)
smoothLength   = input.int(2, "Smooth Length", minval=1)

//━━━━━━━━━━━━━━━━━━ FINAL BAND TUNING
bandLength     = input.int(9, "Average Band Length", minval=1)
bandMultiplier = input.float(0.9, "Band Multiplier", step=0.1)

//━━━━━━━━━━━━━━━━━━ FLOW ENGINE
flowFastLen = input.int(2, "Flow Fast EMA")
flowSlowLen = input.int(8, "Flow Slow EMA")
flowBoost   = input.float(1.6, "Flow Boost", step=0.1)

//━━━━━━━━━━━━━━━━━━ VISUALS
showBands      = input.bool(true, "Show Average Bands")
showHTF        = input.bool(true, "Show x15 Trend Line")
showBackground = input.bool(false, "Background Trend")

htfTF = input.timeframe("15", "HTF Timeframe")

//━━━━━━━━━━━━━━━━━━ MOMENTUM
momentum = source - source[momentumLength]

baseStrength = (momentum / ta.ema(high - low, momentumLength)) * 100

//━━━━━━━━━━━━━━━━━━ FLOW ENGINE
flowFast = ta.ema(close, flowFastLen)
flowSlow = ta.ema(close, flowSlowLen)

//━━━━━━━━━━━━━━━━━━ NORMALIZED FLOW
flowPower = ((flowFast - flowSlow) / close) * 10000

//━━━━━━━━━━━━━━━━━━ FINAL STRENGTH
strength = baseStrength + (flowPower * flowBoost)

//━━━━━━━━━━━━━━━━━━ UP / DOWN
upRaw = math.max(strength, 0)
downRaw = math.min(strength, 0)

//━━━━━━━━━━━━━━━━━━ PARSER SAFE MICRO SUM
upMicro = upRaw + upRaw[1]
downMicro = downRaw + downRaw[1]

//━━━━━━━━━━━━━━━━━━ CONTROLLED FLOW SMOOTHING
upBias = ta.ema(upMicro, smoothLength)
downBias = ta.ema(downMicro, smoothLength)

//━━━━━━━━━━━━━━━━━━ DYNAMIC BANDS
upperBand = ta.ema(math.abs(upBias), bandLength) * bandMultiplier
lowerBand = -ta.ema(math.abs(downBias), bandLength) * bandMultiplier

//━━━━━━━━━━━━━━━━━━ HTF TREND (SMOOTHED)
htfTrend = request.security(
     syminfo.tickerid,
     htfTF,
     ta.ema(upBias + downBias, 8)
     )

//━━━━━━━━━━━━━━━━━━ COLORS
upStrong = color.rgb(0,255,120)
upWeak   = color.rgb(0,120,60)

downStrong = color.rgb(255,0,0)
downWeak   = color.rgb(120,0,0)

//━━━━━━━━━━━━━━━━━━ HISTOGRAM COLORS
upColor =
     upBias > upperBand ?
     upStrong :
     upBias > upBias[1] ?
     color.new(upStrong, 0) :
     color.new(upWeak, 0)

downColor =
     downBias < lowerBand ?
     downStrong :
     downBias < downBias[1] ?
     color.new(downStrong, 0) :
     color.new(downWeak, 0)

//━━━━━━━━━━━━━━━━━━ HISTOGRAM
plot(
     upBias,
     title="UP TREND",
     style=plot.style_columns,
     color=upColor,
     linewidth=4
     )

plot(
     downBias,
     title="DOWN TREND",
     style=plot.style_columns,
     color=downColor,
     linewidth=4
     )

//━━━━━━━━━━━━━━━━━━ BANDS
plot(
     showBands ? upperBand : na,
     title="Upper Average Band",
     color=color.orange,
     linewidth=2
     )

plot(
     showBands ? lowerBand : na,
     title="Lower Average Band",
     color=color.orange,
     linewidth=2
     )

//━━━━━━━━━━━━━━━━━━ HTF TREND
plot(
     showHTF ? htfTrend : na,
     title="HTF x15 Trend",
     color=color.white,
     linewidth=2
     )

//━━━━━━━━━━━━━━━━━━ ZERO LINE
hline(0, "ZERO", color=color.gray)

//━━━━━━━━━━━━━━━━━━ BACKGROUND
bgColorFinal =
     showBackground ?
     htfTrend > 0 ?
     color.new(color.green, 92) :
     color.new(color.red, 92)
     : na

bgcolor(bgColorFinal)
````
