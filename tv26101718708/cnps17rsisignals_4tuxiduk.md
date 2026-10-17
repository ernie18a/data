# CNPS17-RSI_SIGNALS

- url: https://www.tradingview.com/script/4TuXiDuK-CNPS17-RSI-SIGNALS/
- type: strategy
- pine_id: PUB;55b39867dca04b7986e17ab2f01105e3
- version: 1.0

## Description

CNPS17 RSI SIGNALS

CNPS17 is an intraday mean-reversion and momentum-confirmation strategy built around RSI extreme zones and strong price-action candles.

The strategy distinguishes between two classes of setups:

• Extreme RSI signals
• RSI zone + strong candle signals

The objective is to identify moments when momentum reaches an extreme or when price begins reacting strongly from an important RSI zone.

━━━━━━━━━━━━━━━━━━
1. STRATEGY CONCEPT
━━━━━━━━━━━━━━━━━━

The strategy uses RSI with four important levels:

Overbought: 80
Resistance: 68
Support: 35
Oversold: 20

These levels create two different signal groups.

EXTREME SIGNALS

SELL 80:

RSI crosses upward into the 80 overbought zone
→ Short setup

BUY 80:

RSI crosses downward into the 20 oversold zone
→ Long setup

ZONE CONFIRMATION SIGNALS

SELL 70:

RSI has recently traded at or above the 68 resistance zone
+
A strong bearish candle appears
→ Short setup

BUY 70:

RSI has recently traded at or below the 35 support zone
+
A strong bullish candle appears
→ Long setup

━━━━━━━━━━━━━━━━━━
2. STRONG CANDLE FILTER
━━━━━━━━━━━━━━━━━━

The secondary RSI setups require candle confirmation.

A candle is considered strong when:

• Candle body is at least 1.2x the average candle body
• Candle body represents at least 60% of the total candle range

This prevents ordinary low-momentum candles from confirming RSI zone signals.

━━━━━━━━━━━━━━━━━━
3. SIGNAL COOLDOWN
━━━━━━━━━━━━━━━━━━

CNPS17 includes a same-direction cooldown.

Default:

3 bars

After a Long signal, another Long signal cannot immediately trigger within the cooldown window.

The same applies independently to Short signals.

This is designed to reduce repeated entries from the same RSI condition.

━━━━━━━━━━━━━━━━━━
4. ENTRY LOGIC
━━━━━━━━━━━━━━━━━━

LONG setups may come from:

• RSI crossing into the oversold extreme zone
• RSI reacting from the support zone with a strong bullish candle

SHORT setups may come from:

• RSI crossing into the overbought extreme zone
• RSI reacting from the resistance zone with a strong bearish candle

The strategy can trade both directions.

━━━━━━━━━━━━━━━━━━
5. RISK MANAGEMENT
━━━━━━━━━━━━━━━━━━

Default CNPS risk parameters:

Stop Loss: 5 points
Take Profit: 15 points

Default theoretical Risk/Reward:

1:3

Position Size:

3 contracts

Pyramiding is disabled.

Optional filters can be enabled from the strategy settings, but the default configuration keeps the core RSI signal logic active.

━━━━━━━━━━━━━━━━━━
6. TIMEFRAME
━━━━━━━━━━━━━━━━━━

CNPS17 runs on the current chart timeframe.

The original signal concept was designed primarily for short intraday timeframes such as:

• 1-minute
• 5-minute

However, the strategy itself does not hard-code a specific timeframe.

Backtest results should therefore be evaluated separately for each timeframe.

━━━━━━━━━━━━━━━━━━
7. SESSION MANAGEMENT
━━━━━━━━━━━━━━━━━━

The CNPS strategy wrapper is designed for intraday trading.

Default timezone:

Asia/Ho_Chi_Minh

Open positions and new entries are controlled by the configured trading session.

Positions are closed according to the strategy's end-of-session rules.

━━━━━━━━━━━━━━━━━━
8. BACKTEST ASSUMPTIONS
━━━━━━━━━━━━━━━━━━

Default Strategy Tester configuration:

Initial Capital: 100,000,000
Position Size: 3 contracts
Commission: 10,000 VND per contract
Slippage: 3 ticks
Pyramiding: 0

Transaction costs and slippage are included in the strategy assumptions.

━━━━━━━━━━━━━━━━━━
9. OPTIONAL SETTINGS
━━━━━━━━━━━━━━━━━━

The strategy allows users to adjust:

