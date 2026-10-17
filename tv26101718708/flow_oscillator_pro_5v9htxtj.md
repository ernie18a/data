# FLOW OSCILLATOR PRO

- url: https://www.tradingview.com/script/5V9Htxtj/
- type: indicator
- pine_id: PUB;0558daff6cee4116ba022b8481f56849
- version: 1.0

## Description

FLOW OSCILLATOR PRO is an advanced institutional momentum oscillator designed to visualize real-time buying and selling pressure across multiple flow layers and higher timeframe trend structures.

Unlike traditional MACD-style oscillators, this indicator uses dynamic flow acceleration and deceleration logic, allowing the histogram to react instantly to momentum shifts — even above or below the zero line.

This creates a much more realistic representation of institutional flow and market pressure.

Perfect for:

NASDAQ
US Indices
Gold (XAUUSD)
Crypto
Scalping
Intraday Momentum Trading
FEATURES
Institutional Flow Histogram

The histogram reacts to real momentum direction:

Neon Green = Momentum rising
Neon Red = Momentum falling

Important:

Histogram can turn RED above zero when bullish momentum weakens
Histogram can turn GREEN below zero when buyers return

This provides significantly earlier momentum detection compared to standard oscillators.

Multi-Timeframe Flow System

The oscillator includes multiple flow layers:

Main Flow

Primary short-term momentum engine.

Signal Flow

Smoothed confirmation flow for crossover signals.

X5 Flow

Higher timeframe momentum projection for trend filtering.

X15 Flow

Mid-to-high timeframe institutional trend structure.

H1 Flow

Slow institutional directional bias and macro momentum.

Dynamic Background Trend Modes

The background color can be switched between multiple trend engines:

Chart Flow
X5 Flow
X15 Flow
H1 Flow

This allows traders to choose how aggressive or stable the trend filter should behave.

Background Colors
Green Background = Bullish higher timeframe pressure
Red Background = Bearish higher timeframe pressure
Smart Buy & Sell Signals

Signals are generated when:

Main Flow crosses Signal Flow
Momentum confirms direction
Flow acceleration supports the move

Signal markers are intentionally positioned further away from the zero line for improved visibility and cleaner chart structure.

Extreme Momentum Detection

The indicator also detects:

Momentum exhaustion
Overextended expansion phases
Potential reversal zones

Colored extreme dots help identify areas where trend pressure may begin slowing down.

HOW TO USE
LONG SETUP

Higher probability long setups occur when:

Histogram turns green
Main Flow crosses above Signal Flow
Background trend is green
X5 / X15 flows align upward

Best used during pullback continuations and momentum expansions.

SHORT SETUP

Higher probability short setups occur when:

Histogram turns red
Main Flow crosses below Signal Flow
Background trend is red
X5 / X15 flows align downward

Best used during breakdowns and bearish momentum acceleration.

COLOR LOGIC

This indicator does NOT use traditional positive/negative MACD coloring.

Instead, colors are based on:

Momentum acceleration
Momentum deceleration
Real flow direction
Flow slope behavior

This creates much earlier and more realistic trend transitions.

BEST SETTINGS

Default settings are optimized for:

NASDAQ M1
Fast intraday momentum trading
Institutional flow tracking

Can also be used for:

Gold scalping
Crypto momentum trading
Futures trading
M5 intraday setups
VISUAL DESIGN
Clean oscillator layout
Smooth institutional flow curves
Dynamic histogram behavior
Multi-timeframe structure
Minimal lag
Fast trend recognition
DISCLAIMER

This indicator is designed as a momentum and flow analysis tool.
Always combine with proper risk management and market structure analysis before trading.

## Source Code

````pine
//@version=6
indicator("FLOW OSCILLATOR PRO", overlay=false)

//━━━━━━━━━━━━━━━━━━ INPUTS
fastLen      = input.int(3, "Fast")
slowLen      = input.int(10, "Slow")
signalLen    = input.int(16, "Signal")
smoothLen    = input.int(3, "Smooth")

x5Mult       = input.int(5, "X5 Multiplier")
x15Mult      = input.int(15, "X15 Multiplier")

extremeLevel = input.float(120.0, "Extreme Level")
deadZone     = input.float(15.0, "Dead Zone")

//━━━━━━━━━━━━━━━━━━ BACKGROUND MODE
bgMode = input.string(
     "X15",
     "Background Mode",
     options=["Chart","X5","X15","H1"])

//━━━━━━━━━━━━━━━━━━ FLOW ENGINE
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

flowRaw = (fastEMA - slowEMA) * 8.0
flow = ta.ema(flowRaw, smoothLen)

//━━━━━━━━━━━━━━━━━━ SIGNAL FLOW
signalFlow = ta.ema(flow, signalLen)

//━━━━━━━━━━━━━━━━━━ X5 FLOW
x5FastEMA = ta.ema(close, fastLen * x5Mult)
x5SlowEMA = ta.ema(close, slowLen * x5Mult)

x5Raw = (x5FastEMA - x5SlowEMA) * 8.0
x5Flow = ta.ema(x5Raw, smoothLen * x5Mult)

//━━━━━━━━━━━━━━━━━━ X15 FLOW
x15FastEMA = ta.ema(close, fastLen * x15Mult)
x15SlowEMA = ta.ema(close, slowLen * x15Mult)

