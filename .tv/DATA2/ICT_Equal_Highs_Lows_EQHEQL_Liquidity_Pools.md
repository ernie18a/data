<!-- tradingview-pine-id: PUB;a63732ebf46747179a64d642cfab685a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Equal Highs & Lows (EQH/EQL) Liquidity Pools

Source: https://www.tradingview.com/script/0qehowvK-ICT-Equal-Highs-Lows-EQH-EQL-Liquidity-Pools/

## Description

ICT Equal Highs & Lows (EQH/EQL) Liquidity Pools

What it does
This indicator marks the horizontal shelves that form when two or more confirmed swing highs, or swing lows, come to rest at almost the same price. Those shelves are where resting orders accumulate, and the script answers one question about each of them: is this shelf still untouched, has price wicked through it, or has price closed beyond it? Lines are drawn only where the swing anchors themselves are visible on the chart, so you can always see why a line sits where it sits.

How it works
Every swing point starts an invisible hypothesis: a shelf at that price, with a tolerance band around it. The hypothesis has to survive. If price leaves the band before a second qualifying swing arrives, the hypothesis is dead and a later similar price cannot bring it back. Only a hypothesis that survives long enough to collect the required number of swings becomes a visible pool.

[*] Swing points are confirmed pivots, found from wicks or from candle bodies. A takeout is always measured on the wick, whichever mode you pick: price trading through the shelf is what takes it, however the swings themselves were found.
[*] The tolerance is frozen with the volatility of the swing that started the shelf. A later change in volatility can never pair two old swings after the fact.
[*] When a shelf is confirmed, every bar since its first anchor is replayed against it, oldest first. The first bar that went past its boundary decides both what happened and when, so a shelf that was already taken never appears as untouched.
[*] Once a pool becomes visible, its level and its boundary are fixed. Further swings at the same price raise the counter on the label and nothing else.
[*] The visible line sits on the extreme of the price group that confirmed it - the highest of the equal highs, the lowest of the equal lows, or the outermost body edge if you switched the swing source to Bodies - so it lies on a price that was actually traded and touches the structure it names. The boundary that decides a takeout sits past the outermost wick of that group, plus a buffer - a poke inside the band the shelf was defined with is noise rather than a takeout. That wick is first capped at the edge of the tolerance band, so a single oversized wick on the first swing cannot lift the boundary off the chart. Measuring the boundary from wicks matters under Bodies: a level is a body edge there, and the same bar's wick reaches past it, so a shelf would otherwise be taken by the very bar that confirmed it.
[*] A wick beyond the boundary marks the pool as swept. A close beyond it marks the pool as broken.

How to use it

[*] Add the script to a chart. It works on any symbol and any timeframe and reads only the bars of the chart you are on.
[*] With the default line style, read the solid lines as untouched shelves and the dashed ones as shelves price has already taken. Pick another style and the untouched ones follow it; a shelf that has been taken always draws dashed. Switch on Highlight nearest untapped pools if you also want the closest untouched shelf on each side drawn one step thicker.
[*] Check the anchors. Every line should start at a swing you can point at, and the price of that swing should sit within the tolerance you configured.
[*] If the chart shows more lines than you can read, lower the tolerance or raise the minimum number of equal highs and lows before touching the retention cap.

Inputs

[*] Swing length - bars required on each side of a swing point. Larger values give fewer and more significant shelves. Range 1-50, default 5.
[*] Measure swings from - Wicks uses the high and low, Bodies uses the open and close and ignores single long wicks.
[*] History searched - how long an unconfirmed hypothesis may wait for its second swing, and how far back a newly confirmed shelf is checked. Range 50-500, default 500.
[*] Tolerance unit - ATR multiple, ticks, or percent of price.
[*] Tolerance - how far apart two swings may sit and still count as equal. Default 0.10, which on a volatile index future works out around ten ticks.
[*] ATR length - length of the volatility measure, used by the ATR mode only. Range 1-200, default 14.
[*] Minimum equal highs/lows per pool - swings needed before a shelf becomes visible. Range 2-10, default 2.
[*] Takeout buffer - distance beyond the edge of the shelf that price must exceed before the pool counts as taken, in units of the frozen tolerance. Range 0-3, default 0.25, which is small enough that a stop run of a few ticks registers.
[*] Display group - show or hide each side, keep or drop swept and broken pools, retention cap per side, line width, line transparency, line style, labels and label size. Broken pools are dropped by default, so switch that on if you want all three states on the chart.
[*] Show EQH/EQL text and Show number of equal highs/lows - the label reads EQH 3x with both on, which is the default. Either can be switched off on its own.
[*] Line style - solid, dashed or dotted for the intact shelves. A shelf that has been taken always draws dashed, because that is its state and not a preference.
[*] Label background - off by default, so only the label text shows. Turn it on where a label sits over the candles and the bare text is hard to read.
[*] Highlight nearest untapped pools - draws the nearest untouched shelf on each side one step thicker. Off by default: a line that is thicker for a reason the chart does not explain is harder to read, not easier.
[*] Colors group - one colour each for buyside, sellside, swept and broken pools.

