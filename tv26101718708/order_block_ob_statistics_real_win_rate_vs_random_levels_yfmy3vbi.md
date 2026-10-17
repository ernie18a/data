# Order Block (OB) Statistics: Real Win Rate vs Random Levels

- url: https://www.tradingview.com/script/yFmy3VBi-Order-Block-OB-Statistics-Real-Win-Rate-vs-Random-Levels/
- type: indicator
- pine_id: PUB;370f7e3213da4a20ba1944b92de12b9a
- version: 1.0

## Description

On real price data, a 54% win rate can be worse than random, and a 46% win
rate can be better. Whether a level "works" depends on the number it is
compared with. That comparison number is called the baseline, and for levels
on a chart it is almost never exactly 50%.

An order-block arrow is therefore not evidence of an edge. The practical
question is simple: does price behave differently after touching an order
block than after touching a similar level with no order-block event behind
it?

This script performs that comparison. It does not generate buy or sell
signals; it measures the entry logic that such signals rely on.

The measurements behind this publication were made on a forex pair
(EURUSD), a crypto pair (BTCUSDT) and an equity index future (ES1!). The
script itself runs on any symbol and timeframe.

[b]What to Use It For[/b]

[b]Evaluating what already exists.[/b] Whatever tool draws your order
blocks, set this script's inputs to match the same rules. The panel then
shows how those zones performed against matched comparison levels. The
comparison levels are measured on the same chart, in the same direction,
with the same size and distance from price.

[b]Evaluating something before you build it.[/b] Entry, exit, sizing and
filters are normally backtested together. Because of this, even a profitable
backtest may not show which part produced the result. This script isolates
the entry and asks one question: after price reaches the zone, does it
behave differently than after reaching a similar level where nothing
happened? If not, exit rules may change the size of wins and losses, but
they cannot add information that the entry does not have. You can learn that
before writing the full strategy.

[b]Generalizing beyond order blocks.[/b] Supply and demand zones, breaker
blocks, support and resistance, session highs and lows, and other
level-based signals can be evaluated with the same test. The rule that
builds the level changes; the baseline problem does not.

Order blocks are widely taught and rarely measured.

https://www.tradingview.com/x/DznVkboF/
Order blocks on BTCUSDT 30m. Open zones extend to the right until price
reaches them. Once reached, they freeze and change to dotted lines, showing
how long each zone lasted. Triangles mark the break of structure - a close
beyond the most recent swing - that confirmed each zone as an order block.
The panel in the corner is the measurement. It scores every zone in the
selected date range - 1,854 of them here, not just the dozen visible -
against matched control levels.


[b]The Result in Plain Language[/b]

The study contains 31 runs. They cover the three instruments named above,
timeframes, periods, barrier widths (target and stop distances) and
order-block definitions. No tested configuration showed a reliable
difference between real order blocks and their placebo levels, and no
configuration repeated such a difference on other instruments. A placebo
level is a matched comparison zone with no order-block event behind it.
The combined estimates were slightly below zero, but the uncertainty range
still included zero.

This does not prove that all order-block concepts fail. It only reports what
this definition, this measurement method and this sample showed - and did
not show. The value of the script is the method. The sections below explain
each term before it is used and show how to apply the same measurement to
your own rules.


[b]Terms Used in the Panel[/b]

[b]Hit rate.[/b] The percentage of counted outcomes in which the target was
reached before the stop. This is the raw result that a simple backtest would
usually report.

[b]Placebo or control level.[/b] A comparison zone with no order-block
event, but matched to the real zone by height, direction and distance from
price. It estimates the hit rate that price movement, general trend and
level placement produce on their own, without any order-block information.

[b]Edge estimate: "real - placebo."[/b] The real-zone hit rate minus the
control-zone hit rate. A positive value means the real zones performed
better than the controls; a negative value means they performed worse.

[b]Percentage point (pp).[/b] An absolute difference between percentages.
For example, 54% minus 50% equals +4 percentage points, not +4% relative
growth.

[b]z score.[/b] The edge estimate divided by a measure of its statistical
noise (the standard error). It shows how large the observed difference is
compared with normal random variation. As a widely used threshold, an
absolute z score near 2 is treated as a first sign of a real effect. This
study also requires the result to repeat before drawing a conclusion.

[b]95% confidence interval (95% CI).[/b] A range around the estimate that
shows how uncertain it is. When the range includes zero, the data do not
clearly show a positive or a negative difference.

