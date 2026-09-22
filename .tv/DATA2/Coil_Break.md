<!-- tradingview-pine-id: PUB;25914258d6c241dd8c98ed7c6fc8f714 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Coil & Break

Source: https://www.tradingview.com/script/rBspQX3H-Coil-Break/

## Description

Coil & Break: Inside Bar, Bull Flag & Range

## What it does

Three bullish patterns share one idea: price pauses, coils, and then expands.
This script finds all three, marks them **while they are still forming**, and
grades the breakout when it happens.

It is a setup finder, not a trading system. It does not place stops, project
targets, or tell you when to exit. Those decisions depend on an environment the
chart cannot see.

Long only, by design.

## The three patterns

**Inside bar** — a bar whose whole range sits inside the previous bar's range.
Three definitions are selectable: the classic range-in-range, body-in-body (a
harami), and range-in-body, which is the tightest and rarest of the three.

**Bull flag** — an impulsive rise, then a shallow pause. The pole must clear a
minimum size in ATR or percent; the flag must not retrace more than a set share
of it, must resolve inside a bar window, and, optionally, must show volume
drying up while it rests. That last one is the honest tell of a flag: not a
wave of sellers, just an absence of buying.

**Tight range** — a quiet box with no flagpole behind it. Measured as the height
of a rolling window against ATR or a percentage. This is the pattern the flag
logic structurally cannot see, because a flag refuses to exist without a
preceding impulse.

## Grading: the part that matters

Every breakout is graded by how many **independent** factors back it:

- **Trend** — where price sits in the bigger picture
- **Momentum** — MACD above zero
- **Volume** — participation above its average
- **Pressure** — the breakout bar closing in the upper part of its own range

Each vote comes from a different kind of evidence. That is deliberate. Two
moving-average crossovers agreeing is not two confirmations — it is one
measurement read twice. That is why there is no MA-cross signal in this script,
only the grade it feeds.

- **A** — every available vote agreed
- **B** — all but one
- **C** — weaker (hidden by default)

The grade is relative to what is *knowable*. A vote you switch off drops out of
the maximum. So does one that cannot be measured yet: on an unfinished daily
bar, volume is a fraction of a session being compared against whole sessions, so
the volume vote leaves the calculation entirely and rejoins at the close. A
setup is never marked down for a reason you could not have known at the time.

## Reading the chart

- **Light blue bars** — a setup is armed here, waiting
- **Amber line** — the price it has to clear. It sits still; it does not crawl
- **A / B / C icon** — the setup triggered, graded

That is the whole visual vocabulary. Three things.

## Repainting

With **Trigger on closed bars only** enabled — the default — signals are fixed
once a bar closes and history is honest.

Turn it off and icons appear the moment price clears the level, and can vanish
if price falls back before the close. That is not a bug; it is the correct
setting if you execute intraday and need to see the break as it happens rather
than hours later. Know which mode you are in.

## Settings worth knowing

- **Trend MA** (default 200) gates everything. A setup against the trend is
  never actionable in a long-only method, so it is filtered rather than graded.
- **Volume while the bar is still open** decides how partial volume is treated.
- **Show which grades** hides C by default. Set it to Everything while you are
  studying what the script rejects.
- Every pattern can be disabled independently.

## Honest limitations

Patterns are recognised by numbers; your eye recognises them by shape. The two
overlap, but not perfectly. The script will flag consolidations that do not look
like textbook examples, and it will miss ones you can see clearly, usually
because a threshold was missed by a hair. The parameters exist so you can pull
the numbers closer to your own eye — expect to spend time on that rather than
trusting the defaults.

Grading measures agreement among indicators. Agreement is not edge. Nothing here
has been backtested for you.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════
//  COIL & BREAK — inside bar, bull flag, tight range
//  Three ways price coils before it expands, graded on how much
//  independent evidence backs the break.
//  Long only. Finds setups; does not manage trades.
//
//  How to read the chart:
//    light blue bar = a setup is armed here, waiting
//    amber line     = the price it has to clear
//    A / B / C icon = the setup triggered, graded by how many
//                     independent factors agreed
//
//  Grading counts votes from sources that measure DIFFERENT
//  things — trend, momentum, volume, pressure. Two moving-average
//  crosses agreeing is one measurement read twice, not two votes.
//  That is why there is no EMA-cross signal in here.
//
//  No stops, no targets. Where risk sits and when to take profit
//  depend on an environment the chart cannot see.
// ═══════════════════════════════════════════════════════════
indicator("Coil & Break", overlay = true)

