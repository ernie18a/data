# TENDANCE 2H DAILY (SELL @ Haut / BUY @ Bas)

- url: https://www.tradingview.com/script/upTzZsZm/
- type: indicator
- pine_id: PUB;5a22655e497b48488820fb82229ef229
- version: 1.0

## Description

2-HOUR DAILY TREND (SELL @ High / BUY @ Low)

GOLD scanner on the M10 timeframe
Detect trend
Identify structure
Wait for breakout
Verify close
Wait for retest
Send signal 🔔

## Source Code

````pine
//@version=5
indicator("SNIPER 10M (SELL @ Haut / BUY @ Bas)", overlay=true)

// === DÉTECTION DES EXTRÊMES ===
lookback = 5
// Nombre de bougies pour détecter les extrêmes (ajustable)

// Plus haut local (pour SELL)
localHigh = ta.highest(high, lookback)
// Plus bas local (pour BUY)
localLow = ta.lowest(low, lookback)

// === CONDITIONS DE SIGNAL ===
// SELL : Quand le prix casse sous le plus haut local (fin de l'impulsion haussière)
sellSignal = ta.crossunder(close, high[1]) and high[1] == localHigh
// BUY : Quand le prix casse au-dessus du plus bas local (fin de l'impulsion baissière)
buySignal = ta.crossover(close, low[1]) and low[1] == localLow

// === AFFICHAGE DES FLÈCHES ===
plotshape(sellSignal, title="SELL (Plus Haut)", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal)
plotshape(buySignal, title="BUY (Plus Bas)", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal)

// === ALERTES ===
alertcondition(sellSignal, title="SELL ALERT", message="SELL @ Plus Haut (10M)")
alertcondition(buySignal, title="BUY ALERT", message="BUY @ Plus Bas (10M)")
````
