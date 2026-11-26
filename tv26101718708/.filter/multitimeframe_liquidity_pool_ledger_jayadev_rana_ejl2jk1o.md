# Multi-Timeframe Liquidity Pool Ledger [Jayadev Rana]

- url: https://www.tradingview.com/script/Ejl2jk1o-Multi-Timeframe-Liquidity-Pool-Ledger-Jayadev-Rana/
- type: indicator
- pine_id: PUB;01ef3c2e896b4c3db930d3b68830ca92
- version: 1.0

## Description

WHAT IT IS

Multi-Timeframe Liquidity Pool Ledger finds places where resting orders tend to build up (equal highs and equal lows made of clustered swing points), follows every one of those pools through its life, and keeps a ledger of what happened when price reached them. It is an information tool for traders who think in terms of liquidity and sweeps. It does not produce entry or exit signals.

HOW IT WORKS

1. Swing points from three timeframes. Confirmed pivot highs and lows are taken from the chart timeframe and from two higher timeframes chosen in the inputs. Higher-timeframe pivots are requested without lookahead, so they appear on the chart only after the required number of higher-timeframe bars has closed to the right of the pivot.

2. Clustering into pools. A new swing level is compared with the intact pools on the same side. If it lies within the tolerance (ATR x input) of an existing pool, the pool absorbs it: the touch count increases, the pool price becomes the touch-weighted average and the pool inherits the highest timeframe involved. Otherwise a new pool is created. This is how "equal highs" and "equal lows" are detected without requiring exact ties.

3. Sweep state machine. Each pool is intact until price trades through it. It is then marked swept, and for the next decision window (bars input) the script watches the closes. If a close returns to the original side of the pool inside that window the sweep is logged as rejected; if not, it is logged as accepted. The maximum excursion beyond the pool is recorded in ATR. Resolved pools stay on the chart for a configurable number of bars and are then removed; intact pools expire after a maximum age. The total number of pools is capped.

4. Statistics. Counts of rejected and accepted sweeps are kept separately for buy-side pools (highs) and sell-side pools (lows), giving the historical rejection rate on this chart.

ON THE CHART

Each pool is a horizontal line from the bar of its first swing to the current bar; width grows with the timeframe of the pool and the line turns dotted and grey once the sweep is resolved. The nearest intact pool above and below the close are plotted as step lines. Small triangles mark the bar on which a pool was swept and optional labels show the timeframe and touch count of the swept pool.

THE LEDGER TABLE

A price ladder: the nearest N pools above price (farthest first), a price row with the current close and ATR, then the nearest N pools below. Each row shows the pool price, timeframe, touches, age in bars, distance in ATR and status (intact, swept, rejected, accepted). Below the ladder: pools tracked, sweeps awaiting a decision, expired pools, and the rejection rate of buy-side and sell-side sweeps with the sample size.

INPUTS

Pivot detection: chart pivot strength, two higher timeframes, higher-timeframe pivot strength.
Pool rules: equal-level tolerance in ATR, sweep decision bars, maximum pools, intact-pool expiry, how long resolved pools stay visible.
Display: pool lines, sweep labels, table, pools per side, table position, colours.

ALERTS

Buy-side pool swept, sell-side pool swept, sweep rejected, sweep accepted. Informational only.

INTENDED USE

Any liquid market. Intraday traders can use a 5 or 15 minute chart with 60 and 240 as higher timeframes; swing traders a 1 hour or 4 hour chart with daily and weekly higher timeframes.

LIMITATIONS

Pivots confirm late by construction, so a pool appears only after its right-side bars have closed, and higher-timeframe pools appear later still. The rejection and acceptance statistics describe the loaded history of this chart only and are not forecasts. Data-window plots show the nearest pool distances and counts for alert building or further analysis.

