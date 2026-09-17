<!-- tradingview-pine-id: PUB;cd6c05d659fa4c4fb444819885c43bcb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Shift Pulse

Source: https://www.tradingview.com/script/hS1ZVQu4-Liquidity-Shift-Pulse/

## Description

Is a price-structure and liquidity-based overlay indicator designed to identify selected bullish transition and expansion conditions, then manage the resulting long-side state using protected market structure.

The indicator is built around price behavior, confirmed swing structure, volatility normalization, participation, and market-regime conditions. It does not use moving-average crossovers, RSI, MACD, or ADX as signal generators.

1. Purpose

LSP is intended to help traders visually study two different types of bullish price behavior:

Liquidity Shift Entry
Looks for a downside liquidity sweep followed by a reclaim, bullish displacement, and a break of internal price structure.
Expansion Entry
Looks for a strong bullish breakout from an established price range when candle expansion, participation, and market-regime conditions support the move.

These two engines serve different purposes. The liquidity engine focuses on transitions that begin around previously confirmed swing liquidity, while the expansion engine allows the indicator to recognize strong directional breaks even when no recent liquidity sweep is present.

2. Liquidity Shift Logic

The indicator tracks confirmed swing highs and swing lows using pivot-based structure.

For a bullish liquidity setup, price must first trade below a previously confirmed swing low by a configurable ATR-normalized amount and then reclaim that level. The candle must also show sufficient lower-wick rejection.

After the sweep, the script stores the relevant internal structure level and waits for bullish confirmation within the configured setup window.

Confirmation requires several elements:

A valid liquidity sweep and reclaim.
Bullish candle displacement.
Minimum candle range relative to ATR.
Minimum candle-body proportion.
Strong closing location within the candle.
A close above the stored internal structure level.
Optional relative-volume confirmation.
Optional market-regime confirmation.

A setup that becomes too old or moves materially below its sweep low is invalidated.

3. Expansion Entry

The Expansion Entry engine is designed for a different market condition.

Instead of requiring a prior liquidity sweep, it looks for price to close above the highest high of a configurable previous range.

The breakout candle must meet configurable requirements for:

Breakout distance.
Range expansion relative to ATR.
Candle-body proportion.
Closing strength.
Relative volume, when available and enabled.
Market-regime conditions.

The Expansion Entry can be disabled independently from the liquidity-shift engine.

4. Participation Filter

LSP can compare current volume with a previous rolling volume baseline.

The resulting relative-volume measurement can be used to prevent an entry condition from being accepted when participation is below the selected threshold.

If usable volume data is unavailable for the symbol, the script does not treat missing volume as automatic confirmation failure.

5. Market Regime Filter

The optional regime filter uses a Choppiness Index calculation to distinguish more directional conditions from highly compressed or irregular environments.

The filter can accept either:

A sufficiently directional market, or
A market whose choppiness is decreasing while remaining below the configured transition threshold.

This component is used as a contextual filter rather than as an independent trading signal.

6. Protected Structure

After a BUY condition is confirmed, LSP establishes a Protected Structure level below price.

As new confirmed higher pivot lows form after entry, this protected level can move upward.

An important design characteristic is that Protected Structure is one-directional during an active long state:

It can move higher, but it does not move lower.

This creates a visual representation of the price structure that the active bullish condition is attempting to preserve.

7. SELL / Exit Logic

The SELL label in LSP represents an exit from an active long-side state, not an independent short-entry signal.

A SELL can occur when one of the following conditions is confirmed:

Price closes below Protected Structure.
A bearish liquidity reversal develops after sufficient favorable movement.
A large established move gives back more than the configured percentage of its maximum open favorable excursion and receives bearish candle confirmation.

Because SELL conditions are evaluated only while the script is in an active long state, users should not interpret SELL labels as standalone short recommendations.

8. Large-Trend Protection

For unusually extended favorable moves, the script tracks:

Entry price.
ATR at entry.
Highest price reached since entry.
Maximum favorable movement.
Current remaining favorable movement.
Percentage of the maximum move that has been given back.

Once the move exceeds the selected ATR activation threshold, the optional profit-protection logic can react to excessive giveback accompanied by bearish price behavior.

This feature is intended as structural protection logic rather than a profit target.

9. Main Settings

The script provides controls for:

Liquidity Engine

Pivot sensitivity
ATR period
Minimum sweep penetration
Minimum rejection wick

Structure Shift

