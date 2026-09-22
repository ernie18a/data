<!-- tradingview-pine-id: PUB;9cf3e2d8c43343858f33c603f850d9dd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Closed-Bar Anatomy Percentile Panel [BSL]

Source: https://www.tradingview.com/script/yzg354uS-Closed-Bar-Anatomy-Percentile-Panel-BSL/

## Description

A candle with a small body and a long upper wick has a name. Learning the name
does not tell you whether the body is small FOR THIS CHART, or whether the
wick is long compared to the last five hundred bars.

Closed-Bar Anatomy Percentile Panel [BSL] replaces the name with four numbers
and a rank for each:

    BODY            18.0%   PCTL 26 · SMALLER THAN 74% OF THEM · n=500
    UPPER WICK      61.0%   PCTL 93 · LARGER THAN 93% OF THEM  · n=500
    LOWER WICK      21.0%   PCTL 44                            · n=500
    CLOSE POSITION  12.0%   PCTL 08                            · n=500

Plus the bar's whole range against its own median: 1.4 times.

FOUR SHARES OF ONE BAR

Body, upper wick and lower wick are shares of the bar's OWN range, and the
three of them always add to 100. A large body on a small bar and a large body
on a huge bar produce the same number, which is the point: the shape is
separated from the size, and the size gets its own line.

Close position is where the close sits inside the range, from bottom to top.
It is a LOCATION, not a direction. An up bar and a down bar with identical
geometry produce identical body and wick shares; only the close position
separates them, and that is a fact about where the bar closed, not a verdict
about what it means.

RANKED AGAINST WHAT, EXACTLY

Against the previous 500 bars of this same chart. Not against a textbook, not
against another instrument, and not against the bar itself: the bar being
described is excluded from its own comparison window, which is what makes
"thinner than 74% of the last 500 bars" mean the last 500 OTHER bars.

Change the window and the percentiles change, because you have changed the
question.

NO NAME, NO BULL COLOUR, NO BEAR COLOUR

There is no pattern name anywhere in this script: not in the title, an input
label, a tooltip, a panel cell or an alert.

There is also no bullish colour and no bearish colour anywhere in the source.
A green body would put back the verdict this panel exists to remove, and it
would arrive through the palette, where nobody argues with it. The numbers are
printed in one neutral colour and left alone.

WHEN A NUMBER IS WITHHELD

A bar with no range at all has no shares. Every share would be a division by
zero, so the panel prints a dash rather than a fabricated figure.

A bar with no range ANYWHERE in the window withholds all four ranks, rather
than quietly ranking against 499 bars while the panel still says 500. A small
misstatement about a denominator compounds into a large one about a
percentile.

An absent rank is not a rank of zero, and the drawing keeps them apart: an
absent rank draws as dots, an actual zero draws as an empty bar. They look
different because they mean different things.

The bar still forming gets its own row, separate from the four, with its live
shares and no percentile at all. Its shape can still change.

WHY ALL FOUR ROWS SHOW THE SAME n

Because they must. All four use the same window, the same warm-up, and none of
them waits on an outcome, a bar's geometry is finished the moment it closes.
So all four become available and unavailable together, and the only unfinished
observation on the chart is the bar still open, which is why it sits in a row
of its own.

Four equal sample sizes here are a fact you can rely on, not a default value
nobody filled in.

SETTINGS

- Window: 500 bars
- Panel position: Bottom center

Six positions, and the panel opens at the bottom center. Six rows is a lot of
panel, so it needs a strip nothing else draws in: the legend and the trading
buttons take the top left, the platform's own logo sits in the bottom left, and
the price scale owns the right.

RANKING A SMOOTHING AGAINST ITSELF

The body share of a Heikin Ashi candle is a property of the averaging, not of
the session. Ranking it would rank one smoothing setting against itself.
Renko, Kagi, Point & Figure and Range have the same problem in their own way.

On those chart types the panel freezes and publishes nothing.

FOUR PERCENTILES, PUBLISHED

Four values are published for other indicators to pick up in their Source
setting: the four percentiles. On any bar where a rank is unavailable they
carry no value at all, which is not the same as a percentile of zero, and the
difference matters to anything consuming them, because zero is the lowest
possible rank and "no value" is not a rank.

These four are the only entries this panel puts in that dropdown. It draws no
series on the chart and offers no alerts, so there is nothing else to pick by
mistake.

THERE ARE NO ALERTS

There is no event here to alert on. An alert on a percentile crossing would be
a signal wearing a description's clothes, so the script offers none.

WHAT IT WILL NOT TELL YOU

It has no direction, no bias, no score and no signal, and it emits no events.
A description is not a signal, and presenting one as the other is the exact
overreach this panel exists to argue against.

