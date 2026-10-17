# Composite Index [TipsChain]

- url: https://www.tradingview.com/script/XwZ05NKL-Composite-Index-TipsChain/
- type: indicator
- pine_id: PUB;kCNcdxUzrelE5XZYAkf8yffVCp3EAB3k
- version: 2.0

## Description

This is a formula Ms Brown developed to identify divergence failures with in the RSI . This also highlights the horizontal support levels with in the indicator area.
The Composite Index study comprises 2 momentum indicators on the RSI which are smoothed using a moving average. Control of the upper and lower indicators can be used to adjust the periods represented by each through the Object Properties dialog box for the study.
The Composite Index is an oscillator that will warn when the RSI is failing to detect a price trend reversal by forming divergences with the RSI. It can be used in any time frame or market.

Usage: 
1. Check hidden and regular divergences on RSI+COMPOSITE_INDEX and PRICE+COMPOSITE_INDEX. 
2. After finding divergence wait for COMPOSITE_INDEX to cross under/over it's moving averages to trigger.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HoManVig

//@version=4
study(title="Composite Index [TipsChain]", shorttitle="Composite Index [TipsChain]")
src=input(defval=close,type=input.source,title="Source")
rsi_period=input(defval=14,title="RSI Period")
rsi_momentum_period=input(defval=9,title="Period Momentum Indicator Of RSI")
very_short_rsi_period=input(defval=3,title="Very short RSI")
sma_very_short_rsi_period=input(defval=3,title="Simple moving Averages For Smoothing Slightly 'Very Short RSI'")
sma_composite_fast_period=input(defval=13,title="Smooth Fast Composite Index")
sma_composite_slow_period=input(defval=33,title="Smooth Slow Composite Index")
//Step 1 : create a 9-period momentum indicator of 14-period RSI. Yes, it is momentum on RSI , not price. This is an indicator on an indicator.
rsi=rsi(src,rsi_period)
rsi_momentum=rsi(rsi,rsi_momentum_period)
//Step 2: create a very short3-period RSI and then a simple 3-period moving average of the 3-period RSI to smooth is Slightly.
very_short_rsi=rsi(src,very_short_rsi_period)
smooth_very_short_rsi=sma(very_short_rsi,sma_very_short_rsi_period)
//Step 3: add Step 1 and 2 together to create the Composite Index.
composite_index=rsi_momentum+smooth_very_short_rsi
//Step 4: Create two simple moving averages of the Composite Index using the period 13 and 33.
sma_composite_fast=sma(composite_index,sma_composite_fast_period)
sma_composite_slow=sma(composite_index,sma_composite_slow_period)
//Step 5:plot the composite Index and its two simple averages as three lines in a separate frame under the price data.
GetColor(c,s,f)=>
     c>s and c>f ? #7e57c2 : c<s and c<f ? #c2185b : #ff9800
plot(composite_index,color=GetColor(composite_index,sma_composite_slow,sma_composite_fast),style=plot.style_line,linewidth=2,title="Composite Index")
plot(sma_composite_fast,color=color.green,style=plot.style_line,title="Composite Fast")
plot(sma_composite_slow,color=color.red,style=plot.style_line,title="Composite Slow")
````
