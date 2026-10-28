# Take Profit & Stop Loss Levels

- url: https://www.tradingview.com/script/liuZhpsR-Take-Profit-Stop-Loss-Levels/
- type: indicator
- pine_id: PUB;d4efa25d79aa416b9221af6f47bf132f
- version: 3.0

## Description

This script is a simple price-level indicator. It uses the previous closed 1-minute candle’s close as a base price, then draws three horizontal levels on the main chart: the base price, a percentage above it, and a percentage below it.

It declares the indicator and two settings:
up Percent: how far above the base price the top line should be.
down Percent: how far below the base price the bottom line should be
The base price based on the previous closed 1-minute candle close:

[list]
[*]Orange: previous 1-minute close (The base Level)
[*]Green: upper level (Take Profit Level)
[*]Red: lower level (Stop Loss Level)
[/list]

You Can change Take Profit & Stop Loss Levels percentage from the indicator settings.

## Source Code

````pine
//@version=6
indicator("Take Profit & Stop Loss Levels", overlay=true, format=format.price)

upPercent = input.float(4.0, "Up Percentage", step=0.1)
downPercent = input.float(2.0, "Down Percentage", step=0.1, minval=0.0)

basePrice = request.security(syminfo.tickerid, "1", close[1], barmerge.gaps_off, barmerge.lookahead_off)
upPrice = basePrice * (1 + upPercent / 100.0)
downPrice = basePrice * (1 - downPercent / 100.0)

plot(basePrice, title="Previous 1m Close", color=color.orange, linewidth=2, trackprice=true, show_last=1, offset=-99999)
plot(upPrice, title="Up Level", color=color.green, linewidth=2, trackprice=true, show_last=1, offset=-99999)
plot(downPrice, title="Down Level", color=color.red, linewidth=2, trackprice=true, show_last=1, offset=-99999)

var label takeProfitLabel = na
var label stopLossLabel = na

if barstate.islast and not na(upPrice) and not na(downPrice)
    label.delete(takeProfitLabel)
    label.delete(stopLossLabel)
    takeProfitText = "Take Profit Level (+" + str.tostring(upPercent) + "%)"
    stopLossText = "Stop Loss Level (-" + str.tostring(downPercent) + "%)"
    takeProfitLabel := label.new(bar_index, upPrice, takeProfitText, style=label.style_label_down, color=color.green, textcolor=color.white)
    stopLossLabel := label.new(bar_index, downPrice, stopLossText, style=label.style_label_up, color=color.red, textcolor=color.white)
````
