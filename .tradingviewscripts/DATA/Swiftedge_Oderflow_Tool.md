<!-- tradingview-pine-id: PUB;b2ffcfe97cb547f1ab1a05fb8256c814 -->
<!-- tradingviewscripts-format: 1 -->
# Swiftedge Oderflow Tool

Source: https://www.tradingview.com/script/lK6GXo06-Swiftedge-Oderflow-Tool/

## Description

Swiftedge Oderflow Tool
OVERVIEW
This indicator is an all-in-one orderflow toolkit that visualizes where significant traded volume has built up, whether those levels have been revisited, and how current activity compares to recent norms. It combines six modules that share one calculation engine:

Liquidity lines — horizontal levels born on the candle that built the volume, running until price trades back through them
Trade bubbles — outsized volume prints, colored by delta
A buy/sell split volume profile anchored at the price axis
HVN / LVN reaction zones detected from the profile
Session levels (Asia / London / New York), daily levels (PDH / PDL / PDC), session VWAP and a developing value area (POC / VAH / VAL)
A dashboard with bar delta, CVD divergence, relative volume, ADR usage and the nearest level above/below price
Every module can be toggled independently, so the indicator can run as a minimal liquidity map or a full cockpit.

HOW IT WORKS
Volume distribution. Each chart bar is decomposed into lower-timeframe candles (1-minute by default, configurable down to seconds where your plan provides them). Each LTF candle's volume is booked to a price bin at its close, and classified as buy or sell volume by its candle direction. Where LTF data is unavailable (older history), the bar's volume is spread evenly across its high-low range as a fallback.

Liquidity lines. A price bin that accumulates a significant share of volume (relative-strength threshold, configurable) spawns a line. The line is anchored to the bar that contributed the most volume to that level, and is plotted at the level's volume-weighted price — not at a rounded grid price. While the level remains untouched it extends to the right edge of the chart. When price trades through the level, its accumulated strength is "burned" (configurable percentage per bar); once it falls below the threshold the line is closed at that bar. Untouched liquidity therefore persists visibly, while consumed liquidity ends exactly where it was consumed. Color and line width scale with the level's peak strength, normalized against the 95th percentile of visible levels; old mitigated lines fade progressively.

Visible-range adaptation. The engine reads the chart's visible range and recalculates on every scroll or zoom. Level resolution (bin size) is derived from the visible price span, so the map keeps a consistent density at any zoom level. A warm-up window (one quarter of the visible span) is processed before the left edge so lines do not start "cold".

Bubbles. A bar whose volume exceeds a configurable percentile of recent bars (defaults: 90 / 97 / 99.5 for small / medium / large) prints a circle at its close, colored by the bar's delta sign.

Volume profile. Built from the visible bars, with each bar's volume spread across its full high-low range, split into buy and sell volume, and smoothed with a 1-2-1 kernel (configurable passes). It is drawn against a fixed wall at the right edge, growing inward, with the buy portion (green) and sell portion (magenta) stacked per row.

HVN / LVN zones. From the smoothed profile, HVNs are the largest local peaks (with a minimum substance filter) and LVNs are the deepest local valleys that sit between populated areas (range edges are excluded). The top N of each (default 3) are drawn as translucent horizontal zones across the visible range with small tags at the right edge.

Sessions, daily levels, VWAP, value area. Session open/high/low are tracked per configurable session windows and timezone and reset daily. PDH / PDL / PDC come from the completed prior daily candle (fetched with lookahead on closed data only — no future leak). VWAP accumulates hlc3 × volume from the daily open. The developing value area builds today's volume distribution and expands from the POC until 70% of volume is captured, yielding POC / VAH / VAL.

Absorption flags. A diamond marks bars with volume above a high percentile but an unusually small range (fraction of ATR14): heavy business transacted without price progress — a classic absorption footprint. Below-bar green diamonds indicate positive delta, above-bar magenta diamonds negative delta.

Dashboard. Bar delta and N-bar delta sum (from the LTF decomposition), a CVD-vs-price divergence check over a configurable lookback, relative volume vs its 20-bar average, day range as a percentage of the average daily range, the active session, and the nearest tracked level above and below current price with distance in percent.

HOW TO USE IT
Untouched liquidity lines act as a map of levels the market has built but not yet retested; strong (bright, thick) untouched lines are natural magnets and reaction candidates.
A line ending shows you exactly where and when that liquidity was consumed.
HVN zones mark acceptance (price tends to slow down and two-way trade there); LVN zones mark rejection/vacuum areas (price tends to move through them quickly or turn at their edge).
Session highs/lows and PDH/PDL are widely watched reference levels; combined with the liquidity map you can see whether volume actually built at them.
The dashboard's divergence row flags when price makes progress that cumulative delta does not confirm.
Use the companion CVD panel script for the delta curve in a separate pane.
SETTINGS NOTES
Defaults are tuned for liquid crypto and index futures on intraday timeframes (1-15 min). The lower timeframe input controls distribution precision: "1" (minute) works broadly; second-based timeframes increase precision on recent data where your subscription provides them. Session times default to a European timezone and should be adjusted to your market.

