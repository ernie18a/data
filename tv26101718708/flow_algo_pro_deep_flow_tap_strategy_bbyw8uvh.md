# Flow Algo Pro - Deep Flow Tap Strategy

- url: https://www.tradingview.com/script/BbYw8uVH-Flow-Algo-Pro-Deep-Flow-Tap-Strategy/
- type: strategy
- pine_id: PUB;eb5d123a1ca0433cb53f0e8784f6469f
- version: 2.0

## Description

Flow Algo Pro – Deep Flow Tap Strategy is a trend-following pullback strategy designed to identify potential continuation entries after price retraces into the 20/50 EMA Deep Flow Zone.
The strategy uses the relationship between the 20 EMA and 50 EMA to establish the current directional bias. When the 20 EMA is above the 50 EMA, the market is considered bullish; when the 20 EMA is below the 50 EMA, the market is considered bearish.    Pasted markdown
Rather than entering immediately when the trend is established, the strategy waits for price to pull back into the area between the 20 EMA and 50 EMA.

Long Setup
A long setup occurs when:
1. The 20 EMA is above the 50 EMA, establishing a bullish trend.
2. Price retraces and touches or overlaps the 20/50 EMA zone.
3. The candle then closes above the upper boundary of the zone.
4. When enabled, the confirmation candle must also be bullish.
5. If there is no existing position, a long trade is triggered.

Short Setup
A short setup is the exact opposite:
1. The 20 EMA is below the 50 EMA, establishing a bearish trend.
2. Price retraces into the 20/50 EMA zone.
3. The candle closes below the lower boundary of the zone.
4. When enabled, the confirmation candle must also be bearish.
5. If there is no existing position, a short trade is triggered.

Trade Management
The strategy uses a fixed stop-loss and take-profit system.
The default configuration is:
- 10m chart
- Stop Loss: 30 points
- Take Profit: 65 points
- Risk/Reward: approximately 1:2.17
- Default position: 1 contract
The stop and target are calculated from the actual strategy position's average entry price.    

The strategy uses actual stop and limit orders, meaning the TP/SL levels can be triggered by an intrabar price touch rather than requiring the candle to close beyond the level.

Trade Protection
Only one trade can be active at a time. Once a position is opened, the strategy locks further entries until the existing position has been closed. This prevents multiple signals from creating unwanted pyramiding or overlapping positions.

Best Use
The strategy is designed primarily for trend continuation and pullback trading, rather than attempting to predict market reversals.
The basic concept is:
Trend → Pullback → Deep Flow Zone Tap → Rejection → Entry
The 20/50 EMA zone acts as the area where the strategy looks for price to temporarily retrace before potentially continuing in the established direction.
Important Disclaimer

This script is a technical analysis and backtesting tool. It does not guarantee profitable results and should not be considered financial advice. Historical backtest performance does not guarantee future results. Traders should independently evaluate the strategy, including transaction costs, slippage, market conditions and position sizing, before using it with real capital.

## Source Code

````pine
//@version=6
//@version=6
strategy(
     "Flow Algo Pro - Deep Flow Tap Strategy V3",
     overlay=true,
     pyramiding=0,
     process_orders_on_close=true,
     calc_on_order_fills=true,
     initial_capital=25000,
     default_qty_type=strategy.fixed,
     default_qty_value=1,
     commission_type=strategy.commission.cash_per_contract,
     commission_value=0.50,
     margin_long=0.333333,
     margin_short=0.333333
)

//====================================================
// INPUTS
//====================================================

//-------------------------
// Deep Flow Zone
//-------------------------
groupFlow = "Deep Flow Zone"

fastLength = input.int(
     20,
     "Fast EMA",
     minval=1,
     group=groupFlow
)

slowLength = input.int(
     50,
     "Slow EMA",
     minval=1,
     group=groupFlow
)

requireBullishClose = input.bool(
     true,
     "Require Bullish Candle For Long",
     group=groupFlow
)

requireBearishClose = input.bool(
     true,
     "Require Bearish Candle For Short",
     group=groupFlow
)

//-------------------------
// Risk Management
//-------------------------
groupRisk = "Risk Management"

contracts = input.int(
     1,
     "Contracts",
     minval=1,
     group=groupRisk
)

stopPoints = input.float(
     30.0,
     "Stop Loss Points",
     minval=0.25,
     step=0.25,
     group=groupRisk
)

targetPoints = input.float(
     65.0,
     "Take Profit Points",
     minval=0.25,
     step=0.25,
     group=groupRisk
)

