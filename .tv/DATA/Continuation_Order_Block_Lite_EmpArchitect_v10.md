<!-- tradingview-pine-id: PUB;4aff2fbef6b2423d909a49aa6b6e36fc -->
<!-- tradingviewscripts-format: 1 -->
# Continuation Order Block Lite [EmpArchitect] v1.0

Source: https://www.tradingview.com/script/7kzavpXh-Continuation-Order-Block-Lite-EmpArchitect/

## Description

█ OVERVIEW

Continuation Order Block Lite [EmpArchitect] maps bullish and bearish order-block zones that form only after a defined continuation-structure sequence.

Many order-block tools identify an opposing candle and plot a zone without showing the structural sequence that made the zone relevant.

This script separates the sequence from the zone:

• CHoCH establishes a possible change in structural direction
• BUILD BOS advances the continuation sequence
• CONT BOS confirms or extends the selected continuation model
• A qualifying continuation order block is then mapped
• The zone is tracked through interaction, invalidation, expiry, or supersession

It is an analytics-only structure tool. It does not provide entries, stop losses, targets, position sizing, risk/reward, probability scores, performance claims, or trade signals.

█ WHAT IT MAPS

Bullish continuation zone:

A full-candle zone taken from the most recent bearish structure-timeframe candle before a qualifying bullish continuation break.

Bearish continuation zone:

A full-candle zone taken from the most recent bullish structure-timeframe candle before a qualifying bearish continuation break.

The script tracks one current active continuation zone. Older zones may remain visible as inactive historical boxes.

█ CONTINUATION MODELS

Model B — CHoCH + first BOS:

The structural direction changes through CHoCH. The first same-direction BOS completes the continuation sequence.

Model A — CHoCH + two BOS:

The structural direction changes through CHoCH. The first BOS builds the sequence. The second same-direction BOS completes the stricter continuation sequence.

The model changes the number of confirmed structural breaks required before the structure state becomes ready.

█ HOW THE STRUCTURE SEQUENCE WORKS

The script uses confirmed pivots from the selected structure timeframe.

A pivot high or pivot low becomes available only after the selected left-side and right-side confirmation bars have completed.

A close beyond the latest live swing level creates a structural break:

• CHoCH — the break changes the current structural direction
• BUILD BOS — the break continues the new direction but has not yet completed the selected model
• CONT BOS — the break completes or extends the selected continuation sequence

The script uses the most recently confirmed internal pivot. A newer confirmed pivot can replace an older unbroken pivot.

Equal highs and equal lows are not accepted as pivots because the comparison is strict.

█ ORDER-BLOCK ORIGIN

After a qualifying continuation break, the script searches backward through completed structure bars.

For a bullish continuation zone, it selects the most recent bearish candle.

For a bearish continuation zone, it selects the most recent bullish candle.

The complete candle high-to-low range is used. The zone is not reduced to the candle body.

The search is limited by the Origin search window setting.

The zone begins when the continuation condition is confirmed. It is not back-projected as though it had already been known on the original candle.

█ DISPLACEMENT AND FVG QUALIFICATION

A candidate zone must pass the selected displacement / imbalance rule.

Displacement is measured against ATR from the structure timeframe.

Immediate FVG refers to a three-candle imbalance anchored at the selected origin candle.

When “Require both displacement and immediate FVG” is OFF:

• Displacement OR immediate FVG can qualify the zone

When it is ON:

• Displacement AND immediate FVG are both required

The dashboard displays the active rule and ATR multiplier.

█ VISUAL LANGUAGE

The structure sequence uses different line styles so the events are not presented as equivalent.

CHoCH:

• Dashed line
• Muted directional colour
• Context transition only

BUILD BOS:

• Dotted line
• Muted label
• Sequence is still below the selected confirmation threshold

CONT BOS:

• Solid line
• Stronger directional colour
• Thicker line at the break that completes the selected continuation model

Bullish structure and zones use green.

Bearish structure and zones use orange.

Active zones use stronger solid styling.

Inactive historical zones retain their bullish or bearish colour with a faded fill and dotted outline.

█ ZONE LIFECYCLE

The script tracks the zone separately from the structural break that created it.

An active zone can be:

• Fresh
• Touched
• Gap-through
• Structurally invalidated
• Expired by maximum age
• Superseded by a newer same-side continuation zone

First interaction:

A zone is marked as touched when price first reaches the zone and overlaps its range.

Gap-through:

A gap-through event is recorded when the first interaction bar moves completely beyond the zone without overlapping it.

Structure invalidation:

• Bullish zone — a completed structure-timeframe close below the zone bottom
• Bearish zone — a completed structure-timeframe close above the zone top

Age expiry:

The zone becomes inactive after exceeding the selected maximum number of completed structure bars.

Supersession:

A newer qualifying same-side continuation zone replaces the currently active zone.

A touch does not automatically delete the zone.

█ TIMEFRAME MODES

Auto mode:

• Charts up to and including 4H use 4H structure
• Charts above 4H through 1D use 1D structure
• Charts above 1D through 1W use 1W structure
• Charts above 1W use 1M structure

Examples:

• 15m chart → 4H structure
• 1H chart → 4H structure
• 4H chart = 4H structure
• 1D chart = 1D structure

Manual mode:

Select a structure timeframe equal to or higher than the chart timeframe.

Examples:

• 1H chart → 4H structure
• 4H chart → 1D structure
• 1D chart → 1W structure

A structure timeframe below the chart timeframe is rejected.

Same-timeframe mode processes the prior completed chart bar directly.

Higher-timeframe mode processes the prior confirmed structure bar when a new structure bar begins.

█ STATUS PANEL

The panel shows the current continuation state:

• Chart timeframe and structure timeframe
• Auto or Manual mode
• Same-timeframe or higher-timeframe view
• Selected continuation model
• Current sequence progress
• Most recent structural break
• Active bullish-zone state, age, and range
• Active bearish-zone state, age, and range
• Most recent zone lifecycle event
• Current displacement / FVG qualification
• Structure-data readiness

