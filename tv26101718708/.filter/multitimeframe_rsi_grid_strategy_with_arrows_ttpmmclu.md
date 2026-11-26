# Multi-Timeframe RSI Grid Strategy with Arrows

- url: https://www.tradingview.com/script/TTpMMcLu-Multi-Timeframe-RSI-Grid-Strategy-with-Arrows/
- type: strategy
- pine_id: PUB;803c8d89887f4ba1a3ff8611d0fe2109
- version: 1.0

## Description

Key Features of the Strategy
Multi-Timeframe RSI Analysis:

The strategy calculates RSI values for three different timeframes:

The current chart's timeframe.

Two higher timeframes (configurable via higher_tf1 and higher_tf2 inputs).

It uses these RSI values to identify overbought (sell) and oversold (buy) conditions.

Grid Trading System:

The strategy uses a grid-based approach to scale into trades. It adds positions at predefined intervals (grid_space) based on the ATR (Average True Range) and a grid multiplication factor (grid_factor).

The grid system allows for pyramiding (adding to positions) up to a maximum number of grid levels (max_grid).

Daily Profit Target:

The strategy has a daily profit target (daily_target). Once the target is reached, it closes all open positions and stops trading for the day.

Drawdown Protection:

If the open drawdown exceeds 2% of the account equity, the strategy closes all positions to limit losses.

Reverse Signals:

If the RSI conditions reverse (e.g., from buy to sell or vice versa), the strategy closes all open positions and resets the grid.

Visualization:

The script plots buy and sell signals as arrows on the chart.

It also plots the RSI values for the current and higher timeframes, along with overbought and oversold levels.

How It Works
Inputs:

The user can configure parameters like RSI length, overbought/oversold levels, higher timeframes, grid spacing, lot size multiplier, maximum grid levels, daily profit target, and ATR length.

RSI Calculation:

The RSI is calculated for the current timeframe and the two higher timeframes using ta.rsi().

Grid System:

The grid system uses the ATR to determine the spacing between grid levels (grid_space).

When the price moves in the desired direction, the strategy adds positions at intervals of grid_space, increasing the lot size by a multiplier (lot_multiplier) for each new grid level.

Entry Conditions:

A buy signal is generated when the RSI is below the oversold level on all three timeframes.

A sell signal is generated when the RSI is above the overbought level on all three timeframes.

Position Management:

The strategy scales into positions using the grid system.

It closes all positions if the daily profit target is reached or if a reverse signal is detected.

Visualization:

Buy and sell signals are plotted as arrows on the chart.

RSI values for all timeframes are plotted, along with overbought and oversold levels.

Example Scenario
Suppose the current RSI is below 30 (oversold), and the RSI on the 60-minute and 240-minute charts is also below 30. This triggers a buy signal.

The strategy enters a long position with a base lot size.

If the price moves against the position by grid_space, the strategy adds another long position with a larger lot size (scaled by lot_multiplier).

This process continues until the maximum grid level (max_grid) is reached or the daily profit target is achieved.

Key Variables
grid_level: Tracks the current grid level (number of positions added).

last_entry_price: Tracks the price of the last entry.

base_size: The base lot size for the initial position.

daily_profit_target: The daily profit target in percentage terms.

target_reached: A flag to indicate whether the daily profit target has been achieved.

Potential Use Cases
This strategy is suitable for traders who want to combine RSI-based signals with a grid trading approach to capitalize on mean-reverting price movements.

It can be used in trending or ranging markets, depending on the RSI settings and grid parameters.

Limitations
The grid trading system can lead to significant drawdowns if the market moves strongly against the initial position.

The strategy relies heavily on RSI, which may produce false signals in strongly trending markets.

The daily profit target may limit potential gains in highly volatile markets.

Customization
You can adjust the input parameters (e.g., RSI length, overbought/oversold levels, grid spacing, lot multiplier) to suit your trading style and market conditions.

You can also modify the drawdown protection threshold or add additional filters (e.g., volume, moving averages) to improve the strategy's performance.

In summary, this script is a sophisticated trading strategy that combines RSI-based signals with a grid trading system to manage entries, exits, and position sizing. It includes features like daily profit targets, drawdown protection, and multi-timeframe analysis to enhance its robustnes

## Source Code

