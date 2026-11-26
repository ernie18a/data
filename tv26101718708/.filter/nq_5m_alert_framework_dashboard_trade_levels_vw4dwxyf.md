# NQ 5m Alert Framework Dashboard + Trade Levels

- url: https://www.tradingview.com/script/vW4dwXyF-NQ-5m-Alert-Framework-Dashboard-Trade-Levels/
- type: indicator
- pine_id: PUB;5688d4dea0de464ea9dfbdb9f3586433
- version: 1.0

## Description

NQ 5m Alert Framework Dashboard + Trade Levels

This indicator is built for traders who want a cleaner way to read NQ/MNQ breakout setups on the 5-minute chart.

It combines:

• fast/slow EMA trend bias
• VWAP position
• dynamic breakout high and breakdown low levels
• early setup markers near the breakout zone
• breakout and breakdown trigger labels
• an on-chart dashboard showing market bias and projected trade levels

What it shows

• Bullish / bearish bias
  • based on EMA structure and price vs VWAP
• Setup markers
  • yellow “Set” markers when price is approaching a breakout or breakdown zone
• Breakout triggers
  • BO for breakout up
  • BD for breakdown
• Breakout levels
  • green line = breakout high
  • red line = breakdown low
• Dashboard
  • Bias
  • Setup status
  • Trigger status
  • EMA state
  • VWAP state
  • projected entry, SL, TP1, TP2, TP3

How to read it

• Set = conditions are lining up, get ready
• BO / BD = actual breakout or breakdown trigger
• background color
  • green = bullish bias
  • red = bearish bias

Best use case

This tool is designed for:

• NQ / MNQ traders
• 5-minute breakout traders
• intraday traders who want visual structure and quick decision support

Notes

• This is a framework, not financial advice
• projected trade levels are based on the fixed point settings in the script
• users should test and adjust stop and target distances for their own market conditions and risk tolerance

## Source Code

````pine
//@version=5
indicator("NQ 5m Alert Framework Dashboard + Trade Levels", overlay=true)

// Inputs
fastLen = input.int(9, "Fast EMA")
slowLen = input.int(21, "Slow EMA")
breakoutLookback = input.int(10, "Breakout Lookback")
setupBuffer = input.float(5.0, "Setup Buffer Points")
showEma = input.bool(true, "Show EMAs")
showVwap = input.bool(true, "Show VWAP")
showBreakoutLevels = input.bool(true, "Show Breakout Levels")
showBackground = input.bool(true, "Show Bias Background")
showDashboard = input.bool(true, "Show Dashboard")

stopLossPts = input.float(20.0, "Stop Loss Points")
tp1Pts = input.float(10.0, "TP1 Points")
tp2Pts = input.float(20.0, "TP2 Points")
tp3Pts = input.float(30.0, "TP3 Points")

// Indicators
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
vwapValue = ta.vwap(close)

highestHigh = ta.highest(high, breakoutLookback)
lowestLow = ta.lowest(low, breakoutLookback)

breakoutHigh = highestHigh[1]
breakoutLow = lowestLow[1]

// Conditions
bullFlip = ta.crossover(emaFast, emaSlow)
bearFlip = ta.crossunder(emaFast, emaSlow)

reclaimVwap = ta.crossover(close, vwapValue)
loseVwap = ta.crossunder(close, vwapValue)

bullBias = emaFast > emaSlow and close > vwapValue
bearBias = emaFast < emaSlow and close < vwapValue

longSetup = bullBias and close >= breakoutHigh - setupBuffer and close < breakoutHigh
shortSetup = bearBias and close <= breakoutLow + setupBuffer and close > breakoutLow

breakoutUp = ta.crossover(high, breakoutHigh)
breakoutDown = ta.crossunder(low, breakoutLow)



// Trade levels
var float entryPrice = na
var float stopPrice = na
var float tp1Price = na
var float tp2Price = na
var float tp3Price = na
var string tradeSide = "NONE"

if breakoutUp
    entryPrice := breakoutHigh
    stopPrice := entryPrice - stopLossPts
    tp1Price := entryPrice + tp1Pts
    tp2Price := entryPrice + tp2Pts
    tp3Price := entryPrice + tp3Pts
    tradeSide := "LONG"

if breakoutDown
    entryPrice := breakoutLow
    stopPrice := entryPrice + stopLossPts
    tp1Price := entryPrice - tp1Pts
    tp2Price := entryPrice - tp2Pts
    tp3Price := entryPrice - tp3Pts
    tradeSide := "SHORT"

