# Bull Trend Filtered StochRSI (BTFS)

- url: https://www.tradingview.com/script/TpuQxPsx-Bull-Trend-Filtered-StochRSI-BTFS/
- type: strategy
- pine_id: PUB;0b79096ebfd6492bbe81e6361049d413
- version: 1.0

## Description

Ride Bull Trends Via Stochastic with Special Rules for Heavy Bullish Bias

TLDR: Long Only Trend Indicator Where you are always entered Long if the stochastic is over the lower band line and the price is above the Donchian Chanel high. Exit when Stochastic RSI is below the lower band. 

Indicators:
Filter = Trend/Bullish indicator is Donchian of ema(high) this is set as the highest ema(high, 6) in the last 30 candles. this can be adjusted to fit the market as desired. 
     **indicator prints green background when the filter condition is satisfied***

Entry Exit = enter when the Stoch RSI is above the given lower trend band. This value is set at 35 but can be adjusted according to risk tolerance and market conditions. 

Logic:

this indicator allows  a trader to be present during bullish/parabolic trends by only triggering if the close is > than the highest 6 candle average high over the last 30 candles. This filter requires the market to be in a generally bullish posture. If the market is in this condition the stochastic RSI indicator value offers a good gauge of price action and only goes significantly down if price trends below the average range of the rsi period. This filters out noise and keeps a trader from over trading on inconsequential corrections while responding fairly quickly to changes in general trend direction. the response is fast enough to produce an unprofitable amount of false signals if the bull market filter is not implemented. However when used in combination the signals return desirable results in bull trending markets.

Hope this Helps. Happy Trades. 
-Snarky Puppy

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SnarkyPuppy

//@version=5
strategy("Filtered Stoch", overlay=false, default_qty_value = 100, default_qty_type=strategy.percent_of_equity)

/////high filter...upper donchian channel of ema... or highest ema for a given amount of candles

filter_ema_len= input(6)
ema_donchian_len = input(30)

ema=ta.highest(ta.ema(high,filter_ema_len),ema_donchian_len)

////////////////////////basic stoch rsi with max val 100 and min val 0.. entry above lowerband preset 35

smoothK = input.int(7, "K", minval=1)
smoothD = input.int(4, "D", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthStoch = input.int(14, "Stochastic Length", minval=1)
src = input(close, title="RSI Source")
rsi1 = ta.rsi(src, lengthRSI)
k = math.min(100, math.max(0,ta.sma(ta.stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)))
d = math.max(math.min(ta.sma(k, smoothD),80),35)
plot(k, "K", color=#2962FF)
plot(d, "D", color=#FF6D00)
h0 = hline(80, "Upper Band", color=#787B86)
hline(50, "Middle Band", color=color.new(#787B86, 50))
lowerband=input(35)
h11 = hline(lowerband, "Lower Band", color=#787B86)
fill(h0, h11, color=color.rgb(33, 150, 243, 90), title="Background")

ematrend= close>ema ? 1 : 0

bgcolor(ematrend==1?color.rgb(76, 175, 79, 80):na)

longCondition = k>lowerband and ematrend==1
if (longCondition)
    strategy.entry("Up", strategy.long)

shortCondition =  ta.crossunder(k,lowerband)
if (shortCondition)
    strategy.close("Up", shortCondition)
````
