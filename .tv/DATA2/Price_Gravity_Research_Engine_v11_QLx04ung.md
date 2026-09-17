<!-- tradingview-pine-id: PUB;ec89dd292d5d4b9fa6380c8e0ce4c2c2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Price Gravity Research Engine v1.1

Source: https://www.tradingview.com/script/QLx04ung-Price-Gravity-Research-Engine-Effort-Displacement/

## Description

Price Gravity Research Engine (PG-RE) is a market-state research indicator designed to measure how much normalized market effort is being consumed relative to the amount and efficiency of price movement that effort produces.

The core idea is simple:

Price becomes mechanically “heavy” when substantial effort produces little or inefficient displacement, and “light” when price travels efficiently with comparatively little resistance.

Rather than generating traditional buy/sell signals, PG-RE is built to describe the current movement environment.

Who it is for: PG-RE is especially suited to discretionary intraday, price-action, and market-structure traders who want a regime/context layer for distinguishing clean repricing from inefficient, effort-heavy travel.

What the engine measures

PG-RE evaluates three primary components:

1) Effort

Market activity is normalized relative to its expected baseline.

[*]When usable volume is available, volume is used as the primary effort source.
[*]A range-based activity proxy can be used as an alternative.
[*]On intraday charts, PG-RE can normalize effort by time of day, helping prevent the open or close from being classified as abnormal simply because raw activity is naturally higher during those periods.

2) Displacement

Net price movement over the Gravity Window is measured using log returns and normalized against recent volatility.

This asks:

Has price actually traveled a meaningful distance relative to what volatility would normally imply?

3) Path Efficiency

PG-RE compares net displacement with the total path traveled over the same window.

[*]A direct move has high path efficiency.
[*]A back-and-forth move with little net progress has low path efficiency.

The Gravity model

PG-RE combines normalized effort, volatility-adjusted displacement, and path efficiency into one mechanical measure called Price Gravity.

In practical terms:

[*]more effort with less progress tends to increase gravity
[*]inefficient, rotational travel tends to increase gravity
[*]strong, efficient displacement tends to reduce gravity
[*]efficient movement achieved with relatively little effort represents lighter travel

Gravity is then interpreted relative to its own recent distribution, making PG-RE a regime tool, not a fixed-value oscillator.

It is designed to answer:

“How difficult is it for price to move right now, and is that difficulty changing?”

not:

“Should I buy or sell this bar?”

What is different about PG-RE

Rather than evaluating activity, volatility, or directional movement independently, PG-RE treats their relationship as the object of measurement.

Its primary output is therefore not momentum or volume itself, but the changing amount of normalized effort associated with efficient versus inefficient price travel.

Mechanical states

PG-RE classifies the current environment into several descriptive states:

PRESSURE

Elevated effort is producing unusually weak displacement while travel remains inefficient and gravity is building. Elevated activity is producing little clean progress.

VACUUM ↑ / ↓

Price is producing unusually strong and efficient displacement with comparatively low effort. Movement is encountering relatively little resistance.

ACTIVE REPRICING ↑ / ↓

Both effort and displacement are elevated while travel remains efficient. Price is moving materially and activity is substantial.

DRAG ↑ / ↓

A directional move remains underway, but gravity is increasing while path efficiency remains below the high-efficiency threshold. Progress is becoming mechanically heavier.

LIGHT TRAVEL ↑ / ↓

Displacement is strong and efficient while overall gravity is unusually low.

DEAD ROTATION

Effort and displacement are subdued while travel remains inefficient, producing little directional progress.

RELEASE ↑ / ↓

A recent high-gravity environment is followed by sharply easing gravity while path efficiency improves. Resistance that had previously constrained movement is dissipating.

NEUTRAL

No stronger mechanical condition currently dominates.

Reading the dashboard

PRICE GRAVITY

Current mechanical state.

WEIGHT

