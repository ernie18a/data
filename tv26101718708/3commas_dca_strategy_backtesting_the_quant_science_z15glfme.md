# 3Commas DCA Strategy Backtesting [The Quant Science]

- url: https://www.tradingview.com/script/z15GLfMe-3Commas-DCA-Strategy-Backtesting-The-Quant-Science/
- type: strategy
- pine_id: PUB;2653ff8f4572412fbb8ba3c1c29a7ea8
- version: 3.0

## Description

This strategy is an advanced [b]Dollar Cost Averaging (DCA)[/b] simulator designed to replicate the logic of [b]3Commas[/b] algorithmic trading bots directly within TradingView. This streamlined version showcases the power of Pine Script in developing high-efficiency backtests. By deep-diving into the data before going live, users can stress-test their setups and avoid costly mistakes.

The following 3Commas configuration is assumed for this template:

[b]Direction: Long | Order Type: Limit | Exchange: Binance (BTC/USDT[/b]
[image]https://www.tradingview.com/x/hKq61fKZ/[/image]

[list]
[*][b]Initial Order Size:[/b] Set to 1000 USDT.
[*][b]Entry Logic: [/b]Our custom TradingView signal triggers on an RSI bearish cross of the 35 level, initiating a Long DCA sequence on oversold conditions.
[/list]
[image]https://www.tradingview.com/x/zdWDUS57/[/image]

[b]The Averaging orders logic for this template is configured as follows:[/b]

[list]
[*][b]Deviation to open first averaging order:[/b] 1%
[*][b]Averaging order size:[/b] 100 USDT
[*][b]Deviation step multiplier: [/b] 1.5
[*][b]Order size multiplier:[/b]1.5
[*][b]Averaging orders per trade:[/b]11
[*][b]Limit averaging orders placed on exchange:[/b] 11
[/list]
[b]Critical Note: Max amount for bot usage & Backtesting Accuracy[/b] 
When configuring 3Commas, always prioritize the [b]Max amount for bot usage[/b] parameter. This is essential to ensure your backtesting data remains realistic and avoids "illusory" results.

As shown in this setup, the [b]Max amount for bot usage[/b] is approximately 8,500 USDT. This represents the maximum amount of funds the bot can trade. To maintain high-fidelity backtesting on TradingView, we have set the Initial Capital to 10,000 USDT.

By utilizing ~85% of the available equity (8,500 out of 10,000 USDT), the simulation closely mirrors real-world trading conditions.

If your [b]Max amount for bot usage[/b] exceeds your account balance, you must adjust your configuration. Always align your bot settings with your specific trading goals and financial capacity to avoid liquidation or failed order execution.
[image]https://www.tradingview.com/x/h6x3qn1X/[/image]

🧠 [b]Workflow Description[/b]
This strategy automates 3Commas-style Dollar Cost Averaging (DCA), operating exclusively on the Long side. The first order is triggered when the 7-period RSI crosses down the oversold threshold (default: 35), signaling a potential local bottom. Upon entry, the system simultaneously calculates and places 10 averaging orders via limit orders at progressively lower price levels to manage the position.  The spacing between these orders is dynamic; it increases exponentially through a deviation multiplier, allowing the strategy to cover deep drawdowns effectively. Simultaneously, the volume of each subsequent purchase grows according to an amount multiplier, aggressively pulling the average entry price downward. The trade is closed either at a take profit target triggered once the total position equity reaches the set value or via a stop loss calculated from the initial entry price.
[image]https://www.tradingview.com/x/xRSXCPl6/[/image]

[b]Backtesting Considerations & Performance Analysis[/b]
Despite the positive net profit shown in the strategy report, this specific configuration underperforms when compared to a simple Buy & Hold approach. In this scenario, a Buy & Hold investor who simply hold 10,000 USDT worth of the asset would have achieved a significantly higher return than the trader executing this DCA strategy. This indicates that while the bot is "profitable" in absolute terms, it is not capital-efficient under these specific market conditions.

❌ To keep this simulator streamlined and focused on core DCA logic, the current version does not include the following features: 

[list]
[*][b]Base Template Only: [/b]This is a foundational framework designed for educational and initial testing purposes.
[*][b]No Leverage Backtesting: [/b]All calculations assume a 1x spot-trading margin (no liquidation or margin cost simulation).
[*][b]No Short Selling: [/b]This version is strictly long-only.
[*][b]Simplified DCA Settings: [/b]Advanced 3Commas parameters (such as Minimum Deviation Step or Non-linear Volume Scaling) are not included.
[*][b]Fixed Order Count: [/b]The strategy is hardcoded to 11 total orders (1 Base Order + 10 Averaging Orders).
[*][b]Standard Profit Logic: [/b]Take Profit % is calculated based on the Average Price, while Stop Loss % is anchored to the Initial Base Order price.
[*][b]No Reinvestment (Compounding): [/b]The strategy uses a fixed position size and does not automatically reinvest profits into subsequent deals.
[/list]
Feel free to swap the trigger logic or optimize the averaging settings to discover a configuration that outperforms a simple Buy & Hold strategy.

## Source Code

````pine
//@version=6
strategy(
     "3Commas DCA Strategy Backtesting [The Quant Science]",
     overlay = false,
     default_qty_type = strategy.cash,
     initial_capital = 1000000,
     default_qty_value = 100000,
     pyramiding = 10,
     currency = currency.USDT,
     commission_type = strategy.commission.percent,
     commission_value = 0.07,
     slippage = 5,
     process_orders_on_close = true,
     close_entries_rule = "ANY"
     )

long_strategy  = input.bool(defval=true, title = "Long Strategy |", group = "Strategy Side", inline = "strategy-side")
short_strategy = input.bool(defval=false, title = "Short Strategy", group = "Strategy Side", inline = "strategy-side")

if ((long_strategy==true) and (short_strategy))
    runtime.error("Cannot select both strategies!!! Only one strategy per side at a time. Select LONG to analyze the long backtest and choose SHORT to analyze the short backtest.")

start_date  = input.int(title="D: ", defval=1,    minval=1,    maxval=31,   inline = 'Start', group = "DATE PERIOD BACKTESTING")
start_month = input.int(title="M: ", defval=1,    minval=1,    maxval=12,   inline = 'Start', group = "DATE PERIOD BACKTESTING")
start_year  = input.int(title="Y: ", defval=2021, minval=1800, maxval=2100, inline = 'Start', group = "DATE PERIOD BACKTESTING")
end_date    = input.int(title="D: ", defval=31,   minval=1,    maxval=31,   inline = 'End',   group = "DATE PERIOD BACKTESTING")
end_month   = input.int(title="M: ", defval=12,   minval=1,    maxval=12,   inline = 'End',   group = "DATE PERIOD BACKTESTING")
end_year    = input.int(title="Y: ", defval=2027, minval=1800, maxval=2100, inline = 'End',   group = "DATE PERIOD BACKTESTING")

in_date_range = (time >= timestamp(syminfo.timezone, start_year, start_month, start_date, 0, 0)) and (time < timestamp(syminfo.timezone, end_year, end_month, end_date, 0, 0))

qty_base = input.int(defval = 100000, minval = 0, step = 1, title = "Base order (USDT):", group = "STRATEGY", tooltip = "The Base Order is the first order the bot will create when starting a new trade.", inline = "base-order-size")
lenght_period = input.int(title="Lenght", defval=14, minval=0, group = "START DEAL CONDITION", inline = "rsi")
trigger_rsi = input.int(title="Trigger RSI", defval=35, minval=0, group = "START DEAL CONDITION", inline = "rsi")
rsi = ta.rsi(close, lenght_period)

qty_dca = input.int(defval = 100, minval = 0, step = 1, title = "Averaging order size (USDT: ", group = "AVERAGING ORDERS", inline = "Header", tooltip = "Enter the amount of funds your averaging orders.", confirm = true)
DROP = input.float(defval = 1.50,  minval = 0, title = "Price Deviation (% from initial order): ", step = 0.10, group = "AVERAGING ORDERS", inline = "Drop", tooltip = "Deviation to open first averaging order", confirm = true)
SAFETY_ORDER_VOLUME_SCALE = input.float(defval = 1, minval = 0, step = 0.1, maxval = 100, title = "Order size multiplier: ", group = "AVERAGING ORDERS", confirm = true)
STEP_SCALE_VALUE = input.float(defval = 0.5, minval = 0, maxval = 100, title = "Deviation step multiplier: ", step = 0.10, group = "AVERAGING ORDERS", confirm = true)

PROFIT = input.float(defval = 1, minval = 0, title = "Target profit (%): ", step = 0.10, group = "TAKE PROFIT", inline = "pov", tooltip = "Configure the percentage 'Take Profit' target the strategy will use to close successful trades, the strategy will automatically account for exchange fees.", confirm = true)

STOPLOSS = input.bool(defval = false, title = "", group = "STOP LOSS", inline = "SL")
STOPLOSSVALUE  = input.float(defval = 50, minval = 0, title = "Stop loss (%): ", step = 0.10, group = "STOP LOSS", inline = "SL", tooltip = "This is the percentage that price needs to move in the opposite direction to your take profit target, at which point the strategy will execute a 'Market Order' on the exchange account to close the deal for a smaller loss than keeping the deal open. Please note, the 'Stop Loss' is calculated from the price the initial 'Base Order' was filled at on the exchange account and not the Dollar Cost Average price.")

var float base_order_price = 0
var float dca_long1   = 0
var float dca_long2   = 0
var float dca_long3   = 0
var float dca_long4   = 0
var float dca_long5   = 0
var float dca_long6   = 0
var float dca_long7   = 0
var float dca_long8   = 0
var float dca_long9   = 0
var float dca_long10  = 0

var float exit_condition_long = 0 
var float exit_condition_stoploss_long = 0 
rsi_entry_condition_long = ta.crossunder(rsi, trigger_rsi) 

if (rsi_entry_condition_long and in_date_range and strategy.opentrades==0 and long_strategy==true) 

    base_order_price := close 

    dca_long1  := (base_order_price - (base_order_price * (DROP * (STEP_SCALE_VALUE * 1))/ 100)) 
    dca_long2  := (dca_long1 - (dca_long1 * (DROP * (STEP_SCALE_VALUE * 2))  / 100)) 
    dca_long3  := (dca_long2 - (dca_long2 * (DROP * (STEP_SCALE_VALUE * 3))  / 100)) 
    dca_long4  := (dca_long3 - (dca_long3 * (DROP * (STEP_SCALE_VALUE * 4))  / 100)) 
    dca_long5  := (dca_long4 - (dca_long4 * (DROP * (STEP_SCALE_VALUE * 5))  / 100))
    dca_long6  := (dca_long5 - (dca_long5 * (DROP * (STEP_SCALE_VALUE * 6))  / 100))
    dca_long7  := (dca_long6 - (dca_long6 * (DROP * (STEP_SCALE_VALUE * 7))  / 100))
    dca_long8  := (dca_long7 - (dca_long7 * (DROP * (STEP_SCALE_VALUE * 8))  / 100))
    dca_long9  := (dca_long8 - (dca_long8 * (DROP * (STEP_SCALE_VALUE * 9))  / 100))
    dca_long10 := (dca_long9 - (dca_long9 * (DROP * (STEP_SCALE_VALUE * 10))  / 100))

    strategy.entry(id = "Buy",  direction = strategy.long, qty = qty_base/base_order_price, limit = base_order_price)
    strategy.entry(id = "SO1",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 1) /dca_long1,   limit = dca_long1)
    strategy.entry(id = "SO2",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 2) /dca_long2,   limit = dca_long2)
    strategy.entry(id = "SO3",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 3) /dca_long3,   limit = dca_long3)
    strategy.entry(id = "SO4",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 4) /dca_long4,   limit = dca_long4)
    strategy.entry(id = "SO5",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 5) /dca_long5,   limit = dca_long5)
    strategy.entry(id = "SO6",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 6) /dca_long6,   limit = dca_long6)
    strategy.entry(id = "SO7",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 7) /dca_long7,   limit = dca_long7)
    strategy.entry(id = "SO8",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 8) /dca_long8,   limit = dca_long8)
    strategy.entry(id = "SO9",  direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 9) /dca_long9,   limit = dca_long9)
    strategy.entry(id = "SO10", direction = strategy.long, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 10) /dca_long10, limit = dca_long10)

    if STOPLOSS==true
        exit_condition_stoploss_long := dca_long10 - (dca_long10 * STOPLOSSVALUE / 100)    

