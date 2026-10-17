# BO - RSI - M5 Backtesting

- url: https://www.tradingview.com/script/FXzxRacV/
- type: strategy
- pine_id: PUB;LggetWU0Cs4f2xTlLrkS6DwGttXwtLO7
- version: 2.0

## Description

BO - RSI  - M5 Backtesting -Rule of Strategy

A. Data
1. Chart M5 IDC
2. Symbol: EURJPY

B. Indicator
1. RSI
2. Length: 12 (adjustable)
3. Extreme Top: 75 (adjustable)
4. Extreme Bottom: 25 (adjustable)

C. Rule of Signal
1. Put Signal
* Rsi create a temporary peak over Extreme Top
row61: peak_rsi= rsi[2]>rsi[3] and rsi[1]>rsi[2] and rsi[0]<rsi[1] and rsi[1]>rsi_top
2. Call Signal
* Rsi create a temporary bottom under Extreme Bottom
row62: bott_rsi= rsi[2]<rsi[3] and rsi[1]<rsi[2] and rsi[0]>rsi[1] and rsi[1]<rsi_bot

D. Rule of Order
1. Only 1 trade opening
2. Stoploss: No trade open after 1 loss trade each day (number of loss trades adjustable)
3. Expiry: after 6 bars  (number of bars adjustable)

## Source Code

````pine
// BO - RSI - M5 Backtesting
// © inno14
//@version=4
strategy("BO - RSI - M5 Backtesting")
//strategy.risk.max_intraday_loss(1, strategy.cash)
// === INPUT PERIOD OF TIME ===
Date   = input(true, title = "=== Date Option ===")
FromDay   = input(defval = 1, title = "From Day", minval = 1, maxval = 31)
FromMonth = input(defval = 1, title = "From Month", minval = 1, maxval = 12)
FromYear  = input(defval = 2020, title = "From Year", minval = 2017)

ToDay     = input(defval = 1, title = "To Day", minval = 1, maxval = 31)
ToMonth   = input(defval = 1, title = "To Month", minval = 1, maxval = 12)
ToYear    = input(defval = 9999, title = "To Year", minval = 2017)

// === DATE RANGE ===
start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)  // backtest start window
finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false // create function "within window of time"

// === Trading Time ===
CTimeDvM   = input(true, title = "=== Trading Time ===")
Time_zone = input(7,title="Time Zone")
FromHourDvM   = input(defval = 07, title = "From Hour", minval = 00, maxval = 23)
FromMinuteDvM = input(defval = 00, title = "From Minute", minval = 00, maxval = 59)
ToHourDvM   = input(defval = 18, title = "To Hour", minval = 00, maxval = 23)
ToMinuteDvM = input(defval = 00, title = "To Minute", minval = 00, maxval = 59)

GMT_FHDvM=FromHourDvM<Time_zone?FromHourDvM-Time_zone+24:FromHourDvM-Time_zone
GMT_THDvM=ToHourDvM<Time_zone?ToHourDvM-Time_zone+24:ToHourDvM-Time_zone
fhDvM= (GMT_FHDvM<10?"0"+tostring(GMT_FHDvM):tostring(GMT_FHDvM))
fmDvM= (FromMinuteDvM<10?"0"+tostring(FromMinuteDvM):tostring(FromMinuteDvM))
thDvM= (GMT_THDvM<10?"0"+tostring(GMT_THDvM):tostring(GMT_THDvM))
tmDvM= (ToMinuteDvM<10?"0"+tostring(ToMinuteDvM):tostring(ToMinuteDvM))
WorkingHourDvM = fhDvM+fmDvM+"-"+thDvM+tmDvM
t0_DvM = time(timeframe.period, WorkingHourDvM)
htrtime = input(true,title="Highlight Trading Time")
bgcolor(htrtime? t0_DvM? color.gray : na:na, title="Trading Time", transp=90)

//New trading time open
fh_ott= (GMT_FHDvM<10?"0"+tostring(GMT_FHDvM):tostring(GMT_FHDvM))
fm_ott= (FromMinuteDvM<10?"0"+tostring(FromMinuteDvM):tostring(FromMinuteDvM))
th_ott= fh_ott
tm_ott= (FromMinuteDvM+5<10?"0"+tostring(FromMinuteDvM+5):tostring(FromMinuteDvM+5))
trading_time_open = fh_ott+fm_ott+"-"+th_ott+tm_ott
t1 = time(timeframe.period, trading_time_open)

