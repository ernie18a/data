<!-- tradingview-pine-id: PUB;6b3b5472532f4dc29e0ff4c4e4e4d692 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Machine Learning Signal Statistics: kNN Win Rate vs Random Entries

Source: https://www.tradingview.com/script/XuIlozD8-Machine-Learning-Statistics-kNN-Win-Rate-vs-Random-Entries/

## Description

Before you trust a "machine learning" indicator - or pay for one - you
can test it. This script measures the method most published ML
indicators are built on against entries taken at random, on your
instrument, your timeframe, your chart.

Why random entries are the comparison that matters. A win rate
on its own tells you very little. Buy anything at any moment, put a
target above and a stop below, and you will win roughly half the time.
That is arithmetic, not skill. So the useful question about a signal is
not "how often does it win" but "how often does it win compared with
entering at a random moment instead". This script answers that
question. For every signal the method produces, it also places matched
random entries - same direction, same target and stop distances,
anchored at bars where no signal happened - then scores both and
reports the difference.

The measurement is tested before it is trusted. The script can
replace price with artificial data that contains one deliberate,
repeating pattern - put there on purpose, so there is definitely
something to find. A plain RSI rule - the relative strength index, a
standard overbought and oversold gauge - reads that pattern directly
and won 75.7% of its trades. Randomly timed trades on the same bars won
50.6%. The pattern was there, and a simple rule found it.

The same test then handed the widely published machine-learning method
the same data, with the pattern sitting in the exact measurements it
looks at. It won 39.9%. Randomly timed trades won 49.3%. It did not
merely fail to find the pattern. It finished 9.4 percentage points
behind random timing - a percentage point being the plain difference
between two percentages, so 51% against 50% is one point - and the gap
grew wider the stronger the pattern was made.

That is the demonstration this script exists to make possible: an
instrument that finds an edge when one is really there, and reports
nothing when there is not. What it reports on live market data is
below.

https://www.tradingview.com/x/pB3ondYm/
The script on a live chart, with both populations drawn. The green and
red pins are signals from the machine-learning method - green below the
bar for long, red above it for short - created only once the bar has
closed, so nothing is moved or redrawn afterwards. The grey dots are
the control: matched random entries, three for every signal, taken in
the same direction with the same target and stop distances but at bars
where no signal happened. Those are what the signals get measured
against, and the key in the corner names both. The panel reports the
two win rates and the gap between them: 50.1% for the signals against
49.5% for random entries, a difference of 0.6 percentage points across
812 signal trades.

What to Use It For

Checking an ML indicator before you trust it. The method measured
here is the one most published ML indicators are built on: nearest-
neighbor classification over oscillator readings. If you use one, this
tells you what its timing was worth on your instrument, over a window
you choose.

Seeing what a win rate is worth without a control. Every cell in
this study has a raw win rate near 50% and a controlled result near
zero. The raw number and the meaningful number look nothing alike. Run
the script with the control switched off and back on to see it.

Testing the measurement itself. Everything here can be checked.
The synthetic mode lets you plant a pattern and confirm the instrument
finds it, before you believe anything it says about a real market.

The Result in Plain Language

Across three instruments at the default settings, the method's signals
won 48.8% of the time. Matched random entries on the same instruments
won 49.9%. The difference is -1.1 percentage points.

That difference is smaller than what this test could reliably detect.
On this sample the smallest difference the measurement could resolve is
about 2.9 percentage points. So the honest statement is not "the method
is worthless" - it is this:

On this sample, the method's signal timing cannot be told apart from
random timing, and any real advantage larger than about 3 percentage
points would have shown up.

The same answer came back on every configuration tested: different
numbers of neighbors, fewer features, different training lengths,
different targets, both timeframes, and a separate year of data that
shares no bars with the main window. Twenty configurations, and not one
of them produced a result large enough to be distinguished from chance.

The sharpest single test came from switching both of the method's
filters off, which produces far more signals and therefore a finer
measurement. 2,782 signal trades against 8,181 random ones:

[pine]
  Signals        49.784%
  Random         49.786%
  Difference     -0.002 percentage points
[/pine]

How the Test Works

The signal. The script rebuilds the published method from its
open source: five oscillator readings per bar, a search for past bars
whose readings look similar, and a vote among those neighbors. When
the vote changes sign, that is the signal, and that is the entry.

The trade. Every entry is taken at the close of the bar where
the signal appeared. A target and a stop are placed the same distance
above and below, measured in average true range, which is roughly how
far price travels in one bar. Whichever is reached first decides the
outcome. Trades that reach neither within the time limit are reported
separately and left out of the win rate.

The control. Each signal also creates three random entries, at
fixed distances later on the chart, in the same direction, with the
same target and stop distances. Nothing about them is tied to a signal.
They answer the question "what would any trade of this shape have
returned over this sample".

The comparison. Signals minus random entries, in percentage
points. That is the number this script exists to produce.

https://www.tradingview.com/x/0KKtg9SX/
The same chart and run as above, with the full accounting shown. Every
signal the method produced is followed down the panel into exactly one
outcome, and every random entry alongside it: 862 signals, 821 of them
inside the chosen date window, and 2,430 matched random entries built
from those. Nothing is discarded quietly - each rejected signal is
counted on its own line, the trades still running when the window ended
are counted too, and the error counter near the bottom has to read zero
for the run to be valid.

Validation

Two tests with known answers, both built into the script.

The blank test. Price is replaced with a random walk containing
no pattern at all. Both signals and random entries must then land at
50%. Across sixteen different random walks, signals came in at 49.88%
and random entries at 49.52%, a difference of 0.27 percentage points.
Nothing was found, because there was nothing there.

The planted test. A pattern is added to the artificial data, at
three strengths, sitting in exactly the measurements the method reads.
A simple rule that looks at that pattern directly gains more as the
pattern gets stronger:

[pine]
  Pattern strength    Simple rule beats random by
  none                     +0.45 points
  weak                     +3.90 points
  medium                  +11.60 points
  strong                  +25.15 points
[/pine]

This is what makes the market result believable. The measurement finds
a real edge when one is put there, and reports nothing when there is
nothing to find.

What the method did on the planted data. It went the other way.
The stronger the pattern, the further behind random timing it finished:
-2.48, then -6.75, then -9.40 percentage points. On the same bars, with
the same targets, the simple rule was gaining 25 points.

This is a result on artificial data with one setting per strength, and
it is reported as an observation, not an explanation. There is a
candidate reason in how the published method picks which past bars to
vote - it may keep the least similar ones rather than the most similar
- but that has not been tested and no claim is made here.

https://www.tradingview.com/x/LsWPntbh/
The test with a known answer. Price has been replaced by artificial
data carrying one deliberate, repeating pattern, so there is certainly
something to find. The lower block of the panel is a plain RSI rule
reading that pattern directly: it wins 75.9% against 50.6% for random
entries, a gap of 25.3 points. The upper block is the machine-learning
method given the same data: 39.7% against 49.3%, a gap of -9.6 points.
A simple rule found the pattern; the method finished behind random
timing. These figures move by a few tenths of a point as a chart loads
more bars, because this test uses all of them. The candles behind the
panel are artificial and show nothing meaningful.

Results

Baseline configuration, 30 minutes, 2025-01-01 to 2026-08-01, the
method's own default settings throughout:

[pine]
  Instrument   Signals   Random    Difference
  BTCUSDT       50.12%   49.52%    +0.60 pts
  EURUSD        47.24%   51.35%    -4.11 pts
  ES1!          48.68%   49.03%    -0.35 pts
  Pooled        48.84%   49.93%    -1.10 pts
[/pine]

The three instruments do not disagree by more than ordinary sampling
variation, so the pooled figure stands. The range of plausible values
around the pooled -1.10 runs from -3.6 to +1.5 percentage points, and
includes zero.

Every other configuration tested, all on BTCUSDT at 30 minutes:

