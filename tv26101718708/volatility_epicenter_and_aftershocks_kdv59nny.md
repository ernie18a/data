# Volatility Epicenter and Aftershocks

- url: https://www.tradingview.com/script/KDV59nnY-Volatility-Epicenter-and-Aftershocks/
- type: indicator
- pine_id: PUB;43532167f7184e71870038a856db6660
- version: 1.0

## Description

Volatility Epicenter and Aftershocks is an event-conditioned market-memory indicator. It detects moments when a recent six-bar path is unusually dominated by one or two returns and unusually active relative to the same part of the trading session.
https://www.tradingview.com/x/62iT906V/
When a primary Shock is confirmed, the indicator freezes a movement box around that bar's close. The box does not say price will rise or fall. Its height comes from the maximum excursions of completed historical Shock events over the same forward horizon.

HOW MARKET MEMORY WORKS
https://www.tradingview.com/x/GCGvYUdL/
This script does not use an LSTM or neural network. Its memory consists of rolling empirical distributions and a transparent event-state machine.
For log return r(t) = ln(Close(t) / Close(t−1)), the recent path and volatility concentration are:

Path = Σ|r|
Concentration = Σr⁴ / (Σr²)²

Seasonal memory compares the current Path with its median at the same time in previous sessions:
Seasonal Ratio = Current Path / Same-Time Historical Median
A Shock occurs when both Concentration and Seasonal Ratio exceed their rolling percentile thresholds. Thresholds are calculated before adding the current observation, preventing leakage.

After each Shock matures, the script stores its maximum 3-, 5- and 10-bar excursion:
Excursion(h) = max[ln(Highest(h) / Shock Close), |ln(Lowest(h) / Shock Close)|]
The box uses the selected percentile of completed 10-bar excursions:
Upper = Shock Close × exp(Excursion Percentile)
Lower = Shock Close × exp(−Excursion Percentile)
The first Shock fixes the box and expiry. Additional detections inside that window become A, B, C aftershocks without restarting it.
[b]In simplified form:[/b]
shock = concentration >= historical_threshold
        and seasonal_ratio >= historical_threshold
box_height = percentile(completed_shock_excursions)


[b]This is empirical market memory[/b]—not ATR, candle-size projection or black-box prediction.
Why this is not another breakout or large-candle script
•	A breakout is defined by price crossing a level. Epicenter does not use support, resistance, channels, or prior highs and lows to define a Shock.
•	A large-candle alert is usually defined by one candle's body or range. Epicenter evaluates the structure of a multi-bar return path.
•	ATR measures average true range. Epicenter asks whether the same amount of movement arrived in a concentrated burst rather than being distributed across bars.
•	The empirical box is not an ATR multiple and is not projected from the Shock candle's size. It is learned from completed post-Shock excursions.
What market memory means

Read the chart in ten seconds
https://www.tradingview.com/x/fI2cCAn0/
•	Shock - the primary volatility event. It starts the original movement window.
•	Solid rectangle - the empirical range associated with the primary shock.
•	A, B, C... - additional shocks detected before the original window ends.
•	Dotted rectangles - aftershock context. They are not scored as separate targets.
•	Standalone green check - price reached either boundary of the primary box before expiry.
•	Standalone red cross - the original window ended before either boundary was reached.

What the box means
https://www.tradingview.com/x/CPO9YAny/
The range is learned from the maximum excursions of completed historical shock events. Box-height percentile controls how wide that range is:
•	P50 is the typical reach. Approximately half of comparable completed shocks moved farther and half moved less.
•	P85 is a wider stress envelope. Only a smaller minority of comparable completed shocks moved farther.
The box is symmetric because the model estimates movement magnitude, not direction. A wider box is not a stronger bullish or bearish opinion.

Practical use
•	Separate an ordinary large candle from a path whose volatility structure is genuinely unusual for that session time.
•	Add event context to a breakout: a breakout with no Shock is a level event; a breakout with a Shock also carries concentrated-volatility risk.
•	Recognize a Shock inside a range even when no breakout system would react.
•	Use P50 as a typical remembered excursion and P85 as a wider stress envelope when planning exposure, stops, or monitoring intensity.
•	Audit whether the remembered boundary was reached before the original ten-bar window cooled.

