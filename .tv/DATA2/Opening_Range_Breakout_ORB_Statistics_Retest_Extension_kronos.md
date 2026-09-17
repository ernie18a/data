<!-- tradingview-pine-id: PUB;6241d2b1e1974bcaa2436fd0da9139be -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Opening Range Breakout (ORB) Statistics: Retest & Extension (kronos)

Source: https://www.tradingview.com/script/NCTr00I4-Opening-Range-Breakout-Statistics-ORB-kronos/

## Description

Opening Range Breakout (ORB) Statistics: Retest & Extension (kronos)

This indicator turns a completed opening range into a compact statistical read of what historically happened next. The default summary keeps the chart clean and focuses on three questions: which side broke first, how often the selected extension was reached, and what the current session has already confirmed.

How it works

The script builds an opening range from a market preset or custom session. When the range closes, its width and close location are frozen. Historical sessions are then filtered by the selected similarity rule. The current session is never included in its own sample.

[*]First Break shows UP, DOWN and OTHER in separate cells. OTHER combines no-break sessions and same-bar two-sided breaks because OHLC data cannot prove an intrabar order.
[*]UP or DOWN receives the stronger highlight only when that directional outcome leads both the opposite direction and OTHER.
[*]Extension shows the historical share that reached the selected range multiple. Once a directional first break exists, the sample switches to comparable historical breaks in that direction.
[*]Based On shows the sample size and effective similarity scope behind the extension statistic.
[*]Today shows the confirmed first-break direction, broken-edge retest state and active extension state.

Opening range presets

[*]US Cash 09:30 New York
[*]London Cash 08:00 London
[*]Tokyo Cash 09:00 Tokyo
[*]Crypto 00:00 UTC
[*]Custom session and timezone

Opening Range Length supports 15, 30 and 60 minutes for the market presets. Custom mode uses the custom Opening Range and Outcome Window fields.

Historical matching

Auto is the recommended mode. Before a break it uses the most specific sample that reaches the target sample size. After a directional break it resolves a separate sample for that break direction. Manual filters can instead use the same range setup, same range size, same range close, or all sessions.

Range size is classified from historical normalized opening-range widths. The current width uses a half-tie percentile rank, so equal historical widths do not receive an artificial upper-rank bias. The range close is classified into lower, middle or upper thirds.

Outcome rules

Confirmed Close requires a closed bar beyond the opening-range edge. Wick Beyond Range uses strict high/low breaches. Exact touches of the opening-range boundary are not breaks. If a single wick bar crosses both edges before a direction is established, the result is recorded as a same-bar two-sided break rather than assigning an order that the chart data cannot prove.

The broken-edge and midpoint retests can only be confirmed on a later bar than the first break. Extension targets count an exact touch.

Chart display

The opening-range box, high, low and optional midpoint remain unchanged after the range locks. Only the target in the first-break direction is shown. The OR and target lines extend one chart bar beyond the latest processed bar, matching the price-label offset on every supported timeframe. Event labels are optional and off by default.

Inputs

[*]Preset - Market/session preset. Default: US Cash 09:30 NY.
[*]Opening Range Length - 15, 30 or 60 minutes. Default: 30 Minutes.
[*]Max History Sessions - Maximum retained completed sessions. Default: 250.
[*]Target Sample Size - Desired sample size for adaptive matching. Default: 20.
[*]History Filter - Auto, same range setup, same range size, same range close, or all sessions. Default: Auto (Recommended).
[*]Minimum Session Data % - Required outcome-window coverage. Default: 80.
[*]Break Confirmation - Confirmed Close or Wick Beyond Range. Default: Confirmed Close.
[*]Extension Target - Range-width multiple beyond the broken edge. Default: 1.0.
[*]Display - Opening range, midpoint, active target, price labels, event labels and compact summary.

Alerts

Alerts are available for opening-range lock, first break up, first break down, same-bar two-sided break, edge retest, midpoint retest, opposite edge, selected extension and both-sides completion. State changes are processed on confirmed chart bars.

Limitations

The indicator uses chart-timeframe OHLC bars only. It does not reconstruct intrabar sequencing. Session windows must align with the chart timeframe, and incomplete opening ranges are excluded. Historical percentages describe the selected sample and are not forecasts.

This script is a charting tool for educational purposes. It does not provide financial advice and does not predict future price movement. Trading carries risk; decisions and their outcome remain yours.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) KronosMMXM

//@version=6
indicator("Opening Range Breakout (ORB) Statistics: Retest & Extension (kronos)", shorttitle = "Opening Range Stats (kronos)", overlay = true, max_lines_count = 20, max_boxes_count = 5, max_labels_count = 30)

//#region TYPES ================================================================

enum SessionPreset
    usCash     = "US Cash 09:30 NY"
    londonCash = "London Cash 08:00 London"
    tokyoCash  = "Tokyo Cash 09:00 Tokyo"
    cryptoUtc  = "Crypto 00:00 UTC"
    custom     = "Custom"

enum RangeLength
    m15 = "15 Minutes"
    m30 = "30 Minutes"
    m60 = "60 Minutes"

enum MatchChoice
    adaptive   = "Auto (Recommended)"
    widthClose = "Same Range Setup"
    widthOnly  = "Same Range Size"
    closeOnly  = "Same Range Close"
    allRows    = "All Sessions"

enum BreakBasis
    closeBreak = "Confirmed Close"
    wickBreak  = "Wick Beyond Range"

enum StrokeStyle
    solid  = "Solid"
    dashed = "Dashed"
    dotted = "Dotted"

enum PanelSpot
    topRight    = "Top Right"
    topLeft     = "Top Left"
    bottomRight = "Bottom Right"
    bottomLeft  = "Bottom Left"

enum EventLabelMode
    off = "Off"
    key = "Key Events"
    all = "All Events"

//#endregion

//#region CONSTANTS ============================================================

string TZ_NEW_YORK = "America/New_York"
string TZ_LONDON   = "Europe/London"
string TZ_TOKYO    = "Asia/Tokyo"
string TZ_UTC      = "UTC"

string US_OR_15     = "0930-0945"
string US_OR_30     = "0930-1000"
string US_OR_60     = "0930-1030"
string US_OUTCOME   = "0930-1600"
string LONDON_OR_15 = "0800-0815"
string LONDON_OR_30 = "0800-0830"
string LONDON_OR_60 = "0800-0900"
string LONDON_OUT   = "0800-1630"
string TOKYO_OR_15  = "0900-0915"
string TOKYO_OR_30  = "0900-0930"
string TOKYO_OR_60  = "0900-1000"
string TOKYO_OUT    = "0900-1500"
string CRYPTO_OR_15 = "0000-0015"
string CRYPTO_OR_30 = "0000-0030"
string CRYPTO_OR_60 = "0000-0100"
string CRYPTO_OUT   = "0000-0000"
string WEEKDAYS    = ":23456"
string EVERY_DAY   = ":1234567"

int MIN_PER_DAY       = 1440
int MS_PER_DAY        = 86400000
int HARD_MIN_SAMPLE   = 5
int WIDTH_UNKNOWN     = 0
int WIDTH_NARROW      = 1
int WIDTH_TYPICAL     = 2
int WIDTH_WIDE        = 3
int CLOSE_LOWER       = 1
int CLOSE_MIDDLE      = 2
int CLOSE_UPPER       = 3
int BREAK_NONE        = 0
int BREAK_UP          = 1
int BREAK_DOWN        = -1
int BREAK_BOTH        = 2
int MATCH_ADAPTIVE    = 0
int MATCH_WIDTH_CLOSE = 1
int MATCH_WIDTH       = 2
int MATCH_CLOSE       = 3
int MATCH_ALL         = 4
int BOARD_ROWS        = 3
int BOARD_COLS        = 4
int MAX_EVENT_LABELS  = 6
int LEVEL_LABEL_OFFSET = 1
float WIDTH_LOW_PCT   = 25.0
float WIDTH_HIGH_PCT  = 75.0
float CLOSE_LOW_EDGE  = 1.0 / 3.0
float CLOSE_HIGH_EDGE = 2.0 / 3.0
float FLOAT_EPS       = 0.000000001
float MAX_COVERAGE    = 110.0

color UP_COLOR      = #26a69aff
color DOWN_COLOR    = #ef5350ff
color MID_COLOR     = #b2b5beff
color RANGE_FILL    = #787b8620
color WARN_COLOR    = #ffb300ff
color HIT_COLOR     = #2962ffff

string GRP_SESSION = "Session"
string GRP_STATS   = "Statistics"
string GRP_OUTCOME = "Outcome Rules"
string GRP_DISPLAY = "Display"
string GRP_STYLE   = "Style"

string TIP_PRESET = """Presets set the range start, outcome window, timezone,
and active days. Opening Range Length selects 15, 30, or 60 minutes. Custom
unlocks the custom fields below without overwriting them."""

string TIP_RANGE_LENGTH = """Length used by the four market presets. Custom uses
the Opening Range field below instead."""

string TIP_WINDOWS = """The opening range and outcome window must start at the
same local time. Both lengths must divide evenly into the chart timeframe, and
the first opening-range bar must begin exactly at that local start."""

string TIP_HISTORY = """Maximum completed sessions kept on the current chart.
The summary always reports the actual usable history after all filters."""

string TIP_MATCH = """Auto uses the most specific historical sample
that is large enough. Before a break it matches the current range setup. After a
break it resolves a separate sample for that break direction, so useful follow-
through statistics do not disappear because the first sample was too small."""

string TIP_COVERAGE = """A completed session is stored only when the opening
range is complete and the outcome window contains at least this share of its
expected chart bars. Partial history and most early closes are excluded."""

string TIP_BREAK = """Confirmed Close requires a closed bar beyond an edge.
Wick Beyond Range uses the bar high and low. If one wick bar crosses both edges,
the result is recorded as Both Same Bar rather than inventing an order."""

