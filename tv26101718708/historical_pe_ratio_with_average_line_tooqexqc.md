# Historical P/E Ratio with Average Line

- url: https://www.tradingview.com/script/TOoqExQC/
- type: indicator
- pine_id: PUB;7529fba3d9bf49d3b13d63e9efea38dc
- version: 1.0

## Description

[b]**Description:**[/b]

This indicator plots a stock's price-to-earnings (P/E) ratio over time and adds an average line. It lets you see at a glance whether a company is currently valued more expensively or more cheaply than its historical norm.

[b]**What the indicator shows**[/b]

The blue line shows the historical P/E ratio, calculated as the current price divided by earnings per share. The orange line represents the average — either as an overall average across the entire available history, or as a moving average over an adjustable number of bars. A small info box in the top right summarizes the current P/E value and the average.

[b]**Settings**[/b]

The calculation period can be set to TTM (trailing twelve months), fiscal year (FY), or quarter (FQ). The average type can be switched between overall average and moving average, whose length is freely adjustable. An outlier filter hides extreme P/E spikes that occur during periods of very low earnings and would otherwise distort the scale.

[b]**Usage notes**[/b]

The indicator only works with stocks that have available fundamental data and is most useful on the daily or weekly chart. During loss periods with negative earnings, the P/E ratio is undefined and is deliberately not displayed. The overall average is calculated across the history loaded in the chart — the more history is visible, the more meaningful the average line becomes.

[b]**Disclaimer**[/b]

This indicator is provided for informational and educational purposes only and does not constitute investment advice or a buy/sell recommendation. A P/E ratio above or below its historical average is not a buy or sell signal in itself and should always be considered together with the business model, growth expectations, and industry context. Fundamental data is provided by TradingView; no guarantee is made as to its accuracy or completeness.

---

[b]**Beschreibung:**[/b]

Dieser Indikator stellt das Kurs-Gewinn-Verhältnis (KGV) einer Aktie über die Zeit dar und ergänzt es um eine Durchschnittslinie. So lässt sich auf einen Blick erkennen, ob ein Unternehmen aktuell teurer oder günstiger bewertet ist als im historischen Mittel.

[b]**Was der Indikator zeigt**[/b]

Die blaue Linie zeigt das historische KGV, berechnet aus dem aktuellen Kurs geteilt durch den Gewinn je Aktie. Die orange Linie stellt den Durchschnitt dar – wahlweise als Gesamtdurchschnitt über die gesamte verfügbare Historie oder als gleitender Durchschnitt über eine einstellbare Anzahl von Bars. Eine kleine Info-Box rechts oben fasst den aktuellen KGV-Wert und den Durchschnitt zusammen.

[b]**Einstellmöglichkeiten**[/b]

Berechnungsperiode wählbar zwischen TTM (letzte zwölf Monate), Geschäftsjahr (FY) und Quartal (FQ). Der Durchschnittstyp lässt sich zwischen Gesamtdurchschnitt und gleitendem Durchschnitt umschalten, dessen Länge frei einstellbar ist. Ein Ausreißer-Filter blendet extreme KGV-Spitzen aus, die bei sehr niedrigen Gewinnen entstehen und die Skala sonst verzerren würden.

[b]**Hinweise zur Nutzung**[/b]

Der Indikator funktioniert nur bei Aktien mit verfügbaren Fundamentaldaten und ist am sinnvollsten auf dem Tages- oder Wochenchart. In Verlustphasen mit negativem Gewinn ist das KGV nicht definiert und wird bewusst nicht dargestellt. Der Gesamtdurchschnitt wird über die im Chart geladene Historie gebildet – je mehr Historie sichtbar ist, desto aussagekräftiger ist die Durchschnittslinie.

[b]**Wichtiger Hinweis**[/b]

Dieser Indikator dient ausschließlich Informations- und Bildungszwecken und stellt keine Anlageberatung oder Kauf-/Verkaufsempfehlung dar. Ein KGV über oder unter dem historischen Durchschnitt ist für sich genommen kein Kauf- oder Verkaufssignal, sondern sollte stets im Zusammenhang mit dem Geschäftsmodell, der Wachstumserwartung und dem Branchenumfeld betrachtet werden. Fundamentaldaten werden von TradingView bereitgestellt; für deren Richtigkeit und Vollständigkeit wird keine Gewähr übernommen.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mcsnowman

//@version=6
indicator("Historisches KGV & Durchschnitt", shorttitle="KGV", overlay=false, precision=2)

// ─── Eingaben ───────────────────────────────────────────────
periode         = input.string("TTM", "Berechnungsperiode", options=["TTM", "FY", "FQ"])
durchschnittTyp = input.string("Gesamtdurchschnitt", "Durchschnitt", options=["Gesamtdurchschnitt", "Gleitend (SMA)"])
smaLaenge       = input.int(252, "SMA-Länge (Bars)", minval=1, tooltip="Nur bei 'Gleitend'. 252 ≈ 1 Handelsjahr auf Tagesbasis.")
maxKGV          = input.float(100.0, "Ausreißer ab KGV von ... ignorieren", minval=0, tooltip="Blendet extreme Spitzen aus (z.B. bei sehr kleinen Gewinnen).")

// ─── Gewinn je Aktie (EPS) abrufen ──────────────────────────
eps = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE", periode, ignore_invalid_symbol = true)

// ─── KGV berechnen (nur sinnvoll bei positivem Gewinn) ──────
kgv      = (not na(eps) and eps > 0) ? close / eps : na
kgvClean = (not na(kgv) and kgv <= maxKGV) ? kgv : na

// ─── Durchschnitt berechnen ─────────────────────────────────
var float summe  = 0.0
var int   anzahl = 0
if not na(kgvClean)
    summe  += kgvClean
    anzahl += 1
gesamtAvg = anzahl > 0 ? summe / anzahl : na

avg = durchschnittTyp == "Gesamtdurchschnitt" ? gesamtAvg : ta.sma(kgvClean, smaLaenge)

// ─── Ausgabe ────────────────────────────────────────────────
plot(kgvClean, "KGV",   color=color.new(color.blue, 0),   linewidth=2)
plot(avg,      "Ø KGV", color=color.new(color.orange, 0), linewidth=2)

// Info-Box rechts oben mit aktuellen Werten
var table info = table.new(position.top_right, 1, 2, bgcolor=color.new(color.gray, 80), border_width=1)
if barstate.islast
    table.cell(info, 0, 0, "KGV akt.: " + (na(kgvClean) ? "n/v" : str.tostring(kgvClean, "#.##")), text_color=color.blue)
    table.cell(info, 0, 1, "Ø KGV: "    + (na(avg)      ? "n/v" : str.tostring(avg, "#.##")),      text_color=color.orange)
````
