# TELAY Algo Alpha

- url: https://www.tradingview.com/script/cgHZxED6-TELAY-Algo-Alpha/
- type: indicator
- pine_id: PUB;13d4d60c9ebc483d818a7ce150a025d4
- version: 1.0

## Description

TELAY Algo Alpha
A long-only trade map built on a directional trend model: one entry, a fixed stop, and three scaling targets — all confirmed on bar close.
Based on AlgoAlpha's open-source "Trend Targets". When price confirms an uptrend, the script marks a single long setup: entry at the flip, a fixed stop at low − ATR×5 (it does not trail, so normal pullbacks don't shake the trade out), and three targets registered by touch. Full carry; the position closes at the final target, or earlier on a close below the stop or a bearish flip.
A persistent panel keeps the setup visible through the whole uptrend — entry, stop, live return, the three targets with hit status, trend, and trade state — with a marker at each target. Signals confirm on bar close (no repaint); one position at a time.
Arabic UI — key: الدخول = Entry · الوقف = Stop · السعر/العائد = Price/Return · هدف 1/2/3 = Target 1/2/3 · الاتجاه = Trend (صاعد Up / هابط Down) · صفقة مفتوحة = Open · بلغ الهدف الأخير = Final target reached · ضرب الوقف = Stopped · مراقبة = Monitoring.
Credits: trend logic adapted from the open-source "Trend Targets" by AlgoAlpha. Management, stop, panel, and alerts are original. Published open-source.
For education and research only — not financial advice, and no result is guaranteed.

## Source Code

````pine
//@version=6
// =============================================================================
// TELAY Algo Alpha — v1.5
// الأساس : Trend Targets [AlgoAlpha]
// القواعد: قواعد القرار التفصيلية v1.0 (وقف بالإغلاق 2.1 / تحريك 2.4 / أهداف 3.1)
// النوع  : مؤشر تنبيهات تشغيلية Long-only — نفس جوهر TELAY Swift Trend
//          محرك AlgoAlpha (Supertrend + WMA + EMA) محفوظ كما هو
//          وقف بالإغلاق · أهداف باللمس · 3 أهداف · حمل كامل · إغلاق عند الهدف الأخير
//          وقف متحرك يرتقي مع كل هدف · لوحة معلومات بدل الخطوط · تنسيق عشري تلقائي
//          علامات مميِّزة (دائرة/معيّن/مربّع/صليب) بدل مثلثات المؤشر السابق
// سجل التعديل:
//   v1.1: إزالة الخط السفلي lwr من الوقف المتحرك — بند خامل (يبعد ~12 ATR فلا يرفع الوقف)
//         التتبع الفعّال = تعادل + 30% من ربح T1 + Chandelier
//   v1.1: ربط دائرة الشراء بالدخول الفعلي بدل الإشارة الخام (دقة العلامة في كل الإعدادات)
//   v1.2: الموضع الافتراضي للوحة ← أسفل اليمين
//   v1.3: فصل عرض الإعداد عن إغلاق الصفقة — اللوحة تُبقي مستويات الشراء طوال الاتجاه الصاعد
//         (كالأصل)؛ الإغلاق (هدف/وقف/انقلاب) يصبح حالة + تنبيه + علامة لا تفريغًا للوحة
//   v1.4: مطابقة منطق وقف AlgoAlpha الأصلي — وقف ثابت = low − ATR(14)×5 يُضبط عند الدخول
//         ولا يتتبّع (أُزيل التعادل والتتبّع المتحرك بالكامل)
//   v1.5: شَّارة ترويسة اللوحة بالأزرق المتوسط لتمييز Algo Alpha عن أخضر Swift Trend
// =============================================================================
indicator("TELAY Algo Alpha", overlay = true, max_labels_count = 100)

