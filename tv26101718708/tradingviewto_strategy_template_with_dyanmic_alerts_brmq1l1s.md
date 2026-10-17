# TradingView.To Strategy Template (with Dyanmic Alerts)

- url: https://www.tradingview.com/script/brMq1l1s-TradingView-To-Strategy-Template-with-Dyanmic-Alerts/
- type: strategy
- pine_id: PUB;84050e95cb324618b3eaac4008022d5c
- version: 1.0

## Description

Hello traders,

If you're tired of manual trading and looking for a solid strategy template to pair with your indicators, look no further.
This Pine Script v5 strategy template is engineered for maximum customization and risk management.
Best part?
This Pine Script v5 template facilitates the dynamic construction of TradingView.TO alerts, sparing users the time and effort of mastering the TradingView.TO syntax and manually create alert commands.

This powerful tool gives much power to those who don't know how to code in Pinescript and want to automate their indicators' signals via TradingView.TO bot.

[b]IMPORTANT NOTES[/b]

TradingView.TO is a trading bot software that forwards TradingView alerts to your brokers (examples: Binance, Oanda, Coinbase, Bybit, Metatrader 4/5, ...) for automating trading.
Many traders don't know how to create TradingView.TO dynamically-compatible alerts using the data from their TradingView scripts.

Traders using trading bots want their alerts to reflect the stop-loss/take-profit/trailing-stop/stop-loss to break options from your script and then create the orders accordingly.

This script showcases how to create TradingView.TO alerts dynamically.

[b]TRADINGVIEW ALERTS[/b]

1) You'll have to create one alert per asset X timeframe = 1 chart.
Example: 1 alert for BTC/USDT on the 5 minutes chart, 1 alert for BTC/USDT on the 15-minute chart (assuming you want your bot to trade the BTC/USDT on the 5 and 15-minute timeframes)

2) Select the Order fills and alert() function calls condition

3) For each alert, the alert message is pre-configured with the text below
{{strategy.order.alert_message}}

Please leave it as it is.
It's a TradingView native variable that will fetch the alert text messages built by the script.

4) TradingView.TO uses webhook technology - setting a webhook URL from the alerts notifications tab is required.

[b]KEY FEATURES[/b]

[b]I) Modular Indicator Connection[/b]
* plug your existing indicator into the template.
* Only two lines of code are needed for full compatibility.

Step 1: Create your connector

Adapt your indicator with only 2 lines of code and then connect it to this strategy template.

To do so:

1) Find in your indicator where the conditions print the long/buy and short/sell signals.
2) Create an additional plot as below

I'm giving an example with a Two moving averages cross.

Please replicate the same methodology for your indicator, whether a MACD , ZigZag, Pivots , higher-highs, lower-lows or whatever indicator with clear buy and sell conditions.

[pine]
//@version=5
indicator("Supertrend", overlay = true, timeframe = "", timeframe_gaps = true)

atrPeriod = input.int(10,    "ATR Length", minval = 1)
factor =    input.float(3.0, "Factor",     minval = 0.01, step = 0.01)

[supertrend, direction] = ta.supertrend(factor, atrPeriod)

supertrend := barstate.isfirst ? na : supertrend
bodyMiddle = plot(barstate.isfirst ? na : (open + close) / 2, display = display.none)
upTrend =    plot(direction &lt; 0 ? supertrend : na, "Up Trend",   color = color.green, style = plot.style_linebr)
downTrend =  plot(direction &lt; 0 ? na : supertrend, "Down Trend", color = color.red,   style = plot.style_linebr)

fill(bodyMiddle, upTrend,   color.new(color.green, 90), fillgaps = false)
fill(bodyMiddle, downTrend, color.new(color.red,   90), fillgaps = false)

buy  = ta.crossunder(direction, 0)
sell = ta.crossunder(direction, 0)

//////// CONNECTOR SECTION //////// 

Signal = buy ? 1 : sell ? -1 : 0
plot(Signal, title = "Signal", display = display.data_window)

