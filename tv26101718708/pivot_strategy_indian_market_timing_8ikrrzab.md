# PIVOT STRATEGY [INDIAN MARKET TIMING]

- url: https://www.tradingview.com/script/8IKrRZAb-PIVOT-STRATEGY-INDIAN-MARKET-TIMING/
- type: strategy
- pine_id: PUB;ca43a4aa2f084eebbdf2c2be29c23902
- version: 8.0

## Description

[b]A Back-tested Profitable Strategy for Free!![/b]
A PIVOT INTRADAY STRATEGY for 5 minute Time-Frame  , that also explains the time condition for Indian Markets [9:15am - 3:30pm]
The Timing can be changed to fit other markets, [b]scroll down[/b] to "TIME CONDITION" to know more.
The commission is also included in the strategy .

The basic idea is when ,

1) Price crosses above ema1 ,indicated by pivot highest line in [b]green[/b] color .
2) Price crosses below ema1 ,indicated by pivot lowest line in [b]red[/b] color .
3) Candle high crosses above [b]pivot highest[/b], is the Long condition .
4) Candle low crosses below [b]pivot lowest[/b] ,  is the Short condition .
5) Maximum [b]Risk per trade[/b] for the intraday trade can be changed .
6) Default_qty_size is set to 60 contracts , which can be changed under [b]settings → properties → order size[/b].
7) [b]ATR is used for trailing[/b] after entry, as mentioned in the inputs below.

// ═════════════════════════//
// ————————> [b]INPUTS[/b] <————————— //
// ═════════════════════════//
      [b] Leftbars[/b]         —————>     Length of pivot highs and lows
      [b] Rightbars [/b]      —————>     Length of pivot highs and lows
[b]Price Cross Ema[/b]    —————>      Added condition [crossing above/below ema1 for long/short position]
       [b]ATR LONG [/b]     —————>      ATR  stoploss trail for Long positions
       [b]ATR SHORT[/b]     —————>      ATR  stoploss trail for Short positions
           [b] RISK [/b]         —————>      Maximum Risk per trade for the day

The strategy was back-tested on [b]RELIANCE [5 min TF][/b]  ,the input values and the results are[b] mentioned under "BACKTEST RESULTS" below[/b].


// ═════════════════════════ //
// ————————> PROPERTIES<——————— //
// ═════════════════════════ //
Default_qty_size ————> 60 contracts , which can be changed under [b]settings [/b] 
                                                                                                               ↓   
                                                                                                       [b]properties [/b]
                                                                                                                ↓
                                                                                                       [b]order size[/b]

// ═══════════════════════════════//
// ————————> TIME CONDITION <————————— //
// ═══════════════════════════════//
[list]
[*]The [b]time can be changed[/b] in the script , Add it → click on ' { } ' [next to settings] → Pine editor→ making it a copy [right top corner} → Edit the line 25 .
The Indian Markets open at [b]9:15am[/b] and closes at [b]3:30pm[/b].
The 'time_cond' specifies the time at which Entries should happen .
"Close All" function closes all the trades at 3pm, at the open of the next candle.
To [b]change the time to close all trades[/b] , Go to Pine Editor → Edit the line 103 [ Multiples of the TF ,Example Edit to 57 min for 3min Time-Frame ].
All open trades get closed at 3pm , because some brokers don't allow you to place fresh intraday orders after 3pm .
[/list]
[symbol="NSE:RELIANCE"]NSE:RELIANCE[/symbol]

// ═══════════════════════════════════════════════ //
// ————————> BACKTEST RESULTS ( 128 CLOSED TRADES )<————————— //
// ═══════════════════════════════════════════════ //
INPUTS can be changed for better back-test results.
The strategy applied to NIFTY ([i]5 min Time-Frame and contract size 60[/i]) gives us [b]60% profitability[/b]y , as shown below
It was tested for a [b]period a 6 months[/b] with a Profit Factor of 1.45 ,net Profit of 21,500Rs profit .
[b]Sharpe Ratio[/b][b][/b] : 0.311
Sortino Ratio : 0.727
The graph has a [b]Linear Curve with consistent profits[/b].

The INPUTS are as follows,
1)        Leftbars  ————————>  3
2)       Rightbars  ————————>  5
3)   Price Cross Ema ——————> 150
4)       ATR LONG ————————>  2.7
5)       ATR SHORT  ———————>  2.9
6)            RISK  —————————> 2500
7)   Default qty size ——————>   60

[symbol="NSE:RELIANCE"]NSE:RELIANCE[/symbol]

[b]Save it to favorites.
Apply it to your charts Now !!
            ↓
FOLLOW US FOR MORE !
Thank me later ;)[/b]

## Source Code

