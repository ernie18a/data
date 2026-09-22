<!-- tradingview-pine-id: PUB;422fe06396b243e190bbdb823d728ec4 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Signal Audit Lab [BSL]

Source: https://www.tradingview.com/script/g4p0NHXW-Signal-Audit-Lab-BSL/

## Description

Signal Audit Lab measures what happens after numeric events emitted by another
indicator. Connect one external plot, define how its values become long and
short events, and inspect the resulting sample on the current symbol and
timeframe.

This is a measurement tool. It does not generate signals, simulate orders, or
claim that an observed event has a trading edge.

HOW IT WORKS

The script reads one numeric `input.source()` series. Four decoders are
available:

- Signed pulse: positive and negative event pulses such as +1 / 0 / -1.
- Threshold cross: crossings above the long level or below the short level.
- Long-only edge: the first qualifying long value after a non-qualifying value.
- Short-only edge: the equivalent short-only rule.

Events are committed only on confirmed bars. Held values are deduplicated into
one edge. Optional cooldown and conflict rules make rejected events explicit.
An `na` transition cannot create an accidental first event without a prior
valid observation.

MEASUREMENT

The event-bar close is the anchor. Direction-adjusted forward returns are
measured after 1, 3, 5, 10 and 20 bars by default. Each horizon has its own
completed and pending sample count, so unfinished observations never enter the
denominator.

The round-trip cost input subtracts a user-defined basis-point amount from each
completed return. It is a sensitivity adjustment, not a fill, spread, slippage,
or execution model.

The panel reports:

- completed and pending observations;
- mean raw and cost-adjusted directional return;
- hit rate, return dispersion, and a Wilson 95% interval;
- separate aggregate, long, and short results;
- mean favorable and adverse excursion at the longest horizon;
- a payoff proxy based on mean positive versus mean negative net outcomes;
- longest-horizon session and normalized-ATR volatility splits;
- accepted long/short counts, cooldown rejects, conflicts, `na` skips, and
  configuration status.

Samples below 30 observations are highlighted. Compact mode keeps aggregate
horizons, excursion/payoff, and diagnostics readable on narrow charts. Full
mode adds directional detail, raw-to-net values, Wilson intervals, dispersion,
and the split tables.

SESSION AND VOLATILITY SPLITS

The session split classifies the event bar using the selected session and
timezone. The defaults are 09:30–16:00, Monday–Friday, America/New_York.

Volatility is normalized ATR (`ATR / close`) compared with its moving-average
baseline. Defaults are ATR 14 and baseline 100. LOW is below 0.8 times the
baseline, HIGH is above 1.2 times the baseline, and values between those
boundaries are MID. Events before the baseline is available are UNCLASSIFIED.
The exact settings remain visible in Full mode.

SETUP

1. Add an indicator that exposes a numeric plot. TradingView strategies cannot
   provide an external source plot.
2. Add Signal Audit Lab and select that plot under Event source.
3. Choose the decoder and levels that match the producer's numeric contract.
4. Enter a clear source label, then set horizons, cost sensitivity, session,
   and volatility boundaries.
5. Read the sample count and diagnostics before interpreting percentages.

For a continuous oscillator such as RSI, Threshold cross is the natural
decoder. For a producer that exposes +1 / 0 / -1 pulses, use Signed pulse.

OUTPUTS AND ALERTS

Optional chart markers show accepted confirmed events. A hidden +1 / 0 / -1
plot is available for inspection or data export. Alert conditions are provided
for “Accepted long event” and “Accepted short event”; they use the same
confirmed booleans as the statistics.

REPAINT AND DATA BOUNDARY

Signal Audit Lab does not commit its own events before bar close. Historical
and realtime tests confirm that an unconfirmed source flicker is excluded from
the statistics until confirmation.

This boundary cannot certify the upstream source. A connected indicator may
still repaint, use future-looking data, revise history, or change behavior after
an update. Reload and Bar Replay should be repeated for the specific producer
before relying on a result. The panel therefore labels source stability as
unverified.

LIMITATIONS

- Results describe the loaded chart history, symbol, timeframe, settings, and
  upstream plot. They are not universal and can change when any of these change.
- Close-to-close forward measurement is not an order-fill simulation or a
  strategy backtest.
- The cost input does not model spread, slippage, liquidity, partial fills,
  position sizing, pyramiding, or portfolio interaction.
