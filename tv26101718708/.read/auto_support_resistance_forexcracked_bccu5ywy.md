# Auto Support & Resistance [ForexCracked]

- url: https://www.tradingview.com/script/BCcU5YwY-Auto-Support-Resistance-ForexCracked/
- type: indicator
- pine_id: PUB;7fdca6194d8943eda9b546369486363b
- version: 2.0

## Description

🔷 OVERVIEW

Auto Support & Resistance finds the levels that matter and scores how strong they are. It builds zones from confirmed swing pivots, merges nearby pivots into one level, counts every touch, and rates each zone from one to five stars. Levels never repaint: a zone only appears once its swing is confirmed.

🔷 HOW IT WORKS

Confirmed pivot highs become resistance zones and confirmed pivot lows become support zones. Pivots that land within half an ATR of an existing zone merge into it, and each merge or retest adds a touch. More touches means a more solid fill on the chart and a higher star rating. When price closes through a zone, the level flips: broken resistance becomes support, and broken support becomes resistance, exactly as classic technical analysis describes. Zones that nothing has touched for a long time fade off the chart, and only the strongest levels per side are kept, so the chart stays clean.

🔷 THE DASHBOARD

A compact panel shows the nearest resistance and nearest support: the exact level, how far away it is in pips, and its strength in stars. Drop it in any corner.

🔷 HOW TO USE

Treat the zones as areas of interest, not automatic trades. Watch how price reacts at a strong level: rejections at four and five star zones in the direction of your higher timeframe bias are the classic play, and a clean break and retest of a flipped level is the second. Always confirm with your own analysis and use a stop.

🔷 SETTINGS

Pivot strength, merge distance and zone height (x ATR), max levels per side, break buffer, zone age, colours, and dashboard position.

🔷 ALERTS

Level broken (flip), and New confirmed level.

Free and open-source. Educational tool, not financial advice.

## Source Code

````pine
//@version=6
// © ForexCracked  —  free & open-source  —  Licensed under CC BY-NC-SA 4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/

indicator("Auto Support & Resistance [ForexCracked]", "S/R [FXC]", overlay = true, max_boxes_count = 500)

//=====================================================================================================================
// INPUTS
//=====================================================================================================================
gL = "Chart timeframe levels"
pivLen   = input.int(10, "Pivot strength (bars)", minval = 3, maxval = 50, group = gL, tooltip = "A level needs this many bars on each side of the swing to confirm. Levels never repaint: they only appear once the swing is confirmed.")
mergeF   = input.float(0.5, "Merge distance (x ATR)", minval = 0.1, step = 0.1, group = gL, tooltip = "Pivots closer together than this merge into one zone, and each merge counts as an extra touch.")
zoneF    = input.float(0.15, "Zone height (x ATR)", minval = 0.05, step = 0.05, group = gL)
maxSide  = input.int(5, "Max levels per side", minval = 2, maxval = 10, group = gL)

gM = "Higher timeframe levels"
useH1    = input.bool(true, "Show HTF 1 levels", inline = "h1", group = gM)
htf1     = input.timeframe("240", "", inline = "h1", group = gM, tooltip = "Big levels from higher timeframes draw on your chart with a thicker border and a label, so the 4H and Daily zones everyone watches are visible while you trade the lower timeframe.")
useH2    = input.bool(true, "Show HTF 2 levels", inline = "h2", group = gM)
htf2     = input.timeframe("D", "", inline = "h2", group = gM)
pivLenH  = input.int(5, "HTF pivot strength (bars)", minval = 3, maxval = 20, group = gM)
maxSideH = input.int(3, "Max HTF levels per side (each TF)", minval = 1, maxval = 6, group = gM)

gB = "Breaks & aging"
brkF      = input.float(0.1, "Break buffer (x ATR)", minval = 0.0, step = 0.05, group = gB, tooltip = "Price must CLOSE this far beyond a zone to break it. A broken level flips: old resistance becomes new support, and vice versa.")
maxAge    = input.int(500, "Max age of weak levels (bars since last touch)", minval = 50, group = gB)
keepStrng = input.bool(true, "Keep strong levels (4-5 stars) until broken", group = gB, tooltip = "Old levels with many touches are exactly the ones that matter. With this on, they never age out; only a real break removes their side.")

