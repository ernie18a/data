# Vantage-X [3.0]

- url: https://www.tradingview.com/script/AQxfmHcn-Vantage-X-3-0/
- type: indicator
- pine_id: PUB;96ba1e6cbbff4316b09931eb0693aca5
- version: 1.0

## Description

Vantage-X [3.0] — The Clean-Chart Trading Dashboard

Vantage-X [3.0] is an advanced, all-in-one trading dashboard built for one purpose: maximum clarity with zero chart clutter.

Designed for traders who rely on price action but still want high-quality confirmation, Vantage-X removes the noise of traditional indicators and replaces it with a clean, powerful dashboard that delivers only what matters — instantly.

No lines. No overlap. No distractions.
Just pure, structured market insight.

⸻

🔹 What’s New in Version 3.0

Version 3.0 expands Vantage-X beyond trend and structure — adding momentum and order flow intelligence directly into the dashboard:

• RSI (Relative Strength Index)

A core momentum strength indicator now built into the dashboard.
Quickly identify bullish vs bearish strength without needing a separate oscillator.

⸻

• Stochastic RSI (SRSI)

A fast-reacting momentum trigger used for timing entries.
Displays K momentum value only, helping you spot shifts in momentum at a glance.

⸻

• FLOW (Rolling Order Flow Proxy)

A dynamic, customizable flow indicator that tracks recent buying vs selling pressure based on a user-defined look-back period.

Perfect for:
• Spotting short-term momentum shifts
• Confirming breakouts and continuations
• Reading market pressure in real time

⸻

• PD FLOW (Previous Day Flow — Locked)

A static, session-based flow reading from the previous trading day.

This gives you:
• A clear directional bias from prior session activity
• Context for current-day setups
• An institutional-style “who was in control yesterday” view

⸻

🔹 Core Systems (Still Included)

Vantage-X [3.0] keeps everything that made 2.0 powerful:

✔ EMA 50 / EMA 200 Cross → Macro trend direction
✔ EMA 20 / EMA 50 Cross → Intraday trend confirmation
✔ EMA 9 / EMA 21 Cross → Fast momentum shifts
✔ Clean dashboard UI with color-coded signals
✔ Full toggle system for customization
✔ Multi-market & multi-timeframe compatibility

Everything works seamlessly together — no added clutter.

⸻

🔹 Core Purpose

The mission of Vantage-X hasn’t changed:

Eliminate chart noise. Enhance decision clarity.

Instead of stacking indicators on your chart, Vantage-X consolidates:
• Trend
• Momentum
• Flow
• Bias

…into one compact, easy-to-read dashboard.

So you can stay focused on what actually matters — price action.

⸻

🔹 Features

✔ Ultra-clean, non-intrusive dashboard
✔ Trend + momentum + flow in one system
✔ Real-time and previous-day context (FLOW + PD FLOW)
✔ Color-coded signals for instant interpretation
✔ Fully customizable with on/off toggles
✔ Designed for scalpers, day traders, and swing traders
✔ Optimized for fast decision-making on any device

⸻

🔹 Why Traders Use Vantage-X

Vantage-X is built for traders who want:

• Faster reads
• Cleaner charts
• Better timing
• Less hesitation
• More confidence in execution

Every signal is designed to support your decisions — not overwhelm them.

⸻

🔹 Free to Use — Built for Traders

Vantage-X [3.0] is completely free.
No locked features. No hidden upgrades.

Built for traders who value clarity over chaos.

## Source Code

````pine
//@version=6
indicator("Vantage-X [3.0]", overlay=true, max_labels_count=500)

// === SETTINGS ===
symbol = syminfo.tickerid
useLondonVWAP = input.bool(false, "Use London Session VWAP")
chopLen = 5
emaDistThreshold = input.float(5.0, "EMA Distance Threshold", minval=0.1)
emaSlopeThreshold = 0.01

groupMomentum = "Momentum Filters"

enableRSIFilter      = input.bool(true,  "Enable RSI Confirmation", group=groupMomentum)
enableStochRSIFilter = input.bool(true,  "Enable Stoch RSI Confirmation", group=groupMomentum)

showRSIOnDashboard      = input.bool(true, "Show RSI on Dashboard", group=groupMomentum)
showStochRSIOnDashboard = input.bool(true, "Show Stoch RSI on Dashboard", group=groupMomentum)

strictMode = input.bool(false, "Strict Confirmation Mode", group=groupMomentum)

rsiLen        = input.int(14, "RSI Length", minval=1, group=groupMomentum)
stochLen      = input.int(14, "Stoch RSI Length", minval=1, group=groupMomentum)
kSmoothing    = input.int(3, "%K Smoothing", minval=1, group=groupMomentum)
dSmoothing    = input.int(3, "%D Smoothing", minval=1, group=groupMomentum)

