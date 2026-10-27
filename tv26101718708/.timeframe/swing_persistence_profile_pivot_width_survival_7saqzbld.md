# Swing Persistence Profile - Pivot Width Survival

- url: https://www.tradingview.com/script/7SaQzbLD-Swing-Persistence-Profile-Pivot-Width-Survival/
- type: indicator
- pine_id: PUB;e6038a571eb34e2589ba52a15e3e34b9
- version: 1.0

## Description

Swing Persistence Profile ranks every swing high and swing low on the chart by the widest pivot
window it survives. It is also explicit about the exact bar on which that rank becomes knowable,
and it shades the region where it is not knowable yet.

THE IDEA

A pivot is not a property of a bar on its own. It is a property of a bar together with the width
of the window it was compared against. The same high is a swing high when you look two bars either
side, and is not a swing high when you look thirteen. Tools that ask you to pick one width and
then draw the result bury that choice inside a single number.

This script evaluates up to five widths at once - 2, 3, 5, 8 and 13 bars each side by default -
and records, for every bar, the widest width at which that bar is still the extreme of its window.
That number is the bar's persistence depth.

Because widening a window can only add constraints, the widths are strictly nested: a bar that is
the highest of its 13-bar neighbourhood is necessarily also the highest of its 8, 5, 3 and 2-bar
neighbourhoods. Depth is therefore a single ordered rank rather than five separate opinions that
have to be reconciled. A depth-13 swing is a depth-3 swing that kept going.

TIMING

A pivot of width w cannot be identified until w bars have closed after it. That is arithmetic, not
an implementation detail, and it means a bar's persistence depth is not final until the deepest
active width has passed.

There is one further subtlety that most pivot scripts leave in place. The w-th bar after the
candidate is itself still forming while it is the live bar, and its own high or low can still
invalidate the pivot. A script that reads the verdict during that bar will show a marker that
changes, or vanishes, before the bar closes.

This one waits one bar longer. Every verdict it reads comes from a bar that has already closed, so
the confirmation lag is the deepest active width plus one bar. A marker is created once, on the
bar it describes, and is then left alone: it is not moved, recoloured or deleted on later bars,
and it does not flicker intrabar either.

The bars still inside that delay are shaded, so the region where the answer can still change is
visible on the chart instead of being left to inference. Nothing inside the shaded region has been
ranked yet, so an empty shaded region means "not decided," not "no swings here."

WHAT IS DRAWN

A marker on each qualifying swing, placed on the bar that made the extreme, coloured and sized by
depth, optionally printing the depth as a number.

An optional structure line joining swings at or above one chosen depth, alternating between highs
and lows. The most recent segment extends if a later bar sets a more extreme value in the same
direction; once a swing in the opposite direction closes a segment, that segment is fixed.

An optional higher-timeframe reference: the price of the most recent confirmed swing high and
swing low measured on a higher timeframe, drawn as a stepped level. The requested expression is
offset by one bar and the request uses lookahead, which is the pair the Pine Script documentation
specifies for confirmed higher-timeframe values, so historical and realtime bars receive the same
series. The level therefore lags by the reference width plus one bar of the reference timeframe,
and that lag is the point rather than a defect.

Optional alerts on a swing reaching a chosen depth. The alert fires as many bars after the swing
as the deepest active width plus one; the swing itself is on the earlier bar. Because every
verdict is read from a closed bar, "Once Per Bar" and "Once Per Bar Close" fire on the same bar.

THE TABLE

"Swings" counts how many swings reached at least that depth across loaded history, highs and lows
together. "Kept" is the share of the previous row's swings that survived into this row. "Bars ea"
is the average number of bars per swing at that depth. The footer reports the confirmation lag in
bars and how many bars have been rated.

The survival ratios describe the instrument and timeframe you are looking at, not any particular
trade. If most depth-2 swings die at depth 3, the chart is producing many local extremes that do
not extend. If they survive, the same series is producing fewer and longer swings. Comparing that
profile across timeframes or across symbols is a way of choosing a swing width that matches how a
market actually moves, rather than choosing 5 because 5 is a common default.

Counts cover every bar of history the chart has loaded, so they are comparable between symbols
only when the loaded history is comparable.

SETTINGS

Depths in use activates between two and five of the width slots. Reducing it also shortens the
undecided region at the right edge, because that region is as long as the deepest active width
plus one settling bar.