````pine
//   ____________                _________                      _____________
//  |____________|             ||________|                      ||__________|
//       ||            ____    ||        ||                     ||                    ______ ________    _____ ________
//       ||    |   || ||       ||________|| |   || ||    ||     ||     |   ||   /\\   |   // |______| || ||    |______|
//       ||    |===|| |===     ||__________ |   || ||    ||     ||     |===||  /__\\  |===      ||    ||   \\     ||
//       ||    |   || ||___    ||        || |___|| ||___ ||___  ||     |   || /    \\ |   \\    ||    || ___||    ||
//       ||                    ||________||                     ||__________
//       ||                    ||________|                      ||__________|
  
//@version=5
strategy("PIVOT STRATEGY [5MIN TF]",overlay=true ,commission_type = strategy.cash, commission_value = 30 , slippage = 2, default_qty_value = 60, currency = currency.NONE, pyramiding = 0)
leftbars = input(defval = 10)
rightbars = input(defval = 15)


// ══════════════════════════ //
// —————————> INPUTS <——————— //
// ══════════════════════════ //

EMA1 = input.int(title='PRICE CROSS EMA', defval = 150, minval = 10 ,maxval = 400)
factor1 = input.float(title='_ATR LONG',defval = 3.2 , minval = 1 , maxval = 5 , step = 0.1, tooltip = "ATR TRAIL LONG")
factor2 = input.float(title='_ATR SHORT',defval = 3.2 , minval = 1 , maxval = 5 , step = 0.1, tooltip = "ATR TRAIL SHORT")
risk = input.float(title='RISK',defval = 200 , minval = 1 , maxval = 5000 , step = 50, tooltip = "RISK PER TRADE")

var initialCapital = strategy.equity
t = time(timeframe.period, '0935-1400:1234567')
time_cond = not na(t)

// ══════════════════════════════════ //
// ———————————> EMA DATA <——————————— //
// ══════════════════════════════════ //
ema1 = ta.ema(close, EMA1)

plot(ema1, color=color.new(color.yellow, 0), style=plot.style_linebr, title='ema1')

// ══════════════════════════════════ //
// ————————> TRAIL DATA <———————————— //
// ══════════════════════════════════ //
// *******Calculate LONG TRAIL data*****
ATR_LO = ta.atr(14)*factor1

// *******Calculate SHORT TRAIL data*****
ATR_SH = ta.atr(14)*factor2

longStop = close - ATR_LO
shortStop = close + ATR_SH


// Plot trailing stop
//plot(longStop, color=color.new(color.green, 0), style=plot.style_linebr, title='Long Trailing Stop')
//plot(shortStop , color=color.new(color.red, 0), style=plot.style_linebr, title='Short Trailing Stop')

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════ //
// ————————————————————————————————————————————————————————> PIVOT DATA <———————————————————————————————————————————————————————————————————————————————————————————————————— //
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════ //

ph = ta.pivothigh(close,leftbars, rightbars)
pl = ta.pivotlow(close,leftbars, rightbars)

pvt_condition1 = not na(ph)

upper_price = 0.0
upper_price := pvt_condition1 ? ph : upper_price[1]

pvt_condition2 = not na(pl)

lower_price = 0.0
lower_price := pvt_condition2 ? pl : lower_price[1]

// Signals
long  = ta.crossover(high, upper_price + syminfo.mintick)
short = ta.crossunder(low, lower_price - syminfo.mintick)

plot(upper_price, color= close > ema1  ? color.green : na, style=plot.style_line, title='PH')

plot(lower_price,  color= close <  ema1  ? color.red : na, style=plot.style_line, title='PL')


// ══════════════════════════════════//
// ————————> LONG POSITION <————————//
// ══════════════════════════════════//
//******barinstate.isconfirmed used to avoid repaint in real time*******

if ( long and strategy.opentrades==0 and barstate.isconfirmed and time_cond and close >= ema1 )
    strategy.entry(id= "Long" ,direction = strategy.long, comment = "B")
    
//plot(longStop , color=color.new(color.blue, 0), style=plot.style_linebr, title='long Stop')

if strategy.position_size > 0 
    strategy.exit("long tsl", "Long" , stop = longStop ,comment='S')
 

// ═════════════════════════════════════//
// ————————> SHORT POSITIONS <————————— //
// ═════════════════════════════════════//
if ( short and strategy.opentrades==0 and barstate.isconfirmed and time_cond and close <= ema1 )
    strategy.entry(id = "Short" ,direction = strategy.short,  comment = "S") 

if strategy.position_size < 0
    strategy.exit("short tsl", "Short" ,  stop = shortStop ,comment='B')

// ════════════════════════════════════════════════//
// ————————> CLOSE ALL POSITIONS BY 3PM <————————— //
// ════════════════════════════════════════════════//
strategy.close_all(when = hour == 14 and minute == 55)

// ════════════════════════════════════════//
// ————————> MAX INTRADAY LOSS  <————————— //
// ════════════════════════════════════════//
strategy.risk.max_intraday_loss(type = strategy.cash, value = risk)
````