Whether gravity is currently HEAVY, NORMAL, or LIGHT relative to its recent distribution.

CHANGE

Whether gravity is BUILDING, STABLE, or EASING.

TRAVEL

Whether price movement is DIRECT, MIXED, or ROTATIONAL.

EFFORT

Whether normalized activity is HIGH, NORMAL, or LOW.

BALANCE

A directional asymmetry proxy combining close-location-weighted effort with cumulative upward versus downward path travel.

Important:

UPSIDE HEAVIER is not a bullish label, and DOWNSIDE HEAVIER is not a bearish label.

[*]UPSIDE HEAVIER means the upward-side gravity proxy is relatively heavier than the downward-side proxy.
[*]DOWNSIDE HEAVIER means the downward-side gravity proxy is relatively heavier than the upward-side proxy.

BALANCE should be interpreted as a relative resistance proxy, not as a direct measurement of buying/selling pressure or order flow.

Direction and gravity should therefore be interpreted separately.

How I use it

PG-RE works best as a market-structure context layer.

I primarily look for transitions between conditions such as:

[*]HEAVY + BUILDING + ROTATIONAL
effort is being consumed without clean travel

[*]LIGHT + DIRECT ↑/↓
price is traveling efficiently with relatively low gravity

[*]PRESSURE → RELEASE
a previously constrained auction begins converting effort into cleaner movement

[*]ACTIVE REPRICING → DRAG
a strong move remains active, but its mechanical efficiency is deteriorating

[*]VACUUM → rising gravity
a low-resistance move begins encountering more opposition

Practical notes

[*]PG-RE is adaptive and distribution-relative, so a “high” reading in one market or timeframe does not need to equal a “high” reading somewhere else in raw-value terms.
[*]The current live bar can evolve as price, range, and volume develop.
[*]The indicator contains no buy/sell labels and makes no forecast claim.
[*]PG-RE measures model-implied movement difficulty from price, volatility, and volume/range data. It does not directly measure order-book liquidity, executed aggressor flow, or physical market resistance.
[*]A warm-up period is required before distribution-relative states become available.
[*]Its purpose is to structure the relationship between effort, displacement, path efficiency, and changing market resistance within one coherent framework.

Quick Use Guide

[*]Start with PRICE GRAVITY and WEIGHT to judge whether the market is mechanically heavy, normal, or light.
[*]Check CHANGE to see whether gravity is building, stable, or easing.
[*]Use TRAVEL to separate direct movement from churn.
[*]Use EFFORT to judge how much participation is present behind the move.
[*]Use BALANCE to identify directional asymmetry in relative resistance.
[*]Treat states as context, not trade arrows.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cheeseboard1991

//@version=6
// Price_Gravity_Research_Engine_v1.1.pine

indicator("Price Gravity Research Engine v1.1", shorttitle="PG-RE v1.1", overlay=false, max_bars_back=5000)
// Price Gravity Research Engine
// Measures abnormal effort relative to volatility-normalized displacement and path efficiency.
// Research instrument only: no buy/sell labels and no forecast claims.

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Inputs                                                                      │
// └─────────────────────────────────────────────────────────────────────────────┘
const string G_MODEL   = "Model"
const string G_EFFORT  = "Effort Normalization"
const string G_STATE   = "State Classification"
const string G_DISPLAY = "Display"

int gravityLen = input.int(
     24,
     "Gravity Window",
     minval=5,
     maxval=250,
     group=G_MODEL,
     tooltip="Rolling window used for effort, net displacement, and path-efficiency measurements."
)

int volLen = input.int(
     30,
     "Volatility Window",
     minval=10,
     maxval=500,
     group=G_MODEL,
     tooltip="Window for expected log-return volatility used to normalize net displacement."
)

int distLen = input.int(
     300,
     "Distribution Window",
     minval=100,
     maxval=2000,
     group=G_MODEL,
     tooltip="Rolling distribution used for robust scores and percent ranks."
)

