# Binary Option Strategy Tester with Martingale-Basic V.2

- url: https://www.tradingview.com/script/7iRLKHim-Binary-Option-Strategy-Tester-with-Martingale-Basic-V-2/
- type: indicator
- pine_id: PUB;15be5b5201044056b4ffb1db9504e0fe
- version: 3.0

## Description

In Binary options, strategy testing is a bit different. The strategy result depends upon expiry intervals and payout ratio.
My previous script was a try to resolve this but has some bugs in specific choices. The new version overcame those and added some new features useful for binary option strategy testing.
[b]Assumption:[/b]
[list]
[*]We are opening position at next candle after signal come
[*]Chart interval is option expiry time.
[*]We are taking the position at opening price
[*]Our call will be profitable if we get a green candle and put will be profitable if we get a red candle
[*]We can open only one trade at a time. So if we are in trade, subsequent signals will be ignored.
[/list]

[b]All Input Options:[/b]
[list]
[*]Test Call/Put individually or both. Default BOTH
[*]Select  up to 5 Martingale levels. Default 2
[*]Type of Martingale Trade. Default “SAME”
[b]“SAME”:[/b]  If you are trading CALL and incur a loss, you are taking CALL in subsequent Martingale levels. 
[b]“OPSITE”:[/b]  if you are trading CALL and incur a loss, you are taking PUT in subsequent Martingale levels. 
[b]“FOLLOW CANDLE COLOR”:[/b]  You are following candle color in Martingale levels, i.e if the loss candle is RED, you are taking PUT in subsequent candles.  
[b]“OPPOSITE CANDLE COLOR”:[/b]  You are taking opposite candle color trade, i.e if the loss candle is RED, you are taking CALL in subsequent candle. 
[*]Select Specific Trading Session. Please select “USE SPECIFIC SESSION”. Default: TRUE
[*]Put the investment amount per option. Default: 10
[*]Payout ratio. Default: 80%
[/list]

The strategy is taken from Vdub Binary Options SniperVX v1 (by @vdubus). I have deleted extra parts and kept only the necessary parts.

[b]Result Table[/b]
[image]https://www.tradingview.com/x/1E2sohVF/[/image]
[b]Signal and Win Levels:[/b]
[image]https://www.tradingview.com/x/k309KYDf/[/image]
[b]Signal and Loss:[/b]
[image]https://www.tradingview.com/x/OrHdTYTG/[/image]

