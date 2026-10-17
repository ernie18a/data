# Classic Long Term Trend Following System

- url: https://www.tradingview.com/script/xM16I5bD-Classic-Long-Term-Trend-Following-System/
- type: strategy
- pine_id: PUB;7d826cb3e4e54d7a962cd06875fcb2c0
- version: 4.0

## Description

This is a classic [b]long term[/b] trend following system. 

The breakout period is 50 days instead of 20 and the moving average crossover are 40 and 120. 

The moving averages are also exponential instead of simple. 

The stoploss is 4 ATRs away from the price. 

Recommendations:
Donchian Channels settings > 50 days
Moving Averages > 40 and 120, 80 and 140

Important to note:
My first strategy, DC Breakout System | This is simplicity at its finest, is best used on the crypto market and this one for stocks, commodities, currencies, etc. Those markets tend to trend a lot longer than crypto do.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Robrecht99

//@version=5
strategy("Classic Trend Following System", overlay=true, margin_long=0, margin_short=0, pyramiding=1)

// Backtest Range //

Start = input.time(defval = timestamp("01 Jan 2017 00:00 +0000"), title = "Backtest Start Date", group = "backtest window")
Finish = input.time(defval = timestamp("01 Jan 2100 00:00 +0000"), title = "Backtest End Date", group = "backtest window")

// Moving Averages //

len1 = input.int(50, minval = 1, title = "Length Fast EMA", group = "Moving Average Inputs")
len2 = input.int(150, minval = 1, title = "Length Slow EMA", group = "Moving Average Inputs")
src1 = input(close, title = "Source Fast MA")
src2 = input(close, title = "Source Slow MA")
maFast = input.color(color.new(color.red, 0), title = "Color Fast EMA", group = "Moving Average Inputs", inline = "maFast")
maSlow = input.color(color.new(color.blue, 0), title = "Color Slow EMA", group = "Moving Average Inputs", inline = "maSlow")
fast = ta.ema(src1, len1)
slow = ta.ema(src2, len2)
plot(fast, color = maFast, title = "Fast EMA")
plot(slow, color = maSlow, title = "Slow EMA")

// Donchian Channels //

Length1 = input.int(title = "Length Upper Channel", defval=50, minval=1, group = "Donchian Channels Inputs")
Length2 = input.int(title = "Length Lower Channel", defval=50, minval=1, group = "Donchian Channels Inputs")
h1 = ta.highest(high[1], Length1)
l1 = ta.lowest(low[1], Length2)
fillColor = input.color(color.new(color.purple, 95), title = "Fill Color", group = "Donchian Channels Inputs")
upperColor = input.color(color.new(color.orange, 0), title = " Color Upper Channel", group = "Donchian Channels Inputs", inline = "upper")
lowerColor = input.color(color.new(color.orange, 0), title = " Color Lower Channel", group = "Donchian Channels Inputs", inline = "lower")
u = plot(h1, "Upper", color = upperColor)
l = plot(l1, "Lower", color = upperColor)
fill(u, l, color=fillColor)

// ATR and Position Size //

leverage = input.int(title = "Leverage Used", defval = 1, minval = 1, group = "ATR Position Size Inputs")
pointvalue = input.int(title = "Point Value/ATR Multipliers from Entry", defval = 4, minval = 1, group = "ATR Position Size Inputs")
length = input.int(title = "ATR Period", defval = 14, minval = 1, group ="ATR Position Size Inputs")
risk = input(title = "Risk Per Trade", defval = 0.01, group = "ATR Position Size Inputs")
atr = ta.atr(length)
amount = (risk * strategy.initial_capital / (pointvalue * atr * leverage))

// ATR Trailing Stops //

xATRPeriod = input.int(14, "ATR Period", group = "ATR Trailing Stop Inputs")
xATRMultiplier = input.float(4, "ATR Multiplier", step = .1, group = "ATR Trailing Stop Inputs")
xATR = ta.atr(xATRPeriod)
Stop = xATRMultiplier * xATR
var xATRTrailingStop = 0.0
xATRTrailingStop := if close>xATRTrailingStop[1] and close[1] > xATRTrailingStop[1]
    math.max(xATRTrailingStop[1], close - Stop)
else if close < xATRTrailingStop[1] and close[1] < xATRTrailingStop[1]
    math.min(xATRTrailingStop[1], close + Stop)
else if close > xATRTrailingStop[1]
    close - Stop 
else 
    close+Stop
var Position = 0.0
Position := if close[1] < xATRTrailingStop[1] and close > xATRTrailingStop[1]
    1
else if close[1] > xATRTrailingStop[1] and close < xATRTrailingStop[1]
    -1
else
    Position[1]
PlotColor = Position == -1 ? color.orange : Position == 1 ? color.orange : color.orange
plot(xATRTrailingStop, color=PlotColor, linewidth = input(2, "Line Width", group = "ATR Trailing Stop Inputs"), style = plot.style_circles, title = "ATR Trailing Stop")


// Buy and Sell Conditions //

entrycondition1 = ta.crossover(fast, slow)
entrycondition2 = fast > slow
sellcondition1 = ta.crossunder(fast, slow)
sellcondition2 = slow > fast

// Buy and Sell Signals //

if (close > h1 and entrycondition2)
    strategy.entry("long", strategy.long, qty=amount)
    stoploss = close - atr * xATRMultiplier
    strategy.exit("exit sl", stop=stoploss, trail_offset=stoploss)
if (sellcondition1 and sellcondition2)
    strategy.close(id="long")

if (close < l1 and sellcondition2)
    strategy.entry("short", strategy.short, qty=amount)
    stoploss = close + atr * xATRMultiplier
    strategy.exit("exit sl", stop=stoploss, trail_offset=stoploss)
if (entrycondition1 and entrycondition2)
    strategy.close(id="short")
````
