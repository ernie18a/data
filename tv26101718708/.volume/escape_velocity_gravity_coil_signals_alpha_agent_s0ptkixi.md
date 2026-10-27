# Escape Velocity: Gravity & Coil Signals [Alpha Agent]

- url: https://www.tradingview.com/script/s0PTkIXI-Escape-Velocity-Gravity-Coil-Signals-Alpha-Agent/
- type: indicator
- pine_id: PUB;6d08ccbb4cd0421a9aabaf2b6d008949
- version: 1.0

## Description

Escape Velocity looks for the moment a market stops struggling and starts moving.

This is the rebuilt, open-source version of my earlier script Houdini. The full source code is published here.

IN PLAIN ENGLISH

Most of the time, price spends a lot of effort going nowhere: volume comes in, candles overlap, and the net result is a sideways grind. Escape Velocity measures that struggle (I call it Price Gravity) and watches for two conditions that can come before a clean move:

- Compression: price gets squeezed into a narrowing wedge. The script draws it as an amber COIL zone.
- Release: the struggle eases and price starts traveling efficiently in one direction again.

When those line up, it prints a signal. Every signal is confirmed on bar close, so what you see on a closed bar does not change afterwards.

On the chart you get:
- LONG / SHORT: the primary entries (neon rings).
- COIL: an amber compression zone, drawn when a wedge matures. While the zone is live, hover its COIL label to see the bias.
- SIG9: a confirmed cup-and-handle breakout (expansion).
- LONG+ / SHORT+: the 4-hour chart confirms the move. It can appear on a LONG or SHORT entry, or on its own as a separate 4-hour signal.
- A glowing adaptive corridor that shows the current trend leg, plus the two legs before it.
- A status panel (the Agent HUD, top right) that shows the current state, regime, flow quality, path efficiency and the last entry.
- A trade manager that draws entry, stop and three targets for a LONG / SHORT (one managed trade at a time).

Two display styles, same signals: Terminal (default) and Alpha-Glow (the Alpha Agent neon palette).


HOW IT WORKS (FOR QUANTS)

Escape Velocity combines five components. Each has a single job, and the signals come from how they line up, not from any one of them alone.

1. Price Gravity (the core model)
- Effort is volume normalized against its own time-of-day profile: a per-minute seasonal baseline built over roughly the last 20 sessions. When volume is unavailable, true range is used instead.
- Displacement is the net log move over the window, divided by the move you would expect from recent return volatility.
- Path efficiency is net move divided by total path traveled, from 0 to 1.
- Gravity rises when effort is high but displacement and efficiency are low: energy is being absorbed without progress.
- The main inputs are converted to robust z-scores (median / MAD) so the model adapts across symbols and sessions.
- A directional split (upside vs downside effort and gravity) tells the engine which side is doing the work.

2. Adaptive structure corridor
- The corridor's center line is a Kaufman adaptive average. Its width is ATR-based and widens automatically as the market gets noisier (lower efficiency ratio).
- The regime (BULL / BEAR / TRANSITION) needs slope, efficiency and position all to agree. A regime only flips after price holds beyond the opposite band for consecutive closed bars, which filters one-bar wicks.

3. COIL (compression)
- A wedge is drawn from the last two confirmed pivot highs and the last two confirmed pivot lows.
- It qualifies when both edges slope the same way, converge to a clearly narrower width than where they started, and hold that shape for several consecutive closed bars.
- A falling wedge gives COIL with a bullish bias; a rising wedge gives COIL with a bearish bias.

4. Entries
- LONG: a bullish COIL must come first. A LONG prints only if, within a short window after it, price either shifts the structure regime to bullish or closes through the wedge's upper edge. This sequencing (compression, then release) is the heart of the long side.
- SHORT: fires when downside path efficiency is high and most of a nine-part gravity-release checklist agrees (efficiency building, gravity easing, displacement expanding, effort aligned to the downside). A cooldown prevents clustering.
- SIG9: a cup-and-handle breakout. It needs a cup of meaningful ATR depth, a shallow handle, a pattern that has matured, and a closed-bar break of the handle high.

5. STRONG 4H power (the + badge)
- A confirmation layer from the completed 4-hour bar: trend filter, fast-average cross and above-average volume.
- On charts below 4H it reads only the last completed 4H bar, using TradingView's documented non-repainting request pattern. On a 4H chart it uses the chart's own closed bars. It is disabled on charts above 4H.


WHAT MAKES IT ORIGINAL

- Price Gravity is my own effort-versus-progress model. It combines time-of-day-normalized effort, volatility-scaled displacement and path efficiency into one robust score, with a directional split.
- LONG entries are gated by a compression-then-release sequence (COIL first, then a structural or wedge breakout), not by a single trigger.
- The COIL zone shows the engine's actual wedge rather than a generic pattern overlay.
- Signals, zones, corridor and HUD share one visual language, so the whole state reads at a glance.


HOW TO USE IT

- Use standard candles. On Heikin Ashi, Renko, Kagi, Point & Figure, Line Break and Range charts, the script hides its signals, zones, trade levels and panels and shows a notice instead.
- Works on intraday and higher timeframes. The seasonal effort model works best on liquid intraday symbols with volume.
- Read the HUD first: REGIME and FLOW tell you whether the market is trending cleanly or chopping.
- A live COIL zone means compression. Watch which side price leaves it from.
- LONG / SHORT are the entries. SIG9 and COIL are context, not entries.
- Alerts: create them on a standard-candle chart and set them to "Once Per Bar Close". Available alerts cover COIL (ARMED) long/short, structure changes, LONG, SHORT, SIG9 (listed as MAGIC SIG9), STRONG long/short, and the trade manager events (activated, TP1, profit lock, TP2, TP3, stop, timeout).

Settings, briefly:
- Trade Manager: Auto ATR or Fixed Dollar stop and targets, profit lock after TP1, maximum holding bars.
- Display: signal hierarchy, Terminal / Alpha-Glow style, signal size, corridors, corridor fill (Neon Glass / Original / Subtle), COIL zones, HUD on/off and position.


LIMITATIONS AND DISCLOSURES

- Bar-close confirmation: signals appear when the bar closes, not intra-bar. That is deliberate, and it means entries arrive after the triggering candle is complete.
- The COIL zone is drawn back to the wedge's starting point. It is drawn once, on the bar COIL fires, using only pivots already confirmed on that bar, and its shape never changes afterwards. Pivots confirm a few bars after they form, so COIL is by nature a slightly delayed read of compression.
- LONG is selective: it needs a prior COIL, so it will not catch every rally.
- STRONG reads the last completed 4-hour bar, so it can lag by up to one 4H bar. It is off on charts above 4H.
- The seasonal effort baseline needs a few sessions of intraday history. Until then the script uses a standard average. On symbols without volume, effort falls back to true range.
- Trade manager levels are a visual guide, not orders. Target and stop hits are judged from bar highs and lows, so the order of intra-bar touches cannot be known, and fills, slippage and fees are not modeled.
- Alerts are evaluated on whatever chart they are created on. Create them on standard candles.
- No indicator predicts the future. Signals are designed to flag conditions that can come before directional moves; they are not guarantees. Nothing here is financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cheeseboard1991
// Escape Velocity: Gravity & Coil Signals [Alpha Agent]
// Alpha Agent by Einstein's Unified
//
// Adaptive structure indicator built on a price-gravity engine that weighs
// trading effort against displacement and path efficiency.
//
// Signals (all confirmed on bar close):
//   LONG / SHORT   primary entries
//   MAGIC SIG9     confirmed cup break / expansion
//   COIL           matured wedge compression (the ARMED setup behind LONG)
//   STRONG (+)     completed-4H power confirmation, non-repainting
//
// Includes a scalp trade manager (Auto ATR or fixed dollar targets)
// and two display styles: Terminal and Alpha-Glow.

//@version=6
indicator(
    "Escape Velocity: Gravity & Coil Signals [Alpha Agent]",
    shorttitle="ESC VEL",
    overlay=true,
    max_bars_back=5000,
    max_labels_count=500,
    max_lines_count=500,
    max_boxes_count=500
)

// -----------------------------------------------------------------------------
// Production constants
// -----------------------------------------------------------------------------

const float EPS = 1e-10

const int STRUCTURE_KAMA_LEN = 34
const int STRUCTURE_ER_LEN = 20
const int STRUCTURE_ATR_LEN = 21
const int STRUCTURE_SLOPE_BARS = 5

const float STRUCTURE_MIN_ER = 0.24
const float STRUCTURE_MIN_SLOPE_ATR = 0.07
const float STRUCTURE_BASE_WIDTH_ATR = 1.05
const float STRUCTURE_NOISE_EXPANSION = 0.65

const int STRUCTURE_TREND_BREAK_BARS = 2

const int CUP_LOOKBACK = 30
const int CUP_HANDLE_BARS = 6
const float CUP_MIN_DEPTH_ATR = 2.00
const float CUP_RIM_TOLERANCE = 0.22
const float CUP_HANDLE_MAX_DEPTH = 0.42

const int PATTERN_MATURITY_BARS = 4
const int PATTERN_BREAK_COOLDOWN_BARS = 20

const int WEDGE_PIVOT_LEFT = 3
const int WEDGE_PIVOT_RIGHT = 3
const int WEDGE_MAX_BARS = 55
const float WEDGE_TIGHTNESS = 0.80

const int ARMED_TO_EARLY_WINDOW = 12

const int GRAVITY_LEN = 24
const int VOL_LEN = 30
const int DIST_LEN = 300
const float INEFF_WEIGHT = 0.75
const int GRAVITY_SMOOTH = 3

const float HIGH_Z = 1.00
const float LOW_Z = -0.75
const float SLOPE_Z = 0.20
const float EFFICIENCY_HIGH = 0.60
const float EFFICIENCY_LOW = 0.25
const int RELEASE_LOOKBACK = 8

const int SEASON_DAYS = 20
const int MIN_SEASON_SAMPLES = 5
const int FALLBACK_LEN = 50

const float MAGIC_PRE_EFFICIENCY = 0.42
const int MAGIC_SIGNAL_SCORE_MIN = 7
const int MAGIC_COOLDOWN_BARS = 5

const int ENS_FAST_LEN = 9
const int ENS_TREND_LEN = 200
const int ENS_VOLUME_LEN = 20
const float ENS_VOLUME_MINIMUM = 1.10

const string G_MANAGER = "Trade Manager"
const string G_DISPLAY = "Display"

// -----------------------------------------------------------------------------
// Minimal production inputs
// -----------------------------------------------------------------------------

string distanceMode = input.string(
    "Auto ATR",
    "TP / SL Mode",
    options=["Auto ATR", "Fixed Dollar"],
    group=G_MANAGER
)

int distanceAtrLength = input.int(
    14,
    "ATR Length",
    minval=1,
    maxval=500,
    group=G_MANAGER
)

float stopAtrMultiplier = input.float(
    0.75,
    "Stop ATR Multiplier",
    minval=0.05,
    step=0.05,
    group=G_MANAGER
)

float scalpStopCash = input.float(
    150.0,
    "Dollar Stop / Contract",
    minval=1.0,
    step=10.0,
    group=G_MANAGER
)

float scalpTp1Cash = input.float(
    200.0,
    "Dollar TP1 / Contract",
    minval=1.0,
    step=10.0,
    group=G_MANAGER
)

float scalpTp2Cash = input.float(
    300.0,
    "Dollar TP2 / Contract",
    minval=1.0,
    step=10.0,
    group=G_MANAGER
)

float scalpTp3Cash = input.float(
    400.0,
    "Dollar TP3 / Contract",
    minval=1.0,
    step=10.0,
    group=G_MANAGER
)

float scalpLockCash = input.float(
    50.0,
    "Dollar Lock After TP1 / Contract",
    minval=0.0,
    step=10.0,
    group=G_MANAGER
)

int scalpMaxBars = input.int(
    40,
    "Maximum Holding Bars",
    minval=1,
    maxval=1000,
    group=G_MANAGER
)


string displayDetail = input.string(
    "Full Signal Hierarchy",
    "Display Detail",
    options=["Full Signal Hierarchy", "Primary Entries Only"],
    group=G_DISPLAY,
    tooltip="Full Signal Hierarchy shows every signal label. Primary Entries Only hides MAGIC SIG9, COIL (ARMED) and STRONG 4H markers without changing signal calculations, alerts, or trade management."
)

bool fullSignalDisplay = displayDetail == "Full Signal Hierarchy"


bool showStructureCorridors = input.bool(
    true,
    "Show Structure Corridors",
    group=G_DISPLAY,
    tooltip="Shows the current adaptive structural leg plus the prior two legs as lightweight directional corridors. Visual only."
)

bool showStatusChip = input.bool(
    true,
    "Show Alpha Agent Status",
    group=G_DISPLAY,
    tooltip="Shows a compact structure / flow quality / efficiency / state card. Visual only."
)

string signalStyle = input.string(
    "Terminal",
    "Signal Style",
    options=["Terminal", "Alpha-Glow"],
    group=G_DISPLAY,
    tooltip="Terminal = neon ring orbs on tethers with callout labels and a cyan glass Agent HUD. Alpha-Glow = the same layout in the Alpha Agent neon palette: cyan LONG, magenta SHORT, violet SIG9, amber COIL compression zones, cyan/magenta corridor and a cyan/magenta glass HUD. A color theme only; it works in every session and on every timeframe. Visual only."
)

string signalSize = input.string(
    "Standard",
    "Signal Size",
    options=["Compact", "Standard", "Bold"],
    group=G_DISPLAY,
    tooltip="Compact suits traders who read candles closely. Bold suits screenshots and zoomed-out charts. Visual only."
)

