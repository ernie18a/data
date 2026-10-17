# byquan GP - Combined GP 1H+ ChiBao A Filter

- url: https://www.tradingview.com/script/SIkGHsbI/
- type: indicator
- pine_id: PUB;9efa8b477e9d49dd99ddaefcee388c16
- version: 1.0

## Description

// GP - Combined EMA Early Retest + SRSI Channel Filter

This script combines two complementary approaches into a filtered momentum and pullback retest system. 

The core concept is to generate **high-probability entry signals** by requiring confirmation from both price action structure (via EMA pullback & early retest) and multi-timeframe momentum extremes (via SRSI Channel).

### Indicator A – EMA Early Retest Logic
This part identifies potential early retest entries after a strong move:
- Uses a triple EMA system (Fast 20 / Mid 50 / Slow 100 by default).
- Detects when the fast EMA crosses the mid or slow EMA, then tracks the subsequent pullback.
- Measures pullback depth as a percentage of the prior impulse move.
- Triggers a signal when price (via fast EMA) returns to an **early retest zone** (default 90% of the pullback), but only in the direction of the higher trend (Mid vs Slow EMA).

This logic aims to catch early resumption of the trend instead of waiting for a full retest of the swing low/high.

### Indicator B – Multi-Timeframe SRSI Channel
Provides higher-timeframe momentum context:
- Calculates Stochastic RSI (K+D) on open, high, low, and close.
- Aggregates values from **four higher timeframes** (default: 3H, 6H, 12H, 24H).
- Detects momentum extremes and confirms reversals after a set number of bars (default 10 bars confirmation).
- Acts as a powerful **momentum filter** to avoid signals against the broader momentum.

### Combined Filter System
The final signals are **filtered** using a 1-week lookback:
- A buy signal from the EMA Early Retest is only valid if the SRSI Channel has recently confirmed a momentum low (oversold reversal).
- A sell signal is only valid if the SRSI Channel has recently confirmed a momentum high (overbought reversal).

This filter significantly reduces false signals by ensuring that short-term price action aligns with broader momentum shifts.

### How to Use

**Bullish (Long) Signal:**
- Lime triangle appears below the bar.
- Indicates the fast EMA has pulled back and is retesting early in an uptrend, confirmed by recent multi-timeframe SRSI momentum low.

**Bearish (Short) Signal:**
- Red triangle appears above the bar.
- Indicates the fast EMA has pulled back and is retesting early in a downtrend, confirmed by recent multi-timeframe SRSI momentum high.

**Visual Elements:**
- Orange = Fast EMA (most responsive)
- Blue   = Mid EMA
- Gray   = Slow EMA (trend filter)
- Light triangles = Original EMA signals (filtered out)
- Bright triangles = **Filtered high-probability signals**

### Recommended Usage
- Best suited for **intraday and swing trading** on 5m, 15m, 30m, and 1H timeframes.
- Works well on major forex pairs, indices, and cryptocurrencies.
- Use in the direction of the higher timeframe trend for better performance.
- Combine with support/resistance, order blocks, or volume analysis for maximum edge.

### Settings Tips
- Adjust "Pullback depth (%)" and "Early retest ratio" to match market volatility.
- Modify higher timeframe settings in "Indicator B" group to suit your trading style.
- Increase "Confirm bars" for stricter (fewer but higher quality) signals.

This is **not** a simple mashup of indicators. The real value comes from the intelligent combination of **price structure (EMA retest)** with **multi-timeframe momentum confirmation**, plus the 1-week lookback filter. 

The script is open-source and shared for educational purposes only. It is not financial advice — always use proper risk management and backtest thoroughly before using on a live account.

Feedback and suggestions are welcome!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// Combined: Indicator A (EMA Early Retest) + Indicator B (SRSI Channel) with filter
//@version=5
indicator("GP - Combined A+B Filter", overlay=true)

// ============================================================
// ██████  INDICATOR A — EMA EARLY RETEST
// ============================================================

// ===== INPUT A =====
pullbackRatio = input.float(0.25, "Pullback depth (%)",  step=0.05, group="Indicator A")
earlyRatio    = input.float(0.90, "Early retest ratio",  step=0.01, group="Indicator A")
emaFastLen    = input.int(20,  "Fast EMA Length",  minval=1, group="Indicator A")
emaMidLen     = input.int(50,  "Mid EMA Length",   minval=1, group="Indicator A")
emaSlowLen    = input.int(100, "Slow EMA Length",  minval=1, group="Indicator A")

// ===== EMA =====
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

// ===== TREND FILTER =====
trendBuy  = emaMid > emaSlow
trendSell = emaMid < emaSlow

