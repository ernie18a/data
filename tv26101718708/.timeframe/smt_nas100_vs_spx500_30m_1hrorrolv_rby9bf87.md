# SMT NAS100 vs SPX500 - 30m / 1H(RorRoLv)

- url: https://www.tradingview.com/script/RbY9Bf87/
- type: indicator
- pine_id: PUB;f666a254fea6450f80acb6486738dbf0
- version: 1.0

## Description

SMT NAS100 vs SPX500 para apertura en altos y bajos de 30 minutos y 1 hora

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RorRoLv

//@version=6
indicator("SMT NAS100 vs SPX500 - 30m / 1H(RorRoLv)", overlay=true, max_labels_count=500)

// === Inputs ===
spxSymbol = input.symbol("OANDA:SPX500USD", "Símbolo SPX500")
tfSMT     = input.timeframe("30", "Temporalidad SMT", options=["30", "60"])
showHigh  = input.bool(true, "Detectar SMT en altos")
showLow   = input.bool(true, "Detectar SMT en bajos")

// === Datos NAS100 del gráfico ===
nasHigh = request.security(syminfo.tickerid, tfSMT, high)
nasLow  = request.security(syminfo.tickerid, tfSMT, low)

// === Datos SPX500 ===
spxHigh = request.security(spxSymbol, tfSMT, high)
spxLow  = request.security(spxSymbol, tfSMT, low)

// === Último alto/bajo cerrado anterior ===
nasPrevHigh = nasHigh[1]
nasPrevLow  = nasLow[1]

spxPrevHigh = spxHigh[1]
spxPrevLow  = spxLow[1]

// === Condiciones SMT ===
// SPX500 saca alto anterior, NAS100 no
bearishSMT = showHigh and spxHigh > spxPrevHigh and nasHigh <= nasPrevHigh

// SPX500 saca bajo anterior, NAS100 no
bullishSMT = showLow and spxLow < spxPrevLow and nasLow >= nasPrevLow

// === Señales visuales ===
plotshape(
     bearishSMT,
     title="SMT Bajista",
     style=shape.labeldown,
     text="SMT\nSPX High",
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.small
)

plotshape(
     bullishSMT,
     title="SMT Alcista",
     style=shape.labelup,
     text="SMT\nSPX Low",
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.small
)

// === Alertas ===
alertcondition(bearishSMT, title="SMT Bajista SPX/NAS", message="SPX500 sacó el último alto de 30m/1H y NAS100 no confirmó.")
alertcondition(bullishSMT, title="SMT Alcista SPX/NAS", message="SPX500 sacó el último bajo de 30m/1H y NAS100 no confirmó.")
````
