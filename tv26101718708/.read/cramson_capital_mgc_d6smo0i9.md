# Cramson Capital MGC

- url: https://www.tradingview.com/script/D6SMo0I9-Cramson-Capital-MGC/
- type: indicator
- pine_id: PUB;5f7713543b954a8a87eff7012cabae0e
- version: 1.0

## Description

# Cramson Capital MGC

A session-based Micro Gold (MGC) tool that builds the opening-range value area and then signals one of two mutually-exclusive plays each day, decided by where price opens relative to that value area.

## Overview

Every trading day the indicator measures a 15-minute opening range (09:30–09:45 New York time) and builds a volume profile across it to derive the Value Area High (VAH), Value Area Low (VAL) and Point of Control (POC). The price at which the candle immediately after the opening range opens — inside or outside the value area — determines which of two setups is live for the rest of the morning. Only one play can occur per day.

## The opening range & value area

The profile is built to mirror TradingView's Fixed Range Volume Profile:

- 15-minute opening range (09:30–09:45), measured by candle open time so the window closes cleanly at 09:45.
- 24 tick-aligned rows, 70% value area.
- Each candle's volume is distributed across the rows it spans, weighted by price overlap.
- The value area expands outward from the POC toward the heavier neighbouring row and stops before the row that would push it past 70%, matching TradingView's published method.
- Resolution is taken from the chart timeframe — run it on a 1-minute chart for the cleanest profile.

VAH, VAL and POC are drawn each day and extend to the 11:15 entry cutoff.

## The two daily plays

The deciding question is where the 09:45 candle opens.

**Value Reversion** — opens OUTSIDE the value area. The indicator waits for a candle to close back inside the value area and enters on that close, targeting the far side of the value area (filling the value). Open above the value area → short toward the VAL. Open below → long toward the VAH. Take profit sits on the far value-area boundary; the stop is a 1:1 mirror of that distance.

**Value Breakout** — opens INSIDE the value area. The indicator waits for a candle to close outside the value area and enters in that direction. The stop is placed at the opposite value-area boundary; take profit is 1:1 with the stop.

Both plays run at a fixed 1:1 risk-to-reward.

## Trade management

- One trade per day.
- New entries are only taken up to 11:15.
- Any position still open is flattened at the configured time-close (3:45pm by default — push it later if you prefer to let trades run to target or stop).
- If a single bar trades through both the take profit and the stop, the result is counted conservatively as a stop (toggleable).

## On-chart visuals

- VAH / VAL / POC lines for each session.
- A daily play label printed at the 09:45 candle: REVERSION ↓, REVERSION ↑, or BREAKOUT, so the morning read is obvious at a glance.
- BUY / SELL entry markers, plus exit markers for take profit (TP), stop (SL) and time-close (T).

## Monthly stats table

A compact table tracks performance for the current calendar month and resets automatically when the month rolls over:

- Wins
- Losses
- Win %
- Net ticks (total winning ticks minus total losing ticks)

## Alerts

Long Entry and Short Entry alert conditions are included. Set the alert to "Once Per Bar Close" so it fires on the confirmed close that the logic is based on.

## Settings

- Timezone and opening-range / cutoff / time-close times.
- Conservative fill assumption when TP and SL share a bar.
- Line, signal and label colours.
- Daily play label on/off.
- Monthly stats table on/off and position.

## Recommended use

Designed for Micro Gold (MGC) on a 1-minute chart during the New York session. The default times reference the US cash open (09:30 ET) and a late-morning wind-down (11:15 ET).

## Disclaimer

This script is provided for educational and analytical purposes only. It is not financial advice and makes no guarantee of future results. Markets carry risk; always test thoroughly and trade within your own risk tolerance.

## Source Code

