# Uitimate Rainbow

- url: https://www.tradingview.com/script/0Dzkw8X0/
- type: indicator
- pine_id: PUB;907b69c7fe1844abbcb54db1f37cf289
- version: 1.0

## Description

This indicator combines Exponential Moving Average (EMA) lines into a single script, organized into 10 distinct groups of 3 lines each. It is designed to help traders analyze multi-layered market trends, momentum, and dynamic support/resistance zones from ultra-short-term scalping levels to macro long-term trends, all calculated based on the Close price.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Mongkong

//@version=6
indicator("Uitimate Rainbow", overlay=true)
plot(ta.ema(close, 5),     color=color.red,    linewidth=2, title="EMA 5")
plot(ta.ema(close, 10),    color=color.yellow, linewidth=2, title="EMA 10")
plot(ta.ema(close, 15),    color=color.rgb(255, 105, 180), linewidth=2, title="EMA 15")
plot(ta.ema(close, 50),    color=color.red,    linewidth=2, title="EMA 50")
plot(ta.ema(close, 100),   color=color.yellow, linewidth=2, title="EMA 100")
plot(ta.ema(close, 150),   color=color.rgb(255, 105, 180), linewidth=2, title="EMA 150")
plot(ta.ema(close, 55),    color=color.red,    linewidth=2, title="EMA 55")
plot(ta.ema(close, 110),   color=color.yellow, linewidth=2, title="EMA 110")
plot(ta.ema(close, 165),   color=color.rgb(255, 105, 180), linewidth=2, title="EMA 165")
plot(ta.ema(close, 500),   color=color.red,    linewidth=2, title="EMA 500")
plot(ta.ema(close, 1000),  color=color.yellow, linewidth=2, title="EMA 1000")
plot(ta.ema(close, 1500),  color=color.rgb(255, 105, 180), linewidth=2, title="EMA 1500")
plot(ta.ema(close, 550),   color=color.red,    linewidth=2, title="EMA 550")
plot(ta.ema(close, 1100),  color=color.yellow, linewidth=2, title="EMA 1100")
plot(ta.ema(close, 1650),  color=color.rgb(255, 105, 180), linewidth=2, title="EMA 1650")
plot(ta.ema(close, 600),   color=color.red,    linewidth=2, title="EMA 600")
plot(ta.ema(close, 1200),  color=color.yellow, linewidth=2, title="EMA 1200")
plot(ta.ema(close, 1800),  color=color.rgb(255, 105, 180), linewidth=2, title="EMA 1800")
plot(ta.ema(close, 5000),  color=color.red,    linewidth=2, title="EMA 5000")
````
