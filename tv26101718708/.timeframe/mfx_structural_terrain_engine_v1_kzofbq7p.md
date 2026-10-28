# MFx Structural Terrain Engine V1

- url: https://www.tradingview.com/script/kZofBq7p-MFx-Structural-Terrain-Engine-V1/
- type: indicator
- pine_id: PUB;7e7c8f36d1bb438e978ed0f13a2fcfd1
- version: 3.0

## Description

Description

Mfx Structural Terrain Engine is a market structure indicator designed to place price into a long-term structural context rather than relying on traditional overbought/oversold oscillators.

Instead of asking: "Is price high or low?"

the engine asks: "Where is price relative to its long-term structural growth path?"

The indicator combines:
Structural Power Law modeling
Long-term moving average context
Adaptive terrain zones
Multi-timeframe structural analysis to classify where price currently resides within the broader market cycle.

The engine is designed to work across multiple asset classes including cryptocurrencies, equities, ETFs, indices, commodities, and forex using asset-specific structural profiles and automatic higher-timeframe routing.

Rather than producing buy or sell signals, it provides a structural framework for evaluating opportunity, fair value, accumulation, and potential exhaustion.

Features
Multi-asset structural profiles
Automatic higher-timeframe routing (TradFi & Crypto)
Structural Power Law spine
Long-term structural moving average
Adaptive terrain bands
Market cycle positioning
Structural zone classification
Structural confidence scoring
Clean structural dashboard
Supported Markets

The Structural Terrain Engine is designed to analyze a wide range of markets, including:

Bitcoin
Cryptocurrencies
Stocks
ETFs
Market Indices
Commodities
Forex

Each asset class can use its own structural profile while the indicator automatically adapts its higher-timeframe context for continuous (crypto) and session-based (traditional) markets.

Terrain Zones...The terrain is divided into six structural regions.

Generational Opportunity...Historically represents periods of extreme structural undervaluation.

Deep Opportunity...Price remains significantly below structural value while long-term risk has historically been reduced.

Accumulation...Price begins transitioning back toward structural equilibrium.

Fair Value...Price is trading near its expected long-term structural path.

Extended...Price is becoming increasingly stretched above structural value.

Campaign Exhaustion...Historically associated with elevated structural risk and mature market cycles.

Dashboard Metrics

Market State...Summarizes the current structural zone together with the model's confidence.

Example: Deep Opportunity - Moderate Confidence

Price vs Spine: Shows where price is relative to the selected structural spine.

1.00× = Price is exactly on the structural model.
Above 1.00× = Price is trading above structure.
Below 1.00× = Price is trading below structure.

Distance to Spine:  Displays the absolute price difference between the current market price and the structural spine.

Cycle Position:  Normalizes price into a 0–100 structural cycle score.
Lower values generally represent deeper structural opportunity.
Higher values indicate progressively later-cycle conditions.

Current Zone: Displays the terrain region price currently occupies.

Model Alignment:  Measures how closely the structural models agree with one another.
Higher values indicate stronger agreement between the independent structural models.

Signal Confidence: Represents the overall confidence of the structural assessment.
Higher confidence suggests stronger structural evidence supporting the current terrain classification.

Structural Growth: Shows how quickly the structural spine is advancing over time.
Positive values indicate structural expansion.

Timeframe Routing:  The indicator automatically selects a higher-timeframe context based on the current chart.

Chart	Context
15m	1H
30m	2H
1H	4H
3H	6H
6H	1D (TradFi) / 12H (Crypto)
12H	2D
1D	3D
3D	1W
1W	2W
2W	1M

Manual timeframe selection is also available.

Inputs
Structural Model
Asset Profile

Select the structural profile best suited for the instrument.

Examples include:

Bitcoin
Crypto
Equities
Commodities
Custom
Structural Spine

Choose which structural model is used as the primary reference.

Available options include:

Structural
Power Law
Context
Timeframe Routing

Choose how the higher-timeframe context is selected.

Options: Profile Default,  Auto TradFi,  Auto Crypto,  Manual,  Manual Higher Timeframe...Overrides automatic timeframe routing.

Terrain: Show Terrain Bands...Displays the structural valuation bands.

Show Structural Moving Average:  Displays the higher-timeframe structural moving average.

Show Power Law:  Displays the structural Power Law spine.

Show Zone Labels:  Displays terrain zone labels beside the chart.

Zone Label Offset:  Moves zone labels closer to or farther from price.

Zone Label Size:  Adjusts the size of terrain labels.

