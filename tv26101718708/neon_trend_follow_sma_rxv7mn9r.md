# Neon Trend Follow + SMA

- url: https://www.tradingview.com/script/Rxv7MN9R-Neon-Trend-Follow-SMA/
- type: indicator
- pine_id: PUB;c62c0edb98a0457e90d69ce75bb04944
- version: 1.0

## Description

Neon Trend Follow + SMA

trending indicator gives buy and sells based on timeframe

## Source Code

````pine
//@version=6
indicator("Neon Trend Follow + SMA", shorttitle="NTSMA", overlay=true, max_labels_count=500)

// Inputs
src = input.source(close, "Source")
atrLen = input.int(10, "ATR Length", minval=1)
atrMult = input.float(3.0, "ATR Multiplier", minval=0.1, step=0.1)
smaLen = input.int(50, "SMA Length", minval=1)
fastLen = input.int(21, "Fast EMA Length", minval=1)
showCloud = input.bool(true, "Show Trend Cloud")
showSignals = input.bool(true, "Show Buy/Sell Signals")
colorBars = input.bool(true, "Color Candles")
showDash = input.bool(true, "Show Dashboard")

// Core calculations
atr = ta.atr(atrLen)
fastEma = ta.ema(src, fastLen)
sma = ta.sma(src, smaLen)

upperBand = src + atr * atrMult
lowerBand = src - atr * atrMult

var float trendLine = na
var int trend = 1

prevTrendLine = nz(trendLine[1], lowerBand)

if trend == 1
    trendLine := math.max(lowerBand, prevTrendLine)
    if close < trendLine
        trend := -1
        trendLine := upperBand
else
    trendLine := math.min(upperBand, prevTrendLine)
    if close > trendLine
        trend := 1
        trendLine := lowerBand

bullish = trend == 1
bearish = trend == -1

buySignal = bullish and trend[1] == -1
sellSignal = bearish and trend[1] == 1

// Colors
bullColor = color.rgb(0, 255, 180)
bearColor = color.rgb(255, 45, 100)
smaColor = color.rgb(255, 220, 80)
emaColor = color.rgb(90, 170, 255)
panelColor = color.rgb(25, 25, 35)

trendColor = bullish ? bullColor : bearColor
smaBiasColor = close > sma ? bullColor : bearColor

// Plots
trendPlot = plot(trendLine, "Trend Trail", color=trendColor, linewidth=3)
smaPlot = plot(sma, "SMA", color=smaColor, linewidth=2)
plot(fastEma, "Fast EMA", color=emaColor, linewidth=1)

// Cloud
fill(trendPlot, smaPlot, color=showCloud ? color.new(trendColor, 82) : na, title="Trend Cloud")

// Candle coloring
barcolor(colorBars ? trendColor : na)

// Signals
plotshape(showSignals and buySignal, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.small, text="BUY", textcolor=color.white)
plotshape(showSignals and sellSignal, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, text="SELL", textcolor=color.white)

// Background glow
bgcolor(bullish ? color.new(bullColor, 94) : color.new(bearColor, 94))

// Alerts
alertcondition(buySignal, title="Buy Alert", message="NTSMA: BUY signal")
alertcondition(sellSignal, title="Sell Alert", message="NTSMA: SELL signal")

// Dashboard
var table dash = table.new(position.top_right, 2, 2, border_width=1)

if barstate.islast and showDash
    table.cell(dash, 0, 0, "Trend", text_color=color.white, bgcolor=panelColor)
    table.cell(dash, 1, 0, bullish ? "BULLISH" : "BEARISH", text_color=color.white, bgcolor=trendColor)
    table.cell(dash, 0, 1, "SMA Bias", text_color=color.white, bgcolor=panelColor)
    table.cell(dash, 1, 1, close > sma ? "Above SMA" : "Below SMA", text_color=color.white, bgcolor=smaBiasColor)
````
