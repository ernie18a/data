# SUPPORT RESISTANCE STRATEGY [5MIN TF]

- url: https://www.tradingview.com/script/KOfsPM9h-SUPPORT-RESISTANCE-STRATEGY-5MIN-TF/
- type: strategy
- pine_id: PUB;c5551799ee7e4698a6ed53d8c5a995c9
- version: 1.0

## Description

A SUPPORT RESISTANCE BREAKOUT STRATEGY for [b]5 minute Time-Frame[/b] , that has the time condition for Indian Markets
The [b]Timing can be changed[/b][i][/i] to fit other markets, [b]scroll down[/b] to "TIME CONDITION" to know more.
The commission is also included in the strategy .

The basic idea is when ,

1) Price crosses above [b]Resistance[/b] Level ,indicated by Red Line, is a Long condition.
2) Price crosses below [b]Support[/b] Level ,indicated by Green Line , is a Short condition.
3) Candle high crosses above ema1, is a part of the [b]Long[/b] condition .
4) Candle low crosses below ema1, is a part of the [b]Short[/b] condition .
5) Volume Threshold is an added confirmation for long/short positions.
6) Maximum Risk per trade for the intraday trade can be changed .
7) Default qty size is set to[b] 50 contracts[/b] , which can be changed under settings → properties → order size.
8) ATR is used for trailing after entry, as mentioned in the inputs below.


// ═════════════════════════//
// ————————> INPUTS <————————— //
// ═════════════════════════//

→ L_Bars ———————————> Length of Resistance / Support Levels.
→ R_Bars ———————————> Length of Resistance / Support Levels.
→ Volume Break ———————> Volume Breakout from range to confirm Long/Short position.
→ Price Cross Ema —————> Added condition as explained above (3) and (4).
→ ATR LONG —————————> ATR stoploss trail for Long positions.
→ ATR SHORT ————————> ATR stoploss trail for Short positions.
→ RISK ————————————> Maximum Risk per trade intraday.

The strategy was back-tested on TCS ,the input values and the results are[b] mentioned under "BACKTEST RESULTS" below.[/b]


// ═════════════════════════ //
// ————————> PROPERTIES<——————— //
// ═════════════════════════ //

Default_qty_size ————>[b] 50 contracts[/b] , which can be changed under
[b]
Settings
↓
Properties
↓
Order size
[/b]
// ═══════════════════════════════//
// ————————> TIME CONDITION <————————— //
// ═══════════════════════════════//
[list]
[*]The time can be changed in the script , Add it → click on ' { } ' → Pine editor→ making it a copy [right top corner} → Edit the line 27.
The Indian Markets open at [b]9:15am and closes at 3:30pm.[/b]
The 'time_cond' specifies the time at which Entries should happen .
"Close All" function closes all the trades at 3pm , at the open of the next candle.
To change the time to close all trades , Go to Pine Editor → Edit the line 92 .
All open trades get closed at 3pm , because some brokers don't allow you to place fresh intraday orders after 3pm .

[/list][b][/b]
// ═══════════════════════════════════════════════ //
// ————————> BACKTEST RESULTS ( 100 CLOSED TRADES )<————————— //
// ═══════════════════════════════════════════════ //
INPUTS can be changed for better Back-Test results.
The strategy applied to [symbol="NSE:TCS"]NSE:TCS[/symbol]([b]5 min Time-Frame[/b] and contract size 50) gives us [b]60% profitability[/b] , as shown below
It was tested for a period a [b]6 months[/b] with a Profit Factor of 1.8 ,net Profit of 30,000 Rs profit .
[b]Sharpe Ratio : 0.49
Sortino Ratio : 1.4[/b]
The graph has a Linear Curve with Consistent Profits.

The INPUTS are as follows,
1) L_Bars —————————> 4
2) R_Bars —————————> 4
3) Volume Break ————> 5
4) Price Cross Ema ——> 100
5) ATR LONG ——————> 2.4
6) ATR SHORT —————> 2.6
7) RISK —————————> 2000
8) Default qty size ——> 50
[symbol="NSE:TCS"]NSE:TCS[/symbol]

[b]Save it to favorites.
Apply it to your charts Now !!