[b]Ambiguous outcome.[/b] A bar whose high and low contain both the target
and the stop. Open-high-low-close data cannot show which one price reached
first. The script counts such cases against the hit rate, which is the safe
choice.

[b]Censored outcome.[/b] A zone that reaches neither barrier before the time
limit. It is reported separately and not counted in the hit rate.


[b]Why 50% Is the Wrong Baseline[/b]

Any rule that enters when price reaches a level already has some hit rate
before any real signal is involved. That hit rate comes from how price moves
and drifts on its own. Intuition says that with equal target and stop
distances, price should reach each side half the time. On real price data
this is often not true, and the size of the difference varies by instrument,
direction and period.

Across the runs behind this publication, the baseline for levels with no
special meaning ranged from 47.3% to 52.3% overall, and from 43.3% to 54.6%
after splitting by direction. This is the source of the numbers at the top
of this description: a 54% long hit rate can be below its baseline, while a
46% short hit rate can be above its baseline.

The script measures both sides at once. For every confirmed order block, it
also places control zones of the same height, direction and distance from
price, at bars where no order-block event occurred. Real and control zones
are then measured in exactly the same way.

The "real - placebo" row is therefore the primary result. It subtracts the
part of the performance that the baseline alone explains. It is more
informative than the raw hit rate. The control does not remove every
possible difference, however; those limits are listed below.


[b]What Counts as an Order Block[/b]

A swing high or swing low is confirmed a fixed number of bars after it
forms. A break of structure is a close beyond the most recent unbroken
swing. The break is tested on the closing price only, never inside a bar.
The order block is the source candle: the last candle before the break
that moved the other way. An upward break points back at the last down
candle; a downward break points back at the last up candle.

The close is used rather than the high or the low because a bar's extreme
has no known timing. OHLC data records that price reached a level during
the bar, not when, and every measurement here has to start from a defined
moment. A close supplies one. It also means a break that is reversed
before the bar ends does not count as a break.

The important question is: when does the zone become visible in real time?

An order block is not visible when its source candle forms. The candle
becomes a zone only after a later break of structure points back to it. Two
bars are therefore involved: the source bar on which the zone is drawn and
the confirmation bar on which the break closes.

Every measurement starts from the confirmation bar forward. Price that
reached the source candle before the zone became visible is not a trade and
is not counted. Because confirmation occurs at a close, the first touch test
is performed on the following bar. Control zones use the same one-bar delay
so the comparison stays fair.

https://www.tradingview.com/x/hDDlAyAR/
A single order block, zoomed in. The source candle is where the zone is
drawn. The triangle several bars later marks the close that confirmed the
break of structure - the first moment the zone existed for a user in real
time. The bars between the two were not tradeable, and nothing in that
interval is counted.


[b]How the Measurement Works[/b]

A risk unit, or R, is selected in the settings as either average true range
(ATR) or zone height. It sets the scale of the measurement: for example, a
barrier size of 2R places both the target and the stop two selected risk
units from entry.

Average true range is the average size of a bar's full range over a set
number of bars, including any gap from the previous close - in effect, how
far price typically travels in one bar. Setting barriers in ATR rather than
in points means a 2R barrier is twice the recent typical bar range, so the
same setting means the same thing on a volatile instrument and a quiet one.

The ATR used for a zone's barriers is read once, at the bar where that
zone is created - the confirmation bar for a real zone, the placement
bar for a control zone - and stays fixed for that zone.

The near edge of a zone is the side facing price after the break: the top of
a bullish zone, the bottom of a bearish one. It is the side price has to come
back to.

When price returns to the near edge of a zone, the entry is recorded at that
bar's close. A target and a stop are placed the selected number of risk
units away, one in each direction. For a bullish zone the target is above
the entry and the stop below it; for a bearish zone, the reverse. The
script then records which barrier price reaches first, starting from the
next bar.

Entry is recorded at the close rather than at the zone edge for a specific
reason. A touch is triggered when price crosses the edge, not only when
price equals it, so the touching bar may cross the edge by an unknown
amount. Suppose the entry were recorded at the edge price while the
measurement started on the next bar. Then the measurement would begin after
price had already moved away from the assumed entry. The entry price and the
price from which the barriers are measured must be the same.

Sometimes a single bar contains both the target and the stop.
Open-high-low-close (OHLC) data alone cannot show which one price reached
first inside that bar. Such outcomes are marked ambiguous and counted
against the hit rate, which is the safe choice.

