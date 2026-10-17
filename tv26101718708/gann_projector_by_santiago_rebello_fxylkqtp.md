# Gann Projector by Santiago Rebello

- url: https://www.tradingview.com/script/FxYLKqTP-Gann-Projector-by-Santiago-Rebello/
- type: indicator
- pine_id: PUB;47ed009251cd4057ae538d367d6196d1
- version: 1.0

## Description

📊 Concept OverviewThe Automated Rolling Gann Projector is a mathematical time-and-price projection system that automates W.D. Gann’s core principles of geometric cycle tracking.Instead of relying on rigid, manual user configuration inputs that expire as the market advances, this indicator uses an autonomous structural engine to constantly track real-time price action, detect structural swing milestones, and project dynamic cycle turn coordinates infinitely forward into the blank chart space.🛠️ Technical Architecture & Core EngineDynamic Pivot Arrays: The script continually monitors price volatility to isolate the three most recent verified structural pivots (highs/lows) via custom strength inputs. As a new swing forms, the underlying memory array rolls automatically—discarding expired cycles and locking fresh reference points.Automated Price-to-Time Scaled Vectors: The indicator measures the exact elapsed calendar time (in days) between the discovered historical market points and establishes an expansion coefficient ($Ratio = Price_A / Price_B$). This dynamic geometric factor is multiplied by historical swing duration to project upcoming cyclic targets.True Timeline Translation Mapping: A major challenge with mathematical time projections is that while the standard calendar counts weekends, trading charts completely skip them. This script uses an advanced, flattened time-to-bar interpolation matrix to ensure the projected target boxes align accurately across the future timeline, skipping weekend and holiday data gaps cleanly.Persistent Analytical HUD: Features a clean, floating dashboard table positioned dynamically to display active pivot configurations, localized turn dates synchronized with the exchange's timezone (syminfo.timezone), and underlying geometric ratios at a quick glance.💡 How to Use This ToolPivot Left/Right Strength: Customize the structural depth of the tracking engine. Higher values look for long-term macroscopic swing phases, while lower values capture fast, intraday structural microcycles.Visual Convergence Zones: Watch for areas where multiple automated target boxes cluster near the same day coordinates—these overlapping zones highlight strong mathematical time windows.

## Source Code

````pine
//@version=6
indicator("Automated Rolling Gann Projector", shorttitle="Gann Auto", overlay=true, max_lines_count=100, max_boxes_count=100, max_labels_count=100)

