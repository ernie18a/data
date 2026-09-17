<!-- tradingview-pine-id: PUB;42e65278fb03460b9e3e880c67ea269f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Zen [LTW] v0.5

Source: https://www.tradingview.com/script/w1GEXEwn/

## Description

📊 Zen [LTW] v0.5

Zen (禪) translates to "Seon" (Line) in Korean. Inspired by homonyms that share the same pronunciation but have different meanings, this is an indicator that automatically draws lines by directly identifying meaningful points—the fundamental condition for drawing a line—specifically between two or more highs, or two or more lows.

When candles touch the created line 3 times, the line transforms into a plane (zone). This makes it easier to flexibly manage stop losses caused by psychological fluctuations that rely purely on intuition based on a single, baseless thin line.

---

⚙️Key Features

▪️Drag & Drop Time Range
[image]https://www.tradingview.com/x/7APrdKY3/[/image]
You do not need to complexly count the number of candles. By specifying the 'Start Point' and 'End Point' times in the settings window, you can extract the S/R (Support/Resistance) within your desired specific session.

▪️Min Pivot Confirmation
If it receives support/resistance at least N times within a margin of error, rather than being an accidentally formed high/low, it can become a strong resistance zone. However, if it breaks through only with a large candle without trading volume, a sweeping movement may occur, absorbing liquidity and pushing retail investors attempting breakout trading out of their positions beyond the line. Such lines are formed into planes (zones) according to the set number of Pivot values (e.g., 3). Counter-trend trading can also be executed as long as the price does not deviate from this plane area.

▪️Info Icons
Markers are displayed at the start and end points, respectively, allowing you to grasp the analysis section at a glance. If the End Point is unchecked, the end point becomes the currently forming candle, so the marker will only appear at the manually selected start point.

Hovering the mouse cursor over the icon allows you to check detailed information via a tooltip, such as the number of bars in that section and the number of identified support/resistance pivots.

▪️3 Independent Analysis Zones
Provides a total of 3 independent systems: Zen 1, Zen 2, and Zen 3. You can simultaneously analyze short-, medium-, and long-term trends or support/resistance of different periods on a single chart and express them in different colors.

---

📌 Settings Guide

1. Drag Start Point / End Point: Sets the reference times to start and end the analysis.

2. Pivot Strength: The number of left and right candles that serve as a standard when identifying pivots (highs/lows). The higher the number, the larger the swing highs/lows it finds.

3. Min Pivot Confirmation: The minimum number of touches (confirmations) required for the identified virtual line to be recognized as a support/resistance zone. The higher the number, the stricter the conditions, outputting only highly reliable lines.

4. Icon Vertical Gap: Adjusts the height to float the analysis start/end marker icons so they do not overlap with the candles.

5. Right Extension Bars: Determines how many more candles to the right to extend and draw the identified support/resistance zone based on the current candle. This is useful for capturing future entry/exit timing points.

---

🔥 Practical Trading Tips (Cautions)

This indicator does not provide standalone entry signals (Buy/Sell) like those used by indicator sellers. Please use it as a basis for Breakout or Bounce trading strategies by combining it with price action (candle patterns like pin bars, engulfing, etc.) or volume indicators near the identified support/resistance zones.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Zen [LTW] v0.5", overlay = true, max_lines_count = 500)

