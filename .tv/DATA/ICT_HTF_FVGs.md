<!-- tradingview-pine-id: PUB;3bf9640bdf174e09a8168212f63a87d8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT HTF FVGs

Source: https://www.tradingview.com/script/9A7WuqQO-ICT-HTF-FVGs/

## Description

Higher Timeframe Fair Value Gaps with CE and Quarter Levels

What it does
This script draws fair value gaps from two higher timeframes onto the chart you are already looking at, so a 4-hour or daily gap stays visible while you work on a 5-minute chart. Each gap is drawn as a zone anchored at the time the pattern actually formed, with a consequent encroachment (CE) line at its midpoint, and the script then tracks what price does with that zone afterwards: left alone, entered, reached at the CE line, or traded all the way through. Both higher timeframes are chosen by you, and every filter, colour, and lifecycle rule is a setting.

How it works
A fair value gap is a three-candle pattern where the middle candle moves far enough that the first and third candles do not overlap, leaving a price range that was passed through in one direction without trading in the other. The script evaluates that pattern on each selected higher timeframe and projects the resulting zone onto the chart's own bar index, both for its left edge and for any offset applied to its right edge, which is what keeps a weekly zone on the correct spot of an intraday chart and keeps an offset from ever landing inside a trading pause.

[*] A bullish gap exists when the third candle's low is above the first candle's high. The zone spans that distance, and price returns into it from above.
[*] A bearish gap exists when the third candle's high is below the first candle's low. The zone spans that distance, and price returns into it from below.
[*] The CE line sits at the exact midpoint of the zone. The optional quarter lines sit at 25 % and 75 % of it.
[*] Each zone moves through four states: open, touched, CE reached, and mitigated. The border style and the fill opacity show which state a zone is in.
[*] A zone is only created once all three candles of its pattern have closed on their own timeframe. Nothing is drawn from a candle that is still forming.
[*] Optional filters can reject a gap before it is drawn: direction, the trend of its own timeframe, the quality of the middle candle, and the time window it formed in.

How to use it

[*] Add the script and set the two higher timeframes you follow. Both must be at or above the chart timeframe; a lower one is switched off and named on the chart.
[*] Read the zones as areas price has left behind, not as signals. The colour tells you which timeframe and direction a zone belongs to, the label repeats it in text.
[*] Watch the state. A solid border means untouched, a dashed border means price has been inside, a faded zone has been traded through completely. There is no legend on the chart; the colour tied to each timeframe is set in the Style group of the settings.
[*] Require Displacement is on by default and removes gaps left by quiet candles. Turn on the remaining filters one at a time if there are still more zones than you want.
[*] Set Extend Zones to match how you read a chart: ending a fixed number of bars right of price, freezing where a zone was traded through, or running to the right edge.

Inputs

[*] Timeframes - two independent slots, each with an on/off switch and its own timeframe. A slot below the chart timeframe is ignored.
[*] Direction - keep both directions, or only bullish or only bearish gaps.
[*] Require Displacement - on by default. Demands that the middle candle's body covers at least a chosen share of its range, optionally that its range reaches a multiple of the ATR of its own timeframe. Body share 0-100 %, default 50; ATR multiple 0-10, default 0 which switches that half off.
[*] Trend Filter - compares the close of the last completed bar of the slot timeframe with an EMA on that same timeframe, and keeps only gaps with or against that direction. EMA length 2-500, default 50.
[*] Session Filter - keeps only gaps whose middle candle starts inside a chosen window, in a chosen timezone. A slot on a daily timeframe or higher ignores it.
[*] Interaction Basis - whether a bar's wick or only its close counts as reaching a zone, its CE line, or its far edge.
[*] Mitigation Basis - HTF Bar Close advances a zone only when a bar of its own timeframe closes; Chart Bar advances it on every closed chart bar.
[*] Zones Per Timeframe - how many zones each slot keeps before the oldest is removed. Range 1-20, default 3.
[*] Extend Zones - To Current Bar keeps open zones ending a set number of bars right of price, Until Mitigated freezes a zone where it was traded through, Always runs every zone to the right edge. Right Offset 0-200 bars, default 10.
[*] Labels - content and text size as a number from 8 to 40, default 12. Position is fixed just outside the right edge of the zone, at CE height.
[*] Style - a bullish and a bearish colour per slot, fill opacity, mitigated opacity, border width where zero draws no border, and the CE line style and width.

Settings that only apply under a condition are greyed out until that condition is met, so an inactive option cannot be changed by mistake.

Signals and alerts

[*] New FVG formed - a new zone has been created on one of the two timeframes.
[*] FVG entered - price has reached into a zone for the first time.
[*] CE reached - price has reached the midpoint of a zone.
[*] FVG mitigated - price has traded through an entire zone.

Every alert fires once per bar close. Each type fires at most once per bar; the message names the direction and timeframe of the zone nearest to price and, if others made the same move on the same close, how many. Require Displacement is on by default, which lowers how many gaps are drawn in the first place and therefore how often these alerts fire; turn it off to see and be alerted on every structural gap again.

Repainting
Every value used to build a zone is read from bars that have already closed on their own timeframe. The request is offset by at least one bar and paired with lookahead, which is the combination that returns the last completed higher-timeframe bar rather than the one still forming. A zone therefore appears at the close of the third candle of its pattern and never moves afterwards, and state changes are only evaluated on confirmed bars. The visible consequence is deliberate: a gap forming inside a running 4-hour candle is not drawn until that candle closes. Showing it earlier would mean drawing a zone whose edge can still move, because the low of an unfinished candle can fall further and close the gap again.

Limitations

[*] A zone appears only when the higher-timeframe candle that completes it has closed. On a daily slot that can be hours after the move that created the gap.
[*] On a low chart timeframe the loaded history may not reach back far enough to show older zones of a high timeframe, because the zone's left edge sits on a bar index that predates what is currently loaded.
[*] The session filter has no meaning on a daily timeframe or higher and is skipped there, so a slot on daily will show gaps from outside the chosen window.
[*] A timeframe below the chart timeframe cannot be projected meaningfully and is switched off rather than approximated.
[*] The script marks where gaps are and what price has done with them. It does not judge whether a gap will be filled, and it produces no entries, exits, or directional calls.
[*] Only chart bars and higher timeframes are used. No tick data, no volume-derived values, so nothing here depends on the data plan of the account.

