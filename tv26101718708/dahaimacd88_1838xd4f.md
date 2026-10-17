# dahaimacd88

- url: https://www.tradingview.com/script/1838xd4F/
- type: indicator
- pine_id: PUB;b33fa72018e948bc994c70612693ade0
- version: 1.0

## Description

MACD仅供参考

## Source Code

````pine
//@version=5
indicator(title="DAHAIMACD 警报",  timeframe="", timeframe_gaps=true)
// Getting inputs
fast_length = input(title="Fast Length", defval=12)
slow_length = input(title="Slow Length", defval=26)
src = input(title="Source", defval=close)
signal_length = input.int(title="Signal Smoothing",  minval = 1, maxval = 50, defval = 9)
sma_source = input.string(title="Oscillator MA Type",  defval="EMA", options=["SMA", "EMA"])
sma_signal = input.string(title="Signal Line MA Type", defval="EMA", options=["SMA", "EMA"])
// Plot colors
col_macd = input(#2962FF, "MACD Line  ", group="Color Settings", inline="MACD")
col_signal = input(#FF6D00, "Signal Line  ", group="Color Settings", inline="Signal")
col_grow_above = input(#26A69A, "Above   Grow", group="Histogram", inline="Above")
col_fall_above = input(#B2DFDB, "Fall", group="Histogram", inline="Above")
col_grow_below = input(#FFCDD2, "Below Grow", group="Histogram", inline="Below")
col_fall_below = input(#FF5252, "Fall", group="Histogram", inline="Below")
// Calculating
fast_ma = sma_source == "SMA" ? ta.sma(src, fast_length) : ta.ema(src, fast_length)
slow_ma = sma_source == "SMA" ? ta.sma(src, slow_length) : ta.ema(src, slow_length)
macd = fast_ma - slow_ma
signal = sma_signal == "SMA" ? ta.sma(macd, signal_length) : ta.ema(macd, signal_length)
hist = macd - signal
hline(0, "Zero Line", color=color.new(#787B86, 50))
plot(hist, title="Histogram", style=plot.style_columns, color=(hist>=0 ? (hist[1] < hist ? col_grow_above : col_fall_above) : (hist[1] < hist ? col_grow_below : col_fall_below)))
plot(macd, title="MACD", color=col_macd)
plot(signal, title="Signal", color=col_signal)



upcross = ta.crossover(macd,signal)
plotchar(upcross?signal:na,char="●",location= location.absolute,size = size.tiny,color = color.green)

alertcondition(upcross,title = "金叉",message = "金叉")

dncross = ta.crossunder(macd,signal)
plotchar(dncross?signal:na,char="●",location= location.absolute,size = size.tiny,color = color.red)
alertcondition(dncross,title = "死叉",message = "死叉")
````