string TIP_EXTENSION = """Distance beyond an opening-range edge measured in
multiples of the completed range width. A value of 1.0 means one full range."""

string TIP_LABEL = """Off keeps the chart clean. Key Events shows only the
first break, the active extension, and a completed both-sides outcome. All Events
also marks retests. Multiple events on one bar share one label."""

string TIP_SUMMARY = """The summary changes with the session phase. It
shows only the range state, today's path, the matching historical path, and the
sample behind those percentages."""

string TIP_TARGET = """Shows only the target in the first-break direction. The
opposite target stays hidden because it is not the active outcome."""

string TIP_LEVEL_LABELS = """Pins OR High, OR Low, and the active target to the
right edge of the latest session. The labels are reused instead of added on
every bar."""

//#endregion

//#region INPUTS ===============================================================

SessionPreset sessionPresetInput = input.enum(SessionPreset.usCash, "Preset", group = GRP_SESSION, tooltip = TIP_PRESET)
RangeLength rangeLengthInput = input.enum(RangeLength.m30, "Opening Range Length", group = GRP_SESSION, active = sessionPresetInput != SessionPreset.custom, tooltip = TIP_RANGE_LENGTH)
string customTimezoneInput = input.string("America/New_York", "Custom Timezone", group = GRP_SESSION, active = sessionPresetInput == SessionPreset.custom, tooltip = TIP_WINDOWS)
string customOrInput = input.session("0930-1000", "Opening Range", group = GRP_SESSION, active = sessionPresetInput == SessionPreset.custom, tooltip = TIP_WINDOWS)
string customOutcomeInput = input.session("0930-1600", "Outcome Window (Includes OR)", group = GRP_SESSION, active = sessionPresetInput == SessionPreset.custom, tooltip = TIP_WINDOWS)
bool includeWeekendsInput = input.bool(false, "Include Weekends", group = GRP_SESSION, active = sessionPresetInput == SessionPreset.custom)

int historyLimitInput = input.int(250, "Max History Sessions", minval = 20, maxval = 500, group = GRP_STATS, tooltip = TIP_HISTORY)
int minMatchInput = input.int(20, "Target Sample Size", minval = 5, maxval = 100, group = GRP_STATS, tooltip = TIP_MATCH)
MatchChoice matchChoiceInput = input.enum(MatchChoice.adaptive, "History Filter", group = GRP_STATS, tooltip = TIP_MATCH)
int minCoverageInput = input.int(80, "Minimum Session Data %", minval = 50, maxval = 100, group = GRP_STATS, tooltip = TIP_COVERAGE)

BreakBasis breakBasisInput = input.enum(BreakBasis.closeBreak, "Break Confirmation", group = GRP_OUTCOME, tooltip = TIP_BREAK)
float extensionInput = input.float(1.0, "Extension Target", minval = 0.25, maxval = 3.0, step = 0.25, group = GRP_OUTCOME, tooltip = TIP_EXTENSION)

bool showRangeInput = input.bool(true, "Show Opening Range", group = GRP_DISPLAY)
bool showMidpointInput = input.bool(true, "Show Midpoint", group = GRP_DISPLAY, active = showRangeInput)
bool showTargetsInput = input.bool(true, "Show Active Target", group = GRP_DISPLAY, active = showRangeInput, tooltip = TIP_TARGET)
bool showLevelLabelsInput = input.bool(true, "Show Price Labels", group = GRP_DISPLAY, active = showRangeInput, tooltip = TIP_LEVEL_LABELS)
EventLabelMode eventLabelsInput = input.enum(EventLabelMode.off, "Event Labels", group = GRP_DISPLAY, active = showRangeInput, tooltip = TIP_LABEL)
bool showDashboardInput = input.bool(true, "Show Summary", group = GRP_DISPLAY, tooltip = TIP_SUMMARY)
PanelSpot panelSpotInput = input.enum(PanelSpot.topRight, "Summary Position", group = GRP_DISPLAY, active = showDashboardInput)
int panelSizeInput = input.int(10, "Summary Text Size", minval = 10, maxval = 24, group = GRP_DISPLAY, active = showDashboardInput)

color rangeFillInput = input.color(RANGE_FILL, "Range Fill", group = GRP_STYLE, active = showRangeInput)
color upColorInput = input.color(UP_COLOR, "Up", inline = "dir", group = GRP_STYLE)
color downColorInput = input.color(DOWN_COLOR, "Down", inline = "dir", group = GRP_STYLE)
color midpointColorInput = input.color(MID_COLOR, "Midpoint", group = GRP_STYLE, active = showRangeInput and showMidpointInput)
int lineWidthInput = input.int(1, "Line Width", minval = 1, maxval = 4, group = GRP_STYLE, active = showRangeInput)
StrokeStyle rangeLineStyleInput = input.enum(StrokeStyle.solid, "Range Line Style", group = GRP_STYLE, active = showRangeInput)
StrokeStyle targetLineStyleInput = input.enum(StrokeStyle.dotted, "Target Line Style", group = GRP_STYLE, active = showRangeInput and showTargetsInput)
int labelSizeInput = input.int(10, "Label Size", minval = 10, maxval = 30, group = GRP_STYLE, active = showRangeInput and (showLevelLabelsInput or eventLabelsInput != EventLabelMode.off))
bool labelBgInput = input.bool(false, "Label Background", group = GRP_STYLE, active = showRangeInput and (showLevelLabelsInput or eventLabelsInput != EventLabelMode.off))

//#endregion

//#region FUNCTIONS ============================================================

// @function        Reads the first time in an HHMM-HHMM session string.
// @param spec      (series string) Session specification.
// @returns         (series int) Minutes since local midnight.
sessionFromMinute(series string spec) =>
    int result = 0
    if str.length(spec) >= 9
        float hourPart = str.tonumber(str.substring(spec, 0, 2))
        float minutePart = str.tonumber(str.substring(spec, 2, 4))
        bool readable = not na(hourPart) and not na(minutePart)
        result := readable ? int(hourPart) * 60 + int(minutePart) : 0
    result

// @function        Reads the second time in an HHMM-HHMM session string.
// @param spec      (series string) Session specification.
// @returns         (series int) Minutes since midnight; 0000 becomes 1440.
sessionToMinute(series string spec) =>
    int result = MIN_PER_DAY
    if str.length(spec) >= 9
        float hourPart = str.tonumber(str.substring(spec, 5, 7))
        float minutePart = str.tonumber(str.substring(spec, 7, 9))
        bool readable = not na(hourPart) and not na(minutePart)
        int rawMinute = readable ? int(hourPart) * 60 + int(minutePart) : 0
        result := rawMinute == 0 ? MIN_PER_DAY : rawMinute
    result

// @function        Returns the length of a session, including midnight wraps.
// @param fromMin   (series int) Start minute.
// @param toMin     (series int) End minute.
// @returns         (series int) Length in minutes.
sessionSpan(series int fromMin, series int toMin) =>
    toMin > fromMin ? toMin - fromMin : toMin + MIN_PER_DAY - fromMin

// @function        Returns elapsed minutes from an anchor with one-day wrap.
// @param atMinute  (series int) Current local minute.
// @param anchorMin (series int) Anchor local minute.
// @returns         (series int) Elapsed minutes in 0 to 1439.
minutesSince(series int atMinute, series int anchorMin) =>
    (atMinute - anchorMin + MIN_PER_DAY) % MIN_PER_DAY

// @function        Builds a stable local-date key for a possibly wrapped session.
// @param barTime   (series int) Bar opening timestamp.
// @param zoneName  (series string) IANA or UTC timezone.
// @param localMin  (series int) Local minute of the bar.
// @param fromMin   (series int) Session start minute.
// @param toMin     (series int) Session end minute.
// @returns         (series int) YYYYMMDD key of the session start date.
sessionDateKey(series int barTime, series string zoneName, series int localMin,
  series int fromMin, series int toMin) =>
    bool wraps = toMin < fromMin
    int keyTime = wraps and localMin < toMin ? barTime - MS_PER_DAY : barTime
    year(keyTime, zoneName) * 10000 + month(keyTime, zoneName) * 100 + dayofmonth(keyTime, zoneName)

// @function        Converts the style input to a Pine line style.
// @param styleChoice (simple StrokeStyle) Selected style.
// @returns         (simple string) Pine line-style constant.
strokeValue(simple StrokeStyle styleChoice) =>
    string result = line.style_solid
    if styleChoice == StrokeStyle.dashed
        result := line.style_dashed
    else if styleChoice == StrokeStyle.dotted
        result := line.style_dotted
    result

// @function        Converts the panel input to a Pine table position.
// @param spotChoice (simple PanelSpot) Selected corner.
// @returns         (simple string) Pine table-position constant.
panelPosition(simple PanelSpot spotChoice) =>
    string result = position.top_right
    if spotChoice == PanelSpot.topLeft
        result := position.top_left
    else if spotChoice == PanelSpot.bottomRight
        result := position.bottom_right
    else if spotChoice == PanelSpot.bottomLeft
        result := position.bottom_left
    result

// @function        Returns a percent string without false decimal precision.
// @param valuePct  (series float) Percentage or na.
// @returns         (series string) Rounded percentage or dash.
formatPercent(series float valuePct) =>
    na(valuePct) ? "-" : str.tostring(int(math.round(valuePct))) + "%"

// @function        Formats elapsed minutes in compact hours and minutes.
// @param minuteCount (series int) Minutes or na.
// @returns         (series string) Compact duration or dash.
formatMinutes(series int minuteCount) =>
    string result = "-"
    if not na(minuteCount)
        int hoursPart = int(math.floor(minuteCount / 60.0))
        int minsPart = minuteCount % 60
        if hoursPart > 0
            result := str.tostring(hoursPart) + "h " + str.tostring(minsPart) + "m"
        else
            result := str.tostring(minsPart) + "m"
    result

