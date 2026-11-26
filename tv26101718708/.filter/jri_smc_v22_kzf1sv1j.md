# JRI SMC v22

- url: https://www.tradingview.com/script/KzF1Sv1J-JRI-SMC-v22/
- type: indicator
- pine_id: PUB;a78db74d0ba24689a449ccd073ddace8
- version: 3.0

## Description

THE 7 CONDITIONS YOUR INDICATOR CHECKS
	1.	Bias — Is the market structure bullish (HH+HL) or bearish (LH+LL)?
	2.	In Zone — Is price inside a confirmed supply or demand zone?
	3.	BOS — Did price break a recent structure level in your direction?
	4.	Retest — Did price come back and test that broken level?
	5.	vs VWAP — Is price above VWAP for buys, below for sells?
	6.	EMA Stack — Is EMA 20 above EMA 50 for buys, below for sells?
	7.	RSI — Is RSI above 50 for buys, below 50 for sells?
All 7 pointing the same direction means institutions are aligned with your trade. That’s when you pull the trigger.

## Source Code

````pine
//@version=6
indicator("JRI SMC v21", shorttitle="JRI v21", overlay=true, max_boxes_count=5, max_labels_count=80, max_lines_count=80)

// ── INPUTS
swingLen = input.int(10,    "Swing Length",           minval=3, maxval=50,  group="Structure")
atrLen   = input.int(14,    "ATR Length",             group="Risk")
slMult   = input.float(1.5, "SL Multiplier",          group="Risk")
pointVal = input.float(1.0, "Point Value broker adj", minval=0.00001, step=0.0001, group="Risk")
minScore = input.int(6,     "Min Confirmations 1-9",  minval=1, maxval=9,   group="Signals")
maxLoss  = input.int(2,     "Max Losses Before Stop", minval=1, maxval=5,   group="Risk")
onlySess = input.bool(true, "Only Signal In NY and London", group="Signals")
keyStep  = input.int(100,   "Key Level Interval",     group="Key Levels")
keyFwd   = input.int(40,    "Key Levels Fwd Bars",    group="Key Levels")
showFib  = input.bool(true, "Show Fib Levels",        group="Tools")

// ── CORE
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
myRsi = ta.rsi(close, 14)
myAtr = ta.atr(atrLen) * pointVal
[myVwap,_,_] = ta.vwap(hlc3, timeframe.change("D"), 1)
prevHigh10 = ta.highest(high, 10)[1]
prevLow10  = ta.lowest(low,  10)[1]

isScalp  = timeframe.period == "1" or timeframe.period == "3" or timeframe.period == "5"
mySL     = isScalp ? 0.8 : slMult
lineFwd  = isScalp ? 15 : 30
cooldown = isScalp ? swingLen * 10 : swingLen * 4

// ── EMA PLOTS — clean, minimal
p20 = plot(ema20, "EMA 20", color=color.new(color.yellow, 20), linewidth=1)
p50 = plot(ema50, "EMA 50", color=color.new(color.orange, 20), linewidth=2)
fill(p20, p50, ema20 > ema50 ? color.new(color.lime, 95) : color.new(color.red, 95), "Cloud")
plot(myVwap, "VWAP", color=color.new(color.aqua, 30), linewidth=1, style=plot.style_stepline)

// ── ATH ATL — very subtle
var float ath = na
var float atl = na
if na(ath) or high > ath
    ath := high
if na(atl) or low < atl
    atl := low
plot(ath, "ATH", color=color.new(color.red,   75), linewidth=1, style=plot.style_stepline)
plot(atl, "ATL", color=color.new(color.green, 75), linewidth=1, style=plot.style_stepline)

// ── SESSIONS — very subtle background only
londonSess = time(timeframe.period, "0300-1200:23456", "America/New_York")
nySess     = time(timeframe.period, "0930-1600:23456", "America/New_York")
inLondon   = not na(londonSess)
inNY       = not na(nySess)
inSession  = inNY or inLondon
sessName   = inNY ? "NY" : inLondon ? "LONDON" : "OFF"
sessClr    = inNY ? color.green : inLondon ? color.blue : color.red
bgcolor(inNY ? color.new(color.green, 97) : inLondon ? color.new(color.blue, 97) : na, title="Session")

