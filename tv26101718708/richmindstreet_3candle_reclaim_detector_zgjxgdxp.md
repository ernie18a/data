# RichMindStreet 3-Candle Reclaim Detector

- url: https://www.tradingview.com/script/zgjxgDXP-RichMindStreet-3-Candle-Reclaim-Detector/
- type: indicator
- pine_id: PUB;387cd32670a148d1af054e9b57d8d189
- version: 2.0

## Description

3-Candle Reclaim Detector

The 3-Candle Reclaim Detector is a price-action based TradingView indicator designed to identify potential bullish and bearish reclaim setups through a structured multi-step confirmation process.

🔹 How It Works

The indicator follows a simple sequence:

1️⃣ 3-Candle Reclaim
Identifies a three-candle reclaim pattern where:

Bullish: C1 is bearish, C2 sweeps below C1 low and reclaims it, followed by a bullish C3.
Bearish: C1 is bullish, C2 sweeps above C1 high and reclaims it, followed by a bearish C3.

2️⃣ Successive Invalidation
The setup remains valid only while price respects the C1 reference level. A confirmed candle close beyond the invalidation level fails the setup.

3️⃣ BOS Confirmation
The indicator waits for a confirmed break of structure. BOS is based on the close of the confirmed pivot candle, rather than its wick high/low.

4️⃣ BOS 50% Confirmation
After BOS, the immediate next confirmed candle must satisfy the 50% midpoint condition:

Bullish → closes at or above the BOS candle midpoint
Bearish → closes at or below the BOS candle midpoint

5️⃣ Trade Position Ready
Only after BOS 50% confirmation does the indicator display the trade position structure, including:

Entry
Stop Loss
TP1 — 1R
TP2 — configurable RR
Risk/reward visualization
📊 Trade Management

The indicator supports a configurable final RR target with a minimum of 1:1.

The trade statistics recognize 1R achievement as a winning trade. Therefore, a trade that reaches TP1/1R is counted as a win even if price subsequently returns to the stop.

🔔 Alert

The indicator provides a single primary alert:

TRADE POSITION READY

The alert is triggered when a valid setup completes the required BOS 50% confirmation and the trade-position setup becomes ready.

🎯 Designed For

This indicator is intended for traders who prefer structured price-action confirmation rather than entering solely on the initial reclaim pattern.

It can help organize the sequence:

3C RECLAIM → INVALIDATION CHECK → BOS → BOS 50% CONFIRMATION → TRADE POSITION READY

⚠️ Important

This indicator is a technical analysis and trade-setup visualization tool, not financial advice. Signals should be evaluated within your own trading plan, risk management rules, market conditions, and timeframe context.

## Source Code

````pine
//@version=6
indicator("3-Candle Reclaim Detector", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

//══════════════════════════════════════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════════════════════════════════════

groupPatterns = "3-Candle Reclaim"

enableBullish = input.bool(
     true,
     "Enable Bullish Reclaim",
     group=groupPatterns)

enableBearish = input.bool(
     true,
     "Enable Bearish Reclaim",
     group=groupPatterns)

// Setup arrows are compact and offset from the candle by default.
arrowOffsetPct = input.float(
     0.20,
     "Setup Arrow Offset (%)",
     minval=0.0,
     maxval=5.0,
     step=0.05,
     group=groupPatterns)


groupSteps = "Step Controls"

enableStep2 = input.bool(
     true,
     "Enable Successive Invalidation",
     group=groupSteps)

showFailedReclaims = input.bool(
     true,
     "Show Failed Reclaims",
     group=groupSteps)

enableStep3 = input.bool(
     true,
     "Enable BOS Confirmation",
     group=groupSteps)

enableStep4 = input.bool(
     true,
     "Enable BOS 50% Confirmation",
     group=groupSteps)


groupStructure = "Structure Settings"

structureSwingLength = input.int(
     3,
     "Structure Swing Length",
     minval=1,
     maxval=20,
     group=groupStructure)

showBOSLabel = input.bool(
     true,
     "Show BOS Labels",
     group=groupStructure)


groupTrade = "Trade Settings"

enableTrade = input.bool(
     true,
     "Enable Trade",
     group=groupTrade)

finalRR = input.float(
     2.0,
     "Final RR / TP2",
     minval=1.0,
     step=0.5,
     group=groupTrade)

showTradePosition = input.bool(
     true,
     "Show Trade Position",
     group=groupTrade)

showTradeLabels = input.bool(
     false,
     "Show Trade Price Labels",
     group=groupTrade)

// OFF by default to keep the chart clean.
showTradeResults = input.bool(
     false,
     "Show Trade Result Labels",
     group=groupTrade)


groupQuality = "Trade Quality Diagnostic"

showQualityDiagnostic = input.bool(
     true,
     "Show Trade Quality Diagnostic",
     group=groupQuality)

locationLookback = input.int(
     20,
     "Setup Location Lookback",
     minval=5,
     maxval=100,
     group=groupQuality)

locationCautionThreshold = input.float(
     70.0,
     "Location Caution Above (%)",
     minval=50.0,
     maxval=95.0,
     step=5.0,
     group=groupQuality)

locationExtremeThreshold = input.float(
     85.0,
     "Location Extended Above (%)",
     minval=60.0,
     maxval=100.0,
     step=5.0,
     group=groupQuality)


groupDisplay = "Display Filter"

displaySetupCount = input.int(
     5,
     "Show Last N Setups",
     minval=1,
     maxval=20,
     group=groupDisplay)


groupDashboard = "Dashboard"

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group=groupDashboard)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options=[
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left"
     ],
     group=groupDashboard)


//══════════════════════════════════════════════════════════════════════════════
// DISPLAY FILTER
//══════════════════════════════════════════════════════════════════════════════
// Only the latest N setups are retained and processed in memory.

bool barInsideDisplayWindow = true


// CONSTANTS
//══════════════════════════════════════════════════════════════════════════════

const int DIR_BULL = 1
const int DIR_BEAR = -1


//══════════════════════════════════════════════════════════════════════════════
// COLORS
//══════════════════════════════════════════════════════════════════════════════

// Active position
color ACTIVE_PROFIT_BG = color.new(color.green, 84)
color ACTIVE_PROFIT_BORDER = color.new(color.green, 45)

color ACTIVE_RISK_BG = color.new(color.red, 84)
color ACTIVE_RISK_BORDER = color.new(color.red, 45)

color ACTIVE_ENTRY_COLOR = color.blue
color ACTIVE_TP_COLOR = color.green
color ACTIVE_SL_COLOR = color.red


// Historical position
// Much lighter than the active trade.
color HISTORY_PROFIT_BG = color.new(color.green, 94)
color HISTORY_PROFIT_BORDER = color.new(color.green, 82)

color HISTORY_RISK_BG = color.new(color.red, 94)
color HISTORY_RISK_BORDER = color.new(color.red, 82)

color HISTORY_ENTRY_COLOR = color.new(color.blue, 65)
color HISTORY_TP_COLOR = color.new(color.green, 60)
color HISTORY_SL_COLOR = color.new(color.red, 60)


//══════════════════════════════════════════════════════════════════════════════
// SETUP ARRAYS
//══════════════════════════════════════════════════════════════════════════════

var array<int> setupDirections = array.new_int()
var array<float> setupLevels = array.new_float()
var array<float> setupSweepLevels = array.new_float()
var array<int> setupBars = array.new_int()
var array<label> setupLabels = array.new_label()

var array<float> setupStructureLevels = array.new_float()

var array<bool> setupBOSConfirmed = array.new_bool()
var array<int> setupBOSBars = array.new_int()
var array<float> setupBOSHighs = array.new_float()
var array<float> setupBOSLows = array.new_float()
var array<label> bosLabels = array.new_label()

var array<float> setupBOSMidpoints = array.new_float()
var array<bool> setup50Confirmed = array.new_bool()

// Trade Quality Diagnostic arrays.
// These are diagnostic only and do not block trades.
var array<float> setupBOSBodyScores = array.new_float()
var array<float> setupBOSCloseScores = array.new_float()
var array<float> setupBOSBreakScores = array.new_float()
var array<float> setup50Scores = array.new_float()
var array<float> setupQualityScores = array.new_float()

// Setup Location / Late Entry diagnostic arrays.
// Diagnostic only — these values do not block or filter trades.
var array<float> setupLocationPosition = array.new_float()
var array<float> setupLocationRoom = array.new_float()
var array<float> setupPreEntryMoveR = array.new_float()
var array<float> setupLocationRangeHigh = array.new_float()
var array<float> setupLocationRangeLow = array.new_float()

// Trade candidate state: qualified setups survive while another trade is active.
var array<bool> setupTradeCandidate = array.new_bool()
var array<float> setupTradeEntry = array.new_float()
var array<float> setupTradeSL = array.new_float()
var array<float> setupTradeRisk = array.new_float()
var array<float> setupTradeTP1 = array.new_float()
var array<float> setupTradeTP2 = array.new_float()

var array<bool> setupFailed = array.new_bool()
var array<string> setupDiagnostic = array.new_string()


//══════════════════════════════════════════════════════════════════════════════
// STRUCTURE
//══════════════════════════════════════════════════════════════════════════════

confirmedSwingHigh =
     ta.pivothigh(
         high,
         structureSwingLength,
         structureSwingLength)

confirmedSwingLow =
     ta.pivotlow(
         low,
         structureSwingLength,
         structureSwingLength)


var float latestStructureHigh = na
var float latestStructureLow = na


if not na(confirmedSwingHigh)
    // Use the CLOSE of the confirmed pivot-high candle as the bullish BOS level.
    // The pivot itself is still identified from the candle HIGH.
    latestStructureHigh := close[structureSwingLength]

if not na(confirmedSwingLow)
    // Use the CLOSE of the confirmed pivot-low candle as the bearish BOS level.
    // The pivot itself is still identified from the candle LOW.
    latestStructureLow := close[structureSwingLength]


//══════════════════════════════════════════════════════════════════════════════
// 3-CANDLE RECLAIM
//══════════════════════════════════════════════════════════════════════════════

