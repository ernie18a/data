# Bull Market Support Band + STD Deviation Levels

- url: https://www.tradingview.com/script/b0t5bZw3-Bull-Market-Support-Band-STD-Deviation-Levels/
- type: indicator
- pine_id: PUB;15c0a125acc24cd0b95d0b8bf9543399
- version: 1.0

## Description

An enhanced version of the Bull Market Support Band that introduces a statistical framework for analyzing market structure and volatility.

This indicator builds on the traditional 20-week SMA and 21-week EMA by calculating their average to form a central mean. From this baseline, it plots multiple deviation bands using standard deviation of price, creating a dynamic range of expected movement.

Deviation levels include ±0.5, ±0.75, ±1, ±2, ±3, and ±4 standard deviations, allowing traders to identify key zones of support, resistance, and market extremes.

Lower deviation bands can highlight potential accumulation or value areas, while higher deviation bands may signal overextended or euphoric conditions. The outer bands (±3 and ±4) are particularly useful for spotting rare, high-volatility events.

This tool is designed for higher timeframe analysis, especially in trending markets, and can be used to complement long-term strategies and risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © zkdev (modified)

//@version=5
indicator('Bull Market Support Band + Deviation Levels', overlay=true, timeframe='W', timeframe_gaps=true)

// === Inputs ===
source      = close
smaLength   = input.int(20, title="SMA Length")
emaLength   = input.int(21, title="EMA Length")
stdLength   = input.int(20, title="Std Dev Length")

show_05  = input.bool(true,  "Show ±0.5 SD")
show_075 = input.bool(true,  "Show ±0.75 SD")
show_1   = input.bool(true,  "Show ±1 SD")
show_2   = input.bool(true,  "Show ±2 SD")
show_3   = input.bool(true,  "Show ±3 SD")
show_4   = input.bool(true,  "Show ±4 SD")

// === Base Calculations (Weekly) ===
sma = ta.sma(source, smaLength)
ema = ta.ema(source, emaLength)

// Pull weekly values
outSma = request.security(syminfo.tickerid, timeframe.period, sma)
outEma = request.security(syminfo.tickerid, timeframe.period, ema)

// === Mean ===
basis = (outSma + outEma) / 2

// === Standard Deviation (weekly price) ===
std = request.security(syminfo.tickerid, timeframe.period, ta.stdev(source, stdLength))

// === Deviation Levels ===
u_05  = basis + std * 0.5
l_05  = basis - std * 0.5

u_075 = basis + std * 0.75
l_075 = basis - std * 0.75

u_1   = basis + std * 1.0
l_1   = basis - std * 1.0

u_2   = basis + std * 2.0
l_2   = basis - std * 2.0

u_3   = basis + std * 3.0
l_3   = basis - std * 3.0

u_4   = basis + std * 4.0
l_4   = basis - std * 4.0

// === Original Plots ===
smaPlot = plot(outSma, color=color.new(color.red, 0), title='20w SMA')
emaPlot = plot(outEma, color=color.new(color.green, 0), title='21w EMA')

fill(smaPlot, emaPlot, color=color.new(color.orange, 75), fillgaps=true)

// === Mean Plot ===
plot(basis, color=color.white, linewidth=2, title="Band Mean")

// === Deviation Plots ===
plot(show_05  ? u_05  : na, color=color.new(color.blue, 75), title="+0.5 SD")
plot(show_05  ? l_05  : na, color=color.new(color.blue, 75), title="-0.5 SD")

plot(show_075 ? u_075 : na, color=color.new(color.blue, 65), title="+0.75 SD")
plot(show_075 ? l_075 : na, color=color.new(color.blue, 65), title="-0.75 SD")

plot(show_1   ? u_1   : na, color=color.new(color.blue, 50), title="+1 SD")
plot(show_1   ? l_1   : na, color=color.new(color.blue, 50), title="-1 SD")

plot(show_2   ? u_2   : na, color=color.new(color.blue, 35), title="+2 SD")
plot(show_2   ? l_2   : na, color=color.new(color.blue, 35), title="-2 SD")

plot(show_3   ? u_3   : na, color=color.new(color.purple, 20), title="+3 SD")
plot(show_3   ? l_3   : na, color=color.new(color.purple, 20), title="-3 SD")

plot(show_4   ? u_4   : na, color=color.new(color.purple, 0), title="+4 SD")
plot(show_4   ? l_4   : na, color=color.new(color.purple, 0), title="-4 SD")
````
