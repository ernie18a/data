# Channels With NVI Strategy [TradeDots]

- url: https://www.tradingview.com/script/ZPgdScmW-Channels-With-NVI-Strategy-TradeDots/
- type: strategy
- pine_id: PUB;91958c65f6484c028ac2d2192a021093
- version: 2.0

## Description

The "Channels With NVI Strategy" is a trading strategy that identifies oversold market instances during a bullish trading market. Specifically, the strategy integrates two principal indicators to deliver profitable opportunities, anticipating potential uptrends.

[b]2 MAIN COMPONENTS[/b]

[b]1. Channel Indicators: [/b]This strategy gives users the flexibility to choose between Bollinger Band Channels or Keltner Channels. This selection can be made straight from the settings, allowing the traders to adjust the tool according to their preferences and strategies.

[b]2. Negative Volume Indicator (NVI):[/b] An indicator that calculates today's price rate of change, but only when today's trading volume is less than the previous day's. This functionality enables users to detect potential shifts in the trading volume with time and price.

[b]ENTRY CONDITION[/b]

First, the assets price must drop below the lower band of the channel indicator. 
Second, NVI must ascend above the exponential moving average line, signifying a possible flood of 'smart money' (large institutional investors or savvy traders), indicating an imminent price rally.

[b]EXIT CONDITION[/b]

Exit conditions can be customized based on individual trading styles and risk tolerance levels. Traders can define their ideal take profit or stop loss percentages.

Moreover, the strategy also employs an NVI-based exit policy. Specifically, if the NVI dips under the exponential moving average – suggestive of a fading trading momentum, the strategy grants an exit call.

[b]RISK DISCLAIMER [/b]

Trading entails substantial risk, and most day traders incur losses. All content, tools, scripts, articles, and education provided by TradeDots serve purely informational and educational purposes. Past performances are not definitive predictors of future results.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tradedots

//@version=5
strategy("Channels With NVI Strategy [TradeDots]", overlay=true, initial_capital = 10000, default_qty_type = strategy.percent_of_equity, default_qty_value = 60, pyramiding = 1, commission_type = strategy.commission.percent, commission_value = 0.01)

// define variable
bool stop_loss = false
bool take_profit = false

// get channel type
channel_type = input.string("BB", "", inline="CHANNEL", options=["BB", "KC"],group="STRATEGY")
channel_source = input(close, "", inline="CHANNEL", group="STRATEGY")
channel_length = input.int(20, "", inline="CHANNEL", minval=1,group="STRATEGY")
channel_mult = input.int(2, "", inline="CHANNEL", minval=1,group="STRATEGY")
channel_color = input(#9cff87, "", inline="CHANNEL",group="STRATEGY")

[middle, upper, lower] = if channel_type == "KC"
    ta.kc(channel_source, channel_length,channel_mult)
else 
    ta.bb(channel_source, channel_length,channel_mult)

// plot channel bands
plot(upper, color = channel_color, title = "Upper Channel Line")
plot(lower, color = channel_color, title = "Lower Channel Line")

// set nvi length
input_ema_nvi_length = input.int(200, minval=1, title = "NVI Legnth: ", group = "STRATEGY")
ema_nvi = ta.ema(ta.nvi, input_ema_nvi_length)

// stop loss and take profit options
enable_stop_loss = input.bool(defval = false, title = "", inline = "SL", group = "SL AND TP")
input_stop_loss = input.float(defval = 0, step = 0.1, title = "Stop Loss (%)", inline = "SL", group = "SL AND TP")

enable_take_profit = input.bool(defval = false, title = "", inline = "TP", group = "SL AND TP")
input_take_profit = input.float(defval = 0, step = 0.1, title = "Take Profit (%)", inline = "TP", group = "SL AND TP")

// entry rand exit condition
longCondition = close < lower and ta.nvi > ema_nvi
closeLongCondition = ta.nvi < ema_nvi

// assign stop loss and take profit
stop_loss := strategy.position_avg_price * (1-input_stop_loss/100) > close and enable_stop_loss == true ? true : na
take_profit := strategy.position_avg_price * (1+input_take_profit/100) < close and enable_take_profit == true ? true : na

// run strategy
if barstate.isconfirmed
    if (longCondition) and strategy.opentrades == 0
        strategy.entry("Long", strategy.long)
        label.new(bar_index, low, "🟢 Long", color = #9cff87, style = label.style_label_up)
    
    if (closeLongCondition == true or (take_profit == true and enable_take_profit == true) or (stop_loss == true and enable_stop_loss == true)) and strategy.opentrades > 0
        strategy.close("Long")
        label.new(bar_index, high, "🔴 Close", color = #f9396a, style = label.style_label_down, textcolor = #ffffff)
````