bullishReclaim =
     barstate.isconfirmed and
     close[2] < open[2] and
     low[1] < low[2] and
     close[1] > low[2] and
     close > open and
     close > low[2]


bearishReclaim =
     barstate.isconfirmed and
     close[2] > open[2] and
     high[1] > high[2] and
     close[1] < high[2] and
     close < open and
     close < high[2]


//══════════════════════════════════════════════════════════════════════════════
// ACTIVE TRADE STATE
//══════════════════════════════════════════════════════════════════════════════

var bool activeTrade = false

var int activeDirection = 0
var int activeSetupIndex = na
var int activeEntryBar = na

var float activeEntry = na
var float activeSL = na
var float activeRisk = na
var float activeTP1 = na
var float activeTP2 = na

var bool activeTP1Hit = false
var bool activeTradeDrawn = false
var bool tradePositionReadyNow = false
var bool delayedTradeActivationNow = false

// Bar on which the most recent trade was fully closed by SL or TP.
// New trades may only be activated from 3C setups that formed AFTER this bar.
// Opposite-direction reversal switches are handled separately and can still
// switch on the same confirmed setup that closes the current trade.
var int lastTradeCloseBar = na


//══════════════════════════════════════════════════════════════════════════════
// ACTIVE DRAWING OBJECTS
//══════════════════════════════════════════════════════════════════════════════

var line activeEntryLine = na
var line activeSLLine = na
var line activeTP1Line = na
var line activeTP2Line = na

var box activeRiskBox = na
var box activeProfitBox = na

var label activeEntryLabel = na
var label activeSLLabel = na
var label activeTP1Label = na
var label activeTP2Label = na


//══════════════════════════════════════════════════════════════════════════════
// TRADE STATISTICS
//══════════════════════════════════════════════════════════════════════════════

var int totalTrades = 0
var int winningTrades = 0
var int losingTrades = 0

var float totalRealizedR = 0.0


//══════════════════════════════════════════════════════════════════════════════
// PROCESS EXISTING SETUPS
//══════════════════════════════════════════════════════════════════════════════

