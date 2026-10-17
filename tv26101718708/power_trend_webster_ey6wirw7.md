# Power Trend [Webster]

- url: https://www.tradingview.com/script/EY6WIRW7-Power-Trend-Webster/
- type: indicator
- pine_id: PUB;4df00af2479f4043b20b8a3e41723443
- version: 2.0

## Description

Implements Mike Webster's Power Trend criteria:

Low has to be above 21 EMA for 10 consecutive days
The 21 EMA is above the 50 SMA for at least 5 days
the 50 SMA is in an uptrend


The final criteria:
Power Trend starts on an up day

Is intentionally not included based on commentary in WRO 68.

Rules:
initiation a Power Trend -
When one of the 3 criteria are met, a yellow dot appears.
When two of the 3 criteria are met, an orange dot appears.
When all 3 criteria are met, a green dot appears

when the Power Trend is in danger -
An orange dot appears with a close below the 21 EMA

The power trend shuts off -
When the 21EMA closes below the 50 SMA

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Calda09

//@version=6
indicator("Power Trend [Webster]", overlay=true, max_bars_back=500)

// Inputs
ema_len  = input.int(21,    "EMA Length",                   group="Settings")
sma_len  = input.int(50,    "SMA Length",                   group="Settings")
low_days = input.int(10,    "Low > EMA consecutive days",   group="Settings")
ema_days = input.int(5,     "EMA > SMA consecutive days",   group="Settings")
sma_lb   = input.int(5,     "SMA Rising Lookback",          group="Settings")
show_mas = input.bool(true,  "Show EMA / SMA lines",        group="Display")

// Moving Averages
ema21 = ta.ema(close, ema_len)
sma50 = ta.sma(close, sma_len)

// Streaks
var int low_streak = 0
var int ema_streak = 0
low_streak := low > ema21 ? low_streak + 1 : 0
ema_streak := ema21 > sma50 ? ema_streak + 1 : 0

// Conditions
cond1 = low_streak >= low_days
cond2 = ema_streak >= ema_days
cond3 = sma50 > sma50[sma_lb]

count     = (cond1 ? 1 : 0) + (cond2 ? 1 : 0) + (cond3 ? 1 : 0)
pt_active = cond1 and cond2 and cond3

// State
var bool pt_engaged = false
var int  prev_count = 0

// Events
pt_on    = pt_active and not pt_engaged
pt_off   = pt_engaged and ema21 < sma50

// Progression dots
dot_1of3 = not pt_engaged and count >= 1 and prev_count < 1
dot_2of3 = not pt_engaged and count >= 2 and prev_count < 2

// Update state
pt_engaged := pt_off ? false : pt_on ? true : pt_engaged
prev_count := pt_off ? 0     : count

// MA lines
ema_col = show_mas ? (pt_engaged ? color.new(#00e5ff, 0) : color.new(color.gray, 65)) : na
sma_col = show_mas ? (pt_engaged ? color.new(#ff9800, 0) : color.new(color.gray, 65)) : na
plot(ema21, "21 EMA", color=ema_col, linewidth=2)
plot(sma50, "50 SMA", color=sma_col, linewidth=2)

// Shading — always on during engaged period
bgcolor(pt_engaged ? color.new(color.lime, 88) : na, title="PT Active Region")

// Dots
plotshape(dot_1of3, title="1 of 3", style=shape.circle, location=location.abovebar, color=color.yellow, size=size.tiny)
plotshape(dot_2of3, title="2 of 3", style=shape.circle, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(pt_on,    title="PT On",  style=shape.circle, location=location.abovebar, color=color.lime,   size=size.tiny)
plotshape(pt_off,   title="PT Off", style=shape.circle, location=location.abovebar, color=color.red,    size=size.tiny)
````
