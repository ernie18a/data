# Kevindicator

- url: https://www.tradingview.com/script/SlS2etSj-Kevindicator/
- type: indicator
- pine_id: PUB;c172eb06093448ac9579404d9718a6cf
- version: 1.0

## Description

MTF Supply & Demand Zones
A multi-timeframe supply and demand zone indicator that scans the chart's own timeframe and every higher timeframe you enable (15m through 1D) and automatically draws zones based on a strict base-candle → impulse → follow-through pattern.

How zones are detected:
Demand: a small-bodied red base candle with a lower rejection wick, followed by a visibly large green impulse candle (measured against ATR-14) that closes above the base, with no candle closing back inside the zone during the continuation window.
Supply: the mirror image — a small-bodied green base candle with an upper rejection wick, followed by a visibly large red impulse candle that closes below the base.
Zones are boxed from the base candle's open to its wick extreme, and only wicks (not closes) may re-enter the zone while it's forming.

Zone management:
Zones extend live until broken by a 15-minute close through the zone.
Overlap suppression: when a new zone would sit on top of an existing, still-active zone in the same direction, the lower-timeframe zone is dropped — either the new one is skipped, or the older lower-TF zone is replaced by the new higher-TF one. This keeps the chart from filling up with redundant stacked boxes across timeframes.
Auto-hide broken zones: once a zone breaks, it's automatically removed from the chart after a user-set number of hours (1–72), so invalidated zones don't clutter historical price action.

Inputs:
Toggle which timeframes to scan (15m, 30m, 90m, 1H, 2H, 4H, Daily)
Detection sensitivity (base body size, wick size, impulse strength vs. ATR, continuation candle count)
Zone cleanup controls (overlap % threshold, broken-zone hide duration)
Display options (colors, transparency, timeframe labels, 50% equilibrium line, distance-based hiding, alerts on new zone formation)

## Source Code

