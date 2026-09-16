<!-- tradingview-pine-id: PUB;e54110c1171c4efc83c2e682ef4a806e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HERTZ ORDER BLOCK V1.11 · ACTIVE OB MARKET BIAS PANEL 5M

Source: https://www.tradingview.com/script/WDn8TMEP/

## Description

HERTZ Order Block - Active Market Bias & Depletion [5M]

HERTZ Order Block is a market-structure-based Order Block analysis tool designed primarily for short-term cryptocurrency charts, with a particular focus on 5-minute analysis.

The indicator does not treat every opposite-colored candle as an Order Block. Instead, an Order Block can only be created after a confirmed structural event and a qualifying displacement move. The script then evaluates the resulting zone using multiple contextual factors, including displacement strength, candle structure, optional Fair Value Gap confirmation, optional candle-pattern confirmation, volume expansion, liquidity sweep context, zone size, age, retests, nearby opposing Order Blocks, and repeated-use depletion.

The purpose of the script is not to predict the next candle or guarantee a reversal. Its purpose is to identify structurally relevant Order Block zones, track how price interacts with them over time, rank their current importance, and summarize the balance between active bullish and bearish Order Blocks.

Order Block formation

A bullish Order Block is searched for after a confirmed bullish Break of Structure and bullish displacement. The script looks backward for a qualifying bearish candle that preceded the displacement and uses that candle as the source of the bullish zone.

A bearish Order Block uses the opposite process. After a confirmed bearish Break of Structure and bearish displacement, the script searches backward for a qualifying bullish candle and uses it as the source of the bearish zone.

Depending on the selected zone mode, the Order Block can be constructed from the refined portion of the source candle, its candle body, or its full high-to-low range.

Once an Order Block is created, its original price boundaries are preserved. The zone is not continuously relocated to follow price.

Confirmed lifecycle states

Each active Order Block has a lifecycle. These lifecycle states are primarily updated from confirmed bars so that an unclosed candle does not permanently change the historical state of a zone.

FRESH means that the Order Block has been created and has not yet completed a confirmed retest.

APPROACH means price has moved within the defined ATR-based approach distance of the Order Block.

IN ZONE means a confirmed price bar has interacted with the Order Block.

HOLD means the zone was tested and a later confirmed bar moved away from the zone in the expected direction by the required ATR-based confirmation distance.

These states are used not only for display purposes but also to control which Order Blocks are considered immediately actionable.

Action priority

The indicator separates structural importance from immediate trading relevance.

Structural Score (S) represents the current structural strength of an active Order Block after considering its original quality, displacement characteristics, age, mitigation status, opposing-zone conflict, and repeated-test depletion.

Action Score (A) represents how relevant an Order Block is to the current price interaction.

A distant Order Block is therefore not automatically labeled as the most important trading zone simply because it had a high initial quality score.

Only Order Blocks in the APPROACH or IN ZONE states are eligible for ACTION #1 or ACTION #2.

A FRESH zone that is still too far from current price can remain a RESERVE zone.

A completed HOLD also returns to reserve status rather than continuously encouraging entries after the original reaction has already occurred.

If opposing bullish and bearish actionable zones have similar scores, the indicator can display a WAIT condition instead of presenting a small numerical difference as a meaningful directional advantage.

Conflict-aware Order Blocks

Active bullish and bearish Order Blocks are not evaluated independently.

The script checks whether an opposing Order Block overlaps the current zone or is located close enough to interfere with the expected reaction path.

Strong and nearby opposing zones reduce the structural score of the affected Order Block. Multiple opposing zones can create an additional conflict penalty.

This allows the indicator to distinguish between a structurally isolated Order Block and one that is operating inside a congested bullish/bearish conflict area.

Repeated-test depletion

Order Blocks are not assumed to retain the same strength indefinitely.

A separate retest counter tracks independent interactions with each zone. Multiple consecutive candles remaining inside the same zone are treated as one interaction rather than multiple independent tests.

For another test to be counted, price must first leave the interaction and later return to the Order Block.

The default progressive depletion model is:

T1 - first successful test, no additional depletion.

T2 - moderate structural reduction.

T3 - stronger structural reduction.

T4 - substantial structural reduction.

T5+ - additional progressive depletion up to the configured maximum.

This mechanism is intended to represent the idea that repeatedly tested liquidity or order-flow areas may become less structurally significant as they are revisited.

The depletion values are scoring adjustments. They should not be interpreted as measured probabilities of failure.

Live warnings versus confirmed states

The indicator deliberately separates confirmed lifecycle information from intrabar warnings.

The confirmed state may continue to display HOLD, IN ZONE, or another locked state while the current realtime candle is still open.

AT RISK is a realtime warning that price is approaching the Order Block's invalidation boundary.

LIVE BREAK indicates that the current unconfirmed candle is temporarily trading beyond the relevant invalidation boundary.

These live warnings can appear and disappear while the realtime candle is forming. They do not by themselves rewrite the confirmed lifecycle of the Order Block.

With close-based invalidation, an Order Block is not permanently invalidated until the relevant candle closes beyond the zone boundary.

With wick-based invalidation, the configured wick condition is used instead.

Active Order Block Market Bias panel

The information panel in the upper-right corner summarizes the current balance between active bullish and bearish Order Blocks.

MARKET displays BULLISH, BEARISH, or NEUTRAL.

BULL DOM shows the bullish share of the active Order Block dominance calculation.

BEAR DOM shows the bearish share.

ACTIVE displays the number of active bullish and bearish Order Blocks.

TOP BULL identifies the strongest currently relevant bullish Order Block score and state.

TOP BEAR provides the equivalent information for bearish Order Blocks.

EDGE displays the difference between bullish and bearish dominance.

The market-bias calculation does not simply count bullish and bearish boxes. Each active Order Block is weighted according to its structural or actionable score, lifecycle state, and proximity to price. Conflict and repeated-test depletion are already reflected in the underlying structural evaluation.

An IN ZONE Order Block therefore contributes more immediate contextual importance than a distant and heavily depleted historical Order Block.

The Bull and Bear Dominance percentages are relative Order Block dominance measurements. They are not probabilities that price will rise or fall, and they should not be interpreted as expected win rates.

Scoring terminology

Q represents formation quality based on the qualifying contextual conditions available when the Order Block is identified.

RP is an internal reversal-power score derived from formation quality, Order Block size characteristics, and displacement strength.

S is the current Structural Score.

A is the current Action Score.

T1, T2, T3, etc. represent independent confirmed tests of a previously held Order Block.

ACTION #1 is the highest-ranked currently actionable Order Block.

ACTION #2 is the second-ranked actionable Order Block when available.

RESERVE identifies a structurally relevant zone that is not currently considered an immediate actionable interaction.

WAIT indicates that opposing actionable Order Blocks are sufficiently close in ranking that the script does not assign a meaningful directional advantage.

Intended use

The indicator is designed as a discretionary market-structure and context tool rather than an automated trading strategy.

On a 5-minute cryptocurrency chart, traders can use it to identify active demand and supply areas, observe whether price is approaching or testing those areas, compare opposing Order Block strength, recognize repeatedly tested/depleted zones, and monitor whether active Order Block structure currently favors the bullish side, bearish side, or neither side.

The indicator does not generate orders, calculate position size, or provide a complete risk-management system.

Calculation and repainting considerations

Order Block creation requires confirmed structural conditions. Historical Order Block boundaries are based on already available candle data and are stored when the zone is created.

Confirmed lifecycle transitions such as retests, holds, and close-based invalidations are evaluated using confirmed bars.

The realtime AT RISK and LIVE BREAK warnings are intentionally intrabar and can therefore change before the current candle closes. This behavior is expected and is visually separated from confirmed lifecycle states.

Users should distinguish between a confirmed state and a realtime warning when interpreting the chart.

Limitations

Order Blocks are subjective market-structure concepts and there is no universally accepted mathematical definition of the exact boundaries or validity of an Order Block.

ATR thresholds, structure lookbacks, zone construction methods, displacement requirements, and optional confirmation filters can materially affect which zones are detected.

Cryptocurrency volatility can also change significantly across symbols and market regimes. Settings appropriate for one asset or period may not behave identically on another.

A high Quality, Structural, Action, RP, Bull Dominance, or Bear Dominance value does not guarantee that price will react from a zone.

The indicator does not account for every possible source of market information, including news, fundamental events, exchange-specific liquidity conditions, hidden orders, or external derivatives positioning.

For these reasons, the indicator should be used as one component of a broader analysis and risk-management process rather than as a standalone prediction system.

What is different about this implementation

Instead of displaying every detected Order Block with equal importance, this implementation maintains a lifecycle for each zone and continually differentiates between formation quality, structural relevance, immediate action relevance, opposing-zone conflict, and repeated-use depletion.

Its state-locked FRESH / APPROACH / IN ZONE / HOLD workflow, progressive T1/T2/T3/T4 depletion model, conflict-aware scoring, live-warning separation, and active Order Block dominance panel are designed to reduce visual ambiguity and make the changing condition of each active zone easier to interpret.

Recommended starting context

The default parameters were designed with 5-minute cryptocurrency analysis in mind. They are starting values, not universally optimal settings. Users should evaluate the script on the symbol, timeframe, market conditions, and execution method relevant to their own analysis.

