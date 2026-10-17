# Repainting Statistics: Displayed vs Tradeable Win Rate

- url: https://www.tradingview.com/script/NkmqfEAK-Repainting-Statistics-Displayed-vs-Tradeable-Win-Rate/
- type: indicator
- pine_id: PUB;f95b60fe5dd74bc2a1e265d9f18bd24e
- version: 1.0

## Description

Repainting means that an indicator draws or changes signals on bars
that have already closed, using information that did not exist when
those bars closed. Before you trust an indicator whose arrows mark
every top and bottom - or a backtest built on such arrows - this script
shows how much of that performance hindsight alone can create, on any
chart.

On randomly generated price bars - data with no trend and no pattern to
find - a pivot-reversal arrow showed a 75.84% win rate. The same arrow,
entered at the first moment it was actually visible on a live chart,
won 50.0% - the coin flip that random data must produce. The 25.9-point
gap is the repainting premium.

On real market data - a crypto pair, an FX pair and an equity index
future - the premium at the default settings is 18.9 percentage points
of win rate. That is the average amount by which the displayed history
of a repainting signal overstates what a real-time user of the same
signal could have achieved.

This script measures the two kinds of repainting that place future
information onto past bars: signals computed from data that had not yet
happened, and signals drawn backwards onto earlier bars with a plot
offset. A third kind - signals that appear and disappear while the live
bar is still forming - is a separate phenomenon and is out of scope
here. This script itself does not repaint: every marker it draws is
created only after the signal is confirmed, and is never moved.

The measurements behind this publication were made on BTCUSDT (crypto),
EURUSD (forex) and ES1! (an equity index future). The script runs on any
symbol and timeframe.

[b]What to Use It For[/b]

[b]Putting a number on a widely known warning.[/b] Traders are routinely
warned that repainting indicators look better than they perform. The
warning is correct, but it usually comes without a number. This script
produces the number, on your chart, with a method you can audit row by
row in its panel.

[b]Understanding what a hindsight chart is worth.[/b] Arrows planted at
exact tops and bottoms - ZigZag-style reversal markers, fractal arrows
drawn several bars back - are the most common repainting signals. The
script scores the same signal twice on the same bars: where history
draws it, and where a live user could first have acted on it. The
difference is what the hindsight display is worth.

[b]Testing before trusting.[/b] If a signal on your chart is drawn
in the past - the arrow sits several bars behind the bar where it first
appeared - this measurement applies to it. The pivot rule used here is
the cleanest representative of that family, with the hindsight distance
as an explicit setting, so you can see how the premium grows as signals
are drawn deeper into the past.

https://www.tradingview.com/x/NZ51UzJn/
A pivot-reversal signal on a real chart. The orange triangle is the
displayed placement: history draws the signal at the exact swing bar.
The circle marks the confirmation bar: the first bar on which the signal
was actually knowable in real time. The dotted line connects the two -
the bars in between are the hindsight gap. The panel scores every such
pair on the loaded chart - 5,512 of them here, not just the two visible
- in both ways and reports the difference.


[b]The Result in Plain Language[/b]

Every tested configuration showed a large, positive repainting premium.
Across three instruments at the default settings, the displayed version
of the signal won 18.9 percentage points more often than the tradeable
version of the same signal - about 68% against about 50%. The result
repeated on every instrument, on two timeframes, and in a separate
calendar year that shares no data with the main test window.

The deeper the hindsight, the larger the premium: painting the signal 2
bars into the past cost 13.1 points; painting it 10 bars back cost 34.5
points. Filling the trade at the exact swing price - which is what a
naive backtest of a repainting signal does - nearly doubled the premium
compared with filling at the signal bar's close.

The tradeable version of the signal, meanwhile, stayed at the baseline
in every cell. The gap between the two versions is not produced by the
rule finding good trades. It is produced by where history draws them.


[b]Terms Used in the Panel[/b]

[b]Displayed arm.[/b] The trade as the chart's history shows it: entry
at the close of the bar where the signal is drawn - the pivot bar, the
swing bar the arrow points at - even though the signal did not exist yet
on that bar.

[b]Tradeable arm.[/b] The same signal entered at the close of the bar
where it first became knowable - the confirmation bar. This is the best
a real-time user of the signal could have done.

[b]Premium ("disp - trad").[/b] The displayed arm's win rate minus the
tradeable arm's win rate, in percentage points. This is the primary
result: the part of the displayed performance that hindsight placement
alone creates.

[b]Percentage point (pp).[/b] An absolute difference between
percentages: 68% minus 50% is 18 percentage points.

