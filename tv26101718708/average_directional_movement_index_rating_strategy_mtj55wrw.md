# Average Directional Movement Index Rating Strategy

- url: https://www.tradingview.com/script/MTj55wRW-Average-Directional-Movement-Index-Rating-Strategy/
- type: indicator
- pine_id: PUB;IBqIum0MnyBChQpEoZ9yQfjq82ElP69S
- version: 1.0

## Description

The Average Directional Movement Index Rating (ADXR) measures the strength 
 of the Average Directional Movement Index (ADX). It's calculated by taking 
 the average of the current ADX and the ADX from one time period before 
 (time periods can vary, but the most typical period used is 14 days).
 Like the ADX, the ADXR ranges from values of 0 to 100 and reflects strengthening 
 and weakening trends. However, because it represents an average of ADX, values 
 don't fluctuate as dramatically and some analysts believe the indicator helps 
 better display trends in volatile markets.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 03/05/2018
// The Average Directional Movement Index Rating (ADXR) measures the strength 
// of the Average Directional Movement Index (ADX). It's calculated by taking 
// the average of the current ADX and the ADX from one time period before 
// (time periods can vary, but the most typical period used is 14 days).
// Like the ADX, the ADXR ranges from values of 0 to 100 and reflects strengthening 
// and weakening trends. However, because it represents an average of ADX, values 
// don't fluctuate as dramatically and some analysts believe the indicator helps 
// better display trends in volatile markets.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
fADX(Len) =>
    up = change(high)
    down = -change(low)
    trur = rma(tr, Len)
    plus = fixnan(100 * rma(up > down and up > 0 ? up : 0, Len) / trur)
    minus = fixnan(100 * rma(down > up and down > 0 ? down : 0, Len) / trur)
    sum = plus + minus 
    100 * rma(abs(plus - minus) / (sum == 0 ? 1 : sum), Len)

study(title="Average Directional Movement Index Rating Strategy", shorttitle="ADXR")
LengthADX = input(title="Length ADX", defval=14)
LengthADXR = input(title="Length ADXR", defval=14)
Signal1 = input(13, step=0.01)
Signal2 = input(45, step=0.01)
hline(Signal1, color=green, linestyle=line)
hline(Signal2, color=red, linestyle=line)
xADX = fADX(LengthADX)
xADXR = (xADX + xADX[LengthADXR]) / 2
pos = iff(xADXR < Signal1, 1,
       iff(xADXR > Signal2, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xADXR, color=green, title="ADXR")
````
