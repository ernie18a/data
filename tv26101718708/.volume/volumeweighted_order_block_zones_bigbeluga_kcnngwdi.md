# Volume-Weighted Order Block Zones [BigBeluga]

- url: https://www.tradingview.com/script/KcnNgwDI-Volume-Weighted-Order-Block-Zones-BigBeluga/
- type: indicator
- pine_id: PUB;891a96497b1f41c2ae6eb73cc0a0e808
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
[quote]The [b]Volume-Weighted Order Block Zones[/b] is an advanced technical indicator created by BigBeluga to identify and map institutional order blocks using pivot points and price displacement. Traditional order block indicators often highlight every single pivot zone, resulting in chart clutter and low-probability setups. In order to provide a solution to this problem, this indicator integrates volume-weighted strength calculations and ATR-based displacement triggers, ensuring that only high-momentum structural zones backed by significant volume are plotted.

The indicator aims to visualize institutional order-building and subsequent market expansions. The core element of its calculation involves tracking volume-weighted metrics against moving averages alongside a dynamic displacement formula defined as:

[i]bearLevel = bearObHigh - atr * displacement[/i]
[i]bullLevel = bullObLow + atr * displacement[/i]

where [i]atr[/i] is the standard Average True Range of period 100, and [i]displacement[/i] is the sensitivity multiplier. Higher values of [i]displacement[/i] and [i]minVolStrength[/i] allow the indicator to filter out weak market noise and focus exclusively on major institutional footprints.[/quote]


[b]🔵 FEATURES[/b]
[quote]
The system utilizes a multi-layered matrix structure to provide actionable market intelligence:

[b]1 — Swing & Volume-Weighted Detection Engine[/b]
[list]
[*] [b]Pivot Identification:[/b] Automatically tracks structural pivot highs and lows using a customizable swing length via [i]pHigh = ta.pivothigh(high, swLen, swLen)[/i] and [i]pLow = ta.pivotlow(low, swLen, swLen)[/i].
[*] [b]Volume Strength Filtering:[/b] Calculates volume intensity percentages via [i]f_getVolumeColor(vol, sma, baseColor)[/i] to filter out blocks falling below the [i]minVolStrength[/i] threshold.
[image]https://www.tradingview.com/x/GEdXQVtt/[/image]
[/list]

[b]2 — Displacement Triggers & Order Block Mapping[/b]
[list]
[*] [b]Dynamic Trigger Lines:[/b] Projects live dashed trigger lines using [i]line.new(bullObBar, bullLevel, bar_index, bullLevel, style=line.style_dashed)[/i] that extend dynamically until price achieves the required ATR displacement threshold.
[image]https://www.tradingview.com/x/v8o3sesj/[/image]
[*] [b]Zone Visualization & Peak Labels:[/b] Plots high-precision order block boxes with volume percentage text alongside structural pivot high ([i]PH[/i]) and pivot low ([i]PL[/i]) labels.
[image]https://www.tradingview.com/x/gFnTEftl/[/image]
[/list]
[b]3 — Active Zone Management & Retest Signals[/b]
[list]
[*] [b]Mitigation & Invalidation:[/b] Continuously monitors active zones inside the loop structure, automatically deleting order blocks when price breaches opposite boundaries or gets fully mitigated.
[*] [b]Retest Signals ([i]B[/i] / [i]S[/i]):[/b] Generates clear [i]B[/i] (Bullish OB bounce) and [i]S[/i] (Bearish OB rejection) signal labels when price retests active institutional zones.
[image]https://www.tradingview.com/x/IkYrXaPG/[/image]
[/list][/quote]


[b]🔵 HOW TO USE[/b]
[quote]
Apart from the basic visualization of institutional market zones, this tool can also act in alternative ways to support decision-making:

[list=1]
[*] [b]Identify High-Volume Order Blocks:[/b] Look for newly formed order block boxes displaying strong volume percentages (e.g., above 20%+) to locate institutional liquidity entry points.
[*] [b]Manage Risk with Retest Labels:[/b] Monitor [i]B[/i] and [i]S[/i] retest signal labels to guide entries and manage stop losses as price interacts with active institutional zones.
[/list]
[/quote]