exit_condition_long := base_order_price + (base_order_price * PROFIT / 100)  
stop_loss_target_long = ta.crossunder(close, exit_condition_stoploss_long)
take_profit_gain_long = ta.crossover(close, exit_condition_long)

if (take_profit_gain_long and in_date_range and long_strategy==true) 

    strategy.close_all("Take Profit")

    strategy.cancel("Buy")
    strategy.cancel("SO1")
    strategy.cancel("SO2")
    strategy.cancel("SO3")
    strategy.cancel("SO4")
    strategy.cancel("SO5")
    strategy.cancel("SO6")
    strategy.cancel("SO7")
    strategy.cancel("SO8")
    strategy.cancel("SO9")
    strategy.cancel("SO10")

if (stop_loss_target_long and in_date_range and long_strategy==true) 

    strategy.close_all("Stop Loss")

    strategy.cancel("Buy")
    strategy.cancel("SO1")
    strategy.cancel("SO2")
    strategy.cancel("SO3")
    strategy.cancel("SO4")
    strategy.cancel("SO5")
    strategy.cancel("SO6")
    strategy.cancel("SO7")
    strategy.cancel("SO8")
    strategy.cancel("SO9")
    strategy.cancel("SO10")

var float base_order_price_short = 0 
var float dca_short1   = 0
var float dca_short2   = 0
var float dca_short3   = 0
var float dca_short4   = 0
var float dca_short5   = 0
var float dca_short6   = 0
var float dca_short7   = 0
var float dca_short8   = 0
var float dca_short9   = 0
var float dca_short10  = 0

