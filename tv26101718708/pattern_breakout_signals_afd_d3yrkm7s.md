# Pattern Breakout Signals [AFD]

- url: https://www.tradingview.com/script/d3yrkm7S-Pattern-Breakout-Signals-AFD/
- type: indicator
- pine_id: PUB;04a7ea1faa85494c88f94626fb71be28
- version: 1.0

## Description

[b]See what broke. See the plan.[/b]

Pattern Breakout Signals brings the breakout, its underlying structure and calculated Entry, Stop and three targets onto one chart. Trendlines, parallel channels and classical chart patterns are detected internally; no companion indicator is needed.

[b]ON THE CHART[/b]
[list]
[*]Long/Short triangles mark recent selected closed-bar signals. Hover for the formation or pattern name only.
[*]A solid outline shows the current formation. Previous formations shown selects 1-20 recent arrows with their frozen grey dashed formations (default 3), within retained history and drawing age.
[*]The latest signal draws Entry, Stop and T1/T2/T3, with optional shaded zones. The current formation is independent of those arrows.
[*]The method panel shows prices and the technical grade without hover popups. Reached target prices turn green; a reached stop price turns red.
[/list]

[b]THE LEVELS[/b]
Entry is the signal-bar close. The default stop uses 1.5 times the previous bar's ATR; Boundary mode places it beyond the broken boundary using an ATR buffer. Targets default to 1R, 2R and 3R, where R is the entry-to-rounded-stop distance. Each multiple is adjustable. Stops and targets round away from Entry to the tick grid. By design, prices freeze at the signal close; they do not trail.

[b]WHICH BREAKS COUNT[/b]
Signals require confirmed structure and a close beyond the breach tolerance, following a previous close inside tolerance relative to the previous bar's boundary. Pivot confirmation introduces delay.

Minimum score and Maximum extension filter signals; extension defaults to one prior-bar ATR beyond the boundary after tolerance. A rejected crossing still consumes that structure's break opportunity. Opposite-direction crossings on one bar suppress signals; otherwise eligible unrelated breaks compete by score, then smaller entry-to-stop distance, then a fixed identity order.

While a plan is Active, qualifying same-direction breaks sharing at least two distinct anchors (same bar and price) with its original formation count as related confirmations, at most once per bar. They create no extra marker, plan or alert. A new primary signal replaces the displayed plan.

[b]READING THE GRADE[/b]
Score combines close distance beyond the boundary after tolerance (40%), directional candle body (30%) and close location (30%). Components are normalized and limited to 0-1; distance uses prior-bar ATR. A is 75 or above, B is 50 to below 75, C is below 50. Fixed design weights, no outcome calibration: the grade measures the breakout candle, not future results. The guide and Full/JSON alert receipts carry the detailed formulas.

[b]AFTER THE SIGNAL[/b]
Only later closed bars are checked for Stop and target reaches, including gaps. Targets are tracked independently and keep their green price/checkmark after a later stop. A stop and a newly reached target on the same bar produce Order unknown; that bar adds no target reaches and the stop price stays neutral. Reaches describe bar ranges, not fills or executed trades.

A plan ends when Stop or all three targets are reached, order is unknown, its lifetime expires (100 bars from the signal by default), or a new primary supersedes it. Reaches are checked before expiry. Level length controls drawing length separately. There are no aggregate outcome statistics or outcome alerts.

[b]SETUP AND LIMITATIONS[/b]
Use standard time-based bars or candles. Signal labels hides triangles and technical grades; Show formations and Previous formation control outlines separately. For signal alerts, select Any alert() function call; Full text and JSON formats are available. Related confirmations send no alert.

These timing and lifecycle descriptions state the design; broader native chart verification remains outstanding. Calculated levels are not predictions. Not financial advice.

 Free and open-source under MPL 2.0.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry

//@version=6
indicator("Pattern Breakout Signals [AFD]", "PBS [AFD]", overlay = true, max_bars_back = 2001,
     max_lines_count = 120, max_labels_count = 160, max_polylines_count = 2, behind_chart = false)

// Constants

string MODEL_ATR      = "ATR"
string MODEL_BOUNDARY = "Boundary"
string FORMAT_FULL    = "Full"
string FORMAT_JSON    = "JSON"
int    HISTORY_LIMIT  = 2000
int    PRUNE_EVERY    = 64
int    FORM_LINE      = 1
int    FORM_PAIR      = 2
int    FORM_DOUBLE    = 3
int    FORM_SHOULDERS = 5
float  EXTENSION_EPS = 1e-9
string GROUP_FORM    = "Formations"
color TARGET_REACHED_COLOR = #26a69a
color STOP_REACHED_COLOR   = #ef5350

string DISCLOSE_SIGNAL = "Technical condition computed at the confirmed bar close; not a forecast and not financial advice. " +
     "A structure counts only from the bar it became known, after its pivot confirmation delay."
string DISCLOSE_LEVELS = "Calculated plan levels, frozen at the signal close; they never move. " +
     "Not a promised fill or result and not financial advice."
string DISCLOSE_GRADE  = "Score = 40 × close distance + 30 × candle body + 30 × close location, each clamped to 0–1: " +
     "distance = (direction × (close − boundary) − breach tolerance) ÷ preceding ATR; body = direction × (close − open) ÷ (high − low); " +
     "location = (close − low) ÷ (high − low) for Long, (high − close) ÷ (high − low) for Short. Grade from the score: " +
     "A ≥ 75, B ≥ 50, C < 50. Design weights with no calibration sample; it measures this candle " +
     "against this boundary and the preceding ATR, not the pattern or any future result."
string DISCLOSE_OBSERVATION = "Later confirmed-bar highs/lows observe Stop and each target, including gaps; no fills or trade results. " +
     "Stop plus a newly reached target on one bar means Order unknown; that bar adds no target reaches. " +
     "Reaches precede expiry. While the primary is Active, related same-direction breaks share two distinct exact anchor bar/price pairs with its frozen formation; " +
     "one confirmation count per bar, no new signal. No calibration sample."

// Inputs stay enabled so resetting settings cannot freeze dependent inputs; runtime switches govern use.
// Signals and levels

string GROUP_PLAN = "Signals and levels"
int pbsBreachTicks = input.int(0, "Breach tolerance (ticks)", minval = 0, maxval = 100, group = GROUP_PLAN,
     tooltip = "• Close must be strictly more than this many ticks beyond the boundary.\n• 0 accepts any close strictly beyond it.\n• Confirmed bars only; opposite breaks on one bar produce no plan.", display = display.data_window)
float pbsMinScore = input.float(0.0, "Minimum score", minval = 0.0, maxval = 100.0, step = 1.0, group = GROUP_PLAN,
     tooltip = "• Breaks scoring below this create no signal, plan or alert; the structure is still used up.\n• 0 disables score filtering. Grades: A ≥ 75, B ≥ 50, C < 50.\n• Weights are fixed design values, not outcome-calibrated; the guide and Full/JSON alerts disclose the method.", display = display.data_window)
float pbsMaxExtensionInput = input.float(1.0, "Maximum extension (ATR)", minval = 0.1, maxval = 10.0, step = 0.1, group = GROUP_PLAN,
     tooltip = "• Maximum direction × (close − boundary), less breach tolerance, divided by prior ATR.\n• Equality passes with a 1e-9 ATR comparison allowance; farther breaks consume the structure without a signal or confirmation.\n• Separate from the unchanged grade arithmetic; design threshold, no calibration sample.", display = display.data_window)
int pbsPlanLifetimeInput = input.int(100, "Plan lifetime (bars)", minval = 1, maxval = 2000, group = GROUP_PLAN,
     tooltip = "• Active plans expire this many confirmed bars after their signal.\n• Stop/target observations on the expiry bar take precedence.\n• Independent of Level length; observed reaches are not fills or trade results.", display = display.data_window)
string pbsModel = input.string(MODEL_ATR, "Stop model", options = [MODEL_ATR, MODEL_BOUNDARY], group = GROUP_PLAN,
     tooltip = "• ATR: stop distance = ATR stop multiple × prior ATR.\n• Boundary: stop beyond the broken boundary by Boundary buffer × prior ATR.\n• Stops round away from entry to the tick grid.", display = display.data_window)
int pbsAtrLength = input.int(14, "Plan ATR length", minval = 1, maxval = 200, group = GROUP_PLAN,
     tooltip = "• Wilder ATR length for score distance and plan levels.\n• Uses ATR from the bar before the signal.\n• Separate from the detector mean true ranges.", display = display.data_window)
float pbsStopAtr = input.float(1.5, "ATR stop multiple", minval = 0.1, maxval = 10.0, step = 0.1, group = GROUP_PLAN,
     tooltip = "• ATR stop distance from entry, in prior-bar ATR units.\n• Used only with Stop model = ATR.", display = display.data_window)
float pbsBufferAtr = input.float(0.25, "Boundary buffer (ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = GROUP_PLAN,
     tooltip = "• Stop buffer beyond the broken boundary, in prior-bar ATR units.\n• 0 adds no buffer. Used only with Stop model = Boundary.", display = display.data_window)
float pbsTarget1RInput = input.float(1.0, "Target 1 (R)", minval = 0.1, maxval = 20.0, step = 0.1, group = GROUP_PLAN,
     tooltip = "• T1 distance = this multiple × R, the entry-to-rounded-stop distance.\n• Independent of T2 and T3; tiers keep their names even if out of order.\n• Rounded away from entry to the tick grid; fixed at signal close.", display = display.data_window)
float pbsTargetR = input.float(2.0, "Target 2 (R)", minval = 0.1, maxval = 20.0, step = 0.1, group = GROUP_PLAN,
     tooltip = "• T2 distance = this multiple × R, the entry-to-rounded-stop distance.\n• Independent of T1 and T3; tiers keep their names even if out of order.\n• Rounded away from entry to the tick grid; fixed at signal close.", display = display.data_window)
float pbsTarget3RInput = input.float(3.0, "Target 3 (R)", minval = 0.1, maxval = 20.0, step = 0.1, group = GROUP_PLAN,
     tooltip = "• T3 distance = this multiple × R, the entry-to-rounded-stop distance.\n• Independent of T1 and T2; tiers keep their names even if out of order.\n• Rounded away from entry to the tick grid; fixed at signal close.", display = display.data_window)

// Display

string GROUP_VIEW = "Display"
bool  pbsShowSignals = input.bool(true, "Signal labels", group = GROUP_VIEW,
     tooltip = "• Show confirmed signal triangles from the same recent window as previous formations.\n• Previous formations shown sets the count; formation age/reach also limits triangles. Off hides markers and technical grades.\n• Each triangle's hover shows only the formation or pattern name.")
bool  pbsShowLevels  = input.bool(true, "Plan levels", group = GROUP_VIEW,
     tooltip = "• Show Entry, Stop and T1/T2/T3 for the latest retained signal.\n• Off hides level lines, target tags and plan prices/model together.\n• Reached target prices turn green; a reached Stop price turns red in the panel.")
int   pbsKeep        = input.int(10, "Plans kept", minval = 1, maxval = 40, group = GROUP_VIEW,
     tooltip = "• Signal records retained; oldest leave first, and any record over 9,500 bars old is dropped.\n• Previous formations shown selects recent eligible triangles and matching formations from these records. Only the latest record draws level lines.\n• Table records sets how many show in the panel.", display = display.data_window)
int   pbsExtent      = input.int(30, "Level length (bars)", minval = 1, maxval = 100, group = GROUP_VIEW,
     tooltip = "• Level lines grow to this many bars, then stop extending.\n• No future projection. Used while Plan levels is on.", display = display.data_window)
bool  pbsFillZonesInput = input.bool(true, "Fill plan zones", group = GROUP_VIEW,
     tooltip = "• Shades Entry→T1, T1→T2, T2→T3 and Entry→Stop for the latest signal.\n• Bands follow the T1/T2/T3 prices as set, even if out of order.\n• Used while Plan levels is on.")
int   pbsZoneTransparencyInput = input.int(92, "Zone fill transparency", minval = 0, maxval = 100, group = GROUP_VIEW, display = display.data_window,
     tooltip = "• Plan-zone fill transparency: 0 solid; 100 invisible.\n• Target bands use the Target color and the stop band the Stop color, with their own transparency replaced.\n• Used while Plan levels and Fill plan zones are on.")
bool  pbsShowTable   = input.bool(true, "Method panel", group = GROUP_VIEW,
     tooltip = "• Show retained signals and plan data without table hovers.\n• Off hides the panel.\n• Warnings stay visible; Setup notices show when no warning takes priority.")
string pbsPanelPositionInput = input.string("Bottom left", "Panel position", options = ["Bottom right", "Bottom left", "Top right", "Top left"], group = GROUP_VIEW,
     tooltip = "• Corner for the table, warnings and Setup notices.\n• Top corners add header clearance, largest at top left; very short panes may still clip.", display = display.data_window)
string pbsTableSizeInput = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal", "Large"],
     group = GROUP_VIEW, display = display.data_window,
     tooltip = "• Text size of the table, warnings and Setup notices.\n• Larger text takes more chart space.")
int pbsTableRecordsInput = input.int(1, "Table records", minval = 1, maxval = 3,
     group = GROUP_VIEW, display = display.data_window,
     tooltip = "• Newest retained events, oldest left and latest right.\n• Limited by Plans kept. Chart levels remain latest-only.\n• Used while Method panel is on.")
