# RSI T-Bands

- url: https://www.tradingview.com/script/uKmuHQfA-RSI-T-Bands/
- type: indicator
- pine_id: PUB;793256a60d0e471fb01db62560d87440
- version: 3.0

## Description

Overview
RSI T-Bands is a trend-following indicator that wraps RSI with upper and lower bands built from standard deviation. Instead of treating RSI as a simple overbought/oversold oscillator, it uses the position of these bands relative to the 50 midline to define a bullish or bearish trend state. Bands expand and contract with RSI volatility, making the indicator adaptive to changing momentum conditions.

• Bullish state: begins when the lower RSI band moves above 50.
• Bearish state: begins when the upper RSI band moves below 50

How to use
Candle coloring reflects the current trend state (green = bullish, red = bearish).

The upper and lower RSI bands act as dynamic thresholds around RSI.

The dashed 50 midline is the trend decision boundary.

Alerts
The script includes two alert conditions:

RSI T-Bands Bullish: triggers when the trend state flips from bearish to bullish.

RSI T-Bands Bearish: triggers when the trend state flips from bullish to bearish.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nick_Joan
//@version=6
indicator(title="RSI T-Bands | NickJoan", precision=2)

// ─── Groups ───────────────────────────────────────────────────────────────────
var string gCalc   = "Calculation Settings"
var string gColors = "Color Settings"

// ─── Inputs ───────────────────────────────────────────────────────────────────
rsiLen      = input.int(18, minval=1, title="RSI Length", group=gCalc)
sdLen       = input.int(33, minval=1, title="StdDev Period", group=gCalc)
upperSdMult = input.float(0.83, minval=0.1, title="Upper Band StdDev Multiplier", step=0.01, group=gCalc)
lowerSdMult = input.float(1.08, minval=0.1, title="Lower Band StdDev Multiplier", step=0.01, group=gCalc)

bullColor    = input.color(color.aqua, "Bullish Candle Color", group=gColors)
bearColor    = input.color(color.olive, "Bearish Candle Color", group=gColors)
neutralColor = input.color(color.new(color.gray, 60), "Neutral Band Color", group=gColors)

// ─── Calculations ─────────────────────────────────────────────────────────────
rsi = ta.rsi(close, rsiLen)
sd = ta.stdev(rsi, sdLen)
upperBand = rsi + upperSdMult * sd
lowerBand = rsi - lowerSdMult * sd

// ─── Signal Logic ─────────────────────────────────────────────────────────────
rsilong = lowerBand > 50
rsishort = upperBand < 50

var bool bullish = false
if rsilong
    bullish := true
if rsishort
    bullish := false

biasBullish = bullish and not bullish[1]
biasBearish = not bullish and bullish[1]

trendColor = bullish ? bullColor : bearColor

// ─── Plots ────────────────────────────────────────────────────────────────────
rsiPlot = plot(rsi, title="RSI", color=color.rgb(0, 0, 255, 60), linewidth=1, display = display.none)

plot(upperBand, title="Upper Trend Band", color=bullish ? neutralColor : bearColor, linewidth=1)
plot(lowerBand, title="Lower Trend Band", color=bullish ? bullColor : neutralColor, linewidth=1)

overboughtLevel = hline(70, "Overbought Level", color=#787B86)
midlineLevel    = hline(50, "Midline", color=color.new(#787B86, 50))
oversoldLevel   = hline(30, "Oversold Level", color=#787B86)

fill(overboughtLevel, oversoldLevel, color=color.rgb(126, 87, 194, 90), title="RSI Zone Fill")

upperFillPlot = plot(70, title="Upper Fill Level", color=na, editable=false, display=display.none)
lowerFillPlot = plot(30, title="Lower Fill Level", color=na, editable=false, display=display.none)


plotcandle(
     open, high, low, close,
     title="Trend Candles",
     color=trendColor,
     wickcolor=trendColor,
     bordercolor=trendColor,
     force_overlay=true,
     display=display.pane)

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(biasBullish, title="RSI T-Bands Bullish", message="RSI T-Bands are Bullish on {{ticker}} {{interval}}")
alertcondition(biasBearish, title="RSI T-Bands Bearish", message="RSI T-Bands are Bearish on {{ticker}} {{interval}}")
````
