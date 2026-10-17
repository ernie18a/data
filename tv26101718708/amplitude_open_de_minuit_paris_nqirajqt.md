# Amplitude Open de Minuit (Paris)

- url: https://www.tradingview.com/script/nQIRAjqt/
- type: indicator
- pine_id: PUB;cf846938cf664e6cbbed4ec9e8575649
- version: 1.0

## Description

Amplitude Open de Minuit ancre le prix d'ouverture de 00h00 (heure de Paris) comme niveau de référence de la session, et met en évidence les phases où le prix s'en est nettement détaché.
Tant qu'une bougie reste entièrement au-dessus de l'open de minuit, une bande verte se remplit jusqu'à son point bas ; entièrement en-dessous, une bande rouge se remplit jusqu'à son point haut. Lorsque le prix chevauche l'open, aucune bande n'apparaît : la zone est considérée comme indécise.

Le résultat donne en un coup d'œil le côté dominant de la session et la profondeur du déplacement par rapport au prix de référence de minuit.

Ligne grise : open de minuit (Europe/Paris)
Remblai vert : prix entièrement au-dessus de l'open
Remblai rouge : prix entièrement en-dessous
Zone neutre quand le prix recouvre l'open

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Hakujii

//@version=6
indicator("Amplitude Open de Minuit (Paris)", overlay = true)

tz = "Europe/Paris"

// Capture l'open de la 1ere bougie de chaque journee (minuit Paris)
var float midOpen = na
isNewDay = na(midOpen) or (dayofmonth(time, tz) != dayofmonth(time[1], tz))
if isNewDay
    midOpen := open

// Niveau zero = open de minuit
zeroPlot = plot(midOpen, "Open minuit", color = color.gray, linewidth = 1)

// Vert : bougie entierement au-dessus du zero -> on suit son BAS
greenLow  = low > midOpen ? low : na
greenPlot = plot(greenLow, "Bas haussier", color = color.new(color.teal, 100))

// Rouge : bougie entierement en-dessous du zero -> on suit son HAUT
redHigh = high < midOpen ? high : na
redPlot = plot(redHigh, "Haut baissier", color = color.new(color.red, 100))

// Remblais entre le zero et le bord des bougies
fill(zeroPlot, greenPlot, color = color.new(color.teal, 70), title = "Amplitude haute")
fill(zeroPlot, redPlot,   color = color.new(color.red, 70),  title = "Amplitude basse")
````
