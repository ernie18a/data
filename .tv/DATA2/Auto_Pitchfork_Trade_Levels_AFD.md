<!-- tradingview-pine-id: PUB;0ed1adb81cc2453ea8e619d58181bd40 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Auto Pitchfork + Trade Levels [AFD]

Source: https://www.tradingview.com/script/qaZnLWji-Auto-Pitchfork-Trade-Levels-AFD/

## Description

[image]https://www.tradingview.com/x/HiGv9XGx/[/image]
Automatic pitchforks from confirmed swing pivots, with Entry, Stop and up to three targets on every fork. No manual anchors, and no pivot that is still forming.

How it works

Three alternating confirmed pivots, P0, P1 and P2, make a fork once they pass six checks: leg size, leg length, P2 beyond P0, fork width, intact structure, and a confirming close inside the fork. 

Standard, Schiff or Modified Schiff sets where the median line starts. Parallels run through P1 and P2; dotted warning lines sit one median-to-parallel distance further out. A fork ends on a close past a warning line by a small margin, on replacement by a newer valid fork, or by age. Accepted anchors are fixed: a newer fork replaces an old one, never moves it. 

The optional Longer layer runs the same rules at three times the Swing length. Anchor labels carry S or L.

Late by design

A pivot confirms Swing length bars after it prints, so every fork appears after its anchors, and a finished chart shows forks where nothing was drawn at the time. TradingView classes scripts like this as potentially misleading, and this is one. No claim is made about repainting either way.

Trade levels

Entry (the confirming close, on the tick grid) and Stop (beyond P2) freeze when the fork forms. Target basis sets T1 to T3:

Actual stop (R), default: 1R, 2R and 3R from Entry, R being the Entry-to-Stop distance, so the ladder is reproducible from the panel. 

ATR: 1, 2 and 3 times the fork's frozen ATR(14).
Median line: one target, the median itself. 
Structure: the median, then the parallel and warning line on the target side.

The last two are fork lines, so they slope; the panel shows each line's latest value until it is reached or the setup closes. A line already behind Entry at formation is not a target and shows as a dash. With none left, the setup reads Levels Unavailable.

On the chart

Green bands from Entry through the targets, a red band from Entry to Stop; wedges under a sloped basis. 

A confirmed bar reaching a level marks it reached, with price and time, and clears its drawings. The last target or the Stop clears the rest. Nothing is counted across setups: no hit rate, no score. An unmarked level has not been reached yet; it is not a failure. 

Touch counts, bars within a fixed ATR band of the median or a parallel, are in the Data Window and the Full and JSON alerts, with their band and bar sample. 

Switching a fork line off hides its drawings, including a sloped target on it. The panel is unchanged.

The panel

Setup and state on top, for example Standard - Long above Closed, T3 Reached, then Entry, Stop and T1 to T3 with their multiples. Closed means level tracking ended, not that an order was closed: there are no orders, positions or sizes here. With both layers on, each gets a column. Before a setup, a note reads insufficient confirmed pivots, waiting for a new confirmed pivot, or the rule the newest candidate failed.

Panel position Auto puts the table on the Entry and Stop side, low for a long setup and high for a short one, where it can cover those tags. The four corners are fixed alternatives.

Alerts

Fork formed, Median reached, Parallel touch, Fork ended, and one batched alert in Brief, Full or JSON, all on confirmed bars. JSON keeps schema 2: target is T2, and r is the legacy capped unit, not the ladder's R.

Good to know

One value comes from another timeframe: the previous closed daily ATR, for an internal cap on intraday charts. It uses lookahead on with a one-bar offset, so it never reads the forming day. 

Geometry is linear in price and bar index, on a log scale too. Readability at extreme zoom is not claimed.

Counts describe this chart's history inside the stated band. Not a forecast. Entry, targets and stop are chart geometry: each target is a fixed multiple of the selected unit, or a fork line itself.

What is original here

Automatic pitchforks are common, and some add Fibonacci ratios, volume or automatic variant choice; this one does not. What it combines: confirmed-only anchors fixed once accepted, a named reason when nothing draws, targets recomputable from the panel or sitting on the fork's own lines, and reached levels recorded but never scored.

Licence

Mozilla Public License 2.0. Auction Foundry.

---

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry

indicator("Auto Pitchfork + Trade Levels [AFD]", "APTL [AFD]", overlay = true, behind_chart = false, max_lines_count = 100, max_labels_count = 80, max_boxes_count = 16, max_bars_back = 5000)

// Draws Standard, Schiff and Modified Schiff pitchforks from three alternating confirmed pivots and counts how many times price has touched each line inside a stated ATR band.
// Pivot ring, lifecycle, line mutation and alert batching adapted from Auction Foundry Auto Trend Channels;
// stop floor and R cap from Classical Auto Chart Patterns; filled level labels and table presentation
// from that script and Auto Harmonic Patterns; level zones and reached-state presentation from
// Classical Auto Chart Patterns; touch wording from Auto Trendlines.
// Linear-price geometry. A fork is drawn from alternating confirmed pivots, the swing length in bars after P2.

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const string G_DETECT    = "Detection"
const string G_FORK      = "Fork"
const string G_LIFECYCLE = "Lifecycle"
const string G_TRADE     = "Trade levels"
const string G_DISPLAY   = "Display"
const string G_ALERTS    = "Alerts"

const string VARIANT_STANDARD_NAME = "Standard"
const string VARIANT_SCHIFF_NAME   = "Schiff"
const string VARIANT_MODIFIED_NAME = "Modified Schiff"
const int VARIANT_STANDARD         = 0
const int VARIANT_SCHIFF           = 1
const int VARIANT_MODIFIED         = 2

const string BASIS_STOP_NAME = "Actual stop (R)"
const string BASIS_ATR_NAME = "ATR"
const string BASIS_MEDIAN_NAME = "Median line"
const string BASIS_STRUCTURE_NAME = "Structure"
const int BASIS_STOP = 0
const int BASIS_ATR = 1
const int BASIS_MEDIAN = 2
const int BASIS_STRUCTURE = 3
const string BASIS_STOP_TOKEN = "actual_stop"
const string BASIS_ATR_TOKEN = "atr"
const string BASIS_MEDIAN_TOKEN = "median"
const string BASIS_STRUCTURE_TOKEN = "structure"

const string TIES_REJECT    = "Reject ties"
const string TIES_LATEST    = "Latest equal pivot"
const string ANCHORS_LATEST = "Latest triple"
const string ANCHORS_RECENT = "Recent valid triple"

const int KIND_HIGH = 0
const int KIND_LOW  = 1

const int ST_ACTIVE     = 0
const int ST_ENDED      = 1
const int ST_AGED       = 2
const int ST_SUPERSEDED = 3

const int WHY_ABOVE     = 1
const int WHY_BELOW     = 2
const int WHY_AGED      = 3
const int WHY_SUPERSEDE = 4

const int LEVEL_UNAVAILABLE   = -1
const int LEVEL_TRACKING      = 0
const int LEVEL_T3            = 1
const int LEVEL_STOP          = 2
const int LEVEL_ORDER_UNKNOWN = 3
const int LEVEL_FORK_ENDED    = 4

const string BUILD_ID = "APTL-PREPUB-20260921K"

const int EV_FORMED = 0
const int EV_MEDIAN = 1
const int EV_RETURN = 2
const int EV_ENDED  = 3

const string STROKE_SOLID  = "Solid"
const string STROKE_DASHED = "Dashed"
const string STROKE_DOTTED = "Dotted"

const string EVENTS_ALL       = "All events"
const string EVENTS_LIFECYCLE = "Formation and ending"
const string EVENTS_TOUCHES   = "Touches"
const string EVENTS_OFF       = "Off"

const string SIZE_TINY   = "Tiny"
const string SIZE_SMALL  = "Small"
const string SIZE_NORMAL = "Normal"

const string DETAIL_BRIEF = "Brief"
const string DETAIL_FULL  = "Full"
const string DETAIL_JSON  = "JSON"

const string POS_AUTO         = "Auto"
const string POS_TOP_RIGHT    = "Top right"
const string POS_TOP_LEFT     = "Top left"
const string POS_BOTTOM_RIGHT = "Bottom right"
const string POS_BOTTOM_LEFT  = "Bottom left"

const int HORIZON_MAX           = 2000
const int SWING_KEEP            = 3
const int RECENT_SWING_KEEP     = 12
const int RING_SIZE             = HORIZON_MAX + 1
const int RETURN_MARK_CAP       = 12
const int LINE_SLOTS            = 12
const int CONNECTOR_FIRST       = 9
const int LABEL_SLOTS           = 22
const int RING_SLOT_FIRST       = 7
const int MARK_SLOT_FIRST       = 10
const int SETUP_LINE_SLOTS      = 12
const int SETUP_LABEL_SLOTS     = 5
const int SETUP_BOX_SLOTS       = 4
const int SETUP_FILL_SLOTS      = 3
const int SETUP_CONNECTOR_FIRST = 5
const int SETUP_FLOOR_FIRST     = 10
const int ZONE_FILL_TRANSP      = 68
const int ZONE_BORDER_TRANSP    = 18
const int FLOOR_EDGE_TRANSP     = 100
const int TABLE_REACHED_TRANSP  = 20
const int PANEL_ROWS            = 9
const int ALERT_INTERVAL_MS     = 15000
const int ALERT_QUEUE_CHARS     = 24000
const int ALERT_QUEUE_EVENTS    = 64
const int R_CAP_ATR_LEN         = 14
const int DRAW_MAX_BACK         = 4500
const float STRUCT_STOP_FLOOR_R = 0.5
const string RETURN_GLYPH       = "◇"
const string PIVOT_GLYPH        = "○"

const string DISCLOSURE = "Counts describe this chart's history inside the stated band. Not a forecast. Entry, targets and stop are chart geometry: each target is a fixed multiple of the selected unit, or a fork line itself."

const int LONGER_MULTIPLE           = 3
const int PIVOT_HORIZON             = 500
const int VOLATILITY_LENGTH         = 14
const float MIN_LEG_ATR             = 1.0
const float STRUCTURE_TOLERANCE_ATR = 0.10
const float MIN_WIDTH_ATR           = 0.50
const float MAX_WIDTH_ATR           = 8.0
const float TOUCH_BAND_ATR          = 0.25
const int TOUCH_GAP_BARS            = 3
const float ENDED_ALLOWANCE_ATR     = 0.10
const int AGE_OUT_BARS              = 400
const float STOP_BEYOND_ATR         = 0.10
const float R_CAP_ATR_MULTIPLE      = 6.0
const float TARGET_1_R              = 1.0
const float TARGET_2_R              = 2.0
const float TARGET_3_R              = 3.0
const float LABEL_SPACING_ATR       = 0.25
const bool SHOW_WARNING_LINES       = true
const bool SHOW_INNER_PARALLELS         = false

const color GUIDE_DARK        = #7D8896
const color GUIDE_LIGHT       = #55606E
const color TOUCH_DARK        = #E0A04A
const color TOUCH_LIGHT       = #A66308
const color LEVEL_GREEN_DARK  = #225E39
const color LEVEL_GREEN_LIGHT = #267A46
const color LEVEL_RED_DARK    = #963A45
const color LEVEL_RED_LIGHT   = #B33B49
const color LEVEL_TEXT        = #FFFFFF

const color INK_DARK    = #C7CFD9
const color INK_LIGHT   = #1A212B
const color FILL_DARK   = #0E1218
const color FILL_LIGHT  = #FFFFFF
const color FRAME_DARK  = #2A323D
const color FRAME_LIGHT = #D5DAE0
const color PLOT_TINT   = #26A69A

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────

int swingInput      = input.int(5, "Swing length", minval = 2, maxval = 30, group = G_DETECT, tooltip = "• Bars needed on each side of a pivot.\n• Higher values select larger swings and delay confirmation.\n• A fork appears this many bars after its third pivot.", display = display.none)
bool longerInput    = input.bool(false, "Longer layer", group = G_DETECT, tooltip = "• Adds a second fork on the same timeframe.\n• Uses three times the Swing length, with its own pivots and levels.")
string equalInput   = input.string(TIES_REJECT, "Equal-price pivots", options = [TIES_REJECT, TIES_LATEST], group = G_DETECT, tooltip = "• Reject ties: requires strict highs or lows on both sides.\n• Latest equal pivot: allows earlier equals; later bars must be lower for highs, higher for lows.\n• Confirmation delay is unchanged.", display = display.none)
string anchorsInput = input.string(ANCHORS_LATEST, "Anchor selection", options = [ANCHORS_LATEST, ANCHORS_RECENT], group = G_DETECT, tooltip = "• Latest triple: checks the newest three alternating pivots.\n• Recent valid triple: searches up to 12 pivots from the last 500 bars, newest first.\n• The newest pivot stays third; the same shape rules apply.", display = display.none)