[pine]
  Neighbors 2 / 8 / 32    +0.77 / +0.60 / +0.19 pts
  Two features only       +0.71 pts
  Training length 4 bars  +0.42 pts, 8 bars  +0.52 pts
  Shorter memory          +1.13 pts
  Targets 1x / 3x         +0.71 / +1.58 pts
[/pine]

On the hourly chart, across the same three instruments, +0.94 points.
Over calendar 2024, a window sharing no bars with the main one, -1.01
points. Both ranges of uncertainty include zero.

To reproduce these figures: the script's defaults match the
baseline. Switch the date range on, set 2025-01-01 to 2026-08-01, turn
compact panel mode off, and load the full chart history.

Terms Used in the Panel

Signals. Entries taken where the method's vote changed sign.

Random / placebo. Matched entries at fixed offsets later, same
direction and same target distances, anchored where no signal occurred.

Ambiguous outcome. A bar whose range contains both the target
and the stop. Bar data cannot show which came first, so the trade is
counted against the win rate - the cautious choice.

Censored outcome. A trade that reached neither target nor stop
before the time limit. Reported on its own and kept out of the win rate.

95% interval. The range of values the true answer plausibly sits
in. When it includes 50%, the result cannot be told apart from a coin
flip.

Smallest detectable difference. How small a difference this test
could have found on data with no edge. Anything smaller than it is not
evidence.

Settings

Classifier. Number of neighbors, training length, how many
oscillator readings to use, how far ahead the training labels look, and
which of the two labeling conventions to use. The method's own filters
can each be switched off.

Measurement. Target and stop size, the averaging length behind
them, and the time limit.

Control. How many random entries per signal and how far ahead
they are placed.

Sample. The date range uses explicit year, month and day fields
rather than a date picker, so a published sample can be reproduced
exactly.

Validation. Synthetic mode, seed, step size, drift, and the
planted-pattern strength.

Display. Compact panel, signal markers, marker size.

Limitations

The sample is smaller than intended. The target set before any
run was 1,000 completed trades per test. The main test produced 812,
and the platform's history limit made 1,000 unreachable at the
published settings on any instrument, timeframe or date range tried.
Every figure above is reported with the precision it actually achieved:
about 4.6 points for a single instrument and 2.9 points pooled.

The measurement has a small bias of its own. On data with no
edge, random entries come in at 49.62% rather than exactly 50%. Signals
carry the same offset, so it cancels when the two are subtracted, and
the difference on that data sits at +0.27 points. It is disclosed here
because it is real.

One decision was made after seeing data. When the validation
missed one of its own criteria by a small margin, the rule for what to
do next was written before the additional runs but after the result
that prompted them. That is a weaker guarantee than deciding everything
in advance, which is what the rest of this study did.

What was and was not measured. The classifier itself: readings,
similarity, neighbor vote, filters, entry when the vote flips. Not
included are the extra entry conditions and exit rules that individual
published indicators layer on top. Outcomes here are scored by a fixed
target-and-stop race, not by any indicator's own exits.

One family of method. Nearest-neighbor classification is one
class of ML indicator. These numbers apply to the method measured.

Loaded history bounds every test. How many bars your chart loads,
not only the calendar range, limits each run.

Direction splits are descriptive only. In a trending sample the
long and short win rates separate by around 20 points while the overall
comparison holds steady. Read the combined rows.

This is a measurement of the past. It reports what happened
under stated rules on stated samples. It does not predict anything.

Disclaimer

This script and its description are provided for educational and
research purposes only. They do not constitute financial, investment,
trading or other professional advice, and they do not recommend buying,
selling or holding any asset. Historical and simulated results do not
guarantee future performance. Trading involves risk, including the
possible loss of capital. You are solely responsible for your trading
and investment decisions and should conduct your own research and,
where appropriate, consult a qualified financial professional.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Algolego

//@version=6
// max_bars_back 500: the deepest explicit history offset is the label
// horizon (max 20); 500 covers it plus every feature warm-up with margin,
// and smaller per-series buffers matter on a script this close to the
// platform's runtime limit.
indicator("Machine Learning Signal Statistics: kNN Win Rate vs Random Entries", "ML Stats",
     overlay = true, max_bars_back = 500, max_labels_count = 500, max_lines_count = 500)

// =============================================================================
// Measures what a machine-learning signal's timing is worth, in percentage
// points of win rate, against matched random-timing entries.
//
// The rule under test is the widely published kNN classification method:
// normalized oscillator features (RSI, WaveTrend, CCI, ADX), a Lorentzian-
// distance neighbor vote over a bar-history training window, vote sign to
// signal, entry on signal flip. The classifier here is a reimplementation of
// that method as it appears in open source, faithful to the deployed code
// including its non-obvious properties (DESIGN.md 2.1-2.2): the as-coded
// label pairs each bar's features with the INVERTED direction of the 4-bar
// move that ended at that bar; the neighbor scan admits candidates in
// non-decreasing distance order, skips every 4th training index, and on
// overflow discards the earliest admission, so the retained set is the last
// k admissions, not the k nearest; the retained set persists across bars.
// Stated deviations (DESIGN.md 2.2): sliding recent training window, label
// horizon and label convention as inputs, no kernel/EMA/SMA overlay gates,
// no published exit logic, signals once per closed bar.
//
// Every admitted signal flip enters at that bar's close and races symmetric
// +/- kR ATR barriers. Each real entry queues matched placebo entries -- same
// direction, fixed bar offsets, own-bar ATR unit, identical race -- so real
// minus placebo is the classifier's timing edge with the path/drift baseline
// subtracted. Primary statistic: two-proportion z (DESIGN.md 3.3).
//
// SELF-TEST (DESIGN.md 8): on a driftless random walk both arms must sit at
// 50%. With a planted regularity (input g > 0: a mean-reverting pull keyed to
// RSI(14) of the previous bar's close, expressible in the classifier's own
// feature space), an ORACLE rule that reads RSI directly must beat its own
// placebos -- that detection validates the harness. The classifier's own
// performance on planted data is a recorded measurement, not a gate.
//
// Implementation mandates honoured (DESIGN.md 5): all ta.* and feature calls
// unconditional at global scope on the routed series; the neighbor loop at
// global scope; training arrays size-checked every bar; feature/filter
// functions contain no bare history lookups on globals (the defect class
// that voided OB run 0a) -- every series they touch arrives as an argument
// or is function-local state, and every call site executes on every bar.
//
// This script itself does not repaint: markers are created at the signal
// bar's close and never modified.
// =============================================================================

// ---------------------------------------------------------------- inputs ----
// Classifier defaults are the flagship source defaults (reference/lc_v1.pine),
// so the measured configuration is the deployed one. The five features are
// fixed to the canonical set; Feature count selects a prefix of it, as in the
// source's featureCount switch.
grpC = "Classifier (canonical kNN)"
kNbr     = input.int(8, "Neighbors k", minval = 1, maxval = 100, group = grpC)
maxBack  = input.int(2000, "Training window (bars)", minval = 100, maxval = 4500, group = grpC,
     tooltip = "Sliding window of the most recent training bars searched for " +
     "neighbors. Signals are admitted only once the window is full.")
featCnt  = input.int(5, "Feature count", minval = 2, maxval = 5, group = grpC,
     tooltip = "Uses the first N of: RSI(14,1), WT(10,11), CCI(20,1), " +
     "ADX(20,2), RSI(9,1).")
labelH   = input.int(4, "Label horizon (bars)", minval = 1, maxval = 20, group = grpC,
     tooltip = "The source hardcodes 4. Exposed as a sweep dimension.")
labelCnv = input.string("As coded (contrarian)", "Label convention",
     options = ["As coded (contrarian)", "Textbook (predictive)"], group = grpC,
     tooltip = "As coded: each bar's features are paired with the inverted " +
     "direction of the completed move into that bar -- what the deployed " +
     "method does. Textbook: features are paired with the direction of the " +
     "move that follows, pushed only once the horizon has closed -- what " +
     "its description says it does.")
