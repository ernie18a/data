# Dynamic Liquidity Draw [AlgoNorth]

- url: https://www.tradingview.com/script/P8OSB7kB-Dynamic-Liquidity-Draw-AlgoNorth/
- type: indicator
- pine_id: PUB;1d0feea3f8ea48c9b0d59587bb7020d4
- version: 1.0

## Description

Dynamic Liquidity Draw

Structure just turned. Where is the next pool of liquidity in that direction, and how far away is it? Most liquidity scripts cover the chart in levels and leave you to work out which one matters now. This one picks the nearest untaken pool on the side structure points to and draws the line from price to it.

The line arcs onto the pool and holds there, green for a pool above, red for a pool below. When price takes it, or structure turns again, the line moves to the next one. Tags name each pool it targets, dots mark the bar that reaches it, and a panel keeps count of how often that happened on your chart.

🔶 USAGE

🔸 Follow the arc. The line eases from price onto the target pool and holds it until the pool is reached or structure flips. Green means the target is above price, red means below. Candles can take the same colour, with Colour candles by target side.

🔸 Read the tags. BSL is a swing high (buy-side liquidity), SSL a swing low (sell-side liquidity). EQH and EQL mark a pool that two or more swings share within the equal-pool tolerance. Tags sit on the candle that made the pool.

🔸 Watch the dots. When the target pool is reached, a dot marks the bar: gold for a sweep (price traded through and closed back inside), or in the chart's text colour for a break (price closed beyond the pool).

🔸 Prior targets. If structure flips before the target is reached, the pool keeps a dashed level labelled "prior target" until price trades through it.

🔸 Grey means no pool. When every pool on the structure side has been taken, a grey line follows the extreme still forming until a new swing is confirmed. Grey carries no tag, dot or count.

🔸 Read the panel. Structure, the current target and its distance in ATR, pools tracked on each side, targets reached and dropped, sweeps and breaks, average bars to reach, and reach rates by how far away the target was when it was set.

🔸 Alerts: pool reached above, pool reached below, pool swept, pool broken, target dropped. All fire at bar close.

🔶 DETAILS

🔸 Pools. A swing high or low with 5 bars each side, confirmed 5 bars after it forms. A pool stays on the list until price trades through it. The newest 60 per side are kept.

🔸 Equal pools. A new swing within 0.1 ATR of the nearest pool on its side joins that pool instead of making a new one. The pool keeps its own price.

🔸 Structure. Range breakout mode: a close above the highest high of the last 20 bars turns structure up, a close below the lowest low turns it down. Swing break mode uses a close beyond the latest structure swing instead. Structure only changes at a bar close.

🔸 The target. The nearest untaken pool on the structure side. It is held until reached or dropped, even if a nearer pool forms. Reached means price traded through it; a touch is not a take.

🔸 The arc. The line starts at the candle's extreme on the flip bar and eases toward the target over about 10 bars, then held at least 50% of the way from the candle toward the target and never past the candle itself. The shading runs from the line to a short average of close. The arc's shape is a drawing device; only its destination, the pool, is measured.

🔸 Reach rates. Every finished target is filed in the band its distance fell in when set (0–1, 1–2, 2–3, 3–4, 4+ ATR), and the panel shows what share of each band was reached before structure flipped. Nearer targets are reached more often by construction. These are counts over the loaded history, not a forecast and not a backtest. Counts are targets, not distinct pools: a pool dropped at a structure flip can be targeted again and is counted each time.

🔸 Price only. Pools are inferred from swing highs and lows. The script has no order data, so "liquidity" here means the levels where resting orders are commonly assumed to sit, not a measurement of them.

🔶 SETTINGS

🔸 Logic: Swing length, Equal pool tolerance, Structure mode, Structure length, Structure swing length, Arc length, Minimum lead toward pool, Edge smoothing, Oldest pool to target, Pools kept per side.

🔸 Style: Show arc and shading, Show forming extreme when no pool, Line width, Pool above and Pool below colours, Colour candles by target side, Shading strength, Mark untaken pools, Tag target pools, Pool tag size, Mark reached target pools, Sweep dot colour, Show prior targets, Prior target levels kept, Show live pool level, Show pool price tag, Mark structure flips.

🔸 Panel: Show panel, Panel corner. Four corners for when more than one copy is loaded.

🔶 NOTES

🔸 This is a context tool. It shows where the next pool is and keeps score; it doesn't give buy or sell signals. What you do with the read is up to you.

🔸 Nothing is drawn until the first structure break. From then on, every decision is made when a bar closes, and nothing on a closed bar is ever moved or redrawn.

🔸 Pool tags sit on the candle that made the pool, so you can see at a glance which swing is being targeted. A tag is written on the bar where its pool becomes the target, which is at least 5 bars after the swing formed and often more, and it stays exactly where it is from then on. Prior-target levels work the same way: drawn on the bar structure flips, starting from the pool's candle, and never changed afterwards. Read them as a record of which swings were targeted rather than a marker that appeared in real time.

🔸 Liquidity is read from price. Swing highs and lows stand in for where orders are assumed to rest; no order book or volume data is used.

🔸 The panel's rates come from the bars loaded on your chart, so each symbol and timeframe shows its own numbers, and more history changes them.

🔸 The newest 300 tags and 20 prior-target levels are kept.

🔸 The preview has Colour candles by target side switched on. It is off by default, so your own candle colours are kept until you turn it on.

🔸 Made for candle and bar charts. On Renko, Kagi and similar chart types the panel says the levels and rates differ.

🔶 SUMMARY

