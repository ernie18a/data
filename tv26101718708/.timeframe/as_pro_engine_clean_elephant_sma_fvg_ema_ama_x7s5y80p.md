# AS PRO ENGINE CLEAN (Elephant + SMA + FVG + EMA + AMA)

- url: https://www.tradingview.com/script/X7s5y80P/
- type: indicator
- pine_id: PUB;9c26e857dd614ffe925dfa1120c91270
- version: 1.0

## Description

AS PRO ENGINE CLEAN (Elephant + SMA + FVG + EMA + AMA) — Description

This TradingView Pine Script (v6) is a multi-layered market analysis indicator combining volatility detection, trend structure, smart money concepts, adaptive trend filtering, and session-based liquidity mapping.

It is designed as an “all-in-one market intelligence engine” that visualizes key trading conditions and generates alert signals.

⚙️ 1. MASTER CONTROL PANEL

The script starts with a global switch system allowing the user to enable or disable core modules:

Elephant detection (volatility spikes)
FVG (Fair Value Gaps)
EMA multi-timeframe trend filter
AMA (Adaptive Moving Average)

This makes the indicator modular and customizable.

🐘 2. ELEPHANT BAR DETECTION (VOLATILITY SPIKES)

This module identifies high-impact candles using:

ATR-based volatility filter
Candle body strength vs full range

A bar is marked as an “Elephant” when:

Range > ATR × multiplier
Candle body is strong (dominant directional pressure)

Outputs:

Bullish Elephant (strong upward impulse)
Bearish Elephant (strong downward impulse)

These represent institutional-style momentum candles.

📈 3. SMA TREND STRUCTURE

The system uses three moving averages:

SMA 9 (short-term trend)
SMA 20 (mid trend)
SMA 200 (macro trend)
Features:
Plots all SMAs on chart
Colors candles based on SMA 9 trend:
Green → price above SMA 9 (bullish momentum)
Red → price below SMA 9 (bearish momentum)

This acts as the primary directional filter.

📦 4. FVG (FAIR VALUE GAP) DETECTION

The script detects inefficiencies in price:

Bullish FVG:
Low current candle > high of candle 2 bars ago
Bearish FVG:
High current candle < low of candle 2 bars ago

When detected:

A colored box is drawn on chart
Boxes extend forward in time

These represent liquidity imbalance zones commonly used in Smart Money Concepts.

⚡ 5. EMA MULTI-TIMEFRAME FILTER

A higher-timeframe EMA (default 5m EMA 20) is pulled into the chart.

Functions:
Shows institutional trend bias
Detects:
EMA crossover (bullish signal)
EMA crossunder (bearish signal)

This acts as a higher-level trend confirmation layer.

🧠 6. AMA (ADAPTIVE MOVING AVERAGE – KAUFMAN STYLE)

The AMA dynamically adjusts sensitivity based on market efficiency:

Key logic:
Efficiency Ratio (trend strength vs noise)
Fast/slow smoothing constants
Adaptive smoothing coefficient
Result:
In strong trends → AMA reacts faster
In choppy markets → AMA smooths out noise

This is a smart dynamic trend-following filter.

🎨 7. VISUAL MARKET STRUCTURE
Candles are colored based on:
SMA trend direction
Elephant bar detection

This visually separates:

Momentum phases
Accumulation / distribution zones
🌍 8. SESSION-BASED LIQUIDITY ZONES (WARSAW TIME)

The script defines and tracks multiple trading sessions:

Asia
Europe (London)
US
New York
Daily short session
Each session:
Calculates opening range (first X minutes)
Tracks high and low
Draws a box representing session liquidity zone

These zones represent:

Institutional activity periods
Volatility expansion areas
Key liquidity ranges
⏱️ 9. 15-MINUTE MARKET RANGE ENGINE

The script builds a dynamic market structure using 15-minute data:

Rolling high/low range over last N candles
Real-time updating support and resistance lines
Non-repainting logic (confirmed data only)

This creates:

Dynamic liquidity boundaries
Institutional range structure
🚨 10. ALERT SYSTEM

The system generates three main alert types:

Main Signal:

Triggered when:

Elephant bar appears OR
FVG is detected
EMA Signal:
EMA crossover / crossunder events
Combined Alert:
Any major structural or trend event

This creates a multi-factor signal engine combining:

Momentum
Inefficiency
Trend structure
🧩 OVERALL SYSTEM LOGIC

This indicator behaves like a hybrid trading engine combining:

