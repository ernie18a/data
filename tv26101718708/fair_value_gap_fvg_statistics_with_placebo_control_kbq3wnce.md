# Fair Value Gap (FVG) Statistics with Placebo Control

- url: https://www.tradingview.com/script/Kbq3WncE-Fair-Value-Gap-FVG-Statistics-with-Placebo-Control/
- type: indicator
- pine_id: PUB;e1dce617ffeb43d39ccc38ea9a7abf18
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

On the same instrument, measured against a 50% baseline, fair value gaps looked significantly profitable in one period and significantly unprofitable in another. Both readings were artifacts of a baseline that was never 50%.

This indicator measures what actually happens after price returns to a gap, then compares the result against fake, or placebo, zones of the same size placed at bars where no gap occurred. Because a hit rate tells you nothing until you know what a meaningless zone scores on the same chart.

[b]The following description consists of two parts. Part 1 is written in plain English and covers everything most readers need. Part 2 contains the full methodology and results for anyone who wants to examine the numbers in detail.[/b]

═══════════════════════════════════════
[b]PART 1 — WHAT THIS IS AND WHY[/b]
═══════════════════════════════════════

█ [b]THE PROBLEM[/b]

Zone-based tools are everywhere: fair value gaps, order blocks, breakers, imbalances. Yet almost none of them tell you how often a zone actually led anywhere. And when a number is quoted, it is often built on one of three flawed foundations.

[b]1. The zone is counted before it could have been known.[/b]

This problem is easiest to see with order blocks. An order block is commonly defined as the last opposite candle before a move that breaks structure. That means the block cannot be identified until the structure break occurs, often several bars later. Yet it is drawn back on the earlier candle as though it had been known at the time.

Any hit rate measured from that earlier candle therefore counts a zone that nobody could actually have traded.

Fair value gaps suffer less from this problem because their three-bar pattern completes quickly, but the same principle applies: a zone becomes active only when it becomes knowable, and nothing before that bar should be counted.

[b]2. Failed zones disappear.[/b]

Many tools remove a zone from the chart once price has passed through it. That makes sense for keeping a chart clean. It is disastrous for statistics, because the zones being removed are disproportionately the ones that failed.

Count only what remains on the chart and you are counting the survivors.

[b]3. The hit rate is compared with 50%.[/b]

This is the most important problem, and it is extremely common.

The reasoning seems straightforward: if the target and stop are equally far from the entry, then no edge should mean a 50/50 outcome.

But a rule that enters when price [i]reaches a level[/i] inherits a baseline from the way price moves. That baseline is not necessarily 50%. It changes with the instrument, direction, and market conditions. Across the three markets tested here, it ranged from roughly 45% to 55%.

A hit rate by itself therefore tells you very little.

What matters is how the same measurement performs on zones that have no informational meaning at all.

█ [b]WHAT THIS INDICATOR DOES[/b]

For every real fair value gap the indicator identifies, it also generates placebo zones of the same height, direction, and distance from price, anchored at bars where no fair value gap occurred.

Real and placebo zones are then measured by exactly the same rules.

The difference between them — [b]real minus placebo[/b] — is the result that matters.

If real gaps perform like the placebo zones, then the pattern is not adding anything, regardless of how attractive the raw hit rate may look.

The placebo comparison does not ask whether fair value gaps win more than 50% of the time.

It asks a harder question:

[quote]Do fair value gaps perform better than comparable zones that carry no fair value gap information at all?[/quote]

█ [b]HOW THE COMPARISON IS KEPT FAIR[/b]

Statistical libraries for Pine already exist, and many indicators will draw fair value gaps. What is not otherwise available is a matched control built into the measurement itself, so that every figure the indicator reports arrives together with the baseline it should be judged against.

Three design choices make that possible, and they only work together.

[b]A matched placebo control.[/b] Each placebo zone has the same height, the same direction, and the same distance from price as the real zone it is meant to compare with. Both are scored by identical rules.

[b]Confirmation-honest timing.[/b] A zone enters the sample only when it becomes knowable, never earlier. Every confirmed zone remains in the sample from that point onward, including zones that fail immediately.

[b]Bias controls that are reported rather than hidden.[/b] Cases that are genuinely difficult to score — such as bars that touch both exits and trades that never resolve — are counted and displayed for real and placebo zones side by side. Ambiguous cases are treated conservatively rather than silently discarded.

The combination matters. A matched control is useful only if both sides are measured under the same timing and scoring rules.

█ [b]WHAT THE TESTS FOUND[/b]

Across three asset classes, three timeframes, and two separate periods — fourteen measurements in total — fair value gaps showed no detectable advantage over size-matched zones placed at meaningless bars.

The difference remained below about one percentage point of hit rate, and none of the fourteen individual measurements reached conventional statistical significance.

That is a bound on what was observed, not a claim that the true effect is exactly zero.

A different market or a different period could produce a different result. That is precisely why the comparison is built into the tool rather than left as an assumption or a footnote.

The broader conclusion is more useful:

