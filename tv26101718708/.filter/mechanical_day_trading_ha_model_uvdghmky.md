# Mechanical Day Trading : HA Model

- url: https://www.tradingview.com/script/uVdgHMKY/
- type: indicator
- pine_id: PUB;f8d292ae9f2c425893d529cdf8c58146
- version: 1.0

## Description

วิธีใช้งาน
สำคัญที่สุด — อินดิเคเตอร์วาดแท่ง Heikin Ashi ทับลงบนกราฟ ให้ไปที่ Chart settings (รูปตา/เกียร์) → ปิดแท่งเทียนจริง (Body / Borders / Wick) จะเห็นแท่ง HA สีเขียว/แดง/เทาชัดเหมือนภาพ ถ้าไม่อยากปิดก็ปิด toggle "วาดแท่ง Heikin Ashi" แล้วใช้แค่เส้น/dots/สัญญาณแทนได้
ลงตามปกติ: Pine Editor → วางโค้ด → Save → Add to chart (ใช้กับ TF เล็กอย่าง 5m ตามภาพ)
สิ่งที่จะเห็นบนกราฟ

แท่ง HA: เขียว = HA ขาขึ้น, แดง/น้ำเงิน = ขาลง, เทา = บอดี้เล็ก (ลังเล)
EMA Ribbon 8/13/21/50 + แถบ fill เปลี่ยนสีตามการเรียงตัว (เขียวเมื่อ stack ขึ้น แดงเมื่อ stack ลง)
Daily VWAP (แดง) + Secondary VWAP (ส้ม) มี label ลอยทางขวาตามภาพ
Trend dots: จุดเขียวใต้แท่งตอนขาขึ้น / จุดแดงเหนือแท่งตอนขาลง
แถบ session สีที่ขอบล่างจอ (Asia ส้ม / London ฟ้า / NY ม่วง)

ตรรกะสัญญาณ (ตรงสเปก ทุกตัวยืนยันตอนแท่งปิด ไม่ repaint)

BUY = HA เขียวแรง + ราคาเหนือ ribbon (EMA เรียง 8>21>50 และราคา>EMA8) + dot เขียว + ราคาเหนือ Daily VWAP
SELL = ตรงข้ามทุกข้อ
EXIT = ตาม exitMode (ดีฟอลต์ "Any" = dot เปลี่ยนฝั่ง หรือ HA เปลี่ยนสีสวนทาง หรือ ตัด EMA21 กลับ)
ระบบบังคับให้ ออกก่อนเข้าใหม่ เลยได้ลำดับ EXIT → BUY/SELL สวยๆ ไม่ยิงรัวทุกแท่ง

ปรับได้ใน Settings

EMA: ความยาวทั้ง 4 เส้น (EMA3 = เส้นอ้างอิง EXIT)
VWAP: เปิด/ปิดแต่ละเส้น, anchor ของ Secondary (Session/Week/Month), ใช้ VWAP กรองสัญญาณหรือไม่
Trend dots: เลือก Supertrend หรือ PSAR + ปรับ sensitivity (Supertrend = Factor/ATR, PSAR = Start/Inc/Max)
HA: % บอดี้ที่นับเป็น "เทา"
Signals: เปิด/ปิด label, เลือกเงื่อนไข EXIT
Sessions: timezone + เวลาแต่ละ session + เปิด/ปิดทีละอัน
สีทุกองค์ประกอบ (อยากได้ bearish เป็นน้ำเงินเข้มก็เปลี่ยนช่อง Bearish ได้)

Alert — Add alert → Condition "HA Model" → เลือก Buy / Sell / Exit Signal → frequency Once Per Bar Close
ข้อควรรู้

VWAP ต้องมีข้อมูล volume (EURUSD IC Markets มี tick volume ใช้ได้)
session คิดตาม timezone ที่ตั้ง (ดีฟอลต์ UTC+7 ตามภาพ) เวลา London กับ NY ดีฟอลต์ทับกันช่วง 19:30–23:00 แถบล่างช่วงนั้นจะเป็นสี NY ทับ London
เงื่อนไข BUY/SELL ค่อนข้างเข้ม (ต้อง EMA เรียงสมบูรณ์) สัญญาณเลยไม่เยอะ ถ้าอยากได้ถี่ขึ้นบอกได้ เดี๋ยวผ่อนเงื่อนไข ribbon ให้

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  Mechanical Day Trading : HA Model
//  - Heikin Ashi เป็นแกนหลัก / EMA Ribbon (8,13,21,50) / Daily + Secondary VWAP
//  - Trend dots (Supertrend หรือ PSAR) / สัญญาณ BUY-SELL-EXIT / Session boxes
//  - ไม่ repaint: state + label + alert ยืนยันด้วย barstate.isconfirmed
//  *** แนะนำ: ปิดแท่งเทียนจริงในหน้า Chart settings เพื่อให้เห็นแท่ง Heikin Ashi ชัด ***
// ════════════════════════════════════════════════════════════════════════
indicator("Mechanical Day Trading : HA Model", shorttitle="HA Model", overlay=true, max_labels_count=500)

