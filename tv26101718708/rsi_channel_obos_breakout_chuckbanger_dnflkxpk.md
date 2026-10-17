# RSI channel ob/os breakout [ChuckBanger]

- url: https://www.tradingview.com/script/dNFLkxPk-RSI-channel-ob-os-breakout-ChuckBanger/
- type: indicator
- pine_id: PUB;sRtdPxHyT4wX80Pb8IU1iDKv3InzcorN
- version: 1.0

## Description

This is a breakout signal script based on reverse engineering of RSI. It shows a channel of overbought and oversold readings that the trader can sett in settings. When low crosses under lower line it shows bullish signal and when high is crossing upper line it shows a bearish signal. The script also has wilder's moving average as filter instead of high/low.

Good luck traders!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChuckBanger

//@version=4
study("RSI channel ob/os breakout [ChuckBanger]", overlay=true)

ob = input(title="Overbought", type=input.integer, defval=70)
os = input(title="Oversold", type=input.integer, defval=30)
src = input(title="Source", type=input.source, defval=close)
wildersLen = input(title="Wilders Length", type=input.integer, defval=2)
filter = input(title="Filter with Wilder MA On/Off", type=input.bool, defval=false)

calc_wilder(src, length) =>
    float wild = 0
    wild := nz(wild[1]) + (src - nz(wild[1])) / length
    wild

get_rsi_rev(src, length) =>
    alpha = 2 * abs(rsi(src, length) / 100 - 0.5)
    arsi = 0.0
    arsi := alpha * src + (1 - alpha) * nz(arsi[1])
    arsi
    
rsi80 = get_rsi_rev(src, ob)
rsi20 = get_rsi_rev(src, os)

wilder = calc_wilder(src, wildersLen)

lowLevel = 0.0
lowCrossing = filter ? crossunder(wilder, rsi20) : crossunder(low, rsi20)
if (lowCrossing)
    lowLevel := rsi20

highLevel = 0.0
highCrossing = filter ? crossover(wilder, rsi80) : crossover(high, rsi80)
if (highCrossing)
    highLevel := rsi80

plot(rsi80, color=color.red, title="Daily RSI 70") 
plot(rsi20, color=color.lime, title="Daily RSI 30") 
plot(wilder, color=color.blue, title="Wilders MA") 
plotarrow(lowLevel == rsi20 ? -1 : highLevel == rsi80 ? 1 : na, colorup=color.lime, colordown=color.orange, maxheight=20, title="Bull/Bear Arrows")
````