rsiBullLevel  = input.float(50.0, "RSI Bull Level", group=groupMomentum)
rsiBearLevel  = input.float(50.0, "RSI Bear Level", group=groupMomentum)

strictRsiBull = input.float(55.0, "Strict RSI Bull Level", group=groupMomentum)
strictRsiBear = input.float(45.0, "Strict RSI Bear Level", group=groupMomentum)

stochOB       = input.float(80.0, "Stoch RSI Overbought", group=groupMomentum)
stochOS       = input.float(20.0, "Stoch RSI Oversold", group=groupMomentum)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FLOW SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showFlow                = input.bool(true,  "Show FLOW", group="FLOW")
flowLookback            = input.int(8,      "FLOW Lookback", minval=3, maxval=200, group="FLOW")
flowVolLookback         = input.int(20,     "FLOW Volume Avg Lookback", minval=5, maxval=200, group="FLOW")
flowCompressionFactor   = input.float(0.75, "FLOW Compression Factor", step=0.05, group="FLOW")
flowVolumeFactor        = input.float(1.10, "FLOW Volume Concentration Factor", step=0.05, group="FLOW")
flowBreakoutFactor      = input.float(1.20, "FLOW Breakout Efficiency Factor", step=0.05, group="FLOW")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PD FLOW SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showPdFlow              = input.bool(true,  "Show PD FLOW", group="PD FLOW")
pdFlowCompressionFactor = input.float(0.75, "PD FLOW Compression Factor", step=0.05, group="PD FLOW")
pdFlowVolumeFactor      = input.float(1.10, "PD FLOW Volume Concentration Factor", step=0.05, group="PD FLOW")
pdFlowBreakoutFactor    = input.float(1.20, "PD FLOW Breakout Efficiency Factor", step=0.05, group="PD FLOW")

// Local TF distances
emaDist_9_20   = math.abs(9 - 20)
emaDist_20_50  = math.abs(20 - 50)
emaDist_50_200 = math.abs(50 - 200)

// 15M TF distances
emaDist_9_20_15m   = math.abs(9 - 20)
emaDist_20_50_15m  = math.abs(20 - 50)
emaDist_50_200_15m = math.abs(50 - 200)

// 1H TF distances
emaDist_9_20_1h   = math.abs(9 - 20)
emaDist_20_50_1h  = math.abs(20 - 50)
emaDist_50_200_1h = math.abs(50 - 200)

// 4H TF distances
emaDist_9_20_4h   = math.abs(9 -20)
emaDist_20_50_4h  = math.abs(20 - 50)
emaDist_50_200_4h = math.abs(50 - 200)

// === TOGGLES ===
showEMA9 = input.bool(true, "Show EMA9")
showEMA20 = input.bool(true, "Show EMA20")
showEMA50 = input.bool(true, "Show EMA50")
showEMA200 = input.bool(true, "Show EMA200")
showVWAP = input.bool(true, "Show VWAP")
showEMA9_15m = input.bool(true, "Show EMA9_15m")
showEMA20_15m = input.bool(true, "Show EMA20_15m")
showEMA50_15m = input.bool(true, "Show EMA50_15m")
showEMA200_15m = input.bool(true, "Show EMA200_15m")
showChopFilter = input.bool(true, "Show Chop Filter")
showEMA9_1h = input.bool(true, "Show EMA9_1h")
showEMA20_1h = input.bool(true, "Show EMA20_1h")
showEMA50_1h = input.bool(true, "Show EMA50_1h")
showEMA200_1h = input.bool(true, "Show EMA200_1h")
showVolumeSignal = input.bool(true, "Show Volume Signal")
showEMA9_4h = input.bool(true, "Show EMA9_4h")
showEMA20_4h = input.bool(true, "Show EMA20_4h")
showEMA50_4h = input.bool(true, "Show EMA50_4h")
showEMA200_4h = input.bool(true, "Show EMA200_4h")
showNyBias = input.bool(true, "Show NY Bias")
nyBiasBullThr   = input.float(0.66, "NY Bias Bull Threshold", step=0.01)
nyBiasBearThr   = input.float(0.33, "NY Bias Bear Threshold", step=0.01)

