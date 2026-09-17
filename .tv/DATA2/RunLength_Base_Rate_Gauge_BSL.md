<!-- tradingview-pine-id: PUB;f9f2fefa7db94555a76906bb9ccd2b2d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Run-Length Base Rate Gauge [BSL]

Source: https://www.tradingview.com/script/6Gk3N6S2-Run-Length-Base-Rate-Gauge-BSL/

## Description

Five closes up in a row. Is five a lot?

The usual answer is an adjective: extended, stretched, due. Run-Length Base
Rate Gauge [BSL] answers with a count instead:

    RUN OF 5 OR LONGER · n=41 BEFORE THIS ONE · 19/41 EXTENDED · 46.3%

Forty-one runs on this chart reached five before this one. Nineteen of them
went to six. That is the whole product: two lines, one table, no direction and
no signal.

THE RUN IN FRONT OF YOU IS NOT IN THE 41

This is the part that makes the number worth reading, so it is worth being
precise about.

The denominator counts runs that have ALREADY STOPPED. The run currently
underway is held as PENDING and counted nowhere: not as a success it has not
earned, and not as a failure that has not happened. It has not yet had the
chance to end.

The alternative is more tempting than it looks, and worse than it looks. A run
of eight in progress has already been a run of one, two, three, and so on up
to eight. Credit it to all eight denominators and you have added one
observation to rows whose totals differ enormously: a row with 400 prior runs
barely moves, while a row with 3 lurches. The output looks exactly like a real
effect of run length, long runs behaving differently from short ones, and it
is entirely an artefact of counting an unfinished thing.

No row would be looking into the future. The defect would live in the
comparison between rows, which is where the usual checks do not look.

The fix here is stronger than adjusting for it. A run enters the counters only
on the bar it STOPS on, so every length it passed through resolves at the same
instant. The delay is one bar, and it is one bar for every run length in the
table, so all sixty rows share a single cutoff by construction rather than by
correction.

WHEN THE PERCENTAGE DISAPPEARS

Below ten prior runs there is no percentage. The bare fraction is shown
instead, with a note that the rate is being held back.

The panel goes further: its transparency is a step function of the sample
size. A rate resting on four runs is drawn faintly. A rate resting on four
hundred is drawn solid. You cannot read the number without also reading how
much is behind it, and no percentage ever appears without the count it came
from.

THE EDGES, AND WHAT HAPPENS AT THEM

A run longer than sixty bars is read at row sixty, and the panel says so
rather than clipping in silence.

An unchanged close ends a run and starts none. The headline reads NO RUN.

While the bar is still open the headline is prefixed FORMING and drawn
faintly. A table cell in Pine cannot have a dashed border, so an unconfirmed
reading is marked with transparency and a word, and the word is doing real
work, not decorating.

TWO NUMBERS THAT LOOK ALIKE AND ARE NOT

The panel always reports the rate at the run length in front of you. That
length changes bar to bar, which is right for something you read.

The value published for other scripts uses a FIXED threshold you set once.
That is right for something that gets measured, and the two are deliberately
kept apart: a series whose definition moved with the live run length would not
be one event, and anything measuring it would be measuring a different
population on every bar.

THE TWO SETTINGS

- Exported threshold: 5 bars in a row
- Panel position: Bottom center

Pick any of six positions. The gauge starts at the bottom center, the one strip
the platform is not already using for the legend, the trading buttons, its own
logo or the price scale.

A RUN OF AVERAGES IS NOT A RUN

A run of Heikin Ashi closes is a run of averages, and a base rate taken over
it describes the averaging rather than the market. Renko, Kagi, Point & Figure
and Range have the same problem for their own reasons.

On those chart types the gauge freezes and publishes nothing.

THE ONE PUBLISHED VALUE

One value is published for other indicators to pick up in their Source
setting: the outcome of the fixed-threshold trial. Before a trial resolves it
carries no value at all, which is not the same as a trial that resolved as
zero.

Two alert conditions share that dropdown and are not values. The gauge draws
nothing else, so there is nothing else to connect to.

WHAT THE GAUGE REFUSES TO PRINT

No verdict. Not "unusual", not "overextended", not "due for a reversal".

No percentage below ten prior runs. No count that includes the run in
progress. No confidence interval, no significance test, no p-value. The sample
size is printed and you weigh it yourself.

No colour coding by outcome. The headline is green on an up run and red on a
down run because that is the run's DIRECTION, and for no other reason; the
strip below it is one neutral colour whose transparency carries the sample
size.

