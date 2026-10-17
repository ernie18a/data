# 02 SMC + BB Breakout (Improved)

- url: https://www.tradingview.com/script/Y4kqxvA7-02-SMC-BB-Breakout-Improved/
- type: strategy
- pine_id: PUB;2d4bdc2a65b1460b8e56132f8f28f9c2
- version: 6.0

## Description

This strategy combines Smart Money Concepts (SMC) with Bollinger Band breakouts to identify potential trading opportunities. SMC focuses on identifying key price levels and market structure shifts, while Bollinger Bands help pinpoint overbought/oversold conditions and potential breakout points. The strategy also incorporates higher timeframe trend confirmation to filter out trades that go against the prevailing trend.

Key Components:

Bollinger Bands:

Calculated using a Simple Moving Average (SMA) of the closing price and a standard deviation multiplier.
The strategy uses the upper and lower bands to identify potential breakout points.
The SMA (basis) acts as a centerline and potential support/resistance level.
The fill between the upper and lower bands can be toggled by the user.
Higher Timeframe Trend Confirmation:

The strategy allows for optional confirmation of the current trend using a higher timeframe (e.g., daily).
It calculates the SMA of the higher timeframe's closing prices.
A bullish trend is confirmed if the higher timeframe's closing price is above its SMA.
This helps filter out trades that go against the prevailing long-term trend.
Smart Money Concepts (SMC):

Order Blocks:
Simplified as recent price clusters, identified by the highest high and lowest low over a specified lookback period.
These levels are considered potential areas of support or resistance.
Liquidity Zones (Swing Highs/Lows):
Identified by recent swing highs and lows, indicating areas where liquidity may be present.
The Swing highs and lows are calculated based on user defined lookback periods.
Market Structure Shift (MSS):
Identifies potential changes in market structure.
A bullish MSS occurs when the closing price breaks above a previous swing high.
A bearish MSS occurs when the closing price breaks below a previous swing low.
The swing high and low values used for the MSS are calculated based on the user defined swing length.
Entry Conditions:

Long Entry:
The closing price crosses above the upper Bollinger Band.
If higher timeframe confirmation is enabled, the higher timeframe trend must be bullish.
A bullish MSS must have occurred.
Short Entry:
The closing price crosses below the lower Bollinger Band.
If higher timeframe confirmation is enabled, the higher timeframe trend must be bearish.
A bearish MSS must have occurred.
Exit Conditions:

Long Exit:
The closing price crosses below the Bollinger Band basis.
Or the Closing price falls below 99% of the order block low.
Short Exit:
The closing price crosses above the Bollinger Band basis.
Or the closing price rises above 101% of the order block high.
Position Sizing:

The strategy calculates the position size based on a fixed percentage (5%) of the strategy's equity.
This helps manage risk by limiting the potential loss per trade.
Visualizations:

Bollinger Bands (upper, lower, and basis) are plotted on the chart.
SMC elements (order blocks, swing highs/lows) are plotted as lines, with user-adjustable visibility.
Entry and exit signals are plotted as shapes on the chart.
The Bollinger band fill opacity is adjustable by the user.
Trading Logic:

The strategy aims to capitalize on Bollinger Band breakouts that are confirmed by SMC signals and higher timeframe trend. It looks for breakouts that align with potential market structure shifts and key price levels (order blocks, swing highs/lows). The higher timeframe filter helps avoid trades that go against the overall trend.

In essence, the strategy attempts to identify high-probability breakout trades by combining momentum (Bollinger Bands) with structural analysis (SMC) and trend confirmation.

Key User-Adjustable Parameters:

Bollinger Bands Length
Standard Deviation Multiplier
Higher Timeframe
Higher Timeframe Confirmation (on/off)
SMC Elements Visibility (on/off)
Order block lookback length.
Swing lookback length.
Bollinger band fill opacity.
This detailed description should provide a comprehensive understanding of the strategy's logic and components.



***DISCLAIMER: This strategy is for educational purposes only. It is not financial advice. Past performance is not indicative of future results. Use at your own risk. Always perform thorough backtesting and forward testing before using any strategy in live trading.***

## Source Code

````pine
//@version=6
strategy('00 SMC + BB Breakout + Momentum Candle + Alerts', overlay=true, initial_capital=10000, commission_type=strategy.commission.percent, commission_value=0.1, slippage=2)

// Inputs
length = input.int(55, title='Bollinger Bands Length')
mult = input.float(2.0, title='Standard Deviation Multiplier')
show_smc = input.bool(true, title='Show SMC Elements')
ob_length = input.int(20, title="Order Block Lookback", minval=5)
swing_length = input.int(12, title="Swing Lookback", minval=5)
momentum_filter = input.bool(true, title="Require Momentum Candle for Entry")
momentum_body_percent = input.float(70, title="Momentum Candle Body %", minval=1, maxval=100) / 100.0 // Percentage of the candle's range that must be the body