// ─── مدخلات المحرك (AlgoAlpha — محفوظة) ───────────────────────────────────────
st_factor      = input.float(12,  "Supertrend Factor", minval = 1, step = 0.5, group = "إعدادات الاتجاه")
st_atr_period  = input.int(90,    "Supertrend ATR Period", minval = 1, group = "إعدادات الاتجاه")
wma_length     = input.int(40,    "WMA Length", minval = 1, group = "إعدادات الاتجاه")
ema_length     = input.int(14,    "EMA Length", minval = 1, group = "إعدادات الاتجاه")
cont_factor    = input.int(3,     "Confirmation count", minval = 1, group = "إعدادات الرفض")
atr_period     = input.int(14,    "Volatility (ATR) period", minval = 1, group = "الأهداف")
sl_multiplier  = input.float(5,   "Stop Loss ATR Multiplier", minval = 0.1, step = 0.1, group = "الأهداف")
tp1_multiplier = input.float(0.5, "TP1 Multiplier", minval = 0.1, step = 0.1, group = "الأهداف")
tp2_multiplier = input.float(1.0, "TP2 Multiplier", minval = 0.1, step = 0.1, group = "الأهداف")
tp3_multiplier = input.float(1.5, "TP3 Multiplier", minval = 0.1, step = 0.1, group = "الأهداف")

// ─── مدخلات التشغيل (TELAY) ───────────────────────────────────────────────────
useFlipExit = input.bool(true,  "خروج عند انقلاب الاتجاه هبوطًا", group = "الخروج")
showPanel   = input.bool(true,  "إظهار لوحة المعلومات", group = "العرض")
showLines   = input.bool(false, "إظهار خطوط المستويات", group = "العرض")
panelPos    = input.string("bottom_right", "موضع اللوحة", options = ["top_right","top_left","bottom_right","bottom_left","middle_right"], group = "العرض")