Signals and alerts

[*] Buyside pool formed and Sellside pool formed - fire when a shelf becomes visible and is still untouched.
[*] Buyside pool swept and Sellside pool swept - fire when a wick crosses the boundary and the bar closes back inside.
[*] Buyside pool broken and Sellside pool broken - fire when a bar closes beyond the boundary.

All six fire on the close of the bar that produced the change. A shelf that the replay finds already taken raises no formation alert, because it was never visible as untouched.

Repainting
State changes only on a closed bar. On the live bar no shelf is added, removed or reclassified, so what you see on history is what you would have seen in real time. One thing does follow the live bar, and it rewrites nothing: the right edge of an untouched line. A second follows it only if you switch on Highlight nearest untapped pools - which line is marked as the nearest one ahead of price. Swing points are confirmed pivots and are therefore known a fixed number of bars after they happened; the script does not pretend otherwise, and it replays every bar since the shelf's first anchor, so a shelf cannot appear untouched at a price that was already traded through. Once a pool is visible its level and boundary are never rewritten.

Limitations

[*] The very first swing of a shelf is the one bar never replayed against the shelf itself - it cannot be, or under Bodies a long wick on that bar would invalidate its own shelf before it exists. Under Bodies a small share of shelves therefore start on a bar whose wick already reached past the boundary. The cap on the boundary keeps that bounded; under Wicks it cannot happen at all.
[*] A swing is confirmed only after the configured number of bars have passed, so a shelf always becomes visible later than it formed. That delay is inherent to pivots and cannot be removed without looking ahead.
[*] On very quiet or thinly traded symbols the tolerance can be wide relative to the actual range, which pairs swings a trader would not group together. Lower it or switch to the tick mode.
[*] The script reads only the bars of the chart timeframe. It does not look at higher timeframes, at intrabar data, or at volume.
[*] It describes shelves that exist and what happened to them. It does not rank them, score them, or suggest entries, exits or targets.
[*] Shelves are dropped once the retention cap per side is exceeded. Taken shelves go first; a shelf that still holds is only dropped when no taken one is left, and then the oldest goes. Deep history is not kept on the chart.
[*] A shelf can be taken before its second swing exists. It is then drawn from its first anchor to the takeout and marked as taken, which puts the second swing to the right of where the line ends while the touch count still includes it.
[*] Swing points must stand out from the bars around them. Two highs at the same price no further apart than the swing length cancel each other out, so a tight double top can go unmarked. Lower the swing length if you want those.

This script is a charting tool for educational purposes. It does not provide financial advice and does not predict future price movement. Trading carries risk; decisions and their outcome remain yours.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) KronosMMXM

//@version=6
indicator("ICT Equal Highs & Lows (EQH/EQL) Liquidity Pools", shorttitle = "Equal Highs & Lows (kronos)", overlay = true, max_lines_count = 250, max_labels_count = 250, max_bars_back = 500)

//#region TYPES ================================================================

enum SwingSource
    wicks  = "Wicks"
    bodies = "Bodies"

enum LineLook
    solid  = "Solid"
    dashed = "Dashed"
    dotted = "Dotted"

enum ToleranceMode
    atr     = "ATR multiple"
    ticks   = "Ticks"
    percent = "Percent of price"

// An invisible hypothesis. It can die before it is ever drawn, and it keeps the
// bar on which it died so a pivot whose own event predates that bar can still
// build the formation. Such a pool is terminal whenever the stretch since the
// anchor already took the POOL boundary. That boundary is a different line from
// the candidate band: it runs from the members' clamped wick extreme plus the
// buffer, and never reaches past anchorLevel +/- tol * (1 + buffer).
type Candidate
    int   anchorBar
    float anchorLevel
    float tol
    float bound
    int   members
    float edgeLevel
    float edgeWick
    int   deadBar  = na
    bool  promoted = false

// A confirmed structure. Everything geometric is frozen at promotion time.
type Pool
    int   anchorBar
    float anchorLevel
    float tol
    float level
    float bound
    int   touches
    int   state
    int   terminalBar = na
    line  shelf       = na
    label tag         = na

//#endregion

//#region CONSTANTS ============================================================

int    STATE_INTACT     = 0
int    STATE_SWEPT      = 1
int    STATE_BROKEN     = 2

color  BUYSIDE_COLOR    = #26a69aff
color  SELLSIDE_COLOR   = #ef5350ff
color  SWEPT_COLOR      = #b2b5beff
color  BROKEN_COLOR     = #787b86ff

string GRP_DETECTION    = "Detection"
string GRP_TOLERANCE    = "Tolerance"
string GRP_DISPLAY      = "Display"
string GRP_COLORS       = "Colors"

int    SWING_LEN_MAX    = 50
int    LOOKBACK_MAX     = 500
int    CANDIDATES_MAX   = 200
int    X_MIN_OFFSET     = 10000
int    ATR_LEN_MAX      = 200
int    TOUCHES_MIN      = 2
int    TOUCHES_MAX      = 10
int    POOLS_MAX        = 25
int    LINE_WIDTH_MIN   = 1
int    LINE_WIDTH_MAX   = 4
int    LABEL_SIZE_MIN   = 10
int    LABEL_SIZE_MAX   = 40
int    OPACITY_MAX      = 90

