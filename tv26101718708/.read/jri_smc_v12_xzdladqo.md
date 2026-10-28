# JRI SMC v12

- url: https://www.tradingview.com/script/XZdlADQo-JRI-SMC-v12/
- type: indicator
- pine_id: PUB;d93e328d46a84963b60ca655ad1e6769
- version: 2.0

## Description

THE JRI SMART MONEY STRATEGY
Philosophy
You trade with institutions, not against them. Every decision flows from the higher timeframe down to the lower timeframe. You never enter on a lower timeframe without confirmation from above.

STEP 1 — WEEKLY (Big Picture)
Start here every week before you trade anything.
Find the ATH and ATL on the chart. These are your absolute boundaries — price respects these levels hard. Note whether the weekly candle is bullish or bearish. Is price making Higher Highs and Higher Lows (bullish) or Lower Highs and Lower Lows (bearish)? This tells you the macro bias. Only trade in the direction of the weekly trend unless you have an extremely strong counter-trend setup.

STEP 2 — DAILY (Directional Bias)
This is where you determine your bias for the week.
Look for the most recent swing High and swing Low. Mark them. Is price respecting a previous HH or HL? Is it breaking below a HL (bearish shift) or above a LH (bullish shift)? Measure the wick of the previous day’s candle — the wick shows where institutions rejected price. That rejection zone becomes your supply or demand area. The daily bias tells you whether you’re only looking for BUYs or only looking for SELLs on the lower timeframes that day.

STEP 3 — 4 HOUR (Key Levels and Zones)
This is your map for the trading session.
Draw your key psychological levels — on Gold these are every 100 points: 4700, 4800, 4900, 5000. Price always gravitates toward and reacts at these round numbers because that’s where institutions place large orders. Mark your supply zones (areas where price sold off hard from) and demand zones (areas where price bounced hard from). These become your trade locations — you only look to enter when price reaches one of these zones, not in the middle of a range.

STEP 4 — 2 HOUR (Institutional Activity)
This is where you identify what the big players are doing.
Look for institution candles — large body candles that are 2x the average size. These are institutions entering positions. After a large institution candle, price often comes back to mitigate (retest) that candle before continuing. That mitigation point is a high-probability entry. Also look for liquidity sweeps — when price wicks above a recent high or below a recent low and immediately closes back. This is institutions hunting stops before the real move. After a liquidity sweep, the move goes the other direction.

STEP 5 — 1 HOUR (Entry Zone)
Now you’re narrowing down exactly where to enter.
Look for retracements back into the 4H supply or demand zone. If the daily bias is bullish and price pulls back to a 4H demand zone on the 1H, that’s your entry zone. Look for the 1H to show a Break of Structure in your direction — a BOS confirms institutions have shifted. If the trend is already running strong, you can enter on a retest of the broken structure level rather than waiting for a deep pullback.

STEP 6 — 30 MINUTE (Counter Trend Lines and Confirmation)
This refines your entry timing.
Draw a counter trend line against the current move. When price breaks that counter trend line in the direction of your bias, that’s your trigger to prepare for entry. This is also where you confirm SMC concepts — look for a mitigation block, an order block, or a fair value gap that price is filling before continuing your direction.

STEP 7 — 15 MINUTE (Final Entry Confirmation)
Your signal timeframe.
This is where the JRI indicator fires. All 7 conditions need to align — bias, zone, BOS, retest, VWAP, EMA stack, RSI. When the score hits 5, 6, or 7 out of 7 the signal fires. On your funded account only take 6/7 or 7/7. On personal accounts 5/7 is acceptable. The 15m gives you enough detail to see the setup clearly without being too noisy.

STEP 8 — 5 MINUTE and 1 MINUTE (Precision Entry and Scalping)
This is where you time the exact entry.
On the 5m and 1m you’re looking for the same things — liquidity sweeps, institution candles, BOS — but at a micro level. For scalps you enter at the candle HIGH on a BUY or candle LOW on a SELL. Your stop goes below the candle LOW on BUY or above the candle HIGH on SELL with 0.8x ATR buffer. You measure the move in 1:3 risk-reward.

RISK MANAGEMENT RULES — NON NEGOTIABLE
These apply to every single trade no exceptions.
At T1 (1:1 R) — take 50% of your position off. Lock in profit. This is not optional.
At T2 (1:2 R) — move your stop loss to your entry price. You are now in a risk-free trade.
At T3 (1:3 R) — close the remaining position. Full target hit.
Never move your stop loss against you. Never add to a losing position. If you’re in a funded account and the trade hits your SL, that’s the end of that trade. No revenge trading.

