# CNPS18-VWAP_RETEST

- url: https://www.tradingview.com/script/1WwC9ePg-CNPS18-VWAP-RETEST/
- type: strategy
- pine_id: PUB;3d5ad180127e49dab1c263826fa2b5fe
- version: 1.0

## Description

CNPS18 VWAP BREAKOUT RETEST

CNPS18 is an intraday VWAP strategy designed to avoid entering directly on the initial breakout.

Instead, the strategy waits for price to break VWAP, return to the VWAP area, and confirm continuation before opening a position.

The core idea is:

Breakout
→ Retest
→ Confirmation
→ Entry

━━━━━━━━━━━━━━━━━━
1. STRATEGY CONCEPT
━━━━━━━━━━━━━━━━━━

VWAP is used as the main intraday equilibrium reference.

A directional setup begins when price crosses through VWAP.

LONG SEQUENCE

Price crosses above VWAP
→ Bullish breakout is registered
→ Price returns toward VWAP
→ VWAP is successfully retested
→ Price closes back above VWAP
→ Bullish confirmation candle
→ LONG

SHORT SEQUENCE

Price crosses below VWAP
→ Bearish breakout is registered
→ Price returns toward VWAP
→ VWAP is successfully retested
→ Price closes back below VWAP
→ Bearish confirmation candle
→ SHORT

The strategy therefore avoids automatically chasing the first breakout candle.

━━━━━━━━━━━━━━━━━━
2. BREAKOUT VALIDITY WINDOW
━━━━━━━━━━━━━━━━━━

A breakout remains valid only for a limited number of bars.

Default logic:

Maximum approximately 10 bars between breakout and retest confirmation.

If the market does not produce a valid retest within the active window, the setup expires.

This prevents very old VWAP breaks from creating delayed entries.

━━━━━━━━━━━━━━━━━━
3. VWAP RETEST
━━━━━━━━━━━━━━━━━━

After a breakout, the strategy monitors whether price returns to the current VWAP area.

For Long setups:

Price must revisit VWAP after breaking above it.

For Short setups:

Price must revisit VWAP after breaking below it.

A valid confirmation then requires price to close back on the correct side of VWAP.

━━━━━━━━━━━━━━━━━━
4. HIGHER-TIMEFRAME BIAS
━━━━━━━━━━━━━━━━━━

CNPS18 includes an optional higher-timeframe VWAP bias.

Default reference:

1-hour timeframe

The higher-timeframe component can be used to determine whether the lower-timeframe setup agrees with the broader intraday direction.

This filter can be enabled or disabled from the settings.

━━━━━━━━━━━━━━━━━━
5. ATR DISTANCE FILTER
━━━━━━━━━━━━━━━━━━

The strategy uses ATR to evaluate whether the breakout has created enough separation from VWAP.

This helps avoid extremely small crosses where price simply oscillates around VWAP without establishing directional intent.

The minimum VWAP distance requirement is configurable.

━━━━━━━━━━━━━━━━━━
6. OPTIONAL CONFIRMATION FILTERS
━━━━━━━━━━━━━━━━━━

Additional confirmation tools may include:

• Candle direction
• Wick behavior
• Volume confirmation
• VWAP distance
• Higher-timeframe bias

Some optional filters are disabled by default to avoid over-filtering the strategy.

━━━━━━━━━━━━━━━━━━
7. RISK MANAGEMENT
━━━━━━━━━━━━━━━━━━

Default CNPS exit configuration:

Stop Loss: 5 points
Take Profit: 15 points

Default theoretical Risk/Reward:

1:3

Position Size:

3 contracts

Pyramiding is disabled.

The strategy also contains source-derived ATR logic that can be used as an alternative research configuration.

━━━━━━━━━━━━━━━━━━
8. TRADE FREQUENCY
━━━━━━━━━━━━━━━━━━

The strategy includes controls for limiting the number of trades taken during one trading day.

This is particularly useful on low timeframes where price may repeatedly move above and below VWAP.

Trade limits should be evaluated together with transaction costs.

━━━━━━━━━━━━━━━━━━
9. TIMEFRAME
━━━━━━━━━━━━━━━━━━

CNPS18 uses the current chart timeframe for its primary entry logic.

The optional higher-timeframe bias uses its own configurable timeframe.

Typical research timeframes include:

• 1-minute
• 3-minute
• 5-minute

Results can vary significantly across timeframes.

━━━━━━━━━━━━━━━━━━
10. BACKTEST ASSUMPTIONS
━━━━━━━━━━━━━━━━━━

Default Strategy Tester configuration:

Initial Capital: 100,000,000
Position Size: 3 contracts
Commission: 10,000 VND per contract
Slippage: 3 ticks
Pyramiding: 0

Trading friction is included in the strategy settings.

━━━━━━━━━━━━━━━━━━
11. HOW TO EVALUATE THE STRATEGY
━━━━━━━━━━━━━━━━━━

CNPS18 should be evaluated as a retest strategy rather than a simple VWAP crossover system.

Important metrics and comparisons include:

• Breakout-only versus breakout-retest behavior
• Long versus Short performance
• Higher-timeframe bias ON versus OFF
• Number of bars allowed for retest
• ATR distance requirement
• Profit Factor
• Average Trade
• Maximum Drawdown
• Transaction-cost sensitivity

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This strategy is provided for educational, analytical and backtesting purposes only.

It does not constitute financial or investment advice.

Past performance does not guarantee future results.

Trading leveraged financial instruments involves substantial risk. Users are responsible for their own trading decisions and risk management.

## Source Code

````pine
//@version=6
strategy(
     title="CNPS18 VWAP-RETEST",
     shorttitle="CNPS18 VWAP-RETEST",
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
// ║                     CNPS18 VWAP-RETEST                             ║
// ║             VWAP BREAK -> RETEST -> CONFIRMATION                  ║
// ╠══════════════════════════════════════════════════════════════════════╣
// ║ TIMEFRAME       : CURRENT CHART TIMEFRAME                          ║
// ║ POSITION        : 3 CONTRACTS                                      ║
// ║ COMMISSION      : VND 10,000 / CONTRACT                           ║
// ║ SLIPPAGE        : 3 TICKS                                          ║
// ║                                                                    ║
// ║ LONG                                                               ║
// ║ Close crosses above VWAP                                           ║
// ║ -> Price retests VWAP                                              ║
// ║ -> Bullish close above VWAP                                        ║
// ║ -> Optional Filters                                                ║
// ║ -> LONG                                                            ║
// ║                                                                    ║
// ║ SHORT                                                              ║
// ║ Close crosses below VWAP                                           ║
// ║ -> Price retests VWAP                                              ║
// ║ -> Bearish close below VWAP                                        ║
// ║ -> Optional Filters                                                ║
// ║ -> SHORT                                                           ║
// ║                                                                    ║
// ║ DEFAULT EXIT                                                       ║
// ║ SL = 5 POINTS                                                      ║
// ║ TP = 15 POINTS                                                     ║
// ╚══════════════════════════════════════════════════════════════════════╝


// ============================================================================
// SECTION 1: VWAP SETTINGS
// ============================================================================

useH1VWAPBias = input.bool(
     true,
     title="Use H1 VWAP Bias?",
     group="VWAP"
)


// ============================================================================
// SECTION 2: BREAKOUT / RETEST
// ============================================================================

breakoutBarsMax = input.int(
     10,
     title="Maximum Bars Since VWAP Breakout",
     minval=1,
     maxval=100,
     group="Breakout / Retest"
)

minimumDistanceATR = input.float(
     0.20,
     title="Minimum Distance From VWAP / ATR",
     minval=0.0,
     step=0.05,
     group="Breakout / Retest"
)

requireDistance = input.bool(
     true,
     title="Require Minimum VWAP Distance?",
     group="Breakout / Retest"
)


// ============================================================================
// SECTION 3: REJECTION FILTER
// ============================================================================

requireRejection = input.bool(
     false,
     title="Require Rejection Wick?",
     group="Rejection"
)

minimumWickBodyRatio = input.float(
     1.30,
     title="Minimum Wick / Body Ratio",
     minval=0.0,
     step=0.1,
     group="Rejection"
)


// ============================================================================
// SECTION 4: VOLUME FILTER
// ============================================================================

requireVolumeSpike = input.bool(
     false,
     title="Require Volume Spike?",
     group="Volume"
)

volumeAverageLength = input.int(
     20,
     title="Volume Average Length",
     minval=2,
     group="Volume"
)

volumeSpikeFactor = input.float(
     1.20,
     title="Volume Spike Factor",
     minval=0.1,
     step=0.1,
     group="Volume"
)


// ============================================================================
// SECTION 5: ATR
// ============================================================================

atrLength = input.int(
     14,
     title="ATR Length",
     minval=1,
     group="ATR"
)


// ============================================================================
// SECTION 6: RISK MANAGEMENT
// ============================================================================

stopLossPoints = input.float(
     5.0,
     title="Stop Loss (Points)",
     minval=0.1,
     step=0.5,
     group="Risk Management"
)

takeProfitPoints = input.float(
     15.0,
     title="Take Profit (Points)",
     minval=0.1,
     step=0.5,
     group="Risk Management"
)


// ============================================================================
// SECTION 7: TRADE CONTROL
// ============================================================================

maximumTradesPerDay = input.int(
     2,
     title="Maximum Trades Per Day",
     minval=1,
     maxval=20,
     group="Trade Control"
)

tradeDirection = input.string(
     "Long",
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


// ============================================================================
// SECTION 8: SESSION
// ============================================================================
//
// Session Filter is optional.
//
// Default OFF keeps the original strategy behavior.
//
// Force Close remains at 14:45.
//
// ============================================================================

useSessionFilter = input.bool(
     false,
     title="Use Entry Session Filter?",
     group="Session"
)

strategyTimezone = input.string(
     "Asia/Ho_Chi_Minh",
     title="Strategy Timezone",
     group="Session"
)

sessionStartHour = input.int(
     9,
     title="Session Start Hour",
     minval=0,
     maxval=23,
     group="Session"
)

sessionStartMinute = input.int(
     0,
     title="Session Start Minute",
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
// SECTION 9: ALERT CONTROL
// ============================================================================

disableSLTPAlerts = input.bool(
     false,
     title="Disable SL / TP Alerts?",
     group="Alerts"
)


// ============================================================================
// SECTION 10: DISPLAY
// ============================================================================

showVWAP = input.bool(
     true,
     title="Show VWAP?",
     group="Display"
)

showH1VWAP = input.bool(
     true,
     title="Show H1 VWAP?",
     group="Display"
)

showSignalMarkers = input.bool(
     false,
     title="Show Setup Markers?",
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
// SECTION 11: TIME ENGINE
// ============================================================================
//
// NO timeframe lock.
//
// Signal calculations use the CURRENT CHART TIMEFRAME.
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

bool sessionOK = (
     not useSessionFilter or
     entrySession
)


// ============================================================================
// SECTION 12: TRADING DAY
// ============================================================================

int tradingDayKey = (
     year(time, strategyTimezone) * 10000 +
     month(time, strategyTimezone) * 100 +
     dayofmonth(time, strategyTimezone)
)

bool newTradingDay = (
     bar_index == 0 or
     tradingDayKey != tradingDayKey[1]
)

var int tradesToday = 0

if newTradingDay

    tradesToday := 0


// ============================================================================
// SECTION 13: VWAP
// ============================================================================
//
// Chart VWAP follows the CURRENT CHART TIMEFRAME.
//
// H1 VWAP is calculated independently in the 60-minute context.
//
// ============================================================================

float vwap = ta.vwap(
     hlc3
)

float vwapH1 = request.security(
     syminfo.tickerid,
     "60",
     ta.vwap(hlc3),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)


// ============================================================================
// SECTION 14: H1 VWAP BIAS
// ============================================================================
//
// LONG:
// Current price must be above H1 VWAP.
//
// SHORT:
// Current price must be below H1 VWAP.
//
// Can be disabled.
//
// ============================================================================

bool longBiasOK = (
     not useH1VWAPBias or
     (
         not na(vwapH1) and
         close > vwapH1
     )
)

bool shortBiasOK = (
     not useH1VWAPBias or
     (
         not na(vwapH1) and
         close < vwapH1
     )
)


// ============================================================================
// SECTION 15: ATR
// ============================================================================

float atr = ta.atr(
     atrLength
)


// ============================================================================
// SECTION 16: VOLUME SPIKE
// ============================================================================

float averageVolume = ta.sma(
     volume,
     volumeAverageLength
)

bool volumeSpike = (
     not na(averageVolume) and
     volume >=
     averageVolume *
     volumeSpikeFactor
)


// ============================================================================
// SECTION 17: CANDLE / WICK METRICS
// ============================================================================

float candleBody = (
     math.abs(
         close -
         open
     )
)

float lowerWick = (
     math.min(
         open,
         close
     ) -
     low
)

float upperWick = (
     high -
     math.max(
         open,
         close
     )
)

bool bullishRejection = (
     lowerWick >
     candleBody *
     minimumWickBodyRatio
)

bool bearishRejection = (
     upperWick >
     candleBody *
     minimumWickBodyRatio
)


// ============================================================================
// SECTION 18: VWAP BREAKOUT
// ============================================================================
//
// Bull breakout:
// Close crosses from below VWAP to above VWAP.
//
// Bear breakout:
// Close crosses from above VWAP to below VWAP.
//
// ============================================================================

bool bullishVWAPBreak = ta.crossover(
     close,
     vwap
)

bool bearishVWAPBreak = ta.crossunder(
     close,
     vwap
)

int barsSinceBullBreak = ta.barssince(
     bullishVWAPBreak
)

int barsSinceBearBreak = ta.barssince(
     bearishVWAPBreak
)

bool validBullBreak = (
     not na(barsSinceBullBreak) and
     barsSinceBullBreak <=
     breakoutBarsMax
)

bool validBearBreak = (
     not na(barsSinceBearBreak) and
     barsSinceBearBreak <=
     breakoutBarsMax
)


// ============================================================================
// SECTION 19: RETEST SINCE BULL BREAKOUT
// ============================================================================
//
// Preserve source logic:
//
// After bullish VWAP breakout,
// at least one candle since breakout must touch VWAP.
//
// ============================================================================

bool touchedSinceBullBreak = false

if validBullBreak

    for i = 0 to breakoutBarsMax

        if (
             i <= barsSinceBullBreak and
             low[i] <= vwap
        )

            touchedSinceBullBreak := true


// ============================================================================
// SECTION 20: RETEST SINCE BEAR BREAKOUT
// ============================================================================
//
// After bearish VWAP breakout,
// at least one candle since breakout must touch VWAP.
//
// ============================================================================

bool touchedSinceBearBreak = false

if validBearBreak

    for i = 0 to breakoutBarsMax

        if (
             i <= barsSinceBearBreak and
             high[i] >= vwap
        )

            touchedSinceBearBreak := true


// ============================================================================
// SECTION 21: CLOSE CONFIRMATION
// ============================================================================

bool bullishCloseConfirmation = (
     close > vwap and
     close > open
)

bool bearishCloseConfirmation = (
     close < vwap and
     close < open
)


// ============================================================================
// SECTION 22: BASE LONG SETUP
// ============================================================================
//
// Bullish VWAP breakout
// -> breakout still fresh
// -> VWAP retested
// -> bullish candle closes back above VWAP.
//
// ============================================================================

bool longBase = (
     validBullBreak and
     touchedSinceBullBreak and
     bullishCloseConfirmation
)


// ============================================================================
// SECTION 23: BASE SHORT SETUP
// ============================================================================

bool shortBase = (
     validBearBreak and
     touchedSinceBearBreak and
     bearishCloseConfirmation
)


// ============================================================================
// SECTION 24: REJECTION FILTER
// ============================================================================

bool longRejectionOK = (
     not requireRejection or
     bullishRejection
)

bool shortRejectionOK = (
     not requireRejection or
     bearishRejection
)


// ============================================================================
// SECTION 25: VOLUME FILTER
// ============================================================================

bool longVolumeOK = (
     not requireVolumeSpike or
     volumeSpike
)

bool shortVolumeOK = (
     not requireVolumeSpike or
     volumeSpike
)


// ============================================================================
// SECTION 26: VWAP DISTANCE FILTER
// ============================================================================
//
// Entry must be at least N × ATR away from VWAP.
//
// Default:
// 0.20 ATR
//
// ============================================================================

bool distanceOK = (
     not requireDistance or
     (
         not na(atr) and
         math.abs(
             close -
             vwap
         ) >
         minimumDistanceATR *
         atr
     )
)


// ============================================================================
// SECTION 27: RAW LONG SIGNAL
// ============================================================================

bool rawLongSignal = (
     longBase and
     longRejectionOK and
     longVolumeOK and
     distanceOK and
     longBiasOK
)


// ============================================================================
// SECTION 28: RAW SHORT SIGNAL
// ============================================================================

bool rawShortSignal = (
     shortBase and
     shortRejectionOK and
     shortVolumeOK and
     distanceOK and
     shortBiasOK
)


// ============================================================================
// SECTION 29: POSITION STATE
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

bool positionJustClosed = (
     strategy.position_size == 0 and
     strategy.position_size[1] != 0
)


// ============================================================================
// SECTION 30: CAN TRADE
// ============================================================================

bool dailyTradeLimitOK = (
     tradesToday <
     maximumTradesPerDay
)

bool canTrade = (
     positionFlat and
     dailyTradeLimitOK and
     sessionOK and
     currentCloseMinute <
     sessionEndTotal and
     barstate.isconfirmed
)


// ============================================================================
// SECTION 31: AMBIGUOUS SIGNAL PROTECTION
// ============================================================================

bool ambiguousSignal = (
     rawLongSignal and
     rawShortSignal
)

bool finalLongSignal = (
     canTrade and
     allowLong and
     rawLongSignal and
     not ambiguousSignal
)

bool finalShortSignal = (
     canTrade and
     allowShort and
     rawShortSignal and
     not ambiguousSignal
)


// ============================================================================
// SECTION 32: LONG ENTRY
// ============================================================================

if finalLongSignal

    strategy.entry(
         "Long",
         strategy.long,
         qty=3,
         comment="VWAP Long",
         alert_message="ENTRY_LONG_CNPS18_VWAP_RETEST"
    )

    tradesToday += 1


// ============================================================================
// SECTION 33: SHORT ENTRY
// ============================================================================

if finalShortSignal

    strategy.entry(
         "Short",
         strategy.short,
         qty=3,
         comment="VWAP Short",
         alert_message="ENTRY_SHORT_CNPS18_VWAP_RETEST"
    )

    tradesToday += 1


// ============================================================================
// SECTION 34: ACTIVE RISK LEVELS
// ============================================================================

var float activeLongSL = na
var float activeLongTP = na

var float activeShortSL = na
var float activeShortTP = na


// ============================================================================
// SECTION 35: LONG SL / TP
// ============================================================================

if positionLong

    float entryPrice = (
         strategy.position_avg_price
    )

    activeLongSL := (
         entryPrice -
         stopLossPoints
    )

    activeLongTP := (
         entryPrice +
         takeProfitPoints
    )

    strategy.exit(
         "Long Exit",
         from_entry="Long",
         stop=activeLongSL,
         limit=activeLongTP,
         alert_profit="EXIT_LONG_TP_CNPS18",
         alert_loss="EXIT_LONG_SL_CNPS18",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 36: SHORT SL / TP
// ============================================================================

if positionShort

    float entryPrice = (
         strategy.position_avg_price
    )

    activeShortSL := (
         entryPrice +
         stopLossPoints
    )

    activeShortTP := (
         entryPrice -
         takeProfitPoints
    )

    strategy.exit(
         "Short Exit",
         from_entry="Short",
         stop=activeShortSL,
         limit=activeShortTP,
         alert_profit="EXIT_SHORT_TP_CNPS18",
         alert_loss="EXIT_SHORT_SL_CNPS18",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 37: POSITION CLEANUP
// ============================================================================

if positionJustClosed

    activeLongSL := na
    activeLongTP := na

    activeShortSL := na
    activeShortTP := na


// ============================================================================
// SECTION 38: SESSION END
// ============================================================================
//
// Force close at 14:45.
//
// On unusual chart timeframes the actual bar boundary may cross 14:45.
// Strategy follows the selected chart timeframe.
//
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
             alert_message="SESSION_END_CNPS18"
        )


// ============================================================================
// SECTION 39: VWAP DISPLAY
// ============================================================================

plot(
     showVWAP
     ? vwap
     : na,
     title="VWAP",
     color=color.orange,
     linewidth=2
)

plot(
     showH1VWAP and
     useH1VWAPBias
     ? vwapH1
     : na,
     title="H1 VWAP",
     color=color.blue,
     linewidth=1
)


// ============================================================================
// SECTION 40: ACTIVE LONG SL / TP DISPLAY
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


// ============================================================================
// SECTION 41: ACTIVE SHORT SL / TP DISPLAY
// ============================================================================

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
// SECTION 42: OPTIONAL SETUP MARKERS
// ============================================================================
//
// Setup markers only.
//
// TradingView Strategy order markers remain the authoritative fills.
//
// ============================================================================

plotshape(
     showSignalMarkers and
     rawLongSignal,
     title="VWAP Long Setup",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.tiny,
     text="L",
     textcolor=color.white
)

plotshape(
     showSignalMarkers and
     rawShortSignal,
     title="VWAP Short Setup",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     text="S",
     textcolor=color.white
)


// ============================================================================
// SECTION 43: DIAGNOSTIC COUNTERS
// ============================================================================

var int bullBreakCount = 0
var int bearBreakCount = 0

var int bullRetestCount = 0
var int bearRetestCount = 0

var int longBaseCount = 0
var int shortBaseCount = 0

var int longSignalCount = 0
var int shortSignalCount = 0


if bullishVWAPBreak

    bullBreakCount += 1


if bearishVWAPBreak

    bearBreakCount += 1


bool newBullRetest = (
     touchedSinceBullBreak and
     (
         not touchedSinceBullBreak[1] or
         bullishVWAPBreak
     )
)

bool newBearRetest = (
     touchedSinceBearBreak and
     (
         not touchedSinceBearBreak[1] or
         bearishVWAPBreak
     )
)


if newBullRetest

    bullRetestCount += 1


if newBearRetest

    bearRetestCount += 1


if longBase and not longBase[1]

    longBaseCount += 1


if shortBase and not shortBase[1]

    shortBaseCount += 1


if finalLongSignal

    longSignalCount += 1


if finalShortSignal

    shortSignalCount += 1


// ============================================================================
// SECTION 44: DIAGNOSTICS
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
         "CNPS18"
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
         "VWAP"
    )

    table.cell(
         diagnostics,
         1,
         1,
         str.tostring(
             vwap,
             format.mintick
         )
    )


    table.cell(
         diagnostics,
         0,
         2,
         "H1 VWAP"
    )

    table.cell(
         diagnostics,
         1,
         2,
         str.tostring(
             vwapH1,
             format.mintick
         )
    )


    table.cell(
         diagnostics,
         0,
         3,
         "Bull Breaks"
    )

    table.cell(
         diagnostics,
         1,
         3,
         str.tostring(
             bullBreakCount
         )
    )


    table.cell(
         diagnostics,
         0,
         4,
         "Bear Breaks"
    )

    table.cell(
         diagnostics,
         1,
         4,
         str.tostring(
             bearBreakCount
         )
    )


    table.cell(
         diagnostics,
         0,
         5,
         "Bull Retests"
    )

    table.cell(
         diagnostics,
         1,
         5,
         str.tostring(
             bullRetestCount
         )
    )


    table.cell(
         diagnostics,
         0,
         6,
         "Bear Retests"
    )

    table.cell(
         diagnostics,
         1,
         6,
         str.tostring(
             bearRetestCount
         )
    )


    table.cell(
         diagnostics,
         0,
         7,
         "Long Base"
    )

    table.cell(
         diagnostics,
         1,
         7,
         str.tostring(
             longBaseCount
         )
    )


    table.cell(
         diagnostics,
         0,
         8,
         "Short Base"
    )

    table.cell(
         diagnostics,
         1,
         8,
         str.tostring(
             shortBaseCount
         )
    )


    table.cell(
         diagnostics,
         0,
         9,
         "Distance OK"
    )

    table.cell(
         diagnostics,
         1,
         9,
         distanceOK
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         10,
         "Long H1 Bias"
    )

    table.cell(
         diagnostics,
         1,
         10,
         longBiasOK
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         11,
         "Short H1 Bias"
    )

    table.cell(
         diagnostics,
         1,
         11,
         shortBiasOK
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         12,
         "Long Entries"
    )

    table.cell(
         diagnostics,
         1,
         12,
         str.tostring(
             longSignalCount
         )
    )


    table.cell(
         diagnostics,
         0,
         13,
         "Short Entries"
    )

    table.cell(
         diagnostics,
         1,
         13,
         str.tostring(
             shortSignalCount
         )
    )


    table.cell(
         diagnostics,
         0,
         14,
         "Trades Today"
    )

    table.cell(
         diagnostics,
         1,
         14,
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
