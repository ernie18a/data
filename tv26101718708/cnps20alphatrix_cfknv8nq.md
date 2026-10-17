# CNPS20-ALPHA_TRIX

- url: https://www.tradingview.com/script/cFKnV8nq-CNPS20-ALPHA-TRIX/
- type: strategy
- pine_id: PUB;e7ed0ccc7be74027bfd8bed6ebb52b9d
- version: 1.0

## Description

CNPS20 ALPHA TRIX

CNPS20 is a trend-following momentum strategy built around the TRIX oscillator and a combination of market-regime filters.

The strategy attempts to participate only when:

• Momentum changes direction
• The market is not excessively choppy
• Trend strength is sufficient
• Price agrees with the broader trend filter

━━━━━━━━━━━━━━━━━━
1. STRATEGY CONCEPT
━━━━━━━━━━━━━━━━━━

TRIX is the primary momentum trigger.

TRIX is calculated from a triple-smoothed exponential moving average.

The strategy monitors the TRIX line around the zero level.

LONG CONCEPT

TRIX crosses upward through zero
+
Market regime filters are valid
+
Trend filters are valid
→ LONG

SHORT CONCEPT

TRIX crosses downward through zero
+
Market regime filters are valid
+
Trend filters are valid
→ SHORT

━━━━━━━━━━━━━━━━━━
2. TRIX SETTINGS
━━━━━━━━━━━━━━━━━━

Default TRIX Length:

8

The strategy evaluates both:

• TRIX direction
• Zero-line transition

The zero-cross acts as the primary directional event.

━━━━━━━━━━━━━━━━━━
3. CHOP FILTER
━━━━━━━━━━━━━━━━━━

CNPS20 uses the Choppiness Index to avoid low-quality sideways conditions.

Default threshold:

CHOP < 50

When CHOP is too high, the market is considered excessively rotational and the strategy avoids new entries.

This filter is intended to reduce trend signals generated inside range-bound conditions.

━━━━━━━━━━━━━━━━━━
4. ADX FILTER
━━━━━━━━━━━━━━━━━━

ADX is used as a trend-strength filter.

Default source settings:

ADX Length: 7
Minimum ADX: 20

A valid setup requires ADX to indicate sufficient directional strength.

ADX itself does not determine Long or Short direction.

It measures the strength of the current trend environment.

━━━━━━━━━━━━━━━━━━
5. EMA200 TREND FILTER
━━━━━━━━━━━━━━━━━━

An EMA200 filter is available and enabled in the default trend configuration.

LONG:

Price should trade above EMA200.

SHORT:

Price should trade below EMA200.

The EMA filter is intended to prevent TRIX signals from fighting the broader trend.

━━━━━━━━━━━━━━━━━━
6. ENTRY STRUCTURE
━━━━━━━━━━━━━━━━━━

A valid entry therefore combines several layers:

TRIX momentum event
+
Low enough Choppiness
+
Sufficient ADX
+
EMA200 directional alignment

This produces fewer signals than a standalone TRIX crossover strategy.

━━━━━━━━━━━━━━━━━━
7. RISK MANAGEMENT
━━━━━━━━━━━━━━━━━━

CNPS20 supports two risk-management approaches.

FIXED POINTS

Default CNPS configuration:

Stop Loss: 5 points
Take Profit: 15 points

ATR MODE

The source strategy also supports ATR-based exits.

Original concept:

Stop Loss approximately 1 ATR
Take Profit approximately 1.5 ATR

Users can compare fixed-point and volatility-adjusted exits through backtesting.

━━━━━━━━━━━━━━━━━━
8. TRADE DIRECTION
━━━━━━━━━━━━━━━━━━

CNPS20 supports:

• Long
• Short
• Both

The strategy can also react to opposite momentum conditions depending on the selected configuration.

Pyramiding is disabled.

Default position size:

3 contracts

━━━━━━━━━━━━━━━━━━
9. TIMEFRAME
━━━━━━━━━━━━━━━━━━

CNPS20 operates on the current chart timeframe.

All primary indicators are calculated using the active chart data.

