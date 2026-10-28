# Universal MTF S&R v8 - Structural Zones & Local Swings

- url: https://www.tradingview.com/script/S9MBUKtf-Universal-MTF-S-R-v8-Structural-Zones-Local-Swings/
- type: indicator
- pine_id: PUB;60d2f0667a9142e69002ba4cf6832895
- version: 2.0

## Description

Universal MTF S&R v8 combines confirmed multi-timeframe support/resistance zones with an optional layer of recent local swing highs and lows.

The indicator was developed to answer two practical questions: where are the established structural levels, and which recent price levels might matter before a higher-timeframe pivot confirms?

[b]Structural zones[/b]

The script collects confirmed pivots from Monthly, Weekly, Daily, 4H and optional 1H candles. Nearby levels can merge into zones, with widths based on source-timeframe ATR and a percentage cap.

Structural ranking considers timeframe importance, pivot prominence and repeated evidence. Overlap between different timeframes adds confluence. These ranks describe structural characteristics; they are not probabilities of a successful trade.

Zones are classified relative to the last completed chart candle:
• Green: support below price.
• Amber: price closed inside the zone.
• Red: resistance above price.

[b]Developing and local levels[/b]

A separate layer displays recent highs and lows from completed candles. Candidates initially carry an UNCONFIRMED label. After surviving the configured number of subsequent source candles, they become LOCAL CONFIRMED.

A completed candle’s wick beyond a level removes it. Levels also expire, and the retained history is limited to two highs and two lows. Local confirmation does not increase structural rank.

The local source can use the chart timeframe or a separately selected timeframe. For example, a 4H chart can display 1H local swings alongside higher-timeframe structural zones.

[b]Suggested use[/b]

Start with the default settings on standard candlestick charts. Adjust the local source, visible level count and labels to suit your analysis. Colours, line styles and label appearance are configurable.

An optional Fibonacci overlay uses rolling highs and lows from completed candles.

[b]Timing and limitations[/b]

Structural pivots require right-side confirmation candles. Structural boxes extend back to their originating pivots, but those levels were only identified after confirmation. Local lines begin when their candidates first become observable.

Local levels update from completed source candles, so they can lag intrabar moves. Candidates can disappear, and confirmed local levels can later break or expire. Available history and feed revisions can affect the displayed results.

The absence of a nearby structural zone does not imply an unobstructed price path. This indicator provides chart context; it does not generate entry signals, execute trades or establish trading performance.

[b]Chart examples[/b]

ETH 4H: higher-timeframe support, active zones and resistance alongside developing and locally confirmed swings.
[image]https://www.tradingview.com/x/MYoJw7aa/[/image]

APT 4H: the recent 0.8888 local high and developing local low illustrate why no nearby structural resistance does not mean clear runway.
[image]https://www.tradingview.com/x/0suW0zCE/[/image]

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0.
// Original implementation: Universal MTF S&R v5.
// Standalone multi-timeframe support/resistance visualization. It does not generate trade signals.
//@version=6
indicator("Universal MTF S&R v8.2.1", overlay = true, max_boxes_count = 100, max_labels_count = 100, max_lines_count = 20, max_bars_back = 5000)

string GROUP_TIMEFRAMES = "Timeframes"
string GROUP_DETECTION = "Detection"
string GROUP_DISPLAY = "Display"
string GROUP_FIBONACCI = "Optional Fibonacci"
string GROUP_LOCAL = "Developing / local levels"
string GROUP_LOCAL_STYLE = "Developing / local appearance"

bool showMonthly = input.bool(true, "Monthly", group = GROUP_TIMEFRAMES)
bool showWeekly = input.bool(true, "Weekly", group = GROUP_TIMEFRAMES)
bool showDaily = input.bool(true, "Daily", group = GROUP_TIMEFRAMES)
bool show4Hour = input.bool(true, "4H", group = GROUP_TIMEFRAMES)
bool show1Hour = input.bool(false, "1H", group = GROUP_TIMEFRAMES, tooltip = "Off by default to keep the chart clean. Enable it when you need local intraday levels.")
int monthlyLevelsPerSide = input.int(5, "Monthly pivot depth per side", minval = 1, maxval = 8, group = GROUP_TIMEFRAMES)
int weeklyLevelsPerSide = input.int(6, "Weekly pivot depth per side", minval = 1, maxval = 10, group = GROUP_TIMEFRAMES)
int dailyLevelsPerSide = input.int(8, "Daily pivot depth per side", minval = 1, maxval = 12, group = GROUP_TIMEFRAMES)
int fourHourLevelsPerSide = input.int(6, "4H pivot depth per side", minval = 1, maxval = 12, group = GROUP_TIMEFRAMES)
int oneHourLevelsPerSide = input.int(6, "1H pivot depth per side", minval = 1, maxval = 12, group = GROUP_TIMEFRAMES)
int candidateHistoryMultiplier = input.int(4, "Candidate history multiplier", minval = 2, maxval = 8, group = GROUP_TIMEFRAMES, tooltip = "Keeps a deeper hidden history so important old levels are not discarded. The visible-zone cap still keeps the chart clean.")

int pivotLeftBars = input.int(4, "Pivot bars left", minval = 2, maxval = 20, group = GROUP_DETECTION)
int pivotRightBars = input.int(4, "Pivot bars right", minval = 2, maxval = 20, group = GROUP_DETECTION, tooltip = "A pivot is confirmed after these right-side source bars close. Its confirmed value becomes available at the next source bar opening and is collected on a chart-bar close. Historical coverage depends on the chart's loaded bars.")
int atrLength = input.int(14, "ATR length", minval = 5, maxval = 100, group = GROUP_DETECTION)
float zoneHalfWidthAtr = input.float(0.18, "Zone half-width (source ATR)", minval = 0.05, maxval = 0.50, step = 0.01, group = GROUP_DETECTION)
float maximumZoneHalfWidthPercent = input.float(1.00, "Maximum zone half-width (%)", minval = 0.10, maxval = 3.00, step = 0.05, group = GROUP_DETECTION, tooltip = "Caps the distance from the weighted center to either edge, including merged zones. A two-tick minimum applies. Merges exceeding the cap remain separate.")
float mergeTolerancePercent = input.float(0.35, "MTF merge tolerance (%)", minval = 0.05, maxval = 2.00, step = 0.05, group = GROUP_DETECTION, tooltip = "Nearby confirmed pivots can merge into one zone, provided the merged width stays within the cap. Distinct timeframes add confluence; same-timeframe pivots add repeated evidence.")

