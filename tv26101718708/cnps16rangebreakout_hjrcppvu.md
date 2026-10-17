# CNPS16-RANGE_BREAKOUT

- url: https://www.tradingview.com/script/HJrCpPvU-CNPS16-RANGE-BREAKOUT/
- type: strategy
- pine_id: PUB;cae7b40815274ab1838dd1ef6fb4c9be
- version: 1.0

## Description

CNPS16 RANGE-BREAKOUT

CNPS16 RANGE-BREAKOUT is an intraday breakout strategy designed to capture directional expansion after the market establishes an initial opening range.

The strategy first defines a fixed price range during the early part of the trading session. Once the range is completed, it places breakout orders above the Range High and below the Range Low and waits for price to initiate a directional move.

━━━━━━━━━━━━━━━━━━
1. STRATEGY CONCEPT
━━━━━━━━━━━━━━━━━━

The strategy builds an opening range during a predefined time window.

Default Range:

09:00 – 09:15
Timezone: Asia/Ho_Chi_Minh

During this period, the strategy records:

• Range High
• Range Low

Once the range window has closed, the range becomes locked and can be used for breakout entries.

LONG SETUP

Range is completed
→ Buy Stop is placed at the Range High
→ Price trades through the Range High
→ LONG position is opened

SHORT SETUP

Range is completed
→ Sell Stop is placed at the Range Low
→ Price trades through the Range Low
→ SHORT position is opened

The Long and Short breakout orders use an OCA structure.

When one side is filled, the pending order on the opposite side is automatically cancelled.

━━━━━━━━━━━━━━━━━━
2. ONE TRADE PER DAY
━━━━━━━━━━━━━━━━━━

CNPS16 allows a maximum of one completed breakout trade per trading day.

Once either the Long or Short setup has been triggered and traded, the strategy will not open another position until the next trading day.

This rule is intended to prevent repeated entries after the initial opening-range breakout has already occurred.

━━━━━━━━━━━━━━━━━━
3. RANGE SETTINGS
━━━━━━━━━━━━━━━━━━

The opening-range window can be fully customized.

Default settings:

Range Start: 09:00
Range End: 09:15

The strategy also includes a Minimum Range Width parameter.

If the completed opening range is smaller than the specified minimum width, the setup is considered invalid and no breakout orders are armed.

This can be used to avoid extremely narrow opening ranges.

━━━━━━━━━━━━━━━━━━
4. RISK MANAGEMENT
━━━━━━━━━━━━━━━━━━

Default risk parameters:

Stop Loss: 5 points
Take Profit: 15 points

Default theoretical Risk/Reward:

1:3

Both values can be modified from the strategy settings.

The default execution size is:

3 contracts per trade

Pyramiding is disabled, so the strategy will not add additional positions while a trade is already active.

━━━━━━━━━━━━━━━━━━
5. TRADE DIRECTION
━━━━━━━━━━━━━━━━━━

The strategy supports three directional modes:

• Long
• Short
• Both

The Both setting allows the strategy to place breakout orders on both sides of the opening range.

Long Only or Short Only can be selected when the trader wants to apply an external directional bias.

━━━━━━━━━━━━━━━━━━
6. SESSION MANAGEMENT
━━━━━━━━━━━━━━━━━━

Default timezone:

Asia/Ho_Chi_Minh

Default trading session:

09:00 – 14:45

The opening range must be completed before breakout orders can become active.

Pending breakout orders are only valid during the configured trading session.

Open positions and remaining orders are managed according to the strategy's end-of-session logic.

━━━━━━━━━━━━━━━━━━
7. TIMEFRAME
━━━━━━━━━━━━━━━━━━

CNPS16 does not use a fixed timeframe.

All calculations are performed using the current chart timeframe.

This means the behavior and backtest results can differ significantly between:

• 1-minute charts
• 3-minute charts
• 5-minute charts
• Higher intraday timeframes

The strategy should therefore be evaluated on the same market and timeframe intended for actual use.

━━━━━━━━━━━━━━━━━━
8. BACKTEST ASSUMPTIONS
━━━━━━━━━━━━━━━━━━

Default Strategy Tester configuration:

Initial Capital: 100,000,000
Position Size: 3 contracts
Commission: 10,000 VND per contract
Slippage: 3 ticks
Pyramiding: 0

Transaction costs and slippage are included in the strategy configuration so that historical results account for a basic level of trading friction.

Actual execution may differ from historical Strategy Tester results.

━━━━━━━━━━━━━━━━━━
9. VISUAL SETTINGS
━━━━━━━━━━━━━━━━━━

Optional chart elements include:

• Range High / Range Low
• Active Stop Loss / Take Profit levels
• Setup markers
• Diagnostic information

These visual components can be enabled or disabled from the strategy settings.

They do not change the underlying entry or exit logic.

━━━━━━━━━━━━━━━━━━
10. HOW TO EVALUATE THE STRATEGY
━━━━━━━━━━━━━━━━━━

CNPS16 is designed around the idea that an initial period of price balance can be followed by directional expansion.

When evaluating the strategy, useful variables to study include:

• Opening-range width
• Breakout timing
• Intraday volatility
• Gap behavior
• Long versus Short performance
• Market regime
• Transaction costs
• Slippage sensitivity

Performance should not be evaluated using Net Profit alone.

Relevant Strategy Tester metrics include:

• Profit Factor
• Maximum Drawdown
• Win Rate
• Average Trade
• Total Number of Trades
• Long / Short Performance
• Average Winning Trade
• Average Losing Trade

━━━━━━━━━━━━━━━━━━
11. IMPORTANT NOTES
━━━━━━━━━━━━━━━━━━

A breakout above or below the opening range does not guarantee continuation.

False breakouts, low-liquidity conditions, volatility changes and execution differences can materially affect strategy performance.

Parameters that perform well over one historical period may not perform the same way under different market conditions.

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This strategy is provided for educational, research and backtesting purposes only.

It does not constitute financial advice, investment advice or a recommendation to buy or sell any financial instrument.

Past performance does not guarantee future results.

Trading futures and other leveraged financial instruments involves substantial risk. Users are responsible for their own trading decisions, position sizing and risk management.

## Source Code

````pine
//@version=6
strategy(
     title="CNPS16 RANGE-BREAKOUT",
     shorttitle="CNPS16 RANGE-BREAKOUT",
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
     max_boxes_count=100,
     max_bars_back=5000
)


// ╔══════════════════════════════════════════════════════════════════════╗
// ║                   CNPS16 RANGE-BREAKOUT                            ║
// ║             RANGE -> BREAKOUT -> FIXED SL / TP                    ║
// ╠══════════════════════════════════════════════════════════════════════╣
// ║ TIMEFRAME       : CURRENT CHART TIMEFRAME                          ║
// ║ POSITION SIZE   : 3 CONTRACTS                                      ║
// ║ COMMISSION      : VND 10,000 / CONTRACT                           ║
// ║ SLIPPAGE        : 3 TICKS                                          ║
// ║                                                                    ║
// ║ RANGE                                                              ║
// ║ Default: 09:00 -> 09:15                                            ║
// ║                                                                    ║
// ║ LONG                                                               ║
// ║ Build Range                                                        ║
// ║ -> Buy Stop at Range High                                          ║
// ║ -> Breakout                                                        ║
// ║ -> LONG                                                            ║
// ║ -> SL 5 Points                                                     ║
// ║ -> TP 15 Points                                                    ║
// ║                                                                    ║
// ║ SHORT                                                              ║
// ║ Build Range                                                        ║
// ║ -> Sell Stop at Range Low                                          ║
// ║ -> Breakout                                                        ║
// ║ -> SHORT                                                           ║
// ║ -> SL 5 Points                                                     ║
// ║ -> TP 15 Points                                                    ║
// ║                                                                    ║
// ║ ENTRY ORDERS USE OCA: FIRST FILL CANCELS THE OTHER SIDE.          ║
// ║ MAXIMUM ONE TRADE PER DAY.                                         ║
// ╚══════════════════════════════════════════════════════════════════════╝


// ============================================================================
// SECTION 1: RANGE SETTINGS
// ============================================================================

strategyTimezone = input.string(
     "Asia/Ho_Chi_Minh",
     title="Strategy Timezone",
     group="Range"
)