Zones that reach neither barrier inside the time limit are censored.
Censoring is the statistical term for an observation whose outcome was
never seen: the zone was still running when the limit expired, which is
known, and nothing more. Counting it as a win or a loss would mean
inventing the missing outcome, so it is dropped from the hit rate and
reported separately.

Ambiguous and censored counts are reported for real and control zones
separately. They cancel out of the difference only when both sides show them
at similar rates.

https://www.tradingview.com/x/DkYddFEa/
One measurement from beginning to end: the confirming break, price
returning to the near edge, entry at that bar's close, and the barrier
that was reached first - here, the stop. On this instrument the aggregate
ran negative over the test window; the result did not replicate on the
other two instruments and is recorded as unresolved in the limitations
section. The panel reports what it measures.


[b]Where the Method Comes From[/b]

None of the statistics here are new, and it is worth being clear about that.

A standard way to test a method is to apply it where the signal does not
exist, then check that no effect appears. In statistics this is called a
placebo test, and it is a common tool in causal inference - the field that
studies cause and effect. The placebo zones in this script apply that idea
to price bars instead of people.

The trading application is not new either. David Aronson's
[i]Evidence-Based Technical Analysis[/i] (2006) argues that a trading rule
should be compared with random entry signals rather than with zero. His book
uses Monte Carlo permutation and White's Reality Check for this purpose.

The scoring rule - a target, a stop and a time limit, whichever is reached
first - is the triple-barrier method described by Marcos López de Prado.

What this script adds is not the method but its availability. The control is
created and scored automatically next to the real zones, on any chart and
any symbol. The baseline arrives together with the result, instead of
requiring a separate study that most people will never run.


[b]How to Use It[/b]

[b]1. Match the definition.[/b] Set the order-block inputs to reproduce the
rules used by the indicator, strategy or idea you want to evaluate. A
statistical result only applies to the definition that produced it.

[b]2. Run the built-in validation first.[/b] Enable synthetic mode before
interpreting live-market results. Synthetic mode replaces price internally
with a random walk - artificial price data that moves randomly and contains
no real signal - whose correct answer is known. If the measurement does not
recover that answer, the market result should not be trusted.

[b]3. Check the sample funnel.[/b] The funnel accounts for every break of
structure: how many found no source candle, fell below the displacement
filter (a minimum move size, set in the settings), had price already inside
the zone at confirmation, or became measurable zones. If the categories
do not add up to the break count, the panel reports the mismatch.

[b]4. Check measurement quality.[/b] A barrier size of 1R often resolves
within a few bars. It may then only measure price noise right at the entry
rather than what happens afterward; the panel flags it as TOO TIGHT. Set the
time limit long enough to keep the number of censored zones small, and
compare the real and control ambiguous and censored rates.

[b]5. Read the three core rows.[/b] "Hit rate" is the raw real-zone result
and sample size. "Placebo" is the matched baseline. "Real - placebo" is the
edge estimate. Read its size first, then its z score and confidence
interval. Do not treat a high raw hit rate as evidence of an edge unless it
also exceeds the matched baseline.

[b]6. Look for repetition, not the best single result.[/b] Repeat the same
configuration on other instruments and independent periods. A result that
appears on only one chart can be random variation rather than a reusable
signal.


[b]Results[/b]

The study contains 31 runs and 23 distinct estimates. They span three
instruments from three asset classes - BTCUSDT (crypto), EURUSD (FX) and
ES1! (an equity index future) - plus four timeframes, three time periods,
three barrier widths and eight definition variants.

In the table, Estimate means "real - placebo" in percentage points. A
negative estimate means the placebo levels performed better. The z score
compares that estimate with its statistical noise, and the 95% CI shows the
uncertainty range.

[pine]
  Pool                            Estimate      z      95% CI
  30m, 3 instruments, 2025-26     -1.18pp    -1.19    -3.1 to +0.8
  1h,  3 instruments, 2025-26     -1.90pp    -1.35    -4.7 to +0.9
  1h,  3 instruments, 2024        -2.39pp    -1.36    -5.8 to +1.1
  1h,  7 runs, all periods        -1.73pp    -1.66    -3.8 to +0.3
[/pine]

Every pooled row combines the same three instruments: BTCUSDT, EURUSD and
ES1!. They are one crypto pair, one FX pair and one equity index future
sharing the same calendar window, chosen so that a result holding on all
three cannot come from the structure of a single market.

