# MR SATURN

- url: https://www.tradingview.com/script/aqMe5TG9-MR-SATURN/
- type: indicator
- pine_id: PUB;851513da36ff408482f73a607d779422
- version: 1.0

## Description

**Mean Reversion Oscillator (MR Osc)**

This indicator measures how far price has deviated from its statistical mean and signals when that deviation is likely to reverse. It is designed for TradingView (Pine Script v6) and plots as a standalone oscillator pane below the chart.

**Indicators used:**

- **Z-Score** — the core calculation. It takes the difference between price and a moving average, then divides by the standard deviation over the same lookback period. The result tells you how many standard deviations price currently sits from its mean. Values beyond ±2.9 are considered statistically extreme.
- **Moving Average (SMA/EMA/WMA/RMA)** — user-selectable, used as the mean baseline for the z-score calculation.
- **Standard Deviation** — measured over the same lookback window, used to normalize the deviation into z-score units.

**Signals:**

- **Circle (primary)** — fires when the z-score reaches the extreme threshold (default ±2.9) and begins turning back, indicating a potential mean reversion.
- **Diamond (confirmation)** — fires a few candles later when the z-score crosses back through a user-defined level (default ±0.5), confirming the trend has actually shifted rather than just stalling at the extreme.

**Visual elements:** a red band above zero and a teal band below zero mark the neutral transition zone, with dotted reference lines at ±2.0σ and the current threshold and confirmation levels drawn dynamically on the pane.

## Source Code

````pine
//@version=6
indicator("MR SATURN", shorttitle="MeanRev", overlay=false, max_bars_back=500)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_core  = "Core"
src          = input.source(close, "Source", group=grp_core)
length       = input.int(50,  "Length",      group=grp_core, minval=5, maxval=500, tooltip="Lookback for EMA mean and standard-deviation calculation.")
smooth       = input.int(3,   "Smoothing",   group=grp_core, minval=1, maxval=50,  tooltip="EMA passes over the raw z-score to reduce noise.")
sensitivity  = input.float(1.0, "Sensitivity", group=grp_core, minval=0.1, maxval=10.0, step=0.1, tooltip="Scales oscillator amplitude. 1.0 = raw z-score. Higher = larger swings.")

grp_zones = "Zone Levels"
ob_level  = input.float( 0.40, "Overbought Centre", group=grp_zones, step=0.05, tooltip="Midpoint of the red overbought band.")
os_level  = input.float(-0.30, "Oversold Centre",   group=grp_zones, step=0.05, tooltip="Midpoint of the green oversold band.")
band_w    = input.float( 0.12, "Band Half-Width",   group=grp_zones, step=0.01, minval=0.01, tooltip="Half the height of each coloured zone band.")

grp_sig = "Confirmation Signal"
confirm_bars  = input.int(1,   "Peak/Trough Lookback", group=grp_sig, minval=1, maxval=5, tooltip="Bars each side that must be lower/higher to confirm a peak or trough.")
require_cross = input.bool(true, "Require Zone Cross",  group=grp_sig, tooltip="When ON, signals only fire if the oscillator entered the zone.")

grp_style = "Style"
show_hist = input.bool(false, "Histogram Mode (v3.2 style)", group=grp_style, tooltip="Fills area under curve instead of a line.")
line_col  = input.color(color.new(color.blue,  0),  "Line / Histogram Color",  group=grp_style)
ob_col    = input.color(color.new(color.red,   65), "Overbought Band Color",   group=grp_style)
os_col    = input.color(color.new(color.green, 65), "Oversold Band Color",     group=grp_style)
dot_bear  = input.color(color.red,                  "Bear Reversal Dot Color", group=grp_style)
dot_bull  = input.color(color.lime,                 "Bull Reversal Dot Color", group=grp_style)


// ─────────────────────────────────────────────────────────────────────────────
//  OSCILLATOR  (z-score of price vs its EMA, scaled by sensitivity)
// ─────────────────────────────────────────────────────────────────────────────
basis = ta.ema(src, length)
dev   = ta.stdev(src, length)
raw   = dev > 0 ? (src - basis) / dev * sensitivity : 0.0
mr    = ta.ema(raw, smooth)


// ─────────────────────────────────────────────────────────────────────────────
//  ZONE BOUNDARIES
// ─────────────────────────────────────────────────────────────────────────────
ob_hi = ob_level + band_w
ob_lo = ob_level - band_w
os_hi = os_level + band_w
os_lo = os_level - band_w


// ─────────────────────────────────────────────────────────────────────────────
//  CONFIRMATION SIGNALS  — reversal at extremes (non-repainting)
// ─────────────────────────────────────────────────────────────────────────────
n = confirm_bars

is_peak   = true
is_trough = true
for i = 0 to n - 1
    if mr[1] <= mr[i + 2] or mr[1] <= mr[i]
        is_peak := false
    if mr[1] >= mr[i + 2] or mr[1] >= mr[i]
        is_trough := false

peaked_in_ob   = require_cross ? mr[1] >= ob_lo : mr[1] >= ob_level - band_w * 2
troughed_in_os = require_cross ? mr[1] <= os_hi : mr[1] <= os_level + band_w * 2

bear_flip = is_peak   and peaked_in_ob
bull_flip = is_trough and troughed_in_os


// ─────────────────────────────────────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────────────────────────────────────
p_ob_hi = plot(ob_hi, color=na, editable=false, display=display.none)
p_ob_lo = plot(ob_lo, color=na, editable=false, display=display.none)
p_os_hi = plot(os_hi, color=na, editable=false, display=display.none)
p_os_lo = plot(os_lo, color=na, editable=false, display=display.none)

fill(p_ob_hi, p_ob_lo, color=ob_col, title="Overbought Zone")
fill(p_os_hi, p_os_lo, color=os_col, title="Oversold Zone")

hline(0, "Zero", color=color.new(color.gray, 55), linestyle=hline.style_dashed)

p_mr   = plot(mr, title="Mean Reversion", color=show_hist ? na : line_col, linewidth=2)
p_zero = plot(0, color=na, editable=false, display=display.none)
fill(p_mr, p_zero, color=show_hist ? color.new(line_col, 40) : na, title="Histogram Fill")

plotshape(bear_flip ? mr[1] : na, title="Bear Reversal", location=location.absolute, style=shape.circle, color=dot_bear, size=size.small, offset=-1)
plotshape(bull_flip ? mr[1] : na, title="Bull Reversal", location=location.absolute, style=shape.circle, color=dot_bull, size=size.small, offset=-1)


// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(bear_flip, "MeanRev Bear Flip", "Mean-Reversion: Bearish reversal from overbought zone")
alertcondition(bull_flip, "MeanRev Bull Flip", "Mean-Reversion: Bullish reversal from oversold zone")
alertcondition(bear_flip or bull_flip, "MeanRev Any Flip", "Mean-Reversion: Reversal signal fired")
````