// Input for Risk Percentage (Adjustable)
// DEFAULT SET TO 5%
risk_percent_input = input.float(5.0, title="Risk Percent per Trade", minval = 0.1, maxval = 100.0, step = 0.5)

// Bollinger Bands Calculation
basis = ta.sma(close, length)
upper_band = basis + mult * ta.stdev(close, length)
lower_band = basis - mult * ta.stdev(close, length)

// Smart Money Concepts (SMC)
order_block_high = ta.highest(high, ob_length)
order_block_low = ta.lowest(low, ob_length)
recent_swing_high = ta.highest(high, swing_length)
recent_swing_low = ta.lowest(low, swing_length)
previous_high = ta.valuewhen(high > ta.highest(high[1], swing_length), high[1], 0)
previous_low = ta.valuewhen(low < ta.lowest(low[1], swing_length), low[1], 0)
shift_to_bullish = close > previous_high
shift_to_bearish = close < previous_low

// Momentum Candle Check (Strong Body)
candle_range = high - low
candle_body = math.abs(close - open)
body_percentage = candle_range > 0 ? candle_body / candle_range : 0
long_momentum = body_percentage >= momentum_body_percent and close > open
short_momentum = body_percentage >= momentum_body_percent and close < open

// --- START: Momentum Candle Coloring ---
bullish_momentum_color = long_momentum ? color.lime : na
bearish_momentum_color = short_momentum ? color.red : na
barcolor(bullish_momentum_color, title="Bullish Momentum Candle")
barcolor(bearish_momentum_color, title="Bearish Momentum Candle")
// --- END: Momentum Candle Coloring ---

// Entry Conditions
long_condition = ta.crossover(close, upper_band) and shift_to_bullish and (not momentum_filter or long_momentum)
short_condition = ta.crossunder(close, lower_band) and shift_to_bearish and (not momentum_filter or short_momentum)

// Exit Conditions
exit_long_condition = ta.crossunder(close, basis) or close < (order_block_low * 0.99)
exit_short_condition = ta.crossover(close, basis) or close > (order_block_high * 1.01)

// --- START: Position Sizing Calculation (Using Adjustable Risk %) ---
capital_per_trade = (strategy.equity * risk_percent_input) / 100.0
trade_qty = capital_per_trade / close
trade_qty := trade_qty < 0.000001 ? 0.000001 : trade_qty
// --- END: Position Sizing Calculation ---

// --- START: Alert Message Strings ---
string longEntryMsg  = "SMC BB Long Entry: {{ticker}} Action: {{strategy.order.action}} @ Price: {{strategy.order.price}}"
string shortEntryMsg = "SMC BB Short Entry: {{ticker}} Action: {{strategy.order.action}} @ Price: {{strategy.order.price}}"
string longExitMsg   = "SMC BB Exit Long: {{ticker}} Action: {{strategy.order.action}} @ Price: {{strategy.order.price}}"
string shortExitMsg  = "SMC BB Exit Short: {{ticker}} Action: {{strategy.order.action}} @ Price: {{strategy.order.price}}"
// --- END: Alert Message Strings ---

// Strategy Execution with Alerts
if long_condition
    strategy.entry('Long', strategy.long, qty=trade_qty, alert_message=longEntryMsg)

if short_condition
    strategy.entry('Short', strategy.short, qty=trade_qty, alert_message=shortEntryMsg)

if exit_long_condition
    strategy.close('Long', comment="Exit Long", alert_message=longExitMsg)

if exit_short_condition
    strategy.close('Short', comment="Exit Short", alert_message=shortExitMsg)

// Plotting Bollinger Bands (Improved)
p1 = plot(upper_band, color=color.rgb(76, 175, 80), title='Upper BB', linewidth=2)
p2 = plot(lower_band, color=color.rgb(244, 67, 54), title='Lower BB', linewidth=2)
plot(basis, color=color.rgb(33, 150, 243), title='Basis BB', linewidth=2)

// Plotting SMC Elements (Improved)
if show_smc
    line.new(bar_index[ob_length], order_block_high, bar_index, order_block_high, color=color.rgb(255, 0, 0, 70), width=2, style=line.style_dashed)
    line.new(bar_index[ob_length], order_block_low, bar_index, order_block_low, color=color.rgb(0, 255, 0, 70), width=2, style=line.style_dashed)
    line.new(bar_index[swing_length], recent_swing_high, bar_index, recent_swing_high, color=color.rgb(255, 193, 7, 70), width=1, style=line.style_dotted)
    line.new(bar_index[swing_length], recent_swing_low, bar_index, recent_swing_low, color=color.rgb(0, 188, 212, 70), width=1, style=line.style_dotted)

// Plot entry and exit shapes
plotshape(long_condition, title="Long Entry", location=location.belowbar, color=color.new(color.green, 0), style=shape.triangleup, size=size.small)
plotshape(short_condition, title="Short Entry", location=location.abovebar, color=color.new(color.red, 0), style=shape.triangledown, size=size.small)
````
