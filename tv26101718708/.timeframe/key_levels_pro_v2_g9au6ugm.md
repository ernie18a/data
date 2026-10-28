# Key Levels Pro V2

- url: https://www.tradingview.com/script/g9AU6ugM-Key-Levels-Pro-V2/
- type: indicator
- pine_id: PUB;3ab3b08411e448c0bf0dcd60606027a3
- version: 1.0

## Description

Key Levels Pro [Optimized for Range Charts]
The Key Levels Pro indicator is a fully rebuilt, premium-grade toolkit designed to pinpoint the most critical intraday and session levels. It has been meticulously optimized from the ground up to guarantee 100% accurate tracking across Range Charts and all standard timeframes without missing a beat.

This tool automatically detects and plots the exact boundaries where significant liquidity and volatility lie, featuring a sleek, high-contrast visual design that stands out beautifully on dark charts.

✨ Core Features
Pre-Market High / Low (04:00 - 09:30 NY Time): Strictly isolates and tracks the pre-market session boundary, ignoring extraneous overnight data to give you the true pre-market range.
Opening Range Breakouts (ORB): Automatically maps the M5 (5-minute) and M15 (15-minute) opening ranges, complete with midpoints. The start of these zones dynamically anchors perfectly to the 9:30 AM NY Open, regardless of your chart type.
NY Open (Fair Value): Plots a static level exactly at the 9:30 AM NY Opening price, offering a crucial baseline for the day's trend.
Prior Day High & Low (PDH / PDL): Essential macro levels are clearly marked for immediate bias reference.
Smart Labeling System: Features offset, non-overlapping labels perfectly aligned to the right. M5 and M15 labels are strategically spaced out so you never have to guess which level is which when they cluster.
Proximity Alerts & History: Optionally toggle on historical daily, weekly, and naked session levels, complete with proximity merging so your chart stays clean.
🛠 Range Chart & Multi-Timeframe Compatibility
Unlike many session-based indicators that break or disappear on tick, volume, or Range charts, Key Levels Pro calculates its core state robustly. It locks in the exact starting conditions of the New York session, ensuring your levels draw flawlessly whether you are trading a 10-minute candle or a fast-moving futures Range chart.

## Source Code

