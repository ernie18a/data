# Open Session Suite  EMA, VWAP & MTF Bias

- url: https://www.tradingview.com/script/dX1Su5zU-Open-Session-Suite-EMA-VWAP-MTF-Bias/
- type: indicator
- pine_id: PUB;fa4eca196e444e48be05ae062f161f3b
- version: 1.0

## Description

A clean, multi-layered trading suite built for intraday traders. 
Designed around session-based trading with confluent signals.

FEATURES
- EMA 20, 50 and 200 plotted with configurable lengths
- Session VWAP as a dynamic support/resistance reference
- Confluence crossover arrows — EMA50 cross filtered by VWAP 
  and EMA200 bias
- Multi-timeframe bias table showing H1 and M15 EMA50 bias 
  at a glance without leaving your current chart
- London and New York session highlighting with configurable 
  times and colours
- Smart alerts with dynamic messages including live RSI 
  and EMA50 values

INPUTS
All key settings are configurable from the indicator panel — 
EMA lengths, session times, and session colours.

ALERTS
Set a single alert on this indicator and select 
"Any alert() function call" to receive bullish, bearish, 
and mixed bias notifications with live price context.

Built in Pine Script v6.

## Source Code

````pine
//@version=6
indicator("My Custom Open Session Suite", overlay=true)

// 1. INPUTS: This lets you change the lengths later without touching the code
ema1_length = input.int(20, title="Short EMA Length")
ema2_length = input.int(50, title="Medium EMA Length")
ema3_length = input.int(200, title="Long EMA Length")
londonsessiontime = input.session("0800-1600", title="London session")
londonsessioncolor = input.color(color.gray, title="London color")
newyorksessiontime = input.session("0930-1600", title="New York session")
newyorksessioncolor = input.color(color.gray, title="New York color")

// 2. CALCULATIONS: Telling the computer to calculate the data
ema20 = ta.ema(close, ema1_length)
ema50 = ta.ema(close, ema2_length)
ema200 = ta.ema(close, ema3_length)
myVwap = ta.vwap
rsiValue = ta.rsi(close, 14)
//avgVolume = ta.sma(volume, 20)
H1_EMA50 = request.security(syminfo.tickerid, "60", ta.ema(close[1], ema2_length), lookahead = barmerge.lookahead_off)
M15_EMA50 = request.security(syminfo.tickerid, "15", ta.ema(close[1], ema2_length), lookahead = barmerge.lookahead_off)

// 3. Functions
getSessionColor(sessionTime, timezone, sessionColor) =>
    isInSession = not na(time(timeframe.period, sessionTime, timezone))
    isInSession ? color.new(sessionColor, 85) : na

getBiasText(isAbove) =>
    isAbove ? "BULL" : "BEAR"

getBiasColor(isAbove) =>
    isAbove ? color.green : color.red

// 4. PLOTTING: Drawing the lines onto your live chart
plot(ema20, color=color.blue, title="EMA 20", linewidth=1)
plot(ema50, color=color.orange, title="EMA 50", linewidth=1)
plot(ema200, color=color.red, title="EMA 200", linewidth=2)
plot(myVwap, color=color.purple, title="Session VWAP", linewidth=2, style=plot.style_stepline)

// 5. Alerts
aboveEma50 = close > ema50
belowEma50 = close < ema50
aboveEma200 = close > ema200
belowEma200 = close < ema200
aboveVwap = close > myVwap
belowVwap = close < myVwap
//aboveAvgVolume = volume > avgVolume
//belowAvgVolume = volume < avgVolume
//aboversi50 = rsiValue > 50
//belowrsi50 = rsiValue < 50
aboveM15_EMA50 = close > M15_EMA50
aboveH1_EMA50 = close > H1_EMA50
belowM15_EMA50 = close < M15_EMA50
belowH1_EMA50 = close < H1_EMA50

if aboveEma50 and aboveVwap and aboveEma200
    alert("Bullish — price above EMA50, VWAP and EMA200 on " + syminfo.ticker +  " | RSI: " + str.tostring(rsiValue) + " | EMA50: " + str.tostring(ema50), alert.freq_once_per_bar_close)

if belowEma50 and belowVwap and belowEma200
    alert("Bearish — price below EMA50, VWAP and EMA200 on " + syminfo.ticker +  " | RSI: " + str.tostring(rsiValue) + " | EMA50: " + str.tostring(ema50), alert.freq_once_per_bar_close)

if (aboveEma50 and belowVwap) or (belowEma50 and aboveVwap)
    alert("Mixed — price between EMA50 and VWAP on " + syminfo.ticker + " | RSI: " + str.tostring(rsiValue) + " | EMA50: " + str.tostring(ema50), alert.freq_once_per_bar_close)

// 6. Visuals Signals
//plotshape(low < ema50 and low < myVwap, style=shape.circle, location=location.belowbar, color=color.red, size=size.tiny)
//plotshape(low > ema50 and high > myVwap, style=shape.circle, location=location.abovebar, color=color.green, size=size.tiny)
plotshape(ta.crossover(close,ema50) and aboveVwap and aboveEma200, style=shape.arrowup, location=location.abovebar, color=color.green, size=size.small)
plotshape(ta.crossunder(close,ema50) and belowVwap and belowEma200, style=shape.arrowdown, location=location.belowbar, color=color.red, size=size.small)

// 7. Background
// bgcolor(aboveEma200 ? color.new(color.green, 90) : na)
// bgcolor(belowEma200 ? color.new(color.red, 90) : na)

// 8. Bias Table
var biasTable = table.new(position.top_right, 2, 2)
table.cell(biasTable, 0, 0, "H1", text_color=color.white, bgcolor=color.gray)
table.cell(biasTable, 1, 0, "M15", text_color=color.white, bgcolor=color.gray)
table.cell(biasTable, 0, 1, getBiasText(aboveH1_EMA50), text_color=color.white, bgcolor=getBiasColor(aboveH1_EMA50))
table.cell(biasTable, 1, 1, getBiasText(aboveM15_EMA50), text_color = color.white, bgcolor=getBiasColor(aboveM15_EMA50))

// 9. Session
bgcolor(getSessionColor(londonsessiontime, "Europe/London", londonsessioncolor))
bgcolor(getSessionColor(newyorksessiontime, "America/New_York", newyorksessioncolor))
````