This indicator is provided for analytical and educational purposes. It does not constitute investment advice, does not guarantee future results, and does not claim that any displayed score represents a future return or a statistically guaranteed probability.

---

## Source Code

````pine
//@version=6
indicator("HERTZ ORDER BLOCK V1.11 · ACTIVE OB MARKET BIAS PANEL 5M", shorttitle="HERTZ OB V1.11", overlay=true, max_boxes_count=100, max_labels_count=100)

//=====================================================================
// GROUPS
//=====================================================================
string G1  = "1. STRUCTURE"
string G2  = "2. DISPLACEMENT"
string G3  = "3. CONFIRMATION"
string G4  = "4. ORDER BLOCK"
string G5  = "5. SIZE / REVERSAL POWER"
string G6  = "6. ACTION PRIORITY"
string G7  = "7. ZONE STATE / DEPLETION"
string G8  = "8. LIVE WARNING"
string G9  = "9. VISUAL"
string G10 = "10. MARKET BIAS PANEL"
string G11 = "11. ALERT"

//=====================================================================
// STRUCTURE
//=====================================================================
int structureLen = input.int(10, "Structure Lookback", minval=4, maxval=50, group=G1)
int atrLen = input.int(14, "ATR Length", minval=5, maxval=100, group=G1)

float bosBufferATR = input.float(
     0.03,
     "BOS Buffer ATR",
     minval=0.0,
     maxval=0.50,
     step=0.01,
     group=G1
)

//=====================================================================
// DISPLACEMENT
//=====================================================================
float strongBodyATR = input.float(
     0.60,
     "Strong Body ATR",
     minval=0.20,
     maxval=3.00,
     step=0.05,
     group=G2
)

float legATR = input.float(
     1.10,
     "3-Bar Displacement ATR",
     minval=0.50,
     maxval=5.00,
     step=0.05,
     group=G2
)

float minBodyRatio = input.float(
     0.55,
     "Minimum Body Ratio",
     minval=0.30,
     maxval=0.95,
     step=0.05,
     group=G2
)

int displacementWindow = input.int(
     2,
     "Displacement Memory",
     minval=0,
     maxval=5,
     group=G2
)

//=====================================================================
// CONFIRMATION
//=====================================================================
bool requireFVG = input.bool(false, "Require FVG", group=G3)
bool requirePattern = input.bool(false, "Require Candle Pattern", group=G3)
bool requireVolume = input.bool(false, "Require Volume Expansion", group=G3)
bool requireSweep = input.bool(false, "Require Liquidity Sweep", group=G3)

int fvgWindow = input.int(3, "FVG Memory", minval=1, maxval=10, group=G3)
int patternWindow = input.int(3, "Pattern Memory", minval=1, maxval=10, group=G3)
int sweepWindow = input.int(8, "Sweep Memory", minval=1, maxval=30, group=G3)

int volLen = input.int(20, "Volume Average", minval=5, maxval=100, group=G3)
int volWindow = input.int(3, "Volume Memory", minval=1, maxval=10, group=G3)

float volMultiplier = input.float(
     1.20,
     "Volume Expansion",
     minval=1.0,
     maxval=5.0,
     step=0.05,
     group=G3
)

//=====================================================================
// ORDER BLOCK
//=====================================================================
int obLookback = input.int(
     8,
     "Opposite Candle Search",
     minval=1,
     maxval=20,
     group=G4
)

string zoneMode = input.string(
     "Refined",
     "OB Zone",
     options=["Refined", "Body", "Full Candle"],
     group=G4
)

int minQuality = input.int(
     60,
     "Minimum Quality",
     minval=60,
     maxval=100,
     step=5,
     group=G4
)

string invalidationMode = input.string(
     "Close",
     "Invalidation",
     options=["Close", "Wick"],
     group=G4
)

int maxBlocks = input.int(
     12,
     "Maximum OB Count",
     minval=2,
     maxval=30,
     group=G4
)

bool keepInvalidated = input.bool(
     false,
     "Keep Invalidated OB",
     group=G4
)

//=====================================================================
// SIZE / REVERSAL POWER
//=====================================================================
float preferredMinATR = input.float(
     0.35,
     "Preferred Minimum OB ATR",
     minval=0.05,
     maxval=2.00,
     step=0.05,
     group=G5
)

float preferredMaxATR = input.float(
     0.90,
     "Preferred Maximum OB ATR",
     minval=0.10,
     maxval=3.00,
     step=0.05,
     group=G5
)

bool filterExtremeSize = input.bool(
     false,
     "Filter Extreme OB Size",
     group=G5
)

float absoluteMinATR = input.float(
     0.12,
     "Absolute Minimum OB ATR",
     minval=0.01,
     maxval=1.00,
     step=0.01,
     group=G5
)

float absoluteMaxATR = input.float(
     1.75,
     "Absolute Maximum OB ATR",
     minval=0.50,
     maxval=5.00,
     step=0.05,
     group=G5
)

//=====================================================================
// ACTION PRIORITY
//=====================================================================
float actionMaxDistanceATR = input.float(
     1.25,
     "Maximum ACTION Distance ATR",
     minval=0.25,
     maxval=5.00,
     step=0.25,
     group=G6
)

float conflictRangeATR = input.float(
     2.00,
     "Opposing OB Conflict Range ATR",
     minval=0.25,
     maxval=5.00,
     step=0.25,
     group=G6
)

int contestedMargin = input.int(
     6,
     "Contested Score Difference",
     minval=1,
     maxval=20,
     group=G6
)

bool showAction2 = input.bool(
     true,
     "Show ACTION #2",
     group=G6
)

bool showReserve = input.bool(
     true,
     "Show RESERVE",
     group=G6
)

int minimumReserveScore = input.int(
     72,
     "Minimum RESERVE Score",
     minval=50,
     maxval=95,
     group=G6
)

//=====================================================================
// STATE / RETEST
//=====================================================================
float retestArmATR = input.float(
     0.05,
     "Retest Departure ATR",
     minval=0.0,
     maxval=1.0,
     step=0.01,
     group=G7
)

int minRetestBars = input.int(
     2,
     "Minimum Bars Before Retest",
     minval=1,
     maxval=10,
     group=G7
)

float approachDistanceATR = input.float(
     0.50,
     "APPROACH Distance ATR",
     minval=0.10,
     maxval=2.00,
     step=0.05,
     group=G7
)

float holdConfirmATR = input.float(
     0.15,
     "HOLD Confirmation ATR",
     minval=0.00,
     maxval=1.00,
     step=0.05,
     group=G7
)

//=====================================================================
// PROGRESSIVE DEPLETION
//=====================================================================
int depletionT2 = input.int(
     6,
     "T2 Depletion",
     minval=0,
     maxval=20,
     group=G7
)

int depletionT3Extra = input.int(
     10,
     "T3 Additional Depletion",
     minval=0,
     maxval=25,
     group=G7
)

int depletionT4Extra = input.int(
     16,
     "T4 Additional Depletion",
     minval=0,
     maxval=30,
     group=G7
)

int depletionAfterT4 = input.int(
     6,
     "Each Test After T4",
     minval=0,
     maxval=15,
     group=G7
)

int maxDepletionPenalty = input.int(
     40,
     "Maximum Depletion",
     minval=10,
     maxval=60,
     group=G7
)

//=====================================================================
// LIVE WARNING
//=====================================================================
bool showLiveWarnings = input.bool(
     true,
     "Show Live Warnings",
     group=G8
)

float liveRiskATR = input.float(
     0.10,
     "AT RISK Distance ATR",
     minval=0.01,
     maxval=0.50,
     step=0.01,
     group=G8
)

//=====================================================================
// VISUAL
//=====================================================================
color bullColor = input.color(
     color.rgb(8, 153, 129),
     "Bullish OB",
     group=G9
)

color bearColor = input.color(
     color.rgb(242, 54, 69),
     "Bearish OB",
     group=G9
)

int projectionBars = input.int(
     18,
     "Right Projection Bars",
     minval=3,
     maxval=100,
     group=G9
)

string visualMode = input.string(
     "Clean",
     "Visual Mode",
     options=["Clean", "Detailed"],
     group=G9
)

bool hideNonPriorityText = input.bool(
     true,
     "Hide Non-Priority OB Text",
     group=G9
)

bool dimNonPriority = input.bool(
     true,
     "Dim Non-Priority OB",
     group=G9
)

bool showBOS = input.bool(false, "Show BOS", group=G9)
bool showStructure = input.bool(false, "Show Structure", group=G9)
bool showMarkers = input.bool(false, "Show Creation Markers", group=G9)

//=====================================================================
// MARKET BIAS PANEL
//=====================================================================
bool showBiasPanel = input.bool(
     true,
     "Show Market Bias Panel",
     group=G10
)

int neutralDominanceBand = input.int(
     8,
     "Neutral Dominance Band",
     minval=2,
     maxval=25,
     group=G10,
     tooltip="Bull/Bear dominance difference below this value is NEUTRAL."
)