[b]🔵 NOTES[/b]
[quote]
[b]Why this implementation is unique:[/b]
[list]
[*] It combines volume profile weighting directly with order block detection, filtering out low-volume traps automatically.
[*] The dynamic live trigger line engine adapts seamlessly to real-time price action without cluttering historical chart data.
[*] The script is fully optimized for Pine Script version 6, integrating robust array management var OB[] obBoxes = array.new<OB>() and dynamic box rendering for maximum performance.
[/list][/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Volume-Weighted Order Block Zones [BigBeluga]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, calc_bars_count = 3000)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Order Block Detection Parameters
swLen          = input.int(10, title="Swing Detection Length", group="Order Block Settings", tooltip="Number of bars before and after a pivot high/low required to confirm a swing structure.")
maxOB          = input.int(10, title="Max Active Order Blocks", group="Order Block Settings", tooltip="Maximum number of active order block zones allowed on the chart simultaneously.")
displacement   = input.float(4.0, title="Displacement Multiplier", step=0.1, group="Order Block Settings", tooltip="ATR multiplier added to or subtracted from the pivot to establish the displacement trigger level.")
minVolStrength = input.int(0, title="Min Volume Strength (%)", minval=0, maxval=100, group="Order Block Settings", tooltip="Filters out pivot points and order blocks with volume strength lower than this percentage.")

// Label Size & Typography Settings
lblSize        = input.string("small", title="Label Size", options=["tiny", "small", "normal", "large"], group="Display Settings", tooltip="Controls the font size for PL, PH, B, and S labels.")

// Map label size selection to secondary sizes for retest signals
lblSize1 = switch lblSize
    "tiny"   => "small"
    "small"  => "normal"
    "normal" => "large"
    "large"  => "huge"

