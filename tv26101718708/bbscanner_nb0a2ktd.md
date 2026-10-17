# BBScanner

- url: https://www.tradingview.com/script/Nb0A2KtD-BBScanner/
- type: indicator
- pine_id: PUB;f5a9059ebcf34a2aabaffd2216811e0e
- version: 2.0

## Description

it checks 3 days candle into 1 candle and checks if the close is below the 3 days lower bolling band

## Source Code

````pine
//@version=5
indicator("BBScanner", overlay=true)

// --- 3-Day Candle Math ---
// 3-Day Close = Current Close
// 3-Day Open  = Open from 2 bars ago
// 3-Day High  = Highest High of last 3 bars
// 3-Day Low   = Lowest Low of last 3 bars
three_day_close = close
three_day_high  = ta.highest(high, 3)
three_day_low   = ta.lowest(low, 3)

// --- Bollinger Bands on 3-Day Basis ---
// We use a length of 20, but calculated on the 3-day "simulated" price
bb_length = 20
bb_mult   = 2.0
basis     = ta.sma(three_day_close, bb_length)
dev       = bb_mult * ta.stdev(three_day_close, bb_length)
lower_bb  = basis - dev

// --- The Condition ---
// Is the current 3-day close below the 3-day Lower BB?
is_below = three_day_close < lower_bb

// --- Export for Screener ---
// We plot '1' for true and '0' for false so the screener can read it
plot(is_below ? 1 : 0, "BBBelow", display=display.none)

// Visual for your chart
plot(lower_bb, "BBLower", color=color.red)
plotchar(is_below, "Signal", "▼", location.top, color=color.red)
````
