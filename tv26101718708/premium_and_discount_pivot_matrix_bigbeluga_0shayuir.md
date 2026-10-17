# Premium and Discount Pivot Matrix [BigBeluga]

- url: https://www.tradingview.com/script/0SHayuiR-Premium-and-Discount-Pivot-Matrix-BigBeluga/
- type: indicator
- pine_id: PUB;f4a356b521af435dace79f0b7e68f83c
- version: 1.0

## Description

[b]Premium and Discount Pivot Matrix [BigBeluga][/b] is an advanced market-structure terminal engineered for TradingView. It maps macroeconomic structural equilibrium by tracking historical price extremes and calculating accurate institutional auction zones. 

Instead of printing static linear channels, this framework uses an active multi-pivot state matrix to calculate premium ceiling and discount floor boundaries. It pairs these levels with a real-time [b]100-Bin Volume Profile Matrix[/b] plotted directly at the leading edge of the chart, providing immediate clarity on volume distribution relative to the market's fair-value equilibrium.

 [symbol="NSE:NIFTY"]NSE:NIFTY[/symbol] 
[image]https://www.tradingview.com/x/fTqy5Knr/[/image]

 [symbol="BINANCE:BTCUSDT"]BINANCE:BTCUSDT[/symbol]  
[image]https://www.tradingview.com/x/We9q30Jm/[/image]

[b]🔵 CHANNEL CALCULATION METHODOLOGY[/b]
The central core of the indicator relies on a multi-layered geometric calculation engine to establish its tracking bands. The engine follows a distinct three-step sequence to construct the structural matrix:

[b]1. Multi-Pivot Array Extraction Engine[/b]
[list]
[*] [b]Asymmetric Window Scanning Nodes:[/b] The engine scans the chart for structural price peaks and troughs using an adjustable lookback window ([b]Pivot Left/Right Bars[/b]). For a pivot to be verified, it must be the absolute highest or lowest value within that specified bar radius.
[*] [b]FIFO Array Storage Matrix:[/b] When a high pivot is logged, it is pushed into the [b]highPivots[/b] array; low pivots are funneled into the [b]lowPivots[/b] array. The script features memory guardrails ([b]Max Pivots to Track[/b]) that automatically shift old elements out of memory, limiting array depth to prevent memory allocation drag.
[/list]

[pine]
// Manage Arrays via FIFO (First-In, First-Out) Storage Architecture
if not na(pHi)
    array.push(highPivots, pHi)
    if array.size(highPivots) > arraySize
        array.shift(highPivots)

if not na(pLo)
    array.push(lowPivots, pLo)
    if array.size(lowPivots) > arraySize
        array.shift(lowPivots)
[/pine]

[b]2. Mathematical Boundary Selection[/b]
[list]
[*] [b]Premium Ceiling Isolation Grid:[/b] The terminal continuously runs an evaluation sweep across the active high memory array and extracts the absolute highest peak value using an optimized maximum tracking filter node. This serves as the outer resistance band.
[*] [b]Discount Floor Isolation Grid:[/b] Concurrently, the engine sweeps the active low memory array to extract the absolute lowest trough value, setting the hard outer support band floor.
[*] [b]Step-Line Price Plotting Framework:[/b] Because it selects the maximum high and minimum low of a rolling historical lookback set, the boundaries plot on your canvas as clean, structural step-lines. These lines only shift when a new macro extreme is logged or when an older extreme drops out of the tracking array.
[/list]

[b]3. Dynamic Equilibrium Tracking State Machine[/b]
[list]
[*] [b]Fair Value Midline Matrix:[/b] The Equilibrium Midline represents the exact mathematical center of the active trading channel. It calculates the mid-point price by taking the average of the resistance ceiling and support floor arrays.
[*] [b]Structural Shifting Trend Cloud Filters:[/b] This midline acts as a real-time tracker for the value center of the asset. The internal state machine monitors this line on every tick and applies dynamic visual treatments: it flashes the [b]Midline Rising Color[/b] when the value structure is shifting upward, and instantly mutates to the [b]Midline Falling Color[/b] when structural value drops downward.
[/list]

[pine]
// Extract Channel Levels 
float resistance = na
float support = na

if array.size(highPivots) > 0
    resistance := array.max(highPivots)

if array.size(lowPivots) > 0
    support := array.min(lowPivots)

// Calculate Midline
float midline = not na(resistance) and not na(support) ? (resistance + support) / 2 : na
[/pine]

