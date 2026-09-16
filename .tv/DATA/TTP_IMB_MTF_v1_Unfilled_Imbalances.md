<!-- tradingview-pine-id: PUB;65dc8949c87f4ec2a851f7f846267890 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# TTP IMB MTF v1 - Unfilled Imbalances

Source: https://www.tradingview.com/script/V27gem2X-TTP-IMB-Unfilled-Imbalances/

## Description

What it draws
Unfilled imbalances — three-bar fair value gaps — from four timeframes at once (4H, 1D, 1W, 1M by default, all configurable), rendered on whatever chart timeframe you are on. Switching the chart resolution does not change the levels: a weekly gap keeps the same two prices whether you are looking at 4H or 1D.

A gap is defined by wicks across a three-bar window:

bullish — the high of the first bar is below the low of the third
bearish — the low of the first bar is above the high of the third
The box spans exactly those two extremes.

When a gap stops being drawn
Once price has overlapped 66.6% of the box's ORIGINAL height, measured from the side price enters by. A bullish gap dies when price falls that far into it from the top; a bearish gap when price rises that far from the bottom. A wick is enough by default — there is a setting to require a close instead, which leaves noticeably more zones alive.

The threshold is adjustable. 100 means only a complete traverse closes a zone, 50 is the classic midpoint rule.

Partially overlapped zones keep their full original geometry — the box does not shrink, so you can always see the imbalance as it was formed.

Fading
A zone price has already eaten at least 50% into, but which has not reached the closing threshold, is drawn faded and labelled with its fill percentage. This separates an untouched imbalance from one that has already been worked, without hiding either.

Multiplicative search band
Zones lying entirely outside a band around current price are discarded before anything else. That band is a RATIO — price/N up to price*N, N=2 by default — not a percentage.

This matters more than it sounds. A symmetric percentage band is badly lopsided, because price moves in multiples: −80% is 0.2x, a five-fold drop, practically zero, while +80% is only 1.8x, a couple of levels. Equal ratios up and down is what a log chart actually shows.

Timeframe gating
Only timeframes at or above the chart's own are computed, and only up to a ceiling of N rungs above it (2 by default). On a 4H chart that gives 4H/1D/1W and drops the monthly; on a daily chart, 1D/1W/1M. Timeframes below the chart are never drawn — they would be hairlines — and are not calculated at all.

Set the ceiling to 3 to see everything at or above the chart, or to 0 for the chart's own timeframe only.

How much is shown
Per timeframe: the N nearest unfilled zones above price and N below (3 each by default), plus every zone that currently CONTAINS price — those are the operative ones and are never rationed away.

Border thickness increases with timeframe, so the hierarchy reads at a glance.

Settings worth knowing
Filled at (%) — closing threshold, default 66.6
A wick is enough to fill — off requires a bar close beyond the threshold
Zones per side, per TF — default 3
Search range (xN) — multiplicative band, default 2
Dim a zone once filled (%) — fading threshold, default 50
Rungs above chart TF — the gating ceiling, default 2
Ignore zones thinner than (%) — optional micro-gap filter, off by default
Notes and limitations
The still-forming higher-timeframe bar cannot CREATE a zone — that would repaint intrabar — but it does count toward FILLING one, so a zone can die live as price moves into it. Everything else is closed-bar only.

Buffers fill only as far back as the chart's own loaded history reaches. On a 4H chart covering roughly two years, the monthly buffer holds about two dozen months rather than the full setting. This does not affect zones near price, which is all the script draws.

The gap scan is linear in the number of bars. The "has this gap been filled" test is answered with suffix extremes rather than a nested scan over later bars, which is what keeps four timeframes inside the execution budget instead of timing out.

This is a visualisation tool. It marks structural levels and does not generate entry or exit signals.

---

## Source Code

