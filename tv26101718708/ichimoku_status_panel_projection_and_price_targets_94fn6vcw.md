# Ichimoku Status Panel - Projection and Price Targets

- url: https://www.tradingview.com/script/94Fn6Vcw/
- type: indicator
- pine_id: PUB;2dddae77fc134f76a3bf56cd2ba7e0f0
- version: 16.0

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
//    Cloud. It can be switched off to use a plain 26-bar shift. The same
//    convention governs the elapsed counts and leg lengths in the time theory
//    section, so a classical number of 9 lands on the ninth bar counting the
//    swing origin as the first.
// ============================================================================
indicator("Ichimoku Status Panel - Projection and Price Targets", shorttitle="Ichimoku Status", overlay=true, max_lines_count=60, max_labels_count=100)

// ------------------------------------------------------------------ Ichimoku
grpI   = "Ichimoku"
lenC   = input.int(9,  "Tenkan-sen (Conversion Line)",   minval=2, group=grpI)
lenB   = input.int(26, "Kijun-sen (Base Line)",    minval=2, group=grpI)
lenS   = input.int(52, "Senkou Span B (Leading Span B)", minval=2, group=grpI)
shift  = input.int(26, "Displacement", minval=1, group=grpI)
incTdy = input.bool(true,  "Count the current bar as period 1 (25-bar shift)", group=grpI, tooltip="Matches the original construction and the built-in Ichimoku Cloud. Turn off for a plain 26-bar shift.")
useCls = input.bool(false, "Build from closes only (stock indices)",           group=grpI, tooltip="Classical practice uses intraday high and low, but indices may be built from closes alone.")
showI  = input.bool(true,  "Draw the Ichimoku lines",                          group=grpI)
flatHi = input.bool(true, "Emphasise flat stretches of Senkou Span B", group=grpI, tooltip="A stretch where neither the 52-bar high nor low has changed. Drawn at full opacity once it has run for the length below, nine by default after the classical unit")
flatMin= input.int(9, "Shortest flat stretch to emphasise", minval=2, maxval=52, group=grpI)

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

// ------------------------------------------------------------------- Alerts
grpA   = "Alerts (Kata-fu)"
alOn   = input.bool(false, "Enable kata-fu alerts", group=grpA, tooltip="Enable this, then create an alert whose condition is 'Any alert() function call'. A dropdown route is also provided if you prefer picking the condition directly")
alTier = input.string("5 or more", "Streaks to alert on", options=["5 or more", "7 or more", "9 or more"], group=grpA, tooltip="Each tier fires once as it is reached")
alOrd  = input.bool(false, "Orderly streaks only", group=grpA, tooltip="Not applied to interposed patterns, which the source text does not split into orderly and disorderly")
alPre  = input.bool(false, "Only after an opposing move of one period", group=grpA, tooltip="Alerts only when the pattern follows a move of 26 bars or more in the opposite direction")
alBull = input.bool(true, "Bull", inline="al1", group=grpA)
alBear = input.bool(true, "Bear", inline="al1", group=grpA)
alIp   = input.bool(true, "Alert on interposed patterns too", group=grpA)

// ---------------------------------------------------------------- Time theory
// The source text builds its time analysis on the chart's own (daily) bars.
// The weekly treatment in Chapter 7 is introduced explicitly as a "simplified
// method": less precise for pinning down an exact date, but, in the author's
// words, still worth having for locating periods where a change of direction
// is likely. The chart's own timeframe is therefore the default here, with the
// higher timeframe available as an alternative rather than shown alongside it.
grpH  = "Time theory (Ch.2 chart timeframe / Ch.7 higher timeframe)"
tfMode  = input.string("Chart", "Measure on", options=["Chart", "Higher"], group=grpH, tooltip="Chart uses the Chapter 2 time theory; Higher uses the Chapter 7 simplified method. Only one is shown at a time")
htfMode = input.string("Auto", "Higher timeframe selection", options=["Auto", "Manual"], group=grpH, tooltip="Only used when Measure on is set to Higher. Auto picks a round timeframe roughly five times the chart's own")
htfMan  = input.timeframe("W", "Higher timeframe (manual)", group=grpH)
hPivL   = input.int(5, "Swing sensitivity (bars each side)", minval=1, group=grpH, tooltip="Pivots confirm this many bars late. A higher timeframe is already coarse, so 2-3 suits it; around 5 suits the chart's own bars")
showFut = input.bool(true, "Draw forecast lines for the next turns", group=grpH, tooltip="A rough calendar-based estimate (7 days per week, 30 per month) that ignores non-trading days. It marks periods where a change is more likely, not a direction")
archN   = input.int(0, "Keep this many past confirmations", minval=0, maxval=20, group=grpH, tooltip="Leaves a faded vertical line where a forecast time number was actually reached. 0 disables it. Intended for occasional review: left on permanently the lines accumulate until something always sits near any turn")
archTr  = input.int(70, "Transparency of past confirmations", minval=0, maxval=95, group=grpH)
showSw  = input.bool(false, "Mark detected swing points and leg lengths", group=grpH, tooltip="Shows the points the time module treats as wave origins, so the sensitivity setting can be checked against your own reading")
swN     = input.int(20, "Keep this many swing marks", minval=2, maxval=40, group=grpH)
minBaS  = input.string("9", "Lowest classical number to use", options=["9", "17", "26", "33", "42", "51", "65", "76"], group=grpH, tooltip="Only one forecast line exists at a time, so 9 is fine by default. With past confirmations enabled, 9 and 17 are crossed by nearly every leg and the lines pile up, so choose 26 or higher then")
minDur  = input.int(17, "Shortest leg treated as a match", minval=5, maxval=60, group=grpH, tooltip="A match between two short legs is almost always coincidence, so legs below this length are excluded. The source text's weekly example spans 15-18 weeks, roughly 75-90 daily bars")
onlyBoth= input.bool(false, "Only draw where both reasons coincide", group=grpH, tooltip="Draws only when the classical number and the duration match point to a similar time. Far fewer lines")
bothTol = input.int(2, "Tolerance for coincidence (bars)", minval=0, maxval=5, group=grpH)