string TAG_BUYSIDE  = "EQH"
string TAG_SELLSIDE = "EQL"

string EVENT_BUY_FORMED  = "Buyside pool formed"
string EVENT_SELL_FORMED = "Sellside pool formed"
string EVENT_BUY_SWEPT   = "Buyside pool swept"
string EVENT_SELL_SWEPT  = "Sellside pool swept"
string EVENT_BUY_BROKEN  = "Buyside pool broken"
string EVENT_SELL_BROKEN = "Sellside pool broken"

string MSG_BUY_FORMED  = "Equal highs confirmed a new buyside liquidity pool."
string MSG_SELL_FORMED = "Equal lows confirmed a new sellside liquidity pool."
string MSG_BUY_SWEPT   = "A wick took a buyside pool and the bar closed back inside its boundary."
string MSG_SELL_SWEPT  = "A wick took a sellside pool and the bar closed back inside its boundary."
string MSG_BUY_BROKEN  = "A bar closed beyond the boundary of a buyside pool."
string MSG_SELL_BROKEN = "A bar closed beyond the boundary of a sellside pool."

string TIP_SWING = """Bars required on each side of a swing point. A pivot is only
known this many bars after it happened; the script replays that gap instead of
skipping it."""

string TIP_SOURCE = """Wicks find swings from the high and low. Bodies find them
from the open and close, so a single long wick does not create a swing. A takeout
is always measured on the wick, whichever mode you pick - price trading through
the shelf is what takes it."""

string TIP_LOOKBACK = """How far back an unconfirmed hypothesis may wait for its
second swing. It also limits how long a shelf may take to form. A swing is only
confirmed once the bars on its right are in, so the effective wait is this value
minus the swing length: set it to at least twice the swing length plus one, or
no pool can ever form."""

string TIP_TOLERANCE = """How far apart two swings may sit and still count as
equal. The value is frozen with the volatility of the swing that started the
shelf, so a later change in volatility cannot pair old swings after the fact."""

string TIP_MIN_TOUCHES = """Swings needed before a shelf becomes visible. Two is
usable here because a hypothesis dies as soon as price leaves its tolerance band,
so a surviving pair is a real shelf rather than any two similar prices."""

string TIP_TAKEOUT = """Distance beyond the edge of the shelf that price must
exceed before the pool counts as taken, measured in units of the frozen
tolerance. The default is small on purpose: a stop run a few ticks above the
shelf is the event this indicator exists for, while a one-tick jitter is not."""

string TIP_MAX_POOLS = """Retention only. It caps how many pools stay on the
chart per side and never decides whether a pool is valid."""

string TIP_LINE_STYLE = """Solid, dashed or dotted, applied to every shelf
line the script draws."""

string TIP_LABEL_PLATE = """Draws an opaque plate behind the label text. Off by
default so only the text shows. Turn it on where a label sits over the candles
and the bare text is hard to read."""

string TIP_DOL = """Draws the nearest untouched shelf on each side one step
thicker. Off by default: a line that is thicker for a reason the chart does not
explain is harder to read, not easier."""

string TIP_OPACITY = """Transparency of the shelf lines, 0 is solid. Raise it on
dense charts or on small screens where solid lines hide price."""

string TIP_LABEL_SIZE = """Text size of the shelf labels in points."""

//#endregion

//#region INPUTS ===============================================================

int           swingLenInput     = input.int(5, "Swing length (bars each side)", minval = 1, maxval = SWING_LEN_MAX, group = GRP_DETECTION, tooltip = TIP_SWING)
SwingSource   sourceModeInput   = input.enum(SwingSource.wicks, "Measure swings from", group = GRP_DETECTION, tooltip = TIP_SOURCE)
int           poolLookbackInput = input.int(500, "History searched (bars)", minval = 50, maxval = LOOKBACK_MAX, group = GRP_DETECTION, tooltip = TIP_LOOKBACK)

ToleranceMode tolModeInput      = input.enum(ToleranceMode.atr, "Tolerance unit", group = GRP_TOLERANCE)
float         tolValueInput     = input.float(0.10, "Tolerance", minval = 0.01, maxval = 100.0, step = 0.01, group = GRP_TOLERANCE, tooltip = TIP_TOLERANCE)
int           atrLenInput       = input.int(14, "ATR length", minval = 1, maxval = ATR_LEN_MAX, group = GRP_TOLERANCE, active = tolModeInput == ToleranceMode.atr)
int           minTouchesInput   = input.int(2, "Minimum equal highs/lows per pool", minval = TOUCHES_MIN, maxval = TOUCHES_MAX, group = GRP_TOLERANCE, tooltip = TIP_MIN_TOUCHES)
float         takeoutInput      = input.float(0.25, "Takeout buffer (tolerances)", minval = 0.0, maxval = 3.0, step = 0.05, group = GRP_TOLERANCE, tooltip = TIP_TAKEOUT)