How the event is detected
The engine uses confirmed chart bars and combines two conditions across the recent six-bar path:
1.	Variance concentration: whether one or two returns dominate the recent path's realized variance.
2.	Seasonal volatility abnormality: how active the recent path is compared with the same bar position in prior sessions.
A primary event appears only when both measures exceed their rolling thresholds. Additional detections inside the primary window are labelled as aftershocks rather than restarting the main outcome test.

Non-repainting design
•	Events are confirmed only after a chart bar closes.
•	The primary box coordinates are frozen when created.
•	Aftershocks do not extend or reset the primary box's original window.
•	A check or X is added only after the corresponding outcome is observable.
•	Keep all preserves historical boxes for audit. Latest only is an explicit display choice that suppresses secondary boxes.
Recommended starting setup
•	Timeframe: 15 minutes.
•	Session preset: Auto.
•	Box-height percentile: 50.
•	Box history: Keep all.
•	Zone annotations: Marks only.

Recommended presets:
https://www.tradingview.com/x/Kl3BxvTJ/
SPY, QQQ and US stocks: US ETF RTH
NQ and ES: CME equity futures
Gold, Silver and energy futures: Metals / energy futures
Bitcoin and crypto: Crypto 24/7
NIFTY and BANKNIFTY: Custom session, 09:15 start and 25 bars per session on a 15-minute chart

BOX HEIGHT
https://www.tradingview.com/x/SCuvyxyu/
P50 shows the typical historical reach and is the recommended default.
P60 to P75 shows an expanded movement range.
P80 to P85 shows a wider stress envelope.

A higher percentile is not a stronger prediction. It simply displays a wider historical range.

HIGHER-TIMEFRAME BOXES

Use Adaptive mode on charts above 15 minutes. Boxes become available after five completed Shock outcomes and may use outcomes that cross session boundaries.
Strict mode requires the full historical sample and same-session outcomes.
Early Shocks may appear without boxes while the market memory is warming up. The script does not add boxes retrospectively because that would introduce lookahead.

DISPLAY
https://www.tradingview.com/x/slrNqWkv/
Keep all preserves historical boxes for auditing.
Latest only keeps the newest primary box.
Marks only is recommended. It displays checks and crosses without adding text inside boxes.
Full text adds explanations inside boxes but may become crowded.

SENSITIVITY
https://www.tradingview.com/x/D797IhaP/
Recommended balanced settings are a six-bar path, concentration percentile of 80, seasonal-volatility percentile of 50 and a ten-bar aftershock window.
Higher thresholds produce fewer and more exceptional Shocks. Lower thresholds produce more signals.

Changing the timeframe, session preset or detection settings recalculates the model across the available chart history. This is recalculation under a different configuration, not repainting.
Session presets are included for US ETF regular hours, CME equity futures, metals and energy futures, crypto, and custom sessions. The model must collect enough calibration and completed-event history before boxes can be displayed.

https://www.tradingview.com/x/NHsAQAB1/
ALERTS
•	Primary volatility epicenter detected.
•	Secondary aftershock detected.
•	Projected percentile boundary achieved.
•	Original aftershock window cooled.

Important limitations
•	This is not a buy/sell system and does not predict direction.
•	The empirical range describes this symbol's observed history; it is not a guarantee of

## Source Code

````pine
//@version=6
indicator("Volatility Epicenter [NeuralMarkets] — Research v3", "NM Volatility Epicenter", overlay = true, max_boxes_count = 200, max_labels_count = 500, max_lines_count = 200)

// Non-directional research indicator.
// It detects paths whose realized variance is dominated by one or two returns,
// then learns forward maximum-excursion ranges from matured historical epicenters.
// Confirmed bars only. Optimized and researched on 15-minute data.

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────

string GROUP_SESSION = "Session profile"
string sessionPreset = input.string("Auto", "Session preset", options = ["Auto", "US ETF RTH", "CME equity futures", "Metals / energy futures", "Crypto 24/7", "Custom"], group = GROUP_SESSION)
int customStartHour = input.int(9, "Custom start hour", 0, 23, group = GROUP_SESSION, inline = "custom")
int customStartMinute = input.int(30, "Minute", 0, 59, group = GROUP_SESSION, inline = "custom")
int customSessionSlots = input.int(26, "Custom bars/session", 1, 500, group = GROUP_SESSION)
int seasonalSessions = input.int(20, "Seasonal baseline sessions", 10, 60, group = GROUP_SESSION, tooltip = "Each path is compared with the same bar position in prior sessions.")