This script is a charting tool for educational purposes. It does not provide
financial advice and does not predict future price movement. Trading carries
risk; decisions and their outcome remain yours.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) KronosMMXM

//@version=6
indicator(
  "ICT HTF FVGs", overlay = true,
  max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//#region TYPES ================================================================

enum Direction
    both    = "Both"
    bullish = "Bullish only"
    bearish = "Bearish only"

enum TrendFilter
    off     = "Off"
    aligned = "With slot trend"
    counter = "Against slot trend"

enum TouchBasis
    wick      = "Wick"
    closeOnly = "Close"

enum MitigationBasis
    htfClose = "HTF Bar Close"
    chartBar = "Chart Bar"

enum ExtendMode
    toCurrent      = "To Current Bar + Offset"
    untilMitigated = "Until Mitigated"
    always         = "Always"

enum LabelContent
    timeframeOnly = "Timeframe"
    withDirection = "Timeframe + Direction"
    withDate      = "Timeframe + Direction + Date"

enum LineStyleOption
    solid  = "Solid"
    dashed = "Dashed"
    dotted = "Dotted"

enum SessionTimezone
    exchange = "Exchange"
    newYork  = "America/New_York"
    london   = "Europe/London"
    berlin   = "Europe/Berlin"
    tokyo    = "Asia/Tokyo"
    utc      = "UTC"

//#endregion

//#region CONSTANTS ============================================================

int    DIR_BULL = 1
int    DIR_BEAR = -1
int    DIR_NONE = 0

int    STATE_OPEN      = 0
int    STATE_TOUCHED   = 1
int    STATE_CE        = 2
int    STATE_MITIGATED = 3

int    SLOT_ONE = 0
int    SLOT_TWO = 1

string GRP_TIMEFRAMES = "Timeframes"
string GRP_DETECTION  = "Detection"
string GRP_LIFECYCLE  = "Lifecycle"
string GRP_DISPLAY    = "Display"
string GRP_STYLE      = "Style"
string GRP_ALERTS     = "Alerts"

string TF_1HOUR = "60"
string TF_4HOUR = "240"

string TZ_NEW_YORK = "America/New_York"
string TZ_LONDON   = "Europe/London"
string TZ_BERLIN   = "Europe/Berlin"
string TZ_TOKYO    = "Asia/Tokyo"
string TZ_UTC      = "UTC"

color  SLOT1_BULL_COLOR = #26a69aff
color  SLOT1_BEAR_COLOR = #ef5350ff
color  SLOT2_BULL_COLOR = #3f8fd4ff
color  SLOT2_BEAR_COLOR = #b46fb0ff
color  NEUTRAL_COLOR    = #b2b5beff
color  PANEL_COLOR      = #787b86ff

int    SECONDS_1MIN   = 60
int    SECONDS_1HOUR  = 3600
int    SECONDS_1DAY   = 86400
int    SECONDS_1WEEK  = 604800
int    SECONDS_1MONTH = 2592000

int    MIN_BARS       = 20
int    PERCENT_MAX    = 100
int    PANEL_TRANSP   = 85
int    QUARTER_TRANSP = 45
float  FILTER_OFF     = 0.0
float  CE_RATIO       = 0.5
float  QUARTER_UPPER  = 0.75
float  QUARTER_LOWER  = 0.25

string DATE_FORMAT    = "d MMM"
string TEXT_SEPARATOR = " "
string TEXT_COMMA     = ", "
string TEXT_EMPTY     = ""

string DIR_NAME_BULL = "Bullish"
string DIR_NAME_BEAR = "Bearish"

string EVENT_FORMED    = "formed"
string EVENT_ENTERED   = "entered"
string EVENT_CE        = "reached its CE"
string EVENT_MITIGATED = "fully mitigated"

string NOTE_PREFIX = "Below the chart timeframe, not drawn: "

// --- Tooltip texts (multiline strings must stay unindented) ---

string TIP_DISPLACEMENT = """Keeps only gaps whose middle candle is a genuine
displacement candle, measured by the two settings below."""

string TIP_DISPLACEMENT_ATR = """Additional requirement on the middle candle's
full range, in ATR multiples of its own timeframe. Zero switches this part off."""

string TIP_TREND = """Compares the close of the last completed bar of the slot
timeframe with an EMA on that same timeframe and keeps only gaps on the chosen
side."""

string TIP_SESSION = """Keeps only gaps whose middle candle starts inside the
window below. A slot on a daily timeframe or higher ignores this filter, because
a daily candle has no session window of its own."""

string TIP_TOUCH = """Whether a bar's wick or only its close counts as reaching a
zone, its CE line, or its far edge."""

string TIP_MITIGATION = """HTF Bar Close advances a zone only when a bar of its
own timeframe closes. Chart Bar advances it on every closed bar of the chart
timeframe."""

string TIP_ZONES = """The oldest zone of a timeframe is removed once this count
is exceeded."""

string TIP_EXTEND = """To Current Bar keeps every open zone ending a fixed number
of bars to the right of price. Until Mitigated freezes a zone where it was traded
through. Always keeps every zone running to the right edge of the chart."""

string TIP_QUARTER = """Adds the 25 % and 75 % levels of each zone next to the CE
line."""

string TIP_BORDER = """Border thickness of each zone. Zero draws no border at
all, which leaves only the tinted fill."""

//#endregion

//#region INPUTS ===============================================================

bool            slot1EnabledInput        = input.bool(true, "Slot 1", inline = "slot1", group = GRP_TIMEFRAMES)
string          slot1TfInput             = input.timeframe(TF_1HOUR, "", inline = "slot1", group = GRP_TIMEFRAMES, active = slot1EnabledInput)
bool            slot2EnabledInput        = input.bool(true, "Slot 2", inline = "slot2", group = GRP_TIMEFRAMES)
string          slot2TfInput             = input.timeframe(TF_4HOUR, "", inline = "slot2", group = GRP_TIMEFRAMES, active = slot2EnabledInput)

Direction       directionInput           = input.enum(Direction.both, "Direction", group = GRP_DETECTION)
bool            requireDisplacementInput = input.bool(true, "Require Displacement", group = GRP_DETECTION, tooltip = TIP_DISPLACEMENT)
int             minBodyRatioInput        = input.int(50, "Min Body Ratio %", minval = 0, maxval = PERCENT_MAX, group = GRP_DETECTION, active = requireDisplacementInput)
float           minDisplacementAtrInput  = input.float(0.0, "Min Displacement Range (ATR)", minval = 0.0, maxval = 10.0, step = 0.1, group = GRP_DETECTION, active = requireDisplacementInput, tooltip = TIP_DISPLACEMENT_ATR)
int             atrLengthInput           = input.int(14, "ATR Length", minval = 1, maxval = 200, group = GRP_DETECTION, active = requireDisplacementInput)
TrendFilter     trendFilterInput         = input.enum(TrendFilter.off, "Trend Filter", group = GRP_DETECTION, tooltip = TIP_TREND)
int             trendEmaLengthInput      = input.int(50, "Trend EMA Length", minval = 2, maxval = 500, group = GRP_DETECTION, active = trendFilterInput != TrendFilter.off)
bool            sessionFilterInput       = input.bool(false, "Session Filter", group = GRP_DETECTION, tooltip = TIP_SESSION)
string          sessionInput             = input.session("0700-1100", "Session", group = GRP_DETECTION, active = sessionFilterInput)
SessionTimezone timezoneInput            = input.enum(SessionTimezone.newYork, "Session Timezone", group = GRP_DETECTION, active = sessionFilterInput)

TouchBasis      touchBasisInput          = input.enum(TouchBasis.wick, "Interaction Basis", group = GRP_LIFECYCLE, tooltip = TIP_TOUCH)
MitigationBasis mitigationBasisInput     = input.enum(MitigationBasis.htfClose, "Mitigation Basis", group = GRP_LIFECYCLE, tooltip = TIP_MITIGATION)
bool            hideMitigatedInput       = input.bool(true, "Hide Mitigated Zones", group = GRP_LIFECYCLE)

int             zonesPerTfInput          = input.int(3, "Zones Per Timeframe", minval = 1, maxval = 20, group = GRP_DISPLAY, tooltip = TIP_ZONES)
ExtendMode      extendModeInput          = input.enum(ExtendMode.toCurrent, "Extend Zones", group = GRP_DISPLAY, tooltip = TIP_EXTEND)
int             rightOffsetInput         = input.int(10, "Right Offset (Bars)", minval = 0, maxval = 200, group = GRP_DISPLAY, active = extendModeInput == ExtendMode.toCurrent)
bool            showCeLineInput          = input.bool(true, "Show CE Line", group = GRP_DISPLAY)
bool            showQuarterLinesInput    = input.bool(false, "Show Quarter Lines", group = GRP_DISPLAY, tooltip = TIP_QUARTER)
bool            showLabelsInput          = input.bool(true, "Show Labels", group = GRP_DISPLAY)
LabelContent    labelContentInput        = input.enum(LabelContent.withDirection, "Label Content", group = GRP_DISPLAY, active = showLabelsInput)
int             textSizeInput            = input.int(12, "Text Size", minval = 8, maxval = 40, group = GRP_DISPLAY)

color           slot1BullColorInput      = input.color(SLOT1_BULL_COLOR, "Slot 1", inline = "col1", group = GRP_STYLE)
color           slot1BearColorInput      = input.color(SLOT1_BEAR_COLOR, "", inline = "col1", group = GRP_STYLE)
color           slot2BullColorInput      = input.color(SLOT2_BULL_COLOR, "Slot 2", inline = "col2", group = GRP_STYLE)
color           slot2BearColorInput      = input.color(SLOT2_BEAR_COLOR, "", inline = "col2", group = GRP_STYLE)
int             zoneOpacityInput         = input.int(10, "Zone Opacity", minval = 0, maxval = PERCENT_MAX, group = GRP_STYLE)
int             mitigatedOpacityInput    = input.int(6, "Mitigated Opacity", minval = 0, maxval = PERCENT_MAX, group = GRP_STYLE, active = not hideMitigatedInput)
int             borderWidthInput         = input.int(1, "Border Width", minval = 0, maxval = 4, group = GRP_STYLE, tooltip = TIP_BORDER)
LineStyleOption ceLineStyleInput         = input.enum(LineStyleOption.dashed, "CE Line Style", group = GRP_STYLE, active = showCeLineInput)
int             ceLineWidthInput         = input.int(1, "CE Line Width", minval = 1, maxval = 4, group = GRP_STYLE, active = showCeLineInput)

bool            alertOnNewInput          = input.bool(true, "Alert On New FVG", group = GRP_ALERTS)
bool            alertOnEntryInput        = input.bool(true, "Alert On Zone Entry", group = GRP_ALERTS)
bool            alertOnCeInput           = input.bool(true, "Alert On CE", group = GRP_ALERTS)
bool            alertOnMitigationInput   = input.bool(true, "Alert On Mitigation", group = GRP_ALERTS)

//#endregion

//#region FUNCTIONS ============================================================

// @function        Formats a timeframe string for labels and alerts.
// @param tf        (simple string) Timeframe to format.
// @returns         (simple string) Compact name such as "15m", "4H" or "1D".
timeframeLabel(simple string tf) =>
    int seconds = timeframe.in_seconds(tf)
    switch
        seconds < SECONDS_1HOUR  => str.tostring(seconds / SECONDS_1MIN) + "m"
        seconds < SECONDS_1DAY   => str.tostring(seconds / SECONDS_1HOUR) + "H"
        seconds < SECONDS_1WEEK  => str.tostring(seconds / SECONDS_1DAY) + "D"
        seconds < SECONDS_1MONTH => str.tostring(seconds / SECONDS_1WEEK) + "W"
        =>                          str.tostring(seconds / SECONDS_1MONTH) + "M"

// @function        Converts a line style option to its line style constant.
// @param styleOpt  (series LineStyleOption) The selected option.
// @returns         (series string) A line.style_* constant.
lineStyleOf(series LineStyleOption styleOpt) =>
    switch styleOpt
        LineStyleOption.solid  => line.style_solid
        LineStyleOption.dotted => line.style_dotted
        =>                        line.style_dashed

// @function        Picks the configured color of one slot and direction.
// @param slotId    (series int) SLOT_ONE or SLOT_TWO.
// @param dirVal    (series int) DIR_BULL or DIR_BEAR.
// @returns         (series color) The matching zone color.
// Dependencies     slot1BullColorInput, slot1BearColorInput, slot2BullColorInput,
// Dependencies     slot2BearColorInput
zoneColor(series int slotId, series int dirVal) =>
    bool isBullish = dirVal == DIR_BULL
    slotId == SLOT_ONE ? (isBullish ? slot1BullColorInput : slot1BearColorInput)
      : (isBullish ? slot2BullColorInput : slot2BearColorInput)

// @function        Detects a fair value gap on the timeframe it is evaluated in
//                   and applies every active filter inside that same context.
//                   Bar offsets: [3] is the first candle of the pattern, [2] the
//                   displacement candle, [1] the third and most recently CLOSED
//                   candle. Nothing is ever read from the bar that is still
//                   forming, which is what makes the result final once reported.
// @param tz        (simple string) Timezone the session window is read in.
// @param isDwm     (simple bool) True when the requested timeframe is daily or
//                   higher, in which case the session filter does not apply.
// @returns         (tuple) Direction (DIR_NONE when there is no gap or a filter
//                   rejected it), zone top, zone bottom, start time of the
//                   pattern, open time of the last closed bar, and that closed
//                   bar's high, low and close.
// Dependencies     atrLengthInput, trendEmaLengthInput, sessionInput, directionInput,
// Dependencies     requireDisplacementInput, minBodyRatioInput, minDisplacementAtrInput,
// Dependencies     sessionFilterInput, trendFilterInput
htfFvgFields(simple string tz, simple bool isDwm) =>
    float atrValue  = ta.atr(atrLengthInput)[1]
    float emaValue  = ta.ema(close, trendEmaLengthInput)[1]
    bool  inSession = not na(time(timeframe.period, sessionInput, tz)[2])
    bool  isBull    = low[1] > high[3]
    bool  isBear    = high[1] < low[3]
    int   rawDir    = isBull ? DIR_BULL : isBear ? DIR_BEAR : DIR_NONE
    float gapTop    = isBull ? low[1] : isBear ? low[3] : na
    float gapBottom = isBull ? high[3] : isBear ? high[1] : na
    float midRange  = high[2] - low[2]
    float bodyRatio = midRange > 0 ? math.abs(close[2] - open[2]) / midRange : 0.0
    bool  trendUp   = close[1] > emaValue

    bool dirOk = directionInput == Direction.both
      or (directionInput == Direction.bullish and rawDir == DIR_BULL)
      or (directionInput == Direction.bearish and rawDir == DIR_BEAR)
    bool bodyOk = not requireDisplacementInput
      or bodyRatio * PERCENT_MAX >= minBodyRatioInput
    bool rangeOk = not requireDisplacementInput
      or minDisplacementAtrInput == FILTER_OFF
      or (not na(atrValue) and midRange >= atrValue * minDisplacementAtrInput)
    bool sessionOk = not sessionFilterInput or isDwm or inSession
    bool trendMatch = rawDir == DIR_BULL ? trendUp : not trendUp
    bool trendOk = trendFilterInput == TrendFilter.off
      or (trendFilterInput == TrendFilter.aligned and trendMatch)
      or (trendFilterInput == TrendFilter.counter and not trendMatch)
    bool keep = dirOk and bodyOk and rangeOk and sessionOk and trendOk

    [keep ? rawDir : DIR_NONE, gapTop, gapBottom, time[3], time[1], high[1], low[1],
      close[1]]

// @function        Requests one higher timeframe with the house anti-repaint
//                   pattern: every element of the returned tuple is read at an
//                   offset of at least one bar, so lookahead_on can only ever
//                   report bars that are already closed.
// @param tf        (simple string) Higher timeframe to request.
// @param tz        (simple string) Timezone the session window is read in.
// @param isDwm     (simple bool) True when `tf` is daily or higher.
// @returns         (tuple) The tuple documented on htfFvgFields().
htfFvgSnapshot(simple string tf, simple string tz, simple bool isDwm) =>
    request.security(
      syminfo.tickerid, tf, htfFvgFields(tz, isDwm), lookahead = barmerge.lookahead_on)

// @function        Records the chart bar_index of one HTF close and returns
//                   where the current three-candle pattern on that slot began.
//                   A bar_index is unaffected by trading pauses or weekends,
//                   which is what a calendar-time offset is not.
// @param closeBars (series array<int>) Rolling history of a slot's last three
//                   HTF-close bar indices, oldest first. Mutated by this call.
// @returns         (series int) bar_index of the chart bar right after the
//                   third-oldest recorded close, or -1 while fewer than three
//                   closes have been recorded yet for this slot.
recordHtfClose(series array<int> closeBars) =>
    int oldestClose  = array.get(closeBars, 0)
    int patternStart = oldestClose == -1 ? -1 : oldestClose + 1
    array.shift(closeBars)
    array.push(closeBars, bar_index)
    patternStart

// zoneAlertMessage(), zoneLabelText() and the five zone-store functions live in
// CALCULATIONS, and refreshZoneGeometry() lives in VISUALS: they read the slot
// names and the parallel state arrays, none of which can be declared before
// the timeframes are resolved.

//#endregion

//#region CALCULATIONS =========================================================

// --- Timeframe resolution ---
int  chartSeconds = timeframe.in_seconds()
int  slot1Seconds = timeframe.in_seconds(slot1TfInput)
int  slot2Seconds = timeframe.in_seconds(slot2TfInput)

bool slot1Usable  = slot1EnabledInput and slot1Seconds >= chartSeconds
bool slot2Usable  = slot2EnabledInput and slot2Seconds >= chartSeconds
bool slot1Blocked = slot1EnabledInput and slot1Seconds < chartSeconds
bool slot2Blocked = slot2EnabledInput and slot2Seconds < chartSeconds
bool slot1IsDwm   = slot1Seconds >= SECONDS_1DAY
bool slot2IsDwm   = slot2Seconds >= SECONDS_1DAY

string slot1Name = timeframeLabel(slot1TfInput)
string slot2Name = timeframeLabel(slot2TfInput)

// Mapped through a ternary chain rather than str.tostring(): time() needs a
// `simple string`, and only this form is guaranteed to keep that qualifier.
string sessionTz = timezoneInput == SessionTimezone.exchange ? syminfo.timezone
  : timezoneInput == SessionTimezone.newYork ? TZ_NEW_YORK
  : timezoneInput == SessionTimezone.london ? TZ_LONDON
  : timezoneInput == SessionTimezone.berlin ? TZ_BERLIN
  : timezoneInput == SessionTimezone.tokyo ? TZ_TOKYO : TZ_UTC

[tf1Dir, tf1Top, tf1Bottom, tf1Start, tf1Stamp, tf1High, tf1Low, tf1Close] =
  htfFvgSnapshot(slot1TfInput, sessionTz, slot1IsDwm)
[tf2Dir, tf2Top, tf2Bottom, tf2Start, tf2Stamp, tf2High, tf2Low, tf2Close] =
  htfFvgSnapshot(slot2TfInput, sessionTz, slot2IsDwm)

// A slot reports a fresh closed bar exactly once, when its bar time changes.
// The na guard on the previous value keeps the very first reported bar from
// counting as a change against an empty history.
bool tf1Closed = slot1Usable and not na(tf1Stamp) and not na(tf1Stamp[1])
  and tf1Stamp != tf1Stamp[1]
bool tf2Closed = slot2Usable and not na(tf2Stamp) and not na(tf2Stamp[1])
  and tf2Stamp != tf2Stamp[1]

// --- Interaction values ---
bool useChartBars   = mitigationBasisInput == MitigationBasis.chartBar
bool useWickTouches = touchBasisInput == TouchBasis.wick
bool followRight    = extendModeInput == ExtendMode.toCurrent

float chartTouchHigh = useWickTouches ? high : close
float chartTouchLow  = useWickTouches ? low : close
float slot1TouchHigh = useWickTouches ? tf1High : tf1Close
float slot1TouchLow  = useWickTouches ? tf1Low : tf1Close
float slot2TouchHigh = useWickTouches ? tf2High : tf2Close
float slot2TouchLow  = useWickTouches ? tf2Low : tf2Close

bool warmedUp = bar_index >= MIN_BARS

// --- HTF-close bar tracking: lets a zone's left edge sit on xloc.bar_index
// without reconstructing it from calendar time. Three deep because a pattern
// spans three HTF candles; see recordHtfClose(). ---
var array<int> slot1CloseBars = array.new<int>(3, -1)
var array<int> slot2CloseBars = array.new<int>(3, -1)

// --- Zone store: one slot per zone, all arrays always mutated together ---
var array<int>   zoneSlotArr = array.new<int>()
var array<int>   zoneDirArr  = array.new<int>()
var array<float> zoneTop     = array.new<float>()
var array<float> zoneBottom  = array.new<float>()
var array<float> zoneCe      = array.new<float>()
var array<int>   zoneState   = array.new<int>()
var array<box>   zoneBox     = array.new<box>()
var array<line>  zoneCeLine  = array.new<line>()
var array<line>  zoneUpperQ  = array.new<line>()
var array<line>  zoneLowerQ  = array.new<line>()
var array<label> zoneLabel   = array.new<label>()

// --- Alert collection, reset on every bar ---
bool   newFvgFlag       = false
bool   entryFlag        = false
bool   ceFlag           = false
bool   mitigatedFlag    = false
string newFvgMessage    = TEXT_EMPTY
string entryMessage     = TEXT_EMPTY
string ceMessage        = TEXT_EMPTY
string mitigatedMessage = TEXT_EMPTY

int   newFvgCount = 0
int   newFvgSlot  = SLOT_ONE
int   newFvgDir   = DIR_NONE
int   entryIdx    = -1
int   ceIdx       = -1
int   mitigIdx    = -1
int   entryCount  = 0
int   ceCount     = 0
int   mitigCount  = 0
float entryDist   = 0.0
float ceDist      = 0.0
float mitigDist   = 0.0

// @function         Builds the dynamic alert text for one zone transition.
// @param eventText   (series string) One of the EVENT_* constants.
// @param slotId      (series int) SLOT_ONE or SLOT_TWO.
// @param dirVal      (series int) DIR_BULL or DIR_BEAR.
// @param extraCount  (series int) How many further zones made the same move.
// @returns           (series string) The full alert message.
// Dependencies       slot1Name, slot2Name
zoneAlertMessage(series string eventText, series int slotId, series int dirVal,
  series int extraCount) =>
    string tfName   = slotId == SLOT_ONE ? slot1Name : slot2Name
    string dirName  = dirVal == DIR_BULL ? DIR_NAME_BULL : DIR_NAME_BEAR
    string baseText = dirName + " FVG (" + tfName + ") " + eventText
    extraCount > 0 ? baseText + " (+" + str.tostring(extraCount) + " more)" : baseText

// @function        Builds a zone's label text from its slot and direction.
// @param slotId    (series int) SLOT_ONE or SLOT_TWO.
// @param dirVal    (series int) DIR_BULL or DIR_BEAR.
// @param startTime (series int) UNIX time (ms) of the pattern's first candle.
// @returns         (series string) The label text.
// Dependencies     slot1Name, slot2Name, sessionTz, labelContentInput
zoneLabelText(series int slotId, series int dirVal, series int startTime) =>
    string tfName   = slotId == SLOT_ONE ? slot1Name : slot2Name
    string dirName  = dirVal == DIR_BULL ? DIR_NAME_BULL : DIR_NAME_BEAR
    string headline = tfName + TEXT_SEPARATOR + dirName
    string dateStr  = str.format_time(startTime, DATE_FORMAT, sessionTz)
    switch labelContentInput
        LabelContent.timeframeOnly => tfName
        LabelContent.withDirection => headline
        =>                            headline + TEXT_SEPARATOR + dateStr

// @function        Deletes one zone's drawings and removes its slot from every
//                   parallel state array.
// @param idx       (series int) Array index of the zone to remove.
// @returns         (series bool) Always true; the function acts by side effect.
// Dependencies     zoneSlotArr..zoneLabel, showCeLineInput, showQuarterLinesInput,
// Dependencies     showLabelsInput
deleteZone(series int idx) =>
    box.delete(array.get(zoneBox, idx))
    if showCeLineInput
        line.delete(array.get(zoneCeLine, idx))
    if showQuarterLinesInput
        line.delete(array.get(zoneUpperQ, idx))
        line.delete(array.get(zoneLowerQ, idx))
    if showLabelsInput
        label.delete(array.get(zoneLabel, idx))
    array.remove(zoneSlotArr, idx)
    array.remove(zoneDirArr, idx)
    array.remove(zoneTop, idx)
    array.remove(zoneBottom, idx)
    array.remove(zoneCe, idx)
    array.remove(zoneState, idx)
    array.remove(zoneBox, idx)
    array.remove(zoneCeLine, idx)
    array.remove(zoneUpperQ, idx)
    array.remove(zoneLowerQ, idx)
    array.remove(zoneLabel, idx)
    true

// @function        Removes the oldest zone of a slot once its count exceeds the
//                   retention limit. One creation can only push the count a
//                   single step over the limit, so one removal is enough.
// @param slotId    (series int) SLOT_ONE or SLOT_TWO.
// @param limit     (series int) Maximum zones to keep for this slot.
// @returns         (series bool) Always true; the function acts by side effect.
// Dependencies     zoneSlotArr (insertion order equals chronological order)
enforceRetention(series int slotId, series int limit) =>
    int slotTotal      = 0
    int firstIdxOfSlot = -1
    int storedCount    = array.size(zoneSlotArr)
    if storedCount > 0
        for j = 0 to storedCount - 1
            if array.get(zoneSlotArr, j) == slotId
                slotTotal += 1
                if firstIdxOfSlot == -1
                    firstIdxOfSlot := j
    if slotTotal > limit and firstIdxOfSlot != -1
        deleteZone(firstIdxOfSlot)
    true

// @function        Restyles one zone's drawings to match its current state.
// @param idx       (series int) Array index of the zone to restyle.
// @returns         (series bool) Always true; the function acts by side effect.
// Dependencies     zoneSlotArr, zoneDirArr, zoneState, zoneBox, zoneCeLine,
// Dependencies     zoneUpperQ, zoneLowerQ, zoneLabel, zoneOpacityInput,
// Dependencies     mitigatedOpacityInput, ceLineWidthInput, showCeLineInput,
// Dependencies     showQuarterLinesInput, showLabelsInput
applyZoneStyle(series int idx) =>
    int   state     = array.get(zoneState, idx)
    color baseColor = zoneColor(array.get(zoneSlotArr, idx), array.get(zoneDirArr, idx))

    bool isMitigated  = state == STATE_MITIGATED
    bool isDashedEdge = state == STATE_TOUCHED or state == STATE_CE
    int  fadedTransp  = PERCENT_MAX - mitigatedOpacityInput
    int  fillTransp   = isMitigated ? fadedTransp : PERCENT_MAX - zoneOpacityInput

    color borderColor  = isMitigated ? color.new(baseColor, fadedTransp) : baseColor
    color quarterColor = color.new(baseColor, isMitigated ? fadedTransp : QUARTER_TRANSP)

    box boxId = array.get(zoneBox, idx)
    box.set_bgcolor(boxId, color.new(baseColor, fillTransp))
    box.set_border_color(boxId, borderColor)
    box.set_border_style(boxId, isDashedEdge ? line.style_dashed : line.style_solid)

    if showCeLineInput
        line ceLineId = array.get(zoneCeLine, idx)
        line.set_color(ceLineId, borderColor)
        line.set_width(ceLineId, state == STATE_CE ? ceLineWidthInput + 1 : ceLineWidthInput)
    if showQuarterLinesInput
        line.set_color(array.get(zoneUpperQ, idx), quarterColor)
        line.set_color(array.get(zoneLowerQ, idx), quarterColor)
    if showLabelsInput
        label.set_textcolor(array.get(zoneLabel, idx), borderColor)
    true

// @function        Stops one zone from growing further and pins its right edge
//                   to the bar that mitigated it. Used by every extend mode
//                   except Always: without it, a zone in To Current Bar mode
//                   would keep the last projected edge and so overshoot its own
//                   mitigation point by the whole offset.
// @param idx       (series int) Array index of the zone to freeze.
// @returns         (series bool) Always true; the function acts by side effect.
// Dependencies     zoneBox, zoneCeLine, zoneUpperQ, zoneLowerQ, showCeLineInput,
// Dependencies     showQuarterLinesInput
freezeZone(series int idx) =>
    box boxId = array.get(zoneBox, idx)
    box.set_extend(boxId, extend.none)
    box.set_right(boxId, bar_index)
    if showCeLineInput
        line ceLineId = array.get(zoneCeLine, idx)
        line.set_extend(ceLineId, extend.none)
        line.set_x2(ceLineId, bar_index)
    if showQuarterLinesInput
        line upperId = array.get(zoneUpperQ, idx)
        line lowerId = array.get(zoneLowerQ, idx)
        line.set_extend(upperId, extend.none)
        line.set_x2(upperId, bar_index)
        line.set_extend(lowerId, extend.none)
        line.set_x2(lowerId, bar_index)
    true

// @function          Creates one zone, stores its state and enforces the
//                     retention limit of its slot. Every drawing is anchored on
//                     xloc.bar_index, not calendar time, so an offset right edge
//                     always lands on an actual bar instead of inside a trading
//                     pause or across a weekend.
// @param slotId      (series int) SLOT_ONE or SLOT_TWO.
// @param dirVal      (series int) DIR_BULL or DIR_BEAR.
// @param topPrice    (series float) Upper edge of the gap.
// @param bottomPrice (series float) Lower edge of the gap.
// @param startBar    (series int) bar_index of the pattern's first candle.
// @param startTime   (series int) UNIX time (ms) of the pattern's first candle,
//                     used only to format the optional date in the label text.
// @returns           (series bool) Always true; the function acts by side effect.
// Dependencies       zoneSlotArr..zoneLabel, followRight, rightOffsetInput,
// Dependencies       zoneOpacityInput, borderWidthInput, showCeLineInput,
// Dependencies       showQuarterLinesInput, showLabelsInput, ceLineStyleInput,
// Dependencies       ceLineWidthInput, textSizeInput, zonesPerTfInput
createZone(series int slotId, series int dirVal, series float topPrice,
  series float bottomPrice, series int startBar, series int startTime) =>
    float ceLevel = (topPrice + bottomPrice) * CE_RATIO
    float span    = topPrice - bottomPrice
    float upperQ  = bottomPrice + span * QUARTER_UPPER
    float lowerQ  = bottomPrice + span * QUARTER_LOWER

    int    rightBar    = followRight ? bar_index + rightOffsetInput : bar_index
    string extendStyle = followRight ? extend.none : extend.right
    color  baseColor   = zoneColor(slotId, dirVal)

    box boxId = box.new(
      startBar, topPrice, rightBar, bottomPrice,
      xloc         = xloc.bar_index,
      border_color = baseColor,
      border_width = borderWidthInput,
      bgcolor      = color.new(baseColor, PERCENT_MAX - zoneOpacityInput),
      extend       = extendStyle)
    line ceLineId = showCeLineInput ? line.new(
      startBar, ceLevel, rightBar, ceLevel,
      xloc   = xloc.bar_index,
      extend = extendStyle,
      color  = baseColor,
      style  = lineStyleOf(ceLineStyleInput),
      width  = ceLineWidthInput) : na
    line upperQId = showQuarterLinesInput ? line.new(
      startBar, upperQ, rightBar, upperQ,
      xloc   = xloc.bar_index,
      extend = extendStyle,
      color  = color.new(baseColor, QUARTER_TRANSP),
      style  = line.style_dotted) : na
    line lowerQId = showQuarterLinesInput ? line.new(
      startBar, lowerQ, rightBar, lowerQ,
      xloc   = xloc.bar_index,
      extend = extendStyle,
      color  = color.new(baseColor, QUARTER_TRANSP),
      style  = line.style_dotted) : na
    // style_label_left anchors on the left and grows the text body to the
    // right, so the text sits right of rightBar instead of centred on it. A
    // fully transparent background leaves only the text visible.
    label labelId = showLabelsInput ? label.new(
      rightBar, ceLevel, zoneLabelText(slotId, dirVal, startTime),
      xloc      = xloc.bar_index,
      style     = label.style_label_left,
      color     = color.new(baseColor, PERCENT_MAX),
      textcolor = baseColor,
      size      = textSizeInput) : na

    array.push(zoneSlotArr, slotId)
    array.push(zoneDirArr, dirVal)
    array.push(zoneTop, topPrice)
    array.push(zoneBottom, bottomPrice)
    array.push(zoneCe, ceLevel)
    array.push(zoneState, STATE_OPEN)
    array.push(zoneBox, boxId)
    array.push(zoneCeLine, ceLineId)
    array.push(zoneUpperQ, upperQId)
    array.push(zoneLowerQ, lowerQId)
    array.push(zoneLabel, labelId)

    enforceRetention(slotId, zonesPerTfInput)
    true

// Everything below runs only on a confirmed bar, so no zone is ever created or
// advanced on a bar that can still change.
//
// The order inside the block is deliberate and load-bearing: existing zones are
// advanced FIRST, new zones are created afterwards. The third candle of a fresh
// pattern always touches the near edge of its own gap by definition, so a zone
// created before the lifecycle pass would be reported as touched in the same
// breath as it was formed.
if warmedUp and barstate.isconfirmed
    int zoneCount = array.size(zoneSlotArr)
    if zoneCount > 0
        for i = 0 to zoneCount - 1
            int  stateBefore = array.get(zoneState, i)
            int  slotId      = array.get(zoneSlotArr, i)
            bool slotClosed  = slotId == SLOT_ONE ? tf1Closed : tf2Closed
            bool evaluate    = stateBefore < STATE_MITIGATED and (useChartBars or slotClosed)
            if evaluate
                int   dirVal     = array.get(zoneDirArr, i)
                float zoneTopVal = array.get(zoneTop, i)
                float zoneBotVal = array.get(zoneBottom, i)
                float zoneCeVal  = array.get(zoneCe, i)
                float touchHigh  = useChartBars ? chartTouchHigh
                  : slotId == SLOT_ONE ? slot1TouchHigh : slot2TouchHigh
                float touchLow   = useChartBars ? chartTouchLow
                  : slotId == SLOT_ONE ? slot1TouchLow : slot2TouchLow

                // A bullish gap sits below the market and is entered from above,
                // a bearish gap sits above it and is entered from below. The
                // direction therefore decides which end of the bar measures how
                // deep price has reached into the zone.
                float reach = dirVal == DIR_BULL ? touchLow : touchHigh
                int   state = stateBefore

                // Cascading, non-exclusive: one large bar may carry a zone
                // through several stages within the same evaluation.
                if state == STATE_OPEN and touchLow <= zoneTopVal and touchHigh >= zoneBotVal
                    state := STATE_TOUCHED
                if state == STATE_TOUCHED
                    bool ceHit = dirVal == DIR_BULL ? reach <= zoneCeVal : reach >= zoneCeVal
                    if ceHit
                        state := STATE_CE
                if state == STATE_CE
                    bool doneHit = dirVal == DIR_BULL ? reach <= zoneBotVal : reach >= zoneTopVal
                    if doneHit
                        state := STATE_MITIGATED

                if state != stateBefore
                    array.set(zoneState, i, state)
                    applyZoneStyle(i)
                    if state == STATE_MITIGATED and extendModeInput != ExtendMode.always
                        freezeZone(i)

                    float distance = math.abs(close - zoneCeVal)

                    bool becameTouched   = state >= STATE_TOUCHED and stateBefore < STATE_TOUCHED
                    bool becameCe        = state >= STATE_CE and stateBefore < STATE_CE
                    bool becameMitigated = state == STATE_MITIGATED

                    if becameTouched and alertOnEntryInput
                        entryCount += 1
                        if entryIdx == -1 or distance < entryDist
                            entryIdx  := i
                            entryDist := distance
                    if becameCe and alertOnCeInput
                        ceCount += 1
                        if ceIdx == -1 or distance < ceDist
                            ceIdx  := i
                            ceDist := distance
                    if becameMitigated and alertOnMitigationInput
                        mitigCount += 1
                        if mitigIdx == -1 or distance < mitigDist
                            mitigIdx  := i
                            mitigDist := distance

    // Messages are built while the indices above are still valid: creating and
    // cleaning up below can both change them.
    if entryIdx != -1
        entryFlag    := true
        entryMessage := zoneAlertMessage(
          EVENT_ENTERED, array.get(zoneSlotArr, entryIdx), array.get(zoneDirArr, entryIdx),
          entryCount - 1)
    if ceIdx != -1
        ceFlag    := true
        ceMessage := zoneAlertMessage(
          EVENT_CE, array.get(zoneSlotArr, ceIdx), array.get(zoneDirArr, ceIdx), ceCount - 1)
    if mitigIdx != -1
        mitigatedFlag    := true
        mitigatedMessage := zoneAlertMessage(
          EVENT_MITIGATED, array.get(zoneSlotArr, mitigIdx), array.get(zoneDirArr, mitigIdx),
          mitigCount - 1)

    // --- New gaps ---
    // Recorded on EVERY close of a slot, gap or not: the rolling history has to
    // count every HTF bar to stay aligned, not only the ones that formed a gap.
    int slot1PatternStartBar = tf1Closed ? recordHtfClose(slot1CloseBars) : -1
    int slot2PatternStartBar = tf2Closed ? recordHtfClose(slot2CloseBars) : -1
    if tf1Closed and tf1Dir != DIR_NONE and not na(tf1Top) and slot1PatternStartBar >= 0
        createZone(SLOT_ONE, tf1Dir, tf1Top, tf1Bottom, slot1PatternStartBar, tf1Start)
        newFvgCount += 1
        newFvgSlot  := SLOT_ONE
        newFvgDir   := tf1Dir
    if tf2Closed and tf2Dir != DIR_NONE and not na(tf2Top) and slot2PatternStartBar >= 0
        createZone(SLOT_TWO, tf2Dir, tf2Top, tf2Bottom, slot2PatternStartBar, tf2Start)
        if newFvgCount == 0
            newFvgSlot := SLOT_TWO
            newFvgDir  := tf2Dir
        newFvgCount += 1
    if newFvgCount > 0 and alertOnNewInput
        newFvgFlag    := true
        newFvgMessage := zoneAlertMessage(EVENT_FORMED, newFvgSlot, newFvgDir, newFvgCount - 1)

    // Separate pass, running backwards: deleting inside the loop above would
    // shift the indices out from under its own counter.
    if hideMitigatedInput
        int cleanupCount = array.size(zoneSlotArr)
        if cleanupCount > 0
            for k = cleanupCount - 1 to 0
                if array.get(zoneState, k) == STATE_MITIGATED
                    deleteZone(k)

//#endregion

//#region VISUALS ==============================================================

var table noteTable = table.new(
  position.top_center, 1, 1,
  bgcolor = color.new(PANEL_COLOR, PANEL_TRANSP), border_width = 0)

// @function        Pulls the right edge of every unmitigated zone along with
//                   price, and keeps each label anchored to that same right
//                   edge. This runs on every bar, not only on confirmed ones:
//                   it moves drawings, never state, so it cannot make a signal
//                   repaint.
// @returns         (series bool) Always true; the function acts by side effect.
// Dependencies     zoneState, zoneBox, zoneCeLine, zoneUpperQ, zoneLowerQ,
// Dependencies     zoneLabel, followRight, rightOffsetInput,
// Dependencies     showCeLineInput, showQuarterLinesInput, showLabelsInput
refreshZoneGeometry() =>
    int zoneCount = array.size(zoneSlotArr)
    if zoneCount > 0
        int rightBar = bar_index + rightOffsetInput
        for i = 0 to zoneCount - 1
            if array.get(zoneState, i) < STATE_MITIGATED
                box boxId = array.get(zoneBox, i)
                if followRight
                    box.set_right(boxId, rightBar)
                    if showCeLineInput
                        line.set_x2(array.get(zoneCeLine, i), rightBar)
                    if showQuarterLinesInput
                        line.set_x2(array.get(zoneUpperQ, i), rightBar)
                        line.set_x2(array.get(zoneLowerQ, i), rightBar)
                if showLabelsInput
                    label.set_x(array.get(zoneLabel, i), box.get_right(boxId))
    true

refreshZoneGeometry()

if barstate.islast
    if slot1Blocked or slot2Blocked
        string blockedNames = slot1Blocked and slot2Blocked
          ? slot1Name + TEXT_COMMA + slot2Name
          : slot1Blocked ? slot1Name : slot2Name
        table.cell(
          noteTable, 0, 0, NOTE_PREFIX + blockedNames,
          text_color = NEUTRAL_COLOR, text_size = textSizeInput,
          text_halign = text.align_right)

//#endregion

//#region ALERTS ===============================================================

alertcondition(
  newFvgFlag, title = "New FVG formed",
  message = "A new higher-timeframe fair value gap was formed.")
alertcondition(
  entryFlag, title = "FVG entered",
  message = "Price entered a higher-timeframe fair value gap.")
alertcondition(
  ceFlag, title = "CE reached",
  message = "Price reached the CE line of a higher-timeframe fair value gap.")
alertcondition(
  mitigatedFlag, title = "FVG mitigated",
  message = "Price traded through a higher-timeframe fair value gap.")

if newFvgFlag
    alert(newFvgMessage, alert.freq_once_per_bar_close)
if entryFlag
    alert(entryMessage, alert.freq_once_per_bar_close)
if ceFlag
    alert(ceMessage, alert.freq_once_per_bar_close)
if mitigatedFlag
    alert(mitigatedMessage, alert.freq_once_per_bar_close)

//#endregion
````