The panel describes the current state. It does not recommend an action.

█ ALERTS

Included structure-context events:

• New bullish or bearish continuation zone
• Bullish or bearish zone interaction
• Bullish or bearish gap-through
• Zone deactivation

Zone-deactivation messages include the reason:

• Structure reversal
• Structure invalidation
• Age
• Superseded

These are structure-event alerts only. They are not trade signals.

█ WORKED EXAMPLE

Example: 1H chart with 4H structure and Model B.

1. A confirmed 4H close breaks the latest opposite-side swing and creates CHoCH.
2. A later confirmed 4H close breaks the next same-direction swing.
3. That break is displayed as CONT BOS because Model B requires CHoCH plus the first BOS.
4. The script searches backward for the most recent opposing 4H candle.
5. The full high-to-low range of that candle becomes the candidate continuation zone.
6. The candidate appears only if the displacement / immediate-FVG rule passes.
7. A touch changes the zone from fresh to touched but does not deactivate it. The zone remains active until structure reversal, structure invalidation, age expiry, or supersession.

The sequence establishes why the zone was mapped. It does not establish that price will return to the zone or that the zone will hold.

█ HOW IT DIFFERS FROM SMC STRUCTURE ENGINE

SMC Structure Engine [EmpArchitect] is a broader chart-structure tool.

It maps general CHoCH and BOS events, multiple order blocks, liquidity sweeps, break strength, zone scoring, touch counts, and broader regime context.

Continuation Order Block Lite is narrower by design.

It focuses on:

• A selected structure timeframe
• A defined CHoCH-to-BOS continuation sequence
• A continuation-specific origin candle
• Displacement / immediate-FVG qualification
• One current active continuation zone, with older zones retained as inactive history
• A compact continuation-zone lifecycle

The two scripts answer different questions.

SMC Structure Engine asks:

What is the broader structure and order-block context on this chart?

Continuation Order Block Lite asks:

Did a defined continuation sequence complete, and what happened to the resulting origin zone?

█ SETTINGS

Model settings:

• Structure timeframe mode
• Manual structure timeframe
• Trend-state model
• Pivot left bars
• Pivot right bars
• Origin search window
• Displacement threshold
• Require both displacement and immediate FVG
• Maximum zone age

Display settings:

• Show zone boxes
• Show continuation sequence
• Show structure swing levels
• Show status panel

█ IMPORTANT LIMITATIONS

• Confirmed pivots introduce delay.
• Structural breaks use completed closes, not intrabar assumptions.
• A valid continuation sequence does not prove that continuation will persist.
• A mapped zone does not imply that price will return.
• A zone interaction does not imply that the zone will hold.
• The script keeps only one current active continuation zone.
• A newer same-side zone supersedes the previous active zone.
• Zones use the full candle range, not the body.
• Equal highs and equal lows are excluded by the strict pivot definition.
• The script does not evaluate volume, liquidity sweeps, session quality, macro events, or market regime outside the defined sequence.
• Results depend on pivot settings, origin lookback, ATR threshold, FVG requirement, market, and timeframe.
• Same-timeframe and higher-timeframe views can show different structural granularity.
• Lower-liquidity or highly irregular markets may produce noisier structure.

█ NOTES

• Pine Script v6
• Public and open-source
• Built by EmpArchitect
• Analytics-only structure tool
• Designed for chart review and structural inspection
• Not a signal service
• No entries, exits, stop losses, targets, or performance claims

█ CORE IDEA

Continuation Order Block Lite does not treat every opposing candle as an order block.

It first requires a defined continuation sequence.

It then maps the origin zone and records what happened to it.

Structure observations, not signals.

---

## Source Code

````pine
//@version=6
// =============================================================================
// Continuation Order Block Lite [EmpArchitect] v1.0
// -----------------------------------------------------------------------------
// Analytics-only continuation order-block map.
//
// Method preserved from the locked EA ContOB Indicator v0.4 donor:
//   • completed structure-timeframe data
//   • Model A: CHoCH + two BOS
//   • Model B: CHoCH + first BOS
//   • most-recent opposite-candle origin
//   • full-candle zone boundaries
//   • displacement / immediate-FVG qualification
//   • one active bullish and one active bearish zone
//   • first interaction, gap-through, invalidation, age and supersession
//
// Same-timeframe mode reads the prior completed chart bar directly.
// Higher-timeframe mode requests the prior completed structure bar via [1]
// with barmerge.lookahead_on. Both modes process a bar when its completed
// structure timestamp first appears in the selected data stream.
// =============================================================================
indicator(
     "Continuation Order Block Lite [EmpArchitect] v1.0",
     "ContOB Lite [EA] v1.0",
     overlay = true,
     max_boxes_count = 500,
     max_labels_count = 500,
     max_lines_count = 500)

// =============================== COLORS ======================================
color BULL_COLOR       = color.rgb(8, 153, 129)
color BEAR_COLOR       = color.rgb(214, 139, 0)
color PANEL_BG         = color.rgb(18, 22, 28)
color PANEL_HEADER     = color.rgb(37, 44, 55)
color PANEL_LABEL      = color.rgb(28, 34, 43)
color PANEL_BORDER     = color.rgb(80, 89, 104)
color PANEL_TEXT       = color.rgb(235, 238, 243)
color PANEL_MUTED      = color.rgb(155, 164, 177)
color CONTEXT_TEXT      = color.rgb(184, 191, 202)

// =============================== INPUTS ======================================
string GROUP_MODEL = "Model"
string structureMode = input.string(
     "Auto",
     "Structure timeframe mode",
     options = ["Auto", "Manual"],
     tooltip = "Auto: charts up to 4H use 4H structure; charts above 4H through 1D use 1D; charts above 1D through 1W use 1W. Manual: select an equal or higher structure timeframe.",
     group = GROUP_MODEL)

