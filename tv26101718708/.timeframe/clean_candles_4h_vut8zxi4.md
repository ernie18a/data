# Clean Candles [4H]

- url: https://www.tradingview.com/script/Vut8ZxI4-Clean-Candles-4H/
- type: indicator
- pine_id: PUB;831d7c3e9a30409fbd0832212e81dfc9
- version: 1.0

## Description

What can be controlled ⏱️ Timeframe: Default 4H, can be changed to any timeframe 🕯️ Candle type: No end, top/bottom/secrets (Marubozu) 🎨 Colors: 6 protein colors per type and direction 🔲 Limits: Activate/deactivate color, thickness 🏷️ Marker: Text or symbol, size, candle stop 📏 Line at lock, length, color 🔔 Alerts: 7 alerts, stability in Condition 💧 Overall limit: 10M USDT, adjustable 📊 Statistics panel with numbers and percentages, location can be changed

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hezamalqhatani
// 🕯️ مؤشر الشموع النظيفة — شموع 4 ساعات بدون ذيول

//@version=6
indicator("🕯️ الشموع النظيفة [4H]", overlay=true, max_labels_count=500)

// ══════════════════════════════════════════════════════════════
// 1️⃣  إعدادات الإطار الزمني | Timeframe Settings
// ══════════════════════════════════════════════════════════════
var G1 = "⏱️ الإطار الزمني"
tfInput         = input.timeframe("240", "الإطار الزمني للفحص", group=G1,
                  tooltip="الإطار الافتراضي 240 دقيقة (4 ساعات). يمكنك تغييره لأي إطار.")

// ══════════════════════════════════════════════════════════════
// 2️⃣  نوع الشمعة المطلوبة | Candle Type Selection
// ══════════════════════════════════════════════════════════════
var G2 = "🕯️ نوع الشمعة"
detectMode      = input.string("الاثنان معاً", "الكشف عن",
                  options=["بدون ذيل علوي فقط", "بدون ذيل سفلي فقط", "الاثنان معاً"],
                  group=G2,
                  tooltip="بدون ذيل علوي فقط: high=close أو high=open\nبدون ذيل سفلي فقط: low=close أو low=open\nالاثنان معاً: الشمعة بدون أي ذيول (Marubozu كاملة)")

wickTolerance   = input.float(0.0, "تسامح الذيل (نقطة)", group=G2, minval=0.0, step=0.1,
                  tooltip="0 = صارم تماماً. أي قيمة أكبر تسمح بذيل صغير بهذا الحجم بالنقاط.\nمفيد للأسواق التي تصعب فيها الشموع 100% النظيفة.")

