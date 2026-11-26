# Price and Volume Breakout Buy Strategy [TradeDots]

- url: https://www.tradingview.com/script/jc2hs2qK-Price-and-Volume-Breakout-Buy-Strategy-TradeDots/
- type: strategy
- pine_id: PUB;bf6c3d4744be458db3a63fb9555e5352
- version: 2.0

## Description

The "Price and Volume Breakout Buy Strategy" is a trading strategy designed to identify buying opportunities by detecting concurrent price and volume breakouts over a specified range of candlesticks.

This strategy is optimized for assets demonstrating high volatility and significant momentum spikes.

[b]HOW IT WORKS[/b]

The strategy first takes the specific number of candlesticks as the examination window for both price and volume. 

These values are used as benchmarks to identify breakout conditions.

A trade is initiated when both the closing price and the trading volume surpass the maximum values observed within the predetermined window.

Price must be above a designated moving average, serving as the trend indicator, ensuring that all trades align with the prevailing market trend.

[b]APPLICATION[/b]

This strategy is particularly effective for highly volatile assets such as Bitcoin and Ethereum, capitalizing on the cues from sudden price and volume breakouts indicative of significant market movement, often driven by market smart money traders.

However, for broader markets like the S&P 500, this strategy may be less effective due to less pronounced volume and price shifts compared to the cryptocurrency markets.

[b]DEFAULT SETUP[/b]

Commission: 0.01%
Initial Capital: $10,000
Equity per Trade: 70%

Backtest result sometimes gives fewer than 100 trades under certain higher timeframes, as most trades tend to have a long holding period. Entry conditions are also more stringent, which, combined with the relatively brief history of cryptocurrencies, results in fewer trades on longer timeframes.

Users are advised to adjust and personalize this trading strategy to better match their individual trading preferences and style.

[b]RISK DISCLAIMER[/b]

Trading entails substantial risk, and most day traders incur losses. All content, tools, scripts, articles, and education provided by TradeDots serve purely informational and educational purposes. Past performances are not definitive predictors of future results.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradedots

//@version=5
strategy("Price and Volume Breakout Buy Strategy [TradeDots]", overlay=true, initial_capital = 10000, default_qty_type = strategy.percent_of_equity, default_qty_value = 70, commission_type = strategy.commission.percent, commission_value = 0.01)

input_price_breakout_period = input.int(60, "Price Breakout Period")
input_volume_breakout_period = input.int(60, "Volume Breakout Period")
input_trendline_legnth = input.int(200, "Trendline Length")
input_order_direction = input.string("Long", options = ["Long", "Short", "Long and Short"], title = "Order Direction")

price_highest = ta.highest(input_price_breakout_period)
price_lowest = ta.lowest(input_price_breakout_period)
volume_highest = ta.highest(volume, input_volume_breakout_period)

// Long Orders
if close > price_highest[1] and volume > volume_highest[1] and close > ta.sma(close, input_trendline_legnth) and strategy.opentrades == 0 and input_order_direction != "Short"
    strategy.entry("Long", strategy.long)
    line.new(bar_index[input_price_breakout_period], price_highest[1], bar_index, price_highest[1], color = #9cff87, width = 2)
    label.new(bar_index,low, "🟢 Breakout Buy", style = label.style_label_up, color = #9cff87)

// Close when price is below moving average for 5 consecutive days
if close < ta.sma(close, input_trendline_legnth) and close[1] < ta.sma(close, input_trendline_legnth) and close[2] < ta.sma(close, input_trendline_legnth) and close[3] < ta.sma(close, input_trendline_legnth) and close[4] < ta.sma(close, input_trendline_legnth) and strategy.opentrades.size(strategy.opentrades - 1) > 0
    strategy.close("Long")
    label.new(bar_index, high, "🔴 Close Position", style = label.style_label_down, color = #f9396a, textcolor = color.white)

// Short Orders
if close < price_lowest[1] and volume > volume_highest[1] and close < ta.sma(close, input_trendline_legnth) and strategy.opentrades == 0 and input_order_direction != "Long"
    strategy.entry("Short", strategy.short)
    line.new(bar_index[input_price_breakout_period], price_lowest[1], bar_index, price_lowest[1], color = #f9396a, width = 2)
    label.new(bar_index,high , "🔴 Breakout Sell", style = label.style_label_down, color = #f9396a, textcolor = color.white)

// Close when price is above moving average for 5 consecutive days
if close > ta.sma(close, input_trendline_legnth) and close[1] > ta.sma(close, input_trendline_legnth) and close[2] > ta.sma(close, input_trendline_legnth) and close[3] > ta.sma(close, input_trendline_legnth) and close[4] > ta.sma(close, input_trendline_legnth) and strategy.opentrades.size(strategy.opentrades - 1) < 0
    strategy.close("Short")
    label.new(bar_index, low, "🟢 Close Position", style = label.style_label_up, color = #9cff87)

plot(ta.sma(close, input_trendline_legnth), color = color.white, linewidth = 2)
plotcandle(open, high, low, close, title='Candles', color = (close > ta.sma(close, input_trendline_legnth) ? #9cff87 : #f9396a), wickcolor=(close > ta.sma(close, input_trendline_legnth) ? #9cff87 : #f9396a), force_overlay = true)
````