color pbsLongColor   = input.color(color.new(#26a69a, 0), "Long", group = GROUP_VIEW, inline = "dir", tooltip = "• Long triangle and Long table-heading color.\n• Shared color row: Short sets the corresponding Short color.")
color pbsShortColor  = input.color(color.new(#ef5350, 0), "Short", group = GROUP_VIEW, inline = "dir", tooltip = "• Long/Short colors affect their triangles and table headings.\n• They do not change signal direction or calculations.")
color pbsEntryColor  = input.color(color.new(#787b86, 0), "Entry", group = GROUP_VIEW, inline = "lvl", tooltip = "• Entry level-line color.\n• Shared row: Stop and Target set their own level-line colors.")
color pbsStopColor   = input.color(color.new(#ef5350, 0), "Stop", group = GROUP_VIEW, inline = "lvl", tooltip = "• Color of the Stop line and the Entry→Stop zone.\n• Used while Plan levels is on.")
color pbsTargetColor = input.color(color.new(#26a69a, 0), "Target", group = GROUP_VIEW, inline = "lvl", tooltip = "• One color for the T1/T2/T3 lines and the target zones; tags use the chart text color.\n• Used while Plan levels is on.")

float pbsMarkerGapInput = input.float(0.5, "Marker gap (ATR)", minval = 0.0, maxval = 3.0, step = 0.1,
     group = GROUP_VIEW, display = display.data_window,
     tooltip = "• Gap between the triangle and its signal candle (below the low for Long, above the high for Short), in prior-bar ATR.\n• Never less than two ticks, even at 0.\n• Used while Signal labels is on.")
bool pbsShowFormationsInput = input.bool(true, "Show formations", group = GROUP_FORM,
     tooltip = "• Draws one live structure (Current) and recent frozen signal formations (Previous).\n• Off hides all formations; signal detection is unchanged.\n• Built from confirmed pivots, so it appears after the confirmation delay.")
bool pbsPreviousInput = input.bool(true, "Previous formation", group = GROUP_FORM,
     tooltip = "• Shows recent signal formations in grey, dashed and unfilled.\n• Previous formations shown sets the requested count, including the latest signal.\n• Used while Show formations is on.")
int pbsPreviousCountInput = input.int(3, "Previous formations shown", minval = 1, maxval = 20,
     group = GROUP_FORM, display = display.data_window,
     tooltip = "• Number of recent retained signal triangles and matching frozen formations, including the latest.\n• Limited by Plans kept; both hide once a formation's drawn left edge is more than 2,000 bars old. Older records do not fill a gap.\n• Signal labels and formation switches independently hide their drawing type.")
bool pbsFillInput = input.bool(false, "Fill active formation", group = GROUP_FORM,
     tooltip = "• Fill the current channel/pattern body where an interior exists.\n• Single trendlines and previous formations have no fill.\n• Used while Show formations is on.")
color pbsFormationColorInput = input.color(#42a5f5, "Formation color", group = GROUP_FORM,
     tooltip = "• Color of the current formation's outline, caption and fill.\n• The outline keeps this color's own transparency; the fill uses Fill transparency.\n• Previous stays grey. Used while Show formations is on.")
int pbsFormationWidthInput = input.int(2, "Formation line width", minval = 1, maxval = 4,
     group = GROUP_FORM, display = display.data_window,
     tooltip = "• Current and previous outline width, in pixels.\n• Used while Show formations is on.")
int pbsFillTransparencyInput = input.int(90, "Fill transparency", minval = 0, maxval = 100,
     group = GROUP_FORM, display = display.data_window,
     tooltip = "• Current fill transparency: 0 solid; 100 invisible.\n• Independent of outline transparency.\n• Used while Show formations and Fill active formation are on.")

// Alerts

string GROUP_ALERT = "Alerts"
string pbsAlertFormat = input.string(FORMAT_FULL, "Format", options = [FORMAT_FULL, FORMAT_JSON], group = GROUP_ALERT,
     tooltip = "• Full: labeled text. JSON: information as fields.\n• Includes technical IDs, contributors, grade components and level methods.\n• One signal alert at confirmed bar close, with disclosures.", display = display.data_window)

// Engine interface

// One possible break of one live structure in one direction, as its engine saw it this bar.
type PbsCand
    string engine
    string family
    string structureId
    int    dir
    int    accepted
    float  boundary
    float  boundaryPrev
    bool   activePrev
    bool   breakAllowed
    int    latestAnchor
    int    horizon
    string currentFamily

// Scalar geometry copied from its confirmed structure.
type PbsForm
    string key = ""
    string name = ""
    int known = -1
    int kind = 0
    int leftBar = -1
    int boundaryBar = -1
    int rightBar = -1
    float upperStart = na
    float upperEnd = na
    float lowerStart = na
    float lowerEnd = na
    int anchor1 = -1
    int anchor2 = -1
    int anchor3 = -1
    int anchor4 = -1
    int anchor5 = -1
    float price1 = na
    float price2 = na
    float price3 = na
    float price4 = na
    float price5 = na

var array<PbsForm> pbsBreakFormsArray = array.new<PbsForm>()
var PbsForm pbsPreviousForm = na
var PbsForm pbsActiveForm = na

// A consumed structure-direction key and the bar after which nothing can rebuild it.
type PbsSpent
    int    deadline
    string liveId

var array<PbsCand>      pbsCands  = array.new<PbsCand>()
var array<string>       pbsLive   = array.new<string>()
var map<string, PbsSpent> pbsSpent = map.new<string, PbsSpent>()
var array<string> pbsFailures = array.new<string>()

// Records the first reason the stream stopped; nothing clears it within a load.
pbsFailNow(string why) =>
    if pbsFailures.size() == 0
        pbsFailures.push(why)

// Shared terminator: ends a branch made only for effect so every branch of a chain has one type.
pbsNoop() =>
    0

bool pbsSupported = chart.is_standard and not timeframe.isticks and
     (timeframe.isseconds or timeframe.isminutes or timeframe.isdwm)

// Malformed prices or tick metadata stop the whole stream; no partial engine state may signal.
if barstate.isconfirmed and pbsSupported and pbsFailures.size() == 0
    if na(open) or na(high) or na(low) or na(close) or high < low or low > math.min(open, close) or high < math.max(open, close)
        pbsFailNow("invalid prices on bar " + str.tostring(bar_index))
        pbsNoop()
    else if na(syminfo.mintick) or syminfo.mintick <= 0
        pbsFailNow("invalid tick size")
        pbsNoop()

bool  pbsRun  = barstate.isconfirmed and pbsSupported and pbsFailures.size() == 0
float pbsTick = syminfo.mintick
float pbsTol  = pbsBreachTicks * syminfo.mintick

// One close-breach predicate for engine retirement and shared event consumption.
pbsBeyond(float price, float boundary, int dir, float tolerance) =>
    dir * (price - boundary) > tolerance

// Plan ATR: Wilder average of true range (first bar high − low), read from the preceding bar.
float pbsTr       = ta.tr(true)
float pbsAtr      = ta.rma(pbsTr, pbsAtrLength)
float pbsAtrPrior = pbsAtr[1]

if pbsRun
    pbsCands.clear()
    pbsLive.clear()
    pbsBreakFormsArray.clear()

// Fails the stream when a history offset leaves the retained window; never substitutes other bars.
pbsHistoryOk(int offset) =>
    bool ok = offset >= 0 and offset <= bar_index and offset <= HISTORY_LIMIT
    if not ok
        pbsFailNow("history offset " + str.tostring(offset) + " outside the retained window")
    ok

// Trendline engine (ATLN)
// Pivots confirm `strength` bars after their anchor bar, so a line is available only after its
// second anchor has confirmed.

string ATLN_ANCHOR_WICK = "Wick"
string ATLN_ANCHOR_BODY = "Body"

// Slot layout: slots 0-2 are the high side (short, middle, long), slots 3-5 the low side.
int ATLN_SLOT_COUNT = 6
int ATLN_SIDE_SPAN  = 3

string ATLN_GRP = "Advanced · Trendline engine"

bool   atlnOn = input.bool(true, "Trendlines", group = ATLN_GRP, tooltip = "• Enable the trendline detector.\n• Off removes its candidates; other engines remain independent.")
int    atlnSwing = input.int(10, "Swing strength", minval = 1, maxval = 50, group = ATLN_GRP, tooltip = "• Bars on each side needed to confirm a swing; this is the short length.\n• A swing confirms this many bars late. Used with Trendlines on.\n• Bars to apply must be at least 2 × this + 1; Setup flags a shortfall.", display = display.data_window)
int    atlnPool = input.int(10, "Pivots searched", minval = 2, maxval = 12, group = ATLN_GRP, tooltip = "• Recent confirmed pivots searched per side and length.\n• More pivots allow more candidate pairs. Used with Trendlines on.", display = display.data_window)
int    atlnMeanLen = input.int(14, "Mean true range length", minval = 1, maxval = 200, group = ATLN_GRP, tooltip = "• Simple mean true-range length for trendline tolerances.\n• Uses available history during warm-up; separate from Wilder plan ATR.\n• Used with Trendlines on.", display = display.data_window)
float  atlnPierce = input.float(0.25, "Pierce tolerance (x mean true range)", minval = 0.0, maxval = 3.0, step = 0.05, group = ATLN_GRP, tooltip = "• Allowed wick penetration between anchors, in mean true-range units.\n• 0 permits no penetration. Used with Trendlines on.", display = display.data_window)
float  atlnTouch = input.float(0.25, "Touch tolerance (x mean true range)", minval = 0.0, maxval = 3.0, step = 0.05, group = ATLN_GRP, tooltip = "• Touch band around the line, in mean true-range units.\n• Used only with Trendlines on and Minimum touches above 0.", display = display.data_window)
int    atlnHorizon = input.int(300, "Bars to apply", minval = 100, maxval = 1000, group = ATLN_GRP, tooltip = "• A line expires when its first anchor is older than this many bars; a break on that bar still counts.\n• Each active length needs at least max(2 × strength + 1, strength + Minimum anchor span); Setup names any shortfall.\n• Used with Trendlines on.", display = display.data_window)
int    atlnMinSpan = input.int(0, "Minimum anchor span", minval = 0, maxval = 200, group = ATLN_GRP, tooltip = "• Minimum bars between line anchors.\n• 0 adds no minimum. Used with Trendlines on.", display = display.data_window)
int    atlnMinTouches = input.int(0, "Minimum touches", minval = 0, maxval = 10, group = ATLN_GRP, tooltip = "• Touches required before a pair is adopted.\n• 0 removes this requirement and makes Touch tolerance irrelevant.\n• Used with Trendlines on.", display = display.data_window)
bool   atlnTiers = input.bool(true, "Three lengths per side", group = ATLN_GRP, tooltip = "• Use short, middle and long swing lengths on each side.\n• Off uses only the short length. Used with Trendlines on.")
int    atlnMidMult = input.int(2, "Middle length multiple", minval = 2, maxval = 10, group = ATLN_GRP, tooltip = "• Middle strength = Swing strength × this multiple, capped at 200.\n• Bars to apply must be at least 2 × middle strength + 1.\n• Used with Trendlines and Three lengths per side on.", display = display.data_window)
int    atlnLongMult = input.int(4, "Long length multiple", minval = 2, maxval = 20, group = ATLN_GRP, tooltip = "• Long strength = Swing strength × this multiple, capped at 200.\n• Bars to apply must be at least 2 × long strength + 1.\n• Used with Trendlines and Three lengths per side on.", display = display.data_window)
string atlnAnchor = input.string(ATLN_ANCHOR_WICK, "Anchor price", options = [ATLN_ANCHOR_WICK, ATLN_ANCHOR_BODY], group = ATLN_GRP, tooltip = "• Anchor lines to pivot wicks or the edge of the candle body.\n• Pivots are always detected on wicks. Used with Trendlines on.", display = display.data_window)

// One side-and-length pivot pool: anchor bar indices with their anchor prices, oldest first.
type AtlnPool
    array<int>   bars
    array<float> prices

// One held line. `alive` false means the slot is empty.
type AtlnSlot
    bool   alive   = false
    int    b1      = -1
    float  p1      = 0.0
    int    b2      = -1
    float  p2      = 0.0
    int    adopted = -1
    string id      = ""

var array<AtlnPool> atlnPools = array.new<AtlnPool>()
var array<AtlnSlot> atlnSlots = array.new<AtlnSlot>()

if barstate.isfirst
    for k = 0 to ATLN_SLOT_COUNT - 1
        array.push(atlnPools, AtlnPool.new(array.new<int>(), array.new<float>()))
        array.push(atlnSlots, AtlnSlot.new())

// Guarded readers. `idx` is an absolute bar index; the offset must pass pbsHistoryOk (0 to
// min(bar_index, 2000)) or the stream fails closed and the reader returns na.
atlnHighAt(int idx) =>
    int off = bar_index - idx
    float r = na
    if pbsHistoryOk(off)
        r := high[off]
    r

atlnLowAt(int idx) =>
    int off = bar_index - idx
    float r = na
    if pbsHistoryOk(off)
        r := low[off]
    r

atlnCloseAt(int idx) =>
    int off = bar_index - idx
    float r = na
    if pbsHistoryOk(off)
        r := close[off]
    r

atlnBodyAt(int idx, bool isHigh) =>
    int off = bar_index - idx
    float r = na
    if pbsHistoryOk(off)
        r := isHigh ? math.max(open[off], close[off]) : math.min(open[off], close[off])
    r

// True range `barsBack` bars ago; high - low on the first chart bar.
atlnTrueRangeAt(int barsBack) =>
    float result = 0.0
    if barsBack >= bar_index
        result := high[barsBack] - low[barsBack]
        pbsNoop()
    else
        float prevClose = close[barsBack + 1]
        float a = high[barsBack] - low[barsBack]
        float b = math.abs(high[barsBack] - prevClose)
        float c = math.abs(low[barsBack] - prevClose)
        result := math.max(a, math.max(b, c))
        pbsNoop()
    result

// Simple mean of true range over the last `len` bars, newest first, on the shorter available
// sample at the start of the chart.
atlnMeanTrueRange(int len) =>
    int span = math.min(len, bar_index + 1)
    float total = 0.0
    if span > 0
        for i = 0 to span - 1
            total += atlnTrueRangeAt(i)
    span > 0 ? total / span : 0.0

// Line price at bar `b`; the * 1.0 forces float division.
atlnLineAt(int b1, float p1, int b2, float p2, int b) =>
    p1 + (p2 - p1) * ((b - b1) * 1.0 / (b2 - b1))

// Canonical identity: side, both anchors, anchor basis. Excludes slot and length.
atlnIdentity(bool isHigh, int b1, float p1, int b2, float p2, bool wickAnchor) =>
    (isHigh ? "H" : "L") + "|" + str.tostring(b1) + ":" + str.tostring(p1) + "|" + str.tostring(b2) + ":" + str.tostring(p2) + "|" + (wickAnchor ? "W" : "B")

// Does any bar strictly between the anchors trade through the line by more than `tol`?
atlnPierced(int b1, float p1, int b2, float p2, bool isHigh, float tol) =>
    bool pierced = false
    if b2 - b1 > 1
        for b = b1 + 1 to b2 - 1
            float lp = atlnLineAt(b1, p1, b2, p2, b)
            if isHigh
                if atlnHighAt(b) > lp + tol
                    pierced := true
                    break
                pbsNoop()
            else
                if atlnLowAt(b) < lp - tol
                    pierced := true
                    break
                pbsNoop()
    pierced

// Close-basis violation at bar `b`: the close is beyond the line by more than `tol`.
// Bars at or before the second anchor never violate.
atlnViolatesAt(int b1, float p1, int b2, float p2, bool isHigh, int b, float tol) =>
    bool result = false
    if b > b2
        float lp = atlnLineAt(b1, p1, b2, p2, b)
        float c = atlnCloseAt(b)
        result := pbsBeyond(c, lp, isHigh ? 1 : -1, tol)
    result

atlnViolatedSince(int b1, float p1, int b2, float p2, bool isHigh, int upto, float tol) =>
    bool violated = false
    if upto > b2
        for b = b2 + 1 to upto
            if atlnViolatesAt(b1, p1, b2, p2, isHigh, b, tol)
                violated := true
                break
    violated

// Is bar `b` inside the touch band? Penetration is signed and side-aware.
atlnIsTouch(int b1, float p1, int b2, float p2, bool isHigh, int b, float ttol) =>
    float lp = atlnLineAt(b1, p1, b2, p2, b)
    float pen = isHigh ? atlnHighAt(b) - lp : lp - atlnLowAt(b)
    pen >= -ttol and pen <= ttol

atlnTouchesSoFar(int b1, float p1, int b2, float p2, bool isHigh, float ttol) =>
    int n = 0
    if bar_index > b2
        for b = b2 + 1 to bar_index
            if atlnIsTouch(b1, p1, b2, p2, isHigh, b, ttol)
                n += 1
    n

// One pool's per-bar upkeep: append a newly confirmed pivot, trim to the searched size, then drop
// anchors older than the horizon. At most one pivot confirms per pool per bar, so one trim suffices.
atlnPoolStep(AtlnPool pool, float pivotPrice, int strength, bool isHigh, bool wickAnchor, int poolMax, int horizon) =>
    if not na(pivotPrice)
        int anchor = bar_index - strength
        float price = wickAnchor ? pivotPrice : atlnBodyAt(anchor, isHigh)
        if anchor < 0 or na(price)
            pbsFailNow("ATLN malformed pivot")
            pbsNoop()
        else
            array.push(pool.bars, anchor)
            array.push(pool.prices, price)
            pbsNoop()
    if array.size(pool.bars) > poolMax
        array.shift(pool.bars)
        array.shift(pool.prices)
    while array.size(pool.bars) > 0 and bar_index - array.get(pool.bars, 0) > horizon
        array.shift(pool.bars)
        array.shift(pool.prices)
    0

// Among valid pairs, the one nearest the current close. Scan order is newest second anchor, then
// newest first anchor, with a strict distance comparison so ties keep the earlier-found pair.
// (exB1a, exB2a) and (exB1b, exB2b) are pairs already held on this side; -1 means none.
atlnSelect(AtlnPool pool, bool isHigh, float pierceTol, float vtol, float ttol, int minSpan, int minTouches, int exB1a, int exB2a, int exB1b, int exB2b, float closeNow) =>
    int outB1 = -1
    float outP1 = 0.0
    int outB2 = -1
    float outP2 = 0.0
    bool found = false
    float bestDist = 0.0
    int n = array.size(pool.bars)
    if n >= 2
        for a = n - 1 to 1
            for b = a - 1 to 0
                int b1 = array.get(pool.bars, b)
                float p1 = array.get(pool.prices, b)
                int b2 = array.get(pool.bars, a)
                float p2 = array.get(pool.prices, a)
                bool progressive = isHigh ? p2 < p1 : p2 > p1
                bool spans = b2 - b1 >= minSpan
                bool taken = (b1 == exB1a and b2 == exB2a) or (b1 == exB1b and b2 == exB2b)
                if progressive and spans and not taken
                    if not atlnPierced(b1, p1, b2, p2, isHigh, pierceTol)
                        if not atlnViolatedSince(b1, p1, b2, p2, isHigh, bar_index, vtol)
                            bool touched = minTouches <= 0 or atlnTouchesSoFar(b1, p1, b2, p2, isHigh, ttol) >= minTouches
                            if touched
                                float d = math.abs(atlnLineAt(b1, p1, b2, p2, bar_index) - closeNow)
                                if not found or d < bestDist
                                    outB1 := b1
                                    outP1 := p1
                                    outB2 := b2
                                    outP2 := p2
                                    bestDist := d
                                    found := true
    [outB1, outP1, outB2, outP2, found]

pbsLineForm(AtlnSlot held, bool isHigh) =>
    PbsForm form = PbsForm.new()
    form.key := "ATLN|" + held.id
    form.name := isHigh ? "Descending trendline" : "Ascending trendline"
    form.known := held.adopted
    form.kind := FORM_LINE
    form.leftBar := held.b1
    form.boundaryBar := held.b1
    form.rightBar := bar_index
    form.upperStart := held.p1
    form.upperEnd := atlnLineAt(held.b1, held.p1, held.b2, held.p2, bar_index)
    form.anchor1 := held.b1
    form.price1 := held.p1
    form.anchor2 := held.b2
    form.price2 := held.p2
    form

// Series calls execute every bar, including disabled engines.

bool atlnWickAnchor = atlnAnchor == ATLN_ANCHOR_WICK
int  atlnShortLen = atlnSwing
int  atlnMidLen   = math.min(200, atlnSwing * atlnMidMult)
int  atlnLongLen  = math.min(200, atlnSwing * atlnLongMult)

float atlnMean = atlnMeanTrueRange(atlnOn ? atlnMeanLen : 1)

float atlnPivHighShort = ta.pivothigh(atlnShortLen, atlnShortLen)
float atlnPivHighMid   = ta.pivothigh(atlnMidLen, atlnMidLen)
float atlnPivHighLong  = ta.pivothigh(atlnLongLen, atlnLongLen)
float atlnPivLowShort  = ta.pivotlow(atlnShortLen, atlnShortLen)
float atlnPivLowMid    = ta.pivotlow(atlnMidLen, atlnMidLen)
float atlnPivLowLong   = ta.pivotlow(atlnLongLen, atlnLongLen)

float atlnCloseNow = close

if pbsRun and atlnOn
    float pierceTol = atlnPierce * atlnMean
    float touchTol  = atlnTouch * atlnMean
    float vtol = pbsTol
    array<PbsCand> stage = array.new<PbsCand>()

    for slot = 0 to ATLN_SLOT_COUNT - 1
        bool isHigh = slot < ATLN_SIDE_SPAN
        float pv = na
        int strength = atlnShortLen
        if slot == 0
            pv := atlnPivHighShort
            pbsNoop()
        else if slot == 1
            pv := atlnPivHighMid
            strength := atlnMidLen
            pbsNoop()
        else if slot == 2
            pv := atlnPivHighLong
            strength := atlnLongLen
            pbsNoop()
        else if slot == 3
            pv := atlnPivLowShort
            pbsNoop()
        else if slot == 4
            pv := atlnPivLowMid
            strength := atlnMidLen
            pbsNoop()
        else
            pv := atlnPivLowLong
            strength := atlnLongLen
            pbsNoop()
        atlnPoolStep(array.get(atlnPools, slot), pv, strength, isHigh, atlnWickAnchor, atlnPool, atlnHorizon)

    // Snapshot before break/age/tier retirement; breaks take priority over age.
    for slot = 0 to ATLN_SLOT_COUNT - 1
        AtlnSlot s = array.get(atlnSlots, slot)
        if s.alive
            bool isHigh = slot < ATLN_SIDE_SPAN
            int tier = slot % ATLN_SIDE_SPAN
            bool broken = atlnViolatesAt(s.b1, s.p1, s.b2, s.p2, isHigh, bar_index, vtol)
            bool aged = not broken and bar_index - s.b1 > atlnHorizon
            bool switchedOff = not broken and not aged and tier > 0 and not atlnTiers
            string fam = isHigh ? "Descending" : "Ascending"
            array.push(stage, PbsCand.new(
                 "ATLN", fam, s.id, isHigh ? 1 : -1, s.adopted,
                 atlnLineAt(s.b1, s.p1, s.b2, s.p2, bar_index),
                 atlnLineAt(s.b1, s.p1, s.b2, s.p2, bar_index - 1),
                 true, not aged and not switchedOff, s.b2, atlnHorizon, fam))
            if broken
                pbsBreakFormsArray.push(pbsLineForm(s, isHigh))
            if broken or aged or switchedOff
                s.alive := false

    // Fill high-side short/middle/long slots before low-side slots.
    for slot = 0 to ATLN_SLOT_COUNT - 1
        AtlnSlot s = array.get(atlnSlots, slot)
        int tier = slot % ATLN_SIDE_SPAN
        if not s.alive and (tier == 0 or atlnTiers)
            bool isHigh = slot < ATLN_SIDE_SPAN
            int base = isHigh ? 0 : ATLN_SIDE_SPAN
            AtlnSlot oa = array.get(atlnSlots, base + (slot - base + 1) % ATLN_SIDE_SPAN)
            AtlnSlot ob = array.get(atlnSlots, base + (slot - base + 2) % ATLN_SIDE_SPAN)
            int exB1a = oa.alive ? oa.b1 : -1
            int exB2a = oa.alive ? oa.b2 : -1
            int exB1b = ob.alive ? ob.b1 : -1
            int exB2b = ob.alive ? ob.b2 : -1
            [b1, p1, b2, p2, found] = atlnSelect(array.get(atlnPools, slot), isHigh, pierceTol, vtol, touchTol, atlnMinSpan, atlnMinTouches, exB1a, exB2a, exB1b, exB2b, atlnCloseNow)
            if found
                s.alive := true
                s.b1 := b1
                s.p1 := p1
                s.b2 := b2
                s.p2 := p2
                s.adopted := bar_index
                s.id := atlnIdentity(isHigh, b1, p1, b2, p2, atlnWickAnchor)

    // A failed stream publishes nothing from this bar.
    if pbsFailures.size() == 0
        for c in stage
            array.push(pbsCands, c)
        for slot = 0 to ATLN_SLOT_COUNT - 1
            AtlnSlot s = array.get(atlnSlots, slot)
            if s.alive
                array.push(pbsLive, "ATLN|" + s.id)

// Channel engine (ATCH)

const string ATCH_GROUP        = "Advanced · Channel engine"
const int    ATCH_HORIZON_MAX  = 2000
const int    ATCH_PENDING_CAP  = 32
const int    ATCH_PENDING_WAIT = 20

bool  atchOn         = input.bool(true, "Channels", group = ATCH_GROUP, tooltip = "• Enable the three-anchor channel detector.\n• Off does not disable Rising and falling channels in the Pattern engine.")
int   atchSwing      = input.int(8, "Swing length", minval = 2, maxval = 30, group = ATCH_GROUP, tooltip = "• Bars on each side needed to confirm a channel pivot.\n• Confirmation is delayed by this many bars.\n• A pivot must be strictly higher or lower than every bar in that window. Used with Channels on.", display = display.data_window)
bool  atchLonger     = input.bool(false, "Longer swing channel", group = ATCH_GROUP, tooltip = "• Add a longer-swing channel layer.\n• Strength = Swing length × Longer swing multiple.\n• Layer enables at horizon ≥ 3 × strength; its first break check needs one more bar.\n• Used with Channels on.")
int   atchMultiple   = input.int(3, "Longer swing multiple", minval = 2, maxval = 4, group = ATCH_GROUP, tooltip = "• Longer-layer strength = Swing length × this multiple.\n• Used with Channels and Longer swing channel on.", display = display.data_window)
int   atchPools      = input.int(10, "Channel pivots searched", minval = 3, maxval = 12, group = ATCH_GROUP, tooltip = "• Recent same-side pivots searched for three-anchor channels.\n• Newest pivot is the third anchor; older pivots can be the first.\n• Used with Channels on.", display = display.data_window)
int   atchHorizon    = input.int(600, "Search and age horizon", minval = 100, maxval = ATCH_HORIZON_MAX, group = ATCH_GROUP, tooltip = "• Maximum channel search reach and age, in bars from the first anchor.\n• Longer-layer break check needs at least 3 × its strength + 1 bars.\n• Used with Channels on.", display = display.data_window)
int   atchVolatility = input.int(14, "Volatility window", minval = 5, maxval = 100, group = ATCH_GROUP, tooltip = "• Simple mean true-range length for channel widths and allowances.\n• Separate from the plan ATR. Used with Channels on.", display = display.data_window)
float atchContain    = input.float(0.10, "Containment allowance", minval = 0.0, maxval = 0.50, step = 0.05, group = ATCH_GROUP, tooltip = "• Allowed wick penetration during channel construction, in mean true-range units.\n• 0 permits no penetration. Used with Channels on.", display = display.data_window)
float atchMinWidth   = input.float(0.50, "Minimum width", minval = 0.10, maxval = 5.0, step = 0.10, group = ATCH_GROUP, tooltip = "• Reject channels narrower than this multiple of the mean true range.\n• Must not exceed Maximum width; if it does, all signals stop. Used with Channels on.", display = display.data_window)
float atchMaxWidth   = input.float(8.0, "Maximum width", minval = 1.0, maxval = 20.0, step = 0.50, group = ATCH_GROUP, tooltip = "• Reject channels wider than this multiple of the mean true range.\n• Must not be below Minimum width; if it is, all signals stop. Used with Channels on.", display = display.data_window)

type AtchPivot
    int index
    float price

type AtchChannel
    AtchPivot a
    AtchPivot b
    AtchPivot c
    int dir
    int layer
    float slope
    float width
    float containment
    int constructed
    string key
    int available = -1

type AtchLayer
    array<AtchPivot> highsArray
    array<AtchPivot> lowsArray
    array<AtchChannel> pendingArray

type AtchUsed
    string key
    int anchor

// Mean true range is summed oldest to newest.
// The loop runs on every bar; a window that is short or holds an na bar yields na.
float atchTrValue = bar_index == 0 ? high - low : math.max(high - low, math.abs(high - close[1]), math.abs(low - close[1]))
float atchTrSum = 0.0
for atchK = atchVolatility - 1 to 0
    atchTrSum += atchTrValue[atchK]
float atchMean = bar_index >= atchVolatility - 1 ? atchTrSum / atchVolatility : na

bool atchLayerTwo = atchLonger and atchHorizon >= 3 * atchSwing * atchMultiple
bool atchConfigOk = atchMinWidth <= atchMaxWidth

var array<AtchLayer> atchLayersArray = array.new<AtchLayer>()
var array<AtchChannel> atchLiveArray = array.new<AtchChannel>(2)
var array<AtchUsed> atchUsedArray = array.new<AtchUsed>()

if array.size(atchLayersArray) == 0
    array.push(atchLayersArray, AtchLayer.new(array.new<AtchPivot>(), array.new<AtchPivot>(), array.new<AtchChannel>()))
    array.push(atchLayersArray, AtchLayer.new(array.new<AtchPivot>(), array.new<AtchPivot>(), array.new<AtchChannel>()))

atchLowerAt(AtchChannel ch, int index) =>
    float baseline = ch.a.price + ch.slope * (index - ch.a.index)
    ch.dir == 1 ? baseline : baseline - ch.width

atchUpperAt(AtchChannel ch, int index) =>
    float baseline = ch.a.price + ch.slope * (index - ch.a.index)
    ch.dir == 1 ? baseline + ch.width : baseline

atchInside(AtchChannel ch, int index, float last) =>
    last >= atchLowerAt(ch, index) and last <= atchUpperAt(ch, index)

atchKey(int dir, AtchPivot a, AtchPivot b, AtchPivot c) =>
    str.tostring(dir) + "|" + str.tostring(a.index) + ":" + str.tostring(a.price) + "|" + str.tostring(b.index) + ":" + str.tostring(b.price) + "|" + str.tostring(c.index) + ":" + str.tostring(c.price)

// Rank order: newer third anchor, smaller normalised distance to the centre,
// longer span, older middle anchor, rising direction. Strict, so a full tie keeps the incumbent.
atchBetter(AtchChannel cand, AtchChannel inc, int index, float last) =>
    float candDistance = math.abs(last - (atchLowerAt(cand, index) + cand.width * 0.5)) / cand.width
    float incDistance = math.abs(last - (atchLowerAt(inc, index) + inc.width * 0.5)) / inc.width
    int candSpan = cand.c.index - cand.a.index
    int incSpan = inc.c.index - inc.a.index
    bool better = false
    if cand.c.index != inc.c.index
        better := cand.c.index > inc.c.index
        pbsNoop()
    else if candDistance != incDistance
        better := candDistance < incDistance
        pbsNoop()
    else if candSpan != incSpan
        better := candSpan > incSpan
        pbsNoop()
    else if cand.b.index != inc.b.index
        better := cand.b.index < inc.b.index
        pbsNoop()
    else
        better := cand.dir > inc.dir
        pbsNoop()
    better

// A pivot centre must exceed every neighbour across both windows; ties and a centre
// that is also a pivot of the other side are excluded.
atchStrictPivot(int now, int strength) =>
    AtchPivot hi = na
    AtchPivot lo = na
    int centre = now - strength
    if centre - strength >= 0 and pbsHistoryOk(bar_index - (centre - strength))
        float centreHigh = high[bar_index - centre]
        float centreLow = low[bar_index - centre]
        bool highPivot = true
        bool lowPivot = true
        for index = centre - strength to now
            if index != centre
                highPivot := highPivot and centreHigh > high[bar_index - index]
                lowPivot := lowPivot and centreLow < low[bar_index - index]
        if highPivot != lowPivot
            if highPivot
                hi := AtchPivot.new(centre, centreHigh)
                pbsNoop()
            else
                lo := AtchPivot.new(centre, centreLow)
                pbsNoop()
    [hi, lo]

atchTrimPivots(array<AtchPivot> poolArray, int now) =>
    while array.size(poolArray) > 0 and now - array.get(poolArray, 0).index > atchHorizon
        array.shift(poolArray)
    0

atchConstruct(AtchPivot a, AtchPivot c, array<AtchPivot> oppositesArray, int dir, int layer, int strength, int now, float volatility) =>
    AtchChannel result = na
    bool valid = not na(volatility) and volatility > 0 and c.index - a.index >= 2 * strength and now - a.index <= atchHorizon and dir * (c.price - a.price) > 0
    if valid
        float slope = (c.price - a.price) / (c.index - a.index)
        AtchPivot b = na
        float width = 0.0
        int cursor = array.size(oppositesArray) - 1
        while cursor >= 0
            AtchPivot p = array.get(oppositesArray, cursor)
            if p.index <= a.index
                break
            if p.index < c.index
                float residual = dir * (p.price - (a.price + slope * (p.index - a.index)))
                if residual > 0 and residual >= width
                    width := residual
                    b := p
            cursor -= 1
        if not na(b) and width >= atchMinWidth * volatility and width <= atchMaxWidth * volatility
            AtchChannel candidate = AtchChannel.new(a, b, c, dir, layer, slope, width, atchContain * volatility, now, "")
            if pbsHistoryOk(bar_index - a.index)
                for index = a.index to c.index
                    if high[bar_index - index] > atchUpperAt(candidate, index) + candidate.containment or low[bar_index - index] < atchLowerAt(candidate, index) - candidate.containment
                        valid := false
                        break
                pbsNoop()
            else
                valid := false
                pbsNoop()
            if valid
                candidate.key := atchKey(dir, a, b, c)
                result := candidate
    result

atchWasUsed(string key) =>
    bool found = false
    if array.size(atchUsedArray) > 0
        for entry in atchUsedArray
            if entry.key == key
                found := true
                break
    found

// One layer: confirm pivots, build pending channels, accept the best inside close.
atchIngest(AtchLayer layerData, int layer, int strength, int now, float last, float volatility) =>
    [hi, lo] = atchStrictPivot(now, strength)
    if not na(hi)
        array.push(layerData.highsArray, hi)
    if not na(lo)
        array.push(layerData.lowsArray, lo)
    atchTrimPivots(layerData.highsArray, now)
    atchTrimPivots(layerData.lowsArray, now)
    for side = 0 to 1
        AtchPivot pivot = side == 0 ? hi : lo
        array<AtchPivot> sameArray = side == 0 ? layerData.highsArray : layerData.lowsArray
        array<AtchPivot> oppositeArray = side == 0 ? layerData.lowsArray : layerData.highsArray
        // atchPools >= 3, so the start never exceeds the end once two pivots exist
        if not na(pivot) and array.size(sameArray) > 1
            for index = math.max(0, array.size(sameArray) - atchPools) to array.size(sameArray) - 2
                AtchChannel candidate = atchConstruct(array.get(sameArray, index), pivot, oppositeArray, side == 0 ? -1 : 1, layer, strength, now, volatility)
                if not na(candidate)
                    array.push(layerData.pendingArray, candidate)
    while array.size(layerData.pendingArray) > ATCH_PENDING_CAP
        array.shift(layerData.pendingArray)
    AtchChannel liveNow = array.get(atchLiveArray, layer)
    if na(liveNow) and array.size(layerData.pendingArray) > 0
        int bestIndex = -1
        AtchChannel best = na
        for index = 0 to array.size(layerData.pendingArray) - 1
            AtchChannel candidate = array.get(layerData.pendingArray, index)
            if not atchWasUsed(candidate.key) and atchInside(candidate, now, last)
                if na(best)
                    best := candidate
                    bestIndex := index
                    pbsNoop()
                else if atchBetter(candidate, best, now, last)
                    best := candidate
                    bestIndex := index
                    pbsNoop()
        if bestIndex >= 0
            array.remove(layerData.pendingArray, bestIndex)
            best.available := now
            array.set(atchLiveArray, layer, best)
            array.push(atchUsedArray, AtchUsed.new(best.key, best.a.index))
    0

pbsChannelForm(AtchChannel held) =>
    PbsForm form = PbsForm.new()
    form.key := "ATCH|" + held.key
    form.name := held.dir == 1 ? "Rising channel" : "Falling channel"
    form.known := held.available
    form.kind := FORM_PAIR
    form.leftBar := held.a.index
    form.boundaryBar := held.a.index
    form.rightBar := bar_index
    form.upperStart := atchUpperAt(held, held.a.index)
    form.upperEnd := atchUpperAt(held, bar_index)
    form.lowerStart := atchLowerAt(held, held.a.index)
    form.lowerEnd := atchLowerAt(held, bar_index)
    form.anchor1 := held.a.index
    form.price1 := held.a.price
    form.anchor2 := held.b.index
    form.price2 := held.b.price
    form.anchor3 := held.c.index
    form.price3 := held.c.price
    form

if pbsRun and atchOn
    if not atchConfigOk
        pbsFailNow("Channel settings: minimum width exceeds maximum width. Lower Minimum width or raise Maximum width")
        pbsNoop()
    else
        int atchLayerCount = atchLayerTwo ? 2 : 1
        array<PbsCand> atchOut = array.new<PbsCand>()

        // Used keys leave once their first anchor can no longer reconstruct the channel.
        int usedIndex = array.size(atchUsedArray) - 1
        while usedIndex >= 0
            AtchUsed entry = array.get(atchUsedArray, usedIndex)
            if bar_index - entry.anchor > atchHorizon
                array.remove(atchUsedArray, usedIndex)
            usedIndex -= 1

        // Pending channels expire by age from the first anchor or by the wait since construction.
        for layer = 0 to atchLayerCount - 1
            array<AtchChannel> pendingArray = array.get(atchLayersArray, layer).pendingArray
            int pendingIndex = array.size(pendingArray) - 1
            while pendingIndex >= 0
                AtchChannel pendingChannel = array.get(pendingArray, pendingIndex)
                if bar_index - pendingChannel.a.index > atchHorizon or bar_index - pendingChannel.constructed > ATCH_PENDING_WAIT
                    array.remove(pendingArray, pendingIndex)
                pendingIndex -= 1

        // Prior active channels: candidates describe them before this bar's outcome; age precedes the close test.
        for layer = 0 to atchLayerCount - 1
            AtchChannel live = array.get(atchLiveArray, layer)
            if not na(live)
                bool aged = bar_index - live.a.index > atchHorizon
                float upperNow = atchUpperAt(live, bar_index)
                float lowerNow = atchLowerAt(live, bar_index)
                string family = live.dir == 1 ? "Rising channel" : "Falling channel"
                int latest = math.max(live.a.index, math.max(live.b.index, live.c.index))
                array.push(atchOut, PbsCand.new("ATCH", family, live.key, 1, live.available, upperNow, atchUpperAt(live, bar_index - 1), true, not aged, latest, atchHorizon, family))
                array.push(atchOut, PbsCand.new("ATCH", family, live.key, -1, live.available, lowerNow, atchLowerAt(live, bar_index - 1), true, not aged, latest, atchHorizon, family))
                bool outside = pbsBeyond(close, upperNow, 1, pbsTol) or pbsBeyond(close, lowerNow, -1, pbsTol)
                if not aged and outside
                    pbsBreakFormsArray.push(pbsChannelForm(live))
                if aged or outside
                    AtchChannel none = na
                    array.set(atchLiveArray, layer, none)

        for layer = 0 to atchLayerCount - 1
            atchIngest(array.get(atchLayersArray, layer), layer, layer == 0 ? atchSwing : atchSwing * atchMultiple, bar_index, close, atchMean)

        // Publish only when no history check failed on this bar.
        if array.size(pbsFailures) == 0
            for cand in atchOut
                array.push(pbsCands, cand)
            for layer = 0 to atchLayerCount - 1
                AtchChannel liveId = array.get(atchLiveArray, layer)
                if not na(liveId)
                    array.push(pbsLive, "ATCH|" + liveId.key)
                array<AtchChannel> idPending = array.get(atchLayersArray, layer).pendingArray
                if array.size(idPending) > 0
                    for pendingId in idPending
                        array.push(pbsLive, "ATCH|" + pendingId.key)
        pbsNoop()

// Pattern engine (CACP)
// Pivots confirm `swing` bars after their anchor bar, so a structure is available only from the
// bar its last anchor confirmed.

string CACP_GRP = "Advanced · Pattern engine"

string CACP_PRE_STRICT = "Strict"
string CACP_PRE_BAL    = "Balanced"
string CACP_PRE_PERM   = "Permissive"

string CACP_F_RECTANGLE   = "Rectangle"
string CACP_F_ASC_TRI     = "Ascending Triangle"
string CACP_F_DESC_TRI    = "Descending Triangle"
string CACP_F_SYM_TRI     = "Symmetrical Triangle"
string CACP_F_RISE_WEDGE  = "Rising Wedge"
string CACP_F_FALL_WEDGE  = "Falling Wedge"
string CACP_F_PENNANT     = "Pennant"
string CACP_F_BULL_FLAG   = "Bull Flag"
string CACP_F_BEAR_FLAG   = "Bear Flag"
string CACP_F_RISE_CHAN   = "Rising Channel"
string CACP_F_FALL_CHAN   = "Falling Channel"
string CACP_F_DOUBLE_TOP  = "Double Top"
string CACP_F_DOUBLE_BOT  = "Double Bottom"
string CACP_F_HS          = "Head & Shoulders"
string CACP_F_IHS         = "Inverse Head & Shoulders"
string CACP_F_NONE        = ""

int   CACP_SURVIVORS      = 3
int   CACP_MAX_KEPT       = 12
int   CACP_MAX_ACTIVE     = 6
int   CACP_MAX_NECKS      = 3
int   CACP_RESOLVED_MAX   = 144
int   CACP_POLE_LOOKBACK  = 20
int   CACP_FLAG_SPAN      = 40
float CACP_POLE_MIN       = 3.0
float CACP_SYMMETRY_MIN   = 0.30
float CACP_OVERLAP_MIN    = 0.30
float CACP_FLAT_FRAC      = 0.25
float CACP_FLAT_MEAN      = 1.25
float CACP_APEX_SPAN_MULT = 1.5
float CACP_WIDTH_MAX      = 1.5
float CACP_TOP_MATCH      = 0.5
float CACP_SHOULDER_MATCH = 0.75
float CACP_HEAD_BEYOND    = 0.5
float CACP_NECK_HEIGHT_MAX = 6.0
float CACP_HUGE           = 1e9

bool   cacpOn = input.bool(true, "Patterns", group = CACP_GRP,
     tooltip = "• Detect classical chart patterns; the family switches below choose which.\n• Independent of the Trendline and Channel engines.")
string cacpPreset = input.string(CACP_PRE_BAL, "Pattern preset", options = [CACP_PRE_STRICT, CACP_PRE_BAL, CACP_PRE_PERM],
     group = CACP_GRP, display = display.none,
     tooltip = "• Sets pivots kept per side, bar horizon, wick allowance (mean true ranges), flat angle and parallel angle (degrees).\n• Strict 6 / 200 / 0.10 / 1.0 / 8; Balanced 10 / 300 / 0.25 / 1.5 / 15; Permissive 12 / 400 / 0.45 / 3.0 / 22.\n• Used with Patterns on.")
int    cacpSwing = input.int(8, "Pattern swing strength", minval = 1, maxval = 50, group = CACP_GRP, display = display.none,
     tooltip = "• Bars on each side needed to confirm a pattern pivot.\n• Confirmation is delayed by this many bars. Used with Patterns on.")
int    cacpMeanLen = input.int(14, "Pattern mean true range length", minval = 1, maxval = 200, group = CACP_GRP, display = display.none,
     tooltip = "• Simple mean true-range length for pattern geometry.\n• Separate from plan ATR. Used with Patterns on.")
bool   cacpWedges     = input.bool(true, "Wedges", group = CACP_GRP, tooltip = "• Detect rising and falling wedges.\n• Used with Patterns on.")
bool   cacpTriangles  = input.bool(true, "Triangles", group = CACP_GRP, tooltip = "• Detect ascending, descending and symmetrical triangles.\n• Includes a pennant that outlasts 40 bars.\n• Used with Patterns on.")
bool   cacpRectangles = input.bool(true, "Rectangles", group = CACP_GRP, tooltip = "• Detect two flat, roughly parallel boundaries.\n• Used with Patterns on.")
bool   cacpChannels   = input.bool(true, "Rising and falling channels", group = CACP_GRP, tooltip = "• Detect parallel sloping pattern boundaries.\n• Includes a flag that outlasts 40 bars.\n• Independent of Channels in the Channel engine. Used with Patterns on.")
bool   cacpFlags      = input.bool(true, "Flags", group = CACP_GRP, tooltip = "• Detect bull/bear channels up to 40 bars long, after a 20-bar move of at least 3 mean true ranges.\n• Used with Patterns on.")
bool   cacpPennants   = input.bool(true, "Pennants", group = CACP_GRP, tooltip = "• Detect symmetrical triangles up to 40 bars long, after a 20-bar move of at least 3 mean true ranges.\n• Used with Patterns on.")
bool   cacpDoubles    = input.bool(true, "Double tops and bottoms", group = CACP_GRP, tooltip = "• Detect double tops/bottoms and their intervening neckline.\n• Used with Patterns on.")
bool   cacpHeadShoulders = input.bool(true, "Head and shoulders", group = CACP_GRP, tooltip = "• Detect head and shoulders and its inverse.\n• Neckline joins the two intervening extremes. Used with Patterns on.")

string pbsPanelLayoutInput = input.string("Full", "Panel layout", options = ["Full", "Compact"],
     group = GROUP_VIEW, display = display.data_window,
     tooltip = "• Full: separate Pro-style fields.\n• Compact: combine identity and age fields; retain separate prices without hovers.\n• For short panes, use Compact at Bottom left. Very short panes may still clip.\n• Used while Method panel is on.")

int cacpPoolUsed = switch cacpPreset
    CACP_PRE_STRICT => 6
    CACP_PRE_PERM   => 12
    => 10
int cacpBarsUsed = switch cacpPreset
    CACP_PRE_STRICT => 200
    CACP_PRE_PERM   => 400
    => 300
float cacpTolUsed = switch cacpPreset
    CACP_PRE_STRICT => 0.10
    CACP_PRE_PERM   => 0.45
    => 0.25
float cacpFlatUsed = switch cacpPreset
    CACP_PRE_STRICT => 1.0
    CACP_PRE_PERM   => 3.0
    => 1.5
float cacpParallelUsed = switch cacpPreset
    CACP_PRE_STRICT => 8.0
    CACP_PRE_PERM   => 22.0
    => 15.0

// One confirmed pivot: anchor bar index and wick price.
type CacpPoint
    int   idx
    float price

// A straight boundary through two anchors; isHigh marks a line through highs.
type CacpBound
    int   b1
    float p1
    int   b2
    float p2
    bool  isHigh

// A held two-boundary formation. `family` is the family it was accepted as and never changes;
// `kind` is the current family, which a brief flag or pennant may demote once.
type CacpPair
    string    family
    string    kind
    CacpBound upper
    CacpBound lower
    int       start
    int       apex
    int       available
    string    key

// A held neckline pattern. e3 is -1 for a double top or bottom.
type CacpNeck
    string    kind
    int       e1
    float     p1
    int       e2
    float     p2
    int       e3 = -1
    float     p3 = 0.0
    CacpBound neck
    int       start
    int       limit
    int       dir
    int       available = -1
    string    key

// The anchor bars of a pair that has ended, so the same pair cannot be accepted again.
type CacpPairKey
    int ub1
    int ub2
    int lb1
    int lb2

// Pivot and mean series execute on every bar.

float cacpMeanTr = ta.sma(ta.tr(true), cacpMeanLen)
float cacpPivHi  = ta.pivothigh(cacpSwing, cacpSwing)
float cacpPivLo  = ta.pivotlow(cacpSwing, cacpSwing)

var array<CacpPoint>   cacpHighs     = array.new<CacpPoint>()
var array<CacpPoint>   cacpLows      = array.new<CacpPoint>()
var array<CacpBound>   cacpUpperKept = array.new<CacpBound>()
var array<CacpBound>   cacpLowerKept = array.new<CacpBound>()
var array<CacpPair>    cacpActive    = array.new<CacpPair>()
var array<CacpNeck>    cacpNecks     = array.new<CacpNeck>()
var array<CacpPairKey> cacpResolved  = array.new<CacpPairKey>()

cacpOk() =>
    pbsFailures.size() == 0

// Guarded readers. `idx` is an absolute bar index; an offset outside pbsHistoryOk fails the
// stream and the reader returns na.
cacpHighAt(int idx) =>
    int off = bar_index - idx
    float r = na
    if pbsHistoryOk(off)
        r := high[off]
    r

cacpLowAt(int idx) =>
    int off = bar_index - idx
    float r = na
    if pbsHistoryOk(off)
        r := low[off]
    r

cacpCloseAt(int idx) =>
    int off = bar_index - idx
    float r = na
    if pbsHistoryOk(off)
        r := close[off]
    r

cacpSlope(CacpBound bd) =>
    (bd.p2 - bd.p1) / (bd.b2 - bd.b1)

cacpPriceAt(CacpBound bd, int b) =>
    bd.p1 + cacpSlope(bd) * (b - bd.b1)

cacpBoundKey(CacpBound bd) =>
    str.tostring(bd.b1) + ":" + str.tostring(bd.p1) + "|" + str.tostring(bd.b2) + ":" + str.tostring(bd.p2)

cacpPairKey(CacpBound up, CacpBound lo) =>
    "P|" + cacpBoundKey(up) + "|" + cacpBoundKey(lo)

// Same anchors and prices; the side flag is ignored.
cacpSameBound(CacpBound a, CacpBound b) =>
    a.b1 == b.b1 and a.b2 == b.b2 and a.p1 == b.p1 and a.p2 == b.p2

// True when the bar's wick at absolute index `b` trades beyond the line plus `tol`.
cacpViolatedAt(CacpBound bd, int b, float tol) =>
    float lp = cacpPriceAt(bd, b)
    bd.isHigh ? cacpHighAt(b) > lp + tol : cacpLowAt(b) < lp - tol

cacpViolatedRange(CacpBound bd, int fromBar, int toBar, float tol) =>
    bool hit = false
    if toBar >= fromBar
        for b = fromBar to toBar
            if cacpViolatedAt(bd, b, tol)
                hit := true
                break
    hit

cacpFamilyOn(string kind) =>
    switch kind
        CACP_F_RISE_WEDGE => cacpWedges
        CACP_F_FALL_WEDGE => cacpWedges
        CACP_F_ASC_TRI    => cacpTriangles
        CACP_F_DESC_TRI   => cacpTriangles
        CACP_F_SYM_TRI    => cacpTriangles
        CACP_F_RECTANGLE  => cacpRectangles
        CACP_F_RISE_CHAN  => cacpChannels
        CACP_F_FALL_CHAN  => cacpChannels
        CACP_F_BULL_FLAG  => cacpFlags
        CACP_F_BEAR_FLAG  => cacpFlags
        CACP_F_PENNANT    => cacpPennants
        CACP_F_DOUBLE_TOP => cacpDoubles
        CACP_F_DOUBLE_BOT => cacpDoubles
        CACP_F_HS         => cacpHeadShoulders
        CACP_F_IHS        => cacpHeadShoulders
        => false

// Families whose life also ends when the width leaves its band.
cacpBandKind(string kind) =>
    kind == CACP_F_RECTANGLE or kind == CACP_F_RISE_CHAN or kind == CACP_F_FALL_CHAN or
         kind == CACP_F_BULL_FLAG or kind == CACP_F_BEAR_FLAG

// Brief families that end, or demote, after the flag span.
cacpDemotes(string kind) =>
    kind == CACP_F_BULL_FLAG or kind == CACP_F_BEAR_FLAG or kind == CACP_F_PENNANT

cacpDemoteOf(string kind) =>
    switch kind
        CACP_F_BULL_FLAG => CACP_F_FALL_CHAN
        CACP_F_BEAR_FLAG => CACP_F_RISE_CHAN
        CACP_F_PENNANT   => CACP_F_SYM_TRI
        => kind

cacpClassify(float upper, float lower, float pole, float flat, float parallel, bool converges, bool diverges, float ratio, bool brief) =>
    bool uf = math.abs(upper) < flat
    bool lf = math.abs(lower) < flat
    bool inBand = ratio >= 1.0 / CACP_WIDTH_MAX and ratio <= CACP_WIDTH_MAX
    string kind = CACP_F_NONE
    if uf and lf
        if not diverges and inBand
            kind := CACP_F_RECTANGLE
        pbsNoop()
    else if upper < lower and converges
        if uf
            kind := CACP_F_ASC_TRI
            pbsNoop()
        else if lf
            kind := CACP_F_DESC_TRI
            pbsNoop()
        else if upper < 0 and lower > 0
            if math.min(math.abs(upper), math.abs(lower)) / math.max(math.abs(upper), math.abs(lower)) >= CACP_SYMMETRY_MIN
                kind := brief and math.abs(pole) >= CACP_POLE_MIN ? CACP_F_PENNANT : CACP_F_SYM_TRI
            pbsNoop()
        else if upper < 0
            kind := CACP_F_FALL_WEDGE
            pbsNoop()
        else
            kind := CACP_F_RISE_WEDGE
            pbsNoop()
        pbsNoop()
    else if not diverges and math.abs(upper - lower) <= parallel and inBand
        float meanAngle = (upper + lower) / 2
        if meanAngle > flat
            kind := brief and pole <= -CACP_POLE_MIN ? CACP_F_BEAR_FLAG : CACP_F_RISE_CHAN
            pbsNoop()
        else if meanAngle < -flat
            kind := brief and pole >= CACP_POLE_MIN ? CACP_F_BULL_FLAG : CACP_F_FALL_CHAN
            pbsNoop()
        pbsNoop()
    kind

cacpOverlap(CacpBound up, CacpBound lo) =>
    int shared = math.max(0, math.min(up.b2, lo.b2) - math.max(up.b1, lo.b1))
    int longer = math.max(up.b2 - up.b1, lo.b2 - lo.b1)
    longer <= 0 ? 0.0 : shared / float(longer)

cacpWidthRatio(CacpBound up, CacpBound lo) =>
    int left  = math.max(up.b1, lo.b1)
    int right = math.min(up.b2, lo.b2)
    float a = cacpPriceAt(up, left) - cacpPriceAt(lo, left)
    float b = cacpPriceAt(up, right) - cacpPriceAt(lo, right)
    right > left and a > 0 and b > 0 ? b / a : CACP_HUGE

// Bar where the two lines meet, rounded half up; -1 when parallel or out of range.
cacpApexOf(CacpBound up, CacpBound lo) =>
    float su = cacpSlope(up)
    float sl = cacpSlope(lo)
    int result = -1
    if su != sl
        float raw = (lo.p1 - sl * lo.b1 - up.p1 + su * up.b1) / (su - sl)
        if raw > 0 and raw < CACP_HUGE
            result := math.floor(raw + 0.5)
    result

// [underlying limit, current limit] for a formation of family `kind`. The band edge is compared
// in float before flooring, which gives the same result as flooring first for every edge that
// can bind and never converts an unbounded quotient to int.
cacpLimits(string kind, CacpBound up, CacpBound lo, int start, int apex) =>
    int span = math.max(up.b2 - up.b1, lo.b2 - lo.b1)
    int under = start + 2 * span
    if apex > start
        under := cacpPriceAt(up, apex) <= cacpPriceAt(lo, apex) ? apex - 1 : apex
    if cacpBandKind(kind)
        float width = cacpPriceAt(up, start) - cacpPriceAt(lo, start)
        float drift = cacpSlope(up) - cacpSlope(lo)
        if width > 0 and drift != 0
            float room = drift > 0 ? width * (CACP_WIDTH_MAX - 1) : width * (1 - 1 / CACP_WIDTH_MAX)
            float q = room / math.abs(drift)
            if q >= 1 and q < under - start
                under := start + math.floor(q)
    int lim = cacpDemotes(kind) ? math.min(under, start + CACP_FLAG_SPAN) : under
    [under, lim]

// Flat-claimed boundaries may not travel more than a quarter of the height or 1.25 mean TR.
cacpFlatHeld(string kind, CacpBound up, CacpBound lo, int right, float mean) =>
    int left = math.max(up.b1, lo.b1)
    float height = math.abs(cacpPriceAt(up, left) - cacpPriceAt(lo, left))
    bool held = true
    bool upClaim = kind == CACP_F_RECTANGLE or kind == CACP_F_ASC_TRI
    bool loClaim = kind == CACP_F_RECTANGLE or kind == CACP_F_DESC_TRI
    if upClaim
        float drift = math.abs(cacpSlope(up)) * math.max(0, right - up.b1)
        if (height > 0 and drift / height > CACP_FLAT_FRAC) or (mean > 0 and drift / mean > CACP_FLAT_MEAN)
            held := false
    if held and loClaim
        float drift = math.abs(cacpSlope(lo)) * math.max(0, right - lo.b1)
        if (height > 0 and drift / height > CACP_FLAT_FRAC) or (mean > 0 and drift / mean > CACP_FLAT_MEAN)
            held := false
    held

// True when an active formation already owns this upper or this lower (anchor bars only).
cacpHeld(CacpBound up, CacpBound lo) =>
    bool found = false
    for f in cacpActive
        if (f.upper.b1 == up.b1 and f.upper.b2 == up.b2) or (f.lower.b1 == lo.b1 and f.lower.b2 == lo.b2)
            found := true
            break
    found

cacpSeen(CacpBound up, CacpBound lo) =>
    bool found = false
    for k in cacpResolved
        if k.ub1 == up.b1 and k.ub2 == up.b2 and k.lb1 == lo.b1 and k.lb2 == lo.b2
            found := true
            break
    found

cacpInNecks(CacpBound bd) =>
    bool found = false
    for nk in cacpNecks
        if cacpSameBound(nk.neck, bd)
            found := true
            break
    found

cacpInPairs(CacpBound bd) =>
    bool found = false
    for f in cacpActive
        if cacpSameBound(f.upper, bd) or cacpSameBound(f.lower, bd)
            found := true
            break
    found

cacpKeptHas(array<CacpBound> kept, int b1, int b2) =>
    bool found = false
    for bd in kept
        if bd.b1 == b1 and bd.b2 == b2
            found := true
            break
    found

// Files an ended pair once; past 144 entries drops the oldest entry whose upper or lower is no
// longer kept, else the oldest entry.
cacpRetire(CacpPair f) =>
    bool added = not cacpSeen(f.upper, f.lower)
    if added
        array.push(cacpResolved, CacpPairKey.new(f.upper.b1, f.upper.b2, f.lower.b1, f.lower.b2))
    while array.size(cacpResolved) > CACP_RESOLVED_MAX
        int drop = 0
        int m = array.size(cacpResolved)
        for i = 0 to m - 1
            CacpPairKey k = array.get(cacpResolved, i)
            if not cacpKeptHas(cacpUpperKept, k.ub1, k.ub2) or not cacpKeptHas(cacpLowerKept, k.lb1, k.lb2)
                drop := i
                break
        array.remove(cacpResolved, drop)
    added

// Drops pivots older than the window, then the oldest beyond the pool size. Returns the size.
cacpPrunePool(array<CacpPoint> pool) =>
    while array.size(pool) > 0 and bar_index - array.get(pool, 0).idx > cacpBarsUsed
        array.shift(pool)
    while array.size(pool) > cacpPoolUsed
        array.shift(pool)
    array.size(pool)

// Drops kept boundaries the current bar's wick violates or whose first anchor left the window.
cacpPruneKept(array<CacpBound> kept, float tol) =>
    int n = array.size(kept)
    if n > 0
        for i = n - 1 to 0
            CacpBound bd = array.get(kept, i)
            if cacpViolatedAt(bd, bar_index, tol) or bar_index - bd.b1 > cacpBarsUsed
                array.remove(kept, i)
    array.size(kept)

// Pairs the newest pivot with every older pivot of its side; keeps lines with intact wicks
// between the anchors and since the second anchor, then trims to the newest twelve.
cacpAddBounds(array<CacpPoint> pool, array<CacpBound> kept, bool isHigh, float tol) =>
    int n = array.size(pool)
    if n > 1
        CacpPoint last = array.get(pool, n - 1)
        for i = 0 to n - 2
            CacpPoint older = array.get(pool, i)
            CacpBound bd = CacpBound.new(older.idx, older.price, last.idx, last.price, isHigh)
            if not cacpViolatedRange(bd, older.idx + 1, last.idx - 1, tol) and not cacpViolatedRange(bd, last.idx + 1, bar_index, tol)
                array.push(kept, bd)
        while array.size(kept) > CACP_MAX_KEPT
            array.shift(kept)
    array.size(kept)

// Indices of the three kept boundaries nearest the close; ties keep the earlier index.
cacpNearest(array<CacpBound> kept) =>
    array<int> pick = array.new<int>()
    int n = array.size(kept)
    int want = math.min(CACP_SURVIVORS, n)
    if want > 0
        for k = 1 to want
            int best = -1
            float bestDist = 0.0
            for i = 0 to n - 1
                if not array.includes(pick, i)
                    float d = math.abs(cacpPriceAt(array.get(kept, i), bar_index) - close)
                    if best == -1 or d < bestDist
                        best := i
                        bestDist := d
            if best >= 0
                array.push(pick, best)
    pick

// Classifies every surviving upper/lower pairing and accepts the qualifying ones.
cacpFormPairs(float mean) =>
    array<int> ups = cacpNearest(cacpUpperKept)
    array<int> los = cacpNearest(cacpLowerKept)
    int taken = 0
    for ui in ups
        for li in los
            CacpBound up = array.get(cacpUpperKept, ui)
            CacpBound lo = array.get(cacpLowerKept, li)
            if cacpOverlap(up, lo) >= CACP_OVERLAP_MIN and not cacpHeld(up, lo) and not cacpSeen(up, lo) and
                 not cacpInNecks(up) and not cacpInNecks(lo)
                int start = math.max(up.b1, lo.b1)
                int span  = math.max(up.b2 - up.b1, lo.b2 - lo.b1)
                int apex  = cacpApexOf(up, lo)
                float pole = 0.0
                if start >= CACP_POLE_LOOKBACK
                    pole := (cacpCloseAt(start) - cacpCloseAt(start - CACP_POLE_LOOKBACK)) / mean
                int reach = math.floor(CACP_APEX_SPAN_MULT * span + 0.5)
                bool converges = apex > start and apex - start <= reach
                bool diverges  = apex > 0 and apex <= start and start - apex <= reach
                string kind = cacpClassify(math.todegrees(math.atan(cacpSlope(up) / mean)),
                     math.todegrees(math.atan(cacpSlope(lo) / mean)), pole, cacpFlatUsed, cacpParallelUsed,
                     converges, diverges, cacpWidthRatio(up, lo), span <= CACP_FLAG_SPAN)
                [pairUnder, pairLimit] = cacpLimits(kind, up, lo, start, apex)
                if kind != CACP_F_NONE and cacpFamilyOn(kind) and bar_index <= pairLimit and
                     bar_index - start <= cacpBarsUsed and cacpFlatHeld(kind, up, lo, bar_index, mean)
                    array.push(cacpActive, CacpPair.new(kind, kind, up, lo, start, apex, bar_index, cacpPairKey(up, lo)))
                    taken := taken + 1
    taken

// Oldest strictly-between extreme of the opposite pool: lowest for tops, highest for bottoms.
cacpExtreme(array<CacpPoint> pool, int left, int right, bool tops) =>
    CacpPoint found = na
    for p in pool
        if p.idx > left and p.idx < right
            if na(found) or (tops ? p.price < found.price : p.price > found.price)
                found := p
    found

cacpBeyond(CacpPoint p, CacpPoint a, CacpPoint b, bool tops) =>
    na(p) ? false : tops ? p.price < math.min(a.price, b.price) : p.price > math.max(a.price, b.price)

cacpNeckKey(CacpNeck nk) =>
    string s = "N|" + str.tostring(nk.e1) + ":" + str.tostring(nk.p1) + "|" + str.tostring(nk.e2) + ":" + str.tostring(nk.p2)
    if nk.e3 >= 0
        s := s + "|" + str.tostring(nk.e3) + ":" + str.tostring(nk.p3)
    s + "|" + cacpBoundKey(nk.neck)

// Double match on the last two same-side pivots first, then head and shoulders on the last three.
cacpDetectNeck(array<CacpPoint> anchors, array<CacpPoint> troughs, bool tops, float mean) =>
    CacpNeck result = na
    int n = array.size(anchors)
    if n >= 2
        CacpPoint a = array.get(anchors, n - 2)
        CacpPoint b = array.get(anchors, n - 1)
        CacpPoint t = cacpExtreme(troughs, a.idx, b.idx, tops)
        if math.abs(a.price - b.price) <= CACP_TOP_MATCH * mean and cacpBeyond(t, a, b, tops)
            result := CacpNeck.new(tops ? CACP_F_DOUBLE_TOP : CACP_F_DOUBLE_BOT, a.idx, a.price, b.idx, b.price,
                 -1, 0.0, CacpBound.new(t.idx, t.price, b.idx, t.price, not tops), a.idx,
                 a.idx + 2 * (b.idx - a.idx), tops ? -1 : 1, -1, "")
    if na(result) and n >= 3
        CacpPoint s1 = array.get(anchors, n - 3)
        CacpPoint hd = array.get(anchors, n - 2)
        CacpPoint s2 = array.get(anchors, n - 1)
        bool head = tops ? hd.price > s1.price + CACP_HEAD_BEYOND * mean and hd.price > s2.price + CACP_HEAD_BEYOND * mean :
             hd.price < s1.price - CACP_HEAD_BEYOND * mean and hd.price < s2.price - CACP_HEAD_BEYOND * mean
        if head and math.abs(s1.price - s2.price) <= CACP_SHOULDER_MATCH * mean
            CacpPoint t1 = cacpExtreme(troughs, s1.idx, hd.idx, tops)
            CacpPoint t2 = cacpExtreme(troughs, hd.idx, s2.idx, tops)
            if cacpBeyond(t1, s1, hd, tops) and cacpBeyond(t2, hd, s2, tops)
                result := CacpNeck.new(tops ? CACP_F_HS : CACP_F_IHS, s1.idx, s1.price, hd.idx, hd.price,
                     s2.idx, s2.price, CacpBound.new(t1.idx, t1.price, t2.idx, t2.price, not tops), s1.idx,
                     s1.idx + 2 * (s2.idx - s1.idx), tops ? -1 : 1, -1, "")
    if not na(result)
        float height = result.e3 < 0 ?
             (tops ? math.max(result.p1, result.p2) - result.neck.p1 : result.neck.p1 - math.min(result.p1, result.p2)) :
             math.abs(result.p2 - cacpPriceAt(result.neck, result.e2))
        bool heightOk = height > 0 and height <= CACP_NECK_HEIGHT_MAX * mean
        if not heightOk
            result := na
        if heightOk
            result.key := cacpNeckKey(result)
    result

cacpNeckInvalidAt(CacpNeck nk, int index) =>
    float outer = nk.dir == -1 ? math.max(nk.p1, nk.p2) : math.min(nk.p1, nk.p2)
    if nk.e3 >= 0
        outer := nk.dir == -1 ? math.max(outer, nk.p3) : math.min(outer, nk.p3)
    pbsBeyond(cacpCloseAt(index), outer, -nk.dir, pbsTol)

cacpNeckInvalidSince(CacpNeck nk) =>
    int lastAnchor = nk.e3 >= 0 ? nk.e3 : nk.e2
    bool invalid = false
    if bar_index > lastAnchor
        for index = lastAnchor + 1 to bar_index
            if cacpNeckInvalidAt(nk, index)
                invalid := true
                break
    invalid

// Accepts an enabled, intact neckline within its limits, with no invalidating close or pair owner.
cacpTryNeck(array<CacpPoint> anchors, array<CacpPoint> troughs, bool tops, float mean, float tol) =>
    CacpNeck nk = cacpDetectNeck(anchors, troughs, tops, mean)
    bool took = false
    if not na(nk)
        if cacpFamilyOn(nk.kind) and bar_index <= nk.limit and bar_index - nk.start <= cacpBarsUsed and
             not cacpViolatedRange(nk.neck, nk.neck.b1 + 1, bar_index, tol) and not cacpInPairs(nk.neck) and not cacpNeckInvalidSince(nk)
            nk.available := bar_index
            array.push(cacpNecks, nk)
            took := true
    took

pbsPairForm(CacpPair held) =>
    PbsForm form = PbsForm.new()
    form.key := "CACP|" + held.key
    form.name := held.kind
    form.known := held.available
    form.kind := FORM_PAIR
    form.leftBar := held.start
    form.boundaryBar := held.start
    form.rightBar := bar_index
    form.upperStart := cacpPriceAt(held.upper, held.start)
    form.upperEnd := cacpPriceAt(held.upper, bar_index)
    form.lowerStart := cacpPriceAt(held.lower, held.start)
    form.lowerEnd := cacpPriceAt(held.lower, bar_index)
    form.anchor1 := held.upper.b1
    form.price1 := held.upper.p1
    form.anchor2 := held.upper.b2
    form.price2 := held.upper.p2
    form.anchor3 := held.lower.b1
    form.price3 := held.lower.p1
    form.anchor4 := held.lower.b2
    form.price4 := held.lower.p2
    form

pbsNeckForm(CacpNeck held) =>
    PbsForm form = PbsForm.new()
    form.key := "CACP|" + held.key
    form.name := held.kind
    form.known := held.available
    form.kind := held.e3 < 0 ? FORM_DOUBLE : FORM_SHOULDERS
    form.leftBar := held.e1
    form.boundaryBar := held.neck.b1
    form.rightBar := bar_index
    form.upperStart := held.neck.p1
    form.upperEnd := cacpPriceAt(held.neck, bar_index)
    form.anchor1 := held.e1
    form.price1 := held.p1
    form.anchor2 := held.neck.b1
    form.price2 := held.neck.p1
    form.anchor3 := held.e2
    form.price3 := held.p2
    if held.e3 >= 0
        form.anchor4 := held.neck.b2
        form.price4 := held.neck.p2
        form.anchor5 := held.e3
        form.price5 := held.p3
    form

// Newest first: demotion, expiry, candidates (not on the acceptance bar), then completion.
cacpStepPairs() =>
    int n = array.size(cacpActive)
    if n > 0
        for i = n - 1 to 0
            CacpPair f = array.get(cacpActive, i)
            [stepUnder, stepLimit] = cacpLimits(f.kind, f.upper, f.lower, f.start, f.apex)
            int lim = stepLimit
            if cacpDemotes(f.kind) and bar_index > lim and bar_index <= stepUnder and
                 bar_index - f.start <= cacpBarsUsed and cacpFamilyOn(cacpDemoteOf(f.kind))
                f.kind := cacpDemoteOf(f.kind)
                lim := stepUnder
            bool expired = bar_index > lim or bar_index - f.start > cacpBarsUsed
            float upNow = cacpPriceAt(f.upper, bar_index)
            float loNow = cacpPriceAt(f.lower, bar_index)
            if f.available < bar_index
                int latest = math.max(f.upper.b2, f.lower.b2)
                array.push(pbsCands, PbsCand.new("CACP", f.family, f.key, 1, f.available, upNow,
                     cacpPriceAt(f.upper, bar_index - 1), true, not expired, latest, cacpBarsUsed, f.kind))
                array.push(pbsCands, PbsCand.new("CACP", f.family, f.key, -1, f.available, loNow,
                     cacpPriceAt(f.lower, bar_index - 1), true, not expired, latest, cacpBarsUsed, f.kind))
            int side = expired ? 0 : pbsBeyond(close, upNow, 1, pbsTol) ? 1 : pbsBeyond(close, loNow, -1, pbsTol) ? -1 : 0
            if side != 0 and f.available < bar_index
                pbsBreakFormsArray.push(pbsPairForm(f))
            if expired or side != 0
                array.remove(cacpActive, i)
                cacpRetire(f)
    n

// Newest first: expiry, candidate in the neckline's one direction, then completion.
cacpStepNecks() =>
    int n = array.size(cacpNecks)
    if n > 0
        for i = n - 1 to 0
            CacpNeck nk = array.get(cacpNecks, i)
            bool expired = bar_index > nk.limit or bar_index - nk.start > cacpBarsUsed
            bool invalid = cacpNeckInvalidAt(nk, bar_index)
            float nb = cacpPriceAt(nk.neck, bar_index)
            if nk.available < bar_index
                int latest = math.max(math.max(nk.e1, nk.e2), math.max(nk.e3, math.max(nk.neck.b1, nk.neck.b2)))
                array.push(pbsCands, PbsCand.new("CACP", nk.kind, nk.key, nk.dir, nk.available, nb,
                     cacpPriceAt(nk.neck, bar_index - 1), true, not expired and not invalid, latest, cacpBarsUsed, nk.kind))
            bool outside = pbsBeyond(close, nb, nk.dir, pbsTol)
            if not expired and not invalid and outside and nk.available < bar_index
                pbsBreakFormsArray.push(pbsNeckForm(nk))
            if expired or invalid or outside
                array.remove(cacpNecks, i)
    n

if pbsRun and cacpOn
    float cacpMean = cacpMeanTr
    // A missing or nonpositive full-window mean pauses detection; held structures wait unchanged.
    if not na(cacpMean) and cacpMean > 0
        float cacpPierce = cacpTolUsed * cacpMean
        bool cacpNewHi = not na(cacpPivHi)
        bool cacpNewLo = not na(cacpPivLo)
        int  cacpAnchor = bar_index - cacpSwing
        if cacpNewHi
            float cacpWick = cacpAnchor >= 0 ? cacpHighAt(cacpAnchor) : na
            if na(cacpWick) or cacpWick != cacpPivHi
                pbsFailNow("CACP: pivot high differs from its anchor wick")
                pbsNoop()
            else
                array.push(cacpHighs, CacpPoint.new(cacpAnchor, cacpPivHi))
                pbsNoop()
        if cacpNewLo and cacpOk()
            float cacpWick = cacpAnchor >= 0 ? cacpLowAt(cacpAnchor) : na
            if na(cacpWick) or cacpWick != cacpPivLo
                pbsFailNow("CACP: pivot low differs from its anchor wick")
                pbsNoop()
            else
                array.push(cacpLows, CacpPoint.new(cacpAnchor, cacpPivLo))
                pbsNoop()
        // Pools, kept-boundary pruning and new boundaries: high side, then low side.
        if cacpOk()
            cacpPrunePool(cacpHighs)
            cacpPruneKept(cacpUpperKept, cacpPierce)
            if cacpNewHi
                cacpAddBounds(cacpHighs, cacpUpperKept, true, cacpPierce)
            cacpPrunePool(cacpLows)
            cacpPruneKept(cacpLowerKept, cacpPierce)
            if cacpNewLo
                cacpAddBounds(cacpLows, cacpLowerKept, false, cacpPierce)
        // Construction runs only on new pivot output and before any held structure is retired.
        if cacpOk() and (cacpNewHi or cacpNewLo)
            cacpFormPairs(cacpMean)
        if cacpOk() and cacpNewHi
            cacpTryNeck(cacpHighs, cacpLows, true, cacpMean, cacpPierce)
        if cacpOk() and cacpNewLo
            cacpTryNeck(cacpLows, cacpHighs, false, cacpMean, cacpPierce)
        if cacpOk()
            cacpStepPairs()
            cacpStepNecks()
            // Construction preserves all prior owners; held breaks publish before survivor eviction.
            while array.size(cacpActive) > CACP_MAX_ACTIVE
                cacpRetire(array.shift(cacpActive))
            while array.size(cacpNecks) > CACP_MAX_NECKS
                array.shift(cacpNecks)
    // Every held structure is live, including while detection is paused.
    if cacpOk()
        for f in cacpActive
            array.push(pbsLive, "CACP|" + f.key)
        for nk in cacpNecks
            array.push(pbsLive, "CACP|" + nk.key)

// Active geometry comes only from actual held structures, never the mixed live/pending ID list.
pbsHeldForm(string key) =>
    PbsForm found = na
    if atlnOn
        for slot = 0 to ATLN_SLOT_COUNT - 1
            AtlnSlot held = atlnSlots.get(slot)
            if held.alive and "ATLN|" + held.id == key
                found := pbsLineForm(held, slot < ATLN_SIDE_SPAN)
    if atchOn
        for layer = 0 to (atchLayerTwo ? 1 : 0)
            AtchChannel held = atchLiveArray.get(layer)
            if not na(held) and "ATCH|" + held.key == key
                found := pbsChannelForm(held)
    if cacpOn
        for held in cacpActive
            if "CACP|" + held.key == key
                found := pbsPairForm(held)
        for held in cacpNecks
            if "CACP|" + held.key == key
                found := pbsNeckForm(held)
    found

pbsFormReachOk(PbsForm form) =>
    bool valid = not na(form) and form.known >= 0 and form.known <= bar_index and form.leftBar >= 0 and
         form.rightBar <= bar_index and form.rightBar >= form.leftBar and bar_index - form.leftBar <= HISTORY_LIMIT and
         form.boundaryBar >= form.leftBar and form.boundaryBar <= form.rightBar and
         not na(form.upperStart) and not na(form.upperEnd)
    if valid
        if form.kind == FORM_PAIR
            valid := not na(form.lowerStart) and not na(form.lowerEnd)
        else if form.kind == FORM_DOUBLE or form.kind == FORM_SHOULDERS
            valid := form.anchor1 >= form.leftBar and form.anchor1 < form.anchor2 and form.anchor2 < form.anchor3 and
                 form.anchor3 <= form.rightBar and not na(form.price1) and not na(form.price2) and not na(form.price3)
            if valid and form.kind == FORM_SHOULDERS
                valid := form.anchor3 < form.anchor4 and form.anchor4 < form.anchor5 and form.anchor5 <= form.rightBar and
                     not na(form.price4) and not na(form.price5)
        else
            valid := form.kind == FORM_LINE
    valid

pbsFormDistance(PbsForm form) =>
    form.kind == FORM_PAIR ? math.min(math.abs(close - form.upperEnd), math.abs(close - form.lowerEnd)) :
     math.abs(close - form.upperEnd)

pbsKeyBefore(string firstKey, string secondKey) =>
    array<string> keysArray = array.from(firstKey, secondKey)
    keysArray.sort(order.ascending)
    keysArray.first() == firstKey

pbsChooseForm(PbsForm current) =>
    PbsForm picked = na(current) ? na : pbsHeldForm(current.key)
    if not pbsFormReachOk(picked)
        picked := na
        array<PbsForm> formsArray = array.new<PbsForm>()
        if atlnOn
            for slot = 0 to ATLN_SLOT_COUNT - 1
                AtlnSlot held = atlnSlots.get(slot)
                if held.alive
                    formsArray.push(pbsLineForm(held, slot < ATLN_SIDE_SPAN))
        if atchOn
            for layer = 0 to (atchLayerTwo ? 1 : 0)
                AtchChannel held = atchLiveArray.get(layer)
                if not na(held)
                    formsArray.push(pbsChannelForm(held))
        if cacpOn
            for held in cacpActive
                formsArray.push(pbsPairForm(held))
            for held in cacpNecks
                formsArray.push(pbsNeckForm(held))
        for form in formsArray
            if pbsFormReachOk(form)
                bool better = na(picked)
                if not better
                    float distance = pbsFormDistance(form)
                    float priorDistance = pbsFormDistance(picked)
                    better := distance < priorDistance or distance == priorDistance and (
                         form.known > picked.known or form.known == picked.known and pbsKeyBefore(form.key, picked.key))
                if better
                    picked := form
    picked

// Cache from every confirmed bar, including historical bars before an open last bar.
if pbsRun and pbsFailures.size() == 0 and pbsShowFormationsInput
    pbsActiveForm := pbsChooseForm(pbsActiveForm)

// Common event book

int   DRAW_REACH = 9500
int   SPENT_LIMIT = 49000

// One crossing that passed the score filter and produced valid levels in the chosen model.
type PbsPass
    PbsCand cand
    string  key
    float   distance
    float   body
    float   closeLoc
    float   score
    float   stop
    float   target
    float   target1
    float   target3
    float   risk

// One retained plan and every chart object it owns.
type PbsPlan
    int    bar
    int    closeTime
    int    dir
    string structure
    string formationName
    float  markerPrice
    float  entry
    float  stop
    float  target
    float  target1
    float  target3
    float  score
    line   entryLine
    line   stopLine
    line   targetLine
    line   target1Line
    line   target3Line
    linefill entryT1Fill
    linefill t1T2Fill
    linefill t2T3Fill
    linefill stopFill
    label  target1Label
    label  target2Label
    label  target3Label
    label  signalLabel
    PbsForm primaryForm
    string state = "Active"
    bool reached1 = false
    bool reached2 = false
    bool reached3 = false
    int confirmations = 0
    int confirmationBar = -1
    int terminalBar = -1

var array<PbsPlan> pbsPlans = array.new<PbsPlan>()
var bool pbsHadSignal = false

// Frozen scalar snapshots are separate from the mutable held structures and visual switches.
pbsBreakForm(PbsCand candidate) =>
    PbsForm found = na
    for form in pbsBreakFormsArray
        if form.key == candidate.engine + "|" + candidate.structureId
            found := form
            break
    found

pbsFormHasAnchor(PbsForm form, int index, float price) =>
    index >= 0 and not na(price) and (
         form.anchor1 == index and form.price1 == price or form.anchor2 == index and form.price2 == price or
         form.anchor3 == index and form.price3 == price or form.anchor4 == index and form.price4 == price or
         form.anchor5 == index and form.price5 == price)

// Two distinct exact bar/price pairs; confirmations never expand the primary's anchor set.
pbsRelatedForms(PbsForm primary, PbsForm candidate) =>
    bool related = false
    if not na(primary) and not na(candidate)
        array<int> barsArray = array.from(candidate.anchor1, candidate.anchor2, candidate.anchor3, candidate.anchor4, candidate.anchor5)
        array<float> pricesArray = array.from(candidate.price1, candidate.price2, candidate.price3, candidate.price4, candidate.price5)
        int firstBar = -1
        float firstPrice = na
        for index = 0 to 4
            int anchor = barsArray.get(index)
            float price = pricesArray.get(index)
            if pbsFormHasAnchor(primary, anchor, price)
                if firstBar < 0
                    firstBar := anchor
                    firstPrice := price
                    pbsNoop()
                else if anchor != firstBar or price != firstPrice
                    related := true
                    break
                pbsNoop()
    related

pbsStepPlan(PbsPlan plan) =>
    if plan.state == "Active" and bar_index > plan.bar
        bool stopNow = plan.dir == 1 ? low <= plan.stop : high >= plan.stop
        bool target1Now = not plan.reached1 and (plan.dir == 1 ? high >= plan.target1 : low <= plan.target1)
        bool target2Now = not plan.reached2 and (plan.dir == 1 ? high >= plan.target : low <= plan.target)
        bool target3Now = not plan.reached3 and (plan.dir == 1 ? high >= plan.target3 : low <= plan.target3)
        if stopNow and (target1Now or target2Now or target3Now)
            plan.state := "Order unknown"
            pbsNoop()
        else if stopNow
            plan.state := "Stop reached"
            pbsNoop()
        else
            plan.reached1 := plan.reached1 or target1Now
            plan.reached2 := plan.reached2 or target2Now
            plan.reached3 := plan.reached3 or target3Now
            if plan.reached1 and plan.reached2 and plan.reached3
                plan.state := "All targets reached"
            else if bar_index - plan.bar >= pbsPlanLifetimeInput
                plan.state := "Expired"
            pbsNoop()
        if plan.state != "Active"
            plan.terminalBar := bar_index
    pbsNoop()

// Observe later confirmed bars before deciding whether the latest primary can group this batch.
if pbsRun and pbsFailures.size() == 0 and pbsPlans.size() > 0
    pbsStepPlan(pbsPlans.last())

pbsKeyOf(PbsCand c) =>
    c.engine + "|" + c.family + "|" + c.structureId + "|" + (c.dir == 1 ? "L" : "S")

pbsSameRecord(PbsCand a, PbsCand b) =>
    a.engine == b.engine and a.family == b.family and a.structureId == b.structureId and a.dir == b.dir and
     a.accepted == b.accepted and a.boundary == b.boundary and a.boundaryPrev == b.boundaryPrev and
     a.activePrev == b.activePrev and a.breakAllowed == b.breakAllowed

pbsValidRecord(PbsCand c) =>
    (c.engine == "ATLN" or c.engine == "ATCH" or c.engine == "CACP") and not na(c.family) and c.family != "" and
     not na(c.structureId) and c.structureId != "" and (c.dir == 1 or c.dir == -1) and not na(c.accepted) and
     c.accepted >= 0 and not na(c.boundary) and not na(c.boundaryPrev) and not na(c.latestAnchor) and
     not na(c.horizon) and c.horizon > 0

// Corrects near-grid float noise within 1e-6 tick, but never snaps a level onto or across entry.
pbsTickRound(float price, bool up, float entry) =>
    float units = price / pbsTick
    float nearest = math.round(units)
    float snapped = math.abs(units - nearest) <= 1e-6 ? nearest : units
    float rounded = (up ? math.ceil(snapped) : math.floor(snapped)) * pbsTick
    float outward = (up ? math.ceil(units) : math.floor(units)) * pbsTick
    bool separated = up and rounded - entry > pbsTick * 1e-6 or not up and entry - rounded > pbsTick * 1e-6
    separated ? rounded : outward

// Grade components for one crossing on this bar, against the preceding bar's ATR.
pbsQuality(PbsCand c) =>
    float span     = high - low
    float distance = math.max(0.0, math.min(1.0, (c.dir * (close - c.boundary) - pbsTol) / pbsAtrPrior))
    float body     = math.max(0.0, math.min(1.0, c.dir * (close - open) / span))
    float closeLoc = c.dir == 1 ? (close - low) / span : (high - close) / span
    float score    = math.round((40.0 * distance + 30.0 * body + 30.0 * closeLoc) * 1000000.0) / 1000000.0
    [distance, body, closeLoc, score]

// Stop, three targets and risk; na unless every level has positive directional distance.
pbsLevels(PbsCand c) =>
    float rawStop = pbsModel == MODEL_ATR ? close - c.dir * pbsStopAtr * pbsAtrPrior :
         c.boundary - c.dir * pbsBufferAtr * pbsAtrPrior
    float stop    = na
    float target  = na
    float target1 = na
    float target3 = na
    float risk    = na
    if not na(rawStop) and c.dir * (close - rawStop) > 0
        float rounded = pbsTickRound(rawStop, c.dir == -1, close)
        float r = c.dir * (close - rounded)
        if not na(r) and r > 0
            float t = pbsTickRound(close + c.dir * pbsTargetR * r, c.dir == 1, close)
            float t1 = pbsTickRound(close + c.dir * pbsTarget1RInput * r, c.dir == 1, close)
            float t3 = pbsTickRound(close + c.dir * pbsTarget3RInput * r, c.dir == 1, close)
            if not na(t) and c.dir * (t - close) > 0 and not na(t1) and c.dir * (t1 - close) > 0 and not na(t3) and c.dir * (t3 - close) > 0
                stop    := rounded
                target  := t
                target1 := t1
                target3 := t3
                risk    := r
    [stop, target, target1, target3, risk]

pbsGrade(float score) =>
    score >= 75.0 ? "A" : score >= 50.0 ? "B" : "C"

pbsShownFamily(PbsCand c) =>
    c.currentFamily != c.family and not na(c.currentFamily) and c.currentFamily != "" ?
         c.currentFamily + " (from " + c.family + ")" : c.family

pbsFamilyText(string family, string engine) =>
    string named = engine == "ATLN" ? family + " trendline" : family
    str.substring(named, 0, 1) + str.lower(str.substring(named, 1, str.length(named)))

pbsChartFamily(PbsCand c) =>
    string named = pbsFamilyText(c.family, c.engine)
    if c.currentFamily != c.family and not na(c.currentFamily) and c.currentFamily != ""
        named := pbsFamilyText(c.currentFamily, c.engine) + " (from " + named + ")"
    named

pbsSignalFormation(PbsCand candidate) =>
    string family = not na(candidate.currentFamily) and candidate.currentFamily != "" ? candidate.currentFamily : candidate.family
    pbsFamilyText(family, candidate.engine)

// Decimal places of the tick, so prices print on the tick grid rather than the scale's precision.
pbsTickDecimals() =>
    int d = 0
    float scaled = pbsTick
    while d < 12 and (scaled < 0.5 or math.abs(scaled - math.round(scaled)) > 1e-7)
        scaled := scaled * 10.0
        d += 1
    d

pbsZeros(int n) =>
    string out = ""
    if n > 0
        for i = 1 to n
            out += "0"
    out

pbsPrice(float value) =>
    int d = pbsTickDecimals()
    str.tostring(value, d == 0 ? "0" : "0." + pbsZeros(d))

// Entry is the raw close and can carry sub-tick decimals on adjusted chart data.
pbsEntryText(float value) =>
    str.tostring(value, "0.################")

// ATR, boundary and risk retain sub-tick decimals like the raw entry.
pbsExact(float value) =>
    pbsEntryText(value)

pbsNum(float value) =>
    str.tostring(value, "0.######")

PbsPass        pbsSelected     = na
array<PbsPass> pbsPassing      = array.new<PbsPass>()

if pbsRun and pbsFailures.size() == 0
    // A malformed or conflicting record rejects the whole batch before any key is consumed.
    map<string, PbsCand> unique = map.new<string, PbsCand>()
    array<string> keyOrder = array.new<string>()
    for c in pbsCands
        if not pbsValidRecord(c)
            pbsFailNow("malformed engine record")
            break
        string k = pbsKeyOf(c)
        if unique.contains(k)
            if not pbsSameRecord(unique.get(k), c)
                pbsFailNow("conflicting records for one structure")
                break
            pbsNoop()
        else
            unique.put(k, c)
            keyOrder.push(k)
            pbsNoop()
    if pbsFailures.size() == 0
        // Every first close outside consumes its key, whether or not a plan follows.
        array<PbsCand> crossings = array.new<PbsCand>()
        for k in keyOrder
            PbsCand c = unique.get(k)
            if pbsSpent.contains(k) or not c.activePrev or not c.breakAllowed or c.accepted >= bar_index
                continue
            bool outside    = pbsBeyond(close, c.boundary, c.dir, pbsTol)
            bool prevInside = c.dir * (close[1] - c.boundaryPrev) <= pbsTol
            if outside
                pbsSpent.put(k, PbsSpent.new(c.latestAnchor + c.horizon + 1, c.engine + "|" + c.structureId))
                if prevInside
                    crossings.push(c)
        if pbsSpent.size() > SPENT_LIMIT
            pbsFailNow("consumed-structure registry above " + str.tostring(SPENT_LIMIT) + " entries")
        if crossings.size() > 0 and pbsFailures.size() == 0
            int longs  = 0
            int shorts = 0
            for c in crossings
                if c.dir == 1
                    longs += 1
                    pbsNoop()
                else
                    shorts += 1
                    pbsNoop()
            if longs > 0 and shorts > 0
                pbsNoop()
            else if na(pbsAtrPrior) or pbsAtrPrior <= 0 or high == low
                pbsNoop()
            else
                for c in crossings
                    [distance, body, closeLoc, score] = pbsQuality(c)
                    float extension = (c.dir * (close - c.boundary) - pbsTol) / pbsAtrPrior
                    if not na(score) and score >= pbsMinScore and extension <= pbsMaxExtensionInput + EXTENSION_EPS
                        [stop, target, target1, target3, risk] = pbsLevels(c)
                        if not na(stop) and not na(target)
                            PbsPlan latestPlan = pbsPlans.size() > 0 ? pbsPlans.last() : na
                            bool confirmation = false
                            if not na(latestPlan) and latestPlan.state == "Active" and latestPlan.dir == c.dir
                                confirmation := pbsRelatedForms(latestPlan.primaryForm, pbsBreakForm(c))
                            if confirmation
                                if latestPlan.confirmationBar != bar_index
                                    latestPlan.confirmations += 1
                                    latestPlan.confirmationBar := bar_index
                                pbsNoop()
                            else
                                pbsPassing.push(PbsPass.new(c, pbsKeyOf(c), distance, body, closeLoc, score, stop, target, target1, target3, risk))
                                pbsNoop()
                if pbsPassing.size() == 0
                    pbsNoop()
                else
                    // Highest score, then smaller risk, then the lowest key in sorted order.
                    float bestScore = pbsPassing.first().score
                    for p in pbsPassing
                        bestScore := math.max(bestScore, p.score)
                    float bestRisk = na
                    for p in pbsPassing
                        if p.score == bestScore
                            bestRisk := na(bestRisk) ? p.risk : math.min(bestRisk, p.risk)
                    array<string> tied = array.new<string>()
                    for p in pbsPassing
                        if p.score == bestScore and p.risk == bestRisk
                            tied.push(p.key)
                    tied.sort(order.ascending)
                    string winner = tied.first()
                    for p in pbsPassing
                        if p.key == winner
                            pbsSelected := p
                    pbsNoop()
                pbsNoop()

// A key is released only after every anchor has left its engine's horizon and its structure
// is neither live nor pending. Sweeping every PRUNE_EVERY bars only keeps keys longer.
if pbsRun and pbsFailures.size() == 0 and bar_index % PRUNE_EVERY == 0
    map<string, bool> live = map.new<string, bool>()
    for id in pbsLive
        live.put(id, true)
    for c in pbsCands
        live.put(c.engine + "|" + c.structureId, true)
    array<string> spentKeys = pbsSpent.keys()
    for k in spentKeys
        PbsSpent s = pbsSpent.get(k)
        if bar_index > s.deadline and not live.contains(s.liveId)
            pbsSpent.remove(k)

// Method text

pbsContributors() =>
    array<string> keys = array.new<string>()
    for p in pbsPassing
        keys.push(p.key)
    keys.sort(order.ascending)
    keys

pbsEngineCount() =>
    int n = 0
    for e in array.from("ATLN", "ATCH", "CACP")
        bool seen = false
        for p in pbsPassing
            if p.cand.engine == e
                seen := true
        n += seen ? 1 : 0
    n

pbsLevelMethod(PbsPass p) =>
    string stopRule = pbsModel == MODEL_ATR ?
         "Stop = entry " + (p.cand.dir == 1 ? "−" : "+") + " " + pbsNum(pbsStopAtr) + " × ATR(" + str.tostring(pbsAtrLength) + ") " + pbsExact(pbsAtrPrior) :
         "Stop = broken boundary " + pbsExact(p.cand.boundary) + " " + (p.cand.dir == 1 ? "−" : "+") + " " + pbsNum(pbsBufferAtr) + " × ATR(" + str.tostring(pbsAtrLength) + ") " + pbsExact(pbsAtrPrior)
    "Entry = signal-bar close " + pbsEntryText(close) + ".\n" + stopRule + ", rounded to the tick grid away from entry → " + pbsPrice(p.stop) +
         ".\nR = " + pbsExact(p.risk) + ". T1/T2/T3 = entry " + (p.cand.dir == 1 ? "+" : "−") + " (" +
         pbsNum(pbsTarget1RInput) + "/" + pbsNum(pbsTargetR) + "/" + pbsNum(pbsTarget3RInput) +
         ") × R, rounded away from entry → " + pbsPrice(p.target1) + "/" + pbsPrice(p.target) + "/" + pbsPrice(p.target3) +
         ".\nATR is from the bar before the signal. " + DISCLOSE_LEVELS

pbsJson(string value) =>
    string out = str.replace_all(value, "\\", "\\\\")
    out := str.replace_all(out, '"', '\\"')
    out := str.replace_all(out, "\n", " ")
    out

pbsTriggerMethod(PbsPass p) =>
    "Break: direction × (confirmed close − boundary) > breach tolerance; " +
         "direction × (previous close − previous boundary) ≤ breach tolerance. Direction = " +
         str.tostring(p.cand.dir) + "; previous close " + pbsEntryText(close[1]) +
         "; previous boundary " + pbsExact(p.cand.boundaryPrev) +
         "; structure became known on bar " + str.tostring(p.cand.accepted) + "."

pbsAlertText(PbsPass p, array<string> contributors, int engines) =>
    string dirWord = p.cand.dir == 1 ? "Long" : "Short"
    string stamp   = str.format_time(time_close, "yyyy-MM-dd HH:mm:ss", "UTC")
    string out = ""
    if pbsAlertFormat == FORMAT_JSON
        array<string> quoted = array.new<string>()
        for k in contributors
            quoted.push('"' + pbsJson(k) + '"')
        out := '{"script":"Pattern Breakout Signals [AFD]","symbol":"' + pbsJson(syminfo.tickerid) + '","timeframe":"' + timeframe.period +
             '","close_time_utc":"' + stamp + '","direction":"' + dirWord + '","event_key":"' + pbsJson(p.key) +
             '","engine":"' + p.cand.engine + '","family":"' + pbsJson(p.cand.family) + '","current_family":"' + pbsJson(p.cand.currentFamily) +
             '","contributors":[' + quoted.join(",") + '],"engine_count":' + str.tostring(engines) +
             ',"entry":' + pbsEntryText(close) + ',"stop":' + pbsPrice(p.stop) + ',"target":' + pbsPrice(p.target) +
             ',"target1":' + pbsPrice(p.target1) + ',"target2":' + pbsPrice(p.target) + ',"target3":' + pbsPrice(p.target3) +
             ',"target_multiples_r":[' + pbsNum(pbsTarget1RInput) + ',' + pbsNum(pbsTargetR) + ',' + pbsNum(pbsTarget3RInput) + ']' +
             ',"tick":' + pbsPrice(pbsTick) + ',"atr_prior":' + pbsExact(pbsAtrPrior) + ',"atr_length":' + str.tostring(pbsAtrLength) +
             ',"level_model":"' + pbsModel + '","stop_atr":' + pbsNum(pbsStopAtr) + ',"boundary_buffer_atr":' + pbsNum(pbsBufferAtr) +
             ',"target_r":' + pbsNum(pbsTargetR) + ',"boundary":' + pbsExact(p.cand.boundary) +
             ',"breach_ticks":' + str.tostring(pbsBreachTicks) + ',"breach_tolerance":' + pbsPrice(pbsTol) +
             ',"maximum_extension_atr":' + pbsNum(pbsMaxExtensionInput) + ',"plan_lifetime_bars":' + str.tostring(pbsPlanLifetimeInput) +
             ',"extension_comparison_allowance_atr":1e-9' +
             ',"plan_state":"Active","confirmation_bars":0,"targets_observed":[false,false,false],"observation_method":"' + pbsJson(DISCLOSE_OBSERVATION) + '"' +
             ',"risk":' + pbsExact(p.risk) + ',"level_method":"' + pbsJson(pbsLevelMethod(p)) +
             '","previous_close":' + pbsEntryText(close[1]) + ',"boundary_previous":' + pbsExact(p.cand.boundaryPrev) +
             ',"accepted_bar":' + str.tostring(p.cand.accepted) + ',"trigger_method":"' + pbsJson(pbsTriggerMethod(p)) + '"' +
             ',"grade":"' + pbsGrade(p.score) + '","score":' + pbsNum(p.score) + ',"distance":' + pbsNum(p.distance) +
             ',"body":' + pbsNum(p.body) + ',"location":' + pbsNum(p.closeLoc) +
             ',"weights":[40,30,30],"cutoffs":{"A":75,"B":50},"method":"' + pbsJson(DISCLOSE_GRADE) +
             '","levels_disclosure":"' + pbsJson(DISCLOSE_LEVELS) + '","signal_disclosure":"' + pbsJson(DISCLOSE_SIGNAL) + '"}'
        pbsNoop()
    else
        out := "Pattern Breakout Signals [AFD] — " + dirWord + " signal on " + syminfo.tickerid + " " + timeframe.period +
             " · bar close " + stamp + " UTC\n" + p.cand.engine + " " + pbsShownFamily(p.cand) + " · key " + p.key + "\n" +
             pbsModel + " model\n" + pbsLevelMethod(p) + "\nTick " + pbsPrice(pbsTick) +
             " · boundary " + pbsExact(p.cand.boundary) + " · breach tolerance " + str.tostring(pbsBreachTicks) +
             " ticks = " + pbsPrice(pbsTol) + "\n" + pbsTriggerMethod(p) + "\n" +
             "Grade " + pbsGrade(p.score) + " · score " + pbsNum(p.score) + " = 40 × " + pbsNum(p.distance) + " + 30 × " + pbsNum(p.body) +
             " + 30 × " + pbsNum(p.closeLoc) + "\nContributors (" + str.tostring(engines) + " engine" + (engines == 1 ? "" : "s") + "): " +
             contributors.join(", ") + "\n" + DISCLOSE_GRADE + "\n" + DISCLOSE_SIGNAL
        out += "\nMaximum extension " + pbsNum(pbsMaxExtensionInput) + " ATR after tolerance, with a 1e-9 ATR comparison allowance; lifetime " + str.tostring(pbsPlanLifetimeInput) +
             " bars; plan Active, confirmation bars 0, no target observations at creation.\n" + DISCLOSE_OBSERVATION
        pbsNoop()
    out

pbsChartText(string source) =>
    string out = str.replace_all(source, "ATLN Descending", "Descending trendline")
    out := str.replace_all(out, "ATLN Ascending", "Ascending trendline")
    out := str.replace_all(out, "ATLN|", "")
    out := str.replace_all(out, "ATCH|", "")
    out := str.replace_all(out, "CACP|", "")
    out := str.replace_all(out, "ATLN ", "Trendline ")
    out := str.replace_all(out, "ATCH ", "")
    out := str.replace_all(out, "CACP ", "")
    out := str.replace_all(out, "ATCH: ", "Channel: ")
    out := str.replace_all(out, "CACP: ", "Pattern: ")
    out := str.replace_all(out, "ATLN: ", "Trendline: ")
    out

// Plan drawings

pbsDeleteLevels(PbsPlan p) =>
    line.delete(p.entryLine)
    line.delete(p.stopLine)
    line.delete(p.targetLine)
    line.delete(p.target1Line)
    line.delete(p.target3Line)
    linefill.delete(p.entryT1Fill)
    linefill.delete(p.t1T2Fill)
    linefill.delete(p.t2T3Fill)
    linefill.delete(p.stopFill)
    p.entryT1Fill   := na
    p.t1T2Fill      := na
    p.t2T3Fill      := na
    p.stopFill      := na
    label.delete(p.target1Label)
    label.delete(p.target2Label)
    label.delete(p.target3Label)
    p.entryLine     := na
    p.stopLine      := na
    p.targetLine    := na
    p.target1Line   := na
    p.target3Line   := na
    p.target1Label  := na
    p.target2Label  := na
    p.target3Label  := na
    pbsNoop()

pbsTargetTag(int bar, float price, string tiers) =>
    label.new(bar, price, tiers, xloc = xloc.bar_index, yloc = yloc.price,
         style = label.style_label_left, color = color.new(chart.bg_color, 100),
         textcolor = chart.fg_color, size = size.small, tooltip = tiers)

pbsSameTarget(float firstPrice, float secondPrice) =>
    math.abs(firstPrice - secondPrice) / pbsTick < 0.5

// Coincident tick prices share one tag without moving the actual target levels.
pbsCreateTargetTags(PbsPlan plan) =>
    bool same12 = pbsSameTarget(plan.target1, plan.target)
    bool same13 = pbsSameTarget(plan.target1, plan.target3)
    bool same23 = pbsSameTarget(plan.target, plan.target3)
    string first = "T1" + (same12 ? "/T2" : "") + (same13 ? "/T3" : "")
    plan.target1Label := pbsTargetTag(plan.bar, plan.target1, first)
    if not same12
        plan.target2Label := pbsTargetTag(plan.bar, plan.target, "T2" + (same23 ? "/T3" : ""))
    if not same13 and not same23
        plan.target3Label := pbsTargetTag(plan.bar, plan.target3, "T3")
    pbsNoop()

pbsDeletePlan(PbsPlan p) =>
    pbsDeleteLevels(p)
    label.delete(p.signalLabel)
    pbsNoop()

if not na(pbsSelected)
    PbsPass p = pbsSelected
    pbsHadSignal := true
    // The selected break owns the snapshot captured before engine retirement/refill.
    pbsPreviousForm := pbsBreakForm(p.cand)
    array<string> contributors = pbsContributors()
    int engines = pbsEngineCount()
    while pbsPlans.size() >= pbsKeep
        pbsDeletePlan(pbsPlans.shift())
    if pbsPlans.size() > 0
        PbsPlan prior = pbsPlans.last()
        if prior.state == "Active"
            prior.state := "Superseded"
            prior.terminalBar := bar_index
        pbsDeleteLevels(pbsPlans.last())
    PbsPlan plan = PbsPlan.new(bar_index)
    plan.closeTime      := time_close
    plan.dir            := p.cand.dir
    plan.structure      := pbsChartFamily(p.cand)
    plan.formationName  := pbsSignalFormation(p.cand)
    plan.entry          := close
    plan.stop           := p.stop
    plan.target         := p.target
    plan.target1        := p.target1
    plan.target3        := p.target3
    plan.score          := p.score
    plan.primaryForm    := pbsPreviousForm
    float markerGap = math.max(pbsMarkerGapInput * pbsAtrPrior, 2.0 * pbsTick)
    float markerPrice = p.cand.dir == 1 ? low - markerGap : high + markerGap
    plan.markerPrice    := markerPrice
    if pbsShowLevels
        plan.entryLine  := line.new(bar_index, plan.entry, bar_index, plan.entry, color = pbsEntryColor, style = line.style_solid, width = 1)
        plan.stopLine   := line.new(bar_index, plan.stop, bar_index, plan.stop, color = pbsStopColor, style = line.style_dashed, width = 1)
        plan.targetLine := line.new(bar_index, plan.target, bar_index, plan.target, color = pbsTargetColor, style = line.style_dotted, width = 1)
        plan.target1Line := line.new(bar_index, plan.target1, bar_index, plan.target1, color = pbsTargetColor, style = line.style_dotted, width = 1)
        plan.target3Line := line.new(bar_index, plan.target3, bar_index, plan.target3, color = pbsTargetColor, style = line.style_dotted, width = 1)
        if pbsFillZonesInput
            color targetZone = color.new(pbsTargetColor, pbsZoneTransparencyInput)
            plan.entryT1Fill := linefill.new(plan.entryLine, plan.target1Line, targetZone)
            plan.t1T2Fill    := linefill.new(plan.target1Line, plan.targetLine, targetZone)
            plan.t2T3Fill    := linefill.new(plan.targetLine, plan.target3Line, targetZone)
            plan.stopFill    := linefill.new(plan.entryLine, plan.stopLine, color.new(pbsStopColor, pbsZoneTransparencyInput))
        pbsCreateTargetTags(plan)
    pbsPlans.push(plan)
    alert(pbsAlertText(p, contributors, engines), alert.freq_once_per_bar_close)

// Retention belongs to signal records; only the newest owns live plan lines.
if pbsPlans.size() > 0
    for i = pbsPlans.size() - 1 to 0
        PbsPlan p = pbsPlans.get(i)
        if bar_index - p.bar > DRAW_REACH
            pbsDeletePlan(p)
            pbsPlans.remove(i)
            pbsNoop()
        else if not na(p.entryLine)
            int rightBar = math.min(bar_index, p.bar + pbsExtent)
            rightBar := p.terminalBar >= 0 ? math.min(rightBar, p.terminalBar) : rightBar
            p.entryLine.set_x2(rightBar)
            p.stopLine.set_x2(rightBar)
            p.targetLine.set_x2(rightBar)
            p.target1Line.set_x2(rightBar)
            p.target3Line.set_x2(rightBar)
            label.set_xy(p.target1Label, rightBar, p.target1)
            if not na(p.target2Label)
                label.set_xy(p.target2Label, rightBar, p.target)
            if not na(p.target3Label)
                label.set_xy(p.target3Label, rightBar, p.target3)
            pbsNoop()

// Formation drawings

type PbsFormDraw
    string key = ""
    int signalBar = -1
    array<line> linesArray
    array<linefill> fillsArray
    label nameLabel
    array<polyline> polygonsArray

pbsNewFormDrawing() =>
    PbsFormDraw.new(linesArray = array.new<line>(5), fillsArray = array.new<linefill>(1), polygonsArray = array.new<polyline>(2))

var PbsFormDraw pbsActiveDrawing = pbsNewFormDrawing()
var array<PbsFormDraw> pbsPreviousDrawingsArray = array.new<PbsFormDraw>()

pbsClearForm(PbsFormDraw drawing) =>
    for polygonId in drawing.polygonsArray
        polyline.delete(polygonId)
    drawing.polygonsArray.set(0, na)
    drawing.polygonsArray.set(1, na)
    for fillId in drawing.fillsArray
        linefill.delete(fillId)
    for lineId in drawing.linesArray
        line.delete(lineId)
    for i = 0 to 4
        drawing.linesArray.set(i, na)
    drawing.fillsArray.set(0, na)
    label.delete(drawing.nameLabel)
    drawing.nameLabel := na
    drawing.key := ""
    pbsNoop()

pbsFormLineUpdate(PbsFormDraw drawing, int slot, int firstBar, float firstPrice, int lastBar, float lastPrice, color usedColor, bool previous) =>
    line outlineLine = drawing.linesArray.get(slot)
    if na(outlineLine)
        outlineLine := line.new(firstBar, firstPrice, lastBar, lastPrice, xloc = xloc.bar_index,
             color = usedColor, width = pbsFormationWidthInput)
        drawing.linesArray.set(slot, outlineLine)
        pbsNoop()
    else
        line.set_xy1(outlineLine, firstBar, firstPrice)
        line.set_xy2(outlineLine, lastBar, lastPrice)
        line.set_color(outlineLine, usedColor)
        line.set_width(outlineLine, pbsFormationWidthInput)
        pbsNoop()
    line.set_style(outlineLine, previous ? line.style_dashed : line.style_solid)
    pbsNoop()

pbsFormFillUpdate(PbsFormDraw drawing, int slot, int firstLine, int secondLine, color usedColor) =>
    linefill shadingFill = drawing.fillsArray.get(slot)
    if na(shadingFill)
        shadingFill := linefill.new(drawing.linesArray.get(firstLine), drawing.linesArray.get(secondLine), usedColor)
        drawing.fillsArray.set(slot, shadingFill)
        pbsNoop()
    else
        linefill.set_color(shadingFill, usedColor)
        pbsNoop()
    pbsNoop()

pbsFormPolygonUpdate(PbsFormDraw drawing, int slot, int firstBar, float firstPrice, int middleBar, float middlePrice, int lastBar, float lastPrice, color fillColor) =>
    if na(drawing.polygonsArray.get(slot))
        array<chart.point> verticesArray = array.from(
             chart.point.from_index(firstBar, firstPrice),
             chart.point.from_index(middleBar, middlePrice),
             chart.point.from_index(lastBar, lastPrice))
        drawing.polygonsArray.set(slot, polyline.new(verticesArray, curved = false, closed = true, xloc = xloc.bar_index,
             line_color = color.new(pbsFormationColorInput, 100), fill_color = fillColor))
        pbsNoop()
    pbsNoop()

pbsRenderForm(PbsFormDraw drawing, PbsForm form, bool previous) =>
    if not pbsFormReachOk(form)
        if drawing.key != ""
            pbsClearForm(drawing)
        pbsNoop()
    else
        if drawing.key != form.key
            pbsClearForm(drawing)
            drawing.key := form.key
        color usedColor = previous ? color.new(color.gray, 45) : pbsFormationColorInput
        if form.kind == FORM_LINE or form.kind == FORM_PAIR
            pbsFormLineUpdate(drawing, 0, form.boundaryBar, form.upperStart, form.rightBar, form.upperEnd, usedColor, previous)
            if form.kind == FORM_PAIR
                pbsFormLineUpdate(drawing, 1, form.boundaryBar, form.lowerStart, form.rightBar, form.lowerEnd, usedColor, previous)
        else
            pbsFormLineUpdate(drawing, 0, form.anchor1, form.price1, form.anchor2, form.price2, usedColor, previous)
            pbsFormLineUpdate(drawing, 1, form.anchor2, form.price2, form.anchor3, form.price3, usedColor, previous)
            if form.kind == FORM_SHOULDERS
                pbsFormLineUpdate(drawing, 2, form.anchor3, form.price3, form.anchor4, form.price4, usedColor, previous)
                pbsFormLineUpdate(drawing, 3, form.anchor4, form.price4, form.anchor5, form.price5, usedColor, previous)
                pbsFormLineUpdate(drawing, 4, form.boundaryBar, form.upperStart, form.rightBar, form.upperEnd, usedColor, previous)
            else
                pbsFormLineUpdate(drawing, 2, form.boundaryBar, form.upperStart, form.rightBar, form.upperEnd, usedColor, previous)
        if not previous and pbsFillInput and form.kind != FORM_LINE
            color fillColor = color.new(pbsFormationColorInput, pbsFillTransparencyInput)
            if form.kind == FORM_PAIR
                pbsFormFillUpdate(drawing, 0, 0, 1, fillColor)
            else
                // Separate three-point polygons cannot self-cross across both shoulders.
                pbsFormPolygonUpdate(drawing, 0, form.anchor1, form.price1, form.anchor2, form.price2,
                     form.anchor3, form.price3, fillColor)
                if form.kind == FORM_SHOULDERS
                    pbsFormPolygonUpdate(drawing, 1, form.anchor3, form.price3, form.anchor4, form.price4,
                         form.anchor5, form.price5, fillColor)
        string formationName = pbsFamilyText(form.name, "CACP")
        if na(drawing.nameLabel)
            drawing.nameLabel := label.new(form.rightBar, form.upperEnd, formationName, xloc = xloc.bar_index,
                 yloc = yloc.price, style = label.style_label_lower_right, color = color.new(chart.bg_color, 0),
                 textcolor = previous ? color.gray : usedColor, size = size.small, tooltip = formationName)
            pbsNoop()
        else
            label.set_xy(drawing.nameLabel, form.rightBar, form.upperEnd)
            label.set_text(drawing.nameLabel, formationName)
            label.set_tooltip(drawing.nameLabel, formationName)
            label.set_textcolor(drawing.nameLabel, previous ? color.gray : usedColor)
            pbsNoop()
        pbsNoop()
    pbsNoop()

pbsDisplayPlans() =>
    int count = math.min(pbsPreviousCountInput, pbsPlans.size())
    array<PbsPlan> selectedPlansArray = array.new<PbsPlan>()
    if count > 0
        for index = pbsPlans.size() - count to pbsPlans.size() - 1
            PbsPlan plan = pbsPlans.get(index)
            if pbsFormReachOk(plan.primaryForm)
                selectedPlansArray.push(plan)
    selectedPlansArray

pbsRenderSignals(array<PbsPlan> selectedPlansArray, bool visible) =>
    array<int> wantedBarsArray = array.new<int>()
    if visible
        for plan in selectedPlansArray
            wantedBarsArray.push(plan.bar)
    for plan in pbsPlans
        if not wantedBarsArray.includes(plan.bar)
            label.delete(plan.signalLabel)
            plan.signalLabel := na
    if visible
        for plan in selectedPlansArray
            if na(plan.signalLabel)
                plan.signalLabel := label.new(plan.bar, plan.markerPrice, "",
                     yloc = yloc.price,
                     color = plan.dir == 1 ? pbsLongColor : pbsShortColor,
                     style = plan.dir == 1 ? label.style_triangleup : label.style_triangledown, size = size.tiny,
                     tooltip = plan.formationName)
    pbsNoop()

pbsRenderPrevious(array<PbsPlan> selectedPlansArray, bool visible) =>
    array<int> wantedBarsArray = array.new<int>()
    array<PbsForm> wantedFormsArray = array.new<PbsForm>()
    if visible
        for plan in selectedPlansArray
            wantedBarsArray.push(plan.bar)
            wantedFormsArray.push(plan.primaryForm)
    // Free every outgoing drawing before any replacement allocates chart objects.
    if pbsPreviousDrawingsArray.size() > 0
        for index = pbsPreviousDrawingsArray.size() - 1 to 0
            PbsFormDraw drawing = pbsPreviousDrawingsArray.get(index)
            if not wantedBarsArray.includes(drawing.signalBar)
                pbsClearForm(drawing)
                pbsPreviousDrawingsArray.remove(index)
                pbsNoop()
    for index = 0 to (wantedBarsArray.size() > 0 ? wantedBarsArray.size() - 1 : na)
        int signalBar = wantedBarsArray.get(index)
        PbsFormDraw drawing = na
        for held in pbsPreviousDrawingsArray
            if held.signalBar == signalBar
                drawing := held
                break
        if na(drawing)
            drawing := pbsNewFormDrawing()
            drawing.signalBar := signalBar
            pbsPreviousDrawingsArray.push(drawing)
        pbsRenderForm(drawing, wantedFormsArray.get(index), true)
    pbsNoop()

// Seed IDs on the last confirmed historical bar; retain them on live last-bar executions.
if barstate.islastconfirmedhistory or barstate.islast
    array<PbsPlan> selectedPlansArray = pbsDisplayPlans()
    bool signalsVisible = pbsShowSignals and pbsSupported and pbsFailures.size() == 0
    bool formationsVisible = pbsShowFormationsInput and pbsSupported and pbsFailures.size() == 0
    pbsRenderSignals(selectedPlansArray, signalsVisible)
    pbsRenderForm(pbsActiveDrawing, formationsVisible ? pbsActiveForm : na, false)
    pbsRenderPrevious(selectedPlansArray, formationsVisible and pbsPreviousInput)

// Status and method table

string pbsPanelPosition = switch pbsPanelPositionInput
    "Bottom left" => position.bottom_left
    "Top right"   => position.top_right
    "Top left"    => position.top_left
    => position.bottom_right
string pbsTableSize = switch pbsTableSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    "Large" => size.large
    => size.small
var table pbsPanel = table.new(pbsPanelPosition, 4, 15, bgcolor = na,
     border_color = color.from_gradient(20, 0, 100, color.new(chart.bg_color, 0), color.new(chart.fg_color, 0)), border_width = 0,
     frame_color = color.from_gradient(45, 0, 100, color.new(chart.bg_color, 0), color.new(chart.fg_color, 0)), frame_width = 0)

pbsTableText(string value) =>
    string wrapped = ""
    array<string> paragraphsArray = str.split(value, "\n")
    for paragraphIndex = 0 to (paragraphsArray.size() > 0 ? paragraphsArray.size() - 1 : na)
        if paragraphIndex > 0
            wrapped += "\n"
        string paragraph = ""
        int used = 0
        for word in str.split(paragraphsArray.get(paragraphIndex), " ")
            bool nextLine = used > 0 and used + 1 + str.length(word) > 24
            paragraph += (paragraph == "" ? "" : nextLine ? "\n" : " ") + word
            used := nextLine or used == 0 ? str.length(word) : used + 1 + str.length(word)
        wrapped += paragraph
    wrapped

pbsTableClearance() =>
    int leftLines = pbsTableSizeInput == "Tiny" ? 14 : 10
    pbsPanelPositionInput == "Top left" ? leftLines : pbsPanelPositionInput == "Top right" ? 2 : 0

pbsLengthNotice(string name, int strength) =>
    int required = math.max(2 * strength + 1, strength + atlnMinSpan)
    atlnHorizon < required ? "Trendline " + name + " length: Bars to apply needs " + str.tostring(required) +
         " for pivot pairs." : ""

pbsConfigNotice() =>
    string notice = ""
    if atlnOn
        notice := pbsLengthNotice("Short", atlnShortLen)
        if atlnTiers
            string middle = pbsLengthNotice("Middle", atlnMidLen)
            string longest = pbsLengthNotice("Long", atlnLongLen)
            if middle != ""
                notice += (notice == "" ? "" : "\n") + middle
            if longest != ""
                notice += (notice == "" ? "" : "\n") + longest
    int channelRequired = 3 * atchSwing * atchMultiple + 1
    if atchOn and atchLonger and atchHorizon < channelRequired
        notice += (notice == "" ? "" : "\n") + "Longer channel: Search and age horizon needs " +
             str.tostring(channelRequired) + " for a break."
    if notice != ""
        notice += "\nIncrease the named horizon or reduce swing/span settings."
    notice

pbsTableCell(int column, int row, string value, color background, bool field, bool footer = false, bool latestHeading = false, color valueColor = na) =>
    string shown = field ? value : pbsTableText(value)
    int tableRow = row + (pbsTableClearance() > 0 ? 1 : 0)
    if footer and pbsPanelPositionInput == "Bottom left"
        shown += pbsPanelLayoutInput == "Compact" and pbsShowTable ? "\n" : "\n\n"
    pbsPanel.cell(column, tableRow, shown, text_color = na(valueColor) ? chart.fg_color : valueColor, text_size = pbsTableSize,
         text_halign = text.align_left, bgcolor = background,
         text_font_family = field ? font.family_default : font.family_monospace,
         text_formatting = field or latestHeading ? text.format_bold : text.format_none)

pbsTableField(int row, string value, bool footer = false) =>
    color spineColor = color.from_gradient(7, 0, 100, color.new(chart.bg_color, 0), color.new(chart.fg_color, 0))
    pbsTableCell(0, row, value, spineColor, true, footer)

pbsTableData(int column, int row, string value, bool footer = false, color valueColor = na) =>
    pbsTableCell(column, row, value, color.new(chart.bg_color, 0), false, footer, valueColor = valueColor)

if barstate.islast
    string warning = not pbsSupported ? "Unsupported chart:\nstandard time-based bars required." :
         pbsFailures.size() > 0 ? "Signals stopped:\n" + pbsChartText(pbsFailures.first()) + ".\nNo further signals computed." :
         na(pbsAtrPrior) ? "Warming up:\nplan ATR unavailable." : ""
    string configNotice = pbsConfigNotice()
    bool setupShown = warning == "" and configNotice != ""
    pbsPanel.clear(0, 0, 3, 14)
    bool tableVisible = warning != "" or setupShown or pbsShowTable
    int clearance = pbsTableClearance()
    // Top spacers have no rules; opaque content cells meet without border gaps.
    pbsPanel.set_frame_width(clearance > 0 ? 0 : 1)
    pbsPanel.set_border_width(clearance > 0 ? 0 : 1)
    pbsPanel.set_frame_color(tableVisible ? color.from_gradient(45, 0, 100, color.new(chart.bg_color, 0), color.new(chart.fg_color, 0)) : na)
    pbsPanel.set_border_color(tableVisible ? color.from_gradient(20, 0, 100, color.new(chart.bg_color, 0), color.new(chart.fg_color, 0)) : na)
    if tableVisible and clearance > 0
        // Separate transparent clearance from every opaque heading or required message.
        pbsPanel.cell(0, 0, str.repeat("\n", clearance - 1), text_size = pbsTableSize, bgcolor = na)
    if warning != ""
        pbsTableField(0, "Warning", true)
        pbsTableData(1, 0, warning, true)
    else if pbsShowTable
        if pbsPlans.size() > 0
            int count = math.min(pbsTableRecordsInput, pbsPlans.size())
            for column = 1 to count
                PbsPlan record = pbsPlans.get(pbsPlans.size() - count + column - 1)
                bool compactInput = pbsPanelLayoutInput == "Compact"
                int row = 0
                string heading = column == count ? "Latest signal" : "Previous signal"
                if compactInput
                    heading := (column == count ? "Latest" : "Prior") + " " + (record.dir == 1 ? "Long" : "Short") +
                         (pbsShowSignals ? " " + pbsGrade(record.score) : "") + (pbsShowLevels ? " " + pbsModel : "")
                if column == 1
                    pbsTableField(row, compactInput ? "Signal" + (pbsShowSignals ? "/grade" : "") + (pbsShowLevels ? "/model" : "") : "Signal")
                pbsTableCell(column, row, heading,
                     color.from_gradient(20, 0, 100, color.new(chart.bg_color, 0),
                          color.new(record.dir == 1 ? pbsLongColor : pbsShortColor, 0)), false, false, column == count)
                row += 1
                if column == 1
                    pbsTableField(row, "Structure")
                pbsTableData(column, row, record.structure)
                row += 1
                int age = bar_index - record.bar
                string spanState = record.state == "Active" and age < pbsExtent ? "Lines growing" : "Line span ended"
                if column == 1
                    pbsTableField(row, compactInput ? "Closed/bars (UTC)" : "Closed (UTC)", compactInput and not pbsShowLevels and not setupShown)
                string closeText = compactInput ? str.format_time(record.closeTime, "yyyy-MM-dd HH:mm", "UTC") + " · " + str.tostring(age) + "b" :
                     str.format_time(record.closeTime, "yyyy-MM-dd\nHH:mm:ss", "UTC")
                pbsTableData(column, row, closeText, compactInput and not pbsShowLevels and not setupShown)
                row += 1
                if not compactInput
                    if column == 1
                        pbsTableField(row, "Side")
                    pbsTableData(column, row, record.dir == 1 ? "Long" : "Short")
                    row += 1
                if pbsShowSignals and not compactInput
                    if column == 1
                        pbsTableField(row, "Technical grade")
                    pbsTableData(column, row, pbsGrade(record.score))
                    row += 1
                if pbsShowLevels
                    if column == 1
                        pbsTableField(row, "Entry")
                    pbsTableData(column, row, pbsEntryText(record.entry))
                    row += 1
                    if column == 1
                        pbsTableField(row, "Stop")
                    pbsTableData(column, row, pbsPrice(record.stop), valueColor = record.state == "Stop reached" ? STOP_REACHED_COLOR : chart.fg_color)
                    row += 1
                    if column == 1
                        pbsTableField(row, "T1 (" + pbsNum(pbsTarget1RInput) + "R)")
                    pbsTableData(column, row, pbsPrice(record.target1) + (record.reached1 ? " ✓" : ""), valueColor = record.reached1 ? TARGET_REACHED_COLOR : chart.fg_color)
                    row += 1
                    if column == 1
                        pbsTableField(row, "T2 (" + pbsNum(pbsTargetR) + "R)")
                    pbsTableData(column, row, pbsPrice(record.target) + (record.reached2 ? " ✓" : ""), valueColor = record.reached2 ? TARGET_REACHED_COLOR : chart.fg_color)
                    row += 1
                    if column == 1
                        pbsTableField(row, "T3 (" + pbsNum(pbsTarget3RInput) + "R)", compactInput and not setupShown)
                    pbsTableData(column, row, pbsPrice(record.target3) + (record.reached3 ? " ✓" : ""), compactInput and not setupShown, valueColor = record.reached3 ? TARGET_REACHED_COLOR : chart.fg_color)
                    row += 1
                    if not compactInput
                        if column == 1
                            pbsTableField(row, "Stop model")
                        pbsTableData(column, row, pbsModel + " · Prior-bar ATR")
                        row += 1
                if not compactInput
                    string ageText = str.tostring(age) + " bars"
                    if pbsShowLevels and column == count
                        ageText += "\n" + spanState
                    if column == 1
                        pbsTableField(row, "Age", not setupShown)
                    pbsTableData(column, row, ageText, not setupShown)
        else
            pbsTableField(0, "Signal", not setupShown)
            pbsTableData(1, 0, pbsHadSignal ? "No retained signal" : "No signal yet", not setupShown)
    if setupShown
        int setupRow = pbsShowTable and pbsPlans.size() > 0 ?
             (pbsPanelLayoutInput == "Compact" ? 3 + (pbsShowLevels ? 5 : 0) : 5 + (pbsShowSignals ? 1 : 0) + (pbsShowLevels ? 6 : 0)) :
             pbsShowTable ? 1 : 0
        int setupColumns = pbsShowTable and pbsPlans.size() > 0 ? math.min(pbsTableRecordsInput, pbsPlans.size()) : 1
        pbsTableField(setupRow, "Setup", true)
        for column = 1 to setupColumns
            pbsTableData(column, setupRow, column == 1 ? configNotice : "", true)
````
