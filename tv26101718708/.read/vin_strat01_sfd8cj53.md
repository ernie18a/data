# Vin Strat01 

- url: https://www.tradingview.com/script/Sfd8CJ53-Vin-Strat01/
- type: indicator
- pine_id: PUB;4bad04a8230249bfbe670c92adca6a93
- version: 1.0

## Description

5 min 200/400 ema or multiple time frame based. Multi Time frame Momentum Signal!

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Momentum Signal", overlay=true)

// ============================================================
// INPUTS
// ============================================================
rsiLen      = input.int(14, "RSI Length")
vwapBuffer  = input.float(2.0, "Allowed % distance below VWAP", minval=0.0, step=0.1)
showOnlyNew = input.bool(true, "Show arrow only when signal first triggers")

// ============================================================
// HELPER FUNCTIONS (fetch indicator from a specific timeframe)
// ============================================================
f_ema(tf, len) =>
    request.security(syminfo.tickerid, tf, ta.ema(close, len), lookahead=barmerge.lookahead_off)

f_rsi(tf, len) =>
    request.security(syminfo.tickerid, tf, ta.rsi(close, len), lookahead=barmerge.lookahead_off)

// ============================================================
// CONDITION 1: TREND
// Price above 200 & 400 EMA on 5m  OR  above 100 & 200 EMA on 10m
// ============================================================
ema200_5m  = f_ema("5", 200)
ema400_5m  = f_ema("5", 400)
cond5m     = close > ema200_5m and close > ema400_5m

ema100_10m = f_ema("10", 100)
ema200_10m = f_ema("10", 200)
cond10m    = close > ema100_10m and close > ema200_10m

trendOK    = cond5m or cond10m

// ============================================================
// CONDITION 2: RSI > 50 on the 5-minute chart
// ============================================================
rsi5m   = f_rsi("5", rsiLen)
rsi5mOK = rsi5m > 50

// ============================================================
// CONDITION 3: RSI > 40 on the 1-hour chart
// ============================================================
rsi1h   = f_rsi("60", rsiLen)
rsi1hOK = rsi1h > 40

// ============================================================
// CONDITION 4: Above VWAP, or no more than 2% below it
// ============================================================
vwapValue = ta.vwap(hlc3)
vwapOK    = close >= vwapValue * (1 - vwapBuffer / 100)

// ============================================================
// CONDITION 5: Price above the 8 EMA on the 15-minute chart
// ============================================================
ema8_15m = f_ema("15", 8)
ema8OK   = close > ema8_15m

// ============================================================
// COMBINE ALL CONDITIONS
// ============================================================
allConditions = trendOK and rsi5mOK and rsi1hOK and vwapOK and ema8OK

// Optionally only fire on the first bar the signal appears
signal = showOnlyNew ? (allConditions and not allConditions[1]) : allConditions

// ============================================================
// PLOT THE PURPLE UP ARROW
// ============================================================
plotshape(signal, title="Buy Signal", location=location.belowbar, style=shape.triangleup, size=size.small, color=color.purple)

// ============================================================
// ALERT (optional — lets you set notifications)
// ============================================================
alertcondition(signal, title="All Conditions Met", message="Purple arrow signal triggered on {{ticker}}")
````
