# MTF EMA Breakout PRO OPTIMIZED (1H Entry)

- url: https://www.tradingview.com/script/1Sk84toy-MTF-EMA-Breakout-PRO-OPTIMIZED-1H-Entry/
- type: indicator
- pine_id: PUB;2aeb4ca892df42dead44911492442bf4
- version: 1.0

## Description

swing trading
beginers friendly
no bias
fix SL
Fix TP

## Source Code

````pine
//@version=5
indicator("MTF EMA Breakout PRO OPTIMIZED (1H Entry)", overlay=true)

// === INPUT ===
emaLen  = input.int(20, "EMA Length")
rsiLen  = input.int(14, "RSI Length")
rr      = input.float(5.0, "Risk Reward")
bodyPct = input.float(0.6, "Strong Candle Body %")

// === CORE CALCULATIONS ===
ema_1h = ta.ema(close, emaLen)
rsiVal = ta.rsi(close, rsiLen)

// === MTF (UPDATED) ===
[ema_1d, c_1d] = request.security(syminfo.tickerid, "D",   [ta.ema(close, emaLen), close], lookahead=barmerge.lookahead_off)
[ema_4h, c_4h] = request.security(syminfo.tickerid, "240", [ta.ema(close, emaLen), close], lookahead=barmerge.lookahead_off)
[ema_1h_tf, c_1h_tf] = request.security(syminfo.tickerid, "60",  [ta.ema(close, emaLen), close], lookahead=barmerge.lookahead_off)

// === TREND ===
bullTrend = c_1d > ema_1d and c_4h > ema_4h and c_1h_tf > ema_1h_tf
bearTrend = c_1d < ema_1d and c_4h < ema_4h and c_1h_tf < ema_1h_tf

// === STRONG CANDLE ===
body = math.abs(close - open)
candleRange = math.max(high - low, syminfo.mintick)
strongCandle = body > candleRange * bodyPct

// === STORAGE ===
var float setupHigh = na
var float setupLow  = na
var float sl        = na
var float tp        = na
var float entry     = na
var float risk      = na

var bool inTrade  = false
var int  dir      = 0

// === SETUP (NOW 1H BASED) ===
bullSetup = bullTrend and rsiVal > 50 and strongCandle and close > ema_1h and close[1] <= ema_1h[1]
bearSetup = bearTrend and rsiVal < 50 and strongCandle and close < ema_1h and close[1] >= ema_1h[1]

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

// === BREAKEVEN ===
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

// === PLOT ===
plot(ema_1h, color=color.yellow)

// === SIGNALS ===
plotshape(buySignal,  location=location.belowbar, color=color.green, style=shape.labelup,   text="BUY")
plotshape(sellSignal, location=location.abovebar, color=color.red,   style=shape.labeldown, text="SELL")

// === LEVELS ===
plot(inTrade ? sl : na, color=color.red, linewidth=2)
plot(inTrade ? tp : na, color=color.green, linewidth=2)

// === ALERTS ===
alertcondition(buySignal, title="BUY", message="BUY ENTRY")
alertcondition(sellSignal, title="SELL", message="SELL ENTRY")
alertcondition(slHit, title="SL HIT", message="STOP LOSS HIT")
alertcondition(tpHit, title="TP HIT", message="TAKE PROFIT HIT")
````
