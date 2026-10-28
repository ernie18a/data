# Live Footprint Center Frame

- url: https://www.tradingview.com/script/rLHG79gI-Live-Footprint-Center-Frame/
- type: indicator
- pine_id: PUB;78e25c10d96e4aa598022a859f5a6914
- version: 1.0

## Description

📊 Live Footprint Center Frame

Live Footprint Center Frame is a footprint-style chart overlay designed to help traders study candle-by-candle volume behavior directly on the main chart. The script displays centered footprint frames around candles and breaks each candle into multiple price slots so volume structure can be viewed more clearly.

🔎 What It Does

The script visualizes estimated internal candle activity using lower-timeframe OHLCV data. It displays price-slot volume, delta behavior, POC, value area, imbalance markings, absorption-style highlights, delta bars, POC trail, and a compact HUD panel for quick market structure reading.

Key visual elements include:

• Footprint-style candle frames  
• Price-slot volume ladder  
• Estimated ask/bid style cell values  
• Positive and negative delta coloring  
• POC highlight  
• Value Area highlight  
• Imbalance arrows  
• Absorption-style border highlights  
• Small delta bar below candles  
• POC trail between candles  
• Compact HUD with ASK, BID, DEL, POC, VA, VOL, CVD, and bias information  

🧠 General Logic

Live Footprint Center Frame uses lower-timeframe OHLCV data to approximate how volume is distributed inside each candle. The script divides the candle range into price slots, distributes lower-timeframe volume across those slots, and then calculates estimated delta, total volume, POC, value area, and balance information.

This is not true exchange-level bid/ask footprint data. It is an educational footprint-style approximation based on the data available through TradingView.

📌 Why It Is Useful

This tool can help traders study more than just candle open, high, low, and close. It gives a clearer visual view of where volume activity is concentrated inside the candle and how that activity changes from candle to candle.

It can be useful for observing:

• Where volume is concentrated  
• How POC shifts between candles  
• Whether delta supports or disagrees with price movement  
• Where value area develops inside the candle  
• Whether activity appears balanced or imbalanced  
• Possible absorption-style areas  
• Short-term volume structure around important price zones  

🎨 Visual Reading Guide

Green-style cells show stronger positive delta behavior.  
Red-style cells show stronger negative delta behavior.  
Orange areas highlight the POC zone.  
Blue-style areas highlight the value area.  
Yellow borders can show absorption-style conditions.  
Small delta bars below candles show candle delta direction and strength.  
The HUD gives a quick summary of ASK, BID, DEL, POC, VA, VOL, CVD, and bias.

🧭 How To Use

1. Add the script to a clean chart.  
2. Use intraday charts for clearer footprint-style reading.  
3. Watch the POC area to see where the highest slot volume appears.  
4. Compare candle delta with candle direction.  
5. Use value area to understand where most candle activity is located.  
6. Use imbalance and absorption highlights as context only.  
7. Check the HUD for a quick summary of current candle conditions.  
8. Combine this with market structure, support and resistance, liquidity zones, and proper risk management.

⚙️ Settings Overview

Lower timeframe precision controls the lower timeframe data used for the footprint approximation.  
Closed bars to keep controls how many previous footprint candles remain visible.  
Price slots per candle controls how many horizontal volume rows appear inside each candle.  
Cell text controls whether cells show volume, delta, delta percentage, or estimated ask/bid style values.  
Frame width adjusts the centered footprint frame width around each candle.  
Live candle update allows the active candle footprint to update while the candle is forming.  
POC trail connects POC movement between candles.  
Value Area highlights the main volume zone.  
Imbalance ratio controls imbalance sensitivity.  
Absorption slot volume percentage controls absorption-style highlighting.  
HUD settings control the compact panel position and visibility.  
Color settings allow visual customization of bullish, bearish, neutral, POC, value area, frame, and delta elements.

⚠️ Limitations

This script uses TradingView-available OHLCV data and lower-timeframe calculations. It does not access true exchange order book data or true bid/ask footprint data on most symbols. Values can vary depending on symbol, timeframe, lower-timeframe availability, volume quality, and chart settings.

