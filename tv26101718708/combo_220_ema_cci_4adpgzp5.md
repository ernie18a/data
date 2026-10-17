# Combo 2/20 EMA & CCI

- url: https://www.tradingview.com/script/4ADPgzp5-Combo-2-20-EMA-CCI/
- type: strategy
- pine_id: PUB;841a17cdf58f439cb4e1c0ff70081960
- version: 1.0

## Description

This is another part of my research work, where I test a combination of two strategies, receiving a combined signal. In order to understand which indicator combinations work better, which work worse, as filters for trades. This is combo strategies for get a cumulative signal.  

 First strategy
 This indicator plots 2/20 exponential moving average. For the Mov  Avg X 2/20 Indicator, the EMA bar will be painted when the Alert criteria is met.

 Second strategy
The Commodity Channel Index (CCI) is best used with markets that display cyclical or seasonal characteristics, and is formulated to detect the beginning and ending of the cycles by incorporating a moving average together with a divisor that reflects both  possible and actual trading ranges. The final index measures the deviation from normal, which indicates  major changes in market trend.

Strategy tester settings:
Initial capital: 1000
Order size: 0.5
Commission: 0.1%
Other as default.

Indicator settings:
EMA Length: 50
CCI Length: 10
Fast MA Length: 15
Slow MA Length: 20
Other as default.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=5
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 03/09/2024
// This is combo strategies for get a cumulative signal.  
//
// First strategy
// This indicator plots 2/20 exponential moving average. For the Mov 
// Avg X 2/20 Indicator, the EMA bar will be painted when the Alert criteria is met.
//
// Second strategy
// The Commodity Channel Index (CCI) is best used with markets that display cyclical or 
// seasonal characteristics, and is formulated to detect the beginning and ending of these 
// cycles by incorporating a moving average together with a divisor that reflects both possible 
// and actual trading ranges. The final index measures the deviation from normal, which indicates 
// major changes in market trend.
//
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
EMA20(Length) =>
    pos = 0.0
    xPrice = close
    xXA = ta.ema(xPrice, Length)
    nHH = math.max(high, high[1])
    nLL = math.min(low, low[1])
    nXS = nLL > xXA or nHH < xXA ? nLL : nHH
    iff_1 = nXS < close[1] ? 1 : nz(pos[1], 0)
    pos := nXS > close[1] ? -1 : iff_1
    pos

CCI(CCILen, FastMA, SlowMA) =>
    pos=0
    xCCI=ta.cci(close,CCILen)
    xSMA=ta.sma(xCCI, SlowMA)
    xFMA=ta.sma(xCCI, FastMA)
    pos:= xSMA<xFMA ? 1 : xSMA > xFMA ? -1 : nz(pos[1],0)
    pos

strategy(title='Combo 2/20 EMA & CCI', shorttitle='Combo', overlay=true)
var I1 = '●═════ 2/20 EMA ═════●'
Length = input.int(14, title='Length', minval=1, group=I1)
var I2 = '●═════  CCI ═════●'
CCILen=input.int(10,title='CCI Length',minval=1)
FastMA=input.int(10,title='Fast MA Length',minval=1)
SlowMA=input.int(20,title='Slow MA Length',minval=1)
var misc = '●═════ MISC ═════●'
reverse = input.bool(false, title='Trade reverse', group=misc)
var timePeriodHeader = '●═════ Time Start ═════●'
d = input.int(1, title='From Day', minval=1, maxval=31, group=timePeriodHeader)
m = input.int(1, title='From Month', minval=1, maxval=12, group=timePeriodHeader)
y = input.int(2020, title='From Year', minval=0, group=timePeriodHeader)
StartTrade = time > timestamp(y, m, d, 00, 00) ? true : false

posEMA20 = EMA20(Length)
posCCI = CCI(CCILen, FastMA, SlowMA)

iff_1 = posEMA20 == -1 and posCCI == -1 and StartTrade ? -1 : 0
pos = posEMA20 == 1 and posCCI == 1 and StartTrade ? 1 : iff_1 
iff_2 = reverse and pos == -1 ? 1 : pos
possig = reverse and pos == 1 ? -1 : iff_2
if possig == 1
    strategy.entry('Long', strategy.long)
if possig == -1
    strategy.entry('Short', strategy.short)
if possig == 0
    strategy.close_all(comment = 'Exit')
barcolor(possig == -1 ? #b50404 : possig == 1 ? #079605 : #0536b3)
````