WHAT IT WILL NOT TELL YOU

It measures one thing at a horizon of one bar: whether the next bar closed the
same way. It has no forward return at longer horizons, no excursion figures,
no regime splits and no cost sensitivity. Those belong to Signal Audit Lab
[BSL], and this gauge is a producer feeding into it.

It does not report a mean or expected run length, and it draws no
distribution. It contains no entry, exit, stop or position size, and it
asserts no direction: a run of eight is reported as a run of eight.

This tool reports historical base rates with their denominators. It does not
predict price, guarantee performance or provide trading advice. Validate the
behaviour on your own symbols, timeframes and execution assumptions before
making decisions.

Open-source Pine Script® v6. Educational use only.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © BarState Labs
//@version=6
indicator("Run-Length Base Rate Gauge [BSL]", shorttitle = "BSL Run Length", overlay = true)

// One number and one line under it. Price has closed in the same direction r
// bars in a row; runs that reached r have happened n times on this chart before
// this one, and k of those went one bar further. The gauge asserts no direction
// and issues no signal. It answers "is this unusual" with a count instead of an
// adjective.
//
// The denominator is the product. A run still in progress has not yet had the
// chance to stop, so it is held as PENDING and counted nowhere — neither as a
// success it has not earned nor as a failure that has not happened.

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
const string GROUP_EVENT = "01 · Exported event"
const string GROUP_DISPLAY = "02 · Display"

const int MAX_RUN = 60
const int MIN_N_FOR_RATE = 10

int thresholdInput = input.int(5, "Exported threshold, bars in a row", minval = 1, maxval = MAX_RUN,
     group = GROUP_EVENT,
     tooltip = "The strip always reports the base rate at the run length in front of you. This input sets a FIXED run length for the exported stream instead, because an event whose definition moved with the live run length would not be one event.")

string panelPositionInput = input.string("Bottom center", "Panel position", options = ["Auto", "Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center"],
     group = GROUP_DISPLAY, tooltip = "Auto keeps the gauge opposite the latest price within the visible chart range. Pick a corner by hand when another script already occupies this one.")

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────
color C_INK = color.rgb(11, 14, 13)
color C_PAPER = color.rgb(242, 239, 232)
color C_MUTED = color.rgb(137, 145, 141)
color C_AMBER = color.rgb(244, 184, 96)
color C_GREEN = color.rgb(114, 224, 165)
color C_RED = color.rgb(240, 120, 103)
color C_LINE = color.new(C_MUTED, 65)

// Transparency as a step function of the sample size. This is part of the
// product and not styling: a rate resting on four runs must not look like a
// rate resting on four hundred.
f_transparency(int n) =>
    n <= 0 ? 70 : n < MIN_N_FOR_RATE ? 55 : n < 30 ? 35 : n < 100 ? 15 : 0

// ─────────────────────────────────────────────────────────────────────────────
// Run length
//
// An unchanged close is 0 and not a direction. It ends a run without starting
// one, because "the same direction" is a claim about a sign and a bar that went
// nowhere carries no sign. `ta.barssince` is evaluated in global scope on every
// bar rather than inside a condition: a history-dependent function that only
// runs on some bars carries a different history.
// ─────────────────────────────────────────────────────────────────────────────
bool configValid = thresholdInput >= 1 and thresholdInput <= MAX_RUN
bool standardChart = chart.is_standard

float closeDelta = close - close[1]
int direction = na(closeDelta) ? 0 : closeDelta > 0 ? 1 : closeDelta < 0 ? -1 : 0
bool directionChanged = direction != direction[1]
int barsSinceFlip = ta.barssince(directionChanged)

// A Pine boolean is never na, so warm-up has to be carried by a flag. Without
// it a bar with no previous close would be indistinguishable from a bar that
// closed unchanged, and the two are different statements.
// `ta.barssince` is na until its condition has been true once. A bar that closes
// unchanged has a resolved run length of 0 without ever needing that history, so
// the readiness flag asks for the elapsed count only when a direction exists.
bool runReady = not na(closeDelta) and (direction == 0 or not na(barsSinceFlip))
int runLength = not runReady ? na : direction == 0 ? 0 : barsSinceFlip + 1
int previousRun = runLength[1]

bool resolved = configValid and standardChart and barstate.isconfirmed and runReady and
     not na(previousRun)
bool forming = configValid and standardChart and not barstate.isconfirmed and runReady