useVolF  = input.bool(true, "Volatility filter", group = grpC, inline = "f1")
useRegF  = input.bool(true, "Regime filter", group = grpC, inline = "f1")
useAdxF  = input.bool(false, "ADX filter", group = grpC, inline = "f2")
regThr   = input.float(-0.1, "Regime threshold", minval = -10, maxval = 10, step = 0.1, group = grpC)
adxThr   = input.int(20, "ADX threshold", minval = 0, maxval = 100, group = grpC)
minSep   = input.int(0, "Minimum separation (bars, 0 = off)", minval = 0, group = grpC,
     tooltip = "Optional. Rejects a signal closer than this to the previous " +
     "accepted signal in the same direction.")

grpM = "Measurement"
atrLen  = input.int(14, "ATR length", minval = 1, group = grpM,
     tooltip = "Each entry's risk unit is ATR at its own entry bar.")
kR      = input.float(2.0, "Barrier size (R)", minval = 0.1, step = 0.1, group = grpM)
maxBars = input.int(100, "Time limit after entry (bars)", minval = 1, group = grpM)

grpN = "Placebo control"
usePlac = input.bool(true, "Run placebo control", group = grpN)
nPlac   = input.int(3, "Placebos per real entry", minval = 1, maxval = 10, group = grpN)
offBase = input.int(211, "Placebo offset (bars)", minval = 10, group = grpN)

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
synReg   = input.float(0.0, "Planted regularity strength g (0 = none)", minval = 0,
     step = 0.25, group = grpS,
     tooltip = "Adds a mean-reverting pull keyed to RSI(14) of the previous " +
     "bar's close: pull = -g * substep * (RSI - 50) / 50. A causally " +
     "knowable pattern in the classifier's own feature space. The oracle " +
     "rule reads the same RSI directly and must detect it (DESIGN.md 4.2-4.3).")

grpD = "Display"
compact  = input.bool(true, "Compact panel", group = grpD)
showSig  = input.bool(true, "Draw signal markers", group = grpD)
lgPos    = input.string("Bottom right", "Legend position",
     options = ["Top left", "Top center", "Top right",
                "Middle left", "Middle center", "Middle right",
                "Bottom left", "Bottom center", "Bottom right"], group = grpD,
     tooltip = "Where the marker key sits. No corner is safe on every " +
     "chart: bottom-left carries TradingView's logo, top-left the symbol " +
     "and indicator names, top-right this script's statistics panel, and " +
     "price itself can occupy any band.")
showLgnd = input.bool(true, "Show marker legend", group = grpD,
     tooltip = "A separate key in the lower-left corner naming what each " +
     "marker is. Kept out of the statistics panel: that panel is a dense " +
     "read-out, and a legend buried in it is not a legend.")
showPlac = input.bool(false, "Draw placebo markers", group = grpD,
     tooltip = "Marks where the matched random entries were taken. Off by " +
     "default because there are three of them per signal. Drawn with " +
     "plotshape rather than labels: labels are capped at 500 per script " +
     "and the placebo population is far larger than that.")
// Numeric because the label size constants bottom out at tiny (~8pt).
mrkSize  = input.int(6, "Marker size", minval = 1, maxval = 20, group = grpD)
mrkOff   = input.float(0.5, "Marker offset (ATR)", minval = 0, step = 0.1, group = grpD,
     tooltip = "How far the marker sits from the bar, in risk units. " +
     "0 places it against the bar as yloc.belowbar would.")

// ------------------------------------------------------- synthetic series ---
// Four sub-steps per bar so synthetic bars carry a real intrabar path,
// inherited from scripts #2 and #3. New here: the planted-regularity pull.
// ta.rsi consumes synPrev BEFORE this bar is built, so its internal series is
// the close of bar t-1 -- the pull at bar t depends only on completed bars,
// per DESIGN.md 4.2. With synth off, synPrev never updates and the RSI of a
// constant is na; nz routes that to a zero pull.
var float synPrev = 10000.0

pullRsi = ta.rsi(synPrev, 14)
pull    = synth ? -synReg * synVol * (nz(pullRsi, 50.0) - 50.0) / 50.0 : 0.0

r1 = math.random(-1.0, 1.0, synSeed)
r2 = math.random(-1.0, 1.0, synSeed + 1)
r3 = math.random(-1.0, 1.0, synSeed + 2)
r4 = math.random(-1.0, 1.0, synSeed + 3)

d4     = (synDrift + pull) / 4.0
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
_hlc3  = (_high + _low + _close) / 3
_ohlc4 = (_open + _high + _low + _close) / 4

// True range from the routed series, so ATR is correct in both modes.
_tr = na(_close[1]) ? _high - _low :
     math.max(_high - _low, math.max(math.abs(_high - _close[1]), math.abs(_low - _close[1])))
atr = ta.rma(_tr, atrLen)

// -------------------------------------------- feature functions (ported) ----
// Transcribed from reference/mlext_v1.pine (FIDELITY.md maps every line).
// Every series these functions touch arrives as an argument; internal state
// is ta.* or var locals, valid because every call site below executes
// unconditionally on every bar.

// mlext_v1.pine:46 -- rescale a bounded range to another bounded range.
rescale(float src, float oldMin, float oldMax, float newMin, float newMax) =>
    newMin + (newMax - newMin) * (src - oldMin) / math.max(oldMax - oldMin, 10e-10)

// mlext_v1.pine:32 -- running historical min-max. Each call site keeps its
// own var state; the source constant 10e10 (= 1e11) is kept verbatim.
normalize(float src, float mn, float mx) =>
    var float hMin =  10e10
    var float hMax = -10e10
    hMin := math.min(nz(src, hMin), hMin)
    hMax := math.max(nz(src, hMax), hMax)
    mn + (mx - mn) * (src - hMin) / math.max(hMax - hMin, 10e-10)

// mlext_v1.pine:120
n_rsi(float src, simple int n1, simple int n2) =>
    rescale(ta.ema(ta.rsi(src, n1), n2), 0, 100, 0, 1)

// mlext_v1.pine:128
n_cci(float src, simple int n1, simple int n2) =>
    normalize(ta.ema(ta.cci(src, n1), n2), 0, 1)

// mlext_v1.pine:137
n_wt(float src, simple int n1, simple int n2) =>
    ema1 = ta.ema(src, n1)
    ema2 = ta.ema(math.abs(src - ema1), n1)
    ci = (src - ema1) / (0.015 * ema2)
    wt1 = ta.ema(ci, n2)
    wt2 = ta.sma(wt1, 4)
    normalize(wt1 - wt2, 0, 1)

// mlext_v1.pine:150 -- the library's hand-rolled Wilder ADX, kept as coded
// (including the unused th local being dropped and the nz seeds).
n_adx(float highSrc, float lowSrc, float closeSrc, simple int n1) =>
    tr = math.max(math.max(highSrc - lowSrc, math.abs(highSrc - nz(closeSrc[1]))),
         math.abs(lowSrc - nz(closeSrc[1])))
    dmPlus = highSrc - nz(highSrc[1]) > nz(lowSrc[1]) - lowSrc ?
         math.max(highSrc - nz(highSrc[1]), 0) : 0
    dmNeg = nz(lowSrc[1]) - lowSrc > highSrc - nz(highSrc[1]) ?
         math.max(nz(lowSrc[1]) - lowSrc, 0) : 0
    trSmooth = 0.0
    trSmooth := nz(trSmooth[1]) - nz(trSmooth[1]) / n1 + tr
    smPlus = 0.0
    smPlus := nz(smPlus[1]) - nz(smPlus[1]) / n1 + dmPlus
    smNeg = 0.0
    smNeg := nz(smNeg[1]) - nz(smNeg[1]) / n1 + dmNeg
    diPos = smPlus / trSmooth * 100
    diNeg = smNeg / trSmooth * 100
    dx = math.abs(diPos - diNeg) / (diPos + diNeg) * 100
    adxV = ta.rma(dx, n1)
    rescale(adxV, 0, 100, 0, 1)

