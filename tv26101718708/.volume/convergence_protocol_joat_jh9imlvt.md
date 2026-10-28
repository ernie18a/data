# Convergence Protocol [JOAT]

- url: https://www.tradingview.com/script/JH9IMLVt-Convergence-Protocol-JOAT/
- type: strategy
- pine_id: PUB;24c80ba7530044bb83f52840ea72a8cf
- version: 1.0

## Description

[b]Convergence Protocol [JOAT][/b]

[b]Introduction[/b]

Convergence Protocol is an open-source strategy that combines four analytical modules — structural trend, volatility regime, delta pressure, and liquidity/structure break detection — into a multi-pathway entry and exit system. The strategy generates trade signals through five independent entry mechanisms, each requiring alignment between different analytical dimensions, and manages positions with ATR-based stops, dual take-profit levels, and an optional trailing stop that activates after the first target is reached.

The design rationale for combining these four modules is that each answers a different question about the market. Structure and trend analysis answers: what direction is the market likely to move? Volatility regime answers: does the market have the energy to sustain a directional move? Delta pressure answers: is volume supporting the proposed direction? Liquidity and structure break detection answers: has the market made a meaningful structural commitment that confirms directional intent? No single module alone provides a robust enough basis for a trade. Convergence across multiple modules provides a higher-quality signal set that reduces the frequency of marginal trades while maintaining enough opportunities to be practical.

[image]https://www.tradingview.com/x/8R6BjjMD/[/image]

[b]Strategy Properties and Backtesting Settings[/b]

Default settings used for publication:
[list]
[*]Initial Capital: Default TradingView account size
[*]Position Size: 5% of equity per trade
[*]Commission: 0.04% per side (realistic for most crypto and equity platforms)
[*]Slippage: 1 tick
[*]Risk Per Trade: 5% of equity maximum (within sustainable limits)
[*]Stop Loss: 1.5x ATR from entry
[*]TP1: 1.2x risk (50% of position closed)
[*]TP2: 2.5x risk (remaining position)
[*]Trailing Stop: 1.0x ATR trailing offset, activates after TP1 hit
[/list]

Backtesting results will vary significantly by instrument and timeframe. This strategy is intended to be evaluated across multiple instruments and market conditions before drawing conclusions. A single backtest run does not constitute evidence of future performance.

[b]Core Modules[/b]

[b]Module 1: Structural Trend Engine[/b]

The baseline uses a double-smoothed moving average (SMEMA). Swing highs and lows are tracked to classify market structure as bullish (HH+HL), bearish (LH+LL), or neutral. A 0-7 confluence score is assembled from: regime direction, structural alignment, volatility expansion, absence of squeeze, delta pressure, structure break confirmation, and liquidity sweep confirmation. Each module contributes a binary point to the score.

[b]Module 2: Volatility Regime[/b]

Short-period ATR is compared to long-period ATR. A ratio above 1.05 with a rising oscillator confirms volatility expansion — the market has enough energy for directional moves. A squeeze condition (fast ATR well below slow ATR and its own moving average) signals that the market is coiling; entries are filtered or blocked depending on settings.

[b]Module 3: Delta Pressure[/b]

Bar-by-bar delta (positive on bullish bars, negative on bearish bars) is smoothed into fast and slow EMAs. Their cross and relative position provide a directional bias from the volume perspective.

[b]Module 4: Liquidity and Structure[/b]

A break of structure (BOS) is confirmed when price closes beyond the most recent pivot in any direction on a confirmed bar. Liquidity sweeps are detected when price wicks beyond a prior swing and closes back on the correct side. Both conditions contribute to the confluence score.

[b]Entry Mechanisms[/b]

[b]1. Confluence Score Entry[/b]
All four modules must be aligned and score at or above the minimum threshold (default: 2 of 7). This is the primary high-conviction entry.

[b]2. Baseline Pullback Entry[/b]
In an established trend (regime confirmed), when price returns to within the step band of the baseline with positive delta confirmation, a pullback entry is generated. This produces more frequent entries by adding trend-continuation trades within an established directional move.

