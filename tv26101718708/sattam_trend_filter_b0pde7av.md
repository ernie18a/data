# Sattam | Trend Filter

- url: https://www.tradingview.com/script/b0pDe7aV-Sattam-Trend-Filter/
- type: indicator
- pine_id: PUB;7af709c8512540f9b6700aeb8891e52e
- version: 1.0

## Description

[b]SATTAM | Trend Filter
[/b]
A trend-following overlay built on a triple-pass exponential smoothing engine
with Fibonacci-adaptive volatility bands and a live command-center panel.

── HOW IT WORKS ──────────────────────────────────────────────
1) NOISE FILTER
   Price is passed through three chained EMA stages. Each stage feeds the next,
   which removes most of the intrabar noise that makes a single moving average
   whipsaw, while keeping the turn of the trend readable.

2) TREND DETECTION
   Direction is taken from the 2-bar slope of the filter line (base - base[2]),
   not from a price/MA cross. The line turns green while the slope is positive
   and red while it is negative. An orange diamond marks the exact bar where the
   slope flips sign (confirmed on close only - no repainting of the signal).

3) FIBONACCI-ADAPTIVE BANDS
   Band width is the smoothed high-low range, expanded by three Fibonacci
   multipliers (0.236 / 0.382 / 0.618, scaled). The bands breathe with real
   volatility, so the same settings work on a quiet range and on a fast trend.
   Fills are gradient-colored by trend momentum, from bear color to bull color.

4) MULTI-FILTER (optional)
   Adds a slower filter line. Triangles mark fast/slow crosses, and the panel
   reports whether both filters agree (Aligned) or conflict (Divergent).

── COMMAND CENTER PANEL ──────────────────────────────────────
• Trend      - current direction
• Strength   - 0-100% of the strongest slope in the lookback window
               (Strong / Moderate / Weak / Flat)
• Band Pos   - where price sits inside the outer bands
               (Over-Extended / Upper Band / Mid / Lower Band)
• Filters    - fast vs slow agreement (multi-filter mode)
• Signal     - the active flip on this bar

── HOW TO USE ────────────────────────────────────────────────
• Trade in the direction of the line color; treat flips as the alert to act.
• Prefer entries taken while Strength is Strong or Moderate; Flat readings
  usually mean a range, where flips are least reliable.
• "Over-Extended" in Band Pos warns that price is stretched to the outer band
  - useful for taking partials or waiting for a pullback instead of chasing.
• Turn on Multi-Filter for higher-timeframe context: take signals only when
  the panel shows Aligned.

── SETTINGS ──────────────────────────────────────────────────
All inputs are labelled in English and Arabic.
• Filter Length - lower = faster and more signals, higher = smoother
  (25 default; try 50-80 on lower timeframes, 10-20 for scalping)
• Slow Filter Length - the confirmation filter (80 default)
• Colors, fill transparency, bar coloring
• Panel position, size, and language (EN / AR)

── ALERTS ────────────────────────────────────────────────────
• Trend Bullish / Trend Bearish (slope flip)
• Fast Cross Up / Fast Cross Down (multi-filter cross)
All alerts fire once per bar close and include ticker, timeframe and price.
Panel language (EN / AR) also controls the alert message language.

Works on any symbol and any timeframe.

Disclaimer: for education and analysis only. This is not financial advice.
No indicator predicts the future - always use your own risk management.

[b]SATTAM | Trend Filter — فلتر الاتجاه
[/b]
مؤشر اتجاه يُرسم فوق الشارت، مبني على محرّك تنعيم أُسّي ثلاثي المراحل،
مع نطاقات فيبوناتشي متكيّفة مع التذبذب، ولوحة تحكّم مباشرة.

── كيف يعمل ─────────────────────────────────────────────────
١) فلتر الضجيج
   يمرّ السعر عبر ثلاث مراحل EMA متسلسلة، كل مرحلة تُغذّي التي بعدها.
   هذا يزيل معظم الضجيج الذي يجعل المتوسط المتحرك العادي يتذبذب،
   مع بقاء لحظة انعكاس الاتجاه واضحة وقابلة للقراءة.