// ===== BUY STATE MACHINE =====
var int   stateBuy      = 0
var float emaCrossLowBuy = na
var float emaPeakBuy    = na
var bool  peakLockedBuy = false

crossUp = ta.crossover(emaFast, emaMid) or ta.crossover(emaFast, emaSlow)

if crossUp
    stateBuy       := 1
    emaCrossLowBuy := emaFast
    emaPeakBuy     := emaFast
    peakLockedBuy  := false

signalBuy = false

if stateBuy == 1
    if emaFast > emaFast[1]
        emaPeakBuy := math.max(emaPeakBuy, emaFast)
    if emaFast < emaFast[1] and emaFast[1] < emaFast[2]
        peakLockedBuy := true
        stateBuy      := 2

if stateBuy == 2 and peakLockedBuy
    totalHeightBuy = emaPeakBuy - emaCrossLowBuy
    pullDepthBuy   = emaPeakBuy - emaFast
    if totalHeightBuy > 0 and pullDepthBuy >= totalHeightBuy * pullbackRatio
        stateBuy := 3

if stateBuy == 3
    totalHeightBuy = emaPeakBuy - emaCrossLowBuy
    earlyLevelBuy  = emaPeakBuy - totalHeightBuy * (1 - earlyRatio)
    if emaFast >= earlyLevelBuy
        if trendBuy
            signalBuy := true
        stateBuy := 4

// ===== SELL STATE MACHINE =====
var int   stateSell        = 0
var float emaCrossHighSell = na
var float emaBottomSell    = na
var bool  bottomLockedSell = false

crossDown = ta.crossunder(emaFast, emaMid) or ta.crossunder(emaFast, emaSlow)

if crossDown
    stateSell        := 1
    emaCrossHighSell := emaFast
    emaBottomSell    := emaFast
    bottomLockedSell := false

signalSell = false

if stateSell == 1
    if emaFast < emaFast[1]
        emaBottomSell := math.min(emaBottomSell, emaFast)
    if emaFast > emaFast[1] and emaFast[1] > emaFast[2]
        bottomLockedSell := true
        stateSell        := 2

if stateSell == 2 and bottomLockedSell
    totalHeightSell = emaCrossHighSell - emaBottomSell
    pullDepthSell   = emaFast - emaBottomSell
    if totalHeightSell > 0 and pullDepthSell >= totalHeightSell * pullbackRatio
        stateSell := 3

if stateSell == 3
    totalHeightSell = emaCrossHighSell - emaBottomSell
    earlyLevelSell  = emaBottomSell + totalHeightSell * (1 - earlyRatio)
    if emaFast <= earlyLevelSell
        if trendSell
            signalSell := true
        stateSell := 4

// ============================================================
// ██████  INDICATOR B — SRSI CHANNEL (inline, overlay=true)
// ============================================================

// ===== INPUT B =====
smoothK   = input.int(3,  "K",            minval=1, group="Indicator B (SRSI)")
smoothD   = input.int(3,  "D",            minval=1, group="Indicator B (SRSI)")
lengthRSI = input.int(14, "RSI Length",   minval=1, group="Indicator B (SRSI)")
lengthS   = input.int(14, "Stoch Length", minval=1, group="Indicator B (SRSI)")

tf1_h = input.int(3,  "Time 1 (hours)", minval=1, group="Indicator B (SRSI)")
tf2_h = input.int(6,  "Time 2 (hours)", minval=1, group="Indicator B (SRSI)")
tf3_h = input.int(12, "Time 3 (hours)", minval=1, group="Indicator B (SRSI)")
tf4_h = input.int(24, "Time 4 (hours)", minval=1, group="Indicator B (SRSI)")

watchLow    = input.int(20, "Watch Low Level",  group="Indicator B (SRSI)")
watchHigh   = input.int(80, "Watch High Level", group="Indicator B (SRSI)")
confirmBars = input.int(10, "Confirm bars",     minval=1, group="Indicator B (SRSI)")

// ===== SRSI FUNCTION =====
f_srsi(_src) =>
    rsiVal = ta.rsi(_src, lengthRSI)
    k = ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, lengthS), smoothK)
    d = ta.sma(k, smoothD)
    k + d

ds_open  = f_srsi(open)
ds_high  = f_srsi(high)
ds_low   = f_srsi(low)
ds_close = f_srsi(close)

stArr = array.from(ds_open, ds_high, ds_low, ds_close)
stMin = array.min(stArr)
stMax = array.max(stArr)

// ===== MULTI-TF =====
tf1 = str.tostring(tf1_h * 60)
tf2 = str.tostring(tf2_h * 60)
tf3 = str.tostring(tf3_h * 60)
tf4 = str.tostring(tf4_h * 60)

