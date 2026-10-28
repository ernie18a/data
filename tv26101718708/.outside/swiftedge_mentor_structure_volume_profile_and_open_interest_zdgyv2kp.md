# SwiftEdge Mentor - Structure, Volume Profile and Open Interest

- url: https://www.tradingview.com/script/ZDGyv2KP-SwiftEdge-Mentor-Structure-Volume-Profile-and-Open-Interest/
- type: indicator
- pine_id: PUB;58e0a27e2ff74122986db426153555b4
- version: 1.0

## Description

WHAT IT DOES

A read-only market map. It draws three things and reports them in one side
panel: market structure, a volume profile, and how open interest is moving
against price. It gives no entries, no exits and no signals.

HOW IT WORKS

Structure. Swing highs and lows are pivots with a configurable number of bars on
each side, three by default. Only the last three of each are kept and labelled
HH, HL, LH or LL, and the trend is read from the newest pair: higher highs with
higher lows is up, lower highs with lower lows is down, anything else is
sideways. A structure break is flagged when price trades beyond the last swing
while that swing was not already the continuation label. Impulse legs are bars
whose range exceeds two times the median range of the last 96 bars and whose
body is at least 65 percent of that range. Daily ATR is Wilder 14 on completed
daily bars only, and the panel shows today's range as a percentage of it, so a
day that has already travelled twice its normal distance is marked as stretched.
Session opens are drawn for Tokyo, London and New York in their own time zones.

Volume profile. Each bar's volume is spread evenly across the price bins its
high-low range covers, over a configurable window, 24 hours and 25 dollar bins
by default. The point of control is the heaviest bin. The value area grows
outwards from it, always taking the larger of the two neighbouring bins, until
it holds 70 percent of the total volume. High and low volume nodes are local
extremes of a five-bin smoothing measured against the median of the profile, and
the three nearest to current price are drawn with their prices labelled.

Open interest. Open interest is read from the exchange's own feed and compared
with price over one hour and four hours. Rising open interest with rising price
is new longs, rising open interest with falling price is new shorts, falling
open interest with rising price is a short squeeze, and falling open interest
with falling price is a long flush. The ticker is derived from the chart's own
symbol, so this works on any instrument where the exchange publishes open
interest. Where it does not, the block reads "no OI feed" and everything else
continues to work.

HOW TO USE IT

Put it on a chart and read the panel. The structure block says what the market
has done, the volume profile says where it has spent its volume, and the
positioning block says whether a move is being funded by new positions or caused
by old ones closing. Run it on a 1 minute chart if you want the volume profile
at its finest resolution; on higher timeframes each bar's volume is distributed
across its own range instead, which the 25 dollar binning largely absorbs.

Five alerts are available: structure break up, structure break down, price left
the value area, price entered the value area, and open interest regime changed.

WHAT IT DOES NOT DO

It does not see the order book. Resting limit orders that never trade leave no
trace in price or volume, so standing liquidity cannot be reconstructed from
what a chart provides. This was measured rather than assumed: on three hours of
recorded order book data, ranking price levels by traded volume found 40 percent
of the ten largest resting walls, where picking levels at random finds 23
percent, and an absorption metric found none of them. A liquidity layer is
therefore absent rather than approximated.

It has no cumulative volume delta either. The taker side of each trade is not
available to a chart script, and inferring it from bar direction is a different
measurement: against recorded trades carrying the real taker flag, the sign of
close minus open times volume correlates 0.71 per bar on one minute data and
0.65 on one second data, where one second is worse because 36 percent of seconds
close unchanged and get no direction at all. Since the usual purpose of such a
line is divergence at swing points, where single bars decide the answer, a 0.71
proxy would produce divergences the full data does not show. It is left out.

It is descriptive. It reports what has happened. It makes no claim about what
happens next, and no performance claim of any kind.

ORIGINALITY

Structure labelling, volume profiles and open interest readings each exist
separately. This combines the three into one panel under a single consistent set
of definitions, and states plainly which parts of a full order flow picture a
chart script cannot provide, with the measurements behind that statement
included in the code comments rather than asserted.

REPAINTING