// ── KEY LEVELS — only major rounded numbers
if barstate.islast
    lo = math.floor(low / keyStep) * keyStep - keyStep * 2
    hi = math.ceil(high / keyStep) * keyStep + keyStep * 3
    lv = lo
    while lv <= hi
        big = lv % (keyStep * 5) == 0
        line.new(bar_index - 3, lv, bar_index + keyFwd, lv, color=big ? color.new(color.white, 55) : color.new(color.gray, 88), width=big ? 1 : 1, style=big ? line.style_solid : line.style_dotted)
        if big
            label.new(bar_index + keyFwd + 1, lv, str.tostring(lv), color=color.new(color.black, 80), textcolor=color.new(color.white, 20), style=label.style_label_left, size=size.tiny)
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
    if array.size(shV) > 10
        array.shift(shV)
        array.shift(shI)

if not na(pL)
    array.push(slV, pL)
    array.push(slI, bar_index - swingLen)
    if array.size(slV) > 10
        array.shift(slV)
        array.shift(slI)

if not na(pH) and array.size(shV) >= 2
    prev = array.get(shV, array.size(shV) - 2)
    lbl  = pH > prev ? "HH" : "LH"
    clr  = pH > prev ? color.green : color.red
    label.new(bar_index - swingLen, pH, lbl, color=color.new(clr, 80), textcolor=clr, style=label.style_label_down, size=size.tiny)

if not na(pL) and array.size(slV) >= 2
    prev = array.get(slV, array.size(slV) - 2)
    lbl  = pL > prev ? "HL" : "LL"
    clr  = pL > prev ? color.green : color.red
    label.new(bar_index - swingLen, pL, lbl, color=color.new(clr, 80), textcolor=clr, style=label.style_label_up, size=size.tiny)

// ── BIAS — requires 2 consecutive confirming swings
bullBias = false
bearBias = false
if array.size(shV) >= 3 and array.size(slV) >= 3
    sh1 = array.get(shV, array.size(shV) - 1)
    sh2 = array.get(shV, array.size(shV) - 2)
    sh3 = array.get(shV, array.size(shV) - 3)
    sl1 = array.get(slV, array.size(slV) - 1)
    sl2 = array.get(slV, array.size(slV) - 2)
    sl3 = array.get(slV, array.size(slV) - 3)
    bullBias := sh1 > sh2 and sh2 > sh3 and sl1 > sl2 and sl2 > sl3
    bearBias := sh1 < sh2 and sh2 < sh3 and sl1 < sl2 and sl2 < sl3

var label bLbl = na
if barstate.islast
    label.delete(bLbl)
    bLbl := label.new(bar_index + 2, high, bullBias ? "BULLISH" : bearBias ? "BEARISH" : "NEUTRAL", color=bullBias ? color.new(color.green,30) : bearBias ? color.new(color.red,30) : color.new(color.gray,30), textcolor=color.white, style=label.style_label_left, size=size.small)

// ── INSTITUTION CANDLE — very subtle
avgBody  = ta.sma(math.abs(close - open), 20)
bigBody  = math.abs(close - open) > avgBody * 2.0
instMove = bigBody

// ── BOS / CHOCH
rHL  = array.size(slV) >= 2 ? array.get(slV, array.size(slV) - 2) : na
rLH  = array.size(shV) >= 2 ? array.get(shV, array.size(shV) - 2) : na
rHLi = array.size(slI) >= 2 ? array.get(slI, array.size(slI) - 2) : na
rLHi = array.size(shI) >= 2 ? array.get(shI, array.size(shI) - 2) : na

bosD = not na(rHL) and close < rHL and close[1] >= rHL
bosU = not na(rLH) and close > rLH and close[1] <= rLH

