# Crypto ORB 15M more sesions

- url: https://www.tradingview.com/script/B8EkuTQs/
- type: indicator
- pine_id: PUB;da677c175cbd4ad196108c13d315107c
- version: 1.0

## Description

Sessie

Instelling

Londen open

0800-0815

New York open

1530-1545

Asia open

0200-0215

## Source Code

````pine
//@version=5
indicator("Crypto ORB 15M", overlay=true)

// === INSTELLINGEN ===
orbSession = input.session("1530-1545", title="ORB Session")
showSignals = input.bool(true, title="Show Buy/Sell Signals")

// === ORB RANGE ===
inSession = not na(time(timeframe.period, orbSession))

var float orbHigh = na
var float orbLow = na

if inSession
    orbHigh := high
    orbLow := low

// === BREAKOUTS ===
longBreak = ta.crossover(close, orbHigh)
shortBreak = ta.crossunder(close, orbLow)

// === LIJNEN ===
plot(orbHigh, color=color.green, linewidth=2, title="ORB High")
plot(orbLow, color=color.red, linewidth=2, title="ORB Low")

// === SIGNALEN ===
plotshape(showSignals and longBreak,
     title="BUY",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     text="BUY")

plotshape(showSignals and shortBreak,
     title="SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

// === ALERTS ===
alertcondition(longBreak, title="ORB Buy", message="ORB BUY SIGNAL")
alertcondition(shortBreak, title="ORB Sell", message="ORB SELL SIGNAL")
````
