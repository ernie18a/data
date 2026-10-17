# Reinforced RSI - The Quant Science 

- url: https://www.tradingview.com/script/mjIwVkql-Reinforced-RSI-The-Quant-Science/
- type: strategy
- pine_id: PUB;90ec48f874174cf9bad33d492fb43e29
- version: 4.0

## Description

[b][i]This strategy was designed and written with the goal of showing and motivating the community how to integrate our 'Probabilities' module with their own script. [/i][/b]

We have recreated one of the simplest strategies used by many traders. The strategy only trades long and uses the overbought and oversold levels on the RSI indicator. 

We added stop losses and take profits to offer more dynamism to the strategy. Then the 'Probabilities' module was integrated to create a probabilistic reinforcement on each trade. 
Specifically, each trade is executed, only if the past probabilities of making a profitable trade is greater than or equal to 51%. This greatly increased the performance of the strategy by avoiding possible bad trades. 

The backtesting was calculated on the [symbol="NASDAQ:TSLA"]NASDAQ:TSLA[/symbol], on 15 minutes timeframe. 

The strategy works on Tesla using the following parameters: 

[i]1. Lenght:[/i] 13
[i]2. Oversold:[/i] 40
[i]3. Overbought:[/i] 70
[i]4. Lookback:[/i] 50 
[i]5. Take profit:[/i] 3% 
[i]6. Stop loss:[/i] 3% 

[i]Time period:[/i] January 2021 to date. 

Our Probabilities Module, used in the strategy example: [url=https://www.tradingview.com/script/c59tBqoE-Probabilities-Module-The-Quant-Science/]https://www.tradingview.com/script/c59tBqoE-Probabilities-Module-The-Quant-Science/[/url]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © thequantscience

//@version=6
strategy("% Win Rate Strategy Filter | Probabilities Module [The Quant Science]",
     default_qty_type = strategy.cash,
     currency = currency.USDT,
     initial_capital = 100000,
     commission_type = strategy.commission.percent,
     commission_value = 0.07,
     slippage = 5,
     process_orders_on_close = true,
     close_entries_rule = "ANY"
     )

filter_strat = input.bool(defval = false, title = "Add % Win Rate Filter", group = "SETTINGS")
look = input.int(defval = 30, minval = 1, maxval = 500, title = "Lookback [N. Trades]", group = "SETTINGS")
tp = input.float(defval = 1.00, minval = 0, title = "Take profit [%]", group = "SETTINGS")
sl = input.float(defval = 1.00, minval = 0, title = "Stop loss [%]", group = "SETTINGS")
size_pos = input.float(defval = 50, title = "Position Sizing [%]", minval = 0.10, maxval = 100, group = "SETTINGS")
rsi = ta.rsi(close, 14)

entry_condition  = close < open 
take_profit_cond_exit = close > open 
stop_loss_cond_exit = close < close[1]

var bool in_trade = false
var int  trade_outcome = na

is_entry = not in_trade and entry_condition
is_tp = in_trade and take_profit_cond_exit
is_sl = in_trade and stop_loss_cond_exit

if is_entry
    in_trade := true
    trade_outcome := na

if is_tp
    in_trade := false
    trade_outcome := 1
else if is_sl
    in_trade := false
    trade_outcome := 0 

var results_array = array.new_float(0)

if not na(trade_outcome) and (is_tp or is_sl)
    array.push(results_array, trade_outcome)
    if array.size(results_array) > look
        array.clear(results_array)
    trade_outcome := na

float probabilities = array.size(results_array) > 0 ? array.avg(results_array) * 100 : na
plot(probabilities, color = color.aqua, title = "Win Rate %")

var float init_price = 0
var float qty_order = 0
var float take_profit_level = 0
var float stop_profit_level = 0

entry_condition_long_strat = ta.crossunder(rsi, 35)
if (filter_strat == false and entry_condition_long_strat and strategy.opentrades == 0)
    init_price := close 
    qty_order  := (strategy.initial_capital * size_pos)/100
    strategy.entry(id="Open Trade [No filter]", direction = strategy.long, qty = qty_order/init_price, limit = init_price)
    take_profit_level := (init_price + ((init_price * tp)/100))
    stop_profit_level := (init_price - ((init_price * sl)/100))

tp_condition = ta.crossover(close, take_profit_level)
sl_condition = ta.crossunder(close, stop_profit_level)

if (tp_condition and filter_strat == false)
    strategy.exit(id = "Take Profit [No filter]", from_entry = "Open Trade [No filter]", qty_percent = 100, limit = take_profit_level)
if (sl_condition and filter_strat == false)
    strategy.exit(id = "Stop Loss [No filter]", from_entry = "Open Trade [No filter]", qty_percent = 100, limit = stop_profit_level)

if (filter_strat == true and entry_condition and strategy.opentrades == 0 and probabilities > 60)
    init_price := close 
    qty_order  := (strategy.initial_capital * size_pos)/100
    strategy.entry(id="Open Trade", direction = strategy.long, qty = qty_order/init_price, limit = init_price)
    take_profit_level := (init_price + ((init_price * tp)/100))
    stop_profit_level := (init_price - ((init_price * sl)/100))

tp_condition_with_filter = ta.crossover(close, take_profit_level)
sl_condition_with_filter = ta.crossunder(close, stop_profit_level)

if (tp_condition_with_filter and filter_strat == true)
    strategy.exit(id = "Take Profit", from_entry = "Open Trade", qty_percent = 100, limit = take_profit_level)
if (sl_condition_with_filter and filter_strat == true)
    strategy.exit(id = "Stop Loss", from_entry = "Open Trade", qty_percent = 100, limit = stop_profit_level)
````
