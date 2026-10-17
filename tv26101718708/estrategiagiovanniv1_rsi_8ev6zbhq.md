# Estrategia_Giovanni_V1 RSI

- url: https://www.tradingview.com/script/8Ev6zBHq-Estrategia-Giovanni-V1-RSI/
- type: indicator
- pine_id: PUB;534ca217341249a194203ff6186a3e2a
- version: 1.0

## Description

ENGLISH DESCRIPTION (Required):
This indicator is a "Triple Bullish Divergence" scanner designed for the Crypto Screener. It identifies market exhaustion by detecting 3 consecutive RSI lows below the 30 level.

Confirmation: It requires a price action breakout (close above the previous candle's high) after the third RSI touch.

Output: It returns a binary value (1 for signal, 0 for no signal), making it compatible with custom columns in the TradingView Screener 2.0.

## Source Code

````pine
//@version=5
indicator("Filtro_Giovanni_Div", shorttitle="FGD", overlay=false)

rsiVal = ta.rsi(close, 7)
esMinimo = ta.pivotlow(rsiVal, 3, 1)

var int contador = 0
var int ultima = 0

if (not na(esMinimo) and rsiVal[1] < 30)
    if (bar_index - ultima > 5)
        contador += 1
        ultima := bar_index

if (rsiVal > 60)
    contador := 0

confirmacion = close > high[1] and close > open and contador >= 3

// Esta línea es la que buscará el Screener
plot(confirmacion ? 1 : 0, title="Señal_Divergencia")
````