// @function        Formats a percentile rank without implying probability.
// @param valuePct  (series float) Percentile rank or na.
// @returns         (series string) P-prefixed rank or dash.
formatRank(series float valuePct) =>
    na(valuePct) ? "-" : "P" + str.tostring(int(math.round(valuePct)))

// @function        Formats a local minute as HH:MM.
// @param minuteValue (series int) Minute since local midnight.
// @returns         (series string) Zero-padded local clock time.
formatClock(series int minuteValue) =>
    int safeMinute = (minuteValue + MIN_PER_DAY) % MIN_PER_DAY
    int hourPart = int(math.floor(safeMinute / 60.0))
    int minutePart = safeMinute % 60
    string hourText = hourPart < 10 ? "0" + str.tostring(hourPart) : str.tostring(hourPart)
    string minuteText = minutePart < 10 ? "0" + str.tostring(minutePart) : str.tostring(minutePart)
    hourText + ":" + minuteText

// @function        Returns the public timezone name of a preset.
// @param presetChoice (simple SessionPreset) Active preset.
// @returns         (simple string) Short timezone label.
presetZoneName(simple SessionPreset presetChoice) =>
    string result = "New York"
    if presetChoice == SessionPreset.londonCash
        result := "London"
    else if presetChoice == SessionPreset.tokyoCash
        result := "Tokyo"
    else if presetChoice == SessionPreset.cryptoUtc
        result := "UTC"
    else if presetChoice == SessionPreset.custom
        result := "Custom Time"
    result

// @function        Returns a concise preset name for the board header.
// @param presetChoice (simple SessionPreset) Active session preset.
// @returns         (simple string) Compact market name.
presetName(simple SessionPreset presetChoice) =>
    string result = "US Cash"
    if presetChoice == SessionPreset.londonCash
        result := "London"
    else if presetChoice == SessionPreset.tokyoCash
        result := "Tokyo"
    else if presetChoice == SessionPreset.cryptoUtc
        result := "Crypto"
    else if presetChoice == SessionPreset.custom
        result := "Custom"
    result

// @function        Returns a plain-language OR-close label.
// @param zoneValue (series int) Internal close zone.
// @returns         (series string) Compact board phrase.
shortCloseName(series int zoneValue) =>
    string result = "Closed in middle third"
    if zoneValue == CLOSE_LOWER
        result := "Closed in lower third"
    else if zoneValue == CLOSE_UPPER
        result := "Closed in upper third"
    result

// @function        Returns a plain-language scope word for the sample.
// @param modeValue (series int) Effective match mode.
// @returns         (series string) Similarity phrase used after a row count.
sampleScopeName(series int modeValue) =>
    string result = "prior"
    if modeValue == MATCH_WIDTH_CLOSE
        result := "similar"
    else if modeValue == MATCH_WIDTH
        result := "same-size"
    else if modeValue == MATCH_CLOSE
        result := "same-close"
    result

// @function        Maps a reached state to concise live board text.
// @param reached   (series bool) Whether the outcome occurred.
// @param closedNow (series bool) Whether the outcome window is finished.
// @returns         (series string) Hit, No, or Open.
outcomeState(series bool reached, series bool closedNow) =>
    reached ? "Hit" : closedNow ? "No" : "Open"

// @function        Returns the display name of a frozen width class.
// @param classValue (series int) Internal width class.
// @returns         (series string) User-facing label.
widthClassName(series int classValue) =>
    string result = "No Width Rank"
    if classValue == WIDTH_NARROW
        result := "Narrow"
    else if classValue == WIDTH_TYPICAL
        result := "Typical"
    else if classValue == WIDTH_WIDE
        result := "Wide"
    result

// @function        Returns the display name of a frozen close location.
// @param zoneValue (series int) Internal close zone.
// @returns         (series string) User-facing label.
closeZoneName(series int zoneValue) =>
    string result = "Middle Third"
    if zoneValue == CLOSE_LOWER
        result := "Lower Third"
    else if zoneValue == CLOSE_UPPER
        result := "Upper Third"
    result

// @function        Returns the display name of the effective context match.
// @param modeValue (series int) Internal match mode.
// @returns         (series string) User-facing label.
matchModeName(series int modeValue) =>
    string result = "All Sessions"
    if modeValue == MATCH_WIDTH_CLOSE
        result := "Width + OR Close Third"
    else if modeValue == MATCH_WIDTH
        result := "Width"
    else if modeValue == MATCH_CLOSE
        result := "OR Close Third"
    result

// @function        Tests whether one historical record matches a context.
// @param rowIndex  (series int) Historical row index.
// @param modeValue (series int) Effective match mode.
// @param widthRows (array<int>) Frozen historical width classes.
// @param closeRows (array<int>) Frozen historical close zones.
// @param widthNow  (series int) Current width class.
// @param closeNow  (series int) Current close zone.
// @returns         (series bool) True when the record belongs to the sample.
recordMatches(series int rowIndex, series int modeValue,
  array<int> widthRows, array<int> closeRows, series int widthNow,
  series int closeNow) =>
    int rowWidth = array.get(widthRows, rowIndex)
    int rowClose = array.get(closeRows, rowIndex)
    bool allMatch = modeValue == MATCH_ALL
    bool closeMatch = modeValue == MATCH_CLOSE and rowClose == closeNow
    bool widthKnown = widthNow != WIDTH_UNKNOWN
    bool widthMatch = modeValue == MATCH_WIDTH and widthKnown and rowWidth == widthNow
    bool exactMode = modeValue == MATCH_WIDTH_CLOSE and widthKnown
    bool exactMatch = exactMode and rowWidth == widthNow and rowClose == closeNow
    allMatch or closeMatch or widthMatch or exactMatch

// @function        Resolves the most specific sample that meets a minimum size.
// @param exactRows (series int) Rows matching range size and close location.
// @param widthRows (series int) Rows matching range size.
// @param closeRows (series int) Rows matching close location.
// @param minimumRows (series int) Desired sample size.
// @returns         (series int) Effective internal match mode.
adaptiveMatch(series int exactRows, series int widthRows,
  series int closeRows, series int minimumRows) =>
    bool exactReady = exactRows >= minimumRows
    bool widthReady = widthRows >= minimumRows and widthRows >= closeRows
    bool closeReady = closeRows >= minimumRows
    int result = MATCH_ALL
    if exactReady
        result := MATCH_WIDTH_CLOSE
    else if widthReady
        result := MATCH_WIDTH
    else if closeReady
        result := MATCH_CLOSE
    result

// @function        Returns an observed share, or na for an empty denominator.
// @param hitCount  (series int) Number of matching outcomes.
// @param rowCount  (series int) Explicit denominator.
// @returns         (series float) Percentage or na.
observedShare(series int hitCount, series int rowCount) =>
    rowCount > 0 ? 100.0 * hitCount / rowCount : na

// @function        Returns the rounded median of a mutable scratch array.
// @param valuesRows (array<int>) Scratch values; sorted in place.
// @returns         (series int) Rounded median or na.
medianInt(array<int> valuesRows) =>
    int result = na
    int rowCount = array.size(valuesRows)
    if rowCount > 0
        array.sort(valuesRows, order.ascending)
        int middle = int(math.floor(rowCount / 2.0))
        if rowCount % 2 == 1
            result := array.get(valuesRows, middle)
        else
            int leftValue = array.get(valuesRows, middle - 1)
            int rightValue = array.get(valuesRows, middle)
            result := int(math.round((leftValue + rightValue) / 2.0))
    result

// @function        Appends one completed session and trims every parallel array.
// @param widthRows (array<float>) Historical normalized widths.
// @param widthClassRows (array<int>) Historical width classes.
// @param closeRows (array<int>) Historical close zones.
// @param breakRows (array<int>) Historical first-break states.
// @param breakMinuteRows (array<int>) Historical first-break confirmation times.
// @param bothRows  (array<bool>) Historical both-sides outcomes.
// @param anyExtensionRows (array<bool>) Historical either-side extensions.
// @param edgeRows  (array<bool>) Historical broken-edge retests.
// @param midRows   (array<bool>) Historical midpoint retests.
// @param oppositeRows (array<bool>) Historical opposite-edge touches.
// @param sameExtensionRows (array<bool>) Historical directional extensions.
// @param extensionMinuteRows (array<int>) Historical extension times.
// @param widthValue (series float) Session normalized width.
// @param widthClassValue (series int) Session width class.
// @param closeValue (series int) Session close zone.
// @param breakValue (series int) Session first-break state.
// @param breakMinuteValue (series int) First-break time or -1.
// @param bothValue (series bool) Whether both range edges broke.
// @param anyExtensionValue (series bool) Whether either extension was touched.
// @param edgeValue (series bool) Whether the broken edge was retested.
// @param midValue  (series bool) Whether the midpoint was retested.
// @param oppositeValue (series bool) Whether the opposite edge was touched.
// @param sameExtensionValue (series bool) Whether the directional target hit.
// @param extensionMinuteValue (series int) Extension time or -1.
// @param maximumRows (series int) Maximum retained sessions.
// @returns         (series int) Retained session count.
storeSession(array<float> widthRows, array<int> widthClassRows,
  array<int> closeRows, array<int> breakRows, array<int> breakMinuteRows,
  array<bool> bothRows, array<bool> anyExtensionRows, array<bool> edgeRows,
  array<bool> midRows, array<bool> oppositeRows,
  array<bool> sameExtensionRows, array<int> extensionMinuteRows,
  series float widthValue, series int widthClassValue, series int closeValue,
  series int breakValue, series int breakMinuteValue, series bool bothValue,
  series bool anyExtensionValue, series bool edgeValue, series bool midValue,
  series bool oppositeValue, series bool sameExtensionValue,
  series int extensionMinuteValue, series int maximumRows) =>
    array.push(widthRows, widthValue)
    array.push(widthClassRows, widthClassValue)
    array.push(closeRows, closeValue)
    array.push(breakRows, breakValue)
    array.push(breakMinuteRows, breakMinuteValue)
    array.push(bothRows, bothValue)
    array.push(anyExtensionRows, anyExtensionValue)
    array.push(edgeRows, edgeValue)
    array.push(midRows, midValue)
    array.push(oppositeRows, oppositeValue)
    array.push(sameExtensionRows, sameExtensionValue)
    array.push(extensionMinuteRows, extensionMinuteValue)
    while array.size(widthRows) > maximumRows
        array.shift(widthRows)
        array.shift(widthClassRows)
        array.shift(closeRows)
        array.shift(breakRows)
        array.shift(breakMinuteRows)
        array.shift(bothRows)
        array.shift(anyExtensionRows)
        array.shift(edgeRows)
        array.shift(midRows)
        array.shift(oppositeRows)
        array.shift(sameExtensionRows)
        array.shift(extensionMinuteRows)
    array.size(widthRows)