rangeStartHour = input.int(
     9,
     title="Range Start Hour",
     minval=0,
     maxval=23,
     group="Range"
)

rangeStartMinute = input.int(
     0,
     title="Range Start Minute",
     minval=0,
     maxval=59,
     group="Range"
)

rangeEndHour = input.int(
     9,
     title="Range End Hour",
     minval=0,
     maxval=23,
     group="Range"
)

rangeEndMinute = input.int(
     15,
     title="Range End Minute",
     minval=0,
     maxval=59,
     group="Range"
)

minimumRangeWidth = input.float(
     0.5,
     title="Minimum Range Width (Points)",
     minval=0.0,
     step=0.5,
     group="Range"
)


// ============================================================================
// SECTION 2: RISK MANAGEMENT
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
// SECTION 3: TRADE DIRECTION
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
// SECTION 4: SESSION
// ============================================================================

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

sessionEndHour = input.int(
     14,
     title="Session End Hour",
     minval=0,
     maxval=23,
     group="Session"
)

sessionEndMinute = input.int(
     45,
     title="Session End Minute",
     minval=0,
     maxval=59,
     group="Session"
)


// ============================================================================
// SECTION 5: ALERT CONTROL
// ============================================================================

disableSLTPAlerts = input.bool(
     false,
     title="Disable SL / TP Alerts?",
     group="Alert Control"
)


// ============================================================================
// SECTION 6: DISPLAY
// ============================================================================

showRange = input.bool(
     true,
     title="Show Range High / Low?",
     group="Display"
)

showActiveSLTP = input.bool(
     true,
     title="Show Active SL / TP?",
     group="Display"
)

showSignalMarkers = input.bool(
     false,
     title="Show Setup Markers?",
     group="Display"
)

showDiagnostics = input.bool(
     false,
     title="Show Diagnostics?",
     group="Display"
)


// ============================================================================
// SECTION 7: TIME ENGINE
// ============================================================================
//
// IMPORTANT:
//
// No timeframe lock.
//
// The strategy uses the CURRENT chart timeframe.
//
// ============================================================================

int currentOpenMinute = (
     hour(time, strategyTimezone) * 60 +
     minute(time, strategyTimezone)
)

int currentCloseMinute = (
     hour(time_close, strategyTimezone) * 60 +
     minute(time_close, strategyTimezone)
)

int rangeStartTotal = (
     rangeStartHour * 60 +
     rangeStartMinute
)

int rangeEndTotal = (
     rangeEndHour * 60 +
     rangeEndMinute
)

int sessionStartTotal = (
     sessionStartHour * 60 +
     sessionStartMinute
)

int sessionEndTotal = (
     sessionEndHour * 60 +
     sessionEndMinute
)

bool validTimeConfiguration = (
     sessionStartTotal <= rangeStartTotal and
     rangeStartTotal < rangeEndTotal and
     rangeEndTotal < sessionEndTotal
)

bool inSession = (
     currentOpenMinute >= sessionStartTotal and
     currentOpenMinute < sessionEndTotal
)

bool insideRangeWindow = (
     validTimeConfiguration and
     currentOpenMinute >= rangeStartTotal and
     currentOpenMinute < rangeEndTotal
)

bool rangeWindowHasClosed = (
     validTimeConfiguration and
     currentCloseMinute >= rangeEndTotal
)

bool beforeSessionEnd = (
     currentCloseMinute < sessionEndTotal
)


// ============================================================================
// SECTION 8: TRADING DAY
// ============================================================================

int tradingDayKey = (
     year(time, strategyTimezone) * 10000 +
     month(time, strategyTimezone) * 100 +
     dayofmonth(time, strategyTimezone)
)

var int activeTradingDayKey = na

bool newTradingDay = (
     inSession and
     (
         na(activeTradingDayKey) or
         tradingDayKey != activeTradingDayKey
     )
)

if newTradingDay

    activeTradingDayKey := (
         tradingDayKey
    )


// ============================================================================
// SECTION 9: DAILY RANGE
// ============================================================================

var float rangeHigh = na
var float rangeLow = na

var bool rangeLocked = false


if newTradingDay

    rangeHigh := na
    rangeLow := na

    rangeLocked := false