string GROUP_ENGINE = "Epicenter engine"
int pathWindow = input.int(6, "Recent path length (bars)", 4, 20, group = GROUP_ENGINE)
int concentrationPercentile = input.int(80, "Concentration percentile", 60, 95, group = GROUP_ENGINE)
int volatilityPercentile = input.int(50, "Minimum seasonal-volatility percentile", 20, 80, group = GROUP_ENGINE)
int calibrationSamples = input.int(1500, "Rolling calibration samples", 300, 5000, group = GROUP_ENGINE)
int minCalibrationSamples = input.int(200, "Minimum calibration samples", 100, 1000, group = GROUP_ENGINE)
int aftershockBars = input.int(10, "Aftershock state length", 3, 30, group = GROUP_ENGINE)

string GROUP_MODEL = "Empirical range model"
int modelSamples = input.int(250, "Completed events retained", 50, 1000, group = GROUP_MODEL)
int minModelSamples = input.int(20, "Events required before halos", 10, 100, group = GROUP_MODEL)
int boxPercentile = input.int(50, "Box-height percentile", 50, 85, 5, group = GROUP_MODEL, tooltip = "50 = typical reach: roughly half of comparable shocks moved farther. 85 = stress envelope: only roughly 15–20% moved farther.")
string rangeWarmupMode = input.string("Adaptive", "Higher-timeframe box warm-up", options = ["Adaptive", "Strict"], group = GROUP_MODEL, tooltip = "Adaptive shows higher-timeframe boxes after 5 completed Shock outcomes and allows the ten-bar outcome to cross a session boundary. Strict preserves the full event requirement and same-session-only outcome rule. Both modes use completed Shock outcomes—not ATR—to size the box.")

string GROUP_VISUAL = "Visuals"
bool showHalos = input.bool(true, "Show active aftershock zone", group = GROUP_VISUAL)
bool showEpicenters = input.bool(true, "Show historical SHOCK markers", group = GROUP_VISUAL)
string boxHistoryMode = input.string("Keep all", "Box history", options = ["Keep all", "Latest only"], group = GROUP_VISUAL, tooltip = "Keep all preserves completed zones so signals remain auditable. Latest only removes the previous zone when a new shock appears.")
int maximumStoredZones = input.int(60, "Maximum stored zones", 10, 150, group = GROUP_VISUAL, tooltip = "Applies to Keep all mode. Pine has drawing limits, so the oldest zone is removed only after this cap is reached.")
string zoneAnnotationMode = input.string("Marks only", "Zone annotations", options = ["Marks only", "Full text", "None"], group = GROUP_VISUAL, tooltip = "Marks only keeps overlapping zones clean with a green tick for a hit and a red X for a miss. Full text restores status sentences inside boxes.")
bool showAftershockTint = input.bool(false, "Tint active aftershock state", group = GROUP_VISUAL)
bool showCooledMarker = input.bool(false, "Show cooled markers", group = GROUP_VISUAL)

int effectiveMinCalibration = math.min(minCalibrationSamples, calibrationSamples)
int effectiveMinModel = math.min(minModelSamples, modelSamples)
string boxMeaning = boxPercentile <= 60 ? "TYPICAL REACH" : boxPercentile >= 80 ? "STRESS ENVELOPE" : "PROJECTED RANGE"
bool showZoneText = zoneAnnotationMode == "Full text"
bool showOutcomeMarks = zoneAnnotationMode == "Marks only"

// ─────────────────────────────────────────────────────────────────────────────
// Data structures and helpers
// ─────────────────────────────────────────────────────────────────────────────

type SeasonalProfile
    array<float> values
    array<int> cursors
    array<int> counts
    int slots
    int lookback

newSeasonalProfile(int slots, int lookback) =>
    int safeSlots = math.max(slots, 1)
    int safeLookback = math.max(lookback, 2)
    SeasonalProfile.new(array.new_float(safeSlots * safeLookback, na), array.new_int(safeSlots, 0), array.new_int(safeSlots, 0), safeSlots, safeLookback)

