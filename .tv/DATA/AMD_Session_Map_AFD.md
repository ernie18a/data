<!-- tradingview-pine-id: PUB;c0b04b75422046c0be2eb073289de56e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# AMD Session Map [AFD]

Source: https://www.tradingview.com/script/pL2iPgPM-AMD-Session-Map-AFD/

## Description

[image]https://www.tradingview.com/x/87de1mbG/[/image]

Three measured boxes per session cycle — Accumulation, Manipulation, Distribution — drawn only where the rules qualify one, each on a confirmed bar. The same read runs on higher-timeframe bars as a thin coloured rule along the bottom of the pane.

The three phases 
Accumulation — the balance box. Adaptive RTH takes a contained window of about 40 minutes anywhere in the session, whole bars, four-bar minimum, no wider than the 30th percentile of the last 30. Opening 60 / 90 min instead take a fixed stretch from 09:30 New York, one cycle a day. 

Manipulation — the sweep box, from the swept boundary to the extreme reached. The panel names the boundary and the time. No sweep within 90 minutes of the balance completing: timeout. 

Distribution — the post-reclaim box, from the close back inside the balance to the end of the cycle. No reclaim within 30 minutes of the first sweep bar: timeout. Resolution — closed up, closed down, or named for what it did: unfinished at the close, both boundaries swept, closed back on the sweep side, deadline passed. Never rounded to a side.

The higher-timeframe ribbon  One thin rule per period along the bottom of the pane. Daily is on by default; Weekly, Monthly and Quarterly are switches. Each period's range comes from the first four completed bars of its container — Daily in the month, Weekly in the quarter, Monthly in the year, Quarterly in a four-year cycle. Unresolved periods are neutral grey. A rule holds no price coordinate, so the ribbon never moves the price scale. Show it as panel rows, as the ribbon, as both, or not at all. It never feeds the intraday detector. 

Higher-timeframe requests — the lookahead disclosure  Four requests, one per period, each for a completed-bar tuple. Every value is offset by one bar with the history-referencing operator inside the request expression, paired with barmerge.lookahead_on — the pairing the Pine Script documentation names as the way to return only confirmed values on all bars, whatever the bar state. Checked on Bar Replay: stepping through 25–26 August left the historical ribbon colors and the panel's higher-timeframe rows identical to the same bars outside replay. The consequence, by design: a higher-timeframe value is always one completed higher-timeframe bar behind. 

Scope  Standard chart type, 1 to 15 minutes, exchange timezone America/New_York. The timezone is the whole test — asset class is not checked. []Exchange-designated regular-session bars only, inside the nominal 09:30–16:00 window. Early closes follow the exchange's own last-regular-bar flag; pre/post-market bars are excluded even when extended hours are displayed. [*]Outside that scope the panel reports UNSUPPORTED and intraday fields stay empty rather than carry a value the model did not measure. 

[image]https://www.tradingview.com/x/6ABdvv3M/[/image]
Adaptive RTH

[image]https://www.tradingview.com/x/dhmyDROA/[/image]
Opening 60

[image]https://www.tradingview.com/x/YAZu3ZT6/[/image]
Opening 90 - Selective volatility

Settings  Accumulation model — Adaptive RTH, which can map repeat cycles in one day, or Opening 60 / 90 min, which map one. 

Confirmation profile — Structure + volatility context applies no size filter; ATR ratios are reported and change nothing. Selective volatility-confirmed adds two: the sweep must clear the boundary by 0.10x ATR, and the bar closing past the far boundary needs a body of at least 0.50x ATR and at least half its own range. Structure only keeps ATR out of every decision. 

Presentation — Map draws the boxes over your native candles; Phase candles also recolours the confirmed sweep and distribution bars; Full emphasis adds a background tint. 

Panel — the live phase, the balance range, the swept boundary and its time, the reclaim, and one row per enabled higher-timeframe period. Seven positions, or switched off; it still draws on an unsupported chart. 

Data Window — nineteen fields: five geometry levels, six Wilder ATR(14) measurements, and two accumulation levels per higher-timeframe period. 

Data and limitations  Rule-based chart geometry; AMD terms do not establish participant intent or future outcome. Phase names label what the rules measured — a contained range, trade beyond its boundary, a move after the reclaim — and nothing about who traded or why. Every decision is made on a confirmed bar. A cycle in progress is shown as in progress. A higher-timeframe value lags by one completed higher-timeframe bar, as described above. Six cycles are retained and older ones dropped — up to three boxes each, against the 60 this script declares. No alerts, signals, entries, exits, scores, rankings, projections, or performance claims. It does not tell anyone what to do with what it draws. 

Originality An Auction Foundry implementation of the Accumulation / Manipulation / Distribution framework. The adaptive balance admission, the sweep and reclaim deadlines, the volatility latching and the calendar read are all in the published source. Free to use, open-source under the Mozilla Public License 2.0.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry
//@version=6
indicator("AMD Session Map [AFD]", "AMD Session [AFD]", overlay = true, behind_chart = false, max_boxes_count = 60, max_lines_count = 60, max_labels_count = 60, max_bars_back = 300)

// ————— Constants
const string GROUP_SETUP = "Quick setup"
const string GROUP_CONTEXT = "History and HTF context"
const string GROUP_PANEL = "Status panel"
const string GROUP_COLORS = "Colors"

const string SESSION_TIMEZONE = "America/New_York"
const int MINUTE_MS = 60000
const int MIN_ACCUMULATION_BARS = 4
const int BASELINE_SAMPLES = 30
const int RANGE_PERCENTILE = 30
const int ATR_LENGTH = 14
const int MANIPULATION_DEADLINE_MINUTES = 90
const int RECLAIM_DEADLINE_MINUTES = 30
const float SELECTIVE_SWEEP_ATR = 0.10
const float SELECTIVE_BODY_ATR = 0.50
const float SELECTIVE_BODY_RANGE = 0.50
const int RANGE_FILL_TRANSPARENCY = 70
const int HISTORY_TRANSPARENCY = 25
const int PHASE_TINT_TRANSPARENCY = 85
const int PANEL_BACKGROUND_TRANSPARENCY = 5
const string RIBBON_GLYPH_RULE = "▔"
const int RIBBON_LABEL_OFFSET = 8
const int RIBBON_LABEL_GUTTER = 10
const int RIBBON_FILL_TRANSPARENCY = 30

const int CONTAINER_MONTH = 1
const int CONTAINER_QUARTER = 2
const int CONTAINER_YEAR = 3
const int CONTAINER_CYCLE_4Y = 4

const string MODE_ADAPTIVE = "Adaptive RTH"
const string MODE_OPENING_60 = "Opening 60 min"
const string MODE_OPENING_90 = "Opening 90 min"

const string PROFILE_CONTEXT = "Structure + volatility context"
const string PROFILE_SELECTIVE = "Selective volatility-confirmed"
const string PROFILE_STRUCTURE = "Structure only"

const string PRESENT_PHASE_CANDLES = "Phase candles"
const string PRESENT_MAP_ONLY = "Map only"
const string PRESENT_FULL = "Full emphasis"

const string CALENDAR_PANEL_RIBBON = "Panel + ribbon"
const string CALENDAR_PANEL_ONLY = "Panel only"
const string CALENDAR_RIBBON_ONLY = "Ribbon only"
const string CALENDAR_OFF = "Off"

const string CALENDAR_DAILY = "Daily"
const string CALENDAR_WEEKLY = "Weekly"
const string CALENDAR_MONTHLY = "Monthly"
const string CALENDAR_QUARTERLY = "Quarterly"

const string PANEL_TOP_RIGHT = "Top right"
const string PANEL_MIDDLE_LEFT = "Middle left"
const string PANEL_MIDDLE_CENTER = "Middle center"
const string PANEL_MIDDLE_RIGHT = "Middle right"
const string PANEL_BOTTOM_LEFT = "Bottom left"
const string PANEL_BOTTOM_CENTER = "Bottom center"
const string PANEL_BOTTOM_RIGHT = "Bottom right"

const int STATE_SCANNING = 0
const int STATE_BUILD_OPENING = 1
const int STATE_AWAIT_MANIPULATION = 2
const int STATE_MANIPULATION = 3
const int STATE_DISTRIBUTION = 4
const int STATE_WAIT_ESCAPE = 5
const int STATE_WAIT_SESSION = 6

const int SIDE_NONE = 0
const int SIDE_UPPER = 1
const int SIDE_LOWER = -1