Internal structure length
Setup memory
Structure-break buffer
Displacement range
Candle-body strength
Closing strength
Setup invalidation

Expansion Entry

Enable/disable expansion entries
Breakout lookback
Breakout buffer
Expansion range
Body requirement
Closing strength

Participation

Relative-volume filter
Volume baseline
Minimum relative volume

Market Regime

Choppiness filter
Choppiness period
Directional threshold
Transition threshold

Exit Protection

Initial structure buffer
Higher-low protection buffer
Bearish reversal activation
Large-trend activation
Maximum profit giveback

Visuals

Protected Structure
Confirmed liquidity levels
Liquidity sweep markers
BUY/SELL labels
Signal distance from price
10. Alerts

Alert conditions are included for:

Bullish liquidity sweep
Liquidity-shift BUY
Expansion BUY
Combined BUY
Bearish liquidity shift
SELL

Users can create TradingView alerts from these conditions according to their own workflow.

11. Confirmation and Repainting Behavior

LSP evaluates its principal signal conditions on confirmed bars.

Swing liquidity levels are based on confirmed pivot highs and pivot lows. Because pivot confirmation requires bars to form to the right of the potential swing, these levels inherently appear with confirmation delay.

This is intentional: a swing is not treated as confirmed before the required right-side bars exist.

The script does not use future-looking data or lookahead logic to generate historical signals. Once a BUY or SELL event has been confirmed on a closed bar, the script does not intentionally relocate that historical signal.

Users should distinguish this from normal real-time chart behavior: values and conditions on the currently open candle can change until that candle closes.

12. How to Use

LSP is best interpreted as a structured market-analysis framework, rather than as a standalone mechanical trading system.

Possible uses include:

Identifying liquidity-reclaim transitions.
Identifying strong structural expansion events.
Monitoring whether a bullish structure remains intact.
Visualizing progressively higher protected structure.
Creating alerts for selected liquidity and structural events.
Combining LSP with a trader's own risk management, higher-timeframe analysis, and broader market context.

Different markets and timeframes have different volatility and liquidity characteristics, so the default parameters should not be assumed to be optimal for every instrument.

13. Design Approach

The script combines several price-action concepts for a specific workflow rather than simply stacking unrelated indicators.

Its sequence is designed around:

Liquidity interaction → reclaim → displacement → structure confirmation → protected structure management

with a separate expansion path for strong structural breakouts.

The purpose of combining these components is to distinguish initial bullish qualification from subsequent structure management and exit conditions within one consistent state model.

14. Limitations

Liquidity Shift Pulse is an analytical indicator, not a strategy or automated trading system.

It does not predict future prices and does not guarantee that a liquidity sweep, breakout, BUY, SELL, or protected-structure event will lead to a profitable outcome.

Important limitations include:

Pivot-based swing detection introduces confirmation delay.
Strong trends can produce false breakouts.
Liquidity sweeps can fail after reclaiming a level.
Choppy markets can create repeated structural transitions.
Volume quality varies between instruments and data sources.
ATR normalization adapts measurements to volatility but does not make different markets behaviorally identical.
Protected Structure is a price-structure reference, not a guaranteed stop level.
Historical observations do not establish future performance.

The indicator should therefore be used together with independent analysis and appropriate risk management.

---

## Source Code

````pine
//@version=6
indicator(
    title = "Liquidity Shift Pulse",
    shorttitle = "LSP",
    overlay = true,
    max_labels_count = 300
)

// ============================================================================
// LIQUIDITY SHIFT PULSE [LSP] - V2.1
// ----------------------------------------------------------------------------
// Two complementary long-entry engines:
//
// 1. Liquidity Shift Entry
//    Sweep -> Reclaim -> Displacement -> Internal Structure Break.
//
// 2. Expansion Entry
//    Strong breakout from established price structure when participation
//    and market-regime conditions confirm the move.
//
// HOLD:
// - Confirmed higher lows raise Protected Structure.
// - Protected Structure never moves lower during an active trade.
//
// SELL:
// - Confirmed break below Protected Structure.
// - Bearish liquidity reversal.
// - Large-profit giveback protection after an exceptional trend.
//
// No MA crossover.
// No RSI.
// No MACD.
// No ADX.
// No candle recoloring.
// Signals use confirmed bars.
// ============================================================================


// ============================================================================
// INPUT GROUPS
// ============================================================================