a1 = request.security(syminfo.tickerid, tf1, stMin)
a2 = request.security(syminfo.tickerid, tf2, stMin)
a3 = request.security(syminfo.tickerid, tf3, stMin)
a4 = request.security(syminfo.tickerid, tf4, stMin)

b1 = request.security(syminfo.tickerid, tf1, stMax)
b2 = request.security(syminfo.tickerid, tf2, stMax)
b3 = request.security(syminfo.tickerid, tf3, stMax)
b4 = request.security(syminfo.tickerid, tf4, stMax)

c1 = request.security(syminfo.tickerid, tf1, ds_close)
c2 = request.security(syminfo.tickerid, tf2, ds_close)
c3 = request.security(syminfo.tickerid, tf3, ds_close)
c4 = request.security(syminfo.tickerid, tf4, ds_close)

oranMin   = (a1 + a2 + a3 + a4) * 100 / 800
oranMax   = (b1 + b2 + b3 + b4) * 100 / 800
oranClose = (c1 + c2 + c3 + c4) * 100 / 800

// ===== MID SIGNAL LOGIC =====
var bool watchFromLow  = false
var bool watchFromHigh = false

if oranClose <= watchLow and not watchFromLow and not watchFromHigh
    watchFromLow := true

if oranClose >= watchHigh and not watchFromHigh and not watchFromLow
    watchFromHigh := true

triggerFromLow  = watchFromLow  and oranClose >= 50
triggerFromHigh = watchFromHigh and oranClose <= 50

if triggerFromLow or triggerFromHigh
    watchFromLow  := false
    watchFromHigh := false

// ===== EXTREME CONFIRMATION =====
var float Dec        = na
var float Inc        = na
var bool  trackingDec = false
var bool  trackingInc = false
var int   decCount   = 0
var int   incCount   = 0

if triggerFromHigh
    Dec         := oranClose
    trackingDec := true
    decCount    := 0

if triggerFromLow
    Inc         := oranClose
    trackingInc := true
    incCount    := 0

confirmedMin = false
if trackingDec
    if oranClose < Dec
        Dec      := oranClose
        decCount := 0
    else
        decCount += 1
    if decCount >= confirmBars
        trackingDec  := false
        confirmedMin := true

confirmedMax = false
if trackingInc
    if oranClose > Inc
        Inc      := oranClose
        incCount := 0
    else
        incCount += 1
    if incCount >= confirmBars
        trackingInc  := false
        confirmedMax := true

// ============================================================
// ██████  FILTER: 1 WEEK LOOKBACK
// ============================================================
// Tính số bars tương đương 1 tuần trên TF hiện tại
barsPerWeek = math.max(1, math.round(7 * 24 * 60 * 60 / timeframe.in_seconds()))

// Trong barsPerWeek bar gần nhất, có confirmedMin / confirmedMax nào không?
recentConfirmedMin = ta.highest(confirmedMin ? 1 : 0, barsPerWeek) >= 1
recentConfirmedMax = ta.highest(confirmedMax ? 1 : 0, barsPerWeek) >= 1

// ===== FILTERED SIGNALS =====
filteredBuy  = signalBuy  and recentConfirmedMin
filteredSell = signalSell and recentConfirmedMax

// ============================================================
// ██████  PLOTS
// ============================================================
plot(emaFast, color=color.orange, linewidth=2, title="Fast EMA")
plot(emaMid,  color=color.blue,   linewidth=1, title="Mid EMA")
plot(emaSlow, color=color.gray,   linewidth=1, title="Slow EMA")

// Tín hiệu gốc (mờ) — tùy chọn, có thể xóa nếu không cần
plotshape(signalBuy  and not filteredBuy,  style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 75), size=size.tiny,  title="BUY (filtered out)")
plotshape(signalSell and not filteredSell, style=shape.triangledown, location=location.abovebar, color=color.new(color.red,  75), size=size.tiny,  title="SELL (filtered out)")

// Tín hiệu đã lọc (rõ nét)
plotshape(filteredBuy,  style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.small, title="BUY Signal (filtered)")
plotshape(filteredSell, style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.small, title="SELL Signal (filtered)")

// ============================================================
// ██████  ALERTS
// ============================================================
alertcondition(filteredBuy,              "Filtered BUY",  "A+B BUY signal — {{ticker}} {{interval}}")
alertcondition(filteredSell,             "Filtered SELL", "A+B SELL signal — {{ticker}} {{interval}}")
alertcondition(filteredBuy or filteredSell, "Filtered Signal", "A+B signal — {{ticker}} {{interval}}")
````
