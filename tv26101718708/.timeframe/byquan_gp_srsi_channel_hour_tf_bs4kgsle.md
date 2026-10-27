# byquan GP - SRSI Channel (Hour TF)

- url: https://www.tradingview.com/script/BS4kgsLe/
- type: indicator
- pine_id: PUB;fc5b0131e9f843d5a87a0542945a660d
- version: 1.0

## Description

// GP - SRSI Channel (Multi-Timeframe Hourly)

This indicator displays a **Multi-Timeframe Stochastic RSI Channel** designed to identify momentum extremes and confirmed reversal zones using higher timeframe aggregation.

Instead of relying on a single timeframe SRSI, this script aggregates data from four higher hourly timeframes (default: 3H, 6H, 12H, 24H) to provide a more robust and stable view of momentum conditions.

### Core Components

**SRSI Calculation**
- Stochastic RSI (K+D smoothed) is calculated on open, high, low, and close.
- This creates a more comprehensive representation of momentum at each bar.

**Multi-Timeframe Channel**
- Minimum and Maximum SRSI values are collected across the four selected higher timeframes.
- The channel (filled area between Min and Max) shows the current momentum range across different scales.
- The white line represents the averaged SRSI Close value.

**Background Zones**
- **Green** (0-20): Oversold zone
- **Blue** (20-50): Accumulation / Recovery zone
- **Orange** (50-80): Distribution / Weakening zone  
- **Red** (80-100): Overbought zone

These zones help traders quickly assess the overall momentum environment.

### Signal Logic

**Mid-Level Transition Detection**
- Watches when the SRSI exits extreme zones (below 20 or above 80) and crosses the 50 mid-level.
- Yellow circle at 50 marks potential momentum shift points.

**Confirmed Extreme Reversal**
- After exiting an extreme zone, the script tracks whether price continues moving away from the extreme for a user-defined number of bars (`Confirm bars`).
- **Lime circle** = Confirmed momentum low (potential bullish reversal)
- **Red circle** = Confirmed momentum high (potential bearish reversal)

This confirmation mechanism significantly reduces premature signals by waiting for sustained momentum movement after leaving extreme territories.

### How to Use

- **Bullish Reversal**: Look for the price entering the green oversold zone, then a **lime circle** appearing after confirmation. This suggests strengthening momentum across multiple timeframes.
- **Bearish Reversal**: Look for the price entering the red overbought zone, then a **red circle** appearing. This indicates weakening momentum.
- The channel width shows how broad the momentum disagreement is across timeframes — narrower channel = stronger consensus.
- Best used as a **momentum filter** or confluence tool together with price action, support/resistance, or other structure-based setups.

### Recommended Settings & Timeframes
- Works on all timeframes, but performs best on **5m, 15m, 30m, and 1H** charts for intraday and swing trading.
- Default higher timeframes (3H–24H) provide excellent balance between responsiveness and reliability.
- Increase `Confirm bars` for higher quality but fewer signals.
- Adjust `Watch Low/High Level` according to the volatility of the instrument.

This script is not a simple copy of existing SRSI indicators. Its value lies in the **multi-timeframe channel construction**, **dynamic extreme confirmation logic**, and the combination of visual zones with clear reversal markers.

The indicator is open-source and shared for educational purposes only. It is not financial advice. Always backtest thoroughly and use proper risk management.

Feedback is highly appreciated!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 abdelgayoumriddersa105382

//@version=5
indicator("byquan GP - SRSI Channel (Hour TF)", shorttitle="GP - SRSI Channel H", overlay=false)

// =====================================================
// INPUTS
// =====================================================
smoothK   = input.int(3,  "K", minval=1)
smoothD   = input.int(3,  "D", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthS   = input.int(14, "Stoch Length", minval=1)

// ==== Timeframes in HOURS ====
tf1_h = input.int(3,  "Time 1 (hours)", minval=1)
tf2_h = input.int(6,  "Time 2 (hours)", minval=1)
tf3_h = input.int(12, "Time 3 (hours)", minval=1)
tf4_h = input.int(24, "Time 4 (hours)", minval=1)

// =====================================================
// LEVEL INPUTS
// =====================================================
watchLow    = input.int(20, "Watch Low Level")
watchHigh   = input.int(80, "Watch High Level")
midLevel    = input.int(50, "Mid Level")
confirmBars = input.int(10, "Confirm bars", minval=1)

// =====================================================
// CONVERT HOURS → MINUTES
// =====================================================
tf1 = str.tostring(tf1_h * 60)
tf2 = str.tostring(tf2_h * 60)
tf3 = str.tostring(tf3_h * 60)
tf4 = str.tostring(tf4_h * 60)

// =====================================================
// FUNCTION: SRSI
// =====================================================
f_srsi(_src) =>
    rsiVal = ta.rsi(_src, lengthRSI)
    k = ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, lengthS), smoothK)
    d = ta.sma(k, smoothD)
    k + d

