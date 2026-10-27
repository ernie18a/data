# Momentum Ignition System PRO+

- url: https://www.tradingview.com/script/SYHYXi8k-Momentum-Ignition-System-PRO/
- type: indicator
- pine_id: PUB;894632a7930c4047ad39127bfe4e288a
- version: 1.0

## Description

🚀 Momentum Ignition System PRO+

A hybrid momentum-trend indicator designed for traders who focus on:

Volatility Contraction Patterns (VCP)
Momentum ignition setups
EMA trend structure
Institutional accumulation zones
Breakout trading

This indicator combines trend, momentum, anchored VWAP, volatility, and market structure into a single clean framework for identifying high-probability breakout candidates.

🔥 Key Features
✅ RSI Momentum Ignition Engine

Uses:

RSI(14)
WMA(200) of RSI

The indicator plots:

🟢 Bullish arrows when RSI crosses ABOVE WMA(200)
🔴 Bearish arrows when RSI crosses BELOW WMA(200)

This helps identify:

momentum regime shifts
early trend ignition
potential breakout expansion phases
✅ Multi-EMA Trend Structure

Includes customizable:

EMA 10
EMA 20
EMA 50
EMA 200

Useful for:

trend alignment
pullback entries
trend continuation
institutional trend structure
✅ Bullish / Bearish EMA Cloud

Dynamic cloud between EMA20 & EMA50:

🟢 Green Cloud → bullish trend structure
🔴 Red Cloud → bearish trend structure

Helps visualize:

trend health
base formation
momentum alignment
✅ Anchored VWAP

Custom Anchored VWAP with selectable anchor periods:

Session
Weekly
Monthly

Anchored VWAP helps identify:

institutional average price
support/resistance
accumulation zones
fair value areas
✅ ADR% (Average Daily Range)

Displays customizable ADR% table with dynamic coloring.

Color Logic:

🟢 Green → high expansion potential
🟠 Orange → moderate volatility
🔴 Red → low volatility

Useful for:

breakout potential
volatility expansion
position sizing
🎯 Ideal Usage

Best suited for:

Swing Trading
Momentum Trading
Breakout Trading
VCP Setups
Qullamaggie-style setups
Minervini-style trend continuation setups

## Source Code

````pine
//@version=5
indicator("Momentum Ignition System PRO+", overlay=true)

//====================================================
// INPUTS
//====================================================

// RSI SETTINGS
rsiLength      = input.int(14, title="RSI Length")
rsiWmaLength   = input.int(200, title="RSI WMA Length")

// EMA SETTINGS
ema10Length    = input.int(10, title="EMA 10")
ema20Length    = input.int(20, title="EMA 20")
ema50Length    = input.int(50, title="EMA 50")
ema200Length   = input.int(200, title="EMA 200")

// ADR SETTINGS
adrLength = input.int(14, title="ADR Length")

// ADR TABLE POSITION
adrPosition = input.string(
     "Top Right",
     title="ADR Table Position",
     options = [
         "Top Left",
         "Top Right",
         "Bottom Left",
         "Bottom Right"
     ])

// CLOUD SETTINGS
showCloud = input.bool(true, title="Show EMA 20/50 Cloud")

// ANCHORED VWAP SETTINGS
anchorType = input.string(
     "Session",
     title="Anchored VWAP",
     options=["Session", "Week", "Month"])

//====================================================
// CALCULATIONS
//====================================================

// RSI
rsiValue = ta.rsi(close, rsiLength)
rsiWMA   = ta.wma(rsiValue, rsiWmaLength)

// RSI CROSS
bullCross = ta.crossover(rsiValue, rsiWMA)
bearCross = ta.crossunder(rsiValue, rsiWMA)

// EMAs
ema10  = ta.ema(close, ema10Length)
ema20  = ta.ema(close, ema20Length)
ema50  = ta.ema(close, ema50Length)
ema200 = ta.ema(close, ema200Length)

//====================================================
// ANCHORED VWAP
//====================================================

newSession = ta.change(time("D"))
newWeek    = ta.change(time("W"))
newMonth   = ta.change(time("M"))

isNewAnchor =
     anchorType == "Session" ? newSession :
     anchorType == "Week" ? newWeek :
     newMonth

var float cumulativePV = na
var float cumulativeVol = na

if isNewAnchor
    cumulativePV := hlc3 * volume
    cumulativeVol := volume
else
    cumulativePV += hlc3 * volume
    cumulativeVol += volume

anchoredVWAP = cumulativePV / cumulativeVol

//====================================================
// ADR %
//====================================================

dailyRange = ((high - low) / low) * 100
adrPercent = ta.sma(dailyRange, adrLength)

//====================================================
// TREND CLOUD
//====================================================

// Bullish/Bearish Trend
bullTrend = ema20 > ema50
bearTrend = ema20 < ema50

//====================================================
// EMA PLOTS
//====================================================

plot(
     ema10,
     title="EMA 10",
     color=color.yellow,
     linewidth=2)

p1 = plot(
     ema20,
     title="EMA 20",
     color=color.orange,
     linewidth=2)

p2 = plot(
     ema50,
     title="EMA 50",
     color=color.blue,
     linewidth=2)

plot(
     ema200,
     title="EMA 200",
     color=color.red,
     linewidth=2)

//====================================================
// CLOUD FILL
//====================================================

fill(
     p1,
     p2,
     color = showCloud ?
         bullTrend ?
             color.new(color.green, 82) :
             color.new(color.red, 82)
         : na,
     title="EMA Cloud")

//====================================================
// ANCHORED VWAP PLOT
//====================================================

plot(
     anchoredVWAP,
     title="Anchored VWAP",
     color=color.purple,
     linewidth=3)

//====================================================
// RSI CROSS ARROWS
//====================================================

// BULLISH ARROW
plotshape(
     bullCross,
     title="Bullish RSI Cross",
     style=shape.arrowup,
     location=location.belowbar,
     color=color.lime,
     size=size.small)

// BEARISH ARROW
plotshape(
     bearCross,
     title="Bearish RSI Cross",
     style=shape.arrowdown,
     location=location.abovebar,
     color=color.red,
     size=size.small)

//====================================================
// ADR TABLE POSITION LOGIC
//====================================================

tablePos =
     adrPosition == "Top Left" ? position.top_left :
     adrPosition == "Bottom Left" ? position.bottom_left :
     adrPosition == "Bottom Right" ? position.bottom_right :
     position.top_right

//====================================================
// ADR TABLE
//====================================================

var table adrTable = table.new(tablePos, 1, 1)

if barstate.islast

    // ADR Dynamic Color
    adrColor =
         adrPercent > 5 ? color.new(color.green, 10) :
         adrPercent > 3 ? color.new(color.orange, 10) :
         color.new(color.red, 10)

    table.cell(
         adrTable,
         0,
         0,
         "ADR% : " + str.tostring(adrPercent, "#.##"),
         text_color=color.white,
         bgcolor=adrColor)

//====================================================
// OPTIONAL BAR COLORING
//====================================================

barcolor(
     bullTrend ? color.new(color.green, 75) :
     bearTrend ? color.new(color.red, 75) :
     na)

//====================================================
// ALERTS
//====================================================

alertcondition(
     bullCross,
     title="Bullish RSI Cross",
     message="RSI 14 crossed ABOVE WMA 200")

alertcondition(
     bearCross,
     title="Bearish RSI Cross",
     message="RSI 14 crossed BELOW WMA 200")
````