This makes the strategy suitable for comparative testing across different intraday timeframes.

━━━━━━━━━━━━━━━━━━
10. SESSION MANAGEMENT
━━━━━━━━━━━━━━━━━━

Default timezone:

Asia/Ho_Chi_Minh

The CNPS wrapper limits entries to the configured intraday trading session and includes end-of-session position management.

━━━━━━━━━━━━━━━━━━
11. BACKTEST ASSUMPTIONS
━━━━━━━━━━━━━━━━━━

Default Strategy Tester configuration:

Initial Capital: 100,000,000
Position Size: 3 contracts
Commission: 10,000 VND per contract
Slippage: 3 ticks
Pyramiding: 0

Transaction costs are included in the strategy settings.

━━━━━━━━━━━━━━━━━━
12. HOW TO EVALUATE THE STRATEGY
━━━━━━━━━━━━━━━━━━

Because CNPS20 combines several filters, it should be evaluated both as a complete system and by individual component.

Useful comparisons include:

• EMA200 filter ON / OFF
• CHOP threshold
• ADX threshold
• Fixed exit versus ATR exit
• Long versus Short performance
• Different TRIX lengths

Important Strategy Tester metrics include:

• Profit Factor
• Maximum Drawdown
• Average Trade
• Win Rate
• Total Trades
• Average Holding Time
• Commission sensitivity

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This strategy is provided for educational, research and backtesting purposes only.

It does not constitute financial advice or a recommendation to trade any financial instrument.

Past performance does not guarantee future results.

Trading futures and leveraged products involves substantial risk. Users are solely responsible for their own trading decisions and risk management.

## Source Code

````pine
//@version=6
strategy(
     title="CNPS20 ALPHA-TRIX",
     shorttitle="CNPS20 ALPHA-TRIX",
     overlay=true,
     initial_capital=100000000,
     default_qty_type=strategy.fixed,
     default_qty_value=3,
     pyramiding=0,
     margin_long=0,
     margin_short=0,
     slippage=3,
     commission_type=strategy.commission.cash_per_contract,
     commission_value=10000,
     fill_orders_on_standard_ohlc=true,
     process_orders_on_close=true,
     calc_on_order_fills=true,
     max_labels_count=300,
     max_lines_count=300,
     max_bars_back=5000
)


// ╔══════════════════════════════════════════════════════════════════════╗
// ║                       CNPS20 ALPHA-TRIX                            ║
// ║             TREND + REGIME + TRIX MOMENTUM ENTRY                  ║
// ╠══════════════════════════════════════════════════════════════════════╣
// ║ TIMEFRAME       : CURRENT CHART TIMEFRAME                          ║
// ║ POSITION        : 3 CONTRACTS                                      ║
// ║ COMMISSION      : VND 10,000 / CONTRACT                           ║
// ║ SLIPPAGE        : 3 TICKS                                          ║
// ║                                                                    ║
// ║ LONG                                                               ║
// ║ CHOP < Threshold                                                   ║
// ║ + ADX > Minimum                                                    ║
// ║ + Close > Trend EMA                                                ║
// ║ + TRIX crosses above Zero                                          ║
// ║ -> LONG                                                            ║
// ║                                                                    ║
// ║ SHORT                                                              ║
// ║ CHOP < Threshold                                                   ║
// ║ + ADX > Minimum                                                    ║
// ║ + Close < Trend EMA                                                ║
// ║ + TRIX crosses below Zero                                          ║
// ║ -> SHORT                                                           ║
// ║                                                                    ║
// ║ DEFAULT EXIT                                                       ║
// ║ SL = 5 POINTS                                                      ║
// ║ TP = 15 POINTS                                                     ║
// ╚══════════════════════════════════════════════════════════════════════╝


// ============================================================================
// SECTION 1: TRADE CONTROL
// ============================================================================

tradeDirection = input.string(
     "Both",
     title="Trade Direction",
     options=[
         "Long",
         "Short",
         "Both"
     ],
     group="Trade Control"
)

bool allowLong = (
     tradeDirection == "Long" or
     tradeDirection == "Both"
)

