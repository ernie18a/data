# Chande Forecast Oscillator

- url: https://www.tradingview.com/script/SGUK2MxG-Chande-Forecast-Oscillator/
- type: strategy
- pine_id: PUB;8IKllyJo6FdN3EIr6M1SHnZGhijRTSDA
- version: 1.0

## Description

The Chande Forecast Oscillator developed by Tushar Chande The Forecast 
 Oscillator plots the percentage difference between the closing price and 
 the n-period linear regression forecasted price. The oscillator is above 
 zero when the forecast price is greater than the closing price and less 
 than zero if it is below.

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
////////////////////////////////////////////////////////////
strategy(title="Chande Forecast Oscillator", shorttitle="CFO")
Length = input(14, minval=1)
Offset = input(0)
hline(0, color=black, linestyle=line)
xLG = linreg(close, Length, Offset)
xCFO = ((close -xLG) * 100) / close
plot(xCFO, color=red, title="CFO")
````