````pine
//@version=6
// =============================================================================
//  MGC Value Reversion / Breakout  (Cramson Capital gold strategy)
//  - 15-min window (09:30-09:45) used only to build the value area (VAH/VAL)
//    TradingView-style profile as the MNQ tool (24 rows, 70%, chart timeframe).
//  - The 09:45 candle's OPEN decides the day's single play:
//      * Opens OUTSIDE the value area  -> VALUE REVERSION: wait for a candle to close
//        back INSIDE the VA, enter on that close toward the FAR VA side.
//        Take profit = far VA side. Stop = 1:1 mirror of the target distance.
//      * Opens INSIDE the value area    -> VALUE BREAKOUT: wait for a candle to
//        close OUTSIDE the VA, enter in that direction.
//        Stop = opposite VA side. Take profit = 1:1 with the stop.
//  - One trade/day, entries until 11:15, time-close at 11:15 (both adjustable).
//  - Monthly stats table (wins / losses / win% / net ticks), resets each month.
//  Run on a 1-minute chart. Times use the timezone input.
//  For alerts choose "Once Per Bar Close".
// =============================================================================
indicator("Cramson Capital MGC", "Cramson MGC", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ----------------------------- Inputs ---------------------------------------
gT = "Session & Times"
tz        = input.string("America/New_York", "Timezone", group = gT, tooltip = "Exchange timezone for every time below.")
orStartH  = input.int(9,  "OR start hour",   minval = 0, maxval = 23, group = gT)
orStartM  = input.int(30, "OR start minute", minval = 0, maxval = 59, group = gT)
orEndH    = input.int(9,  "OR end hour",     minval = 0, maxval = 23, group = gT, tooltip = "A candle is in the OR only if it OPENS before this time, so the last OR candle is the one that CLOSES at OR end (09:45).")
orEndM    = input.int(45, "OR end minute",   minval = 0, maxval = 59, group = gT)
cutoffH   = input.int(11, "Entry cutoff hour",   minval = 0, maxval = 23, group = gT)
cutoffM   = input.int(15, "Entry cutoff minute", minval = 0, maxval = 59, group = gT)
exitH     = input.int(15, "Time-close hour",     minval = 0, maxval = 23, group = gT, tooltip = "Open trades are flattened at this time (Cramson 'gets off around 11:15'). Push it later if you want trades to run.")
exitM     = input.int(45, "Time-close minute",   minval = 0, maxval = 59, group = gT)

// Volume profile is fixed: 24 tick-aligned rows, 70% value area, built at the chart timeframe.
numRows = 24
vaPct   = 70.0

gR = "Risk / Trade"
worstFill = input.bool(true, "If TP & SL hit same bar, assume SL", group = gR)

gV = "Visuals"
cVA    = input.color(color.blue,   "VAH/VAL",     group = gV)
cPOC   = input.color(color.red,    "POC",         group = gV)
cLong  = input.color(color.lime,   "Long",        group = gV)
cShort = input.color(color.red,    "Short",       group = gV)
showPlayLabel = input.bool(true, "Show daily play label", group = gV)

gS = "Stats Table"
showTbl  = input.bool(true, "Show monthly stats table", group = gS)
tblPosIn = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gS)

mtick = syminfo.mintick

// ----------------------------- Month name helper ----------------------------
f_mName(int m) =>
    switch m
        1 => "Jan"
        2 => "Feb"
        3 => "Mar"
        4 => "Apr"
        5 => "May"
        6 => "Jun"
        7 => "Jul"
        8 => "Aug"
        9 => "Sep"
        10 => "Oct"
        11 => "Nov"
        12 => "Dec"
        => "?"

// ----------------------------- Time helpers ---------------------------------
curMin     = hour(time, tz) * 60 + minute(time, tz)   // bar OPEN time-of-day in tz
orStartTot = orStartH * 60 + orStartM
orEndTot   = orEndH * 60 + orEndM
cutoffTot  = cutoffH * 60 + cutoffM
exitTot    = exitH * 60 + exitM
inOR      = curMin >= orStartTot and curMin < orEndTot
newDay    = inOR and not inOR[1]
orEnd     = not inOR and inOR[1]
entriesAllowed = curMin <= cutoffTot

