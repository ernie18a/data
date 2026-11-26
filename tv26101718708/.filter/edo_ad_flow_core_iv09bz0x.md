# Edo A/D Flow Core

- url: https://www.tradingview.com/script/IV09bz0X-Edo-A-D-Flow-Core/
- type: indicator
- pine_id: PUB;baeb6a8057d14a10a695a6771c8b3c8a
- version: 1.0

## Description

Edo A/D Flow Core — Normalized Accumulation/Distribution with Dual Moving Averages, Four-State Histogram and Automatic Divergence Detection

The Accumulation/Distribution Line is one of the classic flow indicators of technical analysis, originally developed by Marc Chaikin to refine the On Balance Volume reading by weighting each candle's volume contribution by where it closes within its own range. The concept is sound — flow leaves a trail before price confirms — but the indicator has three serious practical limitations: its scale depends on the ticker's accumulated history, it is not comparable across assets, and it appears visually flat over long periods.

Edo A/D Flow Core was built to address those limitations without losing the underlying logic. The indicator preserves the original A/D calculation but transforms it into a clean, zero-centered, cross-asset comparable surface where flow direction, flow acceleration and flow-vs-price divergences can be read at a glance.


THE A/D LINE FOUNDATION

Each bar contributes to the cumulative A/D series with the classic formula:

raw = ((Close − Open) / (High − Low)) × Volume

A/D = Σ raw

If the candle range is zero, the contribution is forced to zero to avoid division errors. The closer the close is to the high, the more accumulative the bar; the closer to the low, the more distributive. A close in the middle of the range produces a small contribution regardless of how much price moved.


ADAPTIVE NORMALIZATION

The cumulative A/D would otherwise live on an arbitrary scale that depends on the ticker's volume history. Edo A/D Flow Core applies a sliding zero-centered normalization on a configurable lookback window (default 90 periods):

— Identify the highest and lowest values of the A/D in the last N periods
— Compute the midpoint (max + min) / 2
— Rescale each value as a percentage from the midpoint relative to the full range:
   norm = (value − midpoint) / (range / 2) × 100

The resulting series moves within an approximate ±100 range. Values close to +100 mean flow at relative highs of the lookback window; values close to −100 mean relative lows. The same transformation is applied to the moving averages and to the histogram.

This is what makes the indicator visually comparable across tickers regardless of their history. AAPL, NVDA or a recently listed stock will all be plotted on the same homogeneous scale.


THE TWO LINES

Two moving averages are drawn over the normalized A/D:

— Fast Line — default cyan, width 2, length 9. Reactive line for short-term flow.
— Slow Line — default yellow, width 1, length 21. Reference line for background flow.

The user can choose between EMA and SMA for both. EMA is the default. The lines can be hidden individually if the user prefers to work with the histogram only.

The relationship between the two carries most of the directional information: Fast above Slow means short-term flow is more bullish than the background; Fast below Slow means the opposite; line crosses mark regime changes.


FOUR-STATE HISTOGRAM

The histogram is the difference between the two normalized lines. Unlike the standard two-color reading (green above zero, red below zero), Edo A/D Flow Core paints four explicit states:

— Bullish Strong — Solid teal — histogram ≥ 0 and greater than the previous bar (acceleration up)
— Bullish Weak — Faded teal — histogram ≥ 0 and ≤ previous bar (deceleration up)
— Bearish Strong — Solid red — histogram < 0 and less than previous bar (acceleration down)
— Bearish Weak — Faded red — histogram < 0 and ≥ previous bar (deceleration down)

This differentiation lets you anticipate regime changes before the lines actually cross. A series of Bullish Strong bars giving way to Bullish Weak bars means the bullish flow is still intact but losing inertia — the first warning of a possible bearish cross.

A dotted gray zero line is always plotted so the histogram crossing the neutral zone is visible.


AUTOMATIC DIVERGENCE DETECTION

The indicator detects and draws price-vs-flow divergences automatically using bilateral pivots on the normalized Fast line.

Bullish divergence (Bull) — Price prints a lower low than the previous one, but the Fast line prints a higher low. A green line connects both flow lows and a "Bull" label is drawn.

Bearish divergence (Bear) — Price prints a higher high, but the Fast line prints a lower high. A red line connects both flow highs and a "Bear" label is drawn.

A proximity filter ensures only divergences between pivots within a maximum distance are considered. Pivots are confirmed bilaterally with ta.pivothigh and ta.pivotlow, which guarantees no signal repaints on later bars.


