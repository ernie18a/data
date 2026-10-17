# Positionsgroesse

- url: https://www.tradingview.com/script/J1AIlDb0/
- type: indicator
- pine_id: PUB;9191ef4e6e42437392fa84eb7e7ef291
- version: 2.0

## Description

BASE-Positionsgrößenrechner

Wenn ihr den „Indikator“ zu eurem Chart hinzufügt, erscheint in der oberen rechten Ecke eine kleine Tabelle in der alle Informationen angezeigt werden. (Verschwindet auch nicht, wenn alle Zeichnungen entfernt werden!)

Bei Doppelklick drauf erscheinen die Einstellungen. Underlayings sind wie im Excl-Sheet hinterlegt und können per Dropdown geändert werden. Ebenso natürlich euer Risiko pro Trade. Ihr könnt auch den Einstig bzw. Stop mit Zahleneingabe verschieben (was hilfreich ist, sollte er gerade beim ersten einfügen irgendwo im Chart landen oder der Chart zu weit weg gelaufen sein)
Bei einmaligem klicken auf die Tabelle erscheinen Zwei Linien für Einstieg und Stop beide schwarz (Farbig war nicht möglich, da diese sonst dauerhaft im Chart angezeigt werden). Diese können per drag and drop ans Fibonacci-Tool gezogen werden. 
In der Tabelle werden jetzt alle Infos angezeigt, Einstig, Stop, Abstand und die Größe (Anzahl an Kontrakten), tatsächlich und abgerundet (auch über ,5 wird abgerundet!)
Wenn ihr zurück in den Chart klickt, verschwinden die Linien wieder. Aber alle Informationen Start, Stop etc bleiben erhalten und werden dauerhaft angezeigt.

## Source Code

````pine
//@version=6
indicator("Positionsrechner", overlay=true)

risiko = input.float(125, "Risiko pro Trade")

markt = input.string("EURUSD", "Underlying", options=["FDXS","FDXM","FDAX","EURUSD","6E","MGC","GC","MES","ES","MCL","CL","FGBL","AKTIEN"])

einstieg = input.price(1.10000, "Einstieg")
stopPreis = input.price(1.09900, "ISL / Stop")

multiplikator = switch markt
    "FDXS" => 1.0
    "FDXM" => 5.0
    "FDAX" => 25.0
    "EURUSD" => 1.0
    "6E" => 125000.0
    "MGC" => 10.0
    "GC" => 100.0
    "MES" => 5.0
    "ES" => 50.0
    "MCL" => 100.0
    "CL" => 1000.0
    "FGBL" => 1000.0
    "AKTIEN" => 1.0
    => 1.0

preisFormat = markt == "EURUSD" ? "#.#####" : (markt == "FDAX" or markt == "FDXS" or markt == "FDXM") ? "#" : "#.##"

anzeigeEinstieg = markt == "MES" ? math.round(einstieg * 4) / 4 : einstieg
anzeigeStop     = markt == "MES" ? math.round(stopPreis * 4) / 4 : stopPreis

abstand = math.abs(anzeigeEinstieg - anzeigeStop)
groesse = abstand > 0 ? risiko / (abstand * multiplikator) : na
groesseGanz = math.floor(groesse)

var table t = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Underlying")
    table.cell(t, 1, 0, markt)

    table.cell(t, 0, 1, "Risiko")
    table.cell(t, 1, 1, str.tostring(risiko, "#"))

    table.cell(t, 0, 2, "Einstieg")
    table.cell(t, 1, 2, str.tostring(anzeigeEinstieg, preisFormat))

    table.cell(t, 0, 3, "ISL")
    table.cell(t, 1, 3, str.tostring(anzeigeStop, preisFormat))

    table.cell(t, 0, 4, "Abstand")
    table.cell(t, 1, 4, str.tostring(abstand, preisFormat))

    table.cell(t, 0, 5, "Größe")
    table.cell(t, 1, 5, str.tostring(groesse, "#,###.##") + " / ganz: " + str.tostring(groesseGanz))
````