//=====================================================================
// ALERT
//=====================================================================
bool dynamicAlerts = input.bool(true, "Dynamic Alerts", group=G11)
bool retestAlerts = input.bool(true, "Retest Alerts", group=G11)

//=====================================================================
// FUNCTIONS
//=====================================================================
f_sizeClass(float sizeATR) =>
    string result = "XL"

    if sizeATR < 0.20
        result := "MICRO"
    else if sizeATR < 0.40
        result := "SMALL"
    else if sizeATR < 0.90
        result := "MEDIUM"
    else if sizeATR < 1.40
        result := "LARGE"
    else
        result := "XL"

    result

f_sizeFit(float sizeATR) =>
    int result = 5

    if sizeATR < 0.15
        result := 3
    else if sizeATR < 0.25
        result := 8
    else if sizeATR < preferredMinATR
        result := 14
    else if sizeATR <= preferredMaxATR
        result := 20
    else if sizeATR <= 1.20
        result := 15
    else if sizeATR <= 1.50
        result := 10
    else
        result := 5

    result

f_reversalPower(int quality, float sizeATR, float impulseATR) =>
    int sizeScore = f_sizeFit(sizeATR)

    int impulseScore = int(
         math.round(
             math.min(
                 15.0,
                 math.max(
                     0.0,
                     impulseATR * 7.5
                 )
             )
         )
     )

    float raw = quality * 0.65 + sizeScore + impulseScore

    int result = int(
         math.round(
             math.min(
                 100.0,
                 math.max(
                     0.0,
                     raw
                 )
             )
         )
     )

    result

f_qualityCap(int quality) =>
    int result = 100

    if quality < 65
        result := 69
    else if quality < 75
        result := 79
    else if quality < 85
        result := 89
    else
        result := 100

    result

f_grade(int score) =>
    string result = "C"

    if score >= 90
        result := "PRIME"
    else if score >= 82
        result := "A+"
    else if score >= 74
        result := "A"
    else if score >= 64
        result := "B"
    else
        result := "C"

    result

f_distanceToZone(float price, float top, float bottom) =>
    float result = 0.0

    if price > top
        result := price - top
    else if price < bottom
        result := bottom - price
    else
        result := 0.0

    result

f_overlap(float aTop, float aBottom, float bTop, float bBottom) =>
    bool result = aBottom <= bTop and aTop >= bBottom
    result

f_zoneGap(float aTop, float aBottom, float bTop, float bBottom) =>
    float result = 0.0

    if aTop < bBottom
        result := bBottom - aTop
    else if bTop < aBottom
        result := aBottom - bTop
    else
        result := 0.0

    result

f_freshnessScore(int ageBars) =>
    int result = -8

    if ageBars <= 6
        result := 8
    else if ageBars <= 18
        result := 5
    else if ageBars <= 36
        result := 2
    else if ageBars <= 72
        result := 0
    else if ageBars <= 120
        result := -4
    else
        result := -8

    result

f_interactionScore(float distanceATR, bool inside) =>
    int result = -20

    if inside
        result := 20
    else if distanceATR <= 0.25
        result := 14
    else if distanceATR <= 0.50
        result := 10
    else if distanceATR <= 1.00
        result := 6
    else if distanceATR <= 1.50
        result := 2
    else if distanceATR <= 2.50
        result := -4
    else
        result := -20

    result

f_stateActionBonus(int state) =>
    int result = 0

    if state == 1
        result := 10
    else if state == 2
        result := 20

    result

f_stateText(int state) =>
    string result = "FRESH"

    if state == 1
        result := "APPROACH"
    else if state == 2
        result := "IN ZONE"
    else if state == 3
        result := "HOLD"

    result

f_holdText(int state, int tests) =>
    string result = f_stateText(state)

    if state == 3

        if tests <= 1
            result := "HOLD T1"
        else if tests == 2
            result := "HOLD T2"
        else if tests == 3
            result := "HOLD T3"
        else if tests == 4
            result := "HOLD T4"
        else
            result := "HOLD T5+"

    result

f_depletionPenalty(int state, int tests) =>
    int result = 0

    if state == 3

        if tests <= 1

            result := 0

        else if tests == 2

            result := depletionT2

        else if tests == 3

            result := depletionT2 + depletionT3Extra

        else if tests == 4

            result := depletionT2 + depletionT3Extra + depletionT4Extra

        else

            int extraTests = tests - 4

            result := depletionT2 +
                 depletionT3Extra +
                 depletionT4Extra +
                 extraTests * depletionAfterT4

    result := math.min(
         result,
         maxDepletionPenalty
    )

    result

//=====================================================================
// PANEL STATE WEIGHT
//
// IN ZONE > APPROACH > FRESH > HOLD
// HOLD depletion is already reflected in structural score.
//=====================================================================
f_panelStateWeight(int state) =>
    float result = 0.85

    if state == 0
        result := 0.90
    else if state == 1
        result := 1.15
    else if state == 2
        result := 1.35
    else if state == 3
        result := 0.80

    result

//=====================================================================
// PANEL PROXIMITY WEIGHT
//=====================================================================
f_panelDistanceWeight(float distanceATR, bool inside) =>
    float result = 0.45

    if inside
        result := 1.35
    else if distanceATR <= 0.25
        result := 1.25
    else if distanceATR <= 0.50
        result := 1.18
    else if distanceATR <= 1.00
        result := 1.08
    else if distanceATR <= 2.00
        result := 0.92
    else if distanceATR <= 3.00
        result := 0.72
    else
        result := 0.45

    result

//=====================================================================
// CORE
//=====================================================================
float atr = ta.atr(atrLen)

float safeATR = math.max(
     atr,
     syminfo.mintick
)

float structureHigh = ta.highest(
     high[1],
     structureLen
)

float structureLow = ta.lowest(
     low[1],
     structureLen
)

//=====================================================================
// BOS
//=====================================================================
bool bullBOS = barstate.isconfirmed and not na(structureHigh) and not na(structureHigh[1]) and close > structureHigh + atr * bosBufferATR and close[1] <= structureHigh[1] + atr[1] * bosBufferATR

bool bearBOS = barstate.isconfirmed and not na(structureLow) and not na(structureLow[1]) and close < structureLow - atr * bosBufferATR and close[1] >= structureLow[1] - atr[1] * bosBufferATR

//=====================================================================
// CANDLE DATA
//=====================================================================
float range0 = math.max(high - low, syminfo.mintick)
float range1 = math.max(high[1] - low[1], syminfo.mintick)
float range2 = math.max(high[2] - low[2], syminfo.mintick)

float body0 = math.abs(close - open)
float body1 = math.abs(close[1] - open[1])
float body2 = math.abs(close[2] - open[2])

float bodyRatio0 = body0 / range0
float bodyRatio1 = body1 / range1
float bodyRatio2 = body2 / range2

//=====================================================================
// DISPLACEMENT
//=====================================================================
bool bullStrongBar = close > open and body0 >= atr * strongBodyATR and bodyRatio0 >= minBodyRatio and close >= high - range0 * 0.20

bool bearStrongBar = close < open and body0 >= atr * strongBodyATR and bodyRatio0 >= minBodyRatio and close <= low + range0 * 0.20

int bullBars3 =
     (close > open ? 1 : 0) +
     (close[1] > open[1] ? 1 : 0) +
     (close[2] > open[2] ? 1 : 0)

int bearBars3 =
     (close < open ? 1 : 0) +
     (close[1] < open[1] ? 1 : 0) +
     (close[2] < open[2] ? 1 : 0)

float legLow3 = ta.lowest(low, 3)
float legHigh3 = ta.highest(high, 3)

bool bullStack3 = bullBars3 >= 2 and close > close[2] and close - legLow3 >= atr * legATR

bool bearStack3 = bearBars3 >= 2 and close < close[2] and legHigh3 - close >= atr * legATR

bool bullDisplacement = bullStrongBar or bullStack3
bool bearDisplacement = bearStrongBar or bearStack3

int bullDispAgo = nz(
     ta.barssince(bullDisplacement),
     100000
)

int bearDispAgo = nz(
     ta.barssince(bearDisplacement),
     100000
)

bool bullDispRecent = bullDispAgo <= displacementWindow
bool bearDispRecent = bearDispAgo <= displacementWindow

float bullImpulseATR = atr > 0.0 ?
     math.max(0.0, close - legLow3) / atr :
     0.0

float bearImpulseATR = atr > 0.0 ?
     math.max(0.0, legHigh3 - close) / atr :
     0.0

//=====================================================================
// PATTERNS
//=====================================================================
bool bullEngulfing = close[1] < open[1] and close > open and open <= close[1] and close >= open[1]

bool bearEngulfing = close[1] > open[1] and close < open and open >= close[1] and close <= open[1]

bool middleSmall = body1 <= range1 * 0.35

float candle2Mid = (
     open[2] +
     close[2]
) * 0.50

bool morningStar = close[2] < open[2] and middleSmall and close > open and close > candle2Mid

bool eveningStar = close[2] > open[2] and middleSmall and close < open and close < candle2Mid

bool threeSoldiers = close > open and close[1] > open[1] and close[2] > open[2] and close > close[1] and close[1] > close[2] and bodyRatio0 >= 0.50 and bodyRatio1 >= 0.45 and bodyRatio2 >= 0.45