if barstate.isconfirmed and array.size(setupDirections) > 0

    tradePositionReadyNow := false
    delayedTradeActivationNow := false

    int i = array.size(setupDirections) - 1

    while i >= 0

        int direction =
             array.get(
                 setupDirections,
                 i)

        float setupLevel =
             array.get(
                 setupLevels,
                 i)

        float sweepLevel =
             array.get(
                 setupSweepLevels,
                 i)

        int originalSetupBar =
             array.get(
                 setupBars,
                 i)

        label setupLabel =
             array.get(
                 setupLabels,
                 i)

        bool failed =
             array.get(
                 setupFailed,
                 i)

        bool bosConfirmed =
             array.get(
                 setupBOSConfirmed,
                 i)

        int bosBar =
             array.get(
                 setupBOSBars,
                 i)

        float bosMidpoint =
             array.get(
                 setupBOSMidpoints,
                 i)

        bool confirmation50 =
             array.get(
                 setup50Confirmed,
                 i)

        bool subsequentCandle =
             bar_index > originalSetupBar

        bool setupFailsNow = false
        bool bosConfirmedNow = false
        bool confirmation50Now = false


        //══════════════════════════════════════════════════════════════════════
        // SUCCESSIVE INVALIDATION
        //══════════════════════════════════════════════════════════════════════

        if enableStep2 and
             subsequentCandle and
             not failed and
             not bosConfirmed

            bool bullInvalidation =
                 direction == DIR_BULL and
                 close < setupLevel

            bool bearInvalidation =
                 direction == DIR_BEAR and
                 close > setupLevel


            if bullInvalidation or bearInvalidation
                setupFailsNow := true
                array.set(setupDiagnostic, i, "FAILED — SUCCESSIVE INVALIDATION")


        //══════════════════════════════════════════════════════════════════════
        // BOS CONFIRMATION
        //══════════════════════════════════════════════════════════════════════

        if not setupFailsNow and
             not failed and
             enableStep3 and
             not bosConfirmed and
             subsequentCandle

            float structureLevel =
                 array.get(
                     setupStructureLevels,
                     i)


            bool bullBOS =
                 direction == DIR_BULL and
                 not na(structureLevel) and
                 close > structureLevel

            bool bearBOS =
                 direction == DIR_BEAR and
                 not na(structureLevel) and
                 close < structureLevel


            if bullBOS

                // A bullish BOS must be confirmed by a bullish candle close.
                // If the BOS confirmation candle closes bearish, invalidate the
                // setup immediately and do not create a trade candidate.
                if close < open
                    setupFailsNow := true
                    array.set(setupDiagnostic, i, "FAILED — BULL BOS CANDLE IS BEARISH")
                else
                    array.set(setupDiagnostic, i, "BOS CONFIRMED — WAITING FOR 50%")
                    float midpoint =
                         (high + low) / 2.0


                    array.set(
                         setupBOSConfirmed,
                         i,
                         true)

                    array.set(
                         setupBOSBars,
                         i,
                         bar_index)

                    array.set(
                         setupBOSHighs,
                         i,
                         high)

                    array.set(
                         setupBOSLows,
                         i,
                         low)

                    array.set(
                         setupBOSMidpoints,
                         i,
                         midpoint)


                    bosConfirmedNow := true

                    //──────────────────────────────────────────────────────────────
                    // TRADE QUALITY DIAGNOSTIC — BOS QUALITY
                    // 30 pts: body strength
                    // 25 pts: close location
                    // 20 pts: distance beyond BOS level
                    // 25 pts are reserved for BOS 50% confirmation.
                    // This score is diagnostic only; it does not filter trades.
                    //──────────────────────────────────────────────────────────────
                    float bosRange = high - low
                    float bosBodyPct = bosRange > 0 ? math.abs(close - open) / bosRange : 0.0
                    float bosCloseLocation = bosRange > 0 ? (close - low) / bosRange : 0.0
                    float bosBreakPct = bosRange > 0 and not na(structureLevel) ?
                         math.max(close - structureLevel, 0.0) / bosRange : 0.0

                    float bosBodyScore = math.min(bosBodyPct / 0.60, 1.0) * 30.0
                    float bosCloseScore = math.min(bosCloseLocation / 0.75, 1.0) * 25.0
                    float bosBreakScore = math.min(bosBreakPct / 0.50, 1.0) * 20.0

                    array.set(setupBOSBodyScores, i, bosBodyScore)
                    array.set(setupBOSCloseScores, i, bosCloseScore)
                    array.set(setupBOSBreakScores, i, bosBreakScore)
                    array.set(setup50Scores, i, 0.0)
                    array.set(setupQualityScores, i, bosBodyScore + bosCloseScore + bosBreakScore)

                    // SETUP LOCATION / LATE ENTRY DIAGNOSTIC
                    // Uses completed bars BEFORE the BOS candle.
                    // Diagnostic only — it does not filter or block trades.
                    float locationHigh = ta.highest(high, locationLookback)[1]
                    float locationLow = ta.lowest(low, locationLookback)[1]
                    float locationRange = locationHigh - locationLow
                    float locationPct = locationRange > 0 ?
                         (close - locationLow) / locationRange * 100.0 :
                         na
                    float locationRoomPct = not na(locationPct) ?
                         100.0 - locationPct :
                         na
                    float locationRisk = close - sweepLevel
                    float preEntryMoveR = locationRisk > 0 ?
                         (close - locationLow) / locationRisk :
                         na

                    array.set(setupLocationPosition, i, locationPct)
                    array.set(setupLocationRoom, i, locationRoomPct)
                    array.set(setupPreEntryMoveR, i, preEntryMoveR)
                    array.set(setupLocationRangeHigh, i, locationHigh)
                    array.set(setupLocationRangeLow, i, locationLow)


                    if showBOSLabel

                        label bosLabel =
                             label.new(
                                 bar_index,
                                 high,
                                 "BULLISH BOS",
                                 style=label.style_label_down,
                                 color=color.green,
                                 textcolor=color.white)


                        array.set(
                             bosLabels,
                             i,
                             bosLabel)


            else if bearBOS

                // A bearish BOS must be confirmed by a bearish candle close.
                // If the BOS confirmation candle closes bullish, invalidate the
                // setup immediately and do not create a trade candidate.
                if close > open
                    setupFailsNow := true
                    array.set(setupDiagnostic, i, "FAILED — BEAR BOS CANDLE IS BULLISH")
                else
                    array.set(setupDiagnostic, i, "BOS CONFIRMED — WAITING FOR 50%")
                    float midpoint =
                         (high + low) / 2.0


                    array.set(
                         setupBOSConfirmed,
                         i,
                         true)

                    array.set(
                         setupBOSBars,
                         i,
                         bar_index)

                    array.set(
                         setupBOSHighs,
                         i,
                         high)

                    array.set(
                         setupBOSLows,
                         i,
                         low)

                    array.set(
                         setupBOSMidpoints,
                         i,
                         midpoint)


                    bosConfirmedNow := true

                    //──────────────────────────────────────────────────────────────
                    // TRADE QUALITY DIAGNOSTIC — BOS QUALITY
                    // 30 pts: body strength
                    // 25 pts: close location
                    // 20 pts: distance beyond BOS level
                    // 25 pts are reserved for BOS 50% confirmation.
                    // This score is diagnostic only; it does not filter trades.
                    //──────────────────────────────────────────────────────────────
                    float bosRange = high - low
                    float bosBodyPct = bosRange > 0 ? math.abs(close - open) / bosRange : 0.0
                    float bosCloseLocation = bosRange > 0 ? (high - close) / bosRange : 0.0
                    float bosBreakPct = bosRange > 0 and not na(structureLevel) ?
                         math.max(structureLevel - close, 0.0) / bosRange : 0.0

                    float bosBodyScore = math.min(bosBodyPct / 0.60, 1.0) * 30.0
                    float bosCloseScore = math.min(bosCloseLocation / 0.75, 1.0) * 25.0
                    float bosBreakScore = math.min(bosBreakPct / 0.50, 1.0) * 20.0

                    array.set(setupBOSBodyScores, i, bosBodyScore)
                    array.set(setupBOSCloseScores, i, bosCloseScore)
                    array.set(setupBOSBreakScores, i, bosBreakScore)
                    array.set(setup50Scores, i, 0.0)
                    array.set(setupQualityScores, i, bosBodyScore + bosCloseScore + bosBreakScore)

                    // SETUP LOCATION / LATE ENTRY DIAGNOSTIC
                    // Uses completed bars BEFORE the BOS candle.
                    // Diagnostic only — it does not filter or block trades.
                    float locationHigh = ta.highest(high, locationLookback)[1]
                    float locationLow = ta.lowest(low, locationLookback)[1]
                    float locationRange = locationHigh - locationLow
                    float locationPct = locationRange > 0 ?
                         (locationHigh - close) / locationRange * 100.0 :
                         na
                    float locationRoomPct = not na(locationPct) ?
                         100.0 - locationPct :
                         na
                    float locationRisk = sweepLevel - close
                    float preEntryMoveR = locationRisk > 0 ?
                         (locationHigh - close) / locationRisk :
                         na

                    array.set(setupLocationPosition, i, locationPct)
                    array.set(setupLocationRoom, i, locationRoomPct)
                    array.set(setupPreEntryMoveR, i, preEntryMoveR)
                    array.set(setupLocationRangeHigh, i, locationHigh)
                    array.set(setupLocationRangeLow, i, locationLow)


                    if showBOSLabel

                        label bosLabel =
                             label.new(
                                 bar_index,
                                 low,
                                 "BEARISH BOS",
                                 style=label.style_label_up,
                                 color=color.red,
                                 textcolor=color.white)


                        array.set(
                             bosLabels,
                             i,
                             bosLabel)


        //══════════════════════════════════════════════════════════════════════
        // BOS 50% CONFIRMATION
        // The immediate next candle must:
        // 1) close beyond the BOS midpoint in the setup direction, AND
        // 2) close in the same candle direction as the setup.
        // Otherwise the setup fails and no trade is opened.
        //══════════════════════════════════════════════════════════════════════

        bool currentBOS =
             bosConfirmed or bosConfirmedNow


        int currentBOSBar =
             bosConfirmedNow ?
                 bar_index :
                 bosBar


        float currentMidpoint =
             bosConfirmedNow ?
                 (high + low) / 2.0 :
                 bosMidpoint


        if not setupFailsNow and
             not failed and
             enableStep3 and
             enableStep4 and
             currentBOS and
             not confirmation50

            bool immediateNextCandle =
                 bar_index == currentBOSBar + 1


            if immediateNextCandle

                bool bull50Pass =
                     direction == DIR_BULL and
                     close >= currentMidpoint

                bool bear50Pass =
                     direction == DIR_BEAR and
                     close <= currentMidpoint


                // The immediate 50% confirmation candle must also close in the
                // same direction as the setup. A midpoint pass alone is not enough.
                bool bull50DirectionPass =
                     direction == DIR_BULL and
                     close > open

                bool bear50DirectionPass =
                     direction == DIR_BEAR and
                     close < open

                bool fiftyCandleDirectionPass =
                     bull50DirectionPass or bear50DirectionPass

                // The immediate 50% confirmation candle must have a body
                // greater than 50% of its total candle range.
                float fiftyCandleRange = high - low
                float fiftyCandleBody = math.abs(close - open)
                bool fiftyBodyPass =
                     fiftyCandleRange > 0 and
                     (fiftyCandleBody / fiftyCandleRange) > 0.50

                if (bull50Pass or bear50Pass) and
                     fiftyCandleDirectionPass and
                     fiftyBodyPass

                    array.set(
                         setup50Confirmed,
                         i,
                         true)

                    array.set(setupDiagnostic, i, "50% CONFIRMED — TRADE READY")

                    confirmation50Now := true

                    // 25-point BOS 50% confirmation quality.
                    // Score is based on how far the confirmation close travels
                    // beyond the BOS midpoint, normalized to the BOS candle range.
                    float bosRangeFor50 = array.get(setupBOSHighs, i) - array.get(setupBOSLows, i)
                    float favorable50Distance = direction == DIR_BULL ?
                         math.max(close - currentMidpoint, 0.0) :
                         math.max(currentMidpoint - close, 0.0)
                    float fiftyScore = bosRangeFor50 > 0 ?
                         math.min(favorable50Distance / (bosRangeFor50 * 0.50), 1.0) * 25.0 :
                         0.0

                    array.set(setup50Scores, i, fiftyScore)

                    float bosScoreNow =
                         array.get(setupBOSBodyScores, i) +
                         array.get(setupBOSCloseScores, i) +
                         array.get(setupBOSBreakScores, i)

                    array.set(setupQualityScores, i, bosScoreNow + fiftyScore)


                    // If a new opposite-direction trade candidate is fully confirmed,
                    // close the current trade at the confirmed candle close and switch
                    // immediately to the new trade position.
                    // Opposite-direction reversal switch is allowed only when
                    // the NEW trade entry has crossed beyond the CURRENT trade entry:
                    //   active SHORT -> new LONG entry must be ABOVE active SHORT entry
                    //   active LONG  -> new SHORT entry must be BELOW active LONG entry
                    float newOppositeEntry = array.get(setupTradeEntry, i)
                    bool oppositeEntryPassed =
                         activeDirection == DIR_BEAR ?
                             newOppositeEntry > activeEntry :
                             activeDirection == DIR_BULL ?
                                 newOppositeEntry < activeEntry :
                                 false

                    bool oppositeTradeReady =
                         activeTrade and
                         activeDirection != direction and
                         array.get(setupTradeCandidate, i) and
                         oppositeEntryPassed

                    if oppositeTradeReady

                        float reversalExitPrice = close
                        float reversalExitR =
                             activeDirection == DIR_BULL ?
                                 (reversalExitPrice - activeEntry) / activeRisk :
                                 (activeEntry - reversalExitPrice) / activeRisk

                        float reversalRealizedR =
                             activeTP1Hit ?
                                 0.5 + reversalExitR * 0.5 :
                                 reversalExitR

                        totalRealizedR += reversalRealizedR

                        // A trade counts as a WIN only after TP1 / 1R was reached.
                        // Therefore an opposite-setup switch before TP1 is recorded as a loss.
                        if not activeTP1Hit
                            losingTrades += 1

                        // Freeze the current trade drawings before switching state.
                        if not na(activeEntryLine)
                            line.set_extend(activeEntryLine, extend.none)
                            line.set_x2(activeEntryLine, bar_index)
                            line.set_color(activeEntryLine, HISTORY_ENTRY_COLOR)

                        if not na(activeSLLine)
                            line.set_extend(activeSLLine, extend.none)
                            line.set_x2(activeSLLine, bar_index)
                            line.set_color(activeSLLine, HISTORY_SL_COLOR)

                        if not na(activeTP1Line)
                            line.set_extend(activeTP1Line, extend.none)
                            line.set_x2(activeTP1Line, bar_index)
                            line.set_color(activeTP1Line, HISTORY_TP_COLOR)

                        if not na(activeTP2Line)
                            line.set_extend(activeTP2Line, extend.none)
                            line.set_x2(activeTP2Line, bar_index)
                            line.set_color(activeTP2Line, HISTORY_TP_COLOR)

                        if not na(activeRiskBox)
                            box.set_extend(activeRiskBox, extend.none)
                            box.set_right(activeRiskBox, bar_index)
                            box.set_bgcolor(activeRiskBox, HISTORY_RISK_BG)
                            box.set_border_color(activeRiskBox, HISTORY_RISK_BORDER)

                        if not na(activeProfitBox)
                            box.set_extend(activeProfitBox, extend.none)
                            box.set_right(activeProfitBox, bar_index)
                            box.set_bgcolor(activeProfitBox, HISTORY_PROFIT_BG)
                            box.set_border_color(activeProfitBox, HISTORY_PROFIT_BORDER)

                        if showTradeResults
                            label.new(
                                 bar_index,
                                 reversalExitPrice,
                                 "REVERSAL EXIT\n" +
                                 str.tostring(reversalRealizedR, "#.##") +
                                 "R",
                                 style=label.style_label_left,
                                 color=color.orange,
                                 textcolor=color.white)

                        activeEntryLine := na
                        activeSLLine := na
                        activeTP1Line := na
                        activeTP2Line := na
                        activeRiskBox := na
                        activeProfitBox := na
                        activeEntryLabel := na
                        activeSLLabel := na
                        activeTP1Label := na
                        activeTP2Label := na

                        activeTrade := false
                        activeDirection := 0
                        activeSetupIndex := na
                        activeEntryBar := na
                        activeEntry := na
                        activeSL := na
                        activeRisk := na
                        activeTP1 := na
                        activeTP2 := na
                        activeTP1Hit := false
                        activeTradeDrawn := false

                    // Activate when the trade slot is free. Otherwise retain the candidate.
                    bool setupFormedAfterLastTradeClose =
                         na(lastTradeCloseBar) or
                         array.get(setupBars, i) > lastTradeCloseBar

                    if not activeTrade and
                         array.get(setupTradeCandidate, i) and
                         setupFormedAfterLastTradeClose

                        activeTrade := true
                        activeDirection := direction
                        activeSetupIndex := i
                        activeEntryBar := array.get(setupBOSBars, i)
                        activeEntry := array.get(setupTradeEntry, i)
                        activeSL := array.get(setupTradeSL, i)
                        activeRisk := array.get(setupTradeRisk, i)
                        activeTP1 := array.get(setupTradeTP1, i)
                        activeTP2 := array.get(setupTradeTP2, i)
                        activeTP1Hit := false
                        activeTradeDrawn := false
                        totalTrades += 1
                        array.set(setupTradeCandidate, i, false)
                        array.set(setupDiagnostic, i, "TRADE ACTIVE — " + (direction == DIR_BULL ? "LONG" : "SHORT"))
                        tradePositionReadyNow := true

                else

                    // The immediate next candle is required to pass all three
                    // conditions: midpoint, candle direction, and body > 50%
                    // of the candle range. If any condition fails, this setup
                    // is failed and no trade position is opened.
                    string fiftyFailureReason =
                         not (bull50Pass or bear50Pass) and
                         not fiftyCandleDirectionPass and
                         not fiftyBodyPass ?
                             "FAILED — 50% MIDPOINT + DIRECTION + BODY" :
                         not (bull50Pass or bear50Pass) and
                         not fiftyCandleDirectionPass ?
                             "FAILED — 50% MIDPOINT + DIRECTION" :
                         not (bull50Pass or bear50Pass) and
                         not fiftyBodyPass ?
                             "FAILED — 50% MIDPOINT + BODY" :
                         not fiftyCandleDirectionPass and
                         not fiftyBodyPass ?
                             "FAILED — 50% DIRECTION + BODY" :
                         not (bull50Pass or bear50Pass) ?
                             "FAILED — 50% MIDPOINT" :
                         not fiftyCandleDirectionPass ?
                             "FAILED — 50% CANDLE DIRECTION" :
                             "FAILED — 50% BODY <= 50%"

                    array.set(setupDiagnostic, i, fiftyFailureReason)
                    setupFailsNow := true


        //══════════════════════════════════════════════════════════════════════
        // DRAW TRADE POSITION ONLY AFTER BOS 50% CONFIRMATION
        //
        // Trade state is still created on BOS, but visual position objects are
        // intentionally hidden until the immediate next candle confirms 50%.
        //══════════════════════════════════════════════════════════════════════

        if confirmation50Now and
             activeTrade and
             activeSetupIndex == i and
             showTradePosition and
             not activeTradeDrawn

            if activeDirection == DIR_BULL

                activeRiskBox :=
                     box.new(
                         left=bar_index,
                         top=activeEntry,
                         right=bar_index + 1,
                         bottom=activeSL,
                         bgcolor=ACTIVE_RISK_BG,
                         border_color=ACTIVE_RISK_BORDER,
                         extend=extend.right)


                activeProfitBox :=
                     box.new(
                         left=bar_index,
                         top=activeTP2,
                         right=bar_index + 1,
                         bottom=activeEntry,
                         bgcolor=ACTIVE_PROFIT_BG,
                         border_color=ACTIVE_PROFIT_BORDER,
                         extend=extend.right)


            else

                activeRiskBox :=
                     box.new(
                         left=bar_index,
                         top=activeSL,
                         right=bar_index + 1,
                         bottom=activeEntry,
                         bgcolor=ACTIVE_RISK_BG,
                         border_color=ACTIVE_RISK_BORDER,
                         extend=extend.right)


                activeProfitBox :=
                     box.new(
                         left=bar_index,
                         top=activeEntry,
                         right=bar_index + 1,
                         bottom=activeTP2,
                         bgcolor=ACTIVE_PROFIT_BG,
                         border_color=ACTIVE_PROFIT_BORDER,
                         extend=extend.right)


            activeEntryLine :=
                 line.new(
                     bar_index,
                     activeEntry,
                     bar_index + 1,
                     activeEntry,
                     extend=extend.right,
                     color=ACTIVE_ENTRY_COLOR,
                     style=line.style_dashed,
                     width=2)


            activeSLLine :=
                 line.new(
                     bar_index,
                     activeSL,
                     bar_index + 1,
                     activeSL,
                     extend=extend.right,
                     color=ACTIVE_SL_COLOR,
                     style=line.style_dashed,
                     width=2)


            activeTP1Line :=
                 line.new(
                     bar_index,
                     activeTP1,
                     bar_index + 1,
                     activeTP1,
                     extend=extend.right,
                     color=ACTIVE_TP_COLOR,
                     style=line.style_dashed,
                     width=1)


            activeTP2Line :=
                 line.new(
                     bar_index,
                     activeTP2,
                     bar_index + 1,
                     activeTP2,
                     extend=extend.right,
                     color=ACTIVE_TP_COLOR,
                     style=line.style_dashed,
                     width=2)


            if showTradeLabels

                activeEntryLabel :=
                     label.new(
                         bar_index,
                         activeEntry,
                         "ENTRY\n" +
                         str.tostring(
                             activeEntry,
                             format.mintick),
                         style=label.style_label_left,
                         color=color.blue,
                         textcolor=color.white)


                activeSLLabel :=
                     label.new(
                         bar_index,
                         activeSL,
                         "SL\n" +
                         str.tostring(
                             activeSL,
                             format.mintick),
                         style=label.style_label_left,
                         color=color.red,
                         textcolor=color.white)


                activeTP1Label :=
                     label.new(
                         bar_index,
                         activeTP1,
                         "TP1 • 1R\n" +
                         str.tostring(
                             activeTP1,
                             format.mintick),
                         style=label.style_label_left,
                         color=color.green,
                         textcolor=color.white)


                activeTP2Label :=
                     label.new(
                         bar_index,
                         activeTP2,
                         "TP2 • " +
                         str.tostring(
                             finalRR,
                             "#.##") +
                         "R\n" +
                         str.tostring(
                             activeTP2,
                             format.mintick),
                         style=label.style_label_left,
                         color=color.green,
                         textcolor=color.white)


            activeTradeDrawn := true


        //══════════════════════════════════════════════════════════════════════
        // FAILURE
        //══════════════════════════════════════════════════════════════════════

        if setupFailsNow

            array.set(
                 setupFailed,
                 i,
                 true)

            if array.get(setupDiagnostic, i) == ""
                array.set(setupDiagnostic, i, "FAILED — SETUP INVALIDATED")

            array.set(
                 setupTradeCandidate,
                 i,
                 false)


            if showFailedReclaims

                if direction == DIR_BULL

                    label.set_text(
                         setupLabel,
                         "3C BULL RECLAIM - FAILED")

                else

                    label.set_text(
                         setupLabel,
                         "3C BEAR RECLAIM - FAILED")


                label.set_color(
                     setupLabel,
                     color.new(color.gray, 60))


            else

                label.delete(
                     setupLabel)


                //══════════════════════════════════════════════════════════════════════
        // STORE TRADE CANDIDATE
        //
        // BOS fixes Entry at the BOS close and SL at the C2 sweep. The candidate
        // is retained if another trade is already active.
        //══════════════════════════════════════════════════════════════════════

        if bosConfirmedNow and
             enableTrade and
             not setupFailsNow and
             not failed

            float entryPrice = close
            float stopPrice = sweepLevel
            float risk = direction == DIR_BULL ? entryPrice - stopPrice : stopPrice - entryPrice

            if risk > 0

                float target1 = direction == DIR_BULL ? entryPrice + risk : entryPrice - risk
                float target2 = direction == DIR_BULL ? entryPrice + risk * finalRR : entryPrice - risk * finalRR

                array.set(setupTradeCandidate, i, true)
                array.set(setupTradeEntry, i, entryPrice)
                array.set(setupTradeSL, i, stopPrice)
                array.set(setupTradeRisk, i, risk)
                array.set(setupTradeTP1, i, target1)
                array.set(setupTradeTP2, i, target2)


                // If BOS itself is the trade trigger and a new opposite-direction
                // candidate appears, close the current trade at the confirmed BOS
                // close and switch immediately to the new position.
                // When 50% confirmation is disabled, apply the same reversal rule
                // directly at BOS: only switch if the NEW opposite trade entry has
                // crossed beyond the CURRENT trade entry.
                float newOppositeEntryAtBOS = array.get(setupTradeEntry, i)
                bool oppositeEntryPassedAtBOS =
                     activeDirection == DIR_BEAR ?
                         newOppositeEntryAtBOS > activeEntry :
                         activeDirection == DIR_BULL ?
                             newOppositeEntryAtBOS < activeEntry :
                             false

                bool oppositeTradeReadyAtBOS =
                     not enableStep4 and
                     activeTrade and
                     activeDirection != direction and
                     array.get(setupTradeCandidate, i) and
                     oppositeEntryPassedAtBOS

                if oppositeTradeReadyAtBOS

                    float reversalExitPrice = close
                    float reversalExitR =
                         activeDirection == DIR_BULL ?
                             (reversalExitPrice - activeEntry) / activeRisk :
                             (activeEntry - reversalExitPrice) / activeRisk

                    float reversalRealizedR =
                         activeTP1Hit ?
                             0.5 + reversalExitR * 0.5 :
                             reversalExitR

                    totalRealizedR += reversalRealizedR

                    if not activeTP1Hit
                        losingTrades += 1

                    if not na(activeEntryLine)
                        line.set_extend(activeEntryLine, extend.none)
                        line.set_x2(activeEntryLine, bar_index)
                        line.set_color(activeEntryLine, HISTORY_ENTRY_COLOR)

                    if not na(activeSLLine)
                        line.set_extend(activeSLLine, extend.none)
                        line.set_x2(activeSLLine, bar_index)
                        line.set_color(activeSLLine, HISTORY_SL_COLOR)

                    if not na(activeTP1Line)
                        line.set_extend(activeTP1Line, extend.none)
                        line.set_x2(activeTP1Line, bar_index)
                        line.set_color(activeTP1Line, HISTORY_TP_COLOR)

                    if not na(activeTP2Line)
                        line.set_extend(activeTP2Line, extend.none)
                        line.set_x2(activeTP2Line, bar_index)
                        line.set_color(activeTP2Line, HISTORY_TP_COLOR)

                    if not na(activeRiskBox)
                        box.set_extend(activeRiskBox, extend.none)
                        box.set_right(activeRiskBox, bar_index)
                        box.set_bgcolor(activeRiskBox, HISTORY_RISK_BG)
                        box.set_border_color(activeRiskBox, HISTORY_RISK_BORDER)

                    if not na(activeProfitBox)
                        box.set_extend(activeProfitBox, extend.none)
                        box.set_right(activeProfitBox, bar_index)
                        box.set_bgcolor(activeProfitBox, HISTORY_PROFIT_BG)
                        box.set_border_color(activeProfitBox, HISTORY_PROFIT_BORDER)

                    if showTradeResults
                        label.new(
                             bar_index,
                             reversalExitPrice,
                             "REVERSAL EXIT\n" +
                             str.tostring(reversalRealizedR, "#.##") +
                             "R",
                             style=label.style_label_left,
                             color=color.orange,
                             textcolor=color.white)

                    activeEntryLine := na
                    activeSLLine := na
                    activeTP1Line := na
                    activeTP2Line := na
                    activeRiskBox := na
                    activeProfitBox := na
                    activeEntryLabel := na
                    activeSLLabel := na
                    activeTP1Label := na
                    activeTP2Label := na
                    activeTrade := false
                    activeDirection := 0
                    activeSetupIndex := na
                    activeEntryBar := na
                    activeEntry := na
                    activeSL := na
                    activeRisk := na
                    activeTP1 := na
                    activeTP2 := na
                    activeTP1Hit := false
                    activeTradeDrawn := false

                // If 50% confirmation is disabled, BOS itself activates the trade.
                if not enableStep4 and not activeTrade
                    activeTrade := true
                    activeDirection := direction
                    activeSetupIndex := i
                    activeEntryBar := bar_index
                    activeEntry := entryPrice
                    activeSL := stopPrice
                    activeRisk := risk
                    activeTP1 := target1
                    activeTP2 := target2
                    activeTP1Hit := false
                    activeTradeDrawn := false
                    totalTrades += 1
                    array.set(setupTradeCandidate, i, false)

        i -= 1


