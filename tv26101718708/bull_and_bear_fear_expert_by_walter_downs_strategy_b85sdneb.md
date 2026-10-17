# Bull and Bear Fear Expert by Walter Downs Strategy

- url: https://www.tradingview.com/script/B85sdNEB/
- type: strategy
- pine_id: PUB;GPoG6mRiLD4Cnn47qTn87tOsBCp0qo5n
- version: 2.0

## Description

Bull and Bear Fear Expert by Walter Downs Strategy

## Source Code

````pine
//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ceyhun

strategy("Bull and Bear Fear Expert by Walter Downs Strategy", overlay=true)

n = input(12, "Time periods")
Barcolor = input(true, title="Barcolor")

BullFear = (highest(high, n) - lowest(high, n)) / 2 + lowest(high, n)
BearFear = (highest(low, n) - lowest(low, n)) / 2 + lowest(low, n)

b_color = close > BullFear ? color.blue : close < BearFear ? color.red : color.gray
barcolor(Barcolor ? b_color : na)

plot(BullFear, color=#0000FF, linewidth=2)
plot(BearFear, color=#FF5252, linewidth=2)

longCondition = crossover(close, BullFear)
if longCondition
    strategy.entry("Long", strategy.long)

shortCondition = crossover(BearFear, close)
if shortCondition
    strategy.entry("Short", strategy.short)
````