bool allowShort = (
     tradeDirection == "Short" or
     tradeDirection == "Both"
)

allowReversal = input.bool(
     true,
     title="Reverse Position On Opposite Signal?",
     group="Trade Control"
)

maximumTradesPerDay = input.int(
     0,
     title="Maximum Trades Per Day (0 = Unlimited)",
     minval=0,
     maxval=50,
     group="Trade Control"
)

cooldownBars = input.int(
     0,
     title="Cooldown Bars After Entry",
     minval=0,
     maxval=100,
     group="Trade Control"
)


// ============================================================================
// SECTION 2: CHOP FILTER
// ============================================================================

chopLength = input.int(
     14,
     title="Choppiness Length",
     minval=2,
     group="Regime Filter"
)

chopThreshold = input.float(
     50.0,
     title="Maximum Choppiness",
     minval=0.0,
     maxval=100.0,
     step=1.0,
     group="Regime Filter"
)


// ============================================================================
// SECTION 3: ADX FILTER
// ============================================================================

adxLength = input.int(
     7,
     title="ADX Length",
     minval=1,
     group="Regime Filter"
)

adxMinimum = input.float(
     20.0,
     title="Minimum ADX",
     minval=0.0,
     step=1.0,
     group="Regime Filter"
)


// ============================================================================
// SECTION 4: TREND FILTER
// ============================================================================

useTrendFilter = input.bool(
     true,
     title="Use EMA Trend Filter?",
     group="Trend"
)

trendEMALength = input.int(
     200,
     title="Trend EMA Length",
     minval=1,
     group="Trend"
)


// ============================================================================
// SECTION 5: TRIX TRIGGER
// ============================================================================

trixLength = input.int(
     8,
     title="TRIX Length",
     minval=1,
     group="TRIX"
)

minimumTrixSlope = input.float(
     0.0,
     title="Minimum Absolute TRIX Slope",
     minval=0.0,
     step=0.01,
     group="TRIX"
)


// ============================================================================
// SECTION 6: EXIT MODE
// ============================================================================

exitMode = input.string(
     "Fixed Points",
     title="Exit Mode",
     options=[
         "Fixed Points",
         "ATR"
     ],
     group="Risk Management"
)


// ============================================================================
// SECTION 7: FIXED POINT EXIT
// ============================================================================

stopLossPoints = input.float(
     5.0,
     title="Fixed Stop Loss (Points)",
     minval=0.1,
     step=0.5,
     group="Risk Management"
)

takeProfitPoints = input.float(
     15.0,
     title="Fixed Take Profit (Points)",
     minval=0.1,
     step=0.5,
     group="Risk Management"
)


// ============================================================================
// SECTION 8: ATR EXIT
// ============================================================================

atrLength = input.int(
     7,
     title="ATR Length",
     minval=1,
     group="ATR Exit"
)

atrStopMultiplier = input.float(
     1.0,
     title="ATR Stop Multiplier",
     minval=0.1,
     step=0.1,
     group="ATR Exit"
)

atrTakeProfitMultiplier = input.float(
     1.5,
     title="ATR Take Profit Multiplier",
     minval=0.1,
     step=0.1,
     group="ATR Exit"
)


// ============================================================================
// SECTION 9: OPTIONAL BREAK EVEN
// ============================================================================

useBreakEven = input.bool(
     false,
     title="Use Break Even?",
     group="Break Even"
)

breakEvenTriggerR = input.float(
     1.0,
     title="Break Even Trigger (R)",
     minval=0.25,
     step=0.25,
     group="Break Even"
)

breakEvenOffsetPoints = input.float(
     0.5,
     title="Break Even Offset (Points)",
     minval=0.0,
     step=0.5,
     group="Break Even"
)


// ============================================================================
// SECTION 10: SESSION
// ============================================================================

strategyTimezone = input.string(
     "Asia/Ho_Chi_Minh",
     title="Strategy Timezone",
     group="Session"
)

sessionStartHour = input.int(
     9,
     title="Entry Start Hour",
     minval=0,
     maxval=23,
     group="Session"
)

