# EMA Strat

- url: https://www.tradingview.com/script/NFFIcgFf-EMA-Strat/
- type: strategy
- pine_id: PUB;af6572d663ea444e8d623f4e9a36ebe0
- version: 1.0

## Description

If previous day close above EMA, enter long at open the following day. Exit long position if prices close below EMA.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ericdwyang

//@version=5
strategy("EMA Strat", overlay=true, margin_long=100, margin_short=100)

// EMA Variables
emaInput = input(21, "Length")
ema = ta.ema(close, emaInput)

// Variable Declaration
p = 0

start = false

// Start Date
yearInput = input(2000, "Year")
if (time >= timestamp(2000,01,01,01,01))
    start := true


// Check first candle relative to EMA
if (close > ema and start == true)
    p += 1
    strategy.entry("Long", strategy.long, comment = "Entry")
    

// Candle close above EMA (p + 1, count reset to 0)
above = close[1] > ema[1]
if (above)
    p += 1



// Candle close below EMA (reset p to 0, count -1)
below = close < ema
if (below)
    p := 0
    strategy.close("Long", comment = "Flat")

// // Exit Position
// if (redCount == -2)
//     strategy.close("Long", comment = "Flat")
    
// goLong = p[1] == 0 and p == 1
// flatten = p == 0
    
// // Restablish long    
// if (goLong and start == true)
//     strategy.entry("Long", strategy.long, comment = "Entry")
    

plot(p)
plot(ema)
````
