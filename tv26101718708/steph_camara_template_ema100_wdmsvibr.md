# Steph CAMARA Template + EMA100

- url: https://www.tradingview.com/script/wdMsViBr/
- type: indicator
- pine_id: PUB;156b8b5d595045e9808437e24831ea47
- version: 1.0

## Description

Template nom + EMA 100 intégrée. permet d'affiche un slogan et ton nom sur le graphique avec la moyenne mobile exponentielle 100

## Source Code

````pine
//@version=6
indicator("Steph CAMARA Template + EMA100", overlay=true)

//==============================
// INPUTS
//==============================
grpText = "Template"
nameText = input.string("Steph CAMARA", "Nom", group=grpText)
sloganText = input.string("FOCUS   |   STRATEGY   |   SUCCESS", "Slogan", group=grpText)
showTemplate = input.bool(true, "Afficher template", group=grpText)

grpStyle = "Style Template"
nameColor = input.color(color.rgb(160, 115, 20), "Couleur nom dorée", group=grpStyle)
sloganColor = input.color(color.rgb(95, 85, 70), "Couleur slogan", group=grpStyle)
templateBg = input.color(color.new(color.white, 100), "Fond template", group=grpStyle)

grpEMA = "EMA+"
showEMA = input.bool(true, "Afficher EMA+ 100", group=grpEMA)
emaLen = input.int(100, "Longueur EMA", minval=1, group=grpEMA)
emaSource = input.source(close, "EMA Source", group=grpEMA)
emaBullColor = input.color(color.rgb(60, 180, 75), "Couleur EMA haussière", group=grpEMA)
emaBearColor = input.color(color.rgb(245, 45, 65), "Couleur EMA baissière", group=grpEMA)
emaWidth = input.int(2, "Épaisseur EMA", minval=1, maxval=5, group=grpEMA)

//==============================
// TEMPLATE TEXTE
//==============================
var table tpl = table.new(position.top_center, 1, 2, border_width=0)

if barstate.islast
    if showTemplate
        table.cell(tpl, 0, 0, nameText, text_color=nameColor, bgcolor=templateBg, text_size=size.large)
        table.cell(tpl, 0, 1, sloganText, text_color=sloganColor, bgcolor=templateBg, text_size=size.small)
    else
        table.clear(tpl, 0, 0)

//==============================
// EMA+ 100
//==============================
emaPlus = ta.ema(emaSource, emaLen)
emaColor = close >= emaPlus ? emaBullColor : emaBearColor

plot(showEMA ? emaPlus : na, title="EMA+ 100", color=emaColor, linewidth=emaWidth)
````