if bosD and not na(rHLi)
    line.new(rHLi, rHL, bar_index, rHL, color=color.new(color.red, 50), width=1, style=line.style_dashed)
    label.new(bar_index, rHL, "CHoCH", color=color.new(color.red, 60), textcolor=color.red, style=label.style_label_left, size=size.tiny)

if bosU and not na(rLHi)
    line.new(rLHi, rLH, bar_index, rLH, color=color.new(color.green, 50), width=1, style=line.style_dashed)
    label.new(bar_index, rLH, "CHoCH", color=color.new(color.green, 60), textcolor=color.green, style=label.style_label_left, size=size.tiny)

// ── RETEST / MITIGATION
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

// ── IMBALANCE / FVG
fvgBull = low > high[2] and close[1] > high[2]
fvgBear = high < low[2] and close[1] < low[2]

// ── SUPPLY DEMAND — LINES ONLY
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
    if array.size(sT) > 0
        for i = 0 to array.size(sT) - 1
            if array.get(sC, i) >= minRej
                lvl = (array.get(sT, i) + array.get(sBt, i)) / 2
                line.new(bar_index - 20, lvl, bar_index + keyFwd, lvl, color=color.new(color.red, 30), width=2)
                label.new(bar_index + keyFwd + 1, lvl, "S", color=color.new(color.red, 60), textcolor=color.red, style=label.style_label_left, size=size.tiny)
    if array.size(dT) > 0
        for i = 0 to array.size(dT) - 1
            if array.get(dC, i) >= minRej
                lvl = (array.get(dT, i) + array.get(dBt, i)) / 2
                line.new(bar_index - 20, lvl, bar_index + keyFwd, lvl, color=color.new(color.green, 30), width=2)
                label.new(bar_index + keyFwd + 1, lvl, "D", color=color.new(color.green, 60), textcolor=color.green, style=label.style_label_left, size=size.tiny)

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

// ── LIQUIDITY SWEEPS
liqH = high > prevHigh10 and close < prevHigh10
liqL = low  < prevLow10  and close > prevLow10

if liqH
    label.new(bar_index, high, "LSH", color=color.new(color.orange, 70), textcolor=color.orange, style=label.style_label_down, size=size.tiny)
if liqL
    label.new(bar_index, low,  "LSL", color=color.new(color.orange, 70), textcolor=color.orange, style=label.style_label_up,   size=size.tiny)

// ── FIB LEVELS
var line fib382  = na
var line fib500  = na
var line fib618  = na
var label fib382L = na
var label fib500L = na
var label fib618L = na

if showFib and barstate.islast and array.size(shV) >= 1 and array.size(slV) >= 1
    line.delete(fib382)
    line.delete(fib500)
    line.delete(fib618)
    label.delete(fib382L)
    label.delete(fib500L)
    label.delete(fib618L)
    swHigh = array.get(shV, array.size(shV) - 1)
    swLow  = array.get(slV, array.size(slV) - 1)
    swRng  = swHigh - swLow
    f382 = bullBias ? swLow  + swRng * 0.382 : swHigh - swRng * 0.382
    f500 = bullBias ? swLow  + swRng * 0.5   : swHigh - swRng * 0.5
    f618 = bullBias ? swLow  + swRng * 0.618 : swHigh - swRng * 0.618
    nearPrice = math.abs(close - f500) < (high - low) * 8
    if nearPrice
        fib382  := line.new(bar_index - 8, f382, bar_index + 20, f382, color=color.new(color.yellow, 50), width=1, style=line.style_dashed)
        fib500  := line.new(bar_index - 8, f500, bar_index + 20, f500, color=color.new(color.white,  50), width=1, style=line.style_dashed)
        fib618  := line.new(bar_index - 8, f618, bar_index + 20, f618, color=color.new(color.lime,   50), width=1, style=line.style_dashed)
        fib382L := label.new(bar_index + 21, f382, "0.382 " + str.tostring(f382, "#.##"), color=color.new(color.black, 75), textcolor=color.yellow, style=label.style_label_left, size=size.tiny)
        fib500L := label.new(bar_index + 21, f500, "0.5   " + str.tostring(f500, "#.##"), color=color.new(color.black, 75), textcolor=color.white,  style=label.style_label_left, size=size.tiny)
        fib618L := label.new(bar_index + 21, f618, "0.618 " + str.tostring(f618, "#.##"), color=color.new(color.black, 75), textcolor=color.lime,   style=label.style_label_left, size=size.tiny)

