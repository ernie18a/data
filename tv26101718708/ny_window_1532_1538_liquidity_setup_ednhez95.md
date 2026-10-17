# NY Window 1532 1538 Liquidity Setup

- url: https://www.tradingview.com/script/EDnHeZ95/
- type: indicator
- pine_id: PUB;151d4ac3d84e4bc496baa86a888ea635
- version: 1.0

## Description

On cherche à capturer le dernier mouvement de la journée.

Cette fenêtre horaire permet d’identifier une zone clé où le marché fixe :

un haut
un bas

À partir de cette zone, on attend un setup classique SMC :

prise de liquidité (sweep)
réaction
impulsion

 L’objectif est de se positionner dans la direction du mouvement final.

## Source Code

````pine
//@version=6
indicator("Fenêtre 15:32–15:38 NY", overlay=true)

tz = "America/New_York"

h = hour(time, tz)
m = minute(time, tz)

inWindow = (h == 15 and m >= 32 and m <= 38)

bgcolor(inWindow ? color.new(color.green, 80) : na)
````
