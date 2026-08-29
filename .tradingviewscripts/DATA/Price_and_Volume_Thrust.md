<!-- tradingview-pine-id: PUB;b871e46526424f95b679fe5324a12735 -->
<!-- tradingviewscripts-format: 1 -->
# Price and Volume Thrust

Source: https://www.tradingview.com/script/VdRnrxwV-Stochastic-Price-and-Volume-Thrust/

## Description

Name: Stochastic Price and Volume Thrust

Platform: Tradingview

Code Language: Pine Script

Indicator Type: Plot

When Slow Stochastic is <= 25, or >= 75

Condition 1: If the candle makes a higher high than the previous candle, and volume is greater than the previous candles volume, then plot small blue dot below the low of the signaling candle
Condition 2: If the candle makes a lower low than the previous candle, and volume is greater than the previous candles volume, then plot small magenta dot above the high of the signaling candle

---

## Source Code

````pine
//@version=6
indicator('Price and Volume Thrust', overlay = true)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
arrowOffset = input.float(1.0, title = 'Dot Offset (% of candle range)', minval = 0.1, maxval = 10.0, step = 0.1)
dotSize = input.string('Small', title = 'Dot Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'])

kLength = input.int(14, title = '%K Length', minval = 1)
kSmoothing = input.int(3, title = '%K Smoothing', minval = 1)
dSmoothing = input.int(3, title = '%D Smoothing', minval = 1)

obLevel = input.int(75, title = 'Overbought Level', minval = 50, maxval = 100)
osLevel = input.int(25, title = 'Oversold Level', minval = 0, maxval = 50)

// ─────────────────────────────────────────────
// SLOW STOCHASTIC CALCULATION
// ─────────────────────────────────────────────
fastK = ta.stoch(close, high, low, kLength)
slowK = ta.sma(fastK, kSmoothing)

// ─────────────────────────────────────────────
// STOCHASTIC FILTER
// ─────────────────────────────────────────────
stochFilter = slowK >= obLevel or slowK <= osLevel

// ─────────────────────────────────────────────
// CONDITIONS
// ─────────────────────────────────────────────
bullSignal = high > high[1] and volume > volume[1] and close > open and stochFilter
bearSignal = low < low[1] and volume > volume[1] and close < open and stochFilter

// ─────────────────────────────────────────────
// DOT PLACEMENT
// ─────────────────────────────────────────────
candleRange = high - low
offsetPoints = candleRange * (arrowOffset / 100.0)
bullDotY = low - offsetPoints
bearDotY = high + offsetPoints

// ─────────────────────────────────────────────
// BULL DOTS
// ─────────────────────────────────────────────
plotchar(dotSize == 'Tiny' and bullSignal ? bullDotY : na, title = 'Bull Dot (Tiny)', char = '•', location = location.absolute, color = color.new(color.blue, 0), size = size.tiny)

plotchar(dotSize == 'Small' and bullSignal ? bullDotY : na, title = 'Bull Dot (Small)', char = '•', location = location.absolute, color = color.new(color.blue, 0), size = size.small)

plotchar(dotSize == 'Normal' and bullSignal ? bullDotY : na, title = 'Bull Dot (Normal)', char = '•', location = location.absolute, color = color.new(color.blue, 0), size = size.normal)

plotchar(dotSize == 'Large' and bullSignal ? bullDotY : na, title = 'Bull Dot (Large)', char = '•', location = location.absolute, color = color.new(color.blue, 0), size = size.large)

plotchar(dotSize == 'Huge' and bullSignal ? bullDotY : na, title = 'Bull Dot (Huge)', char = '•', location = location.absolute, color = color.new(color.blue, 0), size = size.huge)

// ─────────────────────────────────────────────
// BEAR DOTS
// ─────────────────────────────────────────────
plotchar(dotSize == 'Tiny' and bearSignal ? bearDotY : na, title = 'Bear Dot (Tiny)', char = '•', location = location.absolute, color = color.new(color.fuchsia, 0), size = size.tiny)

plotchar(dotSize == 'Small' and bearSignal ? bearDotY : na, title = 'Bear Dot (Small)', char = '•', location = location.absolute, color = color.new(color.fuchsia, 0), size = size.small)

plotchar(dotSize == 'Normal' and bearSignal ? bearDotY : na, title = 'Bear Dot (Normal)', char = '•', location = location.absolute, color = color.new(color.fuchsia, 0), size = size.normal)

plotchar(dotSize == 'Large' and bearSignal ? bearDotY : na, title = 'Bear Dot (Large)', char = '•', location = location.absolute, color = color.new(color.fuchsia, 0), size = size.large)

plotchar(dotSize == 'Huge' and bearSignal ? bearDotY : na, title = 'Bear Dot (Huge)', char = '•', location = location.absolute, color = color.new(color.fuchsia, 0), size = size.huge)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(bullSignal, title = 'Bullish Price & Volume Thrust', message = 'Price and Volume Thrust: Higher High + Higher Volume + Bullish Close + Stochastic Filter — Bullish Thrust Signal')

alertcondition(bearSignal, title = 'Bearish Price & Volume Thrust', message = 'Price and Volume Thrust: Lower Low + Higher Volume + Bearish Close + Stochastic Filter — Bearish Thrust Signal')
````