// Chart timeframe to higher timeframe map. An exact 5x step often lands on a
// timeframe that does not exist (25 minutes, for instance), so each step is
// rounded to a real, round timeframe. The resulting ratio varies from about
// four to six times.
autoHTF() =>
    int m = timeframe.multiplier
    string r = "W"
    if timeframe.isseconds
        r := "5"
    else if timeframe.isminutes
        r := m <= 1 ? "5" : m <= 3 ? "15" : m <= 5 ? "30" : m <= 15 ? "60" : m <= 30 ? "120" : m <= 60 ? "240" : m <= 120 ? "480" : "D"
    else if timeframe.isdaily
        r := "W"
    else if timeframe.isweekly
        r := "M"
    else if timeframe.ismonthly
        r := "3M"
    r

// Selecting Chart simply passes timeframe.period through. Everything downstream
// is identical either way; only the timeframe being measured changes.
htf = tfMode == "Chart" ? timeframe.period : (htfMode == "Auto" ? autoHTF() : htfMan)

// ------------------------------------------------------------------ Display
grpD    = "Display"
lookbk  = input.int(120, "Lookback for elapsed-bar count", minval=20, group=grpD)
kTol    = input.int(3, "Tolerance for a classical number (bars)", minval=0, maxval=6, group=grpD, tooltip="An elapsed count within this many bars of a classical number is flagged. Set to 0 to flag exact hits only")
showRng = input.bool(true, "Show the band the projection holds within", group=grpD, tooltip="A projection is replaced if price passes certain levels before it lands. Those levels are shown as [low-high]: while price stays inside, the projection is settled")
posStr  = input.string("Top right", "Panel position", options=["Top right", "Bottom right", "Top left", "Bottom left"], group=grpD)
themeStr= input.string("Auto", "Panel theme", options=["Auto", "Dark", "Light"], group=grpD, tooltip="Auto follows the brightness of the chart background")
txtSize = input.string("Normal", "Text size", options=["Small", "Normal", "Large"], group=grpD)

// ------------------------------------------------------------------- Colors
// The panel carries an opaque background so it stays readable on both dark and
// light chart backgrounds.
// The panel is opaque, so the chart background does not bleed through, but a
// manual switch means changing the setting every time the chart theme changes.
// This reads the background's brightness instead.
bgLum  = (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)) / 255
isDark = themeStr == "Auto" ? bgLum < 0.5 : themeStr == "Dark"
cBg    = isDark ? #1E222D : #FFFFFF
cHdr   = isDark ? #2B3548 : #DCE7F5
cFrame = isDark ? #434651 : #B8BCC4
cLbl   = isDark ? #B2B5C4 : #555B6E
cTxt   = isDark ? #F0F3FA : #1A1D26
cEmph  = isDark ? #FFFFFF : #000000
cOn    = isDark ? #00E676 : #00796B
cOff   = isDark ? #9AA3B2 : #7A8090  // no data yet (not detected, out of range)
cDn    = isDark ? #FF7A7A : #C62828  // bearish / falling - a direction, not a verdict
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

// A flat Senkou Span B means neither the 52-bar high nor the 52-bar low has
// changed. A midpoint reads only the two extremes, so this is information a
// moving average cannot show at all.
//
// Each bar counts how far back the same value runs, itself included, and is
// drawn at full opacity once that reaches flatMin. Since plot colours each bar
// independently, the ninth bar of a stretch onward is emphasised and the first
// eight stay faint.
//
// Reaching back to the start of the stretch is not possible here: how long a
// stretch runs is not settled until later bars arrive, and plot cannot repaint
// bars already drawn. The emphasis therefore extends backwards as the stretch
// grows. Every spanB[i] referenced is an already-calculated value, so nothing
// repaints.
sbFlatLen(int lim) =>
    int n = 1
    for i = 1 to lim
        if na(spanB[i]) or spanB[i] != spanB[0]
            break
        n += 1
    n

sbOn = flatHi and sbFlatLen(60) >= flatMin

disp = math.max(incTdy ? shift - 1 : shift, 1)

// The cloud drawn at the current bar was calculated disp bars ago
cloudTop = math.max(spanA[disp], spanB[disp])
cloudBot = math.min(spanA[disp], spanB[disp])

// The cloud drawn where the Chikou Span sits was calculated 2 x disp bars ago
lagTop = math.max(spanA[disp * 2], spanB[disp * 2])
lagBot = math.min(spanA[disp * 2], spanB[disp * 2])