[i][b]Please note that Binary options trading is very risky. You must be aware of the risk and be willing to accept them in order to invest in binary options. Only invest what you can afford to lose. The past performance of any trading system, strategy, or methodology is not necessarily indicative of future results.[/b][/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tanayroy

//@version=5
//The strategy tester works well with Binary option traded in IQ Option or other similar Platform.
indicator("Binary Option Strategy Tester with Martingale-Basic V.2[tanayroy]", shorttitle="BOST V.2",overlay = true)
gp = 'Strategy Information'
i_trade_call_put = input.string('BOTH', title='Trade Call/Put', options=['BOTH', 'CALL', 'PUT'], group=gp)
//input on martingale level
i_martingale_level = input.int(2, title='Martingale Level', minval=1, maxval=5, group=gp)
i_martingle_trade = input.string('SAME', title='Type of Trade', options=['SAME', 'OPPOSITE', 'FOLLOW CANDLE COLOR', 
 'OPPOSITE CANDLE COLOR'], group=gp)
//trading time
i_trading_session = input.session('0100-1000',title='Trading Session', group=gp)
i_use_session = input.bool(true, 'Use Specific Session', group=gp)
initial_investment=input.float(10.0,title="Initial Investment Per Option",minval=1.0,group=gp)
profit_percentage=input.int(80,title='Profit Percentage Offered',group=gp)

//check if in session
InSession() =>
    time(timeframe.period, i_trading_session) != 0

var in_sess=false
in_sess := i_use_session ? InSession() : true
long_allowed = i_trade_call_put == 'BOTH' or i_trade_call_put == 'CALL'
short_allowed = i_trade_call_put == 'BOTH' or i_trade_call_put == 'PUT'

//check martingale way
martingale_way(call, put, type, length) =>
    out = false
    if call and type == 'NA'
        out := close > open[length]
        out
    else if put and type == 'NA'
        out := open[length] > close
        out
    else if type == 'SAME' and call
        out := close > open[length]
        out
    else if type == 'SAME' and put
        out := open[length] > close
        out
    else if type == 'OPPOSITE' and call
        out := open[length] > close
        out
    else if type == 'OPPOSITE' and put
        out := close > open[length]
        out
    else if type == 'FOLLOW CANDLE COLOR'
        out := close[1] > open[1] ? close > open[length] : open[length] > close
        out
    else if type == 'OPPOSITE CANDLE COLOR'
        out := close[1] > open[1] ? close < open[length] : open[length] < close
        out
    out

//variable for strategy testing
var can_buy_call = false
var can_buy_put = false
var in_martingale = false
var in_trade = false
var buy_condition = false
var sell_condition = false
var int count_call = 0
var int count_put = 0
var bool cl1win = na
var bool cl2win = na
var bool cl3win = na
var bool cl4win = na
var bool cl5win = na
var bool closs = na
var int count_cl1win = 0
var int count_cl2win = 0
var int count_cl3win = 0
var int count_cl4win = 0
var int count_cl5win = 0
var int count_closs = 0

var bool pl1win = na
var bool pl2win = na
var bool pl3win = na
var bool pl4win = na
var bool pl5win = na
var bool ploss = na
var int count_pl1win = 0
var int count_pl2win = 0
var int count_pl3win = 0
var int count_pl4win = 0
var int count_pl5win = 0
var int count_ploss = 0
var bool in_profit = false
var bool in_loss = false
var int max_loss = 0
var int consecutive_loss = 0
var int max_profit = 0
var int consecutive_profit = 0

//*****************************************************************************//
//*****************************************************************************//
//********************************PASTE YOUR STRATEGY***************************//
//*****************************************************************************//
//*****************************************************************************//
//Start From Here
//strategy Vdub Binary Options SniperVX v1 by vdubus
len = 8
src = close
out = ta.sma(src, len)
last8h = ta.highest(close, 13)
lastl8 = ta.lowest(close, 13)
bearish = ta.cross(close,out) == 1 and close[1] > close
bullish = ta.cross(close,out) == 1 and close[1] < close
channel2=false
src0 = close, len0 = 13//input(13, minval=1, title="Trend Change EMA")
ema0 = ta.ema(src0, len0)

//--Modified vyacheslav.shindin-------------------------------------------------//           Signal 1
//Configured ema signal output
slow = 8
fast = 5
vh1 = ta.ema(ta.highest(math.avg(low, close), fast), 5)
vl1 = ta.ema(ta.lowest(math.avg(high, close), slow), 8)
//
e_ema1 = ta.ema(close, 1)
e_ema2 = ta.ema(e_ema1, 1)
e_ema3 = ta.ema(e_ema2, 1)
tema = 1 * (e_ema1 - e_ema2) + e_ema3
//
e_e1 = ta.ema(close, 8)
e_e2 = ta.ema(e_e1, 5)
dema = 2 * e_e1 - e_e2
signal = tema > dema ? math.max(vh1, vl1) : math.min(vh1, vl1)


//strategy for buying call
is_call=tema > dema and signal > low and (signal-signal[1] > signal[1]-signal[2])

//strategy fo selling call
is_put=tema < dema and signal < high and (signal[1]-signal > signal[2]-signal[1])


//PASTE END HERE
// is_call and is_put variable is required. assign buy logic in is_call and sell logic in is_put

//****************************YOUR STRATEGY END HERE*************************************//
//****************************KEEP THE REST CODE INTACT*************************************//

if is_call and long_allowed and in_sess
    can_buy_call := true
    can_buy_put := false
  

if is_put and short_allowed and in_sess
    can_buy_call := false
    can_buy_put := true



if can_buy_call and not can_buy_call[1] and not in_trade 
    buy_condition := true
    in_trade := true
    count_call += 1

else if buy_condition[1]
    buy_condition := false
 

if can_buy_put and not can_buy_put[1] and not in_trade 
    sell_condition := true
    in_trade := true
    count_put += 1


else if sell_condition[1]
    sell_condition := false


call_profit = martingale_way(true, false, 'NA', 0)
mart_call_profit = martingale_way(true, false, i_martingle_trade, 0)
put_profit = martingale_way(false, true, 'NA', 0)
mart_put_profit = martingale_way(false, true, i_martingle_trade, 0)


if i_martingale_level == 1
    if buy_condition[1] and not buy_condition and in_trade and call_profit  
     and not sell_condition[1]  and not sell_condition  
        count_cl1win += 1
        in_trade := false
        cl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[1] and not buy_condition and not sell_condition[1]  
     and not sell_condition and in_trade and  not call_profit
        count_closs += 1
        in_trade := false
        closs := true
        in_profit := false
        in_loss := true
        buy_condition := false
        sell_condition := false
        can_buy_call := false
        can_buy_put := false


else if i_martingale_level == 2
    if buy_condition[1] and not buy_condition and in_trade and call_profit 
         and not sell_condition[1] and not sell_condition
        count_cl1win += 1
        in_trade := false
        cl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[2] and not buy_condition[1] and not buy_condition and in_trade and mart_call_profit 
         and not sell_condition[1] and not sell_condition[2] and not sell_condition
        count_cl2win += 1
        in_trade := false
        cl2win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if buy_condition[2] and not buy_condition[1] and not buy_condition and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition and in_trade and not mart_call_profit
        count_closs += 1
        in_trade := false
        closs := true
        in_loss := true
        in_profit := false
        buy_condition := false
        sell_condition := false
        can_buy_call := false
        can_buy_put := false



else if i_martingale_level == 3
    if buy_condition[1] and not buy_condition and in_trade and call_profit and not sell_condition[1] 
         and not sell_condition
        count_cl1win += 1
        in_trade := false
        cl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[2] and not buy_condition[1] and not buy_condition and in_trade 
         and mart_call_profit and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition
        count_cl2win += 1
        in_trade := false
        cl2win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[3] and not buy_condition[2] and not buy_condition[1] and not buy_condition 
         and in_trade and mart_call_profit and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition[3] and not sell_condition
        count_cl3win += 1
        in_trade := false
        cl3win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[3] and not buy_condition[2] and not buy_condition[1] and not buy_condition 
         and not sell_condition[1] and not sell_condition[2] and not sell_condition[3] and not sell_condition 
         and in_trade and not mart_call_profit
        count_closs += 1
        in_trade := false
        closs := true
        in_loss := true
        in_profit := false
        buy_condition := false
        sell_condition := false
        can_buy_call := false
        can_buy_put := false


else if i_martingale_level == 4
    if buy_condition[1] and not buy_condition and in_trade and call_profit and not sell_condition[1] 
         and not sell_condition
        count_cl1win += 1
        in_trade := false
        cl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[2] and not buy_condition[1] and not buy_condition and in_trade and mart_call_profit 
         and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition
        count_cl2win += 1
        in_trade := false
        cl2win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[3] and not buy_condition[2] and not buy_condition[1] and not buy_condition 
         and in_trade and mart_call_profit and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition[3] and not sell_condition
        count_cl3win += 1
        in_trade := false
        cl3win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if buy_condition[4] and not buy_condition[3] and not buy_condition[2] and not buy_condition[1] 
         and not buy_condition and in_trade and mart_call_profit and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition[3] and not sell_condition[4] and not sell_condition
        count_cl4win += 1
        in_trade := false
        cl4win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[4] and not buy_condition[3] and not buy_condition[2] and not buy_condition[1] 
         and not buy_condition and not sell_condition[1] and not sell_condition[2] and not sell_condition[3] 
         and not sell_condition[4] and not sell_condition and in_trade and not mart_call_profit
        count_closs += 1
        in_trade := false
        closs := true
        in_loss := true
        in_profit := false
        buy_condition := false
        sell_condition := false
        can_buy_call := false
        can_buy_put := false




if i_martingale_level == 5
    if buy_condition[1] and not buy_condition and in_trade and call_profit and not sell_condition[1] 
         and not sell_condition
        count_cl1win += 1
        in_trade := false
        cl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[2] and not buy_condition[1] and not buy_condition and in_trade and mart_call_profit 
         and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition
        count_cl2win += 1
        in_trade := false
        cl2win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if buy_condition[3] and not buy_condition[2] and not buy_condition[1] and not buy_condition and in_trade 
         and mart_call_profit and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition[3] and not sell_condition
        count_cl3win += 1
        in_trade := false
        cl3win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if buy_condition[4] and not buy_condition[3] and not buy_condition[2] and not buy_condition[1] 
         and not buy_condition and in_trade and mart_call_profit and not sell_condition[1] 
         and not sell_condition[2] and not sell_condition[3] and not sell_condition[4] and not sell_condition
        count_cl4win += 1
        in_trade := false
        cl4win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if buy_condition[5] and not buy_condition[4] and not buy_condition[3] and not buy_condition[2] 
         and not buy_condition[1] and not buy_condition and not sell_condition[1] and not sell_condition[2] 
         and not sell_condition[3] and not sell_condition[4] and not sell_condition[5] and not sell_condition 
         and in_trade and mart_call_profit
        count_cl5win += 1
        in_trade := false
        cl5win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if buy_condition[5] and not buy_condition[4] and not buy_condition[3] and not buy_condition[2] 
         and not buy_condition[1] and not buy_condition and not sell_condition[1] and not sell_condition[2] 
         and not sell_condition[3] and not sell_condition[4] and not sell_condition[5] and not sell_condition 
         and in_trade and not mart_call_profit
        count_closs += 1
        in_trade := false
        closs := true
        in_loss := true
        in_profit := false
        buy_condition := false
        sell_condition := false
        can_buy_call := false
        can_buy_put := false


calculate_martingale_amount(previous_investment, win_ratio)=>
    mart = (int(previous_investment) / win_ratio) + int(previous_investment)
    if mart - math.floor(mart) >= 0.5
        math.ceil(mart)
    else
        math.floor(mart)

    

if cl1win[1]
    cl1win := false

if cl2win[1]
    cl2win := false

if cl3win[1]
    cl3win := false

if cl4win[1]
    cl4win := false

if cl5win[1]
    cl5win := false

if closs[1]
    closs := false


if i_martingale_level == 1
    if sell_condition[1] and not sell_condition  and in_trade and  
     put_profit and not buy_condition[1] and not buy_condition
        count_pl1win += 1
        in_trade := false
        pl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if sell_condition[1] and not sell_condition and not buy_condition[1] 
     and not buy_condition and in_trade and  not put_profit
        count_ploss += 1
        in_trade := false
        ploss := true
        buy_condition := false
        sell_condition := false
        in_loss := true
        in_profit := false
        can_buy_call := false
        can_buy_put := false


else if i_martingale_level == 2
    if sell_condition[1] and not sell_condition and in_trade and put_profit and not buy_condition[1] 
         and not buy_condition
        count_pl1win += 1
        in_trade := false
        pl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[2] and not sell_condition[1] and not sell_condition and in_trade and mart_put_profit 
         and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition
        count_pl2win += 1
        in_trade := false
        pl2win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if sell_condition[2] and not sell_condition[1] and not sell_condition and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition and in_trade and not mart_put_profit
        count_ploss += 1
        in_trade := false
        ploss := true
        buy_condition := false
        sell_condition := false
        in_loss := true
        in_profit := false
        can_buy_call := false
        can_buy_put := false



else if i_martingale_level == 3
    if sell_condition[1] and not sell_condition and in_trade and put_profit and not buy_condition[1] 
         and not buy_condition
        count_pl1win += 1
        in_trade := false
        pl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[2] and not sell_condition[1] and not sell_condition and in_trade 
         and mart_put_profit and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition
        count_pl2win += 1
        in_trade := false
        pl2win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[3] and not sell_condition[2] and not sell_condition[1] and not sell_condition 
         and in_trade and mart_put_profit and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition[3] and not buy_condition
        count_pl3win += 1
        in_trade := false
        pl3win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if sell_condition[3] and not sell_condition[2] and not sell_condition[1] and not sell_condition 
         and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] and not buy_condition 
         and in_trade and not mart_put_profit
        count_ploss += 1
        in_trade := false
        ploss := true
        buy_condition := false
        sell_condition := false
        in_loss := true
        in_profit := false
        can_buy_call := false
        can_buy_put := false


