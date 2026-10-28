# Key Levels Dashboard - Simple & Clean

- url: https://www.tradingview.com/script/XX6UNcRY-Key-Levels-Dashboard-Simple-Clean/
- type: indicator
- pine_id: PUB;31c8d91d2b8f4781bef86fdcb279aa31
- version: 1.0

## Description

Previous Day High/Low, Premarket High/Low, ORB High/Low, Previous Day Close

## Source Code

````pine
//@version=5
indicator("Key Levels Dashboard - Simple & Clean", overlay=true, max_lines_count=500)

// ==========================================
// SESSION CONFIGURATION & HELPER FUNCTIONS
// ==========================================
var string TZ = "America/New_York"
rth_session   = input.session("0930-1600", title="RTH Session Times", group="Session Settings")
pm_session    = input.session("0400-0930", title="Premarket Session Times", group="Session Settings")
or_session    = input.session("0930-0945", title="Opening Range Timeframe", group="Session Settings")

get_line_style(style_string) =>
    switch style_string
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// ==========================================
// USER INPUTS & CUSTOMIZATION
// ==========================================
// --- VWAP ---
show_vwap   = input.bool(true, title="Show Native VWAP", group="1) VWAP Settings")
color_vwap  = input.color(color.orange, title="VWAP Color", group="1) VWAP Settings")

// --- Previous Day Benchmarks (Red / Purple) ---
show_pdh    = input.bool(true, title="Show Prev Day High", group="2) Previous Day Benchmarks")
color_pdh   = input.color(color.red, title="Prev Day High Color", group="2) Previous Day Benchmarks")
style_pdh   = input.string("Solid", title="Prev Day High Style", options=["Solid", "Dashed", "Dotted"], group="2) Previous Day Benchmarks")
width_pdh   = input.int(1, title="Prev Day High Width", minval=1, group="2) Previous Day Benchmarks")

show_pdl    = input.bool(true, title="Show Prev Day Low", group="2) Previous Day Benchmarks")
color_pdl   = input.color(color.red, title="Prev Day Low Color", group="2) Previous Day Benchmarks")
style_pdl   = input.string("Solid", title="Prev Day Low Style", options=["Solid", "Dashed", "Dotted"], group="2) Previous Day Benchmarks")
width_pdl   = input.int(1, title="Prev Day Low Width", minval=1, group="2) Previous Day Benchmarks")

show_pdc    = input.bool(true, title="Show Prev Day Close", group="2) Previous Day Benchmarks")
color_pdc   = input.color(color.purple, title="Prev Day Close Color", group="2) Previous Day Benchmarks")
style_pdc   = input.string("Solid", title="Prev Day Close Style", options=["Solid", "Dashed", "Dotted"], group="2) Previous Day Benchmarks")
width_pdc   = input.int(1, title="Prev Day Close Width", minval=1, group="2) Previous Day Benchmarks")

// --- Premarket Extremes (Yellow) ---
show_pmh    = input.bool(true, title="Show Premarket High", group="3) Premarket Extremes")
color_pmh   = input.color(color.yellow, title="Premarket High Color", group="3) Premarket Extremes")
style_pmh   = input.string("Solid", title="Premarket High Style", options=["Solid", "Dashed", "Dotted"], group="3) Premarket Extremes")
width_pmh   = input.int(1, title="Premarket High Width", minval=1, group="3) Premarket Extremes")

show_pml    = input.bool(true, title="Show Premarket Low", group="3) Premarket Extremes")
color_pml   = input.color(color.yellow, title="Premarket Low Color", group="3) Premarket Extremes")
style_pml   = input.string("Solid", title="Premarket Low Style", options=["Solid", "Dashed", "Dotted"], group="3) Premarket Extremes")
width_pml   = input.int(1, title="Premarket Low Width", minval=1, group="3) Premarket Extremes")

// --- 15-Min Opening Range (Green) ---
show_orh    = input.bool(true, title="Show 15-Min OR High", group="4) 15-Min Opening Range")
color_orh   = input.color(color.green, title="OR High Color", group="4) 15-Min Opening Range")
style_orh   = input.string("Solid", title="OR High Line Style", options=["Solid", "Dashed", "Dotted"], group="4) 15-Min Opening Range")
width_orh   = input.int(1, title="OR High Width", minval=1, group="4) 15-Min Opening Range")

show_orl    = input.bool(true, title="Show 15-Min OR Low", group="4) 15-Min Opening Range")
color_orl   = input.color(color.green, title="OR Low Color", group="4) 15-Min Opening Range")
style_orl   = input.string("Solid", title="OR Low Line Style", options=["Solid", "Dashed", "Dotted"], group="4) 15-Min Opening Range")
width_orl   = input.int(1, title="OR Low Width", minval=1, group="4) 15-Min Opening Range")

// ==========================================
// SESSION & TIME LOGIC
// ==========================================
in_rth = not na(time(timeframe.period, rth_session + ":23456", TZ))
in_pm  = not na(time(timeframe.period, pm_session + ":23456", TZ))
in_or  = not na(time(timeframe.period, or_session + ":23456", TZ))