THE 7 CONDITIONS YOUR INDICATOR CHECKS
	1.	Bias — Is the market structure bullish (HH+HL) or bearish (LH+LL)?
	2.	In Zone — Is price inside a confirmed supply or demand zone?
	3.	BOS — Did price break a recent structure level in your direction?
	4.	Retest — Did price come back and test that broken level?
	5.	vs VWAP — Is price above VWAP for buys, below for sells?
	6.	EMA Stack — Is EMA 20 above EMA 50 for buys, below for sells?
	7.	RSI — Is RSI above 50 for buys, below 50 for sells?
All 7 pointing the same direction means institutions are aligned with your trade. That’s when you pull the trigger.

YOUR SESSION SCHEDULE
Your primary window is the NY Open — 6:30am PST. This is when the highest volume hits and the cleanest moves happen. Gold (MGC/GC) and NQ are your instruments. Run your top-down analysis the night before or early morning before the open. Have your levels marked, your bias set, your zones identified. When the open hits you’re ready to execute, not still analyzing.

## Source Code

````pine
//@version=6
indicator("JRI SMC v13", shorttitle="JRI v13", overlay=true, max_boxes_count=50, max_labels_count=100, max_lines_count=100)

// ── INPUTS
swingLen = input.int(10,   "Swing Length",        minval=3, maxval=50, group="Structure")
atrLen   = input.int(14,   "ATR Length",          group="Risk")
slMult   = input.float(1.5,"SL Multiplier",       group="Risk")
minScore = input.int(6,    "Min Score 1-7",       minval=1, maxval=7, group="Signals")
maxLoss  = input.int(2,    "Max Consecutive Losses Before Stop", minval=1, maxval=5, group="Risk")
keyStep  = input.int(100,  "Key Level Interval",  group="Key Levels")
keyFwd   = input.int(50,   "Key Levels Fwd Bars", group="Key Levels")

showAsia   = input.bool(true, "Show Asia Session",   group="Sessions")
showLondon = input.bool(true, "Show London Session", group="Sessions")
showNY     = input.bool(true, "Show NY Session",     group="Sessions")

// ── CORE
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
myRsi = ta.rsi(close, 14)
myAtr = ta.atr(atrLen)
[myVwap,_,_] = ta.vwap(hlc3, timeframe.change("D"), 1)

recentHigh10 = ta.highest(high, 10)
recentLow10  = ta.lowest(low,  10)

isScalp = timeframe.period == "1" or timeframe.period == "3" or timeframe.period == "5"
mySL    = isScalp ? 0.8 : slMult
lineFwd = isScalp ? 12 : 25
boxSize = isScalp ? size.small : size.normal

// ── PLOTS
p20 = plot(ema20, "EMA 20", color=color.new(color.yellow, 0), linewidth=1)
p50 = plot(ema50, "EMA 50", color=color.new(color.orange, 0), linewidth=2)
fill(p20, p50, ema20 > ema50 ? color.new(color.lime, 91) : color.new(color.red, 91), "Cloud")
plot(myVwap, "VWAP", color=color.new(color.aqua, 10), linewidth=2, style=plot.style_stepline)

var float ath = na
var float atl = na
if na(ath) or high > ath
    ath := high
if na(atl) or low < atl
    atl := low
plot(ath, "ATH", color=color.new(color.red,   50), linewidth=1, style=plot.style_stepline)
plot(atl, "ATL", color=color.new(color.green, 50), linewidth=1, style=plot.style_stepline)

// ── SESSIONS
asiaSess   = time(timeframe.period, "2000-0400:23456", "America/New_York")
londonSess = time(timeframe.period, "0300-1200:23456", "America/New_York")
nySess     = time(timeframe.period, "0930-1600:23456", "America/New_York")

inAsia   = showAsia   and not na(asiaSess)
inLondon = showLondon and not na(londonSess)
inNY     = showNY     and not na(nySess)

sessionColor = inNY     ? color.new(color.green,  93) :
               inLondon ? color.new(color.blue,   93) :
               inAsia   ? color.new(color.purple, 93) : na

bgcolor(sessionColor, title="Session")

