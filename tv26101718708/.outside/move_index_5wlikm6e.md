# MOVE Index

- url: https://www.tradingview.com/script/5WlIKm6e/
- type: indicator
- pine_id: PUB;3cb9902c6e4b41da8a7f9e8e9b38c817
- version: 1.0

## Description

The MOVE Index measures the implied volatility of U.S. Treasury bonds. It is often described as the bond market’s equivalent of the VIX. A rising MOVE usually signals increasing stress or uncertainty in interest-rate markets.

## Source Code

````pine
//@version=6
indicator("MOVE Index", shorttitle="MOVE", overlay=false)

// Paramètres
move_symbol = input.symbol("TVC:MOVE", title="MOVE Index")
ma_length = input.int(5, title="Longueur MA", minval=1)

// Récupération des données MOVE
move = request.security(move_symbol, timeframe.period, close, gaps=barmerge.gaps_off)

// Gestion des données manquantes
move_clean = nz(move, 100) // Remplace na par 100 (moyenne historique)

// Calcul de la MA9
ma_move = ta.sma(move_clean, ma_length)

plot(ma_move, title="MA9 MOVE", color=color.new(color.rgb(135, 206, 250), 75), linewidth=2)
````
