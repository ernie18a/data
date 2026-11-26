# JRI SMC v15

- url: https://www.tradingview.com/script/wEFPvY1L-JRI-SMC-v15/
- type: indicator
- pine_id: PUB;08b731b3c6824b72b586d662f15b755d
- version: 1.0

## Description

New update YOUR SESSION SCHEDULE
Your primary window is the NY Open — 6:30am PST. This is when the highest volume hits and the cleanest moves happen. Gold (MGC/GC) and NQ are your instruments. Run your top-down analysis the night before or early morning before the open. Have your levels marked, your bias set, your zones identified. When the open hits you’re ready to execute, not still analyzing.

## Source Code

````pine
//@version=6
indicator("JRI SMC v15", shorttitle="JRI v15", overlay=true, max_boxes_count=50, max_labels_count=100, max_lines_count=100)

swingLen = input.int(10,    "Swing Length",           minval=3, maxval=50, group="Structure")
atrLen   = input.int(14,    "ATR Length",             group="Risk")
slMult   = input.float(1.5, "SL Multiplier",          group="Risk")
minScore = input.int(6,     "Min Score 1-7",          minval=1, maxval=7, group="Signals")
maxLoss  = input.int(2,     "Max Losses Before Stop", minval=1, maxval=5, group="Risk")
keyStep  = input.int(100,   "Key Level Interval",     group="Key Levels")
keyFwd   = input.int(50,    "Key Levels Fwd Bars",    group="Key Levels")
showAsia   = input.bool(true, "Show Asia",   group="Sessions")
showLondon = input.bool(true, "Show London", group="Sessions")
showNY     = input.bool(true, "Show NY",     group="Sessions")

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
boxSz   = isScalp ? size.small : size.normal

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

asiaSess   = time(timeframe.period, "2000-0400:23456", "America/New_York")
londonSess = time(timeframe.period, "0300-1200:23456", "America/New_York")
nySess     = time(timeframe.period, "0930-1600:23456", "America/New_York")
inAsia     = showAsia   and not na(asiaSess)
inLondon   = showLondon and not na(londonSess)
inNY       = showNY     and not na(nySess)
sessBg     = inNY ? color.new(color.green, 93) : inLondon ? color.new(color.blue, 93) : inAsia ? color.new(color.purple, 93) : na
bgcolor(sessBg, title="Session BG")
sessName   = inNY ? "NY" : inLondon ? "LONDON" : inAsia ? "ASIA" : "OFF"
sessClr    = inNY ? color.green : inLondon ? color.blue : inAsia ? color.purple : color.gray

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

avgBody  = ta.sma(math.abs(close - open), 20)
bigBody  = math.abs(close - open) > avgBody * 2.0
instBull = bigBody and close > open
instBear = bigBody and close < open
bgcolor(instBull ? color.new(color.lime, 93) : instBear ? color.new(color.red, 93) : na, title="Inst Candle")

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

touchDemand = inDZ() and not inDZ()[1]
touchSupply = inSZ() and not inSZ()[1]

if touchDemand
    label.new(bar_index, low,  "WATCH DEMAND", color=color.new(color.green, 40), textcolor=color.white, style=label.style_label_up,   size=size.tiny)
if touchSupply
    label.new(bar_index, high, "WATCH SUPPLY", color=color.new(color.red,   40), textcolor=color.white, style=label.style_label_down, size=size.tiny)

liqH = high > recentHigh10[1] and close < recentHigh10[1]
liqL = low  < recentLow10[1]  and close > recentLow10[1]

if liqH
    label.new(bar_index, high, "LIQ SWEEP", color=color.new(color.orange, 60), textcolor=color.orange, style=label.style_label_down, size=size.tiny)
if liqL
    label.new(bar_index, low,  "LIQ SWEEP", color=color.new(color.orange, 60), textcolor=color.orange, style=label.style_label_up,   size=size.tiny)

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

var bool inBuy       = false
var bool inSell      = false
var int  lastBuyBar  = na
var int  lastSellBar = na
var int  consLoss    = 0
var bool tradeLock   = false
cooldown = isScalp ? swingLen * 6 : swingLen * 3

bFire = bSc >= minScore and not inBuy  and not inSell and not tradeLock and (na(lastBuyBar)  or bar_index - lastBuyBar  > cooldown)
sFire = sSc >= minScore and not inSell and not inBuy  and not tradeLock and (na(lastSellBar) or bar_index - lastSellBar > cooldown)

if bFire
    inBuy       := true
    inSell      := false
    lastBuyBar  := bar_index
if sFire
    inSell      := true
    inBuy       := false
    lastSellBar := bar_index
if bSc < minScore - 1 and inBuy
    inBuy := false
if sSc < minScore - 1 and inSell
    inSell := false

