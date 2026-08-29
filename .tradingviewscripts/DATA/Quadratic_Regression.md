<!-- tradingview-pine-id: PUB;rOpaAmnJktU92aBdbPMb1k4XZH6NbMXK -->
<!-- tradingviewscripts-format: 1 -->
# Quadratic Regression

Source: https://www.tradingview.com/script/uuDEajsI-Quadratic-Regression/

## Description

Fit a quadratic polynomial (parabola) to the last length data points by minimizing the sum of squares between the data and the fitted results. The script can extrapolate the results in the future and can also display the R-squared of the model. Note that this script is subject to some limitations (more in the "Notes" section).

Settings

[*]Length : Number of data points to use as input.
[*]Offset : Determine the number of past fitted values to be displayed, if 0 only the extrapolated values are displayed, if 55 only the past fitted values are displayed.
[*]Src : Input data of the indicator
[*]Show R2 : Determine if the value of the R-squared must be displayed, by default true.

Usage

When the underlying trend in the price is not linear, we might use more advanced models to estimate it, this is where using a higher-degree regression model might be required, as such a quadratic model (second-degree) is appropriate when the underlying trend is parabolic.

[image]https://www.tradingview.com/x/qm22JRIG/[/image]

Here we can see that the quadratic regression (in blue) offer a better fit than a linear one.

Another advantage of the quadratic regression is that a linear one will always have the same direction, that's not the case with the quadratic regression and as such, it is possible to forecast reversals.

[image]https://www.tradingview.com/x/7ZdAUYeg/[/image]

Above a linear regression (in red) and two quadratic regression (in blue) with both length = 54. Note that for the sake of clarity, the above image uses a quadratic regression to show all the past fitted values and another one to show all the forecasted values.

The R-Squared is also extremely useful when it comes to measuring the accuracy of the model, with values closer to 1 indicating that the model is appropriate, and thus suggesting that the underlying trend in the price is parabolic. The R-squared can also measure the strength of the trend.

Notes

The script uses the function line.new, as such only a maximum of 54 observations are displayed, getting more observations can be done by using an additional quadratic regression like we did in the previous section. Another thing is that line.new use xloc.bar_time, as such it is possible to observe some errors with the displayed results of the indicator, such as:

[image]https://www.tradingview.com/x/yxv6SryM/[/image]

This will happen when applying the indicator to symbols with session breaks, I apologize for this inconvenience and I'll try to find solutions. Note however that the indicator will work perfectly on cryptos. 

Summary

That's an indicator I really wanted to make, even if it is important to note that such models are rarely useful in stock markets, however it is more than possible to create a quadratic regression (with severe limitations) with pinescript.

Today I turn 21, while I should be celebrating I still wanted to share something with the community, it's also some kind of present to myself that tells me that I am a bit better at using pinescript than last year, and I am glad I could progress (instead of regress, regression, got it?). Thx a lot for reading!

---

## Source Code

````pine
// This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License https://creativecommons.org/licenses/by-sa/4.0/
// © alexgrover

//@version=4
study("Quadratic Regression",overlay=true)
length = input(54,maxval=54)
offset = input(27,maxval=55)
src    = input(close)
show   = input(true,"Show R2")
//------------------------------------------------------------------------------
n = bar_index
Var(x) => variance(x,length)
Cov(x,y) => sma(x*y,length) - sma(x,length)*sma(y,length)
//------------------------------------------------------------------------------
sma = sma(src,length)
varn = (pow(length,2)-1)/12
norm = Var(n*n)*varn-pow(Cov(n,n*n),2)
a = (Cov(n*n,src)*varn - Cov(n,src)*Cov(n,n*n))/norm
b = (Cov(n,src)*Var(n*n) - Cov(n*n,src)*Cov(n,n*n))/norm
c = sma - a*sma(n*n,length) - b*sma(n,length)
Q(x)=> a*pow(n+x,2) + b*(n+x) + c
//------------------------------------------------------------------------------
sse = 0.,sst = 0.
for i = 0 to length-1
    sse := sse + pow(src[i] - Q(-i),2)
    sst := sst + pow(src[i] - sma,2)
r2 = 1 - sse/sst
//------------------------------------------------------------------------------
line l = na
dt = round(time - time[1])
for i = 1-offset to 54-offset
    css = abs(i) > length ? na : #2157f3
    l := line.new(time+dt*i,Q(i),time+dt*(i+1),Q(i+1),
      xloc=xloc.bar_time,color=css,width=2)
line.delete(l[1])
//------------------------------------------------------------------------------
label la = na
min = min(offset,length+1)
transp = color.new(color.white, 100)
if show
    la := label.new(n[min],Q(-min),tostring(r2,"#.###")
      ,color=transp,style=label.style_label_up,textcolor=#2157f3)
    label.delete(la[1])
````