Pivots confirm after the configured number of bars on each side and do not move
afterwards. Daily values are taken from completed daily bars only. The volume
profile and the panel show the current state and are redrawn on the last bar,
so they reflect the present rather than a history of past states. The two value
area alerts evaluate on the last bar and therefore do nothing on historical
bars.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//  SwiftEdge Mentor · alpha v0.1
//
//  A market map in three parts: structure, volume profile, and open interest
//  against price. Ported from a seven-step analysis that also reads a live order
//  book. Three of those steps survive the move to a chart script intact; this
//  file carries them and says plainly which do not, and why.
//
//  ┌──────────────────────────────────────────────────────────────────────────┐
//  │ step                    in this file   why                              │
//  ├──────────────────────────────────────────────────────────────────────────┤
//  │ 1 Structure             YES            OHLCV only                       │
//  │ 2 Liquidity (walls)     NO             needs the live order book        │
//  │ 3 Volume profile        YES            OHLCV only                       │
//  │ 4 Order flow (CVD)      NO (yet)       needs the taker side             │
//  │ 5 Timeframe alignment   NO (yet)       same                             │
//  │ 6 Positioning (OI)      YES            TradingView carries the OI feed   │
//  │ 7 Synthesis             PARTIAL        without the wall invalidation     │
//  └──────────────────────────────────────────────────────────────────────────┘
//
//  STEP 2 IS NOT AN OMISSION THAT CAN BE FIXED. Resting limit orders that never
//  trade leave no trace in price or volume: a large wall that is never hit
//  produces exactly zero volume. Measured on 3 hours of recorded book data
//  (12,766 snapshots) against the trades over the same hours: ranking price
//  levels by traded volume finds 40 % of the book's ten largest walls, where
//  picking at random finds 23 %, and an absorption metric (volume per second at
//  a level) found 0 %. Walls cannot be reconstructed from what a chart provides.
//  What the volume proxy does capture is the volume profile, which is step 3,
//  already here under its own name. Drawing it twice and calling one of them
//  "liquidity" would put two labels on one dataset.
//
//  STEP 4/5 ARE DEFERRED, NOT IMPOSSIBLE. A chart script has no taker side, so
//  CVD has to be inferred from the bar. Measured against recorded trades
//  carrying the real taker flag: sign(close − open) × volume correlates +0.706 per bar
//  at 1 m and +0.651 at 1 s (1 s is WORSE — 36.4 % of seconds have close == open
//  and get no direction at all). Using high/low made it worse still (+0.584 and
//  +0.520). The cumulative line tracks at ~0.93 either way. The Mentor uses CVD
//  for divergence at swing points, which is exactly where single bars decide the
//  answer, so a 0.71 proxy would produce divergences the full data does not show.
//  It may be added later as a separate, clearly labelled approximation.
//
//  Constants below come from the original analysis and are not re-tuned here:
//      swing_n 3 · imp_x 2.0 · imp_krop 65 % · vp_timer 24 h · vp_trin 25
//      va_pct 70 % · hvn_x 1.3 · lvn_x 0.6 · daily ATR Wilder 14
//
//  DESCRIPTIVE, NOT PROVEN. Several of these ideas were tested as trading
//  signals on recorded data and did not hold (walls as magnets, band retests,
//  timeframe alignment). This draws structure. It makes no claim about what
//  happens next and no performance claim of any kind.
//
//  Works on any symbol and timeframe. The open interest block needs an exchange
//  that publishes an OI feed; without one that block reads "no OI feed" and the
//  rest still works.
// ══════════════════════════════════════════════════════════════════════════════
indicator("SwiftEdge Mentor - Structure, Volume Profile and Open Interest", "SE Mentor", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ── inputs ────────────────────────────────────────────────────────────────────
g1 = "Structure"
swingN    = input.int(3,    "Swing strength (bars each side)", minval = 1, maxval = 10, group = g1, tooltip = "original setting: 3")
showSwing = input.bool(true,  "HH / HL / LH / LL labels",   group = g1)
keepSwings= input.int(3,    "Keep only the last N swings", minval = 1, maxval = 20, group = g1, tooltip = "the original keeps 3 tops and 3 bottoms. More than ~5 buries the chart.")
lblSizeIn = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = g1)
showImp   = input.bool(true,  "Impulse legs",               group = g1)
impX      = input.float(2.0, "Impulse: range > x × median", minval = 1.0, step = 0.1, group = g1, tooltip = "original: 2.0")
impBody   = input.float(65.0,"Impulse: body ≥ % of range",  minval = 10, maxval = 100, group = g1, tooltip = "original: 65")
showSess  = input.bool(true,  "Session opens",              group = g1)