bool          showBuysideInput  = input.bool(true, "Show buyside pools (equal highs)", group = GRP_DISPLAY)
bool          showSellsideInput = input.bool(true, "Show sellside pools (equal lows)", group = GRP_DISPLAY)
bool          showSweptInput    = input.bool(true, "Keep pools after they are swept", group = GRP_DISPLAY)
bool          showBrokenInput   = input.bool(false, "Keep pools after they are broken", group = GRP_DISPLAY)
bool          showDolInput      = input.bool(false, "Highlight nearest untapped pools", group = GRP_DISPLAY, tooltip = TIP_DOL)
int           maxPoolsInput     = input.int(6, "Pools kept per side", minval = 1, maxval = POOLS_MAX, group = GRP_DISPLAY, tooltip = TIP_MAX_POOLS)
int           lineWidthInput    = input.int(1, "Line width", minval = LINE_WIDTH_MIN, maxval = LINE_WIDTH_MAX, group = GRP_DISPLAY)
int           lineOpacityInput  = input.int(20, "Line opacity", minval = 0, maxval = OPACITY_MAX, group = GRP_DISPLAY, tooltip = TIP_OPACITY)
LineLook      lineLookInput     = input.enum(LineLook.solid, "Line style", group = GRP_DISPLAY, tooltip = TIP_LINE_STYLE)
bool          showLabelsInput   = input.bool(true, "Show labels", group = GRP_DISPLAY)
bool          showPricesInput   = input.bool(false, "Show price in labels", group = GRP_DISPLAY, active = showLabelsInput)
bool          showTouchesInput  = input.bool(true, "Show number of equal highs/lows", group = GRP_DISPLAY, active = showLabelsInput)
bool          showTagInput      = input.bool(true, "Show EQH/EQL text", group = GRP_DISPLAY, active = showLabelsInput)
int           labelSizeInput    = input.int(12, "Label size", minval = LABEL_SIZE_MIN, maxval = LABEL_SIZE_MAX, group = GRP_DISPLAY, active = showLabelsInput and (showTagInput or showTouchesInput or showPricesInput), tooltip = TIP_LABEL_SIZE)
bool          labelPlateInput   = input.bool(false, "Label background", group = GRP_DISPLAY, tooltip = TIP_LABEL_PLATE, active = showLabelsInput and (showTagInput or showTouchesInput or showPricesInput))

color         colBuysideInput   = input.color(BUYSIDE_COLOR, "Buyside pool", group = GRP_COLORS, active = showBuysideInput)
color         colSellsideInput  = input.color(SELLSIDE_COLOR, "Sellside pool", group = GRP_COLORS, active = showSellsideInput)
color         colSweptInput     = input.color(SWEPT_COLOR, "Swept pool", group = GRP_COLORS, active = showSweptInput)
color         colBrokenInput    = input.color(BROKEN_COLOR, "Broken pool", group = GRP_COLORS, active = showBrokenInput)

//#endregion

//#region FUNCTIONS ============================================================

// @function        Maps the chosen look to a Pine line style constant.
// @param look      (LineLook) Style picked in the settings.
// @returns         (series string) Matching `line.style_*` constant.
lineStyleOf(LineLook look) =>
    switch look
        LineLook.dashed => line.style_dashed
        LineLook.dotted => line.style_dotted
        =>                 line.style_solid

// @function        Opaque plate or none, depending on the setting.
// @param on        (bool) Whether the plate is switched on.
// @returns         (series color) Label background colour.
labelPlate(bool on) =>
    color.new(chart.bg_color, on ? 0 : 100)

// @function        Signed "is price past this boundary" so both sides share one path.
// @param isBuy     (bool) True for equal highs, false for equal lows.
// @param price     (float) Price being tested.
// @param boundary  (float) Boundary to test against.
// @returns         (series bool) True when price sits beyond the boundary.
beyond(bool isBuy, float price, float boundary) =>
    isBuy ? price > boundary : price < boundary

// @function        Moves a level away from the market in the side's direction.
// @param isBuy     (bool) True for equal highs, false for equal lows.
// @param level     (float) Level to move.
// @param distance  (float) Absolute distance to add.
// @returns         (series float) Shifted level.
offsetLevel(bool isBuy, float level, float distance) =>
    isBuy ? level + distance : level - distance

// @function        Tolerance for one swing, measured with that swing's own data.
// @param atrEvent  (float) ATR as of the swing's event bar.
// @param priceAt    (float) Swing price, used by the percent mode.
// @returns         (series float) Half-width of the price group, in price units.
// Dependencies     tolModeInput, tolValueInput
eventTolerance(float atrEvent, float priceAt) =>
    switch tolModeInput
        ToleranceMode.atr   => tolValueInput * atrEvent
        ToleranceMode.ticks => tolValueInput * syminfo.mintick
        =>                     priceAt * tolValueInput / 100.0