string displayView = input.string("Adaptive", "Zone view", options = ["Adaptive", "Full map"], group = GROUP_DISPLAY, tooltip = "Adaptive: daily+ overview (4 per side), above 1H to sub-daily swing (5), 1H and lower detail (6), plus at most 2 active zones. Full map restores the manual cap and nearest reserve. Filtering never deletes retained candidates. Switching the chart interval changes detail; mouse zoom does not.")
int maximumVisibleZonesPerSide = input.int(12, "Maximum zones per side (ceiling)", minval = 2, maxval = 20, group = GROUP_DISPLAY, tooltip = "Adaptive uses the smaller of this ceiling and the timeframe profile limit. Full map uses this limit for support, resistance and active zones separately. Counts are after merging.")
int nearestZonesPerSide = input.int(8, "Full map: nearest reserve", minval = 0, maxval = 20, group = GROUP_DISPLAY, tooltip = "Protects the closest confirmed support and resistance zones, measured from their near edge to the last closed price. This is part of the total limit, not additional zones. Limited to the total when larger. Set 0 for the v8 ranking-only selection. Merging and structural ranks are unchanged.")
bool showLabels = input.bool(true, "Show timeframe labels", group = GROUP_DISPLAY)
bool showZonePrices = input.bool(true, "Include zone center in label", group = GROUP_DISPLAY, display = display.none)
string zoneLabelAlignment = input.string("Left", "Zone text extends from anchor", options = ["Left", "Right"], group = GROUP_DISPLAY, tooltip = "Left keeps labels inside the chart when the latest candle is near the right edge.", display = display.none)
string minimumLabelRank = input.string("Moderate", "Full label detail from rank", options = ["Local", "Moderate", "Strong", "Major"], group = GROUP_DISPLAY, tooltip = "All visible zones have compact source/price labels when labels are enabled. This threshold adds the rank word and stronger emphasis; it no longer hides lower-ranked labels. Rank points remain uncalibrated heuristics, not probabilities.")
string labelTextSize = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_DISPLAY)
bool showQuickGuide = input.bool(true, "Show display summary", group = GROUP_DISPLAY)
string guideTextSize = input.string("Small", "Summary size", options = ["Small", "Normal", "Large"], group = GROUP_DISPLAY)
color supportColor = input.color(color.rgb(0, 190, 120), "Support color", group = GROUP_DISPLAY)
color activeColor = input.color(color.rgb(235, 165, 45), "Active-zone color", group = GROUP_DISPLAY, tooltip = "Used when the last completed chart candle closes inside a zone.")
color resistanceColor = input.color(color.rgb(235, 70, 80), "Resistance color", group = GROUP_DISPLAY)
color labelTextColor = input.color(color.white, "Zone label text color", group = GROUP_DISPLAY, display = display.none)
string warningTextSize = input.string("Normal", "Chart warning size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_DISPLAY, display = display.none)

bool showLocalLevels = input.bool(true, "Show developing / local levels", group = GROUP_LOCAL, tooltip = "A separate, small layer of recent swing highs and lows. It does not add structural rank or change the confirmed MTF zones. Turn off to compare with v7.", display = display.none)
string localTimeframeInput = input.timeframe("", "Local source timeframe (blank = chart)", group = GROUP_LOCAL, tooltip = "Can be below the chart timeframe: closed intrabars are read separately. A higher source uses its previous completed candle. Lower-timeframe history depends on TradingView's intrabar allowance.", display = display.none)
int localLeftBars = input.int(3, "Local swing bars left", minval = 1, maxval = 20, group = GROUP_LOCAL, tooltip = "A completed source candle creates a candidate when its high exceeds, or its low undercuts, all of these preceding candles. No right-side candles are required yet.", display = display.none)
int localConfirmationBars = input.int(4, "Local confirmation bars right", minval = 1, maxval = 20, group = GROUP_LOCAL, tooltip = "UNCONFIRMED becomes LOCAL CONFIRMED after this many completed source candles without a strictly higher high / lower low. Local confirmation does not establish a major structural zone.", display = display.none)
int localMaximumAge = input.int(60, "Expire after source candles", minval = 21, maxval = 500, group = GROUP_LOCAL, tooltip = "Broken levels are removed on a completed source candle's wick beyond them. Old levels expire; at most the two most recent surviving highs and two lows are retained. There is no automatic S/R flip.", display = display.none)
int localLevelsPerSide = input.int(2, "Visible local highs / lows per side", minval = 1, maxval = 2, group = GROUP_LOCAL, display = display.none)
bool showLocalHighs = input.bool(true, "Show local highs", group = GROUP_LOCAL, display = display.none)
bool showLocalLows = input.bool(true, "Show local lows", group = GROUP_LOCAL, display = display.none)
bool showLocalLabels = input.bool(true, "Show local labels", group = GROUP_LOCAL_STYLE, display = display.none)
bool showLocalPrices = input.bool(true, "Include local price in label", group = GROUP_LOCAL_STYLE, display = display.none)
string localLabelSize = input.string("Small", "Local label size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_LOCAL_STYLE, display = display.none)
int localLabelOffset = input.int(3, "Local label offset (chart bars)", minval = 0, maxval = 50, group = GROUP_LOCAL_STYLE, display = display.none)
string localLabelAlignment = input.string("Left", "Local text extends from anchor", options = ["Left", "Right"], group = GROUP_LOCAL_STYLE, tooltip = "Left keeps the text inside the chart when the latest candle is near its right edge.", display = display.none)
string localPendingStyle = input.string("Dashed", "Unconfirmed line style", options = ["Dashed", "Dotted", "Solid"], group = GROUP_LOCAL_STYLE, display = display.none)
string localConfirmedStyle = input.string("Dotted", "Local confirmed line style", options = ["Dashed", "Dotted", "Solid"], group = GROUP_LOCAL_STYLE, display = display.none)
int localLineWidth = input.int(1, "Local line width", minval = 1, maxval = 3, group = GROUP_LOCAL_STYLE, display = display.none)
color localHighColor = input.color(color.rgb(160, 130, 255), "Local high color", group = GROUP_LOCAL_STYLE, display = display.none)
color localLowColor = input.color(color.rgb(70, 180, 240), "Local low color", group = GROUP_LOCAL_STYLE, display = display.none)
color localTextColor = input.color(color.white, "Local label text color", group = GROUP_LOCAL_STYLE, display = display.none)
int localLabelTransparency = input.int(20, "Local label transparency", minval = 0, maxval = 100, group = GROUP_LOCAL_STYLE, display = display.none)
string localHighText = input.string("HIGH", "Local high label text", group = GROUP_LOCAL_STYLE, display = display.none)
string localLowText = input.string("LOW", "Local low label text", group = GROUP_LOCAL_STYLE, display = display.none)
string localPendingText = input.string("UNCONFIRMED", "Developing status text", group = GROUP_LOCAL_STYLE, display = display.none)
string localConfirmedText = input.string("LOCAL CONFIRMED", "Local confirmed status text", group = GROUP_LOCAL_STYLE, display = display.none)

bool useFibonacciConfluence = input.bool(false, "Use Fibonacci confluence", group = GROUP_FIBONACCI, tooltip = "Optional. Fibonacci adds a small structural-rank bonus only when it overlaps an existing MTF zone. Level visibility is controlled separately.")
bool showFibonacciLevels = input.bool(false, "Show Fibonacci levels", group = GROUP_FIBONACCI, tooltip = "Draws Fibonacci levels from the highest and lowest completed candles in the rolling lookback, not from separately confirmed swing pivots. This display setting works independently from confluence scoring.")
int fibonacciLookback = input.int(150, "Fibonacci swing lookback (closed bars)", minval = 30, maxval = 1000, group = GROUP_FIBONACCI)
bool showFibonacciLabels = input.bool(true, "Show Fibonacci labels", group = GROUP_FIBONACCI, display = display.none)
string fibonacciLabelSize = input.string("Small", "Fibonacci label size", options = ["Tiny", "Small", "Normal", "Large"], group = GROUP_FIBONACCI, display = display.none)
color fibonacciLineColor = input.color(color.new(color.silver, 35), "Fibonacci line color", group = GROUP_FIBONACCI, display = display.none)
color fibonacciLabelColor = input.color(color.new(color.gray, 55), "Fibonacci label color", group = GROUP_FIBONACCI, display = display.none)
color fibonacciTextColor = input.color(color.white, "Fibonacci text color", group = GROUP_FIBONACCI, display = display.none)

int SOURCE_1H = 1
int SOURCE_4H = 2
int SOURCE_D = 4
int SOURCE_W = 8
int SOURCE_M = 16

bool standardChartGate = chart.is_standard and not timeframe.isticks
bool replayChart = str.contains(syminfo.tickerid, "replay")
int sourceCutoff = barstate.isrealtime and not replayChart ? timenow : barstate.isconfirmed ? math.min(time_close, timenow) : time
bool closedStandardGate = barstate.isconfirmed and standardChartGate
float chartSeconds = timeframe.isticks ? na : timeframe.in_seconds()
bool include1Hour = show1Hour and chartSeconds <= 3600.0
bool include4Hour = show4Hour and chartSeconds <= 14400.0
bool includeDaily = showDaily and chartSeconds <= 86400.0
bool includeWeekly = showWeekly and chartSeconds <= 604800.0
bool includeMonthly = showMonthly and chartSeconds <= 2678400.0

float displayAtr = ta.atr(atrLength)
// Resolve history on every calculation, outside conditional drawing functions.
// Keep the previous completed candle on realtime updates; preserve warm-up na.
float closedChartPrice = barstate.isconfirmed ? close : close[1]
float closedChartAtr = barstate.isconfirmed ? displayAtr : displayAtr[1]

// These rolling series run every bar; scoring/drawing consumes them only at a closed chart bar.
float fibonacciSwingHigh = ta.highest(high, fibonacciLookback)
float fibonacciSwingLow = ta.lowest(low, fibonacciLookback)
int fibonacciHighOffset = ta.highestbars(high, fibonacciLookback)
int fibonacciLowOffset = ta.lowestbars(low, fibonacciLookback)
float fibonacciRange = fibonacciSwingHigh - fibonacciSwingLow
// Same-candle extrema have no observable chronological swing direction.
bool fibonacciReady = bar_index >= fibonacciLookback - 1 and not na(fibonacciRange) and fibonacciRange > syminfo.mintick and fibonacciHighOffset != fibonacciLowOffset
// Extrema offsets are zero or negative: the older extreme has the smaller offset.
bool fibonacciUpswing = fibonacciLowOffset < fibonacciHighOffset
float fibonacci382 = fibonacciReady ? fibonacciUpswing ? fibonacciSwingHigh - fibonacciRange * 0.382 : fibonacciSwingLow + fibonacciRange * 0.382 : na
float fibonacci500 = fibonacciReady ? fibonacciUpswing ? fibonacciSwingHigh - fibonacciRange * 0.500 : fibonacciSwingLow + fibonacciRange * 0.500 : na
float fibonacci618 = fibonacciReady ? fibonacciUpswing ? fibonacciSwingHigh - fibonacciRange * 0.618 : fibonacciSwingLow + fibonacciRange * 0.618 : na
float fibonacci786 = fibonacciReady ? fibonacciUpswing ? fibonacciSwingHigh - fibonacciRange * 0.786 : fibonacciSwingLow + fibonacciRange * 0.786 : na

type RawLevel
    float price
    float sourceAtr
    int sourceMask
    int sourceTime
    int pivotKind
    float prominenceAtr

type RenderZone
    float center
    float lower
    float upper
    int sourceMask
    float timeframePoints
    float centerWeight
    int evidenceCount
    float prominencePoints
    int earliestTime
    int latestTime
    int role
    bool selected
    box area
    label tag

var array<RawLevel> rawLevels = array.new<RawLevel>()
var array<RenderZone> mergedZones = array.new<RenderZone>()
var table quickGuide = table.new(position.top_right, 2, 4, border_width = 1)
var table localWarning = table.new(position.bottom_right, 1, 1)
var label chartWarning = na
var line fibonacci382Line = na
var line fibonacci500Line = na
var line fibonacci618Line = na
var line fibonacci786Line = na
var label fibonacci382Tag = na
var label fibonacci500Tag = na
var label fibonacci618Tag = na
var label fibonacci786Tag = na

f_pivotHigh(int leftBars, int rightBars) =>
    ta.pivothigh(high, leftBars, rightBars)

f_pivotLow(int leftBars, int rightBars) =>
    ta.pivotlow(low, leftBars, rightBars)

// Local two-sided excursion, not global topographic prominence.
// The weaker side limits the value; the pivot candle itself is excluded from both flanks.
f_balancedProminence(float leftExcursion, float rightExcursion, float pivotAtr) =>
    not na(leftExcursion) and not na(rightExcursion) and not na(pivotAtr) and pivotAtr > 0.0 ? math.max(0.0, math.min(leftExcursion, rightExcursion)) / pivotAtr : na

f_pivotHighProminence(int leftBars, int rightBars, int selectedAtrLength) =>
    float pivot = ta.pivothigh(high, leftBars, rightBars)
    float pivotAtr = ta.atr(selectedAtrLength)[rightBars]
    float leftLow = ta.lowest(low, leftBars)[rightBars + 1]
    float rightLow = ta.lowest(low, rightBars)
    f_balancedProminence(pivot - leftLow, pivot - rightLow, pivotAtr)

f_pivotLowProminence(int leftBars, int rightBars, int selectedAtrLength) =>
    float pivot = ta.pivotlow(low, leftBars, rightBars)
    float pivotAtr = ta.atr(selectedAtrLength)[rightBars]
    float leftHigh = ta.highest(high, leftBars)[rightBars + 1]
    float rightHigh = ta.highest(high, rightBars)
    f_balancedProminence(leftHigh - pivot, rightHigh - pivot, pivotAtr)

[pivotHigh1H, pivotLow1H, pivotTime1H, pivotAtr1H, pivotHighProminence1H, pivotLowProminence1H] = request.security(syminfo.tickerid, "60", [f_pivotHigh(pivotLeftBars, pivotRightBars)[1], f_pivotLow(pivotLeftBars, pivotRightBars)[1], time[pivotRightBars + 1], ta.atr(atrLength)[pivotRightBars + 1], f_pivotHighProminence(pivotLeftBars, pivotRightBars, atrLength)[1], f_pivotLowProminence(pivotLeftBars, pivotRightBars, atrLength)[1]], lookahead = barmerge.lookahead_on)
[pivotHigh4H, pivotLow4H, pivotTime4H, pivotAtr4H, pivotHighProminence4H, pivotLowProminence4H] = request.security(syminfo.tickerid, "240", [f_pivotHigh(pivotLeftBars, pivotRightBars)[1], f_pivotLow(pivotLeftBars, pivotRightBars)[1], time[pivotRightBars + 1], ta.atr(atrLength)[pivotRightBars + 1], f_pivotHighProminence(pivotLeftBars, pivotRightBars, atrLength)[1], f_pivotLowProminence(pivotLeftBars, pivotRightBars, atrLength)[1]], lookahead = barmerge.lookahead_on)
[pivotHighD, pivotLowD, pivotTimeD, pivotAtrD, pivotHighProminenceD, pivotLowProminenceD] = request.security(syminfo.tickerid, "D", [f_pivotHigh(pivotLeftBars, pivotRightBars)[1], f_pivotLow(pivotLeftBars, pivotRightBars)[1], time[pivotRightBars + 1], ta.atr(atrLength)[pivotRightBars + 1], f_pivotHighProminence(pivotLeftBars, pivotRightBars, atrLength)[1], f_pivotLowProminence(pivotLeftBars, pivotRightBars, atrLength)[1]], lookahead = barmerge.lookahead_on)
[pivotHighW, pivotLowW, pivotTimeW, pivotAtrW, pivotHighProminenceW, pivotLowProminenceW] = request.security(syminfo.tickerid, "W", [f_pivotHigh(pivotLeftBars, pivotRightBars)[1], f_pivotLow(pivotLeftBars, pivotRightBars)[1], time[pivotRightBars + 1], ta.atr(atrLength)[pivotRightBars + 1], f_pivotHighProminence(pivotLeftBars, pivotRightBars, atrLength)[1], f_pivotLowProminence(pivotLeftBars, pivotRightBars, atrLength)[1]], lookahead = barmerge.lookahead_on)
[pivotHighM, pivotLowM, pivotTimeM, pivotAtrM, pivotHighProminenceM, pivotLowProminenceM] = request.security(syminfo.tickerid, "M", [f_pivotHigh(pivotLeftBars, pivotRightBars)[1], f_pivotLow(pivotLeftBars, pivotRightBars)[1], time[pivotRightBars + 1], ta.atr(atrLength)[pivotRightBars + 1], f_pivotHighProminence(pivotLeftBars, pivotRightBars, atrLength)[1], f_pivotLowProminence(pivotLeftBars, pivotRightBars, atrLength)[1]], lookahead = barmerge.lookahead_on)

var int lastHighTime1H = na
var int lastLowTime1H = na
var int lastHighTime4H = na
var int lastLowTime4H = na
var int lastHighTimeD = na
var int lastLowTimeD = na
var int lastHighTimeW = na
var int lastLowTimeW = na
var int lastHighTimeM = na
var int lastLowTimeM = na

f_clampFloat(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_hasMask(int combinedMask, int sourceMask) =>
    math.floor(combinedMask / sourceMask) % 2 == 1

f_timeframeWeight(int sourceMask) =>
    sourceMask == 1 ? 10.0 : sourceMask == 2 ? 20.0 : sourceMask == 4 ? 40.0 : sourceMask == 8 ? 60.0 : sourceMask == 16 ? 80.0 : 0.0

f_sourceText(int combinedMask) =>
    string result = ""
    if f_hasMask(combinedMask, SOURCE_M)
        result += "M"
    if f_hasMask(combinedMask, SOURCE_W)
        result += str.length(result) > 0 ? " + W" : "W"
    if f_hasMask(combinedMask, SOURCE_D)
        result += str.length(result) > 0 ? " + D" : "D"
    if f_hasMask(combinedMask, SOURCE_4H)
        result += str.length(result) > 0 ? " + 4H" : "4H"
    if f_hasMask(combinedMask, SOURCE_1H)
        result += str.length(result) > 0 ? " + 1H" : "1H"
    result

f_sourceLongText(int combinedMask) =>
    string result = ""
    if f_hasMask(combinedMask, SOURCE_M)
        result += "Monthly"
    if f_hasMask(combinedMask, SOURCE_W)
        result += str.length(result) > 0 ? " + Weekly" : "Weekly"
    if f_hasMask(combinedMask, SOURCE_D)
        result += str.length(result) > 0 ? " + Daily" : "Daily"
    if f_hasMask(combinedMask, SOURCE_4H)
        result += str.length(result) > 0 ? " + 4H" : "4H"
    if f_hasMask(combinedMask, SOURCE_1H)
        result += str.length(result) > 0 ? " + 1H" : "1H"
    result

f_structureRankName(float score) =>
    score >= 80.0 ? "MAJOR" : score >= 50.0 ? "STRONG" : score >= 30.0 ? "MODERATE" : "LOCAL"

f_minimumLabelScore(string rank) =>
    rank == "Major" ? 80.0 : rank == "Strong" ? 50.0 : rank == "Moderate" ? 30.0 : 0.0

f_textSize(string selectedSize) =>
    selectedSize == "Tiny" ? size.tiny : selectedSize == "Normal" ? size.normal : selectedSize == "Large" ? size.large : size.small

// Local levels are an independent lifecycle. They never enter rawLevels or mergedZones.
type LocalSwing
    float price
    int kind
    int pivotTime
    int availableTime
    int sourceIndex

type LocalSnapshot
    LocalSwing firstHigh
    LocalSwing secondHigh
    LocalSwing firstLow
    LocalSwing secondLow
    int sourceIndex
    int closedAt

// Return new records without changing the prior source-bar state.
f_nextLocalSwings(array<LocalSwing> previous, float candleHigh, float candleLow, float precedingHigh, float precedingLow, int sourceIndex, int openedAt, int closedAt, int maximumAge) =>
    array<LocalSwing> candidates = array.new<LocalSwing>()
    for level in previous
        bool broken = level.kind == -1 ? candleHigh > level.price : candleLow < level.price
        if not broken and sourceIndex - level.sourceIndex <= maximumAge
            array.push(candidates, level.copy())
    if not na(precedingHigh) and candleHigh > precedingHigh
        array.push(candidates, LocalSwing.new(candleHigh, -1, openedAt, closedAt, sourceIndex))
    if not na(precedingLow) and candleLow < precedingLow
        array.push(candidates, LocalSwing.new(candleLow, 1, openedAt, closedAt, sourceIndex))
    array<LocalSwing> retained = array.new<LocalSwing>()
    int highCount = 0
    int lowCount = 0
    int index = array.size(candidates) - 1
    while index >= 0
        LocalSwing candidate = array.get(candidates, index)
        if candidate.kind == -1 and highCount < 2
            array.unshift(retained, candidate)
            highCount += 1
        if candidate.kind == 1 and lowCount < 2
            array.unshift(retained, candidate)
            lowCount += 1
        index -= 1
    retained

// This function executes in the selected source context. Callers expose only closed snapshots.
f_localSnapshot(int leftBars, int maximumAge) =>
    float precedingHigh = ta.highest(high[1], leftBars)
    float precedingLow = ta.lowest(low[1], leftBars)
    var array<LocalSwing> swings = array.new<LocalSwing>()
    if bar_index >= leftBars
        swings := f_nextLocalSwings(swings, high, low, precedingHigh, precedingLow, bar_index, time, time_close, maximumAge)
    LocalSwing firstHigh = na
    LocalSwing secondHigh = na
    LocalSwing firstLow = na
    LocalSwing secondLow = na
    int index = array.size(swings) - 1
    while index >= 0
        LocalSwing level = array.get(swings, index)
        if level.kind == -1
            if na(firstHigh)
                firstHigh := level.copy()
            else
                secondHigh := level.copy()
        else
            if na(firstLow)
                firstLow := level.copy()
            else
                secondLow := level.copy()
        index -= 1
    LocalSnapshot.new(firstHigh, secondHigh, firstLow, secondLow, bar_index, time_close)

f_closedLocalSnapshot(int leftBars, int maximumAge) =>
    LocalSnapshot snapshot = f_localSnapshot(leftBars, maximumAge)
    snapshot[1]

f_localLineStyle(string selectedStyle) =>
    selectedStyle == "Solid" ? line.style_solid : selectedStyle == "Dotted" ? line.style_dotted : line.style_dashed

string localTimeframe = localTimeframeInput == "" ? timeframe.period : localTimeframeInput
float localSeconds = timeframe.isticks ? na : timeframe.in_seconds(localTimeframe)
string localSourceLabel = localSeconds >= 3600.0 and localSeconds < 86400.0 and localSeconds % 3600.0 == 0.0 ? str.tostring(int(localSeconds / 3600.0)) + "H" : localTimeframe + (localSeconds < 3600.0 and localSeconds >= 60.0 ? "m" : "")
var LocalSnapshot latestLocalSnapshot = na

if showLocalLevels and standardChartGate
    if localSeconds < chartSeconds
        // One snapshot per available source intrabar; an open source candle cannot qualify by time.
        array<LocalSnapshot> intrabars = request.security_lower_tf(syminfo.tickerid, localTimeframe, f_localSnapshot(localLeftBars, localMaximumAge), calc_bars_count = 10000)
        for snapshot in intrabars
            if not na(snapshot) and not na(snapshot.closedAt) and snapshot.closedAt <= sourceCutoff
                latestLocalSnapshot := snapshot
    else if localSeconds == chartSeconds
        LocalSnapshot snapshot = f_localSnapshot(localLeftBars, localMaximumAge)
        latestLocalSnapshot := barstate.isconfirmed ? snapshot : snapshot[1]
    else
        latestLocalSnapshot := request.security(syminfo.tickerid, localTimeframe, f_closedLocalSnapshot(localLeftBars, localMaximumAge), lookahead = barmerge.lookahead_on, calc_bars_count = 10000)

// A retained object is not evidence that the source feed has advanced.
f_localFresh(int closedAt, int cutoff, float durationSeconds) =>
    not na(closedAt) and not na(cutoff) and not na(durationSeconds) and closedAt <= cutoff and cutoff - closedAt < durationSeconds * 1000.0

bool localFresh = not na(latestLocalSnapshot) and f_localFresh(latestLocalSnapshot.closedAt, sourceCutoff, localSeconds)

// Start lines when the candidate became observable, rather than backdating them to a pivot.
f_updateLocalVisual(line levelLine, label levelTag, LocalSwing level, int sourceIndex) =>
    line updatedLine = levelLine
    label updatedTag = levelTag
    if not na(level)
        int age = sourceIndex - level.sourceIndex
        bool confirmed = age >= localConfirmationBars
        color levelColor = level.kind == -1 ? localHighColor : localLowColor
        string statusText = confirmed ? localConfirmedText : localPendingText
        string kindText = level.kind == -1 ? localHighText : localLowText
        string lineStyle = f_localLineStyle(confirmed ? localConfirmedStyle : localPendingStyle)
        int rightTime = math.max(time_close, level.availableTime + 1)
        if na(updatedLine)
            updatedLine := line.new(level.availableTime, level.price, rightTime, level.price, xloc = xloc.bar_time, extend = extend.right)
        line.set_xy1(updatedLine, level.availableTime, level.price)
        line.set_xy2(updatedLine, rightTime, level.price)
        line.set_color(updatedLine, levelColor)
        line.set_style(updatedLine, lineStyle)
        line.set_width(updatedLine, localLineWidth)
        if showLocalLabels
            if na(updatedTag)
                updatedTag := label.new(bar_index + localLabelOffset, level.price, "", style = localLabelAlignment == "Left" ? label.style_label_right : label.style_label_left)
            label.set_xy(updatedTag, bar_index + localLabelOffset, level.price)
            label.set_text(updatedTag, localSourceLabel + " · " + kindText + " · " + statusText + (showLocalPrices ? " · " + str.tostring(level.price, format.mintick) : ""))
            label.set_color(updatedTag, color.new(levelColor, localLabelTransparency))
            label.set_textcolor(updatedTag, localTextColor)
            label.set_size(updatedTag, f_textSize(localLabelSize))
            label.set_tooltip(updatedTag, "Recent local swing; independent of structural rank.\nSource: " + localSourceLabel + "\nClosed right-side candles: " + str.tostring(age) + "/" + str.tostring(localConfirmationBars) + "\nFirst observable: " + str.format_time(level.availableTime, "yyyy-MM-dd HH:mm", "UTC") + " UTC\nA higher high / lower low on a closed source candle removes it. Equal touches retain it.\nOlder levels can expire or leave the two-per-side history. No automatic S/R flip.\nUNCONFIRMED candidates can disappear; LOCAL CONFIRMED is not a major-zone rating.")
        else if not na(updatedTag)
            label.delete(updatedTag)
            updatedTag := na
    else
        if not na(updatedLine)
            line.delete(updatedLine)
        if not na(updatedTag)
            label.delete(updatedTag)
        updatedLine := na
        updatedTag := na
    [updatedLine, updatedTag]

var array<line> localLines = array.new<line>(4, na)
var array<label> localTags = array.new<label>(4, na)

if barstate.islast
    LocalSwing firstHigh = na
    LocalSwing secondHigh = na
    LocalSwing firstLow = na
    LocalSwing secondLow = na
    int sourceIndex = na
    if showLocalLevels and standardChartGate and localFresh and (displayView == "Full map" or chartSeconds < 86400.0)
        sourceIndex := latestLocalSnapshot.sourceIndex
        firstHigh := showLocalHighs ? latestLocalSnapshot.firstHigh : na
        secondHigh := showLocalHighs and localLevelsPerSide == 2 ? latestLocalSnapshot.secondHigh : na
        firstLow := showLocalLows ? latestLocalSnapshot.firstLow : na
        secondLow := showLocalLows and localLevelsPerSide == 2 ? latestLocalSnapshot.secondLow : na
    array<LocalSwing> visibleLevels = array.from(firstHigh, secondHigh, firstLow, secondLow)
    for index = 0 to 3
        [updatedLine, updatedTag] = f_updateLocalVisual(array.get(localLines, index), array.get(localTags, index), array.get(visibleLevels, index), sourceIndex)
        array.set(localLines, index, updatedLine)
        array.set(localTags, index, updatedTag)

f_structureColor(color baseColor, float score) =>
    float darknessFactor = score >= 80.0 ? 0.55 : score >= 50.0 ? 0.70 : score >= 30.0 ? 0.85 : 1.00
    int redChannel = int(math.round(color.r(baseColor) * darknessFactor))
    int greenChannel = int(math.round(color.g(baseColor) * darknessFactor))
    int blueChannel = int(math.round(color.b(baseColor) * darknessFactor))
    color.rgb(redChannel, greenChannel, blueChannel)

f_fillTransparency(float score) =>
    score >= 80.0 ? 94 : score >= 50.0 ? 96 : score >= 30.0 ? 97 : 98

f_borderWidth(float score) =>
    score >= 80.0 ? 2 : 1

f_candidateLimit(int configuredCount) =>
    configuredCount * candidateHistoryMultiplier

f_countRawLevels(int sourceMask, int pivotKind) =>
    int count = 0
    int index = 0
    while index < array.size(rawLevels)
        RawLevel level = array.get(rawLevels, index)
        if level.sourceMask == sourceMask and level.pivotKind == pivotKind
            count += 1
        index += 1
    count

f_trimRawLevels(int sourceMask, int pivotKind, int maximumCount) =>
    while f_countRawLevels(sourceMask, pivotKind) > maximumCount
        int oldestIndex = -1
        int index = 0
        while index < array.size(rawLevels) and oldestIndex == -1
            RawLevel level = array.get(rawLevels, index)
            if level.sourceMask == sourceMask and level.pivotKind == pivotKind
                oldestIndex := index
            index += 1
        if oldestIndex >= 0
            array.remove(rawLevels, oldestIndex)

f_addRawLevel(float price, float sourceAtr, int sourceMask, int sourceTime, int pivotKind, float prominenceAtr, int configuredCount) =>
    bool added = not na(price) and not na(sourceAtr) and sourceAtr > 0.0 and not na(sourceTime) and not na(prominenceAtr)
    if added
        array.push(rawLevels, RawLevel.new(price, sourceAtr, sourceMask, sourceTime, pivotKind, prominenceAtr))
        f_trimRawLevels(sourceMask, pivotKind, f_candidateLimit(configuredCount))
    added

f_deleteRenderZone(RenderZone zone) =>
    if not na(zone.area)
        box.delete(zone.area)
    if not na(zone.tag)
        label.delete(zone.tag)

f_clearRenderZones() =>
    int index = 0
    while index < array.size(mergedZones)
        f_deleteRenderZone(array.get(mergedZones, index))
        index += 1
    array.clear(mergedZones)

f_zoneHalfWidth(RawLevel level) =>
    float atrWidth = level.sourceAtr * zoneHalfWidthAtr
    float percentageCap = math.abs(level.price) * maximumZoneHalfWidthPercent * 0.01
    math.max(math.min(atrWidth, percentageCap), syminfo.mintick * 2.0)

f_unionSourceMasks(int firstMask, int secondMask) =>
    int result = firstMask
    if f_hasMask(secondMask, SOURCE_1H) and not f_hasMask(result, SOURCE_1H)
        result += SOURCE_1H
    if f_hasMask(secondMask, SOURCE_4H) and not f_hasMask(result, SOURCE_4H)
        result += SOURCE_4H
    if f_hasMask(secondMask, SOURCE_D) and not f_hasMask(result, SOURCE_D)
        result += SOURCE_D
    if f_hasMask(secondMask, SOURCE_W) and not f_hasMask(result, SOURCE_W)
        result += SOURCE_W
    if f_hasMask(secondMask, SOURCE_M) and not f_hasMask(result, SOURCE_M)
        result += SOURCE_M
    result

f_timeframePointsFromMask(int combinedMask) =>
    float points = 0.0
    if f_hasMask(combinedMask, SOURCE_1H)
        points += f_timeframeWeight(SOURCE_1H)
    if f_hasMask(combinedMask, SOURCE_4H)
        points += f_timeframeWeight(SOURCE_4H)
    if f_hasMask(combinedMask, SOURCE_D)
        points += f_timeframeWeight(SOURCE_D)
    if f_hasMask(combinedMask, SOURCE_W)
        points += f_timeframeWeight(SOURCE_W)
    if f_hasMask(combinedMask, SOURCE_M)
        points += f_timeframeWeight(SOURCE_M)
    points

f_mergeFitsWidth(float firstCenter, float firstWeight, float firstLower, float firstUpper, float secondCenter, float secondWeight, float secondLower, float secondUpper) =>
    float center = (firstCenter * firstWeight + secondCenter * secondWeight) / (firstWeight + secondWeight)
    float halfWidthCap = math.max(math.abs(center) * maximumZoneHalfWidthPercent * 0.01, syminfo.mintick * 2.0)
    float lower = math.min(firstLower, secondLower)
    float upper = math.max(firstUpper, secondUpper)
    // Reject over-wide unions; never trim away a contributing pivot's range.
    math.max(center - lower, upper - center) <= halfWidthCap + syminfo.mintick * 0.000001

f_zonesShouldMerge(RenderZone firstZone, RenderZone secondZone) =>
    float priceReference = math.max(math.abs(firstZone.center), math.abs(secondZone.center))
    float mergeTolerance = math.max(priceReference * mergeTolerancePercent * 0.01, syminfo.mintick * 4.0)
    bool rangesOverlap = firstZone.lower <= secondZone.upper and firstZone.upper >= secondZone.lower
    bool centersNear = math.abs(firstZone.center - secondZone.center) <= mergeTolerance
    (rangesOverlap or centersNear) and f_mergeFitsWidth(firstZone.center, firstZone.centerWeight, firstZone.lower, firstZone.upper, secondZone.center, secondZone.centerWeight, secondZone.lower, secondZone.upper)

f_mergeZonePair(RenderZone firstZone, RenderZone secondZone) =>
    float combinedWeight = firstZone.centerWeight + secondZone.centerWeight
    RenderZone result = firstZone.copy()
    result.center := (firstZone.center * firstZone.centerWeight + secondZone.center * secondZone.centerWeight) / combinedWeight
    result.centerWeight := combinedWeight
    result.lower := math.min(firstZone.lower, secondZone.lower)
    result.upper := math.max(firstZone.upper, secondZone.upper)
    result.sourceMask := f_unionSourceMasks(firstZone.sourceMask, secondZone.sourceMask)
    result.timeframePoints := f_timeframePointsFromMask(result.sourceMask)
    result.evidenceCount += secondZone.evidenceCount
    result.prominencePoints := math.max(firstZone.prominencePoints, secondZone.prominencePoints)
    result.earliestTime := math.min(firstZone.earliestTime, secondZone.earliestTime)
    result.latestTime := math.max(firstZone.latestTime, secondZone.latestTime)
    result

f_consolidateMergedZones() =>
    bool mergedAny = true
    while mergedAny
        mergedAny := false
        int firstIndex = 0
        while firstIndex < array.size(mergedZones) - 1 and not mergedAny
            RenderZone firstZone = array.get(mergedZones, firstIndex)
            int secondIndex = firstIndex + 1
            while secondIndex < array.size(mergedZones) and not mergedAny
                RenderZone secondZone = array.get(mergedZones, secondIndex)
                if f_zonesShouldMerge(firstZone, secondZone)
                    array.set(mergedZones, firstIndex, f_mergeZonePair(firstZone, secondZone))
                    array.remove(mergedZones, secondIndex)
                    mergedAny := true
                else
                    secondIndex += 1
            firstIndex += 1

f_rebuildMergedZones() =>
    f_clearRenderZones()
    int rawIndex = 0
    while rawIndex < array.size(rawLevels)
        RawLevel level = array.get(rawLevels, rawIndex)
        float halfWidth = f_zoneHalfWidth(level)
        float candidateLower = level.price - halfWidth
        float candidateUpper = level.price + halfWidth
        float sourceWeight = f_timeframeWeight(level.sourceMask)
        int matchedIndex = -1
        int zoneIndex = 0
        while zoneIndex < array.size(mergedZones) and matchedIndex == -1
            RenderZone candidateZone = array.get(mergedZones, zoneIndex)
            float priceReference = math.max(math.abs(level.price), math.abs(candidateZone.center))
            float mergeTolerance = math.max(priceReference * mergeTolerancePercent * 0.01, syminfo.mintick * 4.0)
            bool rangesOverlap = candidateLower <= candidateZone.upper and candidateUpper >= candidateZone.lower
            bool centersNear = math.abs(level.price - candidateZone.center) <= mergeTolerance
            if (rangesOverlap or centersNear) and f_mergeFitsWidth(candidateZone.center, candidateZone.centerWeight, candidateZone.lower, candidateZone.upper, level.price, sourceWeight, candidateLower, candidateUpper)
                matchedIndex := zoneIndex
            zoneIndex += 1
        float prominencePoints = f_clampFloat(level.prominenceAtr * 3.0, 0.0, 12.0)
        if matchedIndex >= 0
            RenderZone matchedZone = array.get(mergedZones, matchedIndex)
            matchedZone.center := (matchedZone.center * matchedZone.centerWeight + level.price * sourceWeight) / (matchedZone.centerWeight + sourceWeight)
            matchedZone.centerWeight += sourceWeight
            matchedZone.lower := math.min(matchedZone.lower, candidateLower)
            matchedZone.upper := math.max(matchedZone.upper, candidateUpper)
            matchedZone.earliestTime := math.min(matchedZone.earliestTime, level.sourceTime)
            matchedZone.latestTime := math.max(matchedZone.latestTime, level.sourceTime)
            matchedZone.evidenceCount += 1
            matchedZone.prominencePoints := math.max(matchedZone.prominencePoints, prominencePoints)
            matchedZone.sourceMask := f_unionSourceMasks(matchedZone.sourceMask, level.sourceMask)
            matchedZone.timeframePoints := f_timeframePointsFromMask(matchedZone.sourceMask)
            array.set(mergedZones, matchedIndex, matchedZone)
        else
            RenderZone newZone = RenderZone.new(level.price, candidateLower, candidateUpper, level.sourceMask, sourceWeight, sourceWeight, 1, prominencePoints, level.sourceTime, level.sourceTime, 0, false, na, na)
            array.push(mergedZones, newZone)
        rawIndex += 1
    f_consolidateMergedZones()

f_fibonacciPoints(RenderZone zone) =>
    bool overlap382 = useFibonacciConfluence and fibonacciReady and zone.lower <= fibonacci382 and zone.upper >= fibonacci382
    bool overlap500 = useFibonacciConfluence and fibonacciReady and zone.lower <= fibonacci500 and zone.upper >= fibonacci500
    bool overlap618 = useFibonacciConfluence and fibonacciReady and zone.lower <= fibonacci618 and zone.upper >= fibonacci618
    bool overlap786 = useFibonacciConfluence and fibonacciReady and zone.lower <= fibonacci786 and zone.upper >= fibonacci786
    float points = overlap500 or overlap618 ? 10.0 : overlap382 or overlap786 ? 5.0 : 0.0
    string levelName = overlap618 ? "0.618" : overlap500 ? "0.500" : overlap382 ? "0.382" : overlap786 ? "0.786" : "none"
    [points, levelName]

f_sourceCount(int combinedMask) =>
    int count = 0
    for mask in array.from(SOURCE_1H, SOURCE_4H, SOURCE_D, SOURCE_W, SOURCE_M)
        count += f_hasMask(combinedMask, mask) ? 1 : 0
    count

// First pivot per timeframe is already represented by timeframePoints.
// Extra pivots are repeated observations, not independently verified retests.
f_repeatPoints(int evidenceCount, int combinedMask) =>
    f_clampFloat((evidenceCount - f_sourceCount(combinedMask)) * 3.0, 0.0, 12.0)

f_zoneStructureScore(RenderZone zone, float fibonacciPoints) =>
    float reactionPoints = f_repeatPoints(zone.evidenceCount, zone.sourceMask)
    f_clampFloat(zone.timeframePoints + zone.prominencePoints + reactionPoints + fibonacciPoints, 0.0, 100.0)

f_zoneSelectionScore(RenderZone zone, float referencePrice, float structureScore) =>
    float safeReference = math.max(math.abs(referencePrice), syminfo.mintick)
    float distancePercent = math.abs(zone.center - referencePrice) / safeReference * 100.0
    float proximityPoints = f_clampFloat(24.0 - distancePercent, 0.0, 24.0)
    float ageDays = math.max(0.0, (time - zone.latestTime) / 86400000.0)
    float recencyPoints = f_clampFloat(10.0 - ageDays / 30.0, 0.0, 10.0)
    float majorHistoryBonus = f_hasMask(zone.sourceMask, SOURCE_M) ? 30.0 : f_hasMask(zone.sourceMask, SOURCE_W) ? 15.0 : 0.0
    structureScore + proximityPoints + recencyPoints + majorHistoryBonus

f_displayFullMapSelection(float referencePrice) =>
    array<float> selectionScores = array.new<float>()
    int resetIndex = 0
    while resetIndex < array.size(mergedZones)
        RenderZone resetZone = array.get(mergedZones, resetIndex)
        resetZone.role := referencePrice > resetZone.upper ? 1 : referencePrice < resetZone.lower ? -1 : 0
        resetZone.selected := false
        array.set(mergedZones, resetIndex, resetZone)
        [fibPoints, fibLevel] = f_fibonacciPoints(resetZone)
        array.push(selectionScores, f_zoneSelectionScore(resetZone, referencePrice, f_zoneStructureScore(resetZone, fibPoints)))
        resetIndex += 1
    int role = 1
    while role >= -1
        int selectedCount = 0
        int nearestLimit = role == 0 ? 0 : math.min(nearestZonesPerSide, maximumVisibleZonesPerSide)
        // Reserve nearby merged zones before historical strength consumes the cap.
        while selectedCount < nearestLimit
            int nearestIndex = -1
            float nearestDistance = na
            float nearestScore = -1.0
            for [candidateIndex, candidateZone] in mergedZones
                if candidateZone.role == role and not candidateZone.selected
                    float distance = role == 1 ? referencePrice - candidateZone.upper : candidateZone.lower - referencePrice
                    float score = array.get(selectionScores, candidateIndex)
                    if na(nearestDistance) or distance < nearestDistance or (distance == nearestDistance and score > nearestScore)
                        nearestIndex := candidateIndex
                        nearestDistance := distance
                        nearestScore := score
            if nearestIndex < 0
                break
            RenderZone nearestZone = array.get(mergedZones, nearestIndex)
            nearestZone.selected := true
            array.set(mergedZones, nearestIndex, nearestZone)
            selectedCount += 1
        while selectedCount < maximumVisibleZonesPerSide
            int bestIndex = -1
            float bestScore = -1.0
            int candidateIndex = 0
            while candidateIndex < array.size(mergedZones)
                RenderZone candidateZone = array.get(mergedZones, candidateIndex)
                if candidateZone.role == role and not candidateZone.selected
                    float selectionScore = array.get(selectionScores, candidateIndex)
                    if selectionScore > bestScore
                        bestScore := selectionScore
                        bestIndex := candidateIndex
                candidateIndex += 1
            if bestIndex >= 0
                RenderZone bestZone = array.get(mergedZones, bestIndex)
                bestZone.selected := true
                array.set(mergedZones, bestIndex, bestZone)
                selectedCount += 1
            else
                selectedCount := maximumVisibleZonesPerSide
        role -= 1

// Display policy only: the source mask, rank, center and boundaries are never changed.
// Thresholds are usability defaults, not calibrated reaction probabilities.
f_displayProfile(float seconds) =>
    seconds >= 86400.0 ? "Overview" : seconds > 3600.0 ? "Swing" : "Detail"

f_displaySideLimit(float seconds, int manualLimit) =>
    math.min(manualLimit, seconds >= 86400.0 ? 4 : seconds > 3600.0 ? 5 : 6)

f_displayDistance(RenderZone zone, float referencePrice) =>
    math.max(0.0, math.max(zone.lower - referencePrice, referencePrice - zone.upper))

f_displayNearestIndex(array<RenderZone> zones, array<bool> chosen, array<bool> eligible, array<float> scores, int role, float referencePrice) =>
    int result = -1
    float bestDistance = na
    float bestScore = na
    for [index, zone] in zones
        if zone.role == role and not array.get(chosen, index) and array.get(eligible, index)
            float distance = f_displayDistance(zone, referencePrice)
            float score = array.get(scores, index)
            if result < 0 or distance < bestDistance or (distance == bestDistance and score > bestScore)
                result := index
                bestDistance := distance
                bestScore := score
    result

// Returns a new selection; input zones/arrays are read-only.
// A 0.5 ATR allowance softens the distance boundary. Updates use closed candles;
// this is not stateful hysteresis, so no hidden live-only selection memory is required.
f_displayAdaptiveSelection(array<RenderZone> zones, array<float> structureScores, array<float> selectionScores, float referencePrice, float seconds, float referenceAtr, int manualLimit) =>
    int count = array.size(zones)
    if count != array.size(structureScores) or count != array.size(selectionScores)
        runtime.error("S&R display selection: zone and score counts differ.")
    array<bool> chosen = array.new<bool>(count, false)
    array<bool> allEligible = array.new<bool>(count, true)
    array<bool> nearby = array.new<bool>(count, false)
    array<bool> anchors = array.new<bool>(count, false)
    bool overview = seconds >= 86400.0
    float radius = referenceAtr * 12.5
    float minimumScore = seconds > 3600.0 ? 30.0 : 0.0
    for [index, zone] in zones
        float distance = f_displayDistance(zone, referencePrice)
        array.set(nearby, index, overview or (not na(radius) and distance <= radius))
        bool higherSource = zone.sourceMask >= (overview ? SOURCE_W : SOURCE_D)
        array.set(anchors, index, higherSource and (overview or (not na(radius) and distance <= radius * 2.0)))
    for role in array.from(1, 0, -1)
        int limit = role == 0 ? math.min(manualLimit, 2) : f_displaySideLimit(seconds, manualLimit)
        int selectedCount = 0
        if role != 0
            // Always show the nearest obstacle, even if weak or distant.
            int nearest = f_displayNearestIndex(zones, chosen, allEligible, selectionScores, role, referencePrice)
            if nearest >= 0
                array.set(chosen, nearest, true)
                selectedCount += 1
            // Protect the anchor before optional detail when the user ceiling is small.
            bool anchorSelected = false
            for [index, zone] in zones
                anchorSelected := anchorSelected or (zone.role == role and array.get(chosen, index) and array.get(anchors, index))
            if not anchorSelected and selectedCount < limit
                int anchor = f_displayNearestIndex(zones, chosen, anchors, selectionScores, role, referencePrice)
                if anchor >= 0
                    array.set(chosen, anchor, true)
                    selectedCount += 1
            // Reserve a second nearby obstacle when the remaining ceiling allows it.
            int nextNear = f_displayNearestIndex(zones, chosen, nearby, selectionScores, role, referencePrice)
            if nextNear >= 0 and selectedCount < limit
                array.set(chosen, nextNear, true)
                selectedCount += 1
        while selectedCount < limit
            int bestIndex = -1
            float bestScore = na
            for [index, zone] in zones
                bool eligible = role == 0 or (array.get(nearby, index) and array.get(structureScores, index) >= minimumScore)
                if zone.role == role and not array.get(chosen, index) and eligible
                    float score = array.get(selectionScores, index)
                    if bestIndex < 0 or score > bestScore
                        bestIndex := index
                        bestScore := score
            if bestIndex < 0
                break
            array.set(chosen, bestIndex, true)
            selectedCount += 1
    chosen

f_selectBestZones(float referencePrice, float referenceAtr) =>
    if displayView == "Full map"
        f_displayFullMapSelection(referencePrice)
    else
        array<float> structureScores = array.new<float>()
        array<float> selectionScores = array.new<float>()
        for zone in mergedZones
            zone.role := referencePrice > zone.upper ? 1 : referencePrice < zone.lower ? -1 : 0
            [fibPoints, fibLevel] = f_fibonacciPoints(zone)
            float structureScore = f_zoneStructureScore(zone, fibPoints)
            array.push(structureScores, structureScore)
            array.push(selectionScores, f_zoneSelectionScore(zone, referencePrice, structureScore))
        array<bool> chosen = f_displayAdaptiveSelection(mergedZones, structureScores, selectionScores, referencePrice, chartSeconds, referenceAtr, maximumVisibleZonesPerSide)
        for [index, zone] in mergedZones
            zone.selected := array.get(chosen, index)
    // Both branches update drawing selection; keep the unused return type consistent.
    true

f_zoneLabelText(RenderZone zone, float score) =>
    string roleLetter = zone.role == 1 ? "S" : zone.role == 0 ? "A" : "R"
    string rankText = score >= f_minimumLabelScore(minimumLabelRank) ? " · " + f_structureRankName(score) : ""
    roleLetter + " · " + f_sourceText(zone.sourceMask) + rankText + (showZonePrices ? " · " + str.tostring(zone.center, format.mintick) : "")

f_zoneTooltip(RenderZone zone, float score, float fibonacciPoints, string fibonacciLevel, float selectionScore) =>
    string roleName = zone.role == 1 ? "SUPPORT" : zone.role == 0 ? "ACTIVE ZONE" : "RESISTANCE"
    roleName + " · " + f_structureRankName(score) + " structural rank · " + str.tostring(int(math.round(score))) + " heuristic points (not probability)\n" +
      "Zone range: " + str.tostring(zone.lower, format.mintick) + " - " + str.tostring(zone.upper, format.mintick) + "\n" +
      "Timeframes: " + f_sourceLongText(zone.sourceMask) + "\n" +
      "Timeframe weight: " + str.tostring(int(math.round(zone.timeframePoints))) + "\n" +
      "Merged confirmed pivots: " + str.tostring(zone.evidenceCount) + "\n" +
      "Additional same-TF observations: +" + str.tostring(f_repeatPoints(zone.evidenceCount, zone.sourceMask), "0") + "\n" +
      "Two-sided prominence: +" + str.tostring(int(math.round(zone.prominencePoints))) + "\n" +
      "Fibonacci " + fibonacciLevel + ": +" + str.tostring(int(math.round(fibonacciPoints))) + "\n" +
      "Selection rank: " + str.tostring(int(math.round(selectionScore))) + "\n" +
      "Weights are design choices, not fitted success rates. Sources can share the same swing; merged pivots are not retest counts.\n" +
      "First / latest pivot: " + str.format_time(zone.earliestTime, "yyyy-MM-dd", "UTC") + " / " + str.format_time(zone.latestTime, "yyyy-MM-dd", "UTC") + "\n" +
      "Current map projected back to pivot origins, not a historical signal record. This indicator does not generate entries."

f_renderMergedZones(float referencePrice, float referenceAtr) =>
    f_selectBestZones(referencePrice, referenceAtr)
    // Free deselected drawings before allocating replacements, avoiding transient GC.
    for zone in mergedZones
        if not zone.selected
            f_deleteRenderZone(zone)
            zone.area := na
            zone.tag := na
    float minimumScore = f_minimumLabelScore(minimumLabelRank)
    int index = 0
    while index < array.size(mergedZones)
        RenderZone zone = array.get(mergedZones, index)
        if zone.selected
            [fibonacciPoints, fibonacciLevel] = f_fibonacciPoints(zone)
            float score = f_zoneStructureScore(zone, fibonacciPoints)
            float selectionScore = f_zoneSelectionScore(zone, referencePrice, score)
            color baseColor = zone.role == 1 ? supportColor : zone.role == 0 ? activeColor : resistanceColor
            color strengthColor = f_structureColor(baseColor, score)
            int fillTransparency = f_fillTransparency(score)
            int borderWidth = f_borderWidth(score)
            if na(zone.area)
                zone.area := box.new(zone.earliestTime, zone.upper, time, zone.lower, xloc = xloc.bar_time, extend = extend.right)
            box.set_right(zone.area, time)
            box.set_bgcolor(zone.area, color.new(strengthColor, fillTransparency))
            box.set_border_color(zone.area, color.new(strengthColor, score >= 50.0 ? 35 : 60))
            box.set_border_width(zone.area, borderWidth)
            if showLabels
                if na(zone.tag)
                    zone.tag := label.new(time, zone.center, "", xloc = xloc.bar_time, style = zoneLabelAlignment == "Left" ? label.style_label_right : label.style_label_left, textcolor = labelTextColor, size = f_textSize(labelTextSize))
                label.set_xy(zone.tag, time, zone.center)
                label.set_text(zone.tag, f_zoneLabelText(zone, score))
                label.set_color(zone.tag, color.new(strengthColor, score >= minimumScore ? 30 : 65))
                label.set_tooltip(zone.tag, f_zoneTooltip(zone, score, fibonacciPoints, fibonacciLevel, selectionScore))
            else if not na(zone.tag)
                label.delete(zone.tag)
                zone.tag := na
        array.set(mergedZones, index, zone)
        index += 1

f_sourceStatus(bool selected, float sourceSeconds) =>
    not selected ? "OFF" : chartSeconds <= sourceSeconds ? "ON" : "LOWER TF"

// Summarize filtered higher-timeframe context without extending another shaded band.
f_hiddenAnchorText(array<RenderZone> zones, int role, float referencePrice, float seconds) =>
    int nearestIndex = -1
    float nearestDistance = na
    for [index, zone] in zones
        bool higherSource = zone.sourceMask >= (seconds >= 86400.0 ? SOURCE_W : SOURCE_D)
        if zone.role == role and not zone.selected and higherSource
            float distance = f_displayDistance(zone, referencePrice)
            if nearestIndex < 0 or distance < nearestDistance
                nearestIndex := index
                nearestDistance := distance
    string result = "none retained"
    if nearestIndex >= 0
        RenderZone nearest = array.get(zones, nearestIndex)
        result := str.tostring(nearest.center, format.mintick) + " (" + f_sourceText(nearest.sourceMask) + ")"
    result

f_updateQuickGuide(float referencePrice, float referenceAtr) =>
    if showQuickGuide
        string textSize = f_textSize(guideTextSize)
        color headerColor = color.rgb(35, 40, 48)
        color bodyColor = color.rgb(22, 26, 32)
        string profile = displayView == "Full map" ? "Full map" : f_displayProfile(chartSeconds)
        string sourceStatus = "M " + f_sourceStatus(showMonthly, 2678400.0) + " / W " + f_sourceStatus(showWeekly, 604800.0) + " / D " + f_sourceStatus(showDaily, 86400.0) + " / 4H " + f_sourceStatus(show4Hour, 14400.0) + " / 1H " + f_sourceStatus(show1Hour, 3600.0)
        int sideLimit = displayView == "Full map" ? maximumVisibleZonesPerSide : f_displaySideLimit(chartSeconds, maximumVisibleZonesPerSide)
        int activeLimit = displayView == "Full map" ? maximumVisibleZonesPerSide : math.min(2, maximumVisibleZonesPerSide)
        string profileTooltip = "Limits: " + str.tostring(sideLimit) + " support, " + str.tostring(sideLimit) + " resistance, " + str.tostring(activeLimit) + " active. Nearest obstacle on each side is protected in Adaptive.\n" + sourceStatus + "\nLOWER TF sources are excluded on this chart. Widths and ranks are unchanged. Labels show centers; hover a label for boundaries."
        table.cell(quickGuide, 0, 0, "S&R v8.2.1", bgcolor = headerColor, text_color = color.white, text_size = textSize, tooltip = profileTooltip)
        table.cell(quickGuide, 1, 0, profile, bgcolor = headerColor, text_color = color.white, text_size = textSize, tooltip = profileTooltip)
        int totalSupports = 0
        int totalResistances = 0
        int totalActive = 0
        int shownSupports = 0
        int shownResistances = 0
        int shownActive = 0
        for zone in mergedZones
            totalSupports += zone.role == 1 ? 1 : 0
            totalResistances += zone.role == -1 ? 1 : 0
            totalActive += zone.role == 0 ? 1 : 0
            shownSupports += zone.role == 1 and zone.selected ? 1 : 0
            shownResistances += zone.role == -1 and zone.selected ? 1 : 0
            shownActive += zone.role == 0 and zone.selected ? 1 : 0
        string counts = "S " + str.tostring(shownSupports) + "/" + str.tostring(totalSupports) + " · R " + str.tostring(shownResistances) + "/" + str.tostring(totalResistances) + " · A " + str.tostring(shownActive) + "/" + str.tostring(totalActive)
        string coverage = "Visible / retained merged zones. A = price inside the zone at the last chart close, not an entry signal. Hidden levels still exist. History and source eligibility limit coverage; empty space does not establish an absence of support/resistance. Full map broadens selection but still has a cap."
        table.cell(quickGuide, 0, 1, "Shown / retained", bgcolor = bodyColor, text_color = color.silver, text_size = textSize, tooltip = coverage)
        table.cell(quickGuide, 1, 1, counts, bgcolor = bodyColor, text_color = color.white, text_size = textSize, tooltip = coverage)
        string hiddenAnchors = "S " + f_hiddenAnchorText(mergedZones, 1, referencePrice, chartSeconds) + " · R " + f_hiddenAnchorText(mergedZones, -1, referencePrice, chartSeconds)
        string hiddenTooltip = "Nearest hidden higher-timeframe zones by near edge. Daily+ on swing/detail charts; Weekly+ on overview charts. These centers are context outside the drawn selection, not new calculations or guaranteed turning points."
        table.cell(quickGuide, 0, 2, "Hidden HTF", bgcolor = bodyColor, text_color = color.silver, text_size = textSize, tooltip = hiddenTooltip)
        table.cell(quickGuide, 1, 2, hiddenAnchors, bgcolor = bodyColor, text_color = color.silver, text_size = textSize, tooltip = hiddenTooltip)
        bool overviewHidesLocal = displayView == "Adaptive" and chartSeconds >= 86400.0
        string localStatus = not showLocalLevels ? "OFF" : not standardChartGate ? "BLOCKED" : overviewHidesLocal ? "Hidden in overview" : na(latestLocalSnapshot) ? "Waiting for data" : not localFresh ? "Stale / gap" : localSourceLabel + " · closed candles"
        string localTooltip = "Local lines are separate from confirmed structural zones. Adaptive overview hides them without changing their calculation.\n" + (na(referenceAtr) ? "Distance filter is waiting for chart ATR; nearest obstacles remain protected." : "Adaptive swing/detail distance: 12.5 chart ATR = " + str.tostring(referenceAtr * 12.5, format.mintick) + "; higher-timeframe anchor allowance: 25 ATR. These are display choices, not forecasts.") + "\nStructural confirmation: " + str.tostring(pivotRightBars) + " source bars, then source availability and a chart close."
        table.cell(quickGuide, 0, 3, "Local layer", bgcolor = bodyColor, text_color = color.silver, text_size = textSize, tooltip = localTooltip)
        table.cell(quickGuide, 1, 3, localStatus, bgcolor = bodyColor, text_color = color.silver, text_size = textSize, tooltip = localTooltip)
    else
        table.clear(quickGuide, 0, 0, 1, 3)

f_updateFibonacciVisual(line levelLine, label levelTag, float levelPrice, string ratioText) =>
    line updatedLine = levelLine
    label updatedTag = levelTag
    bool levelVisible = standardChartGate and showFibonacciLevels and fibonacciReady
    int leftBar = math.max(0, bar_index + math.min(fibonacciHighOffset, fibonacciLowOffset))
    if levelVisible
        if na(updatedLine)
            updatedLine := line.new(leftBar, levelPrice, bar_index, levelPrice, color = fibonacciLineColor, style = line.style_dotted, width = 1)
        else
            line.set_xy1(updatedLine, leftBar, levelPrice)
            line.set_xy2(updatedLine, bar_index, levelPrice)
        if showFibonacciLabels
            if na(updatedTag)
                updatedTag := label.new(bar_index, levelPrice, "Fib " + ratioText, style = label.style_label_left, color = fibonacciLabelColor, textcolor = fibonacciTextColor, size = f_textSize(fibonacciLabelSize))
            label.set_x(updatedTag, bar_index)
            label.set_y(updatedTag, levelPrice)
            label.set_text(updatedTag, "Fib " + ratioText)
        else if not na(updatedTag)
            label.delete(updatedTag)
            updatedTag := na
    else
        if not na(updatedLine)
            line.delete(updatedLine)
        if not na(updatedTag)
            label.delete(updatedTag)
        updatedLine := na
        updatedTag := na
    [updatedLine, updatedTag]

bool rawLevelsChanged = false
if closedStandardGate
    if include1Hour and not na(pivotHigh1H) and (na(lastHighTime1H) or pivotTime1H != lastHighTime1H)
        rawLevelsChanged := f_addRawLevel(pivotHigh1H, pivotAtr1H, SOURCE_1H, pivotTime1H, -1, pivotHighProminence1H, oneHourLevelsPerSide) or rawLevelsChanged
        lastHighTime1H := pivotTime1H
    if include1Hour and not na(pivotLow1H) and (na(lastLowTime1H) or pivotTime1H != lastLowTime1H)
        rawLevelsChanged := f_addRawLevel(pivotLow1H, pivotAtr1H, SOURCE_1H, pivotTime1H, 1, pivotLowProminence1H, oneHourLevelsPerSide) or rawLevelsChanged
        lastLowTime1H := pivotTime1H
    if include4Hour and not na(pivotHigh4H) and (na(lastHighTime4H) or pivotTime4H != lastHighTime4H)
        rawLevelsChanged := f_addRawLevel(pivotHigh4H, pivotAtr4H, SOURCE_4H, pivotTime4H, -1, pivotHighProminence4H, fourHourLevelsPerSide) or rawLevelsChanged
        lastHighTime4H := pivotTime4H
    if include4Hour and not na(pivotLow4H) and (na(lastLowTime4H) or pivotTime4H != lastLowTime4H)
        rawLevelsChanged := f_addRawLevel(pivotLow4H, pivotAtr4H, SOURCE_4H, pivotTime4H, 1, pivotLowProminence4H, fourHourLevelsPerSide) or rawLevelsChanged
        lastLowTime4H := pivotTime4H
    if includeDaily and not na(pivotHighD) and (na(lastHighTimeD) or pivotTimeD != lastHighTimeD)
        rawLevelsChanged := f_addRawLevel(pivotHighD, pivotAtrD, SOURCE_D, pivotTimeD, -1, pivotHighProminenceD, dailyLevelsPerSide) or rawLevelsChanged
        lastHighTimeD := pivotTimeD
    if includeDaily and not na(pivotLowD) and (na(lastLowTimeD) or pivotTimeD != lastLowTimeD)
        rawLevelsChanged := f_addRawLevel(pivotLowD, pivotAtrD, SOURCE_D, pivotTimeD, 1, pivotLowProminenceD, dailyLevelsPerSide) or rawLevelsChanged
        lastLowTimeD := pivotTimeD
    if includeWeekly and not na(pivotHighW) and (na(lastHighTimeW) or pivotTimeW != lastHighTimeW)
        rawLevelsChanged := f_addRawLevel(pivotHighW, pivotAtrW, SOURCE_W, pivotTimeW, -1, pivotHighProminenceW, weeklyLevelsPerSide) or rawLevelsChanged
        lastHighTimeW := pivotTimeW
    if includeWeekly and not na(pivotLowW) and (na(lastLowTimeW) or pivotTimeW != lastLowTimeW)
        rawLevelsChanged := f_addRawLevel(pivotLowW, pivotAtrW, SOURCE_W, pivotTimeW, 1, pivotLowProminenceW, weeklyLevelsPerSide) or rawLevelsChanged
        lastLowTimeW := pivotTimeW
    if includeMonthly and not na(pivotHighM) and (na(lastHighTimeM) or pivotTimeM != lastHighTimeM)
        rawLevelsChanged := f_addRawLevel(pivotHighM, pivotAtrM, SOURCE_M, pivotTimeM, -1, pivotHighProminenceM, monthlyLevelsPerSide) or rawLevelsChanged
        lastHighTimeM := pivotTimeM
    if includeMonthly and not na(pivotLowM) and (na(lastLowTimeM) or pivotTimeM != lastLowTimeM)
        rawLevelsChanged := f_addRawLevel(pivotLowM, pivotAtrM, SOURCE_M, pivotTimeM, 1, pivotLowProminenceM, monthlyLevelsPerSide) or rawLevelsChanged
        lastLowTimeM := pivotTimeM

bool shouldRefreshVisuals = barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed)

if shouldRefreshVisuals
    [refreshed382Line, refreshed382Tag] = f_updateFibonacciVisual(fibonacci382Line, fibonacci382Tag, fibonacci382, "0.382")
    [refreshed500Line, refreshed500Tag] = f_updateFibonacciVisual(fibonacci500Line, fibonacci500Tag, fibonacci500, "0.500")
    [refreshed618Line, refreshed618Tag] = f_updateFibonacciVisual(fibonacci618Line, fibonacci618Tag, fibonacci618, "0.618")
    [refreshed786Line, refreshed786Tag] = f_updateFibonacciVisual(fibonacci786Line, fibonacci786Tag, fibonacci786, "0.786")
    fibonacci382Line := refreshed382Line
    fibonacci382Tag := refreshed382Tag
    fibonacci500Line := refreshed500Line
    fibonacci500Tag := refreshed500Tag
    fibonacci618Line := refreshed618Line
    fibonacci618Tag := refreshed618Tag
    fibonacci786Line := refreshed786Line
    fibonacci786Tag := refreshed786Tag
    if standardChartGate
        if not na(chartWarning)
            label.delete(chartWarning)
        chartWarning := na
        if rawLevelsChanged or array.size(mergedZones) == 0
            f_rebuildMergedZones()
        f_renderMergedZones(closedChartPrice, closedChartAtr)
    else
        f_clearRenderZones()
        if na(chartWarning)
            chartWarning := label.new(bar_index, high, "BLOCKED: USE STANDARD CANDLES", style = label.style_label_down, color = color.orange, textcolor = color.black, size = f_textSize(warningTextSize))

if barstate.islast
    f_updateQuickGuide(closedChartPrice, closedChartAtr)
    table.clear(localWarning, 0, 0, 0, 0)
    if showLocalLevels and standardChartGate and not localFresh
        string localWarningText = na(latestLocalSnapshot) ? "Local levels: no closed source data" : "Local levels hidden: stale / missing source updates"
        table.cell(localWarning, 0, 0, localWarningText, bgcolor = color.rgb(35, 40, 48), text_color = color.orange, text_size = f_textSize(warningTextSize), tooltip = na(latestLocalSnapshot) ? "No eligible closed snapshot." : "Last source close: " + str.format_time(latestLocalSnapshot.closedAt, "yyyy-MM-dd HH:mm", "UTC") + " UTC. No break/confirmation can be inferred across missing data.")

// Display selection never changes retained candidates, zone widths or structural rank.
````