else if i_martingale_level == 4
    if sell_condition[1] and not sell_condition and in_trade and put_profit and not buy_condition[1] 
         and not buy_condition
        count_pl1win += 1
        in_trade := false
        pl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[2] and not sell_condition[1] and not sell_condition and in_trade and mart_put_profit 
         and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition
        count_pl2win += 1
        in_trade := false
        pl2win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[3] and not sell_condition[2] and not sell_condition[1] and not sell_condition and in_trade 
         and mart_put_profit and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition[3] and not buy_condition
        count_pl3win += 1
        in_trade := false
        pl3win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[4] and not sell_condition[3] and not sell_condition[2] and not sell_condition[1] 
         and not sell_condition 
         and in_trade and mart_put_profit and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition[3] and not buy_condition[4] and not buy_condition
        count_pl4win += 1
        in_trade := false
        pl4win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false


    else if sell_condition[4] and not sell_condition[3] and not sell_condition[2] and not sell_condition[1] 
         and not sell_condition and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
         and not buy_condition[4] and not buy_condition and in_trade and not mart_put_profit
        count_ploss += 1
        in_trade := false
        ploss := true
        buy_condition := false
        sell_condition := false
        in_loss := true
        in_profit := false
        can_buy_call := false
        can_buy_put := false