string manualStructureTf = input.timeframe(
     "240",
     "Manual structure timeframe",
     tooltip = "Used only in Manual mode. It must be equal to or higher than the chart timeframe.",
     group = GROUP_MODEL)

string trendModel = input.string(
     "B: CHoCH + first BOS",
     "Trend-state model",
     options = [
         "A: CHoCH + two BOS (strict)",
         "B: CHoCH + first BOS"
     ],
     group = GROUP_MODEL)

int pivotLeft = input.int(
     3,
     "Pivot left bars",
     minval = 1,
     group = GROUP_MODEL)

int pivotRight = input.int(
     3,
     "Pivot right bars",
     minval = 1,
     group = GROUP_MODEL)

int originLookback = input.int(
     10,
     "Origin search window (structure bars)",
     minval = 1,
     maxval = 400,
     group = GROUP_MODEL)

float displacementMultiplier = input.float(
     1.5,
     "Displacement threshold (structure ATR x)",
     minval = 0.0,
     step = 0.1,
     group = GROUP_MODEL)

bool requireBothDispAndFvg = input.bool(
     false,
     "Require both displacement and immediate FVG",
     tooltip = "ON: both displacement and immediate FVG are required. OFF: displacement OR immediate FVG qualifies.",
     group = GROUP_MODEL)

int maximumZoneAge = input.int(
     20,
     "Maximum zone age (structure bars)",
     minval = 1,
     group = GROUP_MODEL)

string GROUP_DISPLAY = "Display"
bool showZoneBoxes = input.bool(
     true,
     "Show zone boxes",
     group = GROUP_DISPLAY)

bool showStructureBreaks = input.bool(
     true,
     "Show continuation sequence",
     tooltip = "CHoCH is context. BUILD BOS advances the selected model. CONT BOS confirms or extends continuation structure.",
     group = GROUP_DISPLAY)

bool showSwingLevels = input.bool(
     false,
     "Show structure swing levels",
     group = GROUP_DISPLAY)

bool showStatusPanel = input.bool(
     true,
     "Show status panel",
     group = GROUP_DISPLAY)

// Preserve the locked donor's default 50-bar readiness floor after removal of
// the unrelated public dealing-range control.
const int WARMUP_FLOOR = 50
const int ARRAY_LIMIT = 400

// ======================= TIMEFRAME RESOLUTION ================================
float chartSeconds = timeframe.in_seconds()

string automaticStructureTf =
     chartSeconds <= timeframe.in_seconds("240")
     ? "240"
     : chartSeconds <= timeframe.in_seconds("D")
     ? "D"
     : chartSeconds <= timeframe.in_seconds("W")
     ? "W"
     : "M"

string structureTf =
     structureMode == "Auto"
     ? automaticStructureTf
     : manualStructureTf

float structureSeconds = timeframe.in_seconds(structureTf)
bool sameTimeframeMode = chartSeconds == structureSeconds

if chartSeconds > structureSeconds
    runtime.error(
         "Manual structure timeframe must be equal to or higher than the chart timeframe. " +
         "Current chart: " + timeframe.period +
         ", selected structure: " + structureTf +
         ". Use Auto mode or choose a higher timeframe.")

// ============================== HELPERS ======================================
f_timeframeLabel(string tf) =>
    switch tf
        "1" => "1m"
        "3" => "3m"
        "5" => "5m"
        "15" => "15m"
        "30" => "30m"
        "45" => "45m"
        "60" => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "360" => "6H"
        "480" => "8H"
        "720" => "12H"
        "D" => "1D"
        "W" => "1W"
        "M" => "1M"
        => tf

// Tracks the most recent confirmed internal pivot. A newer confirmed internal
// pivot can replace an older unbroken pivot by design.
//
// eventDirection:  1 = bullish break, -1 = bearish break, 0 = no break
// eventKind:       1 = BOS, 2 = CHoCH, 0 = no event
f_structureEngine(
     bool newStructureBar,
     array<int> barTimes,
     array<float> highs,
     array<float> lows,
     array<float> closes,
     int leftBars,
     int rightBars,
     int requiredBreaks) =>

    var float lastSwingHigh = na
    var int   lastSwingHighTime = na
    var bool  swingHighLive = false

    var float lastSwingLow = na
    var int   lastSwingLowTime = na
    var bool  swingLowLive = false

    var int structureDirection = 0
    var int breakCount = 0

    int eventDirection = 0
    int eventKind = 0
    float brokenLevel = na
    int brokenPivotTime = na

    if newStructureBar
        int size = closes.size()
        int pivotIndex = size - 1 - rightBars

        if pivotIndex >= leftBars
            float candidateHigh = highs.get(pivotIndex)
            bool validHigh = true

            for index = pivotIndex - leftBars to pivotIndex + rightBars
                if index != pivotIndex and highs.get(index) >= candidateHigh
                    validHigh := false

            if validHigh
                lastSwingHigh := candidateHigh
                lastSwingHighTime := barTimes.get(pivotIndex)
                swingHighLive := true

            float candidateLow = lows.get(pivotIndex)
            bool validLow = true

            for index = pivotIndex - leftBars to pivotIndex + rightBars
                if index != pivotIndex and lows.get(index) <= candidateLow
                    validLow := false

            if validLow
                lastSwingLow := candidateLow
                lastSwingLowTime := barTimes.get(pivotIndex)
                swingLowLive := true

        float currentClose = closes.get(size - 1)

        if swingHighLive and not na(lastSwingHigh) and currentClose > lastSwingHigh
            brokenLevel := lastSwingHigh
            brokenPivotTime := lastSwingHighTime
            eventKind := structureDirection == 1 ? 1 : 2
            swingHighLive := false
            eventDirection := 1

            if structureDirection == 1
                breakCount += 1
            else
                structureDirection := 1
                breakCount := 1

        if swingLowLive and not na(lastSwingLow) and currentClose < lastSwingLow
            brokenLevel := lastSwingLow
            brokenPivotTime := lastSwingLowTime
            eventKind := structureDirection == -1 ? 1 : 2
            swingLowLive := false
            eventDirection := -1

            if structureDirection == -1
                breakCount += 1
            else
                structureDirection := -1
                breakCount := 1

    bool bullishState = structureDirection == 1 and breakCount >= requiredBreaks
    bool bearishState = structureDirection == -1 and breakCount >= requiredBreaks

    [structureDirection, breakCount, bullishState, bearishState, eventDirection, eventKind, brokenLevel, brokenPivotTime, lastSwingHigh, lastSwingLow]