SENSITIVITY PROFILE

A single input — Divergence Sensitivity — controls the divergence module. It exposes three preset profiles that adjust pivot length and proximity filter together:

— Fast — pivot length 3, search range 30. Aggressive detection, more short-term signals, more noise. Useful on intraday or short-swing charts.
— Balanced — pivot length 5, search range 60. Default configuration. Recommended for daily and weekly charts.
— Slow — pivot length 8, search range 100. Conservative detection, fewer signals but with greater potential reach. Useful on monthly charts and major divergence analysis.

Switching profile recomputes all visible divergences instantly.


CONFIGURATION

— A/D Settings: MA Type (EMA / SMA), Fast Length (default 9), Slow Length (default 21), Normalization Period (default 90)
— Display: independent toggles for Fast Line, Slow Line, Divergences and Sensitivity Profile selector
— Colors: full customization of histogram (four states), Fast Line, Slow Line, bullish and bearish divergence colors


ALERTS

The indicator does not include predefined alert conditions. Alerts are configured manually on the public plots, which gives total freedom to the user:

— Bullish line cross — alert on Fast Line, condition Crossing Up, reference Slow Line
— Bearish line cross — alert on Fast Line, condition Crossing Down, reference Slow Line
— Histogram crossing zero — alert on Histogram, condition Crossing, reference 0
— Detected divergences — alert on Bull Div Line or Bear Div Line, condition Greater than 0 or Not equal to NaN

Divergences are confirmed with a lag equal to the pivot length of the active profile (3, 5 or 8 bars). This lag is structural — no divergence detector can confirm a pivot without waiting for those bars to its right.


HOW TO READ IT

A clean reading follows four streams that combine into common patterns.

1 — Read the lines: Fast above Slow means active bullish flow; Fast below Slow means active bearish flow.

2 — Read the histogram color: Bullish Strong / Weak / Bearish Weak / Bearish Strong tell you whether flow is accelerating or decelerating in either direction without waiting for the cross.

3 — Watch for divergences: Bull and Bear labels mark the moments where flow and price disagree, which typically precede corrections or trend changes.

4 — Combine the four streams: clean bullish reactivation (histogram migrating from Bearish Weak to Bullish Strong + line cross + prior Bull divergence), bullish exhaustion (Bullish Strong becoming less frequent + flat Fast line + Bear divergence appearing), bearish capitulation (consecutive Bearish Strong bars + extreme negative Fast values + Bull divergence) and silent distribution (sideways price + histogram migrating quietly to Bearish Weak + Fast drifting below Slow).


OPEN SOURCE

Edo A/D Flow Core is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem alongside Edo EMA Core Cross, Edo Sentiment Map, Edo SuperTrend Core, Edo TRIX Core Cross, Edo RSI Dual, Edo Multi Stoch and Edo ZigZag Auto Fib SR.


This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// ███████╗██████╗  ██████╗ ██╗      █████╗ ██████╗
// ██╔════╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗
// █████╗  ██║  ██║██║   ██║██║     ███████║██████╔╝
// ██╔══╝  ██║  ██║██║   ██║██║     ██╔══██║██╔══██╗
// ███████╗██████╔╝╚██████╔╝███████╗██║  ██║██████╔╝
// ╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
// ─────────────────────────────────────────────────────────────────
// ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗███████╗
// ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝
// ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║   ╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║   ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
// ─────────────────────────────────────────────────────────────────
// © Edolab Markets


//@version=6
indicator(title="Edo A/D Flow Core", shorttitle="Edo A/D Flow Core", overlay=false)

// ================== INPUTS ==================
g_ad = "A/D Settings"
ma_type  = input.string("EMA", "MA Type", options=["EMA", "SMA"], group=g_ad)
fast_len = input.int(9,  "Fast Length", minval=1, group=g_ad)
slow_len = input.int(21, "Slow Length", minval=1, group=g_ad)
norm_len = input.int(90, "Normalization Period", minval=10, group=g_ad)

g_display = "Display"
show_fast    = input.bool(true, "Show Fast Line",   group=g_display)
show_slow    = input.bool(true, "Show Slow Line",   group=g_display)
show_div     = input.bool(true, "Show Divergences", group=g_display)
div_profile  = input.string("Balanced", "Divergence Sensitivity", options=["Fast", "Balanced", "Slow"], group=g_display)