var float exit_condition_short = 0 
var float exit_condition_stoploss_short = 0 

rsi_entry_condition_short = ta.crossover(rsi, trigger_rsi) 

if (rsi_entry_condition_short and in_date_range and strategy.opentrades==0 and short_strategy==true) 

    base_order_price_short := close 

    dca_short1  := (base_order_price_short + (base_order_price_short * (DROP * (STEP_SCALE_VALUE * 1))/ 100)) 
    dca_short2  := (dca_short1 + (dca_short1 * (DROP * (STEP_SCALE_VALUE * 2))  / 100)) 
    dca_short3  := (dca_short2 + (dca_short2 * (DROP * (STEP_SCALE_VALUE * 3))  / 100)) 
    dca_short4  := (dca_short3 + (dca_short3 * (DROP * (STEP_SCALE_VALUE * 4))  / 100)) 
    dca_short5  := (dca_short4 + (dca_short4 * (DROP * (STEP_SCALE_VALUE * 5))  / 100))
    dca_short6  := (dca_short5 + (dca_short5 * (DROP * (STEP_SCALE_VALUE * 6))  / 100))
    dca_short7  := (dca_short6 + (dca_short6 * (DROP * (STEP_SCALE_VALUE * 7))  / 100))
    dca_short8  := (dca_short7 + (dca_short7 * (DROP * (STEP_SCALE_VALUE * 8))  / 100))
    dca_short9  := (dca_short8 + (dca_short8 * (DROP * (STEP_SCALE_VALUE * 9))  / 100))
    dca_short10 := (dca_short9 + (dca_short9 * (DROP * (STEP_SCALE_VALUE * 10))  / 100))

    exit_condition_short := (base_order_price_short - (base_order_price_short * PROFIT / 100))

    if STOPLOSS==true
        exit_condition_stoploss_short := (dca_short10 + (dca_short10 * STOPLOSSVALUE / 100))
 
    strategy.entry(id = "Short",  direction = strategy.short, qty = qty_base/base_order_price_short, limit = base_order_price_short)
    strategy.entry(id = "SSO1",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 1) /dca_short1,   limit = dca_short1)
    strategy.entry(id = "SSO2",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 2) /dca_short2,   limit = dca_short2)
    strategy.entry(id = "SSO3",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 3) /dca_short3,   limit = dca_short3)
    strategy.entry(id = "SSO4",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 4) /dca_short4,   limit = dca_short4)
    strategy.entry(id = "SSO5",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 5) /dca_short5,   limit = dca_short5)
    strategy.entry(id = "SSO6",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 6) /dca_short6,   limit = dca_short6)
    strategy.entry(id = "SSO7",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 7) /dca_short7,   limit = dca_short7)
    strategy.entry(id = "SSO8",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 8) /dca_short8,   limit = dca_short8)
    strategy.entry(id = "SSO9",  direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 9) /dca_short9,   limit = dca_short9)
    strategy.entry(id = "SSO10", direction = strategy.short, qty = qty_dca  * (SAFETY_ORDER_VOLUME_SCALE * 10) /dca_short10, limit = dca_short10)
    
