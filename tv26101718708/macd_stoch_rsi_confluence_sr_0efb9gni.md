# MACD & Stoch RSI Confluence S/R

- url: https://www.tradingview.com/script/0EFB9GnI/
- type: indicator
- pine_id: PUB;6a0a04c83c7e47af8adddb6594fc2979
- version: 1.0

## Description

MACD & Stoch RSI Confluence S/R

MACD & Stoch RSI Confluence S/R draws horizontal support and resistance 
levels from MACD and Stochastic RSI crossover points, then automatically 
merges levels that cluster close together into a single confluence zone. 
Instead of treating every crossover as an isolated signal, it highlights 
the price areas where two independent momentum oscillators historically 
agreed on a turning point.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BACKGROUND — WHY CROSSOVER-BASED LEVELS?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MACD and Stochastic RSI are both momentum oscillators, but they measure 
momentum differently — MACD from the relationship between two EMAs, 
Stochastic RSI from the position of RSI within its own recent range. 
Because of this difference, the two oscillators don't always cross at the 
same time or the same price, but when they do cross near the same price 
level, it suggests that two independent calculations both detected a 
shift in momentum at that point.

Traditional crossover indicators only mark the moment of the crossover 
itself and then move on — the price level where it happened is rarely 
preserved or revisited. This indicator instead treats every crossover 
price as a potential support or resistance level going forward, on the 
logic that price has already shown a reaction (a momentum shift) at that 
level once, and may do so again if it returns there.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS — TECHNICAL DETAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CROSSOVER DETECTION
The indicator calculates a standard MACD (fast EMA, slow EMA, signal line) 
and a standard Stochastic RSI (RSI smoothed through a Stochastic 
calculation, then K/D smoothing) independently. Bullish crossovers occur 
when MACD crosses above its signal line, or when Stochastic RSI's K line 
crosses above its D line. Bearish crossovers are the inverse.

Each time a valid crossover occurs, the indicator looks back a 
user-defined number of bars (How many bars before crossover?) and records 
the low of that bar for bullish crossovers, or the high for bearish 
crossovers. This offset exists because the actual turning point in price 
often occurs slightly before the oscillator confirms it — anchoring the 
line to the prior bar's extreme captures the reaction point more 
accurately than the bar where the crossover is technically confirmed.

PROXIMITY FILTERING (PER OSCILLATOR)
Before a new level is recorded, it's checked against existing levels from 
the same oscillator and same direction using an ATR-based distance 
threshold. If a new crossover price falls too close to an already-recorded 
level, it's discarded. This prevents a single trending move that triggers 
several crossovers in quick succession from flooding the chart with 
near-identical lines.

CONFLUENCE MERGING (ACROSS OSCILLATORS)
After proximity filtering, all surviving levels from both oscillators — 
MACD support, MACD resistance, Stoch RSI support, Stoch RSI resistance — 
are pooled together. Any levels within a percentage threshold of each 
other are merged into a single line, positioned at their average price. 
The merged line is labeled with the count of crossovers that contributed 
to it, so a label showing "⬡3" indicates three separate crossover events — 
potentially from different oscillators — all landed within the merge 
threshold of one another.

This merge threshold is calculated automatically based on the chart's 
timeframe: wider on higher timeframes (where price ranges are naturally 
larger) and tighter on lower timeframes. A manual override is available if 
you prefer a fixed percentage regardless of timeframe.

DYNAMIC COLORING
Every line — merged or single — is colored based on its position relative 
to the current close. A line below price is colored as support; a line 
above price is colored as resistance. Because lines extend forward in 
time, a single line can change from resistance to support (or vice versa) 
as price crosses through it, and the color updates automatically.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INFO TABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A table in the corner of your choice displays, for the most recent bar:
— The number of support and resistance lines currently shown for each 
  oscillator separately
— The nearest support and nearest resistance level to current price, 
  calculated from the same merged lines drawn on the chart — not a 
  separate calculation, so the table always matches what you see
— Whether the MACD zero-line filter and Stoch RSI overbought/oversold 
  filter are currently active
