# Flow RSI Engine PRO

- url: https://www.tradingview.com/script/wtyAY0fc/
- type: indicator
- pine_id: PUB;8ba7d28271b14d96ab1c4efa680beb15
- version: 1.0

## Description

# NASDAQ Flow RSI Engine PRO

NASDAQ Flow RSI Engine PRO is a momentum-flow oscillator specifically optimized for fast NASDAQ and US100 intraday trading, especially on the 1-minute timeframe.

Unlike a traditional RSI, this indicator does not focus on classic overbought/oversold behavior alone.
Its primary purpose is to visualize:

* momentum acceleration
* flow continuation
* institutional higher timeframe bias
* pullback reloads
* expansion vs compression phases
* early momentum exhaustion

The indicator was redesigned from the ground up for aggressive momentum-based scalping environments where standard RSI indicators often react too slowly.

---

# Core Concept

The engine combines multiple RSI-based flow layers into one clean momentum structure.

The script uses:

* RSI as the raw momentum source
* EMA smoothing for trend-flow calculation
* a secondary flow-pressure engine
* higher timeframe confirmation
* dynamic pressure histogram
* adaptive momentum expansion zones

The goal is to reveal when momentum is:

* building
* accelerating
* weakening
* compressing
* exhausting

before price movement becomes obvious.

---

# Main Components

## 1. NASDAQ Flow Line

The main Flow line represents the active momentum stream.

It is built from:

* RSI
* Trend EMA
* Flow EMA smoothing

The line changes color dynamically depending on:

* momentum strength
* acceleration
* directional pressure

This line is designed to react faster than traditional RSI smoothing methods while still remaining visually clean.

---

## 2. Signal Line

The white Signal line acts as a short-term confirmation layer.

It smooths the Flow line and helps identify:

* flow continuation
* momentum shifts
* early directional weakness

Crossovers between Flow and Signal can reveal:

* pullback reloads
* exhaustion
* momentum failure

---

## 3. HTF x5 Flow

The magenta/cyan HTF line represents the higher timeframe momentum bias using true multi-timeframe calculations.

Default setting:

* 5-minute HTF confirmation for 1-minute NASDAQ trading

This layer acts as:

* institutional bias filter
* trend stability reference
* directional confirmation engine

The HTF line helps reduce low-quality countertrend entries.

---

## 4. Dynamic Momentum Histogram

The histogram visualizes short-term momentum pressure.

Unlike traditional RSI histograms, the color logic reacts earlier to:

* acceleration changes
* directional momentum shifts
* expansion phases

The histogram was intentionally designed to:

* react fast
* remain visually smooth
* avoid excessive flickering

Green histogram:

* bullish pressure
* acceleration
* momentum expansion

Red histogram:

* bearish pressure
* distribution
* downside acceleration

Transparent histogram colors were used intentionally to keep focus on the Flow structure itself.

---

# Key Momentum Zones

## 80

Extreme bullish expansion zone.

Often associated with:

* climax moves
* momentum exhaustion
* aggressive trend continuation

---

## 70

Bullish momentum control zone.

Strong continuation trends usually remain above this area.

---

## 60

Momentum support zone.

NASDAQ pullback continuations often reclaim this level before expansion resumes.

---

## 50

Equilibrium zone.

Represents balance between bullish and bearish pressure.

This area is critical for:

* momentum transitions
* reclaim setups
* directional confirmation

---

## 40

Bearish control zone.

Failure below this area often signals distribution or weakness.

---

## 30

Bearish momentum acceleration zone.

Strong downside continuation frequently develops below this level.

---

## 20

Extreme bearish expansion zone.

Often associated with:

* capitulation
* panic selling
* exhaustion phases

---

# Shift Signals

The indicator includes optional early momentum shift markers.

Green arrows:

* bullish momentum reclaim
* early upside acceleration

Red arrows:

* bearish exhaustion
* momentum failure
* downside pressure expansion

These are not standalone buy/sell signals.
They are intended to assist flow reading and momentum interpretation.

---

# Best Use Cases

This indicator was specifically optimized for:

* NASDAQ / US100
* 1-minute scalping
* momentum continuation trading
* opening range trading
* liquidity sweep reversals
* VWAP reclaim setups
* EMA pullback entries
* expansion breakouts

---

# Design Philosophy

The script was intentionally designed to remain:

* clean
* fast
* readable
* low-lag
* visually structured

The focus is not on predicting tops or bottoms.

The focus is on identifying:

* real momentum flow
* directional intent
* acceleration changes
* market pressure transitions

in real time.

## Source Code

````pine
//@version=6
indicator("Flow RSI Engine PRO", shorttitle="Flow RSI PRO", overlay=false)

//━━━━━━━━━━━━━━━━━━ INPUTS

src = input.source(close, "Source")

// CORE
rsiLen      = input.int(8,  "RSI Length", minval=1)
trendLen    = input.int(5,  "Trend EMA", minval=1)
flowLen     = input.int(13, "Flow EMA", minval=1)
signalLen   = input.int(3,  "Signal EMA", minval=1)