method observe(SeasonalProfile this, int slot, float value, int minSamples = 10) =>
    float historicalMedian = na
    int samplesBeforeWrite = 0
    bool valid = slot >= 0 and slot < this.slots and not na(value)
    if valid
        samplesBeforeWrite := array.get(this.counts, slot)
        if samplesBeforeWrite >= minSamples
            array<float> history = array.new_float()
            int base = slot * this.lookback
            for i = 0 to samplesBeforeWrite - 1
                float observation = array.get(this.values, base + i)
                if not na(observation)
                    array.push(history, observation)
            if array.size(history) >= minSamples
                historicalMedian := array.median(history)
        int cursor = array.get(this.cursors, slot)
        array.set(this.values, slot * this.lookback + cursor, value)
        array.set(this.cursors, slot, (cursor + 1) % this.lookback)
        array.set(this.counts, slot, math.min(samplesBeforeWrite + 1, this.lookback))
    [historicalMedian, samplesBeforeWrite]

clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

pushBounded(array<float> values, float value, int maximumSize) =>
    if not na(value)
        array.push(values, value)
        if array.size(values) > maximumSize
            array.shift(values)
    array.size(values)

pathStatistics(array<float> returns) =>
    float realizedPath = 0.0
    float quadratic = 0.0
    float fourth = 0.0
    float maximumSquare = 0.0
    int count = array.size(returns)
    if count > 0
        for i = 0 to count - 1
            float r = array.get(returns, i)
            float square = r * r
            realizedPath += math.abs(r)
            quadratic += square
            fourth += square * square
            maximumSquare := math.max(maximumSquare, square)
    float concentration = quadratic > 0.0 ? fourth / (quadratic * quadratic) : na
    float dominantShare = quadratic > 0.0 ? maximumSquare / quadratic : na
    [realizedPath, concentration, dominantShare]

maximumExcursion(float anchor, float highestValue, float lowestValue) =>
    anchor > 0.0 and highestValue > 0.0 and lowestValue > 0.0 ? math.max(math.log(highestValue / anchor), math.abs(math.log(lowestValue / anchor))) : na

percentileOrNa(array<float> values, int minimumSamples, int percentile) =>
    array.size(values) >= minimumSamples ? array.percentile_nearest_rank(values, percentile) : na

aftershockCode(int sequence) =>
    string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    int zeroBased = math.max(sequence - 1, 0)
    zeroBased < 26 ? str.substring(alphabet, zeroBased, zeroBased + 1) : "A" + str.substring(alphabet, math.min(zeroBased - 26, 25), math.min(zeroBased - 25, 26))

// ─────────────────────────────────────────────────────────────────────────────
// Session routing
// ─────────────────────────────────────────────────────────────────────────────

float chartMinutesFloat = timeframe.in_seconds() / 60.0
int chartMinutes = int(math.max(chartMinutesFloat, 1.0))
bool isCrypto = syminfo.type == "crypto"
bool isCashAsset = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr"

int autoStartHour = isCrypto ? 0 : isCashAsset ? 9 : 17
int autoStartMinute = isCrypto ? 0 : isCashAsset ? 30 : 0
int autoSessionMinutes = isCrypto ? 1440 : isCashAsset ? 390 : 1380
int autoSlots = math.max(1, int(math.floor(autoSessionMinutes / chartMinutesFloat)))

int startHour = switch sessionPreset
    "US ETF RTH" => 9
    "CME equity futures" => 17
    "Metals / energy futures" => 18
    "Crypto 24/7" => 0
    "Custom" => customStartHour
    => autoStartHour

int startMinute = switch sessionPreset
    "US ETF RTH" => 30
    "CME equity futures" => 0
    "Metals / energy futures" => 0
    "Crypto 24/7" => 0
    "Custom" => customStartMinute
    => autoStartMinute

int configuredSlots = switch sessionPreset
    "US ETF RTH" => math.max(1, int(math.floor(390.0 / chartMinutesFloat)))
    "CME equity futures" => math.max(1, int(math.floor(1380.0 / chartMinutesFloat)))
    "Metals / energy futures" => math.max(1, int(math.floor(1380.0 / chartMinutesFloat)))
    "Crypto 24/7" => math.max(1, int(math.floor(1440.0 / chartMinutesFloat)))
    "Custom" => customSessionSlots
    => autoSlots