g2 = "Volume profile"
showVP    = input.bool(true,  "Draw POC / value area / HVN / LVN", group = g2)
vpHours   = input.int(24,   "Hours",                 minval = 1, maxval = 168, group = g2, tooltip = "original: 24")
vpStep    = input.float(25.0,"Bin size ($)",          minval = 1, group = g2, tooltip = "original: 25")
vaPct     = input.float(70.0,"Value area %",          minval = 30, maxval = 95, group = g2, tooltip = "original: 70")
hvnX      = input.float(1.3, "HVN: > x × median",     minval = 1.0, step = 0.05, group = g2, tooltip = "original: 1.3")
lvnX      = input.float(0.6, "LVN: < x × median",     minval = 0.1, maxval = 1.0, step = 0.05, group = g2, tooltip = "original: 0.6")

g3 = "Positioning"
showOI    = input.bool(true,  "Open interest vs price", group = g3)
oiSuffix  = input.string(".P_OI", "OI ticker suffix", options = [".P_OI", "_OI"], group = g3, tooltip = "TradingView publishes Binance perp OI as e.g. BINANCE:BTCUSDT.P_OI")

g4 = "Panel"
showPanel = input.bool(true,  "Summary panel", group = g4)
panelPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = g4)
panelSize = input.string("Normal", "Text size", options = ["Small", "Normal", "Large"], group = g4)
showLvls  = input.bool(true, "Price tags on POC / VA / HVN / LVN", group = g4)

lblSize = lblSizeIn == "Tiny" ? size.tiny : lblSizeIn == "Normal" ? size.normal : lblSizeIn == "Large" ? size.large : size.small
pnlSize = panelSize == "Small" ? size.small : panelSize == "Large" ? size.large : size.normal


// ── step 1: structure ─────────────────────────────────────────────────────────
// Pivots, exactly the original test: a bar whose high is >= every high within
// swingN bars each side (and the mirror for lows).
ph = ta.pivothigh(high, swingN, swingN)
pl = ta.pivotlow(low,  swingN, swingN)

var float[] topP = array.new_float()
var int[]   topT = array.new_int()
var float[] botP = array.new_float()
var int[]   botT = array.new_int()

if not na(ph)
    array.push(topP, ph)
    array.push(topT, bar_index - swingN)
    if array.size(topP) > 3
        array.shift(topP)
        array.shift(topT)
if not na(pl)
    array.push(botP, pl)
    array.push(botT, bar_index - swingN)
    if array.size(botP) > 3
        array.shift(botP)
        array.shift(botT)

// label of the newest top/bottom, from the one before it
lblTop = array.size(topP) < 2 ? "top" : (array.get(topP, array.size(topP) - 1) > array.get(topP, array.size(topP) - 2) ? "HH" : "LH")
lblBot = array.size(botP) < 2 ? "low" : (array.get(botP, array.size(botP) - 1) > array.get(botP, array.size(botP) - 2) ? "HL" : "LL")

trendTxt = lblTop == "HH" and lblBot == "HL" ? "up (higher highs and lows)" :
           lblTop == "LH" and lblBot == "LL" ? "down (lower highs and lows)" : "sideways / undecided"

lastTop = array.size(topP) > 0 ? array.get(topP, array.size(topP) - 1) : na
lastBot = array.size(botP) > 0 ? array.get(botP, array.size(botP) - 1) : na

// structure break: price beyond the last swing while that swing was NOT already
// the continuation label. Same condition as the original.
breakUp   = not na(lastTop) and close > lastTop and lblTop != "HH"
breakDown = not na(lastBot) and close < lastBot and lblBot != "LL"
breakTxt  = breakUp   ? "BREAK UP: price above last high "  + str.tostring(lastTop, format.mintick) :
             breakDown ? "BREAK DOWN: price below last low " + str.tostring(lastBot, format.mintick) : "none"

