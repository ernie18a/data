# Positive Volume Index Strategy

- url: https://www.tradingview.com/script/RWSUmSK6-Positive-Volume-Index-Strategy/
- type: indicator
- pine_id: PUB;uqXr6SkyCmo755jNbt1dWB1Ntzcdo73e
- version: 1.0

## Description

The theory behind the indexes is as follows: On days of increasing volume, 
 you can expect prices to increase, and on days of decreasing volume, you can 
 expect prices to decrease. This goes with the idea of the market being in-gear 
 and out-of-gear. Both PVI and NVI work in similar fashions: Both are a running 
 cumulative of values, which means you either keep adding or subtracting price 
 rate of change each day to the previous day`s sum. In the case of PVI, if today`s 
 volume is less than yesterday`s, don`t add anything; if today`s volume is greater, 
 then add today`s price rate of change. For NVI, add today`s price rate of change 
 only if today`s volume is less than yesterday`s.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 09/10/2017
// The theory behind the indexes is as follows: On days of increasing volume, 
// you can expect prices to increase, and on days of decreasing volume, you can 
// expect prices to decrease. This goes with the idea of the market being in-gear 
// and out-of-gear. Both PVI and NVI work in similar fashions: Both are a running 
// cumulative of values, which means you either keep adding or subtracting price 
// rate of change each day to the previous day`s sum. In the case of PVI, if today`s 
// volume is less than yesterday`s, don`t add anything; if today`s volume is greater, 
// then add today`s price rate of change. For NVI, add today`s price rate of change 
// only if today`s volume is less than yesterday`s.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Positive Volume Index", shorttitle="Positive Volume Index")
EMA_Len = input(255, minval=1)
xROC = roc(close, 1)
nRes = iff(volume > volume[1], nz(nRes[1], 0) + xROC, nz(nRes[1], 0))
nResEMA = ema(nRes, EMA_Len)
pos = iff(nRes > nResEMA, 1,
	   iff(nRes < nResEMA, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(nRes, color=red, title="PVI")
plot(nResEMA, color=blue, title="EMA")
````
