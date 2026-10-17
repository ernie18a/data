# BRAYAN PRO ZONES + EMA 200

- url: https://www.tradingview.com/script/2YEWqc6j-BRAYAN-PRO-ZONES-EMA-200/
- type: indicator
- pine_id: PUB;7cf22334726148e7a03c496c46466a2e
- version: 1.0

## Description

BRAYAN SMART MONEY

Advanced Smart Money Concepts indicator designed for XAUUSD traders using institutional price action and market structure analysis.

This indicator helps identify:
- Breaks of structure
- Trend reversals
- Liquidity sweeps
- Institutional zones
- Smart Money reactions

FEATURES:
✅ BOS (Break of Structure)
✅ CHOCH (Change of Character)
✅ Liquidity Sweeps
✅ Order Blocks
✅ EMA 200 Trend Filter
✅ Dynamic Support & Resistance
✅ Institutional Zones
✅ Clean professional design

WHAT IT SHOWS:
🟢 BOS ↑ = Bullish continuation
🔴 BOS ↓ = Bearish continuation
🟦 Liquidez = Possible liquidity sweep
🟩 Green zones = Bullish order blocks
🟥 Red zones = Bearish order blocks
🟧 EMA 200 = Main market trend

BEST USE:
- XAUUSD
- M5 timeframe
- New York session

Ideal for:
- Scalping
- Smart Money Concepts
- ICT style trading
- Institutional trading
- Prop firm trading

This indicator is built to help traders understand market structure, liquidity manipulation, and high probability reaction zones used by institutional traders.

## Source Code

````pine
//@version=5
indicator("BRAYAN PRO ZONES + EMA 200", overlay=true, max_boxes_count=20, max_labels_count=20)

//====================================================
// AJUSTES
//====================================================
fuerza = input.int(10, "Fuerza")
tamanoZona = input.float(5.0, "Tamaño Zona")

//====================================================
// EMA 200
//====================================================
ema200 = ta.ema(close, 200)

plot(
     ema200,
     color=color.orange,
     linewidth=2,
     title="EMA 200")

//====================================================
// SOPORTE Y RESISTENCIA
//====================================================
ph = ta.pivothigh(high, fuerza, fuerza)
pl = ta.pivotlow(low, fuerza, fuerza)

var float resistencia = na
var float soporte = na

if not na(ph)
    resistencia := ph

if not na(pl)
    soporte := pl

//====================================================
// VARIABLES
//====================================================
var box zonaResistencia = na
var box zonaSoporte = na

var label labelResistencia = na
var label labelSoporte = na

//====================================================
// RESISTENCIA
//====================================================
if not na(resistencia)

    // BORRAR ANTERIOR
    box.delete(zonaResistencia)
    label.delete(labelResistencia)

    // CREAR ZONA
    zonaResistencia := box.new(
         left=bar_index - 10,
         top=resistencia + tamanoZona,
         right=bar_index + 40,
         bottom=resistencia,
         bgcolor=color.new(color.red, 88),
         border_color=color.red,
         border_width=1)

    // ETIQUETA
    labelResistencia := label.new(
         bar_index,
         resistencia,
         "RESISTENCIA",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

//====================================================
// SOPORTE
//====================================================
if not na(soporte)

    // BORRAR ANTERIOR
    box.delete(zonaSoporte)
    label.delete(labelSoporte)

    // CREAR ZONA
    zonaSoporte := box.new(
         left=bar_index - 10,
         top=soporte,
         right=bar_index + 40,
         bottom=soporte - tamanoZona,
         bgcolor=color.new(color.green, 88),
         border_color=color.green,
         border_width=1)

    // ETIQUETA
    labelSoporte := label.new(
         bar_index,
         soporte,
         "SOPORTE",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)
````