````pine
//@version=6
// TTP IMB MTF v1 - unfilled imbalances (3-bar FVG) on 4H / 1D / 1W / 1M, drawn on ANY
// chart timeframe. Companion to "TTP MTF v6 - Trend Turning Points (rec)"; deliberately
// a SEPARATE script so it gets its OWN ~500ms execution budget (v6 already trips
// RE10022 on spiky coins) and so v6's locked regression harness stays untouched.
//
// Written as a MODULE: the whole feature is f_accumHL + f_scanFvg + f_pickNear + one
// draw block, with no global var state other than the buffers. To fold it into v6
// later, paste those three functions, the security calls and the draw block - nothing
// else in v6 has to change.
//
// SPEC (user, 29-08-2026)
//   imbalance = 3-bar FVG by WICKS
//       bullish : high[i-2] < low[i]   -> box [high[i-2] .. low[i]]
//       bearish : low[i-2]  > high[i]  -> box [high[i]   .. low[i-2]]
//   closed    = price overlaps 66.6% of the ORIGINAL box height, measured from the
//               edge price enters by. A WICK is enough (no close required).
//       bullish : threshold = top - 0.666*h,  closed when any later low  <= threshold
//       bearish : threshold = bot + 0.666*h,  closed when any later high >= threshold
//   partially overlapped (< 66.6%) boxes keep their FULL original geometry.
//   shown     = N nearest unfilled above + N nearest below per TF (default 3+3), plus
//               any zone that currently CONTAINS price.
//   TF gating = a WINDOW on the timeframe ladder: at or above the chart timeframe
//               (4H zones on a monthly chart are hairlines) AND at most `maxUp`
//               rungs above it. See the note on request.* below.
//   range     = zones wholly outside price/N .. price*N are dropped (multiplicative,
//               not percent - see the rangeMult tooltip for why).
//   fading    = a zone already eaten >= dimAt% of its height is drawn faded.
//   box width = every box ends on ONE common right edge (bar_index + rightOff);
//               the left edge is the gap's birth bar by default (optional fixed length).
//
// WHY THE FILL TEST IS O(n) AND NOT O(n^2)
//   "is this gap filled" is naively "scan every later bar", i.e. a nested loop - on the
//   1D buffer that is ~1200*1200 = 1.4M iterations and a guaranteed RE10022 "Loop takes
//   too long". But "some later low <= threshold" is exactly "min of later lows <=
//   threshold", so a SUFFIX MINIMUM of low (and suffix MAXIMUM of high) answers every
//   gap in O(1). Two backward passes + one forward pass, exact same result.
//
// MTF PLUMBING
//   Buffers are built the same way v6 builds its 1D/4H buffers: request.security returns
//   plain scalars (never arrays/objects - same discipline as v6) and f_accumHL appends a
//   new HTF bar when its time advances, or refreshes the last one while it is still
//   forming. Because only TF >= chart is ever requested, the request.security_lower_tf
//   path v6 needs does NOT exist here - that is the expensive call, and dropping it is
//   most of why this script is cheap.
//
//   Consequence to know: a buffer can only fill as far back as the CHART history reaches.
//   On a 4H chart with 5000 bars loaded (~2.3 years) the monthly buffer holds ~27 months,
//   not 200. That is plenty for zones near price, which is all this script draws.
indicator("TTP IMB MTF v1 - Unfilled Imbalances", "TTP IMB", overlay=true, max_boxes_count=500, max_lines_count=50, max_labels_count=50)

// --------- inputs ---------
tfI4 = input.timeframe("240", "TF #1", group="Timeframes")
tfID = input.timeframe("1D",  "TF #2", group="Timeframes")
tfIW = input.timeframe("1W",  "TF #3", group="Timeframes")
tfIM = input.timeframe("1M",  "TF #4", group="Timeframes")
show4 = input.bool(true, "Show TF #1", group="Timeframes", tooltip="A timeframe BELOW the chart timeframe is never drawn even when ticked - it is not computed at all. Auto-gating by design: 4H zones on a monthly chart are hairlines, and skipping them is also what keeps this script fast.")
showD = input.bool(true, "Show TF #2", group="Timeframes")
showW = input.bool(true, "Show TF #3", group="Timeframes")
showM = input.bool(true, "Show TF #4", group="Timeframes")
maxUp = input.int(2, "Rungs above chart TF", minval=0, maxval=3, group="Timeframes", tooltip="Ceiling on the auto-gate: how many timeframes ABOVE the chart's own to draw. 2 means at most three timeframes are ever on screen - on a 4H chart that is 4H/1D/1W, with the monthly dropped as noise; on a 1D chart it is 1D/1W/1M. Set to 3 to get the old behaviour (everything at or above the chart), 0 to see only the chart's own timeframe.")