// === INDICATORS ===
ema9_4h = request.security(symbol, "240", ta.ema(close, 9))
ema20_4h = request.security(symbol, "240", ta.ema(close, 20))
ema50_4h = request.security(symbol, "240", ta.ema(close, 50))
ema200_4h = request.security(symbol, "240", ta.ema(close, 200))
ema9_1h = request.security(symbol, "60", ta.ema(close, 9))
ema20_1h = request.security(symbol, "60", ta.ema(close, 20))
ema50_1h = request.security(symbol, "60", ta.ema(close, 50))
ema200_1h = request.security(symbol, "60", ta.ema(close, 200))
ema9_15m = request.security(symbol, "15", ta.ema(close, 9))
ema20_15m = request.security(symbol, "15", ta.ema(close, 20))
ema50_15m = request.security(symbol, "15", ta.ema(close, 50))
ema200_15m = request.security(symbol, "15", ta.ema(close, 200))
ema9 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200  = ta.ema(close, 200)

// === VWAP SESSIONS ===
var float sumTPl = na
var float sumVoll = na
isLondonStart = (hour == 3 and minute == 0)
if isLondonStart
    sumTPl := 0.0
    sumVoll := 0.0
isLondonSession = (hour >= 3 and hour < 11)
if isLondonSession
    tpL = (high + low + close) / 3
    sumTPl += tpL * volume
    sumVoll += volume
vwapLondon = sumVoll > 0 ? sumTPl / sumVoll : na//@version=6


var float sumTPn = na
var float sumVoln = na
isNYStart = (hour == 9 and minute == 30)
if isNYStart
    sumTPn := 0.0
    sumVoln := 0.0
isNYSession = (hour == 9 and minute >= 30) or (hour > 9 and hour < 16)
if isNYSession
    tpN = (high + low + close) / 3
    sumTPn += tpN * volume
    sumVoln += volume
vwapNY = sumVoln > 0 ? sumTPn / sumVoln : na

vwap = useLondonVWAP ? vwapLondon : vwapNY

// === CHOP FILTER ===
avgBody   = ta.sma(math.abs(close - open), chopLen)
avgRange  = ta.sma(high - low, chopLen)
cond1     = avgBody < 0.25 * avgRange
insideBar = high < high[1] and low > low[1]
cond2     = insideBar and insideBar[1]
emaDist   = math.abs(ema20 - ema200)
emaSlope  = ema20 - ema20[1]
cond3     = emaDist < emaDistThreshold and math.abs(emaSlope) < emaSlopeThreshold
chop      = cond1 or cond2 or cond3 
SignalChop      = chop ? "Choppy" : "Trending"
SignalChopColor = chop ? color.gray :  color.green

// === SIGNAL LOGIC ===
signalEMA9_4h     = close > ema9_4h ? "Bullish" : close < ema9_4h ? "Bearish" : "Neutral"
signalEMA9_4hColor = signalEMA9_4h == "Bullish" ? color.green : signalEMA9_4h == "Bearish" ? color.red : color.gray

signalEMA20_4h     = close > ema20_4h ? "Bullish" : close < ema20_4h ? "Bearish" : "Neutral"
signalEMA20_4hColor = signalEMA20_4h == "Bullish" ? color.green : signalEMA20_4h == "Bearish" ? color.red : color.gray

signalEMA50_4h     = close > ema50_4h ? "Bullish" : close < ema50_4h ? "Bearish" : "Neutral"
signalEMA50_4hColor = signalEMA50_4h == "Bullish" ? color.green : signalEMA50_4h == "Bearish" ? color.red : color.gray

signalEMA200_4h     = close > ema200_4h ? "Bullish" : close < ema200_4h ? "Bearish" : "Neutral"
signalEMA200_4hColor = signalEMA200_4h == "Bullish" ? color.green : signalEMA200_4h == "Bearish" ? color.red : color.gray

signalEMA9_1h     = close > ema9_1h ? "Bullish" : close < ema9_1h ? "Bearish" : "Neutral"
signalEMA9_1hColor = signalEMA9_1h == "Bullish" ? color.green : signalEMA9_1h == "Bearish" ? color.red : color.gray

signalEMA20_1h     = close > ema20_1h ? "Bullish" : close < ema20_1h ? "Bearish" : "Neutral"
signalEMA20_1hColor = signalEMA20_1h == "Bullish" ? color.green : signalEMA20_1h == "Bearish" ? color.red : color.gray

signalEMA50_1h     = close > ema50_1h ? "Bullish" : close < ema50_1h ? "Bearish" : "Neutral"
signalEMA50_1hColor = signalEMA50_1h == "Bullish" ? color.green : signalEMA50_1h == "Bearish" ? color.red : color.gray

signalEMA200_1h     = close > ema200_1h ? "Bullish" : close < ema200_1h ? "Bearish" : "Neutral"
signalEMA200_1hColor = signalEMA200_1h == "Bullish" ? color.green : signalEMA200_1h == "Bearish" ? color.red : color.gray

