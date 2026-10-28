# market slayer

- url: https://www.tradingview.com/script/eJRHVtrW-market-slayer/
- type: strategy
- pine_id: PUB;9d0064bce18041efbf25e5316fe06365
- version: 3.0

## Description

Input Parameters:

Various input parameters allow customization of the strategy, including options to show trend confirmation, specify trend timeframes and values, set SMA lengths, enable take profit and stop loss, and define their respective values.
Calculations:

Simple Moving Averages (SMAs) are calculated based on the specified lengths.
Buy and sell signals are generated based on the crossover and crossunder of the short and long SMAs.
Confirmation Bars:

Functions are defined to determine bullish or bearish confirmation bars based on certain conditions.
These confirmation bars are used to confirm trend direction and generate additional signals.
Plotting:

SMAs are plotted on the chart.
Trend labels and signal markers are plotted based on the calculated conditions.
Trade Signals:

Buy and sell conditions are defined based on the crossover/crossunder of SMAs and confirmation of trend direction.
Strategy entries and exits are executed accordingly.
Take Profit and Stop Loss:

Optional take profit and stop loss functionality is included.
Trades are automatically closed when profit or loss thresholds are reached.
Closing Trades:

Trades are also closed based on changes in trend confirmation bars to ensure alignment with the overall market direction.
Alerts:

Alert conditions are defined for opening and closing trades, providing notifications when certain conditions are met.
Overall, this script aims to provide a systematic approach to trading by combining moving average crossovers with trend confirmation bars, along with options for risk management through take profit and stop loss orders. Users can customize various parameters to adapt the strategy to different market conditions and trading preferences.

The script uses the request.security() function with the lookahead parameter set to barmerge.lookahead_on to access data from a higher timeframe within the Pine Script on TradingView. Let's break down why it's used:

Higher Timeframe Analysis:

By default, Pine Script operates on the timeframe of the chart it's applied to. However, in trading strategies, it's common to incorporate signals or data from higher timeframes to confirm or validate signals generated on lower timeframes. This helps traders to align their trades with the broader market trend.
Trend Confirmation:

In this script, the confirmationTrendTimeframe parameter allows users to specify a higher timeframe for trend confirmation. The request.security() function fetches the data from this higher timeframe and applies the defined conditions to confirm the trend direction.
Lookahead Behavior:

The lookahead parameter set to barmerge.lookahead_on ensures that the script considers the most up-to-date information available on the higher timeframe when making trading decisions on the lower timeframe. This prevents the script from lagging behind or using outdated data, enhancing the accuracy of trend confirmation.
Usage in confirmationTrendBullish and confirmationTrendBearish:

These variables are assigned the values returned by the request.security() function, which represents the bullish or bearish trend confirmation based on the conditions applied to the data from the higher timeframe.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Creativ3mindz

//@version=5
strategy("Stock Radar with fill", overlay=true)

// Input parameters
showConfirmationTrend = input(title='Show Trend', defval=true)
confirmationTrendTimeframe = input.timeframe(title='Main Trend', defval='240')
confirmationTrendValue = input(title='Main Trend Value', defval=2)
showConfirmationBars = input(title='Show Confirmation Bars', defval=true)
topCbarValue = input(title='Top Confirmation Value', defval=60)
short_length = input.int(10, minval=1, title="Short WMA Length")
long_length = input.int(20, minval=1, title="Long WMA Length")
takeProfitEnabled = input(title="Take Profit Enabled", defval=false)
takeProfitValue = input.float(title="Take Profit (points)", defval=20, minval=0)
stopLossEnabled = input(title="Stop Loss Enabled", defval=false)
stopLossValue = input.float(title="Stop Loss (points)", defval=50, minval=0)


// Calculate WMAs
short_wma = ta.wma(close, short_length)
long_wma = ta.wma(close, long_length)

// Generate buy and sell signals based on WMAs
buy_signal = ta.crossover(short_wma, long_wma)
sell_signal = ta.crossunder(short_wma, long_wma)

// Plot WMAs
plot(short_wma, color=color.rgb(24, 170, 11), title="Short WMA")
plot(long_wma, color=color.red, title="Long WMA")

// Confirmation Bars
f_confirmationBarBullish(cbValue) =>
    cBarClose = close
    slowConfirmationBarSmaHigh = ta.wma(high, cbValue)
    slowConfirmationBarSmaLow = ta.wma(low, cbValue)
    slowConfirmationBarHlv = int(na)
    slowConfirmationBarHlv := cBarClose > slowConfirmationBarSmaHigh ? 1 : cBarClose < slowConfirmationBarSmaLow ? -1 : slowConfirmationBarHlv[1]
    slowConfirmationBarSslDown = slowConfirmationBarHlv < 0 ? slowConfirmationBarSmaHigh : slowConfirmationBarSmaLow
    slowConfirmationBarSslUp = slowConfirmationBarHlv < 0 ? slowConfirmationBarSmaLow : slowConfirmationBarSmaHigh
    slowConfirmationBarSslUp > slowConfirmationBarSslDown