[b]3. Squeeze Breakout Entry[/b]
When a detected squeeze condition resolves (squeeze ends) with trend and delta alignment, a breakout entry fires. This targets the expansion phase immediately following volatility compression.

[b]4. Delta Crossover Entry[/b]
When the fast delta EMA crosses above the slow delta EMA in the direction of the regime, and the market is not in a squeeze, a momentum entry is generated.

[b]5. Sweep Reversal Entry[/b]
When a liquidity sweep occurs with confirming delta pressure, a reversal entry is generated in the direction of the sweep reversal. This targets the classic sweep-and-go pattern.

[b]Exit Logic[/b]

[list]
[*][b]TP1:[/b] 50% of position closed at 1.2× risk. Locks in partial profit and reduces position size for the remainder of the trade
[*][b]TP2:[/b] Remaining 50% targets 2.5× risk with a hard stop at the original stop level
[*][b]Trailing Stop:[/b] After TP1 is hit, the strategy optionally converts to a trailing stop with an ATR-based offset, allowing the winning portion of the trade to capture extended moves
[*][b]Regime Exit:[/b] If the market regime flips against the position (bullish regime while short, or bearish regime while long), the position is closed at market. This protects against holding trades through structural regime reversals
[/list]

[b]Limitations and Considerations[/b]

[list]
[*]The strategy uses OHLCV-based calculations throughout. It does not have access to tick data, order book information, or real-time execution data that institutional traders use
[*]Backtesting results are inherently optimistic due to perfect execution assumed at bar close prices. Real-world execution will differ
[*]The five entry mechanisms produce different trade frequencies. Users should evaluate each mechanism independently in backtesting before enabling all simultaneously
[*]The regime change exit can produce early exits in choppy markets where the regime briefly flips before resuming the original direction
[*]The trailing stop activation after TP1 is a fixed ATR offset from the highest/lowest price reached. It does not adapt to subsequent volatility changes during the trade
[*]The strategy is designed for trending markets. In persistent ranging environments, the confluence score-based entries will underperform because the regime module will frequently return a Ranging classification, suppressing primary entries
[*]Commission and slippage settings in the strategy Properties should be adjusted to match the actual costs on the instrument and broker being used before drawing any performance conclusions
[/list]

[b]Originality Statement[/b]

This strategy is original in its specific multi-pathway entry architecture and the unified 0-7 confluence scoring system that synthesizes structural, volatility, delta, and liquidity analysis into a single conviction metric. Each of the five entry pathways serves a distinct market condition: confluence entries target high-alignment setups; pullback entries target trend continuation in established moves; squeeze breakout entries target volatility expansion transitions; delta crossover entries target momentum initiation; sweep reversal entries target institutional accumulation/distribution patterns. No single existing strategy approach covers all five scenarios. The combination is justified because these five market conditions occur at different points in the market cycle, and a strategy limited to one condition type will sit idle during the other four.

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. Past backtest results do not guarantee future performance. No backtesting result should be interpreted as evidence that this strategy will be profitable in live trading. Markets change, and conditions that produced past results may not recur. The strategy does not account for taxes, broker requirements, or psychological factors in live trading. Always use proper risk management and consult with a qualified financial professional before making any investment decisions. The author is not responsible for any losses incurred from using this strategy.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Convergence Protocol [JOAT]", shorttitle="CP [JOAT]",
         overlay=true, margin_long=100, margin_short=100,
         default_qty_type=strategy.percent_of_equity,
         default_qty_value=5, commission_type=strategy.commission.percent,
         commission_value=0.04, slippage=1,
         max_labels_count=200, max_lines_count=300, max_boxes_count=200)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_r   = "Risk Management"
