# Lee Jones 5  EMA

- url: https://www.tradingview.com/script/SBzgbJ9G-Lee-Jones-5-EMA/
- type: indicator
- pine_id: PUB;3c33be033b244ca8b8ec2c75d43b5389
- version: 2.0

## Description

My Simple 5EMA Fast bands that change colour when bullish / bearish and 50/100/200

## Source Code

````pine


//@version=5
indicator("LJ's EMA", overlay=true)
src = close

// Input options for EMAs
emaS_value = input.int(12, minval=1, title="EMA Small - Value")
emaS = ta.ema(close, emaS_value)
emaB_value = input.int(21, minval=1, title="EMA Big - Value")
emaB = ta.ema(close, emaB_value)
emaC_value = input.int(50, minval=1, title="EMA C - Value")
emaC = ta.ema(close, emaC_value)
emaD_value = input.int(100, minval=1, title="EMA D - Value")
emaD = ta.ema(close, emaD_value)
emaE_value = input.int(200, minval=1, title="EMA E - Value")
emaE = ta.ema(close, emaE_value)

EMA_UpTrend_color = input(color.green, title="EMA UpTrend Color")
EMA_DownTrend_color = input(#ff0000, title="EMA DownTrend Color")
EMA_C_color = input(color.rgb(71, 10, 10), title="EMA C Color")
EMA_D_color = input(#0d093d, title="EMA D Color")
EMA_E_color = input(#720d65, title="EMA E Color")

// Input options for Arrows
arrowColorUp = input(color.green, title="Arrow Up Color")
arrowColorDown = input(#ff0000, title="Arrow Down Color")
arrowSize = input.int(50, minval=1, title="Arrow Size")

// Rules For Up and Down EMA trends
EMA_UpTrend = emaS >= emaB
EMA_DownTrend = emaS < emaB

// Rules for Arrows by using EMAs Crossover state
var float crossover = na
// Determine crossover state
if (crossover == 1)
    crossover := na
else if (EMA_UpTrend[1] and EMA_DownTrend)
    crossover := -1
else if (crossover == -1)
    crossover := na
else if (EMA_DownTrend[1] and EMA_UpTrend)
    crossover := 1


// Plot EMAs on chart
plot(emaS, color=color.new(EMA_UpTrend ? EMA_UpTrend_color : EMA_DownTrend_color, 0), title="EMA Small", style=plot.style_line, linewidth=1, offset=0)
plot(emaB, color=color.new(EMA_UpTrend ? EMA_UpTrend_color : EMA_DownTrend_color, 0), title="EMA Big", style=plot.style_line, linewidth=2, offset=0)
plot(emaC, color=color.new(EMA_C_color, 0), title="EMA C", style=plot.style_line, linewidth=3, offset=0)
plot(emaD, color=color.new(EMA_D_color, 0), title="EMA D", style=plot.style_line, linewidth=3, offset=0)
plot(emaE, color=color.new(EMA_E_color, 0), title="EMA E", style=plot.style_line, linewidth=3, offset=0)
// Plot arrow when EMAs cross
plotarrow(crossover == 1 ? 1 : crossover == -1 ? -1 : na, title="Show Arrow on EMAs Cross", colorup=arrowColorUp, colordown=arrowColorDown, maxheight=arrowSize, offset=+1, display=display.none)

// Alerts
alertcondition(crossover == 1, title="EMA Trend Up", message="EMA Trend Up - {{ticker}} - {{interval}}")
alertcondition(crossover == -1, title="EMA Trend Down", message="EMA Trend Down - {{ticker}} - {{interval}}")
````
