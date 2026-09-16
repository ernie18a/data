<!-- tradingview-pine-id: PUB;a6ba91124fe74949a8db3387b8fa34c1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MES 1-Day and 3-Day Equilibrium

Source: https://www.tradingview.com/script/HKJqt2nA-MES-1-Day-and-3-Day-Equilibrium/

## Description

The MES 1-Day and 3-Day Equilibrium indicator helps traders identify where price is balanced over two short-term periods.

The yellow line shows the previous trading day’s equilibrium,calculated as the midpoint between the previous day’s high and low.

The blue line shows the 3-day equilibrium—calculated as the midpoint between the highest high and lowest low from the previous three completed trading days.

How I use it:

• Price above both lines suggests a bullish bias.

• Price below both lines suggests a bearish bias.

• Price between the two lines suggests mixed or balanced conditions.

The background turns light green when price is above both equilibrium levels and light red when price is below both. Each current level is identified with a label on the right side of the chart.

The indicator automatically adjusts to the symbol being viewed and can be used with futures, stocks, ETFs and indexes. It is designed primarily for intraday charts.

This indicator does not provide automatic buy or sell signals. I use it as a reference for market direction, possible support and resistance, and confirmation alongside price action, volume and risk management.

---

## Source Code

````pine
//@version=6
indicator("MES 1-Day and 3-Day Equilibrium", overlay=true, max_labels_count=10)

[priorHigh, priorLow, threeDayHigh, threeDayLow] = request.security(
     syminfo.tickerid,
     "D",
     [high[1], low[1], ta.highest(high, 3)[1], ta.lowest(low, 3)[1]],
     lookahead=barmerge.lookahead_on)

oneDayEQ = (priorHigh + priorLow) / 2
threeDayEQ = (threeDayHigh + threeDayLow) / 2

plot(oneDayEQ, "1-Day Equilibrium", color.yellow, 2, plot.style_stepline)
plot(threeDayEQ, "3-Day Equilibrium", color.aqua, 3, plot.style_stepline)

var label oneDayLabel = na
var label threeDayLabel = na

if barstate.islast
    label.delete(oneDayLabel)
    label.delete(threeDayLabel)

    oneDayLabel := label.new(
         bar_index + 3,
         oneDayEQ,
         "1-Day EQ: " + str.tostring(oneDayEQ, format.mintick),
         style=label.style_label_left,
         color=color.yellow,
         textcolor=color.black)

    threeDayLabel := label.new(
         bar_index + 3,
         threeDayEQ,
         "3-Day EQ: " + str.tostring(threeDayEQ, format.mintick),
         style=label.style_label_left,
         color=color.aqua,
         textcolor=color.black)

bullish = close > oneDayEQ and close > threeDayEQ
bearish = close < oneDayEQ and close < threeDayEQ

bgcolor(
     bullish ? color.new(color.green, 92) :
     bearish ? color.new(color.red, 92) : na)
````
