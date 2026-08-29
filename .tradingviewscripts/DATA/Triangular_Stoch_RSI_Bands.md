<!-- tradingview-pine-id: PUB;KLoV7N6lZOYeb308RRbOvIzeqVcJzCEW -->
<!-- tradingviewscripts-format: 1 -->
# Triangular Stoch RSI Bands

Source: https://www.tradingview.com/script/8OVkDNNf-Triangular-Stoch-RSI-Bands/

## Description

The indicator calculates Triangularity over Stoch RSI Overbought and Oversold Conditions
So Ever wondered how a overbought and oversold condition looks if the values are triangualrised 

The indicator plots auto band levels on top of price

Enjoy!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ankit_1618

//@version=4
study("Triangular Stoch RSI Bands", overlay=true)

tma(src, length) => 
    ema(ema(ema(src,length), length), length)

l = input(20, "dynamic Length")

pivot1 = (highest(high, 9) + lowest(low, 9))/2
pivot2 = (highest(high, 26) + lowest(low, 26))/2
cum=(pivot1+pivot2)/2

adjust_n= cum - 0.89*atr(14)
adjust_p= cum + 0.89*atr(14)

Dynamic_Long = tma(adjust_n,l)
Dynamic_Short = tma(adjust_p,l)


// plot(Dynamic_Long, color=color.green)
// plot(Dynamic_Short, color=color.red)


//Stochastic RSI
smoothK = input(3, "K", minval=1)
smoothD = input(3, "D", minval=1)
lengthRSI = input(14, "RSI Length", minval=1)
lengthStoch = input(14, "Stochastic Length", minval=1)
src = input(close, title="RSI Source")
rsi1 = rsi(src, lengthRSI)
k = sma(stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d = sma(k, smoothD)
overbought = 80
oversold = 20

uc_long_condition = close>Dynamic_Long and close>Dynamic_Short and crossunder(k, 20)
uc_short_condition = close<Dynamic_Long and close<Dynamic_Short and crossover(k, 80)

//Calculations
var trend_number = 0
if close>Dynamic_Short or close<Dynamic_Long
    trend_number := nz(trend_number[1]) + 1

var highs = float(na)-float(na)
var lows = float(na)-float(na)

atr = 0//0.618*atr(14)

if uc_long_condition
    highs := high + atr
else if uc_short_condition
    lows := low - atr

tma_highs = tma(highs,l)
tma_lows = tma(lows,l)
base = (tma_highs+tma_lows)/2
p1=plot(tma_highs, color=color.green)
p2=plot(tma_lows, color=color.red)
plot(base, color=color.gray, transp=50)
fill(p1, p2, color=color.yellow)

pc = plot(close, transp=100)

fill(pc, p1, color= close>tma_highs ? color.green: na)
fill(pc, p2, color= close<tma_lows ? color.red: na)

//Plotting LEVELS


dep = input(0.01, " DEPTH 1")
upper1 = tma_highs  + tma_highs*dep
lower1 = tma_lows  - tma_lows*dep
plot(upper1, color=color.gray, transp=50)
plot(lower1, color=color.gray, transp=50)

dep2 = input(0.0168, " DEPTH 2")
upper2 = tma_highs  + tma_highs*dep2
lower2 = tma_lows  - tma_lows*dep2
plot(upper2, color=color.blue, transp=50)
plot(lower2, color=color.blue, transp=50)


dep3 = input(0.0314, " DEPTH 3")
upper3 = tma_highs  + tma_highs*dep3
lower3 = tma_lows  - tma_lows*dep3
plot(upper3, color=color.gray, transp=50)
plot(lower3, color=color.gray, transp=50)

dep4 = input(0.0446, " DEPTH 4")
upper4 = tma_highs  + tma_highs*dep4
lower4 = tma_lows  - tma_lows*dep4
plot(upper4, color=color.blue, transp=50)
plot(lower4, color=color.blue, transp=50)
````
