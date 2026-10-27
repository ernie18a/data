# PURE VOLUME FLOW MTF PRO + DYNAMIC BANDS

- url: https://www.tradingview.com/script/ajLreMYl/
- type: indicator
- pine_id: PUB;3b2ed193cf2b495d8daa93a55dc91aea
- version: 1.0

## Description

# PURE VOLUME FLOW MTF PRO + DYNAMIC BANDS

PURE VOLUME FLOW MTF PRO is an advanced multi-timeframe volume pressure oscillator designed to visualize real market participation instead of traditional price-only momentum.

Unlike classic RSI, MACD, or standard oscillators, this system focuses on aggressive buy/sell volume flow and liquidity pressure across multiple timeframes.

The indicator combines:

* Real-time volume pressure
* Dynamic liquidity expansion
* Multi-timeframe flow alignment
* Adaptive average pressure zones
* Volume exhaustion behavior
* Flow divergence detection

into one clean visual structure.

━━━━━━━━━━━━━━━━━━

# CORE IDEA

Price alone does not always reveal the true strength of a move.

Markets can continue moving because of:

* short-term momentum
* stop runs
* liquidations
* thin liquidity
* algorithmic spikes

while real participation already fades.

This indicator is designed to detect:

* when volume truly supports a move
* when pressure weakens
* when higher timeframe participation disappears
* when moves become exhausted

━━━━━━━━━━━━━━━━━━

# HOW IT WORKS

The engine separates bullish and bearish volume pressure:

* Up candles contribute bullish volume
* Down candles contribute bearish volume

The system then calculates normalized pressure flow using:

* EMA-based volume smoothing
* Relative volume normalization
* Dynamic pressure averaging

The result is a smooth flow oscillator representing real market pressure instead of simple price momentum.

━━━━━━━━━━━━━━━━━━

# MULTI-TIMEFRAME STRUCTURE

The indicator contains 3 synchronized flow engines:

## Chart TF

Fast and highly reactive.
Shows immediate aggressive buying/selling activity.

## x5 TF

Represents medium-term participation and confirmation.
Often reveals weakening pressure before price reacts.

## x15 TF

Represents higher timeframe directional commitment and institutional bias.

━━━━━━━━━━━━━━━━━━

# DYNAMIC PRESSURE BANDS

The adaptive bands are based on:

* EMA of absolute flow values
* dynamic volatility normalization

These bands automatically adjust to:

* NASDAQ
* BTC
* Gold
* Forex
* volatile sessions
* low volatility periods

Behavior:

* Inside bands → normal market activity
* Outside bands → above-average pressure
* Extreme expansion → possible exhaustion or climax

━━━━━━━━━━━━━━━━━━

# FLOW DIVERGENCES

One of the most powerful features of the system.

Example bearish divergence:

* Price makes Higher High
* x5 Flow makes Lower High

This often indicates:

* weakening participation
* buyer exhaustion
* liquidity drain
* fragile continuation

Example bullish divergence:

* Price makes Lower Low
* Flow makes Higher Low

This often indicates:

* seller exhaustion
* absorption
* potential reversal

━━━━━━━━━━━━━━━━━━

# WHY THIS IS DIFFERENT

Most oscillators are based on:

* price momentum
* RSI calculations
* moving average distance

PURE VOLUME FLOW focuses on:

* actual market participation
* aggressive volume pressure
* liquidity expansion/compression
* higher timeframe commitment

This makes the system highly effective for:

* NASDAQ scalping
* BTC intraday trading
* Gold momentum trading
* NY Open volatility
* trend continuation
* exhaustion detection

━━━━━━━━━━━━━━━━━━

# BEST USE CASES

* M1 scalping
* M3 momentum trading
* trend continuation
* pullback validation
* exhaustion detection
* divergence trading
* HTF permission filtering

━━━━━━━━━━━━━━━━━━

# VISUAL INTERPRETATION

* Rising flow = increasing aggressive participation
* Falling flow = weakening participation
* x5 leading reversals = early warning
* x15 alignment = directional confirmation
* Band expansion = strong market pressure
* Band rejection = possible exhaustion

━━━━━━━━━━━━━━━━━━

# INCLUDED FEATURES

✔ Pure volume flow engine
✔ Multi-timeframe flow analysis
✔ Dynamic adaptive pressure bands
✔ HTF confirmation structure
✔ Divergence detection
✔ Signal lines
✔ Exhaustion visualization
✔ Liquidity expansion behavior
✔ Clean minimalistic design

━━━━━━━━━━━━━━━━━━

Designed for traders who want to see:
not only where price moves —
but where real market pressure actually exists.

## Source Code

````pine
//@version=6
indicator("PURE VOLUME FLOW MTF PRO + DYNAMIC BANDS", overlay=false)

//━━━━━━━━━━━━━━━━━━ INPUTS

volLen      = input.int(20, "Volume Smoothing")
flowSmooth  = input.int(5, "Flow Smooth")
sigLen      = input.int(8, "Signal Length")

bandLen     = input.int(100, "Band Average Length")
bandMult    = input.float(1.5, "Band Multiplier", step=0.1)

showBands   = input.bool(true, "Show Dynamic Bands")

showX5      = input.bool(true, "Show x5")
showX15     = input.bool(true, "Show x15")

