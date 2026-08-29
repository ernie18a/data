<!-- tradingview-pine-id: PUB;c27d5f54da9c43b48558315dc085f3dc -->
<!-- tradingviewscripts-format: 1 -->
# SATTAM - التوازن المفقود — Lost Balance

Source: https://www.tradingview.com/script/gqnIaLit-SATTAM-Lost-Balance-Digital-Levels/

## Description

OVERVIEW

Lost Balance plots a price grid derived from digit-sum arithmetic on a swing pivot, then looks for break-and-retest entries at those levels with a full risk map attached.

The idea is that a market's reaction distances are not arbitrary: the digits of a significant swing price are reduced to a single root number, and that root selects one of three fixed spacing "families". Every level in the grid sits an exact multiple of that spacing away from the pivot.

HOW IT WORKS

1 — Core code
The script finds the most recent confirmed pivot high or low on a higher timeframe. It takes the first four digits of that price from the left (ignoring the decimal point), adds them, then reduces the sum to a single digit between 1 and 9.

Example: pivot 4065.33 → 4065 → 4+0+6+5 = 15 → 1+5 = 6. Core code = 6.

2 — Family law
The core code selects the grid spacing:
• codes 1, 4, 7 → family 12 → 12.0 price units
• codes 2, 5, 8 → family 15 → 15.0 price units
• codes 3, 6, 9 → family 18 → 18.0 price units

3 — Level grid
From the pivot, the script draws N levels above and N below, each exactly one family step apart. The pivot line itself is highlighted.

4 — Structure filter
Market bias is read from the same higher timeframe using swing sequence: higher high plus higher low is bullish, lower high plus lower low is bearish, anything else is neutral. Longs are only allowed in a bullish structure, shorts only in a bearish one, and no signals are produced when structure is neutral.

5 — Entry
On the chart timeframe, a signal requires two events in order. First a candle closes through a grid level. Then price returns to that same level and closes back in the direction of the break. The setup is discarded if price closes back on the wrong side, or if the retest does not occur within the configured bar window.

6 — Risk map
Entry is placed at the broken level itself, which makes every distance a whole number of family steps:
• Stop loss — one step back (the previous level)
• Target 1 — one step forward, 1:1
• Target 2 — two steps forward, 1:2
• Target 3 — three steps forward, 1:3

A red box marks the risk zone and a green box the reward zone. When Target 1 is touched, a "SL → BE" marker appears and the script switches its own stop tracking to breakeven.

SETTINGS

• Level timeframe — where the pivot and grid come from (15 / 30 / 60 / 120 / 240)
• Pivot length — left/right bars required to confirm a swing
• Manual pivot price — type a swing price yourself to override auto-detection
• Levels per side — how many grid lines to draw above and below
• Structure filter — enable or disable the directional filter
• Max bars to wait for retest — how long a break stays valid
• Enable Target 3
• Colors for levels, pivot, risk zone and reward zone

An on-chart table shows the pivot price, its first four digits, the digit sum, the core code, the family, the step in price units, and the current structure.

ALERTS

Four alerts are available through "Any alert() function call": long signal, short signal, Target 1 touched (move stop to breakeven), and stop loss hit.

HOW TO USE

Open a 3-minute chart, leave the level timeframe on 60 minutes, and wait for the grid and structure to settle. When a signal prints, the entry, stop and targets are already drawn at exact grid prices — no measuring required.

IMPORTANT NOTES

The family steps of 12, 15 and 18 are absolute price units, not percentages or ATR multiples. This makes the script meaningful on gold, where those values correspond to 120, 150 and 180 points, and meaningless on instruments quoted at a very different scale such as major FX pairs. Adjust your expectations accordingly, or use the manual pivot input to experiment.

The source method does not define how market structure should be measured, so a standard swing-sequence read is used here. It can be turned off if you prefer to set the bias yourself.

Only one position is tracked at a time. A new signal is not accepted until the current one resolves at its stop or final target.

This script draws levels and setups for study and execution assistance. It does not place orders and it is not financial advice.

CREDITS

The digital-levels method — core code extraction, the three spacing families, and the step-based stop and target map — comes from the "Lost Balance" chapter of the SOVEREIGN trading book. The Pine implementation, structure filter, break-and-retest state machine and trade tracking are original work.
نظرة عامة

