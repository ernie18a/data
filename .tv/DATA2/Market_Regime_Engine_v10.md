<!-- tradingview-pine-id: PUB;6bc80b43126b49cf8cc3718cdbe4c129 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market Regime Engine v1.0

Source: https://www.tradingview.com/script/Nr5RMcSh-Market-Regime-Engine/

## Description

Market Regime Engine

Market Regime Engine is a multi-layer market-state and historical research framework designed to identify what the market is doing, where it is in the broader market cycle, how mature the current regime is, and how similar historical environments have behaved afterward.

Rather than defining trend from a single indicator, the engine processes price, volume, volatility, momentum, and market structure through several independent layers and combines them into a standardized:

Regime Score: -100 → +100

The architecture is:

Price + Volume → Fast Engine → Structure Engine → Context Engine → Regime Score → Regime + Stage → Regime Age → Historical Cohort

The objective is to remain responsive to genuine changes in market behavior without allowing a single moving-average cross, high-volume candle, or isolated structural signal to completely change the market classification.

Fast Engine

The Fast Engine is the most responsive part of the model and receives substantial weight in the final score.

It analyzes:

20 SMA location — whether price is above or below its short-term trend mean.
20 SMA slope — whether the trend itself is rising, falling, or flattening.
Displacement — candle-body expansion normalized by ATR.
Relative Volume (RVOL) — determines whether directional movement is being accompanied by meaningful participation.

The combination of price relative to the 20 SMA, SMA slope, displacement, and volume provides the first indication that market behavior is changing.

ATR normalization allows these measurements to adapt across instruments and volatility regimes.

Structure Engine

The Structure Engine asks whether price structure confirms what the Fast Engine is detecting.

It tracks:

Swing highs
Swing lows
Higher highs
Higher lows
Lower highs
Lower lows
Break of Structure (BOS)
Change of Character (CHoCH)

A BOS identifies a meaningful break of established swing structure and receives one of the largest individual weights in the model.

A CHoCH identifies a potential change in the prevailing structural direction and is particularly useful when an established trend begins deteriorating.

This creates an important distinction between simply moving above or below the 20 SMA and actually changing market structure.

Context Engine

The Context Engine determines whether the surrounding environment supports the signals coming from price and structure.

It incorporates:

ATR — normalizes price movement and allows the engine to compare displacement and SMA distance across changing volatility environments.

ADX/DMI — measures trend strength and directional confirmation. ADX itself does not determine whether the market is bullish or bearish; it strengthens an already established directional condition.

Fair Value Gaps (FVG) — identify recent price imbalances that provide additional directional context.

Order Blocks — identify recent opposing candles preceding meaningful displacement.

FVG and Order Block information intentionally receive relatively small weights because they are treated as contextual evidence rather than primary directional signals.

Regime Score

All of these components feed into a single standardized score:

-100 ←──────── 0 ────────→ +100

Negative values represent increasing bearish alignment, while positive values represent increasing bullish alignment.

The full weighting framework is:

Component	Maximum Weight
Price vs. 20 SMA	±15
20 SMA Slope	±15
Relative Volume	±10
Displacement	±10
Swing Structure	±10
Break of Structure	±20
CHoCH	±10
ADX/DMI	±5
FVG	±2.5
Order Block	±2.5
Maximum Score	±100

This hierarchy is intentional.

The engine places greater importance on price, the 20 SMA, volume, displacement and structural breaks, while FVGs and Order Blocks act as secondary confirmation.

Regime Classification

The Regime Score is translated into five market states:

Strong Bull — broad bullish alignment with strong directional confirmation.

Bull — bullish evidence dominates, but the environment is not strong enough to qualify as Strong Bull.

Range / Neutral — directional evidence is weak, balanced, or conflicting.

Bear — bearish evidence dominates.

Strong Bear — broad bearish alignment with strong downside confirmation.

A confirmation mechanism prevents every short-lived fluctuation from changing the official regime.

For example, price briefly crossing below a rising 20 SMA does not automatically terminate a Bull regime. Other components must deteriorate sufficiently for the aggregate score to confirm a meaningful transition.

This provides the responsiveness of a fast indicator without making the classification excessively sensitive to noise.

Regime vs. Market Stage

One of the most important features of the full engine is that Regime and Stage are separate calculations.

Regime = tactical market condition

Regime answers:

What is the market doing right now?

It is relatively fast and responsive.

Stage = structural market cycle

Stage answers:

Where is the market within the broader trend cycle?

The model uses four stages:

Stage 1 — Base / Accumulation

Typically characterized by flattening trend, weaker ADX, overlapping price structure, and stabilization following a bearish environment.

Stage 2 — Markup

Characterized by a rising 20 SMA, bullish structure, price above the trend mean, structural upside progression and strengthening trend conditions.

Stage 3 — Distribution

Represents deterioration following a bullish environment. The 20 SMA may flatten, bullish structure begins failing, lower highs may develop, and bearish CHoCH can signal that the previous advance is losing control.

Stage 4 — Markdown

Characterized by a falling 20 SMA, bearish structure, price below the trend mean and established downside progression.

Because Stage and Regime are independent, the model can recognize transitions such as:

Strong Bull / Stage 2 → Bull / Stage 2 → Range / Stage 2 → Range / Stage 3 → Bear / Stage 3 → Bear / Stage 4

This provides considerably more information than simply labeling every bar "uptrend" or "downtrend."

Regime Age

Once a confirmed regime begins, the engine counts how many bars that regime has survived.

This produces Regime Age.

For example:

Bull — Age 4
Bull — Age 8
Bull — Age 13
Bull — Age 21

The numbers 8, 13 and 21 do not determine the regime or Stage.

They are strictly research checkpoints.

A market does not become more bullish because it reaches Age 13, nor does it become bearish because it reaches Age 21.

Instead, regime age allows the model to investigate whether the statistical behavior of a market changes as a regime matures.

Historical Cohort Engine

The full Market Regime Engine extends beyond classification by maintaining a historical cohort research layer.

At the designated regime-age checkpoints:

8 bars
13 bars
21 bars

the engine studies subsequent market behavior over:

5 bars
10 bars
20 bars

The research layer can evaluate characteristics such as:

Continuation probability
Average forward return
Historical sample size
Direction-adjusted performance