LIMITATIONS — PLEASE READ
TradingView does not provide order book (L2) or bid/ask tape data to Pine. All volume placement and delta in this indicator are approximations built from lower-timeframe OHLCV data. This is a principled approximation, not actual resting orders or true tape delta.
The indicator draws in the visible range and recalculates when you scroll or zoom; drawings therefore adapt to the window you are viewing. The heavy rendering runs once per bar close, so the newest bar's lines can update with up to one bar of delay.
Lower-timeframe history is limited by TradingView; on older history the fallback distribution (bar range spread) is used, which is coarser.
Volume must be provided by your data feed; on symbols without volume the indicator cannot work.
This is a visualization and context tool. It generates no signals and no performance claims are made or implied.

---

## Source Code

````pine
//@version=6

indicator("Swiftedge Oderflow Tool", "Swift Oderflow", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

max_bars_back(high, 3000)
max_bars_back(low, 3000)
max_bars_back(volume, 3000)

// ─── Inputs ────────────────────────────────────────────────────────────────
grpH = "Liquidity lines"
autoBin   = input.bool(true, "Auto level resolution (adapts to zoom)",                         group = grpH)
rows      = input.int(80,   "Levels on screen",                    minval = 20, maxval = 150, group = grpH)
binTicks  = input.int(2,    "Bin size (ticks, when manual)",       minval = 1,               group = grpH)
ltfRes    = input.timeframe("1", "Lower timeframe for distribution",                           group = grpH)
decayPct  = input.float(0.0,  "Decay per bar (%) — 0 = untouched liquidity persists", minval = 0, maxval = 50, step = 0.5, group = grpH)
burnPct   = input.float(60.0, "Burn when price trades through the level (%)", minval = 0, maxval = 100, group = grpH)
minShare  = input.float(0.08, "Min. relative strength to spawn a line", minval = 0.01, maxval = 0.5, step = 0.01, group = grpH)
maxLevels = input.int(120,  "Max active levels (memory)",          minval = 20, maxval = 200, group = grpH)
gammaExp  = input.float(0.5, "Color curve (lower = hotter)",       minval = 0.2, maxval = 1.0, step = 0.05, group = grpH)
fadeAmt   = input.float(40.0, "Fade on old mitigated lines (%)",   minval = 0, maxval = 80, group = grpH)
showDots  = input.bool(true, "Dot at line birth",                                              group = grpH)

grpC = "Heat colors (cold → max)"
cCold = input.color(#7c4dff, "Cold",  group = grpC)
cWarm = input.color(#43a047, "Warm",  group = grpC)
cHot  = input.color(#9ccc65, "Hot",   group = grpC)
cMax  = input.color(#ccff00, "Max",   group = grpC)

grpB = "Bubbles (large trades)"
showBub = input.bool(true,  "Show bubbles",         group = grpB)
bubLen  = input.int(200,    "Percentile lookback",  minval = 20, group = grpB)
bubP1   = input.float(90.0, "Percentile: small",    minval = 50, maxval = 100, group = grpB)
bubP2   = input.float(97.0, "Percentile: medium",   minval = 50, maxval = 100, group = grpB)
bubP3   = input.float(99.5, "Percentile: large",    minval = 50, maxval = 100, group = grpB)
cBuy    = input.color(color.new(#80deea, 35), "Buy (delta > 0)",  group = grpB)
cSell   = input.color(color.new(#e040fb, 35), "Sell (delta < 0)", group = grpB)

grpN = "HVN / LVN reaction zones"
showNodes = input.bool(true, "Show HVN/LVN zones",  group = grpN)
nHVN      = input.int(3,  "HVN count (volume peaks)",   minval = 1, maxval = 8, group = grpN)
nLVN      = input.int(3,  "LVN count (volume valleys)", minval = 1, maxval = 8, group = grpN)
cHVN      = input.color(#ffee58, "HVN color", group = grpN)
cLVN      = input.color(#ff7043, "LVN color", group = grpN)

grpP = "Volume profile (right edge of visible range)"
showProf   = input.bool(true, "Show volume profile", group = grpP)
profBins   = input.int(80,    "Bins",                minval = 20, maxval = 150, group = grpP)
profW      = input.int(30,    "Max width (bars)",    minval = 10, maxval = 100, group = grpP)
profSmooth = input.int(2,     "Smoothing (passes)",  minval = 0,  maxval = 5,   group = grpP)
cBid       = input.color(color.new(#00c853, 35), "Buy side",  group = grpP)
cAsk       = input.color(color.new(#e040fb, 35), "Sell side", group = grpP)

grpS = "Sessions"
showSess = input.bool(true, "Show session levels", group = grpS)
tzStr    = input.string("Europe/Berlin", "Session timezone", group = grpS)
sesAsia  = input.session("0000-0900", "Asia",     group = grpS)
sesLdn   = input.session("0900-1530", "London",   group = grpS)
sesNy    = input.session("1530-2200", "New York", group = grpS)
cAsia    = input.color(#4dd0e1, "Asia color",     group = grpS)
cLdn     = input.color(#f06292, "London color",   group = grpS)
cNy      = input.color(#ffb74d, "New York color", group = grpS)

grpD = "Daily levels"
showPD  = input.bool(true, "Show PDH / PDL / PDC + today's open", group = grpD)
cPD     = input.color(#b0bec5, "Color", group = grpD)
adrLen  = input.int(20, "ADR length (days)", minval = 5, maxval = 60, group = grpD)

grpV = "VWAP + value area"
showVwap = input.bool(true, "Show session VWAP", group = grpV)
cVwap    = input.color(#64b5f6, "VWAP color", group = grpV)
showVA   = input.bool(true, "Show developing POC / VAH / VAL", group = grpV)
vaBins   = input.int(60, "Value area bins", minval = 20, maxval = 100, group = grpV)
cPoc     = input.color(#ffee58, "POC color", group = grpV)
cVa      = input.color(#9ccc65, "VAH/VAL color", group = grpV)

grpA = "Absorption flags"
showAbs = input.bool(true, "Show absorption diamonds", group = grpA)
absVol  = input.float(97.0, "Volume percentile", minval = 80, maxval = 99.9, group = grpA)
absRng  = input.float(0.6,  "Max range (× ATR14)", minval = 0.1, maxval = 1.5, step = 0.1, group = grpA)

grpT = "Dashboard"
showDash = input.bool(true, "Show dashboard", group = grpT)
dashPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = grpT)
deltaLen = input.int(20, "Delta sum lookback (bars)", minval = 5, maxval = 100, group = grpT)
divLen   = input.int(30, "CVD divergence lookback (bars)", minval = 10, maxval = 200, group = grpT)

// ─── Visible range ─────────────────────────────────────────────────────────
visL      = chart.left_visible_bar_time
visR      = chart.right_visible_bar_time
warmStart = visL - (visR - visL) / 4
accum     = time >= warmStart and time <= visR   // accumulate (incl. warm-up)
inVis     = time >= visL and time <= visR        // draw only here

var int visLeftIdx  = na
var int visRightIdx = na
if inVis
    if na(visLeftIdx)
        visLeftIdx := bar_index
    visRightIdx := bar_index

// ─── Lower timeframe data + delta (every bar) ──────────────────────────────
[ltfV, ltfC, ltfO] = request.security_lower_tf(syminfo.tickerid, ltfRes, [volume, close, open])

float barDelta = 0.0
if array.size(ltfV) > 0
    for i = 0 to array.size(ltfV) - 1
        v = nz(array.get(ltfV, i))
        barDelta += array.get(ltfC, i) >= array.get(ltfO, i) ? v : -v
else
    barDelta := close >= open ? nz(volume) : -nz(volume)

cvd      = ta.cum(barDelta)
deltaSum = math.sum(barDelta, deltaLen)

// ─── Heatmap state ─────────────────────────────────────────────────────────
var float binSize = na
var lvKey     = array.new_int()    // price bin (integer key)
var lvVol     = array.new_float()  // accumulated heat (decays/burns)
var lvBuy     = array.new_float()  // raw buy volume
var lvSell    = array.new_float()  // raw sell volume
var lvPxSum   = array.new_float()  // Σ(price × volume) → volume-weighted price
var lvW       = array.new_float()  // Σ volume (raw weight for vw price)
var lvContrib = array.new_float()  // volume added THIS bar
var lvBigC    = array.new_float()  // largest single-bar contribution
var lvBigBar  = array.new_int()    // bar of largest contribution (line birth)
var lvSeg     = array.new_int()    // index of open line segment (-1 = none)
var segPx    = array.new_float()   // volume-weighted price (frozen on close)
var segStart = array.new_int()
var segEnd   = array.new_int()
var segPeak  = array.new_float()
var int replayBar = na             // bar where warm-up replay happened (no dot)

keyOf(float p) => int(math.round(p / binSize))

addVol(int k, float p, float vb, float vs) =>
    v = vb + vs
    idx = array.indexof(lvKey, k)
    if idx == -1
        array.push(lvKey, k)
        array.push(lvVol, v)
        array.push(lvBuy, vb)
        array.push(lvSell, vs)
        array.push(lvPxSum, p * v)
        array.push(lvW, v)
        array.push(lvContrib, v)
        array.push(lvBigC, 0.0)
        array.push(lvBigBar, bar_index)
        array.push(lvSeg, -1)
    else
        array.set(lvVol, idx, array.get(lvVol, idx) + v)
        array.set(lvBuy, idx, array.get(lvBuy, idx) + vb)
        array.set(lvSell, idx, array.get(lvSell, idx) + vs)
        array.set(lvPxSum, idx, array.get(lvPxSum, idx) + p * v)
        array.set(lvW, idx, array.get(lvW, idx) + v)
        array.set(lvContrib, idx, array.get(lvContrib, idx) + v)

vwPx(int i) =>
    w = array.get(lvW, i)
    w > 0 ? array.get(lvPxSum, i) / w : array.get(lvKey, i) * binSize

// ─── Bin freeze ────────────────────────────────────────────────────────────
var float wHi = na
var float wLo = na
var rawP = array.new_float()
var rawV = array.new_float()   // sign: + = buy, − = sell

if accum and na(binSize) and not autoBin
    binSize := syminfo.mintick * binTicks

if accum and na(binSize) and autoBin
    wHi := na(wHi) ? high : math.max(wHi, high)
    wLo := na(wLo) ? low : math.min(wLo, low)
    if inVis
        est = (wHi - wLo) * 1.5
        binSize := est <= 0 ? syminfo.mintick * binTicks :
             math.max(syminfo.mintick, math.round(est / rows / syminfo.mintick) * syminfo.mintick)
        if array.size(rawP) > 0
            for i = 0 to array.size(rawP) - 1
                rp = array.get(rawP, i)
                rv = array.get(rawV, i)
                addVol(keyOf(rp), rp, rv > 0 ? rv : 0.0, rv < 0 ? -rv : 0.0)
            array.clear(rawP)
            array.clear(rawV)
        replayBar := bar_index
    else if array.size(rawP) < 30000
        if array.size(ltfV) > 0
            for i = 0 to array.size(ltfV) - 1
                v = nz(array.get(ltfV, i))
                array.push(rawP, array.get(ltfC, i))
                array.push(rawV, array.get(ltfC, i) >= array.get(ltfO, i) ? v : -v)
        else
            array.push(rawP, hl2)
            array.push(rawV, close >= open ? nz(volume) : -nz(volume))

// ─── Accumulation ──────────────────────────────────────────────────────────
if accum and not na(binSize)
    if array.size(lvContrib) > 0
        array.fill(lvContrib, 0.0)
    decayF = 1.0 - decayPct / 100.0
    burnF  = 1.0 - burnPct / 100.0
    if array.size(lvVol) > 0
        for i = 0 to array.size(lvVol) - 1
            p = array.get(lvKey, i) * binSize
            f = decayF * (p >= low and p <= high ? burnF : 1.0)
            array.set(lvVol, i, array.get(lvVol, i) * f)
    if array.size(ltfV) > 0
        for i = 0 to array.size(ltfV) - 1
            v = nz(array.get(ltfV, i))
            c = array.get(ltfC, i)
            o = array.get(ltfO, i)
            if c >= o
                addVol(keyOf(c), c, v, 0.0)
            else
                addVol(keyOf(c), c, 0.0, v)
    else
        nB  = math.max(1, int((high - low) / binSize) + 1)
        per = nz(volume) / nB
        isUp = close >= open
        for j = 0 to nB - 1
            pj = low + j * binSize
            addVol(keyOf(pj), pj, isUp ? per : 0.0, isUp ? 0.0 : per)
    // track the "largest contribution" bar (where the line is born)
    for i = 0 to array.size(lvContrib) - 1
        if array.get(lvContrib, i) > array.get(lvBigC, i)
            array.set(lvBigC, i, array.get(lvContrib, i))
            array.set(lvBigBar, i, bar_index)
    // prune weakest levels above the cap (close their segments first)
    if array.size(lvVol) > maxLevels
        while array.size(lvVol) > maxLevels
            mi = 0
            mv = array.get(lvVol, 0)
            for i = 1 to array.size(lvVol) - 1
                if array.get(lvVol, i) < mv
                    mv := array.get(lvVol, i)
                    mi := i
            si = array.get(lvSeg, mi)
            if si != -1 and array.get(segEnd, si) == -1
                array.set(segEnd, si, bar_index)
            array.remove(lvKey, mi)
            array.remove(lvVol, mi)
            array.remove(lvBuy, mi)
            array.remove(lvSell, mi)
            array.remove(lvPxSum, mi)
            array.remove(lvW, mi)
            array.remove(lvContrib, mi)
            array.remove(lvBigC, mi)
            array.remove(lvBigBar, mi)
            array.remove(lvSeg, mi)

// ─── Segment lifecycle ─────────────────────────────────────────────────────
if accum and not na(binSize) and array.size(lvVol) > 0
    mVx = array.max(lvVol)
    if mVx > 0
        for i = 0 to array.size(lvVol) - 1
            v  = array.get(lvVol, i)
            sh = v / mVx
            si = array.get(lvSeg, i)
            if si == -1
                if sh >= minShare and array.size(segPx) < 4000
                    array.push(segPx, vwPx(i))
                    array.push(segStart, array.get(lvBigBar, i))
                    array.push(segEnd, -1)
                    array.push(segPeak, v)
                    array.set(lvSeg, i, array.size(segPx) - 1)
            else
                array.set(segPx, si, vwPx(i))
                if v > array.get(segPeak, si)
                    array.set(segPeak, si, v)
                if sh < minShare * 0.5
                    array.set(segEnd, si, bar_index)
                    array.set(lvSeg, i, -1)

// ─── Day tracking ──────────────────────────────────────────────────────────
newDay = timeframe.change("D")
var float dayO   = na
var float dayHi  = na
var float dayLo  = na
var int   dStart = na
if newDay
    dayO   := open
    dayHi  := high
    dayLo  := low
    dStart := bar_index
else
    dayHi := math.max(nz(dayHi, high), high)
    dayLo := math.min(nz(dayLo, low), low)

[pdh, pdl, pdc] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
adr = request.security(syminfo.tickerid, "D", ta.sma(high - low, adrLen)[1], lookahead = barmerge.lookahead_on)

// ─── Session tracking ──────────────────────────────────────────────────────
inAsia = not na(time(timeframe.period, sesAsia, tzStr))
inLdn  = not na(time(timeframe.period, sesLdn, tzStr))
inNy   = not na(time(timeframe.period, sesNy, tzStr))

var float aO = na
var float aH = na
var float aL = na
var int   aStart = na
var float lO = na
var float lH = na
var float lL = na
var int   lStart = na
var float nO = na
var float nH = na
var float nL = na
var int   nStart = na

if newDay
    aO := na
    aH := na
    aL := na
    aStart := na
    lO := na
    lH := na
    lL := na
    lStart := na
    nO := na
    nH := na
    nL := na
    nStart := na

if inAsia and not inAsia[1]
    aO := open
    aH := high
    aL := low
    aStart := bar_index
else if inAsia
    aH := math.max(nz(aH, high), high)
    aL := math.min(nz(aL, low), low)

if inLdn and not inLdn[1]
    lO := open
    lH := high
    lL := low
    lStart := bar_index
else if inLdn
    lH := math.max(nz(lH, high), high)
    lL := math.min(nz(lL, low), low)

if inNy and not inNy[1]
    nO := open
    nH := high
    nL := low
    nStart := bar_index
else if inNy
    nH := math.max(nz(nH, high), high)
    nL := math.min(nz(nL, low), low)

// ─── Session VWAP ──────────────────────────────────────────────────────────
var float cumPV = 0.0
var float cumV  = 0.0
if newDay
    cumPV := 0.0
    cumV  := 0.0
cumPV += hlc3 * nz(volume)
cumV  += nz(volume)
vwapVal = cumV > 0 ? cumPV / cumV : na
plot(showVwap ? vwapVal : na, "VWAP", color = cVwap, linewidth = 2)

// ─── Absorption flags ──────────────────────────────────────────────────────
volP  = ta.percentile_linear_interpolation(volume, 200, absVol)
atr14 = ta.atr(14)
absorb = showAbs and not na(volP) and volume >= volP and (high - low) < atr14 * absRng
plotshape(absorb and barDelta >= 0, "Buy absorption",  shape.diamond, location.belowbar, color.new(#00e676, 20), size = size.tiny)
plotshape(absorb and barDelta < 0,  "Sell absorption", shape.diamond, location.abovebar, color.new(#e040fb, 20), size = size.tiny)

// ─── Developing value area (today's volume distribution) ───────────────────
float pocPx = na
float vahPx = na
float valPx = na
if showVA and not na(dStart) and not na(dayHi) and dayHi > dayLo and barstate.islast
    dLen = math.min(bar_index - dStart, 1600)
    pv   = array.new_float(vaBins, 0.0)
    step = (dayHi - dayLo) / vaBins
    for o = 0 to dLen
        b0 = int((low[o] - dayLo) / step)
        b1 = int((high[o] - dayLo) / step)
        b0 := math.min(math.max(b0, 0), vaBins - 1)
        b1 := math.min(math.max(b1, 0), vaBins - 1)
        per = nz(volume[o]) / (b1 - b0 + 1)
        for j = b0 to b1
            array.set(pv, j, array.get(pv, j) + per)
    pocI = 0
    for j = 1 to vaBins - 1
        if array.get(pv, j) > array.get(pv, pocI)
            pocI := j
    total = array.sum(pv)
    if total > 0
        va = array.get(pv, pocI)
        up = pocI + 1
        dn = pocI - 1
        while va < total * 0.70 and (up < vaBins or dn >= 0)
            vUp = up < vaBins ? array.get(pv, up) : -1.0
            vDn = dn >= 0 ? array.get(pv, dn) : -1.0
            if vUp >= vDn
                va += vUp
                up += 1
            else
                va += vDn
                dn -= 1
        pocPx := dayLo + (pocI + 0.5) * step
        vahPx := dayLo + math.min(up, vaBins) * step
        valPx := dayLo + (dn + 1) * step

// ─── RENDER: liquidity lines (once per bar) ────────────────────────────────
heatColor(float norm) =>
    norm < 0.30 ? cCold :
     norm < 0.55 ? color.from_gradient(norm, 0.30, 0.55, cCold, cWarm) :
     norm < 0.82 ? color.from_gradient(norm, 0.55, 0.82, cWarm, cHot) :
     color.from_gradient(norm, 0.82, 1.0, cHot, cMax)

var liqLines  = array.new_line()
var dotLabels = array.new_label()
var int lastDrawnHeat = na
if barstate.islast and not na(visLeftIdx) and not na(visRightIdx) and array.size(segPx) > 0 and (na(lastDrawnHeat) or bar_index != lastDrawnHeat)
    lastDrawnHeat := bar_index
    while array.size(liqLines) > 0
        line.delete(array.pop(liqLines))
    while array.size(dotLabels) > 0
        label.delete(array.pop(dotLabels))
    visIdx = array.new_int()
    peaks  = array.new_float()
    for s = 0 to array.size(segPx) - 1
        sEnd = array.get(segEnd, s) == -1 ? visRightIdx : array.get(segEnd, s)
        if sEnd >= visLeftIdx and array.get(segStart, s) <= visRightIdx
            array.push(visIdx, s)
            array.push(peaks, array.get(segPeak, s))
    if array.size(visIdx) > 0
        sortedP = array.copy(peaks)
        array.sort(sortedP, order.descending)
        nSeg = array.size(sortedP)
        float ref = array.get(sortedP, math.min(nSeg - 1, int(nSeg * 0.05)))
        ref := ref <= 0 ? 1.0 : ref
        maxL = 420   // keep room for session/daily level lines
        thr  = nSeg > maxL ? array.get(sortedP, maxL - 1) : 0.0
        nBars = visRightIdx - visLeftIdx + 1
        dots  = 0
        for k = 0 to array.size(visIdx) - 1
            pk = array.get(peaks, k)
            if pk < thr
                continue
            s     = array.get(visIdx, k)
            norm  = math.pow(math.min(1.0, pk / ref), gammaExp)
            price = array.get(segPx, s)
            alive = array.get(segEnd, s) == -1
            x1    = math.max(array.get(segStart, s), visLeftIdx)
            x2    = alive ? visRightIdx + 1 : math.min(array.get(segEnd, s), visRightIdx)
            x2   := math.max(x2, x1 + 1)
            tBase   = 60.0 - 56.0 * norm
            endFrac = (x2 - visLeftIdx) * 1.0 / nBars
            tFin    = alive ? tBase : math.min(92.0, tBase + fadeAmt * (1.0 - endFrac))
            w   = norm >= 0.82 ? 3 : norm >= 0.50 ? 2 : 1
            col = color.new(heatColor(norm), int(tFin))
            ln = line.new(x1, price, x2, price, color = col, width = w)
            array.push(liqLines, ln)
            if showDots and array.get(segStart, s) >= visLeftIdx and (na(replayBar) or array.get(segStart, s) != replayBar) and dots < 200
                dl = label.new(array.get(segStart, s), price, "", style = label.style_circle,
                     color = col, size = size.tiny)
                array.push(dotLabels, dl)
                dots += 1

// ─── Bubbles (visible range only) ──────────────────────────────────────────
p1 = ta.percentile_linear_interpolation(volume, bubLen, bubP1)
p2 = ta.percentile_linear_interpolation(volume, bubLen, bubP2)
p3 = ta.percentile_linear_interpolation(volume, bubLen, bubP3)
if showBub and inVis and not na(p1) and volume >= p1
    sz = volume >= p3 ? size.normal : volume >= p2 ? size.small : size.tiny
    label.new(bar_index, close, "", style = label.style_circle,
         color = barDelta >= 0 ? cBuy : cSell, size = sz)

// ─── Volume profile + HVN/LVN (visible bars, anchored at price axis) ───────
var profBoxes  = array.new_box()
var nodeBoxes  = array.new_box()
var nodeLabels = array.new_label()
if (showProf or showNodes) and barstate.islast and not na(visLeftIdx) and not na(visRightIdx)
    while array.size(profBoxes) > 0
        box.delete(array.pop(profBoxes))
    while array.size(nodeBoxes) > 0
        box.delete(array.pop(nodeBoxes))
    while array.size(nodeLabels) > 0
        label.delete(array.pop(nodeLabels))
    oR = bar_index - visRightIdx
    oL = math.min(bar_index - visLeftIdx, oR + 2500)
    if oL > oR
        float vHi = na
        float vLo = na
        for o = oR to oL
            vHi := na(vHi) ? high[o] : math.max(vHi, high[o])
            vLo := na(vLo) ? low[o] : math.min(vLo, low[o])
        if not na(vHi) and vHi > vLo
            pvB  = array.new_float(profBins, 0.0)
            pvS  = array.new_float(profBins, 0.0)
            step = (vHi - vLo) / profBins
            for o = oR to oL
                b0 = int((low[o] - vLo) / step)
                b1 = int((high[o] - vLo) / step)
                b0 := math.min(math.max(b0, 0), profBins - 1)
                b1 := math.min(math.max(b1, 0), profBins - 1)
                per = nz(volume[o]) / (b1 - b0 + 1)
                up  = close[o] >= open[o]
                for j = b0 to b1
                    if up
                        array.set(pvB, j, array.get(pvB, j) + per)
                    else
                        array.set(pvS, j, array.get(pvS, j) + per)
            if profSmooth > 0
                for pass = 1 to profSmooth
                    prevB = array.copy(pvB)
                    prevS = array.copy(pvS)
                    for j = 0 to profBins - 1
                        jm = math.max(j - 1, 0)
                        jp = math.min(j + 1, profBins - 1)
                        array.set(pvB, j, (array.get(prevB, jm) + 2 * array.get(prevB, j) + array.get(prevB, jp)) / 4)
                        array.set(pvS, j, (array.get(prevS, jm) + 2 * array.get(prevS, j) + array.get(prevS, jp)) / 4)
            float pMax = 0.0
            for j = 0 to profBins - 1
                pMax := math.max(pMax, array.get(pvB, j) + array.get(pvS, j))
            if showProf and pMax > 0
                wall = visRightIdx + 2 + profW
                for j = 0 to profBins - 1
                    vB = array.get(pvB, j)
                    vS = array.get(pvS, j)
                    vT = vB + vS
                    w  = math.round(profW * vT / pMax)
                    if vT > 0 and w >= 1
                        wB = math.round(w * vB / vT)
                        y0 = vLo + j * step
                        if wB >= 1
                            pb1 = box.new(wall - wB, y0 + step, wall, y0,
                                 border_color = color(na), bgcolor = cBid)
                            array.push(profBoxes, pb1)
                        if w - wB >= 1
                            pb2 = box.new(wall - w, y0 + step, wall - wB, y0,
                                 border_color = color(na), bgcolor = cAsk)
                            array.push(profBoxes, pb2)
            if showNodes and pMax > 0
                total = array.new_float(profBins, 0.0)
                for j = 0 to profBins - 1
                    array.set(total, j, array.get(pvB, j) + array.get(pvS, j))
                scoreH = array.new_float(profBins, 0.0)
                for j = 1 to profBins - 2
                    t = array.get(total, j)
                    if t >= array.get(total, j - 1) and t >= array.get(total, j + 1) and t > pMax * 0.25
                        array.set(scoreH, j, t)
                scoreL = array.new_float(profBins, 0.0)
                for j = 2 to profBins - 3
                    t = array.get(total, j)
                    if t <= array.get(total, j - 1) and t <= array.get(total, j + 1)
                        nm = 0.0
                        for q = math.max(j - 8, 0) to math.min(j + 8, profBins - 1)
                            nm := math.max(nm, array.get(total, q))
                        if nm > pMax * 0.20 and t < nm * 0.75
                            array.set(scoreL, j, nm - t)
                for r = 0 to nHVN + nLVN - 1
                    isH = r < nHVN
                    src = isH ? scoreH : scoreL
                    bi = -1
                    bv = 0.0
                    for j = 0 to profBins - 1
                        if array.get(src, j) > bv
                            bv := array.get(src, j)
                            bi := j
                    if bi != -1
                        for q = math.max(bi - 3, 0) to math.min(bi + 3, profBins - 1)
                            array.set(src, q, 0.0)
                        y0 = vLo + bi * step
                        nc = isH ? cHVN : cLVN
                        nb = box.new(visLeftIdx, y0 + step, visRightIdx + 1, y0,
                             border_color = color(na), bgcolor = color.new(nc, 84))
                        array.push(nodeBoxes, nb)
                        nl = label.new(visRightIdx + 1, y0 + step / 2, isH ? "HVN" : "LVN",
                             style = label.style_label_left, color = color.new(nc, 45),
                             textcolor = #101010, size = size.tiny)
                        array.push(nodeLabels, nl)

// ─── Session / daily / value-area level lines (once per bar) ───────────────
var lvlLines  = array.new_line()
var lvlLabels = array.new_label()
var int lastDrawnLvl = na

mkLevel(int x1, float y, color c, string txt, string lstyle) =>
    if not na(y) and not na(x1)
        ln = line.new(x1, y, bar_index + 5, y, color = color.new(c, 25), width = 1,
             style = lstyle == "dot" ? line.style_dotted : lstyle == "dash" ? line.style_dashed : line.style_solid)
        array.push(lvlLines, ln)
        lb = label.new(bar_index + 5, y, txt, style = label.style_label_left,
             color = color.new(c, 80), textcolor = color.new(color.white, 15), size = size.tiny)
        array.push(lvlLabels, lb)

if barstate.islast and (na(lastDrawnLvl) or bar_index != lastDrawnLvl)
    lastDrawnLvl := bar_index
    while array.size(lvlLines) > 0
        line.delete(array.pop(lvlLines))
    while array.size(lvlLabels) > 0
        label.delete(array.pop(lvlLabels))
    if showSess
        mkLevel(aStart, aO, cAsia, "AS.O", "dot")
        mkLevel(aStart, aH, cAsia, "AS.H", "solid")
        mkLevel(aStart, aL, cAsia, "AS.L", "solid")
        mkLevel(lStart, lO, cLdn, "LDN.O", "dot")
        mkLevel(lStart, lH, cLdn, "LDN.H", "solid")
        mkLevel(lStart, lL, cLdn, "LDN.L", "solid")
        mkLevel(nStart, nO, cNy, "NY.O", "dot")
        mkLevel(nStart, nH, cNy, "NY.H", "solid")
        mkLevel(nStart, nL, cNy, "NY.L", "solid")
    if showPD
        mkLevel(dStart, pdh, cPD, "PDH", "dash")
        mkLevel(dStart, pdl, cPD, "PDL", "dash")
        mkLevel(dStart, pdc, cPD, "PDC", "dot")
        mkLevel(dStart, dayO, cPD, "D.O", "dot")
    if showVA
        mkLevel(dStart, pocPx, cPoc, "POC", "solid")
        mkLevel(dStart, vahPx, cVa, "VAH", "dash")
        mkLevel(dStart, valPx, cVa, "VAL", "dash")

// ─── Dashboard table ───────────────────────────────────────────────────────
posOf(string s) =>
    s == "Top left" ? position.top_left :
     s == "Bottom right" ? position.bottom_right :
     s == "Bottom left" ? position.bottom_left :
     s == "Middle right" ? position.middle_right : position.top_right

addLvl(array<float> lp, array<string> lnm, float p, string s) =>
    if not na(p)
        array.push(lp, p)
        array.push(lnm, s)

var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(posOf(dashPos), 2, 9, bgcolor = color.new(#0d0d14, 15),
             border_width = 1, border_color = color.new(#2a2a3a, 60))
    cGrn = #00e676
    cMag = #e040fb
    cTxt = #d0d0d8
    sessTxt = inNy ? "NEW YORK" : inLdn ? "LONDON" : inAsia ? "ASIA" : "OFF-HOURS"
    sessCol = inNy ? cNy : inLdn ? cLdn : inAsia ? cAsia : color.gray
    divTxt = "—"
    divCol = cTxt
    if bar_index > divLen
        pUp = close > close[divLen]
        cUp = cvd > cvd[divLen]
        divTxt := pUp and not cUp ? "BEARISH ⚠" : not pUp and cUp ? "BULLISH ⚠" : "ALIGNED ✓"
        divCol := pUp and not cUp ? cMag : not pUp and cUp ? cGrn : cTxt
    rvol   = nz(volume / ta.sma(volume, 20), 1.0)
    adrPct = not na(adr) and adr > 0 and not na(dayHi) ? (dayHi - dayLo) / adr * 100 : na
    lp  = array.new_float()
    lnm = array.new_string()
    addLvl(lp, lnm, pdh, "PDH")
    addLvl(lp, lnm, pdl, "PDL")
    addLvl(lp, lnm, pdc, "PDC")
    addLvl(lp, lnm, dayO, "D.O")
    addLvl(lp, lnm, aH, "AS.H")
    addLvl(lp, lnm, aL, "AS.L")
    addLvl(lp, lnm, lH, "LDN.H")
    addLvl(lp, lnm, lL, "LDN.L")
    addLvl(lp, lnm, nH, "NY.H")
    addLvl(lp, lnm, nL, "NY.L")
    addLvl(lp, lnm, vwapVal, "VWAP")
    addLvl(lp, lnm, pocPx, "POC")
    addLvl(lp, lnm, vahPx, "VAH")
    addLvl(lp, lnm, valPx, "VAL")
    string nAbove = "—"
    string nBelow = "—"
    float dAbove = na
    float dBelow = na
    for i = 0 to array.size(lp) - 1
        p = array.get(lp, i)
        if p > close and (na(dAbove) or p - close < dAbove)
            dAbove := p - close
            nAbove := array.get(lnm, i) + "  +" + str.tostring(dAbove / close * 100, "#.##") + "%"
        if p < close and (na(dBelow) or close - p < dBelow)
            dBelow := close - p
            nBelow := array.get(lnm, i) + "  −" + str.tostring(dBelow / close * 100, "#.##") + "%"
    table.cell(dash, 0, 0, "SESSION",      text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 0, sessTxt,        text_color = sessCol, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 1, "BAR Δ",        text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 1, str.tostring(barDelta, format.volume), text_color = barDelta >= 0 ? cGrn : cMag, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 2, "Δ " + str.tostring(deltaLen) + " BARS", text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(deltaSum, format.volume), text_color = deltaSum >= 0 ? cGrn : cMag, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 3, "CVD DIV",      text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 3, divTxt,         text_color = divCol, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 4, "RVOL",         text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(rvol, "#.##") + "×", text_color = rvol >= 1.5 ? cGrn : rvol < 0.7 ? color.gray : cTxt, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 5, "ADR USED",     text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 5, na(adrPct) ? "—" : str.tostring(adrPct, "#") + "%", text_color = not na(adrPct) and adrPct > 100 ? cMag : cTxt, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 6, "DAY RANGE",    text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 6, na(dayHi) ? "—" : str.tostring(dayHi - dayLo, format.mintick), text_color = cTxt, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 7, "ABOVE",        text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 7, nAbove,         text_color = cGrn, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 8, "BELOW",        text_color = cTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 8, nBelow,         text_color = cMag, text_size = size.tiny, text_halign = text.align_right)
````