It measures nothing that happens afterwards. It names no pattern, uses no
support or resistance level, and every number it prints describes a single
bar. There is no multi-bar shape anywhere in it.

Where outcomes are measured is elsewhere: Signal Audit Lab [BSL] takes any
event series and reports what followed.

This tool describes the geometry of one closed bar. It does not predict price,
guarantee performance or provide trading advice. Validate the behaviour on
your own symbols, timeframes and execution assumptions before making
decisions.

Open-source Pine Script® v6. Educational use only.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © BarState Labs
//@version=6
indicator("Closed-Bar Anatomy Percentile Panel [BSL]", shorttitle = "BSL Bar Anatomy", overlay = true)

// The last completed candle broken into four numbers, each with a percentile
// beside it: body 18% of range and thinner than 74% of the last 500 bars, upper
// wick 61%, lower wick 21%, close at 12% of range.
//
// No pattern is named anywhere in this script and nothing on the panel is
// coloured bullish or bearish. The whole argument is that the shape is a
// measurement rather than a verdict, and a palette that took a side would
// undo it.

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
const string GROUP_WINDOW = "01 · Comparison window"
const string GROUP_DISPLAY = "02 · Display"

const int RANK_CELLS = 10

int windowInput = input.int(500, "Window, bars", minval = 20, maxval = 5000, group = GROUP_WINDOW,
     tooltip = "How many PREVIOUS bars each ratio is ranked against. The bar being described is never in its own window, so 'thinner than 74%' means 74% of the other bars.")

string panelPositionInput = input.string("Bottom center", "Panel position", options = ["Auto", "Top right", "Bottom right", "Top left", "Bottom left", "Top center", "Bottom center"],
     group = GROUP_DISPLAY, tooltip = "Auto keeps the panel opposite the latest price within the visible chart range. Pick a corner by hand when another script already occupies this one.")

// ─────────────────────────────────────────────────────────────────────────────
// Palette
//
// One neutral colour for every measurement. There is no bull colour and no bear
// colour in this file, and a test asserts their absence, because the product's
// claim is that a shape is a measurement and a green body would be a verdict
// smuggled in through the stylesheet. Amber appears only on a status that says
// the product could not measure something.
// ─────────────────────────────────────────────────────────────────────────────
color C_INK = color.rgb(11, 14, 13)
color C_PANEL = color.rgb(20, 25, 23)
color C_PAPER = color.rgb(242, 239, 232)
color C_MUTED = color.rgb(137, 145, 141)
color C_AMBER = color.rgb(244, 184, 96)
color C_BAR = color.rgb(150, 168, 178)
color C_LINE = color.new(C_MUTED, 65)

// The rank drawing: one neutral bar filling left to right.
f_rank_bar(float percentile) =>
    string drawing = ""
    if na(percentile)
        for cell = 1 to RANK_CELLS
            drawing += "·"
    else
        int filled = math.min(RANK_CELLS, math.max(0, int(math.round(RANK_CELLS * percentile / 100.0))))
        for cell = 1 to RANK_CELLS
            drawing += cell <= filled ? "█" : "░"
    drawing

f_share_text(float share) =>
    na(share) ? "—" : str.tostring(share, "#.#") + "%"

// "Smaller than 74% of them" is 100 minus the rank, because the rank counts the
// previous values at or below this one. Both numbers are printed rather than
// one, so a reader can check the sentence against the figure it came from.
f_rank_text(float percentile) =>
    na(percentile) ? "—" : "PCTL " + str.tostring(percentile, "#") + "  ·  SMALLER THAN " +
     str.tostring(100.0 - percentile, "#") + "% OF THEM"

// ─────────────────────────────────────────────────────────────────────────────
// The four ratios
//
// A zero-range bar has no shares. 0/0 is not 0, and a row printing 0% there
// would assert that the bar had no body when in fact it had no extent to
// measure one against.
// ─────────────────────────────────────────────────────────────────────────────
bool configValid = windowInput >= 20 and windowInput <= 5000
bool standardChart = chart.is_standard

float barRange = high - low
bool rangeDefined = barRange > 0.0
float bodyTop = math.max(open, close)
float bodyBottom = math.min(open, close)

float bodyShare = rangeDefined ? 100.0 * math.abs(close - open) / barRange : na
float upperShare = rangeDefined ? 100.0 * (high - bodyTop) / barRange : na
float lowerShare = rangeDefined ? 100.0 * (bodyBottom - low) / barRange : na
float closePosition = rangeDefined ? 100.0 * (close - low) / barRange : na