bool higherTimeframe = chartMinutesFloat > 15.0
bool adaptiveHigherTimeframe = rangeWarmupMode == "Adaptive" and higherTimeframe
int rangeMinimumSamples = adaptiveHigherTimeframe ? math.min(effectiveMinModel, 5) : effectiveMinModel
bool allowCrossSessionOutcomes = adaptiveHigherTimeframe

int minuteOfDay = hour * 60 + minute
int sessionStartMinute = startHour * 60 + startMinute
int minutesFromStart = (minuteOfDay - sessionStartMinute + 1440) % 1440
int sessionSlot = int(math.floor(minutesFromStart / chartMinutesFloat))
bool validSessionBar = sessionSlot >= 0 and sessionSlot < configuredSlots
bool newSession = validSessionBar and (not validSessionBar[1] or sessionSlot < sessionSlot[1])

// ─────────────────────────────────────────────────────────────────────────────
// Confirmed-bar feature engine
// ─────────────────────────────────────────────────────────────────────────────

var array<float> pathReturns = array.new_float()
var SeasonalProfile seasonalPath = newSeasonalProfile(configuredSlots, seasonalSessions)
var array<float> concentrationHistory = array.new_float()
var array<float> volatilityRatioHistory = array.new_float()
var array<float> excursion3Samples = array.new_float()
var array<float> excursion5Samples = array.new_float()
var array<float> excursion10Samples = array.new_float()
var box activeZone = na
var line activeAnchorLine = na
var array<box> storedZones = array.new_box()
var array<line> storedAnchorLines = array.new_line()
var array<bool> storedZoneHits = array.new_bool()
var array<label> storedTargetLabels = array.new_label()
var array<bool> storedPrimaryZones = array.new_bool()
var array<label> shockBubbleLabels = array.new_label()

var int sessionSequence = 0
var int primaryWindowEnd = na
var int aftershockSequence = 0
var float currentPath = na
var float concentration = na
var float dominantShockShare = na
var float seasonalMedianPath = na
var float volatilityRatio = na
var float concentrationThreshold = na
var float volatilityThreshold = na
var float shockScore = na
var float empiricalHalo3 = na
var float empiricalHalo5 = na
var float empiricalHalo10 = na
var bool rangeModelReady = false

bool epicenterEvent = false
bool primaryShockEvent = false
bool secondaryAftershockEvent = false
int currentAftershockNumber = 0

float highest3 = ta.highest(high, 3)
float lowest3 = ta.lowest(low, 3)
float highest5 = ta.highest(high, 5)
float lowest5 = ta.lowest(low, 5)
float highest10 = ta.highest(high, 10)
float lowest10 = ta.lowest(low, 10)

