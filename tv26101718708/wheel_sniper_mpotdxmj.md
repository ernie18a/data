# Wheel Sniper

- url: https://www.tradingview.com/script/MpOTDxMj-Wheel-Sniper/
- type: indicator
- pine_id: PUB;281b8f06bf27476ea37295c54f06a001
- version: 1.0

## Description

Wheel Sniper identifies high-probability zones to sell cash-secured puts on dips and covered calls on strength using Bollinger Bands and RSI reversals.

Blue signals highlight potential bottoming areas, while red signals mark extended rallies that may stall.

Designed for wheel strategy traders who want better timing—not more signals.

(my first attempt at creating an indicator)

## Source Code

````pine
//@version=5
indicator("Wheel Signal (CSP + Covered Call)", overlay=true)

// Inputs
rsiLength = input.int(14, "RSI Length")
cspRsiTrigger = input.float(35, "CSP RSI Cross Up Level")
ccRsiTrigger = input.float(65, "CC RSI Cross Down Level")
bbLength = input.int(20, "BB Length")
bbMult = input.float(2.0, "BB Multiplier")
cspLookbackBars = input.int(3, "CSP Bars Since Lower BB Touch")
ccLookbackBars = input.int(3, "CC Bars Since Upper BB Touch")
useTrendFilter = input.bool(false, "Use 200 SMA Filter?")
showBBs = input.bool(true, "Show Bollinger Bands?")
showSMA = input.bool(false, "Show 200 SMA?")

// Core calculations
rsiValue = ta.rsi(close, rsiLength)

basis = ta.sma(close, bbLength)
dev = bbMult * ta.stdev(close, bbLength)
upperBand = basis + dev
lowerBand = basis - dev

sma200 = ta.sma(close, 200)

// CSP logic
touchedLower = low < lowerBand
recentLowerTouch = ta.barssince(touchedLower) <= cspLookbackBars
rsiCrossUp = ta.crossover(rsiValue, cspRsiTrigger)
cspTrendOK = not useTrendFilter or close > sma200
cspSignal = recentLowerTouch and rsiCrossUp and cspTrendOK

// Covered call logic
touchedUpper = high > upperBand
recentUpperTouch = ta.barssince(touchedUpper) <= ccLookbackBars
rsiCrossDown = ta.crossunder(rsiValue, ccRsiTrigger)
ccTrendOK = not useTrendFilter or close > sma200
ccSignal = recentUpperTouch and rsiCrossDown and ccTrendOK

// Plots
plot(showBBs ? upperBand : na, title="Upper BB", color=color.red)
plot(showBBs ? basis : na, title="BB Basis", color=color.gray)
plot(showBBs ? lowerBand : na, title="Lower BB", color=color.blue)
plot(showSMA ? sma200 : na, title="200 SMA", color=color.white)

plotshape(cspSignal, title="CSP Signal", style=shape.triangleup, location=location.belowbar, size=size.small, color=color.blue, text="CSP")
plotshape(ccSignal, title="Covered Call Signal", style=shape.triangledown, location=location.abovebar, size=size.small, color=color.red, text="CC")

// Alert conditions
alertcondition(cspSignal, title="CSP Entry Alert", message="CSP setup: recent lower BB touch + RSI cross up")
alertcondition(ccSignal, title="Covered Call Alert", message="Covered Call setup: recent upper BB touch + RSI cross down")
````
