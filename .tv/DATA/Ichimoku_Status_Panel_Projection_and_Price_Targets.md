<!-- tradingview-pine-id: PUB;2dddae77fc134f76a3bf56cd2ba7e0f0 -->
<!-- tradingviewscripts-format: 1 -->
# Ichimoku Status Panel - Projection and Price Targets

Source: https://www.tradingview.com/script/94Fn6Vcw/

## Description

Ichimoku Status Panel - Projection and Price Targets

WHAT THIS IS

A read-only status panel for Ichimoku Kinko Hyo. It produces no buy or sell
signals and takes no view on direction. It reports what the chart currently
shows, in a form that is quicker to read than the lines themselves, and leaves
the judgement to the reader.

The panel is aimed at people who already trade with Ichimoku and want the
bookkeeping done for them: which conditions hold, for how long, and what is
already determined about the next few bars.

WHAT IT ADDS OVER A PLAIN ICHIMOKU

1. Projection of the Tenkan-sen and Kijun-sen.

The Tenkan-sen and Kijun-sen are midpoints of rolling high/low windows. That
means the bar on which the current extreme leaves the window is already known,
and so is the value the line will take once it does. The panel reports this as
"in N bars, up/down to X". Unless a new extreme is made in the meantime, that
move is settled in advance. A moving average cannot be read this way, and this
property is generally not surfaced by Ichimoku tools.

2. Chikou Span measured against the cloud, not only against price.

Most implementations compare the Chikou Span with the price 26 periods back
and stop there. Classical treatments also compare it with the cloud that sits
at that same location. A break of the cloud by price that is not confirmed by
the Chikou Span clearing the cloud behind it is a well documented failure
pattern. The panel shows this as a separate row, and calls out when the Chikou
Span is inside the cloud.

3. Counting that matches the original construction.

The original definition displaces by "26 periods including the current one",
which is a 25-bar shift. The script uses this by default and exposes a toggle
for anyone who prefers a plain 26-bar shift, so the reading can be matched to
whichever convention the rest of a workflow uses.

4. Construction from closes only, for indices.

Classical practice takes the intraday high and low, with the note that stock
indices remain valid when built from closes alone. Both are available.

5. Wave price targets, with a validity rule.

V, N, E and NT calculations from the last three alternating swing points, with
the percentage of the move already completed, and an option to hide targets
that price has passed. Consecutive swing points of the same kind are merged
into the more extreme one, so a usable wave is always available rather than
the display stalling whenever two highs or two lows confirm in a row.

More importantly, a wave whose starting point A has been taken out by price is
no longer a valid premise for a target. Pivots confirm several bars late, so
after a breakout the most recent completed wave often still runs against the
market, and every target it produces sits on the wrong side. When this happens
the script falls back to the preceding wave, which by construction runs the
other way, and the panel marks the condition. This keeps the levels on the
side the market is actually working toward.

PANEL ROWS

Bullish count      how many of the six conditions currently hold
Price - Tenkan     side, plus distance from the Tenkan-sen in percent
Tenkan - Kijun     bullish or bearish, and how many bars it has held
Chikou - Price     bullish or bearish, and how many bars it has held
Chikou - Kumo      above, below, or inside the cloud behind price
Price - Kumo       above, below, or inside the current cloud
Kijun slope        rising, falling, or flat with a count of flat bars
Proj Tenkan        bars until the Tenkan-sen moves, and to what value
Proj Kijun         bars until the Kijun-sen moves, and to what value
Kumo twist         bars until the next crossing of the leading spans
Bars since         bars since the recent high and low, flagged when close to
                   the classical time numbers 9, 17, 26, 33, 42, 65 and 76
Wave               the A, B and C points currently used for the targets,
                   marked when the preceding wave is in use or when the
                   starting point has been broken

All panel values are also written to the data window, so past bars can be
inspected by moving the cursor across the chart.

PRICE TARGET FORMULAS