signalVWAP     = close > vwap ? "Bullish" : close < vwap ? "Bearish" : "Neutral"
signalVWAPColor = signalVWAP == "Bullish" ? color.green : signalVWAP == "Bearish" ? color.red : color.gray

signalEMA = close > ema20_1h ? "Bullish" : close < ema20_1h ? "Bearish" : "Neutral"

signalVolume     = str.tostring(volume, format.volume)
signalVolumeColor = close > open ? color.lime : close < open ? color.red : color.gray

signalEMA9_15m     = close > ema9_15m ? "Bullish" : close < ema9_15m ? "Bearish" : "Neutral"
signalEMA9_15mColor = signalEMA9_15m == "Bullish" ? color.green : signalEMA9_15m == "Bearish" ? color.red : color.gray

signalEMA20_15m     = close > ema20_15m ? "Bullish" : close < ema20_15m ? "Bearish" : "Neutral"
signalEMA20_15mColor = signalEMA20_15m == "Bullish" ? color.green : signalEMA20_15m == "Bearish" ? color.red : color.gray

signalEMA50_15m     = close > ema50_15m ? "Bullish" : close < ema50_15m ? "Bearish" : "Neutral"
signalEMA50_15mColor = signalEMA50_15m == "Bullish" ? color.green : signalEMA50_15m == "Bearish" ? color.red : color.gray

signalEMA200_15m     = close > ema200_15m ? "Bullish" : close < ema200_15m ? "Bearish" : "Neutral"
signalEMA200_15mColor = signalEMA200_15m == "Bullish" ? color.green : signalEMA200_15m == "Bearish" ? color.red : color.gray

signalEMA9    = close > ema9 ? "Bullish" : close < ema9 ? "Bearish" : "Neutral"
signalEMA9Color = signalEMA9 == "Bullish" ? color.green : signalEMA9 == "Bearish" ? color.red : color.gray

signalEMA20    = close > ema20 ? "Bullish" : close < ema20 ? "Bearish" : "Neutral"
signalEMA20Color = signalEMA20 == "Bullish" ? color.green : signalEMA20 == "Bearish" ? color.red : color.gray

signalEMA50    = close > ema50 ? "Bullish" : close < ema50 ? "Bearish" : "Neutral"
signalEMA50Color = signalEMA50 == "Bullish" ? color.green : signalEMA50 == "Bearish" ? color.red : color.gray

signalEMA200    = close > ema200 ? "Bullish" : close < ema200 ? "Bearish" : "Neutral"
signalEMA200Color = signalEMA200 == "Bullish" ? color.green : signalEMA200 == "Bearish" ? color.red : color.gray

//@version=6
// === VX • EMA 50/200 Cross (Dashboard Row) ===

// --- Setting (toggle) ---
showEMA50_200 = input.bool(true, "EMA 50/200 Row")

// --- Calc (current chart timeframe) ---
float e20 = ta.ema(close, 20)
float e50 = ta.ema(close, 50)
float e200 = ta.ema(close, 200)

ema50200_bull = e50 > e200
ema50200_bear = e50 < e200
ema50200_flat = not ema50200_bull and not ema50200_bear
ema50200_text  = ema50200_bull ? "Bullish" : ema50200_bear ? "Bearish" : "Flat —"
ema50200_color = ema50200_bull ? color.lime : ema50200_bear ? color.red : color.gray

const int EMA50200_Signal = 5   // next free row under your 4H rows

// (Optional) expose booleans for other logic
ema50200_isBull = ema50200_bull
ema50200_isBear = ema50200_bear
ema50200_isFlat = ema50200_flat

//@version=6
// === VX • EMA 20/50 Cross (Dashboard Row) ===

// --- Setting (toggle) ---
var string _vxGrp = "Dashboard: Signals"
showEMA20_50 = input.bool(true, "EMA 20/50 Row", group=_vxGrp)

ema2050_bull = e20 > e50
ema2050_bear = e20 < e50
ema2050_flat = not ema2050_bull and not ema2050_bear
ema2050_text  = ema2050_bull ? "Bullish" : ema2050_bear ? "Bearish" : "Flat —"
ema2050_color = ema2050_bull ? color.lime : ema2050_bear ? color.red : color.gray

const int EMA2050_Signal = 5   // next free row under your 4H rows

// (Optional) expose booleans for other logic
ema2050_isBull = ema2050_bull
ema2050_isBear = ema2050_bear
ema2050_isFlat = ema2050_flat

//@version=6
// === VX • EMA 9/21 Cross (Dashboard Row) ===

// --- Setting (toggle) ---
showEMA9_21 = input.bool(true, "EMA 9/21 Row", group=_vxGrp)