sessionStartMinute = input.int(
     0,
     title="Entry Start Minute",
     minval=0,
     maxval=59,
     group="Session"
)

lastEntryHour = input.int(
     14,
     title="Last Entry Hour",
     minval=0,
     maxval=23,
     group="Session"
)

lastEntryMinute = input.int(
     30,
     title="Last Entry Minute",
     minval=0,
     maxval=59,
     group="Session"
)

sessionEndHour = input.int(
     14,
     title="Force Close Hour",
     minval=0,
     maxval=23,
     group="Session"
)

sessionEndMinute = input.int(
     45,
     title="Force Close Minute",
     minval=0,
     maxval=59,
     group="Session"
)


// ============================================================================
// SECTION 11: ALERT CONTROL
// ============================================================================

disableSLTPAlerts = input.bool(
     false,
     title="Disable SL / TP Alerts?",
     group="Alerts"
)


// ============================================================================
// SECTION 12: DISPLAY
// ============================================================================

showTrendEMA = input.bool(
     true,
     title="Show Trend EMA?",
     group="Display"
)

showSignalMarkers = input.bool(
     false,
     title="Show Signal Markers?",
     group="Display"
)

showActiveSLTP = input.bool(
     true,
     title="Show Active SL / TP?",
     group="Display"
)

showDiagnostics = input.bool(
     false,
     title="Show Diagnostics?",
     group="Display"
)


// ============================================================================
// SECTION 13: TIME ENGINE
// ============================================================================
//
// No timeframe lock.
// Everything follows the CURRENT CHART TIMEFRAME.
//
// ============================================================================

int currentMinute = (
     hour(time, strategyTimezone) * 60 +
     minute(time, strategyTimezone)
)

int currentCloseMinute = (
     hour(time_close, strategyTimezone) * 60 +
     minute(time_close, strategyTimezone)
)

int sessionStartTotal = (
     sessionStartHour * 60 +
     sessionStartMinute
)

int lastEntryTotal = (
     lastEntryHour * 60 +
     lastEntryMinute
)

int sessionEndTotal = (
     sessionEndHour * 60 +
     sessionEndMinute
)

bool entrySession = (
     currentMinute >= sessionStartTotal and
     currentMinute <= lastEntryTotal
)


// ============================================================================
// SECTION 14: DAILY TRADE COUNTER
// ============================================================================

int dayKey = (
     year(time, strategyTimezone) * 10000 +
     month(time, strategyTimezone) * 100 +
     dayofmonth(time, strategyTimezone)
)

bool newTradingDay = (
     bar_index == 0 or
     dayKey != dayKey[1]
)

var int tradesToday = 0

if newTradingDay

    tradesToday := 0


// ============================================================================
// SECTION 15: TRUE RANGE
// ============================================================================

float trueRange = (
     bar_index == 0
     ? high - low
     : math.max(
         high - low,
         math.max(
             math.abs(
                 high -
                 close[1]
             ),
             math.abs(
                 low -
                 close[1]
             )
         )
     )
)


// ============================================================================
// SECTION 16: CHOPPINESS INDEX
// ============================================================================
//
// CHOP:
//
// 100 * log10(
//     Sum True Range /
//     (Highest High - Lowest Low)
// ) / log10(N)
//
// ============================================================================

float highestHigh = ta.highest(
     high,
     chopLength
)

float lowestLow = ta.lowest(
     low,
     chopLength
)

float chopRange = (
     highestHigh -
     lowestLow
)

float averageTrueRangeForChop = ta.sma(
     trueRange,
     chopLength
)

float trueRangeSum = (
     averageTrueRangeForChop *
     chopLength
)

float chopValue = 100.0

if (
     chopRange > 0 and
     not na(trueRangeSum) and
     trueRangeSum > 0
)

    chopValue := (
         100.0 *
         math.log10(
             trueRangeSum /
             chopRange
         ) /
         math.log10(
             chopLength
         )
    )


// ============================================================================
// SECTION 17: ADX / DMI
// ============================================================================

