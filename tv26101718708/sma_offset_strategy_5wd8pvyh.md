# SMA Offset Strategy

- url: https://www.tradingview.com/script/5WD8PVYh-SMA-Offset-Strategy/
- type: strategy
- pine_id: PUB;b2e06767ec5b4e3bac28367773a71372
- version: 26.0

## Description

This strategy uses simple moving averages and some math to determine buy/sell points. We keep a SMA 100 day line as our basis for our offset. If the close price is below the line, we choose our open position based on how low below the line it is goes, this value (Low Offset) is a percentage and can be configured by the user. Same for closing your position, when the close is above our SMA 100 line, we determine how high above the line before selling. If we try to sell too early (while the price is still rising), the trailing stop loss will kick in. Backtested with Bitcoin and Ethereum.

Configurable variables:
[list]
[*] SMA Fast (default is 14 days)
[*] SMA Slow (default is 100)
[*] SMA Reference (default is 30)
[*] Low Offset % (default is 0.001)
[*] High Offset % (default is 0.0164)
[*] Order Stake % (default is 0.96)
[*] Trailing stop loss % (default is 1.35)
[/list]

## Source Code

````pine
//@version=5
// Author: Sonny Parlin (highschool dropout)
// Updated 9/14/2021
// Thanks to Paul D. Mendes for his help with properly setting up 
// the stoploss and trailing stoploss code. 
// https://www.udemy.com/user/paul-7512/
// 
strategy(shorttitle='SMA+Strategy', 
     title='SMA Offset Strategy', 
     overlay=true, 
     currency=currency.USD,
     commission_type=strategy.commission.percent, 
     commission_value=0.05,
     slippage=2,
     initial_capital=10000, 
     pyramiding=0)


i_fastMALen = input.int(14, minval=10, maxval=50, title='SMA Fast (days)')
i_slowMALen = input.int(69, minval=40, maxval=200, title='SMA Slow (days)')
i_orderStake = input.float(98, 'Order Stake (%)', minval=0, step=0.01) / 100
i_lowOffset = input.float(1, 'Low Offset (%)', minval=0, step=0.1) / 100
i_takeProfit = input.float(3.1, 'Take Profit (%)', minval=0, step=0.1) / 100
useTakeProfit = input(true, 'Use Take Profit')
i_showPlots = input(true, 'Show plots')

// SMA
smaFast = ta.sma(close, i_fastMALen)
smaSlow = ta.sma(close, i_slowMALen)


// Trailing Stoploss
i_activationPct = input.float(0.9, title='Trailing Stop is activated after price moves x% from Entry', step=0.1) / 100
i_trailOffset = input.int(2000, title='Trailing Stop in ticks (pair specific)', minval=1, step=100)  // You'll have to tweak per pair
var float activationLevel = na  // The price needs to pass this price in order to activate the trailing Stop Loss

var tstop = float(na)
if high >= activationLevel and strategy.opentrades > 0
    tstop := math.max(high - i_trailOffset * syminfo.mintick, nz(tstop[1]))
    tstop
else
    tstop := na
    tstop


// Order size is based on percent of your total equity 98% is the default
orderSize = strategy.equity * i_orderStake / close

// The buy stratey
distanceLow = (smaSlow - close) / smaSlow // get our distanceLow
buyCondition1 = close < smaSlow  // close is lower than our slow moving average
buyCondition2 = ta.rising(smaFast, 2)  // fast moving average is rising for 2 candles
buyCondition3 = distanceLow > i_lowOffset  // our distanceLow is greater than our low offset
orBuyCondition = ta.rising(smaSlow, 1) and smaFast > smaSlow // or buy anytime the slow moving average is rising for 3 candles in a row
enterLong = buyCondition1 and buyCondition2 and buyCondition3 or orBuyCondition or ta.crossover(ta.rsi(close,14),30)

// Stop loss
i_sl = input.float(3.6, title='Stop Loss (%)', step=0.1) / 100
var float entryPrice = na
var float stopLossPrice = na

if enterLong and strategy.opentrades == 0
    entryPrice := close
    stopLossPrice := entryPrice * (1 - i_sl)
    strategy.entry('Open Long Position', strategy.long, orderSize)
    activationLevel := entryPrice + entryPrice * i_activationPct
    strategy.exit('Exit Long Position ', 'Open Long Position', stop=stopLossPrice, trail_price=activationLevel, trail_offset=i_trailOffset)

i_takeProfit := entryPrice * i_takeProfit + entryPrice

// Exit strategies
// Candle crossed above the trailing start line but came back down, we use a 
// "microstop" and sell before the price drops down to our trailing stoploss
// minimizing our loss or possibly earning a small profit. 
i_useMicroStop = input(true, 'Use Micro stop')
if ta.crossunder(low, activationLevel) and i_useMicroStop
    strategy.close('Open Long Position', comment='Micro Stop')

// Take profit
// Sell after our take profit percent is reached.
if high > i_takeProfit and useTakeProfit
    strategy.close('Open Long Position', comment='Take Profit')

// PLOTS
// Set up SMA plot but don't show by default
plot(i_showPlots ? smaFast : na, 'smaFast', color=color.new(#00ff00, 0))
plot(i_showPlots ? smaSlow : na, 'smaSlow', color=color.new(color.orange, 0))

// Stoploss Plot
plot(i_showPlots ? entryPrice : na, title='Entry Price', color=color.new(color.gray, 0), style=plot.style_linebr, linewidth=2)
plot(i_showPlots ? stopLossPrice : na, title='Entry Stoploss Price', color=color.new(color.red, 0), style=plot.style_linebr, linewidth=2)
plot(i_showPlots ? tstop : na, 'Trailing Stop Loss', color=color.new(#ffffff, 0), style=plot.style_linebr, linewidth=2)

// Plot for when the trailing stoploss kicks in
plot(i_showPlots ? activationLevel : na, 'Trailing Stop AL', color=na(tstop) ? color.new(color.yellow, 80) : color.yellow, style=plot.style_linebr)
plot(i_showPlots ? syminfo.mintick * i_trailOffset : na, 'Trailing Stop Offset', color=color.new(#ff00ff, 0), style=plot.style_linebr)
plot(i_showPlots ? distanceLow / 100 : na, 'distanceLow', color=color.new(#ffaaff, 0), style=plot.style_linebr)
plot(i_showPlots ? i_lowOffset / 100 : na, 'i_lowOffset', color=color.new(#ffddff, 0), style=plot.style_linebr)
plot(i_showPlots ? i_takeProfit : na, 'take profit', color=color.new(color.green, 0), style=plot.style_linebr)

// plot(syminfo.mintick, "Min Tick")
````
