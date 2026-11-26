# BTC Golden Ratio Extended for Bears

- url: https://www.tradingview.com/script/V1hJY6i5-BTC-Golden-Ratio-Extended-for-Bears/
- type: indicator
- pine_id: PUB;64b84b3b67b04b319ed9b9d924683452
- version: 1.0

## Description

Added lower yellow lines (for Fibs 3, 5, 8, 13, 21) to mark buy signals on much lower levels for the current bear market.

## Source Code

````pine
//@version=5
// Based on the medium article by Philip Swift
// Extended to include additional multipliers and lower divisions
indicator(title="BTC Golden Ratio Extended for Bears", overlay=true)

useDailyTimeframe = input(true, title="Use Static Daily Timeframe")
tf = useDailyTimeframe ? "D" : timeframe.period

// --- Calculations ---
dma111 = request.security(syminfo.tickerid, tf, ta.sma(close, 111))
dma350 = request.security(syminfo.tickerid, tf, ta.sma(close, 350))

// Upper Multipliers
goldenRatio = dma350 * 1.6
fib2 = dma350 * 2
fib3 = dma350 * 3
fib5 = dma350 * 5
fib8 = dma350 * 8
fib13 = dma350 * 13
fib21 = dma350 * 21

// Original Lower Multipliers (Yellow Lines)
negFib1_4 = dma350 / 1.4
negFib1_6 = dma350 / 1.6
negFib2 = dma350 / 2
negFib2_6 = dma350 / 2.6

// New Lower Divisions (Yellow Lines)
lowDiv3  = dma350 / 3
lowDiv5  = dma350 / 5
lowDiv8  = dma350 / 8
lowDiv13 = dma350 / 13
lowDiv21 = dma350 / 21

// --- Plotting ---

// Plotting Upper Lines
plot(dma111, color=color.white, title="111 SMA")
plot(dma350, color=color.orange, title="350 SMA")
plot(goldenRatio, color=color.green, title="Golden Ratio")
plot(fib2, color=color.red, title="2x Multiplier")
plot(fib3, color=color.purple, title="3x Multiplier")
plot(fib5, color=color.gray, title="5x Multiplier")
plot(fib8, color=color.gray, title="8x Multiplier")
plot(fib13, color=color.gray, title="13x Multiplier")
plot(fib21, color=color.gray, title="21x Multiplier")

// Plotting All Lower Lines (Yellow)
plot(negFib1_4, color=color.yellow, title="Low 1.4")
plot(negFib1_6, color=color.yellow, title="Low 1.6")
plot(negFib2, color=color.yellow, title="Low 2.0")
plot(negFib2_6, color=color.yellow, title="Low 2.6")
plot(lowDiv3,  color=color.yellow, title="Div 3")
plot(lowDiv5,  color=color.yellow, title="Div 5")
plot(lowDiv8,  color=color.yellow, title="Div 8")
plot(lowDiv13, color=color.yellow, title="Div 13")
plot(lowDiv21, color=color.yellow, title="Div 21")

// --- Signal Logic ---

// Original Bottom Signals
bottom1 = ta.crossunder(dma111, negFib1_4)
bottom2 = ta.crossunder(dma111, negFib1_6)
bottom3 = ta.crossunder(dma111, negFib2)
bottom4 = ta.crossunder(dma111, negFib2_6)

// New Bottom Signals for additional divisions
bottom5 = ta.crossunder(dma111, lowDiv3)
bottom6 = ta.crossunder(dma111, lowDiv5)
bottom7 = ta.crossunder(dma111, lowDiv8)
bottom8 = ta.crossunder(dma111, lowDiv13)
bottom9 = ta.crossunder(dma111, lowDiv21)

// Top Signal
topSignal = ta.crossover(dma111, fib2)

// --- Shape Plotting (Visual Signals) ---

// Long Signals (Green Triangles)
plotshape(bottom1, title="Long 1.4", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)
plotshape(bottom2, title="Long 1.6", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)
plotshape(bottom3, title="Long 2.0", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)
plotshape(bottom4, title="Long 2.6", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)
plotshape(bottom5, title="Long Div 3", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)
plotshape(bottom6, title="Long Div 5", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)
plotshape(bottom7, title="Long Div 8", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)
plotshape(bottom8, title="Long Div 13", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)
plotshape(bottom9, title="Long Div 21", style=shape.triangleup, location=location.belowbar, color=color.lime, text="LONG", textcolor=color.lime, size=size.small)

// Short Signal (Red Triangle)
plotshape(topSignal, title="Short", style=shape.triangledown, location=location.abovebar, color=color.red, text="SHORT", textcolor=color.red, size=size.small)
````
