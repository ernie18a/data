# Parabolic SAR along with Heiken ashi Open strategy and EMA move

- url: https://www.tradingview.com/script/N7N7dvuc-Parabolic-SAR-along-with-Heiken-ashi-Open-strategy-and-EMA-move/
- type: strategy
- pine_id: PUB;g0lAvvANQWQePstwY6cSiWvRh7QHeFSr
- version: 1.0

## Description

Parabolic SAR along with Heiken ashi Open strategy and EMA move

## Source Code

````pine
//@version=4
strategy(title="Parabolic SAR", shorttitle="SAR", overlay=true)
start = input(0.05)
increment = input(0.03)
maximum = input(1, "Max Value")
out = sar(start, increment, maximum)
plot(out, "ParabolicSAR", style=plot.style_cross, color=#3A6CA8)
haTicker = heikinashi(syminfo.tickerid)
haOpen = security(haTicker, timeframe.period, open)
haClose = security(haTicker, timeframe.period, close)
haLow = security(haTicker, timeframe.period, low)
haHigh = security(haTicker, timeframe.period, high)

//Entries

if close > out and close > sma(close,50) and haOpen == haLow
    strategy.entry("Long",  long=strategy.long)
    
if close < out and close < sma(close,50) and haOpen == haHigh
    strategy.entry("Short",  long=strategy.short)

// // Exits
strategy.close(id="Long",when = close < out)

strategy.close(id="Short",when = close > out)
````
