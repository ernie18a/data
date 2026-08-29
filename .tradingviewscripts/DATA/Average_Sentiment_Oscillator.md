<!-- tradingview-pine-id: PUB;wQp1Q1Nvojs1mGEVwXfcPtgc0pdCwVRz -->
<!-- tradingviewscripts-format: 1 -->
# Average Sentiment Oscillator

Source: https://www.tradingview.com/script/hz1PKu3G/

## Description

Description of this indicator from its author:

Average Sentiment Oscillator

Momentum oscillator of averaged bull/bear percentages.

We suggest using it as a relatively accurate way to gauge the sentiment of a given period of candles, as a trend filter or for entry/exit signals.

It’s a combination of two algorithms, both essentially the same but applied in a different way. The first one analyzes the bullish/bearishness of each bar using OHLC prices then averages all percentages in the period group of bars (eg. 10) to give the final % value. The second one treats the period group of bars as one bar and then determines the sentiment percentage with the OHLC points of the group. The first one is noisy but more accurate in respect to intra-bar sentiment, whereas the second gives a smoother result and adds more weight to the range of price movement. They can be used separately as Mode 1 and Mode 2 in the indicator settings, or combined as Mode 0.

Original indicator idea from Benjamin Joshua Nash, converted from MT4 version

Usage:

The blue line is Bulls %, red line is Bears %. As they are both percentages of 100, they mirror each other. The higher line is the dominating sentiment. The lines crossing the 50% centreline mark the shift of power between bulls and bears, and this often provides a good entry or exit signal, i.e. if the blue line closes above 50% on the last bar, Buy or exit Sell, if the red line closes above 50% on the last bar, Sell or exit Buy. These entries are better when average volume is high.

It's also possible to see the relative strength of the swings/trend, i.e. a blue peak is higher than the preceding red one. A clear divergence can be seen in the picture as the second bullish peak registers as a lower strength on the oscillator but moved higher on the price chart. By setting up levels at the 70% and 30% mark the oscillator can also be used for trading overbought/oversold levels similar to a Stochastic or RSI. As is the rule with most indicators, a smaller period gives more leading signals and a larger period gives less false signals.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KivancOzbilgic

//@version=4
study("Average Sentiment Oscillator", shorttitle="ASO")
length=input(10,"Period?",minval=1,maxval=100)
mode=input(0,"Calculation Method:",minval=0,maxval=2)
intrarange=high-low
grouplow=lowest(low,length)
grouphigh=highest(high,length)
groupopen=open[length-1]
grouprange=grouphigh-grouplow
K1=intrarange==0 ? 1 : intrarange
K2=grouprange==0 ? 1 : grouprange
intrabarbulls=((((close-low)+(high-open))/2)*100)/K1
groupbulls=((((close-grouplow)+(grouphigh-groupopen))/2)*100)/K2
intrabarbears=((((high-close)+(open-low))/2)*100)/K1
groupbears=((((grouphigh-close)+(groupopen-grouplow))/2)*100)/K2
TempBufferBulls= mode==0 ? (intrabarbulls+groupbulls)/2 : mode==1 ? intrabarbulls : groupbulls
TempBufferBears= mode==0 ? (intrabarbears+groupbears)/2 : mode==1 ? intrabarbears : groupbears
ASOBulls=sma(TempBufferBulls,length)
ASOBears=sma(TempBufferBears,length)
plot(ASOBulls,color=color.blue,linewidth=2)
plot(ASOBears,color=color.red,linewidth=2)
````
