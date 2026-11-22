# Relative Strength During Market Correction

- url: https://www.tradingview.com/script/ABlI2wJW-Relative-Strength-During-Market-Correction/
- type: indicator
- pine_id: PUB;47a56d1e9c48418ca6ba8a94307d3ab7
- version: 1.0

## Description

Looking for sectors that display RS during market correction

## Source Code

````pine
//@version=5
indicator("Relative Strength During Market Correction", overlay=true)

// --- Inputs ---
benchmarkTicker = input.symbol("NSE:NIFTY", title="Benchmark", 
     tooltip="Use NSE:NIFTY for largecap, NSE:CNX500 for broader market")
emaLength = input.int(21, title="EMA Length", minval=5, maxval=200)

// --- Chart Calculations ---
chartEma = ta.ema(close, emaLength)
chartIsStrong = close > chartEma

// --- Benchmark Calculations ---
benchClose = request.security(benchmarkTicker, timeframe.period, close, 
     lookahead=barmerge.lookahead_off)
benchEma = ta.ema(benchClose, emaLength)
marketInCorrection = benchClose < benchEma

// --- RS Setup ---
rsSetup = marketInCorrection and chartIsStrong
rsJustStarted = rsSetup and not rsSetup[1]
rsEnded = not rsSetup and rsSetup[1]

// --- Visuals ---
plot(chartEma, color=color.new(color.green, 0), linewidth=2, title="Chart EMA")
plot(benchEma, color=color.new(color.orange, 50), linewidth=1, 
     title="Benchmark EMA", display=display.data_window)

bgcolor(rsSetup ? color.new(color.green, 88) : na, title="RS Active")

plotshape(rsJustStarted, style=shape.labelup, location=location.belowbar, 
     color=color.green, text="RS▲", textcolor=color.white, size=size.small,
     title="RS Start")
plotshape(rsEnded, style=shape.labeldown, location=location.abovebar, 
     color=color.red, text="RS▼", textcolor=color.white, size=size.small,
     title="RS End")

// --- Alerts ---
alertcondition(rsJustStarted, title="RS Setup Triggered", 
     message="{{ticker}} showing Relative Strength vs benchmark")
alertcondition(rsEnded, title="RS Setup Ended", 
     message="{{ticker}} RS setup has broken down")
````