- MFE and MAE use chart OHLC values inside the forward window; they do not prove
  an executable path through intrabar prices.
- Session and volatility splits are descriptive. Small or imbalanced buckets
  should not be treated as stable regimes.
- The script does not optimize settings, predict prices, or validate the logic
  of the connected producer.

Use the Lab to form a better question, then verify that question with a proper
execution model and out-of-sample process.

ORIGINALITY AND SOURCE

This is an original BarState Labs implementation built from an independent
written specification and deterministic acceptance fixtures. No protected,
invite-only, or closed-source implementation was used. The script uses standard
forward-return, variance, Wilson interval, excursion, and ATR calculations and
is published under the Mozilla Public License 2.0.

CHANGELOG

v1.0.0

- Initial open-source release.
- Four explicit event decoders with confirmed-bar commitment.
- Five configurable forward horizons and cost sensitivity.
- Aggregate, directional, excursion, session, and volatility evidence.
- Compact and Full panels, accepted-event markers, and two alert conditions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BarStateLabs
//@version=6
indicator("Signal Audit Lab [BSL]", "BSL Signal Audit", overlay = true, max_bars_back = 300)

// Signal Audit Lab measures confirmed numeric events emitted by an indicator.
// It is a diagnostic instrument, not a signal generator or strategy backtest.

const string GROUP_SOURCE = "01 · Connect a signal"
const string GROUP_EVENT = "02 · Decode events"
const string GROUP_HORIZONS = "03 · Measure forward"
const string GROUP_SPLITS = "04 · Segment results"
const string GROUP_OUTPUT = "05 · Display"

float eventSource = input.source(close, "Event source", group = GROUP_SOURCE,
     tooltip = "Select the numeric plot you want to measure. TradingView strategies cannot provide external source plots.")
string sourceLabelInput = input.string("NAME THIS SOURCE", "Source label", group = GROUP_SOURCE,
     tooltip = "Use a short label that identifies the producer and event, for example: Regime release.")
bool sourceBindingConfirmedInput = input.bool(false, "I verified this event source", group = GROUP_SOURCE,
     tooltip = "Turn this on only after selecting the intended plot and decoder. Until then, the Lab stays safely unarmed and does not mistake the chart's Close series for events.")

string modeInput = input.string("Signed pulse", "Decoder mode",
     options = ["Signed pulse", "Threshold cross", "Long-only edge", "Short-only edge"], group = GROUP_EVENT,
     tooltip = "Signed pulse fits +1/0/-1 event streams. Threshold cross fits continuous oscillators. Edge modes accept only one direction.")
float longLevelInput = input.float(1.0, "Long threshold", group = GROUP_EVENT, inline = "levels")
float shortLevelInput = input.float(-1.0, "Short threshold", group = GROUP_EVENT, inline = "levels")
string conflictInput = input.string("Reject both", "Conflict policy",
     options = ["Reject both", "Prefer long", "Prefer short"], group = GROUP_EVENT,
     tooltip = "Applied only when the same bar qualifies in both directions. Reject both avoids assigning a direction to a conflicting event.")
int cooldownInput = input.int(0, "Minimum gap, bars", minval = 0, maxval = 500, group = GROUP_EVENT,
     tooltip = "Reject new events for this many bars after an accepted event. Zero keeps every distinct confirmed edge.")
float costBpsInput = input.float(10.0, "Round-trip cost sensitivity, bps", minval = 0.0, maxval = 1000.0,
     step = 0.1, group = GROUP_EVENT,
     tooltip = "The default subtracts 10 bps from each completed forward return. This tests sensitivity to a non-zero cost. It does not model fills; set a value that fits the market.")

int h1Input = input.int(1, "H1", minval = 1, maxval = 200, group = GROUP_HORIZONS, inline = "h")
int h2Input = input.int(3, "H2", minval = 1, maxval = 200, group = GROUP_HORIZONS, inline = "h")
int h3Input = input.int(5, "H3", minval = 1, maxval = 200, group = GROUP_HORIZONS, inline = "h")
int h4Input = input.int(10, "H4", minval = 1, maxval = 200, group = GROUP_HORIZONS, inline = "h")
int h5Input = input.int(20, "H5", minval = 1, maxval = 200, group = GROUP_HORIZONS, inline = "h")