//══════════════════════════════════════════════════════════════════════════════
// CREATE BULLISH SETUP
//══════════════════════════════════════════════════════════════════════════════

if enableBullish and
     bullishReclaim

    float bullC1Level =
         low[2]

    float bullSweepLow =
         low[1]

    float bullStructureHigh =
         latestStructureHigh


    float bullArrowPrice =
         low * (1.0 - arrowOffsetPct / 100.0)

    label bullLabel =
         label.new(
             bar_index,
             bullArrowPrice,
             "",
             style=label.style_triangleup,
             color=color.green,
             textcolor=color.white,
             size=size.tiny)


    array.push(
         setupDirections,
         DIR_BULL)

    array.push(
         setupLevels,
         bullC1Level)

    array.push(
         setupSweepLevels,
         bullSweepLow)

    array.push(
         setupBars,
         bar_index)

    array.push(
         setupLabels,
         bullLabel)

    array.push(
         setupStructureLevels,
         bullStructureHigh)

    array.push(
         setupBOSConfirmed,
         false)

    array.push(
         setupBOSBars,
         na)

    array.push(
         setupBOSHighs,
         na)

    array.push(
         setupBOSLows,
         na)

    array.push(
         bosLabels,
         na)

    array.push(
         setupBOSMidpoints,
         na)

    array.push(
         setup50Confirmed,
         false)

    array.push(
         setupBOSBodyScores,
         0.0)

    array.push(
         setupBOSCloseScores,
         0.0)

    array.push(
         setupBOSBreakScores,
         0.0)

    array.push(
         setup50Scores,
         0.0)

    array.push(
         setupQualityScores,
         0.0)

    array.push(setupLocationPosition, na)
    array.push(setupLocationRoom, na)
    array.push(setupPreEntryMoveR, na)
    array.push(setupLocationRangeHigh, na)
    array.push(setupLocationRangeLow, na)

    array.push(setupTradeCandidate, false)
    array.push(setupTradeEntry, na)
    array.push(setupTradeSL, na)
    array.push(setupTradeRisk, na)
    array.push(setupTradeTP1, na)
    array.push(setupTradeTP2, na)

    array.push(
         setupFailed,
         false)

    array.push(
         setupDiagnostic,
         "3C CONFIRMED — WAITING FOR BOS")

