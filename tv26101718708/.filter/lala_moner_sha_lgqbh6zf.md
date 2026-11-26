# lala moner sha

- url: https://www.tradingview.com/script/lgqbH6zf-lala-moner-sha/
- type: indicator
- pine_id: PUB;36699f52c31044d9b2a882c0b368c254
- version: 1.0

## Description

guys this will is best one i am using i am making money from it so maybe you guys can do also

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
indicator("Liquidity Grab, CSD & Focused Fibonacci", shorttitle="LGD+CSD+Fib", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// --- Group Constants ---
string G_LOGI = "Logic Settings"
string G_STYL = "Style Settings"
color  C_GOLD = #FFD700

// --- Inputs ---
pivotLen    = input.int(5, "Pivot Lookback", minval=1, group=G_LOGI)
maxGrabs    = input.int(1, "Max Grabs per Level", minval=1, group=G_LOGI)
levelExpiry = input.int(300, "Liquidity Level Expiry (Bars)", minval=1, group=G_LOGI)
csdLookback = input.int(10, "CSD Max Bars", minval=1, group=G_LOGI)
csdWait     = input.int(4, "Wait After CSD (Bars)", minval=0, group=G_LOGI)
zoneExpiry  = input.int(50, "Zone Expiry (Bars)", minval=1, group=G_LOGI)
maxZoneWidth = input.int(20, "Max Zone Width (Bars)", minval=1, group=G_LOGI, tooltip="Limits how far the FVG/Breaker boxes extend horizontally.")
oteSetting   = input.bool(false, "Optimal Trade Entry (OTE) Only", group=G_LOGI, tooltip="When enabled, the script only shows Golden Zone setups (where an FVG overlaps a Breaker) and only displays the entire setup after price touches the zone and then confirms via a continuation break.")
useHtfOb     = input.bool(false, "Filter by HTF Order Block", group=G_LOGI, tooltip="If enabled, liquidity grabs are only valid if they occur within a Higher Time Frame Order Block.")
htf          = input.timeframe("60", "HTF Timeframe", group=G_LOGI)

showFVG     = input.bool(true, "Show Imbalances (FVG)", group=G_STYL)
showBreaker = input.bool(true, "Show Breaker Blocks", group=G_STYL)
showFib     = input.bool(true, "Show Fibonacci on Pullback", group=G_STYL)
bullColor   = input.color(#089981, "Bullish Color", group=G_STYL, inline="Colors")
bearColor   = input.color(#f23645, "Bearish Color", group=G_STYL, inline="Colors")
levelColor  = input.color(color.gray, "Level Color", group=G_STYL)

// --- Types ---
type LiquidityLevel
    float price
    line  levelLine
    bool  isHigh
    int   creationBar
    int   grabCount = 0
    bool  active = true

type PendingCSD
    float grabPrice
    int   grabBar
    bool  isBullish
    int   expiryBar
    bool  active = true

type Zone
    box   boxId
    float top
    float bottom
    bool  isBullish
    int   grabBar
    float grabPrice
    int   csdBar
    int   creationBar
    bool  active = true
    bool  touched = false
    float extPrice = 0.0
    bool  drawn = false
    string zoneType = ""
    bool  isGolden = false

// --- Storage ---
var levels      = array.new<LiquidityLevel>(0)
var pendingCSDs = array.new<PendingCSD>(0)
var activeZones = array.new<Zone>(0)

// --- Helper: Draw Fib ---
drawFib(int startX, float startY, int endX, float endY, color col) =>
    float[] levels_val = array.from(0.0, 0.382, 0.5, 0.618, 0.705, 0.786, 1.0)
    float diff = endY - startY
    for l in levels_val
        float price = startY + diff * l
        line.new(startX, price, bar_index, price, color=color.new(col, 50), style=line.style_dotted)
        label.new(bar_index, price, str.tostring(l), color=#00000000, textcolor=col, style=label.style_label_left, size=size.tiny)

// --- HTF Order Block Logic ---
getHtfOB() =>
    bool hBullShift = ta.crossover(close, ta.highest(high[1], 5))
    bool hBearShift = ta.crossunder(close, ta.lowest(low[1], 5))
    float obH = na, float obL = na
    if hBullShift
        for i = 1 to 10
            if close[i] < open[i]
                obH := high[i], obL := low[i]
                break
    if hBearShift
        for i = 1 to 10
            if close[i] > open[i]
                obH := high[i], obL := low[i]
                break
    [obH, obL, hBullShift, hBearShift]

[hH, hL, bShift, rShift] = request.security(syminfo.tickerid, htf, getHtfOB(), lookahead = barmerge.lookahead_on)

var float htfBullOB_H = na, var float htfBullOB_L = na
var float htfBearOB_H = na, var float htfBearOB_L = na

if bShift
    htfBullOB_H := hH, htfBullOB_L := hL
if rShift
    htfBearOB_H := hH, htfBearOB_L := hL

// --- Core Logic ---
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

// --- Level Creation ---
if not na(ph)
    newLine = line.new(bar_index[pivotLen], ph, bar_index, ph, color=color.new(levelColor, 50), style=line.style_dashed)
    array.push(levels, LiquidityLevel.new(ph, newLine, true, bar_index[pivotLen]))
if not na(pl)
    newLine = line.new(bar_index[pivotLen], pl, bar_index, pl, color=color.new(levelColor, 50), style=line.style_dashed)
    array.push(levels, LiquidityLevel.new(pl, newLine, false, bar_index[pivotLen]))

// --- Level Processing ---
if array.size(levels) > 0
    for i = array.size(levels) - 1 to 0
        lvl = array.get(levels, i)
        if lvl.active
            if bar_index - lvl.creationBar > levelExpiry
                lvl.active := false
                line.delete(lvl.levelLine)
                continue
            line.set_x2(lvl.levelLine, bar_index)
            if lvl.isHigh
                if high > lvl.price and close <= lvl.price
                    bool inHtfOb = not useHtfOb or (high <= htfBearOB_H and high >= htfBearOB_L)
                    if inHtfOb
                        lvl.grabCount += 1
                        array.push(pendingCSDs, PendingCSD.new(high, bar_index, false, bar_index + csdLookback))
                        if lvl.grabCount >= maxGrabs
                            lvl.active := false
                else if close > lvl.price
                    lvl.active := false
                    line.set_color(lvl.levelLine, color.new(levelColor, 85))
            else
                if low < lvl.price and close >= lvl.price
                    bool inHtfOb = not useHtfOb or (low >= htfBullOB_L and low <= htfBullOB_H)
                    if inHtfOb
                        lvl.grabCount += 1
                        array.push(pendingCSDs, PendingCSD.new(low, bar_index, true, bar_index + csdLookback))
                        if lvl.grabCount >= maxGrabs
                            lvl.active := false
                else if close < lvl.price
                    lvl.active := false
                    line.set_color(lvl.levelLine, color.new(levelColor, 85))

// --- CSD & Focused Zone Creation ---
if array.size(pendingCSDs) > 0
    for i = array.size(pendingCSDs) - 1 to 0
        csd = array.get(pendingCSDs, i)
        if csd.active
            float csdTrigger = csd.isBullish ? high[bar_index - csd.grabBar] : low[bar_index - csd.grabBar]
            bool confirmed = csd.isBullish ? close > csdTrigger : close < csdTrigger
            
            if confirmed
                float bbTop = na, float bbBot = na
                int offBB = bar_index - csd.grabBar
                if showBreaker
                    if csd.isBullish and close[offBB + 1] > open[offBB + 1]
                        bbTop := high[offBB + 1], bbBot := low[offBB + 1]
                    else if not csd.isBullish and close[offBB + 1] < open[offBB + 1]
                        bbTop := high[offBB + 1], bbBot := low[offBB + 1]

                bool hasGoldenOverlap = false
                if not na(bbTop)
                    for k = csd.grabBar + 1 to bar_index
                        int offFVG = bar_index - k
                        if csd.isBullish and low[offFVG] > high[offFVG + 2]
                            if low[offFVG] > bbBot and high[offFVG + 2] < bbTop
                                hasGoldenOverlap := true
                                break
                        else if not csd.isBullish and high[offFVG] < low[offFVG + 2]
                            if high[offFVG] < bbTop and low[offFVG + 2] > bbBot
                                hasGoldenOverlap := true
                                break
                if oteSetting and not hasGoldenOverlap
                    csd.active := false
                    continue
                
                if not oteSetting
                    label.new(csd.grabBar, csd.grabPrice, "●", color=#00000000, textcolor=csd.isBullish ? bullColor : bearColor, style=label.style_label_center, size=size.small)
                    label.new(bar_index, csd.isBullish ? low : high, "CSD", color=csd.isBullish ? bullColor : bearColor, textcolor=chart.bg_color, style=csd.isBullish ? label.style_label_up : label.style_label_down, size=size.tiny)
                
                color dirColor = csd.isBullish ? bullColor : bearColor
                for k = csd.grabBar to bar_index
                    int off = bar_index - k
                    if showBreaker and k == csd.grabBar and not na(bbTop)
                        color zCol = hasGoldenOverlap ? C_GOLD : dirColor
                        box bId = na
                        if not oteSetting
                            bId := box.new(k - 1, bbTop, bar_index, bbBot, bgcolor=color.new(zCol, 75), border_color=zCol, text="BB", text_size=size.tiny, text_color=dirColor)
                        array.push(activeZones, Zone.new(bId, bbTop, bbBot, csd.isBullish, csd.grabBar, csd.grabPrice, bar_index, bar_index, true, false, 0.0, not oteSetting, "BB", hasGoldenOverlap))
                    
                    if showFVG and off + 2 <= bar_index and k > csd.grabBar
                        float fvgTop = na, float fvgBot = na
                        if csd.isBullish and low[off] > high[off + 2]
                            fvgTop := low[off], fvgBot := high[off + 2]
                        else if not csd.isBullish and high[off] < low[off + 2]
                            fvgTop := high[off], fvgBot := low[off + 2]
                        
                        if not na(fvgTop)
                            bool overlaps = not na(bbTop) and fvgTop > bbBot and fvgBot < bbTop
                            color zCol = overlaps ? C_GOLD : dirColor
                            box bId = na
                            if not oteSetting
                                bId := box.new(k - 2, fvgTop, bar_index, fvgBot, bgcolor=color.new(zCol, 75), border_color=zCol, text="FVG", text_size=size.tiny, text_color=dirColor)
                            array.push(activeZones, Zone.new(bId, fvgTop, fvgBot, csd.isBullish, csd.grabBar, csd.grabPrice, bar_index, bar_index, true, false, 0.0, not oteSetting, "FVG", overlaps))
                csd.active := false
            if bar_index >= csd.expiryBar
                csd.active := false

// --- Zone Management & Fibonacci Pullback ---
if array.size(activeZones) > 0
    for i = array.size(activeZones) - 1 to 0
        z = array.get(activeZones, i)
        if z.active
            if not na(z.boxId)
                int currentWidth = bar_index - box.get_left(z.boxId)
                if currentWidth < maxZoneWidth
                    box.set_right(z.boxId, bar_index)
            
            if not z.drawn and bar_index >= z.csdBar + csdWait
                // 1. Check for initial touch
                if not z.touched
                    bool touch = z.isBullish ? low <= z.top : high >= z.bottom
                    if touch
                        z.touched := true
                        float ext = z.isBullish ? high[bar_index - z.csdBar] : low[bar_index - z.csdBar]
                        for j = z.csdBar to bar_index
                            float h = high[bar_index - j], l = low[bar_index - j]
                            if z.isBullish
                                if h > ext 
                                    ext := h
                            else
                                if l < ext 
                                    ext := l
                        z.extPrice := ext
                
                // 2. Plotting Logic
                if z.touched
                    bool shouldPlot = false
                    if oteSetting
                        // Wait for continuation: Price closes beyond Point B in the trade direction
                        shouldPlot := z.isBullish ? close > z.extPrice : close < z.extPrice
                    else
                        shouldPlot := true
                    
                    if shouldPlot
                        // Create Labels and Boxes if they don't exist
                        if na(z.boxId)
                            color dirColor = z.isBullish ? bullColor : bearColor
                            color zCol = z.isGolden ? C_GOLD : dirColor
                            int x1 = z.zoneType == "BB" ? z.csdBar - 1 : z.creationBar - 2
                            z.boxId := box.new(x1, z.top, bar_index, z.bottom, bgcolor=color.new(zCol, 75), border_color=zCol, text=z.zoneType, text_size=size.tiny, text_color=dirColor)
                            
                            // To avoid duplicate setup labels (Dot and CSD) for the same CSD bar, 
                            // we only draw them for the first zone found for that CSD.
                            bool firstZone = true
                            for prevZ in activeZones
                                if prevZ.csdBar == z.csdBar and prevZ.drawn
                                    firstZone := false
                                    break
                            
                            if firstZone
                                label.new(z.grabBar, z.grabPrice, "●", color=#00000000, textcolor=z.isBullish ? bullColor : bearColor, style=label.style_label_center, size=size.small)
                                label.new(z.csdBar, z.isBullish ? low[bar_index - z.csdBar] : high[bar_index - z.csdBar], "CSD", color=z.isBullish ? bullColor : bearColor, textcolor=chart.bg_color, style=z.isBullish ? label.style_label_up : label.style_label_down, size=size.tiny)
                                
                                // --- Position & SL Visualization ---
                                line.new(bar_index, close, bar_index + 10, close, color = z.isBullish ? bullColor : bearColor, width = 2)
                                label.new(bar_index + 10, close, "Entry: " + str.tostring(close, format.mintick), style = label.style_none, textcolor = z.isBullish ? bullColor : bearColor, size = size.small)
                                
                                line.new(bar_index, z.grabPrice, bar_index + 10, z.grabPrice, color = z.isBullish ? bearColor : bullColor, width = 2, style = line.style_dashed)
                                label.new(bar_index + 10, z.grabPrice, "SL: " + str.tostring(z.grabPrice, format.mintick), style = label.style_none, textcolor = z.isBullish ? bearColor : bullColor, size = size.small)



                                float risk = math.abs(close - z.grabPrice)
                                float tpPrice = z.isBullish ? close + (risk * 2) : close - (risk * 2)
                                line.new(bar_index, tpPrice, bar_index + 10, tpPrice, color = #089981, width = 2, style = line.style_dotted)
                                label.new(bar_index + 10, tpPrice, "TP (1:2): " + str.tostring(tpPrice, format.mintick), style = label.style_none, textcolor = #089981, size = size.small)

                if not na(z.boxId)
                    box.set_bgcolor(z.boxId, color.new(color.gray, 95)), box.set_border_color(z.boxId, color.new(color.gray, 95))

// --- Clean Up ---
if array.size(levels) > 100
    array.shift(levels)
if array.size(activeZones) > 50
    array.shift(activeZones)
````