// ---------------------------------------------------------------- features --
// The canonical set (lc_v1.pine:211-235): RSI and CCI on close, WT on hlc3,
// ADX on high/low/close -- here the routed equivalents. Parameters are the
// source defaults, fixed; Feature count selects a prefix.
f1 = n_rsi(_close, 14, 1)
f2 = n_wt(_hlc3, 10, 11)
f3 = n_cci(_close, 20, 1)
f4 = n_adx(_high, _low, _close, 20)
f5 = n_rsi(_close, 9, 1)

// ----------------------------------------------------------------- filters --
// Transcribed from mlext_v1.pine at global scope, on the routed series.

// filter_volatility (mlext_v1.pine:221): ta.atr(1) > ta.atr(10). ta.atr(n) is
// rma of true range, so the routed equivalent is rma of the routed TR.
volPass = useVolF ? ta.rma(_tr, 1) > ta.rma(_tr, 10) : true

// regime_filter (mlext_v1.pine:178), called on ohlc4 in the source
// (lc_v1.pine:283). The source's value2 reads the bar range; routed here.
// Non-var locals with nz() self-history reproduce the source's seeding: an
// na assignment on the first bar does not stick.
float rgV1 = 0.0
float rgV2 = 0.0
float rgKlmf = 0.0
rgV1 := 0.2 * (_ohlc4 - _ohlc4[1]) + 0.8 * nz(rgV1[1])
rgV2 := 0.1 * (_high - _low) + 0.8 * nz(rgV2[1])
rgOmega = math.abs(rgV1 / rgV2)
rgAlpha = (-math.pow(rgOmega, 2) +
     math.sqrt(math.pow(rgOmega, 4) + 16 * math.pow(rgOmega, 2))) / 8
rgKlmf := rgAlpha * _ohlc4 + (1 - rgAlpha) * nz(rgKlmf[1])
rgSlope = math.abs(rgKlmf - rgKlmf[1])
rgEma   = ta.ema(rgSlope, 200)
regimePass = useRegF ? (rgSlope - rgEma) / rgEma >= regThr : true

// filter_adx (mlext_v1.pine:200), length 14 as wired in lc_v1.pine:284,
// on the routed series (the source reads settings.source = close and the
// built-in high/low).
fTr = math.max(math.max(_high - _low, math.abs(_high - nz(_close[1]))),
     math.abs(_low - nz(_close[1])))
fDmPlus = _high - nz(_high[1]) > nz(_low[1]) - _low ?
     math.max(_high - nz(_high[1]), 0) : 0
fDmNeg = nz(_low[1]) - _low > _high - nz(_high[1]) ?
     math.max(nz(_low[1]) - _low, 0) : 0
float fTrS = 0.0
float fSmP = 0.0
float fSmN = 0.0
fTrS := nz(fTrS[1]) - nz(fTrS[1]) / 14 + fTr
fSmP := nz(fSmP[1]) - nz(fSmP[1]) / 14 + fDmPlus
fSmN := nz(fSmN[1]) - nz(fSmN[1]) / 14 + fDmNeg
fDiP = fSmP / fTrS * 100
fDiN = fSmN / fTrS * 100
fDx  = math.abs(fDiP - fDiN) / (fDiP + fDiN) * 100
fAdx = ta.rma(fDx, 14)
adxPass = useAdxF ? fAdx > adxThr : true

filterAll = volPass and regimePass and adxPass

// ----------------------------------------------------------- training set ---
// One training point per bar, as in the source (lc_v1.pine:239-248, 312,
// 320). A point's index in the source's untrimmed arrays is fixed for life,
// and the scan's i%4 rule permanently excludes every index divisible by 4 --
// so those points are dropped HERE, at push time, instead of being stored
// and skipped on every later scan (25% of iterations; part of the runtime
// response to the platform's 20 s limit, FIDELITY.md sampling-rule row).
// nPushed keeps counting in the source's full index space; the scan maps
// its window into the compacted arrays arithmetically. The admitted set is
// unchanged by construction.
//
// As-coded label (lc_v1.pine:311): a completed rise into this bar is
// labeled short, paired with THIS bar's features; na comparisons on early
// bars yield the neutral label, as in the source. Textbook label: this bar's
// close against the close labelH bars back, paired with the features of that
// earlier bar, pushed only now that the horizon has closed -- na features on
// early bars are pushed as na in both conventions, again as in the source;
// an na distance fails every admission test.
asCoded = labelCnv == "As coded (contrarian)"

var array<float> f1Arr = array.new<float>()
var array<float> f2Arr = array.new<float>()
var array<float> f3Arr = array.new<float>()
var array<float> f4Arr = array.new<float>()
var array<float> f5Arr = array.new<float>()
var array<int>   yArr  = array.new<int>()
var int nPushed   = 0    // full-space training index counter (source semantics)
var int nTrainErr = 0    // integrity: any array size off its expected count

// Kept indices in [0, x): those not divisible by 4.
kept(int x) => x - int(math.ceil(x / 4.0))

if asCoded
    int yLab = _close[labelH] < _close ? -1 : _close[labelH] > _close ? 1 : 0
    if nPushed % 4 != 0
        array.push(f1Arr, f1)
        array.push(f2Arr, f2)
        array.push(f3Arr, f3)
        array.push(f4Arr, f4)
        array.push(f5Arr, f5)
        array.push(yArr, yLab)
    nPushed += 1
else if bar_index >= labelH
    int yLab = _close > _close[labelH] ? 1 : _close < _close[labelH] ? -1 : 0
    if nPushed % 4 != 0
        array.push(f1Arr, f1[labelH])
        array.push(f2Arr, f2[labelH])
        array.push(f3Arr, f3[labelH])
        array.push(f4Arr, f4[labelH])
        array.push(f5Arr, f5[labelH])
        array.push(yArr, yLab)
    nPushed += 1

expKept = kept(nPushed)
if array.size(yArr) != expKept or array.size(f1Arr) != expKept or
     array.size(f2Arr) != expKept or array.size(f3Arr) != expKept or
     array.size(f4Arr) != expKept or array.size(f5Arr) != expKept
    nTrainErr += 1

// ---------------------------------------------------------- neighbor scan ---
// The source loop (lc_v1.pine:361-379), at global scope per the DESIGN.md 5
// mandate. Faithful properties: the retained-neighbor arrays are var and are
// NEVER cleared, so the set persists and rolls across bars; lastDist resets
// every bar; admission needs d >= lastDist AND a training index not divisible
// by 4; on overflow lastDist is raised to the element at round(k*3/4) and the
// earliest admission is shifted out.
//
// Order-preserving optimizations (FIDELITY.md, distance rows), forced by the
// platform's 20-second runtime limit on full charts:
//   1. Indices divisible by 4 skip the distance entirely -- the source
//      computes d first and discards it; those candidates can never be
//      admitted, so no admitted pair changes.
//   2. The distance is the PRODUCT prod(1 + |df|) instead of the source's
//      log-sum sum(log(1 + |df|)) = log(prod(1 + |df|)). log is strictly
//      increasing, distances are only ever compared (d >= lastDist, and the
//      kIdx element read back into lastDist), and lastDist's -1.0 reset
//      admits the scan's first candidate in both formulations (log-sums are
//      >= 0, products >= 1). Every admission decision, the retained set,
//      and the prediction are identical; only the stored magnitudes differ.
//      Features are bounded to [0,1], so factors are <= 2 and a 5-feature
//      product is <= 32: no overflow.
//   3. The 5-feature default runs an unrolled loop with no per-iteration
//      conditionals, mirroring the source's per-featureCount switch; other
//      counts take the generic loop.
//   4. Indices divisible by 4 are dropped at push time (training-set block
//      above), so the scan iterates only admissible candidates: the window
//      [nPushed-maxBack, nPushed) in the source's full index space maps to
//      [kept(nPushed-maxBack), kept(nPushed)) in the compacted arrays, in
//      the same order, and the i%4 test leaves the loop.
var array<float> knnDist = array.new<float>()
var array<float> knnPred = array.new<float>()
var float prediction = 0.0