string GROUP_LIQUIDITY = "Liquidity Engine"
string GROUP_SHIFT     = "Structure Shift"
string GROUP_EXPANSION = "Expansion Entry"
string GROUP_VOLUME    = "Participation"
string GROUP_REGIME    = "Market Regime"
string GROUP_EXIT      = "Exit Protection"
string GROUP_VISUALS   = "Visuals"


// ============================================================================
// LIQUIDITY ENGINE
// ============================================================================

int pivotLeft = input.int(
    defval = 2,
    title = "Pivot Left Bars",
    minval = 1,
    maxval = 10,
    group = GROUP_LIQUIDITY,
    tooltip = "Controls confirmed swing sensitivity. Lower values react faster."
)

int pivotRight = input.int(
    defval = 2,
    title = "Pivot Right Bars",
    minval = 1,
    maxval = 10,
    group = GROUP_LIQUIDITY,
    tooltip = "Number of bars required to confirm a swing."
)

int atrLength = input.int(
    defval = 14,
    title = "ATR Period",
    minval = 5,
    maxval = 100,
    group = GROUP_LIQUIDITY
)

float sweepPenetrationATR = input.float(
    defval = 0.01,
    title = "Minimum Sweep Penetration",
    minval = 0.00,
    maxval = 1.00,
    step = 0.01,
    group = GROUP_LIQUIDITY,
    tooltip = "Minimum penetration beyond confirmed liquidity measured in ATR."
)

float minimumSweepWickRatio = input.float(
    defval = 0.10,
    title = "Minimum Sweep Wick",
    minval = 0.00,
    maxval = 0.80,
    step = 0.05,
    group = GROUP_LIQUIDITY,
    tooltip = "Minimum rejection wick relative to candle range."
)


// ============================================================================
// STRUCTURE SHIFT
// ============================================================================

int internalStructureLength = input.int(
    defval = 5,
    title = "Internal Structure Length",
    minval = 3,
    maxval = 20,
    group = GROUP_SHIFT
)

int setupWindow = input.int(
    defval = 18,
    title = "Liquidity Setup Memory",
    minval = 3,
    maxval = 50,
    group = GROUP_SHIFT,
    tooltip = "Maximum number of bars allowed between a liquidity sweep and bullish confirmation."
)

float structureBreakBufferATR = input.float(
    defval = 0.02,
    title = "Structure Break Buffer",
    minval = 0.00,
    maxval = 1.00,
    step = 0.01,
    group = GROUP_SHIFT
)

float minimumDisplacementATR = input.float(
    defval = 0.65,
    title = "Minimum Displacement Range",
    minval = 0.30,
    maxval = 4.00,
    step = 0.05,
    group = GROUP_SHIFT
)

float minimumBodyRatio = input.float(
    defval = 0.40,
    title = "Minimum Displacement Body",
    minval = 0.20,
    maxval = 0.95,
    step = 0.05,
    group = GROUP_SHIFT
)

float minimumCloseStrength = input.float(
    defval = 0.62,
    title = "Minimum Close Strength",
    minval = 0.50,
    maxval = 0.95,
    step = 0.01,
    group = GROUP_SHIFT
)

float setupInvalidationATR = input.float(
    defval = 0.45,
    title = "Setup Invalidation Buffer",
    minval = 0.05,
    maxval = 2.00,
    step = 0.05,
    group = GROUP_SHIFT
)


// ============================================================================
// EXPANSION ENTRY
// ============================================================================

bool useExpansionEntry = input.bool(
    defval = true,
    title = "Enable Expansion Entry",
    group = GROUP_EXPANSION,
    tooltip = "Allows LSP to capture strong breakouts even when a recent liquidity sweep is absent."
)

int expansionLookback = input.int(
    defval = 20,
    title = "Expansion Structure",
    minval = 10,
    maxval = 100,
    group = GROUP_EXPANSION,
    tooltip = "Price must break the highest high of this previous range."
)

float expansionBreakBufferATR = input.float(
    defval = 0.03,
    title = "Expansion Break Buffer",
    minval = 0.00,
    maxval = 1.00,
    step = 0.01,
    group = GROUP_EXPANSION
)

float expansionMinimumATR = input.float(
    defval = 0.95,
    title = "Expansion Candle Range",
    minval = 0.40,
    maxval = 4.00,
    step = 0.05,
    group = GROUP_EXPANSION
)

float expansionBodyRatio = input.float(
    defval = 0.48,
    title = "Expansion Candle Body",
    minval = 0.20,
    maxval = 0.95,
    step = 0.01,
    group = GROUP_EXPANSION
)