bool threeCrows = close < open and close[1] < open[1] and close[2] < open[2] and close < close[1] and close[1] < close[2] and bodyRatio0 >= 0.50 and bodyRatio1 >= 0.45 and bodyRatio2 >= 0.45

bool bullPattern = bullEngulfing or morningStar or threeSoldiers

bool bearPattern = bearEngulfing or eveningStar or threeCrows

int bullPatternAgo = nz(
     ta.barssince(bullPattern),
     100000
)

int bearPatternAgo = nz(
     ta.barssince(bearPattern),
     100000
)

bool bullPatternRecent = bullPatternAgo <= patternWindow
bool bearPatternRecent = bearPatternAgo <= patternWindow

//=====================================================================
// FVG
//=====================================================================
bool bullFVG = low > high[2]
bool bearFVG = high < low[2]

int bullFVGAgo = nz(
     ta.barssince(bullFVG),
     100000
)

int bearFVGAgo = nz(
     ta.barssince(bearFVG),
     100000
)

bool bullFVGRecent = bullFVGAgo <= fvgWindow
bool bearFVGRecent = bearFVGAgo <= fvgWindow

//=====================================================================
// LIQUIDITY SWEEP
//=====================================================================
bool bullSweep = barstate.isconfirmed and not na(structureLow) and low < structureLow and close > structureLow

bool bearSweep = barstate.isconfirmed and not na(structureHigh) and high > structureHigh and close < structureHigh

int bullSweepAgo = nz(
     ta.barssince(bullSweep),
     100000
)

int bearSweepAgo = nz(
     ta.barssince(bearSweep),
     100000
)

bool bullSweepRecent = bullSweepAgo <= sweepWindow
bool bearSweepRecent = bearSweepAgo <= sweepWindow

//=====================================================================
// VOLUME
//=====================================================================
float volMA = ta.sma(
     volume,
     volLen
)

float volRatio = not na(volMA) and volMA > 0.0 ?
     volume / volMA :
     na

float maxVolRatio = ta.highest(
     volRatio,
     volWindow
)

bool volumeRecent = not na(maxVolRatio) and maxVolRatio >= volMultiplier

//=====================================================================
// QUALITY
//=====================================================================
int bullQuality =
     60 +
     (bullFVGRecent ? 15 : 0) +
     (bullPatternRecent ? 10 : 0) +
     (volumeRecent ? 5 : 0) +
     (bullSweepRecent ? 10 : 0)

int bearQuality =
     60 +
     (bearFVGRecent ? 15 : 0) +
     (bearPatternRecent ? 10 : 0) +
     (volumeRecent ? 5 : 0) +
     (bearSweepRecent ? 10 : 0)

//=====================================================================
// SETUPS
//=====================================================================
bool bullConfirmOK =
     (not requireFVG or bullFVGRecent) and
     (not requirePattern or bullPatternRecent) and
     (not requireVolume or volumeRecent) and
     (not requireSweep or bullSweepRecent)

bool bearConfirmOK =
     (not requireFVG or bearFVGRecent) and
     (not requirePattern or bearPatternRecent) and
     (not requireVolume or volumeRecent) and
     (not requireSweep or bearSweepRecent)

bool bullSetup = bullBOS and bullDispRecent and bullConfirmOK and bullQuality >= minQuality

bool bearSetup = bearBOS and bearDispRecent and bearConfirmOK and bearQuality >= minQuality

//=====================================================================
// STORAGE
//=====================================================================
var array<box> obBoxes = array.new<box>()

var array<int> obDirection = array.new<int>()

var array<bool> obActive = array.new<bool>()
var array<bool> obArmed = array.new<bool>()
var array<bool> obRetested = array.new<bool>()

var array<int> obState = array.new<int>()
var array<int> obZoneEnterBar = array.new<int>()

var array<int> obTestCount = array.new<int>()
var array<bool> obWasTouching = array.new<bool>()

var array<float> obTop = array.new<float>()
var array<float> obBottom = array.new<float>()
var array<float> obCreationATR = array.new<float>()
var array<float> obSizeATR = array.new<float>()

var array<int> obBirth = array.new<int>()
var array<int> obQuality = array.new<int>()
var array<int> obRP = array.new<int>()

var array<int> obStructuralScore = array.new<int>()
var array<int> obActionScore = array.new<int>()
var array<int> obConflict = array.new<int>()

var array<float> obDistanceATR = array.new<float>()

var int lastBullOrigin = na
var int lastBearOrigin = na

bool newBullOB = false
bool newBearOB = false

bool bullTrueRetest = false
bool bearTrueRetest = false

//=====================================================================
// CREATE BULL OB
//=====================================================================
if bullSetup

    int bullOffset = na

    for j = 1 to obLookback

        if close[j] < open[j]

            bullOffset := j
            break

    if not na(bullOffset)

        int originBar = bar_index - bullOffset

        bool uniqueOrigin = na(lastBullOrigin) or originBar != lastBullOrigin

        if uniqueOrigin

            float cHigh = high[bullOffset]
            float cLow = low[bullOffset]
            float cOpen = open[bullOffset]
            float cClose = close[bullOffset]

            float bodyHigh = math.max(cOpen, cClose)
            float bodyLow = math.min(cOpen, cClose)

            float zTop = na
            float zBottom = na

            if zoneMode == "Full Candle"

                zTop := cHigh
                zBottom := cLow

            else if zoneMode == "Body"

                zTop := bodyHigh
                zBottom := bodyLow

            else

                zTop := cOpen
                zBottom := cLow

            float creationATR = safeATR

            float sizeATR = math.max(
                 0.0,
                 zTop - zBottom
            ) / creationATR

            int rp = f_reversalPower(
                 bullQuality,
                 sizeATR,
                 bullImpulseATR
            )

            bool sizeOK =
                 not filterExtremeSize or
                 (
                     sizeATR >= absoluteMinATR and
                     sizeATR <= absoluteMaxATR
                 )

            if sizeOK

                box b = box.new(
                     left=originBar,
                     top=zTop,
                     right=bar_index + projectionBars,
                     bottom=zBottom,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     border_color=bullColor,
                     border_width=1,
                     bgcolor=color.new(bullColor, 88),
                     text="BULL | FRESH",
                     text_size=size.small,
                     text_color=color.white,
                     text_halign=text.align_center,
                     text_valign=text.align_center
                )

                array.push(obBoxes, b)
                array.push(obDirection, 1)

                array.push(obActive, true)
                array.push(obArmed, false)
                array.push(obRetested, false)

                array.push(obState, 0)
                array.push(obZoneEnterBar, -1)

                array.push(obTestCount, 0)
                array.push(obWasTouching, false)

                array.push(obTop, zTop)
                array.push(obBottom, zBottom)
                array.push(obCreationATR, creationATR)
                array.push(obSizeATR, sizeATR)

                array.push(obBirth, bar_index)
                array.push(obQuality, bullQuality)
                array.push(obRP, rp)

                array.push(obStructuralScore, 0)
                array.push(obActionScore, 0)
                array.push(obConflict, 0)

                array.push(obDistanceATR, 999.0)

                lastBullOrigin := originBar
                newBullOB := true

                if dynamicAlerts

                    alert(
                         "NEW BULLISH OB | " +
                         syminfo.ticker +
                         " | Q=" +
                         str.tostring(bullQuality),
                         alert.freq_once_per_bar_close
                    )

//=====================================================================
// CREATE BEAR OB
//=====================================================================
if bearSetup

    int bearOffset = na

    for j = 1 to obLookback

        if close[j] > open[j]

            bearOffset := j
            break

    if not na(bearOffset)

        int originBar = bar_index - bearOffset

        bool uniqueOrigin = na(lastBearOrigin) or originBar != lastBearOrigin

        if uniqueOrigin

            float cHigh = high[bearOffset]
            float cLow = low[bearOffset]
            float cOpen = open[bearOffset]
            float cClose = close[bearOffset]

            float bodyHigh = math.max(cOpen, cClose)
            float bodyLow = math.min(cOpen, cClose)

            float zTop = na
            float zBottom = na

            if zoneMode == "Full Candle"

                zTop := cHigh
                zBottom := cLow

            else if zoneMode == "Body"

                zTop := bodyHigh
                zBottom := bodyLow

            else

                zTop := cHigh
                zBottom := cOpen

            float creationATR = safeATR

            float sizeATR = math.max(
                 0.0,
                 zTop - zBottom
            ) / creationATR

            int rp = f_reversalPower(
                 bearQuality,
                 sizeATR,
                 bearImpulseATR
            )

            bool sizeOK =
                 not filterExtremeSize or
                 (
                     sizeATR >= absoluteMinATR and
                     sizeATR <= absoluteMaxATR
                 )

            if sizeOK

                box b = box.new(
                     left=originBar,
                     top=zTop,
                     right=bar_index + projectionBars,
                     bottom=zBottom,
                     xloc=xloc.bar_index,
                     extend=extend.none,
                     border_color=bearColor,
                     border_width=1,
                     bgcolor=color.new(bearColor, 88),
                     text="BEAR | FRESH",
                     text_size=size.small,
                     text_color=color.white,
                     text_halign=text.align_center,
                     text_valign=text.align_center
                )

                array.push(obBoxes, b)
                array.push(obDirection, -1)

                array.push(obActive, true)
                array.push(obArmed, false)
                array.push(obRetested, false)

                array.push(obState, 0)
                array.push(obZoneEnterBar, -1)

                array.push(obTestCount, 0)
                array.push(obWasTouching, false)

                array.push(obTop, zTop)
                array.push(obBottom, zBottom)
                array.push(obCreationATR, creationATR)
                array.push(obSizeATR, sizeATR)

                array.push(obBirth, bar_index)
                array.push(obQuality, bearQuality)
                array.push(obRP, rp)

                array.push(obStructuralScore, 0)
                array.push(obActionScore, 0)
                array.push(obConflict, 0)

                array.push(obDistanceATR, 999.0)

                lastBearOrigin := originBar
                newBearOB := true

                if dynamicAlerts

                    alert(
                         "NEW BEARISH OB | " +
                         syminfo.ticker +
                         " | Q=" +
                         str.tostring(bearQuality),
                         alert.freq_once_per_bar_close
                    )

