# Stage-2 RS + Volume Accumulation

- url: https://www.tradingview.com/script/9mzlyP6T-Stage-2-RS-Volume-Accumulation/
- type: indicator
- pine_id: PUB;cfe65d2372804a56b854daeabad08d69
- version: 1.0

## Description

Stage-2 RS + Volume Accumulation to refer any stock with good buy zone

## Source Code

````pine
//@version=6
indicator("Stage-2 RS + Volume Accumulation", overlay=true, max_labels_count=500)

benchmark = input.symbol("NSE:NIFTYMIDSMALL400", "Benchmark Index")
rsiLen = input.int(14, "RSI Length", minval=2)
rsLen = input.int(30, "RS Lookback", minval=5)
volLen = input.int(20, "Volume Avg Length", minval=5)
volMult = input.float(1.2, "Volume Spike Multiplier", step=0.1)
swingLen = input.int(50, "Higher High/Low Lookback", minval=10)

mClose = request.security(syminfo.tickerid, "M", close)
mMA18 = request.security(syminfo.tickerid, "M", ta.sma(close, 18))
mRsi = request.security(syminfo.tickerid, "M", ta.rsi(close, rsiLen))
stage2 = mClose > mMA18 and mMA18 > mMA18[1]

idxClose = request.security(benchmark, timeframe.period, close)
validIdx = not na(idxClose) and idxClose > 0
rsLine = validIdx ? close / idxClose : na
rsMA = ta.sma(rsLine, rsLen)
beatsIndex = validIdx and rsLine > rsMA and ta.roc(rsLine, rsLen) > 0

higherHigh = high > ta.highest(high[1], swingLen)
higherLow = low > ta.lowest(low[1], swingLen)
hhhl = higherHigh and higherLow

volAvg = ta.sma(volume, volLen)
upVol = ta.sma(close > open ? volume : 0.0, volLen) * volLen
dnVol = ta.sma(close < open ? volume : 0.0, volLen) * volLen
accumulation = upVol > dnVol and close > open and volume > volAvg * volMult

basePass = stage2 and mRsi > 55 and beatsIndex
buy = basePass and hhhl
strongBuy = buy and accumulation
avoid = not buy

barcolor(avoid ? color.red : strongBuy ? color.lime : buy ? color.green : na)
bgcolor(avoid ? color.new(color.red, 90) : strongBuy ? color.new(color.green, 88) : buy ? color.new(color.teal, 90) : na)

plotshape(buy and not strongBuy, title="BUY", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.tiny)
plotshape(strongBuy, title="STRONG BUY", style=shape.labelup, location=location.belowbar, color=color.lime, text="STRONG BUY", textcolor=color.black, size=size.tiny)

plot(mMA18, title="18M MA", color=color.orange, linewidth=2)

alertcondition(buy and not strongBuy, title="BUY", message="BUY")
alertcondition(strongBuy, title="STRONG BUY", message="STRONG BUY")
alertcondition(avoid, title="AVOID", message="AVOID")
````