float expansionCloseStrength = input.float(
    defval = 0.65,
    title = "Expansion Close Strength",
    minval = 0.50,
    maxval = 0.95,
    step = 0.01,
    group = GROUP_EXPANSION
)


// ============================================================================
// PARTICIPATION
// ============================================================================

bool useVolumeFilter = input.bool(
    defval = true,
    title = "Use Relative Volume",
    group = GROUP_VOLUME
)

int volumeLength = input.int(
    defval = 20,
    title = "Volume Baseline",
    minval = 5,
    maxval = 100,
    group = GROUP_VOLUME
)

float minimumRelativeVolume = input.float(
    defval = 0.90,
    title = "Minimum Relative Volume",
    minval = 0.50,
    maxval = 5.00,
    step = 0.05,
    group = GROUP_VOLUME,
    tooltip = "Current volume relative to the previous volume baseline."
)


// ============================================================================
// MARKET REGIME
// ============================================================================

bool useRegimeFilter = input.bool(
    defval = true,
    title = "Use Choppiness Filter",
    group = GROUP_REGIME
)

int chopLength = input.int(
    defval = 14,
    title = "Choppiness Period",
    minval = 5,
    maxval = 50,
    group = GROUP_REGIME
)

float directionalChoppiness = input.float(
    defval = 55.0,
    title = "Directional Threshold",
    minval = 30.0,
    maxval = 70.0,
    step = 0.1,
    group = GROUP_REGIME
)

float maximumChoppiness = input.float(
    defval = 65.0,
    title = "Maximum Transition Threshold",
    minval = 40.0,
    maxval = 80.0,
    step = 0.1,
    group = GROUP_REGIME
)


// ============================================================================
// EXIT PROTECTION
// ============================================================================

float initialProtectionBufferATR = input.float(
    defval = 0.25,
    title = "Initial Protection Buffer",
    minval = 0.00,
    maxval = 2.00,
    step = 0.05,
    group = GROUP_EXIT
)

float protectedLowBufferATR = input.float(
    defval = 0.20,
    title = "Higher-Low Protection Buffer",
    minval = 0.00,
    maxval = 1.00,
    step = 0.05,
    group = GROUP_EXIT
)

int reversalWindow = input.int(
    defval = 7,
    title = "Bearish Reversal Window",
    minval = 2,
    maxval = 20,
    group = GROUP_EXIT
)

float minimumProfitForReversalATR = input.float(
    defval = 2.00,
    title = "Bearish Reversal Activation",
    minval = 0.00,
    maxval = 10.00,
    step = 0.10,
    group = GROUP_EXIT
)

bool enableLargeProfitProtection = input.bool(
    defval = true,
    title = "Protect Large Trends",
    group = GROUP_EXIT
)

float largeProfitActivationATR = input.float(
    defval = 4.00,
    title = "Large Trend Activation",
    minval = 1.00,
    maxval = 15.00,
    step = 0.25,
    group = GROUP_EXIT
)

float maximumProfitGiveback = input.float(
    defval = 30.0,
    title = "Maximum Profit Giveback %",
    minval = 10.0,
    maxval = 70.0,
    step = 1.0,
    group = GROUP_EXIT
)


// ============================================================================
// VISUALS
// ============================================================================

bool showProtectedStructure = input.bool(
    defval = true,
    title = "Show Protected Structure",
    group = GROUP_VISUALS
)

bool showLiquidityLevels = input.bool(
    defval = false,
    title = "Show Liquidity Levels",
    group = GROUP_VISUALS
)

bool showSweepMarkers = input.bool(
    defval = false,
    title = "Show Liquidity Sweeps",
    group = GROUP_VISUALS
)

bool showSignals = input.bool(
    defval = true,
    title = "Show BUY / SELL",
    group = GROUP_VISUALS
)

float signalDistanceATR = input.float(
    defval = 0.35,
    title = "Signal Distance",
    minval = 0.10,
    maxval = 2.00,
    step = 0.05,
    group = GROUP_VISUALS
)


// ============================================================================
// PERSISTENT STATE
// ============================================================================
//
// All persistent variables are declared BEFORE any logic uses them.
// This avoids undeclared-identifier problems and keeps state management clear.
// ============================================================================


// Liquidity references

var float lastSwingHigh = na
var float lastSwingLow = na


// Bullish setup state

