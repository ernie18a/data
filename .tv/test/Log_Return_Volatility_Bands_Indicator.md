<!-- tradingview-pine-id: PUB;daad87d371bc4fdb89194e46c26415c9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Log Return & Volatility Bands Indicator

Source: https://www.tradingview.com/script/1orQcP2s-Log-Return-Volatility-Bands-Indicator/

## Description

**Log Return & Volatility Bands Indicator**

This Pine Script (v5) indicator for TradingView translates the log-transformation and volatility-tracking concepts used in quantitative finance (such as GARCH modeling) directly onto your chart.

**Key Features:**

* **Logarithmic Returns:** Calculates daily log returns ($\ln(P_t / P_{t-1})$) behind the scenes to accurately measure relative price changes, removing the distorting effect of long-term exponential trends.
* **Annualized Volatility:** Computes the rolling standard deviation of these log returns over a user-defined period, scaling it by the square root of trading days ($\sqrt{252}$) to display annualized market volatility percentage.
* **Volatility Channels:** Plots dynamic upper and lower bands around a Simple Moving Average (SMA) of the price to help identify market breakouts, periods of high uncertainty, and potential mean-reversion points.

**How to Use:**

1. Open TradingView and load your preferred ticker (e.g., **NASDAQ:MU**).
2. Open the **Pine Editor**, paste the script, and click **Add to Chart**.
3. Adjust the length and multiplier parameters in the indicator settings to match your preferred trading timeframe and risk tolerance.

---

## Source Code

````pine
//@version=6
indicator("Log Return & Volatility Bands Indicator", overlay=true)

// 1. Configurable parameters
length = input.int(20, title="Calculation Period")
mult   = input.float(2.0, title="Standard Deviation Multiplier")

// 2. Logarithmic returns calculation
logReturn = math.log(close / close[1])

// 3. Annualized historical volatility based on log returns
volatility = ta.stdev(logReturn, length) * math.sqrt(252) * 100

// 4. Volatility channels construction around the price
smaPrice  = ta.sma(close, length)
stdPrice  = ta.stdev(close, length)
upperBand = smaPrice + (stdPrice * mult)
lowerBand = smaPrice - (stdPrice * mult)

// 5. Chart plotting
plot(smaPrice, color=color.blue, title="Moving Average (20)")
p1 = plot(upperBand, color=color.red, title="Upper Band")
p2 = plot(lowerBand, color=color.green, title="Lower Band")
fill(p1, p2, color=color.new(color.gray, 90), title="Volatility Channel")
````
