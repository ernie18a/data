# SwiftEdge FVG Lifecycle

- url: https://www.tradingview.com/script/1Q13O60S-SwiftEdge-FVG-Lifecycle/
- type: indicator
- pine_id: PUB;a0cd5979bf9f4b52a2f8a760f7cda54a
- version: 1.0

## Description

SwiftEdge FVG Lifecycle follows every fair value gap (FVG) through its whole life: untouched, tapped, midpoint (CE) reached, filled, or closed through and turned into an inverse FVG (iFVG). Only live gaps stay on the chart. The panel shows what happened to the gaps on your own symbol and timeframe: how many were touched, reached the midpoint, filled or inverted, and how a simple first-touch entry at the gap performed, split by gap size and session.

Most FVG tools only draw boxes. This one is built to answer which gaps are worth paying attention to.

WHAT IT SHOWS

• Fair value gaps
A bullish FVG forms when the low of candle 3 is above the high of candle 1, leaving a price range the middle candle moved through without overlap. A bearish FVG is the mirror image. Two filters remove weak gaps:
  – Minimum size in ATR(14), so the same setting works on any symbol and timeframe.
  – Displacement: the middle candle must close in the direction of the gap with a body of at least a chosen number of ATR (0 = off).
A strong move often leaves several overlapping gaps on consecutive candles. By default these are merged into one gap, because they are one imbalance created by one move.

• Lifecycle on the chart
  – Untouched gaps are drawn with full shading. Tapped gaps are drawn lighter.
  – With "Shrink to the unfilled part" on, the box shrinks as price trades into it, so you always see the part of the imbalance that is still open.
  – The midpoint (consequent encroachment, CE) is drawn as a line while it is inside the unfilled part.
  – A gap is removed when price trades through its far edge (or, if you prefer, only when a bar closes through it).
  – A bar that closes through a gap turns it into an iFVG: a bullish gap becomes resistance, a bearish gap becomes support. iFVGs are drawn with a dashed border in the colour of their new role and are removed when a bar closes back through them.
  – Only the gaps closest to price are drawn (6 FVGs and 3 iFVGs by default, and none farther than 10 ATR away). Every gap is still tracked for the statistics.
  – Higher-timeframe gaps (on by default): up to two higher timeframes, picked automatically from the chart timeframe (for example 4H and daily on a 15-minute chart) or set manually. They are drawn behind the chart's own gaps as outlined zones with a light fill, a dashed midpoint, a timeframe tag in the corner and a label such as "4H FVG", so you can see where a lower-timeframe gap sits inside a higher-timeframe imbalance. They follow the same lifecycle (shrinking, removal, inversion) on the current chart.
  – Hover a label for the gap's range, size in ATR, the session it formed in, its current state and its age.

• Statistics panel (bullish and bearish side by side)
  – Live FVGs and iFVGs.
  – Lifecycle funnel: gaps formed, and the share that were touched, reached the midpoint, were fully filled, and were closed through (iFVG).
  – First-touch test: on the first touch, a limit entry at the gap edge (or at the midpoint), a stop beyond the far edge plus a small ATR buffer, and a target in R (2R by default) with a maximum holding time. The result is shown as win rate, average R and number of tests for all gaps, by size (small, medium, large in ATR) and by the session the gap formed in (Asia, London, New York, other hours), plus the same test on the first retest of an iFVG. Results with an average above +0.05R are shown green and below −0.05R red (with at least 20 tests).

HOW IT WORKS

1. A gap is confirmed on the close of the third candle and is followed from the next bar.
2. Every closed bar is checked against each live gap in this order: first touch, midpoint, close through (iFVG) or trade through (filled). The unfilled part is updated from the bar's low or high.
3. In the first-touch test, a stop that could have been hit on the entry bar is counted as a loss, a target is never counted on the entry bar, and gaps through the stop or target fill at the open. When the maximum holding time ends, the test closes at that bar's close. Results are in R and before costs.
4. Higher-timeframe gaps are taken from closed higher-timeframe bars only and are not part of the statistics.

HOW TO USE IT

• Read the funnel to see how your market treats gaps. A high fill rate means gaps tend to be closed; a high inversion rate means closes through gaps are common and iFVGs deserve attention.
• Use the first-touch rows to compare gap sizes and sessions before trusting a setup. Compare edge entries with midpoint entries by switching the test entry.
• The average R is before commission and slippage. On low timeframes, costs can be a large share of the risk, so a small positive average may not survive them.