[quote]A hit rate quoted without its baseline does not tell you whether something works. On the same instrument, measured against 50%, this pattern looked significantly profitable in one period and significantly unprofitable in another. Both readings were created by the baseline, not by the gaps.[/quote]

That lesson applies to zone-based tools generally, not only to fair value gaps.

If you take one thing from this script, take that.

█ [b]HOW IT WAS TESTED[/b]

A single result on a single chart is easy to produce and easy to overinterpret. Before publication, the same measurement was therefore repeated while changing one assumption at a time.

[list]
[*]Three asset classes — crypto, currencies, and equity index futures
[*]Three timeframes — 5 minutes, 30 minutes, and 1 hour
[*]Two separate, non-overlapping time periods
[*]Three different target and stop distances
[*]Two different limits on how long a trade could remain open
[/list]

Each of these choices is partly arbitrary. If a finding appears only under one particular setting, it may belong to the setting rather than to the market.

Fourteen separate measurements were made in total.

Two standard statistical tools are used. A confidence interval shows the range in which the underlying value plausibly lies, which is more informative than a single headline estimate. Results from independent markets are also combined so that their evidence can be considered together rather than one chart at a time.

The measurement procedure was additionally checked against artificial data for which the correct answer was known in advance. This allowed the method itself to be tested independently of any market result.

█ [b]HOW TO READ AND USE THE INDICATOR[/b]

Add the indicator to any chart. It works on any symbol and any timeframe and needs no configuration to produce a result.

[b]The panel[/b]

By default, the panel shows a compact view: the number of zones found, the number revisited by price, the hit rate with its confidence interval, the placebo baseline, and the difference between real and placebo.

Turn off [i]Compact panel[/i] for the full breakdown: wins, losses, unresolved cases, the direction split, and side-by-side rates for the cases that are hardest to score.

Everything used to produce the headline result is available for inspection.

[b]Reading the result[/b]

Check the sample size first. Below roughly 1000 resolved zones, the confidence interval is usually too wide to conclude much. Recognizing that the sample is inconclusive is a valid result, not a failure of the indicator. Lower timeframes and longer histories both increase the sample.

Then read [b]real − placebo[/b]. That is the headline result.

A positive number means the gaps outperformed the placebo zones. A negative number means they underperformed them.

The z-score beside it indicates how far the observed difference sits from what chance alone can produce. As a rough guide, an absolute z-score below 2 is not conventionally distinguishable from noise.

The raw hit rate is shown for context, not as the answer. Judging the pattern from that number alone is the mistake this indicator is designed to expose.

[b]Setting up a measurement[/b]

To measure a specific period, turn on [i]Limit to date range[/i] and set the dates.

The panel reports the sample actually achieved. This can be shorter than the requested period if the chart has not loaded enough historical data, so scroll left when necessary to load more history.

To check whether a result depends on your choice of exits, change [i]Barrier size[/i] and run the measurement again. A finding that appears only at one setting may belong to the setting rather than to the pattern.

[b]As a chart indicator[/b]

Zones are drawn as they form and can also be used in the usual visual way.

A zone that price has not yet returned to is drawn solid and continues extending to the right while it remains open.

When price reaches the zone, the box stops extending and fades to a dotted outline. The width of a completed box therefore shows how long that gap survived before price returned to it, while the chart makes it easy to see which zones remain active.

Turning off [i]Draw real zones[/i] leaves only the statistics panel.

█ [b]SETTINGS[/b]

[b]Measurement[/b] — [i]Risk unit[/i] selects whether exit distance scales with ATR or with the zone's own height. [i]Barrier size[/i] sets that distance. [i]Time limit[/i] controls how many bars a trade may remain open before being recorded as unresolved.

[i]Entry price[/i] and [i]Evaluate exits on the entry bar[/i] provide alternative scoring conventions so their effect can be measured rather than assumed. Both are labeled where they introduce a known bias.

[i]Minimum zone height[/i] filters out small gaps. [i]Exclude overlapping zones[/i] and [i]Overlap lookback[/i] prevent several gaps created by the same move from being treated as independent observations.

[b]Sample[/b] — restricts the measurement to a date range, entered as year, month, and day so the sample remains reproducible.

[b]Placebo control[/b] — [i]Placebos per zone[/i] sets how many comparison zones each real zone generates; more placebos produce a tighter estimate of the baseline. [i]Placebo offset[/i] controls how far from the original bar the comparison zones are anchored.

[b]Validation[/b] — replaces market price with a random walk so the measurement can be checked against data whose correct answer is known in advance rather than only against real markets.

[b]Display[/b] — [i]Compact panel[/i] shows the headline rows only; turning it off reveals the full breakdown. [i]Draw real zones[/i] toggles the boxes on the chart.

═══════════════════════════════════════
[b]PART 2 — DETAILED ANALYSIS[/b]
═══════════════════════════════════════

█ [b]HOW A ZONE IS SCORED[/b]

A gap becomes active on the bar after its three-bar pattern closes. From that point onward, every confirmed zone remains in the sample, including zones that fail immediately.

When price returns to a zone, the entry is recorded at [b]that bar's close[/b], not at the zone edge.

This matters more than it may appear.