//=====================================================================
// MAX BLOCKS
//=====================================================================
while array.size(obBoxes) > maxBlocks

    box oldBox = array.shift(obBoxes)

    box.delete(oldBox)

    array.shift(obDirection)

    array.shift(obActive)
    array.shift(obArmed)
    array.shift(obRetested)

    array.shift(obState)
    array.shift(obZoneEnterBar)

    array.shift(obTestCount)
    array.shift(obWasTouching)

    array.shift(obTop)
    array.shift(obBottom)
    array.shift(obCreationATR)
    array.shift(obSizeATR)

    array.shift(obBirth)
    array.shift(obQuality)
    array.shift(obRP)

    array.shift(obStructuralScore)
    array.shift(obActionScore)
    array.shift(obConflict)

    array.shift(obDistanceATR)

//=====================================================================
// CONFIRMED STATE ENGINE
//=====================================================================
int totalBoxes = array.size(obBoxes)

if barstate.isconfirmed and totalBoxes > 0

    for i = 0 to totalBoxes - 1

        bool active = array.get(obActive, i)

        if active

            box b = array.get(obBoxes, i)

            int direction = array.get(obDirection, i)

            bool armedNow = array.get(obArmed, i)
            bool retested = array.get(obRetested, i)

            int stateNow = array.get(obState, i)
            int zoneEnterBar = array.get(obZoneEnterBar, i)

            int testCount = array.get(obTestCount, i)

            bool wasTouching = array.get(
                 obWasTouching,
                 i
            )

            float zTop = array.get(obTop, i)
            float zBottom = array.get(obBottom, i)
            float creationATR = array.get(obCreationATR, i)

            int birthBar = array.get(obBirth, i)

            int ageBars = bar_index - birthBar

            //---------------------------------------------------------
            // INVALIDATION
            //---------------------------------------------------------
            bool invalidBull =
                 direction == 1 and
                 (
                     invalidationMode == "Close" ?
                     close < zBottom :
                     low < zBottom
                 )

            bool invalidBear =
                 direction == -1 and
                 (
                     invalidationMode == "Close" ?
                     close > zTop :
                     high > zTop
                 )

            bool invalid = invalidBull or invalidBear

            if invalid

                array.set(
                     obActive,
                     i,
                     false
                )

                if keepInvalidated

                    color fade =
                         direction == 1 ?
                         color.new(bullColor, 94) :
                         color.new(bearColor, 94)

                    box.set_right(
                         b,
                         bar_index
                    )

                    box.set_bgcolor(
                         b,
                         fade
                    )

                    box.set_border_color(
                         b,
                         fade
                    )

                    box.set_border_width(
                         b,
                         1
                    )

                    box.set_text(
                         b,
                         "INVALID"
                    )

                else

                    box.set_bgcolor(
                         b,
                         na
                    )

                    box.set_border_color(
                         b,
                         na
                    )

                    box.set_text(
                         b,
                         ""
                    )

            else

                //-----------------------------------------------------
                // ARM
                //-----------------------------------------------------
                if not armedNow

                    bool bullDepart =
                         direction == 1 and
                         close > zTop + creationATR * retestArmATR

                    bool bearDepart =
                         direction == -1 and
                         close < zBottom - creationATR * retestArmATR

                    if bullDepart or bearDepart

                        armedNow := true

                        array.set(
                             obArmed,
                             i,
                             true
                        )

                //-----------------------------------------------------
                // DISTANCE / TOUCH
                //-----------------------------------------------------
                float lockedDistance =
                     f_distanceToZone(
                         close,
                         zTop,
                         zBottom
                     ) / creationATR

                bool zoneTouched =
                     low <= zTop and
                     high >= zBottom

                //-----------------------------------------------------
                // INDEPENDENT TEST
                //-----------------------------------------------------
                bool newTestEpisode =
                     armedNow and
                     ageBars >= minRetestBars and
                     zoneTouched and
                     not wasTouching

                if newTestEpisode

                    testCount += 1

                    array.set(
                         obTestCount,
                         i,
                         testCount
                    )

                array.set(
                     obWasTouching,
                     i,
                     zoneTouched
                )

                //-----------------------------------------------------
                // FRESH
                //-----------------------------------------------------
                if armedNow and stateNow == 0

                    if zoneTouched and ageBars >= minRetestBars

                        stateNow := 2
                        zoneEnterBar := bar_index

                        array.set(
                             obState,
                             i,
                             2
                        )

                        array.set(
                             obZoneEnterBar,
                             i,
                             bar_index
                        )

                    else if lockedDistance <= approachDistanceATR

                        stateNow := 1

                        array.set(
                             obState,
                             i,
                             1
                        )

                //-----------------------------------------------------
                // APPROACH
                //-----------------------------------------------------
                else if armedNow and stateNow == 1

                    if zoneTouched and ageBars >= minRetestBars

                        stateNow := 2
                        zoneEnterBar := bar_index

                        array.set(
                             obState,
                             i,
                             2
                        )

                        array.set(
                             obZoneEnterBar,
                             i,
                             bar_index
                        )

                    else if lockedDistance > approachDistanceATR

                        stateNow := 0

                        array.set(
                             obState,
                             i,
                             0
                        )

                //-----------------------------------------------------
                // FIRST RETEST FLAG
                //-----------------------------------------------------
                if armedNow and not retested and ageBars >= minRetestBars and zoneTouched

                    array.set(
                         obRetested,
                         i,
                         true
                    )

                    if direction == 1

                        bullTrueRetest := true

                        if dynamicAlerts and retestAlerts

                            alert(
                                 "BULLISH OB TRUE RETEST | " +
                                 syminfo.ticker,
                                 alert.freq_once_per_bar_close
                            )

                    else

                        bearTrueRetest := true

                        if dynamicAlerts and retestAlerts

                            alert(
                                 "BEARISH OB TRUE RETEST | " +
                                 syminfo.ticker,
                                 alert.freq_once_per_bar_close
                            )

                //-----------------------------------------------------
                // IN ZONE -> HOLD
                //-----------------------------------------------------
                if stateNow == 2

                    if zoneEnterBar >= 0 and bar_index > zoneEnterBar

                        bool bullHold =
                             direction == 1 and
                             close > zTop + creationATR * holdConfirmATR

                        bool bearHold =
                             direction == -1 and
                             close < zBottom - creationATR * holdConfirmATR

                        if bullHold or bearHold

                            stateNow := 3

                            array.set(
                                 obState,
                                 i,
                                 3
                            )

                        else if not zoneTouched

                            if lockedDistance <= approachDistanceATR

                                stateNow := 1

                                array.set(
                                     obState,
                                     i,
                                     1
                                )

                            else

                                stateNow := 0

                                array.set(
                                     obState,
                                     i,
                                     0
                                )