يرسم المؤشر شبكة أسعار مشتقة من جمع أرقام سعر بيفوت، ثم يبحث عن دخول بكسر وإعادة اختبار عند تلك المستويات مع خريطة مخاطرة كاملة.

آلية العمل

1. الشفرة المركزية — يرصد آخر قمة أو قاع مؤكد على فريم أعلى، يأخذ أول 4 أرقام من اليسار، يجمعها، ثم يبسّط الناتج لرقم واحد بين 1 و 9.
مثال: 4065.33 ← 4065 ← 4+0+6+5 = 15 ← 1+5 = 6.

2. قانون العائلات — الشفرات 1-4-7 تعطي عائلة 12، والشفرات 2-5-8 عائلة 15، والشفرات 3-6-9 عائلة 18. وهذه هي المسافة الثابتة بين المستويات.

3. الشبكة — من البيفوت تُرسم مستويات فوق وتحت، المسافة بينها خطوة العائلة بالضبط.

4. الهيكلة — قمة أعلى مع قاع أعلى = صاعد، وقمة أدنى مع قاع أدنى = هابط. الشراء مسموح في الصاعد فقط والبيع في الهابط فقط، ولا إشارات في العرضي.

5. الدخول — إغلاق شمعة خارج المستوى، ثم عودة السعر للمستوى نفسه وإغلاقه في اتجاه الكسر.

6. خريطة المخاطرة — الدخول عند المستوى المكسور، والوقف عند المستوى السابق، والأهداف الثلاثة عند المستويات التالية بنسب 1:1 و 1:2 و 1:3. عند لمس الهدف الأول يظهر وسم SL → BE.

ملاحظة مهمة

خطوات العائلة (12 و 15 و 18) قيم سعرية مطلقة وليست نسباً، فهي ذات معنى على الذهب حيث تعادل 120 و 150 و 180 نقطة، وبلا معنى على أدوات ذات تسعير مختلف كلياً مثل أزواج العملات الرئيسية.

المؤشر أداة رسم ومساعدة تنفيذ، لا ينفّذ أوامر ولا يُعد نصيحة مالية.

المصدر

