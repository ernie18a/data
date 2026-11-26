# Simple SMA Indicator from Stream

- url: https://www.tradingview.com/script/xmvJbCrm-Simple-SMA-Indicator-from-Stream/
- type: indicator
- pine_id: PUB;5hC7D08xCasDRlucrR3Opn4dpfOabe2Q
- version: 1.0

## Description

Added strategy logic.

Part 2:
https://www.tradingview.com/streams/JklgcKQGdQXV1RLMt2Y9r

Part 1:
https://www.tradingview.com/script/djP5c8XZ-Simple-SMA-Indicator/

https://www.tradingview.com/streams/FYGStZButruT1_WkgMzyN/

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
//@version=4
study(title="Simple SMA Indicator", shorttitle="S SMA I", precision=6, overlay=true)
Resolution = input(title="Resolution", type=input.resolution, defval="D")
Source = input(title="Source", type=input.source, defval=close)
xSeries = security(syminfo.tickerid, Resolution, Source)
Length = input(title="Length", type=input.integer, defval=14, minval=2)
TriggerPrice = input(title="Trigger Price", type=input.source, defval=close)
BarColors = input(title="Painting bars", type=input.bool, defval=true)
ShowLine = input(title="Show Line", type=input.bool, defval=true)
pos = 0
xSMA = sma(xSeries, Length)
pos := iff(TriggerPrice > xSMA, 1,
         iff(TriggerPrice < xSMA, -1, nz(pos[1], 0)))
nRes = ShowLine ? xSMA : na
nColor = BarColors ? pos == -1 ? color.red : pos == 1 ? color.green : color.blue : na 
alertcondition(pos != pos[1] and pos == 1, title='Signal Buy', message='Strategy to change to BUY')
alertcondition(pos != pos[1] and pos == -1, title='Signal Sell', message='Strategy to change to SELL')
alertcondition(pos != pos[1] and pos == 0, title='FLAT', message='Strategy get out from position')
barcolor(nColor)
plot(nRes, title='SMA', color=#00ffaa, linewidth=2, style=plot.style_line)
````