rth_new = in_rth and not in_rth[1]
pm_new  = in_pm and not in_pm[1]
or_new  = in_or and not in_or[1]
or_end  = not in_or and in_or[1]

// ==========================================
// NATIVE VWAP PLOT
// ==========================================
plot(show_vwap ? ta.vwap : na, title="VWAP", color=color_vwap, linewidth=2)

// ==========================================
// LEVEL CALCULATIONS
// ==========================================
// 1) Previous Day RTH Levels via Daily request
[pdh_val, pdl_val, pdc_val] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

// 2) Active Premarket High / Low Tracking
var float pm_h = na
var float pm_l = na

if pm_new
    pm_h := high
    pm_l := low
else if in_pm
    pm_h := math.max(high, pm_h)
    pm_l := math.min(low, pm_l)

// 3) 15-Min Opening Range Tracking
var float or_h = na
var float or_l = na

if or_new
    or_h := high
    or_l := low
else if in_or
    or_h := math.max(high, or_h)
    or_l := math.min(low, or_l)

// Persistent variable fields for daily session locks
var float locked_pm_h = na
var float locked_pm_l = na
var float locked_or_h = na
var float locked_or_l = na

if rth_new
    locked_pm_h := pm_h
    locked_pm_l := pm_l
    locked_or_h := na
    locked_or_l := na

if or_end
    locked_or_h := or_h
    locked_or_l := or_l

// ==========================================
// STATIC RENDER LINE ENGINE
// ==========================================
var line l_pdh = na, var line l_pdl = na, var line l_pdc = na
var line l_pmh = na, var line l_pml = na
var line l_orh = na, var line l_orl = na

// Redraw lines on a new day or session open to avoid screen cluttering
if timeframe.change("D") or rth_new
    line.delete(l_pdh), line.delete(l_pdl), line.delete(l_pdc)
    line.delete(l_pmh), line.delete(l_pml)
    
    // Draw Previous Day High, Low, Close (Red & Purple)
    if show_pdh and not na(pdh_val)
        l_pdh := line.new(x1=bar_index, y1=pdh_val, x2=bar_index+1, y2=pdh_val, extend=extend.right, color=color_pdh, style=get_line_style(style_pdh), width=width_pdh)
    if show_pdl and not na(pdl_val)
        l_pdl := line.new(x1=bar_index, y1=pdl_val, x2=bar_index+1, y2=pdl_val, extend=extend.right, color=color_pdl, style=get_line_style(style_pdl), width=width_pdl)
    if show_pdc and not na(pdc_val)
        l_pdc := line.new(x1=bar_index, y1=pdc_val, x2=bar_index+1, y2=pdc_val, extend=extend.right, color=color_pdc, style=get_line_style(style_pdc), width=width_pdc)

    // Draw Premarket Levels (Yellow)
    float active_pmh = in_pm ? pm_h : locked_pm_h
    float active_pml = in_pm ? pm_l : locked_pm_l
    
    if show_pmh and not na(active_pmh)
        l_pmh := line.new(x1=bar_index, y1=active_pmh, x2=bar_index+1, y2=active_pmh, extend=extend.right, color=color_pmh, style=get_line_style(style_pmh), width=width_pmh)
    if show_pml and not na(active_pml)
        l_pml := line.new(x1=bar_index, y1=active_pml, x2=bar_index+1, y2=active_pml, extend=extend.right, color=color_pml, style=get_line_style(style_pml), width=width_pml)
else
    // Keep extending lines to the edge of the screen as new bars form
    line.set_x2(l_pdh, bar_index), line.set_x2(l_pdl, bar_index), line.set_x2(l_pdc, bar_index)
    
    // Dynamic updates for premarket lines while premarket session is building
    if in_pm
        if show_pmh and not na(l_pmh)
            line.set_y1(l_pmh, pm_h), line.set_y2(l_pmh, pm_h)
        if show_pml and not na(l_pml)
            line.set_y1(l_pml, pm_l), line.set_y2(l_pml, pm_l)
            
    line.set_x2(l_pmh, bar_index), line.set_x2(l_pml, bar_index)

// Draw 15-Minute Opening Range (Green)
if or_end
    line.delete(l_orh), line.delete(l_orl)
    if show_orh and not na(locked_or_h)
        l_orh := line.new(x1=bar_index, y1=locked_or_h, x2=bar_index+1, y2=locked_or_h, extend=extend.right, color=color_orh, style=get_line_style(style_orh), width=width_orh)
    if show_orl and not na(locked_or_l)
        l_orl := line.new(x1=bar_index, y1=locked_or_l, x2=bar_index+1, y2=locked_or_l, extend=extend.right, color=color_orl, style=get_line_style(style_orl), width=width_orl)
else
    line.set_x2(l_orh, bar_index)
    line.set_x2(l_orl, bar_index)
````
