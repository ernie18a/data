# MA/EMA

- url: https://www.tradingview.com/script/d6Rgq8wd-MA-EMA/
- type: indicator
- pine_id: PUB;6f6470ee7bdf4d8e88f1e4bbc173df5c
- version: 1.0

## Description

Multi MA/EMA
Customize the length of each moving average directly from the settings panel.
Simple and lightweight — built for scanning hundreds of tickers daily with minimal chart loading delay.

## Source Code

````pine
//@version=5
indicator(title="MA/EMA", shorttitle="MAs", overlay=true)

// === Input ===
useEMA = input.bool(false, title="Use EMA (Uncheck for SMA)")

// === Length Inputs ===
len5   = input.int(5,   minval=1, title="MA5 Length")
len10  = input.int(10,  minval=1, title="MA10 Length")
len20  = input.int(20,  minval=1, title="MA20 Length")
len50  = input.int(50,  minval=1, title="MA50 Length")
len100 = input.int(100, minval=1, title="MA100 Length")
len150 = input.int(150, minval=1, title="MA150 Length")
len200 = input.int(200, minval=1, title="MA200 Length")

// === Source ===
src = close

// === Function for MA/EMA ===
maFunc(src, length) =>
    useEMA ? ta.ema(src, length) : ta.sma(src, length)

// === Calculations ===
ma5   = maFunc(src, len5)
ma10  = maFunc(src, len10)
ma20  = maFunc(src, len20)
ma50  = maFunc(src, len50)
ma100 = maFunc(src, len100)
ma150 = maFunc(src, len150)
ma200 = maFunc(src, len200)

// === Plots ===
plot(ma5,   color=color.new(#056656, 45), title="MA5",   linewidth=1)
plot(ma10,  color=color.new(#00bcd4, 45), title="MA10",  linewidth=1)
plot(ma20,  color=color.new(#ff9800, 45), title="MA20",  linewidth=1)
plot(ma50,  color=color.new(#ef5350, 60), title="MA50",  linewidth=1)
plot(ma100, color=color.new(#434651, 75), title="MA100", linewidth=1)
plot(ma150, color=color.new(#056656, 75), title="MA150", linewidth=1)
plot(ma200, color=color.new(#9c27b0, 75), title="MA200", linewidth=1)

//dattran3678
````