f_findBullishOrigin(
     array<float> opens,
     array<float> highs,
     array<float> lows,
     array<float> closes,
     int lookback) =>

    int size = closes.size()
    int originIndex = -1
    float zoneTop = na
    float zoneBottom = na

    if size >= 2
        int firstIndex = math.max(0, size - 1 - lookback)

        for index = size - 2 to firstIndex
            if closes.get(index) < opens.get(index)
                originIndex := index
                zoneTop := highs.get(index)
                zoneBottom := lows.get(index)
                break

    [originIndex, zoneTop, zoneBottom]

f_findBearishOrigin(
     array<float> opens,
     array<float> highs,
     array<float> lows,
     array<float> closes,
     int lookback) =>

    int size = closes.size()
    int originIndex = -1
    float zoneTop = na
    float zoneBottom = na

    if size >= 2
        int firstIndex = math.max(0, size - 1 - lookback)

        for index = size - 2 to firstIndex
            if closes.get(index) > opens.get(index)
                originIndex := index
                zoneTop := highs.get(index)
                zoneBottom := lows.get(index)
                break

    [originIndex, zoneTop, zoneBottom]

// Immediate three-candle imbalance anchored at the selected origin candle.
f_hasBullishFvg(array<float> highs, array<float> lows, int originIndex) =>
    originIndex >= 0 and
     highs.size() - originIndex >= 3 and
     highs.get(originIndex) < lows.get(originIndex + 2)

f_hasBearishFvg(array<float> highs, array<float> lows, int originIndex) =>
    originIndex >= 0 and
     highs.size() - originIndex >= 3 and
     lows.get(originIndex) > highs.get(originIndex + 2)

f_freezeZoneBox(box zoneBox, color directionColor) =>
    if not na(zoneBox)
        box.set_border_color(zoneBox, color.new(directionColor, 58))
        box.set_border_style(zoneBox, line.style_dotted)
        box.set_border_width(zoneBox, 1)
        box.set_bgcolor(zoneBox, color.new(directionColor, 93))

f_eventMessage(
     string eventName,
     string direction,
     string zoneId,
     float eventPrice,
     string reason,
     float zoneTop,
     float zoneBottom,
     float zoneMidpoint) =>

    '{"schema":1,"src":"EA-ContOB-Lite","symbol":"' + syminfo.tickerid +
     '","chart_tf":"' + timeframe.period +
     '","structure_tf":"' + structureTf +
     '","event":"' + eventName +
     '","direction":"' + direction +
     '","zone_id":"' + zoneId +
     '","time":' + str.tostring(time) +
     ',"top":' + (na(zoneTop) ? "null" : str.tostring(zoneTop)) +
     ',"bottom":' + (na(zoneBottom) ? "null" : str.tostring(zoneBottom)) +
     ',"midpoint":' + (na(zoneMidpoint) ? "null" : str.tostring(zoneMidpoint)) +
     ',"event_price":' + (na(eventPrice) ? "null" : str.tostring(eventPrice)) +
     ',"reason":' + (reason == "" ? "null" : '"' + reason + '"') + "}"

// ================ COMPLETED STRUCTURE-TIMEFRAME DATA =========================
// HTF request: confirmed prior structure bar. In same-timeframe mode these
// requested values are ignored and direct chart values are used instead.
[requestedOpen, requestedHigh, requestedLow, requestedClose, requestedTime, requestedAtr] = request.security(
     syminfo.tickerid,
     structureTf,
     [open[1], high[1], low[1], close[1], time[1], ta.atr(14)[1]],
     lookahead = barmerge.lookahead_on,
     calc_bars_count = ARRAY_LIMIT + WARMUP_FLOOR + 50)

float structureOpen =
     sameTimeframeMode
     ? open[1]
     : requestedOpen

float structureHigh =
     sameTimeframeMode
     ? high[1]
     : requestedHigh

float structureLow =
     sameTimeframeMode
     ? low[1]
     : requestedLow

float structureClose =
     sameTimeframeMode
     ? close[1]
     : requestedClose

int structureTime =
     sameTimeframeMode
     ? time[1]
     : requestedTime

float structureAtr =
     sameTimeframeMode
     ? ta.atr(14)[1]
     : requestedAtr

// Process each completed structure bar when its timestamp first appears in the
// selected data stream. This works identically for same-timeframe and HTF views,
// including when the script is loaded midway through an open realtime chart bar.
bool newStructureBar =
     not na(structureTime) and
     not na(structureClose) and
     structureTime != nz(structureTime[1])

var structureTimes = array.new_int()
var structureOpens = array.new_float()
var structureHighs = array.new_float()
var structureLows = array.new_float()
var structureCloses = array.new_float()
var int completedStructureBars = 0

if newStructureBar
    structureTimes.push(structureTime)
    structureOpens.push(structureOpen)
    structureHighs.push(structureHigh)
    structureLows.push(structureLow)
    structureCloses.push(structureClose)
    completedStructureBars += 1

    if structureTimes.size() > ARRAY_LIMIT
        structureTimes.shift()
        structureOpens.shift()
        structureHighs.shift()
        structureLows.shift()
        structureCloses.shift()