string variantInput = input.string(VARIANT_STANDARD_NAME, "Variant", options = [VARIANT_STANDARD_NAME, VARIANT_SCHIFF_NAME, VARIANT_MODIFIED_NAME], group = G_FORK, tooltip = "• Standard: starts the center line at the first pivot.\n• Schiff: keeps that starting bar but moves its price halfway toward the second pivot.\n• Modified Schiff: moves the start halfway toward the second pivot in both price and bars.\n• All three: draw the center line through the midpoint of the last two pivots.", display = display.none)
bool upperInput     = input.bool(true, "Upper parallel", group = G_FORK, tooltip = "• Shows the upper parallel, the fork line through P1.\n• Active forks also show its tag, leader, dotted warning line and touch marks.\n• The warning line is one center-to-parallel distance above the upper parallel.\n• Off hides these drawings; calculations continue.")
bool medianInput    = input.bool(true, "Median line", group = G_FORK, tooltip = "• Shows the center line, tag, leader and touch marks.\n• Off hides these drawings; calculations continue.")
bool lowerInput     = input.bool(true, "Lower parallel", group = G_FORK, tooltip = "• Shows the lower parallel, the fork line through P2.\n• Active forks also show its tag, leader, dotted warning line and touch marks.\n• The warning line is one center-to-parallel distance below the lower parallel.\n• Off hides these drawings; calculations continue.")
int retainedInput   = input.int(2, "Retained ended forks", minval = 0, maxval = 5, group = G_LIFECYCLE, tooltip = "• Number of ended forks kept across both layers, newest first.\n• Retention keeps a fork's geometry on the chart; it does not keep its setup open.\n• A setup closes with its fork either way, and its level drawings clear then.", display = display.none)

bool levelsInput = input.bool(true, "Show Entry, Stop and Targets", group = G_TRADE, tooltip = "• Shows Entry, Stop, targets and zones while the setup is open, plus table prices.\n• Under a frozen basis the targets are 1, 2 and 3 units from Entry; under a sloped one they are fork lines, and there may be fewer than three.\n• A reached target clears its own drawings; the Stop, or the last target the setup carries, clears them all.\n• A setup closes when its fork ends or ages out, and its drawings clear with it.\n• Tracking continues when hidden.")
string basisInput = input.string(BASIS_STOP_NAME, "Target basis", options = [BASIS_STOP_NAME, BASIS_ATR_NAME, BASIS_MEDIAN_NAME, BASIS_STRUCTURE_NAME], group = G_TRADE, tooltip = "• Actual stop (R): one unit is the frozen Entry-to-Stop distance, so T1 sits a stop away.\n• ATR: one unit is the fork's frozen 14-bar average true range, independent of the stop.\n• Under either, the ladder is 1, 2 and 3 units from Entry, frozen when the fork forms.\n• Median line: the single target is the fork's median line, so it slopes with the fork.\n• Structure: T1 the median, then the parallel and the warning line on the side the setup is heading toward; those slope with the fork too.\n• A sloped target fixes on the bar that reaches it, or on the bar the setup closes, and does not move again.\n• A sloped line already behind Entry when the fork formed is not a target, and the setup carries fewer tiers or none at all.\n• This is a chart input, so changing it rebuilds every fork and setup under the new basis.", active = levelsInput, display = display.none)

