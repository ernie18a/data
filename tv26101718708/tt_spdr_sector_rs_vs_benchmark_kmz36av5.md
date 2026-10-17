# TT - SPDR Sector RS vs Benchmark

- url: https://www.tradingview.com/script/kMZ36av5-TT-SPDR-Sector-RS-vs-Benchmark/
- type: indicator
- pine_id: PUB;446b3bff9e5a45e38ba02cba2d012d46
- version: 1.0

## Description

SPDR Sector Relative Strength vs Benchmark

A top-down dashboard that ranks the 11 S&P 500 SPDR sector ETFs by how strongly each is outperforming or underperforming a benchmark (SPY by default) across multiple timeframes — plus a momentum read on which sectors are gaining or losing ground. Built for traders who want to find the strongest sectors first, then hunt individual stock setups inside them.


WHAT IS RELATIVE STRENGTH?

Relative strength (RS) here means a sector's return minus the benchmark's return over the same window. If XLK returns +8% over a month while SPY returns +5%, XLK's RS is +3% — it beat the market by three points. A positive number means the sector is leading; negative means it's lagging. This is more useful than raw return for sector rotation, because it tells you where money is flowing relative to the broad index, not just whether things went up.


HOW TO READ THE TABLE

- 1D / 1W / 1M / 3M / 6M / 1Y — relative strength over each trailing window. Green = beating the benchmark, red = lagging. Each column can be toggled on or off, and the cell colour deepens with the size of the move so you can read the whole grid at a glance.

- Score — the average relative strength across every enabled timeframe, giving you a single ranking number. A sector that's green across all horizons is a more durable leader than one that's only popped on a single window.

- Mom (Momentum) — whether relative strength is improving or deteriorating, by comparing a recent window against an older one. Positive (green) means strength is building; negative (red) means it's fading. This is often where rotation shows up before it's obvious in the raw RS columns.


MOMENTUM MODES

Momentum offers three calculations (Settings > Momentum Mode):

- Level diff — the raw difference between the recent and older RS. Simplest, but biased: a longer window naturally accumulates a bigger number, so it can mislead.

- Pace (per-bar) — rescales the older window to the recent window's length before comparing, removing that size bias.

- Pace (non-overlap) — compares the most recent stretch against the separate, earlier stretch before it. This is a true acceleration measure and the best early signal of a sector quietly turning up or rolling over. It's the default.

Tip: a sector showing a shrinking negative in the raw columns isn't necessarily recovering — shorter windows always show smaller cumulative numbers. The pace modes correct for this and reveal whether the sector is actually decelerating or still getting worse, faster.


KEY SETTINGS

- Benchmark — what each sector is measured against. Swap SPY for QQQ, IWM, or any symbol.
- Measurement Timeframe — the bar size lookbacks are counted in. Daily is recommended, where 5 bars ≈ 1 week, 21 ≈ 1 month, 63 ≈ 3 months, 126 ≈ 6 months, 252 ≈ 1 year.
- RS Columns Show — Cumulative (total RS per window) or Per-Month Rate (RS divided by the months in each window) for an apples-to-apples monthly pace across columns.
- Gradient Scale — Auto (each column scaled to its own strongest sector) or Manual (a fixed percentage maps to the deepest colour, so every column shares one scale).
- Plus full control of table position, size, font, colours and which columns are shown.


A SUGGESTED WORKFLOW

1. Sort by Score (or Momentum) descending.
2. Favour sectors that are both strong (high Score) AND strengthening (positive Momentum) — that combination tends to flag leadership early rather than late.
3. Drill into the top one or two sectors and look for individual stock candidates there. Skip the laggards.
4. For shorter holds, lean on the 1W / 1M columns and momentum; for swing positions, weight the 3M / 6M horizons.


NOTES

- When a column is set to a higher timeframe than your chart, its value updates until that higher-timeframe bar closes. This is expected behaviour, not repainting of confirmed bars.
- In Per-Month Rate mode the 1D and 1W columns get extrapolated to a full month and will look large and noisy — untick them and lean on the 1M–1Y columns in that mode.
- Sector weights are deliberately not used; index weighting tells you what moves SPY, not where the best opportunities are.

