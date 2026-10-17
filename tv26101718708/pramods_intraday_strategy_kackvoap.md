# Pramod’s Intraday Strategy

- url: https://www.tradingview.com/script/kAckvOaP-Pramod-s-Intraday-Strategy/
- type: strategy
- pine_id: PUB;R0SaswKtvQ8KZUKAft6XcBlcjCVsCsJ3
- version: 1.0

## Description

If Open = High, Short with 0.25% Stop Loss and 0.5% Take Profit
If Open = Low, Long with 0.25% Stop Loss and 0.5% Take Profit

This strategy is given by desipplz.

## Source Code

````pine
//@version=2
strategy("OHL Strategy", overlay=true, default_qty_type = strategy.percent_of_equity, default_qty_value = 100)

if (open == low)
    strategy.entry("Long", strategy.long)
    strategy.exit("Exit", from_entry = "Long", profit = .5 * open, loss = .25 * open) 
    
if (open == high)
    strategy.entry("Short", strategy.short)
    strategy.exit("Exit", from_entry = "Short", profit = .5 * open, loss = .25 * open)
````
