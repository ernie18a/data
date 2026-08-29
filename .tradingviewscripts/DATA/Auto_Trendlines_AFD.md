<!-- tradingview-pine-id: PUB;ef547c02fe9747a9bbc2e44d0927cb6d -->
<!-- tradingviewscripts-format: 1 -->
# Auto Trendlines [AFD]

Source: https://www.tradingview.com/script/S5pOkiQ5-Auto-Trendlines-AFD/

## Description

Traders! 
[image]https://www.tradingview.com/x/prdkvDe4/[/image]
If this draws fewer lines than the last auto-trendline script you tried, that is not a bug. 

Almost every free entrant in this category will connect any two points and call the result a trendline, including points price has already traded straight through. This one will not draw that line at all.

WHAT IT DOES

Two confirmed same-side pivots define a diagonal line - two swing highs for a descending line, two swing lows for an ascending one. Before it is drawn, the pair has to pass four checks, all required:

[*]Same side. Never one high paired with one low.
[*]Progressive. The second pivot has to be lower than the first on a descending line, higher on an ascending one.
[*]No pierce. No bar between the two anchors may have traded through the line.
[*]Still intact now. No bar since the second anchor may have violated it either.

The third check is the one almost everyone in this category skips, and the fourth closes the gap right behind it - a pivot needs time to confirm, so without the fourth check a line could pass the first three and still be dead on arrival, already traded through in the bars since its own anchor. Of every pair that clears all four, the one nearest current price is the one drawn.

It keeps three lines per side by default - one at your Swing Strength setting, and two more at longer multiples of it - so a short, a medium and a long trendline can all be live on the same side at once, each resting on a different swing rather than three readings of the same one.

HOW A LINE LIVES AND DIES

A live line is maintained, not redrawn - its right edge follows price, and its label counts how many bars have touched it within your tolerance. It is retired, dimmed and kept on the chart, never silently deleted, for exactly one of two reasons: price violated it, or its anchor aged past your Bars to Apply setting. A retired line's colour, width and style are yours to set - the defaults reproduce a plain grey dotted line, but a violated line and an aged-out line both use the same styling, because both are "no longer live" and neither claims anything about what happens next.

When a side has nothing to show, an optional note names the refusal directly instead of leaving a blank chart that reads as broken - something like "No valid ascending line - recent pivot pairs failed the validity rule." It disappears the moment a line forms on that side.

THE TWO ALERTS

One alert per side, on one event: a line was violated and retired, on the bar that just closed. That is the whole alert surface.

[*]It does not fire on a developing bar - only once a bar closes.
[*]It does not fire when a line is retired for age. An aged line was not violated, and an alert saying it was would be a false statement about your chart.
[*]It does not tell you what to do next. It names the event and points at the settings that produced it.
[*]There is no alert for a line forming, for a touch, or for price approaching a line.

SETTINGS WORTH KNOWING FIRST
[image]https://www.tradingview.com/x/7mbOAE99/[/image]
Swing Strength sets how many bars either side of a pivot must confirm it - higher means steadier, later pivots; lower means more of them, sooner and noisier. Pivots Searched sets how many recent pivots each length keeps in its pool to test pairs from. Pierce Tolerance and Touch Tolerance are both a multiple of ATR: Pierce is how far price may travel through a line before it counts as pierced or violated, and Touch is the separate band used only for counting touches. Bars to Apply bounds how old a line's anchor may get before it ages out - 0 means no limit.

[image]https://www.tradingview.com/x/PkEVM0qA/[/image]
Minimum Touches is worth reading twice, because it does not do what it sounds like. Requiring touches before a line can be drawn does not find a better line - it defers the same line's appearance into a later, shorter-lived part of its own life, since touches accrue before the line is drawn, not after. What it actually buys is recency: the lines that survive it are the ones price is currently working on.

Label position offers "Right of line" (default, floats along the line's own slope) or "Below, centered" (sits directly under the line's tip). Either way the label is a plain box with no pointer.

WHAT IT WILL NOT DO

It is not a signal tool. It does not grade a line's strength, does not rank one line against another, and does not name a target, a breakout, or a bounce - each of those is a claim about the bar after the one that just closed, and this script has no view on that. A touch count is a count of what already happened, shown with the tolerance that produced it, nothing more.

WHAT IS DISCLOSED RATHER THAN HIDDEN

A line appears late by design - its anchors are confirmed pivots, so a line shows up Swing Strength bars after the bar that anchors it. That lag is the price of not drawing lines that vanish a bar later.

Whether this script repaints has not been observed on a replay and is not claimed here either way. Its behaviour on a logarithmic price scale is likewise unobserved and unclaimed.

Zero request.*() calls of any kind - every calculation reads the chart's own series.

Open source under the Mozilla Public License 2.0.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry

//@version=6

// Auto Trendlines [AFD]
//
// Draws diagonal trendlines from confirmed swing pivots. A line is only drawn if it passes a
// four-part validity rule, and once drawn it is held rather than redrawn every bar:
//   1. Same side    - both anchors are swing highs (descending) or both are swing lows
//                     (ascending). Never one of each.
//   2. Progressive   - the second anchor must be lower than the first on a descending line,
//                     higher on an ascending one. Flat is not a trend.
//   3. No pierce     - no bar between the two anchors may have traded through the connecting
//                     line. A line the market already broke through is not support.
//   4. Still intact  - no bar since the second anchor may have violated the line either.
//
// Each line's label shows how many bars have touched it, at the tolerance in use. A violated
// line is dimmed and kept on screen rather than deleted, so history of the break stays visible.
// The script does not score, rank, or grade a line, name a target, or say anything about what
// price will do next.
//
// Lines appear late by design: an anchor is a confirmed pivot, so a line becomes drawable only
// Swing Strength bars after the bar that anchors it. That lag is the cost of not drawing lines
// that later disappear.
//
// Three independent lengths run per side - short, medium and long swing - each with its own
// pivot search, so the three lines rest on genuinely different pivots rather than near-copies
// of one line. Six lines maximum are ever live at once.
indicator(title = "Auto Trendlines [AFD]", shorttitle = "ATLN [AFD]", overlay = true, max_lines_count = 100, max_labels_count = 50, max_bars_back = 5000)

// ══════════════════════════════════════════════════════════════════════════════
// Constant declarations
// ══════════════════════════════════════════════════════════════════════════════

string BASIS_WICK  = "Wick through"
string BASIS_CLOSE = "Close through"

