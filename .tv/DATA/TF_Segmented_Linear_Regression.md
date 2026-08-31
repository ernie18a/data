<!-- tradingview-pine-id: PUB;NXPkhxTebtMHkGhrl7XAljXtkTUta9e2 -->
<!-- tradingviewscripts-format: 1 -->
# TF Segmented Linear Regression

Source: https://www.tradingview.com/script/FGvtpiFR-TF-Segmented-Linear-Regression/

## Description

Fit a line at successive intervals, where the interval period is determined by a user-selected time frame, this allows the user to have an estimate of the intrinsic trend within various intervals.

Settings

[*]Timeframe : Determine the period of the interval, if the timeframe is weekly then a new line will be fit at the start each weeks, by default "Daily" 
[*]Mult : Multiplication factor for the RMSE, determine the distance between the upper and lower extremities
[*]Src : Input data for the indicator
[*]Plot Extremities : Logical value, if true then the extremities of the channel are plotted, if false only the midline is plotted, true by default.

Usage

The timeframe setting should be higher than the current chart timeframe, note however that too large values of timeframe might return an error. Since the maximum number of lines that can be plotted is 54, using the extremities will only return 18 channels. 

The indicator can be compared to the "regression trend" drawing tool

[image]https://www.tradingview.com/x/KkvwNfCD/[/image]

Main tf = 5 min with the indicator using a daily timeframe, the filled area is produced by the regression trend drawing tool using the same interval as the indicator, and coincide with it.

[image]https://www.tradingview.com/x/00ntdHiO/[/image]

Main tf = 15 min with the indicator using a weekly timeframe, wider channel indicate that the values tend to be farther away from the fitted line. 

A line with a significant slope indicates a strong trend, in that case, the width of the channel is determined by the amplitude of the retracements in the trend, with a narrower channel indicating a cleaner trend.

When the fitted line has a low slope value and the channel is wide, it means that there were two or more variations of opposite directions with large amplitudes within the interval, this also indicates that a linear model is not appropriate.

A slope approximately equal to 0 with a low channel width indicates a trendless market with cyclical variations of low amplitude in it.

Refrences

Determining the starting and ending points of the fitted line was done using a linear combination between the wma and sma

https://www.tradingview.com/script/IXDiw4TP-Computing-The-Linear-Regression-Using-The-WMA-And-SMA/

The wma and sma functions both use a series as period by making use of the Wma and Sum functions in the following script

https://www.tradingview.com/script/kY5hhjA7-Functions-Allowing-Series-As-Length-PineCoders-FAQ/

---

## Source Code

````pine
// This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License https://creativecommons.org/licenses/by-sa/4.0/
// © alexgrover

//@version=4
study("TF Segmented Linear Regression","TFSLR",true)
timeframe = input("D",type=input.resolution)
mult      = input(2)
src       = input(close)
ext       = input(true,"Plot Extremities")
//------------------------------------------------------------------------------
n = bar_index
t = time(timeframe)
p = (barssince(change(t)) + 1)[1]
//------------------------------------------------------------------------------
Sum(src,p) => a = cum(src), a - a[max(p,0)]
Wma(src,p) => 
    mp = max(p,0)
    denom = mp*(mp+1)/2
    a = cum(src), (mp*a - Sum(a[1],p))/denom
a = Wma(src[1],p),b = Sum(src[1],p)/p
//------------------------------------------------------------------------------
A = 4*b-3*a,B = 3*a-2*b
m = (A - B)/(p-1)
d=0., for i = 0 to max(p-1,1)
    l = B + m*i
    d := d + pow(src[i+1]-l,2) 
rmse = sqrt(d/(p-1))*mult
//------------------------------------------------------------------------------
l(k,css)=>
    line lr = na
    if change(t)
        lr := line.new(n-p,A+k,n-1,B+k,
          color=css,width=2)
        line.delete(lr[1])
//------------------------------------------------------------------------------
if ext
    l(rmse,#2157f3),l(-rmse,#2157f3)
l(0,#ff1100)
````
