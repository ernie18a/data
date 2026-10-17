# KAMA Multi (5lines)

- url: https://www.tradingview.com/script/BlV0XXtM-KAMA-Multi-5lines/
- type: indicator
- pine_id: PUB;91eed0c310454ffcb981b32addfaea12
- version: 1.0

## Description

[b]Overview[/b]
This advanced trading tool provides a high-performance implementation of Kaufman’s Adaptive Moving Average (KAMA). Unlike standard indicators, KAMA automatically adjusts its sensitivity based on market noise and volatility. This allows the indicator to remain smooth during sideways movements while staying highly responsive during strong price breakouts.

[b]Key Features[/b]
Adaptive Trend Analysis: The tool calculates the Efficiency Ratio (ER) to distinguish between a clear trend and market "noise." It speeds up when the trend is strong and slows down when the market is choppy.

Multi-Timeframe (MTF) Capabilities: You can track market cycles from higher timeframes (e.g., viewing a 4-hour KAMA on a 15-minute chart) to maintain a "big picture" perspective.

5 Independent Adaptive Lines: Manage up to five separate KAMA layers simultaneously. This allows you to visualize multiple market cycles—from short-term momentum to long-term structural trends—on a single chart.

Sophisticated Smoothing: Each line uses "Fast" and "Slow" boundaries to define how quickly the average should react to price changes, offering a customized balance between speed and reliability.

[b]How to Use the Parameters[/b]
ER (Efficiency Ratio): Controls the period used to measure trend strength.

Fast/Slow Settings: These define the range of the adaptation. In a trending market, the line acts like a fast average; in a range, it shifts toward the slower, more stable setting.

Timeframe Selector: Allows you to synchronize your analysis across different chart intervals for a more comprehensive strategy.

[b]Strategic Utility[/b]
Trend Filtering: Use the higher-period KAMA lines as a primary trend bias. Only take trades in the direction of the adaptive slope.

Mean Reversion: Because KAMA flattens during consolidation, these flat zones act as powerful dynamic support and resistance levels.

Counter-Trend Potential: Identifying extreme deviations of price from the adaptive lines helps locate overextended market conditions and potential reversal points.

## Source Code

````pine
//@version=6
indicator("KAMA Multi (5lines)", overlay = true)

import TradingView/ta/11 as TVta

src = input.source(close, "Source")
tf  = input.timeframe("", "Timeframe") // пусто = текущий ТФ графика

f_kama(src, er, fast, slow) =>
    TVta.kama(src, er, fast, slow)

use1  = input.bool(true,  "Enable KAMA 1")
er1   = input.int(10, "ER 1")
fast1 = input.int(2,  "Fast 1")
slow1 = input.int(30, "Slow 1")

use2  = input.bool(false, "Enable KAMA 2")
er2   = input.int(10, "ER 2")
fast2 = input.int(2,  "Fast 2")
slow2 = input.int(30, "Slow 2")

use3  = input.bool(false, "Enable KAMA 3")
er3   = input.int(10, "ER 3")
fast3 = input.int(2,  "Fast 3")
slow3 = input.int(30, "Slow 3")

use4  = input.bool(false, "Enable KAMA 4")
er4   = input.int(10, "ER 4")
fast4 = input.int(2,  "Fast 4")
slow4 = input.int(30, "Slow 4")

use5  = input.bool(false, "Enable KAMA 5")
er5   = input.int(10, "ER 5")
fast5 = input.int(2,  "Fast 5")
slow5 = input.int(30, "Slow 5")

k1 = use1 ? request.security(syminfo.tickerid, tf, f_kama(src, er1, fast1, slow1)) : na
k2 = use2 ? request.security(syminfo.tickerid, tf, f_kama(src, er2, fast2, slow2)) : na
k3 = use3 ? request.security(syminfo.tickerid, tf, f_kama(src, er3, fast3, slow3)) : na
k4 = use4 ? request.security(syminfo.tickerid, tf, f_kama(src, er4, fast4, slow4)) : na
k5 = use5 ? request.security(syminfo.tickerid, tf, f_kama(src, er5, fast5, slow5)) : na

plot(k1, "KAMA 1", color=color.blue)
plot(k2, "KAMA 2", color=color.red)
plot(k3, "KAMA 3", color=color.green)
plot(k4, "KAMA 4", color=color.orange)
plot(k5, "KAMA 5", color=color.purple)
````
