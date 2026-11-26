# Smart Money Matrix ICT + Volume Profile [Point algo]

- url: https://www.tradingview.com/script/GcvLpM3i-Smart-Money-Matrix-ICT-Volume-Profile-Point-algo/
- type: indicator
- pine_id: PUB;13dc493f435045abab61c6177534f242
- version: 1.0

## Description

This indicator is a comprehensive institutional-grade toolkit designed to bridge the gap between Market Structure (SMC/ICT) and Volume Analysis (Volume Profile). By combining these two distinct analytical disciplines, the indicator provides a high-confluence "Matrix" view of the market, helping traders identify where high-conviction orders are resting and how price structure is reacting to them.

[b]Core Functionality[/b]
The script is divided into three primary modules that work in synergy:

[b]1. ICT & Smart Money Structure[/b]
This module tracks the "DNA" of market movement using high-precision pivot detection:
[list]
[*]Market Structure Shift (MSS) & Break of Structure (BOS): Automatically identifies trend transitions and continuations.
[*]Liquidity Sweeps: Highlights "stop hunts" where price wicks beyond previous swing points before reversing, signaling institutional absorption.
[*]Dynamic Fair Value Gaps (FVG): Plots active FVGs and automatically removes them (mitigation) once price returns to fill the imbalance.
[/list]

[b]2. Advanced Volume Profile (VP)[/b]
While most volume profiles are static, this engine calculates volume distribution over a user-defined lookback period to find the "fairest" price levels:
[list]
[*]Point of Control (POC): The price level with the highest traded volume, acting as a massive magnet or pivot.
[*]Value Area (VAH/VAL): Highlights the zone where 70% (customizable) of the volume took place, distinguishing between value-driven moves and "excess" price action.
[*]Bull/Bear Volume Split: The profile histogram is color-coded to show whether buyers or sellers were more aggressive at specific price nodes.
[/list]

[b]3. Master Intelligence Dashboard (HUD)[/b]
A real-time terminal in the corner of your chart that synthesizes all data points:
[list]
[*]Market Bias: Real-time bullish/bearish/neutral status based on structural breaks.
[*]Zone Positioning: Instantly tells you if price is above, below, or at value (POC).
[*]Distance Metrics: Calculates the percentage distance to the POC for mean-reversion planning.
[/list]

[b]How to Use[/b]
[list]
[*]High Confluence Entry: Look for a Liquidity Sweep or MSS that occurs exactly at the Value Area Low (VAL) or POC. This suggests institutions are defending a high-volume zone.
[*]Targeting: Use the POC as a primary take-profit level during mean-reversion trades.
[*]Imbalance Trading: Use the FVG boxes to identify "magnets" in the market. If price breaks structure (BOS) and leaves an FVG near the Value Area High, expect a retracement to that zone before the next leg.
[/list]

[b]Technical Breakdown[/b]
[list]
[*]Pivots: Uses a customizable lookback length to detect swing points.
[*]Volume Binning: Divides the price range into numBins to calculate volume density accurately across the lookback period.
[*]Non-Repainting: All structural labels (MSS/BOS/Sweeps) and FVG boxes are calculated on closed bars to ensure signal integrity.
[*]Transparency: All features, from FVG transparency to the number of Volume bins, are fully adjustable via the user settings menu.
[/list]

[b]Disclaimer:[/b] Trading involves significant risk. This tool is designed for technical analysis and educational purposes. It does not provide financial advice. Past performance of structural patterns is not indicative of future results.

## Source Code