// ══════════════════════════════════════════════════════════════
// 3️⃣  إعدادات الألوان | Color Settings
// ══════════════════════════════════════════════════════════════
var G3 = "🎨 الألوان"
// شمعة بدون ذيل علوي
colorNoUpperBull = input.color(color.new(#00E5FF, 0),  "↑ صاعدة — بدون ذيل علوي", group=G3, inline="cu")
colorNoUpperBear = input.color(color.new(#FF6F00, 0),  "↓ هابطة — بدون ذيل علوي", group=G3, inline="cu")
// شمعة بدون ذيل سفلي
colorNoLowerBull = input.color(color.new(#76FF03, 0),  "↑ صاعدة — بدون ذيل سفلي", group=G3, inline="cl")
colorNoLowerBear = input.color(color.new(#FF1744, 0),  "↓ هابطة — بدون ذيل سفلي", group=G3, inline="cl")
// شمعة Marubozu كاملة (بدون ذيلين)
colorMarubozuBull = input.color(color.new(#B9F6CA, 0), "↑ صاعدة — بدون ذيلين (Marubozu)", group=G3, inline="cm")
colorMarubozuBear = input.color(color.new(#FF8A80, 0), "↓ هابطة — بدون ذيلين (Marubozu)", group=G3, inline="cm")

// شفافية جسم الشمعة الملونة
bodyTransparency = input.int(0, "شفافية الجسم %", group=G3, minval=0, maxval=90, step=5)

// ══════════════════════════════════════════════════════════════
// 4️⃣  إعدادات الحدود | Border Settings
// ══════════════════════════════════════════════════════════════
var G4 = "🔲 حدود الشمعة"
showBorder      = input.bool(true,  "إظهار حد الشمعة",      group=G4, inline="b1")
borderColor     = input.color(color.new(#FFFFFF, 40), "لون الحد", group=G4, inline="b1")

// ══════════════════════════════════════════════════════════════
// 5️⃣  إعدادات الملصق | Label Settings
// ══════════════════════════════════════════════════════════════
var G5 = "🏷️ الملصقات"
showLabel       = input.bool(true,  "إظهار ملصق فوق الشمعة",    group=G5, inline="l1")
labelStyle      = input.string("نص", "نوع الملصق", options=["نص","رمز"], group=G5, inline="l1")
labelSize       = input.string("صغير", "حجم الملصق", options=["صغير جداً","صغير","عادي","كبير"], group=G5)
labelOffsetPct  = input.float(0.3, "مسافة الملصق عن الشمعة %", group=G5, minval=0.0, maxval=5.0, step=0.1,
                  tooltip="نسبة مئوية من نطاق السعر لتحريك الملصق بعيداً عن الشمعة")

// ══════════════════════════════════════════════════════════════
// 6️⃣  إعدادات الخط الأفقي | Horizontal Line Settings
// ══════════════════════════════════════════════════════════════
var G6 = "📏 خطوط أفقية"
showHLine       = input.bool(false, "رسم خط عند مستوى الإغلاق", group=G6, inline="h1")
hLineStyle      = input.string("متقطع", "نمط الخط", options=["صلب","متقطع","منقط"], group=G6, inline="h1")
hLineColor      = input.color(color.new(#FFEB3B, 50), "لون الخط", group=G6, inline="h1")
hLineWidth      = input.int(1, "سماكة الخط", group=G6, minval=1, maxval=4, inline="h1")
hLineLength     = input.int(20, "طول الخط (شموع)", group=G6, minval=1, maxval=500)

// ══════════════════════════════════════════════════════════════
// 7️⃣  إعدادات التنبيهات | Alert Settings
// ══════════════════════════════════════════════════════════════
var G7 = "🔔 التنبيهات"
alertNoUpper    = input.bool(true,  "تنبيه: شمعة بدون ذيل علوي",       group=G7, inline="al1")
alertNoLower    = input.bool(true,  "تنبيه: شمعة بدون ذيل سفلي",       group=G7, inline="al1")
alertMarubozu   = input.bool(true,  "تنبيه: Marubozu كاملة",            group=G7, inline="al2")
alertBullOnly   = input.bool(false, "صاعدة فقط",                        group=G7, inline="al2")
alertBearOnly   = input.bool(false, "هابطة فقط",                        group=G7, inline="al2")

// فلتر السيولة
var G8 = "💧 فلتر السيولة"
liqEnabled      = input.bool(true,        "تفعيل فلتر السيولة",         group=G8, inline="lq1")
liqMinUSDT      = input.float(10000000.0, "الحد الأدنى (USDT)",         group=G8, inline="lq1",
                  minval=0.0, step=1000000.0,
                  tooltip="لن تُطلق أي تنبيه إذا كانت سيولة الشمعة أقل من هذا الحد.\nالقيمة الافتراضية: 10,000,000 USDT")

// ══════════════════════════════════════════════════════════════
// 8️⃣  إعدادات الإحصائيات | Statistics Panel
// ══════════════════════════════════════════════════════════════
var G9 = "📊 لوحة الإحصائيات"
showStats       = input.bool(true, "إظهار لوحة الإحصائيات", group=G9, inline="st1")
statsLocation   = input.string("أعلى اليمين", "موقع اللوحة",
                  options=["أعلى اليمين","أعلى اليسار","أعلى الوسط","أسفل اليمين","أسفل اليسار"],
                  group=G9, inline="st1")
statsLookback   = input.int(100, "عدد الشموع للإحصاء", group=G9, minval=10, maxval=1000)

// ══════════════════════════════════════════════════════════════
// 🔧 دوال مساعدة | Helper Functions
// ══════════════════════════════════════════════════════════════
toLabelSize(s) =>
    switch s
        "صغير جداً" => size.tiny
        "صغير"      => size.small
        "عادي"      => size.normal
        "كبير"      => size.large
        => size.small

toLineStyle(s) =>
    switch s
        "صلب"    => line.style_solid
        "متقطع"  => line.style_dashed
        "منقط"   => line.style_dotted
        => line.style_dashed

toPosition(s) =>
    switch s
        "أعلى اليمين"  => position.top_right
        "أعلى اليسار"  => position.top_left
        "أعلى الوسط"   => position.top_center
        "أسفل اليمين"  => position.bottom_right
        "أسفل اليسار"  => position.bottom_left
        => position.top_right

// ══════════════════════════════════════════════════════════════
// 9️⃣  جلب بيانات الإطار الزمني المحدد | Fetch HTF Data
// ══════════════════════════════════════════════════════════════
// نجلب OHLC من الإطار الزمني المحدد — barmerge.lookahead_on بعد الإغلاق
[htfO, htfH, htfL, htfC, htfV] = request.security(
     syminfo.tickerid, tfInput,
     [open, high, low, close, volume],
     lookahead = barmerge.lookahead_on)

// ══════════════════════════════════════════════════════════════
// 🔍 منطق الكشف | Detection Logic
// ══════════════════════════════════════════════════════════════
tol = wickTolerance * syminfo.mintick   // تحويل النقاط لقيمة سعرية

// الذيل العلوي والسفلي بالقيمة الفعلية
upperWick = htfH - math.max(htfO, htfC)
lowerWick = math.min(htfO, htfC) - htfL

// هل الذيل ضمن حد التسامح؟
noUpperWick = upperWick <= tol
noLowerWick = lowerWick <= tol

isBull = htfC >= htfO
isBear = htfC < htfO

// الشموع المكتشفة
isNoUpperOnly  = noUpperWick and not noLowerWick   // بدون ذيل علوي فقط
isNoLowerOnly  = noLowerWick and not noUpperWick   // بدون ذيل سفلي فقط
isMarubozu     = noUpperWick and noLowerWick        // بدون ذيلين (Marubozu)

// تطبيق وضع الكشف المحدد
isDetected = switch detectMode
    "بدون ذيل علوي فقط" => isNoUpperOnly or isMarubozu
    "بدون ذيل سفلي فقط" => isNoLowerOnly or isMarubozu
    "الاثنان معاً"       => isMarubozu
    => false

// تغيير الشمعة في الإطار الزمني (اكتشاف الإغلاق الجديد)
htfChanged = ta.change(htfC) != 0 or ta.change(htfO) != 0

// ══════════════════════════════════════════════════════════════
// 🎨 تحديد اللون | Color Assignment
// ══════════════════════════════════════════════════════════════
getCandleColor() =>
    clr = color(na)
    if isMarubozu
        clr := isBull ? color.new(colorMarubozuBull, bodyTransparency) : color.new(colorMarubozuBear, bodyTransparency)
    else if isNoUpperOnly
        clr := isBull ? color.new(colorNoUpperBull, bodyTransparency)  : color.new(colorNoUpperBear, bodyTransparency)
    else if isNoLowerOnly
        clr := isBull ? color.new(colorNoLowerBull, bodyTransparency)  : color.new(colorNoLowerBear, bodyTransparency)
    clr

candleColor = getCandleColor()

// ══════════════════════════════════════════════════════════════
// 📊 الرسم البياني | Plotting
// ══════════════════════════════════════════════════════════════

// رسم الشمعة الملونة فوق الشمعة الأصلية
plotcandle(
     isDetected ? htfO : na,
     isDetected ? htfH : na,
     isDetected ? htfL : na,
     isDetected ? htfC : na,
     color       = candleColor,
     wickcolor   = candleColor,
     bordercolor = showBorder ? borderColor : candleColor)

// ══════════════════════════════════════════════════════════════
// 🏷️ الملصقات | Labels
// ══════════════════════════════════════════════════════════════
priceRange  = ta.highest(high, 200) - ta.lowest(low, 200)
labelOffset = priceRange * (labelOffsetPct / 100.0)

getLabelText() =>
    txt = ""
    if labelStyle == "رمز"
        if isMarubozu
            txt := isBull ? "🟢" : "🔴"
        else if isNoUpperOnly
            txt := isBull ? "🔵" : "🟠"
        else if isNoLowerOnly
            txt := isBull ? "💚" : "❤️"
    else
        if isMarubozu
            txt := isBull ? "▲M" : "▼M"
        else if isNoUpperOnly
            txt := "⊤"
        else if isNoLowerOnly
            txt := "⊥"
    txt

if isDetected and showLabel and barstate.isconfirmed
    labelY    = isBull ? htfH + labelOffset : htfL - labelOffset
    labelPos  = isBull ? label.style_label_down : label.style_label_up
    labelTxt  = getLabelText()
    labelClr  = color.new(candleColor, 30)
    label.new(
         bar_index, labelY,
         text      = labelTxt,
         style     = labelPos,
         color     = labelClr,
         textcolor = color.white,
         size      = toLabelSize(labelSize))

// ══════════════════════════════════════════════════════════════
// 📏 الخطوط الأفقية | Horizontal Lines
// ══════════════════════════════════════════════════════════════
var line hLineLast = na

if isDetected and showHLine and barstate.isconfirmed
    if not na(hLineLast)
        line.delete(hLineLast)
    hLineLast := line.new(
         x1    = bar_index,
         y1    = htfC,
         x2    = bar_index + hLineLength,
         y2    = htfC,
         color = hLineColor,
         width = hLineWidth,
         style = toLineStyle(hLineStyle),
         extend = extend.none)

// ══════════════════════════════════════════════════════════════
// 📊 لوحة الإحصائيات | Statistics Panel
// ══════════════════════════════════════════════════════════════
var int countNoUpper   = 0
var int countNoLower   = 0
var int countMarubozu  = 0
var int countBull      = 0
var int countBear      = 0
var int countTotal     = 0

if barstate.isconfirmed and isDetected
    countTotal    += 1
    if isMarubozu
        countMarubozu += 1
    else if isNoUpperOnly
        countNoUpper  += 1
    else if isNoLowerOnly
        countNoLower  += 1
    if isBull
        countBull += 1
    else
        countBear += 1

var table statsTable = na
if barstate.islast and showStats
    statsTable := table.new(toPosition(statsLocation), 2, 8,
         bgcolor      = color.new(#0D1117, 10),
         border_color = color.new(#30363D, 0),
         border_width = 1,
         frame_color  = color.new(#58A6FF, 20),
         frame_width  = 1)

    // الرأس
    table.merge_cells(statsTable, 0, 0, 1, 0)
    table.cell(statsTable, 0, 0,
         "🕯️ إحصائيات الشموع النظيفة",
         text_color = #58A6FF,
         bgcolor    = color.new(#161B22, 0),
         text_size  = size.small)

    // المجموع
    table.cell(statsTable, 0, 1, "📌 الإجمالي",        text_color=#C9D1D9, text_size=size.small, bgcolor=color.new(#0D1117,20))
    table.cell(statsTable, 1, 1, str.tostring(countTotal), text_color=#FFFFFF, text_size=size.small, bgcolor=color.new(#0D1117,20))

    // Marubozu
    table.cell(statsTable, 0, 2, "⬛ Marubozu كاملة",  text_color=#F0C27F, text_size=size.small, bgcolor=color.new(#0D1117,30))
    table.cell(statsTable, 1, 2, str.tostring(countMarubozu), text_color=#F0C27F, text_size=size.small, bgcolor=color.new(#0D1117,30))

    // بدون ذيل علوي
    table.cell(statsTable, 0, 3, "⊤ بدون ذيل علوي",   text_color=#00E5FF, text_size=size.small, bgcolor=color.new(#0D1117,20))
    table.cell(statsTable, 1, 3, str.tostring(countNoUpper), text_color=#00E5FF, text_size=size.small, bgcolor=color.new(#0D1117,20))

    // بدون ذيل سفلي
    table.cell(statsTable, 0, 4, "⊥ بدون ذيل سفلي",   text_color=#76FF03, text_size=size.small, bgcolor=color.new(#0D1117,30))
    table.cell(statsTable, 1, 4, str.tostring(countNoLower), text_color=#76FF03, text_size=size.small, bgcolor=color.new(#0D1117,30))

    // صاعدة
    table.cell(statsTable, 0, 5, "▲ صاعدة",             text_color=#3FB950, text_size=size.small, bgcolor=color.new(#0D1117,20))
    table.cell(statsTable, 1, 5, str.tostring(countBull),  text_color=#3FB950, text_size=size.small, bgcolor=color.new(#0D1117,20))

    // هابطة
    table.cell(statsTable, 0, 6, "▼ هابطة",             text_color=#F85149, text_size=size.small, bgcolor=color.new(#0D1117,30))
    table.cell(statsTable, 1, 6, str.tostring(countBear),  text_color=#F85149, text_size=size.small, bgcolor=color.new(#0D1117,30))

    // نسبة صاعدة/هابطة
    bullRatio = countTotal > 0 ? math.round((countBull / countTotal) * 100) : 0
    table.cell(statsTable, 0, 7, "📈 نسبة الصعود",      text_color=#C9D1D9, text_size=size.small, bgcolor=color.new(#0D1117,20))
    table.cell(statsTable, 1, 7, str.tostring(bullRatio) + "%", text_color= bullRatio >= 50 ? #3FB950 : #F85149, text_size=size.small, bgcolor=color.new(#0D1117,20))

// ══════════════════════════════════════════════════════════════
// 🔔 التنبيهات | Alerts (alertcondition — تظهر كل منفصلة)
// ══════════════════════════════════════════════════════════════
_liq      = hlc3 * volume
_liqOK    = not liqEnabled or _liq >= liqMinUSDT
_confirmed = barstate.isconfirmed

// شروط مدمجة مع السيولة والإغلاق المؤكد
_cNoUpperBull  = _confirmed and _liqOK and (isNoUpperOnly or isMarubozu) and isBull  and (not alertBearOnly)
_cNoUpperBear  = _confirmed and _liqOK and (isNoUpperOnly or isMarubozu) and isBear  and (not alertBullOnly)
_cNoLowerBull  = _confirmed and _liqOK and (isNoLowerOnly or isMarubozu) and isBull  and (not alertBearOnly)
_cNoLowerBear  = _confirmed and _liqOK and (isNoLowerOnly or isMarubozu) and isBear  and (not alertBullOnly)
_cMarubozuBull = _confirmed and _liqOK and isMarubozu and isBull and (not alertBearOnly)
_cMarubozuBear = _confirmed and _liqOK and isMarubozu and isBear and (not alertBullOnly)
_cAny          = _confirmed and _liqOK and isDetected

// تنبيهات alert() للتفاصيل الإضافية في الرسالة
if _cNoUpperBull and alertNoUpper
    alert("⊤▲ شمعة صاعدة بدون ذيل علوي | " + syminfo.ticker + " [" + tfInput + "] | الإغلاق: " + str.tostring(htfC, format.mintick), alert.freq_once_per_bar_close)

if _cNoUpperBear and alertNoUpper
    alert("⊤▼ شمعة هابطة بدون ذيل علوي | " + syminfo.ticker + " [" + tfInput + "] | الإغلاق: " + str.tostring(htfC, format.mintick), alert.freq_once_per_bar_close)

if _cNoLowerBull and alertNoLower
    alert("⊥▲ شمعة صاعدة بدون ذيل سفلي | " + syminfo.ticker + " [" + tfInput + "] | الإغلاق: " + str.tostring(htfC, format.mintick), alert.freq_once_per_bar_close)

if _cNoLowerBear and alertNoLower
    alert("⊥▼ شمعة هابطة بدون ذيل سفلي | " + syminfo.ticker + " [" + tfInput + "] | الإغلاق: " + str.tostring(htfC, format.mintick), alert.freq_once_per_bar_close)

if _cMarubozuBull and alertMarubozu
    alert("⬛▲ Marubozu صاعدة — بدون أي ذيول | " + syminfo.ticker + " [" + tfInput + "] | الإغلاق: " + str.tostring(htfC, format.mintick), alert.freq_once_per_bar_close)

if _cMarubozuBear and alertMarubozu
    alert("⬛▼ Marubozu هابطة — بدون أي ذيول | " + syminfo.ticker + " [" + tfInput + "] | الإغلاق: " + str.tostring(htfC, format.mintick), alert.freq_once_per_bar_close)

// alertcondition — تظهر كخيارات منفصلة في قائمة Condition
alertcondition(_cNoUpperBull,  title="⊤▲ صاعدة — بدون ذيل علوي",       message="⊤▲ شمعة صاعدة بدون ذيل علوي | {{ticker}} | {{interval}} | الإغلاق: {{close}}")
alertcondition(_cNoUpperBear,  title="⊤▼ هابطة — بدون ذيل علوي",       message="⊤▼ شمعة هابطة بدون ذيل علوي | {{ticker}} | {{interval}} | الإغلاق: {{close}}")
alertcondition(_cNoLowerBull,  title="⊥▲ صاعدة — بدون ذيل سفلي",       message="⊥▲ شمعة صاعدة بدون ذيل سفلي | {{ticker}} | {{interval}} | الإغلاق: {{close}}")
alertcondition(_cNoLowerBear,  title="⊥▼ هابطة — بدون ذيل سفلي",       message="⊥▼ شمعة هابطة بدون ذيل سفلي | {{ticker}} | {{interval}} | الإغلاق: {{close}}")
alertcondition(_cMarubozuBull, title="⬛▲ Marubozu صاعدة — بدون ذيلين", message="⬛▲ Marubozu صاعدة | {{ticker}} | {{interval}} | الإغلاق: {{close}}")
alertcondition(_cMarubozuBear, title="⬛▼ Marubozu هابطة — بدون ذيلين", message="⬛▼ Marubozu هابطة | {{ticker}} | {{interval}} | الإغلاق: {{close}}")
alertcondition(_cAny,          title="🔔 أي شمعة نظيفة",                 message="🔔 شمعة نظيفة رُصدت | {{ticker}} | {{interval}} | الإغلاق: {{close}}")
````