// ── POWERHOUSE 9 CONFIRMATIONS
c1 = bullBias or bearBias
c2 = liqH or liqL
c3 = instMove
c4 = fvgBull or fvgBear
c5 = bosU or bosD
c6 = retS or retR
c7 = (myRsi > 60 and bullBias) or (myRsi < 40 and bearBias)
c8 = inDZ() or inSZ()
rrOK = myAtr * mySL > 0
c9 = rrOK

confScore = (c1?1:0) + (c2?1:0) + (c3?1:0) + (c4?1:0) + (c5?1:0) + (c6?1:0) + (c7?1:0) + (c8?1:0) + (c9?1:0)

biasOkBuy  = bullBias and bosU
biasOkSell = bearBias and bosD

// ── SIGNALS
var bool inBuy       = false
var bool inSell      = false
var int  lastBuyBar  = na
var int  lastSellBar = na
var int  consLoss    = 0
var bool tradeLock   = false

sessionOK = onlySess ? inSession : true

bFire = confScore >= minScore and biasOkBuy  and not inBuy  and not inSell and not tradeLock and sessionOK and (na(lastBuyBar)  or bar_index - lastBuyBar  > cooldown)
sFire = confScore >= minScore and biasOkSell and not inSell and not inBuy  and not tradeLock and sessionOK and (na(lastSellBar) or bar_index - lastSellBar > cooldown)

if bFire
    inBuy       := true
    inSell      := false
    lastBuyBar  := bar_index
if sFire
    inSell      := true
    inBuy       := false
    lastSellBar := bar_index
if confScore < minScore - 2 and inBuy
    inBuy := false
if confScore < minScore - 2 and inSell
    inSell := false

// ── TRADE TRACKER
var float tradeEntry   = na
var float tradeSL      = na
var float tradeT1      = na
var float tradeT2      = na
var float tradeT3      = na
var bool  tradeIsLong  = false
var bool  tradeActive  = false
var string tradeStatus = "FLAT"
var int   winsDay      = 0
var int   lossDay      = 0
var int   winsWeek     = 0
var int   lossWeek     = 0

if bFire[1] and not tradeActive
    tradeEntry  := open
    tradeSL     := open - myAtr * mySL
    tradeT1     := open + (open - tradeSL)
    tradeT2     := open + (open - tradeSL) * 2.0
    tradeT3     := open + (open - tradeSL) * 3.0
    tradeIsLong := true
    tradeActive := true
    tradeStatus := "LONG ACTIVE"

if sFire[1] and not tradeActive
    tradeEntry  := open
    tradeSL     := open + myAtr * mySL
    tradeT1     := open - (tradeSL - open)
    tradeT2     := open - (tradeSL - open) * 2.0
    tradeT3     := open - (tradeSL - open) * 3.0
    tradeIsLong := false
    tradeActive := true
    tradeStatus := "SHORT ACTIVE"

if tradeActive and tradeIsLong and low <= tradeSL
    tradeActive := false
    tradeStatus := "STOPPED OUT"
    lossDay     := lossDay + 1
    lossWeek    := lossWeek + 1
    consLoss    := consLoss + 1
    if consLoss >= maxLoss
        tradeLock := true

if tradeActive and not tradeIsLong and high >= tradeSL
    tradeActive := false
    tradeStatus := "STOPPED OUT"
    lossDay     := lossDay + 1
    lossWeek    := lossWeek + 1
    consLoss    := consLoss + 1
    if consLoss >= maxLoss
        tradeLock := true