int minimumWarmup =
     math.max(
         WARMUP_FLOOR,
         originLookback + pivotLeft + pivotRight + 2)

bool structureReady = structureHighs.size() >= minimumWarmup

// =========================== STRUCTURE ENGINE ================================
int requiredBreaks = str.startswith(trendModel, "A") ? 3 : 2

[structureDirection, structureBreakCount, bullishStructure, bearishStructure, structureEventDirection, structureEventKind, brokenStructureLevel, brokenPivotTime, currentSwingHigh, currentSwingLow] = f_structureEngine(
     newStructureBar,
     structureTimes,
     structureHighs,
     structureLows,
     structureCloses,
     pivotLeft,
     pivotRight,
     requiredBreaks)

// Persistent structure-event memory for the status panel.
var string lastStructureEventText = "—"
var int lastStructureEventDirection = 0
var int lastStructureEventAtCount = na

if newStructureBar and structureEventDirection != 0
    lastStructureEventText :=
         structureEventKind == 2
         ? "CHoCH"
         : structureBreakCount < requiredBreaks
         ? "BUILD BOS"
         : "CONT BOS"
    lastStructureEventDirection := structureEventDirection
    lastStructureEventAtCount := completedStructureBars

// ============================== ZONE STATE ===================================
var bool bullishZoneActive = false
var float bullishZoneTop = na
var float bullishZoneBottom = na
var float bullishZoneMidpoint = na
var bool bullishZoneInteracted = false
var int bullishZoneBirth = 0
var int bullishZoneSerial = 0
var box bullishZoneBox = na

var bool bearishZoneActive = false
var float bearishZoneTop = na
var float bearishZoneBottom = na
var float bearishZoneMidpoint = na
var bool bearishZoneInteracted = false
var int bearishZoneBirth = 0
var int bearishZoneSerial = 0
var box bearishZoneBox = na

// Per-bar analytical events and frozen old-zone context.
bool newBullishZone = false
bool newBearishZone = false
bool bullishInteraction = false
bool bearishInteraction = false
bool bullishGapThrough = false
bool bearishGapThrough = false
bool bullishZoneOff = false
bool bearishZoneOff = false

string bullishOffReason = ""
string bearishOffReason = ""

float oldBullishTop = na
float oldBullishBottom = na
float oldBullishMidpoint = na
int oldBullishSerial = 0

float oldBearishTop = na
float oldBearishBottom = na
float oldBearishMidpoint = na
int oldBearishSerial = 0

// Persistent lifecycle-event memory for the status panel.
var string lastZoneEventText = "—"
var int lastZoneEventDirection = 0
var int lastZoneEventAtBar = na

// ============================ ZONE LIFECYCLE =================================
// Snapshot the zone before deactivation so the event retains the correct ID
// and coordinates.
if bullishZoneActive
    string reason = ""

    if not bullishStructure
        reason := "TREND_REVERSAL"
    else if newStructureBar and completedStructureBars > bullishZoneBirth
        if structureClose < bullishZoneBottom
            reason := "STRUCTURE_INVALIDATION"
        else if completedStructureBars - bullishZoneBirth > maximumZoneAge
            reason := "AGE"

    if reason != ""
        bullishZoneOff := true
        bullishOffReason := reason
        oldBullishTop := bullishZoneTop
        oldBullishBottom := bullishZoneBottom
        oldBullishMidpoint := bullishZoneMidpoint
        oldBullishSerial := bullishZoneSerial
        bullishZoneActive := false
        f_freezeZoneBox(bullishZoneBox, BULL_COLOR)

if bearishZoneActive
    string reason = ""

    if not bearishStructure
        reason := "TREND_REVERSAL"
    else if newStructureBar and completedStructureBars > bearishZoneBirth
        if structureClose > bearishZoneTop
            reason := "STRUCTURE_INVALIDATION"
        else if completedStructureBars - bearishZoneBirth > maximumZoneAge
            reason := "AGE"

    if reason != ""
        bearishZoneOff := true
        bearishOffReason := reason
        oldBearishTop := bearishZoneTop
        oldBearishBottom := bearishZoneBottom
        oldBearishMidpoint := bearishZoneMidpoint
        oldBearishSerial := bearishZoneSerial
        bearishZoneActive := false
        f_freezeZoneBox(bearishZoneBox, BEAR_COLOR)

// ============================== ZONE CREATION ================================
// The qualification boolean is intentionally unchanged from the locked donor:
// ON  -> displacement AND FVG
// OFF -> displacement OR FVG
if newStructureBar and
     structureEventDirection == 1 and
     bullishStructure and
     structureReady and
     not na(structureAtr)

    [originIndex, candidateTop, candidateBottom] = f_findBullishOrigin(
         structureOpens,
         structureHighs,
         structureLows,
         structureCloses,
         originLookback)

    if originIndex >= 0
        bool hasFvg =
             f_hasBullishFvg(
                 structureHighs,
                 structureLows,
                 originIndex)

        bool displacementQualified =
             structureCloses.get(structureCloses.size() - 1) - candidateBottom >=
             displacementMultiplier * structureAtr

        bool zoneQualified =
             requireBothDispAndFvg
             ? displacementQualified and hasFvg
             : displacementQualified or hasFvg

        if zoneQualified
            if bullishZoneActive
                bullishZoneOff := true
                bullishOffReason := "SUPERSEDED"
                oldBullishTop := bullishZoneTop
                oldBullishBottom := bullishZoneBottom
                oldBullishMidpoint := bullishZoneMidpoint
                oldBullishSerial := bullishZoneSerial

            f_freezeZoneBox(bullishZoneBox, BULL_COLOR)

            bullishZoneActive := true
            bullishZoneTop := candidateTop
            bullishZoneBottom := candidateBottom
            bullishZoneMidpoint := (candidateTop + candidateBottom) / 2
            bullishZoneInteracted := false
            bullishZoneBirth := completedStructureBars
            bullishZoneSerial += 1
            newBullishZone := true

            bullishZoneBox :=
                 showZoneBoxes
                 ? box.new(
                     left = bar_index,
                     top = candidateTop,
                     right = bar_index + 1,
                     bottom = candidateBottom,
                     xloc = xloc.bar_index,
                     border_color = BULL_COLOR,
                     border_width = 1,
                     bgcolor = color.new(BULL_COLOR, 86))
                 : na