This is an analytical tool, not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
//  Multi-Timeframe Liquidity Pool Ledger [Jayadev Rana]
//  Clusters confirmed swing highs/lows from the chart timeframe and two
//  higher timeframes into "pools" (equal highs / equal lows), tracks every
//  pool through intact -> swept -> rejected / accepted, and keeps a running
//  ledger with touches, age, distance and the historical rejection rate.
//  Information tool only: no entry or exit signals are produced.
// ============================================================================
indicator("Multi-Timeframe Liquidity Pool Ledger [Jayadev Rana]", shorttitle = "MTLPL", overlay = true, max_lines_count = 400, max_labels_count = 200)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gP = "Pivot detection"
lenC   = input.int(5, "Chart pivot strength (bars each side)", minval = 2, maxval = 50, group = gP)
tf2    = input.timeframe("60", "Higher timeframe 1", group = gP)
tf3    = input.timeframe("240", "Higher timeframe 2", group = gP)
lenH   = input.int(3, "HTF pivot strength (bars each side)", minval = 1, maxval = 20, group = gP, tooltip = "Higher-timeframe pivots are confirmed only after this many HTF bars have closed to the right, so they always appear late by design.")

gC = "Pool rules"
tolAtr   = input.float(0.25, "Equal-level tolerance (ATR x)", minval = 0.05, maxval = 2, step = 0.05, group = gC, tooltip = "Two swing levels closer than ATR(14) x this are treated as one pool (equal highs / equal lows).")
confBars = input.int(3, "Sweep decision bars", minval = 1, maxval = 20, group = gC, tooltip = "After a pool is swept, if price closes back on the original side within this many bars the sweep is logged as REJECTED, otherwise as ACCEPTED.")
maxPools = input.int(60, "Max pools tracked", minval = 10, maxval = 200, group = gC)
maxAge   = input.int(1500, "Expire intact pools after (bars)", minval = 100, maxval = 10000, group = gC)
keepRes  = input.int(150, "Keep resolved pools on chart (bars)", minval = 10, maxval = 2000, group = gC)