````pine
//@version=5
indicator("Smart Money Matrix ICT + Volume Profile [Point algo]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

grp_ui = "ICT Premium Colors"
bullColor = input.color(color.rgb(0, 230, 118), "ICT Bullish Accents", group=grp_ui)
bearColor = input.color(color.rgb(255, 23, 68), "ICT Bearish Accents", group=grp_ui)
zoneAlpha = input.int(85, "FVG Transparency", minval=0, maxval=100, group=grp_ui)

grp_ict = "ICT Features"
showFVG = input.bool(true, "Show Mitigating FVGs?", group=grp_ict)
maxBoxBars = input.int(50, "Max FVG Extension (Bars)", group=grp_ict)
showStruct = input.bool(true, "Show MSS / BOS?", group=grp_ict)
showSweeps = input.bool(true, "Show Liquidity Sweeps?", group=grp_ict)
showPivots = input.bool(true, "Show Pivot Points?", group=grp_ict)
length = input.int(5, "Swing Detection Length", group=grp_ict)

grp_vp = "Volume Profile Settings"
lookback = input.int(100, "VP Lookback Bars", minval=20, maxval=500, group=grp_vp)
numBins = input.int(24, "Number of Price Levels", minval=10, maxval=50, group=grp_vp)
profileDirection = input.string("Right to Left", "Histogram Direction", options=["Left to Right", "Right to Left"], group=grp_vp)
profileGap = input.int(15, "Gap from Current Candle", minval=0, maxval=100, group=grp_vp)
profileOffset = input.int(20, "Profile Width Multiplier", minval=1, maxval=100, group=grp_vp)
vaPercent = input.int(70, "Value Area %", minval=60, maxval=90, group=grp_vp)

grp_vp_colors = "Volume Profile Colors"
showProfile = input.bool(true, "Show VP Histogram", group=grp_vp_colors)
showPOC = input.bool(true, "Show POC Line", group=grp_vp_colors)
showVAH = input.bool(true, "Show Value Area High", group=grp_vp_colors)
showVAL = input.bool(true, "Show Value Area Low", group=grp_vp_colors)
pocColor = input.color(color.yellow, "POC Color", group=grp_vp_colors)
vahColor = input.color(color.red, "VAH Color", group=grp_vp_colors)
valColor = input.color(color.green, "VAL Color", group=grp_vp_colors)
bullVolColor = input.color(color.new(color.green, 60), "Bull Volume Color", group=grp_vp_colors)
bearVolColor = input.color(color.new(color.red, 60), "Bear Volume Color", group=grp_vp_colors)

showHUD = input.bool(true, "Show Master Dashboard?", group="Master HUD")

ph = ta.pivothigh(high, length, length)
pl = ta.pivotlow(low, length, length)

var float lastHigh = na
var float lastLow = na
var int trend = 0 

if not na(ph)
    lastHigh := ph
    if showPivots
        label.new(bar_index[length], ph, "×", color=color.new(color.white, 100), textcolor=color.gray, style=label.style_label_down, size=size.small)

if not na(pl)
    lastLow := pl
    if showPivots
        label.new(bar_index[length], pl, "×", color=color.new(color.white, 100), textcolor=color.gray, style=label.style_label_up, size=size.small)

bearSweep = high > lastHigh and close < lastHigh and not na(lastHigh)
bullSweep = low < lastLow and close > lastLow and not na(lastLow)

if showSweeps and bearSweep
    label.new(bar_index, high, "Sweep", color=color.new(bearColor, 100), textcolor=bearColor, style=label.style_label_down, size=size.tiny)
    lastHigh := na 

if showSweeps and bullSweep
    label.new(bar_index, low, "Sweep", color=color.new(bullColor, 100), textcolor=bullColor, style=label.style_label_up, size=size.tiny)
    lastLow := na 

bullBreak = close > lastHigh and not na(lastHigh)
bearBreak = close < lastLow and not na(lastLow)

if bullBreak and showStruct
    isMSS = trend == -1 or trend == 0
    line.new(bar_index[length], lastHigh, bar_index, lastHigh, color=bullColor, style=line.style_dashed)
    label.new(math.round(bar_index - (length/2)), lastHigh, isMSS ? "MSS" : "BOS", color=color.new(color.black, 100), textcolor=bullColor, style=label.style_label_down, size=size.tiny)
    trend := 1
    lastHigh := na 

if bearBreak and showStruct
    isMSS = trend == 1 or trend == 0
    line.new(bar_index[length], lastLow, bar_index, lastLow, color=bearColor, style=line.style_dashed)
    label.new(math.round(bar_index - (length/2)), lastLow, isMSS ? "MSS" : "BOS", color=color.new(color.black, 100), textcolor=bearColor, style=label.style_label_up, size=size.tiny)
    trend := -1
    lastLow := na

var box[] bullFvgs = array.new_box()
var box[] bearFvgs = array.new_box()

isBullFvg = low > high[2] and close[1] > high[2]
isBearFvg = high < low[2] and close[1] < low[2]

if isBullFvg and showFVG
    bx = box.new(left=bar_index[2], top=low, bottom=high[2], right=bar_index, bgcolor=color.new(bullColor, zoneAlpha), border_color=na)
    array.push(bullFvgs, bx)

if isBearFvg and showFVG
    bx = box.new(left=bar_index[2], top=low[2], bottom=high, right=bar_index, bgcolor=color.new(bearColor, zoneAlpha), border_color=na)
    array.push(bearFvgs, bx)

if array.size(bullFvgs) > 0
    for i = array.size(bullFvgs) - 1 to 0
        bx = array.get(bullFvgs, i)
        if (bar_index - box.get_left(bx)) > maxBoxBars
            array.remove(bullFvgs, i) 
        else
            box.set_right(bx, bar_index) 
            if low < box.get_top(bx) 
                array.remove(bullFvgs, i) 

if array.size(bearFvgs) > 0
    for i = array.size(bearFvgs) - 1 to 0
        bx = array.get(bearFvgs, i)
        if (bar_index - box.get_left(bx)) > maxBoxBars
            array.remove(bearFvgs, i) 
        else
            box.set_right(bx, bar_index) 
            if high > box.get_bottom(bx) 
                array.remove(bearFvgs, i) 


highestPrice = ta.highest(high, lookback)
lowestPrice = ta.lowest(low, lookback)
priceRange = highestPrice - lowestPrice
binSize = priceRange / numBins

var array<float> volumeProfile = array.new_float(numBins, 0)
var array<float> bullVolProfile = array.new_float(numBins, 0)
var array<float> bearVolProfile = array.new_float(numBins, 0)

array.clear(volumeProfile)
array.clear(bullVolProfile)
array.clear(bearVolProfile)

for i = 0 to numBins - 1
    array.push(volumeProfile, 0.0)
    array.push(bullVolProfile, 0.0)
    array.push(bearVolProfile, 0.0)

if barstate.islast and binSize > 0
    for i = 0 to lookback - 1
        if i < bar_index
            barHigh = high[i]
            barLow = low[i]
            barClose = close[i]
            barOpen = open[i]
            barVol = volume[i]
            
            barMidPrice = (barHigh + barLow) / 2
            binIndex = math.floor((barMidPrice - lowestPrice) / binSize)
            binIndex := math.max(0, math.min(binIndex, numBins - 1))
            
            currentVol = array.get(volumeProfile, binIndex)
            array.set(volumeProfile, binIndex, currentVol + barVol)
            
            if barClose > barOpen
                bullVol = array.get(bullVolProfile, binIndex)
                array.set(bullVolProfile, binIndex, bullVol + barVol)
            else
                bearVol = array.get(bearVolProfile, binIndex)
                array.set(bearVolProfile, binIndex, bearVol + barVol)

var float pocPrice = na
var float vahPrice = na
var float valPrice = na
var int pocIndex = na

if barstate.islast and array.size(volumeProfile) > 0
    maxVolume = array.max(volumeProfile)
    pocIndex := array.indexof(volumeProfile, maxVolume)
    pocPrice := lowestPrice + (pocIndex * binSize) + (binSize / 2)
    
    totalVolume = array.sum(volumeProfile)
    targetVolume = totalVolume * vaPercent / 100
    
    vaVolume = array.get(volumeProfile, pocIndex)
    upperIdx = pocIndex
    lowerIdx = pocIndex
    
    while vaVolume < targetVolume and (upperIdx < numBins - 1 or lowerIdx > 0)
        upperVol = upperIdx < numBins - 1 ? array.get(volumeProfile, upperIdx + 1) : 0.0
        lowerVol = lowerIdx > 0 ? array.get(volumeProfile, lowerIdx - 1) : 0.0
        
        if upperVol >= lowerVol and upperIdx < numBins - 1
            upperIdx := upperIdx + 1
            vaVolume := vaVolume + upperVol
        else if lowerIdx > 0
            lowerIdx := lowerIdx - 1
            vaVolume := vaVolume + lowerVol
        else
            break
            
    vahPrice := lowestPrice + (upperIdx * binSize) + binSize
    valPrice := lowestPrice + (lowerIdx * binSize)


var box[] profileBoxes = array.new_box(0)

if showProfile and barstate.islast and array.size(volumeProfile) > 0
    if array.size(profileBoxes) > 0
        for i = 0 to array.size(profileBoxes) - 1
            box.delete(array.get(profileBoxes, i))
        array.clear(profileBoxes)
    
    maxVol = array.max(volumeProfile)
    
    for i = 0 to numBins - 1
        vol = array.get(volumeProfile, i)
        bullVol = array.get(bullVolProfile, i)
        bearVol = array.get(bearVolProfile, i)
        
        if vol > 0
            barTop = lowestPrice + ((i + 1) * binSize)
            barBottom = lowestPrice + (i * binSize)
            barWidth = (vol / maxVol) * profileOffset
            barAnchor = bar_index + profileGap
            
            // Gap and Direction Logic
            barLeft = profileDirection == "Right to Left" ? barAnchor - int(barWidth) : barAnchor
            barRight = profileDirection == "Right to Left" ? barAnchor : barAnchor + int(barWidth)
            
            boxColor = bullVol > bearVol ? bullVolColor : bearVolColor
            
            b = box.new(barLeft, barTop, barRight, barBottom, border_color=color.new(color.gray, 80), bgcolor=boxColor, border_width=1)
            array.push(profileBoxes, b)

var line pocLine = na
var line vahLine = na
var line valLine = na
var label pocLabel = na
var label vahLabel = na
var label valLabel = na

if barstate.islast
    lineEnd = bar_index + profileGap + (profileDirection == "Left to Right" ? profileOffset : 5)
    
    if showPOC and not na(pocPrice)
        if not na(pocLine)
            line.delete(pocLine)
        if not na(pocLabel)
            label.delete(pocLabel)
        pocLine := line.new(bar_index - lookback, pocPrice, lineEnd, pocPrice, color=pocColor, width=3, style=line.style_solid)
        pocLabel := label.new(lineEnd, pocPrice, "POC", style=label.style_label_left, color=color.new(color.black, 100), textcolor=pocColor, size=size.small)

    if showVAH and not na(vahPrice)
        if not na(vahLine)
            line.delete(vahLine)
        if not na(vahLabel)
            label.delete(vahLabel)
        vahLine := line.new(bar_index - lookback, vahPrice, lineEnd, vahPrice, color=vahColor, width=2, style=line.style_dashed)
        vahLabel := label.new(lineEnd, vahPrice, "VAH", style=label.style_label_left, color=color.new(color.black, 100), textcolor=vahColor, size=size.tiny)

    if showVAL and not na(valPrice)
        if not na(valLine)
            line.delete(valLine)
        if not na(valLabel)
            label.delete(valLabel)
        valLine := line.new(bar_index - lookback, valPrice, lineEnd, valPrice, color=valColor, width=2, style=line.style_dashed)
        valLabel := label.new(lineEnd, valPrice, "VAL", style=label.style_label_left, color=color.new(color.black, 100), textcolor=valColor, size=size.tiny)


aboveVA = not na(vahPrice) and close > vahPrice
belowVA = not na(valPrice) and close < valPrice
nearPOC = not na(pocPrice) and math.abs(close - pocPrice) < (priceRange * 0.02)
crossAbovePOC = not na(pocPrice) and ta.crossover(close, pocPrice)
crossBelowPOC = not na(pocPrice) and ta.crossunder(close, pocPrice)
vahRejection = ta.crossunder(close, vahPrice) and close[1] > vahPrice
valBounce = ta.crossover(close, valPrice) and close[1] < valPrice

plotshape(crossAbovePOC, "POC Cross Up", shape.triangleup, location.belowbar, color.new(color.yellow, 0), size=size.tiny)
plotshape(crossBelowPOC, "POC Cross Down", shape.triangledown, location.abovebar, color.new(color.orange, 0), size=size.tiny)
plotshape(valBounce, "VAL Bounce", shape.labelup, location.belowbar, color.new(color.green, 0), text="VAL", textcolor=color.white, size=size.small)
plotshape(vahRejection, "VAH Rejection", shape.labeldown, location.abovebar, color.new(color.red, 0), text="VAH", textcolor=color.white, size=size.small)

bgcolor(aboveVA ? color.new(color.red, 95) : belowVA ? color.new(color.green, 95) : nearPOC ? color.new(color.yellow, 95) : na)


var table hud = table.new(position.top_right, 2, 8, bgcolor=color.new(#1e222d, 10), border_color=color.new(color.gray, 80), border_width=1)

if barstate.islast and showHUD
    // ICT Core Bias
    table.cell(hud, 0, 0, "L17 Market Bias", text_color=color.gray, text_size=size.small)
    biasText = trend == 1 ? "BULLISH" : trend == -1 ? "BEARISH" : "NEUTRAL"
    biasColor = trend == 1 ? bullColor : trend == -1 ? bearColor : color.gray
    table.cell(hud, 1, 0, biasText, text_color=biasColor, text_size=size.small)
    
    table.cell(hud, 0, 1, "Active FVGs", text_color=color.gray, text_size=size.small)
    fvgCount = str.tostring(array.size(bullFvgs) + array.size(bearFvgs))
    table.cell(hud, 1, 1, fvgCount, text_color=color.white, text_size=size.small)
    
    // VP Separator
    table.cell(hud, 0, 2, "─ Volume Profile ─", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 2, "─ Value ─", text_color=color.white, text_size=size.small)
    
    // VP Stats
    table.cell(hud, 0, 3, "POC", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 3, not na(pocPrice) ? str.tostring(pocPrice, format.mintick) : "N/A", text_color=pocColor, text_size=size.small)
    
    table.cell(hud, 0, 4, "VAH", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 4, not na(vahPrice) ? str.tostring(vahPrice, format.mintick) : "N/A", text_color=vahColor, text_size=size.small)
    
    table.cell(hud, 0, 5, "VAL", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 5, not na(valPrice) ? str.tostring(valPrice, format.mintick) : "N/A", text_color=valColor, text_size=size.small)
    
    table.cell(hud, 0, 6, "Zone Position", text_color=color.white, text_size=size.small)
    posText = aboveVA ? "ABOVE VA" : belowVA ? "BELOW VA" : nearPOC ? "AT POC" : "IN VA"
    posColor = aboveVA ? color.red : belowVA ? color.green : nearPOC ? color.yellow : color.gray
    table.cell(hud, 1, 6, posText, text_color=posColor, text_size=size.small)
    
    table.cell(hud, 0, 7, "Dist to POC", text_color=color.white, text_size=size.small)
    pocDist = not na(pocPrice) ? ((close - pocPrice) / pocPrice) * 100 : 0
    table.cell(hud, 1, 7, str.tostring(pocDist, "#.##") + "%", text_color=pocDist > 0 ? color.green : color.red, text_size=size.small)

alertcondition(crossAbovePOC, "POC Cross Up", "Price crossed above POC")
alertcondition(crossBelowPOC, "POC Cross Down", "Price crossed below POC")
alertcondition(valBounce, "VAL Bounce", "Price bounced from Value Area Low")
alertcondition(vahRejection, "VAH Rejection", "Price rejected from Value Area High")
alertcondition(nearPOC, "Near POC", "Price near Point of Control")
````
