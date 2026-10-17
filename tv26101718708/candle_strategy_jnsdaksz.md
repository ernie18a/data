# Candle Strategy

- url: https://www.tradingview.com/script/JnSdAkSZ-Candle-Strategy/
- type: strategy
- pine_id: PUB;9624cfaa19d34a08a0516ebee9c284e7
- version: 1.0

## Description

This strategy is based candle count number also strategy analysis -

Rules for buy-
         1) choose Candle Number(Ex.-47) For Trade
         2)  Trade Sell if price is above high of day 1st candle that mean direction is upside
         3)  We are taking stop loss on lowest low of candle since day first candle to trade no.
         4)  close Trade at last bar of the day 
         5)  Trader Can Choose Trade Direction From input
         [image]https://www.tradingview.com/x/ZWeZWFrz/[/image]

Rules for Sell-
          1) Choose Candle Number(Ex.-47) For Trade
          2) Trade Sell if price is below low of day 1st candle that mean direction is downside
          3) We are taking stop loss on highest of candle since day first candle to trade no.
          4) close Trade at last bar of the day
          5) Trader Can Choose Trade Direction From input

Note - this strategy can be also use for static to understand which candle will make low/high of the day high chance Example in bank nifty 5 minutes chart candle no 47 have highest trade 
opportunity appear on long side ...this data is small based on 5000 previous bar ...

 Disclaimer:  market involves significant risks, including complete possible loss of funds. Consequently trading is not suitable for all investors and traders. By increasing leverage risk increases as well.With the demo account you can test any trading strategies you wish in a risk-free environment. Please bear in mind that the results of the transactions of the practice account are virtual, and do not reflect any real profit or loss or a real trading environment, whereas market conditions may affect both the quotation and execution

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © samscripter

//@version=5
strategy(title='Candle Strategy', overlay=true,max_labels_count=500,process_orders_on_close = true,max_lines_count = 500)

// choose trade Direction

var group_ch ="Choose Trade Direction Setting"

trade_dir = input.string("Both", title="Trade Direction",options=["Long", "Short", "Both"],group = group_ch)

// input into trading conditions
longOK  = trade_dir == "Long" or trade_dir == "Both"
shortOK = trade_dir == "Short" or trade_dir == "Both"


t = time('D')

var count_no =1


if t == t[1]
    count_no:=count_no+1

if ta.change(time('D'))!=0
    count_no:=1


// label 
text_color=input.color(color.blue,title="Text Color Input",group = "Choose Label Text Color Setting")

lv_index =close>open ?low :high
lv_loc   =close>open ?yloc.belowbar:yloc.abovebar

label.new(bar_index, lv_index, str.tostring(count_no), textcolor=text_color, style=label.style_none,yloc=lv_loc)

in_no =input.int(47,title = "Candle Number For trade",group = "Choose Candle For Trade")


cond =count_no==in_no

var hi_f =0.0
var lo_f =0.0

if ta.change(time('D'))!=0
    hi_f:=high
    lo_f:=low


var lo =0.0

if cond and close>hi_f and longOK
    lo:=math.min(low[1],low)    
    strategy.entry('El',strategy.long)
if cond and close<lo_f and shortOK
    strategy.entry('Es',strategy.short)


// get bar index first candle

var fir_cndle=0.0

if ta.change(time('D'))!=0
    fir_cndle:=bar_index


var low_valn=0.0
var i_val  =0.0
var line ln=na

if cond and close>hi_f and longOK
    low_valn:=low[1]
    for i=0 to bar_index-fir_cndle
        if low[i]<=low_valn
            low_valn:=low[i]
            i_val  :=i


var high_valn =0.0
var i_vah     =0.0
var line ln2  =na

if cond and close<lo_f and shortOK
    high_valn :=high[1]
    for i=0 to bar_index-fir_cndle
        if high[i]>=high_valn
            high_valn:=high[i]
            i_vah  :=i   


// ploting line 

if cond and close>hi_f
    ln:=line.new(bar_index[i_val],low_valn,bar_index+1,low_valn)
if cond and close<lo_f
    ln2:=line.new(bar_index[i_vah],high_valn,bar_index+1,high_valn,color=color.green)

// close on last bar 
if session.islastbar
    strategy.close('El')
    strategy.close('Es')



// stop loss 
if strategy.position_size>0
    strategy.exit('Xl',stop = low_valn,comment = "exit long")
if strategy.position_size<0
    strategy.exit('Xs',stop = high_valn,comment = 'exit short')
````
