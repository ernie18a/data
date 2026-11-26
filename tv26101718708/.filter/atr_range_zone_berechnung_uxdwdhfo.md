# ATR Range Zone Berechnung 

- url: https://www.tradingview.com/script/uXDwdHfo/
- type: indicator
- pine_id: PUB;a691a35f2470433796b092b5caa38e66
- version: 1.0

## Description

Der Indikator berechnet täglich automatisch die ATR Half Zonen des ATR Range Zone Framework™.

Berechnungsgrundlage:

Daily ATR (14) vom Vortag
Basispreis = (Vortages-Schlusskurs + heutiger Eröffnungskurs) ÷ 2
Half ATR = 50 % der Daily ATR

Ausgabe:

Basispreis
Daily ATR
Half ATR (50 %)
Buy Zone 1.2
Buy Zone 1.5
Buy Zone 1.75
Sell Zone 1.2
Sell Zone 1.5
Sell Zone 1.75

Darstellung:

Tabelle oben rechts im Chart
Schriftgröße 14
Keine Linien
Keine Signale
Keine automatischen Entries
Reiner Preisrechner für die täglichen ATR Half Zonen

Hinweis: Die Indikatoren liefern ausschließlich die täglichen ATR-Zonen. Die eigentliche Handelsentscheidung erfolgt durch den Trader anhand der Regeln des ATR Range Zone Framework™ (Killzones, Marktstruktur, Liquiditätssweeps, Kerzenbestätigung und weitere Confluence-Faktoren).

## Source Code

````pine
//@version=6
indicator("ATR Range Zone Framework™ - Half ATR Table", overlay=true)

atrLength = input.int(14, "ATR Länge")

dailyOpen = request.security(syminfo.tickerid, "D", open)
prevClose = request.security(syminfo.tickerid, "D", close[1])
dailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLength)[1])

basis = (prevClose + dailyOpen) / 2
halfATR = dailyATR * 0.50

buy12   = basis - halfATR * 1.2
buy15   = basis - halfATR * 1.5
buy175  = basis - halfATR * 1.75

sell12  = basis + halfATR * 1.2
sell15  = basis + halfATR * 1.5
sell175 = basis + halfATR * 1.75

var table t = table.new(position.top_right, 2, 18, border_width=2)

if barstate.islast
    table.cell(t, 0, 0, "ATR HALF 50%™", bgcolor=color.black, text_color=color.white, text_size=14)
    table.cell(t, 1, 0, "PREIS", bgcolor=color.black, text_color=color.white, text_size=14)

    table.cell(t, 0, 1, "Basispreis", text_size=14)
    table.cell(t, 1, 1, str.tostring(basis, format.mintick), text_size=14)

    table.cell(t, 0, 2, "Daily ATR", text_size=14)
    table.cell(t, 1, 2, str.tostring(dailyATR, format.mintick), text_size=14)

    table.cell(t, 0, 3, "Half ATR 50%", text_size=14)
    table.cell(t, 1, 3, str.tostring(halfATR, format.mintick), text_size=14)

    table.cell(t, 0, 4, "BUY 1.2", text_color=color.green, text_size=14)
    table.cell(t, 1, 4, str.tostring(buy12, format.mintick), text_color=color.green, text_size=14)

    table.cell(t, 0, 5, "BUY 1.5", text_color=color.green, text_size=14)
    table.cell(t, 1, 5, str.tostring(buy15, format.mintick), text_color=color.green, text_size=14)

    table.cell(t, 0, 6, "BUY 1.75", text_color=color.green, text_size=14)
    table.cell(t, 1, 6, str.tostring(buy175, format.mintick), text_color=color.green, text_size=14)

    table.cell(t, 0, 7, "SELL 1.2", text_color=color.red, text_size=14)
    table.cell(t, 1, 7, str.tostring(sell12, format.mintick), text_color=color.red, text_size=14)

    table.cell(t, 0, 8, "SELL 1.5", text_color=color.red, text_size=14)
    table.cell(t, 1, 8, str.tostring(sell15, format.mintick), text_color=color.red, text_size=14)

    table.cell(t, 0, 9, "SELL 1.75", text_color=color.red, text_size=14)
    table.cell(t, 1, 9, str.tostring(sell175, format.mintick), text_color=color.red, text_size=14)
````
