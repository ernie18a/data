# Binary Option Strategy Tester with Martingale

- url: https://www.tradingview.com/script/rmSNswV0-Binary-Option-Strategy-Tester-with-Martingale/
- type: indicator
- pine_id: PUB;c7c1e32ddc2d4c60a55b14fdc6de4f00
- version: 2.0

## Description

In Binary options, strategy testing is a bit different. The script is just a try to test Binary options strategies.
[b]Assumption:[/b]
[list]
[*]We are opening position at next candle after signal come
[*]We are taking the position at opening price
[*]Our call will be profitable if we get a green candle and put will be profitable  if we get a red candle
[*]We can open only one trade at a time. So if we are in trade, subsequent signals will be ignored.
[/list]
The script is not counting your profit or loss, it just counting the winning and losing trades.

[b]Input Options:[/b]
[list]
[*]Choose long only or short only test. Default is both.
[*]You can continue your trade with Martingale Level, up to 5. Default is 1 (no Martingale)
[*]You can choose Martingale trade type
    SAME: if call subsequent trade will be call only and vice versa
   OPPOSITE: if call subsequent trade will be put
   FOLLOW CANDLE COLOR: Subsequent trade will follow previous candle color
   OPPOSITE CANDLE COLOR: Subsequent trade will opposite of previous candle color
[*]You can choose trading session to test. Default is false.
[/list]