string ANCHOR_WICK = "Wick"
string ANCHOR_BODY = "Body"

// Where the touch-count label sits relative to its line's own right end.
string LABEL_POS_RIGHT = "Right of line"
string LABEL_POS_BELOW = "Below, centered"

// The three line styles offered for an already-broken (retired) line.
string STYLE_SOLID  = "Solid"
string STYLE_DASHED = "Dashed"
string STYLE_DOTTED = "Dotted"

// How far back a drawn endpoint may sit. A drawing placed with `xloc.bar_index` can only reach
// 10,000 bars into the past before the runtime stops the script entirely, and a line that is
// never violated has no age limit, so a long-lived one will eventually reach that edge. This
// stays comfortably below that ceiling.
int DRAW_BACK_LIMIT = 9500

// How far past a line's own drawn tip its touch-count label floats, in bars, so the label box
// clears the line's own stroke instead of sitting on top of it.
int LABEL_LEAD_BARS = 6

// How far, in multiples of ATR, the "Below, centered" label position and the empty-state note
// both sit from the price they describe.
float LABEL_DROP_ATR = 1.0

// Slot layout for the six live lines. Slots 0-2 are the descending side, short to long; slots
// 3-5 are the ascending side in the same order, so `slot < 3` is the side and `slot % 3` is the
// tier.
int SLOT_COUNT = 6
int SIDE_SPAN  = 3
int TIER_SHORT = 0
int TIER_MID   = 1
int TIER_LONG  = 2

string GRP_DETECT  = "📐 Detection"
string GRP_LIFE    = "📊 Lifecycle"
string GRP_DISPLAY = "🎨 Display"

string TIP_SWING = "How many bars on each side a swing point must stand above.\n• Higher = steadier pivots, but lines appear later.\n• Lower = more pivots, but noisier and less reliable."
string TIP_POOL = "How many recent confirmed pivots the line search can pick from, per side.\n• Higher = more pairs considered, but slower to compute.\n• Lower = fewer pairs considered, faster but may miss a valid line."
string TIP_PIERCE = "How far a bar between the two anchors may trade through the line before it's rejected, in multiples of ATR.\n• Higher = more piercing allowed, so more pairs qualify.\n• Lower = stricter; 0 means a single tick through disqualifies it."
string TIP_TOUCH = "How close a bar must come to a live line to count as a touch, in multiples of ATR.\n• Higher = counts touches from farther away on either side of the line.\n• Lower = only bars very close to the line count.\n• A band, not a one-sided floor - the label's count always shows this number alongside it."
string TIP_BASIS = "What counts as breaking a live line.\n• Wick through - any trade beyond the line ends it.\n• Close through - waits for a confirmed close beyond the line."
string TIP_VTOL = "How far price must move beyond a live line before it's retired, in multiples of ATR.\n• Higher = the line survives deeper moves against it before retiring.\n• Lower = retires sooner; 0 means any move past the line ends it."
string TIP_RETIRE = "How many broken lines stay visible behind the live one.\n• Higher = more retired history stays on screen.\n• Lower = less; 0 hides retired lines completely."
string TIP_ATR = "Bar count for the average true range that scales every tolerance above.\n• Higher = smoother, slower-changing tolerance.\n• Lower = more reactive to recent volatility.\n• Uses a simple mean of true range, not Wilder's smoothing."
string TIP_GLOW = "Draws each live line twice - a soft, wide halo under a narrower core line."
string TIP_RAMP = "Shades a live line more solid the more bars touch it.\n• Reflects an observed count only, not a rating of the line."
string TIP_HORIZON = "How far back a line's anchor may sit before it ages out.\n• Higher = anchors and lines can persist longer.\n• Lower = lines age out sooner.\n• 0 = no age limit."
string TIP_SPAN = "The fewest bars the two anchors may sit apart.\n• Higher = requires longer, more established pairs; fewer qualify.\n• Lower = allows steeper, shorter-span lines.\n• 0 = no minimum."
string TIP_ANCHOR = "What price an anchor is pinned to - the pivot bar's wick tip, or the top/bottom of its body.\n• Pivots are always detected on wicks; this only changes where the line is drawn through.\n• Pair Body with Close through - Body with Wick through tends to get retired by the very next wick."
string TIP_TOUCHES = "How many bars must already have touched a pair before it can be drawn at all.\n• Higher = fewer lines, each appearing later and staying visible for less time.\n• Lower = more lines, appearing sooner.\n• 0 = no requirement."
string TIP_FILL = "Shades the gap between the shortest and longest line on the same side, when both are drawn.\n• Marks the space between two drawn lines only - not a level, zone, or signal."
string TIP_TIERS = "Holds three lines per side instead of one - short, medium and long swing lengths, each searching its own pivots.\n• Every line still passes the same four-part validity rule.\n• Longer lines are drawn thicker."
string TIP_MIDMULT = "Swing strength of the medium line, as a multiple of Swing Strength above.\n• Higher = a longer, steadier medium line.\n• Lower = closer in length to the short line."
string TIP_LONGMULT = "Swing strength of the long line, as a multiple of Swing Strength above.\n• Higher = a longer, rarer line that changes least often.\n• Lower = closer in length to the medium line, but needs a high enough Bars to Apply to find pivots at all."
string TIP_LABELPOS = "Where the touch-count label sits relative to the line's own right end.\n• Right of line - continues along the line's own slope.\n• Below, centered - sits directly under the tip, regardless of slope."
string TIP_EMPTY = "Shows a small note when a side has no live line at all, across all three lengths.\n• Disappears the moment a line forms.\n• Never appears on a side that is switched off."
string TIP_BROKEN = "Colour, width and style of a line once it's retired (violated or aged out).\n• A retired line never updates again - these are what set it apart from a live one at a glance."

// ══════════════════════════════════════════════════════════════════════════════
// Inputs
// ══════════════════════════════════════════════════════════════════════════════