// ----------------------------- State ----------------------------------------
var float orH = na, var float orL = na, var float vah = na, var float val = na, var float poc = na
var bool  orReady = false, var bool validOR = false
var int   play = 0      // 0 none, 1 value-reversion, 2 value-breakout
var int   revSide = 0   // reversion play only: +1 opened above VAH, -1 opened below VAL
var int   st  = 0       // 0 waiting for trigger, 1 in trade, 2 done
var int   dir = 0       // 1 long, -1 short
var float entryP = na, var float slP = na, var float tpP = na
var int   orStartTime = na

var array<float> hAr = array.new_float()
var array<float> lAr = array.new_float()
var array<float> vAr = array.new_float()

var line lVAH = na, var line lVAL = na, var line lPOC = na
var line lEntry = na, var line lSL = na, var line lTP = na

bool longSig = false, bool shortSig = false
bool tpExit = false, bool slExit = false, bool tExit = false

// ----------------------------- Monthly counters -----------------------------
var int   curWins   = 0
var int   curLosses = 0
var int   curScratch= 0
var float curTicks  = 0.0
var int   trackedMonth = -1

mNow = month(time, tz)
if mNow != trackedMonth
    curWins := 0
    curLosses := 0
    curScratch := 0
    curTicks := 0.0
    trackedMonth := mNow

// ----------------------------- New day reset & accumulation -----------------
if newDay
    array.clear(hAr)
    array.clear(lAr)
    array.clear(vAr)
    play := 0
    revSide := 0
    st := 0
    dir := 0
    orReady := false
    validOR := false
    entryP := na
    slP := na
    tpP := na
    orStartTime := time

if inOR
    array.push(hAr, high)
    array.push(lAr, low)
    array.push(vAr, nz(volume, 0.0))

// ----------------------------- Build TV-style profile at OR end -------------
if orEnd and array.size(hAr) > 0
    orH := array.max(hAr)
    orL := array.min(lAr)
    validOR := orH > orL
    if validOR
        rng = orH - orL
        tpr  = math.max(1, int(math.round(rng / numRows / mtick)))
        rowH = tpr * mtick
        nRows = math.min(500, math.max(1, int(math.ceil(rng / rowH))))
        volByRow = array.new_float(nRows, 0.0)
        n = array.size(hAr)
        for i = 0 to n - 1
            bh = array.get(hAr, i)
            bl = array.get(lAr, i)
            bv = array.get(vAr, i)
            if bh <= bl
                idx = math.max(0, math.min(nRows - 1, int(math.floor((bl - orL) / rowH))))
                array.set(volByRow, idx, array.get(volByRow, idx) + bv)
            else
                loIdx = math.max(0, int(math.floor((bl - orL) / rowH)))
                hiIdx = math.min(nRows - 1, int(math.floor((bh - orL) / rowH)))
                span = bh - bl
                for r = loIdx to hiIdx
                    rBot = orL + r * rowH
                    rTop = rBot + rowH
                    ov = math.min(bh, rTop) - math.max(bl, rBot)
                    if ov > 0
                        array.set(volByRow, r, array.get(volByRow, r) + bv * (ov / span))
        // POC
        pocIdx = 0
        pocVol = -1.0
        for i = 0 to nRows - 1
            v = nz(array.get(volByRow, i), 0.0)
            if v > pocVol
                pocVol := v
                pocIdx := i
        // Value area (TradingView method): expand toward the heavier neighbour,
        // but STOP before adding the row that would push past the target -- that
        // crossing row is NOT included.
        totalVol = array.sum(volByRow)
        target = totalVol * vaPct / 100.0
        upper = pocIdx
        lower = pocIdx
        vaVol = nz(array.get(volByRow, pocIdx), 0.0)
        bool vaDone = false
        while not vaDone and (upper < nRows - 1 or lower > 0)
            vAbove = upper < nRows - 1 ? nz(array.get(volByRow, upper + 1), 0.0) : -1.0
            vBelow = lower > 0 ? nz(array.get(volByRow, lower - 1), 0.0) : -1.0
            bool addUp = false
            if vAbove > vBelow
                addUp := true
            else if vBelow > vAbove
                addUp := false
            else
                distUp = (upper + 1) - pocIdx
                distDn = pocIdx - (lower - 1)
                addUp := distUp <= distDn
            chosen = addUp ? vAbove : vBelow
            if vaVol + chosen <= target      // fits within 70% -> include it
                if addUp
                    upper := upper + 1
                else
                    lower := lower - 1
                vaVol := vaVol + chosen
            else                             // would exceed 70% -> stop, exclude this row
                vaDone := true
        if totalVol > 0
            vah := orL + (upper + 1) * rowH
            val := orL + lower * rowH         // bottom edge of the lowest VA bucket (matches TradingView FRVP)
            poc := orL + (pocIdx + 0.5) * rowH
            orReady := true
            // Decide the day's play from where the 09:45 candle OPENS
            if open > vah
                play := 1
                revSide := 1       // opened above the VA -> revert downward (short)
            else if open < val
                play := 1
                revSide := -1      // opened below the VA -> revert upward (long)
            else if open < vah and open > val
                play := 2          // strictly inside the VA -> breakout
            // else: open sits exactly on VAH or VAL -> no play today
            // draw levels from OR start to the entry cutoff
            yy = year(time, tz), mm = month(time, tz), dd = dayofmonth(time, tz)
            cutoffTs = timestamp(tz, yy, mm, dd, cutoffH, cutoffM)
            lVAH := line.new(orStartTime, vah, cutoffTs, vah, xloc = xloc.bar_time, color = cVA, width = 1)
            lVAL := line.new(orStartTime, val, cutoffTs, val, xloc = xloc.bar_time, color = cVA, width = 1)
            lPOC := line.new(orStartTime, poc, cutoffTs, poc, xloc = xloc.bar_time, color = cPOC, style = line.style_dashed, width = 1)
            if showPlayLabel and play != 0
                ptxt = play == 2 ? "BREAKOUT" : revSide == 1 ? "Value Fill ↓" : "Value Fill ↑"
                pcol = play == 2 ? color.new(color.orange, 15) : color.new(color.teal, 15)
                label.new(time, math.max(high, vah), ptxt, xloc = xloc.bar_time, style = label.style_label_down, color = pcol, textcolor = color.white, size = size.small)