// ═══════════════════════════════════════════════════════════
//  CONTEXT — trend and momentum. No signals of their own.
// ═══════════════════════════════════════════════════════════
gX        = "Context"
trendLen  = input.int(200, "Trend MA length", minval = 1, group = gX)
trendType = input.string("EMA", "Trend MA type", options = ["SMA", "EMA"], group = gX)
reqTrend  = input.bool(true, "Only look for setups above the trend MA", group = gX,
     tooltip = "Long only means a setup against the trend is never actionable.")
confirmed = input.bool(true, "Trigger on closed bars only", group = gX,
     tooltip = "On: honest history, but on a daily chart the icon appears after " +
               "the close. Off: the icon appears the moment price clears the " +
               "level, and can disappear if price falls back before the close. " +
               "Off is the right setting while you are executing at the open.")
macdFast  = input.int(12, "MACD fast", minval = 1, group = gX)
macdSlow  = input.int(26, "MACD slow", minval = 1, group = gX)

f_ma(src, len, t) => t == "SMA" ? ta.sma(src, len) : ta.ema(src, len)

trendMA  = f_ma(close, trendLen, trendType)
macdLine = ta.ema(close, macdFast) - ta.ema(close, macdSlow)
// na(trendMA) means the chart has fewer bars than the MA needs. That
// is missing information, not a failed test — do not block on it.
trendOk  = not reqTrend or na(trendMA) or close > trendMA

// ═══════════════════════════════════════════════════════════
//  VOLUME — one place, used by the flag definition and the vote
// ═══════════════════════════════════════════════════════════
gVol    = "Volume"
volLen  = input.int(20, "Volume average (bars)", minval = 1, group = gVol)
volMult = input.float(1.2, "Above-average multiplier", minval = 0.1, step = 0.1, group = gVol)
volLive = input.string("Ignore it", "Volume while the bar is still open",
     options = ["Ignore it", "Use the volume so far"], group = gVol,
     tooltip = "A daily bar's volume is incomplete until the day closes. Half an " +
               "hour after the open you hold a fraction of a session compared " +
               "against whole sessions — the check fails for a reason that has " +
               "nothing to do with the breakout.\n\n" +
               "Ignore: the volume vote drops out of the grade entirely while the " +
               "bar is live, and rejoins at the close. The grade may change then.")

volAvg   = ta.sma(volume, volLen)
volReady = barstate.isconfirmed or volLive == "Use the volume so far"
volUsable = not na(volume) and volReady

// ═══════════════════════════════════════════════════════════
//  SETUP A — INSIDE BAR
//  A bar that sits inside the previous one: compression before
//  expansion. The tradable event is the breakout after it.
// ═══════════════════════════════════════════════════════════
gI       = "Setup — Inside bar"
useIB    = input.bool(true, "Enable", group = gI)
ibMode   = input.string("Range in range (classic)", "Pattern definition",
     options = ["Range in range (classic)", "Body in body (harami)", "Range in body (strict)"],
     group = gI,
     tooltip = "Range in range: the whole bar, wicks included, inside the previous " +
               "bar's range. The textbook inside bar.\n" +
               "Body in body: bodies only, wicks ignored. A harami — more frequent, " +
               "weaker.\n" +
               "Range in body: the whole bar inside the previous body. Rarest.")
ibStrict = input.bool(false, "Strict (reject equal edges)", group = gI)
ibRef    = input.string("Inside bar high", "Breakout level",
     options = ["Inside bar high", "Mother bar high"], group = gI,
     tooltip = "Mother bar high is the stronger confirmation — the whole " +
               "compression is cleared — but it fires later.")
ibClose  = input.bool(true, "Breakout needs a close above the level", group = gI,
     tooltip = "Off = an intrabar touch is enough.")
