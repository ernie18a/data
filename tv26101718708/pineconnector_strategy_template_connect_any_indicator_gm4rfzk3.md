# Pineconnector Strategy Template (Connect Any Indicator)

- url: https://www.tradingview.com/script/GM4rFZk3-Pineconnector-Strategy-Template-Connect-Any-Indicator/
- type: strategy
- pine_id: PUB;3adbdb12bf8841fca7dbe547be86ba8e
- version: 2.0

## Description

Hello traders,

If you're tired of manual trading and looking for a solid strategy template to pair with your indicators, look no further. 
This Pine Script v5 strategy template is engineered for maximum customization and risk management. 
Best part? 
It’s optimized for Pineconnector, allowing seamless integration with MetaTrader 4 and 5.

This powerful tool gives a lot of power to those who don't know how to code in Pinescript and are looking to automate their indicators' signals on Metatrader 4/5.

[b]IMPORTANT NOTES[/b]

Pineconnector is a trading bot software that forwards TradingView alerts to your Metatrader 4/5 for automating trading.
Many traders don't know how to dynamically create Pineconnector-compatible alerts using the data from their TradingView scripts.

Traders using trading bots want their alerts to reflect the stop-loss/take-profit/trailing-stop/stop-loss to break options from your script and then create the orders accordingly.

This script showcases how to create Pineconnector alerts dynamically.

Pineconnector doesn't support alerts with multiple Take Profits.
As a workaround, for 2 TPs, I had to open two trades.
It's not optimal, as we end up paying more spreads for that extra trade - however, depending on your trading strategy, it may not be a big deal.

[b]TRADINGVIEW ALERTS[/b]

1) You'll have to create one alert per asset X timeframe = 1 chart.
Example: 1 alert for EUR/USD on the 5 minutes chart, 1 alert for EUR/USD on the 15-minute chart (assuming you want your bot to trade the EUR/USD on the 5 and 15-minute timeframes)

2) Select the Order fills and alert() function calls condition

3) For each alert, the alert message is pre-configured with the text below
{{strategy.order.alert_message}}

Please leave it as it is.
It's a TradingView native variable that will fetch the alert text messages built by the script.

4) Don't forget to set the Pineconnector webhook URL in the Notifications tab of the TradingView alerts UI. You’ll find the URL on the Pineconnector documentation website.

[b]EA CONFIGURATION[/b]

1) The Pyramiding in the EA on Metatrader must be set to 2 if you want to trade with 2 TPs => as it's opening 2 trades.
If you only want 1 TP, set the EA Pyramiding to 1.
Regarding the other EA settings, please refer to the Pineconnector documentation on their website.

2) In the EA, you can set a risk (= position size type) in %/lots/USD, as in the TradingView backtest settings.

[b]KEY FEATURES[/b]

I) Modular Indicator Connection
    * plug in your existing indicator into the template.
    * Only two lines of code are needed for full compatibility.

[i]Step 1: Create your connector[/i]

Adapt your indicator with only 2 lines of code and then connect it to this strategy template.

To do so:

1) Find in your indicator where the conditions print the long/buy and short/sell signals.
2) Create an additional plot as below

I'm giving an example with a Two moving averages cross.

Please replicate the same methodology for your indicator, whether it's a MACD , ZigZag , Pivots , higher-highs, lower-lows, or whatever indicator with clear buy and sell conditions.

[pine]
//@version=5
indicator("Supertrend", overlay = true, timeframe = "", timeframe_gaps = true)

atrPeriod = input.int(10,    "ATR Length", minval = 1)
factor =    input.float(3.0, "Factor",     minval = 0.01, step = 0.01)

[supertrend, direction] = ta.supertrend(factor, atrPeriod)

supertrend := barstate.isfirst ? na : supertrend
bodyMiddle = plot(barstate.isfirst ? na : (open + close) / 2, display = display.none)
upTrend =    plot(direction < 0 ? supertrend : na, "Up Trend",   color = color.green, style = plot.style_linebr)
downTrend =  plot(direction < 0 ? na : supertrend, "Down Trend", color = color.red,   style = plot.style_linebr)

fill(bodyMiddle, upTrend,   color.new(color.green, 90), fillgaps = false)
fill(bodyMiddle, downTrend, color.new(color.red,   90), fillgaps = false)

buy  = ta.crossunder(direction, 0)
sell = ta.crossunder(direction, 0)

//////// CONNECTOR SECTION //////// 

Signal = buy ? 1 : sell ? -1 : 0
plot(Signal, title = "Signal", display = display.data_window)

//////// CONNECTOR SECTION //////// 
[/pine]

[b]Important Notes[/b]

🔥 The Strategy Template expects the value to be exactly 1 for the bullish signal and -1 for the bearish signal

Now, you can connect your indicator to the Strategy Template using the method below or that one.

[i]Step 2: Connect the connector[/i]

1) Add your updated indicator to a TradingView chart
2) Add the Strategy Template as well to the SAME chart
3) Open the Strategy Template settings, and in the Data Source field, select your 🔌Connector🔌 (which comes from your indicator)

Note it doesn’t have to be named 🔌Connector🔌 - you can name it as you want - however, I recommend an explicit name you can easily remember.

From then, you should start seeing the signals and plenty of other stuff on your chart.

🔥 Note that whenever you update your indicator values, the strategy statistics and visuals on your chart will update in real-time

[b]II) Customizable Risk Management[/b]

- Choose between percentage or USD modes for maximum drawdown.
- Set max consecutive losing days and max losing streak length. 		
- I used the code from my friend @JosKodify for the maximum losing streak. :)  

Will halt the EA and backtest orders fill whenever either of the safeguards above are “broken”

[b]III) Intraday Risk Management[/b]