// ─────────────────────────────────────────────────────────────────────────────
// Ranking, and the one thing that blocks it
//
// `ta.percentrank` compares this bar against the `window` bars before it. A
// zero-range bar in that window has no ratio to contribute, so the window is
// short by one and the denominator quietly shrinks. Rather than publish a rank
// whose denominator a reader cannot see, the product counts the blocking bars
// and prints the count and the reason.
//
// The count is taken over exactly the ranking window: math.sum includes the
// current bar, so the series is offset by one to cover bars t-1 back to
// t-window and nothing else.
// ─────────────────────────────────────────────────────────────────────────────
float zeroRangeSum = math.sum(rangeDefined ? 0.0 : 1.0, windowInput)[1]
int zeroRangeInWindow = na(zeroRangeSum) ? na : int(zeroRangeSum)

bool historyReady = configValid and standardChart and bar_index >= windowInput and
     not na(zeroRangeInWindow)
bool percentileReady = historyReady and rangeDefined and zeroRangeInWindow == 0

// Evaluated in global scope on every bar rather than inside a condition: a
// history-dependent function that only runs on some bars carries a different
// history.
float bodyRank = ta.percentrank(bodyShare, windowInput)
float upperRank = ta.percentrank(upperShare, windowInput)
float lowerRank = ta.percentrank(lowerShare, windowInput)
float closeRank = ta.percentrank(closePosition, windowInput)

float bodyPercentile = percentileReady ? bodyRank : na
float upperPercentile = percentileReady ? upperRank : na
float lowerPercentile = percentileReady ? lowerRank : na
float closePercentile = percentileReady ? closeRank : na

// The fourth number in the promise. It is a context reading rather than a fifth
// ranked row, and it uses the same offset window as the ranks so the two cannot
// describe different stretches of history.
float medianRange = ta.median(barRange[1], windowInput)
float rangeMultiple = historyReady and rangeDefined and not na(medianRange) and medianRange > 0.0 ?
     barRange / medianRange : na

bool confirmedBar = configValid and standardChart and barstate.isconfirmed
bool formingBar = configValid and standardChart and not barstate.isconfirmed

// ─────────────────────────────────────────────────────────────────────────────
// Exported streams
//
// BarState Labs producer stream contract 1.1.0, numeric-value profile, delay 0.
// Four percentile ranks, domain finite-real, units "percentile rank against the
// window, 0-100". A percentile is a measurement — magnitude, order and
// arithmetic all carry meaning — and its value set cannot be enumerated, so
// 1.1.0 requires a declared domain and a declared unit instead of an alphabet.
//
// The shares themselves are not exported. Any consumer holding the same OHLC
// can recompute them; the rank against this chart's own history is the thing
// only this product has.
//
// The forming bar publishes na. Unlike a window statistic, this reading is
// ABOUT the current bar, and the current bar's shape can still change with the
// next tick, so the producer genuinely has no opinion about it yet. na also
// covers warm-up, an invalid configuration, a non-standard chart and a window
// holding a zero-range bar. A consumer must not read it as a rank of zero or
// carry it forward with nz().
// ─────────────────────────────────────────────────────────────────────────────
plot(confirmedBar ? bodyPercentile : na, "Body share percentile", display = display.data_window)
plot(confirmedBar ? upperPercentile : na, "Upper wick share percentile", display = display.data_window)
plot(confirmedBar ? lowerPercentile : na, "Lower wick share percentile", display = display.data_window)
plot(confirmedBar ? closePercentile : na, "Close position percentile", display = display.data_window)

// ─────────────────────────────────────────────────────────────────────────────
// The last confirmed bar
//
// Snapshotted on confirmation, so the panel keeps describing the completed
// candle while the next one is still moving. A confirmed bar with no range is
// snapshotted too, with its flag, because "the last closed bar had no extent"
// is a reading and skipping it would silently show an older bar instead.
// ─────────────────────────────────────────────────────────────────────────────
var float snapBody = na
var float snapUpper = na
var float snapLower = na
var float snapClose = na
var float snapBodyRank = na
var float snapUpperRank = na
var float snapLowerRank = na
var float snapCloseRank = na
var float snapMultiple = na
var bool snapDefined = false
var bool snapRanked = false
var int snapZero = na
var int snapBar = na

if confirmedBar
    snapBody := bodyShare
    snapUpper := upperShare
    snapLower := lowerShare
    snapClose := closePosition
    snapBodyRank := bodyPercentile
    snapUpperRank := upperPercentile
    snapLowerRank := lowerPercentile
    snapCloseRank := closePercentile
    snapMultiple := rangeMultiple
    snapDefined := rangeDefined
    snapRanked := percentileReady
    snapZero := zeroRangeInWindow
    snapBar := bar_index

// ─────────────────────────────────────────────────────────────────────────────
// Panel
//
// Six rows and four columns: a merged context bar, the four measurements, and a
// merged row for the bar still forming. The forming bar is kept out of the four
// rows entirely rather than mixed into them, so a reader can see that the candle
// in front of them can still change shape.
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