The larger framework can also be extended to measure:

Median return
Maximum Favorable Excursion (MFE)
Maximum Adverse Excursion (MAE)
Regime survival rate
Regime failure rate
Probability of a new high or low
Probability of transitioning into another regime

This creates a distinction between classification and expectancy.

The Regime Engine tells you:

What environment are we in?

The Historical Cohort Engine asks:

What has historically happened after environments like this?

Importantly, historical cohort statistics do not feed back into the Regime Score. They remain an independent research layer.

Distance From the 20 SMA

The full engine also measures price's distance from its 20 SMA in ATR units:

(Price − 20 SMA) / ATR

This provides information that a simple Bull/Bear classification cannot.

For example, two markets might both have a +55 Bull Regime Score, but one could be:

0.30 ATR above its 20 SMA

while the other is:

2.20 ATR above its 20 SMA.

The directional environment may be similar, but the second market is substantially more extended.

SMA distance is therefore treated primarily as location information rather than additional directional points, helping avoid double-counting the same trend information.

Full Dashboard

The larger version exposes the internal workings of the engine rather than displaying only the final regime.

The dashboard reports:

Current Regime
Regime Score
Market Stage
Regime Age
Price vs. 20 SMA
SMA slope
RVOL
Displacement
BOS
CHoCH
ADX
FVG
Order Block context
ATR-normalized SMA distance
5-bar historical cohort results
10-bar historical cohort results
20-bar historical cohort results

This makes the indicator transparent: instead of simply being told that the market is Bullish, the user can see why the model reached that conclusion.

Example

Suppose the dashboard reports:

Regime: BULL
Score: +32.5
Stage: Stage 2 — Markup
Age: 9 bars

with:

Price above 20 SMA: +15
Rising SMA: +15
RVOL: 0
Displacement: 0
BOS: 0
CHoCH: 0
ADX: 0
Bullish FVG: +2.5

The result is:

+15 + 15 + 2.5 = +32.5

The correct interpretation is not simply "the market is going higher."

Instead, the engine is saying:

The market remains structurally bullish and in a Stage-2 environment, but immediate momentum, volume and structural-break confirmation are currently limited.

That distinction is the purpose of the model.

Philosophy of the Indicator

Market Regime Engine is built around the idea that:

Regime ≠ Trade Entry

A bullish regime does not mean every bar should be bought, just as a bearish regime does not mean every bar should be sold.

The engine is designed to establish environment and directional context.

Execution can then be handled separately using the trader's preferred methodology—price location, pullbacks, candlestick confirmation, support/resistance, volume profile, or other entry criteria.

The framework therefore separates three different questions:

Regime:
What is the market doing?

Stage:
Where are we in the broader cycle?

Historical Cohort:
What happened historically after comparable conditions?

Together, these create a market-state framework that attempts to remain fast enough to recognize meaningful change, structured enough to resist noise, and transparent enough to understand exactly why the market received its current classification.

For research and educational purposes only. Market Regime Engine does not predict future prices and is not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Market Regime Engine v1.0", overlay=true, max_labels_count=500)

//=============================================================================
// MARKET REGIME ENGINE
//
// PRICE + VOLUME
//      |
// FAST ENGINE
//      |
// STRUCTURE ENGINE
//      |
// CONTEXT ENGINE
//      |
// REGIME SCORE (-100 to +100)
//      |
// REGIME + STAGE
//      |
// REGIME AGE
//      |
// HISTORICAL COHORT
//
// 8 / 13 / 21 ARE RESEARCH POINTS ONLY.
// THEY DO NOT DETERMINE REGIME OR STAGE.
//=============================================================================


//=============================================================================
// 1. INPUTS
//=============================================================================

groupFast = "1. Fast Engine"

smaLength = input.int(20, "SMA Length", minval=2, group=groupFast)
slopeBars = input.int(3, "SMA Slope Bars", minval=1, group=groupFast)
slopeThreshold = input.float(0.10, "Slope Threshold (ATR)", minval=0.01, step=0.01, group=groupFast)
rvolLength = input.int(20, "RVOL Length", minval=2, group=groupFast)
rvolThreshold = input.float(1.20, "RVOL Threshold", minval=0.10, step=0.05, group=groupFast)
displacementThreshold = input.float(0.75, "Displacement Threshold (ATR)", minval=0.10, step=0.05, group=groupFast)

groupStructure = "2. Structure Engine"

swingLength = input.int(3, "Swing Length", minval=2, maxval=20, group=groupStructure)
structureMemory = input.int(5, "BOS / CHoCH Memory", minval=1, maxval=20, group=groupStructure)

groupContext = "3. Context Engine"

atrLength = input.int(14, "ATR Length", minval=2, group=groupContext)
diLength = input.int(14, "DI Length", minval=2, group=groupContext)
adxSmoothing = input.int(14, "ADX Smoothing", minval=1, group=groupContext)
adxThreshold = input.float(20.0, "ADX Trend Threshold", minval=5.0, step=0.5, group=groupContext)
fvgMemory = input.int(10, "FVG Memory", minval=1, maxval=50, group=groupContext)
obSearchBars = input.int(10, "Order Block Search", minval=2, maxval=30, group=groupContext)
obMemory = input.int(20, "Order Block Maximum Age", minval=1, maxval=100, group=groupContext)

groupRegime = "4. Regime Engine"

bullThreshold = input.float(30.0, "Bull Threshold", minval=10.0, maxval=80.0, group=groupRegime)
bearThreshold = input.float(-30.0, "Bear Threshold", minval=-80.0, maxval=-10.0, group=groupRegime)
strongBullThreshold = input.float(60.0, "Strong Bull Threshold", minval=30.0, maxval=100.0, group=groupRegime)
strongBearThreshold = input.float(-60.0, "Strong Bear Threshold", minval=-100.0, maxval=-30.0, group=groupRegime)
confirmationBars = input.int(2, "Regime Confirmation Bars", minval=1, maxval=10, group=groupRegime)

groupResearch = "5. Regime Age / Cohort Research"

researchLookback = input.int(1000, "Historical Lookback", minval=100, maxval=5000, group=groupResearch)
showAgeLabels = input.bool(true, "Show 8 / 13 / 21 Age Labels", group=groupResearch)

groupDisplay = "6. Display"