// @function        Writes one compact two-column dashboard row.
// @param board     (series table) Destination table.
// @param rowIndex  (series int) Destination row.
// @param metricText (series string) Left-side label.
// @param valueText (series string) Right-side value.
// @param valueTone (series color) Right-side text color.
// @param glyphSize (series int) Text size in points.
// @returns         (series int) Next row index.
writeBoardRow(series table board, series int rowIndex, series string metricText,
  series string valueText, series color valueTone, series int glyphSize) =>
    color cellBg = color.new(chart.bg_color, 8)
    table.cell(board, 0, rowIndex, metricText, text_color = chart.fg_color,
      text_size = glyphSize, text_halign = text.align_left, bgcolor = cellBg)
    table.cell(board, 1, rowIndex, valueText, text_color = valueTone,
      text_size = glyphSize, text_halign = text.align_right, bgcolor = cellBg)
    rowIndex + 1

//#endregion

//#region CALCULATIONS =========================================================

bool useCustom = sessionPresetInput == SessionPreset.custom
string timezoneName = TZ_NEW_YORK
if useCustom
    timezoneName := customTimezoneInput
else if sessionPresetInput == SessionPreset.londonCash
    timezoneName := TZ_LONDON
else if sessionPresetInput == SessionPreset.tokyoCash
    timezoneName := TZ_TOKYO
else if sessionPresetInput == SessionPreset.cryptoUtc
    timezoneName := TZ_UTC

string presetOrSession = US_OR_30
if sessionPresetInput == SessionPreset.londonCash
    presetOrSession := LONDON_OR_30
    if rangeLengthInput == RangeLength.m15
        presetOrSession := LONDON_OR_15
    else if rangeLengthInput == RangeLength.m60
        presetOrSession := LONDON_OR_60
else if sessionPresetInput == SessionPreset.tokyoCash
    presetOrSession := TOKYO_OR_30
    if rangeLengthInput == RangeLength.m15
        presetOrSession := TOKYO_OR_15
    else if rangeLengthInput == RangeLength.m60
        presetOrSession := TOKYO_OR_60
else if sessionPresetInput == SessionPreset.cryptoUtc
    presetOrSession := CRYPTO_OR_30
    if rangeLengthInput == RangeLength.m15
        presetOrSession := CRYPTO_OR_15
    else if rangeLengthInput == RangeLength.m60
        presetOrSession := CRYPTO_OR_60
else
    if rangeLengthInput == RangeLength.m15
        presetOrSession := US_OR_15
    else if rangeLengthInput == RangeLength.m60
        presetOrSession := US_OR_60

string baseOrSession = useCustom ? customOrInput : presetOrSession
string baseOutcomeSession = US_OUTCOME
if useCustom
    baseOutcomeSession := customOutcomeInput
else if sessionPresetInput == SessionPreset.londonCash
    baseOutcomeSession := LONDON_OUT
else if sessionPresetInput == SessionPreset.tokyoCash
    baseOutcomeSession := TOKYO_OUT
else if sessionPresetInput == SessionPreset.cryptoUtc
    baseOutcomeSession := CRYPTO_OUT

bool cryptoEveryDay = sessionPresetInput == SessionPreset.cryptoUtc
bool customEveryDay = useCustom and includeWeekendsInput
bool useEveryDay = cryptoEveryDay or customEveryDay
string daySuffix = useEveryDay ? EVERY_DAY : WEEKDAYS
string orSession = baseOrSession + daySuffix
string outcomeSession = baseOutcomeSession + daySuffix

int orFrom = sessionFromMinute(baseOrSession)
int orTo = sessionToMinute(baseOrSession)
int outcomeFrom = sessionFromMinute(baseOutcomeSession)
int outcomeTo = sessionToMinute(baseOutcomeSession)
int orMinutes = sessionSpan(orFrom, orTo)
int outcomeMinutes = sessionSpan(outcomeFrom, outcomeTo)
float chartTfSeconds = timeframe.in_seconds(timeframe.period)
int chartTfMinutes = int(chartTfSeconds / 60.0)
bool minuteChart = timeframe.isintraday and chartTfSeconds >= 60.0
bool chartTfPositive = chartTfMinutes > 0
bool orAligned = chartTfPositive and orMinutes % chartTfMinutes == 0
bool outcomeAligned = chartTfPositive and outcomeMinutes % chartTfMinutes == 0
bool alignedWindows = orAligned and outcomeAligned
bool nestedWindows = orFrom == outcomeFrom and orMinutes < outcomeMinutes
bool configValid = minuteChart and alignedWindows and nestedWindows and chartTfMinutes <= orMinutes
string configIssue = "Invalid Configuration"
if not minuteChart
    configIssue := "Use 1m+ Intraday Chart"
else if chartTfMinutes > orMinutes
    configIssue := "Chart TF Exceeds OR"
else if orFrom != outcomeFrom
    configIssue := "Outcome Must Start With OR"
else if orMinutes >= outcomeMinutes
    configIssue := "Outcome Must Be Longer"
else if not alignedWindows
    configIssue := "Windows Do Not Align"
int expectedOrBars = configValid ? int(orMinutes / chartTfMinutes) : 0
int expectedOutcomeBars = configValid ? int(outcomeMinutes / chartTfMinutes) : 0

bool inOpeningRange = configValid and not na(time(timeframe.period, orSession, timezoneName))
bool inOutcome = configValid and not na(time(timeframe.period, outcomeSession, timezoneName))
int localMinute = hour(time, timezoneName) * 60 + minute(time, timezoneName)
int currentSessionKey = 0
if inOutcome
    currentSessionKey := sessionDateKey(time, timezoneName, localMinute, outcomeFrom, outcomeTo)

int requestedMatch = MATCH_ALL
if matchChoiceInput == MatchChoice.adaptive
    requestedMatch := MATCH_ADAPTIVE
else if matchChoiceInput == MatchChoice.widthClose
    requestedMatch := MATCH_WIDTH_CLOSE
else if matchChoiceInput == MatchChoice.widthOnly
    requestedMatch := MATCH_WIDTH
else if matchChoiceInput == MatchChoice.closeOnly
    requestedMatch := MATCH_CLOSE

var array<float> historyWidths = array.new<float>()
var array<int> historyWidthClasses = array.new<int>()
var array<int> historyCloseZones = array.new<int>()
var array<int> historyFirstBreaks = array.new<int>()
var array<int> historyFirstMinutes = array.new<int>()
var array<bool> historyBothSides = array.new<bool>()
var array<bool> historyAnyExtensions = array.new<bool>()
var array<bool> historyEdgeRetests = array.new<bool>()
var array<bool> historyMidRetests = array.new<bool>()
var array<bool> historyOppositeTouches = array.new<bool>()
var array<bool> historySameExtensions = array.new<bool>()
var array<int> historyExtensionMinutes = array.new<int>()

var bool activeSession = false
var bool sessionClosed = false
var bool lastSessionAccepted = false
var int activeSessionKey = 0
var int outcomeBarCount = 0
var int openingBarCount = 0
var int openingStartBar = na
var float openingOpen = na
var float openingHigh = na
var float openingLow = na
var float openingClose = na
var float openingWidth = na
var float openingMid = na
var float upperTarget = na
var float lowerTarget = na
var float currentWidthMeasure = na
var float currentWidthRank = na
var int currentWidthHistorySample = 0
var int currentWidthClass = WIDTH_UNKNOWN
var int currentCloseZone = CLOSE_MIDDLE
var bool rangeLocked = false
var bool rangeFailed = false
var bool openingComplete = false
var bool openingStartsAligned = false
var int firstBreakDirection = BREAK_NONE
var int firstBreakBar = na
var int firstBreakElapsed = na
var bool upBroken = false
var bool downBroken = false
var bool bothSidesBroken = false
var bool anyExtensionReached = false
var bool edgeRetested = false
var bool midpointRetested = false
var bool oppositeEdgeTouched = false
var bool sameSideExtension = false
var int extensionElapsed = na
var float lastCoverage = na

var int effectiveMatch = MATCH_ALL
var int upEffectiveMatch = MATCH_ALL
var int downEffectiveMatch = MATCH_ALL
var int matchedSample = 0
var float firstUpPct = na
var float firstDownPct = na
var float firstBothPct = na
var float noBreakPct = na
var float bothSidesPct = na
var float anyExtensionPct = na
var int medianBreakMinutes = na
var int upPostSample = 0
var float upEdgePct = na
var float upMidPct = na
var float upOppositePct = na
var float upExtensionPct = na
var float upBothSidesPct = na
var int upMedianExtension = na
var int downPostSample = 0
var float downEdgePct = na
var float downMidPct = na
var float downOppositePct = na
var float downExtensionPct = na
var float downBothSidesPct = na
var int downMedianExtension = na

bool newSessionEvent = false
bool rangeLockedEvent = false
bool rangeFailedEvent = false
bool firstBreakUpEvent = false
bool firstBreakDownEvent = false
bool firstBreakBothEvent = false
bool edgeRetestEvent = false
bool midpointRetestEvent = false
bool oppositeTouchEvent = false
bool sameExtensionEvent = false
bool bothSidesEvent = false
bool scheduledCloseEvent = false

