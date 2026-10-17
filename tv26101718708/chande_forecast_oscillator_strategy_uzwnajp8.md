# Chande Forecast Oscillator Strategy

- url: https://www.tradingview.com/script/UzWNaJp8-Chande-Forecast-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;414YqzJdZod75jFj3Teo6voukykNr9aa
- version: 1.0

## Description

The Chande Forecast Oscillator developed by Tushar Chande The Forecast 
 Oscillator plots the percentage difference between the closing price and 
 the n-period linear regression forecasted price. The oscillator is above 
 zero when the forecast price is greater than the closing price and less 
 than zero if it is below.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 11/03/2018
// The Chande Forecast Oscillator developed by Tushar Chande The Forecast 
// Oscillator plots the percentage difference between the closing price and 
// the n-period linear regression forecasted price. The oscillator is above 
// zero when the forecast price is greater than the closing price and less 
// than zero if it is below.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
study(title="Chande Forecast Oscillator Strategy", shorttitle="CFO")
Length = input(14, minval=1)
Offset = input(0)
hline(0, color=black, linestyle=line)
xLG = linreg(close, Length, Offset)
xCFO = ((close -xLG) * 100) / close
pos = iff(xCFO > 0, 1,
       iff(xCFO < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xCFO, color=red, title="CFO")
````