var float tradeEntry  = na
var float tradeSL     = na
var float tradeT1     = na
var float tradeT2     = na
var float tradeT3     = na
var bool  tradeIsLong = false
var bool  tradeActive = false
var string tradeStatus = "FLAT"
var int   winsToday   = 0
var int   lossesToday = 0

if bFire[1] and not tradeActive
    tradeEntry  := open
    tradeSL     := open - myAtr * mySL
    tradeT1     := open + (open - tradeSL)
    tradeT2     := open + (open - tradeSL) * 2
    tradeT3     := open + (open - tradeSL) * 3
    tradeIsLong := true
    tradeActive := true
    tradeStatus := "LONG ACTIVE"

if sFire[1] and not tradeActive
    tradeEntry  := open
    tradeSL     := open + myAtr * mySL
    tradeT1     := open - (tradeSL - open)
    tradeT2     := open - (tradeSL - open) * 2
    tradeT3     := open - (tradeSL - open) * 3
    tradeIsLong := false
    tradeActive := true
    tradeStatus := "SHORT ACTIVE"

if tradeActive and tradeIsLong and low <= tradeSL
    tradeActive := false
    tradeStatus := "STOPPED OUT"
    lossesToday := lossesToday + 1
    consLoss    := consLoss + 1
    if consLoss >= maxLoss
        tradeLock := true

if tradeActive and not tradeIsLong and high >= tradeSL
    tradeActive := false
    tradeStatus := "STOPPED OUT"
    lossesToday := lossesToday + 1
    consLoss    := consLoss + 1
    if consLoss >= maxLoss
        tradeLock := true

if tradeActive and tradeIsLong and high >= tradeT3
    tradeActive := false
    tradeStatus := "T3 HIT WIN"
    winsToday   := winsToday + 1
    consLoss    := 0
    tradeLock   := false

if tradeActive and not tradeIsLong and low <= tradeT3
    tradeActive := false
    tradeStatus := "T3 HIT WIN"
    winsToday   := winsToday + 1
    consLoss    := 0
    tradeLock   := false

if dayofmonth != dayofmonth[1]
    winsToday   := 0
    lossesToday := 0
    consLoss    := 0
    tradeLock   := false

plotshape(bFire, "BUY",  shape.labelup,   location.belowbar, color.lime, size=size.small, text="BUY",  textcolor=color.black)
plotshape(sFire, "SELL", shape.labeldown, location.abovebar, color.red,  size=size.small, text="SELL", textcolor=color.white)
bgcolor(bFire ? color.new(color.lime, 85) : sFire ? color.new(color.red, 85) : na, title="Signal Bar")

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
    msg = "BUY - ENTER NEXT OPEN\nSL: " + str.tostring(sl, "#.##") + "  -" + str.tostring(math.round(rr, 1), "#.#") + " pts\n\nT1: " + str.tostring(t1, "#.##") + "  TAKE PARTIAL\nT2: " + str.tostring(t2, "#.##") + "  MOVE SL TO ENTRY\nT3: " + str.tostring(t3, "#.##") + "  FULL TP 1:3\n\nScore: " + str.tostring(bSc) + "/7"
    label.new(bar_index, low - myAtr * 0.3, msg, color=color.new(color.green, 8), textcolor=color.white, style=label.style_label_upper_right, size=boxSz, textalign=text.align_left)

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
    msg = "SELL - ENTER NEXT OPEN\nSL: " + str.tostring(sl, "#.##") + "  +" + str.tostring(math.round(rr, 1), "#.#") + " pts\n\nT1: " + str.tostring(t1, "#.##") + "  TAKE PARTIAL\nT2: " + str.tostring(t2, "#.##") + "  MOVE SL TO ENTRY\nT3: " + str.tostring(t3, "#.##") + "  FULL TP 1:3\n\nScore: " + str.tostring(sSc) + "/7"
    label.new(bar_index, high + myAtr * 0.3, msg, color=color.new(color.red, 8), textcolor=color.white, style=label.style_label_lower_right, size=boxSz, textalign=text.align_left)

var table dash = table.new(position.top_right, 2, 20, bgcolor=color.new(color.black, 10), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.gray, frame_width=1)