A touch condition means that price reached or passed the edge, so the bar may have overshot it by an unknown amount. Assuming a fill at the edge while beginning the measurement only from the following bar would start the trade from an artificial price and can systematically distort the result.

Two exits are then placed at equal distances on either side of the entry. Because the exits are symmetric, real and placebo zones can be compared directly.

If one bar touches both exits, its open, high, low, and close do not reveal which level was reached first. Those cases are shown separately and counted as losses, making the published result the conservative one.

Zones that reach neither exit within the time limit are excluded from the hit-rate calculation. They did not resolve, so they provide no evidence for either outcome.

█ [b]RESULTS[/b]

Results below use the following settings. The sample ends 1 August 2026.

[pine]
SETTING             VALUE

Risk unit (R)       ATR(14) at confirmation
Barrier             2.0 R each side
Time limit          100 bars after entry
Entry               close of the touch bar
Overlapping zones   excluded
Placebos per zone   3
[/pine]

Three markets, 30-minute charts, 2025-01-01 to 2026-08-01:

[pine]
INSTRUMENT    RAW    NAIVE z   PLACEBO   REAL-PLAC

BTCUSDT       49.5%   -0.67     49.0%    +0.5
EURUSD        51.4%   +1.65     51.7%    -0.2
ES1!          49.2%   -0.92     49.9%    -0.7

POOLED                                   -0.04
[/pine]

The panel on the chart above is not restricted to that fixed window — it runs to the most recent bar — so its figures differ slightly from the table. That is expected: it is a different sample, not a different result.

Read the raw column alone and the markets appear different: 49.5% for crypto versus 51.4% for currencies, a spread of 1.9 percentage points.

Now look at the placebo column. Its spread is 2.7 points.

The apparent difference between markets is therefore better explained by the baseline than by the fair value gaps themselves.

One example makes the problem especially clear:

[pine]
BTCUSDT, 1 hour, calendar year 2024
Raw hit rate         54.0%   (n = 1390)
Naive z vs 50%       +2.95   "significant"
Placebo baseline     51.5%
Real minus placebo   +2.5%   z 1.49, not sig.
[/pine]

Against an assumed 50% baseline, a 54% hit rate gives a p-value near 0.003 — exactly the kind of number that can look compelling when published in isolation.

Against its observed control baseline, however, the evidence is not statistically significant.

The same indicator, on the same instrument, over a different period and with a tighter target, produced a raw hit rate of 48.4% with a z-score of -2.25 — apparently significant in the [i]opposite[/i] direction.

Both apparent conclusions arise from comparing with an assumed 50% baseline rather than the observed control baseline.

█ [b]ROBUSTNESS[/b]

[pine]
DIMENSION       TESTED                RESULT

Barrier size    1R / 2R / 3R          no change
Time limit      50 / 100 bars         no change
Asset class     crypto / FX / index   no change
Timeframe       5m / 30m / 1h         no change
Period          2024 / 2025-26        no change
[/pine]

Across fourteen separate estimates of real minus placebo, the largest result was 1.49 standard errors from zero.

With fourteen estimates, even if the true effect were zero, the largest absolute result would be expected to reach roughly 1.9 standard errors by chance alone.

Pooled across three independent markets, the estimate was -0.04 percentage points, with a 95% interval of approximately -1.2 to +1.1 points.

█ [b]LIMITATIONS[/b]

One symbol and one timeframe can be analyzed per chart. Pine cannot pool results across markets, so each chart represents one sample rather than proof by itself. The pooled figures reported above were combined separately.

Trading costs are not included. Entries assume execution at the bar close with no spread, commission, or slippage. Real-world trading costs would make absolute performance worse.

Ambiguous bars are counted as losses. This lowers both real and placebo hit rates by roughly the ambiguous-case rate and therefore tends to cancel when the difference between them is calculated.

[b]The bull and bear rows should not be interpreted independently in a trending market.[/b]

The placebo control matches zone size, direction, and distance from price, but it cannot match the fact that a real gap forms immediately after a strong move in the same direction.

For example, in an uptrend, a fake bearish zone is more likely to be run over by the prevailing trend, whereas a real bearish gap can only form after an actual downward move. These effects work in opposite directions and largely cancel in the combined result.

For that reason, the total should be treated as the primary statistic rather than the directional split.

This limitation was identified during testing and is the main known weakness of the methodology.

Finally, all results come from a sample. Another market or another period may produce a different estimate. That uncertainty is the reason the placebo comparison is built into the indicator rather than assumed away.

█ [b]METHOD AND PRIOR WORK[/b]

None of the statistics here are new, and it is worth being clear about that.

Assigning a treatment to units or moments where it did not actually occur, then checking that no effect appears, is a standard falsification test in causal inference, where it is usually called a placebo test. The placebo zones in this indicator are that idea applied to bars instead of subjects.

The trading application is not new either. David Aronson's [i]Evidence-Based Technical Analysis[/i] (2006) argues that a rule should be judged against the returns of random entry signals rather than against zero, and uses Monte Carlo permutation and White's Reality Check to do it.

The scoring rule — a target, a stop, and a time limit, whichever is reached first — is the triple-barrier method described by Marcos López de Prado.