if configValid and barstate.isconfirmed
    bool finalizeNow = activeSession and (not inOutcome or currentSessionKey != activeSessionKey)
    if finalizeNow
        lastCoverage := expectedOutcomeBars > 0 ? 100.0 * outcomeBarCount / expectedOutcomeBars : na
        bool coverageEnough = lastCoverage >= minCoverageInput
        bool coverageNotHigh = lastCoverage <= MAX_COVERAGE
        lastSessionAccepted := rangeLocked and openingComplete
        lastSessionAccepted := lastSessionAccepted and coverageEnough and coverageNotHigh
        if lastSessionAccepted
            storeSession(historyWidths, historyWidthClasses,
              historyCloseZones, historyFirstBreaks, historyFirstMinutes,
              historyBothSides, historyAnyExtensions, historyEdgeRetests,
              historyMidRetests, historyOppositeTouches,
              historySameExtensions, historyExtensionMinutes,
              currentWidthMeasure, currentWidthClass, currentCloseZone,
              firstBreakDirection,
              na(firstBreakElapsed) ? -1 : firstBreakElapsed,
              bothSidesBroken, anyExtensionReached, edgeRetested,
              midpointRetested, oppositeEdgeTouched, sameSideExtension,
              na(extensionElapsed) ? -1 : extensionElapsed,
              historyLimitInput)
        activeSession := false
        activeSessionKey := 0
        sessionClosed := true
    if inOutcome and not activeSession
        activeSession := true
        activeSessionKey := currentSessionKey
        sessionClosed := false
        lastSessionAccepted := false
        outcomeBarCount := 0
        openingBarCount := 0
        openingStartBar := bar_index
        openingOpen := na
        openingHigh := na
        openingLow := na
        openingClose := na
        openingWidth := na
        openingMid := na
        upperTarget := na
        lowerTarget := na
        currentWidthMeasure := na
        currentWidthRank := na
        currentWidthHistorySample := 0
        currentWidthClass := WIDTH_UNKNOWN
        currentCloseZone := CLOSE_MIDDLE
        rangeLocked := false
        rangeFailed := false
        openingComplete := false
        openingStartsAligned := false
        firstBreakDirection := BREAK_NONE
        firstBreakBar := na
        firstBreakElapsed := na
        upBroken := false
        downBroken := false
        bothSidesBroken := false
        anyExtensionReached := false
        edgeRetested := false
        midpointRetested := false
        oppositeEdgeTouched := false
        sameSideExtension := false
        extensionElapsed := na
        lastCoverage := na
        effectiveMatch := MATCH_ALL
        upEffectiveMatch := MATCH_ALL
        downEffectiveMatch := MATCH_ALL
        matchedSample := 0
        firstUpPct := na
        firstDownPct := na
        firstBothPct := na
        noBreakPct := na
        bothSidesPct := na
        anyExtensionPct := na
        medianBreakMinutes := na
        upPostSample := 0
        upEdgePct := na
        upMidPct := na
        upOppositePct := na
        upExtensionPct := na
        upBothSidesPct := na
        upMedianExtension := na
        downPostSample := 0
        downEdgePct := na
        downMidPct := na
        downOppositePct := na
        downExtensionPct := na
        downBothSidesPct := na
        downMedianExtension := na
        newSessionEvent := true
    if activeSession and currentSessionKey == activeSessionKey
        outcomeBarCount += 1
        if inOpeningRange and not rangeLocked
            openingBarCount += 1
            if openingBarCount == 1
                openingOpen := open
                openingHigh := high
                openingLow := low
                openingStartsAligned := localMinute == orFrom
            else
                openingHigh := math.max(openingHigh, high)
                openingLow := math.min(openingLow, low)
            openingClose := close
            int openingElapsed = minutesSince(localMinute, orFrom)
            bool lastOpeningBar = openingElapsed + chartTfMinutes >= orMinutes
            if lastOpeningBar
                bool openingBarsComplete = openingBarCount == expectedOrBars
                bool openingHasWidth = openingHigh > openingLow
                bool openingHasBase = math.abs(openingOpen) > FLOAT_EPS
                openingComplete := openingBarsComplete and openingStartsAligned
                openingComplete := openingComplete and openingHasWidth and openingHasBase
                if openingComplete
                    rangeLocked := true
                    openingWidth := openingHigh - openingLow
                    openingMid := (openingHigh + openingLow) / 2.0
                    upperTarget := openingHigh + openingWidth * extensionInput
                    lowerTarget := openingLow - openingWidth * extensionInput
                    float widthBase = math.abs(openingOpen)
                    currentWidthMeasure := 100.0 * openingWidth / widthBase
                    int historyRows = array.size(historyWidths)
                    currentWidthHistorySample := historyRows
                    if historyRows >= HARD_MIN_SAMPLE
                        int lessCount = 0
                        int equalCount = 0
                        for rowIndex = 0 to historyRows - 1
                            float priorWidth = array.get(historyWidths, rowIndex)
                            if priorWidth < currentWidthMeasure - FLOAT_EPS
                                lessCount += 1
                            else if math.abs(priorWidth - currentWidthMeasure) <= FLOAT_EPS
                                equalCount += 1
                        currentWidthRank := 100.0 * (lessCount + 0.5 * equalCount) / historyRows
                        currentWidthClass := WIDTH_TYPICAL
                        if currentWidthRank < WIDTH_LOW_PCT
                            currentWidthClass := WIDTH_NARROW
                        else if currentWidthRank > WIDTH_HIGH_PCT
                            currentWidthClass := WIDTH_WIDE
                    float closePosition = math.min(1.0,
                      math.max(0.0, (openingClose - openingLow) / openingWidth))
                    currentCloseZone := CLOSE_MIDDLE
                    if closePosition < CLOSE_LOW_EDGE
                        currentCloseZone := CLOSE_LOWER
                    else if closePosition > CLOSE_HIGH_EDGE
                        currentCloseZone := CLOSE_UPPER
                    int exactCount = 0
                    int widthCount = 0
                    int closeCount = 0
                    int exactUpCount = 0
                    int widthUpCount = 0
                    int closeUpCount = 0
                    int exactDownCount = 0
                    int widthDownCount = 0
                    int closeDownCount = 0
                    if historyRows > 0
                        for rowIndex = 0 to historyRows - 1
                            int rowWidth = array.get(historyWidthClasses,
                              rowIndex)
                            int rowClose = array.get(historyCloseZones, rowIndex)
                            int rowBreak = array.get(historyFirstBreaks, rowIndex)
                            bool widthKnownNow = currentWidthClass != WIDTH_UNKNOWN
                            bool widthHit = widthKnownNow and rowWidth == currentWidthClass
                            bool closeHit = rowClose == currentCloseZone
                            bool exactHit = widthHit and closeHit
                            exactCount += exactHit ? 1 : 0
                            widthCount += widthHit ? 1 : 0
                            closeCount += closeHit ? 1 : 0
                            if rowBreak == BREAK_UP
                                exactUpCount += exactHit ? 1 : 0
                                widthUpCount += widthHit ? 1 : 0
                                closeUpCount += closeHit ? 1 : 0
                            else if rowBreak == BREAK_DOWN
                                exactDownCount += exactHit ? 1 : 0
                                widthDownCount += widthHit ? 1 : 0
                                closeDownCount += closeHit ? 1 : 0
                    effectiveMatch := requestedMatch
                    upEffectiveMatch := requestedMatch
                    downEffectiveMatch := requestedMatch
                    if requestedMatch == MATCH_ADAPTIVE
                        effectiveMatch := adaptiveMatch(
                          exactCount, widthCount, closeCount, minMatchInput)
                        upEffectiveMatch := adaptiveMatch(
                          exactUpCount, widthUpCount, closeUpCount, minMatchInput)
                        downEffectiveMatch := adaptiveMatch(
                          exactDownCount, widthDownCount, closeDownCount,
                          minMatchInput)
                    int upFirstCount = 0
                    int downFirstCount = 0
                    int bothFirstCount = 0
                    int noFirstCount = 0
                    int bothSidesCount = 0
                    int anyExtensionCount = 0
                    int upEdgeCount = 0
                    int upMidCount = 0
                    int upOppositeCount = 0
                    int upExtensionCount = 0
                    int upBothSidesCount = 0
                    int downEdgeCount = 0
                    int downMidCount = 0
                    int downOppositeCount = 0
                    int downExtensionCount = 0
                    int downBothSidesCount = 0
                    array<int> breakMinuteRows = array.new<int>()
                    array<int> upExtensionRows = array.new<int>()
                    array<int> downExtensionRows = array.new<int>()
                    matchedSample := 0
                    upPostSample := 0
                    downPostSample := 0
                    if historyRows > 0
                        for rowIndex = 0 to historyRows - 1
                            int priorBreak = array.get(historyFirstBreaks,
                              rowIndex)
                            bool baseMatched = recordMatches(rowIndex,
                              effectiveMatch, historyWidthClasses,
                              historyCloseZones, currentWidthClass,
                              currentCloseZone)
                            if baseMatched
                                matchedSample += 1
                                int priorBreakMin = array.get(
                                  historyFirstMinutes, rowIndex)
                                upFirstCount += priorBreak == BREAK_UP ? 1 : 0
                                downFirstCount += priorBreak == BREAK_DOWN ? 1 : 0
                                bothFirstCount += priorBreak == BREAK_BOTH ? 1 : 0
                                noFirstCount += priorBreak == BREAK_NONE ? 1 : 0
                                bothSidesCount += array.get(historyBothSides,
                                  rowIndex) ? 1 : 0
                                anyExtensionCount += array.get(
                                  historyAnyExtensions, rowIndex) ? 1 : 0
                                if priorBreakMin >= 0 and priorBreak != BREAK_NONE
                                    array.push(breakMinuteRows, priorBreakMin)
                            bool priorWasUp = priorBreak == BREAK_UP
                            bool upContextMatch = recordMatches(
                              rowIndex, upEffectiveMatch, historyWidthClasses,
                              historyCloseZones, currentWidthClass, currentCloseZone)
                            bool upMatched = priorWasUp and upContextMatch
                            if upMatched
                                upPostSample += 1
                                upEdgeCount += array.get(historyEdgeRetests,
                                  rowIndex) ? 1 : 0
                                upMidCount += array.get(historyMidRetests,
                                  rowIndex) ? 1 : 0
                                upOppositeCount += array.get(
                                  historyOppositeTouches, rowIndex) ? 1 : 0
                                bool priorUpExtension = array.get(
                                  historySameExtensions, rowIndex)
                                upExtensionCount += priorUpExtension ? 1 : 0
                                upBothSidesCount += array.get(historyBothSides,
                                  rowIndex) ? 1 : 0
                                int priorUpExtensionMin = array.get(
                                  historyExtensionMinutes, rowIndex)
                                if priorUpExtension and priorUpExtensionMin >= 0
                                    array.push(upExtensionRows,
                                      priorUpExtensionMin)
                            bool priorWasDown = priorBreak == BREAK_DOWN
                            bool downContextMatch = recordMatches(
                              rowIndex, downEffectiveMatch, historyWidthClasses,
                              historyCloseZones, currentWidthClass, currentCloseZone)
                            bool downMatched = priorWasDown and downContextMatch
                            if downMatched
                                downPostSample += 1
                                downEdgeCount += array.get(historyEdgeRetests,
                                  rowIndex) ? 1 : 0
                                downMidCount += array.get(historyMidRetests,
                                  rowIndex) ? 1 : 0
                                downOppositeCount += array.get(
                                  historyOppositeTouches, rowIndex) ? 1 : 0
                                bool priorDownExtension = array.get(
                                  historySameExtensions, rowIndex)
                                downExtensionCount += priorDownExtension ? 1 : 0
                                downBothSidesCount += array.get(historyBothSides,
                                  rowIndex) ? 1 : 0
                                int priorDownExtensionMin = array.get(
                                  historyExtensionMinutes, rowIndex)
                                if priorDownExtension and priorDownExtensionMin >= 0
                                    array.push(downExtensionRows,
                                      priorDownExtensionMin)
                    if matchedSample >= HARD_MIN_SAMPLE
                        firstUpPct := observedShare(upFirstCount, matchedSample)
                        firstDownPct := observedShare(downFirstCount,
                          matchedSample)
                        firstBothPct := observedShare(bothFirstCount,
                          matchedSample)
                        noBreakPct := observedShare(noFirstCount, matchedSample)
                        bothSidesPct := observedShare(bothSidesCount,
                          matchedSample)
                        anyExtensionPct := observedShare(anyExtensionCount,
                          matchedSample)
                        medianBreakMinutes := array.size(breakMinuteRows)
                          >= HARD_MIN_SAMPLE ? medianInt(breakMinuteRows) : na
                    if upPostSample >= HARD_MIN_SAMPLE
                        upEdgePct := observedShare(upEdgeCount, upPostSample)
                        upMidPct := observedShare(upMidCount, upPostSample)
                        upOppositePct := observedShare(upOppositeCount,
                          upPostSample)
                        upExtensionPct := observedShare(upExtensionCount,
                          upPostSample)
                        upBothSidesPct := observedShare(upBothSidesCount,
                          upPostSample)
                        upMedianExtension := array.size(upExtensionRows)
                          >= HARD_MIN_SAMPLE ? medianInt(upExtensionRows) : na
                    if downPostSample >= HARD_MIN_SAMPLE
                        downEdgePct := observedShare(downEdgeCount,
                          downPostSample)
                        downMidPct := observedShare(downMidCount,
                          downPostSample)
                        downOppositePct := observedShare(downOppositeCount,
                          downPostSample)
                        downExtensionPct := observedShare(downExtensionCount,
                          downPostSample)
                        downBothSidesPct := observedShare(downBothSidesCount,
                          downPostSample)
                        downMedianExtension := array.size(downExtensionRows)
                          >= HARD_MIN_SAMPLE ? medianInt(downExtensionRows) : na
                    rangeLockedEvent := true
                else
                    rangeFailed := true
                    rangeFailedEvent := true
        else if not rangeLocked and not rangeFailed
            rangeFailed := true
            rangeFailedEvent := true
        else if rangeLocked
            bool upNow = high > openingHigh
            bool downNow = low < openingLow
            if breakBasisInput == BreakBasis.closeBreak
                upNow := close > openingHigh
                downNow := close < openingLow
            bool bothBefore = bothSidesBroken
            upBroken := upBroken or upNow
            downBroken := downBroken or downNow
            bothSidesBroken := upBroken and downBroken
            bothSidesEvent := bothSidesBroken and not bothBefore
            bool firstWasPending = firstBreakDirection == BREAK_NONE
            if firstWasPending
                if upNow and downNow
                    firstBreakDirection := BREAK_BOTH
                    firstBreakBar := bar_index
                    firstBreakElapsed := minutesSince(localMinute, orTo) + chartTfMinutes
                    firstBreakBothEvent := true
                else if upNow
                    firstBreakDirection := BREAK_UP
                    firstBreakBar := bar_index
                    firstBreakElapsed := minutesSince(localMinute, orTo) + chartTfMinutes
                    firstBreakUpEvent := true
                else if downNow
                    firstBreakDirection := BREAK_DOWN
                    firstBreakBar := bar_index
                    firstBreakElapsed := minutesSince(localMinute, orTo) + chartTfMinutes
                    firstBreakDownEvent := true
            bool anyTargetNow = high >= upperTarget or low <= lowerTarget
            anyExtensionReached := anyExtensionReached or anyTargetNow
            if firstBreakDirection == BREAK_UP or firstBreakDirection == BREAK_DOWN
                bool sameTargetNow = low <= lowerTarget
                if firstBreakDirection == BREAK_UP
                    sameTargetNow := high >= upperTarget
                if sameTargetNow and not sameSideExtension
                    sameSideExtension := true
                    int nowElapsed = minutesSince(localMinute, orTo) + chartTfMinutes
                    extensionElapsed := math.max(0,
                      nowElapsed - firstBreakElapsed)
                    sameExtensionEvent := true
                if bar_index > firstBreakBar
                    bool edgeNow = high >= openingLow and low <= openingLow
                    bool midpointNow = high >= openingMid and low <= openingMid
                    bool oppositeNow = high >= openingHigh
                    if firstBreakDirection == BREAK_UP
                        edgeNow := low <= openingHigh and high >= openingHigh
                        oppositeNow := low <= openingLow
                    if edgeNow and not edgeRetested
                        edgeRetested := true
                        edgeRetestEvent := true
                    if midpointNow and not midpointRetested
                        midpointRetested := true
                        midpointRetestEvent := true
                    if oppositeNow and not oppositeEdgeTouched
                        oppositeEdgeTouched := true
                        oppositeTouchEvent := true
    int outcomeElapsed = minutesSince(localMinute, outcomeFrom)
    bool activeOutcomeSession = activeSession and inOutcome
    bool sameOutcomeKey = currentSessionKey == activeSessionKey
    bool reachesOutcomeEnd = outcomeElapsed + chartTfMinutes >= outcomeMinutes
    bool scheduledClose = activeOutcomeSession and sameOutcomeKey and reachesOutcomeEnd
    if scheduledClose
        lastCoverage := expectedOutcomeBars > 0 ? 100.0 * outcomeBarCount / expectedOutcomeBars : na
        bool closeCoverageEnough = lastCoverage >= minCoverageInput
        bool closeCoverageNotHigh = lastCoverage <= MAX_COVERAGE
        lastSessionAccepted := rangeLocked and openingComplete
        lastSessionAccepted := lastSessionAccepted and closeCoverageEnough and closeCoverageNotHigh
        if lastSessionAccepted
            storeSession(historyWidths, historyWidthClasses,
              historyCloseZones, historyFirstBreaks, historyFirstMinutes,
              historyBothSides, historyAnyExtensions, historyEdgeRetests,
              historyMidRetests, historyOppositeTouches,
              historySameExtensions, historyExtensionMinutes,
              currentWidthMeasure, currentWidthClass, currentCloseZone,
              firstBreakDirection,
              na(firstBreakElapsed) ? -1 : firstBreakElapsed,
              bothSidesBroken, anyExtensionReached, edgeRetested,
              midpointRetested, oppositeEdgeTouched, sameSideExtension,
              na(extensionElapsed) ? -1 : extensionElapsed,
              historyLimitInput)
        activeSession := false
        activeSessionKey := 0
        sessionClosed := true
        scheduledCloseEvent := true