// @function        Applies one past or present bar to a pool.
// @param pool      (Pool) Pool to advance.
// @param isBuy     (bool) Side of the pool.
// @param back      (int) Bars back from the current bar; 0 is the current bar.
// @returns         (series int) State the pool holds after that bar.
advancePool(Pool pool, bool isBuy, int back) =>
    if pool.state == STATE_INTACT
        float extreme = isBuy ? high[back] : low[back]
        if beyond(isBuy, extreme, pool.bound)
            // A wick through the boundary is a sweep, a close beyond it is a break.
            bool closedPast  = beyond(isBuy, close[back], pool.bound)
            pool.state       := closedPast ? STATE_BROKEN : STATE_SWEPT
            pool.terminalBar := bar_index - back
    pool.state

// @function        Applies one past or present bar to a hypothesis.
// @param cand      (Candidate) Hypothesis to advance.
// @param isBuy     (bool) Side of the hypothesis.
// @param back      (int) Bars back from the current bar; 0 is the current bar.
// @returns         (void)
advanceCandidate(Candidate cand, bool isBuy, int back) =>
    if na(cand.deadBar) and not cand.promoted
        float extreme = isBuy ? high[back] : low[back]
        if beyond(isBuy, extreme, cand.bound)
            cand.deadBar := bar_index - back

// @function        Replays a span of bars against a pool, oldest bar first.
//                  The FIRST bar beyond the boundary decides state and time -
//                  that is the rule, and only a replay in order can find it.
// @param pool      (Pool) Freshly promoted pool.
// @param isBuy     (bool) Side of the pool.
// @param gap       (int) Number of bars to replay, ending at the current bar.
// @returns         (void)
catchUp(Pool pool, bool isBuy, int gap) =>
    if gap > 0
        for k = 0 to gap - 1
            advancePool(pool, isBuy, gap - 1 - k)

// @function        Replays the gap between a swing's event and its confirmation.
// @param cand      (Candidate) Hypothesis just created on the confirmation bar.
// @param isBuy     (bool) Side of the hypothesis.
// @param gap       (int) Number of bars between event and confirmation.
// @returns         (void)
catchUpCandidate(Candidate cand, bool isBuy, int gap) =>
    if gap > 0
        for k = 0 to gap - 1
            advanceCandidate(cand, isBuy, gap - 1 - k)

// @function        Removes the drawings of a pool that is about to be dropped.
// @param pool      (Pool) Pool being discarded.
// @returns         (void)
clearPool(Pool pool) =>
    line.delete(pool.shelf)
    label.delete(pool.tag)
    pool.shelf := na
    pool.tag   := na

// advanceSide(), findPool(), findCandidate(), joinCandidate(), promote(),
// handleSwing(), pruneCandidates() and prunePools() live below the inputs:
// they read swingLenInput, poolLookbackInput, minTouchesInput and the ATR
// series, so they cannot stand here (HOUSE-STYLE A.8).

//#endregion

//#region CALCULATIONS =========================================================

var array<Candidate> buyCandidates  = array.new<Candidate>()
var array<Candidate> sellCandidates = array.new<Candidate>()
var array<Pool>      buyPools       = array.new<Pool>()
var array<Pool>      sellPools      = array.new<Pool>()

float swingHighSource = sourceModeInput == SwingSource.wicks ? high : math.max(open, close)
float swingLowSource  = sourceModeInput == SwingSource.wicks ? low : math.min(open, close)
float atrSeries       = ta.atr(atrLenInput)

// The tolerance belongs to the swing, not to the bar that reveals it.
float atrAtEvent = atrSeries[swingLenInput]
int   eventBar   = bar_index - swingLenInput

// Warm-up gate: stay silent until a pivot could exist and the ATR is defined.
bool atrReady = tolModeInput != ToleranceMode.atr or not na(atrAtEvent)
bool warmedUp = bar_index >= 2 * swingLenInput and atrReady

// State only ever advances on a closed bar. An intrabar wick would otherwise
// lock a pool into "swept" before the same bar could still close beyond the
// boundary and make it "broken" - and it would differ from history.
bool advanceNow = warmedUp and barstate.isconfirmed

// --- Per-bar lifecycle of hypotheses and pools ---
// These functions live below the arrays and inputs they work on (HOUSE-STYLE A.8).

// @function        Applies the current bar to one side's candidates and pools.
// @param cands     (array<Candidate>) Candidates of that side.
// @param pools     (array<Pool>) Pools of that side.
// @param isBuy     (bool) Side being advanced.
// @returns         ([bool, bool]) Whether a sweep and a break happened this bar.
// Dependencies     advanceNow
advanceSide(array<Candidate> cands, array<Pool> pools, bool isBuy) =>
    bool sweptNow  = false
    bool brokenNow = false
    if advanceNow
        if array.size(cands) > 0
            for i = 0 to array.size(cands) - 1
                advanceCandidate(array.get(cands, i), isBuy, 0)
        if array.size(pools) > 0
            for i = 0 to array.size(pools) - 1
                Pool pool = array.get(pools, i)
                int before = pool.state
                int after  = advancePool(pool, isBuy, 0)
                sweptNow  := sweptNow or (before == STATE_INTACT and after == STATE_SWEPT)
                brokenNow := brokenNow or (before == STATE_INTACT and after == STATE_BROKEN)
    [sweptNow, brokenNow]