//=====================================================================
// STRUCTURAL + ACTION SCORE
//=====================================================================
if totalBoxes > 0

    for i = 0 to totalBoxes - 1

        bool active = array.get(
             obActive,
             i
        )

        if active

            int direction = array.get(
                 obDirection,
                 i
            )

            float zTop = array.get(
                 obTop,
                 i
            )

            float zBottom = array.get(
                 obBottom,
                 i
            )

            int birthBar = array.get(
                 obBirth,
                 i
            )

            int quality = array.get(
                 obQuality,
                 i
            )

            int rp = array.get(
                 obRP,
                 i
            )

            int stateNow = array.get(
                 obState,
                 i
            )

            int testCount = array.get(
                 obTestCount,
                 i
            )

            bool retested = array.get(
                 obRetested,
                 i
            )

            int ageBars =
                 bar_index -
                 birthBar

            //---------------------------------------------------------
            // DISTANCE
            //---------------------------------------------------------
            float priceDistance =
                 f_distanceToZone(
                     close,
                     zTop,
                     zBottom
                 )

            float distanceATR =
                 priceDistance /
                 safeATR

            bool priceInside =
                 close <= zTop and
                 close >= zBottom

            array.set(
                 obDistanceATR,
                 i,
                 distanceATR
            )

            //---------------------------------------------------------
            // AGE / MITIGATION
            //---------------------------------------------------------
            int freshness =
                 f_freshnessScore(
                     ageBars
                 )

            int mitigation =
                 retested ?
                 -3 :
                 4

            int depletionPenalty =
                 f_depletionPenalty(
                     stateNow,
                     testCount
                 )

            //---------------------------------------------------------
            // CONFLICT
            //---------------------------------------------------------
            int conflictPenalty = 0
            int conflictCount = 0

            float currentCenter =
                 (
                     zTop +
                     zBottom
                 ) * 0.50

            for j = 0 to totalBoxes - 1

                if j != i

                    bool oppActive =
                         array.get(
                             obActive,
                             j
                         )

                    if oppActive

                        int oppDirection =
                             array.get(
                                 obDirection,
                                 j
                             )

                        if oppDirection != direction

                            float oppTop =
                                 array.get(
                                     obTop,
                                     j
                                 )

                            float oppBottom =
                                 array.get(
                                     obBottom,
                                     j
                                 )

                            float oppCenter =
                                 (
                                     oppTop +
                                     oppBottom
                                 ) * 0.50

                            bool zonesOverlap =
                                 f_overlap(
                                     zTop,
                                     zBottom,
                                     oppTop,
                                     oppBottom
                                 )

                            bool inPath =
                                 zonesOverlap or
                                 (
                                     direction == 1 and
                                     oppCenter >= currentCenter
                                 ) or
                                 (
                                     direction == -1 and
                                     oppCenter <= currentCenter
                                 )

                            if inPath

                                float gap =
                                     f_zoneGap(
                                         zTop,
                                         zBottom,
                                         oppTop,
                                         oppBottom
                                     )

                                float gapATR =
                                     gap /
                                     safeATR

                                if zonesOverlap or gapATR <= conflictRangeATR

                                    int basePenalty = 0

                                    if zonesOverlap
                                        basePenalty := 22
                                    else if gapATR <= 0.25
                                        basePenalty := 18
                                    else if gapATR <= 0.50
                                        basePenalty := 14
                                    else if gapATR <= 1.00
                                        basePenalty := 10
                                    else if gapATR <= 1.50
                                        basePenalty := 6
                                    else if gapATR <= 2.00
                                        basePenalty := 3

                                    if basePenalty > 0

                                        conflictCount += 1

                                        int oppRP =
                                             array.get(
                                                 obRP,
                                                 j
                                             )

                                        int oppBirth =
                                             array.get(
                                                 obBirth,
                                                 j
                                             )

                                        int oppState =
                                             array.get(
                                                 obState,
                                                 j
                                             )

                                        int oppTests =
                                             array.get(
                                                 obTestCount,
                                                 j
                                             )

                                        bool oppRetested =
                                             array.get(
                                                 obRetested,
                                                 j
                                             )

                                        int oppAge =
                                             bar_index -
                                             oppBirth

                                        int oppDepletion =
                                             f_depletionPenalty(
                                                 oppState,
                                                 oppTests
                                             )

                                        int oppContext =
                                             oppRP +
                                             f_freshnessScore(oppAge) +
                                             (
                                                 oppRetested ?
                                                 -3 :
                                                 4
                                             ) -
                                             oppDepletion

                                        int ownContext =
                                             rp +
                                             freshness +
                                             mitigation -
                                             depletionPenalty

                                        int strengthPenalty = 0

                                        if oppContext >= ownContext + 10

                                            strengthPenalty := 7

                                        else if oppContext >= ownContext

                                            strengthPenalty := 4

                                        int candidatePenalty =
                                             basePenalty +
                                             strengthPenalty

                                        conflictPenalty :=
                                             math.max(
                                                 conflictPenalty,
                                                 candidatePenalty
                                             )

            if conflictCount >= 2

                conflictPenalty += 3

            conflictPenalty :=
                 math.min(
                     conflictPenalty,
                     35
                 )

            array.set(
                 obConflict,
                 i,
                 conflictPenalty
            )

            //---------------------------------------------------------
            // STRUCTURAL SCORE
            //---------------------------------------------------------
            int structuralRaw =
                 rp +
                 freshness +
                 mitigation -
                 conflictPenalty -
                 depletionPenalty

            int structuralScore =
                 math.max(
                     0,
                     math.min(
                         100,
                         structuralRaw
                     )
                 )

            int qualityCap =
                 f_qualityCap(
                     quality
                 )

            structuralScore :=
                 math.min(
                     structuralScore,
                     qualityCap
                 )

            array.set(
                 obStructuralScore,
                 i,
                 structuralScore
            )

            //---------------------------------------------------------
            // ACTION SCORE
            //---------------------------------------------------------
            int interaction =
                 f_interactionScore(
                     distanceATR,
                     priceInside
                 )

            int stateBonus =
                 f_stateActionBonus(
                     stateNow
                 )

            int actionRaw =
                 structuralScore +
                 interaction +
                 stateBonus

            int actionScore =
                 math.max(
                     0,
                     math.min(
                         100,
                         actionRaw
                     )
                 )

            actionScore :=
                 math.min(
                     actionScore,
                     qualityCap
                 )

            array.set(
                 obActionScore,
                 i,
                 actionScore
            )

//=====================================================================
// ACTION #1
//=====================================================================
int action1Index = -1
int action1Score = -1

if totalBoxes > 0

    for i = 0 to totalBoxes - 1

        bool active =
             array.get(
                 obActive,
                 i
             )

        if active

            int stateNow =
                 array.get(
                     obState,
                     i
                 )

            float distanceATR =
                 array.get(
                     obDistanceATR,
                     i
                 )

            int score =
                 array.get(
                     obActionScore,
                     i
                 )

            bool stateEligible =
                 stateNow == 1 or
                 stateNow == 2

            bool distanceEligible =
                 distanceATR <=
                 actionMaxDistanceATR

            if stateEligible and distanceEligible and score > action1Score

                action1Score := score
                action1Index := i

//=====================================================================
// ACTION #2
//=====================================================================
int action2Index = -1
int action2Score = -1

if showAction2 and totalBoxes > 0

    for i = 0 to totalBoxes - 1

        if i != action1Index

            bool active =
                 array.get(
                     obActive,
                     i
                 )

            if active

                int stateNow =
                     array.get(
                         obState,
                         i
                     )

                float distanceATR =
                     array.get(
                         obDistanceATR,
                         i
                     )

                int score =
                     array.get(
                         obActionScore,
                         i
                     )

                bool stateEligible =
                     stateNow == 1 or
                     stateNow == 2

                bool distanceEligible =
                     distanceATR <=
                     actionMaxDistanceATR

                if stateEligible and distanceEligible and score > action2Score

                    action2Score := score
                    action2Index := i

//=====================================================================
// CONTESTED
//=====================================================================
bool actionContested = false

if action1Index >= 0 and action2Index >= 0

    int dir1 =
         array.get(
             obDirection,
             action1Index
         )

    int dir2 =
         array.get(
             obDirection,
             action2Index
         )

    int scoreDifference =
         math.abs(
             action1Score -
             action2Score
         )

    actionContested =
         dir1 != dir2 and
         scoreDifference <= contestedMargin

//=====================================================================
// RESERVE
//=====================================================================
int reserveIndex = -1
int reserveScore = -1

if showReserve and totalBoxes > 0

    for i = 0 to totalBoxes - 1

        if i != action1Index and i != action2Index

            bool active =
                 array.get(
                     obActive,
                     i
                 )

            if active

                int stateNow =
                     array.get(
                         obState,
                         i
                     )

                int structural =
                     array.get(
                         obStructuralScore,
                         i
                     )

                bool reserveState =
                     stateNow == 0 or
                     stateNow == 3

                if reserveState and structural >= minimumReserveScore and structural > reserveScore

                    reserveScore := structural
                    reserveIndex := i

//=====================================================================
// VISUAL ENGINE
//=====================================================================
bool isLiveOpenBar =
     barstate.isrealtime and
     not barstate.isconfirmed

