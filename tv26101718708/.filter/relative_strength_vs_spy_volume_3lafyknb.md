# Relative Strength vs SPY + Volume

- url: https://www.tradingview.com/script/3laFyknB/
- type: indicator
- pine_id: PUB;34fe95bd8bfb46628618209148d8f172
- version: 1.0

## Description

A clean lower-panel indicator that combines relative strength versus SPY with volume analysis. The blue line shows whether the current symbol is outperforming or underperforming SPY over the selected lookback period. Volume is displayed as bullish/bearish columns with a thin average volume line.

## Source Code

````pine
//@version=6
indicator("Relative Strength vs SPY + Volume Style", shorttitle="RS vs SPY Vol", overlay=false)

// === Inputs ===
benchmark   = input.symbol("AMEX:SPY", "Benchmark")
volLen      = input.int(20, "Volumen-Durchschnitt", minval=1)
rsLookback  = input.int(50, "RS-Lookback", minval=5)
scaleLookbk = input.int(100, "Skalierung Lookback", minval=20)

// === Daten ===
benchClose = request.security(benchmark, timeframe.period, close)

// Relative Strength als Verhältnis Aktie / SPY
rsRaw = close / benchClose

// Lesbare RS-Metrik: Performance des Ratios über Lookback
rsPerf = (rsRaw / rsRaw[rsLookback] - 1.0) * 100.0

// Volumen
volMA = ta.sma(volume, volLen)

// Balkenfarbe
volColor = close >= open ? color.lime : color.red

// === RS für gemeinsame Darstellung mit Volumen optisch skalieren ===
volMax = ta.highest(volume, scaleLookbk)
rsMin  = ta.lowest(rsPerf, scaleLookbk)
rsMax  = ta.highest(rsPerf, scaleLookbk)

// RS auf den Volumenbereich umlegen
rsScaled = rsMax != rsMin ? ((rsPerf - rsMin) / (rsMax - rsMin)) * (volMax * 0.80) + (volMax * 0.10) : volMax * 0.50

// === Hintergrund weiß ===
bgcolor(color.white)

// === Plots im Pane, aber ohne zusätzliche Werte links oben ===
plot(volume, title="Volume", style=plot.style_columns, color=volColor, display=display.pane)
plot(volMA, title="20day Average", color=color.gray, linewidth=1, display=display.pane)
plot(rsScaled, title="Relative Strength vs SP-500", color=color.blue, linewidth=3, display=display.pane)

// === Nur dieser Wert erscheint links oben in der Statuszeile ===
plot(rsPerf, title="RS vs SPY %", color=color.blue, display=display.status_line)
````