if barstate.isconfirmed
    currentPath := na
    concentration := na
    dominantShockShare := na
    seasonalMedianPath := na
    volatilityRatio := na
    shockScore := na

    if newSession
        sessionSequence += 1
        array.clear(pathReturns)

    if validSessionBar and not newSession and close > 0.0 and close[1] > 0.0
        array.push(pathReturns, math.log(close / close[1]))
        if array.size(pathReturns) > pathWindow
            array.shift(pathReturns)

    if validSessionBar and array.size(pathReturns) == pathWindow
        [realizedPath, pathConcentration, maximumShare] = pathStatistics(pathReturns)
        currentPath := realizedPath
        concentration := pathConcentration
        dominantShockShare := maximumShare
        [historicalPath, seasonalCount] = seasonalPath.observe(sessionSlot, currentPath, 10)
        seasonalMedianPath := historicalPath
        volatilityRatio := not na(historicalPath) and historicalPath > 0.0 ? currentPath / historicalPath : na

        bool calibrationReady = array.size(concentrationHistory) >= effectiveMinCalibration and array.size(volatilityRatioHistory) >= effectiveMinCalibration
        concentrationThreshold := calibrationReady ? array.percentile_nearest_rank(concentrationHistory, concentrationPercentile) : na
        volatilityThreshold := calibrationReady ? array.percentile_nearest_rank(volatilityRatioHistory, volatilityPercentile) : na

        if calibrationReady and not na(concentrationThreshold) and not na(volatilityThreshold) and concentrationThreshold > 0.0 and volatilityThreshold > 0.0
            float concentrationRatio = concentration / concentrationThreshold
            float seasonalRatio = volatilityRatio / volatilityThreshold
            shockScore := clamp(50.0 + 25.0 * (concentrationRatio - 1.0) + 25.0 * (seasonalRatio - 1.0), 0.0, 100.0)
            epicenterEvent := concentration >= concentrationThreshold and volatilityRatio >= volatilityThreshold

        pushBounded(concentrationHistory, concentration, calibrationSamples)
        pushBounded(volatilityRatioHistory, volatilityRatio, calibrationSamples)

    // Cluster shocks without extending the first shock's original outcome window.
    if epicenterEvent
        primaryShockEvent := na(primaryWindowEnd) or bar_index > primaryWindowEnd
        secondaryAftershockEvent := not primaryShockEvent
        if primaryShockEvent
            primaryWindowEnd := bar_index + aftershockBars
            aftershockSequence := 0
        else
            aftershockSequence += 1
            currentAftershockNumber := aftershockSequence

    // On the researched 15-minute setting, outcomes remain same-session only.
    // Higher-timeframe Adaptive mode permits cross-session maturation because a
    // complete ten-bar outcome often cannot fit inside one trading session.
    if epicenterEvent[3] and (allowCrossSessionOutcomes or sessionSequence == sessionSequence[3])
        pushBounded(excursion3Samples, maximumExcursion(close[3], highest3, lowest3), modelSamples)
    if epicenterEvent[5] and (allowCrossSessionOutcomes or sessionSequence == sessionSequence[5])
        pushBounded(excursion5Samples, maximumExcursion(close[5], highest5, lowest5), modelSamples)
    if epicenterEvent[10] and (allowCrossSessionOutcomes or sessionSequence == sessionSequence[10])
        pushBounded(excursion10Samples, maximumExcursion(close[10], highest10, lowest10), modelSamples)

    empiricalHalo3 := percentileOrNa(excursion3Samples, rangeMinimumSamples, boxPercentile)
    empiricalHalo5 := percentileOrNa(excursion5Samples, rangeMinimumSamples, boxPercentile)
    empiricalHalo10 := percentileOrNa(excursion10Samples, rangeMinimumSamples, boxPercentile)
    // The displayed box uses the ten-bar distribution, so shorter-horizon
    // distributions must not unnecessarily block a valid ten-bar box.
    rangeModelReady := not na(empiricalHalo10)

    if epicenterEvent
        if boxHistoryMode == "Latest only" and primaryShockEvent
            while array.size(storedZones) > 0
                box.delete(array.shift(storedZones))
                line.delete(array.shift(storedAnchorLines))
                array.shift(storedZoneHits)
                array.shift(storedPrimaryZones)
                label priorTargetLabel = array.shift(storedTargetLabels)
                if not na(priorTargetLabel)
                    label.delete(priorTargetLabel)
            activeZone := na
            activeAnchorLine := na
        bool drawThisZone = boxHistoryMode == "Keep all" or primaryShockEvent
        if showHalos and rangeModelReady and drawThisZone
            bool isPrimaryZone = primaryShockEvent
            color zoneColor = isPrimaryZone ? color.rgb(245, 98, 73) : color.rgb(245, 154, 66)
            string zoneBorderStyle = isPrimaryZone ? line.style_solid : line.style_dotted
            string initialZoneText = showZoneText ? (isPrimaryZone ? boxMeaning + " · P" + str.tostring(boxPercentile) + "\nDIRECTION UNKNOWN" : "AFTERSHOCK · DOTTED\nNO SEPARATE TARGET") : ""
            activeZone := box.new(bar_index, close * math.exp(empiricalHalo10), bar_index + aftershockBars, close * math.exp(-empiricalHalo10), border_color = color.new(zoneColor, isPrimaryZone ? 25 : 48), border_width = isPrimaryZone ? 2 : 1, border_style = zoneBorderStyle, bgcolor = color.new(zoneColor, isPrimaryZone ? 91 : 95), text = initialZoneText, text_color = color.new(color.white, 12), text_size = size.small, text_halign = text.align_center, text_valign = text.align_top)
            activeAnchorLine := line.new(bar_index, close, bar_index + aftershockBars, close, color = color.new(zoneColor, isPrimaryZone ? 58 : 70), style = isPrimaryZone ? line.style_dashed : line.style_dotted, width = 1)
            array.push(storedZones, activeZone)
            array.push(storedAnchorLines, activeAnchorLine)
            array.push(storedZoneHits, false)
            array.push(storedTargetLabels, na)
            array.push(storedPrimaryZones, isPrimaryZone)
            int retentionLimit = boxHistoryMode == "Keep all" ? maximumStoredZones : 1
            while array.size(storedZones) > retentionLimit
                box.delete(array.shift(storedZones))
                line.delete(array.shift(storedAnchorLines))
                array.shift(storedZoneHits)
                array.shift(storedPrimaryZones)
                label oldestTargetLabel = array.shift(storedTargetLabels)
                if not na(oldestTargetLabel)
                    label.delete(oldestTargetLabel)

