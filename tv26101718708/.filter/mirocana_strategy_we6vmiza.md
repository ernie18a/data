# Mirocana Strategy

- url: https://www.tradingview.com/script/We6vmIza-Mirocana-Strategy/
- type: strategy
- pine_id: PUB;2603
- version: -1.0

## Description

[b]Check[/b] out this strategy.
for more information: [url=http://mirocana.com]mirocana.com[/url]

## Source Code

````pine
//@version=2
strategy("Mirocana.com", overlay=true, currency=currency.USD, initial_capital=10000)
dt = input(defval=0.0010, title="Decision Threshold", type=float, step=0.0001)

confidence=(security(tickerid, 'D', close)-security(tickerid, 'D', close[1]))/security(tickerid, 'D', close[1])
prediction = confidence > dt ? true : confidence < -dt ? false : prediction[1]

bgcolor(prediction ? green : red, transp=93)

if (prediction)
    strategy.exit("Close", "Short")
    strategy.entry("Long", strategy.long, qty=10000*confidence)

if (not prediction)
    strategy.exit("Close", "Long")
    strategy.entry("Short", strategy.short, qty=-10000*confidence)
````
