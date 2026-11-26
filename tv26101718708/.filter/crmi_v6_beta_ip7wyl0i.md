# CRMI v6 BETA

- url: https://www.tradingview.com/script/ip7Wyl0i-CRMI-v6-BETA/
- type: strategy
- pine_id: PUB;8ada42ed8729489fab22efe9e24c0d03
- version: 2.0

## Description

CRMI v6 BETA (Refined Version) with all the upgrades applied:

✅ Impulse strength filter
✅ Reduced trade frequency
✅ Hybrid tightened
✅ Anti-chop applied to FAST + HYBRID
✅ Distance-from-equilibrium filter
✅ Cleaner execution behavior

A. Higher Timeframe Bias Engine (CRITICAL for LONG)
Use HTF (1H / 4H) to define:
Trend direction
Strength
Structure (HH/HL or LH/LL)

Outputs:

htf_bias = BULL / BEAR / NEUTRAL
htf_strength = 0 → 1

👉 LONG mode MUST depend heavily on this.

B. Liquidity + Sweep Detection (Keep from v6 Alpha)
Identify:
Equal highs/lows
Previous session highs/lows
Stop clusters

Outputs:

liquidity_swept = true/false
sweep_direction = up/down
C. Momentum / Displacement Engine
Detect real moves vs noise
Use:
Candle expansion
Volume spike
ATR expansion

Outputs:

impulse_detected = true/false
impulse_strength = 0 → 1
D. Anti-Chop Filter (NEW — VERY IMPORTANT)

This fixes FAST + HYBRID issues.

Detect:

Low ATR
EMA compression
No structure breaks

Outputs:

market_state = TRENDING / CHOPPY

👉 If CHOPPY → restrict entries heavily

⚙️ 2. MODE EXECUTION LAYER (REWRITE THIS)

Now modes become behavior profiles, not separate logic.

⚡ FAST MODE = “Trade the Move”
Needs:
impulse_detected = true
liquidity sweep optional
Ignores HTF bias partially

Behavior:

Quick entries
Tight SL
Fast TP
Short hold

Fix from your observation:
👉 Add minimum hold bars (3–8 candles) to stop micro-scalping spam

🧠 LONG MODE = “Trade the Thesis” (MOST IMPORTANT)

Only enter if:

HTF bias aligned
Liquidity sweep confirms direction
Market NOT choppy

Behavior:

Wider SL
Hold longer
Trail based on structure, NOT price ticks

NEW:
👉 Add Thesis Lock

Once in trade → ignore small pullbacks
Exit ONLY if:
HTF bias flips
Structure breaks
🔁 HYBRID MODE = “Sniper + Runner”

Fix inconsistency by splitting position:

Entry = same as FAST (good timing)
Then:
50% = FAST TP
50% = LONG hold

👉 This alone will stabilize HYBRID massively

🧩 3. SMART RE-ENTRY MEMORY (NEW EDGE)

This is what most retail systems DON’T have.

Track:

last_trade_direction
last_trade_result (win/loss)
last_entry_zone

Logic:

If stopped out BUT bias still valid → allow re-entry
If 2 losses in chop → pause trading
🛡️ 4. TRADE FILTER STACK (FINAL LAYER)

Only allow trades if:

NOT CHOPPY
AND (impulse_detected OR liquidity_swept)
AND HTF alignment (for LONG / HYBRID runner)
🎯 5. EXPECTED RESULTS AFTER BETA



FAST → fewer but cleaner trades
LONG → higher win rate + bigger RR
HYBRID → becomes your best mode overall

## Source Code

````pine
//@version=6
strategy("CRMI v6 BETA REFINED", overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=10,
     pyramiding=0,
     process_orders_on_close=true)

// ================= INPUTS =================

// Mode
executionMode = input.string("HYBRID", "Mode", options=["FAST","LONG","HYBRID"])

// HTF
htf_tf = input.timeframe("60", "HTF Bias TF")

// Trend
emaFastLen = input.int(20)
emaMidLen  = input.int(50)
emaSlowLen = input.int(200)

// Risk
atrLen = input.int(14)
fastATR = input.float(0.8)
longATR = input.float(1.5)
rrTarget = input.float(1.5)
minRR = input.float(1.2)

// FAST control
fastMinHoldBars = input.int(5)

// ================= CORE =================

// EMAs
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

// Trend
bullTrend = emaFast > emaMid and emaMid > emaSlow
bearTrend = emaFast < emaMid and emaMid < emaSlow