ibWin    = input.int(1, "Breakout window (bars after the inside bar)", minval = 1, group = gI,
     tooltip = "1 = the very next bar only, as in the classic setup.")

bodyHi  = math.max(open,    close)
bodyLo  = math.min(open,    close)
pBodyHi = math.max(open[1], close[1])
pBodyLo = math.min(open[1], close[1])

insideBar = switch ibMode
    "Body in body (harami)" =>
        ibStrict ? (bodyHi < pBodyHi and bodyLo > pBodyLo) : (bodyHi <= pBodyHi and bodyLo >= pBodyLo)
    "Range in body (strict)" =>
        ibStrict ? (high < pBodyHi and low > pBodyLo) : (high <= pBodyHi and low >= pBodyLo)
    =>
        ibStrict ? (high < high[1] and low > low[1]) : (high <= high[1] and low >= low[1])

var float ibHigh = na
var float ibMomH = na
var float ibLow  = na
var int   ibBar  = na
var bool  ibDone = false

if insideBar
    ibHigh := high
    ibMomH := high[1]
    ibLow  := low
    ibBar  := bar_index
    ibDone := false

// A close back under the inside bar kills the setup
if not na(ibLow) and close < ibLow
    ibDone := true

ibLevel   = ibRef == "Inside bar high" ? ibHigh : ibMomH
ibAge     = na(ibBar) ? na : bar_index - ibBar
ibAlive   = useIB and not ibDone and not na(ibAge) and ibAge <= ibWin
ibPending = ibAlive
ibBrk     = na(ibLevel) ? false : (ibClose ? close > ibLevel : high > ibLevel)
ibTrigRaw = ibAlive and not insideBar and ibAge >= 1 and ibBrk

// ═══════════════════════════════════════════════════════════
//  SETUP B — BULL FLAG
//  Pole : an impulsive rise inside the lookback window. It keeps
//         extending while price makes new highs, and freezes when
//         price stops.
//  Flag : the pause after it — shallow enough and short enough to
//         still be a pause rather than a reversal.
//  Break: a close above the flag's ceiling.
// ═══════════════════════════════════════════════════════════
gB       = "Setup — Bull flag"
useBF    = input.bool(true, "Enable", group = gB)
poleLen  = input.int(10, "Flagpole lookback (bars)", minval = 2, group = gB)
poleUnit = input.string("ATR", "Pole size measured in", options = ["ATR", "Percent"], group = gB)
poleMinA = input.float(4.0, "Min pole size (× ATR)", minval = 0.5, step = 0.5, group = gB)
poleMinP = input.float(7.0, "Min pole size (%)",     minval = 0.5, step = 0.5, group = gB)
flagMin  = input.int(3,  "Min flag length (bars)", minval = 1, group = gB)
flagMax  = input.int(12, "Max flag length (bars)", minval = 2, group = gB)
maxRetr  = input.float(40, "Max retracement of the pole (%)", minval = 10, maxval = 90,
     step = 5, group = gB,
     tooltip = "Deeper than this and the move is being undone, not paused. " +
               "Kept tight on purpose: a deep, sloppy flag is the single most " +
               "common way this pattern fails.")
bfRefSel = input.string("Pole high (conservative)", "Breakout level",
     options = ["Flag high (aggressive)", "Pole high (conservative)"], group = gB,
     tooltip = "Pole high waits for the whole structure to be cleared. Later " +
               "entry, but it only fires when the move is genuinely continuing. " +
               "Flag high enters on the break of the consolidation's own ceiling, " +
               "which on a deep flag can sit well below the prior high.")
bfClose  = input.bool(true, "Breakout needs a close above the level", group = gB)
bfDry    = input.bool(true, "Volume must dry up during the flag", group = gB,
     tooltip = "The defining tell of a flag: no real sellers, just an absence of " +
               "buying while price rests. Measured on finished bars only, so the " +
               "live bar cannot distort it.")

atr14    = ta.atr(14)
poleLow  = ta.lowest(low, poleLen)
poleUp   = high - poleLow
poleReq  = poleUnit == "ATR" ? atr14 * poleMinA : poleLow * poleMinP / 100
poleOk   = poleUp >= poleReq
newHigh  = high >= ta.highest(high, poleLen)
polePace = ta.sma(volume, poleLen)

