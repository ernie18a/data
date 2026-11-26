# BTC Accumulation Signal

- url: https://www.tradingview.com/script/9T8Vt0hE/
- type: indicator
- pine_id: PUB;cb798b53aef54a9b998b1fa2c4b2b171
- version: 1.0

## Description

What does this indicator do?
It helps you find the best times to buy and sell Bitcoin for the long term. Instead of watching three separate indicators, this tool combines everything into one simple signal on your chart.
How does it work?
Three components run in the background and feed into one score:

EMA 50 & EMA 200 – is Bitcoin in an uptrend or downtrend?
RSI (21) – is Bitcoin overbought or oversold?
Volume – is there real buying or selling pressure behind the move?

When enough conditions are bullish the line turns green and a green diamond appears below the candle. When enough conditions are bearish the line turns red and a red diamond appears above the candle. Candle colors also change with the trend so you can see the market phase at a glance.
What you see on the chart:

🟡 Gold line = EMA 200 – your long term anchor
🟢 Green line = Bitcoin is in an uptrend
🔴 Red line = Bitcoin is in a downtrend
🟢 Green diamond = good time to accumulate / buy
🔴 Red diamond = good time to take profits / sell

Best timeframe: Daily (1D) and 3-Day (3D)
Best asset: Bitcoin (BTC) – works best on longer timeframes and may need parameter adjustment for other assets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © raphael_lor
//@version=6
indicator("BTC Accumulation Signal", shorttitle="BTC.ACC", overlay=true)

// Get user input
src    = input.source(title="Source",   defval=close)
fast   = input.int(title="EMA Fast",   defval=50)
slow   = input.int(title="EMA Slow",   defval=200)
rsiLen = input.int(title="RSI Length", defval=21)
volLen = input.int(title="Volume MA",  defval=30)

// Calculate
emaFast = ta.ema(src, fast)
emaSlow = ta.ema(src, slow)
rsi     = ta.rsi(src, rsiLen)
volMA   = ta.sma(volume, volLen)

score  = 0
score += src > emaFast  ?  1 : -1
score += src > emaSlow  ?  1 : -1
score += rsi > 70       ? -2 : rsi < 50 ? 1 : -1
score += volume > volMA ?  1 : -1

var int trend = 0
if score >= 2
    trend := 1
else if score <= -2
    trend := -1
else
    trend := trend[1]

// Detect buy and sell signals
buySignal  = trend ==  1 and trend[1] != 1
sellSignal = trend == -1 and trend[1] != -1

// Draw data to chart
plot(emaFast, title="EMA Fast", color=trend == 1 ? color.green : trend == -1 ? color.red : color.gray, linewidth=2)
plot(emaSlow, title="EMA Slow", color=#C8960C, linewidth=2)
barcolor(trend == 1 ? color.green : trend == -1 ? color.red : na)
plotshape(buySignal,  title="Buy",  style=shape.diamond, location=location.belowbar, color=color.green, size=size.normal)
plotshape(sellSignal, title="Sell", style=shape.diamond, location=location.abovebar, color=color.red,   size=size.normal)

// Trigger alerts
alertcondition(buySignal,  "BTC Buy",  "BTC Accumulation: Buy Signal!")
alertcondition(sellSignal, "BTC Sell", "BTC Accumulation: Sell Signal!")
````