// ─────────────────────────────
// 1. ZEN 1 SETTINGS
// ─────────────────────────────
grp1 = "Zen 1 Settings"
en1        = input.bool(true, "Enable Zen 1", group = grp1)
showLabel1 = input.bool(true, "Show Info Icons 1", group = grp1)
iconMark1  = input.string("🔵", "Marker Icon 1", options = ["🔵", "🟢", "🟡", "🟠", "🟣", "🟤", "🔴", "⚫", "⚪"], group = grp1)
iconSize1  = input.string("Tiny", "Icon Size 1", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp1)
lblOffset1 = input.float(0.5, "Icon Vertical Gap 1", minval=0.0, step=0.1, group = grp1)
startTime1 = input.time(timestamp("2026-08-28 10:30"), "[ZEN 1] Drag Start Point", confirm = true, group = grp1)
enEnd1     = input.bool(false, "Enable End Point 1", group = grp1)
endTime1   = input.time(timestamp("2026-01-01 00:00"), "End Point 1 (Ignored if unchecked)", tooltip="If unchecked, the current real-time candle is automatically used as the end point.", group = grp1) 
pSrc1      = input.string("High/Low", "Pivot Source 1", options = ["High/Low", "Close"], group = grp1)
pStr1      = input.int(10, "Pivot Strength 1", minval = 5, maxval = 15, group = grp1)
mTouch1    = input.int(3, "Min Pivot Confirmation 1", minval = 2, maxval = 8, group = grp1)
resCol1    = input.color(color.new(#4a4a4a, 50), "Resistance Line Color 1", group = grp1)
supCol1    = input.color(color.new(#4a4a4a, 50), "Support Line Color 1", group = grp1)
lineW1     = input.int(1,  "Line Width 1", minval = 1, maxval = 10, group = grp1)
zTransp1   = input.int(50, "Zone Transparency 1", minval = 0, maxval = 100, group = grp1)
extB1      = input.int(80, "Right Extension Bars 1 (From current candle)", minval = 0, group = grp1)

// ─────────────────────────────
// 2. ZEN 2 SETTINGS
// ─────────────────────────────
grp2 = "Zen 2 Settings"
en2        = input.bool(false, "Enable Zen 2", group = grp2)
showLabel2 = input.bool(true, "Show Info Icons 2", group = grp2)
iconMark2  = input.string("🔴", "Marker Icon 2", options = ["🔵", "🟢", "🟡", "🟠", "🟣", "🟤", "🔴", "⚫", "⚪"], group = grp2)
iconSize2  = input.string("Tiny", "Icon Size 2", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp2)
lblOffset2 = input.float(1.0, "Icon Vertical Gap 2", minval=0.0, step=0.1, group = grp2)
startTime2 = input.time(timestamp("2026-08-28 10:30"), "[ZEN 2] Drag Start Point", confirm = true, group = grp2)
enEnd2     = input.bool(false, "Enable End Point 2", group = grp2)
endTime2   = input.time(timestamp("2026-01-01 00:00"), "End Point 2 (Ignored if unchecked)", tooltip="If unchecked, the current real-time candle is automatically used as the end point.", group = grp2) 
pSrc2      = input.string("High/Low", "Pivot Source 2", options = ["High/Low", "Close"], group = grp2)
pStr2      = input.int(15, "Pivot Strength 2", minval = 5, maxval = 15, group = grp2)
mTouch2    = input.int(3, "Min Pivot Confirmation 2", minval = 2, maxval = 8, group = grp2)
resCol2    = input.color(color.new(#f23645, 50), "Resistance Line Color 2", group = grp2)
supCol2    = input.color(color.new(#089981, 50), "Support Line Color 2", group = grp2)
lineW2     = input.int(1,  "Line Width 2", minval = 1, maxval = 10, group = grp2)
zTransp2   = input.int(50, "Zone Transparency 2", minval = 0, maxval = 100, group = grp2)
extB2      = input.int(80, "Right Extension Bars 2 (From current candle)", minval = 0, group = grp2)

// ─────────────────────────────
// 3. ZEN 3 SETTINGS
// ─────────────────────────────
grp3 = "Zen 3 Settings"
en3        = input.bool(false, "Enable Zen 3", group = grp3)
showLabel3 = input.bool(true, "Show Info Icons 3", group = grp3)
iconMark3  = input.string("⚫", "Marker Icon 3", options = ["🔵", "🟢", "🟡", "🟠", "🟣", "🟤", "🔴", "⚫", "⚪"], group = grp3)
iconSize3  = input.string("Tiny", "Icon Size 3", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp3)
lblOffset3 = input.float(1.5, "Icon Vertical Gap 3", minval=0.0, step=0.1, group = grp3)
startTime3 = input.time(timestamp("2026-08-28 10:30"), "[ZEN 3] Drag Start Point", confirm = true, group = grp3)
enEnd3     = input.bool(false, "Enable End Point 3", group = grp3)
endTime3   = input.time(timestamp("2026-01-01 00:00"), "End Point 3 (Ignored if unchecked)", tooltip="If unchecked, the current real-time candle is automatically used as the end point.", group = grp3) 
pSrc3      = input.string("High/Low", "Pivot Source 3", options = ["High/Low", "Close"], group = grp3)
pStr3      = input.int(5, "Pivot Strength 3", minval = 5, maxval = 15, group = grp3)
mTouch3    = input.int(3, "Min Pivot Confirmation 3", minval = 2, maxval = 8, group = grp3)
resCol3    = input.color(color.new(#9c27b0, 50), "Resistance Line Color 3", group = grp3)
supCol3    = input.color(color.new(color.yellow, 50), "Support Line Color 3", group = grp3)
lineW3     = input.int(1,  "Line Width 3", minval = 1, maxval = 10, group = grp3)
zTransp3   = input.int(50, "Zone Transparency 3", minval = 0, maxval = 100, group = grp3)
extB3      = input.int(80, "Right Extension Bars 3 (From current candle)", minval = 0, group = grp3)


// ─────────────────────────────
// 4. CONSTANTS & HELPER FUNCTIONS
// ─────────────────────────────
float atr = ta.atr(14)
float maxThreshold = atr * 0.5  
int FIXED_STABILITY = 5 

getIconSize(string sz) =>
    string out = size.normal
    if sz == "Tiny"
        out := size.tiny
    if sz == "Small"
        out := size.small
    if sz == "Large"
        out := size.large
    if sz == "Huge"
        out := size.huge
    out

collectPivots(bool _en, int _pStr, string _pSrc, int _sTime, bool _enEnd, int _eTime, float[] _phP, int[] _phI, int[] _phT, float[] _plP, int[] _plI, int[] _plT) =>
    if _en
        float srcH = high
        float srcL = low
        if _pSrc == "Close"
            srcH := close
            srcL := close
        float ph = ta.pivothigh(srcH, _pStr, _pStr)
        float pl = ta.pivotlow(srcL, _pStr, _pStr)
        int pTime = time[_pStr]
        int pivotBarIdx = bar_index - _pStr
        
        if not na(ph) and pTime >= _sTime
            if not _enEnd or pTime <= _eTime
                int arrSizeH = array.size(_phI)
                if arrSizeH == 0 or array.get(_phI, arrSizeH - 1) != pivotBarIdx
                    array.push(_phP, ph)
                    array.push(_phI, pivotBarIdx)
                    array.push(_phT, pTime)
                    
        if not na(pl) and pTime >= _sTime
            if not _enEnd or pTime <= _eTime
                int arrSizeL = array.size(_plI)
                if arrSizeL == 0 or array.get(_plI, arrSizeL - 1) != pivotBarIdx
                    array.push(_plP, pl)
                    array.push(_plI, pivotBarIdx)
                    array.push(_plT, pTime)

// ─────────────────────────────
// 5. DATA TRACKING & STORAGE
// ─────────────────────────────
// Zen 1
var int sIdx1 = na, var int sTime1 = na, var float pHigh1 = na, var int eIdx1 = na, var int eTime1 = na, var float eClose1 = na, var float eHigh1 = na
var label sLbl1 = na, var label eLbl1 = na
var float[] phP1 = array.new_float(0), var int[] phI1 = array.new_int(0), var int[] phT1 = array.new_int(0)
var float[] plP1 = array.new_float(0), var int[] plI1 = array.new_int(0), var int[] plT1 = array.new_int(0)

// Zen 2
var int sIdx2 = na, var int sTime2 = na, var float pHigh2 = na, var int eIdx2 = na, var int eTime2 = na, var float eClose2 = na, var float eHigh2 = na
var label sLbl2 = na, var label eLbl2 = na
var float[] phP2 = array.new_float(0), var int[] phI2 = array.new_int(0), var int[] phT2 = array.new_int(0)
var float[] plP2 = array.new_float(0), var int[] plI2 = array.new_int(0), var int[] plT2 = array.new_int(0)

// Zen 3
var int sIdx3 = na, var int sTime3 = na, var float pHigh3 = na, var int eIdx3 = na, var int eTime3 = na, var float eClose3 = na, var float eHigh3 = na
var label sLbl3 = na, var label eLbl3 = na
var float[] phP3 = array.new_float(0), var int[] phI3 = array.new_int(0), var int[] phT3 = array.new_int(0)
var float[] plP3 = array.new_float(0), var int[] plI3 = array.new_int(0), var int[] plT3 = array.new_int(0)

var line[] allLines = array.new_line(0)
var linefill[] allFills = array.new_linefill(0)

var int[]   g_barIdx = array.new_int(0)
var float[] g_bodyTop = array.new_float(0)
var float[] g_bodyBot = array.new_float(0)

// ─────────────────────────────
// 6. UPDATE TRACKERS & COLLECT DATA
// ─────────────────────────────
int sz = array.size(g_barIdx)
float bTop = open > close ? open : close
float bBot = open < close ? open : close

if sz == 0 or array.get(g_barIdx, sz - 1) != bar_index
    array.push(g_barIdx, bar_index)
    array.push(g_bodyTop, bTop)
    array.push(g_bodyBot, bBot)
else
    array.set(g_bodyTop, sz - 1, bTop)
    array.set(g_bodyBot, sz - 1, bBot)

if en1 and time >= startTime1
    if na(sIdx1)
        sIdx1 := bar_index
        sTime1 := time
    if not enEnd1 or time <= endTime1
        if na(pHigh1) or high > pHigh1
            pHigh1 := high
if en1 and enEnd1 and time >= endTime1
    if na(eIdx1)
        eIdx1 := bar_index
        eTime1 := time
        eClose1 := close
        eHigh1 := high
collectPivots(en1, pStr1, pSrc1, startTime1, enEnd1, endTime1, phP1, phI1, phT1, plP1, plI1, plT1)

if en2 and time >= startTime2
    if na(sIdx2)
        sIdx2 := bar_index
        sTime2 := time
    if not enEnd2 or time <= endTime2
        if na(pHigh2) or high > pHigh2
            pHigh2 := high
if en2 and enEnd2 and time >= endTime2
    if na(eIdx2)
        eIdx2 := bar_index
        eTime2 := time
        eClose2 := close
        eHigh2 := high
collectPivots(en2, pStr2, pSrc2, startTime2, enEnd2, endTime2, phP2, phI2, phT2, plP2, plI2, plT2)

if en3 and time >= startTime3
    if na(sIdx3)
        sIdx3 := bar_index
        sTime3 := time
    if not enEnd3 or time <= endTime3
        if na(pHigh3) or high > pHigh3
            pHigh3 := high
if en3 and enEnd3 and time >= endTime3
    if na(eIdx3)
        eIdx3 := bar_index
        eTime3 := time
        eClose3 := close
        eHigh3 := high
collectPivots(en3, pStr3, pSrc3, startTime3, enEnd3, endTime3, phP3, phI3, phT3, plP3, plI3, plT3)

// ─────────────────────────────
// 7. ZONE FINDER ALGORITHM
// ─────────────────────────────
findZone(float[] prices, int[] indices, int[] times, color lineCol, int _zTransp, bool isRes, int tIdx, float tClose, int _mTouch, int _extB, int lW, int cTime, int tStep) =>
    int size = array.size(prices)
    float minDistance = 1e10 
    bool found = false
    int bestP1x = 0
    int bestP1time = 0
    int bestTouches = 0
    float bestP1y = 0.0, bestSlope = 0.0, bestMaxUp = 0.0, bestMaxDown = 0.0

    if size >= _mTouch
        int start_i = size - 100
        if start_i < 0
            start_i := 0
            
        for i = start_i to size - 2
            float p1_y = array.get(prices, i)
            int   p1_x = array.get(indices, i)
            
            for j = i + 1 to size - 1
                float p2_y = array.get(prices, j)
                int   p2_x = array.get(indices, j)
                
                if p1_x == p2_x
                    continue
                    
                float slope = (p2_y - p1_y) / (p2_x - p1_x)
                int touches = 0
                bool isBroken = false
                float currentMaxUp = 0.0, currentMaxDown = 0.0
                
                for k = i to size - 1
                    int pk_x = array.get(indices, k)
                    float pk_y = array.get(prices, k)
                    float expected_y = p1_y + slope * (pk_x - p1_x)
                    float diff = pk_y - expected_y
                    
                    if math.abs(diff) <= maxThreshold
                        touches += 1
                        if diff > currentMaxUp 
                            currentMaxUp := diff
                        if diff < currentMaxDown 
                            currentMaxDown := diff
                    
                    if pk_x < (tIdx - FIXED_STABILITY)
                        if isRes and diff > maxThreshold
                            isBroken := true
                            break
                        if not isRes and diff < -maxThreshold
                            isBroken := true
                            break

                if touches >= _mTouch and not isBroken
                    bool bodyCut = false
                    int tBars = array.size(g_barIdx)
                    if tBars > 0
                        int start_b = p1_x - array.get(g_barIdx, 0) 
                        if start_b < 0
                            start_b := 0
                        if start_b > tBars - 1
                            start_b := tBars - 1
                            
                        for b = start_b to tBars - 1
                            int b_x = array.get(g_barIdx, b)
                            if b_x > tIdx
                                break 
                            if b_x >= p1_x
                                float b_top = array.get(g_bodyTop, b)
                                float b_bot = array.get(g_bodyBot, b)
                                float b_y = p1_y + slope * (b_x - p1_x)
                                if b_y < b_top and b_y > b_bot
                                    bodyCut := true
                                    break
                    
                    if not bodyCut
                        float cur_proj_y = p1_y + slope * (tIdx - p1_x)
                        float dist = math.abs(cur_proj_y - tClose) 
                        
                        if dist < minDistance
                            minDistance := dist
                            bestP1x := p1_x
                            bestP1time := array.get(times, i)
                            bestP1y := p1_y
                            bestSlope := slope
                            bestMaxUp := currentMaxUp
                            bestMaxDown := currentMaxDown
                            bestTouches := touches 
                            found := true

    if found
        int drawX2 = last_bar_index + _extB
        float drawEndYTop = bestP1y + bestSlope * (drawX2 - bestP1x) + bestMaxUp
        float drawEndYBot = bestP1y + bestSlope * (drawX2 - bestP1x) + bestMaxDown
        
        int drawX2Time = cTime + tStep * _extB

        l_top = line.new(bestP1time, bestP1y + bestMaxUp, drawX2Time, drawEndYTop, xloc=xloc.bar_time, color=lineCol, width=lW)
        l_bot = line.new(bestP1time, bestP1y + bestMaxDown, drawX2Time, drawEndYBot, xloc=xloc.bar_time, color=lineCol, width=lW)
        color fillCol = color.new(lineCol, _zTransp)
        fill  = linefill.new(l_top, l_bot, color=fillCol)
        
        array.push(allLines, l_top)
        array.push(allLines, l_bot)
        array.push(allFills, fill)

    bestTouches

// ─────────────────────────────
// 8. RENDER ALL ZEN (LAST BAR)
// ─────────────────────────────
if barstate.islast
    if array.size(allLines) > 0
        for l in allLines
            line.delete(l)
        array.clear(allLines)
    if array.size(allFills) > 0
        for f in allFills
            linefill.delete(f)
        array.clear(allFills)
        
    int tStep = time - nz(time[1], time - 60000)

    if en1 and not na(sIdx1)
        int tIdx1 = last_bar_index
        float tClose1 = close
        if enEnd1 and not na(eIdx1)
            tIdx1 := eIdx1, tClose1 := eClose1
            
        int resT1 = findZone(phP1, phI1, phT1, resCol1, zTransp1, true, tIdx1, tClose1, mTouch1, extB1, lineW1, time, tStep)
        int supT1 = findZone(plP1, plI1, plT1, supCol1, zTransp1, false, tIdx1, tClose1, mTouch1, extB1, lineW1, time, tStep)
        
        if showLabel1
            string cSize1 = getIconSize(iconSize1)
            int bCnt1 = tIdx1 - sIdx1
            string dStr1 = str.tostring(year(startTime1, syminfo.timezone)%100,"00")+"/"+str.tostring(month(startTime1, syminfo.timezone),"00")+"/"+str.tostring(dayofmonth(startTime1, syminfo.timezone),"00")+" "+str.tostring(hour(startTime1, syminfo.timezone),"00")+":"+str.tostring(minute(startTime1, syminfo.timezone),"00")
            string tTxt1 = "Start: " + dStr1
            if enEnd1 and not na(eIdx1)
                string eStr1 = str.tostring(year(endTime1, syminfo.timezone)%100,"00")+"/"+str.tostring(month(endTime1, syminfo.timezone),"00")+"/"+str.tostring(dayofmonth(endTime1, syminfo.timezone),"00")+" "+str.tostring(hour(endTime1, syminfo.timezone),"00")+":"+str.tostring(minute(endTime1, syminfo.timezone),"00")
                tTxt1 := tTxt1 + "\nEnd: " + eStr1
            tTxt1 := tTxt1 + "\n(" + str.tostring(bCnt1) + " bars)"
            if resT1 > 0
                tTxt1 := tTxt1 + "\nRes Pivots: " + str.tostring(resT1)
            if supT1 > 0
                tTxt1 := tTxt1 + "\nSup Pivots: " + str.tostring(supT1)
                
            float dY1 = pHigh1 + (atr * lblOffset1)
            if na(sLbl1)
                sLbl1 := label.new(x=sTime1, y=dY1, text=iconMark1, tooltip=tTxt1, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, size=cSize1)
            else
                label.set_text(sLbl1, iconMark1), label.set_tooltip(sLbl1, tTxt1), label.set_xy(sLbl1, sTime1, dY1), label.set_size(sLbl1, cSize1)
                
            if enEnd1 and not na(eIdx1)
                float eY1 = eHigh1 + (atr * lblOffset1)
                if na(eLbl1)
                    eLbl1 := label.new(x=eTime1, y=eY1, text=iconMark1, tooltip="End Point 1", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, size=cSize1)
                else
                    label.set_text(eLbl1, iconMark1), label.set_xy(eLbl1, eTime1, eY1), label.set_size(eLbl1, cSize1)
            else
                if not na(eLbl1)
                    label.delete(eLbl1), eLbl1 := na
        else
            if not na(sLbl1)
                label.delete(sLbl1), sLbl1 := na
            if not na(eLbl1)
                label.delete(eLbl1), eLbl1 := na

    if en2 and not na(sIdx2)
        int tIdx2 = last_bar_index
        float tClose2 = close
        if enEnd2 and not na(eIdx2)
            tIdx2 := eIdx2, tClose2 := eClose2
            
        int resT2 = findZone(phP2, phI2, phT2, resCol2, zTransp2, true, tIdx2, tClose2, mTouch2, extB2, lineW2, time, tStep)
        int supT2 = findZone(plP2, plI2, plT2, supCol2, zTransp2, false, tIdx2, tClose2, mTouch2, extB2, lineW2, time, tStep)
        
        if showLabel2
            string cSize2 = getIconSize(iconSize2)
            int bCnt2 = tIdx2 - sIdx2
            string dStr2 = str.tostring(year(startTime2, syminfo.timezone)%100,"00")+"/"+str.tostring(month(startTime2, syminfo.timezone),"00")+"/"+str.tostring(dayofmonth(startTime2, syminfo.timezone),"00")+" "+str.tostring(hour(startTime2, syminfo.timezone),"00")+":"+str.tostring(minute(startTime2, syminfo.timezone),"00")
            string tTxt2 = "Start: " + dStr2
            if enEnd2 and not na(eIdx2)
                string eStr2 = str.tostring(year(endTime2, syminfo.timezone)%100,"00")+"/"+str.tostring(month(endTime2, syminfo.timezone),"00")+"/"+str.tostring(dayofmonth(endTime2, syminfo.timezone),"00")+" "+str.tostring(hour(endTime2, syminfo.timezone),"00")+":"+str.tostring(minute(endTime2, syminfo.timezone),"00")
                tTxt2 := tTxt2 + "\nEnd: " + eStr2
            tTxt2 := tTxt2 + "\n(" + str.tostring(bCnt2) + " bars)"
            
            float dY2 = pHigh2 + (atr * lblOffset2)
            if na(sLbl2)
                sLbl2 := label.new(x=sTime2, y=dY2, text=iconMark2, tooltip=tTxt2, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, size=cSize2)
            else
                label.set_text(sLbl2, iconMark2), label.set_tooltip(sLbl2, tTxt2), label.set_xy(sLbl2, sTime2, dY2), label.set_size(sLbl2, cSize2)
                
            if enEnd2 and not na(eIdx2)
                float eY2 = eHigh2 + (atr * lblOffset2)
                if na(eLbl2)
                    eLbl2 := label.new(x=eTime2, y=eY2, text=iconMark2, tooltip="End Point 2", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, size=cSize2)
                else
                    label.set_text(eLbl2, iconMark2), label.set_xy(eLbl2, eTime2, eY2), label.set_size(eLbl2, cSize2)
            else
                if not na(eLbl2)
                    label.delete(eLbl2), eLbl2 := na
        else
            if not na(sLbl2)
                label.delete(sLbl2), sLbl2 := na
            if not na(eLbl2)
                label.delete(eLbl2), eLbl2 := na

    if en3 and not na(sIdx3)
        int tIdx3 = last_bar_index
        float tClose3 = close
        if enEnd3 and not na(eIdx3)
            tIdx3 := eIdx3, tClose3 := eClose3
            
        int resT3 = findZone(phP3, phI3, phT3, resCol3, zTransp3, true, tIdx3, tClose3, mTouch3, extB3, lineW3, time, tStep)
        int supT3 = findZone(plP3, plI3, plT3, supCol3, zTransp3, false, tIdx3, tClose3, mTouch3, extB3, lineW3, time, tStep)
        
        if showLabel3
            string cSize3 = getIconSize(iconSize3)
            int bCnt3 = tIdx3 - sIdx3
            string dStr3 = str.tostring(year(startTime3, syminfo.timezone)%100,"00")+"/"+str.tostring(month(startTime3, syminfo.timezone),"00")+"/"+str.tostring(dayofmonth(startTime3, syminfo.timezone),"00")+" "+str.tostring(hour(startTime3, syminfo.timezone),"00")+":"+str.tostring(minute(startTime3, syminfo.timezone),"00")
            string tTxt3 = "Start: " + dStr3
            if enEnd3 and not na(eIdx3)
                string eStr3 = str.tostring(year(endTime3, syminfo.timezone)%100,"00")+"/"+str.tostring(month(endTime3, syminfo.timezone),"00")+"/"+str.tostring(dayofmonth(endTime3, syminfo.timezone),"00")+" "+str.tostring(hour(endTime3, syminfo.timezone),"00")+":"+str.tostring(minute(endTime3, syminfo.timezone),"00")
                tTxt3 := tTxt3 + "\nEnd: " + eStr3
            tTxt3 := tTxt3 + "\n(" + str.tostring(bCnt3) + " bars)"
            
            float dY3 = pHigh3 + (atr * lblOffset3)
            if na(sLbl3)
                sLbl3 := label.new(x=sTime3, y=dY3, text=iconMark3, tooltip=tTxt3, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, size=cSize3)
            else
                label.set_text(sLbl3, iconMark3), label.set_tooltip(sLbl3, tTxt3), label.set_xy(sLbl3, sTime3, dY3), label.set_size(sLbl3, cSize3)
                
            if enEnd3 and not na(eIdx3)
                float eY3 = eHigh3 + (atr * lblOffset3)
                if na(eLbl3)
                    eLbl3 := label.new(x=eTime3, y=eY3, text=iconMark3, tooltip="End Point 3", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, size=cSize3)
                else
                    label.set_text(eLbl3, iconMark3), label.set_xy(eLbl3, eTime3, eY3), label.set_size(eLbl3, cSize3)
            else
                if not na(eLbl3)
                    label.delete(eLbl3), eLbl3 := na
        else
            if not na(sLbl3)
                label.delete(sLbl3), sLbl3 := na
            if not na(eLbl3)
                label.delete(eLbl3), eLbl3 := na
````