float ineffWeight = input.float(
     0.75,
     "Inefficiency Weight",
     minval=0.0,
     maxval=3.0,
     step=0.05,
     group=G_MODEL,
     tooltip="Weight applied to path inefficiency in the gravity equation."
)

int gravitySmooth = input.int(
     3,
     "Gravity Smoothing",
     minval=1,
     maxval=20,
     group=G_MODEL,
     tooltip="EMA smoothing applied after the raw gravity calculation."
)

string effortMode = input.string(
     "Auto",
     "Effort Source",
     options=["Auto", "Volume", "Range proxy"],
     group=G_EFFORT,
     tooltip="Auto uses volume when available and otherwise falls back to true range as an explicit proxy."
)

bool useTimeProfile = input.bool(
     true,
     "Normalize Intraday Seasonality",
     group=G_EFFORT,
     tooltip="Uses a minute-of-day EWMA baseline so opening and closing activity are not automatically classified as abnormal."
)

int seasonDays = input.int(
     20,
     "Time-Profile Memory",
     minval=3,
     maxval=120,
     group=G_EFFORT,
     tooltip="Approximate number of same-time observations retained by the minute-of-day EWMA baseline."
)

int minSeasonSamples = input.int(
     5,
     "Minimum Time-Profile Samples",
     minval=1,
     maxval=30,
     group=G_EFFORT,
     tooltip="Before this many same-time observations exist, the engine uses a global EMA baseline."
)

int fallbackLen = input.int(
     50,
     "Fallback Baseline Window",
     minval=10,
     maxval=500,
     group=G_EFFORT,
     tooltip="Global EMA baseline used on non-intraday charts and while the intraday profile is warming up."
)

float highZ = input.float(
     1.00,
     "High Robust-Score Threshold",
     minval=0.25,
     maxval=3.0,
     step=0.05,
     group=G_STATE
)

float lowZ = input.float(
     -0.75,
     "Low Robust-Score Threshold",
     minval=-3.0,
     maxval=-0.10,
     step=0.05,
     group=G_STATE
)

float slopeZ = input.float(
     0.20,
     "Gravity-Change Threshold",
     minval=0.05,
     maxval=2.0,
     step=0.05,
     group=G_STATE,
     tooltip="Minimum standardized gravity change used in Drag, Pressure, and Release states."
)

float efficiencyHigh = input.float(
     0.60,
     "High Path Efficiency",
     minval=0.30,
     maxval=0.95,
     step=0.05,
     group=G_STATE
)

float efficiencyLow = input.float(
     0.25,
     "Low Path Efficiency",
     minval=0.05,
     maxval=0.60,
     step=0.05,
     group=G_STATE
)

int releaseLookback = input.int(
     8,
     "Release Memory",
     minval=2,
     maxval=50,
     group=G_STATE,
     tooltip="Release requires a recent high-gravity condition inside this lookback."
)

bool showComponents = input.bool(
     true,
     "Plot Standardized Components",
     group=G_DISPLAY
)

bool showThresholds = input.bool(
     true,
     "Plot State Thresholds",
     group=G_DISPLAY
)

bool showStateBg = input.bool(
     true,
     "Shade Mechanical State",
     group=G_DISPLAY
)

bool showDataBox = input.bool(
     true,
     "Show Data Box",
     group=G_DISPLAY
)

string dataBoxPosition = input.string(
     "Top Right",
     "Data Box Position",
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"],
     group=G_DISPLAY
)

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Helpers                                                                     │
// └─────────────────────────────────────────────────────────────────────────────┘
float EPS = 1e-10

f_robustZ(float src, int len) =>
    float med = ta.median(src, len)
    float madApprox = ta.median(math.abs(src - med), len)
    (src - med) / (1.4826 * madApprox + EPS)

f_fmt(float value, string formatPattern) =>
    na(value) ? "—" : str.tostring(value, formatPattern)

