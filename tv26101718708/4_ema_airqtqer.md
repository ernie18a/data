# 4 EMA 

- url: https://www.tradingview.com/script/AirqTQer-4-EMA/
- type: indicator
- pine_id: PUB;27d5792cc64b4e28993247c304088be3
- version: 1.0

## Description

This indicator plots four fully customizable Exponential Moving Averages (EMAs) directly on your chart, giving you a clear visual ribbon to identify trend direction, momentum shifts, and dynamic support and resistance levels at a glance.

Each EMA is independently configurable — you can change the period, source (close, open, high, low, hl2, etc.), color, and line width right from the settings panel. You can also toggle any of the four lines on or off without removing the indicator from your chart.

## Source Code

````pine
//@version=5
indicator(title="4 EMA Ribbon", shorttitle="4 EMA", overlay=true)

// ─────────────────────────────────────────
//  EMA 1
// ─────────────────────────────────────────
ema1_enabled = input.bool(true,  title="Show EMA 1",   group="EMA 1")
ema1_length  = input.int(9,      title="EMA 1 Length", group="EMA 1", minval=1)
ema1_source  = input.source(close, title="EMA 1 Source", group="EMA 1")
ema1_color   = input.color(color.new(#00E5FF, 0), title="EMA 1 Color", group="EMA 1")
ema1_width   = input.int(2,      title="EMA 1 Width",  group="EMA 1", minval=1, maxval=5)

// ─────────────────────────────────────────
//  EMA 2
// ─────────────────────────────────────────
ema2_enabled = input.bool(true,  title="Show EMA 2",   group="EMA 2")
ema2_length  = input.int(21,     title="EMA 2 Length", group="EMA 2", minval=1)
ema2_source  = input.source(close, title="EMA 2 Source", group="EMA 2")
ema2_color   = input.color(color.new(#FFEB3B, 0), title="EMA 2 Color", group="EMA 2")
ema2_width   = input.int(2,      title="EMA 2 Width",  group="EMA 2", minval=1, maxval=5)

// ─────────────────────────────────────────
//  EMA 3
// ─────────────────────────────────────────
ema3_enabled = input.bool(true,  title="Show EMA 3",   group="EMA 3")
ema3_length  = input.int(50,     title="EMA 3 Length", group="EMA 3", minval=1)
ema3_source  = input.source(close, title="EMA 3 Source", group="EMA 3")
ema3_color   = input.color(color.new(#FF9800, 0), title="EMA 3 Color", group="EMA 3")
ema3_width   = input.int(2,      title="EMA 3 Width",  group="EMA 3", minval=1, maxval=5)

// ─────────────────────────────────────────
//  EMA 4
// ─────────────────────────────────────────
ema4_enabled = input.bool(true,  title="Show EMA 4",   group="EMA 4")
ema4_length  = input.int(200,    title="EMA 4 Length", group="EMA 4", minval=1)
ema4_source  = input.source(close, title="EMA 4 Source", group="EMA 4")
ema4_color   = input.color(color.new(#F44336, 0), title="EMA 4 Color", group="EMA 4")
ema4_width   = input.int(2,      title="EMA 4 Width",  group="EMA 4", minval=1, maxval=5)

// ─────────────────────────────────────────
//  Calculations
// ─────────────────────────────────────────
ema1_val = ta.ema(ema1_source, ema1_length)
ema2_val = ta.ema(ema2_source, ema2_length)
ema3_val = ta.ema(ema3_source, ema3_length)
ema4_val = ta.ema(ema4_source, ema4_length)

// ─────────────────────────────────────────
//  Plots
// ─────────────────────────────────────────
plot(ema1_enabled ? ema1_val : na, title="EMA 1", color=ema1_color, linewidth=ema1_width)
plot(ema2_enabled ? ema2_val : na, title="EMA 2", color=ema2_color, linewidth=ema2_width)
plot(ema3_enabled ? ema3_val : na, title="EMA 3", color=ema3_color, linewidth=ema3_width)
plot(ema4_enabled ? ema4_val : na, title="EMA 4", color=ema4_color, linewidth=ema4_width)
````
