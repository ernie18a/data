# CNPS19-TREND_PULLBACK

- url: https://www.tradingview.com/script/71O8xp7n-CNPS19-TREND-PULLBACK/
- type: strategy
- pine_id: PUB;52a89c1174cb4890a6f6b211620f5eb0
- version: 1.0

## Description

CNPS19 MOMENTUM SEQUENCE

CNPS19 is a price-action momentum strategy designed to identify structured directional sequences rather than isolated bullish or bearish candles.

The strategy focuses on how several consecutive candles develop relative to an initial reference candle.

━━━━━━━━━━━━━━━━━━
1. STRATEGY CONCEPT
━━━━━━━━━━━━━━━━━━

The setup begins with a main reference candle.

A valid momentum sequence then requires several following candles to develop progressively in the opposite direction.

LONG CONCEPT

Initial reference candle is bearish
→ Following candles are bullish
→ Their lows remain above the reference low
→ Each newer close improves relative to the previous close
→ Bullish momentum sequence is confirmed
→ LONG setup

SHORT CONCEPT

Initial reference candle is bullish
→ Following candles are bearish
→ Their highs remain below the reference high
→ Each newer close moves lower relative to the previous close
→ Bearish momentum sequence is confirmed
→ SHORT setup

━━━━━━━━━━━━━━━━━━
2. MULTI-CANDLE CONFIRMATION
━━━━━━━━━━━━━━━━━━

CNPS19 does not treat a single candle reversal as sufficient confirmation.

The strategy evaluates a sequence of candles.

The purpose is to distinguish:

• Structured directional expansion

from:

• Random one-bar reversals
• Isolated candle noise
• Short-lived countertrend reactions

The number of following candles can be adjusted from the strategy settings.

━━━━━━━━━━━━━━━━━━
3. STRUCTURAL QUALITY
━━━━━━━━━━━━━━━━━━

For a Long sequence, the strategy evaluates whether:

• The main candle is bearish
• Following candles are bullish
• Following lows remain above the main candle low
• Newer closes progressively increase

For a Short sequence, the same logic is mirrored.

This creates a simple market-structure confirmation around the original candle.

━━━━━━━━━━━━━━━━━━
4. ENTRY FILTERS
━━━━━━━━━━━━━━━━━━

Depending on the selected configuration, the strategy can also evaluate:

• Reference-candle midpoint
• Trend alignment
• Pullback quality
• Structural risk
• Directional continuation

These filters are intended to improve entry quality without converting the strategy into a generic trend-following system.

━━━━━━━━━━━━━━━━━━
5. RISK MANAGEMENT
━━━━━━━━━━━━━━━━━━

CNPS19 supports structure-based risk management.

The protective stop can be derived from the price structure surrounding the setup.

Risk can also be constrained so that unusually large structural stops are rejected.

The strategy may use an R-multiple target based on the accepted stop distance.

Position Size:

3 contracts

Pyramiding:

Disabled

━━━━━━━━━━━━━━━━━━
6. IMPORTANT CHARACTERISTIC
━━━━━━━━━━━━━━━━━━

CNPS19 is intentionally more selective than a simple candle-color reversal strategy.

Reducing the sequence requirements too aggressively changes the behavior of the system.

A generic:

Red candle
→ Green candle
→ Long

is not equivalent to the original momentum-sequence concept.

The edge, if present, is expected to come from the structure of the sequence rather than from candle color alone.

━━━━━━━━━━━━━━━━━━
7. TIMEFRAME
━━━━━━━━━━━━━━━━━━

The strategy operates on the current chart timeframe.

It can therefore be tested across multiple intraday timeframes.

Lower timeframes will naturally generate more sequences but may also produce more noise and higher transaction-cost sensitivity.

━━━━━━━━━━━━━━━━━━
8. SESSION MANAGEMENT
━━━━━━━━━━━━━━━━━━

CNPS19 uses the standard CNPS intraday session framework.

Default timezone:

Asia/Ho_Chi_Minh