This script is an analysis and educational tool, not financial advice. Relative strength is backward-looking and can reverse quickly. Always do your own research and manage risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tarw_t based on the original indicator by @valpatrad

//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  SPDR SECTOR RELATIVE STRENGTH vs BENCHMARK
// ═══════════════════════════════════════════════════════════════════════════
//
//  WHAT IT DOES
//  A dashboard ranking the 11 S&P 500 SPDR sector ETFs (XLK, XLF, XLE, ...)
//  by how much each is OUTPERFORMING or UNDERPERFORMING a benchmark (SPY by
//  default) over several lookback windows. Designed as a top-down filter:
//  find the strongest/accelerating sectors first, then hunt individual stocks
//  inside them.
//
//  HOW TO READ EACH COLUMN
//  • 1D / 1W / 1M / 3M / 6M / 1Y — Relative Strength (RS) over that trailing
//      window, calculated as (sector % return − benchmark % return).
//      +3.00% means the sector beat SPY by 3 percentage points over the window.
//      Green = outperforming SPY, red = lagging. Each column toggles on/off.
//  • Score — the average of the displayed RS across every ENABLED timeframe.
//      One ranking number instead of eyeballing six columns. A sector green
//      across all horizons is a more reliable leader than one strong on a
//      single window.
//  • Mom (Momentum) — whether relative strength is IMPROVING or DETERIORATING,
//      comparing a recent window against an older one. Positive = strengthening.
//      Three modes (see Momentum Mode):
//        - Level diff: raw (recent RS − older RS). Simple but biased by window
//          size, since a longer window accumulates a bigger number.
//        - Pace (per-bar): rescales the older RS to the recent window's length
//          first, removing that bias.
//        - Pace (non-overlap): compares the recent segment against the separate
//          earlier segment before it — a true acceleration measure, and the
//          best early-warning of a sector quietly turning up or rolling over.
//
//  KEY SETTINGS
//  • Benchmark — what each sector is measured against (swap SPY for QQQ, etc).
//  • Measurement Timeframe — the bar size the lookbacks are counted in. Daily
//      is recommended so 5≈1W, 21≈1M, 63≈3M, 126≈6M, 252≈1Y.
//  • RS Columns Show — Cumulative (total RS per window) or Per-Month Rate
//      (RS ÷ months in the window) for an apples-to-apples monthly pace.
//  • Gradient Scale — Auto (each column scaled to its own strongest sector) or
//      Manual (a fixed % maps to the deepest colour, same scale everywhere).
//
//  TYPICAL WORKFLOW
//  Sort by Score (or Momentum) descending. Favour sectors that are both
//  strong (Score) and strengthening (positive Momentum) — the latter often
//  flags rotation before it's obvious. Drill into the top sectors for stock
//  candidates; ignore the laggards.
//
//  NOTES
//  • Higher-timeframe RS values update until the higher-timeframe bar closes;
//    that's expected, not a bug.
//  • In Per-Month Rate mode the 1D/1W columns get extrapolated and look large
//    and noisy — untick them and lean on 1M–1Y.
//  • This is an analysis tool, not financial advice. Relative strength is
//    backward-looking and can reverse quickly.
// ═══════════════════════════════════════════════════════════════════════════

indicator('TT - SPDR Sector RS vs Benchmark', 'TT - Sector RS', overlay=true)

////////////////////////////
//          Menu          //
////////////////////////////

// ── About ─────────────────────────────────────────────────────────
gA = 'ℹ️ About This Script'
about = input.bool(false, 'Hover the tooltip (i) to learn more →', group=gA, tooltip='SPDR SECTOR RELATIVE STRENGTH\n\nRanks the 11 S&P 500 sector ETFs by how much each is beating or lagging a benchmark (SPY by default) over multiple timeframes. Use it top-down: find the strongest, accelerating sectors, then pick stocks inside them.\n\nCOLUMNS\n• 1D–1Y: Relative Strength = sector return − benchmark return over that window. Green beats SPY, red lags.\n• Score: average RS across all enabled timeframes — one ranking number.\n• Mom: is relative strength improving (green) or fading (red)? Three calculation modes, from a simple difference to a true pace-corrected acceleration measure.\n\nTIP: sort by Score or Momentum descending. Sectors that are both strong AND strengthening are the best hunting grounds. This is an analysis tool, not financial advice. (This toggle does nothing — it exists only to hold this description.)')

