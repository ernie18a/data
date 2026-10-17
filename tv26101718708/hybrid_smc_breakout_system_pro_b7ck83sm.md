# Hybrid SMC Breakout System PRO

- url: https://www.tradingview.com/script/b7ck83Sm-Hybrid-SMC-Breakout-System-PRO/
- type: indicator
- pine_id: PUB;febeb5dc60c04c9b930dbecb0f9e569d
- version: 1.0

## Description

Hybrid SMC Breakout System PRO
BULL PULLBACK
BEAR PULLBACK

## Source Code

````pine
//@version=6
indicator("Hybrid SMC Breakout System PRO", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// INPUTS
//====================================================
trendLen        = input.int(200, "EMA Trend Length")
fastEMA         = input.int(20, "Fast EMA")
slowEMA         = input.int(50, "Slow EMA")
atrLen          = input.int(14, "ATR Length")
atrMult         = input.float(1.5, "ATR Stop Multiplier")
rr              = input.float(2.0, "Risk Reward")
showFVG         = input.bool(true, "Show Fair Value Gaps")
showLiquidity   = input.bool(true, "Show Liquidity Sweeps")
showBreakouts   = input.bool(true, "Show Breakouts")
showTrend       = input.bool(true, "Show Trend")
showSR          = input.bool(true, "Show Support Resistance")
showSignals     = input.bool(true, "Show Buy Sell Signals")

//====================================================
// EMA TREND
//====================================================
emaTrend = ta.ema(close, trendLen)
emaFast  = ta.ema(close, fastEMA)
emaSlow  = ta.ema(close, slowEMA)

bullTrend = close > emaTrend and emaFast > emaSlow
bearTrend = close < emaTrend and emaFast < emaSlow

plot(showTrend ? emaTrend : na, color=color.orange, linewidth=2)
plot(showTrend ? emaFast : na, color=color.green)
plot(showTrend ? emaSlow : na, color=color.red)

//====================================================
// SUPPORT / RESISTANCE
//====================================================
pivotHigh = ta.pivothigh(high, 5, 5)
pivotLow  = ta.pivotlow(low, 5, 5)

var float resistance = na
var float support = na

if not na(pivotHigh)
    resistance := pivotHigh

if not na(pivotLow)
    support := pivotLow

plot(showSR ? resistance : na, color=color.red, linewidth=2, style=plot.style_linebr)
plot(showSR ? support : na, color=color.green, linewidth=2, style=plot.style_linebr)

//====================================================
// BREAKOUT DETECTION
//====================================================
bullBreakout = close > resistance and close[1] <= resistance
bearBreakout = close < support and close[1] >= support

plotshape(showBreakouts and bullBreakout, title="Bull Breakout", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(showBreakouts and bearBreakout, title="Bear Breakout", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

//====================================================
// FAIR VALUE GAP (ICT STYLE)
//====================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(bar_index-2, high[2], bar_index, low, bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 40))

if showFVG and bearFVG
    box.new(bar_index-2, high, bar_index, low[2], bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 40))

//====================================================
// LIQUIDITY SWEEPS
//====================================================
liqBuy  = low < ta.lowest(low, 10)[1] and close > open
liqSell = high > ta.highest(high, 10)[1] and close < open

plotshape(showLiquidity and liqBuy, title="Liquidity Buy", style=shape.circle, location=location.belowbar, color=color.aqua, size=size.small)
plotshape(showLiquidity and liqSell, title="Liquidity Sell", style=shape.circle, location=location.abovebar, color=color.orange, size=size.small)

//====================================================
// MARKET STRUCTURE SHIFT
//====================================================
bullMSS = high > high[1] and low > low[1]
bearMSS = low < low[1] and high < high[1]

//====================================================
// ATR STOP / TARGET
//====================================================
atr = ta.atr(atrLen)

longSL = close - atr * atrMult
longTP = close + (close - longSL) * rr

shortSL = close + atr * atrMult
shortTP = close - (shortSL - close) * rr

//====================================================
// FINAL ENTRY CONDITIONS
//====================================================
longSignal = bullTrend and bullBreakout and bullMSS and (liqBuy or bullFVG)
shortSignal = bearTrend and bearBreakout and bearMSS and (liqSell or bearFVG)

//====================================================
// SIGNALS
//====================================================
if showSignals and longSignal
    label.new(bar_index, low,
      text="BUY\nSL: " + str.tostring(longSL, format.mintick) + "\nTP: " + str.tostring(longTP, format.mintick),
      style=label.style_label_up,
      color=color.green,
      textcolor=color.white)

if showSignals and shortSignal
    label.new(bar_index, high,
      text="SELL\nSL: " + str.tostring(shortSL, format.mintick) + "\nTP: " + str.tostring(shortTP, format.mintick),
      style=label.style_label_down,
      color=color.red,
      textcolor=color.white)

//====================================================
// ALERTS
//====================================================
alertcondition(longSignal, title="BUY ALERT", message="Hybrid System BUY")
alertcondition(shortSignal, title="SELL ALERT", message="Hybrid System SELL")
````