var float pHigh    = na
var float pLow     = na
var int   pBar     = na
var float flagLow  = na
var float flagHigh = na
var float poleVol  = na
var float flagVolS = 0.0
var int   flagVolN = 0
var bool  bfDone   = false

// 1. Track the flag's floor; only finished bars feed its volume
if not na(pBar) and bar_index > pBar
    flagLow := na(flagLow) ? low : math.min(flagLow, low)
    if barstate.isconfirmed
        flagVolS := flagVolS + nz(volume)
        flagVolN := flagVolN + 1

// 2. Too deep or too long and it is no longer a flag
retrLimit = na(pHigh) ? na : pHigh - (pHigh - pLow) * maxRetr / 100
flagAge   = na(pBar)  ? na : bar_index - pBar
if not na(flagLow) and not na(retrLimit) and flagLow < retrLimit
    bfDone := true
if not na(flagAge) and flagAge > flagMax
    bfDone := true

// 3. Did volume actually quieten down?
flagVolAvg = flagVolN > 0 ? flagVolS / flagVolN : na
dryReady   = not na(flagVolAvg) and not na(poleVol)
dryOk      = not bfDry or na(volume) or not dryReady or flagVolAvg < poleVol

// 4. Breakout — measured BEFORE the bar is allowed to raise the
//    ceiling it has to clear
bfRef     = bfRefSel == "Flag high (aggressive)" ? nz(flagHigh, pHigh) : pHigh
bfAlive   = useBF and not bfDone and not na(flagAge) and flagAge >= 1 and flagAge <= flagMax
bfPending = bfAlive
bfBrk     = na(bfRef) ? false : (bfClose ? close > bfRef : high > bfRef)
bfTrigRaw = bfAlive and flagAge >= flagMin and bfBrk and dryOk

// 5. Only now does this bar count towards the ceiling
if not na(pBar) and bar_index > pBar
    flagHigh := na(flagHigh) ? high : math.max(flagHigh, high)

// 6. A new qualifying high starts or extends the pole
if poleOk and newHigh
    pHigh    := high
    pLow     := poleLow
    pBar     := bar_index
    poleVol  := polePace
    flagLow  := na
    flagHigh := na
    flagVolS := 0.0
    flagVolN := 0
    bfDone   := false

// ═══════════════════════════════════════════════════════════
//  SETUP C — TIGHT RANGE
//  A quiet box with no flagpole behind it, which is why the flag
//  module cannot see it: that one refuses to wake up without an
//  impulsive rise, expires after 15 bars, and never measures how
//  narrow the range actually is.
//
//  A rolling window decides whether the range is tight; the box
//  then FREEZES its ceiling and floor. Freezing is the point — a
//  rolling highest would lift the ceiling on the very bar that
//  breaks it, so nothing could ever trigger, and the drawn level
//  would crawl upward instead of sitting still.
// ═══════════════════════════════════════════════════════════
gBx      = "Setup — Tight range"
useBox   = input.bool(true, "Enable", group = gBx)
bxWin    = input.int(5, "Tight window (bars)", minval = 2, group = gBx,
     tooltip = "How many bars get measured for tightness. This is also the " +
               "minimum length of the consolidation.")
bxMax    = input.int(10, "Max total length (bars)", minval = 2, group = gBx,
     tooltip = "Once the consolidation is older than this the box expires, and " +
               "it will not re-form until the range widens and tightens again.")
bxUnit   = input.string("ATR", "Tightness measured in", options = ["ATR", "Percent"],
     group = gBx)
bxTightA = input.float(1.5, "Max box height (× ATR)", minval = 0.1, step = 0.1, group = gBx)
bxTightP = input.float(3.0, "Max box height (%)",     minval = 0.1, step = 0.1, group = gBx)
bxClose  = input.bool(true, "Breakout needs a close above the ceiling", group = gBx)
bxNear   = input.bool(false, "Box must sit near the recent high", group = gBx,
     tooltip = "Off by default: the trend filter above the 200 MA already gives " +
               "the bullish context. Turn it on to reject quiet ranges that " +
               "formed after a decline.")