//////// CONNECTOR SECTION //////// 

[b]Important Notes[/b]

🔥 The Strategy Template expects the value to be exactly 1 for the bullish signal and -1 for the bearish signal

Now, you can connect your indicator to the Strategy Template using the method below or that one.

Step 2: Connect the connector

1) Add your updated indicator to a TradingView chart
2) Add the Strategy Template as well to the SAME chart
3) Open the Strategy Template settings, and in the Data Source field, select your 🔌Connector🔌 (which comes from your indicator)

Note it doesn’t have to be named 🔌Connector🔌 - you can name it as you want - however, I recommend an explicit name you can easily remember.

From then, you should start seeing the signals and plenty of other stuff on your chart.

🔥 Note that whenever you update your indicator values, the strategy statistics and visuals on your chart will update in real-time
[/pine]

[b]II) BOT Risk Management:[/b]

- Max Drawdown:
Mode: Select whether the max drawdown is calculated in percentage (%) or USD.
Value: If the max drawdown reaches this specified value, set a value to halt the bot.

- Max Consecutive Days:
Use Max Consecutive Days BOT Halt: Enable/Disable halting the bot if the max consecutive losing days value is reached.

- Max Consecutive Days: Set the maximum number of consecutive losing days allowed before halting the bot.

- Max Losing Streak:
Use Max Losing Streak: Enable/Disable a feature to prevent the bot from taking too many losses in a row.

- Max Losing Streak Length: Set the maximum length of a losing streak allowed.
Margin Call:

- Use Margin Call: Enable/Disable a feature to exit when a specified percentage away from a margin call to prevent it.
Margin Call (%): Set the percentage value to trigger this feature.

- Close BOT Total Loss:
Use Close BOT Total Loss: Enable/Disable a feature to close all trades and halt the bot if the total loss is reached.

- Total Loss ($): Set the total loss value in USD to trigger this feature.
Intraday BOT Risk Management:

- Intraday Losses:
Use Intraday Losses BOT Halt: Enable/Disable halting the bot on reaching specified intraday losses.
Mode: Select whether the intraday loss is calculated in percentage (%) or USD.

- Max Intraday Losses (%): Set the value for maximum intraday losses.
Limit Intraday Trades:

- Use Limit Intraday Trades: Enable/Disable a feature to limit the number of intraday trades.

- Max Intraday Trades: Set the maximum number of intraday trades allowed.
Restart Intraday EA:

[b]III) Order Types and Position Sizing[/b]

- Choose between market or limit orders.
- Set your position size directly in the template.

Please use the position size from the “Inputs” and not the “Properties” tab.
I know it's redundant. - the template needs this value from the "Inputs" tab to build the alerts, and the Backtester needs it from the "Properties" tab.

[b]IV) Advanced Take-Profit and Stop-Loss Options[/b]

- Choose to set your SL/TP in either USD or percentages.
- Option for multiple take-profit levels and trailing stop losses.
- Move your stop loss to break even +/- offset in USD for “risk-free” trades.

V) Miscellaneous:
Retry order openings if they fail.

Order Types:
Select and specify order type and price settings.

Position Size:
Define the type and size of positions.

Leverage:
Leverage settings, including margin type and hedge mode.

Session:
Limit trades to specific sessions.

Dates:
Limit trades to a specific date range.

Trades Direction:
Direction: Specify the market direction for opening positions.

[b]VI) Logger[/b]

The TradingView.TO commands are logged in the TradingView logger.
You'll find more information about it in this [url=https://www.tradingview.com/blog/en/pine-logs-in-pine-script-40490/]TradingView blog post[/url].

[b]WHY YOU MIGHT NEED THIS TEMPLATE[/b]

1) Transform your indicator into a TradingView.TO trading bot more easily than before
Connect your indicator to the template
Create your alerts
Set your EA settings