The strategy is taken from [url=https://www.tradingview.com/script/s48QJlfi-Vdub-Binary-Options-SniperVX-v1/]Vdub Binary Options SniperVX v1 (by @vdubus)[/url]. I have deleted extra parts and kept only the necessary part. 
Without Martingale
[image]https://www.tradingview.com/x/ixbZTGLX/[/image]
Result Table
[image]https://www.tradingview.com/x/2rRyxKIM/[/image]
With Martingale
[image]https://www.tradingview.com/x/BJuDHalX/[/image]

I am very new to Pine script, so waiting for your comments and review.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tanayroy

//@version=4
study("Binary Option Strategy Tester with Martingale", shorttitle="BOST V.1")

gp="Strategy Information"
i_trade_call_put=input('BOTH',title="Trade Call/Put",type=input.string,options=['BOTH','CALL','PUT'],group=gp)
//input on martingale level
i_martingale_level=input(1,title="Martingale Level",type=input.integer,minval=1,maxval=5,group=gp)
i_martingle_trade=input('SAME',title="Type of Trade",type=input.string,
 options=['SAME','OPPOSITE','FOLLOW CANDLE COLOR','OPPOSITE CANDLE COLOR'],group=gp)
//trading time
i_trading_session= input("0930-1600", type=input.session,group=gp)
i_use_session=input(false,"Use Specific Session",type=input.bool,group=gp)
//check if in session
InSession() => time(timeframe.period, i_trading_session) != 0
in_sess=i_use_session?InSession():true
long_allowed=i_trade_call_put == 'BOTH' or i_trade_call_put == 'CALL'
short_allowed=i_trade_call_put == 'BOTH' or i_trade_call_put == 'PUT'
//check martingale way
martingale_way(call,put,type)=>
    out=false
    if call and type=='NA'
        out:=close>open
    else if put and type=='NA'
        out:=open>close
    else if type=='SAME' and call
        out:=close>open
    else if type=='SAME' and put
        out:=open>close
    else if type=='OPPOSITE' and call
        out:=open>close
    else if type=='OPPOSITE' and put
        out:=close>open
    else if type=='FOLLOW CANDLE COLOR'
        out:=close[1]>open[1]?close>open:open>close
    else if type=='OPPOSITE CANDLE COLOR'
        out:=close[1]>open[1]?close<open:open<close
    out
        

//variable for strategy testing
var can_buy_call=false
var can_buy_put=false
var in_martingale=false
var in_trade=false
var buy_condition=false
var sell_condition=false
var int count_call=0
var int count_put=0
var bool cl1win=na
var bool cl2win=na
var bool cl3win=na
var bool cl4win=na
var bool cl5win=na
var bool closs=na
var int count_cl1win=0
var int count_cl2win=0
var int count_cl3win=0
var int count_cl4win=0
var int count_cl5win=0
var int count_closs=0

var bool pl1win=na
var bool pl2win=na
var bool pl3win=na
var bool pl4win=na
var bool pl5win=na
var bool ploss=na
var int count_pl1win=0
var int count_pl2win=0
var int count_pl3win=0
var int count_pl4win=0
var int count_pl5win=0
var int count_ploss=0
var bool in_profit=false
var bool in_loss=false
var int max_loss=0
var int consecutive_loss=0
var int max_profit=0
var int consecutive_profit=0

//*****************************************************************************//
//*****************************************************************************//
//********************************YOUR STRATEGY********************************//
//*****************************************************************************//
//*****************************************************************************//

//strategy Vdub Binary Options SniperVX v1 by vdubus
len = 8
src = close
out = sma(src, len)
last8h = highest(close, 13)
lastl8 = lowest(close, 13)
bearish = cross(close,out) == 1 and close[1] > close
bullish = cross(close,out) == 1 and close[1] < close
channel2=false
src0 = close, len0 = 13//input(13, minval=1, title="Trend Change EMA")
ema0 = ema(src0, len0)

//--Modified vyacheslav.shindin-------------------------------------------------//           Signal 1
//Configured ema signal output
slow = 8
fast = 5
vh1 = ema(highest(avg(low, close), fast), 5)
vl1 = ema(lowest(avg(high, close), slow), 8)
//
e_ema1 = ema(close, 1)
e_ema2 = ema(e_ema1, 1)
e_ema3 = ema(e_ema2, 1)
tema = 1 * (e_ema1 - e_ema2) + e_ema3
//
e_e1 = ema(close, 8)
e_e2 = ema(e_e1, 5)
dema = 2 * e_e1 - e_e2
signal = tema > dema ? max(vh1, vl1) : min(vh1, vl1)


//strategy for buying call
is_call=tema > dema and signal > low and (signal-signal[1] > signal[1]-signal[2])

//strategy fo selling call
is_put=tema < dema and signal < high and (signal[1]-signal > signal[2]-signal[1])




//*****************************************************************************//



if is_call and long_allowed
    can_buy_call:=true
    can_buy_put:=false
    
if is_put and short_allowed
    can_buy_call:=false
    can_buy_put:=true
  
    
if can_buy_call and not can_buy_call[1]  and not in_trade and in_sess 
    buy_condition:=true
    in_trade:=true
    count_call:=count_call+1
else if buy_condition[1]
    buy_condition:=false 
   
if can_buy_put and not can_buy_put[1]  and not in_trade and in_sess 
    sell_condition:=true
    in_trade:=true
    count_put:=count_put+1
    
else if sell_condition[1]
    sell_condition:=false    

call_profit=martingale_way(true,false,'NA')
mart_call_profit=martingale_way(true,false,i_martingle_trade)
put_profit=martingale_way(false,true,'NA')
mart_put_profit=martingale_way(false,true,i_martingle_trade)

if i_martingale_level==1
    if buy_condition[1] and not buy_condition and in_trade and call_profit  
     and not sell_condition[1]  and not sell_condition
        count_cl1win:=count_cl1win+1
        in_trade:=false
        cl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    else if buy_condition[1] and not buy_condition and not sell_condition[1]  
     and not sell_condition and in_trade and  not call_profit
        count_closs:=count_closs+1
        in_trade:=false
        closs:=true
        buy_condition:=false
        sell_condition:=false
        can_buy_call:=false
        can_buy_put:=false

else if i_martingale_level==2
    if buy_condition[1] and not buy_condition and in_trade and  call_profit 
     and not sell_condition[1] and not sell_condition[2] and not sell_condition
        count_cl1win:=count_cl1win+1
        in_trade:=false
        cl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    if buy_condition[2] and not buy_condition  and in_trade 
     and  mart_call_profit and not sell_condition[1] and not 
     sell_condition[2] and not sell_condition
        count_cl2win:=count_cl2win+1
        in_trade:=false
        cl2win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    else if buy_condition[2] and not buy_condition[1] and not buy_condition 
     and not sell_condition[1] and not sell_condition[2]  and 
     not sell_condition and in_trade and  not mart_call_profit
        count_closs:=count_closs+1
        in_trade:=false
        closs:=true
        buy_condition:=false
        sell_condition:=false
        can_buy_call:=false
        can_buy_put:=false
        
    
else if i_martingale_level==3
    if buy_condition[1] and not buy_condition and in_trade and  call_profit 
     and not sell_condition[1] and not sell_condition[2] and not 
     sell_condition[3]  and not sell_condition
        count_cl1win:=count_cl1win+1
        in_trade:=false
        cl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    if buy_condition[2] and not buy_condition  and in_trade and 
     mart_call_profit and not sell_condition[1] and not sell_condition[2] 
     and not sell_condition[3]  and not sell_condition
        count_cl2win:=count_cl2win+1
        in_trade:=false
        cl2win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    if buy_condition[3] and not buy_condition and in_trade and  mart_call_profit 
     and not sell_condition[1] and not sell_condition[2] and not 
     sell_condition[3]  and not sell_condition
        count_cl3win:=count_cl3win+1
        in_trade:=false
        cl3win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    else if buy_condition[3] and not buy_condition[2] and not buy_condition[1] 
     and not buy_condition and not sell_condition[1] and not sell_condition[2] 
     and not sell_condition[3]  and not sell_condition and in_trade and 
     not mart_call_profit
        count_closs:=count_closs+1
        in_trade:=false
        closs:=true
        buy_condition:=false
        sell_condition:=false
        can_buy_call:=false
        can_buy_put:=false

else if i_martingale_level==4
    if buy_condition[1] and not buy_condition and in_trade and  call_profit 
     and not sell_condition[1] and not sell_condition[2] and not 
     sell_condition[3] and not sell_condition[4]  and not sell_condition
        count_cl1win:=count_cl1win+1
        in_trade:=false
        cl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    if buy_condition[2] and not buy_condition  and in_trade and  
     mart_call_profit and not sell_condition[1] and not sell_condition[2] 
     and not sell_condition[3] and not sell_condition[4]  and not sell_condition
        count_cl2win:=count_cl2win+1
        in_trade:=false
        cl2win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    if buy_condition[3] and not buy_condition and in_trade and  mart_call_profit 
     and not sell_condition[1] and not sell_condition[2] and not sell_condition[3] 
     and not sell_condition[4]  and not sell_condition
        count_cl3win:=count_cl3win+1
        in_trade:=false
        cl3win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if buy_condition[4] and not buy_condition and in_trade and  mart_call_profit 
     and not sell_condition[1] and not sell_condition[2] and not sell_condition[3] 
     and not sell_condition[4]  and not sell_condition
        count_cl4win:=count_cl4win+1
        in_trade:=false
        cl4win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    else if buy_condition[4] and not buy_condition[3] and not buy_condition[2] 
     and not buy_condition[1] and not buy_condition and not sell_condition[1] 
     and not sell_condition[2] and not sell_condition[3] and not sell_condition[4]  
     and not sell_condition and in_trade and  not mart_call_profit
        count_closs:=count_closs+1
        in_trade:=false
        closs:=true
        buy_condition:=false
        sell_condition:=false
        can_buy_call:=false
        can_buy_put:=false
    


if i_martingale_level==5
    if buy_condition[1] and not buy_condition and in_trade and  call_profit 
     and not sell_condition[1] and not sell_condition[2] and not 
     sell_condition[3] and not sell_condition[4] and not sell_condition[5] 
     and not sell_condition
        count_cl1win:=count_cl1win+1
        in_trade:=false
        cl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    if buy_condition[2] and not buy_condition  and in_trade and mart_call_profit 
     and not sell_condition[1] and not sell_condition[2] and not sell_condition[3]
     and not sell_condition[4] and not sell_condition[5] and not sell_condition
        count_cl2win:=count_cl2win+1
        in_trade:=false
        cl2win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    if buy_condition[3] and not buy_condition and in_trade and  mart_call_profit
     and not sell_condition[1] and not sell_condition[2] and not sell_condition[3]
     and not sell_condition[4] and not sell_condition[5] and not sell_condition
        count_cl3win:=count_cl3win+1
        in_trade:=false
        cl3win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if buy_condition[4] and not buy_condition and in_trade and  mart_call_profit 
     and not sell_condition[1] and not sell_condition[2] and not sell_condition[3] 
     and not sell_condition[4] and not sell_condition[5] and not sell_condition
        count_cl4win:=count_cl4win+1
        in_trade:=false
        cl4win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if buy_condition[5] and not buy_condition and not sell_condition[1] and not 
     sell_condition[2] and not sell_condition[3] and not sell_condition[4] and 
     not sell_condition[5] and not sell_condition and in_trade and  mart_call_profit
        count_cl5win:=count_cl5win+1
        in_trade:=false
        cl5win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    
    else if buy_condition[5] and not buy_condition[4] and not buy_condition[3] 
     and not buy_condition[2] and not buy_condition[1] and not buy_condition 
     and not sell_condition[1] and not sell_condition[2] and not sell_condition[3] 
     and not sell_condition[4] and not sell_condition[5] and not sell_condition 
     and in_trade and  not mart_call_profit
        count_closs:=count_closs+1
        in_trade:=false
        closs:=true
        buy_condition:=false
        sell_condition:=false
        can_buy_call:=false
        can_buy_put:=false

    
    
if cl1win[1]
    cl1win:=false
if cl2win[1]
    cl2win:=false
if cl3win[1]
    cl3win:=false
if cl4win[1]
    cl4win:=false
if cl5win[1]
    cl5win:=false
if closs[1]
    closs:=false

if i_martingale_level==1
    if sell_condition[1] and not sell_condition  and in_trade and  
     put_profit and not buy_condition[1] and not buy_condition
        count_pl1win:=count_pl1win+1
        in_trade:=false
        pl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    else if sell_condition[1] and not sell_condition and not buy_condition[1] 
     and not buy_condition and in_trade and  not put_profit
        count_ploss:=count_ploss+1
        in_trade:=false
        ploss:=true
        buy_condition:=false
        sell_condition:=false
        in_loss:=true
        in_profit:=false
        can_buy_call:=false
        can_buy_put:=false
        
else if i_martingale_level==2
    if sell_condition[1] and not sell_condition  and in_trade and  
     put_profit and not buy_condition[1] and not buy_condition[2]  
     and not buy_condition
        count_pl1win:=count_pl1win+1
        in_trade:=false
        pl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    
    if sell_condition[2] and not sell_condition  and in_trade and mart_put_profit
     and not buy_condition[1] and not buy_condition[2]  and not buy_condition
        count_pl2win:=count_pl2win+1
        in_trade:=false
        pl2win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    else if sell_condition[2] and not sell_condition[1] and not sell_condition 
     and not buy_condition[1] and not buy_condition[2]  and not buy_condition 
     and in_trade and  not mart_put_profit
        count_ploss:=count_ploss+1
        in_trade:=false
        ploss:=true
        buy_condition:=false
        sell_condition:=false 
        in_loss:=true
        in_profit:=false
        can_buy_call:=false
        can_buy_put:=false
    
    
else if i_martingale_level==3
    if sell_condition[1] and not sell_condition  and in_trade and  put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition
        count_pl1win:=count_pl1win+1
        in_trade:=false
        pl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    
    if sell_condition[2] and not sell_condition  and in_trade and  
     mart_put_profit and not buy_condition[1] and not 
     buy_condition[2] and not buy_condition[3]  and not buy_condition
        count_pl2win:=count_pl2win+1
        in_trade:=false
        pl2win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if sell_condition[3] and not sell_condition and in_trade and  
     mart_put_profit and not buy_condition[1] and not buy_condition[2] 
     and not buy_condition[3]  and not buy_condition
        count_pl3win:=count_pl3win+1
        in_trade:=false
        pl3win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    else if sell_condition[3] and not sell_condition[2] and not 
     sell_condition[1] and not sell_condition and not buy_condition[1] 
     and not buy_condition[2] and not buy_condition[3]  and not buy_condition 
     and in_trade and  not mart_put_profit
        count_ploss:=count_ploss+1
        in_trade:=false
        ploss:=true
        buy_condition:=false
        sell_condition:=false
        in_loss:=true
        in_profit:=false
        can_buy_call:=false
        can_buy_put:=false
    
else if i_martingale_level==4
    if sell_condition[1] and not sell_condition  and in_trade and  put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4]  and not buy_condition
        count_pl1win:=count_pl1win+1
        in_trade:=false
        pl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    
    if sell_condition[2] and not sell_condition  and in_trade and  
     mart_put_profit and not buy_condition[1] and not buy_condition[2] 
     and not buy_condition[3] and not buy_condition[4]  and not buy_condition
        count_pl2win:=count_pl2win+1
        in_trade:=false
        pl2win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if sell_condition[3] and not sell_condition and in_trade and  mart_put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4]  and not buy_condition
        count_pl3win:=count_pl3win+1
        in_trade:=false
        pl3win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if sell_condition[4] and not sell_condition and in_trade and  mart_put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4]  and not buy_condition
        count_pl4win:=count_pl4win+1
        in_trade:=false
        pl4win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
    else if sell_condition[4] and not sell_condition[3] and not sell_condition[2] 
     and not sell_condition[1] and not sell_condition and not buy_condition[1] 
     and not buy_condition[2] and not buy_condition[3] and not buy_condition[4] 
     and not buy_condition and in_trade and  not mart_put_profit
        count_ploss:=count_ploss+1
        in_trade:=false
        ploss:=true
        buy_condition:=false
        sell_condition:=false
        in_loss:=true
        in_profit:=false
        can_buy_call:=false
        can_buy_put:=false
        


