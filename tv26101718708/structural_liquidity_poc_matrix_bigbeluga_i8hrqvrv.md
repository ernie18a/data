# Structural Liquidity & POC Matrix [BigBeluga]

- url: https://www.tradingview.com/script/I8HrQVRv-Structural-Liquidity-POC-Matrix-BigBeluga/
- type: indicator
- pine_id: PUB;95222effbc4441e38fcef15d270aaf22
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
[quote]The [b]Structural Liquidity & POC Matrix [BigBeluga][/b] is a clean, automated price action terminal built to track institutional key levels. It isolates important market highs and lows over a set lookback period and instantly projects them onto your chart as trailing liquidity lines. 

Additionally, the script calculates a dynamic volume profile between those major high and low structural markers. Instead of scattering lines everywhere, it neatly draws this volume breakdown on the right side of your workspace to reveal exactly where the heaviest trading occurred and highlights the Point of Control (POC).[/quote]


[b]🔵 FEATURES[/b]
[quote]The toolkit maps out key market interaction zones using a streamlined structural tracking framework:
[b]1 — Dynamic Liquidity Range Tracking[/b]
[list]
[*] [b]Automated Sweep Highs & Lows:[/b] The engine scans your chart using a set lookback period ([b]Liquidity Length[/b]) to find key historical highs and lows, drawing sharp levels right at those turning points.
[*] [b]Smart Fading Level Lines:[/b] Once a liquidity line is plotted, it trails forward until it hits a customizable timer limit ([b]Fade Liquidity[/b]). The line smoothly fades out and resets over time, ensuring your chart stays perfectly clean.
[*] [b]Visual Breakout Diamond Markers:[/b] The exact moment price action breaks or shifts out of a previously established liquidity level, the script prints a sharp diamond symbol (◆) to flag the market sweep.
[image]https://www.tradingview.com/x/adyPTk65/[/image]
[/list]

[b]2 — Adaptive Sidebar Volume Profile & Matrix[/b]
[list]
[*] [b]Right-Side Profile Alignment:[/b] To keep your workspace completely clear of clutter, the script shifts the historical volume breakdown out of the way, plotting it onto the right margin of your screen ([b]Profile Offset[/b]).
[*] [b]Structural Volume Distribution:[/b] The engine tallies up all volume traded between the active major high and low blocks. It dynamically projects the results as a clean structural polyline matrix block, colored to match the dominant market flow.
[*] [b]Point of Control (POC) Target Line:[/b] The system automatically scans your volume data to pinpoint the absolute heaviest volume node ([b]Point of Control (POC)[/b]). It stretches a bright line ([b]POC Color[/b]) from the start of the structure all the way through the profile to reveal major institutional fair value anchors.
[image]https://www.tradingview.com/x/SYboQs8a/[/image]
[/list]

[pine]
// Volume Profile Array Bins & POC Target Index Lookup
volBins = array.new<float>(size, 0.0)
for i = start to bar_index
    price = close[bar_index - i]
    binIdx = math.floor((price - profBot) / atr)
    if binIdx >= 0 and binIdx < size
        array.set(volBins, binIdx, array.get(volBins, binIdx) + volume[bar_index - i])

maxVol = array.max(volBins)
pocBinIdx = volBins.indexof(maxVol) // Find the exact index of the POC
[/pine]
[/quote]

[b]🔵 HOW TO USE[/b]
[quote]Integrating these structural matrix lines into an everyday trading plan follows a clear, step-by-step strategy structure:

[list=1]
[*] [b]Isolate the Active Range Boundaries:[/b] Monitor the top orange and bottom blue tracking lines to instantly map the current structural playing field. These trailing boundaries reveal exactly where short-term stops and market liquidity pool rest.
[*] [b]Locate the Institutional Fair Value Anchor:[/b] Look for the bright yellow Point of Control line stretching across the chart. This level shows you where the largest amount of volume has changed hands, identifying a strong support or resistance anchor for future retests.
[*] [b]Execute Trades Off Range Sweeps:[/b] Watch the chart closely when price sweeps past an outer liquidity line and prints a diamond indicator. If price snaps back inside the range, look to ride the reversal momentum straight across the matrix toward the yellow POC target line.
[image]https://www.tradingview.com/x/HE1XtUA7/[/image]
[image]https://www.tradingview.com/x/GMuXiU8G/[/image]
[/list][/quote]