winFull   = nPushed >= maxBack
fullStart = math.max(0, nPushed - maxBack)
cStart    = kept(fullStart)
cEnd      = array.size(yArr) - 1
kIdx      = math.round(kNbr * 3 / 4)

float lastDist = -1.0
if winFull
    if featCnt == 5
        for i = cStart to cEnd
            d = (1 + math.abs(f1 - array.get(f1Arr, i))) *
                 (1 + math.abs(f2 - array.get(f2Arr, i))) *
                 (1 + math.abs(f3 - array.get(f3Arr, i))) *
                 (1 + math.abs(f4 - array.get(f4Arr, i))) *
                 (1 + math.abs(f5 - array.get(f5Arr, i)))
            if d >= lastDist
                lastDist := d
                array.push(knnDist, d)
                array.push(knnPred, float(array.get(yArr, i)))
                if array.size(knnPred) > kNbr
                    lastDist := array.get(knnDist, kIdx)
                    array.shift(knnDist)
                    array.shift(knnPred)
    else
        for i = cStart to cEnd
            d = (1 + math.abs(f1 - array.get(f1Arr, i))) *
                 (1 + math.abs(f2 - array.get(f2Arr, i))) *
                 (featCnt >= 3 ? 1 + math.abs(f3 - array.get(f3Arr, i)) : 1.0) *
                 (featCnt >= 4 ? 1 + math.abs(f4 - array.get(f4Arr, i)) : 1.0)
            if d >= lastDist
                lastDist := d
                array.push(knnDist, d)
                array.push(knnPred, float(array.get(yArr, i)))
                if array.size(knnPred) > kNbr
                    lastDist := array.get(knnDist, kIdx)
                    array.shift(knnDist)
                    array.shift(knnPred)
    prediction := array.sum(knnPred)

// ------------------------------------------------------------------ signal --
// lc_v1.pine:387-390: sign of the vote sum, gated by the filters, holding the
// previous value when neither side fires. A signal flip to a nonzero
// direction is the event (DESIGN.md 2.3); persistence makes same-direction
// consecutive flips impossible.
var int signal = 0
signal := prediction > 0 and filterAll ? 1 :
     prediction < 0 and filterAll ? -1 : signal

sigFlip = signal != signal[1] and signal != 0

// ------------------------------------------------------------------ oracle --
// DESIGN.md 4.3: reads the planted state through the same public statistic
// the generator keys on -- RSI(14) of the routed close -- exactly as a user
// indicator would, never the generator's internals. Cross events, so oracle
// entries are naturally separated. Scored only in synthetic mode.
oRsi   = ta.rsi(_close, 14)
oLong  = ta.crossunder(oRsi, 35.0)
oShort = ta.crossover(oRsi, 65.0)

// ----------------------------------------------------------------- types ----
type Trade
    int   dir       // +1 long, -1 short
    int   kind      // 0 real, 1 real placebo, 2 oracle, 3 oracle placebo
    float entry
    int   entryBar
    float target
    float stopP
    int   outcome = 0    // 0 pending, 1 target, 2 stop, 3 ambiguous, 4 censored
    int   resBar  = na

type PendQ
    int dueBar
    int dir
    int kind

type Stats
    int nTarget = 0
    int nStop   = 0
    int nAmbig  = 0
    int nCens   = 0
    int bullT   = 0    // directional split: wins / resolved, per side
    int bullD   = 0
    int bearT   = 0
    int bearD   = 0
    float sumHold = 0.0    // total bars held, for the overlap diagnostic
    array<int> resBars

// ------------------------------------------------------------- functions ----
// None of these touches series history; every price arrives as an argument.
newStats() => Stats.new(resBars = array.new<int>())

// Advance one trade through one bar's extremes. One bar containing both
// barriers cannot be ordered from OHLC: ambiguous. Inherited from script #3.
stepTrade(Trade t, float hi, float lo, int curBar, int limitBars) =>
    bool done = false
    if t.outcome == 0
        isBull = t.dir > 0
        hitT = isBull ? hi >= t.target : lo <= t.target
        hitS = isBull ? lo <= t.stopP  : hi >= t.stopP
        t.outcome := hitT and hitS ? 3 : hitT ? 1 : hitS ? 2 :
             curBar - t.entryBar >= limitBars ? 4 : 0
        if t.outcome != 0
            t.resBar := curBar
            done := true
    done

// Censored trades leave the hit-rate denominator; ambiguous stays in it and
// out of the numerator, i.e. it counts against the rate. Inherited rule.
recordTrade(Stats s, Trade t) =>
    if t.outcome == 1
        s.nTarget := s.nTarget + 1
    else if t.outcome == 2
        s.nStop := s.nStop + 1
    else if t.outcome == 3
        s.nAmbig := s.nAmbig + 1
    else if t.outcome == 4
        s.nCens := s.nCens + 1
    // Summed holding time integrates the open-trade count over bars, so
    // sumHold / bars is the mean concurrency without a per-bar loop.
    s.sumHold := s.sumHold + (t.resBar - t.entryBar)
    if t.outcome != 4
        array.push(s.resBars, t.resBar - t.entryBar)
        won = t.outcome == 1
        if t.dir > 0
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

// Theme-aware palette, carried from scripts #1-#3.
COL_TXT  = color.new(chart.fg_color, 35)
COL_VAL  = chart.fg_color
COL_UP   = #26A69A
COL_DOWN = #EF5350
COL_WARN = #FFA726

// Signal markers get their own colours rather than reusing the panel's
// candle-toned palette: brighter and more saturated, so a marker cannot
// be mistaken for a candle of its own direction. Display only.
MRK_UP   = #00E676
MRK_DOWN = #FF1744
// Placebos are the control, not a signal: drawn in the chart's own
// foreground colour so they stay visible on either theme, and kept
// neutral so they read as background against the two signal colours.
// A fixed grey was tried first and was invisible on a dark chart.
MRK_PLAC = color.new(chart.fg_color, 15)

pct(float v) => na(v) ? "--" : str.tostring(v * 100, "#.#") + "%"
num(float v) => na(v) ? "--" : str.tostring(v, "#.##")
dat(int t) => na(t) ? "--" : str.format_time(t, "yyyy-MM-dd", syminfo.timezone)

// 35 rows are emitted at most (non-compact, synthetic). Sized to 44 so a
// future row cannot silently overflow; table.clear below must stay in step.
var table tb = table.new(position.top_right, 2, 44, border_width = 1,
     bgcolor = color.new(chart.bg_color, 0),
     frame_color = color.new(chart.fg_color, 65), frame_width = 1)

// Marker key, its own table, separate from the statistics panel on
// purpose: a scanner reading a screenshot should meet the key
// immediately, not hunt for one row inside a read-out.
// Position is an input because no corner is free on every chart: the
// logo owns bottom-left, the chart's own names own top-left, the
// statistics panel owns top-right, and price can sit in any band.
lgAt = lgPos == "Top left" ? position.top_left :
     lgPos == "Top center" ? position.top_center :
     lgPos == "Top right" ? position.top_right :
     lgPos == "Middle left" ? position.middle_left :
     lgPos == "Middle center" ? position.middle_center :
     lgPos == "Middle right" ? position.middle_right :
     lgPos == "Bottom left" ? position.bottom_left :
     lgPos == "Bottom center" ? position.bottom_center : position.bottom_right