[diPlus, diMinus, adxValue] = ta.dmi(
     adxLength,
     adxLength
)


// ============================================================================
// SECTION 18: TREND EMA
// ============================================================================

float trendEMA = ta.ema(
     close,
     trendEMALength
)

bool uptrend = (
     close >
     trendEMA
)

bool downtrend = (
     close <
     trendEMA
)


// ============================================================================
// SECTION 19: TRIX
// ============================================================================
//
// Triple EMA:
//
// EMA1 = EMA(Close, Length)
// EMA2 = EMA(EMA1, Length)
// EMA3 = EMA(EMA2, Length)
//
// TRIX = 1-bar ROC of EMA3.
//
// ============================================================================

float trixEMA1 = ta.ema(
     close,
     trixLength
)

float trixEMA2 = ta.ema(
     trixEMA1,
     trixLength
)

float trixEMA3 = ta.ema(
     trixEMA2,
     trixLength
)

float trixValue = ta.roc(
     trixEMA3,
     1
)

float trixSlope = (
     trixValue -
     trixValue[1]
)


// ============================================================================
// SECTION 20: ATR
// ============================================================================

float fastATR = ta.atr(
     atrLength
)

float currentATRStopDistance = (
     fastATR *
     atrStopMultiplier
)

float currentATRTPDistance = (
     fastATR *
     atrTakeProfitMultiplier
)


// ============================================================================
// SECTION 21: REGIME FILTER
// ============================================================================

bool choppinessOK = (
     chopValue <
     chopThreshold
)

bool adxOK = (
     adxValue >
     adxMinimum
)

bool filtersMet = (
     choppinessOK and
     adxOK
)


// ============================================================================
// SECTION 22: TREND FILTER
// ============================================================================

bool trendLongOK = (
     not useTrendFilter or
     uptrend
)

bool trendShortOK = (
     not useTrendFilter or
     downtrend
)


// ============================================================================
// SECTION 23: TRIX TRIGGERS
// ============================================================================

bool bullishTrixCross = ta.crossover(
     trixValue,
     0.0
)

bool bearishTrixCross = ta.crossunder(
     trixValue,
     0.0
)

bool trixSlopeOK = (
     math.abs(
         trixSlope
     ) >=
     minimumTrixSlope
)

bool longTrigger = (
     bullishTrixCross and
     trixSlopeOK
)

bool shortTrigger = (
     bearishTrixCross and
     trixSlopeOK
)


// ============================================================================
// SECTION 24: RAW ENTRY SIGNALS
// ============================================================================

bool rawLongSignal = (
     allowLong and
     filtersMet and
     trendLongOK and
     longTrigger
)

bool rawShortSignal = (
     allowShort and
     filtersMet and
     trendShortOK and
     shortTrigger
)


// ============================================================================
// SECTION 25: POSITION STATE
// ============================================================================

bool positionFlat = (
     strategy.position_size == 0
)

bool positionLong = (
     strategy.position_size > 0
)

bool positionShort = (
     strategy.position_size < 0
)

bool newLongPosition = (
     positionLong and
     strategy.position_size[1] <= 0
)

bool newShortPosition = (
     positionShort and
     strategy.position_size[1] >= 0
)

bool positionJustClosed = (
     strategy.position_size == 0 and
     strategy.position_size[1] != 0
)


// ============================================================================
// SECTION 26: COOLDOWN
// ============================================================================

var int lastEntryBar = na

bool cooldownOK = (
     na(lastEntryBar) or
     bar_index -
     lastEntryBar >
     cooldownBars
)


// ============================================================================
// SECTION 27: DAILY TRADE LIMIT
// ============================================================================

bool tradeLimitOK = (
     maximumTradesPerDay == 0 or
     tradesToday <
     maximumTradesPerDay
)


// ============================================================================
// SECTION 28: ENTRY AVAILABILITY
// ============================================================================

bool longPositionStateOK = (
     positionFlat or
     (
         positionShort and
         allowReversal
     )
)

bool shortPositionStateOK = (
     positionFlat or
     (
         positionLong and
         allowReversal
     )
)

