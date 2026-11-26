# Leverage Strategy and a few words on risk/opportunity

- url: https://www.tradingview.com/script/vOaKc2FV-Leverage-Strategy-and-a-few-words-on-risk-opportunity/
- type: strategy
- pine_id: PUB;Ez1DFuIzXVyJCIwGde6iv5EtR63C2nJJ
- version: 1.0

## Description

Hello traders,

I started this script as a joke for someone... finally appears it could be used for educational content
Let's talk about leverage and margin call

[b]Margin Call[/b]
A margin call is the broker's demand that an investor deposit additional money or securities so that the account is brought up to the minimum value, known as the maintenance margin. 
A margin call usually means that one or more of the securities held in the margin account has decreased in value below a certain point.

[b]Leverage[/b]
A leverage is a system which allows the trader to open positions much larger than his own capital. ... “Leverage” usually refers to the ratio between the position value and the investment needed,

[b]Strat[/b]

The strategy simulates long/short positions on a 4h high/low breakout based on the chart candle close.
The panel below shows the strategy equity curve. Activating the margin call option will show when the account would be margin called giving the settings

[b]Casino[/b]

I'm not doing any financial recommendation here.

I made this strategy so that people include more risk management metrics into their strategy.
From the code, we see it's fairly easy to calculate a leveraged position size and a margin call flag - when that flag is hit, the system stops trading.
I simplified things to the extreme here but my point is that the leverage is a double-edge sword gift. 
Assuming we always take the same position sizing, increasing the leverage speed up how fast a margin could be ..... called. (bad joke? feel free to tell me). Not saying it will, saying it introduces more risk by design.

Then one could say "I'll just turn off that stupid margin call option". And that's when someone starts backtesting with unrealistic market conditions.

[i]Finally...[/i]

When I backtest I always assume the worst in every scenario possible (because I'm French), I always try to minimize the risk first (also because I'm French), keeping as close from 0 as possible (French again)
Then I add the "opportunity" component, looking to catch the maximum of opportunity while keeping the risk low.
It's like a [url=https://en.wikipedia.org/wiki/Rubik's_Cube]Rubix cube[/url] puzzle - decreasing the risk is one side of the equation but whenever I try to catch more opportunity... my risks increases. 
Then I update my risk... and now the opportunity decreases... (#wut #wen #simple)

Completely removing the risk from a trading strategy isn't something I wouldn't dare doing.

Trading involves risk. Being obsessed by decreasing the risk is what I do BEST :) 

Dave

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=4
//@author=Daveatt

// Breakout on 2H high/low break Strategy

SystemName = "Leverage Strategy"
TradeId = "🙏"

InitCapital             = 100000
InitPosition            = 100
UseMarginCall           = input(true, title="Use Margin Call?")
MarginValue             = input(25000, title="Margin Value", type=input.float)
// use 1 for no leverage
// use 0.1 for be underleveraged and bet 1/10th of a pip value
// use any value > 1 for full-degen mode
UseLeverage             = input(true, title="Use Leverage")
LeverageValue           = input(4, title="Leverage mult (1 for no leverage)", minval=0.1, type=input.float)
// Risk Management
UseRiskManagement       = input(true, title="Use Risk Management?")
// ticks = 1/10th of a pip value
StopLoss                = input(5, title="Stop Loss in ticks value", type=input.float)
TakeProfit              = input(500, title="Take Profit in ticks value", type=input.float)

InitCommission = 0.075
InitPyramidMax = 1
CalcOnorderFills = false
CalcOnTick = true
DefaultQtyType = strategy.cash
DefaultQtyValue = strategy.cash
Currency = currency.USD
Precision = 2
Overlay=false
MaxBarsBack=3000

strategy
 (
 title=SystemName, 
 shorttitle=SystemName, 
 overlay=Overlay, 
 pyramiding=InitPyramidMax, 
 initial_capital=InitCapital, 
 default_qty_type=DefaultQtyType, 
 default_qty_value=InitPosition, 
 commission_type=strategy.commission.percent, 
 commission_value=InitCommission, 
 calc_on_order_fills=CalcOnorderFills, 
 calc_on_every_tick=CalcOnTick, 
 currency = Currency,
 precision=Precision,
 max_bars_back=MaxBarsBack
 )

//////////////////////////// UTILITIES ///////////////////////////

