# Intelligent Moving Average

- url: https://www.tradingview.com/script/aT9ck5ua/
- type: indicator
- pine_id: PUB;8Okir6vh6D9gBjrdjcPBJvMfALOaD8T3
- version: 2.0

## Description

For 4 simple moving averages, the script tests every single combination for maximum profitability and finds the best pair. 

Combinations: 
sma1 and sma2, 
sma1 and sma3, 
sma1 and sma4, 
sma2 and sma3, 
sma2 and sma4, 
sma3 and sma4 

And then paint the pair which get best performance. sma lengths are optional, so you can change lengths as you wish. 

You will see in some charts that for example sma1 and sma2 pair was best perfrmance and colored on the chart but then sma2 and sma3 pair got better performance, so script starts to paint sma2 and sma3. so it's dynamic based on best performance. 

keep in mind => length1 < length2 < length3 < length4 will be better 


I didn't have enough time to test the script, so please comment when you test it. 



by LonesomeTheBlue

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeThelime

//@version=4
study("Intelligent Moving Average", overlay = true)
src = input(close, title="Source")
len1 = input(8, title = "SMA 1 length", minval=1)
len2 = input(13, title = "SMA 2 length", minval=1)
len3 = input(21, title = "SMA 3 length", minval=1)
len4 = input(34, title = "SMA 4 length", minval=1)
srcprofit = input(ohlc4, title="Source for Profit Calculation")
fee = input(0.1, title="Fee (0.1 means %0.1=>0.001)", type = input.float, minval=0.0001)
s1 = sma(src, len1)
s2 = sma(src, len2)
s3 = sma(src, len3)
s4 = sma(src, len4)

feecalc =0.0
feecalc := 1 - (fee / 100)

// yuk => profit
// kaz => total profit (without fee)
yuk = 0., yuk1 = 0., yuk2 = 0., yuk3 = 0., yuk4 = 0., yuk5 = 0.
kaz = 0., kaz1 = 0., kaz2 = 0., kaz3 = 0., kaz4 = 0., kaz5 = 0.
yuk := crossover(s1, s2) or crossunder(s1, s2)? srcprofit : yuk[1]
kaz := nz(kaz[1]) + (crossunder(s1, s2) ? (yuk - yuk[1]) - (yuk[1]*feecalc) : (crossover(s1, s2) ? (yuk[1] - yuk) - (yuk*feecalc) : 0))

yuk1 := crossover(s1, s3) or crossunder(s1, s3)? srcprofit : yuk1[1]
kaz1 := nz(kaz1[1]) + (crossunder(s1, s3) ? (yuk1 - yuk1[1]) - (yuk1[1]*feecalc) : (crossover(s1, s3) ? (yuk1[1] - yuk1) - (yuk1*feecalc) : 0))

yuk2 := crossover(s1, s4) or crossunder(s1, s4)? srcprofit : yuk2[1]
kaz2 := nz(kaz2[1]) + (crossunder(s1, s4) ? (yuk2 - yuk2[1]) - (yuk2[1]*feecalc) : (crossover(s1, s4) ? (yuk2[1] - yuk2) - (yuk2*feecalc) : 0))

yuk3 := crossover(s2, s3) or crossunder(s2, s3)? srcprofit : yuk3[1]
kaz3 := nz(kaz3[1]) + (crossunder(s2, s3) ? (yuk3 - yuk3[1]) - (yuk3[1]*feecalc) : (crossover(s2, s3) ? (yuk3[1] - yuk3) - (yuk3*feecalc) : 0))

yuk4 := crossover(s2, s4) or crossunder(s2, s4)? srcprofit : yuk4[1]
kaz4 := nz(kaz4[1]) + (crossunder(s2, s4) ? (yuk4 - yuk4[1]) - (yuk4[1]*feecalc) : (crossover(s2, s4) ? (yuk4[1] - yuk4) - (yuk4*feecalc) : 0))

yuk5 := crossover(s3, s4) or crossunder(s3, s4)? srcprofit : yuk5[1]
kaz5 := nz(kaz5[1]) + (crossunder(s3, s4) ? (yuk5 - yuk5[1]) - (yuk5[1]*feecalc) : (crossover(s3, s4) ? (yuk5[1] - yuk5) - (yuk5*feecalc) : 0))

col1 = color.red
col2 = color.red
col3 = color.red
col4 = color.red

a1 = 0
if kaz>kaz1 and kaz>kaz2 and kaz>kaz3 and kaz>kaz4 and kaz>kaz5
    col1:=color.lime
    col2:=color.red
    col3:=na
    col4:=na
    a1 := crossover(s1, s2) ? 1 : crossunder(s1, s2) ? -1 : 0

a2 = 0
if kaz1>kaz and kaz1>kaz2 and kaz1>kaz3 and kaz1>kaz4 and kaz1>kaz5
    col1:=color.lime
    col2:=na
    col3:=color.red
    col4:=na
    a2 := crossover(s1, s3) ? 1 : crossunder(s1, s3) ? -1 : 0

a3=0
if kaz2>kaz and kaz2>kaz1 and kaz2>kaz3 and kaz2>kaz4 and kaz2>kaz5
    col1:=color.lime
    col2:=na
    col3:=na
    col4:=color.red
    a3 := crossover(s1, s4) ? 1 : crossunder(s1, s4) ? -1 : 0

a4=0
if kaz3>kaz and kaz3>kaz1 and kaz3>kaz2 and kaz3>kaz4 and kaz3>kaz5
    col1:=na
    col2:=color.lime
    col3:=color.red
    col4:=na
    a4 := crossover(s2, s3) ? 1 : crossunder(s2, s3) ? -1 : 0

a5=0
if kaz4>kaz and kaz4>kaz1 and kaz4>kaz2 and kaz4>kaz3 and kaz4>kaz5
    col1:=na
    col2:=color.lime
    col3:=na
    col4:=color.red
    a5 := crossover(s2, s4) ? 1 : crossunder(s2, s4) ? -1 : 0

a6=0
if kaz5>kaz and kaz5>kaz1 and kaz5>kaz2 and kaz5>kaz3 and kaz5>kaz4
    col1:=na
    col2:=na
    col3:=color.lime
    col4:=color.red
    a6 := crossover(s3, s4) ? 1 : crossunder(s3, s4) ? -1 : 0

plot(s1, color=col1, linewidth = 2)
plot(s2, color=col2, linewidth = 2)
plot(s3, color=col3, linewidth = 2)
plot(s4, color=col4, linewidth = 2)
plotarrow(a1)
plotarrow(a2)
plotarrow(a3)
plotarrow(a4)
plotarrow(a5)
plotarrow(a6)
````