- Limit the maximum intraday losses both in percentage or USD.
- Option to set a maximum number of intraday trades.
- If your EA gets halted on an intraday chart, auto-restart it the next day.

[b]IV) Spread and Account Filters[/b]

- Trade only if the spread is below a certain pip value.
- Set requirements based on account balance or equity.

[b]V) Order Types and Position Sizing[/b]

- Choose between market, limit, or stop orders.
- Set your position size directly in the template.

Please use the position size from the “Inputs” and not the “Properties” tab.

[b]Reason[/b]: The template sends the order on the same candle as the entry signals - at those entry signals candles, the position size isn’t computed yet, and the template can’t then send it to Pineconnector.

However, you can use the position size type (USD, contracts, %) from the “Properties” tab for backtesting. 
In the EA, you can define the position size type for your orders in USD or lots or %.

[b]VI) Advanced Take-Profit and Stop-Loss Options[/b]

- Choose to set your SL/TP in either pips or percentages.
- Option for multiple take-profit levels and trailing stop losses.
- Move your stop loss to break even +/- offset in pips for “risk-free” trades.

[b]VII) Logger[/b]

The Pineconnector commands are logged in the TradingView logger.
You'll find more information about it in this [url=https://www.tradingview.com/blog/en/pine-logs-in-pine-script-40490/]TradingView blog post[/url].

[b]WHY YOU MIGHT NEED THIS TEMPLATE[/b]

1) Transform your indicator into a Pineconnector trading bot more easily than before
[list]
[*] Connect your indicator to the template
[*] Create your alerts
[*] Set your EA settings
[/list]

2) Save Time
Auto-generated alert messages for Pineconnector.
I tested them all, and I checked with the support team what could/can’t be done

3) Be in Control
Manage your trading risks with advanced features.

4) Customizable
Fits various trading styles and asset classes.

[b]REQUIREMENTS[/b]

* Make sure you have your Pineconnector license ID.
* Create your alerts with the Pineconnector webhook URL
* If there is any issue with the template, ask me in the comments section - I’ll answer quickly.

[b]BACKTEST RESULTS FROM THIS POST[/b]

1) I connected this strategy template to a dummy Supertrend script.
I could have selected any other indicator or concept for this script post.
I wanted to share an example of how you can quickly upgrade your strategy, making it compatible with Pineconnector.

2) The backtest results aren't relevant for this educational script publication.
I used realistic backtesting data but didn't look too much into optimizing the results, as this isn't the point of why I'm publishing this script. This strategy is a template to be connected to any indicator - the sky is the limit. :) 

3) This template is made to take 1 trade per direction at any given time.
Pyramiding is set to 1 on TradingView.

The strategy default settings are:

* Initial Capital: 100000 USD
* Position Size: 1 contract
* Commission Percent: 0.075%
* Slippage: 1 tick
* No margin/leverage used

[b]WHAT’S COMING NEXT FOR YOU GUYS?[/b]

I’ll make the same template for ProfitView, then for AutoView, and then for Alertatron.
All of those are free and open-source.
I have no affiliations with any of those companies - I'm publishing those templates as they will be useful to many of you.

Dave

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=5
//@strategy_alert_message {{strategy.order.alert_message}}


// # ========================================================================= #
// #                   |  SAMPLE INDICATOR  |
// # ========================================================================= #

// Sample script to plug to the strategy template

////@version=5
//indicator(title='Moving Average Cross', shorttitle='Moving Average Cross', overlay=true, precision=6, max_labels_count=500, max_lines_count=500)

// type_ma1 = input.string(title='MA1 type', defval='SMA', options=['RMA', 'SMA', 'EMA'])
// length_ma1 = input(10, title='[ALL but VWAP] MA1 length')

// type_ma2 = input.string(title='MA2 type', defval='SMA', options=['RMA', 'SMA', 'EMA'])
// length_ma2 = input(100, title='[ALL but VWAP] MA2 length')

// // MA
// f_ma(smoothing, src, length) =>
//     rma_1 = ta.rma(src, length)
//     sma_1 = ta.sma(src, length)
//     ema_1 = ta.ema(src, length)
//     iff_1 = smoothing == 'EMA' ? ema_1 : src
//     iff_2 = smoothing == 'SMA' ? sma_1 : iff_1
//     smoothing == 'RMA' ? rma_1 : iff_2

// MA1 = f_ma(type_ma1, close, length_ma1)
// MA2 = f_ma(type_ma2, close, length_ma2)

// // buy and sell conditions
// buy = ta.crossover(MA1, MA2)
// sell = ta.crossunder(MA1, MA2)

// plot(MA1, color=color.new(color.green, 0), title='Plot MA1', linewidth=3)
// plot(MA2, color=color.new(color.red, 0), title='Plot MA2', linewidth=3)

// plotshape(buy, title='LONG SIGNAL', style=shape.circle, location=location.belowbar, color=color.new(color.green, 0), size=size.normal)
// plotshape(sell, title='SHORT SIGNAL', style=shape.circle, location=location.abovebar, color=color.new(color.red, 0), size=size.normal)

// /////////////////////////// SIGNAL FOR STRATEGY /////////////////////////

// Signal = buy ? 1 : sell ? -1 : 0
// plot(Signal, title='🔌Connector🔌', display = display.data_window)

// # ========================================================================= #
// #                   |   SAMPLE INDICATOR  |
// # ========================================================================= #


SCRIPT_NAME = "Pineconnector Strategy Template"

strategy(SCRIPT_NAME, 
 overlay= true, 
 process_orders_on_close = true, 
 calc_on_every_tick = true, 
 pyramiding = 1, 
 initial_capital = 100000, 
 default_qty_type = strategy.fixed, 
 default_qty_value = 1,
 commission_type = strategy.commission.percent,
 commission_value = 0.075,
 slippage = 1
 )

