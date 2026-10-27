# buy/sell signals with Support/Resistance (InvestYourAsset)

- url: https://www.tradingview.com/script/fa5ADgD2-buy-sell-signals-with-Support-Resistance-InvestYourAsset/
- type: indicator
- pine_id: PUB;2b92666defc14270a7d4d6ade0e3ba3e
- version: 1.0

## Description

[i]   📣The present indicator is a MACD based buy/sell signals indicator with support and resistance, that can be used to identify potential buy and sell signals in a security's price. 

   📣It is based on the MACD (Moving Average Convergence Divergence) indicator, which is a momentum indicator that shows the relationship between two moving averages of a security's price.

   📣 The indicator also plots support and resistance levels, which can be used to confirm buy and sell signals. The support and resistance can also be used as a stoploss for existing position. 

👉 To use the indicator, simply add it to your trading chart. The indicator will plot three sections:

   📈  [b]Price and Signals:[/b] This section plots the security's price and the MACD buy and sell signals.

   📈 [b] MACD Oscillator: [/b]This section plots the MACD oscillator, which is a histogram that shows the difference between the two moving averages.

   📈  [b]Moving Averages: [/b]This section plots the two moving averages that the MACD oscillator is based on.

   📈  [b]Support and Resistance:[/b] This section plots support and resistance levels, which are calculated based on the security's recent price action.


👉[b] To identify buy and sell signals, you can look for the following:[/b]
https://www.tradingview.com/x/DuZK8OFU/

   📈 [b] Buy signal: [/b]When shorter Moving Average crosses over longer Moving Average.

   📈  [b]Sell signal:[/b] When shorter moving average crosses under longer moving average.

   📈  You can also look for divergences between the MACD oscillator and the security's price. A divergence occurs when the MACD oscillator is moving in one direction, but the security's price is moving in the opposite direction. Divergences can be a sign of a potential trend reversal.

👉 [b]To confirm buy and sell signals, you can look for support and resistance levels take a look at below snapshot. If a buy signal occurs at a support level, it is a stronger signal than if it occurs at a random price level. Similarly, if a sell signal occurs at a resistance level, it is a stronger signal than if it occurs at a random price level.[/b]
https://www.tradingview.com/x/6teQE57v/

 ⚡[b] Here is a example of how to use the indicator to identify buy signal:[/b]
https://www.tradingview.com/x/w6DsEtgD/

☑ Add the indicator to your trading chart.

☑Look for a buy signal when short MA crosses over Long MA.

☑Look for the buy signal to occur at a support level.

☑Enter a long position at the next candle.

☑Place a stop loss order below the support level.

☑Take profit when the MACD line crosses below the signal line, or when the security reaches a resistance level.


 ⚡ [b]Here is an example of how to use the indicator to identify a sell signal:[/b]
https://www.tradingview.com/x/pnm3Sl82/

☑Add the indicator to your trading chart.

☑Look for a sell signal, when shorter moving average crosses under longer moving average.

☑Look for the sell signal to occur at a resistance level.

☑Enter a short position at the next candle.

☑Place a stop loss order above the resistance level.

☑Take profit when the MACD line crosses above the signal line, or when the security reaches a support level.


✅Things to consider while using the indicator:

📈Look for buy signals in an uptrend and sell signals in a downtrend. This will increase the likelihood of your trades being successful.

📈Place your stop losses below the previous swing low or support for buy signals and above the previous swing high or resistance for sell signals. This will help to limit your losses if the trade goes against you.

📈Consider taking profits at key resistance and support levels. This will help you to lock in your profits and avoid giving them back to the market.

Follow us for timely updates regarding indicators that we may publish in future and give it a like if you appreciate the indicator.[/i]

## Source Code

````pine
//@version=5
indicator("buy/sell signals with Support/Resistance (InvestYourAsset)", overlay=true)

// Input parameters
ma1 = input(12, title="Short MA Period")
ma2 = input(26, title="Long MA Period")

// Fetching data
symbol = input("NA", title="Ticker Symbol")


data = request.security(symbol, "D", close)

// Filter data based on date range
var float filteredClose = na
if (time >= timestamp(year, month, dayofmonth, 00, 00) and time <= timestamp(year, month, dayofmonth, 23, 59))
    filteredClose := close

// MACD Calculation
short_ma = ta.sma(filteredClose, ma1)
long_ma = ta.sma(filteredClose, ma2)
macd_line = short_ma - long_ma

// Signal Generation
positions = ta.crossover(short_ma, long_ma)
signals = positions ? 1 : ta.crossunder(short_ma, long_ma) ? -1 : 0

// Support and Resistance Calculation
lookback = input(20, title="Lookback Period for S&R")
swingHigh = ta.pivothigh(high, lookback, lookback)
swingLow = ta.pivotlow(low, lookback, lookback)

// Plotting
plot(data, color=color.blue, title="Close Price")


plotshape(signals == 1, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Long Signal")
plotshape(signals == -1, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Short Signal")


hline(0, "Zero Line", color=color.gray)
plot(macd_line, color=color.red, title="MACD Oscillator", style=plot.style_histogram, linewidth=1, transp=0)


plot(short_ma, color=color.orange, title="Short MA")
plot(long_ma, color=color.purple, title="Long MA")


plot(swingHigh, color=color.red, style=plot.style_stepline_diamond, linewidth=2, title="Swing High")
plot(swingLow, color=color.green, style=plot.style_stepline_diamond, linewidth=2, title="Swing Low")
````