Dynamic Liquidity Draw picks the nearest untaken pool on the side structure points to and draws the line from price to it: green to a swing high above, red to a swing low below. Take the pool or turn structure, and the line moves on to the next one. Add it to your chart and see which pool the line is pointing to right now.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoNorth

//@version=6
indicator("Dynamic Liquidity Draw [AlgoNorth]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ── Inputs ─────────────────────────────────────────────────────────────────────
string G1 = "Logic"
int    pivLen   = input.int(5,   "Swing length", minval = 2, maxval = 100, group = G1, tooltip = "Bars each side that make a swing high or low. A pool is a swing high or low that price has not traded through yet. A swing is confirmed this many bars after it forms, so a pool cannot be targeted or marked before then.")
float  eqTol    = input.float(0.1, "Equal pool tolerance (ATR, 0 = off)", minval = 0.0, maxval = 1.0, step = 0.05, group = G1, tooltip = "A new swing within this distance of the nearest untaken pool on its side joins that pool instead of making a new one. The pool keeps its own price, which is the more extreme of the two. A pool that two or more swings share when it first becomes the target is tagged EQH or EQL: the prices are within the tolerance, not necessarily equal. A tag is never rewritten, so a pool that a second swing joins after it was first targeted keeps BSL or SSL. 0 = off.")
string sMode    = input.string("Range breakout", "Structure mode", options = ["Range breakout", "Swing break"], group = G1, tooltip = "Range breakout: structure turns on a close beyond the highest high or lowest low of the structure length, counted over the bars before the current one. Swing break: on a close beyond the latest structure swing high or low. Structure only changes at the close of a bar. No line, shading, candle colour or target exists until the first break.")
int    biasLen  = input.int(20,  "Structure length (range breakout)", minval = 2, maxval = 500, group = G1, tooltip = "Range breakout mode. A close above the highest high of this many bars before the current one turns structure up; a close below their lowest low turns it down.")
int    sLen     = input.int(10,  "Structure swing length (swing break)", minval = 2, maxval = 200, group = G1, tooltip = "Swing break mode. Bars each side that make a structure swing, which is confirmed that many bars after it forms. A close above the latest structure swing high turns structure up; a close below the latest structure swing low turns it down. A level is used up once it is broken.")
int    smLen    = input.int(10,  "Arc length", minval = 1, maxval = 100, group = G1, tooltip = "How gradually the line eases onto a new pool, and how long the minimum lead takes to build after a structure flip. Higher = a longer, more gradual arc. If structure flips before the line arrives, the arc ends short of the pool's level.")
int    leadPct  = input.int(50,  "Minimum lead toward pool (%)", minval = 0, maxval = 100, group = G1, tooltip = "Keeps the line at least this share of the way from the candle's extreme toward the target level, which is eased over a few bars when the target changes. The lead builds from zero at a structure flip to its full size over the arc length. The line is always held at or beyond the candle's extreme on the target side, so price cannot overtake it.")
int    avgLen   = input.int(6,   "Edge smoothing", minval = 1, maxval = 100, group = G1, tooltip = "Length of the short average of close that the shading runs to. The line never crosses to the price side of it. After a structure flip the arc starts from the candle's extreme, not from this average. 1 = the raw close.")
int    maxAge   = input.int(0,   "Oldest pool to target (bars, 0 = no limit)", minval = 0, maxval = 5000, group = G1, tooltip = "Pools whose latest swing is older than this are not picked as a new target. The nearest pool is always the newest on its side, so when it is too old no pool is targeted. A target already held is kept past this age. 0 = no limit. Values up to the swing length are raised to the swing length plus one.")
int    maxPools = input.int(60,  "Pools kept per side", minval = 5, maxval = 200, group = G1, tooltip = "Only the newest untaken pools on each side are tracked. At this cap the furthest pool is dropped, unless it is the current target, in which case the next furthest is dropped.")

string G2 = "Style"
bool   showArc  = input.bool(true, "Show arc and shading", group = G2, tooltip = "The line eases from price onto the target pool: the nearest untaken pool on the side structure points to. A target is held until it is reached or structure flips, even if a nearer pool forms. The line is drawn from current and past bars only and is not a forecast; the shading carries no data. The line and shading are left off the bar where structure flips; on a live bar they drop out at its close.")
bool   showProv = input.bool(true, "Show forming extreme when no pool", group = G2, tooltip = "When there is no pool to target on the side structure points to, either because price has taken them all or because the nearest is older than the age limit, nothing can be targeted until a new swing is confirmed. With this on, a grey line and shading follow the extreme still forming: the highest high or lowest low of the last four swing lengths of bars. Grey means no pool is being targeted: no tag, level, dot, alert or count. The colour changes on the bar a pool becomes the target. Off = nothing is drawn and candles are left uncoloured while there is no pool.")
int    lineW    = input.int(3, "Line width", minval = 1, maxval = 5, group = G2, tooltip = "Width of the target line. Its glow is four wider.")
color  colUp    = input.color(#00E676, "Pool above", group = G2, tooltip = "Colour of the line, shading, candles, marks and tags on the upper side: structure up, pools above price.")
color  colDn    = input.color(#FF1744, "Pool below", group = G2, tooltip = "Colour of the line, shading, candles, marks and tags on the lower side: structure down, pools below price.")
bool   colBars  = input.bool(false, "Colour candles by target side", group = G2, tooltip = "Colours candles by the side structure points to, while a target or the forming extreme is being followed. The side is decided at the close of a bar, and a closed bar's colour never changes. A live bar can change colour once, at its close, when structure flips on it.")
float  layerT   = input.float(97.0, "Shading strength (lower = stronger)", minval = 93.0, maxval = 99.5, step = 0.5, group = G2, tooltip = "Transparency of each of the 22 shading layers. They overlap most at the line, so the shading is densest there and fades toward price.")
bool   showAll  = input.bool(false, "Mark untaken pools", group = G2, tooltip = "A small mark just beyond the wick of every untaken pool, drawn when the swing is confirmed and placed back on the swing's candle; it turns brighter and thicker when a second swing joins the pool. The mark is removed when the pool is taken or dropped by the cap.")
bool   showPool = input.bool(true, "Tag target pools (BSL / SSL / EQH / EQL)", group = G2, tooltip = "BSL = buy-side liquidity: a swing high that stop orders are commonly assumed to rest above. SSL = sell-side liquidity: a swing low they are assumed to rest below. EQH / EQL = a pool that two or more swings share. This script reads price only, no order data: pools are inferred from swing highs and lows. A tag is written once, when its pool first becomes the target, and is placed back on the candle that made the pool. That can be many bars after the candle formed, so tags are a historical record of which swings were targeted, not a real-time signal. Where the pool's candle also carries a sweep or break dot on the same side, the tag sits further out so the two stay apart. The newest 300 tags are kept.")
string poolSz   = input.string("Small", "Pool tag size", options = ["Tiny", "Small", "Normal"], group = G2, tooltip = "Text size of the pool tags. The 'prior target' text is one size larger.")
bool   showHit  = input.bool(true, "Mark reached target pools (sweep or break)", group = G2, tooltip = "Sweep: price traded through the target pool and closed back inside it. Break: price closed beyond it or exactly on it. Judged once, at the close of the bar that reaches the pool. The dot sits just beyond the wick of that bar. Only the target pool is judged.")
color  colSweep = input.color(#FFC83D, "Sweep dot", group = G2, tooltip = "Colour of the sweep dot. On a light chart background the default yellow is swapped for a stronger amber so it stays visible; a colour you pick yourself is used as it is. The break dot follows the chart's foreground colour.")
bool   showPrior = input.bool(true, "Show prior targets", group = G2, tooltip = "A prior target is a pool that was the target when structure flipped, before price reached it. It says nothing about what price does next: price may trade through it later. It is drawn as a dashed level from its own candle until price trades through it, then kept as a record ending at that bar. The level and its 'prior target' text are drawn at the close of the bar where structure flipped, and the text sits on that bar. The part of the level before that bar is backdated, so it is a historical record, not a real-time signal. One level per pool: if it becomes the target again, its dashed level carries on, no dotted level is drawn for it, and a second drop adds nothing. The oldest levels are removed by the cap below.")
int    maxPrior  = input.int(20, "Prior target levels kept", minval = 1, maxval = 50, group = G2, tooltip = "How many prior target levels are kept, newest first.")
bool   showLvl  = input.bool(true, "Show live pool level", group = G2, tooltip = "A dotted level at the current target pool's price, from the candle that made the pool to the right-hand edge. It exists only while that pool is the target.")
bool   showTag  = input.bool(true, "Show pool price tag", group = G2, tooltip = "A price label for the target pool, to the right of the last bar.")
bool   showFlip = input.bool(true, "Mark structure flips", group = G2, tooltip = "A triangle on the bar where structure changes direction, including the first break. Decided at the close of the bar and never withdrawn.")

string G3 = "Panel"
bool   showTbl  = input.bool(true, "Show panel", group = G3, tooltip = "Live state plus a tally over the bars this chart has loaded, so the numbers depend on how much history is loaded. Counts are targets, not distinct pools: a pool dropped at a structure flip can be targeted and counted again. Reached means reached before structure flipped. 'Set N ATR away' rows: of the finished targets that were that far from price when set, the rate that were reached. The target still open is not counted. Not a backtest: no orders and no costs are modelled, and the rates are a record of this chart's history, not a forecast.")
string tblPos   = input.string("Top right", "Panel corner", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = G3, tooltip = "Which corner of the chart the panel sits in.")

// Pool tags kept on the chart, of TradingView's 500-label limit
const int   MAXTAG   = 300
// Reach-rate bands by distance when the target is set, in ATR: 0-1, 1-2, 2-3, 3-4, 4+
const int   NB       = 5
// Line and shading colour while there is no confirmed pool
const color COL_FORM = #8A8F98
// Sweep dot colour used on a light chart background while the input is left at its default yellow
const color COL_SWEEP_LIGHT = #FFA800
// Bars with a reached-pool dot that are remembered per side, so a later tag can avoid the dot
const int   MAXDOT   = 5000

float  atr       = ta.atr(14)
// Bar length in milliseconds for time-anchored drawings; one minute if the chart reports none
int    tfSec     = timeframe.in_seconds()
int    tfMs      = (tfSec > 0 ? tfSec : 60) * 1000
string poolSize  = poolSz == "Tiny" ? size.tiny : poolSz == "Normal" ? size.normal : size.small
// The 'prior target' text is one size larger than the pool tags
string priorSize = poolSz == "Tiny" ? size.small : poolSz == "Normal" ? size.large : size.normal
// A pool is already pivLen bars old when it is confirmed, so a smaller limit could never be met
int    maxAgeEff = maxAge == 0 ? 0 : math.max(maxAge, pivLen + 1)

// Perceived brightness of a colour, 0 to 255
f_lum(color c) =>
    0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)

// Black or white text, whichever reads on the given plate
f_txt(color plate) =>
    f_lum(plate) > 140 ? color.black : color.white

// The sweep dot's colour. The default yellow is hard to see on a light chart background, so
// it is swapped for a stronger amber there; a colour the user picked is left alone.
bool  sweepIsDefault = color.r(colSweep) == 255 and color.g(colSweep) == 200 and color.b(colSweep) == 61
color cSweep         = sweepIsDefault and f_lum(chart.bg_color) > 140 ? COL_SWEEP_LIGHT : colSweep

// ── Pools: untaken swing highs and lows ────────────────────────────────────────
// Per pool: price, bar and time of the swing that made it, bar of its latest swing, ATR when
// it was confirmed, how many swings share it, its tag text (empty until named) and its mark.
var array<float>  highs    = array.new<float>()
var array<int>    highsBar = array.new<int>()
var array<int>    highsTm  = array.new<int>()
var array<int>    highsAge = array.new<int>()
var array<float>  highsAtr = array.new<float>()
var array<int>    highsEq  = array.new<int>()
var array<string> highsTx  = array.new<string>()
var array<line>   highsTk  = array.new<line>()
var array<float>  lows     = array.new<float>()
var array<int>    lowsBar  = array.new<int>()
var array<int>    lowsTm   = array.new<int>()
var array<int>    lowsAge  = array.new<int>()
var array<float>  lowsAtr  = array.new<float>()
var array<int>    lowsEq   = array.new<int>()
var array<string> lowsTx   = array.new<string>()
var array<line>   lowsTk   = array.new<line>()

// Bars that carry a reached-pool dot above their high, and below their low
var array<int> dotUpB = array.new<int>()
var array<int> dotDnB = array.new<int>()

// Which pool the target is. Declared here because the per-side cap must never drop it.
var bool tgtIsPool = false
var int  tgtBar    = na
var int  tgtBias   = 0

// A pool is taken once price trades through it; a touch is not a take. Each side is ordered
// by price with the nearest pool last, so the scan stops at the first pool still standing.
f_take(array<float> lv, array<int> bars, array<int> ages, array<int> tms, array<float> ats, array<int> eqs, array<string> txs, array<line> tks, bool isHigh) =>
    if lv.size() > 0
        for i = lv.size() - 1 to 0
            bool taken = isHigh ? high > lv.get(i) : low < lv.get(i)
            if not taken
                break
            lv.remove(i)
            bars.remove(i)
            ages.remove(i)
            tms.remove(i)
            ats.remove(i)
            eqs.remove(i)
            txs.remove(i)
            line.delete(tks.remove(i))

f_take(highs, highsBar, highsAge, highsTm, highsAtr, highsEq, highsTx, highsTk, true)
f_take(lows,  lowsBar,  lowsAge,  lowsTm,  lowsAtr,  lowsEq,  lowsTx,  lowsTk,  false)

// Pool mark: three bars wide, an eighth of an ATR beyond the wick tip
f_mark(int t, float price, bool isHigh) =>
    float y = price + (isHigh ? 0.125 : -0.125) * atr
    line.new(t - tfMs, y, t + tfMs, y, xloc = xloc.bar_time, color = color.new(isHigh ? colUp : colDn, 45), width = 1)

// A new swing joins the nearest pool on its side when it is within the tolerance, otherwise
// it becomes a pool of its own.
f_addPool(array<float> lv, array<int> bars, array<int> ages, array<int> tms, array<float> ats, array<int> eqs, array<string> txs, array<line> tks, float p, bool isHigh) =>
    int  b  = bar_index - pivLen
    int  t  = time[pivLen]
    int  n  = lv.size()
    bool mg = false
    if eqTol > 0 and n > 0
        if math.abs(lv.last() - p) <= eqTol * atr
            // The pool keeps its own price, which is never less extreme than a swing that joins it
            mg := true
            eqs.set(n - 1, eqs.last() + 1)
            ages.set(n - 1, b)
            if not na(tks.last())
                line.set_color(tks.last(), color.new(isHigh ? colUp : colDn, 10))
                line.set_width(tks.last(), 2)
    if not mg
        line mk = na
        if showAll and not na(atr)
            mk := f_mark(t, p, isHigh)
        lv.push(p)
        bars.push(b)
        ages.push(b)
        tms.push(t)
        ats.push(atr)
        eqs.push(1)
        txs.push("")
        tks.push(mk)
        if lv.size() > maxPools
            // Drop the furthest pool, or the next furthest when the furthest is the held target
            int di = tgtIsPool and (tgtBias > 0) == isHigh and bars.get(0) == tgtBar ? 1 : 0
            line.delete(tks.remove(di))
            lv.remove(di)
            bars.remove(di)
            ages.remove(di)
            tms.remove(di)
            ats.remove(di)
            eqs.remove(di)
            txs.remove(di)

float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)
if not na(ph)
    f_addPool(highs, highsBar, highsAge, highsTm, highsAtr, highsEq, highsTx, highsTk, ph, true)
if not na(pl)
    f_addPool(lows, lowsBar, lowsAge, lowsTm, lowsAtr, lowsEq, lowsTx, lowsTk, pl, false)

// Nearest pool on one side, if it is young enough. It is the last element, and also the
// youngest on its side, so no other pool needs testing.
f_pick(array<float> lv, array<int> bars, array<int> ages, array<int> tms) =>
    float p = na
    int   b = na
    int   t = na
    if lv.size() > 0
        if maxAgeEff == 0 or bar_index - ages.last() <= maxAgeEff
            p := lv.last()
            b := bars.last()
            t := tms.last()
    [p, b, t]

// Pools on one side young enough to be targeted: all of them with no age limit, otherwise
// the tail of the array, as ages never decrease along it
f_cntElig(array<int> ages) =>
    int n = 0
    if ages.size() > 0
        for i = ages.size() - 1 to 0
            if maxAgeEff > 0 and bar_index - ages.get(i) > maxAgeEff
                break
            n += 1
    n

// Pools on one side that two or more swings share
f_cntEq(array<int> eqs) =>
    int n = 0
    if eqs.size() > 0
        for i = 0 to eqs.size() - 1
            if eqs.get(i) > 1
                n += 1
    n

[hiLv, hiBar, hiTm] = f_pick(highs, highsBar, highsAge, highsTm)
[loLv, loBar, loTm] = f_pick(lows,  lowsBar,  lowsAge,  lowsTm)

// ── Structure direction: 0 until the first break, then 1 or -1; changes on bar close only ──
// The ta.* calls stay outside the conditions because Pine needs them run on every bar.
bool  swingMode = sMode == "Swing break"
var int bias = 0
float hh  = ta.highest(high, biasLen)[1]
float ll  = ta.lowest(low, biasLen)[1]
float sph = ta.pivothigh(high, sLen, sLen)
float spl = ta.pivotlow(low, sLen, sLen)
var float sHi = na
var float sLo = na

if barstate.isconfirmed
    if swingMode
        if not na(sph)
            sHi := sph
        if not na(spl)
            sLo := spl
        if close > sHi
            bias := 1
            sHi  := na
        else if close < sLo
            bias := -1
            sLo  := na
    else if close > hh
        bias := 1
    else if close < ll
        bias := -1

bool  up      = bias > 0
color cSide   = up ? colUp : colDn
bool  flipBar = bias != 0 and bias != bias[1]

float pool    = bias > 0 ? hiLv  : bias < 0 ? loLv  : na
int   poolBar = bias > 0 ? hiBar : bias < 0 ? loBar : na
int   poolTm  = bias > 0 ? hiTm  : bias < 0 ? loTm  : na

// ── Sticky target ──────────────────────────────────────────────────────────────
// A target is replaced on three events only: there is none, it was reached, or structure
// flipped away from it. Everything here is settled at the close of a bar, so a mark, tag,
// count or alert appears once and is never withdrawn.
var float  tgt      = na
var int    tgtTm    = na
var int    tgtStart = na
var int    tgtBkt   = na
var string tgtKind  = ""
var int    nHit     = 0
var int    nDrop    = 0
var int    nSweep   = 0
var int    sumBars  = 0
var array<int> nSet   = array.new<int>(NB, 0)
var array<int> nReach = array.new<int>(NB, 0)

bool  hit      = barstate.isconfirmed and tgtIsPool and (tgtBias > 0 ? high > tgt : low < tgt)
bool  hitUp    = hit and tgtBias > 0
bool  hitDn    = hit and tgtBias < 0
// Sweep: traded through the pool and closed back inside it. Break: closed beyond it or on it.
bool  swept    = hit and (tgtBias > 0 ? close < tgt : close > tgt)
bool  brk      = hit and not swept
// Where a reached-pool dot sits: a fifth of an ATR beyond the wick on the target's side
float hitY     = tgtBias > 0 ? high + 0.2 * atr : low - 0.2 * atr
bool  flipped  = tgtIsPool and bias != tgtBias
bool  dropped  = flipped and not hit
bool  retarget = (not tgtIsPool or hit or flipped) and barstate.isconfirmed

// Remember which bar and side each dot is drawn on
f_dotAdd(array<int> a) =>
    a.push(bar_index)
    if a.size() > MAXDOT
        a.shift()

if hit and showHit
    if tgtBias > 0
        f_dotAdd(dotUpB)
    else
        f_dotAdd(dotDnB)

// Each finished target is counted once, in the band it was set in
if hit or dropped
    if not na(tgtBkt)
        nSet.set(tgtBkt, nSet.get(tgtBkt) + 1)
        if hit
            nReach.set(tgtBkt, nReach.get(tgtBkt) + 1)
    if hit
        nHit    += 1
        sumBars += bar_index - tgtStart
        if swept
            nSweep += 1
    else
        nDrop += 1

// ── Prior targets ──────────────────────────────────────────────────────────────
// A target dropped at a structure flip keeps a dashed level from its own candle until price trades through it,
// then the level stops at that bar and stays as a record. One record per pool.
var array<line>  prLn  = array.new<line>()
var array<label> prTx  = array.new<label>()
var array<float> prLv  = array.new<float>()
var array<bool>  prUp  = array.new<bool>()
var array<bool>  prOn  = array.new<bool>()
var array<int>   prBar = array.new<int>()

// Whether the pool made at this bar on this side already has a prior target level
f_prHas(int pb, bool isUp) =>
    bool r = false
    if prBar.size() > 0
        for i = prBar.size() - 1 to 0
            if prBar.get(i) == pb and prUp.get(i) == isUp
                r := true
                break
    r

if prLn.size() > 0
    for i = 0 to prLn.size() - 1
        if prOn.get(i)
            if prUp.get(i) ? high > prLv.get(i) : low < prLv.get(i)
                prOn.set(i, false)
                prLn.get(i).set_x2(time)
            else if barstate.islast
                prLn.get(i).set_x2(time + 6 * tfMs)

if showPrior and dropped
    bool wasUp = tgtBias > 0
    // A pool dropped for a second time already has its level
    if not f_prHas(tgtBar, wasUp)
        prLn.push(line.new(tgtTm, tgt, barstate.islast ? time + 6 * tfMs : time, tgt, xloc = xloc.bar_time, style = line.style_dashed, color = color.new(chart.fg_color, 30), width = 1))
        // Text ends on the bar the target was dropped, on the far side of the level from price.
        // That keeps it clear of the pool's own tag, which sits back on the pool's candle.
        prTx.push(label.new(time, tgt, "prior target", xloc = xloc.bar_time, style = wasUp ? label.style_label_lower_right : label.style_label_upper_right, color = color(na), textcolor = f_txt(chart.bg_color), size = priorSize, text_formatting = text.format_bold))
        prLv.push(tgt)
        prUp.push(wasUp)
        prOn.push(true)
        prBar.push(tgtBar)
        if prLn.size() > maxPrior
            line.delete(prLn.shift())
            label.delete(prTx.shift())
            prLv.shift()
            prUp.shift()
            prOn.shift()
            prBar.shift()

// ── New target, its tag and its live level ─────────────────────────────────────
var line  lvl = na
var label tag = na
var array<label> tagLb = array.new<label>()

if retarget
    tgtIsPool := not na(pool)
    tgt       := pool
    tgtBar    := poolBar
    tgtTm     := poolTm
    tgtStart  := bar_index
    tgtBias   := bias
    tgtBkt    := tgtIsPool and atr > 0 ? math.min(NB - 1, int(math.abs(tgt - close) / atr)) : na
    line.delete(lvl)
    lvl := na
    if tgtIsPool
        // The new target is the nearest pool on its side: the last element of that side's arrays
        array<string> txs = highsTx
        array<float>  ats = highsAtr
        array<int>    eqs = highsEq
        if not up
            txs := lowsTx
            ats := lowsAtr
            eqs := lowsEq
        // A pool is named once, the first time it is the target. Its tag is written then, back on
        // the candle that made it, a quarter of the pool's ATR beyond the wick tip. If that candle
        // also carries a dot on the same side, the tag sits further out, clear of the dot.
        if txs.last() == ""
            txs.set(txs.size() - 1, eqs.last() > 1 ? (up ? "EQH" : "EQL") : (up ? "BSL" : "SSL"))
            if showPool and ats.last() > 0
                bool  hasDot = up ? dotUpB.includes(tgtBar) : dotDnB.includes(tgtBar)
                float tagOff = (hasDot ? 0.6 : 0.25) * ats.last()
                tagLb.push(label.new(tgtTm, up ? tgt + tagOff : tgt - tagOff, txs.last(), xloc = xloc.bar_time, style = up ? label.style_label_down : label.style_label_up, color = cSide, textcolor = f_txt(cSide), size = poolSize))
                if tagLb.size() > MAXTAG
                    label.delete(tagLb.shift())
        tgtKind := txs.last()
        // A pool that already has a prior target level keeps that dashed level instead
        if showLvl and not f_prHas(tgtBar, up)
            lvl := line.new(tgtTm, tgt, time, tgt, xloc = xloc.bar_time, style = line.style_dotted, color = color.new(cSide, 30), width = 1)

float dist = tgtIsPool and atr > 0 ? math.abs(tgt - close) / atr : na

// ── Arc ────────────────────────────────────────────────────────────────────────
// Short average of close: the shading's inner edge
float avg  = ta.ema(close, avgLen)
// With no pool on the structure side the arc follows the extreme still forming, in grey.
// That extreme is never treated as a pool: no tag, level, dot, alert or count.
float fmHi = ta.highest(high, pivLen * 4)
float fmLo = ta.lowest(low, pivLen * 4)
bool  prov = showProv and bias != 0 and not tgtIsPool
float aim  = tgtIsPool ? tgt : prov ? (up ? fmHi : fmLo) : na

var float tgtS   = na
var int   flipAt = na
var float rawY   = na
float lineP = na

if flipBar
    flipAt := bar_index

if showArc and not na(aim) and not na(avg)
    float kEase  = 2.0 / (smLen + 1)
    // The candle's extreme on the target side: price cannot pass the line
    float ref    = up ? high : low
    // The level the lead aims at is eased, so a change of target does not step the line
    tgtS := na(tgtS) or flipBar ? aim : tgtS + (aim - tgtS) * 0.5
    // The lead builds from nothing at a flip to its full size over the arc length
    float ramp   = math.min(1.0, (bar_index - flipAt) / (smLen * 1.0))
    float lead   = leadPct / 100.0 * ramp
    float floorY = ref + lead * (tgtS - ref)
    // Eased toward the aim, then held at the lead and at the candle's extreme. On a flip bar the
    // lead is zero, so the arc starts from that extreme.
    rawY := na(rawY) or flipBar ? avg : rawY + (aim - rawY) * kEase
    rawY := up ? math.max(rawY, floorY, ref) : math.min(rawY, floorY, ref)
    // Also held at the short average so the shading never inverts; left off the flip bar
    if not flipBar
        lineP := up ? math.max(rawY, avg) : math.min(rawY, avg)
else
    tgtS := na
    rawY := na

// Shading: 22 flat, faint fills from the line to i / 22 of the way to the price average,
// curved by a power so they bunch at the line. plot() cannot run in a loop, so they are listed.
f_lay(int i) =>
    lineP + (avg - lineP) * math.pow(i / 22.0, 1.3)

// The side's colour while a pool is the target, grey while the forming extreme is followed.
// No colour on a bar with no line: TradingView would otherwise paint a one-bar strip in the
// new side's colour on the bar where structure flips.
bool  noLine = na(lineP)
color cArc   = tgtIsPool ? cSide : COL_FORM
color cLine  = noLine ? color(na) : cArc
color cGlow  = noLine ? color(na) : color.new(cArc, 80)
color cLay   = noLine ? color(na) : color.new(cArc, layerT)

barcolor(colBars and (tgtIsPool or prov) ? cSide : na, title = "Candle colour", editable = false)

plot(lineP, "Line glow", cGlow, lineW + 4, plot.style_linebr, editable = false, display = display.pane)
pLine = plot(lineP, "Target line", cLine, lineW, plot.style_linebr, editable = false)
p1  = plot(f_lay(1),  "Layer 1",  color(na), editable = false, display = display.pane)
p2  = plot(f_lay(2),  "Layer 2",  color(na), editable = false, display = display.pane)
p3  = plot(f_lay(3),  "Layer 3",  color(na), editable = false, display = display.pane)
p4  = plot(f_lay(4),  "Layer 4",  color(na), editable = false, display = display.pane)
p5  = plot(f_lay(5),  "Layer 5",  color(na), editable = false, display = display.pane)
p6  = plot(f_lay(6),  "Layer 6",  color(na), editable = false, display = display.pane)
p7  = plot(f_lay(7),  "Layer 7",  color(na), editable = false, display = display.pane)
p8  = plot(f_lay(8),  "Layer 8",  color(na), editable = false, display = display.pane)
p9  = plot(f_lay(9),  "Layer 9",  color(na), editable = false, display = display.pane)
p10 = plot(f_lay(10), "Layer 10", color(na), editable = false, display = display.pane)
p11 = plot(f_lay(11), "Layer 11", color(na), editable = false, display = display.pane)
p12 = plot(f_lay(12), "Layer 12", color(na), editable = false, display = display.pane)
p13 = plot(f_lay(13), "Layer 13", color(na), editable = false, display = display.pane)
p14 = plot(f_lay(14), "Layer 14", color(na), editable = false, display = display.pane)
p15 = plot(f_lay(15), "Layer 15", color(na), editable = false, display = display.pane)
p16 = plot(f_lay(16), "Layer 16", color(na), editable = false, display = display.pane)
p17 = plot(f_lay(17), "Layer 17", color(na), editable = false, display = display.pane)
p18 = plot(f_lay(18), "Layer 18", color(na), editable = false, display = display.pane)
p19 = plot(f_lay(19), "Layer 19", color(na), editable = false, display = display.pane)
p20 = plot(f_lay(20), "Layer 20", color(na), editable = false, display = display.pane)
p21 = plot(f_lay(21), "Layer 21", color(na), editable = false, display = display.pane)
p22 = plot(f_lay(22), "Layer 22", color(na), editable = false, display = display.pane)
fill(pLine, p1,  cLay, "Shade 1",  editable = false)
fill(pLine, p2,  cLay, "Shade 2",  editable = false)
fill(pLine, p3,  cLay, "Shade 3",  editable = false)
fill(pLine, p4,  cLay, "Shade 4",  editable = false)
fill(pLine, p5,  cLay, "Shade 5",  editable = false)
fill(pLine, p6,  cLay, "Shade 6",  editable = false)
fill(pLine, p7,  cLay, "Shade 7",  editable = false)
fill(pLine, p8,  cLay, "Shade 8",  editable = false)
fill(pLine, p9,  cLay, "Shade 9",  editable = false)
fill(pLine, p10, cLay, "Shade 10", editable = false)
fill(pLine, p11, cLay, "Shade 11", editable = false)
fill(pLine, p12, cLay, "Shade 12", editable = false)
fill(pLine, p13, cLay, "Shade 13", editable = false)
fill(pLine, p14, cLay, "Shade 14", editable = false)
fill(pLine, p15, cLay, "Shade 15", editable = false)
fill(pLine, p16, cLay, "Shade 16", editable = false)
fill(pLine, p17, cLay, "Shade 17", editable = false)
fill(pLine, p18, cLay, "Shade 18", editable = false)
fill(pLine, p19, cLay, "Shade 19", editable = false)
fill(pLine, p20, cLay, "Shade 20", editable = false)
fill(pLine, p21, cLay, "Shade 21", editable = false)
fill(pLine, p22, cLay, "Shade 22", editable = false)

// Reached target pool: a dot beyond the wick of the bar that reached it. Kept off the price
// scale and status line, as its value is a position, not a price level.
plot(showHit and swept ? hitY : na, "Sweep dot", cSweep,         4, plot.style_circles, editable = false, display = display.pane)
plot(showHit and brk   ? hitY : na, "Break dot", chart.fg_color, 4, plot.style_circles, editable = false, display = display.pane)

plotshape(showFlip and flipBar and up,     "Structure flipped up",   shape.triangleup,   location.belowbar, colUp, size = size.tiny, editable = false)
plotshape(showFlip and flipBar and not up, "Structure flipped down", shape.triangledown, location.abovebar, colDn, size = size.tiny, editable = false)

// ── Right edge: live level and price tag ───────────────────────────────────────
if barstate.islast
    if not na(lvl)
        lvl.set_x2(time + 6 * tfMs)
    if showTag and tgtIsPool
        string ptxt = str.tostring(tgt, format.mintick)
        if na(tag)
            tag := label.new(time + 6 * tfMs, tgt, ptxt, xloc = xloc.bar_time, style = label.style_label_left, color = cSide, textcolor = f_txt(cSide), size = size.small)
        else
            tag.set_xy(time + 6 * tfMs, tgt)
            tag.set_text(ptxt)
            tag.set_color(cSide)
            tag.set_textcolor(f_txt(cSide))
    else
        label.delete(tag)
        tag := na

// ── Panel ──────────────────────────────────────────────────────────────────────
var table tbl = na
if na(tbl) and showTbl
    string pos = tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom left" ? position.bottom_left : position.top_right
    tbl := table.new(pos, 2, 16 + (eqTol > 0 ? 1 : 0) + (chart.is_standard ? 0 : 1), bgcolor = color.new(chart.bg_color, 10), border_width = 1, border_color = color.new(chart.fg_color, 85))

f_row(int r, string k, string v, color vc) =>
    tbl.cell(0, r, k, text_color = color.new(chart.fg_color, 30), text_halign = text.align_left,  text_size = size.small)
    tbl.cell(1, r, v, text_color = vc,                            text_halign = text.align_right, text_size = size.small)

// Reach rate of the finished targets set in one band
f_ladder(int r, int b, string name) =>
    int    n = nSet.get(b)
    string v = n > 0 ? str.tostring(100.0 * nReach.get(b) / n, "0") + "% reached  (n=" + str.tostring(n, "0") + ")" : "—"
    f_row(r, name, v, chart.fg_color)

if barstate.islast and showTbl
    color  fg    = chart.fg_color
    int    res   = nHit + nDrop
    bool   aged  = maxAgeEff > 0
    string modeT = swingMode ? "swing-break " + str.tostring(sLen, "0") : "range " + str.tostring(biasLen, "0")
    string eqT   = eqTol > 0 ? "eq " + str.tostring(eqTol, "0.00") : "eq off"
    string leadT = leadPct > 0 ? "lead " + str.tostring(leadPct, "0") + "%" : "lead off"
    string hdr   = str.format("sw {0} · {1} · {2} · arc {3} · {4}", pivLen, eqT, modeT, smLen, leadT)
    string tgtT  = tgtIsPool ? tgtKind + " " + str.tostring(tgt, format.mintick) : bias == 0 ? "—" : prov ? "No pool · forming " + (up ? "high " : "low ") + str.tostring(aim, format.mintick) : "No pool"
    // Before the first structure break there is no side, so the header plate stays neutral
    color  plate = bias == 0 ? color.new(fg, 70) : cSide
    color  ptext = bias == 0 ? fg : f_txt(cSide)
    int r = 0
    tbl.cell(0, r, "Dynamic Liquidity Draw", text_color = ptext, bgcolor = plate, text_halign = text.align_left,  text_size = size.small)
    tbl.cell(1, r, hdr,                      text_color = ptext, bgcolor = plate, text_halign = text.align_right, text_size = size.small)
    r += 1
    if not chart.is_standard
        f_row(r, "Non-standard chart", "synthetic prices; levels and rates differ", fg)
        r += 1
    f_row(r, "Structure", bias == 0 ? "—" : up ? "Up" : "Down", fg)
    r += 1
    f_row(r, "Target", tgtT, fg)
    r += 1
    f_row(r, "Distance", na(dist) ? "—" : str.tostring(dist, "0.0") + " ATR", fg)
    r += 1
    // With an age limit the count of pools inside it is shown beside the count tracked
    f_row(r, aged ? "Pools above · in age limit / tracked" : "Pools above", (aged ? str.tostring(f_cntElig(highsAge), "0") + " / " : "") + str.tostring(highs.size(), "0"), fg)
    r += 1
    f_row(r, aged ? "Pools below · in age limit / tracked" : "Pools below", (aged ? str.tostring(f_cntElig(lowsAge), "0") + " / " : "") + str.tostring(lows.size(), "0"), fg)
    r += 1
    if eqTol > 0
        f_row(r, "Equal pools above / below", str.tostring(f_cntEq(highsEq), "0") + " / " + str.tostring(f_cntEq(lowsEq), "0"), fg)
        r += 1
    f_row(r, "Targets reached / dropped", str.tostring(nHit, "0") + " / " + str.tostring(nDrop, "0") + (res > 0 ? "  (" + str.tostring(100.0 * nHit / res, "0") + "% reached)" : ""), fg)
    r += 1
    f_row(r, "Targets swept / broke", str.tostring(nSweep, "0") + " / " + str.tostring(nHit - nSweep, "0") + (nHit > 0 ? "  (" + str.tostring(100.0 * nSweep / nHit, "0") + "% swept)" : ""), fg)
    r += 1
    f_row(r, "Avg bars to reach (from when set)", nHit > 0 ? str.tostring(sumBars / nHit, "0.0") : "—", fg)
    r += 1
    f_ladder(r, 0, "Set 0–1 ATR away")
    r += 1
    f_ladder(r, 1, "Set 1–2 ATR away")
    r += 1
    f_ladder(r, 2, "Set 2–3 ATR away")
    r += 1
    f_ladder(r, 3, "Set 3–4 ATR away")
    r += 1
    f_ladder(r, 4, "Set 4+ ATR away")
    r += 1
    f_row(r, "Stats cover", "loaded history · " + str.tostring(bar_index + 1, "0") + " bars · not a backtest", color.new(fg, 30))
    r += 1
    f_row(r, "Last bar open · " + syminfo.timezone, str.format_time(time, "yyyy-MM-dd HH:mm", syminfo.timezone), color.new(fg, 30))

// ── Alerts: every condition is settled at the close of a bar ───────────────────
alertcondition(hitUp,   "Pool reached above", "Dynamic Liquidity Draw: the target pool above was reached")
alertcondition(hitDn,   "Pool reached below", "Dynamic Liquidity Draw: the target pool below was reached")
alertcondition(swept,   "Pool swept",         "Dynamic Liquidity Draw: the target pool was swept, price closed back inside it")
alertcondition(brk,     "Pool broken",        "Dynamic Liquidity Draw: the target pool was broken, price closed beyond it or exactly on it")
alertcondition(dropped, "Target dropped",     "Dynamic Liquidity Draw: structure flipped before the target pool was reached")
````
