# MACandles-LinearRegression-Strategy

- url: https://www.tradingview.com/script/7ZmLpnJY-MACandles-LinearRegression-Strategy/
- type: strategy
- pine_id: PUB;37bee81de5f84bd5b37987593af327cf
- version: 2.0

## Description

This is combination of multiple indicators and strategies. Mainly useful for indexes and to time the entry and exits of indexes. No stoploss used - makes it less desirable for leveraged trades or trading individual stocks.

Let us rewind and look back at some of the indicators/strategies published earlier.

[b]1. Moving Average Candles[/b] - this is one of my favourite tool for general trend filtering. Applying supertrend on moving average candles is one of the easiest ways to find reversal in trending market without exiting positions too early. Few scripts published on this basis are:

[url=https://www.tradingview.com/script/YmCLexjL-MA-Candles-Supertrend/]MA Candles Supertrend[/url]
[url=https://www.tradingview.com/script/3o1JCZQL-MA-Candles-Supertrend-Strategy/]MA Candles Supertrend Strategy[/url]

[b]2. VixFix and Linear Regression[/b] - this itself is combination of two indicators.

[url=https://www.tradingview.com/script/og7JPrRA-CM-Williams-Vix-Fix-Finds-Market-Bottoms/]Williams-Vix-Fix-Finds-Market-Bottoms - by @ChrisMoody[/url]
[url=https://www.tradingview.com/script/nqQ1DT5a-Squeeze-Momentum-Indicator-LazyBear/]Squeeze-Momentum-Indicator - by @LazyBear[/url]

I have combined these two indicators to derive VIX-Fix linear regression to find absolute market bottoms. More description here:
[url=https://www.tradingview.com/script/VRbtGCcs-VixFixLinReg-Strategy/]VixFixLinReg-Strategy[/url]
[url=https://www.tradingview.com/script/R6SKpoaH-VixFixLinReg-Indicator/]VixFixLinReg-Indicator[/url]

Now, in this strategy, we combine all these together.

[list]
[*] Derive moving average candles
[*] Derive momentum of moving average candles
[*] Derive Linear regression on momentum
[*] Optionally, also calculate VIX Fix and Linear regression on VixFix momentum
[/list]

[b]To find market bottom:[/b]

There are two options
1. Use when momentum of MA candles hit bottom (red) and slowly turn up (orange). In [b]aggressiveLong[/b] mode, signals are also generated when momentum starts going positive from negative.
2. Use Vix Fix linear regression of MA candles as described in the original script of [url=https://www.tradingview.com/script/VRbtGCcs-VixFixLinReg-Strategy/]VixFixLinReg-Strategy[/url]

[b]To find market top[/b]

Here only Ma candles momentum decreasing is used as signal. If looking for [b]longTrades[/b], exit signal is generated only when momentum is turning negative extreme(orange). Or else, exit signal is generated when momentum has turned neutral.

At this stage, it is very much experimental - use it with caution :)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//@version=5
strategy('MACandles-LinearRegression-Strategy', shorttitle='MALinReg - Strategy', overlay=false, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, commission_type=strategy.commission.percent, pyramiding=1, commission_value=0.01)
resolution = ''
MAType = input.string(title='Moving Average Type (MA Candles)', defval='hma', options=['ema', 'sma', 'hma', 'rma', 'vwma', 'wma'])
LoopbackBars = input.int(60, title='Length (MA Candles)', step=10)

MMAType = input.string(title='Moving Average Type (Momentum)', defval='ema', options=['ema', 'sma', 'hma', 'rma', 'vwma', 'wma'])
MLength = input.int(20, title='MA Length (Momentum)', step=10)

lb = input.int(40, title='Look Back Period Percentile High/Low', step=10, minval=10, maxval=100)
ph = input(.85, title='Highest Percentile - 0.90=90%, 0.95=95%, 0.99=99%')
pl = input(1.01, title='Lowest Percentile - 1.10=90%, 1.05=95%, 1.01=99%')
mult = input.float(3.0, minval=1, maxval=5, title='Bollinger Band Standard Devaition Up')

aggressiveLong = input(true)
longTrades = input(true)
useVixFix = input(false)
i_startTime = input.time(defval=timestamp('01 Jan 2010 00:00 +0000'), title='Start Time')
i_endTime = input.time(defval=timestamp('01 Jan 2099 00:00 +0000'), title='End Time')
inDateRange = time >= i_startTime and time <= i_endTime


f_getMovingAverage(source, MAType, length) =>
    ma = ta.sma(source, length)
    if MAType == 'ema'
        ma := ta.ema(source, length)
        ma
    if MAType == 'hma'
        ma := ta.hma(source, length)
        ma
    if MAType == 'rma'
        ma := ta.rma(source, length)
        ma
    if MAType == 'vwma'
        ma := ta.vwma(source, length)
        ma
    if MAType == 'wma'
        ma := ta.wma(source, length)
        ma
    ma

f_getMACandles(resolution, MAType, LoopbackBars) =>
    oOpen = f_getMovingAverage(open, MAType, LoopbackBars)
    oClose = f_getMovingAverage(close, MAType, LoopbackBars)
    oHigh = f_getMovingAverage(high, MAType, LoopbackBars)
    oLow = f_getMovingAverage(low, MAType, LoopbackBars)
    [oOpen, oClose, oHigh, oLow]

f_getVixFixLinReg(oClose, oLow, MLength) =>
    wvf = (ta.highest(oClose, MLength) - oLow) / ta.highest(oClose, MLength) * 100

    sDev = mult * ta.stdev(wvf, MLength)
    midLine = ta.sma(wvf, MLength)
    lowerBand = midLine - sDev
    upperBand = midLine + sDev

    rangeHigh = ta.highest(wvf, lb) * ph
    rangeLow = ta.lowest(wvf, lb) * pl


    col = wvf >= upperBand or wvf >= rangeHigh ? color.lime : color.gray

    val = ta.linreg(wvf, MLength, 0)
    absVal = math.abs(val)
    linRegColor = val > val[1] ? val > 0 ? color.green : color.orange : val > 0 ? color.lime : color.red

    vixFixState = col == color.lime ? 1 : 0
    vixFixState := strategy.position_size == 0 ? math.max(vixFixState, nz(vixFixState[1], 0)) : vixFixState
    [val, absVal, wvf, col, linRegColor, vixFixState]

f_getMACandlesLinReg(oClose, MMAType, MLength, mult, lb, ph, pl) =>
    ma = f_getMovingAverage(oClose, MMAType, MLength)

    maDiff = oClose - ma
    val = ta.linreg(maDiff, MLength, 0)
    absVal = math.abs(val)
    iff_1 = val > nz(val[1]) ? color.green : color.lime
    iff_2 = val < nz(val[1]) ? color.red : color.orange
    linRegColor = val > 0 ? iff_1 : iff_2


    sDev = mult * ta.stdev(maDiff, MLength)
    midLine = ta.sma(maDiff, MLength)
    lowerBand = midLine - sDev
    upperBand = midLine + sDev

    rangeHigh = ta.highest(maDiff, lb) * ph
    rangeLow = ta.lowest(maDiff, lb) * pl

    col = maDiff >= upperBand or maDiff >= rangeHigh ? color.lime : maDiff <= lowerBand or maDiff <= rangeLow ? color.orange : color.silver
    absMaDiff = math.abs(maDiff)
    [val, absVal, maDiff, absMaDiff, col, linRegColor]

f_getSupertrend(resolution, oOpen, oClose, oHigh, oLow, AtrMAType, AtrLength, AtrMult, wicks) =>
    truerange = math.max(oHigh, oClose[1]) - math.min(oLow, oClose[1])

    averagetruerange = f_getMovingAverage(truerange, AtrMAType, AtrLength)
    atr = averagetruerange * AtrMult

    longWicks = wicks
    shortWicks = wicks
    longStop = oClose - atr
    longStopPrev = nz(longStop[1], longStop)
    longStop := (longWicks ? oLow[1] : oClose[1]) > longStopPrev ? math.max(longStop, longStopPrev) : longStop

    shortStop = oClose + atr
    shortStopPrev = nz(shortStop[1], shortStop)
    shortStop := (shortWicks ? oHigh[1] : oClose[1]) < shortStopPrev ? math.min(shortStop, shortStopPrev) : shortStop

    dir = 1
    dir := nz(dir[1], dir)
    dir := dir == -1 and (longWicks ? oHigh : oClose) > shortStopPrev ? 1 : dir == 1 and (shortWicks[1] ? oLow : oClose) < longStopPrev ? -1 : dir

    [dir, longStop, shortStop]

f_getMACandlesAndSupertrend(MAType, LoopbackBars, AtrMult, wicks) =>
    oOpen = f_getMovingAverage(open, MAType, LoopbackBars)
    oClose = f_getMovingAverage(close, MAType, LoopbackBars)
    oHigh = f_getMovingAverage(high, MAType, LoopbackBars)
    oLow = f_getMovingAverage(low, MAType, LoopbackBars)
    [dir, longStop, shortStop] = f_getSupertrend(resolution, oOpen, oClose, oHigh, oLow, MAType, LoopbackBars, AtrMult, wicks)
    dir

[oOpen, oClose, oHigh, oLow] = f_getMACandles(resolution, MAType, LoopbackBars)
dir = f_getMACandlesAndSupertrend('sma', 200, 1, false)
colorByPreviousClose = false
candleColor = colorByPreviousClose ? oClose[1] < oClose ? color.green : oClose[1] > oClose ? color.red : color.silver : oOpen < oClose ? color.green : oOpen > oClose ? color.red : color.silver


[vval, vabsVal, wvf, vcol, vlinRegColor, vixFixState] = f_getVixFixLinReg(oClose, oLow, MLength)
[val, absVal, maDiff, absMaDiff, col, linRegColor] = f_getMACandlesLinReg(oClose, MMAType, MLength, mult, lb, ph, pl)


plot(useVixFix ? na : absMaDiff, title='Momentum', style=plot.style_histogram, linewidth=4, color=col)
plot(useVixFix ? wvf : na, title='VIX Fix', style=plot.style_histogram, linewidth=4, color=vcol)
plot(useVixFix ? na : -absVal, title='Linear Regression (Momentum)', style=plot.style_histogram, linewidth=4, color=linRegColor)
plot(useVixFix ? -vabsVal : na, title='Linear Regression (VIX Fix)', style=plot.style_histogram, linewidth=4, color=vlinRegColor)

exitColor = longTrades ? color.orange : color.silver
exitPreviousColor = longTrades ? color.silver : color.lime
longCondition = (useVixFix ? vixFixState == 1 and vlinRegColor == color.lime : linRegColor == color.orange and linRegColor[1] == color.red or linRegColor == color.green and linRegColor[1] != color.green and aggressiveLong) and inDateRange and dir > 0
exitLongCondition = col == exitColor and col[1] == exitColor and col[2] == exitPreviousColor and (linRegColor != color.green or not aggressiveLong)

strategy.entry('Long', strategy.long, when=longCondition, oca_name='oca_buy', oca_type=strategy.oca.cancel)
strategy.close('Long', when=exitLongCondition)
````