else if i_martingale_level==5    
    if sell_condition[1] and not sell_condition  and in_trade and  put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4] and not buy_condition[5] and not buy_condition
        count_pl1win:=count_pl1win+1
        in_trade:=false
        pl1win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
    
    
    if sell_condition[2] and not sell_condition  and in_trade and  mart_put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4] and not buy_condition[5] and not buy_condition
        count_pl2win:=count_pl2win+1
        in_trade:=false
        pl2win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if sell_condition[3] and not sell_condition and in_trade and  mart_put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4] and not buy_condition[5] and not buy_condition
        count_pl3win:=count_pl3win+1
        in_trade:=false
        pl3win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if sell_condition[4] and not sell_condition and in_trade and  mart_put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4] and not buy_condition[5] and not buy_condition
        count_pl4win:=count_pl4win+1
        in_trade:=false
        pl4win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    if sell_condition[5] and not sell_condition  and in_trade and  mart_put_profit 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4] and not buy_condition[5] and not buy_condition
        count_pl5win:=count_pl5win+1
        in_trade:=false
        pl5win:=true
        buy_condition:=false
        sell_condition:=false
        in_profit:=true
        in_loss:=false
        can_buy_call:=false
        can_buy_put:=false
        
        
    
    else if sell_condition[5] and not sell_condition[4] and not sell_condition[3] 
     and not sell_condition[2] and not sell_condition[1] and not sell_condition 
     and not buy_condition[1] and not buy_condition[2] and not buy_condition[3] 
     and not buy_condition[4] and not buy_condition[5] and not buy_condition 
     and in_trade and  not mart_put_profit
        count_ploss:=count_ploss+1
        in_trade:=false
        ploss:=true
        buy_condition:=false
        sell_condition:=false
        in_loss:=true
        in_profit:=false
        can_buy_call:=false
        can_buy_put:=false

