<!-- tradingview-pine-id: PUB;826cc6a64acf4377b95cd832403a2c56 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Momentum Range Flip @MaxMaserati

Source: https://www.tradingview.com/script/trS9UjNZ-Momentum-Range-Flip-MaxMaserati/

## Description

Momentum Range Flip

Momentum Range Flip flags a body-close breakout candle, then tracks how far price runs from it before reversing back through the origin. While the range is open, it splits the volume traded inside it into estimated buy and sell volume per price level, then sorts those levels into a Point of Control, High Volume Nodes, and Low Volume Nodes.

─── RANGE ANCHOR AND EXPANSION ───
A momentum candle closes above the prior high or below the prior low, checked only on confirmed bars. Immediate Body Close anchors on that candle; Wait for NBC waits for one inside/balance candle to close first, then anchors back to the breakout candle. Once anchored, the range top and bottom track the highest high and lowest low seen so far. Expansion Method sets whether those bounds update live, tick by tick, or only on candle close. A close back outside the range in the opposite direction ends it.

[image]https://www.tradingview.com/x/T1SZtDJI/[/image]

─── DELTA VOLUME PROFILE, POC, HVN, AND LVN ───
Each bar inside the range splits its volume into buy and sell using:
buy % = clamp(0.5 + body-to-range ratio × 0.3 − wick ratio × 0.1, 0.1, 0.9)
That split is spread across price bins sized by Ticks per Bin. The single bin with the highest total volume becomes the Point of Control (POC). Any other bin at or above the HVN Threshold percent of that top bin is a High Volume Node — a price level heavy trading defended. Any bin at or below the LVN Threshold percent is a Low Volume Node — a price level trading passed through fast, with little resistance. POC, HVN, and LVN each have their own show/hide toggle and line width, so you can isolate any one layer.

─── HOW TO USE ───
1. Wait for the wedge box to appear — this marks a new momentum range, colored by its bullish or bearish bias.
2. Read the RH / RH TGT and RL / RL TGT labels for the current top and bottom of the range.
3. Find the thickest line — that is the POC, the price level with the most volume traded inside the range.
4. Check the High Volume Node lines for other price levels where volume built up; these tend to act as support or resistance if price returns.
5. Check the Low Volume Node lines for gaps in volume; price tends to move through these fast rather than stall.
6. A candle closing beyond the top or bottom line ends the range; treat that as invalidation of the current bias.

─── SETTINGS ───
Calculation Logic — choose the anchor trigger (Immediate vs Wait for NBC) and the expansion method (Live vs Wait for Candle Close).
Colors and Style — wedge fill transparency, bullish/bearish colors, extension line width.
Structure Targets — how far the target lines and labels extend, and their label size.
Delta Volume Profile and POC — toggle the profile, set bin size (Ticks per Bin) and max profile width, then independently toggle and set the line width for POC, HVN (with its own volume threshold), and LVN (with its own volume threshold). Buy/sell colors apply across all three.

─── NOTES ───
In Live (Tick-by-Tick) mode, the range bounds and volume profile update using unclosed, live wick prices and can shift before the bar closes. Switch to Wait for Candle Close for calculations that only use confirmed values. The buy/sell volume split is an estimate based on candle structure, not real order flow data. HVN and LVN thresholds are relative to the biggest bin in the current range, not a fixed volume number. Built for intraday futures charts (ES, NQ) but works on any liquid symbol with volume data.

---

## Source Code

````pine
//@version=6
indicator("Momentum Range Flip @MaxMaserati", overlay=true, max_lines_count=500, max_labels_count=500, max_polylines_count=100)

// ─── SETTINGS ───
logicGroup = "Calculation Logic"
triggerMethod = input.string("Immediate Body Close", title="Anchor Trigger (Start Shape)", options=["Wait for NBC (Failed Close)", "Immediate Body Close"], group=logicGroup, tooltip="Immediate: Starts instantly when a momentum candle closes. Wait for NBC: Waits for a balance/inside candle to close before anchoring to the previous momentum candle.")
calcMethod = input.string("Live (Tick-by-Tick)", title="Expansion Method (Move Bounds)", options=["Live (Tick-by-Tick)", "Wait for Candle Close"], group=logicGroup, tooltip="Live: Bounds expand instantly with live wicks. Wait for Close: Bounds only expand when the candle officially closes.")

