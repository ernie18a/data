# Sigma Structure [RWCS]

- url: https://www.tradingview.com/script/JVy0ZijS-Sigma-Structure-RWCS/
- type: indicator
- pine_id: PUB;13cd7c80ceae4fc49d4073e46a20617c
- version: 1.0

## Description

[b]What it is:[/b]

Sigma Structure is a confluence-based trading indicator that unifies three distinct analytical layers into a single, cohesive view: a Z-Score oscillator measuring price deviation from its 20 EMA, a normalized MACD histogram for momentum context, and an Order Block detection engine that identifies structural demand and supply zones directly on the price chart. The result is an indicator that tells you not just when price is statistically extended, but where that extension is occurring relative to meaningful price structure — giving every signal a location and every location a statistical weight.

[b]How it works:[/b]

1. [b]Z-Score layer:[/b] Price is measured as the number of standard deviations it sits above or below its 20-period EMA. This produces an oscillator that reads consistently across any asset or timeframe — a reading of +2 on Bitcoin means the same thing structurally as +2 on the S&P or EURUSD. The line color intensifies from faded to full aqua as it moves above zero, and faded to full fuchsia below, so the degree of extension is immediately legible at a glance. Fixed bands at ±1, ±2, and ±3 sigma define the statistical landscape.

2. [b]MACD layer:[/b] A standard MACD histogram is computed normally, then linearly scaled so its rolling peak aligns with the ±3σ band. No calculation is modified — only the display axis is shared with the Z-Score. This means crossovers, divergences, and momentum shifts read identically to a standard MACD, but now live in the same visual space as the bands, letting you see momentum and mean-reversion context simultaneously.

3. [b]Order Block layer:[/b] The indicator scans for order blocks using a sequential candle method — a bearish candle followed by a configurable number of consecutive bullish candles (demand), or a bullish candle followed by consecutive bearish candles (supply). Detected zones are drawn directly on the price chart as shaded regions with solid top boundaries and dashed bottom boundaries, color-coded aqua for demand and fuchsia for supply. Zones extend rightward bar by bar and self-invalidate the moment price closes through them, so what you see on the chart is always live and relevant.

4. [b]Confluence signals:[/b] Two signal types fire when the Z-Score and Order Block layers align. An OB Reversal label appears when price is inside an Order Block while the Z-Score is at or beyond ±2σ — the statistical extension and the structural level are confirming each other as a fade opportunity. An OB Continuation label appears when price pulls back into an Order Block and the Z-Score reclaims zero — the trend is reasserting after a mean-reversion dip into demand or supply.

5. [b]Volatility divergence:[/b] A background highlight layer compares price's rolling highs and lows against the rolling highs and lows of realized volatility (standard deviation of log returns). When price makes a new low without a corresponding expansion in realized volatility, a bullish divergence is flagged. The inverse flags bearish divergence. These are not entry signals on their own — they indicate moments where price action and volatility are telling different stories and warrant closer attention.

[b]Possible ways to use it:[/b]

1. [b]Reversal setups:[/b] When the Z-Score reaches ±2σ or beyond and price simultaneously tags an active Order Block zone, the statistical extension and structural level are aligned. The OB Reversal label marks these bars. Look for MACD histogram compression or a zero cross in the same window for additional confirmation before acting.

2. [b]Trend continuation entries:[/b] In trending markets, price frequently pulls back into demand or supply zones and finds support exactly where it should. When the Z-Score crosses back through zero inside an active zone, the OB Continuation label fires — this is your structural retest with momentum confirmation.

3. [b]Divergence as a filter:[/b] The volatility divergence highlights flag potential exhaustion in price moves that lack volatility confirmation. Use these as a reason to tighten risk or wait for the OB/Z-Score confluence before entering, rather than chasing the move.

4. [b]EMA trend bias:[/b] The fast and slow EMA overlay on the price chart provides a quick structural read. Aligning your OB Reversal or Continuation signals in the direction of the EMA cross adds a higher-timeframe trend filter without requiring a second indicator.

5. [b]Alert-driven scanning:[/b] Three configurable alerts cover the ±2σ Trade Zone cross, OB Reversal confluence, and OB Continuation setup. Set these across a watchlist to surface actionable conditions without manual chart monitoring.

[b]Settings guide:[/b]

1. [b]EMA / Std Dev Length:[/b] Both default to 20, matching a standard Bollinger Band configuration. Increase for smoother, slower signals on higher timeframes.

2. [b]MACD Norm Lookback:[/b] Controls how far back the indicator looks to find the MACD histogram's peak for scaling. Higher values produce more stable scaling; lower values make the histogram more reactive to recent momentum.

3. [b]Sequential Candles for OB:[/b] The number of consecutive candles required after the origin candle to confirm a block. Higher values produce fewer, higher-quality zones.