2) Save Time
Auto-generated alert messages for TradingView.TO.
I tested them all and checked with the support team what could/couldn’t be done.

3) Be in Control
Manage your trading risks with advanced features.

4) Customizable
Fits various trading styles and asset classes.

REQUIREMENTS

* Make sure you have your TradingView.TO account
* If there is any issue with the template, ask me in the comments section - I’ll answer quickly.

[b]BACKTEST RESULTS FROM THIS POST[/b]

1) I connected this strategy template to a dummy Supertrend script.
I could have selected any other indicator or concept for this script post.
I wanted to share an example of how you can quickly upgrade your strategy, making it compatible with TradingView.TO.

2) The backtest results aren't relevant for this educational script publication.
I used realistic backtesting data but didn't look too much into optimizing the results, as this isn't the point of why I'm publishing this script. This strategy is a template to be connected to any indicator - the sky is the limit. :)

3) This template is made to take 1 trade per direction at any given time.
Pyramiding is set to 1 on TradingView.

The strategy default settings are:

* Initial Capital: 100000 USD
* Position Size: 1%
* Commission Percent: 0.075%
* Slippage: 1 tick
* No margin/leverage used

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


SCRIPT_NAME = "TradingViewTO Strategy Template"

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

tradingviewto_account_ID = input.string(title = "Account Name", defval = "USDM", group = "Account Name", tooltip = "Insert your TradingViewTO Account Name here")

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

// # ========================================================================= #
// #                   | Trading Mode |
// # ========================================================================= #

trading_mode    = input.string("Spot", title = "Trading Mode", options = ["Spot", "Margin"], group = "Trading Mode", tooltip = "Spot for buy/sell orders\nMargin for long/short orders")

// # ========================================================================= #
// #                   | Order Types |
// # ========================================================================= #

order_type_mode = input.string("Market", title = "Order Type", options = ["Market", "Limit"], group = "Order Types")
order_type_price = input.float(10, title = "Price", group = "Order Types", 
 tooltip = "With 'Limit', below the current market price for a buy - above the current market price for a sell")

// # ========================================================================= #
// #                   | Position Size |
// # ========================================================================= #

pos_type       = input.string("Units", title = "Position Type", options = ["Units", "Percent"], group = "Position Size", tooltip = "Select the position type you want to use for this strategy")
pos_size       = input.float(3, minval = 0, maxval = 100, title = "Position Size", group = "Position Size", tooltip = "Required to specify the position size here for ProfitView to work properly")

// # ========================================================================= #
// #                   | Leverage |
// # ========================================================================= #

//margin_type    = input.string("Isolated", title = "Margin Type", options = ["Isolated", "Crossed"], group = "Leverage", tooltip = "Select the margin type you want to use for this strategy")
use_leverage   = input.bool(false, title = "Use Leverage?", group = "Leverage", tooltip = "Use this option if you want to use the Leverage for this strategy")
leverage_value = input.float(1, minval = 0, title = "Value", group = "Leverage", tooltip = "Required to specify the leverage here for ProfitView to work properly")
use_hedge_mode = input.bool(false, title = "Use Hedge Mode?", group = "Leverage", tooltip = "Use this option if you want to use the Hedge mode for this strategy")

// # ========================================================================= #
// #                   | Sessions |
// # ========================================================================= #

use_session = input.bool(false, title='Use Sessions ?', group='Session', tooltip = "Limit the trades between a start and end time")
Session = input.session(title='Trading Session', defval='0000-2345', group='Session')
sess_timezone = input.string('UTC-5', title='Session Timezone', group='Session')

close_trades_end_session = input.bool(false, title='Close Trades at End of Session ?', group='Session', tooltip = "Close all the trades at the end of the session")

// # ========================================================================= #
// #                   | Dates |
// # ========================================================================= #

// ————— Syntax coming from https://www.tradingview.com/blog/en/new-parameter-for-date-input-added-to-pine-21812/