With A as the start of the wave, B as the first objective and C as the
pullback or rally against it:

  V  = B + (B - C)
  N  = C + (B - A)
  E  = B + (B - A)
  NT = C + (C - A)

The same four formulas serve both directions. In a down wave A is the starting
high, B the low and C the rally high, which makes the bracketed terms negative
and places the targets below B.

NT is off by default. Classical texts describe it as the rarest of the four,
and leaving all four on tends to produce a level near any price.

ON LAG AND REVISION

Swing points are found with a pivot lookback, so they confirm a number of bars
after the fact, set by "Swing sensitivity". Until a pivot confirms, the most
recent leg is not part of the wave, and the wave used for the targets can
change as new pivots arrive. The target lines move when it does. This is
inherent to identifying waves mechanically and is not hidden: the A, B and C
values in use are always shown in the panel so the reading can be checked.

The six conditions, the projections and the Kumo twist count are all evaluated
on confirmed values and do not revise.

Choosing the wave is a judgement in classical practice, not a calculation. The
automatic detection here is a convenience. Where it disagrees with the wave you
would have drawn, trust your own.

SETTINGS WORTH KNOWING

Wave selection        "Latest valid" falls back to the preceding wave when
                      price takes out the starting point of the latest one.
                      "Latest only" always uses the most recent wave.
Swing sensitivity     larger picks up larger waves, and confirms later
Target line length    how far left the target lines are drawn
Panel theme           the panel is opaque, so it stays readable on any
                      chart background; the theme is a preference
Draw the Ichimoku lines
                      turn this off if you already have the built-in
                      Ichimoku Cloud on the chart

The time-number flags on the "Bars since" row derive from calendar-based
reasoning in the original theory. They are meaningful on daily charts. On
intraday charts the rest of the panel still applies, but those flags are best
ignored.

CREDIT

Ichimoku Kinko Hyo was developed by Goichi Hosoda. The projection property,
the Chikou Span versus cloud relationship, the inclusive counting convention
and the four price target formulas are all part of the classical body of
theory. The code and the panel design are my own.

---

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// ============================================================================
//  Ichimoku Status Panel - Projection and Price Targets
//  ---------------------------------------------------------------------------
//  A read-only situational panel for Ichimoku Kinko Hyo. It produces no buy or
//  sell signals. It reports what the chart currently shows so the reader can
//  form their own judgement.
//
//  Contents
//    1. Six-condition bullish / bearish matrix with duration in bars
//    2. Projection - Tenkan-sen and Kijun-sen are midpoints of rolling high /
//       low windows, so it is possible to know in advance which extreme will
//       drop out of the window, in how many bars, and where the line will move
//       as a result. This is confirmed unless a new extreme is made.
//    3. Bars remaining until the next Kumo twist
//    4. Bars elapsed since the recent high / low, flagged against the classical
//       time numbers (9, 17, 26, 33, 42, 65, 76)
//    5. Wave price targets - V, N, E and NT calculations
//
//  Terminology note
//    In classical Ichimoku the term "jissen" refers to the candlesticks
//    themselves, not to a close-based line. Only the Chikou Span is close
//    based: it plots today's close 26 periods back.
//
//  Written for Pine Script v6. Points checked against the v5 to v6 migration
//  guide: no int or float used where a bool is expected, no na() or nz() on
//  bool values, no ta.*() call placed on the right side of an and / or where
//  lazy evaluation would skip it, no integer division, no series value passed
//  to a plot offset, no history reference on a literal or a UDT field, no for
//  loop whose end boundary changes inside its own scope, and no reliance on
//  the color constants whose values changed in v6.
//
//  Counting note
//    The original construction counts "26 periods including today", which is a
//    25-bar shift. This is the default and matches the built-in Ichimoku
//    Cloud. It can be switched off to use a plain 26-bar shift.
// ============================================================================
indicator("Ichimoku Status Panel - Projection and Price Targets", shorttitle="Ichimoku Status", overlay=true, max_lines_count=10, max_labels_count=10)