string sessionInput = input.session("0930-1600:23456", "Reference session", group = GROUP_SPLITS, inline = "session",
     tooltip = "Classifies the event bar as inside or outside this session. Adjust it for the market you are studying.")
string timezoneInput = input.string("America/New_York", "Session timezone", group = GROUP_SPLITS, inline = "session")
int atrLengthInput = input.int(14, "ATR length", minval = 2, maxval = 200, group = GROUP_SPLITS, inline = "vol")
int baselineLengthInput = input.int(100, "ATR baseline", minval = 20, maxval = 500, group = GROUP_SPLITS, inline = "vol")
float lowBoundaryInput = input.float(0.8, "Low ×", minval = 0.1, maxval = 2.0, step = 0.05,
     group = GROUP_SPLITS, inline = "bands")
float highBoundaryInput = input.float(1.2, "High ×", minval = 0.2, maxval = 5.0, step = 0.05,
     group = GROUP_SPLITS, inline = "bands")

string panelDensityInput = input.string("Compact", "Panel density", options = ["Full", "Compact"],
     group = GROUP_OUTPUT, tooltip = "Use Compact on narrow charts. Compact shows aggregate horizons, excursion/payoff and diagnostics; Full adds direction detail, raw returns, Wilson intervals, dispersion and split tables.")
bool showMarkersInput = input.bool(false, "Show accepted-event markers", group = GROUP_OUTPUT)
string panelPositionInput = input.string("Auto", "Panel position", options = ["Auto", "Top right", "Bottom right"],
     group = GROUP_OUTPUT, tooltip = "Auto keeps the panel opposite the latest price within the visible chart range.")

color C_INK = color.rgb(11, 14, 13)
color C_PANEL = color.rgb(20, 25, 23)
color C_PAPER = color.rgb(242, 239, 232)
color C_MUTED = color.rgb(137, 145, 141)
color C_AMBER = color.rgb(244, 184, 96)
color C_GREEN = color.rgb(114, 224, 165)
color C_RED = color.rgb(240, 120, 103)
color C_LINE = color.new(C_MUTED, 65)

bool horizonsValid = h1Input < h2Input and h2Input < h3Input and h3Input < h4Input and h4Input < h5Input
bool volatilityBandsValid = lowBoundaryInput < highBoundaryInput
bool configurationValid = horizonsValid and volatilityBandsValid
bool auditReady = configurationValid and sourceBindingConfirmedInput

var array<int> horizons = array.from(h1Input, h2Input, h3Input, h4Input, h5Input)

// Ten cells: long H1..H5, then short H1..H5.
var array<int> observationCount = array.new_int(10, 0)
var array<float> rawReturnSum = array.new_float(10, 0.0)
var array<float> netReturnSum = array.new_float(10, 0.0)
var array<float> netReturnSqSum = array.new_float(10, 0.0)
var array<int> hitCount = array.new_int(10, 0)
var array<float> positiveReturnSum = array.new_float(10, 0.0)
var array<int> positiveReturnCount = array.new_int(10, 0)
var array<float> negativeReturnSum = array.new_float(10, 0.0)
var array<int> negativeReturnCount = array.new_int(10, 0)

// Longest-horizon excursion arrays: long, short.
var array<int> excursionCount = array.new_int(2, 0)
var array<float> mfeSum = array.new_float(2, 0.0)
var array<float> maeSum = array.new_float(2, 0.0)

// Longest-horizon split arrays.
var array<int> sessionCount = array.new_int(2, 0)
var array<float> sessionNetSum = array.new_float(2, 0.0)
var array<int> sessionHits = array.new_int(2, 0)
var array<int> volatilityCount = array.new_int(4, 0)
var array<float> volatilityNetSum = array.new_float(4, 0.0)
var array<int> volatilityHits = array.new_int(4, 0)

var int acceptedLongTotal = 0
var int acceptedShortTotal = 0
var int rawLongEdges = 0
var int rawShortEdges = 0
var int conflictBars = 0
var int cooldownRejects = 0
var int naSkips = 0
var int lastAcceptedBar = na

