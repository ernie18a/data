# WinnerTrend

- url: https://www.tradingview.com/script/LzyHnfxp/
- type: indicator
- pine_id: PUB;839ae6a479b745e2894e7648b1ace7e6
- version: 1.0

## Description

trend senin dostundur...yeşil bölge tut kırmızı bölge sat alanı

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=5
indicator("WinnerTrend", overlay=true)

//=====================
// INPUTS
//=====================
len1 = input.int(8,  "Periyot 8")
len2 = input.int(13, "Periyot 13")
len3 = input.int(21, "Periyot 21")
len4 = input.int(55, "Periyot 55")

//=====================
// ZONE OPACITY
//=====================
greenTransp = input.int(85, "Yeşil Zone Opaklık (0-100)")
redTransp   = input.int(85, "Kırmızı Zone Opaklık (0-100)")

//=====================
// RENKLER
//=====================
col1 = input.color(color.orange, "W 8")
col2 = input.color(color.teal,   "W 13")
col3 = input.color(color.blue,   "W 21")
col4 = input.color(color.green,  "W 55")

col50  = input.color(color.yellow, "SMA 50")
col200 = input.color(color.red,    "SMA 200")

//=====================
// WEIGHTED FUNCTION
//=====================
w_sma = 0.2
w_ema = 0.5
w_wma = 0.3

f_weighted(len) =>
    ema = ta.ema(close, len)
    sma = ta.sma(close, len)
    wma = ta.wma(close, len)

    ema := na(ema) ? close : ema
    sma := na(sma) ? close : sma
    wma := na(wma) ? close : wma

    (sma * w_sma) + (ema * w_ema) + (wma * w_wma)

//=====================
// VALUES
//=====================
w1 = f_weighted(len1)  // 8
w2 = f_weighted(len2)  // 13
w3 = f_weighted(len3)  // 21
w4 = f_weighted(len4)  // 55

sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

//=====================
// PLOTS
//=====================
p1 = plot(w1, color=col1, linewidth=3, title="W 8")
plot(w2, color=col2, linewidth=2, title="W 13")
p2 = plot(w3, color=col3, linewidth=3, title="W 21")
plot(w4, color=col4, linewidth=2, title="W 55")

plot(sma50,  color=col50,  linewidth=2, title="SMA 50")
plot(sma200, color=col200, linewidth=2, title="SMA 200")

//=====================
// ONLY ZONE: 8 - 21
//=====================
bull = w1 > w3

fill(p1, p2,
     color = bull ? color.new(color.green, greenTransp)
                  : color.new(color.red, redTransp),
     title="Zone 8-21")
````
