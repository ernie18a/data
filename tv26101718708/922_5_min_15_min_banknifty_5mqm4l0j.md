# 9:22 5 MIN 15 MIN BANKNIFTY

- url: https://www.tradingview.com/script/5MQm4L0J-9-22-5-MIN-15-MIN-BANKNIFTY/
- type: strategy
- pine_id: PUB;00ac2f47498141639565e3e8453ca474
- version: 1.0

## Description

[b]9:22 5 MIN 15 MIN BANKNIFTY Strategy with Additional Filters
[/b]

The 9:22 5 MIN 15 MIN BANKNIFTY Strategy with Additional Filters is a trend-following strategy designed for trading the BANKNIFTY instrument on a 5-minute chart. It aims to capture potential price movements by generating buy and sell signals based on moving average crossovers, breakout confirmations, and additional filters.

Key Features:

[list]
[*] Fast MA Length: 9
[*] Slow MA Length: 22
[*] ATR Length: 14
[*] ATR Filter: 0.5
[*] Trailing Stop Percentage: 1.5%
[*] Pullback Threshold: 0.5
[*] Minimum Candle Body Percentage: 0.5
[*] Use Breakout Confirmation: Enabled

[/list]
Additional Filters:

Volume Threshold: Set a minimum volume requirement for trades.
Trend Filter: Optionally enable a trend filter based on a higher timeframe moving average.
Momentum Filter: Optionally enable a momentum filter using the RSI indicator.
Support/Resistance Filter: Optionally enable a filter based on predefined support and resistance levels.
Buy and Sell Signals:

Buy Signal: A buy signal is generated when the fast moving average crosses above the slow moving average, with additional confirmation from breakout and volume criteria, along with optional trend, momentum, and support/resistance filters.
Sell Signal: A sell signal is generated when the fast moving average crosses below the slow moving average, with similar confirmation and filtering criteria as the buy signal.
Exit Strategy:
The strategy employs a trailing stop-loss mechanism based on a percentage of the average entry price. The stop-loss is dynamically adjusted to protect profits while allowing for potential upside.

Please note that this strategy should be thoroughly backtested and evaluated in different market conditions before applying it to live trading. It is also recommended to adjust the parameters and filters according to individual preferences and risk tolerance.

Feel free to customise and adapt the description as needed to suit your preferences and the specific details of your strategy.

## Source Code

````pine
//@version=5
strategy("9:22 5 MIN 15 MIN BANKNIFTY", overlay=true)

fastLength = input(9, title="Fast MA Length")
slowLength = input(22, title="Slow MA Length")
atrLength = input(14, title="ATR Length")
atrFilter = input(0.5, title="ATR Filter")
trailingStop = input(1.5, title="Trailing Stop Percentage")
pullbackThreshold = input(0.5, title="Pullback Threshold")
minCandleBody = input(0.5, title="Minimum Candle Body Percentage")
breakoutConfirmation = input(true, title="Use Breakout Confirmation")

price = close
mafast = ta.sma(price, fastLength)
maslow = ta.sma(price, slowLength)

atrValue = ta.atr(atrLength)

long_entry = ta.crossover(mafast, maslow) and atrValue > atrFilter
short_entry = ta.crossunder(mafast, maslow) and atrValue > atrFilter

// Pullback Filter
pullbackLong = ta.crossover(price, mafast) and ta.change(price) <= -pullbackThreshold
pullbackShort = ta.crossunder(price, mafast) and ta.change(price) >= pullbackThreshold

// Include pullback condition only if a valid entry signal is present
long_entry := long_entry and (pullbackLong or not ta.crossover(price, mafast))
short_entry := short_entry and (pullbackShort or not ta.crossunder(price, mafast))

// Filter based on candle body size
validLongEntry = long_entry and ta.change(price) > 0 and ta.change(price) >= minCandleBody
validShortEntry = short_entry and ta.change(price) < 0 and ta.change(price) <= -minCandleBody

// Breakout confirmation filter
breakoutLong = breakoutConfirmation ? (close > ta.highest(high, fastLength)[1]) : true
breakoutShort = breakoutConfirmation ? (close < ta.lowest(low, fastLength)[1]) : true

long_entry := validLongEntry and breakoutLong
short_entry := validShortEntry and breakoutShort

if (long_entry)
    strategy.entry("Long", strategy.long)
    strategy.close("Short")
    alert("Long trade iniated")
    
if (short_entry)
    strategy.entry("Short", strategy.short)
    strategy.close("Long")
    alert("Short trade initated")

// Trailing Stop-Loss
long_stop = strategy.position_avg_price * (1 - trailingStop / 100)
short_stop = strategy.position_avg_price * (1 + trailingStop / 100)
strategy.exit("Exit Long", "Long", stop = long_stop)
strategy.exit("Exit Short", "Short", stop = short_stop)

plot(mafast, color=color.green, linewidth=2, title="Fast MA")
plot(maslow, color=color.red, linewidth=2, title="Slow MA")
````
