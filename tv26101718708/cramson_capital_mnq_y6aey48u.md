# Cramson Capital MNQ

- url: https://www.tradingview.com/script/y6AEy48U-Cramson-Capital-MNQ/
- type: indicator
- pine_id: PUB;81b76413a57947e5b1599417d8c437a3
- version: 1.0

## Description

# Cramson Capital MNQ Strategy

The Cramson Capital MNQ Strategy is a rules-based intraday trading framework built around the Micro E-mini Nasdaq-100 (MNQ) futures market. The strategy combines the opening range, volume profile analysis, and market confirmation to identify high-quality trading opportunities during the most active part of the trading day.

Using the first 15 minutes of the New York session, the indicator automatically calculates the Opening Range High and Low, along with key Volume Profile levels including Value Area High (VAH), Value Area Low (VAL), and Point of Control (POC).

Trades are generated through a structured 3-step process:

1. Price breaks outside the Opening Range.
2. Price retraces back into the Value Area.
3. Price confirms direction by reclaiming Value Area levels and triggering an entry.

Each setup includes predefined risk management levels, stop-loss placement, and profit targets based on risk-to-reward principles, helping traders maintain consistency and discipline.

Whether you're new to futures trading or looking to add a systematic approach to your trading plan, the Cramson Capital MNQ Strategy provides a clear framework for navigating the Nasdaq futures market with confidence and consistency.

## Source Code

