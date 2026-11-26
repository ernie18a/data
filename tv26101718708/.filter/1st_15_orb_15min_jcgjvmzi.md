# 1st 15 ORB 1/5min

- url: https://www.tradingview.com/script/JcgjVmZi-1st-15-ORB-1-5min/
- type: indicator
- pine_id: PUB;a0c588206ef74ca187cad1cdbfe9cfef
- version: 1.0

## Description

This is a:

Multi-phase Opening Range Breakout (ORB) + Trend Continuation + Compression Detection system

It breaks market behavior into 3 structured regimes:

1. Compression Phase (yellow background)
This is when:
*volatility is shrinking (ATR contraction)
*price is moving sideways
*no clear breakout yet

Meaning:
The market is “loading energy” — not moving decisively

What it is NOT:
*not a buy signal
*not a sell signal
*not directional yet

 2. Breakout / Expansion Phase (ORB break)
Triggered when price breaks:
*above ORB high → bullish bias
*below ORB low → bearish bias

This is where:
*DROP / POP signals can appear (impulse moves)
*volatility expands
*direction begins to form

Meaning:
“The market chose a direction”


3. Trend Phase (background color)
After breakout:
🟩 Green = bullish trend active
🟥 Red = bearish trend active


Price is now:
*trending
*creating structure
*producing continuation setups

What each signal actually means
🔻 DROP
*aggressive sell expansion from inside ORB
*early bearish displacement

🔺 POP
*aggressive buy expansion from inside ORB
*early bullish displacement


REV (reversal)
*failed breakout at ORB boundary
*liquidity trap / rejection


CONT (continuation)
*pullback within trend
*re-entry into direction of breakout

How to use this “to the max”
This system is NOT for random entries. It is a phase-based execution model.

⚙️ Step-by-step usage model
🟨 STEP 1 — Wait for Compression
Do nothing
Identify when yellow background is active

Goal:
Let the market “build pressure”


🟦 STEP 2 — Wait for ORB break
*First break of ORB high/low defines bias
*This is your directional decision point

Rule:
You only start trading AFTER breakout


STEP 3 — Trade continuation only
Once trend is established:
Long setup:
*pullback toward structure
*continuation signal in trend direction

Short setup:
*pullback upward
*continuation down

👉 This is where consistency comes from

STEP 4 — Use DROP / POP sparingly
These are NOT primary entries.
They are:
*early expansion clues
*momentum alerts
*sometimes “first leg” entries (higher risk)



STEP 5 — REV signals = warning zones
Use REV for:
*failed breakout detection
*exit timing
*not primary entries



💡 Key concept (most important part)
This indicator is built around:
*Compression → Expansion → Trend → Continuation

Not:
*guessing tops/bottoms
*reacting to every candle
*overtrading signals

🧭 How professionals would actually use it
1. Morning (pre-breakout)
watch compression

2. First move
identify ORB breakout direction


3. Mid-session
only take continuation trades

4. Late session
stop trading unless clean structure remains

📉 What NOT to do
*don’t trade every DROP/POP
*don’t trade inside compression
*don’t counter-trade trend signals
*don’t ignore ORB bias

What makes this powerful
Most indicators try to predict moves.
This one instead:

organizes market behavior into phases so you only trade when probability is structurally in your favor.

## Source Code

````pine
//@version=5
indicator("1st 15 ORB 1/5min", overlay=true)

// ==========================
// 🔧 INPUTS
// ==========================
sessionInput = input.session("0930-0945", "Opening Range (15m)")
useVWAP      = input.bool(true, "Use VWAP Bias Filter")

maxSignalsPerSide = input.int(2, "Max Signals Per Side", minval=1)
cooldownBars      = input.int(5, "Cooldown Bars", minval=1)

showDrop     = input.bool(true, "Show DROP / POP")
showReversal = input.bool(true, "Show Reversals")
showCont     = input.bool(true, "Show Continuation")

// ==========================
// 🧱 ORB BUILD
// ==========================
inSession = not na(time(timeframe.period, sessionInput))
newDay = ta.change(time("D"))

var float orbHigh = na
var float orbLow  = na
var bool orbComplete = false

if newDay
    orbHigh := na
    orbLow := na
    orbComplete := false

if inSession
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow, low)

if not inSession and not orbComplete and not na(orbHigh)
    orbComplete := true

plot(orbHigh, "ORB High", color=color.blue, linewidth=2)
plot(orbLow,  "ORB Low",  color=color.blue, linewidth=2)

// ==========================
// 📊 VWAP FILTER
// ==========================
vwap = ta.vwap(close)
bullBias = not useVWAP or close > vwap
bearBias = not useVWAP or close < vwap

// ==========================
// 🚫 ORB ZONE FILTER
// ==========================
insideORB = orbComplete and close <= orbHigh and close >= orbLow
outsideORB = orbComplete and not insideORB

// ==========================
// 🚦 SIGNAL LIMITER
// ==========================
var int bullCount = 0
var int bearCount = 0
var int lastSignalBar = na

if newDay
    bullCount := 0
    bearCount := 0
    lastSignalBar := na