// @function        Intact pool nearest in price that already existed at the event.
// @param pools     (array<Pool>) Pools of one side.
// @param level     (float) Swing price at its event bar.
// @param tol       (float) Tolerance frozen at that event bar.
// @returns         (Pool) Matching pool, or na when the swing joins nothing.
// Dependencies     eventBar
findPool(array<Pool> pools, float level, float tol) =>
    Pool  found = na
    float best  = na
    if array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            Pool pool = array.get(pools, i)
            bool alive = na(pool.terminalBar) or eventBar < pool.terminalBar
            float dist = math.abs(level - pool.anchorLevel)
            // Event time binds every pivot, not just the first: the smaller of
            // the two frozen tolerances decides.
            float limit = math.min(pool.tol, tol)
            if alive and dist <= limit and (na(best) or dist < best)
                found := pool
                best  := dist
    found

// @function        Hypothesis nearest in price that was still usable at the event.
// @param cands     (array<Candidate>) Candidates of one side.
// @param level     (float) Swing price at its event bar.
// @param tol       (float) Tolerance frozen at that event bar.
// @returns         (Candidate) Matching hypothesis, or na when none fits.
// Dependencies     eventBar
findCandidate(array<Candidate> cands, float level, float tol) =>
    Candidate found = na
    float     best  = na
    if array.size(cands) > 0
        for i = 0 to array.size(cands) - 1
            Candidate cand = array.get(cands, i)
            bool usable = not cand.promoted and (na(cand.deadBar) or eventBar < cand.deadBar)
            float dist = math.abs(level - cand.anchorLevel)
            float limit = math.min(cand.tol, tol)
            if usable and dist <= limit and (na(best) or dist < best)
                found := cand
                best  := dist
    found

// @function        Adds a confirmed swing to a hypothesis it belongs to.
// @param host      (Candidate) Hypothesis being extended.
// @param isBuy     (bool) Side of the hypothesis.
// @param level     (float) Swing price at its event bar.
// @param wick      (float) Wick extreme of that same bar. Under `Bodies` it
//                  reaches past the level; under `Wicks` the two are equal.
// @returns         (void)
joinCandidate(Candidate host, bool isBuy, float level, float wick) =>
    host.members   := host.members + 1
    host.edgeLevel := isBuy ? math.max(host.edgeLevel, level) : math.min(host.edgeLevel, level)
    // Clamped to the hypothesis band. Every member except the anchor was
    // already tested against that band on its own event bar, so the clamp only
    // ever bites on the anchor - and it must, see promote().
    float capped   = isBuy ? math.min(wick, host.bound) : math.max(wick, host.bound)
    host.edgeWick  := isBuy ? math.max(host.edgeWick, capped) : math.min(host.edgeWick, capped)

// @function        Turns a hypothesis into a visible pool with frozen geometry.
// @param host      (Candidate) Hypothesis that reached the required swing count.
// @param pools     (array<Pool>) Pools of that side.
// @param isBuy     (bool) Side of the hypothesis.
// @returns         (series bool) True when the new pool is intact after catch-up.
// Dependencies     eventBar, swingLenInput, takeoutInput
promote(Candidate host, array<Pool> pools, bool isBuy) =>
    // Two values with two meanings. The visible level is the EXTREME of the
    // price group - the highest equal high, the lowest equal low - so the line
    // sits where the high actually was and touches the structure it names. It
    // is frozen here: a later, higher member raises `touches` and nothing else,
    // or historical geometry would move (that was defect 3 of the 24.08 build).
    // The boundary sits past the group plus the buffer.
    //
    // The boundary is built from the members' WICK extremes, never from their
    // levels. Under `Bodies` a level is a body edge, and the same bar's wick
    // reaches past it - the replay would then let a shelf take itself on the
    // very bar that confirmed it, and no pool would ever be born intact.
    // Under `Wicks` level and wick are the same value, so nothing changes.
    //
    // Every wick is clamped to the hypothesis band first. The ANCHOR bar is the
    // one bar the replay never tests (catchUpCandidate starts at eventBar+1) -
    // it has to be, or a Bodies anchor would kill its own hypothesis. Feeding
    // that untested wick in raw would leave the boundary with no ceiling at
    // all: a rejection candle with a three-ATR wick would push it far above the
    // drawn line, and the shelf would stay solid while price ran through it.
    // Clamped, the boundary never reaches past anchorLevel +/- tol * (1 + buffer).
    float centre = host.edgeLevel
    float edge   = offsetLevel(isBuy, host.edgeWick, takeoutInput * host.tol)
    Pool born = Pool.new(
      anchorBar   = host.anchorBar,
      anchorLevel = host.anchorLevel,
      tol         = host.tol,
      level       = centre,
      bound       = edge,
      touches     = host.members,
      state       = STATE_INTACT)
    host.promoted := true
    array.push(pools, born)
    // The whole span since the anchor is replayed in order. Two separate
    // aggregates can report state and time from different bars - only replaying
    // in order finds the first bar beyond the boundary.
    catchUp(born, isBuy, bar_index - host.anchorBar)
    born.state == STATE_INTACT

