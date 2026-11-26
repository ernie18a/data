# Scalp VWAP

- url: https://www.tradingview.com/script/OE9tLJMl-Scalp-VWAP/
- type: indicator
- pine_id: PUB;34aa21b4152543ecbb7f1dd7704efcf2
- version: 1.0

## Description

Scalp VWAP is an intraday anchored VWAP indicator designed for precision scalping and short-term trading. It plots volume-weighted average prices anchored to the current day and week, each with two configurable standard deviation bands to define value areas and key price levels.
Features:
Daily VWAP — Anchored to each new session with Band 1 and Band 2 standard deviation channels. Includes a developing value area high/low overlay and previous day VWAP + previous value area levels for reference.
Weekly VWAP — Same structure as the daily, anchored to the weekly open. Tracks the developing weekly value area and carries over the prior week's VWAP and value area levels.
Rolling Daily VWAP — An optional overlay that displays the current day's VWAP in a separate color, useful for quick visual separation from the weekly anchor.
Initial Balance — Marks the high and low of a configurable session window (default 00:00–01:00) to define the opening range. Labels appear to the right of the chart for easy identification.
Right-side Labels — All active levels are labeled at the right edge of the chart with configurable offsets, keeping your chart clean without requiring you to hover over lines to identify them.
Settings include: band multipliers, individual toggles for every component, fully customizable colors for VWAP lines, bands, and markers, and offset controls for all labels.

## Source Code

````pine
// @version=5
// Recreated: @TheParagonGrp Scalp VWAP
// Uses proven computeVWAP/computeBANDS pattern from SpaceDyme reference

