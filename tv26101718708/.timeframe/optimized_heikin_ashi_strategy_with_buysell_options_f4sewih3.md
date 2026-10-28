# Optimized Heikin Ashi Strategy with Buy/Sell Options

- url: https://www.tradingview.com/script/f4SEwIH3-Optimized-Heikin-Ashi-Strategy-with-Buy-Sell-Options/
- type: strategy
- pine_id: PUB;c467dd2994814fd094b23dc1d3e12bd5
- version: 2.0

## Description

[b]Strategy Name:[/b]
Optimized Heikin Ashi Strategy with Buy/Sell Options

[b]Description:[/b]
The Optimized Heikin Ashi Strategy is a trend-following strategy designed to capitalize on market trends by utilizing the smoothness of Heikin Ashi candles. This strategy provides flexible options for trading, allowing users to choose between Buy Only (long-only), Sell Only (short-only), or using both in alternating conditions based on the Heikin Ashi candle signals. The strategy works on any market, but it performs especially well in markets where trends are prevalent, such as cryptocurrency or Forex.

This script offers customizable parameters for the backtest period, Heikin Ashi timeframe, stop loss, and take profit levels, allowing traders to optimize the strategy for their preferred markets or assets.

[b]Key Features:[/b]
Trade Type Options:
Buy Only: Enter a long position when a green Heikin Ashi candle appears and exit when a red candle appears.
Sell Only: Enter a short position when a red Heikin Ashi candle appears and exit when a green candle appears.
Stop Loss and Take Profit:
Customizable stop loss and take profit percentages allow for flexible risk management.
The default stop loss is set to 2%, and the default take profit is set to 4%, maintaining a favorable risk/reward ratio.
Heikin Ashi Timeframe:
Traders can select the desired timeframe for Heikin Ashi candle calculation (e.g., 4-hour Heikin Ashi candles for a 1-hour chart).
The strategy smooths out price action and reduces noise, providing clearer signals for entry and exit.

[b]Inputs:[/b]
Backtest Start Date / End Date: Specify the period for testing the strategy’s performance.
Heikin Ashi Timeframe: Select the timeframe for Heikin Ashi candle generation. A higher timeframe helps smooth the trend, which is beneficial for trading lower timeframes.
Stop Loss (in %) and Take Profit (in %): Enable or disable stop loss and take profit, and adjust the levels based on market conditions.
Trade Type: Choose between Buy Only or Sell Only based on your market outlook and strategy preference.
[b]Strategy Performance:[/b]
In testing with BTC/USD, this strategy performed well in a 4-hour Heikin Ashi timeframe applied on a 1-hour chart over a period from January 1, 2024, to September 12, 2024. The results were as follows:

Initial Capital: 1 USD
Order Size: 100% of equity
Net Profit: +30.74 USD (3,073.52% return)
Percent Profitable: 78.28% of trades were winners.
Profit Factor: 15.825, indicating that the strategy's profitable trades far outweighed its losses.
Max Drawdown: 4.21%, showing low risk exposure relative to the large profit potential.
This strategy is ideal for both beginner and advanced traders who are looking to follow trends and avoid market noise by using Heikin Ashi candles. It is also well-suited for traders who prefer automated risk management through the use of stop loss and take profit levels.

Recommended Use:
Best Markets: This strategy works well on trending markets like cryptocurrency, Forex, or indices.
Timeframes: Works best when applied to lower timeframes (e.g., 1-hour chart) with a higher Heikin Ashi timeframe (e.g., 4-hour candles) to smooth out price action.
Leverage: The strategy performs well with leverage, but users should consider using 2x to 3x leverage to avoid excessive risk and potential liquidation. The strategy's low drawdown allows for moderate leverage use while maintaining risk control.
Customization: Traders can adjust the stop loss and take profit percentages based on their risk appetite and market conditions. A default setting of a 2% stop loss and 4% take profit provides a balanced risk/reward ratio.
Notes:
Risk Management: Traders should enable stop loss and take profit settings to maintain effective risk management and prevent large drawdowns during volatile market conditions.
Optimization: This strategy can be further optimized by adjusting the Heikin Ashi timeframe and risk parameters based on specific market conditions and assets.
Backtesting: The built-in backtesting functionality allows traders to test the strategy across different market conditions and historical data to ensure robustness before applying it to live trading.

[b]How to Apply:[/b]
Select your preferred market and chart.
Choose the appropriate Heikin Ashi timeframe based on the chart's timeframe. (e.g., use 4-hour Heikin Ashi candles for 1-hour chart trends).

Adjust stop loss and take profit based on your risk management preference.
Run backtesting to evaluate its performance before applying it in live trading.

