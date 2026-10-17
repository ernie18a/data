# Kane Elephant Bar Alert

- url: https://www.tradingview.com/script/rYio4Tb2-Kane-Elephant-Bar-Alert/
- type: indicator
- pine_id: PUB;df6855d2516f4e91a1a0d94d76f54bdb
- version: 1.0

## Description

Kane Elephant Bar Alert

A real-time momentum candle detection indicator designed to identify powerful institutional-style elephant bars as they are forming.

Features:

Detects large momentum candles based on body size and candle structure
Real-time pulsing live candle effect for active elephant bars
Customizable pulse colors for bullish and bearish candles
Optional neon arrow markers for confirmed elephant bars
Built-in TradingView alert support for phone and desktop notifications
Clean chart design with optional visual elements

Detection Logic:

Candle body must exceed the recent average body size
Candle body must dominate the total candle range
Identifies strong directional momentum and expansion bars

Visual Features:

Bullish elephant candles pulse in a customizable neon bullish color
Bearish elephant candles pulse in a customizable neon bearish color
Pulse effect only appears on the actively forming live candle
Neon arrows can be enabled or disabled independently

Designed for:

Momentum traders
Scalpers
Futures traders
Forex traders
Crypto traders
Intraday trend continuation setups

Works especially well on lower timeframes where early momentum recognition is critical.

## Source Code

````pine
//@version=5
indicator("Kane Elephant Bar Alert", overlay=true)

// Inputs
emaLen = input.int(20, "20 MA Length")
lookback = input.int(20, "Average Body Lookback")
bodyMult = input.float(2.0, "Body Size Multiplier", step=0.1)
minBodyPercent = input.float(65.0, "Minimum Body % of Full Candle", step=1.0)

showArrows = input.bool(true, "Show Elephant Bar Arrows")
showPulse = input.bool(true, "Show Pulsing Live Elephant Candle")

arrowColor = input.color(color.rgb(255, 20, 147), "Arrow Color")

// NEW: Custom pulse colors
bullPulseBaseColor = input.color(color.rgb(0, 255, 80), "Bull Pulse Color")
bearPulseBaseColor = input.color(color.rgb(255, 0, 40), "Bear Pulse Color")

// Calculations
ema20 = ta.ema(close, emaLen)

body = math.abs(close - open)
barRange = high - low
avgBody = ta.sma(body, lookback)
bodyPercent = barRange > 0 ? body / barRange * 100 : 0

bullElephant = close > open and body > avgBody * bodyMult and bodyPercent >= minBodyPercent
bearElephant = close < open and body > avgBody * bodyMult and bodyPercent >= minBodyPercent

// Live bar only
isLiveBar = barstate.islast and not barstate.isconfirmed

// Pulse strength
pulse = math.abs(math.sin(timenow / 500.0))
pulseTransparency = 75 - int(pulse * 65)

// Pulsing candle colors
bullPulseColor = color.new(bullPulseBaseColor, pulseTransparency)
bearPulseColor = color.new(bearPulseBaseColor, pulseTransparency)

liveBullPulse = showPulse and isLiveBar and bullElephant
liveBearPulse = showPulse and isLiveBar and bearElephant

barcolor(liveBullPulse ? bullPulseColor : liveBearPulse ? bearPulseColor : na)

// Optional normal arrows, neon pink by default
plotshape(showArrows and bullElephant, title="Bullish Elephant Arrow", style=shape.triangleup, location=location.belowbar, color=arrowColor, size=size.small)
plotshape(showArrows and bearElephant, title="Bearish Elephant Arrow", style=shape.triangledown, location=location.abovebar, color=arrowColor, size=size.small)

// Hidden 20 EMA
plot(ema20, "20 EMA", display=display.none)

// Alerts
alertcondition(bullElephant, title="Bullish Elephant Bar", message="Bullish elephant bar forming on {{ticker}} {{interval}}")
alertcondition(bearElephant, title="Bearish Elephant Bar", message="Bearish elephant bar forming on {{ticker}} {{interval}}")
alertcondition(bullElephant or bearElephant, title="Any Elephant Bar", message="Elephant bar forming on {{ticker}} {{interval}}")
````