//══════════════════════════════════════════════════════════════════════════════
// CREATE BEARISH SETUP
//══════════════════════════════════════════════════════════════════════════════

if enableBearish and
     bearishReclaim

    float bearC1Level =
         high[2]

    float bearSweepHigh =
         high[1]

    float bearStructureLow =
         latestStructureLow


    float bearArrowPrice =
         high * (1.0 + arrowOffsetPct / 100.0)

    label bearLabel =
         label.new(
             bar_index,
             bearArrowPrice,
             "",
             style=label.style_triangledown,
             color=color.red,
             textcolor=color.white,
             size=size.tiny)


    array.push(
         setupDirections,
         DIR_BEAR)

    array.push(
         setupLevels,
         bearC1Level)

    array.push(
         setupSweepLevels,
         bearSweepHigh)

    array.push(
         setupBars,
         bar_index)

    array.push(
         setupLabels,
         bearLabel)

    array.push(
         setupStructureLevels,
         bearStructureLow)

    array.push(
         setupBOSConfirmed,
         false)

    array.push(
         setupBOSBars,
         na)

    array.push(
         setupBOSHighs,
         na)

    array.push(
         setupBOSLows,
         na)

    array.push(
         bosLabels,
         na)

    array.push(
         setupBOSMidpoints,
         na)

    array.push(
         setup50Confirmed,
         false)

    array.push(
         setupBOSBodyScores,
         0.0)

    array.push(
         setupBOSCloseScores,
         0.0)

    array.push(
         setupBOSBreakScores,
         0.0)

    array.push(
         setup50Scores,
         0.0)

    array.push(
         setupQualityScores,
         0.0)

    array.push(setupLocationPosition, na)
    array.push(setupLocationRoom, na)
    array.push(setupPreEntryMoveR, na)
    array.push(setupLocationRangeHigh, na)
    array.push(setupLocationRangeLow, na)

    array.push(setupTradeCandidate, false)
    array.push(setupTradeEntry, na)
    array.push(setupTradeSL, na)
    array.push(setupTradeRisk, na)
    array.push(setupTradeTP1, na)
    array.push(setupTradeTP2, na)

    array.push(
         setupFailed,
         false)

    array.push(
         setupDiagnostic,
         "3C CONFIRMED — WAITING FOR BOS")


//══════════════════════════════════════════════════════════════════════════════
// KEEP ONLY THE LATEST N SETUPS IN MEMORY
//
// This is the main runtime optimization. Older setup state is removed from
// the arrays instead of being processed on every confirmed candle forever.
// The active trade's setup is always preserved until the trade is closed.
//══════════════════════════════════════════════════════════════════════════════

int setupCount = array.size(setupDirections)

while setupCount > displaySetupCount

    int removeIndex = 0

    if activeTrade and not na(activeSetupIndex) and activeSetupIndex == 0
        // Preserve the active setup when it is the oldest setup.
        removeIndex := 1

    // Keep historical setup/BOS labels on the chart.
    // Only the internal state arrays are pruned for runtime performance.
    // Older labels are intentionally left untouched so all past setups remain visible.

    array.remove(setupDirections, removeIndex)
    array.remove(setupLevels, removeIndex)
    array.remove(setupSweepLevels, removeIndex)
    array.remove(setupBars, removeIndex)
    array.remove(setupLabels, removeIndex)
    array.remove(setupStructureLevels, removeIndex)
    array.remove(setupBOSConfirmed, removeIndex)
    array.remove(setupBOSBars, removeIndex)
    array.remove(setupBOSHighs, removeIndex)
    array.remove(setupBOSLows, removeIndex)
    array.remove(bosLabels, removeIndex)
    array.remove(setupBOSMidpoints, removeIndex)
    array.remove(setup50Confirmed, removeIndex)
    array.remove(setupBOSBodyScores, removeIndex)
    array.remove(setupBOSCloseScores, removeIndex)
    array.remove(setupBOSBreakScores, removeIndex)
    array.remove(setup50Scores, removeIndex)
    array.remove(setupQualityScores, removeIndex)
    array.remove(setupLocationPosition, removeIndex)
    array.remove(setupLocationRoom, removeIndex)
    array.remove(setupPreEntryMoveR, removeIndex)
    array.remove(setupLocationRangeHigh, removeIndex)
    array.remove(setupLocationRangeLow, removeIndex)
    array.remove(setupTradeCandidate, removeIndex)
    array.remove(setupTradeEntry, removeIndex)
    array.remove(setupTradeSL, removeIndex)
    array.remove(setupTradeRisk, removeIndex)
    array.remove(setupTradeTP1, removeIndex)
    array.remove(setupTradeTP2, removeIndex)
    array.remove(setupFailed, removeIndex)
    array.remove(setupDiagnostic, removeIndex)

    if activeTrade and not na(activeSetupIndex) and removeIndex < activeSetupIndex
        activeSetupIndex -= 1

    setupCount := array.size(setupDirections)


//══════════════════════════════════════════════════════════════════════════════
// ACTIVE TRADE MANAGEMENT
//══════════════════════════════════════════════════════════════════════════════