//#endregion

//#region VISUALS ==============================================================

var box openingBox = na
var line highLine = na
var line lowLine = na
var line midpointLine = na
var line upperTargetLine = na
var line lowerTargetLine = na
var label highLevelTag = na
var label lowLevelTag = na
var label targetLevelTag = na
var array<label> eventLabels = array.new<label>()
var table outcomeBoard = table.new(position.top_right, BOARD_COLS, BOARD_ROWS,
  frame_color = color.new(chart.fg_color, 90), frame_width = 0,
  border_width = 0)

string selectedRangeLineStyle = strokeValue(rangeLineStyleInput)
string selectedTargetLineStyle = strokeValue(targetLineStyleInput)

if newSessionEvent
    if not na(openingBox)
        box.delete(openingBox)
        openingBox := na
    if not na(highLine)
        line.delete(highLine)
        highLine := na
    if not na(lowLine)
        line.delete(lowLine)
        lowLine := na
    if not na(midpointLine)
        line.delete(midpointLine)
        midpointLine := na
    if not na(upperTargetLine)
        line.delete(upperTargetLine)
        upperTargetLine := na
    if not na(lowerTargetLine)
        line.delete(lowerTargetLine)
        lowerTargetLine := na
    if not na(highLevelTag)
        label.delete(highLevelTag)
        highLevelTag := na
    if not na(lowLevelTag)
        label.delete(lowLevelTag)
        lowLevelTag := na
    if not na(targetLevelTag)
        label.delete(targetLevelTag)
        targetLevelTag := na
    if array.size(eventLabels) > 0
        for labelIndex = 0 to array.size(eventLabels) - 1
            label.delete(array.get(eventLabels, labelIndex))
        array.clear(eventLabels)
    if showRangeInput
        openingBox := box.new(openingStartBar, high, bar_index, low,
          xloc = xloc.bar_index, border_width = 0, bgcolor = rangeFillInput)

