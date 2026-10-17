# v6 FakeOut V2 SHD (indicator)

- url: https://www.tradingview.com/script/vA4b07vQ-v6-FakeOut-V2-SHD-indicator/
- type: indicator
- pine_id: PUB;5bc8b3a4977440d4bcde3b69dacfdc5d
- version: 1.0

## Description

Simple indicator for fake out condition.

fake out in this indicator consider when previous candle bearish then current candle also bearish with its spike higher than previous spike. Sign & alert appear as fake out sell signal.

Same thing with bullish condition.
When previous candle bullish, then current candle also bullish, with low spike is lower than previous low spike, consider as bullish signal.

customized with sign & alert when condition meet.

enjoy.

## Source Code

````pine
//@version=6
indicator("FakeOut V2 SHD", overlay=true)

// Define previous and current candles' lows and highs
high_1 = high[1]
low_1 = low[1]
open_1 = open[1]
close_1 = close[1]
high_0 = high
low_0 = low
open_0 = open
close_0 = close

// Define previous and current candles as bullish or bearish
bull_1 = close[1] > open[1]
bull_0 = close > open
bear_1 = close[1] < open[1]
bear_0 = close < open

// Bullish liquidity sweep condition: The current bullish candle's low sweeps the previous bullish candle's low
bullFo = low_0 < low_1 and close_0 < high_1

// Bearish liquidity sweep condition: The current bearish candle's high sweeps the previous bearish candle's high
bearFo = high_0 > high_1 and close_0 > low_1

// Entry conditions: Only trigger if the bar has closed
bullishEntryCondition = bullFo and bull_1 and bull_0 and barstate.isconfirmed
bearishEntryCondition = bearFo and bear_1 and bear_0 and barstate.isconfirmed

// Set stop-loss and take-profit for bullish entries
bullishStopLoss = low_0 - 10 * syminfo.mintick
bullishTakeProfit = close + 2 * (close - bullishStopLoss)

// Set stop-loss and take-profit for bearish entries
bearishStopLoss = high_0 + 10 * syminfo.mintick
bearishTakeProfit = close - 2 * (bearishStopLoss - close)

// Execute trades if conditions are met and there's no open trade
// if (bullishEntryCondition and strategy.opentrades == 0)
//    strategy.entry("Long", strategy.long)
//    strategy.exit("Take Profit/Stop Loss", "Long", stop=bullishStopLoss, limit=bullishTakeProfit)

// if (bearishEntryCondition and strategy.opentrades == 0)
//    strategy.entry("Short", strategy.short)
//    strategy.exit("Take Profit/Stop Loss", "Short", stop=bearishStopLoss, limit=bearishTakeProfit)

// Plot the signals for both bullish and bearish grabs
plotshape(series=bullishEntryCondition, title="Bull FO", location=location.belowbar, color=color.green, style=shape.triangleup, size = size.small, text="BUY")
plotshape(series=bearishEntryCondition, title="Bear FO", location=location.abovebar, color=color.red, style=shape.triangledown, size = size.small, text="SELL")
// plot(low_1, color=color.red, linewidth=1, title="Previous Candle Low")
// plot(high_1, color=color.blue, linewidth=1, title="Previous Candle High")

// Alert Conditions: These will only trigger if the entry condition is valid after the candle has closed
alertcondition(bullishEntryCondition, title="Bull FO", message="Bull FO")
alertcondition(bearishEntryCondition, title="Bear FO", message="Bear FO")
````