[b]🔵 CORE STRUCTURAL LAYOUT FEATURES[/b]
[b]1. 100-Bin Volume Profile Distribution Matrix[/b]
[list]
[*] [b]Intra-Channel Grid Binning Engine:[/b] When enabled ([b]Show Volume Profile at Channel End?[/b]), the indicator runs a localized calculation over a specified historical range ([b]Volume Profile Lookback[/b]). It divides the vertical space between the resistance ceiling and support floor into [b]100 equal vertical bins[/b].
[*] [b]Adaptive Transparency Histogram Blocks:[/b] It calculates the exact volume distribution for each candle across these bins, scaling the horizontal width of the resulting histogram bars ([b]Volume Profile Max Width[/b]). Premium distribution bars (above the midline) use an automatic gradient that gets brighter near the resistance ceiling to flag overextended premium supply. Discount distribution bars (below the midline) flash brighter near the support floor to highlight historical institutional accumulation blocks.
[/list]

[b]2. Volumetric Breakdown & Reversal Markers[/b]
[list]
[*] [b]Boundary Breach Telemetry Glyphs:[/b] The terminal closely monitors interactions with the channel boundaries. If a candle breaks completely out of the rolling step-line range, it triggers high-visibility telemetry circle shapes directly on the chart canvas (Bullish Reversal on downward breaks, Bearish Reversal on upward crosses).
[*] [b]Time-Index Signal Buffer Guards:[/b] To prevent messy clutter, the script suppresses repetitive signals using a strict index tracking buffer rule. When a valid breach is confirmed, it stamps the signal with clean text labels tracking the exact transaction volume traded during the breakout bar.
[/list]

[pine]
// 100 Bin Volume Profile Matrix Execution snippet
int binsCount = 100
float channelRange = resistance - support
float binStep = channelRange / binsCount

array<float> binVolumes = array.new_float(binsCount, 0.0)
array<float> binHighs = array.new_float(binsCount, 0.0)
array<float> binLows = array.new_float(binsCount, 0.0)

for i = 0 to binsCount - 1 by 1
    array.set(binLows, i, support + i * binStep)
    array.set(binHighs, i, support + (i + 1) * binStep)
[/pine]

[b]🔵 SYSTEMATIC EXECUTION STRATEGIES & RISK INTERPRETATION[/b]
[list]
[*] [b]Premium Zone Reversals:[/b] When an asset rallies into the upper channel gradient, enters the [b]PREMIUM[/b] zone, and tests the resistance ceiling, monitor the 100-Bin Volume Profile. If the profile shows fading volume bars at the highs, look for short setups targeting a mean-reversion move back down to the Equilibrium Midline.
[*] [b]Discount Value Accumulation Trim:[/b] When price action drops into the [b]DISCOUNT[/b] zone and approaches the channel floor, check the volume profile. Heavy volume concentration at these lows confirms strong institutional interest. Look for long positions here, using the step-line support floor as a strict trade invalidation level.
[*] [b]Equilibrium Breakout Continuations:[/b] Watch the behavior of the asset when the Equilibrium Midline shifts color. A sharp upward shift in the midline accompanied by a validated volume expansion signature suggests a structural trend shift, opening up long continuation options up to the premium line.
[/list]

[b]🔵 INTERFACE CONFIGURATION AND PARAMETERS[/b]
[list]
[*] [b]Pivot Structure Configuration Blocks:[/b] Adjust left/right bar strengths and internal array memory slots to optimize the indicator for short-term swing scalping or long-term macro trend tracking.
[*] [b]Volume Profile Matrix Settings:[/b] Fine-tune lookback depths and maximum bar widths to scale the volume profile layout for any financial asset class or chart timeframe.
[*] [b]Styling & Visual Aesthetics Overrides:[/b] Fully customize colors for rising structures, falling boundaries, interior gradient fills, and background profiles to integrate seamlessly with your preferred light or dark charting interface.
[/list]

