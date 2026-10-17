# VLDMI

- url: https://www.tradingview.com/script/b4hQ3nMb/
- type: indicator
- pine_id: PUB;7d75952797244a5bb9d5fda08d483a5a
- version: 1.0

## Description

RSI上位互換

## Source Code

````pine
//@version=5
indicator("VLDMI", shorttitle="VLDMI", overlay=false)

// ===== 入力 =====
rsiBaseLength = input.int(14, "RSI Base Length", minval=2)
volLength     = input.int(10, "Volatility Length", minval=2)
smoothLength  = input.int(3, "Smoothing", minval=1)

overBought = input.int(70, "Overbought")
overSold   = input.int(30, "Oversold")

// ===== ボラティリティ =====
volatility = ta.stdev(close, volLength)

volMin = ta.lowest(volatility, 50)
volMax = ta.highest(volatility, 50)

normVol = (volatility - volMin) / math.max(volMax - volMin, 0.0001)

// ===== 可変期間 =====
dynamicLength = math.round(rsiBaseLength * (1.5 - normVol))
dynamicLength := math.max(dynamicLength, 2)

// ===== 価格変化 =====
change = ta.change(close)

upMove   = math.max(change, 0)
downMove = -math.min(change, 0)

// ===== 可変RMA関数 =====
f_dynamic_rma(src, len) =>
    alpha = 1.0 / len
    var float rma = na
    rma := na(rma[1]) ? src : alpha * src + (1 - alpha) * rma[1]
    rma

// ===== 可変RMA =====
upRma   = f_dynamic_rma(upMove, dynamicLength)
downRma = f_dynamic_rma(downMove, dynamicLength)

// ===== RSI計算 =====
rs = downRma == 0 ? 100 : upRma / downRma

vldmi = 100 - (100 / (1 + rs))

// ===== スムージング =====
vldmiSmooth = ta.sma(vldmi, smoothLength)

// ===== 描画 =====
plot(vldmiSmooth, title="VLDMI", color=color.aqua, linewidth=2)

hline(overBought, "OverBought", color=color.red)
hline(overSold, "OverSold", color=color.green)
hline(50, "Middle", color=color.gray)

// ===== 背景 =====
bgcolor(
     vldmiSmooth > overBought ? color.new(color.red, 90) :
     vldmiSmooth < overSold ? color.new(color.green, 90) :
     na)

// ===== シグナル =====
buySignal  = ta.crossover(vldmiSmooth, overSold)
sellSignal = ta.crossunder(vldmiSmooth, overBought)

plotshape(
     buySignal,
     title="BUY",
     location=location.bottom,
     color=color.lime,
     style=shape.triangleup,
     size=size.small)

plotshape(
     sellSignal,
     title="SELL",
     location=location.top,
     color=color.red,
     style=shape.triangledown,
     size=size.small)

// ===== アラート =====
alertcondition(
     buySignal,
     title="BUY Alert",
     message="VLDMI BUY Signal")

alertcondition(
     sellSignal,
     title="SELL Alert",
     message="VLDMI SELL Signal")
````