// ============================================================ Conditions
// Each item is three-state: +1 bullish, -1 bearish, 0 neutral (equal / inside).
// The score is their sum and runs from -7 to +7; neutral items count as zero.
st3(float a, float b) => a > b ? 1 : a < b ? -1 : 0
stPC = st3(close, conv)                                   // price vs Tenkan
stPB = st3(close, baseL)                                  // price vs Kijun
stCB = st3(conv, baseL)                                   // Tenkan vs Kijun
stLP = st3(close, close[disp])                            // Chikou vs past price
stLK = close > lagTop   ? 1 : close < lagBot   ? -1 : 0   // Chikou vs cloud
stPK = close > cloudTop ? 1 : close < cloudBot ? -1 : 0   // price vs cloud
stKJ = st3(baseL, baseL[1])                               // Kijun slope
score  = stPC + stPB + stCB + stLP + stLK + stPK + stKJ
SCRMAX = 7
g2 = stCB == 1
g3 = stLP == 1
g6 = stKJ == 1

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
    // pH and pL are also the bounds within which this projection holds: they
    // are the extremes left in the window afterwards, so a high above pH or a
    // low below pL during the intervening bars replaces the projection.
    [n, pv, pH, pL]

[nConv, vConv, hiConv, loConv] = preCalc(lenC)
[nBase, vBase, hiBase, loBase] = preCalc(lenB)

// Because the projection gives the future value of both lines, the bar on
// which their order flips can be read ahead too. The two lines move at
// different times, so this is checked in two stages: when the first one moves,
// and when both have moved.
//
// No such projection can be made unconditional. The Tenkan's 9-bar window sits
// inside the Kijun's 26-bar window, so a high large enough to top both windows
// leaves only the lows to differ and forces the bullish order; a deep enough
// low forces the bearish one. Any projection can therefore be overturned by a
// single large move. What is shown instead is the price band within which the
// projection holds - the overlap of the bands for the two lines.
xN1 = math.min(nConv, nBase)
xN2 = math.max(nConv, nBase)
xC1 = nConv <= nBase ? vConv : conv      // Tenkan at the first of the two moves
xB1 = nBase <= nConv ? vBase : baseL     // Kijun at that same point
xS1 = na(xC1) or na(xB1) ? g2 : xC1 > xB1
xS2 = na(vConv) or na(vBase) ? g2 : vConv > vBase
flipN  = xS1 != g2 ? xN1 : xS2 != g2 ? xN2 : 0
flipTx = flipN == 0 ? "" : (g2 ? "bearish" : "bullish")

// Band within which the projection holds; the overlap of the two lines' bands.
okHi = na(hiConv) or na(hiBase) ? na : math.min(hiConv, hiBase)
okLo = na(loConv) or na(loBase) ? na : math.max(loConv, loBase)

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

// The classical time numbers: the simple ones 9, 17 and 26, plus the compound
// numbers built from them. Compounding subtracts the overlapping bar, which is
// how 9 doubled less one gives 17 and tripled less two gives 26. By the same
// rule 26 + 26 - 1 gives 51, so the two-period number is 51 rather than 52.
// 129 and 172 belong to the same series.
var int[] KNUM = array.from(9, 17, 26, 33, 42, 51, 65, 76, 129, 172)

// Tests how close a count sits to a classical number, with the tolerance passed
// in by the caller: wider for the elapsed-bar row, narrower for the forecast
// lines. Returns the nearest classical number within tolerance, or 0.
nearKt(int n, int tol) =>
    int best = 0
    int bd   = 999
    for i = 0 to array.size(KNUM) - 1
        int k = array.get(KNUM, i)
        int d = math.abs(n - k)
        if d <= tol and d < bd
            bd   := d
            best := k
    best

// The forecast lines keep the original, narrower tolerance, tighter on the
// smaller numbers.
nearK(int n) =>
    int best = 0
    int bd   = 999
    for i = 0 to array.size(KNUM) - 1
        int k = array.get(KNUM, i)
        int tol = k <= 33 ? 1 : 2
        int d = math.abs(n - k)
        if d <= tol and d < bd
            bd   := d
            best := k
    best

kHi = nearKt(barsHi, kTol)
kLo = nearKt(barsLo, kTol)