f_bound(float value, float floorValue, float ceilingValue) =>
    math.max(floorValue, math.min(ceilingValue, value))

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Effort Model                                                                │
// └─────────────────────────────────────────────────────────────────────────────┘
float trueRange = ta.tr(true)
float volumeMean = ta.sma(nz(volume, 0.0), 20)

bool volumeUsable =
     not na(volume) and
     nz(volumeMean, 0.0) > 0.0

bool useVolume =
     effortMode == "Volume" ? volumeUsable :
     effortMode == "Range proxy" ? false :
     volumeUsable

float rawEffort =
     useVolume ? nz(volume, 0.0) : trueRange

float globalBaseline = ta.ema(rawEffort, fallbackLen)
float seasonAlpha = 2.0 / (seasonDays + 1.0)

var array<float> minuteBaseline = array.new_float(1440, na)
var array<int> minuteSamples = array.new_int(1440, 0)

int minuteBucket =
     hour(time, syminfo.timezone) * 60 +
     minute(time, syminfo.timezone)

float storedBaseline = array.get(minuteBaseline, minuteBucket)
int storedSamples = array.get(minuteSamples, minuteBucket)

bool profileEligible =
     timeframe.isintraday and
     useTimeProfile

float activeBaseline =
     profileEligible and
     storedSamples >= minSeasonSamples and
     not na(storedBaseline) ?
     storedBaseline :
     globalBaseline

float relativeEffortBar =
     rawEffort / (activeBaseline + EPS)

relativeEffortBar :=
     f_bound(relativeEffortBar, 0.0, 20.0)

if profileEligible and not na(rawEffort)
    float updatedBaseline =
         na(storedBaseline) ?
         rawEffort :
         storedBaseline + seasonAlpha * (rawEffort - storedBaseline)

    array.set(minuteBaseline, minuteBucket, updatedBaseline)
    array.set(minuteSamples, minuteBucket, storedSamples + 1)

float effort =
     ta.sma(relativeEffortBar, gravityLen)

// Directional allocation proxy: close location within the bar, bounded [-1, +1].
float barRange = high - low

float closeLocation =
     barRange > 0.0 ?
     (2.0 * close - high - low) / barRange :
     0.0

closeLocation :=
     f_bound(closeLocation, -1.0, 1.0)

float positiveEffort =
     ta.sma(
         relativeEffortBar * math.max(closeLocation, 0.0),
         gravityLen
     )

float negativeEffort =
     ta.sma(
         relativeEffortBar * math.max(-closeLocation, 0.0),
         gravityLen
     )

float effortImbalance =
     (positiveEffort - negativeEffort) /
     (positiveEffort + negativeEffort + EPS)

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Displacement and Path Geometry                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
float logReturn =
     close > 0.0 and close[1] > 0.0 ?
     math.log(close / close[1]) :
     0.0

float netLogMove =
     close > 0.0 and close[gravityLen] > 0.0 ?
     math.abs(math.log(close / close[gravityLen])) :
     na

float signedNetLogMove =
     close > 0.0 and close[gravityLen] > 0.0 ?
     math.log(close / close[gravityLen]) :
     na

float pathLength =
     math.sum(math.abs(logReturn), gravityLen)

float expectedMove =
     ta.stdev(logReturn, volLen) *
     math.sqrt(gravityLen)

float displacement =
     netLogMove /
     (expectedMove + EPS)

float pathEfficiency =
     netLogMove /
     (pathLength + EPS)

pathEfficiency :=
     f_bound(pathEfficiency, 0.0, 1.0)

float upwardPath =
     math.sum(math.max(logReturn, 0.0), gravityLen)

float downwardPath =
     math.sum(math.max(-logReturn, 0.0), gravityLen)

float upwardDisplacement =
     upwardPath /
     (expectedMove + EPS)