// ─────────────────────────────────────────────────────────────────────────────
// State and visuals
// ─────────────────────────────────────────────────────────────────────────────

int eventAge = ta.barssince(primaryShockEvent)
bool aftershockActive = not na(eventAge) and eventAge > 0 and eventAge <= aftershockBars
bool cooledNow = not na(eventAge) and eventAge == aftershockBars + 1
string state = primaryShockEvent ? "EPICENTER" : secondaryAftershockEvent ? "AFTERSHOCK" : aftershockActive ? "AFTERSHOCK" : cooledNow ? "COOLED" : "NORMAL"

color epicenterColor = color.rgb(245, 98, 73)
color aftershockColor = color.rgb(245, 154, 66)
color normalColor = color.rgb(145, 153, 166)
color stateColor = primaryShockEvent ? epicenterColor : secondaryAftershockEvent or aftershockActive ? aftershockColor : normalColor

if barstate.isconfirmed and showEpicenters and primaryShockEvent
    string shockTooltip = rangeModelReady ? "Primary volatility shock · empirical range ready" : "Primary volatility shock · range memory warming up: " + str.tostring(array.size(excursion10Samples)) + "/" + str.tostring(rangeMinimumSamples) + " completed outcomes"
    label shockBubble = label.new(bar_index, high, "Shock", yloc = yloc.abovebar, style = label.style_circle, color = epicenterColor, textcolor = color.white, size = size.small, tooltip = shockTooltip)
    array.push(shockBubbleLabels, shockBubble)
if barstate.isconfirmed and showEpicenters and secondaryAftershockEvent
    string aftershockName = aftershockCode(currentAftershockNumber)
    label aftershockLetter = label.new(bar_index, high, aftershockName, yloc = yloc.abovebar, style = label.style_none, textcolor = aftershockColor, size = size.large, tooltip = "Aftershock " + aftershockName)
    array.push(shockBubbleLabels, aftershockLetter)
while array.size(shockBubbleLabels) > maximumStoredZones * 2
    label.delete(array.shift(shockBubbleLabels))
plotshape(showCooledMarker and cooledNow, "Aftershock cooled", shape.circle, location.abovebar, color = color.new(normalColor, 25), size = size.tiny, text = "C", textcolor = normalColor)
bgcolor(showAftershockTint and (primaryShockEvent or secondaryAftershockEvent or aftershockActive) ? color.new(stateColor, primaryShockEvent ? 94 : 97) : na, title = "Aftershock state tint")