// ================================================================ Time theory
// Counts bars elapsed since the most recent swing origin and flags the count
// against the classical time numbers (9, 17, 26, 33, 42, 65, 76). It also keeps
// the length of up to the last 10 completed swing legs and checks whether the
// leg currently forming matches one of them within 1 bar. The source text's
// worked example does exactly this across non-adjacent swings (e.g. one leg
// lasting 33 bars, a later and separate leg lasting a "corresponding" 34); this
// is a bounded version of that idea, limited to the last 10 legs rather than
// the full chart history.
//
// The logic is the same whichever timeframe is measured; only htf changes.
// Chart gives the Chapter 2 reading, Higher the Chapter 7 simplified method.
//
// request.security includes the still-forming bar, so elapsed and matched can
// change until that bar closes, the same caveat that applies to the other
// pivot-based readings in this script.
htfSwing() =>
    var float q0   = na
    var int   qb0  = na
    var int   qb1  = na
    var int   qt0  = 0
    var int   qtm  = na   // time of the current swing point, for chart marks
    var int   qdur = 0    // length of the most recently completed leg
    var int[] durs = array.new_int()

    ph2 = ta.pivothigh(high, hPivL, hPivL)
    pl2 = ta.pivotlow(low, hPivL, hPivL)

    if not na(ph2)
        if qt0 == 1
            if ph2 > q0
                q0  := ph2
                qb0 := bar_index - hPivL
                qtm := time[hPivL]
        else
            qb1 := qb0
            q0  := ph2
            qb0 := bar_index - hPivL
            qtm := time[hPivL]
            qt0 := 1
            if not na(qb1)
                qdur := qb0 - qb1 + (incTdy ? 1 : 0)
                array.push(durs, qdur)
                if array.size(durs) > 10
                    array.shift(durs)

    if not na(pl2)
        if qt0 == -1
            if pl2 < q0
                q0  := pl2
                qb0 := bar_index - hPivL
                qtm := time[hPivL]
        else
            qb1 := qb0
            q0  := pl2
            qb0 := bar_index - hPivL
            qtm := time[hPivL]
            qt0 := -1
            if not na(qb1)
                qdur := qb0 - qb1 + (incTdy ? 1 : 0)
                array.push(durs, qdur)
                if array.size(durs) > 10
                    array.shift(durs)

    // The original counts inclusively, treating the origin bar as period 1. A
    // plain difference makes the origin period 0, so a classical number of 9
    // would land on the tenth bar from the origin. This follows the same
    // setting that governs the 25-bar displacement, keeping the two in step.
    int incT = incTdy ? 1 : 0
    int elapsed = na(qb0) ? na : bar_index - qb0 + incT

    int matched = 0
    int nextDur = 0
    if not na(elapsed) and elapsed >= minDur and array.size(durs) > 0
        for i = 0 to array.size(durs) - 1
            int d = array.get(durs, i)
            if d >= minDur and math.abs(d - elapsed) <= 1
                matched := d
            if d >= minDur and d > elapsed and (nextDur == 0 or d < nextDur)
                nextDur := d

    [elapsed, matched, nextDur, q0, qtm, qt0, qdur]

[hElapsed, hMatched, hNextDur, hSwPx, hSwTm, hSwDir, hSwDur] = request.security(syminfo.tickerid, htf, htfSwing(), lookahead=barmerge.lookahead_off)

// Classical numbers below this are skipped. 9 and 17 are short enough that
// nearly every leg passes through them, so including them turns the drawing
// into a row of ruler marks rather than a reading.
mBas = int(str.tonumber(minBaS))

hK0 = na(hElapsed) ? 0 : nearK(hElapsed)
hK  = hK0 >= mBas ? hK0 : 0

// -------------------------------------------------------- Forecast lines
// One vertical line for the next classical time number and one for the next
// matching historical duration. The remaining bars are converted to seconds
// via timeframe.in_seconds() and each line is placed at that future calendar
// time using xloc.bar_time.
nextBasic(int e) =>
    int r = 0
    for i = 0 to array.size(KNUM) - 1
        int k = array.get(KNUM, i)
        if k >= mBas and e < k
            r := k
            break
    r

nB = na(hElapsed) ? 0 : nextBasic(hElapsed)
remainK   = na(hElapsed) or nB == 0        ? na : nB - hElapsed
remainDur = na(hElapsed) or hNextDur == 0  ? na : hNextDur - hElapsed

htfSec   = timeframe.in_seconds(htf) * 1000
futTimeK = na(remainK)   ? na : time_close + remainK   * htfSec
futTimeD = na(remainDur) ? na : time_close + remainDur * htfSec

// Whether both reasons point at a similar time. With onlyBoth set, lines are
// drawn only when this holds; far fewer remain, and those that do mark places
// where a classical number and a duration match coincide.
bothNear = not na(remainK) and not na(remainDur) and math.abs(remainK - remainDur) <= bothTol
showK    = not onlyBoth or bothNear
showD    = not onlyBoth or bothNear

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

// -------------------------------------------------------- Confirmed pattern log
// A "kata-fu" streak keeps changing every bar while it is still running, so it
// can only be treated as confirmed once it breaks. The log updates every bar
// while the streak is at or above tier 5 (kfLen >= 5), and simply stops
// updating once it breaks, freezing at the last value until the next streak
// reaches tier 5. Interposed patterns are evaluated within a single day's
// window, so they are logged the day they occur.
kfPrecondNow = kfLen >= 5 ? kfPrecond(kfLen - 1, kfDir) : false

var int    kfLogBar = na
var int    kfLogDir = 0
var string kfLogTxt = ""
var color  kfLogCol = cOff

if kfLen >= 5
    kfLogBar := bar_index
    kfLogDir := kfDir
    kfLogCol := kfDir == 1 ? cOn : cDn
    kfLogTxt := (kfOrderlyOK ? "Orderly " : "Disorderly ") + kfTierName(kfLen, kfDir) + "  (" + str.tostring(kfLen) + ")  range " + str.tostring(kfRangePct, "#.#") + "%" + (kfPrecondNow ? "  prior move ok" : "")

var int    ipLogBar = na
var int    ipLogDir = 0
var string ipLogTxt = ""

if ipW > 0
    ipLogBar := bar_index
    ipLogDir := ipDir
    ipLogTxt := ipName + "  (" + str.tostring(ipW) + ")" + (ipPre ? "  prior move ok" : "")