// the original keeps the last THREE tops and bottoms and nothing else. The first
// version drew a label at every pivot and buried the chart in them.
var label[] topL = array.new_label()
var label[] botL = array.new_label()

f_trimLabels(label[] arr, int keep) =>
    while array.size(arr) > keep
        label.delete(array.shift(arr))

if showSwing and not na(ph)
    array.push(topL, label.new(bar_index - swingN, ph, lblTop, color = color.new(color.red, 20), textcolor = color.white, style = label.style_label_down, size = lblSize))
    f_trimLabels(topL, keepSwings)
if showSwing and not na(pl)
    array.push(botL, label.new(bar_index - swingN, pl, lblBot, color = color.new(color.teal, 20), textcolor = color.white, style = label.style_label_up, size = lblSize))
    f_trimLabels(botL, keepSwings)

// impulse legs: range > impX × median range of the last 96 bars, body >= impBody %
rngMed = ta.median(high - low, 96)
isImp  = (high - low) > impX * rngMed and math.abs(close - open) >= impBody / 100 * (high - low)
if showImp and isImp
    line.new(bar_index, open, bar_index, close, color = close > open ? color.new(color.teal, 40) : color.new(color.red, 40), width = 3)

// daily ATR, Wilder 14, on COMPLETED days only — [1] keeps today out of it
dAtr  = request.security(syminfo.tickerid, "1D", ta.atr(14)[1], lookahead = barmerge.lookahead_off)
dHigh = request.security(syminfo.tickerid, "1D", high, lookahead = barmerge.lookahead_off)
dLow  = request.security(syminfo.tickerid, "1D", low,  lookahead = barmerge.lookahead_off)
dayUsed = na(dAtr) or dAtr == 0 ? na : (dHigh - dLow) / dAtr
stretchTxt = na(dayUsed) ? "n/a" : dayUsed >= 2 ? "STRETCHED (over 2× a normal day)" : dayUsed >= 1.5 ? "stretched (over 1.5×)" : "normal"

// session opens: the first bar of the local session hour, the same three
f_opened(tz, hh, mm) =>
    h = hour(time, tz)
    m = minute(time, tz)
    nowMin  = h * 60 + m
    prevMin = hour(time[1], tz) * 60 + minute(time[1], tz)
    openMin = hh * 60 + mm
    nowMin >= openMin and prevMin < openMin

tokyoOpen  = f_opened("Asia/Tokyo",        9, 0)
londonOpen = f_opened("Europe/London",     8, 0)
nyOpen     = f_opened("America/New_York",  9, 30)

var float tokyoP  = na
var float londonP = na
var float nyP     = na
if tokyoOpen
    tokyoP := open
if londonOpen
    londonP := open
if nyOpen
    nyP := open

if showSess and tokyoOpen
    line.new(bar_index, low, bar_index, high, extend = extend.both, color = color.new(color.gray, 60), style = line.style_dotted)
    label.new(bar_index, high, "Tokyo", color = color.new(color.gray, 75), textcolor = color.gray, style = label.style_label_down, size = size.small, yloc = yloc.abovebar)
if showSess and londonOpen
    line.new(bar_index, low, bar_index, high, extend = extend.both, color = color.new(color.blue, 60), style = line.style_dotted)
    label.new(bar_index, high, "London", color = color.new(color.blue, 75), textcolor = color.blue, style = label.style_label_down, size = size.small, yloc = yloc.abovebar)
if showSess and nyOpen
    line.new(bar_index, low, bar_index, high, extend = extend.both, color = color.new(color.orange, 60), style = line.style_dotted)
    label.new(bar_index, high, "New York", color = color.new(color.orange, 75), textcolor = color.orange, style = label.style_label_down, size = size.small, yloc = yloc.abovebar)