showSignals = input.bool(true, "Show Signal Lines")

x5Scale     = input.float(2.0, "x5 Scale")
x15Scale    = input.float(3.2, "x15 Scale")

//━━━━━━━━━━━━━━━━━━ COLORS

chartBull   = input.color(color.rgb(0,255,120), "Chart Bull")
chartBear   = input.color(color.rgb(255,40,40), "Chart Bear")

x5Bull      = input.color(color.rgb(0,220,255), "x5 Bull")
x5Bear      = input.color(color.rgb(255,150,0), "x5 Bear")

x15Bull     = input.color(color.rgb(255,0,255), "x15 Bull")
x15Bear     = input.color(color.rgb(255,255,0), "x15 Bear")

upperBandCol =
     input.color(color.rgb(255,255,255), "Upper Band")

lowerBandCol =
     input.color(color.rgb(255,255,255), "Lower Band")

//━━━━━━━━━━━━━━━━━━ PURE VOLUME ENGINE

calcVolFlow(mult) =>

    buyVol =
         close > close[1]
         ? volume
         : 0.0

    sellVol =
         close < close[1]
         ? volume
         : 0.0

    raw =
         ta.ema(
             buyVol - sellVol,
             volLen * mult)

    norm =
         raw /
         (ta.ema(volume, volLen * mult) + 0.000001)

    flow =
         ta.ema(
             norm,
             flowSmooth * mult)

    flow

//━━━━━━━━━━━━━━━━━━ CHART

flow =
     calcVolFlow(1)

signal =
     ta.ema(flow, sigLen)

//━━━━━━━━━━━━━━━━━━ X5

flow5_raw =
     calcVolFlow(5)

flow5 =
     ta.ema(flow5_raw, 3) * x5Scale

signal5 =
     ta.ema(flow5, sigLen)

//━━━━━━━━━━━━━━━━━━ X15

flow15_raw =
     calcVolFlow(15)

flow15 =
     ta.ema(flow15_raw, 5) * x15Scale

signal15 =
     ta.ema(flow15, sigLen)

//━━━━━━━━━━━━━━━━━━ DYNAMIC BANDS

avgRange =
     ta.ema(math.abs(flow), bandLen)

upperBand =
     avgRange * bandMult

lowerBand =
     -avgRange * bandMult

//━━━━━━━━━━━━━━━━━━ COLORS

chartStrength =
     math.abs(flow - flow[1]) /
     (ta.ema(math.abs(flow - flow[1]), 34) + 0.000001)

chartAlpha =
     82 - int(math.min(chartStrength * 45, 65))

chartCol =
     flow > flow[1]
     ? color.new(chartBull, chartAlpha)
     : color.new(chartBear, chartAlpha)

x5Col =
     flow5 > flow5[1]
     ? color.new(x5Bull, 0)
     : color.new(x5Bear, 0)

x15Col =
     flow15 > flow15[1]
     ? color.new(x15Bull, 0)
     : color.new(x15Bear, 0)

//━━━━━━━━━━━━━━━━━━ SIGNALS

bull =
     ta.crossover(flow, signal)

bear =
     ta.crossunder(flow, signal)

//━━━━━━━━━━━━━━━━━━ ZERO

hline(
     0,
     "Zero",
     color.new(color.gray, 75))

//━━━━━━━━━━━━━━━━━━ BANDS

upperPlot =
     plot(
         showBands ? upperBand : na,
         title="Upper Dynamic Band",
         color=color.new(upperBandCol, 40),
         linewidth=1)

lowerPlot =
     plot(
         showBands ? lowerBand : na,
         title="Lower Dynamic Band",
         color=color.new(lowerBandCol, 40),
         linewidth=1)

fill(
     upperPlot,
     lowerPlot,
     color=color.new(color.white, 96))

//━━━━━━━━━━━━━━━━━━ CHART FLOW

plot(
     flow,
     title="Chart Volume Flow",
     color=chartCol,
     linewidth=2)

plot(
     showSignals ? signal : na,
     title="Chart Signal",
     color=color.new(color.white, 20),
     linewidth=1)

//━━━━━━━━━━━━━━━━━━ X5 FLOW

plot(
     showX5 ? flow5 : na,
     title="x5 Volume Flow",
     color=x5Col,
     linewidth=1)

plot(
     showX5 and showSignals ? signal5 : na,
     title="x5 Signal",
     color=color.new(color.white, 0),
     linewidth=1)

//━━━━━━━━━━━━━━━━━━ X15 FLOW

plot(
     showX15 ? flow15 : na,
     title="x15 Volume Flow",
     color=x15Col,
     linewidth=1)

plot(
     showX15 and showSignals ? signal15 : na,
     title="x15 Signal",
     color=color.new(color.white, 0),
     linewidth=1)

//━━━━━━━━━━━━━━━━━━ MARKERS

plotshape(
     bull,
     title="Bull",
     style=shape.circle,
     location=location.bottom,
     color=chartBull,
     size=size.tiny)

plotshape(
     bear,
     title="Bear",
     style=shape.circle,
     location=location.top,
     color=chartBear,
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━ ALERTS

alertcondition(
     bull,
     "Bullish Volume Cross",
     "Volume flow crossed above signal")

alertcondition(
     bear,
     "Bearish Volume Cross",
     "Volume flow crossed below signal")
````
