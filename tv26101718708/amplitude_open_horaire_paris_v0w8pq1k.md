# Amplitude Open Horaire (Paris)

- url: https://www.tradingview.com/script/V0W8Pq1K/
- type: indicator
- pine_id: PUB;4cb76a5f12794e539a4ef71e0aa02d6a
- version: 1.0

## Description

Amplitude Open Horaire Bougie H1

Cet indicateur ancre un niveau de référence sur l'open de chaque heure pleine (fuseau Europe/Paris) et visualise l'écart du prix par rapport à ce niveau, bougie par bougie.

Lorsqu'une bougie se forme entièrement au-dessus de l'open horaire, un remblai teal relie le niveau au bas de la bougie. Lorsqu'une bougie se forme entièrement en-dessous, un remblai rouge relie le niveau à son haut. Le corridor coloré matérialise ainsi le déplacement directionnel à l'intérieur de l'heure.

Le niveau se réinitialise à chaque nouvelle heure, offrant un cadre de lecture H1 adapté au scalping en unités de temps inférieures (M1, M5).
À utiliser sur un graphique en sous-unité horaire : sur un graphique en 1h ou plus, le niveau correspond simplement à l'open de la bougie courante et le remblai ne s'affiche pas.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Hakujii

//@version=6
indicator("Amplitude Open Horaire (Paris)", overlay = true)

tz = "Europe/Paris"

// Capture l'open de la 1ere bougie de chaque heure (ancre H1)
var float hourOpen = na
isNewHour = na(hourOpen) or (hour(time, tz) != hour(time[1], tz))
if isNewHour
    hourOpen := open

// Niveau zero = open de l'heure
zeroPlot = plot(hourOpen, "Open horaire", color = color.gray, linewidth = 1)

// Vert : bougie entierement au-dessus du zero -> on suit son BAS
greenLow  = low > hourOpen ? low : na
greenPlot = plot(greenLow, "Bas haussier", color = color.new(color.teal, 100))

// Rouge : bougie entierement en-dessous du zero -> on suit son HAUT
redHigh = high < hourOpen ? high : na
redPlot = plot(redHigh, "Haut baissier", color = color.new(color.red, 100))

// Remblais
fill(zeroPlot, greenPlot, color = color.new(color.teal, 70), title = "Amplitude haute")
fill(zeroPlot, redPlot,   color = color.new(color.red, 70),  title = "Amplitude basse")
````