g_colors = "Colors"
col_hist_uu = input.color(color.new(#26A69A, 0),  "Histogram — Bullish Strong", group=g_colors)
col_hist_ud = input.color(color.new(#26A69A, 50), "Histogram — Bullish Weak",   group=g_colors)
col_hist_dd = input.color(color.new(#EF5350, 0),  "Histogram — Bearish Strong", group=g_colors)
col_hist_du = input.color(color.new(#EF5350, 50), "Histogram — Bearish Weak",   group=g_colors)
col_fast    = input.color(color.new(#5B9FAD, 0),  "Fast Line",                  group=g_colors)
col_slow    = input.color(color.new(#E6B800, 0),  "Slow Line",                  group=g_colors)
col_bull    = input.color(color.green,             "Divergence — Bullish",       group=g_colors)
col_bear    = input.color(color.red,               "Divergence — Bearish",       group=g_colors)

// ================== DIVERGENCE PROFILE ==================
div_lb    = div_profile == "Fast" ? 3 : div_profile == "Balanced" ? 5 : 8
div_range = div_profile == "Fast" ? 30 : div_profile == "Balanced" ? 60 : 100

// ================== A/D CALCULATION ==================
raw = high == low ? 0.0 : ((close - open) / (high - low)) * volume
ad  = ta.cum(raw)

// ================== MA FUNCTION ==================
f_ma(src, len, type) =>
    type == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

fast_line = f_ma(ad, fast_len, ma_type)
slow_line = f_ma(ad, slow_len, ma_type)

// ================== SHARED NORMALIZATION ==================
ad_max   = ta.highest(ad, norm_len)
ad_min   = ta.lowest(ad, norm_len)
ad_range = ad_max - ad_min

f_norm(val) =>
    ad_range != 0 ? (val - (ad_max + ad_min) / 2) / (ad_range / 2) * 100 : 0.0

ad_norm   = f_norm(ad)
fast_norm = f_ma(ad_norm, fast_len, ma_type)
slow_norm = f_ma(ad_norm, slow_len, ma_type)
hist      = fast_norm - slow_norm

// ================== HISTOGRAM COLOR ==================
hist_color = hist >= 0 ? (hist > hist[1] ? col_hist_uu : col_hist_ud) : (hist < hist[1] ? col_hist_dd : col_hist_du)

// ================== PLOTS ==================
plot(hist, "Histogram", hist_color, style=plot.style_columns)
plot(show_fast ? fast_norm : na, "Fast Line", col_fast, linewidth=2)
plot(show_slow ? slow_norm : na, "Slow Line", col_slow, linewidth=1)
hline(0, "Zero Line", color.new(color.gray, 50), hline.style_dotted)

// ================== DIVERGENCES ==================
plFound = not na(ta.pivotlow(fast_norm,  div_lb, div_lb))
phFound = not na(ta.pivothigh(fast_norm, div_lb, div_lb))

prevPL_bars = ta.barssince(plFound[1])
prevPH_bars = ta.barssince(phFound[1])

inRangePL = prevPL_bars <= div_range
inRangePH = prevPH_bars <= div_range

bullCond = show_div and plFound and inRangePL and (low[div_lb] < ta.valuewhen(plFound, low[div_lb], 1)) and (fast_norm[div_lb] > ta.valuewhen(plFound, fast_norm[div_lb], 1))
bearCond = show_div and phFound and inRangePH and (high[div_lb] > ta.valuewhen(phFound, high[div_lb], 1)) and (fast_norm[div_lb] < ta.valuewhen(phFound, fast_norm[div_lb], 1))

plot(plFound ? fast_norm[div_lb] : na, "Bull Div Line", bullCond ? col_bull : na, linewidth=2, offset=-div_lb, display=display.pane)
plot(phFound ? fast_norm[div_lb] : na, "Bear Div Line", bearCond ? col_bear : na, linewidth=2, offset=-div_lb, display=display.pane)

plotshape(bullCond ? fast_norm[div_lb] : na, "Bullish Divergence", shape.labelup,   location.absolute, col_bull, offset=-div_lb, text="Bull", textcolor=color.white, size=size.tiny)
plotshape(bearCond ? fast_norm[div_lb] : na, "Bearish Divergence", shape.labeldown, location.absolute, col_bear, offset=-div_lb, text="Bear", textcolor=color.white, size=size.tiny)
````
