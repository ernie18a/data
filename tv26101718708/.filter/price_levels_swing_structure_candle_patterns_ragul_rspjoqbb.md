# Price Levels + Swing Structure + Candle Patterns- Ragul

- url: https://www.tradingview.com/script/rSpjOqbb-Price-Levels-Swing-Structure-Candle-Patterns-Ragul/
- type: indicator
- pine_id: PUB;4fe4cdad81ba4cb5b254f3af633f22f7
- version: 6.0

## Description

Previous High and Low - DAY, MONTH, WEEK
Swing High Low- 15m,60m
Candle Stick Patterns

## Source Code

````pine
//@version=6
indicator("RAGUL — Price Levels + Swing Structure + Candle Patterns", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//   HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

f_ls(s) =>
    s == "dashed" ? line.style_dashed : s == "dotted" ? line.style_dotted : line.style_solid

f_lbl_size(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : size.normal

f_tbl_pos(p) =>
    p == "top_left"     ? position.top_left     :
     p == "bottom_right" ? position.bottom_right :
     p == "bottom_left"  ? position.bottom_left  :
     position.top_right

// ── Run on every bar so Pine doesn't warn about scope ──
chart_high_300 = ta.highest(high, 300)
chart_low_300  = ta.lowest(low,  300)

// ═══════════════════════════════════════════════════════════════
//   PRESET SELECTOR
// ═══════════════════════════════════════════════════════════════

grp_preset  = "━━━ RAGUL PRESET TEMPLATE SELECTOR ━━━"
preset_mode = input.string("Default", "Active Template",
     options = ["Default", "My Preset 1", "My Preset 2", "My Preset 3"],
     tooltip = "Switch presets. To customise a preset edit the color values in the script source.",
     group   = grp_preset)

// ╔══════════════════════════════════════════════════════════════╗
// ║     RAGUL MODULE 1 — PREVIOUS PERIOD PRICE LEVELS           ║
// ╚══════════════════════════════════════════════════════════════╝

grp1  = "━━━ RAGUL MODULE 1 · PREVIOUS PERIOD PRICE LEVELS ━━━"
pdpwpm_on    = input.bool(true, "Enable Previous Period Levels", group=grp1)

grp1a = "Daily — Previous Day Levels"
show_PDH     = input.bool(true,  "Show PDH",           group=grp1a)
show_PDL     = input.bool(true,  "Show PDL",           group=grp1a)
show_PDC     = input.bool(true,  "Show PDC",           group=grp1a)
show_PDO     = input.bool(false, "Show PDO",           group=grp1a)
show_PDEQ    = input.bool(true,  "Show EQ (Midpoint)", group=grp1a)
col_PDH      = input.color(color.new(#00E5FF, 0),  "PDH Color", group=grp1a)
col_PDL      = input.color(color.new(#00E5FF, 0),  "PDL Color", group=grp1a)
col_PDC      = input.color(color.new(#FFD600, 0),  "PDC Color", group=grp1a)
col_PDO      = input.color(color.new(#FFD600, 60), "PDO Color", group=grp1a)
col_PDEQ     = input.color(color.new(#78909C, 0),  "EQ Color",  group=grp1a)
pd_lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp1a)
pd_style     = input.string("solid",  "Line Style", options=["solid","dashed","dotted"], group=grp1a)
pd_show_lbl  = input.bool(true, "Show Labels", group=grp1a)
pd_lbl_mode  = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp1a)
pd_lbl_every = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp1a)
pd_lbl_size  = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp1a)

grp1b = "Weekly — Previous Week Levels"
show_PWH     = input.bool(true,  "Show PWH", group=grp1b)
show_PWL     = input.bool(true,  "Show PWL", group=grp1b)
show_PWC     = input.bool(false, "Show PWC", group=grp1b)
show_PWO     = input.bool(false, "Show PWO", group=grp1b)
col_PWH      = input.color(color.new(#FF6D00, 0),  "PWH Color", group=grp1b)
col_PWL      = input.color(color.new(#FF6D00, 0),  "PWL Color", group=grp1b)
col_PWC      = input.color(color.new(#FFAB40, 60), "PWC Color", group=grp1b)
col_PWO      = input.color(color.new(#FFAB40, 60), "PWO Color", group=grp1b)
pw_lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp1b)
pw_style     = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp1b)
pw_show_lbl  = input.bool(true, "Show Labels", group=grp1b)
pw_lbl_mode  = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp1b)
pw_lbl_every = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp1b)
pw_lbl_size  = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp1b)

grp1c = "Monthly — Previous Month Levels"
show_PMH     = input.bool(true,  "Show PMH", group=grp1c)
show_PML     = input.bool(true,  "Show PML", group=grp1c)
show_PMC     = input.bool(false, "Show PMC", group=grp1c)
show_PMO     = input.bool(false, "Show PMO", group=grp1c)
col_PMH      = input.color(color.new(#E040FB, 0),  "PMH Color", group=grp1c)
col_PML      = input.color(color.new(#E040FB, 0),  "PML Color", group=grp1c)
col_PMC      = input.color(color.new(#CE93D8, 60), "PMC Color", group=grp1c)
col_PMO      = input.color(color.new(#CE93D8, 60), "PMO Color", group=grp1c)
pm_lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp1c)
pm_style     = input.string("dotted", "Line Style", options=["solid","dashed","dotted"], group=grp1c)
pm_show_lbl  = input.bool(true, "Show Labels", group=grp1c)
pm_lbl_mode  = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp1c)
pm_lbl_every = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp1c)
pm_lbl_size  = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp1c)

// ── Runtime preset color overrides ──
pdh_col  = preset_mode == "My Preset 1" ? color.new(#FF0000,0)  : preset_mode == "My Preset 2" ? color.new(#FFD700,0)  : preset_mode == "My Preset 3" ? color.new(#00BFFF,0)  : col_PDH
pdl_col  = preset_mode == "My Preset 1" ? color.new(#FF0000,0)  : preset_mode == "My Preset 2" ? color.new(#FFD700,0)  : preset_mode == "My Preset 3" ? color.new(#00BFFF,0)  : col_PDL
pdc_col  = preset_mode == "My Preset 1" ? color.new(#FFA500,0)  : preset_mode == "My Preset 2" ? color.new(#ADFF2F,0)  : preset_mode == "My Preset 3" ? color.new(#DA70D6,0)  : col_PDC
pdo_col  = preset_mode == "My Preset 1" ? color.new(#FFA500,60) : preset_mode == "My Preset 2" ? color.new(#ADFF2F,60) : preset_mode == "My Preset 3" ? color.new(#DA70D6,60) : col_PDO
pdeq_col = preset_mode == "My Preset 1" ? color.new(#808080,0)  : preset_mode == "My Preset 2" ? color.new(#708090,0)  : preset_mode == "My Preset 3" ? color.new(#696969,0)  : col_PDEQ
pwh_col  = preset_mode == "My Preset 1" ? color.new(#FF6347,0)  : preset_mode == "My Preset 2" ? color.new(#FF8C00,0)  : preset_mode == "My Preset 3" ? color.new(#FF4500,0)  : col_PWH
pwl_col  = preset_mode == "My Preset 1" ? color.new(#FF6347,0)  : preset_mode == "My Preset 2" ? color.new(#FF8C00,0)  : preset_mode == "My Preset 3" ? color.new(#FF4500,0)  : col_PWL
pwc_col  = preset_mode == "My Preset 1" ? color.new(#FF6347,60) : preset_mode == "My Preset 2" ? color.new(#FF8C00,60) : preset_mode == "My Preset 3" ? color.new(#FF4500,60) : col_PWC
pwo_col  = preset_mode == "My Preset 1" ? color.new(#FF6347,60) : preset_mode == "My Preset 2" ? color.new(#FF8C00,60) : preset_mode == "My Preset 3" ? color.new(#FF4500,60) : col_PWO
pmh_col  = preset_mode == "My Preset 1" ? color.new(#9400D3,0)  : preset_mode == "My Preset 2" ? color.new(#8A2BE2,0)  : preset_mode == "My Preset 3" ? color.new(#9932CC,0)  : col_PMH
pml_col  = preset_mode == "My Preset 1" ? color.new(#9400D3,0)  : preset_mode == "My Preset 2" ? color.new(#8A2BE2,0)  : preset_mode == "My Preset 3" ? color.new(#9932CC,0)  : col_PML
pmc_col  = preset_mode == "My Preset 1" ? color.new(#9400D3,60) : preset_mode == "My Preset 2" ? color.new(#8A2BE2,60) : preset_mode == "My Preset 3" ? color.new(#9932CC,60) : col_PMC
pmo_col  = preset_mode == "My Preset 1" ? color.new(#9400D3,60) : preset_mode == "My Preset 2" ? color.new(#8A2BE2,60) : preset_mode == "My Preset 3" ? color.new(#9932CC,60) : col_PMO

// ── Fetch HTF data ──
[d_o, d_h, d_l, d_c] = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[w_o, w_h, w_l, w_c] = request.security(syminfo.tickerid, "W", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[m_o, m_h, m_l, m_c] = request.security(syminfo.tickerid, "M", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
pd_eq = (d_h + d_l) / 2

// ── Persistent line/label storage for Module 1 (delete & redraw on last bar) ──
var line[]  m1_lines  = array.new_line()
var label[] m1_labels = array.new_label()

f_cont_lbl(show, val, col, lbl, every, show_lbl, lbl_mode, lbl_size) =>
    if show and show_lbl and lbl_mode == "Continuous" and bar_index % every == 0
        label.new(bar_index, val, lbl, color=color.new(col, 75), textcolor=col, style=label.style_label_center, size=f_lbl_size(lbl_size))

if pdpwpm_on and barstate.islast
    // Delete previous lines and labels
    for ln in m1_lines
        line.delete(ln)
    array.clear(m1_lines)
    for lb in m1_labels
        label.delete(lb)
    array.clear(m1_labels)

    // Redraw lines
    if show_PDH and not na(d_h)
        array.push(m1_lines, line.new(bar_index-200, d_h, bar_index, d_h, color=pdh_col, width=pd_lw, style=f_ls(pd_style), extend=extend.right))
        if pd_show_lbl and pd_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, d_h, "PDH", color=color.new(pdh_col,80), textcolor=pdh_col, style=label.style_label_left, size=f_lbl_size(pd_lbl_size)))
    if show_PDL and not na(d_l)
        array.push(m1_lines, line.new(bar_index-200, d_l, bar_index, d_l, color=pdl_col, width=pd_lw, style=f_ls(pd_style), extend=extend.right))
        if pd_show_lbl and pd_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, d_l, "PDL", color=color.new(pdl_col,80), textcolor=pdl_col, style=label.style_label_left, size=f_lbl_size(pd_lbl_size)))
    if show_PDC and not na(d_c)
        array.push(m1_lines, line.new(bar_index-200, d_c, bar_index, d_c, color=pdc_col, width=pd_lw, style=f_ls(pd_style), extend=extend.right))
        if pd_show_lbl and pd_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, d_c, "PDC", color=color.new(pdc_col,80), textcolor=pdc_col, style=label.style_label_left, size=f_lbl_size(pd_lbl_size)))
    if show_PDO and not na(d_o)
        array.push(m1_lines, line.new(bar_index-200, d_o, bar_index, d_o, color=pdo_col, width=pd_lw, style=f_ls(pd_style), extend=extend.right))
        if pd_show_lbl and pd_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, d_o, "PDO", color=color.new(pdo_col,80), textcolor=pdo_col, style=label.style_label_left, size=f_lbl_size(pd_lbl_size)))
    if show_PDEQ and not na(pd_eq)
        array.push(m1_lines, line.new(bar_index-200, pd_eq, bar_index, pd_eq, color=pdeq_col, width=pd_lw, style=f_ls(pd_style), extend=extend.right))
        if pd_show_lbl and pd_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, pd_eq, "EQ", color=color.new(pdeq_col,80), textcolor=pdeq_col, style=label.style_label_left, size=f_lbl_size(pd_lbl_size)))
    if show_PWH and not na(w_h)
        array.push(m1_lines, line.new(bar_index-200, w_h, bar_index, w_h, color=pwh_col, width=pw_lw, style=f_ls(pw_style), extend=extend.right))
        if pw_show_lbl and pw_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, w_h, "PWH", color=color.new(pwh_col,80), textcolor=pwh_col, style=label.style_label_left, size=f_lbl_size(pw_lbl_size)))
    if show_PWL and not na(w_l)
        array.push(m1_lines, line.new(bar_index-200, w_l, bar_index, w_l, color=pwl_col, width=pw_lw, style=f_ls(pw_style), extend=extend.right))
        if pw_show_lbl and pw_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, w_l, "PWL", color=color.new(pwl_col,80), textcolor=pwl_col, style=label.style_label_left, size=f_lbl_size(pw_lbl_size)))
    if show_PWC and not na(w_c)
        array.push(m1_lines, line.new(bar_index-200, w_c, bar_index, w_c, color=pwc_col, width=pw_lw, style=f_ls(pw_style), extend=extend.right))
        if pw_show_lbl and pw_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, w_c, "PWC", color=color.new(pwc_col,80), textcolor=pwc_col, style=label.style_label_left, size=f_lbl_size(pw_lbl_size)))
    if show_PWO and not na(w_o)
        array.push(m1_lines, line.new(bar_index-200, w_o, bar_index, w_o, color=pwo_col, width=pw_lw, style=f_ls(pw_style), extend=extend.right))
        if pw_show_lbl and pw_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, w_o, "PWO", color=color.new(pwo_col,80), textcolor=pwo_col, style=label.style_label_left, size=f_lbl_size(pw_lbl_size)))
    if show_PMH and not na(m_h)
        array.push(m1_lines, line.new(bar_index-200, m_h, bar_index, m_h, color=pmh_col, width=pm_lw, style=f_ls(pm_style), extend=extend.right))
        if pm_show_lbl and pm_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, m_h, "PMH", color=color.new(pmh_col,80), textcolor=pmh_col, style=label.style_label_left, size=f_lbl_size(pm_lbl_size)))
    if show_PML and not na(m_l)
        array.push(m1_lines, line.new(bar_index-200, m_l, bar_index, m_l, color=pml_col, width=pm_lw, style=f_ls(pm_style), extend=extend.right))
        if pm_show_lbl and pm_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, m_l, "PML", color=color.new(pml_col,80), textcolor=pml_col, style=label.style_label_left, size=f_lbl_size(pm_lbl_size)))
    if show_PMC and not na(m_c)
        array.push(m1_lines, line.new(bar_index-200, m_c, bar_index, m_c, color=pmc_col, width=pm_lw, style=f_ls(pm_style), extend=extend.right))
        if pm_show_lbl and pm_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, m_c, "PMC", color=color.new(pmc_col,80), textcolor=pmc_col, style=label.style_label_left, size=f_lbl_size(pm_lbl_size)))
    if show_PMO and not na(m_o)
        array.push(m1_lines, line.new(bar_index-200, m_o, bar_index, m_o, color=pmo_col, width=pm_lw, style=f_ls(pm_style), extend=extend.right))
        if pm_show_lbl and pm_lbl_mode == "Single"
            array.push(m1_labels, label.new(bar_index+1, m_o, "PMO", color=color.new(pmo_col,80), textcolor=pmo_col, style=label.style_label_left, size=f_lbl_size(pm_lbl_size)))

// Continuous labels (run every bar)
if pdpwpm_on
    f_cont_lbl(show_PDH,  d_h,   pdh_col,  "PDH", pd_lbl_every, pd_show_lbl, pd_lbl_mode, pd_lbl_size)
    f_cont_lbl(show_PDL,  d_l,   pdl_col,  "PDL", pd_lbl_every, pd_show_lbl, pd_lbl_mode, pd_lbl_size)
    f_cont_lbl(show_PDC,  d_c,   pdc_col,  "PDC", pd_lbl_every, pd_show_lbl, pd_lbl_mode, pd_lbl_size)
    f_cont_lbl(show_PDO,  d_o,   pdo_col,  "PDO", pd_lbl_every, pd_show_lbl, pd_lbl_mode, pd_lbl_size)
    f_cont_lbl(show_PDEQ, pd_eq, pdeq_col, "EQ",  pd_lbl_every, pd_show_lbl, pd_lbl_mode, pd_lbl_size)
    f_cont_lbl(show_PWH,  w_h,   pwh_col,  "PWH", pw_lbl_every, pw_show_lbl, pw_lbl_mode, pw_lbl_size)
    f_cont_lbl(show_PWL,  w_l,   pwl_col,  "PWL", pw_lbl_every, pw_show_lbl, pw_lbl_mode, pw_lbl_size)
    f_cont_lbl(show_PWC,  w_c,   pwc_col,  "PWC", pw_lbl_every, pw_show_lbl, pw_lbl_mode, pw_lbl_size)
    f_cont_lbl(show_PWO,  w_o,   pwo_col,  "PWO", pw_lbl_every, pw_show_lbl, pw_lbl_mode, pw_lbl_size)
    f_cont_lbl(show_PMH,  m_h,   pmh_col,  "PMH", pm_lbl_every, pm_show_lbl, pm_lbl_mode, pm_lbl_size)
    f_cont_lbl(show_PML,  m_l,   pml_col,  "PML", pm_lbl_every, pm_show_lbl, pm_lbl_mode, pm_lbl_size)
    f_cont_lbl(show_PMC,  m_c,   pmc_col,  "PMC", pm_lbl_every, pm_show_lbl, pm_lbl_mode, pm_lbl_size)
    f_cont_lbl(show_PMO,  m_o,   pmo_col,  "PMO", pm_lbl_every, pm_show_lbl, pm_lbl_mode, pm_lbl_size)


// ╔══════════════════════════════════════════════════════════════╗
// ║         RAGUL MODULE 1B — TODAY'S DAY HIGH / LOW            ║
// ╚══════════════════════════════════════════════════════════════╝

grp1e = "━━━ RAGUL MODULE 1B · TODAY'S DAY HIGH / LOW ━━━"
show_today    = input.bool(true,  "Enable Today High / Low",  group=grp1e)
show_TDH      = input.bool(true,  "Show Today High (TDH)",    group=grp1e)
show_TDL      = input.bool(true,  "Show Today Low  (TDL)",    group=grp1e)
col_TDH       = input.color(color.new(#00FF88, 0), "TDH Color", group=grp1e)
col_TDL       = input.color(color.new(#FF4444, 0), "TDL Color", group=grp1e)
tdhl_lw       = input.int(1, "Line Width", minval=1, maxval=4, group=grp1e)
tdhl_style    = input.string("solid", "Line Style", options=["solid","dashed","dotted"], group=grp1e)
td_show_lbl   = input.bool(true, "Show Labels", group=grp1e)
td_lbl_mode   = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp1e)
td_lbl_every  = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp1e)
td_lbl_size   = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp1e)

tdh_col_rt = preset_mode == "My Preset 1" ? color.new(#00FF7F,0) : preset_mode == "My Preset 2" ? color.new(#32CD32,0) : preset_mode == "My Preset 3" ? color.new(#7CFC00,0) : col_TDH
tdl_col_rt = preset_mode == "My Preset 1" ? color.new(#DC143C,0) : preset_mode == "My Preset 2" ? color.new(#B22222,0) : preset_mode == "My Preset 3" ? color.new(#FF6347,0) : col_TDL

is_new_day = ta.change(time("D")) != 0
var float today_high = na
var float today_low  = na

if is_new_day or na(today_high)
    today_high := high
    today_low  := low
else
    today_high := math.max(today_high, high)
    today_low  := math.min(today_low,  low)

if show_today and td_show_lbl and td_lbl_mode == "Continuous"
    if show_TDH and not na(today_high) and bar_index % td_lbl_every == 0
        label.new(bar_index, today_high, "TDH", color=color.new(tdh_col_rt,75), textcolor=tdh_col_rt, style=label.style_label_center, size=f_lbl_size(td_lbl_size))
    if show_TDL and not na(today_low) and bar_index % td_lbl_every == 0
        label.new(bar_index, today_low, "TDL", color=color.new(tdl_col_rt,75), textcolor=tdl_col_rt, style=label.style_label_center, size=f_lbl_size(td_lbl_size))

var line  tdh_line = na
var line  tdl_line = na
var label tdh_lbl  = na
var label tdl_lbl  = na

if show_today
    if show_TDH and not na(today_high)
        if not na(tdh_line)
            line.delete(tdh_line)
        tdh_line := line.new(bar_index, today_high, bar_index+1, today_high, color=tdh_col_rt, width=tdhl_lw, style=f_ls(tdhl_style), extend=extend.both)
        if td_show_lbl and td_lbl_mode == "Single"
            if not na(tdh_lbl)
                label.delete(tdh_lbl)
            tdh_lbl := label.new(bar_index+1, today_high, "TDH", color=color.new(tdh_col_rt,80), textcolor=tdh_col_rt, style=label.style_label_left, size=f_lbl_size(td_lbl_size))
    if show_TDL and not na(today_low)
        if not na(tdl_line)
            line.delete(tdl_line)
        tdl_line := line.new(bar_index, today_low, bar_index+1, today_low, color=tdl_col_rt, width=tdhl_lw, style=f_ls(tdhl_style), extend=extend.both)
        if td_show_lbl and td_lbl_mode == "Single"
            if not na(tdl_lbl)
                label.delete(tdl_lbl)
            tdl_lbl := label.new(bar_index+1, today_low, "TDL", color=color.new(tdl_col_rt,80), textcolor=tdl_col_rt, style=label.style_label_left, size=f_lbl_size(td_lbl_size))


// ╔══════════════════════════════════════════════════════════════╗
// ║     RAGUL MODULE 1C — TODAY'S 1H HIGH / LOW                 ║
// ╚══════════════════════════════════════════════════════════════╝

grp1f = "━━━ RAGUL MODULE 1C · TODAY'S 1H HIGH / LOW ━━━"
show_td1h      = input.bool(true, "Enable Today 1H High / Low", group=grp1f)
show_TD1HH     = input.bool(true, "Show Today 1H High",         group=grp1f)
show_TD1HL     = input.bool(true, "Show Today 1H Low",          group=grp1f)
col_TD1HH      = input.color(color.new(#FF9800,0), "1H High Color", group=grp1f)
col_TD1HL      = input.color(color.new(#00BCD4,0), "1H Low Color",  group=grp1f)
td1h_lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp1f)
td1h_style     = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp1f)
td1h_show_lbl  = input.bool(true, "Show Labels", group=grp1f)
td1h_lbl_mode  = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp1f)
td1h_lbl_every = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp1f)
td1h_lbl_size  = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp1f)

h1_sess_high = request.security(syminfo.tickerid, "60", high, lookahead=barmerge.lookahead_off)
h1_sess_low  = request.security(syminfo.tickerid, "60", low,  lookahead=barmerge.lookahead_off)
h1_new_day   = ta.change(request.security(syminfo.tickerid, "60", time("D"), lookahead=barmerge.lookahead_off)) != 0

var float td1h_high = na
var float td1h_low  = na

if h1_new_day or na(td1h_high)
    td1h_high := h1_sess_high
    td1h_low  := h1_sess_low
else
    td1h_high := math.max(td1h_high, h1_sess_high)
    td1h_low  := math.min(td1h_low,  h1_sess_low)

if show_td1h and td1h_show_lbl and td1h_lbl_mode == "Continuous"
    if show_TD1HH and not na(td1h_high) and bar_index % td1h_lbl_every == 0
        label.new(bar_index, td1h_high, "1H TDH", color=color.new(col_TD1HH,75), textcolor=col_TD1HH, style=label.style_label_center, size=f_lbl_size(td1h_lbl_size))
    if show_TD1HL and not na(td1h_low) and bar_index % td1h_lbl_every == 0
        label.new(bar_index, td1h_low, "1H TDL", color=color.new(col_TD1HL,75), textcolor=col_TD1HL, style=label.style_label_center, size=f_lbl_size(td1h_lbl_size))

var line  td1h_hline = na
var line  td1h_lline = na
var label td1h_hlbl  = na
var label td1h_llbl  = na

if show_td1h
    if show_TD1HH and not na(td1h_high)
        if not na(td1h_hline)
            line.delete(td1h_hline)
        td1h_hline := line.new(bar_index, td1h_high, bar_index+1, td1h_high, color=col_TD1HH, width=td1h_lw, style=f_ls(td1h_style), extend=extend.both)
        if td1h_show_lbl and td1h_lbl_mode == "Single"
            if not na(td1h_hlbl)
                label.delete(td1h_hlbl)
            td1h_hlbl := label.new(bar_index+1, td1h_high, "1H TDH " + str.tostring(td1h_high, format.mintick), color=color.new(col_TD1HH,80), textcolor=col_TD1HH, style=label.style_label_left, size=f_lbl_size(td1h_lbl_size))
    if show_TD1HL and not na(td1h_low)
        if not na(td1h_lline)
            line.delete(td1h_lline)
        td1h_lline := line.new(bar_index, td1h_low, bar_index+1, td1h_low, color=col_TD1HL, width=td1h_lw, style=f_ls(td1h_style), extend=extend.both)
        if td1h_show_lbl and td1h_lbl_mode == "Single"
            if not na(td1h_llbl)
                label.delete(td1h_llbl)
            td1h_llbl := label.new(bar_index+1, td1h_low, "1H TDL " + str.tostring(td1h_low, format.mintick), color=color.new(col_TD1HL,80), textcolor=col_TD1HL, style=label.style_label_left, size=f_lbl_size(td1h_lbl_size))


// ╔══════════════════════════════════════════════════════════════╗
// ║     RAGUL MODULE 1D — TODAY'S 15M HIGH / LOW                ║
// ╚══════════════════════════════════════════════════════════════╝

grp1g = "━━━ RAGUL MODULE 1D · TODAY'S 15M HIGH / LOW ━━━"
show_td15m      = input.bool(true, "Enable Today 15M High / Low", group=grp1g)
show_TD15MH     = input.bool(true, "Show Today 15M High",         group=grp1g)
show_TD15ML     = input.bool(true, "Show Today 15M Low",          group=grp1g)
col_TD15MH      = input.color(color.new(#CDDC39,0), "15M High Color", group=grp1g)
col_TD15ML      = input.color(color.new(#AB47BC,0), "15M Low Color",  group=grp1g)
td15m_lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp1g)
td15m_style     = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp1g)
td15m_show_lbl  = input.bool(true, "Show Labels", group=grp1g)
td15m_lbl_mode  = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp1g)
td15m_lbl_every = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp1g)
td15m_lbl_size  = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp1g)

m15_sess_high = request.security(syminfo.tickerid, "15", high, lookahead=barmerge.lookahead_off)
m15_sess_low  = request.security(syminfo.tickerid, "15", low,  lookahead=barmerge.lookahead_off)
m15_new_day   = ta.change(request.security(syminfo.tickerid, "15", time("D"), lookahead=barmerge.lookahead_off)) != 0

var float td15m_high = na
var float td15m_low  = na

if m15_new_day or na(td15m_high)
    td15m_high := m15_sess_high
    td15m_low  := m15_sess_low
else
    td15m_high := math.max(td15m_high, m15_sess_high)
    td15m_low  := math.min(td15m_low,  m15_sess_low)

if show_td15m and td15m_show_lbl and td15m_lbl_mode == "Continuous"
    if show_TD15MH and not na(td15m_high) and bar_index % td15m_lbl_every == 0
        label.new(bar_index, td15m_high, "15M TDH", color=color.new(col_TD15MH,75), textcolor=col_TD15MH, style=label.style_label_center, size=f_lbl_size(td15m_lbl_size))
    if show_TD15ML and not na(td15m_low) and bar_index % td15m_lbl_every == 0
        label.new(bar_index, td15m_low, "15M TDL", color=color.new(col_TD15ML,75), textcolor=col_TD15ML, style=label.style_label_center, size=f_lbl_size(td15m_lbl_size))

var line  td15m_hline = na
var line  td15m_lline = na
var label td15m_hlbl  = na
var label td15m_llbl  = na

if show_td15m
    if show_TD15MH and not na(td15m_high)
        if not na(td15m_hline)
            line.delete(td15m_hline)
        td15m_hline := line.new(bar_index, td15m_high, bar_index+1, td15m_high, color=col_TD15MH, width=td15m_lw, style=f_ls(td15m_style), extend=extend.both)
        if td15m_show_lbl and td15m_lbl_mode == "Single"
            if not na(td15m_hlbl)
                label.delete(td15m_hlbl)
            td15m_hlbl := label.new(bar_index+1, td15m_high, "15M TDH " + str.tostring(td15m_high, format.mintick), color=color.new(col_TD15MH,80), textcolor=col_TD15MH, style=label.style_label_left, size=f_lbl_size(td15m_lbl_size))
    if show_TD15ML and not na(td15m_low)
        if not na(td15m_lline)
            line.delete(td15m_lline)
        td15m_lline := line.new(bar_index, td15m_low, bar_index+1, td15m_low, color=col_TD15ML, width=td15m_lw, style=f_ls(td15m_style), extend=extend.both)
        if td15m_show_lbl and td15m_lbl_mode == "Single"
            if not na(td15m_llbl)
                label.delete(td15m_llbl)
            td15m_llbl := label.new(bar_index+1, td15m_low, "15M TDL " + str.tostring(td15m_low, format.mintick), color=color.new(col_TD15ML,80), textcolor=col_TD15ML, style=label.style_label_left, size=f_lbl_size(td15m_lbl_size))


// ╔══════════════════════════════════════════════════════════════╗
// ║     RAGUL MODULE 2 — CHART TIMEFRAME SWING STRUCTURE        ║
// ╚══════════════════════════════════════════════════════════════╝

grp2 = "━━━ RAGUL MODULE 2 · CHART TIMEFRAME SWING STRUCTURE ━━━"
rv5_on         = input.bool(true, "Enable Chart TF Swing Structure", group=grp2)
rv5_sh_left    = input.int(5, "Swing High — Bars Left",  minval=1, group=grp2)
rv5_sh_right   = input.int(5, "Swing High — Bars Right", minval=1, group=grp2)
rv5_sl_left    = input.int(5, "Swing Low  — Bars Left",  minval=1, group=grp2)
rv5_sl_right   = input.int(5, "Swing Low  — Bars Right", minval=1, group=grp2)

grp2a = "Current Swing Level Style"
rv5_cur_sh_col  = input.color(color.new(#F44336,0), "Current High Color", group=grp2a)
rv5_cur_sl_col  = input.color(color.new(#4CAF50,0), "Current Low Color",  group=grp2a)
rv5_cur_sh_st   = input.string("solid", "Current High Style", options=["solid","dashed","dotted"], group=grp2a)
rv5_cur_sl_st   = input.string("solid", "Current Low Style",  options=["solid","dashed","dotted"], group=grp2a)
rv5_cur_lw      = input.int(2, "Current Line Width", minval=1, maxval=4, group=grp2a)
rv5_show_lbl    = input.bool(true, "Show Labels", group=grp2a)
rv5_lbl_mode    = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp2a)
rv5_lbl_every   = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp2a)
rv5_lbl_size    = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp2a)

grp2b = "Past Swing Level Style"
rv5_past_sh_col = input.color(color.new(#F44336,70), "Past High Color", group=grp2b)
rv5_past_sl_col = input.color(color.new(#4CAF50,70), "Past Low Color",  group=grp2b)
rv5_past_sh_st  = input.string("dashed", "Past High Style", options=["solid","dashed","dotted"], group=grp2b)
rv5_past_sl_st  = input.string("dashed", "Past Low Style",  options=["solid","dashed","dotted"], group=grp2b)
rv5_past_lw     = input.int(1, "Past Line Width", minval=1, maxval=4, group=grp2b)
rv5_max_past    = input.int(5, "Max Past Levels", minval=1, maxval=20, group=grp2b)

rv5_ph = ta.pivothigh(high, rv5_sh_left, rv5_sh_right)
rv5_pl = ta.pivotlow(low,   rv5_sl_left, rv5_sl_right)

var float  rv5_cur_sh_val  = na
var int    rv5_cur_sh_bar  = na
var float  rv5_cur_sl_val  = na
var int    rv5_cur_sl_bar  = na
var line   rv5_cur_sh_line = na
var line   rv5_cur_sl_line = na
var label  rv5_cur_sh_lbl  = na
var label  rv5_cur_sl_lbl  = na
var line[] rv5_past_sh_lns = array.new_line()
var line[] rv5_past_sl_lns = array.new_line()

if rv5_on
    if not na(rv5_ph)
        ph_bar = bar_index - rv5_sh_right
        if not na(rv5_cur_sh_val) and not na(rv5_cur_sh_line)
            line.set_color(rv5_cur_sh_line,  rv5_past_sh_col)
            line.set_style(rv5_cur_sh_line,  f_ls(rv5_past_sh_st))
            line.set_width(rv5_cur_sh_line,  rv5_past_lw)
            line.set_extend(rv5_cur_sh_line, extend.none)
            array.push(rv5_past_sh_lns, rv5_cur_sh_line)
            if array.size(rv5_past_sh_lns) > rv5_max_past
                line.delete(array.shift(rv5_past_sh_lns))
        rv5_cur_sh_val  := rv5_ph
        rv5_cur_sh_bar  := ph_bar
        rv5_cur_sh_line := line.new(ph_bar, rv5_ph, bar_index, rv5_ph, color=rv5_cur_sh_col, style=f_ls(rv5_cur_sh_st), width=rv5_cur_lw, extend=extend.right)
        if rv5_show_lbl and rv5_lbl_mode == "Single"
            if not na(rv5_cur_sh_lbl)
                label.delete(rv5_cur_sh_lbl)
            rv5_cur_sh_lbl := label.new(ph_bar, rv5_ph, "SH " + str.tostring(rv5_ph, format.mintick), color=color.new(rv5_cur_sh_col,80), textcolor=rv5_cur_sh_col, style=label.style_label_down, size=f_lbl_size(rv5_lbl_size))

    if not na(rv5_pl)
        pl_bar = bar_index - rv5_sl_right
        if not na(rv5_cur_sl_val) and not na(rv5_cur_sl_line)
            line.set_color(rv5_cur_sl_line,  rv5_past_sl_col)
            line.set_style(rv5_cur_sl_line,  f_ls(rv5_past_sl_st))
            line.set_width(rv5_cur_sl_line,  rv5_past_lw)
            line.set_extend(rv5_cur_sl_line, extend.none)
            array.push(rv5_past_sl_lns, rv5_cur_sl_line)
            if array.size(rv5_past_sl_lns) > rv5_max_past
                line.delete(array.shift(rv5_past_sl_lns))
        rv5_cur_sl_val  := rv5_pl
        rv5_cur_sl_bar  := pl_bar
        rv5_cur_sl_line := line.new(pl_bar, rv5_pl, bar_index, rv5_pl, color=rv5_cur_sl_col, style=f_ls(rv5_cur_sl_st), width=rv5_cur_lw, extend=extend.right)
        if rv5_show_lbl and rv5_lbl_mode == "Single"
            if not na(rv5_cur_sl_lbl)
                label.delete(rv5_cur_sl_lbl)
            rv5_cur_sl_lbl := label.new(pl_bar, rv5_pl, "SL " + str.tostring(rv5_pl, format.mintick), color=color.new(rv5_cur_sl_col,80), textcolor=rv5_cur_sl_col, style=label.style_label_up, size=f_lbl_size(rv5_lbl_size))

    if not na(rv5_cur_sh_line)
        line.set_x2(rv5_cur_sh_line, bar_index)
    if not na(rv5_cur_sl_line)
        line.set_x2(rv5_cur_sl_line, bar_index)

    if rv5_show_lbl and rv5_lbl_mode == "Continuous" and bar_index % rv5_lbl_every == 0
        if not na(rv5_cur_sh_val)
            label.new(bar_index, rv5_cur_sh_val, "SH", color=color.new(rv5_cur_sh_col,75), textcolor=rv5_cur_sh_col, style=label.style_label_center, size=f_lbl_size(rv5_lbl_size))
        if not na(rv5_cur_sl_val)
            label.new(bar_index, rv5_cur_sl_val, "SL", color=color.new(rv5_cur_sl_col,75), textcolor=rv5_cur_sl_col, style=label.style_label_center, size=f_lbl_size(rv5_lbl_size))


// ╔══════════════════════════════════════════════════════════════╗
// ║   RAGUL MODULE 3 — SWING STRUCTURE WITH CANDLE PATTERNS     ║
// ╚══════════════════════════════════════════════════════════════╝

grp3 = "━━━ RAGUL MODULE 3 · SWING STRUCTURE WITH CANDLE PATTERNS ━━━"
lux_on            = input.bool(true, "Enable Swing + Candle Patterns", group=grp3)
lux_length        = input.int(20, "Swing Sensitivity (Length)", minval=1, maxval=100, group=grp3)

grp3a = "Swing Structure Labels and Lines"
lux_show_HH       = input.bool(true, "Show HH", group=grp3a)
lux_show_HL       = input.bool(true, "Show HL", group=grp3a)
lux_show_LH       = input.bool(true, "Show LH", group=grp3a)
lux_show_LL       = input.bool(true, "Show LL", group=grp3a)
lux_col_sh        = input.color(color.new(#EF5350,0), "Swing High Color", group=grp3a)
lux_col_sl        = input.color(color.new(#26A69A,0), "Swing Low Color",  group=grp3a)
lux_extend_lines  = input.bool(true, "Extend Lines to Right", group=grp3a)
lux_line_style    = input.string("dashed", "Line Style", options=["solid","dashed","dotted"], group=grp3a)
lux_sh_lw         = input.int(1, "High Line Width", minval=1, maxval=4, group=grp3a)
lux_sl_lw         = input.int(1, "Low Line Width",  minval=1, maxval=4, group=grp3a)
lux_max_lines     = input.int(10, "Max Lines to Show", minval=1, maxval=50, group=grp3a)
lux_show_lbl      = input.bool(true, "Show Labels", group=grp3a)
lux_lbl_mode      = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp3a)
lux_lbl_every     = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp3a)
lux_lbl_size      = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp3a)

grp3b = "Candle Pattern Detection"
lux_show_patterns = input.bool(true, "Show Candle Pattern Labels", group=grp3b)
lux_show_hammer   = input.bool(true, "Hammer",            group=grp3b)
lux_show_inv_ham  = input.bool(true, "Inverted Hammer",   group=grp3b)
lux_show_bull_eng = input.bool(true, "Bullish Engulfing", group=grp3b)
lux_show_hang     = input.bool(true, "Hanging Man",       group=grp3b)
lux_show_shoot    = input.bool(true, "Shooting Star",     group=grp3b)
lux_show_bear_eng = input.bool(true, "Bearish Engulfing", group=grp3b)

lux_ph = ta.pivothigh(lux_length, lux_length)
lux_pl = ta.pivotlow(lux_length,  lux_length)

var float  lux_prev_ph     = na
var float  lux_prev_pl     = na
var float  lux_last_sh_val = na
var float  lux_last_sl_val = na
var string lux_last_sh_tag = na
var string lux_last_sl_tag = na
var line[] lux_sh_lines    = array.new_line()
var line[] lux_sl_lines    = array.new_line()

f_body_top(off)   => math.max(open[off], close[off])
f_body_bot(off)   => math.min(open[off], close[off])
f_body(off)       => math.abs(close[off] - open[off])
f_upper_wick(off) => high[off] - f_body_top(off)
f_lower_wick(off) => f_body_bot(off) - low[off]
f_range(off)      => high[off] - low[off]

f_hammer(off)     => f_lower_wick(off) >= 2 * f_body(off) and f_upper_wick(off) <= 0.1 * f_range(off) and f_range(off) > 0
f_inv_hammer(off) => f_upper_wick(off) >= 2 * f_body(off) and f_lower_wick(off) <= 0.1 * f_range(off) and f_range(off) > 0
f_bull_eng(off)   => close[off] > open[off] and close[off+1] < open[off+1] and close[off] > open[off+1] and open[off] < close[off+1]
f_hang_man(off)   => f_lower_wick(off) >= 2 * f_body(off) and f_upper_wick(off) <= 0.1 * f_range(off) and close[off] < open[off] and f_range(off) > 0
f_shoot_star(off) => f_upper_wick(off) >= 2 * f_body(off) and f_lower_wick(off) <= 0.1 * f_range(off) and f_range(off) > 0
f_bear_eng(off)   => close[off] < open[off] and close[off+1] > open[off+1] and close[off] < open[off+1] and open[off] > close[off+1]

f_candle_label(off) =>
    string result = ""
    if f_hammer(off) and lux_show_hammer
        result := "Hammer"
    else if f_inv_hammer(off) and lux_show_inv_ham
        result := "Inv Hammer"
    else if f_bull_eng(off) and lux_show_bull_eng
        result := "Bull Eng"
    else if f_hang_man(off) and lux_show_hang
        result := "Hang Man"
    else if f_shoot_star(off) and lux_show_shoot
        result := "Shoot Star"
    else if f_bear_eng(off) and lux_show_bear_eng
        result := "Bear Eng"
    result

if lux_on
    if not na(lux_ph)
        ph_bar   = bar_index - lux_length
        is_HH    = na(lux_prev_ph) or lux_ph > lux_prev_ph
        tag      = is_HH ? "HH" : "LH"
        show_tag = (is_HH and lux_show_HH) or (not is_HH and lux_show_LH)
        if show_tag
            pat = lux_show_patterns ? f_candle_label(lux_length) : ""
            lbl = tag + (pat != "" ? " " + pat : "")
            if lux_show_lbl and lux_lbl_mode == "Single"
                label.new(ph_bar, lux_ph, lbl, color=color.new(lux_col_sh,80), textcolor=lux_col_sh, style=label.style_label_down, size=f_lbl_size(lux_lbl_size))
            ln = line.new(ph_bar, lux_ph, ph_bar+1, lux_ph, color=lux_col_sh, style=f_ls(lux_line_style), width=lux_sh_lw, extend=lux_extend_lines ? extend.right : extend.none)
            array.push(lux_sh_lines, ln)
            if array.size(lux_sh_lines) > lux_max_lines
                line.delete(array.shift(lux_sh_lines))
            lux_last_sh_val := lux_ph
            lux_last_sh_tag := tag
        lux_prev_ph := lux_ph

    if not na(lux_pl)
        pl_bar   = bar_index - lux_length
        is_HL    = na(lux_prev_pl) or lux_pl > lux_prev_pl
        tag      = is_HL ? "HL" : "LL"
        show_tag = (is_HL and lux_show_HL) or (not is_HL and lux_show_LL)
        if show_tag
            pat = lux_show_patterns ? f_candle_label(lux_length) : ""
            lbl = tag + (pat != "" ? " " + pat : "")
            if lux_show_lbl and lux_lbl_mode == "Single"
                label.new(pl_bar, lux_pl, lbl, color=color.new(lux_col_sl,80), textcolor=lux_col_sl, style=label.style_label_up, size=f_lbl_size(lux_lbl_size))
            ln = line.new(pl_bar, lux_pl, pl_bar+1, lux_pl, color=lux_col_sl, style=f_ls(lux_line_style), width=lux_sl_lw, extend=lux_extend_lines ? extend.right : extend.none)
            array.push(lux_sl_lines, ln)
            if array.size(lux_sl_lines) > lux_max_lines
                line.delete(array.shift(lux_sl_lines))
            lux_last_sl_val := lux_pl
            lux_last_sl_tag := tag
        lux_prev_pl := lux_pl

    if lux_show_lbl and lux_lbl_mode == "Continuous" and bar_index % lux_lbl_every == 0
        if not na(lux_last_sh_val)
            label.new(bar_index, lux_last_sh_val, lux_last_sh_tag, color=color.new(lux_col_sh,75), textcolor=lux_col_sh, style=label.style_label_center, size=f_lbl_size(lux_lbl_size))
        if not na(lux_last_sl_val)
            label.new(bar_index, lux_last_sl_val, lux_last_sl_tag, color=color.new(lux_col_sl,75), textcolor=lux_col_sl, style=label.style_label_center, size=f_lbl_size(lux_lbl_size))


// ╔══════════════════════════════════════════════════════════════╗
// ║         RAGUL MODULE 4 — 1 HOUR SWING STRUCTURE             ║
// ╚══════════════════════════════════════════════════════════════╝

grp4 = "━━━ RAGUL MODULE 4 · 1 HOUR SWING STRUCTURE ━━━"
h1_on          = input.bool(true, "Enable 1H Swing Structure", group=grp4)
h1_left        = input.int(5, "Bars Left",  minval=1, group=grp4)
h1_right       = input.int(5, "Bars Right", minval=1, group=grp4)
h1_max_past    = input.int(5, "Max Past Levels", minval=1, maxval=20, group=grp4)

grp4a = "1H Current Level Style"
h1_cur_sh_col  = input.color(color.new(#FF9800,0), "Current High Color", group=grp4a)
h1_cur_sl_col  = input.color(color.new(#00BCD4,0), "Current Low Color",  group=grp4a)
h1_cur_st      = input.string("solid", "Current Line Style", options=["solid","dashed","dotted"], group=grp4a)
h1_cur_lw      = input.int(2, "Current Line Width", minval=1, maxval=4, group=grp4a)
h1_show_lbl    = input.bool(true, "Show Labels", group=grp4a)
h1_lbl_mode    = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp4a)
h1_lbl_every   = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp4a)
h1_lbl_size    = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp4a)

grp4b = "1H Past Level Style"
h1_past_sh_col = input.color(color.new(#FF9800,70), "Past High Color", group=grp4b)
h1_past_sl_col = input.color(color.new(#00BCD4,70), "Past Low Color",  group=grp4b)
h1_past_st     = input.string("dashed", "Past Line Style", options=["solid","dashed","dotted"], group=grp4b)
h1_past_lw     = input.int(1, "Past Line Width", minval=1, maxval=4, group=grp4b)

h1_high = request.security(syminfo.tickerid, "60", high, lookahead=barmerge.lookahead_off)
h1_low  = request.security(syminfo.tickerid, "60", low,  lookahead=barmerge.lookahead_off)
h1_ph   = ta.pivothigh(h1_high, h1_left, h1_right)
h1_pl   = ta.pivotlow(h1_low,   h1_left, h1_right)

var float  h1_cur_sh_val  = na
var float  h1_cur_sl_val  = na
var line   h1_cur_sh_line = na
var line   h1_cur_sl_line = na
var label  h1_cur_sh_lbl  = na
var label  h1_cur_sl_lbl  = na
var line[] h1_past_sh_lns = array.new_line()
var line[] h1_past_sl_lns = array.new_line()

if h1_on
    if not na(h1_ph)
        ph_bar = bar_index - h1_right
        if not na(h1_cur_sh_val) and not na(h1_cur_sh_line)
            line.set_color(h1_cur_sh_line,  h1_past_sh_col)
            line.set_style(h1_cur_sh_line,  f_ls(h1_past_st))
            line.set_width(h1_cur_sh_line,  h1_past_lw)
            line.set_extend(h1_cur_sh_line, extend.none)
            array.push(h1_past_sh_lns, h1_cur_sh_line)
            if array.size(h1_past_sh_lns) > h1_max_past
                line.delete(array.shift(h1_past_sh_lns))
        h1_cur_sh_val  := h1_ph
        h1_cur_sh_line := line.new(ph_bar, h1_ph, bar_index, h1_ph, color=h1_cur_sh_col, style=f_ls(h1_cur_st), width=h1_cur_lw, extend=extend.right)
        if h1_show_lbl and h1_lbl_mode == "Single"
            if not na(h1_cur_sh_lbl)
                label.delete(h1_cur_sh_lbl)
            h1_cur_sh_lbl := label.new(ph_bar, h1_ph, "1H High " + str.tostring(h1_ph, format.mintick), color=color.new(h1_cur_sh_col,80), textcolor=h1_cur_sh_col, style=label.style_label_down, size=f_lbl_size(h1_lbl_size))

    if not na(h1_pl)
        pl_bar = bar_index - h1_right
        if not na(h1_cur_sl_val) and not na(h1_cur_sl_line)
            line.set_color(h1_cur_sl_line,  h1_past_sl_col)
            line.set_style(h1_cur_sl_line,  f_ls(h1_past_st))
            line.set_width(h1_cur_sl_line,  h1_past_lw)
            line.set_extend(h1_cur_sl_line, extend.none)
            array.push(h1_past_sl_lns, h1_cur_sl_line)
            if array.size(h1_past_sl_lns) > h1_max_past
                line.delete(array.shift(h1_past_sl_lns))
        h1_cur_sl_val  := h1_pl
        h1_cur_sl_line := line.new(pl_bar, h1_pl, bar_index, h1_pl, color=h1_cur_sl_col, style=f_ls(h1_cur_st), width=h1_cur_lw, extend=extend.right)
        if h1_show_lbl and h1_lbl_mode == "Single"
            if not na(h1_cur_sl_lbl)
                label.delete(h1_cur_sl_lbl)
            h1_cur_sl_lbl := label.new(pl_bar, h1_pl, "1H Low " + str.tostring(h1_pl, format.mintick), color=color.new(h1_cur_sl_col,80), textcolor=h1_cur_sl_col, style=label.style_label_up, size=f_lbl_size(h1_lbl_size))

    if not na(h1_cur_sh_line)
        line.set_x2(h1_cur_sh_line, bar_index)
    if not na(h1_cur_sl_line)
        line.set_x2(h1_cur_sl_line, bar_index)

    if h1_show_lbl and h1_lbl_mode == "Continuous" and bar_index % h1_lbl_every == 0
        if not na(h1_cur_sh_val)
            label.new(bar_index, h1_cur_sh_val, "1H H", color=color.new(h1_cur_sh_col,75), textcolor=h1_cur_sh_col, style=label.style_label_center, size=f_lbl_size(h1_lbl_size))
        if not na(h1_cur_sl_val)
            label.new(bar_index, h1_cur_sl_val, "1H L", color=color.new(h1_cur_sl_col,75), textcolor=h1_cur_sl_col, style=label.style_label_center, size=f_lbl_size(h1_lbl_size))


// ╔══════════════════════════════════════════════════════════════╗
// ║         RAGUL MODULE 5 — 15 MINUTE SWING STRUCTURE          ║
// ╚══════════════════════════════════════════════════════════════╝

grp5 = "━━━ RAGUL MODULE 5 · 15 MINUTE SWING STRUCTURE ━━━"
m15_on          = input.bool(true, "Enable 15M Swing Structure", group=grp5)
m15_left        = input.int(5, "Bars Left",  minval=1, group=grp5)
m15_right       = input.int(5, "Bars Right", minval=1, group=grp5)
m15_max_past    = input.int(5, "Max Past Levels", minval=1, maxval=20, group=grp5)

grp5a = "15M Current Level Style"
m15_cur_sh_col  = input.color(color.new(#CDDC39,0), "Current High Color", group=grp5a)
m15_cur_sl_col  = input.color(color.new(#AB47BC,0), "Current Low Color",  group=grp5a)
m15_cur_st      = input.string("solid", "Current Line Style", options=["solid","dashed","dotted"], group=grp5a)
m15_cur_lw      = input.int(2, "Current Line Width", minval=1, maxval=4, group=grp5a)
m15_show_lbl    = input.bool(true, "Show Labels", group=grp5a)
m15_lbl_mode    = input.string("Single", "Label Mode", options=["Single","Continuous"], group=grp5a)
m15_lbl_every   = input.int(10, "Continuous — Every N Bars", minval=2, maxval=100, group=grp5a)
m15_lbl_size    = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp5a)

grp5b = "15M Past Level Style"
m15_past_sh_col = input.color(color.new(#CDDC39,70), "Past High Color", group=grp5b)
m15_past_sl_col = input.color(color.new(#AB47BC,70), "Past Low Color",  group=grp5b)
m15_past_st     = input.string("dashed", "Past Line Style", options=["solid","dashed","dotted"], group=grp5b)
m15_past_lw     = input.int(1, "Past Line Width", minval=1, maxval=4, group=grp5b)

m15_high = request.security(syminfo.tickerid, "15", high, lookahead=barmerge.lookahead_off)
m15_low  = request.security(syminfo.tickerid, "15", low,  lookahead=barmerge.lookahead_off)
m15_ph   = ta.pivothigh(m15_high, m15_left, m15_right)
m15_pl   = ta.pivotlow(m15_low,   m15_left, m15_right)

var float  m15_cur_sh_val  = na
var float  m15_cur_sl_val  = na
var line   m15_cur_sh_line = na
var line   m15_cur_sl_line = na
var label  m15_cur_sh_lbl  = na
var label  m15_cur_sl_lbl  = na
var line[] m15_past_sh_lns = array.new_line()
var line[] m15_past_sl_lns = array.new_line()

if m15_on
    if not na(m15_ph)
        ph_bar = bar_index - m15_right
        if not na(m15_cur_sh_val) and not na(m15_cur_sh_line)
            line.set_color(m15_cur_sh_line,  m15_past_sh_col)
            line.set_style(m15_cur_sh_line,  f_ls(m15_past_st))
            line.set_width(m15_cur_sh_line,  m15_past_lw)
            line.set_extend(m15_cur_sh_line, extend.none)
            array.push(m15_past_sh_lns, m15_cur_sh_line)
            if array.size(m15_past_sh_lns) > m15_max_past
                line.delete(array.shift(m15_past_sh_lns))
        m15_cur_sh_val  := m15_ph
        m15_cur_sh_line := line.new(ph_bar, m15_ph, bar_index, m15_ph, color=m15_cur_sh_col, style=f_ls(m15_cur_st), width=m15_cur_lw, extend=extend.right)
        if m15_show_lbl and m15_lbl_mode == "Single"
            if not na(m15_cur_sh_lbl)
                label.delete(m15_cur_sh_lbl)
            m15_cur_sh_lbl := label.new(ph_bar, m15_ph, "15M High " + str.tostring(m15_ph, format.mintick), color=color.new(m15_cur_sh_col,80), textcolor=m15_cur_sh_col, style=label.style_label_down, size=f_lbl_size(m15_lbl_size))

    if not na(m15_pl)
        pl_bar = bar_index - m15_right
        if not na(m15_cur_sl_val) and not na(m15_cur_sl_line)
            line.set_color(m15_cur_sl_line,  m15_past_sl_col)
            line.set_style(m15_cur_sl_line,  f_ls(m15_past_st))
            line.set_width(m15_cur_sl_line,  m15_past_lw)
            line.set_extend(m15_cur_sl_line, extend.none)
            array.push(m15_past_sl_lns, m15_cur_sl_line)
            if array.size(m15_past_sl_lns) > m15_max_past
                line.delete(array.shift(m15_past_sl_lns))
        m15_cur_sl_val  := m15_pl
        m15_cur_sl_line := line.new(pl_bar, m15_pl, bar_index, m15_pl, color=m15_cur_sl_col, style=f_ls(m15_cur_st), width=m15_cur_lw, extend=extend.right)
        if m15_show_lbl and m15_lbl_mode == "Single"
            if not na(m15_cur_sl_lbl)
                label.delete(m15_cur_sl_lbl)
            m15_cur_sl_lbl := label.new(pl_bar, m15_pl, "15M Low " + str.tostring(m15_pl, format.mintick), color=color.new(m15_cur_sl_col,80), textcolor=m15_cur_sl_col, style=label.style_label_up, size=f_lbl_size(m15_lbl_size))

    if not na(m15_cur_sh_line)
        line.set_x2(m15_cur_sh_line, bar_index)
    if not na(m15_cur_sl_line)
        line.set_x2(m15_cur_sl_line, bar_index)

    if m15_show_lbl and m15_lbl_mode == "Continuous" and bar_index % m15_lbl_every == 0
        if not na(m15_cur_sh_val)
            label.new(bar_index, m15_cur_sh_val, "15M H", color=color.new(m15_cur_sh_col,75), textcolor=m15_cur_sh_col, style=label.style_label_center, size=f_lbl_size(m15_lbl_size))
        if not na(m15_cur_sl_val)
            label.new(bar_index, m15_cur_sl_val, "15M L", color=color.new(m15_cur_sl_col,75), textcolor=m15_cur_sl_col, style=label.style_label_center, size=f_lbl_size(m15_lbl_size))


// ╔══════════════════════════════════════════════════════════════╗
// ║                    RAGUL STATUS TABLE                        ║
// ╚══════════════════════════════════════════════════════════════╝

grp6       = "━━━ RAGUL STATUS TABLE ━━━"
show_table = input.bool(true, "Show Status Table", group=grp6)
tbl_pos    = input.string("top_right", "Table Position", options=["top_right","top_left","bottom_right","bottom_left"], group=grp6)

if show_table and barstate.islast
    tbl = table.new(f_tbl_pos(tbl_pos), 2, 9,
         bgcolor=color.new(color.black,10),
         border_color=color.new(color.gray,50), border_width=1,
         frame_color=color.new(color.gray,40), frame_width=1)
    table.cell(tbl, 0, 0, "RAGUL Module",                 text_color=color.silver, text_size=size.small, bgcolor=color.new(color.navy,10))
    table.cell(tbl, 1, 0, "Status",                       text_color=color.silver, text_size=size.small, bgcolor=color.new(color.navy,10))
    table.cell(tbl, 0, 1, "M1  · Previous Period Levels", text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 1, pdpwpm_on  ? "ON ✓" : "OFF ✗", text_color=pdpwpm_on  ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 2, "M1B · Today Day H/L",          text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 2, show_today ? "ON ✓" : "OFF ✗",  text_color=show_today ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 3, "M1C · Today 1H H/L",           text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 3, show_td1h  ? "ON ✓" : "OFF ✗",  text_color=show_td1h  ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 4, "M1D · Today 15M H/L",          text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 4, show_td15m ? "ON ✓" : "OFF ✗",  text_color=show_td15m ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 5, "M2  · Chart TF Swing",         text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 5, rv5_on     ? "ON ✓" : "OFF ✗",  text_color=rv5_on     ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 6, "M3  · Swing + Patterns",       text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 6, lux_on     ? "ON ✓" : "OFF ✗",  text_color=lux_on     ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 7, "M4  · 1H Swing Structure",     text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 7, h1_on      ? "ON ✓" : "OFF ✗",  text_color=h1_on      ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 0, 8, "M5  · 15M Swing Structure",    text_color=color.white,  text_size=size.small)
    table.cell(tbl, 1, 8, m15_on     ? "ON ✓" : "OFF ✗",  text_color=m15_on     ? color.green : color.red, text_size=size.small)


// ╔══════════════════════════════════════════════════════════════╗
// ║         RAGUL — LABEL COLLISION RESOLVER                     ║
// ╚══════════════════════════════════════════════════════════════╝

grp_cr       = "━━━ RAGUL LABEL COLLISION RESOLVER ━━━"
cr_on        = input.bool(true,  "Enable Label Collision Resolver", group=grp_cr)
cr_threshold = input.float(0.10, "Collision Zone (% of Range)", minval=0.01, maxval=2.0, step=0.01, group=grp_cr)
cr_offset    = input.float(0.12, "Spread Offset (% of Range)",  minval=0.01, maxval=2.0, step=0.01, group=grp_cr)

var float[]  cr_price = array.new_float()
var string[] cr_txt   = array.new_string()
var color[]  cr_col   = array.new_color()

// Persistent collision labels and lines - deleted and redrawn each last bar
var label[] cr_labels = array.new_label()
var line[]  cr_lines  = array.new_line()

if cr_on and barstate.islast
    array.clear(cr_price)
    array.clear(cr_txt)
    array.clear(cr_col)

    // Delete previous collision labels and lines
    for lb in cr_labels
        label.delete(lb)
    array.clear(cr_labels)
    for ln in cr_lines
        line.delete(ln)
    array.clear(cr_lines)

    float chart_range = chart_high_300 - chart_low_300
    if chart_range <= 0
        chart_range := close * 0.05

    float collision_gap = chart_range * (cr_threshold / 100)
    float spread_step   = chart_range * (cr_offset   / 100)

    if pdpwpm_on
        if show_PDH and not na(d_h)
            array.push(cr_price, d_h)
            array.push(cr_txt, "PDH")
            array.push(cr_col, pdh_col)
        if show_PDL and not na(d_l)
            array.push(cr_price, d_l)
            array.push(cr_txt, "PDL")
            array.push(cr_col, pdl_col)
        if show_PDC and not na(d_c)
            array.push(cr_price, d_c)
            array.push(cr_txt, "PDC")
            array.push(cr_col, pdc_col)
        if show_PDO and not na(d_o)
            array.push(cr_price, d_o)
            array.push(cr_txt, "PDO")
            array.push(cr_col, pdo_col)
        if show_PDEQ and not na(pd_eq)
            array.push(cr_price, pd_eq)
            array.push(cr_txt, "EQ")
            array.push(cr_col, pdeq_col)
        if show_PWH and not na(w_h)
            array.push(cr_price, w_h)
            array.push(cr_txt, "PWH")
            array.push(cr_col, pwh_col)
        if show_PWL and not na(w_l)
            array.push(cr_price, w_l)
            array.push(cr_txt, "PWL")
            array.push(cr_col, pwl_col)
        if show_PWC and not na(w_c)
            array.push(cr_price, w_c)
            array.push(cr_txt, "PWC")
            array.push(cr_col, pwc_col)
        if show_PWO and not na(w_o)
            array.push(cr_price, w_o)
            array.push(cr_txt, "PWO")
            array.push(cr_col, pwo_col)
        if show_PMH and not na(m_h)
            array.push(cr_price, m_h)
            array.push(cr_txt, "PMH")
            array.push(cr_col, pmh_col)
        if show_PML and not na(m_l)
            array.push(cr_price, m_l)
            array.push(cr_txt, "PML")
            array.push(cr_col, pml_col)
        if show_PMC and not na(m_c)
            array.push(cr_price, m_c)
            array.push(cr_txt, "PMC")
            array.push(cr_col, pmc_col)
        if show_PMO and not na(m_o)
            array.push(cr_price, m_o)
            array.push(cr_txt, "PMO")
            array.push(cr_col, pmo_col)

    if show_today
        if show_TDH and not na(today_high)
            array.push(cr_price, today_high)
            array.push(cr_txt, "TDH")
            array.push(cr_col, tdh_col_rt)
        if show_TDL and not na(today_low)
            array.push(cr_price, today_low)
            array.push(cr_txt, "TDL")
            array.push(cr_col, tdl_col_rt)

    if show_td1h
        if show_TD1HH and not na(td1h_high)
            array.push(cr_price, td1h_high)
            array.push(cr_txt, "1H TDH")
            array.push(cr_col, col_TD1HH)
        if show_TD1HL and not na(td1h_low)
            array.push(cr_price, td1h_low)
            array.push(cr_txt, "1H TDL")
            array.push(cr_col, col_TD1HL)

    if show_td15m
        if show_TD15MH and not na(td15m_high)
            array.push(cr_price, td15m_high)
            array.push(cr_txt, "15M TDH")
            array.push(cr_col, col_TD15MH)
        if show_TD15ML and not na(td15m_low)
            array.push(cr_price, td15m_low)
            array.push(cr_txt, "15M TDL")
            array.push(cr_col, col_TD15ML)

    if rv5_on
        if not na(rv5_cur_sh_val)
            array.push(cr_price, rv5_cur_sh_val)
            array.push(cr_txt, "SH")
            array.push(cr_col, rv5_cur_sh_col)
        if not na(rv5_cur_sl_val)
            array.push(cr_price, rv5_cur_sl_val)
            array.push(cr_txt, "SL")
            array.push(cr_col, rv5_cur_sl_col)

    if h1_on
        if not na(h1_cur_sh_val)
            array.push(cr_price, h1_cur_sh_val)
            array.push(cr_txt, "1H High")
            array.push(cr_col, h1_cur_sh_col)
        if not na(h1_cur_sl_val)
            array.push(cr_price, h1_cur_sl_val)
            array.push(cr_txt, "1H Low")
            array.push(cr_col, h1_cur_sl_col)

    if m15_on
        if not na(m15_cur_sh_val)
            array.push(cr_price, m15_cur_sh_val)
            array.push(cr_txt, "15M High")
            array.push(cr_col, m15_cur_sh_col)
        if not na(m15_cur_sl_val)
            array.push(cr_price, m15_cur_sl_val)
            array.push(cr_txt, "15M Low")
            array.push(cr_col, m15_cur_sl_col)

    int cr_n = array.size(cr_price)

    if cr_n > 1
        for i = 0 to cr_n - 2
            for j = 0 to cr_n - 2 - i
                float p_a = array.get(cr_price, j)
                float p_b = array.get(cr_price, j + 1)
                if p_a > p_b
                    array.set(cr_price, j,     p_b)
                    array.set(cr_price, j + 1, p_a)
                    string s_a = array.get(cr_txt, j)
                    string s_b = array.get(cr_txt, j + 1)
                    array.set(cr_txt, j,     s_b)
                    array.set(cr_txt, j + 1, s_a)
                    color c_a = array.get(cr_col, j)
                    color c_b = array.get(cr_col, j + 1)
                    array.set(cr_col, j,     c_b)
                    array.set(cr_col, j + 1, c_a)

    float[] cr_adj = array.new_float(cr_n, 0.0)
    for i = 0 to cr_n - 1
        array.set(cr_adj, i, array.get(cr_price, i))

    if cr_n > 1
        for i = 1 to cr_n - 1
            float prev_y = array.get(cr_adj, i - 1)
            float curr_y = array.get(cr_adj, i)
            if math.abs(curr_y - prev_y) < collision_gap
                array.set(cr_adj, i, prev_y + spread_step)

    if cr_n > 1
        for i = cr_n - 2 to 0
            float curr_y = array.get(cr_adj, i)
            float next_y = array.get(cr_adj, i + 1)
            if math.abs(next_y - curr_y) < collision_gap
                array.set(cr_adj, i, next_y - spread_step)

    int cr_lbl_x = bar_index + 3

    for i = 0 to cr_n - 1
        float  orig_p = array.get(cr_price, i)
        float  adj_p  = array.get(cr_adj,   i)
        string lbl_t  = array.get(cr_txt,   i)
        color  lbl_c  = array.get(cr_col,   i)

        array.push(cr_labels,
             label.new(cr_lbl_x, adj_p,
                  lbl_t + " " + str.tostring(orig_p, format.mintick),
                  color=color.new(lbl_c, 70), textcolor=lbl_c,
                  style=label.style_label_left, size=size.small))

        if math.abs(adj_p - orig_p) > collision_gap * 0.1
            array.push(cr_lines,
                 line.new(cr_lbl_x - 1, orig_p, cr_lbl_x, adj_p,
                      color=color.new(lbl_c, 40), width=1, style=line.style_dotted))
````