showSMA = input.bool(true, "Show 20 SMA", group=groupDisplay)
showBackground = input.bool(true, "Show Regime Background", group=groupDisplay)
showStructureLabels = input.bool(true, "Show BOS / CHoCH Labels", group=groupDisplay)
showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)


//=============================================================================
// 2. FAST ENGINE
//=============================================================================

//-----------------------------------------------------------------------------
// 20 SMA
//-----------------------------------------------------------------------------

sma20 = ta.sma(close, smaLength)

//-----------------------------------------------------------------------------
// ATR
//-----------------------------------------------------------------------------

atr = ta.atr(atrLength)

//-----------------------------------------------------------------------------
// SMA slope normalized to ATR
//-----------------------------------------------------------------------------

float smaSlope = 0.0

if not na(sma20[slopeBars])
    if atr > 0
        smaSlope := (sma20 - sma20[slopeBars]) / atr

bool smaRising = smaSlope > slopeThreshold
bool smaFalling = smaSlope < -slopeThreshold
bool smaFlat = not smaRising and not smaFalling

//-----------------------------------------------------------------------------
// Distance from SMA
//-----------------------------------------------------------------------------

float distanceFromSMA = 0.0

if atr > 0
    distanceFromSMA := (close - sma20) / atr

//-----------------------------------------------------------------------------
// Relative Volume
//-----------------------------------------------------------------------------

volumeAverage = ta.sma(volume, rvolLength)

float rvol = 0.0

if volumeAverage > 0
    rvol := volume / volumeAverage

bool highRVOL = rvol >= rvolThreshold

//-----------------------------------------------------------------------------
// Candle displacement
//-----------------------------------------------------------------------------

candleBody = math.abs(close - open)

float displacement = 0.0

if atr > 0
    displacement := candleBody / atr

bool bullishDisplacement = close > open and displacement >= displacementThreshold
bool bearishDisplacement = close < open and displacement >= displacementThreshold


//=============================================================================
// 3. STRUCTURE ENGINE
//=============================================================================

//-----------------------------------------------------------------------------
// Confirmed swing highs and lows
//-----------------------------------------------------------------------------

pivotHigh = ta.pivothigh(high, swingLength, swingLength)
pivotLow = ta.pivotlow(low, swingLength, swingLength)

var float currentSwingHigh = na
var float priorSwingHigh = na

var float currentSwingLow = na
var float priorSwingLow = na

if not na(pivotHigh)
    priorSwingHigh := currentSwingHigh
    currentSwingHigh := pivotHigh

if not na(pivotLow)
    priorSwingLow := currentSwingLow
    currentSwingLow := pivotLow

//-----------------------------------------------------------------------------
// HH / HL / LH / LL
//-----------------------------------------------------------------------------

bool higherHigh = false
bool lowerHigh = false
bool higherLow = false
bool lowerLow = false

if not na(currentSwingHigh)
    if not na(priorSwingHigh)
        higherHigh := currentSwingHigh > priorSwingHigh
        lowerHigh := currentSwingHigh < priorSwingHigh

if not na(currentSwingLow)
    if not na(priorSwingLow)
        higherLow := currentSwingLow > priorSwingLow
        lowerLow := currentSwingLow < priorSwingLow

bool bullishSwingStructure = higherHigh and higherLow
bool bearishSwingStructure = lowerHigh and lowerLow

//-----------------------------------------------------------------------------
// BOS / CHoCH
//-----------------------------------------------------------------------------

var int structureDirection = 0

bool bullBOS = false
bool bearBOS = false
bool bullCHoCH = false
bool bearCHoCH = false

bool highBreak = false
bool lowBreak = false

if not na(currentSwingHigh)
    if close > currentSwingHigh
        if close[1] <= currentSwingHigh
            highBreak := true

if not na(currentSwingLow)
    if close < currentSwingLow
        if close[1] >= currentSwingLow
            lowBreak := true

if highBreak
    if structureDirection == -1
        bullCHoCH := true
    else
        bullBOS := true

    structureDirection := 1

if lowBreak
    if structureDirection == 1
        bearCHoCH := true
    else
        bearBOS := true

    structureDirection := -1

//-----------------------------------------------------------------------------
// Structure memory
//-----------------------------------------------------------------------------

barsBullBOS = ta.barssince(bullBOS)
barsBearBOS = ta.barssince(bearBOS)
barsBullCHoCH = ta.barssince(bullCHoCH)
barsBearCHoCH = ta.barssince(bearCHoCH)

bool recentBullBOS = false
bool recentBearBOS = false
bool recentBullCHoCH = false
bool recentBearCHoCH = false

if not na(barsBullBOS)
    recentBullBOS := barsBullBOS <= structureMemory

if not na(barsBearBOS)
    recentBearBOS := barsBearBOS <= structureMemory

if not na(barsBullCHoCH)
    recentBullCHoCH := barsBullCHoCH <= structureMemory

if not na(barsBearCHoCH)
    recentBearCHoCH := barsBearCHoCH <= structureMemory


//=============================================================================
// 4. CONTEXT ENGINE
//=============================================================================

//-----------------------------------------------------------------------------
// ADX / DMI
//-----------------------------------------------------------------------------

[plusDI, minusDI, adx] = ta.dmi(diLength, adxSmoothing)

bool adxTrending = adx >= adxThreshold

//-----------------------------------------------------------------------------
// FVG
//-----------------------------------------------------------------------------

bool bullFVG = false
bool bearFVG = false

if bar_index >= 2
    bullFVG := low > high[2]
    bearFVG := high < low[2]

barsBullFVG = ta.barssince(bullFVG)
barsBearFVG = ta.barssince(bearFVG)

bool recentBullFVG = false
bool recentBearFVG = false

if not na(barsBullFVG)
    recentBullFVG := barsBullFVG <= fvgMemory

if not na(barsBearFVG)
    recentBearFVG := barsBearFVG <= fvgMemory

//-----------------------------------------------------------------------------
// Order Blocks
//
// Simplified:
// Bull OB = most recent bearish candle before bullish displacement.
// Bear OB = most recent bullish candle before bearish displacement.
//-----------------------------------------------------------------------------

var float bullOBHigh = na
var float bullOBLow = na
var float bearOBHigh = na
var float bearOBLow = na

var int bullOBBar = na
var int bearOBBar = na

