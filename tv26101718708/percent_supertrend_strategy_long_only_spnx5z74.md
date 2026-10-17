# Percent Supertrend Strategy (Long Only)

- url: https://www.tradingview.com/script/sPNx5Z74/
- type: strategy
- pine_id: PUB;1d5fca01d060477e8c78baa26cc36bc9
- version: 1.0

## Description

Diese Strategie ist eine trendfolgende Trading-Logik, die sich optisch und strukturell am klassischen Supertrend-Indikator orientiert. Der entscheidende Unterschied besteht darin, dass statt der Average True Range (ATR) ein prozentualer Abstand zum Preis verwendet wird, um die Trendgrenzen zu berechnen.

Die Strategie bildet eine dynamische obere und untere Bandstruktur basierend auf einem festen prozentualen Abstand zum Mittelpreis (HL2). Diese Bänder wirken als adaptive Support- und Resistance-Level. Sobald der Kurs diese Level durchbricht, erfolgt ein Trendwechsel (Flip), der die Richtung des Marktes definiert.

Es werden ausschließlich Long-Positionen gehandelt. Ein Einstieg erfolgt, wenn der Trend von bärisch auf bullisch wechselt. Positionen werden geschlossen, sobald ein gegenteiliger Flip (von bullisch auf bärisch) auftritt.

Durch den prozentualen Ansatz reagiert die Strategie nicht auf Volatilität im ATR-Sinn, sondern skaliert direkt mit dem Preisniveau. Dadurch eignet sie sich besonders für Märkte mit stabilen Trendbewegungen und klaren prozentualen Bewegungsstrukturen.

Die Visualisierung im Chart entspricht einer klassischen Supertrend-Darstellung, wodurch Trendphasen intuitiv erkennbar bleiben.

## Source Code

````pine
//@version=5
strategy("Percent Supertrend Strategy (Long Only)", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// ─────────────────────────────────────────────
// INPUT
// ─────────────────────────────────────────────
perc = input.float(20.0, "Prozent Abstand", step=0.1) / 100

// ─────────────────────────────────────────────
// BASISBERECHNUNG
// ─────────────────────────────────────────────
src = hl2

upperBasic = src * (1 + perc)
lowerBasic = src * (1 - perc)

// ─────────────────────────────────────────────
// TRAILING LOGIK (Supertrend-ähnlich)
// ─────────────────────────────────────────────
var float finalUpper = na
var float finalLower = na

finalUpper := na(finalUpper[1]) ? upperBasic :
     (close[1] > finalUpper[1] ? upperBasic : math.min(upperBasic, finalUpper[1]))

finalLower := na(finalLower[1]) ? lowerBasic :
     (close[1] < finalLower[1] ? lowerBasic : math.max(lowerBasic, finalLower[1]))

// ─────────────────────────────────────────────
// TREND LOGIK (FLIP)
// ─────────────────────────────────────────────
var int trend = 1

trend := nz(trend[1], 1)

if close > finalUpper[1]
    trend := 1
else if close < finalLower[1]
    trend := -1

// ─────────────────────────────────────────────
// SIGNALS
// ─────────────────────────────────────────────
longSignal  = trend == 1 and trend[1] == -1
exitSignal  = trend == -1 and trend[1] == 1

if longSignal
    strategy.entry("Long", strategy.long)

if exitSignal
    strategy.close("Long")

// ─────────────────────────────────────────────
// PLOT (Supertrend Lookalike)
// ─────────────────────────────────────────────
line = trend == 1 ? finalLower : finalUpper

plot(line, title="Percent Supertrend", linewidth=2, color=trend == 1 ? color.lime : color.red)

plotshape(longSignal, title="Long Entry", style=shape.triangleup, color=color.lime, location=location.belowbar, size=size.tiny)
plotshape(exitSignal, title="Exit", style=shape.triangledown, color=color.red, location=location.abovebar, size=size.tiny)
````