٢) تحديد الاتجاه
   الاتجاه يُؤخذ من ميل الخط عبر شمعتين (base - base[2])، وليس من تقاطع
   السعر مع متوسط. الخط أخضر عندما يكون الميل موجباً، وأحمر عندما يكون سالباً.
   الماسة البرتقالية تحدّد الشمعة التي انقلب فيها الميل — وتُؤكَّد عند إغلاق
   الشمعة فقط، بلا إعادة رسم للإشارة.

٣) نطاقات فيبوناتشي المتكيّفة
   عرض النطاق = مدى (أعلى − أدنى) بعد تنعيمه، مضروباً في ثلاثة معاملات
   فيبوناتشي (٠.٢٣٦ / ٠.٣٨٢ / ٠.٦١٨ بعد التحجيم). النطاقات تتّسع وتضيق مع
   التذبذب الحقيقي، فتعمل نفس الإعدادات في السوق الهادئ وفي الترند السريع.
   تعبئة النطاقات ملوّنة بتدرّج حسب زخم الاتجاه، من لون الهبوط إلى لون الصعود.

٤) الفلتر المزدوج (اختياري)
   يضيف خط فلتر أبطأ. المثلثات تحدّد تقاطع السريع مع البطيء، واللوحة تُظهر
   هل الفلتران متوافقان (متوافق) أم متعارضان (متعارض).

── لوحة التحكّم ─────────────────────────────────────────────
• الاتجاه      — الاتجاه الحالي (صاعد / هابط)
• القوة        — من ٠ إلى ١٠٠٪ مقارنةً بأقوى ميل في فترة القياس
                 (قوي / متوسط / ضعيف / محايد)
• موضع النطاق  — أين يقع السعر داخل النطاقات الخارجية
                 (تشبّع / النطاق العلوي / الوسط / النطاق السفلي)
• الفلاتر      — توافق السريع مع البطيء (في وضع الفلتر المزدوج)
• الإشارة      — الانعكاس النشط على الشمعة الحالية

── طريقة الاستخدام ──────────────────────────────────────────
• تداول مع لون الخط، واعتبر لحظة الانعكاس هي إشارة التحرّك.
• فضّل الدخول عندما تكون القوة «قوي» أو «متوسط»؛ قراءة «محايد» غالباً تعني
  سوقاً عرضياً تكون فيه الانعكاسات أقل موثوقية.
• ظهور «تشبّع» في موضع النطاق يعني أن السعر امتدّ إلى النطاق الخارجي —
  مفيد لجني جزء من الأرباح أو انتظار الارتداد بدل المطاردة.
• فعّل الفلتر المزدوج للحصول على سياق الفريم الأكبر، وخذ الإشارات فقط
  عندما تُظهر اللوحة «متوافق».

── الإعدادات ────────────────────────────────────────────────
جميع الإعدادات مكتوبة بالإنجليزية والعربية معاً.
• طول الفلتر — الأقل = أسرع وإشارات أكثر، والأعلى = أنعم
  (الافتراضي ٢٥؛ جرّب ٥٠–٨٠ على الفريمات الصغيرة، و١٠–٢٠ للمضاربة السريعة)
• طول الفلتر البطيء — فلتر التأكيد (الافتراضي ٨٠)
• الألوان، وشفافية التعبئة، وتلوين الشموع
• موضع اللوحة وحجمها ولغتها (EN / AR)

── التنبيهات ────────────────────────────────────────────────
• اتجاه صاعد / اتجاه هابط (انعكاس الميل)
• تقاطع صاعد / تقاطع هابط للفلتر السريع (في الفلتر المزدوج)
كل التنبيهات تُطلق مرة واحدة عند إغلاق الشمعة، وتتضمّن الرمز والفريم والسعر.
لغة اللوحة (EN / AR) تتحكّم أيضاً في لغة نص التنبيه.

يعمل على جميع الرموز وجميع الفريمات الزمنية.

إخلاء مسؤولية: هذا المؤشر لأغراض تعليمية وتحليلية فقط، وليس نصيحة مالية.
لا يوجد مؤشر يتنبأ بالمستقبل — التزم دائماً بإدارة رأس المال الخاصة بك.

## Source Code