// ------------------------------------------------------------------ Ichimoku
grpI   = "Ichimoku"
lenC   = input.int(9,  "Tenkan-sen (Conversion Line)",   minval=2, group=grpI)
lenB   = input.int(26, "Kijun-sen (Base Line)",    minval=2, group=grpI)
lenS   = input.int(52, "Senkou Span B (Leading Span B)", minval=2, group=grpI)
shift  = input.int(26, "Displacement", minval=1, group=grpI)
incTdy = input.bool(true,  "Count the current bar as period 1 (25-bar shift)", group=grpI, tooltip="Matches the original construction and the built-in Ichimoku Cloud. Turn off for a plain 26-bar shift.")
useCls = input.bool(false, "Build from closes only (stock indices)",           group=grpI, tooltip="Classical practice uses intraday high and low, but indices may be built from closes alone.")
showI  = input.bool(true,  "Draw the Ichimoku lines",                          group=grpI)

// ------------------------------------------------------------ Price targets
grpN     = "Wave price targets"
showTgt  = input.bool(true, "Draw target lines", group=grpN)
pivLen   = input.int(7, "Swing sensitivity (bars each side)", minval=3, group=grpN, tooltip="Pivots confirm this many bars late, so the detected wave can still change.")
onV      = input.bool(true,  "V  =  B + (B - C)", inline="tg1", group=grpN)
onN      = input.bool(true,  "N  =  C + (B - A)", inline="tg1", group=grpN)
onE      = input.bool(true,  "E  =  B + (B - A)", inline="tg2", group=grpN)
onNT     = input.bool(false, "NT =  C + (C - A)", inline="tg2", group=grpN, tooltip="Classical texts describe NT as the rarest of the four.")
waveSel  = input.string("Latest valid", "Wave selection", options=["Latest valid", "Latest only"], group=grpN, tooltip="Latest valid falls back to the previous wave once price takes out the starting point A of the latest one.")
anchorN  = input.int(40, "Target line length (bars)", minval=5, maxval=200, group=grpN)
onlyUnr  = input.bool(true, "Show unreached targets only", group=grpN)
showPct  = input.bool(true, "Show progress toward target", group=grpN)

// ------------------------------------------------------------------ Kata-fu
grpK      = "Candle patterns (Kata-fu)"
dojiRatio = input.float(0.05, "Doji body ratio threshold", minval=0.0, maxval=0.5, step=0.01, group=grpK, tooltip="A candle counts as a doji when its body is this fraction of its range or smaller")

// ------------------------------------------------------------------ Display
grpD    = "Display"
lookbk  = input.int(120, "Lookback for elapsed-bar count", minval=20, group=grpD)
posStr  = input.string("Top right", "Panel position", options=["Top right", "Bottom right", "Top left", "Bottom left"], group=grpD)
themeStr= input.string("Dark", "Panel theme", options=["Dark", "Light"], group=grpD)
txtSize = input.string("Normal", "Text size", options=["Small", "Normal", "Large"], group=grpD)

// ------------------------------------------------------------------- Colors
// The panel carries an opaque background so it stays readable on both dark and
// light chart backgrounds.
isDark = themeStr == "Dark"
cBg    = isDark ? #1E222D : #FFFFFF
cHdr   = isDark ? #2B3548 : #DCE7F5
cFrame = isDark ? #434651 : #B8BCC4
cLbl   = isDark ? #B2B5C4 : #555B6E
cTxt   = isDark ? #F0F3FA : #1A1D26
cEmph  = isDark ? #FFFFFF : #000000
cOn    = isDark ? #00E676 : #00796B
cOff   = isDark ? #848E9C : #9FA3B0
cWarn  = isDark ? #FF5252 : #C62828
cInfo  = isDark ? #FFD54F : #B45309

tSizeS = txtSize == "Small" ? size.tiny  : txtSize == "Large" ? size.normal : size.small
tSizeL = txtSize == "Small" ? size.small : txtSize == "Large" ? size.large  : size.normal