The decision rule was fixed before the runs: a single configuration had to
reach an absolute z score above 2 (|z| > 2) and then repeat on two other
instruments. One result crossed the single-run threshold: EURUSD 30m at
-4.9pp and z -2.69. It failed both repetitions. The same configuration
returned +0.1pp on BTCUSDT and +0.8pp on ES1!. Its two independent EURUSD
periods combined to -1.23pp at z -0.55, and the sign flipped between the
two periods.

[b]No tested configuration met the full decision rule.[/b] The most precise
combined estimate was -1.73pp, and its confidence interval included zero.
The balanced pool - the same three instruments over the two periods that
share no data, before adding the third EURUSD year - gave -2.10pp at
z -1.91, the largest combined deviation in the study; its interval of
-4.3 to +0.1 also included zero, by a small margin. The study therefore
did not detect a reliable positive or negative order-block effect under
the tested conditions.

[b]None of the tested refinements changed the conclusion.[/b] A displacement
filter that discarded 56% of breaks, body-only zones, the mitigation
requirement (the Require price outside setting: it discards a zone if price
was already inside it when the break of structure closed), and swing length
across a 3.3x range all moved the estimate by less than the measurement
noise.

[b]Using 50% as the comparison point can create a false conclusion in either
direction.[/b] Order blocks filtered to 2 ATR of displacement produced a
46.7% hit rate and z -1.83 against a 50% comparison, which could be
presented as evidence that the setup loses. Against the matched control, the
same runs produced -0.6pp at z -0.29. The apparent result came mostly from
the wrong baseline, not from the order blocks.

[b]To reproduce the published figures:[/b] The script defaults match the
configuration used for these estimates. Set the date range to 2025-01-01
through 2026-08-01 for rows labelled 2025-26, or use the matching calendar
year for the other rows. Disable compact panel mode to display the funnel
counts. The three instruments are BTCUSDT, EURUSD and ES1!.

[b]A final note on direction.[/b] The mean of all 23 estimates is -0.87pp,
while the same statistic on data built to contain no edge returned -0.44pp.
Fifteen estimates are negative, seven are positive and one is exactly zero.
The estimates share data, so this count is not a formal statistical test.
The data do not establish an exact zero effect, but they do limit how large
any real effect could be within this design and sample.


[b]Validation[/b]

[b]Driftless random-walk check.[/b] On a driftless random walk, an entry
with equal barriers reaches either side with equal probability. Synthetic
mode replaces price with such a walk, so the combined real and control hit
rates should stay close to 50%, within normal statistical variation.

Eight seeds were tested - starting values for the random generator, each
producing a different artificial price series. The combined real hit rate
was 49.83% and the combined control hit rate was 50.26%, both within 1.5
standard deviations of 50% - that is, well inside normal random variation.
Two of the eight individual runs fell outside the expected range, on
opposite sides of the test and in opposite directions. That pattern
matches ordinary random variation, not a systematic measurement error.

[b]Resolution check.[/b] Combined across all eight seeds, the difference
statistic was -0.44pp even though the synthetic data contained no edge. This
shows the smallest difference the design can detect in practice: at this
sample size, differences smaller than about 1.2 percentage points cannot be
separated from measurement noise.

[b]Drift stress test.[/b] The same validation was then repeated after adding
drift, while the data was still built to contain no signal edge.

https://www.tradingview.com/x/Gr5iNoDx/
Synthetic mode with drift, where no edge exists by construction. Against the
50% comparison the long side reads 59.6% at z +5.33 and the short side 38.8%
at z -5.89. Both look statistically significant, and both are false signals
created by the wrong baseline. Against the matched control the same two sides
read -0.59 and -0.16 percentage points, at z -0.27 and -0.07, and the
aggregate difference is 0.0%. Synthetic mode replaces price internally, so
the chart behind the panel does not show the tested data.


[b]Settings[/b]

[b]Order-block definition.[/b] Swing length sets how many bars on each side
are required to confirm a swing point. Search depth sets how far back from
the break the script looks for the source candle. Zone bounds selects either
the full candle range or the candle body. Minimum displacement can require
the move from the source candle to the break to span a selected number of
ATR. Require price outside excludes zones that price had already traded into
by the time of confirmation.

[b]Measurement.[/b] Risk unit selects ATR or zone height. Barrier size sets
the target and stop distance in risk units. Time limit removes zones that
have not reached either barrier in time (censoring). Entry price offers the
bar close or the zone edge; the zone-edge option is included for comparison
but is labelled biased. Minimum zone height and the overlap filter determine
which zones enter the sample, while the overlap window sets how far back the
filter compares.