What this script adds is not the method but its availability. The control is generated and scored automatically alongside the real zones, on any chart and any symbol, so the baseline arrives together with the number instead of requiring a separate study that most people will never run.

█ [b]OPEN SOURCE[/b]

The source is open. Every figure above can be reproduced — or shown to be wrong — by anyone who wants to check it.

Order blocks are next, measured by the same rule: from the bar that breaks structure, not from the earlier candle on which the block is drawn.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Algolego

//@version=6
indicator("Fair Value Gap (FVG) Statistics with Placebo Control", "FVG Stats", overlay = true,
     max_bars_back = 5000, max_boxes_count = 500)

// =============================================================================
// Measures what actually happens after price returns to a fair value gap.
//
// Every zone is measured from the bar it became knowable on -- never earlier.
// Every confirmed zone is counted, including ones that fail immediately.
// Exits are evaluated from the bar AFTER entry: within the entry bar, OHLC
// cannot tell you whether the extreme came before or after the fill.
//
// The baseline for "no edge" is NOT 50%. Any rule that enters when price
// reaches a level inherits a baseline from path and drift. The placebo -- same
// size, same direction, same distance from price, anchored at bars where
// nothing happened -- measures that baseline. Real minus placebo is the
// statistic that matters.
//
// The fill price and the price measurement starts from must be the SAME price.
// A touch trigger fires on "low <= edge", not "low == edge", so the touch bar
// breaches the edge by an unknown amount. Filling at the edge but starting the
// barrier race on the next bar begins it already displaced toward the stop.
// Entering at the touch bar's close removes that displacement.
//
// SELF-TEST: on a driftless random walk, entry at a price with symmetric
// barriers resolves upward exactly 50% of the time (optional stopping theorem).
// Turn on Synthetic mode and both hit rates MUST bracket 50%, less about half
// the ambiguous rate. Anything else is a measurement bug, with no market
// interpretation available. Re-run this after every change to the measurement
// path.
// =============================================================================

// ---------------------------------------------------------------- inputs ----
grpM = "Measurement"
rMode   = input.string("ATR", "Risk unit (R)", options = ["ATR", "Zone height"], group = grpM)
atrLen  = input.int(14, "ATR length", minval = 1, group = grpM)
// Defaults match the settings the published results were measured with, so a
// reader who changes nothing reproduces the documented figures.
kR      = input.float(2.0, "Barrier size (R)", minval = 0.1, step = 0.1, group = grpM)
maxBars = input.int(100, "Time limit after entry (bars)", minval = 1, group = grpM)
entryMode = input.string("Bar close", "Entry price",
     options = ["Bar close", "Zone edge (biased)"], group = grpM)
entryBarExits = input.bool(false, "Evaluate exits on the entry bar (biased)", group = grpM)
minHgt  = input.float(0.0, "Minimum zone height (ATR)", minval = 0, step = 0.1, group = grpM)
dedupe  = input.bool(true, "Exclude overlapping same-direction zones", group = grpM)
dupWin  = input.int(20, "Overlap lookback (bars)", minval = 1, group = grpM)

// Explicit y/m/d rather than input.time: the date picker clamps to loaded data
// and silently reverts, which would make a published sample unreproducible.
grpR = "Sample"
useRange = input.bool(false, "Limit to date range", group = grpR)
startY = input.int(2025, "Start   year", minval = 1970, group = grpR, inline = "s")
startM = input.int(1,    "month", minval = 1, maxval = 12, group = grpR, inline = "s")
startD = input.int(1,    "day",   minval = 1, maxval = 31, group = grpR, inline = "s")
endY   = input.int(2026, "End     year", minval = 1970, group = grpR, inline = "e")
endM   = input.int(8,    "month", minval = 1, maxval = 12, group = grpR, inline = "e")
endD   = input.int(1,    "day",   minval = 1, maxval = 31, group = grpR, inline = "e")

startT = timestamp(startY, startM, startD, 0, 0)
endT   = timestamp(endY, endM, endD, 0, 0)

grpN = "Placebo control"
useNull = input.bool(true, "Run placebo control", group = grpN)
nPlac   = input.int(3, "Placebos per real zone", minval = 1, maxval = 10, group = grpN)
offBase = input.int(211, "Placebo offset (bars)", minval = 10, group = grpN)

grpS = "Validation (synthetic data)"
synth    = input.bool(false, "Replace price with a random walk", group = grpS)
synSeed  = input.int(12345, "Seed", group = grpS)
synVol   = input.float(1.0, "Sub-step size", minval = 0.01, step = 0.1, group = grpS)
synDrift = input.float(0.0, "Drift per bar (0 = driftless null)", step = 0.05, group = grpS)

grpD = "Display"
compact   = input.bool(true, "Compact panel", group = grpD)
showZones = input.bool(true, "Draw real zones", group = grpD)

// ------------------------------------------------------- synthetic series ---
// Four sub-steps per bar so synthetic bars carry a real intrabar path: the
// high and low are extremes of a walk, not decorations around the close. That
// matters because the bugs this test is built to catch all live in the
// relationship between a bar's extremes and its close.
var float synPrev = 10000.0