if bullishDisplacement
    for i = 1 to obSearchBars
        if close[i] < open[i]
            bullOBHigh := high[i]
            bullOBLow := low[i]
            bullOBBar := bar_index - i
            break

if bearishDisplacement
    for i = 1 to obSearchBars
        if close[i] > open[i]
            bearOBHigh := high[i]
            bearOBLow := low[i]
            bearOBBar := bar_index - i
            break

bool bullOBActive = false
bool bearOBActive = false

if not na(bullOBBar)
    if bar_index - bullOBBar <= obMemory
        if close >= bullOBLow
            bullOBActive := true

if not na(bearOBBar)
    if bar_index - bearOBBar <= obMemory
        if close <= bearOBHigh
            bearOBActive := true


//=============================================================================
// 5. REGIME SCORE
//
// Fast information gets the greatest influence.
// FVG / OB are contextual and deliberately low weight.
//=============================================================================

//-----------------------------------------------------------------------------
// PRICE VS 20 SMA
//
// +/- 15
//-----------------------------------------------------------------------------

float priceScore = 0.0

if close > sma20
    priceScore := 15.0
else if close < sma20
    priceScore := -15.0

//-----------------------------------------------------------------------------
// SMA SLOPE
//
// +/- 15
//-----------------------------------------------------------------------------

float slopeScore = 0.0

if smaRising
    slopeScore := 15.0
else if smaFalling
    slopeScore := -15.0

//-----------------------------------------------------------------------------
// DISPLACEMENT
//
// +/- 10
//-----------------------------------------------------------------------------

float displacementScore = 0.0

if bullishDisplacement
    displacementScore := 10.0
else if bearishDisplacement
    displacementScore := -10.0

//-----------------------------------------------------------------------------
// RVOL
//
// +/- 10 when volume confirms directional candle.
//-----------------------------------------------------------------------------

float volumeScore = 0.0

if highRVOL
    if close > open
        volumeScore := 10.0
    else if close < open
        volumeScore := -10.0

//-----------------------------------------------------------------------------
// SWING STRUCTURE
//
// +/- 10
//-----------------------------------------------------------------------------

float swingScore = 0.0

if bullishSwingStructure
    swingScore := 10.0
else if bearishSwingStructure
    swingScore := -10.0

//-----------------------------------------------------------------------------
// BOS
//
// +/- 20
//
// Highest individual structural weight.
//-----------------------------------------------------------------------------

float bosScore = 0.0

if recentBullBOS
    if not recentBearBOS
        bosScore := 20.0

if recentBearBOS
    if not recentBullBOS
        bosScore := -20.0

//-----------------------------------------------------------------------------
// CHoCH
//
// +/- 10
//-----------------------------------------------------------------------------

float chochScore = 0.0

if recentBullCHoCH
    if not recentBearCHoCH
        chochScore := 10.0

if recentBearCHoCH
    if not recentBullCHoCH
        chochScore := -10.0

//-----------------------------------------------------------------------------
// ADX
//
// ADX does NOT create direction.
//
// It only reinforces an existing directional environment.
// +/- 5
//-----------------------------------------------------------------------------

float adxScore = 0.0

if adxTrending
    if plusDI > minusDI
        if close > sma20
            adxScore := 5.0

    if minusDI > plusDI
        if close < sma20
            adxScore := -5.0

//-----------------------------------------------------------------------------
// FVG
//
// Context only.
// +/- 2.5
//-----------------------------------------------------------------------------

float fvgScore = 0.0

if recentBullFVG
    if not recentBearFVG
        fvgScore := 2.5

if recentBearFVG
    if not recentBullFVG
        fvgScore := -2.5

//-----------------------------------------------------------------------------
// ORDER BLOCK
//
// Context only.
// +/- 2.5
//-----------------------------------------------------------------------------

float obScore = 0.0

if bullOBActive
    if not bearOBActive
        obScore := 2.5

if bearOBActive
    if not bullOBActive
        obScore := -2.5

//-----------------------------------------------------------------------------
// TOTAL
//
// Maximum = +100
// Minimum = -100
//-----------------------------------------------------------------------------

rawScore = priceScore + slopeScore + displacementScore + volumeScore + swingScore + bosScore + chochScore + adxScore + fvgScore + obScore

regimeScore = math.max(-100.0, math.min(100.0, rawScore))


//=============================================================================
// 6. RAW REGIME
//=============================================================================

int rawRegime = 0

if regimeScore >= strongBullThreshold
    rawRegime := 2
else if regimeScore >= bullThreshold
    rawRegime := 1
else if regimeScore <= strongBearThreshold
    rawRegime := -2
else if regimeScore <= bearThreshold
    rawRegime := -1
else
    rawRegime := 0


//=============================================================================
// 7. REGIME CONFIRMATION
//
// Prevent one SMA cross or one noisy candle from flipping regime.
//=============================================================================

var int confirmedRegime = 0
var int candidateRegime = 0
var int candidateBars = 0

bool regimeChanged = false

if rawRegime == confirmedRegime
    candidateRegime := confirmedRegime
    candidateBars := 0
else
    if rawRegime == candidateRegime
        candidateBars += 1
    else
        candidateRegime := rawRegime
        candidateBars := 1

    if candidateBars >= confirmationBars
        confirmedRegime := candidateRegime
        candidateBars := 0
        regimeChanged := true


//=============================================================================
// 8. REGIME AGE
//
// AGE DOES NOT AFFECT REGIME SCORE.
//=============================================================================

var int regimeAge = 1

if barstate.isfirst
    regimeAge := 1
else
    if regimeChanged
        regimeAge := 1
    else
        regimeAge += 1

bool age8 = regimeAge == 8
bool age13 = regimeAge == 13
bool age21 = regimeAge == 21

bool researchCheckpoint = age8 or age13 or age21


//=============================================================================
// 9. STAGE ENGINE
//
// Stage is structurally derived.
//
// Stage 1 = Accumulation / Base
// Stage 2 = Markup
// Stage 3 = Distribution / Topping
// Stage 4 = Markdown
//
// AGE IS NOT USED.
//=============================================================================

bool stage1Condition = false
bool stage2Condition = false
bool stage3Condition = false
bool stage4Condition = false

//-----------------------------------------------------------------------------
// Stage 2 - Markup
//-----------------------------------------------------------------------------

