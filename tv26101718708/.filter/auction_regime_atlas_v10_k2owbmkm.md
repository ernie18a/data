# Auction Regime Atlas v1.0 

- url: https://www.tradingview.com/script/k2OwBMKm/
- type: indicator
- pine_id: PUB;2db8c8edb56c4b0fa1fbccfc9270d545
- version: 1.0

## Description

# 🧭 Auction Regime Atlas v1.0

Auction Regime Atlas is a Pine Script v6 overlay indicator designed to visualize market acceptance, value migration, rejected auction areas, and contextual auction regimes directly on the chart.

❌ It is not a buy/sell signal tool.
❌ It is not a strategy.
❌ It is not an orderflow or liquidation-data replacement.

🎯 The goal is to help traders understand where price has been accepted, where value is forming, where price has moved away from value, and whether the current market context is balanced, transitional, displaced, or low quality.

---

## 💡 Core Idea

Markets often rotate around accepted value before moving into new auction areas.

Auction Regime Atlas maps that process by combining:

* price acceptance over a lookback window
* volume participation
* candle efficiency
* wick/rejection behavior
* higher-timeframe context
* regime classification
* distance from current value

📊 The result is a compact visual framework for understanding auction context without flooding the chart with signals.

---

## 🚀 Main Features

### 1. 🎯 Core Value Band

The Core Value Band highlights the price area where recent market activity shows the strongest acceptance.

It is calculated from a price-bin acceptance model using:

* time spent near price
* volume concentration
* close location
* wick/rejection behavior

⚠️ This band is meant as auction context, not as a mechanical support or resistance level.

---

### 2. 📏 Acceptance Edges

Upper and lower acceptance edges define the boundaries of the current accepted value area.

These edges help identify whether price is:

* inside accepted value
* above value
* below value
* far away from value

---

### 3. 🔄 Auction Regime

The dashboard shows a simplified auction regime state.

Current v1.0 regime states include:

* Neutral
* Balance
* Migration Up
* Migration Down
* Failed Auction

🛡️ The regime engine uses confirmed-bar logic and cooldown handling to avoid excessive state flipping.

---

### 4. 🌍 HTF Context

The indicator includes a higher-timeframe context layer based on confirmed higher-timeframe data.

ℹ️ This is used only as context and does not create entry or exit signals.

---

### 5. 📍 Location Awareness

The Location field shows where current price is relative to the accepted value area:

* Inside Value
* Above Value
* Below Value
* Away From Value
* No Value

When price is far away from the value zone, the visual relevance of the Core Band is reduced so the zone does not appear like an active trade signal.

---

### 6. 🎨 Visual Modes

Auction Regime Atlas includes three modes:

#### 🎯 Focus Mode

A clean minimal view for live chart reading.

Shows:

* Core Value Band
* Acceptance Edges
* compact dashboard
* no debug rows

#### ⚖️ Balanced Mode

Adds additional context zones while keeping the chart clean.

Shows:

* Core Value Band
* Acceptance Edges
* transitional/rejection context
* vacuum/context areas where applicable

#### 🔬 Research Mode

Adds validation and diagnostic rows for development, review, and deeper inspection.

Shows:

* object count
* validation status
* pending state information
* alert condition status

---

## 📋 Dashboard Fields

The compact dashboard includes:

* Mode
* Regime
* HTF Context
* Core Value Band
* Acceptance Score
* Location
* Activity
* Context Quality

🔬 Research Mode can additionally show:

* Validation Status
* Object Count
* State Debug
* Alert Debug

---

## 🔔 Alerts

The indicator includes four confirmed-bar alert conditions:

* New Auction Regime
* Value Migration Started
* Acceptance Edge Broken
* Failed Auction Detected

⚠️ Alerts are context alerts only.
They are not trade entry or exit instructions.

---

## 🛠️ Suggested Use

Auction Regime Atlas is best used as a context layer.

Useful questions:

* Is price currently inside accepted value?
* Is price moving away from value?
* Is the market balanced or transitioning?
* Did price leave value without building new acceptance?
* Is the current move happening near or far away from accepted value?
* Does higher-timeframe context support or contradict the current auction?

✅ Recommended starting use:

* Focus Mode for clean chart reading
* Balanced Mode for broader context
* Research Mode only for diagnostics and validation

---

## 📖 Practical Workflow

A simple way to interpret auction conditions is to combine Regime, Location Awareness, and HTF Context into a structured process.

### 1️⃣ Step 1: Start With HTF Context

First identify the higher-timeframe backdrop shown in the dashboard.

Ask:

* Is the higher timeframe supportive of directional movement?
* Is it balanced or already migrating?
* Does it align with the current chart or create conflict?

🌍 HTF Context provides the broader auction environment in which lower-timeframe activity is occurring.

### 2️⃣ Step 2: Check Current Location

Next evaluate where price is relative to accepted value.

* Inside Value suggests ongoing acceptance and rotational behavior.
* Above Value or Below Value suggests price is testing outside accepted value.
* Away From Value suggests displacement from the current auction area.
* No Value suggests acceptance has not yet formed clearly.

📍 Location helps determine whether price is interacting with value or operating away from it.

### 3️⃣ Step 3: Read the Active Regime

Then assess the current Auction Regime state.

* Balance implies acceptance and rotational trade around value.
* Migration Up or Migration Down implies value is attempting to relocate.
* Failed Auction suggests an attempted move has not established acceptance.
* Neutral indicates limited directional auction information.

🔄 The regime describes the current phase of the auction process rather than predicting the next move.

### 4️⃣ Step 4: Compare Regime and Location

The most useful information often comes from the relationship between regime and location.

Examples:

* Balance + Inside Value often reflects stable acceptance.
* Migration Up + Above Value may indicate value expansion higher.
* Migration Down + Below Value may indicate value expansion lower.
* Failed Auction + Away From Value may indicate rejection of a recent auction attempt.

📊 This comparison helps identify whether price behavior is consistent with the current auction state.

### 5️⃣ Step 5: Evaluate Market State Transitions

Watch for changes between regimes while monitoring location relative to value.

Common transitions include:

* Balance → Migration Up
* Balance → Migration Down
* Migration → Failed Auction
* Failed Auction → Balance

🔍 A transition becomes more meaningful when it is supported by location changes and aligned with HTF Context.

### 6️⃣ Step 6: Build a Contextual Narrative

Rather than treating any single field as a signal, combine all three layers:

1. Determine the higher-timeframe backdrop.
2. Identify where price is relative to value.
3. Assess the active auction regime.
4. Monitor whether the relationship between those factors is strengthening or weakening.

🧠 This workflow helps traders interpret whether the market is accepting value, rejecting value, migrating toward a new value area, or transitioning between auction states.

---

## 📈 Recommended Markets and Timeframes

The indicator is designed for liquid markets, especially:

* crypto perpetuals
* major crypto spot markets
* liquid index or futures markets
* high-volume intraday instruments

⏱️ Suggested timeframes:

* 5m
* 15m
* 1h for higher timeframe context

---

## ⚠️ Important Limitations

Auction Regime Atlas does not use true orderflow, footprint, delta, liquidation, or exchange-level positioning data.

All calculations are based on OHLCV data available in Pine Script.

❌ The indicator does not predict price direction.
❌ It does not guarantee reversals, continuations, or breakouts.
❌ It does not provide financial advice.

📌 The visual zones should be interpreted as auction context, not as automatic trade levels.

---

## 🛡️ Non-Repainting Design

The indicator is designed with confirmed-bar logic and non-repainting higher-timeframe requests.

Higher-timeframe context uses confirmed data and avoids lookahead behavior.

🔧 Visuals are updated with a stable object lifecycle to reduce flicker and avoid uncontrolled object creation.

---

## 📝 Release Notes — v1.0

🎉 Initial public release.

✅ Included:

* Acceptance Map Engine
* Core Value Band
* Acceptance Edges
* Minimal Auction Regime Engine
* HTF Context
* Location Awareness
* Focus / Balanced / Research modes
* Compact dashboard
* Confirmed-bar alerts
* Validation diagnostics in Research Mode
* Controlled object budget
* Non-repainting architecture

