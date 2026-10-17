# Moving Averages and Bollinger Bands

- url: https://www.tradingview.com/script/lwDFlLI7-Moving-Averages-and-Bollinger-Bands/
- type: indicator
- pine_id: PUB;aff8dfecbe88491d8e2d4bf1757596a2
- version: 1.0

## Description

Bollinger Bands and Moving Average, this help us to get zones to make long or short entry position

## Source Code

````pine
//@version=6
indicator("Custom Moving Averages and Bollinger Bands", overlay=true)

// Inputs
lengthWMAHigh10 = input.int(10, "WMA Length (High 10)")
lengthWMAHigh5 = input.int(5, "WMA Length (High 5)")
lengthWMALow10 = input.int(10, "WMA Length (Low 10)")
lengthWMALow5 = input.int(5, "WMA Length (Low 5)")
lengthEMA50 = input.int(50, "EMA Length (Close 50)")
bbLength = input.int(20, "Bollinger Bands Length")
bbMultiplier = input.float(2.0, "Bollinger Bands Multiplier")

// Calculations
wmaHigh10 = request.security(syminfo.tickerid, "", ta.wma(high, lengthWMAHigh10))
wmaHigh5 = request.security(syminfo.tickerid, "", ta.wma(high, lengthWMAHigh5))
wmaLow10 = request.security(syminfo.tickerid, "", ta.wma(low, lengthWMALow10))
wmaLow5 = request.security(syminfo.tickerid, "", ta.wma(low, lengthWMALow5))
ema50 = request.security(syminfo.tickerid, "", ta.ema(close, lengthEMA50))

// Bollinger Bands
basis = request.security(syminfo.tickerid, "", ta.sma(close, bbLength))
deviation = request.security(syminfo.tickerid, "", ta.stdev(close, bbLength))
bbUpper = basis + bbMultiplier * deviation
bbLower = basis - bbMultiplier * deviation

// Plotting
plot(wmaHigh10, color=#ae00ff, title="WMA High 10")
plot(wmaHigh5, color=#ae00ff, title="WMA High 5")
plot(wmaLow10, color=#ff00d4, title="WMA Low 10")
plot(wmaLow5, color=#ff00d4, title="WMA Low 5")
plot(ema50, color=color.purple, title="EMA Close 50")
plot(bbUpper, color=color.gray, title="Bollinger Band Upper")
plot(basis, color=color.black, title="Bollinger Band Basis")
plot(bbLower, color=color.gray, title="Bollinger Band Lower")
````