gD = "Display"
showLines = input.bool(true, "Pool lines", group = gD)
showLbl   = input.bool(true, "Sweep labels", group = gD)
showTbl   = input.bool(true, "Ledger table", group = gD)
nShow     = input.int(4, "Nearest pools per side in table", minval = 1, maxval = 8, group = gD)
tblPos    = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = gD)
cHi = input.color(color.new(#ef5350, 0), "Buy-side pool (above price)", group = gD)
cLo = input.color(color.new(#26a69a, 0), "Sell-side pool (below price)", group = gD)
cRes = input.color(color.new(#787b86, 0), "Resolved pool", group = gD)

// ───────────────────────────── 2. Pivot sources ─────────────────────────────
atr = ta.atr(14)
phC = ta.pivothigh(high, lenC, lenC)
plC = ta.pivotlow(low, lenC, lenC)
[ph2, ph2t] = request.security(syminfo.tickerid, tf2, [ta.pivothigh(high, lenH, lenH), time[lenH]], lookahead = barmerge.lookahead_off)
[pl2, pl2t] = request.security(syminfo.tickerid, tf2, [ta.pivotlow(low, lenH, lenH), time[lenH]], lookahead = barmerge.lookahead_off)
[ph3, ph3t] = request.security(syminfo.tickerid, tf3, [ta.pivothigh(high, lenH, lenH), time[lenH]], lookahead = barmerge.lookahead_off)
[pl3, pl3t] = request.security(syminfo.tickerid, tf3, [ta.pivotlow(low, lenH, lenH), time[lenH]], lookahead = barmerge.lookahead_off)
new2h = not na(ph2) and ph2t != ph2t[1]
new2l = not na(pl2) and pl2t != pl2t[1]
new3h = not na(ph3) and ph3t != ph3t[1]
new3l = not na(pl3) and pl3t != pl3t[1]

// ───────────────────────────── 3. Pool storage ─────────────────────────────
// status: 0 intact, 1 swept (pending decision), 2 rejected, 3 accepted
var float[] pPrice  = array.new_float()
var int[]   pSide   = array.new_int()      // +1 pool of highs, -1 pool of lows
var int[]   pTf     = array.new_int()      // 0 chart, 1 tf2, 2 tf3
var int[]   pTouch  = array.new_int()
var int[]   pBorn   = array.new_int()
var int[]   pStatus = array.new_int()
var int[]   pSweep  = array.new_int()
var float[] pSweepX = array.new_float()    // sweep excursion beyond the pool in ATR
var line[]  pLine   = array.new_line()
var int statRejHi = 0
var int statAccHi = 0
var int statRejLo = 0
var int statAccLo = 0
var int statExpired = 0

tfName(int t) => t == 0 ? timeframe.period : t == 1 ? tf2 : tf3
stName(int s) => s == 0 ? "intact" : s == 1 ? "swept" : s == 2 ? "rejected" : "accepted"

removePool(int i) =>
    ln = array.get(pLine, i)
    if not na(ln)
        line.delete(ln)
    array.remove(pPrice, i)
    array.remove(pSide, i)
    array.remove(pTf, i)
    array.remove(pTouch, i)
    array.remove(pBorn, i)
    array.remove(pStatus, i)
    array.remove(pSweep, i)
    array.remove(pSweepX, i)
    array.remove(pLine, i)

addPivot(float price, int side, int tfIdx, int bornBar) =>
    tol = atr * tolAtr
    int found = -1
    if array.size(pPrice) > 0
        for i = 0 to array.size(pPrice) - 1
            if array.get(pStatus, i) == 0 and array.get(pSide, i) == side and math.abs(array.get(pPrice, i) - price) <= tol
                found := i
                break
    if found >= 0
        t = array.get(pTouch, found)
        // touch-weighted average keeps the pool centred on the cluster
        array.set(pPrice, found, (array.get(pPrice, found) * t + price) / (t + 1))
        array.set(pTouch, found, t + 1)
        array.set(pTf, found, math.max(array.get(pTf, found), tfIdx))
    else
        if array.size(pPrice) >= maxPools
            // drop the oldest resolved pool, else the oldest intact single-touch pool, else the oldest
            int drop = -1
            for i = 0 to array.size(pPrice) - 1
                if array.get(pStatus, i) >= 2
                    drop := i
                    break
            if drop < 0
                for i = 0 to array.size(pPrice) - 1
                    if array.get(pTouch, i) == 1
                        drop := i
                        break
            if drop < 0
                drop := 0
            removePool(drop)
        array.push(pPrice, price)
        array.push(pSide, side)
        array.push(pTf, tfIdx)
        array.push(pTouch, 1)
        array.push(pBorn, bornBar)
        array.push(pStatus, 0)
        array.push(pSweep, 0)
        array.push(pSweepX, 0.0)
        array.push(pLine, showLines ? line.new(bornBar, price, bar_index, price, color = side > 0 ? cHi : cLo, width = 1 + tfIdx) : na)

if not na(phC)
    addPivot(phC, 1, 0, bar_index - lenC)
if not na(plC)
    addPivot(plC, -1, 0, bar_index - lenC)
if new2h
    addPivot(ph2, 1, 1, bar_index)
if new2l
    addPivot(pl2, -1, 1, bar_index)
if new3h
    addPivot(ph3, 1, 2, bar_index)
if new3l
    addPivot(pl3, -1, 2, bar_index)

// ───────────────────────────── 4. Sweep state machine ─────────────────────────────
bool sweptHiNow = false
bool sweptLoNow = false
bool rejNow = false
bool accNow = false
if array.size(pPrice) > 0
    for i = array.size(pPrice) - 1 to 0
        st = array.get(pStatus, i)
        pr = array.get(pPrice, i)
        sd = array.get(pSide, i)
        if st == 0
            if bar_index - array.get(pBorn, i) > maxAge
                statExpired += 1
                removePool(i)
                continue
            swept = sd > 0 ? high > pr : low < pr
            if swept
                array.set(pStatus, i, 1)
                array.set(pSweep, i, bar_index)
                array.set(pSweepX, i, atr > 0 ? (sd > 0 ? (high - pr) : (pr - low)) / atr : 0.0)
                if sd > 0
                    sweptHiNow := true
                else
                    sweptLoNow := true
                if showLbl
                    label.new(bar_index, sd > 0 ? high : low, (sd > 0 ? "sweep " : "sweep ") + tfName(array.get(pTf, i)) + " x" + str.tostring(array.get(pTouch, i)), style = sd > 0 ? label.style_label_down : label.style_label_up, color = color.new(sd > 0 ? cHi : cLo, 30), textcolor = color.white, size = size.tiny)
        else if st == 1
            x = atr > 0 ? (sd > 0 ? (high - pr) : (pr - low)) / atr : 0.0
            if x > array.get(pSweepX, i)
                array.set(pSweepX, i, x)
            back = sd > 0 ? close < pr : close > pr
            if back
                array.set(pStatus, i, 2)
                rejNow := true
                if sd > 0
                    statRejHi += 1
                else
                    statRejLo += 1
            else if bar_index - array.get(pSweep, i) >= confBars
                array.set(pStatus, i, 3)
                accNow := true
                if sd > 0
                    statAccHi += 1
                else
                    statAccLo += 1
        else
            if bar_index - array.get(pSweep, i) > keepRes
                removePool(i)
                continue
        ln = array.get(pLine, i)
        if not na(ln)
            line.set_x2(ln, bar_index)
            if st >= 2
                line.set_color(ln, color.new(cRes, 40))
                line.set_style(ln, line.style_dotted)

// ───────────────────────────── 5. Nearest pools and distances ─────────────────────────────
float nearHi = na
float nearLo = na
int   nearHiTouch = 0
int   nearLoTouch = 0
int   nIntactHi = 0
int   nIntactLo = 0
int   nPending = 0
if array.size(pPrice) > 0
    for i = 0 to array.size(pPrice) - 1
        st = array.get(pStatus, i)
        pr = array.get(pPrice, i)
        if st == 1
            nPending += 1
        if st == 0
            if pr > close
                nIntactHi += 1
                if na(nearHi) or pr < nearHi
                    nearHi := pr
                    nearHiTouch := array.get(pTouch, i)
            else
                nIntactLo += 1
                if na(nearLo) or pr > nearLo
                    nearLo := pr
                    nearLoTouch := array.get(pTouch, i)
distHi = not na(nearHi) and atr > 0 ? (nearHi - close) / atr : na
distLo = not na(nearLo) and atr > 0 ? (close - nearLo) / atr : na

plot(nearHi, "Nearest buy-side pool", color.new(cHi, 20), 2, plot.style_linebr)
plot(nearLo, "Nearest sell-side pool", color.new(cLo, 20), 2, plot.style_linebr)
plot(distHi, "Distance to pool above (ATR)", display = display.data_window)
plot(distLo, "Distance to pool below (ATR)", display = display.data_window)
plot(nIntactHi, "Intact pools above", display = display.data_window)
plot(nIntactLo, "Intact pools below", display = display.data_window)
plot(sweptHiNow ? 1 : 0, "High pool swept", display = display.data_window)
plot(sweptLoNow ? 1 : 0, "Low pool swept", display = display.data_window)
plotshape(sweptHiNow, "Buy-side sweep", shape.triangledown, location.abovebar, color.new(cHi, 0), size = size.tiny)
plotshape(sweptLoNow, "Sell-side sweep", shape.triangleup, location.belowbar, color.new(cLo, 0), size = size.tiny)

// ───────────────────────────── 6. Ledger table ─────────────────────────────
var table tbl = na
cell(int c, int r, string s, color tc = color.white, color bg = na) =>
    table.cell(tbl, c, r, s, text_color = tc, bgcolor = bg, text_size = size.small)
hdr(int r, string a, string b, string c, string d, string e, string f) =>
    bg = color.new(color.gray, 40)
    cell(0, r, a, color.white, bg)
    cell(1, r, b, color.white, bg)
    cell(2, r, c, color.white, bg)
    cell(3, r, d, color.white, bg)
    cell(4, r, e, color.white, bg)
    cell(5, r, f, color.white, bg)
// selection sort of pool indices by distance from the close (small arrays)
sortByDist(int[] idx) =>
    n = array.size(idx)
    if n > 1
        for a = 0 to n - 2
            for b = a + 1 to n - 1
                da = math.abs(array.get(pPrice, array.get(idx, a)) - close)
                db = math.abs(array.get(pPrice, array.get(idx, b)) - close)
                if db < da
                    tmp = array.get(idx, a)
                    array.set(idx, a, array.get(idx, b))
                    array.set(idx, b, tmp)
rate(int rej, int acc) => rej + acc > 0 ? str.tostring(rej / (rej + acc) * 100.0, "#") + "% of " + str.tostring(rej + acc) : "-"
if showTbl and barstate.islast
    pos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : position.bottom_left
    rows = 2 * nShow + 6
    if na(tbl)
        tbl := table.new(pos, 6, rows, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
    hdr(0, "Pool", "TF", "Touch", "Age", "Dist ATR", "Status")
    // collect the nearest intact/pending pools above and below, sorted by distance
    int[] idxHi = array.new_int()
    int[] idxLo = array.new_int()
    if array.size(pPrice) > 0
        for i = 0 to array.size(pPrice) - 1
            if array.get(pStatus, i) <= 1
                if array.get(pPrice, i) > close
                    array.push(idxHi, i)
                else
                    array.push(idxLo, i)
    sortByDist(idxHi)
    sortByDist(idxLo)
    for r = 0 to nShow - 1
        // above rows listed farthest-first so the table reads like a price ladder
        rowA = 1 + r
        k = nShow - 1 - r
        if k < array.size(idxHi)
            i = array.get(idxHi, k)
            st = array.get(pStatus, i)
            cell(0, rowA, str.tostring(array.get(pPrice, i), format.mintick), cHi)
            cell(1, rowA, tfName(array.get(pTf, i)))
            cell(2, rowA, str.tostring(array.get(pTouch, i)))
            cell(3, rowA, str.tostring(bar_index - array.get(pBorn, i)))
            cell(4, rowA, str.tostring((array.get(pPrice, i) - close) / atr, "#.#"))
            cell(5, rowA, stName(st), st == 1 ? color.new(#ffeb3b, 0) : color.white)
        else
            for c = 0 to 5
                cell(c, rowA, "")
    cell(0, nShow + 1, "PRICE", color.new(#ffeb3b, 0), color.new(color.gray, 60))
    table.merge_cells(tbl, 1, nShow + 1, 5, nShow + 1)
    cell(1, nShow + 1, str.tostring(close, format.mintick) + "   ATR " + str.tostring(atr, format.mintick), color.new(#ffeb3b, 0), color.new(color.gray, 60))
    for r = 0 to nShow - 1
        rowB = nShow + 2 + r
        if r < array.size(idxLo)
            i = array.get(idxLo, r)
            st = array.get(pStatus, i)
            cell(0, rowB, str.tostring(array.get(pPrice, i), format.mintick), cLo)
            cell(1, rowB, tfName(array.get(pTf, i)))
            cell(2, rowB, str.tostring(array.get(pTouch, i)))
            cell(3, rowB, str.tostring(bar_index - array.get(pBorn, i)))
            cell(4, rowB, str.tostring((close - array.get(pPrice, i)) / atr, "#.#"))
            cell(5, rowB, stName(st), st == 1 ? color.new(#ffeb3b, 0) : color.white)
        else
            for c = 0 to 5
                cell(c, rowB, "")
    base = 2 * nShow + 2
    hdr(base, "Statistics", "", "", "", "", "")
    cell(0, base + 1, "Tracked / pending")
    table.merge_cells(tbl, 1, base + 1, 5, base + 1)
    cell(1, base + 1, str.tostring(array.size(pPrice)) + " pools, " + str.tostring(nPending) + " swept awaiting decision, " + str.tostring(statExpired) + " expired")
    cell(0, base + 2, "Buy-side sweeps rejected", cHi)
    table.merge_cells(tbl, 1, base + 2, 5, base + 2)
    cell(1, base + 2, rate(statRejHi, statAccHi) + " sweeps (accepted " + str.tostring(statAccHi) + ")")
    cell(0, base + 3, "Sell-side sweeps rejected", cLo)
    table.merge_cells(tbl, 1, base + 3, 5, base + 3)
    cell(1, base + 3, rate(statRejLo, statAccLo) + " sweeps (accepted " + str.tostring(statAccLo) + ")")

// ───────────────────────────── 7. Alerts (informational) ─────────────────────────────
alertcondition(sweptHiNow, "Buy-side pool swept", "Liquidity Ledger: a pool of highs was swept")
alertcondition(sweptLoNow, "Sell-side pool swept", "Liquidity Ledger: a pool of lows was swept")
alertcondition(rejNow, "Sweep rejected", "Liquidity Ledger: a sweep was rejected (close back inside)")
alertcondition(accNow, "Sweep accepted", "Liquidity Ledger: a sweep was accepted (no close back inside)")
````
