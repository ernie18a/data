<!-- tradingview-pine-id: PUB;bbe5dd1ca11f4d5ba16096e98fbe49b7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Zebra Grid & Time Verticals

Source: https://www.tradingview.com/script/Xw0EWmsU-Zebra-Grid-Time-Verticals/

## Description

This indicator provides dynamic price-shelf visual scaffolding and multi-timeframe session timing using non-cluttering overlays.

Dynamic Centered Horizontal Grid: Calculates a dynamic centerPrice rounded to the user-defined point step (e.g., 10 or 100 points) and tracks upper/lower boundary triggers. When price expands outside the current range boundary, the entire grid dynamically shifts to re-center around live price action.

Zebra Interval Shading: Draws alternating background filled boxes (box.new) between even step intervals alongside persistent horizontal price lines (line.new), giving immediate visual definition to price bins across the chart space.

Historical Timeframe Markers: Detects period transitions (ta.change(time(tf_input)) != 0) on a user-designated higher timeframe (e.g., 15m or 6h) and plots full-chart-height vertical lines at each interval open.

Forward (+1) Projection Line: Requests higher timeframe closing timestamps via request.security to project a future vertical line (lineFuture) using xloc.bar_time to show precisely where the next interval will start before it arrives.

Memory Management: Operates exclusively on barstate.islast using arrays (gridBoxes, gridLines) to purge and redraw horizontal elements, keeping line counts clean within standard TradingView script limits (max_lines_count=500).

How to Use It in Trading:

Intraday Execution (Left 1m Chart): Set step sizes to 10 points with 15-minute vertical lines. Use the alternating zebra bands as visual target shelves for scalping micro-swings, and monitor the 15-minute vertical lines to anticipate volatility shifts around candle opens/closes.

Macro Structure (Bottom-Right 30m Chart): Set step sizes to 100 points with 6-hour (360m) vertical lines. The 100-point bands map institutional round-number zones, while the 6-hour vertical intervals visually segregate the trading day into four distinct structural sessions (Asia, London, US Morning, US Afternoon).

Session Timing & Preparation: Use the +1 Future Vertical Line to pre-plan trade execution windows, identifying exactly how much time remains in the current higher-timeframe candle before structural resets occur.

Other Script Features

Independent Modular Toggles: Dedicated user inputs (showZebra, showVerts) allow instantaneous toggling of horizontal price grids and vertical time lines without removing the script.

Custom Styling Options: Complete user control over horizontal step sizes, grid line counts, line styles (Solid, Dashed, Dotted), line widths, and fill color transparency.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KinetiCapital


//@version=6
indicator("Zebra Grid & Time Verticals", overlay=true, max_lines_count=500)

// =============================================================================
// --- TOGGLES & INPUTS ---
// =============================================================================
grp_zebra = "Horizontal Zebra Grid"
showZebra = input.bool(true, "Zebra Grid Intervals", inline = 'zebra', group=grp_zebra)
stepSize  = input.int(10, "", minval=1, inline = 'zebra', group=grp_zebra)
gridCount = input.int(100, "Number of Grids", minval=1, inline = 'zebra2', group=grp_zebra)
gridColor = input.color(color.new(color.gray, 30), "", inline = 'zebra2', group=grp_zebra)
fillColor = input.color(color.rgb(54, 84, 123, 94), "", inline = 'zebra2', group=grp_zebra)

grp_vert   = "Vertical Time Intervals"
showVerts  = input.bool(true, "Verticals", inline = 'VL', group=grp_vert)
showFuture = true//input.bool(true, "Show Upcoming (+1) Future Line?", group=grp_vert)
tf_input   = input.timeframe("15", "", inline = 'VL', group=grp_vert)
line_color = input.color(color.new(color.gray, 50), "", inline = 'VL2', group=grp_vert)
line_style = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], inline = 'VL2', group=grp_vert)
line_width = input.int(2, "Width", minval=1, maxval=4, inline = 'VL2', group=grp_vert)

// Map string selection to Pine Script line styles
get_style(style) =>
    switch style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

// =============================================================================
// --- HORIZONTAL ZEBRA GRID STATE ---
// =============================================================================
var float centerPrice   = math.round(close / stepSize) * stepSize
var float upperBoundary = centerPrice + (gridCount * stepSize / 2)
var float lowerBoundary = centerPrice - (gridCount * stepSize / 2)

var array<box>  gridBoxes = array.new_box()
var array<line> gridLines = array.new_line()

if close >= upperBoundary or close <= lowerBoundary
    centerPrice   := math.round(close / stepSize) * stepSize
    upperBoundary := centerPrice + (gridCount * stepSize / 2)
    lowerBoundary := centerPrice - (gridCount * stepSize / 2)

// =============================================================================
// --- HISTORICAL VERTICAL TIME LINES ---
// =============================================================================
bool is_new_period = ta.change(time(tf_input)) != 0

if showVerts and is_new_period
    line.new(
         x1 = bar_index, 
         y1 = close, 
         x2 = bar_index, 
         y2 = close + 1, 
         xloc = xloc.bar_index, 
         extend = extend.both, 
         color = line_color, 
         style = get_style(line_style), 
         width = line_width
     )

// =============================================================================
// --- UPCOMING (+1) FUTURE VERTICAL TIME LINE ---
// =============================================================================
var line lineFuture = na

if barstate.islast
    line.delete(lineFuture)
    
    if showVerts and showFuture
        // Calculate the next period open timestamp using Higher Timeframe data
        int current_period_start = request.security(syminfo.tickerid, tf_input, time, lookahead=barmerge.lookahead_off)
        int next_period_start    = request.security(syminfo.tickerid, tf_input, time_close, lookahead=barmerge.lookahead_off)

        if not na(next_period_start)
            lineFuture := line.new(
                 x1 = next_period_start, 
                 y1 = close, 
                 x2 = next_period_start, 
                 y2 = close + 1, 
                 xloc = xloc.bar_time, 
                 extend = extend.both, 
                 color = line_color, 
                 style = get_style(line_style), 
                 width = line_width
             )

// =============================================================================
// --- HORIZONTAL ZEBRA GRID DRAWING ---
// =============================================================================
if barstate.islast
    if array.size(gridBoxes) > 0
        for i = 0 to array.size(gridBoxes) - 1
            box.delete(array.get(gridBoxes, i))
        array.clear(gridBoxes)
    
    if array.size(gridLines) > 0
        for i = 0 to array.size(gridLines) - 1
            line.delete(array.get(gridLines, i))
        array.clear(gridLines)

    if showZebra
        halfCount = math.floor(gridCount / 2)
        
        for i = -halfCount to halfCount
            float topPrice = centerPrice + (i * stepSize)
            float botPrice = topPrice - stepSize
            
            array.push(gridLines, line.new(bar_index[500], topPrice, bar_index, topPrice, xloc=xloc.bar_index, extend=extend.both, color=gridColor, width=1))
            
            if math.abs(i) % 2 == 0
                array.push(gridBoxes, box.new(bar_index[1], topPrice, bar_index, botPrice, xloc=xloc.bar_index, extend=extend.both, bgcolor=fillColor, border_color=color.new(color.white, 100)))
````