Blending:  Adjust how different structural models contribute to the final structural spine.
A reserved external-model weighting is included for future integration of additional verified structural models.

Who Is This For?

The Structural Terrain Engine is intended for investors and traders who want to understand where price sits within a larger structural cycle, rather than relying solely on short-term indicators.  It can be used as a standalone market framework or alongside existing technical analysis for timing, confirmation, and risk management.

How to Use:  The indicator is designed for structural analysis—not short-term trading signals.

Many traders use it to:
Identify long-term accumulation areas.
Gauge whether price is historically extended.
Monitor structural trend health.
Add higher-timeframe context to lower-timeframe decisions.
Evaluate market cycle progression.
Compare multiple asset classes using a consistent structural framework.

The terrain should be interpreted as a probabilistic framework rather than a prediction engine.

Notes
Confirmed higher-timeframe calculations do not repaint.
Structural models are intended for long-term market analysis.
Automatic timeframe routing adapts differently for traditional markets and 24/7 crypto markets.
The indicator is designed to provide structural context and should be used alongside sound risk management and additional market analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © renderingnature1

//@version=6
indicator("MFx Structural Terrain Engine V2", shorttitle="MFx Terrain V2", overlay=true, max_bars_back=5000)

//=============================================================================
// MFx STRUCTURAL TERRAIN ENGINE V2
// Structural research framework. No forecasts. No buy/sell instructions.
//=============================================================================
//=============================================================================
// CONSTANTS
//=============================================================================
const string GROUP_GENERAL     = "01 — General"
const string GROUP_TIMEFRAME   = "02 — Timeframe Architecture"
const string GROUP_POWERLAW    = "03 — Power Law Model"
const string GROUP_MA          = "04 — Long-Term Moving Average"
const string GROUP_BLEND       = "05 — Structural Spine"
const string GROUP_ZONES       = "06 — Terrain Zones"
const string GROUP_CONFIDENCE  = "07 — Terrain Analytics"
const string GROUP_VISUAL      = "08 — Visual Design"
const string GROUP_DASHBOARD   = "09 — Dashboard"
// January 3, 2009 00:00:00 UTC.
const int BITCOIN_GENESIS = timestamp("03 Jan 2009 00:00 +0000")

//=============================================================================
// TYPES
//=============================================================================

type ModelResult
    string name
    float value
    float weight
    bool available
    string status

type TimeframeRoute
    string timeframe
    bool supported
    string status

//=============================================================================
// INPUTS
//=============================================================================

// General
string assetProfile = input.string("Bitcoin", "Asset profile", options = ["Bitcoin", "Crypto", "Equity", "Commodity", "Custom Research"], group = GROUP_GENERAL)
string spineMode = input.string("Blended Model", "Structural spine mode", options = ["Power Law", "200 Week MA", "Blended Model"], tooltip = "Selects the model used as the central structural reference. The blended model combines available models in log-price space.", group = GROUP_GENERAL)
bool restrictPowerLaw = input.bool(true, "Restrict Power Law to Bitcoin profile", tooltip = "Prevents the Bitcoin genesis model from being applied silently to unrelated assets.", group = GROUP_GENERAL)

// Timeframe architecture
string timeframeMode = input.string("Profile Default", "Context timeframe mode", options = ["Profile Default", "Auto TradFi", "Auto Crypto", "Manual"], group = GROUP_TIMEFRAME)
string manualHTF = input.timeframe("1W", "Manual context timeframe", group = GROUP_TIMEFRAME)

// Power Law
float powerA = input.float(1.0e-17, "Coefficient A", minval = 1.0e-30, step = 1.0e-18, tooltip = "Research hypothesis: Price = A × Days^B.", group = GROUP_POWERLAW)
float powerB = input.float(5.80, "Exponent B", minval = 0.01, step = 0.01, group = GROUP_POWERLAW)
int customAnchorDate = input.time(timestamp("01 Jan 2000 00:00 +0000"), "Custom Power Law anchor date", tooltip = "Bitcoin automatically uses January 3, 2009. Other asset profiles use this experimental research anchor.", group = GROUP_POWERLAW)

// Weekly model
int structuralWeeks = input.int(200, "Structural MA length in weeks", minval = 20, maxval = 500, group = GROUP_MA)

// Blend
float powerWeight = input.float(50.0, "Power Law weight", minval = 0.0, maxval = 100.0, step = 1.0, group = GROUP_BLEND)
float maWeight = input.float(30.0, "Weekly MA weight", minval = 0.0, maxval = 100.0, step = 1.0, group = GROUP_BLEND)
float reservedExternalWeight = input.float(20.0, "Future model weight", minval = 0.0, maxval = 100.0, step = 1.0, tooltip = "Reserved for future structural models. Currently inactive.", group = GROUP_BLEND)

