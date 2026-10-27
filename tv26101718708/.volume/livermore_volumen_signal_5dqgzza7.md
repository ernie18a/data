# Livermore Volumen Signal

- url: https://www.tradingview.com/script/5DqGZZa7/
- type: indicator
- pine_id: PUB;3e73aff9f85049f6ad1a129d117f5396
- version: 1.0

## Description

Livermore Volumen Signal – Volumenanalyse nach Jesse Livermore

Dieser Indikator basiert auf der Volumenanalyse von Jesse Livermore, wie sie in Richard Smittens „Trade Like Jesse Livermore" (2005) beschrieben wird. Livermore hielt Volumen für den einzigen objektiven Bestätigungsindikator neben dem Kurs – alles andere bezeichnete er als Lärm.

Was zeigt der Indikator?
Der Indikator berechnet das Verhältnis des aktuellen Balkens-Volumens zum 20-Perioden-Durchschnittsvolumen (Vol/Ø-Ratio). Das Ergebnis wird als Balken dargestellt und nach Livermores Schwellenwerten farbcodiert:

🟡 Gelb (≥ 1,5x): Erhöhtes Volumen – potenzielles Signal. Aufmerksamkeit erforderlich.

🟢 Grün (≥ 2,0x): Starkes Volumen – bestätigt Pivotal Points, Breakouts oder Trendfortsetzungen.

🔴 Rot (≥ 5,0x): Extremer Erschöpfungs-Spike – mögliches Trendende, Distributions- oder Reversal-Signal.

⬜ Grau (< 1,5x): Normales oder niedriges Volumen – kein valides Signal nach Livermore.

Die vier Livermore-Volumenregeln:

Kurs steigt + Volumen steigt → Trend intakt, Position halten/aufstocken

Kurs steigt + Volumen fällt → Trend schwächelt, kein Nachhaufen

Kurs fällt + Volumen fällt → Normal Reaction, kein Ausstieg nötig

Kurs fällt + Volumen steigt → Echter Abverkauf / Distribution → Ausstieg prüfen

Anwendung:
Kombiniere diesen Indikator mit Pivotal Points (strukturelle Hoch-/Tiefpunkte), Breakouts zu neuen Hochs/Tiefs sowie One-Day-Reversal-Mustern. Ein Breakout ohne erhöhtes Volumen (< 1,5x) ist nach Livermore kein valides Signal. Erst ab 2,0x gilt ein Signal als bestätigt.

## Source Code

````pine
//@version=6
indicator("Livermore Volumen Signal", overlay=false)

// 20-Tage Durchschnittsvolumen
vol_ma = ta.sma(volume, 20)

// Verhältnis aktuelles Volumen zu Durchschnitt
vol_ratio = volume / vol_ma

// ✅ RICHTIG – alles in einer Zeile, kein Umbruch im ternären Operator
farbe = vol_ratio >= 5.0 ? color.new(color.red, 0) : vol_ratio >= 2.0 ? color.new(color.green, 0) : vol_ratio >= 1.5 ? color.new(color.yellow, 0) : color.new(color.gray, 40)

// Balken zeichnen
plot(vol_ratio, title="Vol/Ø-Ratio", color=farbe, style=plot.style_columns)

// Livermore Schwellenlinien
hline(1.5, "Livermore Min-Signal (1.5x)", color=color.yellow, linestyle=hline.style_dashed)
hline(2.0, "Starkes Signal (2.0x)",       color=color.green,  linestyle=hline.style_dashed)
hline(5.0, "Erschöpfungs-Spike (5.0x)",   color=color.red,    linestyle=hline.style_dashed)

// Mittellinie (Durchschnitt = 1.0)
hline(1.0, "Durchschnitt",                color=color.gray,   linestyle=hline.style_solid)
````
