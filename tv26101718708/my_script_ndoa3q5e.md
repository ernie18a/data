# My script

- url: https://www.tradingview.com/script/NDOa3Q5e-My-script/
- type: indicator
- pine_id: PUB;56087aeb8d3f400f8caecfd2512713b7
- version: 1.0

## Description

// IBD/CANSLIM swing trade entry signals with VWAP confirmation
// Plots: PrevClose, CurrClose, VWAP for webhook execution

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradingjunky34

//@version=6
indicator("My script")
plot(close)
plot(close[1], title="PrevClose")
plot(close[0], title="CurrClose")
plot(ta.vwap, title="VWAP")
````