// Zone thresholds
float threshold1 = input.float(0.55, "Zone 1 / Zone 2", minval = 0.01, step = 0.01, group = GROUP_ZONES)
float threshold2 = input.float(0.75, "Zone 2 / Zone 3", minval = 0.01, step = 0.01, group = GROUP_ZONES)
float threshold3 = input.float(0.95, "Zone 3 / Zone 4", minval = 0.01, step = 0.01, group = GROUP_ZONES)
float threshold4 = input.float(1.25, "Zone 4 / Zone 5", minval = 0.01, step = 0.01, group = GROUP_ZONES)
float threshold5 = input.float(1.65, "Zone 5 / Zone 6", minval = 0.01, step = 0.01, group = GROUP_ZONES)
float threshold6 = input.float(2.20, "Zone 6 / Zone 7", minval = 0.01, step = 0.01, group = GROUP_ZONES)

float visualFloorRatio = input.float(0.30, "Visual lower boundary", minval = 0.01, maxval = 0.54, step = 0.01, group = GROUP_ZONES)
float visualCeilingRatio = input.float(3.00, "Visual upper boundary", minval = 2.21, step = 0.10, group = GROUP_ZONES)

// Agreement and confidence
float agreementSensitivity = input.float(4.0, "Agreement sensitivity", minval = 0.10, maxval = 20.0, step = 0.10, group = GROUP_CONFIDENCE)
float confidenceAgreementWeight = input.float(70.0, "Confidence: agreement weight", minval = 0.0, maxval = 100.0, group = GROUP_CONFIDENCE)
float confidenceDataWeight = input.float(30.0, "Confidence: data-quality weight", minval = 0.0, maxval = 100.0, group = GROUP_CONFIDENCE)

// Visuals
bool showPowerLaw = input.bool(true, "Show Power Law", group = GROUP_VISUAL)
bool showStructuralMA = input.bool(true, "Show structural MA", group = GROUP_VISUAL)
bool showTerrainBands = input.bool(true, "Show terrain bands", group = GROUP_VISUAL)
bool showDashboard = input.bool(true, "Show dashboard", group = GROUP_DASHBOARD)

string dashboardHorizontal = input.string("Right", "Dashboard horizontal position", options = ["Left", "Center", "Right"], group = GROUP_DASHBOARD)
string dashboardVertical = input.string("Top", "Dashboard vertical position", options = ["Top", "Middle", "Bottom"], group = GROUP_DASHBOARD)
bool showZoneLabels = input.bool(true, "Show zone labels", group = GROUP_VISUAL)
int zoneLabelOffset = input.int(2, "Zone label offset bars", minval = 1, maxval = 500, group = GROUP_VISUAL)
string zoneLabelSizeInput = input.string("Normal", "Zone label text size", options = ["Tiny", "Small", "Normal"], group = GROUP_VISUAL)

//=============================================================================
// GENERAL UTILITIES
//=============================================================================

f_isPositive(float _value) => not na(_value) and _value > 0.0

f_clamp(float _value, float _minimum, float _maximum) => math.max(_minimum, math.min(_maximum, _value))

f_createModel(string _name, float _value, float _weight, string _missingReason) =>
    bool available = f_isPositive(_value) and _weight > 0.0
    ModelResult.new(_name, _value, _weight, available, available ? "Available" : _missingReason)

f_isHigherTimeframe(string _requestedTF) =>
    int chartSeconds = timeframe.in_seconds()
    int requestedSeconds = timeframe.in_seconds(_requestedTF)
    not na(chartSeconds) and not na(requestedSeconds) and requestedSeconds > chartSeconds

//=============================================================================
// TIMEFRAME ROUTER
//=============================================================================

