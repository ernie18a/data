# Trailing Sell

- url: https://www.tradingview.com/script/4ITU0noW-Trailing-Sell/
- type: strategy
- pine_id: PUB;bb0b20fa1c934d1dab0d49b6b5a53840
- version: 16.0

## Description

This script demonstrates how to do trailing sell. With this approach, given an exit signal, instead of selling directly, you just follow the price upwards (for long positions) and you sell when the price decreases by a small percentage. The order will be executed when the next bar is closed. This approach may increase the profits (slightly) in some strategies! This script can be used as a template for your own strategy. Be aware that the simulated data may produce unrealistic results.

## Source Code

````pine
//@version=6
//#region PREAMBLE 
// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
//  Copyright © 2022-present Iason Nikolas | jason5480
//  The "Trailing Exit" script (aka "Trailing Sell") may be freely distributed under the MIT license.
//  
//  Permission is hereby granted, free of charge,
//  to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//  is furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in ALL COPIES or substantial portions of
//  the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//  OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//  
//  Description
//  --------------------------------------------------------------------------------------------------------------------
//  This strategy will go long if fast MA crosses over slow MA.
//  If the order type is limit and the mode is trail then the strategy instead of exiting
//  from the position directly it will follow the high price upwards (percentagewise)
//  If the price raises by this percentage then the exit order will be executed.
//  If the order type is stop and the mode is trail then the strategy instead of entering
//  into the position directly it will follow the low price downwards (percentagewise)
//  If the price drops by this percentage then the exit order will be executed.
//  
//  --------------------------------------------------------------------------------------------------------------------
//  Disclaimer:
//    1. I am not licensed financial advisors or broker-dealer. I do not tell you when or what to buy or sell.
//       I developed this software which enables you execute manual or automated trades using TradingView.
//       The software allows you to set the criteria you want for entering and exiting trades.
//    2. Do not trade with money you cannot afford to lose.
//    3. I do not guarantee consistent profits or that anyone can make money with no effort.
//       And I am not selling the holy grail.
//    4. Every system can have winning and losing streaks.
//    5. Money management plays a large role in the results of your trading. For example: lot size, account size,
//       broker leverage, and broker margin call rules all affect on results. Also, your Take Profit and Stop Loss
//       settings for individual pair trades and for overall account equity have a major impact on results.
//       If you are new to trading and do not understand these items, then I recommend you seek educational materials
//       to further your knowledge.
//    
//  YOU NEED TO FIND AND USE THE TRADING SYSTEM THAT WORKS BEST FOR YOU AND YOUR TRADING TOLERANCE.
//  I HAVE PROVIDED NOTHING MORE THAN A TOOL WITH OPTIONS FOR YOU TO TRADE WITH THIS PROGRAM ON TRADINGVIEW.
//  
//  I accept suggestions to improve the script.
//  If you encounter any problems I will be happy to share with me.
//  --------------------------------------------------------------------------------------------------------------------
//#endregion ===========================================================================================================
//#region SETUP
// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

strategy(title = 'Trailing Exit',
         shorttitle = 'TEx',
         overlay = true,
         pyramiding = 0,
         default_qty_type = strategy.percent_of_equity,
         default_qty_value = 100,
         initial_capital = 100000,
         max_labels_count = 150)

//#endregion ===========================================================================================================
//#region FILTERS
// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

import jason5480/chrono_utils/7 as chr

// INPUT ===============================================================================================================
var dateTimeWindow = chr.DateTimeWindow.new().init(
  fromDateTime = input.bool(defval = false, title = 'From     ', inline = 'From Date', group = 'Filters', display = display.data_window) ? input.time(defval = timestamp('01 Jan 2023 00:00'), title = '​', inline = 'From Date', group = 'Filters', display = display.data_window) : na,
  toDateTime = input.bool(defval = false, title = 'To       ', inline = 'To Date', group = 'Filters', display = display.data_window) ? input.time(defval = timestamp('01 Jan 2024 00:00'), title = '​​', inline = 'To Date', group = 'Filters', display = display.data_window) : na,
  refTimezone = chr.exTimezone(input.enum(defval = chr.Timezone.Exchange, title = 'Timezones Ref->Chart', inline = 'Timezone', group = 'Filters', display = display.data_window)),
  chTimezone = chr.exTimezone(input.enum(defval = chr.Timezone.Exchange, title = '->', tooltip = 'The Timezone Ref is the reference timezone that is used for the "From" and "To" datetime window settings. The Timezone Chart is the timezone to convert into. WARNING! The chart timezone setting should always match with the actual chart timezone on the bottom right corner of your chart.', inline = 'Timezone', group = 'Filters', display = display.data_window)))

// LOGIC ===============================================================================================================
bool dateFilterApproval = dateTimeWindow.is_bar_included()

