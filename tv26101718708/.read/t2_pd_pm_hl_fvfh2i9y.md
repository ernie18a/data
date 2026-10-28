# T2 PD & PM HL

- url: https://www.tradingview.com/script/FVFH2i9Y-T2-PD-PM-HL/
- type: indicator
- pine_id: PUB;9efb9828dcdb460288ddab93383c71f5
- version: 1.0

## Description

Previous Day High and Low (Regular Hours) and Pre-Market High and Low (4am ET to 9:29ET). Resets each day.

## Source Code

````pine
// PDH / PDL / PMH / PML Key Levels Indicator
//@version=6
indicator("Levels", overlay=true, max_lines_count=20, max_labels_count=20)

// ─── SETTINGS ───────────────────────────────────────────────────────────────

var g_pd = "Previous Day Levels"
pdh_color   = input.color(color.new(#26a69a, 0), "PDH Color", group=g_pd)
pdl_color   = input.color(color.new(#ef5350, 0), "PDL Color", group=g_pd)
pd_style    = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=g_pd)
pd_width    = input.int(1, "Line Width", minval=1, maxval=4, group=g_pd)
show_pd     = input.bool(true, "Show PDH/PDL", group=g_pd)

var g_pm = "Pre-Market Levels"
pmh_color   = input.color(color.new(#66bb6a, 0), "PMH Color", group=g_pm)
pml_color   = input.color(color.new(#ff7043, 0), "PML Color", group=g_pm)
pm_style    = input.string("Dashed", "Line Style", options=["Solid","Dashed","Dotted"], group=g_pm)
pm_width    = input.int(1, "Line Width", minval=1, maxval=4, group=g_pm)
show_pm     = input.bool(true, "Show PMH/PML", group=g_pm)

var g_lbl = "Labels"
show_name   = input.bool(true, "Show Level Name", group=g_lbl)
show_price  = input.bool(true, "Show Price", group=g_lbl)
label_size  = input.string(size.small, "Label Size", options=[size.tiny, size.small, size.normal, size.large], group=g_lbl)

var g_ext = "Extensions"
extend_bars = input.int(10, "Extend Lines (bars right)", minval=0, maxval=500, group=g_ext)

var g_ema = "8 EMA"
show_ema    = input.bool(true, "Show 8 EMA", group=g_ema)
ema_color   = input.color(color.new(#f9a825, 0), "EMA Color", group=g_ema)
ema_width   = input.int(1, "EMA Width", minval=1, maxval=4, group=g_ema)

// ─── HELPERS ────────────────────────────────────────────────────────────────

f_line_style(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_label_text(lname, price) =>
    n   = show_name  ? lname : ""
    sep = (show_name and show_price) ? "  " : ""
    p   = show_price ? str.tostring(price, format.mintick) : ""
    n + sep + p

// ─── SESSION DETECTION (from reference script) ──────────────────────────────

in_premarket = not na(time(timeframe.period, "0400-0930", "America/New_York"))
in_rth       = not na(time(timeframe.period, "0930-1600", "America/New_York"))
new_day      = ta.change(time("D")) != 0
rth_start    = not in_rth[1] and in_rth

// ─── RTH HIGH/LOW ACCUMULATOR (current day → becomes PDH/PDL tomorrow) ──────

var float rth_day_high = na
var float rth_day_low  = na
var int   rth_high_time = na
var int   rth_low_time  = na

if rth_start
    rth_day_high  := high
    rth_day_low   := low
    rth_high_time := time
    rth_low_time  := time
else if in_rth
    if na(rth_day_high) or high > rth_day_high
        rth_day_high  := high
        rth_high_time := time
    if na(rth_day_low) or low < rth_day_low
        rth_day_low  := low
        rth_low_time := time

// ─── LOCK PDH/PDL AT START OF NEW DAY ───────────────────────────────────────

var float pdh_val  = na
var float pdl_val  = na
var int   pdh_time = na
var int   pdl_time = na

if new_day
    pdh_val  := rth_day_high
    pdl_val  := rth_day_low
    pdh_time := rth_high_time
    pdl_time := rth_low_time

// ─── PRE-MARKET HIGH/LOW ACCUMULATOR ────────────────────────────────────────

var float pm_high      = na
var float pm_low       = na
var int   pm_high_time = na
var int   pm_low_time  = na
var int   pm_date      = na

new_pm_day = new_day or (in_premarket and (na(pm_date) or pm_date != dayofmonth(time)))

if new_pm_day
    pm_high      := na
    pm_low       := na
    pm_high_time := na
    pm_low_time  := na
    pm_date      := dayofmonth(time)

if in_premarket
    if na(pm_high) or high > pm_high
        pm_high      := high
        pm_high_time := time
    if na(pm_low) or low < pm_low
        pm_low      := low
        pm_low_time := time

// ─── LINE / LABEL VARS ───────────────────────────────────────────────────────

var line  l_pdh  = na
var line  l_pdl  = na
var line  l_pmh  = na
var line  l_pml  = na
var label lb_pdh = na
var label lb_pdl = na
var label lb_pmh = na
var label lb_pml = na

// ─── DRAW FUNCTION ───────────────────────────────────────────────────────────

ms_per_bar  = timeframe.in_seconds() * 1000
extend_time = time + extend_bars * ms_per_bar

// PD levels: redraw only when new_day locks in fresh values
if new_day and not na(pdh_val) and not na(pdh_time)
    line.delete(l_pdh),  label.delete(lb_pdh)
    line.delete(l_pdl),  label.delete(lb_pdl)

    if show_pd
        l_pdh  := line.new(pdh_time, pdh_val, extend_time, pdh_val, xloc=xloc.bar_time, color=pdh_color, style=f_line_style(pd_style), width=pd_width)
        lb_pdh := label.new(extend_time, pdh_val, f_label_text("PDH", pdh_val), xloc=xloc.bar_time, color=color.new(pdh_color, 85), textcolor=pdh_color, style=label.style_label_left, size=label_size)
        l_pdl  := line.new(pdl_time, pdl_val, extend_time, pdl_val, xloc=xloc.bar_time, color=pdl_color, style=f_line_style(pd_style), width=pd_width)
        lb_pdl := label.new(extend_time, pdl_val, f_label_text("PDL", pdl_val), xloc=xloc.bar_time, color=color.new(pdl_color, 85), textcolor=pdl_color, style=label.style_label_left, size=label_size)

// Extend PD right edge each bar
if show_pd
    if not na(l_pdh)
        line.set_x2(l_pdh,  extend_time)
        label.set_x(lb_pdh, extend_time)
    if not na(l_pdl)
        line.set_x2(l_pdl,  extend_time)
        label.set_x(lb_pdl, extend_time)

// PM levels: redraw each bar so line tracks the actual H/L candle live
if show_pm and (in_premarket or in_rth)
    if not na(pm_high) and not na(pm_high_time)
        line.delete(l_pmh),  label.delete(lb_pmh)
        l_pmh  := line.new(pm_high_time, pm_high, extend_time, pm_high, xloc=xloc.bar_time, color=pmh_color, style=f_line_style(pm_style), width=pm_width)
        lb_pmh := label.new(extend_time, pm_high, f_label_text("PMH", pm_high), xloc=xloc.bar_time, color=color.new(pmh_color, 85), textcolor=pmh_color, style=label.style_label_left, size=label_size)
    if not na(pm_low) and not na(pm_low_time)
        line.delete(l_pml),  label.delete(lb_pml)
        l_pml  := line.new(pm_low_time, pm_low, extend_time, pm_low, xloc=xloc.bar_time, color=pml_color, style=f_line_style(pm_style), width=pm_width)
        lb_pml := label.new(extend_time, pm_low, f_label_text("PML", pm_low), xloc=xloc.bar_time, color=color.new(pml_color, 85), textcolor=pml_color, style=label.style_label_left, size=label_size)

// ─── 8 EMA ───────────────────────────────────────────────────────────────────

ema8 = ta.ema(close, 8)
plot(show_ema ? ema8 : na, title="8 EMA", color=ema_color, linewidth=ema_width)
````
