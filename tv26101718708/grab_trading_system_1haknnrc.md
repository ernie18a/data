# Grab Trading System

- url: https://www.tradingview.com/script/1HAKnNRc-Grab-Trading-System/
- type: strategy
- pine_id: PUB;u7CACTxq8CVb2XtjMj62jnQ3u81DKfqk
- version: 2.0

## Description

Hello All,


This is "Grab Trading System" script defined in the book "Trend Following" by Michael W. Covel. also named as "Two-box system". I made small changes and I guess that it can be improved more.

The definition: Far box defines major trend; system trades only in same direction as major trend, meanwhile fading the signals of near box. Last trade in each trend exits at break of far box - at the same time as the trend reverses. All trades, except the last in the trend, use a limit order, as they are fading the near box. The last trade exits on a stop, as the trend changes.

As you can see there is Longterm Period and Shortterm Period in the indicator options. Longterm period is used for major trend and shortterm period is used to take position according to major trend. in my test I got better performance in small time frames. you need to set longterm/shortterm periods by your trading strategies. 


Enjoy!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue

//@version=4
strategy("Grab Trading System", overlay = true)
flb = input(defval = 80, title = "Longterm Period", minval = 1)
slb = input(defval = 21, title = "Shortterm Period", minval = 1)
showtarget = input(defval = true, title = "Show Target")
showtrend = input(defval = true, title = "Show Trend")

major_resistance = highest(flb)
major_support = lowest(flb)
minor_resistance = highest(slb)
minor_support = lowest(slb)
 
var int trend = 0
trend := high > major_resistance[1] ? 1 : low < major_support[1] ? -1 : trend
strategy.entry("Buy", true, when = trend == 1 and low[1] == minor_support[1] and low > minor_support)
strategy.entry("Sell", false, when = trend == -1 and high[1] == minor_resistance[1] and high < minor_resistance)

if strategy.position_size > 0
    strategy.exit("Buy", stop = major_support, comment = "Stop Buy")
    if high[1] == minor_resistance[1] and high < minor_resistance
        strategy.close("Buy", comment ="Close Buy")
    
if strategy.position_size < 0
    strategy.exit("Sell", stop = major_resistance, comment = "Stop Sell")
    if low[1] == minor_support[1] and low > minor_support
        strategy.close("Sell", comment ="Close Sell")

if strategy.position_size != 0 and change(trend)
    strategy.close_all()
    
majr = plot(major_resistance, color = showtrend and trend == -1 and trend[1] == -1 ? color.red : na)
majs = plot(major_support, color = showtrend and trend == 1 and trend[1] == 1 ? color.lime : na)
minr = plot(minor_resistance, color = showtarget and trend == 1 and strategy.position_size > 0 ? color.yellow : na, style = plot.style_circles)
mins = plot(minor_support, color = showtarget and trend == -1 and strategy.position_size < 0 ? color.yellow : na, style = plot.style_circles)

fill(majs, mins, color = showtrend and trend == 1 and trend[1] == 1 ? color.new(color.lime, 85) : na)
fill(majr, minr, color = showtrend and trend == -1 and trend[1] == -1 ? color.new(color.red, 85) : na)
````
