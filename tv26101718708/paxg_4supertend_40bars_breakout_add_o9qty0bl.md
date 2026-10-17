# PAXG 4-Supertend + 40Bars Breakout add

- url: https://www.tradingview.com/script/o9qty0BL-PAXG-4-Supertend-40Bars-Breakout-add/
- type: strategy
- pine_id: PUB;346b8f21bdfe4fe690c6db10d3c81259
- version: 1.0

## Description

[b]PAXG 4H Supertrend + 40-Bar Breakout [/b]
This strategy is designed for PAX Gold (PAXG) on the 4-hour timeframe, combining Supertrend-based trend identification with a 40-bar closing-price breakout to capture sustained bullish moves.

[b]Strategy Logic[/b]
[i]1. Base Long Entry — Supertrend[/i]

Opens a long position when the Supertrend flips from bearish to bullish.
Enters only when no position is currently open.
Uses the Supertrend settings of ATR Length 10 and Multiplier 4.0 by default.

[i]2. Breakout Add-On — 40-Bar Closing High[/i]

Adds a position when the market is already in a long trade and the current candle closes above the highest closing price of the previous 40 completed candles.
Adds an additional position equivalent to 30% of current strategy equity by default.
Allows only one breakout add-on per trade.
[i]
3. Exit — Bearish Supertrend Reversal[/i]

Closes the entire long position when the Supertrend flips from bullish to bearish.
Includes an optional backtest end-date exit.
Key Features
Designed for 4-hour PAXG charts.
Trend-following entries using Supertrend.
Closing-price breakout confirmation to add to winning positions.
Configurable ATR settings, breakout lookback, and add-on percentage.
Optional backtest date filter.
Includes a configurable commission assumption of 0.03% per order.
Uses next-bar-open order execution settings for strategy entries and exits.
[b]
Risk Disclaimer[/b]
This is a long-only trend-following strategy intended for backtesting and research. Its performance depends on market conditions, execution assumptions, fees, and slippage. Backtest results do not guarantee future performance. Test the strategy thoroughly before using it with real capital.

## Source Code

````pine
//@version=6
strategy(
     title = "PAXG 4H Supertrend + 40-Bar Breakout Add",
     overlay = true,
     initial_capital = 100000,
     currency = currency.USD,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 100,
     pyramiding = 2,
     commission_type = strategy.commission.percent,
     commission_value = 0.03,
     process_orders_on_close = false,
     calc_on_every_tick = false,
     margin_long = 50
)

//====================================================
// INPUTS
//====================================================

// Supertrend
atrLength = input.int(
     10,
     title = "Supertrend ATR Length",
     minval = 1
)

stMultiplier = input.float(
     4.0,
     title = "Supertrend Multiplier",
     step = 0.1
)

// Breakout confirmation
breakoutLength = input.int(
     40,
     title = "Breakout Lookback",
     minval = 2
)

// Add-on size
addPercent = input.float(
     30.0,
     title = "Add-on Position %",
     minval = 1,
     maxval = 50,
     step = 5
)

//====================================================
// BACKTEST DATE RANGE
//====================================================

// Default = 25 Sep 2021
startDate = input.time(
     1632528000000,
     title = "Backtest Start Date"
)

// Default = 25 Sep 2026
endDate = input.time(
     1790380740000,
     title = "Backtest End Date"
)

useDateFilter = input.bool(
     true,
     title = "Use Backtest Date Filter"
)

inDateRange =
     not useDateFilter or
     (time >= startDate and time <= endDate)

//====================================================
// SUPERTREND
//====================================================

[supertrend, direction] =
     ta.supertrend(stMultiplier, atrLength)

// TradingView Supertrend convention:
//
// direction < 0 = bullish
// direction > 0 = bearish

bullish = direction < 0
bearish = direction > 0

bullishFlip =
     bullish and
     direction[1] > 0

bearishFlip =
     bearish and
     direction[1] < 0

//====================================================
// 40-BAR CLOSING HIGH
//====================================================

// Highest CLOSE of the PREVIOUS 40 completed candles.
// Current candle is deliberately excluded.

highestPreviousClose =
     ta.highest(close, breakoutLength)[1]

breakoutSignal =
     close > highestPreviousClose

//====================================================
// TRADE STATE
//====================================================

// Prevent more than one add-on during each trade.

var bool addedPosition = false

// Reset once completely flat
if strategy.position_size == 0 and strategy.position_size[1] != 0
    addedPosition := false

//====================================================
// BASE ENTRY
//====================================================

// Supertrend flips bullish on completed 4H candle.
//
// process_orders_on_close = false means
// the market order fills on the NEXT bar open.

if (
     inDateRange and
     bullishFlip and
     strategy.position_size == 0
   )

    strategy.entry(
         id = "Base Long",
         direction = strategy.long
    )

//====================================================
// 30% ADD-ON
//====================================================

// Requirements:
//
// 1. Already long
// 2. No previous add-on during this trade
// 3. Close > highest CLOSE of previous 40 bars
//
// Order is created after this candle closes
// and normally fills on the NEXT 4H open.

if (
     inDateRange and
     strategy.position_size > 0 and
     not addedPosition and
     breakoutSignal
   )

    // 30% of current strategy equity.
    //
    // Pine requires explicit quantity for this
    // second order, so equity is converted into
    // PAXG units using current closing price.

    addQty =
         (strategy.equity * (addPercent / 100.0)) /
         close

    strategy.entry(
         id = "Breakout Add",
         direction = strategy.long,
         qty = addQty
    )

    addedPosition := true

//====================================================
// EXIT
//====================================================

// Exit entire position immediately after
// Supertrend changes from bullish to bearish.
//
// With process_orders_on_close = false,
// exit fills on NEXT 4H bar open.

if (
     strategy.position_size > 0 and
     bearishFlip
   )

    strategy.close_all(
         comment = "Bearish Supertrend"
    )

//====================================================
// END-DATE EXIT
//====================================================

if (
     useDateFilter and
     time > endDate and
     strategy.position_size > 0
   )

    strategy.close_all(
         comment = "End of Backtest"
    )

//====================================================
// VISUALS
//====================================================

plot(
     bullish ? supertrend : na,
     title = "Bullish Supertrend",
     color = color.green,
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     bearish ? supertrend : na,
     title = "Bearish Supertrend",
     color = color.red,
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     highestPreviousClose,
     title = "Previous 40-Bar Highest Close",
     color = color.orange,
     linewidth = 1
)

// Base entry marker
plotshape(
     bullishFlip and inDateRange,
     title = "Base Entry",
     location = location.belowbar,
     style = shape.triangleup,
     color = color.green,
     size = size.small,
     text = "BUY"
)

// Add-on marker
plotshape(
     strategy.position_size > 0 and
     breakoutSignal and
     not addedPosition[1],
     title = "30% Add",
     location = location.belowbar,
     style = shape.circle,
     color = color.blue,
     size = size.small,
     text = "+30%"
)

// Exit marker
plotshape(
     strategy.position_size > 0 and
     bearishFlip,
     title = "Exit",
     location = location.abovebar,
     style = shape.triangledown,
     color = color.red,
     size = size.small,
     text = "EXIT"
)
````
