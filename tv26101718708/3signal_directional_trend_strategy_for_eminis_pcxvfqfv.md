# 3-Signal Directional Trend Strategy for E-Minis

- url: https://www.tradingview.com/script/pCxvfqFv-3-Signal-Directional-Trend-Strategy-for-E-Minis/
- type: strategy
- pine_id: PUB;5f7809c870b3484ca985d8db916be10f
- version: 1.0

## Description

This is a conceptual strategy intended for E-mini S&P 500 futures with hourly bars.

It uses three signals, going long or short when two or more change in the same direction.

First is MACD. A positive oscillator is considered a bullish signal and a falling oscillator is interpreted bearishly.

Next, stochastics are used as an overbought/oversold indicator. Overbought conditions are considered bearish and oversold readings are viewed as bullish.

Third is a custom indicator based on our [url=https://www.tradingview.com/script/4j9HWCVA-Moving-Average-Speed-Can-Spot-Turns-Before-They-Happen/]Moving Average Speed[/url] script. It takes the rate of change of the 50-hour simple moving average (SMA), and then smooths it using a 10-period average. This provides a directional signal.

Traders may want to experiment with different settings for moving average speed. 

[b]Note: This is intended for use with stock index futures, which have round-the clock price data to populate the data in the indicators. It may not yield good results with stocks or ETFs.[/b]

[i]TradeStation has, for decades, advanced the trading industry, providing access to stocks, options, futures and cryptocurrencies. See our [url=https://www.tradingview.com/broker/TradeStation/]Overview[/url] for more.[/i]

[b]Important Information[/b]
TradeStation Securities, Inc., TradeStation Crypto, Inc., and TradeStation Technologies, Inc. are each wholly owned subsidiaries of TradeStation Group, Inc., all operating, and providing products and services, under the TradeStation brand and trademark. TradeStation Crypto, Inc. offers to self-directed investors and traders cryptocurrency brokerage services.  It is neither licensed with the SEC or the CFTC nor is it a Member of NFA. When applying for, or purchasing, accounts, subscriptions, products, and services, it is important that you know which company you will be dealing with. Please [url=https://uploads.tradestation.com/uploads/TradeStation-Group-Inc-Companies.pdf]click here[/url] for further important information explaining what this means.
 
[b]This content is for informational and educational purposes only.[/b] This is not a recommendation regarding any investment or investment strategy.  Any opinions expressed herein are those of the author and do not represent the views or opinions of TradeStation or any of its affiliates. 

Investing involves risks. Past performance, whether actual or indicated by historical tests of strategies, is no guarantee of future performance or success. There is a possibility that you may sustain a loss equal to or greater than your entire investment regardless of which asset class you trade (equities, options, futures, or digital assets); therefore, you should not invest or risk money that you cannot afford to lose. Before trading any asset class, first read the relevant risk disclosure statements on the Important Documents page, found here: [url=http://www.tradestation.com/important-information]www.tradestation.com/important-information[/url].

## Source Code

````pine
// By TradeStation
//@version=5

strategy("Mov Avg Speed Strategy", overlay=true)

src = input(close, title="Source")

// MA Speed  
avg_len = input.int(50, minval=1, title="Avg Length", group="MA Speed")
roc_len = input.int(1, minval=1, title="Rate of Change Length", group="MA Speed")
avg_roc_len = input.int(10, minval=1, title="Avg Rate of Change Length", group="MA Speed")

// Stochastic
stoch_len = input.int(14, minval=1, title="Stochastic Length", group="Stochastic")
smooth_k = input.int(3, minval=1, title="Stochastic Smooth K", group="Stochastic")
overbought = input.float(80, title="Stochastic Overbought", group="Stochastic")
oversold = input.float(20, title="Stochastic Oversold", group="Stochastic")

// MACD
fast_length = input(12, title="Fast Length", group="MACD")
slow_length = input(26, title="Slow Length", group="MACD")
macd_avg_length = input.int(9, title="MACD Avg Length",  minval=1, group="MACD")

// MA Speed
avg = ta.sma(src, avg_len)
roc = ta.roc(avg, roc_len)
avg_roc = ta.sma(roc, avg_roc_len)
avg_roc_signal = avg_roc > 0 ? 1 : avg_roc < 0 ? -1 : 0 

// Stochastic k
k = ta.sma(ta.stoch(close, high, low, stoch_len), smooth_k)
stochastic_signal = k <= oversold ? 1 : k >= overbought ? -1 : 0

// MACD
fast_ma = ta.ema(src, fast_length)
slow_ma = ta.ema(src, slow_length)
macd = fast_ma - slow_ma
macd_avg = ta.ema(macd, macd_avg_length)
macd_signal = macd_avg > macd_avg[1] ? 1 : macd_avg < macd_avg[1] ? -1 : 0

// set the signal couint
long_count = 0
short_count = 0

if macd_signal == 1
    long_count += 1

else if macd_signal == -1
    short_count += 1
 
if stochastic_signal == 1
    long_count += 1

else if stochastic_signal == -1
    short_count += 1
 
if avg_roc_signal == 1
    long_count += 1

else if avg_roc_signal == -1
    short_count += 1

if (long_count >= 2)
    strategy.entry("Long", strategy.long)

if (short_count >= 2)
    strategy.entry("Short", strategy.short)
````