use_date = input.bool(false, title='Use Date Filter ?', group='Date', tooltip = "Limit the trades between a start and end date")
i_startTime = input.time(defval=timestamp('01 Jan 2019 13:30 +0000'), title='Start Time', group='Date')
i_endTime = input.time(defval=timestamp('30 Dec 2021 23:30 +0000'), title='End Time', group='Date')

TradeDateIsAllowed() =>
    use_date ? time >= i_startTime and time <= i_endTime : true
// # ========================================================================= #
// #                   | Direction |
// # ========================================================================= #

strat_direction = input.string(strategy.direction.all, title = "Direction", options = [strategy.direction.all, strategy.direction.long, strategy.direction.short], group = "Trades Direction", tooltip = "To specify in which market direction the strategy is allowed to open positions.")

//use_close_opposite = input.bool(false, title = "Close on Opposite Signal?", group = "Close on Opposite", tooltip = "Close the position if 1 or more MACDs become bearish (for longs) or bullish (for shorts)")

// # ========================================================================= #
// #                   | General SL/TP |
// # ========================================================================= #

sl_tp_mode = input.string("USD", title = "Mode", options = ["USD", "%"], group = "General SL/TP", tooltip = "Select the mode you want to use for the SL/TP values\nSelect the same mode in the TradingViewTO EA on Metatrader")

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
        final_SL_Long  := (sl_tp_mode == "USD") ? entryLongPrice  - (sl_value * get_pip_size()) : entryLongPrice * (1 - (sl_value * 0.01))
    else if signal_bear
        final_SL_Short := (sl_tp_mode == "USD") ? entryShortPrice + (sl_value * get_pip_size()) : entryShortPrice * (1 + (sl_value * 0.01))

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
        final_TP1_Long  := (sl_tp_mode == "USD") ? entryLongPrice  + (tp1_value * get_pip_size()) : entryLongPrice * (1 + (tp1_value * 0.01))
    else if signal_bear
        final_TP1_Short := (sl_tp_mode == "USD") ? entryShortPrice - (tp1_value * get_pip_size()) : entryShortPrice * (1 - (tp1_value * 0.01))

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
        final_TP2_Long  := (sl_tp_mode == "USD") ? entryLongPrice  + (tp2_value * get_pip_size()) : entryLongPrice * (1 + (tp2_value * 0.01))
    else if signal_bear
        final_TP2_Short := (sl_tp_mode == "USD") ? entryShortPrice - (tp2_value * get_pip_size()) : entryShortPrice * (1 - (tp2_value * 0.01))

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
// #                   |   Sessions  |
// # ========================================================================= #

// Session calculations
// The BarInSession function returns true when
// the current bar is inside the session parameter
BarInSession(sess) =>
    time(timeframe.period, sess, sess_timezone) != 0

in_session = BarInSession(Session)
okToTradeInSession = use_session ? in_session : true
new_session = in_session and not in_session[1]

bgcolor(color=use_session and BarInSession(Session)[1] ? color.new(color.green, 85) : na, title='Trading Session')

// # ========================================================================= #
// #                   |   TradingViewTO Alerts Message  |
// # ========================================================================= #

string entry_long_limit_alert_message = ""
string entry_long_TP1_alert_message = ""
string entry_long_TP2_alert_message = ""

var float tp1_qty_perc = tp1_qty / 100

var string account_command = ""
var string pyr_line_command = ""
var string bull_command = ""
var string bear_command = ""

ignore_pyr_orders    = "check=pos side=[side] iffound=abort\n"