// ═══════════════ GROUPS ═══════════════
g_ema  = "📈 EMA Ribbon"
g_vwap = "🎯 VWAP"
g_dot  = "🟢🔴 Trend Dots"
g_ha   = "🕯️ Heikin Ashi"
g_sig  = "🚦 Signals"
g_sess = "🕓 Sessions"
g_col  = "🎨 Colors"

// ═══════════════ INPUTS: EMA ═══════════════
showEMA = input.bool(true, "แสดง EMA Ribbon", group=g_ema)
len8  = input.int(8,  "EMA 1", minval=1, group=g_ema)
len13 = input.int(13, "EMA 2", minval=1, group=g_ema)
len21 = input.int(21, "EMA 3 (เส้นอ้างอิง EXIT)", minval=1, group=g_ema)
len50 = input.int(50, "EMA 4", minval=1, group=g_ema)

// ═══════════════ INPUTS: VWAP ═══════════════
showDailyVWAP    = input.bool(true,  "แสดง Daily VWAP", group=g_vwap)
showSecVWAP      = input.bool(true,  "แสดง Secondary VWAP", group=g_vwap)
secAnchor        = input.string("Week", "Secondary anchor", options=["Session", "Week", "Month"], group=g_vwap)
useVWAPInSignals = input.bool(true,  "ใช้ VWAP กรองสัญญาณ Buy/Sell", group=g_vwap)

// ═══════════════ INPUTS: TREND DOTS ═══════════════
showDots  = input.bool(true, "แสดง Trend Dots", group=g_dot)
dotMode   = input.string("Supertrend", "โหมด Trend", options=["Supertrend", "PSAR"], group=g_dot)
stFactor  = input.float(2.0,  "Supertrend Factor",     minval=0.1,   step=0.1,   group=g_dot)
stATR     = input.int(10,     "Supertrend ATR Length", minval=1,                 group=g_dot)
psarStart = input.float(0.02, "PSAR Start",            minval=0.001, step=0.001, group=g_dot)
psarInc   = input.float(0.02, "PSAR Increment",        minval=0.001, step=0.001, group=g_dot)
psarMax   = input.float(0.2,  "PSAR Max",              minval=0.01,  step=0.01,  group=g_dot)

// ═══════════════ INPUTS: HEIKIN ASHI ═══════════════
showHACandles = input.bool(true, "วาดแท่ง Heikin Ashi", group=g_ha, tooltip="แนะนำให้ปิดแท่งจริงในหน้า Chart settings (ตาเปิด/ปิด) เพื่อให้เห็นแท่ง HA ชัด")
neutralPct    = input.float(10.0, "Neutral: บอดี้ HA ≤ % ของช่วง = เทา", minval=0, maxval=50, step=1, group=g_ha)

// ═══════════════ INPUTS: SIGNALS ═══════════════
showLabels = input.bool(true, "แสดง Label BUY / SELL / EXIT", group=g_sig)
exitMode   = input.string("Any", "เงื่อนไข EXIT", options=["Any", "Trend dot flip", "HA flip", "EMA21 cross"], group=g_sig, tooltip="Any = หลุดเงื่อนไขใดเงื่อนไขหนึ่ง (dot เปลี่ยนฝั่ง / HA เปลี่ยนสี / ตัด EMA21 กลับ)")

// ═══════════════ INPUTS: SESSIONS ═══════════════
sessTz     = input.string("Asia/Bangkok", "Timezone ของ session", group=g_sess, tooltip="เช่น Asia/Bangkok (UTC+7), Asia/Tokyo, Europe/London, America/New_York")
showAsia   = input.bool(true, "Asia",     group=g_sess, inline="A")
asiaSess   = input.session("0500-1400", "", group=g_sess, inline="A")
showLondon = input.bool(true, "London",   group=g_sess, inline="L")
londonSess = input.session("1400-2300", "", group=g_sess, inline="L")
showNY     = input.bool(true, "New York", group=g_sess, inline="N")
nySess     = input.session("1930-0400", "", group=g_sess, inline="N")