Every depth threshold in the script - minimum depth to mark, minimum depth for the structure line,
and the alert depth - is stated in BARS EACH SIDE, not as a slot number. With the default widths,
"minimum depth 3" means the second of the five slots. A threshold set above the deepest active
width produces nothing, by design.

Enter the widths in ascending order. The ranking itself does not require it, but the table only
reads as a survival sequence when they ascend, and "Kept" can exceed 100% if they do not.

The higher-timeframe reference width is counted in bars of that timeframe: a width of 5 on a daily
reference means five daily bars each side.

WHO IT IS FOR

Anyone who uses swing points as an input to something else - reading structure, choosing the
lookback for a range or a channel, deciding how far back a level should be considered relevant -
and would rather see how sensitive those points are to window width than settle it by habit. It is
also usable as a calibration step before fixing a pivot length in another tool.

WHAT IT DOES NOT DO

It produces no entries, exits, targets, direction or bias, and nothing in it should be read as
one. It measures the geometry of the price series and stops there. Persistence depth describes
what has already happened; a deep swing is not evidence about what happens next.

NOTES

Highs and lows come from the chart series. On non-standard chart types - Heikin Ashi, Renko, Kagi,
Point and Figure, Range - those values are synthetic, and the depths will describe the synthetic
series rather than the market. The script declares alert conditions, so it should be used and
presented on a standard chart type.

TradingView permits 500 labels and 500 lines per script. On long histories the platform drops the
oldest drawings as newer ones are created, so the left edge of a deep history may be bare. This
does not affect the table, which counts every rated bar.

Persistence depth for highs and lows, and the bar index each verdict refers to, are available in
the Data Window. Those values describe the bar named by "Swing bar index," not the bar the cursor
is on.

One data request is made for the higher-timeframe reference whether or not it is displayed, so
enabling it costs nothing extra.

ORIGINALITY

The built-in ta.pivothigh() and ta.pivotlow() functions are used as the primitive, as they are in
a great many scripts. Everything above them is written for this script: running several widths in
parallel, aligning their verdicts onto a common bar so that they can be compared, reducing them to
one nested rank, deferring every drawing until that rank is final on closed data, marking the
region where it is not yet final, and reporting the survival ratios between widths.

Open source under the Mozilla Public License 2.0. The logic is described above in enough detail to
be checked line by line against the source.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © harrell.jordon

indicator("Swing Persistence Profile", "SPP", overlay = true,
     max_labels_count = 500, max_lines_count = 500, max_bars_back = 500)

// ═════════════════════════════════════════════════════════════════════════════
//  A pivot is not a property of a bar. It is a property of a bar AND the width
//  of the window you looked at. The same high is a swing high at width 2 and
//  not a swing high at width 13. Most pivot tools hide that by asking you to
//  pick one width and then presenting the result as if it were a fact.
//
//  This script runs up to five pivot widths at once and, for every bar, records
//  the WIDEST width at which that bar is still an extreme. That number is the
//  bar's persistence depth. Depth 2 means the bar beat its two neighbours on
//  each side and nothing more. Depth 13 means it beat thirteen on each side,
//  and therefore also beat 8, 5, 3 and 2 - the widths are strictly nested, so
//  depth is a single ordered rank rather than five separate opinions.
//
//  Timing is handled explicitly, and slightly more conservatively than the
//  arithmetic minimum. A width-w pivot cannot be known until w bars after the
//  fact, and the w-th of those bars is still forming while it is the realtime
//  bar - its own high or low can still invalidate the pivot. So this script
//  waits max(width) + 1 bars: every verdict it reads comes from a bar that has
//  already closed. A marker is therefore created once, on the bar it belongs
//  to, and is never moved, recoloured or removed afterwards - not even
//  intrabar. The still-undecided bars at the hard right edge are shaded so the
//  region where the answer can still change is visible rather than implied.
//
//  The table turns the same data into a description of the instrument: how many
//  swings exist at each width, and what share of them survive to the next width
//  up. A market whose depth-2 swings mostly die at depth 3 is producing noise at
//  the chart timeframe. One where they survive is producing structure. That
//  ratio is a measured property of the series, not a forecast of anything.
// ═════════════════════════════════════════════════════════════════════════════


