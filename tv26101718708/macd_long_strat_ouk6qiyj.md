# MACD Long Strat

- url: https://www.tradingview.com/script/Ouk6qIyJ-MACD-Long-Strat/
- type: strategy
- pine_id: PUB;INAa9zwx7EfBNJ0vDc1rOZdGvvmZzuV2
- version: 1.0

## Description

First script I've written, but the concept is pretty simple. This uses the MACD with settings fast_SMA = 6 and slow SMA=16 and uses the distance between the 2 (histogram) to look for potential trend reversals to flag potential entries for Long trades. It waits for the confirmation looking backward 2 x timeframes (to reduce false calls slightly). You can adjust it to open / close quicker (1 timeframe instread of 2) but backtesting shows 2 timeframe delay is best to avoid false signals. 

[image]https://www.tradingview.com/x/TKDaOntD/[/image]



The script suggests Long entry points based on this criteria and uses the converse (reducing histogram / SMA difference delayed by 2 timeframes) to suggest exit or trade close points for downward reversal. It was originally written looking at 1m scalps but backtesting shows this is even more effective on higher timeframes (1D).

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheGrindToday

//@version=4
strategy("MACD Long Strat", overlay=false)


//fast = 12, slow = 26
fast = 6, slow = 26
fastMA = ema(close, fast)
slowMA = ema(close, slow)
macd = fastMA - slowMA
signal = sma(macd, 9)
histogram = macd-signal

macdpos = histogram[0] > 0
macdneg = histogram[0] < 0

histogram_reversing_negative = histogram[1] > histogram[2]


LongEntryCondition =  histogram > histogram[1] 
ShortEntryCondition =  histogram < histogram[1]

exitConditionLong = histogram[0] < histogram[2]

if (LongEntryCondition and histogram_reversing_negative)
    strategy.entry("Long", strategy.long)


if (exitConditionLong)
    strategy.close("Long")
    
plot(histogram)
````