var label sessLbl = na
if barstate.islast
    label.delete(sessLbl)
    sessText = inNY     ? "NY SESSION" :
               inLondon ? "LONDON SESSION" :
               inAsia   ? "ASIA SESSION" : "OFF SESSION"
    sessClr  = inNY     ? color.green  :
               inLondon ? color.blue   :
               inAsia   ? color.purple : color.gray
    sessLbl := label.new(bar_index + 2, low, sessText, color=sessClr, textcolor=color.white, style=label.style_label_left, size=size.small)

// ── KEY LEVELS
if barstate.islast
    lo = math.floor(low / keyStep) * keyStep - keyStep * 2
    hi = math.ceil(high / keyStep) * keyStep + keyStep * 3
    lv = lo
    while lv <= hi
        big = lv % (keyStep * 5) == 0
        lc  = big ? color.new(color.white, 35) : color.new(color.gray, 80)
        lw  = big ? 2 : 1
        ls  = big ? line.style_solid : line.style_dotted
        line.new(bar_index - 3, lv, bar_index + keyFwd, lv, color=lc, width=lw, style=ls)
        if big
            label.new(bar_index + keyFwd + 1, lv, str.tostring(lv), color=color.new(color.black, 60), textcolor=color.new(color.white, 5), style=label.style_label_left, size=size.normal)
        lv := lv + keyStep

// ── SWINGS
pH = ta.pivothigh(high, swingLen, swingLen)
pL = ta.pivotlow(low,  swingLen, swingLen)

var float[] shV = array.new_float(0)
var float[] slV = array.new_float(0)
var int[]   shI = array.new_int(0)
var int[]   slI = array.new_int(0)

if not na(pH)
    array.push(shV, pH)
    array.push(shI, bar_index - swingLen)
    if array.size(shV) > 8
        array.shift(shV)
        array.shift(shI)

if not na(pL)
    array.push(slV, pL)
    array.push(slI, bar_index - swingLen)
    if array.size(slV) > 8
        array.shift(slV)
        array.shift(slI)

if not na(pH) and array.size(shV) >= 2
    prev = array.get(shV, array.size(shV) - 2)
    lbl  = pH > prev ? "HH" : "LH"
    clr  = pH > prev ? color.green : color.red
    label.new(bar_index - swingLen, pH, lbl, color=color.new(clr, 70), textcolor=clr, style=label.style_label_down, size=size.tiny)

if not na(pL) and array.size(slV) >= 2
    prev = array.get(slV, array.size(slV) - 2)
    lbl  = pL > prev ? "HL" : "LL"
    clr  = pL > prev ? color.green : color.red
    label.new(bar_index - swingLen, pL, lbl, color=color.new(clr, 70), textcolor=clr, style=label.style_label_up, size=size.tiny)

// ── BIAS
bullBias = false
bearBias = false
if array.size(shV) >= 2 and array.size(slV) >= 2
    sh1 = array.get(shV, array.size(shV) - 1)
    sh2 = array.get(shV, array.size(shV) - 2)
    sl1 = array.get(slV, array.size(slV) - 1)
    sl2 = array.get(slV, array.size(slV) - 2)
    bullBias := sh1 > sh2 and sl1 > sl2
    bearBias := sh1 < sh2 and sl1 < sl2

var label bLbl = na
if barstate.islast
    label.delete(bLbl)
    bLbl := label.new(bar_index + 2, high, bullBias ? "BULLISH" : bearBias ? "BEARISH" : "NEUTRAL", color=bullBias ? color.green : bearBias ? color.red : color.gray, textcolor=color.white, style=label.style_label_left, size=size.normal)

// ── INSTITUTION CANDLE
avgBody  = ta.sma(math.abs(close - open), 20)
bigBody  = math.abs(close - open) > avgBody * 2.0
instBull = bigBody and close > open
instBear = bigBody and close < open
bgcolor(instBull ? color.new(color.lime, 93) : instBear ? color.new(color.red, 93) : na, title="Inst Candle")

// ── BOS
rHL  = array.size(slV) >= 2 ? array.get(slV, array.size(slV) - 2) : na
rLH  = array.size(shV) >= 2 ? array.get(shV, array.size(shV) - 2) : na
rHLi = array.size(slI) >= 2 ? array.get(slI, array.size(slI) - 2) : na
rLHi = array.size(shI) >= 2 ? array.get(shI, array.size(shI) - 2) : na

