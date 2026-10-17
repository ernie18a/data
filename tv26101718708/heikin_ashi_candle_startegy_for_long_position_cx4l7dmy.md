# Heikin Ashi Candle Startegy for Long Position

- url: https://www.tradingview.com/script/CX4l7Dmy-Heikin-Ashi-Candle-Startegy-for-Long-Position/
- type: strategy
- pine_id: PUB;906a63119baa40a089ffd3b3d092916f
- version: 2.0

## Description

This strategy utilize Heikin-Ashi candlestick chart. 
Heikin-Ashi technique is a Japanese candlestick-based technical trading tool that uses candlestick charts to represent and visualize market price data.
Heikin-Ashi candle is essentially taking an average of the movement. 
There is a tendency with Heikin-Ashi for the candles to stay red during a downtrend and green during an uptrend.

This strategy only apply for long trading position.
The idea is trader will waiting 3 green candles for validation period (confirmation) before entering long position.
Different timeframe will result different result.
Number of validation period can be changed to see different result

This strategy has parameter for take profit percentage, trailing stop and stop loss.
User can set maximum active position to minimize risk and qty order.

This tool is useful for user who wants to backtest Heikin-Ashi trading strategy.

Script will emit alert when long position is opened and closed.

Warning of Backtesting
Backtesting is backward-looking. As the name implies, you are testing how something would have worked if you traded it perfectly in the past. 
Past performance does not indicate future performance and you should not assume it does.
Backtesting assumes you never miss-fire, that you get in and out at the exactly perfect moment each time.
Backtesting assumes you have perfect liquidity, and your limit orders fill at a specific, pre-defined price every time (either the open, close, low, high, or some average of these).

Disclaimer
Do your own research and consider fundamental price of asset.
The indicators provided on this script is for educational purposes only.
Author does not offer advisory or brokerage services, nor does it recommend or advise users to buy or sell particular stocks or securities.
Please examined script and give feedback for further improvement.

Script are open to public, everyone see and clone source code or just apply to chart. Please make comment for improvement.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YohanNaftali

//@version=5

///////////////////////////////////////////////////////////////////////////////
// Heikin Ashi Candle Startegy
// ver 2021.12.29
// © YohanNaftali
// This script composed by Yohan Naftali for educational purpose only 
// Reader who will use this signal must do own research
///////////////////////////////////////////////////////////////////////////////
strategy(
     title = 'Heikin Ashi Candle Startegy Long',  
     shorttitle = 'HA Strategy Long',  
     format = format.price,
     precision = 6,
     overlay = true)

// Input
validationPeriod = input.int( 
     defval = 3, 
     title = 'Validation Period', 
     group = 'Candle')

qtyOrder = input.float(
     defval = 1.0,
     title = 'Qty', 
     group = 'Order')

maxActive = input.float(
     defval = 1.0,
     title = 'Maximum Active Open Position', 
     group = 'Order')

// Long Strategy
tpLong = input.float(
     defval = 1,
     title = "Take Profit (%)",
     minval = 0.0, 
     step = 0.1, 
     group = "Long") * 0.01

slLong = input.float(
     defval = 25,
     title = "Stop Loss (%)", 
     minval=0.0, 
     step=0.1,
     group="Long") * 0.01

trailingStopLong = input.float(
     defval = 0.2,
     title = "Trailing Stop (%)",
     minval = 0.0, 
     step = 0.1,
     group = 'Long') * 0.01

// Calculation
haTicker = ticker.heikinashi(syminfo.tickerid)
haClose = request.security(haTicker, timeframe.period, close)
haOpen = request.security(haTicker, timeframe.period, open)

// Long
limitLong = tpLong > 0.0 ? strategy.position_avg_price * (1 + tpLong) : na
stopLong = slLong > 0.0 ? strategy.position_avg_price * (1 - slLong) : na
float trailLong = 0.0
trailLong := if strategy.position_size > 0
    trailClose = close * (1 - trailLong)
    math.max(trailClose, trailLong[1])
else
    0

isGreen = true
for i = 0 to validationPeriod-1
    isGreen := isGreen and haClose[i] > haOpen[i]        
isLong = isGreen and haClose[validationPeriod] < haOpen[validationPeriod]



plot(
     limitLong,
     title = 'Limit', 
     color = color.rgb(0, 0, 255, 0), 
     style = plot.style_stepline,
     linewidth = 1)

plot(
     trailLong,
     title = 'Trailing', 
     color = color.rgb(255, 255, 0, 0), 
     style = plot.style_stepline,
     linewidth = 1)

plot(
     stopLong,
     title = 'Stop', 
     style = plot.style_stepline,
     color = color.rgb(255, 0, 0, 0), 
     linewidth = 1)

// plotshape(
//      isLong, 
//      title = 'Entry', 
//      style = shape.arrowup, 
//      location = location.belowbar, 
//      offset = 1, 
//      color = color.new(color.green, 0), 
//      text = 'Long Entry',
//      size = size.small)

// Strategy
strategy.risk.max_position_size(maxActive)
strategy.risk.allow_entry_in(strategy.direction.long)

strategy.entry(
     id = "Long", 
     direction = strategy.long, 
     qty = qtyOrder,  
     when = isLong,       
     alert_message = "LN")
if (strategy.position_size > 0)
    strategy.exit(
         id = "Long Exit",
         from_entry = "Long",
         limit = limitLong,
         stop = stopLong,
         trail_price = trailLong,
         alert_message = "LX")
````