// --- Calc (current chart timeframe) ---
float e9 = ta.ema(close, 9)
float e21 = ta.ema(close, 21)

ema921_bull = e9 > e21
ema921_bear = e9 < e21
ema921_flat = not ema921_bull and not ema921_bear
ema921_text  = ema921_bull ? "Bullish" : ema921_bear ? "Bearish" : "Flat —"
ema921_color = ema921_bull ? color.lime : ema921_bear ? color.red : color.gray

const int EMA921_Signal = 5   // next free row under your 4H rows

// (Optional) expose booleans for other logic
ema921_isBull = ema921_bull
ema921_isBear = ema921_bear
ema921_isFlat = ema921_flat

//@version=6
// === VX • EMA 5/13 Cross (Dashboard Row) ===

// --- Setting (toggle) ---
showEMA5_13 = input.bool(true, "EMA 5/13 Row", group=_vxGrp)

// --- Calc (current chart timeframe) ---
float e5 = ta.ema(close, 5)
float e13 = ta.ema(close, 13)

ema513_bull = e5 > e13
ema513_bear = e5 < e13
ema513_flat = not ema513_bull and not ema513_bear
ema513_text  = ema513_bull ? "Bullish" : ema513_bear ? "Bearish" : "Flat —"
ema513_color = ema513_bull ? color.lime : ema513_bear ? color.red : color.gray

const int EMA513_Signal = 5   // next free row under your 4H rows

// (Optional) expose booleans for other logic
ema513_isBull = ema513_bull
ema513_isBear = ema513_bear
ema513_isFlat = ema513_flat

// --- FLOW (ROLLING) ---
flowRangeNow = ta.highest(high, flowLookback) - ta.lowest(low, flowLookback)
flowRangeAvg = ta.sma(high - low, flowLookback) * flowLookback

flowAvgVol = ta.sma(volume, flowVolLookback)
flowZoneVol = ta.sma(volume, flowLookback) * flowLookback
flowZoneAvgVolExpected = flowAvgVol * flowLookback

flowIsCompressed = flowRangeNow < (flowRangeAvg * flowCompressionFactor)
flowHasVolumeConcentration = flowZoneVol > (flowZoneAvgVolExpected * flowVolumeFactor)
flowIsBase = flowIsCompressed and flowHasVolumeConcentration

var float flowBaseHigh = na
var float flowBaseLow  = na

flowHighest = ta.highest(high, flowLookback)
flowLowest  = ta.lowest(low, flowLookback)

if flowIsBase
    flowBaseHigh := flowHighest
    flowBaseLow  := flowLowest

flowCurrBarRange = high - low
flowAvgBarRange  = ta.sma(high - low, flowLookback)

flowBullBreakout = not na(flowBaseHigh) and high > flowBaseHigh and close > flowBaseHigh and flowCurrBarRange > flowAvgBarRange * flowBreakoutFactor
flowBearBreakout = not na(flowBaseLow)  and low < flowBaseLow  and close < flowBaseLow  and flowCurrBarRange > flowAvgBarRange * flowBreakoutFactor

flowBullStructure = close > open and close > close[1]
flowBearStructure = close < open and close < close[1]

string signalFlow = "Neutral"
color signalFlowColor = color.gray
int flowValue = 0

if flowBullBreakout and flowBullStructure
    signalFlow := "Bull"
    signalFlowColor := color.lime
    flowValue := 1
else if flowBearBreakout and flowBearStructure
    signalFlow := "Bear"
    signalFlowColor := color.red
    flowValue := -1
else if flowIsBase
    signalFlow := "Base"
    signalFlowColor := color.orange
    flowValue := 0
else
    signalFlow := "Neutral"
    signalFlowColor := color.gray
    flowValue := 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PD FLOW (PREVIOUS NY SESSION LOCKED)
// Uses ONLY previous NY regular session: 9:30 AM ET → 4:00 PM ET
// Output: Bull / Bear / Base / Neutral
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
nySessionPd   = "0930-1600"
inNySessionPd = not na(time(timeframe.period, nySessionPd, "America/New_York"))
newNySessionPd = inNySessionPd and not inNySessionPd[1]
endNySessionPd = not inNySessionPd and inNySessionPd[1]

// Track CURRENT NY session stats
var float currPdNyHigh = na
var float currPdNyLow = na
var float currPdNyOpen = na
var float currPdNyClose = na
var float currPdNyVol = na
var float currPdNyRangeSum = na
var int   currPdNyBars = 0

if newNySessionPd
    currPdNyHigh := high
    currPdNyLow := low
    currPdNyOpen := open
    currPdNyClose := close
    currPdNyVol := volume
    currPdNyRangeSum := high - low
    currPdNyBars := 1
