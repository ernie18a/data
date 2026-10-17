# 3 EMA Trading-Style EG1893

- url: https://www.tradingview.com/script/7JlgGFBQ/
- type: indicator
- pine_id: PUB;f2752f28ae3444f9980f6613ee30a10d
- version: 1.0

## Description

3 EMA Trading-Style EG1893

Der **3 EMA Trading-Style EG1893" in der Version 2a ist ein flexibler Multi-EMA-Indikator für TradingView, entwickelt für Scalping, Daytrading, Swing Trading und langfristige Trendanalyse.

Der Indikator kombiniert drei exponentielle gleitende Durchschnitte (EMAs) mit vorkonfigurierten Tradingstil-Presets und einem übersichtlichen EMA-Dashboard direkt im Chart.

## Features
* 3 dynamische EMAs
* Tradingstil-Presets:
  * Scalping
  * Daytrading
  * Swing Trading
  * Positionstrading
  * Custom
* Individuelle Farben & Linienstärken
* EMA-Crossover Signale
* Bullischer/Bärischer Trendfilter
* Optionaler Trend-Hintergrund
* Live EMA Dashboard im Chart
* Alarmfunktionen für Buy/Sell Signale

## Presets
| Stil             | EMA Werte      |
| ---------------- | -------------- |
| Scalping         | 5 / 9 / 20     |
| Daytrading       | 9 / 21 / 50    |
| Swing Trading    | 20 / 50 / 200  |
| Positionstrading | 50 / 100 / 200 |

## Anwendung
Der Indikator eignet sich ideal für:
* Trendfolge
* Pullback-Trading
* Momentum-Setups
* EMA Cross Strategien
* Marktstruktur-Analyse

Besonders hilfreich ist die Kombination aus schnellen und langsamen EMAs zur Erkennung von Trendwechseln und Marktphasen.

## Signale
* EMA 1 kreuzt EMA 2 nach oben → mögliches Kaufsignal
* EMA 1 kreuzt EMA 2 nach unten → mögliches Verkaufssignal
* EMA Struktur zeigt aktuelle Trendrichtung

## Hinweis

Wie alle technischen Indikatoren sollte auch dieser nicht isoliert verwendet werden. Für bessere Ergebnisse empfiehlt sich die Kombination mit:
* Price Action
* Volumen
* Support & Resistance
* Risikomanagement

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © endgame_1893

//@version=6
indicator("3 EMA Trading-Style EG1893_V2a", overlay=true)

// ───── Tradingstil ─────
style = input.string(
     "Daytrading",
     "Tradingstil",
     options = ["Scalping", "Daytrading", "Swing Trading", "Positionstrading", "Custom"]
)

// ───── Custom EMA Werte ─────
customEma1 = input.int(9, "Custom EMA 1 (schnell)", minval=1)
customEma2 = input.int(21, "Custom EMA 2 (mittel)", minval=1)
customEma3 = input.int(50, "Custom EMA 3 (langsam)", minval=1)

// ───── Aktive EMA Werte ─────
ema1Length = switch style
    "Scalping"         => 5
    "Daytrading"       => 9
    "Swing Trading"    => 20
    "Positionstrading" => 50
    => customEma1

ema2Length = switch style
    "Scalping"         => 9
    "Daytrading"       => 21
    "Swing Trading"    => 50
    "Positionstrading" => 100
    => customEma2

ema3Length = switch style
    "Scalping"         => 20
    "Daytrading"       => 50
    "Swing Trading"    => 200
    "Positionstrading" => 200
    => customEma3

// ───── Quelle ─────
src = input.source(close, "Quelle")

// ───── Farben & Dicke ─────
colorEma1 = input.color(color.lime, "Farbe EMA 1 (schnell)")
colorEma2 = input.color(color.orange, "Farbe EMA 2 (mittel)")
colorEma3 = input.color(color.red, "Farbe EMA 3 (langsam)")

widthEma1 = input.int(2, "Dicke EMA 1", minval=1, maxval=5)
widthEma2 = input.int(2, "Dicke EMA 2", minval=1, maxval=5)
widthEma3 = input.int(3, "Dicke EMA 3", minval=1, maxval=5)

// ───── Optionen ─────
showSignals = input.bool(true, "Cross-Signale anzeigen")
showTrendBg = input.bool(false, "Trend-Hintergrund anzeigen")
showPanel = input.bool(true, "Aktive EMA Werte anzeigen (Panel)")

