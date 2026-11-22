# Comparative Relative Strength

- url: https://www.tradingview.com/script/NKeUrncg-Comparative-Relative-Strength/
- type: indicator
- pine_id: PUB;f9b5542d05a546ad809b8b3e394a9289
- version: 2.0

## Description

This is Relative Strength Comparative indicator which is widely used by many people for RS based strategies. It help to identify the strength of trend and can help to make perfect entries and exits based on this oscillator

## Source Code

````pine
//@version=6
indicator("Comparative Relative Strength", shorttitle="CRS")
a = syminfo.tickerid
b = input.symbol("NIFTY", title="INDEX")
cs = request.security(a, timeframe.period, close) 
bs = request.security(b, timeframe.period, close)
plot(cs/bs*1000, title="RS", color=color.gray) 
len = input(50) 
plot(ta.sma(cs/bs*1000, len), color=color.navy)
````