stop_loss_target_short =  ta.crossover(close, exit_condition_stoploss_short)
take_profit_gain_short = ta.crossunder(close, exit_condition_short)

if (take_profit_gain_short and in_date_range and short_strategy==true) 

    strategy.close_all("Take Profit Short")

    strategy.cancel("Short")
    strategy.cancel("SSO1")
    strategy.cancel("SSO2")
    strategy.cancel("SSO3")
    strategy.cancel("SSO4")
    strategy.cancel("SSO5")
    strategy.cancel("SSO6")
    strategy.cancel("SSO7")
    strategy.cancel("SSO8")
    strategy.cancel("SSO9")
    strategy.cancel("SSO10")

if (stop_loss_target_short and in_date_range and short_strategy==true) 

    strategy.close_all("Stop Loss Short")

    strategy.cancel("Short")
    strategy.cancel("SSO1")
    strategy.cancel("SSO2")
    strategy.cancel("SSO3")
    strategy.cancel("SSO4")
    strategy.cancel("SSO5")
    strategy.cancel("SSO6")
    strategy.cancel("SSO7")
    strategy.cancel("SSO8")
    strategy.cancel("SSO9")
    strategy.cancel("SSO10")

if (strategy.equity < 0) 
    runtime.error("Bankruptcy! The equity line of this backtesting is negative. Try the backtesting again using different parameters, or reduce or increase the test period.")

rsi_color_green_long = rsi <= trigger_rsi 
rsi_color_red_long = rsi >= trigger_rsi
rsi_color_long = rsi_color_red_long ? #ff0000 : rsi_color_green_long ? #00ff00 : #00ff00

rsi_color_red_short = rsi >= trigger_rsi 
rsi_color_green_short = rsi <= trigger_rsi 
rsi_color_short = rsi_color_red_short ? #00ff00: rsi_color_green_short ? #ff0000 : #ff0000 

rsi_color = long_strategy==true ? rsi_color_long : short_strategy==true ? rsi_color_short : color.gray

plot(rsi, title="RSI", color=rsi_color, linewidth=1)
hline(0, title="RSI - Bottom line", color=color.rgb(0, 255, 8))
hline(100, title="RSI - Top line", color=color.rgb(255, 39, 39))
hline(trigger_rsi, title="RSI - Trigger value", color=color.rgb(72, 73, 73), linewidth=2, linestyle=hline.style_dotted)
````