f_record(int idx, float rawValue, float netValue) =>
    array.set(observationCount, idx, array.get(observationCount, idx) + 1)
    array.set(rawReturnSum, idx, array.get(rawReturnSum, idx) + rawValue)
    array.set(netReturnSum, idx, array.get(netReturnSum, idx) + netValue)
    array.set(netReturnSqSum, idx, array.get(netReturnSqSum, idx) + netValue * netValue)
    if netValue > 0
        array.set(hitCount, idx, array.get(hitCount, idx) + 1)
        array.set(positiveReturnCount, idx, array.get(positiveReturnCount, idx) + 1)
        array.set(positiveReturnSum, idx, array.get(positiveReturnSum, idx) + netValue)
    else if netValue < 0
        array.set(negativeReturnCount, idx, array.get(negativeReturnCount, idx) + 1)
        array.set(negativeReturnSum, idx, array.get(negativeReturnSum, idx) + netValue)

f_record_split(array<int> counts, array<float> sums, array<int> hits, int idx, float netValue) =>
    array.set(counts, idx, array.get(counts, idx) + 1)
    array.set(sums, idx, array.get(sums, idx) + netValue)
    if netValue > 0
        array.set(hits, idx, array.get(hits, idx) + 1)

f_stat_count(int scope, int horizonIdx) =>
    scope == 0 ? array.get(observationCount, horizonIdx) + array.get(observationCount, horizonIdx + 5) :
     scope == 1 ? array.get(observationCount, horizonIdx) : array.get(observationCount, horizonIdx + 5)

f_stat_int(array<int> values, int scope, int horizonIdx) =>
    scope == 0 ? array.get(values, horizonIdx) + array.get(values, horizonIdx + 5) :
     scope == 1 ? array.get(values, horizonIdx) : array.get(values, horizonIdx + 5)

f_stat_float(array<float> values, int scope, int horizonIdx) =>
    scope == 0 ? array.get(values, horizonIdx) + array.get(values, horizonIdx + 5) :
     scope == 1 ? array.get(values, horizonIdx) : array.get(values, horizonIdx + 5)

f_mean(float total, int count) =>
    count > 0 ? total / count : na

f_stdev(float total, float squaredTotal, int count) =>
    count > 1 ? math.sqrt(math.max(0.0, (squaredTotal - total * total / count) / (count - 1))) : na

f_wilson(int count, int successes) =>
    float lower = na
    float upper = na
    if count > 0
        float z = 1.959963984540054
        float p = successes / count
        float denominator = 1.0 + z * z / count
        float center = (p + z * z / (2.0 * count)) / denominator
        float halfWidth = z * math.sqrt((p * (1.0 - p) + z * z / (4.0 * count)) / count) / denominator
        lower := math.max(0.0, center - halfWidth) * 100.0
        upper := math.min(1.0, center + halfWidth) * 100.0
    [lower, upper]

