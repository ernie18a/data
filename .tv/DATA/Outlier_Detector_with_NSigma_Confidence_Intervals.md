<!-- tradingview-pine-id: PUB;WmROfgArR55ZPxo83XveLqxzUfseBUVG -->
<!-- tradingviewscripts-format: 1 -->
# Outlier Detector with N-Sigma Confidence Intervals

Source: https://www.tradingview.com/script/6QX7rznd-Outlier-Detector-with-N-Sigma-Confidence-Intervals/

## Description

A detrended series that oscilates around zero is obtained after first differencing a time series (i.e. subtracting the closing price for a candle from the one immediately before, for example). Hypothetically, assuming that every detrended closing price is independent of each other (what might not be true!), these values will follow a normal distribution with mean zero and unknown variance sigma squared (assuming equal variance, what is also probably not true as volatility changes over time for different pairs). After studentizing, they follow a Student's t-distribution, but as the sample size increases (back periods > 30, at least), they follow a standard normal distribution.

This script was developed for personal use and the idea is spotting candles that are at least 99% bigger than average (using N = 3) as they will cross the upper and lower confidence interval limits. N = 2 would roughly provide a 95% confidence interval.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tvjvzl

//@version=4

study("Outlier Detector with N-Sigma Confidence Intervals")
source = input(close)
dif = source - source[1]
periods = input(30, title = "Sample size - Back periods for std. deviation estimate") + 1

//Unbiased standard deviation estimator
std = sqrt((sum(pow(dif, 2), periods) - pow(dif[0], 2))/(periods - 2))

//Z-score
z = dif/std

//Plot
c = sign(z) == 1 ? #22ab94:#ec407a
plot(abs(z), color=color.new(c, 0), title = "Series", linewidth=1, style = plot.style_columns)
hline(input(2, "First limit"), color=color.new(#959595, 0), title = "First limit")
hline(input(3, "Second limit"), color=color.new(#959595, 0), title = "Second limit")
````