// ---------------------------------------------------------------- Alert logic
// A streak stays at kfLen >= 5 for as long as it runs, so alerting every bar
// would fire continuously. Only the moment a tier is reached counts, giving
// one alert per tier.
kfTier   = kfLen >= 9 ? 9 : kfLen >= 7 ? 7 : kfLen >= 5 ? 5 : 0
alMinT   = alTier == "9 or more" ? 9 : alTier == "7 or more" ? 7 : 5
kfTierUp = kfTier > nz(kfTier[1], 0) and kfTier >= alMinT

kfDirOK  = (kfDir == 1 and alBull) or (kfDir == -1 and alBear)
kfOrdOK  = not alOrd or kfOrderlyOK
kfPreOK  = not alPre or kfPrecondNow
kfAlert  = kfTierUp and kfDirOK and kfOrdOK and kfPreOK

// An interposed pattern resolves within a single day's window, so it alerts on
// the day it completes. A change of window size (6/8/11) counts as a new one.
ipNew    = ipW > 0 and ipW != nz(ipW[1], 0)
ipDirOK  = (ipDir == 1 and alBull) or (ipDir == -1 and alBear)
ipPreOK  = not alPre or ipPre
ipAlert  = alIp and ipNew and ipDirOK and ipPreOK

if alOn and kfAlert
    alert(syminfo.ticker + " " + timeframe.period + "  " + (kfOrderlyOK ? "Orderly " : "Disorderly ") + kfTierName(kfLen, kfDir) + "  (" + str.tostring(kfLen) + ")  range " + str.tostring(kfRangePct, "#.#") + "%" + (kfPrecondNow ? "  prior move ok" : ""), alert.freq_once_per_bar_close)

if alOn and ipAlert
    alert(syminfo.ticker + " " + timeframe.period + "  " + ipName + "  (" + str.tostring(ipW) + ")" + (ipPre ? "  prior move ok" : ""), alert.freq_once_per_bar_close)

// Dropdown route. The message is fixed text, but the condition can be picked
// directly in the alert dialog. Use either this or the alert() route, not both.
alertcondition(kfAlert, "Kata-fu streak formed",     "Kata-fu: a streak has formed")
alertcondition(ipAlert, "Interposed pattern formed", "Kata-fu: an interposed pattern has formed")

kfBarsAgo = na(kfLogBar) ? na : bar_index - kfLogBar
ipBarsAgo = na(ipLogBar) ? na : bar_index - ipLogBar

agoTxt(int n) => n == 0 ? "current" : str.tostring(n) + " bars ago"
mkDir(int dir) => dir == 1 ? "△" : dir == -1 ? "▽" : "-"

// ============================================================= Panel strings
f(float v) => str.tostring(v, format.mintick)

sDev = str.tostring((close - conv) / conv * 100, "#.##") + "%"
sDevB= str.tostring((close - baseL) / baseL * 100, "#.##") + "%"
// A two-state row reports "Below" or "Bearish" when the two values are simply
// equal, which then contradicts the sanyaku test, since that uses a strict
// comparison. When the 9-bar and 26-bar windows share the same high and low the
// Tenkan and Kijun coincide exactly, which happens in practice after a sharp
// move. Equality is therefore shown as its own state.
udTx(int st) => st == 1 ? "Above" : st == -1 ? "Below" : "Equal"
gxTx(int st) => st == 1 ? "Bullish" : st == -1 ? "Bearish" : "Equal"

t1   = udTx(stPC) + "  dev " + sDev
t1b  = udTx(stPB) + "  dev " + sDevB

// A gradient scale showing which way the conditions lean. Fifteen segments,
// neutral yellow at the centre, deepening to red towards the left and green
// towards the right. Only the current position is drawn at full opacity; the
// rest is faded. It is a scale of where things stand, not a verdict.
cBarLo = isDark ? #E53935 : #C62828
cBarMd = isDark ? #FFD54F : #F9A825
cBarHi = isDark ? #43A047 : #2E7D32

segCol(int i) =>
    i <= 7 ? color.from_gradient(i, 0, 7, cBarLo, cBarMd) : color.from_gradient(i, 7, 14, cBarMd, cBarHi)
rngTx(float lo, float hi) => not showRng or na(lo) or na(hi) ? "" : "  [" + f(lo) + "-" + f(hi) + "]"

t2   = gxTx(stCB) + "  " + str.tostring(n2) + " bars" + (flipN > 0 ? "  -> " + flipTx + " in " + str.tostring(flipN) + rngTx(okLo, okHi) : "")
t3   = gxTx(stLP) + "  " + str.tostring(n3) + " bars"
t4   = close > lagTop ? "Above cloud" : close < lagBot ? "Below cloud" : "Inside cloud - capped by resistance"
t5   = close > cloudTop ? "Above cloud" : close < cloudBot ? "Below cloud" : "Inside cloud"
t6   = g6 ? "Rising" : baseL < baseL[1] ? "Falling" : "Flat  " + str.tostring(flatN) + " bars"