// =================================================================== Ichimoku
srcH = useCls ? close : high
srcL = useCls ? close : low

mid(simple int len) => math.avg(ta.lowest(srcL, len), ta.highest(srcH, len))

conv  = mid(lenC)
baseL = mid(lenB)
spanA = math.avg(conv, baseL)
spanB = mid(lenS)

disp = math.max(incTdy ? shift - 1 : shift, 1)

// The cloud drawn at the current bar was calculated disp bars ago
cloudTop = math.max(spanA[disp], spanB[disp])
cloudBot = math.min(spanA[disp], spanB[disp])

// The cloud drawn where the Chikou Span sits was calculated 2 x disp bars ago
lagTop = math.max(spanA[disp * 2], spanB[disp * 2])
lagBot = math.min(spanA[disp * 2], spanB[disp * 2])

// ============================================================ Six conditions
g1 = close > conv                       // price above Tenkan-sen
g2 = conv  > baseL                      // Tenkan above Kijun
g3 = close > close[disp]                // Chikou Span above past price
g4 = close > lagTop                     // Chikou Span above the cloud
g5 = close > cloudTop                   // price above the cloud
g6 = baseL > baseL[1]                   // Kijun-sen rising
cnt = (g1 ? 1 : 0) + (g2 ? 1 : 0) + (g3 ? 1 : 0) + (g4 ? 1 : 0) + (g5 ? 1 : 0) + (g6 ? 1 : 0)

bs(bool b) => nz(ta.barssince(b != b[1]), bar_index) + 1
n2 = bs(g2)
n3 = bs(g3)

var int flatN = 0
flatN := baseL == baseL[1] ? flatN + 1 : 0

// ================================================================ Projection
// Look ahead to the bar on which the current extreme leaves the rolling window
// and report where the line will sit once it does.
maxOver(int cnt_) =>
    float m = na
    if cnt_ > 0
        for i = 0 to cnt_ - 1
            m := na(m) ? srcH[i] : math.max(m, srcH[i])
    m

minOver(int cnt_) =>
    float m = na
    if cnt_ > 0
        for i = 0 to cnt_ - 1
            m := na(m) ? srcL[i] : math.min(m, srcL[i])
    m

preCalc(simple int len) =>
    int   aH = -ta.highestbars(srcH, len)
    int   aL = -ta.lowestbars(srcL, len)
    int   nH = len - aH
    int   nL = len - aL
    int   n  = math.min(nH, nL)
    float pH = n == nH ? maxOver(aH) : ta.highest(srcH, len)
    float pL = n == nL ? minOver(aL) : ta.lowest(srcL, len)
    float pv = na(pH) or na(pL) ? na : math.avg(pH, pL)
    [n, pv]

[nConv, vConv] = preCalc(lenC)
[nBase, vBase] = preCalc(lenB)

// ================================================================ Kumo twist
// Leading spans are plotted disp bars ahead, so the next disp bars of cloud
// are already determined.
int twistIn = 0
for j = 1 to disp
    idx = disp - j
    if (spanA[idx] > spanB[idx]) != (spanA[idx + 1] > spanB[idx + 1])
        twistIn := j
        break

// =============================================================== Bars elapsed
barsHi = -ta.highestbars(high, lookbk)
barsLo = -ta.lowestbars(low,  lookbk)

nearK(int n) =>
    math.abs(n -  9) <= 1 ?  9 : math.abs(n - 17) <= 1 ? 17 : math.abs(n - 26) <= 1 ? 26 : math.abs(n - 33) <= 1 ? 33 : math.abs(n - 42) <= 2 ? 42 : math.abs(n - 65) <= 2 ? 65 : math.abs(n - 76) <= 2 ? 76 : 0

kHi = nearK(barsHi)
kLo = nearK(barsLo)

