# 15m ORB Clean Power

- url: https://www.tradingview.com/script/U4Q7D5bO-15m-ORB-Clean-Power/
- type: indicator
- pine_id: PUB;e88e29018e7b42f49cb861784f36ae36
- version: 1.0

## Description

5-minute Opening Range Breakout strategy with institutional volume confirmation and automatic target profit calculation.

## Source Code

````pine
//@version=5
indicator("15m ORB Clean Power", overlay=true)

// Settings
orbTime = input.string("0930-0945", "Opening Range Time (15m)")
volMult = input.float(1.5, "Volume Power Multiplier")
tpMultiplier = input.float(2.0, "Take Profit (Risk/Reward)")

// ORB Logic (Calculated in background)
is_new_day = ta.change(time("D")) != 0
is_in_range = not na(time(timeframe.period, orbTime))
var float orbHigh = na
var float orbLow = na

if is_new_day
    orbHigh := na
    orbLow := na

if is_in_range
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)

// Volume Check
isVolPower = volume > (ta.sma(volume, 20) * volMult)

// Breakout Signals
isUp = ta.crossover(close, orbHigh) and isVolPower
isDown = ta.crossunder(close, orbLow) and isVolPower

// Take Profit Calculation
rangeSize = orbHigh - orbLow
var float targetPrice = na

if isUp
    targetPrice := orbHigh + (rangeSize * tpMultiplier)
if isDown
    targetPrice := orbLow - (rangeSize * tpMultiplier)

// Visuals
barcolor(isVolPower ? color.new(color.purple, 0) : na)
plotchar(isUp, char="↓", location=location.abovebar, color=color.green, size=size.small, text="VOL BUY")
plotchar(isDown, char="↑", location=location.belowbar, color=color.red, size=size.small, text="VOL SELL")

// Plot Target Line only (Green dashed line)
plot(targetPrice, color=color.new(color.green, 40), style=plot.style_linebr, linewidth=2, title="Target Profit")
````