bool commonEntryApproval = (
     entrySession and
     currentCloseMinute <
     sessionEndTotal and
     tradeLimitOK and
     cooldownOK and
     barstate.isconfirmed
)


// ============================================================================
// SECTION 29: FINAL ENTRY SIGNALS
// ============================================================================

bool finalLongSignal = (
     commonEntryApproval and
     rawLongSignal and
     longPositionStateOK
)

bool finalShortSignal = (
     commonEntryApproval and
     rawShortSignal and
     shortPositionStateOK
)


// ============================================================================
// SECTION 30: PENDING EXIT DISTANCES
// ============================================================================
//
// ATR mode freezes ATR-derived distances on the entry signal.
//
// Fixed mode freezes 5 / 15 points by default.
//
// ============================================================================

var float pendingStopDistance = na
var float pendingTPDistance = na


// ============================================================================
// SECTION 31: LONG ENTRY
// ============================================================================

if finalLongSignal

    if exitMode == "ATR"

        pendingStopDistance := (
             currentATRStopDistance
        )

        pendingTPDistance := (
             currentATRTPDistance
        )

    else

        pendingStopDistance := (
             stopLossPoints
        )

        pendingTPDistance := (
             takeProfitPoints
        )


    strategy.entry(
         "Long",
         strategy.long,
         qty=3,
         comment="TRIX Long",
         alert_message="ENTRY_LONG_CNPS20_TRIX"
    )

    lastEntryBar := (
         bar_index
    )

    tradesToday += 1


// ============================================================================
// SECTION 32: SHORT ENTRY
// ============================================================================

if finalShortSignal

    if exitMode == "ATR"

        pendingStopDistance := (
             currentATRStopDistance
        )

        pendingTPDistance := (
             currentATRTPDistance
        )

    else

        pendingStopDistance := (
             stopLossPoints
        )

        pendingTPDistance := (
             takeProfitPoints
        )


    strategy.entry(
         "Short",
         strategy.short,
         qty=3,
         comment="TRIX Short",
         alert_message="ENTRY_SHORT_CNPS20_TRIX"
    )

    lastEntryBar := (
         bar_index
    )

    tradesToday += 1


// ============================================================================
// SECTION 33: ACTIVE EXIT STATE
// ============================================================================

var float activeEntryPrice = na
var float activeInitialRisk = na

var float activeLongSL = na
var float activeLongTP = na

var float activeShortSL = na
var float activeShortTP = na

var bool breakEvenActivated = false


// ============================================================================
// SECTION 34: INITIALIZE LONG EXIT
// ============================================================================

if newLongPosition

    activeEntryPrice := (
         strategy.position_avg_price
    )

    float longStopDistance = (
         pendingStopDistance
    )

    float longTPDistance = (
         pendingTPDistance
    )


    if (
         na(longStopDistance) or
         longStopDistance <= 0
    )

        longStopDistance := (
             stopLossPoints
        )


    if (
         na(longTPDistance) or
         longTPDistance <= 0
    )

        longTPDistance := (
             takeProfitPoints
        )


    activeInitialRisk := (
         longStopDistance
    )

    activeLongSL := (
         activeEntryPrice -
         longStopDistance
    )

    activeLongTP := (
         activeEntryPrice +
         longTPDistance
    )

    activeShortSL := na
    activeShortTP := na

    breakEvenActivated := false

    pendingStopDistance := na
    pendingTPDistance := na


// ============================================================================
// SECTION 35: INITIALIZE SHORT EXIT
// ============================================================================

if newShortPosition

    activeEntryPrice := (
         strategy.position_avg_price
    )

    float shortStopDistance = (
         pendingStopDistance
    )

    float shortTPDistance = (
         pendingTPDistance
    )


    if (
         na(shortStopDistance) or
         shortStopDistance <= 0
    )

        shortStopDistance := (
             stopLossPoints
        )


    if (
         na(shortTPDistance) or
         shortTPDistance <= 0
    )

        shortTPDistance := (
             takeProfitPoints
        )


    activeInitialRisk := (
         shortStopDistance
    )

    activeShortSL := (
         activeEntryPrice +
         shortStopDistance
    )

    activeShortTP := (
         activeEntryPrice -
         shortTPDistance
    )

    activeLongSL := na
    activeLongTP := na

    breakEvenActivated := false

    pendingStopDistance := na
    pendingTPDistance := na


