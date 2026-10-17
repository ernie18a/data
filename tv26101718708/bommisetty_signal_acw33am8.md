# Bommisetty Signal

- url: https://www.tradingview.com/script/Acw33Am8-Bommisetty-Signal/
- type: indicator
- pine_id: PUB;3cf6ee0921794b989d9ef361498bf68c
- version: 1.0

## Description

this is for educational purpose not for illegal, follow strict rules

## Source Code

````pine
//@version=6
indicator(title="Bommisetty Signal", shorttitle="Bommisetty", overlay=true)
conversionPeriods = input.int(9, minval=1, title="Conversion Line Length")
basePeriods = input.int(24, minval=1, title="Base Line Length")
laggingSpan2Periods = input.int(52, minval=1, title="Leading Span B Length")
displacement = input.int(24, minval=1, title="Lagging Span")
donchian(len) => math.avg(ta.lowest(len), ta.highest(len))
conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)
leadLine1 = math.avg(conversionLine, baseLine)
leadLine2 = donchian(laggingSpan2Periods)
plot(conversionLine, color=#2962FF, title="Conversion Line")
plot(baseLine, color=#B71C1C, title="Base Line")
plot(close, offset = -displacement + 1, color=#43A047, title="Lagging Span")
p1 = plot(leadLine1, offset = displacement - 1, color=#A5D6A7,
	 title="Leading Span A")
p2 = plot(leadLine2, offset = displacement - 1, color=#EF9A9A,
	 title="Leading Span B")
plot(leadLine1 > leadLine2 ? leadLine1 : leadLine2, offset = displacement - 1, title = "Kumo Cloud Upper Line", display = display.none) 
plot(leadLine1 < leadLine2 ? leadLine1 : leadLine2, offset = displacement - 1, title = "Kumo Cloud Lower Line", display = display.none) 
fill(p1, p2, title = "Cloud Fill", color = leadLine1 > leadLine2 ? color.rgb(67, 160, 71, 90) : color.rgb(244, 67, 54, 90))
//@version=5
// Cross conditions
bullCross = ta.crossover(conversionLine, baseLine)
bearCross = ta.crossunder(conversionLine, baseLine)
//@version=5
// Example Buy/Sell condition (you can replace with your own logic)
emaFast = ta.ema(close, 9)
emaSlow = ta.ema(close, 24)
buySignal  = ta.crossover(emaFast, emaSlow)
sellSignal = ta.crossunder(emaFast, emaSlow)
//@version=5
// Ichimoku Cloud declaration
conversionLength = input.int(9, title="Conversion Line Length")
baseLength       = input.int(24, title="Base Line Length")
laggingSpan2Len  = input.int(52, title="Lagging Span 2 Length")
//@version=5
// --- Define Your Buy & Sell Conditions Here ---
// Replace the conditions below with the exact logic or indicator from your base script
buyCondition  = ta.crossover(ta.ema(close, 9), ta.ema(close, 24))
sellCondition = ta.crossunder(ta.ema(close, 9), ta.ema(close, 24))
// --- Tracking States ---
// This remembers the last signal so candles stay colored until the next signal
var isBuy  = false
var isSell = false
// --- Plotting Labels ---
plotshape(buyCondition, title="Buy Label", location=location.belowbar, 
          style=shape.labelup, size=size.small, color=color.green, textcolor=color.white)

plotshape(sellCondition, title="Sell Label", location=location.abovebar, 
          style=shape.labeldown, size=size.small, color=color.red, textcolor=color.white)
````
