# Umkehrstaebe nach Markttechnik

- url: https://www.tradingview.com/script/OZDqwaPo/
- type: indicator
- pine_id: PUB;298d9f98c51c4e05a16cb6320adec5d8
- version: 1.0

## Description

Ein Umkehrstab (Reversal Bar oder Umkehrkerze) ist ein wichtiges Candlestick-Muster in der Markttechnik, das eine mögliche Wende im Kursverlauf eines Marktes signalisiert.

[b]Definition und Entstehung[/b]

Ein Umkehrstab liegt vor, wenn der Preis über das Hoch oder Tief der vorhergehenden Kerze hinausgeht, sich dann aber innerhalb derselben Kerze stark in die entgegengesetzte Richtung umkehrt.

Aufwärts-Umkehr (Bärisch): Der Kurs steigt zunächst über das Hoch der vorherigen Kerze, fällt dann aber deutlich ab und schließt unter seinem Eröffnungskurs.
Abwärts-Umkehr (Bullisch): Der Kurs fällt zunächst unter das Tief der vorherigen Kerze, erholt sich dann stark und schließt über seinem Eröffnungskurs.

[b]Sie sollten nach Markttechnik niemals als isoliertes Signal gehandelt, sondern in Kombination mit anderen Chart-Ereignissen (z.B. Widerstände) oder übergeordneten Trends betrachtet werden.[/b]

## Source Code

````pine
//@version=6
indicator("Umkehrstäbe", overlay=true)

// Short-Umkehrstab
shortReversal =
     high > high[1] and
     close < open

// Long-Umkehrstab
longReversal =
     low < low[1] and
     close > open

// Markierungen
plotshape(
     shortReversal,
     title="Short Umkehrstab",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small)

plotshape(
     longReversal,
     title="Long Umkehrstab",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small)

// Alerts
alertcondition(
     shortReversal,
     title="Short Umkehrstab",
     message="Short Umkehrstab erkannt")

alertcondition(
     longReversal,
     title="Long Umkehrstab",
     message="Long Umkehrstab erkannt")
````
