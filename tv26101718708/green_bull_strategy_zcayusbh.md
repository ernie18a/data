# green bull strategy

- url: https://www.tradingview.com/script/ZCaYuSbH-green-bull-strategy/
- type: strategy
- pine_id: PUB;d8b57ef79ee04dfd890e1d4b8bd27e69
- version: 2.0

## Description

super trend strategy never be on the wrong side of a trade again,

 Use 35 Length and 3.3 multiplier on 3m for best result MNQ

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shane10kelly

//@version=5
strategy(title='Trend Trader Strategy', overlay=true, process_orders_on_close=true)

Length = input.int(21, minval=1)
Multiplier = input.float(3, minval=0.000001)

avgTR = ta.wma(ta.atr(1), Length)
highestC = ta.highest(Length)
lowestC = ta.lowest(Length)

hiLimit = highestC[1] - avgTR[1] * Multiplier
loLimit = lowestC[1] + avgTR[1] * Multiplier

ret = 0.0
pos = 0.0

ret := close > hiLimit and close > loLimit ? hiLimit :
       close < loLimit and close < hiLimit ? loLimit :
       nz(ret[1], close)

pos := close > ret ? 1 :
       close < ret ? -1 :
       nz(pos[1], 0)

// === TRADE EXECUTION ===
if pos != pos[1] and pos == 1
    strategy.entry("Long", strategy.long)
    alert("Buy Signal", alert.freq_once_per_bar_close)

if pos != pos[1] and pos == -1
    strategy.entry("Short", strategy.short)
    alert("Sell Signal", alert.freq_once_per_bar_close)

// === VISUALS ===
barcolor(pos == -1 ? color.red : pos == 1 ? color.green : color.blue)
plot(ret, color=color.blue, title='Trend Trader Line')
````