if close > sma20
    if smaRising
        if structureDirection == 1
            if adxTrending
                stage2Condition := true

//-----------------------------------------------------------------------------
// Stage 4 - Markdown
//-----------------------------------------------------------------------------

if close < sma20
    if smaFalling
        if structureDirection == -1
            if adxTrending
                stage4Condition := true

//-----------------------------------------------------------------------------
// Stage 3 - Distribution
//
// Bullish structure is deteriorating.
//-----------------------------------------------------------------------------

if structureDirection == 1
    if bearCHoCH
        stage3Condition := true

    if lowerHigh
        if not smaRising
            stage3Condition := true

    if smaFlat
        if close <= sma20
            stage3Condition := true

//-----------------------------------------------------------------------------
// Stage 1 - Accumulation
//
// Bearish structure is stabilizing/recovering.
//-----------------------------------------------------------------------------

if confirmedRegime == 0
    if smaFlat
        if not adxTrending
            stage1Condition := true

if structureDirection == -1
    if bullCHoCH
        stage1Condition := true

    if higherLow
        if not smaFalling
            stage1Condition := true

//-----------------------------------------------------------------------------
// Final stage
//-----------------------------------------------------------------------------

int marketStage = 1

if stage4Condition
    marketStage := 4
else if stage3Condition
    marketStage := 3
else if stage2Condition
    marketStage := 2
else if stage1Condition
    marketStage := 1
else
    if confirmedRegime > 0
        marketStage := 2
    else if confirmedRegime < 0
        marketStage := 4
    else
        marketStage := 1


//=============================================================================
// 10. REGIME / STAGE NAMES
//=============================================================================

string regimeName = "RANGE"

if confirmedRegime == 2
    regimeName := "STRONG BULL"
else if confirmedRegime == 1
    regimeName := "BULL"
else if confirmedRegime == -1
    regimeName := "BEAR"
else if confirmedRegime == -2
    regimeName := "STRONG BEAR"

string stageName = "STAGE 1 - BASE"

if marketStage == 1
    stageName := "STAGE 1 - BASE"
else if marketStage == 2
    stageName := "STAGE 2 - MARKUP"
else if marketStage == 3
    stageName := "STAGE 3 - DISTRIBUTION"
else if marketStage == 4
    stageName := "STAGE 4 - MARKDOWN"


//=============================================================================
// 11. HISTORICAL COHORT ENGINE
//
// Research question:
//
// When a regime reached age 8 / 13 / 21,
// what happened 5 / 10 / 20 bars afterward?
//
// These statistics DO NOT feed back into regime classification.
//=============================================================================

//-----------------------------------------------------------------------------
// Running cohort statistics
//-----------------------------------------------------------------------------

var int samples8_5 = 0
var int wins8_5 = 0
var float sum8_5 = 0.0

var int samples8_10 = 0
var int wins8_10 = 0
var float sum8_10 = 0.0

var int samples8_20 = 0
var int wins8_20 = 0
var float sum8_20 = 0.0

var int samples13_5 = 0
var int wins13_5 = 0
var float sum13_5 = 0.0

var int samples13_10 = 0
var int wins13_10 = 0
var float sum13_10 = 0.0

var int samples13_20 = 0
var int wins13_20 = 0
var float sum13_20 = 0.0

var int samples21_5 = 0
var int wins21_5 = 0
var float sum21_5 = 0.0

var int samples21_10 = 0
var int wins21_10 = 0
var float sum21_10 = 0.0

var int samples21_20 = 0
var int wins21_20 = 0
var float sum21_20 = 0.0

//-----------------------------------------------------------------------------
// Helper values
//
// Outcome is direction-adjusted:
//
// Bull regime:
// positive price return = success.
//
// Bear regime:
// negative price return = success.
//
// Range is excluded from directional cohort research.
//-----------------------------------------------------------------------------

bool enoughHistory = bar_index > 30