// ==========================================
// 1. CONFIGURATION & ENGINE SETTINGS
// ==========================================
tablePos   = input.string("Top Left", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Display")
tableSize  = input.string("Small", "Table Size", options=["Small", "Medium", "Large"], group="Display")

pivotLeft  = input.int(10, "Pivot Left Strength", minval=1, tooltip="Bars required to the left of a pivot", group="Auto Pivot Setup")
pivotRight = input.int(10, "Pivot Right Strength", minval=1, tooltip="Bars required to the right of a pivot (Detection Delay)", group="Auto Pivot Setup")
baseSwingDays = input.int(20, "Default Base Swing Cycle (Days)", minval=1, tooltip="Fallback tracking days multiplier if historical bar distance is unreadable", group="Auto Pivot Setup")

// Visual Styling
color1 = input.color(color.orange, "Projection 1 Color", group="Aesthetics")
color2 = input.color(color.yellow, "Projection 2 Color", group="Aesthetics")
color3 = input.color(color.fuchsia, "Projection 3 Color", group="Aesthetics")

getPos() =>
    switch tablePos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_left

ts = tableSize == "Small" ? size.tiny : tableSize == "Medium" ? size.small : size.normal

// ==========================================
// 2. DETECT HISTORICAL PIVOTS AUTOMATICALLY
// ==========================================
pHi = ta.pivothigh(high, pivotLeft, pivotRight)
pLo = ta.pivotlow(low, pivotLeft, pivotRight)

// Maintain an absolute running array of the last 3 confirmed pivot points
var float[] pivotPrices = array.new_float(0)
var int[]   pivotBars   = array.new_int(0)
var int[]   pivotTimes  = array.new_int(0)
var bool[]  pivotIsHigh = array.new_bool(0)

if not na(pHi)
    array.unshift(pivotPrices, pHi)
    array.unshift(pivotBars, bar_index[pivotRight])
    array.unshift(pivotTimes, time[pivotRight])
    array.unshift(pivotIsHigh, true)
    if array.size(pivotPrices) > 5
        array.pop(pivotPrices), array.pop(pivotBars), array.pop(pivotTimes), array.pop(pivotIsHigh)

if not na(pLo)
    array.unshift(pivotPrices, pLo)
    array.unshift(pivotBars, bar_index[pivotRight])
    array.unshift(pivotTimes, time[pivotRight])
    array.unshift(pivotIsHigh, false)
    if array.size(pivotPrices) > 5
        array.pop(pivotPrices), array.pop(pivotBars), array.pop(pivotTimes), array.pop(pivotIsHigh)

// ==========================================
// 3. ROLLING MATHEMATICAL PROJECTIONS
// ==========================================
if array.size(pivotPrices) >= 3 and barstate.islast

    // Extract the latest 3 sequential structural pivot values
    price1 = array.get(pivotPrices, 0)
    bar1   = array.get(pivotBars, 0)
    time1  = array.get(pivotTimes, 0)
    isHi1  = array.get(pivotIsHigh, 0)

    price2 = array.get(pivotPrices, 1)
    bar2   = array.get(pivotBars, 1)
    time2  = array.get(pivotTimes, 1)
    isHi2  = array.get(pivotIsHigh, 1)

    price3 = array.get(pivotPrices, 2)
    bar3   = array.get(pivotBars, 2)
    time3  = array.get(pivotTimes, 2)
    isHi3  = array.get(pivotIsHigh, 2)

    // Compute original time distances (Swing Days) between historical pivots
    daysBetween1_2 = math.max(1, math.round((time1 - time2) / 86400000))
    daysBetween2_3 = math.max(1, math.round((time2 - time3) / 86400000))

    // --- Vector 1 Calculation (From Pivot 1) ---
    ratio1 = isHi1 ? price1 / price2 : price2 / price1
    projDays1 = ratio1 * daysBetween1_2
    turnDate1 = time1 + math.round(projDays1 * 86400000)

    // --- Vector 2 Calculation (From Pivot 2) ---
    ratio2 = isHi2 ? price2 / price3 : price3 / price2
    projDays2 = ratio2 * daysBetween2_3
    turnDate2 = time2 + math.round(projDays2 * 86400000)

    // --- Vector 3 Calculation (Cross Cycle Macro) ---
    ratio3 = isHi3 ? price3 / price1 : price1 / price3
    projDays3 = ratio3 * baseSwingDays
    turnDate3 = time1 + math.round(projDays3 * 86400000)

    // ==========================================
    // 4. FUTURE BAR INDEX CONVERTER (FLATTENED INLINE)
    // ==========================================
    int msPerBar = int(timeframe.isintraday ? timeframe.multiplier * 60000 : 
                   timeframe.isdaily ? 86400000 : 
                   timeframe.isweekly ? 604800000 : 2592000000)
    
    // Target 1 Translation
    int missingMs1 = turnDate1 - time
    int estBars1 = math.round(missingMs1 / msPerBar)
    if timeframe.isdaily or timeframe.isintraday
        estBars1 := estBars1 + (math.floor(estBars1 / 5) * 2)
    int projBar1 = bar_index + estBars1

    // Target 2 Translation
    int missingMs2 = turnDate2 - time
    int estBars2 = math.round(missingMs2 / msPerBar)
    if timeframe.isdaily or timeframe.isintraday
        estBars2 := estBars2 + (math.floor(estBars2 / 5) * 2)
    int projBar2 = bar_index + estBars2

    // Target 3 Translation
    int missingMs3 = turnDate3 - time
    int estBars3 = math.round(missingMs3 / msPerBar)
    if timeframe.isdaily or timeframe.isintraday
        estBars3 := estBars3 + (math.floor(estBars3 / 5) * 2)
    int projBar3 = bar_index + estBars3

    // ==========================================
    // 5. CLEAN DYNAMIC GRAPHICS GENERATION
    // ==========================================
    var box box1 = na, var box box2 = na, var box box3 = na
    var label lbl1 = na, var label lbl2 = na, var label lbl3 = na

    box.delete(box1), box.delete(box2), box.delete(box3)
    label.delete(lbl1), label.delete(lbl2), label.delete(lbl3)

    // Plot Dynamic Future Target Lines & Labels
    box1 := box.new(projBar1, low * 0.95, projBar1 + 1, high * 1.05, bgcolor=color.new(color1, 85), border_color=color1, border_width=2)
    lbl1 := label.new(projBar1, high * 1.055, "Auto Turn 1\n" + str.format_time(turnDate1, "MMM d", syminfo.timezone), color=color1, textcolor=color.white, style=label.style_label_down, size=size.small)

    box2 := box.new(projBar2, low * 0.955, projBar2 + 1, high * 1.045, bgcolor=color.new(color2, 85), border_color=color2, border_width=2)
    lbl2 := label.new(projBar2, high * 1.047, "Auto Turn 2\n" + str.format_time(turnDate2, "MMM d", syminfo.timezone), color=color2, textcolor=color.black, style=label.style_label_down, size=size.small)

    box3 := box.new(projBar3, low * 0.96, projBar3 + 1, high * 1.04, bgcolor=color.new(color3, 85), border_color=color3, border_width=2)
    lbl3 := label.new(projBar3, high * 1.042, "Auto Turn 3\n" + str.format_time(turnDate3, "MMM d", syminfo.timezone), color=color3, textcolor=color.white, style=label.style_label_down, size=size.small)

    // --- Dynamic Information HUD ---
    var table t = na
    table.delete(t)
    t := table.new(getPos(), 5, 4, bgcolor=color.new(color.white, 85), border_width=1)
    
    // Header Row Styling using valid gray shade hex code (#434651)
    table.cell(t, 0, 0, "ROLLING PIVOT", bgcolor=#434651, text_color=color.white, text_size=ts)
    table.cell(t, 1, 0, "PRICE VALUE", bgcolor=#434651, text_color=color.white, text_size=ts)
    table.cell(t, 2, 0, "HIST SWING DAYS", bgcolor=#434651, text_color=color.white, text_size=ts)
    table.cell(t, 3, 0, "GANN RATIO", bgcolor=#434651, text_color=color.white, text_size=ts)
    table.cell(t, 4, 0, "PROJECTED TURN", bgcolor=#434651, text_color=color.white, text_size=ts)
    
    table.cell(t, 0, 1, "Pivot 1 (Latest)", bgcolor=color.new(color1, 40), text_size=ts)
    table.cell(t, 1, 1, str.tostring(price1, "#.##"), text_size=ts)
    table.cell(t, 2, 1, str.tostring(daysBetween1_2), text_size=ts)
    table.cell(t, 3, 1, str.tostring(ratio1, "#.####"), text_size=ts)
    table.cell(t, 4, 1, str.format_time(turnDate1, "MMM d", syminfo.timezone), bgcolor=color.new(color1, 40), text_size=ts)
    
    table.cell(t, 0, 2, "Pivot 2", bgcolor=color.new(color2, 40), text_size=ts)
    table.cell(t, 1, 2, str.tostring(price2, "#.##"), text_size=ts)
    table.cell(t, 2, 2, str.tostring(daysBetween2_3), text_size=ts)
    table.cell(t, 3, 2, str.tostring(ratio2, "#.####"), text_size=ts)
    table.cell(t, 4, 2, str.format_time(turnDate2, "MMM d", syminfo.timezone), bgcolor=color.new(color2, 40), text_size=ts)
    
    table.cell(t, 0, 3, "Pivot 3", bgcolor=color.new(color3, 40), text_size=ts)
    table.cell(t, 1, 3, str.tostring(price3, "#.##"), text_size=ts)
    table.cell(t, 2, 3, str.tostring(baseSwingDays), text_size=ts)
    table.cell(t, 3, 3, str.tostring(ratio3, "#.####"), text_size=ts)
    table.cell(t, 4, 3, str.format_time(turnDate3, "MMM d", syminfo.timezone), bgcolor=color.new(color3, 40), text_size=ts)
````
