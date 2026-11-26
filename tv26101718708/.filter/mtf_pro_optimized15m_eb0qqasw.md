# MTF  PRO OPTIMIZED(15m)

- url: https://www.tradingview.com/script/eB0qqAsW-MTF-PRO-OPTIMIZED-15m/
- type: indicator
- pine_id: PUB;6a8f46b4948d49878cb2800cd0d90d7f
- version: 1.0

## Description

simple breakout
no bias
fix sl
fix tp with trailing
easy to beginers

## Source Code

````pine
//@version=5
indicator("MTF EMA Breakout PRO OPTIMIZED", overlay=true)

// === INPUT ===
emaLen  = input.int(20, "EMA Length")
rsiLen  = input.int(14, "RSI Length")
rr      = input.float(5.0, "Risk Reward")
bodyPct = input.float(0.6, "Strong Candle Body %")

// === CORE CALCULATIONS ===
ema_15 = ta.ema(close, emaLen)
rsiVal = ta.rsi(close, rsiLen)

// === MTF (OPTIMIZED SECURITY CALLS) ===
[ema_4h, c_4h]   = request.security(syminfo.tickerid, "240", [ta.ema(close, emaLen), close], lookahead=barmerge.lookahead_off)
[ema_1h, c_1h]   = request.security(syminfo.tickerid, "60",  [ta.ema(close, emaLen), close], lookahead=barmerge.lookahead_off)
[ema_15m, c_15m] = request.security(syminfo.tickerid, "15",  [ta.ema(close, emaLen), close], lookahead=barmerge.lookahead_off)

// === TREND ===
bullTrend = c_4h > ema_4h and c_1h > ema_1h and c_15m > ema_15m
bearTrend = c_4h < ema_4h and c_1h < ema_1h and c_15m < ema_15m

// === STRONG CANDLE (SAFE) ===
body = math.abs(close - open)
candleRange = math.max(high - low, syminfo.mintick)  // avoid zero division
strongCandle = body > candleRange * bodyPct

// === STORAGE ===
var float setupHigh = na
var float setupLow  = na
var float sl        = na
var float tp        = na
var float entry     = na
var float risk      = na

var bool inTrade  = false
var int  dir      = 0   // 1=buy, -1=sell

// === SETUP CONDITIONS ===
bullSetup = bullTrend and rsiVal > 50 and strongCandle and close > ema_15 and close[1] <= ema_15[1]
bearSetup = bearTrend and rsiVal < 50 and strongCandle and close < ema_15 and close[1] >= ema_15[1]

// === CAPTURE SETUP ===
if not inTrade
    if bullSetup
        setupHigh := high
        sl := low[1]

    if bearSetup
        setupLow := low
        sl := high[1]

// === ENTRY ===
buySignal  = not inTrade and not na(setupHigh) and high > setupHigh
sellSignal = not inTrade and not na(setupLow)  and low  < setupLow

if buySignal
    entry := setupHigh
    risk  := entry - sl
    tp    := entry + risk * rr

    inTrade := true
    dir := 1
    setupHigh := na

if sellSignal
    entry := setupLow
    risk  := sl - entry
    tp    := entry - risk * rr

    inTrade := true
    dir := -1
    setupLow := na

// === BREAKEVEN LOCK ===
if inTrade
    if dir == 1 and high >= entry + risk
        sl := entry
    if dir == -1 and low <= entry - risk
        sl := entry

// === EXIT ===
slHit = false
tpHit = false

if inTrade
    if dir == 1
        slHit := low <= sl
        tpHit := high >= tp
    else
        slHit := high >= sl
        tpHit := low <= tp

if slHit or tpHit
    inTrade := false
    dir := 0

// === PLOTS ===
plot(ema_15, color=color.yellow)

// Signals
plotshape(buySignal,  location=location.belowbar, color=color.green, style=shape.labelup,   text="BUY")
plotshape(sellSignal, location=location.abovebar, color=color.red,   style=shape.labeldown, text="SELL")

// Active trade levels
plot(inTrade ? sl : na, color=color.red,   linewidth=2, title="SL")
plot(inTrade ? tp : na, color=color.green, linewidth=2, title="TP")

// === ALERTS ===
alertcondition(buySignal, title="BUY", message="BUY ENTRY")
alertcondition(sellSignal, title="SELL", message="SELL ENTRY")
alertcondition(slHit, title="SL HIT", message="STOP LOSS HIT")
alertcondition(tpHit, title="TP HIT", message="TAKE PROFIT HIT")
````