// ----------------------------- State machine --------------------------------
if orReady and not inOR
    // Trade logic
    if st == 0 and not entriesAllowed
        st := 2                              // window closed, no trade today
    else if st == 0 and entriesAllowed
        bool entered = false
        if play == 1
            // VALUE REVERSION: wait for a close back INSIDE the value area
            if close < vah and close > val
                dir := revSide == 1 ? -1 : 1           // above -> short to VAL, below -> long to VAH
                entryP := close
                tpP := dir == 1 ? vah : val            // target the far value-area side
                r = math.abs(entryP - tpP)
                slP := dir == 1 ? entryP - r : entryP + r   // 1:1 mirror of the target
                entered := true
        else if play == 2
            // VALUE BREAKOUT: wait for a close OUTSIDE the value area
            if close > vah or close < val
                dir := close > vah ? 1 : -1
                entryP := close
                slP := dir == 1 ? val : vah            // stop at the opposite value-area side
                r = math.abs(entryP - slP)
                tpP := dir == 1 ? entryP + r : entryP - r   // 1:1 with the stop
                entered := true
        if entered
            st := 1
            longSig  := dir == 1
            shortSig := dir == -1
            lEntry := line.new(time, entryP, time, entryP, xloc = xloc.bar_time, color = color.gray, style = line.style_dotted)
            lSL    := line.new(time, slP,    time, slP,    xloc = xloc.bar_time, color = cShort, width = 1)
            lTP    := line.new(time, tpP,    time, tpP,    xloc = xloc.bar_time, color = cLong,  width = 1)
    else if st == 1
        hitTp  = dir == 1 ? high >= tpP : low  <= tpP
        hitSl  = dir == 1 ? low  <= slP : high >= slP
        timeUp = curMin >= exitTot
        bool  didExit = false
        float exTicks = na
        if hitTp and hitSl
            if worstFill
                slExit := true
                exTicks := dir * (slP - entryP) / mtick
            else
                tpExit := true
                exTicks := dir * (tpP - entryP) / mtick
            didExit := true
        else if hitTp
            tpExit := true
            exTicks := dir * (tpP - entryP) / mtick
            didExit := true
        else if hitSl
            slExit := true
            exTicks := dir * (slP - entryP) / mtick
            didExit := true
        else if timeUp
            tExit := true
            exTicks := dir * (close - entryP) / mtick
            didExit := true
        if didExit
            st := 2
            curTicks := curTicks + exTicks
            if exTicks > 0
                curWins := curWins + 1
            else if exTicks < 0
                curLosses := curLosses + 1
            else
                curScratch := curScratch + 1
        if not na(lEntry)
            line.set_x2(lEntry, time)
            line.set_x2(lSL, time)
            line.set_x2(lTP, time)