// Every non-boolean, non-colour input below carries `display = display.data_window`, so its
// value stays fully visible in the Settings dialog and the Data window without repeating it in
// the chart's status line.
int swingInput = input.int(10, "Swing Strength", minval = 1, maxval = 50, group = GRP_DETECT, tooltip = TIP_SWING, display = display.data_window)
int poolInput = input.int(10, "Pivots Searched", minval = 2, maxval = 12, group = GRP_DETECT, tooltip = TIP_POOL, display = display.data_window)
float pierceInput = input.float(0.25, "Pierce Tolerance (× ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = GRP_DETECT, tooltip = TIP_PIERCE, display = display.data_window)
int atrLenInput = input.int(14, "ATR Length", minval = 1, maxval = 200, group = GRP_DETECT, tooltip = TIP_ATR, display = display.data_window)

string basisInput = input.string(BASIS_WICK, "Violated By", options = [BASIS_WICK, BASIS_CLOSE], group = GRP_LIFE, tooltip = TIP_BASIS, display = display.data_window)
float violateInput = input.float(0.0, "Violation Tolerance (× ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = GRP_LIFE, tooltip = TIP_VTOL, display = display.data_window)
float touchInput = input.float(0.25, "Touch Tolerance (× ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = GRP_LIFE, tooltip = TIP_TOUCH, display = display.data_window)
// Keeping more retired lines only changes how much broken-line history stays visible - it does
// not affect detection or which lines are considered valid.
int retireInput = input.int(5, "Retired Lines Kept", minval = 0, maxval = 10, group = GRP_LIFE, tooltip = TIP_RETIRE, display = display.data_window)

// `active =` is only ever given a single boolean here, never a compound condition - a compound
// condition risks leaving a control permanently dimmed if it is not re-evaluated correctly.
bool showFallingInput = input.bool(true, "Descending lines", group = GRP_DISPLAY)
bool showRisingInput = input.bool(true, "Ascending lines", group = GRP_DISPLAY)
// Saturated red/green rather than the chart's own candle colours, so the lines don't blend into
// the candles behind them.
color fallingColorInput = input.color(color.new(#ff1744, 0), "Descending", group = GRP_DISPLAY, inline = "col", active = showFallingInput)
color risingColorInput = input.color(color.new(#00e676, 0), "Ascending", group = GRP_DISPLAY, inline = "col", active = showRisingInput)
// Retired lines fall back to width 1 regardless of this setting, so a live line stays visually
// distinct from a retired one.
int widthInput = input.int(3, "Line width", minval = 1, maxval = 5, group = GRP_DISPLAY, display = display.data_window)
bool extendInput = input.bool(true, "Extend to the right", group = GRP_DISPLAY)
bool rampInput = input.bool(true, "Colour by touch count", group = GRP_DISPLAY, tooltip = TIP_RAMP)
// Draws one extra line object per live line for the halo effect.
bool glowInput = input.bool(true, "Glow", group = GRP_DISPLAY, tooltip = TIP_GLOW)
bool showLabelInput = input.bool(true, "Show touch count", group = GRP_DISPLAY)
string labelPosInput = input.string(LABEL_POS_RIGHT, "Label position", options = [LABEL_POS_RIGHT, LABEL_POS_BELOW], group = GRP_DISPLAY, tooltip = TIP_LABELPOS, active = showLabelInput, display = display.data_window)
bool fillInput = input.bool(true, "Shade between the lengths", group = GRP_DISPLAY, tooltip = TIP_FILL)

int horizonInput = input.int(300, "Bars to Apply", minval = 0, maxval = 5000, group = GRP_DETECT, tooltip = TIP_HORIZON, display = display.data_window)

int spanInput = input.int(0, "Minimum Anchor Span", minval = 0, maxval = 200, group = GRP_DETECT, tooltip = TIP_SPAN, display = display.data_window)
string anchorInput = input.string(ANCHOR_WICK, "Anchor Price", options = [ANCHOR_WICK, ANCHOR_BODY], group = GRP_DETECT, tooltip = TIP_ANCHOR, display = display.data_window)

// Counterintuitively, requiring touches does not select longer-lived lines - it selects
// shorter-lived ones, since those touches accumulate before the line is even drawn.
int minTouchInput = input.int(0, "Minimum Touches", minval = 0, maxval = 10, group = GRP_DETECT, tooltip = TIP_TOUCHES, display = display.data_window)

bool tiersInput = input.bool(true, "Three lengths per side", group = GRP_DETECT, tooltip = TIP_TIERS)
int midMultInput = input.int(2, "Medium length multiple", minval = 2, maxval = 10, group = GRP_DETECT, tooltip = TIP_MIDMULT, active = tiersInput, display = display.data_window)
int longMultInput = input.int(4, "Long length multiple", minval = 2, maxval = 20, group = GRP_DETECT, tooltip = TIP_LONGMULT, active = tiersInput, display = display.data_window)

// Answers "why is nothing showing" directly on the chart: a side with zero live lines gets a
// small note explaining the refusal, instead of just looking broken.
bool showEmptyNoteInput = input.bool(true, "Note when no valid line", group = GRP_DISPLAY, tooltip = TIP_EMPTY)

// A retired line's colour, width and style are the only thing that distinguishes it from a
// live one, since it is otherwise unmarked.
color brokenColorInput = input.color(color.new(color.gray, 45), "Broken line", group = GRP_DISPLAY, inline = "broken", tooltip = TIP_BROKEN)
int brokenWidthInput = input.int(1, "Width", minval = 1, maxval = 5, group = GRP_DISPLAY, inline = "broken", display = display.data_window)
string brokenStyleInput = input.string(STYLE_DOTTED, "Style", options = [STYLE_SOLID, STYLE_DASHED, STYLE_DOTTED], group = GRP_DISPLAY, inline = "broken", display = display.data_window)

// ══════════════════════════════════════════════════════════════════════════════
// Functions
// ══════════════════════════════════════════════════════════════════════════════

// Shifts a colour's existing transparency rather than replacing it - `color.new()` alone would
// discard whatever alpha the user picked in the colour dialog.
shiftTransparency(color src, int add) =>
    int a = math.min(100, math.max(0, int(color.t(src)) + add))
    color.new(src, a)

// True range calculated directly rather than via `ta.tr()`, so the average below can be a
// simple mean rather than `ta.atr()`'s Wilder smoothing - the two are different statistics.
trueRangeAt(int barsBack) =>
    float result = 0.0
    if barsBack >= bar_index
        result := high[barsBack] - low[barsBack]
    else
        float prevClose = close[barsBack + 1]
        float a = high[barsBack] - low[barsBack]
        float b = math.abs(high[barsBack] - prevClose)
        float c = math.abs(low[barsBack] - prevClose)
        result := math.max(a, math.max(b, c))
    result

// Simple mean of true range over the last `len` bars, clamped at the start of the chart.
meanTrueRange(int len) =>
    int span = math.min(len, bar_index + 1)
    float total = 0.0
    if span > 0
        for i = 0 to span - 1
            total += trueRangeAt(i)
    span > 0 ? total / span : 0.0

// A line's price at bar `b`. `(b - b1)` and `(b2 - b1)` are integer subtractions, and Pine
// divides two integers as integers - the `* 1.0` forces floating-point division so the line
// doesn't collapse onto one endpoint.
linePriceAt(int b1, float p1, int b2, float p2, int b) =>
    int span = b2 - b1
    p1 + (p2 - p1) * ((b - b1) * 1.0 / span)

// Validity rule 3 - no-pierce. Checks every bar strictly between the two anchors for a trade
// through the line by more than `tol`. The `b2 - b1 > 1` guard matters: Pine's `for i = a to b`
// counts downward when `a > b` instead of skipping the loop, so adjacent anchors would scan
// backwards without it.
piercedBetween(int b1, float p1, int b2, float p2, bool isHigh, float tol) =>
    bool pierced = false
    if b2 - b1 > 1
        for b = b1 + 1 to b2 - 1
            float lp = linePriceAt(b1, p1, b2, p2, b)
            int back = bar_index - b
            if isHigh
                if high[back] > lp + tol
                    pierced := true
                    break
            else
                if low[back] < lp - tol
                    pierced := true
                    break
    pierced

// Does one bar violate the line? Bars at or before the second anchor never do - that range
// belongs to the no-pierce rule.
violatesAt(int b1, float p1, int b2, float p2, bool isHigh, int b, float vtol, bool useWick) =>
    bool result = false
    if b > b2
        float lp = linePriceAt(b1, p1, b2, p2, b)
        int back = bar_index - b
        if isHigh
            float v = useWick ? high[back] : close[back]
            result := v > lp + vtol
        else
            float v = useWick ? low[back] : close[back]
            result := v < lp - vtol
    result

// Validity rule 4. Has anything since the second anchor already broken this line? Same
// downward-counting guard as above.
violatedSince(int b1, float p1, int b2, float p2, bool isHigh, int upto, float vtol, bool useWick) =>
    bool violated = false
    if upto > b2
        for b = b2 + 1 to upto
            if violatesAt(b1, p1, b2, p2, isHigh, b, vtol, useWick)
                violated := true
                break
    violated

// Is bar `b` a touch? Penetration is signed and side-aware, so one comparison works for both
// sides: positive means through the line, negative means short of it.
//
// This is a band, not a one-sided floor: a bar that traded far beyond the line by more than the
// tolerance does not count as a touch, even though it came close enough on approach - only bars
// that land within the tolerance on either side of the line are touches.
isTouch(int b1, float p1, int b2, float p2, bool isHigh, int b, float ttol) =>
    float lp = linePriceAt(b1, p1, b2, p2, b)
    int back = bar_index - b
    float pen = isHigh ? high[back] - lp : lp - low[back]
    pen >= -ttol and pen <= ttol

// Counts the touches a line has accumulated between its second anchor and now. A line only
// becomes drawable once its second anchor confirms, so that stretch has already happened and
// skipping it would under-report the count on the bar a line first appears.
touchesSoFar(int b1, float p1, int b2, float p2, bool isHigh, float ttol) =>
    int n = 0
    if bar_index > b2
        for b = b2 + 1 to bar_index
            if isTouch(b1, p1, b2, p2, isHigh, b, ttol)
                n += 1
    n

// The anchor's drawn price, read from the bar the pivot sits on. Detection always reads the
// wick; this only changes the price the line is drawn through, between the wick and the body.
anchorPriceFor(int barsBack, bool isHigh, float wickPrice, bool useWickAnchor) =>
    float result = wickPrice
    if not useWickAnchor
        result := isHigh ? math.max(open[barsBack], close[barsBack]) : math.min(open[barsBack], close[barsBack])
    result

// One pool's per-bar maintenance: add a newly confirmed pivot, trim the pool to its searched
// size, then drop anything older than the horizon.
//
// The trim is a single `if` because at most one pivot confirms per bar per pool, so one shift
// always suffices. The horizon is a `while` because how many anchors cross it on a given bar
// depends on the horizon and how the pivots happen to be spaced.
addPivot(array<int> pBars, array<float> pPrices, float pivotPrice, int barsBack, bool isHigh, bool useWickAnchor, int poolMax, int horizon) =>
    if not na(pivotPrice)
        array.push(pBars, bar_index - barsBack)
        array.push(pPrices, anchorPriceFor(barsBack, isHigh, pivotPrice, useWickAnchor))
    if array.size(pBars) > poolMax
        array.shift(pBars)
        array.shift(pPrices)
    if horizon > 0
        while array.size(pBars) > 0 and bar_index - array.get(pBars, 0) > horizon
            array.shift(pBars)
            array.shift(pPrices)

// ══════════════════════════════════════════════════════════════════════════════
// Calculations
// ══════════════════════════════════════════════════════════════════════════════

bool useWick = basisInput == BASIS_WICK

float atrNow = meanTrueRange(atrLenInput)
float pierceTol = pierceInput * atrNow
float violateTol = violateInput * atrNow
float touchTol = touchInput * atrNow

// Confirmed pivots, most recent last, bounded to the searched pool - six pools, one per tier per
// side. Written as twelve parallel arrays rather than nested arrays, since Pine arrays cannot
// hold other arrays.
var array<int> hiBarsShort = array.new<int>()
var array<float> hiPricesShort = array.new<float>()
var array<int> hiBarsMid = array.new<int>()
var array<float> hiPricesMid = array.new<float>()
var array<int> hiBarsLong = array.new<int>()
var array<float> hiPricesLong = array.new<float>()

var array<int> loBarsShort = array.new<int>()
var array<float> loPricesShort = array.new<float>()
var array<int> loBarsMid = array.new<int>()
var array<float> loPricesMid = array.new<float>()
var array<int> loBarsLong = array.new<int>()
var array<float> loPricesLong = array.new<float>()

// The three swing lengths, capped at 200 - a pivot needs that many bars either side to confirm
// at all. Bars to Apply is not scaled per tier: a longer swing simply finds fewer pivots inside
// the same window, rather than searching a wider one.
bool anchorWick = anchorInput == ANCHOR_WICK
int shortLen = swingInput
int midLen = math.min(200, swingInput * midMultInput)
int longLen = math.min(200, swingInput * longMultInput)

// `ta.pivothigh(n, n)` returns a value on the bar that confirms the pivot, n bars after the
// pivot itself. All six calls are unconditional and in the global scope, because skipping a
// `ta.*` call on some bars would leave it with a broken history from that point on - so the
// tier toggle below controls what is drawn, never what is detected.
//
// Pivot detection always reads the wick, never the body, at every tier: on gapless data a bar's
// body always shares an endpoint with its neighbour's, so a body has no strict local maximum and
// pivot detection on bodies would essentially never fire.
float pivotHighShort = ta.pivothigh(shortLen, shortLen)
float pivotLowShort = ta.pivotlow(shortLen, shortLen)
float pivotHighMid = ta.pivothigh(midLen, midLen)
float pivotLowMid = ta.pivotlow(midLen, midLen)
float pivotHighLong = ta.pivothigh(longLen, longLen)
float pivotLowLong = ta.pivotlow(longLen, longLen)

addPivot(hiBarsShort, hiPricesShort, pivotHighShort, shortLen, true, anchorWick, poolInput, horizonInput)
addPivot(hiBarsMid, hiPricesMid, pivotHighMid, midLen, true, anchorWick, poolInput, horizonInput)
addPivot(hiBarsLong, hiPricesLong, pivotHighLong, longLen, true, anchorWick, poolInput, horizonInput)
addPivot(loBarsShort, loPricesShort, pivotLowShort, shortLen, false, anchorWick, poolInput, horizonInput)
addPivot(loBarsMid, loPricesMid, pivotLowMid, midLen, false, anchorWick, poolInput, horizonInput)
addPivot(loBarsLong, loPricesLong, pivotLowLong, longLen, false, anchorWick, poolInput, horizonInput)

// Among every pair that passes all four validity conditions, picks the one nearest the current
// close rather than the first one the scan reaches - a valid pair can still sit far from
// current price, which is technically correct but not useful to look at.
//
// Every qualifying pair gets compared rather than the scan stopping at the first match, so this
// does more work on average than a first-match scan, though the worst case (nothing qualifies)
// is unchanged.
//
// The minimum-touch check runs last, since it is the only one of these tests that has to walk
// bar-by-bar from the second anchor to now - the cheap integer checks run first so that scan
// only ever runs on a pair that already passed everything else.
//
// The last four arguments exclude pairs another tier on the same side is already holding, so a
// tier won't adopt the exact same anchor pair as its neighbour - without this, two tiers can
// easily pick the same pivots and draw the same line twice under two different tier labels.
//
// `-1` means "no pair to exclude" and can never collide with a real bar index.
selectAnchors(array<int> pBars, array<float> pPrices, bool isHigh, float tol, float vtol, bool useWickArg, int minSpan, int minTouches, float ttol, int exB1a, int exB2a, int exB1b, int exB2b) =>
    int outB1 = -1
    float outP1 = 0.0
    int outB2 = -1
    float outP2 = 0.0
    bool found = false
    float bestDist = 0.0
    int n = array.size(pBars)
    if n >= 2
        for a = n - 1 to 1
            for b = a - 1 to 0
                int b1 = array.get(pBars, b)
                float p1 = array.get(pPrices, b)
                int b2 = array.get(pBars, a)
                float p2 = array.get(pPrices, a)
                bool progressive = isHigh ? p2 < p1 : p2 > p1
                // Tested before the pierce/violation scans, since this is a cheap integer
                // comparison and those scans are not.
                bool spans = minSpan <= 0 or b2 - b1 >= minSpan
                // Also tested before the scans, for the same reason - a cheap integer comparison
                // that can skip a pair before any bar-by-bar work runs.
                bool taken = (b1 == exB1a and b2 == exB2a) or (b1 == exB1b and b2 == exB2b)
                if progressive and spans and not taken
                    if not piercedBetween(b1, p1, b2, p2, isHigh, tol)
                        if not violatedSince(b1, p1, b2, p2, isHigh, bar_index, vtol, useWickArg)
                            bool touched = minTouches <= 0 or touchesSoFar(b1, p1, b2, p2, isHigh, ttol) >= minTouches
                            if touched
                                float d = math.abs(linePriceAt(b1, p1, b2, p2, bar_index) - close)
                                if not found or d < bestDist
                                    outB1 := b1
                                    outP1 := p1
                                    outB2 := b2
                                    outP2 := p2
                                    bestDist := d
                                    found := true
    [outB1, outP1, outB2, outP2, found]

// Live-line state, one entry per slot, held as parallel arrays rather than a single array of a
// custom type.
var array<int> slotB1 = array.new<int>(SLOT_COUNT, -1)
var array<float> slotP1 = array.new<float>(SLOT_COUNT, 0.0)
var array<int> slotB2 = array.new<int>(SLOT_COUNT, -1)
var array<float> slotP2 = array.new<float>(SLOT_COUNT, 0.0)
var array<int> slotTouches = array.new<int>(SLOT_COUNT, 0)
var array<bool> slotAlive = array.new<bool>(SLOT_COUNT, false)
var array<line> slotLine = array.new<line>(SLOT_COUNT, na)
var array<line> slotGlow = array.new<line>(SLOT_COUNT, na)
var array<label> slotLabel = array.new<label>(SLOT_COUNT, na)

var array<line> retiredLines = array.new<line>()

// A plain top-level ternary rather than a `=>` function - a user-defined function's return
// value is always `series`-qualified in Pine regardless of its inputs, while a plain ternary
// keeps its operands' own qualifier. `line.set_style()` expects no stricter than `series`, so
// the plain form is the safer one.
string brokenStyle = brokenStyleInput == STYLE_SOLID ? line.style_solid : brokenStyleInput == STYLE_DASHED ? line.style_dashed : line.style_dotted

// Retires a line: stops updating it, styles it as broken, and keeps at most `retireInput` of
// them, deleting the oldest once that limit is passed.
retireLine(line ln) =>
    if not na(ln)
        line.set_color(ln, brokenColorInput)
        line.set_width(ln, brokenWidthInput)
        line.set_style(ln, brokenStyle)
        array.push(retiredLines, ln)
    while array.size(retiredLines) > retireInput
        line oldest = array.shift(retiredLines)
        line.delete(oldest)

// Ends a slot's line, however it exits - violated, aged out, or its tier switched off. All three
// end the same way; only whether the line is kept (dimmed) differs. A line switched off by the
// user is deleted rather than retired, since a retired line is meant to be evidence that price
// did something, and a toggle is not price doing something.
clearSlot(int slot, bool keep) =>
    line ln = array.get(slotLine, slot)
    if keep
        retireLine(ln)
    else if not na(ln)
        line.delete(ln)
    line glow = array.get(slotGlow, slot)
    if not na(glow)
        line.delete(glow)
    label lb = array.get(slotLabel, slot)
    if not na(lb)
        label.delete(lb)
    array.set(slotLine, slot, na)
    array.set(slotGlow, slot, na)
    array.set(slotLabel, slot, na)
    array.set(slotAlive, slot, false)

// Fills an empty slot from its own pivot pool, if that pool has a qualifying pair. The validity
// rule itself never changes between tiers - only which pivots are in the pool being searched.
adoptInto(int slot, array<int> pBars, array<float> pPrices, bool isHigh) =>
    if not array.get(slotAlive, slot)
        // The two other slots on this side, whichever tiers they are. Adoption runs short to
        // long, so a longer tier sees the shorter ones as they stand on this bar - which is what
        // makes the exclusion deterministic rather than dependent on who asked first.
        int base = isHigh ? 0 : SIDE_SPAN
        int otherA = base + (slot - base + 1) % SIDE_SPAN
        int otherB = base + (slot - base + 2) % SIDE_SPAN
        int exB1a = array.get(slotAlive, otherA) ? array.get(slotB1, otherA) : -1
        int exB2a = array.get(slotAlive, otherA) ? array.get(slotB2, otherA) : -1
        int exB1b = array.get(slotAlive, otherB) ? array.get(slotB1, otherB) : -1
        int exB2b = array.get(slotAlive, otherB) ? array.get(slotB2, otherB) : -1
        [b1, p1, b2, p2, found] = selectAnchors(pBars, pPrices, isHigh, pierceTol, violateTol, useWick, spanInput, minTouchInput, touchTol, exB1a, exB2a, exB1b, exB2b)
        if found
            array.set(slotB1, slot, b1)
            array.set(slotP1, slot, p1)
            array.set(slotB2, slot, b2)
            array.set(slotP2, slot, p2)
            array.set(slotTouches, slot, touchesSoFar(b1, p1, b2, p2, isHigh, touchTol))
            array.set(slotAlive, slot, true)

// Violation flags read by the two alert conditions at the bottom of the file. Plain series, not
// `var`, so each resets to false every bar and an alert only ever describes the bar it sits on.
// Set inside the `barstate.isconfirmed` block below, which keeps an alert off a developing bar.
bool hiViolatedNow = false
bool loViolatedNow = false

// ── Lifecycle, all six slots ──────────────────────────────────────────────────
//
// The arithmetic here is just the slot layout: `slot < SIDE_SPAN` is the descending side,
// `slot % SIDE_SPAN` is the tier.
if barstate.isconfirmed
    for slot = 0 to SLOT_COUNT - 1
        bool isHigh = slot < SIDE_SPAN
        int tier = slot % SIDE_SPAN
        bool tierOn = tier == TIER_SHORT or tiersInput
        bool sideOn = isHigh ? showFallingInput : showRisingInput
        if array.get(slotAlive, slot)
            int b1 = array.get(slotB1, slot)
            float p1 = array.get(slotP1, slot)
            int b2 = array.get(slotB2, slot)
            float p2 = array.get(slotP2, slot)
            // A line can age out even though it was valid when chosen and was never violated -
            // it simply grew older than the horizon while being held. It is dimmed and kept like
            // any other retired line, so nothing disappears unexplained, but it fires no
            // violation alert, since it was not violated.
            bool violated = violatesAt(b1, p1, b2, p2, isHigh, bar_index, violateTol, useWick)
            bool aged = not violated and horizonInput > 0 and bar_index - b1 > horizonInput
            bool switchedOff = not violated and not aged and not (tierOn and sideOn)
            if violated or aged or switchedOff
                if violated
                    if isHigh
                        hiViolatedNow := true
                    else
                        loViolatedNow := true
                clearSlot(slot, not switchedOff)
            else if isTouch(b1, p1, b2, p2, isHigh, bar_index, touchTol)
                array.set(slotTouches, slot, array.get(slotTouches, slot) + 1)

    // Written out rather than looped, since each slot's pool is its own named array.
    // `adoptInto()` does nothing on a slot that already holds a line, so the tier toggle here is
    // the only thing deciding whether a tier fills.
    if showFallingInput
        adoptInto(0, hiBarsShort, hiPricesShort, true)
        if tiersInput
            adoptInto(1, hiBarsMid, hiPricesMid, true)
            adoptInto(2, hiBarsLong, hiPricesLong, true)
    if showRisingInput
        adoptInto(3, loBarsShort, loPricesShort, false)
        if tiersInput
            adoptInto(4, loBarsMid, loPricesMid, false)
            adoptInto(5, loBarsLong, loPricesLong, false)

// ══════════════════════════════════════════════════════════════════════════════
// Visuals
// ══════════════════════════════════════════════════════════════════════════════

// Longer lines are drawn thicker. This is a length, not a rank - a long-swing line isn't a
// better line, just one built from rarer pivots. Width is the only visual axis left: colour
// already marks the side, and style already marks live versus retired.
tierWidth(int tier) =>
    tier == TIER_LONG ? math.min(5, widthInput + 1) : tier == TIER_MID ? widthInput : math.max(1, widthInput - 1)

tierName(int tier) =>
    tier == TIER_LONG ? "Long" : tier == TIER_MID ? "Mid" : "Short"

// More touches reads more opaque - this encodes an observed count, not a rating. The tier fade
// is a second, smaller axis, and it is zero when tiers are switched off, so a single-line chart
// is unchanged by it.
rampColor(color base, int touches, int tier) =>
    int tierFade = not tiersInput ? 0 : tier == TIER_LONG ? 0 : tier == TIER_MID ? 6 : 12
    int touchFade = rampInput ? 24 - math.min(4, touches) * 6 : 0
    shiftTransparency(base, tierFade + touchFade)

drawTrendline(int b1, float p1, int b2, float p2, int tier, int touches, color base, line existing, line existingGlow, label existingLabel) =>
    int rightBar = extendInput ? bar_index : b2
    float rightPrice = linePriceAt(b1, p1, b2, p2, rightBar)
    // The label's own anchor point. Anchoring it exactly at the line's own tip puts it where the
    // glow-widened stroke passes through it, so "Right of line" floats it `LABEL_LEAD_BARS`
    // further along the same line instead - clear of the stroke without moving anything the
    // label counts. "Below, centered" sits it directly under the line's tip, a fixed
    // `LABEL_DROP_ATR` below, regardless of the line's slope.
    bool labelBelow = labelPosInput == LABEL_POS_BELOW
    int labelBar = labelBelow ? rightBar : rightBar + LABEL_LEAD_BARS
    float labelPrice = labelBelow ? rightPrice - LABEL_DROP_ATR * atrNow : linePriceAt(b1, p1, b2, p2, labelBar)
    // The drawn left endpoint is deliberately not the anchor itself - it's clamped to
    // `DRAW_BACK_LIMIT` bars back so the drawing never exceeds Pine's history window. The
    // clamped point is recomputed on the same line, so the segment stays collinear and nothing
    // about the touch, pierce or violation tests moves - those still read `b1`/`p1` directly.
    int leftBar = math.max(b1, bar_index - DRAW_BACK_LIMIT)
    float leftPrice = linePriceAt(b1, p1, b2, p2, leftBar)
    color shade = rampColor(base, touches, tier)
    int lineWidth = tierWidth(tier)

    line glow = existingGlow
    if glowInput
        // Halo first, so creation order paints the core on top of it.
        if na(glow)
            glow := line.new(leftBar, leftPrice, rightBar, rightPrice, xloc = xloc.bar_index, color = shiftTransparency(base, 70), width = lineWidth + 4)
        else
            line.set_xy1(glow, leftBar, leftPrice)
            line.set_xy2(glow, rightBar, rightPrice)
            line.set_color(glow, shiftTransparency(base, 70))
    else if not na(glow)
        line.delete(glow)
        glow := na

    line ln = existing
    if na(ln)
        ln := line.new(leftBar, leftPrice, rightBar, rightPrice, xloc = xloc.bar_index, color = shade, width = lineWidth, style = line.style_solid)
    else
        line.set_xy1(ln, leftBar, leftPrice)
        line.set_xy2(ln, rightBar, rightPrice)
        line.set_color(ln, shade)
        line.set_width(ln, lineWidth)

    label lb = existingLabel
    if showLabelInput
        // The tier is only named on the label when there's more than one tier - with a single
        // line, "Short" would be labelling a distinction the chart doesn't contain.
        string txt = (tiersInput ? tierName(tier) + " · " : "") + str.tostring(touches) + (touches == 1 ? " touch" : " touches") + " @ " + str.tostring(touchInput, "#.##") + "× ATR"
        if na(lb)
            // A plain centered box with no pointer: `label.style_label_center` centers the
            // rectangle on its anchor point, unlike `label.style_label_down`/`_up`, which each
            // draw a pointer toward the anchor.
            lb := label.new(labelBar, labelPrice, txt, xloc = xloc.bar_index, style = label.style_label_center, color = shiftTransparency(base, 85), textcolor = shade, size = size.small)
        else
            label.set_xy(lb, labelBar, labelPrice)
            label.set_text(lb, txt)
            label.set_color(lb, shiftTransparency(base, 85))
            label.set_textcolor(lb, shade)
    else if not na(lb)
        label.delete(lb)
        lb := na

    [ln, glow, lb]

if barstate.islast or barstate.isconfirmed
    for slot = 0 to SLOT_COUNT - 1
        bool isHigh = slot < SIDE_SPAN
        if array.get(slotAlive, slot) and (isHigh ? showFallingInput : showRisingInput)
            [ln, gl, lb] = drawTrendline(array.get(slotB1, slot), array.get(slotP1, slot), array.get(slotB2, slot), array.get(slotP2, slot), slot % SIDE_SPAN, array.get(slotTouches, slot), isHigh ? fallingColorInput : risingColorInput, array.get(slotLine, slot), array.get(slotGlow, slot), array.get(slotLabel, slot))
            array.set(slotLine, slot, ln)
            array.set(slotGlow, slot, gl)
            array.set(slotLabel, slot, lb)

// ── The band between the short and long line ──────────────────────────────────
//
// One `linefill` per side, spanning the shortest and longest line on that side when both are
// drawn. It's not a zone or a level - it just shades the gap between two lines already drawn.
// Exactly two fills are ever created, one per side, regardless of settings.
//
// A fill is bound to two line IDs, so it follows them for free while `drawTrendline()` moves
// their endpoints - the line's ID doesn't change when its coordinates do. The fill only needs
// rebuilding when a slot's line object itself is replaced, which is tracked by comparing the
// four anchor bar/price values rather than the line IDs directly, since a replaced line always
// carries a different anchor pair.
var linefill hiFill = na
var int hiFillA1 = -1
var int hiFillA2 = -1
var int hiFillB1 = -1
var int hiFillB2 = -1

var linefill loFill = na
var int loFillA1 = -1
var int loFillA2 = -1
var int loFillB1 = -1
var int loFillB2 = -1

if barstate.islast or barstate.isconfirmed
    bool hiPair = fillInput and array.get(slotAlive, 0) and array.get(slotAlive, 2) and not na(array.get(slotLine, 0)) and not na(array.get(slotLine, 2))
    if hiPair
        int hiShortB1 = array.get(slotB1, 0)
        int hiShortB2 = array.get(slotB2, 0)
        int hiLongB1 = array.get(slotB1, 2)
        int hiLongB2 = array.get(slotB2, 2)
        if na(hiFill) or hiShortB1 != hiFillA1 or hiShortB2 != hiFillA2 or hiLongB1 != hiFillB1 or hiLongB2 != hiFillB2
            if not na(hiFill)
                linefill.delete(hiFill)
            hiFill := linefill.new(array.get(slotLine, 0), array.get(slotLine, 2), shiftTransparency(fallingColorInput, 88))
            hiFillA1 := hiShortB1
            hiFillA2 := hiShortB2
            hiFillB1 := hiLongB1
            hiFillB2 := hiLongB2
    else if not na(hiFill)
        linefill.delete(hiFill)
        hiFill := na

    bool loPair = fillInput and array.get(slotAlive, 3) and array.get(slotAlive, 5) and not na(array.get(slotLine, 3)) and not na(array.get(slotLine, 5))
    if loPair
        int loShortB1 = array.get(slotB1, 3)
        int loShortB2 = array.get(slotB2, 3)
        int loLongB1 = array.get(slotB1, 5)
        int loLongB2 = array.get(slotB2, 5)
        if na(loFill) or loShortB1 != loFillA1 or loShortB2 != loFillA2 or loLongB1 != loFillB1 or loLongB2 != loFillB2
            if not na(loFill)
                linefill.delete(loFill)
            loFill := linefill.new(array.get(slotLine, 3), array.get(slotLine, 5), shiftTransparency(risingColorInput, 88))
            loFillA1 := loShortB1
            loFillA2 := loShortB2
            loFillB1 := loLongB1
            loFillB2 := loLongB2
    else if not na(loFill)
        linefill.delete(loFill)
        loFill := na

// ── Empty-state notice ────────────────────────────────────────────────────────
//
// A retired line's own colour, width and style are the only visual trace that a line was
// violated - there is no separate marker or background flash for the event.
//
// When a side has no live line at all, across all three lengths, a small note explains why
// instead of leaving a blank chart that reads as broken. This exists instead of loosening the
// validity rule to force more lines to appear - the rule is the reason this indicator exists,
// so an honest "nothing qualifies right now" is preferred over a line that shouldn't be there.
// Two `var label`s, one per side, updated in place and deleted the moment that side gets a live
// line.
var label hiEmptyLabel = na
var label loEmptyLabel = na

if barstate.islast or barstate.isconfirmed
    bool hiAnyAlive = array.get(slotAlive, 0) or array.get(slotAlive, 1) or array.get(slotAlive, 2)
    bool loAnyAlive = array.get(slotAlive, 3) or array.get(slotAlive, 4) or array.get(slotAlive, 5)

    bool showHiEmpty = showEmptyNoteInput and showFallingInput and not hiAnyAlive
    if showHiEmpty
        float hiEmptyPrice = high + LABEL_DROP_ATR * atrNow
        if na(hiEmptyLabel)
            hiEmptyLabel := label.new(bar_index, hiEmptyPrice, "No valid descending line — recent pivot pairs failed the validity rule", xloc = xloc.bar_index, style = label.style_label_center, color = shiftTransparency(fallingColorInput, 85), textcolor = fallingColorInput, size = size.small)
        else
            label.set_xy(hiEmptyLabel, bar_index, hiEmptyPrice)
    else if not na(hiEmptyLabel)
        label.delete(hiEmptyLabel)
        hiEmptyLabel := na

    bool showLoEmpty = showEmptyNoteInput and showRisingInput and not loAnyAlive
    if showLoEmpty
        float loEmptyPrice = low - LABEL_DROP_ATR * atrNow
        if na(loEmptyLabel)
            loEmptyLabel := label.new(bar_index, loEmptyPrice, "No valid ascending line — recent pivot pairs failed the validity rule", xloc = xloc.bar_index, style = label.style_label_center, color = shiftTransparency(risingColorInput, 85), textcolor = risingColorInput, size = size.small)
        else
            label.set_xy(loEmptyLabel, bar_index, loEmptyPrice)
    else if not na(loEmptyLabel)
        label.delete(loEmptyLabel)
        loEmptyLabel := na

// ══════════════════════════════════════════════════════════════════════════════
// Screener series
// ══════════════════════════════════════════════════════════════════════════════
//
// Hidden from the chart pane and exposed to the Pine Screener as filterable columns instead. A
// plot carrying `display.data_window` still reaches the Screener, so these cost nothing
// visually.

// With three tiers per side there's no longer a single line to describe, so each series reports
// the nearest live line on that side.
float hiPriceNow = na
float loPriceNow = na
float hiTouchesNow = na
float loTouchesNow = na
int hiLiveCount = 0
int loLiveCount = 0

for slot = 0 to SLOT_COUNT - 1
    if array.get(slotAlive, slot)
        bool isHigh = slot < SIDE_SPAN
        float lp = linePriceAt(array.get(slotB1, slot), array.get(slotP1, slot), array.get(slotB2, slot), array.get(slotP2, slot), bar_index)
        if isHigh
            hiLiveCount += 1
            if na(hiPriceNow) or math.abs(lp - close) < math.abs(hiPriceNow - close)
                hiPriceNow := lp
                hiTouchesNow := array.get(slotTouches, slot)
        else
            loLiveCount += 1
            if na(loPriceNow) or math.abs(lp - close) < math.abs(loPriceNow - close)
                loPriceNow := lp
                loTouchesNow := array.get(slotTouches, slot)

plot(hiPriceNow, "Descending line price", display = display.data_window)
plot(loPriceNow, "Ascending line price", display = display.data_window)
plot(na(hiPriceNow) ? na : (hiPriceNow - close) / (atrNow > 0 ? atrNow : 1.0), "Distance to descending (ATR)", display = display.data_window)
plot(na(loPriceNow) ? na : (close - loPriceNow) / (atrNow > 0 ? atrNow : 1.0), "Distance to ascending (ATR)", display = display.data_window)
plot(hiTouchesNow, "Descending touches", display = display.data_window)
plot(loTouchesNow, "Ascending touches", display = display.data_window)
plot(hiLiveCount > 0 ? 1 : 0, "Descending line present", display = display.data_window)
plot(loLiveCount > 0 ? 1 : 0, "Ascending line present", display = display.data_window)
plot(hiLiveCount, "Descending lines live", display = display.data_window)
plot(loLiveCount, "Ascending lines live", display = display.data_window)

// ══════════════════════════════════════════════════════════════════════════════
// Alerts
// ══════════════════════════════════════════════════════════════════════════════
//
// Two conditions only, one per side - no proximity alert, no touch alert, and no alert when a
// line first appears.
//
// Both fire on a past event on a closed bar. `hiViolatedNow` and `loViolatedNow` are set inside
// the `barstate.isconfirmed` lifecycle block by the same code that retires the line, so an alert
// can never disagree with the chart or fire on a developing bar. Neither fires when a line is
// retired for age rather than violated - an aged line was never actually broken, and an alert
// saying otherwise would be false.
//
// The alert message is a `const string`, which Pine requires to be known at compile time - it
// cannot vary bar to bar, so it can't name the basis or tolerance actually in use. It names the
// event instead and points at the settings for the rest.
//
// The wording says "violated," not "breakout," "signal," or "entry" - each of those would be a
// claim about what happens on the bar after this one, where this only describes a bar that has
// already closed.
alertcondition(hiViolatedNow, "Descending line violated", "Auto Trendlines [AFD]: a descending line was violated and retired on the bar that just closed. What counts as a violation is the script's Violated By and Violation Tolerance settings. This describes a bar that has already closed and says nothing about the next one.")
alertcondition(loViolatedNow, "Ascending line violated", "Auto Trendlines [AFD]: an ascending line was violated and retired on the bar that just closed. What counts as a violation is the script's Violated By and Violation Tolerance settings. This describes a bar that has already closed and says nothing about the next one.")
````