_ext_connector = input.source(close, title = "External Connector", group = "Connected Indicator Source", tooltip = "Select the indicator you want to connect to this strategy.\nThis indicator will be used to trigger the strategy orders.")
ext_connector = nz(_ext_connector)

// # ========================================================================= #
// #                   | EA |
// # ========================================================================= #

pineconnector_licence_ID = input.string(title = "Licence ID", defval = "123456789", group = "Pineconnector", tooltip = "Insert your Pineconnector Licence ID here\nYou can find it in your Pineconnector account webpage")

use_drawdown_EA_halt = input.bool(false, title = "Use Drawdown EA Halt?", group = "EA Risk Management", inline = "max drawdown", tooltip = "Halt the EA if the max drawdown value is reached")
max_drawdown_mode  = input.string("%", title = "Mode", options = ["%", "USD"], group = "EA Risk Management", inline = "max drawdown")
max_drawdown_value = input.float(20, minval = 0, title = "Max Drawdown (%)", group = "EA Risk Management", inline = "max drawdown")

use_max_consecutive_days_EA_halt = input.bool(false, title = "Use Max Consecutive Days EA Halt?", group = "EA Risk Management", inline = "max consecutive days", tooltip = "Halt the EA if the max consecutive losing days value is reached")
nb_max_consecutive_days = input.int(3, minval = 0, title = "Max Consecutive Days", group = "EA Risk Management", inline = "max consecutive days")

use_max_losing_streak = input.bool(false, title = "Use Max Losing Streak?", group = "EA Risk Management", inline = "max losing streak", tooltip = "To prevent the EA from taking too many losses in a row")
maxLosingStreak = input.int(15, title="Max Losing Streak Length", minval=1, group = "EA Risk Management", inline = "max losing streak")

use_margin_call = input.bool(false, title = "Use Margin Call?", group = "EA Risk Management", inline = "margin call", tooltip = "Margin longs/shorts need to be different than 0% from the Properties tab.\nExit when we're X% away from a margin call, to prevent it")
margin_call_value = input.float(10, minval = 0, title = "Margin Call (%)", group = "EA Risk Management", inline = "margin call")

use_close_EA_total_loss = input.bool(false, title = "Use Close EA Total Loss?", group = "EA Risk Management", inline = "close EA total loss", tooltip = "Close all the trades + halt EA if the total loss is reached")
total_loss_value = input.float(-5000, maxval = 0, title = "Total Loss ($)", group = "EA Risk Management", inline = "close EA total loss")

use_intraday_losses_EA_halt = input.bool(false, title = "Use Intraday Losses EA Halt?", group = "Intraday EA Risk Management", inline = "intraday losses")
intraday_loss_value = input.string("%", title = "Mode", options = ["%", "USD"], group = "Intraday EA Risk Management", inline = "intraday losses")
nb_intraday_losses = input.int(3, minval = 0, title = "Max Intraday Losses (%)", group = "Intraday EA Risk Management", inline = "intraday losses")

use_limit_intraday_trades = input.bool(false, title = "Use Limit Intraday Trades?", group = "Intraday EA Risk Management", inline = "max intraday trades")
nb_max_intraday_trades = input.int(5, minval = 0, title = "Max Intraday Trades", group = "Intraday EA Risk Management", inline = "max intraday trades")

use_restart_intraday_EA = input.bool(false, title = "Use Restart Intraday EA?", group = "Intraday EA Risk Management", inline = "restart intraday EA", tooltip = "Restart the EA at the first bar of next day if it has been stoppped with an intraday risk management safeguard")

use_spread_filter = input.bool(false, title = "Use Spread Filter?", group = "EA Spread Filter", inline = "spread filter", tooltip = "Enter the position only if the spread is equal or less than the specified value in pips.")
spread_value      = input.float(3.5, minval = 0, title = "Spread Value (pips)", group = "EA Spread Filter", inline = "spread filter")

use_acc_filter    = input.bool(false, title = "Use Account Filter?", group = "EA Account Filter", inline = "account filter", tooltip = "Enter the position only if the account requirement is met.\nEA Options: Account Balance, Account Equity, Margin Percentage and Free Margin")
accfilter_value   = input.float(1000, minval = 0, title = "Account Balance/Equity (USD)", group = "EA Account Filter", inline = "account filter")

// # ========================================================================= #
// #                   | Order Types |
// # ========================================================================= #

order_type_mode = input.string("Market", title = "Order Type", options = ["Market", "Limit", "Stop"], group = "Order Types")
order_type_price = input.float(10, title = "Price", group = "Order Types", 
 tooltip = "With 'Limit', below the current market price for a buy - above the current market price for a sell\nWith 'Stop', above the current market price for a buy - below the current market price for a sell\n")

// # ========================================================================= #
// #                   | Position Size |
// # ========================================================================= #

pos_size = input.float(3, minval = 0, maxval = 100, title = "Position Size", group = "Position Size", tooltip = "Required to specify the position size here for Pineconnector to work properly")

// # ========================================================================= #
// #                   | Direction |
// # ========================================================================= #

strat_direction = input.string(strategy.direction.all, title = "Direction", options = [strategy.direction.all, strategy.direction.long, strategy.direction.short], group = "Trades Direction", tooltip = "To specify in which market direction the strategy is allowed to open positions.")

//use_close_opposite = input.bool(false, title = "Close on Opposite Signal?", group = "Close on Opposite", tooltip = "Close the position if 1 or more MACDs become bearish (for longs) or bullish (for shorts)")

// # ========================================================================= #
// #                   | General SL/TP |
// # ========================================================================= #