bool updateOpeningBox = showRangeInput and activeSession and inOpeningRange
updateOpeningBox := updateOpeningBox and (not rangeLocked or rangeLockedEvent)
updateOpeningBox := updateOpeningBox and not na(openingBox)
if updateOpeningBox
    box.set_top(openingBox, openingHigh)
    box.set_bottom(openingBox, openingLow)
    box.set_right(openingBox, bar_index)

if rangeFailedEvent and not na(openingBox)
    box.delete(openingBox)
    openingBox := na

if rangeLockedEvent and showRangeInput
    highLine := line.new(openingStartBar, openingHigh, bar_index + 1, openingHigh,
      xloc = xloc.bar_index, color = upColorInput,
      style = selectedRangeLineStyle, width = lineWidthInput)
    lowLine := line.new(openingStartBar, openingLow, bar_index + 1, openingLow,
      xloc = xloc.bar_index, color = downColorInput,
      style = selectedRangeLineStyle, width = lineWidthInput)
    if showMidpointInput
        midpointLine := line.new(openingStartBar, openingMid, bar_index + 1,
          openingMid, xloc = xloc.bar_index, color = midpointColorInput,
          style = selectedRangeLineStyle, width = lineWidthInput)

if showRangeInput and showTargetsInput and firstBreakUpEvent
    upperTargetLine := line.new(firstBreakBar, upperTarget, bar_index + 1,
      upperTarget, xloc = xloc.bar_index, color = upColorInput,
      style = selectedTargetLineStyle, width = lineWidthInput)
if showRangeInput and showTargetsInput and firstBreakDownEvent
    lowerTargetLine := line.new(firstBreakBar, lowerTarget, bar_index + 1,
      lowerTarget, xloc = xloc.bar_index, color = downColorInput,
      style = selectedTargetLineStyle, width = lineWidthInput)

if showRangeInput and rangeLocked and (activeSession or scheduledCloseEvent)
    if not na(highLine)
        line.set_x2(highLine, bar_index + 1)
    if not na(lowLine)
        line.set_x2(lowLine, bar_index + 1)
    if not na(midpointLine)
        line.set_x2(midpointLine, bar_index + 1)
    if not na(upperTargetLine)
        line.set_x2(upperTargetLine, bar_index + 1)
    if not na(lowerTargetLine)
        line.set_x2(lowerTargetLine, bar_index + 1)

string eventNote = ""
bool firstBreakEvent = firstBreakUpEvent or firstBreakDownEvent
firstBreakEvent := firstBreakEvent or firstBreakBothEvent
bool laterBothEvent = bothSidesEvent and not firstBreakBothEvent
bool keyEventNow = firstBreakEvent or sameExtensionEvent or laterBothEvent
bool allEventNow = keyEventNow or edgeRetestEvent or midpointRetestEvent or oppositeTouchEvent
bool allLabelsSelected = eventLabelsInput == EventLabelMode.all
bool keyLabelsSelected = eventLabelsInput == EventLabelMode.key
bool labelEventNow = allLabelsSelected and allEventNow
labelEventNow := labelEventNow or keyLabelsSelected and keyEventNow
if labelEventNow
    if firstBreakUpEvent
        eventNote := "Break Up"
    else if firstBreakDownEvent
        eventNote := "Break Down"
    else if firstBreakBothEvent
        eventNote := "Both Edges"
    if eventLabelsInput == EventLabelMode.all and edgeRetestEvent
        eventNote := eventNote + (str.length(eventNote) > 0 ? " | " : "") + "Edge Retest"
    if eventLabelsInput == EventLabelMode.all and midpointRetestEvent
        eventNote := eventNote + (str.length(eventNote) > 0 ? " | " : "") + "Midpoint"
    if eventLabelsInput == EventLabelMode.all and oppositeTouchEvent
        eventNote := eventNote + (str.length(eventNote) > 0 ? " | " : "") + "Opposite Edge"
    if sameExtensionEvent
        string eventJoin = str.length(eventNote) > 0 ? " | " : ""
        eventNote := eventNote + eventJoin
        eventNote := eventNote + str.tostring(extensionInput, "#.##") + "x Target"
    if bothSidesEvent and not firstBreakBothEvent
        eventNote := eventNote + (str.length(eventNote) > 0 ? " | " : "") + "Both Sides"

if showRangeInput and str.length(eventNote) > 0
    float labelPrice = close
    if firstBreakUpEvent
        labelPrice := openingHigh
    else if firstBreakDownEvent
        labelPrice := openingLow
    else if sameExtensionEvent and firstBreakDirection == BREAK_UP
        labelPrice := upperTarget
    else if sameExtensionEvent and firstBreakDirection == BREAK_DOWN
        labelPrice := lowerTarget
    else if oppositeTouchEvent and firstBreakDirection == BREAK_UP
        labelPrice := openingLow
    else if oppositeTouchEvent and firstBreakDirection == BREAK_DOWN
        labelPrice := openingHigh
    else if midpointRetestEvent or bothSidesEvent
        labelPrice := openingMid
    else if edgeRetestEvent and firstBreakDirection == BREAK_UP
        labelPrice := openingHigh
    else if edgeRetestEvent and firstBreakDirection == BREAK_DOWN
        labelPrice := openingLow
    bool labelAbove = labelPrice >= openingMid
    color directionTone = WARN_COLOR
    if firstBreakDirection == BREAK_UP
        directionTone := upColorInput
    else if firstBreakDirection == BREAK_DOWN
        directionTone := downColorInput
    bool retestTone = edgeRetestEvent or midpointRetestEvent or oppositeTouchEvent
    color labelTone = directionTone
    if retestTone
        labelTone := HIT_COLOR
    else if bothSidesEvent or firstBreakBothEvent
        labelTone := WARN_COLOR
    color labelFill = labelBgInput ? chart.bg_color : color.new(chart.bg_color, 100)
    string labelShape = labelAbove ? label.style_label_down : label.style_label_up
    label eventTag = label.new(bar_index, labelPrice, eventNote,
      xloc = xloc.bar_index, yloc = yloc.price, color = labelFill,
      style = labelShape, textcolor = labelTone, size = labelSizeInput)
    array.push(eventLabels, eventTag)
    while array.size(eventLabels) > MAX_EVENT_LABELS
        label oldTag = array.shift(eventLabels)
        label.delete(oldTag)

bool levelTagsVisible = barstate.islast and showRangeInput
levelTagsVisible := levelTagsVisible and showLevelLabelsInput and rangeLocked
levelTagsVisible := levelTagsVisible and (activeSession or scheduledCloseEvent)
color levelTagFill = labelBgInput ? chart.bg_color : color.new(chart.bg_color, 100)
int levelTagX = bar_index + LEVEL_LABEL_OFFSET

if levelTagsVisible
    if na(highLevelTag)
        highLevelTag := label.new(levelTagX, openingHigh, "OR High",
          xloc = xloc.bar_index, yloc = yloc.price, color = levelTagFill,
          style = label.style_label_left, textcolor = upColorInput,
          size = labelSizeInput)
    label.set_xy(highLevelTag, levelTagX, openingHigh)
    label.set_color(highLevelTag, levelTagFill)
    label.set_textcolor(highLevelTag, upColorInput)
    label.set_size(highLevelTag, labelSizeInput)
    if na(lowLevelTag)
        lowLevelTag := label.new(levelTagX, openingLow, "OR Low",
          xloc = xloc.bar_index, yloc = yloc.price, color = levelTagFill,
          style = label.style_label_left, textcolor = downColorInput,
          size = labelSizeInput)
    label.set_xy(lowLevelTag, levelTagX, openingLow)
    label.set_color(lowLevelTag, levelTagFill)
    label.set_textcolor(lowLevelTag, downColorInput)
    label.set_size(lowLevelTag, labelSizeInput)

bool targetHasDirection = firstBreakDirection == BREAK_UP or firstBreakDirection == BREAK_DOWN
bool targetTagVisible = levelTagsVisible and showTargetsInput and targetHasDirection
if targetTagVisible
    bool targetUp = firstBreakDirection == BREAK_UP
    float targetPrice = targetUp ? upperTarget : lowerTarget
    color targetTone = targetUp ? upColorInput : downColorInput
    string targetText = str.tostring(extensionInput, "#.##") + "x Extension"
    if na(targetLevelTag)
        targetLevelTag := label.new(levelTagX, targetPrice, targetText,
          xloc = xloc.bar_index, yloc = yloc.price, color = levelTagFill,
          style = label.style_label_left, textcolor = targetTone,
          size = labelSizeInput)
    label.set_xy(targetLevelTag, levelTagX, targetPrice)
    label.set_text(targetLevelTag, targetText)
    label.set_color(targetLevelTag, levelTagFill)
    label.set_textcolor(targetLevelTag, targetTone)
    label.set_size(targetLevelTag, labelSizeInput)

if barstate.islast and not levelTagsVisible
    if not na(highLevelTag)
        label.delete(highLevelTag)
        highLevelTag := na
    if not na(lowLevelTag)
        label.delete(lowLevelTag)
        lowLevelTag := na

if barstate.islast and not targetTagVisible
    if not na(targetLevelTag)
        label.delete(targetLevelTag)
        targetLevelTag := na