[b]Sample.[/b] The range uses explicit year, month and day fields rather
than a date picker. The built-in picker can silently snap to the loaded data
and change the dates, which would make a published result hard to reproduce.

[b]Placebo control.[/b] Sets the number of control zones generated for each
real zone and the bar offset used to place them.

[b]Validation.[/b] Controls synthetic mode, seed, step size and drift per
bar.

[b]Display.[/b] Controls compact panel mode, zone drawing and break markers.


[b]Limitations[/b]

[b]The control does not match every feature.[/b] It matches zone size,
direction and distance from price, but it does not match the fact that a
strong move in that direction has just happened. In trending markets this
gap matters for direction: control long and short hit rates differed by as
much as 10.9 percentage points. Treat long/short splits as unreliable in
trends. The combined result is also affected, to a degree this study does
not measure.

[b]One instrument remains unresolved.[/b] EURUSD 30m returned -4.9pp at
z -2.69. The result failed repetition on both other instruments, and its two
independent EURUSD periods combined to -1.23pp at z -0.55 with opposite
signs. The available history cannot fully separate a real
instrument-specific effect from a random outlier.

[b]Single runs are not precise enough to support the conclusion on their
own.[/b] An order block requires a break of structure, so observations are
rarer than for many gap-based patterns. A single instrument-timeframe run
can only detect differences of about 3 percentage points or larger. The
combined estimates therefore carry more weight than any single run.

[b]Loaded chart history limits the sample.[/b] The number of bars loaded by
the chart, not only the selected calendar dates, determines how much data a
run can use. The 5-minute cell reaches only a few months, so the effects of
its period and its timeframe cannot be separated.

[b]Historical measurement is not a forecast.[/b] The script reports what
happened under the specified rules and sample. Past behavior of a level does
not guarantee or predict future behavior.


[b]Disclaimer[/b]

This script and its description are provided for educational and research
purposes only. They do not constitute financial, investment, trading or
other professional advice, and they do not recommend buying, selling or
holding any asset. Historical and simulated results do not guarantee future
performance. Trading involves risk, including the possible loss of capital.
You are solely responsible for your trading and investment decisions and
should conduct your own research and, where appropriate, consult a
qualified financial professional.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Algolego

//@version=6
indicator("Order Block (OB) Statistics: Real Win Rate vs Random Levels", "OB Stats", overlay = true,
     max_bars_back = 5000, max_boxes_count = 500)

// =============================================================================
// Measures what actually happens after price returns to an order block.
//
// An order block is not knowable when it forms. It is a candle in the past that
// only becomes a zone once a later break of structure points back at it. This
// script therefore separates two bars that most order-block tools conflate:
//   source bar      -- the candle the zone is drawn on
//   confirmation bar -- the bar the break of structure closed, which is the
//                       first moment the zone exists for anyone
// Everything is measured from the confirmation bar forward. Price that reached
// the zone before it was knowable is not a trade, and is not counted as one.
//
// Because confirmation lands on a bar's CLOSE, the touch test starts on the
// following bar. A fair value gap does not have this problem -- it completes on
// the previous bar, so the current bar is legitimately in its future. Order
// blocks do, and the placebo carries the same one-bar delay so the control
// stays matched.
//
// The baseline for "no edge" is NOT 50%. Any rule that enters when price
// reaches a level inherits a baseline from path and drift. The placebo -- same
// size, same direction, same distance from price, anchored at bars where no
// structural event occurred -- measures that baseline. Real minus placebo is
// the statistic that matters.
//
// The fill price and the price measurement starts from must be the SAME price.
// A touch trigger fires on "low <= edge", not "low == edge", so the touch bar
// breaches the edge by an unknown amount. Filling at the edge but starting the
// barrier race on the next bar begins it already displaced toward the stop.
// Entering at the touch bar's close removes that displacement.
//
// The self-test below verifies the measurement path, NOT zone construction: on
// a random walk a zone drawn on the wrong candle is still a fair coin, so it
// passes either way. The funnel counters in the panel -- breaks of structure,
// no source candle, below displacement, price already in -- are what audit
// construction. A no-source-candle rate far above a coin flip means the
// detection is not reading the bars it claims to.
//
// SELF-TEST: on a driftless random walk, entry at a price with symmetric
// barriers resolves upward exactly 50% of the time (optional stopping theorem).
// Turn on Synthetic mode and both hit rates MUST bracket 50%, less about half
// the ambiguous rate. Anything else is a measurement bug, with no market
// interpretation available. Re-run this after every change to the measurement
// path.
// =============================================================================