const int RESULT_NONE = 0
const int RESULT_UPWARD = 1
const int RESULT_DOWNWARD = 2
const int RESULT_INCOMPLETE = 3
const int RESULT_AMBIGUOUS = 4
const int RESULT_INVALIDATED = 5
const int RESULT_M_TIMEOUT = 6
const int RESULT_RECLAIM_TIMEOUT = 7
const int RESULT_INSUFFICIENT = 8

const color ACCUMULATION_COLOR = color.rgb(59, 130, 246)
const color MANIPULATION_COLOR = color.rgb(245, 158, 11)
const color DISTRIBUTION_COLOR = color.rgb(139, 92, 246)
const color UPWARD_COLOR = color.rgb(16, 185, 129)
const color DOWNWARD_COLOR = color.rgb(244, 63, 94)
const color NEUTRAL_COLOR = color.rgb(100, 116, 139)

const string TT_MODEL = "• Sets which price range counts as the balance — every sweep and reclaim is measured against it\n• Adaptive RTH — the first tight stretch of the session, wherever it falls, and another later if the first one finishes\n• Tight means: about 40 minutes long, rounded to whole chart bars; the later bars stay inside the high and low of the earlier ones; and the whole stretch is no wider than the 30th percentile of the last 30 windows\n• Opening 60 / 90 min — simply the high and low of the first hour, or hour and a half, from 09:30 New York; one cycle a day"
const string TT_PROFILE = "• Sets whether the size of a bar matters, or only where price went\n• Structure + volatility context — no size filter: where price went and the sweep/reclaim deadlines decide every phase; the ATR ratios are reported in the Data Window and change nothing\n• Selective volatility-confirmed — the same rules with two size filters added: the sweep must clear the range boundary by 0.10× ATR, and the bar closing past the far boundary needs a body of at least 0.50× ATR that is at least half that bar's own range\n• Structure only — ATR takes no part in any decision, and the six volatility fields are left blank"
const string TT_PRESENTATION = "• Sets how much of your chart's own look the indicator changes\n• Map only — the three boxes over your own candles, nothing recoloured\n• Phase candles — the boxes, plus the confirmed sweep and distribution bars in their phase colours\n• Full emphasis — the same, with a background tint behind those bars\n• Accumulation bars are never recoloured: the range is only known once its bars have closed"
const string TT_HISTORY = "• How many finished cycles stay drawn behind the live one\n• 0 keeps only the cycle in progress\n• Each finished cycle keeps up to three boxes, out of the 60 this script declares"
const string TT_CALENDAR = "• A second A/M/D read taken on Daily, Weekly, Monthly or Quarterly bars\n• Panel + ribbon — one panel row and one coloured rule per enabled period\n• Panel only / Ribbon only — one of the two; Off hides both\n• The ribbon sits at the bottom of the pane and holds no price coordinate, so it never moves the price scale\n• The HTF read never feeds the intraday detector"
const string TT_CALENDAR_DAILY = "• The first four completed daily bars of each calendar month set the range; the rest of the month measures against it\n• Only completed bars are read, so the read is one bar behind\n• Top rule of the ribbon"
const string TT_CALENDAR_WEEKLY = "• The first four completed weekly bars of each quarter set the range; the rest of the quarter measures against it\n• Only completed bars are read, so the read is one bar behind\n• Second rule from the top"
const string TT_CALENDAR_MONTHLY = "• The first four completed monthly bars of each year set the range; the remaining eight months measure against it\n• Only completed bars are read, so the read is one bar behind\n• Third rule from the top"
const string TT_CALENDAR_QUARTERLY = "• The first four completed quarterly bars of each four-year cycle set the range; the remaining twelve quarters measure against it\n• Only completed bars are read, so the read is one bar behind\n• Bottom rule of the ribbon"
const string TT_SHOW_PANEL = "• Turns the status panel off, leaving the boxes, the ribbon and the Data Window untouched\n• The panel still draws on an unsupported chart, where it is the only surface that names the failed condition"
const string TT_PANEL = "• Where the status panel sits on the chart\n• Top-left and top-centre are omitted so the panel never covers the chart header"
const string TT_COLOR_A = "• The accumulation box, and its panel row — brighter while accumulation is the live phase"
const string TT_COLOR_M = "• The sweep box, and its panel row — brighter while manipulation is the live phase\n• Every bar from the sweep to the reclaim carries it, including one that closes back inside the range"
const string TT_COLOR_D = "• The post-reclaim box and bars, until the cycle ends\n• A cycle ending upward or downward switches to those two colours; one ending on both boundaries, on the sweep side, or unfinished at the close keeps this one"
const string TT_COLOR_UP = "• The box and bars of a cycle that closed above the range after a downside sweep"
const string TT_COLOR_DOWN = "• The box and bars of a cycle that closed below the range after an upside sweep"

// ————— Inputs - fifteen settings; the three presets own model and presentation complexity
string accumulationModeInput = input.string(MODE_ADAPTIVE, "Accumulation model", options = [MODE_ADAPTIVE, MODE_OPENING_60, MODE_OPENING_90], group = GROUP_SETUP, tooltip = TT_MODEL, display = display.none)
string confirmationProfileInput = input.string(PROFILE_CONTEXT, "Confirmation profile", options = [PROFILE_CONTEXT, PROFILE_SELECTIVE, PROFILE_STRUCTURE], group = GROUP_SETUP, tooltip = TT_PROFILE, display = display.none)
string presentationInput = input.string(PRESENT_PHASE_CANDLES, "Presentation", options = [PRESENT_PHASE_CANDLES, PRESENT_MAP_ONLY, PRESENT_FULL], group = GROUP_SETUP, tooltip = TT_PRESENTATION, display = display.none)

int historyCountInput = input.int(6, "Retained cycles", minval = 0, maxval = 15, group = GROUP_CONTEXT, tooltip = TT_HISTORY, display = display.none)
string calendarDisplayInput = input.string(CALENDAR_PANEL_RIBBON, "HTF context", options = [CALENDAR_PANEL_RIBBON, CALENDAR_PANEL_ONLY, CALENDAR_RIBBON_ONLY, CALENDAR_OFF], group = GROUP_CONTEXT, tooltip = TT_CALENDAR, display = display.none)
bool calendarDailyInput = input.bool(true, "HTF · Daily", group = GROUP_CONTEXT, active = calendarDisplayInput != CALENDAR_OFF, tooltip = TT_CALENDAR_DAILY, display = display.none)
bool calendarWeeklyInput = input.bool(false, "HTF · Weekly", group = GROUP_CONTEXT, active = calendarDisplayInput != CALENDAR_OFF, tooltip = TT_CALENDAR_WEEKLY, display = display.none)
bool calendarMonthlyInput = input.bool(false, "HTF · Monthly", group = GROUP_CONTEXT, active = calendarDisplayInput != CALENDAR_OFF, tooltip = TT_CALENDAR_MONTHLY, display = display.none)
bool calendarQuarterlyInput = input.bool(false, "HTF · Quarterly", group = GROUP_CONTEXT, active = calendarDisplayInput != CALENDAR_OFF, tooltip = TT_CALENDAR_QUARTERLY, display = display.none)

bool showPanelInput = input.bool(true, "Show status panel", group = GROUP_PANEL, tooltip = TT_SHOW_PANEL, display = display.none)
string panelPositionInput = input.string(PANEL_TOP_RIGHT, "Panel position", options = [PANEL_TOP_RIGHT, PANEL_MIDDLE_LEFT, PANEL_MIDDLE_CENTER, PANEL_MIDDLE_RIGHT, PANEL_BOTTOM_LEFT, PANEL_BOTTOM_CENTER, PANEL_BOTTOM_RIGHT], group = GROUP_PANEL, active = showPanelInput, tooltip = TT_PANEL, display = display.none)

color accumulationColorInput = input.color(ACCUMULATION_COLOR, "Accumulation", group = GROUP_COLORS, tooltip = TT_COLOR_A, display = display.none)
color manipulationColorInput = input.color(MANIPULATION_COLOR, "Manipulation", group = GROUP_COLORS, tooltip = TT_COLOR_M, display = display.none)
color distributionColorInput = input.color(DISTRIBUTION_COLOR, "Distribution", group = GROUP_COLORS, tooltip = TT_COLOR_D, display = display.none)
color upwardColorInput = input.color(UPWARD_COLOR, "Upward", group = GROUP_COLORS, tooltip = TT_COLOR_UP, display = display.none)
color downwardColorInput = input.color(DOWNWARD_COLOR, "Downward", group = GROUP_COLORS, tooltip = TT_COLOR_DOWN, display = display.none)