4. [b]Max Active Zones:[/b] How many demand and supply zones can coexist on each side. Older zones are removed when the limit is reached.

5. [b]Divergence Lookback:[/b] The rolling window for comparing price extremes against volatility extremes. Shorter values produce more frequent signals; longer values are more selective.

[b]Disclaimer:[/b]

[i]This indicator is published for educational and informational purposes only. Nothing presented here constitutes financial advice, a solicitation, or a recommendation to buy or sell any financial instrument. All trading involves risk, including the possible loss of principal. Past performance of any indicator or methodology is not indicative of future results. You are solely responsible for your own trading decisions. Always conduct your own research and consult a qualified financial professional before making any investment decisions.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RWCS_LTD

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RWCS_LTD

//@version=6
indicator("Sigma Structure [RWCS]", overlay=false, max_labels_count=100)

// ─── Groups ──────────────────────────────────────────────────
var string G1 = "Core"
var string G2 = "MACD"
var string G3 = "Order Blocks"
var string G4 = "Divergence"
var string G5 = "Display"

// ─── Inputs ──────────────────────────────────────────────────
src       = input.source(close,  "Source",                        group=G1)
ema_len   = input.int(20,        "EMA Length",                    group=G1, minval=1)
std_len   = input.int(20,        "Std Dev Lookback",              group=G1, minval=2)
show_cont = input.bool(true,  "Show Continuation Signals",       group=G2)
show_ob   = input.bool(true,  "Show Order Block Signals",       group=G2)

macd_fast  = input.int(12,      "Fast Length",                   group=G2, minval=1)
macd_slow  = input.int(26,      "Slow Length",                   group=G2, minval=1)
macd_sig   = input.int(9,       "Signal Length",                 group=G2, minval=1)
norm_len   = input.int(100,     "MACD Norm Lookback",            group=G2, minval=10)
show_lines = input.bool(false,  "Show MACD Line + Signal",       group=G2)

ob_periods   = input.int(3,     "Sequential Candles for OB",     group=G3, minval=1)
ob_threshold = input.float(0.0, "% Move After OB",               group=G3, step=0.1)
ob_wicks     = input.bool(false,"Use Wicks for Zone Boundaries", group=G3)
max_zones    = input.int(5,     "Max Active Zones (each side)",  group=G3, minval=1, maxval=10)

div_lb   = input.int(100,       "Divergence Lookback",           group=G4, minval=10)
show_div = input.bool(true,     "Show Divergence Highlights",    group=G4)

show_ema_overlay = input.bool(true, "Show Fast/Slow EMA on Chart", group=G5)
ema_fast_len     = input.int(20,    "Fast EMA (overlay)",          group=G5, minval=1)
ema_slow_len     = input.int(50,    "Slow EMA (overlay)",          group=G5, minval=1)

// ─── Palette ─────────────────────────────────────────────────
c_up   = color.aqua
c_down = color.fuchsia

// ─── Z-Score ─────────────────────────────────────────────────
ema20 = ta.ema(src, ema_len)
sigma = ta.stdev(src, std_len)
z     = sigma != 0 ? (src - ema20) / sigma : 0.0

z_col = z >= 3  ? color.new(c_up,    0) :
         z <= -3 ? color.new(c_down,  0) :
         z >= 2  ? color.new(c_up,   30) :
         z <= -2 ? color.new(c_down, 30) :
         z >= 1  ? color.new(c_up,   50) :
         z <= -1 ? color.new(c_down, 50) :
         z >= 0  ? color.new(c_up,   75) :
                  color.new(c_down, 75)

// ─── MACD ────────────────────────────────────────────────────
[macd_l, sig_l, hist] = ta.macd(src, macd_fast, macd_slow, macd_sig)
peak  = ta.highest(math.abs(hist), norm_len)
h_sc  = peak > 0 ? (hist   / peak) * 3 : 0.0
ml_sc = peak > 0 ? (macd_l / peak) * 3 : 0.0
sl_sc = peak > 0 ? (sig_l  / peak) * 3 : 0.0

hist_col = h_sc >= 0
     ? (h_sc >= h_sc[1] ? color.new(c_up,   50) : color.new(c_up,  75))
     : (h_sc <= h_sc[1] ? color.new(c_down, 50) : color.new(c_down,75))

// ─── Divergence ──────────────────────────────────────────────
ret      = math.log(close / close[1])
vol      = ta.stdev(ret, div_lb)
lowest   = ta.lowest(vol[1], div_lb)
highest  = ta.highest(vol[1], div_lb)
bull_div = (low  < ta.lowest(low[1],   div_lb)) and not (vol < lowest)
bear_div = (high > ta.highest(high[1], div_lb)) and not (vol > highest)

