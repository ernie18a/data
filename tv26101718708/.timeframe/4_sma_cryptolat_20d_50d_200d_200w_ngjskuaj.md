# 4 SMA CryptoLat 20D / 50D / 200D + 200W

- url: https://www.tradingview.com/script/nGJskuAJ-4-SMA-CryptoLat-20D-50D-200D-200W/
- type: indicator
- pine_id: PUB;8799f3f12b3342efb46884a402d69e33
- version: 1.0

## Description

This indicator combines short-, medium-, and long-term simple moving averages (20, 50, 200) with a higher timeframe reference (200-week SMA) to provide a structured view of market conditions across multiple time horizons.

Unlike standard moving average overlays, this script integrates:

A multi-timeframe framework by projecting the 200-week SMA directly onto lower timeframes
Dynamic labeling on the latest bar for quick identification of each moving average without clutter
Visual hierarchy through color and thickness to emphasize long-term levels (200 and 200W)

The inclusion of the 200-week SMA is particularly useful for identifying macro support and resistance levels often respected by institutional participants, while the 20/50/200 SMAs help evaluate short- and mid-term trend alignment.

How it works:

SMA 20: Short-term momentum
SMA 50: Mid-term trend direction
SMA 200: Long-term trend baseline
SMA 200 Weekly: Macro-level support/resistance projected from higher timeframe data

Typical use cases:

Trend confirmation when all SMAs are aligned
Identifying dynamic support/resistance zones
Observing interactions between price and higher timeframe structure

This tool is designed for traders who want a simplified but structured multi-timeframe perspective without switching charts.

## Source Code

````pine
//@version=5
indicator("SMA 20 / 50 / 200 + 200 Semanas con etiquetas", overlay=true)

// === Inputs ===
sma20_len = input.int(20, title="SMA 20")
sma50_len = input.int(50, title="SMA 50")
sma200_len = input.int(200, title="SMA 200")
sma200w_len = input.int(200, title="SMA 200 Semanas")

// === Cálculo SMAs ===
sma20 = ta.sma(close, sma20_len)
sma50 = ta.sma(close, sma50_len)
sma200 = ta.sma(close, sma200_len)
sma200w = request.security(syminfo.tickerid, "W", ta.sma(close, sma200w_len))

// === Plot ===
plot(sma20, color=color.blue, title="SMA 20", linewidth=2)
plot(sma50, color=color.orange, title="SMA 50", linewidth=2)
plot(sma200, color=color.red, title="SMA 200", linewidth=2)
plot(sma200w, color=color.purple, title="SMA 200 Semanas", linewidth=3)

// === Etiquetas dinámicas ===
var label lbl20 = na
var label lbl50 = na
var label lbl200 = na
var label lbl200w = na

// Borrar etiquetas anteriores para evitar acumulación
if bar_index > 10
    label.delete(lbl20)
    label.delete(lbl50)
    label.delete(lbl200)
    label.delete(lbl200w)

// Crear nuevas etiquetas en la última vela
if barstate.islast
    lbl20 := label.new(bar_index, sma20, "20", color=color.blue, textcolor=color.white, style=label.style_label_right)
    lbl50 := label.new(bar_index, sma50, "50", color=color.orange, textcolor=color.white, style=label.style_label_right)
    lbl200 := label.new(bar_index, sma200, "200", color=color.red, textcolor=color.white, style=label.style_label_right)
    lbl200w := label.new(bar_index, sma200w, "200W", color=color.purple, textcolor=color.white, style=label.style_label_right)
````
