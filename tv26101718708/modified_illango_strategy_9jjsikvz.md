# Modified Illango Strategy

- url: https://www.tradingview.com/script/9jjsikVz/
- type: indicator
- pine_id: PUB;jp79T7IzcSGudMjnckIEqCqRGrNvW6p8
- version: 3.0

## Description

Modified Illango Strategy

## Source Code

````pine
//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ceyhun

study("Modified Illango Strategy", overlay=false)

len = input(35, title="Length")
Avghk = input(3,"Avg Hk")
Emahk = input(9,"Ema Hk")

High35 = highest(high, len)
Low35 = lowest(low, len)
perHK = (close - Low35) / (High35 - Low35) * 100
AvgHK = sma(perHK, Avghk)
EMAHK = sma(ema(AvgHK, Emahk), Emahk)
diff = AvgHK - EMAHK

plot(EMAHK, "EMAHK", color=#FF0000)
plot(AvgHK, "AvgHK", color=	#0000FF)

Buy = cross(AvgHK, EMAHK) and diff > 1 and AvgHK > 5 and AvgHK < 45 and EMAHK > 5 and 
   EMAHK < 45
Sell = cross(EMAHK, AvgHK) and diff < -1 and AvgHK > 55 and AvgHK < 95 and EMAHK > 55 and 
   EMAHK < 95
plotshape(Buy, color=#0000FF, location=location.bottom, style=shape.triangleup, text="Buy",size=size.tiny)
plotshape(Sell, color=#FF0000, location=location.top,style=shape.triangledown, text="Sell",size=size.tiny)

a = Buy
b_color = Buy ? #0000FF : na
barcolor(a ? b_color : na)
bgcolor(a ? b_color : na)

b = Sell
b_color2 = Sell ? #FF0000 : na
barcolor(b ? b_color2 : na)

bgcolor(b ? b_color2 : na)

alertcondition(Buy, title="Buy Signal", message="Buy")
alertcondition(Sell, title="Sell Signal", message="Sell")

Bsl = valuewhen(Buy, lowest(low, 3), 1)
Ssl = valuewhen(Sell, highest(high, 3), 1)

plot(Bsl, "Bstop loss", color=#008000)
plot(Ssl, "Sstop loss", color=#FF0000)

alertcondition(Bsl, title="Buy Stop Loss Signal", message="Buy Stoploss")
alertcondition(Ssl, title="Sell Stop Loss Signal", message="Sell Stoploss")
````
