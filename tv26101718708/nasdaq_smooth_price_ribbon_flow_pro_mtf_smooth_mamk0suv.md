# NASDAQ Smooth Price Ribbon FLOW PRO MTF SMOOTH

- url: https://www.tradingview.com/script/MaMk0sUv/
- type: indicator
- pine_id: PUB;b3cd8d114c254b73bfe23be5320c0eaa
- version: 1.0

## Description

A professional multi-timeframe flow ribbon designed specifically for NASDAQ scalping and intraday trading.

This indicator transforms price action into smooth dynamic flow zones that behave more like institutional liquidity fields than traditional moving averages.

Unlike standard MTF EMA systems, the ribbons are organically smoothed to eliminate stair-stepping while still preserving true higher-timeframe structure and directional bias.

The result is a clean momentum-flow overlay optimized for fast NASDAQ conditions on lower timeframes like M1 and M5.

FEATURES
Smooth Multi-Timeframe Flow Engine

Includes 4 independent flow structures:

Chart Timeframe
x5 Intraday Flow
x15 Session Flow
1H Institutional Flow

Each layer acts as a dynamic liquidity ribbon instead of a static EMA.

No Stair-Stepping

Most MTF indicators suffer from hard HTF stepping.

This script uses synthetic smoothing and multiplier-based flow projection to create continuous institutional-style curves while preserving HTF directional behavior.

The HTF ribbons remain smooth even during strong volatility.

Adaptive Dynamic Bands

Ribbon width expands and contracts automatically based on:

momentum acceleration
flow strength
volatility pressure
directional expansion

This creates natural liquidity zones during trends and tighter structures during consolidation.

NASDAQ Optimized

The default settings are specifically tuned for:

NASDAQ M1 scalping
fast momentum continuation
pullback trading
session flow analysis
intraday trend alignment

The indicator reacts quickly without becoming noisy.

Smart Trend Coloring

Color logic is intentionally simplified:

Rising flow = green
Falling flow = red

This avoids constant color flipping during small pullbacks and creates cleaner trend readability.

Professional Flow Structure

Each timeframe has a different role:

Chart TF → short-term momentum
x5 → intraday trend guide
x15 → session direction
1H → institutional bias / magnet zone

The interaction between ribbons creates high-quality continuation and pullback areas.

BEST USE CASES
NASDAQ scalping
Momentum trading
Pullback entries
Trend continuation
HTF bias filtering
Session flow analysis
Liquidity zone visualization
RECOMMENDED TIMEFRAMES

Best optimized for:

M1
M3
M5

Can also be used on:

M15
H1
DEFAULT NASDAQ SETTINGS
Main Smooth = 11
Flow Smooth = 4
Trend Smooth = 6

x5 Multiplier = 5
x15 Multiplier = 18
1H Multiplier = 75

These settings create:

fast chart response
smooth higher timeframe structure
reduced noise
strong trend continuation behavior
cleaner institutional flow zones
VISUAL INTERPRETATION
Green Expanding Ribbon

Strong bullish momentum expansion.

Red Expanding Ribbon

Strong bearish momentum expansion.

Narrow Ribbon

Compression / consolidation phase.

Price Pullback Into HTF Ribbon

Potential continuation zone.

HTF Ribbon Crossovers

Possible larger directional shift.

IMPORTANT

This indicator is not designed as a signal generator.

It is a professional market structure and flow visualization tool intended to improve:

directional bias
trend alignment
pullback timing
momentum confirmation
higher timeframe awareness

Best combined with price action and volume analysis.

## Source Code

````pine
//@version=6
indicator("NASDAQ Smooth Price Ribbon FLOW PRO MTF SMOOTH", overlay=true)

//━━━━━━━━━━━━━━━━━━ INPUTS
src = input.source(close, "Price Source")

//━━━━━━━━━━━━━━━━━━ TOGGLES
showChart = input.bool(true, "Show Chart TF")
show_x5   = input.bool(true, "Show x5 Smooth")
show_x15  = input.bool(true, "Show x15 Smooth")
show_h1   = input.bool(true, "Show 1H Smooth")

showLabels = input.bool(true, "Show TF Labels")

labelOffset = input.int(18, "Label X Offset")

//━━━━━━━━━━━━━━━━━━ NASDAQ OPTIMIZED SETTINGS
smoothLen = input.int(11, "Main Smooth", minval=1)
flowLen   = input.int(4,  "Flow Smooth", minval=1)

trendLen = input.int(6, "Trend Smooth", minval=1)

