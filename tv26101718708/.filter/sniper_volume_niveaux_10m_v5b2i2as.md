# SNIPER VOLUME + NIVEAUX (10M)

- url: https://www.tradingview.com/script/V5b2I2aS/
- type: indicator
- pine_id: PUB;7807c009e8bc4c4bb6c04615ef4698d6
- version: 1.0

## Description

Scan GOLD on M10
Detect trend
Identify structure
Wait for breakout
Verify closure
Wait for retest
Send signal 🔔

## Source Code

````pine
//@version=5
indicator("SNIPER VOLUME + NIVEAUX (10M)", overlay=true)

// === PARAMÈTRES ===
lookback = input.int(20, "Nombre de bougies pour détecter les extrêmes", minval=10)
minImpulsion = input.float(0.5, "Amplitude minimale de l'impulsion (%)", minval=0.1, step=0.1) / 100
minVolume = input.float(1.5, "Multiplicateur de volume moyen", minval=0.1, step=0.1)

// Niveaux fixes de support/résistance (à ajuster selon ton graphique)
niveauResistance = input.float(4000.0, "Niveau de Résistance", step=0.01)
niveauSupport = input.float(3800.0, "Niveau de Support", step=0.01)

// === DÉTECTION DES EXTRÊMES SIGNIFICATIFS ===
localHigh = ta.highest(high, lookback)
localLow = ta.lowest(low, lookback)

// === FILTRE : IMPULSION MINIMALE ===
impulsionHausse = (localHigh - localLow) / localLow >= minImpulsion
impulsionBaisse = (localHigh - localLow) / localLow >= minImpulsion

// === FILTRE DE VOLUME ===
volumeMoyen = ta.sma(volume, 20)
volumeEleve = volume > volumeMoyen * minVolume

// === CONDITIONS DE SIGNAL (FILTRÉES) ===
// SELL : Après une forte impulsion haussière + cassure baissière claire + volume élevé + près de la résistance
sellSignal = high == localHigh and impulsionHausse and close < low[1] and volumeEleve and close >= niveauResistance * 0.99
// BUY : Après une forte impulsion baissière + cassure haussière claire + volume élevé + près du support
buySignal = low == localLow and impulsionBaisse and close > high[1] and volumeEleve and close <= niveauSupport * 1.01

// === AFFICHAGE DES FLÈCHES ===
plotshape(sellSignal, title="SELL (Volume + Résistance)", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal)
plotshape(buySignal, title="BUY (Volume + Support)", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.normal)

// === AFFICHAGE DES NIVEAUX FIXES ===
plot(niveauResistance, title="Résistance", color=color.red, linewidth=2)
plot(niveauSupport, title="Support", color=color.green, linewidth=2)

// === ALERTES ===
alertcondition(sellSignal, title="SELL ALERT", message="SELL @ Résistance + Volume (10M)")
alertcondition(buySignal, title="BUY ALERT", message="BUY @ Support + Volume (10M)")
````