// ============================================================================
// SECTION 36: LONG BREAK EVEN
// ============================================================================

if (
     positionLong and
     useBreakEven and
     not breakEvenActivated and
     not na(activeEntryPrice) and
     not na(activeInitialRisk)
)

    float longBETrigger = (
         activeEntryPrice +
         activeInitialRisk *
         breakEvenTriggerR
    )

    if high >= longBETrigger

        float newLongSL = (
             activeEntryPrice +
             breakEvenOffsetPoints
        )

        if (
             na(activeLongSL) or
             newLongSL >
             activeLongSL
        )

            activeLongSL := (
                 newLongSL
            )

        breakEvenActivated := true


// ============================================================================
// SECTION 37: SHORT BREAK EVEN
// ============================================================================

if (
     positionShort and
     useBreakEven and
     not breakEvenActivated and
     not na(activeEntryPrice) and
     not na(activeInitialRisk)
)

    float shortBETrigger = (
         activeEntryPrice -
         activeInitialRisk *
         breakEvenTriggerR
    )

    if low <= shortBETrigger

        float newShortSL = (
             activeEntryPrice -
             breakEvenOffsetPoints
        )

        if (
             na(activeShortSL) or
             newShortSL <
             activeShortSL
        )

            activeShortSL := (
                 newShortSL
            )

        breakEvenActivated := true


// ============================================================================
// SECTION 38: LONG EXIT
// ============================================================================

