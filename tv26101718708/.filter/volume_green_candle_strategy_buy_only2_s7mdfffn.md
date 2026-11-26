# Volume + Green Candle Strategy (BUY ONLY)2

- url: https://www.tradingview.com/script/S7MdFfFN-Volume-Green-Candle-Strategy-BUY-ONLY-2/
- type: strategy
- pine_id: PUB;72743c5f4e074f979f54c75d74a2aa6f
- version: 1.0

## Description

Strategy Idea

The strategy buys when there is strong bullish activity with high volume and exits when the price shows weakness.

When the Strategy BUYS

It enters a BUY trade when all of these happen:

Volume is higher than average
Current volume is greater than the last 21 candles' average volume.

Green candle
The candle closed higher than it opened.

Not an inside candle
The candle is not completely inside the previous candle's range.

➡ This means strong buyers are entering the market.

When the Strategy EXITS

It closes the trade when:

• The price closes below the previous candle's low.

➡ This signals possible weakness or trend change.

Important Rules

• Only one trade at a time
• Uses 100% of capital per trade
• Orders are taken after candle close

In One Line

Buy strong bullish high-volume candles and exit when price becomes weak.  It is for index only like NIFTYBANK Future and NIFTY Future

## Source Code

````pine
//@version=5
strategy("Volume + Green Candle Strategy (BUY ONLY)2",
     overlay=true,
     pyramiding=0,
     process_orders_on_close=true,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100)

// ===== INPUT =====
volLength = input.int(21, "Volume MA Length")

// ===== VOLUME =====
volMA = ta.sma(volume, volLength)

// ===== CANDLES =====
greenCandle = close > open

// ===== INSIDE BAR FILTER =====
insidePrevCandle = high < high[1] and low > low[1]

// ===== BUY CONDITION =====
buyCondition = volume > volMA and greenCandle and not insidePrevCandle

// ===== ENTRY =====
if buyCondition and strategy.position_size == 0
    strategy.entry("BUY", strategy.long)

// ===== EXIT =====
exitCondition = strategy.position_size > 0 and close < low[1]

if exitCondition
    strategy.close("BUY")
````