else if i_martingale_level == 5
    if sell_condition[1] and not sell_condition and in_trade and put_profit and not buy_condition[1] 
         and not buy_condition
        count_pl1win += 1
        in_trade := false
        pl1win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[2] and not sell_condition[1] and not sell_condition and in_trade and mart_put_profit 
         and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition
        count_pl2win += 1
        in_trade := false
        pl2win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[3] and not sell_condition[2] and not sell_condition[1] and not sell_condition and in_trade 
         and mart_put_profit and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition[3] and not buy_condition
        count_pl3win += 1
        in_trade := false
        pl3win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[4] and not sell_condition[3] and not sell_condition[2] and not sell_condition[1] 
         and not sell_condition and in_trade and mart_put_profit and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition[3] and not buy_condition[4] and not buy_condition
        count_pl4win += 1
        in_trade := false
        pl4win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false



    else if sell_condition[5] and not sell_condition[4] and not sell_condition[3] and not sell_condition[2] 
         and not sell_condition[1] and not sell_condition and in_trade and mart_put_profit and not buy_condition[1] 
         and not buy_condition[2] and not buy_condition[3] and not buy_condition[4] and not buy_condition[5] 
         and not buy_condition
        count_pl5win += 1
        in_trade := false
        pl5win := true
        buy_condition := false
        sell_condition := false
        in_profit := true
        in_loss := false
        can_buy_call := false
        can_buy_put := false




    else if sell_condition[5] and not sell_condition[4] and not sell_condition[3] and not sell_condition[2] 
         and not sell_condition[1] and not sell_condition and not buy_condition[1] and not buy_condition[2] 
         and not buy_condition[3] and not buy_condition[4] and not buy_condition[5] and not buy_condition 
         and in_trade and not mart_put_profit
        count_ploss += 1
        in_trade := false
        ploss := true
        buy_condition := false
        sell_condition := false
        in_loss := true
        in_profit := false
        can_buy_call := false
        can_buy_put := false


