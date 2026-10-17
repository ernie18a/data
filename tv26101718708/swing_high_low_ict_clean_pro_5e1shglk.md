# Swing High Low - ICT Clean Pro

- url: https://www.tradingview.com/script/5e1shgLk/
- type: indicator
- pine_id: PUB;dab20cbee42344cd8b09d4f1460a8af2
- version: 1.0

## Description

Cet indicateur montre les swings highs et les swings lows avec une règle simple.
 Un swing high est une bougie dont le plus haut est supérieur à celui de la bougie précédente et de la suivante.

Un swing low est une bougie dont le plus bas est inférieur à celui de la précédente et de la suivante.
Les swings apparaissent avec un décalage d'une bougie pour confirmaiton.

De petits points sont affichés sur le graphique pour garder une lecture claire et épurée.

Cet outil m'aide à lire la structure de marché et à identifier la liquidité de manière simple et efficace.

## Source Code

````pine
//@version=6
indicator("Swing High Low - ICT Clean Pro", overlay=true)

// 🎨 Couleurs
colorHigh = input.color(color.new(color.red, 60), "Couleur Swing High")
colorLow  = input.color(color.new(color.blue, 60), "Couleur Swing Low")

// 🔹 Taille choisie
sizeInput = input.string("tiny", "Taille", options=["tiny","small","normal"])

// 🔎 Pivot 1-1
isSwingHigh = high[1] > high[0] and high[1] > high[2]
isSwingLow  = low[1] < low[0] and low[1] < low[2]

// 🟢 Affichage selon taille (OBLIGATOIRE en Pine)

// TINY
plotshape(isSwingHigh and sizeInput == "tiny", offset=-1, style=shape.circle, location=location.abovebar, size=size.tiny, color=colorHigh)
plotshape(isSwingLow  and sizeInput == "tiny", offset=-1, style=shape.circle, location=location.belowbar, size=size.tiny, color=colorLow)

// SMALL
plotshape(isSwingHigh and sizeInput == "small", offset=-1, style=shape.circle, location=location.abovebar, size=size.small, color=colorHigh)
plotshape(isSwingLow  and sizeInput == "small", offset=-1, style=shape.circle, location=location.belowbar, size=size.small, color=colorLow)

// NORMAL
plotshape(isSwingHigh and sizeInput == "normal", offset=-1, style=shape.circle, location=location.abovebar, size=size.normal, color=colorHigh)
plotshape(isSwingLow  and sizeInput == "normal", offset=-1, style=shape.circle, location=location.belowbar, size=size.normal, color=colorLow)
````