if tradeActive and tradeIsLong and high >= tradeT3
    tradeActive := false
    tradeStatus := "T3 WIN"
    winsDay     := winsDay + 1
    winsWeek    := winsWeek + 1
    consLoss    := 0
    tradeLock   := false

if tradeActive and not tradeIsLong and low <= tradeT3
    tradeActive := false
    tradeStatus := "T3 WIN"
    winsDay     := winsDay + 1
    winsWeek    := winsWeek + 1
    consLoss    := 0
    tradeLock   := false

if dayofmonth != dayofmonth[1]
    winsDay   := 0
    lossDay   := 0
    consLoss  := 0
    tradeLock := false

if dayofweek == dayofweek.monday and dayofweek != dayofweek[1]
    winsWeek := 0
    lossWeek := 0

// ── ARROWS
plotshape(bFire, "BUY",  shape.labelup,   location.belowbar, color.lime, size=size.small, text="BUY",  textcolor=color.black)
plotshape(sFire, "SELL", shape.labeldown, location.abovebar, color.red,  size=size.small, text="SELL", textcolor=color.white)

// ── 1:3 ENTRY BOX — clean labeled lines
if bFire
    ep  = high
    sl  = low - myAtr * mySL
    rr  = ep - sl
    t1  = ep + rr
    t2  = ep + rr * 2.0
    t3  = ep + rr * 3.0
    line.new(bar_index, ep, bar_index + lineFwd, ep, color=color.white,                width=2)
    line.new(bar_index, sl, bar_index + lineFwd, sl, color=color.red,                  width=2)
    line.new(bar_index, t1, bar_index + lineFwd, t1, color=color.yellow,               width=1, style=line.style_dashed)
    line.new(bar_index, t2, bar_index + lineFwd, t2, color=color.new(color.lime, 20),  width=1, style=line.style_dashed)
    line.new(bar_index, t3, bar_index + lineFwd, t3, color=color.lime,                 width=2)
    label.new(bar_index + lineFwd + 1, ep, "ENTRY " + str.tostring(ep, "#.##"),        color=color.new(color.black,70), textcolor=color.white,  style=label.style_label_left, size=size.tiny)
    label.new(bar_index + lineFwd + 1, sl, "SL  "  + str.tostring(sl, "#.##"),        color=color.new(color.black,70), textcolor=color.red,    style=label.style_label_left, size=size.tiny)
    label.new(bar_index + lineFwd + 1, t1, "T1  "  + str.tostring(t1, "#.##"),        color=color.new(color.black,70), textcolor=color.yellow, style=label.style_label_left, size=size.tiny)
    label.new(bar_index + lineFwd + 1, t2, "T2  "  + str.tostring(t2, "#.##"),        color=color.new(color.black,70), textcolor=color.lime,   style=label.style_label_left, size=size.tiny)
    label.new(bar_index + lineFwd + 1, t3, "T3  "  + str.tostring(t3, "#.##"),        color=color.new(color.black,70), textcolor=color.lime,   style=label.style_label_left, size=size.tiny)
    label.new(bar_index, low - myAtr * 0.3, "BUY " + str.tostring(confScore) + "/9  next candle open", color=color.new(color.green, 15), textcolor=color.white, style=label.style_label_upper_right, size=size.small)