[b]Discordant pairs.[/b] Events where the two arms disagreed - one won
and the other lost. The premium's z score comes from a paired test
(McNemar's test) on exactly these events: it asks whether the
disagreements favour one arm more often than chance allows. A paired
test is used because both arms trade the same events on the same price
path, so their outcomes rise and fall together.

[b]z score.[/b] The result divided by a measure of its statistical noise.
As a widely used threshold, an absolute z score above 2 is treated as a
first sign of a real effect; this study also required the result to
repeat on two more instruments before calling it a finding.

[b]95% confidence interval (95% CI).[/b] A range around the estimate
showing its uncertainty. When the range excludes zero, the direction of
the effect is established at that confidence level.

[b]Ambiguous outcome.[/b] A bar whose range contains both the target and
the stop. Bar data cannot show which was reached first, so the case is
counted against the win rate - the safe choice.

[b]Censored outcome.[/b] A trade that reached neither barrier before the
time limit. It is reported separately and leaves the paired comparison;
a pair only counts when both arms produced a real outcome.

[b]Replay errors.[/b] An internal integrity counter for the part of the
measurement that reconstructs the displayed arm's trade from closed
bars. It must read 0; any other value voids the run and says so.


[b]The Rule Being Measured[/b]

A pivot low is a bar whose low is strictly below the lows of a set
number of bars on each side - the pivot length. A pivot high is the
mirror image. In this script a pivot low is a long signal and a pivot
high a short signal, ties disqualify the bar, and the test uses the
strict definition throughout.

A pivot with length 3 can only be recognised 3 bars after the pivot bar
prints: its definition depends on the bars that come after it. History
nevertheless draws the signal at the pivot bar. That gap - the signal
exists in the display 3 bars before it existed in reality - is not a
flaw of one particular indicator. It is the defining feature of the
whole family of reversal markers this rule represents, and its size is
the pivot length, which makes the hindsight distance measurable as a
setting rather than an accident.


[b]How the Measurement Works[/b]

Both arms of every pair use one shared risk unit: the average true range
(ATR) measured at the pivot bar. Average true range is roughly how far
price typically travels in one bar, so barriers set in ATR mean the same
thing on a volatile instrument and a quiet one. A barrier size of 2R
places a target and a stop two risk units from the entry, one on each
side.

The displayed arm enters at the pivot bar's close. The tradeable arm
enters at the confirmation bar's close. Each arm then races its own
symmetric barriers: whichever of the target or stop is reached first
decides the outcome, with a time limit for trades that reach neither.
Entries are recorded at closes because a bar's high or low has no known
time inside the bar; a close is a defined moment.

The displayed arm's early bars are reconstructed at confirmation time
from bars that have already closed. Nothing about the measurement uses
future data; the future data is entirely inside the thing being
measured - the entry placement.

[b]Why the displayed arm cannot help winning more.[/b] A pivot low is,
by definition, lower than every low for the next several bars. So while
the displayed trade runs through those bars, price cannot reach a stop
placed at or below the pivot low - but it can reach the target. Losing
outcomes are suppressed during the hindsight gap; winning outcomes are
not. The panel shows this directly: the displayed arm's average adverse
excursion (how far a trade goes against the entry before resolving) is
0.56-0.61R across the baseline cells, while the tradeable arm's is
0.85-0.89R on the same events.

https://www.tradingview.com/x/S923bkFF/
The built-in validation. Price is replaced internally with a random walk
that contains no signal by construction, so the correct answer is known:
the tradeable arm must win 50%, and here it reads 50.2% with a
confidence interval containing 50. The displayed arm wins 76.1% on this
run of the test. The premium exists before any market data is involved,
because it is a property of hindsight placement, not of markets.


[b]Results[/b]

The study contains 18 runs: 4 validation runs on synthetic data and 14
market runs producing 15 estimates. All 15 market estimates are
positive, ranging from +12.2 to +34.5 percentage points, with the
smallest z score at +12.8. The smallest difference the design can
detect is about 1 percentage point, measured on data with no edge.

The decision rule was fixed before any market run: an absolute z score
above 2 on one configuration, plus a repeat of the result on the two
other instruments, before anything counts as a finding. The rule was
met in full.

Baseline configuration, 30 minutes, 2025-01-01 to 2026-08-01:

[pine]
  Instrument       Premium      z        Pairs
  BTCUSDT          +18.0pp    +29.0      5,348
  EURUSD           +20.1pp    +25.4      3,618
  ES1!             +19.2pp    +22.6      3,276
  Pooled           +18.9pp    95% CI +18.1 to +19.7
[/pine]

A heterogeneity check (Cochran's Q, which asks whether the three
instruments disagree more than sampling noise allows) does not reject
pooling: Q 4.43, p 0.11.

The same three instruments, 1-hour timeframe: +17.4, +20.6 and +20.1
points - each within one point of its 30-minute counterpart. At 1 hour
the heterogeneity check is marginal (Q 6.02, p 0.049), so the 1-hour
result is reported as the range +17.4 to +20.6 rather than as one
pooled number.

Calendar year 2024, which shares no data with the window above: +15.8,
+18.0 and +18.9 points, pooled +17.3 (95% CI +15.8 to +18.7, Q p 0.19).

[b]The premium grows with hindsight depth.[/b] On BTCUSDT 30m, changing
only the pivot length - how many bars into the past the signal is
drawn:

[pine]
  Hindsight depth    Premium      z        Pairs
  2 bars             +13.1pp    +27.6      7,364
  3 bars (default)   +18.0pp    +29.0      5,348
  5 bars             +24.8pp    +27.7      3,428
  10 bars            +34.5pp    +24.0      1,775
[/pine]

The relationship is strictly monotone, and it was stated as the expected
pattern in the study design before any run: a longer protected gap
suppresses more losing outcomes. A measurement artifact would have no
reason to follow the dose this way.

[b]The premium shrinks as barriers widen.[/b] Same events, scored at
three barrier sizes: +29.4 points at 1R, +18.0 at 2R, +12.2 at 3R. The
hindsight gap protects a fixed number of bars; a wider barrier makes the
race last longer, so the protected bars are a smaller share of it.

[b]Filling at the arrow price nearly doubles the premium.[/b] The
default displayed fill is the signal bar's close. Filling at the pivot's
exact extreme instead - which is what a backtest that trusts the arrows
does - raises the premium from +18.0 to +34.2 points on the same
events. The displayed arm's average adverse excursion collapses to
0.28R: trades that appear to suffer almost no drawdown. In that
configuration, across 5,349 pairs, there was not a single event where
the tradeable arm won and the displayed arm lost. That is exactly what
the geometry requires, and it serves as an additional consistency check
on the measurement.

[b]The tradeable arm stayed at its baseline everywhere.[/b] In all nine
baseline market cells its win rate was between 49.3% and 51.2%, and its
confidence interval contained 50% every time. This is reported as a
property of the measurement design, not as a claim about pivot trading;
see the limitations.

[b]To reproduce the published figures:[/b] the script defaults match the
baseline configuration. Switch the date range on (2025-01-01 to
2026-08-01), disable compact panel mode, and load the full chart
history. The three instruments are BTCUSDT, EURUSD and ES1!.


[b]Validation[/b]

[b]Known-answer test.[/b] Synthetic mode replaces price internally with
a random walk that contains no signal, so the correct answers are known
in advance: the tradeable arm must win 50%, and the displayed arm must
win more - if either fails, the measurement is broken. Across three
seeds (three different artificial price series), the tradeable arm
pooled to 49.96% on 11,637 pairs, within a twentieth of a point of 50%,
with every seed's confidence interval containing 50%. The displayed arm
pooled to 75.84%. The premium on data with no edge: +25.9 points.

[b]Drift stress test.[/b] The same test repeated with a steady upward
drift added to the artificial data. Drift moved the long and short win
rates apart, as it must - the tradeable arm read 59.0% long and 41.3%
short - but the premium barely moved: +24.9 points against +25.9
driftless. Both arms inherit the drift, and it cancels in the pairing.
This is the test that shows the premium is not a trend artifact.

https://www.tradingview.com/x/fHMDvvZM/
The drift stress test. Artificial data with a steady upward drift and
still no signal by construction. Drift splits the tradeable arm's two
directions apart - 59.0% long against 41.3% short - exactly as a trend
must. The premium is nearly unchanged: +24.9 points against +25.9
without drift, because both arms inherit the drift and it cancels in
the pairing. Synthetic mode replaces price internally, so the chart
behind the panel does not show the tested data.

[b]Resolution.[/b] On no-edge data the design resolves differences down
to about 1 percentage point. Every market estimate in this study is at
least twelve times that floor.

[b]Accounting.[/b] The panel reconciles every confirmed pivot into
exactly one category (measured, out of range, no ATR available, or
filtered), reports any mismatch as an explicit error, and carries a
replay-error counter that must read zero. Across all 18 runs, every
reconciliation was exact and every replay-error count was zero.


[b]Settings[/b]

[b]Signal definition.[/b] Pivot length sets how many bars on each side
define a pivot - and with it, how far into the past the displayed signal
is drawn. Minimum separation optionally rejects events too close to the
previous one.

[b]Measurement.[/b] ATR length sets the risk unit. Barrier size sets the
target and stop distance in risk units. The time limit censors trades
that reach neither barrier. Displayed fill chooses where the displayed
arm enters: the pivot bar's close (default) or the pivot's exact extreme
(labelled biased; it adds the fill bias on top of the placement bias).

[b]Sample.[/b] The date range uses explicit year, month and day fields
rather than a date picker, so a published sample can be reproduced
exactly.

[b]Validation.[/b] Synthetic mode, seed, step size and drift per bar.

[b]Display.[/b] Compact panel mode, the signal markers with their gap
lines, and the marker size.


[b]Limitations[/b]

[b]One rule family was measured.[/b] The pivot-reversal signal is the
cleanest and most common representative of hindsight placement, but
other repainting mechanisms - such as higher-timeframe data requested
with lookahead - share the deception without being measured here. The
numbers in this description apply to the measured rule.

[b]The tradeable arm's 50% is not a verdict on pivot trading.[/b] This
design pairs two versions of one rule; it contains no control for the
rule itself, so it cannot say whether pivot reversals have or lack an
edge against other entries. The premium - the difference between the
two versions - is the only claim.

[b]Long/short splits are unreliable under trend.[/b] In the drift test,
drift displaced the two directions' win rates by about nine points each
way while the aggregate premium held. Read the aggregate rows; treat
directional splits as descriptive.

[b]Instruments may differ by a small amount.[/b] BTCUSDT showed the
lowest premium in every window, and at 1 hour the heterogeneity check
was marginal. A real instrument-level spread of roughly two points
around +19 is possible. No cell was below +12.

[b]Loaded chart history bounds every sample.[/b] The number of bars the
chart loads, not only the calendar range, limits each run. The windows
and sample sizes are stated per cell above.

[b]Historical measurement is not a forecast.[/b] The script reports what
happened under the specified rules and samples. It does not predict the
future behavior of any signal or instrument.


[b]Disclaimer[/b]

This script and its description are provided for educational and
research purposes only. They do not constitute financial, investment,
trading or other professional advice, and they do not recommend buying,
selling or holding any asset. Historical and simulated results do not
guarantee future performance. Trading involves risk, including the
possible loss of capital. You are solely responsible for your trading
and investment decisions and should conduct your own research and,
where appropriate, consult a qualified financial professional.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Algolego

//@version=6
indicator("Repainting Statistics: Displayed vs Tradeable Win Rate", "Repaint Stats",
     overlay = true, max_bars_back = 5000, max_labels_count = 500, max_lines_count = 500)

// =============================================================================
// Measures what hindsight signal placement is worth, in percentage points of
// win rate.
//
// The rule under test is a pivot-reversal signal. A pivot low -- a bar whose
// low is strictly below the lows of pivLen bars on each side -- is a long
// signal; a pivot high is a short one. The pivot exists only pivLen bars after
// it prints, yet history draws it at the pivot bar. Every confirmed pivot is
// therefore scored twice:
//   displayed arm  -- entry at the pivot bar's close, where history draws the
//                     signal (optionally at the pivot extreme, the folklore
//                     backtest fill, clearly labelled biased)
//   tradeable arm  -- entry at the confirmation bar's close, the first moment
//                     the signal was knowable
// Both arms race the same symmetric +/- kR barriers from their own entries and
// share one risk unit: ATR at the pivot bar, which precedes both entries.
// Displayed minus tradeable is the repainting premium.
//
// Scope: PineCoders type 2 and type 3 repainting -- future data on historical
// bars, and negative plot offsets. Type 1 (realtime flicker) is a different
// phenomenon and is out of scope. This script itself does not repaint: its
// markers are created at the confirmation bar, never before, and are never
// modified afterwards.
//
// Why the displayed arm is favoured on data with no edge: the pivot definition
// constrains every gap-bar low to sit above the pivot low. Whenever the
// displayed stop is at or below the pivot low, no gap bar can hit the stop
// while every gap bar can hit the target. Stop-first outcomes are suppressed
// during the gap; target-first outcomes are not.
//
// The tradeable arm is the control. There is no placebo: the question is
// internal to one rule -- same events, two placements -- so the pairing
// supplies the baseline. The tradeable arm's absolute rate on market data
// carries an uncontrolled path/drift baseline and is NOT interpretable as
// edge; the premium is the statistic this script exists to measure.
//
// Primary statistic: McNemar on discordant pairs. The two arms share the
// price path from the confirmation bar onward, so their outcomes are strongly
// positively correlated; a two-proportion z ignoring that overstates the
// variance of the difference. It is shown as a secondary, conservative check.
// With a common paired denominator, (b - c) / n equals the difference of the
// two arms' hit rates exactly.
//
// The displayed arm's race over the closed gap bars is replayed at the
// confirmation bar. DESIGN.md 3.3 mandates, honoured here: the replay loop
// runs at global scope, never inside a function (the defect class that voided
// OB run 0a lived in history lookups inside conditionally-called functions);
// a replay-integrity counter verifies every event replays exactly pivLen bars;
// the replay reads the routed series so synthetic mode exercises the same
// code path.
//
// Tie rule, fixed because ta.pivot* tie semantics are unverified: pivots are
// detected explicitly with STRICT inequality on both sides. A tie disqualifies
// the candidate. (DESIGN.md open item 10.1.)
//
// SELF-TEST: on a driftless random walk the tradeable arm, whose entry and
// barriers use no future information, resolves upward exactly 50% of the time
// (optional stopping theorem) -- its interval must contain 50%. The displayed
// arm must sit ABOVE 50% on the same data: a replay defect that reads
// unrelated bars turns it into a second fair coin, which a null-only check
// would score as a pass. Gate A criteria are in DESIGN.md section 7.
// =============================================================================

// ---------------------------------------------------------------- inputs ----
grpP = "Signal definition"
pivLen = input.int(3, "Pivot length (bars each side)", minval = 1, maxval = 50, group = grpP,
     tooltip = "A pivot is confirmed this many bars after it prints. This is " +
     "the hindsight gap: how far into the past the displayed signal is drawn.")
minSep = input.int(0, "Minimum separation (bars, 0 = off)", minval = 0, group = grpP,
     tooltip = "Optional. Rejects an event closer than this to the previous " +
     "accepted event in the same direction. Same-direction pivots are never " +
     "closer than pivot length + 1 bars by construction.")

grpM = "Measurement"
atrLen  = input.int(14, "ATR length", minval = 1, group = grpM,
     tooltip = "The risk unit is ATR at the pivot bar, shared by both arms.")
kR      = input.float(2.0, "Barrier size (R)", minval = 0.1, step = 0.1, group = grpM)
maxBars = input.int(100, "Time limit after entry (bars, per arm)", minval = 1, group = grpM)
dispFill = input.string("Pivot close", "Displayed fill",
     options = ["Pivot close", "Pivot extreme (biased)"], group = grpM,
     tooltip = "Where the displayed arm enters. A signal arrow under a bar " +
     "implies acting on that bar's close. The extreme is the folklore " +
     "backtest fill and stacks the edge-fill bias on top of the placement " +
     "premium.")

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

grpS = "Validation (synthetic data)"
synth    = input.bool(false, "Replace price with a random walk", group = grpS)
synSeed  = input.int(12345, "Seed", group = grpS)
synVol   = input.float(1.0, "Sub-step size", minval = 0.01, step = 0.1, group = grpS)
synDrift = input.float(0.0, "Drift per bar (0 = driftless null)", step = 0.05, group = grpS)

grpD = "Display"
compact  = input.bool(true, "Compact panel", group = grpD)
showSig  = input.bool(true, "Draw signal markers and gap lines", group = grpD)
// Numeric because the label size constants bottom out at tiny (~8pt).
mrkSize  = input.int(3, "Marker size", minval = 1, maxval = 20, group = grpD)

// ------------------------------------------------------- synthetic series ---
// Four sub-steps per bar so synthetic bars carry a real intrabar path: the
// high and low are extremes of a walk, not decorations around the close. The
// bugs this test is built to catch live in the relationship between a bar's
// extremes and its close. Open is routed too, for consistency with scripts
// #1 and #2, although this rule does not read candle direction.
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

_open  = synth ? sOpen  : open
_high  = synth ? sHigh  : high
_low   = synth ? sLow   : low
_close = synth ? sClose : close

// True range from the routed series, so ATR is correct in both modes.
_tr = na(_close[1]) ? _high - _low :
     math.max(_high - _low, math.max(math.abs(_high - _close[1]), math.abs(_low - _close[1])))
atr = ta.rma(_tr, atrLen)

// ----------------------------------------------------------------- types ----
type Arm
    float entry
    int   entryBar
    float target
    float stopP
    float mfe     = 0.0
    float mae     = 0.0
    int   outcome = 0        // 0 pending, 1 target, 2 stop, 3 ambiguous, 4 censored
    int   resBar  = na       // bar the outcome landed on, for hold time

type Pair
    bool isBull
    int  pivBar
    int  confBar
    Arm  disp
    Arm  trad

type ArmStats
    int   nTarget = 0
    int   nStop   = 0
    int   nAmbig  = 0
    int   nCens   = 0
    int   bullT   = 0        // directional split: wins / resolved, per side
    int   bullD   = 0
    int   bearT   = 0
    int   bearD   = 0
    float sumMfe  = 0.0
    float sumMae  = 0.0
    array<int> resBars

// ------------------------------------------------------------- functions ----
// All declarations live at global scope. None of these touches series history
// -- every price they see arrives as an argument. That is deliberate: history
// lookups inside functions are the defect class that voided OB run 0a.
newArmStats() => ArmStats.new(resBars = array.new<int>())

// Advance one arm through one bar's extremes. Returns true if the arm
// resolved on this bar. MFE/MAE are updated before the outcome test, matching
// scripts #1 and #2, so the resolution bar's excursion is included. One bar
// containing both barriers cannot be ordered from OHLC: ambiguous.
stepArm(Arm a, bool isBull, float hi, float lo, int curBar, int limitBars) =>
    bool done = false
    if a.outcome == 0
        rd = math.abs(a.target - a.entry)
        a.mfe := math.max(a.mfe, (isBull ? hi - a.entry : a.entry - lo) / rd)
        a.mae := math.max(a.mae, (isBull ? a.entry - lo : hi - a.entry) / rd)
        hitT = isBull ? hi >= a.target : lo <= a.target
        hitS = isBull ? lo <= a.stopP  : hi >= a.stopP
        a.outcome := hitT and hitS ? 3 : hitT ? 1 : hitS ? 2 :
             curBar - a.entryBar >= limitBars ? 4 : 0
        if a.outcome != 0
            a.resBar := curBar
            done := true
    done

// Censored arms leave the hit-rate denominator; ambiguous stays in it and out
// of the numerator, i.e. it counts against the rate. Inherited rule.
recordArm(ArmStats s, Arm a, bool isBull) =>
    if a.outcome == 1
        s.nTarget := s.nTarget + 1
    else if a.outcome == 2
        s.nStop := s.nStop + 1
    else if a.outcome == 3
        s.nAmbig := s.nAmbig + 1
    else if a.outcome == 4
        s.nCens := s.nCens + 1
    s.sumMfe := s.sumMfe + a.mfe
    s.sumMae := s.sumMae + a.mae
    if a.outcome != 4
        array.push(s.resBars, a.resBar - a.entryBar)
        won = a.outcome == 1
        if isBull
            s.bullD := s.bullD + 1
            s.bullT := s.bullT + (won ? 1 : 0)
        else
            s.bearD := s.bearD + 1
            s.bearT := s.bearT + (won ? 1 : 0)

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

hr2(int x, int n) => n > 0 ? float(x) / n : na

// Theme-aware palette, carried from scripts #1 and #2. COL_TRAD is the
// tradeable-entry marker: mid-blue, deliberately outside the candle palette
// so the marker cannot blend with a candle of its own trade's direction.
COL_TXT  = color.new(chart.fg_color, 35)
COL_VAL  = chart.fg_color
COL_UP   = #26A69A
COL_DOWN = #EF5350
COL_WARN = #FFA726
COL_TRAD = #2196F3

pct(float v) => na(v) ? "--" : str.tostring(v * 100, "#.#") + "%"
num(float v) => na(v) ? "--" : str.tostring(v, "#.##")
dat(int t) => na(t) ? "--" : str.format_time(t, "yyyy-MM-dd", syminfo.timezone)

// 32 rows are emitted in non-compact mode. Sized to 36 so a future row cannot
// silently overflow; table.clear below must stay in step with this number.
var table tb = table.new(position.top_right, 2, 36, border_width = 1,
     bgcolor = color.new(chart.bg_color, 0),
     frame_color = color.new(chart.fg_color, 65), frame_width = 1)

var array<string> tk = array.new<string>()
var array<string> tv = array.new<string>()
var array<color>  tc = array.new<color>()

addRow(string k, string v, color c) =>
    array.push(tk, k)
    array.push(tv, v)
    array.push(tc, c)
    array.size(tk)

// ------------------------------------------------------------------ state ---
inRange     = not useRange or (time >= startT and time <= endT)
fillExtreme = dispFill == "Pivot extreme (biased)"

var array<Pair> activeP = array.new<Pair>()
var ArmStats sDisp = newArmStats()
var ArmStats sTrad = newArmStats()

// Funnel. Every confirmed pivot signal ends in exactly one bucket. An outside
// bar can be a pivot low and a pivot high simultaneously; that is two signals.
var int nPivots    = 0
var int nRange     = 0    // confirmation bar outside the date range
var int nAtrNa     = 0    // ATR at the pivot bar unavailable or zero
var int nSep       = 0    // rejected by the minimum-separation input
var int nEvents    = 0    // events entered: both arms created
var int nEvBull    = 0
var int nEvBear    = 0
var int nReplayErr = 0    // replay-integrity: gap bars replayed != pivLen
var int lastBullEv = na
var int lastBearEv = na

// Paired classification, on pairs where both arms resolved (not censored).
// b = displayed won and tradeable did not; c = the reverse. With the common
// denominator nPairBoth, premium = (b - c) / n exactly.
var int nPairBoth = 0
var int nPairCens = 0    // at least one arm censored: excluded from paired stats
var int bWin      = 0
var int cWin      = 0
var int bothWin   = 0
var int bothLose  = 0
var int bBull     = 0
var int cBull     = 0
var int nBullP    = 0
var int bBear     = 0
var int cBear     = 0
var int nBearP    = 0

// Sample diagnostics, separating "date inputs resolved wrong" from "the chart
// has no data that far back".
var int chartFirstT = na
var int nBarsAll    = 0
var int nBarsRange  = 0
var int firstT      = na
var int lastT       = na
if na(chartFirstT)
    chartFirstT := time
nBarsAll += 1
if inRange
    firstT := na(firstT) ? time : firstT
    lastT  := time
    nBarsRange += 1

// -------------------------------------------------------- pivot detection ---
// Explicit, at global scope, on the routed series. STRICT inequality on both
// sides; a tie disqualifies. The candidate is the bar pivLen bars back; it is
// confirmed on this bar's close. bar_index >= 2 * pivLen guarantees the whole
// window exists.
bool isPL = false
bool isPH = false
if bar_index >= 2 * pivLen
    isPL := true
    isPH := true
    for k = 0 to 2 * pivLen
        if k != pivLen
            if na(_low[k]) or na(_low[pivLen]) or _low[pivLen] >= _low[k]
                isPL := false
            if na(_high[k]) or na(_high[pivLen]) or _high[pivLen] <= _high[k]
                isPH := false

// --------------------------------------------- event creation and replay ----
// Runs at the confirmation bar B. The pivot bar is P = B - pivLen. The
// displayed arm entered at P's close, so its race covers the closed gap bars
// P+1 .. B, replayed here from history -- at global scope, per the DESIGN.md
// 3.3 mandate. The tradeable arm enters at B's close; its race starts at B+1.
unit = atr[pivLen]     // risk unit: ATR at the pivot bar, shared by both arms

for dir = 0 to 1
    isBull = dir == 0
    if (isBull ? isPL : isPH)
        nPivots += 1
        if not inRange
            nRange += 1
        else if na(unit) or unit <= 0
            nAtrNa += 1
        else if minSep > 0 and not na(isBull ? lastBullEv : lastBearEv) and
             bar_index - (isBull ? lastBullEv : lastBearEv) < minSep
            nSep += 1
        else
            pivBar  = bar_index - pivLen
            pivExt  = isBull ? _low[pivLen] : _high[pivLen]
            dEntry  = fillExtreme ? pivExt : _close[pivLen]
            tEntry  = _close
            r       = kR * unit

            Arm disp = Arm.new(entry = dEntry, entryBar = pivBar,
                 target = isBull ? dEntry + r : dEntry - r,
                 stopP  = isBull ? dEntry - r : dEntry + r)
            Arm trad = Arm.new(entry = tEntry, entryBar = bar_index,
                 target = isBull ? tEntry + r : tEntry - r,
                 stopP  = isBull ? tEntry - r : tEntry + r)

            // Replay the gap bars in chronological order: offset pivLen-1 is
            // bar P+1, offset 0 is B itself. Every iteration is counted even
            // after the arm resolves, so the counter checks loop coverage,
            // not the race. It must equal pivLen for every event.
            int replayed = 0
            for k = pivLen - 1 to 0
                replayed += 1
                if stepArm(disp, isBull, _high[k], _low[k], bar_index - k, maxBars)
                    recordArm(sDisp, disp, isBull)
            if replayed != pivLen
                nReplayErr += 1

            array.push(activeP, Pair.new(isBull = isBull, pivBar = pivBar,
                 confBar = bar_index, disp = disp, trad = trad))
            nEvents += 1
            if isBull
                nEvBull += 1
                lastBullEv := bar_index
            else
                nEvBear += 1
                lastBearEv := bar_index

            // Markers, created at confirmation and never modified afterwards,
            // so Pine's automatic deletion of the oldest drawings is safe --
            // no manual object management needed (script #2 needed it because
            // it kept writing to its boxes). Orange marks the displayed
            // placement -- the illusion; the direction colour marks the
            // tradeable one. Not drawn in synthetic mode: synthetic prices
            // have no relation to the chart scale.
            if showSig and not synth
                label.new(pivBar, pivExt, "",
                     style = isBull ? label.style_triangleup : label.style_triangledown,
                     color = COL_WARN, size = mrkSize,
                     yloc = isBull ? yloc.belowbar : yloc.abovebar)
                // Below/above the bar, not at the entry price: at yloc.price
                // the circle sat inside the bar's range and covered it, and
                // in the direction colour it blended with same-colour
                // candles. The gap line still ends at the entry price, so no
                // price information is lost by offsetting the marker.
                label.new(bar_index, tEntry, "", style = label.style_circle,
                     color = COL_TRAD, size = mrkSize,
                     yloc = isBull ? yloc.belowbar : yloc.abovebar)
                // Transparency 15, not 55: at 55 the dotted line was barely
                // visible against the chart background.
                line.new(pivBar, dEntry, bar_index, tEntry,
                     color = color.new(chart.fg_color, 15), style = line.style_dotted)

// ------------------------------------------------------------ evaluation ----
// Live continuation. The guard bar_index > confBar keeps the creation bar out:
// the replay already covered bar B for the displayed arm, and nothing is left
// of B for the tradeable arm once it fills at B's close. A pair is classified
// when both arms are terminal; a pair with either arm censored is excluded
// from the paired statistics and counted separately.
if array.size(activeP) > 0
    for i = array.size(activeP) - 1 to 0
        p = array.get(activeP, i)
        if bar_index > p.confBar
            if stepArm(p.disp, p.isBull, _high, _low, bar_index, maxBars)
                recordArm(sDisp, p.disp, p.isBull)
            if stepArm(p.trad, p.isBull, _high, _low, bar_index, maxBars)
                recordArm(sTrad, p.trad, p.isBull)
        if p.disp.outcome != 0 and p.trad.outcome != 0
            if p.disp.outcome == 4 or p.trad.outcome == 4
                nPairCens += 1
            else
                nPairBoth += 1
                dW = p.disp.outcome == 1
                tW = p.trad.outcome == 1
                if dW and not tW
                    bWin += 1
                    if p.isBull
                        bBull += 1
                    else
                        bBear += 1
                else if tW and not dW
                    cWin += 1
                    if p.isBull
                        cBull += 1
                    else
                        cBear += 1
                else if dW and tW
                    bothWin += 1
                else
                    bothLose += 1
                if p.isBull
                    nBullP += 1
                else
                    nBearP += 1
            array.remove(activeP, i)

// ---------------------------------------------------------------- readout ---
if barstate.islast
    // Per-arm rates, unconditional over all recorded arms.
    dD = sDisp.nTarget + sDisp.nStop + sDisp.nAmbig
    dT = sTrad.nTarget + sTrad.nStop + sTrad.nAmbig
    hrD = hr2(sDisp.nTarget, dD)
    hrT = hr2(sTrad.nTarget, dT)
    [dLo, dHi] = wilson(sDisp.nTarget, dD)
    [tLo, tHi] = wilson(sTrad.nTarget, dT)
    zD = dD > 0 ? (hrD - 0.5) * 2 * math.sqrt(dD) : na
    zT = dT > 0 ? (hrT - 0.5) * 2 * math.sqrt(dT) : na

    // Paired statistics. McNemar primary; two-proportion z secondary.
    prem  = nPairBoth > 0 ? float(bWin - cWin) / nPairBoth : na
    zMc   = bWin + cWin > 0 ? float(bWin - cWin) / math.sqrt(bWin + cWin) : na
    z2p   = twoProp(bWin + bothWin, nPairBoth, cWin + bothWin, nPairBoth)
    premB = nBullP > 0 ? float(bBull - cBull) / nBullP : na
    premS = nBearP > 0 ? float(bBear - cBear) / nBearP : na

    nRecD = dD + sDisp.nCens
    nRecT = dT + sTrad.nCens
    medD  = array.size(sDisp.resBars) > 0 ? array.median(sDisp.resBars) : na
    medT  = array.size(sTrad.resBars) > 0 ? array.median(sTrad.resBars) : na
    degen = not na(medT) and medT <= 2

    // Both funnels must reconcile exactly. A nonzero residual means a reject
    // path is missing a counter.
    resid   = nPivots - (nRange + nAtrNa + nSep + nEvents)
    evResid = nEvents - (nPairBoth + nPairCens + array.size(activeP))

    // Per-seed verdict (DESIGN.md 7.1): the tradeable interval must contain
    // 50%, with clean funnels and zero replay errors. The displayed arm's
    // above-50% criterion (G3) is scored on the pooled seeds, not here, so
    // the header does not gate on it -- but zD is displayed for the log.
    selfPass = not na(tLo) and tLo <= 0.5 and tHi >= 0.5 and
         resid == 0 and evResid == 0 and nReplayErr == 0
    hdr = synth ? (synDrift != 0 ? "DRIFT TEST" :
         (selfPass ? "VALIDATION PASS" : "VALIDATION FAIL")) : timeframe.period
    hdrC = not synth ? COL_VAL :
         synDrift != 0 ? COL_WARN : selfPass ? COL_UP : COL_DOWN

    empty = useRange and nBarsRange == 0

    array.clear(tk)
    array.clear(tv)
    array.clear(tc)

    addRow("REPAINTING STATISTICS", hdr, hdrC)
    addRow(synth ? "SYNTHETIC  seed " + str.tostring(synSeed) : "Sample",
         synth ? "drift " + str.tostring(synDrift, "#.##") :
         empty ? "NO BARS IN RANGE" : dat(firstT) + "  " + dat(lastT),
         synth ? COL_WARN : empty ? COL_DOWN : COL_VAL)

    if not compact
        addRow("Range set", useRange ? dat(startT) + "  " + dat(endT) : "off",
             useRange ? COL_VAL : COL_TXT)
        addRow("Chart loaded", dat(chartFirstT) + "   " + str.tostring(nBarsAll) + "b",
             COL_VAL)
        addRow("Bars in range", str.tostring(nBarsRange), empty ? COL_DOWN : COL_VAL)

    addRow("Confirmed pivot signals", str.tostring(nPivots) +
         (resid != 0 ? "   UNACCOUNTED " + str.tostring(resid) : ""),
         resid != 0 ? COL_DOWN : COL_VAL)

    if not compact
        addRow("  out of range",   str.tostring(nRange), COL_TXT)
        addRow("  no ATR",         str.tostring(nAtrNa), COL_TXT)
        addRow("  min separation", str.tostring(nSep),   COL_TXT)

    addRow("Events (pairs entered)", str.tostring(nEvents) + "   " +
         str.tostring(nEvBull) + "/" + str.tostring(nEvBear) + " b/s", COL_VAL)
    addRow("Pairs resolved", str.tostring(nPairBoth) +
         (evResid != 0 ? "   UNACCOUNTED " + str.tostring(evResid) : ""),
         evResid != 0 ? COL_DOWN : COL_VAL)

    if not compact
        addRow("  censored pairs", str.tostring(nPairCens), COL_TXT)
        addRow("  still open", str.tostring(array.size(activeP)), COL_TXT)

    // Surfaced even in compact mode when nonzero: a replay error voids the
    // run and must not hide behind a toggle.
    if not compact or nReplayErr > 0
        addRow("  replay errors", str.tostring(nReplayErr) +
             (nReplayErr > 0 ? "   RUN VOID" : ""),
             nReplayErr > 0 ? COL_DOWN : COL_TXT)

    addRow("Displayed win rate (n=" + str.tostring(dD) + ")", pct(hrD), COL_VAL)
    if not compact
        addRow("  95% interval", na(dLo) ? "--" : pct(dLo) + " - " + pct(dHi) +
             "   z50 " + num(zD), COL_VAL)
        addRow("  t/s/a/c", str.tostring(sDisp.nTarget) + "/" + str.tostring(sDisp.nStop) +
             "/" + str.tostring(sDisp.nAmbig) + "/" + str.tostring(sDisp.nCens), COL_TXT)
        addRow("  bull / bear", pct(hr2(sDisp.bullT, sDisp.bullD)) + " / " +
             pct(hr2(sDisp.bearT, sDisp.bearD)) + "   " +
             str.tostring(sDisp.bullD) + "/" + str.tostring(sDisp.bearD), COL_VAL)

    addRow("Tradeable win rate (n=" + str.tostring(dT) + ")", pct(hrT), COL_VAL)
    if not compact
        addRow("  95% interval", na(tLo) ? "--" : pct(tLo) + " - " + pct(tHi) +
             "   z50 " + num(zT), COL_VAL)
        addRow("  t/s/a/c", str.tostring(sTrad.nTarget) + "/" + str.tostring(sTrad.nStop) +
             "/" + str.tostring(sTrad.nAmbig) + "/" + str.tostring(sTrad.nCens), COL_TXT)
        addRow("  bull / bear", pct(hr2(sTrad.bullT, sTrad.bullD)) + " / " +
             pct(hr2(sTrad.bearT, sTrad.bearD)) + "   " +
             str.tostring(sTrad.bullD) + "/" + str.tostring(sTrad.bearD), COL_VAL)

    // Positive premium is coloured as a warning, not a win: it is the size of
    // the illusion the hindsight placement creates.
    addRow("Premium (disp - trad)", (na(prem) ? "--" : pct(prem)) + "   z " + num(zMc),
         na(prem) ? COL_VAL : prem > 0 ? COL_WARN : COL_DOWN)
    if not compact
        addRow("  discordant d-only / t-only", str.tostring(bWin) + " / " +
             str.tostring(cWin), COL_TXT)
        addRow("  two-prop z (secondary)", num(z2p), COL_TXT)
        addRow("  bull / bear premium", pct(premB) + " / " + pct(premS) + "   " +
             str.tostring(nBullP) + "/" + str.tostring(nBearP), COL_VAL)
        addRow("  ambiguous d / t", pct(hr2(sDisp.nAmbig, dD)) + " / " +
             pct(hr2(sTrad.nAmbig, dT)), COL_WARN)
        addRow("  censored d / t", pct(hr2(sDisp.nCens, nRecD)) + " / " +
             pct(hr2(sTrad.nCens, nRecT)), COL_WARN)
        addRow("  mean MFE/MAE  d", num(nRecD > 0 ? sDisp.sumMfe / nRecD : na) + " / " +
             num(nRecD > 0 ? sDisp.sumMae / nRecD : na), COL_VAL)
        addRow("  mean MFE/MAE  t", num(nRecT > 0 ? sTrad.sumMfe / nRecT : na) + " / " +
             num(nRecT > 0 ? sTrad.sumMae / nRecT : na), COL_VAL)

    addRow("Displayed fill / barrier", (fillExtreme ? "extreme (biased)" : "pivot close") +
         " / " + str.tostring(kR, "#.#") + "R   d " + (na(medD) ? "--" : str.tostring(medD, "#.#")) +
         "b  t " + (na(medT) ? "--" : str.tostring(medT, "#.#")) + "b" +
         (degen ? "  TOO TIGHT" : ""), fillExtreme or degen ? COL_WARN : COL_VAL)
    addRow("Definition", "pivot " + str.tostring(pivLen) + "  strict ties" +
         (minSep > 0 ? "  minsep " + str.tostring(minSep) : ""), COL_TXT)

    // Opaque cells on an opaque table, so nothing shows through the numbers
    // where price crosses the panel. chart.bg_color is passed through
    // color.new(..., 0) to force zero transparency.
    cellBg = color.new(chart.bg_color, 0)

    table.clear(tb, 0, 0, 1, 35)
    for i = 0 to array.size(tk) - 1
        table.cell(tb, 0, i, array.get(tk, i), text_size = size.small,
             text_color = COL_TXT, text_halign = text.align_left,
             bgcolor = cellBg)
        table.cell(tb, 1, i, array.get(tv, i), text_size = size.small,
             text_color = array.get(tc, i), text_halign = text.align_right,
             bgcolor = cellBg)
````