x15Raw = (x15FastEMA - x15SlowEMA) * 8.0
x15Flow = ta.ema(x15Raw, smoothLen * x15Mult)

//━━━━━━━━━━━━━━━━━━ H1 FLOW
h1Mult = 60

h1FastEMA = ta.ema(close, fastLen * h1Mult)
h1SlowEMA = ta.ema(close, slowLen * h1Mult)

h1Raw = (h1FastEMA - h1SlowEMA) * 8.0
h1Flow = ta.ema(h1Raw, smoothLen * h1Mult)

//━━━━━━━━━━━━━━━━━━ COLOR FUNCTION
f_col(val) =>
    val >= val[1] ? color.rgb(0,255,120) : color.rgb(255,0,80)

//━━━━━━━━━━━━━━━━━━ COLORS
histColor = f_col(flow)

flowColor = f_col(flow)

signalColor = f_col(signalFlow)

x5Color = f_col(x5Flow)

x15Color = f_col(x15Flow)

h1Color = f_col(h1Flow)

//━━━━━━━━━━━━━━━━━━ HISTOGRAM
plot(
     flow,
     title="Flow Histogram",
     style=plot.style_columns,
     color=histColor,
     linewidth=2)

//━━━━━━━━━━━━━━━━━━ MAIN FLOW LINE
plot(
     flow,
     title="Main Flow",
     color=flowColor,
     linewidth=2)

//━━━━━━━━━━━━━━━━━━ SIGNAL FLOW
plot(
     signalFlow,
     title="Signal Flow",
     color=signalColor,
     linewidth=1)

//━━━━━━━━━━━━━━━━━━ X5 FLOW
plot(
     x5Flow,
     title="X5 Flow",
     color=x5Color,
     linewidth=1)

//━━━━━━━━━━━━━━━━━━ X15 FLOW
plot(
     x15Flow,
     title="X15 Flow",
     color=x15Color,
     linewidth=2)

//━━━━━━━━━━━━━━━━━━ H1 FLOW
plot(
     h1Flow,
     title="H1 Flow",
     color=h1Color,
     linewidth=3)

//━━━━━━━━━━━━━━━━━━ ZERO LINE
hline(
     0,
     color=color.new(color.white, 70))

//━━━━━━━━━━━━━━━━━━ BACKGROUND STATES
chartBull = flow >= flow[1]

x5Bull = x5Flow >= x5Flow[1]

x15Bull = x15Flow >= x15Flow[1]

h1Bull = h1Flow >= h1Flow[1]

//━━━━━━━━━━━━━━━━━━ ACTIVE BACKGROUND
bgBull =
     bgMode == "Chart" ? chartBull :
     bgMode == "X5" ? x5Bull :
     bgMode == "X15" ? x15Bull :
     h1Bull

//━━━━━━━━━━━━━━━━━━ BACKGROUND
bgcolor(
     bgBull
     ? color.new(color.green, 92)
     : color.new(color.red, 92))

//━━━━━━━━━━━━━━━━━━ SIGNALS
bullCross = ta.crossover(flow, signalFlow)

bearCross = ta.crossunder(flow, signalFlow)

buySignal =
     bullCross and
     flow < -deadZone and
     flow >= flow[1]

sellSignal =
     bearCross and
     flow > deadZone and
     flow < flow[1]

//━━━━━━━━━━━━━━━━━━ SIGNAL MEMORY
var int lastBuyBar = na
var int lastSellBar = na

buyReady =
     na(lastBuyBar) or
     bar_index - lastBuyBar > 12

sellReady =
     na(lastSellBar) or
     bar_index - lastSellBar > 12

finalBuy =
     buySignal and
     buyReady

finalSell =
     sellSignal and
     sellReady

if finalBuy
    lastBuyBar := bar_index

if finalSell
    lastSellBar := bar_index

//━━━━━━━━━━━━━━━━━━ EXTREMES
topExtreme =
     flow > extremeLevel and
     flow < flow[1] and
     flow[1] > flow[2]

bottomExtreme =
     flow < -extremeLevel and
     flow > flow[1] and
     flow[1] < flow[2]

//━━━━━━━━━━━━━━━━━━ SIGNAL OFFSET
atrOffset = ta.atr(14) * 6

buyPlot = finalBuy ? flow - atrOffset : na

sellPlot = finalSell ? flow + atrOffset : na

//━━━━━━━━━━━━━━━━━━ BUY SIGNALS
plotshape(
     buyPlot,
     title="Buy Signals",
     style=shape.triangleup,
     location=location.absolute,
     color=color.rgb(0,255,120),
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━ SELL SIGNALS
plotshape(
     sellPlot,
     title="Sell Signals",
     style=shape.triangledown,
     location=location.absolute,
     color=color.rgb(255,0,80),
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━ TOP EXTREME
plotshape(
     topExtreme ? flow : na,
     title="Top Extremes",
     style=shape.circle,
     location=location.absolute,
     color=color.orange,
     size=size.tiny)

//━━━━━━━━━━━━━━━━━━ BOTTOM EXTREME
plotshape(
     bottomExtreme ? flow : na,
     title="Bottom Extremes",
     style=shape.circle,
     location=location.absolute,
     color=color.aqua,
     size=size.tiny)
````