if sFire
    ep  = low
    sl  = high + myAtr * mySL
    rr  = sl - ep
    t1  = ep - rr
    t2  = ep - rr * 2.0
    t3  = ep - rr * 3.0
    line.new(bar_index, ep, bar_index + lineFwd, ep, color=color.white,                width=2)
    line.new(bar_index, sl, bar_index + lineFwd, sl, color=color.red,                  width=2)
    line.new(bar_index, t1, bar_index + lineFwd, t1, color=color.yellow,               width=1, style=line.style_dashed)
    line.new(bar_index, t2, bar_index + lineFwd, t2, color=color.new(color.lime, 20),  width=1, style=line.style_dashed)
    line.new(bar_index, t3, bar_index + lineFwd, t3, color=color.lime,                 width=2)
    label.new(bar_index + lineFwd + 1, ep, "ENTRY " + str.tostring(ep, "#.##"),        color=color.new(color.black,70), textcolor=color.white,  style=label.style_label_left, size=size.tiny)
    label.new(bar_index + lineFwd + 1, sl, "SL  "  + str.tostring(sl, "#.##"),        color=color.new(color.black,70), textcolor=color.red,    style=label.style_label_left, size=size.tiny)
    label.new(bar_index + lineFwd + 1, t1, "T1  "  + str.tostring(t1, "#.##"),        color=color.new(color.black,70), textcolor=color.yellow, style=label.style_label_left, size=size.tiny)
    label.new(bar_index + lineFwd + 1, t2, "T2  "  + str.tostring(t2, "#.##"),        color=color.new(color.black,70), textcolor=color.lime,   style=label.style_label_left, size=size.tiny)
    label.new(bar_index + lineFwd + 1, t3, "T3  "  + str.tostring(t3, "#.##"),        color=color.new(color.black,70), textcolor=color.lime,   style=label.style_label_left, size=size.tiny)
    label.new(bar_index, high + myAtr * 0.3, "SELL " + str.tostring(confScore) + "/9  next candle open", color=color.new(color.red, 15), textcolor=color.white, style=label.style_label_lower_right, size=size.small)

// ── DASHBOARD — Powerhouse 9 checklist
var table dash = table.new(position.top_right, 2, 25, bgcolor=color.new(color.black, 15), border_color=color.new(color.gray, 70), border_width=1, frame_color=color.new(color.gray,50), frame_width=1)