bosD = not na(rHL) and close < rHL and close[1] >= rHL
bosU = not na(rLH) and close > rLH and close[1] <= rLH

if bosD and not na(rHLi)
    line.new(rHLi, rHL, bar_index, rHL, color=color.new(color.red, 40), width=1, style=line.style_dashed)
    label.new(bar_index, rHL, "BOS", color=color.new(color.red, 55), textcolor=color.red, style=label.style_label_left, size=size.tiny)

if bosU and not na(rLHi)
    line.new(rLHi, rLH, bar_index, rLH, color=color.new(color.green, 40), width=1, style=line.style_dashed)
    label.new(bar_index, rLH, "BOS", color=color.new(color.green, 55), textcolor=color.green, style=label.style_label_left, size=size.tiny)

// ── RETEST
var bool bbHL = false
var bool baLH = false
if bosD
    bbHL := true
if bosU
    baLH := true

buf  = 0.001
retR = bbHL and not na(rHL) and high >= rHL * (1 - buf) and close < rHL
retS = baLH and not na(rLH) and low  <= rLH * (1 + buf) and close > rLH
if retR
    bbHL := false
if retS
    baLH := false

// ── ZONES
var box[]   sBx = array.new_box(0)
var box[]   dBx = array.new_box(0)
var float[] sT  = array.new_float(0)
var float[] sBt = array.new_float(0)
var float[] dT  = array.new_float(0)
var float[] dBt = array.new_float(0)
var int[]   sC  = array.new_int(0)
var int[]   dC  = array.new_int(0)

if not na(pH)
    zT = pH * (1 + buf)
    zB = pH * (1 - buf)
    m  = false
    if array.size(sT) > 0
        for i = 0 to array.size(sT) - 1
            if pH >= array.get(sBt, i) and pH <= array.get(sT, i)
                array.set(sC, i, array.get(sC, i) + 1)
                m := true
                break
    if not m
        array.push(sT, zT)
        array.push(sBt, zB)
        array.push(sC, 1)

if not na(pL)
    zT = pL * (1 + buf)
    zB = pL * (1 - buf)
    m  = false
    if array.size(dT) > 0
        for i = 0 to array.size(dT) - 1
            if pL >= array.get(dBt, i) and pL <= array.get(dT, i)
                array.set(dC, i, array.get(dC, i) + 1)
                m := true
                break
    if not m
        array.push(dT, zT)
        array.push(dBt, zB)
        array.push(dC, 1)

minRej = 2
if barstate.islast
    for b in sBx
        box.delete(b)
    for b in dBx
        box.delete(b)
    array.clear(sBx)
    array.clear(dBx)
    if array.size(sT) > 0
        for i = 0 to array.size(sT) - 1
            if array.get(sC, i) >= minRej
                b = box.new(bar_index - 30, array.get(sT, i), bar_index + 30, array.get(sBt, i), border_color=color.new(color.red, 40), bgcolor=color.new(color.red, 86), border_width=1)
                array.push(sBx, b)
    if array.size(dT) > 0
        for i = 0 to array.size(dT) - 1
            if array.get(dC, i) >= minRej
                b = box.new(bar_index - 30, array.get(dT, i), bar_index + 30, array.get(dBt, i), border_color=color.new(color.green, 40), bgcolor=color.new(color.green, 86), border_width=1)
                array.push(dBx, b)

inSZ() =>
    r = false
    if array.size(sT) > 0
        for i = 0 to array.size(sT) - 1
            if array.get(sC, i) >= minRej
                if close >= array.get(sBt, i) and close <= array.get(sT, i)
                    r := true
    r

inDZ() =>
    r = false
    if array.size(dT) > 0
        for i = 0 to array.size(dT) - 1
            if array.get(dC, i) >= minRej
                if close >= array.get(dBt, i) and close <= array.get(dT, i)
                    r := true
    r

// ── ZONE TOUCH ALERT
touchDemand = inDZ() and not inDZ()[1]
touchSupply = inSZ() and not inSZ()[1]

if touchDemand
    label.new(bar_index, low, "WATCH DEMAND", color=color.new(color.green, 40), textcolor=color.white, style=label.style_label_up, size=size.tiny)
if touchSupply
    label.new(bar_index, high, "WATCH SUPPLY", color=color.new(color.red, 40), textcolor=color.white, style=label.style_label_down, size=size.tiny)

