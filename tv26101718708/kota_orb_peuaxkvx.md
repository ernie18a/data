# Kota ORB

- url: https://www.tradingview.com/script/PeUaXKVx-Kota-ORB/
- type: indicator
- pine_id: PUB;234acab7fe6f4f0392275ef86ac58641
- version: 1.0

## Description

One of the best data based indicators ive made. It will make you very happy.

## Source Code

````pine
//@version=6
indicator("Kota ORB", overlay=true)

nySession = input.session("0830-0945", "NY Session")

inNY = not na(time(timeframe.period, nySession))

var float orbHigh = na
var float orbLow = na

newSession = inNY and not inNY[1]

if newSession
    orbHigh := high
    orbLow := low

if inNY
    orbHigh := math.max(orbHigh, high)
    orbLow := math.min(orbLow, low)

plot(orbHigh, color=color.green, linewidth=2)
plot(orbLow, color=color.red, linewidth=2)
````