❌ Not included:

* strategy mode
* backtesting
* buy/sell signals
* automated entries or exits
* orderflow claims
* delta claims
* liquidation data
* machine learning
* multi-symbol logic

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Regime Atlas — v1.0 RC1.1 Context-Relevance Release Candidate
//@version=6
indicator(
     title="Auction Regime Atlas v1.0 — RC1.1",
     shorttitle="ARA v1.0 RC1.1",
     overlay=true,
     max_boxes_count=100,
     max_lines_count=60,
     max_labels_count=20,
     max_bars_back=500
)

//==================================================
// 2. IMPORTS
//==================================================
// No external imports in v1.0 RC1.1.

//==================================================
// 3. CONSTANTS / ENUMS / TYPES
//==================================================

enum VisualMode
    Focus
    Balanced
    Research

enum AuctionRegime
    Neutral
    Balance
    MigrationUp
    MigrationDown
    FailedAuction
    ExpansionDiscovery
    Compression
    VacuumRepricing
    ReAcceptance
    DistributionExhaustion

enum ZoneType
    Accepted
    Transitional
    Rejected
    Vacuum

enum ZoneStatus
    Active
    Weakening
    Historical
    Invalidated

enum ContextQuality
    Low
    Medium
    High

string MODE_FOCUS = "Focus"
string MODE_BALANCED = "Balanced"
string MODE_RESEARCH = "Research"

string DASH_POS_TOP_RIGHT = "Top Right"
string DASH_POS_TOP_LEFT = "Top Left"
string DASH_POS_MIDDLE_RIGHT = "Middle Right"
string DASH_POS_MIDDLE_LEFT = "Middle Left"
string DASH_POS_BOTTOM_RIGHT = "Bottom Right"
string DASH_POS_BOTTOM_LEFT = "Bottom Left"

string DASH_SIZE_TINY = "Tiny"
string DASH_SIZE_SMALL = "Small"
string DASH_SIZE_NORMAL = "Normal"

string DASH_FIELD_MODE = "Mode"
string DASH_FIELD_REGIME = "Regime"
string DASH_FIELD_HTF_CONTEXT = "HTF"
string DASH_FIELD_CORE_BAND = "Core"
string DASH_FIELD_ACCEPTANCE = "Accept"
string DASH_FIELD_ACTIVITY = "Activity"
string DASH_FIELD_LOCATION = "Location"
string DASH_FIELD_CONTEXT = "Context"
string DASH_FIELD_VALIDATION = "Valid"
string DASH_FIELD_OBJECTS = "Objects"
string DASH_FIELD_STATE = "State"
string DASH_FIELD_ALERTS = "Alerts"

string ALERT_REGIME_CHANGE_TEXT = "Auction Regime changed."
string ALERT_MIGRATION_TEXT = "Value Migration started."
string ALERT_EDGE_BREAK_TEXT = "Acceptance Edge broken."
string ALERT_REACCEPTANCE_TEXT = "Re-Acceptance confirmed."
string ALERT_FAILED_AUCTION_TEXT = "Failed Auction detected."
string ALERT_VACUUM_RISK_TEXT = "Vacuum Expansion Risk detected."
string ALERT_HTF_ALIGN_TEXT = "HTF and chart context aligned."

int OBJECT_BUDGET_BOXES = 100
int OBJECT_BUDGET_LINES = 60
int OBJECT_BUDGET_LABELS = 20
int PLOT_BUDGET_TARGET = 0

int CQ_LOW = 0
int CQ_MEDIUM = 1
int CQ_HIGH = 2

int REGIME_NEUTRAL = 0
int REGIME_BALANCE = 1
int REGIME_MIGRATION_UP = 2
int REGIME_MIGRATION_DOWN = 3
int REGIME_FAILED_AUCTION = 4
int REGIME_EXPANSION = 5
int REGIME_COMPRESSION = 6
int REGIME_VACUUM = 7
int REGIME_REACCEPTANCE = 8
int REGIME_DISTRIBUTION = 9

color ACCEPTED_COLOR = #008080
color TRANSITIONAL_COLOR = #D4AF37
color REJECTED_COLOR = #C62828
color VACUUM_COLOR = #7E57C2
color NEUTRAL_COLOR = #808080
color WARNING_COLOR = #F57C00
color DASH_BG_COLOR = #000000
color DASH_TEXT_COLOR = #FFFFFF
color DASH_MUTED_TEXT_COLOR = #BDBDBD

//==================================================
// 4. INPUTS
//==================================================

string modeInput = input.string(
     title="Mode",
     defval="Focus",
     options=["Focus", "Balanced", "Research"],
     group="Mode / Preset",
     tooltip="Select visual mode. RC1.1 release candidate with context-relevance hardening, Focus/Balanced/Research modes, minimal alerts, validation diagnostics and compact dashboard behavior."
)

int lookbackInput = input.int(
     title="Lookback Length",
     defval=80,
     minval=20,
     maxval=200,
     group="Auction Map",
     tooltip="Number of bars used by the minimal acceptance-map calculation."
)

int binCountInput = input.int(
     title="Bin Count",
     defval=36,
     minval=16,
     maxval=80,
     group="Auction Map",
     tooltip="Number of price bins used by the minimal acceptance-map calculation."
)

int decayLengthInput = input.int(
     title="Zone Decay Length",
     defval=80,
     minval=10,
     maxval=200,
     group="Auction Map",
     tooltip="Reserved for later zone lifecycle phases. Phase I uses one live core band, acceptance edges, limited Balanced Mode zones, optional confirmed HTF context band and minimal alert infrastructure."
)

float acceptedThresholdInput = input.float(
     title="Accepted Score Threshold",
     defval=0.55,
     minval=0.10,
     maxval=0.95,
     step=0.05,
     group="Auction Map",
     tooltip="Minimum normalized acceptance score required to display the minimal core value band."
)

float mergeFactorInput = input.float(
     title="Core Band Merge Factor",
     defval=0.75,
     minval=0.25,
     maxval=1.00,
     step=0.05,
     group="Auction Map",
     tooltip="Adjacent bins above accepted threshold times this factor are merged into the core band."
)

int stateConfirmationBarsInput = input.int(
     title="State Confirmation Bars",
     defval=3,
     minval=1,
     maxval=10,
     group="Regime Engine",
     tooltip="Number of confirmed bars required before a pending regime can become active."
)

int cooldownBarsInput = input.int(
     title="Regime Cooldown Bars",
     defval=5,
     minval=1,
     maxval=20,
     group="Regime Engine",
     tooltip="Minimum confirmed bars before another regime change is allowed."
)

float migrationAtrThresholdInput = input.float(
     title="Migration ATR Threshold",
     defval=0.15,
     minval=0.05,
     maxval=1.00,
     step=0.05,
     group="Regime Engine",
     tooltip="Minimum shift of the core band midpoint in ATR units required for migration states."
)

float failedAuctionWickThresholdInput = input.float(
     title="Failed Auction Wick Threshold",
     defval=0.45,
     minval=0.20,
     maxval=0.90,
     step=0.05,
     group="Regime Engine",
     tooltip="Minimum wick rejection ratio required for the minimal Failed Auction state."
)

float awayFromValueAtrInput = input.float(
     title="Away From Value ATR Threshold",
     defval=1.00,
     minval=0.25,
     maxval=3.00,
     step=0.25,
     group="Regime Engine",
     tooltip="Distance from the active Core Value Band, in ATR units, after which the band is treated as context-only and visually faded."
)

string htfTfInput = input.timeframe(
     title="HTF Timeframe",
     defval="60",
     group="HTF Context",
     tooltip="Higher timeframe used for non-repainting context."
)

bool showHtfBandInput = input.bool(
     title="Show Confirmed HTF Band",
     defval=false,
     group="HTF Context",
     tooltip="Shows a very subtle band from the last confirmed higher-timeframe candle. Default is off to keep Focus Mode clean."
)

bool showHtfBandInFocusInput = input.bool(
     title="Show HTF Band In Focus Mode",
     defval=false,
     group="HTF Context",
     tooltip="If disabled, the HTF band is shown only in Balanced or Research Mode when enabled."
)

