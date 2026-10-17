# Hidden HA Reversal Signals

- url: https://www.tradingview.com/script/RZp5JhXx-Hidden-HA-Reversal-Signals/
- type: indicator
- pine_id: PUB;26edfae641804a78939bef5072fc861e
- version: 1.0

## Description

The Hidden Heikin Ashi Doji Reversal Signals indicator identifies potential trend reversal opportunities by analyzing Heikin Ashi candle patterns in the background while allowing traders to view and trade using standard candlesticks.

The indicator does not display Heikin Ashi candles on the chart. Instead, it internally calculates Heikin Ashi values and searches for a specific three-candle reversal pattern:

Buy Setup
The first Heikin Ashi candle forms a Doji, indicating market indecision.
The next two Heikin Ashi candles show strong bullish momentum with little or no upper wick.
A BUY signal is generated on the third candle.

Sell Setup
The first Heikin Ashi candle forms a Doji, indicating market indecision.
The next two Heikin Ashi candles show strong bearish momentum with little or no lower wick.
A SELL signal is generated on the third candle.

Key Features
Hidden Heikin Ashi analysis while using normal candlesticks.
Detects potential bullish and bearish reversals.
Filters market noise through Heikin Ashi calculations.
Provides clear BUY and SELL signals directly on the chart.
Supports TradingView alerts for automated notifications.
Works across stocks, indices, forex, commodities, and cryptocurrencies.

Best Use
Swing trading
Trend reversal identification
Momentum-based entries
Multi-timeframe confirmation strategies

## Source Code

````pine
//@version=6
indicator('Hidden HA Doji Reversal Signals', overlay = true)

//--------------------------------------------------
// Hidden Heikin Ashi Calculation
//--------------------------------------------------
haClose = (open + high + low + close) / 4

var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2

haHigh = math.max(high, math.max(haOpen, haClose))
haLow = math.min(low, math.min(haOpen, haClose))

//--------------------------------------------------
// Doji Detection
//--------------------------------------------------
bodySize = math.abs(haClose - haOpen)
rangeSize = haHigh - haLow

dojiThreshold = input.float(0.10, 'Doji Body % of Range', step = 0.01)

isDoji = rangeSize > 0 and bodySize <= rangeSize * dojiThreshold

//--------------------------------------------------
// Wick Detection
//--------------------------------------------------
tol = syminfo.mintick * 2

// No Lower Wick
noLowerWick = math.abs(math.min(haOpen, haClose) - haLow) <= tol

// No Upper Wick
noUpperWick = math.abs(haHigh - math.max(haOpen, haClose)) <= tol

//--------------------------------------------------
// BUY Pattern
// Doji -> No Lower Wick -> No Lower Wick
//--------------------------------------------------
buySignal = isDoji[2] and noLowerWick[1] and noLowerWick and haClose[1] > haOpen[1] and haClose > haOpen

//--------------------------------------------------
// SELL Pattern
// Doji -> No Upper Wick -> No Upper Wick
//--------------------------------------------------
sellSignal = isDoji[2] and noUpperWick[1] and noUpperWick and haClose[1] < haOpen[1] and haClose < haOpen

//--------------------------------------------------
// Plot Signals
//--------------------------------------------------
plotshape(buySignal, title = 'BUY', location = location.belowbar, style = shape.labelup, color = color.lime, text = 'BUY', size = size.small)

plotshape(sellSignal, title = 'SELL', location = location.abovebar, style = shape.labeldown, color = color.red, text = 'SELL', size = size.small)

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(buySignal, title = 'Buy Signal', message = 'Hidden HA Buy Signal')

alertcondition(sellSignal, title = 'Sell Signal', message = 'Hidden HA Sell Signal')
````