var bool bullishSetupActive = false
var int bullishSweepBar = na
var float bullishSweepLow = na
var float bullishBreakLevel = na


// Long trade state

var bool inLong = false
var int entryBar = na
var float entryPrice = na
var float entryATR = na
var float highestSinceEntry = na
var float protectedLow = na


// Bearish reversal state

var bool bearishSetupActive = false
var int bearishSweepBar = na
var float bearishSweepHigh = na
var float bearishBreakLevel = na


// ============================================================================
// BASIC CALCULATIONS
// ============================================================================

float atr = ta.atr(atrLength)

float candleRange = high - low
float candleBody = math.abs(close - open)

float bodyRatio = 0.0

if candleRange > 0.0
    bodyRatio := candleBody / candleRange


float bullishCloseLocation = 0.50
float bearishCloseLocation = 0.50

if candleRange > 0.0
    bullishCloseLocation := (close - low) / candleRange
    bearishCloseLocation := (high - close) / candleRange


float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)

float lowerWickRatio = 0.0
float upperWickRatio = 0.0

if candleRange > 0.0
    lowerWickRatio := lowerWick / candleRange
    upperWickRatio := upperWick / candleRange


float candleRangeATR = 0.0

if not na(atr) and atr > 0.0
    candleRangeATR := candleRange / atr


// ============================================================================
// CONFIRMED SWINGS
// ============================================================================

float confirmedPivotHigh = ta.pivothigh(
    high,
    pivotLeft,
    pivotRight
)

float confirmedPivotLow = ta.pivotlow(
    low,
    pivotLeft,
    pivotRight
)


// ============================================================================
// RELATIVE VOLUME
// ============================================================================

float averageVolume = ta.sma(volume, volumeLength)[1]

float relativeVolume = 1.0

bool volumeAvailable = (
    not na(volume) and
    not na(averageVolume) and
    averageVolume > 0.0
)

if volumeAvailable
    relativeVolume := volume / averageVolume


bool volumeConfirmed = true

if useVolumeFilter and volumeAvailable
    volumeConfirmed := relativeVolume >= minimumRelativeVolume


// ============================================================================
// CHOPPINESS INDEX
// ============================================================================

float trueRange = ta.tr(true)

float trueRangeSum = ta.sma(
    trueRange,
    chopLength
) * chopLength

float chopHigh = ta.highest(
    high,
    chopLength
)

float chopLow = ta.lowest(
    low,
    chopLength
)

float chopRange = chopHigh - chopLow

float choppiness = na

if (
    not na(trueRangeSum) and
    trueRangeSum > 0.0 and
    chopRange > 0.0
)
    choppiness := 100.0 * math.log(trueRangeSum / chopRange) / math.log(chopLength)


// ============================================================================
// MARKET REGIME
// ============================================================================

bool regimeConfirmed = true

if useRegimeFilter

    regimeConfirmed := false

    if not na(choppiness)

        bool directionalMarket = choppiness <= directionalChoppiness

        bool leavingCompression = (
            choppiness <= maximumChoppiness and
            choppiness < choppiness[1]
        )

        regimeConfirmed := directionalMarket or leavingCompression


// ============================================================================
// INTERNAL STRUCTURE
// ============================================================================

float currentInternalHigh = ta.highest(
    high[1],
    internalStructureLength
)

float currentInternalLow = ta.lowest(
    low[1],
    internalStructureLength
)


// ============================================================================
// LIQUIDITY SWEEPS
// ============================================================================

bool bullishLiquiditySweep = false

if (
    barstate.isconfirmed and
    not na(lastSwingLow) and
    not na(atr)
)

    bool penetratedLow = low < lastSwingLow - atr * sweepPenetrationATR
    bool reclaimedLow = close > lastSwingLow
    bool validLowerWick = lowerWickRatio >= minimumSweepWickRatio

    bullishLiquiditySweep := penetratedLow and reclaimedLow and validLowerWick


bool bearishLiquiditySweep = false

if (
    barstate.isconfirmed and
    not na(lastSwingHigh) and
    not na(atr)
)

    bool penetratedHigh = high > lastSwingHigh + atr * sweepPenetrationATR
    bool rejectedHigh = close < lastSwingHigh
    bool validUpperWick = upperWickRatio >= minimumSweepWickRatio

    bearishLiquiditySweep := penetratedHigh and rejectedHigh and validUpperWick


// ============================================================================
// CREATE BULLISH LIQUIDITY SETUP
// ============================================================================