if insideRangeWindow

    if na(rangeHigh)

        rangeHigh := (
             high
        )

    else

        rangeHigh := (
             math.max(
                 rangeHigh,
                 high
             )
        )


    if na(rangeLow)

        rangeLow := (
             low
        )

    else

        rangeLow := (
             math.min(
                 rangeLow,
                 low
             )
        )


if (
     not rangeLocked and
     rangeWindowHasClosed and
     not na(rangeHigh) and
     not na(rangeLow)
)

    rangeLocked := true


float rangeWidth = (
     not na(rangeHigh) and
     not na(rangeLow)
     ? rangeHigh -
       rangeLow
     : na
)

bool validRange = (
     rangeLocked and
     not na(rangeWidth) and
     rangeWidth >= minimumRangeWidth
)


// ============================================================================
// SECTION 10: ONE TRADE PER DAY
// ============================================================================

var int tradedDayKey = na

bool tradedToday = (
     not na(tradedDayKey) and
     tradedDayKey == tradingDayKey
)


// ============================================================================
// SECTION 11: POSITION STATE
// ============================================================================

bool inPosition = (
     strategy.position_size != 0
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
// SECTION 12: SAME-BAR TRADE DETECTION
// ============================================================================
//
// Historical stop order can theoretically fill and exit inside the
// same candle.
//
// This ensures that such a trade still consumes the daily setup.
//
// ============================================================================

bool newClosedTrade = (
     strategy.closedtrades >
     nz(
         strategy.closedtrades[1],
         0
     )
)

if newClosedTrade

    tradedDayKey := (
         tradingDayKey
    )


// ============================================================================
// SECTION 13: ENTRY AVAILABILITY
// ============================================================================

bool canArmBreakout = (
     validTimeConfiguration and
     validRange and
     rangeWindowHasClosed and
     beforeSessionEnd and
     inSession and
     not inPosition and
     not tradedToday
)


// ============================================================================
// SECTION 14: LONG ENTRY
// ============================================================================
//
// LONG:
//
// Range completes
// -> Place BUY STOP at Range High
// -> Price trades through Range High
// -> LONG
//
// ============================================================================

bool longSetupArmed = (
     canArmBreakout and
     allowLong
)

if longSetupArmed

    strategy.entry(
         "Long",
         strategy.long,
         qty=3,
         stop=rangeHigh,
         oca_name="CNPS16_BREAKOUT",
         oca_type=strategy.oca.cancel,
         comment="Long Breakout",
         alert_message="ENTRY_LONG_CNPS16_RANGE_BREAKOUT"
    )


// ============================================================================
// SECTION 15: SHORT ENTRY
// ============================================================================
//
// SHORT:
//
// Range completes
// -> Place SELL STOP at Range Low
// -> Price trades through Range Low
// -> SHORT
//
// ============================================================================

bool shortSetupArmed = (
     canArmBreakout and
     allowShort
)

if shortSetupArmed

    strategy.entry(
         "Short",
         strategy.short,
         qty=3,
         stop=rangeLow,
         oca_name="CNPS16_BREAKOUT",
         oca_type=strategy.oca.cancel,
         comment="Short Breakout",
         alert_message="ENTRY_SHORT_CNPS16_RANGE_BREAKOUT"
    )


// ============================================================================
// SECTION 16: REAL ENTRY CONFIRMATION
// ============================================================================

if positionJustOpened

    tradedDayKey := (
         tradingDayKey
    )

    strategy.cancel(
         "Long"
    )

    strategy.cancel(
         "Short"
    )


// ============================================================================
// SECTION 17: LONG STOP LOSS / TAKE PROFIT
// ============================================================================

var float activeLongSL = na
var float activeLongTP = na

var float activeShortSL = na
var float activeShortTP = na


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
         alert_profit="EXIT_LONG_TP_CNPS16",
         alert_loss="EXIT_LONG_SL_CNPS16",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 18: SHORT STOP LOSS / TAKE PROFIT
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
         alert_profit="EXIT_SHORT_TP_CNPS16",
         alert_loss="EXIT_SHORT_SL_CNPS16",
         disable_alert=disableSLTPAlerts
    )


// ============================================================================
// SECTION 19: POSITION CLEANUP
// ============================================================================