// ─────────────────────────── Inputs: depths ──────────────────────────────────
string G_DEPTH = "1 - Persistence depths"

int nDepths = input.int(5, "Depths in use", minval = 2, maxval = 5, group = G_DEPTH,
     tooltip = "How many of the five depth slots below are active. Slots above " +
               "this number are ignored by the ranking, the markers and the " +
               "table. Reducing this also shortens the undecided region at the " +
               "right edge, because that region is as long as the deepest " +
               "active width plus one settling bar.")

int d1 = input.int(2, "Depth 1 (bars each side)", minval = 1, maxval = 100, group = G_DEPTH,
     tooltip = "Narrowest width. A bar qualifies if its high is the extreme of " +
               "this many bars on both sides (lows, mirrored, for swing lows). " +
               "Enter the widths in ascending order; the ranking itself does " +
               "not require it, but the table reads as a survival sequence " +
               "only when they ascend.")

int d2 = input.int(3, "Depth 2", minval = 1, maxval = 100, group = G_DEPTH,
     tooltip = "Second width. Every bar that qualifies here also qualifies at " +
               "any narrower width, which is what makes depth an ordered rank.")

int d3 = input.int(5, "Depth 3", minval = 1, maxval = 100, group = G_DEPTH,
     tooltip = "Third width. Inactive when 'Depths in use' is below 3.")

int d4 = input.int(8, "Depth 4", minval = 1, maxval = 100, group = G_DEPTH,
     tooltip = "Fourth width. Inactive when 'Depths in use' is below 4.")

int d5 = input.int(13, "Depth 5", minval = 1, maxval = 100, group = G_DEPTH,
     tooltip = "Deepest width. This value alone sets the confirmation lag of " +
               "the whole script: no marker can be drawn until this many bars " +
               "have closed after the bar it describes, plus one settling bar. " +
               "Larger values mean fewer, more selective swings and a longer " +
               "wait.")


// ─────────────────────────── Inputs: markers ─────────────────────────────────
string G_MARK = "2 - Swing markers"

bool showMarks = input.bool(true, "Show swing markers", group = G_MARK,
     tooltip = "Draw one marker on each qualifying swing, positioned on the bar " +
               "that actually made the extreme. Markers are created once the " +
               "deepest width has confirmed on a closed bar, and are never " +
               "repositioned.")

int minRank = input.int(3, "Minimum depth to mark", minval = 1, maxval = 100, group = G_MARK,
     tooltip = "Depth thresholds on this script are stated in BARS EACH SIDE, " +
               "not in slot numbers: with the default widths, 3 means the " +
               "second slot. Swings below this depth are counted in the table " +
               "but not drawn. A value above the deepest active width draws " +
               "nothing at all.")

bool showRankText = input.bool(true, "Print the depth inside the marker", group = G_MARK,
     tooltip = "Shows the numeric persistence depth. Turn off for a cleaner " +
               "chart when you only need the colour and size gradient.")