// ---------------------------------------------------------------- inputs ----
// Defaults throughout match the configuration the published results were
// measured at, so a reader who changes nothing reproduces the documented
// figures. Swing length is 3 rather than a rounder 5 because 5 did not produce
// enough confirmed zones to resolve an effect on a single instrument.
grpO = "Order block definition"
pivLen  = input.int(3, "Swing length (bars each side)", minval = 1, group = grpO,
     tooltip = "A swing high/low is confirmed this many bars after it prints. " +
     "The break of structure cannot be known any earlier than that.")
obDepth = input.int(10, "Source-candle search depth (bars)", minval = 1, group = grpO,
     tooltip = "How far back from the break of structure to look for the last " +
     "opposite-colour candle. That candle is the order block.")
obBody  = input.string("Full range", "Zone bounds",
     options = ["Full range", "Body only"], group = grpO)
dispAtr = input.float(0.0, "Minimum displacement (ATR)", minval = 0, step = 0.25, group = grpO,
     tooltip = "Optional. Requires the leg from the source candle to the break " +
     "of structure to span at least this many ATR. 0 disables the filter.")
reqOutside = input.bool(true, "Require price outside the zone at confirmation", group = grpO,
     tooltip = "Drops zones price had already traded back into by the time the " +
     "break of structure closed. Those are not 'wait for the retrace' trades.")

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
showBos   = input.bool(true, "Mark the confirming break of structure", group = grpD)

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

// Open is routed too: order-block detection reads candle direction, which a
// synthetic run must reproduce or the self-test is not testing this script.
_open  = synth ? sOpen  : open
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
    int   confBar  = 0        // first bar the zone existed; nothing before counts
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
bodyMode = obBody == "Body only"

var array<Zone>    active  = array.new<Zone>()
var array<Zone>    recentZ = array.new<Zone>()   // overlap cache, real zones
var array<Zone>    recentP = array.new<Zone>()   // overlap cache, placebos
var array<Pending> queued  = array.new<Pending>()
var array<Zone>    drawnZ  = array.new<Zone>()   // zones holding a live box
var Stats sReal    = newStats()
var Stats sPlac    = newStats()
var int   nConfRaw = 0
var int   nDup     = 0
var int   nBos     = 0    // breaks of structure seen
var int   nNoSrc   = 0    // no opposite-colour candle within the search depth
var int   nDisp    = 0    // rejected by the displacement filter
var int   nInside  = 0    // price already back inside the zone at confirmation
var int   nSmall   = 0    // below the minimum zone height, or zero height
var int   nDrawn   = 0    // boxes actually created, to separate "no zone was
                          // built" from "a zone was built but not drawn"
var int   nPlacDup = 0    // placebos rejected by the overlap filter, so the
                          // control's rejection rate can be compared to nDup
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

