# 3-Kerzen-Farbmuster

- url: https://www.tradingview.com/script/8Hp3MOGZ/
- type: indicator
- pine_id: PUB;eeac4c3e5c7449d08b9cfb0681e3edbb
- version: 1.0

## Description

Das Script gibt eine Meldung aus wenn im Chart sich der Kerze ändert

## Source Code

````pine
//@version=6
indicator("3-Kerzen-Farbmuster (grün-grün-rot / rot-rot-grün)", overlay=true)

// ----- Benutzereingabe -----
showDots = input.bool(true, "Dots im Chart anzeigen")

// ----- Kerzenfarben der letzten 3 vollständigen Kerzen -----
isGreen1 = close[1] > open[1]
isRed1   = close[1] < open[1]
isGreen2 = close[2] > open[2]
isRed2   = close[2] < open[2]
isGreen3 = close[3] > open[3]
isRed3   = close[3] < open[3]

// ----- Mustererkennung -----
longPattern  = isGreen3 and isGreen2 and isRed1   // grün, grün, rot
shortPattern = isRed3 and isRed2 and isGreen1    // rot, rot, grün

// ----- Punkte im Chart (nur wenn showDots aktiv) -----
plotshape(showDots and longPattern, title="Long Signal", location=location.belowbar,
         color=color.new(color.green, 0), style=shape.circle, size=size.small)
plotshape(showDots and shortPattern, title="Short Signal", location=location.abovebar,
         color=color.new(color.red, 0), style=shape.circle, size=size.small)

// ----- TradingView-Alarme (immer aktiv) -----
alertcondition(longPattern, title="Long Pattern (grün-grün-rot)", message="Long: grün, grün, rot")
alertcondition(shortPattern, title="Short Pattern (rot-rot-grün)", message="Short: rot, rot, grün")
````
