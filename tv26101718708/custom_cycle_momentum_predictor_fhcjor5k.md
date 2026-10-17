# Custom Cycle & Momentum Predictor 

- url: https://www.tradingview.com/script/FHcjor5K/
- type: indicator
- pine_id: PUB;ff738cca42c24e38851492e28b895c13
- version: 1.0

## Description

Weil RSI, MACD und Zyklen völlig unterschiedliche mathematische Werte haben (RSI geht von 0-100, MACD hat offene Enden), habe ich sie im Skript normalisiert. Sie bewegen sich jetzt alle auf einer Skala von -50 bis +50:

Der Zyklus-Fortschritt: Wird im Skript über eine geglättete Stochastik simuliert. Sie zeigt dir, wo im aktuellen "Kurs-Ausschlag" (der Welle) wir uns befinden.

Der RSI: Gibt an, ob die aktuelle Welle überhitzt ist.

Der MACD: Zeigt, ob die Welle überhaupt noch Schwung (Momentum) hat.

Das Ergebnis:
Der Indikator wird in einem eigenen Fenster unter dem Chart angezeigt.

Grüne Zone (unten, unter -30): Der Zyklus ist im Keller, der RSI ist niedrig und der MACD dreht nach oben. Ein guter Zeitpunkt, nach Kauf-Signalen Ausschau zu halten.

Rote Zone (oben, über +30): Der Zyklus ist am Peak, die Luft wird dünn. Zeit, über Gewinnmitnahmen nachzudenken.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pyronix25
//@version=6
indicator("Custom Cycle & Momentum Predictor V6", overlay=false, precision=2)

// --- INPUTS ---
// RSI Einstellungen
rsiLength = input.int(14, title="RSI Länge", group="RSI")

// MACD Einstellungen
macdFast   = input.int(12, title="MACD Fast Length", group="MACD")
macdSlow   = input.int(26, title="MACD Slow Length", group="MACD")
macdSignal = input.int(9, title="MACD Signal Length", group="MACD")

// Zyklus Einstellungen (Simuliert durch Stochastik für die Wellenbewegung)
cycleLength = input.int(20, title="Zyklus Länge (Perioden)", group="Zyklus")
cycleSmooth = input.int(3, title="Zyklus Glättung", group="Zyklus")

// --- BERECHNUNGEN ---

// 1. RSI (normalisiert auf eine Skala von -50 bis +50)
rsiValue = ta.rsi(close, rsiLength)
rsiNormalized = rsiValue - 50.0

// 2. MACD (normalisiert über die Veränderung)
[macdLine, signalLine, _] = ta.macd(close, macdFast, macdSlow, macdSignal)
macdHist = macdLine - signalLine
// Normalisierung des MACD (wir nutzen die Standardabweichung, um es oszillieren zu lassen)
macdNormalized = ta.ema(macdHist, 5) / ta.stdev(macdHist, 50) * 25.0

// 3. Zyklus-Fortschritt (Stochastik repräsentiert die Wellen-Phase von -50 bis +50)
cycleRaw = ta.stoch(close, high, low, cycleLength)
cycleSmoothed = ta.sma(cycleRaw, cycleSmooth)
cycleNormalized = cycleSmoothed - 50.0

// --- KOMBINIERTER ZYKLUS SCORE ---
// Hier fließen alle drei Komponenten gleichmäßig (je 1/3 Gewichtung) ein
combinedScore = (rsiNormalized + macdNormalized + cycleNormalized) / 3.0

// --- PLOTS ---
// Nulllinie (Gleichgewicht)
hline(0, "Nulllinie", color=color.gray, linestyle=hline.style_dashed)
hline(30, "Überkauft Grenze", color=color.red, linestyle=hline.style_dotted)
hline(-30, "Überverkauft Grenze", color=color.green, linestyle=hline.style_dotted)

// Farbwechsel basierend auf dem Score
color baseColor = combinedScore > 0 ? (combinedScore > 30 ? color.red : color.green) : (combinedScore < -30 ? color.green : color.red)
// In V6 wird die Transparenz für Flächen-Plots (style.style_area) direkt über color.new() geregelt
color areaColor = color.new(baseColor, 50)

plot(combinedScore, title="Zyklus & Momentum Score", color=areaColor, style=plot.style_area)
plot(combinedScore, title="Score Linie", color=color.white, linewidth=2)

// --- SIGNALE (Hintergrundfarbe bei Extrempunkten) ---
color bgTrend = combinedScore > 30 ? color.new(color.red, 90) : (combinedScore < -30 ? color.new(color.green, 90) : na)
bgcolor(bgTrend)
````