strengthLen = input.int(6, "Strength Length", minval=1)
accelLen    = input.int(3, "Acceleration Length", minval=1)

minBandATR = input.float(0.03, "Min Band ATR", step=0.01)
maxBandATR = input.float(0.35, "Max Band ATR", step=0.01)

//━━━━━━━━━━━━━━━━━━ NASDAQ MTF MULTIPLIERS
x5Mult  = input.float(5.0,  "x5 Multiplier")
x15Mult = input.float(18.0, "x15 Multiplier")
h1Mult  = input.float(75.0, "1H Multiplier")

//━━━━━━━━━━━━━━━━━━ COLORS

// CHART
chartBullLine = input.color(color.lime, "Chart Bull Line")
chartBearLine = input.color(color.red,  "Chart Bear Line")

chartBullFill = input.color(color.new(color.lime, 78), "Chart Bull Fill")
chartBearFill = input.color(color.new(color.red, 78),  "Chart Bear Fill")

// x5
x5BullLine = input.color(color.new(color.green, 25), "x5 Bull Line")
x5BearLine = input.color(color.new(color.red, 25),   "x5 Bear Line")

x5BullFill = input.color(color.new(color.green, 84), "x5 Bull Fill")
x5BearFill = input.color(color.new(color.red, 84),   "x5 Bear Fill")

// x15
x15BullLine = input.color(color.new(color.aqua, 40),   "x15 Bull Line")
x15BearLine = input.color(color.new(color.orange, 40), "x15 Bear Line")

x15BullFill = input.color(color.new(color.aqua, 88),   "x15 Bull Fill")
x15BearFill = input.color(color.new(color.orange, 88), "x15 Bear Fill")

// 1H
h1BullLine = input.color(color.new(color.teal, 55),   "1H Bull Line")
h1BearLine = input.color(color.new(color.maroon, 55), "1H Bear Line")

h1BullFill = input.color(color.new(color.teal, 90),   "1H Bull Fill")
h1BearFill = input.color(color.new(color.maroon, 90), "1H Bear Fill")

//━━━━━━━━━━━━━━━━━━ FLOW ENGINE
f_flow(_src, _smoothLen, _flowLen) =>
    ema1 = ta.ema(_src, _smoothLen)
    ema2 = ta.ema(ema1, _smoothLen)
    ema3 = ta.ema(ema2, _flowLen)

    baseFlow = ta.ema(ema3, _flowLen)

    ta.ema(
         baseFlow + (baseFlow - baseFlow[2]) * 0.40,
         3
    )

//━━━━━━━━━━━━━━━━━━ BAND ENGINE
f_band(_flow, _strengthLen, _accelLen) =>
    slope = _flow - _flow[1]
    slopeAbs = math.abs(slope)

    power = ta.ema(slopeAbs, _strengthLen)
    accel = ta.ema(math.abs(power - power[1]), _accelLen)

    strengthRaw = (power * 0.40) + (accel * 2.4)
    strength = ta.ema(strengthRaw, 3)

    atrValue = ta.atr(14)

    normStrength = math.pow(
         math.min(1.0, strength * 90000),
         1.4
    )

    atrValue * (minBandATR + (normStrength * maxBandATR))

//━━━━━━━━━━━━━━━━━━ CHART FLOW
chartFlow = f_flow(src, smoothLen, flowLen)

chartBand = f_band(chartFlow, strengthLen, accelLen)

chartUpper = chartFlow + chartBand
chartLower = chartFlow - chartBand

chartTrend = ta.ema(chartFlow, trendLen)

chartLineColor =
     chartTrend > chartTrend[1] ?
     chartBullLine :
     chartBearLine

chartFillColor =
     chartTrend > chartTrend[1] ?
     chartBullFill :
     chartBearFill

//━━━━━━━━━━━━━━━━━━ CHART PLOTS
cp1 = plot(
     showChart ? chartUpper : na,
     title="Chart Upper",
     color=color.new(chartLineColor, 75),
     linewidth=2
)

cp2 = plot(
     showChart ? chartLower : na,
     title="Chart Lower",
     color=color.new(chartLineColor, 75),
     linewidth=2
)

fill(cp1, cp2, color=chartFillColor)