if barstate.islast
    dTot  = winsDay + lossDay
    wTot  = winsWeek + lossWeek
    dPct  = dTot > 0 ? math.round(winsDay  / dTot * 100) : 0
    wPct  = wTot > 0 ? math.round(winsWeek / wTot * 100) : 0
    dt    = str.tostring(year) + "/" + str.tostring(month, "00") + "/" + str.tostring(dayofmonth, "00")
    tClr  = tradeActive ? (tradeIsLong ? color.lime : color.red) : tradeStatus == "T3 WIN" ? color.lime : tradeStatus == "STOPPED OUT" ? color.red : color.gray
    lkClr = tradeLock ? color.red : color.new(color.lime, 20)
    eTxt  = tradeActive ? str.tostring(tradeEntry, "#.##") : "---"
    slTxt = tradeActive ? str.tostring(tradeSL,    "#.##") : "---"
    t1Txt = tradeActive ? str.tostring(tradeT1,    "#.##") : "---"
    t2Txt = tradeActive ? str.tostring(tradeT2,    "#.##") : "---"
    t3Txt = tradeActive ? str.tostring(tradeT3,    "#.##") : "---"
    gr    = color.new(color.gray, 25)
    hdr   = color.new(color.navy, 20)

    table.cell(dash, 0, 0,  "JRI v21",      text_color=color.white,               text_size=size.small, bgcolor=hdr)
    table.cell(dash, 1, 0,  dt,             text_color=color.new(color.white,15),  text_size=size.small, bgcolor=hdr)
    table.cell(dash, 0, 1,  "SESSION",      text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 1,  sessName,       text_color=sessClr, text_size=size.small)
    table.cell(dash, 0, 2,  "TRADE",        text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 2,  tradeStatus,    text_color=tClr, text_size=size.small)
    table.cell(dash, 0, 3,  "ENTRY",        text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 3,  eTxt,           text_color=color.white,  text_size=size.tiny)
    table.cell(dash, 0, 4,  "SL",           text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 4,  slTxt,          text_color=color.red,    text_size=size.tiny)
    table.cell(dash, 0, 5,  "T1  1:1",      text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 5,  t1Txt,          text_color=color.yellow, text_size=size.tiny)
    table.cell(dash, 0, 6,  "T2  1:2",      text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 6,  t2Txt,          text_color=color.lime,   text_size=size.tiny)
    table.cell(dash, 0, 7,  "T3  1:3",      text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 7,  t3Txt,          text_color=color.green,  text_size=size.tiny)
    table.cell(dash, 0, 8,  "DAY W/L",      text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 8,  str.tostring(winsDay) + "W  " + str.tostring(lossDay) + "L  " + str.tostring(dPct) + "%", text_color=dPct>=50?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 9,  "WEEK W/L",     text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 9,  str.tostring(winsWeek) + "W  " + str.tostring(lossWeek) + "L  " + str.tostring(wPct) + "%", text_color=wPct>=50?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 10, "STATUS",       text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 10, tradeLock ? "STOP TRADING" : "TRADING OK", text_color=lkClr, text_size=size.tiny)
    table.cell(dash, 0, 11, "SCORE",        text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 11, str.tostring(confScore) + " / 9", text_color=confScore>=6?color.lime:confScore>=4?color.yellow:color.red, text_size=size.small)
    table.cell(dash, 0, 12, "── CHECKLIST", text_color=color.new(color.white,30), text_size=size.tiny, bgcolor=hdr)
    table.cell(dash, 1, 12, "Powerhouse",   text_color=color.new(color.white,30), text_size=size.tiny, bgcolor=hdr)
    table.cell(dash, 0, 13, "1 Trend/Struct", text_color=gr, text_size=size.tiny)
    table.cell(dash, 1, 13, c1 ? "YES" : "NO", text_color=c1?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 14, "2 Liquidity",  text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 14, c2 ? "YES" : "NO", text_color=c2?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 15, "3 Inst Move",  text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 15, c3 ? "YES" : "NO", text_color=c3?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 16, "4 Imbalance",  text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 16, c4 ? "YES" : "NO", text_color=c4?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 17, "5 CHoCH",      text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 17, c5 ? "YES" : "NO", text_color=c5?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 18, "6 Mitigation", text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 18, c6 ? "YES" : "NO", text_color=c6?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 19, "7 Divergence", text_color=gr,  text_size=size.tiny)
    table.cell(dash, 1, 19, c7 ? "YES" : "NO", text_color=c7?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 20, "8 Entry Level", text_color=gr, text_size=size.tiny)
    table.cell(dash, 1, 20, c8 ? "YES" : "NO", text_color=c8?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 21, "9 Risk:Reward", text_color=gr, text_size=size.tiny)
    table.cell(dash, 1, 21, c9 ? "YES" : "NO", text_color=c9?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 22, "VWAP",          text_color=gr, text_size=size.tiny)
    table.cell(dash, 1, 22, close > myVwap ? "ABOVE" : "BELOW", text_color=close>myVwap?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 23, "EMA",           text_color=gr, text_size=size.tiny)
    table.cell(dash, 1, 23, ema20 > ema50 ? "BULL" : "BEAR", text_color=ema20>ema50?color.lime:color.red, text_size=size.tiny)
    table.cell(dash, 0, 24, "RSI",           text_color=gr, text_size=size.tiny)
    table.cell(dash, 1, 24, str.tostring(math.round(myRsi)) + (myRsi>50?" BULL":" BEAR"), text_color=myRsi>50?color.lime:color.red, text_size=size.tiny)

alertcondition(bFire,  "JRI BUY",         "JRI BUY - enter next candle open")
alertcondition(sFire,  "JRI SELL",        "JRI SELL - enter next candle open")
alertcondition(tradeLock, "JRI STOP TRADING", "Max losses hit - step away")
alertcondition(bullBias,  "JRI Bullish",  "Structure BULLISH confirmed")
alertcondition(bearBias,  "JRI Bearish",  "Structure BEARISH confirmed")
alertcondition(liqH,      "JRI Liq High", "Liquidity sweep high")
alertcondition(liqL,      "JRI Liq Low",  "Liquidity sweep low")
````