// the three values nearest a reference price, the three closest to price.
// Pine does not allow function declarations inside conditional blocks, so this
// lives at the top level even though it is only used on the last bar.
f_near3(float[] arr, float ref) =>
    out = array.new_float()
    tmp = array.copy(arr)
    cnt = math.min(3, array.size(tmp))
    if cnt > 0
        for _ = 1 to cnt
            bi = 0
            if array.size(tmp) > 0
                for j = 0 to array.size(tmp) - 1
                    if math.abs(array.get(tmp, j) - ref) < math.abs(array.get(tmp, bi) - ref)
                        bi := j
            array.push(out, array.get(tmp, bi))
            array.remove(tmp, bi)
    out


// ── step 3: volume profile ────────────────────────────────────────────────────
// the original builds this from 1 m bars and spreads each bar's volume evenly over
// the bins its high-low spans. Here it is built from CHART bars the same way.
// On a 1 m chart the two are identical; on 15 m the difference is only how the
// volume is distributed inside a bar, and the 25-dollar binning absorbs much of
// that. Run it on 1 m if you want the exact equivalent.
barsWanted = math.max(1, math.round(vpHours * 60 / (timeframe.in_seconds() / 60)))
// fence against reading past the first bar: low[i] beyond history is na and would
// poison the profile, and bar_index - barsBack must stay >= 0 for line.new.
barsBack   = math.min(math.min(barsWanted, 5000), math.max(1, bar_index))

var float pocV   = na
var float vaLoV  = na
var float vaHiV  = na
var float[] hvnA = array.new_float()
var float[] lvnA = array.new_float()

if barstate.islast and showVP
    lo = low[0]
    hi = high[0]
    for i = 0 to barsBack - 1
        lo := math.min(lo, low[i])
        hi := math.max(hi, high[i])
    b0 = math.floor(lo / vpStep)
    b1 = math.floor(hi / vpStep)
    nb = b1 - b0 + 1
    if nb > 0 and nb <= 4000
        prof = array.new_float(nb, 0.0)
        for i = 0 to barsBack - 1
            l0 = math.floor(low[i]  / vpStep) - b0
            h0 = math.floor(high[i] / vpStep) - b0
            span = h0 - l0 + 1
            if span > 0
                share = volume[i] / span
                for b = l0 to h0
                    if b >= 0 and b < nb
                        array.set(prof, b, array.get(prof, b) + share)
        // POC
        pocI = 0
        for b = 0 to nb - 1
            if array.get(prof, b) > array.get(prof, pocI)
                pocI := b
        tot = array.sum(prof)
        // value area: grow from the POC, always taking the larger neighbour
        loI = pocI
        hiI = pocI
        s   = array.get(prof, pocI)
        while s < vaPct / 100 * tot and (loI > 0 or hiI < nb - 1)
            down = loI > 0      ? array.get(prof, loI - 1) : -1.0
            up   = hiI < nb - 1 ? array.get(prof, hiI + 1) : -1.0
            if up >= down
                hiI := hiI + 1
                s := s + up
            else
                loI := loI - 1
                s := s + down
        // median and a 5-bin smoothing, as in the original
        srt = array.copy(prof)
        array.sort(srt)
        med = array.get(srt, int(nb / 2))
        sm = array.new_float(nb, 0.0)
        for b = 0 to nb - 1
            a0 = math.max(0, b - 2)
            a1 = math.min(nb - 1, b + 2)
            acc = 0.0
            for k = a0 to a1
                acc += array.get(prof, k)
            array.set(sm, b, acc / (a1 - a0 + 1))
        array.clear(hvnA)
        array.clear(lvnA)
        if nb >= 5
            for b = 2 to nb - 3
                v  = array.get(sm, b)
                mx = v
                mn = v
                for k = b - 2 to b + 2
                    mx := math.max(mx, array.get(sm, k))
                    mn := math.min(mn, array.get(sm, k))
                if v >= mx and v > hvnX * med
                    array.push(hvnA, (b0 + b) * vpStep + vpStep / 2)
                if v <= mn and v < lvnX * med and b >= loI and b <= hiI
                    array.push(lvnA, (b0 + b) * vpStep + vpStep / 2)
        pocV  := (b0 + pocI) * vpStep + vpStep / 2
        vaLoV := (b0 + loI) * vpStep
        vaHiV := (b0 + hiI) * vpStep + vpStep

