<!-- tradingview-pine-id: PUB;lMWUNZbLAxuhQ3Z7K8CozRwdlTjAvH4F -->
<!-- tradingviewscripts-format: 1 -->
# Trend Quality

Source: https://www.tradingview.com/script/jbEZftvb/

## Description

The quality of the current trend is calculated by adding or subtracting
one point to the total value depending on the following criteras:

1. EMA-8, MA-20, MA-50, MA-100, MA-200 , each get a point if they are increasing.
2. EMA-8 > MA-20 > MA-20 > MA-50 > MA-100 > MA-200 , each condition that is true gets one point.

On top of the Trend Quality value we apply a "weekly" (5 periods) and
a "monthly" (22 periods) moving average. 

When above a value of 5, a strong trend is indicated and hence
a trend following strategy should be used.

Use this to Buy when bouncing back from e.g MA-20 or a confirming
consolidation/candlestick/trendline pattern.

When the trend decreases below Zero a trend shift may have occured.

Idea, curtesy: Tobbe Rosèn

---

## Source Code

````pine
//@version=4
//
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © kruskakli
//
// The quality of the current trend is calculated by adding or subtracting
// one point to the total value depending on the following criteras:
//
// 1. EMA-8, MA-20, MA-50, MA-100, MA-200 , each get a point if they are increasing.
// 2. EMA-8 > MA-20 > MA-50 > MA-100 > MA-200 , each condition that is true gets one point.
// 3. The current stock price is at least 30 percent above its 52-week low, gets one point
// 4. The current stock price is within at least 25 percent of its 52-week high, gets one point.
// 5. The 200-day moving average line is trending up for at least 1 month (preferably 4–5 months), gets one point.
// 6. Close > MA-50
//
// On top of the Trend Quality value we apply a "weekly" (5 periods) and
// a "monthly" (22 periods) moving average. 
//
// When above a value of 9, a strong trend is indicated and hence
// a trend following strategy should be used.
// Use this to Buy when bouncing back from e.g MA-20 or a confirming
// consolidation/candlestick/trendline pattern.
// When the trend decreases below Zero a trend shift may have occured.
//
// Idea, curtesy: Tobbe Rosèn and Mark Minervini
//
// ( http://www.minervini.com/blog/index.php/blog/show/first_things_first_how_to_chart_stocks_correctly_and_increase_your_chances )
//
study("Trend Quality", overlay=false)

src = close

ema8 = ema(src, 8)
ma20 = sma(src, 20)
ma50 = sma(src, 50)
ma100 = sma(src, 100)
ma200 = sma(src, 200)

week = security(syminfo.tickerid, "W", close)
week52low = lowest(week, 52)
week52high = highest(week, 52)

float monotonic = na
monotonic := (ma200[0] > ma200[1]) ? 1 :0

int tq = 0
calc_tq_direction(_src, _tq) =>
    if (_src[0] > _src[1])
        _tq + 1
    else
        _tq - 1

tq_gt(_s1, _s2, _tq) =>
    if (_s1 > _s2)
        _tq + 1
    else
        _tq - 1

tq := calc_tq_direction(ema8, tq)
tq := calc_tq_direction(ma20, tq)
tq := calc_tq_direction(ma50, tq)
tq := calc_tq_direction(ma100, tq)
tq := calc_tq_direction(ma200, tq)

tq := tq_gt(ema8, ma20, tq)
tq := tq_gt(ma20, ma50, tq)
tq := tq_gt(ma50, ma100, tq)
tq := tq_gt(ma100, ma200, tq)

// Rule 3
tq := (close * 1.3) > week52low ? tq + 1 : tq

// Rule 4
tq := close > (week52high * 0.75) ? tq + 1 : tq

// Rule 5 (using 50 days, i.e 10 weeks or 2.5 months)
tq := (sum(monotonic, 50) == 50) ? tq + 1 : tq

// Rule 6
tq := close > ma50 ? tq + 1 : tq


tq5 = sma(tq, 5)
tq22 = sma(tq, 22)

plot(tq,   title="TQ",   color=color.gray)
plot(tq5,  title="TQ5",  color=color.yellow)
plot(tq22, title="TQ22", color=color.blue)

hline(9.0 , color=color.gray)
hline(-9.0 , color=color.gray)
````
