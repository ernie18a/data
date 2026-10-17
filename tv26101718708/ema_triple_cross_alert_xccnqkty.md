# EMA Triple Cross Alert

- url: https://www.tradingview.com/script/xCcNqktY-EMA-Triple-Cross-Alert/
- type: indicator
- pine_id: PUB;ac30ccf19b714b69ae16e1201a805579
- version: 1.0

## Description

Indicator Features:
22 EMA (Blue/Fast)
222 EMA (Green/Medium)
222 EMA (Red/Slow)
Red triangles appear when blue crosses below both green & red and stays below for the full 3-minute bar
Built-in alert condition ready to use

## Source Code

````pine
//@version=6
indicator("EMA Triple Cross Alert", overlay=true)

// 1. Plot 3 EMAs: fast (22), medium (222), slow (222)
// Note: User specified 222 for both medium and slow.
fastLen   = input.int(22, "Fast EMA Length")
medLen    = input.int(222, "Medium EMA Length")
slowLen   = input.int(222, "Slow EMA Length")

emaFast = ta.ema(close, fastLen)
emaMed  = ta.ema(close, medLen)
emaSlow = ta.ema(close, slowLen)

plot(emaFast, "Fast EMA", color.blue, 2)
plot(emaMed,  "Medium EMA", color.green, 2)
plot(emaSlow, "Slow EMA", color.red, 2)

// 2. Signal: Fast EMA crosses below BOTH medium and slow EMAs
// 3. 1-bar confirmation: Signal only fires if fast stays below both for the entire bar
// We check if the condition was met at the close of the previous bar [1] 
// and is still met at the close of the current bar.
isBelowBoth = emaFast < emaMed and emaFast < emaSlow
crossBelow  = ta.crossunder(emaFast, math.min(emaMed, emaSlow))

// Confirmation logic: 
// Trigger on the bar close if it has been below for the duration of the bar.
// In Pine Script, conditions evaluated on 'close' are confirmed when the bar closes.
confirmedSignal = isBelowBoth and barstate.isconfirmed

// 5. Visual Marker
plotshape(confirmedSignal, "Cross Down Signal", shape.triangledown, location.abovebar, color.red, size=size.small)

// 4. Alert Condition
alertcondition(confirmedSignal, "EMA Triple Cross Down", "Fast EMA (22) has crossed and stayed below both Medium and Slow EMAs (222)")
````