// ── General ──────────────────────────────────────────────────────
gG = 'General'
benchmark = input.symbol('SPY', 'Benchmark', group=gG, tooltip='Each sector is compared against this symbol.')
res = input.timeframe('D', 'Measurement Timeframe', group=gG, tooltip='Lookbacks below are counted in bars of THIS timeframe. Daily is recommended so 5≈1W, 21≈1M, 63≈3M, 126≈6M, 252≈1Y.')

// ── Lookback periods (in bars of the measurement timeframe) ───────
gP = 'Lookback Periods'
show_1d = input.bool(true,  '1D', group=gP, inline='p1')
lb_1d   = input.int(1,   'bars', 1, group=gP, inline='p1')
show_1w = input.bool(true,  '1W', group=gP, inline='p2')
lb_1w   = input.int(5,   'bars', 1, group=gP, inline='p2')
show_1m = input.bool(true,  '1M', group=gP, inline='p3')
lb_1m   = input.int(21,  'bars', 1, group=gP, inline='p3')
show_3m = input.bool(true,  '3M', group=gP, inline='p4')
lb_3m   = input.int(63,  'bars', 1, group=gP, inline='p4')
show_6m = input.bool(true,  '6M', group=gP, inline='p5')
lb_6m   = input.int(126, 'bars', 1, group=gP, inline='p5')
show_1y = input.bool(true,  '1Y', group=gP, inline='p6')
lb_1y   = input.int(252, 'bars', 1, group=gP, inline='p6')

// ── Table ────────────────────────────────────────────────────────
gT = 'Table'
show_ticker = input.bool(true, 'Ticker', inline='Show', group=gT)
show_sector = input.bool(true, 'Sector', inline='Show', group=gT)
show_score  = input.bool(true, 'Score',  inline='Show', group=gT)
rs_disp_mode = input.string('Cumulative', 'RS Columns Show', ['Cumulative', 'Per-Month Rate'], group=gT, tooltip='Cumulative = total RS over each trailing window. Per-Month Rate = that RS divided by the number of months in the window (the "month" unit is your 1M lookback), so every column is an average monthly pace anchored to now. Note: sub-month windows (1D, 1W) get extrapolated and look large/noisy in this mode.')
show_mom    = input.bool(true, 'Momentum Column', group=gT)
mom_recent  = input.string('1M', 'Momentum:  recent', ['1D','1W','1M','3M','6M','1Y'], inline='mom', group=gT)
mom_older   = input.string('6M', 'vs older', ['1D','1W','1M','3M','6M','1Y'], inline='mom', group=gT, tooltip='Momentum compares relative strength over the recent period against the older period. Positive = relative strength improving.')
mom_mode    = input.string('Pace (non-overlap)', 'Momentum Mode', ['Level diff', 'Pace (per-bar)', 'Pace (non-overlap)'], group=gT, tooltip='Level diff = recent RS − older RS (biased by window size). Pace (per-bar) = older RS rescaled to the recent window length before subtracting (removes the bias). Pace (non-overlap) = compares the recent segment against the separate earlier segment before it — a true acceleration measure (needs older period longer than recent). Momentum is independent of the RS Columns Show setting.')
sort_by  = input.string('Score', 'Sort By', ['Score', 'Momentum', '1D', '1W', '1M', '3M', '6M', '1Y'], inline='sort', group=gT)
sort_dir = input.string('Descending', '', ['Ascending', 'Descending'], inline='sort', group=gT)
in_font = input.string('Default', 'Text Font', ['Default', 'Monospace'], group=gT)
font = in_font == 'Monospace' ? font.family_monospace : font.family_default
b_width = input.int(1, 'Border Width', 0, group=gT)
in_tab_size = input.string('Normal', 'Size', ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group=gT)
tab_size = switch in_tab_size
    'Auto'   => size.auto
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Normal' => size.normal
    'Large'  => size.large
    'Huge'   => size.huge