arw(float pv, float cur) => na(pv) ? "" : pv > cur ? "UP " : pv < cur ? "DN " : "-- "
t7   = na(vConv) ? "n/a" : "in " + str.tostring(nConv) + " bars  " + arw(vConv, conv)  + f(vConv) + rngTx(loConv, hiConv)
t8   = na(vBase) ? "n/a" : "in " + str.tostring(nBase) + " bars  " + arw(vBase, baseL) + f(vBase) + rngTx(loBase, hiBase)
t9   = twistIn > 0 ? "in " + str.tostring(twistIn) + " bars" : "none within range"
kTx(int n, int k) => k == 0 ? "" : " (" + str.tostring(k) + (n == k ? "" : (n > k ? "+" : "-") + str.tostring(math.abs(n - k))) + ")"
t10  = "high " + str.tostring(barsHi) + kTx(barsHi, kHi) + "  /  low " + str.tostring(barsLo) + kTx(barsLo, kLo)
// The classical "sanyaku" reading.
//
// Bullish is Tenkan above Kijun, the Chikou Span above price, and price above
// the cloud, all holding at once. Bearish is all three holding in the other
// direction.
//
// The bearish case must not be written as the negation of the bullish one. Not
// above the cloud includes being inside it, which would report a bearish
// sanyaku while price still sits within the cloud, and the other two would pick
// up equality as well. The bearish side is therefore stated explicitly.
// The definition in common circulation adds a condition to the Tenkan-Kijun
// comparison: the Kijun must be flat or rising for the bullish reading, flat or
// falling for the bearish one. In effect the Kijun must not point the other way.
//
// What to do when the two lines are exactly equal is not addressed by the
// original or by the common definition, so the handling here is a judgement of
// my own. Equality arises when the 9-bar and 26-bar windows share the same high
// and low, that is, just after a move sharp enough for the last nine bars to
// have made the whole 26-bar range. If the Kijun has a direction at that point,
// the reading follows it; if the Kijun is also flat there is nothing left to
// decide the direction, so no sanyaku is reported.
tkB   = stCB == 1 or (stCB == 0 and stKJ == 1)    // bullish Tenkan condition
tkS   = stCB == -1 or (stCB == 0 and stKJ == -1)  // bearish Tenkan condition

sanB  = tkB and close > close[disp] and close > cloudTop and stKJ >= 0
sanS  = tkS and close < close[disp] and close < cloudBot and stKJ <= 0
sanTx = sanB ? "   Sanyaku bullish" : sanS ? "   Sanyaku bearish" : ""
sanCol= sanB ? cOn : sanS ? cDn : cEmph

t11  = not okABC ? "detecting" : (bull ? "Up" : "Down") + (useL ? "" : "  (prev)") + (broken ? "  (A broken)" : "") + "   A " + f(A) + " > B " + f(B) + " > C " + f(C)

t12 = na(kfLogBar) ? "none yet" : agoTxt(kfBarsAgo) + "  " + kfLogTxt
t13 = na(ipLogBar) ? "none yet" : agoTxt(ipBarsAgo) + "  " + ipLogTxt

t14 = na(hElapsed) ? "detecting" : str.tostring(hElapsed) + " bars (" + htf + ") since swing" + (hK > 0 ? "  near " + str.tostring(hK) : "") + (hMatched > 0 ? "  matches a prior " + str.tostring(hMatched) + "-bar leg" : "")

// ==================================================================== Panel
tPos = posStr == "Top right" ? position.top_right : posStr == "Bottom right" ? position.bottom_right : posStr == "Top left" ? position.top_left : position.bottom_left

// The colour bar needs a different colour per cell, so the table is built with
// fifteen columns. Every other row merges them back into the usual three
// columns: label, value and mark.
// Row 0 places the colour bar and the count side by side, so the table carries
// five more columns beyond the fifteen the bar needs. The data rows merge them
// back into the usual three columns.
// Column widths: when a merged cell needs more width than its columns provide,
// the surplus is added to the LAST column of the merge. With the label merged
// over columns 0-5, column 5 alone widened and one bar segment looked fat. The
// label now spans columns 0-15, so the surplus lands in column 15, outside the
// bar, and the fifteen segments stay equal.
// Cols 0-14: bar / 15: buffer / 16-19: value / 20: mark
NSEG  = 15   // bar segments (columns 0-14)
NCOL  = 21   // total columns
C_LBL = 0
C_VAL = 16
C_MRK = 20

var bool merged = false
// border_width is a table-level setting and cannot vary per cell. Setting it to
// zero lets the fifteen bar cells read as one continuous strip; the rows still
// separate well enough on background colour alone.
var table t = table.new(tPos, NCOL, 16, bgcolor=cBg, border_width=0, frame_width=1, frame_color=cFrame, border_color=cFrame)

// Three-state row: rising, falling, or neither (flat).
row3(int r, string k, string v, int st) =>
    table.cell(t, C_LBL, r, k, text_color=cLbl, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, C_VAL, r, v, text_color=cTxt, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, C_MRK, r, st == 1 ? "+" : st == -1 ? "-" : "=", text_color=st == 1 ? cOn : st == -1 ? cDn : cOff, text_size=tSizeS, bgcolor=cBg)

inf(int r, string k, string v, color vc) =>
    table.cell(t, C_LBL, r, k, text_color=cLbl, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, C_VAL, r, v, text_color=vc, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, C_MRK, r, "", bgcolor=cBg)