// ── LIQ SWEEPS
liqSweepH = high > recentHigh10[1] and close < recentHigh10[1]
liqSweepL = low  < recentLow10[1]  and close > recentLow10[1]

if liqSweepH
    label.new(bar_index, high, "LIQ SWEEP", color=color.new(color.orange, 60), textcolor=color.orange, style=label.style_label_down, size=size.tiny)
if liqSweepL
    label.new(bar_index, low, "LIQ SWEEP", color=color.new(color.orange, 60), textcolor=color.orange, style=label.style_label_up, size=size.tiny)

// ── SCORE
b1  = bullBias       ? 1 : 0
b2  = inDZ()        ? 1 : 0
b3  = bosU           ? 1 : 0
b4  = retS           ? 1 : 0
b5  = close > myVwap ? 1 : 0
b6  = ema20 > ema50  ? 1 : 0
b7  = myRsi > 50     ? 1 : 0
bSc = b1 + b2 + b3 + b4 + b5 + b6 + b7

s1  = bearBias       ? 1 : 0
s2  = inSZ()        ? 1 : 0
s3  = bosD           ? 1 : 0
s4  = retR           ? 1 : 0
s5  = close < myVwap ? 1 : 0
s6  = ema20 < ema50  ? 1 : 0
s7  = myRsi < 50     ? 1 : 0
sSc = s1 + s2 + s3 + s4 + s5 + s6 + s7

// ── CONSECUTIVE LOSS TRACKER
var int  consLoss   = 0
var bool tradeLock  = false
var int  lastBuyBar = na
var int  lastSellBar= na

cooldown = isScalp ? swingLen * 5 : swingLen * 3

var bool inBuy  = false
var bool inSell = false

bFire = bSc >= minScore and not inBuy  and not inSell and not tradeLock and (na(lastBuyBar)  or bar_index - lastBuyBar  > cooldown)
sFire = sSc >= minScore and not inSell and not inBuy  and not tradeLock and (na(lastSellBar) or bar_index - lastSellBar > cooldown)

if bFire
    inBuy      := true
    inSell     := false
    lastBuyBar := bar_index
if sFire
    inSell      := true
    inBuy       := false
    lastSellBar := bar_index

if bSc < minScore - 1 and inBuy
    inBuy  := false
if sSc < minScore - 1 and inSell
    inSell := false

// ── TRADE LOCK — stop after max consecutive losses
if bFire or sFire
    consLoss  := 0
    tradeLock := false

if bSc < 2 and inBuy
    consLoss  := consLoss + 1
    inBuy     := false
    if consLoss >= maxLoss
        tradeLock := true

if sSc < 2 and inSell
    consLoss  := consLoss + 1
    inSell    := false
    if consLoss >= maxLoss
        tradeLock := true

var label lockLbl = na
if tradeLock and barstate.islast
    label.delete(lockLbl)
    lockLbl := label.new(bar_index, high, "STOP TRADING\n" + str.tostring(maxLoss) + " LOSSES — STEP AWAY", color=color.new(color.red, 10), textcolor=color.white, style=label.style_label_left, size=size.normal)

// ── ARROWS
plotshape(bFire, "BUY",  shape.labelup,   location.belowbar, color.lime, size=size.small, text="BUY",  textcolor=color.black)
plotshape(sFire, "SELL", shape.labeldown, location.abovebar, color.red,  size=size.small, text="SELL", textcolor=color.white)

bgcolor(bFire ? color.new(color.lime, 85) : sFire ? color.new(color.red, 85) : na, title="Signal Bar")

// ── ENTRY BOX
if bFire
    ep  = high
    sl  = low - myAtr * mySL
    rr  = ep - sl
    t1  = ep + rr
    t2  = ep + rr * 2
    t3  = ep + rr * 3
    line.new(bar_index, ep, bar_index + lineFwd, ep, color=color.white,  width=2)
    line.new(bar_index, sl, bar_index + lineFwd, sl, color=color.red,    width=2)
    line.new(bar_index, t1, bar_index + lineFwd, t1, color=color.yellow, width=1, style=line.style_dashed)
    line.new(bar_index, t2, bar_index + lineFwd, t2, color=color.lime,   width=2, style=line.style_dashed)
    line.new(bar_index, t3, bar_index + lineFwd, t3, color=color.green,  width=3)
    msg = "BUY @ " + str.tostring(ep, "#.##") + "\nSL: " + str.tostring(sl, "#.##") + "  -" + str.tostring(math.round(rr, 1), "#.#") + " pts\n\nT1: " + str.tostring(t1, "#.##") + "  TAKE PARTIAL\nT2: " + str.tostring(t2, "#.##") + "  MOVE SL TO ENTRY\nT3: " + str.tostring(t3, "#.##") + "  FULL TP 1:3\n\nScore: " + str.tostring(bSc) + "/7"
    label.new(bar_index, low - myAtr * 0.3, msg, color=color.new(color.green, 8), textcolor=color.white, style=label.style_label_upper_right, size=boxSize, textalign=text.align_left)

