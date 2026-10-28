# NUTJP CDC ActionZone 2024

- url: https://www.tradingview.com/script/LuB0pC90/
- type: strategy
- pine_id: PUB;f06f2471512f4a57b81b62f5533b4c5e
- version: 1.0

## Description

1. Core Components of the Strategy

	•	Fast EMA and Slow EMA:
	•	The Fast EMA (shorter period) is more reactive to recent price changes.
	•	The Slow EMA (longer period) reacts slower and provides a smoother view of the overall trend.
	•	Relationship Between Fast EMA and Slow EMA:
	•	When the Fast EMA is above the Slow EMA, the market is considered Bullish.
	•	When the Fast EMA is below the Slow EMA, the market is considered Bearish.

2. Zones Based on Price and EMAs

The strategy defines six zones based on the position of the price, Fast EMA, and Slow EMA:

	1.	Green Zone (Buy):
	•	Bullish trend (Fast EMA > Slow EMA)
	•	Price is above the Fast EMA.
	•	Indicates a strong uptrend and suggests buying.
	2.	Blue and Light Blue Zones (Pre-Buy):
	•	Price is above the Fast EMA but below or near the Slow EMA.
	•	Represents potential bullish signals but not strong enough to trigger a buy.
	3.	Red Zone (Sell):
	•	Bearish trend (Fast EMA < Slow EMA)
	•	Price is below the Fast EMA.
	•	Indicates a strong downtrend and suggests selling or avoiding long trades.
	4.	Orange and Yellow Zones (Pre-Sell):
	•	Price is below the Fast EMA but above or near the Slow EMA.
	•	Represents potential bearish signals but not strong enough to trigger a sell.

These zones help traders visualize the market conditions and determine whether to buy, hold, or sell.

3. Buy and Sell Conditions

	•	Buy Condition:
A buy signal is triggered when:
	•	The price enters the Green Zone (Bullish trend and price > Fast EMA).
	•	It’s the first green candle after a non-green candle.
	•	Sell Condition:
A sell signal is triggered when:
	•	The price enters the Red Zone (Bearish trend and price < Fast EMA).
	•	It’s the first red candle after a non-red candle.

4. Trade Execution Logic

	•	Buy:
The strategy enters a long position (buy) when the above buy condition is met.
	•	Sell:
The strategy exits the long position when the sell condition is met.
Note: It doesn’t support short trades, meaning it doesn’t enter sell positions.

5. Momentum-Based Signals (Optional)

The indicator also includes momentum signals using Stochastic RSI to provide additional buy/sell signals:

	•	These are based on oversold and overbought levels of the Stochastic RSI.
	•	It filters signals depending on whether the trend is Bullish or Bearish.

6. Visual Features

The indicator is designed to make the trading zones and signals visually intuitive:

	•	Bar Colors:
Candlesticks are colored based on the current zone (e.g., Green for Buy, Red for Sell).
	•	EMA Lines:
The Fast EMA and Slow EMA are plotted, making it easy to see crossover points.
	•	Buy/Sell Signals:
Marked with shapes (e.g., circles) below/above bars for clarity.

7. Strategy Assumptions

	•	Trend-Following Nature:
This strategy assumes that trends persist. It works best in trending markets but might give false signals in ranging markets.
	•	Lagging Nature of EMAs:
As EMAs are lagging indicators, buy and sell signals may occur after significant moves have already begun or ended.
	•	Momentum Confirmation (Optional):
Adding momentum signals can help filter false signals, though it’s not part of the core logic.

8. Usage Recommendations

	•	Timeframes:
Works on various timeframes but may perform better on higher timeframes (e.g., 1H, Daily) to reduce noise.
	•	Markets:
Can be applied to stocks, forex, and cryptocurrencies.
	•	Backtesting and Optimization:
Before live trading, backtest the strategy with different EMA periods and other parameters to find optimal settings for your market and timeframe.

## Source Code

````pine
//@version=5
strategy("NUTJP CDC ActionZone 2024", overlay=true, precision=6, commission_value=0.1, slippage=3)

//****************************************************************************//
// CDC Action Zone is based on a simple EMA crossover
// between [default] EMA12 and EMA26
//****************************************************************************//

// Define User Input Variables
xsrc = input.source(title='Source Data', defval=close)
xprd1 = input.int(title='Fast EMA period', defval=12)
xprd2 = input.int(title='Slow EMA period', defval=26)
xsmooth = input.int(title='Smoothing period (1 = no smoothing)', defval=1)
fillSW = input.bool(title='Paint Bar Colors', defval=true)
fastSW = input.bool(title='Show fast moving average line', defval=true)
slowSW = input.bool(title='Show slow moving average line', defval=true)

xfixtf = input.bool(title='** Use Fixed time frame Mode (advanced) **', defval=false)
xtf = input.timeframe(title='** Fix chart to which time frame? **', defval='D')

startDate = input.time(timestamp("2018-01-01 00:00"), title="Start Date")
endDate = input.time(timestamp("2069-12-31 23:59"), title="End Date")

//****************************************************************************//
// Calculate Indicators
f_secureSecurity(_symbol, _res, _src) => request.security(_symbol, _res, _src[1], lookahead=barmerge.lookahead_on)

xPrice = ta.ema(xsrc, xsmooth)

FastMA = xfixtf ? ta.ema(f_secureSecurity(syminfo.tickerid, xtf, ta.ema(xsrc, xprd1)), xsmooth) : ta.ema(xPrice, xprd1)

SlowMA = xfixtf ? ta.ema(f_secureSecurity(syminfo.tickerid, xtf, ta.ema(xsrc, xprd2)), xsmooth) : ta.ema(xPrice, xprd2)

Bull = FastMA > SlowMA
Bear = FastMA < SlowMA

// Define Color Zones
Green = Bull and xPrice > FastMA
Red = Bear and xPrice < FastMA

// Buy and Sell Conditions
buycond = Green and not Green[1]
sellcond = Red and not Red[1]

inDateRange = (time >= startDate and time <= endDate)

if inDateRange
    if buycond
        strategy.entry("Long", strategy.long, qty=100)
    if sellcond
        strategy.close("Long")

//****************************************************************************//
// Display color on chart
bColor = Green ? color.green :
         Red ? color.red :
         color.black
barcolor(color=fillSW ? bColor : na)

// Display MA lines
FastL = plot(fastSW ? FastMA : na, "Fast EMA", color=color.new(color.red, 0), style=xfixtf ? plot.style_stepline : plot.style_line)
SlowL = plot(slowSW ? SlowMA : na, "Slow EMA", color=color.new(color.blue, 0), style=xfixtf ? plot.style_stepline : plot.style_line)
fill(FastL, SlowL, Bull ? color.new(color.green, 90) : (Bear ? color.new(color.red, 90) : na))
````
