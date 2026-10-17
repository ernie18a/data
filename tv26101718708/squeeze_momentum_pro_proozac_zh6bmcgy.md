# Squeeze Momentum Pro [Proozac]

- url: https://www.tradingview.com/script/zH6bmcgY-Squeeze-Momentum-Pro-Proozac/
- type: indicator
- pine_id: PUB;21ad0fa9f8684144b71cc061d28e9ada
- version: 1.0

## Description

[b]SQUEEZE MOMENTUM PRO[/b]

Squeeze Momentum Pro combines volatility compression with momentum analysis to help identify potential breakout opportunities.

The indicator detects when Bollinger Bands contract inside Keltner Channels, signaling a period of unusually low volatility (a squeeze). Once volatility expands again, it highlights the breakout while showing whether bullish or bearish momentum is strengthening or weakening.

[b]FEATURES[/b]

Squeeze Detection

• Red Dot = Squeeze ON (volatility compression)
• Green Dot = Squeeze OFF (breakout released)
• Gray Dot = No Squeeze

Momentum Histogram

Momentum is calculated using a linear regression of price relative to its recent trading range.

Histogram colors:

• Bright Green = Bullish momentum increasing
• Teal = Bullish momentum weakening
• Bright Red = Bearish momentum increasing
• Muted Red = Bearish momentum weakening

Squeeze Fire

When a squeeze changes from ON to OFF, the indicator highlights the breakout:

• Green Background = Bullish Squeeze Fire
• Red Background = Bearish Squeeze Fire

This is the primary trading signal.

[b]INPUTS[/b]

Squeeze Settings

• BB Length
• BB Multiplier
• KC Length
• KC Multiplier

Momentum Settings

• Momentum Length
• EMA or SMA smoothing
• Smoothing Length

Visual Settings

• Custom colors for squeeze dots
• Custom colors for all momentum states

Alerts

• Bullish Squeeze Fire
• Bearish Squeeze Fire
• Squeeze Started

[b]SUGGESTED USE[/b]

A squeeze is a warning that volatility is compressing, not an entry signal by itself.

The highest-probability setups occur when a squeeze lasts for several bars, then fires while momentum confirms the breakout direction.

The strongest signals usually appear when the histogram is Bright Green or Bright Red on the firing bar, indicating accelerating momentum.

Works on all timeframes, with particularly clean signals on the 1H and 4H charts. On lower timeframes, reducing the smoothing length can improve responsiveness.

## Source Code

````pine
//@version=6
// Squeeze Momentum Pro — BB/KC squeeze with momentum acceleration histogram
indicator("Squeeze Momentum Pro", shorttitle="Squeeze Pro", overlay=false)

// ── Inputs ────────────────────────────────────────────────────────────────────
g1 = "Squeeze Detection"
bb_len    = input.int(20, "BB Length", group=g1, minval=5)
bb_mult   = input.float(2.0, "BB Multiplier", group=g1, minval=0.5, step=0.1)
kc_len    = input.int(20, "KC Length", group=g1, minval=5)
kc_mult   = input.float(1.5, "KC Multiplier", group=g1, minval=0.5, step=0.1)

g2 = "Momentum"
mom_len    = input.int(12, "Momentum Length", group=g2, minval=3)
use_ema    = input.bool(true, "Smooth with EMA (vs SMA)", group=g2)
smooth_len = input.int(3, "Smoothing Length", group=g2, minval=1)

g3 = "Colors"
sq_on_col    = input.color(#f44336, "Squeeze ON  dot", group=g3)
sq_off_col   = input.color(#4caf50, "Squeeze OFF dot", group=g3)
sq_none_col  = input.color(color.gray, "No Squeeze dot", group=g3)
mom_bull_acc = input.color(#00e676, "Momentum Bull Accel", group=g3)
mom_bull_dec = input.color(#26a69a, "Momentum Bull Decel", group=g3)
mom_bear_acc = input.color(#ff1744, "Momentum Bear Accel", group=g3)
mom_bear_dec = input.color(#ef5350, "Momentum Bear Decel", group=g3)

// ── Calculations ──────────────────────────────────────────────────────────────
bb_basis = ta.sma(close, bb_len)
bb_dev   = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev

kc_basis = ta.ema(close, kc_len)
kc_range = kc_mult * ta.atr(kc_len)
kc_upper = kc_basis + kc_range
kc_lower = kc_basis - kc_range

sq_on  = bb_upper < kc_upper and bb_lower > kc_lower
sq_off = bb_upper > kc_upper and bb_lower < kc_lower

mom_raw = ta.linreg(close - math.avg(ta.highest(high, mom_len), ta.lowest(low, mom_len)), mom_len, 0)
mom     = use_ema ? ta.ema(mom_raw, smooth_len) : ta.sma(mom_raw, smooth_len)

mom_color = mom > 0 ? (mom > mom[1] ? mom_bull_acc : mom_bull_dec) : (mom < mom[1] ? mom_bear_acc : mom_bear_dec)

// ── Plots ─────────────────────────────────────────────────────────────────────
plot(mom, "Momentum", color=mom_color, style=plot.style_histogram, linewidth=4)
plot(0, "Zero Line", color=color.new(color.gray, 40), linewidth=1)

squeeze_dot_color = sq_on ? sq_on_col : sq_off ? sq_off_col : sq_none_col
plot(0, "Squeeze State", color=squeeze_dot_color, linewidth=3, style=plot.style_circles)

hline(0, "Zero", color=color.new(color.gray, 30), linestyle=hline.style_solid, linewidth=1)

// ── Squeeze Fire ──────────────────────────────────────────────────────────────
sq_fired_bull = sq_off and sq_on[1] and mom > 0
sq_fired_bear = sq_off and sq_on[1] and mom < 0

fire_bg = sq_fired_bull ? color.new(#00e676, 75) : sq_fired_bear ? color.new(#ff1744, 75) : na
bgcolor(fire_bg, title="Squeeze Fire")

// ── Info Label ────────────────────────────────────────────────────────────────
var label sq_info = na
if barstate.islast
    label.delete(sq_info)
    sq_txt  = sq_on ? "SQUEEZE ON - Coiling..." : sq_off ? "SQUEEZE FIRED" : "No Squeeze"
    sq_col  = sq_on ? sq_on_col : sq_off ? sq_off_col : sq_none_col
    sq_info := label.new(bar_index, mom, sq_txt, style=label.style_label_left, color=color.new(sq_col, 30), textcolor=color.white, size=size.small)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(sq_fired_bull, "Bullish Squeeze Fire", "{{ticker}} — Bullish squeeze fire on {{interval}}")
alertcondition(sq_fired_bear, "Bearish Squeeze Fire", "{{ticker}} — Bearish squeeze fire on {{interval}}")
alertcondition(sq_on and not sq_on[1], "Squeeze Started", "{{ticker}} — Volatility squeeze began on {{interval}}")
````