Entries are restricted to the configured trading window.

Positions are closed according to the strategy's end-of-session rules.

━━━━━━━━━━━━━━━━━━
9. BACKTEST ASSUMPTIONS
━━━━━━━━━━━━━━━━━━

Default CNPS framework:

Initial Capital: 100,000,000
Position Size: 3 contracts
Commission: 10,000 VND per contract
Slippage: 3 ticks
Pyramiding: 0

Transaction costs are included in the Strategy Tester configuration.

━━━━━━━━━━━━━━━━━━
10. HOW TO EVALUATE THE STRATEGY
━━━━━━━━━━━━━━━━━━

CNPS19 should be evaluated primarily on setup quality versus trade frequency.

Useful metrics include:

• Total Trades
• Profit Factor
• Win Rate
• Maximum Drawdown
• Average Trade
• Average Holding Time
• Long / Short Performance
• Sequence length
• Structural risk distribution

A major consideration is the trade-off between:

More signals

and

Higher-quality sequence confirmation.

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This strategy is intended for educational, analytical and backtesting purposes only.

It does not constitute financial advice.

Past performance does not guarantee future results.

Trading futures and leveraged financial instruments involves substantial risk. Users are responsible for their own trading decisions, execution and risk management.

## Source Code

````pine
//@version=6
strategy(
     title="CNPS19 TREND-PULLBACK V6",
     shorttitle="CNPS19 TREND-PB V6",
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
// ║                  CNPS19 TREND-PULLBACK V6                         ║
// ║            TREND -> PULLBACK -> MOMENTUM RETURN                   ║
// ╠══════════════════════════════════════════════════════════════════════╣
// ║ TIMEFRAME       : CURRENT CHART TIMEFRAME                          ║
// ║ POSITION        : 3 CONTRACTS                                      ║
// ║ COMMISSION      : VND 10,000 / CONTRACT                           ║
// ║ SLIPPAGE        : 3 TICKS                                          ║
// ║                                                                    ║
// ║ LONG                                                               ║
// ║ EMA20 > EMA50 + EMA20 rising                                       ║
// ║ -> Bearish pullback candle                                         ║
// ║ -> Bullish recovery within N bars                                  ║
// ║ -> Close above previous High                                       ║
// ║ -> Close above EMA20                                               ║
// ║ -> LONG                                                            ║
// ║                                                                    ║
// ║ SHORT                                                              ║
// ║ EMA20 < EMA50 + EMA20 falling                                      ║
// ║ -> Bullish pullback candle                                         ║
// ║ -> Bearish recovery within N bars                                  ║
// ║ -> Close below previous Low                                        ║
// ║ -> Close below EMA20                                               ║
// ║ -> SHORT                                                           ║
// ║                                                                    ║
// ║ DEFAULT EXIT                                                       ║
// ║ SL = 5 POINTS                                                      ║
// ║ TP = 10 POINTS                                                     ║
// ╚══════════════════════════════════════════════════════════════════════╝


// ============================================================================
// SECTION 1: TREND SETTINGS
// ============================================================================

fastEMALength = input.int(
     20,
     title="Fast EMA Length",
     minval=2,
     group="Trend"
)

slowEMALength = input.int(
     50,
     title="Slow EMA Length",
     minval=5,
     group="Trend"
)

slopeLookback = input.int(
     3,
     title="EMA Slope Lookback",
     minval=1,
     maxval=20,
     group="Trend"
)

useTrendSlope = input.bool(
     true,
     title="Require EMA Slope?",
     group="Trend"
)


// ============================================================================
// SECTION 2: OPTIONAL VWAP FILTER
// ============================================================================

useVWAPFilter = input.bool(
     false,
     title="Use VWAP Filter?",
     group="Trend"
)


// ============================================================================
// SECTION 3: PULLBACK SETUP
// ============================================================================

setupLifetimeBars = input.int(
     4,
     title="Maximum Bars After Pullback",
     minval=1,
     maxval=15,
     group="Setup"
)

requirePreviousBarBreak = input.bool(
     true,
     title="Require Previous High / Low Break?",
     group="Setup"
)

requireEMAReclaim = input.bool(
     true,
     title="Require EMA20 Reclaim?",
     group="Setup"
)


// ============================================================================
// SECTION 4: CONFIRMATION CANDLE
// ============================================================================

minimumBodyPercent = input.float(
     20.0,
     title="Minimum Confirmation Body / Range (%)",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group="Confirmation"
)


// ============================================================================
// SECTION 5: PULLBACK INVALIDATION
// ============================================================================

invalidationBuffer = input.float(
     1.0,
     title="Pullback Invalidation Buffer",
     minval=0.0,
     step=0.5,
     group="Setup"
)


// ============================================================================
// SECTION 6: RISK MANAGEMENT
// ============================================================================

stopLossPoints = input.float(
     5.0,
     title="Stop Loss (Points)",
     minval=0.5,
     step=0.5,
     group="Risk Management"
)

takeProfitPoints = input.float(
     10.0,
     title="Take Profit (Points)",
     minval=0.5,
     step=0.5,
     group="Risk Management"
)


// ============================================================================
// SECTION 7: BREAK EVEN
// ============================================================================

useBreakEven = input.bool(
     false,
     title="Use Break Even?",
     group="Break Even"
)

breakEvenTriggerPoints = input.float(
     6.0,
     title="Break Even Trigger (Points)",
     minval=0.5,
     step=0.5,
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
// SECTION 8: TRADE CONTROL
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

maximumTradesPerDay = input.int(
     4,
     title="Maximum Trades Per Day",
     minval=1,
     maxval=20,
     group="Trade Control"
)

cooldownBars = input.int(
     1,
     title="Cooldown Bars After Entry",
     minval=0,
     maxval=50,
     group="Trade Control"
)


// ============================================================================
// SECTION 9: DAILY LOSS GUARD
// ============================================================================

useDailyLossGuard = input.bool(
     true,
     title="Use Daily Loss Guard?",
     group="Daily Guard"
)

maximumDailyLossPercent = input.float(
     3.0,
     title="Maximum Daily Loss (%)",
     minval=0.5,
     maxval=20.0,
     step=0.5,
     group="Daily Guard"
)


// ============================================================================
// SECTION 10: SESSION
// ============================================================================

strategyTimezone = input.string(
     "Asia/Ho_Chi_Minh",
     title="Strategy Timezone",
     group="Session"
)

morningStartHour = input.int(
     9,
     title="Morning Start Hour",
     minval=0,
     maxval=23,
     group="Session"
)

morningStartMinute = input.int(
     5,
     title="Morning Start Minute",
     minval=0,
     maxval=59,
     group="Session"
)

morningEndHour = input.int(
     11,
     title="Morning End Hour",
     minval=0,
     maxval=23,
     group="Session"
)

morningEndMinute = input.int(
     25,
     title="Morning End Minute",
     minval=0,
     maxval=59,
     group="Session"
)

afternoonStartHour = input.int(
     13,
     title="Afternoon Start Hour",
     minval=0,
     maxval=23,
     group="Session"
)

afternoonStartMinute = input.int(
     5,
     title="Afternoon Start Minute",
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

showEMA = input.bool(
     true,
     title="Show EMA20 / EMA50?",
     group="Display"
)

showVWAP = input.bool(
     false,
     title="Show VWAP?",
     group="Display"
)

showSetupLevels = input.bool(
     false,
     title="Show Pullback Levels?",
     group="Display"
)

showSignalMarkers = input.bool(
     false,
     title="Show Entry Markers?",
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

int currentMinute = hour(time, strategyTimezone) * 60 + minute(time, strategyTimezone)

int currentCloseMinute = hour(time_close, strategyTimezone) * 60 + minute(time_close, strategyTimezone)

int morningStart = morningStartHour * 60 + morningStartMinute

int morningEnd = morningEndHour * 60 + morningEndMinute

int afternoonStart = afternoonStartHour * 60 + afternoonStartMinute

int lastEntryTime = lastEntryHour * 60 + lastEntryMinute

int sessionEnd = sessionEndHour * 60 + sessionEndMinute

bool morningWindow = (
     currentMinute >= morningStart and
     currentMinute <= morningEnd
)

bool afternoonWindow = (
     currentMinute >= afternoonStart and
     currentMinute <= lastEntryTime
)

bool entryWindow = (
     morningWindow or
     afternoonWindow
)


// ============================================================================
// SECTION 14: TRADING DAY
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
var float dayStartEquity = na

if (
     newTradingDay or
     na(dayStartEquity)
)

    tradesToday := 0
    dayStartEquity := strategy.equity


// ============================================================================
// SECTION 15: DAILY LOSS ENGINE
// ============================================================================

float dailyPnLPercent = 0.0

if (
     not na(dayStartEquity) and
     dayStartEquity > 0
)

    dailyPnLPercent := (
         (strategy.equity - dayStartEquity) /
         dayStartEquity *
         100.0
    )

bool dailyHalt = (
     useDailyLossGuard and
     dailyPnLPercent <=
     -maximumDailyLossPercent
)


// ============================================================================
// SECTION 16: INDICATORS
// ============================================================================

float emaFast = ta.ema(
     close,
     fastEMALength
)

float emaSlow = ta.ema(
     close,
     slowEMALength
)

float vwap = ta.vwap(
     hlc3
)


// ============================================================================
// SECTION 17: EMA SLOPE
// ============================================================================

float emaSlope = (
     emaFast -
     emaFast[slopeLookback]
)

bool bullishTrend = (
     emaFast >
     emaSlow and
     (
         not useTrendSlope or
         emaSlope >
         0
     )
)

bool bearishTrend = (
     emaFast <
     emaSlow and
     (
         not useTrendSlope or
         emaSlope <
         0
     )
)


// ============================================================================
// SECTION 18: CURRENT CANDLE METRICS
// ============================================================================

float candleRange = (
     high -
     low
)

float candleBody = math.abs(
     close -
     open
)

float candleBodyPercent = 0.0

if candleRange > 0

    candleBodyPercent := (
         candleBody /
         candleRange *
         100.0
    )

bool bullishCandle = (
     close >
     open
)

bool bearishCandle = (
     close <
     open
)

bool bodyQualityOK = (
     candleBodyPercent >=
     minimumBodyPercent
)


// ============================================================================
// SECTION 19: POSITION STATE
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

bool positionJustOpened = (
     strategy.position_size != 0 and
     strategy.position_size[1] == 0
)

bool positionJustClosed = (
     strategy.position_size == 0 and
     strategy.position_size[1] != 0
)


// ============================================================================
// SECTION 20: SETUP STATE
// ============================================================================

var bool longSetupArmed = false
var bool shortSetupArmed = false

var int longSetupBar = na
var int shortSetupBar = na

var float longPullbackHigh = na
var float longPullbackLow = na

var float shortPullbackHigh = na
var float shortPullbackLow = na


// ============================================================================
// SECTION 21: SETUP EXPIRATION
// ============================================================================

bool longExpired = (
     longSetupArmed and
     not na(longSetupBar) and
     bar_index -
     longSetupBar >
     setupLifetimeBars
)

bool shortExpired = (
     shortSetupArmed and
     not na(shortSetupBar) and
     bar_index -
     shortSetupBar >
     setupLifetimeBars
)


if longExpired

    longSetupArmed := false
    longSetupBar := na


if shortExpired

    shortSetupArmed := false
    shortSetupBar := na


// ============================================================================
// SECTION 22: TREND INVALIDATION
// ============================================================================

if (
     longSetupArmed and
     emaFast <=
     emaSlow
)

    longSetupArmed := false
    longSetupBar := na


if (
     shortSetupArmed and
     emaFast >=
     emaSlow
)

    shortSetupArmed := false
    shortSetupBar := na


// ============================================================================
// SECTION 23: PRICE INVALIDATION
// ============================================================================

if (
     longSetupArmed and
     not na(longPullbackLow) and
     close <
     longPullbackLow -
     invalidationBuffer
)

    longSetupArmed := false
    longSetupBar := na


if (
     shortSetupArmed and
     not na(shortPullbackHigh) and
     close >
     shortPullbackHigh +
     invalidationBuffer
)

    shortSetupArmed := false
    shortSetupBar := na


// ============================================================================
// SECTION 24: LONG CONFIRMATION
// ============================================================================

bool longBreakOK = (
     not requirePreviousBarBreak or
     close >
     high[1]
)

bool longEMAReclaimOK = (
     not requireEMAReclaim or
     close >
     emaFast
)

bool longVWAPOK = (
     not useVWAPFilter or
     close >
     vwap
)

bool rawLongSignal = (
     longSetupArmed and
     not na(longSetupBar) and
     bar_index >
     longSetupBar and
     bar_index -
     longSetupBar <=
     setupLifetimeBars and
     bullishTrend and
     bullishCandle and
     bodyQualityOK and
     longBreakOK and
     longEMAReclaimOK and
     longVWAPOK
)


// ============================================================================
// SECTION 25: SHORT CONFIRMATION
// ============================================================================

bool shortBreakOK = (
     not requirePreviousBarBreak or
     close <
     low[1]
)

bool shortEMAReclaimOK = (
     not requireEMAReclaim or
     close <
     emaFast
)

bool shortVWAPOK = (
     not useVWAPFilter or
     close <
     vwap
)

bool rawShortSignal = (
     shortSetupArmed and
     not na(shortSetupBar) and
     bar_index >
     shortSetupBar and
     bar_index -
     shortSetupBar <=
     setupLifetimeBars and
     bearishTrend and
     bearishCandle and
     bodyQualityOK and
     shortBreakOK and
     shortEMAReclaimOK and
     shortVWAPOK
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
// SECTION 27: CAN TRADE
// ============================================================================

bool canTrade = (
     positionFlat and
     entryWindow and
     not dailyHalt and
     tradesToday <
     maximumTradesPerDay and
     cooldownOK and
     barstate.isconfirmed
)


// ============================================================================
// SECTION 28: FINAL SIGNALS
// ============================================================================

bool longCandidate = (
     canTrade and
     allowLong and
     rawLongSignal
)

bool shortCandidate = (
     canTrade and
     allowShort and
     rawShortSignal
)

bool ambiguousSignal = (
     longCandidate and
     shortCandidate
)

bool finalLongSignal = (
     longCandidate and
     not ambiguousSignal
)

bool finalShortSignal = (
     shortCandidate and
     not ambiguousSignal
)


// ============================================================================
// SECTION 29: LONG ENTRY
// ============================================================================

if finalLongSignal

    strategy.entry(
         "Long",
         strategy.long,
         qty=3,
         comment="Trend Pullback Long",
         alert_message="ENTRY_LONG_CNPS19_V6"
    )

    tradesToday += 1
    lastEntryBar := bar_index

    longSetupArmed := false
    shortSetupArmed := false


// ============================================================================
// SECTION 30: SHORT ENTRY
// ============================================================================

if finalShortSignal

    strategy.entry(
         "Short",
         strategy.short,
         qty=3,
         comment="Trend Pullback Short",
         alert_message="ENTRY_SHORT_CNPS19_V6"
    )

    tradesToday += 1
    lastEntryBar := bar_index

    longSetupArmed := false
    shortSetupArmed := false


// ============================================================================
// SECTION 31: ARM LONG PULLBACK
// ============================================================================
//
// Bear candle inside bullish trend.
//
// We evaluate entry BEFORE arming a new setup.
// The pullback candle can never confirm itself.
//
// ============================================================================

if (
     positionFlat and
     entryWindow and
     not dailyHalt and
     not finalLongSignal and
     not finalShortSignal and
     bullishTrend and
     bearishCandle
)

    longSetupArmed := true

    longSetupBar := bar_index

    longPullbackHigh := high
    longPullbackLow := low


// ============================================================================
// SECTION 32: ARM SHORT PULLBACK
// ============================================================================

if (
     positionFlat and
     entryWindow and
     not dailyHalt and
     not finalLongSignal and
     not finalShortSignal and
     bearishTrend and
     bullishCandle
)

    shortSetupArmed := true

    shortSetupBar := bar_index

    shortPullbackHigh := high
    shortPullbackLow := low


// ============================================================================
// SECTION 33: ACTIVE RISK STATE
// ============================================================================

var float activeEntryPrice = na

var float activeLongSL = na
var float activeLongTP = na

var float activeShortSL = na
var float activeShortTP = na

var bool breakEvenActivated = false


// ============================================================================
// SECTION 34: INITIALIZE LONG EXIT
// ============================================================================

if (
     positionJustOpened and
     positionLong
)

    activeEntryPrice := strategy.position_avg_price

    activeLongSL := (
         activeEntryPrice -
         stopLossPoints
    )

    activeLongTP := (
         activeEntryPrice +
         takeProfitPoints
    )

    activeShortSL := na
    activeShortTP := na

    breakEvenActivated := false


// ============================================================================
// SECTION 35: INITIALIZE SHORT EXIT
// ============================================================================

if (
     positionJustOpened and
     positionShort
)

    activeEntryPrice := strategy.position_avg_price

    activeShortSL := (
         activeEntryPrice +
         stopLossPoints
    )

    activeShortTP := (
         activeEntryPrice -
         takeProfitPoints
    )

    activeLongSL := na
    activeLongTP := na

    breakEvenActivated := false


// ============================================================================
// SECTION 36: LONG BREAK EVEN
// ============================================================================

if (
     positionLong and
     useBreakEven and
     not breakEvenActivated and
     not na(activeEntryPrice)
)

    float longBETrigger = (
         activeEntryPrice +
         breakEvenTriggerPoints
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

            activeLongSL := newLongSL

        breakEvenActivated := true


// ============================================================================
// SECTION 37: SHORT BREAK EVEN
// ============================================================================

if (
     positionShort and
     useBreakEven and
     not breakEvenActivated and
     not na(activeEntryPrice)
)

    float shortBETrigger = (
         activeEntryPrice -
         breakEvenTriggerPoints
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

            activeShortSL := newShortSL

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
         alert_profit="EXIT_LONG_TP_CNPS19_V6",
         alert_loss="EXIT_LONG_SL_CNPS19_V6",
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
         alert_profit="EXIT_SHORT_TP_CNPS19_V6",
         alert_loss="EXIT_SHORT_SL_CNPS19_V6",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 40: POSITION CLEANUP
// ============================================================================

if positionJustClosed

    activeEntryPrice := na

    activeLongSL := na
    activeLongTP := na

    activeShortSL := na
    activeShortTP := na

    breakEvenActivated := false


// ============================================================================
// SECTION 41: DAILY HALT
// ============================================================================

if dailyHalt

    longSetupArmed := false
    shortSetupArmed := false


// ============================================================================
// SECTION 42: SESSION END
// ============================================================================

bool finalSessionBar = (
     currentMinute <
     sessionEnd and
     currentCloseMinute >=
     sessionEnd
)

if finalSessionBar

    longSetupArmed := false
    shortSetupArmed := false

    if strategy.position_size != 0

        strategy.close_all(
             immediately=true,
             comment="Session End",
             alert_message="SESSION_END_CNPS19_V6"
        )


// ============================================================================
// SECTION 43: EMA DISPLAY
// ============================================================================

plot(
     showEMA
     ? emaFast
     : na,
     title="EMA20",
     color=color.blue,
     linewidth=1
)

plot(
     showEMA
     ? emaSlow
     : na,
     title="EMA50",
     color=color.orange,
     linewidth=1
)


// ============================================================================
// SECTION 44: VWAP DISPLAY
// ============================================================================

plot(
     showVWAP
     ? vwap
     : na,
     title="VWAP",
     color=color.gray,
     linewidth=1
)


// ============================================================================
// SECTION 45: SETUP LEVELS
// ============================================================================

plot(
     showSetupLevels and
     longSetupArmed
     ? longPullbackLow
     : na,
     title="Long Pullback Low",
     color=color.new(
         color.green,
         50
     ),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showSetupLevels and
     shortSetupArmed
     ? shortPullbackHigh
     : na,
     title="Short Pullback High",
     color=color.new(
         color.red,
         50
     ),
     linewidth=1,
     style=plot.style_linebr
)


// ============================================================================
// SECTION 46: SL / TP DISPLAY
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
// SECTION 47: ENTRY MARKERS
// ============================================================================

plotshape(
     showSignalMarkers and
     finalLongSignal,
     title="Long Entry",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small,
     text="L",
     textcolor=color.white
)

plotshape(
     showSignalMarkers and
     finalShortSignal,
     title="Short Entry",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     text="S",
     textcolor=color.white
)


// ============================================================================
// SECTION 48: DIAGNOSTICS
// ============================================================================

var table diagnostics = table.new(
     position.top_right,
     2,
     14,
     border_width=1
)

if (
     showDiagnostics and
     barstate.islast
)

    string trendText = "NEUTRAL"

    if bullishTrend
        trendText := "BULL"

    if bearishTrend
        trendText := "BEAR"


    string positionText = "FLAT"

    if positionLong
        positionText := "LONG"

    if positionShort
        positionText := "SHORT"


    table.cell(
         diagnostics,
         0,
         0,
         "CNPS19 V6"
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
         "Trend"
    )

    table.cell(
         diagnostics,
         1,
         1,
         trendText
    )


    table.cell(
         diagnostics,
         0,
         2,
         "Long Armed"
    )

    table.cell(
         diagnostics,
         1,
         2,
         longSetupArmed
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         3,
         "Short Armed"
    )

    table.cell(
         diagnostics,
         1,
         3,
         shortSetupArmed
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         4,
         "Raw Long"
    )

    table.cell(
         diagnostics,
         1,
         4,
         rawLongSignal
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         5,
         "Raw Short"
    )

    table.cell(
         diagnostics,
         1,
         5,
         rawShortSignal
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         6,
         "Entry Window"
    )

    table.cell(
         diagnostics,
         1,
         6,
         entryWindow
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         7,
         "EMA20"
    )

    table.cell(
         diagnostics,
         1,
         7,
         str.tostring(
             emaFast,
             format.mintick
         )
    )


    table.cell(
         diagnostics,
         0,
         8,
         "EMA50"
    )

    table.cell(
         diagnostics,
         1,
         8,
         str.tostring(
             emaSlow,
             format.mintick
         )
    )


    table.cell(
         diagnostics,
         0,
         9,
         "Daily PnL"
    )

    table.cell(
         diagnostics,
         1,
         9,
         str.tostring(
             dailyPnLPercent,
             "0.00"
         ) +
         "%"
    )


    table.cell(
         diagnostics,
         0,
         10,
         "Daily Halt"
    )

    table.cell(
         diagnostics,
         1,
         10,
         dailyHalt
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         11,
         "Trades"
    )

    table.cell(
         diagnostics,
         1,
         11,
         str.tostring(
             tradesToday
         ) +
         " / " +
         str.tostring(
             maximumTradesPerDay
         )
    )


    table.cell(
         diagnostics,
         0,
         12,
         "SL / TP"
    )

    table.cell(
         diagnostics,
         1,
         12,
         str.tostring(
             stopLossPoints
         ) +
         " / " +
         str.tostring(
             takeProfitPoints
         )
    )


    table.cell(
         diagnostics,
         0,
         13,
         "Position"
    )

    table.cell(
         diagnostics,
         1,
         13,
         positionText
    )
````