if (
    not inLong and
    bullishLiquiditySweep and
    not na(currentInternalHigh)
)

    bullishSetupActive := true
    bullishSweepBar := bar_index
    bullishSweepLow := low
    bullishBreakLevel := currentInternalHigh


// ============================================================================
// BULLISH SETUP AGE
// ============================================================================

int bullishSetupAge = 100000

if bullishSetupActive and not na(bullishSweepBar)
    bullishSetupAge := bar_index - bullishSweepBar


// ============================================================================
// INVALIDATE BULLISH SETUP
// ============================================================================

bool bullishSetupExpired = bullishSetupActive and bullishSetupAge > setupWindow

bool bullishSetupFailed = false

if bullishSetupActive and not na(bullishSweepLow)
    bullishSetupFailed := close < bullishSweepLow - atr * setupInvalidationATR


if bullishSetupExpired or bullishSetupFailed

    bullishSetupActive := false
    bullishSweepBar := na
    bullishSweepLow := na
    bullishBreakLevel := na


// ============================================================================
// LIQUIDITY-SHIFT ENTRY
// ============================================================================

bool bullishDisplacement = (
    close > open and
    candleRangeATR >= minimumDisplacementATR and
    bodyRatio >= minimumBodyRatio and
    bullishCloseLocation >= minimumCloseStrength
)

bool bullishStructureShift = false

if bullishSetupActive and not na(bullishBreakLevel)
    bullishStructureShift := close > bullishBreakLevel + atr * structureBreakBufferATR


bool liquidityBuySignal = (
    barstate.isconfirmed and
    not inLong and
    bullishSetupActive and
    bullishSetupAge <= setupWindow and
    bullishDisplacement and
    bullishStructureShift and
    volumeConfirmed and
    regimeConfirmed
)


// ============================================================================
// EXPANSION ENTRY
// ============================================================================

float expansionReferenceHigh = ta.highest(
    high[1],
    expansionLookback
)

bool expansionPriceBreak = (
    close >
    expansionReferenceHigh +
    atr * expansionBreakBufferATR
)

bool expansionCandle = (
    close > open and
    candleRangeATR >= expansionMinimumATR and
    bodyRatio >= expansionBodyRatio and
    bullishCloseLocation >= expansionCloseStrength
)

bool expansionRegime = regimeConfirmed

if useRegimeFilter and not na(choppiness)
    expansionRegime := regimeConfirmed and choppiness < choppiness[1]


bool expansionBuySignal = (
    barstate.isconfirmed and
    not inLong and
    useExpansionEntry and
    not na(expansionReferenceHigh) and
    expansionPriceBreak and
    expansionCandle and
    volumeConfirmed and
    expansionRegime
)


// ============================================================================
// FINAL BUY
// ============================================================================

bool buySignal = liquidityBuySignal or expansionBuySignal


// ============================================================================
// INITIAL PROTECTION REFERENCE
// ============================================================================

float expansionInitialStructure = ta.lowest(
    low[1],
    internalStructureLength
)


// ============================================================================
// ENTER LONG
// ============================================================================

if buySignal

    inLong := true

    entryBar := bar_index
    entryPrice := close
    entryATR := atr
    highestSinceEntry := high

    if liquidityBuySignal and not na(bullishSweepLow)
        protectedLow := bullishSweepLow - atr * initialProtectionBufferATR
    else
        protectedLow := expansionInitialStructure - atr * initialProtectionBufferATR

    bullishSetupActive := false
    bullishSweepBar := na
    bullishSweepLow := na
    bullishBreakLevel := na

    bearishSetupActive := false
    bearishSweepBar := na
    bearishSweepHigh := na
    bearishBreakLevel := na


// ============================================================================
// TRACK MAXIMUM FAVORABLE PRICE
// ============================================================================

if inLong

    if na(highestSinceEntry)
        highestSinceEntry := high
    else
        highestSinceEntry := math.max(highestSinceEntry, high)


// ============================================================================
// MAXIMUM OPEN PROFIT
// ============================================================================

float maximumOpenProfit = 0.0

if (
    inLong and
    not na(highestSinceEntry) and
    not na(entryPrice)
)
    maximumOpenProfit := math.max(highestSinceEntry - entryPrice, 0.0)


float maximumOpenProfitATR = 0.0

if (
    inLong and
    not na(entryATR) and
    entryATR > 0.0
)
    maximumOpenProfitATR := maximumOpenProfit / entryATR