var line pocL = na
var box  vaB  = na
var line[] hvnL = array.new_line()
var line[] lvnL = array.new_line()
var label[] tagL = array.new_label()

if barstate.islast and showVP and not na(pocV)
    x0 = bar_index - barsBack
    line.delete(pocL)
    box.delete(vaB)
    // Pine counts DOWN when `to` is below `from`, so `0 to size-1` on an empty
    // array runs with i = 0 instead of skipping. Every such loop needs a guard.
    if array.size(hvnL) > 0
        for i = 0 to array.size(hvnL) - 1
            line.delete(array.get(hvnL, i))
    if array.size(lvnL) > 0
        for i = 0 to array.size(lvnL) - 1
            line.delete(array.get(lvnL, i))
    if array.size(tagL) > 0
        for i = 0 to array.size(tagL) - 1
            label.delete(array.get(tagL, i))
    array.clear(hvnL)
    array.clear(lvnL)
    array.clear(tagL)
    vaB  := box.new(x0, vaHiV, bar_index + 10, vaLoV, border_color = color.new(color.blue, 45), border_width = 1, bgcolor = color.new(color.blue, 96))
    pocL := line.new(x0, pocV, bar_index + 10, pocV, color = color.orange, width = 3)
    if showLvls
        array.push(tagL, label.new(bar_index + 10, pocV,  "POC  " + str.tostring(pocV, format.mintick),  color = color.orange,            textcolor = color.black, style = label.style_label_left, size = size.small))
        array.push(tagL, label.new(bar_index + 10, vaHiV, "VAH  " + str.tostring(vaHiV, format.mintick), color = color.new(color.blue, 25), textcolor = color.white, style = label.style_label_left, size = size.small))
        array.push(tagL, label.new(bar_index + 10, vaLoV, "VAL  " + str.tostring(vaLoV, format.mintick), color = color.new(color.blue, 25), textcolor = color.white, style = label.style_label_left, size = size.small))
    hv = f_near3(hvnA, close)
    lv = f_near3(lvnA, close)
    if array.size(hv) > 0
        for i = 0 to array.size(hv) - 1
            pv = array.get(hv, i)
            array.push(hvnL, line.new(x0, pv, bar_index + 10, pv, color = color.new(color.teal, 25), width = 2, style = line.style_dashed))
            if showLvls
                array.push(tagL, label.new(bar_index + 10, pv, "HVN  " + str.tostring(pv, format.mintick), color = color.new(color.teal, 25), textcolor = color.white, style = label.style_label_left, size = size.small))
    if array.size(lv) > 0
        for i = 0 to array.size(lv) - 1
            pv = array.get(lv, i)
            array.push(lvnL, line.new(x0, pv, bar_index + 10, pv, color = color.new(color.red, 25), width = 2, style = line.style_dotted))
            if showLvls
                array.push(tagL, label.new(bar_index + 10, pv, "LVN  " + str.tostring(pv, format.mintick), color = color.new(color.red, 25), textcolor = color.white, style = label.style_label_left, size = size.small))

// ── step 6: positioning (open interest) ───────────────────────────────────────
// The OI feed is NOT specific to one symbol. Exchanges that publish open interest
// do it under a ticker derived from the pair, so the name is built from the chart's
// own symbol rather than hard-coded. Two forms are tried, because the chart may be
// the spot pair or the perpetual itself:
//     built    PREFIX:BASE+QUOTE+suffix    e.g. a spot chart of a pair
//     direct   the chart's own ticker + "_OI"   e.g. a chart already on the perp
// Both calls use ignore_invalid_symbol, so a symbol with no OI feed returns na and
// the panel says "no OI feed" while everything else keeps working. Nothing breaks
// on stocks, forex, or an exchange that publishes no open interest.
oiBuilt  = syminfo.prefix + ":" + syminfo.basecurrency + syminfo.currency + oiSuffix
oiDirect = syminfo.tickerid + "_OI"
oiA = request.security(oiBuilt,  timeframe.period, close, ignore_invalid_symbol = true)
oiB = request.security(oiDirect, timeframe.period, close, ignore_invalid_symbol = true)
oiNow = na(oiA) ? oiB : oiA
oiTicker = na(oiA) ? oiDirect : oiBuilt
bars1h = math.max(1, math.round(3600 / timeframe.in_seconds()))
bars4h = bars1h * 4
oiOk   = not na(oiNow)
oi1h   = oiOk and bar_index > bars1h ? (oiNow - oiNow[bars1h]) / oiNow[bars1h] * 100 : na
oi4h   = oiOk and bar_index > bars4h ? (oiNow - oiNow[bars4h]) / oiNow[bars4h] * 100 : na
px1h   = bar_index > bars1h ? (close - close[bars1h]) / close[bars1h] * 100 : na
px4h   = bar_index > bars4h ? (close - close[bars4h]) / close[bars4h] * 100 : na