// ————— Preset resolution and function declarations
int chartMinutes = timeframe.isminutes ? timeframe.multiplier : 1
int chartSeconds = chartMinutes * 60
bool adaptiveMode = accumulationModeInput == MODE_ADAPTIVE
bool selectiveProfile = confirmationProfileInput == PROFILE_SELECTIVE
bool volatilityEnabled = confirmationProfileInput != PROFILE_STRUCTURE
bool showPhaseCandles = presentationInput != PRESENT_MAP_ONLY
bool showPhaseBackground = presentationInput == PRESENT_FULL
bool showCalendarPanel = calendarDisplayInput == CALENDAR_PANEL_RIBBON or calendarDisplayInput == CALENDAR_PANEL_ONLY
bool showCalendarRibbon = calendarDisplayInput == CALENDAR_PANEL_RIBBON or calendarDisplayInput == CALENDAR_RIBBON_ONLY
bool showCalendarData = calendarDisplayInput != CALENDAR_OFF
int calendarPeriodsEnabled = (calendarDailyInput ? 1 : 0) + (calendarWeeklyInput ? 1 : 0) + (calendarMonthlyInput ? 1 : 0) + (calendarQuarterlyInput ? 1 : 0)

int effectiveCandidateBars = math.max(MIN_ACCUMULATION_BARS, int(math.ceil(40.0 * 60.0 / chartSeconds)))
int effectiveContainmentBars = math.min(effectiveCandidateBars - 1, math.max(1, int(math.ceil(15.0 * 60.0 / chartSeconds))))
int effectiveSeedBars = effectiveCandidateBars - effectiveContainmentBars

