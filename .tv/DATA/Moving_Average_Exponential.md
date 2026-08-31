<!-- tradingview-pine-id: PUB;8a60c527e94148eaac8bdfabed9d9b41 -->
<!-- tradingviewscripts-format: 1 -->
# Moving Average Exponential

Source: https://www.tradingview.com/script/y7Y8NrEy/

## Description

Moving Average Exponential, 3 intervals (21 55 144)

---

## Source Code

````pine
//@version=6
indicator(title="Moving Average Exponential", shorttitle="EMA 长中短线均线组", overlay=true)

len2 = input.int(21, minval=1, title="Length")
src2 = input.source(close, title="Source")
offset2 = input.int(0, title="Offset", minval=-500, maxval=500)
out2 = ta.ema(src2, len2)
plot(out2, title="EMA21", color=color.red, offset=offset2, linewidth=1)

len3 = input.int(55, minval=1, title="Length")
src3 = input.source(close, title="Source")
offset3 = input.int(0, title="Offset", minval=-500, maxval=500)
out3 = ta.ema(src3, len3)
plot(out3, title="EMA55", color=color.yellow, offset=offset3, linewidth=1)

len4 = input.int(144, minval=1, title="Length")
src4 = input.source(close, title="Source")
offset4 = input.int(0, title="Offset", minval=-500, maxval=500)
out4 = ta.ema(src4, len4)
plot(out4, title="EMA144", color=color.green, offset=offset4, linewidth=1)
````