````pine
//@version=5
strategy("Multi-Timeframe RSI Grid Strategy with Arrows", overlay=true, initial_capital=10000, currency=currency.USD, pyramiding=10)

// Input parameters
rsi_length = input.int(14, "RSI Length")
oversold = input.int(30, "Oversold Level")
overbought = input.int(70, "Overbought Level")
higher_tf1 = input.string("60", "Higher Timeframe 1")
higher_tf2 = input.string("240", "Higher Timeframe 2")
grid_factor = input.float(1.2, "Grid Multiplication Factor", step=0.1)
lot_multiplier = input.float(1.5, "Lot Multiplication Factor", step=0.1)
max_grid = input.int(5, "Maximum Grid Levels")
daily_target = input.float(4.0, "Daily Profit Target (%)", step=0.5)
atr_length = input.int(14, "ATR Length")

// Calculate RSI values
current_rsi = ta.rsi(close, rsi_length)
higher_tf1_rsi = request.security(syminfo.tickerid, higher_tf1, ta.rsi(close, rsi_length))
higher_tf2_rsi = request.security(syminfo.tickerid, higher_tf2, ta.rsi(close, rsi_length))

// Grid system variables
var int grid_level = 0
var float last_entry_price = na
var float base_size = strategy.equity * 0.01 / close
var float daily_profit_target = strategy.equity * (daily_target / 100)
var bool target_reached = false

// ATR for grid spacing
atr = ta.atr(atr_length)
grid_space = atr * grid_factor

// Daily reset
new_day = ta.change(time("D"))
if new_day
    daily_profit_target := strategy.equity * (daily_target / 100)
    target_reached := false
    grid_level := 0
    last_entry_price := na

// Trading conditions
buy_condition = current_rsi < oversold and higher_tf1_rsi < oversold and higher_tf2_rsi < oversold
sell_condition = current_rsi > overbought and higher_tf1_rsi > overbought and higher_tf2_rsi > overbought

// Reverse signal detection
reverse_long_to_short = sell_condition and strategy.position_size > 0
reverse_short_to_long = buy_condition and strategy.position_size < 0

// Close all trades on reverse signals
if reverse_long_to_short or reverse_short_to_long
    strategy.close_all()
    grid_level := 0
    last_entry_price := na

// Grid management logic
if strategy.position_size == 0
    grid_level := 0
    last_entry_price := na

if strategy.position_size > 0 and not reverse_long_to_short
    if close < last_entry_price - grid_space and grid_level < max_grid and not target_reached
        strategy.entry("Long Grid " + str.tostring(grid_level), strategy.long, qty=base_size * math.pow(lot_multiplier, grid_level))
        grid_level += 1
        last_entry_price := close

if strategy.position_size < 0 and not reverse_short_to_long
    if close > last_entry_price + grid_space and grid_level < max_grid and not target_reached
        strategy.entry("Short Grid " + str.tostring(grid_level), strategy.short, qty=base_size * math.pow(lot_multiplier, grid_level))
        grid_level += 1
        last_entry_price := close

// Initial entry
if buy_condition and strategy.position_size == 0 and not target_reached
    strategy.entry("Long", strategy.long, qty=base_size)
    grid_level := 1
    last_entry_price := close

if sell_condition and strategy.position_size == 0 and not target_reached
    strategy.entry("Short", strategy.short, qty=base_size)
    grid_level := 1
    last_entry_price := close

// Profit target check
current_profit = strategy.netprofit + strategy.openprofit
if current_profit >= daily_profit_target and not target_reached
    strategy.close_all()
    target_reached := true

// Drawdown protection
if strategy.openprofit < -(0.02 * strategy.equity)  // 2% drawdown protection
    strategy.close_all()
    grid_level := 0
    last_entry_price := na

// Plot Buy and Sell Arrows
plotshape(series=buy_condition and strategy.position_size == 0, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="BUY", size=size.small)
plotshape(series=sell_condition and strategy.position_size == 0, title="Sell Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL", size=size.small)

// Plotting RSI
plot(current_rsi, "Current RSI", color=color.blue)
plot(higher_tf1_rsi, "HTF1 RSI", color=color.red)
plot(higher_tf2_rsi, "HTF2 RSI", color=color.green)
hline(oversold, "Oversold", color=color.gray)
hline(overbought, "Overbought", color=color.gray)
````