color forkInput      = input.color(#5A8DFF, "Pitchfork color", group = G_DISPLAY, tooltip = "• Color and transparency of active fork lines, pivot marks and fork tags.\n• Ended forks keep their muted color.", display = display.none)
string strokeInput   = input.string(STROKE_SOLID, "Pitchfork line style", options = [STROKE_SOLID, STROKE_DASHED, STROKE_DOTTED], group = G_DISPLAY, tooltip = "• Solid, Dashed or Dotted fork lines and handle.\n• Warning lines stay dotted; level lines stay solid.", display = display.none)
int widthInput       = input.int(2, "Line width", minval = 1, maxval = 4, group = G_DISPLAY, tooltip = "• Width of the active parallels, from 1 to 4.\n• The center line is one step thicker; handles and ended forks stay at 1.", display = display.none)
bool labelsInput     = input.bool(true, "Labels", group = G_DISPLAY, tooltip = "• Shows pivot names, the live fork’s caption, right-side tags and touch marks.\n• Off hides labels and leaders; lines and zones keep their settings.\n• Ended forks carry no caption; right-side tags have no hover text.\n• Entry, Stop and target prices appear when Panel and levels are on.")
int labelInsetInput  = input.int(2, "Label inset (bars)", minval = 1, maxval = 50, group = G_DISPLAY, active = labelsInput, tooltip = "• Gap in bars from the latest candle to the tag column.\n• Larger values need more blank space on the chart’s right side.\n• Dotted leaders connect tags to their exact prices.", display = display.none)
bool panelInput      = input.bool(true, "Panel", group = G_DISPLAY, tooltip = "• Shows each layer’s latest setup direction, tracking status and reached times.\n• Times use the exchange timezone; same-bar Stop/target order is unknown.\n• Results stay until a newer fork replaces them.\n• Off hides setup rows; notices remain visible.")
string positionInput = input.string(POS_AUTO, "Panel position", options = [POS_AUTO, POS_TOP_RIGHT, POS_TOP_LEFT, POS_BOTTOM_RIGHT, POS_BOTTOM_LEFT], group = G_DISPLAY, active = panelInput, tooltip = "• Auto places the table low for a long setup and high for a short one, on the Entry and Stop side rather than the targets.\n• The four corners anchor the table there whatever the setup does.\n• A fixed top corner can cover the level tags when the setup is long.\n• Top-left placement may overlap the chart’s symbol and indicator names.", display = display.none)
string textSizeInput = input.string(SIZE_SMALL, "Text size", options = [SIZE_TINY, SIZE_SMALL, SIZE_NORMAL], group = G_DISPLAY, tooltip = "• Tiny, Small or Normal text for labels and the table.\n• Larger text needs more chart space.", display = display.none)

string alertEventsInput = input.string(EVENTS_ALL, "Alert events", options = [EVENTS_ALL, EVENTS_LIFECYCLE, EVENTS_TOUCHES, EVENTS_OFF], group = G_ALERTS, tooltip = "• All events: formation, ending and touches.\n• Formation and ending: includes replacement and age expiry.\n• Touches: first center-line reach and counted line touches.\n• Off stops alerts; detection and counting continue.", display = display.none)
string detailInput      = input.string(DETAIL_BRIEF, "Detail", options = [DETAIL_BRIEF, DETAIL_FULL, DETAIL_JSON], group = G_ALERTS, tooltip = "• Brief: fork identity and event time. Full: adds prices and touch counts.\n• JSON: structured events with build, settings and dropped-event count.\n• Batches are at least 15 seconds apart, sent on confirmed realtime bars; pending events may wait across sessions.\n• Existing alerts keep their saved code and settings.", display = display.none)

bool formedAlertInput = alertEventsInput == EVENTS_ALL or alertEventsInput == EVENTS_LIFECYCLE
bool endedAlertInput  = formedAlertInput
bool medianAlertInput = alertEventsInput == EVENTS_ALL or alertEventsInput == EVENTS_TOUCHES
bool returnAlertInput = medianAlertInput

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

type BarData
    int index
    int stamp
    float hi
    float lo
    float last
    bool valid

type Pivot
    int index
    int stamp
    float price
    int kind

type Layer
    array<Pivot> swingsArray
    int examined = 0
    string newestReason = ""

type Span
    float hi
    float lo
    bool valid

type Fork
    int side
    int layer
    int variant
    Pivot p0
    Pivot p1
    Pivot p2
    float oBar
    float oPrice
    float slope
    float dUp
    float dDn
    float volatility
    int available
    float entry
    float r
    float stop
    float target
    float target1
    float target3
    int basis
    string key
    bool p1Upper
    array<int> countsArray
    array<int> lastArray
    array<int> markBarsArray
    array<int> markLinesArray
    array<bool> tiersArray
    int state = 0
    int why = 0
    int endBar = -1
    bool tradeReady = false

type Setup
    Fork fork
    int formedTime
    float tolerance
    array<int> reachedTimesArray
    array<bool> ambiguousArray
    array<int> reachedBarsArray
    int settledBar = na
    int stopTime = na
    bool stopAmbiguous = false
    int state = 0

type SetupDrawing
    Setup setup
    array<line> linesArray
    array<label> labelsArray
    array<box> boxesArray
    array<linefill> fillsArray

type Drawing
    Fork fork
    array<line> linesArray
    array<label> labelsArray

type Tag
    array<line> linesArray
    array<label> labelsArray
    int slot
    int connectorSlot
    int layer
    int role
    float price
    color tint

// ─────────────────────────────────────────────────────────────────────────────
// Functions
// ─────────────────────────────────────────────────────────────────────────────

// ── Naming
layerName(int layer) =>
    layer == 0 ? "Swing" : "Longer"

sideWord(int side) =>
    side == 1 ? "up" : "down"

variantName(int variantCode) =>
    variantCode == VARIANT_SCHIFF ? VARIANT_SCHIFF_NAME : variantCode == VARIANT_MODIFIED ? VARIANT_MODIFIED_NAME : VARIANT_STANDARD_NAME

variantCodeOf(string chosen) =>
    chosen == VARIANT_SCHIFF_NAME ? VARIANT_SCHIFF : chosen == VARIANT_MODIFIED_NAME ? VARIANT_MODIFIED : VARIANT_STANDARD

basisName(int basisCode) =>
    basisCode == BASIS_ATR ? BASIS_ATR_NAME : basisCode == BASIS_MEDIAN ? BASIS_MEDIAN_NAME : basisCode == BASIS_STRUCTURE ? BASIS_STRUCTURE_NAME : BASIS_STOP_NAME

basisCodeOf(string chosen) =>
    chosen == BASIS_ATR_NAME ? BASIS_ATR : chosen == BASIS_MEDIAN_NAME ? BASIS_MEDIAN : chosen == BASIS_STRUCTURE_NAME ? BASIS_STRUCTURE : BASIS_STOP

basisToken(int basisCode) =>
    basisCode == BASIS_ATR ? BASIS_ATR_TOKEN : basisCode == BASIS_MEDIAN ? BASIS_MEDIAN_TOKEN : basisCode == BASIS_STRUCTURE ? BASIS_STRUCTURE_TOKEN : BASIS_STOP_TOKEN

basisSloped(int basisCode) =>
    basisCode == BASIS_MEDIAN or basisCode == BASIS_STRUCTURE

tierCount(int basisCode) =>
    basisCode == BASIS_MEDIAN ? 1 : 3

basisUnitWord(int basisCode, string times) =>
    basisCode == BASIS_ATR ? times + "ATR(" + str.tostring(VOLATILITY_LENGTH) + ")" : "R"

tierLabel(int basisCode, int tier, string atLeast, string times) =>
    basisSloped(basisCode) ? (tier == 0 ? "Median" : tier == 1 ? "Parallel" : "Warning") : atLeast + str.tostring(tier + 1) + basisUnitWord(basisCode, times)

lineName(int which) =>
    which == 0 ? "Upper" : which == 2 ? "Lower" : "Median"

terminalWord(Fork f) =>
    f.why == WHY_ABOVE ? "Ended above" : f.why == WHY_BELOW ? "Ended below" : f.why == WHY_AGED ? "Aged out" : "Superseded"

forkKey(int layer, int side, Pivot p0, Pivot p1, Pivot p2) =>
    str.tostring(layer) + ":" + str.tostring(side) + ":" + str.tostring(p0.stamp) + ":" + str.tostring(p1.stamp) + ":" + str.tostring(p2.stamp)

// ── Geometry
getBar(array<BarData> ringArray, int index) =>
    BarData result = na
    if index >= 0
        BarData slot = array.get(ringArray, index % RING_SIZE)
        if not na(slot) and slot.index == index
            result := slot
    result

atPrice(float anchorBar, float anchorPrice, float slope, int x) =>
    anchorPrice + slope * (x - anchorBar)

medianAt(Fork f, int x) =>
    atPrice(f.oBar, f.oPrice, f.slope, x)

upperAt(Fork f, int x) =>
    medianAt(f, x) + f.dUp

lowerAt(Fork f, int x) =>
    medianAt(f, x) - f.dDn

warnUpperAt(Fork f, int x) =>
    upperAt(f, x) + f.dUp

warnLowerAt(Fork f, int x) =>
    lowerAt(f, x) - f.dDn

innerUpperAt(Fork f, int x) =>
    medianAt(f, x) + f.dUp / 2.0

innerLowerAt(Fork f, int x) =>
    medianAt(f, x) - f.dDn / 2.0

lineAt(Fork f, int which, int x) =>
    which == 0 ? upperAt(f, x) : which == 2 ? lowerAt(f, x) : medianAt(f, x)

geometryFor(int variantCode, Pivot p0, Pivot p1, Pivot p2) =>
    float oBar = variantCode == VARIANT_MODIFIED ? (p0.index + p1.index) / 2.0 : p0.index * 1.0
    float oPrice = variantCode == VARIANT_STANDARD ? p0.price : (p0.price + p1.price) / 2.0
    float mBar = (p1.index + p2.index) / 2.0
    float mPrice = (p1.price + p2.price) / 2.0
    float slope = (mPrice - oPrice) / (mBar - oBar)
    float t1 = p1.price
    float t2 = atPrice(p2.index * 1.0, p2.price, slope, p1.index)
    float mid = atPrice(oBar, oPrice, slope, p1.index)
    bool p1Upper = t1 >= t2
    float dUp = (p1Upper ? t1 : t2) - mid
    float dDn = mid - (p1Upper ? t2 : t1)
    [oBar, oPrice, slope, dUp, dDn, p1Upper]

// ── Pivots and triples
strictPivot(array<BarData> ringArray, int now, int strength) =>
    Pivot hi = na
    Pivot lo = na
    int centreIndex = now - strength
    if centreIndex - strength >= 0
        BarData centre = getBar(ringArray, centreIndex)
        bool highPivot = not na(centre) and centre.valid
        bool lowPivot = highPivot
        if highPivot
            for index = centreIndex - strength to now
                BarData neighbour = getBar(ringArray, index)
                if na(neighbour) or not neighbour.valid
                    highPivot := false
                    lowPivot := false
                    break
                if index != centreIndex
                    bool olderEqual = equalInput == TIES_LATEST and index < centreIndex
                    highPivot := highPivot and (olderEqual ? centre.hi >= neighbour.hi : centre.hi > neighbour.hi)
                    lowPivot := lowPivot and (olderEqual ? centre.lo <= neighbour.lo : centre.lo < neighbour.lo)
        if highPivot != lowPivot
            if highPivot
                hi := Pivot.new(centreIndex, centre.stamp, centre.hi, KIND_HIGH)
            else
                lo := Pivot.new(centreIndex, centre.stamp, centre.lo, KIND_LOW)
    [hi, lo]

trimSwings(array<Pivot> swingsArray, int now) =>
    while array.size(swingsArray) > 0
        Pivot first = array.get(swingsArray, 0)
        if now - first.index > PIVOT_HORIZON
            array.shift(swingsArray)
        else
            break
    0

updateSwings(array<Pivot> swingsArray, Pivot pivot) =>
    bool entered = true
    int size = array.size(swingsArray)
    Pivot last = na
    if size > 0
        last := array.get(swingsArray, size - 1)
    if not na(last) and last.kind == pivot.kind
        bool beyond = pivot.kind == KIND_LOW ? pivot.price < last.price : pivot.price > last.price
        bool laterEqual = equalInput == TIES_LATEST and pivot.index > last.index and pivot.price == last.price
        if beyond or laterEqual
            array.set(swingsArray, size - 1, pivot)
        else
            entered := false
    else
        array.push(swingsArray, pivot)
    int keep = anchorsInput == ANCHORS_RECENT ? RECENT_SWING_KEEP : SWING_KEEP
    while array.size(swingsArray) > keep
        array.shift(swingsArray)
    entered

intervalSpans(array<BarData> ringArray, array<Pivot> swingsArray) =>
    int count = array.size(swingsArray)
    array<Span> spansArray = array.new<Span>(count * count)
    if count >= 2
        int segment = 0
        Pivot first = array.get(swingsArray, 0)
        Pivot last = array.get(swingsArray, count - 1)
        float hi = na
        float lo = na
        bool valid = true
        for index = first.index to last.index
            BarData bar = getBar(ringArray, index)
            bool good = not na(bar) and bar.valid
            valid := valid and good
            if good
                hi := na(hi) ? bar.hi : math.max(hi, bar.hi)
                lo := na(lo) ? bar.lo : math.min(lo, bar.lo)
            Pivot next = array.get(swingsArray, segment + 1)
            if index == next.index
                array.set(spansArray, segment * count + segment + 1, Span.new(hi, lo, valid))
                if segment < count - 2
                    segment += 1
                    hi := good ? bar.hi : na
                    lo := good ? bar.lo : na
                    valid := good
        for left = 0 to count - 2
            Span combined = array.get(spansArray, left * count + left + 1)
            if left + 2 < count
                for right = left + 2 to count - 1
                    Span adjacent = array.get(spansArray, (right - 1) * count + right)
                    combined := Span.new(math.max(combined.hi, adjacent.hi), math.min(combined.lo, adjacent.lo), combined.valid and adjacent.valid)
                    array.set(spansArray, left * count + right, combined)
    spansArray

structureIntact(Span first, Span secondSpan, int side, Pivot p0, Pivot p1, Pivot p2, float tol) =>
    bool intact = first.valid and secondSpan.valid
    if intact
        float sameFirst = side == 1 ? first.lo : first.hi
        float oppositeFirst = side == 1 ? first.hi : first.lo
        float sameSecond = side == 1 ? secondSpan.lo : secondSpan.hi
        float oppositeSecond = side == 1 ? secondSpan.hi : secondSpan.lo
        intact := side * (p0.price - sameFirst) <= tol and side * (oppositeFirst - p1.price) <= tol and side * (oppositeSecond - p1.price) <= tol and side * (p2.price - sameSecond) <= tol
    intact

bornInside(float oBar, float oPrice, float slope, float dUp, float dDn, int x, float closePrice, float allowance) =>
    float median = atPrice(oBar, oPrice, slope, x)
    bool above = closePrice > median + dUp + dUp + allowance
    bool below = closePrice < median - dDn - dDn - allowance
    not above and not below

tripleReason(Span first, Span secondSpan, int side, Pivot p0, Pivot p1, Pivot p2, float atr, float width, int strength, bool inside) =>
    string reason = ""
    if na(atr) or atr <= 0
        reason := "volatility unavailable"
    else if side * (p1.price - p0.price) < MIN_LEG_ATR * atr or side * (p1.price - p2.price) < MIN_LEG_ATR * atr
        reason := "minimum movement"
    else if p1.index - p0.index < strength or p2.index - p1.index < strength
        reason := "leg length"
    else if side * (p2.price - p0.price) <= 0
        reason := "P2 versus P0"
    else if width < MIN_WIDTH_ATR * atr or width > MAX_WIDTH_ATR * atr
        reason := "width"
    else if not structureIntact(first, secondSpan, side, p0, p1, p2, STRUCTURE_TOLERANCE_ATR * atr)
        reason := "structure or missing data"
    else if not inside
        reason := "construction close"
    reason

selectAnchors(Layer layerData, int strength, array<BarData> ringArray, BarData bar, float atr) =>
    array<Pivot> swingsArray = layerData.swingsArray
    int count = array.size(swingsArray)
    Pivot chosen0 = na
    Pivot chosen1 = na
    layerData.examined := 0
    layerData.newestReason := ""
    if count >= 3
        array<Span> spansArray = intervalSpans(ringArray, swingsArray)
        Pivot p2 = array.get(swingsArray, count - 1)
        int side = p2.kind == KIND_LOW ? 1 : -1
        int p1Index = count - 2
        while p1Index >= 1 and na(chosen0)
            Pivot p1 = array.get(swingsArray, p1Index)
            int p0Index = p1Index - 1
            while p0Index >= 0 and na(chosen0)
                Pivot p0 = array.get(swingsArray, p0Index)
                [oBar, oPrice, slope, dUp, dDn, _] = geometryFor(variantCodeOf(variantInput), p0, p1, p2)
                bool inside = bornInside(oBar, oPrice, slope, dUp, dDn, bar.index, bar.last, ENDED_ALLOWANCE_ATR * atr)
                string reason = tripleReason(array.get(spansArray, p0Index * count + p1Index), array.get(spansArray, p1Index * count + count - 1), side, p0, p1, p2, atr, dUp + dDn, strength, inside)
                layerData.examined += 1
                if layerData.examined == 1
                    layerData.newestReason := reason
                if reason == ""
                    chosen0 := p0
                    chosen1 := p1
                    layerData.newestReason := ""
                if anchorsInput == ANCHORS_LATEST
                    break
                p0Index -= 2
            if anchorsInput == ANCHORS_LATEST
                break
            p1Index -= 2
    [chosen0, chosen1]

// ── Entry, stop and targets
cappedR(float raw, float cap) =>
    na(cap) or cap <= 0.0 ? raw : math.min(raw, cap)

gridPrice(float price) =>
    float mt = syminfo.mintick
    na(price) or na(mt) or mt <= 0 ? price : math.round(price / mt) * mt

outwardLevel(int direction, float entryPrice, float levelPrice) =>
    float mt = syminfo.mintick
    float out = levelPrice
    if not na(mt) and mt > 0
        float bound = direction > 0 ? math.max(levelPrice, entryPrice + mt) : math.min(levelPrice, entryPrice - mt)
        float grid = bound / mt
        float nearest = math.round(grid)
        grid := math.abs(grid - nearest) <= math.max(1e-9, math.abs(grid) * 2e-15, math.abs(entryPrice / mt) * 2e-15) ? nearest : grid
        out := direction > 0 ? math.ceil(grid) * mt : math.floor(grid) * mt
    out

stopFor(int side, float entryPrice, Pivot p2, float atr, float r) =>
    float raw = p2.price - side * STOP_BEYOND_ATR * atr
    float out = entryPrice - side * math.max(side * (entryPrice - raw), STRUCT_STOP_FLOOR_R * r)
    outwardLevel(-side, entryPrice, out)

stopDistance(float entryPrice, float stopPrice) =>
    math.abs(entryPrice - stopPrice)

targetUnit(int basisCode, float entryPrice, float stopPrice, float atr) =>
    basisCode == BASIS_ATR ? atr : stopDistance(entryPrice, stopPrice)

targetFor(int side, float entryPrice, float unit, float multiple) =>
    outwardLevel(side, entryPrice, entryPrice + side * multiple * unit)

slopedTierLine(Fork f, int tier) =>
    tier == 0 ? 1 : f.side == 1 ? 0 : 2

slopedTargetAt(Fork f, int tier, int x) =>
    float out = na
    if tier == 0
        out := medianAt(f, x)
    else if f.basis == BASIS_STRUCTURE
        out := f.side == 1 ? (tier == 1 ? upperAt(f, x) : warnUpperAt(f, x)) : (tier == 1 ? lowerAt(f, x) : warnLowerAt(f, x))
    out

forkTargetAt(Fork f, int tier, int x) =>
    basisSloped(f.basis) ? slopedTargetAt(f, tier, x) : (tier == 0 ? f.target1 : tier == 1 ? f.target : f.target3)

freezeTiers(Fork f, int x) =>
    if basisSloped(f.basis)
        for tier = 0 to 2
            float price = slopedTargetAt(f, tier, x)
            array.set(f.tiersArray, tier, not na(price) and f.side * (price - f.entry) > 0)
    0

tierActive(Fork f, int tier) =>
    array.get(f.tiersArray, tier)

anyTier(Fork f) =>
    array.includes(f.tiersArray, true)

finalTier(Fork f) =>
    int out = -1
    for tier = 0 to 2
        if array.get(f.tiersArray, tier)
            out := tier
    out

// ── Latest level setups
setupTarget(Setup setup, int tier) =>
    tier == 0 ? setup.fork.target1 : tier == 1 ? setup.fork.target : setup.fork.target3

setupTargetAt(Setup setup, int tier, int x) =>
    forkTargetAt(setup.fork, tier, x)

resolvedPosition(string choice, Setup firstSetup) =>
    string out = choice
    if choice == POS_AUTO
        out := na(firstSetup) ? POS_TOP_RIGHT : firstSetup.fork.side == 1 ? POS_BOTTOM_RIGHT : POS_TOP_RIGHT
    out

positionConst(string choice) =>
    choice == POS_TOP_RIGHT ? position.top_right : choice == POS_TOP_LEFT ? position.top_left : choice == POS_BOTTOM_RIGHT ? position.bottom_right : position.bottom_left

newSetup(Fork f, BarData bar) =>
    float tolerance = f.tradeReady ? syminfo.mintick / 2.0 : 0.0
    bool ready = f.tradeReady and anyTier(f)
    Setup.new(f, bar.stamp, tolerance, array.new<int>(3), array.new<bool>(3, false), array.new<int>(3), state = ready ? LEVEL_TRACKING : LEVEL_UNAVAILABLE)

advanceSetup(Setup setup, BarData bar) =>
    if setup.state == LEVEL_TRACKING and bar.valid and bar.index > setup.fork.available
        Fork f = setup.fork
        bool stopped = f.side == 1 ? bar.lo <= f.stop + setup.tolerance : bar.hi >= f.stop - setup.tolerance
        bool newTier = false
        for tier = 0 to 2
            float price = tierActive(f, tier) ? setupTargetAt(setup, tier, bar.index) : na
            bool reached = na(price) ? false : f.side == 1 ? bar.hi >= price - setup.tolerance : bar.lo <= price + setup.tolerance
            if na(array.get(setup.reachedTimesArray, tier)) and reached
                array.set(setup.reachedTimesArray, tier, bar.stamp)
                array.set(setup.reachedBarsArray, tier, bar.index)
                array.set(setup.ambiguousArray, tier, stopped)
                newTier := true
        int last = finalTier(f)
        if stopped
            setup.stopTime := bar.stamp
            setup.stopAmbiguous := newTier
            setup.state := newTier ? LEVEL_ORDER_UNKNOWN : LEVEL_STOP
        else if last >= 0 and not na(array.get(setup.reachedTimesArray, last))
            setup.state := LEVEL_T3
        if setup.state != LEVEL_TRACKING
            setup.settledBar := bar.index
    0

closeSetupWithFork(Setup setup) =>
    if not na(setup) and setup.state == LEVEL_TRACKING and setup.fork.state != ST_ACTIVE
        setup.state := LEVEL_FORK_ENDED
        setup.settledBar := setup.fork.endBar
    0

lineVisible(int which) =>
    which == 0 ? upperInput : which == 1 ? medianInput : lowerInput

setupVisible(Setup setup) =>
    not na(setup) and setup.state == LEVEL_TRACKING and levelsInput

setupLevelVisible(Setup setup, int role) =>
    setupVisible(setup) and (role < 2 or (tierActive(setup.fork, role - 2) and na(array.get(setup.reachedTimesArray, role - 2)) and (not basisSloped(setup.fork.basis) or lineVisible(slopedTierLine(setup.fork, role - 2)))))

floorEdgeNeeded(Fork f, int tier) =>
    tierActive(f, tier) and tier < finalTier(f)

// ── Events
eventName(int kind, Fork f) =>
    kind == EV_FORMED ? "Fork formed" : kind == EV_MEDIAN ? "Median reached" : kind == EV_RETURN ? "Parallel touch" : terminalWord(f)

touchesText(Fork f) =>
    "U " + str.tostring(array.get(f.countsArray, 0)) + " · M " + str.tostring(array.get(f.countsArray, 1)) + " · L " + str.tostring(array.get(f.countsArray, 2))

bandText() =>
    str.tostring(TOUCH_BAND_ATR, "#.##") + "× ATR"

jsonNumber(float value) =>
    na(value) ? "null" : str.tostring(value, "#.###############")

jsonString(string value) =>
    string escaped = str.replace_all(value, "\\", "\\\\")
    escaped := str.replace_all(escaped, "\"", "\\\"")
    escaped := str.replace_all(escaped, "\n", "\\n")
    escaped := str.replace_all(escaped, "\r", "\\r")
    escaped := str.replace_all(escaped, "\t", "\\t")
    "\"" + escaped + "\""

configurationText() =>
    "equalInput=" + equalInput + ";" + "anchorsInput=" + anchorsInput + ";" + "retainedInput=" + str.tostring(retainedInput) + ";" + "swingInput=" + str.tostring(swingInput) + ";" + "longerInput=" + str.tostring(longerInput) + ";" + "multipleInput=" + str.tostring(LONGER_MULTIPLE) + ";" + "horizonInput=" + str.tostring(PIVOT_HORIZON) + ";" + "volatilityInput=" + str.tostring(VOLATILITY_LENGTH) + ";" + "minLegInput=" + str.tostring(MIN_LEG_ATR) + ";" + "tolInput=" + str.tostring(STRUCTURE_TOLERANCE_ATR) + ";" + "minWidthInput=" + str.tostring(MIN_WIDTH_ATR) + ";" + "maxWidthInput=" + str.tostring(MAX_WIDTH_ATR) + ";" + "bandInput=" + str.tostring(TOUCH_BAND_ATR) + ";" + "gapInput=" + str.tostring(TOUCH_GAP_BARS) + ";" + "endedInput=" + str.tostring(ENDED_ALLOWANCE_ATR) + ";" + "ageOutInput=" + str.tostring(AGE_OUT_BARS) + ";" + "stopBeyondInput=" + str.tostring(STOP_BEYOND_ATR) + ";" + "rCapMultInput=" + str.tostring(R_CAP_ATR_MULTIPLE) + ";" + "variantInput=" + variantInput + ";" + "alertEventsInput=" + alertEventsInput + ";" + "formedAlertInput=" + str.tostring(formedAlertInput) + ";" + "medianAlertInput=" + str.tostring(medianAlertInput) + ";" + "returnAlertInput=" + str.tostring(returnAlertInput) + ";" + "endedAlertInput=" + str.tostring(endedAlertInput) + ";" + "detailInput=" + detailInput + ";stopModeInput=Structure;sizingInput=false;targetBasis=" + basisToken(basisCodeOf(basisInput)) + ";target1R=1;target2R=2;target3R=3;legacyTarget=T2;upperInput=" + str.tostring(upperInput) + ";medianInput=" + str.tostring(medianInput) + ";lowerInput=" + str.tostring(lowerInput)

jsonEnvelope(array<string> eventsArray, int dropped) =>
    "{\"schema\":2,\"build\":" + jsonString(BUILD_ID) + ",\"product\":\"Auto Pitchfork + Trade Levels [AFD]\",\"ticker\":" + jsonString(syminfo.tickerid) + ",\"timeframe\":" + jsonString(timeframe.period) + ",\"config\":" + jsonString(configurationText()) + ",\"dropped_events\":" + str.tostring(dropped) + ",\"events\":[" + array.join(eventsArray, ",") + "]}"

eventMessage(int kind, Fork f, BarData bar, int which) =>
    string what = eventName(kind, f) + (kind == EV_RETURN ? " · " + lineName(which) : "")
    string head = layerName(f.layer) + " | " + variantName(f.variant) + " fork · " + sideWord(f.side) + " | " + what + " | " + f.key + " | event bar opened " + str.tostring(bar.stamp)
    string out = head
    if detailInput == DETAIL_FULL
        string unitWord = basisUnitWord(f.basis, "x")
        string tiersText = ""
        for tier = 0 to 2
            tiersText += " | T" + str.tostring(tier + 1) + " " + tierLabel(f.basis, tier, ">=", "x") + " " + (f.tradeReady and tierActive(f, tier) ? str.tostring(forkTargetAt(f, tier, bar.index), format.mintick) : "unavailable")
        string unitText = basisSloped(f.basis) ? " | target basis " + basisName(f.basis) + " (fork lines, no frozen unit)" : " | target unit " + unitWord + " (" + (f.basis == BASIS_ATR ? str.tostring(VOLATILITY_LENGTH) + "-bar average true range" : "actual stop distance") + ") " + (f.tradeReady ? str.tostring(targetUnit(f.basis, f.entry, f.stop, f.volatility), format.mintick) : "unavailable")
        out := head + " | confirmed close of bar opened " + str.format_time(bar.stamp, "yyyy-MM-dd HH:mm:ss", syminfo.timezone) + " " + syminfo.timezone + " | upper " + str.tostring(upperAt(f, bar.index), format.mintick) + " | median " + str.tostring(medianAt(f, bar.index), format.mintick) + " | lower " + str.tostring(lowerAt(f, bar.index), format.mintick) + " | touches " + touchesText(f) + " within " + bandText() + " over " + str.tostring(bar.index - f.available) + " bars | entry " + (f.tradeReady ? str.tostring(f.entry, format.mintick) : "unavailable") + tiersText + " | stop " + (f.tradeReady ? str.tostring(f.stop, format.mintick) : "unavailable") + unitText + " | geometric R " + (f.tradeReady ? str.tostring(f.r, format.mintick) : "unavailable") + " | " + DISCLOSURE
    else if detailInput == DETAIL_JSON
        out := "{\"event\":" + jsonString(eventName(kind, f)) + ",\"key\":" + jsonString(f.key) + ",\"time\":" + str.tostring(bar.stamp) + ",\"confirmed_at\":" + str.tostring(time_close) + ",\"line\":" + jsonString(kind == EV_RETURN ? lineName(which) : "") + ",\"layer\":" + str.tostring(f.layer) + ",\"side\":" + str.tostring(f.side) + ",\"variant\":" + str.tostring(f.variant) + ",\"p0\":" + str.tostring(f.p0.stamp) + ",\"p1\":" + str.tostring(f.p1.stamp) + ",\"p2\":" + str.tostring(f.p2.stamp) + ",\"entry\":" + jsonNumber(f.tradeReady ? f.entry : na) + ",\"target\":" + jsonNumber(f.tradeReady and tierActive(f, 1) ? forkTargetAt(f, 1, bar.index) : na) + ",\"stop\":" + jsonNumber(f.tradeReady ? f.stop : na) + ",\"r\":" + jsonNumber(f.tradeReady ? f.r : na) + ",\"upper\":" + jsonNumber(upperAt(f, bar.index)) + ",\"median\":" + jsonNumber(medianAt(f, bar.index)) + ",\"lower\":" + jsonNumber(lowerAt(f, bar.index)) + ",\"touches_upper\":" + str.tostring(array.get(f.countsArray, 0)) + ",\"touches_median\":" + str.tostring(array.get(f.countsArray, 1)) + ",\"touches_lower\":" + str.tostring(array.get(f.countsArray, 2)) + ",\"sample_bars\":" + str.tostring(bar.index - f.available) + ",\"band_atr\":" + jsonNumber(TOUCH_BAND_ATR) + ",\"note\":" + jsonString(DISCLOSURE) + "}"
    out

recordEvent(int kind, Fork f, BarData bar, int which, array<int> flagsArray, array<string> messagesArray) =>
    array.set(flagsArray, kind, 1)
    bool enabled = kind == EV_FORMED ? formedAlertInput : kind == EV_MEDIAN ? medianAlertInput : kind == EV_RETURN ? returnAlertInput : endedAlertInput
    if enabled
        array.push(messagesArray, eventMessage(kind, f, bar, which))
    0

// ── Lifecycle
countReturns(Fork f, BarData bar, array<int> flagsArray, array<string> messagesArray) =>
    int x = bar.index
    float v = f.volatility
    for which = 0 to 2
        float level = lineAt(f, which, x)
        if bar.lo <= level + TOUCH_BAND_ATR * v and bar.hi >= level - TOUCH_BAND_ATR * v
            int last = array.get(f.lastArray, which)
            if last < 0 or x - last >= TOUCH_GAP_BARS
                int total = array.get(f.countsArray, which) + 1
                array.set(f.countsArray, which, total)
                array.set(f.lastArray, which, x)
                array.push(f.markBarsArray, x)
                array.push(f.markLinesArray, which)
                if array.size(f.markBarsArray) > RETURN_MARK_CAP
                    array.shift(f.markBarsArray)
                    array.shift(f.markLinesArray)
                recordEvent(EV_RETURN, f, bar, which, flagsArray, messagesArray)
                if which == 1 and total == 1
                    recordEvent(EV_MEDIAN, f, bar, -1, flagsArray, messagesArray)
    0

advanceFork(Fork f, BarData bar, array<int> flagsArray, array<string> messagesArray) =>
    int x = bar.index
    float v = f.volatility
    bool live = f.state == ST_ACTIVE and x > f.available and bar.valid
    bool above = live and bar.last > warnUpperAt(f, x) + ENDED_ALLOWANCE_ATR * v
    bool below = live and not above and bar.last < warnLowerAt(f, x) - ENDED_ALLOWANCE_ATR * v
    bool aged = f.state == ST_ACTIVE and x > f.available and not above and not below and x - f.available >= AGE_OUT_BARS
    if above or below
        f.state := ST_ENDED
        f.why := above ? WHY_ABOVE : WHY_BELOW
        f.endBar := x
        recordEvent(EV_ENDED, f, bar, -1, flagsArray, messagesArray)
    else if aged
        f.state := ST_AGED
        f.why := WHY_AGED
        f.endBar := x
        recordEvent(EV_ENDED, f, bar, -1, flagsArray, messagesArray)
    else if live
        countReturns(f, bar, flagsArray, messagesArray)
    0

newerTerminal(Fork left, Fork right) =>
    left.endBar > right.endBar or (left.endBar == right.endBar and (left.available > right.available or (left.available == right.available and left.layer > right.layer)))

retireFork(array<Fork> terminalArray, Fork f) =>
    array.push(terminalArray, f)
    int index = array.size(terminalArray) - 1
    while index > 0
        Fork ahead = array.get(terminalArray, index - 1)
        Fork here = array.get(terminalArray, index)
        if newerTerminal(here, ahead)
            array.set(terminalArray, index - 1, here)
            array.set(terminalArray, index, ahead)
            index -= 1
        else
            break
    while array.size(terminalArray) > retainedInput
        array.pop(terminalArray)
    0

ingestLayer(Layer layerData, int layer, int strength, array<BarData> ringArray, BarData bar, float atr, float cap, array<Fork> liveArray, array<Fork> terminalArray, array<Setup> setupsArray, array<int> flagsArray, array<string> messagesArray) =>
    [hi, lo] = strictPivot(ringArray, bar.index, strength)
    trimSwings(layerData.swingsArray, bar.index)
    if not na(hi) or not na(lo)
        Pivot p2 = na(lo) ? hi : lo
        bool entered = updateSwings(layerData.swingsArray, p2)
        int count = array.size(layerData.swingsArray)
        if entered and count >= 3
            [p0, p1] = selectAnchors(layerData, strength, ringArray, bar, atr)
            if not na(p0)
                int side = p2.kind == KIND_LOW ? 1 : -1
                int variantCode = variantCodeOf(variantInput)
                [oBar, oPrice, slope, dUp, dDn, p1Upper] = geometryFor(variantCode, p0, p1, p2)
                Fork old = array.get(liveArray, layer)
                if not na(old)
                    old.state := ST_SUPERSEDED
                    old.why := WHY_SUPERSEDE
                    old.endBar := bar.index
                    array.set(liveArray, layer, na)
                    retireFork(terminalArray, old)
                    recordEvent(EV_ENDED, old, bar, -1, flagsArray, messagesArray)
                float r = cappedR(math.abs(p1.price - p2.price), cap)
                float entryPrice = gridPrice(bar.last)
                float stopPrice = stopFor(side, entryPrice, p2, atr, r)
                int basisCode = basisCodeOf(basisInput)
                bool slopedBasis = basisSloped(basisCode)
                float unit = slopedBasis ? na : targetUnit(basisCode, entryPrice, stopPrice, atr)
                float target1Price = slopedBasis ? na : targetFor(side, entryPrice, unit, TARGET_1_R)
                float targetPrice = slopedBasis ? na : targetFor(side, entryPrice, unit, TARGET_2_R)
                float target3Price = slopedBasis ? na : targetFor(side, entryPrice, unit, TARGET_3_R)
                Fork built = Fork.new(side, layer, variantCode, p0, p1, p2, oBar, oPrice, slope, dUp, dDn, atr, p2.index + strength, entryPrice, r, stopPrice, targetPrice, target1Price, target3Price, basisCode, forkKey(layer, side, p0, p1, p2), p1Upper, array.new<int>(3, 0), array.new<int>(3, -1), array.new<int>(), array.new<int>(), tiersArray = array.new<bool>(3, true), tradeReady = not na(syminfo.mintick) and syminfo.mintick > 0 and (R_CAP_ATR_MULTIPLE == 0 or (not na(cap) and cap > 0)))
                freezeTiers(built, built.available)
                array.set(liveArray, layer, built)
                array.set(setupsArray, layer, newSetup(built, bar))
                recordEvent(EV_FORMED, built, bar, -1, flagsArray, messagesArray)
    0

// ── Colours and text
addTransparency(color selected, float extra) =>
    color.new(selected, math.min(100.0, math.max(0.0, color.t(selected) + extra)))

lightChart() =>
    color bg = chart.bg_color
    (color.r(bg) * 0.299 + color.g(bg) * 0.587 + color.b(bg) * 0.114) > 140

forkColor() =>
    forkInput

forkStroke() =>
    strokeInput == STROKE_DOTTED ? line.style_dotted : strokeInput == STROKE_DASHED ? line.style_dashed : line.style_solid

guideColor() =>
    lightChart() ? GUIDE_LIGHT : GUIDE_DARK

returnColor() =>
    lightChart() ? TOUCH_LIGHT : TOUCH_DARK

levelColor() =>
    lightChart() ? LEVEL_GREEN_LIGHT : LEVEL_GREEN_DARK

stopColor() =>
    lightChart() ? LEVEL_RED_LIGHT : LEVEL_RED_DARK

inkColor() =>
    lightChart() ? INK_LIGHT : INK_DARK

textSizeOf(string chosen) =>
    switch chosen
        SIZE_NORMAL => size.normal
        SIZE_SMALL  => size.small
        => size.tiny

// ── Drawing
deleteDrawing(Drawing drawing) =>
    for id in drawing.linesArray
        if not na(id)
            line.delete(id)
    for id in drawing.labelsArray
        if not na(id)
            label.delete(id)
    0

updateLine(array<line> linesArray, int slot, int leftBar, float leftPrice, int rightBar, float rightPrice, color tint, string stroke, int weight, string coordinateMode = xloc.bar_index) =>
    line id = array.get(linesArray, slot)
    if na(id)
        id := line.new(leftBar, leftPrice, rightBar, rightPrice, xloc = coordinateMode, extend = extend.none, color = tint, style = stroke, width = weight)
        array.set(linesArray, slot, id)
    else
        line.set_xy1(id, leftBar, leftPrice)
        line.set_xy2(id, rightBar, rightPrice)
        line.set_color(id, tint)
        line.set_style(id, stroke)
        line.set_width(id, weight)
    0

clearLine(array<line> linesArray, int slot) =>
    line id = array.get(linesArray, slot)
    if not na(id)
        line.delete(id)
        array.set(linesArray, slot, na)
    0

updateLabel(array<label> labelsArray, int slot, int barIndex, float price, string body, color tint, color back, string pointer, string place, string hover) =>
    label id = array.get(labelsArray, slot)
    if na(id)
        id := label.new(barIndex, price, body, xloc = xloc.bar_index, yloc = place, color = back, style = pointer, textcolor = tint, size = textSizeOf(textSizeInput), tooltip = hover)
        array.set(labelsArray, slot, id)
    else
        label.set_xy(id, barIndex, price)
        label.set_yloc(id, place)
        label.set_text(id, body)
        label.set_color(id, back)
        label.set_textcolor(id, tint)
        label.set_style(id, pointer)
        label.set_size(id, textSizeOf(textSizeInput))
        label.set_tooltip(id, hover)
    0

clearLabel(array<label> labelsArray, int slot) =>
    label id = array.get(labelsArray, slot)
    if not na(id)
        label.delete(id)
        array.set(labelsArray, slot, na)
    0

captionPrice(Fork f, array<Fork> membersArray) =>
    float price = f.p0.price - f.side * f.volatility
    if f.layer == 1 and array.size(membersArray) > 0
        for peer in membersArray
            if peer.layer == 0 and peer.state == ST_ACTIVE and peer.p0.index == f.p0.index and peer.side == f.side
                price := peer.p0.price - peer.side * peer.volatility - f.side * f.volatility
    price

drawFork(Drawing drawing, int now, bool bothTagLayers, float captionY) =>
    Fork f = drawing.fork
    bool live = f.state == ST_ACTIVE
    int right = live ? now : f.endBar
    string layerTag = f.layer == 0 ? "S " : "L "
    string tagSuffix = bothTagLayers ? (f.layer == 0 ? " · S" : " · L") : ""
    string tagStyle = label.style_label_left
    int tagBar = now + labelInsetInput
    color noFill = color.new(chart.bg_color, 100)
    color tagBack = color.new(chart.bg_color, 0)
    color quiet = addTransparency(guideColor(), 55)
    color forkTint = live ? forkColor() : quiet
    color guideTint = guideColor()
    color returnTint = returnColor()
    int strokeParallel = live ? widthInput : 1
    int strokeMedian = live ? widthInput + 1 : 1
    int originBar = math.round(f.oBar)
    int upperAnchor = f.p1Upper ? f.p1.index : f.p2.index
    int lowerAnchor = f.p1Upper ? f.p2.index : f.p1.index
    if medianInput
        updateLine(drawing.linesArray, 0, originBar, medianAt(f, originBar), right, medianAt(f, right), forkTint, forkStroke(), strokeMedian)
    else
        clearLine(drawing.linesArray, 0)
    if upperInput
        updateLine(drawing.linesArray, 1, upperAnchor, upperAt(f, upperAnchor), right, upperAt(f, right), forkTint, forkStroke(), strokeParallel)
    else
        clearLine(drawing.linesArray, 1)
    if lowerInput
        updateLine(drawing.linesArray, 2, lowerAnchor, lowerAt(f, lowerAnchor), right, lowerAt(f, right), forkTint, forkStroke(), strokeParallel)
    else
        clearLine(drawing.linesArray, 2)
    color handleTint = live ? addTransparency(forkTint, 45) : quiet
    updateLine(drawing.linesArray, 7, f.p0.index, f.p0.price, f.p1.index, f.p1.price, handleTint, forkStroke(), 1)
    updateLine(drawing.linesArray, 8, f.p1.index, f.p1.price, f.p2.index, f.p2.price, handleTint, forkStroke(), 1)
    if live and SHOW_WARNING_LINES and upperInput
        updateLine(drawing.linesArray, 3, f.p2.index, warnUpperAt(f, f.p2.index), right, warnUpperAt(f, right), addTransparency(guideTint, 30), line.style_dotted, 1)
    else
        clearLine(drawing.linesArray, 3)
    if live and SHOW_WARNING_LINES and lowerInput
        updateLine(drawing.linesArray, 4, f.p2.index, warnLowerAt(f, f.p2.index), right, warnLowerAt(f, right), addTransparency(guideTint, 30), line.style_dotted, 1)
    else
        clearLine(drawing.linesArray, 4)
    if live and SHOW_INNER_PARALLELS and upperInput and medianInput
        updateLine(drawing.linesArray, 5, f.p1.index, innerUpperAt(f, f.p1.index), right, innerUpperAt(f, right), addTransparency(guideTint, 45), line.style_dotted, 1)
    else
        clearLine(drawing.linesArray, 5)
    if live and SHOW_INNER_PARALLELS and lowerInput and medianInput
        updateLine(drawing.linesArray, 6, f.p1.index, innerLowerAt(f, f.p1.index), right, innerLowerAt(f, right), addTransparency(guideTint, 45), line.style_dotted, 1)
    else
        clearLine(drawing.linesArray, 6)
    string layerSuffix = f.layer == 0 ? "" : " · " + layerName(f.layer)
    if labelsInput and live
        updateLabel(drawing.labelsArray, 3, f.p0.index, captionY, variantName(f.variant) + " Fork - " + (f.side == 1 ? "Long" : "Short") + layerSuffix, inkColor(), noFill, f.side == 1 ? label.style_label_up : label.style_label_down, yloc.price, "")
    else
        clearLabel(drawing.labelsArray, 3)
    if live and labelsInput
        updateLabel(drawing.labelsArray, 0, f.p0.index, f.p0.price, layerTag + "P0", forkTint, noFill, f.side * (f.layer == 0 ? 1 : -1) == 1 ? label.style_label_up : label.style_label_down, yloc.price, "")
        updateLabel(drawing.labelsArray, 1, f.p1.index, f.p1.price, layerTag + "P1", forkTint, noFill, f.side * (f.layer == 0 ? 1 : -1) == 1 ? label.style_label_down : label.style_label_up, yloc.price, "")
        updateLabel(drawing.labelsArray, 2, f.p2.index, f.p2.price, layerTag + "P2", forkTint, noFill, f.side * (f.layer == 0 ? 1 : -1) == 1 ? label.style_label_up : label.style_label_down, yloc.price, "")
        updateLabel(drawing.labelsArray, RING_SLOT_FIRST, f.p0.index, f.p0.price, PIVOT_GLYPH, forkTint, noFill, label.style_label_center, yloc.price, "")
        updateLabel(drawing.labelsArray, RING_SLOT_FIRST + 1, f.p1.index, f.p1.price, PIVOT_GLYPH, forkTint, noFill, label.style_label_center, yloc.price, "")
        updateLabel(drawing.labelsArray, RING_SLOT_FIRST + 2, f.p2.index, f.p2.price, PIVOT_GLYPH, forkTint, noFill, label.style_label_center, yloc.price, "")
    else
        clearLabel(drawing.labelsArray, 0)
        clearLabel(drawing.labelsArray, 1)
        clearLabel(drawing.labelsArray, 2)
        clearLabel(drawing.labelsArray, RING_SLOT_FIRST)
        clearLabel(drawing.labelsArray, RING_SLOT_FIRST + 1)
        clearLabel(drawing.labelsArray, RING_SLOT_FIRST + 2)
    for role = 0 to 2
        if live and labelsInput and lineVisible(role)
            updateLabel(drawing.labelsArray, role + 4, tagBar, lineAt(f, role, now), lineName(role) + tagSuffix, forkTint, tagBack, tagStyle, yloc.price, "")
        else
            clearLabel(drawing.labelsArray, role + 4)
    int marks = live and labelsInput ? array.size(f.markBarsArray) : 0
    for slot = 0 to RETURN_MARK_CAP - 1
        if slot < marks
            int markBar = array.get(f.markBarsArray, slot)
            int markLine = array.get(f.markLinesArray, slot)
            if lineVisible(markLine)
                updateLabel(drawing.labelsArray, MARK_SLOT_FIRST + slot, markBar, lineAt(f, markLine, markBar), RETURN_GLYPH, returnTint, noFill, label.style_label_center, yloc.price, "")
            else
                clearLabel(drawing.labelsArray, MARK_SLOT_FIRST + slot)
        else
            clearLabel(drawing.labelsArray, MARK_SLOT_FIRST + slot)
    0

pruneDrawing(Drawing drawing) =>
    Fork f = drawing.fork
    bool live = f.state == ST_ACTIVE
    for slot = 0 to LINE_SLOTS - 1
        bool keep = (slot == 0 and medianInput) or (slot == 1 and upperInput) or (slot == 2 and lowerInput) or slot == 7 or slot == 8 or (slot == 3 and live and SHOW_WARNING_LINES and upperInput) or (slot == 4 and live and SHOW_WARNING_LINES and lowerInput) or (slot == 5 and live and SHOW_INNER_PARALLELS and upperInput and medianInput) or (slot == 6 and live and SHOW_INNER_PARALLELS and lowerInput and medianInput) or (slot >= CONNECTOR_FIRST and live and labelsInput and lineVisible(slot - CONNECTOR_FIRST))
        if not keep
            clearLine(drawing.linesArray, slot)
    for slot = 0 to LABEL_SLOTS - 1
        bool keep = labelsInput and live and (slot <= 3 or (slot >= 4 and slot <= 6 and lineVisible(slot - 4)) or (slot >= RING_SLOT_FIRST and slot < MARK_SLOT_FIRST) or (slot >= MARK_SLOT_FIRST and slot - MARK_SLOT_FIRST < array.size(f.markBarsArray) and lineVisible(array.get(f.markLinesArray, slot - MARK_SLOT_FIRST))))
        if not keep
            clearLabel(drawing.labelsArray, slot)
    0

setupPrice(Setup setup, int role, int x) =>
    role == 0 ? setup.fork.entry : role == 1 ? setup.fork.stop : setupTargetAt(setup, role - 2, x)

setupPriceBar(Setup setup, int role, int now) =>
    int reachedBar = role < 2 ? na : array.get(setup.reachedBarsArray, role - 2)
    na(reachedBar) ? (na(setup.settledBar) ? now : setup.settledBar) : reachedBar

setupPriceFixed(Setup setup, int role) =>
    int reachedBar = role < 2 ? na : array.get(setup.reachedBarsArray, role - 2)
    not na(reachedBar) or not na(setup.settledBar)

clearWedge(SetupDrawing drawing, int slot) =>
    linefill fillId = array.get(drawing.fillsArray, slot)
    if not na(fillId)
        linefill.delete(fillId)
        array.set(drawing.fillsArray, slot, na)
    0

updateWedge(SetupDrawing drawing, int slot, int lowerSlot, int upperSlot, color tint) =>
    line lowerLine = array.get(drawing.linesArray, lowerSlot)
    line upperLine = array.get(drawing.linesArray, upperSlot)
    if not na(lowerLine) and not na(upperLine)
        array.set(drawing.fillsArray, slot, linefill.new(lowerLine, upperLine, color.new(tint, ZONE_FILL_TRANSP)))
    0

clearZone(SetupDrawing drawing, int slot) =>
    box zoneId = array.get(drawing.boxesArray, slot)
    if not na(zoneId)
        box.delete(zoneId)
        array.set(drawing.boxesArray, slot, na)
    0

updateZone(SetupDrawing drawing, int slot, int leftTime, int rightTime, float firstPrice, float lastPrice, color tint) =>
    box zoneId = array.get(drawing.boxesArray, slot)
    float upper = math.max(firstPrice, lastPrice)
    float lower = math.min(firstPrice, lastPrice)
    if na(zoneId)
        zoneId := box.new(leftTime, upper, rightTime, lower, xloc = xloc.bar_time, border_color = color.new(tint, ZONE_BORDER_TRANSP), border_width = 1, bgcolor = color.new(tint, ZONE_FILL_TRANSP))
        array.set(drawing.boxesArray, slot, zoneId)
    else
        box.set_lefttop(zoneId, leftTime, upper)
        box.set_rightbottom(zoneId, rightTime, lower)
        box.set_border_color(zoneId, color.new(tint, ZONE_BORDER_TRANSP))
        box.set_bgcolor(zoneId, color.new(tint, ZONE_FILL_TRANSP))
    0

pruneSetupDrawing(SetupDrawing drawing, bool eligible) =>
    Setup setup = drawing.setup
    for role = 0 to SETUP_LABEL_SLOTS - 1
        bool keep = eligible and setupLevelVisible(setup, role)
        if not keep
            clearLine(drawing.linesArray, role)
        if not keep or not labelsInput
            clearLabel(drawing.labelsArray, role)
            clearLine(drawing.linesArray, SETUP_CONNECTOR_FIRST + role)
    bool sloped = basisSloped(setup.fork.basis)
    for slot = 0 to SETUP_BOX_SLOTS - 1
        bool keep = eligible and (slot == 0 or (not sloped and na(array.get(setup.reachedTimesArray, slot - 1))))
        if not keep
            clearZone(drawing, slot)
    for tier = 0 to 1
        if not (eligible and floorEdgeNeeded(setup.fork, tier))
            clearLine(drawing.linesArray, SETUP_FLOOR_FIRST + tier)
    for slot = 0 to SETUP_FILL_SLOTS - 1
        clearWedge(drawing, slot)
    0

drawSetup(SetupDrawing drawing, int now, int rightTime, bool bothTagLayers, bool eligible) =>
    Setup setup = drawing.setup
    if eligible
        Fork f = setup.fork
        string suffix = bothTagLayers ? (f.layer == 0 ? " · S" : " · L") : ""
        for role = 0 to SETUP_LABEL_SLOTS - 1
            if setupLevelVisible(setup, role)
                float leftPrice = setupPrice(setup, role, f.available)
                float price = setupPrice(setup, role, now)
                float rightPrice = setupPrice(setup, role, now + 1)
                color tint = role == 1 ? stopColor() : levelColor()
                updateLine(drawing.linesArray, role, setup.formedTime, leftPrice, rightTime, rightPrice, tint, line.style_solid, 1, xloc.bar_time)
                if labelsInput
                    string body = "--> " + (role == 0 ? "Entry" : role == 1 ? "Stop" : "T" + str.tostring(role - 1)) + suffix
                    updateLabel(drawing.labelsArray, role, now + labelInsetInput, price, body, LEVEL_TEXT, tint, label.style_label_left, yloc.price, "")
        updateZone(drawing, 0, setup.formedTime, rightTime, f.entry, f.stop, stopColor())
        if basisSloped(f.basis)
            int floorSlot = 0
            for tier = 0 to 2
                updateWedge(drawing, tier, floorSlot, tier + 2, levelColor())
                if floorEdgeNeeded(f, tier)
                    floorSlot := SETUP_FLOOR_FIRST + tier
                    updateLine(drawing.linesArray, floorSlot, setup.formedTime, setupPrice(setup, tier + 2, f.available), rightTime, setupPrice(setup, tier + 2, now + 1), color.new(levelColor(), FLOOR_EDGE_TRANSP), line.style_solid, 1, xloc.bar_time)
        else
            for tier = 0 to 2
                if na(array.get(setup.reachedTimesArray, tier))
                    float lowerTier = tier == 0 ? f.entry : setupTarget(setup, tier - 1)
                    updateZone(drawing, tier + 1, setup.formedTime, rightTime, lowerTier, setupTarget(setup, tier), levelColor())
    0

tagBefore(Tag left, Tag right) =>
    left.price < right.price or (left.price == right.price and (left.layer < right.layer or (left.layer == right.layer and left.role < right.role)))

visibleDrawingRange(array<Drawing> drawingsArray, array<Fork> membersArray, int leftInView, int rightInView, float lowInView, float highInView) =>
    float rangeLow = lowInView
    float rangeHigh = highInView
    if not na(leftInView) and not na(rightInView)
        for drawing in drawingsArray
            for slot = 0 to CONNECTOR_FIRST - 1
                line lineId = array.get(drawing.linesArray, slot)
                if not na(lineId)
                    int leftBar = line.get_x1(lineId)
                    int rightBar = line.get_x2(lineId)
                    int clippedLeft = math.max(leftInView, leftBar)
                    int clippedRight = math.min(rightInView, rightBar)
                    if clippedLeft <= clippedRight
                        float leftPrice = line.get_y1(lineId)
                        float rightPrice = line.get_y2(lineId)
                        float slope = rightBar == leftBar ? 0.0 : (rightPrice - leftPrice) / (rightBar - leftBar)
                        float first = atPrice(leftBar, leftPrice, slope, clippedLeft)
                        float last = atPrice(leftBar, leftPrice, slope, clippedRight)
                        float lower = math.min(first, last)
                        float upper = math.max(first, last)
                        rangeLow := na(rangeLow) ? lower : math.min(rangeLow, lower)
                        rangeHigh := na(rangeHigh) ? upper : math.max(rangeHigh, upper)
            Fork f = drawing.fork
            if labelsInput and f.state == ST_ACTIVE and f.p0.index >= leftInView and f.p0.index <= rightInView
                float captionY = captionPrice(f, membersArray)
                rangeLow := na(rangeLow) ? captionY : math.min(rangeLow, captionY)
                rangeHigh := na(rangeHigh) ? captionY : math.max(rangeHigh, captionY)
    [rangeLow, rangeHigh]

insertTag(array<Tag> tagsArray, Tag tag) =>
    array.push(tagsArray, tag)
    int index = array.size(tagsArray) - 1
    while index > 0 and tagBefore(tag, array.get(tagsArray, index - 1))
        array.set(tagsArray, index, array.get(tagsArray, index - 1))
        index -= 1
    array.set(tagsArray, index, tag)
    0

layoutTags(array<Drawing> drawingsArray, array<SetupDrawing> setupDrawingsArray, array<bool> eligibleArray, int now, float lowInView, float highInView) =>
    array<Tag> tagsArray = array.new<Tag>()
    float largestVolatility = 0.0
    for drawing in drawingsArray
        Fork f = drawing.fork
        if f.state == ST_ACTIVE and labelsInput
            largestVolatility := math.max(largestVolatility, f.volatility)
            for role = 0 to 2
                if lineVisible(role)
                    insertTag(tagsArray, Tag.new(drawing.linesArray, drawing.labelsArray, role + 4, CONNECTOR_FIRST + role, f.layer, role, lineAt(f, role, now), forkColor()))
    for drawing in setupDrawingsArray
        if not na(drawing) and array.get(eligibleArray, drawing.setup.fork.layer) and labelsInput
            Setup setup = drawing.setup
            largestVolatility := math.max(largestVolatility, setup.fork.volatility)
            for role = 0 to SETUP_LABEL_SLOTS - 1
                if setupLevelVisible(setup, role)
                    insertTag(tagsArray, Tag.new(drawing.linesArray, drawing.labelsArray, role, SETUP_CONNECTOR_FIRST + role, setup.fork.layer, role + 3, setupPrice(setup, role, now), role == 1 ? stopColor() : levelColor()))
    int count = array.size(tagsArray)
    if count > 0
        float tick = not na(syminfo.mintick) and syminfo.mintick > 0 ? syminfo.mintick : 0.0
        Tag firstTag = array.get(tagsArray, 0)
        Tag lastTag = array.get(tagsArray, count - 1)
        float rangeLow = na(lowInView) ? firstTag.price : math.min(lowInView, firstTag.price)
        float rangeHigh = na(highInView) ? lastTag.price : math.max(highInView, lastTag.price)
        float textFraction = textSizeInput == SIZE_NORMAL ? 0.075 : textSizeInput == SIZE_SMALL ? 0.06 : 0.045
        float rangeFloor = (rangeHigh - rangeLow) * textFraction
        float spacing = math.max(tick, largestVolatility * LABEL_SPACING_ATR, rangeFloor)
        array<float> meansArray = array.new<float>()
        array<int> weightsArray = array.new<int>()
        for index = 0 to count - 1
            Tag tag = array.get(tagsArray, index)
            array.push(meansArray, tag.price - index * spacing)
            array.push(weightsArray, 1)
            int blocks = array.size(meansArray)
            while blocks > 1
                float left = array.get(meansArray, blocks - 2)
                float right = array.get(meansArray, blocks - 1)
                if left <= right
                    break
                int leftWeight = array.get(weightsArray, blocks - 2)
                int rightWeight = array.pop(weightsArray)
                array.pop(meansArray)
                array.set(meansArray, blocks - 2, (left * leftWeight + right * rightWeight) / (leftWeight + rightWeight))
                array.set(weightsArray, blocks - 2, leftWeight + rightWeight)
                blocks -= 1
        int index = 0
        int tagBar = now + labelInsetInput
        for block = 0 to array.size(meansArray) - 1
            for member = 1 to array.get(weightsArray, block)
                Tag tag = array.get(tagsArray, index)
                float placed = array.get(meansArray, block) + index * spacing
                label.set_xy(array.get(tag.labelsArray, tag.slot), tagBar, placed)
                updateLine(tag.linesArray, tag.connectorSlot, now, tag.price, tagBar, placed, addTransparency(tag.tint, 30), line.style_dotted, 1)
                index += 1
    0

hasMember(array<Fork> membersArray, string key) =>
    bool found = false
    if array.size(membersArray) > 0
        for f in membersArray
            if f.key == key
                found := true
                break
    found

setupEligible(Setup setup, array<Fork> membersArray) =>
    setupVisible(setup) and hasMember(membersArray, setup.fork.key)

renderForks(array<Drawing> drawingsArray, array<Fork> membersArray, array<SetupDrawing> setupDrawingsArray, array<Setup> setupsArray, int now, int rightTime, int leftInView, int rightInView, float lowInView, float highInView) =>
    int index = array.size(drawingsArray) - 1
    while index >= 0
        Drawing drawing = array.get(drawingsArray, index)
        if not hasMember(membersArray, drawing.fork.key)
            deleteDrawing(drawing)
            array.remove(drawingsArray, index)
        index -= 1
    array<bool> eligibleArray = array.new<bool>(2, false)
    for drawing in drawingsArray
        pruneDrawing(drawing)
    for layer = 0 to 1
        array.set(eligibleArray, layer, setupEligible(array.get(setupsArray, layer), membersArray))
        SetupDrawing drawing = array.get(setupDrawingsArray, layer)
        if not na(drawing)
            drawing.setup := array.get(setupsArray, layer)
            pruneSetupDrawing(drawing, array.get(eligibleArray, layer))
    array<bool> tagLayersArray = array.new<bool>(2, false)
    if labelsInput
        for f in membersArray
            if f.state == ST_ACTIVE and (upperInput or medianInput or lowerInput)
                array.set(tagLayersArray, f.layer, true)
        for layer = 0 to 1
            if array.get(eligibleArray, layer)
                array.set(tagLayersArray, layer, true)
    bool bothTagLayers = array.get(tagLayersArray, 0) and array.get(tagLayersArray, 1)
    if array.size(membersArray) > 0
        for f in membersArray
            Drawing selected = na
            if array.size(drawingsArray) > 0
                for drawing in drawingsArray
                    if drawing.fork.key == f.key
                        selected := drawing
                        break
            if na(selected)
                selected := Drawing.new(f, array.new<line>(LINE_SLOTS), array.new<label>(LABEL_SLOTS))
                array.push(drawingsArray, selected)
            selected.fork := f
            drawFork(selected, now, bothTagLayers, captionPrice(f, membersArray))
    for layer = 0 to 1
        Setup setup = array.get(setupsArray, layer)
        if array.get(eligibleArray, layer)
            SetupDrawing drawing = array.get(setupDrawingsArray, layer)
            if na(drawing)
                drawing := SetupDrawing.new(setup, array.new<line>(SETUP_LINE_SLOTS), array.new<label>(SETUP_LABEL_SLOTS), array.new<box>(SETUP_BOX_SLOTS), array.new<linefill>(SETUP_FILL_SLOTS))
                array.set(setupDrawingsArray, layer, drawing)
            drawSetup(drawing, now, rightTime, bothTagLayers, array.get(eligibleArray, layer))
    [drawnLow, drawnHigh] = visibleDrawingRange(drawingsArray, membersArray, leftInView, rightInView, lowInView, highInView)
    layoutTags(drawingsArray, setupDrawingsArray, eligibleArray, now, drawnLow, drawnHigh)
    0

displayedForks(array<Fork> liveArray, array<Fork> terminalArray) =>
    array<Fork> result = array.new<Fork>()
    for slot = 0 to 1
        Fork f = array.get(liveArray, slot)
        if not na(f)
            array.push(result, f)
    if array.size(terminalArray) > 0
        for f in terminalArray
            array.push(result, f)
    result

// ── Panel
waitingText(Layer layerData) =>
    bool fewPivots = array.size(layerData.swingsArray) < 3
    fewPivots ? "insufficient confirmed pivots" : layerData.newestReason == "" ? "waiting for a new confirmed pivot" : str.tostring(layerData.examined) + (layerData.examined == 1 ? " triple examined" : " triples examined") + "\nNewest rejected: " + layerData.newestReason

panelCell(table target, int column, int row, string body, color tint, string hover, color backColor = na) =>
    table.cell(target, column, row, body, text_color = tint, text_size = textSizeOf(textSizeInput), text_halign = text.align_left, tooltip = hover, bgcolor = na(backColor) ? (lightChart() ? FILL_LIGHT : FILL_DARK) : backColor)
    0

setupStatus(Setup setup) =>
    string lastName = "T" + str.tostring(finalTier(setup.fork) + 1)
    setup.state == LEVEL_TRACKING ? "Tracking" : setup.state == LEVEL_T3 ? "Closed, " + lastName + " Reached" : setup.state == LEVEL_STOP ? "Closed, Stop Reached" : setup.state == LEVEL_ORDER_UNKNOWN ? "Closed, Order Unknown" : setup.state == LEVEL_FORK_ENDED ? "Closed, Fork Ended" : "Levels Unavailable"

reachedTimeText(int stamp) =>
    bool sameDay = str.format_time(stamp, "yyyy-MM-dd", syminfo.timezone) == str.format_time(time, "yyyy-MM-dd", syminfo.timezone)
    bool sameYear = str.format_time(stamp, "yyyy", syminfo.timezone) == str.format_time(time, "yyyy", syminfo.timezone)
    string pattern = timeframe.isintraday ? (sameDay ? "HH:mm" : sameYear ? "MM-dd HH:mm" : "yyyy-MM-dd HH:mm") : sameYear ? "MM-dd" : "yyyy-MM-dd"
    str.format_time(stamp, pattern, syminfo.timezone)

panelSetupLevel(table target, int column, int row, Setup setup, int role, int x) =>
    string body = "—"
    color tint = inkColor()
    color backColor = na
    bool sloped = basisSloped(setup.fork.basis)
    bool carried = role < 2 or tierActive(setup.fork, role - 2)
    string hover = carried ? "• Levels unavailable when this fork formed.\n• A newer fork replaces this setup." : "• This fork's " + tierLabel(setup.fork.basis, role - 2, "≥", "×") + " line did not lie beyond Entry when the fork formed, so the setup never carried it."
    if setup.fork.tradeReady and carried
        int priceBar = setupPriceBar(setup, role, x)
        body := str.tostring(setupPrice(setup, role, priceBar), format.mintick)
        hover := sloped and role >= 2 ? (setupPriceFixed(setup, role) ? "• A sloped target is the fork line itself. This price is where that line sat on the bar that fixed it, and it does not move again." : "• A sloped target is the fork line itself, so this price is the line read at the latest bar and is not frozen.") : "• Frozen when formed: " + str.format_time(setup.formedTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + " " + syminfo.timezone
        if role == 0
            body += "\nFormed " + reachedTimeText(setup.formedTime)
        else
            int reachedTime = role == 1 ? setup.stopTime : array.get(setup.reachedTimesArray, role - 2)
            bool ambiguous = role == 1 ? setup.stopAmbiguous : array.get(setup.ambiguousArray, role - 2)
            if not na(reachedTime)
                body += "\nReached " + reachedTimeText(reachedTime) + (ambiguous ? "\nOrder unknown" : "")
                tint := LEVEL_TEXT
                backColor := color.new(role == 1 ? stopColor() : levelColor(), TABLE_REACHED_TRANSP)
                hover += "\n• First reached bar opened: " + str.format_time(reachedTime, "yyyy-MM-dd HH:mm:ss", syminfo.timezone) + " " + syminfo.timezone + (ambiguous ? "\n• Stop and a new target reached on the same bar; order unknown." : "")
            else
                body += setup.state == LEVEL_TRACKING ? "\nPending" : setup.state == LEVEL_UNAVAILABLE ? "\nNever opened" : "\nUnreached · closed"
    panelCell(target, column, row, body, tint, hover, backColor)
    0

levelRowName(int basisCode, int role) =>
    role == 0 ? "Entry" : role == 1 ? (basisCode == BASIS_STOP ? "Stop · 1R" : "Stop") : "T" + str.tostring(role - 1) + " " + tierLabel(basisCode, role - 2, "≥", "×")

basisHover(int basisCode, int role) =>
    string unit = role < 2 ? "• Entry and Stop are fixed prices, frozen when the fork forms, and do not move again." : basisCode == BASIS_ATR ? "• ATR = the fork's frozen " + str.tostring(VOLATILITY_LENGTH) + "-bar average true range; targets round away from Entry." : basisCode == BASIS_MEDIAN ? "• The target is the fork's median line itself, so it slopes with the fork." : basisCode == BASIS_STRUCTURE ? "• The targets are the fork's median, then the parallel and the warning line on the side the setup is heading toward, so they slope with the fork." : "• R = frozen Entry-to-Stop distance; targets round away from Entry."
    unit + "\n• Times mark each bar’s open in the exchange timezone."

panelLevel(table target, int row, string name, int role, Setup firstSetup, Setup otherSetup, int basisCode, int x) =>
    panelCell(target, 0, row, name, guideColor(), basisHover(basisCode, role))
    panelSetupLevel(target, 1, row, firstSetup, role, x)
    if not na(otherSetup)
        panelSetupLevel(target, 2, row, otherSetup, role, x)
    row + 1

panelHeading(table target, int row, int column, Setup setup) =>
    Fork f = setup.fork
    string body = variantName(f.variant) + " - " + (f.side == 1 ? "Long" : "Short") + "\n" + setupStatus(setup)
    string hover = "• " + layerName(f.layer) + " layer · fork " + (f.state == ST_ACTIVE ? "active" : "ended") + "\n• Formed " + str.format_time(setup.formedTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + " " + syminfo.timezone + (setup.state == LEVEL_TRACKING ? "\n• Hiding drawings does not pause an open setup.\n• It closes when a target or the Stop is reached, or when its fork ends." : setup.state == LEVEL_FORK_ENDED ? "\n• This setup closed because its fork ended; a newer fork would have replaced it instead." : "")
    panelCell(target, column, row, body, inkColor(), hover)
    0

panelNote(table target, int row, string body, int lastColumn, string hover = "") =>
    panelCell(target, 0, row, body, guideColor(), hover)
    for column = 1 to lastColumn
        panelCell(target, column, row, "", guideColor(), "")
    table.merge_cells(target, 0, row, lastColumn, row)
    row + 1

// ─────────────────────────────────────────────────────────────────────────────
// Calculation
// ─────────────────────────────────────────────────────────────────────────────

var array<BarData> ringArray = array.new<BarData>(RING_SIZE)
var array<float> trueRangesArray = array.new<float>()
var BarData previousBar = na
var array<Layer> layersArray = array.new<Layer>()
var array<Fork> liveArray = array.new<Fork>(2)
var array<Fork> terminalArray = array.new<Fork>()
var array<Drawing> drawingsArray = array.new<Drawing>()
var array<Setup> setupsArray = array.new<Setup>(2)
var array<SetupDrawing> setupDrawingsArray = array.new<SetupDrawing>(2)
var float volatility = na
var int visibleLeftIndex = na
var int visibleRightIndex = na
var float visibleLow = na
var float visibleHigh = na
var int lastConfirmedIndex = na
var table panelTable = table.new(positionConst(positionInput == POS_AUTO ? POS_TOP_RIGHT : positionInput), 3, PANEL_ROWS, border_width = 0)

if array.size(layersArray) == 0
    array.push(layersArray, Layer.new(array.new<Pivot>()))
    array.push(layersArray, Layer.new(array.new<Pivot>()))

array<int> flagsArray = array.new<int>(4, 0)
array<string> messagesArray = array.new<string>()

bool supported = chart.is_standard and not timeframe.isticks
bool settingsValid = MIN_WIDTH_ATR <= MAX_WIDTH_ATR and MIN_LEG_ATR < MAX_WIDTH_ATR
bool pricesValid = not na(high) and not na(low) and not na(close) and low <= close and close <= high

if pricesValid and time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    visibleLeftIndex := na(visibleLeftIndex) ? bar_index : visibleLeftIndex
    visibleRightIndex := bar_index
    visibleLow := na(visibleLow) ? low : math.min(visibleLow, low)
    visibleHigh := na(visibleHigh) ? high : math.max(visibleHigh, high)

float chartCapAtr = ta.sma(ta.tr(true), R_CAP_ATR_LEN)
float dailyCapAtr = na
if supported and timeframe.isintraday
    dailyCapAtr := request.security(syminfo.tickerid, "D", ta.sma(ta.tr(true), R_CAP_ATR_LEN)[1], lookahead = barmerge.lookahead_on)
float rCapValue = R_CAP_ATR_MULTIPLE * (timeframe.isintraday ? dailyCapAtr : chartCapAtr)
Fork priorSwingFork = array.get(liveArray, 0)
Fork priorLongerFork = array.get(liveArray, 1)

if barstate.isconfirmed
    lastConfirmedIndex := bar_index
    BarData bar = BarData.new(bar_index, time, high, low, close, pricesValid)
    array.set(ringArray, bar_index % RING_SIZE, bar)
    float tr = na
    if bar.valid
        if na(previousBar) or not previousBar.valid
            tr := bar.hi - bar.lo
        else if previousBar.valid
            tr := math.max(bar.hi - bar.lo, math.abs(bar.hi - previousBar.last), math.abs(bar.lo - previousBar.last))
    previousBar := bar
    array.push(trueRangesArray, tr)
    if array.size(trueRangesArray) > VOLATILITY_LENGTH
        array.shift(trueRangesArray)
    float total = 0.0
    for value in trueRangesArray
        total += value
    volatility := array.size(trueRangesArray) == VOLATILITY_LENGTH ? total / VOLATILITY_LENGTH : na
    if supported and settingsValid
        for setup in setupsArray
            if not na(setup)
                advanceSetup(setup, bar)
        for layer = 0 to 1
            Fork liveFork = array.get(liveArray, layer)
            if not na(liveFork)
                advanceFork(liveFork, bar, flagsArray, messagesArray)
                if liveFork.state != ST_ACTIVE
                    array.set(liveArray, layer, na)
                    retireFork(terminalArray, liveFork)
        for setup in setupsArray
            closeSetupWithFork(setup)
        ingestLayer(array.get(layersArray, 0), 0, swingInput, ringArray, bar, volatility, rCapValue, liveArray, terminalArray, setupsArray, flagsArray, messagesArray)
        if longerInput
            ingestLayer(array.get(layersArray, 1), 1, swingInput * LONGER_MULTIPLE, ringArray, bar, volatility, rCapValue, liveArray, terminalArray, setupsArray, flagsArray, messagesArray)
        int terminalIndex = array.size(terminalArray) - 1
        while terminalIndex >= 0
            Fork oldFork = array.get(terminalArray, terminalIndex)
            if bar.index - oldFork.p0.index > DRAW_MAX_BACK
                array.remove(terminalArray, terminalIndex)
            terminalIndex -= 1

Fork panelFork = array.get(liveArray, 0)
if na(panelFork)
    panelFork := array.get(liveArray, 1)

// ─────────────────────────────────────────────────────────────────────────────
// Rendering
// ─────────────────────────────────────────────────────────────────────────────

if barstate.islast
    array<Fork> membersArray = displayedForks(liveArray, terminalArray)
    renderForks(drawingsArray, membersArray, setupDrawingsArray, setupsArray, bar_index, na(time_close) ? time : time_close, visibleLeftIndex, visibleRightIndex, visibleLow, visibleHigh)
    string blocking = not supported ? "Unsupported chart: standard time-based charts only." : MIN_WIDTH_ATR > MAX_WIDTH_ATR ? "Invalid settings: minimum width exceeds maximum width." : MIN_LEG_ATR >= MAX_WIDTH_ATR ? "Invalid settings: maximum width must exceed minimum leg." : ""
    array<string> notesArray = array.new<string>()
    if blocking != ""
        array.push(notesArray, blocking)
    else
        if na(syminfo.mintick) or syminfo.mintick <= 0
            array.push(notesArray, "Tick metadata unavailable: trade levels unavailable.")
        for layer = 0 to 1
            Setup checkedSetup = array.get(setupsArray, layer)
            if not na(checkedSetup) and checkedSetup.state == LEVEL_UNAVAILABLE
                array.push(notesArray, layerName(layer) + ": trade levels unavailable at formation " + (checkedSetup.fork.tradeReady ? "(no target line lay beyond Entry)." : "(cap or tick metadata)."))
        if not pricesValid
            array.push(notesArray, "Missing price data: no new construction.")
        else if na(volatility) or volatility <= 0
            array.push(notesArray, "Volatility unavailable: no new construction.")
    string notice = array.join(notesArray, "\n")
    table.clear(panelTable, 0, 0, 2, PANEL_ROWS - 1)
    table.set_bgcolor(panelTable, color.new(chart.bg_color, 100))
    table.set_frame_color(panelTable, lightChart() ? FRAME_LIGHT : FRAME_DARK)
    table.set_frame_width(panelTable, 0)
    int row = 0
    Setup swingSetup = array.get(setupsArray, 0)
    Setup longerSetup = array.get(setupsArray, 1)
    Setup firstSetup = na(swingSetup) ? longerSetup : swingSetup
    bool bothSetups = not na(swingSetup) and not na(longerSetup)
    int lastColumn = bothSetups ? 2 : 1
    table.set_position(panelTable, positionConst(resolvedPosition(positionInput, firstSetup)))
    if panelInput and blocking == ""
        if not na(firstSetup)
            Setup otherSetup = bothSetups ? longerSetup : na
            panelCell(panelTable, 0, row, "Setup", guideColor(), "• Variant and setup direction.\n• Long/Short describes direction; Closed means level tracking has ended.\n• Order Unknown: Stop and a new target reached on the same bar; their sequence is unknown.")
            panelHeading(panelTable, row, 1, firstSetup)
            if bothSetups
                panelHeading(panelTable, row, 2, otherSetup)
            row += 1
            if levelsInput
                int panelBasis = firstSetup.fork.basis
                for role = 0 to 1 + tierCount(panelBasis)
                    row := panelLevel(panelTable, row, levelRowName(panelBasis, role), role, firstSetup, otherSetup, panelBasis, bar_index)
        else
            string waiting = "No level setup · S: " + waitingText(array.get(layersArray, 0))
            if longerInput
                waiting += "\nL: " + waitingText(array.get(layersArray, 1))
            row := panelNote(panelTable, row, waiting, lastColumn, "• Shows why the newest checked set of pivots was rejected.\n• Other sets may have failed for different reasons.")
    if notice != ""
        row := panelNote(panelTable, row, notice, lastColumn)

// ─────────────────────────────────────────────────────────────────────────────
// Data Window outputs
// ─────────────────────────────────────────────────────────────────────────────

bool swingTerminal = not na(priorSwingFork) and priorSwingFork.state != ST_ACTIVE
bool longerTerminal = not na(priorLongerFork) and priorLongerFork.state != ST_ACTIVE
Fork outputFork = swingTerminal ? priorSwingFork : longerTerminal ? priorLongerFork : panelFork
bool outputHasFork = not na(outputFork)
bool outputHasVolatility = outputHasFork and outputFork.volatility > 0 and pricesValid
plot(outputHasVolatility ? (close - medianAt(outputFork, bar_index)) / outputFork.volatility : na, "Close to median (ATR)", color = PLOT_TINT, display = display.data_window)
plot(outputHasVolatility ? (close - upperAt(outputFork, bar_index)) / outputFork.volatility : na, "Close to upper (ATR)", color = PLOT_TINT, display = display.data_window)
plot(outputHasVolatility ? (close - lowerAt(outputFork, bar_index)) / outputFork.volatility : na, "Close to lower (ATR)", color = PLOT_TINT, display = display.data_window)
plot(outputHasFork ? outputFork.state : na, "State code", color = PLOT_TINT, display = display.data_window)
plot(outputHasFork ? outputFork.side : na, "Side", color = PLOT_TINT, display = display.data_window)
plot(outputHasFork ? outputFork.variant : na, "Variant code", color = PLOT_TINT, display = display.data_window)
plot(outputHasFork ? array.get(outputFork.countsArray, 0) : na, "Touches upper", color = PLOT_TINT, display = display.data_window)
plot(outputHasFork ? array.get(outputFork.countsArray, 1) : na, "Touches median", color = PLOT_TINT, display = display.data_window)
plot(outputHasFork ? array.get(outputFork.countsArray, 2) : na, "Touches lower", color = PLOT_TINT, display = display.data_window)
plot(outputHasFork ? TOUCH_BAND_ATR : na, "Touch band (ATR)", color = PLOT_TINT, display = display.data_window)
plot(outputHasFork ? lastConfirmedIndex - outputFork.available : na, "Bars since known", color = PLOT_TINT, display = display.data_window)

plot(outputHasFork ? outputFork.layer : na, "Output layer", color = PLOT_TINT, display = display.data_window)
plot(swingTerminal ? priorSwingFork.state : na, "Swing terminal event", color = PLOT_TINT, display = display.data_window)
plot(longerTerminal ? priorLongerFork.state : na, "Longer terminal event", color = PLOT_TINT, display = display.data_window)

// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────

var array<string> pendingMessagesArray = array.new<string>()
var int pendingChars = 0
var int pendingDropped = 0
var int lastDelivery = na
bool deliveryDue = false
if barstate.isconfirmed and barstate.isrealtime
    for message in messagesArray
        array.push(pendingMessagesArray, message)
        pendingChars += str.length(message)
        while array.size(pendingMessagesArray) > ALERT_QUEUE_EVENTS or pendingChars > ALERT_QUEUE_CHARS
            pendingChars -= str.length(array.shift(pendingMessagesArray))
            pendingDropped += 1
    deliveryDue := (array.size(pendingMessagesArray) > 0 or pendingDropped > 0) and (na(lastDelivery) or timenow - lastDelivery >= ALERT_INTERVAL_MS)

alertcondition(array.get(flagsArray, EV_FORMED) == 1 and formedAlertInput, "Fork formed", "Auto Pitchfork + Trade Levels [AFD]: one or more forks formed on this confirmed bar; the separately delivered detailed records carry each event's own time.")
alertcondition(array.get(flagsArray, EV_MEDIAN) == 1 and medianAlertInput, "Median reached", "Auto Pitchfork + Trade Levels [AFD]: one or more first-median touches occurred on this confirmed bar; the separately delivered detailed records carry each event's own time.")
alertcondition(array.get(flagsArray, EV_RETURN) == 1 and returnAlertInput, "Parallel touch", "Auto Pitchfork + Trade Levels [AFD]: one or more line touches occurred on this confirmed bar; the separately delivered detailed records carry each event's own time.")
alertcondition(array.get(flagsArray, EV_ENDED) == 1 and endedAlertInput, "Fork ended", "Auto Pitchfork + Trade Levels [AFD]: one or more forks stopped counting on this confirmed bar; the separately delivered detailed records carry each event's own time.")

if deliveryDue
    string batch = "Auto Pitchfork + Trade Levels [AFD] | " + syminfo.tickerid + " | " + timeframe.period + " | " + BUILD_ID + " | " + configurationText() + " | dropped events " + str.tostring(pendingDropped) + "\n" + array.join(pendingMessagesArray, "\n")
    if detailInput == DETAIL_JSON
        batch := jsonEnvelope(pendingMessagesArray, pendingDropped)
    alert(batch, alert.freq_once_per_bar_close)
    lastDelivery := timenow
    array.clear(pendingMessagesArray)
    pendingChars := 0
    pendingDropped := 0
````