Thank You ☺[/b][symbol="NSE:TCS"]NSE:TCS[/symbol]

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
strategy("SUPPORT RESISTANCE STRATEGY [5MIN TF]",overlay=true ,commission_type = strategy.cash, commission_value = 30 , slippage = 2, default_qty_value = 40, currency = currency.NONE, pyramiding = 0)
L_Bars = input.int(defval = 10, minval = 1 , maxval = 50, step =1)
R_Bars = input.int(defval = 15, minval = 1 , maxval = 50, step =1)
volumeRange = input.int(20, title='Volume Break [threshold]', minval = 1)

// ═══════════════════════════ //
// ——————————> INPUT <——————— //
// ═══════════════════════════ //

EMA1 = input.int(title='PRICE CROSS EMA', defval = 150, minval = 10 ,maxval = 400)
factor1 = input.float(title='_ATR LONG',defval = 3.2 , minval = 1 , maxval = 5 , step = 0.1, tooltip = "ATR TRAIL LONG")
factor2 = input.float(title='_ATR SHORT',defval = 3.2 , minval = 1 , maxval = 5 , step = 0.1, tooltip = "ATR TRAIL SHORT")
risk = input.float(title='RISK',defval = 200 , minval = 1 , maxval = 5000 , step = 50, tooltip = "RISK PER TRADE")


var initialCapital = strategy.equity
t = time(timeframe.period, '0915-1445:1234567')
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

long_trail = close - ATR_LO
short_trail = close + ATR_SH

// Plot atr data
//plot(longStop, color=color.new(color.green, 0), style=plot.style_linebr, title='Long Trailing Stop')
//plot(shortStop , color=color.new(color.red, 0), style=plot.style_linebr, title='Short Trailing Stop')

// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════ //
// ————————————————————————————————————————————————————————> RESISTANCE/SUPPORT LEVELS DATA <————————————————————————————————————————————————————————————————————————————————————————————— //
// ══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════ //

Resistance_pi = fixnan(ta.pivothigh(L_Bars, R_Bars)[1])
Support_pi = fixnan(ta.pivotlow(L_Bars, R_Bars)[1])
r1 = plot(Resistance_pi, color=ta.change(Resistance_pi) ? na : color.red,  offset=-(R_Bars + 1),linewidth=2, title='RESISTANCE')
s1 = plot(Support_pi, color=ta.change(Support_pi) ? na : color.green, offset=-(R_Bars + 1),linewidth=2, title='SUPPORT')

//Volume 
vol_1 = ta.ema(volume, 5)
vol_2 = ta.ema(volume, 10)
osc_vol = 100 * (vol_1 - vol_2) / vol_2

// ══════════════════════════════════//
// ————————> LONG POSITIONS <————————//
// ══════════════════════════════════//
//******barinstate.isconfirmed used to avoid repaint in real time*******

if ( ta.crossover(close, Resistance_pi) and osc_vol > volumeRange and not(open - low > close - open) and strategy.opentrades==0 and barstate.isconfirmed and time_cond and close >= ema1 )
    strategy.entry(id= "Long" ,direction = strategy.long, comment = "BUY")
    
plot(long_trail , color=color.new(color.blue, 0), style=plot.style_linebr, title='long Stop')

if strategy.position_size > 0 
    strategy.exit("long tsl", "Long" , stop = long_trail ,comment='SELL')
 
// ═════════════════════════════════════//
// ————————> SHORT POSITIONS <————————— //
// ═════════════════════════════════════//
if ( ta.crossunder(close, Support_pi) and osc_vol > volumeRange and not(open - close < high - open)  and strategy.opentrades==0 and barstate.isconfirmed and time_cond and close <= ema1 )
    strategy.entry(id = "Short" ,direction = strategy.short,  comment = "SELL") 

if strategy.position_size < 0
    strategy.exit("short tsl", "Short" ,  stop = short_trail ,comment='BUY')

// ════════════════════════════════════════════════//
// ————————> CLOSE ALL POSITIONS BY 3PM <————————— //
// ════════════════════════════════════════════════//
strategy.close_all(when = hour == 14 and minute == 55)

// ════════════════════════════════════════//
// ————————> MAX INTRADAY LOSS  <————————— //
// ════════════════════════════════════════//
strategy.risk.max_intraday_loss(type = strategy.cash, value = risk)
````