indicator(title="Scalp VWAP", shorttitle="Scalp VWAP", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

grp_vwap = "VWAP SETTINGS"
b1_mult  = input.float(1.0, "Bands Multiplier 1", minval=0.1, group=grp_vwap)
b2_mult  = input.float(2.0, "Bands Multiplier 2", minval=0.1, group=grp_vwap)

grp_ib = "INITIAL BALANCE"
ib_start_hour = input.int(0, "IB Start Hour",   minval=0, maxval=23, group=grp_ib)
ib_start_min  = input.int(0, "IB Start Minute", minval=0, maxval=59, group=grp_ib)
ib_end_hour   = input.int(1, "IB End Hour",     minval=0, maxval=23, group=grp_ib)
ib_end_min    = input.int(0, "IB End Minute",   minval=0, maxval=59, group=grp_ib)
en_ib_mrk     = input.bool(true, "Enable Initial Balance Mrk.", group=grp_ib)
ib_mrk_offset = input.int(25, "IB Mrk. offset", group=grp_ib)
col_ib_mrk    = input.color(color.new(color.gray, 50), "IB Mrk. Color", group=grp_ib)

grp_rv = "ROLLING DAILY VWAP"
en_rv         = input.bool(false, "Enable Rolling Daily VWAP",    group=grp_rv)
en_rv_mrk     = input.bool(true,  "Enable Rolling VWAP Mrk.",     group=grp_rv)
col_rv        = input.color(color.new(color.teal, 0),  "Rolling VWAP Color",      group=grp_rv)
col_rv_band   = input.color(color.new(color.teal, 80), "Rolling BAND Color",      group=grp_rv)
col_rv_edge   = input.color(color.new(color.teal, 60), "Rolling BAND EDGE Color", group=grp_rv)
en_rv_vwap    = input.bool(true, "Enable VWAP",      group=grp_rv)
en_rv_b1      = input.bool(true, "Enable 1st Bands", group=grp_rv)
en_rv_b2      = input.bool(true, "Enable 2nd Bands", group=grp_rv)
rv_mrk_offset = input.int(15, "Rolling Mrk. offset", group=grp_rv)
col_rv_mrk    = input.color(color.new(color.teal, 0), "Rolling Mrk. Color", group=grp_rv)

grp_d = "DAILY"
en_daily        = input.bool(true, "Enable Daily",      group=grp_d)
en_daily_mrk    = input.bool(true, "Enable Daily Mrk.", group=grp_d)
col_d           = input.color(color.new(color.blue, 0),  "Daily VWAP Color",      group=grp_d)
col_d_band      = input.color(color.new(color.gray, 80), "Daily BAND Color",      group=grp_d)
col_d_band_edge = input.color(color.new(color.gray, 60), "Daily BAND EDGE Color", group=grp_d)
en_d_vwap       = input.bool(true, "Enable VWAP",      group=grp_d)
en_d_b1         = input.bool(true, "Enable 1st Bands", group=grp_d)
en_d_b2         = input.bool(true, "Enable 2nd Bands", group=grp_d)
d_mrk_offset    = input.int(15, "Daily Mrk. offset", group=grp_d)
col_d_mrk       = input.color(color.new(color.blue, 40), "Daily Mrk. Color",        group=grp_d)
col_d_prev_mrk  = input.color(color.new(color.blue, 60), "Previous Day Mrk. Color", group=grp_d)
en_d_dev_mrk    = input.bool(true, "Enable Developing VA Mrk.", group=grp_d)
en_d_prev_mrk   = input.bool(true, "Enable Previous VA Mrk.",  group=grp_d)
en_d_prev_vwap  = input.bool(true, "Enable Previous VWAP",     group=grp_d)

grp_w = "WEEKLY"
en_weekly       = input.bool(true, "Enable Weekly",      group=grp_w)
en_weekly_mrk   = input.bool(true, "Enable Weekly Mrk.", group=grp_w)
col_w           = input.color(color.new(color.blue, 60), "Weekly VWAP Color",      group=grp_w)
col_w_band      = input.color(color.new(color.gray, 80), "Weekly BAND Color",      group=grp_w)
col_w_band_edge = input.color(color.new(color.gray, 60), "Weekly BAND EDGE Color", group=grp_w)
en_w_vwap       = input.bool(true, "Enable VWAP",      group=grp_w)
en_w_b1         = input.bool(true, "Enable 1st Bands", group=grp_w)
en_w_b2         = input.bool(true, "Enable 2nd Bands", group=grp_w)
w_mrk_offset    = input.int(15, "Weekly Mrk. offset", group=grp_w)
col_w_mrk       = input.color(color.new(color.blue, 40), "Weekly Mrk. Color",        group=grp_w)
col_w_prev_mrk  = input.color(color.new(color.blue, 60), "Previous Week Mrk. Color", group=grp_w)
en_w_dev_mrk    = input.bool(true, "Enable Developing VA Mrk.", group=grp_w)
en_w_prev_mrk   = input.bool(true, "Enable Previous VA Mrk.",  group=grp_w)
en_w_prev_vwap  = input.bool(true, "Enable Previous VWAP.",    group=grp_w)

// ─────────────────────────────────────────────
// CORE FUNCTIONS — exact pattern from reference
// ─────────────────────────────────────────────

is_newbar(res) =>
    t = time(res)
    not na(t) and (na(t[1]) or t > t[1])

computeVWAP(src, isNewPeriod) =>
    var float sumSrcVol = na
    var float sumVol    = na
    sumSrcVol := isNewPeriod ? src * volume : src * volume + sumSrcVol[1]
    sumVol    := isNewPeriod ? volume       : volume + sumVol[1]
    _vwap = sumSrcVol / sumVol
    [_vwap, sumVol]

computeBANDS(src, isNewPeriod, stDevMultiplier, _vwap, sumVol) =>
    var float sumSrcSrcVol = na
    sumSrcSrcVol := isNewPeriod ? volume * math.pow(src, 2) : volume * math.pow(src, 2) + sumSrcSrcVol[1]
    variance = sumSrcSrcVol / sumVol - math.pow(_vwap, 2)
    variance := variance < 0 ? 0 : variance
    stDev     = math.sqrt(variance)
    [_vwap - stDev * stDevMultiplier, _vwap + stDev * stDevMultiplier]

// ─────────────────────────────────────────────
// PERIOD FLAGS
// ─────────────────────────────────────────────

new_day  = is_newbar("D")
new_week = is_newbar("W")

// ─────────────────────────────────────────────
// DAILY VWAP
// ─────────────────────────────────────────────

var float d_vah      = na
var float d_val      = na
var float d_prev_vwap = na
var float d_prev_vah  = na
var float d_prev_val  = na

[d_vwap, d_sumVol] = computeVWAP(hlc3, new_day)

if new_day
    d_prev_vwap := d_vwap[1]
    d_prev_vah  := d_vah[1]
    d_prev_val  := d_val[1]
    d_vah       := high
    d_val       := low
else
    d_vah := math.max(nz(d_vah, high), high)
    d_val := math.min(nz(d_val, low),  low)

[d_l1, d_u1] = computeBANDS(hlc3, new_day, b1_mult, d_vwap, d_sumVol)
[d_l2, d_u2] = computeBANDS(hlc3, new_day, b2_mult, d_vwap, d_sumVol)

plot(en_daily and en_d_vwap ? d_vwap : na, "VWAP", col_d, 2)
d_u1p = plot(en_daily and en_d_b1 ? d_u1 : na, "Daily - STDEV 1",  col_d_band_edge, 1)
d_l1p = plot(en_daily and en_d_b1 ? d_l1 : na, "Daily - STDEV -1", col_d_band_edge, 1)
d_u2p = plot(en_daily and en_d_b2 ? d_u2 : na, "Daily - STDEV 2",  col_d_band_edge, 1)
d_l2p = plot(en_daily and en_d_b2 ? d_l2 : na, "Daily - STDEV -2", col_d_band_edge, 1)
fill(d_u1p, d_l1p, en_daily and en_d_b1 ? col_d_band : na, "Daily Band1 Fill")
fill(d_u2p, d_u1p, en_daily and en_d_b2 ? col_d_band : na, "Daily Band2 Up Fill")
fill(d_l1p, d_l2p, en_daily and en_d_b2 ? col_d_band : na, "Daily Band2 Lo Fill")

plot(en_daily and en_d_prev_vwap ? d_prev_vwap : na, "Prev Day VWAP", col_d_prev_mrk, 1, plot.style_circles)

d_vah_p  = plot(en_daily and en_d_dev_mrk ? d_vah : na, "VWAP - D1 Upper", color.new(col_d, 70), 1, plot.style_stepline)
d_val_p  = plot(en_daily and en_d_dev_mrk ? d_val : na, "VWAP - D1 Lower", color.new(col_d, 70), 1, plot.style_stepline)
fill(d_vah_p, d_val_p, en_daily and en_d_dev_mrk ? color.new(col_d, 92) : na, "Daily VA Fill")

d_pvah_p = plot(en_daily and en_d_prev_mrk ? d_prev_vah : na, "VWAP - C1 Upper 2", color.new(col_d_prev_mrk, 40), 1, plot.style_stepline)
d_pval_p = plot(en_daily and en_d_prev_mrk ? d_prev_val : na, "VWAP - C1 Lower 2", color.new(col_d_prev_mrk, 40), 1, plot.style_stepline)
fill(d_pvah_p, d_pval_p, en_daily and en_d_prev_mrk ? color.new(col_d_prev_mrk, 88) : na, "Prev Day VA Fill")

// ─────────────────────────────────────────────
// WEEKLY VWAP
// ─────────────────────────────────────────────

var float w_vah       = na
var float w_val       = na
var float w_prev_vwap = na
var float w_prev_vah  = na
var float w_prev_val  = na

[w_vwap, w_sumVol] = computeVWAP(hlc3, new_week)

if new_week
    w_prev_vwap := w_vwap[1]
    w_prev_vah  := w_vah[1]
    w_prev_val  := w_val[1]
    w_vah       := high
    w_val       := low
else
    w_vah := math.max(nz(w_vah, high), high)
    w_val := math.min(nz(w_val, low),  low)

[w_l1, w_u1] = computeBANDS(hlc3, new_week, b1_mult, w_vwap, w_sumVol)
[w_l2, w_u2] = computeBANDS(hlc3, new_week, b2_mult, w_vwap, w_sumVol)

plot(en_weekly and en_w_vwap ? w_vwap : na, "VWAP", col_w, 2)
w_u1p = plot(en_weekly and en_w_b1 ? w_u1 : na, "Weekly - STDEV 1",  col_w_band_edge, 1)
w_l1p = plot(en_weekly and en_w_b1 ? w_l1 : na, "Weekly - STDEV -1", col_w_band_edge, 1)
w_u2p = plot(en_weekly and en_w_b2 ? w_u2 : na, "Weekly - STDEV 2",  col_w_band_edge, 1)
w_l2p = plot(en_weekly and en_w_b2 ? w_l2 : na, "Weekly - STDEV -2", col_w_band_edge, 1)
fill(w_u1p, w_l1p, en_weekly and en_w_b1 ? col_w_band : na, "Weekly Band1 Fill")
fill(w_u2p, w_u1p, en_weekly and en_w_b2 ? col_w_band : na, "Weekly Band2 Up Fill")
fill(w_l1p, w_l2p, en_weekly and en_w_b2 ? col_w_band : na, "Weekly Band2 Lo Fill")

plot(en_weekly and en_w_prev_vwap ? w_prev_vwap : na, "Prev Week VWAP", col_w_prev_mrk, 1, plot.style_circles)

w_vah_p  = plot(en_weekly and en_w_dev_mrk ? w_vah : na, "VWAP - C2 Upper",   color.new(col_w, 70), 1, plot.style_stepline)
w_val_p  = plot(en_weekly and en_w_dev_mrk ? w_val : na, "VWAP - C2 Lower",   color.new(col_w, 70), 1, plot.style_stepline)
fill(w_vah_p, w_val_p, en_weekly and en_w_dev_mrk ? color.new(col_w, 92) : na, "Weekly VA Fill")

w_pvah_p = plot(en_weekly and en_w_prev_mrk ? w_prev_vah : na, "VWAP - C2 Upper 2", color.new(col_w_prev_mrk, 40), 1, plot.style_stepline)
w_pval_p = plot(en_weekly and en_w_prev_mrk ? w_prev_val : na, "VWAP - C2 Lower 2", color.new(col_w_prev_mrk, 40), 1, plot.style_stepline)
fill(w_pvah_p, w_pval_p, en_weekly and en_w_prev_mrk ? color.new(col_w_prev_mrk, 88) : na, "Prev Week VA Fill")

// ─────────────────────────────────────────────
// ROLLING DAILY VWAP
// Reuses daily VWAP values with separate color/style
// ─────────────────────────────────────────────

plot(en_rv and en_rv_vwap ? d_vwap : na, "Rolling VWAP",    col_rv,   2)
plot(en_rv and en_rv_b1   ? d_u1   : na, "RVWAP - Upper 1", col_rv_edge, 1)
plot(en_rv and en_rv_b1   ? d_l1   : na, "RVWAP - Lower 1", col_rv_edge, 1)
plot(en_rv and en_rv_b2   ? d_u2   : na, "RVWAP - Upper 2", col_rv_edge, 1)
plot(en_rv and en_rv_b2   ? d_l2   : na, "RVWAP - Lower 2", col_rv_edge, 1)

// ─────────────────────────────────────────────
// INITIAL BALANCE
// ─────────────────────────────────────────────

ib_start_mins = ib_start_hour * 60 + ib_start_min
ib_end_mins   = ib_end_hour   * 60 + ib_end_min
bar_mins      = hour * 60 + minute
in_ib_window  = bar_mins >= ib_start_mins and bar_mins < ib_end_mins

var float ib_high = na
var float ib_low  = na
if new_day
    ib_high := na
    ib_low  := na
if in_ib_window
    ib_high := na(ib_high) ? high : math.max(ib_high, high)
    ib_low  := na(ib_low)  ? low  : math.min(ib_low,  low)

plot(en_ib_mrk and not na(ib_high) ? ib_high : na, "IB High", col_ib_mrk, 1, plot.style_stepline)
plot(en_ib_mrk and not na(ib_low)  ? ib_low  : na, "IB Low",  col_ib_mrk, 1, plot.style_stepline)

// ─────────────────────────────────────────────
// LABELS
// ─────────────────────────────────────────────

if barstate.islast
    ls = label.style_label_left

    if en_daily and en_daily_mrk and not na(d_vwap)
        label.new(bar_index + d_mrk_offset, d_vwap, "D VWAP",
             color=color.new(col_d, 20), textcolor=color.white, style=ls, size=size.small)
    if en_daily and en_d_prev_vwap and not na(d_prev_vwap)
        label.new(bar_index + d_mrk_offset, d_prev_vwap, "pD VWAP",
             color=color.new(col_d_prev_mrk, 20), textcolor=color.white, style=ls, size=size.small)
    if en_daily and en_d_dev_mrk and not na(d_vah)
        label.new(bar_index + d_mrk_offset, d_vah, "D VAH",
             color=color.new(col_d, 40), textcolor=color.white, style=ls, size=size.small)
        label.new(bar_index + d_mrk_offset, d_val, "D VAL",
             color=color.new(col_d, 40), textcolor=color.white, style=ls, size=size.small)
    if en_daily and en_d_prev_mrk and not na(d_prev_vah)
        label.new(bar_index + d_mrk_offset, d_prev_vah, "pD VAH",
             color=color.new(col_d_prev_mrk, 40), textcolor=color.white, style=ls, size=size.small)
        label.new(bar_index + d_mrk_offset, d_prev_val, "pD VAL",
             color=color.new(col_d_prev_mrk, 40), textcolor=color.white, style=ls, size=size.small)
    if en_weekly and en_weekly_mrk and not na(w_vwap)
        label.new(bar_index + w_mrk_offset, w_vwap, "W VWAP",
             color=color.new(col_w, 20), textcolor=color.white, style=ls, size=size.small)
    if en_weekly and en_w_prev_vwap and not na(w_prev_vwap)
        label.new(bar_index + w_mrk_offset, w_prev_vwap, "pW VWAP",
             color=color.new(col_w_prev_mrk, 20), textcolor=color.white, style=ls, size=size.small)
    if en_weekly and en_w_dev_mrk and not na(w_vah)
        label.new(bar_index + w_mrk_offset, w_vah, "W VAH",
             color=color.new(col_w, 40), textcolor=color.white, style=ls, size=size.small)
        label.new(bar_index + w_mrk_offset, w_val, "W VAL",
             color=color.new(col_w, 40), textcolor=color.white, style=ls, size=size.small)
    if en_weekly and en_w_prev_mrk and not na(w_prev_vah)
        label.new(bar_index + w_mrk_offset, w_prev_vah, "pW VAH",
             color=color.new(col_w_prev_mrk, 40), textcolor=color.white, style=ls, size=size.small)
        label.new(bar_index + w_mrk_offset, w_prev_val, "pW VAL",
             color=color.new(col_w_prev_mrk, 40), textcolor=color.white, style=ls, size=size.small)
    if en_rv and en_rv_mrk and not na(d_vwap)
        label.new(bar_index + rv_mrk_offset, d_vwap, "RVWAP",
             color=color.new(col_rv, 20), textcolor=color.white, style=ls, size=size.small)
    if en_ib_mrk and not na(ib_high)
        label.new(bar_index + ib_mrk_offset, ib_high, "IB H",
             color=color.new(col_ib_mrk, 20), textcolor=color.white, style=ls, size=size.small)
        label.new(bar_index + ib_mrk_offset, ib_low, "IB L",
             color=color.new(col_ib_mrk, 20), textcolor=color.white, style=ls, size=size.small)
````