// ─── Order Block Detection ────────────────────────────────────
ob_period = ob_periods + 1
absmove   = math.abs(close[ob_period] - close[1]) / close[ob_period] * 100
relmove   = absmove >= ob_threshold

int up_count = 0
for i = 1 to ob_periods
    up_count += close[i] > open[i] ? 1 : 0
bool OB_bull = close[ob_period] < open[ob_period] and up_count == ob_periods and relmove

int dn_count = 0
for i = 1 to ob_periods
    dn_count += close[i] < open[i] ? 1 : 0
bool OB_bear = close[ob_period] > open[ob_period] and dn_count == ob_periods and relmove

float bull_ob_top = OB_bull ? (ob_wicks ? high[ob_period] : open[ob_period]) : na
float bull_ob_bot = OB_bull ? low[ob_period] : na
float bear_ob_top = OB_bear ? high[ob_period] : na
float bear_ob_bot = OB_bear ? (ob_wicks ? low[ob_period] : open[ob_period]) : na

// ─── Multi-Zone Arrays ────────────────────────────────────────
var line[]     d_tops  = array.new_line()
var line[]     d_bots  = array.new_line()
var linefill[] d_fills = array.new_linefill()
var float[]    d_top_v = array.new_float()
var float[]    d_bot_v = array.new_float()

var line[]     s_tops  = array.new_line()
var line[]     s_bots  = array.new_line()
var linefill[] s_fills = array.new_linefill()
var float[]    s_top_v = array.new_float()
var float[]    s_bot_v = array.new_float()

// ─── Helper Functions ─────────────────────────────────────────
purge_demand(int i) =>
    line.delete(array.get(d_tops,  i))
    line.delete(array.get(d_bots,  i))
    linefill.delete(array.get(d_fills, i))
    array.remove(d_tops,  i)
    array.remove(d_bots,  i)
    array.remove(d_fills, i)
    array.remove(d_top_v, i)
    array.remove(d_bot_v, i)

purge_supply(int i) =>
    line.delete(array.get(s_tops,  i))
    line.delete(array.get(s_bots,  i))
    linefill.delete(array.get(s_fills, i))
    array.remove(s_tops,  i)
    array.remove(s_bots,  i)
    array.remove(s_fills, i)
    array.remove(s_top_v, i)
    array.remove(s_bot_v, i)

// ─── Extend All Active Lines Rightward ───────────────────────
if array.size(d_tops) > 0
    for i = 0 to array.size(d_tops) - 1
        line.set_x2(array.get(d_tops, i), bar_index + 1)
        line.set_x2(array.get(d_bots, i), bar_index + 1)

if array.size(s_tops) > 0
    for i = 0 to array.size(s_tops) - 1
        line.set_x2(array.get(s_tops, i), bar_index + 1)
        line.set_x2(array.get(s_bots, i), bar_index + 1)

// ─── Invalidate Breached Zones ────────────────────────────────
if array.size(d_bot_v) > 0
    for i = array.size(d_bot_v) - 1 to 0
        if close < array.get(d_bot_v, i)
            purge_demand(i)

if array.size(s_top_v) > 0
    for i = array.size(s_top_v) - 1 to 0
        if close > array.get(s_top_v, i)
            purge_supply(i)

// ─── Register New Demand Zone ─────────────────────────────────
if OB_bull
    top = bull_ob_top
    bot = bull_ob_bot
    tl = line.new(bar_index - ob_period, top, bar_index + 1, top,
         color=color.new(c_up, 50), width=2, force_overlay=true)
    bl = line.new(bar_index - ob_period, bot, bar_index + 1, bot,
         color=color.new(c_up, 50), width=2,
         style=line.style_dashed, force_overlay=true)
    lf = linefill.new(tl, bl, color.new(c_up, 90))
    array.push(d_tops,  tl)
    array.push(d_bots,  bl)
    array.push(d_fills, lf)
    array.push(d_top_v, top)
    array.push(d_bot_v, bot)
    if array.size(d_tops) > max_zones
        purge_demand(0)

// ─── Register New Supply Zone ─────────────────────────────────
if OB_bear
    top = bear_ob_top
    bot = bear_ob_bot
    tl = line.new(bar_index - ob_period, top, bar_index + 1, top,
         color=color.new(c_down, 50), width=2, force_overlay=true)
    bl = line.new(bar_index - ob_period, bot, bar_index + 1, bot,
         color=color.new(c_down, 50), width=2,
         style=line.style_dashed, force_overlay=true)
    lf = linefill.new(tl, bl, color.new(c_down, 90))
    array.push(s_tops,  tl)
    array.push(s_bots,  bl)
    array.push(s_fills, lf)
    array.push(s_top_v, top)
    array.push(s_bot_v, bot)
    if array.size(s_tops) > max_zones
        purge_supply(0)