if newStructureBar and
     structureEventDirection == -1 and
     bearishStructure and
     structureReady and
     not na(structureAtr)

    [originIndex, candidateTop, candidateBottom] = f_findBearishOrigin(
         structureOpens,
         structureHighs,
         structureLows,
         structureCloses,
         originLookback)

    if originIndex >= 0
        bool hasFvg =
             f_hasBearishFvg(
                 structureHighs,
                 structureLows,
                 originIndex)

        bool displacementQualified =
             candidateTop - structureCloses.get(structureCloses.size() - 1) >=
             displacementMultiplier * structureAtr

        bool zoneQualified =
             requireBothDispAndFvg
             ? displacementQualified and hasFvg
             : displacementQualified or hasFvg

        if zoneQualified
            if bearishZoneActive
                bearishZoneOff := true
                bearishOffReason := "SUPERSEDED"
                oldBearishTop := bearishZoneTop
                oldBearishBottom := bearishZoneBottom
                oldBearishMidpoint := bearishZoneMidpoint
                oldBearishSerial := bearishZoneSerial

            f_freezeZoneBox(bearishZoneBox, BEAR_COLOR)

            bearishZoneActive := true
            bearishZoneTop := candidateTop
            bearishZoneBottom := candidateBottom
            bearishZoneMidpoint := (candidateTop + candidateBottom) / 2
            bearishZoneInteracted := false
            bearishZoneBirth := completedStructureBars
            bearishZoneSerial += 1
            newBearishZone := true

            bearishZoneBox :=
                 showZoneBoxes
                 ? box.new(
                     left = bar_index,
                     top = candidateTop,
                     right = bar_index + 1,
                     bottom = candidateBottom,
                     xloc = xloc.bar_index,
                     border_color = BEAR_COLOR,
                     border_width = 1,
                     bgcolor = color.new(BEAR_COLOR, 86))
                 : na

// =========================== FIRST INTERACTION ===============================
if bullishZoneActive
    if not bullishZoneInteracted and low <= bullishZoneTop
        bullishZoneInteracted := true

        if high >= bullishZoneBottom
            bullishInteraction := true
        else
            bullishGapThrough := true

    if not na(bullishZoneBox)
        box.set_right(bullishZoneBox, bar_index)

if bearishZoneActive
    if not bearishZoneInteracted and high >= bearishZoneBottom
        bearishZoneInteracted := true

        if low <= bearishZoneTop
            bearishInteraction := true
        else
            bearishGapThrough := true

    if not na(bearishZoneBox)
        box.set_right(bearishZoneBox, bar_index)

// Record the most recent lifecycle event after all per-bar zone logic has run.
// New-zone or interaction events intentionally replace same-bar deactivation
// text when a superseded zone is immediately replaced.
if bullishZoneOff
    lastZoneEventText := "BULL OFF · " + bullishOffReason
    lastZoneEventDirection := 1
    lastZoneEventAtBar := bar_index

if bearishZoneOff
    lastZoneEventText := "BEAR OFF · " + bearishOffReason
    lastZoneEventDirection := -1
    lastZoneEventAtBar := bar_index

if newBullishZone
    lastZoneEventText := "NEW BULL ZONE"
    lastZoneEventDirection := 1
    lastZoneEventAtBar := bar_index

if newBearishZone
    lastZoneEventText := "NEW BEAR ZONE"
    lastZoneEventDirection := -1
    lastZoneEventAtBar := bar_index

if bullishInteraction
    lastZoneEventText := "BULL ZONE TAP"
    lastZoneEventDirection := 1
    lastZoneEventAtBar := bar_index

if bearishInteraction
    lastZoneEventText := "BEAR ZONE TAP"
    lastZoneEventDirection := -1
    lastZoneEventAtBar := bar_index

if bullishGapThrough
    lastZoneEventText := "BULL GAP-THROUGH"
    lastZoneEventDirection := 1
    lastZoneEventAtBar := bar_index

if bearishGapThrough
    lastZoneEventText := "BEAR GAP-THROUGH"
    lastZoneEventDirection := -1
    lastZoneEventAtBar := bar_index

// =============================== DRAWING =====================================
plot(
     currentSwingHigh,
     "Structure swing high",
     color = showSwingLevels ? color.new(BULL_COLOR, 50) : na,
     style = plot.style_stepline,
     linewidth = 1)

plot(
     currentSwingLow,
     "Structure swing low",
     color = showSwingLevels ? color.new(BEAR_COLOR, 50) : na,
     style = plot.style_stepline,
     linewidth = 1)

