# TP Scalping - Min Frequent / POC / Moy / ATR - Money Reaper

- url: https://www.tradingview.com/script/AK6yLsKP/
- type: indicator
- pine_id: PUB;ea827a93701b446fb6bf9499abc3c80a
- version: 1.0

## Description

*Min fréquent : **

C'est la plus petite taille de bougie qui revient régulièrement sur la période analysée.

Autrement dit :

"Quel est le plus petit mouvement que le marché réalise souvent ?

Dans ce cas présent : 17.5 points

**A quoi ça sert ? **

Viser un objectif minimum réaliste, si on entre sur un bon set up on sait qu'on peut viser +- cette target 

----------------------------------------------------------------------------------------

**POC**:

C'est la taille de bougie qui apparaît le plus souvent.

Dans ce cas présent 22.5 points

Permet de définir un objectif standard ( probablement la statistique la plus utile de l'indicateur

--------------------------------------------------------------------------------------
**MOY : **

Moyenne de toute l'amplitude analysée

Dans le cas présent 26.34 points

**Attention ** quelques grosses bougies peuvent faire monter cette valeur 
Utile pour les objectifs de TP ambitieux (Max confluences)

---------------------------------------------------------------------------------------

** ATR :**

L'ATR mesure la volatilité récente. Cela signifie que les dernières bougies parcourent environ 25 points en moyenne.

**Sert à savoir si le marché est :**

Rouge : Lent

orange: Normal

Vert : Très actif

## Source Code

````pine
//@version=6
indicator("TP Scalping - Min Fréquent / POC / Moy / ATR", overlay=false)

length      = input.int(50, "Nombre de bougies analysées", minval=10, maxval=500)
binSize     = input.float(5.0, "Palier en points", minval=0.25)
freqPercent = input.float(10.0, "Seuil fréquence minimum (%)", minval=1.0, maxval=50.0)
atrLength   = input.int(14, "ATR Length", minval=1)

// Seuils couleur ATR
atrBadLimit  = input.float(15.0, "ATR rouge si inférieur à", minval=0.1)
atrGoodLimit = input.float(25.0, "ATR vert si supérieur à", minval=0.1)

rangePts = high - low
atrValue = ta.atr(atrLength)
avgRange = ta.sma(rangePts, length)

atrColor =
     atrValue < atrBadLimit  ? color.red :
     atrValue < atrGoodLimit ? color.orange :
     color.lime

maxBins = 500
var float[] bins = array.new_float(maxBins, 0.0)

for i = 0 to maxBins - 1
    array.set(bins, i, 0.0)

for i = 0 to length - 1
    r = high[i] - low[i]
    binIndex = int(math.floor(r / binSize))
    if binIndex >= 0 and binIndex < maxBins
        array.set(bins, binIndex, array.get(bins, binIndex) + 1)

minOccurrences = length * freqPercent / 100.0

float minFrequent = na
float pocRange = na
float maxCount = 0.0

for i = 0 to maxBins - 1
    count = array.get(bins, i)
    level = (i + 0.5) * binSize

    if na(minFrequent) and count >= minOccurrences
        minFrequent := level

    if count > maxCount
        maxCount := count
        pocRange := level

plot(rangePts, "Bougie actuelle", color=color.gray)
plot(minFrequent, "MIN fréquent", color=color.lime, linewidth=2)
plot(pocRange, "POC", color=color.orange, linewidth=2)
plot(avgRange, "MOY", color=color.blue, linewidth=2)
plot(atrValue, "ATR", color=atrColor, linewidth=2)

var table t = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Mesure", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 0, "Points", bgcolor=color.black, text_color=color.white)

    table.cell(t, 0, 1, "Bougies", text_color=color.white)
    table.cell(t, 1, 1, str.tostring(length), text_color=color.white)

    table.cell(t, 0, 2, "MIN fréquent", text_color=color.lime)
    table.cell(t, 1, 2, str.tostring(minFrequent, "#.##") + " pts", text_color=color.lime)

    table.cell(t, 0, 3, "POC", text_color=color.orange)
    table.cell(t, 1, 3, str.tostring(pocRange, "#.##") + " pts", text_color=color.orange)

    table.cell(t, 0, 4, "MOY", text_color=color.blue)
    table.cell(t, 1, 4, str.tostring(avgRange, "#.##") + " pts", text_color=color.blue)

    table.cell(t, 0, 5, "ATR", text_color=atrColor)
    table.cell(t, 1, 5, str.tostring(atrValue, "#.##") + " pts", text_color=atrColor)
````