// Color Scheme Definitions
c_bullOb   = input.color(#4bffa5, title="Bullish/Bearish OB Colors", group="Color Settings", tooltip="", inline="ob1")
c_bearOb   = input.color(#ff784f, title="", group="Color Settings", tooltip="Base color used for Bullish Order Block background zones.\nBase color used for Bearish Order Block background zones.", inline="ob1")
c_bullLine = input.color(#4bffa5, title="Bullish/Bearish Trigger Line", group="Color Settings", tooltip="", inline="ob2")
c_bearLine = input.color(#ff784f, title="", group="Color Settings", tooltip="Color of the Bullish Displacement Trigger Line.\nColor of the Bearish Displacement Trigger Line.", inline="ob2")
c_plText   = input.color(#4bffa5, title="Pivot Low/High Text Color", group="Color Settings", tooltip="", inline="ob3")
c_phText   = input.color(#ff784f, title="", group="Color Settings", tooltip="Base color of the Pivot Low (PL) label text.\nBase color of the Pivot High (PH) label text.", inline="ob3")

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Custom User Defined Type to store Order Block elements
type OB 
    box body 
    line triggerLEVEL
    bool isBullish

// Dynamic Array storing active Order Block instances
var OB[] obBoxes = array.new<OB>()

// Structure Pivot Detection
pHigh = ta.pivothigh(high, swLen, swLen)
pLow  = ta.pivotlow(low, swLen, swLen)

// Volume and Volatility Metrics
volMA = ta.sma(volume, 20)
atr   = ta.atr(100)

// Maximum high / minimum low lookbacks since pivot to detect retroactive breakouts
highestSincePivot = ta.highest(high, swLen)
lowestSincePivot  = ta.lowest(low, swLen)

// Bullish Order Block Tracking Variables
var float bullObHigh    = na
var float bullObLow     = na
var int   bullObBar     = na
var float bullObVol     = na
var float bullLevel     = na
var bool  bullTriggered = true

// Bearish Order Block Tracking Variables
var float bearObHigh    = na
var float bearObLow     = na
var int   bearObBar     = na
var float bearObVol     = na
var float bearLevel     = na
var bool  bearTriggered = true

// Cooldown tracking for retest signal labels
var lastBullRetest = 0
var lastBearRetest = 0

// Pending Un-triggered Breakout Trigger Lines
var line liveBullLine = na
var line liveBearLine = na

// Custom function calculating volume strength percentage and mapping dynamic alpha transparency
f_getVolumeColor(vol, sma, baseColor) =>
    float volRatio = sma > 0 ? (vol / sma) : 1.0
    int rawAlpha    = int(96 - (volRatio * 12))
    int alpha       = math.min(math.max(rawAlpha, 40), 92)
    int strength    = 100 - alpha
    [color.new(baseColor, alpha), strength]

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// 1. SWING LOW & BULLISH ORDER BLOCK LOGIC
if not na(pLow)
    float tempObVol = volume[swLen]
    [_, plStrength] = f_getVolumeColor(tempObVol, volMA[swLen], c_plText)

    if plStrength >= minVolStrength
        // Store Pivot Low metrics
        bullObHigh    := high[swLen]
        bullObLow     := low[swLen]
        bullObBar     := bar_index[swLen]
        bullObVol     := tempObVol
        bullLevel     := bullObLow + atr * displacement
        
        // Check if price already displaced above trigger level during confirmation lookback
        bool alreadyCrossed = highestSincePivot >= bullLevel
        bullTriggered := alreadyCrossed

        color plTextColor = color.new(c_plText, 80 - plStrength)

        // Clear previous live pending trigger line
        line.delete(liveBullLine)
        
        if not bullTriggered
            // Draw active dashed trigger line awaiting displacement
            liveBullLine := line.new(bullObBar, bullLevel, bar_index, bullLevel, style=line.style_dashed, color=c_bullLine)
        else
            // Retroactive OB creation if breakout occurred prior to pivot confirmation
            liveBullLine := na
            
            // Find exact historical bar offset where displacement trigger was crossed
            int crossOffset = 0
            for offset = swLen - 1 to 0
                if close[offset] >= bullLevel or high[offset] >= bullLevel
                    crossOffset := offset
                    break
            
            int crossBar = bar_index - crossOffset
            
            // Ensure zone was not invalidated/mitigated before confirmation
            bool isMitigated = false
            for offset = crossOffset to 0
                if low[offset] < bullObLow
                    isMitigated := true
                    break
            
            if not isMitigated
                [bullColor, bullStrength] = f_getVolumeColor(bullObVol, volMA[swLen], c_bullOb)
                
                // Remove overlapping active bullish OBs
                if array.size(obBoxes) > 0
                    for i = array.size(obBoxes) - 1 to 0 
                        OB currentOB = array.get(obBoxes, i)
                        if currentOB.isBullish
                            float oldHigh = box.get_top(currentOB.body)
                            float oldLow  = box.get_bottom(currentOB.body)
                            if bullObHigh >= oldLow and bullObLow <= oldHigh
                                box.delete(currentOB.body)
                                line.delete(currentOB.triggerLEVEL)
                                array.remove(obBoxes, i)
                
                // Plot displacement trigger line and OB zone box
                l = line.new(bullObBar, bullLevel, crossBar, bullLevel, style=line.style_solid, color=c_bullLine)
                b = box.new(bullObBar, bullObHigh, bar_index, bullObLow, bgcolor=bullColor, border_color=color.new(c_bullOb, 100), text=str.tostring(bullStrength) + "%", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
                
                // Store new OB and enforce maximum allowed count
                obBoxes.push(OB.new(b, l, true))
                if array.size(obBoxes) > maxOB
                    oldOB = array.shift(obBoxes)
                    box.delete(oldOB.body)
                    line.delete(oldOB.triggerLEVEL)

        // Plot Pivot Low label with volume-weighted text intensity
        label.new(bar_index[swLen], pLow, "PL", color=color.new(color.black, 100), textcolor=plTextColor, style=label.style_label_up, size=lblSize, tooltip="Pivot Low: " + str.tostring(pLow, format.mintick) + "\nVolume Strength: " + str.tostring(plStrength) + "%")


// 2. SWING HIGH & BEARISH ORDER BLOCK LOGIC
if not na(pHigh)
    float tempObVol = volume[swLen]
    [_, phStrength] = f_getVolumeColor(tempObVol, volMA[swLen], c_phText)

    if phStrength >= minVolStrength
        // Store Pivot High metrics
        bearObHigh    := high[swLen]
        bearObLow     := low[swLen]
        bearObBar     := bar_index[swLen]
        bearObVol     := tempObVol
        bearLevel     := bearObHigh - atr * displacement
        
        // Check if price already displaced below trigger level during confirmation lookback
        bool alreadyCrossed = lowestSincePivot <= bearLevel
        bearTriggered := alreadyCrossed

        color phTextColor = color.new(c_phText, 80 - phStrength)

        // Clear previous live pending trigger line
        line.delete(liveBearLine)

        if not bearTriggered
            // Draw active dashed trigger line awaiting displacement
            liveBearLine := line.new(bearObBar, bearLevel, bar_index, bearLevel, style=line.style_dashed, color=c_bearLine)
        else
            // Retroactive OB creation if breakout occurred prior to pivot confirmation
            liveBearLine := na

            // Find exact historical bar offset where displacement trigger was crossed
            int crossOffset = 0
            for offset = swLen - 1 to 0
                if close[offset] <= bearLevel or low[offset] <= bearLevel
                    crossOffset := offset
                    break

            int crossBar = bar_index - crossOffset

            // Ensure zone was not invalidated/mitigated before confirmation
            bool isMitigated = false
            for offset = crossOffset to 0
                if high[offset] > bearObHigh
                    isMitigated := true
                    break

            if not isMitigated
                [bearColor, bearStrength] = f_getVolumeColor(bearObVol, volMA[swLen], c_bearOb)

                // Remove overlapping active bearish OBs
                if array.size(obBoxes) > 0
                    for i = array.size(obBoxes) - 1 to 0 
                        OB currentOB = array.get(obBoxes, i)
                        if not currentOB.isBullish
                            float oldHigh = box.get_top(currentOB.body)
                            float oldLow  = box.get_bottom(currentOB.body)
                            if bearObHigh >= oldLow and bearObLow <= oldHigh
                                box.delete(currentOB.body)
                                line.delete(currentOB.triggerLEVEL)
                                array.remove(obBoxes, i)

                // Plot displacement trigger line and OB zone box
                l = line.new(bearObBar, bearLevel, crossBar, bearLevel, style=line.style_solid, color=c_bearLine)
                b = box.new(bearObBar, bearObHigh, bar_index, bearObLow, bgcolor=bearColor, border_color=color.new(c_bearOb, 100), text=str.tostring(bearStrength) + "%", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)

                // Store new OB and enforce maximum allowed count
                obBoxes.push(OB.new(b, l, false))
                if array.size(obBoxes) > maxOB
                    oldOB = array.shift(obBoxes)
                    box.delete(oldOB.body)
                    line.delete(oldOB.triggerLEVEL)

        // Plot Pivot High label with volume-weighted text intensity
        label.new(bar_index[swLen], pHigh, "PH", color=color.new(color.black, 100), textcolor=phTextColor, style=label.style_label_down, size=lblSize, tooltip="Pivot High: " + str.tostring(pHigh, format.mintick) + "\nVolume Strength: " + str.tostring(phStrength) + "%")


// 3. DYNAMICALLY EXTEND PENDING TRIGGER LINES
if not bullTriggered and not na(liveBullLine)
    line.set_x2(liveBullLine, bar_index)

if not bearTriggered and not na(liveBearLine)
    line.set_x2(liveBearLine, bar_index)


// 4. ACTIVE ZONE MANAGEMENT, MITIGATION & RETEST SIGNALS
if array.size(obBoxes) > 0
    for i = array.size(obBoxes) - 1 to 0 
        OB currentOB = array.get(obBoxes, i)
        
        // Dynamically extend active OB box right boundary to current bar
        box.set_right(currentOB.body, bar_index)
        
        float obTop    = box.get_top(currentOB.body)
        float obBottom = box.get_bottom(currentOB.body)
        
        // Invalidation check (Price breaches opposite side of the Order Block)
        bool isInvalidated = false
        if currentOB.isBullish and low < obBottom
            isInvalidated := true
        else if not currentOB.isBullish and high > obTop
            isInvalidated := true

        // Delete invalidated zones
        if isInvalidated
            box.delete(currentOB.body)
            line.delete(currentOB.triggerLEVEL)
            array.remove(obBoxes, i)
        else
            // Check for Bullish OB retest/bounce
            if currentOB.isBullish
                bool bullCrossUp = (low[1] <= obTop and low > obTop) or (close[1] <= obTop and close > obTop)
                if bullCrossUp and barstate.isconfirmed and bar_index - lastBullRetest > 5
                    label.new(bar_index, low, "B", color=color.new(c_bullLine, 80), textcolor=chart.fg_color, style=label.style_label_up, size=lblSize1, tooltip="Bullish OB Retest")
                    lastBullRetest := bar_index
            else
                // Check for Bearish OB retest/rejection
                bool bearCrossDown = (high[1] >= obBottom and high < obBottom) or (close[1] >= obBottom and close < obBottom)
                if bearCrossDown and barstate.isconfirmed and bar_index - lastBearRetest > 5
                    label.new(bar_index, high, "S", color=color.new(c_bearLine, 80), textcolor=chart.fg_color, style=label.style_label_down, size=lblSize1, tooltip="Bearish OB Retest")
                    lastBearRetest := bar_index


// 5. REAL-TIME BREAKOUT TRIGGER DETECTION
// Real-time Bullish Displacement Breakout Trigger
if ta.crossover(close, bullLevel) and not na(bullObBar) and not bullTriggered and barstate.isconfirmed
    bullTriggered := true
    [bullColor, bullStrength] = f_getVolumeColor(bullObVol, volMA[bar_index - bullObBar], c_bullOb)
    
    line.delete(liveBullLine)
    liveBullLine := na

    // Clear overlapping bullish OBs
    if array.size(obBoxes) > 0
        for i = array.size(obBoxes) - 1 to 0 
            OB currentOB = array.get(obBoxes, i)
            if currentOB.isBullish
                float oldHigh = box.get_top(currentOB.body)
                float oldLow  = box.get_bottom(currentOB.body)
                if bullObHigh >= oldLow and bullObLow <= oldHigh
                    box.delete(currentOB.body)
                    line.delete(currentOB.triggerLEVEL)
                    array.remove(obBoxes, i)

    b = box.new(bullObBar, bullObHigh, bar_index, bullObLow, bgcolor=bullColor, border_color=color.new(c_bullOb, 100), text=str.tostring(bullStrength) + "%", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
    l = line.new(bullObBar, bullLevel, bar_index, bullLevel, style=line.style_solid, color=c_bullLine)

    obBoxes.push(OB.new(b, l, true))
    if array.size(obBoxes) > maxOB
        oldOB = array.shift(obBoxes)
        box.delete(oldOB.body)
        line.delete(oldOB.triggerLEVEL)

// Real-time Bearish Displacement Breakout Trigger
if ta.crossunder(close, bearLevel) and not na(bearObBar) and not bearTriggered and barstate.isconfirmed
    bearTriggered := true
    [bearColor, bearStrength] = f_getVolumeColor(bearObVol, volMA[bar_index - bearObBar], c_bearOb)
    
    line.delete(liveBearLine)
    liveBearLine := na

    // Clear overlapping bearish OBs
    if array.size(obBoxes) > 0
        for i = array.size(obBoxes) - 1 to 0 
            OB currentOB = array.get(obBoxes, i)
            if not currentOB.isBullish
                float oldHigh = box.get_top(currentOB.body)
                float oldLow  = box.get_bottom(currentOB.body)
                if bearObHigh >= oldLow and bearObLow <= oldHigh
                    box.delete(currentOB.body)
                    line.delete(currentOB.triggerLEVEL)
                    array.remove(obBoxes, i)

    b = box.new(bearObBar, bearObHigh, bar_index, bearObLow, bgcolor=bearColor, border_color=color.new(c_bearOb, 100), text=str.tostring(bearStrength) + "%", text_color=chart.fg_color, text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)
    l = line.new(bearObBar, bearLevel, bar_index, bearLevel, style=line.style_solid, color=c_bearLine)

    obBoxes.push(OB.new(b, l, false))
    if array.size(obBoxes) > maxOB
        oldOB = array.shift(obBoxes)
        box.delete(oldOB.body)
        line.delete(oldOB.triggerLEVEL)

// }
````