trendState = bullTrend ? 1 : bearTrend ? -1 : 0

// ATR
atr = ta.atr(atrLen)

// ================= HTF BIAS =================
htf_close = request.security(syminfo.tickerid, htf_tf, close)
htf_ema   = request.security(syminfo.tickerid, htf_tf, ta.ema(close, 50))

htf_bias = htf_close > htf_ema ? 1 : htf_close < htf_ema ? -1 : 0

// ================= ANTI-CHOP =================
eff = math.abs(close - close[20]) / math.sum(math.abs(close - close[1]), 20)
isChoppy = eff < 0.25

// ================= VALUE =================
eq = ta.ema(close, 34)
upper = eq + atr
lower = eq - atr

inDiscount = close < eq
inPremium  = close > eq

// ================= IMPULSE FILTER =================
impulse = math.abs(close - open)
avgImpulse = ta.sma(math.abs(close - open), 10)
strongImpulse = impulse > avgImpulse * 1.2

// ================= TRIGGERS =================
bullBreak = close > high[1] and strongImpulse
bearBreak = close < low[1] and strongImpulse

// ================= SCORES =================
buyScore =
     (trendState == 1 ? 30 : 0) +
     (inDiscount ? 20 : 0) +
     (bullBreak ? 20 : 0) +
     (htf_bias == 1 ? 30 : 0)

sellScore =
     (trendState == -1 ? 30 : 0) +
     (inPremium ? 20 : 0) +
     (bearBreak ? 20 : 0) +
     (htf_bias == -1 ? 30 : 0)

// ================= MODE =================
isFast = executionMode == "FAST"
isLong = executionMode == "LONG"
isHybrid = executionMode == "HYBRID"

// Tightened thresholds
minScore = isFast ? 65 : isLong ? 75 : 70
atrMult = isLong ? longATR : fastATR

// ================= RISK =================
longStop = close - atr * atrMult
shortStop = close + atr * atrMult

longTarget = close + (close - longStop) * rrTarget
shortTarget = close - (shortStop - close) * rrTarget

longRR = (longTarget - close) / (close - longStop)
shortRR = (close - shortTarget) / (shortStop - close)

// ================= SMART FILTER =================
distanceFromEQ = math.abs(close - eq) / atr
validDisplacement = distanceFromEQ > 0.5

// ================= MEMORY =================
var int lastDir = 0
var int entryBar = na
var int lastLossDir = 0

justClosed = strategy.position_size == 0 and strategy.position_size[1] != 0

if justClosed
    profit = strategy.closedtrades.profit(strategy.closedtrades - 1)
    lastLossDir := profit < 0 ? lastDir : 0

// ================= ENTRY =================

longCond =
     buyScore >= minScore and
     longRR >= minRR and
     validDisplacement and
     (not isLong or htf_bias == 1) and
     not ((isFast or isHybrid) and isChoppy)

shortCond =
     sellScore >= minScore and
     shortRR >= minRR and
     validDisplacement and
     (not isLong or htf_bias == -1) and
     not ((isFast or isHybrid) and isChoppy)

// Re-entry logic
longCond := longCond or (lastLossDir == 1 and htf_bias == 1)
shortCond := shortCond or (lastLossDir == -1 and htf_bias == -1)

// ================= EXECUTION =================

if longCond and strategy.position_size == 0
    strategy.entry("Long", strategy.long)
    lastDir := 1
    entryBar := bar_index

if shortCond and strategy.position_size == 0
    strategy.entry("Short", strategy.short)
    lastDir := -1
    entryBar := bar_index

// ================= HOLD LOGIC =================

barsHeld = bar_index - entryBar
canExitFast = barsHeld >= fastMinHoldBars

longValid = trendState >= 0
shortValid = trendState <= 0

// ================= EXIT =================

if strategy.position_size > 0
    if isLong and longValid
        na
    else if not isFast or canExitFast
        strategy.exit("L Exit", stop=longStop, limit=longTarget)

if strategy.position_size < 0
    if isLong and shortValid
        na
    else if not isFast or canExitFast
        strategy.exit("S Exit", stop=shortStop, limit=shortTarget)

// ================= VISUALS =================

plot(emaFast, color=color.green)
plot(emaMid, color=color.blue)
plot(emaSlow, color=color.orange)

plot(eq, color=color.white)
plot(upper, color=color.red)
plot(lower, color=color.lime)

plotshape(longCond, location=location.belowbar, color=color.lime, style=shape.triangleup, size=size.small)
plotshape(shortCond, location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)
````