f_print(_txt, _condition) =>

    var _lbl = label(na)
    label.delete(_lbl)

    if _condition
        // saving the candle where we got rekt :(
        _index = barssince(_condition)
        _lbl := label.new(bar_index - _index, highest(100), _txt, xloc.bar_index, yloc.price, size = size.normal, style=label.style_labeldown)

//////////////////////////// STRATEGY LOGIC ///////////////////////////

// Date filterigng
_Date       = input(true, title="[LABEL] DATE")
FromYear = input(2019, "From Year", minval=1900),   FromMonth = input(12, "From Month", minval=1, maxval=12),    FromDay = input(1, "From Day", minval=1, maxval=31)
ToYear = input(2019, "To Year", minval=1900),       ToMonth = input(12, "To Month", minval=1, maxval=12),        ToDay = input(9, "To Day", minval=1, maxval=31)
FromDate = timestamp(FromYear, FromMonth, FromDay, 00, 00)     
ToDate = timestamp(ToYear, ToMonth, ToDay, 23, 59)
TradeDateIsAllowed = (time >= FromDate and time <= ToDate)

// non-repainting security version
four_hours_H     = security(syminfo.tickerid, '240', high[1], lookahead=true)
four_hours_L     = security(syminfo.tickerid, '240', low[1], lookahead=true)
buy_trigger     = crossover(close, four_hours_H)
sell_trigger    = crossunder(close, four_hours_L)

// trend states
since_buy  = barssince(buy_trigger)
since_sell = barssince(sell_trigger)
buy_trend  = since_sell > since_buy
sell_trend = since_sell < since_buy 

change_trend = (buy_trend and sell_trend[1]) or (sell_trend and buy_trend[1])

// plot(four_hours_H, title="4H High",  linewidth=2, color=#3c91c2, style=plot.style_linebr, transp=0,
//  show_last=1, trackprice=true)
// plot(four_hours_L, title="4H Low",  linewidth=2, color=#3c91c2, style=plot.style_linebr, transp=0,
//  show_last=1, trackprice=true)

plot(strategy.equity, color=color.blue, linewidth=3, title="Strategy Equity")

// get the entry price
entry_price = valuewhen(buy_trigger or sell_trigger, close, 0)

// SL and TP

SL_price    = buy_trend ? entry_price - StopLoss    : entry_price + StopLoss
is_SL_hit   = buy_trend ? crossunder(low, SL_price) : crossover(high, SL_price) 

TP_price    = buy_trend ? entry_price + TakeProfit  : entry_price - TakeProfit
is_TP_hit   = buy_trend ? crossover(high, TP_price) : crossunder(low, TP_price)

//  Account Margin Management:
f_account_margin_call_cross(_amount)=>
    _return = crossunder(strategy.equity, _amount)

f_account_margin_call(_amount)=>
    _return = strategy.equity <= _amount

is_margin_call_cross    = f_account_margin_call_cross(MarginValue)
is_margin_call          = f_account_margin_call(MarginValue)

plot(strategy.equity, title='strategy.equity', transp=0, linewidth=4)
//plot(barssince(is_margin_call ), title='barssince(is_margin_call)', transp=100)

can_trade = iff(UseMarginCall, not is_margin_call, true)
trade_size  = InitPosition * (not UseLeverage ? 1 : LeverageValue)

// We can take the trade if not liquidated/margined called/rekt

buy_final   = can_trade and buy_trigger and TradeDateIsAllowed
sell_final  = can_trade and sell_trigger and TradeDateIsAllowed

close_long  = buy_trend  and 
 (UseRiskManagement and (is_SL_hit or is_TP_hit)) or sell_trigger

close_short = sell_trend and 
 (UseRiskManagement and (is_SL_hit or is_TP_hit)) or buy_trigger

strategy.entry(TradeId + ' B', long=true, qty=trade_size, when=buy_final)
strategy.entry(TradeId + ' S', long=false, qty=trade_size, when=sell_final)
strategy.close(TradeId + ' B', when=close_long)
strategy.close(TradeId + ' S', when=close_short)

// FULL DEGEN MODE ACTIVATED
// Margin called - Broker closing your account
strategy.close_all(when=is_margin_call)

if UseMarginCall and is_margin_call_cross
    f_print("☠️REKT☠️", is_margin_call_cross)
````
