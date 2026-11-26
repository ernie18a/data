# Gann Levels (Fixed Yesterday Close Anchor) v6

- url: https://www.tradingview.com/script/UUa68ZTx-Gann-Levels-Fixed-Yesterday-Close-Anchor-v6/
- type: indicator
- pine_id: PUB;1a060eb2601d47429ee6dae04efa9adf
- version: 1.0

## Description

1. Mathematical Grounding (Gann Square of 9)
W.D. Gann’s core theory posits that price movement is governed by geometric relationships. The script calculates key support and resistance milestones by transforming the baseline price into degrees of a circle using the algebraic formula:

                                       Gann Lvel = ((sqrt(Base Price) + Angle/180)^2

Base Price: The script extracts the exact finalized daily closing price from the previous session.

Angles Used: It computes full cardinal wheel checkpoints (90°, 180°, 270°, 360°) and sub-cardinal wheel checkpoints (45°, 135°, 225°, 315°).

Supports vs. Resistances: Resistances add the angle value factor to project higher targets, while supports subtract the factor to project lower target limits.

2. Bulletproof Drawing Engine (Zero Vertical Lines)
Traditional plot() routines create ugly, vertical "staircase" connecting lines when a new day opens and the level shifts. This final script completely eliminates that issue by utilizing Pine Script Drawing Lines.
Each day is treated as a completely isolated, independent visual block.At the start of the trading session, the indicator draws independent horizontal lines.
As new bars form throughout the day, the script  smoothly extend only the current day's lines forward to the latest bar index, leaving historical days perfectly flat and disconnected.

3. Clear Visual HierarchyCardinal Angles (90°, 180°, 270°, 360°): 
Rendered as solid lines because they represent heavy pivot zones. Major full-rotation levels (180° and 360°) are drawn slightly thicker.
Sub-Cardinal Angles (45°, 135°, 225°, 315°): Rendered as dashed lines to signify minor, fluid intraday target extensions.
Daily Close Baseline: Rendered as a distinct blue pivot line so you can easily visually track the starting baseline of the current day's ranges.

4. Dynamic Live Price Labels
Instead of forcing you to hover your mouse over the lines to read the values, the script embeds real-time text boxes (label.new) directly onto the rightmost edge of each horizontal ray. The text dynamically displays both the structural angle name and its exact mathematical price value (rounded to two decimal places, e.g., R 90° (152.45)), moving forward step-by-step alongside the active price candle.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © svennela

//@version=6
indicator("Gann Levels (Fixed Yesterday Close Anchor) v6", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
line_width  = input.int(1, "Line Width", minval=1, maxval=5)
show_labels = input.bool(true, "Show Text Labels")

// Colors
color_res   = color.red
color_sup   = color.green
color_pivot = color.blue
color_text  = color.white

// --- Fetch Strict Yesterday's Closing Price ---
// Requesting the current daily close with lookahead_on means we get the value of the active day. 
// By using [1] on the daily resolution level itself, we strictly pull the completed close of yesterday.
daily_close = request.security(syminfo.tickerid, "D", close, lookahead=barmerge.lookahead_on)[1]

// --- Detect New Session Day ---
is_new_day = ta.change(time("D")) != 0

// --- Gann Square of 9 Core Logic ---
get_gann_level(base_price, angle) =>
    math.pow(math.sqrt(base_price) + (angle / 180.0), 2)

// Calculate Levels
r_45  = get_gann_level(daily_close, 45)
r_90  = get_gann_level(daily_close, 90)
r_135 = get_gann_level(daily_close, 135)
r_180 = get_gann_level(daily_close, 180)
r_225 = get_gann_level(daily_close, 225)
r_270 = get_gann_level(daily_close, 270)
r_315 = get_gann_level(daily_close, 315)
r_360 = get_gann_level(daily_close, 360)

s_45  = get_gann_level(daily_close, -45)
s_90  = get_gann_level(daily_close, -90)
s_135 = get_gann_level(daily_close, -135)
s_180 = get_gann_level(daily_close, -180)
s_225 = get_gann_level(daily_close, -225)
s_270 = get_gann_level(daily_close, -270)
s_315 = get_gann_level(daily_close, -315)
s_360 = get_gann_level(daily_close, -360)

// --- Persistent Variables for Lines & Labels ---
var line line_pivot = na
var line line_r45 = na,  var line line_r90 = na,  var line line_r135 = na, var line line_r180 = na
var line line_r225 = na, var line line_r270 = na, var line line_r315 = na, var line line_r360 = na
var line line_s45 = na,  var line line_s90 = na,  var line line_s135 = na, var line line_s180 = na
var line line_s225 = na, var line line_s270 = na, var line line_s315 = na, var line line_s360 = na

var label lbl_pivot = na
var label lbl_r45 = na,  var label lbl_r90 = na,  var label lbl_r135 = na, var label lbl_r180 = na
var label lbl_r225 = na, var label lbl_r270 = na, var label lbl_r315 = na, var label lbl_r360 = na
var label lbl_s45 = na,  var label lbl_s90 = na,  var label lbl_s135 = na, var label lbl_s180 = na
var label lbl_s225 = na, var label lbl_s270 = na, var label lbl_s315 = na, var label lbl_s360 = na

// Helper function to format prices cleanly
format_lbl(title, val) => title + " (" + str.tostring(val, "#.##") + ")"

// Instantiate lines at the beginning of each session boundary
if (is_new_day or na(line_pivot)) and not na(daily_close)
    line_pivot := line.new(x1=bar_index, y1=daily_close, x2=bar_index, y2=daily_close, color=color_pivot, width=line_width + 1, style=line.style_solid)
    
    line_r45  := line.new(x1=bar_index, y1=r_45,  x2=bar_index, y2=r_45,  color=color_res, width=line_width, style=line.style_dashed)
    line_r90  := line.new(x1=bar_index, y1=r_90,  x2=bar_index, y2=r_90,  color=color_res, width=line_width, style=line.style_solid)
    line_r135 := line.new(x1=bar_index, y1=r_135, x2=bar_index, y2=r_135, color=color_res, width=line_width, style=line.style_dashed)
    line_r180 := line.new(x1=bar_index, y1=r_180, x2=bar_index, y2=r_180, color=color_res, width=line_width + 1, style=line.style_solid)
    line_r225 := line.new(x1=bar_index, y1=r_225, x2=bar_index, y2=r_225, color=color_res, width=line_width, style=line.style_dashed)
    line_r270 := line.new(x1=bar_index, y1=r_270, x2=bar_index, y2=r_270, color=color_res, width=line_width, style=line.style_solid)
    line_r315 := line.new(x1=bar_index, y1=r_315, x2=bar_index, y2=r_315, color=color_res, width=line_width, style=line.style_dashed)
    line_r360 := line.new(x1=bar_index, y1=r_360, x2=bar_index, y2=r_360, color=color_res, width=line_width + 1, style=line.style_solid)
    
    line_s45  := line.new(x1=bar_index, y1=s_45,  x2=bar_index, y2=s_45,  color=color_sup, width=line_width, style=line.style_dashed)
    line_s90  := line.new(x1=bar_index, y1=s_90,  x2=bar_index, y2=s_90,  color=color_sup, width=line_width, style=line.style_solid)
    line_s135 := line.new(x1=bar_index, y1=s_135, x2=bar_index, y2=s_135, color=color_sup, width=line_width, style=line.style_dashed)
    line_s180 := line.new(x1=bar_index, y1=s_180, x2=bar_index, y2=s_180, color=color_sup, width=line_width + 1, style=line.style_solid)
    line_s225 := line.new(x1=bar_index, y1=s_225, x2=bar_index, y2=s_225, color=color_sup, width=line_width, style=line.style_dashed)
    line_s270 := line.new(x1=bar_index, y1=s_270, x2=bar_index, y2=s_270, color=color_sup, width=line_width, style=line.style_solid)
    line_s315 := line.new(x1=bar_index, y1=s_315, x2=bar_index, y2=s_315, color=color_sup, width=line_width, style=line.style_dashed)
    line_s360 := line.new(x1=bar_index, y1=s_360, x2=bar_index, y2=s_360, color=color_sup, width=line_width + 1, style=line.style_solid)

    if show_labels
        lbl_pivot := label.new(x=bar_index, y=daily_close, text=format_lbl("Yesterday Close", daily_close), color=color_pivot, textcolor=color_text, style=label.style_label_left, size=size.small)
        
        lbl_r45   := label.new(x=bar_index, y=r_45,  text=format_lbl("R 45°", r_45),   color=color_res, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_r90   := label.new(x=bar_index, y=r_90,  text=format_lbl("R 90°", r_90),   color=color_res, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_r135  := label.new(x=bar_index, y=r_135, text=format_lbl("R 135°", r_135), color=color_res, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_r180  := label.new(x=bar_index, y=r_180, text=format_lbl("R 180°", r_180), color=color_res, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_r225  := label.new(x=bar_index, y=r_225, text=format_lbl("R 225°", r_225), color=color_res, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_r270  := label.new(x=bar_index, y=r_270, text=format_lbl("R 270°", r_270), color=color_res, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_r315  := label.new(x=bar_index, y=r_315, text=format_lbl("R 315°", r_315), color=color_res, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_r360  := label.new(x=bar_index, y=r_360, text=format_lbl("R 360°", r_360), color=color_res, textcolor=color_text, style=label.style_label_left, size=size.small)
        
        lbl_s45   := label.new(x=bar_index, y=s_45,  text=format_lbl("S 45°", s_45),   color=color_sup, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_s90   := label.new(x=bar_index, y=s_90,  text=format_lbl("S 90°", s_90),   color=color_sup, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_s135  := label.new(x=bar_index, y=s_135, text=format_lbl("S 135°", s_135), color=color_sup, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_s180  := label.new(x=bar_index, y=s_180, text=format_lbl("S 180°", s_180), color=color_sup, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_s225  := label.new(x=bar_index, y=s_225, text=format_lbl("S 225°", s_225), color=color_sup, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_s270  := label.new(x=bar_index, y=s_270, text=format_lbl("S 270°", s_270), color=color_sup, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_s315  := label.new(x=bar_index, y=s_315, text=format_lbl("S 315°", s_315), color=color_sup, textcolor=color_text, style=label.style_label_left, size=size.small)
        lbl_s360  := label.new(x=bar_index, y=s_360, text=format_lbl("S 360°", s_360), color=color_sup, textcolor=color_text, style=label.style_label_left, size=size.small)

// Lock line extensions to follow the exact live bar index identically across all windows
if not na(line_pivot)
    line.set_x2(line_pivot, bar_index)
    line.set_x2(line_r45,  bar_index), line.set_x2(line_r90,  bar_index), line.set_x2(line_r135, bar_index), line.set_x2(line_r180, bar_index)
    line.set_x2(line_r225, bar_index), line.set_x2(line_r270, bar_index), line.set_x2(line_r315, bar_index), line.set_x2(line_r360, bar_index)
    line.set_x2(line_s45,  bar_index), line.set_x2(line_s90,  bar_index), line.set_x2(line_s135, bar_index), line.set_x2(line_s180, bar_index)
    line.set_x2(line_s225, bar_index), line.set_x2(line_s270, bar_index), line.set_x2(line_s315, bar_index), line.set_x2(line_s360, bar_index)

    if show_labels
        label.set_x(lbl_pivot, bar_index)
        label.set_x(lbl_r45,  bar_index), label.set_x(lbl_r90,  bar_index), label.set_x(lbl_r135, bar_index), label.set_x(lbl_r180, bar_index)
        label.set_x(lbl_r225, bar_index), label.set_x(lbl_r270, bar_index), label.set_x(lbl_r315, bar_index), label.set_x(lbl_r360, bar_index)
        label.set_x(lbl_s45,  bar_index), label.set_x(lbl_s90,  bar_index), label.set_x(lbl_s135, bar_index), label.set_x(lbl_s180, bar_index)
        label.set_x(lbl_s225, bar_index), label.set_x(lbl_s270, bar_index), label.set_x(lbl_s315, bar_index), label.set_x(lbl_s360, bar_index)
````
