# Supertrend Strategy

- url: https://www.tradingview.com/script/8QXGsO4U/
- type: strategy
- pine_id: PUB;cdee8f75e94447f985217b23081896e9
- version: 1.0

## Description

The [b]Supertrend Strategy[/b] was created based on the Supertrend and Relative Strength Index (RSI) indicators, widely respected tools in technical analysis. This strategy combines these two indicators to capture market trends with precision and reliability, looking for optimizing exit levels at oversold or overbought price levels.

The Supertrend indicator identifies trend direction based on price and volatility by using the Average True Range (ATR). The ATR measures market volatility by calculating the average range between an asset’s high and low prices over a set period. It provides insight into price fluctuations, with higher ATR values indicating increased volatility and lower values suggesting stability. The Supertrend Indicator plots a line above or below the price, signaling potential buy or sell opportunities: when the price closes above the Supertrend line, an uptrend is indicated, while a close below the line suggests a downtrend. This line shifts as price movements and volatility levels change, acting as both a trailing stop loss and trend confirmation. 

To enhance the Supertrend strategy, the Relative Strength Index (RSI) has been added as an exit criterion. As a momentum oscillator, the RSI indicates overbought (usually above 70) or oversold (usually below 30) conditions. This integration allows trades to close when the asset is overbought or oversold, capturing gains before a possible reversal, even if the percentage take profit level has not been reached. This mechanism aims to prevent losses due to market reversals before the Supertrend signal changes.

[b]### Key Features[/b]

[b]1. **Entry criteria**:[/b]
   - The strategy uses the Supertrend indicator calculated by adding or subtracting a multiple of the ATR from the closing price, depending on the trend direction.
   - When the price crosses above the Supertrend line, the strategy signals a long (buy) entry. Conversely, when the price crosses below, it signals a short (sell) entry.
- The strategy performs a reversal if there is an open position and a change in the direction of the supertrend occurs

   [b]2. **Exit criteria**:[/b]
-	Take profit of 30% (default) on the average position price.
-	Oversold (≤ 5) or overbought (≥ 95) RSI
-	Reversal when there is a change in direction of the Supertrend

[b]3. **No Repainting**:[/b]
   - This strategy is not subject to repainting, [b]as long as the timeframe configured on your chart is the same as the supertrend timeframe [/b].

[b]4. **Position Sizing by Equity and risk management**:[/b]
   - This strategy has a default configuration to operate with 35% of the equity.  At the time of opening the position, the supertrend line is typically positioned at about 12 to 16% of the entry price. This way, the strategy is putting at risk about 16% of 35% of equity, that is, around 5.6% of equity for each trade. The percentage of equity can be adjusted by the user according to their risk management.

[b]5. **Backtest results**:[/b]
   - This strategy was subjected to deep backtesting and operations in replay mode, including transaction fees of 0.12%, and slippage of 5 ticks. 
- The past results in deep backtest and replay mode were compatible and profitable (Variable results depending on the take profit used, supertrend and RSI parameters).  However, it should be noted that few operations were evaluated, since the currency in question has been created for a short time and the frequency of operations is relatively small.
- Past results are no guarantee of future results. The strategy's backtest results may even be due to overfitting with past data.

[image]https://www.tradingview.com/x/hEugZCns/[/image]

[b6. ]Default Settings[/b]
Chart timeframe: 2h
Supertrend Factor: 3.42
ATR period: 14
Supertrend timeframe: 2 h
RSI timeframe: 15 min
RSI Lenght: 5 min
RSI Upper limit: 95
RSI Lower Limit: 5
Take Profit: 30%

 [symbol="BYBIT:1000000MOGUSDT.P"]BYBIT:1000000MOGUSDT.P[/symbol]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © felipemiransan

//@version=5
strategy("Supertrend Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=35)

// Function for Supertrend
supertrend(_factor, _atrPeriod) =>
    [out, _] = ta.supertrend(_factor, _atrPeriod)
    out

// Supertrend Settings
factor = input.float(3.42, title="Supertrend Factor")
atrPeriod = input.int(14, title="ATR Period")
tf2 = input.timeframe("120", title="Supertrend Timeframe")

// RSI Settings
rsi_tf = input.timeframe("15", title="RSI Timeframe")
rsiLength = input.int(5, title="RSI Length")
rsiUpper = input.int(95, title="RSI Upper Limit")  
rsiLower = input.int(5, title="RSI Lower Limit")   

// RSI Timeframe
rsi_tf_value = request.security(syminfo.tickerid, rsi_tf, ta.rsi(close, rsiLength), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

// Supertrend Timeframe
supertrend_tf2 = request.security(syminfo.tickerid, tf2, supertrend(factor, atrPeriod), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

// Take Profit Settings (Percentage in relation to the average price)
takeProfitPercent = input.float(30, title="Take Profit", step=0.1) / 100

// Entry conditions based on price crossover with Supertrend Timeframe
longCondition = ta.crossover(close, supertrend_tf2) and barstate.isconfirmed
shortCondition = ta.crossunder(close, supertrend_tf2) and barstate.isconfirmed

// Execution of reversal orders with closing of previous position
if (longCondition)
    // Close a short position before opening a long position
    if (strategy.position_size < 0)
        strategy.close("Short", comment="Close Short for Long Entry")
    strategy.entry("Long", strategy.long)

if (shortCondition)
    // Close long position before opening short position
    if (strategy.position_size > 0)
        strategy.close("Long", comment="Close Long for Short Entry")
    strategy.entry("Short", strategy.short)

// Calculate take profit levels relative to the average entry price
if (strategy.position_size > 0)
    takeProfitLong = strategy.position_avg_price * (1 + takeProfitPercent)
    strategy.exit("Take Profit Long", "Long", limit=takeProfitLong)

if (strategy.position_size > 0 and (rsi_tf_value >= rsiUpper))
    strategy.close("Long", comment="RSI Take Profit Long")

if (strategy.position_size < 0)
    takeProfitShort = strategy.position_avg_price * (1 - takeProfitPercent)
    strategy.exit("Take Profit Short", "Short", limit=takeProfitShort)

if (strategy.position_size < 0 and (rsi_tf_value <= rsiLower))
    strategy.close("Short", comment="RSI Take Profit Short")

// Plot Supertrend timeframe with commit check to avoid repainting
plot(barstate.isconfirmed ? supertrend_tf2 : na, color=color.blue, title="Supertrend Timeframe (120 min)", linewidth=1)

// Plot RSI for visualization
plot(rsi_tf_value, "RSI", color=color.purple)
hline(rsiUpper, "RSI Upper", color=color.red)
hline(rsiLower, "RSI Lower", color=color.green)
````
