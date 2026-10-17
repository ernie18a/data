# Multi-EMA Indicator

- url: https://www.tradingview.com/script/heBHRqG8-Multi-EMA-Indicator/
- type: indicator
- pine_id: PUB;0600f95869b44ca7b0d780b5d2fde9c1
- version: 1.0

## Description

Multi ema for intraday and long term. can be used when you have to plot multiple ema and you are stopped because of limitation to add. ema 34 can be used for intraday

## Source Code

````pine
// ═══════════════════════════════════════════════════════

// Multi-EMA Indicator

// 33 EMA of High (red) + Low (yellow)

// 10 EMA (blue) | 20 EMA (green) | 50 EMA (orange) | 200 EMA (red)

// All EMAs individually togglable

// ═══════════════════════════════════════════════════════

//@version=5

indicator("Multi-EMA Indicator", overlay=true, shorttitle="Multi-EMA")

 

// ─── Group labels ─────────────────────────────────────

g33  = "33 EMA (High / Low)"

gEMA = "Standard EMAs"

 

// ─── 33 EMA inputs ────────────────────────────────────

show33H = input.bool(true,  "Show 33 EMA High",  group=g33)

show33L = input.bool(true,  "Show 33 EMA Low",   group=g33)

len33   = input.int (33,    "Length",             group=g33, minval=1)

 

// ─── Standard EMA inputs ──────────────────────────────

show10  = input.bool(true,  "Show 10 EMA",        group=gEMA)

len10   = input.int (10,    "10 EMA Length",      group=gEMA, minval=1)

 

show20  = input.bool(true,  "Show 20 EMA",        group=gEMA)

len20   = input.int (20,    "20 EMA Length",      group=gEMA, minval=1)

 

show50  = input.bool(true,  "Show 50 EMA",        group=gEMA)

len50   = input.int (50,    "50 EMA Length",      group=gEMA, minval=1)

 

show200 = input.bool(true,  "Show 200 EMA",       group=gEMA)

len200  = input.int (200,   "200 EMA Length",     group=gEMA, minval=1)

 

// ─── Calculations ─────────────────────────────────────

ema33H  = ta.ema(high,  len33)

ema33L  = ta.ema(low,   len33)

ema10   = ta.ema(close, len10)

ema20   = ta.ema(close, len20)

ema50   = ta.ema(close, len50)

ema200  = ta.ema(close, len200)

 

// ─── Plots ────────────────────────────────────────────

plot(show33H  ? ema33H  : na, title="33 EMA High",

     color=color.new(color.red,    0), linewidth=2, style=plot.style_line)

 

plot(show33L  ? ema33L  : na, title="33 EMA Low",

     color=color.new(color.yellow, 0), linewidth=2, style=plot.style_line)

 

plot(show10   ? ema10   : na, title="10 EMA",

     color=color.new(color.blue,   0), linewidth=1, style=plot.style_line)

 

plot(show20   ? ema20   : na, title="20 EMA",

     color=color.new(color.green,  0), linewidth=1, style=plot.style_line)

 

plot(show50   ? ema50   : na, title="50 EMA",

     color=color.new(color.orange, 0), linewidth=1, style=plot.style_line)

 

plot(show200  ? ema200  : na, title="200 EMA",

     color=color.new(color.red,    0), linewidth=2, style=plot.style_line)
````