f_autoHTF(string _mode, string _manualHTF) =>
    string tf = timeframe.period

    string tradfiHTF = switch tf
        "1"   => "5"
        "3"   => "15"
        "5"   => "30"
        "15"  => "60"
        "30"  => "120"
        "60"  => "240"
        "120" => "240"
        "180" => "360"
        "240" => "1D"
        "360" => "2D"
        "720" => "2D"
        "1D"  => "3D"
        "2D"  => "4D"
        "3D"  => "1W"
        "1W"  => "2W"
        "2W"  => "1M"
        "1M"  => "3M"
        => ""

    string cryptoHTF = switch tf
        "1"   => "5"
        "3"   => "15"
        "5"   => "30"
        "15"  => "60"
        "30"  => "120"
        "60"  => "240"
        "120" => "480"
        "180" => "720"
        "240" => "1D"
        "360" => "1D"
        "480" => "2D"
        "720" => "2D"
        "1D"  => "3D"
        "2D"  => "4D"
        "3D"  => "1W"
        "1W"  => "2W"
        "2W"  => "1M"
        "1M"  => "3M"
        => ""

    string effectiveMode = _mode == "Profile Default" ? (assetProfile == "Bitcoin" or assetProfile == "Crypto" ? "Auto Crypto" : "Auto TradFi") : _mode

    string selectedTF = effectiveMode == "Auto TradFi" ? tradfiHTF : effectiveMode == "Auto Crypto" ? cryptoHTF : effectiveMode == "Manual" ? _manualHTF : ""

    bool mapped = str.length(selectedTF) > 0
    bool valid = mapped and f_isHigherTimeframe(selectedTF)

    string status = not mapped ? "Unsupported chart timeframe - use Manual" : not valid ? "Selected timeframe is not above chart timeframe" : "Valid"

    TimeframeRoute.new(selectedTF, mapped and valid, status)

//=============================================================================
// STRUCTURAL MODELS
//=============================================================================
f_powerLawAnchor() => assetProfile == "Bitcoin" ? BITCOIN_GENESIS : customAnchorDate

f_powerLaw(float _coefficientA, float _exponentB) =>
    int anchorDate = f_powerLawAnchor()
    float elapsedDays = (time - anchorDate) / 86400000.0
    bool profileAllowed = assetProfile == "Bitcoin" or not restrictPowerLaw
    profileAllowed and elapsedDays >= 1.0 ? _coefficientA * math.pow(elapsedDays, _exponentB) : na

