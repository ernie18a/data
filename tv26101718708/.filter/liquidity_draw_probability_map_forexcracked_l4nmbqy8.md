# Liquidity Draw Probability Map [ForexCracked]

- url: https://www.tradingview.com/script/l4nMbqY8-Liquidity-Draw-Probability-Map-ForexCracked/
- type: indicator
- pine_id: PUB;1683a4b3270b40c5a07d96c2be32f35c
- version: 4.0

## Description

🔵 OVERVIEW

Every liquidity tool draws the pools. This one measures whether price actually goes there.

The Liquidity Draw Probability Map finds the resting liquidity on your chart, equal highs and lows, the prior day high and low, the prior week high and low, and the session extremes, then studies your chart's own history and prints what actually happened to pools like each one: how often price reached them, how long it took, and how often the touch rejected versus cut straight through.

The phrase "price is drawing on liquidity" gets said a thousand times a day. This script puts a measured number on it.

🔵 HOW THE MEASUREMENT WORKS

Every pool is filed by two things: its type, and how far from price it was born, measured in ATR units so the numbers transfer across symbols and timeframes.

For each combination the script keeps running counts on your chart's own history:

• How many pools like this were created

• How many were reached within 50 bars

• Of the touches, how many rejected (price closed at least 1 ATR back inside within 20 bars) and how many cut through (price closed at least 0.5 ATR beyond). A touch that does neither within the window is filed as a stall.

• The median number of bars it took to get there

Nothing is estimated and nothing comes from outside data. Every figure is a frequency counted on the chart in front of you, and the sample size is printed next to it, so a number built on 12 events never dresses up as a number built on 300.

🔵 THE MAP

Active pools draw as horizontal lines from the swing that created them. The line gets thicker and more solid as its category's measured reach frequency gets higher, so the levels price has historically honoured stand out and the ones it historically ignores fade back. Each pool carries a compact label: type, measured reach frequency, rejection share of touches, and the sample size behind those numbers.

When a pool is touched, a small circle prints on that bar to mark the purge (these are measurement events, not signals, and they can be switched off). The engine then watches the next 20 bars, classifies the outcome, adds it to the tables, and retires the pool. Purged liquidity leaves the map, exactly as it leaves the market.

🔵 WHAT THIS IS NOT

This script fires no signals. There are no buy or sell arrows, no sweep alerts dressed as entries, no order blocks and no fair value gaps. It does not tell you to trade anything. It is a measurement instrument: it maps where the resting liquidity is and reports what historically happened to liquidity like it, with the sample sizes in plain view. What you do with that context is your decision.

🔵 NET DRAW BIAS

Each active pool contributes its measured reach frequency, discounted by how far away it currently sits. Everything above price is summed against everything below, and the result is z-scored against its own recent history. A strongly positive reading means the statistically heavier magnet is overhead. A strongly negative one means it is below. The dashboard prints the score and the direction plainly.

🔵 THE DASHBOARD

• Nearest pool above: type, distance in ATR, measured reach frequency, median bars to reach, sample size

• Nearest pool below: the same

• Net Draw Bias: score and direction

• Last purge: which pool type was taken and how the touch resolved

• Sample: total pools logged and bars of history measured

🔵 HOW TO USE

• Treat high-frequency pools as context, not entries. A pool whose category was historically reached 75 percent of the time within 50 bars is a level price has tended to gravitate toward on this chart. Useful when planning targets, never a trigger on its own.

• Read the rejection versus cut-through split before assuming a reaction. Some categories on some charts get swept and keep going. The split tells you which kind of chart you are on.

• Use Net Draw Bias for directional context between levels. It answers "which side's liquidity is heavier right now" with a measured number instead of a feeling.

• Respect the sample sizes. Early in a chart's history the tables are thin and the map says so. The numbers firm up as history accumulates.

• Combine with your own structure and risk rules. This is a measurement instrument. It does not know your plan.

🔵 SETTINGS

• Pivot strength and equal-level tolerance control how pools are detected

• Reach horizon (default 50 bars) and outcome window (default 20) control the measurement windows

• Session input defines the session whose extremes are tracked, set it to your Asia hours for the classic use

• Max pool age retires stale levels; per-side caps keep the map readable

• Dashboard position, colors, and line extension are adjustable

🔵 ALERTS

