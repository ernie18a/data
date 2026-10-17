# EMA + Stochastic Strategy with SL/TP

- url: https://www.tradingview.com/script/zzUJff9J-EMA-Stochastic-Strategy-with-SL-TP/
- type: indicator
- pine_id: PUB;72103d4919c24328b56046fbbe640220
- version: 1.0

## Description

Buy / Sell signals
Stop Loss (based on nearest swing high/low)
Take Profit (Risk:Reward adjustable)
EMA 50 & EMA 200 trend filter
Stochastic trigger conditions

## Source Code

````pine
//@version=6
indicator("EMA + Stochastic Strategy with SL/TP", overlay=true)

// ===== INPUTS =====
emaFastLen = input.int(50, "EMA 50")
emaSlowLen = input.int(200, "EMA 200")

rr = input.float(2.0, "Risk Reward (TP Multiplier)", step=0.1)
swingLookback = input.int(5, "Swing Lookback")
pipBuffer = input.float(0.2, "SL Buffer")

// ===== EMAs =====
ema50 = ta.ema(close, emaFastLen)
ema200 = ta.ema(close, emaSlowLen)

plot(ema50, color=color.orange, linewidth=2)
plot(ema200, color=color.blue, linewidth=2)

// ===== STOCHASTIC =====
k = ta.stoch(close, high, low, 14)
d = ta.sma(k, 3)

// ===== TREND CONDITIONS =====
bullTrend = close > ema50 and close > ema200
bearTrend = close < ema50 and close < ema200

// ===== STOCH CROSS =====
buyTrigger = ta.crossover(k, 20)
sellTrigger = ta.crossunder(k, 80)

// ===== FINAL SIGNALS =====
buySignal = bullTrend and buyTrigger
sellSignal = bearTrend and sellTrigger

// ===== SWING POINTS =====
swingLow = ta.lowest(low, swingLookback)
swingHigh = ta.highest(high, swingLookback)

// ===== STOP LOSS =====
buySL = swingLow - pipBuffer
sellSL = swingHigh + pipBuffer

// ===== TAKE PROFIT =====
buyTP = close + (close - buySL) * rr
sellTP = close - (sellSL - close) * rr

// ===== PLOT SIGNALS =====
plotshape(buySignal, title="BUY", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sellSignal, title="SELL", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

// ===== DRAW SL & TP =====
var line slLine = na
var line tpLine = na

if buySignal
    line.delete(slLine)
    line.delete(tpLine)
    slLine := line.new(bar_index, buySL, bar_index+20, buySL, color=color.red, width=2)
    tpLine := line.new(bar_index, buyTP, bar_index+20, buyTP, color=color.green, width=2)

if sellSignal
    line.delete(slLine)
    line.delete(tpLine)
    slLine := line.new(bar_index, sellSL, bar_index+20, sellSL, color=color.red, width=2)
    tpLine := line.new(bar_index, sellTP, bar_index+20, sellTP, color=color.green, width=2)
````