f_confirmedWeeklyMA(int _lengthWeeks) => request.security(syminfo.tickerid, "1W", ta.sma(close, _lengthWeeks)[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

//=============================================================================
// SPINE ENGINE
//=============================================================================

f_logBlend2(ModelResult _model1, ModelResult _model2) =>
    float weightedLogSum = 0.0
    float validWeightSum = 0.0

    if _model1.available
        weightedLogSum += _model1.weight * math.log(_model1.value)
        validWeightSum += _model1.weight

    if _model2.available
        weightedLogSum += _model2.weight * math.log(_model2.value)
        validWeightSum += _model2.weight

    validWeightSum > 0.0 ? math.exp(weightedLogSum / validWeightSum) : na

f_twoModelDispersion(ModelResult _model1, ModelResult _model2) =>
    if not _model1.available or not _model2.available
        na
    else
        float totalWeight = _model1.weight + _model2.weight
        float log1 = math.log(_model1.value)
        float log2 = math.log(_model2.value)
        float weightedMean = (_model1.weight * log1 + _model2.weight * log2) / totalWeight
        float weightedVariance = (_model1.weight * math.pow(log1 - weightedMean, 2.0) + _model2.weight * math.pow(log2 - weightedMean, 2.0)) / totalWeight
        math.sqrt(weightedVariance)

//=============================================================================
// ZONE ENGINE
//=============================================================================

f_thresholdsValid() => visualFloorRatio < threshold1 and threshold1 < threshold2 and threshold2 < threshold3 and threshold3 < threshold4 and threshold4 < threshold5 and threshold5 < threshold6 and threshold6 < visualCeilingRatio

f_zoneNumber(float _ratio) => na(_ratio) ? 0 : _ratio < threshold1 ? 1 : _ratio < threshold2 ? 2 : _ratio < threshold3 ? 3 : _ratio < threshold4 ? 4 : _ratio < threshold5 ? 5 : _ratio < threshold6 ? 6 : 7

f_zoneLabel(int _zone) =>
    switch _zone
        1 => "Generational Opportunity"
        2 => "Deep Opportunity"
        3 => "Accumulation"
        4 => "Fair Value"
        5 => "Extended"
        6 => "Harvest"
        7 => "Campaign Exhaustion"
        => "Unavailable"

f_confidenceLabel(float _confidence) => na(_confidence) ? "Unavailable" : _confidence >= 75.0 ? "High Confidence" : _confidence >= 50.0 ? "Moderate Confidence" : "Low Confidence"

f_marketState(int _zone, float _confidence) => _zone > 0 ? f_zoneLabel(_zone) + " - " + f_confidenceLabel(_confidence) : "Unavailable"

f_zoneColor(int _zone) =>
    switch _zone
        1 => color.rgb(142, 68, 173)
        2 => color.rgb(22, 160, 133)
        3 => color.rgb(88, 166, 74)
        4 => color.rgb(224, 170, 45)
        5 => color.rgb(230, 111, 42)
        6 => color.rgb(205, 61, 55)
        7 => color.rgb(148, 35, 49)
        => color.gray

f_dashboardPosition(string _horizontal, string _vertical) =>
    _vertical == "Top" and _horizontal == "Left" ? position.top_left :
     _vertical == "Top" and _horizontal == "Center" ? position.top_center :
     _vertical == "Top" and _horizontal == "Right" ? position.top_right :
     _vertical == "Middle" and _horizontal == "Left" ? position.middle_left :
     _vertical == "Middle" and _horizontal == "Center" ? position.middle_center :
     _vertical == "Middle" and _horizontal == "Right" ? position.middle_right :
     _vertical == "Bottom" and _horizontal == "Left" ? position.bottom_left :
     _vertical == "Bottom" and _horizontal == "Center" ? position.bottom_center :
     position.bottom_right

f_zoneLabelSize(string _size) => _size == "Tiny" ? size.tiny : _size == "Normal" ? size.normal : size.small

f_priceLabel(float _value) =>
    float absValue = math.abs(_value)
    absValue >= 1000000.0 ? "$" + str.tostring(_value / 1000000.0, "#.##") + "M" : absValue >= 1000.0 ? "$" + str.tostring(_value / 1000.0, "#.#") + "k" : "$" + str.tostring(_value, format.mintick)

f_signedNumber(float _value, string _format) => na(_value) ? "Unavailable" : _value > 0.0 ? "+" + str.tostring(_value, _format) : str.tostring(_value, _format)

f_signedPercent(float _value) => na(_value) ? "Unavailable" : _value > 0.0 ? "+" + str.tostring(_value, "#.##") + "%" : str.tostring(_value, "#.##") + "%"

f_signedCurrency(float _value) =>
    if na(_value)
        "Unavailable"
    else
        string sign = _value > 0.0 ? "+" : _value < 0.0 ? "-" : ""
        float absoluteValue = math.abs(_value)
        string formattedValue = absoluteValue >= 1000000.0 ? "$" + str.tostring(absoluteValue / 1000000.0, "#.##") + "M" : absoluteValue >= 1000.0 ? "$" + str.tostring(absoluteValue / 1000.0, "#.##") + "k" : "$" + str.tostring(absoluteValue, format.mintick)
        sign + formattedValue

f_zoneRangeText(int _zone, float _lower, float _upper) => _zone == 1 ? "<" + f_priceLabel(_upper) : _zone == 7 ? ">" + f_priceLabel(_lower) : f_priceLabel(_lower) + "-" + f_priceLabel(_upper)

f_zoneDisplayText(int _zone, float _lower, float _upper) => f_zoneRangeText(_zone, _lower, _upper) + "\n" + f_zoneLabel(_zone)

f_geometricMidpoint(float _lower, float _upper) => _lower > 0.0 and _upper > 0.0 ? math.sqrt(_lower * _upper) : na

f_segmentProgress(float _value, float _lower, float _upper) => _upper > _lower ? f_clamp((_value - _lower) / (_upper - _lower), 0.0, 1.0) : 0.0

f_terrainAltitude(float _ratio) =>
    float segment = 100.0 / 7.0
    na(_ratio) ? na :
     _ratio < threshold1 ? segment * f_segmentProgress(_ratio, visualFloorRatio, threshold1) :
     _ratio < threshold2 ? segment * (1.0 + f_segmentProgress(_ratio, threshold1, threshold2)) :
     _ratio < threshold3 ? segment * (2.0 + f_segmentProgress(_ratio, threshold2, threshold3)) :
     _ratio < threshold4 ? segment * (3.0 + f_segmentProgress(_ratio, threshold3, threshold4)) :
     _ratio < threshold5 ? segment * (4.0 + f_segmentProgress(_ratio, threshold4, threshold5)) :
     _ratio < threshold6 ? segment * (5.0 + f_segmentProgress(_ratio, threshold5, threshold6)) :
     segment * (6.0 + f_segmentProgress(_ratio, threshold6, visualCeilingRatio))

//=============================================================================
// MODEL CALCULATIONS
//=============================================================================

float powerLawValue = f_powerLaw(powerA, powerB)
float weeklyMAValue = f_confirmedWeeklyMA(structuralWeeks)
string powerLawMissingReason = assetProfile != "Bitcoin" and restrictPowerLaw ? "Disabled outside Bitcoin profile" : "Insufficient or invalid data"

ModelResult powerModel = f_createModel("Power Law", powerLawValue, powerWeight, powerLawMissingReason)
ModelResult maModel = f_createModel(str.tostring(structuralWeeks) + " Week MA", weeklyMAValue, maWeight, "Insufficient confirmed weekly history")

float blendedSpine = f_logBlend2(powerModel, maModel)
float structuralSpine = spineMode == "Power Law" ? powerModel.value : spineMode == "200 Week MA" ? maModel.value : blendedSpine
bool selectedSpineAvailable = spineMode == "Power Law" ? powerModel.available : spineMode == "200 Week MA" ? maModel.available : f_isPositive(blendedSpine)

//=============================================================================
// AGREEMENT AND CONFIDENCE
//=============================================================================

float modelDispersion = f_twoModelDispersion(powerModel, maModel)
float agreementScore = na(modelDispersion) ? na : 100.0 * math.exp(-agreementSensitivity * modelDispersion)
int availableModelCount = (powerModel.available ? 1 : 0) + (maModel.available ? 1 : 0)
float dataQualityScore = availableModelCount / 2.0 * 100.0
float confidenceWeightTotal = confidenceAgreementWeight + confidenceDataWeight

float rawTerrainConfidence = not selectedSpineAvailable or confidenceWeightTotal <= 0.0 ? na : (confidenceAgreementWeight * nz(agreementScore, 0.0) + confidenceDataWeight * dataQualityScore) / confidenceWeightTotal
float terrainConfidence = na(rawTerrainConfidence) ? na : f_clamp(rawTerrainConfidence, 0.0, 100.0)

//=============================================================================
// TERRAIN STATE
//=============================================================================

bool thresholdsValid = f_thresholdsValid()
float priceSpineRatio = selectedSpineAvailable and thresholdsValid ? close / structuralSpine : na
float distanceFromSpine = selectedSpineAvailable ? close - structuralSpine : na
float valuationPercent = f_isPositive(priceSpineRatio) ? 100.0 * (priceSpineRatio - 1.0) : na
float logDistance = f_isPositive(priceSpineRatio) ? math.log(priceSpineRatio) : na
float terrainAltitude = thresholdsValid ? f_terrainAltitude(priceSpineRatio) : na

int currentZone = f_zoneNumber(priceSpineRatio)
string currentZoneLabel = f_zoneLabel(currentZone)
color currentZoneColor = f_zoneColor(currentZone)

bool enteredNewZone = currentZone > 0 and currentZone[1] > 0 and currentZone != currentZone[1]
bool rawSpineCross = ta.cross(close, structuralSpine)
bool crossedSpine = selectedSpineAvailable and rawSpineCross

// Capture the completed prior-week spine whenever a new week begins.
// This does not use the still-developing current weekly observation.
bool newWeek = timeframe.change("1W")
float confirmedWeeklySpine = ta.valuewhen(newWeek, structuralSpine[1], 0)
float previousWeeklySpine = ta.valuewhen(newWeek, structuralSpine[1], 1)
float weeklySpineDrift = f_isPositive(confirmedWeeklySpine) and f_isPositive(previousWeeklySpine) ? 100.0 * (confirmedWeeklySpine / previousWeeklySpine - 1.0) : na

TimeframeRoute contextRoute = f_autoHTF(timeframeMode, manualHTF)

//=============================================================================
// TERRAIN BOUNDARIES
//=============================================================================

float band0 = structuralSpine * visualFloorRatio
float band1 = structuralSpine * threshold1
float band2 = structuralSpine * threshold2
float band3 = structuralSpine * threshold3
float band4 = structuralSpine * threshold4
float band5 = structuralSpine * threshold5
float band6 = structuralSpine * threshold6
float band7 = structuralSpine * visualCeilingRatio

bool bandsEnabled = showTerrainBands and selectedSpineAvailable and thresholdsValid

//=============================================================================
// PLOTS
//=============================================================================

plot(showPowerLaw ? powerLawValue : na, "Power Law Hypothesis", color = color.new(color.aqua, 15), linewidth = 2)
plot(showStructuralMA ? weeklyMAValue : na, "Confirmed Weekly Structural MA", color = color.new(color.orange, 10), linewidth = 2)
plot(structuralSpine, "Selected Structural Spine", color = color.blue, linewidth = 3)

p0 = plot(bandsEnabled ? band0 : na, "Terrain Visual Floor", color = color.new(color.green, 100))
p1 = plot(bandsEnabled ? band1 : na, "Zone Boundary 1", color = color.new(color.green, 92))
p2 = plot(bandsEnabled ? band2 : na, "Zone Boundary 2", color = color.new(color.green, 92))
p3 = plot(bandsEnabled ? band3 : na, "Zone Boundary 3", color = color.new(color.teal, 92))
p4 = plot(bandsEnabled ? band4 : na, "Zone Boundary 4", color = color.new(color.gray, 92))
p5 = plot(bandsEnabled ? band5 : na, "Zone Boundary 5", color = color.new(color.orange, 92))
p6 = plot(bandsEnabled ? band6 : na, "Zone Boundary 6", color = color.new(color.red, 92))
p7 = plot(bandsEnabled ? band7 : na, "Terrain Visual Ceiling", color = color.new(color.red, 100))

fill(p0, p1, color = color.new(f_zoneColor(1), 55), title = "Zone 1")
fill(p1, p2, color = color.new(f_zoneColor(2), 55), title = "Zone 2")
fill(p2, p3, color = color.new(f_zoneColor(3), 55), title = "Zone 3")
fill(p3, p4, color = color.new(f_zoneColor(4), 55), title = "Zone 4")
fill(p4, p5, color = color.new(f_zoneColor(5), 55), title = "Zone 5")
fill(p5, p6, color = color.new(f_zoneColor(6), 55), title = "Zone 6")
fill(p6, p7, color = color.new(f_zoneColor(7), 55), title = "Zone 7")

//=============================================================================
// DASHBOARD
//=============================================================================

var label zoneLabel1 = label.new(na, na, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100))
var label zoneLabel2 = label.new(na, na, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100))
var label zoneLabel3 = label.new(na, na, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100))
var label zoneLabel4 = label.new(na, na, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100))
var label zoneLabel5 = label.new(na, na, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100))
var label zoneLabel6 = label.new(na, na, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100))
var label zoneLabel7 = label.new(na, na, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100))

