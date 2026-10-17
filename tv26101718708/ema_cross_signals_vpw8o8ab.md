# EMA Cross Signals 

- url: https://www.tradingview.com/script/VPw8O8aB-EMA-Cross-Signals/
- type: indicator
- pine_id: PUB;44f06fb4d11c49279a34d43f7662cf0b
- version: 2.0

## Description

[b] EMA Cross Signals[/b] is a clean trend-following indicator designed to help traders identify potential trend continuation and reversal areas using dual exponential moving averages. The indicator automatically highlights bullish and bearish crossover events while keeping the chart simple and easy to read.

Features

• Automatic Buy & Sell signal labels
• Fast EMA and Slow EMA trend filtering
• Visual trend confirmation using dual EMA lines
• Works on Forex, Gold, Silver, Crypto, Stocks, and Indices
• Suitable for scalping, intraday, and swing trading
• Lightweight and beginner-friendly design

How It Works

A Buy signal appears when the faster EMA crosses above the slower EMA, indicating a possible bullish trend shift.

A Sell signal appears when the faster EMA crosses below the slower EMA, indicating a possible bearish trend shift.

The EMA lines help traders identify the prevailing market direction and avoid trading against the dominant trend.

Best Used With

• Support & Resistance
• Price Action
• Market Structure
• Volume Confirmation
• Risk Management

Note
This indicator is intended as a technical analysis tool and should be used alongside your own market analysis and risk management. No indicator can predict market movements with certainty.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("EMA Cross Signals", overlay=true)

fast = ta.ema(close, 20)
slow = ta.ema(close, 50)

buy = ta.crossover(fast, slow)
sell = ta.crossunder(fast, slow)

plot(fast, color=color.green)
plot(slow, color=color.red)

plotshape(buy,
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     text="BUY")

plotshape(sell,
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     text="SELL")
````