bool fadeOlderSignals = input.bool(
    true,
    "Settle Older Signals",
    group=G_DISPLAY,
    tooltip="After the glow window a signal settles in place: glow off, ring and lines dimmed, label kept. Visual only."
)

int glowDurationBars = input.int(
    10,
    "Glow Duration (bars)",
    minval=1,
    maxval=500,
    group=G_DISPLAY,
    tooltip="How many bars a signal keeps its full glow before it settles in place. Visual only."
)

bool showCoilZones = input.bool(
    true,
    "Show COIL Zones",
    group=G_DISPLAY,
    tooltip="COIL = compression. When the engine's wedge matures, the wedge is drawn as a neon amber compression zone from where it began. It is drawn once, on the bar COIL fires, from pivots already confirmed on that bar, and never changes shape afterwards. It ends when a candle closes outside it, at LONG / SHORT, or where its edges meet, then settles slightly dimmer. Styled like the Neon Glass corridor: brightest at the edges, clear at the center. A newer zone replaces any older zone it overlaps. Visual only: COIL alerts are unaffected."
)

string statusCardPosition = input.string(
    "Top Right",
    "Status Card Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
    group=G_DISPLAY,
    tooltip="Moves the Agent HUD. Visual only."
)

string corridorFillStyle = input.string(
    "Neon Glass",
    "Corridor Fill",
    options=["Neon Glass", "Original", "Subtle"],
    group=G_DISPLAY,
    tooltip="Neon Glass = the live corridor leg glows brightest at its edges and fades to clear at the center line; prior legs stay light. Original = full-strength fill. Subtle = lighter single-tone fill. Brightness follows flow efficiency in every mode. Visual only."
)

bool afterhoursStyle = signalStyle == "Alpha-Glow"
bool signatureSignals = true
bool quantifiedStyle = true
bool corridorGlass = corridorFillStyle == "Neon Glass"

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