if in_profit
    max_profit += 1
    max_loss := 0
    in_profit := false
    in_loss := false

if in_loss
    max_loss += 1
    max_profit := 0
    in_loss := false
    in_profit := false



if max_profit > consecutive_profit
    consecutive_profit := max_profit
    

if max_loss > consecutive_loss
    consecutive_loss := max_loss
   

if pl1win[1]
    pl1win := false

if pl2win[1]
    pl2win := false

if pl3win[1]
    pl3win := false

if pl4win[1]
    pl4win := false

if pl5win[1]
    pl5win := false

if ploss[1]
    ploss := false
var label lx=na

plotshape(buy_condition,title="Call",style = shape.triangleup,location = location.belowbar,
 color=color.new(color.teal, 0))
plotshape(sell_condition,title="Put",style = shape.triangledown,location = location.abovebar,
 color=color.new(color.maroon, 0))    
plotchar(cl1win ,title="Call Level 1 Char", char='1', location=location.abovebar)   
plotchar(cl2win ,title="Call Level 2 Char", char='2', location=location.abovebar,offset=0)
plotchar(cl3win ,title="Call Level 3 Char", char='3', location=location.abovebar,offset=0)
plotchar(cl4win ,title="Call Level 4 Char", char='4', location=location.abovebar,offset=0)
plotchar(cl5win ,title="Call Level 5 Char", char='5', location=location.abovebar,offset=0)
plotchar(closs ,title="Call Loss Char", char='L', location=location.abovebar,color = color.new(color.red,0))