Volatility breakout detection (Elephant bars)
Market inefficiency zones (FVG)
Multi-timeframe trend confirmation (EMA)
Adaptive trend filtering (AMA)
Structural trend context (SMA system)
Session liquidity mapping
Dynamic range modeling (15m structure)

## Source Code

````pine
//@version=6
indicator("AS PRO ENGINE CLEAN (Elephant + SMA + FVG + EMA + AMA)", overlay=true, max_boxes_count=200)

//────────────────────
// ⚙️ MASTER
//────────────────────
group_master = "⚙️ MASTER"
enableElephant = input.bool(true, "Enable Elephant", group=group_master)
enableFVG      = input.bool(true, "Enable FVG", group=group_master)
enableEMA      = input.bool(true, "Enable EMA MTF", group=group_master)
enableAMA      = input.bool(true, "Enable AMA", group=group_master)

//────────────────────
// 🐘 ELEPHANT
//────────────────────
group_ele = "🐘 Elephant"
atrLen      = input.int(10, "ATR Length", group=group_ele)
mult        = input.float(1.5, "ATR Multiplier", step=0.1, group=group_ele)
bodyPercent = input.float(0.5, "Body Strength", step=0.05, group=group_ele)

atr = ta.atr(atrLen)
barRange = high - low
body = math.abs(close - open)

bodyRatio = barRange > 0 ? body / barRange : 0
isBigRange = barRange > atr * mult
isStrongBody = bodyRatio > bodyPercent

elephantBar = enableElephant and isBigRange and isStrongBody
bullElephant = elephantBar and close > open
bearElephant = elephantBar and close < open

//────────────────────
// 📈 SMA
//────────────────────
group_sma = "📈 SMA"
sma9Len   = input.int(9, "SMA 9", group=group_sma)
sma20Len  = input.int(20, "SMA 20", group=group_sma)
sma200Len = input.int(200, "SMA 200", group=group_sma)

sma9 = ta.sma(close, sma9Len)
sma20 = ta.sma(close, sma20Len)
sma200 = ta.sma(close, sma200Len)

plot(sma9, color=color.rgb(120, 123, 134, 46), style = plot.style_stepline, title="SMA 9")
plot(sma20, color=color.rgb(255, 153, 0, 76), style = plot.style_stepline, title="SMA 20")
plot(sma200, color=color.rgb(82, 183, 255, 78), style = plot.style_stepline, title="SMA 200")


// TREND BASED CANDLES (SMA 9)
trendUp = close > sma9
trendDown = close < sma9