Transform your charting layout from traditional linear indicators into a highly automated, volume-anchored volatility tracking network with the [b]Premium and Discount Pivot Matrix[/b] terminal.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator('Premium and Discount Pivot Matrix [BigBeluga]', 'Premium/Discount Matrix [BigBeluga]', overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// --- Groups ---
string G_PIVOT = "Pivot Structure Configuration"
string G_VP    = "Volume Profile Matrix Settings"
string G_STYLE = "Styling & Visual Aesthetics"

// Pivot Structure
pivotLegs       = input.int(5, title = 'Pivot Left/Right Bars', group = G_PIVOT, tooltip = 'Number of bars required on each side to validate a pivot high or low point.')
arraySize       = input.int(10, title = 'Max Pivots to Track (per side)', minval = 2, group = G_PIVOT, tooltip = 'Maximum historical pivots retained in memory to evaluate structural boundaries.')
showSignals     = input.bool(true, title = 'Show Reversal Signals?', group = G_PIVOT, tooltip = 'Toggles display for break and reversal marker dots along with structural volume metadata.')

// Volume Profile Settings
showProfile     = input.bool(true, title = 'Show Volume Profile at Channel End?', group = G_VP, tooltip = 'Toggles visibility of the historical volume distribution block at the right edge of the chart.')
profileLookback = input.int(400, title = 'Volume Profile Lookback (Bars)', minval = 10, group = G_VP, tooltip = 'The depth of historical bars scanned to aggregate and compile volume distributions.')
profileWidth    = input.int(30, title = 'Volume Profile Max Width (Bars)', minval = 5, group = G_VP, tooltip = 'Maximum structural width of the volume profile matrix measured in bars.')

// Styling & Aesthetics
showFill        = input.bool(true, title = 'Show Channel Fill Gradient?', group = G_STYLE, tooltip = 'Toggles visibility for the background cloud gradient between boundaries.')
colorRes        = input.color(#e77912, title = 'Resistance Line Color', group = G_STYLE, tooltip = 'Color treatment applied to Premium levels, upper breakout accents, and upper boundaries.')
colorSup        = input.color(#12e7c0, title = 'Support Line Color', group = G_STYLE, tooltip = 'Color treatment applied to Discount levels, lower breakout accents, and lower boundaries.')
colorMidUp      = input.color(#12e7c0, title = 'Midline Rising Color', group = G_STYLE, tooltip = 'Color assigned to the midline when structural value shifting increases upwards.')
colorMidDn      = input.color(#e77912, title = 'Midline Falling Color', group = G_STYLE, tooltip = 'Color assigned to the midline when structural value shifting drops downwards.')
colorMidFlat    = #1A1A24

// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

var array<float> highPivots = array.new_float(0)
var array<float> lowPivots = array.new_float(0)

//  Detect Pivots 
pHi = ta.pivothigh(high, pivotLegs, pivotLegs)
pLo = ta.pivotlow(low, pivotLegs, pivotLegs)

//  Manage Arrays 
if not na(pHi)
    array.push(highPivots, pHi)
    if array.size(highPivots) > arraySize
        array.shift(highPivots)

if not na(pLo)
    array.push(lowPivots, pLo)
    if array.size(lowPivots) > arraySize
        array.shift(lowPivots)

//  Extract Channel Levels 
float resistance = na
float support = na

if array.size(highPivots) > 0
    resistance := array.max(highPivots)

if array.size(lowPivots) > 0
    support := array.min(lowPivots)

// Calculate Midline
float midline = not na(resistance) and not na(support) ? (resistance + support) / 2 : na

//  Color Midline Based on Trend 
var color midlineColor = color.gray

if midline > midline[1]
    midlineColor := colorMidUp
if midline < midline[1]
    midlineColor := colorMidDn

//  Breakout Signals & Dynamic Volume Labels 
bullishBreakout = ta.crossover(hl2, resistance[1]) and barstate.isconfirmed
bearishBreakout = ta.crossunder(hl2, support[1]) and barstate.isconfirmed

var lastBreak = 0

// }

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

pRes = plot(resistance, title = 'Resistance (Max Pivot High)', color = colorRes, linewidth = 1, style = plot.style_stepline)
pMid = plot(midline, title = 'Midline', color = midlineColor, linewidth = 1, style = plot.style_stepline, linestyle = plot.linestyle_dashed)
pSup = plot(support, title = 'Support (Min Pivot Low)', color = colorSup, linewidth = 1, style = plot.style_stepline)

//  Gradient Fills using Unique Theme Colors 
fill(pMid, pRes, resistance, midline, showFill ? color.new(colorRes, 90) : color.new(color.black, 100),  color.new(color.black, 100), title = 'Top Gradient Upper')
fill(pMid, pSup, midline, support, color.new(color.black, 100), showFill ? color.new(colorSup, 90) : color.new(color.black, 100), title = 'Bottom Gradient Upper')

// Reversal markers kept completely intact visually via plotshape
plotshape(showSignals and bullishBreakout and bar_index - lastBreak > 5, title = 'Bearish Reversal', style = shape.circle, location = location.abovebar, color = colorRes, size = size.tiny)
plotshape(showSignals and bearishBreakout and bar_index - lastBreak > 5, title = 'Bullish Reversal', style = shape.circle, location = location.belowbar, color = colorSup, size = size.tiny)

// Dynamic Volume Label Additions
if showSignals and (bullishBreakout or bearishBreakout) and bar_index - lastBreak > 5
    string volText = str.tostring(volume, format.volume)

    if bullishBreakout
        label.new(x = bar_index, y = high, text = volText, textcolor = chart.fg_color, color = color.new(color.black, 100), style = label.style_label_lower_right, size = size.small)
    else if bearishBreakout
        label.new(x = bar_index, y = low, text = volText, textcolor = chart.fg_color, color = color.new(color.black, 100), style = label.style_label_upper_right, size = size.small)

if bullishBreakout or bearishBreakout
    lastBreak := bar_index

//  100 Bin Volume Profile & Dynamic Labels at Channel End 
var array<box> vpBoxes = array.new_box(0)
var label lblPremium = na
var label lblEquilibrium = na
var label lblDiscount = na

// Container lines to hold the extension projections
var line extResLine = na
var line extMidLine = na
var line extSupLine = na

if showProfile and barstate.islast and not na(resistance) and not na(support) and resistance > support
    if array.size(vpBoxes) > 0
        for i = 0 to array.size(vpBoxes) - 1 by 1
            box.delete(array.get(vpBoxes, i))
        array.clear(vpBoxes)

    label.delete(lblPremium)
    label.delete(lblEquilibrium)
    label.delete(lblDiscount)

    line.delete(extResLine)
    line.delete(extMidLine)
    line.delete(extSupLine)

    int binsCount = 100
    float channelRange = resistance - support
    float binStep = channelRange / binsCount

    array<float> binVolumes = array.new_float(binsCount, 0.0)
    array<float> binHighs = array.new_float(binsCount, 0.0)
    array<float> binLows = array.new_float(binsCount, 0.0)

    for i = 0 to binsCount - 1 by 1
        array.set(binLows, i, support + i * binStep)
        array.set(binHighs, i, support + (i + 1) * binStep)

    for barIdx = 0 to profileLookback - 1 by 1
        float barHigh = high[barIdx]
        float barLow = low[barIdx]
        float barVol = volume[barIdx]

        if not na(barVol) and barHigh > barLow
            for b = 0 to binsCount - 1 by 1
                float bHi = array.get(binHighs, b)
                float bLo = array.get(binLows, b)

                float intersectTop = math.min(barHigh, bHi)
                float intersectBot = math.max(barLow, bLo)

                if intersectTop > intersectBot
                    float weight = (intersectTop - intersectBot) / (barHigh - barLow)
                    array.set(binVolumes, b, array.get(binVolumes, b) + barVol * weight)

    float maxVol = array.max(binVolumes)

    if maxVol > 0
        for b = 0 to binsCount - 1 by 1
            float bHi = array.get(binHighs, b)
            float bLo = array.get(binLows, b)
            float bVol = array.get(binVolumes, b)

            int boxLength = math.round(bVol / maxVol * profileWidth)

            if boxLength > 0
                float edgeDistance = math.abs(b - 49.5) / 49.5
                int dynamicTransparency = math.round(95 - edgeDistance * 50)
                color boxColor = bLo >= midline ? color.new(colorRes, dynamicTransparency) : color.new(colorSup, dynamicTransparency)

                box vpBox = box.new(left = bar_index + 2, top = bHi, right = bar_index + 2 + boxLength, bottom = bLo, bgcolor = boxColor, border_color = color.new(chart.bg_color, 0), border_width = 1)
                array.push(vpBoxes, vpBox)

    //  Profile Termination Line Projections 
    int labelOffset = bar_index + 4 + profileWidth
    float premiumTargetLoc = resistance
    float discountTargetLoc = support

    //  Premium, Equilibrium, and Discount Labels 
    lblPremium := label.new(x = labelOffset, y = premiumTargetLoc, text = 'PREMIUM', textcolor = colorRes, color = color.new(color.black, 100), style = label.style_label_left, size = size.small)
    lblEquilibrium := label.new(x = labelOffset, y = midline, text = 'EQUILIBRIUM', textcolor = midlineColor, color = color.new(color.black, 100), style = label.style_label_left, size = size.small)
    lblDiscount := label.new(x = labelOffset, y = discountTargetLoc, text = 'DISCOUNT', textcolor = colorSup, color = color.new(color.black, 100), style = label.style_label_left, size = size.small)

    extResLine := line.new(x1 = bar_index, y1 = premiumTargetLoc, x2 = labelOffset, y2 = premiumTargetLoc, color = colorRes, width = 1, force_overlay = true)
    extMidLine := line.new(x1 = bar_index, y1 = midline, x2 = labelOffset, y2 = midline, color = midlineColor, width = 1, force_overlay = true, style = line.style_dashed)
    extSupLine := line.new(x1 = bar_index, y1 = discountTargetLoc, x2 = labelOffset, y2 = discountTargetLoc, color = colorSup, width = 1, force_overlay = true)

// }
````