r1 = math.random(-1.0, 1.0, synSeed)
r2 = math.random(-1.0, 1.0, synSeed + 1)
r3 = math.random(-1.0, 1.0, synSeed + 2)
r4 = math.random(-1.0, 1.0, synSeed + 3)

d4     = synDrift / 4.0
sOpen  = synPrev
sp1    = sOpen + r1 * synVol + d4
sp2    = sp1   + r2 * synVol + d4
sp3    = sp2   + r3 * synVol + d4
sClose = sp3   + r4 * synVol + d4
sHigh  = math.max(math.max(sOpen, sp1), math.max(math.max(sp2, sp3), sClose))
sLow   = math.min(math.min(sOpen, sp1), math.min(math.min(sp2, sp3), sClose))

if synth
    synPrev := sClose

_high  = synth ? sHigh  : high
_low   = synth ? sLow   : low
_close = synth ? sClose : close

// True range from the routed series, so ATR is correct in both modes.
_tr = na(_close[1]) ? _high - _low :
     math.max(_high - _low, math.max(math.abs(_high - _close[1]), math.abs(_low - _close[1])))
atr = ta.rma(_tr, atrLen)

// ----------------------------------------------------------------- types ----
type Zone
    bool  isBull
    bool  isReal
    bool  isDup    = false
    int   confBar  = 0
    float top
    float bot
    float rUnit
    bool  touched  = false
    float entry    = na
    float target   = na
    float stopP    = na
    int   entryBar = na
    float mfe      = 0.0
    float mae      = 0.0
    int   outcome  = 0        // 0 pending, 1 target, 2 stop, 3 ambiguous, 4 censored
    box   bx       = na       // drawn zone, extended rightwards until touched

type Pending
    int   dueBar
    bool  isBull
    float heightAtr
    float standoffAtr

type Stats
    int nConf   = 0
    int nTouch  = 0
    int nTarget = 0
    int nStop   = 0
    int nAmbig  = 0
    int nCens   = 0
    float sumMfe = 0.0
    float sumMae = 0.0
    array<int> resBars

// ------------------------------------------------------------- functions ----
// All declarations live at global scope. Pine cannot declare a function
// inside an if/for block -- it parses it as a call and rejects the types.
newStats() => Stats.new(resBars = array.new<int>())

inRange  = not useRange or (time >= startT and time <= endT)
edgeMode = entryMode == "Zone edge (biased)"

var array<Zone>    active  = array.new<Zone>()
var array<Zone>    recentZ = array.new<Zone>()   // overlap cache, real zones
var array<Zone>    recentP = array.new<Zone>()   // overlap cache, placebos
var array<Pending> queued  = array.new<Pending>()
var array<Zone>    drawnZ  = array.new<Zone>()   // zones holding a live box
var Stats sReal    = newStats()
var Stats sPlac    = newStats()
var int   nConfRaw = 0
var int   nDup     = 0
var int   firstT   = na
var int   lastT    = na

// Diagnostics: a blank/empty Sample row is ambiguous between "the date inputs
// resolved wrong" and "the chart has no data that far back". These separate the
// two without guessing.
var int chartFirstT = na
var int nBarsAll    = 0
var int nBarsRange  = 0
if na(chartFirstT)
    chartFirstT := time
nBarsAll += 1

// Directional splits. Drift lifts long-side barrier hits and depresses
// short-side ones; a measurement bug inflates both in their own direction.
// Splitting the counts is what tells those two apart.
var int rBullT = 0
var int rBullD = 0
var int rBearT = 0
var int rBearD = 0
var int pBullT = 0
var int pBullD = 0
var int pBearT = 0
var int pBearD = 0

// Compare against every zone from the last dupWin bars, whatever its state.
// Comparing only against still-open zones misses almost everything when zones
// are touched immediately.
overlapsIn(array<Zone> arr, float t, float b, bool isBull) =>
    bool found = false
    for z in arr
        if z.isBull == isBull and t >= z.bot and b <= z.top
            found := true
    found

pruneTo(array<Zone> arr, int win) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            if bar_index - array.get(arr, i).confBar > win
                array.remove(arr, i)
    array.size(arr)

makeZone(bool isBull, float t, float b, bool isReal) =>
    unit = rMode == "ATR" ? atr : t - b
    Zone.new(isBull = isBull, isReal = isReal, top = t, bot = b, rUnit = unit,
         confBar = bar_index)

record(Stats s, Zone z) =>
    s.nTouch := s.nTouch + 1
    s.sumMfe := s.sumMfe + z.mfe
    s.sumMae := s.sumMae + z.mae
    if z.outcome == 1
        s.nTarget := s.nTarget + 1
    else if z.outcome == 2
        s.nStop := s.nStop + 1
    else if z.outcome == 3
        s.nAmbig := s.nAmbig + 1
    else if z.outcome == 4
        s.nCens := s.nCens + 1
    if z.outcome != 4
        array.push(s.resBars, bar_index - z.entryBar)

