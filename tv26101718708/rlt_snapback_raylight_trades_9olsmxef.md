# RLT Snapback  RAYLIGHT TRADES

- url: https://www.tradingview.com/script/9OLSMxeF-RLT-Snapback-RAYLIGHT-TRADES/
- type: indicator
- pine_id: PUB;6ba0ed87891d4ddba3b800f05897e693
- version: 2.0

## Description

RLT Snapback is a manual pullback tool. You pick the swing, and it measures how deep the current pullback goes as a percentage of that swing. It marks the 25%–75% zone and labels the market structure from your swing onward.

It does not choose swings for you and it does not give buy or sell signals. It shows where price is relative to a swing you chose.

HOW IT WORKS

1. Point A and Point B
When you add the indicator to the chart, TradingView asks you to click two points:

Point A: the start of the swing (swing low for an up-move, swing high for a down-move)
Point B: the end of the swing (the latest swing high or low)
You can change both points at any time in the indicator settings, or by removing the indicator and adding it again.

2. Range box and levels
A box is drawn from Point A to Point B, like a date range. The pullback from Point B back toward Point A is measured, and these levels are drawn:

25% and 75%: the edges of the zone (solid lines)
50%: the midpoint (dashed, optional)
The area between 25% and 75% is shaded as the zone.
Each level has a label on the right with its price (prices are optional). A small label at Point B shows the size of the swing in % and the number of bars from A to B.

3. Live pullback status
A label next to the current price shows how deep the pullback is right now:

Grey: the pullback hasn't reached 25% yet
Gold: price is inside the 25%–75% zone
Red, INVALID: price has gone beyond 75% of the swing
INVALID uses the deepest wick since Point B, so once it appears it stays, even if price comes back into the zone. That swing is no longer valid, and you should draw a new one.

4. Market structure (HH / HL / LH / LL)
Starting from Point A only, the indicator labels the major swings as Higher High, Higher Low, Lower High and Lower Low.
To ignore small noise, a swing only counts when it's at least a set percentage of your A→B range. You can change this in settings with "Min swing size", which defaults to 30%. Raise it for fewer, bigger swings, or lower it for more detail.
Highs and lows always alternate, so you get a clean structure instead of every small wiggle.

HOW TO USE IT

Find a clear swing on your timeframe.
Click Point A at the start of the swing and Point B at the end.
Watch whether the pullback forms its swing (HL in an uptrend, LH in a downtrend) inside the 25%–75% zone.
If the status turns red, the pullback went too deep. Ignore that swing and wait for a new one.
What you do from there, and how you confirm it, is your own decision and analysis.

SETTINGS

Swing points: Point A and Point B (time and price)
Style: zone fill, 25%/75% line colour, 50% line, range box colours, show prices, show status label, badge position
Market structure: show or hide labels, minimum swing size, colours for bullish and bearish labels

NOTES

The levels move only when you move Point A or Point B, so nothing repaints on its own.
Works on any symbol and any timeframe.
This is a drawing and measuring tool for chart analysis. It is not financial advice, and past price behaviour does not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RAYLIGHT TRADES
//              ╔════════════════════════════════╗              //
//              ║           CREATED BY           ║              //
//              ╚════════════════════════════════╝              //
//
// ██████╗  █████╗ ██╗   ██╗██╗     ██╗ ██████╗ ██╗  ██╗████████╗
// ██╔══██╗██╔══██╗╚██╗ ██╔╝██║     ██║██╔════╝ ██║  ██║╚══██╔══╝
// ██████╔╝███████║ ╚████╔╝ ██║     ██║██║  ███╗███████║   ██║
// ██╔══██╗██╔══██║  ╚██╔╝  ██║     ██║██║   ██║██╔══██║   ██║
// ██║  ██║██║  ██║   ██║   ███████╗██║╚██████╔╝██║  ██║   ██║
// ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
//
//       ████████╗██████╗  █████╗ ██████╗ ███████╗███████╗
//       ╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
//          ██║   ██████╔╝███████║██║  ██║█████╗  ███████╗
//          ██║   ██╔══██╗██╔══██║██║  ██║██╔══╝  ╚════██║
//          ██║   ██║  ██║██║  ██║██████╔╝███████╗███████║
//          ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝
//
//                ◆  RLT SNAPBACK  ·  RAYLIGHT TRADES  ◆