// Expanded table size to 17 rows.
var table dashboard = table.new(f_dashboardPosition(dashboardHorizontal, dashboardVertical), 2, 17, border_width = 1, frame_color = color.new(color.white, 75), border_color = color.new(color.white, 85))

f_dashboardRow(table _table, int _row, string _label, string _value, color _valueColor) =>
    table.cell(_table, 0, _row, _label, text_color = color.silver, bgcolor = color.new(color.black, 15))
    table.cell(_table, 1, _row, _value, text_color = _valueColor, bgcolor = color.new(color.black, 15))

f_updateZoneLabel(label _label, int _zone, float _lower, float _upper) =>
    float midpoint = f_geometricMidpoint(_lower, _upper)
    bool visible = showZoneLabels and bandsEnabled and not na(midpoint)
    string labelText = visible ? f_zoneDisplayText(_zone, _lower, _upper) : ""

    label.set_xy(_label, bar_index + zoneLabelOffset, visible ? midpoint : na)
    label.set_text(_label, labelText)
    label.set_color(_label, color.new(color.black, 100))
    label.set_textcolor(_label, color.white)
    label.set_size(_label, f_zoneLabelSize(zoneLabelSizeInput))
    label.set_textalign(_label, text.align_left)

if barstate.islast
    f_updateZoneLabel(zoneLabel1, 1, band0, band1)
    f_updateZoneLabel(zoneLabel2, 2, band1, band2)
    f_updateZoneLabel(zoneLabel3, 3, band2, band3)
    f_updateZoneLabel(zoneLabel4, 4, band3, band4)
    f_updateZoneLabel(zoneLabel5, 5, band4, band5)
    f_updateZoneLabel(zoneLabel6, 6, band5, band6)
    f_updateZoneLabel(zoneLabel7, 7, band6, band7)
    table.clear(dashboard, 0, 0, 1, 16)