// @function        Routes one confirmed swing: count it, extend a hypothesis, or start one.
// @param cands     (array<Candidate>) Candidates of that side.
// @param pools     (array<Pool>) Pools of that side.
// @param isBuy     (bool) Side of the swing.
// @param level     (float) Swing price at its event bar.
// @param tol       (float) Tolerance frozen at that event bar.
// @returns         (series bool) True when a pool became visible and is intact.
// Dependencies     eventBar, minTouchesInput
handleSwing(array<Candidate> cands, array<Pool> pools, bool isBuy, float level, float tol) =>
    bool formed = false
    // Wick extreme of the swing's own bar, taken at the same offset as `level`,
    // and the band a hypothesis anchored here would carry.
    float wick  = isBuy ? high[swingLenInput] : low[swingLenInput]
    float band  = offsetLevel(isBuy, level, tol)
    Pool target = findPool(pools, level, tol)
    if not na(target)
        // Later members raise the counter. They never move level or boundary.
        target.touches := target.touches + 1
    else
        Candidate host = findCandidate(cands, level, tol)
        if na(host)
            Candidate fresh = Candidate.new(
              anchorBar   = eventBar,
              anchorLevel = level,
              tol         = tol,
              bound       = band,
              members     = 1,
              edgeLevel   = level,
              edgeWick    = isBuy ? math.min(wick, band) : math.max(wick, band))
            array.push(cands, fresh)
            // A hypothesis is also only known swingLen bars after its event.
            // Without this replay it would be born blind to that gap.
            catchUpCandidate(fresh, isBuy, swingLenInput)
        else
            joinCandidate(host, isBuy, level, wick)
            if host.members >= minTouchesInput
                formed := promote(host, pools, isBuy)
    formed

// @function        Drops hypotheses that can no longer produce a valid pool.
// @param cands     (array<Candidate>) Candidates of one side.
// @returns         (void)
// Dependencies     swingLenInput, poolLookbackInput
pruneCandidates(array<Candidate> cands) =>
    if array.size(cands) > 0
        for i = array.size(cands) - 1 to 0
            Candidate cand = array.get(cands, i)
            // A hypothesis dead for longer than the confirmation gap can never be
            // reached again: every future swing event is younger than its death.
            bool expired = cand.promoted
              or (not na(cand.deadBar) and bar_index - cand.deadBar > swingLenInput)
              or (bar_index - cand.anchorBar > poolLookbackInput)
            if expired
                array.remove(cands, i)
    // Hard cap: without it the list grows at swingLen = 1 with a long lookback
    // until the three linear scans per bar become too expensive.
    while array.size(cands) > CANDIDATES_MAX
        array.shift(cands)

// @function        Applies visibility choices and the per-side retention cap.
// @param pools     (array<Pool>) Pools of one side.
// @returns         (void)
// Dependencies     showSweptInput, showBrokenInput, maxPoolsInput
prunePools(array<Pool> pools) =>
    if array.size(pools) > 0
        for i = array.size(pools) - 1 to 0
            Pool pool = array.get(pools, i)
            bool drop = (pool.state == STATE_SWEPT and not showSweptInput)
              or (pool.state == STATE_BROKEN and not showBrokenInput)
            if drop
                clearPool(pool)
                array.remove(pools, i)
    // Never discard a shelf that still holds while a taken one is available.
    while array.size(pools) > maxPoolsInput
        int victim = 0
        for i = 0 to array.size(pools) - 1
            if array.get(pools, i).state != STATE_INTACT
                victim := i
                break
        clearPool(array.get(pools, victim))
        array.remove(pools, victim)

[buySweptNow, buyBrokenNow]   = advanceSide(buyCandidates, buyPools, true)
[sellSweptNow, sellBrokenNow] = advanceSide(sellCandidates, sellPools, false)

float buyPivot  = ta.pivothigh(swingHighSource, swingLenInput, swingLenInput)
float sellPivot = ta.pivotlow(swingLowSource, swingLenInput, swingLenInput)

float buyTol  = eventTolerance(atrAtEvent, buyPivot)
float sellTol = eventTolerance(atrAtEvent, sellPivot)

// Prune before the swings are routed, so a candidate can never be older than
// the lookback when it is promoted. Otherwise the replay would reach back
// lookback + 1 bars - one more than max_bars_back covers.
pruneCandidates(buyCandidates)
pruneCandidates(sellCandidates)

bool buyFormedNow  = false
bool sellFormedNow = false
if advanceNow and not na(buyPivot)
    buyFormedNow := handleSwing(buyCandidates, buyPools, true, buyPivot, buyTol)
if advanceNow and not na(sellPivot)
    sellFormedNow := handleSwing(sellCandidates, sellPools, false, sellPivot, sellTol)

prunePools(buyPools)
prunePools(sellPools)

//#endregion

//#region VISUALS ==============================================================