// ─── الألوان ─────────────────────────────────────────────────────────────────
green  = input.color(#00ffbb, "Bullish Color", group = "المظهر")
red    = input.color(#ff1100, "Bearish Color", group = "المظهر")
col_ok = #16ac09
col_no = #db1e1e
orange = #ff8800
color cBg  = color.new(#0e0e12, 0)
color cLab = #b8bcc4

// ─── محرك AlgoAlpha (محفوظ كما هو) ────────────────────────────────────────────
pine_supertrend(factor, atrPeriod) =>
    src = hl2
    atr = ta.atr(atrPeriod)
    upperBand = src + factor * atr
    lowerBand = src - factor * atr
    prevLowerBand = nz(lowerBand[1])
    prevUpperBand = nz(upperBand[1])
    lowerBand := lowerBand > prevLowerBand or close[1] < prevLowerBand ? lowerBand : prevLowerBand
    upperBand := upperBand < prevUpperBand or close[1] > prevUpperBand ? upperBand : prevUpperBand
    [lowerBand, upperBand]

[lwr, upr] = pine_supertrend(st_factor, st_atr_period)
tL = ta.ema(ta.wma(math.avg(lwr, upr), wma_length), ema_length)

var int trend = 0
if ta.crossover(tL, tL[1])
    trend := 1
if ta.crossunder(tL, tL[1])
    trend := -1

var int rejcount = 0
bullishrej = trend == 1 and high > tL and low < tL
bearishrej = trend == -1 and high > tL and low < tL
if (bullishrej or bearishrej)
    rejcount += 1
if ta.cross(trend, 0) or (not (bullishrej or bearishrej) and rejcount > 0)
    rejcount := 0

longSignal  = ta.crossover(trend, 0)
shortSignal = ta.crossunder(trend, 0)
volatility  = ta.atr(atr_period)

// ─── حالة الصفقة (TELAY) ─────────────────────────────────────────────────────
var bool  inTrade = false
var float entry   = na
var float curStop = na
var float t1      = na
var float t2      = na
var float t3      = na
var int   dec     = 2
var bool  hitT1   = false
var bool  hitT2   = false
var bool  hitT3   = false
var bool  setup       = false   // v1.3: عرض الإعداد نشط ما دام الاتجاه صاعدًا (كالأصل)
var int   closeReason = 0       // v1.3: 0=مفتوحة 1=هدف أخير 2=وقف 3=انقلاب

f_fmt(float p, int d) => str.tostring(p, d == 3 ? "0.000" : "0.00")

bool enLong = false   // v1.1: عَلَم الدخول الفعلي (لربط دائرة الشراء بالصفقة لا بالإشارة الخام)

// ─── الدخول ──────────────────────────────────────────────────────────────────
if longSignal and not inTrade and barstate.isconfirmed and not na(volatility)
    inTrade := true
    setup       := true
    closeReason := 0
    enLong  := true
    entry   := close
    curStop := low - volatility * sl_multiplier             // SL بصيغة AlgoAlpha
    dec     := close < 1.0 ? 3 : 2
    float slDist = math.abs(close - curStop)
    t1      := close + slDist * tp1_multiplier
    t2      := close + slDist * tp2_multiplier
    t3      := close + slDist * tp3_multiplier
    hitT1   := false
    hitT2   := false
    hitT3   := false
    alert("🔵 إشارة شراء | " + syminfo.ticker + " | دخول " + f_fmt(entry, dec) + " | وقف " + f_fmt(curStop, dec) + " | أهداف " + f_fmt(t1, dec) + " / " + f_fmt(t2, dec) + " / " + f_fmt(t3, dec), alert.freq_once_per_bar_close)

// ─── أعلام الخروج (تُضبط لحظة الخروج) ─────────────────────────────────────────
bool exTP   = false
bool exSL   = false
bool exFlip = false

// ─── إدارة الصفقة (تقييم على إغلاق الشمعة فقط) ───────────────────────────────
if inTrade and barstate.isconfirmed
    // كشف لمس الأهداف (للعلامات والتنبيهات فقط — الوقف ثابت كالأصل، لا يتحرك)
    if not hitT1 and high >= t1
        hitT1 := true
        alert("✅ تحقق الهدف 1 | " + syminfo.ticker + " | " + f_fmt(t1, dec), alert.freq_once_per_bar_close)
    if not hitT2 and high >= t2
        hitT2 := true
        alert("✅ تحقق الهدف 2 | " + syminfo.ticker + " | " + f_fmt(t2, dec), alert.freq_once_per_bar_close)

    // ترتيب الحسم — الهدف الأخير أولًا (علّم الهدف ثم أغلق)
    if not hitT3 and high >= t3
        hitT3   := true
        inTrade := false
        closeReason := 1
        exTP    := true
        alert("🏁 إغلاق — الهدف الأخير | " + syminfo.ticker + " | " + f_fmt(t3, dec), alert.freq_once_per_bar_close)
    else if close < curStop
        inTrade := false
        closeReason := 2
        exSL    := true
        alert("🛑 إغلاق — ضرب الوقف | " + syminfo.ticker + " | إغلاق " + f_fmt(close, dec) + " < وقف " + f_fmt(curStop, dec), alert.freq_once_per_bar_close)
    else if useFlipExit and shortSignal
        inTrade := false
        closeReason := 3
        exFlip  := true
        alert("🛑 إغلاق — انقلاب الاتجاه | " + syminfo.ticker + " | إغلاق " + f_fmt(close, dec), alert.freq_once_per_bar_close)

// v1.3: يُنهى عرض الإعداد فقط عند هبوط الاتجاه مع إغلاق الصفقة (يبقى ما دامت مفتوحة أو الاتجاه صاعدًا)
if not inTrade and trend == -1 and barstate.isconfirmed
    setup := false

// ─── العلامات المميِّزة (دائرة دخول/هبوط · معيّن أهداف · مربّع T3 · صليب خروج) ──
plotshape(enLong      ? low  : na, "إشارة شراء", shape.circle, location.belowbar, green, size = size.small)
plotshape(shortSignal ? high : na, "إشارة هبوط", shape.circle, location.abovebar, red,   size = size.small)

bool justT1 = hitT1 and not hitT1[1]
bool justT2 = hitT2 and not hitT2[1]
plotshape(justT1 ? t1 : na, "هدف 1", shape.diamond, location.absolute, col_ok, text = "T1", textcolor = color.white, size = size.tiny)
plotshape(justT2 ? t2 : na, "هدف 2", shape.diamond, location.absolute, col_ok, text = "T2", textcolor = color.white, size = size.tiny)

plotshape(exTP   ? t3   : na, "اغلاق T3", shape.square, location.absolute, col_ok, text = "اغلاق T3", textcolor = color.white, size = size.small)
plotshape(exSL   ? high : na, "خروج وقف", shape.xcross, location.abovebar, col_no, text = "خروج",     textcolor = color.white, size = size.small)
plotshape(exFlip ? high : na, "خروج اتجاه", shape.xcross, location.abovebar, orange, text = "خروج اتجاه", textcolor = color.white, size = size.small)

// ─── عناصر العرض الأصلية (محفوظة من AlgoAlpha) ───────────────────────────────
plot(tL, "Baseline", color = trend == 1 ? color.new(green, 50) : color.new(red, 50))
barcolor(trend == 1 ? color.new(green, 50) : color.new(red, 50))
plotchar((rejcount > cont_factor and trend == 1)  ? tL : na, "رفض صعودي", "▲", location.belowbar, green, size = size.tiny)
plotchar((rejcount > cont_factor and trend == -1) ? tL : na, "رفض هبوطي", "▼", location.abovebar, red,   size = size.tiny)

// ─── خطوط المستويات (اختياري — اللوحة هي الأساس) ─────────────────────────────
plot(showLines and setup ? entry   : na, "الدخول", color.new(color.gray, 0), style = plot.style_linebr)
plot(showLines and setup ? curStop : na, "الوقف",  color.new(col_no, 0),     style = plot.style_linebr)
plot(showLines and setup ? t1      : na, "هدف 1",  color.new(col_ok, 40),    style = plot.style_linebr)
plot(showLines and setup ? t2      : na, "هدف 2",  color.new(col_ok, 20),    style = plot.style_linebr)
plot(showLines and setup ? t3      : na, "هدف 3",  color.new(col_ok, 0),     style = plot.style_linebr)

// ─── لوحة المعلومات ──────────────────────────────────────────────────────────
f_pos(string s) =>
    pos = position.top_right
    if s == "top_left"
        pos := position.top_left
    else if s == "bottom_left"
        pos := position.bottom_left
    else if s == "bottom_right"
        pos := position.bottom_right
    else if s == "middle_right"
        pos := position.middle_right
    pos

f_tick(bool hit) => hit ? "✔" : "⏳"

var table panel = showPanel ? table.new(f_pos(panelPos), 2, 10, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 50)) : na

if showPanel and not na(panel) and barstate.islast
    float pnl = setup and not na(entry) ? (close - entry) / entry * 100 : na
    string st = not setup ? "مراقبة" : inTrade ? "صفقة مفتوحة" : closeReason == 1 ? "بلغ الهدف الأخير" : closeReason == 2 ? "ضرب الوقف" : "متابعة"
    color blueMed = #2962FF                                    // v1.5: أزرق متوسط — هوية Algo Alpha
    color hdr     = setup ? blueMed : color.new(color.gray, 0)
    table.cell(panel, 0, 0, "TELAY Algo Alpha", text_color = color.white, bgcolor = blueMed, text_size = size.large)
    table.cell(panel, 1, 0, st, text_color = color.white, bgcolor = hdr, text_size = size.large)
    table.cell(panel, 0, 1, "الرمز / الفريم", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 1, syminfo.ticker + " · " + timeframe.period, text_color = color.white, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 0, 2, "الدخول", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 2, setup ? f_fmt(entry, dec) : "—", text_color = color.white, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 0, 3, "الوقف (ثابت)", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 3, setup ? f_fmt(curStop, dec) : "—", text_color = col_no, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 0, 4, "السعر / العائد", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 4, setup ? f_fmt(close, dec) + "  (" + str.tostring(pnl, "0.0") + "%)" : "—", text_color = na(pnl) ? color.white : (pnl >= 0 ? col_ok : col_no), bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 0, 5, "هدف 1", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 5, setup ? f_fmt(t1, dec) + "  " + f_tick(hitT1) : "—", text_color = color.white, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 0, 6, "هدف 2", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 6, setup ? f_fmt(t2, dec) + "  " + f_tick(hitT2) : "—", text_color = color.white, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 0, 7, "هدف 3", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 7, setup ? f_fmt(t3, dec) + "  " + f_tick(hitT3) : "—", text_color = color.white, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 0, 8, "الاتجاه", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 8, trend == 1 ? "صاعد" : trend == -1 ? "هابط" : "—", text_color = trend == 1 ? green : trend == -1 ? red : color.white, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 0, 9, "ملاحظة", text_color = cLab, bgcolor = cBg, text_size = size.normal)
    table.cell(panel, 1, 9, "وقف الأصل الثابت (low−ATR×5) · أهداف باللمس", text_color = cLab, bgcolor = cBg, text_size = size.small)
````