plot(
     showChart ? chartFlow : na,
     title="Chart Flow",
     color=chartLineColor,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━ x5
x5SmoothLen = math.max(1, math.round(smoothLen * x5Mult))
x5FlowLen   = math.max(1, math.round(flowLen * x5Mult))
x5TrendLen  = math.max(1, math.round(trendLen * x5Mult))

x5Flow = f_flow(src, x5SmoothLen, x5FlowLen)

x5Band = f_band(x5Flow, strengthLen, accelLen)

x5Upper = x5Flow + x5Band
x5Lower = x5Flow - x5Band

x5Trend = ta.ema(x5Flow, x5TrendLen)

x5LineColor =
     x5Trend > x5Trend[1] ?
     x5BullLine :
     x5BearLine

x5FillColor =
     x5Trend > x5Trend[1] ?
     x5BullFill :
     x5BearFill

xp1 = plot(
     show_x5 ? x5Upper : na,
     title="x5 Upper",
     color=color.new(x5LineColor, 78),
     linewidth=2
)

xp2 = plot(
     show_x5 ? x5Lower : na,
     title="x5 Lower",
     color=color.new(x5LineColor, 78),
     linewidth=2
)

fill(xp1, xp2, color=x5FillColor)

plot(
     show_x5 ? x5Flow : na,
     title="x5 Flow",
     color=x5LineColor,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━ x15
x15SmoothLen = math.max(1, math.round(smoothLen * x15Mult))
x15FlowLen   = math.max(1, math.round(flowLen * x15Mult))
x15TrendLen  = math.max(1, math.round(trendLen * x15Mult))

x15Flow = f_flow(src, x15SmoothLen, x15FlowLen)

x15Band = f_band(x15Flow, strengthLen, accelLen)

x15Upper = x15Flow + x15Band
x15Lower = x15Flow - x15Band

x15Trend = ta.ema(x15Flow, x15TrendLen)

x15LineColor =
     x15Trend > x15Trend[1] ?
     x15BullLine :
     x15BearLine

x15FillColor =
     x15Trend > x15Trend[1] ?
     x15BullFill :
     x15BearFill

x15p1 = plot(
     show_x15 ? x15Upper : na,
     title="x15 Upper",
     color=color.new(x15LineColor, 80),
     linewidth=2
)

x15p2 = plot(
     show_x15 ? x15Lower : na,
     title="x15 Lower",
     color=color.new(x15LineColor, 80),
     linewidth=2
)

fill(x15p1, x15p2, color=x15FillColor)

plot(
     show_x15 ? x15Flow : na,
     title="x15 Flow",
     color=x15LineColor,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━ 1H
h1SmoothLen = math.max(1, math.round(smoothLen * h1Mult))
h1FlowLen   = math.max(1, math.round(flowLen * h1Mult))
h1TrendLen  = math.max(1, math.round(trendLen * h1Mult))

h1Flow = f_flow(src, h1SmoothLen, h1FlowLen)

h1Band = f_band(h1Flow, strengthLen, accelLen)

h1Upper = h1Flow + h1Band
h1Lower = h1Flow - h1Band

h1Trend = ta.ema(h1Flow, h1TrendLen)

h1LineColor =
     h1Trend > h1Trend[1] ?
     h1BullLine :
     h1BearLine

h1FillColor =
     h1Trend > h1Trend[1] ?
     h1BullFill :
     h1BearFill

hp1 = plot(
     show_h1 ? h1Upper : na,
     title="1H Upper",
     color=color.new(h1LineColor, 82),
     linewidth=2
)

hp2 = plot(
     show_h1 ? h1Lower : na,
     title="1H Lower",
     color=color.new(h1LineColor, 82),
     linewidth=2
)

fill(hp1, hp2, color=h1FillColor)

plot(
     show_h1 ? h1Flow : na,
     title="1H Flow",
     color=h1LineColor,
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━ LABELS
var label chartLbl = na
var label x5Lbl    = na
var label x15Lbl   = na
var label h1Lbl    = na

if barstate.islast and showLabels

    label.delete(chartLbl)
    label.delete(x5Lbl)
    label.delete(x15Lbl)
    label.delete(h1Lbl)

    chartLbl := label.new(
         bar_index + labelOffset,
         chartFlow,
         "CHART",
         xloc=xloc.bar_index,
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(color.black, 100),
         size=size.small
    )

    x5Lbl := label.new(
         bar_index + labelOffset,
         x5Flow,
         "x5",
         xloc=xloc.bar_index,
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(color.black, 100),
         size=size.small
    )

    x15Lbl := label.new(
         bar_index + labelOffset,
         x15Flow,
         "x15",
         xloc=xloc.bar_index,
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(color.black, 100),
         size=size.small
    )

    h1Lbl := label.new(
         bar_index + labelOffset,
         h1Flow,
         "1H",
         xloc=xloc.bar_index,
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(color.black, 100),
         size=size.small
    )
````