// Executing this only once at the beginning of the strategy
if barstate.isfirst

    // First Line
    account_command := "A=" + tradingviewto_account_ID

    // Spot or Margin
    if trading_mode == "Spot"
        bull_command := "Buy " + syminfo.ticker
        bear_command := "Sell " + syminfo.ticker
    else if trading_mode == "Margin"
        bull_command := "Long " + syminfo.ticker
        bear_command := "Short " + syminfo.ticker

    // Order Type
    if order_type_mode == "Limit"
        bull_command := bull_command + "p=" + str.tostring(order_type_price) + " "
        bear_command := bear_command + "p=-" + str.tostring(order_type_price) + " "
    
    // Quantity
    if pos_type == "Units"
        bull_command := bull_command + "Q=" + str.tostring(pos_size * tp1_qty_perc) + " "
        bear_command := bear_command + "Q=" + str.tostring(pos_size * tp1_qty_perc) + " "
    else if pos_type == "Percent"
        bull_command := bull_command + "Q=" + str.tostring(pos_size * tp1_qty_perc) + "% "
        bear_command := bear_command + "Q=" + str.tostring(pos_size * tp1_qty_perc) + "% "

    // Hedge Mode
    if use_hedge_mode
        bull_command := bull_command + "hedge "
        bear_command := bear_command + "hedge "

    // Leverage
    if use_leverage
        bull_command := bull_command + "L=" + str.tostring(leverage_value) + " "
        bear_command := bear_command + "L=" + str.tostring(leverage_value) + " "

    bull_command := bull_command + "A=" + tradingviewto_account_ID
    bear_command := bear_command + "A=" + tradingviewto_account_ID

if use_tp1 and use_tp2

    entry_long_TP1_alert_message := bull_command + " sl=" + (sl_tp_mode == "USD" ? str.tostring(final_SL_Long, format.mintick) : str.tostring(sl_value) + "% ") 
     + " tp=" + (sl_tp_mode == "USD" ? str.tostring(final_TP1_Long, format.mintick) : str.tostring(tp1_value) + "%")

    entry_long_TP2_alert_message := bull_command + " sl=" + (sl_tp_mode == "USD" ? str.tostring(final_SL_Long, format.mintick) : str.tostring(sl_value) + "% ")
     + " tp=" + (sl_tp_mode == "USD" ? str.tostring(final_TP2_Long, format.mintick) : str.tostring(tp2_value) + "%")

else if use_tp1 and (not use_tp2 or tp1_qty == 100)

    entry_long_TP1_alert_message := bull_command + " sl=" + (sl_tp_mode == "USD" ? str.tostring(final_SL_Long, format.mintick) : str.tostring(sl_value) + "% ")
     + " tp=" + (sl_tp_mode == "USD" ? str.tostring(final_TP1_Long, format.mintick) : str.tostring(tp1_value) + "%")

else if not use_tp1 and use_tp2

    entry_long_TP2_alert_message := bull_command + " sl=" + (sl_tp_mode == "USD" ? str.tostring(final_SL_Long, format.mintick) : str.tostring(sl_value) + "% ")
     + " tp=" + (sl_tp_mode == "USD" ? str.tostring(final_TP2_Long, format.mintick) : str.tostring(tp2_value) + "%")

entry_long_limit_alert_message := entry_long_TP1_alert_message + "\n" + entry_long_TP2_alert_message

//entry_long_limit_alert_message = tradingviewto_account_ID + ",buystop," + syminfo.ticker + ",price=" + str.tostring(buy_price) + ",risk=" + str.tostring(pos_size) + ",tp=" + str.tostring(final_TP_Long) + ",sl=" + str.tostring(final_SL_Long)

//entry_short_market_alert_message = tradingviewto_account_ID + ",sell," + syminfo.ticker + ",risk=" + str.tostring(pos_size) + (use_tp1 ? ",tp=" + str.tostring(final_TP1_Short) : "")
// + (use_sl ? ",sl=" + str.tostring(final_SL_Short) : "")

//entry_short_limit_alert_message = tradingviewto_account_ID + ",sellstop," + syminfo.ticker + ",price=" + str.tostring(sell_price) + ",risk=" + str.tostring(pos_size) + ",tp=" + str.tostring(final_TP_Short) + ",sl=" + str.tostring(final_SL_Short)

string entry_short_limit_alert_message = ""
string entry_short_TP1_alert_message = ""
string entry_short_TP2_alert_message = ""