canFireBull = (na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars) and bullCount < maxSignalsPerSide
canFireBear = (na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars) and bearCount < maxSignalsPerSide

atr = ta.atr(14)

// ==========================
// 🔻 DROP / POP
// ==========================
dropSignal = orbComplete and insideORB and low < orbLow and (high - low) > atr
popSignal  = orbComplete and insideORB and high > orbHigh and (high - low) > atr

dropFinal = showDrop and dropSignal and bearBias and canFireBear
popFinal  = showDrop and popSignal and bullBias and canFireBull

if dropFinal
    bearCount += 1
    lastSignalBar := bar_index
    bullCount := 0

if popFinal
    bullCount += 1
    lastSignalBar := bar_index
    bearCount := 0

// ==========================
// 🚀 BREAKOUT CONFIRMATION
// ==========================
bullBreak = orbComplete and close > orbHigh and bullBias
bearBreak = orbComplete and close < orbLow and bearBias

bullConfirm = bullBreak[1] and low > low[1]
bearConfirm = bearBreak[1] and high < high[1]

bullSignal = bullConfirm and outsideORB and canFireBull
bearSignal = bearConfirm and outsideORB and canFireBear

if bullSignal
    bullCount += 1
    lastSignalBar := bar_index
    bearCount := 0

if bearSignal
    bearCount += 1
    lastSignalBar := bar_index
    bullCount := 0

// ==========================
// 🔁 REVERSALS
// ==========================
bearReversal = showReversal and high > orbHigh and close < orbHigh
bullReversal = showReversal and low < orbLow and close > orbLow

bearRevFinal = bearReversal and outsideORB and canFireBear
bullRevFinal = bullReversal and outsideORB and canFireBull

if bearRevFinal
    bearCount += 1
    lastSignalBar := bar_index
    bullCount := 0

if bullRevFinal
    bullCount += 1
    lastSignalBar := bar_index
    bearCount := 0

// ==========================
// 🔄 CONTINUATION
// ==========================
trendDown = ta.barssince(low < orbLow) < 30
trendUp   = ta.barssince(high > orbHigh) < 30

pullbackDown = trendDown and close > close[1]
pullbackUp   = trendUp and close < close[1]

continueDown = showCont and trendDown and pullbackDown and close < low[1] and outsideORB
continueUp   = showCont and trendUp and pullbackUp and close > high[1] and outsideORB

// ==========================
// 🧠 COMPRESSION ADDON (NEW ONLY)
// ==========================

// volatility contraction
atrNow = ta.atr(14)
atrAvg = ta.sma(ta.atr(14), 20)
volCompression = atrNow < atrAvg

// range tightening
hh = ta.highest(high, 20)
ll = ta.lowest(low, 20)
rangeSize = hh - ll
avgRange = ta.sma(high - low, 20)
rangeCompression = rangeSize < avgRange

// no breakout structure
noBreak = close < hh and close > ll

compression = volCompression and rangeCompression and noBreak

// ==========================
// 📍 PLOTS
// ==========================

// 🟢 BULLISH
plotshape(popFinal, title="POP", style=shape.triangleup, location=location.belowbar, color=color.lime, text="POP")
plotshape(bullSignal, title="BUY", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY")
plotshape(bullRevFinal, title="REV LONG", style=shape.labelup, location=location.belowbar, color=color.lime, text="REV")
plotshape(continueUp, title="CONT UP", style=shape.labelup, location=location.belowbar, color=color.teal, text="CONT")

// 🔴 BEARISH
plotshape(dropFinal, title="DROP", style=shape.triangledown, location=location.abovebar, color=color.red, text="DROP")
plotshape(bearSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL")
plotshape(bearRevFinal, title="REV SHORT", style=shape.triangledown, location=location.abovebar, color=color.orange, text="REV")
plotshape(continueDown, title="CONT DOWN", style=shape.triangledown, location=location.abovebar, color=color.maroon, text="CONT")

// 🧠 COMPRESSION VISUAL (NEW ONLY)
bgcolor(compression ? color.new(color.yellow, 88) : na)

// ==========================

 // ==========================
 // 🎨 TREND BACKGROUND COLOR
 // ==========================

// trend state based on ORB breakout direction
var int trend = 0

bullTrend = orbComplete and close > orbHigh
bearTrend = orbComplete and close < orbLow

if bullTrend
    trend := 1

if bearTrend
    trend := -1

// background colors
bgcolor(trend == 1 ? color.new(color.green, 88) : na)
bgcolor(trend == -1 ? color.new(color.red, 88) : na)
bgcolor(trend == 0 ? color.new(color.gray, 92) : na)
// 🔔 ALERTS (UNCHANGED + ADDITION)
// ==========================
alertcondition(popFinal, "POP", "Impulse Up Inside ORB")
alertcondition(dropFinal, "DROP", "Impulse Down Inside ORB")
alertcondition(bullSignal, "BUY", "BUY Signal")
alertcondition(bearSignal, "SELL", "SELL Signal")
alertcondition(continueDown, "CONT DOWN", "Continuation Down")
alertcondition(continueUp, "CONT UP", "Continuation Up")

alertcondition(compression, "COMPRESSION", "Market Compression Detected")
````