sl_tp_mode = input.string("pips", title = "Mode", options = ["pips", "%"], group = "General SL/TP", tooltip = "Select the mode you want to use for the SL/TP values\nSelect the same mode in the Pineconnector EA on Metatrader")

// # ========================================================================= #
// #                   | Stop Loss |
// # ========================================================================= #

use_sl = input.bool(true, title = "Use Stop Loss?", group = "Stop Loss")
sl_value = input.float(40, minval = 0, title = "Value", group = "Stop Loss", inline = "stoploss")// * 0.01

// # ========================================================================= #
// #                   | Trailing Stop Loss |
// # ========================================================================= #

use_tsl         = input.bool(false, title = "Use Trailing Stop Loss?", group = "Trailing Stop Loss")
tsl_input_value = input.float(10, minval = 0, title = "Value", group = "Trailing Stop Loss")

// # ========================================================================= #
// #                   | Take Profit |
// # ========================================================================= #

use_tp1 = input.bool(true, title = "Use Take Profit 1?", group = "Take Profit 1")
tp1_value = input.float(30, minval = 0, title = "Value", group = "Take Profit 1")
tp1_qty   = input.float(50, minval = 0, title = "Quantity (%)", group = "Take Profit 1")

use_tp2   = input.bool(true, title = "Use Take Profit 2?", group = "Take Profit 2")
tp2_value = input.float(50, minval = 0, title = "Value", group = "Take Profit 2")

// # ========================================================================= #
// #                   | Stop Loss to Breakeven |
// # ========================================================================= #

use_sl_be         = input.bool(false, title = "Use Stop Loss to Breakeven Mode?", group = "Break Even")
sl_be_value       = input.float(30, step = 0.1, minval = 0, title = "Value (pips)", group = "Break Even", inline = "breakeven")
sl_be_offset      = input.int(1, step = 1, minval = 0, title = "Offset (pips)", group = "Break Even", tooltip = "Set the SL at BE price +/- offset value")

// # ========================================================================= #
// #                   | Pine Utilities |
// # ========================================================================= #

// Source: https://www.tradingview.com/pine-script-reference/v5/#var_strategy.margin_liquidation_price
changePercent(v1, v2) => 
    float result = (v1 - v2) * 100 / math.abs(v2)

// Source: https://www.tradingview.com/pine-script-reference/v5/#fun_strategy.closedtrades.profit
// Calculate sum gross profit from all closed trades by adding the difference between gross profit and commission.
SumGrossProfitClosedTrades() =>
    sumGrossProfit = 0.0
    for tradeNo = 0 to strategy.closedtrades - 1
        sumGrossProfit += strategy.closedtrades.profit(tradeNo) - strategy.closedtrades.commission(tradeNo)
    result = nz(sumGrossProfit)

get_pip_size() =>

    float _pipsize = 1.

    if syminfo.type == "forex" 
        _pipsize := (syminfo.mintick * (str.contains(syminfo.ticker, "JPY") ? 100 : 10))
    else if str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "XAG")
        _pipsize := 0.1

    _pipsize

// # ========================================================================= #
// #                   | Calculations |
// # ========================================================================= #

bull = ext_connector == 1  and barstate.isconfirmed
bear = ext_connector == -1 and barstate.isconfirmed

signal_candle = bull or bear

signal_bull = bull and strategy.position_size[1] <= 0
signal_bear = bear and strategy.position_size[1] >= 0

entryLongPrice  = ta.valuewhen(signal_bull, close, 0)
entryShortPrice = ta.valuewhen(signal_bear, close, 0)

plot(strategy.position_size > 0 ? entryLongPrice : na, title = "Long Entry Price", color = color.green, linewidth = 2, style = plot.style_circles)
plot(strategy.position_size < 0 ? entryShortPrice : na, title = "Short Entry Price", color = color.red, linewidth = 2, style = plot.style_circles)

var label entry_label = na

if barstate.islast

    if strategy.position_size > 0
        entry_label := label.new(x = bar_index + 5, y = entryLongPrice, text = "Long Entry: " + str.tostring(entryLongPrice, format.mintick), style = label.style_label_left, color = color.green, size = size.normal)
    else if strategy.position_size < 0
        entry_label := label.new(x = bar_index + 5, y = entryShortPrice, text = "Short Entry: " + str.tostring(entryShortPrice, format.mintick), style = label.style_label_left, color = color.red, size = size.normal)

// # ========================================================================= #
// #                   |   Stop Loss |
// # ========================================================================= #

var float final_SL_Long = 0.
var float final_SL_Short = 0.

var float final_SL_Long_Pineconnector = 0.
var float final_SL_Short_Pineconnector = 0.

if use_sl

    if signal_bull
        final_SL_Long  := (sl_tp_mode == "pips") ? entryLongPrice  - (sl_value * get_pip_size()) : entryLongPrice * (1 - (sl_value * 0.01))
    else if signal_bear
        final_SL_Short := (sl_tp_mode == "pips") ? entryShortPrice + (sl_value * get_pip_size()) : entryShortPrice * (1 + (sl_value * 0.01))

// # ========================================================================= #
// #                   |   Trailing Stop Loss |
// # ========================================================================= #

var MaxReached = 0.0  

if signal_candle[1]

    MaxReached := strategy.position_size > 0 ? high : low

MaxReached := strategy.position_size > 0
 ? math.max(nz(MaxReached, high), high)
 : strategy.position_size < 0 ? math.min(nz(MaxReached, low), low) : na