// ─── Confluence: Price Inside Any Active Zone ─────────────────
in_demand = false
if array.size(d_top_v) > 0
    for i = 0 to array.size(d_top_v) - 1
        if low <= array.get(d_top_v, i) and high >= array.get(d_bot_v, i)
            in_demand := true

in_supply = false
if array.size(s_top_v) > 0
    for i = 0 to array.size(s_top_v) - 1
        if high >= array.get(s_bot_v, i) and low <= array.get(s_top_v, i)
            in_supply := true

// ─── Confluence Signals ───────────────────────────────────────
crossO     = ta.crossover(z,  0)
crossU     = ta.crossunder(z, 0)
rev_long   = in_demand and z <= -2
rev_short  = in_supply and z >= 2
cont_long  = in_demand and crossO
cont_short = in_supply and crossU

// ─── Bands ───────────────────────────────────────────────────
b3p = plot(+3, "+3σ", color=color.new(c_up,   30), linewidth=1)
b2p = plot(+2, "+2σ", color=color.new(c_up,   55), linewidth=1)
b1p = plot(+1, "+1σ", color=color.new(c_up,   75), linewidth=1)
b0  = plot( 0, "Zero", color=color.new(color.gray, 55), linewidth=1)
b1n = plot(-1, "-1σ", color=color.new(c_down, 75), linewidth=1)
b2n = plot(-2, "-2σ", color=color.new(c_down, 55), linewidth=1)
b3n = plot(-3, "-3σ", color=color.new(c_down, 30), linewidth=1)

// ─── Z-Score Line + Fill to Zero ─────────────────────────────
z_plot = plot(z, "Z-Score", color=z_col, linewidth=2)

// ─── MACD ────────────────────────────────────────────────────
plot(h_sc, "MACD Hist", color=hist_col, style=plot.style_histogram, linewidth=2)
plot(show_lines ? ml_sc : na, "MACD Line", color=color.new(c_up,  30), linewidth=1)
plot(show_lines ? sl_sc  : na, "Signal",   color=color.new(c_down, 30), linewidth=1)

// ─── Confluence Labels on Price Chart ────────────────────────
if rev_long and show_ob
    label.new(bar_index, low,
         "⚡ OB LONG  " + str.tostring(math.round(z, 1)) + "σ",
         style=label.style_label_up, color=color.new(c_up, 40),
         textcolor=color.new(color.white, 10), size=size.small, force_overlay=true)

if rev_short and show_ob
    label.new(bar_index, high,
         "⚡ OB SHORT  " + str.tostring(math.round(z, 1)) + "σ",
         style=label.style_label_down, color=color.new(c_down, 40),
         textcolor=color.new(color.white, 10), size=size.small, force_overlay=true)

if cont_long and show_cont
    label.new(bar_index, low, "↗ CONT",
         style=label.style_label_up, color=color.new(c_up, 60),
         textcolor=color.new(color.white, 10), size=size.tiny, force_overlay=true)

if cont_short and show_cont
    label.new(bar_index, high, "↘ CONT",
         style=label.style_label_down, color=color.new(c_down, 60),
         textcolor=color.new(color.white, 10), size=size.tiny, force_overlay=true)

// ─── Background Highlights ────────────────────────────────────
bgcolor(show_div and bull_div ? color.new(c_up,   80) : na, title="Bullish Divergence")
bgcolor(show_div and bear_div ? color.new(c_down, 80) : na, title="Bearish Divergence")

// ─── EMA Overlays ─────────────────────────────────────────────
plot(show_ema_overlay ? ta.ema(close, ema_fast_len) : na,
     "Fast EMA", color=color.new(c_up, 30), linewidth=1, force_overlay=true)
plot(show_ema_overlay ? ta.ema(close, ema_slow_len) : na,
     "Slow EMA", color=color.new(c_down, 30), linewidth=1, force_overlay=true)

// ─── Alerts ──────────────────────────────────────────────────
crossOalert = ta.crossover(z, 2)
crossUalert = ta.crossunder(z, -2)

alertcondition(crossOalert or crossUalert,
     "Z-Score Trade Zone",
     "⚡ TRADE ZONE — {{ticker}} on {{interval}}: Z-Score hit ±2σ")

alertcondition(rev_long or rev_short,
     "OB + Z-Score Reversal Confluence",
     "🎯 OB REVERSAL — {{ticker}} on {{interval}}: Price in Order Block at ±2σ extremity")

alertcondition(cont_long or cont_short,
     "OB Continuation Setup",
     "↗↘ OB CONTINUATION — {{ticker}} on {{interval}}: Z-Score reclaimed zero inside Order Block")
````