if activeTrade and
     bar_index > activeEntryBar

    bool stopHit = false
    bool tp1Hit = false
    bool tp2Hit = false


    if activeDirection == DIR_BULL

        stopHit := low <= activeSL
        tp1Hit := high >= activeTP1
        tp2Hit := high >= activeTP2

    else

        stopHit := high >= activeSL
        tp1Hit := low <= activeTP1
        tp2Hit := low <= activeTP2


    //══════════════════════════════════════════════════════════════════════════
    // STOP LOSS
    //══════════════════════════════════════════════════════════════════════════

    if stopHit

        float exitR =
             activeTP1Hit ?
                 0.0 :
                 -1.0


        totalRealizedR += exitR

        // A trade is considered a WIN once TP1 (1R) is achieved.
        // Therefore a later SL after TP1 must not be counted as a loss.
        if not activeTP1Hit
            losingTrades += 1


        //──────────────────────────────────────────────────────────────────────
        // FREEZE ACTIVE POSITION AS HISTORICAL
        //──────────────────────────────────────────────────────────────────────

        if not na(activeEntryLine)

            line.set_extend(
                 activeEntryLine,
                 extend.none)

            line.set_x2(
                 activeEntryLine,
                 bar_index)

            line.set_color(
                 activeEntryLine,
                 HISTORY_ENTRY_COLOR)


        if not na(activeSLLine)

            line.set_extend(
                 activeSLLine,
                 extend.none)

            line.set_x2(
                 activeSLLine,
                 bar_index)

            line.set_color(
                 activeSLLine,
                 HISTORY_SL_COLOR)


        if not na(activeTP1Line)

            line.set_extend(
                 activeTP1Line,
                 extend.none)

            line.set_x2(
                 activeTP1Line,
                 bar_index)

            line.set_color(
                 activeTP1Line,
                 HISTORY_TP_COLOR)


        if not na(activeTP2Line)

            line.set_extend(
                 activeTP2Line,
                 extend.none)

            line.set_x2(
                 activeTP2Line,
                 bar_index)

            line.set_color(
                 activeTP2Line,
                 HISTORY_TP_COLOR)


        if not na(activeRiskBox)

            box.set_extend(
                 activeRiskBox,
                 extend.none)

            box.set_right(
                 activeRiskBox,
                 bar_index)

            box.set_bgcolor(
                 activeRiskBox,
                 HISTORY_RISK_BG)

            box.set_border_color(
                 activeRiskBox,
                 HISTORY_RISK_BORDER)


        if not na(activeProfitBox)

            box.set_extend(
                 activeProfitBox,
                 extend.none)

            box.set_right(
                 activeProfitBox,
                 bar_index)

            box.set_bgcolor(
                 activeProfitBox,
                 HISTORY_PROFIT_BG)

            box.set_border_color(
                 activeProfitBox,
                 HISTORY_PROFIT_BORDER)


        // Result label OFF by default.
        if showTradeResults

            label.new(
                 bar_index,
                 activeSL,
                 activeTP1Hit ?
                     "WIN\nTP1 HIT\n+0.5R" :
                     "LOSS\nSL HIT\n" +
                     str.tostring(
                         exitR,
                         "#.##") +
                     "R",
                 style=
                     activeDirection == DIR_BULL ?
                         label.style_label_down :
                         label.style_label_up,
                 color=activeTP1Hit ? color.green : color.red,
                 textcolor=color.white)


        // Historical objects remain on chart.
        activeEntryLine := na
        activeSLLine := na
        activeTP1Line := na
        activeTP2Line := na

        activeRiskBox := na
        activeProfitBox := na

        activeEntryLabel := na
        activeSLLabel := na
        activeTP1Label := na
        activeTP2Label := na


        // Record the close bar so older setups cannot be activated after this trade.
        lastTradeCloseBar := bar_index

        activeTrade := false

        activeDirection := 0
        activeSetupIndex := na
        activeEntryBar := na

        activeEntry := na
        activeSL := na
        activeRisk := na
        activeTP1 := na
        activeTP2 := na

        activeTP1Hit := false
        activeTradeDrawn := false


    else

        //══════════════════════════════════════════════════════════════════════
        // TP1
        //══════════════════════════════════════════════════════════════════════

        if not activeTP1Hit and tp1Hit

            activeTP1Hit := true

            totalRealizedR += 0.5
            winningTrades += 1


            if showTradeResults

                label.new(
                     bar_index,
                     activeTP1,
                     "TP1\n50% CLOSED\n+0.5R",
                     style=label.style_label_left,
                     color=color.green,
                     textcolor=color.white)


        //══════════════════════════════════════════════════════════════════════
        // TP2
        //══════════════════════════════════════════════════════════════════════

        if activeTP1Hit and tp2Hit

            float finalTradeR =
                 0.5 +
                 finalRR * 0.5


            totalRealizedR += finalRR * 0.5


            //──────────────────────────────────────────────────────────────────
            // FREEZE ACTIVE POSITION AS HISTORICAL
            //──────────────────────────────────────────────────────────────────

            if not na(activeEntryLine)

                line.set_extend(
                     activeEntryLine,
                     extend.none)

                line.set_x2(
                     activeEntryLine,
                     bar_index)

                line.set_color(
                     activeEntryLine,
                     HISTORY_ENTRY_COLOR)


            if not na(activeSLLine)

                line.set_extend(
                     activeSLLine,
                     extend.none)

                line.set_x2(
                     activeSLLine,
                     bar_index)

                line.set_color(
                     activeSLLine,
                     HISTORY_SL_COLOR)


            if not na(activeTP1Line)

                line.set_extend(
                     activeTP1Line,
                     extend.none)

                line.set_x2(
                     activeTP1Line,
                     bar_index)

                line.set_color(
                     activeTP1Line,
                     HISTORY_TP_COLOR)


            if not na(activeTP2Line)

                line.set_extend(
                     activeTP2Line,
                     extend.none)

                line.set_x2(
                     activeTP2Line,
                     bar_index)

                line.set_color(
                     activeTP2Line,
                     HISTORY_TP_COLOR)


            if not na(activeRiskBox)

                box.set_extend(
                     activeRiskBox,
                     extend.none)

                box.set_right(
                     activeRiskBox,
                     bar_index)

                box.set_bgcolor(
                     activeRiskBox,
                     HISTORY_RISK_BG)

                box.set_border_color(
                     activeRiskBox,
                     HISTORY_RISK_BORDER)


            if not na(activeProfitBox)

                box.set_extend(
                     activeProfitBox,
                     extend.none)

                box.set_right(
                     activeProfitBox,
                     bar_index)

                box.set_bgcolor(
                     activeProfitBox,
                     HISTORY_PROFIT_BG)

                box.set_border_color(
                     activeProfitBox,
                     HISTORY_PROFIT_BORDER)


            if showTradeResults

                label.new(
                     bar_index,
                     activeTP2,
                     "WIN\nTP2 HIT\n+" +
                     str.tostring(
                         finalTradeR,
                         "#.##") +
                     "R",
                     style=label.style_label_left,
                     color=color.green,
                     textcolor=color.white)


            // Keep historical drawings.
            activeEntryLine := na
            activeSLLine := na
            activeTP1Line := na
            activeTP2Line := na

            activeRiskBox := na
            activeProfitBox := na

            activeEntryLabel := na
            activeSLLabel := na
            activeTP1Label := na
            activeTP2Label := na


            // Record the close bar so older setups cannot be activated after this trade.
            lastTradeCloseBar := bar_index

            activeTrade := false

            activeDirection := 0
            activeSetupIndex := na
            activeEntryBar := na

            activeEntry := na
            activeSL := na
            activeRisk := na
            activeTP1 := na
            activeTP2 := na

            activeTP1Hit := false
            activeTradeDrawn := false


//══════════════════════════════════════════════════════════════════════════════
//══════════════════════════════════════════════════════════════════════════════
// ACTIVATE WAITING TRADE CANDIDATE
// ONLY THE LATEST 3C RECLAIM CAN ACTIVATE
//══════════════════════════════════════════════════════════════════════════════

if barstate.isconfirmed and
     enableTrade and
     not activeTrade and
     array.size(setupDirections) > 0

    // Only the MOST RECENT 3C reclaim is eligible to activate a trade.
    // Older trade candidates must never be activated after a newer reclaim
    // appears. This prevents an old bullish candidate from opening a LONG
    // when the latest reclaim is bearish (and vice versa).
    int pendingIndex = array.size(setupDirections) - 1

    bool latestSetupFormedAfterLastTradeClose =
         na(lastTradeCloseBar) or
         array.get(setupBars, pendingIndex) > lastTradeCloseBar

    bool latestCandidateReady =
         array.get(setupTradeCandidate, pendingIndex) and
         array.get(setup50Confirmed, pendingIndex) and
         not array.get(setupFailed, pendingIndex) and
         latestSetupFormedAfterLastTradeClose

    if latestCandidateReady
        activeTrade := true
        activeDirection := array.get(setupDirections, pendingIndex)
        activeSetupIndex := pendingIndex
        activeEntryBar := array.get(setupBOSBars, pendingIndex)
        activeEntry := array.get(setupTradeEntry, pendingIndex)
        activeSL := array.get(setupTradeSL, pendingIndex)
        activeRisk := array.get(setupTradeRisk, pendingIndex)
        activeTP1 := array.get(setupTradeTP1, pendingIndex)
        activeTP2 := array.get(setupTradeTP2, pendingIndex)
        activeTP1Hit := false
        activeTradeDrawn := false
        totalTrades += 1
        array.set(setupTradeCandidate, pendingIndex, false)
        array.set(setupDiagnostic, pendingIndex, "TRADE ACTIVE — " + (activeDirection == DIR_BULL ? "LONG" : "SHORT"))
        delayedTradeActivationNow := true
        tradePositionReadyNow := true


//══════════════════════════════════════════════════════════════════════════════
// DRAW DELAYED TRADE POSITION
//══════════════════════════════════════════════════════════════════════════════