else if inNySessionPd
    currPdNyHigh := math.max(currPdNyHigh, high)
    currPdNyLow := math.min(currPdNyLow, low)
    currPdNyClose := close
    currPdNyVol += volume
    currPdNyRangeSum += (high - low)
    currPdNyBars += 1

// Store PREVIOUS NY session stats (locked)
var float prevPdNyHigh = na
var float prevPdNyLow = na
var float prevPdNyOpen = na
var float prevPdNyClose = na
var float prevPdNyVol = na
var int   prevPdNyBars = na
var float prevPdNyAvgBarRange = na

if endNySessionPd
    prevPdNyHigh := currPdNyHigh
    prevPdNyLow := currPdNyLow
    prevPdNyOpen := currPdNyOpen
    prevPdNyClose := currPdNyClose
    prevPdNyVol := currPdNyVol
    prevPdNyBars := currPdNyBars
    prevPdNyAvgBarRange := currPdNyBars > 0 ? currPdNyRangeSum / currPdNyBars : na

// Previous NY session measurements
float prevPdNyRange = na
float prevPdNyBody = na
int prevPdNyDir = 0

if not na(prevPdNyHigh) and not na(prevPdNyLow) and not na(prevPdNyOpen) and not na(prevPdNyClose)
    prevPdNyRange := prevPdNyHigh - prevPdNyLow
    prevPdNyBody := math.abs(prevPdNyClose - prevPdNyOpen)
    prevPdNyDir := prevPdNyClose > prevPdNyOpen ? 1 : prevPdNyClose < prevPdNyOpen ? -1 : 0

