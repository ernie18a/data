# FVG+OB Hunter -Free- [AlgoTrader Pro]

- url: https://www.tradingview.com/script/26xb5FaN-FVG-OB-Hunter-Free-AlgoTrader-Pro/
- type: indicator
- pine_id: PUB;6cca6f4c69fa40c3b90588cfc1f35c14
- version: 1.0

## Description

[b]FVG + OB Hunter (Free) [AlgoTraderPro][/b]

Fair Value Gaps and Order Blocks are the foundation of Smart Money Concepts trading. This free indicator detects both automatically, draws them on your chart, and tracks each zone until it is mitigated—so you always know which support and resistance zones are still live.

[b]Core functions[/b]
[list]
[*]Detects Bullish and Bearish [b]Fair Value Gaps[/b] (3-candle imbalances) and marks them as support/resistance zones
[*]Identifies [b]Supply and Demand Order Blocks[/b]—the last opposing candle before a strong impulse move
[*]Extends each zone to the right with semi-transparent boxes and [b]auto-deletes [/b] it when mitigated
[*]Live Nearest-Zones table: the closest zones above and below price, with entry, range and distance
[/list]

[b]How detection works[/b]

A Bearish FVG forms when the current candle's high is below the low two bars prior; a Bullish FVG when the current low is above the high two bars prior. When a gap forms, the indicator scans back up to OB Scan Lookback bars (default 10) for the last opposing candle—its body becomes the Order Block. Each zone extends right with every bar and is removed when price closes through it (invalidated) or closes beyond the far edge after entry (mitigated). Only unmitigated, live zones stay on the chart.

[b]The Nearest-Zones table[/b]

Four rows—nearest Bear FVG and Supply OB above, nearest Bull FVG and Demand OB below—sorted by distance to price. Columns: [b]ZONE | ENTRY | RANGE | DIST[/b], where ENTRY is the near edge and DIST is the percent distance from the current close. Positionable in any corner.

[b]Settings[/b]

Show Bearish FVG · Show Bullish FVG · Show Order Blocks · Show Nearest-Zones Table · zone colours · Extension Transparency (60–99) · OB Scan Lookback (3–50, how far back the opposing OB candle is sought) · Table Position. All inputs carry tooltips.

[b]How to use it[/b]

The near edge (ENTRY) of an unmitigated zone is a support/resistance reference—for limit entries, for placing protective stops just beyond a zone, or simply to see where price is likely to react. The table keeps the nearest levels and their distances in view at all times.

[b]Credits & compatibility[/b]

Fair Value Gaps and Order Blocks are Smart Money Concepts popularised by the ICT / SMC community. This is an original, independent PineScript v6 implementation of those concepts; no third-party code is used. Works on all assets and all timeframes and is compatible with all TradingView plans.

This is the free edition. An extended edition that additionally grades each zone (A / B / C), tags it by trend and volume, highlights the strongest confluence setups, and fires alerts is also available.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algoTraderGTP