rowDir(int r, string k, string v, color mainCol, int dir, color markCol) =>
    table.cell(t, C_LBL, r, k, text_color=cLbl, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, C_VAL, r, v, text_color=mainCol, text_size=tSizeS, text_halign=text.align_left, bgcolor=cBg)
    table.cell(t, C_MRK, r, mkDir(dir), text_color=markCol, text_size=tSizeS, bgcolor=cBg)

if barstate.islast
    // Row 0 - the gradient scale on the left, the count and sanyaku on the right.
    // score runs -7 to +7 and maps one-to-one onto the 15 segments (0 = centre).
    int seg = math.max(math.min(score + SCRMAX, NSEG - 1), 0)
    for i = 0 to NSEG - 1
        table.cell(t, i, 0, " ", bgcolor=i == seg ? segCol(i) : color.from_gradient(72, 0, 100, segCol(i), cBg), text_size=size.tiny)
    table.cell(t, NSEG, 0, (score > 0 ? "+" : "") + str.tostring(score) + sanTx, text_color=sanB or sanS ? sanCol : cEmph, text_size=tSizeL, text_halign=text.align_right, bgcolor=cHdr)

    row3(1, "Price - Tenkan",  t1,  stPC)
    row3(2, "Price - Kijun",   t1b, stPB)
    row3(3, "Tenkan - Kijun",  t2,  stCB)
    row3(4, "Chikou - Price",  t3,  stLP)
    row3(5, "Chikou - Kumo",  t4, stLK)
    row3(6, "Price - Kumo",   t5, stPK)
    row3(7, "Kijun slope",    t6, stKJ)

    inf(8,  "Proj Tenkan", t7,  cInfo)
    inf(9,  "Proj Kijun",  t8,  cInfo)
    inf(10, "Kumo twist",  t9,  twistIn > 0 ? cInfo : cOff)
    inf(11, "Bars since",  t10, (kHi > 0 or kLo > 0) ? cInfo : cTxt)
    inf(12, "Wave",        t11, not okABC or broken ? cOff : cTgt)

    rowDir(13, "Kata-fu",    t12, na(kfLogBar) ? cOff : cTxt, kfLogDir, na(kfLogBar) ? cOff : kfLogCol)
    rowDir(14, "Interposed", t13, na(ipLogBar) ? cOff : cTxt, ipLogDir, na(ipLogBar) ? cOff : (ipDir == 1 ? cOn : cDn))

    inf(15, "Time",        t14, (hK > 0 or hMatched > 0) ? cInfo : cTxt)

    // Merge once only; merging cells that are already merged raises an error.
    if not merged
        table.merge_cells(t, NSEG, 0, NCOL - 1, 0)
        for r = 1 to 15
            table.merge_cells(t, C_LBL, r, C_VAL - 1, r)
            table.merge_cells(t, C_VAL, r, C_MRK - 1, r)
        merged := true

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

// =============================================================== Forecast lines
// One line for the next classical time number and one for the next matching
// historical duration, drawn with different styles and colors. When the two
// land close together, the timing has two independent reasons behind it.
cFutK = cInfo                       // classical time number - dashed
cFutD = isDark ? #7FB3FF : #15559A  // matching duration - dotted

