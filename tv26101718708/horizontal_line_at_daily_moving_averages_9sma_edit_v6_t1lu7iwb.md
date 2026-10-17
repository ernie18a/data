# Horizontal Line At Daily Moving Averages - 9SMA edit v6

- url: https://www.tradingview.com/script/t1LU7iWb-Horizontal-Line-At-Daily-Moving-Averages-9SMA-edit-v6/
- type: indicator
- pine_id: PUB;81873842363c46fe8f84d7bf942f33cd
- version: 1.0

## Description

Plots a horizontal line on all time frames for daily simple moving averages. The original indicator was created by © davidtammari. I needed 9SMA instead of EMA so have reposted the indicator with an updated script. I also added a 65min 9SMA visible on timeframes under 60mins. Also updated to pinescript v6

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © davidtammari

indicator('Horizontal Line At Daily Moving Averages', overlay = true)

MA9 = request.security(syminfo.tickerid, 'D', ta.sma(close, 9))
MA21 = request.security(syminfo.tickerid, 'D', ta.sma(close, 21))
MA50 = request.security(syminfo.tickerid, 'D', ta.sma(close, 50))
MA100 = request.security(syminfo.tickerid, 'D', ta.sma(close, 100))
MA200 = request.security(syminfo.tickerid, 'D', ta.sma(close, 200))
// 1. Calculate the 65-min MA (MUST come before the plot)
MA9_65_raw = request.security(syminfo.tickerid, '65', ta.sma(close, 9))

// 2. Define the condition (Only show if timeframe is less than 60 mins)
show65MA = timeframe.isintraday and timeframe.multiplier < 60

// 3. Filter the data: If condition is false, result is 'na' (not available/invisible)
MA9_65 = show65MA ? MA9_65_raw : na

// 4. Existing Plots
plot(MA9, trackprice = true, linewidth = 2, color = color.new(color.red, 0), offset = -9999, title = '9 MA')
plot(MA21, trackprice = true, linewidth = 2, color = color.new(color.navy, 0), offset = -9999, title = '21 MA')
plot(MA50, trackprice = true, linewidth = 2, color = color.new(color.green, 0), offset = -9999, title = '50 MA')
plot(MA100, trackprice = true, linewidth = 2, color = color.new(color.blue, 0), offset = -9999, title = '100 MA')
plot(MA200, trackprice = true, linewidth = 2, color = color.new(color.purple, 0), offset = -9999, title = '200 MA')

// 5. Plot the new 65-min line
plot(MA9_65, trackprice = true, linewidth = 2, color = color.new(color.orange, 0), offset = -9999, title = '65min 9 MA')
````
