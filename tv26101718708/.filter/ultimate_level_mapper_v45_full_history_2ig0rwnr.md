# Ultimate Level Mapper v45 - Full History

- url: https://www.tradingview.com/script/2IG0RWNr-Ultimate-Level-Mapper-v45-Full-History/
- type: indicator
- pine_id: PUB;6f67754256ac4f8e90cb8ad1d9f1ec21
- version: 4.0

## Description

pdh pdl pwh pwl pmh pml 5 min h/l last 5 days' close & ATH

## Source Code

````pine
//@version=5
indicator("Ultimate Level Mapper v54 - Multi-Source ATH", overlay=true, max_lines_count=500, max_bars_back=5000)

// ==========================================
// --- INPUTS: COLORS & WIDTHS
// ==========================================
grp_pdhl   = "Previous Day High/Low"
col_pdh    = input.color(color.gray, "PDH Color", group=grp_pdhl)
w_pdh      = input.int(1, "PDH Width", group=grp_pdhl)
col_pdl    = input.color(color.gray, "PDL Color", group=grp_pdhl)
w_pdl      = input.int(1, "PDL Width", group=grp_pdhl)

grp_closes = "Historical Closes"
col_c1     = input.color(color.new(color.white, 0),  "Yesterday Color", group=grp_closes)
w_c1       = input.int(1, "Yesterday Width", group=grp_closes)
col_c2     = input.color(color.new(color.white, 20), "2 Days Color", group=grp_closes)
w_c2       = input.int(1, "2 Days Width", group=grp_closes)
col_c3     = input.color(color.new(color.white, 40), "3 Days Color", group=grp_closes)
w_c3       = input.int(1, "3 Days Width", group=grp_closes)
col_c4     = input.color(color.new(color.white, 60), "4 Days Color", group=grp_closes)
w_c4       = input.int(1, "4 Days Width", group=grp_closes)
col_c5     = input.color(color.new(color.white, 80), "5 Days Color", group=grp_closes)
w_c5       = input.int(1, "5 Days Width", group=grp_closes)

grp_pm     = "Premarket"
col_pmh    = input.color(color.purple, "PM High Color", group=grp_pm)
w_pmh      = input.int(1, "PM High Width", group=grp_pm)
col_pml    = input.color(color.purple, "PM Low Color", group=grp_pm)
w_pml      = input.int(1, "PM Low Width", group=grp_pm)

grp_orb    = "Opening Range"
col_orbh   = input.color(color.white, "5min High Color", group=grp_orb)
w_orbh     = input.int(2, "5min High Width", group=grp_orb)
col_orbl   = input.color(color.white, "5min Low Color", group=grp_orb)
w_orbl     = input.int(2, "5min Low Width", group=grp_orb)

grp_ath    = "All-Time High"
col_ath    = input.color(color.maroon, "ATH Color", group=grp_ath)
w_ath      = input.int(3, "ATH Width", group=grp_ath)

grp_wk     = "Weekly Levels"
col_pwh    = input.color(color.blue, "PW High Color", group=grp_wk)
w_pwh      = input.int(2, "PW High Width", group=grp_wk)
col_pwl    = input.color(color.blue, "PW Low Color", group=grp_wk)
w_pwl      = input.int(2, "PW Low Width", group=grp_wk)

lbl_size   = input.string("small", "Label Size", options=["tiny", "small", "normal"])

// ==========================================
// --- CALCULATIONS
// ==========================================
is_rth = not na(time(timeframe.period, "0930-1600:23456", "America/New_York"))
is_new_day = ta.change(time("D", "America/New_York")) != 0
is_monday = dayofweek(time) == dayofweek.monday

// 1. ATH DEEP SEARCH
// We pull from three timeframes to ensure the value isn't 'na'
ath_m = request.security(syminfo.tickerid, "M", ta.highest(high, 500), lookahead=barmerge.lookahead_on)
ath_w = request.security(syminfo.tickerid, "W", ta.highest(high, 500), lookahead=barmerge.lookahead_on)
ath_d = request.security(syminfo.tickerid, "D", ta.highest(high, 500), lookahead=barmerge.lookahead_on)

var float ath = 0.0
// Logic: Use the highest non-zero value found across all requests
ath := math.max(nz(ath_m), math.max(nz(ath_w), math.max(nz(ath_d), nz(ath))))