// Written as if/else, not a chained ternary. The chained version across four
// continuation lines did not group the way it reads: on 2026-10-02 it returned
// "long flush" for OI +1.29 % with price +0.92 %, which is the "new longs" case.
f_oiRead(float dOi, float dPx) =>
    string out = "n/a"
    if not na(dOi) and not na(dPx)
        if dOi > 0 and dPx > 0
            out := "new longs — trend funded"
        else if dOi > 0 and dPx < 0
            out := "new shorts — trend funded"
        else if dOi < 0 and dPx > 0
            out := "short squeeze — closing, not new money"
        else
            out := "long flush — closing, not new money"
    out

// ── step 7: panel ─────────────────────────────────────────────────────────────
f_pos() =>
    panelPos == "Top left" ? position.top_left : panelPos == "Bottom right" ? position.bottom_right : panelPos == "Bottom left" ? position.bottom_left : position.top_right

// ── the side panel ────────────────────────────────────────────────────────────
// ONE column, label over value. Two columns forced the panel as wide as its
// longest sentence; stacking makes it narrow and tall, like a side
// panel. Every string below is kept short for the same reason — a sentence in
// here costs width on every row.
f_lab(table t, int r, string txt) =>
    table.cell(t, 0, r, txt, text_color = color.new(color.silver, 45), text_size = size.tiny, text_halign = text.align_left)

f_val(table t, int r, string txt, color c) =>
    table.cell(t, 0, r, txt, text_color = c, text_size = pnlSize, text_halign = text.align_left)

f_sec(table t, int r, string txt) =>
    table.cell(t, 0, r, txt, text_color = color.new(color.white, 30), text_size = size.tiny, text_halign = text.align_left, bgcolor = color.new(color.gray, 75))

// short forms, so the panel stays narrow
trendShort = trendTxt == "up (higher highs and lows)" ? "UP" : trendTxt == "down (lower highs and lows)" ? "DOWN" : "SIDEWAYS"
trendCol   = trendShort == "UP" ? color.teal : trendShort == "DOWN" ? color.red : color.silver
breakShort = breakUp ? "UP  " + str.tostring(lastTop, format.mintick) : breakDown ? "DOWN  " + str.tostring(lastBot, format.mintick) : "—"
f_oiShort(float dOi, float dPx) =>
    string o = "n/a"
    if not na(dOi) and not na(dPx)
        if dOi > 0 and dPx > 0
            o := "new longs"
        else if dOi > 0 and dPx < 0
            o := "new shorts"
        else if dOi < 0 and dPx > 0
            o := "short squeeze"
        else
            o := "long flush"
    o
f_oiCol(float dOi, float dPx) =>
    na(dOi) or na(dPx) ? color.silver : dOi > 0 and dPx > 0 ? color.teal : dOi > 0 and dPx < 0 ? color.red : color.orange

