# Alphabet Long Trigger (Björn)

- url: https://www.tradingview.com/script/nNl0NUVZ/
- type: indicator
- pine_id: PUB;0aa5f4bdf9e3422687519f166a1f8b9c
- version: 1.0

## Description

Alphabet Trigger Dezember 2025:
Kurs 267–269 €
grüne Kerze mit höherem Tief
Volumen-Lebenszeichen
Nasdaq nicht im Abwärtsmodus

Alphabet Momentum Pullback Strategy — Brief Description

This strategy targets high-quality pullbacks within a confirmed uptrend and enters a long position only when price, structure, volume, and market context align.

A trade is triggered when:

Price enters the buy zone between €267–€269, signaling a controlled pullback.

The chart forms the first green candle with a higher low, indicating buyers are returning.

Volume shows a positive uptick (at least above the recent average), confirming real demand.

The Nasdaq is not falling, ensuring the broader tech market is stable and not in risk-off mode.

The strategy avoids entries triggered solely by price and waits for multi-factor confirmation, reducing false breakouts and momentum traps. It is designed for disciplined swing traders who prioritize trend alignment, volume confirmation, and market context before entering a position.

## Source Code

````pine
//@version=5
indicator("Alphabet Long Trigger (Björn)", overlay=true)

// ────────────────────────────────────────
// Parameter (für EUR-Alphabet & Nasdaq)
// ────────────────────────────────────────

// Kaufzone für Alphabet in EUR
minPrice = input.float(267.0, "Min Kaufpreis")
maxPrice = input.float(269.0, "Max Kaufpreis")

// Volumen-Faktor gegenüber Durchschnitt (z.B. 1.1 = 110 %)
volFactor = input.float(1.1, "Volumenfaktor vs. Durchschnitt")

// Nasdaq-Symbol (kannst du bei Bedarf anpassen, z.B. auf QQQ)
nasdaqSymbol = input.symbol("NASDAQ:NDX", "Nasdaq-Index")

// Zeitraum für Durchschnittsvolumen
volLength = input.int(20, "Periode Durchschnittsvolumen", minval=5)

// ────────────────────────────────────────
// 1) Alphabet-Preisbedingung: 267–269 €
// ────────────────────────────────────────

priceInZone = (close >= minPrice) and (close <= maxPrice)

// ────────────────────────────────────────
// 2) Erste grüne Kerze mit höherem Tief
//    - grüne Kerze: close > open
//    - höheres Tief: low > low[1]
// ────────────────────────────────────────

greenCandle = close > open
higherLow   = low > low[1]
candleOk    = greenCandle and higherLow

// ────────────────────────────────────────
// 3) Volumen: mind. X % über Durchschnitt
// ────────────────────────────────────────

avgVol     = ta.sma(volume, volLength)
volumeOk   = volume > avgVol * volFactor

// ────────────────────────────────────────
// 4) Nasdaq nicht im Abwärtsmodus
//    - aktuelle Nasdaq-Kerze nicht tiefer als die vorige
//    - UND nicht deutlich rot (Schutz vor Risk-Off)
// ────────────────────────────────────────

nasdaqClose     = request.security(nasdaqSymbol, timeframe.period, close)
nasdaqPrevClose = request.security(nasdaqSymbol, timeframe.period, close[1])

nasdaqNotFalling   = nasdaqClose >= nasdaqPrevClose
nasdaqNotBigRed    = (nasdaqClose - nasdaqPrevClose) / nasdaqPrevClose > -0.007  // max. ca. -0,7 %

nasdaqOk = nasdaqNotFalling and nasdaqNotBigRed

// ────────────────────────────────────────
// Gesamtsignal: ALLE Bedingungen erfüllt
// ────────────────────────────────────────

longTrigger = priceInZone and candleOk and volumeOk and nasdaqOk

// Markierung im Chart
plotshape(longTrigger, title="Alphabet Long Trigger", style=shape.labelup,
     text="ALPH LONG", location=location.belowbar, size=size.large)

// Hintergrund einfärben, wenn Trigger
bgcolor(longTrigger ? color.new(color.green, 85) : na)

// Alert-Bedingung
alertcondition(longTrigger, title="Alphabet Long Trigger",
     message="Alphabet-Setup erfüllt: Kurs in Zone, grüne Kerze mit höherem Tief, Volumen OK, Nasdaq stabil.")
````
