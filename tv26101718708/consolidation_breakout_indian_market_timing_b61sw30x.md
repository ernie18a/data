# Consolidation Breakout [Indian Market Timing]

- url: https://www.tradingview.com/script/b61Sw30x-Consolidation-Breakout-Indian-Market-Timing/
- type: strategy
- pine_id: PUB;41d38b2f4547498097b55b133e5f0e5c
- version: 1.0

## Description

OK let's get started ,

A Day Trading (Intraday) Consolidation Breakout Indication Strategy that explains time condition for Indian Markets .
The commission is also included in the strategy .
The basic idea is ,

1) Price crosses above upper band , indicated by a color change (green) is the Long condition .
2) Price crosses below lower band , indicated by a color change (red) is the Short condition .
3) ATR is used for trailing after entry

// ═══════════════════════════════//
// ————————> TIME CONDITION <————————— //
// ═══════════════════════════════//
The Indian Markets open at 9:15am and closes at 3:30pm.
The time_condition specifies the time at which Entries should happen .
"Close All" function closes all the trades at 2:57pm.
All open trades get closed at 2:57pm , because some brokers dont allow you to place fresh intraday orders after 3pm.
[symbol="NSE:NIFTY1!"]NSE:NIFTY1![/symbol]

// ═══════════════════════════════════════════════ //
// ————————> BACKTEST RESULTS  ( 114 CLOSED TRADES )<————————— //
// ═══════════════════════════════════════════════ //
LENGTH , MULT (factor) and ATR can be changed for better backtest results.
The strategy applied to NIFTY (3 min Time-Frame and contract size 5) gives us 60% profitability , as shown below
It was tested for a period a 8 months with a Profit Factor of 2.2 , avg Trade of 6000Rs profit and Sharpe Ratio : 0.67
The graph has a Linear Curve with consistent profits.
[symbol="NSE:NIFTY1!"]NSE:NIFTY1![/symbol]

Save it favorites.
Apply it to your charts Now !!
Thank me later ;)

## Source Code

````pine
//@version=5
strategy("Consolidation Breakout [Indian Market Timing]",overlay = true , pyramiding = 0 ,initial_capital = 50000, default_qty_value=5, currency = currency.NONE,commission_type = strategy.cash, commission_value = 30, slippage = 1 )


// ══════════════════════════════════//
// ————————> INPUT VALUES <————————— //
// ══════════════════════════════════//

LENGTH = input.int(title='LENGTH', defval = 75, minval = 10 ,maxval = 300)
MULT = input.float(title='MULT_STDEV',defval = 3.2 , minval = 1 , maxval = 7 , step =0.1)

//EMA1 = input.int(title='EMA1', defval = 50, minval = 10 ,maxval = 550)
//EMA2 = input.int(title='EMA2', defval = 135, minval = 10 ,maxval = 550)
factor_tr = input.float(title = "ATR TRAIL", defval = 10, step = 0.1)

// ══════════════════════════════════//
// ————————> DAY TIME LIMIT <——————— //
// ══════════════════════════════════//

t = time(timeframe.period, '0935-1430:1234567')
time_condition = not na(t)

//**********************// ════════════════════════════════//
//**********************// ————————> ATR & PLOT <————————— //
//**********************// ════════════════════════════════//
//ema1 = ta.ema(close,EMA1)
//ema2 = ta.ema(close,EMA2)

//plot(ema1, color=color.new(color.blue, 0), style=plot.style_linebr, title='ema1')
//plot(ema2, color=color.new(color.yellow, 0), style=plot.style_linebr, title='ema2')

atr_tr = ta.atr(16)*factor_tr

longStop = close - atr_tr
shortStop = close + atr_tr

Entry = close
length = LENGTH
mult = MULT
basis = ta.sma(Entry , length)
dev = mult * ta.stdev(Entry , length)
upper = (basis + dev)
lower = (basis - dev)
buyEntry = ta.crossover(Entry , upper)
sellEntry = ta.crossunder(Entry , lower)

//plot(upper, color=color.new(color.red, 0), style=plot.style_linebr, title="short stop")
//plot(lower, color=color.new(color.green, 0), style=plot.style_linebr, title="Long stop")

plot(upper, color=close[1] > upper and close > upper ? color.green : color.red, linewidth=2)
plot(lower, color=close[1] > lower and close > lower ? color.green : color.red, linewidth=2)




// ══════════════════════════════════//
// ————————> LONG POSITIONS <————————//
// ══════════════════════════════════//
//******barinstate.isconfirmed used to avoid repaint in real time*******

if ( buyEntry and strategy.opentrades==0 and barstate.isconfirmed and time_condition)
    strategy.entry(id= "Long" ,direction = strategy.long, comment = "B")
    
plot(longStop , color=color.new(color.blue, 0), style=plot.style_linebr, title='long Stop')

if strategy.position_size > 0 
    strategy.exit("long tsl", "Long" , stop = longStop , comment='S')

// ═════════════════════════════════════//
// ————————> SHORT POSITIONS <————————— //
// ═════════════════════════════════════//
if ( sellEntry and strategy.opentrades==0 and barstate.isconfirmed and time_condition)
    strategy.entry(id = "Short" ,direction = strategy.short,  comment = "S") 

if strategy.position_size < 0
    strategy.exit("short tsl", "Short" , stop = shortStop ,comment='B')

// ════════════════════════════════════════════════//
// ————————> CLOSE ALL POSITIONS BY 3PM <————————— //
// ════════════════════════════════════════════════//
strategy.close_all(when = hour == 14 and minute == 57)
````