// ============================================================================
// CURRENT PROFIT GIVEBACK
// ============================================================================

float currentOpenProfit = 0.0

if inLong and not na(entryPrice)
    currentOpenProfit := math.max(close - entryPrice, 0.0)


float profitGivebackPercent = 0.0

if maximumOpenProfit > 0.0
    profitGivebackPercent := ((maximumOpenProfit - currentOpenProfit) / maximumOpenProfit) * 100.0


// ============================================================================
// PROTECTED HIGHER LOW
// ============================================================================
//
// Confirmed pivot lows after entry can raise Protected Structure.
//
// Protected Structure:
// - Can move UP.
// - Can never move DOWN.
// ============================================================================

if (
    inLong and
    not na(confirmedPivotLow) and
    not na(entryBar)
)

    int confirmedLowBar = bar_index - pivotRight

    if confirmedLowBar > entryBar

        float pivotATR = atr[pivotRight]
        float candidateProtectedLow = confirmedPivotLow

        if not na(pivotATR)
            candidateProtectedLow := confirmedPivotLow - pivotATR * protectedLowBufferATR

        bool validCandidate = candidateProtectedLow < close

        if validCandidate

            if na(protectedLow) or candidateProtectedLow > protectedLow
                protectedLow := candidateProtectedLow


// ============================================================================
// BEARISH LIQUIDITY REVERSAL SETUP
// ============================================================================

bool bearishReversalEligible = (
    inLong and
    maximumOpenProfitATR >= minimumProfitForReversalATR
)

if (
    bearishReversalEligible and
    bearishLiquiditySweep and
    not na(currentInternalLow)
)

    bearishSetupActive := true
    bearishSweepBar := bar_index
    bearishSweepHigh := high
    bearishBreakLevel := currentInternalLow


// ============================================================================
// BEARISH SETUP AGE
// ============================================================================

int bearishSetupAge = 100000

if bearishSetupActive and not na(bearishSweepBar)
    bearishSetupAge := bar_index - bearishSweepBar


// ============================================================================
// INVALIDATE BEARISH SETUP
// ============================================================================

bool bearishSetupExpired = bearishSetupActive and bearishSetupAge > reversalWindow

bool bearishSetupFailed = false

if bearishSetupActive and not na(bearishSweepHigh)
    bearishSetupFailed := close > bearishSweepHigh + atr * setupInvalidationATR


if bearishSetupExpired or bearishSetupFailed

    bearishSetupActive := false
    bearishSweepBar := na
    bearishSweepHigh := na
    bearishBreakLevel := na


// ============================================================================
// BEARISH DISPLACEMENT
// ============================================================================

bool bearishDisplacement = (
    close < open and
    candleRangeATR >= minimumDisplacementATR and
    bodyRatio >= minimumBodyRatio and
    bearishCloseLocation >= minimumCloseStrength
)


// ============================================================================
// BEARISH STRUCTURE SHIFT
// ============================================================================

bool bearishStructureShift = false

if bearishSetupActive and not na(bearishBreakLevel)
    bearishStructureShift := close < bearishBreakLevel - atr * structureBreakBufferATR


// ============================================================================
// PROTECTED STRUCTURE EXIT
// ============================================================================

bool protectedStructureBroken = false

if (
    inLong and
    not na(protectedLow) and
    not na(entryBar) and
    bar_index > entryBar
)

    protectedStructureBroken := close < protectedLow


// ============================================================================
// BEARISH LIQUIDITY SHIFT EXIT
// ============================================================================

bool bearishLiquidityShift = (
    barstate.isconfirmed and
    inLong and
    bearishSetupActive and
    bearishSetupAge <= reversalWindow and
    bearishDisplacement and
    bearishStructureShift
)


// ============================================================================
// LARGE TREND PROTECTION
// ============================================================================

bool largeTrendEstablished = (
    inLong and
    maximumOpenProfitATR >= largeProfitActivationATR
)

bool excessiveProfitGiveback = (
    largeTrendEstablished and
    profitGivebackPercent >= maximumProfitGiveback
)

bool bearishGivebackConfirmation = (
    close < open and
    close < close[1]
)

bool largeProfitExit = (
    enableLargeProfitProtection and
    excessiveProfitGiveback and
    bearishGivebackConfirmation
)


// ============================================================================
// FINAL SELL
// ============================================================================

bool sellSignal = (
    barstate.isconfirmed and
    inLong and
    (
        protectedStructureBroken or
        bearishLiquidityShift or
        largeProfitExit
    )
)


