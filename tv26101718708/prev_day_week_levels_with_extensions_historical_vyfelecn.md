# Prev Day & Week Levels with Extensions (Historical)

- url: https://www.tradingview.com/script/VYFeLEcN-Prev-Day-Week-Levels-with-Extensions-Historical/
- type: indicator
- pine_id: PUB;5d41cb5e5a5d4cc1861d1b5e24dbaeb8
- version: 1.0

## Description

Overview
This indicator automatically plots key historical levels from the Previous Day and Previous Week, including high, low, and equilibrium (midpoint) levels. It is designed for intraday traders who use daily and weekly price ranges to identify potential support, resistance, and mean-reversion zones.

Key Features
Fibonacci Extensions: Beyond the standard H/L/Mid levels, it automatically calculates and plots extension levels (150%, 200%, -150%, and -200%) based on the prior period's range.

Dynamic Labels: All levels are clearly labeled on the right side of the chart with their specific price values for quick reference.

Historical Tracking: Includes an option to toggle between showing only the current active levels or keeping historical levels on the chart to analyze past reactions.

Clean Visuals: Fully customizable colors and line styles (solid, dashed, or dotted) to match any chart theme.

## Source Code

````pine
//@version=6
indicator("Prev Day & Week Levels with Extensions (Historical)", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// User Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grp1 = "Previous Day Settings"
showDayLevels  = input.bool(true, "Show Day Levels", group=grp1)
dayColor       = input.color(color.new(color.yellow, 0), "Color", group=grp1)
dayLineStyle   = input.string("dotted", "Line Style", options=["solid", "dotted", "dashed"], group=grp1)

grp2 = "Previous Week Settings"
showWeekLevels = input.bool(false, "Show Week Levels", group=grp2)
weekColor      = input.color(color.new(color.aqua, 0), "Color", group=grp2)
weekLineStyle  = input.string("dashed", "Line Style", options=["solid", "dotted", "dashed"], group=grp2)

grp3 = "Historical Settings"
showHistory    = input.bool(true, "Show Historical Levels", group=grp3)

// Helper function to convert string to line style
getLineStyle(styleStr) =>
    switch styleStr
        "solid"  => line.style_solid
        "dotted" => line.style_dotted
        "dashed" => line.style_dashed
        => line.style_solid

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Data Fetching
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[pdH, pdL] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwH, pwL] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Drawing Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
drawLevels(bool show, bool isNewPeriod, float h, float l, color c, string styleStr, string prefix) =>
    // 'var' arrays to track the active set for extension
    var line[] currentLines = array.new<line>()
    var label[] currentLabels = array.new<label>()
    
    mid = (h + l) / 2
    rng = h - l
    exts = array.from(h, l, mid, h + rng*0.5, h + rng, l - rng*0.5, l - rng)
    txts = array.from("H", "L", "Mid", "150%", "200%", "-150%", "-200%")

    if show
        if isNewPeriod
            // If history is disabled, we wipe the previous period's lines before starting new ones
            if not showHistory and array.size(currentLines) > 0
                for i = 0 to array.size(currentLines) - 1
                    line.delete(array.get(currentLines, i))
                    label.delete(array.get(currentLabels, i))
            
            array.clear(currentLines)
            array.clear(currentLabels)

            // Create new drawings for the new period
            for i = 0 to array.size(exts) - 1
                price = array.get(exts, i)
                l_style = getLineStyle(styleStr)
                
                ln = line.new(bar_index, price, bar_index, price, color=c, style=l_style)
                // MODIFIED: Added price formatting to the label text
                lb = label.new(bar_index, price, prefix + " " + array.get(txts, i) + " (" + str.tostring(price, format.mintick) + ")", 
                               style=label.style_label_left, 
                               color=color.new(c, 100), 
                               textcolor=c, 
                               size=size.small)
                
                array.push(currentLines, ln)
                array.push(currentLabels, lb)

        // Stretch the active lines to the current bar
        if array.size(currentLines) > 0
            for i = 0 to array.size(currentLines) - 1
                line.set_x2(array.get(currentLines, i), bar_index)
                label.set_x(array.get(currentLabels, i), bar_index)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Execution
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newDay  = ta.change(time("D")) != 0
newWeek = ta.change(time("W")) != 0

// Execute drawing
drawLevels(showDayLevels, newDay, pdH, pdL, dayColor, dayLineStyle, "PD")
drawLevels(showWeekLevels, newWeek, pwH, pwL, weekColor, weekLineStyle, "PW")
````