fillPctIn = input.float(66.6, "Filled at (% of box height)", minval=1.0, maxval=100.0, step=0.1, group="Imbalance", tooltip="How deep price must overlap a zone, as a percent of the zone's ORIGINAL height, before it counts as closed and stops being drawn. Measured from the edge price enters by: a bullish gap dies when price falls this far into it from the top, a bearish gap when price rises this far into it from the bottom. 100 = only a full traverse closes the zone; 50 = the classic midpoint rule.")
wickFill  = input.bool(true, "A wick is enough to fill", group="Imbalance", tooltip="ON: any bar whose wick reaches the threshold closes the zone (standard FVG treatment - the imbalance was physically traded through). OFF: the bar must CLOSE beyond the threshold, which matches the body-only discipline the TPT detector uses for slom. OFF leaves noticeably more zones alive.")
nEach     = input.int(3, "Zones per side, per TF", minval=1, maxval=5, group="Imbalance", tooltip="How many unfilled zones to draw above price and below price on each timeframe. Zones that currently CONTAIN price are always drawn on top of this count.")
minPct    = input.float(0.0, "Ignore zones thinner than (%)", minval=0.0, maxval=10.0, step=0.05, group="Imbalance", tooltip="Drops micro-gaps whose height is under this percent of price. 0 disables the filter.")
rangeMult = input.float(2.0, "Search range around price (xN)", minval=1.1, maxval=20.0, step=0.1, group="Imbalance", tooltip="Zones lying entirely outside this band around the current price are discarded before anything else - unreachable clutter. The band is MULTIPLICATIVE: price/N up to price*N, so N=2 means 0.5x to 2x. A symmetric PERCENT band would be badly lopsided, because price moves in multiples: -80% is 0.2x (a five-fold drop, practically zero) while +80% is only 1.8x (a couple of levels). Equal ratios up and down is what a log chart shows.")
dimAt     = input.float(50.0, "Dim a zone once filled (%)", minval=0.0, maxval=100.0, step=1.0, group="Imbalance", tooltip="A zone price has ALREADY eaten this far into (but not to the closing threshold) is drawn faded, so a fresh untouched imbalance stands out from a half-worked one. Set to 100 to never dim.")
dimTr     = input.int(92, "Faded transparency", minval=50, maxval=100, group="Imbalance", tooltip="Transparency used for faded zones. Higher = fainter.")

