# Jurik Moving Average Crossover Strategy [ChuckBanger]

- url: https://www.tradingview.com/script/pM6FkCHY-Jurik-Moving-Average-Crossover-Strategy-ChuckBanger/
- type: indicator
- pine_id: PUB;4CT8dCEqhuMzcpURG1FYKqB525WADKvW
- version: 1.0

## Description

The classic moving average crossover strategy does not work well in markets that, instead of trending, tend to frequently reverse within a trading range. The lag between the actual time the market has reversed direction and when the moving average is signalling a trade, the trend is already over and the market is about to go against your position. In this environment, a more appropriate trading strategy is suggested here using an JMA Keltner Channel.

The idea is to create a channel based of support and resistance. When the market breaks out of the channel, and fails to maintain momentum. It is likely the price will fall back toward the center of the channel. This tendency can be exploited in the following manner.

[image]https://www.tradingview.com/x/XSrqMXPu/[/image]
In the chart above, The aqua and maroon (center line) and the blue lines are part of a channel. The middle line is a slow running JMA of the closing prices, with Length = 30 and phase = 0. The upper blue band is constructed by adding 1.5 times of 30-bar ATR (average true range) to the center JMA line and the lower blue band by deducting the same amount. There is a grey line running through the data- That is a fast running JMA with length = 5 and phase = 100 representing the price.

The red dots indicate that the the price is going back in the channel and the market is retracting from a failed upward breakout, and the green dots mark when price is retracting from a failed downward breakout. These are places where one might want to enter the trade. The orange dots indicate where price crosses the center line, a reasonable place to take profit from or even exit the trade.

The center line also shows the up or down movements if the setting is ticked. This feature is useful to use when exit a trade. For example, you enter a long position on a green dot signal and the color is maroon. You can wait for 3-5 candles (depending of markets). And if the color doesn’t change it can be an indication that the price is going lower.  Here it is possible to switch to a short possible or the opposite apply if you enter on a red dot.

The parameter use in this study is for demonstrating purposes only.  This is to show how you can use JMA. Do not trade with real money without thoroughly test the strategy. And always use stop-losses.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChuckBanger

//@version=4
study("Jurik Moving Average Crossover Strategy [ChuckBanger]", shorttitle="JMAC CB", overlay=true)
length = input(title="Length", type=input.integer, defval=30)
phase = input(title="Phase", type=input.integer, defval=0)
power = input(title="Power", type=input.integer, defval=2)
src = input(title="Source", type=input.source, defval=close)
highlight = input(title="Highlight Up/Down", type=input.bool, defval=true)

atrLength = input(title="ATR Length", type=input.integer, defval=30)
mult = input(title="ATR Multiplyer", type=input.float, defval=1.5)

fastLength = input(title="Fast Length", type=input.integer, defval=5)
fastPhase = input(title="Fast Phase", type=input.integer, defval=100)
fastPower = input(title="Fast Power", type=input.integer, defval=2)

calc_jma(_src, _length, _phase, _power) =>
    phaseRatio = _phase < -100 ? 0.5 : _phase > 100 ? 2.5 : _phase / 100 + 1.5
    
    beta = 0.45 * (_length - 1) / (0.45 * (_length - 1) + 2)
    alpha = pow(beta, _power)
    
    e0 = 0.0,e0 := (1 - alpha) * _src + alpha * nz(e0[1])
    
    e1 = 0.0,e1 := (_src - e0) * (1 - beta) + beta * nz(e1[1])
    
    jma = 0.0, e2 = 0.0,e2 := (e0 + phaseRatio * e1 - nz(jma[1])) * 
       pow(1 - alpha, 2) + pow(alpha, 2) * nz(e2[1])
    
    jma := e2 + nz(jma[1])
    jma

jma = calc_jma(src, length, phase, power)
jmaColor = highlight ? jma > jma[1] ? color.aqua : color.maroon : color.blue
plot(jma, title="JMA", linewidth=2, color=jmaColor, transp=0)

atr_ = atr(atrLength)
upper = jma + (atr_ * mult)
lower = jma - (atr_ * mult)
plot(upper)
plot(lower)

fastJma = calc_jma(src, fastLength, fastPhase, fastPower)

plot(fastJma, color=color.gray)

plot(cross(fastJma, jma) ? jma : na, style=plot.style_circles, linewidth=5, color=color.orange, title='JMA crosses', transp=0)
plot(crossunder(fastJma, upper) ? upper + (atr_/4) : na, style=plot.style_circles, linewidth=5, color=color.red, title='JMA Upper crossunder', transp=0)
plot(crossover(fastJma, lower) ? lower - (atr_/4) : na, style=plot.style_circles, linewidth=5, color=color.lime, title='JMA Lower crossover', transp=0)
````