if showDashboard
    string selectedSpineText = spineMode == "Blended Model" ? "Structural Spine" : spineMode

    color ratioColor = na(priceSpineRatio) ? color.red : priceSpineRatio >= 1.0 ? color.orange : color.aqua
    color distanceColor = na(distanceFromSpine) ? color.red : distanceFromSpine > 0.0 ? color.orange : distanceFromSpine < 0.0 ? color.aqua : color.white
    color agreementColor = na(agreementScore) ? color.orange : agreementScore >= 75.0 ? color.lime : agreementScore >= 50.0 ? color.yellow : color.orange
    color confidenceColor = na(terrainConfidence) ? color.red : terrainConfidence >= 75.0 ? color.lime : terrainConfidence >= 50.0 ? color.yellow : color.orange
    color marketStateColor = currentZone <= 0 ? color.red : terrainConfidence >= 75.0 ? color.lime : terrainConfidence >= 50.0 ? color.yellow : color.orange
    color driftColor = na(weeklySpineDrift) ? color.orange : weeklySpineDrift > 0.0 ? color.aqua : weeklySpineDrift < 0.0 ? color.orange : color.white

    // Regime description.
    string macroDescription = currentZone == 1 or currentZone == 2 ? "Macro Value Zone" : currentZone == 3 or currentZone == 4 ? "Fair Value / Neutral" : currentZone == 5 or currentZone == 6 ? "Macro Expansion" : currentZone == 7 ? "Cycle Overextended" : "Undefined"

    // Dynamic descriptive text for analytics metrics.
    string alignmentDesc = na(agreementScore) ? "Needs both valuation models" : "Power Law: " + f_priceLabel(powerModel.value) + "\n" + "200W MA: " + f_priceLabel(maModel.value)
    
    string agreementSummary = na(agreementScore) ? "Unavailable" : agreementScore >= 75.0 ? "Models agree on fair value." : agreementScore >= 50.0 ? "Models are reasonably close." : "Models estimate different fair values."
    
    string confidenceDesc = na(terrainConfidence) ? "Unavailable" :
     terrainConfidence >= 75.0 ? "High confidence in terrain." :
     terrainConfidence >= 50.0 ? "Terrain is generally reliable." :
     "Zone boundaries are approximate."

    string growthDesc = na(weeklySpineDrift) ? "Unavailable" :
     weeklySpineDrift > 0.0 ? "Fair value is rising." :
     weeklySpineDrift < 0.0 ? "Fair value is falling." :
     "Fair value is stable."

    // Dashboard rows
    f_dashboardRow(dashboard, 0, "MFx Terrain", "STRUCTURAL ENGINE", color.aqua)
    f_dashboardRow(dashboard, 1, "Market State", f_marketState(currentZone, terrainConfidence), marketStateColor)
    f_dashboardRow(dashboard, 2, "Regime Description", macroDescription, color.yellow)
    f_dashboardRow(dashboard, 3, "Current Zone", currentZone > 0 ? currentZoneLabel : "Unavailable", currentZone > 0 ? color.white : color.red)
    f_dashboardRow(dashboard, 4, "Asset", syminfo.ticker, color.white)
    f_dashboardRow(dashboard, 5, "Profile", assetProfile, color.white)
    f_dashboardRow(dashboard, 6, "Chart / Context", timeframe.period + " / " + (contextRoute.supported ? contextRoute.timeframe : "Invalid"), contextRoute.supported ? color.white : color.red)

    // Structural valuation models
    f_dashboardRow(dashboard, 7, "Power Law", powerModel.available ? f_priceLabel(powerModel.value) : powerModel.status, powerModel.available ? color.aqua : color.orange)
    f_dashboardRow(dashboard, 8, "200W MA", maModel.available ? f_priceLabel(maModel.value) : maModel.status, maModel.available ? color.orange : color.red)

    // Model interpretation
    f_dashboardRow(dashboard, 9, "Model Agreement", agreementSummary, agreementColor)
    f_dashboardRow(dashboard, 10, "Terrain Confidence", confidenceDesc, confidenceColor)
    f_dashboardRow(dashboard, 11, "Structural Growth", growthDesc, driftColor)

//=============================================================================
// ALERTS - DESCRIPTIVE EVENTS ONLY
//=============================================================================

alertcondition(enteredNewZone, "MFx Terrain: Entered New Zone", "MFx Structural Terrain Engine entered a different terrain zone.")
alertcondition(currentZone == 2 and currentZone[1] != 2, "MFx Terrain: Entered Deep Opportunity", "Price entered the Deep Opportunity terrain zone.")
alertcondition(currentZone == 6 and currentZone[1] != 6, "MFx Terrain: Entered Harvest", "Price entered the Harvest terrain zone.")
alertcondition(currentZone == 7 and currentZone[1] != 7, "MFx Terrain: Entered Campaign Exhaustion", "Price entered the Campaign Exhaustion terrain zone.")
alertcondition(crossedSpine, "MFx Terrain: Crossed Structural Spine", "Price crossed the selected structural spine.")
````