if in_profit
    max_profit:=max_profit+1
    max_loss:=0
    in_profit:=false
if in_loss
    max_loss:=max_loss+1
    max_profit:=0
    in_loss:=false

    
if max_profit>consecutive_profit
    consecutive_profit:=max_profit

if max_loss>consecutive_loss
    consecutive_loss:=max_loss
    
if pl1win[1]
    pl1win:=false
if pl2win[1]
    pl2win:=false
if pl3win[1]
    pl3win:=false
if pl4win[1]
    pl4win:=false
if pl5win[1]
    pl5win:=false
if ploss[1]
    ploss:=false    
    
plot(buy_condition  ?5:0,style=plot.style_columns,color=color.teal)
plot(sell_condition ?5:0,style=plot.style_columns,color=color.maroon)
// plot(buy_condition?5:0,style=plot.style_columns,color=color.orange)  
plotchar(buy_condition ?5:0, char='C',location=location.absolute)
plotchar(sell_condition?5:0, char='P',location=location.absolute)

plot(cl1win?5:0,style=plot.style_columns,color=color.green)
plotchar(cl1win?5:0, char='1',location=location.absolute)
plot(cl2win?4:0,style=plot.style_columns,color=color.green)
plotchar(cl2win?4:0, char='2',location=location.absolute)
plot(cl3win?3:0,style=plot.style_columns,color=color.green)
plotchar(cl3win?3:0, char='3',location=location.absolute)
plot(cl4win?2:0,style=plot.style_columns,color=color.green)
plotchar(cl4win?2:0, char='4',location=location.absolute)
plot(cl5win?1:0,style=plot.style_columns,color=color.green)
plotchar(cl5win?1:0, char='5',location=location.absolute)
plot(closs?5:0,style=plot.style_columns,color=color.red)
plotchar(closs?5:0, char='L',location=location.absolute)