bxNearP  = input.float(3.0, "Near-high tolerance (%)", minval = 0.1, step = 0.5, group = gBx)

winHi = ta.highest(high, bxWin)
winLo = ta.lowest(low,   bxWin)
bxReq = bxUnit == "ATR" ? atr14 * bxTightA : winLo * bxTightP / 100
tight = (winHi - winLo) <= bxReq

nearRef = ta.highest(high, bxMax * 3)
nearOk  = not bxNear or na(nearRef) or winHi >= nearRef * (1 - bxNearP / 100)

var float bxHi   = na
var float bxLo   = na
var int   bxBar  = na
var bool  bxDone = false

// 1. Breakout against the STORED box, before this bar can touch it
bxAge     = na(bxBar) ? na : bar_index - bxBar
bxLive    = useBox and not na(bxHi) and not bxDone
bxBrk     = na(bxHi) ? false : (bxClose ? close > bxHi : high > bxHi)
bxTrigRaw = bxLive and bxBrk

// 2. A close under the floor kills it
if bxLive and close < bxLo
    bxDone := true

// 3. Too long and this is no longer a fresh consolidation
bxTotal = na(bxAge) ? na : bxAge + bxWin
if not na(bxTotal) and bxTotal > bxMax
    bxDone := true

// 4. Form a box only on a FRESHLY tight window. Without the freshness
//    test an expired box would re-form on the next bar out of the same
//    still-tight window, and the max length would mean nothing.
freshTight = tight and not tight[1]
if freshTight and nearOk and (na(bxHi) or bxDone)
    bxHi   := winHi
    bxLo   := winLo
    bxBar  := bar_index
    bxDone := false

boxPending = useBox and not na(bxHi) and not bxDone

// ═══════════════════════════════════════════════════════════
//  GRADING — how many independent factors back this breakout
//
//  Each vote comes from a different kind of evidence. A vote you
//  switch off, or one that cannot be measured yet, drops out of
//  the maximum too — so the grade is always relative to what is
//  actually knowable at this moment.
//
//    A  every available vote agreed          (two aces)
//    B  all but one                          (two queens)
//    C  anything weaker
// ═══════════════════════════════════════════════════════════
gQ       = "Grading"
qTrend   = input.bool(true, "Vote: price above the trend MA", group = gQ)
qMom     = input.bool(true, "Vote: MACD above zero",          group = gQ)
qVol     = input.bool(true, "Vote: above-average volume",     group = gQ)
qPress   = input.bool(true, "Vote: bar closes in its upper part", group = gQ)
qPressP  = input.float(60, "Strong close (% of bar range)", minval = 0, maxval = 100,
     step = 5, group = gQ)
minGrade = input.string("B and better", "Show which grades",
     options = ["A only", "B and better", "Everything"], group = gQ)

barRange = high - low
closePos = barRange > 0 ? (close - low) / barRange * 100 : 100.0
qVolAvail = qVol and volUsable

qT = qTrend    and close > trendMA
qM = qMom      and macdLine > 0
qV = qVolAvail and volume > volAvg * volMult
qP = qPress    and closePos >= qPressP

qMax   = (qTrend ? 1 : 0) + (qMom ? 1 : 0) + (qVolAvail ? 1 : 0) + (qPress ? 1 : 0)
qScore = (qT ? 1 : 0) + (qM ? 1 : 0) + (qV ? 1 : 0) + (qP ? 1 : 0)

isA = qScore >= qMax
isB = not isA and qScore >= qMax - 1
isC = not isA and not isB

showA = true
showB = minGrade != "A only"
showC = minGrade == "Everything"

// ═══════════════════════════════════════════════════════════
//  TRIGGERS
// ═══════════════════════════════════════════════════════════
ibTrig = ibTrigRaw and trendOk
bfTrig = bfTrigRaw and trendOk
bxTrig = bxTrigRaw and trendOk

ibTrig := confirmed ? ibTrig and barstate.isconfirmed : ibTrig
bfTrig := confirmed ? bfTrig and barstate.isconfirmed : bfTrig
bxTrig := confirmed ? bxTrig and barstate.isconfirmed : bxTrig