// ============================================================================
// EXIT LONG
// ============================================================================

if sellSignal

    inLong := false

    entryBar := na
    entryPrice := na
    entryATR := na
    highestSinceEntry := na
    protectedLow := na

    bearishSetupActive := false
    bearishSweepBar := na
    bearishSweepHigh := na
    bearishBreakLevel := na


// ============================================================================
// UPDATE CONFIRMED LIQUIDITY LEVELS
// ============================================================================
//
// Updates occur after current-bar sweep evaluation.
// This prevents a newly confirmed pivot from being used retroactively.
// ============================================================================

if not na(confirmedPivotHigh)
    lastSwingHigh := confirmedPivotHigh

if not na(confirmedPivotLow)
    lastSwingLow := confirmedPivotLow


// ============================================================================
// COLORS
// ============================================================================

color buyColor = color.rgb(
    0,
    180,
    120
)

color sellColor = color.rgb(
    220,
    65,
    80
)

color protectedColor = color.rgb(
    35,
    160,
    105
)

color liquidityHighColor = color.new(
    sellColor,
    72
)

color liquidityLowColor = color.new(
    buyColor,
    72
)


// ============================================================================
// PROTECTED STRUCTURE
// ============================================================================

plot(
    showProtectedStructure and inLong ? protectedLow : na,
    title = "Protected Structure",
    color = protectedColor,
    linewidth = 2,
    style = plot.style_linebr
)


// ============================================================================
// OPTIONAL LIQUIDITY LEVELS
// ============================================================================

plot(
    showLiquidityLevels ? lastSwingHigh : na,
    title = "High Liquidity",
    color = liquidityHighColor,
    linewidth = 1,
    style = plot.style_linebr
)

plot(
    showLiquidityLevels ? lastSwingLow : na,
    title = "Low Liquidity",
    color = liquidityLowColor,
    linewidth = 1,
    style = plot.style_linebr
)


// ============================================================================
// OPTIONAL SWEEP MARKERS
// ============================================================================

plotshape(
    showSweepMarkers and bullishLiquiditySweep,
    title = "Bullish Liquidity Sweep",
    style = shape.circle,
    location = location.belowbar,
    color = buyColor,
    size = size.tiny
)

plotshape(
    showSweepMarkers and bearishLiquiditySweep,
    title = "Bearish Liquidity Sweep",
    style = shape.circle,
    location = location.abovebar,
    color = sellColor,
    size = size.tiny
)


// ============================================================================
// BUY LABEL
// ============================================================================

if showSignals and buySignal

    label.new(
        bar_index,
        low - atr * signalDistanceATR,
        "BUY",
        yloc = yloc.price,
        style = label.style_label_up,
        color = buyColor,
        textcolor = color.white,
        size = size.small
    )


// ============================================================================
// SELL LABEL
// ============================================================================

if showSignals and sellSignal

    label.new(
        bar_index,
        high + atr * signalDistanceATR,
        "SELL",
        yloc = yloc.price,
        style = label.style_label_down,
        color = sellColor,
        textcolor = color.white,
        size = size.small
    )


// ============================================================================
// ALERTS
// ============================================================================

alertcondition(
    bullishLiquiditySweep,
    title = "LSP Bullish Liquidity Sweep",
    message = "Liquidity Shift Pulse detected a bullish liquidity sweep on {{ticker}} - {{interval}}."
)

alertcondition(
    liquidityBuySignal,
    title = "LSP Liquidity BUY",
    message = "Liquidity Shift Pulse confirmed a liquidity-shift BUY on {{ticker}} - {{interval}}."
)

alertcondition(
    expansionBuySignal,
    title = "LSP Expansion BUY",
    message = "Liquidity Shift Pulse confirmed an expansion BUY on {{ticker}} - {{interval}}."
)

alertcondition(
    buySignal,
    title = "LSP BUY",
    message = "Liquidity Shift Pulse BUY confirmed on {{ticker}} - {{interval}}."
)

alertcondition(
    bearishLiquidityShift,
    title = "LSP Bearish Liquidity Shift",
    message = "Liquidity Shift Pulse detected a bearish liquidity reversal on {{ticker}} - {{interval}}."
)

alertcondition(
    sellSignal,
    title = "LSP SELL",
    message = "Liquidity Shift Pulse SELL confirmed on {{ticker}} - {{interval}}."
)
````