bullCol = input.color(color.new(#26A69A, 82), "Bullish zone", group="Display")
bearCol = input.color(color.new(#EF5350, 82), "Bearish zone", group="Display")
insCol  = input.color(color.new(#E8B923, 74), "Zone containing price", group="Display")
showTxt = input.bool(true, "Label on zone", group="Display")
txtCol  = input.color(#B2B5BE, "Label color", group="Display")
rightOff = input.int(10, "Right edge (bars past last bar)", minval=0, maxval=100, group="Display", tooltip="Where every box ENDS, measured in bars to the right of the last bar. This edge is COMMON to all boxes on all timeframes, so they line up in a column instead of running off to infinity. The label sits against this edge.")
fixedLen = input.bool(false, "Fixed box length", group="Display", tooltip="OFF (default): the left edge stays on the bar where the gap was born, so you can see where it formed; the right edge is still the common one, so nothing runs off to infinity. ON: every box is the same length - a tidy column at the right edge, but the box no longer shows WHERE the gap formed.")
boxLen   = input.int(30, "Box length (bars back from last)", minval=1, maxval=500, group="Display", tooltip="Fixed-length mode only: how far LEFT of the last bar a box starts. Total drawn width is this plus the right-edge offset above. Ignored when Fixed box length is off.")

n4Max = input.int(800,  "Max bars in TF #1 buffer", minval=100, maxval=5000, group="Calculation", tooltip="Buffer depth per timeframe. The scan is O(n) - three linear passes - so these are cheap; they mostly bound how far back a zone may have been born. 800 4H bars is about 4.5 months.")
nDMax = input.int(800,  "Max bars in TF #2 buffer", minval=100, maxval=5000, group="Calculation", tooltip="800 daily bars is about 2.2 years.")
nWMax = input.int(400,  "Max bars in TF #3 buffer", minval=100, maxval=5000, group="Calculation", tooltip="400 weekly bars is about 7.7 years.")
nMMax = input.int(200,  "Max bars in TF #4 buffer", minval=100, maxval=5000, group="Calculation", tooltip="200 monthly bars is about 16 years - in practice the chart history is the real limit (see the header note).")

fillPct = fillPctIn / 100.0

// ============ HELPERS ============
f_tfTag(simple string tf) =>
    s = tf
    if tf == "1W" or tf == "W"
        s := "1W"
    else if tf == "1D" or tf == "D"
        s := "1D"
    else if tf == "1M" or tf == "M"
        s := "1M"
    else if tf == "240"
        s := "4H"
    else if tf == "120"
        s := "2H"
    else if tf == "60"
        s := "1H"
    s

// accum - identical contract to v6's f_accum, minus close: push when the HTF bar's time
// advances, otherwise refresh the last element (the still-forming HTF bar).
f_accumHL(array<float> dstH, array<float> dstL, array<float> dstC, array<int> dstT, float h, float l, float c, int t, int maxLen) =>
    if not na(t) and not na(h) and not na(l)
        szD = array.size(dstT)
        if szD == 0 or t > array.get(dstT, szD - 1)
            array.push(dstH, h)
            array.push(dstL, l)
            array.push(dstC, c)
            array.push(dstT, t)
        else if t == array.get(dstT, szD - 1)
            array.set(dstH, szD - 1, h)
            array.set(dstL, szD - 1, l)
            array.set(dstC, szD - 1, c)
    while array.size(dstT) > maxLen
        array.shift(dstH)
        array.shift(dstL)
        array.shift(dstC)
        array.shift(dstT)
    0

// Scan the buffer for 3-bar FVGs and emit the ones still UNFILLED at the last bar.
// Suffix extremes (see header) make the fill test O(1) per gap -> O(n) overall.
// The LAST buffer bar is still forming: it may not give BIRTH to a zone (that would
// repaint intrabar), but it DOES count for filling one, so a zone dies live.
// oFill receives how deep price has ALREADY come into each surviving zone, as a
// fraction of its height (0 = untouched, <pct or it would not have survived). It is
// free: the deepest penetration is exactly the suffix extreme the fill test already
// reads. Zones wholly outside [loLim, hiLim] are dropped before anything else.
f_scanFvg(array<float> aH, array<float> aL, array<float> aC, array<int> aT, float pct, bool byWick, float minH, float loLim, float hiLim, array<float> oTop, array<float> oBot, array<int> oDir, array<int> oT, array<float> oFill) =>
    array.clear(oTop)
    array.clear(oBot)
    array.clear(oDir)
    array.clear(oT)
    array.clear(oFill)
    n = array.size(aH)
    if n >= 4
        // Suffix min of the low / suffix max of the high over [i .. n-1]. With wick
        // filling these are built from low/high; with body filling, from close/close.
        sMin = array.new_float(n, na)
        sMax = array.new_float(n, na)
        float rMin = byWick ? array.get(aL, n - 1) : array.get(aC, n - 1)
        float rMax = byWick ? array.get(aH, n - 1) : array.get(aC, n - 1)
        array.set(sMin, n - 1, rMin)
        array.set(sMax, n - 1, rMax)
        for i = n - 2 to 0
            rMin := math.min(rMin, byWick ? array.get(aL, i) : array.get(aC, i))
            rMax := math.max(rMax, byWick ? array.get(aH, i) : array.get(aC, i))
            array.set(sMin, i, rMin)
            array.set(sMax, i, rMax)
        for i = 2 to n - 2
            h2 = array.get(aH, i - 2)
            l2 = array.get(aL, i - 2)
            hi = array.get(aH, i)
            li = array.get(aL, i)
            tB = array.get(aT, i - 2)
            // bullish: the gap left between the high of bar i-2 and the low of bar i
            if h2 < li
                hgtB = li - h2
                thrB = li - pct * hgtB
                if hgtB >= minH and li >= loLim and h2 <= hiLim and array.get(sMin, i + 1) > thrB
                    array.push(oTop, li)
                    array.push(oBot, h2)
                    array.push(oDir, 1)
                    array.push(oT, tB)
                    // price enters a bullish gap from the top, so depth = top - lowest later low
                    array.push(oFill, math.max(0.0, math.min(1.0, (li - array.get(sMin, i + 1)) / hgtB)))
            // bearish: the gap left between the low of bar i-2 and the high of bar i
            if l2 > hi
                hgtS = l2 - hi
                thrS = hi + pct * hgtS
                if hgtS >= minH and l2 >= loLim and hi <= hiLim and array.get(sMax, i + 1) < thrS
                    array.push(oTop, l2)
                    array.push(oBot, hi)
                    array.push(oDir, -1)
                    array.push(oT, tB)
                    // price enters a bearish gap from the bottom, so depth = highest later high - bottom
                    array.push(oFill, math.max(0.0, math.min(1.0, (array.get(sMax, i + 1) - hi) / hgtS)))
    array.size(oDir)

// Pick up to nE zones strictly ABOVE price and nE strictly BELOW, plus EVERY zone that
// currently contains price (those are the operative ones and are never rationed).
// Selection is nE passes of "nearest not yet taken" - nE is 1..5, so this is noise next
// to the scan and avoids needing a sort.
f_pickNear(array<float> oTop, array<float> oBot, array<int> oDir, array<int> oT, array<float> oFill, float px, int nE, array<float> pTop, array<float> pBot, array<int> pDir, array<int> pT, array<int> pIns, array<float> pFill) =>
    array.clear(pTop)
    array.clear(pBot)
    array.clear(pDir)
    array.clear(pT)
    array.clear(pIns)
    array.clear(pFill)
    m = array.size(oDir)
    if m > 0
        used = array.new_bool(m, false)
        // zones containing price
        for k = 0 to m - 1
            if array.get(oBot, k) <= px and array.get(oTop, k) >= px
                array.set(used, k, true)
                array.push(pTop, array.get(oTop, k))
                array.push(pBot, array.get(oBot, k))
                array.push(pDir, array.get(oDir, k))
                array.push(pT,   array.get(oT, k))
                array.push(pFill, array.get(oFill, k))
                array.push(pIns, 1)
        // nE nearest above: smallest bottom that is still above price
        for c = 1 to nE
            int best = -1
            for k = 0 to m - 1
                if not array.get(used, k) and array.get(oBot, k) > px
                    if best == -1 or array.get(oBot, k) < array.get(oBot, best)
                        best := k
            if best >= 0
                array.set(used, best, true)
                array.push(pTop, array.get(oTop, best))
                array.push(pBot, array.get(oBot, best))
                array.push(pDir, array.get(oDir, best))
                array.push(pT,   array.get(oT, best))
                array.push(pFill, array.get(oFill, best))
                array.push(pIns, 0)
        // nE nearest below: largest top that is still below price
        for c = 1 to nE
            int best = -1
            for k = 0 to m - 1
                if not array.get(used, k) and array.get(oTop, k) < px
                    if best == -1 or array.get(oTop, k) > array.get(oTop, best)
                        best := k
            if best >= 0
                array.set(used, best, true)
                array.push(pTop, array.get(oTop, best))
                array.push(pBot, array.get(oBot, best))
                array.push(pDir, array.get(oDir, best))
                array.push(pT,   array.get(oT, best))
                array.push(pFill, array.get(oFill, best))
                array.push(pIns, 0)
    array.size(pDir)

// ============ TF GATING + SECURITY ============
// The gate is a WINDOW on the timeframe ladder, not just a floor:
//   floor   - a TF below the chart is never drawn (4H zones on a monthly chart are
//             hairlines), and is not even requested.
//   ceiling - only `maxUp` rungs above the chart's own rung. On a 4H chart with the
//             default 2 that gives 4H/1D/1W and drops 1M, which is the noise the
//             monthly zones were adding; on a 1D chart it gives 1D/1W/1M.
// `base` is the lowest slot at or above the chart timeframe. Slots are assumed to be
// ordered ascending (the defaults are) - reordering the TF inputs reorders the ladder.
// A hidden TF is clamped to the chart timeframe so its request.security call stays
// unconditional (Pine requires that) but costs nothing; its buffer is never scanned.
chartSec = timeframe.in_seconds()
sec4 = timeframe.in_seconds(tfI4)
secD = timeframe.in_seconds(tfID)
secW = timeframe.in_seconds(tfIW)
secM = timeframe.in_seconds(tfIM)
base = sec4 >= chartSec ? 0 : secD >= chartSec ? 1 : secW >= chartSec ? 2 : 3

vis4 = show4 and 0 >= base and 0 - base <= maxUp
visD = showD and 1 >= base and 1 - base <= maxUp
visW = showW and 2 >= base and 2 - base <= maxUp
visM = showM and 3 >= base and 3 - base <= maxUp

req4 = vis4 ? tfI4 : timeframe.period
reqD = visD ? tfID : timeframe.period
reqW = visW ? tfIW : timeframe.period
reqM = visM ? tfIM : timeframe.period

[h4, l4, c4, t4] = request.security(syminfo.tickerid, req4, [high, low, close, time], lookahead=barmerge.lookahead_off)
[hD, lD, cD, tD] = request.security(syminfo.tickerid, reqD, [high, low, close, time], lookahead=barmerge.lookahead_off)
[hW, lW, cW, tW] = request.security(syminfo.tickerid, reqW, [high, low, close, time], lookahead=barmerge.lookahead_off)
[hM, lM, cM, tM] = request.security(syminfo.tickerid, reqM, [high, low, close, time], lookahead=barmerge.lookahead_off)

var a4H = array.new_float()
var a4L = array.new_float()
var a4C = array.new_float()
var a4T = array.new_int()
var aDH = array.new_float()
var aDL = array.new_float()
var aDC = array.new_float()
var aDT = array.new_int()
var aWH = array.new_float()
var aWL = array.new_float()
var aWC = array.new_float()
var aWT = array.new_int()
var aMH = array.new_float()
var aML = array.new_float()
var aMC = array.new_float()
var aMT = array.new_int()

if vis4
    f_accumHL(a4H, a4L, a4C, a4T, h4, l4, c4, t4, n4Max)
if visD
    f_accumHL(aDH, aDL, aDC, aDT, hD, lD, cD, tD, nDMax)
if visW
    f_accumHL(aWH, aWL, aWC, aWT, hW, lW, cW, tW, nWMax)
if visM
    f_accumHL(aMH, aML, aMC, aMT, hM, lM, cM, tM, nMMax)

// ============ DRAW ============
var array<box> bxs = array.new<box>()

if barstate.islast
    if array.size(bxs) > 0
        for k = 0 to array.size(bxs) - 1
            box.delete(array.get(bxs, k))
        array.clear(bxs)

    dur   = time - time[1]
    minH  = minPct / 100.0 * close
    // Search band around price, MULTIPLICATIVE: price/N .. price*N. Ratio rather than
    // percent because price moves in multiples - a +/-80% band reaches 0.2x downward
    // (near zero) but only 1.8x upward, which is lopsided by roughly a factor of three.
    loLim = close / rangeMult
    hiLim = close * rangeMult
    dimFr = dimAt / 100.0

    oTop = array.new_float()
    oBot = array.new_float()
    oDir = array.new_int()
    oT   = array.new_int()
    oFil = array.new_float()
    pTop = array.new_float()
    pBot = array.new_float()
    pDir = array.new_int()
    pT   = array.new_int()
    pIns = array.new_int()
    pFil = array.new_float()

    for s = 0 to 3
        vis = s == 0 ? vis4 : s == 1 ? visD : s == 2 ? visW : visM
        if vis
            aH = s == 0 ? a4H : s == 1 ? aDH : s == 2 ? aWH : aMH
            aL = s == 0 ? a4L : s == 1 ? aDL : s == 2 ? aWL : aML
            aC = s == 0 ? a4C : s == 1 ? aDC : s == 2 ? aWC : aMC
            aT = s == 0 ? a4T : s == 1 ? aDT : s == 2 ? aWT : aMT
            tag = s == 0 ? f_tfTag(tfI4) : s == 1 ? f_tfTag(tfID) : s == 2 ? f_tfTag(tfIW) : f_tfTag(tfIM)
            // Higher TF = thicker border, so the hierarchy is readable at a glance.
            bw = s == 0 ? 1 : s == 1 ? 1 : s == 2 ? 2 : 3

            f_scanFvg(aH, aL, aC, aT, fillPct, wickFill, minH, loLim, hiLim, oTop, oBot, oDir, oT, oFil)
            f_pickNear(oTop, oBot, oDir, oT, oFil, close, nEach, pTop, pBot, pDir, pT, pIns, pFil)

            np = array.size(pDir)
            if np > 0
                for k = 0 to np - 1
                    tp  = array.get(pTop, k)
                    bt  = array.get(pBot, k)
                    dr  = array.get(pDir, k)
                    tm  = array.get(pT, k)
                    ins = array.get(pIns, k) == 1
                    fl  = array.get(pFil, k)
                    // Left edge via bar_index, not bar_time: xloc.bar_index cannot address
                    // a time that has no chart bar (weekends, listing gaps), so convert.
                    barsBack = (not na(tm) and tm < time and dur > 0) ? math.min(4900, math.max(1, int(math.round((time - tm) / dur)))) : 1
                    baseCol = ins ? insCol : (dr == 1 ? bullCol : bearCol)
                    // Already half-worked zones fade out, so an untouched imbalance reads first.
                    dim = fl >= dimFr
                    col = dim ? color.new(baseCol, dimTr) : baseCol
                    brd = dim ? color.new(baseCol, math.min(100, dimTr + 4)) : color.new(baseCol, 40)
                    txt = showTxt ? tag + (dr == 1 ? " ↑" : " ↓") + (dim ? " " + str.tostring(fl * 100, "0") + "%" : "") : ""
                    // Boxes are bounded, not extend.right: one COMMON right edge for every
                    // zone on every TF (bar_index + rightOff), so they line up. The two
                    // length inputs are independent by construction - the fixed length is
                    // measured LEFT from the last bar and the right offset is added on top,
                    // so no combination can leave a box floating clear of the price action.
                    bxR = bar_index + rightOff
                    bxL = math.max(0, fixedLen ? bar_index - boxLen : bar_index - barsBack)
                    bx = box.new(bxL, tp, bxR, bt, xloc=xloc.bar_index, border_color=brd, border_width=bw, bgcolor=col, text=txt, text_color=dim ? color.new(txtCol, 45) : txtCol, text_size=size.small, text_halign=text.align_right, text_valign=text.align_center)
                    array.push(bxs, bx)
````