• Price approaching a high-reach pool (within 0.25 ATR, category at or above 70 percent with a meaningful sample)

• Pool purged (liquidity taken)

• Net Draw Bias flips sign

⚠️ DISCLAIMER

These are descriptive statistics of past price behaviour on your chart, not predictions. A pool that was historically reached 80 percent of the time can be ignored today. Sample sizes vary by chart and timeframe, and small samples are unreliable by nature. Nothing here is a trade signal, and results depend on market conditions, settings, and your own execution and risk management. Shared for educational and research purposes. Not financial advice.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ForexCracked

//@version=6
indicator("Liquidity Draw Probability Map [ForexCracked]", shorttitle = "LDPM [FXC]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// =====================================================================
// Liquidity Draw Probability Map v1.2 - original work.
// ---------------------------------------------------------------------
// Maps resting liquidity pools (equal highs/lows, prior day H/L, prior
// week H/L, session extremes) and measures, on this chart's own history,
// what happened to pools of each kind:
//
//   reach%  - how often pools of this type and side, born this far from
//             price (in ATR units), were reached within the reach horizon
//   median  - the median bars it took to reach them (6-bin histogram)
//   rej/cut - of the touches whose outcome is settled, how many closed
//             >=1 ATR back inside (rejection) vs >=0.5 ATR beyond
//             (cut-through) by the end of the outcome window; the rest
//             stalled
//
// The engine is a set of conditional frequency tables indexed by
// [pool type x side x distance-at-birth bin], filled strictly forward:
// a pool enters the tables only when its reach window has elapsed (hits
// and misses from the same birth bar are logged together), and a touch only
// when its outcome window ends. A category prints figures only once it
// has a minimum sample. A pool that outlives its reach window untouched
// stays on the map, faded, and no longer borrows its category figures.
// Prior-day/week levels use the documented non-repainting request:
// [1] offset with lookahead_on, so only completed days/weeks are read.
//
// Net Draw Bias sums the measured reach frequency of every pool still
// inside its reach window, discounted by current distance, above minus below, and z-scores the
// result against its own history: "which side is the magnet", as a
// number.
//
// No signals, no arrows, no win rates. Frequencies with sample sizes.
// =====================================================================

// ---------------- INPUTS ----------------
gD = "Detection"
pivLen  = input.int(5, "Pivot strength (bars)", minval = 2, maxval = 20, group = gD, tooltip = "Swings need this many bars each side to confirm. Pools appear only after confirmation, so nothing repaints.")
eqTolF  = input.float(0.25, "Equal-level tolerance (x ATR)", minval = 0.05, step = 0.05, group = gD, tooltip = "Two confirmed swings this close together form an equal-high or equal-low pool.")
useEQ   = input.bool(true, "Equal highs / lows", group = gD)
usePD   = input.bool(true, "Prior day high / low", group = gD)
usePW   = input.bool(true, "Prior week high / low", group = gD)
useSES  = input.bool(true, "Session high / low (intraday only)", group = gD)
sessStr = input.session("0000-0800", "Session", group = gD, tooltip = "The session whose completed extremes become pools. Default is the classic Asia window; adjust to your market.")
sessTz  = input.string("GMT", "Session timezone", options = ["GMT", "America/New_York", "Europe/London", "Asia/Tokyo", "Asia/Singapore", "Australia/Sydney"], group = gD)

gM = "Measurement"
reachK  = input.int(50, "Reach horizon (bars)", minval = 10, maxval = 60, group = gM, tooltip = "A pool counts as reached only if price touches it within this many bars of its creation. The median readout tops out at 45 bars.")
outWin  = input.int(20, "Outcome window (bars)", minval = 5, maxval = 100, group = gM, tooltip = "The touch bar and the next bars decide the outcome: close >=0.5 ATR beyond = cut-through, close >=1 ATR back inside = rejection, neither by the end of the window = stall.")
nMin    = input.int(20, "Minimum sample to print a figure", minval = 5, maxval = 200, group = gM, tooltip = "A category prints its percentages only after this many of its pools have finished their reach window (and rejection/cut shares only after this many settled touches). Until then the label reads building, with the count so far.")
maxAge  = input.int(400, "Max pool age (bars)", minval = 60, group = gM)
maxPool = input.int(30, "Max active pools", minval = 10, maxval = 60, group = gM)

gS = "Style"
colUp   = input.color(#e84e89, "Pools above price", group = gS)
colDn   = input.color(#2dd4bf, "Pools below price", group = gS)
showPrg = input.bool(true, "Purge markers", group = gS, tooltip = "Small circles on the bar a pool was touched. They mark measurement events, not signals.")
extendN = input.int(15, "Extend lines right (bars)", minval = 0, maxval = 100, group = gS)
showLbl = input.bool(true, "Pool stat labels", group = gS)
showTbl = input.bool(true, "Dashboard", group = gS)
tblPosIn = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gS)
tblPos = tblPosIn == "Top Left" ? position.top_left : tblPosIn == "Bottom Right" ? position.bottom_right : tblPosIn == "Bottom Left" ? position.bottom_left : position.top_right

atr = ta.atr(14)

// ---------------- FREQUENCY TABLES ----------------
// cell = (type*2 + side)*4 + distance bin
// types: 0=EQ 1=PD 2=PW 3=SES | side: 1 = high (buy-side), 0 = low (sell-side)
// distance bins (ATR at birth): 0: <0.5 | 1: 0.5-1 | 2: 1-2 | 3: >=2
var tCreated = array.new<int>(32, 0)   // pools whose reach window has closed
var tReach   = array.new<int>(32, 0)
var tTouch   = array.new<int>(32, 0)   // touches whose outcome is settled
var tReject  = array.new<int>(32, 0)
var tCut     = array.new<int>(32, 0)
// bars-to-reach histogram: 6 bins per cell (1-5, 6-10, 11-20, 21-30, 31-40, 41+)
var hBars    = array.new<int>(192, 0)

cellOf(int typ, bool isHi, int bin) =>
    (typ * 2 + (isHi ? 1 : 0)) * 4 + bin

distBin(float dAtr) =>
    dAtr < 0.5 ? 0 : dAtr < 1.0 ? 1 : dAtr < 2.0 ? 2 : 3

barsBin(int b) =>
    b <= 5 ? 0 : b <= 10 ? 1 : b <= 20 ? 2 : b <= 30 ? 3 : b <= 40 ? 4 : 5

// measured reach frequency for a cell, 0-100; na until the cell has nMin pools
reachPct(int cell) =>
    c = array.get(tCreated, cell)
    c >= nMin ? 100.0 * array.get(tReach, cell) / c : na

rejectPct(int cell) =>
    t = array.get(tTouch, cell)
    t >= nMin ? 100.0 * array.get(tReject, cell) / t : na

cutPct(int cell) =>
    t = array.get(tTouch, cell)
    t >= nMin ? 100.0 * array.get(tCut, cell) / t : na

// streaming median bars-to-reach from the cell's histogram (needs 8+ reaches)
medBars(int cell) =>
    total = array.get(tReach, cell)
    if total < 8
        na
    else
        half = (total + 1) / 2
        acc = 0
        med = 45.0
        done = false
        mids = array.from(3.0, 8.0, 15.0, 25.0, 35.0, 45.0)
        for j = 0 to 5
            if not done
                acc := acc + array.get(hBars, cell * 6 + j)
                if acc >= half
                    med := array.get(mids, j)
                    done := true
        med

// ---------------- POOL STATE (parallel arrays) ----------------
var pPrice   = array.new<float>()
var pType    = array.new<int>()     // 0 EQ, 1 PD, 2 PW, 3 SES
var pHigh    = array.new<bool>()    // true = high / buy-side pool (above price)
var pBirth   = array.new<int>()
var pAnchor  = array.new<int>()     // bar where the level visually starts
var pBin     = array.new<int>()
var pState   = array.new<int>()     // 0 waiting, 1 outcome window
var pTouchB  = array.new<int>()
var pTouchA  = array.new<float>()   // ATR at touch
var pCounted = array.new<bool>()    // reach result logged (a waiting pool with this set is past its window)
var pOut     = array.new<int>()     // outcome decided inside the window: 0 none yet, 1 reject, 2 cut

// reached pools wait here until their reach window has elapsed, so hits and
// misses from the same birth bar enter the tables on the same bar
var qDue  = array.new<int>()
var qCell = array.new<int>()
var qAge  = array.new<int>()

removePool(int i) =>
    array.remove(pPrice, i), array.remove(pType, i), array.remove(pHigh, i)
    array.remove(pBirth, i), array.remove(pAnchor, i), array.remove(pBin, i)
    array.remove(pState, i), array.remove(pTouchB, i), array.remove(pTouchA, i)
    array.remove(pCounted, i), array.remove(pOut, i)

addPool(float price, int typ, int anchor, bool isHi) =>
    if not na(price) and not na(atr) and atr > 0
        // a level price has already traded through is no longer resting liquidity
        taken = isHi ? high >= price : low <= price
        // only a waiting pool still inside its reach window blocks a twin; a stale
        // twin (fully logged) is replaced, a touched one is no longer resting
        dup = false
        staleTwin = -1
        n = array.size(pPrice)
        if n > 0
            for i = 0 to n - 1
                if array.get(pState, i) == 0 and array.get(pType, i) == typ and array.get(pHigh, i) == isHi and math.abs(array.get(pPrice, i) - price) <= 0.1 * atr
                    if array.get(pCounted, i)
                        staleTwin := i
                    else
                        dup := true
        if not dup and not taken
            if staleTwin >= 0
                removePool(staleTwin)
            // at the cap, make room only by dropping a fully logged (stale) pool;
            // if none exists the newcomer is skipped, so no pending measurement is
            // thrown away and eviction never depends on how a pool turns out
            if array.size(pPrice) >= maxPool
                ev = -1
                for k = 0 to array.size(pPrice) - 1
                    if ev < 0 and array.get(pState, k) == 0 and array.get(pCounted, k)
                        ev := k
                if ev >= 0
                    removePool(ev)
            if array.size(pPrice) < maxPool
                bin = distBin(math.abs(price - close) / atr)
                array.push(pPrice, price),  array.push(pType, typ),   array.push(pHigh, isHi)
                array.push(pBirth, bar_index), array.push(pAnchor, anchor), array.push(pBin, bin)
                array.push(pState, 0), array.push(pTouchB, 0), array.push(pTouchA, 0.0)
                array.push(pCounted, false), array.push(pOut, 0)

// ---------------- POOL CREATION ----------------
// Equal highs / lows: two consecutive confirmed pivots within tolerance
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
var float lastPH = na
var float lastPL = na
if useEQ and not na(ph)
    if not na(lastPH) and math.abs(ph - lastPH) <= eqTolF * atr
        addPool(math.max(ph, lastPH), 0, bar_index - pivLen, true)
    lastPH := ph
if useEQ and not na(pl)
    if not na(lastPL) and math.abs(pl - lastPL) <= eqTolF * atr
        addPool(math.min(pl, lastPL), 0, bar_index - pivLen, false)
    lastPL := pl

// Prior day / prior week levels: completed bars only ([1] + lookahead_on is
// the documented non-repainting form; history and realtime read the same bar)
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
newDay  = timeframe.change("D")
newWeek = timeframe.change("W")
// prior-day pools need an intraday chart, prior-week pools need daily or faster;
// on D+ charts timeframe.change fires every bar and would churn meaningless pools
pdOk = timeframe.in_seconds() < timeframe.in_seconds("D")
pwOk = timeframe.in_seconds() < timeframe.in_seconds("W")
if usePD and pdOk and newDay
    addPool(pdh, 1, bar_index, true)
    addPool(pdl, 1, bar_index, false)
if usePW and pwOk and newWeek
    addPool(pwh, 2, bar_index, true)
    addPool(pwl, 2, bar_index, false)

// Session extremes: pools form when the session completes
inSess = useSES and timeframe.isintraday and not na(time(timeframe.period, sessStr, sessTz))
var float sesHi = na
var float sesLo = na
var int   sesStart = na
if inSess and not inSess[1]
    sesHi := high
    sesLo := low
    sesStart := bar_index
else if inSess
    sesHi := math.max(sesHi, high)
    sesLo := math.min(sesLo, low)
if not inSess and inSess[1] and not na(sesHi)
    addPool(sesHi, 3, sesStart, true)
    addPool(sesLo, 3, sesStart, false)

// ---------------- LIFECYCLE ENGINE ----------------
purgedHi = false
purgedLo = false
nearDraw = false
var string lastPurgeTxt = "none yet"
typeNameOf(int typ, bool isHi) =>
    typ == 0 ? (isHi ? "EQH" : "EQL") : typ == 1 ? (isHi ? "PDH" : "PDL") : typ == 2 ? (isHi ? "PWH" : "PWL") : (isHi ? "SES H" : "SES L")

if array.size(pPrice) > 0 and not na(atr) and atr > 0
    i = array.size(pPrice) - 1
    while i >= 0
        price = array.get(pPrice, i)
        typ   = array.get(pType, i)
        isHi  = array.get(pHigh, i)
        cell  = cellOf(typ, isHi, array.get(pBin, i))
        age   = bar_index - array.get(pBirth, i)
        gone  = false
        if array.get(pState, i) == 0
            touched = isHi ? high >= price : low <= price
            // the reach window is ages 1..reachK; a miss is logged when it elapses,
            // a hit is queued and logged on that same bar
            if not array.get(pCounted, i) and (touched or age >= reachK)
                array.set(pCounted, i, true)
                if touched and age <= reachK
                    array.push(qDue, array.get(pBirth, i) + reachK)
                    array.push(qCell, cell)
                    array.push(qAge, age)
                else
                    array.set(tCreated, cell, array.get(tCreated, cell) + 1)
            if touched
                array.set(pState, i, 1)
                array.set(pTouchB, i, bar_index)
                array.set(pTouchA, i, atr)
                if isHi
                    purgedHi := true
                else
                    purgedLo := true
            else if age > maxAge
                removePool(i)
                gone := true
            else if not array.get(pCounted, i)
                dNow = math.abs(price - close) / atr
                rp = reachPct(cell)
                if dNow <= 0.25 and not na(rp) and rp >= 70 and array.get(tCreated, cell) >= 30
                    nearDraw := true
        // outcome window: the touch bar and the next outWin bars; every touch is
        // tallied when the window ends, so stalls are never under-counted
        if not gone
            if array.get(pState, i) == 1
                tb  = array.get(pTouchB, i)
                ta1 = array.get(pTouchA, i)
                outcome = array.get(pOut, i)
                if outcome == 0
                    if isHi
                        if close >= price + 0.5 * ta1
                            outcome := 2
                        else if close <= price - 1.0 * ta1
                            outcome := 1
                    else
                        if close <= price - 0.5 * ta1
                            outcome := 2
                        else if close >= price + 1.0 * ta1
                            outcome := 1
                    if outcome != 0
                        array.set(pOut, i, outcome)
                        lastPurgeTxt := typeNameOf(typ, isHi) + (outcome == 1 ? " rejected" : " cut through")
                if bar_index - tb >= outWin
                    array.set(tTouch, cell, array.get(tTouch, cell) + 1)
                    if outcome == 1
                        array.set(tReject, cell, array.get(tReject, cell) + 1)
                    else if outcome == 2
                        array.set(tCut, cell, array.get(tCut, cell) + 1)
                    else
                        lastPurgeTxt := typeNameOf(typ, isHi) + " stalled"
                    removePool(i)
        i := i - 1

// queued hits enter the tables once their reach window has elapsed
if array.size(qDue) > 0
    q = array.size(qDue) - 1
    while q >= 0
        if bar_index >= array.get(qDue, q)
            qc = array.get(qCell, q)
            qb = qc * 6 + barsBin(array.get(qAge, q))
            array.set(tCreated, qc, array.get(tCreated, qc) + 1)
            array.set(tReach, qc, array.get(tReach, qc) + 1)
            array.set(hBars, qb, array.get(hBars, qb) + 1)
            array.remove(qDue, q)
            array.remove(qCell, q)
            array.remove(qAge, q)
        q := q - 1

// ---------------- NET DRAW BIAS ----------------
// only pools still inside their reach window, in categories with the minimum sample
netRaw = 0.0
if array.size(pPrice) > 0 and not na(atr) and atr > 0
    for i = 0 to array.size(pPrice) - 1
        if array.get(pState, i) == 0 and not array.get(pCounted, i)
            cell = cellOf(array.get(pType, i), array.get(pHigh, i), array.get(pBin, i))
            rp = reachPct(cell)
            if not na(rp)
                dNow = math.abs(array.get(pPrice, i) - close) / atr
                w = rp / (dNow + 0.5)
                netRaw := netRaw + (array.get(pPrice, i) > close ? w : -w)
biasMean = ta.sma(netRaw, 250)
biasSd   = ta.stdev(netRaw, 250)
biasZ    = biasSd > 0 ? (netRaw - biasMean) / biasSd : 0.0
biasSide = biasZ > 0.5 ? 1 : biasZ < -0.5 ? -1 : 0
var int lastSide = 0
biasFlip = biasSide != 0 and lastSide != 0 and biasSide != lastSide
if biasSide != 0
    lastSide := biasSide

// ---------------- VISUALS (rebuilt on the last bar only) ----------------
var vLines = array.new<line>()
var vLbls  = array.new<label>()
if barstate.islast
    while array.size(vLines) > 0
        line.delete(array.pop(vLines))
    while array.size(vLbls) > 0
        label.delete(array.pop(vLbls))
    if array.size(pPrice) > 0
        for i = 0 to array.size(pPrice) - 1
            if array.get(pState, i) == 0
                price = array.get(pPrice, i)
                isHi  = array.get(pHigh, i)
                stale = array.get(pCounted, i)   // untouched past its reach window: category figures no longer apply
                cell  = cellOf(array.get(pType, i), isHi, array.get(pBin, i))
                float rp = na
                if not stale
                    rp := reachPct(cell)
                nC    = array.get(tCreated, cell)
                base  = isHi ? colUp : colDn
                wdt   = not na(rp) and rp >= 70 and nC >= 30 ? 3 : not na(rp) and rp >= 50 ? 2 : 1
                trans = not na(rp) ? int(math.max(10, 70 - rp * 0.6)) : 70
                array.push(vLines, line.new(array.get(pAnchor, i), price, bar_index + extendN, price, color = color.new(base, trans), width = wdt))
                if showLbl
                    rj = rejectPct(cell)
                    md = medBars(cell)
                    nT = array.get(tTouch, cell)
                    nm = typeNameOf(array.get(pType, i), isHi)
                    txt = nm + " · past " + str.tostring(reachK) + "-bar window"
                    if not stale
                        txt := nm
                          + (not na(rp) ? " · reach " + str.tostring(math.round(rp)) + "% of " + str.tostring(nC) : nC > 0 ? " · building n" + str.tostring(nC) : " · no data yet")
                          + (not na(rp) and not na(md) ? " · med " + str.tostring(math.round(md)) + "b" : "")
                          + (not na(rp) and not na(rj) ? " · rej " + str.tostring(math.round(rj)) + "% · cut " + str.tostring(math.round(cutPct(cell))) + "% of " + str.tostring(nT) + " touches" : "")
                    array.push(vLbls, label.new(bar_index + extendN, price, txt, style = isHi ? label.style_label_lower_right : label.style_label_upper_right, color = color.new(#1a2c4c, 25), textcolor = color.new(base, 0), size = size.tiny))

plotshape(showPrg and purgedHi, "Buy-side purged", shape.circle, location.abovebar, color.new(#e84e89, 40), size = size.tiny, display = display.pane)
plotshape(showPrg and purgedLo, "Sell-side purged", shape.circle, location.belowbar, color.new(#2dd4bf, 40), size = size.tiny, display = display.pane)

// ---------------- DASHBOARD ----------------
if showTbl and barstate.islast
    var table t = table.new(tblPos, 5, 6, bgcolor = #1a2c4c, frame_color = color.new(color.gray, 55), frame_width = 1, border_color = color.new(#2a3d63, 25), border_width = 1)
    hd  = #1f3a63
    lbl = #9fb0c4
    table.cell(t, 0, 0, " LIQUIDITY DRAW ", text_color = color.white, bgcolor = hd, text_size = size.small)
    table.cell(t, 1, 0, "Type", text_color = lbl, bgcolor = hd, text_size = size.tiny)
    table.cell(t, 2, 0, "Dist", text_color = lbl, bgcolor = hd, text_size = size.tiny)
    table.cell(t, 3, 0, "Reach", text_color = lbl, bgcolor = hd, text_size = size.tiny)
    table.cell(t, 4, 0, "Med", text_color = lbl, bgcolor = hd, text_size = size.tiny)
    nearUpI = -1
    nearDnI = -1
    if array.size(pPrice) > 0
        for i = 0 to array.size(pPrice) - 1
            if array.get(pState, i) == 0
                p = array.get(pPrice, i)
                if p > close and (nearUpI < 0 or p < array.get(pPrice, nearUpI))
                    nearUpI := i
                if p < close and (nearDnI < 0 or p > array.get(pPrice, nearDnI))
                    nearDnI := i
    for r = 1 to 2
        idx = r == 1 ? nearUpI : nearDnI
        cAcc = r == 1 ? #e84e89 : #2dd4bf
        table.cell(t, 0, r, r == 1 ? "Above" : "Below", text_color = cAcc, text_size = size.tiny)
        if idx >= 0 and not na(atr) and atr > 0
            cell = cellOf(array.get(pType, idx), array.get(pHigh, idx), array.get(pBin, idx))
            stl = array.get(pCounted, idx)
            rp = reachPct(cell)
            md = medBars(cell)
            nC = array.get(tCreated, cell)
            reachTxt = stl ? "past window" : not na(rp) ? str.tostring(math.round(rp)) + "% of " + str.tostring(nC) : nC > 0 ? "building n" + str.tostring(nC) : "no data"
            table.cell(t, 1, r, typeNameOf(array.get(pType, idx), array.get(pHigh, idx)), text_color = color.white, text_size = size.tiny)
            table.cell(t, 2, r, str.tostring(math.abs(array.get(pPrice, idx) - close) / atr, "#.0") + " ATR", text_color = lbl, text_size = size.tiny)
            table.cell(t, 3, r, reachTxt, text_color = cAcc, text_size = size.tiny)
            table.cell(t, 4, r, not stl and not na(rp) and not na(md) ? str.tostring(math.round(md)) + "b" : "-", text_color = lbl, text_size = size.tiny)
        else
            table.cell(t, 1, r, "-", text_color = lbl, text_size = size.tiny)
            table.cell(t, 2, r, "-", text_color = lbl, text_size = size.tiny)
            table.cell(t, 3, r, "-", text_color = lbl, text_size = size.tiny)
            table.cell(t, 4, r, "-", text_color = lbl, text_size = size.tiny)
    table.cell(t, 0, 3, "Net Draw Bias", text_color = lbl, text_size = size.tiny)
    table.cell(t, 1, 3, str.tostring(biasZ, "#.00"), text_color = biasSide == 1 ? #e84e89 : biasSide == -1 ? #2dd4bf : color.white, text_size = size.tiny)
    table.cell(t, 2, 3, biasSide == 1 ? "magnet above" : biasSide == -1 ? "magnet below" : "balanced", text_color = color.white, text_size = size.tiny)
    table.cell(t, 3, 3, "", text_size = size.tiny)
    table.cell(t, 4, 3, "", text_size = size.tiny)
    table.cell(t, 0, 4, "Last purge", text_color = lbl, text_size = size.tiny)
    table.cell(t, 1, 4, lastPurgeTxt, text_color = color.white, text_size = size.tiny)
    table.cell(t, 2, 4, "", text_size = size.tiny)
    table.cell(t, 3, 4, "", text_size = size.tiny)
    table.cell(t, 4, 4, "", text_size = size.tiny)
    totalCreated = 0
    for c = 0 to 31
        totalCreated := totalCreated + array.get(tCreated, c)
    table.cell(t, 0, 5, "Sample", text_color = lbl, text_size = size.tiny)
    table.cell(t, 1, 5, str.tostring(totalCreated) + " pools measured", text_color = lbl, text_size = size.tiny)
    table.cell(t, 2, 5, str.tostring(bar_index + 1) + " bars", text_color = lbl, text_size = size.tiny)
    table.cell(t, 3, 5, "", text_size = size.tiny)
    table.cell(t, 4, 5, "", text_size = size.tiny)

// ---------------- ALERTS ----------------
alertcondition(nearDraw, title = "Approaching high-draw pool", message = "Price is within 0.25 ATR of a high-reach liquidity pool on {{ticker}} {{interval}}")
alertcondition(purgedHi or purgedLo, title = "Liquidity purged", message = "A liquidity pool was just taken on {{ticker}} {{interval}}")
alertcondition(biasFlip, title = "Net Draw Bias flip", message = "Net Draw Bias verdict flipped between magnet above and magnet below on {{ticker}} {{interval}}")
````