if enoughHistory

    //-------------------------------------------------------------------------
    // AGE 8 -> 5 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[5] == 8
        if confirmedRegime[5] != 0
            if bar_index - 5 <= researchLookback
                float return8_5 = 0.0

                if close[5] != 0
                    return8_5 := ((close - close[5]) / close[5]) * 100.0

                float adjusted8_5 = return8_5

                if confirmedRegime[5] < 0
                    adjusted8_5 := -return8_5

                samples8_5 += 1
                sum8_5 += adjusted8_5

                if adjusted8_5 > 0
                    wins8_5 += 1

    //-------------------------------------------------------------------------
    // AGE 8 -> 10 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[10] == 8
        if confirmedRegime[10] != 0
            if bar_index - 10 <= researchLookback
                float return8_10 = 0.0

                if close[10] != 0
                    return8_10 := ((close - close[10]) / close[10]) * 100.0

                float adjusted8_10 = return8_10

                if confirmedRegime[10] < 0
                    adjusted8_10 := -return8_10

                samples8_10 += 1
                sum8_10 += adjusted8_10

                if adjusted8_10 > 0
                    wins8_10 += 1

    //-------------------------------------------------------------------------
    // AGE 8 -> 20 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[20] == 8
        if confirmedRegime[20] != 0
            if bar_index - 20 <= researchLookback
                float return8_20 = 0.0

                if close[20] != 0
                    return8_20 := ((close - close[20]) / close[20]) * 100.0

                float adjusted8_20 = return8_20

                if confirmedRegime[20] < 0
                    adjusted8_20 := -return8_20

                samples8_20 += 1
                sum8_20 += adjusted8_20

                if adjusted8_20 > 0
                    wins8_20 += 1

    //-------------------------------------------------------------------------
    // AGE 13 -> 5 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[5] == 13
        if confirmedRegime[5] != 0
            if bar_index - 5 <= researchLookback
                float return13_5 = 0.0

                if close[5] != 0
                    return13_5 := ((close - close[5]) / close[5]) * 100.0

                float adjusted13_5 = return13_5

                if confirmedRegime[5] < 0
                    adjusted13_5 := -return13_5

                samples13_5 += 1
                sum13_5 += adjusted13_5

                if adjusted13_5 > 0
                    wins13_5 += 1

    //-------------------------------------------------------------------------
    // AGE 13 -> 10 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[10] == 13
        if confirmedRegime[10] != 0
            if bar_index - 10 <= researchLookback
                float return13_10 = 0.0

                if close[10] != 0
                    return13_10 := ((close - close[10]) / close[10]) * 100.0

                float adjusted13_10 = return13_10

                if confirmedRegime[10] < 0
                    adjusted13_10 := -return13_10

                samples13_10 += 1
                sum13_10 += adjusted13_10

                if adjusted13_10 > 0
                    wins13_10 += 1

    //-------------------------------------------------------------------------
    // AGE 13 -> 20 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[20] == 13
        if confirmedRegime[20] != 0
            if bar_index - 20 <= researchLookback
                float return13_20 = 0.0

                if close[20] != 0
                    return13_20 := ((close - close[20]) / close[20]) * 100.0

                float adjusted13_20 = return13_20

                if confirmedRegime[20] < 0
                    adjusted13_20 := -return13_20

                samples13_20 += 1
                sum13_20 += adjusted13_20

                if adjusted13_20 > 0
                    wins13_20 += 1

    //-------------------------------------------------------------------------
    // AGE 21 -> 5 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[5] == 21
        if confirmedRegime[5] != 0
            if bar_index - 5 <= researchLookback
                float return21_5 = 0.0

                if close[5] != 0
                    return21_5 := ((close - close[5]) / close[5]) * 100.0

                float adjusted21_5 = return21_5

                if confirmedRegime[5] < 0
                    adjusted21_5 := -return21_5

                samples21_5 += 1
                sum21_5 += adjusted21_5

                if adjusted21_5 > 0
                    wins21_5 += 1

    //-------------------------------------------------------------------------
    // AGE 21 -> 10 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[10] == 21
        if confirmedRegime[10] != 0
            if bar_index - 10 <= researchLookback
                float return21_10 = 0.0

                if close[10] != 0
                    return21_10 := ((close - close[10]) / close[10]) * 100.0

                float adjusted21_10 = return21_10

                if confirmedRegime[10] < 0
                    adjusted21_10 := -return21_10

                samples21_10 += 1
                sum21_10 += adjusted21_10

                if adjusted21_10 > 0
                    wins21_10 += 1

    //-------------------------------------------------------------------------
    // AGE 21 -> 20 BAR OUTCOME
    //-------------------------------------------------------------------------

    if regimeAge[20] == 21
        if confirmedRegime[20] != 0
            if bar_index - 20 <= researchLookback
                float return21_20 = 0.0

                if close[20] != 0
                    return21_20 := ((close - close[20]) / close[20]) * 100.0

                float adjusted21_20 = return21_20

                if confirmedRegime[20] < 0
                    adjusted21_20 := -return21_20

                samples21_20 += 1
                sum21_20 += adjusted21_20

                if adjusted21_20 > 0
                    wins21_20 += 1


//=============================================================================
// 12. COHORT STATISTICS
//=============================================================================

float winPct8_5 = na
float winPct8_10 = na
float winPct8_20 = na

float winPct13_5 = na
float winPct13_10 = na
float winPct13_20 = na

float winPct21_5 = na
float winPct21_10 = na
float winPct21_20 = na

float avg8_5 = na
float avg8_10 = na
float avg8_20 = na

float avg13_5 = na
float avg13_10 = na
float avg13_20 = na

float avg21_5 = na
float avg21_10 = na
float avg21_20 = na

if samples8_5 > 0
    winPct8_5 := wins8_5 * 100.0 / samples8_5
    avg8_5 := sum8_5 / samples8_5

if samples8_10 > 0
    winPct8_10 := wins8_10 * 100.0 / samples8_10
    avg8_10 := sum8_10 / samples8_10

if samples8_20 > 0
    winPct8_20 := wins8_20 * 100.0 / samples8_20
    avg8_20 := sum8_20 / samples8_20

if samples13_5 > 0
    winPct13_5 := wins13_5 * 100.0 / samples13_5
    avg13_5 := sum13_5 / samples13_5

if samples13_10 > 0
    winPct13_10 := wins13_10 * 100.0 / samples13_10
    avg13_10 := sum13_10 / samples13_10

if samples13_20 > 0
    winPct13_20 := wins13_20 * 100.0 / samples13_20
    avg13_20 := sum13_20 / samples13_20

if samples21_5 > 0
    winPct21_5 := wins21_5 * 100.0 / samples21_5
    avg21_5 := sum21_5 / samples21_5

if samples21_10 > 0
    winPct21_10 := wins21_10 * 100.0 / samples21_10
    avg21_10 := sum21_10 / samples21_10

if samples21_20 > 0
    winPct21_20 := wins21_20 * 100.0 / samples21_20
    avg21_20 := sum21_20 / samples21_20


//=============================================================================
// 13. VISUALS
//=============================================================================

color smaColor = color.gray

if confirmedRegime > 0
    smaColor := color.green
else if confirmedRegime < 0
    smaColor := color.red

plot(showSMA ? sma20 : na, title="20 SMA", color=smaColor, linewidth=2)

color backgroundColor = na

if confirmedRegime == 2
    backgroundColor := color.new(color.green, 90)
else if confirmedRegime == 1
    backgroundColor := color.new(color.green, 95)
else if confirmedRegime == -1
    backgroundColor := color.new(color.red, 95)
else if confirmedRegime == -2
    backgroundColor := color.new(color.red, 90)
else
    backgroundColor := color.new(color.gray, 97)

// bgcolor MUST be global scope.
bgcolor(showBackground ? backgroundColor : na)


//=============================================================================
// 14. STRUCTURE LABELS
//=============================================================================

if showStructureLabels and bullBOS
    label.new(bar_index, low, "BOS UP", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)

if showStructureLabels and bearBOS
    label.new(bar_index, high, "BOS DOWN", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.tiny)

if showStructureLabels and bullCHoCH
    label.new(bar_index, low, "CHoCH UP", style=label.style_label_up, color=color.blue, textcolor=color.white, size=size.tiny)

if showStructureLabels and bearCHoCH
    label.new(bar_index, high, "CHoCH DOWN", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.tiny)


//=============================================================================
// 15. AGE RESEARCH LABELS
//=============================================================================

if showAgeLabels and age8
    label.new(bar_index, high, "AGE 8", style=label.style_label_down, color=color.purple, textcolor=color.white, size=size.tiny)