float downwardDisplacement =
     downwardPath /
     (expectedMove + EPS)

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Gravity Equations                                                           │
// └─────────────────────────────────────────────────────────────────────────────┘
float inefficiency =
     math.max(1.0 - pathEfficiency, EPS)

float rawGravity =
     math.log(1.0 + effort) -
     math.log(displacement + EPS) +
     ineffWeight * math.log(inefficiency + EPS)

float gravity =
     ta.ema(rawGravity, gravitySmooth)

// High values mean more side-specific effort was consumed per unit of
// same-direction path displacement.
float upwardGravity =
     math.log(1.0 + positiveEffort) -
     math.log(upwardDisplacement + EPS) +
     ineffWeight * math.log(inefficiency + EPS)

float downwardGravity =
     math.log(1.0 + negativeEffort) -
     math.log(downwardDisplacement + EPS) +
     ineffWeight * math.log(inefficiency + EPS)

float directionalGravitySpread =
     upwardGravity -
     downwardGravity

float gravityChange =
     ta.change(gravity)

float gravityAcceleration =
     ta.change(gravityChange)

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Rolling Distribution Diagnostics                                            │
// └─────────────────────────────────────────────────────────────────────────────┘
float zGravity =
     f_robustZ(gravity, distLen)

float zEffort =
     f_robustZ(effort, distLen)

float zDisplacement =
     f_robustZ(displacement, distLen)

float zEfficiency =
     f_robustZ(pathEfficiency, distLen)

float zGravityChange =
     f_robustZ(gravityChange, distLen)

float gravityPercentile =
     ta.percentrank(gravity, distLen)

bool ready =
     not na(zGravity) and
     not na(zEffort) and
     not na(zDisplacement) and
     not na(zGravityChange)

bool recentHighGravity =
     ta.highest(zGravity[1], releaseLookback) >
     highZ

bool directionalMove =
     math.abs(nz(signedNetLogMove, 0.0)) >
     expectedMove * 0.35

bool efficiencyRising =
     ta.change(pathEfficiency) >
     0.0

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Mechanical State Classification                                             │
// └─────────────────────────────────────────────────────────────────────────────┘
string directionGlyph =
     nz(signedNetLogMove, 0.0) > 0.0 ? "↑" :
     nz(signedNetLogMove, 0.0) < 0.0 ? "↓" :
     "→"

bool stateRelease =
     ready and
     recentHighGravity and
     zGravityChange < -slopeZ and
     pathEfficiency > efficiencyHigh and
     efficiencyRising

bool statePressure =
     ready and
     zEffort > highZ and
     zDisplacement < lowZ and
     zGravityChange > slopeZ and
     pathEfficiency < efficiencyLow

bool stateVacuum =
     ready and
     zDisplacement > highZ and
     zEffort < lowZ and
     pathEfficiency > efficiencyHigh

bool stateRepricing =
     ready and
     zEffort > highZ and
     zDisplacement > highZ and
     pathEfficiency > efficiencyHigh

bool stateDrag =
     ready and
     directionalMove and
     zGravityChange > slopeZ and
     pathEfficiency < efficiencyHigh

bool stateLight =
     ready and
     zDisplacement > highZ and
     zGravity < lowZ and
     pathEfficiency > efficiencyHigh

bool stateDeadRotation =
     ready and
     zEffort < lowZ and
     zDisplacement < lowZ and
     pathEfficiency < efficiencyLow

string state =
     not ready ? "WARMUP" :
     stateRelease ? "RELEASE " + directionGlyph :
     statePressure ? "PRESSURE" :
     stateVacuum ? "VACUUM " + directionGlyph :
     stateRepricing ? "ACTIVE REPRICING " + directionGlyph :
     stateDrag ? "DRAG " + directionGlyph :
     stateLight ? "LIGHT TRAVEL " + directionGlyph :
     stateDeadRotation ? "DEAD ROTATION" :
     "NEUTRAL"