var line  lnFutK = line.new(time, close, time, close, xloc=xloc.bar_time, extend=extend.both, color=#00000000, style=line.style_dashed)
var label lbFutK = label.new(time, close, "", xloc=xloc.bar_time, style=label.style_label_down, color=#00000000, textcolor=#00000000, size=tSizeS)
var line  lnFutD = line.new(time, close, time, close, xloc=xloc.bar_time, extend=extend.both, color=#00000000, style=line.style_dotted)
var label lbFutD = label.new(time, close, "", xloc=xloc.bar_time, style=label.style_label_down, color=#00000000, textcolor=#00000000, size=tSizeS)

updFut(line L, label T, int ft, string tag, int remain, color col, float y) =>
    if showFut and not na(ft)
        line.set_xy1(L, ft, close)
        line.set_xy2(L, ft, close + syminfo.mintick)
        line.set_color(L, col)
        label.set_xy(T, ft, y)
        label.set_text(T, tag + "  (" + str.tostring(remain) + " out)")
        label.set_textcolor(T, col)
    else
        line.set_color(L, #00000000)
        label.set_text(T, "")
        label.set_textcolor(T, #00000000)

futTop = ta.highest(high, 60)
updFut(lnFutK, lbFutK, showK ? futTimeK : na, htf + " basic " + str.tostring(nB),        remainK,   cFutK, futTop * 1.010)
updFut(lnFutD, lbFutD, showD ? futTimeD : na, htf + " matches " + str.tostring(hNextDur), remainDur, cFutD, futTop * 1.035)

// ------------------------------------------------ Past confirmations (review)
// The forecast lines are recomputed every bar and move as they go, so they
// cannot themselves serve as a record. Instead, the moment a forecast time
// number is actually reached is captured and frozen as a faded vertical line
// at that position: for the classical numbers, when elapsed bars hit 9, 17,
// 26 and so on; for durations, when the leg being formed matches a past one.
//
// nB holds the next classical number still ahead, so an increase in nB means
// the previous target has just been reached. A swing reset makes nB fall
// instead, which is why only an increase counts as an arrival.
prevNB   = nz(nB[1], 0)
arrivedK = prevNB > 0 and nB > prevNB
arrivedD = hMatched > 0 and nz(hMatched[1], 0) == 0

var line[]  archLn = array.new_line()
var label[] archLb = array.new_label()

pushArch(int tt, string tag, color col, string st, float y) =>
    if archN > 0
        array.push(archLn, line.new(tt, close, tt, close + syminfo.mintick, xloc=xloc.bar_time, extend=extend.both, color=color.new(col, archTr), style=st))
        array.push(archLb, label.new(tt, y, tag, xloc=xloc.bar_time, style=label.style_label_down, color=#00000000, textcolor=color.new(col, archTr), size=size.tiny))
        while array.size(archLn) > archN
            line.delete(array.shift(archLn))
            label.delete(array.shift(archLb))

// With onlyBoth set, the test is whether the other reason was also close to
// the target just reached. Both nB and hNextDur point to what is still ahead,
// so at the moment of arrival both have already moved on to the next target;
// the check therefore uses the previous bar's remaining counts.
bothNearPrev = not na(remainK[1]) and not na(remainDur[1]) and math.abs(remainK[1] - remainDur[1]) <= bothTol
archOK = not onlyBoth or bothNearPrev

// Gating on barstate.isconfirmed avoids leaving a line behind when a reading
// appears on a forming bar and is then withdrawn before that bar closes.
if showFut and barstate.isconfirmed and archOK
    if arrivedK
        pushArch(time, str.tostring(prevNB), cFutK, line.style_dashed, futTop * 1.010)
    if arrivedD
        pushArch(time, "=" + str.tostring(hMatched), cFutD, line.style_dotted, futTop * 1.035)

// ------------------------------------------------- Swing marks (for checking)
// Marks the points the time module treats as wave origins, with the length of
// the leg that ended there. This exists so the sensitivity setting can be
// checked against your own reading of the chart; it has no counterpart in the
// source text. A new swing adds a mark; a same-direction extension moves the
// last one, matching the rule that consecutive same-kind pivots are merged.
var label[] swLb = array.new_label()

if showSw and barstate.isconfirmed and not na(hSwTm) and not na(hSwPx)
    bool isNewSw = hSwDir != nz(hSwDir[1], 0)
    bool movedSw = hSwTm != nz(hSwTm[1], 0)
    if isNewSw
        string txt = hSwDur > 0 ? str.tostring(hSwDur) : ""
        array.push(swLb, label.new(hSwTm, hSwPx, txt, xloc=xloc.bar_time, style=hSwDir == 1 ? label.style_label_down : label.style_label_up, color=color.new(cLbl, 60), textcolor=cTxt, size=size.tiny))
        while array.size(swLb) > swN
            label.delete(array.shift(swLb))
    else if movedSw and array.size(swLb) > 0
        label lastSw = array.get(swLb, array.size(swLb) - 1)
        label.set_xy(lastSw, hSwTm, hSwPx)

// ========================================================== Ichimoku drawing
pA = plot(showI ? spanA : na, "Senkou Span A (Leading Span A)", color=color.new(#26A69A, 45), offset=disp)
pB = plot(showI ? spanB : na, "Senkou Span B (Leading Span B)", color=sbOn ? color.new(#EF5350, 0) : color.new(#EF5350, 45), offset=disp)
fill(pA, pB, title="Cloud (Kumo)", color=spanA > spanB ? color.new(#26A69A, 90) : color.new(#EF5350, 90))
plot(showI ? conv  : na, "Tenkan-sen (Conversion Line)",  color=#3D8BFD)
plot(showI ? baseL : na, "Kijun-sen (Base Line)",   color=#FF8C42)
plot(showI ? close : na, "Chikou Span (Lagging Span)", color=color.new(#9C6ADE, 20), offset=-disp)

// ============================================================== Data window
plot(score,   "Bullish score (-7 to +7)", display=display.data_window)
// Sanyaku: 1 = bullish, -1 = bearish, 0 = neither
plot(sanB ? 1 : sanS ? -1 : 0, "Sanyaku (1 bull / -1 bear)", display=display.data_window)
plot(nConv,   "Proj Tenkan bars", display=display.data_window)
plot(vConv,   "Proj Tenkan value",display=display.data_window)
plot(nBase,   "Proj Kijun bars",  display=display.data_window)
plot(vBase,   "Proj Kijun value", display=display.data_window)
plot(twistIn, "Twist in bars",    display=display.data_window)

// Time theory values. With no lines drawn on the chart, moving the cursor back
// through history still shows the elapsed count, the next classical number and
// any duration match for each bar. This is the way to review the readings
// without turning the past confirmation lines on.
plot(hElapsed,  "Time elapsed",      display=display.data_window)
plot(nB,        "Next basic number", display=display.data_window)
plot(remainK,   "Bars to basic",     display=display.data_window)
plot(hMatched,  "Duration match",    display=display.data_window)
plot(hNextDur,  "Next duration",     display=display.data_window)
plot(remainDur, "Bars to duration",  display=display.data_window)
plot(hSwDur,    "Last leg length",   display=display.data_window)
plot(A,       "Wave A", display=display.data_window)
plot(B,       "Wave B", display=display.data_window)
plot(C,       "Wave C", display=display.data_window)

// ============================================================= Runtime notes
// Drawing objects convert x coordinates to timestamps internally, so the time
// buffer must be large enough for the target line anchor.
max_bars_back(time, 300)
````
