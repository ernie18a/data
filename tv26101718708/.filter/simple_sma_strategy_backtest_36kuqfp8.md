# Simple SMA Strategy Backtest

- url: https://www.tradingview.com/script/36kUqFP8-Simple-SMA-Strategy-Backtest/
- type: strategy
- pine_id: PUB;MA6yn3Od3OgAlyW7LzYrFMN0LwXqlVr4
- version: 1.0

## Description

Added strategy logic.

Part 3:

https://www.tradingview.com/streams/5c-w3QL6VOhmL6_4FGJoP


Part 2:

https://www.tradingview.com/script/xmvJbCrm-Simple-SMA-Indicator-from-Stream/

https://www.tradingview.com/streams/JklgcKQGdQXV1RLMt2Y9r


Part 1:
Simple SMA Indicator
https://www.tradingview.com/script/djP5c8XZ-Simple-SMA-Indicator/

https://www.tradingview.com/streams/FYGStZButruT1_WkgMzyN



WARNING:
- For purpose educate only

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HPotter
//  Simple SMA strategy
//
// WARNING:
//      - For purpose educate only
//      - This script to change bars colors
//@version=4
strategy(title="Simple SMA Strategy Backtest", shorttitle="SMA Backtest", precision=6, overlay=true)
Resolution = input(title="Resolution", type=input.resolution, defval="D")
Source = input(title="Source", type=input.source, defval=close)
xSeries = security(syminfo.tickerid, Resolution, Source)
Length = input(title="Length", type=input.integer, defval=14, minval=2)
TriggerPrice = input(title="Trigger Price", type=input.source, defval=close)
BarColors = input(title="Painting bars", type=input.bool, defval=true)
ShowLine = input(title="Show Line", type=input.bool, defval=true)
UseAlerts = input(title="Use Alerts", type=input.bool, defval=false)
reverse = input(title="Trade Reverse", type=input.bool, defval=false)
pos = 0
xSMA = sma(xSeries, Length)
pos := iff(TriggerPrice > xSMA, 1,
         iff(TriggerPrice < xSMA, -1, nz(pos[1], 0)))
nRes = ShowLine ? xSMA : na
alertcondition(UseAlerts == true and pos != pos[1] and pos == 1, title='Signal Buy', message='Strategy to change to BUY')
alertcondition(UseAlerts == true and pos != pos[1] and pos == -1, title='Signal Sell', message='Strategy to change to SELL')
alertcondition(UseAlerts == true and pos != pos[1] and pos == 0, title='FLAT', message='Strategy get out from position')
possig = iff(reverse and pos == 1, -1,
           iff(reverse and pos == -1, 1, pos))
if (possig == 1)
    strategy.entry("Long", strategy.long)
if (possig == -1)
    strategy.entry("Short", strategy.short)
if (possig == 0)
    strategy.close_all()
nColor = BarColors ? possig == -1 ? color.red : possig == 1 ? color.green : color.blue : na 
barcolor(nColor)
plot(nRes, title='SMA', color=#00ffaa, linewidth=2, style=plot.style_line)
````