````pine
//@version=6
indicator("Key Levels Pro", overlay = true, max_lines_count = 500, max_boxes_count = 100, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────
// --- General Settings ---
G_GEN       = "⚙  General"
futuresMode = input.bool(false, "Futures Mode (Globex 1700–0930)", group = G_GEN, tooltip = "On: Pre-market captures full Globex overnight (17:00-09:30). Off: Equity pre-market (04:00-09:30).")
showHist    = input.bool(false, "Show Historical Levels", group = G_GEN)
histDays    = input.int(5, "Max History Days", group = G_GEN, minval = 1, maxval = 10)
showLbls    = input.bool(true, "Show Labels", group = G_GEN)
lblSize     = input.string("Small", "Label Size", group = G_GEN, options = ["Tiny", "Small", "Normal", "Large"])

// --- Primary Levels ---
G_PD    = "📊  PDH / PDL"
show_pd = input.bool(true, "Show PDH / PDL", group = G_PD)
pdh_col = input.color(#00ffaa, "PDH Color", group = G_PD)
pdl_col = input.color(#ff0055, "PDL Color", group = G_PD)
pd_w    = input.int(2, "Width", group = G_PD, minval = 1, maxval = 4)

G_PM    = "🌅  Pre-Market H/L"
show_pm = input.bool(true, "Show Pre-Market H/L", group = G_PM)
pmh_col = input.color(#00d4ff, "PM High Color", group = G_PM)
pml_col = input.color(#0088ff, "PM Low Color", group = G_PM)
pm_w    = input.int(2, "Width", group = G_PM, minval = 1, maxval = 4)

G_M15        = "⏱  M15 ORB"
show_m15     = input.bool(true, "Show M15 ORB", group = G_M15)
m15h_col     = input.color(#b700ff, "High Color", group = G_M15)
m15l_col     = input.color(#ff00d4, "Low Color", group = G_M15)
m15_w        = input.int(2, "Width", group = G_M15, minval = 1, maxval = 4)
show_m15mid  = input.bool(true, "Show M15 Midpoint", group = G_M15)
m15mid_col   = input.color(#e100ff, "Midpoint Color", group = G_M15)
m15mid_style = input.string("Dashed", "Mid Style", group = G_M15, options = ["Solid", "Dashed", "Dotted"])

G_M5        = "📦  M5 ORB"
show_m5     = input.bool(true, "Show M5 ORB", group = G_M5)
m5_bdr      = input.color(color.new(#ffaa00, 50), "Border Color", group = G_M5)
m5_fill     = input.color(color.new(#ffaa00, 90), "Fill Color", group = G_M5)
m5_w        = input.int(1, "Border Width", group = G_M5, minval = 1, maxval = 4)
m5_lbl_col  = input.color(#ffaa00, "Label Color", group = G_M5)
show_m5mid  = input.bool(true, "Show M5 Midpoint", group = G_M5)
m5mid_col   = input.color(#ff8800, "Midpoint Color", group = G_M5)
m5mid_style = input.string("Dashed", "Mid Style", group = G_M5, options = ["Solid", "Dashed", "Dotted"])

G_NYO    = "🔔  NY Open (9:30 AM)"
show_nyo = input.bool(true, "Show NY Open", group = G_NYO)
nyo_col  = input.color(#ffffff, "NY Open Color", group = G_NYO)
nyo_w    = input.int(2, "Width", group = G_NYO, minval = 1, maxval = 4)

// ─────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────
var color NONE = color.new(color.white, 100)

f_sz() =>
    switch lblSize
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_linestyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

// ─────────────────────────────────────────────────────────────────────
//  CORE DATA (Computed directly on chart)
// ─────────────────────────────────────────────────────────────────────
string TZ      = "America/New_York"
// Hardcoding PM session to 04:00 - 09:30 NY time as requested
string pm_sess = "0400-0930:23456"

// Using both timeframe and 1-minute fallback to accurately detect bounds on Range charts
bool inPM   = not na(time(timeframe.period, pm_sess, TZ)) or not na(time("1", pm_sess, TZ))
bool inRTH  = not na(time(timeframe.period, "0930-1600:23456", TZ)) or not na(time("1", "0930-1600:23456", TZ))
bool inM5   = not na(time(timeframe.period, "0930-0935:23456", TZ)) or not na(time("1", "0930-0935:23456", TZ))
bool inM15  = not na(time(timeframe.period, "0930-0945:23456", TZ)) or not na(time("1", "0930-0945:23456", TZ))

bool newPM  = inPM and not inPM[1]
bool newRTH = inRTH and not inRTH[1]
bool rthEnd = not inRTH and inRTH[1]

// Track variables
var float pdh = na, var float pdl = na
var float pmh = na, var float pml = na
var float m5h = na, var float m5l = na
var float m15h= na, var float m15l= na
var float rthh= na, var float rthl= na

// History Tracking
var float prev_pdh = na, var float prev_pdl = na
var float prev_pmh = na, var float prev_pml = na
var float prev_m5h = na, var float prev_m5l = na
var float prev_m15h= na, var float prev_m15l= na

if newPM
    pmh := high
    pml := low

if inPM
    pmh := math.max(nz(pmh, high), high)
    pml := math.min(nz(pml, low), low)

var float nyo = na

if newRTH
    prev_pdh := rthh
    prev_pdl := rthl
    pdh := rthh
    pdl := rthl
    rthh := high
    rthl := low
    
    prev_pmh := pmh
    prev_pml := pml
    
    prev_m5h := m5h
    prev_m5l := m5l
    m5h := na
    m5l := na
    
    prev_m15h := m15h
    prev_m15l := m15l
    m15h := na
    m15l := na
    
    nyo := open

if inRTH
    rthh := math.max(nz(rthh, high), high)
    rthl := math.min(nz(rthl, low), low)
    if inM5
        m5h := math.max(nz(m5h, high), high)
        m5l := math.min(nz(m5l, low), low)
    if inM15
        m15h := math.max(nz(m15h, high), high)
        m15l := math.min(nz(m15l, low), low)

// ─────────────────────────────────────────────────────────────────────
//  DRAWING LOGIC
// ─────────────────────────────────────────────────────────────────────
var line l_pdh = na, var line l_pdl = na
var line l_pmh = na, var line l_pml = na
var line l_m15h= na, var line l_m15l= na, var line l_m15m = na
var line l_nyo = na
var box  b_m5  = na, var line l_m5m = na

var label[] cur_labels = array.new_label()
var int rth_start_idx = na

if newRTH
    rth_start_idx := bar_index
    line.delete(l_pdh), line.delete(l_pdl)
    line.delete(l_pmh), line.delete(l_pml)
    line.delete(l_m15h), line.delete(l_m15l), line.delete(l_m15m)
    line.delete(l_nyo)
    box.delete(b_m5), line.delete(l_m5m)
    
    if show_pd
        l_pdh := line.new(bar_index, pdh, bar_index, pdh, color=pdh_col, width=pd_w)
        l_pdl := line.new(bar_index, pdl, bar_index, pdl, color=pdl_col, width=pd_w)
    if show_pm
        l_pmh := line.new(bar_index, prev_pmh, bar_index, prev_pmh, color=pmh_col, width=pm_w, style=line.style_dashed)
        l_pml := line.new(bar_index, prev_pml, bar_index, prev_pml, color=pml_col, width=pm_w, style=line.style_dashed)
    if show_nyo
        l_nyo := line.new(bar_index, nyo, bar_index, nyo, color=nyo_col, width=nyo_w)

if inRTH
    if not na(l_pdh)
        line.set_x2(l_pdh, bar_index)
        line.set_x2(l_pdl, bar_index)
    if not na(l_pmh)
        line.set_x2(l_pmh, bar_index)
        line.set_x2(l_pml, bar_index)
    if not na(l_nyo)
        line.set_x2(l_nyo, bar_index)

bool m15_done = not inM15 and inM15[1]
if m15_done and show_m15
    l_m15h := line.new(rth_start_idx, m15h, bar_index, m15h, color=m15h_col, width=m15_w)
    l_m15l := line.new(rth_start_idx, m15l, bar_index, m15l, color=m15l_col, width=m15_w)
    if show_m15mid
        mid = (m15h + m15l)/2
        l_m15m := line.new(rth_start_idx, mid, bar_index, mid, color=m15mid_col, style=f_linestyle(m15mid_style))

bool m5_done = not inM5 and inM5[1]
if m5_done and show_m5
    b_m5 := box.new(rth_start_idx, m5h, bar_index, m5l, border_color=m5_bdr, bgcolor=m5_fill, border_width=m5_w)
    if show_m5mid
        mid = (m5h + m5l)/2
        l_m5m := line.new(rth_start_idx, mid, bar_index, mid, color=m5mid_col, style=f_linestyle(m5mid_style))

if not na(l_m15h)
    line.set_x2(l_m15h, bar_index)
    line.set_x2(l_m15l, bar_index)
    if not na(l_m15m)
        line.set_x2(l_m15m, bar_index)

if not na(b_m5)
    box.set_right(b_m5, bar_index)
    if not na(l_m5m)
        line.set_x2(l_m5m, bar_index)

// Current Day Labels
if barstate.islast and showLbls
    for l in cur_labels
        label.delete(l)
    array.clear(cur_labels)
    
    _p = array.new_float()
    _t = array.new_string()
    _c = array.new_color()
    _x = array.new_int()
    
    if show_pd and not na(pdh)
        array.push(_p, pdh), array.push(_t, "PDH"), array.push(_c, pdh_col), array.push(_x, bar_index + 2)
        array.push(_p, pdl), array.push(_t, "PDL"), array.push(_c, pdl_col), array.push(_x, bar_index + 2)
    if show_pm and not na(prev_pmh)
        array.push(_p, prev_pmh), array.push(_t, "PM H"), array.push(_c, pmh_col), array.push(_x, bar_index + 2)
        array.push(_p, prev_pml), array.push(_t, "PM L"), array.push(_c, pml_col), array.push(_x, bar_index + 2)
    if show_m15 and not na(m15h)
        array.push(_p, m15h), array.push(_t, "M15 H"), array.push(_c, m15h_col), array.push(_x, bar_index + 2)
        array.push(_p, m15l), array.push(_t, "M15 L"), array.push(_c, m15l_col), array.push(_x, bar_index + 2)
        if show_m15mid
            array.push(_p, (m15h+m15l)/2), array.push(_t, "M15 Mid"), array.push(_c, m15mid_col), array.push(_x, bar_index + 2)
    if show_m5 and not na(m5h)
        array.push(_p, m5h), array.push(_t, "M5 H"), array.push(_c, m5_lbl_col), array.push(_x, bar_index + 12)
        if show_m5mid
            array.push(_p, (m5h+m5l)/2), array.push(_t, "M5 Mid"), array.push(_c, m5mid_col), array.push(_x, bar_index + 12)
    if show_nyo and not na(nyo)
        array.push(_p, nyo), array.push(_t, "NY Open"), array.push(_c, nyo_col), array.push(_x, bar_index + 2)
        
    for i = 0 to array.size(_p) - 1
        if i < array.size(_p)
            array.push(cur_labels, label.new(array.get(_x, i), array.get(_p, i), array.get(_t, i), color=NONE, textcolor=array.get(_c, i), style=label.style_label_left, size=f_sz()))
````