// Ambiguous bars count against the hit rate. Censored zones leave the
// denominator entirely -- they never resolved, so they are not evidence.
hitRate(Stats s) =>
    d = s.nTarget + s.nStop + s.nAmbig
    d > 0 ? float(s.nTarget) / d : na

hr2(int x, int n) => n > 0 ? float(x) / n : na

wilson(int x, int n) =>
    float lo = na
    float hi = na
    if n > 0
        zc = 1.96
        p  = float(x) / n
        c  = (p + zc * zc / (2 * n)) / (1 + zc * zc / n)
        h  = zc / (1 + zc * zc / n) * math.sqrt(p * (1 - p) / n + zc * zc / (4 * n * n))
        lo := c - h
        hi := c + h
    [lo, hi]

twoProp(int x1, int n1, int x2, int n2) =>
    float z = na
    if n1 > 0 and n2 > 0
        p  = float(x1 + x2) / (n1 + n2)
        se = math.sqrt(p * (1 - p) * (1.0 / n1 + 1.0 / n2))
        z := se > 0 ? (float(x1) / n1 - float(x2) / n2) / se : na
    z

// Theme-aware palette. chart.fg_color follows the viewer's light/dark setting,
// and the accents are mid-tone so they stay legible on either background --
// color.maroon in particular is almost invisible on a dark chart.
COL_TXT  = color.new(chart.fg_color, 35)   // row labels
COL_VAL  = chart.fg_color                  // neutral values
COL_UP   = #26A69A
COL_DOWN = #EF5350
COL_WARN = #FFA726

zoneCol(bool isBull) => isBull ? COL_UP : COL_DOWN

pct(float v) => na(v) ? "--" : str.tostring(v * 100, "#.#") + "%"
num(float v) => na(v) ? "--" : str.tostring(v, "#.##")
dat(int t) => na(t) ? "--" : str.format_time(t, "yyyy-MM-dd", syminfo.timezone)

var table tb = table.new(position.top_right, 2, 22, border_width = 1,
     frame_color = color.new(chart.fg_color, 65), frame_width = 1)

// Rows are queued rather than written at fixed indices, so compact mode can
// omit any of them without renumbering the rest.
var array<string> tk = array.new<string>()
var array<string> tv = array.new<string>()
var array<color>  tc = array.new<color>()

addRow(string k, string v, color c) =>
    array.push(tk, k)
    array.push(tv, v)
    array.push(tc, c)
    array.size(tk)

// ------------------------------------------------------- zone construction --
// Detection uses only closed bars. The 3-bar pattern completes on bar [1], so
// the zone becomes active here, on the bar after completion. Nothing repaints.
bullFvg = not na(_low[1]) and not na(_high[3]) and _low[1] > _high[3]
bearFvg = not na(_high[1]) and not na(_low[3]) and _high[1] < _low[3]

if inRange
    firstT := na(firstT) ? time : firstT
    lastT  := time
    nBarsRange += 1

if (bullFvg or bearFvg) and not na(atr) and atr > 0 and inRange
    isBull = bullFvg
    t = isBull ? _low[1]  : _low[3]
    b = isBull ? _high[3] : _high[1]

    if (t - b) / atr >= minHgt
        pruneTo(recentZ, dupWin)
        z = makeZone(isBull, t, b, true)
        z.isDup := dedupe and overlapsIn(recentZ, t, b, isBull)
        array.push(active, z)
        array.push(recentZ, z)

        nConfRaw += 1
        if z.isDup
            nDup += 1
        else
            sReal.nConf := sReal.nConf + 1

        // Open zones are drawn solid and keep extending. Once price reaches
        // one it freezes and fades to dotted, so the chart shows at a glance
        // what the script is tracking and how long each gap stayed open.
        if showZones and not synth and not z.isDup
            z.bx := box.new(bar_index, t, bar_index + 1, b,
                 border_color = color.new(zoneCol(isBull), 10),
                 bgcolor      = color.new(zoneCol(isBull), 70))
            // Retire the oldest box by hand, below Pine's 500-object limit, and
            // clear the owner's reference. An unfilled zone can then keep
            // extending for as long as it stays unfilled, with no time cap and
            // no risk of writing to a box that has already been discarded.
            array.push(drawnZ, z)
            if array.size(drawnZ) > 400
                old = array.shift(drawnZ)
                if not na(old.bx)
                    box.delete(old.bx)
                    old.bx := na

        // Matched placebos: same height, same standoff, same direction, but
        // anchored at a bar where no structural event occurred.
        if useNull and not z.isDup
            proximal = isBull ? t : b
            standoff = math.abs(_close - proximal) / atr
            height   = (t - b) / atr
            for k = 1 to nPlac
                array.push(queued, Pending.new(bar_index + offBase * k, isBull, height, standoff))