if use_tsl and use_sl

    if strategy.position_size > 0

        stopValue = MaxReached - (tsl_input_value * get_pip_size())
        final_SL_Long := math.max(stopValue, final_SL_Long[1])

    else if strategy.position_size < 0

        stopValue = MaxReached + (tsl_input_value * get_pip_size())
        final_SL_Short := math.min(stopValue, final_SL_Short[1])

// # ========================================================================= #
// #                   |   Take Profit 1 |
// # ========================================================================= #

var float final_TP1_Long  = 0.
var float final_TP1_Short = 0.

if use_tp1

    if signal_bull
        final_TP1_Long  := (sl_tp_mode == "pips") ? entryLongPrice  + (tp1_value * get_pip_size()) : entryLongPrice * (1 + (tp1_value * 0.01))
    else if signal_bear
        final_TP1_Short := (sl_tp_mode == "pips") ? entryShortPrice - (tp1_value * get_pip_size()) : entryShortPrice * (1 - (tp1_value * 0.01))

plot(use_tp1 and strategy.position_size > 0 ? final_TP1_Long : na, title = "TP1 Long", color = color.aqua, linewidth=2, style=plot.style_linebr)
plot(use_tp1 and strategy.position_size < 0 ? final_TP1_Short : na, title = "TP1 Short", color = color.blue, linewidth=2, style=plot.style_linebr)

var label tp1_label = na

if barstate.islast and use_tp1

    if strategy.position_size > 0
        tp1_label := label.new(x = bar_index + 5, y = final_TP1_Long, text = "TP1: " + str.tostring(final_TP1_Long, format.mintick), style = label.style_label_left, color = color.aqua, size = size.normal)
    else if strategy.position_size < 0
        tp1_label := label.new(x = bar_index + 5, y = final_TP1_Short, text = "TP1: " + str.tostring(final_TP1_Short, format.mintick), style = label.style_label_left, color = color.blue, size = size.normal)

// # ========================================================================= #
// #                   |   Take Profit 2 |
// # ========================================================================= #

var float final_TP2_Long  = 0.
var float final_TP2_Short = 0.

if use_tp2 and tp1_qty != 100

    if signal_bull
        final_TP2_Long  := (sl_tp_mode == "pips") ? entryLongPrice  + (tp2_value * get_pip_size()) : entryLongPrice * (1 + (tp2_value * 0.01))
    else if signal_bear
        final_TP2_Short := (sl_tp_mode == "pips") ? entryShortPrice - (tp2_value * get_pip_size()) : entryShortPrice * (1 - (tp2_value * 0.01))

plot(use_tp2 and strategy.position_size > 0 and tp1_qty != 100 ? final_TP2_Long : na, title = "TP2 Long", color = color.orange, linewidth=2, style=plot.style_linebr)
plot(use_tp2 and strategy.position_size < 0 and tp1_qty != 100 ? final_TP2_Short : na, title = "TP2 Short", color = color.white, linewidth=2, style=plot.style_linebr)

var label tp2_label = na

if barstate.islast and use_tp2

    if strategy.position_size > 0 and tp1_qty != 100
        tp2_label := label.new(x = bar_index + 5, y = final_TP2_Long, text = "TP2: " + str.tostring(final_TP2_Long, format.mintick), style = label.style_label_left, color = color.orange, size = size.normal)
    else if strategy.position_size < 0 and tp1_qty != 100
        tp2_label := label.new(x = bar_index + 5, y = final_TP2_Short, text = "TP2: " + str.tostring(final_TP2_Short, format.mintick), style = label.style_label_left, color = color.white, size = size.normal)

// # ========================================================================= #
// #                   |   Stop Loss to Breakeven |
// # ========================================================================= #

var bool SL_BE_REACHED = false

// Calculate open profit or loss for the open positions.
tradeOpenPL() =>
    sumProfit = 0.0
    for tradeNo = 0 to strategy.opentrades - 1
        sumProfit += strategy.opentrades.profit(tradeNo)
    result = sumProfit

current_profit = tradeOpenPL()// * get_pip_size()

current_long_profit = (close - entryLongPrice) / (syminfo.mintick * 10)
current_short_profit = (entryShortPrice - close) / (syminfo.mintick * 10)

plot(current_short_profit, title = "Current Short Profit", display = display.data_window)
plot(current_long_profit, title = "Current Long Profit", display = display.data_window)

if use_sl_be

    if strategy.position_size > 0

        if not SL_BE_REACHED

            if current_long_profit >= sl_be_value 
                final_SL_Long := entryLongPrice + (sl_be_offset * get_pip_size())
                SL_BE_REACHED := true

    else if strategy.position_size < 0

        if not SL_BE_REACHED

            if current_short_profit >= sl_be_value 
                final_SL_Short := entryShortPrice - (sl_be_offset * get_pip_size())
                SL_BE_REACHED := true

plot(use_sl and strategy.position_size > 0 ? final_SL_Long : na, title = "SL Long", color = color.fuchsia, linewidth=2, style=plot.style_linebr)
plot(use_sl and strategy.position_size < 0 ? final_SL_Short : na, title = "SL Short", color = color.fuchsia, linewidth=2, style=plot.style_linebr)

var label sl_label = na

if barstate.islast and use_sl

    if strategy.position_size > 0
        sl_label := label.new(x = bar_index + 5, y = final_SL_Long, text = "SL: " + str.tostring(final_SL_Long, format.mintick), style = label.style_label_left, color = color.fuchsia, size = size.normal)
    else if strategy.position_size < 0
        sl_label := label.new(x = bar_index + 5, y = final_SL_Short, text = "SL: " + str.tostring(final_SL_Short, format.mintick), style = label.style_label_left, color = color.fuchsia, size = size.normal)


// # ========================================================================= #
// #                   |   Pineconnector Alerts Message  |
// # ========================================================================= #