var table tb = na
if barstate.islast and showPanel
    table.delete(tb)
    tb := table.new(f_pos(), 1, 24, border_width = 0, frame_width = 1, frame_color = color.new(color.gray, 45), bgcolor = color.new(color.black, 8))
    table.cell(tb, 0, 0, "SWIFTEDGE MENTOR", text_color = color.white, text_size = pnlSize, text_halign = text.align_left)
    table.cell(tb, 0, 1, "alpha · no book, no CVD", text_color = color.new(color.orange, 25), text_size = size.tiny, text_halign = text.align_left)

    f_sec(tb, 2, "STRUCTURE")
    f_lab(tb, 3, "trend")
    f_val(tb, 4, trendShort, trendCol)
    f_lab(tb, 5, "break")
    f_val(tb, 6, breakShort, breakShort == "—" ? color.silver : color.orange)
    f_lab(tb, 7, "last high / low")
    f_val(tb, 8, (na(lastTop) ? "-" : lblTop + " " + str.tostring(lastTop, format.mintick)), color.new(color.red, 10))
    f_val(tb, 9, (na(lastBot) ? "-" : lblBot + " " + str.tostring(lastBot, format.mintick)), color.new(color.teal, 10))
    f_lab(tb, 10, "day range vs ATR14")
    f_val(tb, 11, na(dayUsed) ? "n/a" : str.tostring(dayUsed * 100, "#") + " %  " + (dayUsed >= 2 ? "STRETCHED" : dayUsed >= 1.5 ? "stretched" : "normal"), na(dayUsed) ? color.silver : dayUsed >= 1.5 ? color.orange : color.silver)

    f_sec(tb, 12, "VOLUME PROFILE " + str.tostring(vpHours) + "h")
    f_lab(tb, 13, "POC")
    f_val(tb, 14, na(pocV) ? "-" : str.tostring(pocV, format.mintick), color.orange)
    f_lab(tb, 15, "value area")
    f_val(tb, 16, na(vaLoV) ? "-" : str.tostring(vaHiV, format.mintick), color.new(color.blue, 10))
    f_val(tb, 17, na(vaLoV) ? "" : str.tostring(vaLoV, format.mintick), color.new(color.blue, 10))

    f_sec(tb, 18, "POSITIONING")
    f_lab(tb, 19, oiOk ? "OI 1h   vs price" : "open interest")
    f_val(tb, 20, not oiOk ? "no OI feed" : na(oi1h) ? "n/a" : str.tostring(oi1h, "+#.#") + " %  " + str.tostring(px1h, "+#.#") + " %  " + f_oiShort(oi1h, px1h), oiOk ? f_oiCol(oi1h, px1h) : color.silver)
    f_lab(tb, 21, "OI 4h   vs price")
    f_val(tb, 22, not oiOk ? "—" : na(oi4h) ? "n/a" : str.tostring(oi4h, "+#.#") + " %  " + str.tostring(px4h, "+#.#") + " %  " + f_oiShort(oi4h, px4h), oiOk ? f_oiCol(oi4h, px4h) : color.silver)

    table.cell(tb, 0, 23, "descriptive, not proven", text_color = color.new(color.orange, 35), text_size = size.tiny, text_halign = text.align_left)


// ── alerts ────────────────────────────────────────────────────────────────────
// At global scope, as Pine requires. Each one fires on the bar where the state
// changes, not on every bar it stays true.
//
// The value-area alerts depend on vaHiV / vaLoV, which are computed on the last
// bar only. That is fine for alerting, because the bar an alert evaluates on IS
// the last bar in real time — but it means these two do nothing on historical
// bars, so backtesting an alert on them will show nothing.
vaOk   = not na(vaHiV) and not na(vaLoV)
leftVA = vaOk and ((close > vaHiV and close[1] <= vaHiV) or (close < vaLoV and close[1] >= vaLoV))
intoVA = vaOk and close <= vaHiV and close >= vaLoV and (close[1] > vaHiV or close[1] < vaLoV)

// OI regime, as the panel reads it. Fires when the reading changes, not while it holds.
oiState   = not oiOk or na(oi1h) or na(px1h) ? "n/a" : f_oiShort(oi1h, px1h)
oiChanged = oiState != oiState[1] and oiState != "n/a"

alertcondition(breakUp,   "Structure break up",    "Structure break up: price above the last swing high")
alertcondition(breakDown, "Structure break down",  "Structure break down: price below the last swing low")
alertcondition(leftVA,    "Price left value area", "Price has left the value area")
alertcondition(intoVA,    "Price entered value area", "Price has moved back into the value area")
alertcondition(oiChanged, "Open interest regime changed", "The open interest reading against price has changed")
````
