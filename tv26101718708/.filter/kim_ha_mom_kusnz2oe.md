# KIM HA MOM

- url: https://www.tradingview.com/script/KuSNZ2OE-KIM-HA-MOM/
- type: indicator
- pine_id: PUB;4158d8d6982a4ea7a36b8768beccfa68
- version: 2.0

## Description

KIM HA MOM — Main Indicator (overlay)
ระบบวิเคราะห์โครงสร้างราคาแบบครบวงจร ฟีเจอร์หลัก:

Heikin Ashi แสดงบนกราฟปกติ เปิด/ปิดได้
VWAP Daily reset UTC+7
EMA Ribbon Fast/Slow พร้อม gradient ความแข็งแรง และ highlight ส้ม/ทอง เมื่อ ROC PUSH
CHoCH & BOS ตรวจจับการเปลี่ยนโครงสร้าง พร้อม Sweep logic
CVD (Cumulative Volume Delta)
Order Block Bull/Bear อัตโนมัติ
Session Strips Asia/London/NY
ROC VWAP พร้อม Alert
Momentum Dots จุดเริ่ม ● และจบ ✕
Entry Signal พร้อมเส้นประ
Day Separator UTC+7

## Source Code

````pine
//@version=6
indicator("KIM HA MOM", shorttitle="KIM HA MOM", overlay=true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// ═══════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════
swingLen  = input.int(5,  "Swing Length",      minval=2, maxval=20)
zoneLen   = input.int(30, "Entry Zone (bars)", minval=5, maxval=200)

autoLTF  = input.bool(true,  "Auto LTF", inline="ltf", group="CVD Settings")
mltLTF   = input.int(1500,   " /",        inline="ltf", group="CVD Settings")
premLTF  = input.bool(false, "Premium",                 group="CVD Settings")

vwapCol      = input.color(color.new(#fff8dc,      0),  "VWAP Daily",  group="Colors")
chochBullCol = input.color(color.new(color.lime,   0),  "CHoCH Bull",  group="Colors")
chochBearCol = input.color(color.new(color.red,    0),  "CHoCH Bear",  group="Colors")
bosBullCol   = input.color(color.new(color.green,  40), "BOS Bull",    group="Colors")
bosBearCol   = input.color(color.new(color.red,    40), "BOS Bear",    group="Colors")
sweepCol     = input.color(color.new(color.orange,  0), "Sweep",       group="Colors")

chochLabelSize = input.string(size.small,  "CHoCH Label Size",
     options=[size.tiny, size.small, size.normal, size.large], group="Label Size")
bosLabelSize   = input.string(size.tiny,   "BOS Label Size",
     options=[size.tiny, size.small, size.normal, size.large], group="Label Size")
tableSize      = input.string(size.tiny, "Table Size",
     options=[size.tiny, size.small, size.normal, size.large], group="Dashboard")

mBars     = input.int(3, "คำนวณย้อนหลัง (แท่ง)", minval=2, maxval=20, group="Momentum")

volMult   = input.float(2.0, "Volume Spike (× avg)",   minval=1.0, step=0.1,  group="Institutional Candle")
bodyMin   = input.float(0.6, "Body Dominance (min)",   minval=0.3, step=0.05, group="Institutional Candle")
closeMin  = input.float(0.65,"Close Conviction (min)",  minval=0.3, step=0.05, group="Institutional Candle")
instCol   = input.color(color.new(color.yellow, 0), "Marker Color",           group="Institutional Candle")
instSize  = input.string(size.small, "Marker Size",
     options=[size.tiny, size.small, size.normal, size.large],                 group="Institutional Candle")
mLabelSize   = input.string(size.tiny, "Momentum Label Size",
     options=[size.tiny, size.small, size.normal, size.large], group="Momentum")
showMomOnBar = input.bool(true, "แสดงบนแท่งเทียน",                            group="Momentum")
onlyOnChange = input.bool(true, "แสดงเฉพาะเมื่อ State เปลี่ยน",              group="Momentum")
// หมายเหตุ: onlyOnChange ไม่ใช้แล้ว เหลือไว้เพื่อ backward compat

entryBodyMin  = input.float(0.5, "Entry Body Ratio (กรองหางยาว)", minval=0.1, maxval=0.9, step=0.05,
     tooltip="0.5 = body ต้องมากกว่า 50% ของ range ทั้งแท่ง ยิ่งสูงยิ่งเข้มงวด",
     group="Entry Filter")

showOB    = input.bool(true,  "แสดง Order Block",            group="Order Block")
obExtBars = input.int(40,     "ยืด OB กี่แท่ง",  minval=5, maxval=200, group="Order Block")
obMitFilt = input.bool(true,  "ซ่อน OB ที่ถูก Mitigate แล้ว", group="Order Block")
obBullCol = input.color(color.new(#00c853, 75), "OB Bull Color", group="Order Block")
obBearCol = input.color(color.new(#d50000, 75), "OB Bear Color", group="Order Block")




// ═══════════════════════════════════════════
// LTF CVD (ใช้แท่งธรรมดาเสมอ แม้กราฟเป็น HA)
// ═══════════════════════════════════════════
tfC  = timeframe.in_seconds(timeframe.period)
rs   = autoLTF ? tfC / mltLTF : timeframe.in_seconds("1")
rs  := premLTF ? rs : math.max(60, rs)
res  = timeframe.from_seconds(math.min(tfC, rs))

regularTicker = ticker.new(syminfo.prefix, syminfo.ticker)

[bArr, sArr] = request.security_lower_tf(regularTicker, res,
     [close > open ? volume : float(0),
      close < open ? volume : float(0)])

barDelta = bArr.sum() - sArr.sum()

// Heikin Ashi ticker (ใช้ทั้ง Swing Detection และ plotcandle)
haTicker = ticker.heikinashi(syminfo.tickerid)


// ═══════════════════════════════════════════
// VWAP Daily
// ═══════════════════════════════════════════
isNewDay  = ta.change(time("D", "UTC+7")) != 0
cumTPV_r  = 0.0
cumVol_r  = 0.0
cumTPV_r := isNewDay ? ohlc4 * volume : cumTPV_r[1] + ohlc4 * volume
cumVol_r := isNewDay ? volume         : cumVol_r[1] + volume
vwapD     = cumTPV_r / cumVol_r

plot(vwapD, "VWAP Daily", color=vwapCol, linewidth=2, display=display.all - display.price_scale - display.status_line)


// ═══════════════════════════════════════════
// CVD Daily
// ═══════════════════════════════════════════
var float cvdDaily = 0.0
if isNewDay
    cvdDaily := 0.0
cvdDaily += barDelta

aboveVwap = close > vwapD


atr14    = ta.atr(14)
avgVol20 = ta.sma(volume, 20)

// ═══════════════════════════════════════════
// Swing Detection — ใช้ HA 5m เสมอ (ดึงจาก haTicker)
// ═══════════════════════════════════════════
haHigh5 = request.security(haTicker, "5", math.max(high, math.max(open, close)))
haLow5  = request.security(haTicker, "5", math.min(low,  math.min(open, close)))

swingH = ta.pivothigh(haHigh5, swingLen, swingLen)
swingL = ta.pivotlow (haLow5,  swingLen, swingLen)

var float lastSH     = na
var int   lastSH_bar = na
var float lastSL     = na
var int   lastSL_bar = na

if not na(swingH)
    lastSH     := swingH
    lastSH_bar := bar_index[swingLen]
if not na(swingL)
    lastSL     := swingL
    lastSL_bar := bar_index[swingLen]

// ═══════════════════════════════════════════
// Liquidity Sweep
// ═══════════════════════════════════════════
var bool  hadSweepH   = false
var bool  hadSweepL   = false
var float sweptLowPx  = na
var float sweptHighPx = na

sweepH = not na(lastSH) and high > lastSH and close < lastSH
sweepL = not na(lastSL) and low  < lastSL and close > lastSL

if sweepH
    hadSweepH   := true
    sweptHighPx := lastSH
if sweepL
    hadSweepL  := true
    sweptLowPx := lastSL



// ═══════════════════════════════════════════
// CHoCH + BOS
// ═══════════════════════════════════════════
chochBull = hadSweepL and not na(lastSH) and close > lastSH and close[1] <= lastSH
chochBear = hadSweepH and not na(lastSL) and close < lastSL and close[1] >= lastSL
bosBull   = not hadSweepL and not na(lastSH) and close > lastSH and close[1] <= lastSH
bosBear   = not hadSweepH and not na(lastSL) and close < lastSL and close[1] >= lastSL

// Discount/Premium = ราคา pullback กลับมาใต้/เหนือ CHoCH level
var float chochLevelBull = na  // ราคา <= chochLevelBull = Discount → Entry Long
var float chochLevelBear = na  // ราคา >= chochLevelBear = Premium  → Entry Short
// ยังคง midpoint ไว้เพื่อ reset logic
var float midpointBull = na
var float midpointBear = na

if chochBull
    midCB = math.round((lastSH_bar + bar_index) / 2)
    line.new(lastSH_bar, lastSH, bar_index, lastSH,
         color=chochBullCol, width=2, style=line.style_solid)
    label.new(midCB, lastSH, "CHoCH ▲",
         style=label.style_label_down,
         color=color.new(color.black, 100), textcolor=chochBullCol, size=chochLabelSize)
    box.new(bar_index, math.max(open, close), bar_index + zoneLen, math.min(open, close),
         bgcolor=color.new(chochBullCol, 88), border_color=color.new(chochBullCol, 50), border_width=1)
    chochLevelBull := lastSH
    hadSweepL := false
    hadSweepH := true   // CHoCH Bull = ถือว่ามี sweep High แล้ว พร้อมให้ CHoCH Bear ถัดไป
    lastSH    := na

if chochBear
    midCBr = math.round((lastSL_bar + bar_index) / 2)
    line.new(lastSL_bar, lastSL, bar_index, lastSL,
         color=chochBearCol, width=2, style=line.style_solid)
    label.new(midCBr, lastSL, "CHoCH ▼",
         style=label.style_label_up,
         color=color.new(color.black, 100), textcolor=chochBearCol, size=chochLabelSize)
    box.new(bar_index, math.max(open, close), bar_index + zoneLen, math.min(open, close),
         bgcolor=color.new(chochBearCol, 88), border_color=color.new(chochBearCol, 50), border_width=1)
    chochLevelBear := lastSL
    hadSweepH := false
    hadSweepL := true   // CHoCH Bear = ถือว่ามี sweep Low แล้ว พร้อมให้ CHoCH Bull ถัดไป
    lastSL    := na

if bosBull
    midBB = math.round((lastSH_bar + bar_index) / 2)
    line.new(lastSH_bar, lastSH, bar_index, lastSH,
         color=bosBullCol, width=1, style=line.style_dashed)
    label.new(midBB, lastSH, "BOS ▲",
         style=label.style_label_down,
         color=color.new(color.black, 100), textcolor=bosBullCol, size=bosLabelSize)
    lastSH := na

if bosBear
    midBBr = math.round((lastSL_bar + bar_index) / 2)
    line.new(lastSL_bar, lastSL, bar_index, lastSL,
         color=bosBearCol, width=1, style=line.style_dashed)
    label.new(midBBr, lastSL, "BOS ▼",
         style=label.style_label_up,
         color=color.new(color.black, 100), textcolor=bosBearCol, size=bosLabelSize)
    lastSL := na

// ═══════════════════════════════════════════
// INSTITUTIONAL CANDLE DETECTOR
// ═══════════════════════════════════════════
instBody    = math.abs(close - open)
instRange   = high - low
instBodyR   = instRange > 0 ? instBody / instRange : 0.0
instCloseP  = instRange > 0 ? (close >= open ? (close - low) / instRange : (high - close) / instRange) : 0.0
instVolOk   = avgVol20 > 0 and volume >= avgVol20 * volMult
instBodyOk  = instBodyR >= bodyMin
instCloseOk = instCloseP >= closeMin
deltaRatio  = volume > 0 ? math.abs(barDelta) / volume : 0.0
highDelta   = deltaRatio >= 0.8 and instVolOk
isInstCandle = (instVolOk and instBodyOk and instCloseOk) or highDelta

// ═══════════════════════════════════════════
// MOMENTUM STATE
// ═══════════════════════════════════════════
candleScore(o, h, l, c) =>
    rng   = h - l
    body  = math.abs(c - o)
    bodyR = rng > 0 ? body / rng : 0.0
    dir   = c >= o ? 1.0 : -1.0
    closeP = rng > 0 ? (c >= o ? (c - l) / rng : (h - c) / rng) : 0.5
    dir * bodyR * closeP

totalScore = 0.0
for i = 0 to mBars - 1
    totalScore += candleScore(open[i], high[i], low[i], close[i])
normScore = totalScore / mBars

strongBull = normScore >=  0.40
bull       = normScore >=  0.13 and normScore <  0.40
sideways   = math.abs(normScore) <  0.13
bear       = normScore <= -0.13 and normScore > -0.40
strongBear = normScore <= -0.40

momentumStr = strongBull ? "Strong Bull 🔥" : bull ? "Bull ▲" : sideways ? "Sideways ◆" : bear ? "Bear ▼" : "Strong Bear 🧊"
momentumCol = strongBull ? color.new(color.lime, 0)   : bull ? color.new(color.green, 0) : sideways ? color.silver : bear ? color.new(color.red, 0) : color.new(color.maroon, 0)
momentumBg  = strongBull ? color.new(color.green, 65) : bull ? color.new(color.green, 80) : sideways ? color.new(color.gray, 75) : bear ? color.new(color.red, 80) : color.new(color.maroon, 65)

// ═══════════════════════════════════════════
// CANDLE STRENGTH SCORE (0–100)
// ═══════════════════════════════════════════
body0  = math.abs(close - open)
rng0   = high - low
s1_raw = atr14    > 0 ? body0  / atr14    : 0.0
s2_raw = rng0     > 0 ? (close >= open ? (close - low) / rng0 : (high - close) / rng0) : 0.5
s3_raw = avgVol20 > 0 ? volume / avgVol20 : 1.0
s1 = math.min(s1_raw / 2.0, 1.0)
s2 = math.min(s2_raw,       1.0)
s3 = math.min(s3_raw / 3.0, 1.0)
strengthScore = s1 * 40 + s2 * 30 + s3 * 30
strengthPrev  = ta.valuewhen(true, strengthScore, 1)
strongerNow   = strengthScore > strengthPrev
weakerNow     = strengthScore < strengthPrev
strengthLabel = "Str: " + str.tostring(math.round(strengthScore)) + (strongerNow ? " ↑" : weakerNow ? " ↓" : " →")
strengthCol   = strengthScore >= 70 ? color.new(color.lime, 0) : strengthScore >= 40 ? color.new(color.yellow, 0) : color.new(color.red, 0)


// ═══════════════════════════════════════════
// SESSION CVD (UTC+7)
// Asia   : 07:00–16:00
// London : 14:00–23:00
// NY     : 19:00–04:00
// ═══════════════════════════════════════════
isAsia   = not na(time(timeframe.period, "0700-1600", "UTC+7"))
isLondon = not na(time(timeframe.period, "1400-2300", "UTC+7"))
isNY     = not na(time(timeframe.period, "1900-0400", "UTC+7"))

asiaStart   = isAsia   and not isAsia[1]
londonStart = isLondon and not isLondon[1]
nyStart     = isNY     and not isNY[1]

var float cvdAsia   = 0.0
var float cvdLondon = 0.0
var float cvdNY     = 0.0

if isNewDay
    cvdAsia   := 0.0
    cvdLondon := 0.0
    cvdNY     := 0.0

if asiaStart
    cvdAsia := 0.0
if isAsia
    cvdAsia += barDelta
if londonStart
    cvdLondon := 0.0
if isLondon
    cvdLondon += barDelta
if nyStart
    cvdNY := 0.0
if isNY
    cvdNY += barDelta

// CVD session ที่ active อยู่ขณะนี้ (NY มีความสำคัญสูงสุด)
cvdSession = isNY ? cvdNY : isLondon ? cvdLondon : isAsia ? cvdAsia : float(na)

biasBull = aboveVwap
biasBear = not aboveVwap

// ═══════════════════════════════════════════
// Dashboard
// ═══════════════════════════════════════════
var table dash = table.new(position.top_right, 3, 6,
     bgcolor=color.new(color.black, 15), border_color=color.new(color.gray, 60),
     border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)

sessionBiasStr(cvdVal, abvVwap) =>
    lng  = abvVwap and cvdVal > 0
    shrt = not abvVwap and cvdVal < 0
    lng ? "▲ LONG" : shrt ? "▼ SHORT" : "◆ NEU"

sessionBiasCol(cvdVal, abvVwap) =>
    lng  = abvVwap and cvdVal > 0
    shrt = not abvVwap and cvdVal < 0
    lng ? color.new(color.lime, 0) : shrt ? color.new(color.red, 0) : color.silver

sessionBiasBg(cvdVal, abvVwap) =>
    lng  = abvVwap and cvdVal > 0
    shrt = not abvVwap and cvdVal < 0
    lng ? color.new(color.green, 70) : shrt ? color.new(color.red, 70) : color.new(color.gray, 70)

if barstate.islast
    biasStr = biasBull ? "▲ BULLISH" : biasBear ? "▼ BEARISH" : "◆ NEUTRAL"
    biasCol = biasBull ? color.new(color.lime, 0) : biasBear ? color.new(color.red, 0) : color.silver
    biasBg  = biasBull ? color.new(color.green, 70) : biasBear ? color.new(color.red, 70) : color.new(color.gray, 70)
    table.cell(dash, 0, 0, "Bias",   text_color=color.silver, text_size=tableSize, bgcolor=color.new(color.black, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, biasStr,  text_color=biasCol,      text_size=tableSize, bgcolor=biasBg,                    text_halign=text.align_center)
    table.cell(dash, 2, 0, "",       text_size=tableSize, bgcolor=color.new(color.black, 0))

    vStr = aboveVwap ? "เหนือ ▲" : "ใต้ ▼"
    vCol = aboveVwap ? color.new(color.lime, 0) : color.new(color.red, 0)
    vBg  = aboveVwap ? color.new(color.green, 80) : color.new(color.red, 80)
    table.cell(dash, 0, 1, "VWAP D", text_color=color.silver, text_size=tableSize, bgcolor=color.new(color.gray, 85), text_halign=text.align_left)
    table.cell(dash, 1, 1, vStr,      text_color=vCol,         text_size=tableSize, bgcolor=vBg,                       text_halign=text.align_center)
    table.cell(dash, 2, 1, "",        text_size=tableSize, bgcolor=color.new(color.gray, 85))

    cvdVal = cvdDaily >= 0 ? "+" + str.tostring(cvdDaily, format.volume) : str.tostring(cvdDaily, format.volume)
    cCol   = cvdDaily >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
    cBg    = cvdDaily >= 0 ? color.new(color.green, 80) : color.new(color.red, 80)
    table.cell(dash, 0, 2, "CVD Daily", text_color=color.silver, text_size=tableSize, bgcolor=color.new(color.gray, 85), text_halign=text.align_left)
    table.cell(dash, 1, 2, cvdVal,       text_color=cCol,         text_size=tableSize, bgcolor=cBg,                       text_halign=text.align_right)
    table.cell(dash, 2, 2, "",           text_size=tableSize, bgcolor=color.new(color.gray, 85))

    aVal     = cvdAsia >= 0 ? "+" + str.tostring(cvdAsia, format.volume) : str.tostring(cvdAsia, format.volume)
    aActive  = isAsia ? " ●" : ""
    aCol     = cvdAsia >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
    aBg      = cvdAsia >= 0 ? color.new(color.green, 80) : color.new(color.red, 80)
    table.cell(dash, 0, 3, "Asia 07-16" + aActive, text_color=color.silver, text_size=tableSize, bgcolor=color.new(color.gray, 85), text_halign=text.align_left)
    table.cell(dash, 1, 3, aVal,                    text_color=aCol,         text_size=tableSize, bgcolor=aBg,                       text_halign=text.align_right)
    table.cell(dash, 2, 3, sessionBiasStr(cvdAsia, aboveVwap), text_color=sessionBiasCol(cvdAsia, aboveVwap), text_size=tableSize, bgcolor=sessionBiasBg(cvdAsia, aboveVwap), text_halign=text.align_center)

    lVal     = cvdLondon >= 0 ? "+" + str.tostring(cvdLondon, format.volume) : str.tostring(cvdLondon, format.volume)
    lActive  = isLondon ? " ●" : ""
    lCol     = cvdLondon >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
    lBg      = cvdLondon >= 0 ? color.new(color.green, 80) : color.new(color.red, 80)
    table.cell(dash, 0, 4, "London 14-23" + lActive, text_color=color.silver, text_size=tableSize, bgcolor=color.new(color.gray, 85), text_halign=text.align_left)
    table.cell(dash, 1, 4, lVal,                      text_color=lCol,         text_size=tableSize, bgcolor=lBg,                       text_halign=text.align_right)
    table.cell(dash, 2, 4, sessionBiasStr(cvdLondon, aboveVwap), text_color=sessionBiasCol(cvdLondon, aboveVwap), text_size=tableSize, bgcolor=sessionBiasBg(cvdLondon, aboveVwap), text_halign=text.align_center)

    nVal     = cvdNY >= 0 ? "+" + str.tostring(cvdNY, format.volume) : str.tostring(cvdNY, format.volume)
    nActive  = isNY ? " ●" : ""
    nCol     = cvdNY >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
    nBg      = cvdNY >= 0 ? color.new(color.green, 80) : color.new(color.red, 80)
    table.cell(dash, 0, 5, "NY 19-04" + nActive, text_color=color.silver, text_size=tableSize, bgcolor=color.new(color.gray, 85), text_halign=text.align_left)
    table.cell(dash, 1, 5, nVal,                   text_color=nCol,         text_size=tableSize, bgcolor=nBg,                       text_halign=text.align_right)
    table.cell(dash, 2, 5, sessionBiasStr(cvdNY, aboveVwap), text_color=sessionBiasCol(cvdNY, aboveVwap), text_size=tableSize, bgcolor=sessionBiasBg(cvdNY, aboveVwap), text_halign=text.align_center)

// ═══════════════════════════════════════════
// ROC of VWAP Daily
// ═══════════════════════════════════════════
rocLen      = input.int(9,     "ROC Length",     minval=1,    group="ROC VWAP")
rocLevel1   = input.float(0.08, "ROC Level 1 ±", minval=0.01, step=0.01, group="ROC VWAP")
rocLevel2   = input.float(0.20, "ROC Level 2 ±", minval=0.01, step=0.01, group="ROC VWAP")

rocVwap    = 100 * (vwapD - vwapD[rocLen]) / vwapD[rocLen]

// ซ่อน rocLen แท่งแรกของวัน เพราะ VWAP reset ทำให้ค่ากระโดด
barsFromDay = ta.barssince(isNewDay)
rocValid    = barsFromDay >= rocLen

rocCrossUp1   = rocValid and ta.crossover (rocVwap,  rocLevel1)
rocCrossDown1 = rocValid and ta.crossunder(rocVwap, -rocLevel1)
rocCrossUp2   = rocValid and ta.crossover (rocVwap,  rocLevel2)
rocCrossDown2 = rocValid and ta.crossunder(rocVwap, -rocLevel2)

if rocCrossUp1
    label.new(bar_index, low - atr14 * 1.2,
         text="P↑\n▲", style=label.style_label_up,
         color=color.new(color.black, 100), textcolor=color.lime, size=size.small)
if rocCrossDown1
    label.new(bar_index, high + atr14 * 1.2,
         text="▼\nP↓", style=label.style_label_down,
         color=color.new(color.black, 100), textcolor=color.red, size=size.small)

if rocCrossUp2
    label.new(bar_index, low - atr14 * 1.8,
         text="P↑↑\n▲", style=label.style_label_up,
         color=color.new(color.black, 100), textcolor=color.aqua, size=size.normal)
if rocCrossDown2
    label.new(bar_index, high + atr14 * 1.8,
         text="▼\nP↓↓", style=label.style_label_down,
         color=color.new(color.black, 100), textcolor=color.orange, size=size.normal)

alertcondition(rocCrossUp1,   title="ROC VWAP Cross +0.08",  message="{{ticker}} ROC VWAP ↑ ข้าม +L1")
alertcondition(rocCrossDown1, title="ROC VWAP Cross -0.08",  message="{{ticker}} ROC VWAP ↓ ข้าม -L1")
alertcondition(rocCrossUp2,   title="ROC VWAP Cross +0.20",  message="{{ticker}} ROC VWAP ↑↑ ข้าม +L2")
alertcondition(rocCrossDown2, title="ROC VWAP Cross -0.20",  message="{{ticker}} ROC VWAP ↓↓ ข้าม -L2")

// ═══════════════════════════════════════════
// SESSION STRIPS (bottom of chart, UTC+7)
// ═══════════════════════════════════════════
showStrips  = input.bool(true, "แสดง Session Strip",  group="Session Strip")
colAsia     = input.color(color.new(#6e6e80, 20),  "Asia Color",   group="Session Strip")
colLondon   = input.color(color.new(#d8d8d8, 20),  "London Color", group="Session Strip")
colNY       = input.color(color.new(#e06a5a, 40),  "NY Color",     group="Session Strip")

bool tf_ok = timeframe.in_seconds() <= 3600

f_in(sess, tz) => not na(time(timeframe.period, sess, tz)) ? 1 : 0
f_st(sess, tz) =>
    inS = not na(time(timeframe.period, sess, tz))
    inS and not inS[1]

plotshape(showStrips and tf_ok and f_in("0700-1600", "UTC+7") != 0,
     style=shape.square, location=location.bottom,
     color=colAsia, size=size.tiny, title="Asia Strip")
plotshape(showStrips and tf_ok and f_st("0700-1600", "UTC+7"),
     style=shape.square, location=location.bottom,
     color=color.new(colAsia, 100), size=size.tiny,
     text="Asia", textcolor=colAsia, title="Asia Label")

plotshape(showStrips and tf_ok and f_in("1400-2300", "UTC+7") != 0,
     style=shape.square, location=location.bottom,
     color=colLondon, size=size.tiny, title="London Strip")
plotshape(showStrips and tf_ok and f_st("1400-2300", "UTC+7"),
     style=shape.square, location=location.bottom,
     color=color.new(colLondon, 100), size=size.tiny,
     text="London", textcolor=colLondon, title="London Label")

plotshape(showStrips and tf_ok and f_in("1900-0400", "UTC+7") != 0,
     style=shape.square, location=location.bottom,
     color=colNY, size=size.tiny, title="NY Strip")
plotshape(showStrips and tf_ok and f_st("1900-0400", "UTC+7"),
     style=shape.square, location=location.bottom,
     color=color.new(colNY, 100), size=size.tiny,
     text="NY", textcolor=colNY, title="NY Label")

// ═══════════════════════════════════════════
// HEIKIN ASHI (วาดบนกราฟ ไม่ต้องเปลี่ยน chart type)
// ═══════════════════════════════════════════
showHA   = input.bool(true, "แสดงแท่ง Heikin Ashi", group="Heikin Ashi")
haBullCol = input.color(color.new(color.white, 0), "HA Bull",  group="Heikin Ashi")
haBearCol = input.color(color.new(color.red,  0),  "HA Bear",  group="Heikin Ashi")

[haO, haH, haL, haC] = request.security(haTicker, timeframe.period, [open, high, low, close])

plotcandle(showHA ? haO : na, showHA ? haH : na, showHA ? haL : na, showHA ? haC : na,
     title="HA Candle",
     color      = haC >= haO ? haBullCol : haBearCol,
     wickcolor  = haC >= haO ? haBullCol : haBearCol,
     bordercolor= haC >= haO ? haBullCol : haBearCol)

// ═══════════════════════════════════════════
// PULLBACK ENTRY
// ═══════════════════════════════════════════
showEntry = input.bool(true, "แสดงป้าย Entry", group="Entry Signal")
haGreen = haC > haO
haRed   = haC < haO


var bool chochBullWaiting = false
var bool pullbackBullSeen = false
var bool chochBearWaiting = false
var bool pullbackBearSeen = false
var int  chochBullBar     = na
var int  chochBearBar     = na

pullbackMaxBars = 6


triggerBull = (chochBull or bosBull) and biasBull
triggerBear = (chochBear or bosBear) and biasBear

// ยกเลิกฝั่งตรงข้ามทันทีที่เกิด CHoCH/BOS ไม่ว่า Bias จะเป็นอะไร
if chochBull or bosBull
    chochBearWaiting := false
    pullbackBearSeen := false
    chochLevelBear   := na

if chochBear or bosBear
    chochBullWaiting := false
    pullbackBullSeen := false
    chochLevelBull   := na

if triggerBull
    chochBullWaiting := true
    pullbackBullSeen := false
    chochBullBar     := bar_index

if triggerBear
    chochBearWaiting := true
    pullbackBearSeen := false
    chochBearBar     := bar_index

// reset ถ้าไม่เกิด Pullback ภายใน 6 แท่งหลัง CHoCH
if chochBullWaiting and not pullbackBullSeen and not na(chochBullBar) and (bar_index - chochBullBar) > pullbackMaxBars
    chochBullWaiting := false
    chochLevelBull   := na
if chochBearWaiting and not pullbackBearSeen and not na(chochBearBar) and (bar_index - chochBearBar) > pullbackMaxBars
    chochBearWaiting := false
    chochLevelBear   := na

// reset ถ้าเกิน 20 แท่งหลัง CHoCH แล้วยังไม่มี Entry
if chochBullWaiting and not na(chochBullBar) and (bar_index - chochBullBar) > 20
    chochBullWaiting := false
    pullbackBullSeen := false
    chochLevelBull   := na
if chochBearWaiting and not na(chochBearBar) and (bar_index - chochBearBar) > 20
    chochBearWaiting := false
    pullbackBearSeen := false
    chochLevelBear   := na

if chochBullWaiting and haRed
    pullbackBullSeen := true
if chochBearWaiting and haGreen
    pullbackBearSeen := true

cvdRising  = not na(cvdSession) and cvdSession > cvdSession[1]
cvdFalling = not na(cvdSession) and cvdSession < cvdSession[1]

entryRange   = high - low
entryBody    = math.abs(close - open)
strongCandle = entryRange > 0 ? (entryBody / entryRange) >= entryBodyMin : false

entryLong  = chochBullWaiting and pullbackBullSeen and haGreen and biasBull and cvdRising and strongCandle
entryShort = chochBearWaiting and pullbackBearSeen and haRed   and biasBear and cvdFalling and strongCandle

if entryLong
    chochBullWaiting := false
    pullbackBullSeen := false
    chochLevelBull   := na
    if showEntry
        line.new(bar_index, low, bar_index, low - atr14 * 5,
             color=color.new(color.lime, 40), style=line.style_dashed, width=1)

if entryShort
    chochBearWaiting := false
    pullbackBearSeen := false
    chochLevelBear   := na
    if showEntry
        line.new(bar_index, high, bar_index, high + atr14 * 5,
             color=color.new(color.red, 40), style=line.style_dashed, width=1)

plotshape(showEntry and entryLong,  style=shape.triangleup,   location=location.bottom,
     color=color.new(color.lime, 0), size=size.small,
     text="▲ Entry", textcolor=color.lime, title="Entry Long")
plotshape(showEntry and entryShort, style=shape.triangledown, location=location.bottom,
     color=color.new(color.red, 0),  size=size.small,
     text="▼ Entry", textcolor=color.red,  title="Entry Short")


// ═══════════════════════════════════════════
// ORDER BLOCK
// OB Bull = แท่งแดงสุดท้ายก่อน impulse ที่ทำให้เกิด CHoCH Bull
// OB Bear = แท่งเขียวสุดท้ายก่อน impulse ที่ทำให้เกิด CHoCH Bear
// ═══════════════════════════════════════════
var box   obBullBox  = na
var float obBullHigh = na
var float obBullLow  = na
var int   obBullLeft = na

var box   obBearBox  = na
var float obBearHigh = na
var float obBearLow  = na
var int   obBearLeft = na

if (chochBull or bosBull) and showOB
    // หา last red candle (regular) ก่อน CHoCH ย้อนหลัง 20 แท่ง
    foundBullOB = false
    for i = 1 to 20
        if not foundBullOB and close[i] < open[i]
            obBullHigh := high[i]
            obBullLow  := low[i]
            obBullLeft := bar_index - i
            foundBullOB := true
    if foundBullOB
        box.delete(obBullBox)
        obBullBox := box.new(obBullLeft, obBullHigh, bar_index + obExtBars, obBullLow,
             bgcolor=obBullCol,
             border_color=color.new(#00c853, 30), border_width=1,
             text="OB Bull", text_color=color.new(#00c853, 0),
             text_halign=text.align_right, text_valign=text.align_top, text_size=size.tiny)

if (chochBear or bosBear) and showOB
    // หา last green candle (regular) ก่อน CHoCH ย้อนหลัง 20 แท่ง
    foundBearOB = false
    for i = 1 to 20
        if not foundBearOB and close[i] > open[i]
            obBearHigh := high[i]
            obBearLow  := low[i]
            obBearLeft := bar_index - i
            foundBearOB := true
    if foundBearOB
        box.delete(obBearBox)
        obBearBox := box.new(obBearLeft, obBearHigh, bar_index + obExtBars, obBearLow,
             bgcolor=obBearCol,
             border_color=color.new(#d50000, 30), border_width=1,
             text="OB Bear", text_color=color.new(#d50000, 0),
             text_halign=text.align_right, text_valign=text.align_top, text_size=size.tiny)

// Mitigation: ซ่อน OB เมื่อราคาปิดผ่านไปฝั่งตรงข้าม
if obMitFilt and showOB
    if not na(obBullBox) and close < obBullLow
        box.delete(obBullBox)
        obBullBox  := na
        obBullHigh := na
        obBullLow  := na
    if not na(obBearBox) and close > obBearHigh
        box.delete(obBearBox)
        obBearBox  := na
        obBearHigh := na
        obBearLow  := na

// ยืด OB box ไปข้างหน้าทุก bar (ถ้า box ยังอยู่)
if showOB and barstate.islast
    if not na(obBullBox)
        box.set_right(obBullBox, bar_index + obExtBars)
    if not na(obBearBox)
        box.set_right(obBearBox, bar_index + obExtBars)

// ═══════════════════════════════════════════
// EMA Ribbon — Momentum Strength
// ═══════════════════════════════════════════
emaFastLen = input.int(9,  "EMA Fast", minval=1, group="EMA Ribbon")
emaSlowLen = input.int(21, "EMA Slow", minval=1, group="EMA Ribbon")
emaFastCol  = input.color(color.new(#00bcd4, 100),   "EMA Fast Color",  group="EMA Ribbon")
emaSlowCol  = input.color(color.new(#ff5722, 100),   "EMA Slow Color",  group="EMA Ribbon")
emaBullFill = input.color(color.new(color.lime, 70), "Fill Bull Color", group="EMA Ribbon")
emaBearFill = input.color(color.new(color.red,  70), "Fill Bear Color", group="EMA Ribbon")

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// วัดความแข็งแรงจาก spread เทียบ ATR
emaSpread      = math.abs(emaFast - emaSlow)
spreadRatio    = atr14 > 0 ? emaSpread / atr14 : 0.0
// gradient ต่อเนื่อง: ยิ่งห่าง (ratio สูง) ยิ่งจาง
spreadTransp = int(math.min(math.max(30 + spreadRatio * 40, 30), 75))

bullFillDyn = color.new(color.lime, spreadTransp)
bearFillDyn = color.new(color.red,  spreadTransp)

// ROC PUSH highlight ±1 แท่ง รอบสัญญาณ
pushBull = rocCrossUp1   or rocCrossUp1[1]   or rocCrossUp1[2]
pushBear = rocCrossDown1 or rocCrossDown1[1] or rocCrossDown1[2]

var color ribbonCol  = color.new(color.lime, 30)
var color emaEdgeCol = color.new(color.white, 80)
if pushBear
    ribbonCol  := color.new(color.orange, 0)
    emaEdgeCol := color.new(color.white, 60)
else if pushBull
    ribbonCol  := color.new(color.yellow, 0)
    emaEdgeCol := color.new(color.white, 60)
else if emaFast > emaSlow
    ribbonCol  := bullFillDyn
    emaEdgeCol := color.new(color.white, 90)
else
    ribbonCol  := bearFillDyn
    emaEdgeCol := color.new(color.white, 90)

emaFastPlot = plot(emaFast, "EMA Fast", color=emaFastCol, linewidth=2,
     display=display.all - display.price_scale - display.status_line)
emaSlowPlot = plot(emaSlow, "EMA Slow", color=emaSlowCol, linewidth=2,
     display=display.all - display.price_scale - display.status_line)

fill(emaFastPlot, emaSlowPlot, color=ribbonCol, title="EMA Ribbon Fill")

// จุดเริ่มต้น / จบ Momentum
momThreshold  = input.float(0.3, "Mom Start Threshold (× ATR)", minval=0.1, step=0.05, group="EMA Ribbon")
momEndThresh  = input.float(0.1, "Mom End Threshold (× ATR)",   minval=0.01, step=0.01, group="EMA Ribbon")
momStart      = ta.crossover(spreadRatio, momThreshold)
momEnd        = ta.crossunder(spreadRatio, momEndThresh)
momStartBull  = momStart and emaFast > emaSlow
momStartBear  = momStart and emaFast < emaSlow

var bool momActiveBull = false
var bool momActiveBear = false

if momStartBull
    momActiveBull := true
    momActiveBear := false
    label.new(bar_index, haL - atr14 * 0.5,
         text="●", style=label.style_none,
         textcolor=color.new(color.lime, 0), size=size.normal)
if momStartBear
    momActiveBear := true
    momActiveBull := false
    label.new(bar_index, haH + atr14 * 0.1,
         text="●", style=label.style_none,
         textcolor=color.new(color.red, 0), size=size.normal)
if momEnd and momActiveBull
    momActiveBull := false
    label.new(bar_index, haL - atr14 * 0.5,
         text="✕", style=label.style_none,
         textcolor=color.new(color.lime, 0), size=size.normal)
if momEnd and momActiveBear
    momActiveBear := false
    label.new(bar_index, haH + atr14 * 0.1,
         text="✕", style=label.style_none,
         textcolor=color.new(color.red, 0), size=size.normal)

// ═══════════════════════════════════════════
// Day Separator
// ═══════════════════════════════════════════
showDaySep = input.bool(true, "แสดงเส้นแบ่งวัน", group="Day Separator")
daySepCol  = input.color(color.new(color.white, 20), "สีเส้นแบ่งวัน", group="Day Separator")

if showDaySep and isNewDay
    line.new(bar_index, low  - atr14 * 5,
             bar_index, high + atr14 * 5,
             color=daySepCol, style=line.style_dashed, width=1, extend=extend.both)

// ═══════════════════════════════════════════
// Alerts
// ═══════════════════════════════════════════
alertcondition(chochBull,              title="CHoCH Bullish",     message="{{ticker}} CHoCH ▲\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(chochBear,              title="CHoCH Bearish",     message="{{ticker}} CHoCH ▼\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(chochBull and biasBull, title="High Quality Bull", message="{{ticker}} ✓ CHoCH ▲ + Bias Bullish\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(chochBear and biasBear, title="High Quality Bear", message="{{ticker}} ✓ CHoCH ▼ + Bias Bearish\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(sweepL and biasBull,    title="Bull Sweep + Bias", message="{{ticker}} ⚡ Sweep Low + Bullish Bias\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(sweepH and biasBear,    title="Bear Sweep + Bias", message="{{ticker}} ⚡ Sweep High + Bearish Bias\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(strongBull,             title="Strong Bull",       message="{{ticker}} 🔥 Strong Bull Momentum\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(strongBear,             title="Strong Bear",       message="{{ticker}} 🧊 Strong Bear Momentum\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(isInstCandle,           title="Institutional Candle", message="{{ticker}} ★ Institutional Candle\nราคา: {{close}}\nเวลา: {{time}}")
alertcondition(entryLong,              title="▲ Entry Long  (CHoCH+Pullback)", message="{{ticker}} ▲ Entry Long\nBias Bullish + CHoCH + HA Pullback Resume\nราคา: {{close}}\นเวลา: {{time}}")
alertcondition(entryShort,             title="▼ Entry Short (CHoCH+Pullback)", message="{{ticker}} ▼ Entry Short\nBias Bearish + CHoCH + HA Pullback Resume\nราคา: {{close}}\nเวลา: {{time}}")
````
