# HTF Mr. Fibonacci Reversal

- url: https://www.tradingview.com/script/Ja4JZAre-HTF-Mr-Fibonacci-Reversal/
- type: indicator
- pine_id: PUB;de121c04b7224c95a433b6fd944c0fb1
- version: 3.0

## Description

The HTF Mr. Fibonacci Reversal is a premium, all-in-one dynamic tool designed to identify major institutional liquidity sweeps, Optimal Trade Entries (OTE), extreme market deviation zones, and internal Market Structure shifts (BOS/CHoCH) simultaneously.

Instead of cluttering your chart with endless Fibonacci ratios and full-screen color zones, this indicator isolates only the levels that matter most to macro reversals. It seamlessly blends Higher Timeframe (HTF) context with internal structural confirmations, operating seamlessly on a Daily (D) HTF anchor by default, but fully customizable to Weekly or Monthly levels depending on your trading style.

🔥 Key Features & Innovations:

1. Dynamic HTF Anchoring & Projections
A primary vertical line automatically captures the exact High and Low range of the previous HTF period. This acts as your baseline liquidity and macro structure. From this anchor, the script projects Fibonacci data into the current live price action.

2. Two Distinct Drawing Models:

Model 2 (Phantom Projection - Default): A unique "clean chart" approach. It projects a phantom HTF candle far to the right of current price action, wrapping the Fibonacci levels and OTE boxes exclusively around this future candle. This allows you to monitor how the micro price action is interacting with macro levels without overlaying shapes over your current candles. The projection is drawn with mathematical pixel-perfect symmetry.
Model 1 (Classic Extension): Draws the Fibonacci levels and OTE boxes starting directly from the vertical anchor, stretching right alongside the price action.
3. Minimalist Fibonacci Architecture
Stripped-down logic to focus heavily on the 0.5 (Equilibrium), -0.618, and 1.618 levels. These specific reaction points are highlighted in solid colors to draw immediate attention for high-probability reversal setups.

4. OTE & Extreme Zones (Transparent Boxes)
Clean, transparent blue boxes elegantly highlight:

Inner Optimal Trade Entry Zones: (0.236 to 0.382) & (0.618 to 0.764)
Extreme Deviation Zones: (-0.382 to -0.618) & (1.382 to 1.618)
5. HTF Phantom Candle
Displays the live, currently developing HTF candle (Open, High, Low, Close) dynamically. If you are on a 15m chart, you can watch exactly what the Daily or Weekly candle looks like in real-time, perfectly centered within your Fibonacci parameters.

6. Integrated Market Structure (BOS / CHoCH)
No need for a secondary structural script. The indicator includes a highly optimized Market Structure engine running in the background.

It maps internal Break of Structure (BOS) and Change of Character (CHoCH) directly on your chart.
By default, unconfirmed "candidate" lines are hidden to keep your chart pristine. Once a level is broken (closing beyond the pivot by default), a solid line and a clear label are drawn retrospectively.
7. Extended Dotted Boundaries & VWAP

The 0.0 and 1.0 levels extend perfectly from the origin anchor all the way to the projected Fib levels, framing the macro range cleanly with labels indicating exact prices.
Includes an optional Anchored VWAP starting exactly from the HTF pivot open.
8. Auto-Adapting UI
The main vertical structure line automatically senses your chart background (light or dark mode) and adapts its color for maximum visibility.

💡 How to Use:
Use the prominent 0.5 equilibrium level to gauge the broader directional bias. When price travels into the outer extreme boxes (below -0.382 or above 1.382), look for exhaustion signals, liquidity sweeps, or a CHoCH confirmation from the internal Market Structure engine for high-probability reversal entries. The inner boxes act as standard retracement targets during trend continuation.

Toggle between Model 1 and Model 2 depending on whether you prefer an immersive overlay or an isolated projection on the right side of your screen.

## Source Code

