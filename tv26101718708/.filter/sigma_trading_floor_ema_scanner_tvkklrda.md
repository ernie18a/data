# SIGMA Trading Floor Ema Scanner

- url: https://www.tradingview.com/script/TvkkLrdA-SIGMA-Trading-Floor-Ema-Scanner/
- type: indicator
- pine_id: PUB;556a0ff941c540a09d982a102dd082fc
- version: 1.0

## Description

EMA COMPRESSION SCANNER, USES RSI, VOLUME AND EMA TO GIVE PROPER BREAKOUTS ENTRY.
Its is best for swing trading and day trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sagar_mehta

//@version=6
indicator("Professional EMA Compression Scanner", overlay=true)

//==================== INPUTS ====================//
fastEMA      = input.int(20, "Fast EMA")
slowEMA      = input.int(200, "Slow EMA")

compression  = input.float(0.30, "EMA Distance (%)", step=0.05)

rsiLength    = input.int(14)
rsiMin       = input.int(55)

volLength    = input.int(20)
volumeFactor = input.float(1.20)

atrLength    = input.int(14)
atrFactor    = input.float(1.2)

showLabels   = input.bool(true)

//==================== CALCULATIONS ====================//

ema20  = ta.ema(close, fastEMA)
ema200 = ta.ema(close, slowEMA)

distance = math.abs(ema20 - ema200) / close * 100

emaCompressed = distance <= compression

rsi = ta.rsi(close, rsiLength)

volAvg = ta.sma(volume, volLength)

highVolume = volume > volAvg * volumeFactor

atr = ta.atr(atrLength)

largeRange = (high-low) > atr * atrFactor

trendUp = close > ema20 and close > ema200

trendDown = close < ema20 and close < ema200

buySignal =
     emaCompressed and
     trendUp and
     rsi > rsiMin and
     highVolume and
     largeRange

sellSignal =
     emaCompressed and
     trendDown and
     rsi < 45 and
     highVolume and
     largeRange

//==================== PLOTS ====================//

plot(ema20,color=color.aqua,linewidth=2,title="20 EMA")

plot(ema200,color=color.orange,linewidth=2,title="200 EMA")

bgcolor(emaCompressed ? color.new(color.yellow,85) : na)

plotshape(buySignal,
style=shape.triangleup,
location=location.belowbar,
color=color.lime,
size=size.small,
title="BUY")

plotshape(sellSignal,
style=shape.triangledown,
location=location.abovebar,
color=color.red,
size=size.small,
title="SELL")

//==================== LABEL ====================//

if barstate.islast and showLabels

    txt =
     "EMA Distance : " + str.tostring(distance,"#.##")+"%\n"+
     "RSI : "+str.tostring(rsi,"#.0")+"\n"+
     "Volume : "+str.tostring(volume/volAvg,"#.##")+"x"

    label.new(bar_index,high,txt,
    style=label.style_label_down,
    color=color.black,
    textcolor=color.white)

//==================== ALERTS ====================//

alertcondition(buySignal,
title="BUY",
message="EMA Compression BUY Signal")

alertcondition(sellSignal,
title="SELL",
message="EMA Compression SELL Signal")
````