string entry_long_limit_alert_message = ""
string entry_long_TP1_alert_message = ""
string entry_long_TP2_alert_message = ""

var float tp1_qty_perc = tp1_qty / 100

var string buy_command = ""
var string sell_command = ""

// Executing this only once at the beginning of the strategy
if barstate.isfirst
    if order_type_mode == "Market"
        buy_command  := ",buy," + syminfo.ticker
        sell_command := ",sell," + syminfo.ticker
    else if order_type_mode == "Limit"
        buy_command  := ",buylimit,"  + syminfo.ticker + ",price=" + str.tostring(order_type_price)
        sell_command := ",selllimit," + syminfo.ticker + ",price=" + str.tostring(order_type_price)
    else if order_type_mode == "Stop"
        buy_command  := ",buystop," + syminfo.ticker + ",price=" + str.tostring(order_type_price)
        sell_command := ",sellstop," + syminfo.ticker + ",price=" + str.tostring(order_type_price)

//pos_size = math.abs(strategy.position_size)

if use_tp1 and use_tp2

    entry_long_TP1_alert_message := pineconnector_licence_ID + buy_command + ",risk=" + str.tostring(pos_size * tp1_qty_perc) + ",tp=" + str.tostring(final_TP1_Long, format.mintick)
     + (use_sl ? ",sl=" + str.tostring(final_SL_Long, format.mintick) : "") + (use_sl_be ? ",beoffset=" + str.tostring(sl_be_offset) + ",betrigger=" + str.tostring(sl_be_value) : "")
     + (use_tsl ? ",trailtrig=" + str.tostring(tsl_input_value) + ",traildist=" + str.tostring(tsl_input_value) + ",trailstep=1" : "")
     + (use_spread_filter ? ",spread=" + str.tostring(spread_value) : "") + (use_acc_filter ? ",accfilter=" + str.tostring(accfilter_value) : "")

    entry_long_TP2_alert_message := pineconnector_licence_ID + buy_command + ",risk=" + str.tostring(pos_size - (pos_size * tp1_qty_perc)) + ",tp=" + str.tostring(final_TP2_Long, format.mintick)
     + (use_sl ? ",sl=" + str.tostring(final_SL_Long, format.mintick) : "") + (use_sl_be ? ",beoffset=" + str.tostring(sl_be_offset) + ",betrigger=" + str.tostring(sl_be_value) : "")
     + (use_tsl ? ",trailtrig=" + str.tostring(tsl_input_value) + ",traildist=" + str.tostring(tsl_input_value) + ",trailstep=1" : "")
     + (use_spread_filter ? ",spread=" + str.tostring(spread_value) : "") + (use_acc_filter ? ",accfilter=" + str.tostring(accfilter_value) : "")

else if use_tp1 and (not use_tp2 or tp1_qty == 100)

    entry_long_TP1_alert_message := pineconnector_licence_ID + buy_command + ",risk=" + str.tostring(pos_size * tp1_qty_perc) + ",tp=" + str.tostring(final_TP1_Long, format.mintick)
     + (use_sl ? ",sl=" + str.tostring(final_SL_Long, format.mintick) : "") + (use_sl_be ? ",beoffset=" + str.tostring(sl_be_offset) + ",betrigger=" + str.tostring(sl_be_value) : "")
     + (use_tsl ? ",trailtrig=" + str.tostring(tsl_input_value) + ",traildist=" + str.tostring(tsl_input_value) + ",trailstep=1" : "")
     + (use_spread_filter ? ",spread=" + str.tostring(spread_value) : "") + (use_acc_filter ? ",accfilter=" + str.tostring(accfilter_value) : "")

else if not use_tp1 and use_tp2

    entry_long_TP2_alert_message := pineconnector_licence_ID + buy_command + ",risk=" + str.tostring(pos_size) + ",tp=" + str.tostring(final_TP2_Long, format.mintick)
     + (use_sl ? ",sl=" + str.tostring(final_SL_Long, format.mintick) : "") + (use_sl_be ? ",beoffset=" + str.tostring(sl_be_offset) + ",betrigger=" + str.tostring(sl_be_value) : "")
     + (use_tsl ? ",trailtrig=" + str.tostring(tsl_input_value) + ",traildist=" + str.tostring(tsl_input_value) + ",trailstep=1" : "")
     + (use_spread_filter ? ",spread=" + str.tostring(spread_value) : "") + (use_acc_filter ? ",accfilter=" + str.tostring(accfilter_value) : "")

entry_long_limit_alert_message := entry_long_TP1_alert_message + "\n" + entry_long_TP2_alert_message

//entry_long_limit_alert_message = pineconnector_licence_ID + ",buystop," + syminfo.ticker + ",price=" + str.tostring(buy_price) + ",risk=" + str.tostring(pos_size) + ",tp=" + str.tostring(final_TP_Long) + ",sl=" + str.tostring(final_SL_Long)

//entry_short_market_alert_message = pineconnector_licence_ID + ",sell," + syminfo.ticker + ",risk=" + str.tostring(pos_size) + (use_tp1 ? ",tp=" + str.tostring(final_TP1_Short) : "")
// + (use_sl ? ",sl=" + str.tostring(final_SL_Short) : "")

//entry_short_limit_alert_message = pineconnector_licence_ID + ",sellstop," + syminfo.ticker + ",price=" + str.tostring(sell_price) + ",risk=" + str.tostring(pos_size) + ",tp=" + str.tostring(final_TP_Short) + ",sl=" + str.tostring(final_SL_Short)

string entry_short_limit_alert_message = ""
string entry_short_TP1_alert_message = ""
string entry_short_TP2_alert_message = ""