if showAgeLabels and age13
    label.new(bar_index, high, "AGE 13", style=label.style_label_down, color=color.purple, textcolor=color.white, size=size.tiny)

if showAgeLabels and age21
    label.new(bar_index, high, "AGE 21", style=label.style_label_down, color=color.purple, textcolor=color.white, size=size.tiny)


//=============================================================================
// 16. DASHBOARD
//=============================================================================

var table dash = table.new(position.top_right, 4, 18, border_width=1)

if showDashboard and barstate.islast

    //-------------------------------------------------------------------------
    // HEADER
    //-------------------------------------------------------------------------

    table.cell(dash, 0, 0, "MARKET REGIME", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, "VALUE", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 2, 0, "STATE", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 3, 0, "WEIGHT", bgcolor=color.black, text_color=color.white)

    //-------------------------------------------------------------------------
    // REGIME
    //-------------------------------------------------------------------------

    color regimeCellColor = color.gray

    if confirmedRegime > 0
        regimeCellColor := color.green
    else if confirmedRegime < 0
        regimeCellColor := color.red

    table.cell(dash, 0, 1, "REGIME")
    table.cell(dash, 1, 1, regimeName, bgcolor=regimeCellColor, text_color=color.white)
    table.cell(dash, 2, 1, str.tostring(regimeScore, "#.0"))
    table.cell(dash, 3, 1, "-100 / +100")

    //-------------------------------------------------------------------------
    // STAGE
    //-------------------------------------------------------------------------

    table.cell(dash, 0, 2, "STAGE")
    table.cell(dash, 1, 2, stageName)
    table.cell(dash, 2, 2, "Cycle")
    table.cell(dash, 3, 2, "Independent")

    //-------------------------------------------------------------------------
    // AGE
    //-------------------------------------------------------------------------

    table.cell(dash, 0, 3, "REGIME AGE")
    table.cell(dash, 1, 3, str.tostring(regimeAge) + " bars")

    string ageState = "NORMAL"

    if researchCheckpoint
        ageState := "RESEARCH"

    table.cell(dash, 2, 3, ageState)
    table.cell(dash, 3, 3, "8 / 13 / 21")

    //-------------------------------------------------------------------------
    // SMA
    //-------------------------------------------------------------------------

    string smaState = "AT SMA"

    if close > sma20
        smaState := "ABOVE"
    else if close < sma20
        smaState := "BELOW"

    table.cell(dash, 0, 4, "20 SMA")
    table.cell(dash, 1, 4, smaState)
    table.cell(dash, 2, 4, str.tostring(priceScore, "#.0"))
    table.cell(dash, 3, 4, "+/-15")

    //-------------------------------------------------------------------------
    // SLOPE
    //-------------------------------------------------------------------------

    string slopeState = "FLAT"

    if smaRising
        slopeState := "RISING"
    else if smaFalling
        slopeState := "FALLING"

    table.cell(dash, 0, 5, "SMA SLOPE")
    table.cell(dash, 1, 5, slopeState)
    table.cell(dash, 2, 5, str.tostring(smaSlope, "#.##") + " ATR")
    table.cell(dash, 3, 5, "+/-15")

    //-------------------------------------------------------------------------
    // RVOL
    //-------------------------------------------------------------------------

    string rvolState = "NORMAL"

    if highRVOL
        rvolState := "HIGH"

    table.cell(dash, 0, 6, "RVOL")
    table.cell(dash, 1, 6, str.tostring(rvol, "#.##") + "x")
    table.cell(dash, 2, 6, rvolState)
    table.cell(dash, 3, 6, "+/-10")

    //-------------------------------------------------------------------------
    // DISPLACEMENT
    //-------------------------------------------------------------------------

    string displacementState = "NORMAL"

    if bullishDisplacement
        displacementState := "BULL IMPULSE"
    else if bearishDisplacement
        displacementState := "BEAR IMPULSE"

    table.cell(dash, 0, 7, "DISPLACEMENT")
    table.cell(dash, 1, 7, str.tostring(displacement, "#.##") + " ATR")
    table.cell(dash, 2, 7, displacementState)
    table.cell(dash, 3, 7, "+/-10")

    //-------------------------------------------------------------------------
    // BOS
    //-------------------------------------------------------------------------

    string bosState = "NONE"

    if recentBullBOS
        if not recentBearBOS
            bosState := "BULLISH"

    if recentBearBOS
        if not recentBullBOS
            bosState := "BEARISH"

    table.cell(dash, 0, 8, "BOS")
    table.cell(dash, 1, 8, bosState)
    table.cell(dash, 2, 8, str.tostring(bosScore, "#.0"))
    table.cell(dash, 3, 8, "+/-20")

    //-------------------------------------------------------------------------
    // CHoCH
    //-------------------------------------------------------------------------

    string chochState = "NONE"

    if recentBullCHoCH
        if not recentBearCHoCH
            chochState := "BULLISH"

    if recentBearCHoCH
        if not recentBullCHoCH
            chochState := "BEARISH"

    table.cell(dash, 0, 9, "CHoCH")
    table.cell(dash, 1, 9, chochState)
    table.cell(dash, 2, 9, str.tostring(chochScore, "#.0"))
    table.cell(dash, 3, 9, "+/-10")

    //-------------------------------------------------------------------------
    // ADX
    //-------------------------------------------------------------------------

    string adxState = "RANGE"

    if adxTrending
        adxState := "TRENDING"

    table.cell(dash, 0, 10, "ADX")
    table.cell(dash, 1, 10, str.tostring(adx, "#.0"))
    table.cell(dash, 2, 10, adxState)
    table.cell(dash, 3, 10, "+/-5")

    //-------------------------------------------------------------------------
    // FVG
    //-------------------------------------------------------------------------

    string fvgState = "NONE"

    if recentBullFVG
        if not recentBearFVG
            fvgState := "BULLISH"

    if recentBearFVG
        if not recentBullFVG
            fvgState := "BEARISH"

    table.cell(dash, 0, 11, "FVG")
    table.cell(dash, 1, 11, fvgState)
    table.cell(dash, 2, 11, str.tostring(fvgScore, "#.0"))
    table.cell(dash, 3, 11, "+/-2.5")

    //-------------------------------------------------------------------------
    // ORDER BLOCK
    //-------------------------------------------------------------------------

    string obState = "NONE"

    if bullOBActive
        if not bearOBActive
            obState := "BULLISH"

    if bearOBActive
        if not bullOBActive
            obState := "BEARISH"

    table.cell(dash, 0, 12, "ORDER BLOCK")
    table.cell(dash, 1, 12, obState)
    table.cell(dash, 2, 12, str.tostring(obScore, "#.0"))
    table.cell(dash, 3, 12, "+/-2.5")

    //-------------------------------------------------------------------------
    // DISTANCE FROM SMA
    //-------------------------------------------------------------------------

    string extensionState = "NORMAL"

    if math.abs(distanceFromSMA) >= 2.0
        extensionState := "EXTENDED"
    else if math.abs(distanceFromSMA) >= 1.0
        extensionState := "ELEVATED"

    table.cell(dash, 0, 13, "SMA DISTANCE")
    table.cell(dash, 1, 13, str.tostring(distanceFromSMA, "#.##") + " ATR")
    table.cell(dash, 2, 13, extensionState)
    table.cell(dash, 3, 13, "Location")

    //-------------------------------------------------------------------------
    // COHORT 5 BAR
    //-------------------------------------------------------------------------

    float activeWin5 = na
    float activeAvg5 = na
    int activeSamples5 = 0

    if regimeAge >= 21
        activeWin5 := winPct21_5
        activeAvg5 := avg21_5
        activeSamples5 := samples21_5
    else if regimeAge >= 13
        activeWin5 := winPct13_5
        activeAvg5 := avg13_5
        activeSamples5 := samples13_5
    else
        activeWin5 := winPct8_5
        activeAvg5 := avg8_5
        activeSamples5 := samples8_5

    string cohort5Text = "N/A"

    if not na(activeWin5)
        cohort5Text := str.tostring(activeWin5, "#.0") + "%"

    string cohort5Avg = "N/A"

    if not na(activeAvg5)
        cohort5Avg := str.tostring(activeAvg5, "#.##") + "%"

    table.cell(dash, 0, 14, "COHORT +5")
    table.cell(dash, 1, 14, cohort5Text)
    table.cell(dash, 2, 14, cohort5Avg)
    table.cell(dash, 3, 14, "N=" + str.tostring(activeSamples5))

    //-------------------------------------------------------------------------
    // COHORT 10 BAR
    //-------------------------------------------------------------------------

    float activeWin10 = na
    float activeAvg10 = na
    int activeSamples10 = 0

    if regimeAge >= 21
        activeWin10 := winPct21_10
        activeAvg10 := avg21_10
        activeSamples10 := samples21_10
    else if regimeAge >= 13
        activeWin10 := winPct13_10
        activeAvg10 := avg13_10
        activeSamples10 := samples13_10
    else
        activeWin10 := winPct8_10
        activeAvg10 := avg8_10
        activeSamples10 := samples8_10

    string cohort10Text = "N/A"

    if not na(activeWin10)
        cohort10Text := str.tostring(activeWin10, "#.0") + "%"

    string cohort10Avg = "N/A"

    if not na(activeAvg10)
        cohort10Avg := str.tostring(activeAvg10, "#.##") + "%"

    table.cell(dash, 0, 15, "COHORT +10")
    table.cell(dash, 1, 15, cohort10Text)
    table.cell(dash, 2, 15, cohort10Avg)
    table.cell(dash, 3, 15, "N=" + str.tostring(activeSamples10))

    //-------------------------------------------------------------------------
    // COHORT 20 BAR
    //-------------------------------------------------------------------------

    float activeWin20 = na
    float activeAvg20 = na
    int activeSamples20 = 0

    if regimeAge >= 21
        activeWin20 := winPct21_20
        activeAvg20 := avg21_20
        activeSamples20 := samples21_20
    else if regimeAge >= 13
        activeWin20 := winPct13_20
        activeAvg20 := avg13_20
        activeSamples20 := samples13_20
    else
        activeWin20 := winPct8_20
        activeAvg20 := avg8_20
        activeSamples20 := samples8_20

    string cohort20Text = "N/A"

    if not na(activeWin20)
        cohort20Text := str.tostring(activeWin20, "#.0") + "%"

    string cohort20Avg = "N/A"

    if not na(activeAvg20)
        cohort20Avg := str.tostring(activeAvg20, "#.##") + "%"

    table.cell(dash, 0, 16, "COHORT +20")
    table.cell(dash, 1, 16, cohort20Text)
    table.cell(dash, 2, 16, cohort20Avg)
    table.cell(dash, 3, 16, "N=" + str.tostring(activeSamples20))

    //-------------------------------------------------------------------------
    // OVERALL
    //-------------------------------------------------------------------------

    table.cell(dash, 0, 17, "OVERALL", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 17, regimeName, bgcolor=regimeCellColor, text_color=color.white)
    table.cell(dash, 2, 17, stageName)
    table.cell(dash, 3, 17, "Age " + str.tostring(regimeAge))