SETTINGS

Detection (bullish/bearish, minimum size, displacement, merging of gaps from one impulse, fill rule, iFVGs on or off, maximum age), higher-timeframe gaps (two timeframes, auto or manual, number shown, fill, border and colours), display (number of FVGs and iFVGs shown, maximum distance from price, shrinking, transparency, borders, midpoint line and style, labels, right extension, inversion marks), colours and label text, and the statistics (test entry, stop buffer, target in R, maximum bars, size buckets, session times and timezone, panel position and text size). Alerts are available for new gaps, first touches, inversions and iFVG retests.

LIMITATIONS

• Lifecycle steps are evaluated on closed bars, so the chart can differ from what happened inside a bar. Nothing changes after a bar closes.
• The first-touch test is a fixed, simplified measurement, not a complete trading system, and it does not include costs.
• Statistics describe the history loaded on your chart and depend on the settings, the symbol, the timeframe and the data feed. They are a measurement, not a forecast, and testing many settings on the same data increases the risk of overfitting.

This script is for analysis and education. It does not provide trading advice, and past behaviour shown on the chart does not imply future results.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  SwiftEdge FVG Lifecycle
//  Fair value gaps followed through their whole life: untouched → tapped →
//  midpoint (CE) reached → filled, or closed through and inverted into an
//  iFVG. Only live gaps stay on the chart, and the panel measures how each
//  kind of gap actually behaved on the loaded history.
//
//   • Detection: three-candle imbalance with a minimum size in ATR and an
//     optional displacement filter on the middle candle.
//   • Lifecycle: gaps shrink to their unfilled part, are removed when filled,
//     and become iFVGs (opposite role) when a bar closes through them.
//     Optional higher-timeframe gaps on the same chart.
//   • Statistics: the lifecycle funnel (touched, CE, filled, inverted) and a
//     first-touch test (limit at the gap edge or CE, stop beyond the far
//     edge, fixed R target) split by gap size and session, plus iFVG retests.
//
//  Gaps are confirmed on the close of the third candle. Lifecycle steps are
//  evaluated on bar close and do not change afterwards; higher-timeframe gaps
//  use closed higher-timeframe bars only. A research tool: statistics
//  describe the loaded history only and are not a forecast.
// ═══════════════════════════════════════════════════════════════════════════
indicator("SwiftEdge FVG Lifecycle", "SE FVG Lifecycle", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═══ Inputs ════════════════════════════════════════════════════════════════
grpD = "1 · Detection"
showBu  = input.bool(true, "Bullish gaps", inline = "dir", group = grpD)
showBe  = input.bool(true, "Bearish gaps", inline = "dir", group = grpD)
minSz   = input.float(0.15, "Min gap size (ATR)", minval = 0.0, step = 0.05, group = grpD,
     tooltip = "The gap between candle 1 and candle 3 must be at least this many ATR(14). Filters out tiny gaps.")
dispK   = input.float(0.6, "Displacement: middle body ≥ (ATR, 0 = off)", minval = 0.0, step = 0.1, group = grpD,
     tooltip = "The middle candle must close in the direction of the gap with a body of at least this many ATR. Keeps gaps that were created by a real push.")
fillBy  = input.string("Wick through", "Remove when filled by", options = ["Wick through", "Close through only"], group = grpD,
     tooltip = "Wick through: a gap is removed once price trades through its far edge. Close through only: it stays until a bar closes through it. A close through always inverts the gap when iFVGs are on.")
useInv  = input.bool(true, "Turn gaps closed through into iFVGs", group = grpD,
     tooltip = "An inverse FVG: a gap that price closed through. It is kept with the opposite role (a bullish gap becomes resistance, a bearish gap support) until a bar closes back through it.")
maxAge  = input.int(0, "Remove gaps older than (bars, 0 = keep)", minval = 0, group = grpD)
mergeOn = input.bool(true, "Merge gaps from the same impulse", group = grpD,
     tooltip = "Consecutive gaps in the same direction that form within two bars of each other and overlap (or almost touch) are combined into one gap, as they are one imbalance created by one move.")

grpH = "2 · Higher-timeframe gaps"
htfOn1  = input.bool(true, "HTF 1", inline = "h1", group = grpH)
htfAu1  = input.bool(true, "Auto", inline = "h1", group = grpH)
htfTf1  = input.timeframe("240", "", inline = "h1", group = grpH,
     tooltip = "Gaps from closed higher-timeframe bars, followed on this chart and drawn as outlined zones with a timeframe tag. They are not part of the statistics.\nAuto: up to 5m → 1H and 4H, up to 15m → 4H and D, up to 1H → D and W, up to 4H → W and M.")
htfOn2  = input.bool(false, "HTF 2", inline = "h2", group = grpH)
htfAu2  = input.bool(true, "Auto", inline = "h2", group = grpH)
htfTf2  = input.timeframe("D", "", inline = "h2", group = grpH)
htfMax  = input.int(3, "Max shown per timeframe", minval = 1, maxval = 20, group = grpH)
htfFill = input.int(93, "Fill transparency", minval = 0, maxval = 100, inline = "hf", group = grpH)
htfBrd  = input.bool(true, "Border", inline = "hf", group = grpH)
htfBull = input.color(#089981, "Colours", inline = "hc", group = grpH)
htfBear = input.color(#f23645, "", inline = "hc", group = grpH)

grpV = "3 · Display"
maxShow = input.int(6, "Max FVGs shown", minval = 1, maxval = 50, group = grpV,
     tooltip = "The live gaps closest to price are drawn. Every gap is still tracked for the statistics.")
maxInvS = input.int(3, "Max iFVGs shown", minval = 0, maxval = 50, group = grpV)
maxDist = input.float(10, "Hide gaps farther than (ATR, 0 = off)", minval = 0.0, step = 1, group = grpV)
shrink  = input.bool(true, "Shrink to the unfilled part", group = grpV)
fillTr  = input.int(86, "Fill transparency", minval = 0, maxval = 100, group = grpV)
showBrd = input.bool(false, "Border on regular gaps", group = grpV)
showCE  = input.bool(true, "Midpoint (CE) line", inline = "ce", group = grpV)
ceSty   = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], inline = "ce", group = grpV)
lblMode = input.string("iFVG + HTF", "Labels", options = ["Off", "iFVG + HTF", "All"], group = grpV)
extBars = input.int(10, "Extend right (bars)", minval = 0, maxval = 200, group = grpV)
invMk   = input.bool(false, "Mark inversions", inline = "mk", group = grpV)
keepMk  = input.int(30, "kept", minval = 1, maxval = 200, inline = "mk", group = grpV)

grpC = "4 · Colours & text"
cBu     = input.color(#089981, "Bullish", inline = "c", group = grpC)
cBe     = input.color(#f23645, "Bearish", inline = "c", group = grpC)
txtOwn  = input.bool(true, "Label text in gap colour", inline = "t", group = grpC)
cTx     = input.color(#787b86, "else", inline = "t", group = grpC)
lblSz   = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpC)

grpS = "5 · Statistics"
showPan = input.bool(true, "Panel", inline = "p", group = grpS)
panPos  = input.string("Top right", "", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], inline = "p", group = grpS)
panSz   = input.string("Tiny", "Text size", options = ["Tiny", "Small", "Normal"], group = grpS)
entryT  = input.string("Gap edge", "Test entry on first touch", options = ["Gap edge", "Midpoint (CE)"], group = grpS,
     tooltip = "The first-touch test enters with a limit at the gap edge (or the midpoint), places the stop beyond the far edge and measures whether the target in R is reached first.")
stopBuf = input.float(0.1, "Stop beyond far edge (ATR)", minval = 0.0, step = 0.05, group = grpS)
tgtR    = input.float(2.0, "Target (R)", minval = 0.25, step = 0.25, inline = "tg", group = grpS)
maxBars = input.int(30, "max bars", minval = 1, maxval = 500, inline = "tg", group = grpS)
szLo    = input.float(0.5, "Size buckets (ATR): small below", minval = 0.0, step = 0.1, inline = "sb", group = grpS)
szHi    = input.float(1.0, "large above", minval = 0.0, step = 0.1, inline = "sb", group = grpS)
sesA    = input.session("2000-0300", "Asia", inline = "sa", group = grpS)
sesL    = input.session("0300-0800", "London", inline = "sl", group = grpS)
sesN    = input.session("0800-1700", "New York", inline = "sn", group = grpS)
tzS     = input.string("America/New_York", "Session timezone", group = grpS)

// ═══ Data ══════════════════════════════════════════════════════════════════
atr   = ta.atr(14)
tfMs  = timeframe.in_seconds() * 1000
inA   = not na(time(timeframe.period, sesA, tzS))
inL   = not na(time(timeframe.period, sesL, tzS))
inN   = not na(time(timeframe.period, sesN, tzS))
sessNow = inN ? 2 : inL ? 1 : inA ? 0 : 3
SESS  = array.from("Asia", "London", "New York", "Other hours")

body1 = close[1] - open[1]
bullG = not na(atr) and low > high[2] and low - high[2] >= minSz * atr and (dispK <= 0 or body1 >= dispK * atr[1])
bearG = not na(atr) and high < low[2] and low[2] - high >= minSz * atr and (dispK <= 0 or -body1 >= dispK * atr[1])

// higher-timeframe gaps from closed higher-timeframe bars only
autoTf(int lvl) =>
    s = timeframe.in_seconds()
    lvl == 1 ? (s <= 300 ? "60" : s <= 900 ? "240" : s <= 3600 ? "D" : s <= 14400 ? "W" : "M") :
     (s <= 300 ? "240" : s <= 900 ? "D" : s <= 3600 ? "W" : "M")

htfGet(string tf) =>
    request.security(syminfo.tickerid, tf, [low[1] > high[3], high[1] < low[3], high[3], low[3], high[1], low[1], time[2], ta.atr(14)[1]],
         lookahead = barmerge.lookahead_on)

tf1 = htfAu1 ? autoTf(1) : htfTf1
tf2 = htfAu2 ? autoTf(2) : htfTf2
[aBu, aBe, aH3, aL3, aH1, aL1, aT2, aAtr] = htfGet(tf1)
[bBu, bBe, bH3, bL3, bH1, bL1, bT2, bAtr] = htfGet(tf2)
ok1  = htfOn1 and timeframe.in_seconds(tf1) > timeframe.in_seconds()
ok2  = htfOn2 and timeframe.in_seconds(tf2) > timeframe.in_seconds() and timeframe.in_seconds(tf2) != timeframe.in_seconds(tf1)
new1 = timeframe.change(tf1)
new2 = timeframe.change(tf2)

lsOf(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

sizeOf(string s) =>
    s == "Small" ? size.small : s == "Normal" ? size.normal : size.tiny

posOf(string s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right :
     s == "Bottom left" ? position.bottom_left : s == "Middle right" ? position.middle_right : position.top_right

tfTxt(string tf) =>
    s = timeframe.in_seconds(tf)
    s < 3600 ? str.tostring(math.round(s / 60)) + "m" : s < 86400 ? str.tostring(math.round(s / 3600)) + "H" :
     s < 604800 ? "D" : s < 2592000 ? "W" : "M"

// ═══ Gaps ══════════════════════════════════════════════════════════════════
type Gap
    int   dir              // 1 = bullish gap, -1 = bearish gap (as formed)
    bool  inv     = false  // closed through: now an iFVG with the opposite role
    bool  htf     = false
    int   lvl     = 0      // 0 chart timeframe, 1 HTF 1, 2 HTF 2
    string tf     = ""
    float top
    float bot
    float rem              // edge of the unfilled part
    int   t0               // time of the middle candle
    int   b0               // bar the gap was confirmed
    int   sz               // size bucket 0 small, 1 medium, 2 large
    int   ss               // session 0 Asia, 1 London, 2 New York, 3 other
    float szAtr
    bool  touched = false
    bool  ce      = false
    bool  traded  = false

var gs = array.new<Gap>()      // chart-timeframe gaps (all tracked)
var hs1 = array.new<Gap>()     // higher-timeframe gaps
var hs2 = array.new<Gap>()
// lifecycle funnel per side (0 bullish, 1 bearish): formed, touched, CE, filled, inverted
var fF = array.new_int(2, 0)
var fT = array.new_int(2, 0)
var fC = array.new_int(2, 0)
var fL = array.new_int(2, 0)
var fI = array.new_int(2, 0)
// first-touch test: per side (long 0-9, short 10-19): 0 all, 1-3 size, 4-7 session, 8 iFVG retest
var stN = array.new_int(20, 0)
var stW = array.new_int(20, 0)
var stR = array.new_float(20, 0.0)
var trD  = array.new_int()
var trE  = array.new_float()
var trS  = array.new_float()
var trT  = array.new_float()
var trB  = array.new_int()
var trSz = array.new_int()
var trSs = array.new_int()
var trIv = array.new_bool()
var mkQ  = array.new_label()
// events on this bar: 0/1 new bull/bear, 2/3 first touch bull/bear, 4/5 bull/bear gap inverted, 6/7 bull/bear iFVG retest
ev = array.new_bool(8, false)

bump(array<int> a, int i) =>
    a.set(i, a.get(i) + 1)
    true

openTrade(int d, float e, float st, int sz, int ss, bool iv) =>
    if math.abs(e - st) > 0
        trD.push(d)
        trE.push(e)
        trS.push(st)
        trT.push(e + d * tgtR * math.abs(e - st))
        trB.push(bar_index)
        trSz.push(sz)
        trSs.push(ss)
        trIv.push(iv)
    true

addStat(int k, float r) =>
    bump(stN, k)
    stR.set(k, stR.get(k) + r)
    if r > 0
        bump(stW, k)
    true

closeTrade(int i, float r) =>
    base = trD.get(i) == 1 ? 0 : 10
    if trIv.get(i)
        addStat(base + 8, r)
    else
        addStat(base, r)
        addStat(base + 1 + trSz.get(i), r)
        addStat(base + 4 + trSs.get(i), r)
    trD.remove(i)
    trE.remove(i)
    trS.remove(i)
    trT.remove(i)
    trB.remove(i)
    trSz.remove(i)
    trSs.remove(i)
    trIv.remove(i)
    true

// one closed bar of a gap's life · returns 1 when the gap is gone
method step(Gap g) =>
    int gone = 0
    e     = g.inv ? -g.dir : g.dir
    near  = e == 1 ? g.top : g.bot
    far   = e == 1 ? g.bot : g.top
    mid   = (g.top + g.bot) / 2
    touch = e == 1 ? low <= near : high >= near
    atCE  = e == 1 ? low <= mid : high >= mid
    thru  = e == 1 ? low <= far : high >= far
    cThru = e == 1 ? close < far : close > far
    side  = g.dir == 1 ? 0 : 1
    stopP = far - e * stopBuf * atr
    if not g.inv
        if touch and not g.touched
            g.touched := true
            ev.set(g.dir == 1 ? 2 : 3, true)
            if not g.htf
                bump(fT, side)
        if atCE and not g.ce
            g.ce := true
            if not g.htf
                bump(fC, side)
        if not g.htf and not g.traded and (entryT == "Gap edge" ? touch : atCE)
            g.traded := true
            lvl = entryT == "Gap edge" ? near : mid
            openTrade(e, e == 1 ? math.min(open, lvl) : math.max(open, lvl), stopP, g.sz, g.ss, false)
        if cThru
            if not g.htf
                bump(fL, side)
                bump(fI, side)
            if useInv
                g.inv     := true
                g.touched := false
                g.traded  := false
                ev.set(g.dir == 1 ? 4 : 5, true)
                if invMk and (g.dir == 1 ? showBe : showBu)
                    mkQ.push(label.new(bar_index, close, "", style = label.style_diamond, color = color.new(g.dir == 1 ? cBe : cBu, 30),
                         size = size.tiny, tooltip = (g.dir == 1 ? "Bullish" : "Bearish") + " FVG closed through: now an iFVG (" +
                         (g.dir == 1 ? "resistance" : "support") + ")"))
                    if mkQ.size() > keepMk
                        label.delete(mkQ.shift())
            else
                gone := 1
        else if thru and fillBy == "Wick through"
            if not g.htf
                bump(fL, side)
            gone := 1
        else if touch
            g.rem := e == 1 ? math.max(g.bot, math.min(g.rem, low)) : math.min(g.top, math.max(g.rem, high))
    else
        if cThru
            gone := 1
        else if touch and not g.traded
            g.traded := true
            ev.set(e == 1 ? 6 : 7, true)
            if not g.htf
                openTrade(e, e == 1 ? math.min(open, near) : math.max(open, near), stopP, g.sz, g.ss, true)
    if maxAge > 0 and bar_index - g.b0 > maxAge
        gone := 1
    gone

runLife(array<Gap> arr) =>
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            g = arr.get(i)
            if bar_index > g.b0
                if g.step() == 1
                    arr.remove(i)
    true

addHtf(array<Gap> arr, bool bu, bool be, float h3, float l3, float h1, float l1, int t2, float hAtr, string tf, int lvl) =>
    if bu or be
        d   = bu ? 1 : -1
        top = bu ? l1 : l3
        bot = bu ? h3 : h1
        if na(hAtr) or top - bot >= minSz * hAtr
            arr.push(Gap.new(dir = d, htf = true, lvl = lvl, tf = tf, top = top, bot = bot, rem = d == 1 ? top : bot, t0 = t2,
                 b0 = bar_index, sz = 1, ss = 3, szAtr = hAtr > 0 ? (top - bot) / hAtr : float(na)))
            if arr.size() > 60
                arr.shift()
    true

// ═══ Engine (on bar close) ═════════════════════════════════════════════════
if barstate.isconfirmed
    // 1) lifecycle of every live gap (may open first-touch tests)
    runLife(gs)
    runLife(hs1)
    runLife(hs2)
    // 2) open tests: stop first, no target on the entry bar, time exit at the close
    if trD.size() > 0
        for i = trD.size() - 1 to 0
            d    = trD.get(i)
            e    = trE.get(i)
            st   = trS.get(i)
            tg   = trT.get(i)
            b    = trB.get(i)
            risk = math.abs(e - st)
            gapS = b < bar_index and (d == 1 ? open <= st : open >= st)
            hitS = d == 1 ? low <= st : high >= st
            hitT = b < bar_index and (d == 1 ? high >= tg : low <= tg)
            if gapS
                closeTrade(i, d * (open - e) / risk)
            else if hitS
                closeTrade(i, -1.0)
            else if hitT
                closeTrade(i, d * ((d == 1 ? math.max(open, tg) : math.min(open, tg)) - e) / risk)
            else if bar_index - b >= maxBars
                closeTrade(i, d * (close - e) / risk)
    // 3) new chart-timeframe gaps
    if bullG or bearG
        d   = bullG ? 1 : -1
        top = bullG ? low : low[2]
        bot = bullG ? high[2] : high
        sA  = (top - bot) / atr
        // one impulse, one gap: extend the previous untouched gap when the new one joins it
        int jn = -1
        if mergeOn and gs.size() > 0
            pg = gs.last()
            if pg.dir == d and not pg.inv and not pg.touched and bar_index - pg.b0 <= 2 and
                 bot <= pg.top + 0.1 * atr and top >= pg.bot - 0.1 * atr
                jn := gs.size() - 1
        if jn >= 0
            pg = gs.get(jn)
            pg.top   := math.max(pg.top, top)
            pg.bot   := math.min(pg.bot, bot)
            pg.rem   := d == 1 ? pg.top : pg.bot
            pg.b0    := bar_index
            pg.szAtr := (pg.top - pg.bot) / atr
            pg.sz    := pg.szAtr < szLo ? 0 : pg.szAtr > szHi ? 2 : 1
        else
            gs.push(Gap.new(dir = d, top = top, bot = bot, rem = d == 1 ? top : bot, t0 = time[1], b0 = bar_index,
                 sz = sA < szLo ? 0 : sA > szHi ? 2 : 1, ss = sessNow, szAtr = sA))
            bump(fF, d == 1 ? 0 : 1)
            ev.set(d == 1 ? 0 : 1, true)
        if gs.size() > 300
            gs.shift()
    // 4) new higher-timeframe gaps
    if ok1 and new1
        addHtf(hs1, aBu, aBe, aH3, aL3, aH1, aL1, aT2, aAtr, tf1, 1)
    if ok2 and new2
        addHtf(hs2, bBu, bBe, bH3, bL3, bH1, bL1, bT2, bAtr, tf2, 2)

// ═══ Drawing (last bar only: the closest live gaps) ════════════════════════
var bxA = array.new_box()
var lnA = array.new_line()
var lbA = array.new_label()

visible(Gap g) =>
    e = g.inv ? -g.dir : g.dir
    e == 1 ? showBu : showBe

distOf(Gap g) =>
    hi = g.top
    lo = g.bot
    close > hi ? close - hi : close < lo ? lo - close : 0.0

drawGap(Gap g) =>
    e    = g.inv ? -g.dir : g.dir
    c    = g.htf ? (e == 1 ? htfBull : htfBear) : e == 1 ? cBu : cBe
    top  = g.inv or not shrink or g.dir == -1 ? g.top : g.rem
    bot  = g.inv or not shrink or g.dir == 1 ? g.bot : g.rem
    rt   = time + extBars * tfMs
    tr   = g.htf ? math.min(100, htfFill + (g.touched ? 2 : 0) + (g.inv ? 3 : 0)) :
         math.min(100, fillTr + (g.touched ? 5 : 0) + (g.inv ? 6 : 0))
    brd  = g.htf ? (htfBrd ? color.new(c, g.inv ? 45 : 15) : color(na)) : g.inv or showBrd ? color.new(c, g.inv ? 55 : 50) : color(na)
    bxA.push(box.new(g.t0, top, rt, bot, xloc = xloc.bar_time, bgcolor = color.new(c, tr), border_color = brd,
         border_style = g.inv ? line.style_dashed : line.style_solid, border_width = g.lvl == 2 ? 2 : 1))
    if g.htf and lblMode != "Off"
        // timeframe tag in the top-left corner of the zone
        lbA.push(label.new(g.t0, top, tfTxt(g.tf), xloc = xloc.bar_time, style = label.style_label_upper_left,
             color = color(na), textcolor = color.new(c, 10), size = size.tiny))
    mid = (g.top + g.bot) / 2
    if showCE and mid <= top and mid >= bot
        lnA.push(line.new(g.t0, mid, rt, mid, xloc = xloc.bar_time, color = color.new(c, g.ce or g.inv ? 65 : 40), style = g.htf ? line.style_dashed : lsOf(ceSty)))
    if lblMode == "All" or (lblMode == "iFVG + HTF" and (g.inv or g.htf))
        name = (g.htf ? tfTxt(g.tf) + " " : "") + (g.inv ? "iFVG" : "FVG")
        state = g.inv ? (g.traded ? "iFVG, retested" : "iFVG, not retested yet") : g.ce ? "midpoint reached" : g.touched ? "tapped" : "untouched"
        lbA.push(label.new(rt, (top + bot) / 2, name, xloc = xloc.bar_time, style = label.style_label_left, color = color(na),
             textcolor = txtOwn ? c : cTx, size = sizeOf(lblSz),
             tooltip = (g.dir == 1 ? "Bullish" : "Bearish") + " FVG" + (g.htf ? " (" + tfTxt(g.tf) + ")" : "") +
             (g.inv ? ", closed through: now " + (e == 1 ? "support" : "resistance") : "") +
             "\n" + str.tostring(g.top, format.mintick) + " – " + str.tostring(g.bot, format.mintick) +
             (na(g.szAtr) ? "" : " · " + str.tostring(g.szAtr, "#.##") + " ATR" + (g.htf ? " of " + tfTxt(g.tf) : "")) +
             (g.htf ? "" : "\nFormed in: " + SESS.get(g.ss)) + "\nState: " + state +
             "\nConfirmed " + str.tostring(bar_index - g.b0) + " bars ago"))
    true

// draws the n live gaps of one kind closest to price
drawSet(array<Gap> arr, bool inv, int n) =>
    m = arr.size()
    if m > 0 and n > 0
        used = array.new_bool(m, false)
        for k = 1 to n
            int best = -1
            float bd = 1e18
            for i = 0 to m - 1
                g = arr.get(i)
                if not used.get(i) and g.inv == inv and visible(g)
                    dd = distOf(g)
                    if dd < bd and (g.htf or maxDist <= 0 or dd <= maxDist * atr)
                        bd := dd
                        best := i
            if best >= 0
                used.set(best, true)
                drawGap(arr.get(best))
    true

if barstate.islast
    for b in bxA
        box.delete(b)
    for l in lnA
        line.delete(l)
    for l in lbA
        label.delete(l)
    bxA.clear()
    lnA.clear()
    lbA.clear()
    // higher timeframes first, so chart-timeframe gaps are drawn on top
    if ok2
        drawSet(hs2, false, htfMax)
        if useInv
            drawSet(hs2, true, htfMax)
    if ok1
        drawSet(hs1, false, htfMax)
        if useInv
            drawSet(hs1, true, htfMax)
    drawSet(gs, false, maxShow)
    if useInv
        drawSet(gs, true, maxInvS)

// ═══ Panel ═════════════════════════════════════════════════════════════════
cTxt  = #d1d4dc
cMute = #787b86

pctOf(int a, int b) =>
    b == 0 ? "—" : str.tostring(a * 100.0 / b, "#") + "%"

testTxt(int k) =>
    n = stN.get(k)
    n == 0 ? "—" : str.tostring(stW.get(k) * 100.0 / n, "#") + "% · " + (stR.get(k) >= 0 ? "+" : "") +
     str.tostring(stR.get(k) / n, "#.##") + "R (" + str.tostring(n) + ")"

testCol(int k) =>
    n = stN.get(k)
    n < 20 ? cTxt : stR.get(k) / n > 0.05 ? cBu : stR.get(k) / n < -0.05 ? cBe : cTxt

var table pt = na
if barstate.islast and showPan
    if not na(pt)
        table.delete(pt)
    PS = sizeOf(panSz)
    pt := table.new(posOf(panPos), 3, 20, bgcolor = color.new(#131722, 8), frame_color = #2a2e39, frame_width = 1, border_width = 0)
    int lvB = 0
    int lvS = 0
    int ivB = 0
    int ivS = 0
    if gs.size() > 0
        for g in gs
            if g.inv
                ivB += g.dir == -1 ? 1 : 0
                ivS += g.dir == 1 ? 1 : 0
            else
                lvB += g.dir == 1 ? 1 : 0
                lvS += g.dir == -1 ? 1 : 0
    kL = array.from("SwiftEdge FVG Lifecycle", "Live FVGs", "Live iFVGs", "Lifecycle", "  Formed", "  Touched", "  Midpoint (CE) reached",
         "  Fully filled", "  Closed through (iFVG)", "First touch → " + str.tostring(tgtR, "#.##") + "R before stop · entry " + (entryT == "Gap edge" ? "edge" : "CE"),
         "  All", "  Small (< " + str.tostring(szLo, "#.##") + " ATR)", "  Medium", "  Large (> " + str.tostring(szHi, "#.##") + " ATR)",
         "  Asia", "  London", "  New York", "  Other hours", "  iFVG retest", "win rate · avg R (n) · before costs")
    for r = 0 to kL.size() - 1
        hdr = r == 3 or r == 9 or r == 19
        table.cell(pt, 0, r, kL.get(r), text_color = r == 0 ? cTxt : hdr ? color.new(cMute, 20) : cMute, text_size = PS, text_halign = text.align_left)
    table.cell(pt, 1, 0, "Bull", text_color = cBu, text_size = PS, text_halign = text.align_right)
    table.cell(pt, 2, 0, "Bear", text_color = cBe, text_size = PS, text_halign = text.align_right)
    for s = 0 to 1
        col = 1 + s
        table.cell(pt, col, 1, str.tostring(s == 0 ? lvB : lvS), text_color = cTxt, text_size = PS, text_halign = text.align_right)
        table.cell(pt, col, 2, str.tostring(s == 0 ? ivB : ivS), text_color = cTxt, text_size = PS, text_halign = text.align_right)
        f = fF.get(s)
        table.cell(pt, col, 4, str.tostring(f), text_color = cTxt, text_size = PS, text_halign = text.align_right)
        table.cell(pt, col, 5, pctOf(fT.get(s), f), text_color = cTxt, text_size = PS, text_halign = text.align_right)
        table.cell(pt, col, 6, pctOf(fC.get(s), f), text_color = cTxt, text_size = PS, text_halign = text.align_right)
        table.cell(pt, col, 7, pctOf(fL.get(s), f), text_color = cTxt, text_size = PS, text_halign = text.align_right)
        table.cell(pt, col, 8, pctOf(fI.get(s), f), text_color = cTxt, text_size = PS, text_halign = text.align_right)
        for j = 0 to 8
            k = s * 10 + j
            table.cell(pt, col, 10 + j, testTxt(k), text_color = testCol(k), text_size = PS, text_halign = text.align_right)

// ═══ Alerts ════════════════════════════════════════════════════════════════
alertcondition(ev.get(0), "New bullish FVG", "SE FVG Lifecycle: new bullish FVG")
alertcondition(ev.get(1), "New bearish FVG", "SE FVG Lifecycle: new bearish FVG")
alertcondition(ev.get(2), "Bullish FVG first touch", "SE FVG Lifecycle: price tapped a bullish FVG")
alertcondition(ev.get(3), "Bearish FVG first touch", "SE FVG Lifecycle: price tapped a bearish FVG")
alertcondition(ev.get(4), "Bullish FVG inverted", "SE FVG Lifecycle: bullish FVG closed through, now a bearish iFVG")
alertcondition(ev.get(5), "Bearish FVG inverted", "SE FVG Lifecycle: bearish FVG closed through, now a bullish iFVG")
alertcondition(ev.get(6), "Bullish iFVG retest", "SE FVG Lifecycle: price retested a bullish iFVG (support)")
alertcondition(ev.get(7), "Bearish iFVG retest", "SE FVG Lifecycle: price retested a bearish iFVG (resistance)")
````