//RSI
rsi_tt=input(true,"=== RSI Option ===")
rsi_len=input(12,title="RSI Length")
rsi_top=input(75,title="RSI Extreme Top")
rsi_bot=input(25,title="RSI Extreme Bottom")
rsi=rsi(close,rsi_len)
plot(rsi, title="RSI", color=color.aqua, style=plot.style_line, linewidth=2, transp=20)
hline100=hline(100)
hline0=hline(0)
hline_top=hline(rsi_top)
hline_bot=hline(rsi_bot)

//peak & bottom
peak_rsi= rsi[2]>rsi[3] and rsi[1]>rsi[2] and rsi[0]<rsi[1] and rsi[1]>rsi_top
bott_rsi= rsi[2]<rsi[3] and rsi[1]<rsi[2] and rsi[0]>rsi[1] and rsi[1]<rsi_bot

//Put signal
x1=
       peak_rsi
       
       

//Call signal
y1=
       bott_rsi
       

no_orders =
       not strategy.opentrades

//Stoploss
var z=0
if t1
    z:=0
z:=z[1]+1
stop_tt=input(true,"== Stoploss Option By Loss Trade ===")
stop_val=input(1,"Number of intraday's loss trades",minval=0,step=1)
stop_loss=strategy.losstrades-strategy.losstrades[z]==stop_val

//Function
xTech=
       x1 
       and no_orders
       and (not stop_loss or stop_val==0)
    

yTech=
       y1 
       and no_orders
       and (not stop_loss or stop_val==0)


//plot Signal
putcol = xTech? color.red : na
callcol = yTech? color.blue : na
PutSignal= xTech and window() and t0_DvM?-0.3*100:na
CallSignal= yTech and window() and t0_DvM?-0.3*100:na
plotshape(PutSignal, title='Put', text="Put", style=shape.circle, location=location.absolute, color=color.red, textcolor=color.black, offset=1, transp=0, size=size.large)
plotshape(CallSignal, title='Call', text="Call", style=shape.circle, location=location.absolute, color=color.blue, textcolor=color.black, offset=1, transp=0, size=size.large)

//Backtesting
exp_tt=input(true,"=== Expiry Option By Bars ===")
exp_val=input(6,"Number of Bars")
strategy.entry("Call", strategy.long, when=yTech and window() and t0_DvM)
strategy.entry("Put", strategy.short, when=xTech and window() and t0_DvM)
strategy.close_all(when=barssince(xTech)==exp_val or barssince(yTech)==exp_val)

//Plot Analyzing Signals
hline2=hline(-1.0*100)
sigtext=
       xTech?"Put signal":yTech?"Call signal":
       " Backtesting From: "+tostring(FromDay)+"/"+tostring(FromMonth)+"/"+tostring(FromYear)+" To: "+tostring(ToDay)+"/"+tostring(ToMonth)+"/"+tostring(ToYear)
       + " * Trading Time From: "+tostring(FromHourDvM)+":"+tostring(FromMinuteDvM)+" To "+tostring(ToHourDvM)+":"+tostring(ToMinuteDvM)
sig_col=xTech?color.new(color.red,10):yTech?color.new(color.blue,10):color.new(color.navy,10)
label_sig_text = label.new(bar_index[0], -0.6*100, text=sigtext, style=label.style_none, textcolor=sig_col, size=size.large)
label.delete(label_sig_text[1])

infotext=
       "RSI Length: "+tostring(rsi_len)+" * RSI Extreme: "+tostring(rsi_top)+"/"+tostring(rsi_bot)
       +" * Stoploss after "+tostring(stop_val)+" loss trade(s) each day"
       +" * Expiry after "+tostring(exp_val)+" bar(s)"
info_col=color.new(color.navy,10)
label_info_text = label.new(bar_index[0], -0.8*100, text=infotext, style=label.style_none, textcolor=info_col, size=size.large)
label.delete(label_info_text[1])
//EOF
````