//@version=6
indicator("RLT Snapback · RAYLIGHT TRADES", shorttitle = "RLT Snapback", overlay = true, max_lines_count = 500, max_boxes_count = 50, max_labels_count = 500)

// ─────────────── Swings (automatic) ───────────────
// Swings are found automatically on CLOSED candles only. A swing is locked once price has pulled back a set % of the move,
// and a locked swing never moves again (no repaint). The newest locked swing pair becomes Point A → Point B.
atrLen    = input.int(14, "ATR length", minval = 1, group = "Swings")
minLegAtr = input.float(5.0, "Min swing size (× ATR)", minval = 1, step = 0.5, group = "Swings", tooltip = "A move must be at least this many ATRs (average candle ranges) to count as a swing. Higher = only bigger, cleaner swings. 5 = major swings, 3 = more swings, 8+ = only the biggest.")
confPct   = input.float(20.0, "Lock swing after pullback of (%)", minval = 5, maxval = 25, step = 1, group = "Swings", tooltip = "Point B is locked when a closed candle has pulled back this % of the A→B move. Keep it at or below 25% so the zone is ready before price reaches it.")


// ─────────────── Style ───────────────
zoneFill   = input.color(color.new(#F0B90B, 88), "Zone fill", group = "Style")
keyCol     = input.color(#F0B90B, "25% / 75% lines", group = "Style")
midCol     = input.color(color.new(#9AA3B2, 30), "50% line", group = "Style")
rangeFill  = input.color(color.new(#2F7BFF, 88), "Range box fill", group = "Style")
rangeLine  = input.color(#2F7BFF, "Range box border", group = "Style")
showMid    = input.bool(true, "Show 50% line", group = "Style")
showPrices = input.bool(true, "Show prices on labels", group = "Style")
showStatus = input.bool(true, "Show live status label", group = "Style")
brandPos   = input.string("Top right", "Badge position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = "Style")

// ─────────────── Market structure ───────────────
showMS = input.bool(true, "Show HH / HL / LH / LL", group = "Market structure")
msUp   = input.color(#2EBD85, "HH / HL colour", group = "Market structure")
msDn   = input.color(#F6465D, "LH / LL colour", group = "Market structure")

auto = true
fmt(float v) => str.tostring(v, format.mintick)

// ─────────────── Locked swing points ───────────────
type Piv
    float p
    int   t
    int   i
    bool  hi

var array<Piv> pivs = array.new<Piv>()

// most recent locked swing high (hi = true) or swing low (hi = false)
lastOf(bool hi) =>
    Piv r = na
    int n = pivs.size()
    if n > 0
        for k = n - 1 to 0
            Piv q = pivs.get(k)
            if q.hi == hi
                r := q
                break
    r

// lock a swing point (it is in the past, so its position never changes) and tag it HH / HL / LH / LL
addPiv(float price, int tm, int idx, bool isHigh) =>
    string tag = isHigh ? "H" : "L"
    Piv prev = lastOf(isHigh)                     // previous swing of the same type
    if not na(prev)
        if isHigh
            tag := price > prev.p ? "HH" : "LH"
        else
            tag := price > prev.p ? "HL" : "LL"
    pivs.push(Piv.new(price, tm, idx, isHigh))
    if showMS
        c = tag == "HH" or tag == "HL" ? msUp : tag == "LH" or tag == "LL" ? msDn : #8A93A3
        label.new(tm, price, tag, xloc = xloc.bar_time, style = isHigh ? label.style_label_down : label.style_label_up, color = color.new(c, 80), textcolor = c, size = size.normal)

// ─────────────── Auto swing engine (closed candles only = no repaint) ───────────────
atr = ta.atr(atrLen)

var int   dir  = 0        // +1 = hunting the next high, -1 = hunting the next low, 0 = starting up
var float exP  = na       // running extreme of the current leg
var int   exT  = na
var int   exI  = na
var float opP  = na       // deepest move against the leg since that extreme (the pullback)
var int   opT  = na
var int   opI  = na
var float hhP  = na       // start-up trackers
var int   hhT  = na
var int   hhI  = na
var float llP  = na
var int   llT  = na
var int   llI  = na
bool justLocked = false
var float baseP = na    // pullback extreme of an unfinished swing (marked later, only if the trend makes a real new swing)
var int   baseT = na
var int   baseI = na
var float sAP = na      // Point A of the swing that just locked
var int   sAT = na
var int   sAI = na

if auto and barstate.isconfirmed and not na(atr)
    minLeg = minLegAtr * atr
    if dir == 0
        if na(hhP) or high > hhP
            hhP := high, hhT := time, hhI := bar_index
        if na(llP) or low < llP
            llP := low, llT := time, llI := bar_index
        if hhP - llP >= minLeg
            if hhI > llI     // low came first → lock the low, now hunting a high
                addPiv(llP, llT, llI, false)
                dir := 1, exP := hhP, exT := hhT, exI := hhI
                opP := low, opT := time, opI := bar_index
            else             // high came first → lock the high, now hunting a low
                addPiv(hhP, hhT, hhI, true)
                dir := -1, exP := llP, exT := llT, exI := llI
                opP := high, opT := time, opI := bar_index
    else if dir == 1
        last = lastOf(false)                      // the swing low this up-move started from
        if na(last)
            dir := 0, hhP := high, hhT := time, hhI := bar_index, llP := low, llT := time, llI := bar_index, baseP := na   // no opposite swing yet → start over
        else
            if high > exP
                exP := high, exT := time, exI := bar_index
                opP := low, opT := time, opI := bar_index
            else if low < opP
                opP := low, opT := time, opI := bar_index
            // the pullback went deeper than the stored pullback low (but not below the last swing low) → re-anchor there
            if not na(baseP) and opP < baseP and opP >= last.p
                baseP := opP, baseT := opT, baseI := opI
                exP := high, exT := time, exI := bar_index
                opP := low, opT := time, opI := bar_index
            fromP = na(baseP) ? last.p : baseP           // where this up-swing really started
            leg = exP - fromP
            if leg >= minLeg and opI > exI and exP - opP >= leg * confPct / 100
                // swing high locked (pullback came on a LATER closed candle) → new setup (A = swing low it started from, B = this high)
                Piv hiPrev = lastOf(true)
                if not na(baseP) and (na(hiPrev) or math.abs(hiPrev.p - baseP) >= 0.5 * minLeg)
                    addPiv(baseP, baseT, baseI, false)     // the higher low between the two highs (only if it is a real swing)
                    sAP := baseP, sAT := baseT, sAI := baseI
                else
                    sAP := last.p, sAT := last.t, sAI := last.i
                addPiv(exP, exT, exI, true)
                justLocked := true
                baseP := na
                dir := -1, exP := opP, exT := opT, exI := opI
                opP := high, opT := time, opI := bar_index
            else if opP < last.p
                // price broke below the last swing low before a real swing high formed → the down-move is still going.
                // Nothing is marked yet; the bounce high is kept and marked only if a real new low forms later.
                baseP := exP, baseT := exT, baseI := exI
                dir := -1, exP := opP, exT := opT, exI := opI
                opP := high, opT := time, opI := bar_index
    else
        last = lastOf(true)                       // the swing high this down-move started from
        if na(last)
            dir := 0, hhP := high, hhT := time, hhI := bar_index, llP := low, llT := time, llI := bar_index, baseP := na   // no opposite swing yet → start over
        else
            if low < exP
                exP := low, exT := time, exI := bar_index
                opP := high, opT := time, opI := bar_index
            else if high > opP
                opP := high, opT := time, opI := bar_index
            // the bounce went higher than the stored bounce high (but not above the last swing high) → re-anchor there
            if not na(baseP) and opP > baseP and opP <= last.p
                baseP := opP, baseT := opT, baseI := opI
                exP := low, exT := time, exI := bar_index
                opP := high, opT := time, opI := bar_index
            fromP = na(baseP) ? last.p : baseP           // where this down-swing really started
            leg = fromP - exP
            if leg >= minLeg and opI > exI and opP - exP >= leg * confPct / 100
                // swing low locked (bounce came on a LATER closed candle) → new setup (A = swing high it started from, B = this low)
                Piv loPrev = lastOf(false)
                if not na(baseP) and (na(loPrev) or math.abs(baseP - loPrev.p) >= 0.5 * minLeg)
                    addPiv(baseP, baseT, baseI, true)      // the lower high between the two lows (only if it is a real swing)
                    sAP := baseP, sAT := baseT, sAI := baseI
                else
                    sAP := last.p, sAT := last.t, sAI := last.i
                addPiv(exP, exT, exI, false)
                justLocked := true
                baseP := na
                dir := 1, exP := opP, exT := opT, exI := opI
                opP := low, opT := time, opI := bar_index
            else if opP > last.p
                // price broke above the last swing high before a real swing low formed → the up-move is still going.
                // Nothing is marked yet; the pullback low is kept and marked only if a real new high forms later.
                baseP := exP, baseT := exT, baseI := exI
                dir := 1, exP := opP, exT := opT, exI := opI
                opP := low, opT := time, opI := bar_index

// ─────────────── Current setup (Point A → Point B) ───────────────
var float aP = na
var int   aT = na
var int   aI = na
var float bP = na
var int   bT = na
var int   bI = na

if auto and justLocked
    B = pivs.last()
    aP := sAP, aT := sAT, aI := sAI
    bP := B.p, bT := B.t, bI := B.i

manualReady = false

hasSetup = not na(aP) and not na(bP) and aP != bP
bull = hasSetup and bP > aP      // swing low → swing high = bullish swing (look for the pullback down)

// 0% = Point B (latest swing), 100% = Point A. Levels measure the pullback from B back toward A.
lvl(float pct) => bP + (aP - bP) * pct
l25 = lvl(0.25)
l50 = lvl(0.50)
l75 = lvl(0.75)

// deepest pullback since Point B (wicks, closed candles). In auto mode this is the running extreme of the new leg.
var float deep = na
if auto and justLocked
    deep := (bP - exP) / (bP - aP) * 100      // exP = deepest pullback since B, up to the bar that locked it
else if hasSetup and barstate.isconfirmed and time > bT
    w = bull ? low : high
    r = (bP - w) / (bP - aP) * 100
    deep := na(deep) ? r : math.max(deep, r)

// ─────────────── Drawing ───────────────
var box   rBox   = na
var box   zBox   = na
var line  ln25   = na
var line  ln50   = na
var line  ln75   = na
var label lb25   = na
var label lb50   = na
var label lb75   = na
var label lbInfo = na
var label lbStat = na

redraw = hasSetup and ((auto and justLocked) or manualReady)
if redraw
    box.delete(rBox), box.delete(zBox)
    line.delete(ln25), line.delete(ln50), line.delete(ln75)
    label.delete(lb25), label.delete(lb50), label.delete(lb75), label.delete(lbInfo)

    top = math.max(aP, bP)
    bot = math.min(aP, bP)

    // date-range style box from swing to swing
    rBox := box.new(aT, top, bT, bot, xloc = xloc.bar_time, border_color = rangeLine, border_width = 1, bgcolor = rangeFill)
    // entry zone 25–75%, extends to the right
    zBox := box.new(bT, math.max(l25, l75), time, math.min(l25, l75), xloc = xloc.bar_time, extend = extend.right, border_color = color(na), bgcolor = zoneFill)
    // level lines
    ln25 := line.new(aT, l25, time, l25, xloc = xloc.bar_time, extend = extend.right, color = keyCol, width = 2)
    ln75 := line.new(aT, l75, time, l75, xloc = xloc.bar_time, extend = extend.right, color = keyCol, width = 2)
    if showMid
        ln50 := line.new(aT, l50, time, l50, xloc = xloc.bar_time, extend = extend.right, color = midCol, width = 1, style = line.style_dashed)

    // level labels on the right, like TradingView's own fib tool
    lbBg = color.new(#0B0E14, 15)
    lb25 := label.new(bar_index + 12, l25, "25%" + (showPrices ? "  " + fmt(l25) : ""), style = label.style_label_left, color = lbBg, textcolor = keyCol, size = size.normal)
    lb75 := label.new(bar_index + 12, l75, "75%" + (showPrices ? "  " + fmt(l75) : ""), style = label.style_label_left, color = lbBg, textcolor = keyCol, size = size.normal)
    if showMid
        lb50 := label.new(bar_index + 12, l50, "50%" + (showPrices ? "  " + fmt(l50) : ""), style = label.style_label_left, color = lbBg, textcolor = midCol, size = size.small)

    // info label at point B (like the TradingView date range label)
    movePct = (bP - aP) / aP * 100
    bars    = na(aI) or na(bI) ? "" : "   ·   " + str.tostring(bI - aI) + " bars"
    infoTxt = (movePct >= 0 ? "+" : "") + str.tostring(movePct, "#.##") + "%" + bars
    lbInfo := label.new(bT, bP, infoTxt, xloc = xloc.bar_time, style = bull ? label.style_label_down : label.style_label_up, color = rangeLine, textcolor = color.white, size = size.small)

// keep the level labels just right of the newest candle
if barstate.islast and hasSetup and not na(lb25)
    label.set_x(lb25, bar_index + 12)
    label.set_x(lb75, bar_index + 12)
    if showMid and not na(lb50)
        label.set_x(lb50, bar_index + 12)

// live status: how deep is the current pullback?
if barstate.islast and hasSetup and showStatus
    label.delete(lbStat)
    retr = (bP - close) / (bP - aP) * 100
    dp = na(deep) ? retr : math.max(deep, retr)
    txt = ""
    col = color.new(#5E6776, 0)
    if dp > 75
        txt := "INVALID  ·  pullback reached " + str.tostring(dp, "#") + "%\nBeyond 75% of the swing"
        col := color.new(#F6465D, 0)
    else if retr >= 25 and retr <= 75
        txt := "In zone  ·  " + str.tostring(retr, "#") + "%"
        col := color.new(#B8860B, 0)
    else
        txt := "Pullback  ·  " + str.tostring(math.max(retr, 0), "#") + "%"
    lbStat := label.new(bar_index + 2, close, txt, style = label.style_label_left, color = col, textcolor = color.white, size = size.normal)

// ─────────────── Alerts (closed candles) ───────────────
retrC  = hasSetup ? (bP - close) / (bP - aP) * 100 : na
inZone = hasSetup and retrC >= 25 and retrC <= 75 and (na(deep) or deep <= 75)
alertcondition(inZone and not inZone[1], "Price entered the 25–75% zone", "RLT Snapback: price entered the 25–75% zone on {{ticker}} {{interval}}")
alertcondition(auto and justLocked, "New swing locked", "RLT Snapback: new swing A→B locked on {{ticker}} {{interval}}")

// ─────────────── Branding badge ───────────────
pos = brandPos == "Top left" ? position.top_left : brandPos == "Bottom right" ? position.bottom_right : brandPos == "Bottom left" ? position.bottom_left : position.top_right
var table badge = table.new(pos, 1, 2, bgcolor = color.new(#0E131C, 10), border_color = color.new(#F0B90B, 40), border_width = 1, frame_color = color.new(#F0B90B, 40), frame_width = 1)
if barstate.islast
    table.cell(badge, 0, 0, "◆ RLT SNAPBACK", text_color = #F0B90B, text_size = size.normal, text_halign = text.align_left)
    table.cell(badge, 0, 1, "by RAYLIGHT TRADES", text_color = color.new(#F2F4F8, 20), text_size = size.small, text_halign = text.align_left)
````
