# Risk to Reward - FIXED SL Backtester

- url: https://www.tradingview.com/script/uWMQ0vwN-Risk-to-Reward-FIXED-SL-Backtester/
- type: strategy
- pine_id: PUB;334d3e67500a45b7b2f3b7764c714803
- version: 1.0

## Description

[b]Don't know how to code? No problem! TradingView is an excellent platform for you.[/b] ✅ ✅

If you have an indicator that you want to backtest using a risk-to-reward ratio or fixed take profit/stop loss levels, then the [b]Risk to Reward - FIXED SL Backtester[/b] script is the perfect solution for you.

introducing [b]Risk to Reward - FIXED SL Backtester[/b] Script which will allow you to test any indicator / Signal with RR or Fixed SL system

How does it work ?! 

Once you connect the script to your indicator, it will analyze your entry points and perform calculations based on them. It will then open trades for you according to the specified inputs in the script settings.

[b]HOW TO CONNECT IT to your indicator? [/b]

simply open your indicator code and add the below line of code to it 
[i][b]plot(Signal ? 100 : 0,"Signal",display = display.data_window)[/b]
[/i]

[image]https://www.tradingview.com/x/bfpZnrqV/[/image]

Replace [b]Signal[/b] with the [i]long condition[/i] from your own indicator. You can also modify the value 100 to any number you prefer. After that, open the settings.

[image]https://www.tradingview.com/x/aJiIXV6k/[/image]

Once the script is connected to your indicator, you can choose from two options:

[list]
[*] Risk To Reward Ratio System
[*] Fixed TP/ SL System
[/list]

[image]https://www.tradingview.com/x/0lZJY2sp/[/image]

🔸if you select the Risk to Reward System ⤵️

The Risk-to-Reward System requires the calculation of a stop loss. That's why I have included three different types of stop-loss calculations for you to choose from:

[list]
[*] ATR Based SL 
[*] Pivot Low SL 
[*] VWAP Based SL
[/list]

[b]Your stop loss and take profit levels will be automatically calculated based on the selected stop loss method and your risk-to-reward ratio.[/b] 
You can also adjust their values to match your desired risk level. The trades will be displayed on the chart.

with the ability to change their values to match your risk.
once this is done, trades will be displayed on the chart 

🔸if you select the Fixed system ⤵️

You have 2 inputs, which are FIXED TP  & Fixed SL 
input the values you want, and trades will be on your chart... 


I have also added a Breakeven feature for you. 
with this Breakeven feature the trade will not just move SL to Entry ?! NO NO, it will place it above entry by a % you input yourself, so you always win! 🚀

[image]https://www.tradingview.com/x/mbshfAh3/[/image]

Here is an example 

[image]https://www.tradingview.com/x/w7c4k5X7/[/image]

Enjoy, and have fun, if you have any questions do not hesitate to ask

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TZack88

//@version=5
strategy(title='RR - FIXED SL Backtester', shorttitle='ZCrypto Backtester',overlay=true,pyramiding=1, initial_capital=10000,
   commission_type=strategy.commission.percent, commission_value=0.075,default_qty_value = 33, default_qty_type = strategy.percent_of_equity)
  
var float slVal                     = 0.0
float longTP                        = na
var float SL                        = na
float BreakevenTP                   = na
float BreakevenSL                   = na
var float TPlong                    = na
deal_start_condition                = false
var float long_sl_level             = na 
color bgray                         = color.rgb(128, 223, 236, 81)
color WHITE                         = color.rgb(210, 210, 210)
color red                           = color.rgb(163, 46, 46, 29)
color white                         = color.rgb(248, 248, 248, 14)
color olive                         = color.olive
color blue                          = color.rgb(23, 43, 77)
color Green                        = color.rgb(10, 218, 103, 34)
string core                         =  "➞ Main Core Settings 🔸"
string Breakeeven                   =  "➞ Breakeven Settings 🔸" 
string SLZ2                         =  "➞ TP/SL ( Risk System ) 🔸"
string RRS                          =  "➞ Risk to Reward 🔸"
string FTPS                         =  "➞ Fixed TP & SL 🔸"
string BES                          =  "➞ BreakEven Settings 🔸"
float smma                          = ta.sma(low,14)
string SLZ2TOOL                     = "Select Which risk system you wanna use ?! Risk to Reward or fixed system"
string RRT                          = "Your Risk to Reward Ratio ? 2:1 then put 2"
string _tooltip3                    = "Select external indicator plot"
string SLSelect                     = "Select the Stoploss Method"
float external_indicator            = input.source(defval=close, title='External indicator         ', group=core, tooltip=_tooltip3,inline = "00")
float deal_start_value              = input.int(defval=100, title='External Value               ', group=core, tooltip="Plot Value",inline = "01")
bool Risktype    				    = input.string('Risk To Reward', title = '   🌀 Risk Type',group=SLZ2,inline = "000",options = ['Risk To Reward', 'Fixed TP & SL'],tooltip = SLZ2TOOL) == 'Risk To Reward'
float RRTP                          = input.float(1.5, minval=0,step = 0.1,title="Risk To Reward Ratio",group=RRS,inline = "01",tooltip = RRT)
string stoploss                     = input.string("ATR SL", title="   ⬇️ Stoploss Type ", options=["ATR SL", "Pivot low", "VWAP SL"], group=RRS,inline = "02",tooltip = SLSelect)
float ATRSL                         = input.float(1.4,"         ATR Factor           ",step = 0.1,group = RRS,inline = "03",tooltip = "Only used with ATR SL")
int LB                              = input.int(8, minval=0,title="         Pivot Lookback     ",group=RRS,inline = "04",tooltip = "looks for lower low ,Only used with Pivot Low")
float VWAPSL                        = input.float(2.5,"         Vwap Multiplier    ",step = 0.1,group=RRS,inline = "05",tooltip = "Gets the SMMA value ,Only used with SMMA SL")
float FixedTP                       = input.float(1.5, minval=0,step = 0.1,title="Fixed TP",group=FTPS,inline = "01") / 100
float FixedSL                       = input.float(1.5, minval=0,step = 0.1,title="Fixed SL",group=FTPS,inline = "01") / 100