// HTF
htfTF       = input.timeframe("5", "HTF x5 TF")

// VISUALS
showHTF     = input.bool(true,  "Show HTF x5")
showBands   = input.bool(true,  "Show Dynamic Bands")
showHist    = input.bool(true,  "Show Momentum Histogram")
showSignals = input.bool(true,  "Show Shift Signals")
showBg      = input.bool(true,  "Show Expansion Background")

//━━━━━━━━━━━━━━━━━━ CORE ENGINE

rsiRaw = ta.rsi(src, rsiLen)

trend = ta.ema(rsiRaw, trendLen)

flow = ta.ema(trend, flowLen)

signal = ta.ema(flow, signalLen)

//━━━━━━━━━━━━━━━━━━ HTF ENGINE

htfTrend = request.security(
     syminfo.tickerid,
     htfTF,
     ta.ema(
         ta.rsi(src, rsiLen),
         trendLen
     )
)

htfFlow = ta.ema(htfTrend, 3)

//━━━━━━━━━━━━━━━━━━ PRESSURE ENGINE

pressure = flow - signal

absPressure = math.abs(pressure)

avgPressure = ta.ema(absPressure, 34)

//━━━━━━━━━━━━━━━━━━ FAST MOMENTUM ENGINE

fastPressure = flow - flow[1]

histBull =
     fastPressure > 0 and
     fastPressure > fastPressure[1]

histBear =
     fastPressure < 0 and
     fastPressure < fastPressure[1]

//━━━━━━━━━━━━━━━━━━ DYNAMIC BANDS

bandMultiplier = input.float(22.0, "Band Strength", step=0.1)

upperBand = 50 + (avgPressure * bandMultiplier)

lowerBand = 50 - (avgPressure * bandMultiplier)

//━━━━━━━━━━━━━━━━━━ FLOW STATES

bullStrong = pressure > avgPressure and flow > flow[1]

bullWeak = pressure > 0 and not bullStrong

bearStrong = pressure < -avgPressure and flow < flow[1]

bearWeak = pressure < 0 and not bearStrong

//━━━━━━━━━━━━━━━━━━ COLORS

flowColor =
     bullStrong ? color.lime :
     bullWeak   ? color.green :
     bearStrong ? color.red :
     bearWeak   ? color.orange :
     color.white

htfColor =
     htfFlow > htfFlow[1]
     ? color.aqua
     : color.fuchsia

histColor =
     histBull
     ? color.new(color.lime, 72)
     : histBear
     ? color.new(color.red, 72)
     : pressure >= 0
     ? color.new(color.teal, 82)
     : color.new(color.maroon, 82)

//━━━━━━━━━━━━━━━━━━ HISTOGRAM

histValue = 50 + (pressure * 15)

//━━━━━━━━━━━━━━━━━━ SHIFT SIGNALS

buyShift =
     pressure > 0 and
     pressure[1] <= 0 and
     flow > flow[1]

sellShift =
     pressure < 0 and
     pressure[1] >= 0 and
     flow < flow[1]

//━━━━━━━━━━━━━━━━━━ LEVELS

hline(80, "Extreme Bull", color=color.lime)
hline(70, "Bull Flow", color=color.green)

hline(60, "Momentum Bull", color=color.aqua)

hline(50, "Equilibrium", color=color.white)

hline(40, "Bear Flow", color=color.fuchsia)

hline(30, "Momentum Bear", color=color.orange)

hline(20, "Extreme Bear", color=color.red)

//━━━━━━━━━━━━━━━━━━ BANDS

upperPlot = plot(
     showBands ? upperBand : na,
     title="Upper Dynamic Band",
     color=color.green,
     linewidth=1
)

lowerPlot = plot(
     showBands ? lowerBand : na,
     title="Lower Dynamic Band",
     color=color.red,
     linewidth=1
)

fill(
     upperPlot,
     lowerPlot,
     color=color.new(color.gray, 94)
)

//━━━━━━━━━━━━━━━━━━ MAIN FLOW

plot(
     flow,
     title="NASDAQ Flow",
     color=flowColor,
     linewidth=1
)

plot(
     signal,
     title="Signal",
     color=color.white,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━ HTF FLOW

plot(
     showHTF ? htfFlow : na,
     title="HTF x5 Flow",
     color=htfColor,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━ MOMENTUM HISTOGRAM

plot(
     showHist ? histValue : na,
     title="Pressure Histogram",
     style=plot.style_histogram,
     color=histColor,
     linewidth=2
)

//━━━━━━━━━━━━━━━━━━ SIGNALS

plotshape(
     showSignals and buyShift,
     title="BUY SHIFT",
     style=shape.triangleup,
     location=location.bottom,
     color=color.lime,
     size=size.tiny
)

plotshape(
     showSignals and sellShift,
     title="SELL SHIFT",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━ EXPANSION BACKGROUND

bgcolor(
     showBg ?
     (
         pressure > avgPressure ?
         color.new(color.lime, 94) :
         pressure < -avgPressure ?
         color.new(color.red, 94) :
         na
     ) : na
)
````