bool targetHitNow = false
if barstate.isconfirmed and array.size(storedZones) > 0
    for zoneIndex = 0 to array.size(storedZones) - 1
        box trackedZone = array.get(storedZones, zoneIndex)
        bool isPrimaryZone = array.get(storedPrimaryZones, zoneIndex)
        bool targetWasHit = array.get(storedZoneHits, zoneIndex)
        int zoneStart = box.get_left(trackedZone)
        int zoneEnd = box.get_right(trackedZone)
        bool insideForwardWindow = bar_index > zoneStart and bar_index <= zoneEnd
        bool upperTargetHit = isPrimaryZone and insideForwardWindow and high >= box.get_top(trackedZone)
        bool lowerTargetHit = isPrimaryZone and insideForwardWindow and low <= box.get_bottom(trackedZone)
        if not targetWasHit and (upperTargetHit or lowerTargetHit)
            targetHitNow := true
            array.set(storedZoneHits, zoneIndex, true)
            string hitSide = upperTargetHit and lowerTargetHit ? "BOTH SIDES" : upperTargetHit ? "UPPER TARGET" : "LOWER TARGET"
            box.set_border_color(trackedZone, color.new(color.rgb(0, 201, 167), 5))
            box.set_border_width(trackedZone, 2)
            box.set_bgcolor(trackedZone, color.new(color.rgb(0, 201, 167), 91))
            box.set_text(trackedZone, showZoneText ? "TARGET ACHIEVED · P" + str.tostring(boxPercentile) + "\n" + hitSide + " · RANGE FROZEN" : "")
            if showOutcomeMarks
                float zoneHeight = box.get_top(trackedZone) - box.get_bottom(trackedZone)
                float outcomeY = math.max(high, box.get_top(trackedZone)) + math.max(zoneHeight * 0.12, syminfo.mintick * 10.0)
                label hitMarker = label.new(bar_index, outcomeY, "✓", style = label.style_none, textcolor = color.rgb(0, 201, 167), size = size.large, tooltip = "P" + str.tostring(boxPercentile) + " target achieved · " + hitSide)
                array.set(storedTargetLabels, zoneIndex, hitMarker)
        else if isPrimaryZone and not targetWasHit and insideForwardWindow
            box.set_text(trackedZone, showZoneText ? "MOVEMENT WINDOW · " + str.tostring(zoneEnd - bar_index) + " BARS LEFT\nP" + str.tostring(boxPercentile) + " " + boxMeaning + " · DIRECTION UNKNOWN" : "")
        else if isPrimaryZone and not targetWasHit and bar_index == zoneEnd + 1
            box.set_text(trackedZone, showZoneText ? "COMPLETED · P" + str.tostring(boxPercentile) + " TARGET NOT HIT\nDIRECTION WAS NOT PREDICTED" : "")
            if showOutcomeMarks
                float zoneHeight = box.get_top(trackedZone) - box.get_bottom(trackedZone)
                float outcomeY = math.max(high, box.get_top(trackedZone)) + math.max(zoneHeight * 0.12, syminfo.mintick * 10.0)
                label missMarker = label.new(bar_index, outcomeY, "×", style = label.style_none, textcolor = color.rgb(245, 98, 73), size = size.large, tooltip = "P" + str.tostring(boxPercentile) + " target not reached before the movement window expired")
                array.set(storedTargetLabels, zoneIndex, missMarker)

alertcondition(primaryShockEvent, "Volatility epicenter detected", "Volatility Epicenter: a new primary variance-shock window was detected on {{ticker}} {{interval}}. Direction remains unresolved.")
alertcondition(secondaryAftershockEvent, "Secondary aftershock detected", "Volatility Epicenter: an additional shock occurred inside the active primary window on {{ticker}} {{interval}}.")
alertcondition(targetHitNow, "Projected target achieved", "Volatility Epicenter: a projected percentile boundary was reached on {{ticker}} {{interval}}.")
alertcondition(cooledNow, "Aftershock state cooled", "Volatility Epicenter: the configured aftershock window has expired on {{ticker}} {{interval}}.")

// Data-window diagnostics.
plot(concentration, "Variance concentration", color = color.new(color.gray, 100), display = display.data_window)
plot(dominantShockShare, "Dominant shock share", color = color.new(color.gray, 100), display = display.data_window)
plot(volatilityRatio, "Seasonal realized-path ratio", color = color.new(color.gray, 100), display = display.data_window)
plot(concentrationThreshold, "Concentration threshold", color = color.new(color.gray, 100), display = display.data_window)
plot(volatilityThreshold, "Seasonal-volatility threshold", color = color.new(color.gray, 100), display = display.data_window)
plot(shockScore, "Shock score", color = color.new(color.gray, 100), display = display.data_window)
plot(empiricalHalo3, "Empirical 3-bar excursion", color = color.new(color.gray, 100), display = display.data_window)
plot(empiricalHalo5, "Empirical 5-bar excursion", color = color.new(color.gray, 100), display = display.data_window)
plot(empiricalHalo10, "Empirical 10-bar excursion", color = color.new(color.gray, 100), display = display.data_window)
plot(array.size(excursion10Samples), "Completed 10-bar Shock outcomes", color = color.new(color.gray, 100), display = display.data_window)
plot(rangeMinimumSamples, "Shock outcomes required for boxes", color = color.new(color.gray, 100), display = display.data_window)
plot(rangeModelReady ? 1 : 0, "Range memory ready (1 = yes)", color = color.new(color.gray, 100), display = display.data_window)
````