This strategy can be further modified and optimized based on personal trading style and market conditions. It’s important to monitor performance regularly and adjust settings as needed to align with market behavior.

## Source Code

````pine
//@version=5
strategy("Optimized Heikin Ashi Strategy with Buy/Sell Options and Alerts", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100, initial_capital=1)

// User inputs for customizing backtest settings
startDate = input.time(timestamp("2023-01-01 00:00"), title="Backtest Start Date", tooltip="Start date for the backtest")
endDate = input.time(timestamp("2024-01-01 00:00"), title="Backtest End Date", tooltip="End date for the backtest")

// Input for Heikin Ashi timeframe optimization
ha_timeframe = input.timeframe("D", title="Heikin Ashi Timeframe", tooltip="Choose the timeframe for Heikin Ashi candles")

// Inputs for optimizing stop loss and take profit
use_stop_loss = input.bool(true, title="Use Stop Loss")
stop_loss_percent = input.float(2.0, title="Stop Loss (%)", minval=0.0, tooltip="Set stop loss percentage")
use_take_profit = input.bool(true, title="Use Take Profit")
take_profit_percent = input.float(4.0, title="Take Profit (%)", minval=0.0, tooltip="Set take profit percentage")

// Input to choose Buy, Sell, or Both
trade_type = input.string("Buy Only", options=["Buy Only", "Sell Only"], title="Trade Type", tooltip="Choose whether to only Buy or only Sell")

// Heikin Ashi calculation on a user-defined timeframe
ha_open = request.security(syminfo.tickerid, ha_timeframe, ta.sma(open, 2), barmerge.gaps_off, barmerge.lookahead_on)
ha_close = request.security(syminfo.tickerid, ha_timeframe, ta.sma(close, 2), barmerge.gaps_off, barmerge.lookahead_on)
ha_high = request.security(syminfo.tickerid, ha_timeframe, math.max(high, close), barmerge.gaps_off, barmerge.lookahead_on)
ha_low = request.security(syminfo.tickerid, ha_timeframe, math.min(low, open), barmerge.gaps_off, barmerge.lookahead_on)

// Heikin Ashi candle colors
ha_bullish = ha_close > ha_open // Green candle
ha_bearish = ha_close < ha_open // Red candle

// Backtest period filter
inDateRange = (time >= startDate) and (time <= endDate)

// Trading logic depending on user input
if (inDateRange)  // Ensures trades happen only in the selected period
    if (trade_type == "Buy Only")  // Buy when green, Sell when red (exit long)
        if (ha_bullish and strategy.position_size <= 0)  // Buy on green candle only if no position is open
            strategy.entry("Buy", strategy.long)
        if (ha_bearish and strategy.position_size > 0)  // Sell (close the long position) on red candle
            strategy.close("Buy")

    if (trade_type == "Sell Only")  // Sell when red, Exit short when green
        if (ha_bearish and strategy.position_size >= 0)  // Short on red candle only if no position is open
            strategy.entry("Sell", strategy.short)
        if (ha_bullish and strategy.position_size < 0)  // Exit the short position on green candle
            strategy.close("Sell")

// Add Stop Loss and Take Profit conditions if enabled
if (use_stop_loss)
    strategy.exit("Stop Loss", from_entry="Buy", stop=strategy.position_avg_price * (1 - stop_loss_percent / 100))
    
if (use_take_profit)
    strategy.exit("Take Profit", from_entry="Buy", limit=strategy.position_avg_price * (1 + take_profit_percent / 100))

// Plot Heikin Ashi candles on the chart
plotcandle(ha_open, ha_high, ha_low, ha_close, color=ha_bullish ? color.green : color.red)

// Plot Buy and Sell signals only in relevant modes
plotshape(series=ha_bullish and strategy.position_size <= 0 and trade_type == "Buy Only", title="Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY", size=size.small)
plotshape(series=ha_bearish and strategy.position_size > 0 and trade_type == "Buy Only", title="Sell Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL", size=size.small)

plotshape(series=ha_bearish and strategy.position_size >= 0 and trade_type == "Sell Only", title="Sell Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL", size=size.small)
plotshape(series=ha_bullish and strategy.position_size < 0 and trade_type == "Sell Only", title="Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY", size=size.small)

// Alert conditions
alertcondition(ha_bullish and strategy.position_size <= 0, title="Buy Signal", message="Heikin Ashi candle turned green. Buy signal triggered.")
alertcondition(ha_bearish and strategy.position_size > 0, title="Sell Signal", message="Heikin Ashi candle turned red. Sell signal triggered.")
````