// ─────────────────────────────────────────────────────────────────────────────
// The two counters
//
// A run of final length F contributes one observation to every threshold it
// reached and one success to every threshold it passed, recorded on the bar the
// run ends. That bar is the first on which the outcome exists. Nothing is ever
// written to an earlier bar's count.
//
// extended[L] and reached[L + 1] are arithmetically the same quantity inside the
// table. They are kept as two arrays anyway: reached[MAX_RUN + 1] does not exist,
// so the top row would otherwise have a numerator with no home, and a reader
// auditing the panel should be able to see the numerator and the denominator
// accumulated by two separate statements.
// ─────────────────────────────────────────────────────────────────────────────
var array<int> reached = array.new<int>(MAX_RUN, 0)
var array<int> extendedRuns = array.new<int>(MAX_RUN, 0)
var int terminatedRuns = 0
var int longestRun = 0
var int overflowRuns = 0

bool runContinued = resolved and runLength == previousRun + 1
bool runTerminated = resolved and previousRun >= 1 and not runContinued

if runTerminated
    terminatedRuns += 1
    longestRun := math.max(longestRun, previousRun)
    overflowRuns += previousRun > MAX_RUN ? 1 : 0
    int reachedCap = math.min(previousRun, MAX_RUN)
    for length = 1 to reachedCap
        array.set(reached, length - 1, array.get(reached, length - 1) + 1)
    int extendedCap = math.min(previousRun - 1, MAX_RUN)
    if extendedCap >= 1
        for length = 1 to extendedCap
            array.set(extendedRuns, length - 1, array.get(extendedRuns, length - 1) + 1)

// ─────────────────────────────────────────────────────────────────────────────
// Exported stream
//
// BarState Labs producer stream contract 1.1.0, signed-pulse profile, delay 0.
// The pulse is the trial itself and not a summary of the trials: on the bar a
// run that had reached the exported threshold either goes one further (+1) or
// stops (-1). Every value the panel counts is one of these pulses, so a
// consumer measuring the stream measures exactly the population on the panel.
//
// na means the product has no opinion yet — warm-up, an open bar, an invalid
// configuration, a non-standard chart. A consumer must not read it as "no
// event" or carry it forward with nz().
// ─────────────────────────────────────────────────────────────────────────────
int trialOutcome = resolved and previousRun == thresholdInput ? (runContinued ? 1 : -1) : 0

plot(resolved ? float(trialOutcome) : na, "Run trial outcome", display = display.data_window)

alertcondition(trialOutcome == 1, "Run extended past the threshold",
     "A run that had reached the exported threshold closed one more bar in the same direction.")
alertcondition(trialOutcome == -1, "Run stopped at the threshold",
     "A run that had reached the exported threshold did not close another bar in the same direction.")

// ─────────────────────────────────────────────────────────────────────────────
// The reading
//
// The strip reports the run length in front of the reader, which on an open bar
// is the forming one. Its denominator excludes the current run by construction,
// because the current run has not terminated and nothing terminated is missing
// from the arrays.
// ─────────────────────────────────────────────────────────────────────────────
int displayRun = runLength
bool haveRun = not na(displayRun) and displayRun >= 1
// Clamped rather than trusted. An array.get outside the table is a runtime
// error, not an na, so the index is forced into range before it is used.
int readRun = math.max(1, math.min(haveRun ? displayRun : thresholdInput, MAX_RUN))
int sampleN = configValid and standardChart ? array.get(reached, readRun - 1) : 0
int sampleK = configValid and standardChart ? array.get(extendedRuns, readRun - 1) : 0
float sampleRate = sampleN > 0 ? 100.0 * sampleK / sampleN : na

string directionWord = na(direction) or direction == 0 ? "FLAT" : direction > 0 ? "UP" : "DOWN"
string headline = not haveRun ? "NO RUN" : str.tostring(displayRun) + " IN A ROW · " + directionWord
string headlineText = forming ? "FORMING · " + headline : headline
color headlineColor = not haveRun ? C_MUTED : direction > 0 ? C_GREEN : C_RED

string fractionText = str.tostring(sampleK) + "/" + str.tostring(sampleN)
string rateText = sampleN >= MIN_N_FOR_RATE ? " · " + str.tostring(sampleRate, "#.0") + "%" :
     " · RATE HELD BELOW n=" + str.tostring(MIN_N_FOR_RATE)