var table lg = table.new(lgAt, 1, 4, border_width = 1,
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
inRange = not useRange or (time >= startT and time <= endT)
featOk  = not na(f1) and not na(f2) and (featCnt < 3 or not na(f3)) and
     (featCnt < 4 or not na(f4)) and (featCnt < 5 or not na(f5))

var array<Trade> active = array.new<Trade>()
var array<PendQ> queued = array.new<PendQ>()
var Stats sReal = newStats()
var Stats sPlac = newStats()
var Stats sOrac = newStats()
var Stats sOplc = newStats()

// Funnels (DESIGN.md 3.4). Every flip and every queued placebo ends in
// exactly one bucket; residuals must read zero.
var int nFlips    = 0
var int nRangeR   = 0
var int nFeatNa   = 0    // the admission guard makes this the only feature-na
                         // path; an admitted event with na features is
                         // impossible by the same expression
var int nAtrNaR   = 0
var int nSepR     = 0
var int nEvReal   = 0
var int nEvBull   = 0
var int nEvBear   = 0
var int nNbShort  = 0    // events entered with fewer than k retained neighbors
var int lastBullEv = na
var int lastBearEv = na

var int nOCross   = 0
var int nRangeO   = 0
var int nAtrNaO   = 0
var int nSepO     = 0
var int nEvOrac   = 0
var int lastOBull = na
var int lastOBear = na

var int nQReal    = 0    // placebos queued, by parent kind
var int nQOrac    = 0
var int nRangeP   = 0
var int nAtrNaP   = 0
var int nEvPlac   = 0
var int nRangePO  = 0
var int nAtrNaPO  = 0
var int nEvOplc   = 0

// Sample diagnostics, inherited from script #3.
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

// ------------------------------------------------------------ evaluation ----
// Steps yesterday's open trades through this bar. Runs before any entry is
// created on this bar; the bar_index > entryBar guard additionally keeps an
// entry bar out of its own race (nothing is left of a bar once filled at its
// close -- the inherited rule).
if array.size(active) > 0
    for i = array.size(active) - 1 to 0
        t = array.get(active, i)
        if bar_index > t.entryBar
            if stepTrade(t, _high, _low, bar_index, maxBars)
                if t.kind == 0
                    recordTrade(sReal, t)
                else if t.kind == 1
                    recordTrade(sPlac, t)
                else if t.kind == 2
                    recordTrade(sOrac, t)
                else
                    recordTrade(sOplc, t)
                array.remove(active, i)

// Set when a real-arm placebo enters on this bar, so the plotshape calls
// below can mark it. Plain locals, reset every bar.
bool placUp = false
bool placDn = false

// -------------------------------------------------- placebo activation ------
// A due placebo enters at this bar's close with its stored direction, its own
// ATR unit, and the same admission checks as a real entry (DESIGN.md 3.2).
// Still-queued entries at the last bar are the beyond-history bucket.
if array.size(queued) > 0
    for i = array.size(queued) - 1 to 0
        q = array.get(queued, i)
        if bar_index >= q.dueBar
            isOrc = q.kind == 3
            if not inRange
                if isOrc
                    nRangePO += 1
                else
                    nRangeP += 1
            else if na(atr) or atr <= 0
                if isOrc
                    nAtrNaPO += 1
                else
                    nAtrNaP += 1
            else
                r = kR * atr
                array.push(active, Trade.new(dir = q.dir, kind = q.kind,
                     entry = _close, entryBar = bar_index,
                     target = q.dir > 0 ? _close + r : _close - r,
                     stopP  = q.dir > 0 ? _close - r : _close + r))
                if isOrc
                    nEvOplc += 1
                else
                    nEvPlac += 1
                    if q.dir > 0
                        placUp := true
                    else
                        placDn := true
            array.remove(queued, i)

// -------------------------------------------------------- event creation ----
// Real classifier events: a signal flip on a bar passing the admission
// checks. The flip itself is only possible once the training window is full,
// because the prediction stays zero until then.
if sigFlip
    nFlips += 1
    dir = signal
    if not inRange
        nRangeR += 1
    else if not featOk
        nFeatNa += 1
    else if na(atr) or atr <= 0
        nAtrNaR += 1
    else if minSep > 0 and not na(dir > 0 ? lastBullEv : lastBearEv) and
         bar_index - (dir > 0 ? lastBullEv : lastBearEv) < minSep
        nSepR += 1
    else
        r = kR * atr
        array.push(active, Trade.new(dir = dir, kind = 0,
             entry = _close, entryBar = bar_index,
             target = dir > 0 ? _close + r : _close - r,
             stopP  = dir > 0 ? _close - r : _close + r))
        nEvReal += 1
        if array.size(knnPred) < kNbr
            nNbShort += 1
        if dir > 0
            nEvBull += 1
            lastBullEv := bar_index
        else
            nEvBear += 1
            lastBearEv := bar_index
        if usePlac
            for j = 1 to nPlac
                array.push(queued, PendQ.new(bar_index + offBase * j, dir, 1))
                nQReal += 1
        if showSig and not synth
            // label_up sits below the bar pointing up at it, label_down
            // above pointing down - the shape convention the ML indicator
            // family uses for its own signals.
            // Placed at an explicit price rather than yloc.belowbar/abovebar,
            // whose gap is fixed and small. Offset in ATR keeps the spacing
            // visually constant across instruments and timeframes. Measured
            // from the bar's own extreme, so the marker never overlaps the
            // bar it belongs to (the defect script #3 hit by anchoring on
            // the entry price).
            label.new(bar_index,
                 dir > 0 ? _low - mrkOff * atr : _high + mrkOff * atr, "",
                 style = dir > 0 ? label.style_label_up : label.style_label_down,
                 color = dir > 0 ? MRK_UP : MRK_DOWN, size = mrkSize,
                 yloc = yloc.price)

// Oracle events: RSI cross rule, synthetic mode only, same admission checks
// and same window gate so the oracle's sample covers the same bars the
// classifier's could.
for od = 0 to 1
    isBullO = od == 0
    if synth and winFull and (isBullO ? oLong : oShort)
        nOCross += 1
        dirO = isBullO ? 1 : -1
        if not inRange
            nRangeO += 1
        else if na(atr) or atr <= 0
            nAtrNaO += 1
        else if minSep > 0 and not na(isBullO ? lastOBull : lastOBear) and
             bar_index - (isBullO ? lastOBull : lastOBear) < minSep
            nSepO += 1
        else
            r = kR * atr
            array.push(active, Trade.new(dir = dirO, kind = 2,
                 entry = _close, entryBar = bar_index,
                 target = dirO > 0 ? _close + r : _close - r,
                 stopP  = dirO > 0 ? _close - r : _close + r))
            nEvOrac += 1
            if isBullO
                lastOBull := bar_index
            else
                lastOBear := bar_index
            if usePlac
                for j = 1 to nPlac
                    array.push(queued, PendQ.new(bar_index + offBase * j, dirO, 3))
                    nQOrac += 1

// ------------------------------------------------------- placebo markers ----
// plotshape, not label.new: there are three placebos per signal and Pine
// caps a script at 500 labels, so labels would show only the most recent
// slice of the population. Same direction convention as the signal markers
// -- long below the bar, short above it. Kept at size.tiny: plotshape
// sizes are shape sizes while the signal markers are labels sized in
// points, so size.small circles dwarfed the signal pins. The control
// should read as background, not compete with the signals.
plotshape(showPlac and not synth and placUp, "Random entry (long)",
     shape.circle, location.belowbar, MRK_PLAC, size = size.tiny)
plotshape(showPlac and not synth and placDn, "Random entry (short)",
     shape.circle, location.abovebar, MRK_PLAC, size = size.tiny)

// ---------------------------------------------------------------- readout ---
if barstate.islast
    // Per-arm rates. Resolved = target + stop + ambiguous.
    dR = sReal.nTarget + sReal.nStop + sReal.nAmbig
    dP = sPlac.nTarget + sPlac.nStop + sPlac.nAmbig
    dO = sOrac.nTarget + sOrac.nStop + sOrac.nAmbig
    dQ = sOplc.nTarget + sOplc.nStop + sOplc.nAmbig
    hrR = hr2(sReal.nTarget, dR)
    hrP = hr2(sPlac.nTarget, dP)
    hrO = hr2(sOrac.nTarget, dO)
    hrQ = hr2(sOplc.nTarget, dQ)
    [rLo, rHi] = wilson(sReal.nTarget, dR)
    [pLo, pHi] = wilson(sPlac.nTarget, dP)
    [oLo, oHi] = wilson(sOrac.nTarget, dO)
    [qLo, qHi] = wilson(sOplc.nTarget, dQ)
    zR = dR > 0 ? (hrR - 0.5) * 2 * math.sqrt(dR) : na
    zP = dP > 0 ? (hrP - 0.5) * 2 * math.sqrt(dP) : na

    // Primary statistic (DESIGN.md 3.3): real minus placebo, two-proportion z.
    dlt = na(hrR) or na(hrP) ? na : hrR - hrP
    zD  = twoProp(sReal.nTarget, dR, sPlac.nTarget, dP)
    dltO = na(hrO) or na(hrQ) ? na : hrO - hrQ
    zO   = twoProp(sOrac.nTarget, dO, sOplc.nTarget, dQ)

    // Open trades and funnel residuals. Every counter reconciles against its
    // parent; a nonzero residual means a reject path is missing a counter.
    int opnR = 0
    int opnP = 0
    int opnO = 0
    int opnQ = 0
    if array.size(active) > 0
        for i = 0 to array.size(active) - 1
            t = array.get(active, i)
            if t.kind == 0
                opnR += 1
            else if t.kind == 1
                opnP += 1
            else if t.kind == 2
                opnO += 1
            else
                opnQ += 1
    int quR = 0
    int quO = 0
    if array.size(queued) > 0
        for i = 0 to array.size(queued) - 1
            quR += array.get(queued, i).kind == 1 ? 1 : 0
            quO += array.get(queued, i).kind == 3 ? 1 : 0

    residF  = nFlips - (nRangeR + nFeatNa + nAtrNaR + nSepR + nEvReal)
    residE  = nEvReal - (dR + sReal.nCens + opnR)
    residP  = nQReal - (nRangeP + nAtrNaP + nEvPlac + quR)
    residEP = nEvPlac - (dP + sPlac.nCens + opnP)
    residO  = nOCross - (nRangeO + nAtrNaO + nSepO + nEvOrac)
    residEO = nEvOrac - (dO + sOrac.nCens + opnO)
    residQ  = nQOrac - (nRangePO + nAtrNaPO + nEvOplc + quO)
    residEQ = nEvOplc - (dQ + sOplc.nCens + opnQ)
    residAll = math.abs(residF) + math.abs(residE) + math.abs(residP) +
         math.abs(residEP) + math.abs(residO) + math.abs(residEO) +
         math.abs(residQ) + math.abs(residEQ)

    // Overlap diagnostic (DESIGN.md failure mode 6): mean open trades per
    // bar, obtained as total held bars over loaded bars. Near 1 means races
    // rarely coexist; well above 1 means most of the sample is correlated.
    // Trades still open at the last bar contribute nothing, and the
    // denominator includes the training warm-up during which no entry can
    // exist, so the value understates by roughly the warm-up fraction --
    // about 7% at window 2000 on a 28.7k-bar chart.
    concR = nBarsAll > 0 ? sReal.sumHold / nBarsAll : na
    concP = nBarsAll > 0 ? sPlac.sumHold / nBarsAll : na
    concO = nBarsAll > 0 ? sOrac.sumHold / nBarsAll : na
    concQ = nBarsAll > 0 ? sOplc.sumHold / nBarsAll : na

    medR = array.size(sReal.resBars) > 0 ? array.median(sReal.resBars) : na
    medP = array.size(sPlac.resBars) > 0 ? array.median(sPlac.resBars) : na
    degen = not na(medR) and medR <= 2

    // Per-seed verdict (DESIGN.md 8.1 G2 for the null runs): on a driftless
    // unplanted walk the real arm's interval must contain 50%, with clean
    // funnels and zero integrity errors. Pooled criteria (G1, G3-G6) are
    // scored across seeds, not here. With g > 0 the run is a planted
    // positive-control run and the header names it instead of gating.
    selfPass = not na(rLo) and rLo <= 0.5 and rHi >= 0.5 and
         residAll == 0 and nTrainErr == 0
    hdr = not synth ? timeframe.period :
         synReg > 0 ? "PLANTED g=" + str.tostring(synReg, "#.##") :
         synDrift != 0 ? "DRIFT TEST" :
         selfPass ? "VALIDATION PASS" : "VALIDATION FAIL"
    hdrC = not synth ? COL_VAL :
         synReg > 0 or synDrift != 0 ? COL_WARN :
         selfPass ? COL_UP : COL_DOWN

    empty = useRange and nBarsRange == 0

    array.clear(tk)
    array.clear(tv)
    array.clear(tc)

    addRow("ML SIGNAL STATISTICS", hdr, hdrC)
    addRow(synth ? "SYNTHETIC  seed " + str.tostring(synSeed) : "Sample",
         synth ? "drift " + str.tostring(synDrift, "#.##") + "  g " +
         str.tostring(synReg, "#.##") :
         empty ? "NO BARS IN RANGE" : dat(firstT) + "  " + dat(lastT),
         synth ? COL_WARN : empty ? COL_DOWN : COL_VAL)

    if not compact
        addRow("Range set", useRange ? dat(startT) + "  " + dat(endT) : "off",
             useRange ? COL_VAL : COL_TXT)
        addRow("Chart loaded", dat(chartFirstT) + "   " + str.tostring(nBarsAll) + "b",
             COL_VAL)
        addRow("Bars in range", str.tostring(nBarsRange), empty ? COL_DOWN : COL_VAL)
        addRow("Training pushes", str.tostring(nPushed) +
             (winFull ? "" : "   WINDOW NOT FULL"), winFull ? COL_TXT : COL_DOWN)

    addRow("Signal flips", str.tostring(nFlips) +
         (residF != 0 ? "   UNACCOUNTED " + str.tostring(residF) : ""),
         residF != 0 ? COL_DOWN : COL_VAL)

    if not compact
        addRow("  out of range", str.tostring(nRangeR), COL_TXT)
        addRow("  feature na",   str.tostring(nFeatNa), COL_TXT)
        addRow("  no ATR",       str.tostring(nAtrNaR), COL_TXT)
        addRow("  min separation", str.tostring(nSepR), COL_TXT)

    addRow("Real entries", str.tostring(nEvReal) + "   " +
         str.tostring(nEvBull) + "/" + str.tostring(nEvBear) + " b/s" +
         (residE != 0 ? "   UNACCOUNTED " + str.tostring(residE) : ""),
         residE != 0 ? COL_DOWN : COL_VAL)
    if not compact
        addRow("  censored / open", str.tostring(sReal.nCens) + " / " +
             str.tostring(opnR), COL_TXT)

    addRow("Real win rate (n=" + str.tostring(dR) + ")", pct(hrR), COL_VAL)
    if not compact
        addRow("  95% interval", na(rLo) ? "--" : pct(rLo) + " - " + pct(rHi) +
             "   z50 " + num(zR), COL_VAL)
        addRow("  t/s/a/c", str.tostring(sReal.nTarget) + "/" + str.tostring(sReal.nStop) +
             "/" + str.tostring(sReal.nAmbig) + "/" + str.tostring(sReal.nCens), COL_TXT)
        addRow("  bull / bear", pct(hr2(sReal.bullT, sReal.bullD)) + " / " +
             pct(hr2(sReal.bearT, sReal.bearD)) + "   " +
             str.tostring(sReal.bullD) + "/" + str.tostring(sReal.bearD), COL_VAL)

    addRow("Placebo entries", str.tostring(nEvPlac) + " of " + str.tostring(nQReal) +
         ((residP != 0 or residEP != 0) ? "   UNACCOUNTED" : ""),
         residP != 0 or residEP != 0 ? COL_DOWN : COL_VAL)
    if not compact
        addRow("  out of range / no ATR / pending", str.tostring(nRangeP) + " / " +
             str.tostring(nAtrNaP) + " / " + str.tostring(quR), COL_TXT)
        addRow("  censored / open", str.tostring(sPlac.nCens) + " / " +
             str.tostring(opnP), COL_TXT)

    addRow("Placebo win rate (n=" + str.tostring(dP) + ")", pct(hrP), COL_VAL)
    if not compact
        addRow("  95% interval", na(pLo) ? "--" : pct(pLo) + " - " + pct(pHi) +
             "   z50 " + num(zP), COL_VAL)
        addRow("  t/s/a/c", str.tostring(sPlac.nTarget) + "/" + str.tostring(sPlac.nStop) +
             "/" + str.tostring(sPlac.nAmbig) + "/" + str.tostring(sPlac.nCens), COL_TXT)
        addRow("  bull / bear", pct(hr2(sPlac.bullT, sPlac.bullD)) + " / " +
             pct(hr2(sPlac.bearT, sPlac.bearD)) + "   " +
             str.tostring(sPlac.bullD) + "/" + str.tostring(sPlac.bearD), COL_VAL)

    addRow("real - placebo", (na(dlt) ? "--" : pct(dlt)) + "   z " + num(zD),
         na(dlt) ? COL_VAL : math.abs(nz(zD)) > 2 ? COL_WARN : COL_VAL)
    if not compact
        addRow("  ambiguous r / p", pct(hr2(sReal.nAmbig, dR)) + " / " +
             pct(hr2(sPlac.nAmbig, dP)), COL_WARN)
        addRow("  censored r / p", pct(hr2(sReal.nCens, dR + sReal.nCens)) + " / " +
             pct(hr2(sPlac.nCens, dP + sPlac.nCens)), COL_WARN)
        addRow("  mean concurrent r / p", num(concR) + " / " + num(concP), COL_TXT)

    // Integrity counters. Surfaced even in compact mode when nonzero: an
    // error voids the run and must not hide behind a toggle.
    if not compact or nTrainErr > 0
        addRow("  train-array errors", str.tostring(nTrainErr) +
             (nTrainErr > 0 ? "   RUN VOID" : ""),
             nTrainErr > 0 ? COL_DOWN : COL_TXT)
    if not compact or nNbShort > 0
        addRow("  entries with < k neighbors", str.tostring(nNbShort),
             nNbShort > 0 ? COL_WARN : COL_TXT)

    // Oracle block, synthetic mode only (DESIGN.md 4.3).
    if synth
        addRow("Oracle entries (RSI cross)", str.tostring(nEvOrac) + " of " +
             str.tostring(nOCross) +
             ((residO != 0 or residEO != 0 or residQ != 0 or residEQ != 0) ?
             "   UNACCOUNTED" : ""),
             residO != 0 or residEO != 0 or residQ != 0 or residEQ != 0 ?
             COL_DOWN : COL_VAL)
        addRow("Oracle win rate (n=" + str.tostring(dO) + ")", pct(hrO) +
             (na(oLo) ? "" : "   " + pct(oLo) + "-" + pct(oHi)), COL_VAL)
        addRow("Oracle placebo (n=" + str.tostring(dQ) + ")", pct(hrQ) +
             (na(qLo) ? "" : "   " + pct(qLo) + "-" + pct(qHi)), COL_VAL)
        addRow("oracle - placebo", (na(dltO) ? "--" : pct(dltO)) + "   z " + num(zO),
             na(dltO) ? COL_VAL : synReg > 0 and nz(zO) > 2 ? COL_UP : COL_VAL)
        // Direction splits: oracle events are RSI crosses and carry no
        // 50/50 constraint, unlike real entries, whose flip alternation
        // forces balance. An imbalanced mix moves an arm off 50% by the
        // sample's realized drift (RUNS.md Phase 0, candidate cause 1).
        addRow("  oracle bull / bear", pct(hr2(sOrac.bullT, sOrac.bullD)) + " / " +
             pct(hr2(sOrac.bearT, sOrac.bearD)) + "   " +
             str.tostring(sOrac.bullD) + "/" + str.tostring(sOrac.bearD), COL_VAL)
        addRow("  o-placebo bull / bear", pct(hr2(sOplc.bullT, sOplc.bullD)) + " / " +
             pct(hr2(sOplc.bearT, sOplc.bearD)) + "   " +
             str.tostring(sOplc.bullD) + "/" + str.tostring(sOplc.bearD), COL_VAL)
        addRow("  mean concurrent o / op", num(concO) + " / " + num(concQ), COL_TXT)

    addRow("Barrier / hold", str.tostring(kR, "#.#") + "R   r " +
         (na(medR) ? "--" : str.tostring(medR, "#.#")) + "b  p " +
         (na(medP) ? "--" : str.tostring(medP, "#.#")) + "b" +
         (degen ? "  TOO TIGHT" : ""), degen ? COL_WARN : COL_VAL)
    addRow("Definition", "k " + str.tostring(kNbr) + "  win " + str.tostring(maxBack) +
         "  H " + str.tostring(labelH) + "  " + (asCoded ? "as-coded" : "textbook") +
         "  f" + str.tostring(featCnt) +
         (useVolF ? " vol" : "") + (useRegF ? " reg" : "") + (useAdxF ? " adx" : "") +
         (minSep > 0 ? "  minsep " + str.tostring(minSep) : ""), COL_TXT)

    // Opaque cells on an opaque table, so nothing shows through the numbers.
    cellBg = color.new(chart.bg_color, 0)

    // Marker key. A colour key, not a shape key: Unicode has no glyph
    // resembling a Pine pin label, so a triangle here would misdescribe
    // the marker it names. Uniform swatches, with position carrying the
    // direction. Rows fill from the top so turning one marker type off
    // leaves no gap.
    // Marker key. A colour key, not a shape key: Unicode has no glyph
    // resembling a Pine pin label, so a triangle here would misdescribe
    // the marker it names. Uniform swatches, direction stated in words.
    // The heading always carries text, so the key is visible even when a
    // marker type is switched off.
    table.clear(lg, 0, 0, 0, 3)
    if showLgnd and not synth
        table.cell(lg, 0, 0, "MARKERS", text_size = size.small,
             text_color = COL_TXT, text_halign = text.align_left, bgcolor = cellBg)
        table.cell(lg, 0, 1, showSig ? "■  signal, long - below the bar" : "",
             text_size = size.small, text_color = MRK_UP,
             text_halign = text.align_left, bgcolor = cellBg)
        table.cell(lg, 0, 2, showSig ? "■  signal, short - above the bar" : "",
             text_size = size.small, text_color = MRK_DOWN,
             text_halign = text.align_left, bgcolor = cellBg)
        table.cell(lg, 0, 3, showPlac ? "■  random entry" : "",
             text_size = size.small, text_color = MRK_PLAC,
             text_halign = text.align_left, bgcolor = cellBg)

    table.clear(tb, 0, 0, 1, 43)
    for i = 0 to array.size(tk) - 1
        table.cell(tb, 0, i, array.get(tk, i), text_size = size.small,
             text_color = COL_TXT, text_halign = text.align_left,
             bgcolor = cellBg)
        table.cell(tb, 1, i, array.get(tv, i), text_size = size.small,
             text_color = array.get(tc, i), text_halign = text.align_right,
             bgcolor = cellBg)
````