````pine
//@version=6
indicator("HTF Mr. Fibonacci Reversals", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// --- Inputs ---
grp_settings = "Settings"
model_type = input.string("Model 2", "Drawing Model", options=["Model 1", "Model 2"], group=grp_settings)
is_model_2 = model_type == "Model 2"

in_htf = input.timeframe("D", "Higher Timeframe", group=grp_settings)
in_reverse = input.bool(false, "Reverse Fib Levels", group=grp_settings)
show_extremes = input.bool(true, "Show Standard Extremes", group=grp_settings)
show_outer_extremes = input.bool(false, "Show Outer Extremes (-1.618 & 2.618)", group=grp_settings)

proj_offset = input.int(15, "Projection Offset (Bars)", group=grp_settings, minval=1)

// Model 1 Specific
extend_right = input.int(1, "Extend Right (Bars) [Model 1]", group=grp_settings, minval=0)

// Model 2 Specific
fib_half_width = input.int(4, "Fib Levels Half-Width (Bars) [Model 2]", group=grp_settings, minval=1, tooltip="Half the width of the Fibonacci levels. Default 4 means total 8 bars wide.")

lbl_size_str = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_settings)
lbl_size = switch lbl_size_str
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large

show_inner_boxes = input.bool(true, "Show Inner OTE Boxes (0.236-0.382 & 0.618-0.764)", group=grp_settings)
show_extreme_boxes = input.bool(true, "Show Extreme Boxes (-0.382--0.618 & 1.382-1.618)", group=grp_settings)
box_color = input.color(color.new(#2196f3, 80), "Box Color", group=grp_settings)

show_vwap = input.bool(false, "Show Anchored VWAP", group="VWAP")
vwap_color = input.color(color.new(color.yellow, 0), "VWAP Color", group="VWAP")
vwap_width = input.int(2, "VWAP Line Width", minval=1, maxval=5, group="VWAP")

auto_fg = input.bool(true, "Auto-Adapt Main Line Color", group=grp_settings, tooltip="Uses chart's default foreground color (black on light, white on dark).")

grp_style = "Style"
color_h_05 = input.color(color.new(color.red, 0), "0.5, -0.618, 1.618 Color", group=grp_style)
color_h_extreme = input.color(color.new(#5272be, 0), "Extreme Levels Color", group=grp_style)
color_v_main = input.color(color.new(color.white, 0), "Vertical Range Line (Manual)", group=grp_style)

// Determine the vertical line color based on user preference
line_col = auto_fg ? chart.fg_color : color_v_main

// --- Market Structure (BOS / CHoCH) Inputs ---
grp_ms = "Market Structure (BOS/CHoCH)"
ms_on = input.bool(true, "Enable Market Structure", group=grp_ms)
ms_len = input.int(5, "Fractal Length (odd)", minval=3, maxval=51, group=grp_ms)
ms_reqBody = input.bool(true, "Break = Close Beyond Level", group=grp_ms)
ms_showCand = input.bool(false, "Show Candidate Lines (Pre-break)", group=grp_ms) // Default OFF as requested
ms_candW = input.int(1, "Candidate Width", minval=1, maxval=5, group=grp_ms)
ms_brkW = input.int(1, "Broken Width", minval=1, maxval=5, group=grp_ms)
ms_showLastN = input.int(5, "Show Last N Broken (0=all)", minval=0, maxval=5000, group=grp_ms)
ms_maxKeep = input.int(100, "Max Stored Broken Lines", minval=10, maxval=500, group=grp_ms)

ms_candCol = input.color(color.new(color.gray, 60), "Candidate Color", group=grp_ms)
ms_brkUpCol = input.color(color.rgb(8,153,129), "Broken UP Color (#089981)", group=grp_ms)
ms_brkDnCol = input.color(color.new(color.red, 0), "Broken DN Color", group=grp_ms)
ms_lbBg = input.color(color.new(color.white, 100), "Label Bg (transparent)", group=grp_ms)

// --- Watermark ---
var table watermark = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(watermark, 0, 0, "erdensedat", text_color=color.new(chart.fg_color, 85), text_size=size.huge)

// --- HTF Variables ---
[prevHigh, prevLow] = request.security(syminfo.tickerid, in_htf, [high[1], low[1]], lookahead=barmerge.lookahead_on)

var int htfStart = na
var float curHtfOpen = na
var float curHtfHigh = na
var float curHtfLow  = na

isNewHtf = timeframe.change(in_htf)
if isNewHtf
    htfStart := time
    curHtfOpen := open
    curHtfHigh := high
    curHtfLow  := low
else
    curHtfHigh := math.max(curHtfHigh, high)
    curHtfLow  := math.min(curHtfLow, low)
    
float curHtfClose = close

// VWAP Calculation
var float sumSrcVol = 0.0
var float sumVol = 0.0
if isNewHtf
    sumSrcVol := hlc3 * volume
    sumVol := volume
else if not na(htfStart)
    sumSrcVol += hlc3 * volume
    sumVol += volume

float vwapVal = show_vwap and sumVol > 0 ? sumSrcVol / sumVol : na
plot(vwapVal, "Anchored VWAP", color=vwap_color, linewidth=vwap_width)

// --- Drawing Arrays ---
var line vLine = line.new(na, na, na, na, xloc=xloc.bar_time, color=line_col, style=line.style_solid, width=4)
var line[] hLines = array.new_line()
var label[] hLabels = array.new_label()

// Special 0.0 and 1.0 Dotted Lines
var line line0 = line.new(na, na, na, na, xloc=xloc.bar_time, color=color_h_extreme, style=line.style_dotted, width=1)
var line line1 = line.new(na, na, na, na, xloc=xloc.bar_time, color=color_h_extreme, style=line.style_dotted, width=1)
var label label0 = label.new(na, na, "", xloc=xloc.bar_time, textcolor=color_h_extreme, color=color.new(color.black, 100), style=label.style_label_left, size=lbl_size)
var label label1 = label.new(na, na, "", xloc=xloc.bar_time, textcolor=color_h_extreme, color=color.new(color.black, 100), style=label.style_label_left, size=lbl_size)

var box boxInner1 = box.new(na, na, na, na, xloc=xloc.bar_time, border_color=na, bgcolor=box_color)
var box boxInner2 = box.new(na, na, na, na, xloc=xloc.bar_time, border_color=na, bgcolor=box_color)
var box boxExt1   = box.new(na, na, na, na, xloc=xloc.bar_time, border_color=na, bgcolor=box_color)
var box boxExt2   = box.new(na, na, na, na, xloc=xloc.bar_time, border_color=na, bgcolor=box_color)

// Projection Drawings - Both are now lines ensuring 100% perfect symmetry over the exact same X coordinate
var line projWick = line.new(na, na, na, na, xloc=xloc.bar_time, width=2)
var line projBody = line.new(na, na, na, na, xloc=xloc.bar_time, width=8) 

var float[] active_levels = array.new_float()

// Initialize lines and labels once
if barstate.isfirst
    // Always add 0.5
    array.push(active_levels, 0.5)
    
    // Add extremes if enabled
    if show_extremes
        array.push(active_levels, -1.0)
        array.push(active_levels, -0.618)
        array.push(active_levels, -0.272)
        array.push(active_levels, 1.272)
        array.push(active_levels, 1.618)
        array.push(active_levels, 2.0)
        
    // Add outer extremes
    if show_outer_extremes
        array.push(active_levels, -1.618)
        array.push(active_levels, 2.618)
        
    for i = 0 to array.size(active_levels) - 1
        level = array.get(active_levels, i)
        is_red_level = level == 0.5 or level == -0.618 or level == 1.618
        c = is_red_level ? color_h_05 : color_h_extreme
        w = is_red_level ? 2 : 1 
        
        array.push(hLines, line.new(na, na, na, na, xloc=xloc.bar_time, color=c, style=line.style_solid, width=w))
        array.push(hLabels, label.new(na, na, "", xloc=xloc.bar_time, textcolor=c, color=color.new(color.black, 100), style=label.style_label_left, size=lbl_size))

// --- Update Drawings ---
if barstate.islast and not na(htfStart) and not na(prevHigh)
    float priceRange = prevHigh - prevLow
    int barDuration = time - time[1]
    
    // Center of projection
    int projCenter = time + (barDuration * proj_offset)
    
    // Coordinates based on Model
    int rightTime = time + (barDuration * extend_right)
    int fibLeft = projCenter - (barDuration * fib_half_width)
    int fibRight = projCenter + (barDuration * fib_half_width)
    
    // Update Vertical Line (Previous range anchor)
    line.set_xy1(vLine, htfStart, prevHigh)
    line.set_xy2(vLine, htfStart, prevLow)
    line.set_color(vLine, line_col)
    
    // Update Horizontal Lines & Labels
    for i = 0 to array.size(active_levels) - 1
        level = array.get(active_levels, i)
        
        float y = na
        if in_reverse
            y := prevLow + (priceRange * level)
        else
            y := prevHigh - (priceRange * level)
            
        ln = array.get(hLines, i)
        lbl = array.get(hLabels, i)
        
        if is_model_2
            line.set_xy1(ln, fibLeft, y)
            line.set_xy2(ln, fibRight, y)
            label.set_xy(lbl, fibRight, y)
        else
            line.set_xy1(ln, htfStart, y)
            line.set_xy2(ln, rightTime, y)
            label.set_xy(lbl, rightTime, y)
            
        lbl_text = str.tostring(level) + " (" + str.tostring(y, format.mintick) + ")"
        label.set_text(lbl, lbl_text)
        label.set_size(lbl, lbl_size)
        
    // Update 0.0 and 1.0 Dotted Lines
    float y_0 = in_reverse ? prevLow : prevHigh
    float y_1 = in_reverse ? prevHigh : prevLow

    int end_x_dotted = is_model_2 ? fibRight : rightTime
    int lbl_x_dotted = is_model_2 ? fibRight : rightTime
    
    line.set_xy1(line0, htfStart, y_0)
    line.set_xy2(line0, end_x_dotted, y_0)
    line.set_color(line0, color_h_extreme)
    label.set_xy(label0, lbl_x_dotted, y_0)
    label.set_text(label0, "0.0 (" + str.tostring(y_0, format.mintick) + ")")
    label.set_size(label0, lbl_size)
    label.set_textcolor(label0, color_h_extreme)

    line.set_xy1(line1, htfStart, y_1)
    line.set_xy2(line1, end_x_dotted, y_1)
    line.set_color(line1, color_h_extreme)
    label.set_xy(label1, lbl_x_dotted, y_1)
    label.set_text(label1, "1.0 (" + str.tostring(y_1, format.mintick) + ")")
    label.set_size(label1, lbl_size)
    label.set_textcolor(label1, color_h_extreme)

    // Update Boxes
    float y_in1_t = in_reverse ? prevLow + (priceRange * 0.236) : prevHigh - (priceRange * 0.236)
    float y_in1_b = in_reverse ? prevLow + (priceRange * 0.382) : prevHigh - (priceRange * 0.382)
    float y_in2_t = in_reverse ? prevLow + (priceRange * 0.618) : prevHigh - (priceRange * 0.618)
    float y_in2_b = in_reverse ? prevLow + (priceRange * 0.764) : prevHigh - (priceRange * 0.764)
    
    float y_ex1_t = in_reverse ? prevLow + (priceRange * -0.382) : prevHigh - (priceRange * -0.382)
    float y_ex1_b = in_reverse ? prevLow + (priceRange * -0.618) : prevHigh - (priceRange * -0.618)
    float y_ex2_t = in_reverse ? prevLow + (priceRange * 1.382) : prevHigh - (priceRange * 1.382)
    float y_ex2_b = in_reverse ? prevLow + (priceRange * 1.618) : prevHigh - (priceRange * 1.618)

    if show_inner_boxes
        box.set_lefttop(boxInner1, is_model_2 ? fibLeft : htfStart, y_in1_t)
        box.set_rightbottom(boxInner1, is_model_2 ? fibRight : rightTime, y_in1_b)
        box.set_bgcolor(boxInner1, box_color)
        
        box.set_lefttop(boxInner2, is_model_2 ? fibLeft : htfStart, y_in2_t)
        box.set_rightbottom(boxInner2, is_model_2 ? fibRight : rightTime, y_in2_b)
        box.set_bgcolor(boxInner2, box_color)
    else
        box.set_rightbottom(boxInner1, htfStart, na)
        box.set_rightbottom(boxInner2, htfStart, na)

    if show_extreme_boxes
        box.set_lefttop(boxExt1, is_model_2 ? fibLeft : htfStart, y_ex1_t)
        box.set_rightbottom(boxExt1, is_model_2 ? fibRight : rightTime, y_ex1_b)
        box.set_bgcolor(boxExt1, box_color)
        
        box.set_lefttop(boxExt2, is_model_2 ? fibLeft : htfStart, y_ex2_t)
        box.set_rightbottom(boxExt2, is_model_2 ? fibRight : rightTime, y_ex2_b)
        box.set_bgcolor(boxExt2, box_color)
    else
        box.set_rightbottom(boxExt1, htfStart, na)
        box.set_rightbottom(boxExt2, htfStart, na)
        
    // Update HTF Projection Candle
    if not na(curHtfOpen)
        color candleCol = curHtfClose >= curHtfOpen ? #089981 : #f23645
        
        // Wick
        line.set_xy1(projWick, projCenter, curHtfHigh)
        line.set_xy2(projWick, projCenter, curHtfLow)
        line.set_color(projWick, candleCol)
        
        // Body - Using line instead of box ensures mathematical exactness on X axis
        float top_body = math.max(curHtfOpen, curHtfClose)
        float bot_body = math.min(curHtfOpen, curHtfClose)
        
        // If open == close, ensure the line is visible by offseting slightly or just letting the wick show it
        if top_body == bot_body
            top_body := top_body + syminfo.mintick
            
        line.set_xy1(projBody, projCenter, top_body)
        line.set_xy2(projBody, projCenter, bot_body)
        line.set_color(projBody, candleCol)


// ==================== MARKET STRUCTURE (BOS/CHoCH) LOGIC ====================
var float upLvl = na
var int   upT   = na
var bool  upBroken = false
var line  upLine = na

var float dnLvl = na
var int   dnT   = na
var bool  dnBroken = false
var line  dnLine = na

var int os = 0 
var line[]  brkLines = array.new_line()
var label[] brkLabs  = array.new_label()

if ms_on
    int L = (ms_len % 2 == 0) ? (ms_len + 1) : ms_len
    int p = int(L / 2)
    
    float phVal = ta.pivothigh(high, p, p)
    float plVal = ta.pivotlow(low,  p, p)
    bool phHit = not na(phVal)
    bool plHit = not na(plVal)
    
    int tfSec = timeframe.in_seconds(timeframe.period)
    int extMs = tfSec * 1000 * 10 // Extension base
    
    // Trim arrays
    if ms_showLastN > 0
        while array.size(brkLines) > ms_showLastN
            line oldLn = array.shift(brkLines)
            label oldLb = array.shift(brkLabs)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)

    while array.size(brkLines) > ms_maxKeep
        line oldLn = array.shift(brkLines)
        label oldLb = array.shift(brkLabs)
        if not na(oldLn)
            line.delete(oldLn)
        if not na(oldLb)
            label.delete(oldLb)

    // Pivot High Hit
    if phHit
        if not na(upLine) and not upBroken
            line.delete(upLine)

        upLvl := phVal
        upT   := time[p]
        upBroken := false

        if ms_showCand
            upLine := line.new(upT, upLvl, time + extMs, upLvl, xloc=xloc.bar_time, color=ms_candCol, style=line.style_dotted, width=ms_candW)
        else
            upLine := na

    // Pivot Low Hit
    if plHit
        if not na(dnLine) and not dnBroken
            line.delete(dnLine)

        dnLvl := plVal
        dnT   := time[p]
        dnBroken := false

        if ms_showCand
            dnLine := line.new(dnT, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, color=ms_candCol, style=line.style_dotted, width=ms_candW)
        else
            dnLine := na

    // Extend live candidates
    if ms_showCand
        if not na(upLine) and not upBroken
            line.set_x2(upLine, time + extMs)
        if not na(dnLine) and not dnBroken
            line.set_x2(dnLine, time + extMs)

    // Break conditions
    bool brkUp = false
    bool brkDn = false

    if not na(upLvl) and not upBroken
        brkUp := ms_reqBody ? close > upLvl : high > upLvl

    if not na(dnLvl) and not dnBroken
        brkDn := ms_reqBody ? close < dnLvl : low < dnLvl

    // Apply Breaks
    if brkUp
        upBroken := true
        
        // Ensure broken line is drawn even if candidate was hidden
        if na(upLine)
            upLine := line.new(upT, upLvl, time, upLvl, xloc=xloc.bar_time)
            
        line.set_color(upLine, ms_brkUpCol)
        line.set_style(upLine, line.style_solid)
        line.set_width(upLine, ms_brkW)
        line.set_x2(upLine, time)

        string txt = os == -1 ? "CHoCH" : "BOS"
        label lb = label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=ms_brkUpCol, color=ms_lbBg, size=lbl_size)

        array.push(brkLines, upLine)
        array.push(brkLabs, lb)
        upLine := na
        os := 1

    if brkDn
        dnBroken := true
        
        // Ensure broken line is drawn even if candidate was hidden
        if na(dnLine)
            dnLine := line.new(dnT, dnLvl, time, dnLvl, xloc=xloc.bar_time)
            
        line.set_color(dnLine, ms_brkDnCol)
        line.set_style(dnLine, line.style_solid)
        line.set_width(dnLine, ms_brkW)
        line.set_x2(dnLine, time)

        string txt = os == 1 ? "CHoCH" : "BOS"
        label lb = label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=ms_brkDnCol, color=ms_lbBg, size=lbl_size)

        array.push(brkLines, dnLine)
        array.push(brkLabs, lb)
        dnLine := na
        os := -1
````
