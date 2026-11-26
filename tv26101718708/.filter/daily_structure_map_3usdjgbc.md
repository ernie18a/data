# Daily Structure Map

- url: https://www.tradingview.com/script/3USDJGBC-Daily-Structure-Map/
- type: indicator
- pine_id: PUB;af359e9342844fd9b73a1481146a182a
- version: 5.0

## Description

Plots key daily price levels and detects significant gap movements between sessions, helping traders quickly identify where price opened and closed relative to the previous day.
Features:

Daily Open & Close lines — color-coded red/green based on current price position, so you instantly know if price is trading above or below key daily levels
Day Separators — dashed vertical lines that mark the start of each new trading day, working consistently across all instruments including 24/7 markets like gold (XAUUSD) and crypto
GAP Signal — cross markers that fire when the percentage difference between two consecutive daily closes exceeds a configurable threshold, highlighting meaningful breakout gaps
Alerts — built-in long and short gap breakout alerts you can set and forget

Best used on intraday timeframes (1m–1H) to see daily structure overlaid on your lower timeframe charts. Fully customizable threshold, separator color, and timeframe seeker to adapt to any instrument or trading style.

## Source Code

````pine
//@version=5
indicator("Daily Structure Map", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500)

doc_threshold = input.float(0.001, 'GAP Close Threshold')
doc_t         = input.timeframe(title="Timeframe seeker", defval='D')

// ── Day Separators ────────────────────────────────────────────────────────
show_separators = input.bool(true,  "Show Day Separators",      group="Day Separators")
sep_color       = input.color(color.new(color.gray, 60), "Color",  group="Day Separators")
sep_style_str   = input.string("Dashed", "Style", options=["Solid", "Dashed", "Dotted"], group="Day Separators")
sep_width       = input.int(1, "Width", minval=1, maxval=5, group="Day Separators")

sep_style = sep_style_str == "Solid" ? line.style_solid : sep_style_str == "Dashed" ? line.style_dashed : line.style_dotted

// ── Day of Week Labels ────────────────────────────────────────────────────
show_dow_labels = input.bool(true, "Show Day of Week Labels", group="Day Labels")
dow_text_color  = input.color(color.silver, "Label Color",    group="Day Labels")

// ── Daily Open/Close Spans ────────────────────────────────────────────────
show_oc_spans = input.bool(true, "Show Daily Open/Close Spans", group="Open/Close Spans")
oc_color      = input.color(color.new(color.gray, 30), "Span Color", group="Open/Close Spans")
oc_style_str  = input.string("Dotted", "Span Style", options=["Solid", "Dashed", "Dotted"], group="Open/Close Spans")
oc_width      = input.int(2, "Span Width", minval=1, maxval=5, group="Open/Close Spans")

oc_style = oc_style_str == "Solid" ? line.style_solid : oc_style_str == "Dashed" ? line.style_dashed : line.style_dotted

// ── Levels ────────────────────────────────────────────────────────────────
show_levels      = input.bool(true, "Show Levels", group="Levels")
levels_show_lbl  = input.bool(true, "Show Labels", group="Levels")

