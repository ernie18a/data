# Single Target After Pivot by Santiago Rebello

- url: https://www.tradingview.com/script/fQjMmny6-Single-Target-After-Pivot-by-Santiago-Rebello/
- type: indicator
- pine_id: PUB;aedfe77bd7e7467788b618beef0c7061
- version: 1.0

## Description

Zig Zag - Single Target After Pivot is an advanced structural charting tool designed to isolate the most recent confirmed market pivot (High or Low) and project a dynamic, time-based structural target directly into the future. By utilizing the native TradingView ZigZag framework (v7), this indicator eliminates lagging market signals and provides real-time projection horizons for swing traders and trend followers.

Unlike standard ZigZag indicators that only look backward, this script introduces a forward-looking predictive modeling vector that anchors to the last confirmed structural breakout.

How It Works (The Core Logic)
Structural Detection: The script uses an optimized multi-point ZigZag calculation matrix to establish structural validation points based on user-defined percentage deviations and depth settings.

Dynamic Target Extrapolation:

When the last confirmed pivot is a High, the script identifies a potential downside continuation or retracement target. It calculates a Target Low by subtracting the deviation percentage from the pivot price.

When the last confirmed pivot is a Low, the script identifies an upside target. It calculates a Target High by adding the deviation percentage to the pivot price.

Time-Based Projections: Instead of basic horizontal lines, this script uses high-precision millisecond-time mapping (xloc.bar_time) to project a trajectory slope into the future right-hand margin of the chart over a designated timeframe horizon (Target Days).

Key Features
Forward-Looking Target Vector: Dashed target projection lines and labels cleanly map out explicit price objectives and time horizons in the future blank space of your chart.

Anchor Historical Prints: Optional historical label triggers map midpoint bar counters directly over confirmed pivots for rapid backtesting validation.

Real-time Metric HUD Dashboard: An elegant UI table pinned to the top right tracks absolute structural statistics, including total validated pivots, target scan horizons, and current active trend objectives.

Input Configurations
Price Deviation (%): Controls the sensitivity of the pivot detection engine. Higher percentages isolate major macroeconomic wings; lower values target micro-scalping structures.

Pivot Legs (Depth): Sets the minimum bar spacing required between consecutive highs/lows to confirm structural integrity.

Target Days: The exact future bar/time horizon used to project the predictive target vector outward.

## Source Code

````pine
//@version=6
indicator("Zig Zag - Single Target After Pivot", overlay = true, max_lines_count = 500, max_labels_count = 500)

import TradingView/ZigZag/7 as ZigZagLib 

// ==========================================
// 1. CONFIGURATION & INPUTS
// ==========================================
deviationInput  = input.float(5.0, "Price deviation (%)", 0.00001, 100.0, 0.5)
depthInput      = input.int(10, "Pivot legs", 2)
lineColorInput  = input(#2962FF, "Line color")
extendInput     = input(true, "Extend to last bar")
showPriceInput  = input(true, "Show prices")
show_pivot_days = input.bool(true, "Show Days at Pivots")
show_target     = input.bool(true, "Show Single Target")
target_days     = input.int(20, "Target Days", minval=10, maxval=60)

// ==========================================
// 2. INITIALIZATION ENGINE
// ==========================================
var line target_line = na
var label target_label = na
var table info_table = na

// Instantiate structural ZigZag object framework
var zigZag = ZigZagLib.newInstance(
     ZigZagLib.Settings.new(deviationInput, depthInput, lineColorInput, extendInput, showPriceInput, false, true, "Percent", true))

zigZag.update()

// ==========================================
// 3. AUTOMATED STRUCTURAL TARGET PROJECTIONS
// ==========================================
if barstate.islast and array.size(zigZag.pivots) >= 1
    // Retrieve the absolute most recent confirmed pivot point from the library stack
    ZigZagLib.Pivot lastPivot = array.get(zigZag.pivots, 0)
    
    // Extract properties cleanly using the library's native fields
    int   pivotBar    = lastPivot.start.index
    float pivotPrice  = lastPivot.start.price
    bool  isPivotHigh = lastPivot.isHigh

    // Map exact targets based on real structural turning points
    float target_price = na
    color target_color = na
    string target_text = na
    
    if isPivotHigh
        // Last pivot was a HIGH -> Project down to TARGET LOW
        target_price := pivotPrice * (1.0 - (deviationInput / 100.0))
        target_color := color.red
        target_text  := "TARGET LOW\n+" + str.tostring(target_days) + "d"
    else
        // Last pivot was a LOW -> Project up to TARGET HIGH
        target_price := pivotPrice * (1.0 + (deviationInput / 100.0))
        target_color := color.green
        target_text  := "TARGET HIGH\n+" + str.tostring(target_days) + "d"
        
    // --- Anchor Historical Dynamic Print ---
    if show_pivot_days
        label.new(pivotBar, isPivotHigh ? pivotPrice * 1.01 : pivotPrice * 0.99, 
                  text=str.tostring(target_days / 2) + "d", 
                  style=isPivotHigh ? label.style_label_down : label.style_label_up, 
                  color=color.blue, textcolor=color.white, size=size.tiny)

    // --- Single Target Overlay Engine ---
    if show_target
        // Wipe historical target lines on real-time tick cycles
        if not na(target_line)
            line.delete(target_line)
        if not na(target_label)
            label.delete(target_label)
            
        // Calculate the future timestamp based on current chart timeframe adjustments
        int pivotTime  = time[bar_index - pivotBar]
        int futureTime = pivotTime + (target_days * timeframe.multiplier * 60 * 1000 * (timeframe.isdaily ? 1440 : 1))

        // Project straight outward into the future using xloc.bar_time
        target_line := line.new(
             x1=pivotTime, y1=pivotPrice, 
             x2=futureTime, y2=target_price,
             xloc=xloc.bar_time,
             color=target_color, width=3, style=line.style_dashed)
             
        target_label := label.new(
             x=futureTime, y=target_price,
             xloc=xloc.bar_time,
             text=target_text + "\n" + str.tostring(target_price, "#.##"),
             style=isPivotHigh ? label.style_label_up : label.style_label_down,
             color=target_color, textcolor=color.white, size=size.normal)

    // ==========================================
    // 4. METRIC HUD DASHBOARD DISPLAY
    // ==========================================
    if na(info_table)
        info_table := table.new(position.top_right, 2, 4, bgcolor=color.white, border_width=1)
        
    table.cell(info_table, 0, 0, "TARGET ANALYSIS", bgcolor=color.gray, text_color=color.white)
    table.cell(info_table, 1, 0, "VALUES", bgcolor=color.gray, text_color=color.white)
    
    table.cell(info_table, 0, 1, "Total Confirmed Pivots", text_color=color.black)
    table.cell(info_table, 1, 1, str.tostring(array.size(zigZag.pivots)), text_color=color.black)
    
    table.cell(info_table, 0, 2, "Target Scan Horizon", text_color=color.black)
    table.cell(info_table, 1, 2, str.tostring(target_days) + " bars", text_color=color.blue)
    
    table.cell(info_table, 0, 3, isPivotHigh ? "Next Expected Objective" : "Next Expected Objective", text_color=color.purple)
    table.cell(info_table, 1, 3, (isPivotHigh ? "LOW @ " : "HIGH @ ") + str.tostring(target_price, "#.##"), text_color=target_color)
````