gS = "Style"
supCol   = input.color(color.new(#2dd4bf, 78), "Support", inline = "c", group = gS)
resCol   = input.color(color.new(#e84e89, 78), "Resistance", inline = "c", group = gS)
extendN  = input.int(20, "Extend right (bars)", minval = 0, group = gS)
showTbl  = input.bool(true, "Dashboard", group = gS)
tblPosIn = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gS)
tblPos = tblPosIn == "Top Left" ? position.top_left : tblPosIn == "Bottom Right" ? position.bottom_right : tblPosIn == "Bottom Left" ? position.bottom_left : position.top_right

atr = ta.atr(14)

// pretty name for a timeframe string ("240" -> "4H", "D" -> "1D")
tfName(string tf) =>
    out = tf
    if tf == "D" or tf == "1D"
        out := "1D"
    else if tf == "W" or tf == "1W"
        out := "1W"
    else
        mins = math.round(str.tonumber(tf))
        if not na(mins)
            out := mins >= 60 ? str.tostring(mins / 60) + "H" : str.tostring(mins) + "m"
    out

//=====================================================================================================================
// STATE — index-aligned arrays per zone (rank: 0 = chart TF, 1 = HTF1, 2 = HTF2)
//=====================================================================================================================
var array<box>   zBox   = array.new<box>()
var array<float> zMid   = array.new<float>()
var array<int>   zDir   = array.new<int>()    //  1 = support, -1 = resistance
var array<int>   zTouch = array.new<int>()
var array<int>   zLast  = array.new<int>()
var array<int>   zRank  = array.new<int>()

strengthOf(t) => math.min(t, 5)

paint(i) =>
    b    = array.get(zBox, i)
    d    = array.get(zDir, i)
    r    = array.get(zRank, i)
    s    = strengthOf(array.get(zTouch, i))
    base = d > 0 ? supCol : resCol
    box.set_bgcolor(b, color.new(base, 88 - s * 6))
    box.set_border_color(b, color.new(base, r > 0 ? 15 : 30))
    box.set_border_width(b, r > 0 ? 2 : 1)
    box.set_text(b, r == 1 ? tfName(htf1) : r == 2 ? tfName(htf2) : "")
    box.set_text_color(b, color.new(base, 25))
    box.set_text_size(b, size.tiny)
    box.set_text_halign(b, text.align_right)

// add a confirmed pivot as a zone, or merge it into a close-enough existing one.
// leftBars anchors the zone's left edge at the ACTUAL swing bar (a pivot confirms leftBars after it happened).
addLevel(float price, int dir, int rank, float zHeight, float mergeDist, int leftBars) =>
    merged = false
    n = array.size(zMid)
    if n > 0
        for i = 0 to n - 1
            if not merged and math.abs(price - array.get(zMid, i)) <= mergeDist
                array.set(zTouch, i, array.get(zTouch, i) + 1)
                array.set(zLast, i, bar_index)
                array.set(zMid, i, (array.get(zMid, i) + price) / 2)
                if rank > array.get(zRank, i)      // HTF pivot upgrades a chart-TF zone
                    array.set(zRank, i, rank)
                b = array.get(zBox, i)
                box.set_top(b, math.max(box.get_top(b), array.get(zMid, i) + zHeight))
                box.set_bottom(b, math.min(box.get_bottom(b), array.get(zMid, i) - zHeight))
                paint(i)
                merged := true
    if not merged
        bx = box.new(math.max(bar_index - leftBars, 0), price + zHeight, bar_index + extendN, price - zHeight, border_width = 1)
        array.push(zBox, bx)
        array.push(zMid, price)
        array.push(zDir, dir)
        array.push(zTouch, 1)
        array.push(zLast, bar_index)
        array.push(zRank, rank)
        paint(array.size(zMid) - 1)

//=====================================================================================================================
// CHART-TF PIVOTS (non-repaint: appear pivLen bars after the swing)
//=====================================================================================================================
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
if not na(ph) and not na(atr)
    addLevel(ph, -1, 0, zoneF * atr, mergeF * atr, pivLen)
if not na(pl) and not na(atr)
    addLevel(pl, 1, 0, zoneF * atr, mergeF * atr, pivLen)

//=====================================================================================================================
// HIGHER-TIMEFRAME PIVOTS (4H / Daily zones visible on your lower-TF chart)
//=====================================================================================================================
[ph1, pl1, atr1] = request.security(syminfo.tickerid, htf1, [ta.pivothigh(pivLenH, pivLenH), ta.pivotlow(pivLenH, pivLenH), ta.atr(14)], lookahead = barmerge.lookahead_off)
[ph2, pl2, atr2] = request.security(syminfo.tickerid, htf2, [ta.pivothigh(pivLenH, pivLenH), ta.pivotlow(pivLenH, pivLenH), ta.atr(14)], lookahead = barmerge.lookahead_off)

okH1 = useH1 and timeframe.in_seconds() < timeframe.in_seconds(htf1)
okH2 = useH2 and timeframe.in_seconds() < timeframe.in_seconds(htf2)

// a HTF pivot confirms pivLenH HTF-bars after the swing = that many CHART bars back
lag1 = math.round(pivLenH * timeframe.in_seconds(htf1) / timeframe.in_seconds())
lag2 = math.round(pivLenH * timeframe.in_seconds(htf2) / timeframe.in_seconds())

var float doneH1hi = na
var float doneH1lo = na
var float doneH2hi = na
var float doneH2lo = na

if okH1 and not na(ph1) and ph1 != doneH1hi and not na(atr1)
    addLevel(ph1, -1, 1, zoneF * atr1, mergeF * atr1, lag1)
    doneH1hi := ph1
if okH1 and not na(pl1) and pl1 != doneH1lo and not na(atr1)
    addLevel(pl1, 1, 1, zoneF * atr1, mergeF * atr1, lag1)
    doneH1lo := pl1
if okH2 and not na(ph2) and ph2 != doneH2hi and not na(atr2)
    addLevel(ph2, -1, 2, zoneF * atr2, mergeF * atr2, lag2)
    doneH2hi := ph2
if okH2 and not na(pl2) and pl2 != doneH2lo and not na(atr2)
    addLevel(pl2, 1, 2, zoneF * atr2, mergeF * atr2, lag2)
    doneH2lo := pl2

//=====================================================================================================================
// MANAGE ZONES — touches, breaks (flip), aging (weak chart-TF only), extension
//=====================================================================================================================
newBreak = false
if array.size(zMid) > 0 and not na(atr)
    i = array.size(zMid) - 1
    while i >= 0
        b   = array.get(zBox, i)
        d   = array.get(zDir, i)
        r   = array.get(zRank, i)
        top = box.get_top(b)
        bot = box.get_bottom(b)
        touched = d > 0 ? (low <= top and close >= bot) : (high >= bot and close <= top)
        if touched and bar_index - array.get(zLast, i) > 3
            array.set(zTouch, i, array.get(zTouch, i) + 1)
            array.set(zLast, i, bar_index)
            paint(i)
        broken = d > 0 ? close < bot - brkF * atr : close > top + brkF * atr
        if broken
            array.set(zDir, i, -d)
            array.set(zTouch, i, 1)
            array.set(zLast, i, bar_index)
            paint(i)
            newBreak := true
        // aging: only weak chart-TF levels fade out; strong levels and HTF levels stay until broken
        s = strengthOf(array.get(zTouch, i))
        exempt = r > 0 or (keepStrng and s >= 4)
        if not exempt and bar_index - array.get(zLast, i) > maxAge
            box.delete(b)
            array.remove(zBox, i), array.remove(zMid, i), array.remove(zDir, i), array.remove(zTouch, i), array.remove(zLast, i), array.remove(zRank, i)
        else
            box.set_right(b, bar_index + extendN)
        i := i - 1

// cap levels per side within each rank: drop the weakest / oldest first
capSide(int dir, int rank, int cap) =>
    count = 0
    n = array.size(zDir)
    if n > 0
        for i = 0 to n - 1
            if array.get(zDir, i) == dir and array.get(zRank, i) == rank
                count := count + 1
    while count > cap
        worst = -1
        worstScore = 1.0e15
        for i = 0 to array.size(zDir) - 1
            if array.get(zDir, i) == dir and array.get(zRank, i) == rank
                score = array.get(zTouch, i) * 1000000.0 + array.get(zLast, i)
                if score < worstScore
                    worstScore := score
                    worst := i
        if worst >= 0
            box.delete(array.get(zBox, worst))
            array.remove(zBox, worst), array.remove(zMid, worst), array.remove(zDir, worst), array.remove(zTouch, worst), array.remove(zLast, worst), array.remove(zRank, worst)
        count := count - 1
capSide(1, 0, maxSide)
capSide(-1, 0, maxSide)
capSide(1, 1, maxSideH)
capSide(-1, 1, maxSideH)
capSide(1, 2, maxSideH)
capSide(-1, 2, maxSideH)

//=====================================================================================================================
// DASHBOARD — nearest support / resistance with source TF, distance in pips, strength stars
//=====================================================================================================================
pipSize = syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)
stars(s) =>
    out = ""
    for k = 1 to 5
        out := out + (k <= s ? "★" : "☆")
    out
rkName(int r) =>
    r == 1 ? tfName(htf1) : r == 2 ? tfName(htf2) : tfName(timeframe.period)

if showTbl and barstate.islast
    bg    = #1a2c4c
    hd    = #1f3a63
    lbl   = #9fb0c4
    tealC = #2dd4bf
    pinkC = #e84e89
    nearS = float(na), nearR = float(na)
    sT = 0, rT = 0, sR = 0, rR = 0
    if array.size(zMid) > 0
        for i = 0 to array.size(zMid) - 1
            m = array.get(zMid, i)
            if m < close and (na(nearS) or m > nearS)
                nearS := m
                sT := strengthOf(array.get(zTouch, i))
                sR := array.get(zRank, i)
            if m > close and (na(nearR) or m < nearR)
                nearR := m
                rT := strengthOf(array.get(zTouch, i))
                rR := array.get(zRank, i)
    var table t = table.new(tblPos, 5, 3, bgcolor = bg, frame_color = color.new(color.gray, 55), frame_width = 1, border_color = color.new(#2a3d63, 25), border_width = 1)
    table.cell(t, 0, 0, " AUTO S/R ", text_color = color.white, bgcolor = hd, text_size = size.normal)
    table.cell(t, 1, 0, "Level", text_color = lbl, bgcolor = hd, text_size = size.small)
    table.cell(t, 2, 0, "TF", text_color = lbl, bgcolor = hd, text_size = size.small)
    table.cell(t, 3, 0, "Away", text_color = lbl, bgcolor = hd, text_size = size.small)
    table.cell(t, 4, 0, "Strength", text_color = lbl, bgcolor = hd, text_size = size.small)
    table.cell(t, 0, 1, "Resistance", text_color = pinkC, text_size = size.small)
    table.cell(t, 1, 1, na(nearR) ? "—" : str.tostring(nearR, format.mintick), text_color = color.white, text_size = size.normal)
    table.cell(t, 2, 1, na(nearR) ? "—" : rkName(rR), text_color = lbl, text_size = size.small)
    table.cell(t, 3, 1, na(nearR) ? "—" : str.tostring(math.round((nearR - close) / pipSize, 1)) + " pips", text_color = lbl, text_size = size.small)
    table.cell(t, 4, 1, na(nearR) ? "—" : stars(rT), text_color = pinkC, text_size = size.small)
    table.cell(t, 0, 2, "Support", text_color = tealC, text_size = size.small)
    table.cell(t, 1, 2, na(nearS) ? "—" : str.tostring(nearS, format.mintick), text_color = color.white, text_size = size.normal)
    table.cell(t, 2, 2, na(nearS) ? "—" : rkName(sR), text_color = lbl, text_size = size.small)
    table.cell(t, 3, 2, na(nearS) ? "—" : str.tostring(math.round((close - nearS) / pipSize, 1)) + " pips", text_color = lbl, text_size = size.small)
    table.cell(t, 4, 2, na(nearS) ? "—" : stars(sT), text_color = tealC, text_size = size.small)

//=====================================================================================================================
// ALERTS
//=====================================================================================================================
alertcondition(newBreak, "Level broken (flip)", "A support or resistance level was broken and flipped sides")
alertcondition(not na(ph) or not na(pl), "New confirmed level", "A new support or resistance level confirmed")
````