// ============================================================= Price targets
// Consecutive pivots of the same kind are merged into the more extreme one so
// that highs and lows always alternate and a wave is always available.
ph = ta.pivothigh(srcH, pivLen, pivLen)
pl = ta.pivotlow(srcL, pivLen, pivLen)

var float p0 = na   // most recent swing point
var float p1 = na
var float p2 = na
var float p3 = na
var int   t0 = 0    // 1 = high, -1 = low

if not na(ph)
    if t0 == 1
        if ph > p0
            p0 := ph
    else
        p3 := p2
        p2 := p1
        p1 := p0
        p0 := ph
        t0 := 1

if not na(pl)
    if t0 == -1
        if pl < p0
            p0 := pl
    else
        p3 := p2
        p2 := p1
        p1 := p0
        p0 := pl
        t0 := -1

// Two candidate waves are available at any time. The latest one is p2 > p1 > p0.
// Because swing points alternate, the one before it, p3 > p2 > p1, always runs
// in the opposite direction.
//
// A wave whose starting point A has been taken out by price is no longer a
// valid premise for a target, so in that case the previous wave is used
// instead. Without this rule a broken wave keeps projecting targets on the
// wrong side of the market until the next pivot confirms.
bullL = t0 == -1                 // latest wave: C is a low, so it points up
bullP = t0 == 1                  // previous wave always points the other way
okL   = not na(p2) and not na(p1) and not na(p0)
okP   = not na(p3) and not na(p2) and not na(p1)
brkL  = okL and (bullL ? close < p2 : close > p2)
brkP  = okP and (bullP ? close < p3 : close > p3)

useL   = waveSel == "Latest only" or not brkL or not okP or brkP
A      = useL ? p2 : p3
B      = useL ? p1 : p2
C      = useL ? p0 : p1
bull   = useL ? bullL : bullP
okABC  = useL ? okL : okP
broken = useL ? brkL : brkP
cTgt   = bull ? cOn : cWarn

// One set of formulas covers both directions. In a down wave A is the starting
// high, B the low and C the rally high, so (B - A) and (B - C) turn negative.
vV  = B + (B - C)
vN  = C + (B - A)
vE  = B + (B - A)
vNT = C + (C - A)

live(float px) => na(px) ? false : not onlyUnr or (bull ? px > close : px < close)
vis(bool on, float px) => showTgt and okABC and on and live(px)

lvV  = vis(onV,  vV)  ? vV  : na
lvN  = vis(onN,  vN)  ? vN  : na
lvE  = vis(onE,  vE)  ? vE  : na
lvNT = vis(onNT, vNT) ? vNT : na


// =============================================================== Kata-fu
// A "streak" (ren) requires at least 5 bars. Five, seven and nine bar
// streaks are successive tiers. "Orderly" (juendo) means both the real
// body and the wicks make new extremes bar over bar in the streak's
// direction; "disorderly" (fujuendo) means they do not. This distinction
// is the stated point of difference from a plain candle count such as the
// Sakata methods. A doji does not break a streak and is counted toward its
// length, matching a worked example in the source text where a gap-up doji
// following a five-bar streak extended it to six.
barColor(int i) =>
    float o = open[i]
    float c = close[i]
    float h = high[i]
    float l = low[i]
    float rng = h - l
    bool isDoji = rng == 0 or math.abs(c - o) <= rng * dojiRatio
    isDoji ? 0 : (c > o ? 1 : -1)

kfFindDir() =>
    int d = 0
    for i = 0 to 19
        int c = barColor(i)
        if c != 0
            d := c
            break
    d

kfDir = kfFindDir()

kfStreakLen() =>
    int n = 0
    if kfDir != 0
        for i = 0 to 39
            int c = barColor(i)
            if c == -kfDir
                break
            n += 1
    n

kfLen = kfStreakLen()