//=============================================================================
// 17. ALERTS
//=============================================================================

alertcondition(regimeChanged and confirmedRegime == 2, "Strong Bull Regime", "Market regime changed to STRONG BULL.")

alertcondition(regimeChanged and confirmedRegime == 1, "Bull Regime", "Market regime changed to BULL.")

alertcondition(regimeChanged and confirmedRegime == -1, "Bear Regime", "Market regime changed to BEAR.")

alertcondition(regimeChanged and confirmedRegime == -2, "Strong Bear Regime", "Market regime changed to STRONG BEAR.")

alertcondition(regimeChanged and confirmedRegime == 0, "Range Regime", "Market regime changed to RANGE.")

alertcondition(bullBOS, "Bullish BOS", "Bullish Break of Structure detected.")

alertcondition(bearBOS, "Bearish BOS", "Bearish Break of Structure detected.")

alertcondition(bullCHoCH, "Bullish CHoCH", "Bullish Change of Character detected.")

alertcondition(bearCHoCH, "Bearish CHoCH", "Bearish Change of Character detected.")

alertcondition(age8, "Regime Age 8", "Current regime reached age 8.")

alertcondition(age13, "Regime Age 13", "Current regime reached age 13.")

alertcondition(age21, "Regime Age 21", "Current regime reached age 21.")
````
