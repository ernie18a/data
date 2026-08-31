<!-- tradingview-pine-id: PUB;cJORF9RciA2yjuVqrJO5ovXKLpBfS1JP -->
<!-- tradingviewscripts-format: 1 -->
# Congestion Index by Katsanos

Source: https://www.tradingview.com/script/V7e88j8Y/

## Description

CONGESTION INDEX
Market movements can be characterized by two distinct types or phases. In the ﬁrst, the market shows trending movements which have a directional bias over a period of time. The second type of market behavior is periodic or cyclic motion, where the market shows no consistent directional bias and trades between two levels. This type of market results in the failure of trend-following indicators and the success of overbought/oversold oscillators. Both phases of the market require the use of different types of indicator. Trending markets need trend-following indicators such as moving averages, moving average convergence/divergence (MACD), and so on. Trading range markets need oscillators such as the relative strength index (RSI) and stochastics, which use overbought and oversold levels. The age-old problem for many trading systems is their inability to determine if a trending or trading range market is at hand. Trend-following indicators, such as the MACD or moving averages, tend to be whipsawed as markets enter a nontrending congestion phase. On the other hand, oscillators (which work well during trading range markets) are often too early to buy or sell in a trending market. Thus, identifying the market phase and selecting the appropriate indicators is critical to a system’s success. The congestion index attempts to identify the market’s character by dividing the actual percentage that the market has changed in the past x days by the extreme range according to the following formula:

Readings between+20 and−20indicate congestion or oscillating mode. Crossing over the 20 line from below indicates the start of a rising trend. Conversely, the start of a down turn is indicated by crossing under−20 from above. The CI can also be used as an overbought/oversold oscillator.

It was taken from İntermarket Trading Strategies book of by Markos Katsanos.Read the book.

D1:=Input(“DAYS IN CONGESTION”,1,500,15);
CI:=ROC(C,D1-1,%)/((HHV(H,D1)-LLV(L,D1))/(LLV(L,D1)+.01)+.000001);
Mov ( CI ,3,E)
(Copyright Markos Katsanos 2008)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ceyhun

//@version=4
study("Congestion Index by Katsanos",overlay=false)

//It was taken from İntermarket Trading Strategies book of by Markos Katsanos.
// D1:=Input(“DAYS IN CONGESTION”,1,500,15);
// CI:=ROC(C,D1-1,%)/((HHV(H,D1)-LLV(L,D1))/(LLV(L,D1)+.01)+.000001);
// Mov(CI,3,E)
// (Copyright Markos Katsanos 2008)

D1 = input(15, title="Days in Congestion")
Period = input(3,title="Moving Average")

CI = roc(close,D1-1)/((highest(high,D1)-lowest(low,D1))/(lowest(low,D1)+.01)+.000001)

dynamic_color = iff(CI>20,color.green,iff(CI<-20,color.red,color.gray))

plot(ema(CI,Period),title="Congestion Index",color=dynamic_color,style=plot.style_histogram)
plot(ema(CI,Period),title="Congestion Index",color=dynamic_color)

plot(20, color=color.green,title="Upper")
plot(-20, color=color.red,title="Lower")
````