show_pdh = input.bool(true, "Previous Day High (PDH)",    inline="pdh", group="Levels")
pdh_color = input.color(color.new(#26A69A, 0), "",        inline="pdh", group="Levels")
show_pdl = input.bool(true, "Previous Day Low (PDL)",     inline="pdl", group="Levels")
pdl_color = input.color(color.new(#EF5350, 0), "",        inline="pdl", group="Levels")
show_pdc = input.bool(true, "Previous Day Close (PDC)",   inline="pdc", group="Levels")
pdc_color = input.color(color.new(color.gray, 0), "",     inline="pdc", group="Levels")

show_pwh = input.bool(true, "Previous Week High (PWH)",   inline="pwh", group="Levels")
pwh_color = input.color(color.new(#26A69A, 20), "",       inline="pwh", group="Levels")
show_pwl = input.bool(true, "Previous Week Low (PWL)",    inline="pwl", group="Levels")
pwl_color = input.color(color.new(#EF5350, 20), "",       inline="pwl", group="Levels")

show_pmh = input.bool(true, "Previous Month High (PMH)",  inline="pmh", group="Levels")
pmh_color = input.color(color.new(#26A69A, 40), "",       inline="pmh", group="Levels")
show_pml = input.bool(true, "Previous Month Low (PML)",   inline="pml", group="Levels")
pml_color = input.color(color.new(#EF5350, 40), "",       inline="pml", group="Levels")
show_pmc = input.bool(true, "Previous Month Close (PMC)", inline="pmc", group="Levels")
pmc_color = input.color(color.new(color.orange, 0), "",   inline="pmc", group="Levels")

levels_style_str = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Levels")
levels_width     = input.int(1, "Line Width", minval=1, maxval=4, group="Levels")

levels_style = levels_style_str == "Solid" ? line.style_solid : levels_style_str == "Dashed" ? line.style_dashed : line.style_dotted

// ── Security calls ────────────────────────────────────────────────────────
d_open      = request.security(syminfo.tickerid, 'D', open,     lookahead=barmerge.lookahead_on)
d_prevClose = request.security(syminfo.tickerid, 'D', close[1], lookahead=barmerge.lookahead_on)

doc_yesterday = request.security(syminfo.tickerid, doc_t, close[1], lookahead=barmerge.lookahead_on)
doc_today     = request.security(syminfo.tickerid, doc_t, close[0], lookahead=barmerge.lookahead_on)

dHigh  = request.security(syminfo.tickerid, "D", high,  lookahead=barmerge.lookahead_on)
dLow   = request.security(syminfo.tickerid, "D", low,   lookahead=barmerge.lookahead_on)
dClose = request.security(syminfo.tickerid, "D", close, lookahead=barmerge.lookahead_on)

wHigh = request.security(syminfo.tickerid, "W", high, lookahead=barmerge.lookahead_on)
wLow  = request.security(syminfo.tickerid, "W", low,  lookahead=barmerge.lookahead_on)

mHigh  = request.security(syminfo.tickerid, "M", high,  lookahead=barmerge.lookahead_on)
mLow   = request.security(syminfo.tickerid, "M", low,   lookahead=barmerge.lookahead_on)
mClose = request.security(syminfo.tickerid, "M", close, lookahead=barmerge.lookahead_on)

// ── Period change detection ───────────────────────────────────────────────
is_new_day   = ta.change(time("D"))   != 0
is_new_week  = ta.change(time("W"))   != 0
is_new_month = ta.change(time("M"))   != 0

// ── Track origin bars + snapshot in one step ─────────────────────────────
// When a new high/low appears, capture both the price AND the bar in current_*.
// At period rollover, copy current_* into prev_* — no historical lookback needed.

var float cur_dh = na
var int   cur_dh_bar = na
var float cur_dl = na
var int   cur_dl_bar = na
var float cur_wh = na
var int   cur_wh_bar = na
var float cur_wl = na
var int   cur_wl_bar = na
var float cur_mh = na
var int   cur_mh_bar = na
var float cur_ml = na
var int   cur_ml_bar = na

var float prev_dh = na
var int   prev_dh_bar = na
var float prev_dl = na
var int   prev_dl_bar = na
var float prev_dc = na
var int   prev_dc_bar = na

var float prev_wh = na
var int   prev_wh_bar = na
var float prev_wl = na
var int   prev_wl_bar = na

var float prev_mh = na
var int   prev_mh_bar = na
var float prev_ml = na
var int   prev_ml_bar = na
var float prev_mc = na
var int   prev_mc_bar = na

// On period rollover: snapshot current → previous, then reset current
if is_new_day
    prev_dh := cur_dh
    prev_dh_bar := cur_dh_bar
    prev_dl := cur_dl
    prev_dl_bar := cur_dl_bar
    prev_dc := close[1]
    prev_dc_bar := bar_index - 1
    cur_dh := dHigh
    cur_dh_bar := bar_index
    cur_dl := dLow
    cur_dl_bar := bar_index
else
    if na(cur_dh) or dHigh > cur_dh
        cur_dh := dHigh
        cur_dh_bar := bar_index
    if na(cur_dl) or dLow < cur_dl
        cur_dl := dLow
        cur_dl_bar := bar_index

if is_new_week
    prev_wh := cur_wh
    prev_wh_bar := cur_wh_bar
    prev_wl := cur_wl
    prev_wl_bar := cur_wl_bar
    cur_wh := wHigh
    cur_wh_bar := bar_index
    cur_wl := wLow
    cur_wl_bar := bar_index
else
    if na(cur_wh) or wHigh > cur_wh
        cur_wh := wHigh
        cur_wh_bar := bar_index
    if na(cur_wl) or wLow < cur_wl
        cur_wl := wLow
        cur_wl_bar := bar_index

if is_new_month
    prev_mh := cur_mh
    prev_mh_bar := cur_mh_bar
    prev_ml := cur_ml
    prev_ml_bar := cur_ml_bar
    prev_mc := mClose[1]
    prev_mc_bar := bar_index - 1
    cur_mh := mHigh
    cur_mh_bar := bar_index
    cur_ml := mLow
    cur_ml_bar := bar_index
else
    if na(cur_mh) or mHigh > cur_mh
        cur_mh := mHigh
        cur_mh_bar := bar_index
    if na(cur_ml) or mLow < cur_ml
        cur_ml := mLow
        cur_ml_bar := bar_index

// ── Day Separators / DOW Labels / Open-Close Spans ───────────────────────
var line open_line  = na
var line close_line = na

if is_new_day and not na(close)
    if not na(open_line)
        line.set_x2(open_line, bar_index - 1)
    if not na(close_line)
        line.set_x2(close_line, bar_index - 1)

    if show_separators
        line.new(bar_index, high, bar_index, low, extend=extend.both, color=sep_color, style=sep_style, width=sep_width)

    if show_dow_labels
        string dow_text = switch dayofweek
            dayofweek.monday    => "Mon"
            dayofweek.tuesday   => "Tue"
            dayofweek.wednesday => "Wed"
            dayofweek.thursday  => "Thu"
            dayofweek.friday    => "Fri"
            dayofweek.saturday  => "Sat"
            dayofweek.sunday    => "Sun"
        label.new(bar_index, high, dow_text, color=color.new(color.black, 100), textcolor=dow_text_color, style=label.style_label_down, size=size.small, yloc=yloc.abovebar)

    if show_oc_spans
        open_line  := line.new(bar_index, d_open,      bar_index, d_open,      color=oc_color, style=oc_style, width=oc_width)
        close_line := line.new(bar_index, d_prevClose, bar_index, d_prevClose, color=oc_color, style=oc_style, width=oc_width)

if show_oc_spans and not na(open_line)
    line.set_x2(open_line, bar_index)
if show_oc_spans and not na(close_line)
    line.set_x2(close_line, bar_index)

// ── Level Rays ────────────────────────────────────────────────────────────
var line  ln_pdh = na
var line  ln_pdl = na
var line  ln_pdc = na
var line  ln_pwh = na
var line  ln_pwl = na
var line  ln_pmh = na
var line  ln_pml = na
var line  ln_pmc = na

var label lb_pdh = na
var label lb_pdl = na
var label lb_pdc = na
var label lb_pwh = na
var label lb_pwl = na
var label lb_pmh = na
var label lb_pml = na
var label lb_pmc = na

f_drawRay(_origin_bar, _price, _color, _txt, _lineRef, _labelRef, _show) =>
    line  newLine  = _lineRef
    label newLabel = _labelRef
    if _show and not na(_origin_bar) and not na(_price)
        line.delete(_lineRef)
        label.delete(_labelRef)
        newLine := line.new(_origin_bar, _price, bar_index, _price, color=_color, style=levels_style, width=levels_width, extend=extend.right)
        if levels_show_lbl
            newLabel := label.new(bar_index, _price, _txt, color=color.new(color.black, 100), textcolor=_color, style=label.style_label_left, size=size.small)
    [newLine, newLabel]

if show_levels and is_new_day
    [l1, b1] = f_drawRay(prev_dh_bar, prev_dh, pdh_color, "PDH", ln_pdh, lb_pdh, show_pdh)
    ln_pdh := l1
    lb_pdh := b1
    [l2, b2] = f_drawRay(prev_dl_bar, prev_dl, pdl_color, "PDL", ln_pdl, lb_pdl, show_pdl)
    ln_pdl := l2
    lb_pdl := b2
    [l3, b3] = f_drawRay(prev_dc_bar, prev_dc, pdc_color, "PDC", ln_pdc, lb_pdc, show_pdc)
    ln_pdc := l3
    lb_pdc := b3

if show_levels and is_new_week
    [l4, b4] = f_drawRay(prev_wh_bar, prev_wh, pwh_color, "PWH", ln_pwh, lb_pwh, show_pwh)
    ln_pwh := l4
    lb_pwh := b4
    [l5, b5] = f_drawRay(prev_wl_bar, prev_wl, pwl_color, "PWL", ln_pwl, lb_pwl, show_pwl)
    ln_pwl := l5
    lb_pwl := b5

if show_levels and is_new_month
    [l6, b6] = f_drawRay(prev_mh_bar, prev_mh, pmh_color, "PMH", ln_pmh, lb_pmh, show_pmh)
    ln_pmh := l6
    lb_pmh := b6
    [l7, b7] = f_drawRay(prev_ml_bar, prev_ml, pml_color, "PML", ln_pml, lb_pml, show_pml)
    ln_pml := l7
    lb_pml := b7
    [l8, b8] = f_drawRay(prev_mc_bar, prev_mc, pmc_color, "PMC", ln_pmc, lb_pmc, show_pmc)
    ln_pmc := l8
    lb_pmc := b8

if show_levels and barstate.islast
    if not na(lb_pdh)
        label.set_x(lb_pdh, bar_index)
    if not na(lb_pdl)
        label.set_x(lb_pdl, bar_index)
    if not na(lb_pdc)
        label.set_x(lb_pdc, bar_index)
    if not na(lb_pwh)
        label.set_x(lb_pwh, bar_index)
    if not na(lb_pwl)
        label.set_x(lb_pwl, bar_index)
    if not na(lb_pmh)
        label.set_x(lb_pmh, bar_index)
    if not na(lb_pml)
        label.set_x(lb_pml, bar_index)
    if not na(lb_pmc)
        label.set_x(lb_pmc, bar_index)

// ── GAP Detection ─────────────────────────────────────────────────────────
doc_delta     = doc_today - doc_yesterday
doc_closeDiff = doc_delta / doc_yesterday

doc_b       = doc_closeDiff > doc_threshold ? true : doc_closeDiff < -doc_threshold ? false : na
doc_dcolor3 = doc_b == false ? color.red : doc_b == true ? color.green : color.gray

plot(doc_b != doc_b[1] and not na(doc_b) ? doc_yesterday : na, title="GAP Signal", style=plot.style_cross, color=doc_dcolor3, linewidth=8)

alertcondition(doc_b != doc_b[1] and doc_b == false, title="SHORT GAP BREAKOUT", message='SHORT: {{ticker}}/{{interval}} at price {{close}} on {{exchange}}')
alertcondition(doc_b != doc_b[1] and doc_b == true,  title="LONG GAP BREAKOUT",  message='LONG: {{ticker}}/{{interval}} at price {{close}} on {{exchange}}')
````
