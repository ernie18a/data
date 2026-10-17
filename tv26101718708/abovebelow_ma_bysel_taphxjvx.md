# % Above/Below MA [BySel]

- url: https://www.tradingview.com/script/tapHxJVx-Above-Below-MA-BySel/
- type: indicator
- pine_id: PUB;6ec4848cc48048d7bdf0f31cd04bd19c
- version: 1.0

## Description

BYSEL
Using % Above/Below MA: EMA, SMA, WMA, RMA, ALMA

[i][b]The price is currently trading above or below the moving average (MA) by a certain percentage relative to the MA itself. This helps us identify a more reasonable entry price.[/b][/i]

Simple Interpretation

In simple terms, this indicator shows whether the current price is trading above or below its moving average (MA), expressed as a percentage deviation from the MA.

During an "[i]uptrend[/i]", if the price retraces toward the MA and the indicator returns to around zero or slightly negative territory, this often represents a "pullback toward the trend axis". Rather than chasing an already extended price move, this area can provide a more favorable point for evaluating a potential long entry.

Conversely, when the price is significantly above its MA and continues to rise, the indicator reflects a "[i]strong trend condition[/i]". However, this does not necessarily represent the optimal point for an early entry, as the price may already be substantially extended from its mean.

The underlying philosophy is straightforward: following a strong directional move, price tends to exhibit "mean-reverting behavior toward its moving average". The objective is therefore not to buy after the price has become excessively extended, but to identify opportunities when price retraces toward its statistical mean while the "[i]primary trend structure remains intact[/i]".

In concise terms:

[i][b]“Do not chase the peak; look for the price to return to the mean rhythm of the trend.”[/b][/i]

## Source Code

````pine
//@version=6
indicator("% Above/Below MA", overlay = false, precision = 2)

// Inputs
length = input.int(20, "MA Length", minval=1)
src = input.source(close, "Source")
maType = input.string("EMA", "MA Type", ["SMA", "EMA", "WMA", "RMA"])

maValue = switch maType
    "SMA" => ta.sma(src, length)
    "EMA" => ta.ema(src, length)
    "WMA" => ta.wma(src, length)
    "ALMA"=> ta.alma(src, length, 0.86, 0.6)
    => ta.rma(src, length)

// Calculations
ratio = math.abs(maValue) > 0 ? ((close - maValue) / maValue) * 100 : na

// Zero reference line
hline(0, title = "Zero", color = color.gray)

// Plot histogram
lineColor = ratio > 0 ? color.rgb(173, 190, 190) : color.rgb(204, 68, 68)
plot(ratio, title = "% Above/Below EMA", color = lineColor, linewidth = 1, style = plot.style_columns)
````