if use_tp1 and use_tp2
    
    entry_short_TP1_alert_message := pineconnector_licence_ID + sell_command + ",risk=" + str.tostring(pos_size * tp1_qty_perc) + ",tp=" + str.tostring(final_TP1_Short, format.mintick) 
     + (use_sl ? ",sl=" + str.tostring(final_SL_Short, format.mintick) : "") + (use_sl_be ? ",beoffset=" + str.tostring(sl_be_offset) + ",betrigger=" + str.tostring(sl_be_value) : "")
     + (use_tsl ? ",trailtrig=" + str.tostring(tsl_input_value) + ",traildist=" + str.tostring(tsl_input_value) + ",trailstep=1" : "")
     + (use_spread_filter ? ",spread=" + str.tostring(spread_value) : "") + (use_acc_filter ? ",accfilter=" + str.tostring(accfilter_value) : "")

    entry_short_TP2_alert_message := pineconnector_licence_ID + sell_command + ",risk=" + str.tostring(pos_size - (pos_size * tp1_qty_perc)) + ",tp=" + str.tostring(final_TP2_Short, format.mintick)
     + (use_sl ? ",sl=" + str.tostring(final_SL_Short, format.mintick) : "") + (use_sl_be ? ",beoffset=" + str.tostring(sl_be_offset) + ",betrigger=" + str.tostring(sl_be_value) : "")
     + (use_tsl ? ",trailtrig=" + str.tostring(tsl_input_value) + ",traildist=" + str.tostring(tsl_input_value) + ",trailstep=1" : "")
     + (use_spread_filter ? ",spread=" + str.tostring(spread_value) : "") + (use_acc_filter ? ",accfilter=" + str.tostring(accfilter_value) : "")

else if use_tp1 and (not use_tp2 or tp1_qty == 100)

    entry_short_TP1_alert_message := pineconnector_licence_ID + sell_command + ",risk=" + str.tostring(pos_size * tp1_qty_perc) + ",tp=" + str.tostring(final_TP1_Short, format.mintick)
     + (use_sl ? ",sl=" + str.tostring(final_SL_Short, format.mintick) : "") + (use_sl_be ? ",beoffset=" + str.tostring(sl_be_offset) + ",betrigger=" + str.tostring(sl_be_value) : "")
     + (use_tsl ? ",trailtrig=" + str.tostring(tsl_input_value) + ",traildist=" + str.tostring(tsl_input_value) + ",trailstep=1" : "")
     + (use_spread_filter ? ",spread=" + str.tostring(spread_value) : "") + (use_acc_filter ? ",accfilter=" + str.tostring(accfilter_value) : "")

else if not use_tp1 and use_tp2

    entry_short_TP2_alert_message := pineconnector_licence_ID + sell_command + ",risk=" + str.tostring(pos_size) + ",tp=" + str.tostring(final_TP2_Short, format.mintick)
     + (use_sl ? ",sl=" + str.tostring(final_SL_Short, format.mintick) : "") + (use_sl_be ? ",beoffset=" + str.tostring(sl_be_offset) + ",betrigger=" + str.tostring(sl_be_value) : "")
     + (use_tsl ? ",trailtrig=" + str.tostring(tsl_input_value) + ",traildist=" + str.tostring(tsl_input_value) + ",trailstep=1" : "")
     + (use_spread_filter ? ",spread=" + str.tostring(spread_value) : "") + (use_acc_filter ? ",accfilter=" + str.tostring(accfilter_value) : "")

entry_short_limit_alert_message := entry_short_TP1_alert_message + "\n" + entry_short_TP2_alert_message

long_update_sl_alert_message  = pineconnector_licence_ID + ",newsltplong," + syminfo.ticker + ",sl=" + str.tostring(final_SL_Long)
short_update_sl_alert_message = pineconnector_licence_ID + ",newsltpshort," + syminfo.ticker + ",sl=" + str.tostring(final_SL_Short)

cancel_long = pineconnector_licence_ID + ",cancellong," + syminfo.ticker// + "x"

cancel_short = pineconnector_licence_ID + ",cancellong," + syminfo.ticker// + "x"

close_long  = pineconnector_licence_ID + ",closelong," + syminfo.ticker
close_short = pineconnector_licence_ID + ",closeshort," + syminfo.ticker

// Close all positions and orders, and off/halt the PineConnector EA.
halt_ea_message    = pineconnector_licence_ID + ",closealleaoff," + syminfo.ticker

// Reactivates the PineConnector EA from halt.
restart_ea_message = pineconnector_licence_ID + ",eaon,eaon"

// # ========================================================================= #
// #                   |   EA global variables |
// # ========================================================================= #

// Flag to remember to stop taking trades if we get too much Rekt :) 
var bool HALT_STRATEGY = false

// # ========================================================================= #
// #                   |   Risk Management |
// # ========================================================================= #

strategy.risk.max_drawdown(use_drawdown_EA_halt ? max_drawdown_value : 100, use_drawdown_EA_halt ? (max_drawdown_mode == "%" ? strategy.percent_of_equity : strategy.cash) : strategy.percent_of_equity, halt_ea_message)

strategy.risk.max_intraday_loss(use_intraday_losses_EA_halt and timeframe.isintraday ? nb_intraday_losses : 999999, use_intraday_losses_EA_halt and timeframe.isintraday ? (intraday_loss_value == "%" ? strategy.percent_of_equity : strategy.cash) : strategy.percent_of_equity, halt_ea_message)

strategy.risk.max_cons_loss_days(use_max_consecutive_days_EA_halt ? nb_max_consecutive_days : 999999, halt_ea_message)

strategy.risk.max_intraday_filled_orders(use_limit_intraday_trades and timeframe.isintraday ? nb_max_intraday_trades : 999999, halt_ea_message)