// Baseline volume comparison
pdNyAvgVolBaseline = request.security(syminfo.tickerid, "D", ta.sma(volume, 20)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// BASE logic
pdNyIsCompressed = prevPdNyRange > 0 ? (prevPdNyBody / prevPdNyRange) < pdFlowCompressionFactor : false
pdNyHasVolumeConcentration = not na(pdNyAvgVolBaseline) and not na(prevPdNyVol) ? prevPdNyVol > (pdNyAvgVolBaseline * pdFlowVolumeFactor) : false
pdNyIsBase = pdNyIsCompressed and pdNyHasVolumeConcentration

// Efficient directional session logic
pdNyBullEfficient = not na(prevPdNyRange) and prevPdNyRange > 0 and prevPdNyDir == 1 and (prevPdNyBody / prevPdNyRange) > (pdFlowBreakoutFactor / 2.0)
pdNyBearEfficient = not na(prevPdNyRange) and prevPdNyRange > 0 and prevPdNyDir == -1 and (prevPdNyBody / prevPdNyRange) > (pdFlowBreakoutFactor / 2.0)

string signalPdFlow = "Neutral"
color signalPdFlowColor = color.gray
int pdFlowValue = 0

if pdNyBullEfficient and not pdNyIsBase
    signalPdFlow := "Bull"
    signalPdFlowColor := color.lime
    pdFlowValue := 1
else if pdNyBearEfficient and not pdNyIsBase
    signalPdFlow := "Bear"
    signalPdFlowColor := color.red
    pdFlowValue := -1
else if pdNyIsBase
    signalPdFlow := "Base"
    signalPdFlowColor := color.orange
    pdFlowValue := 0
else
    signalPdFlow := "Neutral"
    signalPdFlowColor := color.gray
    pdFlowValue := 0

// === RSI + STOCH RSI LOGIC ===
rsiValue = ta.rsi(close, rsiLen)

rsiLowest  = ta.lowest(rsiValue, stochLen)
rsiHighest = ta.highest(rsiValue, stochLen)
stochBase  = (rsiHighest - rsiLowest) != 0 ? ((rsiValue - rsiLowest) / (rsiHighest - rsiLowest)) * 100 : 0.0

k = ta.sma(stochBase, kSmoothing)
d = ta.sma(k, dSmoothing)

// RSI states
rsiBull_normal = rsiValue > rsiBullLevel
rsiBear_normal = rsiValue < rsiBearLevel

rsiBull_strict = rsiValue > strictRsiBull
rsiBear_strict = rsiValue < strictRsiBear

rsiBull = strictMode ? rsiBull_strict : rsiBull_normal
rsiBear = strictMode ? rsiBear_strict : rsiBear_normal
rsiNeutral = not rsiBull and not rsiBear

// Stoch RSI states
stochBull_normal = k > d
stochBear_normal = k < d

stochBull_strict = k > d and k < stochOB
stochBear_strict = k < d and k > stochOS

stochBull = strictMode ? stochBull_strict : stochBull_normal
stochBear = strictMode ? stochBear_strict : stochBear_normal

// Confirmation logic
rsiBullPass   = not enableRSIFilter or rsiBull
rsiBearPass   = not enableRSIFilter or rsiBear
stochBullPass = not enableStochRSIFilter or stochBull
stochBearPass = not enableStochRSIFilter or stochBear

bullMomentumConfirmed = rsiBullPass and stochBullPass
bearMomentumConfirmed = rsiBearPass and stochBearPass

// Dashboard text
rsiRounded = math.round(rsiValue * 10) / 10

rsiNumberColor =
     not enableRSIFilter ? color.gray :
     rsiRounded > 50.0 ? color.lime :
     rsiRounded < 50.0 ? color.red :
     color.gray

signalRSI =
     not enableRSIFilter ? "Off" :
     str.tostring(rsiRounded, "#.0")

// === STOCH RSI (K ONLY DISPLAY) ===
stochRoundedK = math.round(k * 10) / 10

signalStochRSI =
     not enableStochRSIFilter ? "Off" :
     str.tostring(stochRoundedK, "#.0")

signalStochRSIColor =
     not enableStochRSIFilter ? color.gray :
     k > d ? color.lime :
     k < d ? color.red :
     color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREVIOUS NY SESSION BIAS (REPLACES DAILY BIAS)
// Uses previous NY regular session only: 9:30 AM ET → 4:00 PM ET
// Stores previous NY High / Low / Close
// Bias is based on where previous NY Close finished inside previous NY range
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
nySession   = "0930-1600"
inNySession = not na(time(timeframe.period, nySession, "America/New_York"))
newNySession = inNySession and not inNySession[1]
endNySession = not inNySession and inNySession[1]

var float currNyHigh  = na
var float currNyLow   = na
var float currNyClose = na

if newNySession
    currNyHigh  := high
    currNyLow   := low
    currNyClose := close
else if inNySession
    currNyHigh  := math.max(currNyHigh, high)
    currNyLow   := math.min(currNyLow, low)
    currNyClose := close

var float prevNyHigh  = na
var float prevNyLow   = na
var float prevNyClose = na

if endNySession
    prevNyHigh  := currNyHigh
    prevNyLow   := currNyLow
    prevNyClose := currNyClose

float nyRange = na
float nyClosePos = na

if not na(prevNyHigh) and not na(prevNyLow) and not na(prevNyClose)
    nyRange := prevNyHigh - prevNyLow
    nyClosePos := nyRange > 0 ? (prevNyClose - prevNyLow) / nyRange : 0.5

string nyBiasText = "Neutral"
color nyBiasColor = color.gray
int nyBiasValue = 0

if not na(nyClosePos)
    if nyClosePos > nyBiasBullThr
        nyBiasText := "Bull"
        nyBiasColor := color.green
        nyBiasValue := 1
    else if nyClosePos < nyBiasBearThr
        nyBiasText := "Bear"
        nyBiasColor := color.red
        nyBiasValue := -1
    else
        nyBiasText := "Neutral"
        nyBiasColor := color.gray
        nyBiasValue := 0

// === Dashboard Text Size Setting ===
dashboardTextSizeInput = input.string("Small", "Dashboard Text Size", options = ["Tiny", "Small", "Medium", "Large"], group = "Dashboard Settings")

// === Convert setting to Pine text size ===
dashboardTextSize = switch dashboardTextSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Medium" => size.normal
    => size.large

// === DASHBOARD ===
var table dashboard = table.new(position.top_right, 2, 32, border_width=1)

if barstate.islast
    table.clear(dashboard, 0, 0, 1, 31)

    int row = 0

    table.cell(dashboard, 0, row, "Indicator", text_color=color.white, bgcolor=color.black, text_size = dashboardTextSize)
    table.cell(dashboard, 1, row, "Signal",    text_color=color.white, bgcolor=color.black, text_size = dashboardTextSize)
    row += 1

    if showNyBias
        table.cell(dashboard, 0, row, "NY Bias", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, nyBiasText, text_color=nyBiasColor, text_size = dashboardTextSize)
        row += 1

    if showVolumeSignal
        table.cell(dashboard, 0, row, "Volume", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalVolume, text_color=signalVolumeColor, text_size = dashboardTextSize)
        row += 1

    if showPdFlow
        table.cell(dashboard, 0, row, "PD Flow", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalPdFlow, text_color=signalPdFlowColor, text_size = dashboardTextSize)
        row += 1

    if showFlow
        table.cell(dashboard, 0, row, "FLOW", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalFlow, text_color=signalFlowColor, text_size = dashboardTextSize)
        row += 1

    if showRSIOnDashboard
        table.cell(dashboard, 0, row, "RSI", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalRSI, text_color=rsiNumberColor, text_size = dashboardTextSize)
        row += 1

    if showStochRSIOnDashboard
        table.cell(dashboard, 0, row, "SRSI", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalStochRSI, text_color=signalStochRSIColor, text_size = dashboardTextSize)
        row += 1

    if showChopFilter
        table.cell(dashboard, 0, row, "Chop Filter", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, SignalChop, text_color=SignalChopColor, text_size = dashboardTextSize)
        row += 1

    if showVWAP
        table.cell(dashboard, 0, row, "VWAP", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalVWAP, text_color=signalVWAPColor, text_size = dashboardTextSize)
        row += 1

    if showEMA5_13
        table.cell(dashboard, 0, row, "5/13 Cross", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, ema513_text, text_color=ema513_color, text_size = dashboardTextSize)
        row += 1

    if showEMA9_21
        table.cell(dashboard, 0, row, "9/21 Cross", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, ema921_text, text_color=ema921_color, text_size = dashboardTextSize)
        row += 1

    if showEMA20_50
        table.cell(dashboard, 0, row, "20/50 Cross", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, ema2050_text, text_color=ema2050_color, text_size = dashboardTextSize)
        row += 1

    if showEMA50_200
        table.cell(dashboard, 0, row, "50/200 Cross", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, ema50200_text, text_color=ema50200_color, text_size = dashboardTextSize)
        row += 1

    if showEMA9
        table.cell(dashboard, 0, row, "EMA9", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA9, text_color=signalEMA9Color, text_size = dashboardTextSize)
        row += 1

    if showEMA20
        table.cell(dashboard, 0, row, "EMA20", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA20, text_color=signalEMA20Color, text_size = dashboardTextSize)
        row += 1

    if showEMA50
        table.cell(dashboard, 0, row, "EMA50", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA50, text_color=signalEMA50Color, text_size = dashboardTextSize)
        row += 1

    if showEMA200
        table.cell(dashboard, 0, row, "EMA200", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA200, text_color=signalEMA200Color, text_size = dashboardTextSize)
        row += 1

    if showEMA9_15m
        table.cell(dashboard, 0, row, "EMA9_15M", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA9_15m, text_color=signalEMA9_15mColor, text_size = dashboardTextSize)
        row += 1

    if showEMA20_15m
        table.cell(dashboard, 0, row, "EMA20_15M", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA20_15m, text_color=signalEMA20_15mColor, text_size = dashboardTextSize)
        row += 1

    if showEMA50_15m
        table.cell(dashboard, 0, row, "EMA50_15M", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA50_15m, text_color=signalEMA50_15mColor, text_size = dashboardTextSize)
        row += 1

    if showEMA200_15m
        table.cell(dashboard, 0, row, "EMA200_15M", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA200_15m, text_color=signalEMA200_15mColor, text_size = dashboardTextSize)
        row += 1

    if showEMA9_1h
        table.cell(dashboard, 0, row, "EMA9_1H", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA9_1h, text_color=signalEMA9_1hColor, text_size = dashboardTextSize)
        row += 1

    if showEMA20_1h
        table.cell(dashboard, 0, row, "EMA20_1H", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA20_1h, text_color=signalEMA20_1hColor, text_size = dashboardTextSize)
        row += 1

    if showEMA50_1h
        table.cell(dashboard, 0, row, "EMA50_1H", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA50_1h, text_color=signalEMA50_1hColor, text_size = dashboardTextSize)
        row += 1

    if showEMA200_1h
        table.cell(dashboard, 0, row, "EMA200_1H", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA200_1h, text_color=signalEMA200_1hColor, text_size = dashboardTextSize)
        row += 1

    if showEMA9_4h
        table.cell(dashboard, 0, row, "EMA9_4H", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA9_4h, text_color=signalEMA9_4hColor, text_size = dashboardTextSize)
        row += 1

    if showEMA20_4h
        table.cell(dashboard, 0, row, "EMA20_4H", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA20_4h, text_color=signalEMA20_4hColor, text_size = dashboardTextSize)
        row += 1

    if showEMA50_4h
        table.cell(dashboard, 0, row, "EMA50_4H", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA50_4h, text_color=signalEMA50_4hColor, text_size = dashboardTextSize)
        row += 1

    if showEMA200_4h
        table.cell(dashboard, 0, row, "EMA200_4H", text_color=color.white, text_size = dashboardTextSize)
        table.cell(dashboard, 1, row, signalEMA200_4h, text_color=signalEMA200_4hColor, text_size = dashboardTextSize)
        row += 1
````
