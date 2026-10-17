# Heatseeker Levels

- url: https://www.tradingview.com/script/kvQF4Rq1-Heatseeker-Levels/
- type: indicator
- pine_id: PUB;29776efe25984280a9974c51f3ab2c13
- version: 1.0

## Description

Plot all relevant heatseeker nodes based on desired expiry. 

Choose long or short gamma (yellow or purple), indicate expiry date, and decide whether it's just a node or a key node.

## Source Code

````pine
//@version=5
indicator("Heatseeker Levels", shorttitle="HS Levels", overlay=true, max_lines_count=30, max_labels_count=30)

// ============================================================
// COLOR DEFINITIONS
// ============================================================
c_purple = color.new(#9C27B0, 0)
c_yellow = color.new(#FFEB00, 0)

// ============================================================
// INPUTS — Weekly Ceiling (toggle color)
// ============================================================
g_wc = "Weekly Ceiling"
show_wc      = input.bool(true,  "Show",      group=g_wc, inline="wc1")
price_wc     = input.float(0.0,  "Price",     group=g_wc, inline="wc1")
color_wc     = input.string("Purple", "Color", options=["Purple", "Yellow"], group=g_wc, inline="wc1")
show_date_wc = input.bool(false, "Show Date", group=g_wc, inline="wc2")
date_wc      = input.time(timestamp("2026-01-01"), "Date", group=g_wc, inline="wc2")

// --- King Node (toggle color)
g_kn = "King Node"
show_kn      = input.bool(true,  "Show",      group=g_kn, inline="kn1")
price_kn     = input.float(0.0,  "Price",     group=g_kn, inline="kn1")
color_kn     = input.string("Purple", "Color", options=["Purple", "Yellow"], group=g_kn, inline="kn1")
show_date_kn = input.bool(false, "Show Date", group=g_kn, inline="kn2")
date_kn      = input.time(timestamp("2026-01-01"), "Date", group=g_kn, inline="kn2")

// --- Weekly Floor (toggle color)
g_wf = "Weekly Floor"
show_wf      = input.bool(true,  "Show",      group=g_wf, inline="wf1")
price_wf     = input.float(0.0,  "Price",     group=g_wf, inline="wf1")
color_wf     = input.string("Purple", "Color", options=["Purple", "Yellow"], group=g_wf, inline="wf1")
show_date_wf = input.bool(false, "Show Date", group=g_wf, inline="wf2")
date_wf      = input.time(timestamp("2026-01-01"), "Date", group=g_wf, inline="wf2")

// --- Yellow Node 1
g_y1 = "Yellow Node 1"
show_y1      = input.bool(true,  "Show",      group=g_y1, inline="y1a")
price_y1     = input.float(0.0,  "Price",     group=g_y1, inline="y1a")
show_date_y1 = input.bool(false, "Show Date", group=g_y1, inline="y1b")
date_y1      = input.time(timestamp("2026-01-01"), "Date", group=g_y1, inline="y1b")

// --- Yellow Node 2
g_y2 = "Yellow Node 2"
show_y2      = input.bool(true,  "Show",      group=g_y2, inline="y2a")
price_y2     = input.float(0.0,  "Price",     group=g_y2, inline="y2a")
show_date_y2 = input.bool(false, "Show Date", group=g_y2, inline="y2b")
date_y2      = input.time(timestamp("2026-01-01"), "Date", group=g_y2, inline="y2b")

// --- Yellow Node 3
g_y3 = "Yellow Node 3"
show_y3      = input.bool(true,  "Show",      group=g_y3, inline="y3a")
price_y3     = input.float(0.0,  "Price",     group=g_y3, inline="y3a")
show_date_y3 = input.bool(false, "Show Date", group=g_y3, inline="y3b")
date_y3      = input.time(timestamp("2026-01-01"), "Date", group=g_y3, inline="y3b")

// --- Purple Node 1
g_p1 = "Purple Node 1"
show_p1      = input.bool(true,  "Show",      group=g_p1, inline="p1a")
price_p1     = input.float(0.0,  "Price",     group=g_p1, inline="p1a")
show_date_p1 = input.bool(false, "Show Date", group=g_p1, inline="p1b")
date_p1      = input.time(timestamp("2026-01-01"), "Date", group=g_p1, inline="p1b")

// --- Purple Node 2
g_p2 = "Purple Node 2"
show_p2      = input.bool(true,  "Show",      group=g_p2, inline="p2a")
price_p2     = input.float(0.0,  "Price",     group=g_p2, inline="p2a")
show_date_p2 = input.bool(false, "Show Date", group=g_p2, inline="p2b")
date_p2      = input.time(timestamp("2026-01-01"), "Date", group=g_p2, inline="p2b")

// --- Purple Node 3
g_p3 = "Purple Node 3"
show_p3      = input.bool(true,  "Show",      group=g_p3, inline="p3a")
price_p3     = input.float(0.0,  "Price",     group=g_p3, inline="p3a")
show_date_p3 = input.bool(false, "Show Date", group=g_p3, inline="p3b")
date_p3      = input.time(timestamp("2026-01-01"), "Date", group=g_p3, inline="p3b")

// ============================================================
// LABEL OFFSET — distance in bars from current bar to label
// Increase to push labels further right, decrease to pull in
// ============================================================
lbl_offset = input.int(30, "Label Offset (bars)", minval=1, maxval=100, group="Display")

// ============================================================
// COLOR RESOLUTION FOR TOGGLEABLE LEVELS
// ============================================================
col_wc = color_wc == "Purple" ? c_purple : c_yellow
col_kn = color_kn == "Purple" ? c_purple : c_yellow
col_wf = color_wf == "Purple" ? c_purple : c_yellow

txtcol_wc = color_wc == "Purple" ? color.white : color.black
txtcol_kn = color_kn == "Purple" ? color.white : color.black
txtcol_wf = color_wf == "Purple" ? color.white : color.black

// ============================================================
// DRAW FUNCTION
// ============================================================
f_level(show, price, col, txtcol, txt, show_date, date_val) =>
    var line  ln = na
    var label lb = na
    if barstate.islast
        line.delete(ln)
        label.delete(lb)
        if show and price != 0.0
            date_str = show_date ? "  " + str.format_time(date_val, "MM/dd", syminfo.timezone) : ""
            lbl_text = txt + "  " + str.tostring(price, format.mintick) + date_str
            ln := line.new(x1=bar_index - 500, y1=price, x2=bar_index, y2=price, xloc=xloc.bar_index, extend=extend.right, color=col, width=2, style=line.style_solid)
            lb := label.new(x=bar_index + lbl_offset, y=price, text=lbl_text, xloc=xloc.bar_index, color=col, textcolor=txtcol, style=label.style_label_left, size=size.small)

// ============================================================
// PLOT LEVELS
// ============================================================
f_level(show_wc, price_wc, col_wc, txtcol_wc, "Weekly Ceiling", show_date_wc, date_wc)
f_level(show_kn, price_kn, col_kn, txtcol_kn, "King Node",      show_date_kn, date_kn)
f_level(show_wf, price_wf, col_wf, txtcol_wf, "Weekly Floor",   show_date_wf, date_wf)
f_level(show_y1, price_y1, c_yellow, color.black, "Yellow Node 1", show_date_y1, date_y1)
f_level(show_y2, price_y2, c_yellow, color.black, "Yellow Node 2", show_date_y2, date_y2)
f_level(show_y3, price_y3, c_yellow, color.black, "Yellow Node 3", show_date_y3, date_y3)
f_level(show_p1, price_p1, c_purple, color.white, "Purple Node 1", show_date_p1, date_p1)
f_level(show_p2, price_p2, c_purple, color.white, "Purple Node 2", show_date_p2, date_p2)
f_level(show_p3, price_p3, c_purple, color.white, "Purple Node 3", show_date_p3, date_p3)

// ============================================================
// PRICE SCALE HIGHLIGHTS (colored tag on right-side price axis)
// ============================================================
plot(show_wc and price_wc != 0.0 ? price_wc : na, "WC Scale", color=col_wc,   display=display.price_scale, editable=false)
plot(show_kn and price_kn != 0.0 ? price_kn : na, "KN Scale", color=col_kn,   display=display.price_scale, editable=false)
plot(show_wf and price_wf != 0.0 ? price_wf : na, "WF Scale", color=col_wf,   display=display.price_scale, editable=false)
plot(show_y1 and price_y1 != 0.0 ? price_y1 : na, "Y1 Scale", color=c_yellow, display=display.price_scale, editable=false)
plot(show_y2 and price_y2 != 0.0 ? price_y2 : na, "Y2 Scale", color=c_yellow, display=display.price_scale, editable=false)
plot(show_y3 and price_y3 != 0.0 ? price_y3 : na, "Y3 Scale", color=c_yellow, display=display.price_scale, editable=false)
plot(show_p1 and price_p1 != 0.0 ? price_p1 : na, "P1 Scale", color=c_purple, display=display.price_scale, editable=false)
plot(show_p2 and price_p2 != 0.0 ? price_p2 : na, "P2 Scale", color=c_purple, display=display.price_scale, editable=false)
plot(show_p3 and price_p3 != 0.0 ? price_p3 : na, "P3 Scale", color=c_purple, display=display.price_scale, editable=false)

// ============================================================
// ALERTS — one selectable condition per level
// ============================================================
alertcondition(show_wc and price_wc != 0.0 and ta.cross(close, price_wc), title="Weekly Ceiling Cross",  message="Heatseeker: Weekly Ceiling crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
alertcondition(show_kn and price_kn != 0.0 and ta.cross(close, price_kn), title="King Node Cross",       message="Heatseeker: King Node crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
alertcondition(show_wf and price_wf != 0.0 and ta.cross(close, price_wf), title="Weekly Floor Cross",    message="Heatseeker: Weekly Floor crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
alertcondition(show_y1 and price_y1 != 0.0 and ta.cross(close, price_y1), title="Yellow Node 1 Cross",   message="Heatseeker: Yellow Node 1 crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
alertcondition(show_y2 and price_y2 != 0.0 and ta.cross(close, price_y2), title="Yellow Node 2 Cross",   message="Heatseeker: Yellow Node 2 crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
alertcondition(show_y3 and price_y3 != 0.0 and ta.cross(close, price_y3), title="Yellow Node 3 Cross",   message="Heatseeker: Yellow Node 3 crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
alertcondition(show_p1 and price_p1 != 0.0 and ta.cross(close, price_p1), title="Purple Node 1 Cross",   message="Heatseeker: Purple Node 1 crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
alertcondition(show_p2 and price_p2 != 0.0 and ta.cross(close, price_p2), title="Purple Node 2 Cross",   message="Heatseeker: Purple Node 2 crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
alertcondition(show_p3 and price_p3 != 0.0 and ta.cross(close, price_p3), title="Purple Node 3 Cross",   message="Heatseeker: Purple Node 3 crossed on {{ticker}} ({{interval}}) — Close: {{close}}")
````