````pine
//@version=6
// =====================================================================
//  Multi-Timeframe Supply & Demand Zones  (v6)
//  Kevin's method:
//   - Shows the CHART's timeframe and every HIGHER timeframe you enable
//       (15m chart -> 15m/30m/90m/1h/2h/4h/D ; 1h chart -> 1h/90m/2h/4h/D ...).
//       Timeframes below the chart are skipped (Pine can't read them reliably).
//   - DEMAND: single small-body RED base candle WITH a LOWER wick, then a
//       visibly-large GREEN impulse, then follow-through up. Box = Open -> Low.
//   - SUPPLY: single small-body GREEN base candle WITH an UPPER wick, then a
//       visibly-large RED impulse, then follow-through down. Box = High -> Open.
//   - Clean rule: the impulse may not wick past the far side of the base
//       (supply: impulse high <= base high ; demand: impulse low >= base low).
//   - Only WICKS may re-enter the zone while it forms; no candle may CLOSE
//       back inside the zone during the impulse + continuation window.
//   - Timeframe label pinned to the RIGHT EDGE OF THE VISIBLE CHART (by the
//       price scale) at any zoom.
//   - Zones persist & extend until BROKEN by a 15-minute CLOSE (below a demand
//       / above a supply), then are auto-hidden after a configurable number
//       of hours (see "Zone Cleanup" group).
//   - NEW (v6): overlap suppression. When a new zone would overlap an
//       existing, still-active zone (same direction) by more than the
//       configured %, the LOWER-significance timeframe zone is dropped —
//       either the new one is skipped (if the existing zone is equal or
//       higher TF) or the existing one is replaced (if the new zone is a
//       higher TF). This stops 15m/30m/1H/etc. all stacking near-identical
//       boxes on top of one another.
// =====================================================================
indicator("Kevindicator", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ============================== INPUTS ===============================
gTF = "Timeframes to scan (chart TF and higher only)"
useD  = input.bool(true,  "Daily",  group=gTF)
use4H = input.bool(true,  "4 Hour", group=gTF)
use2H = input.bool(true,  "2 Hour", group=gTF)
use1H = input.bool(true,  "1 Hour", group=gTF)
use90 = input.bool(true,  "90 Min", group=gTF)
use30 = input.bool(true,  "30 Min", group=gTF)
use15 = input.bool(true,  "15 Min", group=gTF)

gDet = "Detection"
contCount      = input.int(2,    "Continuation candles after impulse",        minval=1, maxval=10, group=gDet)
baseBodyMaxPct = input.float(0.5, "Max base body (fraction of its range)",     minval=0.05, maxval=0.95, step=0.05, group=gDet)
minWickPct     = input.float(0.15,"Min rejection wick (fraction of base range)",minval=0.0,  maxval=0.9, step=0.01, group=gDet)
impulseAtrMult = input.float(0.8, "Min impulse body (x ATR-14) = 'visibly large'", minval=0.1, step=0.1, group=gDet)
maxAgeDays     = input.int(0,     "Only create zones from last N days (0=all)", minval=0, group=gDet)

gViz = "Display"
maxDistPct  = input.float(0.0, "Hide zones farther than this % from price (0=show all)", minval=0.0, step=0.5, group=gViz)
demandColor = input.color(#26a69a, "Demand color", group=gViz)
supplyColor = input.color(#ef5350, "Supply color", group=gViz)
brokenColor = input.color(#787b86, "Broken color", group=gViz)
bgTransp    = input.int(82, "Zone fill transparency", minval=0, maxval=100, group=gViz)
showLabels  = input.bool(true, "Show timeframe labels", group=gViz)
showMid     = input.bool(true, "Show 50% equilibrium line", group=gViz)
alertsOn    = input.bool(false, "Enable new-zone alerts", group=gViz)

gClean = "Zone Cleanup"
overlapMaxPct   = input.float(50.0, "Skip/replace new zone if it overlaps an existing one by more than (%)", minval=0.0, maxval=100.0, step=5.0, group=gClean, tooltip="Prevents multiple timeframes from stacking near-duplicate boxes in the same area. If a new zone overlaps an existing, still-active zone (same direction) by more than this %, the lower-timeframe one is dropped: the new zone is skipped if the existing zone is equal/higher TF, or the existing zone is removed if the new zone is a higher TF. Set to 100 to disable.")
hideBrokenHours = input.float(4.0,  "Hide broken zones after (hours)", minval=1.0, maxval=72.0, step=1.0, group=gClean, tooltip="A broken zone is removed from the chart this many hours after it broke. Range 1-72 hours.")

// ============================== STATE ================================
var array<float>  zTops = array.new<float>()
var array<float>  zBots = array.new<float>()
var array<bool>   zDem  = array.new<bool>()
var array<bool>   zBrk  = array.new<bool>()
var array<string> zTf   = array.new<string>()
var array<int>    zLeft = array.new<int>()
var array<int>    zBrkT = array.new<int>()   // time (ms) at which the zone broke, na until broken
var array<box>    zBox  = array.new<box>()
var array<label>  zLab  = array.new<label>()
var array<line>   zMid  = array.new<line>()

// ========================= TF PRIORITY / OVERLAP =====================
// Higher timeframe = higher significance = wins when zones overlap.
tfRank(string tf) =>
    switch tf
        "15m" => 1
        "30m" => 2
        "90m" => 3
        "1H"  => 4
        "2H"  => 5
        "4H"  => 6
        "1D"  => 7
        => 0

overlapPct(float t1, float b1, float t2, float b2) =>
    ot = math.min(t1, t2)
    ob = math.max(b1, b2)
    oh = math.max(0.0, ot - ob)
    sh = math.min(t1 - b1, t2 - b2)
    sh > 0 ? oh / sh * 100.0 : 0.0

// ================= DETECTION (evaluated in each HTF) =================
// base = nC+1 bars back, impulse = nC bars back, continuation = nC-1 .. 0
// Returns: demandFlag, dTop, dBot, supplyFlag, sTop, sBot, baseLeftTime, htfBarTime
calc() =>
    nC = contCount
    a  = ta.atr(14)
    bO = open[nC + 1]
    bH = high[nC + 1]
    bL = low[nC + 1]
    bC = close[nC + 1]
    bRange = bH - bL
    bBody  = math.abs(bC - bO)
    iO = open[nC]
    iH = high[nC]
    iL = low[nC]
    iC = close[nC]
    iBody = math.abs(iC - iO)

    baseSmall = bRange > 0 and bBody <= baseBodyMaxPct * bRange
    impBig    = iBody >= impulseAtrMult * a          // "visibly large"

    // min/max close across the impulse + continuation window (indices 0..nC)
    maxC = close[0]
    minC = close[0]
    for k = 1 to nC
        maxC := math.max(maxC, close[k])
        minC := math.min(minC, close[k])

    // ---- DEMAND: red base w/ LOWER wick -> big green -> up ----
    // zone = [bL (bottom), bO (top)]
    baseRed  = bC < bO
    wickOKd  = (bC - bL) >= minWickPct * bRange       // lower wick
    impGreen = iC > iO
    cleanD   = iL >= bL                               // impulse doesn't wick below zone
    dispD    = iC > bO                                // impulse closed above the zone
    holdD    = minC >= bO                             // no candle closes back inside
    demand   = baseRed and baseSmall and wickOKd and impGreen and impBig and cleanD and dispD and holdD

    // ---- SUPPLY: green base w/ UPPER wick -> big red -> down ----
    // zone = [bO (bottom), bH (top)]
    baseGrn  = bC > bO
    wickOKs  = (bH - bC) >= minWickPct * bRange       // upper wick
    impRed   = iC < iO
    cleanS   = iH <= bH                               // impulse doesn't wick above zone
    dispS    = iC < bO                                // impulse closed below the zone
    holdS    = maxC <= bO                             // no candle closes back inside
    supply   = baseGrn and baseSmall and wickOKs and impRed and impBig and cleanS and dispS and holdS

    [demand, bO, bL, supply, bH, bO, time[nC + 1], time]

// ========================= ZONE CREATION ============================
eraseZone(int i) =>
    b = array.get(zBox, i)
    if not na(b)
        box.delete(b)
        array.set(zBox, i, na)
    l = array.get(zLab, i)
    if not na(l)
        label.delete(l)
        array.set(zLab, i, na)
    m = array.get(zMid, i)
    if not na(m)
        line.delete(m)
        array.set(zMid, i, na)

removeZoneAt(int i) =>
    eraseZone(i)
    array.remove(zBox, i)
    array.remove(zLab, i)
    array.remove(zMid, i)
    array.remove(zTops, i)
    array.remove(zBots, i)
    array.remove(zDem, i)
    array.remove(zBrk, i)
    array.remove(zTf, i)
    array.remove(zLeft, i)
    array.remove(zBrkT, i)

makeZone(bool dem, float top, float bot, int leftT, string tflab) =>
    okAge = maxAgeDays == 0 or leftT >= time - maxAgeDays * 86400000
    if okAge and top > bot
        tol = syminfo.mintick * 4
        dup = false
        blockedByHigher = false
        newRank = tfRank(tflab)
        idxToRemove = array.new<int>()
        if array.size(zTops) > 0
            for j = 0 to array.size(zTops) - 1
                if not array.get(zBrk, j) and array.get(zDem, j) == dem
                    exTop = array.get(zTops, j)
                    exBot = array.get(zBots, j)
                    exTf  = array.get(zTf, j)
                    if exTf == tflab and math.abs(exTop - top) <= tol and math.abs(exBot - bot) <= tol
                        // exact duplicate (same tf, same box) - always skip
                        dup := true
                    else if overlapMaxPct < 100.0
                        ov = overlapPct(top, bot, exTop, exBot)
                        if ov > overlapMaxPct
                            exRank = tfRank(exTf)
                            if exRank >= newRank
                                blockedByHigher := true
                            else
                                array.push(idxToRemove, j)
        if not dup and not blockedByHigher
            if array.size(idxToRemove) > 0
                k = array.size(idxToRemove) - 1
                while k >= 0
                    removeZoneAt(array.get(idxToRemove, k))
                    k := k - 1
            box   nab = na
            label nal = na
            line  nil = na
            array.push(zTops, top)
            array.push(zBots, bot)
            array.push(zDem, dem)
            array.push(zBrk, false)
            array.push(zTf, tflab)
            array.push(zLeft, leftT)
            array.push(zBrkT, int(na))
            array.push(zBox, nab)
            array.push(zLab, nal)
            array.push(zMid, nil)
            if alertsOn
                alert((dem ? "Demand" : "Supply") + " zone formed on " + tflab, alert.freq_once_per_bar)

drawZone(int i) =>
    dem = array.get(zDem, i)
    brk = array.get(zBrk, i)
    top = array.get(zTops, i)
    bot = array.get(zBots, i)
    lt  = array.get(zLeft, i)
    tf  = array.get(zTf, i)
    col = brk ? brokenColor : (dem ? demandColor : supplyColor)
    st  = brk ? line.style_dashed : line.style_solid
    b = box.new(lt, top, time, bot, xloc=xloc.bar_time, border_color=col, border_width=1, bgcolor=color.new(col, bgTransp), border_style=st)
    array.set(zBox, i, b)
    if showLabels
        lb = label.new(time, top, tf, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, 10), textcolor=color.white, size=size.small)
        array.set(zLab, i, lb)
    if showMid
        mid = (top + bot) / 2
        ml = line.new(lt, mid, time, mid, xloc=xloc.bar_time, color=color.new(col, 30), style=line.style_dashed, width=1)
        array.set(zMid, i, ml)

// ================= WHICH TIMEFRAMES TO SHOW =========================
// Only the chart timeframe and higher (Pine reads those reliably).
chartSec = timeframe.in_seconds(timeframe.period)
show15 = use15 and timeframe.in_seconds("15")  >= chartSec
show30 = use30 and timeframe.in_seconds("30")  >= chartSec
show90 = use90 and timeframe.in_seconds("90")  >= chartSec
show1H = use1H and timeframe.in_seconds("60")  >= chartSec
show2H = use2H and timeframe.in_seconds("120") >= chartSec
show4H = use4H and timeframe.in_seconds("240") >= chartSec
showDD = useD  and timeframe.in_seconds("1D")  >= chartSec

// ============================ PER-TF SCANS ==========================
[dN15, dT15, dB15, sN15, sT15, sB15, lT15, hT15] = request.security(syminfo.tickerid, "15",  calc(), lookahead=barmerge.lookahead_off)
[dN30, dT30, dB30, sN30, sT30, sB30, lT30, hT30] = request.security(syminfo.tickerid, "30",  calc(), lookahead=barmerge.lookahead_off)
[dN90, dT90, dB90, sN90, sT90, sB90, lT90, hT90] = request.security(syminfo.tickerid, "90",  calc(), lookahead=barmerge.lookahead_off)
[dN1H, dT1H, dB1H, sN1H, sT1H, sB1H, lT1H, hT1H] = request.security(syminfo.tickerid, "60",  calc(), lookahead=barmerge.lookahead_off)
[dN2H, dT2H, dB2H, sN2H, sT2H, sB2H, lT2H, hT2H] = request.security(syminfo.tickerid, "120", calc(), lookahead=barmerge.lookahead_off)
[dN4H, dT4H, dB4H, sN4H, sT4H, sB4H, lT4H, hT4H] = request.security(syminfo.tickerid, "240", calc(), lookahead=barmerge.lookahead_off)
[dND,  dTD,  dBD,  sND,  sTD,  sBD,  lTD,  hTD ] = request.security(syminfo.tickerid, "D",   calc(), lookahead=barmerge.lookahead_off)

f_new(float ht) => na(ht[1]) or ht != ht[1]

if show15 and f_new(hT15)
    if dN15
        makeZone(true,  dT15, dB15, int(lT15), "15m")
    if sN15
        makeZone(false, sT15, sB15, int(lT15), "15m")
if show30 and f_new(hT30)
    if dN30
        makeZone(true,  dT30, dB30, int(lT30), "30m")
    if sN30
        makeZone(false, sT30, sB30, int(lT30), "30m")
if show90 and f_new(hT90)
    if dN90
        makeZone(true,  dT90, dB90, int(lT90), "90m")
    if sN90
        makeZone(false, sT90, sB90, int(lT90), "90m")
if show1H and f_new(hT1H)
    if dN1H
        makeZone(true,  dT1H, dB1H, int(lT1H), "1H")
    if sN1H
        makeZone(false, sT1H, sB1H, int(lT1H), "1H")
if show2H and f_new(hT2H)
    if dN2H
        makeZone(true,  dT2H, dB2H, int(lT2H), "2H")
    if sN2H
        makeZone(false, sT2H, sB2H, int(lT2H), "2H")
if show4H and f_new(hT4H)
    if dN4H
        makeZone(true,  dT4H, dB4H, int(lT4H), "4H")
    if sN4H
        makeZone(false, sT4H, sB4H, int(lT4H), "4H")
if showDD and f_new(hTD)
    if dND
        makeZone(true,  dTD, dBD, int(lTD), "1D")
    if sND
        makeZone(false, sTD, sBD, int(lTD), "1D")

// =============== BREAK / EXTEND / VISIBILITY (every bar) ============
// Break judged on the 15-minute close, regardless of chart timeframe.
c15 = request.security(syminfo.tickerid, "15", close, lookahead=barmerge.lookahead_off)
px  = close

if array.size(zTops) > 0
    for i = 0 to array.size(zTops) - 1
        top = array.get(zTops, i)
        bot = array.get(zBots, i)
        dem = array.get(zDem, i)
        brk = array.get(zBrk, i)
        // --- break detection ---
        if not brk and not na(c15)
            if (dem ? c15 < bot : c15 > top)
                array.set(zBrk, i, true)
                array.set(zBrkT, i, time)
                brk := true
        // --- optional distance-based hiding (0 = show all) ---
        dist    = px >= bot and px <= top ? 0.0 : (px > top ? px - top : bot - px)
        distPct = px != 0 ? dist / px * 100.0 : 0.0
        inRange = maxDistPct <= 0 or distPct <= maxDistPct
        b = array.get(zBox, i)
        if inRange
            if na(b)
                drawZone(i)
            else
                box.set_right(b, time)
                m = array.get(zMid, i)
                if not na(m)
                    line.set_x2(m, time)
                l = array.get(zLab, i)
                if not na(l)
                    label.set_x(l, barstate.islast and not na(chart.right_visible_bar_time) ? int(chart.right_visible_bar_time) : time)
                if brk
                    box.set_bgcolor(b, color.new(brokenColor, bgTransp))
                    box.set_border_color(b, brokenColor)
                    box.set_border_style(b, line.style_dashed)
                    if not na(m)
                        line.set_color(m, color.new(brokenColor, 30))
        else
            if not na(b)
                eraseZone(i)

// ============ PURGE BROKEN ZONES AFTER USER-SET HOURS ================
// Runs every bar (not just at a new session) so the hide-after-N-hours
// setting is honored in real time, from 1 up to 72 hours.
if array.size(zTops) > 0
    i = array.size(zTops) - 1
    while i >= 0
        if array.get(zBrk, i)
            bt = array.get(zBrkT, i)
            if not na(bt) and (time - bt) >= hideBrokenHours * 3600000
                removeZoneAt(i)
        i := i - 1
````