if (
     positionLong and
     not na(activeLongSL) and
     not na(activeLongTP)
)

    strategy.exit(
         "Long Exit",
         from_entry="Long",
         stop=activeLongSL,
         limit=activeLongTP,
         alert_profit="EXIT_LONG_TP_CNPS20",
         alert_loss="EXIT_LONG_SL_CNPS20",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 39: SHORT EXIT
// ============================================================================

if (
     positionShort and
     not na(activeShortSL) and
     not na(activeShortTP)
)

    strategy.exit(
         "Short Exit",
         from_entry="Short",
         stop=activeShortSL,
         limit=activeShortTP,
         alert_profit="EXIT_SHORT_TP_CNPS20",
         alert_loss="EXIT_SHORT_SL_CNPS20",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 40: POSITION CLEANUP
// ============================================================================

if positionJustClosed

    activeEntryPrice := na
    activeInitialRisk := na

    activeLongSL := na
    activeLongTP := na

    activeShortSL := na
    activeShortTP := na

    breakEvenActivated := false


// ============================================================================
// SECTION 41: SESSION END
// ============================================================================

bool finalSessionBar = (
     currentMinute <
     sessionEndTotal and
     currentCloseMinute >=
     sessionEndTotal
)

if finalSessionBar

    if strategy.position_size != 0

        strategy.close_all(
             immediately=true,
             comment="Session End",
             alert_message="SESSION_END_CNPS20"
        )


// ============================================================================
// SECTION 42: TREND EMA DISPLAY
// ============================================================================

plot(
     showTrendEMA and
     useTrendFilter
     ? trendEMA
     : na,
     title="Trend EMA",
     color=color.orange,
     linewidth=2
)


// ============================================================================
// SECTION 43: ACTIVE SL / TP DISPLAY
// ============================================================================

plot(
     showActiveSLTP and
     positionLong
     ? activeLongSL
     : na,
     title="Long SL",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showActiveSLTP and
     positionLong
     ? activeLongTP
     : na,
     title="Long TP",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showActiveSLTP and
     positionShort
     ? activeShortSL
     : na,
     title="Short SL",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showActiveSLTP and
     positionShort
     ? activeShortTP
     : na,
     title="Short TP",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr
)


// ============================================================================
// SECTION 44: SIGNAL MARKERS
// ============================================================================
//
// Optional setup markers only.
// Strategy Tester fills remain authoritative.
//
// ============================================================================

plotshape(
     showSignalMarkers and
     rawLongSignal,
     title="Long Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small,
     text="L",
     textcolor=color.white
)

plotshape(
     showSignalMarkers and
     rawShortSignal,
     title="Short Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="S",
     textcolor=color.white
)


// ============================================================================
// SECTION 45: DIAGNOSTIC COUNTERS
// ============================================================================

var int longTriggerCount = 0
var int shortTriggerCount = 0

var int longEntryCount = 0
var int shortEntryCount = 0


if longTrigger

    longTriggerCount += 1


if shortTrigger

    shortTriggerCount += 1


if finalLongSignal

    longEntryCount += 1


if finalShortSignal

    shortEntryCount += 1


// ============================================================================
// SECTION 46: DIAGNOSTICS
// ============================================================================

var table diagnostics = table.new(
     position.top_right,
     2,
     16,
     border_width=1
)

if (
     showDiagnostics and
     barstate.islast
)

    string positionText = "FLAT"

    if positionLong
        positionText := "LONG"

    if positionShort
        positionText := "SHORT"


    table.cell(
         diagnostics,
         0,
         0,
         "CNPS20"
    )

    table.cell(
         diagnostics,
         1,
         0,
         timeframe.period
    )


    table.cell(
         diagnostics,
         0,
         1,
         "CHOP"
    )

    table.cell(
         diagnostics,
         1,
         1,
         str.tostring(
             chopValue,
             "0.00"
         )
    )


    table.cell(
         diagnostics,
         0,
         2,
         "CHOP OK"
    )

    table.cell(
         diagnostics,
         1,
         2,
         choppinessOK
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         3,
         "ADX"
    )

    table.cell(
         diagnostics,
         1,
         3,
         str.tostring(
             adxValue,
             "0.00"
         )
    )


    table.cell(
         diagnostics,
         0,
         4,
         "ADX OK"
    )

    table.cell(
         diagnostics,
         1,
         4,
         adxOK
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         5,
         "TRIX"
    )

    table.cell(
         diagnostics,
         1,
         5,
         str.tostring(
             trixValue,
             "0.0000"
         )
    )


    table.cell(
         diagnostics,
         0,
         6,
         "TRIX Slope"
    )

    table.cell(
         diagnostics,
         1,
         6,
         str.tostring(
             trixSlope,
             "0.0000"
         )
    )


    table.cell(
         diagnostics,
         0,
         7,
         "Long Trend"
    )

    table.cell(
         diagnostics,
         1,
         7,
         trendLongOK
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         8,
         "Short Trend"
    )

    table.cell(
         diagnostics,
         1,
         8,
         trendShortOK
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         9,
         "Long Triggers"
    )

    table.cell(
         diagnostics,
         1,
         9,
         str.tostring(
             longTriggerCount
         )
    )


    table.cell(
         diagnostics,
         0,
         10,
         "Short Triggers"
    )

    table.cell(
         diagnostics,
         1,
         10,
         str.tostring(
             shortTriggerCount
         )
    )


    table.cell(
         diagnostics,
         0,
         11,
         "Long Entries"
    )

    table.cell(
         diagnostics,
         1,
         11,
         str.tostring(
             longEntryCount
         )
    )


    table.cell(
         diagnostics,
         0,
         12,
         "Short Entries"
    )

    table.cell(
         diagnostics,
         1,
         12,
         str.tostring(
             shortEntryCount
         )
    )


    table.cell(
         diagnostics,
         0,
         13,
         "Trades Today"
    )

    table.cell(
         diagnostics,
         1,
         13,
         str.tostring(
             tradesToday
         )
    )


    table.cell(
         diagnostics,
         0,
         14,
         "Exit Mode"
    )

    table.cell(
         diagnostics,
         1,
         14,
         exitMode
    )


    table.cell(
         diagnostics,
         0,
         15,
         "Position"
    )

    table.cell(
         diagnostics,
         1,
         15,
         positionText
    )
````