if totalBoxes > 0

    for i = 0 to totalBoxes - 1

        bool active =
             array.get(
                 obActive,
                 i
             )

        if active

            box b =
                 array.get(
                     obBoxes,
                     i
                 )

            int direction =
                 array.get(
                     obDirection,
                     i
                 )

            int quality =
                 array.get(
                     obQuality,
                     i
                 )

            int rp =
                 array.get(
                     obRP,
                     i
                 )

            int structuralScore =
                 array.get(
                     obStructuralScore,
                     i
                 )

            int actionScore =
                 array.get(
                     obActionScore,
                     i
                 )

            int conflictPenalty =
                 array.get(
                     obConflict,
                     i
                 )

            int stateNow =
                 array.get(
                     obState,
                     i
                 )

            int testCount =
                 array.get(
                     obTestCount,
                     i
                 )

            int depletionPenalty =
                 f_depletionPenalty(
                     stateNow,
                     testCount
                 )

            float sizeATR =
                 array.get(
                     obSizeATR,
                     i
                 )

            float zTop =
                 array.get(
                     obTop,
                     i
                 )

            float zBottom =
                 array.get(
                     obBottom,
                     i
                 )

            float creationATR =
                 array.get(
                     obCreationATR,
                     i
                 )

            bool isAction1 =
                 i == action1Index

            bool isAction2 =
                 i == action2Index

            bool isReserve =
                 i == reserveIndex

            bool isContestedAction =
                 actionContested and
                 (
                     isAction1 or
                     isAction2
                 )

            bool isPriority =
                 isAction1 or
                 isAction2 or
                 isReserve

            string sideText =
                 direction == 1 ?
                 "BULL" :
                 "BEAR"

            string stateText =
                 f_holdText(
                     stateNow,
                     testCount
                 )

            string sizeName =
                 f_sizeClass(
                     sizeATR
                 )

            string conflictText = "CLEAR"

            if conflictPenalty >= 12

                conflictText := "CONFLICT"

            else if conflictPenalty >= 6

                conflictText := "NEAR OPP"

            string actionGrade =
                 f_grade(
                     actionScore
                 )

            string structuralGrade =
                 f_grade(
                     structuralScore
                 )

            //---------------------------------------------------------
            // LIVE WARNING
            //---------------------------------------------------------
            bool liveBreak = false
            bool liveRisk = false

            if showLiveWarnings and isLiveOpenBar

                if direction == 1

                    if invalidationMode == "Close"

                        liveBreak :=
                             close < zBottom

                        liveRisk :=
                             not liveBreak and
                             low <= zBottom + creationATR * liveRiskATR

                    else

                        liveBreak :=
                             low < zBottom

                        liveRisk :=
                             not liveBreak and
                             low <= zBottom + creationATR * liveRiskATR

                else

                    if invalidationMode == "Close"

                        liveBreak :=
                             close > zTop

                        liveRisk :=
                             not liveBreak and
                             high >= zTop - creationATR * liveRiskATR

                    else

                        liveBreak :=
                             high > zTop

                        liveRisk :=
                             not liveBreak and
                             high >= zTop - creationATR * liveRiskATR

            string liveWarningText = ""

            if liveBreak
                liveWarningText := "LIVE BREAK"
            else if liveRisk
                liveWarningText := "AT RISK"

            //---------------------------------------------------------
            // CLEAN TEXT
            //---------------------------------------------------------
            string cleanLine1 = ""
            string cleanLine2 = ""

            if isContestedAction

                cleanLine1 :=
                     sideText +
                     " | WAIT"

                cleanLine2 :=
                     stateText +
                     " | A" +
                     str.tostring(
                         actionScore
                     )

            else if isAction1

                cleanLine1 :=
                     sideText +
                     " | ACTION #1"

                cleanLine2 :=
                     stateText +
                     " | A" +
                     str.tostring(
                         actionScore
                     ) +
                     " " +
                     actionGrade

            else if isAction2

                cleanLine1 :=
                     sideText +
                     " | ACTION #2"

                cleanLine2 :=
                     stateText +
                     " | A" +
                     str.tostring(
                         actionScore
                     )

            else if isReserve

                cleanLine1 :=
                     sideText +
                     " | RESERVE"

                cleanLine2 :=
                     stateText +
                     " | S" +
                     str.tostring(
                         structuralScore
                     ) +
                     " " +
                     structuralGrade

            else

                cleanLine1 :=
                     sideText +
                     " | " +
                     stateText

            //---------------------------------------------------------
            // DETAILED TEXT
            //---------------------------------------------------------
            string rankText = ""

            if isContestedAction
                rankText := "WAIT"
            else if isAction1
                rankText := "ACTION #1"
            else if isAction2
                rankText := "ACTION #2"
            else if isReserve
                rankText := "RESERVE"

            string detailedLine1 =
                 sideText +
                 " OB | " +
                 sizeName +
                 " | " +
                 rankText

            string detailedLine2 =
                 "Q" +
                 str.tostring(quality) +
                 " RP" +
                 str.tostring(rp) +
                 " S" +
                 str.tostring(structuralScore) +
                 " A" +
                 str.tostring(actionScore)

            string detailedLine3 =
                 conflictText +
                 " | " +
                 stateText

            string detailedLine4 = ""

            if depletionPenalty > 0

                detailedLine4 :=
                     "DEPLETION -" +
                     str.tostring(
                         depletionPenalty
                     )

            //---------------------------------------------------------
            // FINAL TEXT
            //---------------------------------------------------------
            string finalText = ""

            if visualMode == "Detailed"

                if isPriority

                    finalText :=
                         detailedLine1 +
                         "\n" +
                         detailedLine2 +
                         "\n" +
                         detailedLine3

                    if detailedLine4 != ""

                        finalText :=
                             finalText +
                             "\n" +
                             detailedLine4

                else if not hideNonPriorityText

                    finalText :=
                         sideText +
                         " | " +
                         stateText

            else

                if isPriority

                    finalText :=
                         cleanLine1 +
                         "\n" +
                         cleanLine2

                else if not hideNonPriorityText

                    finalText :=
                         cleanLine1

            if liveWarningText != ""

                if finalText != ""

                    finalText :=
                         finalText +
                         "\n" +
                         liveWarningText

                else

                    finalText :=
                         sideText +
                         " | " +
                         liveWarningText

            box.set_text(
                 b,
                 finalText
            )

            //---------------------------------------------------------
            // COLORS
            //---------------------------------------------------------
            color baseColor =
                 direction == 1 ?
                 bullColor :
                 bearColor

            int transparency = 95
            int borderWidth = 1

            if isAction1 and not actionContested and stateNow == 2

                transparency := 55
                borderWidth := 4

            else if isAction1 and not actionContested

                transparency := 66
                borderWidth := 4

            else if isAction2 and not actionContested

                transparency := 76
                borderWidth := 3

            else if isContestedAction

                transparency := 78
                borderWidth := 3

            else if isReserve

                transparency := 88
                borderWidth := 2

            else

                if dimNonPriority

                    transparency := 96

                else

                    transparency := 92

            //---------------------------------------------------------
            // DEPLETION FADE
            //---------------------------------------------------------
            if stateNow == 3

                if testCount == 3

                    transparency :=
                         math.max(
                             transparency,
                             89
                         )

                else if testCount >= 4

                    transparency :=
                         math.max(
                             transparency,
                             92
                         )

            //---------------------------------------------------------
            // LIVE WARNING OVERRIDE
            //---------------------------------------------------------
            if liveBreak

                transparency :=
                     math.min(
                         transparency,
                         60
                     )

                borderWidth :=
                     math.max(
                         borderWidth,
                         4
                     )

            else if liveRisk

                transparency :=
                     math.min(
                         transparency,
                         76
                     )

                borderWidth :=
                     math.max(
                         borderWidth,
                         3
                     )

            box.set_bgcolor(
                 b,
                 color.new(
                     baseColor,
                     transparency
                 )
            )

            box.set_border_color(
                 b,
                 baseColor
            )

            box.set_border_width(
                 b,
                 borderWidth
            )

            if isAction1 or isAction2 or liveBreak

                box.set_text_size(
                     b,
                     size.small
                 )

            else

                box.set_text_size(
                     b,
                     size.tiny
                 )

            if isPriority or liveWarningText != ""

                box.set_text_color(
                     b,
                     color.white
                 )

            else

                box.set_text_color(
                     b,
                     color.new(
                         color.white,
                         60
                     )
                )

//=====================================================================
// ACTIVE OB MARKET BIAS ENGINE
//
// Uses:
// - ACTIVE OBs only
// - confirmed OB states
// - structural/action score
// - proximity
// - state
// - conflict already inside S
// - depletion already inside S
//
// Does NOT use a single candle direction.
// Does NOT represent probability.
//=====================================================================
float bullPower = 0.0
float bearPower = 0.0

int activeBullCount = 0
int activeBearCount = 0

int topBullScore = 0
int topBearScore = 0

int topBullState = -1
int topBearState = -1

// During live bar, panel deliberately uses LAST CONFIRMED close/ATR.
float panelPrice =
     barstate.isconfirmed ?
     close :
     nz(close[1], close)

float panelATR =
     barstate.isconfirmed ?
     safeATR :
     nz(safeATR[1], safeATR)