var table panel = table.new(position.top_right, 4, 6, bgcolor = C_PANEL,
     frame_color = C_LINE, frame_width = 1, border_color = C_LINE, border_width = 1)

if barstate.isfirst
    table.merge_cells(panel, 0, 0, 3, 0)
    table.merge_cells(panel, 0, 5, 3, 5)

if barstate.islast
    table.set_position(panel, resolvedPanelPosition)

    string statusText = not standardChart ? "FROZEN · NON-STANDARD BARS" :
         not configValid ? "CONFIG ERROR" :
         na(snapBar) ? "WARM-UP · NO CLOSED BAR YET" :
         not snapDefined ? "LAST CLOSED BAR HAD NO RANGE" :
         not snapRanked ? (na(snapZero) ? "WARM-UP · WINDOW NOT FULL" :
              "PERCENTILES HELD · " + str.tostring(snapZero) + " ZERO-RANGE BARS IN WINDOW") :
         "RANKED AGAINST " + str.tostring(windowInput) + " BARS"
    color statusColor = snapRanked ? C_PAPER : C_AMBER
    string multipleText = na(snapMultiple) ? "" :
         "  ·  RANGE " + str.tostring(snapMultiple, "#.##") + "× ITS MEDIAN"

    table.cell(panel, 0, 0, "BSL / BAR ANATOMY  ·  " + syminfo.ticker + " " + timeframe.period +
         "  ·  " + statusText + multipleText + "  ·  MEASUREMENT, NOT A PATTERN NAME",
         text_color = statusColor, bgcolor = C_INK, text_size = size.small, text_halign = text.align_left,
         tooltip = "The four rows describe the LAST CLOSED bar. Confirmation lag is 0 bars for every row and every row uses the same window, so all four share one cutoff — the last confirmed bar — and the only censored observation on the chart is the bar still forming, which has its own row at the bottom and no percentile at all. B-vis3-07 Eligible-Window Curtain owns the general form of that window. No pattern is named here and nothing is coloured bullish or bearish.")

    array<string> rowLabels = array.from("BODY", "UPPER WICK", "LOWER WICK", "CLOSE POSITION")
    array<float> rowShares = array.from(snapBody, snapUpper, snapLower, snapClose)
    array<float> rowRanks = array.from(snapBodyRank, snapUpperRank, snapLowerRank, snapCloseRank)
    array<string> rowTips = array.from(
         "The open-to-close distance as a share of the bar's whole range. Body, upper wick and lower wick sum to 100 by construction.",
         "The distance from the higher of open and close up to the high, as a share of the range.",
         "The distance from the low up to the lower of open and close, as a share of the range.",
         "Where the close sits inside the range: 0% is exactly at the low, 100% exactly at the high.")

    for index = 0 to 3
        int row = index + 1
        float share = array.get(rowShares, index)
        float rank = array.get(rowRanks, index)
        table.cell(panel, 0, row, array.get(rowLabels, index), text_color = C_MUTED,
             text_size = size.small, text_halign = text.align_left,
             tooltip = array.get(rowTips, index))
        table.cell(panel, 1, row, f_share_text(share), text_color = C_PAPER, text_size = size.small)
        table.cell(panel, 2, row, f_rank_bar(rank), text_color = C_BAR, text_size = size.small,
             text_halign = text.align_left)
        table.cell(panel, 3, row, f_rank_text(rank) + (na(rank) ? "" : "  ·  n=" +
             str.tostring(windowInput)), text_color = na(rank) ? C_AMBER : C_MUTED,
             text_size = size.small, text_halign = text.align_left,
             tooltip = "The percentile counts the previous bars whose value was at or below this one, out of the whole window. The bar being described is never in its own window. A rank is withheld entirely — never estimated — until the window is full and free of zero-range bars.")

    string formingText = not formingBar ? "NO BAR FORMING · THE LAST BAR ON THE CHART IS CLOSED" :
         not rangeDefined ? "STILL FORMING · NO RANGE YET · NO PERCENTILE" :
         "STILL FORMING  ·  BODY " + f_share_text(bodyShare) + "  ·  UPPER " + f_share_text(upperShare) +
         "  ·  LOWER " + f_share_text(lowerShare) + "  ·  CLOSE AT " + f_share_text(closePosition) +
         "  ·  NO PERCENTILE"
    table.cell(panel, 0, 5, formingText, text_color = color.new(C_MUTED, 30), bgcolor = C_INK,
         text_size = size.small, text_halign = text.align_left,
         tooltip = "The bar in front of you has not closed. Its shape can still change with the next tick, so it is shown on its own row, it is given no percentile, and it never enters the window the four rows above are ranked against.")
````