fastConfirmationBarBullish = f_confirmationBarBullish(topCbarValue)
fastConfirmationBarBearish = not fastConfirmationBarBullish
fastConfirmationBarClr = fastConfirmationBarBullish ? color.green : color.red

fastConfirmationChangeBullish = fastConfirmationBarBullish and fastConfirmationBarBearish[1]
fastConfirmationChangeBearish = fastConfirmationBarBearish and fastConfirmationBarBullish[1]

// Confirmation trend
f_secureSecurity(_symbol, _res, _src) => request.security(_symbol, _res, _src[1], lookahead = barmerge.lookahead_on)

confirmationTrendBullish = f_secureSecurity(syminfo.tickerid, confirmationTrendTimeframe, f_confirmationBarBullish(confirmationTrendValue))
confirmationTrendBearish = not confirmationTrendBullish
confirmationTrendClr = confirmationTrendBullish ? color.green : color.red

// Plot trend labels
plotshape(showConfirmationTrend, style=shape.square, location=location.top, color=confirmationTrendClr, title='Trend Confirmation Bars')
plotshape(showConfirmationBars and (fastConfirmationChangeBullish or fastConfirmationChangeBearish), style=shape.triangleup, location=location.top, color=fastConfirmationChangeBullish ? color.green : color.red, title='Fast Confirmation Bars')
plotshape(showConfirmationBars and buy_signal and confirmationTrendBullish, style=shape.triangleup, location=location.top, color=color.green, title='Buy Signal')
plotshape(showConfirmationBars and sell_signal and confirmationTrendBearish, style=shape.triangledown, location=location.top, color=color.red, title='Sell Signal')

// Generate trade signals
buy_condition = buy_signal and confirmationTrendBullish and not (strategy.opentrades > 0)
sell_condition = sell_signal and confirmationTrendBearish and not (strategy.opentrades > 0)

// Entry conditions for take profit and stop-loss
strategy.entry("Buy", strategy.long, when=buy_condition, comment ="BUY CALLS")
strategy.entry("Sell", strategy.short, when=sell_condition, comment ="BUY PUTS")

// Take Profit and Stop Loss
tpLong = strategy.position_avg_price + takeProfitValue
slLong = strategy.position_avg_price - stopLossValue
tpShort = strategy.position_avg_price - takeProfitValue
slShort = strategy.position_avg_price + stopLossValue

// Plot take profit and stop-loss levels for each trade
l1 = plot(strategy.position_size > 0 ? tpLong : na, "TP Long", color.rgb(0,255,0,0), style = plot.style_linebr)
l2 = plot(strategy.position_size > 0 ? slLong : na, "SL Long", color.rgb(255,0,0,0), style = plot.style_linebr)
l3 = plot(strategy.position_size > 0 ? strategy.position_avg_price : na, "Entry Long", color.white, style = plot.style_linebr)
fill(l3,l2, color = color.rgb(255,0,0,90), title = "Background SL Long")
fill(l3,l1, color = color.rgb(0,255,0,90), title = "Background TP Long")

s1 = plot(strategy.position_size < 0 ? tpShort : na, "TP Short", color.rgb(0, 255,0,0), style = plot.style_linebr)
s2 = plot(strategy.position_size < 0 ? slShort : na, "SL Short", color.rgb(255,0,0,0), style = plot.style_linebr)
s3 = plot(strategy.position_size < 0 ? strategy.position_avg_price : na, "Entry Short", color.white, style = plot.style_linebr)
fill(s3,s2, color = color.rgb(255,0,0,90), title = "Background SL Short")
fill(s3,s1, color = color.rgb(0,255,0,90), title = "Background TP Short")

// Close trades based on trend confirmation bars
if strategy.opentrades > 0
    if strategy.position_size > 0
        if not confirmationTrendBullish
            strategy.close("Buy", comment ="CLOSE CALLS")
    else
        if not confirmationTrendBearish
            strategy.close("Sell", comment ="CLOSE PUTS")

// Define alert conditions as booleans
buy_open_alert = buy_condition
sell_open_alert = sell_condition
buy_closed_alert = strategy.opentrades < 0
sell_closed_alert = strategy.opentrades > 0

// Alert conditions
buy_close_alert_condition = strategy.position_size > 0 and buy_closed_alert
sell_close_alert_condition = strategy.position_size < 0 and sell_closed_alert

// Alerts
alertcondition(buy_open_alert, title='Buy trade opened', message='{"username": "TradingView Alert", "content": "{{strategy.order.comment}} {{ticker}} {{strategy.order.price}}"}')
alertcondition(sell_open_alert, title='Sell trade opened', message='{"username": "TradingView Alert", "content": "{{strategy.order.comment}} {{ticker}} {{strategy.order.price}}"}')
alertcondition(buy_closed_alert, title='Buy trade closed', message='{"username": "TradingView Alert", "content": "{{strategy.order.comment}} {{ticker}} {{strategy.order.price}}"}')
alertcondition(sell_closed_alert, title='Sell trade closed', message='{"username": "TradingView Alert", "content": "{{strategy.order.comment}} {{ticker}} {{strategy.order.price}}"}')
````
