# Bollinger Band + RSI + ADX + MACD + Heikinashi

- url: https://www.tradingview.com/script/ezkXKevK-Bollinger-Band-RSI-ADX-MACD-Heikinashi/
- type: strategy
- pine_id: PUB;BXKBIXDY904FrljZ3awsVmkCPWea2E1q
- version: 1.0

## Description

This script takes into picture Bollinger Bands, RSI with a comparator value, ADX with a comparator value, and MACD with Heikinashi Direction

[b]THIS IS A LONG-ONLY STRATEGY. SHORT TRADES ARE NOT INCLUDED[/b]

[b]Strategy:[/b]

The Strategy takes a trade only after [b]ALL[/b] the following conditions are met.

[list]
[*]Candle low is lower than the Bollinger Lower band

[*]RSI is higher than the comparator value

[*]ADX is higher than the comparator value

[*]MACD value is higher than the Signal value
[/list]

[b]Stop Loss[/b]: Max of (Low of the candle - 0.22% and Close of the candle - 0.32%) - FYI, because its max, it's lower of the 2 and your risk is lesser

[b]Target[/b]: Max of (Bollinger Band Upper band and 0.75% of the value of underlying) - FYI, it takes the maximum available

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © abilash.s.90


dIMinusCalc(adxLen) =>
    
    smoothedTrueRange = 0.0
    smoothedDirectionalMovementMinus = 0.0
    dIMinus = 0.0
    trueRange = 0.0
    directionalMovementMinus = 0.0
    
    trueRange := max(max(high-low, abs(high-nz(close[1]))), abs(low-nz(close[1])))
    directionalMovementMinus := nz(low[1])-low > high-nz(high[1]) ? max(nz(low[1])-low, 0): 0
    
    smoothedTrueRange := nz(smoothedTrueRange[1]) - (nz(smoothedTrueRange[1])/adxLen) + trueRange
    smoothedDirectionalMovementMinus := nz(smoothedDirectionalMovementMinus[1]) - (nz(smoothedDirectionalMovementMinus[1])/adxLen) + directionalMovementMinus
    
    dIMinus := smoothedDirectionalMovementMinus / smoothedTrueRange * 100
    
    dIMinus

dIPlusCalc(adxLen) =>
    
    smoothedTrueRange = 0.0
    smoothedDirectionalMovementPlus = 0.0
    dIPlus =  0.0
    trueRange = 0.0
    directionalMovementPlus = 0.0
    
    trueRange := max(max(high-low, abs(high-nz(close[1]))), abs(low-nz(close[1])))
    directionalMovementPlus := high-nz(high[1]) > nz(low[1])-low ? max(high-nz(high[1]), 0): 0
    
    smoothedTrueRange := nz(smoothedTrueRange[1]) - (nz(smoothedTrueRange[1])/adxLen) + trueRange
    smoothedDirectionalMovementPlus := nz(smoothedDirectionalMovementPlus[1]) - (nz(smoothedDirectionalMovementPlus[1])/adxLen) + directionalMovementPlus
    
    dIPlus := smoothedDirectionalMovementPlus / smoothedTrueRange * 100
    
    dIPlus
    
    
Adx(adxLen) =>
    dIPlus =  0.0
    dIMinus = 0.0
    dX = 0.0
    aDX = 0.0
    dIPlus := dIPlusCalc(adxLen)
    dIMinus := dIMinusCalc(adxLen)
    dX := abs(dIPlus-dIMinus) / (dIPlus+dIMinus)*100
    aDX := sma(dX, adxLen)
    
    aDX
    
BarInSession(sess) => time(timeframe.period, sess) != 0


//@version=4
strategy("Bollinger Band + RSI + ADX + MACD", overlay=true)

//Session

session = input(title="Trading Session", type=input.session, defval="0930-1500")

sessionColor = BarInSession(session) ? color.green : na

bgcolor(color=sessionColor, transp=95)

// Bollinger Bands
src = input(high, title="Bollinger Band Source", type=input.source)
length = input(3, minval=1, type=input.integer, title="Bollinger Band Length")
mult = input(4.989, minval=0.001, maxval=50, step=0.001, type=input.float, title="Bollinger Band Std Dev")
basis = sma(src, length)
dev = mult * stdev(src, length)
upper = basis + dev
lower = basis - dev


plot(upper, title="Bollinger Band Upper", color=color.red)
plot(lower, title="Bollinger Band Lower", color=color.green)

// RSI
rsiSrc = input(close, title="RSI Source", type=input.source)
rsiLength = input(16, minval=1, type=input.integer, title="RSI Length")
rsiComparator = input(39.2, title="RSI Comparator", type=input.float, step=0.1)

rsi = rsi(rsiSrc, rsiLength)

// ADX
adxLength = input(14, minval=1, type=input.integer, title="ADX Length")
adxComparator = input(14, minval=1, type=input.integer, title="ADX Comparator")

adx = Adx(adxLength)

// Heikinashi

haClose = security(heikinashi(syminfo.ticker), timeframe.period, close)
haOpen = security(heikinashi(syminfo.ticker), timeframe.period, open)

nextHaOpen = (haOpen + haClose) / 2

//MACD

macdCalcTypeProcessed = input(title="MACD Source", type=input.source, defval=high)
fast = input(12, title="MACD Fast")
slow = input(20, title="MACD Slow")
signalLen = input(15, title="MACD Signal")

fastMA = ema(macdCalcTypeProcessed, fast)
slowMA = ema(macdCalcTypeProcessed, slow)
macd = fastMA - slowMA
signal = sma(macd, signalLen)



longCondition() =>
    (low < lower) and (rsi[0] > rsiComparator) and (adx > adxComparator) and (close > nextHaOpen) and BarInSession(session) and macd > signal

stop = (close - max((low - (low * 0.0022)), (close - (close * 0.0032)))) / syminfo.mintick
target = (max(upper, (close + (close * 0.0075))) - close) / syminfo.mintick


strategy.entry("SX,LE", strategy.long, when=longCondition(), comment="SX,LE")
strategy.close_all(when=(not BarInSession(session)))
strategy.exit("LX", from_entry="SX,LE", profit=target, loss=stop)
````
