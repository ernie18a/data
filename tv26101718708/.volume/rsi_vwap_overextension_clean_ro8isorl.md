# RSI + VWAP Overextension (Clean)

- url: https://www.tradingview.com/script/rO8iSorL-RSI-VWAP-Overextension-Clean/
- type: indicator
- pine_id: PUB;cf6e5d1859f140f2aa69d93f434de880
- version: 1.0

## Description

Testing how powerful the vwap+rsi can be as an indicator for reversals

## Source Code

````pine
//@version=5
indicator("RSI + VWAP Overextension (Clean)", overlay=true)

// === INPUTS ===
rsiLength = input.int(14, "RSI Length")
rsiOB     = input.int(70, "RSI OB")
rsiOS     = input.int(30, "RSI OS")

devThresh = input.float(0.25, "VWAP Dev %", step=0.05)

// === CALCS ===
rsi = ta.rsi(close, rsiLength)
vwapVal = ta.vwap(hlc3)

dev = (close - vwapVal) / vwapVal * 100

// === CONDITIONS ===
overLong  = rsi > rsiOB and dev > devThresh
overShort = rsi < rsiOS and dev < -devThresh

// === SIGNALS ONLY (NO OTHER VISUALS) ===
plotshape(overLong,
     style=shape.labeldown,
     location=location.abovebar,
     text="OE L",
     size=size.tiny,
     color=color.red,
     textcolor=color.white)

plotshape(overShort,
     style=shape.labelup,
     location=location.belowbar,
     text="OE S",
     size=size.tiny,
     color=color.green,
     textcolor=color.white)
````
