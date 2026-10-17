# Franklin barcolor ATR

- url: https://www.tradingview.com/script/MxaQKx1v-franklin-barcolor-atr/
- type: indicator
- pine_id: PUB;3180
- version: -1.0

## Description

Indicator for http://trader.tfc3.ru/ strategy traders.

## Source Code

````pine
//
// @author hell0men [robotfarm.ru] 
// 
study("Franklin barcolor ATR", overlay=true)
i = input(title="Размер между хаем и (1=close, 2=high/low)", type=integer, defval=1)
a = input(title="Кол-во ATR для размера", type=integer, defval=1)
o = input(title="Макс. отступ в ATR от EMA", type=integer, defval=3)
ema65=ema(close,65)
atrover= high-atr(15)*a
atrunder= low+atr(15)*a
isover() => (i==2?low:close) < atrover and close<open and close>ema65 and close-ema65<atr(15)*o
isunder() => (i==2?high:close) > atrunder and close>open and close<ema65 and ema65-close<atr(15)*o
barcolor(isover() ? orange: na)
barcolor(isunder() ? purple: na)
````