// Orderly check: walk the real (non-doji) bars in the streak from oldest to
// newest and confirm the high, low, open and close all extend in the same
// direction bar over bar.
kfIsOrderly() =>
    bool ok = true
    float prevH = na
    float prevL = na
    float prevO = na
    float prevC = na
    if kfLen > 0
        for j = 0 to kfLen - 1
            int i = kfLen - 1 - j
            int c = barColor(i)
            if c != 0
                float h  = high[i]
                float l  = low[i]
                float o  = open[i]
                float cl = close[i]
                if not na(prevH)
                    if kfDir == 1
                        if not (h > prevH and l > prevL and o > prevO and cl > prevC)
                            ok := false
                    else
                        if not (h < prevH and l < prevL and o < prevO and cl < prevC)
                            ok := false
                prevH := h
                prevL := l
                prevO := o
                prevC := cl
    ok

kfOrderlyOK = kfIsOrderly()

kfTierName(int n, int dir) =>
    dir == 1 ? (n >= 9 ? "9-bull" : n >= 7 ? "7-bull" : n >= 5 ? "5-bull" : "") : (n >= 9 ? "9-bear" : n >= 7 ? "7-bear" : n >= 5 ? "5-bear" : "")

// The source text values a small total range over the streak. This is
// reported, not scored.
kfRangePct = kfLen >= 5 ? (ta.highest(high, kfLen) - ta.lowest(low, kfLen)) / close * 100 : na

// The source text notes the pattern is strongest when it follows a move of
// one period (26 bars) or more in the opposite direction. This uses disp,
// already defined above for that same 25-26 bar convention, and checks the
// close one period further back against the close at the streak's start as
// a simplified proxy for a sustained prior move; it is not a strict
// monotonic check.
kfPrecond(int startOffset, int dir) =>
    int back = startOffset + disp
    bool ok = false
    if back <= bar_index
        ok := dir == 1 ? close[back] > close[startOffset] : close[back] < close[startOffset]
    ok

// Interposed patterns: a fixed window (6 bars for a one-bear-interposed
// five-bull streak, 8 for seven-bull, 11 with two interposed bears for
// nine-bull) where the window's first and last bars must run with the
// streak and a fixed count of opposite-colored bars sits inside.
checkInterposed(int W, int K, int dir) =>
    bool valid = true
    if barColor(0) != dir or barColor(W - 1) != dir
        valid := false
    if valid
        int nonDir = 0
        for i = 1 to W - 2
            int c = barColor(i)
            if c != dir
                nonDir += 1
        if nonDir != K
            valid := false
    valid

ipBull11 = checkInterposed(11, 2, 1)
ipBull8  = checkInterposed(8,  1, 1)
ipBull6  = checkInterposed(6,  1, 1)
ipBear11 = checkInterposed(11, 2, -1)
ipBear8  = checkInterposed(8,  1, -1)
ipBear6  = checkInterposed(6,  1, -1)

ipName = ipBull11 ? "2 bears in 9-bull" : ipBull8 ? "1 bear in 7-bull" : ipBull6 ? "1 bear in 5-bull" : ipBear11 ? "2 bulls in 9-bear" : ipBear8 ? "1 bull in 7-bear" : ipBear6 ? "1 bull in 5-bear" : ""
ipW    = ipBull11 or ipBear11 ? 11 : ipBull8 or ipBear8 ? 8 : ipBull6 or ipBear6 ? 6 : 0
ipDir  = (ipBull11 or ipBull8 or ipBull6) ? 1 : (ipBear11 or ipBear8 or ipBear6) ? -1 : 0
ipPre  = ipW > 0 ? kfPrecond(ipW - 1, ipDir) : false

// ============================================================= Panel strings
f(float v) => str.tostring(v, format.mintick)