if positionJustClosed

    activeLongSL := na
    activeLongTP := na

    activeShortSL := na
    activeShortTP := na


// ============================================================================
// SECTION 20: CANCEL UNUSED BREAKOUT ORDERS
// ============================================================================

if (
     not canArmBreakout and
     not inPosition
)

    strategy.cancel(
         "Long"
    )

    strategy.cancel(
         "Short"
    )


// ============================================================================
// SECTION 21: SESSION END
// ============================================================================

bool finalSessionBar = (
     inSession and
     currentCloseMinute >= sessionEndTotal
)

if finalSessionBar

    strategy.cancel(
         "Long"
    )

    strategy.cancel(
         "Short"
    )

    if inPosition

        strategy.close_all(
             immediately=true,
             comment="Session End",
             alert_message="SESSION_END_CNPS16"
        )


// ============================================================================
// SECTION 22: RANGE DISPLAY
// ============================================================================

plot(
     showRange and
     not na(rangeHigh)
     ? rangeHigh
     : na,
     title="Range High",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showRange and
     not na(rangeLow)
     ? rangeLow
     : na,
     title="Range Low",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)


// ============================================================================
// SECTION 23: ACTIVE SL / TP DISPLAY
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
// SECTION 24: OPTIONAL SIGNAL MARKERS
// ============================================================================
//
// These markers show ARMED SETUPS only.
// They are NOT actual TradingView fills.
//
// ============================================================================

plotshape(
     showSignalMarkers and
     longSetupArmed,
     title="Long Breakout Armed",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.tiny,
     color=color.green,
     text="L",
     textcolor=color.white
)

plotshape(
     showSignalMarkers and
     shortSetupArmed,
     title="Short Breakout Armed",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.tiny,
     color=color.red,
     text="S",
     textcolor=color.white
)


// ============================================================================
// SECTION 25: DIAGNOSTICS
// ============================================================================

var table diagnostics = table.new(
     position.top_right,
     2,
     11,
     border_width=1
)

if (
     showDiagnostics and
     barstate.islast
)

    string statusText = "IDLE"

    if insideRangeWindow
        statusText := "BUILD RANGE"

    if validRange and not tradedToday
        statusText := "WAIT BREAKOUT"

    if tradedToday
        statusText := "DONE TODAY"

    if inPosition
        statusText := positionLong ? "LONG" : "SHORT"


    table.cell(
         diagnostics,
         0,
         0,
         "CNPS16"
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
         "Status"
    )

    table.cell(
         diagnostics,
         1,
         1,
         statusText
    )


    table.cell(
         diagnostics,
         0,
         2,
         "Range Locked"
    )

    table.cell(
         diagnostics,
         1,
         2,
         rangeLocked
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         3,
         "Range High"
    )

    table.cell(
         diagnostics,
         1,
         3,
         str.tostring(
             rangeHigh
         )
    )


    table.cell(
         diagnostics,
         0,
         4,
         "Range Low"
    )

    table.cell(
         diagnostics,
         1,
         4,
         str.tostring(
             rangeLow
         )
    )


    table.cell(
         diagnostics,
         0,
         5,
         "Range Width"
    )

    table.cell(
         diagnostics,
         1,
         5,
         str.tostring(
             rangeWidth
         )
    )


    table.cell(
         diagnostics,
         0,
         6,
         "Long Armed"
    )

    table.cell(
         diagnostics,
         1,
         6,
         longSetupArmed
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         7,
         "Short Armed"
    )

    table.cell(
         diagnostics,
         1,
         7,
         shortSetupArmed
         ? "YES"
         : "NO"
    )


    table.cell(
         diagnostics,
         0,
         8,
         "SL / TP"
    )

    table.cell(
         diagnostics,
         1,
         8,
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
         9,
         "Position"
    )

    table.cell(
         diagnostics,
         1,
         9,
         positionLong
         ? "LONG"
         : (
             positionShort
             ? "SHORT"
             : "FLAT"
         )
    )


    table.cell(
         diagnostics,
         0,
         10,
         "Traded Today"
    )

    table.cell(
         diagnostics,
         1,
         10,
         tradedToday
         ? "YES"
         : "NO"
    )
````