bool breakon                        = input.bool(true,"BreakEven ?" ,group = BES, inline="06",tooltip = "Breakeven w")
float breakRR                       = input.float(1.0, "      Risk To Reward Ratio",step = 0.1, group = BES, inline="07")
float BEper                         = input.float(0.1, "      Percent Above Entry",step = 0.1, group = BES, inline="08",tooltip="MUST be higher than '0'. This input front loads the new breakeven stop loss so that it is actually in profit.")/100




deal_start_condition := if external_indicator == deal_start_value
    true

//-----SL core calculation-----{
x2 = low - ta.rma(ta.tr(true), 14) * ATRSL
stopLong =  ta.lowest(low,LB)

vwap = math.sum(ta.vwap(ta.tr(true)),14) * volume
volumz = math.sum(volume,14)
atr_vwap_volume = math.abs(vwap / volumz)
longstoploss = low - atr_vwap_volume * VWAPSL
//}

// Lets get the SL and return it 
my_stop() =>
    switch stoploss
        "ATR SL" => x2
        "Pivot low" => stopLong
        "SMMA SL" => longstoploss
sl = Risktype ? my_stop() : close  * (1 - FixedSL)


// lets set the SL , TP Values

if deal_start_condition and strategy.position_size == 0
    slVal:= sl
else
    slVal:= slVal    

longDiffSL = math.abs(close - slVal)
longTP := deal_start_condition and strategy.position_size == 0 ? Risktype ? close + (RRTP * longDiffSL) : close * (1 + FixedTP) : longTP[1]


// -- Backtest Date ?! {

limit_date_range = input.bool(title='Limit Date Range', defval=true, group='Backtest date range')
start_time  = input.time(defval=timestamp('01 Aug 2022 00:00 +0000'), title='Start Time', group='Backtest date range')
end_time    = input.time(defval=timestamp('31 Dec 2025 00:00 +0000'), title='End Time', group='Backtest date range')

in_date_range = true
if limit_date_range
    in_date_range := time >= start_time and time <= end_time
    
else
    in_date_range := true

//-- }

longCondition = (deal_start_condition== true) and strategy.position_size == 0

//Breakeven

BreakevenTP := longCondition ? close + (breakRR * longDiffSL) : BreakevenTP[1]
BREAKPLOT = strategy.position_size > 0 ? BreakevenTP : na
BreakevenSL := strategy.position_size > 0 ? strategy.position_avg_price * (1 + BEper) :na
long_tp_hit = close >= BreakevenTP or high>= BreakevenTP
long_sl_level := longCondition  ? slVal : long_tp_hit ? BreakevenSL: long_sl_level[1]


if (in_date_range and longCondition)
    strategy.entry("LONG", strategy.long )   

strategy.exit("Long 3","LONG", 
     limit=longTP,  
     stop=(breakon ? long_sl_level : slVal),
     comment_profit = "TP HIT",
     comment_loss = breakon ? "BE Close" : "Loss"
     )  
    

// PLOTS
SLplot =  strategy.position_size > 0 ? slVal : na
SSL = plot(SLplot, title='LONG STOP LOSS', linewidth=2, style=plot.style_linebr, color=red)
longPlotTP =  strategy.position_size > 0 ? longTP : na
TTP = plot(longPlotTP, title='LONG TAKE PROFIT', linewidth=2, style=plot.style_linebr, color=Green)
avg = plot( strategy.position_avg_price, style = plot.style_linebr,color=WHITE )
BREKEVENLINE = strategy.position_size > 0 ? long_sl_level : na 
plot(breakon ? BREKEVENLINE : na, 'AVG Price',color=color.white, style=plot.style_linebr,editable = false,linewidth = 2)
fill(TTP, avg, color = color.new(Green,80))
fill(avg, SSL, color =color.new(red,80))
````
