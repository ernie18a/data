# CWOP

- url: https://www.tradingview.com/script/EKhn2GP3-CWOP/
- type: indicator
- pine_id: PUB;2d848d0c5ca84102bfbc09cf3b6f6b31
- version: 1.0

## Description

iykyk members only lehh do it iykyk  members only lehh do it

## Source Code

````pine
//@version=5
indicator("CWOP", overlay=true)

// === Averages ===
ema8  = ta.ema(close, 8)
sma21 = ta.sma(close, 21)
vwap  = ta.vwap(hlc3)

// === Plot levels (optional visual aid) ===
plot(ema8,  color=color.orange, title="EMA 8")
plot(sma21, color=color.blue,   title="SMA 21")
plot(vwap,  color=color.purple, title="VWAP")

// === Define stacked zone ===
upperLevel = math.max(math.max(ema8, sma21), vwap)
lowerLevel = math.min(math.min(ema8, sma21), vwap)

// === Full wick sweep condition ===
// candle must pierce above highest AND below lowest
fullSlice = high > upperLevel and low < lowerLevel

// === Direction logic ===
// downward slice = bearish candle (close < open)
// upward slice   = bullish candle (close > open)
downSlice = fullSlice and close < open
upSlice   = fullSlice and close > open

// === Coloring ===
barcolor(downSlice ? color.white :
         upSlice   ? color.black :
         na)
````
