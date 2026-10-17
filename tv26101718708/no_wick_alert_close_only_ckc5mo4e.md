# No Wick Alert (Close Only)

- url: https://www.tradingview.com/script/Ckc5mO4E/
- type: indicator
- pine_id: PUB;62b611cf67f5475a915a1a85fd8ad5f4
- version: 1.0

## Description

[image]https://www.tradingview.com/x/HRobEaVx/[/image]


No Wick Alert (Close Only) is a simple and lightweight indicator that identifies candles that close with no upper wick or no lower wick and allows traders to create TradingView alerts based on these events.

The signal is only generated after the candle has closed, preventing false alerts during candle formation.

[b]Features[/b]

[list]
[*]Detects candles with no upper wick
[*]Detects candles with no lower wick
[*]Signals are confirmed only at bar close
[*]Supports TradingView alert creation
[*]Visual markers plotted directly on the chart
[*]Works on any market and timeframe
[/list]

[b]Why Use No-Wick Candles?[/b]

Candles without a wick often indicate strong directional conviction:

No Upper Wick → Buyers maintained control until the close.
No Lower Wick → Sellers maintained control until the close.

Many traders use these candles as:

[list]
[*]Momentum confirmation signals
[*]Trend continuation clues
[*]Breakout confirmation tools
[*]Additional filters within a broader trading strategy
[/list]

[b]Alert Setup[/b]
[list]
[*]Add the indicator to your chart.
[*]Click Create Alert.
[*]Select No Wick Candle Closed as the alert condition.
[*]Choose Once Per Bar Close for best results.
[/list]

The alert will only trigger after a candle has fully closed and meets the no-wick condition.

[b]Notes[/b]

A candle is considered to have no upper wick when the high equals the higher value of the open or close.
A candle is considered to have no lower wick when the low equals the lower value of the open or close.
The indicator does not repaint because signals are confirmed only after bar close.

This tool is designed to provide a clean and objective way to identify strong closing candles and incorporate them into your trading workflow.

## Source Code

````pine
//@version=6
indicator("No Wick Alert (Close Only)", overlay=true)

// Oberer Docht = 0
noUpperWick = high == math.max(open, close)

// Unterer Docht = 0
noLowerWick = low == math.min(open, close)

// Bedingung erst nach Kerzenschluss prüfen
signal = barstate.isconfirmed and (noUpperWick or noLowerWick)

// Markierung im Chart
plotshape(signal and noUpperWick, title="No Upper Wick",
     location=location.abovebar,
     style=shape.triangledown,
     size=size.small)

plotshape(signal and noLowerWick, title="No Lower Wick",
     location=location.belowbar,
     style=shape.triangleup,
     size=size.small)

// Alarmbedingung
alertcondition(signal,
     title="No Wick Candle Closed",
     message="No Wick Candle Closed.")
````