[b]🔵 NOTES[/b]
[quote][b]Why this implementation is unique:[/b]
[list]
[*] It acts as a compact, self-cleaning support and resistance tool by automatically fading out old level lines before they can crowd your screen.
[*] Rather than forcing you to look at a fixed, unmoving session volume profile, it anchors its volume calculation directly between the active high and low price pivots.
[*] The smart polyline rendering engine keeps your trading window uncluttered by cleanly shifting detailed volume histograms entirely over to the right margin space.
[/list][/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Structural Liquidity & POC Matrix [BigBeluga]", overlay = true, max_polylines_count = 100, max_bars_back = 500, max_labels_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

liquidityLen  = input.int(100, title="Liquidity Length", tooltip="Lookback period to determine the highest and lowest historical price levels.")
fadeLiquidity = input.int(100, title="Fade Liquidity", tooltip="Number of bars after which the liquidity level line fully fades out or resets.")

profOffset   = input.int(50, title="Profile Offset", tooltip="Determines how far to the right of the current bar the volume profile is rendered.")
showPOC      = input.bool(true, title="Point of Control (POC)", inline = "PPOC", tooltip="Toggle to show/hide the Point of Control (POC) line representing highest volume price.")
pocCol       = input.color(color.yellow, title="POC Color", inline = "PPOC", tooltip="Select the color for the Point of Control line.")

bullCol      = input.color(color.rgb(0, 165, 230), title="Bullish Color", tooltip="Color accent used for bottom sweep signals and bullish profile fills.")
bearCol      = input.color(color.rgb(211, 84, 34), title="Bearish Color", tooltip="Color accent used for top sweep signals and bearish profile fills.")

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

bodyTop = math.max(close, open)
bodyBot = math.min(close, open)
var topLBL = label(na)
var botLBL = label(na)

var indexTop = 0
var indexBot = 0

var profBot = 0.
var profTop = 0.

// Top Sweep Logic
H = ta.highest(liquidityLen)
highg = high == H 

var countUP = 0
var top = float(na)

if highg and countUP == 0
    countUP := 1 

if highg
    top := H

if countUP >= 1
    countUP += 1

if countUP == fadeLiquidity
    countUP := 0
    top := float(na)

if countUP == 2
    topLBL.delete()
    indexTop := bar_index
    topLBL := label.new(bar_index, top, str.tostring(top), color=bearCol, style=label.style_label_down, force_overlay = true)
    profTop := top

if top != top[1]
    label.new(bar_index, top, "◆", color = color(na), textcolor=bearCol, style=label.style_label_down, force_overlay = true)
    countUP := 0
    top := float(na)

upperCol = color.from_gradient(countUP, 0, fadeLiquidity, bearCol, color.rgb(255, 82, 82, 100))

// --- Bottom Sweep Logic ---
L = ta.lowest(liquidityLen)
lowg = low == L

var countDN = 0
var bottom = float(na)

if lowg and countDN == 0
    countDN := 1

if lowg
    bottom := L

if countDN >= 1
    countDN += 1

if countDN == fadeLiquidity
    countDN := 0
    bottom := float(na)

if countDN == 2
    botLBL.delete()
    indexBot := bar_index
    botLBL := label.new(bar_index, low, str.tostring(bottom), color=bullCol, style=label.style_label_up, force_overlay = true)
    profBot := bottom

if bottom != bottom[1]
    label.new(bar_index, low, "◆", color=color(na), textcolor = bullCol, style=label.style_label_up, force_overlay = true)
    countDN := 0
    bottom := float(na)

lowerCol = color.from_gradient(countDN, 0, fadeLiquidity, bullCol, color.rgb(76, 175, 80, 100))

// Volume Profile Calculations
start = math.min(indexBot, indexTop)
atr = ta.atr(100) * 0.2

var Tcol = color(na)

if lowg
    Tcol := bearCol

if highg
    Tcol := bullCol

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Plot Sweeps Lines
plot(top, "Liquidity Top", color = upperCol, style = plot.style_linebr, force_overlay = true, linewidth = 2)
plot(bottom, "Liquidity Bottom", color = lowerCol, style = plot.style_linebr, force_overlay = true, linewidth = 2)

// Volume Profile Drawing Logic
if barstate.islast
    height = profTop - profBot
    size = math.max(1, math.round(height / atr)) // Ensure size is at least 1
    
    // Create array to hold volume for each price level
    volBins = array.new<float>(size, 0.0)
    pointArray = array.new<chart.point>()

    var polyline poly = na
    var midLine = line(na)
    var line pocLine = na

    poly.delete()
    midLine.delete()
    pocLine.delete()
    
    // Loop through the range to fill bins
    for i = start to bar_index
        price = close[bar_index - i]
        binIdx = math.floor((price - profBot) / atr)
        
        if binIdx >= 0 and binIdx < size
            currentVol = array.get(volBins, binIdx)
            array.set(volBins, binIdx, currentVol + volume[bar_index - i])
    
    // Normalize volume for polyline width
    maxVol = array.max(volBins)
    pocBinIdx = volBins.indexof(maxVol) // Find the index of the highest volume bin (POC)
    
    // Plot using polylines
    for i = 0 to size - 1
        vol = array.get(volBins, i)
        binBot = profBot + (i * atr)
        binTop = profBot + (i * atr) + atr
        
        // Define width of the bar based on volume
        width = (vol / maxVol) * profOffset 

        if i == 0 
            array.push(pointArray, chart.point.from_index(bar_index + profOffset, binBot))

        array.push(pointArray, chart.point.from_index(bar_index + profOffset - int(width), binBot))
        array.push(pointArray, chart.point.from_index(bar_index + profOffset - int(width), binTop))

        if i == size - 1
            array.push(pointArray, chart.point.from_index(bar_index + profOffset, binTop))

    poly := polyline.new(
             points = pointArray, closed = false,
             line_color = color.new(Tcol, 0), fill_color = color.new(Tcol, 90),
             line_width = 1
     )

    midLine := line.new(int(math.avg(indexBot, indexTop)), profBot + height/2, bar_index, profBot + height/2, color = color.gray, style = line.style_dashed)
    
    // --- POC Plot ---
    if showPOC and size > 0
        pocPrice = profBot + (pocBinIdx * atr) + (atr / 2) // Middle price of the POC bin
        pocVol = array.get(volBins, pocBinIdx)
        pocWidth = (pocVol / maxVol) * profOffset
        
        pocLine := line.new(
             x1 = start, 
             y1 = pocPrice, 
             x2 = bar_index + profOffset - int(pocWidth), 
             y2 = pocPrice, 
             color = pocCol, 
             width = 2
             )
// }
````