i_risk  = input.float(2.0, "Risk Per Trade (%)",      minval=0.5, maxval=10.0, step=0.5, group=grp_r)
i_atr_sl= input.float(1.5, "Stop Loss ATR Mult",      minval=0.5, maxval=4.0,  step=0.1, group=grp_r)
i_rr1   = input.float(1.2, "TP1 R:R",                minval=0.5, maxval=5.0,  step=0.1, group=grp_r)
i_rr2   = input.float(2.5, "TP2 R:R",                minval=1.0, maxval=8.0,  step=0.5, group=grp_r)
i_trail = input.bool(true, "Trail After TP1",        group=grp_r)
i_trail_atr = input.float(1.0, "Trailing ATR Mult",  minval=0.3, maxval=3.0, step=0.1, group=grp_r)

grp_e   = "Entry Settings"
i_min_score = input.int(2, "Min Confluence Score (1-7)", minval=1, maxval=7, group=grp_e)
i_pullback  = input.bool(true, "Baseline Pullback Entries", group=grp_e)
i_squeeze   = input.bool(true, "Squeeze Breakout Entries",  group=grp_e)
i_sweep     = input.bool(true, "Sweep Reversal Entries",    group=grp_e)
i_reentry   = input.bool(true, "Allow Re-entry After TP1",  group=grp_e)
i_vol_gate  = input.bool(false, "Require Vol Expansion",    group=grp_e)

grp_s   = "Structure & Indicators"
i_piv   = input.int(5,  "Pivot Lookback",   minval=2, maxval=15, group=grp_s)
i_blen  = input.int(10, "Baseline Length",  minval=5, maxval=50, group=grp_s)
i_atrlen= input.int(14, "ATR Length",       minval=5, maxval=30, group=grp_s)
i_dfast = input.int(14, "Delta EMA Fast",   minval=5, maxval=50, group=grp_s)
i_dslow = input.int(34, "Delta EMA Slow",   minval=10, maxval=150, group=grp_s)