barcolor(trendUp ? color.new(#6fff00, 0) : trendDown ? color.new(#fe0000, 0) : na)


//────────────────────
// 📦 FVG
//────────────────────
group_fvg = "📦 FVG"
fvgExtend = input.int(3, "Extend", group=group_fvg)

bullFVG = low > high[2]
bearFVG = high < low[2]

if enableFVG and bullFVG
    box.new(bar_index-2, low, bar_index+fvgExtend, high[2],
        bgcolor=color.new(color.green, 80), border_width=0)

if enableFVG and bearFVG
    box.new(bar_index-2, low[2], bar_index+fvgExtend, high,
        bgcolor=color.new(color.red, 80), border_width=0)

//────────────────────
// ⚡ EMA MTF
//────────────────────
group_ema = "⚡ EMA"
emaLen = input.int(20, "EMA Length", group=group_ema)
tf = input.timeframe("5", "HTF", group=group_ema)

emaMTF = enableEMA ? request.security(syminfo.tickerid, tf, ta.ema(close, emaLen)) : na

plot(emaMTF, color=color.rgb(255, 235, 59, 74), title="EMA MTF")

emaUp = ta.crossover(close, emaMTF)
emaDown = ta.crossunder(close, emaMTF)

//────────────────────
// 🧠 AMA 
//────────────────────
group_ama = "🧠 AMA"

len  = input.int(10, "Length", group=group_ama)
fast = input.int(2, "Fast", group=group_ama)
slow = input.int(30, "Slow", group=group_ama)

src = close

//────────────────────
// Efficiency Ratio (Kaufman)
//────────────────────
change = math.abs(src - src[len])

// manual volatility sum (fix for ta.sum error)
float volatility = 0.0
for i = 0 to len - 1
    volatility += math.abs(src[i] - src[i + 1])

er = volatility != 0 ? change / volatility : 0.0

// smoothing constants
fastSC = 2.0 / (fast + 1)
slowSC = 2.0 / (slow + 1)

// adaptive smoothing
sc = math.pow(er * (fastSC - slowSC) + slowSC, 2)

// AMA state
var float ama = na
ama := na(ama[1]) ? src : ama[1] + sc * (src - ama[1])

plot(enableAMA ? ama : na, color=color.rgb(76, 0, 131, 52), title="AMA", style = plot.style_circles, linewidth=1)
//────────────────────
// 🎨 COLORS
//────────────────────
barcolor(bullElephant ? color.rgb(255, 255, 255, 37) : bearElephant ? color.rgb(179, 0, 255, 38) : na)

//────────────────────────────────────
// Opening Range
//────────────────────────────────────
orMinutes = input.int(5, "Opening Range Minutes")

showA = input.bool(true, "Azja")
showEU = input.bool(true, "Europe (London)")
showUS = input.bool(true, "US")
showNY = input.bool(true, "New York")
showDS = input.bool(true, "DS (Poland)")

//────────────────────────────────────
// TIMEZONE (ONLY POLAND)
//────────────────────────────────────
tz = "Europe/Warsaw"

//────────────────────────────────────
// SESSIONS (POLISH TIME)
//────────────────────────────────────
aSess  = "0000-0800"   // Azja
euSess = "0850-1700"   // Europa
usSess = "1350-2200"   // US
nySess = "1520-2250"   // NY
dSess  = "2250-2300"   // DS (Poland)

//────────────────────────────────────
// SESSION DETECTION (ALL IN PL TIME)
//────────────────────────────────────
inA  = not na(time(timeframe.period, aSess, tz))
inEU = not na(time(timeframe.period, euSess, tz))
inUS = not na(time(timeframe.period, usSess, tz))
inNY = not na(time(timeframe.period, nySess, tz))
inDS = not na(time(timeframe.period, dSess, tz))

newA  = inA  and not inA[1]
newEU = inEU and not inEU[1]
newUS = inUS and not inUS[1]
newNY = inNY and not inNY[1]
newDS = inDS and not inDS[1]

//────────────────────────────────────
// AZJA
//────────────────────────────────────
var float aHigh = na
var float aLow  = na
var int aCount  = 0
var int aStart  = na
var box aBox    = na

if newA
    aHigh := na
    aLow  := na
    aCount := 0
    aStart := bar_index
    aBox := na

if showA and inA
    if aCount < orMinutes
        aHigh := na(aHigh) ? high : math.max(aHigh, high)
        aLow  := na(aLow)  ? low  : math.min(aLow, low)
        aCount += 1

    if aCount == orMinutes and na(aBox)
        aBox := box.new(aStart, aHigh, bar_index, aLow,
            bgcolor=color.new(#5b005e, 79), border_color=na)

    if not na(aBox)
        box.set_right(aBox, bar_index)
        box.set_top(aBox, aHigh)
        box.set_bottom(aBox, aLow)

//────────────────────────────────────
// EUROPE
//────────────────────────────────────
var float euHigh = na
var float euLow  = na
var int euCount  = 0
var int euStart  = na
var box euBox    = na

if newEU
    euHigh := na
    euLow  := na
    euCount := 0
    euStart := bar_index
    euBox := na

if showEU and inEU
    if euCount < orMinutes
        euHigh := na(euHigh) ? high : math.max(euHigh, high)
        euLow  := na(euLow)  ? low  : math.min(euLow, low)
        euCount += 1

    if euCount == orMinutes and na(euBox)
        euBox := box.new(euStart, euHigh, bar_index, euLow,
            bgcolor=color.new(#535353, 78), border_color=na)

    if not na(euBox)
        box.set_right(euBox, bar_index)
        box.set_top(euBox, euHigh)
        box.set_bottom(euBox, euLow)

//────────────────────────────────────
// US
//────────────────────────────────────
var float usHigh = na
var float usLow  = na
var int usCount  = 0
var int usStart  = na
var box usBox    = na

if newUS
    usHigh := na
    usLow  := na
    usCount := 0
    usStart := bar_index
    usBox := na

if showUS and inUS
    if usCount < orMinutes
        usHigh := na(usHigh) ? high : math.max(usHigh, high)
        usLow  := na(usLow)  ? low  : math.min(usLow, low)
        usCount += 1

    if usCount == orMinutes and na(usBox)
        usBox := box.new(usStart, usHigh, bar_index, usLow,
            bgcolor=color.new(#1100ff, 65), border_color=na)

    if not na(usBox)
        box.set_right(usBox, bar_index)
        box.set_top(usBox, usHigh)
        box.set_bottom(usBox, usLow)

//────────────────────────────────────
// NEW YORK
//────────────────────────────────────
var float nyHigh = na
var float nyLow  = na
var int nyCount  = 0
var int nyStart  = na
var box nyBox    = na

if newNY
    nyHigh := na
    nyLow  := na
    nyCount := 0
    nyStart := bar_index
    nyBox := na

if showNY and inNY
    if nyCount < orMinutes
        nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
        nyLow  := na(nyLow)  ? low  : math.min(nyLow, low)
        nyCount += 1

    if nyCount == orMinutes and na(nyBox)
        nyBox := box.new(nyStart, nyHigh, bar_index, nyLow,
            bgcolor=color.new(#6d0000, 70), border_color=na)

    if not na(nyBox)
        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)

//────────────────────────────────────
// DAILY SESSION (POLAND)
//────────────────────────────────────
var float dHigh = na
var float dLow  = na
var int dCount  = 0
var int dStart  = na
var box dBox    = na

if newDS
    dHigh := na
    dLow  := na
    dCount := 0
    dStart := bar_index
    dBox := na

if showDS and inDS
    if dCount < orMinutes
        dHigh := na(dHigh) ? high : math.max(dHigh, high)
        dLow  := na(dLow)  ? low  : math.min(dLow, low)
        dCount += 1

    if dCount == orMinutes and na(dBox)
        dBox := box.new(dStart, dHigh, bar_index, dLow,
            bgcolor=color.new(#fff700, 45), border_color=na)

    if not na(dBox)
        box.set_right(dBox, bar_index)
        box.set_top(dBox, dHigh)
        box.set_bottom(dBox, dLow)

//────────────────────────────────────
// 15m DATA STREAM
//────────────────────────────────────
h15 = request.security(syminfo.tickerid, "15", high)
l15 = request.security(syminfo.tickerid, "15", low)

//────────────────────────────────────
// WINDOW RANGE (last 15m swings, LIVE)
//────────────────────────────────────
length = input.int(20, "15m Bars Lookback")

// zamiast HTF snapshot → budujemy rolling range
rangeHigh = ta.highest(h15, length)
rangeLow  = ta.lowest(l15, length)

//────────────────────────────────────
// LINES
//────────────────────────────────────
var line hiLine = na
var line loLine = na

// create once
if na(hiLine)
    hiLine := line.new(bar_index, rangeHigh, bar_index + 1, rangeHigh, extend=extend.right, color=color.rgb(126, 0, 0), width=2)

if na(loLine)
    loLine := line.new(bar_index, rangeLow, bar_index + 1, rangeLow, extend=extend.right, color=color.rgb(0, 107, 21), width=2)

// update continuously (THIS is key)
line.set_y1(hiLine, rangeHigh)
line.set_y2(hiLine, rangeHigh)

line.set_y1(loLine, rangeLow)
line.set_y2(loLine, rangeLow)

//────────────────────────────────────
// REAL 15m DATA STREAM (NO REPAINT)
//────────────────────────────────────
h15q = request.security(syminfo.tickerid, "15", high, lookahead=barmerge.lookahead_off)
l15q = request.security(syminfo.tickerid, "15", low,  lookahead=barmerge.lookahead_off)

//────────────────────────────────────
// RANGE
//────────────────────────────────────
lengthq = input.int(200, "15m Bars Lookback")

rangeHighq = ta.highest(h15, lengthq)
rangeLowq  = ta.lowest(l15, lengthq)

//────────────────────────────────────
// LINES
//────────────────────────────────────
var line hiLineq = na
var line loLineq = na

if na(hiLineq)
    hiLineq := line.new(bar_index, rangeHighq, bar_index, rangeHighq, extend=extend.right, color=color.rgb(157, 0, 0), width=5)

if na(loLineq)
    loLineq := line.new(bar_index, rangeLowq, bar_index, rangeLowq, extend=extend.right, color=color.rgb(0, 134, 4), width=5)

//────────────────────────────────────
// UPDATE (X + Y !!!)
//────────────────────────────────────
line.set_xy1(hiLineq, bar_index - 1, rangeHighq)
line.set_xy2(hiLineq, bar_index,     rangeHighq)

line.set_xy1(loLineq, bar_index - 1, rangeLowq)
line.set_xy2(loLineq, bar_index,     rangeLowq)

//────────────────────
// 🚨 ALERTS
//────────────────────
signal_main = elephantBar or bullFVG or bearFVG
signal_ema  = emaUp or emaDown

alertcondition(signal_main, title="SMC Signal", message="Elephant or FVG")
alertcondition(signal_ema, title="EMA Signal", message="EMA Cross")
alertcondition(signal_ema or signal_main, title="ALL", message="Take a Look!")
````