// ----------------------------- Signals & alerts -----------------------------
plotshape(longSig,  title = "Buy",  style = shape.triangleup,   location = location.belowbar, color = cLong,  size = size.small, text = "BUY")
plotshape(shortSig, title = "Sell", style = shape.triangledown, location = location.abovebar, color = cShort, size = size.small, text = "SELL")
plotshape(tpExit,   title = "TP",   style = shape.circle, location = location.abovebar, color = color.green, size = size.tiny, text = "TP")
plotshape(slExit,   title = "SL",   style = shape.xcross, location = location.abovebar, color = color.red,   size = size.tiny, text = "SL")
plotshape(tExit,    title = "Time", style = shape.square, location = location.abovebar, color = color.gray,  size = size.tiny, text = "T")

alertcondition(longSig,  "Long Entry",  "MGC value reversion/breakout long entry")
alertcondition(shortSig, "Short Entry", "MGC value reversion/breakout short entry")

// ----------------------------- Monthly stats table --------------------------
tblPos = tblPosIn == "Top Right" ? position.top_right : tblPosIn == "Top Left" ? position.top_left : tblPosIn == "Bottom Right" ? position.bottom_right : position.bottom_left
var table tbl = table.new(tblPos, 2, 5, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

if barstate.islast and showTbl
    hdrBg = color.new(#1e222d, 0)
    cellBg = color.new(#1e222d, 15)
    decided = curWins + curLosses
    wr = decided > 0 ? curWins / decided * 100.0 : 0.0
    netCol = curTicks > 0 ? color.lime : curTicks < 0 ? color.red : color.silver
    table.cell(tbl, 0, 0, "This Month", text_color = color.white, bgcolor = hdrBg, text_halign = text.align_left)
    table.cell(tbl, 1, 0, f_mName(mNow) + " " + str.tostring(year(time, tz)), text_color = color.white, bgcolor = hdrBg, text_halign = text.align_right)
    table.cell(tbl, 0, 1, "Wins", text_color = color.silver, bgcolor = cellBg, text_halign = text.align_left)
    table.cell(tbl, 1, 1, str.tostring(curWins), text_color = color.lime, bgcolor = cellBg, text_halign = text.align_right)
    table.cell(tbl, 0, 2, "Losses", text_color = color.silver, bgcolor = cellBg, text_halign = text.align_left)
    table.cell(tbl, 1, 2, str.tostring(curLosses), text_color = color.red, bgcolor = cellBg, text_halign = text.align_right)
    table.cell(tbl, 0, 3, "Win %", text_color = color.silver, bgcolor = cellBg, text_halign = text.align_left)
    table.cell(tbl, 1, 3, str.tostring(wr, "0.0") + "%", text_color = color.white, bgcolor = cellBg, text_halign = text.align_right)
    table.cell(tbl, 0, 4, "Net (ticks)", text_color = color.silver, bgcolor = cellBg, text_halign = text.align_left)
    table.cell(tbl, 1, 4, str.tostring(curTicks, "0.0"), text_color = netCol, bgcolor = cellBg, text_halign = text.align_right)

if barstate.islast and not timeframe.isintraday
    label.new(bar_index, high, "Use a 1-minute chart", style = label.style_label_down, color = color.red, textcolor = color.white)
````