//@version=6
indicator('FVG + OB Hunter -Free- [AlgoTrader Pro]', overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ─── INPUTS: Display ──────────────────────────────────────────────────────────
var g = '=== Display ==='
bool   show_bear_fvg = input.bool(true,  'Show Bearish FVG',
    tooltip  = 'Show/hide boxes for bearish Fair Value Gaps — resistance zones above price where price may return and reverse downward.',
    group    = g)
bool   show_bull_fvg = input.bool(true,  'Show Bullish FVG',
    tooltip  = 'Show/hide boxes for bullish Fair Value Gaps — support zones below price where price may return and reverse upward.',
    group    = g)
bool   show_ob       = input.bool(true,  'Show Order Blocks',
    tooltip  = 'Show/hide Order Block boxes. An OB is the last opposing candle before an impulsive move — it marks where institutional orders were placed. OBs are detected alongside FVGs.',
    group    = g)
bool   show_table    = input.bool(true,  'Show Nearest Zones Table',
    tooltip  = 'Show the summary table listing the nearest active FVG and OB above and below current price, with entry level, range, and distance %.',
    group    = g)
color  bear_col      = input.color(color.new(color.red,    50), 'Bearish FVG Colour',
    tooltip  = 'Color used for bearish FVG boxes.',
    group    = g)
color  bull_col      = input.color(color.new(color.lime,   50), 'Bullish FVG Colour',
    tooltip  = 'Color used for bullish FVG boxes.',
    group    = g)
color  ob_col        = input.color(color.new(color.orange, 50), 'Order Block Colour',
    tooltip  = 'Color used for Order Block boxes.',
    group    = g)
int    ext_transp    = input.int(85, 'Extension Transparency',
    minval   = 60, maxval = 99,
    tooltip  = 'Transparency of the extension box that projects each zone forward to the current bar. Higher = more faded.',
    group    = g)
int    ob_lookback   = input.int(10, 'OB Scan Lookback (bars)',
    minval   = 3, maxval = 50,
    tooltip  = 'When an FVG fires, the indicator scans this many bars back to find the last opposing candle — that candle becomes the Order Block. Does NOT limit how far back FVGs are detected.',
    group    = g)
string tbl_pos_in    = input.string('Top Right', 'Table Position',
    options  = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'],
    tooltip  = 'Corner of the chart where the nearest-zones summary table is anchored.',
    group    = g)

// ─── DERIVED COLORS ───────────────────────────────────────────────────────────
bear_ext_col = color.new(bear_col, ext_transp)
bull_ext_col = color.new(bull_col, ext_transp)
ob_ext_col   = color.new(ob_col,   ext_transp)

// ─── TABLE POSITION ───────────────────────────────────────────────────────────
tbl_pos = tbl_pos_in == 'Top Left'     ? position.top_left    :
          tbl_pos_in == 'Bottom Right' ? position.bottom_right :
          tbl_pos_in == 'Bottom Left'  ? position.bottom_left  :
                                         position.top_right

// ─── TABLE HELPERS (script scope — cannot be inside if blocks) ────────────────
f_p(v)              => na(v) ? '—' : str.tostring(v, format.mintick)
f_rng(t, b)         => na(t) or na(b) ? '—' : str.tostring(b, format.mintick) + ' – ' + str.tostring(t, format.mintick)
f_pct(d, is_above)  => na(d) ? '—' : (is_above ? '+' : '-') + str.tostring(math.round(d, 1)) + '%'

// ─── STATE ARRAYS ─────────────────────────────────────────────────────────────
var box[]    fvg_box     = array.new<box>()
var float[]  fvg_top     = array.new<float>()
var float[]  fvg_bot     = array.new<float>()
var bool[]   fvg_bear    = array.new<bool>()
var int[]    fvg_bars    = array.new<int>()
var bool[]   fvg_entered = array.new<bool>()

var box[]    ob_box  = array.new<box>()
var float[]  ob_tops = array.new<float>()
var float[]  ob_bots = array.new<float>()
var bool[]   ob_bull = array.new<bool>()
var int[]    ob_bars = array.new<int>()

// ─── TABLE ────────────────────────────────────────────────────────────────────
var table zt = show_table ? table.new(tbl_pos, 4, 6,
    bgcolor      = color.new(color.black, 80),
    border_color = color.new(color.gray,  50),
    border_width = 1) : na

// ─── FVG DETECTION ────────────────────────────────────────────────────────────
bear_fvg = low[2] <= open[1] and high[0] >= close[1] and low[2] - high[0] > 0
bull_fvg = high[2] >= open[1] and low[0] <= close[1] and low[0] - high[2] > 0

// ─── HELPER: most recent candle of given direction ────────────────────────────
f_last_ob(seek_down, lookback) =>
    result = -1
    found  = false
    for j = 1 to lookback
        if not found and (seek_down ? close[j] < open[j] : close[j] > open[j])
            result := j
            found  := true
    result

// ─── NEW BEARISH FVG + SUPPLY OB ─────────────────────────────────────────────
if bear_fvg
    t = low[2]
    b = high[0]
    if show_bear_fvg
        box.new(bar_index[1], t, bar_index, b, bgcolor = bear_col, border_color = bear_col)
        e = box.new(bar_index, t, bar_index + 1, b, bgcolor = bear_ext_col, border_color = bear_ext_col)
        array.push(fvg_box,     e)
        array.push(fvg_top,     t)
        array.push(fvg_bot,     b)
        array.push(fvg_bear,    true)
        array.push(fvg_bars,    bar_index)
        array.push(fvg_entered, false)

    j = f_last_ob(false, ob_lookback)
    if j > 0 and show_ob
        obt = math.max(open[j], close[j])
        obb = math.min(open[j], close[j])
        box.new(bar_index - j, obt, bar_index - j + 1, obb, bgcolor = ob_col, border_color = ob_col)
        oe = box.new(bar_index, obt, bar_index + 1, obb, bgcolor = ob_ext_col, border_color = ob_ext_col)
        array.push(ob_box,  oe)
        array.push(ob_tops, obt)
        array.push(ob_bots, obb)
        array.push(ob_bull, false)
        array.push(ob_bars, bar_index)

// ─── NEW BULLISH FVG + DEMAND OB ─────────────────────────────────────────────
if bull_fvg
    t = low[0]
    b = high[2]
    if show_bull_fvg
        box.new(bar_index[1], t, bar_index, b, bgcolor = bull_col, border_color = bull_col)
        e = box.new(bar_index, t, bar_index + 1, b, bgcolor = bull_ext_col, border_color = bull_ext_col)
        array.push(fvg_box,     e)
        array.push(fvg_top,     t)
        array.push(fvg_bot,     b)
        array.push(fvg_bear,    false)
        array.push(fvg_bars,    bar_index)
        array.push(fvg_entered, false)

    j = f_last_ob(true, ob_lookback)
    if j > 0 and show_ob
        obt = math.max(open[j], close[j])
        obb = math.min(open[j], close[j])
        box.new(bar_index - j, obt, bar_index - j + 1, obb, bgcolor = ob_col, border_color = ob_col)
        oe = box.new(bar_index, obt, bar_index + 1, obb, bgcolor = ob_ext_col, border_color = ob_ext_col)
        array.push(ob_box,  oe)
        array.push(ob_tops, obt)
        array.push(ob_bots, obb)
        array.push(ob_bull, true)
        array.push(ob_bars, bar_index)

// ─── EXTEND / ENTER / MITIGATE: FVG ──────────────────────────────────────────
n = array.size(fvg_box)
if n > 0
    for i = n - 1 to 0
        t       = array.get(fvg_top,     i)
        b       = array.get(fvg_bot,     i)
        is_bear = array.get(fvg_bear,    i)
        det_bar = array.get(fvg_bars,    i)
        entered = array.get(fvg_entered, i)

        if bar_index > det_bar
            touched = is_bear ? high >= b : low <= t
            if touched and not entered
                entered := true
                array.set(fvg_entered, i, true)

            blow_through  = is_bear ? close > t : close < b
            orders_filled = entered and (is_bear ? close < b : close > t)
            if blow_through or orders_filled
                box.delete(array.get(fvg_box, i))
                array.remove(fvg_box,     i)
                array.remove(fvg_top,     i)
                array.remove(fvg_bot,     i)
                array.remove(fvg_bear,    i)
                array.remove(fvg_bars,    i)
                array.remove(fvg_entered, i)
            else
                box.set_right(array.get(fvg_box, i), bar_index + 1)
        else
            box.set_right(array.get(fvg_box, i), bar_index + 1)

// ─── EXTEND OR MITIGATE: OB ──────────────────────────────────────────────────
m = array.size(ob_box)
if m > 0
    for i = m - 1 to 0
        t       = array.get(ob_tops, i)
        b       = array.get(ob_bots, i)
        is_bull = array.get(ob_bull, i)
        det_bar = array.get(ob_bars, i)
        if bar_index > det_bar and (is_bull ? low <= b : high >= t)
            box.delete(array.get(ob_box, i))
            array.remove(ob_box,  i)
            array.remove(ob_tops, i)
            array.remove(ob_bots, i)
            array.remove(ob_bull, i)
            array.remove(ob_bars, i)
        else
            box.set_right(array.get(ob_box, i), bar_index + 1)

// ─── SCAN: nearest zones above and below current close ────────────────────────
// Variables reset each bar (non-var)
bfa_dist = float(na)   // bear FVG above
bfa_top  = float(na)
bfa_bot  = float(na)

soa_dist = float(na)   // supply OB above
soa_top  = float(na)
soa_bot  = float(na)

bfb_dist = float(na)   // bull FVG below
bfb_top  = float(na)
bfb_bot  = float(na)

dob_dist = float(na)   // demand OB below
dob_top  = float(na)
dob_bot  = float(na)

nf = array.size(fvg_box)
if nf > 0
    for i = 0 to nf - 1
        ft  = array.get(fvg_top,  i)
        fb  = array.get(fvg_bot,  i)
        fib = array.get(fvg_bear, i)
        if fib and fb >= close
            d = (fb - close) / close * 100
            if na(bfa_dist) or d < bfa_dist
                bfa_dist := d
                bfa_top  := ft
                bfa_bot  := fb
        if not fib and ft <= close
            d = (close - ft) / close * 100
            if na(bfb_dist) or d < bfb_dist
                bfb_dist := d
                bfb_top  := ft
                bfb_bot  := fb

no = array.size(ob_box)
if no > 0
    for i = 0 to no - 1
        ot  = array.get(ob_tops, i)
        obo = array.get(ob_bots, i)
        oib = array.get(ob_bull, i)
        if not oib and obo >= close
            d = (obo - close) / close * 100
            if na(soa_dist) or d < soa_dist
                soa_dist := d
                soa_top  := ot
                soa_bot  := obo
        if oib and ot <= close
            d = (close - ot) / close * 100
            if na(dob_dist) or d < dob_dist
                dob_dist := d
                dob_top  := ot
                dob_bot  := obo

// ─── TABLE UPDATE ─────────────────────────────────────────────────────────────
T_BG = color.new(color.black,  0)
T_TC = color.white
H_BG = color.new(color.gray,  20)
H_TC = color.white
R_BG = color.new(color.red,   85)
S_BG = color.new(color.lime,  90)
E_BG = color.new(color.black, 70)
D_TC = color.new(color.gray,  40)
Z_TC = color.new(color.white, 10)

if show_table and not na(zt)
    // Row 0: title — merged across all 4 columns
    table.cell(zt, 0, 0, ' FVG + OB Hunter (Free) ', text_color = T_TC, bgcolor = T_BG, text_size = size.small)
    table.cell(zt, 1, 0, '', text_color = T_TC, bgcolor = T_BG, text_size = size.small)
    table.cell(zt, 2, 0, '', text_color = T_TC, bgcolor = T_BG, text_size = size.small)
    table.cell(zt, 3, 0, '', text_color = T_TC, bgcolor = T_BG, text_size = size.small)
    table.merge_cells(zt, 0, 0, 3, 0)

    // Row 1: header
    table.cell(zt, 0, 1, ' ZONE ',  text_color = H_TC, bgcolor = H_BG, text_size = size.small)
    table.cell(zt, 1, 1, ' ENTRY ', text_color = H_TC, bgcolor = H_BG, text_size = size.small)
    table.cell(zt, 2, 1, ' RANGE ', text_color = H_TC, bgcolor = H_BG, text_size = size.small)
    table.cell(zt, 3, 1, ' DIST ',  text_color = H_TC, bgcolor = H_BG, text_size = size.small)

    // Sort resistance rows: closer zone (lower bot = nearer from above) → row 3, farther → row 2
    bfa_is_closer = not na(bfa_bot) and (na(soa_bot) or bfa_bot <= soa_bot)
    r2_lbl  = bfa_is_closer ? ' ↑ Supply OB ' : ' ↑ Bear FVG '
    r2_has  = bfa_is_closer ? not na(soa_bot) : not na(bfa_bot)
    r2_top  = bfa_is_closer ? soa_top         : bfa_top
    r2_bot  = bfa_is_closer ? soa_bot         : bfa_bot
    r2_dist = bfa_is_closer ? soa_dist        : bfa_dist
    r3_lbl  = bfa_is_closer ? ' ↑ Bear FVG '  : ' ↑ Supply OB '
    r3_has  = bfa_is_closer ? not na(bfa_bot) : not na(soa_bot)
    r3_top  = bfa_is_closer ? bfa_top         : soa_top
    r3_bot  = bfa_is_closer ? bfa_bot         : soa_bot
    r3_dist = bfa_is_closer ? bfa_dist        : soa_dist

    // Sort support rows: closer zone (higher top = nearer from below) → row 4, farther → row 5
    bfb_is_closer = not na(bfb_top) and (na(dob_top) or bfb_top >= dob_top)
    r4_lbl  = bfb_is_closer ? ' ↓ Bull FVG '  : ' ↓ Demand OB '
    r4_has  = bfb_is_closer ? not na(bfb_top) : not na(dob_top)
    r4_top  = bfb_is_closer ? bfb_top         : dob_top
    r4_bot  = bfb_is_closer ? bfb_bot         : dob_bot
    r4_dist = bfb_is_closer ? bfb_dist        : dob_dist
    r5_lbl  = bfb_is_closer ? ' ↓ Demand OB ' : ' ↓ Bull FVG '
    r5_has  = bfb_is_closer ? not na(dob_top) : not na(bfb_top)
    r5_top  = bfb_is_closer ? dob_top         : bfb_top
    r5_bot  = bfb_is_closer ? dob_bot         : bfb_bot
    r5_dist = bfb_is_closer ? dob_dist        : bfb_dist

    // Row 2: farther resistance zone above
    r2_bg = r2_has ? R_BG : E_BG
    r2_tc = r2_has ? Z_TC : D_TC
    table.cell(zt, 0, 2, r2_lbl,                            text_color = r2_tc, bgcolor = r2_bg, text_size = size.small)
    table.cell(zt, 1, 2, ' ' + f_p(r2_bot) + ' ',          text_color = r2_tc, bgcolor = r2_bg, text_size = size.small)
    table.cell(zt, 2, 2, ' ' + f_rng(r2_top, r2_bot) + ' ', text_color = r2_tc, bgcolor = r2_bg, text_size = size.small)
    table.cell(zt, 3, 2, ' ' + f_pct(r2_dist, true) + ' ',  text_color = r2_tc, bgcolor = r2_bg, text_size = size.small)

    // Row 3: closer resistance zone above (nearest to price)
    r3_bg = r3_has ? R_BG : E_BG
    r3_tc = r3_has ? Z_TC : D_TC
    table.cell(zt, 0, 3, r3_lbl,                            text_color = r3_tc, bgcolor = r3_bg, text_size = size.small)
    table.cell(zt, 1, 3, ' ' + f_p(r3_bot) + ' ',          text_color = r3_tc, bgcolor = r3_bg, text_size = size.small)
    table.cell(zt, 2, 3, ' ' + f_rng(r3_top, r3_bot) + ' ', text_color = r3_tc, bgcolor = r3_bg, text_size = size.small)
    table.cell(zt, 3, 3, ' ' + f_pct(r3_dist, true) + ' ',  text_color = r3_tc, bgcolor = r3_bg, text_size = size.small)

    // Row 4: closer support zone below (nearest to price)
    r4_bg = r4_has ? S_BG : E_BG
    r4_tc = r4_has ? Z_TC : D_TC
    table.cell(zt, 0, 4, r4_lbl,                            text_color = r4_tc, bgcolor = r4_bg, text_size = size.small)
    table.cell(zt, 1, 4, ' ' + f_p(r4_top) + ' ',          text_color = r4_tc, bgcolor = r4_bg, text_size = size.small)
    table.cell(zt, 2, 4, ' ' + f_rng(r4_top, r4_bot) + ' ', text_color = r4_tc, bgcolor = r4_bg, text_size = size.small)
    table.cell(zt, 3, 4, ' ' + f_pct(r4_dist, false) + ' ', text_color = r4_tc, bgcolor = r4_bg, text_size = size.small)

    // Row 5: farther support zone below
    r5_bg = r5_has ? S_BG : E_BG
    r5_tc = r5_has ? Z_TC : D_TC
    table.cell(zt, 0, 5, r5_lbl,                            text_color = r5_tc, bgcolor = r5_bg, text_size = size.small)
    table.cell(zt, 1, 5, ' ' + f_p(r5_top) + ' ',          text_color = r5_tc, bgcolor = r5_bg, text_size = size.small)
    table.cell(zt, 2, 5, ' ' + f_rng(r5_top, r5_bot) + ' ', text_color = r5_tc, bgcolor = r5_bg, text_size = size.small)
    table.cell(zt, 3, 5, ' ' + f_pct(r5_dist, false) + ' ', text_color = r5_tc, bgcolor = r5_bg, text_size = size.small)
````