int stateCode =
     not ready ? 0 :
     stateRelease ? 1 :
     statePressure ? 2 :
     stateVacuum ? 3 :
     stateRepricing ? 4 :
     stateDrag ? 5 :
     stateLight ? 6 :
     stateDeadRotation ? 7 :
     8

color stateColor =
     not ready ? color.new(color.gray, 92) :
     stateRelease ? color.new(color.aqua, 86) :
     statePressure ? color.new(color.orange, 86) :
     stateVacuum ? color.new(color.fuchsia, 88) :
     stateRepricing ? color.new(color.blue, 88) :
     stateDrag ? color.new(color.red, 90) :
     stateLight ? color.new(color.lime, 90) :
     stateDeadRotation ? color.new(color.gray, 90) :
     na

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Research Plots                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
plot(
     showComponents ? zGravity : na,
     "Gravity robust score",
     color=color.white,
     linewidth=3
)

plot(
     showComponents ? zEffort : na,
     "Effort robust score",
     color=color.orange,
     linewidth=1
)

plot(
     showComponents ? zDisplacement : na,
     "Displacement robust score",
     color=color.aqua,
     linewidth=1
)

plot(
     showComponents ? zEfficiency : na,
     "Efficiency robust score",
     color=color.fuchsia,
     linewidth=1
)

hline(
     0.0,
     "Distribution center",
     color=color.new(color.gray, 65)
)

hline(
     showThresholds ? highZ : na,
     "High threshold",
     color=color.new(color.red, 35),
     linestyle=hline.style_dashed
)

hline(
     showThresholds ? lowZ : na,
     "Low threshold",
     color=color.new(color.lime, 35),
     linestyle=hline.style_dashed
)

bgcolor(
     showStateBg ? stateColor : na,
     title="Mechanical state shading"
)

// Data-window diagnostics.
plot(rawGravity, "Raw gravity", display=display.data_window)
plot(gravity, "Smoothed gravity", display=display.data_window)
plot(gravityPercentile, "Gravity percentile", display=display.data_window)
plot(effort, "Relative effort", display=display.data_window)
plot(displacement, "Normalized displacement", display=display.data_window)
plot(pathEfficiency, "Path efficiency", display=display.data_window)
plot(gravityChange, "Gravity change", display=display.data_window)
plot(gravityAcceleration, "Gravity acceleration", display=display.data_window)
plot(upwardGravity, "Upward gravity", display=display.data_window)
plot(downwardGravity, "Downward gravity", display=display.data_window)
plot(directionalGravitySpread, "Directional gravity spread", display=display.data_window)
plot(effortImbalance, "Effort imbalance", display=display.data_window)
plot(stateCode, "State code", display=display.data_window)

// ┌─────────────────────────────────────────────────────────────────────────────┐
// │ Data Box                                                                    │
// └─────────────────────────────────────────────────────────────────────────────┘
const float BALANCE_BAND = 0.1823215568

dataBoxPos =
     dataBoxPosition == "Top Left" ? position.top_left :
     dataBoxPosition == "Bottom Left" ? position.bottom_left :
     dataBoxPosition == "Bottom Right" ? position.bottom_right :
     position.top_right

var table dataBox =
     table.new(
         dataBoxPos,
         2,
         6,
         border_width=1
     )