grp_v   = "Visual Settings"
i_col_b = input.color(#00bfa5, "Long Color",   group=grp_v)
i_col_s = input.color(#ef5350, "Short Color",  group=grp_v)
i_dash  = input.bool(true, "Show Dashboard",   group=grp_v)
i_zones = input.bool(true, "Show Trade Zones", group=grp_v)
i_cloud = input.bool(true, "Show Regime Cloud",group=grp_v)

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────
smema(src, len) => ta.sma(ta.ema(src, len), len)

// ─────────────────────────────────────────────────────────────────────────────
// MODULE 1 — STRUCTURE & TREND ENGINE
// ─────────────────────────────────────────────────────────────────────────────
atr_val  = ta.atr(i_atrlen)
baseline = smema(close, i_blen)
step     = smema(high - low, 100)

b_up1 = baseline + step
b_dn1 = baseline - step
b_up2 = baseline + step * 2.0
b_dn2 = baseline - step * 2.0
b_up3 = baseline + step * 3.0
b_dn3 = baseline - step * 3.0

rising  = baseline > baseline[1]
falling = baseline < baseline[1]

ph = ta.pivothigh(high, i_piv, i_piv)
pl = ta.pivotlow (low,  i_piv, i_piv)

var float last_ph = na
var float last_pl = na
var float prev_ph = na
var float prev_pl = na
var int   phi     = na
var int   pli     = na

if not na(ph)
    prev_ph := last_ph
    last_ph := ph
    phi     := bar_index[i_piv]

if not na(pl)
    prev_pl := last_pl
    last_pl := pl
    pli     := bar_index[i_piv]

s_hh = not na(last_ph) and not na(prev_ph) and last_ph > prev_ph
s_lh = not na(last_ph) and not na(prev_ph) and last_ph < prev_ph
s_ll = not na(last_pl) and not na(prev_pl) and last_pl < prev_pl
s_hl = not na(last_pl) and not na(prev_pl) and last_pl > prev_pl

bull_struct = s_hh and s_hl
bear_struct = s_ll and s_lh

bull_score = (close > b_up1 ? 1:0) + (close > b_up2 ? 1:0) + (s_hh ? 1:0) + (s_hl ? 1:0)
bear_score = (close < b_dn1 ? 1:0) + (close < b_dn2 ? 1:0) + (s_ll ? 1:0) + (s_lh ? 1:0)

var int regime = 0
if barstate.isconfirmed
    regime := rising and bull_score >= 2 ? 1 : falling and bear_score >= 2 ? -1 : 0

// ─────────────────────────────────────────────────────────────────────────────
// MODULE 2 — VOLATILITY REGIME
// ─────────────────────────────────────────────────────────────────────────────
atr_slow    = ta.atr(100)
atr_ratio   = atr_val / math.max(atr_slow, syminfo.mintick)
vol_osc     = ta.ema(atr_ratio - 1.0, 3)
vol_sig     = ta.sma(vol_osc, 9)
vol_expand  = atr_ratio > 1.05 and vol_osc > vol_sig
atr_ma20    = ta.sma(atr_val, 20)
squeeze     = atr_val < atr_slow * 0.82 and atr_val < atr_ma20
sq_released = not squeeze and squeeze[1]  // squeeze just ended — potential breakout

// ─────────────────────────────────────────────────────────────────────────────
// MODULE 3 — DELTA PRESSURE
// ─────────────────────────────────────────────────────────────────────────────
bar_delta    = close > open ? volume : close < open ? -volume : 0.0
delta_fast_v = ta.ema(bar_delta, i_dfast)
delta_slow_v = ta.ema(bar_delta, i_dslow)
delta_ref    = ta.percentile_linear_interpolation(math.abs(delta_fast_v - delta_slow_v), 200, 100)
delta_osc    = (delta_fast_v - delta_slow_v) / math.max(delta_ref, 1.0)
delta_sig_v  = ta.ema(delta_osc, 9)
delta_bull   = delta_osc > 0.05 and delta_osc > delta_sig_v
delta_bear   = delta_osc < -0.05 and delta_osc < delta_sig_v
delta_cross_bull = delta_fast_v > delta_slow_v and delta_fast_v[1] <= delta_slow_v[1]
delta_cross_bear = delta_fast_v < delta_slow_v and delta_fast_v[1] >= delta_slow_v[1]

// ─────────────────────────────────────────────────────────────────────────────
// MODULE 4 — STRUCTURE BREAKS & SWEEPS
// ─────────────────────────────────────────────────────────────────────────────
var bool bos_bull = false
var bool bos_bear = false

if barstate.isconfirmed
    if not na(last_ph) and close > last_ph and close[1] <= last_ph
        bos_bull := true
        bos_bear := false
    if not na(last_pl) and close < last_pl and close[1] >= last_pl
        bos_bear := true
        bos_bull := false

bull_sweep = barstate.isconfirmed and not na(last_pl) and
             low < last_pl - atr_val * 0.25 and close > last_pl
bear_sweep = barstate.isconfirmed and not na(last_ph) and
             high > last_ph + atr_val * 0.25 and close < last_ph

// Pullback detection (price returning to baseline zone from trend direction)
near_baseline  = math.abs(close - baseline) < step * 0.5
bull_pullback  = near_baseline and regime == 1 and low <= baseline + step * 0.3 and close > baseline
bear_pullback  = near_baseline and regime == -1 and high >= baseline - step * 0.3 and close < baseline

// ─────────────────────────────────────────────────────────────────────────────
// CONFLUENCE SCORING (0–7) — confirmed bars
// ─────────────────────────────────────────────────────────────────────────────
var int long_score  = 0
var int short_score = 0

if barstate.isconfirmed
    long_score  := (regime == 1   ? 1:0) + (bull_struct  ? 1:0) +
                   (vol_expand    ? 1:0) + (not squeeze  ? 1:0) +
                   (delta_bull    ? 1:0) + (bos_bull     ? 1:0) +
                   (bull_sweep    ? 1:0)

    short_score := (regime == -1  ? 1:0) + (bear_struct  ? 1:0) +
                   (vol_expand    ? 1:0) + (not squeeze  ? 1:0) +
                   (delta_bear    ? 1:0) + (bos_bear     ? 1:0) +
                   (bear_sweep    ? 1:0)

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY CONDITIONS — multiple pathways for higher trade frequency
// ─────────────────────────────────────────────────────────────────────────────
vol_ok   = not i_vol_gate or vol_expand
flat     = strategy.position_size == 0

// 1. Primary: Full confluence score entry
primary_long  = barstate.isconfirmed and flat and vol_ok and long_score >= i_min_score and regime == 1
primary_short = barstate.isconfirmed and flat and vol_ok and short_score >= i_min_score and regime == -1

// 2. Pullback to baseline in established trend
pb_long  = barstate.isconfirmed and flat and i_pullback and regime == 1 and bull_pullback and delta_bull and vol_ok
pb_short = barstate.isconfirmed and flat and i_pullback and regime == -1 and bear_pullback and delta_bear and vol_ok

// 3. Squeeze breakout in trend direction
sq_long  = barstate.isconfirmed and flat and i_squeeze and sq_released and regime == 1 and delta_bull
sq_short = barstate.isconfirmed and flat and i_squeeze and sq_released and regime == -1 and delta_bear

// 4. Delta crossover in trend direction
dc_long  = barstate.isconfirmed and flat and delta_cross_bull and regime == 1 and not squeeze and vol_ok
dc_short = barstate.isconfirmed and flat and delta_cross_bear and regime == -1 and not squeeze and vol_ok

// 5. Sweep reversal (liquidity grab → continuation)
sw_long  = barstate.isconfirmed and flat and i_sweep and bull_sweep and delta_bull
sw_short = barstate.isconfirmed and flat and i_sweep and bear_sweep and delta_bear

// Combine all long/short signals
long_entry  = primary_long  or pb_long  or sq_long  or dc_long  or sw_long
short_entry = primary_short or pb_short or sq_short or dc_short or sw_short

// Entry label for trade tracking
entry_type(is_long) =>
    primary_long and is_long or primary_short and not is_long ? "CONF" : pb_long and is_long or pb_short and not is_long ? "PB" : sq_long and is_long or sq_short and not is_long ? "SQ" : dc_long and is_long or dc_short and not is_long ? "DC" : "SW"

// ─────────────────────────────────────────────────────────────────────────────
// STOP / TARGET LEVELS
// ─────────────────────────────────────────────────────────────────────────────
var float sl_dist  = na
var float entry_px = na
var float stop_px  = na
var float tp1_px   = na
var float tp2_px   = na
var bool  tp1_done = false
var string e_label = ""

if long_entry
    sl_dist  := atr_val * i_atr_sl
    entry_px := close
    stop_px  := close - sl_dist
    tp1_px   := close + sl_dist * i_rr1
    tp2_px   := close + sl_dist * i_rr2
    tp1_done := false
    e_label  := entry_type(true)

if short_entry
    sl_dist  := atr_val * i_atr_sl
    entry_px := close
    stop_px  := close + sl_dist
    tp1_px   := close - sl_dist * i_rr1
    tp2_px   := close - sl_dist * i_rr2
    tp1_done := false
    e_label  := entry_type(false)

// ─────────────────────────────────────────────────────────────────────────────
// TRADE EXECUTION
// ─────────────────────────────────────────────────────────────────────────────
if long_entry
    strategy.entry("Long", strategy.long)
    strategy.exit("L-TP1", "Long", qty_percent=50, limit=tp1_px, stop=stop_px)
    strategy.exit("L-TP2", "Long", qty_percent=100, limit=tp2_px, stop=stop_px)

if short_entry
    strategy.entry("Short", strategy.short)
    strategy.exit("S-TP1", "Short", qty_percent=50, limit=tp1_px, stop=stop_px)
    strategy.exit("S-TP2", "Short", qty_percent=100, limit=tp2_px, stop=stop_px)

// Trailing stop after TP1 hit
// trail_offset + trail_points is a valid pair in Pine v6
trail_ticks = math.max(nz(atr_val, close * 0.001) * i_trail_atr / syminfo.mintick, 1.0)

if i_trail and strategy.position_size > 0 and not tp1_done
    if high >= tp1_px
        tp1_done := true
        strategy.cancel("L-TP2")
        strategy.exit("L-Trail", "Long", trail_points=trail_ticks, trail_offset=trail_ticks)

if i_trail and strategy.position_size < 0 and not tp1_done
    if low <= tp1_px
        tp1_done := true
        strategy.cancel("S-TP2")
        strategy.exit("S-Trail", "Short", trail_points=trail_ticks, trail_offset=trail_ticks)

// Regime change emergency exit
if barstate.isconfirmed
    if strategy.position_size > 0 and regime == -1
        strategy.close("Long", comment="Regime Exit")
    if strategy.position_size < 0 and regime == 1
        strategy.close("Short", comment="Regime Exit")

// ─────────────────────────────────────────────────────────────────────────────
// VISUAL — REGIME CLOUD (background gradient)
// ─────────────────────────────────────────────────────────────────────────────
r_col    = regime == 1 ? i_col_b : regime == -1 ? i_col_s : color.gray
cloud_op = 97

// Regime band fills
pu3 = plot(i_cloud ? b_up3 : na, color=na, editable=false)
pu2 = plot(i_cloud ? b_up2 : na, color=na, editable=false)
pu1 = plot(i_cloud ? b_up1 : na, color=color.new(i_col_b, 80), linewidth=1, editable=false)
pb  = plot(baseline, "Baseline", color=color.new(r_col, 10), linewidth=2)
pd1 = plot(i_cloud ? b_dn1 : na, color=color.new(i_col_s, 80), linewidth=1, editable=false)
pd2 = plot(i_cloud ? b_dn2 : na, color=na, editable=false)
pd3 = plot(i_cloud ? b_dn3 : na, color=na, editable=false)

fill(pu1, pu2, color=color.new(i_col_b, 95), editable=false)
fill(pu2, pu3, color=color.new(i_col_b, 97), editable=false)
fill(pd1, pd2, color=color.new(i_col_s, 95), editable=false)
fill(pd2, pd3, color=color.new(i_col_s, 97), editable=false)

// Pivot dots
plotshape(not na(ph) ? ph : na, style=shape.circle, location=location.absolute,
         color=color.new(i_col_s, 40), size=size.tiny, offset=-i_piv, editable=false)
plotshape(not na(pl) ? pl : na, style=shape.circle, location=location.absolute,
         color=color.new(i_col_b, 40), size=size.tiny, offset=-i_piv, editable=false)

barcolor(r_col, editable=false)

// ─────────────────────────────────────────────────────────────────────────────
// VISUAL — TRADE ZONE BOXES
// ─────────────────────────────────────────────────────────────────────────────
var box  trade_zone  = na
var line entry_line  = na
var line sl_line     = na
var line tp1_line    = na
var line tp2_line    = na
var box  entry_lbl   = na

if i_zones
    if long_entry or short_entry
        box.delete(trade_zone)
        line.delete(entry_line)
        line.delete(sl_line)
        line.delete(tp1_line)
        line.delete(tp2_line)
        box.delete(entry_lbl)

        is_long  = long_entry
        zone_top = is_long ? tp2_px : stop_px
        zone_bot = is_long ? stop_px : tp2_px
        ecol     = is_long ? i_col_b : i_col_s

        // Full trade range box
        trade_zone := box.new(bar_index, zone_top, bar_index + 50, zone_bot,
                              bgcolor=color.new(ecol, 94),
                              border_color=color.new(ecol, 70),
                              border_style=line.style_dashed)

        // Entry level
        entry_line := line.new(bar_index, close, bar_index + 50, close,
                               color=color.new(color.white, 25), width=1)

        // Stop loss
        sl_line    := line.new(bar_index, stop_px, bar_index + 50, stop_px,
                               color=color.new(i_col_s, 25), width=1, style=line.style_dashed)

        // TP1
        tp1_line   := line.new(bar_index, tp1_px, bar_index + 50, tp1_px,
                               color=color.new(ecol, 50), width=1, style=line.style_dotted)

        // TP2
        tp2_line   := line.new(bar_index, tp2_px, bar_index + 50, tp2_px,
                               color=color.new(ecol, 25), width=2, style=line.style_solid)

        // Entry label
        entry_lbl  := box.new(bar_index, close, bar_index + 50, close,
                              text=(is_long ? "L" : "S") + " " + e_label,
                              text_size=size.tiny, text_color=ecol,
                              text_halign=text.align_left, text_valign=text.align_bottom,
                              bgcolor=color.new(color.black, 100),
                              border_color=color.new(color.black, 100))

// Extend trade lines on active position
if i_zones and strategy.position_size != 0 and not na(entry_line)
    entry_line.set_x2(bar_index)
    sl_line.set_x2(bar_index)
    tp1_line.set_x2(bar_index)
    tp2_line.set_x2(bar_index)
    trade_zone.set_right(bar_index)
    entry_lbl.set_right(bar_index)

// Squeeze visualization (background fill when squeeze active)
bgcolor(squeeze ? color.new(#ffd54f, 97) : na, editable=false, title="Squeeze Background")

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table _t = na
if i_dash and barstate.islast
    if na(_t)
        _t := table.new(position.top_right, 3, 14,
                        border_width=1, border_color=color.new(color.gray, 75),
                        frame_width=2,  frame_color=color.new(color.gray, 55))

    C0  = color.new(#0a1628, 0)
    C1  = color.new(#0f2341, 0)
    C2  = color.new(#152d52, 0)

    table.cell(_t, 0, 0, "CONVERGENCE PROTOCOL", bgcolor=C0,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 0, 0, 2, 0)

    // Regime
    table.cell(_t, 0, 1, "Regime", bgcolor=C1, text_color=color.gray, text_size=size.small)
    reg_str = regime == 1 ? "BULL" : regime == -1 ? "BEAR" : "RANGE"
    table.cell(_t, 1, 1, reg_str, bgcolor=C1, text_color=r_col, text_size=size.small)
    table.cell(_t, 2, 1, regime == 1 ? "+" : regime == -1 ? "-" : "~",
               bgcolor=color.new(r_col, 40), text_color=color.white, text_size=size.small)

    // Scores
    ls_bg = long_score >= 5 ? color.new(i_col_b, 20) : long_score >= 3 ? color.new(i_col_b, 55) : C2
    table.cell(_t, 0, 2, "Long Score", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 2, str.tostring(long_score) + "/7", bgcolor=ls_bg,
               text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 2, long_score >= 5 ? "Strong" : long_score >= 3 ? "Valid" : "Weak",
               bgcolor=C2, text_color=long_score >= 4 ? i_col_b : color.gray, text_size=size.small)

    ss_bg = short_score >= 5 ? color.new(i_col_s, 20) : short_score >= 3 ? color.new(i_col_s, 55) : C1
    table.cell(_t, 0, 3, "Short Score", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 3, str.tostring(short_score) + "/7", bgcolor=ss_bg,
               text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 3, short_score >= 5 ? "Strong" : short_score >= 3 ? "Valid" : "Weak",
               bgcolor=C1, text_color=short_score >= 4 ? i_col_s : color.gray, text_size=size.small)

    // Volatility
    table.cell(_t, 0, 4, "Volatility", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 4, squeeze ? "SQUEEZE" : vol_expand ? "Expanding" : "Neutral",
               bgcolor=squeeze ? color.new(#ffd54f, 30) : vol_expand ? color.new(i_col_b, 55) : C2,
               text_color=squeeze ? #ffd54f : vol_expand ? i_col_b : color.gray, text_size=size.small)
    table.merge_cells(_t, 1, 4, 2, 4)

    // Delta
    table.cell(_t, 0, 5, "Delta", bgcolor=C1, text_color=color.gray, text_size=size.small)
    d_str = delta_bull ? "Bullish" : delta_bear ? "Bearish" : "Neutral"
    d_col = delta_bull ? i_col_b : delta_bear ? i_col_s : color.gray
    table.cell(_t, 1, 5, d_str, bgcolor=C1, text_color=d_col, text_size=size.small)
    table.merge_cells(_t, 1, 5, 2, 5)

    // Structure
    table.cell(_t, 0, 6, "Structure", bgcolor=C2, text_color=color.gray, text_size=size.small)
    str_txt = (s_hh ? "HH " : s_lh ? "LH " : "-- ") + (s_hl ? "HL" : s_ll ? "LL" : "--")
    str_col = bull_struct ? i_col_b : bear_struct ? i_col_s : color.gray
    table.cell(_t, 1, 6, str_txt, bgcolor=C2, text_color=str_col, text_size=size.small)
    table.merge_cells(_t, 1, 6, 2, 6)

    // Active entries available
    table.cell(_t, 0, 7, "Setups", bgcolor=C1, text_color=color.gray, text_size=size.small)
    setup_str = long_entry ? "LONG" : short_entry ? "SHORT" : "None"
    setup_col = long_entry ? i_col_b : short_entry ? i_col_s : color.gray
    table.cell(_t, 1, 7, setup_str, bgcolor=long_entry ? color.new(i_col_b,35) :
               short_entry ? color.new(i_col_s,35) : C1,
               text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 7, e_label, bgcolor=C1, text_color=setup_col, text_size=size.small)

    // Position
    table.cell(_t, 0, 8, "Position", bgcolor=C2, text_color=color.gray, text_size=size.small)
    pos_str = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    pos_col = strategy.position_size > 0 ? i_col_b : strategy.position_size < 0 ? i_col_s : color.gray
    table.cell(_t, 1, 8, pos_str, bgcolor=C2, text_color=pos_col, text_size=size.small)
    table.merge_cells(_t, 1, 8, 2, 8)

    // ATR
    table.cell(_t, 0, 9, "ATR", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 9, str.tostring(atr_val, format.mintick),
               bgcolor=C1, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 9, str.tostring(atr_val / close * 100, "#.##") + "%",
               bgcolor=C1, text_color=color.gray, text_size=size.small)

    // Baseline
    table.cell(_t, 0, 10, "Baseline", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 10, str.tostring(baseline, format.mintick),
               bgcolor=C2, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 10, rising ? "Rising" : "Falling",
               bgcolor=C2, text_color=rising ? i_col_b : i_col_s, text_size=size.small)

    // Performance stats
    total_trades = strategy.closedtrades
    winrate = total_trades > 0 ? (strategy.wintrades / total_trades * 100) : 0.0
    table.cell(_t, 0, 11, "Trades/Win%", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 11, str.tostring(total_trades),
               bgcolor=C1, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 11, str.tostring(winrate, "#.#") + "%",
               bgcolor=C1, text_color=winrate >= 50 ? i_col_b : i_col_s, text_size=size.small)

    pnl = strategy.netprofit
    table.cell(_t, 0, 12, "Net P&L", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 12, (pnl >= 0 ? "+" : "") + str.tostring(pnl, "#.##"),
               bgcolor=pnl >= 0 ? color.new(i_col_b, 40) : color.new(i_col_s, 40),
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 1, 12, 2, 12)

    table.cell(_t, 0, 13, "jackofalltrades", bgcolor=C0,
               text_color=color.new(color.white, 60), text_size=size.tiny)
    table.merge_cells(_t, 0, 13, 2, 13)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(long_entry,  "CP — Long Entry",  "Convergence Protocol: Long signal — {{ticker}} {{interval}}")
alertcondition(short_entry, "CP — Short Entry", "Convergence Protocol: Short signal — {{ticker}} {{interval}}")
alertcondition(sq_released, "CP — Squeeze Released", "Volatility squeeze ended — watch for breakout — {{ticker}}")
alertcondition(delta_cross_bull and regime == 1, "CP — Delta Bull Cross in Uptrend", "{{ticker}}: Bullish delta cross")
alertcondition(delta_cross_bear and regime == -1, "CP — Delta Bear Cross in Downtrend", "{{ticker}}: Bearish delta cross")
````