• RSI Length
• Overbought level
• Resistance level
• Support level
• Oversold level
• Strong candle requirements
• Signal cooldown
• Trade direction
• Stop Loss
• Take Profit
• Session settings

Optional filters should be tested carefully because excessive filtering can significantly reduce the number of trades.

━━━━━━━━━━━━━━━━━━
10. HOW TO EVALUATE THE STRATEGY
━━━━━━━━━━━━━━━━━━

CNPS17 is primarily a short-term RSI reaction strategy.

Useful metrics include:

• Profit Factor
• Maximum Drawdown
• Win Rate
• Average Trade
• Total Trades
• Long / Short Performance
• Performance by signal type
• Commission sensitivity
• Slippage sensitivity

It can also be useful to evaluate the four signal groups independently.

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This strategy is provided for educational, research and backtesting purposes only.

It does not constitute financial or investment advice.

Past performance does not guarantee future results.

Trading futures and leveraged financial instruments involves substantial risk. Users are responsible for their own trading decisions and risk management.

## Source Code

````pine
//@version=6
strategy(
     title="CNPS17 RSI-SIGNALS V4",
     shorttitle="CNPS17 RSI-SIGNALS V4",
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
// ║                    CNPS17 RSI-SIGNALS V4                           ║
// ║                  ORIGINAL SIGNAL BASELINE                         ║
// ╠══════════════════════════════════════════════════════════════════════╣
// ║ TIMEFRAME       : CURRENT CHART TIMEFRAME                          ║
// ║ POSITION        : 3 CONTRACTS                                      ║
// ║ COMMISSION      : VND 10,000 / CONTRACT                           ║
// ║ SLIPPAGE        : 3 TICKS                                          ║
// ║                                                                    ║
// ║ SELL 80                                                            ║
// ║ RSI crosses upward into >= 80                                      ║
// ║ -> SHORT                                                           ║
// ║                                                                    ║
// ║ SELL 70                                                            ║
// ║ RSI recently >= 68                                                 ║
// ║ + Strong Bearish Candle                                            ║
// ║ -> SHORT                                                           ║
// ║                                                                    ║
// ║ BUY 80                                                             ║
// ║ RSI crosses downward into <= 20                                    ║
// ║ -> LONG                                                            ║
// ║                                                                    ║
// ║ BUY 70                                                             ║
// ║ RSI recently <= 35                                                 ║
// ║ + Strong Bullish Candle                                            ║
// ║ -> LONG                                                            ║
// ║                                                                    ║
// ║ DEFAULT EXIT                                                       ║
// ║ SL = 5 POINTS                                                      ║
// ║ TP = 15 POINTS                                                     ║
// ╚══════════════════════════════════════════════════════════════════════╝


// ============================================================================
// SECTION 1: RSI SETTINGS
// ============================================================================

rsiLength = input.int(
     14,
     title="RSI Length",
     minval=1,
     group="RSI"
)

rsiSource = input.source(
     close,
     title="RSI Source",
     group="RSI"
)

overboughtLevel = input.float(
     80.0,
     title="Overbought Level",
     minval=50.0,
     maxval=100.0,
     step=0.5,
     group="RSI"
)

resistanceLevel = input.float(
     68.0,
     title="Resistance Level",
     minval=30.0,
     maxval=100.0,
     step=0.5,
     group="RSI"
)

supportLevel = input.float(
     35.0,
     title="Support Level",
     minval=0.0,
     maxval=70.0,
     step=0.5,
     group="RSI"
)

oversoldLevel = input.float(
     20.0,
     title="Oversold Level",
     minval=0.0,
     maxval=50.0,
     step=0.5,
     group="RSI"
)


// ============================================================================
// SECTION 2: STRONG CANDLE SETTINGS
// ============================================================================

zoneLookback = input.int(
     2,
     title="RSI Zone Lookback",
     minval=1,
     maxval=10,
     group="Signal"
)

averageBodyLength = input.int(
     14,
     title="Average Candle Body Length",
     minval=2,
     group="Signal"
)

bodyMultiplier = input.float(
     1.2,
     title="Strong Candle Body / Average Body",
     minval=0.5,
     step=0.1,
     group="Signal"
)

minimumBodyPercent = input.float(
     60.0,
     title="Strong Candle Minimum Body / Range (%)",
     minval=10.0,
     maxval=100.0,
     step=5.0,
     group="Signal"
)

cooldownBars = input.int(
     3,
     title="Minimum Bars Between Same-Direction Signals",
     minval=0,
     maxval=100,
     group="Signal"
)

confirmOnBarClose = input.bool(
     true,
     title="Confirm Signal On Bar Close?",
     group="Signal"
)


// ============================================================================
// SECTION 3: SIGNAL TYPE CONTROL
// ============================================================================

useExtremeSignals = input.bool(
     true,
     title="Use 80% Extreme Signals?",
     group="Signal Types"
)

useZoneSignals = input.bool(
     true,
     title="Use 70% Zone Signals?",
     group="Signal Types"
)


// ============================================================================
// SECTION 4: OPTIONAL TREND FILTER
// ============================================================================
//
// OFF by default.
//
// This version first restores the ORIGINAL signal frequency.
// Turn this on only after confirming the base strategy trades.
//
// ============================================================================

useTrendFilter = input.bool(
     false,
     title="Use EMA Trend Filter?",
     group="Optional Filter"
)

fastEMALength = input.int(
     20,
     title="Fast EMA",
     minval=2,
     group="Optional Filter"
)

slowEMALength = input.int(
     50,
     title="Slow EMA",
     minval=3,
     group="Optional Filter"
)


// ============================================================================
// SECTION 5: RISK MANAGEMENT
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
// SECTION 6: TRADE DIRECTION
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


// ============================================================================
// SECTION 7: OPTIONAL SESSION FILTER
// ============================================================================
//
// OFF by default.
//
// The original indicator's session boxes were VISUAL only.
// They were NOT part of the BUY / SELL logic.
//
// ============================================================================

useSessionFilter = input.bool(
     false,
     title="Use Session Filter?",
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
// SECTION 8: ALERT CONTROL
// ============================================================================

disableSLTPAlerts = input.bool(
     false,
     title="Disable SL / TP Alerts?",
     group="Alerts"
)


// ============================================================================
// SECTION 9: DISPLAY
// ============================================================================

showEMA = input.bool(
     false,
     title="Show EMA20 / EMA50?",
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
// SECTION 10: TIME ENGINE
// ============================================================================
//
// NO timeframe lock.
// Everything follows the CURRENT chart timeframe.
//
// ============================================================================

int currentMinute = (
     hour(time, strategyTimezone) * 60 +
     minute(time, strategyTimezone)
)

int closeMinute = (
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

bool insideEntrySession = (
     currentMinute >= sessionStartTotal and
     currentMinute <= lastEntryTotal
)

bool sessionOK = (
     not useSessionFilter or
     insideEntrySession
)


// ============================================================================
// SECTION 11: RSI CALCULATION
// ============================================================================

float rsi = ta.rsi(
     rsiSource,
     rsiLength
)


// ============================================================================
// SECTION 12: CANDLE STRENGTH
// ============================================================================

float candleBody = (
     math.abs(
         close -
         open
     )
)

float candleRange = (
     high -
     low
)

float averageBody = ta.sma(
     candleBody,
     averageBodyLength
)

float candleBodyPercent = 0.0

if candleRange > 0

    candleBodyPercent := (
         candleBody /
         candleRange *
         100.0
    )


bool strongBearishCandle = (
     close <
     open and
     candleRange >
     0 and
     not na(averageBody) and
     candleBody >=
     averageBody *
     bodyMultiplier and
     candleBodyPercent >=
     minimumBodyPercent
)

bool strongBullishCandle = (
     close >
     open and
     candleRange >
     0 and
     not na(averageBody) and
     candleBody >=
     averageBody *
     bodyMultiplier and
     candleBodyPercent >=
     minimumBodyPercent
)


// ============================================================================
// SECTION 13: RSI ZONES
// ============================================================================

float zoneHigh = ta.highest(
     rsi,
     zoneLookback
)

float zoneLow = ta.lowest(
     rsi,
     zoneLookback
)


// ============================================================================
// SECTION 14: ORIGINAL 80% SIGNALS
// ============================================================================
//
// Exact source logic.
//
// SELL 80:
// RSI >= 80 now
// previous RSI < 80
//
// BUY 80:
// RSI <= 20 now
// previous RSI > 20
//
// ============================================================================

bool sell80 = (
     useExtremeSignals and
     rsi >=
     overboughtLevel and
     rsi[1] <
     overboughtLevel
)

bool buy80 = (
     useExtremeSignals and
     rsi <=
     oversoldLevel and
     rsi[1] >
     oversoldLevel
)


// ============================================================================
// SECTION 15: ORIGINAL 70% SIGNALS
// ============================================================================
//
// Exact source logic.
//
// SELL 70:
// RSI touched >= 68 within lookback
// + strong bearish candle
// + not SELL 80
//
// BUY 70:
// RSI touched <= 35 within lookback
// + strong bullish candle
// + not BUY 80
//
// ============================================================================

bool sell70 = (
     useZoneSignals and
     zoneHigh >=
     resistanceLevel and
     strongBearishCandle and
     not sell80
)

bool buy70 = (
     useZoneSignals and
     zoneLow <=
     supportLevel and
     strongBullishCandle and
     not buy80
)


// ============================================================================
// SECTION 16: RAW BUY / SELL SIGNALS
// ============================================================================

bool rawSellSignal = (
     sell80 or
     sell70
)

bool rawBuySignal = (
     buy80 or
     buy70
)


// ============================================================================
// SECTION 17: SIGNAL CONFIRMATION
// ============================================================================

bool confirmationOK = (
     not confirmOnBarClose or
     barstate.isconfirmed
)


// ============================================================================
// SECTION 18: ORIGINAL SAME-DIRECTION COOLDOWN
// ============================================================================

var int lastSellSignalBar = na
var int lastBuySignalBar = na

bool sellCooldownOK = (
     na(lastSellSignalBar) or
     bar_index -
     lastSellSignalBar >
     cooldownBars
)

bool buyCooldownOK = (
     na(lastBuySignalBar) or
     bar_index -
     lastBuySignalBar >
     cooldownBars
)


// ============================================================================
// SECTION 19: OPTIONAL EMA FILTER
// ============================================================================

float emaFast = ta.ema(
     close,
     fastEMALength
)

float emaSlow = ta.ema(
     close,
     slowEMALength
)

bool longTrendOK = (
     not useTrendFilter or
     emaFast >
     emaSlow
)

bool shortTrendOK = (
     not useTrendFilter or
     emaFast <
     emaSlow
)


// ============================================================================
// SECTION 20: ACCEPTED SIGNALS
// ============================================================================

bool buySignal = (
     rawBuySignal and
     confirmationOK and
     buyCooldownOK and
     sessionOK
)

bool sellSignal = (
     rawSellSignal and
     confirmationOK and
     sellCooldownOK and
     sessionOK
)


// ============================================================================
// SECTION 21: AMBIGUOUS BAR PROTECTION
// ============================================================================

bool ambiguousSignal = (
     buySignal and
     sellSignal
)

bool finalBuySignal = (
     buySignal and
     not ambiguousSignal
)

bool finalSellSignal = (
     sellSignal and
     not ambiguousSignal
)


// ============================================================================
// SECTION 22: RECORD ORIGINAL SIGNAL COOLDOWN
// ============================================================================
//
// Cooldown is recorded when the source signal is accepted,
// even if a position is already open.
//
// This mirrors indicator signal behavior more closely.
//
// ============================================================================

if finalBuySignal

    lastBuySignalBar := (
         bar_index
    )


if finalSellSignal

    lastSellSignalBar := (
         bar_index
    )


// ============================================================================
// SECTION 23: POSITION STATE
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
// SECTION 24: LONG ENTRY
// ============================================================================

bool finalLongEntry = (
     finalBuySignal and
     longTrendOK and
     allowLong and
     positionFlat
)

if finalLongEntry

    strategy.entry(
         "Long",
         strategy.long,
         qty=3,
         comment=(
             buy80
             ? "BUY 80"
             : "BUY 70"
         ),
         alert_message=(
             buy80
             ? "ENTRY_LONG_BUY80_CNPS17_V4"
             : "ENTRY_LONG_BUY70_CNPS17_V4"
         )
    )


// ============================================================================
// SECTION 25: SHORT ENTRY
// ============================================================================

bool finalShortEntry = (
     finalSellSignal and
     shortTrendOK and
     allowShort and
     positionFlat
)

if finalShortEntry

    strategy.entry(
         "Short",
         strategy.short,
         qty=3,
         comment=(
             sell80
             ? "SELL 80"
             : "SELL 70"
         ),
         alert_message=(
             sell80
             ? "ENTRY_SHORT_SELL80_CNPS17_V4"
             : "ENTRY_SHORT_SELL70_CNPS17_V4"
         )
    )


// ============================================================================
// SECTION 26: ACTIVE SL / TP STATE
// ============================================================================

var float activeLongSL = na
var float activeLongTP = na

var float activeShortSL = na
var float activeShortTP = na


// ============================================================================
// SECTION 27: LONG SL / TP
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
         alert_profit="EXIT_LONG_TP_CNPS17_V4",
         alert_loss="EXIT_LONG_SL_CNPS17_V4",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 28: SHORT SL / TP
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
         alert_profit="EXIT_SHORT_TP_CNPS17_V4",
         alert_loss="EXIT_SHORT_SL_CNPS17_V4",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 29: POSITION CLEANUP
// ============================================================================

if positionJustClosed

    activeLongSL := na
    activeLongTP := na

    activeShortSL := na
    activeShortTP := na


// ============================================================================
// SECTION 30: OPTIONAL SESSION END
// ============================================================================
//
// Only active when Session Filter is enabled.
//
// ============================================================================

bool finalSessionBar = (
     useSessionFilter and
     currentMinute <
     sessionEndTotal and
     closeMinute >=
     sessionEndTotal
)

if finalSessionBar

    if strategy.position_size != 0

        strategy.close_all(
             immediately=true,
             comment="Session End",
             alert_message="SESSION_END_CNPS17_V4"
        )


// ============================================================================
// SECTION 31: EMA DISPLAY
// ============================================================================

plot(
     showEMA
     ? emaFast
     : na,
     title="EMA Fast",
     color=color.blue,
     linewidth=1
)

plot(
     showEMA
     ? emaSlow
     : na,
     title="EMA Slow",
     color=color.orange,
     linewidth=1
)


// ============================================================================
// SECTION 32: ACTIVE SL / TP DISPLAY
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
// SECTION 33: OPTIONAL SIGNAL MARKERS
// ============================================================================

plotshape(
     showSignalMarkers and
     finalBuySignal,
     title="BUY Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.tiny,
     text="B",
     textcolor=color.white
)

plotshape(
     showSignalMarkers and
     finalSellSignal,
     title="SELL Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny,
     text="S",
     textcolor=color.white
)


// ============================================================================
// SECTION 34: DIAGNOSTIC COUNTERS
// ============================================================================

var int buy80Count = 0
var int buy70Count = 0
var int sell80Count = 0
var int sell70Count = 0

var int longEntryCount = 0
var int shortEntryCount = 0


if buy80
    buy80Count += 1

if buy70
    buy70Count += 1

if sell80
    sell80Count += 1

if sell70
    sell70Count += 1

if finalLongEntry
    longEntryCount += 1

if finalShortEntry
    shortEntryCount += 1


// ============================================================================
// SECTION 35: DIAGNOSTICS
// ============================================================================

var table diagnostics = table.new(
     position.top_right,
     2,
     12,
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
         "CNPS17 V4"
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
         "RSI"
    )

    table.cell(
         diagnostics,
         1,
         1,
         str.tostring(
             rsi,
             "0.00"
         )
    )


    table.cell(
         diagnostics,
         0,
         2,
         "BUY 80"
    )

    table.cell(
         diagnostics,
         1,
         2,
         str.tostring(
             buy80Count
         )
    )


    table.cell(
         diagnostics,
         0,
         3,
         "BUY 70"
    )

    table.cell(
         diagnostics,
         1,
         3,
         str.tostring(
             buy70Count
         )
    )


    table.cell(
         diagnostics,
         0,
         4,
         "SELL 80"
    )

    table.cell(
         diagnostics,
         1,
         4,
         str.tostring(
             sell80Count
         )
    )


    table.cell(
         diagnostics,
         0,
         5,
         "SELL 70"
    )

    table.cell(
         diagnostics,
         1,
         5,
         str.tostring(
             sell70Count
         )
    )


    table.cell(
         diagnostics,
         0,
         6,
         "Long Entries"
    )

    table.cell(
         diagnostics,
         1,
         6,
         str.tostring(
             longEntryCount
         )
    )


    table.cell(
         diagnostics,
         0,
         7,
         "Short Entries"
    )

    table.cell(
         diagnostics,
         1,
         7,
         str.tostring(
             shortEntryCount
         )
    )


    table.cell(
         diagnostics,
         0,
         8,
         "Session Filter"
    )

    table.cell(
         diagnostics,
         1,
         8,
         useSessionFilter
         ? "ON"
         : "OFF"
    )


    table.cell(
         diagnostics,
         0,
         9,
         "Trend Filter"
    )

    table.cell(
         diagnostics,
         1,
         9,
         useTrendFilter
         ? "ON"
         : "OFF"
    )


    table.cell(
         diagnostics,
         0,
         10,
         "SL / TP"
    )

    table.cell(
         diagnostics,
         1,
         10,
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
         11,
         "Position"
    )

    table.cell(
         diagnostics,
         1,
         11,
         positionText
    )
````
