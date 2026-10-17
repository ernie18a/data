# Slope Rank Reversal

- url: https://www.tradingview.com/script/U1zwBsFt-Slope-Rank-Reversal/
- type: indicator
- pine_id: PUB;6b8748e832e74577bd423de5cb826ee4
- version: 1.0

## Description

This tool is designed to solve the fundamental problem of "buying low and selling high" by providing objective entry/exit signals based on momentum extremes and inflection points.

The System employs three core components:

Trend Detection (PSAR): The Parabolic SAR is used as a filter to confirm that a trend reversal or transition is currently underway, isolating actionable trade setups.

Dynamic Momentum Ranking: The indicator continuously measures the slope of the price action. This slope is then ranked against historical data to objectively identify when an asset is in an extreme state (overbought or oversold).

Signal Generation (Inflection Points):

Oversold/Buy: A 🟢 Green X is generated only when the slope ranking indicates the market is steeply negative (oversold), and the slope value begins to tick upwards (the inflection point), signaling potential mean reversion.

Overbought/Sell: A 🔴 Red X is generated only when the slope ranking indicates the market is steeply positive (overbought), and the slope value begins to tick downwards, signaling momentum exhaustion.

The core philosophy is simple: Enter only when the market is exhausted and has started to turn.

## Source Code

````pine
//@version=5
indicator(title="Slope Rank Reversal", shorttitle="Slope Rank", overlay=true)
start = input(0.02)
increment = input(0.02)
maximum = input(0.2)
psar = ta.sar(start, increment, maximum)
trend = psar < close? 1 : -1

var len = 1
len := trend != trend[1]? 1 : len[1]+1
ma = ta.ema(close,14)

slope = (ma - ma[len+1])/(len+1)
//plot(slope, color=color.black, display=display.status_line)
// plot(ma, color=color.black)  // overlay to see slope being measured

maxlen = math.min(100,last_bar_index-1)
up = ta.highest(slope,maxlen)
dn = ta.lowest(slope,maxlen)
rank = (slope-dn)/(up-dn)*10
plot(rank, display=display.status_line)

plotshape(rank>9 and rank<rank[1], title = 'top', style = shape.xcross, location = location.abovebar, color = color.red, size=size.tiny, display = display.pane)
plotshape(rank<1 and rank>rank[1], title = 'bottom', style = shape.xcross, location = location.belowbar, color = color.green, size=size.tiny, display = display.pane)
````
