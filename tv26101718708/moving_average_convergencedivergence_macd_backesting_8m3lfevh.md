# Moving Average Convergence/Divergence MaCD Backesting

- url: https://www.tradingview.com/script/8m3LFEVH-Moving-Average-Convergence-Divergence-MaCD-Backesting/
- type: strategy
- pine_id: PUB;61Tn6y49w4awjgdMD22zRrSVbEnpn5EY
- version: 3.0

## Description

Made this to backtest simple macd trading strategy, had to set it to open long and short positions because i'm not sure how you get it to calculate otherwise.

## Source Code

````pine
//@version=4
strategy(title="MACD Histogram Backtest", shorttitle="MACD")

// Getting inputs
fast_length = input(title="Fast Length", type=input.integer, defval=12)
slow_length = input(title="Slow Length", type=input.integer, defval=26)
src = input(title="Source", type=input.source, defval=close)
signal_length = input(title="Signal Smoothing", type=input.integer, minval = 1, maxval = 50, defval = 9)
sma_source = input(title="Simple MA(Oscillator)", type=input.bool, defval=false)
sma_signal = input(title="Simple MA(Signal Line)", type=input.bool, defval=false)

// Plot colors
col_grow_above = #26A69A
col_grow_below = #FFCDD2
col_fall_above = #B2DFDB
col_fall_below = #EF5350
col_macd = #0094ff
col_signal = #ff6a00

// Calculating
fast_ma = sma_source ? sma(src, fast_length) : ema(src, fast_length)
slow_ma = sma_source ? sma(src, slow_length) : ema(src, slow_length)
macd = fast_ma - slow_ma
signal = sma_signal ? sma(macd, signal_length) : ema(macd, signal_length)
hist = macd - signal

grow = hist[1] <= hist
fall = hist[1] >= hist
cross_over = crossover(macd,signal)
cross_under = crossunder(macd,signal)

plot(hist, title="Histogram", style=plot.style_columns, color=(hist>=0 ? (hist[1] < hist ? col_grow_above : col_fall_above) : (hist[1] < hist ? col_grow_below : col_fall_below) ), transp=0 )
plot(macd, title="MACD", color=col_macd, transp=0)
plot(signal, title="Signal", color=col_signal, transp=0)

//Strategy Testing

// Component Code Start
// Example usage:
// if testPeriod()
//   strategy.entry("LE", strategy.long)
testStartYear = input(2017, "Backtest Start Year")
testStartMonth = input(01, "Backtest Start Month")
testStartDay = input(2, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)

testStopYear = input(2019, "Backtest Stop Year")
testStopMonth = input(12, "Backtest Stop Month")
testStopDay = input(30, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,0,0)

// A switch to control background coloring of the test period
testPeriodBackground = input(title="Color Background?", type=input.bool, defval=true)
testPeriodBackgroundColor = testPeriodBackground and (time >= testPeriodStart) and (time <= testPeriodStop) ? #00FF00 : na
bgcolor(testPeriodBackgroundColor, transp=97)

testPeriod() =>
    time >= testPeriodStart and time <= testPeriodStop ? true : false
// Component Code Stop

//Entry and Close settings
if testPeriod() 
    strategy.entry("cross over", true, 1000, when = cross_over, limit = close)
    strategy.close("cross over", when = cross_under)
    
//if testPeriod() 
   // strategy.entry("cross under", false, 1000, when = cross_under, limit = close)
    //strategy.close("cross under", when = cross_over)
````
