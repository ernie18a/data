# NY Killzones Pro

- url: https://www.tradingview.com/script/qEOp2Ut7-NY-Killzones-Pro/
- type: indicator
- pine_id: PUB;264f55cacbcf49cc89ed897d802e742a
- version: 6.0

## Description

**NY Killzones Pro**

NY Killzones Pro is a professional session-based trading indicator designed for index futures and CFDs, including NQ, ES and YM.

### Features

• Asian, London, NY AM and NY PM Killzones (New York Time)

• High & Low liquidity levels for every killzone

• High/Low levels automatically extend until liquidity is taken

• Current Daily Open only

• Current Weekly Open only

• Previous Day High / Low

• Previous Week High / Low

• Current day 00:00 reference level

• Current day 08:30 reference level

• New York day separator

• Individual on/off switches for every session, level and label

• Fully customizable colors

### Designed for

* Nasdaq (NQ)
* S&P 500 (ES)
* Dow Jones (YM)
* US Indices CFDs

This indicator focuses on keeping the chart clean by displaying only the current trading day's reference levels and the current week's weekly open while preserving the most important liquidity levels.

Perfect for traders using ICT, Smart Money Concepts (SMC), liquidity, market structure and session-based trading.

## Source Code

````pine
// © ElMarkucho / rebuilt with ChatGPT
//@version=6
indicator("ICT Session + Cycle SMT Engine v17.9 CYCLE COLOR LEGEND", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500,
     max_bars_back = 5000, dynamic_requests = true)

// VISUAL HIERARCHY
// 1) Confirmed SMT: bright gold/magenta, width 2.
// 2) Live SMT: same hue, thinner and transparent.
// 3) HTF / opening-gap levels: medium priority.
// 4) Session H/L and cycle subdivisions: subdued context layers.
// 90m supplies a very light phase background. 30m subdivisions are drawn
// afterward with the stronger classic phase fill so they remain visible.
// AMD phases are read from fill color and a compact fixed chart legend.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE
// Every supported chart uses the same canonical 1-minute feed.
// This prevents 1m and 2m charts from building different session/cycle ranges.
// On charts above 1m, all available 1m intrabars are processed in time order.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string TZ = "America/New_York"
float chartSec = timeframe.in_seconds(timeframe.period)
bool intraday = timeframe.isintraday
bool engineEnabled = intraday and chartSec >= 60 and chartSec <= 3600
bool useIntrabars = engineEnabled and chartSec > 60
int CANONICAL_SECONDS = 60
int MS_MINUTE = 60 * 1000
int MS_HOUR = 60 * MS_MINUTE
int canonicalCalcBars = input.int(50000, "Canonical 1m bars requested", minval = 10000, maxval = 200000, step = 10000, group = "Engine",
     tooltip = "Uses one fixed 1-minute source on every chart timeframe. Higher values provide more calendar history but consume more resources. TradingView and plan limits still apply.")

nyDayKey(int t) =>
    year(t, TZ) * 10000 + month(t, TZ) * 100 + dayofmonth(t, TZ)

feedRightTime(int t) =>
    t + CANONICAL_SECONDS * 1000

sweepAnchorTime() =>
    time

liveRightTime() =>
    na(time_close) ? time : time_close

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASSETS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string symbolB = input.symbol("CME_MINI:ES1!", "Comparison asset B", group = "SMT • Assets")
string labelB = input.string("ES", "Asset B label", group = "SMT • Assets")
bool useC = input.bool(true, "Use comparison asset C", group = "SMT • Assets")
string symbolC = input.symbol("CBOT_MINI:YM1!", "Comparison asset C", group = "SMT • Assets")
string labelC = input.string("YM", "Asset C label", group = "SMT • Assets")

// Fixed 1m requests are used on the 1m chart. On higher charts, the
// request.security_lower_tf() arrays below provide the same source bars.
[aTimeBase, aOpenBase, aHighBase, aLowBase, aCloseBase] = request.security(
     syminfo.tickerid, "1", [time, open, high, low, close],
     gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true, calc_bars_count = canonicalCalcBars)
[bTimeBase, bHighBase, bLowBase, bTick] = request.security(
     symbolB, "1", [time, high, low, syminfo.mintick],
     gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true, calc_bars_count = canonicalCalcBars)
[cTimeBase, cHighBase, cLowBase, cTickRaw] = request.security(
     symbolC, "1", [time, high, low, syminfo.mintick],
     gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true, calc_bars_count = canonicalCalcBars)

float cTick = useC ? cTickRaw : na

// Ordered 1m intrabars are used on every chart timeframe above 1m.
// B/C only request the values actually used by the SMT engine.
[aTimes1, aOpens1, aHighs1, aLows1, aCloses1] = request.security_lower_tf(
     syminfo.tickerid, "1", [time, open, high, low, close],
     ignore_invalid_symbol = true, ignore_invalid_timeframe = true,
     calc_bars_count = canonicalCalcBars)
[bTimes1, bHighs1, bLows1] = request.security_lower_tf(
     symbolB, "1", [time, high, low],
     ignore_invalid_symbol = true, ignore_invalid_timeframe = true,
     calc_bars_count = canonicalCalcBars)
[cTimes1, cHighs1, cLows1] = request.security_lower_tf(
     symbolC, "1", [time, high, low],
     ignore_invalid_symbol = true, ignore_invalid_timeframe = true,
     calc_bars_count = canonicalCalcBars)

maskText(int mask) =>
    mask == 3 ? labelB + "+" + labelC : mask == 2 ? labelC : labelB

findTimeIndex(array<int> times, int target) =>
    int found = -1
    int count = array.size(times)
    if count > 0
        for i = 0 to count - 1
            if found == -1 and array.get(times, i) == target
                found := i
    found

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS — SESSIONS / LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showSessionBoxes = input.bool(true, "Show session boxes", group = "Sessions")
bool showSessionLabels = input.bool(true, "Show session labels", group = "Sessions")
bool showSessionHighs = input.bool(true, "Show session highs", group = "Sessions")
bool showSessionLows = input.bool(true, "Show session lows", group = "Sessions")
bool showSessionLevelLabels = input.bool(true, "Show session H/L labels", group = "Sessions")
bool keepSweptSessionLevels = input.bool(true, "Keep swept session levels", group = "Sessions")
int sessionBoxTransparency = input.int(99, "Session box transparency", minval = 85, maxval = 100, group = "Sessions")
int sessionBorderTransparency = input.int(94, "Session border transparency", minval = 0, maxval = 100, group = "Sessions")
int sessionLevelTransparency = input.int(22, "Session H/L line transparency", minval = 0, maxval = 80, group = "Sessions",
     tooltip = "Session ranges remain readable but stay below SMT and HTF levels in the visual hierarchy.")
int maxSessionBoxes = input.int(16, "Maximum session boxes", minval = 4, maxval = 40, group = "Sessions")
int maxSessionLevels = input.int(120, "Maximum session H/L levels", minval = 20, maxval = 250, group = "Sessions")
bool mergeOverlappingLevelLabels = input.bool(true, "Merge overlapping Session + D/W/M labels", group = "Sessions",
     tooltip = "When a session high/low and an active Daily, Weekly or Monthly level occupy the same price, one combined higher-timeframe label is shown, e.g. DH/LH, instead of overlapping text.")
int levelLabelMergeTicks = input.int(2, "Level-label merge tolerance (ticks)", minval = 0, maxval = 20, group = "Sessions")

