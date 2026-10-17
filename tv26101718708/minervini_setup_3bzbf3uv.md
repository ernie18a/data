# Minervini Setup

- url: https://www.tradingview.com/script/3BZBF3uv/
- type: indicator
- pine_id: PUB;749e75d2a9ec410faf8179589f0882ca
- version: 1.0

## Description

// TREND-FILTER
Preis  über  SMA 50              Pflicht
Preis  über  SMA 150             Pflicht
Preis  über  SMA 200             Pflicht
SMA 50 über  SMA 150             Pflicht
SMA 50 über  SMA 200             Pflicht

// RELATIVE STÄRKE / PERFORMANCE
Perf. 1J  größer  +25%           Pflicht
Perf. 3M  größer  +5%            Pflicht
52W-High  Abstand max  -25%       Pflicht

// VOLUMEN & LIQUIDITÄT
Ø-Volumen 20T  größer  200.000    empfohlen
Marktkapitalisierung  >  300 Mio   empfohlen

// MOMENTUM ZUSATZ
RSI 14  zwischen  50 und 80       optional
Volumen  über  Ø-Volumen 20T       optional

## Source Code

````pine
//@version=5
indicator("Minervini Setup", overlay=true)

sma50  = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)
low52  = ta.lowest(close, 252)
high52 = ta.highest(close, 252)

c1 = close > sma150 and close > sma200
c2 = sma150 > sma200
c3 = sma200 > sma200[21]
c4 = sma50 > sma150 and sma50 > sma200
c5 = close > sma50
c6 = close >= low52 * 1.25
c7 = close >= high52 * 0.75

signal = c1 and c2 and c3 and c4 and c5 and c6 and c7

plotshape(signal, "Setup OK", shape.labelup, 
         location=location.belowbar, 
         color=color.green, size=size.small)
````