// Draw the actual broken pivot level from its confirmed pivot time to the
// chart bar where the completed structure-timeframe break becomes available.
//
// Visual grammar is continuation-specific:
//   CHoCH      = dashed, muted context transition
//   BUILD BOS  = dotted, sequence still below the selected threshold
//   CONT BOS   = solid, qualifying or later continuation break
if showStructureBreaks and
     newStructureBar and
     structureEventDirection != 0 and
     not na(brokenStructureLevel) and
     not na(brokenPivotTime)

    color directionColor =
         structureEventDirection == 1
         ? BULL_COLOR
         : BEAR_COLOR

    bool isChoch = structureEventKind == 2
    bool isBos = structureEventKind == 1
    bool isBuildingBos =
         isBos and
         structureBreakCount < requiredBreaks
    bool isContinuationBos =
         isBos and
         structureBreakCount >= requiredBreaks
    bool isActivationBos =
         isContinuationBos and
         structureBreakCount == requiredBreaks

    string breakText =
         isChoch
         ? "CHoCH"
         : isBuildingBos
         ? "BUILD BOS"
         : isActivationBos
         ? "CONT BOS"
         : "CONT BOS"

    string breakStyle =
         isChoch
         ? line.style_dashed
         : isBuildingBos
         ? line.style_dotted
         : line.style_solid

    int breakWidth =
         isChoch
         ? 1
         : isBuildingBos
         ? 1
         : isActivationBos
         ? 3
         : 2

    color lineColor =
         isChoch
         ? color.new(directionColor, 34)
         : isBuildingBos
         ? color.new(directionColor, 42)
         : directionColor

    color labelColor =
         isChoch
         ? color.new(directionColor, 68)
         : isBuildingBos
         ? color.new(directionColor, 76)
         : color.new(directionColor, 12)

    color labelTextColor =
         isChoch or isBuildingBos
         ? CONTEXT_TEXT
         : color.white

    line.new(
         x1 = brokenPivotTime,
         y1 = brokenStructureLevel,
         x2 = time,
         y2 = brokenStructureLevel,
         xloc = xloc.bar_time,
         extend = extend.none,
         color = lineColor,
         style = breakStyle,
         width = breakWidth)

    label.new(
         x = time,
         y = brokenStructureLevel,
         text = breakText,
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_left,
         color = labelColor,
         textcolor = labelTextColor,
         size = size.tiny)

// =============================== ALERTS ======================================
if barstate.isconfirmed
    if bullishZoneOff
        alert(
             f_eventMessage(
                 "ZONE_OFF",
                 "bull",
                 "bull-" + str.tostring(oldBullishSerial),
                 close,
                 bullishOffReason,
                 oldBullishTop,
                 oldBullishBottom,
                 oldBullishMidpoint),
             alert.freq_all)

    if bearishZoneOff
        alert(
             f_eventMessage(
                 "ZONE_OFF",
                 "bear",
                 "bear-" + str.tostring(oldBearishSerial),
                 close,
                 bearishOffReason,
                 oldBearishTop,
                 oldBearishBottom,
                 oldBearishMidpoint),
             alert.freq_all)

    if newBullishZone
        alert(
             f_eventMessage(
                 "ZONE_NEW",
                 "bull",
                 "bull-" + str.tostring(bullishZoneSerial),
                 bullishZoneMidpoint,
                 "",
                 bullishZoneTop,
                 bullishZoneBottom,
                 bullishZoneMidpoint),
             alert.freq_all)

    if newBearishZone
        alert(
             f_eventMessage(
                 "ZONE_NEW",
                 "bear",
                 "bear-" + str.tostring(bearishZoneSerial),
                 bearishZoneMidpoint,
                 "",
                 bearishZoneTop,
                 bearishZoneBottom,
                 bearishZoneMidpoint),
             alert.freq_all)

    if bullishInteraction
        alert(
             f_eventMessage(
                 "ZONE_TAP",
                 "bull",
                 "bull-" + str.tostring(bullishZoneSerial),
                 low,
                 "",
                 bullishZoneTop,
                 bullishZoneBottom,
                 bullishZoneMidpoint),
             alert.freq_all)

    if bearishInteraction
        alert(
             f_eventMessage(
                 "ZONE_TAP",
                 "bear",
                 "bear-" + str.tostring(bearishZoneSerial),
                 high,
                 "",
                 bearishZoneTop,
                 bearishZoneBottom,
                 bearishZoneMidpoint),
             alert.freq_all)

    if bullishGapThrough
        alert(
             f_eventMessage(
                 "ZONE_GAP_THRU",
                 "bull",
                 "bull-" + str.tostring(bullishZoneSerial),
                 close,
                 "",
                 bullishZoneTop,
                 bullishZoneBottom,
                 bullishZoneMidpoint),
             alert.freq_all)

    if bearishGapThrough
        alert(
             f_eventMessage(
                 "ZONE_GAP_THRU",
                 "bear",
                 "bear-" + str.tostring(bearishZoneSerial),
                 close,
                 "",
                 bearishZoneTop,
                 bearishZoneBottom,
                 bearishZoneMidpoint),
             alert.freq_all)

alertcondition(
     newBullishZone or newBearishZone,
     "Continuation OB Lite - New Zone",
     "A new continuation order-block zone was confirmed.")

// ============================== STATUS PANEL =================================
var table statusPanel = table.new(
     position.top_right,
     2,
     11,
     bgcolor = PANEL_BG,
     frame_color = PANEL_BORDER,
     frame_width = 1,
     border_color = PANEL_BORDER,
     border_width = 1)

