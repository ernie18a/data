# Kase Dev Stops Strategy

- url: https://www.tradingview.com/script/KFeLQZMc-Kase-Dev-Stops-Strategy/
- type: indicator
- pine_id: PUB;rM4A0Iq6iL68uP2rOARuUkvM2igYGjCK
- version: 1.0

## Description

The Kase Dev Stops system finds the optimal statistical balance between letting profits run, 
  while cutting losses.  Kase DevStop seeks an ideal stop level by accounting for volatility (risk),
  the variance in volatility (the change in volatility from bar to bar), and volatility skew 
  (the propensity for volatility to occasionally spike incorrectly).

  Kase Dev Stops are set at points at which there is an increasing probability of reversal against 
  the trend being statistically significant based on the log normal shape of the range curve.  
  Setting stops will help you take as much risk as necessary to stay in a good position, but not more.

 WARNING:
 - For purpose educate only
 - This script to change bars colors.

## Source Code

````pine
//@version=4
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 08/10/2019
//  The Kase Dev Stops system finds the optimal statistical balance between letting profits run, 
//  while cutting losses.  Kase DevStop seeks an ideal stop level by accounting for volatility (risk),
//  the variance in volatility (the change in volatility from bar to bar), and volatility skew 
//  (the propensity for volatility to occasionally spike incorrectly).
//
//  Kase Dev Stops are set at points at which there is an increasing probability of reversal against 
//  the trend being statistically significant based on the log normal shape of the range curve.  
//  Setting stops will help you take as much risk as necessary to stay in a good position, but not more.
//
// WARNING:
// - For purpose educate only
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Kase Dev Stops Strategy", overlay = true)
Length = input(30, minval=2, maxval = 100)
Level = input(title="Trade From Level", defval=4, options=[1, 2, 3, 4])
RWH = (high - low[Length]) / (atr(Length) * sqrt(Length))
RWL = (high[Length] - low) / (atr(Length) * sqrt(Length))
Pk = wma((RWH-RWL),3)
AVTR = sma(highest(high,2) - lowest(low,2), 20)
SD = stdev(highest(high,2) - lowest(low,2),20)
Val4 = iff(Pk>0, highest(high-AVTR-3*SD,20), lowest(low+AVTR+3*SD,20))
Val3 = iff(Pk>0, highest(high-AVTR-2*SD,20), lowest(low+AVTR+2*SD,20))
Val2 = iff(Pk>0, highest(high-AVTR-SD,20), lowest(low+AVTR+SD,20))
Val1 = iff(Pk>0, highest(high-AVTR,20), lowest(low+AVTR,20))
ResPrice = iff(Level == 4, Val4,
             iff(Level == 3, Val3,
               iff(Level == 2, Val2,
                 iff(Level == 1, Val1, Val4))))
pos = iff(close < ResPrice , -1, 1)
barcolor(pos == -1 ? #b50404: pos == 1 ? #079605 : #0536b3 )
````