// One trigger per setup
if ibTrig
    ibDone := true
if bfTrig
    bfDone := true
if bxTrig
    bxDone := true

triggered = ibTrig or bfTrig or bxTrig
anyArmed  = ibPending or bfPending or boxPending
armed     = anyArmed and trendOk and not triggered

// The level an armed setup has to clear. Gated by `armed` so the line
// and the tint always appear together — one without the other is just
// confusing. Priority runs longest structure first: an inside bar's
// level usually sits inside a box anyway.
rawLvl  = bfPending ? bfRef : boxPending ? bxHi : ibPending ? ibLevel : na
pendLvl = armed ? rawLvl : na

// ═══════════════════════════════════════════════════════════
//  PLOTTING
//  Colors and icons live in the Style tab. text and size have to
//  be compile-time constants, so they are edited here.
// ═══════════════════════════════════════════════════════════
gV       = "Appearance"
showTint = input.bool(true, "Tint bars where a setup is armed", group = gV)
showPend = input.bool(true, "Draw the pending breakout level",  group = gV)

txtCol = chart.fg_color

barcolor(showTint and armed ? #81d4fa : na, title = "Armed setup")

plotshape(triggered and isA and showA, title = "Grade A",
     style = shape.labelup, location = location.belowbar,
     color = #00c853, textcolor = txtCol, text = "A", size = size.small,
     display = display.pane)

plotshape(triggered and isB and showB, title = "Grade B",
     style = shape.triangleup, location = location.belowbar,
     color = #ffab00, textcolor = txtCol, text = "B", size = size.small,
     display = display.pane)

plotshape(triggered and isC and showC, title = "Grade C",
     style = shape.circle, location = location.belowbar,
     color = #90a4ae, textcolor = txtCol, text = "C", size = size.tiny,
     display = display.pane)

plot(showPend and not na(pendLvl) ? pendLvl : na, "Pending breakout",
     color = #ffab00, style = plot.style_linebr, linewidth = 1)

plot(qScore, "Votes earned",   display = display.data_window)
plot(qMax,   "Votes possible", display = display.data_window)

// ═══════════════════════════════════════════════════════════
//  MEASUREMENT
//
//  Scores the signal, not the trade. Every trigger is followed
//  forward for a fixed number of bars and asked one question:
//  how far did it run, in R, before it fell a full R against you?
//
//  R uses the trader's own rule — entry minus the previous bar's
//  low — so the milestones read as real partial-profit levels
//  rather than abstractions. No exit logic is involved, which is
//  the point: a good signal managed badly would otherwise score
//  as a bad signal.
//
//  Only RESOLVED observations are counted. One still open at the
//  right edge has not had its chance to fail yet, and counting it
//  would tilt every recent reading optimistic.
// ═══════════════════════════════════════════════════════════
gS        = "Measurement"
showStats = input.bool(true, "Show the results table", group = gS,
     tooltip = "On by default so the numbers are in front of you rather than " +
               "hidden behind a setting. Turn it off once you are done tuning " +
               "and want a clean chart.")
statHor   = input.int(20, "Observation horizon (bars)", minval = 1, group = gS,
     tooltip = "How long a signal is followed before it is closed out as " +
               "unresolved. Should cover your typical holding period.")
statRef   = input.string("Previous bar low", "R measured from",
     options = ["Previous bar low", "ATR(14)"], group = gS,
     tooltip = "Previous bar low mirrors how you actually place a stop. Switch " +
               "to ATR where the prior low sits unusably close to the entry.")
statAtrM  = input.float(1.0, "ATR multiple for R", minval = 0.1, step = 0.1, group = gS)
statPos   = input.string("Bottom left", "Table position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = gS)
statRows  = input.string("Grades and patterns", "Rows",
     options = ["Grades and patterns", "Grades only", "Patterns only"], group = gS)
rModel    = input.string("Partial scale-out", "How total R is booked",
     options = ["Partial scale-out", "Best excursion"], group = gS,
     tooltip = "Partial scale-out models how you actually trade: a third of the " +
               "position leaves at 1.5R, a third at 2.5R, a third at 4R. A tranche " +
               "whose level was never reached books the stop, or the price at the " +
               "end of the horizon if the stop never came.\n\n" +
               "Best excursion books -1R for a stopped trade and the furthest R it " +
               "reached otherwise. That assumes you sold the exact high, so read it " +
               "as a ceiling, not as profit.")

// Open observations, tracked in parallel arrays
var array<float> obsEntry = array.new<float>()
var array<float> obsR     = array.new<float>()
var array<int>   obsGrade = array.new<int>()
var array<int>   obsPat   = array.new<int>()
var array<int>   obsAge   = array.new<int>()
var array<float> obsBest  = array.new<float>()

// Buckets 0-2 = grades A/B/C, 3-5 = patterns IB/FLAG/BOX
var array<int>   cN    = array.new<int>(6, 0)
var array<int>   cStop = array.new<int>(6, 0)
var array<int>   c15   = array.new<int>(6, 0)
var array<int>   c25   = array.new<int>(6, 0)
var array<int>   c40   = array.new<int>(6, 0)
var array<float> cBest = array.new<float>(6, 0.0)
var array<float> cTotR = array.new<float>(6, 0.0)

// The milestone columns overlap: a trade can touch 4R and later stop
// out, so it lands in both. Summing them would double-count. Booking
// the position in three tranches resolves that honestly — a tranche
// that reached its level is paid, whatever the trade did afterwards.
f_tally(idx, best, stopped, endR) =>
    array.set(cN,    idx, array.get(cN,    idx) + 1)
    array.set(cBest, idx, array.get(cBest, idx) + best)
    if stopped
        array.set(cStop, idx, array.get(cStop, idx) + 1)
    if best >= 1.5
        array.set(c15, idx, array.get(c15, idx) + 1)
    if best >= 2.5
        array.set(c25, idx, array.get(c25, idx) + 1)
    if best >= 4.0
        array.set(c40, idx, array.get(c40, idx) + 1)
    // An unreached tranche books the stop, or the price at the end of
    // the horizon when the stop never came
    unmet = stopped ? -1.0 : endR
    t1 = best >= 1.5 ? 1.5 : unmet
    t2 = best >= 2.5 ? 2.5 : unmet
    t3 = best >= 4.0 ? 4.0 : unmet
    partial = (t1 + t2 + t3) / 3
    ceiling = stopped ? -1.0 : best
    booked  = rModel == "Partial scale-out" ? partial : ceiling
    array.set(cTotR, idx, array.get(cTotR, idx) + booked)

f_pct(part, total) => total > 0 ? str.tostring(math.round(part / total * 100)) + "%" : "—"
f_avg(sum,  total) => total > 0 ? str.tostring(sum / total, "#.0") + "R" : "—"

// Age every open observation, then resolve the ones that are done.
// Backwards, because removing during a forward walk skips entries.
if array.size(obsEntry) > 0
    for i = array.size(obsEntry) - 1 to 0
        e    = array.get(obsEntry, i)
        r    = array.get(obsR,     i)
        age  = array.get(obsAge,   i) + 1
        best = math.max(array.get(obsBest, i), (high - e) / r)
        array.set(obsAge,  i, age)
        array.set(obsBest, i, best)
        // A bar that touches both the milestone and the stop is
        // ambiguous — the tape order is unknowable from a bar.
        stopped = low <= e - r
        if stopped or age >= statHor
            endR = (close - e) / r
            f_tally(array.get(obsGrade, i), best, stopped, endR)
            f_tally(array.get(obsPat,   i), best, stopped, endR)
            array.remove(obsEntry, i)
            array.remove(obsR,     i)
            array.remove(obsGrade, i)
            array.remove(obsPat,   i)
            array.remove(obsAge,   i)
            array.remove(obsBest,  i)

// Open a new observation. After the loop above, so the entry bar's
// own high does not count — the entry happened at its close.
if triggered
    rDist = statRef == "ATR(14)" ? atr14 * statAtrM : close - low[1]
    // A breakout closing below the prior low makes R meaningless and
    // would divide by zero or worse, poison every average downstream.
    if rDist > 0
        gIdx = isA ? 0 : isB ? 1 : 2
        pIdx = bfTrig ? 4 : bxTrig ? 5 : 3
        array.push(obsEntry, close)
        array.push(obsR,     rDist)
        array.push(obsGrade, gIdx)
        array.push(obsPat,   pIdx)
        array.push(obsAge,   0)
        array.push(obsBest,  0.0)

statCorner = switch statPos
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_right

var table stats = table.new(statCorner, 9, 7,
     border_width = 1, border_color = color.new(color.gray, 70))

f_signed(v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.0") + "R"

f_statRow(t, row, label, idx) =>
    n    = array.get(cN, idx)
    totR = array.get(cTotR, idx)
    perR = n > 0 ? totR / n : 0.0
    bg   = color.new(color.black, 25)
    posC = #a5d6a7
    negC = #ef9a9a
    table.cell(t, 0, row, label, text_color = txtCol, bgcolor = bg,
         text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, row, str.tostring(n), text_color = txtCol, bgcolor = bg,
         text_size = size.small, text_halign = text.align_right)
    table.cell(t, 2, row, f_pct(array.get(cStop, idx), n), text_color = negC,
         bgcolor = bg, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 3, row, f_pct(array.get(c15, idx), n), text_color = txtCol,
         bgcolor = bg, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 4, row, f_pct(array.get(c25, idx), n), text_color = txtCol,
         bgcolor = bg, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 5, row, f_pct(array.get(c40, idx), n), text_color = txtCol,
         bgcolor = bg, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 6, row, f_avg(array.get(cBest, idx), n), text_color = txtCol,
         bgcolor = bg, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 7, row, n > 0 ? f_signed(totR) : "—",
         text_color = totR >= 0 ? posC : negC,
         bgcolor = bg, text_size = size.small, text_halign = text.align_right)
    table.cell(t, 8, row, n > 0 ? f_signed(perR) : "—",
         text_color = perR >= 0 ? posC : negC,
         bgcolor = bg, text_size = size.small, text_halign = text.align_right)

if showStats and barstate.islast
    hb = color.new(color.black, 10)
    table.cell(stats, 0, 0, "",         text_color = txtCol, bgcolor = hb, text_size = size.small)
    table.cell(stats, 1, 0, "n",        text_color = txtCol, bgcolor = hb, text_size = size.small)
    table.cell(stats, 2, 0, "stop",     text_color = txtCol, bgcolor = hb, text_size = size.small)
    table.cell(stats, 3, 0, "1.5R",     text_color = txtCol, bgcolor = hb, text_size = size.small)
    table.cell(stats, 4, 0, "2.5R",     text_color = txtCol, bgcolor = hb, text_size = size.small)
    table.cell(stats, 5, 0, "4R",       text_color = txtCol, bgcolor = hb, text_size = size.small)
    table.cell(stats, 6, 0, "avg best", text_color = txtCol, bgcolor = hb, text_size = size.small)
    table.cell(stats, 7, 0, "total R",  text_color = txtCol, bgcolor = hb, text_size = size.small)
    table.cell(stats, 8, 0, "R/trade",  text_color = txtCol, bgcolor = hb, text_size = size.small)

    int r = 1
    if statRows != "Patterns only"
        f_statRow(stats, r,     "A", 0)
        f_statRow(stats, r + 1, "B", 1)
        f_statRow(stats, r + 2, "C", 2)
        r := r + 3
    if statRows != "Grades only"
        f_statRow(stats, r,     "IB",   3)
        f_statRow(stats, r + 1, "FLAG", 4)
        f_statRow(stats, r + 2, "BOX",  5)

// ═══════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(triggered, "Setup triggered", "Setup triggered")
alertcondition(armed and not armed[1], "Setup armed", "A setup is now armed")

if triggered
    grade = isA ? "A" : isB ? "B" : "C"
    pRaw  = (ibTrig ? "IB " : "") + (bfTrig ? "FLAG " : "") + (bxTrig ? "BOX" : "")
    pattern = str.trim(pRaw)
    alert(grade + " setup — " + pattern + " " + syminfo.ticker + " @ " +
          str.tostring(close, format.mintick) + "  (" + str.tostring(qScore) +
          "/" + str.tostring(qMax) + " votes)",
          alert.freq_once_per_bar_close)
````
