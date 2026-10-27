# byquan CombinedA+B (Gp 1H vs CHIBAO A)

- url: https://www.tradingview.com/script/CkEq23KT/
- type: indicator
- pine_id: PUB;2e3c2141dcd34ba3905939850a36c11e
- version: 1.0

## Description

// GP - Combined EMA Early Retest + SRSI Channel Filter [Anti-Repaint]

This script combines a **price structure-based early retest system** with a **multi-timeframe momentum confirmation filter**, specifically engineered to minimize repainting and improve signal reliability.

The core concept is to detect high-probability pullback entries in the direction of the trend, but only when supported by confirmed momentum reversal from higher timeframes.

### Indicator A – EMA Early Retest System
- Uses a triple EMA setup (Fast 20 / Mid 50 / Slow 100 by default) to determine trend direction.
- Detects impulse moves when the fast EMA crosses mid or slow EMA.
- Tracks pullback depth as a percentage of the impulse wave.
- Triggers an early retest signal when price returns to a defined zone (default 90%) before a full retracement.
- Includes `barstate.isconfirmed` logic to ensure signals are generated only on closed bars, significantly reducing intra-bar false triggers.

### Indicator B – Multi-Timeframe SRSI Channel Filter
- Calculates Stochastic RSI using open, high, low, and close for more comprehensive momentum reading.
- Aggregates data from four higher timeframes (default: 3H, 6H, 12H, 24H).
- Detects momentum extremes and waits for confirmation over a user-defined number of bars.
- Uses `security()` with `[1]` offset and proper lookahead settings to minimize repainting from higher timeframes.

### Combined Filtered Signals
Final signals are only valid when:
- The EMA Early Retest logic generates a setup **and**
- The SRSI Channel has recently confirmed a momentum extreme reversal within the past week (1-week lookback filter).

This dual confirmation greatly reduces noise and increases the quality of signals.

### Visuals & Signals
- **Orange**: Fast EMA (main signal line)
- **Blue**: Mid EMA
- **Gray**: Slow EMA (trend filter)
- **Light triangles**: Raw EMA Early Retest signals (often filtered out)
- **Bright Lime/Red triangles**: **Final filtered high-probability signals**

### How to Use
- **Long Signal** (Lime triangle): Early pullback retest in uptrend + recent SRSI momentum low confirmation.
- **Short Signal** (Red triangle): Early pullback retest in downtrend + recent SRSI momentum high confirmation.
- Best used on **5m, 15m, 30m, and 1H** timeframes for intraday and swing trading.
- Strongly recommended to combine with price action, key levels, or market structure for better results.

### Key Features
- Anti-repainting measures on both EMA logic and higher timeframe data.
- 1-week momentum lookback filter for stronger confluence.
- Clear visual distinction between raw and filtered signals.

This is not a basic mashup. The real value lies in the intelligent integration of **early price retest logic** with **multi-timeframe momentum confirmation**, plus careful anti-repainting implementation.

The script is open-source and shared for educational and research purposes only. It is not financial advice. Always backtest thoroughly and use proper risk management.

Feedback is welcome!

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
pullbackRatio = input.float(0.05, "Pullback depth (%)",  step=0.05, group="Indicator A")
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
var int   stateBuy       = 0
var float emaCrossLowBuy = na
var float emaPeakBuy     = na
var bool  peakLockedBuy  = false

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
        // ✅ FIX: Chỉ phát signal khi nến đã đóng hoàn toàn
        // Tránh trường hợp intra-bar thỏa điều kiện rồi rút lại
        if trendBuy and barstate.isconfirmed
            signalBuy := true
        // ✅ FIX: Chỉ chuyển state khi nến đã confirmed
        // Tránh state chuyển sang 4 giữa chừng rồi không thể quay lại
        if barstate.isconfirmed
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
        // ✅ FIX: Chỉ phát signal khi nến đã đóng hoàn toàn
        if trendSell and barstate.isconfirmed
            signalSell := true
        // ✅ FIX: Chỉ chuyển state khi nến đã confirmed
        if barstate.isconfirmed
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
confirmBars = input.int(50, "Confirm bars",     minval=1, group="Indicator B (SRSI)")

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

// ✅ FIX: Thêm barmerge.lookahead_off (default) và dùng close[1] của TF cao
// để chỉ lấy giá trị từ nến đã đóng trên timeframe cao hơn,
// tránh repainting từ nến TF cao đang hình thành
a1 = request.security(syminfo.tickerid, tf1, stMin[1], lookahead=barmerge.lookahead_on)
a2 = request.security(syminfo.tickerid, tf2, stMin[1], lookahead=barmerge.lookahead_on)
a3 = request.security(syminfo.tickerid, tf3, stMin[1], lookahead=barmerge.lookahead_on)
a4 = request.security(syminfo.tickerid, tf4, stMin[1], lookahead=barmerge.lookahead_on)

b1 = request.security(syminfo.tickerid, tf1, stMax[1], lookahead=barmerge.lookahead_on)
b2 = request.security(syminfo.tickerid, tf2, stMax[1], lookahead=barmerge.lookahead_on)
b3 = request.security(syminfo.tickerid, tf3, stMax[1], lookahead=barmerge.lookahead_on)
b4 = request.security(syminfo.tickerid, tf4, stMax[1], lookahead=barmerge.lookahead_on)

c1 = request.security(syminfo.tickerid, tf1, ds_close[1], lookahead=barmerge.lookahead_on)
c2 = request.security(syminfo.tickerid, tf2, ds_close[1], lookahead=barmerge.lookahead_on)
c3 = request.security(syminfo.tickerid, tf3, ds_close[1], lookahead=barmerge.lookahead_on)
c4 = request.security(syminfo.tickerid, tf4, ds_close[1], lookahead=barmerge.lookahead_on)

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
var float Dec         = na
var float Inc         = na
var bool  trackingDec = false
var bool  trackingInc = false
var int   decCount    = 0
var int   incCount    = 0

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
barsPerWeek = math.max(1, math.round(7 * 24 * 60 * 60 / timeframe.in_seconds()))

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

plotshape(signalBuy  and not filteredBuy,  style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 75), size=size.tiny,  title="BUY (filtered out)")
plotshape(signalSell and not filteredSell, style=shape.triangledown, location=location.abovebar, color=color.new(color.red,  75), size=size.tiny,  title="SELL (filtered out)")

plotshape(filteredBuy,  style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.small, title="BUY Signal (filtered)")
plotshape(filteredSell, style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.small, title="SELL Signal (filtered)")

// ============================================================
// ██████  ALERTS
// ============================================================
// ✅ FIX: barstate.isconfirmed đã được đưa vào điều kiện signal ở trên
// nên alertcondition ở đây sẽ tự động chỉ fire khi nến đã đóng
alertcondition(filteredBuy,               "Filtered BUY",    "A+B BUY signal — {{ticker}} {{interval}}")
alertcondition(filteredSell,              "Filtered SELL",   "A+B SELL signal — {{ticker}} {{interval}}")
alertcondition(filteredBuy or filteredSell, "Filtered Signal", "A+B signal — {{ticker}} {{interval}}")
````