// ───── Berechnung ─────
ema1 = ta.ema(src, ema1Length)
ema2 = ta.ema(src, ema2Length)
ema3 = ta.ema(src, ema3Length)

// ───── Plots ─────
plot(ema1, "EMA 1 (schnell)", color=colorEma1, linewidth=widthEma1)
plot(ema2, "EMA 2 (mittel)", color=colorEma2, linewidth=widthEma2)
plot(ema3, "EMA 3 (langsam)", color=colorEma3, linewidth=widthEma3)

// ───── Trendlogik ─────
bullTrend = ema1 > ema2 and ema2 > ema3
bearTrend = ema1 < ema2 and ema2 < ema3

bgcolor(showTrendBg and bullTrend ? color.new(color.green, 88) : na)
bgcolor(showTrendBg and bearTrend ? color.new(color.red, 88) : na)

// ───── Signale ─────
buySignal  = ta.crossover(ema1, ema2)
sellSignal = ta.crossunder(ema1, ema2)

plotshape(showSignals and buySignal, title="Kaufsignal", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY")
plotshape(showSignals and sellSignal, title="Verkaufssignal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL")

// ───── Panel mit aktiven EMA Werten ─────
var table panel = table.new(position.top_right, 3, 7, border_width=1)

if barstate.islast and showPanel
    table.cell(panel, 0, 0, "AKTIVE EMA WERTE", text_color=color.lime, bgcolor=color.new(color.black, 0), text_size=size.large)
    table.cell(panel, 1, 0, "", bgcolor=color.new(color.black, 0))
    table.cell(panel, 2, 0, "", bgcolor=color.new(color.black, 0))

    table.cell(panel, 0, 1, "━", text_color=colorEma1, bgcolor=color.new(color.black, 0), text_size=size.large)
    table.cell(panel, 1, 1, "EMA 1 (schnell)", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(panel, 2, 1, str.tostring(ema1Length), text_color=colorEma1, bgcolor=color.new(color.black, 0), text_size=size.large)

    table.cell(panel, 0, 2, "━", text_color=colorEma2, bgcolor=color.new(color.black, 0), text_size=size.large)
    table.cell(panel, 1, 2, "EMA 2 (mittel)", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(panel, 2, 2, str.tostring(ema2Length), text_color=colorEma2, bgcolor=color.new(color.black, 0), text_size=size.large)

    table.cell(panel, 0, 3, "━", text_color=colorEma3, bgcolor=color.new(color.black, 0), text_size=size.large)
    table.cell(panel, 1, 3, "EMA 3 (langsam)", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(panel, 2, 3, str.tostring(ema3Length), text_color=colorEma3, bgcolor=color.new(color.black, 0), text_size=size.large)

    table.cell(panel, 0, 4, "────────", text_color=color.gray, bgcolor=color.new(color.black, 0))
    table.cell(panel, 1, 4, "────────", text_color=color.gray, bgcolor=color.new(color.black, 0))
    table.cell(panel, 2, 4, "────────", text_color=color.gray, bgcolor=color.new(color.black, 0))

    table.cell(panel, 0, 5, "Aktueller Tradingstil", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(panel, 1, 5, "", bgcolor=color.new(color.black, 0))
    table.cell(panel, 2, 5, style, text_color=color.lime, bgcolor=color.new(color.black, 0))

    table.cell(panel, 0, 6, "ⓘ", text_color=color.gray, bgcolor=color.new(color.black, 0))
    table.cell(panel, 1, 6, "Diese Werte werden aktuell verwendet.", text_color=color.gray, bgcolor=color.new(color.black, 0))
    table.cell(panel, 2, 6, "", bgcolor=color.new(color.black, 0))

if barstate.islast and not showPanel
    table.clear(panel, 0, 0, 2, 6)

// ───── Alerts ─────
alertcondition(buySignal, "EMA Kaufsignal", "EMA 1 kreuzt EMA 2 nach oben")
alertcondition(sellSignal, "EMA Verkaufssignal", "EMA 1 kreuzt EMA 2 nach unten")
alertcondition(bullTrend, "Bullischer EMA Trend", "EMA 1 > EMA 2 > EMA 3")
alertcondition(bearTrend, "Bärischer EMA Trend", "EMA 1 < EMA 2 < EMA 3")
````