colorGroup = "Colors and Style"
boxTransparency = input.int(85, title="Polyline Fill Transparency", minval=0, maxval=100, group=colorGroup)

bullPolyColor = input.color(#00ff88, title="Bullish Polyline", group=colorGroup)
bearPolyColor = input.color(#ff0044, title="Bearish Polyline", group=colorGroup)

bullLineColor = input.color(#00ff88, title="Bullish Extension Line", group=colorGroup)
bearLineColor = input.color(#ff0044, title="Bearish Extension Line", group=colorGroup)
extLineWidth = input.int(2, title="Extension Line Width", minval=1, maxval=5, group=colorGroup)

grp_range      = "Structure Targets"
line_ext       = input.int(15, "Extension (bars)", minval=1, inline="r5", group=grp_range)
lbl_size_lines = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large"], inline="r5", group=grp_range)

volGroup = "Delta Volume Profile and POC"
showVolumeImprint = input.bool(true, title="Show Volume Profile", group=volGroup)
ticksPerBin = input.int(30, title="Ticks per Bin", minval=1, maxval=100, group=volGroup, tooltip="Sets how many ticks of price range each bin covers. Lower value means more bins and more detail.")
vpMaxWidth = input.int(9, title="Profile Max Width (Bars)", minval=1, maxval=50, group=volGroup, tooltip="Limits how far the profile lines extend visually.")

showPOC = input.bool(true, title="Show POC Line", group=volGroup)
pocWidth = input.int(6, title="POC Line Width", minval=1, maxval=10, group=volGroup)

showHVN = input.bool(true, title="Show HVN Nodes", group=volGroup)
hvnThreshold = input.int(70, title="HVN Threshold (% of Max Volume)", minval=1, maxval=99, group=volGroup, tooltip="Bins at or above this percent of the highest-volume bin are marked as High Volume Nodes.")
hvnWidth = input.int(4, title="HVN Line Width", minval=1, maxval=10, group=volGroup)

showLVN = input.bool(true, title="Show LVN Nodes", group=volGroup)
lvnThreshold = input.int(30, title="LVN Threshold (% of Max Volume)", minval=1, maxval=99, group=volGroup, tooltip="Bins at or below this percent of the highest-volume bin are marked as Low Volume Nodes.")
lvnWidth = input.int(1, title="LVN Line Width", minval=1, maxval=10, group=volGroup)

buyVolColor = input.color(color.new(#00c853, 0), title="Buy Volume Color", group=volGroup)
sellVolColor = input.color(color.new(#f44336, 0), title="Sell Volume Color", group=volGroup)

// ─── HELPERS ───
get_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.auto

// ─── STATE ───
var bool isActive = false
var int anchorBar = na
var float anchorTop = na
var float anchorBtm = na
var bool isBullState = false

var float actTop = na 
var float actBtm = na 
var int latestBar = na

var polyline currentPoly = na
var line topExtLine = na
var line btmExtLine = na
var label topExtLabel = na
var label btmExtLabel = na
var line[] imprintLines = array.new<line>() 
var line pocLine = na

// ─── MOMENTUM DETECTION ───
bool is_bux = barstate.isconfirmed and close > high[1]
bool is_bex = barstate.isconfirmed and close < low[1]

bool was_bux = close[1] > high[2]
bool was_bex = close[1] < low[2]
bool is_nbc = barstate.isconfirmed and close <= high[1] and close >= low[1]

bool startShape = false
int startAnchor = na

// ─── ANCHOR TRIGGER ───
if triggerMethod == "Immediate Body Close"
    if is_bux or is_bex
        startShape := true
        startAnchor := bar_index
else // Wait for NBC
    if is_nbc and (was_bux or was_bex)
        startShape := true
        startAnchor := bar_index[1] // anchor to the momentum candle, not the NBC

// ─── EXPANSION AND BREAKOUT ───
bool shapeJustBroken = false

if isActive and not startShape
    bool isBreakout = false
    bool touched = false
    
    if calcMethod == "Wait for Candle Close"
        if barstate.isconfirmed
            if close > actTop or close < actBtm
                isBreakout := true
            else
                if high >= actTop
                    actTop := high
                    touched := true
                if low <= actBtm
                    actBtm := low
                    touched := true
    else // Live (Tick-by-Tick)
        if close > actTop or close < actBtm
            isBreakout := true
        else
            if high >= actTop
                actTop := high
                touched := true
            if low <= actBtm
                actBtm := low
                touched := true
                
    if isBreakout
        isActive := false
        shapeJustBroken := true
    else if touched
        latestBar := bar_index

// ─── SHAPE INIT ───
if startShape
    isActive := true
    anchorBar := startAnchor
    
    float sOpen = startAnchor == bar_index ? open : open[1]
    float sClose = startAnchor == bar_index ? close : close[1]
    float sHigh = startAnchor == bar_index ? high : high[1]
    float sLow = startAnchor == bar_index ? low : low[1]
    
    isBullState := sClose >= sOpen
    color currentLineCol = isBullState ? bullLineColor : bearLineColor
    
    anchorTop := math.max(sOpen, sClose)
    anchorBtm := math.min(sOpen, sClose)
    
    actTop := sHigh
    actBtm := sLow
    latestBar := startAnchor
    
    if not na(currentPoly)
        polyline.delete(currentPoly)
    if not na(topExtLine)
        line.delete(topExtLine)
    if not na(btmExtLine)
        line.delete(btmExtLine)
    if not na(topExtLabel)
        label.delete(topExtLabel)
    if not na(btmExtLabel)
        label.delete(btmExtLabel)
    if not na(pocLine)
        line.delete(pocLine)
    if array.size(imprintLines) > 0
        for i = 0 to array.size(imprintLines) - 1
            line.delete(array.get(imprintLines, i))
        array.clear(imprintLines)
        
    topExtLine := line.new(latestBar, actTop, bar_index + line_ext, actTop, color=currentLineCol, width=extLineWidth, style=line.style_dotted)
    btmExtLine := line.new(latestBar, actBtm, bar_index + line_ext, actBtm, color=currentLineCol, width=extLineWidth, style=line.style_dotted)
    
    string tTxt = isBullState ? "RH TGT" : "RH"
    string bTxt = isBullState ? "RL" : "RL TGT"
    
    topExtLabel := label.new(bar_index + line_ext, actTop, tTxt, textcolor=currentLineCol, style=label.style_label_left, color=color.new(color.white, 100), size=get_size(lbl_size_lines))
    btmExtLabel := label.new(bar_index + line_ext, actBtm, bTxt, textcolor=currentLineCol, style=label.style_label_left, color=color.new(color.white, 100), size=get_size(lbl_size_lines))

// ─── RENDERING ───
if isActive or shapeJustBroken
    
    if not na(currentPoly)
        polyline.delete(currentPoly)
        
    int polyRightEdge = math.max(latestBar, anchorBar + 1)
        
    chart.point[] drawPts = array.new<chart.point>()
    array.push(drawPts, chart.point.from_index(anchorBar, anchorTop))
    array.push(drawPts, chart.point.from_index(polyRightEdge, actTop))
    array.push(drawPts, chart.point.from_index(polyRightEdge, actBtm))
    array.push(drawPts, chart.point.from_index(anchorBar, anchorBtm))
    
    color fillCol = isBullState ? color.new(bullPolyColor, boxTransparency) : color.new(bearPolyColor, boxTransparency)
    color transparentBorder = color.new(color.white, 100)
    
    currentPoly := polyline.new(drawPts, closed=true, fill_color=fillCol, line_color=transparentBorder)

    line.set_xy1(topExtLine, latestBar, actTop)
    line.set_xy2(topExtLine, bar_index + line_ext, actTop)
    label.set_xy(topExtLabel, bar_index + line_ext, actTop)
    
    line.set_xy1(btmExtLine, latestBar, actBtm)
    line.set_xy2(btmExtLine, bar_index + line_ext, actBtm)
    label.set_xy(btmExtLabel, bar_index + line_ext, actBtm)

    if array.size(imprintLines) > 0
        for i = 0 to array.size(imprintLines) - 1
            line.delete(array.get(imprintLines, i))
        array.clear(imprintLines)
    if not na(pocLine)
        line.delete(pocLine)

    if showVolumeImprint or showPOC
        float rangeSize = actTop - actBtm
        
        if rangeSize > 0
            float rangeInTicks = rangeSize / syminfo.mintick
            int adaptiveBins = math.max(5, math.min(100, math.round(rangeInTicks / ticksPerBin)))
            float binSize = rangeSize / adaptiveBins
            
            array<float> buyVols = array.new<float>(adaptiveBins, 0.0)
            array<float> sellVols = array.new<float>(adaptiveBins, 0.0)
            array<float> totalVols = array.new<float>(adaptiveBins, 0.0)
            
            float maxVol = 0.0
            int pocIndex = 0
            int barsBack = bar_index - anchorBar
            
            if barsBack >= 0
                for i = 0 to barsBack
                    float ch = high[i]
                    float cl = low[i]
                    float co = open[i]
                    float cc = close[i]
                    float cv = nz(volume[i], 0)
                    
                    float pm = cc - co
                    float pr = math.max(ch - cl, syminfo.mintick)
                    float bp = math.abs(pm) / pr
                    float wr = (ch - math.max(co, cc)) / pr
                    float sr = (math.min(co, cc) - cl) / pr
                    
                    float bv = 0.0
                    float sv = 0.0
                    
                    if pm > 0
                        bv := cv * math.max(0.1, math.min(0.9, 0.5 + (bp * 0.3) - (wr * 0.1)))
                        sv := cv - bv
                    else if pm < 0
                        sv := cv * math.max(0.1, math.min(0.9, 0.5 + (bp * 0.3) - (sr * 0.1)))
                        bv := cv - sv
                    else
                        bv := cv * 0.5
                        sv := cv * 0.5
                    
                    if pr > 0 and cv > 0
                        for j = 0 to adaptiveBins - 1
                            float binBtm = actBtm + (j * binSize)
                            float binTop = binBtm + binSize
                            
                            float overlapTop = math.min(ch, binTop)
                            float overlapBtm = math.max(cl, binBtm)
                            float overlap = math.max(0, overlapTop - overlapBtm)
                            
                            if overlap > 0
                                float oF = overlap / pr
                                array.set(buyVols, j, array.get(buyVols, j) + (bv * oF))
                                array.set(sellVols, j, array.get(sellVols, j) + (sv * oF))
                                
                                float newTotal = array.get(totalVols, j) + (cv * oF)
                                array.set(totalVols, j, newTotal)
                                
            for j = 0 to adaptiveBins - 1
                float v = array.get(totalVols, j)
                if v > maxVol
                    maxVol := v
                    pocIndex := j

            for j = 0 to adaptiveBins - 1
                float tVol = array.get(totalVols, j)
                if tVol > 0
                    float bVol = array.get(buyVols, j)
                    float sVol = array.get(sellVols, j)
                    
                    float binBtm = actBtm + (j * binSize)
                    float binTop = binBtm + binSize
                    float priceLvl = math.avg(binTop, binBtm)
                    bool isPOC = (j == pocIndex)
                    bool isHVN = not isPOC and tVol >= maxVol * hvnThreshold / 100
                    bool isLVN = not isPOC and tVol <= maxVol * lvnThreshold / 100
                    
                    bool levelIsBullish = bVol >= sVol
                    color levelColor = levelIsBullish ? buyVolColor : sellVolColor
                    
                    if isPOC and showPOC
                        pocLine := line.new(anchorBar, priceLvl, latestBar, priceLvl, color=levelColor, width=2)
                        
                    bool drawLevel = isPOC or (isHVN and showHVN) or (isLVN and showLVN) or (not isHVN and not isLVN)
                    
                    if showVolumeImprint and drawLevel
                        int bLen = math.max(1, math.round((tVol / math.max(maxVol, syminfo.mintick)) * vpMaxWidth))
                        int endLineBar = anchorBar + bLen
                        
                        int bWid = isPOC ? pocWidth : isHVN ? hvnWidth : isLVN ? lvnWidth : 2
                        
                        line profileLine = line.new(anchorBar, priceLvl, endLineBar, priceLvl, color=levelColor, width=bWid)
                        array.push(imprintLines, profileLine)
````