if barstate.islast
    totalTrades = winsToday + lossesToday
    winPct      = totalTrades > 0 ? math.round(winsToday / totalTrades * 100) : 0
    todayDate   = str.tostring(year) + "/" + str.tostring(month, "00") + "/" + str.tostring(dayofmonth, "00")
    tradeClr    = tradeActive ? (tradeIsLong ? color.lime : color.red) : color.gray
    lockClr     = tradeLock ? color.red : color.new(color.gray, 30)
    entryTxt    = tradeActive ? str.tostring(tradeEntry, "#.##") : "---"
    slTxt       = tradeActive ? str.tostring(tradeSL,    "#.##") : "---"
    t1Txt       = tradeActive ? str.tostring(tradeT1,    "#.##") : "---"

    table.cell(dash, 0, 0,  "JRI v15",         text_color=color.new(color.white, 0), text_size=size.small, bgcolor=color.new(color.navy, 10))
    table.cell(dash, 1, 0,  todayDate,          text_color=color.new(color.white, 0), text_size=size.small, bgcolor=color.new(color.navy, 10))
    table.cell(dash, 0, 1,  "SESSION",          text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 1,  sessName,           text_color=sessClr,                   text_size=size.small)
    table.cell(dash, 0, 2,  "TRADE",            text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 2,  tradeStatus,        text_color=tradeClr,                  text_size=size.small)
    table.cell(dash, 0, 3,  "ENTRY",            text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 3,  entryTxt,           text_color=color.white,               text_size=size.tiny)
    table.cell(dash, 0, 4,  "STOP LOSS",        text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 4,  slTxt,              text_color=color.red,                 text_size=size.tiny)
    table.cell(dash, 0, 5,  "NEXT TARGET",      text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 5,  t1Txt,              text_color=color.yellow,              text_size=size.tiny)
    table.cell(dash, 0, 6,  "WINS",             text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 6,  str.tostring(winsToday),   text_color=color.lime,         text_size=size.small)
    table.cell(dash, 0, 7,  "LOSSES",           text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 7,  str.tostring(lossesToday), text_color=color.red,          text_size=size.small)
    table.cell(dash, 0, 8,  "WIN RATE",         text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 8,  str.tostring(winPct) + "%", text_color=winPct >= 50 ? color.lime : color.red, text_size=size.small)
    table.cell(dash, 0, 9,  "STATUS",           text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(dash, 1, 9,  tradeLock ? "STOP TRADING" : "TRADING OK", text_color=lockClr, text_size=size.tiny)
    table.cell(dash, 0, 10, "BUY " + str.tostring(bSc) + "/7",  text_color=color.lime, text_size=size.tiny, bgcolor=color.new(color.navy, 20))
    table.cell(dash, 1, 10, "SELL " + str.tostring(sSc) + "/7", text_color=color.red,  text_size=size.tiny, bgcolor=color.new(color.navy, 20))
    table.cell(dash, 0, 11, "Bias",    text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 11, (bullBias ? "BULL" : bearBias ? "BEAR" : "NEUT"), text_color=bullBias ? color.lime : bearBias ? color.red : color.gray, text_size=size.tiny)
    table.cell(dash, 0, 12, "In Zone", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 12, (inDZ() ? "DEMAND" : inSZ() ? "SUPPLY" : "NO"), text_color=inDZ() ? color.lime : inSZ() ? color.red : color.gray, text_size=size.tiny)
    table.cell(dash, 0, 13, "BOS",     text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 13, (bosU ? "UP" : bosD ? "DOWN" : "NO"), text_color=bosU ? color.lime : bosD ? color.red : color.gray, text_size=size.tiny)
    table.cell(dash, 0, 14, "Retest",  text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 14, (retS ? "SUP" : retR ? "RES" : "NO"), text_color=retS ? color.lime : retR ? color.red : color.gray, text_size=size.tiny)
    table.cell(dash, 0, 15, "VWAP",    text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 15, (close > myVwap ? "ABOVE" : "BELOW"), text_color=close > myVwap ? color.lime : color.red, text_size=size.tiny)
    table.cell(dash, 0, 16, "EMA",     text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 16, (ema20 > ema50 ? "BULL" : "BEAR"), text_color=ema20 > ema50 ? color.lime : color.red, text_size=size.tiny)
    table.cell(dash, 0, 17, "RSI",     text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 17, (myRsi > 50 ? "BULL" : "BEAR"), text_color=myRsi > 50 ? color.lime : color.red, text_size=size.tiny)

alertcondition(bFire,       "JRI BUY",         "JRI BUY fired - enter next candle open")
alertcondition(sFire,       "JRI SELL",        "JRI SELL fired - enter next candle open")
alertcondition(touchDemand, "JRI Watch Demand","Price entered demand zone - get ready")
alertcondition(touchSupply, "JRI Watch Supply","Price entered supply zone - get ready")
alertcondition(tradeLock,   "JRI STOP TRADING","Max losses hit - step away and reset")
alertcondition(bullBias,    "JRI Bullish",     "Structure BULLISH")
alertcondition(bearBias,    "JRI Bearish",     "Structure BEARISH")
alertcondition(liqH,        "JRI Liq High",    "Liquidity sweep high")
alertcondition(liqL,        "JRI Liq Low",     "Liquidity sweep low")
````
