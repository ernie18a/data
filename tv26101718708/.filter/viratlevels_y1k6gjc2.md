# Virat-Levels

- url: https://www.tradingview.com/script/Y1k6gjc2-Virat-Levels/
- type: indicator
- pine_id: PUB;6fa757631582408ba2a435720e572389
- version: 1.0

## Description

Collect all active levels (value + label + color) into arrays — skipping any that are na or toggled off.

Sort all three arrays together by price using bubble sort, so levels are in order from bottom to top.

walk up the sorted list and if any label's Y is within min_gap of the one below it, push it up by the difference. The min_gap is 1.5% of the 200-bar price range, so it auto-scales — works on a $2 stock and a $500 stock equally.

lines are always drawn at the true price (so the line sits exactly on the level), but labels are drawn at the nudged Y (so they don't stack on top of each other). The line still points accurately to the real price, the label just floats slightly above/below if needed.

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════
//  KEY LEVELS DASHBOARD  — Ripster Style
//  • PDH/PDL · PMH/PML · Daily / 4H / 1H S/R
//  • Labels sorted by price, nudged apart so they never overlap
//  • Price badges on right axis for every level
//  ⚠️  Enable "Extended Hours" on your chart for Pre-Market levels.
// ════════════════════════════════════════════════════════════════════════════
//@version=5
indicator("Virat-Levels",
          overlay          = true,
          max_lines_count  = 500,
          max_labels_count = 500)

// ────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ────────────────────────────────────────────────────────────────────────────
G1 = "── Level Visibility ──"
show_pd  = input.bool(true, "Prev Day High / Low (PDH · PDL)",   group=G1)
show_pm  = input.bool(true, "Pre-Market High / Low (PMH · PML)", group=G1, tooltip="⚠️ Requires Extended Hours enabled on chart")
show_1d  = input.bool(true, "Daily S/R Pivots (DR · DS)",        group=G1)
show_4h  = input.bool(true, "4H S/R Pivots (4HR · 4HS)",         group=G1)
show_1h  = input.bool(true, "1H S/R Pivots (1HR · 1HS)",         group=G1)

G2 = "── Line Style ──"
lw     = input.int(2,         "Line Width",  minval=1, maxval=4,                  group=G2)
ls_raw = input.string("Solid","Line Style",  options=["Solid","Dashed","Dotted"], group=G2)

G3 = "── S/R Sensitivity ──"
pivot_len = input.int(5, "Pivot Lookback (bars each side)", minval=2, maxval=20, group=G3,
             tooltip="Higher = fewer but more significant pivots.")

// ────────────────────────────────────────────────────────────────────────────
//  COLORS
// ────────────────────────────────────────────────────────────────────────────
C_PDH = color.new(#FF8C00, 0)
C_PDL = color.new(#7B1FA2, 0)
C_PMH = color.new(#1B5E20, 0)
C_PML = color.new(#B71C1C, 0)
C_DR  = color.new(#E91E8C, 0)
C_DS  = color.new(#29B6F6, 0)
C_4HR = color.new(#F06292, 0)
C_4HS = color.new(#00E676, 0)
C_1HR = color.new(#FF80AB, 0)
C_1HS = color.new(#69F0AE, 0)

ls = ls_raw == "Dashed" ? line.style_dashed :
     ls_raw == "Dotted" ? line.style_dotted : line.style_solid

// ────────────────────────────────────────────────────────────────────────────
//  PREVIOUS DAY HIGH / LOW
// ────────────────────────────────────────────────────────────────────────────
[pdh, pdl] = request.security(syminfo.tickerid, "D",
              [high[1], low[1]], lookahead=barmerge.lookahead_on)

// ────────────────────────────────────────────────────────────────────────────
//  PRE-MARKET HIGH / LOW
// ────────────────────────────────────────────────────────────────────────────
var float pmh    = na
var float pml    = na
var int   pm_key = na
day_key = year * 10000 + month * 100 + dayofmonth
if session.ispremarket
    if na(pm_key) or pm_key != day_key
        pmh := high,  pml := low,  pm_key := day_key
    else
        pmh := math.max(pmh, high),  pml := math.min(pml, low)

// ────────────────────────────────────────────────────────────────────────────
//  MTF S/R PIVOTS
// ────────────────────────────────────────────────────────────────────────────
res_1h = request.security(syminfo.tickerid, "60",
          ta.valuewhen(not na(ta.pivothigh(high,pivot_len,pivot_len)),
                       ta.pivothigh(high,pivot_len,pivot_len),0), lookahead=barmerge.lookahead_off)
sup_1h = request.security(syminfo.tickerid, "60",
          ta.valuewhen(not na(ta.pivotlow(low,pivot_len,pivot_len)),
                       ta.pivotlow(low,pivot_len,pivot_len),0),  lookahead=barmerge.lookahead_off)
res_4h = request.security(syminfo.tickerid, "240",
          ta.valuewhen(not na(ta.pivothigh(high,pivot_len,pivot_len)),
                       ta.pivothigh(high,pivot_len,pivot_len),0), lookahead=barmerge.lookahead_off)
sup_4h = request.security(syminfo.tickerid, "240",
          ta.valuewhen(not na(ta.pivotlow(low,pivot_len,pivot_len)),
                       ta.pivotlow(low,pivot_len,pivot_len),0),  lookahead=barmerge.lookahead_off)
res_1d = request.security(syminfo.tickerid, "D",
          ta.valuewhen(not na(ta.pivothigh(high,pivot_len,pivot_len)),
                       ta.pivothigh(high,pivot_len,pivot_len),0), lookahead=barmerge.lookahead_off)
sup_1d = request.security(syminfo.tickerid, "D",
          ta.valuewhen(not na(ta.pivotlow(low,pivot_len,pivot_len)),
                       ta.pivotlow(low,pivot_len,pivot_len),0),  lookahead=barmerge.lookahead_off)

// ────────────────────────────────────────────────────────────────────────────
//  MIN GAP — scales with the ticker's recent price range
// ────────────────────────────────────────────────────────────────────────────
price_range = ta.highest(high, 200) - ta.lowest(low, 200)
min_gap     = price_range * 0.015

// ────────────────────────────────────────────────────────────────────────────
//  GLOBAL ARRAYS — declared at top level (Pine Script requirement)
// ────────────────────────────────────────────────────────────────────────────
var float[] raw_vals    = array.new_float()
var string[] raw_lbls   = array.new_string()
var color[]  raw_cols   = array.new_color()
var line[]   drn_lines  = array.new_line()
var label[]  drn_labels = array.new_label()

// ────────────────────────────────────────────────────────────────────────────
//  RENDER ON LAST BAR
// ────────────────────────────────────────────────────────────────────────────
if barstate.islast

    // 1. Wipe previous drawings
    for ln in drn_lines
        line.delete(ln)
    for lb in drn_labels
        label.delete(lb)
    array.clear(drn_lines)
    array.clear(drn_labels)
    array.clear(raw_vals)
    array.clear(raw_lbls)
    array.clear(raw_cols)

    // 2. Push active levels — inline, no nested function
    if show_pd and not na(pdh)
        array.push(raw_vals, pdh),  array.push(raw_lbls, "PDH"),  array.push(raw_cols, C_PDH)
    if show_pd and not na(pdl)
        array.push(raw_vals, pdl),  array.push(raw_lbls, "PDL"),  array.push(raw_cols, C_PDL)
    if show_pm and not na(pmh)
        array.push(raw_vals, pmh),  array.push(raw_lbls, "PMH"),  array.push(raw_cols, C_PMH)
    if show_pm and not na(pml)
        array.push(raw_vals, pml),  array.push(raw_lbls, "PML"),  array.push(raw_cols, C_PML)
    if show_1d and not na(res_1d)
        array.push(raw_vals, res_1d), array.push(raw_lbls, "DR"),  array.push(raw_cols, C_DR)
    if show_1d and not na(sup_1d)
        array.push(raw_vals, sup_1d), array.push(raw_lbls, "DS"),  array.push(raw_cols, C_DS)
    if show_4h and not na(res_4h)
        array.push(raw_vals, res_4h), array.push(raw_lbls, "4HR"), array.push(raw_cols, C_4HR)
    if show_4h and not na(sup_4h)
        array.push(raw_vals, sup_4h), array.push(raw_lbls, "4HS"), array.push(raw_cols, C_4HS)
    if show_1h and not na(res_1h)
        array.push(raw_vals, res_1h), array.push(raw_lbls, "1HR"), array.push(raw_cols, C_1HR)
    if show_1h and not na(sup_1h)
        array.push(raw_vals, sup_1h), array.push(raw_lbls, "1HS"), array.push(raw_cols, C_1HS)

    n = array.size(raw_vals)

    // 3. Bubble-sort all three arrays by price ascending (manual swap — no array.swap in Pine)
    for i = 0 to n - 2
        for j = 0 to n - 2 - i
            if array.get(raw_vals, j) > array.get(raw_vals, j + 1)
                tmp_v = array.get(raw_vals, j)
                tmp_l = array.get(raw_lbls, j)
                tmp_c = array.get(raw_cols, j)
                array.set(raw_vals, j, array.get(raw_vals, j + 1))
                array.set(raw_lbls, j, array.get(raw_lbls, j + 1))
                array.set(raw_cols, j, array.get(raw_cols, j + 1))
                array.set(raw_vals, j + 1, tmp_v)
                array.set(raw_lbls, j + 1, tmp_l)
                array.set(raw_cols, j + 1, tmp_c)

    // 4. Nudge label Y positions apart where they would overlap
    label_y = array.copy(raw_vals)
    for i = 1 to n - 1
        prev_y = array.get(label_y, i - 1)
        curr_y = array.get(label_y, i)
        if curr_y - prev_y < min_gap
            array.set(label_y, i, prev_y + min_gap)

    // 5. Draw — line at TRUE price, label at NUDGED price
    right_x = bar_index + 15
    for i = 0 to n - 1
        v   = array.get(raw_vals,  i)
        ly  = array.get(label_y,   i)
        lbl = array.get(raw_lbls,  i)
        col = array.get(raw_cols,  i)
        array.push(drn_lines, line.new(
              x1=bar_index - 500, y1=v, x2=right_x, y2=v,
              color=col, width=lw, style=ls, extend=extend.none))
        array.push(drn_labels, label.new(
              x=right_x, y=ly, text=lbl,
              color=color.new(col, 60), textcolor=color.white,
              style=label.style_label_left, size=size.normal))

// ────────────────────────────────────────────────────────────────────────────
//  RIGHT-AXIS PRICE BADGES
// ────────────────────────────────────────────────────────────────────────────
plot(show_pd ? pdh    : na, "PDH", color=C_PDH, linewidth=1, display=display.price_scale)
plot(show_pd ? pdl    : na, "PDL", color=C_PDL, linewidth=1, display=display.price_scale)
plot(show_pm ? pmh    : na, "PMH", color=C_PMH, linewidth=1, display=display.price_scale)
plot(show_pm ? pml    : na, "PML", color=C_PML, linewidth=1, display=display.price_scale)
plot(show_1d ? res_1d : na, "DR",  color=C_DR,  linewidth=1, display=display.price_scale)
plot(show_1d ? sup_1d : na, "DS",  color=C_DS,  linewidth=1, display=display.price_scale)
plot(show_4h ? res_4h : na, "4HR", color=C_4HR, linewidth=1, display=display.price_scale)
plot(show_4h ? sup_4h : na, "4HS", color=C_4HS, linewidth=1, display=display.price_scale)
plot(show_1h ? res_1h : na, "1HR", color=C_1HR, linewidth=1, display=display.price_scale)
plot(show_1h ? sup_1h : na, "1HS", color=C_1HS, linewidth=1, display=display.price_scale)
````
