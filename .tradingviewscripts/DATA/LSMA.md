<!-- tradingview-pine-id: PUB;pxVKIpRWwp75bsQdMEw16ot0EuJbDLjV -->
<!-- tradingviewscripts-format: 1 -->
# LSMA

Source: https://www.tradingview.com/script/PcO280uj-LSMA-A-Fast-And-Simple-Alternative-Calculation/

## Description

Introduction

At the start of 2019 i published my first post "Approximating A Least Square Moving Average In Pine", who aimed to provide alternatives calculation of the least squares moving average (LSMA), a moving average who aim to estimate the underlying trend in the price without excessive lag. 

The LSMA has the form of a linear regression ax + b where x is a linear sequence 1.2.3..N and with time varying a and b, the exact formula of the LSMA is as follows :

a = stdev(close,length)/stdev(bar_index,length) * correlation(close,bar_index,length)
b = sma(close,length) - a*sma(bar_index,length)
lsma = a*bar_index + b

Such calculation allow to forecast future values however such forecast is rarely accurate and the LSMA is mostly used as a smoother. In this post an alternative calculation is proposed, such calculation is incredibly simple and allow for an extremely efficient computation of the LSMA.

Rationale

The LSMA is a FIR low-pass filter with the following impulse response :

[image]https://www.tradingview.com/x/yq65W93A/[/image]

The impulse response of a FIR filter gives us the weight of the filter, as we can see the weights of the LSMA are a linearly decreasing sequence of values, however unlike the linearly weighted moving average (WMA) the weights of the LSMA take on negative values, this is necessary in order to provide a better fit to the data. Based on such impulse response we know that the WMA can help calculate the LSMA, since both have weights representing a linearly decreasing sequence of values, however the WMA doesn't have negative weights, so the process here is to fit the WMA impulse response to the impulse response of the LSMA.

Based on such negative values we know that we must subtract the impulse response of the WMA by a constant value and multiply the result, such constant value can be given by the impulse response of a simple moving average, we must now make sure that the impulse response of the WMA and SMA cross at a precise point, the point where the impulse response of the LSMA is equal to 0.

[image]https://www.tradingview.com/x/Q16dnFgr/[/image]

We can see that 3WMA and 2SMA are equal at a certain point, and that the impulse response of the LSMA is equal to 0 at that point, if we proceed to subtraction we obtain :

[image]https://www.tradingview.com/x/ymVhNqKE/[/image]

Therefore :

LSMA = 3WMA - 2SMA = WMA + 2(WMA - SMA) 

Comparison

On a graph the difference isn't visible, subtracting the proposed calculation with a regular LSMA of the same period gives :

[image]https://www.tradingview.com/x/rgIKn6rI/[/image]

the error is 0.0000000...and certainly go on even further, therefore we can assume that the error is due to rounding errors.

Conclusion

This post provided a different calculation of the LSMA, it is shown that the LSMA can be made from the linear combination of a WMA and a SMA : 3WMA + -2SMA. I encourage peoples to use  impulse responses in order to estimate other moving averages, since some are extremely heavy to compute. 

Thanks for reading !

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alexgrover

//@version=4
study("LSMA",overlay=true)
length = input(25),src = input(close)
//----
a = 3*wma(src,length) - 2*sma(src,length)
plot(a,"LSMA",#ff9800,2,transp=0)
````
