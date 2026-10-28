# CryptoEdge Pro

- url: https://www.tradingview.com/script/RaEGc6yV-CryptoEdge-Pro/
- type: indicator
- pine_id: PUB;a8ec93c648de4e8b9cd830633f0557e0
- version: 1.0

## Description

Free indicator — dynamic bands and BUY/SELL signals.

BUY when price bounces from lower band
SELL when price rejects from upper band
Works BTCUSD ETHUSD 4H OR 1H 
Alerts included

By CryptoFX Edge
--- PriceFlow Pro coming soon ---

## Source Code

````pine
//@version=5
indicator(title="CryptoEdge Pro", shorttitle="CryptoEdgePro", overlay=true)

slMult = input.float(1.5, "SL Mult ATR", group="Risk", step=0.1)
tpMult = input.float(2.5, "TP Mult ATR", group="Risk", step=0.1)
adxMin = input.float(0, "ADX minimo", group="Filtros")
sessionStr = input.session("0000-2359", "Session UTC", group="Filtros")

src1 = hlc3
src2 = close

v1 = ta.vwap(src1)
m1 = ta.ema(src2, 9)
m2 = ta.ema(src2, 21)
r1 = ta.atr(14)
[d1, d2, d3] = ta.dmi(14, 14)

inSession = not na(time(timeframe.period, sessionStr))
hasTrend = d3 >= adxMin
trendUp = m1 > m2
trendDown = m1 < m2

longOK = ta.crossover(m1, v1) and trendUp and inSession and hasTrend
shortOK = ta.crossunder(m1, v1) and trendDown and inSession and hasTrend

if longOK
    sl = src2 - r1 * slMult
    tp = src2 + r1 * tpMult
    t1 = "BUY E: " + str.tostring(src2, "#.##")
    t2 = "SL: " + str.tostring(sl, "#.##")
    t3 = "TP: " + str.tostring(tp, "#.##")
    label.new(bar_index, low - r1, t1 + "\n" + t2 + "\n" + t3, style=label.style_label_up, color=color.teal, textcolor=color.white, size=size.normal)

if shortOK
    sl = src2 + r1 * slMult
    tp = src2 - r1 * tpMult
    t1 = "SELL E: " + str.tostring(src2, "#.##")
    t2 = "SL: " + str.tostring(sl, "#.##")
    t3 = "TP: " + str.tostring(tp, "#.##")
    label.new(bar_index, high + r1, t1 + "\n" + t2 + "\n" + t3, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)




alertcondition(longOK, "BUY", "BUY Signal")
alertcondition(shortOK, "SELL", "SELL Signal")
````