if barstate.islast
    table.set_position(outcomeBoard, panelPosition(panelSpotInput))
    table.clear(outcomeBoard, 0, 0, BOARD_COLS - 1, BOARD_ROWS - 1)
    if showDashboardInput
        color neutralCellBg = color.new(chart.bg_color, 8)
        color mutedCellBg = color.new(MID_COLOR, 94)
        bool summarySession = activeSession or scheduledCloseEvent
        if not configValid
            table.cell(outcomeBoard, 0, 0, "Setup", text_color = chart.fg_color,
              text_size = panelSizeInput, text_halign = text.align_left,
              bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 1, 0, configIssue, text_color = WARN_COLOR,
              text_size = panelSizeInput, text_halign = text.align_center,
              bgcolor = neutralCellBg)
            string setupInfo = str.tostring(orMinutes) + "m OR | "
            setupInfo := setupInfo + str.tostring(chartTfMinutes) + "m chart"
            table.cell(outcomeBoard, 2, 0, setupInfo, text_color = MID_COLOR,
              text_size = panelSizeInput, text_halign = text.align_center,
              bgcolor = neutralCellBg)
        else if activeSession and rangeFailed
            table.cell(outcomeBoard, 0, 0, "Today", text_color = chart.fg_color,
              text_size = panelSizeInput, text_halign = text.align_left,
              bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 1, 0, "Range incomplete",
              text_color = WARN_COLOR, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 2, 0, "History",
              text_color = MID_COLOR, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = mutedCellBg)
            table.cell(outcomeBoard, 3, 0,
              str.tostring(array.size(historyWidths)) + " sessions",
              text_color = MID_COLOR, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = mutedCellBg)
        else if activeSession and not rangeLocked
            int elapsedMinutes = math.min(orMinutes,
              openingBarCount * chartTfMinutes)
            string progressText = str.tostring(elapsedMinutes) + " / "
            progressText := progressText + str.tostring(orMinutes) + "m"
            bool liveWidthMissing = na(openingHigh) or na(openingLow)
            string liveWidth = "-"
            if not liveWidthMissing
                liveWidth := str.tostring(openingHigh - openingLow, format.mintick)
            table.cell(outcomeBoard, 0, 0, "Today", text_color = chart.fg_color,
              text_size = panelSizeInput, text_halign = text.align_left,
              bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 1, 0, "Building OR",
              text_color = MID_COLOR, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 2, 0, progressText,
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 3, 0, liveWidth,
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = neutralCellBg)
        else if summarySession and rangeLocked
            bool firstSampleReady = matchedSample >= HARD_MIN_SAMPLE
            float otherPct = na(firstBothPct) or na(noBreakPct) ? na : firstBothPct + noBreakPct
            string upBreakText = firstSampleReady ? "UP " + formatPercent(firstUpPct) : "UP -"
            string downBreakText = "DOWN -"
            string otherBreakText = "OTHER -"
            if firstSampleReady
                downBreakText := "DOWN " + formatPercent(firstDownPct)
                otherBreakText := "OTHER " + formatPercent(otherPct)
            bool directionalSharesReady = not na(firstUpPct) and not na(firstDownPct)
            directionalSharesReady := firstSampleReady and directionalSharesReady
            bool upLeads = directionalSharesReady and firstUpPct > firstDownPct
            bool downLeads = directionalSharesReady and firstDownPct > firstUpPct
            if not na(otherPct)
                upLeads := upLeads and firstUpPct > otherPct
                downLeads := downLeads and firstDownPct > otherPct
            color upCellBg = color.new(upColorInput, upLeads ? 82 : 92)
            color downCellBg = color.new(downColorInput, downLeads ? 82 : 92)
            table.cell(outcomeBoard, 0, 0, "First Break",
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_left, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 1, 0, upBreakText,
              text_color = upColorInput, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = upCellBg)
            table.cell(outcomeBoard, 2, 0, downBreakText,
              text_color = downColorInput, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = downCellBg)
            table.cell(outcomeBoard, 3, 0, otherBreakText,
              text_color = MID_COLOR, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = mutedCellBg)

            bool directionalBreak = firstBreakDirection == BREAK_UP
            directionalBreak := directionalBreak or firstBreakDirection == BREAK_DOWN
            bool upDirection = firstBreakDirection == BREAK_UP
            int extensionSample = matchedSample
            int extensionMatch = effectiveMatch
            float extensionPct = anyExtensionPct
            color extensionTone = MID_COLOR
            if directionalBreak and upDirection
                extensionSample := upPostSample
                extensionMatch := upEffectiveMatch
                extensionPct := upExtensionPct
                extensionTone := upColorInput
            else if directionalBreak
                extensionSample := downPostSample
                extensionMatch := downEffectiveMatch
                extensionPct := downExtensionPct
                extensionTone := downColorInput
            string extensionValue = "-"
            if extensionSample >= HARD_MIN_SAMPLE
                extensionValue := formatPercent(extensionPct)
            string multipleText = str.tostring(extensionInput, "#.##") + "x Extension"
            string basedOnText = str.tostring(extensionSample) + " "
            basedOnText := basedOnText + sampleScopeName(extensionMatch) + " "
            if directionalBreak
                string breakScope = upDirection ? "up breaks" : "down breaks"
                basedOnText := basedOnText + breakScope
            else
                basedOnText := basedOnText + "ORs"
            if extensionSample < minMatchInput
                basedOnText := basedOnText + " | Limited"
            table.cell(outcomeBoard, 0, 1, multipleText,
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_left, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 1, 1, extensionValue,
              text_color = extensionTone, text_size = panelSizeInput,
              text_halign = text.align_center,
              bgcolor = color.new(extensionTone, 92))
            table.cell(outcomeBoard, 2, 1, "Based On",
              text_color = MID_COLOR, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = mutedCellBg)
            table.cell(outcomeBoard, 3, 1, basedOnText,
              text_color = extensionSample < minMatchInput ? WARN_COLOR : MID_COLOR,
              text_size = panelSizeInput, text_halign = text.align_center,
              bgcolor = mutedCellBg)

            string todayDirection = "Waiting"
            string todayOutcomeOne = "for first break"
            string todayOutcomeTwo = ""
            color todayTone = MID_COLOR
            if sessionClosed and not lastSessionAccepted
                string coverageText = "No coverage"
                if not na(lastCoverage)
                    coverageText := formatPercent(lastCoverage) + " coverage"
                todayDirection := "Session skipped"
                todayOutcomeOne := coverageText
                todayOutcomeTwo := ""
                todayTone := WARN_COLOR
            else if firstBreakDirection == BREAK_UP
                todayDirection := "UP first"
                todayOutcomeOne := "Retest " + outcomeState(edgeRetested, sessionClosed)
                todayOutcomeTwo := str.tostring(extensionInput, "#.##") + "x "
                todayOutcomeTwo := todayOutcomeTwo + outcomeState(sameSideExtension, sessionClosed)
                todayTone := upColorInput
            else if firstBreakDirection == BREAK_DOWN
                todayDirection := "DOWN first"
                todayOutcomeOne := "Retest " + outcomeState(edgeRetested, sessionClosed)
                todayOutcomeTwo := str.tostring(extensionInput, "#.##") + "x "
                todayOutcomeTwo := todayOutcomeTwo + outcomeState(sameSideExtension, sessionClosed)
                todayTone := downColorInput
            else if firstBreakDirection == BREAK_BOTH
                todayDirection := "Both same bar"
                todayOutcomeOne := "No order"
                todayOutcomeTwo := ""
                todayTone := WARN_COLOR
            else if sessionClosed
                todayDirection := "No break"
                todayOutcomeOne := "Session closed"
                todayOutcomeTwo := ""
            table.cell(outcomeBoard, 0, 2, "Today",
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_left, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 1, 2, todayDirection,
              text_color = todayTone, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 2, 2, todayOutcomeOne,
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 3, 2, todayOutcomeTwo,
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = neutralCellBg)
        else
            string startText = formatClock(orFrom) + " " + presetZoneName(sessionPresetInput)
            table.cell(outcomeBoard, 0, 0, "Next OR",
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_left, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 1, 0, startText,
              text_color = chart.fg_color, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = neutralCellBg)
            table.cell(outcomeBoard, 2, 0, "History",
              text_color = MID_COLOR, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = mutedCellBg)
            table.cell(outcomeBoard, 3, 0,
              str.tostring(array.size(historyWidths)) + " sessions",
              text_color = MID_COLOR, text_size = panelSizeInput,
              text_halign = text.align_center, bgcolor = mutedCellBg)

//#endregion

//#region ALERTS ===============================================================

alertcondition(rangeLockedEvent, "Opening Range Locked",
  "Opening range locked on {{ticker}}.")
alertcondition(firstBreakUpEvent, "First Break Up",
  "The first confirmed opening-range break was up on {{ticker}}.")
alertcondition(firstBreakDownEvent, "First Break Down",
  "The first confirmed opening-range break was down on {{ticker}}.")
alertcondition(firstBreakBothEvent, "Both Edges On One Bar",
  "One confirmed bar crossed both opening-range edges on {{ticker}}.")
alertcondition(edgeRetestEvent, "Opening Range Edge Retest",
  "Price retested the broken opening-range edge on {{ticker}}.")
alertcondition(midpointRetestEvent, "Opening Range Midpoint Retest",
  "Price retested the opening-range midpoint on {{ticker}}.")
alertcondition(oppositeTouchEvent, "Opposite Opening Range Edge",
  "Price reached the opposite opening-range edge on {{ticker}}.")
alertcondition(sameExtensionEvent, "Opening Range Extension Reached",
  "Price reached the selected same-side opening-range extension on {{ticker}}.")
alertcondition(bothSidesEvent, "Both Opening Range Sides Broke",
  "Both opening-range sides have broken on {{ticker}}.")

//#endregion
````