sDev = str.tostring((close - conv) / conv * 100, "#.##") + "%"
t1   = (g1 ? "Above" : "Below") + "  dev " + sDev
t2   = (g2 ? "Bullish" : "Bearish") + "  " + str.tostring(n2) + " bars"
t3   = (g3 ? "Bullish" : "Bearish") + "  " + str.tostring(n3) + " bars"
t4   = close > lagTop ? "Above cloud" : close < lagBot ? "Below cloud" : "Inside cloud - capped by resistance"
t5   = close > cloudTop ? "Above cloud" : close < cloudBot ? "Below cloud" : "Inside cloud"
t6   = g6 ? "Rising" : baseL < baseL[1] ? "Falling" : "Flat  " + str.tostring(flatN) + " bars"

arw(float pv, float cur) => na(pv) ? "" : pv > cur ? "UP " : pv < cur ? "DN " : "-- "
t7   = na(vConv) ? "n/a" : "in " + str.tostring(nConv) + " bars  " + arw(vConv, conv)  + f(vConv)
t8   = na(vBase) ? "n/a" : "in " + str.tostring(nBase) + " bars  " + arw(vBase, baseL) + f(vBase)
t9   = twistIn > 0 ? "in " + str.tostring(twistIn) + " bars" : "none within range"
t10  = "high " + str.tostring(barsHi) + (kHi > 0 ? " (near " + str.tostring(kHi) + ")" : "") + "  /  low " + str.tostring(barsLo) + (kLo > 0 ? " (near " + str.tostring(kLo) + ")" : "")
t11  = not okABC ? "detecting" : (bull ? "Up" : "Down") + (useL ? "" : "  (prev)") + (broken ? "  (A broken)" : "") + "   A " + f(A) + " > B " + f(B) + " > C " + f(C)

kfOrderlyTxt = kfOrderlyOK ? "Orderly" : "Disorderly"
t12 = kfLen < 5 ? str.tostring(kfLen) + " bars (below 5)" : kfOrderlyTxt + "  " + kfTierName(kfLen, kfDir) + "  (" + str.tostring(kfLen) + " bars)  range " + str.tostring(kfRangePct, "#.#") + "%" + (kfPrecond(kfLen - 1, kfDir) ? "  prior move ok" : "")
t13 = ipW == 0 ? "none" : ipName + "  (" + str.tostring(ipW) + " bars)" + (ipPre ? "  prior move ok" : "")

// ==================================================================== Panel
tPos = posStr == "Top right" ? position.top_right : posStr == "Bottom right" ? position.bottom_right : posStr == "Top left" ? position.top_left : position.bottom_left

var table t = table.new(tPos, 3, 14, bgcolor=cBg, border_width=1, frame_width=1, frame_color=cFrame, border_color=cFrame)

mk(bool b) => b ? "+" : "-"

row(int r, string k, string v, bool ok) =>
    table.cell(t, 0, r, k, text_color=cLbl, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, 1, r, v, text_color=ok ? cTxt : cOff, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, 2, r, mk(ok), text_color=ok ? cOn : cOff, text_size=tSizeS, bgcolor=cBg)

inf(int r, string k, string v, color vc) =>
    table.cell(t, 0, r, k, text_color=cLbl, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, 1, r, v, text_color=vc, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, 2, r, "", bgcolor=cBg)

if barstate.islast
    table.cell(t, 0, 0, "Bullish", text_color=cLbl, text_size=tSizeS, text_halign=text.align_left, bgcolor=cHdr)
    table.cell(t, 1, 0, str.tostring(cnt) + "  /  6", text_color=cEmph, text_size=tSizeL, text_halign=text.align_left, bgcolor=cHdr)
    table.cell(t, 2, 0, "", bgcolor=cHdr)

    row(1, "Price - Tenkan",  t1, g1)
    row(2, "Tenkan - Kijun",  t2, g2)
    row(3, "Chikou - Price",  t3, g3)
    row(4, "Chikou - Kumo",   t4, g4)
    row(5, "Price - Kumo",    t5, g5)
    row(6, "Kijun slope",     t6, g6)

    inf(7,  "Proj Tenkan", t7,  cInfo)
    inf(8,  "Proj Kijun",  t8,  cInfo)
    inf(9,  "Kumo twist",  t9,  twistIn > 0 ? cInfo : cOff)
    inf(10, "Bars since",  t10, (kHi > 0 or kLo > 0) ? cInfo : cTxt)
    inf(11, "Wave",        t11, not okABC or broken ? cOff : cTgt)

    inf(12, "Kata-fu",     t12, kfLen >= 5 ? (kfOrderlyOK ? cOn : cWarn) : cOff)
    inf(13, "Interposed",  t13, ipW > 0 ? cInfo : cOff)