// 2. Manual RTH Tracking
var float rth_h = na, var float rth_l = na, var float rth_c = na
if is_rth
    rth_h := not is_rth[1] ? high : math.max(high, rth_h)
    rth_l := not is_rth[1] ? low  : math.min(low, rth_l)
    rth_c := close

// 3. Historical Data
[w_h_curr, w_l_curr, w_h_prev, w_l_prev] = request.security(syminfo.tickerid, "W", [high, low, high[1], low[1]], lookahead=barmerge.lookahead_on)
[d_c_0, d_c_1, d_c_2, d_c_3, d_c_4] = request.security(syminfo.tickerid, "D", [close[1], close[2], close[3], close[4], close[5]], lookahead=barmerge.lookahead_on)

var float pdh = na, var float pdl = na
var float c1 = na, var float c2 = na, var float c3 = na, var float c4 = na, var float c5 = na
var float pwh = na, var float pwl = na

if is_new_day or barstate.isfirst
    pdh := rth_h, pdl := rth_l
    c1 := rth_c, c2 := d_c_0, c3 := d_c_1, c4 := d_c_2, c5 := d_c_3
    
    if is_monday
        pwh := w_h_curr, pwl := w_l_curr
    else
        pwh := w_h_prev, pwl := w_l_prev

// 4. Intraday Tracking
is_pre = not na(time(timeframe.period, "0400-0930:23456", "America/New_York"))
is_orb = not na(time(timeframe.period, "0930-0935:23456", "America/New_York"))
var float pmh = na, var float pml = na, var int pm_idx = na
var float orbh = na, var float orbl = na, var int orb_idx = na

if is_new_day
    pmh := na, pml := na, pm_idx := na, orbh := na, orbl := na, orb_idx := na

if is_pre
    if na(pmh) 
        pm_idx := bar_index
        pmh := high, pml := low
    else
        pmh := math.max(high, pmh), pml := math.min(low, pml)

if is_orb
    if na(orbh)
        orb_idx := bar_index
        orbh := high, orbl := low
    else
        orbh := math.max(high, orbh), orbl := math.min(low, orbl)

// ==========================================
// --- DRAWING ENGINE
// ==========================================
var label[] all_labels = array.new_label()
var line[]  all_lines  = array.new_line()
var float[] used_prices = array.new_float()

f_draw(float val, string txt, color col, int width, int start_idx, bool is_dashed) =>
    if not na(val) and val > 0
        int x_off = 2
        if array.size(used_prices) > 0
            for i = 0 to array.size(used_prices) - 1
                if math.abs(array.get(used_prices, i) - val) < (val * 0.0001)
                    x_off += 15
        array.push(used_prices, val)
        int final_start = na(start_idx) ? (bar_index > 100 ? bar_index - 100 : 0) : start_idx
        array.push(all_lines, line.new(final_start, val, bar_index, val, xloc=xloc.bar_index, extend=extend.right, color=col, width=width, style=is_dashed ? line.style_dashed : line.style_solid))
        array.push(all_labels, label.new(bar_index + x_off, val, txt, xloc=xloc.bar_index, color=col, textcolor=color.white, style=label.style_label_left, size=lbl_size))

if barstate.islast
    while array.size(all_labels) > 0
        label.delete(array.shift(all_labels))
    while array.size(all_lines) > 0
        line.delete(array.shift(all_lines))
    array.clear(used_prices)

    f_draw(pdh, "PDH", col_pdh, w_pdh, na, false)
    f_draw(pdl, "PDL", col_pdl, w_pdl, na, false)
    f_draw(ath, "ATH", col_ath, w_ath, na, false)
    f_draw(pwh, "PW High", col_pwh, w_pwh, na, false)
    f_draw(pwl, "PW Low", col_pwl, w_pwl, na, false)
    f_draw(c1, "Yesterday", col_c1, w_c1, na, false)
    f_draw(c2, "2 days ago", col_c2, w_c2, na, false)
    f_draw(c3, "3 days ago", col_c3, w_c3, na, false)
    f_draw(c4, "4 days ago", col_c4, w_c4, na, false)
    f_draw(c5, "5 days ago", col_c5, w_c5, na, false)
    f_draw(pmh, "PM High", col_pmh, w_pmh, pm_idx, true)
    f_draw(pml, "PM Low", col_pml, w_pml, pm_idx, true)
    f_draw(orbh, "5min High", col_orbh, w_orbh, orb_idx, false)
    f_draw(orbl, "5min Low", col_orbl, w_orbl, orb_idx, false)
````
