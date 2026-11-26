# LZ VWAP + TWAP Fusion BY LZ 

- url: https://www.tradingview.com/script/SQgFvbxX/
- type: indicator
- pine_id: PUB;2d5f1dae68b14f40ae6de5d890697c47
- version: 1.0

## Description

VWAP TWAP Fusion — LZ

Indicateur de lecture directionnelle basé sur la combinaison du VWAP et du TWAP.

Le VWAP représente le prix moyen pondéré par le volume. Il permet d’identifier les zones où le marché a réellement échangé avec du volume, souvent utilisées comme zones d’équilibre institutionnelles.

Le TWAP représente le prix moyen pondéré par le temps. Il donne une lecture plus stable du prix moyen, indépendante des variations brutales de volume.

Cet indicateur affiche :
- le VWAP
- le TWAP
- une ligne fusionnée VWAP/TWAP
- les croisements VWAP/TWAP
- les zones où le prix évolue au-dessus ou en dessous de la moyenne fusionnée

Objectif :
Aider à repérer les zones d’équilibre, les changements de biais, les croisements importants et les réactions potentielles autour des moyennes institutionnelles.

Lecture générale :
- Prix au-dessus de la fusion VWAP/TWAP : biais plutôt haussier
- Prix en dessous de la fusion VWAP/TWAP : biais plutôt baissier
- Croisement VWAP/TWAP : zone de transition ou possible accélération
- Prix proche de la fusion : zone d’équilibre ou d’indécision

Cet indicateur ne donne pas de signal automatique d’achat ou de vente. Il sert uniquement d’outil visuel d’analyse et de confluence avec d’autres éléments comme les Order Blocks, Fibonacci, RSI MTF, VI/FVG, structure de marché et niveaux de liquidité.

## Source Code

````pine
//@version=6
indicator("LZ VWAP + TWAP Fusion Weighted", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMain = "⚙️ LZ Fusion VWAP/TWAP"

src = input.source(hlc3, "Source", group=groupMain)

useDailyReset = input.bool(true, "Reset journalier TWAP/VWAP", group=groupMain)
twapLen       = input.int(120, "TWAP Length si pas reset", minval=1, group=groupMain)

vwapWeightInput = input.float(50.0, "Poids VWAP %", minval=0, maxval=100, step=1, group=groupMain)
twapWeightInput = input.float(50.0, "Poids TWAP %", minval=0, maxval=100, step=1, group=groupMain)

useAdaptive = input.bool(false, "Mode adaptatif ATR", group=groupMain)
atrLen      = input.int(14, "ATR Length", minval=1, group=groupMain)
atrSmooth   = input.int(50, "ATR Moyenne", minval=1, group=groupMain)
adaptiveStrength = input.float(20.0, "Force adaptation %", minval=0, maxval=50, step=1, group=groupMain)

showVWAP   = input.bool(true, "Afficher VWAP", group=groupMain)
showTWAP   = input.bool(true, "Afficher TWAP", group=groupMain)
showFusion = input.bool(true, "Afficher Fusion", group=groupMain)

groupSignal = "🎯 Signaux"
showSignals = input.bool(true, "Afficher signaux cross prix/fusion", group=groupSignal)
compressionTicks = input.float(20.0, "Compression VWAP/TWAP max ticks", minval=0, step=1, group=groupSignal)
tickSizeInput = input.float(0.25, "Tick size", minval=0.00001, group=groupSignal)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION RESET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newDay = ta.change(time("D")) != 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP CUSTOM DAILY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float cumPV = na
var float cumVol = na

if barstate.isfirst or (useDailyReset and newDay)
    cumPV := src * volume
    cumVol := volume
else
    cumPV += src * volume
    cumVol += volume

customVWAP = cumVol != 0 ? cumPV / cumVol : src

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TWAP CUSTOM DAILY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float cumPrice = na
var int cumBars = na

if barstate.isfirst or (useDailyReset and newDay)
    cumPrice := src
    cumBars := 1
else
    cumPrice += src
    cumBars += 1

dailyTWAP = cumBars > 0 ? cumPrice / cumBars : src
rollingTWAP = ta.sma(src, twapLen)

twap = useDailyReset ? dailyTWAP : rollingTWAP
vwap = customVWAP

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE WEIGHTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, atrSmooth)