// ============================================================== Target lines
// One set of objects is created up front and only the coordinates are updated,
// so no drawing objects accumulate and the time buffer is sized correctly.
newLine(simple int w, simple string st) => line.new(0, 0.0, 0, 0.0, color=#00000000, width=w, style=st, extend=extend.none)
newLab() => label.new(0, 0.0, "", style=label.style_label_left, color=#00000000, textcolor=#00000000, size=tSizeS)

var line  lnV  = newLine(1, line.style_dotted)
var line  lnN  = newLine(1, line.style_dashed)
var line  lnE  = newLine(2, line.style_dashed)
var line  lnNT = newLine(1, line.style_dotted)
var label bV   = newLab()
var label bN   = newLab()
var label bE   = newLab()
var label bNT  = newLab()

prog(float tgt) => na(tgt) or na(C) or tgt == C ? na : (close - C) / (tgt - C) * 100.0

upd(line L, label T, string nm, float px) =>
    if na(px)
        line.set_color(L, #00000000)
        label.set_text(T, "")
        label.set_color(T, #00000000)
        label.set_textcolor(T, #00000000)
    else
        int x1 = math.max(bar_index - anchorN, 0)
        int x2 = bar_index + 6
        line.set_xy1(L, x1, px)
        line.set_xy2(L, x2, px)
        line.set_color(L, cTgt)
        float pg = prog(px)
        label.set_xy(T, x2, px)
        label.set_text(T, nm + "  " + f(px) + (showPct and not na(pg) ? "   " + str.tostring(pg, "#") + "%" : ""))
        label.set_color(T, color.new(cTgt, 88))
        label.set_textcolor(T, cTgt)

upd(lnV,  bV,  "V",  lvV)
upd(lnN,  bN,  "N",  lvN)
upd(lnE,  bE,  "E",  lvE)
upd(lnNT, bNT, "NT", lvNT)

// ========================================================== Ichimoku drawing
pA = plot(showI ? spanA : na, "Senkou Span A (Leading Span A)", color=color.new(#26A69A, 45), offset=disp)
pB = plot(showI ? spanB : na, "Senkou Span B (Leading Span B)", color=color.new(#EF5350, 45), offset=disp)
fill(pA, pB, title="Cloud (Kumo)", color=spanA > spanB ? color.new(#26A69A, 90) : color.new(#EF5350, 90))
plot(showI ? conv  : na, "Tenkan-sen (Conversion Line)",  color=#3D8BFD)
plot(showI ? baseL : na, "Kijun-sen (Base Line)",   color=#FF8C42)
plot(showI ? close : na, "Chikou Span (Lagging Span)", color=color.new(#9C6ADE, 20), offset=-disp)

// ============================================================== Data window
plot(cnt,     "Bullish count",    display=display.data_window)
plot(nConv,   "Proj Tenkan bars", display=display.data_window)
plot(vConv,   "Proj Tenkan value",display=display.data_window)
plot(nBase,   "Proj Kijun bars",  display=display.data_window)
plot(vBase,   "Proj Kijun value", display=display.data_window)
plot(twistIn, "Twist in bars",    display=display.data_window)
plot(A,       "Wave A", display=display.data_window)
plot(B,       "Wave B", display=display.data_window)
plot(C,       "Wave C", display=display.data_window)

// ============================================================= Runtime notes
// Drawing objects convert x coordinates to timestamps internally, so the time
// buffer must be large enough for the target line anchor.
max_bars_back(time, 300)
````