int htfBandTransparencyInput = input.int(
     title="HTF Band Transparency",
     defval=95,
     minval=88,
     maxval=98,
     group="HTF Context",
     tooltip="Higher values make the confirmed HTF context band less intrusive."
)

int relVolLenInput = input.int(
     title="Relative Volume Length",
     defval=20,
     minval=5,
     maxval=100,
     group="Activity Layer",
     tooltip="Length used to calculate relative volume."
)

int atrLenInput = input.int(
     title="ATR Length",
     defval=14,
     minval=5,
     maxval=100,
     group="Activity Layer",
     tooltip="Length used to calculate ATR and base volatility metrics."
)

color acceptedColorInput = input.color(
     title="Accepted Zone Color",
     defval=#008080,
     group="Visuals",
     tooltip="Color used for the minimal core value band."
)

color transitionalColorInput = input.color(
     title="Transitional Zone Color",
     defval=#D4AF37,
     group="Visuals",
     tooltip="Reserved for later transitional-zone visuals."
)

color rejectedColorInput = input.color(
     title="Rejected Zone Color",
     defval=#C62828,
     group="Visuals",
     tooltip="Reserved for later rejected-zone visuals."
)

color vacuumColorInput = input.color(
     title="Vacuum Zone Color",
     defval=#7E57C2,
     group="Visuals",
     tooltip="Reserved for later vacuum-zone visuals."
)

color htfBandColorInput = input.color(
     title="HTF Band Color",
     defval=#607D8B,
     group="Visuals",
     tooltip="Color used for the optional confirmed HTF context band."
)

bool showCoreBandInput = input.bool(
     title="Show Core Band",
     defval=true,
     group="Visuals",
     tooltip="Shows the minimal accepted value band."
)

bool showAcceptanceEdgesInput = input.bool(
     title="Show Acceptance Edges",
     defval=true,
     group="Visuals",
     tooltip="Shows the upper and lower acceptance edges."
)

int coreBandTransparencyInput = input.int(
     title="Core Band Transparency",
     defval=88,
     minval=70,
     maxval=95,
     group="Visuals",
     tooltip="Higher values create a lighter and less intrusive core band."
)

bool showBalancedZonesInput = input.bool(
     title="Show Balanced Mode Zones",
     defval=true,
     group="Visuals",
     tooltip="Shows minimal transitional and vacuum diagnostic zones in Balanced and Research modes."
)

bool showFailedAuctionMarkerInput = input.bool(
     title="Show Failed Auction Marker",
     defval=true,
     group="Visuals",
     tooltip="Shows one minimal Failed Auction context marker in Balanced and Research modes."
)

int balancedZoneTransparencyInput = input.int(
     title="Balanced Zone Transparency",
     defval=91,
     minval=80,
     maxval=96,
     group="Visuals",
     tooltip="Transparency for Balanced Mode diagnostic zones."
)

float transitionalThresholdInput = input.float(
     title="Transitional Score Threshold",
     defval=0.35,
     minval=0.10,
     maxval=0.80,
     step=0.05,
     group="Auction Map",
     tooltip="Minimum acceptance score used to derive minimal transitional zones."
)

float vacuumThresholdInput = input.float(
     title="Vacuum Score Threshold",
     defval=0.12,
     minval=0.01,
     maxval=0.35,
     step=0.01,
     group="Auction Map",
     tooltip="Maximum acceptance score used to derive one minimal low-acceptance vacuum zone."
)

bool showDashboardInput = input.bool(
     title="Show Dashboard",
     defval=true,
     group="Dashboard",
     tooltip="Show or hide the compact dashboard."
)