// 31 rows are emitted in non-compact mode. Sized to 36 so a future row cannot
// silently overflow; table.clear below must stay in step with this number.
// Opaque background on the table AND on every cell. The table background
// covers any gap the cell backgrounds do not fill, so nothing on the chart
// shows through the numbers where price crosses the panel.
var table tb = table.new(position.top_right, 2, 36, border_width = 1,
     bgcolor = color.new(chart.bg_color, 0),
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

// --------------------------------------------------------- market structure --
// A swing point is only knowable pivLen bars after it prints, so a break of
// structure is only knowable then either. Both are read off closed bars and the
// break is tested on the close, never intrabar. Nothing repaints.
ph = ta.pivothigh(_high, pivLen, pivLen)
pl = ta.pivotlow(_low,  pivLen, pivLen)

var float refHi  = na
var float refLo  = na
var bool  hiLive = false     // a confirmed swing high that has not been broken yet
var bool  loLive = false

if not na(ph)
    refHi  := ph
    hiLive := true
if not na(pl)
    refLo  := pl
    loLive := true

bosUp = hiLive and not na(refHi) and _close > refHi
bosDn = loLive and not na(refLo) and _close < refLo
if bosUp
    hiLive := false
if bosDn
    loLive := false

// The last opposite-colour candle before the break -- the standard reading of
// "the last down candle before the move up".
//
// Tracked continuously here rather than searched for when a break happens.
// Pine evaluates history inside a function relative to the bars the function
// was CALLED on, so a lookback loop inside a function that only runs on break
// bars reads the last N breaks, not the last N bars. That returns an index in
// call-space which is then indistinguishable from a bar offset -- silently
// drawing zones on arbitrary candles. The self-test cannot catch it, because a
// wrong level on a random walk is still a fair coin. Tracking the candle as it
// prints removes the lookup, and with it the whole failure mode.
var int   dnBar = na       // last down candle
var float dnTop = na
var float dnBot = na
var float dnLo  = na       // raw low, for the displacement leg
var int   upBar = na       // last up candle
var float upTop = na
var float upBot = na
var float upHi  = na       // raw high, for the displacement leg

// ------------------------------------------------------- zone construction --
if (bosUp or bosDn) and not na(atr) and atr > 0 and inRange
    isBull = bosUp
    nBos += 1
    // The trackers are updated below this block, so they hold the last
    // opposite-colour candle at or before the PREVIOUS bar. A break bar is
    // never its own order block.
    srcBar = isBull ? dnBar : upBar
    src    = bar_index - srcBar          // na propagates if no candle seen yet

    if na(src) or src > obDepth or src < 1
        nNoSrc += 1
    else
        // Bounds were resolved when the candle printed: full range is how
        // order blocks are normally drawn, body only is the stricter reading
        // where the wick is treated as noise.
        t = isBull ? dnTop : upTop
        b = isBull ? dnBot : upBot

        // Displacement, measured over the leg the break actually travelled.
        leg = (isBull ? _close - dnLo : upHi - _close) / atr
        okDisp = dispAtr <= 0 or leg >= dispAtr

        // Proximal edge is the side price must come back to. If price is
        // already past it at confirmation there is no retrace to wait for.
        proximal = isBull ? t : b
        outside  = isBull ? _close > proximal : _close < proximal

        if not okDisp
            nDisp += 1
        else if reqOutside and not outside
            nInside += 1
        // Written as an explicit reject branch, not as a bare guard on the
        // accept branch. A guard with no else drops the break silently and the
        // funnel stops reconciling against the break count. The na tests come
        // first so a na bound cannot fall through into zone construction.
        else if na(t) or na(b) or t <= b or (t - b) / atr < minHgt
            nSmall += 1
        else
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

            // The box is drawn on the source candle, because that is where the
            // zone is. It is created here, at confirmation, because that is
            // when it became knowable -- the two are deliberately different
            // bars and the gap between them is the point of this script.
            if showZones and not synth and not z.isDup
                z.bx := box.new(srcBar, t, bar_index + 1, b,
                     border_color = color.new(zoneCol(isBull), 10),
                     bgcolor      = color.new(zoneCol(isBull), 70))
                nDrawn += 1
                // Retire the oldest box by hand, below Pine's 500-object limit,
                // and clear the owner's reference. An untouched zone can then
                // keep extending for as long as it stays untouched, with no
                // time cap and no risk of writing to a discarded box.
                array.push(drawnZ, z)
                if array.size(drawnZ) > 400
                    old = array.shift(drawnZ)
                    if not na(old.bx)
                        box.delete(old.bx)
                        old.bx := na

            // Matched placebos: same height, same standoff, same direction, but
            // anchored at a bar where no structural event occurred.
            if useNull and not z.isDup
                standoff = math.abs(_close - proximal) / atr
                height   = (t - b) / atr
                for k = 1 to nPlac
                    array.push(queued, Pending.new(bar_index + offBase * k, isBull, height, standoff))

// ------------------------------------------------- source-candle tracking ---
// Deliberately AFTER zone construction, so a break bar reads the last
// opposite-colour candle strictly before itself. Unconditional, so the
// trackers advance on every bar regardless of the date range.
if _close < _open
    dnBar := bar_index
    dnTop := bodyMode ? _open  : _high
    dnBot := bodyMode ? _close : _low
    dnLo  := _low
if _close > _open
    upBar := bar_index
    upTop := bodyMode ? _close : _high
    upBot := bodyMode ? _open  : _low
    upHi  := _high

// -------------------------------------------------- placebo activation ------
// Anchored on this bar's close and, like a real zone, not testable for a touch
// until the next bar. Matching that delay is what keeps the control honest:
// anchoring on a close and then testing the same bar's low selects placebos
// onto bars that moved their way late in the session.
if array.size(queued) > 0 and not na(atr) and atr > 0
    for i = array.size(queued) - 1 to 0
        p = array.get(queued, i)
        if bar_index >= p.dueBar
            h  = p.heightAtr  * atr
            so = p.standoffAtr * atr
            float t = na
            float b = na
            if p.isBull
                t := _close - so
                b := t - h
            else
                b := _close + so
                t := b + h
            if h > 0
                // Placebos get the same overlap treatment as real zones, or
                // the control is not matched and its interval is too narrow.
                pruneTo(recentP, dupWin)
                if dedupe and overlapsIn(recentP, t, b, p.isBull)
                    nPlacDup += 1
                else
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
        // these are normally displayed and also shows how long a zone survived.
        if showZones and not na(z.bx) and not z.touched
            box.set_right(z.bx, bar_index + 1)

        // A zone confirmed on this bar's close cannot be touched on this bar.
        // This is the one place order blocks differ from fair value gaps, and
        // skipping it would credit the zone with the move that created it.
        if not z.touched and bar_index > z.confBar
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

// The confirming break, marked on the bar it closed. The distance between this
// marker and the left edge of the zone it created is the lag every order-block
// study has to account for and most do not.
plotshape(showBos and not synth and bosUp, "BOS up", shape.triangleup,
     location.belowbar, COL_UP, size = size.tiny)
plotshape(showBos and not synth and bosDn, "BOS down", shape.triangledown,
     location.abovebar, COL_DOWN, size = size.tiny)

// ---------------------------------------------------------------- readout ---
if inRange
    firstT := na(firstT) ? time : firstT
    lastT  := time
    nBarsRange += 1

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

    addRow("ORDER BLOCK STATISTICS", hdr, hdrC)
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

    // Every break must end in exactly one bucket. A nonzero residual means a
    // reject path is missing a counter, which would make the funnel read as
    // complete while it is not.
    funnelSum = nNoSrc + nDisp + nInside + nSmall + nConfRaw
    resid     = nBos - funnelSum
    addRow("Breaks of structure", str.tostring(nBos) +
         (resid != 0 ? "   UNACCOUNTED " + str.tostring(resid) : ""),
         resid != 0 ? COL_DOWN : COL_VAL)

    if not compact
        // Where breaks are lost on the way to becoming a measurable zone.
        addRow("  no source candle",   str.tostring(nNoSrc),  COL_TXT)
        addRow("  below displacement", str.tostring(nDisp),   COL_TXT)
        addRow("  price already in",   str.tostring(nInside), COL_TXT)
        addRow("  below min height",   str.tostring(nSmall),  COL_TXT)

    // Zones were built but none were drawn. That separates a detection failure
    // from a drawing failure, which need opposite fixes -- so it is surfaced
    // even in compact mode rather than hidden behind a toggle.
    drawGap = nConfRaw > nDup and nDrawn == 0 and showZones and not synth
    if not compact or drawGap
        addRow("  boxes drawn", str.tostring(nDrawn) +
             (not showZones ? "  (off)" : synth ? "  (synthetic)" :
              drawGap ? "   ZONES NOT DRAWN" : ""),
             drawGap ? COL_DOWN : COL_TXT)

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
        // The control is only matched if it is filtered like the real side.
        addRow("  overlap rejects r / p", str.tostring(nDup) + " / " +
             str.tostring(nPlacDup), COL_TXT)
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
        addRow("  mean MFE / MAE", num(mfeAvg) + " / " + num(maeAvg), COL_VAL)

    addRow("real - placebo", (na(dlt) ? "--" : pct(dlt)) + "   z " + num(zd),
         na(dlt) ? COL_VAL : dlt > 0 ? COL_UP : COL_DOWN)
    addRow("Entry / barrier", (edgeMode ? "edge (biased)" : "close") + " / " +
         str.tostring(kR, "#.#") + "R  " +
         (na(medBars) ? "--" : str.tostring(medBars, "#.#") + "b") +
         (degen ? "  TOO TIGHT" : ""), edgeMode or degen ? COL_WARN : COL_VAL)
    addRow("Definition", "swing " + str.tostring(pivLen) + "  depth " +
         str.tostring(obDepth) + "  " + (bodyMode ? "body" : "range") +
         (dispAtr > 0 ? "  disp " + str.tostring(dispAtr, "#.##") : ""), COL_TXT)

    // chart.bg_color follows the user's theme, so the panel stays readable on
    // light and dark charts. Fully opaque, deliberately: at any transparency
    // the candles behind it show through and the numbers become hard to read
    // wherever price crosses the panel, which on a rising chart is exactly
    // where the reader is looking.
    // color.new(..., 0) forces opacity. Passing chart.bg_color through
    // unwrapped preserves whatever transparency it already carries, which is
    // not zero, so the candles still showed through.
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