in_tab_pos = input.string('Top Right', 'Position', ['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=gT)
tab_pos = switch in_tab_pos
    'Top Left'      => position.top_left
    'Top Center'    => position.top_center
    'Top Right'     => position.top_right
    'Middle Left'   => position.middle_left
    'Middle Center' => position.middle_center
    'Middle Right'  => position.middle_right
    'Bottom Left'   => position.bottom_left
    'Bottom Center' => position.bottom_center
    'Bottom Right'  => position.bottom_right

// ── Colors / Gradient ────────────────────────────────────────────
gC = 'Colors'
pos_c   = input.color(#4CAF50, 'Outperforms (deepest)', group=gC)
neg_c   = input.color(#FF5252, 'Underperforms (deepest)', group=gC)
neut_transp = input.int(88, 'Neutral Transparency', 0, 100, group=gC, tooltip='How faded a cell near 0% looks. Higher = more see-through (closer to your chart background).')
data_txt = input.color(#FFFFFF, 'Data Text', group=gC)
grad_mode = input.string('Auto', 'Gradient Scale', ['Auto', 'Manual'], group=gC, tooltip='Auto = each column scales to its own strongest sector. Manual = a fixed % maps to the deepest color (same scale across all columns).')
grad_max = input.float(5.0, 'Manual Max % (deepest color)', 0.1, group=gC)
hdr_bg  = input.color(#2A2E39, 'Header BG', group=gC)
hdr_txt = input.color(#FFFFFF, 'Header Text', group=gC)
name_txt = input.color(#000000, 'Name Text', group=gC)

/////////////////////////////
//        Variables        //
/////////////////////////////

symbols = array.from('XLC', 'XLY', 'XLP', 'XLE', 'XLF', 'XLV', 'XLI', 'XLB', 'XLRE', 'XLK', 'XLU')
sectors = array.from('Communication Services', 'Consumer Discretionary', 'Consumer Staples', 'Energy', 'Financials', 'Health Care', 'Industrials', 'Materials', 'Real Estate', 'Technology', 'Utilities')
colors  = array.from(#A966A7, #C7C952, #00ACBB, #FFC838, #A8CE4E, #00AFEA, #8CC6E9, #8B98C4, #A7001F, #93248B, #FF972A)

period_labels = array.from('1D', '1W', '1M', '3M', '6M', '1Y')
period_show   = array.from(show_1d, show_1w, show_1m, show_3m, show_6m, show_1y)
period_bars   = array.from(lb_1d, lb_1w, lb_1m, lb_3m, lb_6m, lb_1y)

nSym = array.size(symbols)
nPer = 6

// Convert a current close + array of previous closes into % returns per period.
f_returns(c, prevs) =>
    out = array.new_float(nPer, na)
    for p = 0 to nPer - 1
        pv = array.get(prevs, p)
        array.set(out, p, na(pv) or pv == 0 ? na : (c - pv) / pv * 100)
    out

// Return (%) of the earlier, NON-overlapping segment, derived from two
// cumulative window returns (both in %). e.g. the bit of the 6M window
// that sits before the 1M window.
f_priorret(rOld, rRecent) =>
    na(rOld) or na(rRecent) ? na : ((1 + rOld / 100) / (1 + rRecent / 100) - 1) * 100

// ── Benchmark returns ────────────────────────────────────────────
[bc, b1, b5, b21, b63, b126, b252] = request.security(benchmark, res, [close, close[lb_1d], close[lb_1w], close[lb_1m], close[lb_3m], close[lb_6m], close[lb_1y]])
bench_ret = f_returns(bc, array.from(b1, b5, b21, b63, b126, b252))

// ── Sector relative strength (sector return − benchmark return) ──
var rs     = matrix.new<float>(nSym, nPer, na)
var sret_m = matrix.new<float>(nSym, nPer, na)
for i = 0 to nSym - 1
    sym = array.get(symbols, i)
    [c, a1, a5, a21, a63, a126, a252] = request.security(sym, res, [close, close[lb_1d], close[lb_1w], close[lb_1m], close[lb_3m], close[lb_6m], close[lb_1y]])
    srets = f_returns(c, array.from(a1, a5, a21, a63, a126, a252))
    for p = 0 to nPer - 1
        sr = array.get(srets, p)
        br = array.get(bench_ret, p)
        matrix.set(sret_m, i, p, sr)
        matrix.set(rs, i, p, na(sr) or na(br) ? na : sr - br)

// ── Display matrix: cumulative RS, or per-month rate (RS ÷ months) ─
// "Months" = window bars / 1M lookback, so the unit self-calibrates.
month_unit = lb_1m
rs_disp = matrix.new<float>(nSym, nPer, na)
for i = 0 to nSym - 1
    for p = 0 to nPer - 1
        v = matrix.get(rs, i, p)
        if not na(v)
            wb = array.get(period_bars, p)
            pm = rs_disp_mode == 'Per-Month Rate' and wb > 0 ? v * month_unit / wb : v
            matrix.set(rs_disp, i, p, pm)

// ── RS Score: average of the DISPLAYED value across ENABLED frames ─
scores = array.new_float(nSym, na)
for i = 0 to nSym - 1
    sum = 0.0
    cnt = 0
    for p = 0 to nPer - 1
        if array.get(period_show, p)
            v = matrix.get(rs_disp, i, p)
            if not na(v)
                sum += v
                cnt += 1
    array.set(scores, i, cnt == 0 ? na : sum / cnt)

// ── Momentum: improvement in RS, per the selected mode (uses raw RS) ─
ri = array.indexof(period_labels, mom_recent)
oi = array.indexof(period_labels, mom_older)
br_recent = array.get(period_bars, ri)
br_older  = array.get(period_bars, oi)
momentum = array.new_float(nSym, na)
for i = 0 to nSym - 1
    rsR = matrix.get(rs, i, ri)
    rsO = matrix.get(rs, i, oi)
    float m = na
    if mom_mode == 'Level diff'
        m := na(rsR) or na(rsO) ? na : rsR - rsO
    else if mom_mode == 'Pace (per-bar)'
        m := na(rsR) or na(rsO) or br_older == 0 ? na : rsR - rsO * (br_recent / br_older)
    else // Pace (non-overlap)
        if br_older <= br_recent
            m := na
        else
            sR = matrix.get(sret_m, i, ri)
            sO = matrix.get(sret_m, i, oi)
            priorS = f_priorret(sO, sR)
            priorB = f_priorret(array.get(bench_ret, oi), array.get(bench_ret, ri))
            priorRS = na(priorS) or na(priorB) ? na : priorS - priorB
            barsPrior = br_older - br_recent
            m := na(rsR) or na(priorRS) or barsPrior == 0 ? na : rsR - priorRS * (br_recent / barsPrior)
    array.set(momentum, i, m)

// ── Sort order ───────────────────────────────────────────────────
sort_p = array.indexof(period_labels, sort_by) // -1 for 'Score' / 'Momentum'
sort_keys = array.new_float(nSym)
for i = 0 to nSym - 1
    key = sort_by == 'Score' ? array.get(scores, i) : sort_by == 'Momentum' ? array.get(momentum, i) : matrix.get(rs_disp, i, sort_p)
    array.set(sort_keys, i, na(key) ? -1e15 : key)
sorted_index = array.sort_indices(sort_keys, sort_dir == 'Ascending' ? order.ascending : order.descending)

// Gradient endpoint for a period column (Auto mode) — uses displayed values.
f_colmax(p) =>
    m = 0.0
    for i = 0 to nSym - 1
        v = matrix.get(rs_disp, i, p)
        if not na(v)
            m := math.max(m, math.abs(v))
    m <= 0 ? 1.0 : m

// Gradient endpoint for any float array (Auto mode) — used by Score & Momentum.
f_arrmax(arr) =>
    m = 0.0
    for i = 0 to array.size(arr) - 1
        v = array.get(arr, i)
        if not na(v)
            m := math.max(m, math.abs(v))
    m <= 0 ? 1.0 : m

// Heatmap background: fade from a faint (transparent) version of each side's
// color near 0% to the fully saturated color at the gradient extreme.
f_heat(v, scale) =>
    s = scale <= 0 ? 1.0 : scale
    vc = math.max(math.min(v, s), -s) // clamp so colors don't overshoot
    vc >= 0 ? color.from_gradient(vc, 0, s, color.new(pos_c, neut_transp), color.new(pos_c, 0)) : color.from_gradient(vc, -s, 0, color.new(neg_c, 0), color.new(neg_c, neut_transp))

f_fmt(v) =>
    na(v) ? '—' : (v > 0 ? '+' : '') + str.tostring(v, '0.00') + '%'

/////////////////////////////
//          Plot           //
/////////////////////////////

var tbl = table.new(tab_pos, 10, 12, border_width=b_width)

if barstate.islast
    table.clear(tbl, 0, 0, 9, 11)

    // Header row
    int hc = 0
    if show_ticker
        table.cell(tbl, hc, 0, 'Ticker', text_color=hdr_txt, bgcolor=hdr_bg, text_size=tab_size, text_font_family=font)
        hc += 1
    if show_sector
        table.cell(tbl, hc, 0, 'Sector', text_color=hdr_txt, bgcolor=hdr_bg, text_size=tab_size, text_font_family=font)
        hc += 1
    if show_score
        table.cell(tbl, hc, 0, 'Score', text_color=hdr_txt, bgcolor=hdr_bg, text_size=tab_size, text_font_family=font)
        hc += 1
    if show_mom
        table.cell(tbl, hc, 0, 'Mom', text_color=hdr_txt, bgcolor=hdr_bg, text_size=tab_size, text_font_family=font)
        hc += 1
    for p = 0 to nPer - 1
        if array.get(period_show, p)
            table.cell(tbl, hc, 0, array.get(period_labels, p), text_color=hdr_txt, bgcolor=hdr_bg, text_size=tab_size, text_font_family=font)
            hc += 1

    // Data rows
    scoreScale = grad_mode == 'Manual' ? grad_max : f_arrmax(scores)
    momScale   = grad_mode == 'Manual' ? grad_max : f_arrmax(momentum)
    for r = 0 to nSym - 1
        si = array.get(sorted_index, r)
        scol = array.get(colors, si)
        int c0 = 0
        if show_ticker
            table.cell(tbl, c0, r + 1, array.get(symbols, si), text_color=name_txt, bgcolor=scol, text_size=tab_size, text_font_family=font)
            c0 += 1
        if show_sector
            table.cell(tbl, c0, r + 1, array.get(sectors, si), text_color=name_txt, bgcolor=scol, text_size=tab_size, text_font_family=font)
            c0 += 1
        if show_score
            sv = array.get(scores, si)
            sbg = na(sv) ? color.new(color.gray, 85) : f_heat(sv, scoreScale)
            table.cell(tbl, c0, r + 1, f_fmt(sv), text_color=na(sv) ? color.gray : data_txt, bgcolor=sbg, text_size=tab_size, text_font_family=font)
            c0 += 1
        if show_mom
            mv = array.get(momentum, si)
            mbg = na(mv) ? color.new(color.gray, 85) : f_heat(mv, momScale)
            table.cell(tbl, c0, r + 1, f_fmt(mv), text_color=na(mv) ? color.gray : data_txt, bgcolor=mbg, text_size=tab_size, text_font_family=font)
            c0 += 1
        for p = 0 to nPer - 1
            if array.get(period_show, p)
                v = matrix.get(rs_disp, si, p)
                scale = grad_mode == 'Manual' ? grad_max : f_colmax(p)
                bg = na(v) ? color.new(color.gray, 85) : f_heat(v, scale)
                table.cell(tbl, c0, r + 1, f_fmt(v), text_color=na(v) ? color.gray : data_txt, bgcolor=bg, text_size=tab_size, text_font_family=font)
                c0 += 1
````
