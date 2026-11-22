# Options Decay Speed for 0DTE

- url: https://www.tradingview.com/script/eMkmzSAY-Options-Decay-Speed-for-0DTE/
- type: indicator
- pine_id: PUB;u3vn8dMgwfB5H8gMukQIJ1831XU8OjQJ
- version: 1.0

## Description

Use only for:
SPX, 5 minutes time frame
This indicator is complementing options 0DTE strategy - selling options for SPX index in the same day as they are expiring. Output of the indicator (red or green color of the curve) indicates whether is profitable to sell options at given moment at delta and VIX specified in the parameters. Changing parameter "Candles" is not recommended.

Main thought is that options expire with certain speed (theta decay) when stock doesnt move. When stock moves in unfavorable direction slowly enough, decay speed can compensate for disadvantage coming from option delta. Intuitively there must be certain speed of stock value change (expressed in stock value per 5 minutes) that is exactly compensating theta decay. This indicator calculates those two values (details below) and shows, where theta decay is faster than stock movement in the last hour and thus favorable to sell options. 
Indicator gets its result from comparing two values:
1) volatility in the form of highest high and lowest low for past 12 candles (one hour in total) divided by 12 - meaning average movement of stock expressed in [stock move per 5 minutes]
2) speed of options value decay in form of combination of theta decay and option delta. Formulas are approximation of Black-Scholes model as Pine script doesnt allow for advanced functions. Approximations are accurate to 2 decimal points from market open to one hour before market close and will not indicate green when accuracy is not sufficient. Its value is also expressed in [stock move per 5 minutes] so its mutualy comparable. 

My focus was not on code elegance but on practical usability. 
Written by Ondřej Škop.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OnSkop
study("DecaySpeed")
//@version=4
src = input(title="Candles", type=input.integer, defval=12)
IV = input(title="VIX", type=input.integer, defval=30)
delta = input(title="Delta", type=input.integer, defval=5)

x=(time-timestamp(year(time),month(time),dayofmonth(time),-6,0,0))/86400000
y = (1570.4*x*x*x - 3347.2*x*x + 2395.1*x - 566.61)*IV/30 //limit delta 5
//y = (1336.1*x*x*x - 2847.9*x*x + 2037.8*x - 482.08)*IV/30 //limit delta 10
//y = (1065.7*x*x*x - 2271.5*x*x + 1625.4*x - 384.52)*IV/30 //limit delta 20
//y = (882.37*x*x*x - 1880.7*x*x + 1345.7*x - 318.37)*IV/30 //limit delta 30

limit =y/7.50318569963115*(-0.000136*delta*delta*delta+0.0103*delta*delta-0.3464*delta+8.9658)
if (hour>14)
    limit := 1

highestHigh = highest(high, src)
lowestLow = lowest(low, src)
speed = (highestHigh - lowestLow)/src*12
barva=color.red
plot(speed, color=speed>limit ? color.red : color.green, linewidth=2)
//plot(limit, color=color.blue)
````
