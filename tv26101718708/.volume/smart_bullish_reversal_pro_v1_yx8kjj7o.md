# Smart Bullish Reversal PRO v1

- url: https://www.tradingview.com/script/yX8KJJ7o-Smart-Bullish-Reversal-PRO-v1/
- type: indicator
- pine_id: PUB;4301c58c8d7945ebbcc0618cebc97ad7
- version: 1.0

## Description

Good indicator for Egyptian stocks depends on rsi macd divergenace

## Source Code

````pine
//@version=5
indicator("Smart Bullish Reversal PRO v1", overlay=true)

// ========= INPUTS =========
rsiLen   = input.int(14)
pivotLen = input.int(5)
volMult  = input.float(1.2)
emaLen   = input.int(50)

// ========= INDICATORS =========
rsi = ta.rsi(close, rsiLen)
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
ema = ta.ema(close, emaLen)
// ========= EMA CONDITION =========
emaCond = close > ema
// ========= PIVOTS =========
pricePivotLow = ta.pivotlow(low, pivotLen, pivotLen)
rsiPivotLow   = ta.pivotlow(rsi, pivotLen, pivotLen)
macdPivotLow  = ta.pivotlow(macdLine, pivotLen, pivotLen)

// ========= STORE =========
var float prevPriceLow = na
var float lastPriceLow = na
var float prevRsiLow = na
var float lastRsiLow = na
var float prevMacdLow = na
var float lastMacdLow = na

if not na(pricePivotLow)
    prevPriceLow := lastPriceLow
    lastPriceLow := pricePivotLow

if not na(rsiPivotLow)
    prevRsiLow := lastRsiLow
    lastRsiLow := rsiPivotLow

if not na(macdPivotLow)
    prevMacdLow := lastMacdLow
    lastMacdLow := macdPivotLow

// ========= DIVERGENCE =========
bullRsiDiv  = not na(prevPriceLow) and not na(prevRsiLow) and (lastPriceLow < prevPriceLow) and (lastRsiLow > prevRsiLow)
bullMacdDiv = not na(prevPriceLow) and not na(prevMacdLow) and (lastPriceLow < prevPriceLow) and (lastMacdLow > prevMacdLow)



// ========= EARLY MOMENTUM =========

// خروج RSI من oversold
rsiRecovery = ta.crossover(rsi, 30)

// شمعة انعكاسية قوية
bullCandle = close > open and close > close[1]

// بداية صعود MACD
macdTurn = ta.crossover(macdLine, signalLine)

// ========= VOLUME =========
volCond = volume > ta.sma(volume, 10) * volMult

// ========= EARLY SIGNAL =========
earlySignal = (bullRsiDiv or bullMacdDiv) and (rsiRecovery or macdTurn or bullCandle) and 
         volCond and emaCond

// فلترة خفيفة فقط
signal = earlySignal and volCond


// ========= PLOT =========
plotshape(signal, title="BUY", location=location.belowbar,
     style=shape.labelup, color=color.rgb(199, 218, 76), text="B", size=size.tiny)

plot(ema, color=color.rgb(82, 19, 209))
````