plot(pl1win?5:0,style=plot.style_columns,color=color.green)
plotchar(pl1win?5:0, char='1',location=location.absolute)
plot(pl2win?4:0,style=plot.style_columns,color=color.green)
plotchar(pl2win?4:0, char='2',location=location.absolute)
plot(pl3win?3:0,style=plot.style_columns,color=color.green)
plotchar(pl3win?3:0, char='3',location=location.absolute)
plot(pl4win?2:0,style=plot.style_columns,color=color.green)
plotchar(pl4win?2:0, char='4',location=location.absolute)
plot(pl5win?1:0,style=plot.style_columns,color=color.green)
plotchar(pl5win?1:0, char='5',location=location.absolute)
plot(ploss?5:0,style=plot.style_columns,color=color.red)
plotchar(ploss?5:0, char='L',location=location.absolute)

var table _table = table.new(position.bottom_right, 3, 19, border_color=color.black,border_width = 2)

if barstate.islast
    table.cell(_table,0,0,"Number of bar Tested",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,0,tostring(bar_index),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,0,'100%',text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,1,"Number of Call",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,1,tostring(count_call),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,1,tostring((count_call/bar_index)*100,'#.##'),text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,2,"Level 1 Win",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,2,tostring(count_cl1win),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,2,tostring((count_cl1win/count_call)*100,'#.##'),text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,3,"Level 2 Win",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,3,tostring(count_cl2win),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,3,tostring((count_cl2win/count_call)*100,'#.##'),text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,4,"Level 3 Win",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,4,tostring(count_cl3win),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,4,tostring((count_cl3win/count_call)*100,'#.##'),text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,5,"Level 4 Win",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,5,tostring(count_cl4win),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,5,tostring((count_cl4win/count_call)*100,'#.##'),text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,6,"Level 5 Win",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,6,tostring(count_cl5win),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,6,tostring((count_cl5win/count_call)*100,'#.##'),text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,7,"Total Call Profit",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,7,tostring(count_cl1win+count_cl2win+count_cl3win+count_cl4win+count_cl5win),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,7,tostring(((count_cl1win+count_cl2win+count_cl3win+count_cl4win+count_cl5win)/count_call)*100,'#.##'),
     text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,8,"Loss",text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,1,8,tostring(count_closs),text_color=color.white,bgcolor=#1848CC)
    table.cell(_table,2,8,tostring((count_closs/count_call)*100,'#.##'),text_color=color.white,bgcolor=#1848CC)
    
    table.cell(_table,0,9,"Number of Put",text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,1,9,tostring(count_put),text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,2,9,tostring((count_put/bar_index)*100,'#.##'),text_color=color.white,bgcolor=#ff4a68)
    
    table.cell(_table,0,10,"Level 1 Win",text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,1,10,tostring(count_pl1win),text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,2,10,tostring((count_pl1win/count_put)*100,'#.##'),text_color=color.white,bgcolor=#ff4a68)
    
    table.cell(_table,0,11,"Level 2 Win",text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,1,11,tostring(count_pl2win),text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,2,11,tostring((count_pl2win/count_put)*100,'#.##'),text_color=color.white,bgcolor=#ff4a68)
    
    table.cell(_table,0,12,"Level 3 Win",text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,1,12,tostring(count_pl3win),text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,2,12,tostring((count_pl3win/count_put)*100,'#.##'),text_color=color.white,bgcolor=#ff4a68)
    
    table.cell(_table,0,13,"Level4 Win",text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,1,13,tostring(count_pl4win),text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,2,13,tostring((count_pl4win/count_put)*100,'#.##'),text_color=color.white,bgcolor=#ff4a68)
    
    table.cell(_table,0,14,"Level 5 Win",text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,1,14,tostring(count_pl5win),text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,2,14,tostring((count_pl5win/count_put)*100,'#.##'),text_color=color.white,bgcolor=#ff4a68)
    
    table.cell(_table,0,15,"Total Put Profit",text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,1,15,tostring(count_pl1win+count_pl2win+count_pl3win+count_pl4win+count_pl5win),text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,2,15,tostring(((count_pl1win+count_pl2win+count_pl3win+count_pl4win+count_pl5win)/count_put)*100,'#.##'),
     text_color=color.white,bgcolor=#ff4a68)
    
    table.cell(_table,0,16,"Loss",text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,1,16,tostring(count_ploss),text_color=color.white,bgcolor=#ff4a68)
    table.cell(_table,2,16,tostring((count_ploss/count_put)*100,'#.##'),text_color=color.white,bgcolor=#ff4a68)
    
    table.cell(_table,0,17,"Profit in a row",text_color=color.white,bgcolor=#056b60)
    table.cell(_table,1,17,tostring(consecutive_profit),text_color=color.white,bgcolor=#056b60)
    table.cell(_table,2,17,tostring((consecutive_profit/(count_call+count_put))*100,'#.##'),text_color=color.white,bgcolor=#056b60)
    
    table.cell(_table,0,18,"Loss in a row",text_color=color.white,bgcolor=#c71c69)
    table.cell(_table,1,18,tostring(consecutive_loss),text_color=color.white,bgcolor=#c71c69)
    table.cell(_table,2,18,tostring((consecutive_loss/(count_call+count_put))*100,'#.##'),text_color=color.white,bgcolor=#c71c69)
````