formatPrice(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

formatClock(int stamp) =>
    na(stamp) ? "n/a" : str.format_time(stamp, "HH:mm", SESSION_TIMEZONE)

configuredPanelPosition(string selection) =>
    switch selection
        PANEL_TOP_RIGHT => position.top_right
        PANEL_MIDDLE_LEFT => position.middle_left
        PANEL_MIDDLE_CENTER => position.middle_center
        PANEL_MIDDLE_RIGHT => position.middle_right
        PANEL_BOTTOM_LEFT => position.bottom_left
        PANEL_BOTTOM_CENTER => position.bottom_center
        => position.bottom_right

nearestRankPercentile(array<float> values, int percentile) =>
    array<float> ordered = array.copy(values)
    array.sort(ordered, order.ascending)
    int rank = math.max(1, int(math.ceil(array.size(ordered) * percentile / 100.0)))
    array.get(ordered, rank - 1)

panelCell(table panel, int column, int row, string cellText, color textColor, color backgroundColor) =>
    table.cell(panel, column, row, cellText, text_color = textColor, text_size = size.small, text_halign = text.align_left, text_formatting = row == 0 or column == 0 ? text.format_bold : text.format_none, bgcolor = backgroundColor)

resultText(int currentResult) =>
    switch currentResult
        RESULT_UPWARD => "Closed upward"
        RESULT_DOWNWARD => "Closed downward"
        RESULT_AMBIGUOUS => "Both range boundaries swept"
        RESULT_INVALIDATED => "Closed back on the sweep side"
        RESULT_M_TIMEOUT => "No qualifying sweep in 90 min"
        RESULT_RECLAIM_TIMEOUT => "No reclaim in 30 min"
        RESULT_INCOMPLETE => "Unfinished at close"
        RESULT_INSUFFICIENT => "No usable opening range"
        => "No completed cycle"

resultColor(int currentResult) =>
    switch currentResult
        RESULT_UPWARD => upwardColorInput
        RESULT_DOWNWARD => downwardColorInput
        RESULT_AMBIGUOUS => NEUTRAL_COLOR
        RESULT_INVALIDATED => NEUTRAL_COLOR
        => chart.fg_color

// ————— Calculations - supported chart and RTH containment
bool supportedChart = chart.is_standard and timeframe.isminutes and chartMinutes >= 1 and chartMinutes <= 15 and syminfo.timezone == SESSION_TIMEZONE
bool panelVisible = showPanelInput or not supportedChart
int rthStartStamp = timestamp(SESSION_TIMEZONE, year, month, dayofmonth, 9, 30)
int rthEndStamp = timestamp(SESSION_TIMEZONE, year, month, dayofmonth, 16, 0)
bool isRthBar = supportedChart and session.ismarket and time >= rthStartStamp and time_close <= rthEndStamp
bool isLastRthBar = isRthBar and session.islastbar_regular
int calendarDayId = year * 10000 + month * 100 + dayofmonth

float candidateHighSeries = ta.highest(high, effectiveCandidateBars)
float candidateLowSeries = ta.lowest(low, effectiveCandidateBars)
float candidateRangeSeries = candidateHighSeries - candidateLowSeries
float seedHighSeries = ta.highest(high, effectiveSeedBars)
float seedLowSeries = ta.lowest(low, effectiveSeedBars)
float containmentHighSeries = ta.highest(high, effectiveContainmentBars)
float containmentLowSeries = ta.lowest(low, effectiveContainmentBars)

// ————— Persistent intraday model, RTH ATR, baseline, and drawings
var int activeSessionDay = na
var int sessionBarCount = 0
var int adaptiveSegmentBarCount = 0
var int candidateStartFloor = 1

var float previousRthClose = na
var float rthAtr = na
var float atrSeedSum = 0.0
var int atrSampleCount = 0

var array<float> rangeBaseline = array.new<float>()
var array<float> pendingSessionRanges = array.new<float>()

var int modelState = STATE_SCANNING
var int modelResult = RESULT_NONE
var string reasonCode = "A_BASELINE_WARMUP"
var bool cycleLive = false

var float openingHigh = na
var float openingLow = na
var int openingBarCount = 0
var int openingStartTime = na
var int openingLastEndTime = na

var float accumulationHigh = na
var float accumulationLow = na
var int accumulationStartTime = na
var int accumulationEndTime = na
var int armTime = na
var float accumulationAtr = na

var int manipulationStartTime = na
var int manipulationSide = SIDE_NONE
var float manipulationExtreme = na
var float manipulationAtr = na
var int reclaimTime = na
var int reclaimEndTime = na
var float distributionAtr = na
var bool distributionStarted = false
var bool distributionConfirmed = false
var float distributionTop = na
var float distributionBottom = na

var float previousCycleHigh = na
var float previousCycleLow = na

var box activeAccumulationBox = na
var box activeManipulationBox = na
var box activeDistributionBox = na
var array<box> historyAccumulationBoxes = array.new<box>()
var array<box> historyManipulationBoxes = array.new<box>()
var array<box> historyDistributionBoxes = array.new<box>()

float priorAtrForBar = rthAtr
float currentTrueRange = na
float currentBodyAtrRatio = na
float currentBodyRangeRatio = na
color phaseColorForBar = na

// ————— Confirmed-bar intraday state machine
if barstate.isconfirmed
    bool newSession = isRthBar and (session.isfirstbar_regular or na(activeSessionDay) or calendarDayId != activeSessionDay)
    bool leftSession = not isRthBar and isRthBar[1]
    bool internalRthGap = isRthBar and adaptiveMode and not newSession and sessionBarCount > 0 and (not isRthBar[1] or time != time_close[1])
    bool freezeRequested = false
    int freezeResult = RESULT_NONE
    bool armedThisBar = false

    if newSession
        while array.size(pendingSessionRanges) > 0
            float tailRange = array.shift(pendingSessionRanges)
            array.push(rangeBaseline, tailRange)
            while array.size(rangeBaseline) > BASELINE_SAMPLES
                array.shift(rangeBaseline)
        if cycleLive
            modelResult := RESULT_INCOMPLETE
            reasonCode := "SESSION_CLOSE"
            cycleLive := false
            if not na(activeAccumulationBox)
                box.set_border_color(activeAccumulationBox, color.new(accumulationColorInput, HISTORY_TRANSPARENCY))
                box.set_bgcolor(activeAccumulationBox, color.new(accumulationColorInput, math.min(100, RANGE_FILL_TRANSPARENCY + 5)))
            if not na(activeManipulationBox)
                box.set_border_color(activeManipulationBox, color.new(manipulationColorInput, HISTORY_TRANSPARENCY))
                box.set_bgcolor(activeManipulationBox, color.new(manipulationColorInput, math.min(100, RANGE_FILL_TRANSPARENCY + 5)))
            if not na(activeDistributionBox)
                box.set_border_color(activeDistributionBox, color.new(distributionColorInput, HISTORY_TRANSPARENCY))
                box.set_bgcolor(activeDistributionBox, color.new(distributionColorInput, math.min(100, RANGE_FILL_TRANSPARENCY + 5)))
            array.push(historyAccumulationBoxes, activeAccumulationBox)
            array.push(historyManipulationBoxes, activeManipulationBox)
            array.push(historyDistributionBoxes, activeDistributionBox)
            activeAccumulationBox := na
            activeManipulationBox := na
            activeDistributionBox := na
            while array.size(historyAccumulationBoxes) > historyCountInput
                box oldA = array.shift(historyAccumulationBoxes)
                box oldM = array.shift(historyManipulationBoxes)
                box oldD = array.shift(historyDistributionBoxes)
                if not na(oldA)
                    box.delete(oldA)
                if not na(oldM)
                    box.delete(oldM)
                if not na(oldD)
                    box.delete(oldD)

        activeSessionDay := calendarDayId
        sessionBarCount := 0
        adaptiveSegmentBarCount := 0
        candidateStartFloor := 1
        modelState := adaptiveMode ? STATE_SCANNING : STATE_BUILD_OPENING
        modelResult := RESULT_NONE
        reasonCode := adaptiveMode and array.size(rangeBaseline) < BASELINE_SAMPLES ? "A_BASELINE_WARMUP" : "A_SCANNING"
        cycleLive := false
        openingHigh := na
        openingLow := na
        openingBarCount := 0
        openingStartTime := na
        openingLastEndTime := na
        accumulationHigh := na
        accumulationLow := na
        accumulationStartTime := na
        accumulationEndTime := na
        armTime := na
        accumulationAtr := na
        manipulationStartTime := na
        manipulationSide := SIDE_NONE
        manipulationExtreme := na
        manipulationAtr := na
        reclaimTime := na
        reclaimEndTime := na
        distributionAtr := na
        distributionStarted := false
        distributionConfirmed := false
        distributionTop := na
        distributionBottom := na
        previousCycleHigh := na
        previousCycleLow := na

    if internalRthGap
        while array.size(pendingSessionRanges) > 0
            float preGapRange = array.shift(pendingSessionRanges)
            array.push(rangeBaseline, preGapRange)
            while array.size(rangeBaseline) > BASELINE_SAMPLES
                array.shift(rangeBaseline)
        adaptiveSegmentBarCount := 0
        candidateStartFloor := 1

    priorAtrForBar := rthAtr
    if isRthBar
        sessionBarCount += 1
        if adaptiveMode
            adaptiveSegmentBarCount += 1
        float barRange = high - low
        currentTrueRange := na(previousRthClose) ? barRange : math.max(barRange, math.max(math.abs(high - previousRthClose), math.abs(low - previousRthClose)))
        if atrSampleCount < ATR_LENGTH
            atrSeedSum += currentTrueRange
            atrSampleCount += 1
            if atrSampleCount == ATR_LENGTH
                rthAtr := atrSeedSum / ATR_LENGTH
        else
            rthAtr := (rthAtr * (ATR_LENGTH - 1) + currentTrueRange) / ATR_LENGTH
        previousRthClose := close
        float applicableBodyAtr = modelState == STATE_DISTRIBUTION and not na(distributionAtr) ? distributionAtr : priorAtrForBar
        currentBodyAtrRatio := not na(applicableBodyAtr) and applicableBodyAtr > 0 ? math.abs(close - open) / applicableBodyAtr : na
        currentBodyRangeRatio := barRange > 0 ? math.abs(close - open) / barRange : na

    if isRthBar and adaptiveMode and adaptiveSegmentBarCount >= effectiveCandidateBars
        array.push(pendingSessionRanges, candidateRangeSeries)
        while array.size(pendingSessionRanges) > effectiveCandidateBars
            float eligibleRange = array.shift(pendingSessionRanges)
            array.push(rangeBaseline, eligibleRange)
            while array.size(rangeBaseline) > BASELINE_SAMPLES
                array.shift(rangeBaseline)

    int openingEndHour = accumulationModeInput == MODE_OPENING_60 ? 10 : 11
    int openingEndMinute = accumulationModeInput == MODE_OPENING_60 ? 30 : 0
    int openingWindowStart = timestamp(SESSION_TIMEZONE, year, month, dayofmonth, 9, 30)
    int openingWindowEnd = timestamp(SESSION_TIMEZONE, year, month, dayofmonth, openingEndHour, openingEndMinute)
    bool openingWindowBar = isRthBar and not adaptiveMode and time >= openingWindowStart and time_close <= openingWindowEnd
    if modelState == STATE_BUILD_OPENING and openingWindowBar
        openingHigh := na(openingHigh) ? high : math.max(openingHigh, high)
        openingLow := na(openingLow) ? low : math.min(openingLow, low)
        openingBarCount += 1
        openingStartTime := na(openingStartTime) ? time : openingStartTime
        openingLastEndTime := time_close

    if modelState == STATE_BUILD_OPENING and isRthBar and time_close >= openingWindowEnd
        if openingBarCount >= MIN_ACCUMULATION_BARS and not na(openingHigh) and not na(openingLow) and openingHigh > openingLow
            accumulationHigh := openingHigh
            accumulationLow := openingLow
            accumulationStartTime := openingStartTime
            accumulationEndTime := openingLastEndTime
            armTime := openingWindowEnd
            accumulationAtr := priorAtrForBar
            cycleLive := true
            modelState := STATE_AWAIT_MANIPULATION
            reasonCode := "A_SET"
            armedThisBar := true
            activeAccumulationBox := box.new(left = accumulationStartTime, top = accumulationHigh, right = accumulationEndTime, bottom = accumulationLow, xloc = xloc.bar_time, border_color = accumulationColorInput, border_width = 1, border_style = line.style_dotted, bgcolor = color.new(accumulationColorInput, RANGE_FILL_TRANSPARENCY))
        else
            modelResult := RESULT_INSUFFICIENT
            reasonCode := "A_INSUFFICIENT"
            modelState := STATE_WAIT_SESSION

    if isRthBar and adaptiveMode and modelState == STATE_SCANNING and not isLastRthBar
        int candidateWindowStart = adaptiveSegmentBarCount - effectiveCandidateBars + 1
        bool enoughSessionBars = adaptiveSegmentBarCount >= effectiveCandidateBars and candidateWindowStart >= candidateStartFloor
        bool baselineReady = array.size(rangeBaseline) >= BASELINE_SAMPLES
        if not baselineReady
            reasonCode := "A_BASELINE_WARMUP"
        else if enoughSessionBars
            float seedHigh = seedHighSeries[effectiveContainmentBars]
            float seedLow = seedLowSeries[effectiveContainmentBars]
            bool contained = containmentHighSeries <= seedHigh and containmentLowSeries >= seedLow
            float rangeCutoff = nearestRankPercentile(rangeBaseline, RANGE_PERCENTILE)
            bool rangeEligible = candidateRangeSeries <= rangeCutoff
            if contained and rangeEligible and seedHigh > seedLow
                accumulationHigh := seedHigh
                accumulationLow := seedLow
                accumulationStartTime := time[effectiveCandidateBars - 1]
                accumulationEndTime := time_close
                armTime := time_close
                accumulationAtr := priorAtrForBar
                cycleLive := true
                modelState := STATE_AWAIT_MANIPULATION
                reasonCode := "A_SET"
                armedThisBar := true
                activeAccumulationBox := box.new(left = accumulationStartTime, top = accumulationHigh, right = accumulationEndTime, bottom = accumulationLow, xloc = xloc.bar_time, border_color = accumulationColorInput, border_width = 1, border_style = line.style_dotted, bgcolor = color.new(accumulationColorInput, RANGE_FILL_TRANSPARENCY))
            else
                reasonCode := "A_SCANNING"

    if isRthBar and adaptiveMode and modelState == STATE_WAIT_ESCAPE and not na(previousCycleHigh) and not na(previousCycleLow)
        if close > previousCycleHigh or close < previousCycleLow
            modelState := STATE_SCANNING
            modelResult := RESULT_NONE
            reasonCode := "A_SCANNING"
            candidateStartFloor := adaptiveSegmentBarCount + 1
            accumulationHigh := na
            accumulationLow := na
            accumulationStartTime := na
            accumulationEndTime := na
            armTime := na
            accumulationAtr := na
            manipulationStartTime := na
            manipulationSide := SIDE_NONE
            manipulationExtreme := na
            manipulationAtr := na
            reclaimTime := na
            reclaimEndTime := na
            distributionAtr := na
            distributionStarted := false
            distributionConfirmed := false
            distributionTop := na
            distributionBottom := na

    if isRthBar and cycleLive and modelState == STATE_AWAIT_MANIPULATION and not armedThisBar
        if reasonCode == "A_SET"
            reasonCode := "M_WAIT"
        int manipulationDeadline = armTime + MANIPULATION_DEADLINE_MINUTES * MINUTE_MS
        bool withinManipulationWindow = time <= manipulationDeadline
        bool upperBreach = high > accumulationHigh
        bool lowerBreach = low < accumulationLow
        if withinManipulationWindow and upperBreach and lowerBreach
            freezeRequested := true
            freezeResult := RESULT_AMBIGUOUS
            reasonCode := "AMBIGUOUS"
            phaseColorForBar := manipulationColorInput
        else if withinManipulationWindow and (upperBreach or lowerBreach)
            int candidateSide = upperBreach ? SIDE_UPPER : SIDE_LOWER
            float candidateDepth = candidateSide == SIDE_UPPER ? high - accumulationHigh : accumulationLow - low
            float candidateDepthAtr = not na(priorAtrForBar) and priorAtrForBar > 0 ? candidateDepth / priorAtrForBar : na
            bool selectiveAtrReady = not na(candidateDepthAtr)
            bool qualifyingSweep = not selectiveProfile or (selectiveAtrReady and candidateDepthAtr >= SELECTIVE_SWEEP_ATR)
            if qualifyingSweep
                manipulationStartTime := time
                manipulationSide := candidateSide
                manipulationExtreme := candidateSide == SIDE_UPPER ? high : low
                manipulationAtr := priorAtrForBar
                modelState := STATE_MANIPULATION
                reasonCode := "M_OPEN"
                phaseColorForBar := manipulationColorInput
                float mTop = candidateSide == SIDE_UPPER ? manipulationExtreme : accumulationLow
                float mBottom = candidateSide == SIDE_UPPER ? accumulationHigh : manipulationExtreme
                activeManipulationBox := box.new(left = manipulationStartTime, top = mTop, right = time_close, bottom = mBottom, xloc = xloc.bar_time, border_color = manipulationColorInput, border_width = 1, border_style = line.style_dotted, bgcolor = color.new(manipulationColorInput, math.max(70, RANGE_FILL_TRANSPARENCY - 8)))
                bool reclaimedOnSweep = close >= accumulationLow and close <= accumulationHigh
                if reclaimedOnSweep
                    reclaimTime := time
                    reclaimEndTime := time_close
                    distributionAtr := priorAtrForBar
                    distributionTop := close
                    distributionBottom := close
                    modelState := STATE_DISTRIBUTION
                    reasonCode := "D_OPEN"
            else if selectiveAtrReady
                reasonCode := "M_SUBTHRESHOLD"
            else
                reasonCode := "M_WAIT"
        if modelState == STATE_AWAIT_MANIPULATION and time >= manipulationDeadline and not freezeRequested
            freezeRequested := true
            freezeResult := RESULT_M_TIMEOUT
            reasonCode := "M_TIMEOUT"

    if isRthBar and cycleLive and modelState == STATE_MANIPULATION and time > manipulationStartTime
        int reclaimDeadline = manipulationStartTime + RECLAIM_DEADLINE_MINUTES * MINUTE_MS
        bool withinReclaimWindow = time <= reclaimDeadline
        if withinReclaimWindow
            phaseColorForBar := manipulationColorInput
            if manipulationSide == SIDE_UPPER
                manipulationExtreme := math.max(manipulationExtreme, high)
            else
                manipulationExtreme := math.min(manipulationExtreme, low)
            if not na(activeManipulationBox)
                box.set_right(activeManipulationBox, time_close)
                box.set_top(activeManipulationBox, manipulationSide == SIDE_UPPER ? manipulationExtreme : accumulationLow)
                box.set_bottom(activeManipulationBox, manipulationSide == SIDE_UPPER ? accumulationHigh : manipulationExtreme)
            bool oppositeBoundaryBreach = manipulationSide == SIDE_UPPER ? low < accumulationLow : high > accumulationHigh
            bool reclaimed = close >= accumulationLow and close <= accumulationHigh
            if oppositeBoundaryBreach
                freezeRequested := true
                freezeResult := RESULT_AMBIGUOUS
                reasonCode := "AMBIGUOUS"
            else if reclaimed
                reclaimTime := time
                reclaimEndTime := time_close
                distributionAtr := priorAtrForBar
                distributionTop := close
                distributionBottom := close
                modelState := STATE_DISTRIBUTION
                reasonCode := "D_OPEN"
        if modelState == STATE_MANIPULATION and time >= reclaimDeadline and not freezeRequested
            freezeRequested := true
            freezeResult := RESULT_RECLAIM_TIMEOUT
            reasonCode := "RECLAIM_TIMEOUT"

    if isRthBar and cycleLive and modelState == STATE_DISTRIBUTION and time > reclaimTime
        distributionStarted := true
        distributionTop := na(distributionTop) ? high : math.max(distributionTop, high)
        distributionBottom := na(distributionBottom) ? low : math.min(distributionBottom, low)
        phaseColorForBar := distributionColorInput
        if na(activeDistributionBox)
            activeDistributionBox := box.new(left = reclaimEndTime, top = distributionTop, right = time_close, bottom = distributionBottom, xloc = xloc.bar_time, border_color = distributionColorInput, border_width = 1, border_style = line.style_dotted, bgcolor = color.new(distributionColorInput, RANGE_FILL_TRANSPARENCY))
        else
            box.set_right(activeDistributionBox, time_close)
            box.set_top(activeDistributionBox, distributionTop)
            box.set_bottom(activeDistributionBox, distributionBottom)
        bool bothBoundariesReached = high > accumulationHigh and low < accumulationLow
        bool oppositeClose = manipulationSide == SIDE_UPPER ? close < accumulationLow : close > accumulationHigh
        bool sameSideClose = manipulationSide == SIDE_UPPER ? close > accumulationHigh : close < accumulationLow
        bool directionalBody = manipulationSide == SIDE_UPPER ? close < open : close > open
        float confirmingBodyAtr = not na(distributionAtr) and distributionAtr > 0 ? math.abs(close - open) / distributionAtr : na
        float bodyRange = high > low ? math.abs(close - open) / (high - low) : na
        bool selectiveDistributionPass = directionalBody and not na(confirmingBodyAtr) and confirmingBodyAtr >= SELECTIVE_BODY_ATR and not na(bodyRange) and bodyRange >= SELECTIVE_BODY_RANGE
        if bothBoundariesReached
            freezeRequested := true
            freezeResult := RESULT_AMBIGUOUS
            reasonCode := "AMBIGUOUS"
        else if oppositeClose
            if not selectiveProfile or selectiveDistributionPass
                distributionConfirmed := true
                freezeRequested := true
                freezeResult := manipulationSide == SIDE_UPPER ? RESULT_DOWNWARD : RESULT_UPWARD
                reasonCode := "D_CONFIRMED"
                phaseColorForBar := manipulationSide == SIDE_UPPER ? downwardColorInput : upwardColorInput
            else
                reasonCode := "D_GATE_OPEN"
        else if sameSideClose
            freezeRequested := true
            freezeResult := RESULT_INVALIDATED
            reasonCode := "INVALIDATED"
        else if reasonCode != "D_GATE_OPEN"
            reasonCode := "D_OPEN"

    bool sessionOver = isLastRthBar or leftSession
    if sessionOver and cycleLive and not freezeRequested
        freezeRequested := true
        freezeResult := RESULT_INCOMPLETE
        reasonCode := "SESSION_CLOSE"

    if freezeRequested and cycleLive
        modelResult := freezeResult
        cycleLive := false
        previousCycleHigh := accumulationHigh
        previousCycleLow := accumulationLow
        modelState := adaptiveMode and not sessionOver ? STATE_WAIT_ESCAPE : STATE_WAIT_SESSION
        if not na(activeAccumulationBox)
            box.set_border_color(activeAccumulationBox, color.new(accumulationColorInput, HISTORY_TRANSPARENCY))
            box.set_bgcolor(activeAccumulationBox, color.new(accumulationColorInput, math.min(100, RANGE_FILL_TRANSPARENCY + 5)))
        if not na(activeManipulationBox)
            box.set_border_color(activeManipulationBox, color.new(manipulationColorInput, HISTORY_TRANSPARENCY))
            box.set_bgcolor(activeManipulationBox, color.new(manipulationColorInput, math.min(100, RANGE_FILL_TRANSPARENCY + 5)))
        if not na(activeDistributionBox)
            color finalDistributionColor = freezeResult == RESULT_UPWARD ? upwardColorInput : freezeResult == RESULT_DOWNWARD ? downwardColorInput : distributionColorInput
            box.set_border_color(activeDistributionBox, color.new(finalDistributionColor, HISTORY_TRANSPARENCY))
            box.set_bgcolor(activeDistributionBox, color.new(finalDistributionColor, math.min(100, RANGE_FILL_TRANSPARENCY + 5)))
        array.push(historyAccumulationBoxes, activeAccumulationBox)
        array.push(historyManipulationBoxes, activeManipulationBox)
        array.push(historyDistributionBoxes, activeDistributionBox)
        activeAccumulationBox := na
        activeManipulationBox := na
        activeDistributionBox := na
        while array.size(historyAccumulationBoxes) > historyCountInput
            box oldestA = array.shift(historyAccumulationBoxes)
            box oldestM = array.shift(historyManipulationBoxes)
            box oldestD = array.shift(historyDistributionBoxes)
            if not na(oldestA)
                box.delete(oldestA)
            if not na(oldestM)
                box.delete(oldestM)
            if not na(oldestD)
                box.delete(oldestD)

    if sessionOver and modelState == STATE_WAIT_ESCAPE
        modelState := STATE_WAIT_SESSION

    if isLastRthBar and adaptiveMode
        while array.size(pendingSessionRanges) > 0
            float finalRange = array.shift(pendingSessionRanges)
            array.push(rangeBaseline, finalRange)
            while array.size(rangeBaseline) > BASELINE_SAMPLES
                array.shift(rangeBaseline)

// ————— Visuals - phase presentation presets
color confirmedPhaseColor = barstate.isconfirmed and isRthBar ? phaseColorForBar : na
bgcolor(showPhaseBackground and not na(confirmedPhaseColor) ? color.new(confirmedPhaseColor, PHASE_TINT_TRANSPARENCY) : na)
plotcandle(showPhaseCandles and not na(confirmedPhaseColor) ? open : na, showPhaseCandles and not na(confirmedPhaseColor) ? high : na, showPhaseCandles and not na(confirmedPhaseColor) ? low : na, showPhaseCandles and not na(confirmedPhaseColor) ? close : na, title = "Confirmed M/D phase candles", color = confirmedPhaseColor, wickcolor = confirmedPhaseColor, bordercolor = confirmedPhaseColor, editable = false, display = display.pane)

// ————— Calculations - separate calendar context
calendarAmdTuple(int containerMode) =>
    var int containerId = na
    var int calendarState = STATE_SCANNING
    var int calendarResult = RESULT_NONE
    var int calendarSide = SIDE_NONE
    var int calendarBarCount = 0
    var float calendarHigh = na
    var float calendarLow = na
    var int calendarReclaimTime = na
    int currentContainer = containerMode == CONTAINER_CYCLE_4Y ? int(year / 4) : containerMode == CONTAINER_YEAR ? year : containerMode == CONTAINER_QUARTER ? year * 10 + int((month - 1) / 3) + 1 : year * 100 + month
    if na(containerId) or currentContainer != containerId
        containerId := currentContainer
        calendarState := STATE_SCANNING
        calendarResult := RESULT_NONE
        calendarSide := SIDE_NONE
        calendarBarCount := 0
        calendarHigh := na
        calendarLow := na
        calendarReclaimTime := na
    calendarBarCount += 1
    if calendarBarCount <= MIN_ACCUMULATION_BARS
        calendarHigh := na(calendarHigh) ? high : math.max(calendarHigh, high)
        calendarLow := na(calendarLow) ? low : math.min(calendarLow, low)
        if calendarBarCount == MIN_ACCUMULATION_BARS
            if calendarHigh > calendarLow
                calendarState := STATE_AWAIT_MANIPULATION
            else
                calendarResult := RESULT_INSUFFICIENT
                calendarState := STATE_WAIT_SESSION
    else if calendarState == STATE_AWAIT_MANIPULATION
        bool upperSweep = high > calendarHigh
        bool lowerSweep = low < calendarLow
        if upperSweep and lowerSweep
            calendarResult := RESULT_AMBIGUOUS
            calendarState := STATE_WAIT_SESSION
        else if upperSweep or lowerSweep
            calendarSide := upperSweep ? SIDE_UPPER : SIDE_LOWER
            if close >= calendarLow and close <= calendarHigh
                calendarReclaimTime := time
                calendarState := STATE_DISTRIBUTION
            else
                calendarState := STATE_MANIPULATION
    else if calendarState == STATE_MANIPULATION
        bool oppositeBoundaryBreach = calendarSide == SIDE_UPPER ? low < calendarLow : high > calendarHigh
        if oppositeBoundaryBreach
            calendarResult := RESULT_AMBIGUOUS
            calendarState := STATE_WAIT_SESSION
        else if close >= calendarLow and close <= calendarHigh
            calendarReclaimTime := time
            calendarState := STATE_DISTRIBUTION
    else if calendarState == STATE_DISTRIBUTION and time > calendarReclaimTime
        bool bothBoundariesReached = high > calendarHigh and low < calendarLow
        bool oppositeClose = calendarSide == SIDE_UPPER ? close < calendarLow : close > calendarHigh
        bool sameSideClose = calendarSide == SIDE_UPPER ? close > calendarHigh : close < calendarLow
        if bothBoundariesReached
            calendarResult := RESULT_AMBIGUOUS
            calendarState := STATE_WAIT_SESSION
        else if oppositeClose
            calendarResult := calendarSide == SIDE_UPPER ? RESULT_DOWNWARD : RESULT_UPWARD
            calendarState := STATE_WAIT_SESSION
        else if sameSideClose
            calendarResult := RESULT_INVALIDATED
            calendarState := STATE_WAIT_SESSION
    [calendarState[1], calendarResult[1], calendarSide[1], calendarHigh[1], calendarLow[1], containerId[1], calendarBarCount[1]]

bool calendarSupported = supportedChart
[dailyState, dailyResult, dailySide, dailyHigh, dailyLow, dailyContainerId, dailyBarCount] = request.security(syminfo.tickerid, "D", calendarAmdTuple(CONTAINER_MONTH), lookahead = barmerge.lookahead_on)
[weeklyState, weeklyResult, weeklySide, weeklyHigh, weeklyLow, weeklyContainerId, weeklyBarCount] = request.security(syminfo.tickerid, "W", calendarAmdTuple(CONTAINER_QUARTER), lookahead = barmerge.lookahead_on)
[monthlyState, monthlyResult, monthlySide, monthlyHigh, monthlyLow, monthlyContainerId, monthlyBarCount] = request.security(syminfo.tickerid, "M", calendarAmdTuple(CONTAINER_YEAR), lookahead = barmerge.lookahead_on)
[quarterlyState, quarterlyResult, quarterlySide, quarterlyHigh, quarterlyLow, quarterlyContainerId, quarterlyBarCount] = request.security(syminfo.tickerid, "3M", calendarAmdTuple(CONTAINER_CYCLE_4Y), lookahead = barmerge.lookahead_on)
bool dailyAssessed = calendarSupported and not na(dailyContainerId)
bool weeklyAssessed = calendarSupported and not na(weeklyContainerId)
bool monthlyAssessed = calendarSupported and not na(monthlyContainerId)
bool quarterlyAssessed = calendarSupported and not na(quarterlyContainerId)

calendarStateText(int currentState, int currentResult, int currentSide) =>
    switch currentResult
        RESULT_UPWARD => "Distribution · closed up"
        RESULT_DOWNWARD => "Distribution · closed down"
        RESULT_AMBIGUOUS => "Unresolved"
        RESULT_INVALIDATED => "Unresolved"
        RESULT_INSUFFICIENT => "No range"
        => currentState == STATE_DISTRIBUTION ? "Distribution" : currentState == STATE_MANIPULATION ? (currentSide == SIDE_UPPER ? "Manipulation · range high swept" : "Manipulation · range low swept") : currentState == STATE_AWAIT_MANIPULATION ? "Accumulation" : "No range yet"

calendarPhaseColor(int phaseState, int phaseResult) =>
    phaseResult == RESULT_UPWARD ? upwardColorInput : phaseResult == RESULT_DOWNWARD ? downwardColorInput : phaseResult == RESULT_AMBIGUOUS or phaseResult == RESULT_INVALIDATED ? NEUTRAL_COLOR : phaseState == STATE_DISTRIBUTION ? distributionColorInput : phaseState == STATE_MANIPULATION ? manipulationColorInput : accumulationColorInput

calendarBandColor(bool periodEnabled, bool periodAssessed, int phaseState, int phaseResult, float aHigh, float aLow, int barCount) =>
    bool bandReady = showCalendarRibbon and periodEnabled and periodAssessed and barCount >= MIN_ACCUMULATION_BARS and not na(aHigh) and not na(aLow) and aHigh > aLow
    bandReady ? calendarPhaseColor(phaseState, phaseResult) : na

ribbonFillColor(color bandColor) =>
    na(bandColor) ? na : color.new(bandColor, RIBBON_FILL_TRANSPARENCY)

calendarPeriodStatus(bool periodAssessed, string periodName, int phaseState, int phaseResult, int phaseSide) =>
    not calendarSupported ? "Unavailable · unsupported chart" : not periodAssessed ? "No completed " + periodName + " bar" : calendarStateText(phaseState, phaseResult, phaseSide)

// ————— Visuals - Data Window geometry, volatility, and calendar fields
float accumulationWidthAtr = cycleLive and not na(accumulationAtr) and accumulationAtr > 0 ? (accumulationHigh - accumulationLow) / accumulationAtr : na
float manipulationDepth = manipulationSide == SIDE_UPPER ? manipulationExtreme - accumulationHigh : manipulationSide == SIDE_LOWER ? accumulationLow - manipulationExtreme : na
float manipulationDepthAtr = cycleLive and not na(manipulationAtr) and manipulationAtr > 0 ? manipulationDepth / manipulationAtr : na
float distributionRangeAtr = cycleLive and distributionStarted and not na(distributionAtr) and distributionAtr > 0 ? (distributionTop - distributionBottom) / distributionAtr : na

plot(cycleLive and not na(accumulationHigh) ? accumulationHigh : na, "Active accumulation high", color = na, editable = false, display = display.data_window)
plot(cycleLive and not na(accumulationLow) ? accumulationLow : na, "Active accumulation low", color = na, editable = false, display = display.data_window)
plot(cycleLive and manipulationSide != SIDE_NONE ? manipulationExtreme : na, "Active manipulation extreme", color = na, editable = false, display = display.data_window)
plot(cycleLive and distributionStarted ? distributionTop : na, "Active distribution high", color = na, editable = false, display = display.data_window)
plot(cycleLive and distributionStarted ? distributionBottom : na, "Active distribution low", color = na, editable = false, display = display.data_window)
plot(volatilityEnabled and isRthBar ? rthAtr : na, "RTH ATR (14)", color = na, editable = false, display = display.data_window)
plot(volatilityEnabled ? accumulationWidthAtr : na, "Accumulation width / latched RTH ATR (14)", color = na, editable = false, display = display.data_window)
plot(volatilityEnabled ? manipulationDepthAtr : na, "Manipulation depth / latched RTH ATR (14)", color = na, editable = false, display = display.data_window)
plot(volatilityEnabled and isRthBar ? currentBodyAtrRatio : na, "Current body / applicable RTH ATR (14)", color = na, editable = false, display = display.data_window)
plot(volatilityEnabled and isRthBar ? currentBodyRangeRatio : na, "Current body / full range", color = na, editable = false, display = display.data_window)
plot(volatilityEnabled ? distributionRangeAtr : na, "Distribution range / reclaim-latched RTH ATR (14)", color = na, editable = false, display = display.data_window)
plot(showCalendarData and calendarDailyInput and dailyAssessed ? dailyHigh : na, "Daily accumulation high", color = na, editable = false, display = display.data_window)
plot(showCalendarData and calendarDailyInput and dailyAssessed ? dailyLow : na, "Daily accumulation low", color = na, editable = false, display = display.data_window)
plot(showCalendarData and calendarWeeklyInput and weeklyAssessed ? weeklyHigh : na, "Weekly accumulation high", color = na, editable = false, display = display.data_window)
plot(showCalendarData and calendarWeeklyInput and weeklyAssessed ? weeklyLow : na, "Weekly accumulation low", color = na, editable = false, display = display.data_window)
plot(showCalendarData and calendarMonthlyInput and monthlyAssessed ? monthlyHigh : na, "Monthly accumulation high", color = na, editable = false, display = display.data_window)
plot(showCalendarData and calendarMonthlyInput and monthlyAssessed ? monthlyLow : na, "Monthly accumulation low", color = na, editable = false, display = display.data_window)
plot(showCalendarData and calendarQuarterlyInput and quarterlyAssessed ? quarterlyHigh : na, "Quarterly accumulation high", color = na, editable = false, display = display.data_window)
plot(showCalendarData and calendarQuarterlyInput and quarterlyAssessed ? quarterlyLow : na, "Quarterly accumulation low", color = na, editable = false, display = display.data_window)

// ————— Visuals - the HTF ribbon along the bottom of the pane
bool ribbonLabelGutter = time > last_bar_time - RIBBON_LABEL_GUTTER * timeframe.in_seconds() * 1000
color quarterlyBandColor = calendarBandColor(calendarQuarterlyInput, quarterlyAssessed, quarterlyState, quarterlyResult, quarterlyHigh, quarterlyLow, quarterlyBarCount)
color monthlyBandColor = calendarBandColor(calendarMonthlyInput, monthlyAssessed, monthlyState, monthlyResult, monthlyHigh, monthlyLow, monthlyBarCount)
color weeklyBandColor = calendarBandColor(calendarWeeklyInput, weeklyAssessed, weeklyState, weeklyResult, weeklyHigh, weeklyLow, weeklyBarCount)
color dailyBandColor = calendarBandColor(calendarDailyInput, dailyAssessed, dailyState, dailyResult, dailyHigh, dailyLow, dailyBarCount)
plotchar(na(dailyBandColor) or ribbonLabelGutter ? na : 1, "HTF ribbon · Daily", char = RIBBON_GLYPH_RULE, location = location.bottom, color = ribbonFillColor(dailyBandColor), size = size.huge, editable = false, display = display.pane)
plotchar(na(weeklyBandColor) or ribbonLabelGutter ? na : 1, "HTF ribbon · Weekly", char = RIBBON_GLYPH_RULE, location = location.bottom, color = ribbonFillColor(weeklyBandColor), size = size.large, editable = false, display = display.pane)
plotchar(na(monthlyBandColor) or ribbonLabelGutter ? na : 1, "HTF ribbon · Monthly", char = RIBBON_GLYPH_RULE, location = location.bottom, color = ribbonFillColor(monthlyBandColor), size = size.normal, editable = false, display = display.pane)
plotchar(na(quarterlyBandColor) or ribbonLabelGutter ? na : 1, "HTF ribbon · Quarterly", char = RIBBON_GLYPH_RULE, location = location.bottom, color = ribbonFillColor(quarterlyBandColor), size = size.small, editable = false, display = display.pane)

// ————— Visuals - the ribbon labels
plotchar(na(dailyBandColor) ? na : 1, "HTF ribbon · Daily label", char = " ", location = location.bottom, color = na, text = CALENDAR_DAILY, textcolor = dailyBandColor, size = size.large, offset = RIBBON_LABEL_OFFSET, show_last = 1, editable = false, display = display.pane)
plotchar(na(weeklyBandColor) ? na : 1, "HTF ribbon · Weekly label", char = " ", location = location.bottom, color = na, text = CALENDAR_WEEKLY, textcolor = weeklyBandColor, size = size.normal, offset = RIBBON_LABEL_OFFSET, show_last = 1, editable = false, display = display.pane)
plotchar(na(monthlyBandColor) ? na : 1, "HTF ribbon · Monthly label", char = " ", location = location.bottom, color = na, text = CALENDAR_MONTHLY, textcolor = monthlyBandColor, size = size.small, offset = RIBBON_LABEL_OFFSET, show_last = 1, editable = false, display = display.pane)
plotchar(na(quarterlyBandColor) ? na : 1, "HTF ribbon · Quarterly label", char = " ", location = location.bottom, color = na, text = CALENDAR_QUARTERLY, textcolor = quarterlyBandColor, size = size.tiny, offset = RIBBON_LABEL_OFFSET, show_last = 1, editable = false, display = display.pane)

// ————— Visuals - status and diagnostics
var table statusPanel = table.new(configuredPanelPosition(panelPositionInput), 2, 4 + (showCalendarPanel ? calendarPeriodsEnabled : 0), frame_color = color.new(NEUTRAL_COLOR, 30), frame_width = 1, border_color = color.new(NEUTRAL_COLOR, 55), border_width = 1)

if barstate.islast and panelVisible
    color panelBaseColor = color.new(chart.bg_color, PANEL_BACKGROUND_TRANSPARENCY)
    color titleColor = color.new(resultColor(modelResult), 60)
    color accumulationRowColor = color.new(accumulationColorInput, cycleLive and modelState == STATE_AWAIT_MANIPULATION ? 45 : 82)
    color manipulationRowColor = color.new(manipulationColorInput, cycleLive and modelState == STATE_MANIPULATION ? 45 : 82)
    color activeDistributionColor = modelResult == RESULT_UPWARD ? upwardColorInput : modelResult == RESULT_DOWNWARD ? downwardColorInput : distributionColorInput
    color distributionRowColor = color.new(activeDistributionColor, cycleLive and modelState == STATE_DISTRIBUTION ? 45 : 82)

    string phaseStatus = "No range yet · scanning"
    if not supportedChart
        phaseStatus := "Unsupported chart"
    else if cycleLive and modelState == STATE_AWAIT_MANIPULATION
        phaseStatus := "Accumulation · awaiting sweep"
    else if cycleLive and modelState == STATE_MANIPULATION
        phaseStatus := "Manipulation · awaiting reclaim"
    else if cycleLive and modelState == STATE_DISTRIBUTION
        phaseStatus := "Distribution · open"
    else if modelState == STATE_WAIT_ESCAPE
        phaseStatus := resultText(modelResult) + " · awaiting close outside range"
    else if modelState == STATE_WAIT_SESSION
        phaseStatus := resultText(modelResult) + " · next session"
    else if not isRthBar
        phaseStatus := "Outside RTH"

    string accumulationStatus = "Not set"
    if not supportedChart
        accumulationStatus := "Standard 1-15 min · New York exchange timezone"
    else if adaptiveMode and array.size(rangeBaseline) < BASELINE_SAMPLES
        accumulationStatus := "Baseline " + str.tostring(array.size(rangeBaseline)) + "/" + str.tostring(BASELINE_SAMPLES)
    else if not adaptiveMode and modelState == STATE_BUILD_OPENING
        accumulationStatus := accumulationModeInput + " · " + str.tostring(openingBarCount) + " bars"
    else if not na(accumulationHigh)
        accumulationStatus := formatPrice(accumulationLow) + " - " + formatPrice(accumulationHigh)

    string manipulationStatus = manipulationSide == SIDE_NONE ? "Not observed" : (manipulationSide == SIDE_UPPER ? "Range high swept" : "Range low swept") + " · " + formatClock(manipulationStartTime)
    if reasonCode == "M_SUBTHRESHOLD"
        manipulationStatus := "Sweep under 0.10× ATR"

    string distributionStatus = "Not observed"
    if cycleLive and modelState == STATE_DISTRIBUTION and reasonCode == "D_GATE_OPEN"
        distributionStatus := "Past far boundary · body filter not met"
    else if not na(reclaimTime)
        distributionStatus := "Reclaimed " + formatClock(reclaimTime)

    string quarterlyStatus = calendarPeriodStatus(quarterlyAssessed, CALENDAR_QUARTERLY, quarterlyState, quarterlyResult, quarterlySide)
    string monthlyStatus = calendarPeriodStatus(monthlyAssessed, CALENDAR_MONTHLY, monthlyState, monthlyResult, monthlySide)
    string weeklyStatus = calendarPeriodStatus(weeklyAssessed, CALENDAR_WEEKLY, weeklyState, weeklyResult, weeklySide)
    string dailyStatus = calendarPeriodStatus(dailyAssessed, CALENDAR_DAILY, dailyState, dailyResult, dailySide)

    string displayedReason = not supportedChart ? "UNSUPPORTED" : reasonCode
    string stateReason = modelState == STATE_WAIT_ESCAPE ? "WAIT_ESCAPE" : modelState == STATE_WAIT_SESSION ? "WAIT_SESSION" : displayedReason
    string marketReadingDetail = "• Accumulation model · " + accumulationModeInput + "\n• Confirmation profile · " + confirmationProfileInput + "\n• Intraday code · " + displayedReason
    if stateReason != displayedReason
        marketReadingDetail += " · " + stateReason
    if adaptiveMode
        marketReadingDetail += "\n• Adaptive baseline · " + str.tostring(array.size(rangeBaseline)) + "/" + str.tostring(BASELINE_SAMPLES) + " windows"
    string insufficientPeriods = ""
    if calendarDailyInput and dailyAssessed and dailyResult == RESULT_INSUFFICIENT
        insufficientPeriods += (insufficientPeriods == "" ? "" : ", ") + CALENDAR_DAILY
    if calendarWeeklyInput and weeklyAssessed and weeklyResult == RESULT_INSUFFICIENT
        insufficientPeriods += (insufficientPeriods == "" ? "" : ", ") + CALENDAR_WEEKLY
    if calendarMonthlyInput and monthlyAssessed and monthlyResult == RESULT_INSUFFICIENT
        insufficientPeriods += (insufficientPeriods == "" ? "" : ", ") + CALENDAR_MONTHLY
    if calendarQuarterlyInput and quarterlyAssessed and quarterlyResult == RESULT_INSUFFICIENT
        insufficientPeriods += (insufficientPeriods == "" ? "" : ", ") + CALENDAR_QUARTERLY
    if insufficientPeriods != ""
        marketReadingDetail += "\n• HTF code · CAL_INSUFFICIENT · " + insufficientPeriods
    if showCalendarData and not showCalendarPanel
        if calendarDailyInput
            marketReadingDetail += "\n• HTF · " + CALENDAR_DAILY + " · " + dailyStatus
        if calendarWeeklyInput
            marketReadingDetail += "\n• HTF · " + CALENDAR_WEEKLY + " · " + weeklyStatus
        if calendarMonthlyInput
            marketReadingDetail += "\n• HTF · " + CALENDAR_MONTHLY + " · " + monthlyStatus
        if calendarQuarterlyInput
            marketReadingDetail += "\n• HTF · " + CALENDAR_QUARTERLY + " · " + quarterlyStatus

    string marketReadingTimeframe = supportedChart ? str.tostring(chartMinutes) + "m" : timeframe.period

    panelCell(statusPanel, 0, 0, "AMD · " + marketReadingTimeframe, chart.fg_color, titleColor)
    table.cell(statusPanel, 1, 0, phaseStatus, text_color = chart.fg_color, text_size = size.small, text_halign = text.align_left, text_formatting = text.format_none, bgcolor = titleColor, tooltip = marketReadingDetail)
    panelCell(statusPanel, 0, 1, "Accumulation", chart.fg_color, accumulationRowColor)
    panelCell(statusPanel, 1, 1, accumulationStatus, chart.fg_color, accumulationRowColor)
    panelCell(statusPanel, 0, 2, "Manipulation", chart.fg_color, manipulationRowColor)
    panelCell(statusPanel, 1, 2, manipulationStatus, chart.fg_color, manipulationRowColor)
    panelCell(statusPanel, 0, 3, "Distribution", chart.fg_color, distributionRowColor)
    panelCell(statusPanel, 1, 3, distributionStatus, chart.fg_color, distributionRowColor)
    int calendarRow = 4
    if showCalendarPanel
        if calendarDailyInput
            panelCell(statusPanel, 0, calendarRow, "HTF · " + CALENDAR_DAILY, chart.fg_color, panelBaseColor)
            panelCell(statusPanel, 1, calendarRow, dailyStatus, chart.fg_color, panelBaseColor)
            calendarRow += 1
        if calendarWeeklyInput
            panelCell(statusPanel, 0, calendarRow, "HTF · " + CALENDAR_WEEKLY, chart.fg_color, panelBaseColor)
            panelCell(statusPanel, 1, calendarRow, weeklyStatus, chart.fg_color, panelBaseColor)
            calendarRow += 1
        if calendarMonthlyInput
            panelCell(statusPanel, 0, calendarRow, "HTF · " + CALENDAR_MONTHLY, chart.fg_color, panelBaseColor)
            panelCell(statusPanel, 1, calendarRow, monthlyStatus, chart.fg_color, panelBaseColor)
            calendarRow += 1
        if calendarQuarterlyInput
            panelCell(statusPanel, 0, calendarRow, "HTF · " + CALENDAR_QUARTERLY, chart.fg_color, panelBaseColor)
            panelCell(statusPanel, 1, calendarRow, quarterlyStatus, chart.fg_color, panelBaseColor)
            calendarRow += 1
````
