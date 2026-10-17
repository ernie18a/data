# BTC Trend

- url: https://www.tradingview.com/script/ulJ7XzWY/
- type: indicator
- pine_id: PUB;c679442bc0044e2e88ea41b408f21c51
- version: 1.0

## Description

A simple trend-following indicator designed to identify bullish and bearish market regimes.
The indicator combines EMA trend structure, long-term market direction and momentum confirmation by integrating the RSI. 

[b]Components:[/b]
EMA 21 vs EMA 55
short- to medium-term trend direction

[b]Price vs EMA 200[/b]
higher timeframe market trend

[b]RSI > 55[/b]
confirms bullish momentum strenght and helps reduce false signals


[b]Logic:[/b]
The indicator uses a scoring system:
bullish conditions add to a positive score
bearish conditions add to a negative score
a clear trend is only confirmed once enough conditions align. 

[b]Visuals:[/b]
Green background = bullish trend regime
Red background = bearish trend regime
Green triangle = start of a bullish trend
Red triangle = start of a bearish trend

[b]Best timeframes to use:[/b]
The indicator works best on the 4H timeframe and the 1D timeframe, but it can also be used on higher timeframes for macro trend analysis.

[i]This indicator is designed for trend identification, not precise entries or exits.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © georg2909

//@version=6
indicator("BTC Trend", overlay=true)

EMA21 = ta.ema(close, 21)
EMA55 = ta.ema(close, 55)
EMA200 = ta.ema(close, 200)
RSI = ta.rsi(close, 14)

//score
score = 0
score += EMA21 > EMA55  ? 1 : -1
score += close > EMA200 ? 1 : -1
score += RSI > 55       ? 1 : -1

//trend
var int trend = 0
if score >= 2
    trend :=1
else if score <= -2
    trend := -1
else
    trend := trend[1]

bullSignal = trend == 1 and trend[1] !=1
bearSignal = trend == -1 and trend[1] != -1

bgcolor(trend == 1 ? color.new(color.green, 90) : trend == -1 ? color.new(color.red, 90) : na)

plotshape(bullSignal, title="Bullish Trend", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)

plotshape(bearSignal, title="Bearish Trend", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

plot(EMA21,  "EMA 21",  color=color.orange, linewidth=1)
plot(EMA55,  "EMA 55",  color=color.blue,   linewidth=1)
plot(EMA200, "EMA 200", color=color.white,  linewidth=2)
````