// @function        Index of the intact pool closest to price, or na if none.
// @param pools     (array<Pool>) Pools of one side.
// @param isBuy     (bool) Side being searched.
// @returns         (series int) Array index of the nearest untapped pool.
nearestIntact(array<Pool> pools, bool isBuy) =>
    int   found = na
    float best  = na
    if array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            Pool pool = array.get(pools, i)
            // State hangs on the boundary, so "still ahead" does too.
            bool ahead = isBuy ? pool.bound > close : pool.bound < close
            float dist = math.abs(pool.bound - close)
            if pool.state == STATE_INTACT and ahead and (na(best) or dist < best)
                found := i
                best  := dist
    found

// @function        Draws or updates one pool, reusing its line and label.
// @param pool      (Pool) Pool to render.
// @param isBuy     (bool) Side of the pool.
// @param isDol     (bool) True when this is the nearest untapped pool.
// @returns         (void)
// Dependencies     the display and colour inputs
renderPool(Pool pool, bool isBuy, bool isDol) =>
    color base = pool.state == STATE_SWEPT ? colSweptInput
      : pool.state == STATE_BROKEN ? colBrokenInput
      : isBuy ? colBuysideInput : colSellsideInput
    color shade    = color.new(base, lineOpacityInput)
    // Smallest permitted x coordinate (PINE-FEATURES 1.7), on both edges.
    int   leftBar  = math.max(pool.anchorBar, bar_index - X_MIN_OFFSET)
    int   rawRight = pool.state == STATE_INTACT ? bar_index : pool.terminalBar
    int   rightBar = math.max(rawRight, leftBar)
    // A terminal shelf stays dashed whatever the setting - that is state, not
    // taste. The setting governs the intact ones.
    string dash    = pool.state == STATE_INTACT ? lineStyleOf(lineLookInput) : line.style_dashed
    int    width   = lineWidthInput + (isDol and pool.state == STATE_INTACT ? 1 : 0)
    if na(pool.shelf)
        pool.shelf := line.new(
          leftBar, pool.level, rightBar, pool.level,
          xloc = xloc.bar_index)
    line.set_xy1(pool.shelf, leftBar, pool.level)
    line.set_xy2(pool.shelf, rightBar, pool.level)
    line.set_color(pool.shelf, shade)
    line.set_style(pool.shelf, dash)
    line.set_width(pool.shelf, width)
    string tagText = ""
    if showTagInput
        tagText := isBuy ? TAG_BUYSIDE : TAG_SELLSIDE
    if showTouchesInput
        string gapT = str.length(tagText) > 0 ? " " : ""
        tagText := tagText + gapT + str.tostring(pool.touches) + "x"
    if showPricesInput
        string gap = str.length(tagText) > 0 ? " " : ""
        tagText := tagText + gap + str.tostring(pool.level, format.mintick)
    if showLabelsInput and str.length(tagText) > 0
        if na(pool.tag)
            pool.tag := label.new(
              rightBar, pool.level, tagText,
              style     = label.style_label_left,
              color     = labelPlate(labelPlateInput),
              textcolor = chart.fg_color,
              size      = labelSizeInput,
              xloc      = xloc.bar_index)
        label.set_color(pool.tag, labelPlate(labelPlateInput))
        label.set_xy(pool.tag, rightBar, pool.level)
        label.set_text(pool.tag, tagText)
        label.set_size(pool.tag, labelSizeInput)
        // Pine types both branches of an if even when nothing reads the result;
        // the bare na keeps them compatible (CE10235).
        na
    else
        label.delete(pool.tag)
        pool.tag := na

// @function        Renders one side, or clears it when the side is hidden.
// @param pools     (array<Pool>) Pools of one side.
// @param isBuy     (bool) Side being rendered.
// @param visible   (bool) Whether the side is shown at all.
// @returns         (void)
// Dependencies     showDolInput
renderSide(array<Pool> pools, bool isBuy, bool visible) =>
    int nearestIdx = nearestIntact(pools, isBuy)
    int dolIndex   = showDolInput and visible ? nearestIdx : na
    if array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            Pool pool = array.get(pools, i)
            if visible
                renderPool(pool, isBuy, not na(dolIndex) and i == dolIndex)
            else
                clearPool(pool)

renderSide(buyPools, true, showBuysideInput)
renderSide(sellPools, false, showSellsideInput)

//#endregion

//#region ALERTS ===============================================================

// Only transitions on the current bar fire. A pool that the catch-up finds
// already taken never was visible as intact, so it raises no formation alert.
alertcondition(buyFormedNow, title = EVENT_BUY_FORMED, message = MSG_BUY_FORMED)
alertcondition(sellFormedNow, title = EVENT_SELL_FORMED, message = MSG_SELL_FORMED)
alertcondition(buySweptNow, title = EVENT_BUY_SWEPT, message = MSG_BUY_SWEPT)
alertcondition(sellSweptNow, title = EVENT_SELL_SWEPT, message = MSG_SELL_SWEPT)
alertcondition(buyBrokenNow, title = EVENT_BUY_BROKEN, message = MSG_BUY_BROKEN)
alertcondition(sellBrokenNow, title = EVENT_SELL_BROKEN, message = MSG_SELL_BROKEN)

//#endregion
````