if use_tp1 and use_tp2
    
    entry_short_TP1_alert_message := bear_command + " sl=" + (sl_tp_mode == "USD" ? str.tostring(final_SL_Short, format.mintick) : str.tostring(sl_value) + "% ")
     + " tp=" + (sl_tp_mode == "USD" ? str.tostring(final_TP1_Short, format.mintick) : str.tostring(tp1_value) + "%")

    entry_short_TP2_alert_message := bear_command + " sl=" + (sl_tp_mode == "USD" ? str.tostring(final_SL_Short, format.mintick) : str.tostring(sl_value) + "% ")
     + " tp=" + (sl_tp_mode == "USD" ? str.tostring(final_TP2_Short, format.mintick) : str.tostring(tp2_value) + "%")

else if use_tp1 and (not use_tp2 or tp1_qty == 100)

    entry_short_TP1_alert_message := bear_command + " sl=" + (sl_tp_mode == "USD" ? str.tostring(final_SL_Short, format.mintick) : str.tostring(sl_value) + "% ")
     + " tp=" + (sl_tp_mode == "USD" ? str.tostring(final_TP1_Short, format.mintick) : str.tostring(tp1_value) + "%")

else if not use_tp1 and use_tp2

    entry_short_TP2_alert_message := bear_command + " sl=" + (sl_tp_mode == "USD" ? str.tostring(final_SL_Short, format.mintick) : str.tostring(sl_value) + "% ")
     + " tp=" + (sl_tp_mode == "USD" ? str.tostring(final_TP2_Short, format.mintick) : str.tostring(tp2_value) + "%")

entry_short_limit_alert_message := entry_short_TP1_alert_message + "\n" + entry_short_TP2_alert_message

cancel_long  = "Cancel " + syminfo.ticker + (use_hedge_mode ? " hedge" : "") + " A=" + tradingviewto_account_ID
cancel_short = "Cancel " + syminfo.ticker + (use_hedge_mode ? " hedge" : "") + " A=" + tradingviewto_account_ID

close_long  = "Close " + syminfo.ticker + " T=" + (trading_mode == "Spot" ? "buy" : "long")   + (use_hedge_mode ? " hedge" : "") + " A=" + tradingviewto_account_ID
close_short = "Close " + syminfo.ticker + " T=" + (trading_mode == "Spot" ? "sell" : "short") + (use_hedge_mode ? " hedge" : "") + " A=" + tradingviewto_account_ID

// Close all positions and orders, and off/halt the PineConnector EA.
halt_ea_message    = "You MUST halt your Bot manually"

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

// Send the message to TradingViewTO if the losing streak is too long
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

okToTrade = okToTradeInSession and TradeDateIsAllowed() and (not HALT_STRATEGY)

// Entries
if bull and strategy.position_size <= 0 and open_long and okToTrade
    
    alert(close_short, alert.freq_once_per_bar_close)
    strategy.entry("Long", strategy.long, limit = order_type_mode == "Limit" ? order_type_price : na, stop = order_type_mode == "Stop" ? order_type_price : na, qty = pos_size * leverage_value)
    alert(entry_long_TP1_alert_message, alert.freq_once_per_bar_close)
    alert(entry_long_TP2_alert_message, alert.freq_once_per_bar_close)

else if bear and strategy.position_size >= 0 and open_short and okToTrade
    
    alert(close_long, alert.freq_once_per_bar_close)
    strategy.entry("Short", strategy.short, limit = order_type_mode == "Limit" ? order_type_price : na, stop = order_type_mode == "Stop" ? order_type_price : na, qty = pos_size * leverage_value)
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

// Closing all trades at the end of the session
if use_session and close_trades_end_session
    strategy.close_all(alert_message = "Closing all trades at the end of the session")
    
// Close all the opened trades if the strategy is halted
if HALT_STRATEGY
    strategy.close_all(alert_message = halt_ea_message)  
    


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