— Whether each oscillator is enabled
— The current merge threshold percentage and whether it was set 
  automatically or manually

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. CHOOSE WHICH OSCILLATORS TO USE
   Both MACD and Stochastic RSI are enabled by default. You can disable 
   either one independently if you only want levels from a single 
   oscillator, or run both for confluence.

2. SET THE BAR OFFSET
   How many bars before crossover? controls how far back from the 
   confirmed crossover the indicator anchors the level. Start with the 
   default and increase it if you find levels are consistently anchored 
   slightly too late relative to the actual price reaction.

3. TUNE THE PROXIMITY FILTER
   The ATR Multiplier controls how close a new crossover has to be to an 
   existing level of the same type before it's discarded. Increase this on 
   choppy assets to reduce clutter; decrease it if you feel valid levels 
   are being filtered out.

4. APPLY OPTIONAL FILTERS IF NEEDED
   The MACD Zero Line Filter restricts bullish crossovers to above the 
   zero line and bearish crossovers to below it, filtering out weaker 
   signals that occur against the broader momentum direction. The Stoch 
   RSI Overbought/Oversold Filter restricts crossovers to occur only in 
   oversold or overbought territory, focusing on reversal-type signals 
   rather than mid-range noise. Both are off by default — enable them if 
   you want fewer, more selective levels.

5. ADJUST THE MERGE THRESHOLD IF NEEDED
   The automatic threshold works well across most timeframes, but if you 
   trade a single timeframe consistently and want more control, switch to 
   Manual Threshold and set a fixed percentage that matches your 
   instrument's typical price behavior.

6. READ THE LABELS
   Single-oscillator lines are labeled "M" (MACD) or "S" (Stoch RSI). 
   Merged lines are labeled with a count (e.g. "⬡2", "⬡3") showing how many 
   crossovers — and potentially how many different oscillators — agreed on 
   that level. Higher counts represent stronger confluence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHERE TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The indicator works on any asset class and any timeframe, since both 
oscillators and the merge threshold are calculated directly from the 
chart you have open. It's particularly useful for:

— Identifying support/resistance levels that are backed by momentum 
  shifts rather than purely price-action-based pivots
— Spotting confluence zones where MACD and Stoch RSI crossovers 
  historically aligned, which may carry more weight than a level 
  identified by either oscillator alone
— Confirming reactions at prior turning points — if price returns to a 
  level where a crossover previously occurred, the level provides context 
  for whether momentum may shift again
— Combining with other structure or volume-based tools as part of a 
  broader confluence-based approach, rather than as a standalone signal 
  generator

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MACD: Fast/Slow/Signal EMA lengths, source, bar offset, max support/
resistance lines kept, line width, colors, extend mode, ATR-based 
proximity filter, zero-line filter

Stochastic RSI: RSI period, Stochastic period, K/D smoothing, source, and 
the same set of line/extend/proximity/zone options as MACD

Merging: enable/disable, automatic or manual threshold, merged line color 
and width

Table: show/hide, position

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ORIGINALITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MACD and Stochastic RSI crossovers are both well-established concepts 
individually, but this script's specific contribution is treating 
crossover prices as persistent support/resistance levels rather than 
one-off signals, combined with a cross-oscillator confluence merge that 
identifies where two independently-calculated momentum tools agreed on 
the same price area. The ATR-based proximity filter and timeframe-adaptive 
merge threshold are the author's own approach to keeping this practical 
and readable on a live chart rather than producing chart clutter.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This indicator is intended for educational and analytical purposes only. 
No indicator can predict future market movements with certainty. Always 
use proper risk management and combine multiple forms of analysis before 
making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano

//@version=6
indicator('MACD & Stoch RSI Confluence S/R', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════════
// MACD SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════
grp_macd = '── MACD Settings ──'
use_macd = input.bool(true, 'MACD Active', group = grp_macd)
fast_len = input.int(12, 'Fast EMA', minval = 1, group = grp_macd)
slow_len = input.int(26, 'Slow EMA', minval = 1, group = grp_macd)
signal_len = input.int(9, 'Signal', minval = 1, group = grp_macd)
macd_src = input.source(close, 'Source', group = grp_macd)

grp_macd_sr = '── MACD S/R Settings ──'
macd_bars_before = input.int(1, 'How many bars before crossover?', minval = 1, maxval = 20, group = grp_macd_sr)
macd_max_sup = input.int(50, 'Support line count', minval = 1, maxval = 50, group = grp_macd_sr)
macd_max_res = input.int(50, 'Resistance line count', minval = 1, maxval = 50, group = grp_macd_sr)
macd_line_width = input.int(6, 'Line Width', minval = 1, maxval = 8, group = grp_macd_sr)
macd_sup_color = input.color(color.new(#00E676, 0), 'Below Close Color (Support)', group = grp_macd_sr)
macd_res_color = input.color(color.new(#FF1744, 0), 'Above Close Color (Resistance)', group = grp_macd_sr)
macd_show_label = input.bool(true, 'Show Label', group = grp_macd_sr)

grp_macd_ext = '── MACD Extend Settings ──'
macd_extend_mode = input.string('İki Yön Sonsuz', 'Extend Mode', options = ['Sabit Bar', 'Sağa Sonsuz', 'İki Yön Sonsuz'], group = grp_macd_ext)
macd_line_extend = input.int(300, 'Line Length (bars) — for Sabit Bar mode', minval = 5, maxval = 500, group = grp_macd_ext)

grp_macd_prox = '── MACD Proximity Filter ──'
macd_use_prox = input.bool(true, 'Enable Proximity Filter', group = grp_macd_prox)
macd_prox_atr_mult = input.float(0.05, 'ATR Multiplier', minval = 0.01, maxval = 5.0, step = 0.01, group = grp_macd_prox)
macd_atr_len = input.int(2, 'ATR Period', minval = 1, group = grp_macd_prox)

grp_macd_zero = '── MACD Zero Line Filter ──'
macd_use_zero = input.bool(false, 'Enable Zero Line Filter', group = grp_macd_zero)

// ═══════════════════════════════════════════════════════════════════════════════
// STOCHASTIC RSI SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════
grp_srsi = '── Stochastic RSI Settings ──'
use_srsi = input.bool(true, 'Stoch RSI Active', group = grp_srsi)
rsi_len = input.int(14, 'RSI Period', minval = 1, group = grp_srsi)
stoch_len = input.int(14, 'Stochastic Period', minval = 1, group = grp_srsi)
k_smooth = input.int(3, 'K Smoothing', minval = 1, group = grp_srsi)
d_smooth = input.int(3, 'D Smoothing', minval = 1, group = grp_srsi)
srsi_src = input.source(close, 'Source', group = grp_srsi)

grp_srsi_sr = '── Stoch RSI S/R Settings ──'
srsi_bars_before = input.int(1, 'How many bars before crossover?', minval = 1, maxval = 20, group = grp_srsi_sr)
srsi_max_sup = input.int(50, 'Support line count', minval = 1, maxval = 50, group = grp_srsi_sr)
srsi_max_res = input.int(50, 'Resistance line count', minval = 1, maxval = 50, group = grp_srsi_sr)
srsi_line_width = input.int(6, 'Line Width', minval = 1, maxval = 8, group = grp_srsi_sr)
srsi_sup_color = input.color(color.new(#00B0FF, 0), 'Below Close Color (Support)', group = grp_srsi_sr)
srsi_res_color = input.color(color.new(#FF6D00, 0), 'Above Close Color (Resistance)', group = grp_srsi_sr)
srsi_show_label = input.bool(true, 'Show Label', group = grp_srsi_sr)

grp_srsi_ext = '── Stoch RSI Extend Settings ──'
srsi_extend_mode = input.string('İki Yön Sonsuz', 'Extend Mode', options = ['Sabit Bar', 'Sağa Sonsuz', 'İki Yön Sonsuz'], group = grp_srsi_ext)
srsi_line_extend = input.int(300, 'Line Length (bars) — for Sabit Bar mode', minval = 5, maxval = 500, group = grp_srsi_ext)

grp_srsi_prox = '── Stoch RSI Proximity Filter ──'
srsi_use_prox = input.bool(true, 'Enable Proximity Filter', group = grp_srsi_prox)
srsi_prox_atr_mult = input.float(0.05, 'ATR Multiplier', minval = 0.01, maxval = 5.0, step = 0.01, group = grp_srsi_prox)
srsi_atr_len = input.int(2, 'ATR Period', minval = 1, group = grp_srsi_prox)

grp_srsi_zone = '── Stoch RSI Overbought/Oversold Filter ──'
srsi_use_zone = input.bool(false, 'Enable Overbought/Oversold Filter', group = grp_srsi_zone)
ob_level = input.int(80, 'Overbought Level (K>X → Negative)', minval = 50, maxval = 99, group = grp_srsi_zone)
os_level = input.int(20, 'Oversold Level (K<X → Positive)', minval = 1, maxval = 50, group = grp_srsi_zone)

// ═══════════════════════════════════════════════════════════════════════════════
// MERGE SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════
grp_merge = '── Line Merging ──'
use_merge = input.bool(true, 'Merge Nearby Lines', group = grp_merge)
// Merge threshold automatic based on timeframe:
// >= 1 Day → 5% | between 1 Hour–1 Day → 2.5% | < 1 Hour → 1%
// Use the settings below if you want a manual override
use_manual_pct = input.bool(false, 'Use Manual Threshold', group = grp_merge)
merge_pct_man = input.float(0.2, 'Manual Merge Threshold (%)', minval = 0.01, maxval = 10.0, step = 0.01, group = grp_merge)
merge_color_sup = input.color(color.new(#FFD700, 0), 'Merged Support Color', group = grp_merge)
merge_color_res = input.color(color.new(#E040FB, 0), 'Merged Resistance Color', group = grp_merge)
merge_width = input.int(6, 'Merged Line Width', minval = 1, maxval = 8, group = grp_merge)

// ═══════════════════════════════════════════════════════════════════════════════
// INFO TABLE
// ═══════════════════════════════════════════════════════════════════════════════
grp_tbl = '── Info Table ──'
show_table = input.bool(true, 'Show Table', group = grp_tbl)
tbl_pos = input.string('Sağ Üst', 'Table Position', options = ['Sağ Üst', 'Sol Üst', 'Sağ Alt', 'Sol Alt'], group = grp_tbl)

// ═══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════════
// ── TIMEFRAME-BASED AUTOMATIC MERGE THRESHOLD ─────────────────────────────
// timeframe.in_seconds() → converts the current TF to seconds
tf_secs = timeframe.in_seconds()
tf_1h = 3600 // 1 hour = 3600 sec
tf_1d = 86400 // 1 day  = 86400 sec

// >= 1 day → 5% | 1h <= TF < 1d → 2.5% | < 1h → 1%
auto_pct = tf_secs >= tf_1d ? 5.0 : tf_secs >= tf_1h ? 3 : 1.0

merge_pct = use_manual_pct ? merge_pct_man : auto_pct

[macd_line, signal_line, _hist] = ta.macd(macd_src, fast_len, slow_len, signal_len)
macd_atr = ta.atr(macd_atr_len)

macd_bull_cross = ta.crossover(macd_line, signal_line)
macd_bear_cross = ta.crossunder(macd_line, signal_line)
macd_bull_valid = use_macd and macd_bull_cross and (not macd_use_zero or macd_line > 0)
macd_bear_valid = use_macd and macd_bear_cross and (not macd_use_zero or macd_line < 0)

rsi_val = ta.rsi(srsi_src, rsi_len)
rsi_low = ta.lowest(rsi_val, stoch_len)
rsi_high = ta.highest(rsi_val, stoch_len)
stoch = (rsi_val - rsi_low) / (rsi_high - rsi_low) * 100
k_line = ta.sma(stoch, k_smooth)
d_line = ta.sma(k_line, d_smooth)
srsi_atr = ta.atr(srsi_atr_len)

srsi_bull_cross = ta.crossover(k_line, d_line)
srsi_bear_cross = ta.crossunder(k_line, d_line)
srsi_bull_valid = use_srsi and srsi_bull_cross and (not srsi_use_zone or k_line < os_level)
srsi_bear_valid = use_srsi and srsi_bear_cross and (not srsi_use_zone or k_line > ob_level)

// ═══════════════════════════════════════════════════════════════════════════════
// DATA STORAGE
// ═══════════════════════════════════════════════════════════════════════════════
var array<float> macd_bull_prices = array.new_float()
var array<int> macd_bull_bars = array.new_int()
var array<float> macd_bear_prices = array.new_float()
var array<int> macd_bear_bars = array.new_int()
var array<float> srsi_bull_prices = array.new_float()
var array<int> srsi_bull_bars = array.new_int()
var array<float> srsi_bear_prices = array.new_float()
var array<int> srsi_bear_bars = array.new_int()

// ── PROXIMITY CHECK (at recording time) ─────────────────────────────
is_too_close(array<float> prices, float new_price, float threshold) =>
    bool found = false
    for p in prices
        if math.abs(p - new_price) < threshold
            found := true
            break
    found

macd_prox = macd_atr * macd_prox_atr_mult
srsi_prox = srsi_atr * srsi_prox_atr_mult

if macd_bull_valid
    np = low[macd_bars_before]
    if not(macd_use_prox and is_too_close(macd_bull_prices, np, macd_prox))
        array.push(macd_bull_prices, np)
        array.push(macd_bull_bars, bar_index)

if macd_bear_valid
    np = high[macd_bars_before]
    if not(macd_use_prox and is_too_close(macd_bear_prices, np, macd_prox))
        array.push(macd_bear_prices, np)
        array.push(macd_bear_bars, bar_index)

if srsi_bull_valid
    np = low[srsi_bars_before]
    if not(srsi_use_prox and is_too_close(srsi_bull_prices, np, srsi_prox))
        array.push(srsi_bull_prices, np)
        array.push(srsi_bull_bars, bar_index)

if srsi_bear_valid
    np = high[srsi_bars_before]
    if not(srsi_use_prox and is_too_close(srsi_bear_prices, np, srsi_prox))
        array.push(srsi_bear_prices, np)
        array.push(srsi_bear_bars, bar_index)

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════
get_extend(string mode) =>
    mode == 'Sağa Sonsuz' ? extend.right : mode == 'İki Yön Sonsuz' ? extend.both : extend.none

get_tbl_pos() =>
    tbl_pos == 'Sol Üst' ? position.top_left : tbl_pos == 'Sağ Alt' ? position.bottom_right : tbl_pos == 'Sol Alt' ? position.bottom_left : position.top_right

// ═══════════════════════════════════════════════════════════════════════════════
// MERGE ALGORITHM
// Gather all visible lines (bull+bear, macd+srsi) into a single pool,
// group lines within %merge_pct proximity and average them.
// Merged lines → separate color; single lines → their own colors.
// ═══════════════════════════════════════════════════════════════════════════════

// Metadata for a single line
// type: 0=macd_bull, 1=macd_bear, 2=srsi_bull, 3=srsi_bear
build_pool(array<float> mb_p, array<int> mb_b, int mb_s, int mb_t, array<float> mr_p, array<int> mr_b, int mr_s, int mr_t, array<float> sb_p, array<int> sb_b, int sb_s, int sb_t, array<float> sr_p, array<int> sr_b, int sr_s, int sr_t) =>
    array<float> pool_prices = array.new_float()
    array<int> pool_bars = array.new_int()
    array<int> pool_types = array.new_int() // 0=mb,1=mr,2=sb,3=sr

    if mb_t > 0 and mb_s <= mb_t - 1
        for i = mb_s to mb_t - 1 by 1
            array.push(pool_prices, array.get(mb_p, i))
            array.push(pool_bars, array.get(mb_b, i))
            array.push(pool_types, 0)
    if mr_t > 0 and mr_s <= mr_t - 1
        for i = mr_s to mr_t - 1 by 1
            array.push(pool_prices, array.get(mr_p, i))
            array.push(pool_bars, array.get(mr_b, i))
            array.push(pool_types, 1)
    if sb_t > 0 and sb_s <= sb_t - 1
        for i = sb_s to sb_t - 1 by 1
            array.push(pool_prices, array.get(sb_p, i))
            array.push(pool_bars, array.get(sb_b, i))
            array.push(pool_types, 2)
    if sr_t > 0 and sr_s <= sr_t - 1
        for i = sr_s to sr_t - 1 by 1
            array.push(pool_prices, array.get(sr_p, i))
            array.push(pool_bars, array.get(sr_b, i))
            array.push(pool_types, 3)
    [pool_prices, pool_bars, pool_types]

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW LINES
// ═══════════════════════════════════════════════════════════════════════════════
var array<line> active_lines = array.new_line()
var array<label> active_labels = array.new_label()
var table info_table = na

if barstate.islast
    for ln in active_lines
        line.delete(ln)
    for lbl in active_labels
        label.delete(lbl)
    array.clear(active_lines)
    array.clear(active_labels)

    // Collecting the actual prices of the drawn (merged) lines here
    // This array is the SINGLE SOURCE for the "Nearest Support/Resistance" calculation in the table
    array<float> drawn_prices = array.new_float()

    // Calculate visible ranges
    mb_total = array.size(macd_bull_prices)
    mb_start = math.max(0, mb_total - macd_max_sup)
    mr_total = array.size(macd_bear_prices)
    mr_start = math.max(0, mr_total - macd_max_res)
    sb_total = array.size(srsi_bull_prices)
    sb_start = math.max(0, sb_total - srsi_max_sup)
    sr_total = array.size(srsi_bear_prices)
    sr_start = math.max(0, sr_total - srsi_max_res)

    // Gather all visible lines into the pool
    [pool_prices, pool_bars, pool_types] = build_pool(macd_bull_prices, macd_bull_bars, mb_start, mb_total, macd_bear_prices, macd_bear_bars, mr_start, mr_total, srsi_bull_prices, srsi_bull_bars, sb_start, sb_total, srsi_bear_prices, srsi_bear_bars, sr_start, sr_total)

    pool_size = array.size(pool_prices)

    // Track which lines have already been assigned to a group
    array<bool> assigned = array.new_bool(pool_size, false)

    // Draw each line
    if pool_size > 0
        for i = 0 to pool_size - 1 by 1
            if array.get(assigned, i)
                continue

            base_price = array.get(pool_prices, i)
            base_type = array.get(pool_types, i)
            threshold = base_price * merge_pct / 100.0

            // Find all lines close to this one (merge group)
            float grp_sum = base_price
            int grp_count = 1
            int grp_bar = array.get(pool_bars, i)
            array.set(assigned, i, true)

            bool is_merged = false

            if use_merge and i + 1 <= pool_size - 1
                for j = i + 1 to pool_size - 1 by 1
                    if not array.get(assigned, j)
                        other_price = array.get(pool_prices, j)
                        if math.abs(other_price - base_price) <= threshold
                            grp_sum := grp_sum + other_price
                            grp_count := grp_count + 1
                            // Use the oldest bar (for the line's starting point)
                            if array.get(pool_bars, j) < grp_bar
                                grp_bar := array.get(pool_bars, j)
                                grp_bar
                            array.set(assigned, j, true)
                            is_merged := true
                            is_merged

            avg_price = grp_sum / grp_count

            // Determine color and label
            color line_col = na
            string lbl_pfx = ''
            int lw = 2
            int lext = 50
            string ext_mode = 'Sabit Bar'

            if is_merged
                // Merged line → merge color
                line_col := avg_price < close ? merge_color_sup : merge_color_res
                lbl_pfx := ' ⬡' + str.tostring(grp_count) + ' '
                lw := merge_width
                // Extend: use the longer extend mode (or fixed bar)
                lext := math.max(macd_line_extend, srsi_line_extend)
                ext_mode := 'Sabit Bar'
                ext_mode
            else // Single line → its own color
                if base_type == 0
                    sc = macd_sup_color
                    rc = macd_res_color
                    line_col := avg_price < close ? sc : rc
                    lbl_pfx := ' M '
                    lw := macd_line_width
                    lext := macd_line_extend
                    ext_mode := macd_extend_mode
                    ext_mode
                else if base_type == 1
                    sc = macd_sup_color
                    rc = macd_res_color
                    line_col := avg_price < close ? sc : rc
                    lbl_pfx := ' M '
                    lw := macd_line_width
                    lext := macd_line_extend
                    ext_mode := macd_extend_mode
                    ext_mode
                else if base_type == 2
                    sc = srsi_sup_color
                    rc = srsi_res_color
                    line_col := avg_price < close ? sc : rc
                    lbl_pfx := ' S '
                    lw := srsi_line_width
                    lext := srsi_line_extend
                    ext_mode := srsi_extend_mode
                    ext_mode
                else
                    sc = srsi_sup_color
                    rc = srsi_res_color
                    line_col := avg_price < close ? sc : rc
                    lbl_pfx := ' S '
                    lw := srsi_line_width
                    lext := srsi_line_extend
                    ext_mode := srsi_extend_mode
                    ext_mode

            ext = get_extend(ext_mode)
            x1 = grp_bar - math.max(macd_bars_before, srsi_bars_before)
            x2 = bar_index + lext

            ln = line.new(x1, avg_price, x2, avg_price, color = color.new(line_col, 50), width = lw, style = line.style_solid, extend = ext)
            array.push(active_lines, ln)
            // Save the actually drawn price — the table will read from this list
            array.push(drawn_prices, avg_price)

            // Label display — merged lines are always shown
            show_lbl = is_merged or base_type == 0 and macd_show_label or base_type == 1 and macd_show_label or base_type == 2 and srsi_show_label or base_type == 3 and srsi_show_label

            if show_lbl
                arrow = avg_price < close ? '▲' : '▼'
                lbl_txt = arrow + lbl_pfx + str.tostring(math.round(avg_price, 4))
                lbl = label.new(x2, avg_price, text = lbl_txt, color = color.new(line_col, 70), textcolor = line_col, style = label.style_label_left, size = size.small)
                array.push(active_labels, lbl)

    // ── INFO TABLE ────────────────────────────────────────────────────────
    if show_table
        if not na(info_table)
            table.delete(info_table)

        info_table := table.new(get_tbl_pos(), 3, 8, bgcolor = color.new(#1E1E2E, 10), border_color = color.new(#444466, 0), border_width = 1, frame_color = color.new(#6666AA, 0), frame_width = 1)

        ts = size.tiny

        table.cell(info_table, 0, 0, '', text_color = #A0A0CC, text_size = ts, bgcolor = color.new(#2A2A4A, 0))
        table.cell(info_table, 1, 0, 'MACD', text_color = #A0A0CC, text_size = ts, bgcolor = color.new(#2A2A4A, 0), text_halign = text.align_center)
        table.cell(info_table, 2, 0, 'StochRSI', text_color = #A0A0CC, text_size = ts, bgcolor = color.new(#2A2A4A, 0), text_halign = text.align_center)

        table.cell(info_table, 0, 1, 'Support', text_color = #888888, text_size = ts)
        table.cell(info_table, 1, 1, str.tostring(math.min(mb_total, macd_max_sup)), text_color = macd_sup_color, text_size = ts, text_halign = text.align_center)
        table.cell(info_table, 2, 1, str.tostring(math.min(sb_total, srsi_max_sup)), text_color = srsi_sup_color, text_size = ts, text_halign = text.align_center)

        table.cell(info_table, 0, 2, 'Resistance', text_color = #888888, text_size = ts)
        table.cell(info_table, 1, 2, str.tostring(math.min(mr_total, macd_max_res)), text_color = macd_res_color, text_size = ts, text_halign = text.align_center)
        table.cell(info_table, 2, 2, str.tostring(math.min(sr_total, srsi_max_res)), text_color = srsi_res_color, text_size = ts, text_halign = text.align_center)

        // Nearest support/resistance — from the ACTUALLY DRAWN (post-merge) prices.
        // The highest value just below close = nearest support (same source as the "▲" label)
        // The lowest value just above close = nearest resistance (same source as the "▼" label)
        float best_sup = na
        float best_res = na
        for p in drawn_prices
            if p < close
                if na(best_sup) or p > best_sup
                    best_sup := p
                    best_sup
            else if p > close
                if na(best_res) or p < best_res
                    best_res := p
                    best_res

        sup_txt = na(best_sup) ? '—' : str.tostring(math.round(best_sup, 4))
        res_txt = na(best_res) ? '—' : str.tostring(math.round(best_res, 4))

        table.cell(info_table, 0, 3, 'Nearest Support', text_color = #888888, text_size = ts)
        table.cell(info_table, 1, 3, sup_txt, text_color = color.new(#00E676, 0), text_size = ts, text_halign = text.align_center)
        table.merge_cells(info_table, 1, 3, 2, 3)

        table.cell(info_table, 0, 4, 'Nearest Resistance', text_color = #888888, text_size = ts)
        table.cell(info_table, 1, 4, res_txt, text_color = color.new(#FF1744, 0), text_size = ts, text_halign = text.align_center)
        table.merge_cells(info_table, 1, 4, 2, 4)

        table.cell(info_table, 0, 5, 'Filter', text_color = #888888, text_size = ts)
        table.cell(info_table, 1, 5, macd_use_zero ? 'Active ✓' : 'Inactive', text_color = macd_use_zero ? color.new(#00E676, 0) : color.new(#888888, 0), text_size = ts, text_halign = text.align_center)
        table.cell(info_table, 2, 5, srsi_use_zone ? 'Active ✓' : 'Inactive', text_color = srsi_use_zone ? color.new(#00E676, 0) : color.new(#888888, 0), text_size = ts, text_halign = text.align_center)

        table.cell(info_table, 0, 6, 'Active', text_color = #888888, text_size = ts)
        table.cell(info_table, 1, 6, use_macd ? '✓' : '✗', text_color = use_macd ? color.new(#00E676, 0) : color.new(#FF1744, 0), text_size = ts, text_halign = text.align_center)
        table.cell(info_table, 2, 6, use_srsi ? '✓' : '✗', text_color = use_srsi ? color.new(#00E676, 0) : color.new(#FF1744, 0), text_size = ts, text_halign = text.align_center)

        // Merge threshold info
        pct_lbl = use_manual_pct ? 'Manual' : tf_secs >= tf_1d ? '≥1D' : tf_secs >= tf_1h ? '1H-1D' : '<1H'
        table.cell(info_table, 0, 7, 'Merge %', text_color = #888888, text_size = ts)
        table.cell(info_table, 1, 7, str.tostring(merge_pct, '#.##') + '% (' + pct_lbl + ')', text_color = merge_color_sup, text_size = ts, text_halign = text.align_center)
        table.merge_cells(info_table, 1, 7, 2, 7)

// ═══════════════════════════════════════════════════════════════════════════════
// CROSSOVER POINTS
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(macd_bull_valid, 'MACD Positive', shape.triangleup, location.belowbar, color.new(#00E676, 0), size = size.small)
plotshape(macd_bear_valid, 'MACD Negative', shape.triangledown, location.abovebar, color.new(#FF1744, 0), size = size.small)
plotshape(srsi_bull_valid, 'StochRSI Positive', shape.triangleup, location.belowbar, color.new(#00B0FF, 0), size = size.tiny)
plotshape(srsi_bear_valid, 'StochRSI Negative', shape.triangledown, location.abovebar, color.new(#FF6D00, 0), size = size.tiny)
````