if sFire
    ep  = low
    sl  = high + myAtr * mySL
    rr  = sl - ep
    t1  = ep - rr
    t2  = ep - rr * 2
    t3  = ep - rr * 3
    line.new(bar_index, ep, bar_index + lineFwd, ep, color=color.white,  width=2)
    line.new(bar_index, sl, bar_index + lineFwd, sl, color=color.red,    width=2)
    line.new(bar_index, t1, bar_index + lineFwd, t1, color=color.yellow, width=1, style=line.style_dashed)
    line.new(bar_index, t2, bar_index + lineFwd, t2, color=color.lime,   width=2, style=line.style_dashed)
    line.new(bar_index, t3, bar_index + lineFwd, t3, color=color.green,  width=3)
    msg = "SELL @ " + str.tostring(ep, "#.##") + "\nSL: " + str.tostring(sl, "#.##") + "  +" + str.tostring(math.round(rr, 1), "#.#") + " pts\n\nT1: " + str.tostring(t1, "#.##") + "  TAKE PARTIAL\nT2: " + str.tostring(t2, "#.##") + "  MOVE SL TO ENTRY\nT3: " + str.tostring(t3, "#.##") + "  FULL TP 1:3\n\nScore: " + str.tostring(sSc) + "/7"
    label.new(bar_index, high + myAtr * 0.3, msg, color=color.new(color.red, 8), textcolor=color.white, style=label.style_label_lower_right, size=boxSize, textalign=text.align_left)

// ── DASHBOARD
var table dash = table.new(position.top_right, 3, 10, bgcolor=color.new(color.black, 15), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.gray, frame_width=1)
if barstate.islast
    table.cell(dash, 0, 0, "CONDITION", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 20))
    table.cell(dash, 1, 0, "BUY " + str.tostring(bSc) + "/7", text_color=color.lime, text_size=size.small, bgcolor=color.new(color.navy, 20))
    table.cell(dash, 2, 0, "SELL " + str.tostring(sSc) + "/7", text_color=color.red, text_size=size.small, bgcolor=color.new(color.navy, 20))
    conds = array.from("Bias", "In Zone", "BOS", "Retest", "vs VWAP", "EMA", "RSI")
    bChk  = array.from(bullBias, inDZ(), bosU, retS, close > myVwap, ema20 > ema50, myRsi > 50)
    sChk  = array.from(bearBias, inSZ(), bosD, retR, close < myVwap, ema20 < ema50, myRsi < 50)
    for i = 0 to 6
        bc = array.get(bChk, i)
        sc = array.get(sChk, i)
        table.cell(dash, 0, i + 1, array.get(conds, i), text_color=color.white, text_size=size.tiny)
        table.cell(dash, 1, i + 1, bc ? "YES" : "NO", text_color=bc ? color.lime : color.red, text_size=size.small)
        table.cell(dash, 2, i + 1, sc ? "YES" : "NO", text_color=sc ? color.lime : color.red, text_size=size.small)

// ── ALERTS
alertcondition(bFire,        "JRI BUY",         "JRI BUY fired")
alertcondition(sFire,        "JRI SELL",        "JRI SELL fired")
alertcondition(touchDemand,  "JRI Watch Demand","Price entered demand zone — watch for entry")
alertcondition(touchSupply,  "JRI Watch Supply","Price entered supply zone — watch for entry")
alertcondition(tradeLock,    "JRI STOP TRADING","You hit max losses — step away and reset")
alertcondition(bullBias,     "JRI Bullish",     "Structure BULLISH")
alertcondition(bearBias,     "JRI Bearish",     "Structure BEARISH")
alertcondition(liqSweepH,    "JRI Liq High",    "Liquidity sweep high")
alertcondition(liqSweepL,    "JRI Liq Low",     "Liquidity sweep low")
````