plotchar(pl1win ,title="Put Level 1 Char", char='1', location=location.belowbar)
plotchar(pl2win ,title="Put Level 2 Char", char='2', location=location.belowbar,offset=0)
plotchar(pl3win ,title="Put Level 3 Char", char='3', location=location.belowbar,offset=0)
plotchar(pl4win ,title="Put Level 4 Char", char='4', location=location.belowbar,offset=0)
plotchar(pl5win ,title="Put Level 5 Char", char='5', location=location.belowbar,offset=0)
plotchar(ploss ,title="Put Loss L", char='L', location=location.belowbar,color = color.new(color.red,0))


var table _table = table.new(position.top_right, 3, 9, border_color=color.black, border_width=2)
var table _table2 = table.new(position.bottom_left, 3, 8, border_color=color.black, border_width=2)
var table _table3 = table.new(position.bottom_right, 3, 5, border_color=color.black, border_width=2)

alertcondition(condition=is_call,
 title= " BOST Buy",
 message='Buy alert triggered'

 )

alertcondition(condition=is_put,title="BOST Sell",
 message='Sell alert triggered'
 )


if barstate.islast 
    table.cell(_table, 0, 0, 'Number of bar Tested', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 0, str.tostring(bar_index), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 0, '100%', text_color=color.white, bgcolor=#1848CC)

    table.cell(_table, 0, 1, 'Number of Call', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 1, str.tostring(count_call), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 1, str.tostring(count_call / bar_index * 100, '#.##'), 
     text_color=color.white, bgcolor=#1848CC)

    table.cell(_table, 0, 2, 'Level 1 Win', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 2, str.tostring(count_cl1win), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 2, str.tostring(count_cl1win / count_call * 100, '#.##'), text_color=color.white, 
     bgcolor=#1848CC)

    table.cell(_table, 0, 3, 'Level 2 Win', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 3, str.tostring(count_cl2win), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 3, str.tostring(count_cl2win / count_call * 100, '#.##'), text_color=color.white, 
     bgcolor=#1848CC)

    table.cell(_table, 0, 4, 'Level 3 Win', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 4, str.tostring(count_cl3win), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 4, str.tostring(count_cl3win / count_call * 100, '#.##'), text_color=color.white, bgcolor=#1848CC)

    table.cell(_table, 0, 5, 'Level 4 Win', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 5, str.tostring(count_cl4win), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 5, str.tostring(count_cl4win / count_call * 100, '#.##'), text_color=color.white, bgcolor=#1848CC)

    table.cell(_table, 0, 6, 'Level 5 Win', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 6, str.tostring(count_cl5win), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 6, str.tostring(count_cl5win / count_call * 100, '#.##'), text_color=color.white, bgcolor=#1848CC)

    table.cell(_table, 0, 7, 'Total Call Profit', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 7, str.tostring(count_cl1win + count_cl2win + count_cl3win + count_cl4win + count_cl5win), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 7, str.tostring((count_cl1win + count_cl2win + count_cl3win + count_cl4win + count_cl5win) / count_call * 100, '#.##'), text_color=color.white, bgcolor=#1848CC)

    table.cell(_table, 0, 8, 'Loss', text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 1, 8, str.tostring(count_closs), text_color=color.white, bgcolor=#1848CC)
    table.cell(_table, 2, 8, str.tostring(count_closs / count_call * 100, '#.##'), text_color=color.white, bgcolor=#1848CC)

    table.cell(_table2, 0, 0, 'Number of Put', text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 1, 0, str.tostring(count_put), text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 2, 0, str.tostring(count_put / bar_index * 100, '#.##'), text_color=color.white, bgcolor=#ff4a68)

    table.cell(_table2, 0, 1, 'Level 1 Win', text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 1, 1, str.tostring(count_pl1win), text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 2, 1, str.tostring(count_pl1win / count_put * 100, '#.##'), text_color=color.white, bgcolor=#ff4a68)

    table.cell(_table2, 0, 2, 'Level 2 Win', text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 1, 2, str.tostring(count_pl2win), text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 2, 2, str.tostring(count_pl2win / count_put * 100, '#.##'), text_color=color.white, bgcolor=#ff4a68)

    table.cell(_table2, 0, 3, 'Level 3 Win', text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 1, 3, str.tostring(count_pl3win), text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 2, 3, str.tostring(count_pl3win / count_put * 100, '#.##'), text_color=color.white, bgcolor=#ff4a68)

    table.cell(_table2, 0, 4, 'Level 4 Win', text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 1, 4, str.tostring(count_pl4win), text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 2, 4, str.tostring(count_pl4win / count_put * 100, '#.##'), text_color=color.white, bgcolor=#ff4a68)

    table.cell(_table2, 0, 5, 'Level 5 Win', text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 1, 5, str.tostring(count_pl5win), text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 2, 5, str.tostring(count_pl5win / count_put * 100, '#.##'), text_color=color.white, bgcolor=#ff4a68)

    table.cell(_table2, 0, 6, 'Total Put Profit', text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 1, 6, str.tostring(count_pl1win + count_pl2win + count_pl3win + count_pl4win + count_pl5win), text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 2, 6, str.tostring((count_pl1win + count_pl2win + count_pl3win + count_pl4win + count_pl5win) / count_put * 100, '#.##'), text_color=color.white, bgcolor=#ff4a68)

    table.cell(_table2, 0, 7, 'Loss', text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 1, 7, str.tostring(count_ploss), text_color=color.white, bgcolor=#ff4a68)
    table.cell(_table2, 2, 7, str.tostring(count_ploss / count_put * 100, '#.##'), text_color=color.white, bgcolor=#ff4a68)

    table.cell(_table3, 0, 0, 'Profit in a row', text_color=color.white, bgcolor=#056b60)
    table.cell(_table3, 1, 0, str.tostring(consecutive_profit), text_color=color.white, bgcolor=#056b60)
    table.cell(_table3, 2, 0, str.tostring(consecutive_profit / (count_call + count_put) * 100, '#.##'), text_color=color.white, bgcolor=#056b60)

    table.cell(_table3, 0, 1, 'Loss in a row', text_color=color.white, bgcolor=#c71c69)
    table.cell(_table3, 1, 1, str.tostring(consecutive_loss), text_color=color.white, bgcolor=#c71c69)
    table.cell(_table3, 2, 1, str.tostring(consecutive_loss / (count_call + count_put) * 100, '#.##'), text_color=color.white, bgcolor=#c71c69)
    
    tp=(((count_pl1win + count_pl2win + count_pl3win + count_pl4win + count_pl5win)+
     (count_cl1win + count_cl2win + count_cl3win + count_cl4win + count_cl5win))*initial_investment)*(profit_percentage/100)
    table.cell(_table3, 0, 2, 'Total Profit', text_color=color.white, bgcolor=#c71c69)
    table.cell(_table3, 1, 2, '$'+str.tostring(tp,'#.##'), text_color=color.white, bgcolor=#c71c69)
    table.cell(_table3, 2, 2, '-', text_color=color.white, bgcolor=#c71c69)
    
    amt2=calculate_martingale_amount(initial_investment, (profit_percentage/100))
    amt3=calculate_martingale_amount(amt2, (profit_percentage/100))+1
    amt4=calculate_martingale_amount(amt3, (profit_percentage/100))+1
    amt5=calculate_martingale_amount(amt4, (profit_percentage/100))+1
    tl=0.0
    if i_martingale_level==1
        tl:=(count_ploss+count_closs)*initial_investment
    else if i_martingale_level==2
        tl:=(count_ploss+count_closs)*(initial_investment+amt2)
    else if i_martingale_level==3
        tl:=(count_ploss+count_closs)*(initial_investment+amt2+amt3)
    else if i_martingale_level==4
        tl:=(count_ploss+count_closs)*(initial_investment+amt2+amt3+amt4)
    else if i_martingale_level==5
        tl:=(count_ploss+count_closs)*(initial_investment+amt2+amt3+amt4+amt5)
    
    table.cell(_table3, 0, 3, 'Total Loss', text_color=color.white, bgcolor=#c71c69)
    table.cell(_table3, 1, 3, '$'+str.tostring(tl*1,'#.##'), text_color=color.white, bgcolor=#c71c69)
    table.cell(_table3, 2, 3, str.tostring(initial_investment)+', '+str.tostring(amt2)
     +', '+str.tostring(amt3)+',\n'+str.tostring(amt4)+', '+str.tostring(amt5), text_color=color.white, bgcolor=#c71c69)
    
    np=tp-tl
    
    table.cell(_table3, 0, 4, 'Net PL', text_color=color.white, bgcolor=#c71c69)
    table.cell(_table3, 1, 4, '$'+str.tostring(np), text_color=color.white, bgcolor=#c71c69)
    table.cell(_table3, 2, 4, '-', text_color=color.white, bgcolor=#c71c69)
````