// =====================================================
// CALCULATE SRSI
// =====================================================
ds_open  = f_srsi(open)
ds_high  = f_srsi(high)
ds_low   = f_srsi(low)
ds_close = f_srsi(close)

// =====================================================
// CHANNEL (CURRENT TF)
// =====================================================
stArr = array.from(ds_open, ds_high, ds_low, ds_close)
stMin = array.min(stArr)
stMax = array.max(stArr)

// =====================================================
// MULTI TIMEFRAME
// =====================================================
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

// =====================================================
// NORMALIZE TO 0–100
// =====================================================
oranMin   = (a1 + a2 + a3 + a4) * 100 / 800
oranMax   = (b1 + b2 + b3 + b4) * 100 / 800
oranClose = (c1 + c2 + c3 + c4) * 100 / 800

// =====================================================
// ZONE NGANG (FIXED)
// =====================================================
h0   = hline(0)
h20  = hline(20)
h50  = hline(50)
h80  = hline(80)
h100 = hline(100)

fill(h0,  h20,  color=color.new(color.green, 88))   // quá bán
fill(h20, h50,  color=color.new(color.blue, 90))    // hồi / tích lũy
fill(h50, h80,  color=color.new(color.orange, 90))  // phân phối
fill(h80, h100, color=color.new(color.red, 88))     // quá mua

// =====================================================
// PLOTS
// =====================================================
pMin = plot(oranMin, title="Min", color=color.red)
pMax = plot(oranMax, title="Max", color=color.green)
plot(oranClose, title="Close", color=color.white)
fill(pMin, pMax, color=color.new(color.gray, 85))

// =====================================================
// MID SIGNAL LOGIC
// =====================================================
var bool watchFromLow  = false
var bool watchFromHigh = false

if oranClose <= watchLow and not watchFromLow and not watchFromHigh
    watchFromLow := true

if oranClose >= watchHigh and not watchFromHigh and not watchFromLow
    watchFromHigh := true

triggerFromLow  = watchFromLow and oranClose >= midLevel
triggerFromHigh = watchFromHigh and oranClose <= midLevel

if triggerFromLow or triggerFromHigh
    watchFromLow := false
    watchFromHigh := false

plot((triggerFromLow or triggerFromHigh) ? midLevel : na, style=plot.style_circles, linewidth=3, color=color.yellow)

// =====================================================
// EXTREME CONFIRMATION
// =====================================================
var float Dec = na
var float Inc = na
var bool trackingDec = false
var bool trackingInc = false
var int decCount = 0
var int incCount = 0

if triggerFromHigh
    Dec := oranClose
    trackingDec := true
    decCount := 0

if triggerFromLow
    Inc := oranClose
    trackingInc := true
    incCount := 0

confirmedMin = false
if trackingDec
    if oranClose < Dec
        Dec := oranClose
        decCount := 0
    else
        decCount += 1
    if decCount >= confirmBars
        trackingDec := false
        confirmedMin := true

confirmedMax = false
if trackingInc
    if oranClose > Inc
        Inc := oranClose
        incCount := 0
    else
        incCount += 1
    if incCount >= confirmBars
        trackingInc := false
        confirmedMax := true

plot(confirmedMin ? Dec : na, style=plot.style_circles, linewidth=3, color=color.lime)
plot(confirmedMax ? Inc : na, style=plot.style_circles, linewidth=3, color=color.red)

// =====================================================
// ALERT (GỘP CHUNG)
// =====================================================
alertcondition(confirmedMin or confirmedMax, title="SRSI Confirmed Extreme", message="SRSI xác nhận đảo chiều: {{ticker}} | TF {{interval}}")
````