The live candle can update while it is still forming. Confirmed candles are more stable than the active candle.

✅ Educational Use Only

This script is provided for educational market analysis and visual order-flow style study. It does not provide financial advice, guaranteed results, or automatic trade decisions. Traders should use proper risk management and combine this information with their own analysis.

## Source Code

````pine
//@version=6
indicator("LOKKA ALGO - Live Footprint Center Frame V8 FIX", shorttitle="LA FP CENTER V8", overlay=true, max_boxes_count=500, max_labels_count=300, max_lines_count=300)

// © LOKKA ALGO
// Exclusive property of LOKKA ALGO.
// Unauthorized copying, resale, redistribution, modification, or rebranding is not permitted.
// Live footprint-style approximation using lower timeframe OHLCV data.
// TradingView Pine Script cannot access true exchange bid/ask footprint data on most symbols.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore   = "01. Core"
groupLive   = "02. Live Footprint"
groupVisual = "03. Frame Visual"
groupStyle  = "04. Colors"
groupHUD    = "05. HUD"

precisionTF = input.timeframe("1", "Lower timeframe precision", group=groupCore)
barsToShow  = input.int(4, "Closed bars to keep", minval=1, maxval=8, group=groupCore)
slotsPerBar = input.int(10, "Price slots per candle", minval=4, maxval=20, group=groupCore)
textMode    = input.string("UDI", "Cell text", options=["Hidden", "V", "UD", "UDI", "Delta", "Delta%"], group=groupCore)

// Centered around candle time
frameWidth  = input.float(0.34, "Frame width around candle", minval=0.12, maxval=0.48, step=0.01, group=groupCore)

showLiveBar    = input.bool(true, "Update current live candle", group=groupLive)
showDeltaBar   = input.bool(true, "Show small delta bar", group=groupLive)
showDeltaLabel = input.bool(true, "Show small delta label", group=groupLive)
showPOCTrail   = input.bool(true, "Show POC trail", group=groupLive)
showValueArea  = input.bool(true, "Show value area", group=groupLive)
showImbalance  = input.bool(true, "Show imbalance arrows", group=groupLive)
showAbsorption = input.bool(true, "Show absorption border", group=groupLive)

valueAreaPct   = input.float(70.0, "Value Area %", minval=50, maxval=95, step=1, group=groupLive)
imbalanceRatio = input.float(3.0, "Imbalance ratio", minval=1.5, maxval=10.0, step=0.5, group=groupLive)
absorbVolPct   = input.float(18.0, "Absorption slot volume %", minval=5, maxval=50, step=1, group=groupLive)

showCandleFrame = input.bool(true, "Show full candle frame", group=groupVisual)
showFullSlotBg  = input.bool(true, "Show full slot ladder", group=groupVisual)
strongPOC       = input.bool(true, "Strong POC box", group=groupVisual)

bullText    = input.color(color.rgb(0, 245, 175), "Bull text", group=groupStyle)
bearText    = input.color(color.rgb(255, 85, 110), "Bear text", group=groupStyle)
neutralText = input.color(color.rgb(225, 225, 225), "Neutral text", group=groupStyle)

bullBg    = input.color(color.new(color.rgb(0, 150, 115), 76), "Bull slot background", group=groupStyle)
bearBg    = input.color(color.new(color.rgb(190, 45, 65), 76), "Bear slot background", group=groupStyle)
neutralBg = input.color(color.new(color.rgb(25, 45, 75), 74), "Neutral slot background", group=groupStyle)
vaBg      = input.color(color.new(color.rgb(45, 90, 170), 70), "Value area background", group=groupStyle)
pocBg     = input.color(color.new(color.orange, 18), "POC background", group=groupStyle)