//-------------------------
// Display
//-------------------------
groupDisplay = "Display"

showEMAs = input.bool(
     true,
     "Show 20 / 50 EMA",
     group=groupDisplay
)

showZone = input.bool(
     true,
     "Show Deep Flow Zone",
     group=groupDisplay
)

showTradeLevels = input.bool(
     true,
     "Show TP / SL Levels",
     group=groupDisplay
)

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group=groupDisplay
)

//-------------------------
// Colours
//-------------------------
groupColors = "Colours"

fastColor = input.color(
     color.orange,
     "20 EMA",
     group=groupColors
)

slowColor = input.color(
     color.blue,
     "50 EMA",
     group=groupColors
)

bullZoneColor = input.color(
     color.green,
     "Bullish Zone",
     group=groupColors
)

bearZoneColor = input.color(
     color.red,
     "Bearish Zone",
     group=groupColors
)

longSignalColor = input.color(
     color.lime,
     "Long Signal",
     group=groupColors
)

shortSignalColor = input.color(
     color.red,
     "Short Signal",
     group=groupColors
)

//====================================================
// EMA CALCULATIONS
//====================================================

ema20 = ta.ema(close, fastLength)
ema50 = ta.ema(close, slowLength)

//====================================================
// DEEP FLOW ZONE
//====================================================

zoneHigh = math.max(ema20, ema50)
zoneLow  = math.min(ema20, ema50)

// Trend direction
bullTrend = ema20 > ema50
bearTrend = ema20 < ema50

//====================================================
// TAP DETECTION
//====================================================

// Candle must overlap/touch the 20/50 zone.
zoneTap = high >= zoneLow and low <= zoneHigh

//====================================================
// LONG SETUP
//====================================================

// Price taps the zone and closes completely above it.
longClosesOutside = close > zoneHigh

longBullishCandle = close > open

longRejection =
     zoneTap and
     longClosesOutside and
     (
         not requireBullishClose or
         longBullishCandle
     )

longSignal =
     bullTrend and
     longRejection

//====================================================
// SHORT SETUP
//====================================================

// Price taps the zone and closes completely below it.
shortClosesOutside = close < zoneLow

shortBearishCandle = close < open

shortRejection =
     zoneTap and
     shortClosesOutside and
     (
         not requireBearishClose or
         shortBearishCandle
     )

shortSignal =
     bearTrend and
     shortRejection

//====================================================
// TRADE LOCK
//====================================================

// Custom lock prevents another trade from being
// opened while the current trade is active.

var bool tradeActive = false
var int activeDirection = 0
var int entryBar = na

// Release the lock after the position has actually
// closed, but never on the same bar as entry.
if tradeActive and strategy.position_size == 0 and bar_index > entryBar
    tradeActive := false
    activeDirection := 0
    entryBar := na

canEnter =
     not tradeActive and
     strategy.position_size == 0

//====================================================
// ENTRY ALERT MESSAGES
//====================================================

longAlertMessage =
     "LONG ENTRY | MNQ | 10M | Deep Flow Tap"

shortAlertMessage =
     "SHORT ENTRY | MNQ | 10M | Deep Flow Tap"

//====================================================
// ENTRIES
//====================================================

if longSignal and canEnter
    strategy.entry(
         "LONG",
         strategy.long,
         qty=contracts,
         alert_message=longAlertMessage
    )

    tradeActive := true
    activeDirection := 1
    entryBar := bar_index


if shortSignal and canEnter
    strategy.entry(
         "SHORT",
         strategy.short,
         qty=contracts,
         alert_message=shortAlertMessage
    )

    tradeActive := true
    activeDirection := -1
    entryBar := bar_index

//====================================================
// EXIT LEVELS
//====================================================

// These are calculated from the actual average
// strategy entry price.

longStop =
     strategy.position_avg_price - stopPoints

longTarget =
     strategy.position_avg_price + targetPoints

shortStop =
     strategy.position_avg_price + stopPoints

shortTarget =
     strategy.position_avg_price - targetPoints

//====================================================
// LONG EXIT
//====================================================

// stop= and limit= create actual price orders.
// Therefore an intrabar touch of either level
// can fill the exit without waiting for candle close.

if strategy.position_size > 0
    strategy.exit(
         "LONG TP/SL",
         from_entry="LONG",
         stop=longStop,
         limit=longTarget,
         alert_message="LONG EXIT | MNQ | 10M"
    )

//====================================================
// SHORT EXIT
//====================================================

