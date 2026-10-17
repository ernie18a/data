# Bollinger and Stochastic with Trailing Stop - D.M.P.

- url: https://www.tradingview.com/script/g9wencOM-Bollinger-and-Stochastic-with-Trailing-Stop-D-M-P/
- type: strategy
- pine_id: PUB;eaf8c30ac5d4475c870b66dafb01991d
- version: 1.0

## Description

This trading strategy combines Bollinger Bands and the Stochastic indicator to identify entry opportunities in oversold and overbought conditions in the market. The aim is to capitalize on price rebounds from the extremes defined by the Bollinger Bands, with the confirmation of the Stochastic to maximize the probability of success of the operations.

[b]Indicators Used[/b]
- Bollinger Bands Used to measure volatility and define oversold and overbought levels. When the price touches or breaks through the lower band, it indicates a possible oversold condition. Similarly, when it touches or breaks through the upper band, it indicates a possible overbought condition.
- Stochastic: A momentum oscillator that compares the closing price of an asset with its price range over a certain period. Values below 20 indicate oversold, while values above 80 indicate overbought.

[b]Strategy Logic[/b]
- Long Entry (Buy): A purchase operation is executed when the price closes below the lower Bollinger band (indicating oversold) and the Stochastic is also in the oversold zone.
- Short Entry (Sell): A sell operation is executed when the price closes above the upper Bollinger band (indicating overbought) and the Stochastic is in the overbought zone.

## Source Code

````pine
//@version=5
strategy("Bollinger y Estocástico con Trailing Stop", overlay=true)

// Parámetros de entrada
lengthBB = input(20, title="Longitud BB")
stdDevBB = input(2, title="Desviación Estándar BB")
kLength = input(14, title="Longitud K Estocástico")
dLength = input(3, title="Longitud D Estocástico")
smooth = input(3, title="Suavizado Estocástico")
atrLength = input(14, title="Longitud ATR")
trailStopATRMultiple = input(1.5, title="Multiplicador ATR para Trailing Stop")

// Cálculos
[upperBB, basisBB, lowerBB] = ta.bb(close, lengthBB, stdDevBB)
stochK = ta.sma(ta.stoch(close, high, low, kLength), smooth)
atr = ta.atr(atrLength)

// Condiciones de trading
longCondition = close < lowerBB and stochK < 20
shortCondition = close > upperBB and stochK > 80

// Ejecutar operaciones
if (longCondition)
    strategy.entry("Long", strategy.long)
if (shortCondition)
    strategy.entry("Short", strategy.short)

// Trailing Stop
strategy.exit("Exit Long", from_entry="Long", trail_points=atr * trailStopATRMultiple, trail_offset=atr * trailStopATRMultiple)
strategy.exit("Exit Short", from_entry="Short", trail_points=atr * trailStopATRMultiple, trail_offset=atr * trailStopATRMultiple)
````