color cShallow = input.color(color.new(#787b86, 20), "Shallow depth colour", group = G_MARK,
     tooltip = "Colour applied at the narrowest active width. Marker colour is " +
               "interpolated between this and the deep colour by depth.")

color cDeep = input.color(color.new(#2962ff, 0), "Deep depth colour", group = G_MARK,
     tooltip = "Colour applied at the deepest active width.")

color cMarkText = input.color(color.white, "Marker text colour", group = G_MARK,
     tooltip = "Text colour used when the depth number is printed.")


// ─────────────────────────── Inputs: structure line ──────────────────────────
string G_ZIG = "3 - Structure line"

bool showZig = input.bool(true, "Connect swings above a depth", group = G_ZIG,
     tooltip = "Joins qualifying swing highs and lows in alternation to give a " +
               "skeleton of the structure at one chosen scale. The most recent " +
               "segment extends if a later bar sets a more extreme value in the " +
               "same direction; earlier segments are fixed once drawn.")

int zigRank = input.int(5, "Minimum depth for the line", minval = 1, maxval = 100, group = G_ZIG,
     tooltip = "Stated in bars each side, like the marker threshold. Only " +
               "swings at or above this persistence depth become nodes of the " +
               "line. Setting it equal to the deepest active width gives the " +
               "sparsest skeleton; setting it above that width draws nothing.")

color cZig = input.color(color.new(#2962ff, 30), "Line colour", group = G_ZIG,
     tooltip = "Colour of the connecting segments.")

int zigWidth = input.int(2, "Line width", minval = 1, maxval = 5, group = G_ZIG,
     tooltip = "Thickness of the connecting segments in pixels.")


// ─────────────────────────── Inputs: undecided region ────────────────────────
string G_PROV = "4 - Undecided region"

bool showProv = input.bool(true, "Shade the undecided bars", group = G_PROV,
     tooltip = "Shades the bars at the right edge whose persistence depth is " +
               "not yet final, because the deepest width has not yet had that " +
               "many CLOSED bars to the right of them. Nothing inside this " +
               "region has been ranked yet; it is shaded so the wait is visible " +
               "instead of being mistaken for an absence of swings.")

color cProv = input.color(color.new(#787b86, 88), "Shading colour", group = G_PROV,
     tooltip = "Background colour of the undecided region. Keep the " +
               "transparency high so candles stay readable.")


// ─────────────────────────── Inputs: higher timeframe ────────────────────────
string G_HTF = "5 - Higher-timeframe reference"

bool showHtf = input.bool(false, "Show higher-timeframe swing levels", group = G_HTF,
     tooltip = "Plots the price of the most recent confirmed swing high and " +
               "swing low found on a higher timeframe, as a stepped level on " +
               "the chart timeframe. Off by default. Note that the single " +
               "request.security() call is made whether this is on or off, so " +
               "enabling it costs nothing extra.")

string htfTf = input.timeframe("D", "Reference timeframe", group = G_HTF,
     tooltip = "Timeframe the reference swings are measured on. Choose one " +
               "higher than the chart; a lower one produces a level that " +
               "changes several times inside a single chart bar and is not " +
               "meaningful here.")

int htfDepth = input.int(5, "Reference width (bars each side)", minval = 1, maxval = 100, group = G_HTF,
     tooltip = "Pivot width used on the reference timeframe, counted in bars " +
               "OF THAT TIMEFRAME. A width of 5 on the daily row means five " +
               "daily bars on each side.")

color cHtfHigh = input.color(color.new(#f23645, 0), "Reference high colour", group = G_HTF,
     tooltip = "Colour of the higher-timeframe swing-high level.")

color cHtfLow = input.color(color.new(#089981, 0), "Reference low colour", group = G_HTF,
     tooltip = "Colour of the higher-timeframe swing-low level.")


// ─────────────────────────── Inputs: table ───────────────────────────────────
string G_TAB = "6 - Survival table"

bool showTable = input.bool(true, "Show survival table", group = G_TAB,
     tooltip = "Counts, per active width, how many swings on this chart reached " +
               "at least that depth, and what share of the previous width's " +
               "swings survived into it. Counts cover every bar of loaded " +
               "history and combine highs and lows.")

string tabPos = input.string("Top right", "Table position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = G_TAB,
     tooltip = "Corner of the chart the table is anchored to.")

color cTabText = input.color(color.new(#d1d4dc, 0), "Table text colour", group = G_TAB,
     tooltip = "Text colour of the table body.")

color cTabBg = input.color(color.new(#131722, 25), "Table background colour", group = G_TAB,
     tooltip = "Background colour of the table cells.")


// ─────────────────────────── Inputs: alerts ──────────────────────────────────
string G_ALERT = "7 - Alerts"

int alertRank = input.int(8, "Alert at depth or above", minval = 1, maxval = 100, group = G_ALERT,
     tooltip = "Persistence depth an alert requires, in bars each side. The " +
               "alert necessarily fires as many bars after the swing as the " +
               "deepest active width, plus one settling bar - that delay is " +
               "the price of the depth being final at all. Because every " +
               "verdict is read from a closed bar, 'Once Per Bar' and 'Once " +
               "Per Bar Close' fire on the same bar. A value above the deepest " +
               "active width never fires.")


// ═════════════════════════════════════════════════════════════════════════════
//  CORE
// ═════════════════════════════════════════════════════════════════════════════

bool en1 = nDepths >= 1
bool en2 = nDepths >= 2
bool en3 = nDepths >= 3
bool en4 = nDepths >= 4
bool en5 = nDepths >= 5

// Deepest and shallowest active widths. Disabled slots are folded to 1 when
// taking the maximum and to 100 (the input ceiling) when taking the minimum, so
// an inactive slot can never widen the window nor drag the gradient floor down.
int maxD = math.max(d1, d2, en3 ? d3 : 1, en4 ? d4 : 1, en5 ? d5 : 1)
int minD = math.min(d1, d2, en3 ? d3 : 100, en4 ? d4 : 100, en5 ? d5 : 100)

// Total settle lag. maxD bars are needed for the widest pivot to be decidable
// at all; the extra bar means the last of those bars has CLOSED before its
// verdict is read, so nothing here is ever computed from a forming bar.
int lag = maxD + 1

// One pivot series per width. These are evaluated on every bar, unconditionally,
// so the internal state of ta.pivothigh()/ta.pivotlow() stays consistent.
float ph1 = ta.pivothigh(high, d1, d1)
float ph2 = ta.pivothigh(high, d2, d2)
float ph3 = ta.pivothigh(high, d3, d3)
float ph4 = ta.pivothigh(high, d4, d4)
float ph5 = ta.pivothigh(high, d5, d5)

float pl1 = ta.pivotlow(low, d1, d1)
float pl2 = ta.pivotlow(low, d2, d2)
float pl3 = ta.pivotlow(low, d3, d3)
float pl4 = ta.pivotlow(low, d4, d4)
float pl5 = ta.pivotlow(low, d5, d5)

// @function     Reports whether the bar under judgement qualified at one width.
// @param en     Whether this depth slot is active.
// @param pv     A ta.pivothigh()/ta.pivotlow() series.
// @param d      The width that series was built with.
// @param lg     The settle lag: deepest active width plus one.
// @returns      True if the bar lg bars back was an extreme at width d.
//
// A width-d pivot series reports about the bar d bars behind the bar it is read
// on. The bar being judged here sits lg bars back, so the verdict for width d
// was published (lg - d) bars ago and is read at that offset. Because lg is at
// least one greater than every active d, that offset is never 0 and the value
// read therefore always comes from a bar that has already closed.
survives(bool en, float pv, int d, int lg) =>
    en and not na(pv[math.max(1, lg - d)])

int rankH = 0
if survives(en1, ph1, d1, lag)
    rankH := math.max(rankH, d1)
if survives(en2, ph2, d2, lag)
    rankH := math.max(rankH, d2)
if survives(en3, ph3, d3, lag)
    rankH := math.max(rankH, d3)
if survives(en4, ph4, d4, lag)
    rankH := math.max(rankH, d4)
if survives(en5, ph5, d5, lag)
    rankH := math.max(rankH, d5)

int rankL = 0
if survives(en1, pl1, d1, lag)
    rankL := math.max(rankL, d1)
if survives(en2, pl2, d2, lag)
    rankL := math.max(rankL, d2)
if survives(en3, pl3, d3, lag)
    rankL := math.max(rankL, d3)
if survives(en4, pl4, d4, lag)
    rankL := math.max(rankL, d4)
if survives(en5, pl5, d5, lag)
    rankL := math.max(rankL, d5)

// The bar every verdict above refers to.
bool  judged = bar_index >= lag
int   sBar   = bar_index - lag
float pxHigh = high[lag]
float pxLow  = low[lag]


// ═════════════════════════════════════════════════════════════════════════════
//  MARKERS
// ═════════════════════════════════════════════════════════════════════════════

// @function   Interpolates marker colour across the active depth range.
// @param r    Persistence depth of the swing.
// @returns    A colour between the shallow and deep inputs.
rankColour(int r) =>
    color.from_gradient(r, minD, math.max(maxD, minD + 1), cShallow, cDeep)

// @function   Maps persistence depth to a label size.
// @param r    Persistence depth of the swing.
// @returns    A label size constant.
rankSize(int r) =>
    r >= maxD ? size.normal : r * 2 >= maxD + minD ? size.small : size.tiny

if showMarks and judged and rankH >= minRank
    label.new(sBar, pxHigh, showRankText ? str.tostring(rankH) : "",
         yloc      = yloc.price,
         style     = label.style_label_down,
         color     = rankColour(rankH),
         textcolor = cMarkText,
         size      = rankSize(rankH))

if showMarks and judged and rankL >= minRank
    label.new(sBar, pxLow, showRankText ? str.tostring(rankL) : "",
         yloc      = yloc.price,
         style     = label.style_label_up,
         color     = rankColour(rankL),
         textcolor = cMarkText,
         size      = rankSize(rankL))


// ═════════════════════════════════════════════════════════════════════════════
//  STRUCTURE LINE
//
//  Alternating high/low skeleton at one chosen depth. When two consecutive
//  nodes point the same way, the more extreme one replaces the other and the
//  open segment is stretched to it; a node in the opposite direction closes the
//  segment permanently. If a bar qualifies as both a high and a low, the deeper
//  of the two is used, so a node is never placed twice on one bar.
// ═════════════════════════════════════════════════════════════════════════════

var int   anchorBar = na
var float anchorPx  = na
var int   anchorDir = 0
var line  openSeg   = na

bool nodeH = showZig and judged and rankH >= zigRank and rankH >= rankL
bool nodeL = showZig and judged and rankL >= zigRank and rankL > rankH

if nodeH
    if anchorDir == 0
        anchorBar := sBar
        anchorPx  := pxHigh
        anchorDir := 1
    else if anchorDir == 1
        if pxHigh >= anchorPx
            anchorBar := sBar
            anchorPx  := pxHigh
            if not na(openSeg)
                line.set_xy2(openSeg, anchorBar, anchorPx)
    else
        openSeg   := line.new(anchorBar, anchorPx, sBar, pxHigh, color = cZig, width = zigWidth)
        anchorBar := sBar
        anchorPx  := pxHigh
        anchorDir := 1

if nodeL
    if anchorDir == 0
        anchorBar := sBar
        anchorPx  := pxLow
        anchorDir := -1
    else if anchorDir == -1
        if pxLow <= anchorPx
            anchorBar := sBar
            anchorPx  := pxLow
            if not na(openSeg)
                line.set_xy2(openSeg, anchorBar, anchorPx)
    else
        openSeg   := line.new(anchorBar, anchorPx, sBar, pxLow, color = cZig, width = zigWidth)
        anchorBar := sBar
        anchorPx  := pxLow
        anchorDir := -1


// ═════════════════════════════════════════════════════════════════════════════
//  UNDECIDED REGION
// ═════════════════════════════════════════════════════════════════════════════

bgcolor(showProv and bar_index > last_bar_index - lag ? cProv : color(na),
     title = "Undecided region")


// ═════════════════════════════════════════════════════════════════════════════
//  HIGHER-TIMEFRAME REFERENCE
//
//  One bundled request per timeframe. Both levels are returned by a single
//  helper so only one request.security() call is spent. lookahead is ON, paired
//  with a [1] offset on each value inside the helper, so what arrives on the chart
//  is the state of the higher timeframe as of its previous, already closed bar.
//  Historical and realtime bars therefore receive the same value, and it cannot
//  change while the higher-timeframe bar is still forming.
// ═════════════════════════════════════════════════════════════════════════════

// @function   Last confirmed swing high and low of the timeframe it is run on.
// @param d    Pivot width in bars of that timeframe.
// @returns    [swing high price, swing low price], each offset one bar back.
htfSwings(simple int d) =>
    float rawH = ta.pivothigh(high, d, d)
    float rawL = ta.pivotlow(low, d, d)
    var float lastH = na
    var float lastL = na
    if not na(rawH)
        lastH := rawH
    if not na(rawL)
        lastL := rawL
    [lastH[1], lastL[1]]

[htfHigh, htfLow] = request.security(syminfo.tickerid, htfTf, htfSwings(htfDepth),
     lookahead = barmerge.lookahead_on)

plot(showHtf ? htfHigh : na, "HTF swing high", color = cHtfHigh, style = plot.style_linebr)
plot(showHtf ? htfLow  : na, "HTF swing low",  color = cHtfLow,  style = plot.style_linebr)


// ═════════════════════════════════════════════════════════════════════════════
//  SURVIVAL TABLE
// ═════════════════════════════════════════════════════════════════════════════

var array<int> counts    = array.new<int>(5, 0)
var int        barsRated = 0

// @function     Adds this bar's verdicts to one depth slot's running count.
// @param a      The counter array, mutated in place.
// @param i      Slot index, 0 to 4.
// @param en     Whether the slot is active.
// @param d      The slot's width.
// @param rH     Persistence depth of the swing high, 0 if none.
// @param rL     Persistence depth of the swing low, 0 if none.
// @returns      void
tally(array<int> a, int i, bool en, int d, int rH, int rL) =>
    int add = (en and rH >= d ? 1 : 0) + (en and rL >= d ? 1 : 0)
    array.set(a, i, array.get(a, i) + add)

if judged
    barsRated := barsRated + 1
    tally(counts, 0, en1, d1, rankH, rankL)
    tally(counts, 1, en2, d2, rankH, rankL)
    tally(counts, 2, en3, d3, rankH, rankL)
    tally(counts, 3, en4, d4, rankH, rankL)
    tally(counts, 4, en5, d5, rankH, rankL)

// @function   Maps the position input to a table position constant.
// @param s    The selected option string.
// @returns    A position constant.
tablePos(simple string s) =>
    switch s
        "Top left"      => position.top_left
        "Bottom right"  => position.bottom_right
        "Bottom left"   => position.bottom_left
        "Middle right"  => position.middle_right
        => position.top_right

var table tab = table.new(tablePos(tabPos), 4, 7, border_width = 1)

if showTable and barstate.islast
    table.clear(tab, 0, 0, 3, 6)

    table.cell(tab, 0, 0, "Depth",   text_color = cTabText, bgcolor = cTabBg, text_size = size.small)
    table.cell(tab, 1, 0, "Swings",  text_color = cTabText, bgcolor = cTabBg, text_size = size.small)
    table.cell(tab, 2, 0, "Kept",    text_color = cTabText, bgcolor = cTabBg, text_size = size.small)
    table.cell(tab, 3, 0, "Bars ea", text_color = cTabText, bgcolor = cTabBg, text_size = size.small)

    int prev = 0
    for i = 0 to 4
        int d = switch i
            0 => d1
            1 => d2
            2 => d3
            3 => d4
            => d5
        if i < nDepths
            int c = array.get(counts, i)
            string kept    = i == 0 or prev == 0 ? "-" : str.tostring(100.0 * c / prev, "#.#") + "%"
            string spacing = c == 0 ? "-" : str.tostring(barsRated * 1.0 / c, "#.#")
            table.cell(tab, 0, i + 1, str.tostring(d), text_color = cTabText, bgcolor = cTabBg, text_size = size.small)
            table.cell(tab, 1, i + 1, str.tostring(c), text_color = cTabText, bgcolor = cTabBg, text_size = size.small)
            table.cell(tab, 2, i + 1, kept,            text_color = cTabText, bgcolor = cTabBg, text_size = size.small)
            table.cell(tab, 3, i + 1, spacing,         text_color = cTabText, bgcolor = cTabBg, text_size = size.small)
            prev := c

    table.cell(tab, 0, 6, "Undecided", text_color = cTabText, bgcolor = cTabBg, text_size = size.tiny)
    table.cell(tab, 1, 6, str.tostring(lag) + " bars", text_color = cTabText, bgcolor = cTabBg, text_size = size.tiny)
    table.cell(tab, 2, 6, "Rated", text_color = cTabText, bgcolor = cTabBg, text_size = size.tiny)
    table.cell(tab, 3, 6, str.tostring(barsRated), text_color = cTabText, bgcolor = cTabBg, text_size = size.tiny)


// ═════════════════════════════════════════════════════════════════════════════
//  DATA WINDOW AND ALERTS
//
//  The three values below describe the bar the current verdict refers to, not
//  the bar the cursor is on. "Swing bar index" names that bar explicitly so the
//  offset is never left to guesswork.
// ═════════════════════════════════════════════════════════════════════════════

plot(rankH, "Swing high depth", color = color.new(cDeep, 100), display = display.data_window)
plot(rankL, "Swing low depth",  color = color.new(cDeep, 100), display = display.data_window)
plot(sBar,  "Swing bar index",  color = color.new(cDeep, 100), display = display.data_window)

alertcondition(judged and rankH >= alertRank, "Persistent swing high",
     "Swing Persistence Profile: a swing high reached the alert depth. It formed on the bar the confirmation lag places it on, not on this bar.")

alertcondition(judged and rankL >= alertRank, "Persistent swing low",
     "Swing Persistence Profile: a swing low reached the alert depth. It formed on the bar the confirmation lag places it on, not on this bar.")
````