if strategy.position_size < 0
    strategy.exit(
         "SHORT TP/SL",
         from_entry="SHORT",
         stop=shortStop,
         limit=shortTarget,
         alert_message="SHORT EXIT | MNQ | 10M"
    )

//====================================================
// PLOTS
//====================================================

plot(
     showEMAs ? ema20 : na,
     title="20 EMA",
     color=fastColor,
     linewidth=2
)

plot(
     showEMAs ? ema50 : na,
     title="50 EMA",
     color=slowColor,
     linewidth=2
)

//====================================================
// FLOW ZONE FILL
//====================================================

p20 = plot(
     showZone ? ema20 : na,
     title="20 EMA Zone",
     color=color.new(fastColor, 100)
)

p50 = plot(
     showZone ? ema50 : na,
     title="50 EMA Zone",
     color=color.new(slowColor, 100)
)

zoneFillColor =
     bullTrend ?
     color.new(bullZoneColor, 85) :
     bearTrend ?
     color.new(bearZoneColor, 85) :
     color.new(color.gray, 90)

fill(
     p20,
     p50,
     color=showZone ? zoneFillColor : na,
     title="Deep Flow Zone"
)

//====================================================
// BUY / SELL SIGNALS
//====================================================

plotshape(
     longSignal and canEnter,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=longSignalColor,
     textcolor=color.white,
     text="BUY",
     size=size.small
)

plotshape(
     shortSignal and canEnter,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=shortSignalColor,
     textcolor=color.white,
     text="SELL",
     size=size.small
)

//====================================================
// ACTIVE TP / SL LEVELS
//====================================================

plot(
     showTradeLevels and strategy.position_size > 0 ?
     longStop : na,
     title="Long Stop",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showTradeLevels and strategy.position_size > 0 ?
     longTarget : na,
     title="Long Target",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showTradeLevels and strategy.position_size < 0 ?
     shortStop : na,
     title="Short Stop",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showTradeLevels and strategy.position_size < 0 ?
     shortTarget : na,
     title="Short Target",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr
)

//====================================================
// DASHBOARD
//====================================================

var table dashboard = table.new(
     position.top_right,
     2,
     6,
     border_width=1
)

if barstate.islast and showDashboard

    trendText =
         bullTrend ? "BULLISH" :
         bearTrend ? "BEARISH" :
         "NEUTRAL"

    trendColor =
         bullTrend ? color.green :
         bearTrend ? color.red :
         color.gray

    tradeText =
         strategy.position_size > 0 ? "LONG" :
         strategy.position_size < 0 ? "SHORT" :
         tradeActive ? "LOCKED" :
         "READY"

    table.cell(
         dashboard,
         0,
         0,
         "FLOW ALGO",
         text_color=color.white,
         bgcolor=color.black
    )

    table.cell(
         dashboard,
         1,
         0,
         "10M",
         text_color=color.white,
         bgcolor=color.black
    )

    table.cell(
         dashboard,
         0,
         1,
         "Trend",
         text_color=color.white
    )

    table.cell(
         dashboard,
         1,
         1,
         trendText,
         text_color=color.white,
         bgcolor=trendColor
    )

    table.cell(
         dashboard,
         0,
         2,
         "Trade",
         text_color=color.white
    )

    table.cell(
         dashboard,
         1,
         2,
         tradeText,
         text_color=color.white
    )

    table.cell(
         dashboard,
         0,
         3,
         "SL",
         text_color=color.white
    )

    table.cell(
         dashboard,
         1,
         3,
         str.tostring(stopPoints) + " pts",
         text_color=color.white
    )

    table.cell(
         dashboard,
         0,
         4,
         "TP",
         text_color=color.white
    )

    table.cell(
         dashboard,
         1,
         4,
         str.tostring(targetPoints) + " pts",
         text_color=color.white
    )

    table.cell(
         dashboard,
         0,
         5,
         "R:R",
         text_color=color.white
    )

    table.cell(
         dashboard,
         1,
         5,
         "1:" + str.tostring(
             targetPoints / stopPoints,
             "#.##"
         ),
         text_color=color.white
    )

//====================================================
// ALERT CONDITIONS
//====================================================

// These give you selectable conditions in the
// TradingView Create Alert menu.

alertcondition(
     longSignal and canEnter,
     title="Long Signal",
     message="LONG SIGNAL | MNQ | 10M | Deep Flow Tap"
)

alertcondition(
     shortSignal and canEnter,
     title="Short Signal",
     message="SHORT SIGNAL | MNQ | 10M | Deep Flow Tap"
)
````