color asiaColor = input.color(color.new(#8B5CF6, 0), "Asia", group = "Sessions • Colors")
color londonColor = input.color(color.new(#22D3EE, 0), "London", group = "Sessions • Colors")
color newYorkColor = input.color(color.new(#F97316, 0), "New York", group = "Sessions • Colors")

sessionName(int idx) =>
    idx == 0 ? "ASIA" : idx == 1 ? "LONDON" : "NEW YORK"

sessionHighName(int idx) =>
    idx == 0 ? "AH" : idx == 1 ? "LH" : "NYH"

sessionLowName(int idx) =>
    idx == 0 ? "AL" : idx == 1 ? "LL" : "NYL"

sessionColor(int idx) =>
    idx == 0 ? asiaColor : idx == 1 ? londonColor : newYorkColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS — CYCLES
// 02:30–16:00 NY: 81×10m, 27×30m, 9×90m, 3×270m.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showCycles = input.bool(true, "Show time-cycle boxes", group = "Time Cycles")
bool show10Boxes = input.bool(false, "Show 10-minute boxes", group = "Time Cycles")
bool show30Boxes = input.bool(true, "Show 30-minute boxes", group = "Time Cycles")
bool show90Boxes = input.bool(true, "Show 90-minute boxes", group = "Time Cycles")
bool show270Boxes = input.bool(true, "Show 270-minute boxes", group = "Time Cycles")
bool showCycleText = input.bool(false, "Show A / M / D text inside boxes", group = "Time Cycles")
bool showCycleLegend = input.bool(true, "Show time-cycle color legend", group = "Time Cycles",
     tooltip = "Shows a fixed legend for Accumulation, Manipulation, Distribution and the neutral 270m structure color.")
int keepCycleDays = input.int(2, "Keep cycle days", minval = 1, maxval = 4, group = "Time Cycles")

// Classic v17.3 visual model:
// • Phase identity comes from the fill color, not from strong borders or letters.
// • 30m uses the strongest tint and is drawn above 90m/270m.
// • Borders are intentionally almost invisible and always solid.
int fill10Transparency = input.int(96, "10m fill transparency", minval = 80, maxval = 100, group = "Time Cycles • Style")
int fill30Transparency = input.int(90, "30m fill transparency", minval = 70, maxval = 100, group = "Time Cycles • Style")
int fill90Transparency = input.int(96, "90m fill transparency", minval = 80, maxval = 100, group = "Time Cycles • Style")
int fill270Transparency = input.int(98, "270m fill transparency", minval = 85, maxval = 100, group = "Time Cycles • Style")
int cycleBorderTransparency = input.int(96, "Cycle border transparency", minval = 85, maxval = 100, group = "Time Cycles • Style",
     tooltip = "Classic nearly invisible borders. Set to 100 to hide them completely.")

color accumulationColor = input.color(#64748B, "Accumulation", group = "Time Cycles • Colors")
color manipulationColor = input.color(#F59E0B, "Manipulation", group = "Time Cycles • Colors")
color distributionColor = input.color(#8B5CF6, "Distribution", group = "Time Cycles • Colors")
color cycle270Color = input.color(#475569, "270-minute cycle", group = "Time Cycles • Colors")

phaseRole(int indexWithinThree) =>
    indexWithinThree == 0 ? 0 : indexWithinThree == 1 ? 1 : 2

phaseShort(int role) =>
    role == 0 ? "A" : role == 1 ? "M" : "D"

phaseColor(int role) =>
    role == 0 ? accumulationColor : role == 1 ? manipulationColor : distributionColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS — SMT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showSessionSmt = input.bool(true, "Session-to-session SMT", group = "SMT • Logic")
bool showCycle10Smt = input.bool(true, "10m cycle SMT", group = "SMT • Logic")
bool showCycle30Smt = input.bool(true, "30m cycle SMT", group = "SMT • Logic")
bool showCycle90Smt = input.bool(true, "90m cycle SMT", group = "SMT • Logic")
bool showCycle270Smt = input.bool(true, "270m cycle SMT", group = "SMT • Logic")
bool showLiveSmt = input.bool(true, "Show live SMT", group = "SMT • Logic")
bool rejectTwoSidedSmt = input.bool(true, "Reject simultaneous high + low SMT", group = "SMT • Logic")
int sweepTicks = input.int(1, "Minimum sweep ticks", minval = 0, maxval = 20, group = "SMT • Logic")
bool removeInvalidatedSmt = input.bool(true, "Remove invalidated confirmed SMT", group = "SMT • Logic")
int invalidBufferTicks = input.int(1, "Invalidation buffer ticks", minval = 0, maxval = 20, group = "SMT • Logic")
int confirmedLifeMultiplier = input.int(5, "Confirmed SMT lifetime (cycle multiples)", minval = 1, maxval = 20, group = "SMT • Logic")
int cycleReferenceLookback = input.int(9, "Completed cycles searched for SMT", minval = 1, maxval = 27, group = "SMT • Logic",
     tooltip = "Cycle SMT is not limited to the immediately previous cycle. The engine searches the newest still-valid completed cycle ranges, so a 05:30–06:00 cycle can compare with 04:30–05:00 when 05:00–05:30 did not consume that liquidity.")
bool requireUntouchedCycleReference = input.bool(true, "Require untouched cycle liquidity", group = "SMT • Logic",
     tooltip = "A previous cycle high/low can be used only if no intervening completed cycle has already swept the corresponding levels. This prevents stale lines through many unrelated cycles.")

// SMT is the highest-priority visual layer. Gold/magenta stay separate from
// blue/white candles and green/red FVG zones.
color bullColor = input.color(color.new(#FFD54F, 0), "Bullish SMT", group = "SMT • Style")
color bearColor = input.color(color.new(#FF3BD4, 0), "Bearish SMT", group = "SMT • Style")
int confirmedSmtWidth = input.int(2, "Confirmed SMT line width", minval = 1, maxval = 4, group = "SMT • Style")
int liveSmtWidth = input.int(1, "Live SMT line width", minval = 1, maxval = 3, group = "SMT • Style")
int liveTransparency = input.int(72, "Live SMT transparency", minval = 20, maxval = 90, group = "SMT • Style")
bool showSessionSmtLabels = input.bool(false, "Session SMT labels", group = "SMT • Style")
bool showCycleSmtLabels = input.bool(true, "Cycle SMT labels", group = "SMT • Style")
string smtLabelSize = input.string("Small", "SMT label size", options = ["Tiny", "Small"], group = "SMT • Style")
bool higherTfWinsSameSmt = input.bool(true, "Higher timeframe wins for identical SMT anchors", group = "SMT • Style",
     tooltip = "When several 10m/30m/90m/270m or session SMT states connect the exact same chart candles, only the highest-priority timeframe is drawn. Lower-timeframe states remain stored and can reappear if the dominant signal is removed.")
int duplicateSmtPriceTicks = input.int(2, "Identical SMT price tolerance (ticks)", minval = 0, maxval = 20, group = "SMT • Style")

smtSize() =>
    smtLabelSize == "Small" ? size.small : size.tiny

familyText(int family) =>
    switch family
        0 => "LON/ASIA"
        1 => "NY/LON"
        2 => "10m"
        3 => "30m"
        4 => "90m"
        => "270m"

familyDurationMinutes(int family) =>
    switch family
        0 => 1440
        1 => 1440
        2 => 10
        3 => 30
        4 => 90
        => 270

familyEnabled(int family) =>
    switch family
        0 => showSessionSmt
        1 => showSessionSmt
        2 => showCycle10Smt
        3 => showCycle30Smt
        4 => showCycle90Smt
        => showCycle270Smt

familyShowsLabel(int family) =>
    family <= 1 ? showSessionSmtLabels : showCycleSmtLabels

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TYPES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type RangeState
    float aH = na
    float aL = na
    float bH = na
    float bL = na
    float cH = na
    float cL = na
    int aHt = na
    int aLt = na
    int key = na
    int startT = na
    int endT = na
    bool active = false
    bool complete = false
    int seq = 0
    box bx = na
    label nameLb = na
    line hiLine = na
    line loLine = na
    label hiLb = na
    label loLb = na

type CycleState
    int minutes
    RangeState cur
    RangeState prev
    array<RangeState> history
    box bx = na
    label lb = na
    int cycleIndex = na

type SmtSignal
    line ln = na
    label lb = na
    bool active = false
    bool confirmed = false
    int eventKey = na
    int mask = 0
    int t1 = na
    int t2 = na
    float y1 = na
    float y2 = na
    float invalidLevel = na
    int lastUpdateT = na

type TimeLevelState
    int dayKey = na
    int event1800 = na
    line line1800 = na
    line line0000 = na
    line line0830 = na
    line line0930 = na
    label lb1800 = na
    label lb0000 = na
    label lb0830 = na
    label lb0930 = na
    float price1800 = na
    float price0000 = na
    float price0830 = na
    float price0930 = na

type OpeningGap
    box bx = na
    line hiLn = na
    line loLn = na
    line ceLn = na
    line q25Ln = na
    line q75Ln = na
    label lb = na
    int kind = 0
    int startT = na
    float closePrice = na
    float openPrice = na
    float top = na
    float bottom = na
    float ce = na
    float q25 = na
    float q75 = na
    bool upGap = false
    bool filled = false

type OpeningGapEngine
    float last1700Close = na
    int last1700T = na
    int lastOpenEvent = na

newCycle(int minutes) =>
    CycleState.new(
         minutes = minutes,
         cur = RangeState.new(),
         prev = RangeState.new(),
         history = array.new<RangeState>())

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] sessionBoxes = array.new_box()
var label[] sessionLabels = array.new_label()
var line[] sessionLevelLines = array.new_line()
var label[] sessionLevelLabels = array.new_label()
var float[] sessionLevelPrices = array.new_float()
var bool[] sessionLevelIsHigh = array.new_bool()
var bool[] sessionLevelActive = array.new_bool()
var string[] sessionLevelNames = array.new_string()
var box[] cycleBoxes = array.new_box()
var label[] cycleLabels = array.new_label()

registerSessionVisual(box bx, label lb) =>
    if not na(bx)
        array.push(sessionBoxes, bx)
        array.push(sessionLabels, lb)
        while array.size(sessionBoxes) > maxSessionBoxes
            box oldBx = array.shift(sessionBoxes)
            label oldLb = array.shift(sessionLabels)
            box.delete(oldBx)
            if not na(oldLb)
                label.delete(oldLb)
    true

registerSessionLevel(line ln, label lb, float price, bool isHigh, string levelName) =>
    if not na(ln)
        array.push(sessionLevelLines, ln)
        array.push(sessionLevelLabels, lb)
        array.push(sessionLevelPrices, price)
        array.push(sessionLevelIsHigh, isHigh)
        array.push(sessionLevelActive, true)
        array.push(sessionLevelNames, levelName)
        while array.size(sessionLevelLines) > maxSessionLevels
            line oldLn = array.shift(sessionLevelLines)
            label oldLb = array.shift(sessionLevelLabels)
            array.shift(sessionLevelPrices)
            array.shift(sessionLevelIsHigh)
            array.shift(sessionLevelActive)
            array.shift(sessionLevelNames)
            line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)
    true

registerCycleVisual(box bx, label lb) =>
    if not na(bx)
        array.push(cycleBoxes, bx)
        array.push(cycleLabels, lb)
        int perDay = (show10Boxes ? 81 : 0) + (show30Boxes ? 27 : 0) + (show90Boxes ? 9 : 0) + (show270Boxes ? 3 : 0)
        int maxObjects = math.max(1, keepCycleDays * perDay)
        while array.size(cycleBoxes) > maxObjects
            box oldBx = array.shift(cycleBoxes)
            label oldLb = array.shift(cycleLabels)
            box.delete(oldBx)
            if not na(oldLb)
                label.delete(oldLb)
    true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE INITIALIZATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var array<RangeState> sessions = array.new<RangeState>()
var array<CycleState> cycles = array.new<CycleState>()
var array<SmtSignal> smtSignals = array.new<SmtSignal>()
var array<bool> alertFlags = array.new_bool(4, false)
var int lastAlertChartBar = na
var TimeLevelState timeLevels = TimeLevelState.new()
var OpeningGapEngine openingGapEngine = OpeningGapEngine.new()
var array<OpeningGap> openingGaps = array.new<OpeningGap>()

if barstate.isfirst
    for i = 0 to 2
        array.push(sessions, RangeState.new())
    array.push(cycles, newCycle(10))
    array.push(cycles, newCycle(30))
    array.push(cycles, newCycle(90))
    array.push(cycles, newCycle(270))
    for i = 0 to 11
        array.push(smtSignals, SmtSignal.new())

if na(lastAlertChartBar) or bar_index != lastAlertChartBar
    for i = 0 to 3
        array.set(alertFlags, i, false)
    lastAlertChartBar := bar_index

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RANGE HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
clearRangeValues(RangeState r) =>
    r.aH := na
    r.aL := na
    r.bH := na
    r.bL := na
    r.cH := na
    r.cL := na
    r.aHt := na
    r.aLt := na
    r.key := na
    r.startT := na
    r.endT := na
    r.active := false
    r.complete := false
    true

copyRangeValues(RangeState dst, RangeState src) =>
    dst.aH := src.aH
    dst.aL := src.aL
    dst.bH := src.bH
    dst.bL := src.bL
    dst.cH := src.cH
    dst.cL := src.cL
    dst.aHt := src.aHt
    dst.aLt := src.aLt
    dst.key := src.key
    dst.startT := src.startT
    dst.endT := src.endT
    dst.active := false
    dst.complete := src.complete or src.active
    dst.seq := src.seq
    true

cloneRange(RangeState src) =>
    RangeState dst = RangeState.new()
    copyRangeValues(dst, src)
    dst.active := false
    dst.complete := true
    dst

cycleDayFromKey(int key) =>
    na(key) ? na : int(math.floor(float(key) / 1000.0))

pruneCycleHistoryToDay(CycleState cs, int key) =>
    int wantedDay = cycleDayFromKey(key)
    while array.size(cs.history) > 0 and cycleDayFromKey(array.get(cs.history, 0).key) != wantedDay
        array.shift(cs.history)
    true

pushCycleHistory(CycleState cs) =>
    if cs.cur.complete and not na(cs.cur.key)
        array.push(cs.history, cloneRange(cs.cur))
        while array.size(cs.history) > cycleReferenceLookback
            array.shift(cs.history)
    true

resetRange(RangeState r, int key, int startT, int endT, int t,
     float aH, float aL, float bH, float bL, float cH, float cL) =>
    r.aH := aH
    r.aL := aL
    r.bH := bH
    r.bL := bL
    r.cH := cH
    r.cL := cL
    r.aHt := not na(aH) ? t : na
    r.aLt := not na(aL) ? t : na
    r.key := key
    r.startT := startT
    r.endT := endT
    r.active := true
    r.complete := false
    true

updateRange(RangeState r, int t,
     float aH, float aL, float bH, float bL, float cH, float cL) =>
    if not na(aH) and (na(r.aH) or aH > r.aH)
        r.aH := aH
        r.aHt := t
    if not na(aL) and (na(r.aL) or aL < r.aL)
        r.aL := aL
        r.aLt := t
    if not na(bH)
        r.bH := na(r.bH) ? bH : math.max(r.bH, bH)
    if not na(bL)
        r.bL := na(r.bL) ? bL : math.min(r.bL, bL)
    if useC and not na(cH)
        r.cH := na(r.cH) ? cH : math.max(r.cH, cH)
    if useC and not na(cL)
        r.cL := na(r.cL) ? cL : math.min(r.cL, cL)
    true

rangeReadyAB(RangeState r) =>
    not na(r.aH) and not na(r.aL) and not na(r.bH) and not na(r.bL) and not na(bTick)

rangeReadyC(RangeState r) =>
    useC and not na(r.aH) and not na(r.aL) and not na(r.cH) and not na(r.cL) and not na(cTick)


rangeHighForMarket(RangeState r, int market) =>
    market == 0 ? r.aH : market == 1 ? r.bH : r.cH

rangeLowForMarket(RangeState r, int market) =>
    market == 0 ? r.aL : market == 1 ? r.bL : r.cL

tickForMarket(int market) =>
    market == 0 ? syminfo.mintick : market == 1 ? bTick : cTick

cycleReferenceUntouched(array<RangeState> history, int referenceIndex, int market, bool highSide) =>
    RangeState reference = array.get(history, referenceIndex)
    float level = highSide ? rangeHighForMarket(reference, market) : rangeLowForMarket(reference, market)
    float tick = tickForMarket(market)
    bool untouched = not na(level) and not na(tick)

    if untouched and requireUntouchedCycleReference
        int lastIndex = array.size(history) - 1
        if referenceIndex < lastIndex
            for i = referenceIndex + 1 to lastIndex
                RangeState later = array.get(history, i)
                float laterExtreme = highSide ? rangeHighForMarket(later, market) : rangeLowForMarket(later, market)
                if not na(laterExtreme)
                    bool consumed = highSide ?
                         laterExtreme > level + tick * sweepTicks :
                         laterExtreme < level - tick * sweepTicks
                    if consumed
                        untouched := false
                        break

    untouched

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SMT SIGNAL ENGINE — FIXED 12 STATES, NO UNBOUNDED HISTORY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
signalIndex(int family, bool bullish) =>
    family * 2 + (bullish ? 1 : 0)

clearSignalAt(int idx) =>
    SmtSignal s = array.get(smtSignals, idx)
    if not na(s.ln)
        line.delete(s.ln)
    if not na(s.lb)
        label.delete(s.lb)
    s.ln := na
    s.lb := na
    s.active := false
    s.confirmed := false
    s.eventKey := na
    s.mask := 0
    s.t1 := na
    s.t2 := na
    s.y1 := na
    s.y2 := na
    s.invalidLevel := na
    s.lastUpdateT := na
    true

familyPriority(int family) =>
    // Sessions outrank cycle families. Inside cycle families, duration defines priority.
    family == 0 ? 1440 : family == 1 ? 1441 : familyDurationMinutes(family)

mergeMarketMasks(int left, int right) =>
    left == 0 ? right : right == 0 ? left : left == right ? left : 3

sameSmtAnchors(SmtSignal left, SmtSignal right) =>
    float tolerance = syminfo.mintick * duplicateSmtPriceTicks
    left.active and right.active and
         not na(left.t1) and not na(left.t2) and not na(right.t1) and not na(right.t2) and
         not na(left.y1) and not na(left.y2) and not na(right.y1) and not na(right.y2) and
         left.t1 == right.t1 and left.t2 == right.t2 and
         math.abs(left.y1 - right.y1) <= tolerance and
         math.abs(left.y2 - right.y2) <= tolerance

smtDisplayInfo(int family, bool bullish) =>
    int idx = signalIndex(family, bullish)
    SmtSignal current = array.get(smtSignals, idx)
    bool suppressed = false
    int mergedMask = current.mask
    int currentPriority = familyPriority(family)

    if higherTfWinsSameSmt and current.active
        for otherFamily = 0 to 5
            if otherFamily != family
                SmtSignal other = array.get(smtSignals, signalIndex(otherFamily, bullish))
                if sameSmtAnchors(current, other)
                    mergedMask := mergeMarketMasks(mergedMask, other.mask)
                    int otherPriority = familyPriority(otherFamily)
                    if otherPriority > currentPriority or (otherPriority == currentPriority and otherFamily > family)
                        suppressed := true

    [suppressed, mergedMask]

refreshSignal(int family, bool bullish) =>
    int idx = signalIndex(family, bullish)
    SmtSignal s = array.get(smtSignals, idx)
    [suppressed, displayMask] = smtDisplayInfo(family, bullish)

    if suppressed
        // Keep the logical state, but remove its drawings. It can reappear if the
        // higher-timeframe duplicate is later invalidated or expires.
        if not na(s.ln)
            line.delete(s.ln)
            s.ln := na
        if not na(s.lb)
            label.delete(s.lb)
            s.lb := na
    else if s.active and s.mask > 0 and not na(s.t1) and not na(s.t2) and s.t2 > s.t1
        color base = bullish ? bullColor : bearColor
        color col = s.confirmed ? base : color.new(base, liveTransparency)
        int smtWidth = s.confirmed ? confirmedSmtWidth : liveSmtWidth
        if na(s.ln)
            s.ln := line.new(s.t1, s.y1, s.t2, s.y2,
                 xloc = xloc.bar_time, color = col, width = smtWidth, style = line.style_solid)
        else
            line.set_xy1(s.ln, s.t1, s.y1)
            line.set_xy2(s.ln, s.t2, s.y2)
            line.set_color(s.ln, col)
            line.set_width(s.ln, smtWidth)
            line.set_style(s.ln, line.style_solid)

        bool showLb = familyShowsLabel(family)
        if showLb
            int midT = int(math.round((s.t1 + s.t2) / 2.0))
            float midY = (s.y1 + s.y2) / 2.0
            string txt = familyText(family) + " " + maskText(displayMask)
            if na(s.lb)
                s.lb := label.new(midT, midY, txt, xloc = xloc.bar_time,
                     style = label.style_none, color = color.new(col, 100),
                     textcolor = col, size = smtSize(), textalign = text.align_center)
            else
                label.set_xy(s.lb, midT, midY)
                label.set_text(s.lb, txt)
                label.set_style(s.lb, label.style_none)
                label.set_color(s.lb, color.new(col, 100))
                label.set_textcolor(s.lb, col)
                label.set_size(s.lb, smtSize())
        else if not na(s.lb)
            label.delete(s.lb)
            s.lb := na
    true

refreshAllSignals() =>
    for family = 0 to 5
        refreshSignal(family, false)
        refreshSignal(family, true)
    true


setSignal(int family, bool bullish, int eventKey, int mask,
     int t1, float y1, int t2, float y2, bool finalized, float invalidLevel, int updateT) =>
    int idx = signalIndex(family, bullish)
    int oppositeIdx = signalIndex(family, not bullish)
    SmtSignal s = array.get(smtSignals, idx)

    if mask > 0 and familyEnabled(family)
        bool newEvent = not s.active or s.eventKey != eventKey
        if newEvent
            clearSignalAt(idx)
            clearSignalAt(oppositeIdx)
            s := array.get(smtSignals, idx)
            s.active := true
            s.confirmed := false
            s.eventKey := eventKey

        bool wasConfirmed = s.confirmed
        s.mask := mask
        s.t1 := t1
        s.y1 := y1
        s.t2 := t2
        s.y2 := y2
        s.invalidLevel := invalidLevel
        s.lastUpdateT := updateT
        s.confirmed := finalized or s.confirmed
        refreshAllSignals()

        if finalized and not wasConfirmed
            if family <= 1
                array.set(alertFlags, bullish ? 1 : 0, true)
            else
                array.set(alertFlags, bullish ? 3 : 2, true)
    else if s.active and not s.confirmed and s.eventKey == eventKey
        clearSignalAt(idx)
        refreshAllSignals()
    true

evaluateRanges(int family, int eventKey, RangeState current, RangeState reference, bool finalized, int updateT) =>
    if familyEnabled(family) and not na(eventKey) and rangeReadyAB(current) and rangeReadyAB(reference)
        bool aHH = current.aH > reference.aH + syminfo.mintick * sweepTicks
        bool aLL = current.aL < reference.aL - syminfo.mintick * sweepTicks
        bool bHH = current.bH > reference.bH + bTick * sweepTicks
        bool bLL = current.bL < reference.bL - bTick * sweepTicks

        bool cReady = rangeReadyC(current) and rangeReadyC(reference)
        bool cHH = cReady and current.cH > reference.cH + cTick * sweepTicks
        bool cLL = cReady and current.cL < reference.cL - cTick * sweepTicks

        bool bearAB = (aHH != bHH) and (aHH or bHH)
        bool bullAB = (aLL != bLL) and (aLL or bLL)
        bool bearAC = cReady and (aHH != cHH) and (aHH or cHH)
        bool bullAC = cReady and (aLL != cLL) and (aLL or cLL)

        int bearMask = (bearAB ? 1 : 0) + (bearAC ? 2 : 0)
        int bullMask = (bullAB ? 1 : 0) + (bullAC ? 2 : 0)

        if rejectTwoSidedSmt and bearMask > 0 and bullMask > 0
            bearMask := 0
            bullMask := 0

        bool allowLive = finalized or showLiveSmt
        if allowLive
            setSignal(family, false, eventKey, bearMask,
                 reference.aHt, reference.aH, current.aHt, current.aH,
                 finalized, current.aH, updateT)
            setSignal(family, true, eventKey, bullMask,
                 reference.aLt, reference.aL, current.aLt, current.aL,
                 finalized, current.aL, updateT)
    true


evaluateCycleHistory(int family, int eventKey, RangeState current,
     array<RangeState> history, bool finalized, int updateT) =>
    int bearReferenceIndex = -1
    int bullReferenceIndex = -1
    int bearMask = 0
    int bullMask = 0

    int count = array.size(history)
    if familyEnabled(family) and not na(eventKey) and count > 0 and rangeReadyAB(current)
        int currentDay = cycleDayFromKey(current.key)

        // Search from newest to oldest. The first valid reference is the nearest
        // still-untouched cycle liquidity, not necessarily the immediately prior cycle.
        for step = 0 to count - 1
            int i = count - 1 - step
            RangeState reference = array.get(history, i)

            if reference.complete and cycleDayFromKey(reference.key) == currentDay and rangeReadyAB(reference)
                bool aHighValid = cycleReferenceUntouched(history, i, 0, true)
                bool bHighValid = cycleReferenceUntouched(history, i, 1, true)
                bool aLowValid = cycleReferenceUntouched(history, i, 0, false)
                bool bLowValid = cycleReferenceUntouched(history, i, 1, false)

                bool aHH = aHighValid and current.aH > reference.aH + syminfo.mintick * sweepTicks
                bool bHH = bHighValid and current.bH > reference.bH + bTick * sweepTicks
                bool aLL = aLowValid and current.aL < reference.aL - syminfo.mintick * sweepTicks
                bool bLL = bLowValid and current.bL < reference.bL - bTick * sweepTicks

                bool bearAB = aHighValid and bHighValid and (aHH != bHH) and (aHH or bHH)
                bool bullAB = aLowValid and bLowValid and (aLL != bLL) and (aLL or bLL)

                bool cReady = rangeReadyC(current) and rangeReadyC(reference)
                bool cHighValid = cReady and cycleReferenceUntouched(history, i, 2, true)
                bool cLowValid = cReady and cycleReferenceUntouched(history, i, 2, false)
                bool cHH = cHighValid and current.cH > reference.cH + cTick * sweepTicks
                bool cLL = cLowValid and current.cL < reference.cL - cTick * sweepTicks
                bool bearAC = cReady and aHighValid and cHighValid and (aHH != cHH) and (aHH or cHH)
                bool bullAC = cReady and aLowValid and cLowValid and (aLL != cLL) and (aLL or cLL)

                int candidateBearMask = (bearAB ? 1 : 0) + (bearAC ? 2 : 0)
                int candidateBullMask = (bullAB ? 1 : 0) + (bullAC ? 2 : 0)

                if bearReferenceIndex == -1 and candidateBearMask > 0
                    bearReferenceIndex := i
                    bearMask := candidateBearMask

                if bullReferenceIndex == -1 and candidateBullMask > 0
                    bullReferenceIndex := i
                    bullMask := candidateBullMask

                if bearReferenceIndex >= 0 and bullReferenceIndex >= 0
                    break

        if rejectTwoSidedSmt and bearMask > 0 and bullMask > 0
            bearMask := 0
            bullMask := 0
            bearReferenceIndex := -1
            bullReferenceIndex := -1

        bool allowLive = finalized or showLiveSmt
        if allowLive
            if bearReferenceIndex >= 0
                RangeState bearReference = array.get(history, bearReferenceIndex)
                setSignal(family, false, eventKey, bearMask,
                     bearReference.aHt, bearReference.aH, current.aHt, current.aH,
                     finalized, current.aH, updateT)
            else
                setSignal(family, false, eventKey, 0, na, na, na, na,
                     finalized, na, updateT)

            if bullReferenceIndex >= 0
                RangeState bullReference = array.get(history, bullReferenceIndex)
                setSignal(family, true, eventKey, bullMask,
                     bullReference.aLt, bullReference.aL, current.aLt, current.aL,
                     finalized, current.aL, updateT)
            else
                setSignal(family, true, eventKey, 0, na, na, na, na,
                     finalized, na, updateT)

    true

cleanupSignals(int t, float aClose) =>
    bool changed = false
    if not na(aClose)
        for family = 0 to 5
            for direction = 0 to 1
                bool bullish = direction == 1
                int idx = signalIndex(family, bullish)
                SmtSignal s = array.get(smtSignals, idx)
                if s.active and s.confirmed
                    int lifeMinutes = familyDurationMinutes(family) * confirmedLifeMultiplier
                    bool stale = not na(s.lastUpdateT) and t - s.lastUpdateT > lifeMinutes * MS_MINUTE
                    float buffer = syminfo.mintick * invalidBufferTicks
                    bool invalid = removeInvalidatedSmt and not na(s.invalidLevel) and (bullish ? aClose < s.invalidLevel - buffer : aClose > s.invalidLevel + buffer)
                    if stale or invalid
                        clearSignalAt(idx)
                        changed := true
    if changed
        refreshAllSignals()
    true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION WINDOWS / VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sessionWindow(int t, int idx) =>
    int h = hour(t, TZ)
    int m = minute(t, TZ)
    int mod = h * 60 + m
    bool inside = false
    int key = na
    int startT = na
    int endT = na

    if idx == 0
        inside := mod >= 1080 or mod < 150
        if inside
            if mod >= 1080
                int nextT = t + 12 * MS_HOUR
                startT := timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 18, 0)
                endT := timestamp(TZ, year(nextT, TZ), month(nextT, TZ), dayofmonth(nextT, TZ), 2, 30)
                key := nyDayKey(nextT)
            else
                int prevT = t - 12 * MS_HOUR
                startT := timestamp(TZ, year(prevT, TZ), month(prevT, TZ), dayofmonth(prevT, TZ), 18, 0)
                endT := timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 2, 30)
                key := nyDayKey(t)
    else if idx == 1
        inside := mod >= 150 and mod < 420
        if inside
            startT := timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 2, 30)
            endT := timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 7, 0)
            key := nyDayKey(t)
    else
        inside := mod >= 420 and mod < 960
        if inside
            startT := timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 7, 0)
            endT := timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 16, 0)
            key := nyDayKey(t)

    [inside, key, startT, endT]

startSessionVisuals(RangeState s, int idx, int rightT) =>
    color col = sessionColor(idx)
    color levelCol = color.new(col, sessionLevelTransparency)
    if showSessionBoxes
        s.bx := box.new(s.startT, s.aH, math.min(rightT, s.endT), s.aL,
             xloc = xloc.bar_time, border_color = color.new(col, sessionBorderTransparency),
             border_width = 1, bgcolor = color.new(col, sessionBoxTransparency))
        s.nameLb := showSessionLabels ? label.new(s.startT, s.aH, sessionName(idx),
             xloc = xloc.bar_time, style = label.style_label_down,
             color = color.new(col, 20), textcolor = color.white, size = size.small) : na
        registerSessionVisual(s.bx, s.nameLb)
    else
        s.bx := na
        s.nameLb := na

    s.hiLine := showSessionHighs ? line.new(s.aHt, s.aH, math.min(rightT, s.endT), s.aH,
         xloc = xloc.bar_time, color = levelCol, width = 1) : na
    s.loLine := showSessionLows ? line.new(s.aLt, s.aL, math.min(rightT, s.endT), s.aL,
         xloc = xloc.bar_time, color = levelCol, width = 1) : na
    s.hiLb := showSessionHighs and showSessionLevelLabels ? label.new(math.min(rightT, s.endT), s.aH, sessionHighName(idx),
         xloc = xloc.bar_time, style = label.style_label_left,
         color = color.new(levelCol, 100), textcolor = levelCol, size = size.tiny) : na
    s.loLb := showSessionLows and showSessionLevelLabels ? label.new(math.min(rightT, s.endT), s.aL, sessionLowName(idx),
         xloc = xloc.bar_time, style = label.style_label_left,
         color = color.new(levelCol, 100), textcolor = levelCol, size = size.tiny) : na
    true

updateSessionVisuals(RangeState s, int idx, int rightT) =>
    int x2 = math.min(rightT, s.endT)
    if not na(s.bx)
        box.set_right(s.bx, x2)
        box.set_top(s.bx, s.aH)
        box.set_bottom(s.bx, s.aL)
    if not na(s.nameLb)
        label.set_xy(s.nameLb, int(math.round((s.startT + x2) / 2.0)), s.aH)
    if not na(s.hiLine)
        line.set_xy1(s.hiLine, s.aHt, s.aH)
        line.set_xy2(s.hiLine, x2, s.aH)
    if not na(s.loLine)
        line.set_xy1(s.loLine, s.aLt, s.aL)
        line.set_xy2(s.loLine, x2, s.aL)
    if not na(s.hiLb)
        label.set_xy(s.hiLb, x2, s.aH)
    if not na(s.loLb)
        label.set_xy(s.loLb, x2, s.aL)
    true

finalizeSession(RangeState s, int idx) =>
    s.active := false
    s.complete := true
    s.seq += 1
    updateSessionVisuals(s, idx, s.endT)
    if not na(s.hiLine)
        registerSessionLevel(s.hiLine, s.hiLb, s.aH, true, sessionHighName(idx))
    if not na(s.loLine)
        registerSessionLevel(s.loLine, s.loLb, s.aL, false, sessionLowName(idx))
    s.hiLine := na
    s.loLine := na
    s.hiLb := na
    s.loLb := na
    true

processSessionLevelsBase(int t, int rightT, float aH, float aL) =>
    int count = array.size(sessionLevelLines)
    if count > 0
        for step = 0 to count - 1
            int i = count - 1 - step
            if array.get(sessionLevelActive, i)
                line ln = array.get(sessionLevelLines, i)
                label lb = array.get(sessionLevelLabels, i)
                float price = array.get(sessionLevelPrices, i)
                bool isHigh = array.get(sessionLevelIsHigh, i)
                bool swept = isHigh ? aH >= price : aL <= price
                int endT = swept ? t : rightT
                line.set_x2(ln, endT)
                if not na(lb)
                    label.set_xy(lb, endT, price)
                if swept
                    array.set(sessionLevelActive, i, false)
                    if not keepSweptSessionLevels
                        line.delete(ln)
                        if not na(lb)
                            label.delete(lb)
                        array.remove(sessionLevelLines, i)
                        array.remove(sessionLevelLabels, i)
                        array.remove(sessionLevelPrices, i)
                        array.remove(sessionLevelIsHigh, i)
                        array.remove(sessionLevelActive, i)
                        array.remove(sessionLevelNames, i)
    true

processSessions(int t, int rightT,
     float aH, float aL, float bH, float bL, float cH, float cL) =>
    for idx = 0 to 2
        RangeState s = array.get(sessions, idx)
        [inside, key, startT, endT] = sessionWindow(t, idx)

        if inside
            bool newInstance = not s.active or s.key != key
            if newInstance
                if s.active
                    finalizeSession(s, idx)
                resetRange(s, key, startT, endT, t, aH, aL, bH, bL, cH, cL)
                if idx == 1
                    clearSignalAt(signalIndex(0, false))
                    clearSignalAt(signalIndex(0, true))
                if idx == 2
                    clearSignalAt(signalIndex(1, false))
                    clearSignalAt(signalIndex(1, true))
                startSessionVisuals(s, idx, rightT)
            else
                updateRange(s, t, aH, aL, bH, bL, cH, cL)
                updateSessionVisuals(s, idx, rightT)
        else if s.active and t >= s.endT
            finalizeSession(s, idx)

    RangeState asia = array.get(sessions, 0)
    RangeState london = array.get(sessions, 1)
    RangeState newYork = array.get(sessions, 2)

    if london.active and asia.complete and london.key == asia.key
        evaluateRanges(0, london.key, london, asia, false, t)
    if newYork.active and london.complete and newYork.key == london.key
        evaluateRanges(1, newYork.key, newYork, london, false, t)

    // Confirm exactly once on the first feed bar after the session boundary.
    if london.complete and not london.active and t == london.endT
        evaluateRanges(0, london.key, london, asia, true, t)
    if newYork.complete and not newYork.active and t == newYork.endT
        evaluateRanges(1, newYork.key, newYork, london, true, t)

    // A newly started session can clear a dominant session SMT. Re-evaluate all
    // fixed states so a still-valid lower-timeframe duplicate can reappear.
    refreshAllSignals()
    true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CYCLE WINDOWS / VISUALS / SMT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cycleWindow(int t, int minutes) =>
    int mod = hour(t, TZ) * 60 + minute(t, TZ)
    bool inside = mod >= 150 and mod < 960
    int key = na
    int startT = na
    int endT = na
    int idx = na
    if inside
        int fromStart = mod - 150
        idx := int(math.floor(float(fromStart) / float(minutes)))
        int baseT = timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 2, 30)
        startT := baseT + idx * minutes * MS_MINUTE
        endT := startT + minutes * MS_MINUTE
        key := nyDayKey(t) * 1000 + idx
    [inside, key, startT, endT, idx]

cycleShowsBox(int cycleArrayIdx) =>
    cycleArrayIdx == 0 ? show10Boxes : cycleArrayIdx == 1 ? show30Boxes : cycleArrayIdx == 2 ? show90Boxes : show270Boxes

cycleFamily(int cycleArrayIdx) =>
    cycleArrayIdx + 2

cycleRole(int cycleArrayIdx, int idx) =>
    cycleArrayIdx == 3 ? -1 : phaseRole(idx % 3)

cycleBoxColor(int cycleArrayIdx, int idx) =>
    cycleArrayIdx == 3 ? cycle270Color : phaseColor(cycleRole(cycleArrayIdx, idx))

cycleFillTransparency(int cycleArrayIdx) =>
    cycleArrayIdx == 0 ? fill10Transparency : cycleArrayIdx == 1 ? fill30Transparency : cycleArrayIdx == 2 ? fill90Transparency : fill270Transparency

cycleText(int cycleArrayIdx, int idx) =>
    not showCycleText ? "" : cycleArrayIdx == 3 ? "270" : phaseShort(cycleRole(cycleArrayIdx, idx))

startCycleVisual(CycleState cs, int cycleArrayIdx, int rightT) =>
    if showCycles and cycleShowsBox(cycleArrayIdx)
        color col = cycleBoxColor(cycleArrayIdx, cs.cycleIndex)
        string txt = cycleText(cycleArrayIdx, cs.cycleIndex)
        cs.bx := box.new(cs.cur.startT, cs.cur.aH, math.min(rightT, cs.cur.endT), cs.cur.aL,
             xloc = xloc.bar_time, border_color = color.new(col, cycleBorderTransparency),
             border_width = 1, border_style = line.style_solid,
             bgcolor = color.new(col, cycleFillTransparency(cycleArrayIdx)),
             text = txt, text_color = color.new(color.white, 5), text_size = size.tiny,
             text_halign = text.align_center, text_valign = text.align_center)
        cs.lb := na
        registerCycleVisual(cs.bx, cs.lb)
    else
        cs.bx := na
        cs.lb := na
    true

updateCycleVisual(CycleState cs, int rightT) =>
    if not na(cs.bx)
        box.set_right(cs.bx, math.min(rightT, cs.cur.endT))
        box.set_top(cs.bx, cs.cur.aH)
        box.set_bottom(cs.bx, cs.cur.aL)
    true

finalizeCycle(CycleState cs, int cycleArrayIdx, int t) =>
    if cs.cur.active
        int family = cycleFamily(cycleArrayIdx)

        // Evaluate against the newest still-valid reference anywhere in the
        // bounded same-day history, then archive this completed cycle.
        evaluateCycleHistory(family, cs.cur.key, cs.cur, cs.history, true, t)

        cs.cur.active := false
        cs.cur.complete := true
        cs.cur.seq += 1
        updateCycleVisual(cs, cs.cur.endT)
        pushCycleHistory(cs)
    true

processCycle(CycleState cs, int cycleArrayIdx, int t, int rightT,
     float aH, float aL, float bH, float bL, float cH, float cL) =>
    [inside, key, startT, endT, idx] = cycleWindow(t, cs.minutes)

    if inside
        bool newCycleBar = not cs.cur.active or cs.cur.key != key
        if newCycleBar
            if cs.cur.active
                finalizeCycle(cs, cycleArrayIdx, t)

            // Time-cycle SMT is intraday. Remove prior-day references before
            // starting the first cycle of the new New York trading day.
            pruneCycleHistoryToDay(cs, key)

            resetRange(cs.cur, key, startT, endT, t, aH, aL, bH, bL, cH, cL)
            cs.cycleIndex := idx
            startCycleVisual(cs, cycleArrayIdx, rightT)
        else
            updateRange(cs.cur, t, aH, aL, bH, bL, cH, cL)
            updateCycleVisual(cs, rightT)

        if array.size(cs.history) > 0
            evaluateCycleHistory(cycleFamily(cycleArrayIdx), cs.cur.key,
                 cs.cur, cs.history, false, t)
    else if cs.cur.active and t >= cs.cur.endT
        finalizeCycle(cs, cycleArrayIdx, t)
    true

processCycles(int t, int rightT,
     float aH, float aL, float bH, float bL, float cH, float cL) =>
    // Keep the corrected z-order while using the classic v17.3 fills:
    // 270m → 90m → 30m → 10m. The stronger 30m tint remains visible on top
    // without thick, dotted, or dashed borders.
    for step = 0 to 3
        int i = 3 - step
        CycleState cs = array.get(cycles, i)
        processCycle(cs, i, t, rightT, aH, aL, bH, bL, cH, cL)
    true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 18:00 DAILY OPEN / 00:00 / 08:30 / 09:30 — CANONICAL FEED
// 18:00 New York is the futures electronic-session restart and the ICT daily
// open anchor. Midnight remains a separate reference.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool show1800 = input.bool(true, "Show 18:00 Daily Open", group = "Time Levels")
bool show0000 = input.bool(true, "Show 00:00 level", group = "Time Levels")
bool show0830 = input.bool(true, "Show 08:30 level", group = "Time Levels")
bool show0930 = input.bool(true, "Show 09:30 level", group = "Time Levels")
color color1800 = input.color(color.new(#D4A373, 10), "18:00 Daily Open", group = "Time Levels • Colors")
color color0000 = input.color(color.new(#A3A3A3, 25), "00:00", group = "Time Levels • Colors")
color color0830 = input.color(color.new(#FBBF24, 15), "08:30", group = "Time Levels • Colors")
color color0930 = input.color(color.new(#A78BFA, 10), "09:30", group = "Time Levels • Colors")

clearTimeLevel(line ln, label lb) =>
    if not na(ln)
        line.delete(ln)
    if not na(lb)
        label.delete(lb)
    true

processTimeLevels(TimeLevelState s, int t, int rightT, float aO) =>
    int dayKey = nyDayKey(t)
    if na(s.dayKey) or dayKey != s.dayKey
        clearTimeLevel(s.line0000, s.lb0000)
        clearTimeLevel(s.line0830, s.lb0830)
        clearTimeLevel(s.line0930, s.lb0930)
        s.line0000 := na
        s.line0830 := na
        s.line0930 := na
        s.lb0000 := na
        s.lb0830 := na
        s.lb0930 := na
        s.price0000 := na
        s.price0830 := na
        s.price0930 := na
        s.dayKey := dayKey

    int event1800 = timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 18, 0)
    int event0000 = timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 0, 0)
    int event0830 = timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 8, 30)
    int event0930 = timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 9, 30)

    bool hit1800 = t <= event1800 and rightT > event1800
    bool hit0000 = t <= event0000 and rightT > event0000
    bool hit0830 = t <= event0830 and rightT > event0830
    bool hit0930 = t <= event0930 and rightT > event0930

    if show1800 and hit1800 and (na(s.event1800) or s.event1800 != event1800)
        clearTimeLevel(s.line1800, s.lb1800)
        s.event1800 := event1800
        s.price1800 := aO
        s.line1800 := line.new(event1800, aO, rightT, aO, xloc = xloc.bar_time,
             color = color1800, width = 1, style = line.style_dashed)
        s.lb1800 := label.new(rightT, aO, "DO", xloc = xloc.bar_time,
             style = label.style_label_left, color = color.new(color1800, 100),
             textcolor = color1800, size = size.small)

    if show0000 and hit0000 and na(s.line0000)
        s.price0000 := aO
        s.line0000 := line.new(event0000, aO, rightT, aO, xloc = xloc.bar_time,
             color = color0000, width = 1, style = line.style_dashed)
        s.lb0000 := label.new(rightT, aO, "00:00", xloc = xloc.bar_time,
             style = label.style_label_left, color = color.new(color0000, 100),
             textcolor = color0000, size = size.small)

    if show0830 and hit0830 and na(s.line0830)
        s.price0830 := aO
        s.line0830 := line.new(event0830, aO, rightT, aO, xloc = xloc.bar_time,
             color = color0830, width = 1, style = line.style_dashed)
        s.lb0830 := label.new(rightT, aO, "08:30", xloc = xloc.bar_time,
             style = label.style_label_left, color = color.new(color0830, 100),
             textcolor = color0830, size = size.small)

    if show0930 and hit0930 and na(s.line0930)
        s.price0930 := aO
        s.line0930 := line.new(event0930, aO, rightT, aO, xloc = xloc.bar_time,
             color = color0930, width = 1, style = line.style_dashed)
        s.lb0930 := label.new(rightT, aO, "09:30", xloc = xloc.bar_time,
             style = label.style_label_left, color = color.new(color0930, 100),
             textcolor = color0930, size = size.small)

    if not na(s.line1800)
        line.set_x2(s.line1800, rightT)
        label.set_xy(s.lb1800, rightT, s.price1800)
    if not na(s.line0000)
        line.set_x2(s.line0000, rightT)
        label.set_xy(s.lb0000, rightT, s.price0000)
    if not na(s.line0830)
        line.set_x2(s.line0830, rightT)
        label.set_xy(s.lb0830, rightT, s.price0830)
    if not na(s.line0930)
        line.set_x2(s.line0930, rightT)
        label.set_xy(s.lb0930, rightT, s.price0930)
    true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ICT NEW DAY / NEW WEEK OPENING GAPS
// NDOG: prior 17:00 futures close -> 18:00 reopen, Monday-Thursday evenings.
// NWOG: Friday 17:00 close -> Sunday 18:00 reopen.
// Each gap includes its boundaries and Consequent Encroachment (50%).
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showNDOG = input.bool(true, "Show New Day Opening Gaps", group = "Opening Gaps")
bool showNWOG = input.bool(true, "Show New Week Opening Gaps", group = "Opening Gaps")
bool showGapCE = input.bool(true, "Show CE (50%)", group = "Opening Gaps")
bool showGapQuadrants = input.bool(false, "Show 25% / 75%", group = "Opening Gaps")
bool dimFilledGaps = input.bool(true, "Fade fully filled gaps", group = "Opening Gaps")
int keepNDOG = input.int(5, "NDOGs retained", minval = 1, maxval = 20, group = "Opening Gaps")
int keepNWOG = input.int(5, "NWOGs retained", minval = 1, maxval = 20, group = "Opening Gaps")
int minOpeningGapTicks = input.int(1, "Minimum gap size (ticks)", minval = 0, maxval = 100, group = "Opening Gaps")
color ndogColor = input.color(color.new(#94A3B8, 0), "NDOG", group = "Opening Gaps • Colors")
color nwogColor = input.color(color.new(#C4B5FD, 0), "NWOG", group = "Opening Gaps • Colors")
int openingGapFillTransparency = input.int(94, "Gap fill transparency", minval = 80, maxval = 100, group = "Opening Gaps • Style")

openingGapColor(int kind) =>
    kind == 1 ? nwogColor : ndogColor

openingGapText(int kind) =>
    kind == 1 ? "NWOG" : "NDOG"

deleteOpeningGap(OpeningGap g) =>
    if not na(g.bx)
        box.delete(g.bx)
    if not na(g.hiLn)
        line.delete(g.hiLn)
    if not na(g.loLn)
        line.delete(g.loLn)
    if not na(g.ceLn)
        line.delete(g.ceLn)
    if not na(g.q25Ln)
        line.delete(g.q25Ln)
    if not na(g.q75Ln)
        line.delete(g.q75Ln)
    if not na(g.lb)
        label.delete(g.lb)
    true

countOpeningGaps(int kind) =>
    int result = 0
    int count = array.size(openingGaps)
    if count > 0
        for i = 0 to count - 1
            OpeningGap g = array.get(openingGaps, i)
            if g.kind == kind
                result += 1
    result

trimOpeningGaps(int kind, int maxCount) =>
    while countOpeningGaps(kind) > maxCount
        int removeIndex = -1
        int count = array.size(openingGaps)
        if count > 0
            for i = 0 to count - 1
                if removeIndex == -1
                    OpeningGap candidate = array.get(openingGaps, i)
                    if candidate.kind == kind
                        removeIndex := i
        if removeIndex >= 0
            OpeningGap dead = array.get(openingGaps, removeIndex)
            deleteOpeningGap(dead)
            array.remove(openingGaps, removeIndex)
        else
            break
    true

createOpeningGap(int kind, int startT, int rightT, float priorClose, float newOpen) =>
    bool enabled = kind == 1 ? showNWOG : showNDOG
    float minSize = syminfo.mintick * minOpeningGapTicks
    float distance = math.abs(newOpen - priorClose)
    if enabled and not na(priorClose) and not na(newOpen) and distance >= minSize and distance > 0
        color col = openingGapColor(kind)
        float top = math.max(priorClose, newOpen)
        float bottom = math.min(priorClose, newOpen)
        float ce = (top + bottom) / 2.0
        float q25 = bottom + (top - bottom) * 0.25
        float q75 = bottom + (top - bottom) * 0.75

        OpeningGap g = OpeningGap.new(
             kind = kind, startT = startT,
             closePrice = priorClose, openPrice = newOpen,
             top = top, bottom = bottom, ce = ce, q25 = q25, q75 = q75,
             upGap = newOpen > priorClose, filled = false)

        g.bx := box.new(startT, top, rightT, bottom, xloc = xloc.bar_time,
             border_color = color.new(col, 35), border_width = 1,
             bgcolor = color.new(col, openingGapFillTransparency))
        g.hiLn := line.new(startT, top, rightT, top, xloc = xloc.bar_time,
             color = color.new(col, 15), width = 1, style = line.style_solid)
        g.loLn := line.new(startT, bottom, rightT, bottom, xloc = xloc.bar_time,
             color = color.new(col, 15), width = 1, style = line.style_solid)
        g.ceLn := showGapCE ? line.new(startT, ce, rightT, ce, xloc = xloc.bar_time,
             color = col, width = 1, style = line.style_dashed) : na
        g.q25Ln := showGapQuadrants ? line.new(startT, q25, rightT, q25, xloc = xloc.bar_time,
             color = color.new(col, 55), width = 1, style = line.style_dotted) : na
        g.q75Ln := showGapQuadrants ? line.new(startT, q75, rightT, q75, xloc = xloc.bar_time,
             color = color.new(col, 55), width = 1, style = line.style_dotted) : na
        g.lb := label.new(rightT, ce, openingGapText(kind), xloc = xloc.bar_time,
             style = label.style_none, color = color.new(col, 100),
             textcolor = col, size = size.tiny, textalign = text.align_left)

        array.push(openingGaps, g)
        trimOpeningGaps(kind, kind == 1 ? keepNWOG : keepNDOG)
    true

updateOpeningGaps(int rightT, float aH, float aL) =>
    int count = array.size(openingGaps)
    if count > 0
        for i = 0 to count - 1
            OpeningGap g = array.get(openingGaps, i)
            if not na(g.bx)
                box.set_right(g.bx, rightT)
            if not na(g.hiLn)
                line.set_x2(g.hiLn, rightT)
            if not na(g.loLn)
                line.set_x2(g.loLn, rightT)
            if not na(g.ceLn)
                line.set_x2(g.ceLn, rightT)
            if not na(g.q25Ln)
                line.set_x2(g.q25Ln, rightT)
            if not na(g.q75Ln)
                line.set_x2(g.q75Ln, rightT)
            if not na(g.lb)
                label.set_xy(g.lb, rightT, g.ce)

            if not g.filled
                bool fullFill = g.upGap ? aL <= g.closePrice : aH >= g.closePrice
                if fullFill
                    g.filled := true
                    if dimFilledGaps
                        color col = openingGapColor(g.kind)
                        if not na(g.bx)
                            box.set_bgcolor(g.bx, color.new(col, 98))
                            box.set_border_color(g.bx, color.new(col, 82))
                        if not na(g.hiLn)
                            line.set_color(g.hiLn, color.new(col, 75))
                        if not na(g.loLn)
                            line.set_color(g.loLn, color.new(col, 75))
                        if not na(g.ceLn)
                            line.set_color(g.ceLn, color.new(col, 62))
                        if not na(g.q25Ln)
                            line.set_color(g.q25Ln, color.new(col, 88))
                        if not na(g.q75Ln)
                            line.set_color(g.q75Ln, color.new(col, 88))
                        if not na(g.lb)
                            label.set_textcolor(g.lb, color.new(col, 65))
    true

processOpeningGapFeed(OpeningGapEngine state, int t, int rightT,
     float aO, float aH, float aL, float aC) =>
    int event1700 = timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 17, 0)
    int event1800 = timestamp(TZ, year(t, TZ), month(t, TZ), dayofmonth(t, TZ), 18, 0)

    bool closesAt1700 = t < event1700 and rightT >= event1700
    if closesAt1700
        state.last1700Close := aC
        state.last1700T := event1700

    bool opensAt1800 = t <= event1800 and rightT > event1800
    if opensAt1800 and (na(state.lastOpenEvent) or state.lastOpenEvent != event1800)
        int dow = dayofweek(event1800, TZ)
        bool isNwog = dow == dayofweek.sunday
        bool isNdog = dow >= dayofweek.monday and dow <= dayofweek.thursday
        int maxAge = isNwog ? 72 * MS_HOUR : 2 * MS_HOUR
        bool closeValid = not na(state.last1700Close) and not na(state.last1700T) and
             event1800 > state.last1700T and event1800 - state.last1700T <= maxAge

        if closeValid and (isNwog or isNdog)
            createOpeningGap(isNwog ? 1 : 0, event1800, rightT,
                 state.last1700Close, aO)
        state.lastOpenEvent := event1800

    updateOpeningGaps(rightT, aH, aL)
    true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANONICAL FEED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
processFeedBar(int t, float aO, float aH, float aL, float aC,
     float bH, float bL, float cH, float cL) =>
    if engineEnabled and not na(t) and not na(aH) and not na(aL)
        int rightT = feedRightTime(t)
        processSessions(t, rightT, aH, aL, bH, bL, cH, cL)
        processSessionLevelsBase(t, rightT, aH, aL)
        processCycles(t, rightT, aH, aL, bH, bL, cH, cL)
        processTimeLevels(timeLevels, t, rightT, aO)
        processOpeningGapFeed(openingGapEngine, t, rightT, aO, aH, aL, aC)
        cleanupSignals(t, aC)
    true

var int lastCanonicalT = na
var int firstCanonicalT = na

if engineEnabled
    if useIntrabars
        int countA = array.size(aTimes1)
        int countB = array.size(bTimes1)
        int countC = array.size(cTimes1)

        if countA > 0
            // The arrays are time-sorted. Two moving pointers avoid repeatedly
            // scanning B/C arrays from the beginning for every A intrabar.
            int bPtr = 0
            int cPtr = 0

            for i = 0 to countA - 1
                int t1 = array.get(aTimes1, i)

                while bPtr < countB and array.get(bTimes1, bPtr) < t1
                    bPtr += 1
                while cPtr < countC and array.get(cTimes1, cPtr) < t1
                    cPtr += 1

                bool bMatch = bPtr < countB and array.get(bTimes1, bPtr) == t1
                bool cMatch = cPtr < countC and array.get(cTimes1, cPtr) == t1

                if na(lastCanonicalT) or t1 >= lastCanonicalT
                    float bH1 = bMatch ? array.get(bHighs1, bPtr) : na
                    float bL1 = bMatch ? array.get(bLows1, bPtr) : na
                    float cH1 = useC and cMatch ? array.get(cHighs1, cPtr) : na
                    float cL1 = useC and cMatch ? array.get(cLows1, cPtr) : na

                    processFeedBar(t1,
                         array.get(aOpens1, i), array.get(aHighs1, i),
                         array.get(aLows1, i), array.get(aCloses1, i),
                         bH1, bL1, cH1, cL1)

                    if na(firstCanonicalT)
                        firstCanonicalT := t1
                    lastCanonicalT := na(lastCanonicalT) ? t1 : math.max(lastCanonicalT, t1)
    else
        bool aReady = not na(aTimeBase)
        bool bSynced = aReady and bTimeBase == aTimeBase
        bool cSynced = aReady and cTimeBase == aTimeBase

        if aReady
            processFeedBar(aTimeBase, aOpenBase, aHighBase, aLowBase, aCloseBase,
                 bSynced ? bHighBase : na,
                 bSynced ? bLowBase : na,
                 useC and cSynced ? cHighBase : na,
                 useC and cSynced ? cLowBase : na)

            if na(firstCanonicalT)
                firstCanonicalT := aTimeBase
            lastCanonicalT := na(lastCanonicalT) ? aTimeBase : math.max(lastCanonicalT, aTimeBase)

bool confirmedBearSessionSmt = array.get(alertFlags, 0)
bool confirmedBullSessionSmt = array.get(alertFlags, 1)
bool confirmedBearCycleSmt = array.get(alertFlags, 2)
bool confirmedBullCycleSmt = array.get(alertFlags, 3)

alertcondition(confirmedBearSessionSmt, "Confirmed bearish session SMT", "Confirmed bearish session-to-session SMT")
alertcondition(confirmedBullSessionSmt, "Confirmed bullish session SMT", "Confirmed bullish session-to-session SMT")
alertcondition(confirmedBearCycleSmt, "Confirmed bearish cycle SMT", "Confirmed bearish 10m/30m/90m/270m cycle SMT")
alertcondition(confirmedBullCycleSmt, "Confirmed bullish cycle SMT", "Confirmed bullish 10m/30m/90m/270m cycle SMT")
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DAILY / WEEKLY / MONTHLY HIGH-LOW LEVELS
// Local period tracking avoids extra request.security() calls.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showDailyHighs = input.bool(true, "Show daily highs", group = "HTF Levels")
bool showDailyLows = input.bool(true, "Show daily lows", group = "HTF Levels")
bool showWeeklyHighs = input.bool(true, "Show weekly highs", group = "HTF Levels")
bool showWeeklyLows = input.bool(true, "Show weekly lows", group = "HTF Levels")
bool showMonthlyHighs = input.bool(true, "Show monthly highs", group = "HTF Levels")
bool showMonthlyLows = input.bool(true, "Show monthly lows", group = "HTF Levels")
bool showHtfLabels = input.bool(true, "Show HTF labels", group = "HTF Levels")
bool keepSweptHtfLevels = input.bool(true, "Keep swept HTF levels", group = "HTF Levels")
int maxHtfLevels = input.int(160, "Maximum HTF levels", minval = 20, maxval = 300, group = "HTF Levels")

color dailyColor = input.color(color.new(#94A3B8, 15), "Daily", group = "HTF Levels • Colors")
color weeklyColor = input.color(color.new(#C4B5FD, 10), "Weekly", group = "HTF Levels • Colors")
color monthlyColor = input.color(color.new(#2DD4BF, 5), "Monthly", group = "HTF Levels • Colors")

var line[] htfLines = array.new_line()
var label[] htfLabels = array.new_label()
var float[] htfPrices = array.new_float()
var bool[] htfIsHigh = array.new_bool()
var bool[] htfActive = array.new_bool()
var string[] htfNames = array.new_string()

sameLevel(float a, float b) =>
    math.abs(a - b) <= syminfo.mintick * 2.0

mergeHtfName(string oldName, string newName, bool isHigh) =>
    bool hasD = str.contains(oldName, "D") or str.contains(newName, "D")
    bool hasW = str.contains(oldName, "W") or str.contains(newName, "W")
    bool hasM = str.contains(oldName, "M") or str.contains(newName, "M")
    string prefix = hasD and hasW and hasM ? "D/W/M" :
         hasW and hasM ? "W/M" :
         hasD and hasM ? "D/M" :
         hasD and hasW ? "D/W" :
         hasM ? "M" : hasW ? "W" : "D"
    prefix + (isHigh ? "H" : "L")

htfColorForName(string name) =>
    str.contains(name, "M") ? monthlyColor : str.contains(name, "W") ? weeklyColor : dailyColor

levelLabelsSamePrice(float left, float right) =>
    not na(left) and not na(right) and math.abs(left - right) <= syminfo.mintick * levelLabelMergeTicks

appendUniqueLevelName(string base, string tag) =>
    string result = base
    if str.length(tag) > 0 and not str.contains(base, tag)
        result := base + "/" + tag
    result

restoreBaseLevelLabelTexts() =>
    int completedCount = array.size(sessionLevelLabels)
    if completedCount > 0
        for i = 0 to completedCount - 1
            label lb = array.get(sessionLevelLabels, i)
            if not na(lb)
                label.set_text(lb, array.get(sessionLevelNames, i))

    for idx = 0 to 2
        RangeState s = array.get(sessions, idx)
        if not na(s.hiLb)
            label.set_text(s.hiLb, sessionHighName(idx))
        if not na(s.loLb)
            label.set_text(s.loLb, sessionLowName(idx))

    int htfCount = array.size(htfLabels)
    if htfCount > 0
        for i = 0 to htfCount - 1
            label lb = array.get(htfLabels, i)
            if not na(lb)
                label.set_text(lb, array.get(htfNames, i))
    true

mergeSessionNameIntoHtf(int htfIndex, string sessionTag) =>
    label htfLb = array.get(htfLabels, htfIndex)
    if not na(htfLb)
        string merged = appendUniqueLevelName(label.get_text(htfLb), sessionTag)
        label.set_text(htfLb, merged)
    true

refreshLevelLabelHierarchy() =>
    restoreBaseLevelLabelTexts()

    if mergeOverlappingLevelLabels
        int htfCount = array.size(htfLabels)
        int completedSessionCount = array.size(sessionLevelLabels)

        // HTF labels are the visual anchor. Session labels at the same active
        // high/low are hidden and their abbreviations are appended to the HTF text.
        if htfCount > 0
            for h = 0 to htfCount - 1
                if array.get(htfActive, h)
                    float htfPrice = array.get(htfPrices, h)
                    bool htfHigh = array.get(htfIsHigh, h)

                    if completedSessionCount > 0
                        for sIdx = 0 to completedSessionCount - 1
                            if array.get(sessionLevelActive, sIdx) and array.get(sessionLevelIsHigh, sIdx) == htfHigh and
                                 levelLabelsSamePrice(array.get(sessionLevelPrices, sIdx), htfPrice)
                                label sessionLb = array.get(sessionLevelLabels, sIdx)
                                string sessionTag = array.get(sessionLevelNames, sIdx)
                                if not na(sessionLb)
                                    label.set_text(sessionLb, "")
                                mergeSessionNameIntoHtf(h, sessionTag)

                    for idx = 0 to 2
                        RangeState currentSession = array.get(sessions, idx)
                        float sessionPrice = htfHigh ? currentSession.aH : currentSession.aL
                        label sessionLb = htfHigh ? currentSession.hiLb : currentSession.loLb
                        string sessionTag = htfHigh ? sessionHighName(idx) : sessionLowName(idx)
                        if currentSession.active and not na(sessionLb) and levelLabelsSamePrice(sessionPrice, htfPrice)
                            label.set_text(sessionLb, "")
                            mergeSessionNameIntoHtf(h, sessionTag)

        // If several session levels coincide without a D/W/M level, keep one label
        // and combine the abbreviations instead of stacking text at the same price.
        if completedSessionCount > 1
            for i = 0 to completedSessionCount - 2
                if array.get(sessionLevelActive, i)
                    label anchorLb = array.get(sessionLevelLabels, i)
                    if not na(anchorLb) and str.length(label.get_text(anchorLb)) > 0
                        string combined = array.get(sessionLevelNames, i)
                        float anchorPrice = array.get(sessionLevelPrices, i)
                        bool anchorHigh = array.get(sessionLevelIsHigh, i)
                        for j = i + 1 to completedSessionCount - 1
                            if array.get(sessionLevelActive, j) and array.get(sessionLevelIsHigh, j) == anchorHigh and
                                 levelLabelsSamePrice(array.get(sessionLevelPrices, j), anchorPrice)
                                label otherLb = array.get(sessionLevelLabels, j)
                                combined := appendUniqueLevelName(combined, array.get(sessionLevelNames, j))
                                if not na(otherLb)
                                    label.set_text(otherLb, "")
                        label.set_text(anchorLb, combined)
    true

addHtfLevel(int startT, float price, string name, color col, bool isHigh) =>
    bool merged = false
    int count = array.size(htfLines)

    if not na(startT) and not na(price) and count > 0
        for i = 0 to count - 1
            if not merged and array.get(htfActive, i) and array.get(htfIsHigh, i) == isHigh and
                 sameLevel(array.get(htfPrices, i), price)
                string mergedName = mergeHtfName(array.get(htfNames, i), name, isHigh)
                color mergedColor = htfColorForName(mergedName)
                line ln = array.get(htfLines, i)
                label lb = array.get(htfLabels, i)

                if startT < line.get_x1(ln)
                    line.set_x1(ln, startT)
                line.set_color(ln, mergedColor)
                array.set(htfNames, i, mergedName)
                if not na(lb)
                    label.set_text(lb, mergedName)
                    label.set_textcolor(lb, mergedColor)
                merged := true

    if not merged and not na(startT) and not na(price)
        line ln = line.new(startT, price, time_close, price,
             xloc = xloc.bar_time, color = col, width = 1)
        label lb = showHtfLabels ? label.new(time_close, price, name,
             xloc = xloc.bar_time, style = label.style_label_left,
             color = color.new(col, 100), textcolor = col, size = size.small) : na

        array.push(htfLines, ln)
        array.push(htfLabels, lb)
        array.push(htfPrices, price)
        array.push(htfIsHigh, isHigh)
        array.push(htfActive, true)
        array.push(htfNames, name)

        while array.size(htfLines) > maxHtfLevels
            line oldLn = array.shift(htfLines)
            label oldLb = array.shift(htfLabels)
            array.shift(htfPrices)
            array.shift(htfIsHigh)
            array.shift(htfActive)
            array.shift(htfNames)
            line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)
    true

processHtfLevels() =>
    bool dailyHighSwept = false
    bool dailyLowSwept = false
    bool weeklyHighSwept = false
    bool weeklyLowSwept = false
    bool monthlyHighSwept = false
    bool monthlyLowSwept = false

    int count = array.size(htfLines)
    if count > 0
        for step = 0 to count - 1
            int i = count - 1 - step
            line ln = array.get(htfLines, i)
            label lb = array.get(htfLabels, i)
            float price = array.get(htfPrices, i)
            bool isHigh = array.get(htfIsHigh, i)
            bool active = array.get(htfActive, i)
            string levelName = array.get(htfNames, i)

            if active
                bool swept = isHigh ? high >= price : low <= price
                int endT = swept ? sweepAnchorTime() : liveRightTime()

                line.set_x2(ln, endT)
                if not na(lb)
                    label.set_xy(lb, endT, price)

                if swept
                    // A merged level such as D/WH or D/W/MH activates every
                    // applicable alert exactly once, on its first sweep bar.
                    bool containsD = str.contains(levelName, "D")
                    bool containsW = str.contains(levelName, "W")
                    bool containsM = str.contains(levelName, "M")

                    dailyHighSwept := dailyHighSwept or (containsD and isHigh)
                    dailyLowSwept := dailyLowSwept or (containsD and not isHigh)
                    weeklyHighSwept := weeklyHighSwept or (containsW and isHigh)
                    weeklyLowSwept := weeklyLowSwept or (containsW and not isHigh)
                    monthlyHighSwept := monthlyHighSwept or (containsM and isHigh)
                    monthlyLowSwept := monthlyLowSwept or (containsM and not isHigh)

                    array.set(htfActive, i, false)
                    if not keepSweptHtfLevels
                        line.delete(ln)
                        if not na(lb)
                            label.delete(lb)
                        array.remove(htfLines, i)
                        array.remove(htfLabels, i)
                        array.remove(htfPrices, i)
                        array.remove(htfIsHigh, i)
                        array.remove(htfActive, i)
                        array.remove(htfNames, i)

    [dailyHighSwept, dailyLowSwept, weeklyHighSwept, weeklyLowSwept, monthlyHighSwept, monthlyLowSwept]

bool newDay = timeframe.change("D")
bool newWeek = timeframe.change("W")
bool newMonth = timeframe.change("M")

var float dHigh = na
var float dLow = na
var int dHighT = na
var int dLowT = na
var float wHigh = na
var float wLow = na
var int wHighT = na
var int wLowT = na
var float mHigh = na
var float mLow = na
var int mHighT = na
var int mLowT = na

if na(dHigh)
    dHigh := high
    dLow := low
    dHighT := time
    dLowT := time
else if newDay
    if showDailyHighs
        addHtfLevel(dHighT, dHigh, "DH", dailyColor, true)
    if showDailyLows
        addHtfLevel(dLowT, dLow, "DL", dailyColor, false)
    dHigh := high
    dLow := low
    dHighT := time
    dLowT := time
else
    if high > dHigh
        dHigh := high
        dHighT := time
    if low < dLow
        dLow := low
        dLowT := time

if na(wHigh)
    wHigh := high
    wLow := low
    wHighT := time
    wLowT := time
else if newWeek
    if showWeeklyHighs
        addHtfLevel(wHighT, wHigh, "WH", weeklyColor, true)
    if showWeeklyLows
        addHtfLevel(wLowT, wLow, "WL", weeklyColor, false)
    wHigh := high
    wLow := low
    wHighT := time
    wLowT := time
else
    if high > wHigh
        wHigh := high
        wHighT := time
    if low < wLow
        wLow := low
        wLowT := time

if na(mHigh)
    mHigh := high
    mLow := low
    mHighT := time
    mLowT := time
else if newMonth
    if showMonthlyHighs
        addHtfLevel(mHighT, mHigh, "MH", monthlyColor, true)
    if showMonthlyLows
        addHtfLevel(mLowT, mLow, "ML", monthlyColor, false)
    mHigh := high
    mLow := low
    mHighT := time
    mLowT := time
else
    if high > mHigh
        mHigh := high
        mHighT := time
    if low < mLow
        mLow := low
        mLowT := time

[dailyHighSwept, dailyLowSwept, weeklyHighSwept, weeklyLowSwept, monthlyHighSwept, monthlyLowSwept] = processHtfLevels()
refreshLevelLabelHierarchy()

bool anyDailyLiquiditySwept = dailyHighSwept or dailyLowSwept
bool anyWeeklyLiquiditySwept = weeklyHighSwept or weeklyLowSwept
bool anyMonthlyLiquiditySwept = monthlyHighSwept or monthlyLowSwept
bool anyHtfLiquiditySwept = anyDailyLiquiditySwept or anyWeeklyLiquiditySwept or anyMonthlyLiquiditySwept

// Separate conditions make each level selectable in TradingView's Create Alert
// dialog. The combined condition is convenient when one notification is enough.
alertcondition(dailyHighSwept, "Daily High swept", "Daily High liquidity swept on {{ticker}} at {{close}}")
alertcondition(dailyLowSwept, "Daily Low swept", "Daily Low liquidity swept on {{ticker}} at {{close}}")
alertcondition(weeklyHighSwept, "Weekly High swept", "Weekly High liquidity swept on {{ticker}} at {{close}}")
alertcondition(weeklyLowSwept, "Weekly Low swept", "Weekly Low liquidity swept on {{ticker}} at {{close}}")
alertcondition(monthlyHighSwept, "Monthly High swept", "Monthly High liquidity swept on {{ticker}} at {{close}}")
alertcondition(monthlyLowSwept, "Monthly Low swept", "Monthly Low liquidity swept on {{ticker}} at {{close}}")
alertcondition(anyDailyLiquiditySwept, "Any Daily High/Low swept", "Daily High or Low liquidity swept on {{ticker}} at {{close}}")
alertcondition(anyWeeklyLiquiditySwept, "Any Weekly High/Low swept", "Weekly High or Low liquidity swept on {{ticker}} at {{close}}")
alertcondition(anyMonthlyLiquiditySwept, "Any Monthly High/Low swept", "Monthly High or Low liquidity swept on {{ticker}} at {{close}}")
alertcondition(anyHtfLiquiditySwept, "Any D/W/M High/Low swept", "Daily, Weekly, or Monthly liquidity swept on {{ticker}} at {{close}}")


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIME-CYCLE COLOR LEGEND — FIXED POSITION, NO TEXT INSIDE EVERY BOX
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table cycleLegend = table.new(position.bottom_right, 2, 4,
     bgcolor = color.new(chart.bg_color, 8),
     frame_color = color.new(chart.fg_color, 65), frame_width = 1,
     border_color = color.new(chart.fg_color, 85), border_width = 1)
if barstate.islast
    bool legendVisible = showCycles and showCycleLegend
    color clearBg = color.new(chart.bg_color, 100)
    color clearText = color.new(chart.fg_color, 100)
    color labelBg = legendVisible ? color.new(chart.bg_color, 8) : clearBg
    color labelText = legendVisible ? chart.fg_color : clearText

    table.cell(cycleLegend, 0, 0, legendVisible ? "A" : "",
         text_color = legendVisible ? color.white : clearText,
         bgcolor = legendVisible ? color.new(accumulationColor, 12) : clearBg,
         text_size = size.small, text_halign = text.align_center)
    table.cell(cycleLegend, 1, 0, legendVisible ? "Accumulation" : "",
         text_color = labelText, bgcolor = labelBg,
         text_size = size.small, text_halign = text.align_left)

    table.cell(cycleLegend, 0, 1, legendVisible ? "M" : "",
         text_color = legendVisible ? color.white : clearText,
         bgcolor = legendVisible ? color.new(manipulationColor, 12) : clearBg,
         text_size = size.small, text_halign = text.align_center)
    table.cell(cycleLegend, 1, 1, legendVisible ? "Manipulation" : "",
         text_color = labelText, bgcolor = labelBg,
         text_size = size.small, text_halign = text.align_left)

    table.cell(cycleLegend, 0, 2, legendVisible ? "D" : "",
         text_color = legendVisible ? color.white : clearText,
         bgcolor = legendVisible ? color.new(distributionColor, 12) : clearBg,
         text_size = size.small, text_halign = text.align_center)
    table.cell(cycleLegend, 1, 2, legendVisible ? "Distribution" : "",
         text_color = labelText, bgcolor = labelBg,
         text_size = size.small, text_halign = text.align_left)

    table.cell(cycleLegend, 0, 3, legendVisible ? "270" : "",
         text_color = legendVisible ? color.white : clearText,
         bgcolor = legendVisible ? color.new(cycle270Color, 12) : clearBg,
         text_size = size.small, text_halign = text.align_center)
    table.cell(cycleLegend, 1, 3, legendVisible ? "270m structure" : "",
         text_color = labelText, bgcolor = labelBg,
         text_size = size.small, text_halign = text.align_left)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showStatus = input.bool(true, "Show status", group = "Display")
var table statusTable = table.new(position.top_right, 1, 1)
if barstate.islast
    string statusText = ""
    if showStatus
        if not intraday
            statusText := "INTRADAY CHART REQUIRED"
        else if chartSec < 60
            statusText := "SUPPORTED FROM 1m TO 1H"
        else if chartSec > 3600
            statusText := "SUPPORTED UP TO 1H"
        else if useIntrabars
            statusText := "CANONICAL 1m INTRABAR ENGINE"
        else
            statusText := "CANONICAL 1m ENGINE"
    color statusBg = engineEnabled ? color.new(color.green, 80) : color.new(color.red, 65)
    table.cell(statusTable, 0, 0, statusText, text_color = color.white,
         bgcolor = showStatus ? statusBg : color.new(color.black, 100), text_size = size.tiny)
````