if totalBoxes > 0

    for i = 0 to totalBoxes - 1

        bool active =
             array.get(
                 obActive,
                 i
             )

        if active

            int direction =
                 array.get(
                     obDirection,
                     i
                 )

            int stateNow =
                 array.get(
                     obState,
                     i
                 )

            int structuralScore =
                 array.get(
                     obStructuralScore,
                     i
                 )

            float zTop =
                 array.get(
                     obTop,
                     i
                 )

            float zBottom =
                 array.get(
                     obBottom,
                     i
                 )

            float confirmedDistance =
                 f_distanceToZone(
                     panelPrice,
                     zTop,
                     zBottom
                 )

            float confirmedDistanceATR =
                 confirmedDistance /
                 math.max(
                     panelATR,
                     syminfo.mintick
                 )

            bool confirmedInside =
                 panelPrice <= zTop and
                 panelPrice >= zBottom

            //---------------------------------------------------------
            // CONFIRMED ACTION-LIKE SCORE
            //
            // APPROACH / IN ZONE use current structural score plus
            // locked confirmed interaction.
            //---------------------------------------------------------
            int effectiveScore =
                 structuralScore

            if stateNow == 1 or stateNow == 2

                int confirmedInteraction =
                     f_interactionScore(
                         confirmedDistanceATR,
                         confirmedInside
                     )

                int stateBonus =
                     f_stateActionBonus(
                         stateNow
                     )

                effectiveScore :=
                     math.min(
                         100,
                         math.max(
                             0,
                             structuralScore +
                             confirmedInteraction +
                             stateBonus
                         )
                     )

            float stateWeight =
                 f_panelStateWeight(
                     stateNow
                 )

            float proximityWeight =
                 f_panelDistanceWeight(
                     confirmedDistanceATR,
                     confirmedInside
                 )

            float weightedPower =
                 effectiveScore *
                 stateWeight *
                 proximityWeight

            //---------------------------------------------------------
            // BULL
            //---------------------------------------------------------
            if direction == 1

                activeBullCount += 1

                bullPower +=
                     weightedPower

                if effectiveScore > topBullScore

                    topBullScore :=
                         effectiveScore

                    topBullState :=
                         stateNow

            //---------------------------------------------------------
            // BEAR
            //---------------------------------------------------------
            else

                activeBearCount += 1

                bearPower +=
                     weightedPower

                if effectiveScore > topBearScore

                    topBearScore :=
                         effectiveScore

                    topBearState :=
                         stateNow

//=====================================================================
// DOMINANCE NORMALIZATION
//=====================================================================
float totalPower =
     bullPower +
     bearPower

float bullDominance = 50.0
float bearDominance = 50.0

if totalPower > 0.0

    bullDominance :=
         bullPower /
         totalPower *
         100.0

    bearDominance :=
         bearPower /
         totalPower *
         100.0

float dominanceEdge =
     bullDominance -
     bearDominance

//=====================================================================
// MARKET STATE
//=====================================================================
string marketBias = "NEUTRAL"

if activeBullCount == 0 and activeBearCount == 0

    marketBias :=
         "NO ACTIVE OB"

else if dominanceEdge >= neutralDominanceBand

    marketBias :=
         "BULLISH"

else if dominanceEdge <= -neutralDominanceBand

    marketBias :=
         "BEARISH"

else

    marketBias :=
         "NEUTRAL"

//=====================================================================
// PANEL COLORS
//=====================================================================
color panelBg =
     color.new(
         color.black,
         22
     )

color biasBg =
     marketBias == "BULLISH" ?
     color.new(
         bullColor,
         25
     ) :
     marketBias == "BEARISH" ?
     color.new(
         bearColor,
         25
     ) :
     color.new(
         color.gray,
         45
     )

color bullPanelBg =
     color.new(
         bullColor,
         72
     )

color bearPanelBg =
     color.new(
         bearColor,
         72
     )

//=====================================================================
// RIGHT-TOP MARKET BIAS TABLE
//=====================================================================
var table biasTable =
     table.new(
         position.top_right,
         2,
         8,
         frame_color=color.new(color.gray, 50),
         frame_width=1,
         border_color=color.new(color.gray, 70),
         border_width=1
     )

if barstate.islast

    if showBiasPanel

        //-------------------------------------------------------------
        // HEADER
        //-------------------------------------------------------------
        table.cell(
             biasTable,
             0,
             0,
             "ACTIVE OB",
             text_color=color.white,
             bgcolor=color.new(color.gray, 60),
             text_size=size.small
        )

        table.cell(
             biasTable,
             1,
             0,
             "BIAS",
             text_color=color.white,
             bgcolor=color.new(color.gray, 60),
             text_size=size.small
        )

        //-------------------------------------------------------------
        // MARKET
        //-------------------------------------------------------------
        table.cell(
             biasTable,
             0,
             1,
             "MARKET",
             text_color=color.silver,
             bgcolor=panelBg,
             text_size=size.small
        )

        table.cell(
             biasTable,
             1,
             1,
             marketBias,
             text_color=color.white,
             bgcolor=biasBg,
             text_size=size.small
        )

        //-------------------------------------------------------------
        // BULL DOMINANCE
        //-------------------------------------------------------------
        table.cell(
             biasTable,
             0,
             2,
             "BULL DOM",
             text_color=color.white,
             bgcolor=bullPanelBg,
             text_size=size.small
        )

        table.cell(
             biasTable,
             1,
             2,
             str.tostring(
                 bullDominance,
                 "#.0"
             ) + "%",
             text_color=color.white,
             bgcolor=bullPanelBg,
             text_size=size.small
        )

        //-------------------------------------------------------------
        // BEAR DOMINANCE
        //-------------------------------------------------------------
        table.cell(
             biasTable,
             0,
             3,
             "BEAR DOM",
             text_color=color.white,
             bgcolor=bearPanelBg,
             text_size=size.small
        )

        table.cell(
             biasTable,
             1,
             3,
             str.tostring(
                 bearDominance,
                 "#.0"
             ) + "%",
             text_color=color.white,
             bgcolor=bearPanelBg,
             text_size=size.small
        )

        //-------------------------------------------------------------
        // ACTIVE COUNT
        //-------------------------------------------------------------
        table.cell(
             biasTable,
             0,
             4,
             "ACTIVE",
             text_color=color.silver,
             bgcolor=panelBg,
             text_size=size.small
        )

        table.cell(
             biasTable,
             1,
             4,
             "B " +
             str.tostring(activeBullCount) +
             " / S " +
             str.tostring(activeBearCount),
             text_color=color.white,
             bgcolor=panelBg,
             text_size=size.small
        )

        //-------------------------------------------------------------
        // TOP BULL
        //-------------------------------------------------------------
        string topBullText =
             activeBullCount > 0 ?
             str.tostring(topBullScore) +
             " | " +
             f_stateText(topBullState) :
             "--"

        table.cell(
             biasTable,
             0,
             5,
             "TOP BULL",
             text_color=color.white,
             bgcolor=bullPanelBg,
             text_size=size.tiny
        )

        table.cell(
             biasTable,
             1,
             5,
             topBullText,
             text_color=color.white,
             bgcolor=bullPanelBg,
             text_size=size.tiny
        )

        //-------------------------------------------------------------
        // TOP BEAR
        //-------------------------------------------------------------
        string topBearText =
             activeBearCount > 0 ?
             str.tostring(topBearScore) +
             " | " +
             f_stateText(topBearState) :
             "--"

        table.cell(
             biasTable,
             0,
             6,
             "TOP BEAR",
             text_color=color.white,
             bgcolor=bearPanelBg,
             text_size=size.tiny
        )

        table.cell(
             biasTable,
             1,
             6,
             topBearText,
             text_color=color.white,
             bgcolor=bearPanelBg,
             text_size=size.tiny
        )

        //-------------------------------------------------------------
        // EDGE
        //-------------------------------------------------------------
        string edgeText =
             dominanceEdge > 0 ?
             "+" +
             str.tostring(
                 dominanceEdge,
                 "#.0"
             ) :
             str.tostring(
                 dominanceEdge,
                 "#.0"
             )

        table.cell(
             biasTable,
             0,
             7,
             "EDGE",
             text_color=color.silver,
             bgcolor=panelBg,
             text_size=size.small
        )

        table.cell(
             biasTable,
             1,
             7,
             edgeText,
             text_color=color.white,
             bgcolor=biasBg,
             text_size=size.small
        )

    else

        table.clear(
             biasTable,
             0,
             0,
             1,
             7
        )

//=====================================================================
// OPTIONAL STRUCTURE
//=====================================================================
plot(
     showStructure ?
     structureHigh :
     na,
     "Structure High",
     color=color.new(
         bearColor,
         65
     ),
     style=plot.style_linebr
)

plot(
     showStructure ?
     structureLow :
     na,
     "Structure Low",
     color=color.new(
         bullColor,
         65
     ),
     style=plot.style_linebr
)

//=====================================================================
// BOS
//=====================================================================
plotshape(
     showBOS and bullBOS,
     title="Bull BOS",
     style=shape.labelup,
     location=location.belowbar,
     color=bullColor,
     text="BOS",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showBOS and bearBOS,
     title="Bear BOS",
     style=shape.labeldown,
     location=location.abovebar,
     color=bearColor,
     text="BOS",
     textcolor=color.white,
     size=size.tiny
)

//=====================================================================
// CREATION MARKERS
//=====================================================================
plotshape(
     showMarkers and newBullOB,
     title="New Bull OB",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
)

plotshape(
     showMarkers and newBearOB,
     title="New Bear OB",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
)

//=====================================================================
// ALERT CONDITIONS
//=====================================================================
alertcondition(
     newBullOB,
     title="New Bullish Order Block",
     message="NEW BULLISH OB | {{ticker}} | {{interval}} | {{close}}"
)

alertcondition(
     newBearOB,
     title="New Bearish Order Block",
     message="NEW BEARISH OB | {{ticker}} | {{interval}} | {{close}}"
)

alertcondition(
     bullTrueRetest,
     title="Bullish OB True Retest",
     message="BULLISH OB TRUE RETEST | {{ticker}} | {{interval}} | {{close}}"
)

alertcondition(
     bearTrueRetest,
     title="Bearish OB True Retest",
     message="BEARISH OB TRUE RETEST | {{ticker}} | {{interval}} | {{close}}"
)
````