f_bound(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_robustZ(float src, int len) =>
    float medianValue = ta.median(src, len)
    float madValue = ta.median(math.abs(src - medianValue), len)
    float result = (src - medianValue) / (1.4826 * madValue + EPS)
    result

f_structureEfficiency(float src, int len) =>
    float net = math.abs(src - src[len])
    float noise = ta.sma(math.abs(ta.change(src)), len) * len
    float result = not na(noise) and noise > 0.0 ? net / noise : 0.0
    result

f_structureKama(float src, int erLen, int fastLen, int slowLen) =>
    float priceChange = math.abs(src - src[erLen])
    float volatility = ta.sma(math.abs(ta.change(src)), erLen) * erLen
    float efficiencyRatio = not na(volatility) and volatility > 0.0 ? priceChange / volatility : 0.0
    float fastConstant = 2.0 / (fastLen + 1.0)
    float slowConstant = 2.0 / (slowLen + 1.0)
    float smoothing = math.pow(
        efficiencyRatio * (fastConstant - slowConstant) + slowConstant,
        2.0
    )

    float kama = na
    kama := na(kama[1]) ? src : kama[1] + smoothing * (src - kama[1])
    kama

f_project(int x1, float y1, int x2, float y2, int targetX) =>
    float result = (
        x2 == x1 ?
            y1 :
            y1 + ((y2 - y1) / float(x2 - x1)) * float(targetX - x1)
    )

    result

f_roundDistance(float value) =>
    float tickSize = math.max(syminfo.mintick, EPS)
    float rounded = math.round(value / tickSize) * tickSize
    math.max(tickSize, rounded)

f_distanceText(float value) =>
    str.tostring(value, "#.########")

f_pointValue() =>
    float pointValue = syminfo.pointvalue
    float result = not na(pointValue) and pointValue > 0.0 ? pointValue : 1.0
    result

f_cashDistance(float cashAmount) =>
    cashAmount / f_pointValue()

f_cashText(float value) =>
    "$" + str.tostring(value, "#.0")

f_managementText(float distance, float cashAmount, bool cashMode) =>
    cashMode ? f_cashText(cashAmount) : f_distanceText(distance)

f_ensStrongLong() =>
    float fastEma = ta.ema(close, ENS_FAST_LEN)
    float trendSma = ta.sma(close, ENS_TREND_LEN)
    float averageVolume = ta.sma(volume, ENS_VOLUME_LEN)

    float volumeEnergy = (
        not na(averageVolume) and averageVolume > 0.0 ?
            volume / averageVolume :
            0.0
    )

    bool crossUp = ta.crossover(close, fastEma)

    bool signal = (
        close > trendSma and
        crossUp and
        volumeEnergy >= ENS_VOLUME_MINIMUM
    )

    signal

f_ensStrongShort() =>
    float fastEma = ta.ema(close, ENS_FAST_LEN)
    float trendSma = ta.sma(close, ENS_TREND_LEN)
    float averageVolume = ta.sma(volume, ENS_VOLUME_LEN)

    float volumeEnergy = (
        not na(averageVolume) and averageVolume > 0.0 ?
            volume / averageVolume :
            0.0
    )

    bool crossDown = ta.crossunder(close, fastEma)

    bool signal = (
        close < trendSma and
        crossDown and
        volumeEnergy >= ENS_VOLUME_MINIMUM
    )

    signal

// -----------------------------------------------------------------------------
// Effort normalization
// -----------------------------------------------------------------------------

float trueRange = ta.tr(true)
float volumeMean = ta.sma(nz(volume, 0.0), 20)

bool volumeUsable = (
    not na(volume) and
    nz(volumeMean, 0.0) > 0.0
)

float rawEffort = (
    volumeUsable ?
        nz(volume, 0.0) :
        trueRange
)

float globalBaseline = ta.ema(rawEffort, FALLBACK_LEN)
float seasonAlpha = 2.0 / (SEASON_DAYS + 1.0)

var array<float> minuteBaseline = array.new_float(1440, na)
var array<int> minuteSamples = array.new_int(1440, 0)

int minuteBucket = (
    hour(time, syminfo.timezone) * 60 +
    minute(time, syminfo.timezone)
)

float storedBaseline = array.get(minuteBaseline, minuteBucket)
int storedSamples = array.get(minuteSamples, minuteBucket)

bool profileEligible = timeframe.isintraday

float activeBaseline = (
    profileEligible and
    storedSamples >= MIN_SEASON_SAMPLES and
    not na(storedBaseline) ?
        storedBaseline :
        globalBaseline
)

float relativeEffortBar = rawEffort / (activeBaseline + EPS)
relativeEffortBar := f_bound(relativeEffortBar, 0.0, 20.0)

if profileEligible and not na(rawEffort)
    float updatedBaseline = (
        na(storedBaseline) ?
            rawEffort :
            storedBaseline +
            seasonAlpha *
            (rawEffort - storedBaseline)
    )

    array.set(
        minuteBaseline,
        minuteBucket,
        updatedBaseline
    )

    array.set(
        minuteSamples,
        minuteBucket,
        storedSamples + 1
    )

float effort = ta.sma(
    relativeEffortBar,
    GRAVITY_LEN
)

float barRange = high - low

float closeLocation = (
    barRange > 0.0 ?
        (2.0 * close - high - low) / barRange :
        0.0
)

closeLocation := f_bound(
    closeLocation,
    -1.0,
    1.0
)

float positiveEffort = ta.sma(
    relativeEffortBar * math.max(closeLocation, 0.0),
    GRAVITY_LEN
)

float negativeEffort = ta.sma(
    relativeEffortBar * math.max(-closeLocation, 0.0),
    GRAVITY_LEN
)

float effortImbalance = (
    (positiveEffort - negativeEffort) /
    (positiveEffort + negativeEffort + EPS)
)

// -----------------------------------------------------------------------------
// Price Gravity
// -----------------------------------------------------------------------------

float logReturn = (
    close > 0.0 and close[1] > 0.0 ?
        math.log(close / close[1]) :
        0.0
)

float netLogMove = (
    close > 0.0 and close[GRAVITY_LEN] > 0.0 ?
        math.abs(math.log(close / close[GRAVITY_LEN])) :
        na
)

float signedNetLogMove = (
    close > 0.0 and close[GRAVITY_LEN] > 0.0 ?
        math.log(close / close[GRAVITY_LEN]) :
        na
)

float pathLength = math.sum(
    math.abs(logReturn),
    GRAVITY_LEN
)

float expectedMove = (
    ta.stdev(logReturn, VOL_LEN) *
    math.sqrt(GRAVITY_LEN)
)

float displacement = (
    netLogMove /
    (expectedMove + EPS)
)

float pathEfficiency = (
    netLogMove /
    (pathLength + EPS)
)

pathEfficiency := f_bound(
    pathEfficiency,
    0.0,
    1.0
)

float upwardPath = math.sum(
    math.max(logReturn, 0.0),
    GRAVITY_LEN
)

float downwardPath = math.sum(
    math.max(-logReturn, 0.0),
    GRAVITY_LEN
)

float upwardDisplacement = (
    upwardPath /
    (expectedMove + EPS)
)

float downwardDisplacement = (
    downwardPath /
    (expectedMove + EPS)
)

float inefficiency = math.max(
    1.0 - pathEfficiency,
    EPS
)

float rawGravity = (
    math.log(1.0 + effort) -
    math.log(displacement + EPS) +
    INEFF_WEIGHT * math.log(inefficiency + EPS)
)

float gravity = ta.ema(
    rawGravity,
    GRAVITY_SMOOTH
)

float upwardGravity = (
    math.log(1.0 + positiveEffort) -
    math.log(upwardDisplacement + EPS) +
    INEFF_WEIGHT * math.log(inefficiency + EPS)
)

float downwardGravity = (
    math.log(1.0 + negativeEffort) -
    math.log(downwardDisplacement + EPS) +
    INEFF_WEIGHT * math.log(inefficiency + EPS)
)

float directionalGravitySpread = (
    upwardGravity -
    downwardGravity
)

float gravityChange = ta.change(gravity)
float gravityAcceleration = ta.change(gravityChange)

float zGravity = f_robustZ(gravity, DIST_LEN)
float zEffort = f_robustZ(effort, DIST_LEN)
float zDisplacement = f_robustZ(displacement, DIST_LEN)
float zGravityChange = f_robustZ(gravityChange, DIST_LEN)

bool gravityReady = (
    not na(zGravity) and
    not na(zEffort) and
    not na(zDisplacement) and
    not na(zGravityChange) and
    not na(pathEfficiency) and
    not na(directionalGravitySpread) and
    not na(effortImbalance)
)

bool recentHighGravity = (
    ta.highest(zGravity[1], RELEASE_LOOKBACK) > HIGH_Z
)

bool pressureNow = (
    gravityReady and
    zEffort > HIGH_Z and
    zDisplacement < LOW_Z and
    zGravityChange > SLOPE_Z and
    pathEfficiency < EFFICIENCY_LOW
)

float pressureFlag = pressureNow ? 1.0 : 0.0

bool recentPressure = (
    ta.highest(pressureFlag[1], RELEASE_LOOKBACK) > 0.0
)

// -----------------------------------------------------------------------------
// Direct SHORT engine
// -----------------------------------------------------------------------------

float magicPreGate = math.min(
    MAGIC_PRE_EFFICIENCY,
    math.max(
        EFFICIENCY_HIGH - 0.05,
        0.0
    )
)

bool magicDown = (
    nz(signedNetLogMove, 0.0) < 0.0
)

bool magicEfficiencyPrimed = (
    not na(pathEfficiency) and
    pathEfficiency >= magicPreGate
)

float pathEfficiencyChange = ta.change(pathEfficiency)
float zDisplacementChange = ta.change(zDisplacement)

bool magicEfficiencyBuilding = (
    not na(pathEfficiencyChange) and
    pathEfficiencyChange > 0.0
)

bool magicGravityEasing = (
    not na(zGravityChange) and
    zGravityChange < 0.0
)

bool magicGravityAccelerationEasing = (
    not na(gravityAcceleration) and
    gravityAcceleration <= 0.0
)

bool magicDisplacementBuilding = (
    not na(zDisplacementChange) and
    zDisplacementChange > 0.0
)

bool magicEffortAlive = (
    not na(zEffort) and
    zEffort > LOW_Z
)

bool magicShortEffortAligned = (
    not na(effortImbalance) and
    effortImbalance < 0.0
)

bool magicShortLaneOpen = (
    not na(directionalGravitySpread) and
    directionalGravitySpread > 0.0
)

bool magicStoredEnergy = (
    recentHighGravity or
    recentPressure
)

int magicShortScore = (
    (magicDown ? 1 : 0) +
    (magicEfficiencyPrimed ? 1 : 0) +
    (magicEfficiencyBuilding ? 1 : 0) +
    (magicGravityEasing ? 1 : 0) +
    (magicDisplacementBuilding ? 1 : 0) +
    (magicEffortAlive ? 1 : 0) +
    (magicShortEffortAligned ? 1 : 0) +
    (magicShortLaneOpen ? 1 : 0) +
    (
        magicStoredEnergy or
        magicGravityAccelerationEasing ?
            1 :
            0
    )
)

bool magicShortDirectRaw = (
    gravityReady and
    magicDown and
    pathEfficiency >= EFFICIENCY_HIGH and
    magicShortScore >= MAGIC_SIGNAL_SCORE_MIN
)

// -----------------------------------------------------------------------------
// Adaptive structure
// -----------------------------------------------------------------------------

float structureAtr = ta.atr(
    STRUCTURE_ATR_LEN
)

float structureKama = f_structureKama(
    close,
    STRUCTURE_KAMA_LEN,
    2,
    30
)

float structureEr = f_structureEfficiency(
    close,
    STRUCTURE_ER_LEN
)

float structureSlope = (
    structureKama -
    structureKama[STRUCTURE_SLOPE_BARS]
)

float structureSlopeAtr = (
    structureAtr > 0.0 ?
        structureSlope / structureAtr :
        0.0
)

float structureWidthMultiplier = (
    STRUCTURE_BASE_WIDTH_ATR +
    (
        1.0 -
        f_bound(
            structureEr,
            0.0,
            1.0
        )
    ) *
    STRUCTURE_NOISE_EXPANSION
)

float structureHalfWidth = (
    structureAtr *
    structureWidthMultiplier
)

float structureUpper = (
    structureKama +
    structureHalfWidth
)

float structureLower = (
    structureKama -
    structureHalfWidth
)

bool structureBullRaw = (
    close > structureKama and
    structureSlopeAtr >= STRUCTURE_MIN_SLOPE_ATR and
    structureEr >= STRUCTURE_MIN_ER
)

bool structureBearRaw = (
    close < structureKama and
    structureSlopeAtr <= -STRUCTURE_MIN_SLOPE_ATR and
    structureEr >= STRUCTURE_MIN_ER
)

var int structureTrendState = 0
var int structureUpBreachBars = 0
var int structureDownBreachBars = 0

int previousStructureState = nz(
    structureTrendState[1],
    0
)

structureUpBreachBars := (
    previousStructureState == 1 and
    close < structureLower ?
        nz(structureUpBreachBars[1]) + 1 :
        0
)

structureDownBreachBars := (
    previousStructureState == -1 and
    close > structureUpper ?
        nz(structureDownBreachBars[1]) + 1 :
        0
)

bool breakBullStructure = (
    previousStructureState == 1 and
    structureUpBreachBars >= STRUCTURE_TREND_BREAK_BARS
)

bool breakBearStructure = (
    previousStructureState == -1 and
    structureDownBreachBars >= STRUCTURE_TREND_BREAK_BARS
)

if previousStructureState == 1
    if breakBullStructure
        structureTrendState := (
            structureBearRaw ?
                -1 :
                0
        )
    else
        structureTrendState := 1

else if previousStructureState == -1
    if breakBearStructure
        structureTrendState := (
            structureBullRaw ?
                1 :
                0
        )
    else
        structureTrendState := -1

else
    if structureBullRaw
        structureTrendState := 1
    else if structureBearRaw
        structureTrendState := -1
    else
        structureTrendState := 0

bool adaptiveBullShift = (
    barstate.isconfirmed and
    structureTrendState == 1 and
    previousStructureState != 1
)

bool adaptiveBearShift = (
    barstate.isconfirmed and
    structureTrendState == -1 and
    previousStructureState != -1
)

// -----------------------------------------------------------------------------
// Cup break / MAGIC SIG9
// -----------------------------------------------------------------------------

float cupRim = ta.highest(
    high,
    CUP_LOOKBACK
)[1]

float cupBase = ta.lowest(
    low,
    CUP_LOOKBACK
)

float cupDepth = (
    not na(cupRim) and
    not na(cupBase) ?
        cupRim - cupBase :
        0.0
)

float handleHigh = ta.highest(
    high,
    CUP_HANDLE_BARS
)[1]

float handleLow = ta.lowest(
    low,
    CUP_HANDLE_BARS
)

float handleDepthFraction = (
    cupDepth > syminfo.mintick ?
        (cupRim - handleLow) / cupDepth :
        999.0
)

bool nearCupRim = (
    cupDepth > 0.0 and
    close >= cupRim - cupDepth * CUP_RIM_TOLERANCE
)

bool cupCandidate = (
    structureTrendState >= 0 and
    cupDepth >= structureAtr * CUP_MIN_DEPTH_ATR and
    nearCupRim and
    handleDepthFraction >= 0.0 and
    handleDepthFraction <= CUP_HANDLE_MAX_DEPTH and
    handleHigh >= cupRim - cupDepth * CUP_RIM_TOLERANCE
)

var int cupRun = 0

cupRun := (
    cupCandidate ?
        cupRun + 1 :
        0
)

bool cupMaturePrior = (
    nz(cupRun[1]) >=
    PATTERN_MATURITY_BARS
)

var int lastCupBreakBar = na

bool cupBreakEvent = false

if (
    barstate.isconfirmed and
    cupMaturePrior and
    not na(handleHigh) and
    close > handleHigh and
    (
        na(lastCupBreakBar) or
        bar_index - lastCupBreakBar >= PATTERN_BREAK_COOLDOWN_BARS
    )
)
    cupBreakEvent := true
    lastCupBreakBar := bar_index

bool magicSig9Event = cupBreakEvent

// -----------------------------------------------------------------------------
// Wedge / ARMED engine
// -----------------------------------------------------------------------------

float pivotHigh = ta.pivothigh(
    high,
    WEDGE_PIVOT_LEFT,
    WEDGE_PIVOT_RIGHT
)

float pivotLow = ta.pivotlow(
    low,
    WEDGE_PIVOT_LEFT,
    WEDGE_PIVOT_RIGHT
)

var float ph1 = na
var float ph2 = na
var int ph1Bar = na
var int ph2Bar = na

var float pl1 = na
var float pl2 = na
var int pl1Bar = na
var int pl2Bar = na

if not na(pivotHigh)
    ph2 := ph1
    ph2Bar := ph1Bar
    ph1 := pivotHigh
    ph1Bar := bar_index - WEDGE_PIVOT_RIGHT

if not na(pivotLow)
    pl2 := pl1
    pl2Bar := pl1Bar
    pl1 := pivotLow
    pl1Bar := bar_index - WEDGE_PIVOT_RIGHT

bool wedgeReady = (
    not na(ph1) and
    not na(ph2) and
    not na(pl1) and
    not na(pl2) and
    not na(ph1Bar) and
    not na(ph2Bar) and
    not na(pl1Bar) and
    not na(pl2Bar)
)

float wedgeUpperNow = (
    wedgeReady ?
        f_project(
            ph2Bar,
            ph2,
            ph1Bar,
            ph1,
            bar_index
        ) :
        na
)

float wedgeLowerNow = (
    wedgeReady ?
        f_project(
            pl2Bar,
            pl2,
            pl1Bar,
            pl1,
            bar_index
        ) :
        na
)

int wedgeStartBar = (
    wedgeReady ?
        math.max(
            ph2Bar,
            pl2Bar
        ) :
        na
)

float wedgeUpperStart = (
    wedgeReady ?
        f_project(
            ph2Bar,
            ph2,
            ph1Bar,
            ph1,
            wedgeStartBar
        ) :
        na
)

float wedgeLowerStart = (
    wedgeReady ?
        f_project(
            pl2Bar,
            pl2,
            pl1Bar,
            pl1,
            wedgeStartBar
        ) :
        na
)

float wedgeWidthNow = (
    wedgeReady ?
        wedgeUpperNow -
        wedgeLowerNow :
        na
)

float wedgeWidthStart = (
    wedgeReady ?
        wedgeUpperStart -
        wedgeLowerStart :
        na
)

float highSlope = (
    wedgeReady ?
        (ph1 - ph2) /
        math.max(
            float(ph1Bar - ph2Bar),
            1.0
        ) :
        na
)

float lowSlope = (
    wedgeReady ?
        (pl1 - pl2) /
        math.max(
            float(pl1Bar - pl2Bar),
            1.0
        ) :
        na
)

int wedgeAge = (
    wedgeReady ?
        bar_index -
        wedgeStartBar :
        9999
)

bool ascendingWedge = (
    wedgeReady and
    wedgeAge <= WEDGE_MAX_BARS and
    ph1 > ph2 and
    pl1 > pl2 and
    highSlope > 0.0 and
    lowSlope > highSlope and
    wedgeWidthNow > syminfo.mintick and
    wedgeWidthStart > 0.0 and
    wedgeWidthNow <= wedgeWidthStart * WEDGE_TIGHTNESS
)

bool descendingWedge = (
    wedgeReady and
    wedgeAge <= WEDGE_MAX_BARS and
    ph1 < ph2 and
    pl1 < pl2 and
    lowSlope < 0.0 and
    highSlope < lowSlope and
    wedgeWidthNow > syminfo.mintick and
    wedgeWidthStart > 0.0 and
    wedgeWidthNow <= wedgeWidthStart * WEDGE_TIGHTNESS
)

var int ascendingWedgeRun = 0
var int descendingWedgeRun = 0

ascendingWedgeRun := (
    ascendingWedge ?
        ascendingWedgeRun + 1 :
        0
)

descendingWedgeRun := (
    descendingWedge ?
        descendingWedgeRun + 1 :
        0
)

bool bearishArmedEvent = (
    barstate.isconfirmed and
    ascendingWedgeRun == PATTERN_MATURITY_BARS
)

bool bullishArmedEvent = (
    barstate.isconfirmed and
    descendingWedgeRun == PATTERN_MATURITY_BARS
)

var int lastAscendingWedgeBreakBar = na
var int lastDescendingWedgeBreakBar = na

bool ascendingWedgeBreakEvent = false

if (
    barstate.isconfirmed and
    nz(ascendingWedgeRun[1]) >= PATTERN_MATURITY_BARS and
    not na(wedgeLowerNow) and
    close < wedgeLowerNow and
    (
        na(lastAscendingWedgeBreakBar) or
        bar_index - lastAscendingWedgeBreakBar >= PATTERN_BREAK_COOLDOWN_BARS
    )
)
    ascendingWedgeBreakEvent := true
    lastAscendingWedgeBreakBar := bar_index

bool descendingWedgeBreakEvent = false

if (
    barstate.isconfirmed and
    nz(descendingWedgeRun[1]) >= PATTERN_MATURITY_BARS and
    not na(wedgeUpperNow) and
    close > wedgeUpperNow and
    (
        na(lastDescendingWedgeBreakBar) or
        bar_index - lastDescendingWedgeBreakBar >= PATTERN_BREAK_COOLDOWN_BARS
    )
)
    descendingWedgeBreakEvent := true
    lastDescendingWedgeBreakBar := bar_index

bool earlyLongEvent = (
    adaptiveBullShift or
    descendingWedgeBreakEvent
)

var int lastBullArmedBar = na

if bullishArmedEvent
    lastBullArmedBar := bar_index

bool recentBullArmed = (
    not na(lastBullArmedBar) and
    bar_index - lastBullArmedBar <= ARMED_TO_EARLY_WINDOW
)

bool longSignal = (
    earlyLongEvent and
    recentBullArmed
)

// -----------------------------------------------------------------------------
// Production SHORT
// -----------------------------------------------------------------------------

var int lastMagicSignalBar = na

bool shortCooldownReady = (
    na(lastMagicSignalBar) or
    bar_index - lastMagicSignalBar >= MAGIC_COOLDOWN_BARS
)

bool shortSignal = (
    barstate.isconfirmed and
    shortCooldownReady and
    magicShortDirectRaw and
    not magicShortDirectRaw[1] and
    not magicSig9Event
)

if magicSig9Event or shortSignal
    lastMagicSignalBar := bar_index

// -----------------------------------------------------------------------------
// Confirmed 4H power
// -----------------------------------------------------------------------------

// Non-repainting 4H power (TradingView noRepaintSecurity pattern):
// chart below 4H -> last CONFIRMED 4H value ([1] + lookahead_on are
//                   interdependent: no future leak, same on history and live)
// chart on 4H    -> computed on the chart's own confirmed bars
// chart above 4H -> disabled (no lower-timeframe requests)
int strong4hChartSeconds = timeframe.in_seconds()
int strong4hSeconds = timeframe.in_seconds("240")

bool strongLong4hConfirmedHtf = request.security(
    syminfo.tickerid,
    "240",
    f_ensStrongLong()[1],
    gaps=barmerge.gaps_off,
    lookahead=barmerge.lookahead_on
)

bool strongShort4hConfirmedHtf = request.security(
    syminfo.tickerid,
    "240",
    f_ensStrongShort()[1],
    gaps=barmerge.gaps_off,
    lookahead=barmerge.lookahead_on
)

bool strongLong4hOnChart = f_ensStrongLong()
bool strongShort4hOnChart = f_ensStrongShort()

bool strongLong4hState = (
    strong4hChartSeconds < strong4hSeconds ?
        strongLong4hConfirmedHtf :
        strong4hChartSeconds == strong4hSeconds ?
            strongLong4hOnChart :
            false
)

bool strongShort4hState = (
    strong4hChartSeconds < strong4hSeconds ?
        strongShort4hConfirmedHtf :
        strong4hChartSeconds == strong4hSeconds ?
            strongShort4hOnChart :
            false
)

bool strongLong4hEvent = (
    barstate.isconfirmed and
    strongLong4hState and
    not strongLong4hState[1]
)

bool strongShort4hEvent = (
    barstate.isconfirmed and
    strongShort4hState and
    not strongShort4hState[1]
)

// -----------------------------------------------------------------------------
// Alpha Agent visual layer
// Visual-only. No value below is referenced by signal, alert, or trade logic.
// -----------------------------------------------------------------------------

color aaBull = afterhoursStyle ? color.rgb(0, 229, 255) : color.rgb(60, 255, 140)
color aaBear = afterhoursStyle ? color.rgb(255, 46, 200) : color.rgb(255, 62, 118)
color aaBullSoft = color.rgb(198, 255, 221)
color aaBearSoft = color.rgb(255, 191, 211)
color aaIce = color.rgb(118, 214, 255)
color aaCyan = color.rgb(0, 229, 255)
color aaAmber = color.rgb(255, 184, 64)
color aaPanel = color.rgb(13, 17, 23)

f_aaStateColor(int state) =>
    state == 1 ? aaBull : state == -1 ? aaBear : aaIce

// Corridor Fill: Original keeps full-strength transparencies; Subtle and
// Neon Glass use lighter ones. The efficiency-driven brightness order
// (pulse > clean > mixed > choppy) is preserved in every mode.
f_aaFill(int classicTransparency, int subtleTransparency) =>
    corridorFillStyle == "Original" ? classicTransparency : subtleTransparency

// Live leg under Neon Glass: the single fill is cleared and the glass bands
// (drawn in the Terminal/Alpha-Glow renderer) take over.
f_aaLiveFill(int classicTransparency, int subtleTransparency) =>
    corridorGlass ? 100 : f_aaFill(classicTransparency, subtleTransparency)

// --- Segmented adaptive structure corridors: current leg + prior two legs ---

var line aaCurrentUpper = na
var line aaCurrentMid = na
var line aaCurrentLower = na
var linefill aaCurrentFill = na
var int aaCurrentState = na
var int aaCurrentStartBar = na
var float aaCurrentStartUpper = na
var float aaCurrentStartMid = na
var float aaCurrentStartLower = na

var line aaPrev1Upper = na
var line aaPrev1Mid = na
var line aaPrev1Lower = na
var linefill aaPrev1Fill = na
var int aaPrev1State = na

var line aaPrev2Upper = na
var line aaPrev2Mid = na
var line aaPrev2Lower = na
var linefill aaPrev2Fill = na
var int aaPrev2State = na

var int aaArmedHighlightUntil = na
var int aaEntryPulseUntil = na
var int aaEntryPulseDirection = 0

if bullishArmedEvent or bearishArmedEvent
    aaArmedHighlightUntil := bar_index + 3

if longSignal
    aaEntryPulseUntil := bar_index + 2
    aaEntryPulseDirection := 1

else if shortSignal
    aaEntryPulseUntil := bar_index + 2
    aaEntryPulseDirection := -1

bool aaArmedHighlight = (
    not na(aaArmedHighlightUntil) and
    bar_index <= aaArmedHighlightUntil
)

bool aaEntryPulseActive = (
    not na(aaEntryPulseUntil) and
    bar_index <= aaEntryPulseUntil
)

bool aaStructureReady = (
    not na(structureUpper) and
    not na(structureLower) and
    not na(structureKama)
)

bool aaConfirmedStateChange = (
    barstate.isconfirmed and
    not na(aaCurrentState) and
    structureTrendState != aaCurrentState
)

bool aaNeedNewCorridor = (
    aaStructureReady and
    (
        na(aaCurrentUpper) or
        aaConfirmedStateChange
    )
)

// Corridors are drawn on standard candles only: Heikin Ashi, Renko and similar
// charts use synthetic prices.
bool aaShowCorridors = showStructureCorridors and chart.is_standard

if aaShowCorridors and aaNeedNewCorridor
    if not na(aaCurrentUpper)
        if not na(aaPrev2Fill)
            linefill.delete(aaPrev2Fill)
        if not na(aaPrev2Upper)
            line.delete(aaPrev2Upper)
        if not na(aaPrev2Mid)
            line.delete(aaPrev2Mid)
        if not na(aaPrev2Lower)
            line.delete(aaPrev2Lower)

        aaPrev2Upper := aaPrev1Upper
        aaPrev2Mid := aaPrev1Mid
        aaPrev2Lower := aaPrev1Lower
        aaPrev2Fill := aaPrev1Fill
        aaPrev2State := aaPrev1State

        if not na(aaPrev2Upper)
            color aaPrev2Color = f_aaStateColor(aaPrev2State)
            line.set_color(aaPrev2Upper, color.new(aaPrev2Color, 78))
            line.set_color(aaPrev2Mid, color.new(aaPrev2Color, 88))
            line.set_color(aaPrev2Lower, color.new(aaPrev2Color, 78))
            linefill.set_color(aaPrev2Fill, color.new(aaPrev2Color, f_aaFill(94, 97)))

        aaPrev1Upper := aaCurrentUpper
        aaPrev1Mid := aaCurrentMid
        aaPrev1Lower := aaCurrentLower
        aaPrev1Fill := aaCurrentFill
        aaPrev1State := aaCurrentState

        if not na(aaPrev1Upper)
            color aaPrev1Color = f_aaStateColor(aaPrev1State)
            line.set_color(aaPrev1Upper, color.new(aaPrev1Color, 55))
            line.set_color(aaPrev1Mid, color.new(aaPrev1Color, 76))
            line.set_color(aaPrev1Lower, color.new(aaPrev1Color, 55))
            linefill.set_color(aaPrev1Fill, color.new(aaPrev1Color, f_aaFill(89, 94)))

    aaCurrentState := structureTrendState
    aaCurrentStartBar := bar_index
    aaCurrentStartUpper := structureUpper
    aaCurrentStartMid := structureKama
    aaCurrentStartLower := structureLower

    color aaStartColor = f_aaStateColor(aaCurrentState)

    aaCurrentUpper := line.new(
        x1=aaCurrentStartBar,
        y1=aaCurrentStartUpper,
        x2=bar_index,
        y2=structureUpper,
        xloc=xloc.bar_index,
        extend=extend.none,
        color=color.new(aaStartColor, 18),
        width=1
    )

    aaCurrentMid := line.new(
        x1=aaCurrentStartBar,
        y1=aaCurrentStartMid,
        x2=bar_index,
        y2=structureKama,
        xloc=xloc.bar_index,
        extend=extend.none,
        color=color.new(aaStartColor, 58),
        style=line.style_dotted,
        width=1
    )

    aaCurrentLower := line.new(
        x1=aaCurrentStartBar,
        y1=aaCurrentStartLower,
        x2=bar_index,
        y2=structureLower,
        xloc=xloc.bar_index,
        extend=extend.none,
        color=color.new(aaStartColor, 18),
        width=1
    )

    aaCurrentFill := linefill.new(
        aaCurrentUpper,
        aaCurrentLower,
        color.new(aaStartColor, f_aaLiveFill(84, 92))
    )

if aaShowCorridors and not na(aaCurrentUpper) and aaStructureReady
    color aaCurrentBase = f_aaStateColor(aaCurrentState)

    color aaPulseColor = (
        aaEntryPulseDirection == 1 ?
            aaBull :
            aaEntryPulseDirection == -1 ?
                aaBear :
                aaCurrentBase
    )

    color aaCurrentEdge = (
        aaEntryPulseActive ?
            aaPulseColor :
            aaArmedHighlight ?
                aaAmber :
                aaCurrentBase
    )

    int aaEdgeTransparency = (
        aaEntryPulseActive ?
            0 :
            na(pathEfficiency) ?
                34 :
                pathEfficiency >= EFFICIENCY_HIGH ?
                    4 :
                    pathEfficiency <= EFFICIENCY_LOW ?
                        52 :
                        24
    )

    int aaMidTransparency = (
        aaEntryPulseActive ?
            14 :
            na(pathEfficiency) ?
                60 :
                pathEfficiency >= EFFICIENCY_HIGH ?
                    32 :
                    pathEfficiency <= EFFICIENCY_LOW ?
                        76 :
                        54
    )

    int aaFillTransparency = (
        aaEntryPulseActive ?
            f_aaLiveFill(64, 70) :
            na(pathEfficiency) ?
                f_aaLiveFill(86, 92) :
                pathEfficiency >= EFFICIENCY_HIGH ?
                    f_aaLiveFill(72, 80) :
                    pathEfficiency <= EFFICIENCY_LOW ?
                        f_aaLiveFill(93, 97) :
                        f_aaLiveFill(84, 92)
    )

    line.set_xy2(aaCurrentUpper, bar_index, structureUpper)
    line.set_xy2(aaCurrentMid, bar_index, structureKama)
    line.set_xy2(aaCurrentLower, bar_index, structureLower)

    line.set_color(aaCurrentUpper, color.new(aaCurrentEdge, aaEdgeTransparency))
    line.set_color(aaCurrentMid, color.new(aaCurrentEdge, aaMidTransparency))
    line.set_color(aaCurrentLower, color.new(aaCurrentEdge, aaEdgeTransparency))
    linefill.set_color(
        aaCurrentFill,
        color.new(aaEntryPulseActive ? aaPulseColor : aaCurrentBase, aaFillTransparency)
    )

    line.set_width(aaCurrentUpper, aaEntryPulseActive ? 3 : 1)
    line.set_width(aaCurrentMid, aaEntryPulseActive ? 2 : 1)
    line.set_width(aaCurrentLower, aaEntryPulseActive ? 3 : 1)

// --- Alpha Agent status card ---

string aaStructureText = (
    structureTrendState == 1 ?
        "BULL" :
        structureTrendState == -1 ?
            "BEAR" :
            "TRANSITION"
)

color aaStructureColor = f_aaStateColor(structureTrendState)

string aaFlowQuality = (
    na(pathEfficiency) ?
        "--" :
        pathEfficiency >= EFFICIENCY_HIGH ?
            "CLEAN" :
            pathEfficiency <= EFFICIENCY_LOW ?
                "CHOPPY" :
                "MIXED"
)

color aaFlowColor = (
    aaFlowQuality == "CLEAN" ?
        aaBull :
        aaFlowQuality == "CHOPPY" ?
            aaAmber :
            aaIce
)

string aaStateText = (
    aaEntryPulseActive and aaEntryPulseDirection == 1 ?
        "LONG FIRE" :
        aaEntryPulseActive and aaEntryPulseDirection == -1 ?
            "SHORT FIRE" :
            magicSig9Event ?
                "SIG9" :
                aaArmedHighlight ?
                    "ARMED" :
                    "MONITOR"
)

color aaStateColor = (
    aaStateText == "LONG FIRE" ?
        aaBull :
        aaStateText == "SHORT FIRE" ?
            aaBear :
            aaStateText == "SIG9" ?
                aaCyan :
                aaStateText == "ARMED" ?
                    aaAmber :
                    aaStructureColor
)

string aaCardPosition = (
    statusCardPosition == "Top Left" ?
        position.top_left :
        statusCardPosition == "Bottom Right" ?
            position.bottom_right :
            statusCardPosition == "Bottom Left" ?
                position.bottom_left :
                position.top_right
)

// -----------------------------------------------------------------------------
// Trader-facing UI priority engine
// -----------------------------------------------------------------------------

bool primarySignalEvent = (
    longSignal or
    shortSignal
)

bool structureSignalEvent = (
    adaptiveBullShift or
    adaptiveBearShift
)

bool armedSignalEvent = (
    bullishArmedEvent or
    bearishArmedEvent
)

bool showMagicVisual = (
    magicSig9Event and
    not primarySignalEvent
)

bool showStructureVisual = (
    structureSignalEvent and
    not primarySignalEvent and
    not magicSig9Event
)

bool showArmedVisual = (
    armedSignalEvent and
    not primarySignalEvent and
    not magicSig9Event and
    not structureSignalEvent
)

// -----------------------------------------------------------------------------
// Spacing unit (visual only)
// -----------------------------------------------------------------------------
//
// Spacing unit: 1% of the recent price range, so the gap between candle and
// orb stays close to constant in pixels on 45s, 5m or 4h charts. An ATR floor
// covers quiet sessions.

float aaRecentRange = ta.highest(high, 200) - ta.lowest(low, 200)

float aaUnit = math.max(
    nz(aaRecentRange, 0.0) / 100.0,
    math.max(
        nz(structureAtr, 0.0) * 0.15,
        syminfo.mintick * 4.0
    )
)

// -----------------------------------------------------------------------------
// Signal renderer (Terminal and Alpha-Glow)
// -----------------------------------------------------------------------------
//
// Visual-only. Reads signal events; never writes to them.
//
// One orb family, one grammar:
// LONG / SHORT        = neon ring with bloom glow (largest)
// STRONG LONG / SHORT = same execution ring + small "+" badge
// SIG9                = cyan ring with soft glow
// COIL                = amber compression zone (see COIL zone below)
//
// Every orb sits clear of its trigger candle on a thin tether, with its label
// on an angled callout line. Live signals glow for Glow Duration bars, then
// settle IN PLACE: glow off, ring and lines dimmed, label kept. Nothing ever
// slides back onto the candles.
//
// Spacing unit: 1% of the recent price range. The price range a chart shows is
// roughly what fits on screen, so this keeps the gap between candle, orb and
// label close to constant in pixels on 45s, 5m, 4h. An ATR floor covers quiet
// sessions.

const int SG_KIND_ARMED = 1
const int SG_KIND_SIG9 = 2
const int SG_KIND_ENTRY = 3
const int SG_KIND_STRONG = 4
const int SG_CALLOUT_BARS = 3
const int SG_MAX_LINED = 60

color sgNeonGreen = color.rgb(24, 255, 120)
color sgNeonGreenCore = color.rgb(214, 255, 228)
color sgNeonRed = color.rgb(255, 40, 120)
color sgNeonRedCore = color.rgb(255, 218, 232)
color sgSig9Cyan = color.rgb(0, 222, 255)
color sgPillDark = color.rgb(10, 14, 20)
color sgPillBlack = color.rgb(0, 0, 0)

// Alpha-Glow = Alpha Agent neon palette; Terminal keeps its colors.
color sgLongTone = afterhoursStyle ? color.rgb(0, 229, 255) : sgNeonGreen
color sgLongCore = afterhoursStyle ? color.rgb(210, 250, 255) : sgNeonGreenCore
color sgShortTone = afterhoursStyle ? color.rgb(255, 46, 200) : sgNeonRed
color sgShortCore = afterhoursStyle ? color.rgb(255, 214, 244) : sgNeonRedCore
color sgSig9Tone = afterhoursStyle ? color.rgb(168, 96, 255) : sgSig9Cyan

float sgUnit = aaUnit

type SgSignal
    int sigKind
    int sigBar
    color tone
    line tether
    line leader
    label bloom
    label halo
    label shell
    label gap
    label core
    label badge
    label caption

var array<SgSignal> sgLive = array.new<SgSignal>()
var array<SgSignal> sgSettled = array.new<SgSignal>()

f_sgPick(string sgCompact, string sgStandard, string sgBold) =>
    signalSize == "Compact" ? sgCompact : signalSize == "Bold" ? sgBold : sgStandard

f_sgPickF(float sgCompact, float sgStandard, float sgBold) =>
    signalSize == "Compact" ? sgCompact : signalSize == "Bold" ? sgBold : sgStandard

f_sgDot(float sgY, color sgColor, string sgSize, string sgTip) =>
    label.new(
        bar_index,
        sgY,
        "",
        xloc=xloc.bar_index,
        yloc=yloc.price,
        style=label.style_circle,
        color=sgColor,
        textcolor=color.new(color.white, 100),
        size=sgSize,
        tooltip=sgTip
    )

// Orb anatomy (outermost first): bloom, glow, ring, ring cut-out, core.
// "" skips a layer. sgGlyph != "" draws the ring as a text glyph instead.
f_sgCreate(int sgKind, float sgSide, color sgTone, color sgCoreTone, string sgBloomSize, string sgHaloSize, string sgShellSize, string sgGapSize, string sgCoreSize, string sgGlyph, int sgShellT, int sgTetherT, float sgOrbUnits, float sgCaptionUnits, string sgCaptionText, int sgPillT, bool sgBadgeOn, string sgTip) =>
    float sgU = sgUnit
    float sgAnchor = sgSide < 0.0 ? low : high
    float sgOrbY = sgAnchor + sgSide * sgU * sgOrbUnits
    int sgCaptionX = bar_index + SG_CALLOUT_BARS
    float sgCaptionY = sgOrbY + sgSide * sgU * sgCaptionUnits * 0.7

    // Tether is drawn first so the orb sits over its outer end.
    line sgTether = line.new(
        x1=bar_index,
        y1=sgAnchor + sgSide * sgU * 1.2,
        x2=bar_index,
        y2=sgOrbY,
        xloc=xloc.bar_index,
        extend=extend.none,
        color=color.new(sgTone, sgTetherT),
        width=1
    )

    // Angled callout line from the orb out to its label.
    line sgLeader = line.new(
        x1=bar_index,
        y1=sgOrbY,
        x2=sgCaptionX,
        y2=sgCaptionY,
        xloc=xloc.bar_index,
        extend=extend.none,
        color=color.new(sgTone, 35),
        width=1
    )

    label sgBloom = na
    if sgBloomSize != ""
        sgBloom := f_sgDot(sgOrbY, color.new(sgTone, 90), sgBloomSize, sgTip)

    label sgHalo = na
    if sgHaloSize != ""
        sgHalo := f_sgDot(sgOrbY, color.new(sgTone, 72), sgHaloSize, sgTip)

    label sgShell = na
    if sgGlyph != ""
        sgShell := label.new(
            bar_index,
            sgOrbY,
            sgGlyph,
            xloc=xloc.bar_index,
            yloc=yloc.price,
            style=label.style_none,
            textcolor=color.new(sgTone, sgShellT),
            size=sgShellSize,
            tooltip=sgTip
        )
    else
        sgShell := f_sgDot(sgOrbY, color.new(sgTone, sgShellT), sgShellSize, sgTip)

    // Hollow ring: a chart-background disc cut into the ring.
    label sgGap = na
    if sgGapSize != ""
        sgGap := f_sgDot(sgOrbY, chart.bg_color, sgGapSize, sgTip)

    label sgCore = na
    if sgCoreSize != ""
        sgCore := f_sgDot(sgOrbY, sgCoreTone, sgCoreSize, sgTip)

    // STRONG 4H badge: a small "+" disc on the orb's shoulder.
    label sgBadge = na
    if sgBadgeOn
        sgBadge := label.new(
            bar_index + 1,
            sgOrbY - sgSide * sgU * 3.5,
            "+",
            xloc=xloc.bar_index,
            yloc=yloc.price,
            style=label.style_circle,
            color=sgTone,
            textcolor=sgPillBlack,
            size=size.tiny,
            tooltip=sgTip
        )

    // Dark pill with neon text at the end of the callout line.
    label sgCaption = label.new(
        sgCaptionX,
        sgCaptionY,
        sgCaptionText,
        xloc=xloc.bar_index,
        yloc=yloc.price,
        style=label.style_label_left,
        color=color.new(sgPillDark, sgPillT),
        textcolor=color.new(sgTone, sgPillT),
        size=size.small,
        tooltip=sgTip
    )

    SgSignal sgNew = SgSignal.new(
        sgKind,
        bar_index,
        sgTone,
        sgTether,
        sgLeader,
        sgBloom,
        sgHalo,
        sgShell,
        sgGap,
        sgCore,
        sgBadge,
        sgCaption
    )

    sgLive.push(sgNew)

    true

f_sgDropLines(SgSignal sgItem) =>
    if not na(sgItem.tether)
        line.delete(sgItem.tether)

    if not na(sgItem.leader)
        line.delete(sgItem.leader)

    true

f_sgDelete(SgSignal sgItem) =>
    f_sgDropLines(sgItem)

    if not na(sgItem.bloom)
        label.delete(sgItem.bloom)

    if not na(sgItem.halo)
        label.delete(sgItem.halo)

    if not na(sgItem.shell)
        label.delete(sgItem.shell)

    if not na(sgItem.gap)
        label.delete(sgItem.gap)

    if not na(sgItem.core)
        label.delete(sgItem.core)

    if not na(sgItem.badge)
        label.delete(sgItem.badge)

    if not na(sgItem.caption)
        label.delete(sgItem.caption)

    true

// Settle in place: glow, core and badge off; ring, lines and label dimmed.
// The orb keeps its position, so candles never get crowded.
f_sgSettle(SgSignal sgItem) =>
    bool sgIsEntry = (
        sgItem.sigKind == SG_KIND_ENTRY or
        sgItem.sigKind == SG_KIND_STRONG
    )

    int sgRingT = sgIsEntry ? 20 : 40
    int sgTextT = sgIsEntry ? 0 : 35

    if not na(sgItem.bloom)
        label.delete(sgItem.bloom)

    if not na(sgItem.halo)
        label.delete(sgItem.halo)

    if not na(sgItem.core)
        label.delete(sgItem.core)

    if not na(sgItem.badge)
        label.delete(sgItem.badge)

    if not na(sgItem.shell)
        if sgItem.sigKind == SG_KIND_ARMED
            label.set_textcolor(sgItem.shell, color.new(sgItem.tone, sgRingT))
        else
            label.set_color(sgItem.shell, color.new(sgItem.tone, sgRingT))

    if not na(sgItem.tether) and not (afterhoursStyle and sgItem.sigKind == SG_KIND_ARMED)
        line.set_color(sgItem.tether, color.new(sgItem.tone, 78))

    if not na(sgItem.leader)
        line.set_color(sgItem.leader, color.new(sgItem.tone, 70))

    if not na(sgItem.caption)
        label.set_textcolor(sgItem.caption, color.new(sgItem.tone, sgTextT))

    true

// COIL zone: the engine's matured wedge, drawn as a neon amber compression
// channel in the same Neon Glass style as the live corridor: glowing edges,
// fill brightest at the edges and fading to clear at the center line.
// It is drawn once, on the bar COIL fires, from the wedge start using pivots
// that were already confirmed on that bar; after that it only extends forward
// and never changes shape. It ends when a candle closes outside it, at
// LONG / SHORT, where its edges meet, or after SG_ZONE_MAX_BARS, then settles
// one step dimmer (COIL tick and label removed). A newer zone replaces any
// older zone it overlaps. Visual only: it reads the wedge, never writes to it.
const int SG_ZONE_MAX_BARS = 40
const int SG_ZONE_KEEP = 12
const float SG_ZONE_INNER = 0.2

color sgZoneAmber = color.rgb(255, 214, 48)

type SgCoilZone
    int coilBar
    float side
    int uX1
    float uY1
    int uX2
    float uY2
    int lX1
    float lY1
    int lX2
    float lY2
    line upper
    line lower
    line mid
    line upperInner
    line lowerInner
    line upperGlow
    line lowerGlow
    linefill upperEdge
    linefill upperCore
    linefill lowerCore
    linefill lowerEdge
    line tick
    label caption
    bool live

var array<SgCoilZone> sgZones = array.new<SgCoilZone>()

f_sgZoneUp(SgCoilZone sgZone, int sgX) =>
    f_project(sgZone.uX1, sgZone.uY1, sgZone.uX2, sgZone.uY2, sgX)

f_sgZoneLo(SgCoilZone sgZone, int sgX) =>
    f_project(sgZone.lX1, sgZone.lY1, sgZone.lX2, sgZone.lY2, sgX)

f_sgZoneLine(int sgX1, float sgY1, int sgX2, float sgY2, color sgColor, int sgWidth, string sgStyle) =>
    line.new(sgX1, sgY1, sgX2, sgY2, xloc=xloc.bar_index, extend=extend.none, color=sgColor, style=sgStyle, width=sgWidth)

// Glass colors: live = full glow; settled = one step dimmer, still readable.
f_sgZoneColors(SgCoilZone sgZone, bool sgLive) =>
    line.set_color(sgZone.upper, color.new(sgZoneAmber, sgLive ? 10 : 58))
    line.set_color(sgZone.lower, color.new(sgZoneAmber, sgLive ? 10 : 58))
    line.set_color(sgZone.mid, color.new(sgZoneAmber, sgLive ? 70 : 90))
    line.set_color(sgZone.upperGlow, color.new(sgZoneAmber, sgLive ? 78 : 93))
    line.set_color(sgZone.lowerGlow, color.new(sgZoneAmber, sgLive ? 78 : 93))
    linefill.set_color(sgZone.upperEdge, color.new(sgZoneAmber, sgLive ? 66 : 87))
    linefill.set_color(sgZone.upperCore, color.new(sgZoneAmber, sgLive ? 88 : 97))
    linefill.set_color(sgZone.lowerCore, color.new(sgZoneAmber, sgLive ? 88 : 97))
    linefill.set_color(sgZone.lowerEdge, color.new(sgZoneAmber, sgLive ? 66 : 87))
    true

// Extend every line of the zone (and its label) to bar sgX.
f_sgZoneExtend(SgCoilZone sgZone, int sgX) =>
    float sgUp = f_sgZoneUp(sgZone, sgX)
    float sgLo = f_sgZoneLo(sgZone, sgX)
    float sgSpan = sgUp - sgLo
    line.set_xy2(sgZone.upper, sgX, sgUp)
    line.set_xy2(sgZone.lower, sgX, sgLo)
    line.set_xy2(sgZone.mid, sgX, (sgUp + sgLo) / 2.0)
    line.set_xy2(sgZone.upperInner, sgX, sgUp - sgSpan * SG_ZONE_INNER)
    line.set_xy2(sgZone.lowerInner, sgX, sgLo + sgSpan * SG_ZONE_INNER)
    line.set_xy2(sgZone.upperGlow, sgX, sgUp)
    line.set_xy2(sgZone.lowerGlow, sgX, sgLo)

    if not na(sgZone.caption)
        label.set_xy(sgZone.caption, sgX + 1, (sgUp + sgLo) / 2.0)

    true

// Settle: COIL tick and label removed; the glass stays, one step dimmer.
f_sgZoneSettle(SgCoilZone sgZone) =>
    sgZone.live := false
    line.delete(sgZone.tick)
    label.delete(sgZone.caption)
    sgZone.tick := na
    sgZone.caption := na
    f_sgZoneColors(sgZone, false)
    true

f_sgZoneDelete(SgCoilZone sgZone) =>
    linefill.delete(sgZone.upperEdge)
    linefill.delete(sgZone.upperCore)
    linefill.delete(sgZone.lowerCore)
    linefill.delete(sgZone.lowerEdge)
    line.delete(sgZone.upper)
    line.delete(sgZone.lower)
    line.delete(sgZone.mid)
    line.delete(sgZone.upperInner)
    line.delete(sgZone.lowerInner)
    line.delete(sgZone.upperGlow)
    line.delete(sgZone.lowerGlow)
    line.delete(sgZone.tick)
    label.delete(sgZone.caption)
    true

if signatureSignals and chart.is_standard
    // 1. Settle signals older than the glow window, in place.
    bool sgScan = sgLive.size() > 0

    while sgScan
        SgSignal sgOldest = sgLive.first()

        if bar_index - sgOldest.sigBar > glowDurationBars
            sgLive.shift()

            if fadeOlderSignals
                f_sgSettle(sgOldest)

            sgSettled.push(sgOldest)
            sgScan := sgLive.size() > 0
        else
            sgScan := false

    // Keep tether/callout lines only on the most recent settled signals so
    // the chart's line budget never crowds out the corridor.
    while sgSettled.size() > SG_MAX_LINED
        f_sgDropLines(sgSettled.shift())

    // 2. Display priority: a higher-priority event
    //    removes a lower-priority orb drawn on this bar or the previous one.
    if primarySignalEvent or showMagicVisual or showStructureVisual
        int sgIndex = sgLive.size() - 1

        while sgIndex >= 0
            SgSignal sgItem = sgLive.get(sgIndex)

            bool sgOutranked = (
                primarySignalEvent ?
                    sgItem.sigKind == SG_KIND_ARMED or sgItem.sigKind == SG_KIND_SIG9 :
                    sgItem.sigKind == SG_KIND_ARMED
            )

            if sgOutranked and bar_index - sgItem.sigBar <= 1
                f_sgDelete(sgItem)
                sgLive.remove(sgIndex)

            sgIndex -= 1

    // 3. Draw this bar's signals. Distances are in spacing units (see top).
    string sgPriceText = str.tostring(close, format.mintick)

    string sgEffText = (
        na(pathEfficiency) ?
            "--" :
            str.tostring(pathEfficiency, "0.00")
    )

    bool sgStrongLong = fullSignalDisplay and strongLong4hEvent
    bool sgStrongShort = fullSignalDisplay and strongShort4hEvent

    string sgEntryBloom = f_sgPick("", size.large, size.huge)
    string sgEntryHalo = f_sgPick(size.small, size.normal, size.large)
    string sgEntryShell = f_sgPick(size.tiny, size.small, size.normal)
    string sgEntryGap = f_sgPick("", size.tiny, size.small)
    string sgEntryCore = f_sgPick("", "", size.tiny)
    float sgEntryOrb = f_sgPickF(5.0, 6.0, 7.5)
    float sgEntryCaption = f_sgPickF(5.0, 5.5, 7.0)

    if longSignal
        f_sgCreate(
            SG_KIND_ENTRY,
            -1.0,
            sgLongTone,
            sgLongCore,
            sgEntryBloom,
            sgEntryHalo,
            sgEntryShell,
            sgEntryGap,
            sgEntryCore,
            "",
            0,
            45,
            sgEntryOrb,
            sgEntryCaption,
            sgStrongLong ? "LONG+" : "LONG",
            0,
            sgStrongLong,
            "LONG · " + sgPriceText + (sgStrongLong ? " · 4H power confirmed" : "") + " · efficiency " + sgEffText
        )

    if shortSignal
        f_sgCreate(
            SG_KIND_ENTRY,
            1.0,
            sgShortTone,
            sgShortCore,
            sgEntryBloom,
            sgEntryHalo,
            sgEntryShell,
            sgEntryGap,
            sgEntryCore,
            "",
            0,
            45,
            sgEntryOrb,
            sgEntryCaption,
            sgStrongShort ? "SHORT+" : "SHORT",
            0,
            sgStrongShort,
            "SHORT · " + sgPriceText + (sgStrongShort ? " · 4H power confirmed" : "") + " · efficiency " + sgEffText
        )

    if sgStrongLong and not longSignal
        f_sgCreate(
            SG_KIND_STRONG,
            -1.0,
            sgLongTone,
            sgLongCore,
            sgEntryBloom,
            sgEntryHalo,
            sgEntryShell,
            sgEntryGap,
            sgEntryCore,
            "",
            0,
            45,
            sgEntryOrb,
            sgEntryCaption,
            "LONG+",
            0,
            true,
            "STRONG LONG · confirmed 4H power · " + sgPriceText
        )

    if sgStrongShort and not shortSignal
        f_sgCreate(
            SG_KIND_STRONG,
            1.0,
            sgShortTone,
            sgShortCore,
            sgEntryBloom,
            sgEntryHalo,
            sgEntryShell,
            sgEntryGap,
            sgEntryCore,
            "",
            0,
            45,
            sgEntryOrb,
            sgEntryCaption,
            "SHORT+",
            0,
            true,
            "STRONG SHORT · confirmed 4H power · " + sgPriceText
        )

    if fullSignalDisplay and showMagicVisual
        f_sgCreate(
            SG_KIND_SIG9,
            1.0,
            sgSig9Tone,
            color.rgb(245, 253, 255),
            "",
            f_sgPick("", size.normal, size.large),
            f_sgPick(size.tiny, size.small, size.normal),
            f_sgPick("", size.tiny, size.small),
            "",
            "",
            0,
            50,
            f_sgPickF(5.0, 6.0, 7.5),
            f_sgPickF(4.5, 5.0, 6.0),
            "SIG9",
            0,
            false,
            "MAGIC SIG9 · cup break / expansion · " + sgPriceText
        )

    // 4. COIL zone: extend the live zone, or end it and let it settle.
    if sgZones.size() > 0
        SgCoilZone sgLiveZone = sgZones.last()

        if sgLiveZone.live and bar_index > sgLiveZone.coilBar
            float sgZoneUp = f_sgZoneUp(sgLiveZone, bar_index)
            float sgZoneLo = f_sgZoneLo(sgLiveZone, bar_index)

            if sgZoneUp - sgZoneLo <= 0.0
                f_sgZoneSettle(sgLiveZone)
            else if close > sgZoneUp or close < sgZoneLo
                // The edges end on the candle that closed outside the zone.
                f_sgZoneExtend(sgLiveZone, bar_index)
                f_sgZoneSettle(sgLiveZone)
            else if primarySignalEvent or bar_index - sgLiveZone.coilBar >= SG_ZONE_MAX_BARS
                f_sgZoneExtend(sgLiveZone, bar_index)
                f_sgZoneSettle(sgLiveZone)
            else
                f_sgZoneExtend(sgLiveZone, bar_index)

    // 5. New COIL: draw its zone. It replaces any older zone it overlaps in
    //    time (including a live one), so zones never stack in choppy markets.
    if fullSignalDisplay and showArmedVisual and showCoilZones and not na(wedgeStartBar)
        float sgZoneSide = bullishArmedEvent ? 1.0 : -1.0

        int sgOldIndex = sgZones.size() - 1

        while sgOldIndex >= 0
            SgCoilZone sgOldZone = sgZones.get(sgOldIndex)

            if line.get_x2(sgOldZone.upper) >= wedgeStartBar
                f_sgZoneDelete(sgOldZone)
                sgZones.remove(sgOldIndex)

            sgOldIndex -= 1

        SgCoilZone sgNewZone = SgCoilZone.new(
            coilBar=bar_index,
            side=sgZoneSide,
            uX1=ph2Bar,
            uY1=ph2,
            uX2=ph1Bar,
            uY2=ph1,
            lX1=pl2Bar,
            lY1=pl2,
            lX2=pl1Bar,
            lY2=pl1,
            live=true
        )

        int sgZoneStart = wedgeStartBar
        float sgUpStart = f_sgZoneUp(sgNewZone, sgZoneStart)
        float sgLoStart = f_sgZoneLo(sgNewZone, sgZoneStart)
        float sgUpNow = f_sgZoneUp(sgNewZone, bar_index)
        float sgLoNow = f_sgZoneLo(sgNewZone, bar_index)

        float sgSpanStart = sgUpStart - sgLoStart
        float sgSpanNow = sgUpNow - sgLoNow
        color sgClear = color.new(sgZoneAmber, 100)

        // Glow lines first so the crisp edges draw on top of them.
        sgNewZone.upperGlow := f_sgZoneLine(sgZoneStart, sgUpStart, bar_index, sgUpNow, sgClear, 6, line.style_solid)
        sgNewZone.lowerGlow := f_sgZoneLine(sgZoneStart, sgLoStart, bar_index, sgLoNow, sgClear, 6, line.style_solid)
        sgNewZone.upper := f_sgZoneLine(sgZoneStart, sgUpStart, bar_index, sgUpNow, sgClear, 1, line.style_solid)
        sgNewZone.lower := f_sgZoneLine(sgZoneStart, sgLoStart, bar_index, sgLoNow, sgClear, 1, line.style_solid)
        sgNewZone.mid := f_sgZoneLine(sgZoneStart, (sgUpStart + sgLoStart) / 2.0, bar_index, (sgUpNow + sgLoNow) / 2.0, sgClear, 1, line.style_dotted)
        sgNewZone.upperInner := f_sgZoneLine(sgZoneStart, sgUpStart - sgSpanStart * SG_ZONE_INNER, bar_index, sgUpNow - sgSpanNow * SG_ZONE_INNER, sgClear, 1, line.style_solid)
        sgNewZone.lowerInner := f_sgZoneLine(sgZoneStart, sgLoStart + sgSpanStart * SG_ZONE_INNER, bar_index, sgLoNow + sgSpanNow * SG_ZONE_INNER, sgClear, 1, line.style_solid)
        sgNewZone.upperEdge := linefill.new(sgNewZone.upper, sgNewZone.upperInner, sgClear)
        sgNewZone.upperCore := linefill.new(sgNewZone.upperInner, sgNewZone.mid, sgClear)
        sgNewZone.lowerCore := linefill.new(sgNewZone.mid, sgNewZone.lowerInner, sgClear)
        sgNewZone.lowerEdge := linefill.new(sgNewZone.lowerInner, sgNewZone.lower, sgClear)
        sgNewZone.tick := f_sgZoneLine(bar_index, sgLoNow, bar_index, sgUpNow, color.new(sgZoneAmber, 30), 1, line.style_dashed)
        f_sgZoneColors(sgNewZone, true)

        sgNewZone.caption := label.new(
            bar_index + 1,
            (sgUpNow + sgLoNow) / 2.0,
            "COIL",
            xloc=xloc.bar_index,
            yloc=yloc.price,
            style=label.style_label_left,
            color=color.new(sgPillDark, 15),
            textcolor=sgZoneAmber,
            size=size.small,
            tooltip=(
                bullishArmedEvent ?
                    "COIL ▲ · compression zone · falling wedge matured (bias: higher) · watching for LONG" :
                    "COIL ▼ · compression zone · rising wedge matured (bias: lower)"
            )
        )

        sgZones.push(sgNewZone)

        if sgZones.size() > SG_ZONE_KEEP
            f_sgZoneDelete(sgZones.shift())

// -----------------------------------------------------------------------------
// Glowing live corridor edges
// -----------------------------------------------------------------------------
//
// A wide, faint line under each edge of the live corridor leg gives the neon
// glow. Only the live leg glows; prior legs stay dim.

var line aaqGlowUpper = na
var line aaqGlowLower = na
var int aaqGlowStart = na

if quantifiedStyle and aaShowCorridors and not na(aaCurrentUpper) and aaStructureReady
    if na(aaqGlowStart) or aaqGlowStart != aaCurrentStartBar
        if not na(aaqGlowUpper)
            line.delete(aaqGlowUpper)

        if not na(aaqGlowLower)
            line.delete(aaqGlowLower)

        aaqGlowUpper := line.new(
            x1=aaCurrentStartBar,
            y1=aaCurrentStartUpper,
            x2=bar_index,
            y2=structureUpper,
            xloc=xloc.bar_index,
            extend=extend.none,
            color=color.new(f_aaStateColor(aaCurrentState), 82),
            width=6
        )

        aaqGlowLower := line.new(
            x1=aaCurrentStartBar,
            y1=aaCurrentStartLower,
            x2=bar_index,
            y2=structureLower,
            xloc=xloc.bar_index,
            extend=extend.none,
            color=color.new(f_aaStateColor(aaCurrentState), 82),
            width=6
        )

        aaqGlowStart := aaCurrentStartBar

    color aaqGlowColor = (
        aaEntryPulseActive ?
            (aaEntryPulseDirection == 1 ? aaBull : aaBear) :
            f_aaStateColor(aaCurrentState)
    )

    line.set_xy2(aaqGlowUpper, bar_index, structureUpper)
    line.set_xy2(aaqGlowLower, bar_index, structureLower)
    line.set_color(aaqGlowUpper, color.new(aaqGlowColor, aaEntryPulseActive ? 70 : 82))
    line.set_color(aaqGlowLower, color.new(aaqGlowColor, aaEntryPulseActive ? 70 : 82))

// -----------------------------------------------------------------------------
// Neon Glass corridor fill (Corridor Fill = Neon Glass)
// -----------------------------------------------------------------------------
//
// The live leg is filled in four bands: bright neon at both edges, fading to
// near-clear at the center line, like light through a glass tube. Brightness
// still follows flow efficiency (clean > mixed > choppy) and flares on
// LONG/SHORT. Prior legs keep a light single-tone fill.

var line aaqGlassUpperInner = na
var line aaqGlassLowerInner = na
var linefill aaqGlassUpperEdge = na
var linefill aaqGlassUpperCore = na
var linefill aaqGlassLowerCore = na
var linefill aaqGlassLowerEdge = na
var int aaqGlassStart = na

if corridorGlass and aaShowCorridors and not na(aaCurrentUpper) and aaStructureReady
    float aaqUpperInnerNow = structureUpper - (structureUpper - structureKama) * 0.4
    float aaqLowerInnerNow = structureLower + (structureKama - structureLower) * 0.4

    if na(aaqGlassStart) or aaqGlassStart != aaCurrentStartBar
        if not na(aaqGlassUpperEdge)
            linefill.delete(aaqGlassUpperEdge)

        if not na(aaqGlassUpperCore)
            linefill.delete(aaqGlassUpperCore)

        if not na(aaqGlassLowerCore)
            linefill.delete(aaqGlassLowerCore)

        if not na(aaqGlassLowerEdge)
            linefill.delete(aaqGlassLowerEdge)

        if not na(aaqGlassUpperInner)
            line.delete(aaqGlassUpperInner)

        if not na(aaqGlassLowerInner)
            line.delete(aaqGlassLowerInner)

        aaqGlassUpperInner := line.new(
            x1=aaCurrentStartBar,
            y1=aaCurrentStartUpper - (aaCurrentStartUpper - aaCurrentStartMid) * 0.4,
            x2=bar_index,
            y2=aaqUpperInnerNow,
            xloc=xloc.bar_index,
            extend=extend.none,
            color=color.new(color.white, 100),
            width=1
        )

        aaqGlassLowerInner := line.new(
            x1=aaCurrentStartBar,
            y1=aaCurrentStartLower + (aaCurrentStartMid - aaCurrentStartLower) * 0.4,
            x2=bar_index,
            y2=aaqLowerInnerNow,
            xloc=xloc.bar_index,
            extend=extend.none,
            color=color.new(color.white, 100),
            width=1
        )

        aaqGlassUpperEdge := linefill.new(aaCurrentUpper, aaqGlassUpperInner, color.new(color.white, 100))
        aaqGlassUpperCore := linefill.new(aaqGlassUpperInner, aaCurrentMid, color.new(color.white, 100))
        aaqGlassLowerCore := linefill.new(aaCurrentMid, aaqGlassLowerInner, color.new(color.white, 100))
        aaqGlassLowerEdge := linefill.new(aaqGlassLowerInner, aaCurrentLower, color.new(color.white, 100))

        aaqGlassStart := aaCurrentStartBar

    line.set_xy2(aaqGlassUpperInner, bar_index, aaqUpperInnerNow)
    line.set_xy2(aaqGlassLowerInner, bar_index, aaqLowerInnerNow)

    color aaqGlassColor = (
        aaEntryPulseActive ?
            (aaEntryPulseDirection == 1 ? aaBull : aaBear) :
            f_aaStateColor(aaCurrentState)
    )

    int aaqEdgeT = (
        aaEntryPulseActive ?
            52 :
            na(pathEfficiency) ?
                74 :
                pathEfficiency >= EFFICIENCY_HIGH ?
                    60 :
                    pathEfficiency <= EFFICIENCY_LOW ?
                        82 :
                        72
    )

    int aaqCoreT = math.min(aaqEdgeT + 20, 97)

    linefill.set_color(aaqGlassUpperEdge, color.new(aaqGlassColor, aaqEdgeT))
    linefill.set_color(aaqGlassUpperCore, color.new(aaqGlassColor, aaqCoreT))
    linefill.set_color(aaqGlassLowerCore, color.new(aaqGlassColor, aaqCoreT))
    linefill.set_color(aaqGlassLowerEdge, color.new(aaqGlassColor, aaqEdgeT))

// -----------------------------------------------------------------------------
// Agent dashboard, title badge and footer
// -----------------------------------------------------------------------------

var int aaqLastBar = na
var string aaqLastKind = ""
var float aaqLastPrice = na
var int aaqCoilDir = 0

if longSignal
    aaqLastBar := bar_index
    aaqLastKind := "LONG"
    aaqLastPrice := close

else if shortSignal
    aaqLastBar := bar_index
    aaqLastKind := "SHORT"
    aaqLastPrice := close

if bullishArmedEvent
    aaqCoilDir := 1

else if bearishArmedEvent
    aaqCoilDir := -1

color aaqMuted = color.rgb(150, 160, 175)

// Agent HUD branding. Alpha-Glow = cyan / magenta brand; Terminal = cyan / blue.
// Values keep their meaning colors in both (BULL green, BEAR red, CHOPPY amber...).
color aaqBrandTeal = color.rgb(0, 229, 210)
color aaqBrandA = afterhoursStyle ? color.rgb(0, 229, 255) : aaCyan
color aaqBrandB = afterhoursStyle ? color.rgb(255, 46, 200) : color.rgb(90, 140, 255)
color aaqSubtle = afterhoursStyle ? aaqBrandTeal : aaIce
color aaqHudBg = color.rgb(5, 8, 16)
color aaqHudBgAlt = color.rgb(11, 16, 32)
color aaqHudKey = color.rgb(100, 116, 139)
color aaqConfirmed = color.rgb(46, 255, 160)
const int AAQ_GLASS = 28

// Non-standard charts (Heikin Ashi, Renko, Kagi, P&F, line break, range) use
// synthetic prices, so signals, COIL zones, corridors and the HUD are not drawn
// there. Only this notice is shown.
var table aaqChartNotice = na

if barstate.islast and not chart.is_standard
    if na(aaqChartNotice)
        aaqChartNotice := table.new(position.middle_center, 1, 1, frame_color=color.new(aaqBrandA, 40), frame_width=1)
    table.cell(
        aaqChartNotice,
        0,
        0,
        "Escape Velocity runs on standard candles only.\nSignals, zones and panels are hidden on Heikin Ashi, Renko and similar charts.",
        text_color=aaIce,
        bgcolor=color.new(aaqHudBg, 3),
        text_size=size.normal,
        text_font_family=font.family_monospace
    )

// Agent HUD: frameless glass. Gloss rules top and bottom, a brand light bar on
// the left, rows fading into the chart toward the bottom. Values carry their
// meaning as text color only, so the panel never flashes.
// Columns: 0 light bar | 1 key | 2-4 value.
var table aaqHud = table.new(aaCardPosition, 5, 9, frame_width=0, border_width=0)
var table aaqTitle = table.new(position.top_center, 3, 3, frame_width=0, border_width=0)

var table aaqFooter = table.new(
    position.bottom_center,
    1,
    1
)

f_aaqGlass(int aaqRow) =>
    color.new(aaqHudBg, math.min(96, AAQ_GLASS + aaqRow * 3))

f_aaqKeyGlass(int aaqRow) =>
    color.new(aaqHudBgAlt, math.min(96, AAQ_GLASS + aaqRow * 3))

f_aaqRule(table aaqTable, int aaqRow, int aaqCols, int aaqT) =>
    for aaqCol = 0 to aaqCols - 1
        table.cell(aaqTable, aaqCol, aaqRow, "", height=0.3, bgcolor=color.new(color.from_gradient(aaqCol, 0, aaqCols - 1, aaqBrandA, aaqBrandB), aaqT))

    true

f_aaqBar(int aaqRow) =>
    table.cell(aaqHud, 0, aaqRow, "", width=0.25, bgcolor=color.new(aaqBrandA, math.min(90, 55 + aaqRow * 4)))
    true

f_aaqCell(int aaqCol, int aaqRow, string aaqText, color aaqFg, color aaqBg, string aaqSize, string aaqAlign, string aaqTip) =>
    table.cell(aaqHud, aaqCol, aaqRow, aaqText, text_color=aaqFg, bgcolor=aaqBg, text_size=aaqSize, text_halign=aaqAlign, text_font_family=font.family_monospace, tooltip=aaqTip)
    true

f_aaqRow(int aaqRow, string aaqKey, string aaqValue, color aaqColor, string aaqTip) =>
    f_aaqBar(aaqRow)
    f_aaqCell(1, aaqRow, aaqKey, aaqHudKey, f_aaqKeyGlass(aaqRow), size.small, text.align_left, "")
    f_aaqCell(2, aaqRow, aaqValue, aaqColor, color.new(aaqColor, 88), size.small, text.align_left, aaqTip)
    true

if barstate.islast and showStatusChip and chart.is_standard
    int aaqBlocks = na(pathEfficiency) ? 0 : math.round(pathEfficiency * 10.0)
    string aaqMeter = str.repeat("▰", aaqBlocks) + str.repeat("▱", 10 - aaqBlocks)
    string aaqEffText = na(pathEfficiency) ? "--" : str.tostring(pathEfficiency, "0.00")

    string aaqState = (
        aaStateText == "ARMED" ?
            (aaqCoilDir == -1 ? "COILED ▼" : "COILED ▲") :
            aaStateText
    )

    color aaqStateColor = aaStateText == "MONITOR" ? aaqMuted : aaStateColor

    string aaqLast = (
        na(aaqLastBar) ?
            "--" :
            aaqLastKind + " · " + str.tostring(bar_index - aaqLastBar) + " bars · " + str.tostring(aaqLastPrice, format.mintick)
    )

    color aaqLastColor = aaqLastKind == "LONG" ? sgLongTone : aaqLastKind == "SHORT" ? sgShortTone : aaqMuted
    string aaqHeadTip = "Escape Velocity: Gravity & Coil Signals · Alpha Agent by Einstein's Unified"

    // Row 0: gloss rule
    f_aaqRule(aaqHud, 0, 5, 25)

    // Row 1: brand band + confirmation chip
    f_aaqBar(1)
    // One title line: brand on the left, product name across the middle.
    f_aaqCell(1, 1, afterhoursStyle ? "ALPHA AGENT" : "ESC VEL", afterhoursStyle ? aaqBrandB : aaqBrandA, f_aaqGlass(1), size.small, text.align_left, aaqHeadTip)
    f_aaqCell(2, 1, afterhoursStyle ? "ESC VEL" : "AGENT HUD", afterhoursStyle ? aaqBrandA : aaqBrandB, f_aaqGlass(1), size.small, text.align_left, aaqHeadTip)
    f_aaqCell(4, 1, "● CONFIRMED", aaqConfirmed, color.new(aaqConfirmed, 90), size.tiny, text.align_center, "Every signal prints on a closed bar. STRONG uses the last completed 4H bar.")

    // Rows 2-6: state and read-outs
    f_aaqRow(2, "STATE", aaqState, aaqStateColor, "Current agent state. COILED = a COIL compression zone is active.")
    f_aaqRow(3, "REGIME", aaStructureText, aaStructureColor, "Structure regime of the live adaptive corridor.")
    f_aaqRow(4, "FLOW", aaFlowQuality, aaFlowColor, "Flow quality of the live leg (path efficiency).")
    f_aaqBar(5)
    f_aaqCell(1, 5, "EFFICIENCY", aaqHudKey, f_aaqKeyGlass(5), size.small, text.align_left, "")
    f_aaqCell(2, 5, aaqMeter, color.from_gradient(nz(pathEfficiency), 0.0, 1.0, aaqHudKey, aaqBrandA), f_aaqGlass(5), size.small, text.align_left, "Path efficiency of the live leg, 0 to 1.")
    f_aaqCell(4, 5, aaqEffText, aaIce, f_aaqGlass(5), size.small, text.align_center, "Path efficiency of the live leg, 0 to 1.")
    f_aaqRow(6, "LAST", aaqLast, aaqLastColor, "Most recent LONG / SHORT: bars since and price.")

    // Row 7: signature line
    f_aaqBar(7)
    f_aaqCell(1, 7, afterhoursStyle ? "— by Einstein's Unified —" : "— quantitative analytics —", color.new(aaqBrandA, 45), f_aaqGlass(7), size.tiny, text.align_center, "")

    // Row 8: lower gloss rule, fainter so the panel dissolves into the chart
    f_aaqRule(aaqHud, 8, 5, 60)

    table.merge_cells(aaqHud, 2, 1, 3, 1)
    table.merge_cells(aaqHud, 2, 2, 4, 2)
    table.merge_cells(aaqHud, 2, 3, 4, 3)
    table.merge_cells(aaqHud, 2, 4, 4, 4)
    table.merge_cells(aaqHud, 2, 5, 3, 5)
    table.merge_cells(aaqHud, 2, 6, 4, 6)
    table.merge_cells(aaqHud, 1, 7, 4, 7)

    // Title badge in the same glass language
    f_aaqRule(aaqTitle, 0, 3, 25)
    table.cell(
        aaqTitle,
        0,
        1,
        afterhoursStyle ? "ALPHA-GLOW" : "ESCAPE VELOCITY · TERMINAL",
        text_color=afterhoursStyle ? aaqBrandB : aaIce,
        bgcolor=f_aaqGlass(1),
        text_size=size.small,
        text_font_family=font.family_monospace
    )
    f_aaqRule(aaqTitle, 2, 3, 60)
    table.merge_cells(aaqTitle, 0, 1, 2, 1)

    table.cell(
        aaqFooter,
        0,
        0,
        "ALPHA AGENT by Einstein's Unified · " + str.format_time(time, "MMM dd, yyyy", syminfo.timezone),
        text_color=color.new(aaqSubtle, 45),
        text_size=size.tiny,
        text_font_family=font.family_monospace
    )

// -----------------------------------------------------------------------------
// Cross-symbol distance engine
// -----------------------------------------------------------------------------
//
// The default 150/200/300/400/50 cash geometry corresponds to:
// stop = 1.00R
// TP1  = 1.333R
// TP2  = 2.000R
// TP3  = 2.667R
// lock = 0.333R
//
// Auto ATR mode preserves those ratios while scaling to each symbol/timeframe.
// Manual mode uses the entered stop distance and the same ratios.

float managementAtr = ta.atr(distanceAtrLength)
bool fixedDollarMode = distanceMode == "Fixed Dollar"

float atrStopDistance = f_roundDistance(
    managementAtr * stopAtrMultiplier
)

float liveStopDistance = (
    fixedDollarMode ?
        f_roundDistance(f_cashDistance(scalpStopCash)) :
        atrStopDistance
)

float liveTp1Distance = (
    fixedDollarMode ?
        f_roundDistance(f_cashDistance(scalpTp1Cash)) :
        f_roundDistance(atrStopDistance * (4.0 / 3.0))
)

float liveTp2Distance = (
    fixedDollarMode ?
        f_roundDistance(f_cashDistance(scalpTp2Cash)) :
        f_roundDistance(atrStopDistance * 2.0)
)

float liveTp3Distance = (
    fixedDollarMode ?
        f_roundDistance(f_cashDistance(scalpTp3Cash)) :
        f_roundDistance(atrStopDistance * (8.0 / 3.0))
)

float liveLockDistance = (
    fixedDollarMode ?
        f_roundDistance(f_cashDistance(scalpLockCash)) :
        f_roundDistance(atrStopDistance * (1.0 / 3.0))
)

// -----------------------------------------------------------------------------
// Active scalp manager
// -----------------------------------------------------------------------------

var int tradeDirection = 0
var int tradeEntryBar = na
var int tradeTp1Bar = na

var float tradeEntry = na
var float tradeInitialStop = na
var float tradeLockStop = na
var float tradeTp1 = na
var float tradeTp2 = na
var float tradeTp3 = na

var float tradeStopDistance = na
var float tradeLockDistance = na
var float tradeTp1Distance = na
var float tradeTp2Distance = na
var float tradeTp3Distance = na

var bool tradeTp1Hit = false
var bool tradeTp2Hit = false

var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

var label entryLevelLabel = na
var label stopLevelLabel = na
var label tp1LevelLabel = na
var label tp2LevelLabel = na
var label tp3LevelLabel = na

bool tradeEntryLongEvent = false
bool tradeEntryShortEvent = false
bool tradeTp1Event = false
bool tradeTp2Event = false
bool tradeTp3Event = false
bool tradeStopEvent = false
bool tradeTimeoutEvent = false
bool lockActivatedEvent = false

bool tradeFlat = (
    tradeDirection == 0
)

if tradeFlat and barstate.isconfirmed and chart.is_standard
    if longSignal
        tradeDirection := 1
        tradeEntryBar := bar_index
        tradeTp1Bar := na
        tradeEntry := close

        tradeStopDistance := liveStopDistance
        tradeLockDistance := liveLockDistance
        tradeTp1Distance := liveTp1Distance
        tradeTp2Distance := liveTp2Distance
        tradeTp3Distance := liveTp3Distance

        tradeInitialStop := (
            tradeEntry -
            tradeStopDistance
        )

        tradeLockStop := (
            tradeEntry +
            tradeLockDistance
        )

        tradeTp1 := (
            tradeEntry +
            tradeTp1Distance
        )

        tradeTp2 := (
            tradeEntry +
            tradeTp2Distance
        )

        tradeTp3 := (
            tradeEntry +
            tradeTp3Distance
        )

        tradeTp1Hit := false
        tradeTp2Hit := false
        tradeEntryLongEvent := true

        entryLine := line.new(
            bar_index,
            tradeEntry,
            bar_index + 1,
            tradeEntry,
            extend=extend.right,
            color=color.new(color.white, 35),
            width=1
        )

        stopLine := line.new(
            bar_index,
            tradeInitialStop,
            bar_index + 1,
            tradeInitialStop,
            extend=extend.right,
            color=color.red,
            width=2
        )

        tp1Line := line.new(
            bar_index,
            tradeTp1,
            bar_index + 1,
            tradeTp1,
            extend=extend.right,
            color=color.new(color.lime, 30),
            width=1
        )

        tp2Line := line.new(
            bar_index,
            tradeTp2,
            bar_index + 1,
            tradeTp2,
            extend=extend.right,
            color=color.new(color.lime, 15),
            width=1
        )

        tp3Line := line.new(
            bar_index,
            tradeTp3,
            bar_index + 1,
            tradeTp3,
            extend=extend.right,
            color=color.lime,
            width=2
        )

        entryLevelLabel := label.new(
            bar_index + 1,
            tradeEntry,
            "ENTRY",
            style=label.style_label_left,
            color=color.new(color.gray, 40),
            textcolor=color.white,
            size=size.tiny
        )

        stopLevelLabel := label.new(
            bar_index + 1,
            tradeInitialStop,
            "SL -" + f_managementText(tradeStopDistance, scalpStopCash, fixedDollarMode),
            style=label.style_label_left,
            color=color.red,
            textcolor=color.white,
            size=size.tiny
        )

        tp1LevelLabel := label.new(
            bar_index + 1,
            tradeTp1,
            "TP1 +" + f_managementText(tradeTp1Distance, scalpTp1Cash, fixedDollarMode),
            style=label.style_label_left,
            color=color.new(color.lime, 30),
            textcolor=color.black,
            size=size.tiny
        )

        tp2LevelLabel := label.new(
            bar_index + 1,
            tradeTp2,
            "TP2 +" + f_managementText(tradeTp2Distance, scalpTp2Cash, fixedDollarMode),
            style=label.style_label_left,
            color=color.new(color.lime, 15),
            textcolor=color.black,
            size=size.tiny
        )

        tp3LevelLabel := label.new(
            bar_index + 1,
            tradeTp3,
            "TP3 +" + f_managementText(tradeTp3Distance, scalpTp3Cash, fixedDollarMode),
            style=label.style_label_left,
            color=color.lime,
            textcolor=color.black,
            size=size.tiny
        )

    else if shortSignal
        tradeDirection := -1
        tradeEntryBar := bar_index
        tradeTp1Bar := na
        tradeEntry := close

        tradeStopDistance := liveStopDistance
        tradeLockDistance := liveLockDistance
        tradeTp1Distance := liveTp1Distance
        tradeTp2Distance := liveTp2Distance
        tradeTp3Distance := liveTp3Distance

        tradeInitialStop := (
            tradeEntry +
            tradeStopDistance
        )

        tradeLockStop := (
            tradeEntry -
            tradeLockDistance
        )

        tradeTp1 := (
            tradeEntry -
            tradeTp1Distance
        )

        tradeTp2 := (
            tradeEntry -
            tradeTp2Distance
        )

        tradeTp3 := (
            tradeEntry -
            tradeTp3Distance
        )

        tradeTp1Hit := false
        tradeTp2Hit := false
        tradeEntryShortEvent := true

        entryLine := line.new(
            bar_index,
            tradeEntry,
            bar_index + 1,
            tradeEntry,
            extend=extend.right,
            color=color.new(color.white, 35),
            width=1
        )

        stopLine := line.new(
            bar_index,
            tradeInitialStop,
            bar_index + 1,
            tradeInitialStop,
            extend=extend.right,
            color=color.red,
            width=2
        )

        tp1Line := line.new(
            bar_index,
            tradeTp1,
            bar_index + 1,
            tradeTp1,
            extend=extend.right,
            color=color.new(color.lime, 30),
            width=1
        )

        tp2Line := line.new(
            bar_index,
            tradeTp2,
            bar_index + 1,
            tradeTp2,
            extend=extend.right,
            color=color.new(color.lime, 15),
            width=1
        )

        tp3Line := line.new(
            bar_index,
            tradeTp3,
            bar_index + 1,
            tradeTp3,
            extend=extend.right,
            color=color.lime,
            width=2
        )

        entryLevelLabel := label.new(
            bar_index + 1,
            tradeEntry,
            "ENTRY",
            style=label.style_label_left,
            color=color.new(color.gray, 40),
            textcolor=color.white,
            size=size.tiny
        )

        stopLevelLabel := label.new(
            bar_index + 1,
            tradeInitialStop,
            "SL -" + f_managementText(tradeStopDistance, scalpStopCash, fixedDollarMode),
            style=label.style_label_left,
            color=color.red,
            textcolor=color.white,
            size=size.tiny
        )

        tp1LevelLabel := label.new(
            bar_index + 1,
            tradeTp1,
            "TP1 +" + f_managementText(tradeTp1Distance, scalpTp1Cash, fixedDollarMode),
            style=label.style_label_left,
            color=color.new(color.lime, 30),
            textcolor=color.black,
            size=size.tiny
        )

        tp2LevelLabel := label.new(
            bar_index + 1,
            tradeTp2,
            "TP2 +" + f_managementText(tradeTp2Distance, scalpTp2Cash, fixedDollarMode),
            style=label.style_label_left,
            color=color.new(color.lime, 15),
            textcolor=color.black,
            size=size.tiny
        )

        tp3LevelLabel := label.new(
            bar_index + 1,
            tradeTp3,
            "TP3 +" + f_managementText(tradeTp3Distance, scalpTp3Cash, fixedDollarMode),
            style=label.style_label_left,
            color=color.lime,
            textcolor=color.black,
            size=size.tiny
        )


bool tradeWasClosed = false

if (
    tradeDirection != 0 and
    bar_index > tradeEntryBar
)
    bool lockActive = (
        tradeTp1Hit and
        not na(tradeTp1Bar) and
        bar_index > tradeTp1Bar
    )

    float activeStop = (
        lockActive ?
            tradeLockStop :
            tradeInitialStop
    )

    bool activeStopHit = (
        tradeDirection == 1 ?
            low <= activeStop :
            high >= activeStop
    )

    if activeStopHit
        tradeStopEvent := true
        tradeWasClosed := true

    else
        float favorableDistance = (
            tradeDirection == 1 ?
                high - tradeEntry :
                tradeEntry - low
        )

        if (
            not tradeTp1Hit and
            favorableDistance >= tradeTp1Distance
        )
            tradeTp1Hit := true
            tradeTp1Bar := bar_index
            tradeTp1Event := true

            if not na(tp1Line)
                line.delete(tp1Line)
                tp1Line := na

            if not na(tp1LevelLabel)
                label.delete(tp1LevelLabel)
                tp1LevelLabel := na

            if not na(stopLine)
                line.delete(stopLine)
                stopLine := na

            if not na(stopLevelLabel)
                label.delete(stopLevelLabel)
                stopLevelLabel := na

            stopLine := line.new(
                bar_index + 1,
                tradeLockStop,
                bar_index + 2,
                tradeLockStop,
                extend=extend.right,
                color=color.aqua,
                width=2
            )

            stopLevelLabel := label.new(
                bar_index + 1,
                tradeLockStop,
                "LOCK +" + f_managementText(tradeLockDistance, scalpLockCash, fixedDollarMode),
                style=label.style_label_left,
                color=color.aqua,
                textcolor=color.black,
                size=size.tiny
            )

        if (
            not tradeTp2Hit and
            favorableDistance >= tradeTp2Distance
        )
            tradeTp2Hit := true
            tradeTp2Event := true

            if not na(tp2Line)
                line.delete(tp2Line)
                tp2Line := na

            if not na(tp2LevelLabel)
                label.delete(tp2LevelLabel)
                tp2LevelLabel := na

        if favorableDistance >= tradeTp3Distance
            tradeTp3Event := true
            tradeWasClosed := true

        else if (
            bar_index - tradeEntryBar >=
            scalpMaxBars
        )
            tradeTimeoutEvent := true
            tradeWasClosed := true

if (
    tradeDirection != 0 and
    tradeTp1Hit and
    not na(tradeTp1Bar) and
    bar_index == tradeTp1Bar + 1
)
    lockActivatedEvent := true

if tradeDirection != 0
    int levelLabelX = bar_index + 1

    if not na(entryLevelLabel)
        label.set_x(
            entryLevelLabel,
            levelLabelX
        )

    if not na(stopLevelLabel)
        label.set_x(
            stopLevelLabel,
            levelLabelX
        )

    if not na(tp1LevelLabel)
        label.set_x(
            tp1LevelLabel,
            levelLabelX
        )

    if not na(tp2LevelLabel)
        label.set_x(
            tp2LevelLabel,
            levelLabelX
        )

    if not na(tp3LevelLabel)
        label.set_x(
            tp3LevelLabel,
            levelLabelX
        )

if tradeWasClosed
    if not na(entryLine)
        line.delete(entryLine)
        entryLine := na

    if not na(stopLine)
        line.delete(stopLine)
        stopLine := na

    if not na(tp1Line)
        line.delete(tp1Line)
        tp1Line := na

    if not na(tp2Line)
        line.delete(tp2Line)
        tp2Line := na

    if not na(tp3Line)
        line.delete(tp3Line)
        tp3Line := na

    if not na(entryLevelLabel)
        label.delete(entryLevelLabel)
        entryLevelLabel := na

    if not na(stopLevelLabel)
        label.delete(stopLevelLabel)
        stopLevelLabel := na

    if not na(tp1LevelLabel)
        label.delete(tp1LevelLabel)
        tp1LevelLabel := na

    if not na(tp2LevelLabel)
        label.delete(tp2LevelLabel)
        tp2LevelLabel := na

    if not na(tp3LevelLabel)
        label.delete(tp3LevelLabel)
        tp3LevelLabel := na

    tradeDirection := 0
    tradeEntryBar := na
    tradeTp1Bar := na

    tradeEntry := na
    tradeInitialStop := na
    tradeLockStop := na
    tradeTp1 := na
    tradeTp2 := na
    tradeTp3 := na

    tradeStopDistance := na
    tradeLockDistance := na
    tradeTp1Distance := na
    tradeTp2Distance := na
    tradeTp3Distance := na

    tradeTp1Hit := false
    tradeTp2Hit := false

// -----------------------------------------------------------------------------
// Alerts
// -----------------------------------------------------------------------------

alertcondition(
    bullishArmedEvent,
    "ARMED LONG",
    "ARMED: bullish wedge setup is mature."
)

alertcondition(
    bearishArmedEvent,
    "ARMED SHORT",
    "ARMED: bearish wedge setup is mature."
)

alertcondition(
    adaptiveBullShift,
    "STRUCTURE CHANGE LONG",
    "STRUCTURE CHANGE: bullish regime shift."
)

alertcondition(
    adaptiveBearShift,
    "STRUCTURE CHANGE SHORT",
    "STRUCTURE CHANGE: bearish regime shift."
)

alertcondition(
    longSignal,
    "LONG",
    "LONG: validated ARMED to EARLY bullish entry."
)

alertcondition(
    shortSignal,
    "SHORT",
    "SHORT: validated Direct Short entry."
)

alertcondition(
    magicSig9Event,
    "MAGIC SIG9",
    "MAGIC SIG9: confirmed cup break / expansion."
)

alertcondition(
    strongLong4hEvent,
    "STRONG LONG",
    "STRONG LONG: confirmed 4H power signal."
)

alertcondition(
    strongShort4hEvent,
    "STRONG SHORT",
    "STRONG SHORT: confirmed 4H power signal."
)

alertcondition(
    tradeEntryLongEvent,
    "LONG TRADE ACTIVE",
    "LONG scalp manager activated."
)

alertcondition(
    tradeEntryShortEvent,
    "SHORT TRADE ACTIVE",
    "SHORT scalp manager activated."
)

alertcondition(
    tradeTp1Event,
    "TP1 HIT",
    "TP1 hit. Remaining stop will activate locked profit on the next bar."
)

alertcondition(
    lockActivatedEvent,
    "PROFIT LOCK ACTIVE",
    "Locked-profit stop is now active."
)

alertcondition(
    tradeTp2Event,
    "TP2 HIT",
    "TP2 hit."
)

alertcondition(
    tradeTp3Event,
    "TP3 HIT",
    "TP3 hit. Managed scalp completed."
)

alertcondition(
    tradeStopEvent,
    "STOP HIT",
    "Managed scalp stop hit."
)

alertcondition(
    tradeTimeoutEvent,
    "TRADE TIMEOUT",
    "Managed scalp reached its maximum holding window."
)
````