// -------------------------------------------------- placebo activation ------
if array.size(queued) > 0 and not na(atr[1]) and atr[1] > 0
    for i = array.size(queued) - 1 to 0
        p = array.get(queued, i)
        if bar_index >= p.dueBar
            // Anchor on the previous bar's close: the zone must be fully
            // defined before the bar we test for a touch, or the placebo
            // selects itself onto bars that moved its way late in the session.
            h  = p.heightAtr * atr[1]
            so = p.standoffAtr * atr[1]
            float t = na
            float b = na
            if p.isBull
                t := _close[1] - so
                b := t - h
            else
                b := _close[1] + so
                t := b + h
            if h > 0
                // Placebos get the same overlap treatment as real zones, or
                // the control is not matched and its interval is too narrow.
                pruneTo(recentP, dupWin)
                if not (dedupe and overlapsIn(recentP, t, b, p.isBull))
                    pz = makeZone(p.isBull, t, b, false)
                    array.push(active, pz)
                    array.push(recentP, pz)
                    sPlac.nConf := sPlac.nConf + 1
            array.remove(queued, i)

// ------------------------------------------------------------ evaluation ----
if array.size(active) > 0
    for i = array.size(active) - 1 to 0
        z = array.get(active, i)
        bool justEntered = false

        // Grow the drawn zone rightwards until price reaches it, which is how
        // these are normally displayed and also shows how long a gap stayed open.
        if showZones and not na(z.bx) and not z.touched
            box.set_right(z.bx, bar_index + 1)

        if not z.touched
            prox = z.isBull ? z.top : z.bot      // side price must come back to
            hit  = z.isBull ? _low <= prox : _high >= prox
            if hit
                z.touched  := true
                // Fill where measurement starts. The touch bar breached the
                // edge by an unknown amount, so anchoring the barriers at the
                // edge while starting the race on the next bar begins it
                // already displaced toward the stop -- a symmetric bias that
                // depresses both directions equally.
                z.entry    := edgeMode ? prox : _close
                z.entryBar := bar_index
                r = z.rUnit * kR
                z.target   := z.isBull ? z.entry + r : z.entry - r
                z.stopP    := z.isBull ? z.entry - r : z.entry + r
                justEntered := true

                // Freeze and fade the drawn zone at the moment price reaches it.
                if showZones and not na(z.bx)
                    box.set_border_color(z.bx, color.new(zoneCol(z.isBull), 45))
                    box.set_border_style(z.bx, line.style_dotted)
                    box.set_bgcolor(z.bx, color.new(zoneCol(z.isBull), 85))

        // Nothing is left of the entry bar once you fill at its close. In edge
        // mode the bar's extreme may have printed before the fill, so it is
        // skipped there too unless you deliberately ask for the biased view.
        if z.touched and z.outcome == 0 and (not justEntered or (entryBarExits and edgeMode))
            r = z.rUnit * kR
            z.mfe := math.max(z.mfe, (z.isBull ? _high - z.entry : z.entry - _low)  / r)
            z.mae := math.max(z.mae, (z.isBull ? z.entry - _low  : _high - z.entry) / r)

            hitT = z.isBull ? _high >= z.target : _low  <= z.target
            hitS = z.isBull ? _low  <= z.stopP  : _high >= z.stopP

            // One bar containing both barriers cannot be ordered from OHLC.
            z.outcome := hitT and hitS ? 3 : hitT ? 1 : hitS ? 2 :
                 bar_index - z.entryBar >= maxBars ? 4 : 0

            if z.outcome != 0
                won = z.outcome == 1
                if z.isReal and not z.isDup
                    record(sReal, z)
                    if z.outcome != 4
                        if z.isBull
                            rBullD := rBullD + 1
                            rBullT := rBullT + (won ? 1 : 0)
                        else
                            rBearD := rBearD + 1
                            rBearT := rBearT + (won ? 1 : 0)
                else if not z.isReal
                    record(sPlac, z)
                    if z.outcome != 4
                        if z.isBull
                            pBullD := pBullD + 1
                            pBullT := pBullT + (won ? 1 : 0)
                        else
                            pBearD := pBearD + 1
                            pBearT := pBearT + (won ? 1 : 0)
                array.remove(active, i)