frameBg     = input.color(color.new(color.rgb(8, 20, 30), 88), "Frame background", group=groupStyle)
liveBorder  = input.color(color.new(color.aqua, 0), "Live frame border", group=groupStyle)
frameBorder = input.color(color.new(color.rgb(80, 170, 220), 20), "Closed frame border", group=groupStyle)
cellBorder  = input.color(color.new(color.rgb(120, 145, 170), 58), "Cell border", group=groupStyle)

deltaBullBg = input.color(color.new(color.rgb(0, 180, 135), 10), "Delta bull", group=groupStyle)
deltaBearBg = input.color(color.new(color.rgb(255, 70, 90), 10), "Delta bear", group=groupStyle)
pocLineCol  = input.color(color.orange, "POC trail", group=groupStyle)

showHUD     = input.bool(true, "Show compact HUD", group=groupHUD)
hudPosition = input.string("Top Right", "HUD position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupHUD)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOWER TIMEFRAME DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
array<float> ltfOpen  = request.security_lower_tf(syminfo.tickerid, precisionTF, open)
array<float> ltfHigh  = request.security_lower_tf(syminfo.tickerid, precisionTF, high)
array<float> ltfLow   = request.security_lower_tf(syminfo.tickerid, precisionTF, low)
array<float> ltfClose = request.security_lower_tf(syminfo.tickerid, precisionTF, close)
array<float> ltfVol   = request.security_lower_tf(syminfo.tickerid, precisionTF, volume)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_clamp(int v, int lo, int hi) =>
    math.max(lo, math.min(v, hi))

f_short(float v) =>
    float av = math.abs(v)
    av >= 1000000 ? str.tostring(v / 1000000.0, "#.##") + "M" :
     av >= 1000 ? str.tostring(v / 1000.0, "#.##") + "K" :
     str.tostring(math.round(v))

f_pct(float part, float whole) =>
    whole != 0 ? part / whole * 100.0 : 0.0

f_hud_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left" ? position.bottom_left :
     position.top_right

f_period_ms() =>
    int sec = timeframe.in_seconds(timeframe.period)
    int result = math.max(sec * 1000, 60000)
    result

f_center_time() =>
    time

f_frame_left_time() =>
    time - int(f_period_ms() * frameWidth)

f_frame_right_time() =>
    time + int(f_period_ms() * frameWidth)

f_prev_center_time() =>
    time[1]

f_cell_text(float askV, float bidV, float barVol, bool buyImb, bool sellImb) =>
    float total = askV + bidV
    float delta = askV - bidV
    string txt = ""

    if textMode == "Hidden"
        txt := ""
    else if textMode == "V"
        txt := f_short(total)
    else if textMode == "UD"
        txt := f_short(askV) + "×" + f_short(bidV)
    else if textMode == "UDI"
        txt := f_short(askV) + "×" + f_short(bidV)
    else if textMode == "Delta"
        txt := f_short(delta)
    else if textMode == "Delta%"
        txt := str.tostring(f_pct(delta, total), "#.0") + "%"

    if textMode == "UDI" and showImbalance
        if sellImb
            txt := "↓ " + txt
        if buyImb
            txt := txt + " ↑"

    txt


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OBJECT STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var array<box>   histBoxes     = array.new_box()
var array<label> histLabels    = array.new_label()
var array<line>  histLines     = array.new_line()

var array<int> histBoxCounts   = array.new_int()
var array<int> histLabelCounts = array.new_int()
var array<int> histLineCounts  = array.new_int()

f_trim_hist() =>
    while array.size(histBoxCounts) > barsToShow
        int bc = array.shift(histBoxCounts)
        int lc = array.shift(histLabelCounts)
        int nc = array.shift(histLineCounts)

        for i = 0 to bc - 1
            if array.size(histBoxes) > 0
                box.delete(array.shift(histBoxes))

        for i = 0 to lc - 1
            if array.size(histLabels) > 0
                label.delete(array.shift(histLabels))

        for i = 0 to nc - 1
            if array.size(histLines) > 0
                line.delete(array.shift(histLines))

var array<box>   liveBoxes  = array.new_box()
var array<label> liveLabels = array.new_label()
var array<line>  liveLines  = array.new_line()

f_clear_live() =>
    while array.size(liveBoxes) > 0
        box.delete(array.pop(liveBoxes))
    while array.size(liveLabels) > 0
        label.delete(array.pop(liveLabels))
    while array.size(liveLines) > 0
        line.delete(array.pop(liveLines))


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float cumDelta = 0.0
var float prevPOC  = na

var float lastVol     = na
var float lastDelta   = na
var float lastPOC     = na
var float lastVAH     = na
var float lastVAL     = na
var float lastBuyPct  = na
var float lastSellPct = na

var int liveBarIndex = na
var float liveBarDelta = na
var float liveBarPOC = na

var table dash = table.new(f_hud_pos(hudPosition), 8, 7, frame_color=color.new(color.gray, 65), border_width=1)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_draw_footprint(bool isLive, float trailAnchorPOC) =>
    float barLow   = low
    float barHigh  = high
    float barRange = math.max(barHigh - barLow, syminfo.mintick * slotsPerBar)
    float slotSize = math.max(barRange / slotsPerBar, syminfo.mintick)

    array<float> askArr = array.new_float(slotsPerBar, 0.0)
    array<float> bidArr = array.new_float(slotsPerBar, 0.0)
    array<float> totArr = array.new_float(slotsPerBar, 0.0)

    int intrabars = array.size(ltfVol)

    if intrabars > 0
        for j = 0 to intrabars - 1
            float io = array.get(ltfOpen, j)
            float ih = array.get(ltfHigh, j)
            float il = array.get(ltfLow, j)
            float ic = array.get(ltfClose, j)
            float iv = array.get(ltfVol, j)

            int fromSlot = f_clamp(int(math.floor((il - barLow) / slotSize)), 0, slotsPerBar - 1)
            int toSlot   = f_clamp(int(math.floor((ih - barLow) / slotSize)), 0, slotsPerBar - 1)

            if toSlot < fromSlot
                int tmp = fromSlot
                fromSlot := toSlot
                toSlot := tmp

            int touched = math.max(toSlot - fromSlot + 1, 1)
            float share = iv / touched
            bool askSide = ic >= io

            for s = fromSlot to toSlot
                if askSide
                    array.set(askArr, s, array.get(askArr, s) + share)
                else
                    array.set(bidArr, s, array.get(bidArr, s) + share)
    else
        float share = volume / slotsPerBar
        for s = 0 to slotsPerBar - 1
            if close >= open
                array.set(askArr, s, share)
            else
                array.set(bidArr, s, share)

    float totalVol = 0.0
    float totalAsk = 0.0
    float totalBid = 0.0
    float barDelta = 0.0
    float pocVol   = -1.0
    int pocIdx     = 0

    for s = 0 to slotsPerBar - 1
        float askV = array.get(askArr, s)
        float bidV = array.get(bidArr, s)
        float tv   = askV + bidV
        float dv   = askV - bidV

        array.set(totArr, s, tv)

        totalVol += tv
        totalAsk += askV
        totalBid += bidV
        barDelta += dv

        if tv > pocVol
            pocVol := tv
            pocIdx := s

    int vaLow  = pocIdx
    int vaHigh = pocIdx
    float vaSum    = array.get(totArr, pocIdx)
    float vaTarget = totalVol * valueAreaPct / 100.0

    while vaSum < vaTarget and (vaLow > 0 or vaHigh < slotsPerBar - 1)
        float below = vaLow > 0 ? array.get(totArr, vaLow - 1) : -1.0
        float above = vaHigh < slotsPerBar - 1 ? array.get(totArr, vaHigh + 1) : -1.0

        if above > below
            vaHigh += 1
            vaSum += math.max(above, 0)
        else
            vaLow -= 1
            vaSum += math.max(below, 0)

    float pocPrice = barLow + (pocIdx + 0.5) * slotSize
    float vahPrice = barLow + (vaHigh + 1) * slotSize
    float valPrice = barLow + vaLow * slotSize

    int createdBoxes  = 0
    int createdLabels = 0
    int createdLines  = 0

    if showCandleFrame
        box frame = box.new(
             left = f_frame_left_time(),
             right = f_frame_right_time(),
             top = barHigh,
             bottom = barLow,
             xloc = xloc.bar_time,
             bgcolor = frameBg,
             border_color = isLive ? liveBorder : frameBorder,
             border_width = isLive ? 2 : 1)

        if isLive
            array.push(liveBoxes, frame)
        else
            array.push(histBoxes, frame)
            createdBoxes += 1

    for s = 0 to slotsPerBar - 1
        float askV = array.get(askArr, s)
        float bidV = array.get(bidArr, s)
        float tv   = askV + bidV
        float dv   = askV - bidV

        bool drawSlot = showFullSlotBg or tv > 0

        if drawSlot
            bool isPOC = s == pocIdx
            bool inVA  = s >= vaLow and s <= vaHigh

            bool buyImb  = showImbalance and s > 0 and array.get(bidArr, s - 1) > 0 and askV >= array.get(bidArr, s - 1) * imbalanceRatio
            bool sellImb = showImbalance and s < slotsPerBar - 1 and array.get(askArr, s + 1) > 0 and bidV >= array.get(askArr, s + 1) * imbalanceRatio
            bool absorption = showAbsorption and totalVol > 0 and tv >= totalVol * absorbVolPct / 100.0 and math.abs(dv) < tv * 0.25

            color bg = dv > 0 ? bullBg : dv < 0 ? bearBg : neutralBg
            color tx = dv > 0 ? bullText : dv < 0 ? bearText : neutralText
            color br = isLive ? liveBorder : cellBorder

            if showValueArea and inVA
                bg := vaBg

            if isPOC
                bg := pocBg
                br := color.orange

            if absorption
                br := color.yellow

            float y1 = barLow + s * slotSize
            float y2 = s == slotsPerBar - 1 ? barHigh : y1 + slotSize

            string cellTxt = tv > 0 ? f_cell_text(askV, bidV, totalVol, buyImb, sellImb) : ""

            box bx = box.new(
                 left = f_frame_left_time(),
                 right = f_frame_right_time(),
                 top = y2,
                 bottom = y1,
                 xloc = xloc.bar_time,
                 bgcolor = bg,
                 border_color = br,
                 border_width = isPOC and strongPOC ? 2 : absorption ? 2 : 1,
                 text = cellTxt,
                 text_color = tx,
                 text_size = size.tiny,
                 text_halign = text.align_center,
                 text_valign = text.align_center)

            if isLive
                array.push(liveBoxes, bx)
            else
                array.push(histBoxes, bx)
                createdBoxes += 1

    if showDeltaBar
        float baseY = barLow - barRange * 0.14
        float dStrength = math.min(math.abs(barDelta) / math.max(totalVol, 1.0), 1.0)
        float dHeight = math.max(dStrength * barRange * 0.10, syminfo.mintick * 3)

        float dTop = barDelta >= 0 ? baseY + dHeight : baseY
        float dBot = barDelta >= 0 ? baseY : baseY - dHeight

        box db = box.new(
             left = f_frame_left_time(),
             right = f_frame_right_time(),
             top = dTop,
             bottom = dBot,
             xloc = xloc.bar_time,
             bgcolor = barDelta >= 0 ? deltaBullBg : deltaBearBg,
             border_color = barDelta >= 0 ? color.new(bullText, 10) : color.new(bearText, 10),
             border_width = 1)

        if isLive
            array.push(liveBoxes, db)
        else
            array.push(histBoxes, db)
            createdBoxes += 1

        if showDeltaLabel
            float labelY = barDelta >= 0 ? dTop + barRange * 0.008 : dBot - barRange * 0.008

            label dl = label.new(
                 x = f_center_time(),
                 y = labelY,
                 xloc = xloc.bar_time,
                 text = "Δ " + f_short(barDelta),
                 style = label.style_none,
                 textcolor = barDelta >= 0 ? bullText : bearText,
                 size = size.tiny)

            if isLive
                array.push(liveLabels, dl)
            else
                array.push(histLabels, dl)
                createdLabels += 1

    if showPOCTrail and not na(trailAnchorPOC)
        line ln = line.new(
             x1 = f_prev_center_time(),
             y1 = trailAnchorPOC,
             x2 = f_center_time(),
             y2 = pocPrice,
             xloc = xloc.bar_time,
             color = pocLineCol,
             width = isLive ? 1 : 2)

        if isLive
            array.push(liveLines, ln)
        else
            array.push(histLines, ln)
            createdLines += 1

    float buyPct  = f_pct(totalAsk, totalVol)
    float sellPct = f_pct(totalBid, totalVol)

    [createdBoxes, createdLabels, createdLines, totalVol, barDelta, pocPrice, vahPrice, valPrice, buyPct, sellPct]


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORICAL DRAW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.ishistory and barstate.isconfirmed
    [hBoxes, hLabels, hLines, hVol, hDelta, hPOC, hVAH, hVAL, hBuyPct, hSellPct] = f_draw_footprint(false, prevPOC)

    array.push(histBoxCounts, hBoxes)
    array.push(histLabelCounts, hLabels)
    array.push(histLineCounts, hLines)
    f_trim_hist()

    cumDelta += hDelta
    prevPOC := hPOC

    lastVol     := hVol
    lastDelta   := hDelta
    lastPOC     := hPOC
    lastVAH     := hVAH
    lastVAL     := hVAL
    lastBuyPct  := hBuyPct
    lastSellPct := hSellPct


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIVE CANDLE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast and showLiveBar
    bool newLiveBar = na(liveBarIndex) or bar_index != liveBarIndex

    if newLiveBar
        int movedBoxes  = array.size(liveBoxes)
        int movedLabels = array.size(liveLabels)
        int movedLines  = array.size(liveLines)

        if movedBoxes > 0 or movedLabels > 0 or movedLines > 0
            while array.size(liveBoxes) > 0
                array.push(histBoxes, array.shift(liveBoxes))

            while array.size(liveLabels) > 0
                array.push(histLabels, array.shift(liveLabels))

            while array.size(liveLines) > 0
                array.push(histLines, array.shift(liveLines))

            array.push(histBoxCounts, movedBoxes)
            array.push(histLabelCounts, movedLabels)
            array.push(histLineCounts, movedLines)
            f_trim_hist()

            if not na(liveBarDelta)
                cumDelta += liveBarDelta
            if not na(liveBarPOC)
                prevPOC := liveBarPOC

        liveBarIndex := bar_index

    f_clear_live()

    [lBoxes, lLabels, lLines, lVol, lDelta, lPOC, lVAH, lVAL, lBuyPct, lSellPct] = f_draw_footprint(true, prevPOC)

    liveBarDelta := lDelta
    liveBarPOC   := lPOC

    lastVol     := lVol
    lastDelta   := lDelta
    lastPOC     := lPOC
    lastVAH     := lVAH
    lastVAL     := lVAL
    lastBuyPct  := lBuyPct
    lastSellPct := lSellPct


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HUD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_head_bg() =>
    color.new(color.rgb(6, 8, 12), 0)

f_soft_bg() =>
    color.new(color.rgb(28, 31, 38), 0)

f_fill_buy() =>
    color.new(color.rgb(0, 170, 125), 0)

f_fill_sell() =>
    color.new(color.rgb(220, 65, 85), 0)

f_fill_empty() =>
    color.new(color.rgb(58, 60, 68), 45)

f_set(int c, int r, string txt, color txtCol, color bgCol) =>
    table.cell(dash, c, r, txt, text_color=txtCol, bgcolor=bgCol, text_size=size.tiny)

f_meter_row(int row, string title, float pct, bool isBull) =>
    int blocks = 5
    float safePct = na(pct) ? 0.0 : math.max(0.0, math.min(pct, 100.0))
    int filled = int(math.round(safePct / 20.0))
    color actCol = isBull ? f_fill_buy() : f_fill_sell()

    f_set(0, row, title, color.silver, f_soft_bg())
    f_set(1, row, str.tostring(safePct, "#.0") + "%", color.white, f_soft_bg())

    for i = 0 to blocks - 1
        f_set(i + 2, row, "", color.white, i < filled ? actCol : f_fill_empty())

    f_set(7, row, "", color.white, f_soft_bg())

f_delta_row(int row, string title, float dVal, float vVal) =>
    float safeDelta = na(dVal) ? 0.0 : dVal
    float safeVol   = na(vVal) ? 1.0 : math.max(vVal, 1.0)
    float strength  = math.min(math.abs(safeDelta) / safeVol * 100.0, 100.0)
    int blocks = 5
    int filled = int(math.round(strength / 20.0))
    bool bull = safeDelta >= 0
    color actCol = bull ? f_fill_buy() : f_fill_sell()

    f_set(0, row, title, color.silver, f_soft_bg())
    f_set(1, row, f_short(safeDelta), bull ? bullText : bearText, f_soft_bg())

    for i = 0 to blocks - 1
        f_set(i + 2, row, "", color.white, i < filled ? actCol : f_fill_empty())

    f_set(7, row, bull ? "B" : "S", color.white, actCol)

f_info_row(int row, string title, string value, color valColor) =>
    f_set(0, row, title, color.silver, f_soft_bg())
    f_set(1, row, value, valColor, f_soft_bg())
    f_set(2, row, "", color.white, f_soft_bg())
    f_set(3, row, "", color.white, f_soft_bg())
    f_set(4, row, "", color.white, f_soft_bg())
    f_set(5, row, "", color.white, f_soft_bg())
    f_set(6, row, "", color.white, f_soft_bg())
    f_set(7, row, "", color.white, f_soft_bg())

if barstate.islast
    table.clear(dash, 0, 0, 7, 6)

    if showHUD
        f_set(0, 0, "LA", color.white, f_head_bg())
        f_set(1, 0, "CENTER", color.white, f_head_bg())
        f_set(2, 0, "V8", color.orange, f_head_bg())
        f_set(3, 0, "", color.white, f_head_bg())
        f_set(4, 0, "", color.white, f_head_bg())
        f_set(5, 0, "", color.white, f_head_bg())
        f_set(6, 0, precisionTF, color.white, f_head_bg())
        f_set(7, 0, "TF", color.silver, f_head_bg())

        f_meter_row(1, "ASK", lastBuyPct, true)
        f_meter_row(2, "BID", lastSellPct, false)
        f_delta_row(3, "DEL", lastDelta, lastVol)

        f_info_row(4, "POC", na(lastPOC) ? "na" : str.tostring(lastPOC, format.mintick), color.orange)
        f_info_row(5, "VA", na(lastVAH) or na(lastVAL) ? "na" : str.tostring(lastVAH, format.mintick) + " / " + str.tostring(lastVAL, format.mintick), color.white)

        string biasTxt = na(lastDelta) ? "NA" :
             lastDelta > 0 and lastBuyPct > lastSellPct ? "BUY" :
             lastDelta < 0 and lastSellPct > lastBuyPct ? "SELL" :
             "BAL"

        color biasBg = biasTxt == "BUY" ? f_fill_buy() :
             biasTxt == "SELL" ? f_fill_sell() :
             color.new(color.gray, 20)

        f_set(0, 6, "BIAS", color.silver, f_soft_bg())
        f_set(1, 6, biasTxt, color.white, biasBg)
        f_set(2, 6, "VOL", color.silver, f_soft_bg())
        f_set(3, 6, na(lastVol) ? "na" : f_short(lastVol), color.white, f_soft_bg())
        f_set(4, 6, "CVD", color.silver, f_soft_bg())
        f_set(5, 6, f_short(cumDelta), cumDelta >= 0 ? bullText : bearText, f_soft_bg())
        f_set(6, 6, "", color.white, f_soft_bg())
        f_set(7, 6, "", color.white, f_soft_bg())
````