if delayedTradeActivationNow and activeTrade and showTradePosition and not activeTradeDrawn

    int drawStartBar = activeEntryBar

    if activeDirection == DIR_BULL
        activeRiskBox := box.new(left=drawStartBar, top=activeEntry, right=bar_index + 1, bottom=activeSL, bgcolor=ACTIVE_RISK_BG, border_color=ACTIVE_RISK_BORDER, extend=extend.right)
        activeProfitBox := box.new(left=drawStartBar, top=activeTP2, right=bar_index + 1, bottom=activeEntry, bgcolor=ACTIVE_PROFIT_BG, border_color=ACTIVE_PROFIT_BORDER, extend=extend.right)
    else
        activeRiskBox := box.new(left=drawStartBar, top=activeSL, right=bar_index + 1, bottom=activeEntry, bgcolor=ACTIVE_RISK_BG, border_color=ACTIVE_RISK_BORDER, extend=extend.right)
        activeProfitBox := box.new(left=drawStartBar, top=activeEntry, right=bar_index + 1, bottom=activeTP2, bgcolor=ACTIVE_PROFIT_BG, border_color=ACTIVE_PROFIT_BORDER, extend=extend.right)

    activeEntryLine := line.new(drawStartBar, activeEntry, bar_index + 1, activeEntry, extend=extend.right, color=ACTIVE_ENTRY_COLOR, style=line.style_dashed, width=2)
    activeSLLine := line.new(drawStartBar, activeSL, bar_index + 1, activeSL, extend=extend.right, color=ACTIVE_SL_COLOR, style=line.style_dashed, width=2)
    activeTP1Line := line.new(drawStartBar, activeTP1, bar_index + 1, activeTP1, extend=extend.right, color=ACTIVE_TP_COLOR, style=line.style_dashed, width=1)
    activeTP2Line := line.new(drawStartBar, activeTP2, bar_index + 1, activeTP2, extend=extend.right, color=ACTIVE_TP_COLOR, style=line.style_dashed, width=2)

    if showTradeLabels
        activeEntryLabel := label.new(drawStartBar, activeEntry, "ENTRY\n" + str.tostring(activeEntry, format.mintick), style=label.style_label_left, color=color.blue, textcolor=color.white)
        activeSLLabel := label.new(drawStartBar, activeSL, "SL\n" + str.tostring(activeSL, format.mintick), style=label.style_label_left, color=color.red, textcolor=color.white)
        activeTP1Label := label.new(drawStartBar, activeTP1, "TP1 • 1R\n" + str.tostring(activeTP1, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
        activeTP2Label := label.new(drawStartBar, activeTP2, "TP2 • " + str.tostring(finalRR, "#.##") + "R\n" + str.tostring(activeTP2, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)

    activeTradeDrawn := true


// DASHBOARD POSITION
//══════════════════════════════════════════════════════════════════════════════

dashboardPos =
     dashboardPosition == "Top Left" ?
         position.top_left :
     dashboardPosition == "Bottom Right" ?
         position.bottom_right :
     dashboardPosition == "Bottom Left" ?
         position.bottom_left :
         position.top_right


//══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
//══════════════════════════════════════════════════════════════════════════════

var table dashboard =
     table.new(
         dashboardPos,
         3,
         26,
         bgcolor=color.rgb(18, 18, 18),
         frame_color=color.gray,
         frame_width=1,
         border_color=color.rgb(70, 70, 70),
         border_width=1)


if barstate.islast

    table.clear(
         dashboard,
         0,
         0,
         2,
         25)


    if showDashboard

        //══════════════════════════════════════════════════════════════════════
        // SELECT DASHBOARD SETUP
        //
        // When a trade is active, show the active setup.
        // When no trade is active, show the latest setup but keep
        // every dashboard status in PENDING state.
        //══════════════════════════════════════════════════════════════════════

        int dashboardSetupIndex = na


        if activeTrade and
             not na(activeSetupIndex)

            dashboardSetupIndex :=
                 activeSetupIndex
        else if array.size(setupDirections) > 0

            // Revert to the latest setup when no trade is active.
            // Status fields are shown as PENDING until a trade is active.
            dashboardSetupIndex :=
                 array.size(setupDirections) - 1

        // HEADER
        //══════════════════════════════════════════════════════════════════════

        table.cell(
             dashboard,
             0,
             0,
             "3C RECLAIM",
             text_color=color.white,
             bgcolor=color.rgb(35, 55, 100))


        table.cell(
             dashboard,
             1,
             0,
             "STATUS",
             text_color=color.white,
             bgcolor=color.rgb(35, 55, 100))


        table.cell(
             dashboard,
             2,
             0,
             "DETAIL",
             text_color=color.white,
             bgcolor=color.rgb(35, 55, 100))


        //══════════════════════════════════════════════════════════════════════
        // NO SETUP
        //══════════════════════════════════════════════════════════════════════

        if na(dashboardSetupIndex)

            table.cell(
                 dashboard,
                 0,
                 1,
                 "NO SETUP",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 1,
                 "PENDING",
                 text_color=color.yellow,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 1,
                 "Waiting for new 3C reclaim",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


        else

            int idx =
                 dashboardSetupIndex


            int direction =
                 array.get(
                     setupDirections,
                     idx)


            bool failed =
                 array.get(
                     setupFailed,
                     idx)


            string diagnostic =
                 array.get(
                     setupDiagnostic,
                     idx)


            bool bosConfirmed =
                 array.get(
                     setupBOSConfirmed,
                     idx)


            bool confirmation50 =
                 array.get(
                     setup50Confirmed,
                     idx)


            float midpoint =
                 array.get(
                     setupBOSMidpoints,
                     idx)


            string directionText =
                 direction == DIR_BULL ?
                     "BULLISH" :
                     "BEARISH"


            string overallStatus =
                 activeTrade and
                 activeSetupIndex == idx ?
                     "TRADE ACTIVE" :
                 failed ?
                     "FAILED" :
                 confirmation50 ?
                     "TRADE READY" :
                 bosConfirmed ?
                     "BOS CONFIRMED" :
                     "IN PROGRESS"


            color directionBg =
                 direction == DIR_BULL ?
                     color.rgb(20, 100, 55) :
                     color.rgb(120, 35, 35)


            //══════════════════════════════════════════════════════════════════
            // CURRENT SETUP
            //══════════════════════════════════════════════════════════════════

            table.cell(
                 dashboard,
                 0,
                 1,
                 directionText,
                 text_color=color.white,
                 bgcolor=directionBg)


            table.cell(
                 dashboard,
                 1,
                 1,
                 overallStatus,
                 text_color=
                     not activeTrade ?
                         color.yellow :
                     activeTrade and
                     activeSetupIndex == idx ?
                         color.lime :
                     failed ?
                         color.red :
                         color.lime,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 1,
                 diagnostic,
                 text_color=
                     failed ? color.red :
                     activeTrade and activeSetupIndex == idx ? color.lime :
                     confirmation50 ? color.lime :
                     color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // 3C RECLAIM
            //══════════════════════════════════════════════════════════════════

            table.cell(
                 dashboard,
                 0,
                 2,
                 "3C RECLAIM",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 2,
                 not activeTrade ?
                     "PENDING" :
                 failed ?
                     "FAILED" :
                     "DONE",
                 text_color=
                     not activeTrade ?
                         color.yellow :
                     failed ?
                         color.red :
                         color.lime,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 2,
                 "Pattern confirmed",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // SUCCESSIVE INVALIDATION
            //══════════════════════════════════════════════════════════════════

            string invalidationStatus =
                  not activeTrade ?
                      "PENDING" :
                  not enableStep2 ?
                     "OFF" :
                 failed ?
                     "FAILED" :
                     "PASSED"


            table.cell(
                 dashboard,
                 0,
                 3,
                 "SUCCESSIVE INVALIDATION",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 3,
                 invalidationStatus,
                 text_color=
                     invalidationStatus == "FAILED" ?
                         color.red :
                     invalidationStatus == "PASSED" ?
                         color.lime :
                         color.gray,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 3,
                 enableStep2 ?
                     "C1 level protected" :
                     "Disabled",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // BOS
            //══════════════════════════════════════════════════════════════════

            string bosStatus =
                  not activeTrade ?
                      "PENDING" :
                  not enableStep3 ?
                     "OFF" :
                 failed ?
                     "FAILED" :
                 bosConfirmed ?
                     "DONE" :
                     "WAITING"


            table.cell(
                 dashboard,
                 0,
                 4,
                 "BOS CONFIRMATION",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 4,
                 bosStatus,
                 text_color=
                     bosStatus == "DONE" ?
                         color.lime :
                     bosStatus == "FAILED" ?
                         color.red :
                         color.yellow,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 4,
                 bosConfirmed ?
                     "Structure broken" :
                     "Waiting for BOS",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // BOS 50%
            //══════════════════════════════════════════════════════════════════

            string fiftyStatus =
                  not activeTrade ?
                      "PENDING" :
                  not enableStep4 ?
                     "OFF" :
                 not enableStep3 ?
                     "LOCKED" :
                 failed ?
                     "FAILED" :
                 not bosConfirmed ?
                     "LOCKED" :
                 confirmation50 ?
                     "DONE" :
                     "WAITING"


            table.cell(
                 dashboard,
                 0,
                 5,
                 "BOS 50% CONFIRMATION",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 5,
                 fiftyStatus,
                 text_color=
                     fiftyStatus == "DONE" ?
                         color.lime :
                     fiftyStatus == "FAILED" ?
                         color.red :
                     fiftyStatus == "WAITING" ?
                         color.yellow :
                         color.gray,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 5,
                 not enableStep4 ?
                     "Disabled" :
                 not bosConfirmed ?
                     "Waiting for BOS" :
                 confirmation50 ?
                     "Midpoint confirmed" :
                     "Immediate next candle",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // TRADE
            //══════════════════════════════════════════════════════════════════

            bool candidateWaiting =
                 enableTrade and
                 array.get(setupTradeCandidate, idx) and
                 confirmation50 and
                 not failed

            string tradeStatus =
                  not activeTrade ?
                      "PENDING" :
                  not enableTrade ?
                     "OFF" :
                 activeTrade and activeSetupIndex == idx ?
                     "ACTIVE" :
                 candidateWaiting and activeTrade ?
                     "BLOCKED" :
                 candidateWaiting ?
                     "READY" :
                     "WAITING"


            table.cell(
                 dashboard,
                 0,
                 6,
                 "TRADE",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 6,
                 tradeStatus,
                 text_color=
                     tradeStatus == "ACTIVE" or tradeStatus == "READY" ?
                         color.lime :
                     tradeStatus == "BLOCKED" ?
                         color.orange :
                     tradeStatus == "OFF" ?
                         color.gray :
                         color.yellow,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 6,
                 activeTrade and activeSetupIndex == idx ?
                     "BOS close = Entry" :
                 candidateWaiting and activeTrade ?
                     "Blocked — another trade active" :
                 candidateWaiting ?
                     "Trade candidate ready" :
                     "Waiting for BOS / 50%",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // ENTRY
            //══════════════════════════════════════════════════════════════════

            table.cell(
                 dashboard,
                 0,
                 7,
                 "ENTRY",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 7,
                 activeTrade and activeSetupIndex == idx ?
                     str.tostring(activeEntry, format.mintick) :
                 candidateWaiting ?
                     str.tostring(array.get(setupTradeEntry, idx), format.mintick) :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 7,
                 "BOS confirmed close",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // SL
            //══════════════════════════════════════════════════════════════════

            table.cell(
                 dashboard,
                 0,
                 8,
                 "SL",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 8,
                 activeTrade and activeSetupIndex == idx ?
                     str.tostring(activeSL, format.mintick) :
                 candidateWaiting ?
                     str.tostring(array.get(setupTradeSL, idx), format.mintick) :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 8,
                 "C2 sweep",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // TP1
            //══════════════════════════════════════════════════════════════════

            table.cell(
                 dashboard,
                 0,
                 9,
                 "TP1 • 1R",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 9,
                 activeTrade and activeSetupIndex == idx ?
                     str.tostring(activeTP1, format.mintick) :
                 candidateWaiting ?
                     str.tostring(array.get(setupTradeTP1, idx), format.mintick) :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 9,
                 activeTrade and
                 activeSetupIndex == idx and
                 activeTP1Hit ?
                     "50% CLOSED" :
                 candidateWaiting ?
                     "1R TARGET — READY" :
                     "1R TARGET",
                 text_color=
                     activeTrade and
                     activeSetupIndex == idx and
                     activeTP1Hit ?
                         color.lime :
                         color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // TP2
            //══════════════════════════════════════════════════════════════════

            table.cell(
                 dashboard,
                 0,
                 10,
                 "TP2",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 10,
                 activeTrade and activeSetupIndex == idx ?
                     str.tostring(activeTP2, format.mintick) :
                 candidateWaiting ?
                     str.tostring(array.get(setupTradeTP2, idx), format.mintick) :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 10,
                 str.tostring(
                     finalRR,
                     "#.##") +
                 "R",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // HISTORY
            //══════════════════════════════════════════════════════════════════

            float winRate =
                 totalTrades > 0 ?
                     winningTrades * 100.0 / totalTrades :
                     0.0


            table.cell(
                 dashboard,
                 0,
                 11,
                 "HISTORY",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 11,
                 "W " +
                 str.tostring(winningTrades) +
                 " / L " +
                 str.tostring(losingTrades),
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 11,
                 str.tostring(
                     winRate,
                     "#.##") +
                 "% | " +
                 str.tostring(
                     totalRealizedR,
                     "#.##") +
                 "R",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // BOS MIDPOINT
            //══════════════════════════════════════════════════════════════════

            table.cell(
                 dashboard,
                 0,
                 12,
                 "BOS MIDPOINT",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 12,
                 bosConfirmed and
                 not na(midpoint) ?
                     str.tostring(
                         midpoint,
                         format.mintick) :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 12,
                 "50% reference",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 0,
                 13,
                 "BOS LEVEL",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            float frozenBOSLevel =
                 array.get(
                     setupStructureLevels,
                     idx)


            table.cell(
                 dashboard,
                 1,
                 13,
                 not na(frozenBOSLevel) ?
                     str.tostring(
                         frozenBOSLevel,
                         format.mintick) :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 13,
                 "Pivot candle CLOSE",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // LAST CONFIRMED CLOSE
            //══════════════════════════════════════════════════════════════════

            float lastConfirmedClose =
                 barstate.isrealtime ?
                     close[1] :
                     close


            bool bosCloseCondition =
                 not na(frozenBOSLevel) and
                 (direction == DIR_BULL ?
                     lastConfirmedClose > frozenBOSLevel :
                     lastConfirmedClose < frozenBOSLevel)


            table.cell(
                 dashboard,
                 0,
                 14,
                 "CONFIRMED CLOSE",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 1,
                 14,
                 str.tostring(
                     lastConfirmedClose,
                     format.mintick),
                 text_color=
                     bosCloseCondition ?
                         color.lime :
                         color.yellow,
                 bgcolor=color.rgb(25, 25, 25))


            table.cell(
                 dashboard,
                 2,
                 14,
                 not na(frozenBOSLevel) ?
                     direction == DIR_BULL ?
                         (bosCloseCondition ?
                             "CLOSE > BOS LEVEL" :
                             "CLOSE <= BOS LEVEL") :
                         (bosCloseCondition ?
                             "CLOSE < BOS LEVEL" :
                             "CLOSE >= BOS LEVEL") :
                     "No BOS level",
                 text_color=
                     bosCloseCondition ?
                         color.lime :
                         color.silver,
                 bgcolor=color.rgb(25, 25, 25))


            //══════════════════════════════════════════════════════════════════
            // TRADE QUALITY DIAGNOSTIC
            // Diagnostic only — it does not block or filter trades.
            //══════════════════════════════════════════════════════════════════

            float qualityScore =
                 array.get(
                     setupQualityScores,
                     idx)

            float bosBodyScore =
                 array.get(
                     setupBOSBodyScores,
                     idx)

            float bosCloseScore =
                 array.get(
                     setupBOSCloseScores,
                     idx)

            float bosBreakScore =
                 array.get(
                     setupBOSBreakScores,
                     idx)

            float fiftyScore =
                 array.get(
                     setup50Scores,
                     idx)

            float locationPosition =
                 array.get(
                     setupLocationPosition,
                     idx)

            float locationRoom =
                 array.get(
                     setupLocationRoom,
                     idx)

            float preEntryMoveR =
                 array.get(
                     setupPreEntryMoveR,
                     idx)

            string locationGrade =
                 not bosConfirmed or na(locationPosition) ?
                     "PENDING" :
                 locationPosition >= locationExtremeThreshold ?
                     "EXTENDED" :
                 locationPosition >= locationCautionThreshold ?
                     "CAUTION" :
                     "GOOD"

            color locationColor =
                 locationGrade == "EXTENDED" ?
                     color.red :
                 locationGrade == "CAUTION" ?
                     color.yellow :
                 locationGrade == "GOOD" ?
                     color.lime :
                     color.gray

            string qualityGrade =
                 not bosConfirmed ?
                     "PENDING" :
                 not confirmation50 ?
                     str.tostring(qualityScore, "#.0") + "/75" :
                 qualityScore >= 80.0 ?
                     "A" :
                 qualityScore >= 65.0 ?
                     "B" :
                 qualityScore >= 50.0 ?
                     "C" :
                     "D"

            color qualityColor =
                 not bosConfirmed ?
                     color.gray :
                 not confirmation50 ?
                     color.yellow :
                 qualityScore >= 80.0 ?
                     color.lime :
                 qualityScore >= 65.0 ?
                     color.green :
                 qualityScore >= 50.0 ?
                     color.yellow :
                     color.red

            table.cell(
                 dashboard,
                 0,
                 15,
                 "QUALITY SCORE",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 15,
                 showQualityDiagnostic ?
                     qualityGrade :
                     "OFF",
                 text_color=showQualityDiagnostic ? qualityColor : color.gray,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 15,
                 not showQualityDiagnostic ?
                     "Diagnostic disabled" :
                 not bosConfirmed ?
                     "Waiting for BOS" :
                 not confirmation50 ?
                     str.tostring(qualityScore, "#.0") + "/75 BOS quality" :
                     str.tostring(qualityScore, "#.0") + "/100 diagnostic only",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 16,
                 "BOS BODY",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 16,
                 showQualityDiagnostic and bosConfirmed ?
                     str.tostring(bosBodyScore, "#.0") + "/30" :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 16,
                 "Body strength",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 17,
                 "BOS CLOSE",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 17,
                 showQualityDiagnostic and bosConfirmed ?
                     str.tostring(bosCloseScore, "#.0") + "/25" :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 17,
                 "Close near favorable extreme",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 18,
                 "BOS BREAK",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 18,
                 showQualityDiagnostic and bosConfirmed ?
                     str.tostring(bosBreakScore, "#.0") + "/20" :
                     "—",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 18,
                 "Distance beyond BOS",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 19,
                 "BOS 50% QUALITY",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 19,
                 showQualityDiagnostic and confirmation50 ?
                     str.tostring(fiftyScore, "#.0") + "/25" :
                     "—",
                 text_color=
                     confirmation50 ? color.lime : color.yellow,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 19,
                 confirmation50 ?
                     "Beyond midpoint" :
                     "Pending confirmation",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            // SETUP LOCATION / LATE ENTRY DIAGNOSTIC

            table.cell(
                 dashboard,
                 0,
                 20,
                 "SETUP LOCATION",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 20,
                 showQualityDiagnostic ? locationGrade : "OFF",
                 text_color=showQualityDiagnostic ? locationColor : color.gray,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 20,
                 not showQualityDiagnostic ?
                     "Diagnostic disabled" :
                 not bosConfirmed ?
                     "Waiting for BOS" :
                     "Recent range location",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 21,
                 "RANGE POSITION",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 21,
                 showQualityDiagnostic and bosConfirmed and not na(locationPosition) ?
                     str.tostring(locationPosition, "#.0") + "%" :
                     "—",
                 text_color=locationColor,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 21,
                 "Position in last " + str.tostring(locationLookback) + " bars",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 22,
                 "ROOM TO EXTREME",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 22,
                 showQualityDiagnostic and bosConfirmed and not na(locationRoom) ?
                     str.tostring(locationRoom, "#.0") + "%" :
                     "—",
                 text_color=
                     not na(locationRoom) and locationRoom <= (100.0 - locationExtremeThreshold) ?
                         color.red :
                     not na(locationRoom) and locationRoom <= (100.0 - locationCautionThreshold) ?
                         color.yellow :
                         color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 22,
                 "Room before recent range extreme",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 23,
                 "PRE-ENTRY MOVE",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 23,
                 showQualityDiagnostic and bosConfirmed and not na(preEntryMoveR) ?
                     str.tostring(preEntryMoveR, "#.0") + "R" :
                     "—",
                 text_color=
                     not na(preEntryMoveR) and preEntryMoveR >= 3.0 ?
                         color.red :
                     not na(preEntryMoveR) and preEntryMoveR >= 2.0 ?
                         color.yellow :
                         color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 23,
                 "Range edge → BOS entry",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 24,
                 "LOCATION MODE",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 24,
                 "DIAGNOSTIC",
                 text_color=color.aqua,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 24,
                 "Does NOT block trades",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 0,
                 25,
                 "QUALITY MODE",
                 text_color=color.white,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 1,
                 25,
                 "DIAGNOSTIC",
                 text_color=color.aqua,
                 bgcolor=color.rgb(25, 25, 25))

            table.cell(
                 dashboard,
                 2,
                 25,
                 "Does NOT block trades",
                 text_color=color.silver,
                 bgcolor=color.rgb(25, 25, 25))


//══════════════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════════════

alertcondition(
     tradePositionReadyNow,
     title="TRADE POSITION READY",
     message="3C TRADE POSITION READY - BOS 50% CONFIRMED")
````