if barstate.islast and showDataBox
    color panel = color.new(color.black, 12)
    color labelColor = color.silver
    color neutralColor = color.silver

    string weightLabel =
         na(zGravity) ? "—" :
         zGravity > highZ ? "HEAVY" :
         zGravity < lowZ ? "LIGHT" :
         "NORMAL"

    string changeLabel =
         na(zGravityChange) ? "—" :
         zGravityChange > slopeZ ? "BUILDING" :
         zGravityChange < -slopeZ ? "EASING" :
         "STABLE"

    string travelLabel =
         na(pathEfficiency) or na(signedNetLogMove) ? "—" :
         pathEfficiency > efficiencyHigh and signedNetLogMove > 0.0 ? "DIRECT ↑" :
         pathEfficiency > efficiencyHigh and signedNetLogMove < 0.0 ? "DIRECT ↓" :
         pathEfficiency < efficiencyLow ? "ROTATIONAL" :
         "MIXED"

    string effortLabel =
         na(zEffort) ? "—" :
         zEffort > highZ ? "HIGH" :
         zEffort < lowZ ? "LOW" :
         "NORMAL"

    string balanceLabel =
         na(directionalGravitySpread) ? "—" :
         directionalGravitySpread > BALANCE_BAND ? "UPSIDE HEAVIER" :
         directionalGravitySpread < -BALANCE_BAND ? "DOWNSIDE HEAVIER" :
         "BALANCED"

    color stateCellBg =
         na(stateColor) ?
         panel :
         stateColor

    color weightColor =
         weightLabel == "HEAVY" ? color.orange :
         weightLabel == "LIGHT" ? color.aqua :
         neutralColor

    color changeColor =
         changeLabel == "BUILDING" ? color.orange :
         changeLabel == "EASING" ? color.aqua :
         neutralColor

    color travelColor =
         travelLabel == "DIRECT ↑" ? color.lime :
         travelLabel == "DIRECT ↓" ? color.red :
         travelLabel == "ROTATIONAL" ? color.gray :
         neutralColor

    color effortColor =
         effortLabel == "HIGH" ? color.orange :
         effortLabel == "LOW" ? color.aqua :
         neutralColor

    color balanceColor =
         balanceLabel == "UPSIDE HEAVIER" ? color.orange :
         balanceLabel == "DOWNSIDE HEAVIER" ? color.aqua :
         neutralColor

    table.cell(
         dataBox,
         0,
         0,
         "PRICE GRAVITY",
         bgcolor=panel,
         text_color=color.white,
         text_halign=text.align_left
    )

    table.cell(
         dataBox,
         1,
         0,
         state,
         bgcolor=stateCellBg,
         text_color=color.white,
         text_halign=text.align_right
    )

    table.cell(
         dataBox,
         0,
         1,
         "WEIGHT",
         bgcolor=panel,
         text_color=labelColor,
         text_halign=text.align_left
    )

    table.cell(
         dataBox,
         1,
         1,
         weightLabel,
         bgcolor=panel,
         text_color=weightColor,
         text_halign=text.align_right
    )

    table.cell(
         dataBox,
         0,
         2,
         "CHANGE",
         bgcolor=panel,
         text_color=labelColor,
         text_halign=text.align_left
    )

    table.cell(
         dataBox,
         1,
         2,
         changeLabel,
         bgcolor=panel,
         text_color=changeColor,
         text_halign=text.align_right
    )

    table.cell(
         dataBox,
         0,
         3,
         "TRAVEL",
         bgcolor=panel,
         text_color=labelColor,
         text_halign=text.align_left
    )

    table.cell(
         dataBox,
         1,
         3,
         travelLabel,
         bgcolor=panel,
         text_color=travelColor,
         text_halign=text.align_right
    )

    table.cell(
         dataBox,
         0,
         4,
         "EFFORT",
         bgcolor=panel,
         text_color=labelColor,
         text_halign=text.align_left
    )

    table.cell(
         dataBox,
         1,
         4,
         effortLabel,
         bgcolor=panel,
         text_color=effortColor,
         text_halign=text.align_right
    )

    table.cell(
         dataBox,
         0,
         5,
         "BALANCE",
         bgcolor=panel,
         text_color=labelColor,
         text_halign=text.align_left
    )

    table.cell(
         dataBox,
         1,
         5,
         balanceLabel,
         bgcolor=panel,
         text_color=balanceColor,
         text_halign=text.align_right
    )

if barstate.islast and not showDataBox
    table.clear(dataBox, 0, 0, 1, 5)
````