volRatio = atrAvg != 0 ? atr / atrAvg : 1.0

baseVWAPWeight = vwapWeightInput / 100.0
baseTWAPWeight = twapWeightInput / 100.0

adaptiveBoost = math.min(math.max((volRatio - 1.0) * adaptiveStrength / 100.0, -adaptiveStrength / 100.0), adaptiveStrength / 100.0)

vwapWeightRaw = useAdaptive ? baseVWAPWeight + adaptiveBoost : baseVWAPWeight
twapWeightRaw = useAdaptive ? baseTWAPWeight - adaptiveBoost : baseTWAPWeight

weightSum = vwapWeightRaw + twapWeightRaw

vwapWeight = weightSum != 0 ? vwapWeightRaw / weightSum : 0.5
twapWeight = weightSum != 0 ? twapWeightRaw / weightSum : 0.5

fusion = (vwap * vwapWeight) + (twap * twapWeight)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vwapTwapDistanceTicks = math.abs(vwap - twap) / tickSizeInput
isCompression = vwapTwapDistanceTicks <= compressionTicks

priceCrossUp = ta.crossover(close, fusion)
priceCrossDown = ta.crossunder(close, fusion)

fusionUp = fusion > fusion[1]
fusionDown = fusion < fusion[1]

buySignal = priceCrossUp and fusionUp
sellSignal = priceCrossDown and fusionDown

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showVWAP ? vwap : na, "VWAP", color=color.new(color.blue, 0), linewidth=2)
plot(showTWAP ? twap : na, "TWAP", color=color.new(color.orange, 0), linewidth=2)

fusionColor = fusionUp ? color.lime : fusionDown ? color.red : color.gray
plot(showFusion ? fusion : na, "LZ Fusion VWAP/TWAP", color=fusionColor, linewidth=3)

bgcolor(isCompression ? color.new(color.yellow, 88) : na, title="Compression VWAP/TWAP")

plotshape(showSignals and buySignal, title="BUY Cross Fusion", style=shape.labelup, text="BUY\nFusion", color=color.new(color.green, 0), textcolor=color.white, location=location.belowbar, size=size.small)
plotshape(showSignals and sellSignal, title="SELL Cross Fusion", style=shape.labeldown, text="SELL\nFusion", color=color.new(color.red, 0), textcolor=color.white, location=location.abovebar, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table t = table.new(position.top_right, 2, 5, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "LZ Fusion", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.black)

    table.cell(t, 0, 1, "VWAP poids", text_color=color.white)
    table.cell(t, 1, 1, str.tostring(vwapWeight * 100, "#.##") + "%", text_color=color.white)

    table.cell(t, 0, 2, "TWAP poids", text_color=color.white)
    table.cell(t, 1, 2, str.tostring(twapWeight * 100, "#.##") + "%", text_color=color.white)

    table.cell(t, 0, 3, "Distance", text_color=color.white)
    table.cell(t, 1, 3, str.tostring(vwapTwapDistanceTicks, "#.##") + " ticks", text_color=isCompression ? color.yellow : color.white)

    table.cell(t, 0, 4, "Mode", text_color=color.white)
    table.cell(t, 1, 4, useAdaptive ? "ATR Adaptatif" : "Fixe", text_color=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, title="LZ Fusion BUY", message="LZ Fusion VWAP/TWAP BUY")
alertcondition(sellSignal, title="LZ Fusion SELL", message="LZ Fusion VWAP/TWAP SELL")
alertcondition(isCompression, title="LZ Fusion Compression", message="VWAP et TWAP proches = zone compression")
````