منهج المستويات الرقمية مأخوذ من فصل "التوازن المفقود" في كتاب SOVEREIGN. التنفيذ بلغة Pine وفلتر الهيكلة وآلة حالة الكسر وإعادة الاختبار ومتابعة الصفقة عمل أصلي.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  استراتيجية التوازن المفقود — Lost Balance Digital Levels
//  مبني حرفياً على كتاب SOVEREIGN (النسخة الأولى) — فصل "شفرة التوازن المفقود"
//
//  المنطق:  بيفوت → أول 4 أرقام → جمع → تبسيط لرقم واحد (الشفرة المركزية)
//           الشفرة → العائلة (12 / 15 / 18) → شبكة المستويات
//           الهيكلة → كسر مستوى + إعادة اختبار → دخول / وقف / 3 أهداف
// ═══════════════════════════════════════════════════════════════════════════
indicator("SATTAM - التوازن المفقود — Lost Balance", "SATTAM - التوازن المفقود", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ─────────────────────────────── المدخلات ─────────────────────────────────
g1 = "① الشفرة المركزية"
levelTF   = input.timeframe("60",  "فريم المستويات", options = ["15", "30", "60", "120", "240"], group = g1)
pivotLen  = input.int(5,           "طول البيفوت (شموع يمين/يسار)", minval = 1, maxval = 50, group = g1)
manualPiv = input.float(0.0,       "سعر بيفوت يدوي (0 = تلقائي)", minval = 0.0, group = g1,
     tooltip = "اكتب سعر القمة أو القاع بنفسك (مثل 4607.71) لتجاوز الاكتشاف التلقائي")

g2 = "② شبكة المستويات"
levelsN    = input.int(10,   "عدد المستويات لكل جهة", minval = 1, maxval = 30, group = g2)
showPrices = input.bool(true, "إظهار أسعار المستويات", group = g2)

g3 = "③ الدخول"
useBias    = input.bool(true, "فلتر الهيكلة (تداول مع الاتجاه فقط)", group = g3)
retestBars = input.int(20,    "أقصى شموع لانتظار إعادة الاختبار", minval = 1, maxval = 200, group = g3)

g4 = "④ إدارة الصفقة"
useTP3   = input.bool(true, "تفعيل الهدف الثالث (TP3)", group = g4,
     tooltip = "فصل الخروج في الكتاب يذكر 3 أهداف، بينما الأمثلة المصوّرة تعرض TP1 و TP2 فقط")
showInfo = input.bool(true, "إظهار جدول الشفرة", group = g4)

g5 = "⑤ الألوان"
cLevel = input.color(color.new(#546e7a, 25), "خط المستوى", group = g5)
cPivot = input.color(color.new(#1e88e5,  0), "خط البيفوت",  group = g5)
cRisk  = input.color(color.new(#ef5350, 78), "منطقة المخاطرة", group = g5)
cRew   = input.color(color.new(#26a69a, 78), "منطقة الهدف",    group = g5)

// ════════════════════════ ① محرك الشفرة المركزية ═════════════════════════
// الجذر الرقمي: تبسيط متكرر للجمع حتى نصل لرقم واحد بين 1 و 9
digitalRoot(int n) =>
    n <= 0 ? 0 : 1 + (n - 1) % 9

// أول 4 خانات رقمية من اليسار (بعد حذف الفاصلة) → الجمع → الشفرة
codeParts(float price) =>
    string digits = ""
    int    total  = 0
    int    code   = 0
    if not na(price) and price > 0
        string s = str.tostring(price, "#.########")
        for i = 0 to str.length(s) - 1
            string ch = str.substring(s, i, i + 1)
            if str.contains("0123456789", ch) and str.length(digits) < 4
                digits := digits + ch
        if str.length(digits) > 0
            for i = 0 to str.length(digits) - 1
                total += math.round(str.tonumber(str.substring(digits, i, i + 1)))
            code := digitalRoot(total)
    [code, digits, total]

// قانون العائلات: 1-4-7 ← 12 | 2-5-8 ← 15 | 3-6-9 ← 18
familyStep(int code) =>
    switch
        code == 1 or code == 4 or code == 7 => 12.0
        code == 2 or code == 5 or code == 8 => 15.0
        code == 3 or code == 6 or code == 9 => 18.0
        =>                                     na

// ════════════════════ ② سياق الفريم الأعلى (بيفوت + هيكلة) ════════════════
htfContext() =>
    float ph = ta.pivothigh(high, pivotLen, pivotLen)
    float pl = ta.pivotlow(low,   pivotLen, pivotLen)
    var float lastPiv = na
    var int   lastDir = 0
    var float ph1 = na
    var float ph2 = na
    var float pl1 = na
    var float pl2 = na
    if not na(ph)
        lastPiv := ph
        lastDir := 1
        ph2     := ph1
        ph1     := ph
    if not na(pl)
        lastPiv := pl
        lastDir := -1
        pl2     := pl1
        pl1     := pl
    // الهيكلة: قمة أعلى + قاع أعلى = صاعد | قمة أدنى + قاع أدنى = هابط
    int bias = 0
    if not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2)
        bias := ph1 > ph2 and pl1 > pl2 ?  1 : ph1 < ph2 and pl1 < pl2 ? -1 : 0
    [lastPiv, lastDir, bias]

[htfPivot, htfPivDir, htfBias] = request.security(syminfo.tickerid, levelTF, htfContext(),
     lookahead = barmerge.lookahead_off)

float pivotPrice = manualPiv > 0 ? manualPiv : htfPivot
[coreVal, coreDigits, coreSum] = codeParts(pivotPrice)
float step  = familyStep(coreVal)
bool  ready = not na(pivotPrice) and not na(step) and step > 0

// ═════════════════════════ ③ شبكة المستويات ═══════════════════════════════
var array<line>  gridLines  = array.new<line>()
var array<label> gridLabels = array.new<label>()

bool rebuild = ready and (na(pivotPrice[1]) or na(step[1]) or pivotPrice != pivotPrice[1] or step != step[1])

if rebuild
    if array.size(gridLines) > 0
        for i = 0 to array.size(gridLines) - 1
            line.delete(array.get(gridLines, i))
        array.clear(gridLines)
    if array.size(gridLabels) > 0
        for i = 0 to array.size(gridLabels) - 1
            label.delete(array.get(gridLabels, i))
        array.clear(gridLabels)
    for n = -levelsN to levelsN
        float y = pivotPrice + n * step
        array.push(gridLines, line.new(bar_index - 1, y, bar_index, y,
             extend = extend.both,
             color  = n == 0 ? cPivot : cLevel,
             width  = n == 0 ? 2 : 1,
             style  = n == 0 ? line.style_solid : line.style_dotted))
        if showPrices
            array.push(gridLabels, label.new(bar_index + 12, y,
                 str.tostring(y, format.mintick) + (n == 0 ? "  ◄ البيفوت" : ""),
                 style     = label.style_none,
                 textcolor = n == 0 ? cPivot : color.new(cLevel, 0),
                 size      = size.small))

// إبقاء تسميات الأسعار ملتصقة بآخر شمعة
if barstate.islast and array.size(gridLabels) > 0
    for i = 0 to array.size(gridLabels) - 1
        label.set_x(array.get(gridLabels, i), bar_index + 12)

// ═════════════════ ④ كاشف الكسر وإعادة الاختبار (فريم الشارت) ═════════════
// فهرس الشبكة يغطي كل المستويات بتكلفة ثابتة بدل فحصها واحداً واحداً
int   gridIdx   = ready ? int(math.floor((close - pivotPrice) / step)) : na
bool  idxValid  = ready and not rebuild and not na(gridIdx) and not na(gridIdx[1])
bool  brokeUp   = idxValid and gridIdx > gridIdx[1]
bool  brokeDown = idxValid and gridIdx < gridIdx[1]

var int   pendDir = 0
var float pendLvl = na
var int   pendBar = na

var int   tDir   = 0
var float tEntry = na
var float tSL    = na
var float tTP1   = na
var float tTP2   = na
var float tTP3   = na
var bool  tBE    = false
var int   beBar  = na
var box   riskBox   = na
var box   rewardBox = na

bool allowLong  = not useBias or htfBias ==  1
bool allowShort = not useBias or htfBias == -1

// كسر جديد → حالة انتظار إعادة الاختبار
if tDir == 0
    if brokeUp and allowLong
        pendDir := 1
        pendLvl := pivotPrice + gridIdx * step
        pendBar := bar_index
    else if brokeDown and allowShort
        pendDir := -1
        pendLvl := pivotPrice + (gridIdx + 1) * step
        pendBar := bar_index

// إعادة الاختبار → إشارة، أو إلغاء
bool sigLong  = false
bool sigShort = false
if pendDir != 0 and bar_index > pendBar
    if bar_index - pendBar > retestBars
        pendDir := 0
    else if pendDir == 1
        if close < pendLvl
            pendDir := 0
        else if low <= pendLvl and close > pendLvl
            sigLong := true
    else
        if close > pendLvl
            pendDir := 0
        else if high >= pendLvl and close < pendLvl
            sigShort := true

// ═══════════════════════ ⑤ فتح الصفقة ورسم الخريطة ════════════════════════
if sigLong or sigShort
    int d = sigLong ? 1 : -1
    tDir   := d
    tEntry := pendLvl
    tSL    := pendLvl - d * step
    tTP1   := pendLvl + d * step
    tTP2   := pendLvl + d * step * 2
    tTP3   := pendLvl + d * step * 3
    tBE    := false
    beBar  := na
    pendDir := 0
    float finalTP = useTP3 ? tTP3 : tTP2

    riskBox   := box.new(bar_index, math.max(tEntry, tSL), bar_index + 1, math.min(tEntry, tSL),
         border_color = na, bgcolor = cRisk)
    rewardBox := box.new(bar_index, math.max(tEntry, finalTP), bar_index + 1, math.min(tEntry, finalTP),
         border_color = na, bgcolor = cRew)

    label.new(bar_index, tEntry, "Entry", style = label.style_label_left,
         color = color.new(#42a5f5, 15), textcolor = color.white, size = size.small)
    label.new(bar_index, tSL, "SL", style = label.style_label_left,
         color = color.new(#ef5350, 15), textcolor = color.white, size = size.small)
    label.new(bar_index, tTP1, "TP1", style = label.style_label_left,
         color = color.new(#26a69a, 15), textcolor = color.white, size = size.small)
    label.new(bar_index, tTP2, "TP2", style = label.style_label_left,
         color = color.new(#26a69a, 15), textcolor = color.white, size = size.small)
    if useTP3
        label.new(bar_index, tTP3, "TP3", style = label.style_label_left,
             color = color.new(#26a69a, 15), textcolor = color.white, size = size.small)

    string side = d == 1 ? "شراء" : "بيع"
    alert("التوازن المفقود — إشارة " + side + " | عائلة " + str.tostring(step, "#") +
         " | دخول " + str.tostring(tEntry, format.mintick) +
         " | وقف "  + str.tostring(tSL,   format.mintick) +
         " | TP1 "  + str.tostring(tTP1,  format.mintick) +
         " | TP2 "  + str.tostring(tTP2,  format.mintick), alert.freq_once_per_bar)

plotshape(sigLong,  "إشارة شراء", shape.triangleup,   location.belowbar, color.new(#26a69a, 0), size = size.tiny)
plotshape(sigShort, "إشارة بيع",  shape.triangledown, location.abovebar, color.new(#ef5350, 0), size = size.tiny)

// ═══════════════════════ ⑥ متابعة الصفقة حتى الإغلاق ══════════════════════
if tDir != 0
    box.set_right(riskBox,   bar_index + 1)
    box.set_right(rewardBox, bar_index + 1)

    // لمس الهدف الأول → نقل الوقف لنقطة الدخول وإغلاق نصف العقد
    bool tp1Hit = tDir == 1 ? high >= tTP1 : low <= tTP1
    if tp1Hit and not tBE
        tBE   := true
        beBar := bar_index
        label.new(bar_index, tEntry, "SL → BE", style = label.style_label_left,
             color = color.new(#ffa726, 15), textcolor = color.white, size = size.tiny)
        alert("التوازن المفقود — لمس TP1: انقل الوقف لنقطة الدخول وأغلق نصف العقد",
             alert.freq_once_per_bar)

    // الوقف الفعّال يصبح نقطة الدخول ابتداءً من الشمعة التالية للمس TP1
    float effSL   = tBE and bar_index > beBar ? tEntry : tSL
    float finalTP = useTP3 ? tTP3 : tTP2
    bool  slHit   = tDir == 1 ? low  <= effSL   : high >= effSL
    bool  tpDone  = tDir == 1 ? high >= finalTP : low  <= finalTP

    if slHit
        if not tBE
            box.set_bgcolor(rewardBox, color.new(color.gray, 90))
            alert("التوازن المفقود — ضرب وقف الخسارة عند " + str.tostring(tSL, format.mintick),
                 alert.freq_once_per_bar)
        tDir := 0
    else if tpDone
        tDir := 0

// ══════════════════════════ ⑦ جدول الشفرة ═════════════════════════════════
var table info = table.new(position.top_right, 2, 7, border_width = 1,
     frame_color = color.new(color.gray, 50), frame_width = 1)

row(int r, string k, string v, color vc) =>
    table.cell(info, 0, r, k, text_color = color.gray, text_size = size.small,
         bgcolor = color.new(color.black, 85), text_halign = text.align_right)
    table.cell(info, 1, r, v, text_color = vc, text_size = size.small,
         bgcolor = color.new(color.black, 85), text_halign = text.align_center)

if showInfo and barstate.islast
    string breakdown = ""
    if str.length(coreDigits) > 0
        for i = 0 to str.length(coreDigits) - 1
            breakdown := breakdown + (i > 0 ? " + " : "") + str.substring(coreDigits, i, i + 1)

    string biasTxt = htfBias == 1 ? "صاعد ▲" : htfBias == -1 ? "هابط ▼" : "عرضي ─"
    color  biasCol = htfBias == 1 ? #26a69a : htfBias == -1 ? #ef5350 : color.gray

    if not ready
        row(0, "الحالة", "بانتظار بيفوت مؤكد", color.orange)
        for r = 1 to 6
            row(r, "", "", color.gray)
    else
        row(0, "سعر البيفوت",    str.tostring(pivotPrice, format.mintick) +
             (manualPiv > 0 ? " (يدوي)" : htfPivDir == 1 ? " (قمة)" : " (قاع)"), color.white)
        row(1, "أول 4 أرقام",    coreDigits,                       color.white)
        row(2, "الجمع المنطقي",  breakdown + " = " + str.tostring(coreSum), color.white)
        row(3, "الشفرة المركزية", str.tostring(coreVal),            #ffa726)
        row(4, "العائلة",        "الـ " + str.tostring(step, "#"),  #ffa726)
        row(5, "الخطوة",         "$" + str.tostring(step, "#") + " = " +
             str.tostring(step * 10, "#") + " نقطة",                color.white)
        row(6, "الهيكلة",        biasTxt,                           biasCol)
````