````pine
//@version=6
// =============================================================================
//  Opening Range + Value Area — 3-Step Setup
//  - 15-min Opening Range (09:30-09:45 by default)
//  - Volume profile (VAH / VAL / POC) mirrors TradingView's Fixed Range Volume
//    Profile: built at the chart timeframe, proportional volume distribution
//    across tick-aligned rows, standard 70% value-area expansion.
//  - 3-step entry logic, double-closure invalidation, 0.5R TP, 15:45 time close.
//  - Monthly stats table (wins / losses / win% / net ticks) for the current
//    calendar month, auto-resetting at each month rollover.
//  Run on an intraday chart (1m recommended). Times use the timezone input.
//  For alerts choose "Once Per Bar Close".
// =============================================================================
indicator("Cramson Capital MNQ", "Cramson MNQ", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ----------------------------- Inputs ---------------------------------------
gT = "Session & Times"
tz        = input.string("America/New_York", "Timezone", group = gT, tooltip = "Exchange timezone for every time below.")
orStartH  = input.int(9,  "OR start hour",   minval = 0, maxval = 23, group = gT)
orStartM  = input.int(30, "OR start minute", minval = 0, maxval = 59, group = gT)
orEndH    = input.int(9,  "OR end hour",     minval = 0, maxval = 23, group = gT, tooltip = "A candle is in the OR only if it OPENS before this time. So the last included candle is the one that CLOSES at OR end; the candle closing one bar later is excluded.")
orEndM    = input.int(45, "OR end minute",   minval = 0, maxval = 59, group = gT)
cutoffH   = input.int(11, "Entry cutoff hour",   minval = 0, maxval = 23, group = gT)
cutoffM   = input.int(15, "Entry cutoff minute", minval = 0, maxval = 59, group = gT)
exitH     = input.int(15, "Time-close hour",     minval = 0, maxval = 23, group = gT)
exitM     = input.int(45, "Time-close minute",   minval = 0, maxval = 59, group = gT)

// Volume profile is fixed: 24 tick-aligned rows, 70% value area, built at the chart timeframe.
numRows = 24
vaPct   = 70.0

gR = "Risk / Trade"
rMult     = input.float(0.5, "Take profit (R multiple)", minval = 0.1, step = 0.1, group = gR)
worstFill = input.bool(true, "If TP & SL hit same bar, assume SL", group = gR)

gV = "Visuals"
cOR    = input.color(color.orange, "OR high/low", group = gV)
cVA    = input.color(color.blue,   "VAH/VAL",     group = gV)
cPOC   = input.color(color.red,    "POC",         group = gV)
cLong  = input.color(color.lime,   "Long",        group = gV)
cShort = input.color(color.red,    "Short",       group = gV)

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
// A candle is in the OR only if it OPENS at/after start and OPENS before end,
// i.e. the last OR candle is the one that closes exactly at OR end (09:45).
inOR      = curMin >= orStartTot and curMin < orEndTot
newDay    = inOR and not inOR[1]
orEnd     = not inOR and inOR[1]
entriesAllowed = curMin <= cutoffTot

// ----------------------------- State ----------------------------------------
var float orH = na, var float orL = na, var float vah = na, var float val = na, var float poc = na
var bool  orReady = false, var bool validOR = false
var int   st  = 0     // 0 wait-step1, 1 wait-step2, 2 wait-step3, 3 in-trade, 4 done
var int   dir = 0     // 1 long, -1 short
var float entryP = na, var float slP = na, var float tpP = na
var int   orStartTime = na

var array<float> hAr = array.new_float()
var array<float> lAr = array.new_float()
var array<float> vAr = array.new_float()

var line lH = na, var line lL = na, var line lVAH = na, var line lVAL = na, var line lPOC = na
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
        tpr  = math.max(1, int(math.round(rng / numRows / mtick)))   // ticks per row
        rowH = tpr * mtick                                           // tick-aligned row height
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
                // TV tie-break: take the candidate closer to the POC; if equidistant, the upper one
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
        // Only commit & draw a profile that actually has volume (post-09:45 only).
        if totalVol > 0
            vah := orL + (upper + 1) * rowH
            val := orL + lower * rowH         // bottom edge of the lowest VA bucket (matches TradingView FRVP)
            poc := orL + (pocIdx + 0.5) * rowH
            orReady := true
            // draw levels from OR start to the entry cutoff
            yy = year(time, tz), mm = month(time, tz), dd = dayofmonth(time, tz)
            cutoffTs = timestamp(tz, yy, mm, dd, cutoffH, cutoffM)
            lH   := line.new(orStartTime, orH, cutoffTs, orH, xloc = xloc.bar_time, color = cOR, width = 2)
            lL   := line.new(orStartTime, orL, cutoffTs, orL, xloc = xloc.bar_time, color = cOR, width = 2)
            lVAH := line.new(orStartTime, vah, cutoffTs, vah, xloc = xloc.bar_time, color = cVA, width = 1)
            lVAL := line.new(orStartTime, val, cutoffTs, val, xloc = xloc.bar_time, color = cVA, width = 1)
            lPOC := line.new(orStartTime, poc, cutoffTs, poc, xloc = xloc.bar_time, color = cPOC, style = line.style_dashed, width = 1)

// ----------------------------- State machine --------------------------------
if orReady and not inOR
    if st < 3 and not entriesAllowed
        st := 4
    else if st == 0 and entriesAllowed
        bool broke = false
        if close > orH
            st := 1
            dir := 1
            broke := true
        else if close < orL
            st := 1
            dir := -1
            broke := true
        if broke and not na(lH)              // OR broken -> freeze ONLY the OR high/low here; VAH/VAL/POC keep extending to 11:15
            line.set_x2(lH, time_close)
            line.set_x2(lL, time_close)
    else if st == 1
        if (dir == 1 and close < orL) or (dir == -1 and close > orH)
            st := 4
        else if close < vah and close > val
            st := 2
    else if st == 2
        if (dir == 1 and close < orL) or (dir == -1 and close > orH)
            st := 4
        else if (dir == 1 and close > vah) or (dir == -1 and close < val)
            entryP := close
            slP := dir == 1 ? orL : orH
            r = math.abs(entryP - slP)
            tpP := dir == 1 ? entryP + rMult * r : entryP - rMult * r
            st := 3
            longSig  := dir == 1
            shortSig := dir == -1
            lEntry := line.new(time, entryP, time, entryP, xloc = xloc.bar_time, color = color.gray, style = line.style_dotted)
            lSL    := line.new(time, slP,    time, slP,    xloc = xloc.bar_time, color = cShort, width = 1)
            lTP    := line.new(time, tpP,    time, tpP,    xloc = xloc.bar_time, color = cLong,  width = 1)
    else if st == 3
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
            st := 4
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

alertcondition(longSig,  "Long Entry",  "OR+VA long entry triggered")
alertcondition(shortSig, "Short Entry", "OR+VA short entry triggered")

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
    label.new(bar_index, high, "Use an intraday timeframe (1m recommended)", style = label.style_label_down, color = color.red, textcolor = color.white)
````