// PLOT ================================================================================================================
bgcolor(color = dateFilterApproval ? na : color.new(#FF0000, 95), offset = 1, title = 'Filter')

//#endregion ===========================================================================================================
//#region STRATEGY
// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

// INPUT ===============================================================================================================
fastMALen = input.int(defval = 21, title = 'Fast/Slow SMA Length', minval = 1, inline = 'MA Length', group = 'Strategy')
slowMALen = input.int(defval = 49, title = '', minval = 1, tooltip = 'How many candles back to calculte the fast/slow SMA.', inline = 'MA Length', group = 'Strategy')

// LOGIC ===============================================================================================================
float fastMA = ta.sma(close, fastMALen)
float slowMA = ta.sma(close, slowMALen)

bool openLongPosition = ta.crossover(fastMA, slowMA) and dateFilterApproval 
bool closeLongPosition = ta.crossunder(fastMA, slowMA)

// PLOT ================================================================================================================
plot(series = fastMA, title = 'Fast SMA', color = color.yellow, linewidth = 1, style = plot.style_line)
plot(series = slowMA, title = 'Slow SMA', color = color.orange, linewidth = 1, style = plot.style_line)

//#endregion ===========================================================================================================
//#region EXIT
// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

// INPUT ===============================================================================================================

enum OrderType
    market = 'MARKET'
    limit = 'LIMIT'
    stop = 'STOP'

enum LimitMode
    fixed = 'FIXED'
    trail = 'TRAIL'

exitOrderType = input.enum(defval = OrderType.stop, title = 'Order Type', tooltip = 'Use market order to exit at the open of the next bar (MARKET), or use limit order to exit at a "better" price defined by the distance from the close price and the limit mode (LIMIT), or use stop market order to exit at a "worst" price defined by the distance from the close price and the limit mode (STOP). Limit and stop orders last until they are filled or canceled.', group = 'Exit')
exitLimitMode = input.enum(defval = LimitMode.trail, title = 'Limit Mode', tooltip = 'When you use limit or stop orders to exit, use a fixed price defined by the distance and the close price when the open signal s (FIXED), or trail by following the price to the direction of the exit for limit orders or the other direction of the exit for stop orders (TRAIL).', group = 'Exit')
exitDistPerc = input.float(defval = 3.0, title = '  Distance %', minval = 0.01, maxval = 100, step = 0.05, tooltip = 'The distance as a percentage of the close price when the close signal occured and the distance to keep from the high/low price when trailing.', group = 'Exit') / 100

// LOGIC ===============================================================================================================
int barsSinceOpenLong = nz(ta.barssince(openLongPosition), 999999)
int barsSinceCloseLong = nz(ta.barssince(closeLongPosition), 999999)
int barsSinceExitLong = nz(ta.barssince(strategy.opentrades.size(strategy.opentrades - 1) <= 0 and strategy.opentrades.size(strategy.opentrades - 1)[1] > 0), 999999)
bool closeLongIsActive = barsSinceOpenLong > barsSinceCloseLong // open -> close
bool exitLongIsPending = barsSinceExitLong > barsSinceCloseLong // exit -> close

// The close signal when already into a long position
bool validCloseLongPosition = closeLongPosition and strategy.opentrades.size(strategy.opentrades - 1) > 0

var float longLimitOrStopExitPrice = na
bool isFirstValidCloseLongPosition = exitOrderType != OrderType.market ? validCloseLongPosition and na(longLimitOrStopExitPrice[1]) : false
bool tryExitLongPosition = exitOrderType != OrderType.market ? closeLongIsActive and exitLongIsPending and strategy.opentrades.size(strategy.opentrades - 1) > 0 : false
longLimitOrStopExitPrice := if isFirstValidCloseLongPosition
    if exitOrderType == OrderType.limit
        close * (1 + exitDistPerc)
    else if exitOrderType == OrderType.stop
        close * (1 - exitDistPerc)
else if tryExitLongPosition
    if exitLimitMode == LimitMode.trail or (exitLimitMode == LimitMode.fixed and validCloseLongPosition)
        if exitOrderType == OrderType.limit
            math.min(low * (1 + exitDistPerc), nz(longLimitOrStopExitPrice[1], 999999.9))
        else if exitOrderType == OrderType.stop
            math.max(high * (1 - exitDistPerc), nz(longLimitOrStopExitPrice[1]))
    else
        nz(longLimitOrStopExitPrice[1])
else
    na

// PLOT ================================================================================================================
if validCloseLongPosition
    label.new(x = bar_index, y = na, text = 'Close', yloc = yloc.abovebar, color = #D500F9, style = label.style_label_down, textcolor = color.white)
plot(series = longLimitOrStopExitPrice, title = 'Long Tr Exit Price', color = #D500F9, linewidth = 1, style = plot.style_linebr, offset = 1)

//#endregion ===========================================================================================================
//#region POSITION ORDERS
// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

// LOGIC ===============================================================================================================
// Close on valid close signal when exit with market order
if exitOrderType == OrderType.market and validCloseLongPosition
    strategy.close(id = 'Long Entry', comment = 'Close Long', alert_message = 'Long(' + syminfo.ticker + '): Closed at market price')

// Getting into LONG position
if openLongPosition
    strategy.entry(id = 'Long Entry', direction = strategy.long, alert_message = 'Long(' + syminfo.ticker + '): Started')

// Submit exit order when exit with limit or stop order
if exitOrderType != OrderType.market and tryExitLongPosition
    strategy.exit(id = 'Long Exit', from_entry = 'Long Entry',
      limit = exitOrderType == OrderType.limit ? longLimitOrStopExitPrice : na,
      stop = exitOrderType == OrderType.stop ? longLimitOrStopExitPrice : na,
      comment = 'Exit Long', alert_loss = 'Long(' + syminfo.ticker + '): Exited')

// Cancel existing stop orders (if any) when open signal occurs
if exitOrderType != OrderType.market and openLongPosition
    strategy.cancel(id = 'Long Exit')

// PLOT ================================================================================================================
plot(series = strategy.opentrades.entry_price(strategy.opentrades - 1), title = 'Position', color = color.gray, linewidth = 1, style = plot.style_linebr)

//#endregion ===========================================================================================================
````
