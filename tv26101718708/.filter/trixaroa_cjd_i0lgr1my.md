# Trixaroa CJD

- url: https://www.tradingview.com/script/i0LGR1My-Trixaroa-CJD/
- type: indicator
- pine_id: PUB;a55416ddd52b4c2bac491dbf9e043a15
- version: 1.0

## Description

Trixaroa CJD is a powerful bullish strategy indicator based on the confluence of 7 indicators:

TRIX (bullish crossover)
Aroon (trend reversal)
MACD + RSI (momentum confirmation)
OBV (volume confirmation)
ADX + DI (trend strength)
Price > EMA 50 (underlying trend)

How it works : The script generates a Long signal only when all seven indicators align simultaneously, offering a high probability of a strong upward move.

Ideal for scalping and swing trading on stocks, cryptocurrencies, or indices in H4 and Daily timeframes.

Created: April 24, 2026 – Creator: Christophe J. D.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © vitruvex [Christophe D.]

//@version=5
indicator("TRIX + Aroon + OBV + ADX [Final Stable]", shorttitle="Trixaroa CJD", overlay=true)

// ==================== PARAMÈTRES ====================
trixLen    = input.int(15, "TRIX Length", minval=5)
sigLen     = input.int(9,  "TRIX Signal", minval=1)
aroonLen   = input.int(14, "Aroon Length", minval=7)
adxLen     = input.int(14, "ADX Length", minval=7)
adxThresh  = input.int(20, "ADX Minimum", minval=10)

// ==================== TRIX ====================
e1 = ta.ema(close, trixLen)
e2 = ta.ema(e1, trixLen)
e3 = ta.ema(e2, trixLen)
trix = 100 * (e3 - ta.ema(e3, trixLen)) / ta.ema(e3, trixLen)
trixSig = ta.ema(trix, sigLen)

// ==================== AROON MANUEL ====================
hh = ta.highest(high, aroonLen)
ll = ta.lowest(low, aroonLen)
aroonUp   = 100 * (aroonLen - ta.barssince(high == hh)) / aroonLen
aroonDown = 100 * (aroonLen - ta.barssince(low == ll)) / aroonLen

// ==================== INDICATEURS ====================
[macdLine, signalLine, hist] = ta.macd(close, 12, 26, 9)
rsiVal = ta.rsi(close, 14)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
obvVal = ta.obv
obvEma = ta.ema(obvVal, 20)
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)

// ==================== CONDITIONS ====================
trixBull  = ta.crossover(trix, trixSig)
aroonBull = ta.crossover(aroonUp, aroonDown)

macdBull  = ta.crossover(macdLine, signalLine) or hist > 0
rsiBull   = rsiVal > 50
priceBull = close > ema50
obvBull   = obvVal > obvEma and ta.rising(obvVal, 3)
adxBull   = adxVal > adxThresh and diPlus > diMinus

strongBull = trixBull and aroonBull and macdBull and rsiBull and priceBull and obvBull and adxBull

// ==================== AFFICHAGE ====================
plot(ema50,  color=color.orange, linewidth=2, title="EMA 50")
plot(ema200, color=color.red,    linewidth=2, title="EMA 200")

bgcolor(strongBull ? color.new(color.green, 80) : na)

plotshape(strongBull, title="STRONG BUY", location=location.belowbar, 
          color=color.lime, style=shape.triangleup, size=size.large, text="BUY", textcolor=color.black)

plotshape(trixBull and aroonBull, title="T+A", location=location.belowbar, 
          color=color.yellow, style=shape.labelup, size=size.small, text="T+A")

// Dashboard
var table dash = table.new(position.top_right, 1, 6, bgcolor=color.new(#1e222d, 85))
table.cell(dash, 0, 0, "TRIX + Aroon", text_color=color.white)
table.cell(dash, 0, 1, trixBull and aroonBull ? "✅" : "❌", text_color=trixBull and aroonBull ? color.lime : color.red)

table.cell(dash, 0, 2, "MACD + RSI", text_color=color.white)
table.cell(dash, 0, 3, (macdBull and rsiBull) ? "✅" : "❌", text_color=(macdBull and rsiBull) ? color.lime : color.red)

table.cell(dash, 0, 4, "OBV + ADX", text_color=color.white)
table.cell(dash, 0, 5, (obvBull and adxBull) ? "✅" : "❌", text_color=(obvBull and adxBull) ? color.lime : color.red)

// Alert
alertcondition(strongBull, "Strong Bullish Signal", "🔥 Signal TRIX + Aroon + Confirmations → HAUSSIER FORT !")
````
