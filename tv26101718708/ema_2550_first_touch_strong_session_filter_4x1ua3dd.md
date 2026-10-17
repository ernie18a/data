# EMA 25/50 First Touch (Strong + Session Filter)

- url: https://www.tradingview.com/script/4x1Ua3dD-EMA-25-50-First-Touch-Strong-Session-Filter/
- type: indicator
- pine_id: PUB;94617eb46d7c4bb1b4d829ab7ef3f515
- version: 1.0

## Description

EMA 50 and EMA 25 cross alert after cross and touch back to EMA 25, gives a rejection, very good signal

## Source Code

````pine
//@version=5
indicator("EMA 25/50 First Touch (Strong + Session Filter)", overlay=true)

// ===== INPUTS =====
minWaitBars = input.int(6, "Min Bars After Cross")
bodyPercent = input.float(0.5, "Min Body % (0.5 = 50%)")

// ===== SESSION SETTINGS =====
london  = input.session("0800-1700", "London Session")
newyork = input.session("1300-2200", "New York Session")

inSession = not na(time(timeframe.period, london)) or not na(time(timeframe.period, newyork))

// ===== EMA =====
ema25 = ta.ema(close, 25)
ema50 = ta.ema(close, 50)

plot(ema25, color=color.red, linewidth=2)
plot(ema50, color=color.blue, linewidth=2)

// ===== TREND =====
uptrend   = ema25 > ema50
downtrend = ema25 < ema50

bgcolor(uptrend ? color.new(color.green, 85) : na)
bgcolor(downtrend ? color.new(color.red, 85) : na)

// ===== CROSS =====
crossUp = ta.crossover(ema25, ema50)
crossDn = ta.crossunder(ema25, ema50)

// ===== STORAGE =====
var int buyCrossBar  = na
var int sellCrossBar = na

var bool buyArmed  = false
var bool sellArmed = false

if crossUp
    buyCrossBar := bar_index
    buyArmed := false

if crossDn
    sellCrossBar := bar_index
    sellArmed := false

// ===== WAIT =====
buyReady  = not na(buyCrossBar) and (bar_index - buyCrossBar >= minWaitBars)
sellReady = not na(sellCrossBar) and (bar_index - sellCrossBar >= minWaitBars)

// ===== ARM =====
if buyReady
    buyArmed := true

if sellReady
    sellArmed := true

// ===== CANDLE STRENGTH =====
bodySize   = math.abs(close - open)
candleSize = high - low
bodyRatio  = candleSize > 0 ? bodySize / candleSize : 0

strongBody = bodyRatio >= bodyPercent

// ===== TOUCH + REJECTION =====
buyTouch  = low <= ema25
buyReject = close > ema25 and close > open and strongBody

sellTouch  = high >= ema25
sellReject = close < ema25 and close < open and strongBody

// ===== FINAL SIGNALS =====
buySignal =
     buyArmed and
     uptrend and
     inSession and
     buyTouch and
     buyReject

sellSignal =
     sellArmed and
     downtrend and
     inSession and
     sellTouch and
     sellReject

// ===== RESET =====
if buySignal
    buyArmed := false
    buyCrossBar := na

if sellSignal
    sellArmed := false
    sellCrossBar := na

// ===== BOX LABELS =====
if buySignal
    label.new(bar_index, low,
         "BUY",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

if sellSignal
    label.new(bar_index, high,
         "SELL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

// ===== ALERTS =====
alertcondition(buySignal, title="BUY ALERT", message="Strong BUY (Session + Rejection)")
alertcondition(sellSignal, title="SELL ALERT", message="Strong SELL (Session + Rejection)")
````
