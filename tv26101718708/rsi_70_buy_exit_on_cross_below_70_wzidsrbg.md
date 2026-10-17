# RSI > 70 Buy / Exit on Cross Below 70

- url: https://www.tradingview.com/script/wZIdSrBG/
- type: strategy
- pine_id: PUB;eaf7ce6509f84bcb9f9f5725afa0ff6c
- version: 1.0

## Description

This strategy buys when the RSI (Relative Strength Index) closes above 70, indicating strong market momentum. It closes the position as soon as the RSI crosses down and falls below 70, to secure profits before a possible reversal.

In summary:

Entry: RSI > 70

Exit: RSI crosses down below 70

It’s a momentum-based strategy that aims to take advantage of strong trends but exits as soon as the momentum weakens.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Boubizee

//@version=6

strategy('RSI > 70 Buy / Exit on Cross Below 70', overlay = false)

rsiLength = input.int(14, title = 'Période RSI')
rsiLevel = input.float(70, title = 'Niveau RSI')

rsiValue = ta.rsi(close, rsiLength)

longCondition = rsiValue > rsiLevel and rsiValue[1] <= rsiLevel

exitCondition = ta.crossunder(rsiValue, rsiLevel)

if longCondition
    strategy.entry('Long', strategy.long)

if exitCondition
    strategy.close('Long')

plot(rsiValue, title = 'RSI', color = color.blue)
hline(rsiLevel, title = 'Niveau 70', color = color.red)
````