// Background
bgcolor(showBackground ? bullBias ? color.new(color.green, 90) : bearBias ? color.new(color.red, 90) : na : na)

// Plots
plot(showEma ? emaFast : na, color=color.lime, title="EMA 9", linewidth=2)
plot(showEma ? emaSlow : na, color=color.orange, title="EMA 21", linewidth=2)
plot(showVwap ? vwapValue : na, color=color.aqua, title="VWAP", linewidth=2)

plot(showBreakoutLevels ? breakoutHigh : na, color=color.green, title="Breakout High", linewidth=2, style=plot.style_linebr)
plot(showBreakoutLevels ? breakoutLow : na, color=color.red, title="Breakout Low", linewidth=2, style=plot.style_linebr)

// Markers
plotshape(bullFlip, title="Bull Flip", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="Bull")
plotshape(bearFlip, title="Bear Flip", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="Bear")

plotshape(longSetup, title="Long Setup", style=shape.circle, location=location.belowbar, color=color.yellow, size=size.tiny, text="Set")
plotshape(shortSetup, title="Short Setup", style=shape.circle, location=location.abovebar, color=color.yellow, size=size.tiny, text="Set")

plotshape(breakoutUp, title="Breakout Up", style=shape.labelup, location=location.belowbar, color=color.green, text="BO", textcolor=color.white, size=size.small)
plotshape(breakoutDown, title="Breakout Down", style=shape.labeldown, location=location.abovebar, color=color.red, text="BD", textcolor=color.white, size=size.small)

// Dashboard values
biasText = bullBias ? "Bullish" : bearBias ? "Bearish" : "Neutral"
setupText = longSetup ? "Long Setup" : shortSetup ? "Short Setup" : "None"
triggerText = breakoutUp ? "Breakout Up" : breakoutDown ? "Breakdown" : "Waiting"
emaText = emaFast > emaSlow ? "EMA Bull" : emaFast < emaSlow ? "EMA Bear" : "EMA Flat"
vwapText = close > vwapValue ? "Above VWAP" : close < vwapValue ? "Below VWAP" : "At VWAP"

entryText = na(entryPrice) ? "N/A" : str.tostring(entryPrice, format.mintick)
slText = na(stopPrice) ? "N/A" : str.tostring(stopPrice, format.mintick)
tp1Text = na(tp1Price) ? "N/A" : str.tostring(tp1Price, format.mintick)
tp2Text = na(tp2Price) ? "N/A" : str.tostring(tp2Price, format.mintick)
tp3Text = na(tp3Price) ? "N/A" : str.tostring(tp3Price, format.mintick)

dashboardText = str.format(
     "NQ DASHBOARD\nBias: {0}\nSetup: {1}\nTrigger: {2}\nEMA: {3}\nVWAP: {4}\nTrade Side: {5}\nEntry: {6}\nSL: {7}\nTP1: {8}\nTP2: {9}\nTP3: {10}",
     biasText, setupText, triggerText, emaText, vwapText, tradeSide, entryText, slText, tp1Text, tp2Text, tp3Text)

dashboardColor = bullBias ? color.green : bearBias ? color.red : color.gray

var table dash = table.new(position.top_right, 1, 1, border_width=1)
if showDashboard
    table.cell(dash, 0, 0, dashboardText, text_color=color.white, bgcolor=color.new(dashboardColor, 70), text_size=size.small)

// Alerts
alertcondition(bullFlip, title="EMA Bull Flip", message="NQ ALERT: EMA bull flip on 5m")
alertcondition(bearFlip, title="EMA Bear Flip", message="NQ ALERT: EMA bear flip on 5m")
alertcondition(reclaimVwap, title="VWAP Reclaim", message="NQ ALERT: Reclaimed VWAP on 5m")
alertcondition(loseVwap, title="VWAP Loss", message="NQ ALERT: Lost VWAP on 5m")
alertcondition(longSetup, title="Long Setup Near Breakout", message="NQ ALERT: Long setup near breakout on 5m")
alertcondition(shortSetup, title="Short Setup Near Breakdown", message="NQ ALERT: Short setup near breakdown on 5m")
alertcondition(breakoutUp, title="Breakout Up", message="NQ ALERT: Breakout above recent high on 5m")
alertcondition(breakoutDown, title="Breakout Down", message="NQ ALERT: Breakdown below recent low on 5m")
````