f_number(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.##")

f_percent(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.##") + "%"

bool sourceReady = not na(eventSource) and not na(eventSource[1])
bool longQualified = sourceReady and eventSource >= longLevelInput
bool shortQualified = sourceReady and eventSource <= shortLevelInput
bool crossedLong = ta.crossover(eventSource, longLevelInput)
bool crossedShort = ta.crossunder(eventSource, shortLevelInput)

bool longCandidate = false
bool shortCandidate = false
bool sourceConflict = false

if sourceBindingConfirmedInput and sourceReady
    switch modeInput
        "Signed pulse" =>
            sourceConflict := longQualified and shortQualified
            bool allowLong = longQualified
            bool allowShort = shortQualified
            if sourceConflict
                allowLong := conflictInput == "Prefer long"
                allowShort := conflictInput == "Prefer short"
            longCandidate := allowLong and not (eventSource[1] >= longLevelInput)
            shortCandidate := allowShort and not (eventSource[1] <= shortLevelInput)
        "Threshold cross" =>
            longCandidate := crossedLong
            shortCandidate := crossedShort
        "Long-only edge" =>
            longCandidate := longQualified and not (eventSource[1] >= longLevelInput)
        "Short-only edge" =>
            shortCandidate := shortQualified and not (eventSource[1] <= shortLevelInput)

bool acceptedLong = false
bool acceptedShort = false

if barstate.isconfirmed
    if sourceBindingConfirmedInput and na(eventSource)
        naSkips += 1
    if auditReady and sourceReady
        rawLongEdges += longCandidate ? 1 : 0
        rawShortEdges += shortCandidate ? 1 : 0
        conflictBars += sourceConflict ? 1 : 0
        bool hasCandidate = longCandidate or shortCandidate
        bool blockedByCooldown = hasCandidate and not na(lastAcceptedBar) and bar_index - lastAcceptedBar <= cooldownInput
        if blockedByCooldown
            cooldownRejects += 1
        else
            acceptedLong := longCandidate
            acceptedShort := shortCandidate
            if acceptedLong or acceptedShort
                lastAcceptedBar := bar_index
                acceptedLongTotal += acceptedLong ? 1 : 0
                acceptedShortTotal += acceptedShort ? 1 : 0

int acceptedDirection = acceptedLong ? 1 : acceptedShort ? -1 : 0

bool inSelectedSession = not na(time(timeframe.period, sessionInput, timezoneInput))
float normalizedAtr = ta.atr(atrLengthInput) / close
float volatilityBaseline = ta.sma(normalizedAtr, baselineLengthInput)
int volatilityBucket = na(volatilityBaseline) ? 3 :
     normalizedAtr < lowBoundaryInput * volatilityBaseline ? 0 :
     normalizedAtr > highBoundaryInput * volatilityBaseline ? 2 : 1

int longestHorizon = h5Input
float forwardWindowHigh = ta.highest(high, longestHorizon)
float forwardWindowLow = ta.lowest(low, longestHorizon)
float costPercent = costBpsInput / 100.0

if auditReady
    for horizonIdx = 0 to 4
        int horizon = array.get(horizons, horizonIdx)
        int maturedDirection = acceptedDirection[horizon]
        float entryPrice = close[horizon]
        if not na(maturedDirection) and maturedDirection != 0 and not na(entryPrice) and entryPrice != 0
            float rawDirectionalReturn = maturedDirection == 1 ?
                 (close / entryPrice - 1.0) * 100.0 : (entryPrice - close) / entryPrice * 100.0
            float netDirectionalReturn = rawDirectionalReturn - costPercent
            int statsIdx = horizonIdx + (maturedDirection == -1 ? 5 : 0)
            f_record(statsIdx, rawDirectionalReturn, netDirectionalReturn)

            if horizonIdx == 4
                int directionIdx = maturedDirection == 1 ? 0 : 1
                float mfe = maturedDirection == 1 ?
                     (forwardWindowHigh / entryPrice - 1.0) * 100.0 :
                     (entryPrice - forwardWindowLow) / entryPrice * 100.0
                float mae = maturedDirection == 1 ?
                     (forwardWindowLow / entryPrice - 1.0) * 100.0 :
                     (entryPrice - forwardWindowHigh) / entryPrice * 100.0
                array.set(excursionCount, directionIdx, array.get(excursionCount, directionIdx) + 1)
                array.set(mfeSum, directionIdx, array.get(mfeSum, directionIdx) + mfe)
                array.set(maeSum, directionIdx, array.get(maeSum, directionIdx) + mae)

                int sessionIdx = inSelectedSession[horizon] ? 0 : 1
                f_record_split(sessionCount, sessionNetSum, sessionHits, sessionIdx, netDirectionalReturn)
                int eventVolatilityBucket = volatilityBucket[horizon]
                int safeVolatilityBucket = na(eventVolatilityBucket) ? 3 : eventVolatilityBucket
                f_record_split(volatilityCount, volatilityNetSum, volatilityHits, safeVolatilityBucket, netDirectionalReturn)

plotshape(showMarkersInput and acceptedLong, "Accepted long event", shape.triangleup,
     location.belowbar, C_GREEN, size = size.tiny, text = "L", textcolor = C_INK)
plotshape(showMarkersInput and acceptedShort, "Accepted short event", shape.triangledown,
     location.abovebar, C_RED, size = size.tiny, text = "S", textcolor = C_INK)
plot(acceptedDirection, "Accepted event direction (+1/0/-1)", display = display.none)

alertcondition(acceptedLong, "Accepted long event", "Signal Audit Lab accepted a confirmed long event.")
alertcondition(acceptedShort, "Accepted short event", "Signal Audit Lab accepted a confirmed short event.")

bool compactPanel = panelDensityInput == "Compact"
int panelLastColumn = compactPanel ? 3 : 6
int panelRowCount = compactPanel ? 12 : 32

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
     panelPositionInput == "Bottom right" ? position.bottom_right : automaticPanelPosition

var table panel = table.new(position.top_right, compactPanel ? 4 : 7, panelRowCount, bgcolor = C_PANEL,
     frame_color = C_LINE, frame_width = 1, border_color = C_LINE, border_width = 1)

if barstate.isfirst
    table.merge_cells(panel, 0, 0, panelLastColumn, 0)
    table.merge_cells(panel, 0, 1, panelLastColumn, 1)
    if compactPanel
        table.merge_cells(panel, 0, 8, panelLastColumn, 8)
        table.merge_cells(panel, 0, 10, panelLastColumn, 10)
        table.merge_cells(panel, 0, 11, panelLastColumn, 11)
    else
        table.merge_cells(panel, 0, 8, panelLastColumn, 8)
        table.merge_cells(panel, 0, 14, panelLastColumn, 14)
        table.merge_cells(panel, 0, 20, panelLastColumn, 20)
        table.merge_cells(panel, 0, 22, panelLastColumn, 22)
        table.merge_cells(panel, 0, 25, panelLastColumn, 25)
        table.merge_cells(panel, 0, 30, panelLastColumn, 30)
        table.merge_cells(panel, 0, 31, panelLastColumn, 31)

if barstate.islast
    table.set_position(panel, resolvedPanelPosition)
    int acceptedEventTotal = acceptedLongTotal + acceptedShortTotal
    color configColor = not configurationValid ? C_RED : not sourceBindingConfirmedInput or acceptedEventTotal == 0 ? C_AMBER : C_GREEN
    string configText = not configurationValid ? "INVALID CONFIG" : not sourceBindingConfirmedInput ? "SETUP REQUIRED" :
         not sourceReady ? "SOURCE NA" : acceptedEventTotal == 0 ? "NO EVENTS" : "AUDIT ACTIVE"
    string panelTitle = compactPanel ? "SIGNAL AUDIT [BSL]  ·  " + configText : "SIGNAL AUDIT LAB [BSL]  ·  " + configText
    string panelContext = compactPanel ? sourceLabelInput + "  ·  " + syminfo.ticker + " " + timeframe.period + "  ·  " +
         str.tostring(costBpsInput, "#.##") + " BPS" : syminfo.tickerid + "  ·  " + timeframe.period + "  ·  " + sourceLabelInput +
         "  ·  CONFIRMED  ·  COST " + str.tostring(costBpsInput, "#.##") + " BPS"
    table.cell(panel, 0, 0, panelTitle,
         text_color = configColor, bgcolor = C_INK, text_halign = text.align_left)
    table.cell(panel, 0, 1, panelContext,
         text_color = C_MUTED, bgcolor = C_PANEL, text_halign = text.align_left)

    array<string> fullHeaders = array.from("SCOPE / H", "N", "PENDING", "MEAN RAW→NET", "HIT", "WILSON 95%", "STDEV")
    array<string> compactHeaders = array.from("SCOPE / H", "N · P", "MEAN NET", "HIT")
    for col = 0 to panelLastColumn
        string header = compactPanel ? array.get(compactHeaders, col) : array.get(fullHeaders, col)
        table.cell(panel, col, 2, header, text_color = C_PAPER,
             bgcolor = color.new(C_MUTED, 78), text_size = size.tiny)

    int lastScope = compactPanel ? 0 : 2
    for scope = 0 to lastScope
        string scopeLabel = scope == 0 ? "ALL" : scope == 1 ? "LONG" : "SHORT"
        int blockStart = scope == 0 ? 3 : scope == 1 ? 9 : 15
        if scope == 1
            table.cell(panel, 0, 8, "LONG EVENTS", text_color = C_GREEN, bgcolor = C_INK, text_halign = text.align_left)
        if scope == 2
            table.cell(panel, 0, 14, "SHORT EVENTS", text_color = C_RED, bgcolor = C_INK, text_halign = text.align_left)
        for horizonIdx = 0 to 4
            int horizon = array.get(horizons, horizonIdx)
            int count = f_stat_count(scope, horizonIdx)
            int hits = f_stat_int(hitCount, scope, horizonIdx)
            int acceptedForScope = scope == 0 ? acceptedLongTotal + acceptedShortTotal :
                 scope == 1 ? acceptedLongTotal : acceptedShortTotal
            int pending = math.max(0, acceptedForScope - count)
            float rawTotal = f_stat_float(rawReturnSum, scope, horizonIdx)
            float netTotal = f_stat_float(netReturnSum, scope, horizonIdx)
            float netSquaredTotal = f_stat_float(netReturnSqSum, scope, horizonIdx)
            float meanRaw = f_mean(rawTotal, count)
            float meanNet = f_mean(netTotal, count)
            float hitRate = count > 0 ? hits * 100.0 / count : na
            float stdev = f_stdev(netTotal, netSquaredTotal, count)
            [wilsonLow, wilsonHigh] = f_wilson(count, hits)
            color metricColor = count < 30 ? C_AMBER : na(meanNet) ? C_MUTED : meanNet > 0 ? C_GREEN : meanNet < 0 ? C_RED : C_PAPER
            int row = blockStart + horizonIdx
            table.cell(panel, 0, row, scopeLabel + " / " + str.tostring(horizon) + "B", text_color = C_PAPER, text_halign = text.align_left)
            if compactPanel
                color sampleColor = count < 30 or pending > 0 ? C_AMBER : C_PAPER
                table.cell(panel, 1, row, str.tostring(count) + " · " + str.tostring(pending), text_color = sampleColor)
                table.cell(panel, 2, row, f_percent(meanNet), text_color = metricColor)
                table.cell(panel, 3, row, f_percent(hitRate), text_color = metricColor)
            else
                table.cell(panel, 1, row, str.tostring(count), text_color = metricColor)
                table.cell(panel, 2, row, str.tostring(pending), text_color = pending > 0 ? C_AMBER : C_MUTED)
                table.cell(panel, 3, row, f_number(meanRaw) + "→" + f_number(meanNet) + "%", text_color = metricColor)
                table.cell(panel, 4, row, f_percent(hitRate), text_color = metricColor)
                table.cell(panel, 5, row, f_number(wilsonLow) + " to " + f_number(wilsonHigh) + "%", text_color = count < 30 ? C_AMBER : C_MUTED)
                table.cell(panel, 6, row, f_percent(stdev), text_color = C_MUTED)

    int longestCount = array.get(excursionCount, 0) + array.get(excursionCount, 1)
    float meanMfe = f_mean(array.get(mfeSum, 0) + array.get(mfeSum, 1), longestCount)
    float meanMae = f_mean(array.get(maeSum, 0) + array.get(maeSum, 1), longestCount)
    int longestPositiveCount = f_stat_int(positiveReturnCount, 0, 4)
    int longestNegativeCount = f_stat_int(negativeReturnCount, 0, 4)
    float meanPositive = f_mean(f_stat_float(positiveReturnSum, 0, 4), longestPositiveCount)
    float meanNegative = f_mean(f_stat_float(negativeReturnSum, 0, 4), longestNegativeCount)
    float payoffProxy = not na(meanPositive) and not na(meanNegative) and meanNegative != 0 ? meanPositive / math.abs(meanNegative) : na
    int excursionTitleRow = compactPanel ? 8 : 20
    int excursionMetricRow = compactPanel ? 9 : 21
    string excursionTitle = "EXCURSION / PAYOFF  ·  " + str.tostring(longestHorizon) + "B"
    table.cell(panel, 0, excursionTitleRow, excursionTitle,
         text_color = C_AMBER, bgcolor = C_INK, text_halign = text.align_left)
    if compactPanel
        table.cell(panel, 0, excursionMetricRow, "ALL", text_color = C_PAPER, text_halign = text.align_left)
        table.cell(panel, 1, excursionMetricRow, str.tostring(longestCount), text_color = longestCount < 30 ? C_AMBER : C_PAPER)
        table.cell(panel, 2, excursionMetricRow, f_number(meanMfe) + "/" + f_number(meanMae) + "%", text_color = C_MUTED)
        table.cell(panel, 3, excursionMetricRow, f_number(payoffProxy), text_color = C_PAPER)
    else
        table.cell(panel, 0, excursionMetricRow, "ALL DIRECTIONS", text_color = C_PAPER, text_halign = text.align_left)
        table.cell(panel, 1, excursionMetricRow, str.tostring(longestCount), text_color = longestCount < 30 ? C_AMBER : C_PAPER)
        table.cell(panel, 2, excursionMetricRow, "MFE", text_color = C_MUTED)
        table.cell(panel, 3, excursionMetricRow, f_percent(meanMfe), text_color = C_GREEN)
        table.cell(panel, 4, excursionMetricRow, "MAE " + f_percent(meanMae), text_color = C_RED)
        table.cell(panel, 5, excursionMetricRow, "PAYOFF", text_color = C_MUTED)
        table.cell(panel, 6, excursionMetricRow, f_number(payoffProxy), text_color = C_PAPER)

    if not compactPanel
        string sessionTitle = "SESSION SPLIT  ·  " + sessionInput + "  ·  " + timezoneInput
        table.cell(panel, 0, 22, sessionTitle,
             text_color = C_AMBER, bgcolor = C_INK, text_halign = text.align_left)
        array<string> sessionLabels = array.from("IN SESSION", "OUTSIDE")
        for idx = 0 to 1
            int count = array.get(sessionCount, idx)
            float meanNet = f_mean(array.get(sessionNetSum, idx), count)
            float hitRate = count > 0 ? array.get(sessionHits, idx) * 100.0 / count : na
            int row = 23 + idx
            table.cell(panel, 0, row, array.get(sessionLabels, idx), text_color = C_PAPER, text_halign = text.align_left)
            table.cell(panel, 1, row, str.tostring(count), text_color = count < 30 ? C_AMBER : C_PAPER)
            table.cell(panel, 3, row, f_percent(meanNet), text_color = na(meanNet) ? C_MUTED : meanNet > 0 ? C_GREEN : C_RED)
            table.cell(panel, 4, row, f_percent(hitRate), text_color = C_MUTED)

        string volatilityTitle = "VOLATILITY SPLIT  ·  ATR " + str.tostring(atrLengthInput) +
             " / BASE " + str.tostring(baselineLengthInput) + " / " + str.tostring(lowBoundaryInput, "#.##") +
             " to " + str.tostring(highBoundaryInput, "#.##") + "×"
        table.cell(panel, 0, 25, volatilityTitle,
             text_color = C_AMBER, bgcolor = C_INK, text_halign = text.align_left)
        array<string> volatilityLabels = array.from("LOW", "MID", "HIGH", "UNCLASSIFIED")
        for idx = 0 to 3
            int count = array.get(volatilityCount, idx)
            float meanNet = f_mean(array.get(volatilityNetSum, idx), count)
            float hitRate = count > 0 ? array.get(volatilityHits, idx) * 100.0 / count : na
            int row = 26 + idx
            table.cell(panel, 0, row, array.get(volatilityLabels, idx), text_color = C_PAPER, text_halign = text.align_left)
            table.cell(panel, 1, row, str.tostring(count), text_color = count < 30 ? C_AMBER : C_PAPER)
            table.cell(panel, 3, row, f_percent(meanNet), text_color = na(meanNet) ? C_MUTED : meanNet > 0 ? C_GREEN : C_RED)
            table.cell(panel, 4, row, f_percent(hitRate), text_color = C_MUTED)

    string diagnostics = not sourceBindingConfirmedInput ? "STEP 1  SELECT PLOT + DECODER" : compactPanel ? "L/S " + str.tostring(acceptedLongTotal) + "/" + str.tostring(acceptedShortTotal) +
         "  ·  CD " + str.tostring(cooldownRejects) + "  ·  CF " + str.tostring(conflictBars) + "  ·  NA " + str.tostring(naSkips) :
         "DIAGNOSTICS  ·  RAW L/S " + str.tostring(rawLongEdges) + "/" + str.tostring(rawShortEdges) +
         "  ·  ACCEPTED L/S " + str.tostring(acceptedLongTotal) + "/" + str.tostring(acceptedShortTotal) +
         "  ·  COOLDOWN " + str.tostring(cooldownRejects) + "  ·  CONFLICT " + str.tostring(conflictBars) +
         "  ·  NA SKIPS " + str.tostring(naSkips)
    string sourceWarning = not sourceBindingConfirmedInput ? "STEP 2  VERIFY SOURCE TO START" : compactPanel ? "PRODUCER LOGIC OUT OF SCOPE  ·  NOT A BACKTEST" :
         "PRODUCER LOGIC WAS NOT REVIEWED  ·  THIS MEASURES EVENTS, NOT TRADES"
    int diagnosticsRow = compactPanel ? 10 : 30
    int warningRow = compactPanel ? 11 : 31
    table.cell(panel, 0, diagnosticsRow, diagnostics, text_color = C_MUTED, bgcolor = C_INK, text_halign = text.align_left)
    table.cell(panel, 0, warningRow, sourceWarning,
         text_color = C_AMBER, bgcolor = C_INK, text_halign = text.align_left)
````
