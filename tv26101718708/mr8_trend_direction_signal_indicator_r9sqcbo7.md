# MR8 Trend Direction & Signal Indicator

- url: https://www.tradingview.com/script/R9Sqcbo7-MR8-Trend-Direction-Signal-Indicator/
- type: indicator
- pine_id: PUB;8aafafd454124db7ae02929826870260
- version: 1.0

## Description

The MR8 is a dynamic trend-following indicator built on the McGinley Dynamic moving average — one of the most responsive and self-adjusting smoothing algorithms available. Unlike traditional EMAs that can lag or whipsaw in changing market conditions, the McGinley Dynamic automatically adapts its speed based on market velocity, resulting in cleaner, more reliable signals.

How It Works
MR8 plots two McGinley Dynamic lines — a faster Ribbon 8 and a slower Ribbon 9. When the faster line crosses above the slower line, the ribbon turns white, signaling bullish momentum and a potential long entry. When the faster line crosses below, the ribbon turns grey, signaling bearish momentum and a potential short entry. This crossover method filters out the noise and false flips that plague single-line slope-based indicators.

Built-In Stop Loss
MR8 includes an optional visual stop loss line calculated directly from the ribbon's current value — 2% above the line for shorts, 2% below for longs. Toggle it on in settings to see exactly where your risk level sits relative to the indicator itself, on any timeframe.

Alert Ready
MR8 includes two built-in alert conditions — one for long signals and one for short signals — with a webhook-compatible JSON message format. Connect directly to any automated trading bot or notification system with zero additional configuration.

Best Used On
BTC/USD and BTC/USDT
55 minute, 1 hour, and higher timeframes
Futures and spot markets

Settings

Ribbon 8 Length — controls the speed of the faster line (default 12)
Ribbon 9 Length — controls the speed of the slower line (default 21)
Stop Loss % — distance from the ribbon for the optional SL line (default 2%)
Show Stop Loss Line — toggle the SL visualization on or off

## Source Code

````pine
//@version=6
indicator(title="McGinley Ribbon 8 [HR Bot]", shorttitle="MR8", overlay=true)

len8      = input.int(12,    title="Ribbon 8 Length",              minval=1)
len9      = input.int(21,    title="Ribbon 9 Length",              minval=1)
lineWidth = input.int(5,     title="Line Width",                   minval=1, maxval=5)
slPct     = input.float(2.0, title="Stop Loss % (from MR8 line)",  minval=0.1, maxval=20, step=0.1)
showSL    = input.bool(false, title="Show Stop Loss Line")

mcginley(src, len) =>
    mg = float(na)
    mg := na(mg[1]) ? src : mg[1] + (src - mg[1]) / (len * math.pow(src / mg[1], 4))
    mg

mg8 = mcginley(close, len8)
mg9 = mcginley(close, len9)

ribbonUp    = mg8 > mg9
ribbonColor = ribbonUp ? color.white : color.new(color.gray, 20)

plot(mg8, title="Ribbon 8", color=ribbonColor, linewidth=lineWidth)
plot(mg9, title="Ribbon 9", color=color.new(color.gray, 100), linewidth=1, display=display.none)

slMultiplier = slPct / 100
longSL   = mg8 * (1 - slMultiplier)
shortSL  = mg8 * (1 + slMultiplier)
activeSL = ribbonUp ? longSL : shortSL

plot(showSL ? activeSL : na,
     title="Stop Loss Level",
     color=color.new(color.red, 0),
     linewidth=1,
     style=plot.style_circles)

longSignal  = ribbonUp and not ribbonUp[1]
shortSignal = not ribbonUp and ribbonUp[1]

alertcondition(longSignal,
     title="LONG — Ribbon Turned White",
     message='{"side":"BUY","symbol":"BTCUSDT","price":"{{close}}","sl":"{{plot_2}}","time":"{{time}}"}')

alertcondition(shortSignal,
     title="SHORT — Ribbon Turned Grey",
     message='{"side":"SELL","symbol":"BTCUSDT","price":"{{close}}","sl":"{{plot_2}}","time":"{{time}}"}')
````
