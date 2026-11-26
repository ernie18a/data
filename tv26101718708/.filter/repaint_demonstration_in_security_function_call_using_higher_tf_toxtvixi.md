# Repaint Demonstration in Security Function Call using Higher TF

- url: https://www.tradingview.com/script/tOxtvIxI-Repaint-Demonstration-in-Security-Function-Call-using-Higher-TF/
- type: strategy
- pine_id: PUB;a458f8885c344c3086b71302495d3ede
- version: 1.0

## Description

Many Coders mistakenly use Security Function call on their backtest without knowing that the security function does look forward in the future and provide an unrealistic repainted result.
This Script's purpose is to give out a clear demonstration of how the security function does look forward in the data and should NOT be used by any means as a real trading strategy.

Please do NOT by any means use this strategy to trade!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © akrit8888
// @version=4

// "This Script is for demonstration of repaint by using security function to lookup the Future" 
// "And should NOT by any means be use in as a real trading strategy."

strategy("Repaint Demonstration in Security Function Call using Higher TF", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

bigTF = input("W", "Future Sight: ", input.resolution)
bigTFClose = security(syminfo.tickerid, bigTF, close)


buy = crossover(close, bigTFClose)
sell = crossover(bigTFClose, close)

plot(close)
plot(bigTFClose)
strategy.entry("L", true, when = buy)
strategy.close("L", when = sell)
````