// ---------------------------------------------------------------- readout ---
if barstate.islast
    dR       = sReal.nTarget + sReal.nStop + sReal.nAmbig
    dP       = sPlac.nTarget + sPlac.nStop + sPlac.nAmbig
    hr       = hitRate(sReal)
    hrP      = hitRate(sPlac)
    [lo, hi]   = wilson(sReal.nTarget, dR)
    [plo, phi] = wilson(sPlac.nTarget, dP)
    zScore   = dR > 0 ? (hr - 0.5) * 2 * math.sqrt(dR) : na
    medBars  = array.size(sReal.resBars) > 0 ? array.median(sReal.resBars) : na
    touchPc  = sReal.nConf > 0 ? float(sReal.nTouch) / sReal.nConf : na
    mfeAvg   = sReal.nTouch > 0 ? sReal.sumMfe / sReal.nTouch : na
    maeAvg   = sReal.nTouch > 0 ? sReal.sumMae / sReal.nTouch : na
    degen    = not na(medBars) and medBars <= 2

    float dlt = na
    if not na(hr) and not na(hrP)
        dlt := hr - hrP
    zd = twoProp(sReal.nTarget, dR, sPlac.nTarget, dP)

    // On a driftless walk both intervals must contain 50%. They will not if
    // the measurement path leaks information across a bar boundary.
    selfPass = not na(lo) and not na(plo) and lo <= 0.5 and hi >= 0.5 and
         plo <= 0.5 and phi >= 0.5
    hdr = synth ? (synDrift != 0 ? "DRIFT TEST" :
         (selfPass ? "VALIDATION PASS" : "VALIDATION FAIL")) : timeframe.period
    hdrC = not synth ? COL_VAL :
         synDrift != 0 ? COL_WARN : selfPass ? COL_UP : COL_DOWN

    empty = useRange and nBarsRange == 0

    array.clear(tk)
    array.clear(tv)
    array.clear(tc)

    addRow("FVG STATISTICS", hdr, hdrC)
    addRow(synth ? "SYNTHETIC  seed " + str.tostring(synSeed) : "Sample",
         synth ? "drift " + str.tostring(synDrift, "#.##") :
         empty ? "NO BARS IN RANGE" : dat(firstT) + "  " + dat(lastT),
         synth ? COL_WARN : empty ? COL_DOWN : COL_VAL)

    if not compact
        // What the date inputs resolved to, versus what the chart actually has.
        addRow("Range set", useRange ? dat(startT) + "  " + dat(endT) : "off",
             useRange ? COL_VAL : COL_TXT)
        addRow("Chart loaded", dat(chartFirstT) + "   " + str.tostring(nBarsAll) + "b",
             COL_VAL)
        addRow("Bars in range", str.tostring(nBarsRange), empty ? COL_DOWN : COL_VAL)

    addRow("Confirmed zones", str.tostring(nConfRaw) +
         (dedupe ? "  (-" + str.tostring(nDup) + " overlap)" : ""), COL_VAL)
    addRow("Returned to zone", str.tostring(sReal.nTouch) + "  " + pct(touchPc), COL_VAL)

    if not compact
        addRow("  -> target first",  str.tostring(sReal.nTarget), COL_UP)
        addRow("  -> stop first",    str.tostring(sReal.nStop),   COL_DOWN)
        addRow("  -> ambiguous bar", str.tostring(sReal.nAmbig),  COL_WARN)
        addRow("  -> unresolved",    str.tostring(sReal.nCens),   COL_VAL)

    addRow("Hit rate (n=" + str.tostring(dR) + ")", pct(hr),
         na(hr) ? COL_VAL : hr > 0.5 ? COL_UP : COL_DOWN)
    addRow("  95% interval", na(lo) ? "--" : pct(lo) + " - " + pct(hi), COL_VAL)

    if not compact
        addRow("  z vs coinflip", num(zScore), COL_VAL)
        addRow("  bull / bear", pct(hr2(rBullT, rBullD)) + " / " + pct(hr2(rBearT, rBearD)) +
             "   " + str.tostring(rBullD) + "/" + str.tostring(rBearD), COL_VAL)

    addRow("Placebo (n=" + str.tostring(dP) + ")", pct(hrP), COL_VAL)

    if not compact
        addRow("  95% interval", na(plo) ? "--" : pct(plo) + " - " + pct(phi), COL_VAL)
        addRow("  bull / bear", pct(hr2(pBullT, pBullD)) + " / " + pct(hr2(pBearT, pBearD)) +
             "   " + str.tostring(pBullD) + "/" + str.tostring(pBearD), COL_VAL)
        // Ambiguous bars count as losses and censoring drops slow cases. Both
        // only cancel out of the difference if the two sides hit them at the
        // same rate, so the rates are shown side by side.
        addRow("  ambiguous r / p", pct(hr2(sReal.nAmbig, dR)) + " / " +
             pct(hr2(sPlac.nAmbig, dP)), COL_WARN)
        addRow("  unresolved r / p", pct(hr2(sReal.nCens, dR + sReal.nCens)) + " / " +
             pct(hr2(sPlac.nCens, dP + sPlac.nCens)), COL_WARN)

    addRow("real - placebo", (na(dlt) ? "--" : pct(dlt)) + "   z " + num(zd),
         na(dlt) ? COL_VAL : dlt > 0 ? COL_UP : COL_DOWN)
    addRow("Entry / barrier", (edgeMode ? "edge (biased)" : "close") + " / " +
         str.tostring(kR, "#.#") + "R  " +
         (na(medBars) ? "--" : str.tostring(medBars, "#.#") + "b") +
         (degen ? "  TOO TIGHT" : ""), edgeMode or degen ? COL_WARN : COL_VAL)

    // chart.bg_color follows the user's theme, so the panel stays readable on
    // light and dark charts without the price lines showing through the text.
    cellBg = color.new(chart.bg_color, 10)

    table.clear(tb, 0, 0, 1, 21)
    for i = 0 to array.size(tk) - 1
        table.cell(tb, 0, i, array.get(tk, i), text_size = size.small,
             text_color = COL_TXT, text_halign = text.align_left,
             bgcolor = cellBg)
        table.cell(tb, 1, i, array.get(tv, i), text_size = size.small,
             text_color = array.get(tc, i), text_halign = text.align_right,
             bgcolor = cellBg)
````
