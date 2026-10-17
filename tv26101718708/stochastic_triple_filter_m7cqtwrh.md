# Stochastic Triple Filter

- url: https://www.tradingview.com/script/M7CqtwRh-Stochastic-Triple-Filter/
- type: indicator
- pine_id: PUB;15ae1479448b4fd0b6314279d356b605
- version: 1.0

## Description

[b]Stochastic Triple Filter [ATP][/b]

[b]Overview[/b]

The [b]Stochastic Triple Filter[/b] is an enhanced version of the classic Stochastic Oscillator designed to address its most fundamental weakness: the generation of excessive false signals during ranging markets and counter-trend conditions.

This script integrates [b]three independently validated technical analysis components[/b] into a single unified system, where each filter serves a specific and complementary role in signal validation. The result is a significant reduction in low-quality crossover signals, keeping only those that occur within a confirmed trending environment with real directional momentum.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]THE PROBLEM WITH THE CLASSIC STOCHASTIC[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

The classic Stochastic Oscillator generates crossover signals regardless of broader market context. A crossover in oversold territory looks identical whether the broader trend is strongly bullish, strongly bearish, or completely flat and ranging.

This context-blindness is the primary reason most Stochastic-based approaches underperform in live market conditions. The indicator fires during:
- Trending markets
- Ranging markets
- High-volatility periods
- Low-momentum consolidations

...treating all of them identically.

The Triple Filter addresses this by adding two additional layers of validation that specifically target the two most common failure modes:
- Trading [b]against the dominant trend[/b]
- Trading during [b]low-momentum, choppy market conditions[/b]

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]WHY THESE THREE COMPONENTS[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

The combination of the Stochastic Oscillator, the Gaussian Channel, and the Choppiness Index was chosen deliberately. Each component addresses a [b]different dimension of market behavior[/b] that the others cannot measure on their own:
- [b]Stochastic Oscillator[/b] — measures momentum and overbought/oversold conditions
- [b]Gaussian Channel[/b] — measures trend direction with minimal lag
- [b]Choppiness Index[/b] — measures whether the market is trending or ranging

Together, they form a [b]three-dimensional filter[/b] that validates signals from three independent angles simultaneously: momentum, direction, and market structure.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]COMPONENT 1: STOCHASTIC OSCILLATOR — THE SIGNAL GENERATOR[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

The Stochastic Oscillator, originally developed by [b]George Lane in the 1950s[/b], measures the position of the closing price relative to its high-low range over a defined lookback period.
- [b]%K line[/b] — the raw stochastic value
- [b]%D line[/b] — a smoothed version of %K, used as a signal line

[b]Signal rules:[/b]
- [b]Long signal[/b] — %K crosses above %D in the oversold zone (below threshold, default 20)
- [b]Short signal[/b] — %K crosses below %D in the overbought zone (above threshold, default 80)

[b]Default settings used in this script:[/b]
- %K Length: [b]21[/b]
- %K Smoothing: [b]3[/b]
- %D Smoothing: [b]5[/b]

These settings produce a smoother, less reactive version of the Stochastic compared to the classic defaults of 14, 1, and 3 — reducing the number of low-quality crossovers generated before any additional filtering is applied. All parameters are fully configurable.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]COMPONENT 2: GAUSSIAN CHANNEL — THE TREND FILTER[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

The Gaussian Channel, [b]originally developed and published on TradingView by © DonovanWall[/b], applies a recursive Gaussian filter to price data to produce an extremely smooth trend estimate.

Unlike a simple moving average, the Gaussian filter uses a [b]weighted multi-pole recursive calculation[/b] that minimizes lag while preserving directional accuracy.

[i]The f_filt9x() recursive filter function and the f_pole() pole aggregation function used in this script are directly derived from DonovanWall's original published work. All mathematical credit for the Gaussian filter implementation belongs to DonovanWall.[/i]

[b]How it works in this script:[/b]

Only the [b]midline[/b] of the Gaussian Channel is used as a trend direction signal:
- [b]Midline rising[/b] (current value > previous value) → trend is bullish → longs allowed
- [b]Midline falling[/b] (current value < previous value) → trend is bearish → shorts allowed
- If the Stochastic fires a crossover but the Gaussian Channel disagrees → [b]signal is blocked[/b]

[b]Optional modes:[/b]
- [b]Reduced Lag Mode[/b] — applies a lag correction to the source before filtering, making trend detection more reactive
- [b]Fast Response Mode[/b] — blends the filtered output with the first-pole result to increase responsiveness at the cost of some smoothness

Both modes are optional and [b]disabled by default[/b].

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]COMPONENT 3: CHOPPINESS INDEX — THE MOMENTUM FILTER[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

The Choppiness Index, based on the concept originally introduced by [b]E.W. Dreiss in 1993[/b], measures the degree of market trendiness versus choppiness by comparing the sum of individual candle true ranges to the total true range over a lookback period.

The formula produces a normalized value:
- [b]Lower values (~38.2)[/b] → strong directional trending behavior
- [b]Higher values (~100)[/b] → choppy, non-directional price action

[b]How it works in this script:[/b]

A user-configurable threshold (default [b]50[/b]) defines the boundary:
- Choppiness Index [b]below threshold[/b] → market is trending → signals allowed
- Choppiness Index [b]above threshold[/b] → market is choppy → [b]all signals blocked[/b], regardless of Stochastic crossover or Gaussian Channel direction

This prevents trading during low-momentum consolidation periods — historically the most damaging environment for crossover-based systems.

The Choppiness Index filter can be [b]independently enabled or disabled[/b] by the user.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]HOW THE THREE COMPONENTS WORK TOGETHER[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

[b]Valid LONG signal requires all three:[/b]
- %K crosses above %D within the oversold zone
- Gaussian Channel midline is [b]rising[/b]
- Choppiness Index is [b]below the threshold[/b]

[b]Valid SHORT signal requires all three:[/b]
- %K crosses below %D within the overbought zone
- Gaussian Channel midline is [b]falling[/b]
- Choppiness Index is [b]below the threshold[/b]

Crossovers that satisfy the Stochastic condition but fail one or both additional filters are displayed as [b]small white cross markers[/b] on the panel — allowing traders to observe exactly which signals were blocked and why.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]VISUAL ELEMENTS AND PANEL LAYOUT[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

[b]Inside the indicator panel:[/b]
- [b]%K line[/b] — changes color dynamically: green in oversold zone, red in overbought zone, grey in neutral zone. Color intensity is proportional to the distance from each threshold.
- [b]%D line[/b] — follows the same color logic at reduced opacity.
- [b]Overbought/Oversold lines[/b] — horizontal dashed lines at configurable thresholds.
- [b]Midline[/b] — dotted line at level 50.
- [b]Zone background[/b] — faint green when %K is oversold, faint red when overbought.
- [b]Gaussian Channel dots[/b] — a row of colored circles below the Stochastic lines: green when rising, red when falling, grey when flat.
- [b]Choppiness line[/b] — a horizontal line just below the GC dots: green when market is trending (below threshold), grey when choppy (above threshold).
- [b]Signal triangles[/b] — green upward triangles for valid longs, red downward triangles for valid shorts.
- [b]Filtered signal markers[/b] — small white crosses for signals blocked by the GC or Choppiness filters.
- [b]Status table[/b] — bottom right corner, updated in real time, showing the current state of all three filters simultaneously.

[b]On the price chart (optional):[/b]
- [b]BUY/SELL labels[/b] — appear directly on the price chart at the moment of each valid signal using force_overlay.
- [b]Bar color[/b] — candles colored according to Gaussian Channel direction and Choppiness state: bright green when trending up, bright red when trending down, grey when choppy.
- [b]Background flash[/b] — optional faint background highlight on the price chart at signal bars.

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]SETTINGS AND INPUTS[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

[b]⚙️ Stochastic:[/b]
- %K Length (default: 21)
- %K Smoothing (default: 3)
- %D Smoothing (default: 5)
- Overbought Level (default: 80)
- Oversold Level (default: 20)

[b]📡 Gaussian Channel:[/b]
- Enable/Disable GC Filter
- Source (default: HLC3)
- Poles 1–9 (default: 4)
- Sampling Period (default: 144)
- Multiplier (default: 1.414)
- Reduced Lag Mode
- Fast Response Mode

[b]📊 Choppiness Index:[/b]
- Enable/Disable Chop Filter
- Chop Length (default: 14)
- Chop Threshold (default: 50)

[b]📍 Signals on Price Chart:[/b]
- Show BUY/SELL labels on chart
- Show Filter Status Table
- Color bars by signal state

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]CREDITS AND ATTRIBUTIONS[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

- [b]Gaussian Channel[/b] — Original concept and full implementation by [b]© DonovanWall[/b], published on TradingView as [i]"Gaussian Channel [DW]"[/i]. The f_filt9x() and f_pole() functions in this script are directly derived from DonovanWall's original work. All mathematical credit belongs to DonovanWall.
- [b]Choppiness Index[/b] — Original concept by [b]E.W. Dreiss (1993)[/b]. Standard public domain implementation.
- [b]Stochastic Oscillator[/b] — Original concept by [b]George Lane (1950s)[/b]. Standard public domain implementation.

The combination of these three components into a unified signal filtering system — including all visual design, panel layout, filter logic, position management, and status table — was developed independently by [b]© AlgoTrade_Pro[/b].

[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]
[b]DISCLAIMER[/b]
[b]━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[/b]

[i]This script is published for educational and informational purposes only. It is not financial advice and does not guarantee any specific trading results. Past performance in backtesting does not guarantee future results in live markets. Always conduct your own research and testing before making any trading decisions. Trading involves significant risk of loss.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © AlgoTrade_Pro

// ─────────────────────────────────────────────────────────────────
// CREDITS & ATTRIBUTION
// ─────────────────────────────────────────────────────────────────
// Gaussian Channel Filter:
//   Original concept and implementation by © DonovanWall
//   Published on TradingView as "Gaussian Channel [DW]"
//   The f_filt9x() and f_pole() functions used in this script
//   are directly derived from DonovanWall's original work.
//   All credit for the Gaussian filter mathematics belongs to him.
//
// Choppiness Index:
//   Original concept by E.W. Dreiss (1993)
//   Standard public domain implementation
//
// Stochastic Oscillator:
//   Original concept by George Lane (1950s)
//   Standard public domain implementation
//
// This script combines the above components into a unified
// signal filtering system developed by © AlgoTrade_Pro.
// ─────────────────────────────────────────────────────────────────

//@version=6
indicator("Stochastic Triple Filter [ATP]", shorttitle="STF [ATP]", overlay=false)

//──────────────────────────
// INPUTS — STOCHASTIC
//──────────────────────────
var g_stoch = "⚙️ Stochastic"
periodK = input.int(21, "%K Length",
     tooltip="Number of bars used to calculate the raw Stochastic value. Higher = smoother but more lag. Default: 21.",
     minval=1, group=g_stoch)
smoothK = input.int(3,  "%K Smoothing",
     tooltip="Smoothing applied to the %K line via SMA. Higher = fewer false crossovers. Default: 3.",
     minval=1, group=g_stoch)
periodD = input.int(5,  "%D Smoothing",
     tooltip="Smoothing applied to %D (signal line). %D is the SMA of %K. Default: 5.",
     minval=1, group=g_stoch)
obLevel = input.int(80, "Overbought",
     tooltip="Level above which the market is considered overbought. Short signals are only valid when %K crosses down from above this level. Default: 80.",
     minval=50, maxval=99, group=g_stoch)
osLevel = input.int(20, "Oversold",
     tooltip="Level below which the market is considered oversold. Long signals are only valid when %K crosses up from below this level. Default: 20.",
     minval=1, maxval=50, group=g_stoch)

//──────────────────────────
// INPUTS — GAUSSIAN CHANNEL
//──────────────────────────
var g_gc = "📡 Gaussian Channel"
useGC    = input.bool(true,   "Enable GC Filter",
     tooltip="When enabled, signals are only valid if the Gaussian Channel midline agrees with the direction — green (rising) for longs, red (falling) for shorts. Disabling allows all Stochastic crossovers through.",
     group=g_gc)
src      = input.source(hlc3, "Source",
     tooltip="Price source used to calculate the Gaussian Channel. Default: HLC3 (typical price).",
     group=g_gc)
N        = input.int(4,       "Poles",
     tooltip="Number of filter poles (1–9). Higher poles = smoother but more lag. 4 is the recommended default for a good balance of smoothness and responsiveness.",
     minval=1, maxval=9, group=g_gc)
per      = input.int(144,     "Sampling Period",
     tooltip="Lookback period for the Gaussian filter. Higher = slower trend detection. Default: 144 (works well on most timeframes).",
     minval=2, group=g_gc)
mult     = input.float(1.414, "Multiplier",
     tooltip="Multiplier for the filtered true range bands. Does not affect the signal logic — only the visual bands if plotted. Default: 1.414 (√2).",
     minval=0, step=0.1, group=g_gc)
modeLag  = input.bool(false,  "Reduced Lag Mode",
     tooltip="Reduces lag by applying a correction to the source before filtering. Makes the indicator more reactive but can introduce noise.",
     group=g_gc)
modeFast = input.bool(false,  "Fast Response Mode",
     tooltip="Blends the filtered output with the first pole result for a faster but less smooth signal. Use on lower timeframes if signals feel too slow.",
     group=g_gc)

//──────────────────────────
// INPUTS — CHOPPINESS INDEX
//──────────────────────────
var g_chop    = "📊 Choppiness Index"
useChop       = input.bool(true, "Use Chop Filter",
     tooltip="When enabled, signals are blocked during choppy/ranging markets. The Choppiness Index measures how trending vs ranging the market is — values below the threshold mean the market is trending and signals are allowed through.",
     group=g_chop)
chopLength    = input.int(14,    "Chop Length",
     tooltip="Number of bars used to calculate the Choppiness Index. Higher = smoother reading of market condition. Default: 14.",
     minval=1, group=g_chop)
chopThreshold = input.int(50,    "Chop Threshold",
     tooltip="The boundary between trending and choppy markets. Below this value = trending (signals allowed, green bars shown). Above = choppy/ranging (signals blocked, grey bars shown). Classic threshold is 61.8 — we use 50 for a stricter filter.",
     minval=1, maxval=100, group=g_chop)


//──────────────────────────
// INPUTS — SIGNALS ON CHART
//──────────────────────────
var g_overlay = "📍 Signals on Price Chart"
showOverlay = input.bool(true, "Show BUY/SELL on Chart",
     tooltip="When enabled, BUY and SELL labels appear directly on the price chart with a background flash on the signal bar.",
     group=g_overlay)
showTable = input.bool(true, "Show Filter Status Table",
     tooltip="Shows a table in the bottom-right corner of the panel with the current state of each filter (GC, Chop, Stochastic).",
     group=g_overlay)
showBarColor = input.bool(true, "Color Bars by Signal State",
     tooltip="Colors the price chart candles based on the current state of all filters. Green = all filters aligned for long. Red = all aligned for short. Grey = choppy or no signal.",
     group=g_overlay)


//──────────────────────────
// GAUSSIAN CHANNEL — DonovanWall exact implementation
//──────────────────────────
f_filt9x(_a, _s, _i) =>
    int _m2 = 0
    int _m3 = 0
    int _m4 = 0
    int _m5 = 0
    int _m6 = 0
    int _m7 = 0
    int _m8 = 0
    int _m9 = 0
    float _f = .0
    _x = 1 - _a
    _m2 := _i == 9 ? 36 : _i == 8 ? 28 : _i == 7 ? 21 : _i == 6 ? 15 : _i == 5 ? 10 : _i == 4 ? 6 : _i == 3 ? 3 : _i == 2 ? 1 : 0
    _m3 := _i == 9 ? 84 : _i == 8 ? 56 : _i == 7 ? 35 : _i == 6 ? 20 : _i == 5 ? 10 : _i == 4 ? 4 : _i == 3 ? 1 : 0
    _m4 := _i == 9 ? 126 : _i == 8 ? 70 : _i == 7 ? 35 : _i == 6 ? 15 : _i == 5 ? 5 : _i == 4 ? 1 : 0
    _m5 := _i == 9 ? 126 : _i == 8 ? 56 : _i == 7 ? 21 : _i == 6 ? 6 : _i == 5 ? 1 : 0
    _m6 := _i == 9 ? 84 : _i == 8 ? 28 : _i == 7 ? 7 : _i == 6 ? 1 : 0
    _m7 := _i == 9 ? 36 : _i == 8 ? 8 : _i == 7 ? 1 : 0
    _m8 := _i == 9 ? 9 : _i == 8 ? 1 : 0
    _m9 := _i == 9 ? 1 : 0
    _f := math.pow(_a, _i) * nz(_s) + _i * _x * nz(_f[1]) - (_i >= 2 ? _m2 * math.pow(_x, 2) * nz(_f[2]) : 0) + (_i >= 3 ? _m3 * math.pow(_x, 3) * nz(_f[3]) : 0) - (_i >= 4 ? _m4 * math.pow(_x, 4) * nz(_f[4]) : 0) + (_i >= 5 ? _m5 * math.pow(_x, 5) * nz(_f[5]) : 0) - (_i >= 6 ? _m6 * math.pow(_x, 6) * nz(_f[6]) : 0) + (_i >= 7 ? _m7 * math.pow(_x, 7) * nz(_f[7]) : 0) - (_i >= 8 ? _m8 * math.pow(_x, 8) * nz(_f[8]) : 0) + (_i == 9 ? _m9 * math.pow(_x, 9) * nz(_f[9]) : 0)
    _f

f_pole(_a, _s, _i) =>
    _f1 = f_filt9x(_a, _s, 1)
    _f2 = _i >= 2 ? f_filt9x(_a, _s, 2) : 0
    _f3 = _i >= 3 ? f_filt9x(_a, _s, 3) : 0
    _f4 = _i >= 4 ? f_filt9x(_a, _s, 4) : 0
    _f5 = _i >= 5 ? f_filt9x(_a, _s, 5) : 0
    _f6 = _i >= 6 ? f_filt9x(_a, _s, 6) : 0
    _f7 = _i >= 2 ? f_filt9x(_a, _s, 7) : 0
    _f8 = _i >= 8 ? f_filt9x(_a, _s, 8) : 0
    _f9 = _i == 9 ? f_filt9x(_a, _s, 9) : 0
    _fn = _i == 1 ? _f1 : _i == 2 ? _f2 : _i == 3 ? _f3 : _i == 4 ? _f4 : _i == 5 ? _f5 : _i == 6 ? _f6 : _i == 7 ? _f7 : _i == 8 ? _f8 : _i == 9 ? _f9 : na
    [_fn, _f1]

beta    = (1 - math.cos(4 * math.asin(1) / per)) / (math.pow(1.414, 2.0 / N) - 1)
alpha   = -beta + math.sqrt(math.pow(beta, 2) + 2 * beta)
lag     = int((per - 1) / (2 * N))
srcdata = modeLag ? src + src - src[lag] : src
trdata  = modeLag ? ta.tr(true) + ta.tr(true) - ta.tr(true)[lag] : ta.tr(true)

[filtn, filt1]     = f_pole(alpha, srcdata, N)
[filtntr, filt1tr] = f_pole(alpha, trdata, N)

filt   = modeFast ? (filtn + filt1) / 2 : filtn
filttr = modeFast ? (filtntr + filt1tr) / 2 : filtntr

gc_up   = filt > filt[1]
gc_down = filt < filt[1]

//──────────────────────────
// CHOPPINESS INDEX
//──────────────────────────
highestHiChop = ta.highest(high, chopLength)
lowestLoChop  = ta.lowest(low,   chopLength)
rangeChop     = highestHiChop - lowestLoChop
choppiness    = rangeChop != 0 ? 100 * math.log10(math.sum(ta.atr(1), chopLength) / rangeChop) / math.log10(chopLength) : 100
marketTrending = choppiness < chopThreshold

//──────────────────────────
// STOCHASTIC
//──────────────────────────
k = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
d = ta.sma(k, periodD)

in_ob   = k >= obLevel
in_os   = k <= osLevel
in_zone = in_ob or in_os

//──────────────────────────
// SIGNAL LOGIC
//──────────────────────────
long_raw  = ta.crossover(k, d) and in_os
short_raw = ta.crossunder(k, d) and in_ob

long_signal  = long_raw  and (not useGC or gc_up)   and (not useChop or marketTrending)
short_signal = short_raw and (not useGC or gc_down) and (not useChop or marketTrending)

long_filtered  = long_raw  and not long_signal
short_filtered = short_raw and not short_signal

//──────────────────────────
// COLORS
//──────────────────────────
k_pct_os = osLevel > 0         ? math.max(0.0, math.min(1.0, (osLevel - k) / osLevel))            : 0.0
k_pct_ob = (100 - obLevel) > 0 ? math.max(0.0, math.min(1.0, (k - obLevel) / (100 - obLevel)))   : 0.0

k_transp = in_os ? int(80 * (1 - k_pct_os)) : in_ob ? int(80 * (1 - k_pct_ob)) : 80
d_transp = in_os ? int(80 * (1 - k_pct_os)) + 20 : in_ob ? int(80 * (1 - k_pct_ob)) + 20 : 85

k_col = in_os ? color.new(#00C087, math.min(k_transp, 70)) : in_ob ? color.new(#FF4560, math.min(k_transp, 70)) : color.new(#787878, 55)
d_col = in_os ? color.new(#00C087, math.min(d_transp, 80)) : in_ob ? color.new(#FF4560, math.min(d_transp, 80)) : color.new(#787878, 70)

hist = k - d

f_hist_col(_h, _zone) =>
    if _h > 0
        if _zone
            _h >= _h[1] ? color.new(#00C087, 0) : color.new(#00C087, 45)
        else
            _h >= _h[1] ? color.new(#787878, 30) : color.new(#787878, 55)
    else
        if _zone
            _h <= _h[1] ? color.new(#FF4560, 0) : color.new(#FF4560, 45)
        else
            _h <= _h[1] ? color.new(#787878, 30) : color.new(#787878, 55)

hist_col   = f_hist_col(hist, in_zone)
gc_dot_col = gc_up ? color.new(#00C087, 0) : gc_down ? color.new(#FF4560, 0) : color.new(#787878, 60)

//──────────────────────────
// ZONE BACKGROUND
//──────────────────────────
zone_bg = in_ob ? color.new(#FF4560, 92) : in_os ? color.new(#00C087, 92) : color.new(#787878, 98)
bgcolor(zone_bg, title="Zone Background")

//──────────────────────────
// PLOTS
//──────────────────────────
plot(k, "%K", color=k_col, linewidth=2)
plot(d, "%D", color=d_col, linewidth=1)

h_ob = hline(obLevel, "Overbought", color=color.new(#FF4560, 55), linestyle=hline.style_dashed)
h_os = hline(osLevel, "Oversold",   color=color.new(#00C087, 55), linestyle=hline.style_dashed)
hline(50, "Midline", color=color.new(#787878, 70), linestyle=hline.style_dotted)
fill(h_ob, h_os, color=color.rgb(120, 123, 134, 94), title="Band Fill")

// GC state dots — row at osLevel - 28
gc_dot_y = osLevel - 28
plot(useGC ? gc_dot_y : na, "GC State", color=gc_dot_col, linewidth=6, style=plot.style_circles)

// Chop line — row below GC dots at osLevel - 36
chop_line_y   = osLevel - 36
chop_line_col = useChop and marketTrending     ? color.new(#00C087, 10) : useChop and not marketTrending ? color.new(#787878, 50) : na
plot(useChop ? chop_line_y : na, "Chop State", color=chop_line_col, linewidth=6, style=plot.style_line)

// Signal arrows
plotshape(long_signal  ? osLevel - 7 : na, "Long Signal",
     style=shape.triangleup, location=location.absolute,
     color=color.new(#00C087, 0), size=size.small)

plotshape(short_signal ? obLevel + 7 : na, "Short Signal",
     style=shape.triangledown, location=location.absolute,
     color=color.new(#FF4560, 0), size=size.small)

plotshape(long_filtered  ? osLevel - 4 : na, "Long Filtered",
     style=shape.xcross, location=location.absolute,
     color=color.white, size=size.tiny)

plotshape(short_filtered ? obLevel + 4 : na, "Short Filtered",
     style=shape.xcross, location=location.absolute,
     color=color.white, size=size.tiny)

//──────────────────────────
// STATUS TABLE
//──────────────────────────
var table status_tbl = table.new(position.bottom_right, 2, 4,
     bgcolor=color.new(#1a1a2e, 10),
     border_color=color.new(#787878, 60),
     border_width=1,
     frame_color=color.new(#787878, 50),
     frame_width=1)

if barstate.islast and showTable
    table.cell(status_tbl, 0, 0, "FILTER",
         text_color=color.new(#787878, 0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 0), text_halign=text.align_left)
    table.cell(status_tbl, 1, 0, "STATUS",
         text_color=color.new(#787878, 0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 0), text_halign=text.align_center)

    gc_status_txt = gc_up ? "▲ Uptrend" : gc_down ? "▼ Downtrend" : "── Neutral"
    gc_status_col = gc_up ? color.new(#00C087, 0) : gc_down ? color.new(#FF4560, 0) : color.new(#787878, 0)
    table.cell(status_tbl, 0, 1, "Gaussian Channel",
         text_color=color.new(#cccccc, 0), text_size=size.small,
         bgcolor=color.new(#111122, 0), text_halign=text.align_left)
    table.cell(status_tbl, 1, 1, useGC ? gc_status_txt : "OFF",
         text_color=useGC ? gc_status_col : color.new(#787878, 40),
         text_size=size.small, bgcolor=color.new(#111122, 0), text_halign=text.align_center)

    chop_status_txt = marketTrending ? "✔ Trending" : "✖ Choppy"
    chop_status_col = marketTrending ? color.new(#00C087, 0) : color.new(#FF4560, 0)
    table.cell(status_tbl, 0, 2, "Choppiness Index",
         text_color=color.new(#cccccc, 0), text_size=size.small,
         bgcolor=color.new(#0d0d1a, 0), text_halign=text.align_left)
    table.cell(status_tbl, 1, 2, useChop ? chop_status_txt : "OFF",
         text_color=useChop ? chop_status_col : color.new(#787878, 40),
         text_size=size.small, bgcolor=color.new(#0d0d1a, 0), text_halign=text.align_center)

    stoch_status_txt = in_os ? "↑ Oversold" : in_ob ? "↓ Overbought" : "── Neutral"
    stoch_status_col = in_os ? color.new(#00C087, 0) : in_ob ? color.new(#FF4560, 0) : color.new(#787878, 0)
    table.cell(status_tbl, 0, 3, "Stochastic",
         text_color=color.new(#cccccc, 0), text_size=size.small,
         bgcolor=color.new(#111122, 0), text_halign=text.align_left)
    table.cell(status_tbl, 1, 3, stoch_status_txt,
         text_color=stoch_status_col, text_size=size.small,
         bgcolor=color.new(#111122, 0), text_halign=text.align_center)

//──────────────────────────
// BAR COLOR ON PRICE CHART
//──────────────────────────
// Bar color — SFX style
// Choppy (chop > threshold): all grey
// Trending + GC up: greens (bright if above filt, dark if below)
// Trending + GC down: reds (dark if above filt, bright if below)
bar_col =
     not marketTrending ? color.new(#787878, 0) :  // choppy — grey
     gc_up              ? color.new(#0aff68, 0)  :  // uptrend — bright green
     gc_down            ? color.new(#ff0a5a, 0)  :  // downtrend — bright red
                          color.new(#787878, 0)     // neutral

// barcolor colors body + wicks + borders uniformly
// Note: disable barcolor on GC [DW] indicator to avoid conflicts
barcolor(showBarColor ? bar_col : na, title="Bar Color")

//──────────────────────────
// OVERLAY SIGNALS ON PRICE CHART
//──────────────────────────
plotshape(showOverlay and long_signal,  "BUY Label",  shape.triangleup,   location.bottom, color.lime,      0, "",  chart.fg_color, true, size.tiny,  force_overlay=true)
plotshape(showOverlay and short_signal, "SELL Label", shape.triangledown, location.top,    color.red,       0, "", chart.fg_color, true, size.tiny,  force_overlay=true)
bgcolor(showOverlay and long_signal  ? color.new(color.lime, 90) : na, force_overlay=true, title="Buy Flash")
bgcolor(showOverlay and short_signal ? color.new(color.red,  90) : na, force_overlay=true, title="Sell Flash")

//──────────────────────────
// ALERTS
//──────────────────────────
alertcondition(long_signal,  title="Long",  message="Stochastic Triple Filter [ATP] — Long on {{ticker}} / {{interval}}")
alertcondition(short_signal, title="Short", message="Stochastic Triple Filter [ATP] — Short on {{ticker}} / {{interval}}")
````