````pine
//@version=6
indicator("Sattam | Trend Filter", overlay=true, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════

// --- Main Filter ---
grp_main = "🔧 Main Filter | الفلتر الرئيسي"
src        = input.source(close, "Source | المصدر", group=grp_main)
length     = input.int(25, "Filter Length | طول الفلتر", minval=5, maxval=300, group=grp_main)
lineWidth  = input.int(3, "Line Width | سماكة الخط", minval=1, maxval=5, group=grp_main)

// --- Multi-Filter ---
grp_multi = "📊 Multi-Filter | الفلتر المزدوج"
useMulti     = input.bool(false, "Enable Multi-Filter | تفعيل الفلتر المزدوج", group=grp_multi)
slowLength   = input.int(80, "Slow Filter Length | طول الفلتر البطيء", minval=5, maxval=300, group=grp_multi)
showCross    = input.bool(true, "Show Cross Signals | إظهار إشارات التقاطع", group=grp_multi)

// --- Visual ---
grp_vis = "🎨 Visual | المظهر"
bullColor    = input.color(#00e676, "Bull Color | لون الصعود", group=grp_vis)
bearColor    = input.color(#ff1744, "Bear Color | لون الهبوط", group=grp_vis)
fillTransp   = input.int(85, "Fill Transparency | شفافية التعبئة", minval=0, maxval=100, group=grp_vis)
useBarColor  = input.bool(false, "Color Bars | تلوين الشموع", group=grp_vis)

// --- Panel ---
grp_panel = "📋 Command Center | لوحة التحكم"
showPanel    = input.bool(true, "Show Panel | إظهار اللوحة", group=grp_panel)
panelPos     = input.string("Top Right | أعلى يمين", "Position | الموضع", options=["Top Left | أعلى يسار", "Top Right | أعلى يمين", "Bottom Left | أسفل يسار", "Bottom Right | أسفل يمين"], group=grp_panel)
panelSize    = input.string("Small | صغير", "Size | الحجم", options=["Tiny | صغير جداً", "Small | صغير", "Normal | عادي"], group=grp_panel)

// --- Alerts ---
grp_alert = "🔔 Alerts | التنبيهات"
alertTrend   = input.bool(true, "Trend Change Alerts | تنبيهات تغيّر الاتجاه", group=grp_alert)
alertCross   = input.bool(true, "Filter Cross Alerts | تنبيهات تقاطع الفلاتر", group=grp_alert)
langSel      = input.string("EN", "Panel Language | لغة اللوحة", options=["EN", "AR"], group=grp_alert)

bool isAR = langSel == "AR"

// ══════════════════════════════════════════════════════════════════════════
// TRIPLE-PASS EMA NOISE FILTER
// ══════════════════════════════════════════════════════════════════════════

noise_filter(float _src, int _len) =>
    float alpha = 2.0 / (_len + 1)
    var float nf1 = na
    var float nf2 = na
    var float nf3 = na
    nf1 := alpha * _src + (1 - alpha) * nz(nf1[1], _src)
    nf2 := alpha * nf1 + (1 - alpha) * nz(nf2[1], nf1)
    nf3 := alpha * nf2 + (1 - alpha) * nz(nf3[1], nf2)
    nf3

// --- Fast filter (main) ---
float base = noise_filter(src, length)

// --- Slow filter (multi-filter) ---
float baseSlow = noise_filter(src, slowLength)

// ══════════════════════════════════════════════════════════════════════════
// FIBONACCI-ADAPTIVE BANDS
// ══════════════════════════════════════════════════════════════════════════

float bandWidth = noise_filter(high - low, length)

float fib1 = 0.236 * 1.5
float fib2 = 0.382 * 2.0
float fib3 = 0.618 * 2.5

float upper1 = base + fib1 * bandWidth
float lower1 = base - fib1 * bandWidth
float upper2 = base + fib2 * bandWidth
float lower2 = base - fib2 * bandWidth
float upper3 = base + fib3 * bandWidth
float lower3 = base - fib3 * bandWidth

// ══════════════════════════════════════════════════════════════════════════
// TREND DETECTION
// ══════════════════════════════════════════════════════════════════════════

float diff = base - base[2]

bool isBull = diff > 0
bool isBear = diff < 0

// --- Trend Strength (0-100%) ---
float absDiff    = math.abs(diff)
float maxDiff    = ta.highest(absDiff, length)
float strength   = maxDiff != 0 ? (absDiff / maxDiff) * 100 : 0

string strengthLabel = strength >= 80 ? (isAR ? "قوي" : "Strong") : strength >= 50 ? (isAR ? "متوسط" : "Moderate") : strength >= 20 ? (isAR ? "ضعيف" : "Weak") : (isAR ? "محايد" : "Flat")

// --- Price Position in Bands ---
float bandRange  = upper3 - lower3
float pricePos   = bandRange != 0 ? (close - lower3) / bandRange * 100 : 50

string posLabel  = pricePos >= 90 or pricePos <= 10 ? (isAR ? "تشبّع" : "Over-Extended") : pricePos >= 60 ? (isAR ? "النطاق العلوي" : "Upper Band") : pricePos >= 40 ? (isAR ? "الوسط" : "Mid") : (isAR ? "النطاق السفلي" : "Lower Band")

// ══════════════════════════════════════════════════════════════════════════
// DIAMOND SIGNALS
// ══════════════════════════════════════════════════════════════════════════

bool bullFlip = ta.crossover(diff, 0) and barstate.isconfirmed
bool bearFlip = ta.crossunder(diff, 0) and barstate.isconfirmed

// --- Multi-Filter Cross ---
bool fastAboveSlow = ta.crossover(base, baseSlow) and barstate.isconfirmed
bool fastBelowSlow = ta.crossunder(base, baseSlow) and barstate.isconfirmed
bool isAligned     = base > baseSlow

// ══════════════════════════════════════════════════════════════════════════
// GRADIENT COLORS
// ══════════════════════════════════════════════════════════════════════════

float diffLow  = ta.lowest(diff, 100)
float diffHigh = ta.highest(diff, 100)

color gradColor = color.from_gradient(diff, diffLow, diffHigh, bearColor, bullColor)

color trendColor = isBull ? bullColor : bearColor

// ══════════════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════════════

// --- Main trend line ---
plot(base, "Trend Filter", color=trendColor, linewidth=lineWidth)

// --- Slow filter line ---
plot(useMulti ? baseSlow : na, "Slow Filter", color=color.new(color.gray, 30), linewidth=1)

// --- Band plots (invisible, for fills) ---
p_u1 = plot(upper1, "Upper 1", color=color.new(color.white, 100))
p_l1 = plot(lower1, "Lower 1", color=color.new(color.white, 100))
p_u2 = plot(upper2, "Upper 2", color=color.new(color.white, 100))
p_l2 = plot(lower2, "Lower 2", color=color.new(color.white, 100))
p_u3 = plot(upper3, "Upper 3", color=color.new(color.white, 100))
p_l3 = plot(lower3, "Lower 3", color=color.new(color.white, 100))

// --- Gradient fills ---
fill(p_u1, p_l1, color=color.new(gradColor, fillTransp), title="Inner Band Fill")
fill(p_u2, p_u1, color=color.new(gradColor, fillTransp + 5 > 100 ? 100 : fillTransp + 5), title="Mid Upper Fill")
fill(p_l1, p_l2, color=color.new(gradColor, fillTransp + 5 > 100 ? 100 : fillTransp + 5), title="Mid Lower Fill")
fill(p_u3, p_u2, color=color.new(gradColor, fillTransp + 10 > 100 ? 100 : fillTransp + 10), title="Outer Upper Fill")
fill(p_l2, p_l3, color=color.new(gradColor, fillTransp + 10 > 100 ? 100 : fillTransp + 10), title="Outer Lower Fill")

// --- Diamond signals ---
plotshape(bullFlip ? base[1] : na, "Bull Signal", style=shape.diamond, location=location.absolute, color=#FF9800, size=size.small, offset=-1)
plotshape(bearFlip ? base[1] : na, "Bear Signal", style=shape.diamond, location=location.absolute, color=#FF9800, size=size.small, offset=-1)

// --- Multi-filter cross signals ---
plotshape(useMulti and showCross and fastAboveSlow ? baseSlow : na, "Fast Cross Up", style=shape.triangleup, location=location.absolute, color=bullColor, size=size.tiny, offset=-1)
plotshape(useMulti and showCross and fastBelowSlow ? baseSlow : na, "Fast Cross Down", style=shape.triangledown, location=location.absolute, color=bearColor, size=size.tiny, offset=-1)

// --- Bar coloring ---
barcolor(useBarColor ? trendColor : na)

// ══════════════════════════════════════════════════════════════════════════
// COMMAND CENTER PANEL
// ══════════════════════════════════════════════════════════════════════════

var table panel = na

if showPanel
    posY = str.startswith(panelPos, "Top") ? position.top_right : position.bottom_right
    if str.startswith(panelPos, "Top Left")
        posY := position.top_left
    else if str.startswith(panelPos, "Top Right")
        posY := position.top_right
    else if str.startswith(panelPos, "Bottom Left")
        posY := position.bottom_left
    else
        posY := position.bottom_right

    tblSize = str.startswith(panelSize, "Tiny") ? size.tiny : str.startswith(panelSize, "Small") ? size.small : size.normal

    panel := table.new(posY, 2, 7, bgcolor=color.new(#1e1e1e, 10), border_width=1, border_color=color.new(color.gray, 60), frame_width=2, frame_color=color.new(color.gray, 40))

    // Header
    table.cell(panel, 0, 0, isAR ? "🌈 فلتر الاتجاه" : "🌈 Trend Filter", text_color=color.white, text_size=tblSize, bgcolor=color.new(#2d2d2d, 0), text_halign=text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)

    // Trend Direction
    string trendDir = isBull ? (isAR ? "▲ صاعد" : "▲ BULLISH") : (isAR ? "▼ هابط" : "▼ BEARISH")
    table.cell(panel, 0, 1, isAR ? "الاتجاه" : "Trend", text_color=color.gray, text_size=tblSize)
    table.cell(panel, 1, 1, trendDir, text_color=trendColor, text_size=tblSize)

    // Strength
    table.cell(panel, 0, 2, isAR ? "القوة" : "Strength", text_color=color.gray, text_size=tblSize)
    table.cell(panel, 1, 2, str.tostring(math.round(strength, 1)) + "% (" + strengthLabel + ")", text_color=strength >= 80 ? trendColor : strength >= 50 ? color.yellow : color.gray, text_size=tblSize)

    // Price Position
    table.cell(panel, 0, 3, isAR ? "موضع النطاق" : "Band Pos", text_color=color.gray, text_size=tblSize)
    table.cell(panel, 1, 3, str.tostring(math.round(pricePos, 1)) + "% (" + posLabel + ")", text_color=pricePos >= 90 or pricePos <= 10 ? #FF9800 : color.white, text_size=tblSize)

    // Filter Alignment (multi-filter)
    if useMulti
        string alignStr = isAligned ? (isAR ? "✓ متوافق" : "✓ Aligned") : (isAR ? "✗ متعارض" : "✗ Divergent")
        table.cell(panel, 0, 4, isAR ? "الفلاتر" : "Filters", text_color=color.gray, text_size=tblSize)
        table.cell(panel, 1, 4, alignStr, text_color=isAligned ? bullColor : bearColor, text_size=tblSize)

    // Active Signal
    string sigText = bullFlip ? (isAR ? "◆ انعكاس صاعد" : "◆ Bull Flip") : bearFlip ? (isAR ? "◆ انعكاس هابط" : "◆ Bear Flip") : "—"
    color sigColor = bullFlip ? bullColor : bearFlip ? bearColor : color.gray
    int sigRow = useMulti ? 5 : 4
    table.cell(panel, 0, sigRow, isAR ? "الإشارة" : "Signal", text_color=color.gray, text_size=tblSize)
    table.cell(panel, 1, sigRow, sigText, text_color=sigColor, text_size=tblSize)

// ══════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════

string alertHead = "[" + syminfo.ticker + " " + timeframe.period + "] "
string atStr     = isAR ? " عند " : " @ "

if alertTrend
    if bullFlip
        alert(alertHead + (isAR ? "🟢 اتجاه صاعد" : "🟢 TREND BULLISH") + atStr + str.tostring(close), alert.freq_once_per_bar_close)
    if bearFlip
        alert(alertHead + (isAR ? "🔴 اتجاه هابط" : "🔴 TREND BEARISH") + atStr + str.tostring(close), alert.freq_once_per_bar_close)

if alertCross and useMulti
    if fastAboveSlow
        alert(alertHead + (isAR ? "🟢 تقاطع صاعد للفلتر السريع" : "🟢 FAST CROSS UP") + atStr + str.tostring(close), alert.freq_once_per_bar_close)
    if fastBelowSlow
        alert(alertHead + (isAR ? "🔴 تقاطع هابط للفلتر السريع" : "🔴 FAST CROSS DOWN") + atStr + str.tostring(close), alert.freq_once_per_bar_close)
````