// Restart the EA if it's an intraday chart and it has been paused due to intraday max losses or intraday max filled orders

// test if it's a new day
newDay = dayofmonth != dayofmonth[1]

bgcolor(use_restart_intraday_EA and newDay and timeframe.isintraday ? color.aqua : na, title = "Restart EA at the first candle of the day")

if use_restart_intraday_EA and newDay and timeframe.isintraday
    alert(restart_ea_message, alert.freq_once_per_bar_close)

// # ========================================================================= #
// #                   |   Streak Management |
// # ========================================================================= #

// Source: https://www.tradingcode.net/tradingview/losing-streak/

// Check if there's a new losing trade that increased the streak
newLoss = strategy.losstrades > strategy.losstrades[1] and
     strategy.wintrades == strategy.wintrades[1] and
     strategy.eventrades == strategy.eventrades[1]

// Determine current losing streak length
streakLen = 0

streakLen := if newLoss
    nz(streakLen[1]) + 1
else
    if strategy.wintrades > strategy.wintrades[1] or
         strategy.eventrades > strategy.eventrades[1]
        0
    else
        nz(streakLen[1])

// Show current losing streak and its limit on chart
//plot(use_max_losing_streak ? streakLen : na, style=plot.style_columns, color=streakLen < maxLosingStreak ? color.maroon : color.red, title = "Max Losing Streak")
bgcolor(use_max_losing_streak and newLoss ? color.new(color.red, 80) : na, title = "New Loss Streak")

// Send the message to Pineconnector if the losing streak is too long
if streakLen > maxLosingStreak
    HALT_STRATEGY := true
    alert(halt_ea_message, alert.freq_once_per_bar_close)

// # ========================================================================= #
// #                   |   Money Management |
// # ========================================================================= #

if use_margin_call
    if math.abs(changePercent(close, strategy.margin_liquidation_price)) <= margin_call_value
        HALT_STRATEGY := true
        strategy.close_all(comment = "Closing all trades to avoid Margin Liq", alert_message = halt_ea_message)
        //alert(halt_ea_message, alert.freq_once_per_bar_close)  

if use_close_EA_total_loss
    strategy_closeprofit = SumGrossProfitClosedTrades()
    // Test if the total profit/loss of all close//open positions is below the total loss input value
    if (strategy_closeprofit + strategy.openprofit) <= total_loss_value
        HALT_STRATEGY := true
        strategy.close_all(comment = "Closing all trades to avoid Total Loss", alert_message = halt_ea_message)

// # ========================================================================= #
// #                   |   Trades Direction |
// # ========================================================================= #

// Didn't work
// strategy.risk.allow_entry_in(strat_direction)

// # ========================================================================= #
// #                   |   Strategy Calls (Entries/SL/TPs) |
// # ========================================================================= #

open_all  = strat_direction  == strategy.direction.all
open_long  = strat_direction != strategy.direction.short
open_short = strat_direction != strategy.direction.long

// Entries
if bull and strategy.position_size <= 0 and open_long and (not HALT_STRATEGY)
    
    alert(close_short, alert.freq_once_per_bar_close)
    strategy.entry("Long", strategy.long, limit = order_type_mode == "Limit" ? order_type_price : na, stop = order_type_mode == "Stop" ? order_type_price : na)
    alert(entry_long_TP1_alert_message, alert.freq_once_per_bar_close)
    alert(entry_long_TP2_alert_message, alert.freq_once_per_bar_close)

else if bear and strategy.position_size >= 0 and open_short and (not HALT_STRATEGY)
    
    alert(close_long, alert.freq_once_per_bar_close)
    strategy.entry("Short", strategy.short, limit = order_type_mode == "Limit" ? order_type_price : na, stop = order_type_mode == "Stop" ? order_type_price : na)
    alert(entry_short_TP1_alert_message, alert.freq_once_per_bar_close)
    alert(entry_short_TP2_alert_message, alert.freq_once_per_bar_close)

if strategy.position_size[1] > 0

    // This handles the SL being hit even after a SL/BE and/or TSL has been triggered
    if low <= final_SL_Long and use_sl
        strategy.close("Long", alert_message = close_long, comment = "SL Long")
    else
        strategy.exit("Exit TP1 Long", "Long", limit = use_tp1 ? final_TP1_Long : na, comment_profit = "Exit TP1 Long", qty_percent = tp1_qty)
        strategy.exit("Exit TP2 Long", "Long", limit = use_tp2 ? final_TP2_Long : na, comment_profit = "Exit TP2 Long", alert_message = close_long)

else if strategy.position_size[1] < 0

    // This handles the SL being hit even after a SL/BE and/or TSL has been triggered
    if high >= final_SL_Short and use_sl
        strategy.close("Short", alert_message = close_short, comment = "SL Short")
    else
        strategy.exit("Exit TP1 Short", "Short", limit = use_tp1 ? final_TP1_Short : na, comment_profit = "Exit TP1 Short", qty_percent = tp1_qty)
        strategy.exit("Exit TP2 Short", "Short", limit = use_tp2 ? final_TP2_Short : na, comment_profit = "Exit TP2 Short")

// # ========================================================================= #
// #                   |   Logs  |
// # ========================================================================= #

if bull and strategy.position_size <= 0
    log.info(entry_long_limit_alert_message)

else if bear and strategy.position_size >= 0
    log.info(entry_short_limit_alert_message)

// # ========================================================================= #
// #                   |   Reset Variables  |
// # ========================================================================= #


if (strategy.position_size > 0 and strategy.position_size[1] <= 0)
 or (strategy.position_size < 0 and strategy.position_size[1] >= 0)

    //is_TP1_REACHED := false
    SL_BE_REACHED := false
````