string subjectText = (haveRun ? "" : "NO RUN · SHOWING THRESHOLD ") + "RUN OF " +
     str.tostring(readRun) + " OR LONGER"
string pendingText = haveRun ? " · PENDING 1" : ""
string overflowText = haveRun and displayRun > MAX_RUN ? " · PAST THE " + str.tostring(MAX_RUN) +
     "-BAR TABLE, READ AT " + str.tostring(MAX_RUN) : ""
string stripText = subjectText + " · n=" + str.tostring(sampleN) + " BEFORE THIS ONE · " +
     fractionText + " EXTENDED" + rateText + pendingText + overflowText

// ─────────────────────────────────────────────────────────────────────────────
// Gauge
//
// One table of two rows and one column, so the whole product is two strings.
// Everything that will not fit in them is carried in cell tooltips rather than
// dropped, and nothing that decides how the numbers were computed is left off
// the visible face.
// ─────────────────────────────────────────────────────────────────────────────
bool inVisibleWindow = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
var float visibleWindowHigh = na
var float visibleWindowLow = na
var float visibleWindowRightClose = na
if inVisibleWindow
    visibleWindowHigh := na(visibleWindowHigh) ? high : math.max(visibleWindowHigh, high)
    visibleWindowLow := na(visibleWindowLow) ? low : math.min(visibleWindowLow, low)
    visibleWindowRightClose := close

float visibleWindowMid = not na(visibleWindowHigh) and not na(visibleWindowLow) ?
     (visibleWindowHigh + visibleWindowLow) / 2.0 : na
string automaticPanelPosition = not na(visibleWindowMid) and visibleWindowRightClose > visibleWindowMid ?
     position.bottom_right : position.top_right
string resolvedPanelPosition = panelPositionInput == "Top right" ? position.top_right :
     panelPositionInput == "Bottom right" ? position.bottom_right :
     panelPositionInput == "Top left" ? position.top_left :
     panelPositionInput == "Bottom left" ? position.bottom_left :
     panelPositionInput == "Top center" ? position.top_center :
     panelPositionInput == "Bottom center" ? position.bottom_center : automaticPanelPosition

var table gauge = table.new(position.top_right, 1, 2, bgcolor = color.new(C_INK, 6),
     frame_color = C_LINE, frame_width = 1, border_color = C_LINE, border_width = 1)

if barstate.islast
    table.set_position(gauge, resolvedPanelPosition)
    if not standardChart
        table.cell(gauge, 0, 0, "FROZEN", text_color = C_AMBER, text_size = size.large,
             text_halign = text.align_left)
        table.cell(gauge, 0, 1, "NON-STANDARD BARS · NO RUNS, NO COUNTS, NO STREAM",
             text_color = C_AMBER, text_size = size.small, text_halign = text.align_left)
    else if not configValid
        table.cell(gauge, 0, 0, "CONFIG ERROR", text_color = C_RED, text_size = size.large,
             text_halign = text.align_left)
        table.cell(gauge, 0, 1, "EXPORTED THRESHOLD MUST BE 1 TO " + str.tostring(MAX_RUN),
             text_color = C_RED, text_size = size.small, text_halign = text.align_left)
    else
        int fade = f_transparency(sampleN)
        int headlineFade = forming ? math.max(fade, 45) : fade
        table.cell(gauge, 0, 0, headlineText, text_color = color.new(headlineColor, headlineFade),
             text_size = size.huge, text_halign = text.align_left,
             tooltip = "The run length in front of you. On an open bar it is marked FORMING and can still change with the next tick, because the bar's close is still moving. A forming run is drawn and never counted.")
        table.cell(gauge, 0, 1, stripText, text_color = color.new(C_PAPER, fade),
             text_size = size.small, text_halign = text.align_left,
             tooltip = "n counts runs on this chart that reached this length AND have already stopped. " +
             "The run in front of you is PENDING: it has not had the chance to stop yet, so counting it " +
             "would report an outcome that does not exist. Confirmation lag is 1 bar and it is the same " +
             "for every run length, so every row of this table shares one cutoff — the last run that " +
             "ended. Terminated runs so far: " + str.tostring(terminatedRuns) + ". Longest: " +
             str.tostring(longestRun) + ". Runs past the " + str.tostring(MAX_RUN) + "-bar table: " +
             str.tostring(overflowRuns) + ". Below n=" + str.tostring(MIN_N_FOR_RATE) +
             " the percentage is withheld and only the bare fraction is shown. " +
             "No direction is asserted and no signal is issued.")
````
