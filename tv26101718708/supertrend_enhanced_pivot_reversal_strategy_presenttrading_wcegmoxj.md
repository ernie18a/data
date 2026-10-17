# SuperTrend Enhanced Pivot Reversal - Strategy [PresentTrading]

- url: https://www.tradingview.com/script/wcegMOXj-SuperTrend-Enhanced-Pivot-Reversal-Strategy-PresentTrading/
- type: strategy
- pine_id: PUB;0381d786429b483f92c4cdcbd22110db
- version: 2.0

## Description

- Introduction and How it is Different
The SuperTrend Enhanced Pivot Reversal is a unique approach to trading that combines the best of two worlds: the precision of pivot reversal points and the trend-following power of the SuperTrend indicator. This strategy is designed to provide traders with clear entry and exit points, while also filtering out potentially false signals using the SuperTrend indicator.

BTCUSDT 6hr 
https://www.tradingview.com/x/AjgMCGZ9/

ETHBTC 6hr
https://www.tradingview.com/x/TYAD8JkP/

Unlike traditional pivot reversal strategies, this approach uses the SuperTrend indicator as a filter. This means that it only takes trades that align with the overall trend, as determined by the SuperTrend indicator. This can help to reduce the number of false signals and improve the overall profitability of the strategy.

The Pivot Reversal Strategy with SuperTrend Filter is particularly well-suited to the cryptocurrency market for the reason of High Volatility. This means that prices can change rapidly in a very short time, making it possible to make a profit quickly. The strategy's use of pivot points allows traders to take advantage of these rapid price changes by identifying potential reversal points


- Strategy: How it Works
The strategy works by identifying pivot reversal points, which are points in the price chart where the price is likely to reverse. These points are identified using a combination of the ta.pivothigh and ta.pivotlow functions, which find the highest and lowest points in the price chart over a certain period.

Once a pivot reversal point is identified, the strategy checks the direction of the SuperTrend indicator. If the SuperTrend is positive (indicating an uptrend), the strategy will only take long trades. If the SuperTrend is negative (indicating a downtrend), the strategy will only take short trades.

The strategy also includes a stop loss level, which is set as a percentage of the entry price. This helps to limit potential losses if the price moves in the opposite direction to the trade.

- Trade Direction
The trade direction can be set to "Long", "Short", or "Both". This allows the trader to choose whether they want to take only long trades (buying low and selling high), only short trades (selling high and buying low), or both. This can be useful depending on the trader's view of the market and their risk tolerance.

- Usage
To use the Pivot Reversal Strategy with SuperTrend Filter, simply input the desired parameters into the script and apply it to the price chart of the asset you wish to trade. The strategy will then identify potential trade entry and exit points, which will be displayed on the price chart.

- Default Settings
The default settings for the strategy are as follows:

ATR Length: 5
Factor: 2.618
Trade Direction: Both
Stop Loss Level: 20%
Commission: 0.1%
Slippage: 1
Currency: USD
Each trade: 10% of account equity
Initial capital: $10,000

These settings can be adjusted to suit the trader's preferences and risk tolerance. Always remember to test any changes to the settings using historical data before applying them to live trades.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PresentTrading

//@version=5
strategy("SuperTrend Enhanced Pivot Reversal - Strategy [PresentTrading]", overlay=true, precision=3, default_qty_type=strategy.cash, 
 commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1, 
  currency=currency.USD, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, initial_capital= 10000)

// Pivot Reversal parameters
leftBars = input(6)
rightBars = input(3)
swh = ta.pivothigh(leftBars, rightBars)
swl = ta.pivotlow(leftBars, rightBars)

// SuperTrend parameters
atrPeriod = input(5, "ATR Length")
factor = input.float(2.618, "Factor", step = 0.01)

[superTrend, direction] = ta.supertrend(factor, atrPeriod)

// Plot the SuperTrend
plot(superTrend, title="SuperTrend", color=color.blue)


// Trade Direction parameter
tradeDirection = input.string(title="Trade Direction", defval="Both", options=["Long", "Short", "Both"])

// Stop Loss Level (in %)
stopLossLevel = input(20, title="Stop Loss Level (%)")

// Convert the stop loss level to a price difference
stopLossPrice = stopLossLevel / 100


// Long entry
swh_cond = not na(swh)
hprice = 0.0
hprice := swh_cond ? swh : hprice[1]
le = false
le := swh_cond ? true : (le[1] and high > hprice ? false : le[1])
if (le and direction < 0 and (tradeDirection == "Long" or tradeDirection == "Both"))
    strategy.entry("PivRevLE", strategy.long, comment="PivRevLE", stop=hprice + syminfo.mintick)
    strategy.exit("Exit Long", "PivRevLE", stop = hprice * (1 - stopLossPrice))

// Short entry
swl_cond = not na(swl)
lprice = 0.0
lprice := swl_cond ? swl : lprice[1]
se = false
se := swl_cond ? true : (se[1] and low < lprice ? false : se[1])
if (se and direction > 0 and (tradeDirection == "Short" or tradeDirection == "Both"))
    strategy.entry("PivRevSE", strategy.short, comment="PivRevSE", stop=lprice - syminfo.mintick)
    strategy.exit("Exit Short", "PivRevSE", stop = lprice * (1 + stopLossPrice))


// Closing positions when the tradeDirection is one-sided or when SuperTrend direction changes
if ((tradeDirection == "Long" and se and direction < 0) or (tradeDirection == "Long" and direction < 0))
    strategy.close("PivRevLE")
if ((tradeDirection == "Short" and le and direction > 0) or (tradeDirection == "Short" and direction > 0))
    strategy.close("PivRevSE")

// Plot pivot highs and lows
plotshape(swh_cond, title="Pivot Highs", location=location.belowbar, color=color.green, style=shape.triangleup)
plotshape(swl_cond, title="Pivot Lows", location=location.abovebar, color=color.red, style=shape.triangledown)

// Closing positions when the tradeDirection is one-sided
if (tradeDirection == "Long" and se and direction < 0)
    strategy.close("PivRevLE")
if (tradeDirection == "Short" and le and direction > 0)
    strategy.close("PivRevSE")
````
