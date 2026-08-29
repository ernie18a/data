<!-- tradingview-pine-id: PUB;0E5VPtfiMH6Yv2Kztk4UzRTXzpmpBgoq -->
<!-- tradingviewscripts-format: 1 -->
# Linear Correlation Oscillator

Source: https://www.tradingview.com/script/94xv1HSx-Linear-Correlation-Oscillator/

## Description

You don't need loops to get the rolling correlation between an input series and a linear sequence of values, this can be obtained from the normalized difference between a WMA and an SMA of the input series.

The closed-form solutions for the moving average and standard deviation of a linear sequence can be easily calculated, while the same rolling statistics for the input series can be computed using cumulative sums. All these concepts were introduced in previous indicators posts long ago. 

This approach can allow to efficiently compute the rolling R-Squared of a linear regression, as well as its SSE. 

Using the rolling correlation as a trend indicator is often attributed to John Ehlers with the correlation trend indicator (Correlation As A Trend Indicator), but the applications of this precise method can be traced back quite a while ago by a wide variety of users, in fact, the LSMA can be computed using this precise indicator. You can see an example where the correlation oscillator appears below:

https://www.tradingview.com/script/Te01hBsi-Logistic-Correlation/

---

## Source Code

````pine
//@version=4
study("Linear Correlation Oscillator","LCO")
length = input(14),src = input(close)
//----
cmla=0.,cmlb=0.,cmlc=0.
cmla := nz(cmla[1]) + src
cmlb := nz(cmlb[1]) + cmla
cmlc := nz(cmlc[1]) + src*src
//----
sum = cmlb - cmlb[length]
a = (length*cmla-sum[1])
b = cmla - cmla[length]
c = cmlc - cmlc[length]
//----
num = (a - b*(length+1)/2)/length
vary = c/length - pow(b/length,2)
var varx = (length*length - 1)/12
cor = num/sqrt(vary*varx)
//----
plot(cor,"ROsc",#2157f3)
````
