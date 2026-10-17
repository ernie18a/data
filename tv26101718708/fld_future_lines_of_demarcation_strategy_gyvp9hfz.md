# FLD - Future Lines of Demarcation Strategy

- url: https://www.tradingview.com/script/GYVp9hFz-FLD-Future-Lines-of-Demarcation-Strategy/
- type: indicator
- pine_id: PUB;Pskak0SOtJFy42H0H0OSNkDjWMxK0QEK
- version: 1.0

## Description

An FLD is a line that is plotted on the same scale as the price and is in fact the 
  price itself displaced to the right (into the future) by (approximately) half the 
  wavelength of the cycle for which the FLD is plotted. There are three FLD's that can be 
  plotted for each cycle:
    An FLD based on the median price.
    An FLD based on the high price.
    An FLD based on the low price.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 13/02/2017
//  An FLD is a line that is plotted on the same scale as the price and is in fact the 
//  price itself displaced to the right (into the future) by (approximately) half the 
//  wavelength of the cycle for which the FLD is plotted. There are three FLD's that can be 
//  plotted for each cycle:
//    An FLD based on the median price.
//    An FLD based on the high price.
//    An FLD based on the low price.
///////////////////////////////////////////////////////////////////
study(title="FLD's - Future Lines of Demarcation", overlay=true)
Period = input(title="Period", defval=40)
src = input(title="Source", type=source, defval=hl2)
FLD = src
pos = iff(FLD[Period] < close , 1,
       iff(FLD[Period] > close, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue)
plot(FLD, title="FLD", style=line, linewidth=1, color=black, offset = Period)
````