// ═══════════════ INPUTS: COLORS ═══════════════
bullColor    = input.color(#26a69a, "Bullish (เขียว)",       group=g_col)
bearColor    = input.color(#ef5350, "Bearish (แดง/น้ำเงิน)", group=g_col)
neutralColor = input.color(#9e9e9e, "Neutral (เทา)",         group=g_col)
dvwapColor   = input.color(#f23645, "Daily VWAP",            group=g_col)
svwapColor   = input.color(#ff9800, "Secondary VWAP",        group=g_col)
asiaColor    = input.color(#ffb74d, "Asia box",              group=g_col)
londonColor  = input.color(#26c6da, "London box",            group=g_col)
nyColor      = input.color(#ab47bc, "New York box",          group=g_col)

// ═══════════════ HEIKIN ASHI (คำนวณเอง, ไม่ repaint) ═══════════════
haClose = (open + high + low + close) / 4
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2
haHigh = math.max(high, haOpen, haClose)
haLow  = math.min(low, haOpen, haClose)
haBody = math.abs(haClose - haOpen)
haRng  = haHigh - haLow
haBull = haClose > haOpen
haBear = haClose < haOpen
haNeutral    = haRng > 0 and haBody <= haRng * neutralPct / 100
haBullStrong = haBull and not haNeutral
haBearStrong = haBear and not haNeutral

// ═══════════════ EMA RIBBON ═══════════════
ema8  = ta.ema(close, len8)
ema13 = ta.ema(close, len13)
ema21 = ta.ema(close, len21)
ema50 = ta.ema(close, len50)
ribbonBull  = ema8 > ema21 and ema21 > ema50
ribbonBear  = ema8 < ema21 and ema21 < ema50
aboveRibbon = close > ema8 and ribbonBull
belowRibbon = close < ema8 and ribbonBear

// ═══════════════ VWAP (anchored, คำนวณเอง) ═══════════════
f_vwap(_src, _reset) =>
    var float _pv  = 0.0
    var float _vol = 0.0
    if _reset
        _pv  := 0.0
        _vol := 0.0
    _pv  += _src * nz(volume)
    _vol += nz(volume)
    _vol == 0 ? na : _pv / _vol

newDay    = timeframe.change("D")
secReset  = secAnchor == "Session" ? timeframe.change("D") : secAnchor == "Week" ? timeframe.change("W") : timeframe.change("M")
dailyVWAP = f_vwap(hlc3, newDay)
secVWAP   = f_vwap(hlc3, secReset)

// ═══════════════ TREND DOTS (Supertrend / PSAR) ═══════════════
[stLine, stDir] = ta.supertrend(stFactor, stATR)
psarVal = ta.sar(psarStart, psarInc, psarMax)
trendUp = dotMode == "Supertrend" ? (stDir < 0) : (close > psarVal)
trendDn = dotMode == "Supertrend" ? (stDir > 0) : (close < psarVal)
flipUp  = trendUp and not trendUp[1]
flipDn  = trendDn and not trendDn[1]

// ═══════════════ วาดแท่ง HEIKIN ASHI ═══════════════
bodyColor = haNeutral ? neutralColor : haBull ? bullColor : bearColor
plotcandle(showHACandles ? haOpen : na, showHACandles ? haHigh : na, showHACandles ? haLow : na, showHACandles ? haClose : na, title="Heikin Ashi", color=bodyColor, wickcolor=bodyColor, bordercolor=bodyColor)

// ═══════════════ พล็อต EMA RIBBON ═══════════════
p8  = plot(showEMA ? ema8  : na, "EMA 8",  color=color.new(#80cbc4, 0), linewidth=1)
p13 = plot(showEMA ? ema13 : na, "EMA 13", color=color.new(#4db6ac, 0), linewidth=1)
p21 = plot(showEMA ? ema21 : na, "EMA 21", color=color.new(#00897b, 0), linewidth=2)
p50 = plot(showEMA ? ema50 : na, "EMA 50", color=color.new(#607d8b, 0), linewidth=2)
ribbonFill = ribbonBull ? color.new(bullColor, 82) : ribbonBear ? color.new(bearColor, 82) : color.new(neutralColor, 88)
fill(p8, p50, color = showEMA ? ribbonFill : na, title="Ribbon Fill")

// ═══════════════ พล็อต VWAP + label ขวามือ ═══════════════
plot(showDailyVWAP ? dailyVWAP : na, "Daily VWAP",     color=color.new(dvwapColor, 0), linewidth=2)
plot(showSecVWAP   ? secVWAP   : na, "Secondary VWAP", color=color.new(svwapColor, 0), linewidth=2)

var label lblDaily = na
var label lblSec   = na
if barstate.islast
    if showDailyVWAP and not na(dailyVWAP)
        label.delete(lblDaily)
        lblDaily := label.new(bar_index + 3, dailyVWAP, "Daily VWAP", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(dvwapColor, 0), textcolor=color.white, size=size.small)
    if showSecVWAP and not na(secVWAP)
        label.delete(lblSec)
        lblSec := label.new(bar_index + 3, secVWAP, "Secondary", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(svwapColor, 0), textcolor=color.white, size=size.small)

// ═══════════════ พล็อต TREND DOTS ═══════════════
plotshape(showDots and trendUp, title="Up Dot",   style=shape.circle, location=location.belowbar, color=color.new(bullColor, 0), size=size.tiny)
plotshape(showDots and trendDn, title="Down Dot", style=shape.circle, location=location.abovebar, color=color.new(bearColor, 0), size=size.tiny)

// ═══════════════ LOGIC สัญญาณ ═══════════════
buyCond  = haBullStrong and aboveRibbon and trendUp and (not useVWAPInSignals or close > dailyVWAP)
sellCond = haBearStrong and belowRibbon and trendDn and (not useVWAPInSignals or close < dailyVWAP)

longExitRaw  = exitMode == "Trend dot flip" ? flipDn : exitMode == "HA flip" ? haBear : exitMode == "EMA21 cross" ? ta.crossunder(close, ema21) : (flipDn or haBear or ta.crossunder(close, ema21))
shortExitRaw = exitMode == "Trend dot flip" ? flipUp : exitMode == "HA flip" ? haBull : exitMode == "EMA21 cross" ? ta.crossover(close, ema21)  : (flipUp or haBull or ta.crossover(close, ema21))

var int pos = 0
buySignal  = buyCond  and pos == 0
sellSignal = sellCond and pos == 0
longExit   = pos ==  1 and longExitRaw
shortExit  = pos == -1 and shortExitRaw

confirm      = barstate.isconfirmed
sigBuy       = buySignal  and confirm
sigSell      = sellSignal and confirm
sigExitLong  = longExit   and confirm
sigExitShort = shortExit  and confirm

// ═══════════════ วาด LABEL สัญญาณ ═══════════════
if showLabels and sigBuy
    label.new(bar_index, low, "BUY", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=color.new(bullColor, 0), textcolor=color.white, size=size.normal)
if showLabels and sigSell
    label.new(bar_index, high, "SELL", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=color.new(bearColor, 0), textcolor=color.white, size=size.normal)
if showLabels and sigExitLong
    label.new(bar_index, high, "EXIT", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.gray, 0), textcolor=color.white, size=size.small)
if showLabels and sigExitShort
    label.new(bar_index, low, "EXIT", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.gray, 0), textcolor=color.white, size=size.small)

// ═══════════════ อัปเดต STATE (เฉพาะแท่งปิด → ไม่ repaint) ═══════════════
if confirm
    if longExit or shortExit
        pos := 0
    if buySignal
        pos := 1
    if sellSignal
        pos := -1

// ═══════════════ SESSION BOXES (แถบล่างจอ) ═══════════════
inAsia   = not na(time(timeframe.period, asiaSess, sessTz))
inLondon = not na(time(timeframe.period, londonSess, sessTz))
inNY     = not na(time(timeframe.period, nySess, sessTz))
plotshape(showAsia   and inAsia,   title="Asia",     style=shape.square, location=location.bottom, color=asiaColor,   size=size.tiny)
plotshape(showLondon and inLondon, title="London",   style=shape.square, location=location.bottom, color=londonColor, size=size.tiny)
plotshape(showNY     and inNY,     title="New York", style=shape.square, location=location.bottom, color=nyColor,     size=size.tiny)

// ═══════════════ ALERTS ═══════════════
alertcondition(sigBuy,  "Buy Signal",  "HA Model BUY — {{ticker}} {{interval}}")
alertcondition(sigSell, "Sell Signal", "HA Model SELL — {{ticker}} {{interval}}")
alertcondition(sigExitLong or sigExitShort, "Exit Signal", "HA Model EXIT — {{ticker}} {{interval}}")
````