if showStatusPanel and barstate.islast
    string chartTfLabel = f_timeframeLabel(timeframe.period)
    string structureTfLabel = f_timeframeLabel(structureTf)
    string timeframePair =
         chartTfLabel +
         (sameTimeframeMode ? " = " : " → ") +
         structureTfLabel

    string modeText =
         structureMode == "Auto"
         ? (sameTimeframeMode ? "AUTO · SAME-TF" : "AUTO · HTF MAP")
         : (sameTimeframeMode ? "MANUAL · SAME-TF" : "MANUAL · HTF MAP")

    string shortModel =
         str.startswith(trendModel, "A")
         ? "A · CHoCH + 2 BOS"
         : "B · CHoCH + 1 BOS"

    int visibleProgress = math.min(structureBreakCount, requiredBreaks)

    string structureState =
         structureDirection == 1
         ? (bullishStructure ? "BULL READY · " : "BUILDING BULL · ") +
             str.tostring(visibleProgress) +
             "/" +
             str.tostring(requiredBreaks)
         : structureDirection == -1
         ? (bearishStructure ? "BEAR READY · " : "BUILDING BEAR · ") +
             str.tostring(visibleProgress) +
             "/" +
             str.tostring(requiredBreaks)
         : "WAITING FOR CHoCH"

    int lastBreakAge =
         na(lastStructureEventAtCount)
         ? na
         : completedStructureBars - lastStructureEventAtCount

    string lastBreakDirectionText =
         lastStructureEventDirection == 1
         ? "BULL"
         : lastStructureEventDirection == -1
         ? "BEAR"
         : ""

    string lastBreakText =
         lastStructureEventText == "—"
         ? "—"
         : lastStructureEventText +
             " · " +
             lastBreakDirectionText +
             " · " +
             str.tostring(lastBreakAge) +
             " structure bars ago"

    int bullishZoneAge =
         bullishZoneActive
         ? completedStructureBars - bullishZoneBirth
         : 0

    int bearishZoneAge =
         bearishZoneActive
         ? completedStructureBars - bearishZoneBirth
         : 0

    string bullishZoneState =
         bullishZoneInteracted
         ? "TOUCHED"
         : "FRESH"

    string bearishZoneState =
         bearishZoneInteracted
         ? "TOUCHED"
         : "FRESH"

    string bullishZoneText =
         bullishZoneActive
         ? bullishZoneState +
             " · " +
             str.tostring(bullishZoneAge) +
             " structure · " +
             str.tostring(bullishZoneBottom, format.mintick) +
             "–" +
             str.tostring(bullishZoneTop, format.mintick)
         : "—"

    string bearishZoneText =
         bearishZoneActive
         ? bearishZoneState +
             " · " +
             str.tostring(bearishZoneAge) +
             " structure · " +
             str.tostring(bearishZoneBottom, format.mintick) +
             "–" +
             str.tostring(bearishZoneTop, format.mintick)
         : "—"

    int lastZoneAge =
         na(lastZoneEventAtBar)
         ? na
         : bar_index - lastZoneEventAtBar

    string lastZoneText =
         lastZoneEventText == "—"
         ? "—"
         : lastZoneEventText +
             " · " +
             str.tostring(lastZoneAge) +
             " bars ago"

    string qualificationText =
         (requireBothDispAndFvg ? "DISP + FVG" : "DISP OR FVG") +
         " · ATR " +
         str.tostring(displacementMultiplier) +
         "×"

    string readinessText =
         structureReady
         ? "READY · " +
             str.tostring(structureHighs.size()) +
             " structure bars"
         : "WAITING · " +
             str.tostring(structureHighs.size()) +
             "/" +
             str.tostring(minimumWarmup)

    string processedTimeText =
         na(structureTime)
         ? "—"
         : str.format_time(
             structureTime,
             "yyyy-MM-dd HH:mm",
             syminfo.timezone)

    color structureTextColor =
         structureDirection == 1
         ? BULL_COLOR
         : structureDirection == -1
         ? BEAR_COLOR
         : PANEL_MUTED

    color structureCellColor =
         structureDirection == 1
         ? color.new(BULL_COLOR, bullishStructure ? 82 : 90)
         : structureDirection == -1
         ? color.new(BEAR_COLOR, bearishStructure ? 82 : 90)
         : PANEL_BG

    color lastBreakColor =
         lastStructureEventDirection == 1
         ? BULL_COLOR
         : lastStructureEventDirection == -1
         ? BEAR_COLOR
         : PANEL_MUTED

    color lastZoneColor =
         lastZoneEventDirection == 1
         ? BULL_COLOR
         : lastZoneEventDirection == -1
         ? BEAR_COLOR
         : PANEL_MUTED

    table.cell(
         statusPanel,
         0,
         0,
         "CONTINUATION OB",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_HEADER,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         0,
         timeframePair,
         text_color = PANEL_TEXT,
         bgcolor = PANEL_HEADER,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         1,
         "View",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         1,
         modeText,
         text_color = sameTimeframeMode ? PANEL_TEXT : BULL_COLOR,
         bgcolor = PANEL_BG,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         2,
         "Model",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         2,
         shortModel,
         text_color = PANEL_TEXT,
         bgcolor = PANEL_BG,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         3,
         "Sequence",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         3,
         structureState,
         text_color = structureTextColor,
         bgcolor = structureCellColor,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         4,
         "Last break",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         4,
         lastBreakText,
         text_color = lastBreakColor,
         bgcolor = PANEL_BG,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         5,
         "Bull zone",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         5,
         bullishZoneText,
         text_color = bullishZoneActive ? BULL_COLOR : PANEL_MUTED,
         bgcolor = bullishZoneActive ? color.new(BULL_COLOR, 88) : PANEL_BG,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         6,
         "Bear zone",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         6,
         bearishZoneText,
         text_color = bearishZoneActive ? BEAR_COLOR : PANEL_MUTED,
         bgcolor = bearishZoneActive ? color.new(BEAR_COLOR, 88) : PANEL_BG,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         7,
         "Last zone event",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         7,
         lastZoneText,
         text_color = lastZoneColor,
         bgcolor = PANEL_BG,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         8,
         "Qualification",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         8,
         qualificationText,
         text_color = PANEL_TEXT,
         bgcolor = PANEL_BG,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         9,
         "Data",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         9,
         readinessText,
         text_color = structureReady ? BULL_COLOR : BEAR_COLOR,
         bgcolor = PANEL_BG,
         text_size = size.small)

    table.cell(
         statusPanel,
         0,
         10,
         "Processed bar",
         text_color = PANEL_TEXT,
         bgcolor = PANEL_LABEL,
         text_size = size.small)

    table.cell(
         statusPanel,
         1,
         10,
         processedTimeText,
         text_color = PANEL_MUTED,
         bgcolor = PANEL_BG,
         text_size = size.small)
````