string dashboardPositionInput = input.string(
     title="Dashboard Position",
     defval="Top Right",
     options=["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group="Dashboard",
     tooltip="Dashboard location on the chart."
)

string dashboardTextSizeInput = input.string(
     title="Dashboard Text Size",
     defval="Small",
     options=["Tiny", "Small", "Normal"],
     group="Dashboard",
     tooltip="Text size for the compact dashboard. Use Tiny on mobile charts."
)

bool showActivityInFocusInput = input.bool(
     title="Show Activity Row In Focus",
     defval=false,
     group="Dashboard",
     tooltip="Keeps Focus Mode cleaner when disabled. Balanced and Research always show Activity."
)

bool regimeAlertInput = input.bool(
     title="Alert on New Regime",
     defval=true,
     group="Alerts",
     tooltip="Enables the confirmed-bar alert condition for a new auction regime."
)

bool migrationAlertInput = input.bool(
     title="Alert on Value Migration",
     defval=true,
     group="Alerts",
     tooltip="Enables the confirmed-bar alert condition for value migration."
)

bool edgeBreakAlertInput = input.bool(
     title="Alert on Acceptance Edge Break",
     defval=false,
     group="Alerts",
     tooltip="Enables the confirmed-bar alert condition when price closes beyond an acceptance edge."
)

bool reAcceptanceAlertInput = input.bool(
     title="Alert on Re-Acceptance",
     defval=false,
     group="Alerts",
     tooltip="Reserved input. No alertcondition is created for this input in RC1."
)

bool failedAuctionAlertInput = input.bool(
     title="Alert on Failed Auction",
     defval=false,
     group="Alerts",
     tooltip="Enables the confirmed-bar alert condition for failed auction context."
)

bool vacuumRiskAlertInput = input.bool(
     title="Alert on Vacuum Risk",
     defval=false,
     group="Alerts",
     tooltip="Reserved input. No alertcondition is created for this input in RC1."
)

bool htfAlignAlertInput = input.bool(
     title="Alert on HTF + LTF Alignment",
     defval=false,
     group="Alerts",
     tooltip="Reserved input. No alertcondition is created for this input in RC1."
)

bool showDebugInput = input.bool(
     title="Show Debug Diagnostics",
     defval=false,
     group="Debug / Research",
     tooltip="Shows optional Research Mode validation diagnostics. Default off."
)

bool showValidationRowsInput = input.bool(
     title="Show Validation Rows",
     defval=false,
     group="Debug / Research",
     tooltip="Adds compact Research Mode validation rows to the dashboard. Default off to avoid chart clutter."
)

bool showBaseMetricsInput = input.bool(
     title="Show Numeric Activity In Dashboard",
     defval=false,
     group="Debug / Research",
     tooltip="Shows numeric activity proxy in the dashboard instead of Low/Medium/High."
)

//==================================================
// 5. BASE SERIES / MTF REQUESTS
//==================================================

float src = close
float openSeries = open
float highSeries = high
float lowSeries = low
float closeSeries = close
float volumeSeries = volume

float prevClose = nz(closeSeries[1], closeSeries)
float trueRange = math.max(highSeries - lowSeries, math.max(math.abs(highSeries - prevClose), math.abs(lowSeries - prevClose)))
float atrValue = ta.rma(trueRange, atrLenInput)
float atrAvg = ta.sma(atrValue, atrLenInput)

float candleRange = highSeries - lowSeries
float bodySize = math.abs(closeSeries - openSeries)
float upperWick = highSeries - math.max(openSeries, closeSeries)
float lowerWick = math.min(openSeries, closeSeries) - lowSeries
float totalWick = upperWick + lowerWick

float avgVolume = ta.sma(volumeSeries, relVolLenInput)

[htfHigh, htfLow, htfClose, htfAtr] = request.security(
     syminfo.tickerid,
     htfTfInput,
     [high[1], low[1], close[1], ta.atr(atrLenInput)[1]],
     lookahead=barmerge.lookahead_off
)

float htfRange = htfHigh - htfLow
float htfMid = (htfHigh + htfLow) * 0.5
bool htfContextReady = not na(htfHigh) and not na(htfLow) and not na(htfClose) and htfRange > 0.0

//==================================================
// 6. HELPER FUNCTIONS
//==================================================

safeDiv(float numerator, float denominator, float fallback) =>
    denominator != 0.0 ? numerator / denominator : fallback

clampFloat(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

normalize01(float value, float minValue, float maxValue) =>
    clampFloat(safeDiv(value - minValue, maxValue - minValue, 0.0), 0.0, 1.0)

getDashboardPosition(string positionText) =>
    string result = position.top_right
    if positionText == DASH_POS_TOP_LEFT
        result := position.top_left
    else if positionText == DASH_POS_MIDDLE_RIGHT
        result := position.middle_right
    else if positionText == DASH_POS_MIDDLE_LEFT
        result := position.middle_left
    else if positionText == DASH_POS_BOTTOM_RIGHT
        result := position.bottom_right
    else if positionText == DASH_POS_BOTTOM_LEFT
        result := position.bottom_left
    result

getTextSize(string textSizeInput) =>
    string result = size.small
    if textSizeInput == DASH_SIZE_TINY
        result := size.tiny
    else if textSizeInput == DASH_SIZE_NORMAL
        result := size.normal
    result

isFocusModeText(string modeText) =>
    modeText == MODE_FOCUS

isBalancedModeText(string modeText) =>
    modeText == MODE_BALANCED

isResearchModeText(string modeText) =>
    modeText == MODE_RESEARCH

formatPrice(float value) =>
    str.tostring(value, format.mintick)

formatNumber(float value) =>
    str.tostring(value, "#.##")

boolToText(bool condition) =>
    condition ? "Yes" : "No"

getActivityText(float activityValue) =>
    string result = "Medium"
    if activityValue > 0.65
        result := "High"
    else if activityValue < 0.35
        result := "Low"
    result

//==================================================
// 7. CORE FEATURE CALCULATIONS
//==================================================

float closePositionRaw = safeDiv(closeSeries - lowSeries, candleRange, 0.5)
float closePosition = clampFloat(closePositionRaw, 0.0, 1.0)
float relativeVolume = safeDiv(volumeSeries, avgVolume, 0.0)
float relativeVolumeNorm = clampFloat(relativeVolume / 2.0, 0.0, 1.0)
float rangeEfficiency = clampFloat(safeDiv(bodySize, candleRange, 0.0), 0.0, 1.0)
float bodyEfficiency = clampFloat(safeDiv(bodySize, atrValue, 0.0), 0.0, 2.0)
float bodyEfficiencyNorm = clampFloat(bodyEfficiency / 2.0, 0.0, 1.0)
float wickRejectionRatio = clampFloat(safeDiv(totalWick, candleRange, 0.0), 0.0, 1.0)

bool bullishBody = closeSeries > openSeries
bool bearishBody = closeSeries < openSeries

float directionalPressureProxy = safeDiv(closeSeries - openSeries, atrValue, 0.0)
float activityPressureProxy = clampFloat((relativeVolumeNorm + rangeEfficiency + bodyEfficiencyNorm + (1.0 - wickRejectionRatio)) / 4.0, 0.0, 1.0)

int htfBiasRaw = 0
if htfContextReady
    if htfClose > htfMid
        htfBiasRaw := 1
    else if htfClose < htfMid
        htfBiasRaw := -1

string htfBiasText = "Neutral"
if htfBiasRaw > 0
    htfBiasText := "Up"
else if htfBiasRaw < 0
    htfBiasText := "Down"

string htfContextText = "HTF " + htfBiasText

int preliminaryContextQuality = CQ_MEDIUM
bool highQualityContext = relativeVolume > 1.2 and atrValue > atrAvg * 1.1 and not na(htfClose)
bool lowQualityContext = relativeVolume < 0.8 and atrValue < atrAvg * 0.9
if highQualityContext
    preliminaryContextQuality := CQ_HIGH
else if lowQualityContext
    preliminaryContextQuality := CQ_LOW

bool isFocusMode = isFocusModeText(modeInput)
bool isBalancedMode = isBalancedModeText(modeInput)
bool isResearchMode = isResearchModeText(modeInput)

string contextQualityText = "Medium"
color contextQualityColor = color.new(WARNING_COLOR, 0)
if preliminaryContextQuality == CQ_HIGH
    contextQualityText := "High"
    contextQualityColor := color.new(color.lime, 0)
else if preliminaryContextQuality == CQ_LOW
    contextQualityText := "Low"
    contextQualityColor := color.new(color.red, 0)

// Phase C: minimal acceptance map.
// Phase D: minimal structure bands derived from the active core value band.
// Phase E: minimal confirmed-bar regime classification.
// Phase F: Focus Mode visual hardening and compact dashboard behavior.
// Phase G: Balanced Mode minimal transitional/vacuum zone diagnostics.
// Phase H: HTF context hardening using last confirmed HTF candle and optional HTF band.
// Phase I: minimal confirmed-bar alerts.
// Phase J: optional Research Mode validation diagnostics.
// RC1: release-candidate freeze; no new mechanics beyond J.3.
// RC1.1: context-relevance hardening; price location relative to value is explicit and stale value is faded.
float lowLookback = ta.lowest(lowSeries, lookbackInput)
float highLookback = ta.highest(highSeries, lookbackInput)
float lookbackRange = highLookback - lowLookback
float binSize = safeDiv(lookbackRange, binCountInput, 0.0)
bool barsReady = bar_index >= lookbackInput and binSize > 0.0

array<float> binTimeCounts = array.new_float(binCountInput, 0.0)
array<float> binVolumeSums = array.new_float(binCountInput, 0.0)
array<float> binCloseScores = array.new_float(binCountInput, 0.0)
array<float> binWickScores = array.new_float(binCountInput, 0.0)
array<float> binScores = array.new_float(binCountInput, 0.0)

if barsReady
    for offset = 0 to lookbackInput - 1
        float barClose = closeSeries[offset]
        float barHigh = highSeries[offset]
        float barLow = lowSeries[offset]
        float barOpen = openSeries[offset]
        float barVolume = volumeSeries[offset]
        float barRange = barHigh - barLow
        if not na(barClose) and barRange >= 0.0
            int rawIndex = int(math.floor(safeDiv(barClose - lowLookback, binSize, 0.0)))
            int binIndex = int(clampFloat(rawIndex, 0.0, binCountInput - 1.0))
            float closeScore = 1.0 - math.abs(safeDiv(barClose - barLow, barRange, 0.5) - 0.5) * 2.0
            float upperBarWick = barHigh - math.max(barOpen, barClose)
            float lowerBarWick = math.min(barOpen, barClose) - barLow
            float wickScore = 1.0 - clampFloat(safeDiv(upperBarWick + lowerBarWick, barRange, 0.0), 0.0, 1.0)
            array.set(binTimeCounts, binIndex, array.get(binTimeCounts, binIndex) + 1.0)
            array.set(binVolumeSums, binIndex, array.get(binVolumeSums, binIndex) + nz(barVolume, 0.0))
            array.set(binCloseScores, binIndex, array.get(binCloseScores, binIndex) + closeScore)
            array.set(binWickScores, binIndex, array.get(binWickScores, binIndex) + wickScore)

float maxTimeCount = array.max(binTimeCounts)
float maxVolumeSum = array.max(binVolumeSums)
float maxAcceptanceScore = 0.0
float minAcceptanceScore = 10.0
int maxScoreBin = 0
int minScoreBin = 0

if barsReady
    for bin = 0 to binCountInput - 1
        float timeNorm = safeDiv(array.get(binTimeCounts, bin), maxTimeCount, 0.0)
        float volNorm = safeDiv(array.get(binVolumeSums, bin), maxVolumeSum, 0.0)
        float countForAverages = array.get(binTimeCounts, bin)
        float closeNorm = safeDiv(array.get(binCloseScores, bin), countForAverages, 0.0)
        float wickNorm = safeDiv(array.get(binWickScores, bin), countForAverages, 0.0)
        float acceptanceScore = clampFloat((timeNorm * 0.45) + (volNorm * 0.25) + (closeNorm * 0.15) + (wickNorm * 0.15), 0.0, 1.0)
        array.set(binScores, bin, acceptanceScore)
        if acceptanceScore > maxAcceptanceScore
            maxAcceptanceScore := acceptanceScore
            maxScoreBin := bin
        if acceptanceScore < minAcceptanceScore
            minAcceptanceScore := acceptanceScore
            minScoreBin := bin

float coreMergeThreshold = acceptedThresholdInput * mergeFactorInput
int coreStartBin = maxScoreBin
int coreEndBin = maxScoreBin
bool acceptedFound = barsReady and maxAcceptanceScore >= acceptedThresholdInput

if acceptedFound
    int leftProbe = maxScoreBin
    while leftProbe > 0 and array.get(binScores, leftProbe - 1) >= coreMergeThreshold
        leftProbe := leftProbe - 1
    int rightProbe = maxScoreBin
    while rightProbe < binCountInput - 1 and array.get(binScores, rightProbe + 1) >= coreMergeThreshold
        rightProbe := rightProbe + 1
    coreStartBin := leftProbe
    coreEndBin := rightProbe

float coreValueLow = na
float coreValueHigh = na
float coreValueMid = na
if acceptedFound
    coreValueLow := lowLookback + coreStartBin * binSize
    coreValueHigh := lowLookback + (coreEndBin + 1) * binSize
    coreValueMid := (coreValueLow + coreValueHigh) * 0.5

string coreBandText = "n/a"
if acceptedFound
    coreBandText := formatPrice(coreValueLow) + " - " + formatPrice(coreValueHigh)

string acceptanceText = "n/a"
if acceptedFound
    acceptanceText := formatNumber(maxAcceptanceScore)

// RC1.1: context relevance and price location relative to the active value band.
float distanceFromCoreAtr = na
if acceptedFound
    if closeSeries > coreValueHigh
        distanceFromCoreAtr := safeDiv(closeSeries - coreValueHigh, atrValue, 0.0)
    else if closeSeries < coreValueLow
        distanceFromCoreAtr := safeDiv(coreValueLow - closeSeries, atrValue, 0.0)
    else
        distanceFromCoreAtr := 0.0

bool priceInsideValue = acceptedFound and closeSeries >= coreValueLow and closeSeries <= coreValueHigh
bool priceAboveValue = acceptedFound and closeSeries > coreValueHigh
bool priceBelowValue = acceptedFound and closeSeries < coreValueLow
bool priceAwayFromValue = acceptedFound and not priceInsideValue and distanceFromCoreAtr > awayFromValueAtrInput

string locationText = "No Value"
color locationColor = color.new(NEUTRAL_COLOR, 0)
if priceInsideValue
    locationText := "Inside Value"
    locationColor := color.new(acceptedColorInput, 0)
else if priceAwayFromValue
    locationText := "Away From Value"
    locationColor := color.new(WARNING_COLOR, 0)
else if priceAboveValue
    locationText := "Above Value"
    locationColor := color.new(color.lime, 0)
else if priceBelowValue
    locationText := "Below Value"
    locationColor := color.new(color.red, 0)

// Phase G: minimal Balanced Mode zone diagnostics.
bool balancedDiagnosticsEnabled = (isBalancedMode or isResearchMode) and showBalancedZonesInput and acceptedFound

int lowerTransStartBin = coreStartBin
int lowerTransEndBin = coreStartBin - 1
bool lowerTransitionFound = false
if acceptedFound and coreStartBin > 0
    int probeLower = coreStartBin - 1
    while probeLower >= 0 and array.get(binScores, probeLower) >= transitionalThresholdInput and array.get(binScores, probeLower) < acceptedThresholdInput
        lowerTransStartBin := probeLower
        lowerTransitionFound := true
        probeLower := probeLower - 1
    lowerTransEndBin := coreStartBin - 1

int upperTransStartBin = coreEndBin + 1
int upperTransEndBin = coreEndBin
bool upperTransitionFound = false
if acceptedFound and coreEndBin < binCountInput - 1
    int probeUpper = coreEndBin + 1
    while probeUpper <= binCountInput - 1 and array.get(binScores, probeUpper) >= transitionalThresholdInput and array.get(binScores, probeUpper) < acceptedThresholdInput
        upperTransEndBin := probeUpper
        upperTransitionFound := true
        probeUpper := probeUpper + 1
    upperTransStartBin := coreEndBin + 1

float lowerTransitionLow = na
float lowerTransitionHigh = na
if lowerTransitionFound
    lowerTransitionLow := lowLookback + lowerTransStartBin * binSize
    lowerTransitionHigh := lowLookback + (lowerTransEndBin + 1) * binSize

float upperTransitionLow = na
float upperTransitionHigh = na
if upperTransitionFound
    upperTransitionLow := lowLookback + upperTransStartBin * binSize
    upperTransitionHigh := lowLookback + (upperTransEndBin + 1) * binSize

bool vacuumBinOutsideCore = minScoreBin < coreStartBin or minScoreBin > coreEndBin
bool vacuumFound = acceptedFound and minAcceptanceScore <= vacuumThresholdInput and vacuumBinOutsideCore
int vacuumStartBin = minScoreBin
int vacuumEndBin = minScoreBin
if vacuumFound
    int probeVacLower = minScoreBin
    while probeVacLower > 0 and array.get(binScores, probeVacLower - 1) <= vacuumThresholdInput
        probeVacLower := probeVacLower - 1
    int probeVacUpper = minScoreBin
    while probeVacUpper < binCountInput - 1 and array.get(binScores, probeVacUpper + 1) <= vacuumThresholdInput
        probeVacUpper := probeVacUpper + 1
    vacuumStartBin := probeVacLower
    vacuumEndBin := probeVacUpper

float vacuumLow = na
float vacuumHigh = na
if vacuumFound
    vacuumLow := lowLookback + vacuumStartBin * binSize
    vacuumHigh := lowLookback + (vacuumEndBin + 1) * binSize

//==================================================
// 8. STATE / REGIME ENGINE
//==================================================
// Phase E/F/G/H: Minimal confirmed-bar auction regime engine.
// Implemented states: Neutral, Balance, MigrationUp, MigrationDown, FailedAuction.

var int currentRegime = REGIME_NEUTRAL
var int previousRegime = REGIME_NEUTRAL
var int pendingRegime = REGIME_NEUTRAL
var int pendingRegimeBars = 0
var int barsSinceRegimeChange = 100000
var float lastConfirmedCoreMid = na
var bool regimeChangedThisBar = false

regimeChangedThisBar := false

float coreMidShiftAtr = 0.0
if acceptedFound and not na(lastConfirmedCoreMid)
    coreMidShiftAtr := safeDiv(coreValueMid - lastConfirmedCoreMid, atrValue, 0.0)

bool priceInsideCore = priceInsideValue
bool upperWickThroughEdge = acceptedFound and highSeries > coreValueHigh and closeSeries < coreValueHigh
bool lowerWickThroughEdge = acceptedFound and lowSeries < coreValueLow and closeSeries > coreValueLow
bool failedAuctionCandidate = acceptedFound and wickRejectionRatio >= failedAuctionWickThresholdInput and activityPressureProxy >= 0.35 and (upperWickThroughEdge or lowerWickThroughEdge)
bool migrationUpCandidate = acceptedFound and not na(lastConfirmedCoreMid) and coreMidShiftAtr > migrationAtrThresholdInput and maxAcceptanceScore >= acceptedThresholdInput
bool migrationDownCandidate = acceptedFound and not na(lastConfirmedCoreMid) and coreMidShiftAtr < -migrationAtrThresholdInput and maxAcceptanceScore >= acceptedThresholdInput
bool balanceCandidate = acceptedFound and priceInsideCore and math.abs(coreMidShiftAtr) <= migrationAtrThresholdInput and maxAcceptanceScore >= acceptedThresholdInput

int candidateRegime = REGIME_NEUTRAL
if failedAuctionCandidate
    candidateRegime := REGIME_FAILED_AUCTION
else if migrationUpCandidate
    candidateRegime := REGIME_MIGRATION_UP
else if migrationDownCandidate
    candidateRegime := REGIME_MIGRATION_DOWN
else if balanceCandidate
    candidateRegime := REGIME_BALANCE

if barstate.isconfirmed
    regimeChangedThisBar := false
    barsSinceRegimeChange := barsSinceRegimeChange + 1
    if candidateRegime != pendingRegime
        pendingRegime := candidateRegime
        pendingRegimeBars := 1
    else
        pendingRegimeBars := pendingRegimeBars + 1

    bool regimeCanChange = pendingRegimeBars >= stateConfirmationBarsInput and barsSinceRegimeChange >= cooldownBarsInput
    if regimeCanChange and currentRegime != pendingRegime
        previousRegime := currentRegime
        currentRegime := pendingRegime
        barsSinceRegimeChange := 0
        regimeChangedThisBar := true

    if acceptedFound
        lastConfirmedCoreMid := coreValueMid

string regimeText = "Neutral"
color regimeColor = color.new(NEUTRAL_COLOR, 0)
if currentRegime == REGIME_BALANCE
    regimeText := "Balance"
    regimeColor := color.new(acceptedColorInput, 0)
else if currentRegime == REGIME_MIGRATION_UP
    regimeText := "Migration Up"
    regimeColor := color.new(color.lime, 0)
else if currentRegime == REGIME_MIGRATION_DOWN
    regimeText := "Migration Down"
    regimeColor := color.new(color.red, 0)
else if currentRegime == REGIME_FAILED_AUCTION
    regimeText := "Failed Auction"
    regimeColor := color.new(WARNING_COLOR, 0)
else if currentRegime == REGIME_EXPANSION
    regimeText := "Expansion"
else if currentRegime == REGIME_COMPRESSION
    regimeText := "Compression"
else if currentRegime == REGIME_VACUUM
    regimeText := "Vacuum"
else if currentRegime == REGIME_REACCEPTANCE
    regimeText := "Re-Accept"
else if currentRegime == REGIME_DISTRIBUTION
    regimeText := "Distribution"

//==================================================
// 9. SIGNAL / CONTEXT LOGIC
//==================================================
// Phase I exposes context flags and alert conditions only. No entries, exits, or trade signals.

bool minimalMigrationContext = currentRegime == REGIME_MIGRATION_UP or currentRegime == REGIME_MIGRATION_DOWN
bool minimalFailedAuctionContext = currentRegime == REGIME_FAILED_AUCTION
bool upperAcceptanceEdgeBreak = acceptedFound and closeSeries > coreValueHigh and closeSeries[1] <= nz(coreValueHigh[1], coreValueHigh)
bool lowerAcceptanceEdgeBreak = acceptedFound and closeSeries < coreValueLow and closeSeries[1] >= nz(coreValueLow[1], coreValueLow)
bool acceptanceEdgeBreakContext = upperAcceptanceEdgeBreak or lowerAcceptanceEdgeBreak

bool newRegimeAlertCondition = regimeAlertInput and barstate.isconfirmed and regimeChangedThisBar
bool valueMigrationAlertCondition = migrationAlertInput and barstate.isconfirmed and regimeChangedThisBar and minimalMigrationContext
bool failedAuctionAlertCondition = failedAuctionAlertInput and barstate.isconfirmed and regimeChangedThisBar and minimalFailedAuctionContext
bool acceptanceEdgeBreakAlertCondition = edgeBreakAlertInput and barstate.isconfirmed and acceptanceEdgeBreakContext

//==================================================
// 10. ZONE / LEVEL MANAGEMENT
//==================================================
// Phase I uses one active core value box, upper/lower acceptance edge lines, limited Balanced Mode diagnostic boxes, optional HTF context band and global alertconditions.
// No zone history and no regime zone arrays.

//==================================================
// 11. RISK / QUALITY FILTERS
//==================================================
// Phase J exposes preliminary context quality, minimal regime context, limited Balanced Mode diagnostics, hardened HTF context, confirmed-bar alertconditions and optional validation diagnostics.

//==================================================
// 12. VISUALS / OBJECTS
//==================================================

var box htfContextBox = na
var box coreValueBox = na
var line upperAcceptanceEdgeLine = na
var line lowerAcceptanceEdgeLine = na
var box lowerTransitionBox = na
var box upperTransitionBox = na
var box vacuumBox = na
var label failedAuctionMarker = na

// Phase H.1 hotfix:
// Visuals use the last confirmed acceptance snapshot during the open realtime bar.
// This prevents core/transition/vacuum objects from appearing briefly and vanishing intrabar.
bool useLastConfirmedVisuals = barstate.isrealtime and not barstate.isconfirmed and acceptedFound[1]
bool visualAcceptedFound = useLastConfirmedVisuals ? acceptedFound[1] : acceptedFound
float visualCoreValueLow = useLastConfirmedVisuals ? coreValueLow[1] : coreValueLow
float visualCoreValueHigh = useLastConfirmedVisuals ? coreValueHigh[1] : coreValueHigh
bool visualPriceAwayFromValue = useLastConfirmedVisuals ? priceAwayFromValue[1] : priceAwayFromValue
bool visualLowerTransitionFound = useLastConfirmedVisuals ? lowerTransitionFound[1] : lowerTransitionFound
bool visualUpperTransitionFound = useLastConfirmedVisuals ? upperTransitionFound[1] : upperTransitionFound
bool visualVacuumFound = useLastConfirmedVisuals ? vacuumFound[1] : vacuumFound
float visualLowerTransitionLow = useLastConfirmedVisuals ? lowerTransitionLow[1] : lowerTransitionLow
float visualLowerTransitionHigh = useLastConfirmedVisuals ? lowerTransitionHigh[1] : lowerTransitionHigh
float visualUpperTransitionLow = useLastConfirmedVisuals ? upperTransitionLow[1] : upperTransitionLow
float visualUpperTransitionHigh = useLastConfirmedVisuals ? upperTransitionHigh[1] : upperTransitionHigh
float visualVacuumLow = useLastConfirmedVisuals ? vacuumLow[1] : vacuumLow
float visualVacuumHigh = useLastConfirmedVisuals ? vacuumHigh[1] : vacuumHigh
bool visualFailedAuctionContext = useLastConfirmedVisuals ? minimalFailedAuctionContext[1] : minimalFailedAuctionContext

bool visualUpdateAllowed = barstate.islast
int coreBoxLeftIndex = math.max(bar_index - lookbackInput + 1, 0)
bool showCoreValueStructure = visualAcceptedFound and visualUpdateAllowed

if showCoreValueStructure
    color htfBoxBg = color.new(htfBandColorInput, htfBandTransparencyInput)
    color htfBoxBorder = color.new(htfBandColorInput, 70)
    int coreBoxTransparency = visualPriceAwayFromValue ? math.max(coreBandTransparencyInput, 94) : coreBandTransparencyInput
    int coreBorderTransparency = visualPriceAwayFromValue ? 65 : 32
    int edgeTransparency = visualPriceAwayFromValue ? 55 : 0
    color coreBoxBg = color.new(acceptedColorInput, coreBoxTransparency)
    color coreBoxBorder = color.new(acceptedColorInput, coreBorderTransparency)
    color edgeLineColor = color.new(acceptedColorInput, edgeTransparency)

    bool showHtfContextBand = showHtfBandInput and htfContextReady and (showHtfBandInFocusInput or isBalancedMode or isResearchMode)
    if showHtfContextBand
        if na(htfContextBox)
            htfContextBox := box.new(
                 left=coreBoxLeftIndex,
                 top=htfHigh,
                 right=bar_index,
                 bottom=htfLow,
                 xloc=xloc.bar_index,
                 bgcolor=htfBoxBg,
                 border_color=htfBoxBorder,
                 border_width=1
            )
        else
            box.set_left(htfContextBox, coreBoxLeftIndex)
            box.set_right(htfContextBox, bar_index)
            box.set_top(htfContextBox, htfHigh)
            box.set_bottom(htfContextBox, htfLow)
            box.set_bgcolor(htfContextBox, htfBoxBg)
            box.set_border_color(htfContextBox, htfBoxBorder)
    else if not na(htfContextBox)
        box.delete(htfContextBox)
        htfContextBox := na

    if showCoreBandInput
        if na(coreValueBox)
            coreValueBox := box.new(
                 left=coreBoxLeftIndex,
                 top=visualCoreValueHigh,
                 right=bar_index,
                 bottom=visualCoreValueLow,
                 xloc=xloc.bar_index,
                 bgcolor=coreBoxBg,
                 border_color=coreBoxBorder,
                 border_width=1
            )
        else
            box.set_left(coreValueBox, coreBoxLeftIndex)
            box.set_right(coreValueBox, bar_index)
            box.set_top(coreValueBox, visualCoreValueHigh)
            box.set_bottom(coreValueBox, visualCoreValueLow)
            box.set_bgcolor(coreValueBox, coreBoxBg)
            box.set_border_color(coreValueBox, coreBoxBorder)
    else if not na(coreValueBox)
        box.delete(coreValueBox)
        coreValueBox := na

    if showAcceptanceEdgesInput
        if na(upperAcceptanceEdgeLine)
            upperAcceptanceEdgeLine := line.new(
                 x1=coreBoxLeftIndex,
                 y1=visualCoreValueHigh,
                 x2=bar_index,
                 y2=visualCoreValueHigh,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=edgeLineColor,
                 style=line.style_dashed,
                 width=1
            )
        else
            line.set_x1(upperAcceptanceEdgeLine, coreBoxLeftIndex)
            line.set_y1(upperAcceptanceEdgeLine, visualCoreValueHigh)
            line.set_x2(upperAcceptanceEdgeLine, bar_index)
            line.set_y2(upperAcceptanceEdgeLine, visualCoreValueHigh)
            line.set_color(upperAcceptanceEdgeLine, edgeLineColor)
            line.set_style(upperAcceptanceEdgeLine, line.style_dashed)
            line.set_width(upperAcceptanceEdgeLine, 1)

        if na(lowerAcceptanceEdgeLine)
            lowerAcceptanceEdgeLine := line.new(
                 x1=coreBoxLeftIndex,
                 y1=visualCoreValueLow,
                 x2=bar_index,
                 y2=visualCoreValueLow,
                 xloc=xloc.bar_index,
                 extend=extend.none,
                 color=edgeLineColor,
                 style=line.style_dashed,
                 width=1
            )
        else
            line.set_x1(lowerAcceptanceEdgeLine, coreBoxLeftIndex)
            line.set_y1(lowerAcceptanceEdgeLine, visualCoreValueLow)
            line.set_x2(lowerAcceptanceEdgeLine, bar_index)
            line.set_y2(lowerAcceptanceEdgeLine, visualCoreValueLow)
            line.set_color(lowerAcceptanceEdgeLine, edgeLineColor)
            line.set_style(lowerAcceptanceEdgeLine, line.style_dashed)
            line.set_width(lowerAcceptanceEdgeLine, 1)
    else
        if not na(upperAcceptanceEdgeLine)
            line.delete(upperAcceptanceEdgeLine)
            upperAcceptanceEdgeLine := na
        if not na(lowerAcceptanceEdgeLine)
            line.delete(lowerAcceptanceEdgeLine)
            lowerAcceptanceEdgeLine := na

    bool showBalancedDiagnostics = balancedDiagnosticsEnabled and visualUpdateAllowed
    color transBoxBg = color.new(transitionalColorInput, balancedZoneTransparencyInput)
    color transBoxBorder = color.new(transitionalColorInput, 48)
    color vacuumBoxBg = color.new(vacuumColorInput, balancedZoneTransparencyInput)
    color vacuumBoxBorder = color.new(vacuumColorInput, 56)

    if showBalancedDiagnostics and visualLowerTransitionFound
        if na(lowerTransitionBox)
            lowerTransitionBox := box.new(
                 left=coreBoxLeftIndex,
                 top=visualLowerTransitionHigh,
                 right=bar_index,
                 bottom=visualLowerTransitionLow,
                 xloc=xloc.bar_index,
                 bgcolor=transBoxBg,
                 border_color=transBoxBorder,
                 border_width=1
            )
        else
            box.set_left(lowerTransitionBox, coreBoxLeftIndex)
            box.set_right(lowerTransitionBox, bar_index)
            box.set_top(lowerTransitionBox, visualLowerTransitionHigh)
            box.set_bottom(lowerTransitionBox, visualLowerTransitionLow)
            box.set_bgcolor(lowerTransitionBox, transBoxBg)
            box.set_border_color(lowerTransitionBox, transBoxBorder)
    else if not na(lowerTransitionBox)
        box.delete(lowerTransitionBox)
        lowerTransitionBox := na

    if showBalancedDiagnostics and visualUpperTransitionFound
        if na(upperTransitionBox)
            upperTransitionBox := box.new(
                 left=coreBoxLeftIndex,
                 top=visualUpperTransitionHigh,
                 right=bar_index,
                 bottom=visualUpperTransitionLow,
                 xloc=xloc.bar_index,
                 bgcolor=transBoxBg,
                 border_color=transBoxBorder,
                 border_width=1
            )
        else
            box.set_left(upperTransitionBox, coreBoxLeftIndex)
            box.set_right(upperTransitionBox, bar_index)
            box.set_top(upperTransitionBox, visualUpperTransitionHigh)
            box.set_bottom(upperTransitionBox, visualUpperTransitionLow)
            box.set_bgcolor(upperTransitionBox, transBoxBg)
            box.set_border_color(upperTransitionBox, transBoxBorder)
    else if not na(upperTransitionBox)
        box.delete(upperTransitionBox)
        upperTransitionBox := na

    if showBalancedDiagnostics and visualVacuumFound
        if na(vacuumBox)
            vacuumBox := box.new(
                 left=coreBoxLeftIndex,
                 top=visualVacuumHigh,
                 right=bar_index,
                 bottom=visualVacuumLow,
                 xloc=xloc.bar_index,
                 bgcolor=vacuumBoxBg,
                 border_color=vacuumBoxBorder,
                 border_width=1
            )
        else
            box.set_left(vacuumBox, coreBoxLeftIndex)
            box.set_right(vacuumBox, bar_index)
            box.set_top(vacuumBox, visualVacuumHigh)
            box.set_bottom(vacuumBox, visualVacuumLow)
            box.set_bgcolor(vacuumBox, vacuumBoxBg)
            box.set_border_color(vacuumBox, vacuumBoxBorder)
    else if not na(vacuumBox)
        box.delete(vacuumBox)
        vacuumBox := na

    bool showFailedAuctionMarker = (isBalancedMode or isResearchMode) and showFailedAuctionMarkerInput and visualUpdateAllowed and visualFailedAuctionContext
    if showFailedAuctionMarker
        float markerY = highSeries + atrValue * 0.20
        if na(failedAuctionMarker)
            failedAuctionMarker := label.new(
                 x=bar_index,
                 y=markerY,
                 xloc=xloc.bar_index,
                 text="FA",
                 style=label.style_label_down,
                 textcolor=color.white,
                 color=color.new(WARNING_COLOR, 15),
                 size=size.tiny
            )
        else
            label.set_x(failedAuctionMarker, bar_index)
            label.set_y(failedAuctionMarker, markerY)
            label.set_text(failedAuctionMarker, "FA")
            label.set_textcolor(failedAuctionMarker, color.white)
            label.set_color(failedAuctionMarker, color.new(WARNING_COLOR, 15))
            label.set_style(failedAuctionMarker, label.style_label_down)
            label.set_size(failedAuctionMarker, size.tiny)
    else if not na(failedAuctionMarker)
        label.delete(failedAuctionMarker)
        failedAuctionMarker := na
else if barstate.islast and barstate.isconfirmed and not acceptedFound
    if not na(htfContextBox)
        box.delete(htfContextBox)
        htfContextBox := na
    if not na(coreValueBox)
        box.delete(coreValueBox)
        coreValueBox := na
    if not na(upperAcceptanceEdgeLine)
        line.delete(upperAcceptanceEdgeLine)
        upperAcceptanceEdgeLine := na
    if not na(lowerAcceptanceEdgeLine)
        line.delete(lowerAcceptanceEdgeLine)
        lowerAcceptanceEdgeLine := na
    if not na(lowerTransitionBox)
        box.delete(lowerTransitionBox)
        lowerTransitionBox := na
    if not na(upperTransitionBox)
        box.delete(upperTransitionBox)
        upperTransitionBox := na
    if not na(vacuumBox)
        box.delete(vacuumBox)
        vacuumBox := na
    if not na(failedAuctionMarker)
        label.delete(failedAuctionMarker)
        failedAuctionMarker := na

// Phase J: compact validation diagnostics. These are dashboard-only and disabled by default.
int activeVisualObjectCount = 0
activeVisualObjectCount := activeVisualObjectCount + (not na(htfContextBox) ? 1 : 0)
activeVisualObjectCount := activeVisualObjectCount + (not na(coreValueBox) ? 1 : 0)
activeVisualObjectCount := activeVisualObjectCount + (not na(upperAcceptanceEdgeLine) ? 1 : 0)
activeVisualObjectCount := activeVisualObjectCount + (not na(lowerAcceptanceEdgeLine) ? 1 : 0)
activeVisualObjectCount := activeVisualObjectCount + (not na(lowerTransitionBox) ? 1 : 0)
activeVisualObjectCount := activeVisualObjectCount + (not na(upperTransitionBox) ? 1 : 0)
activeVisualObjectCount := activeVisualObjectCount + (not na(vacuumBox) ? 1 : 0)
activeVisualObjectCount := activeVisualObjectCount + (not na(failedAuctionMarker) ? 1 : 0)

string validationStatusText = "PASS"
if not htfContextReady or not barsReady
    validationStatusText := "WAIT"
else if activeVisualObjectCount > 8
    validationStatusText := "WARN"

string objectBudgetText = str.tostring(activeVisualObjectCount) + "/8"
string pendingRegimeText = "Neutral"
if pendingRegime == REGIME_BALANCE
    pendingRegimeText := "Balance"
else if pendingRegime == REGIME_MIGRATION_UP
    pendingRegimeText := "Migration Up"
else if pendingRegime == REGIME_MIGRATION_DOWN
    pendingRegimeText := "Migration Down"
else if pendingRegime == REGIME_FAILED_AUCTION
    pendingRegimeText := "Failed Auction"
else if pendingRegime == REGIME_EXPANSION
    pendingRegimeText := "Expansion"
else if pendingRegime == REGIME_COMPRESSION
    pendingRegimeText := "Compression"
else if pendingRegime == REGIME_VACUUM
    pendingRegimeText := "Vacuum"
else if pendingRegime == REGIME_REACCEPTANCE
    pendingRegimeText := "Re-Accept"
else if pendingRegime == REGIME_DISTRIBUTION
    pendingRegimeText := "Distribution"
string stateDebugText = "P:" + pendingRegimeText + " " + str.tostring(pendingRegimeBars) + "/" + str.tostring(stateConfirmationBarsInput)
string alertDebugText = "R:" + boolToText(newRegimeAlertCondition) + " M:" + boolToText(valueMigrationAlertCondition) + " E:" + boolToText(acceptanceEdgeBreakAlertCondition) + " F:" + boolToText(failedAuctionAlertCondition)

//==================================================
// 13. DASHBOARD / TABLES
//==================================================
// Phase J.3: table row compaction hotfix.
// Focus/Balanced use 7 rows. Research validation uses 11 rows.
// This removes visible empty rows that appeared when validation rows were hidden.

bool showValidationRows = isResearchMode and showDebugInput and showValidationRowsInput
int desiredDashboardRows = showValidationRows ? 11 : 7

var table dashboardTable = na
var int activeDashboardRows = na

if barstate.islast
    color bgHeader = color.new(color.black, 80)
    color bgValue = color.new(color.black, 90)
    color bgHidden = color.new(color.black, 100)
    color textHidden = color.new(color.white, 100)
    string dashTextSize = getTextSize(dashboardTextSizeInput)

    if na(dashboardTable) or activeDashboardRows != desiredDashboardRows
        if not na(dashboardTable)
            table.delete(dashboardTable)
        dashboardTable := table.new(
             position=getDashboardPosition(dashboardPositionInput),
             columns=2,
             rows=desiredDashboardRows,
             bgcolor=color.new(DASH_BG_COLOR, 90),
             frame_color=color.new(color.gray, 78),
             frame_width=1,
             border_color=color.new(color.gray, 84),
             border_width=1
        )
        activeDashboardRows := desiredDashboardRows

    if showDashboardInput
        table.cell(dashboardTable, 0, 0, DASH_FIELD_MODE, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgHeader, text_size=dashTextSize)
        table.cell(dashboardTable, 1, 0, modeInput, text_color=DASH_TEXT_COLOR, bgcolor=bgHeader, text_size=dashTextSize)

        table.cell(dashboardTable, 0, 1, DASH_FIELD_REGIME, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
        table.cell(dashboardTable, 1, 1, regimeText, text_color=regimeColor, bgcolor=bgValue, text_size=dashTextSize)

        table.cell(dashboardTable, 0, 2, DASH_FIELD_HTF_CONTEXT, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
        table.cell(dashboardTable, 1, 2, htfContextText, text_color=DASH_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)

        table.cell(dashboardTable, 0, 3, DASH_FIELD_CORE_BAND, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
        table.cell(dashboardTable, 1, 3, coreBandText, text_color=DASH_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)

        table.cell(dashboardTable, 0, 4, DASH_FIELD_ACCEPTANCE, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
        table.cell(dashboardTable, 1, 4, acceptanceText, text_color=DASH_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)

        table.cell(dashboardTable, 0, 5, DASH_FIELD_LOCATION, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
        table.cell(dashboardTable, 1, 5, locationText, text_color=locationColor, bgcolor=bgValue, text_size=dashTextSize)

        table.cell(dashboardTable, 0, 6, DASH_FIELD_CONTEXT, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
        table.cell(dashboardTable, 1, 6, contextQualityText, text_color=contextQualityColor, bgcolor=bgValue, text_size=dashTextSize)

        if showValidationRows
            table.cell(dashboardTable, 0, 7, DASH_FIELD_VALIDATION, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
            table.cell(dashboardTable, 1, 7, validationStatusText, text_color=DASH_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
            table.cell(dashboardTable, 0, 8, DASH_FIELD_OBJECTS, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
            table.cell(dashboardTable, 1, 8, objectBudgetText, text_color=DASH_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
            table.cell(dashboardTable, 0, 9, DASH_FIELD_STATE, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
            table.cell(dashboardTable, 1, 9, stateDebugText, text_color=DASH_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
            table.cell(dashboardTable, 0, 10, DASH_FIELD_ALERTS, text_color=DASH_MUTED_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
            table.cell(dashboardTable, 1, 10, alertDebugText, text_color=DASH_TEXT_COLOR, bgcolor=bgValue, text_size=dashTextSize)
    else
        for rowIndex = 0 to desiredDashboardRows - 1
            table.cell(dashboardTable, 0, rowIndex, "", text_color=textHidden, bgcolor=bgHidden, text_size=size.tiny)
            table.cell(dashboardTable, 1, rowIndex, "", text_color=textHidden, bgcolor=bgHidden, text_size=size.tiny)

//==================================================
// 14. ALERTS
//==================================================
// Phase I/J: minimal confirmed-bar alertconditions.
// Messages are intentionally static because alertcondition() requires const strings.
// Alerts are context-only and do not imply entries, exits, buy or sell instructions.

alertcondition(newRegimeAlertCondition, "ARA New Auction Regime", "Auction Regime Atlas: new auction regime confirmed. Context only, not a trade signal.")
alertcondition(valueMigrationAlertCondition, "ARA Value Migration Started", "Auction Regime Atlas: value migration context confirmed. Context only, not a trade signal.")
alertcondition(acceptanceEdgeBreakAlertCondition, "ARA Acceptance Edge Broken", "Auction Regime Atlas: acceptance edge break confirmed. Context only, not a trade signal.")
alertcondition(failedAuctionAlertCondition, "ARA Failed Auction Detected", "Auction Regime Atlas: failed auction context confirmed. Context only, not a trade signal.")

//==================================================
// 15. DEBUG / VALIDATION
//==================================================
// RC1.1 validation outputs are dashboard-only, Research Mode only, and disabled by default. Context-relevance hardening adds explicit Location and fades stale value context.
````
