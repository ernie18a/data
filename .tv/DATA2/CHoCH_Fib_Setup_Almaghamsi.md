<!-- tradingview-pine-id: PUB;7befcb3d6cbc4e4fbbdf88c51bab53be -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CHoCH Fib Setup [Almaghamsi]

Source: https://www.tradingview.com/script/Dy1wZuka/

## Description

CHoCH Fib Setup is an educational overlay indicator that combines Change of Character (CHoCH) detection with Fibonacci retracement and extension levels.
The script is designed to help traders study one structured workflow on a single chart:

Identify a CHoCH on the current timeframe.
Draw Fibonacci levels on the impulse that produced that CHoCH.
Highlight a 0.5-0.618 pullback zone as a study area for potential entries.
Project extension targets at 1.272, 1.414, 2, 1.618 and 2.618.
Optionally filter setups with a higher-timeframe structure bias.

This is not a buy/sell signal service and it does not place trades. It is a visual study tool.
What the script does
The script uses pivot highs and lows to track the latest swing points. A bullish CHoCH is marked when price breaks above the last relevant swing high after a non-bullish bias. A bearish CHoCH is marked when price breaks below the last relevant swing low after a non-bearish bias. Users can require a close beyond the level or allow a wick break.
After a valid CHoCH, the script anchors a Fibonacci range to that impulse:

Retracement levels: 0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0
Entry study zone: 0.5 to 0.618
Stop-loss line at the opposite extreme of the impulse
Extension targets: 1.272, 1.414, 1.618 ,2 and 2.618

Each level is printed with its ratio and the actual price.
An optional higher-timeframe module reads the same structure logic on a user-selected timeframe. When enabled, long Fibonacci setups are drawn only if HTF bias is bullish, and short setups only if HTF bias is bearish. Counter-trend CHoCH events can still appear as faded labels ending with "x".
The settings panel is bilingual (English / Arabic), with English first. On-chart labels default to English and can be switched to Arabic.
Why this combination exists
CHoCH, Fibonacci retracements, Fibonacci extensions, and multi-timeframe bias are established public concepts. This script does not invent those concepts. Its purpose is to keep them in one readable workflow so the user does not have to draw the Fib range manually after every CHoCH.
The script is original as a packaged study layout: aligned CHoCH-to-Fib mapping, optional HTF gating, price labels on targets, and a bilingual interface. It does not claim to reverse-engineer any closed-source vendor tool.
How to use

Add the indicator to a standard candlestick chart.
Choose a working timeframe. Example: 15 minutes for entries.
Enable the HTF filter if desired and set a larger interval. Example: 60 on a 15-minute chart.
Wait for a CHoCH in the direction of the HTF bias.
Use the 0.5-0.618 box only as a pullback study zone, not as an automatic order.
Treat the red line as a structural invalidation reference, not a broker order.
Treat 1.272 / 1.414 / 1.618 /2 /2.618 as measured extension references only.
Confirm context with your own analysis and risk limits.

Limitations
Pivot length changes the CHoCH results. This is a simplified swing-break model and not a full Smart Money Concepts suite. It does not plot order blocks, FVGs, or liquidity pools. HTF bias can change until the higher-timeframe bar closes. The script keeps the latest aligned Fibonacci setup, not unlimited history. Pivot confirmation needs right-side bars, which is normal for pivot logic. There is no win rate because this is an indicator, not a strategy().
Disclaimer
This script is provided for education and chart study only. It is not investment advice, financial advice, trading advice, or a recommendation to buy or sell any instrument. Markets involve a high risk of loss. Past behavior around CHoCH or Fibonacci levels does not predict future results. Users are responsible for their own decisions, position sizing, and local regulations.
Open-source note
This publication is open-source so users can inspect the logic. If you reuse parts of the code in a public script, credit this publication and add a meaningful improvement before publishing.

مؤشر CHoCH Fib Setup أداة تعليمية على الشارت تجمع بين اكتشاف تغيير صفة الحركة (CHoCH) ومستويات فيبوناتشي للتصحيح والامتداد.
الهدف هو دراسة مسار واحد على نفس الشارت:

تحديد CHoCH على الفريم الحالي.
رسم فيبوناتشي على موجة الاندفاع التي صنعته.
تظليل منطقة 0.5 إلى 0.618 كمنطقة دراسة للدخول المحتمل.
إسقاط أهداف 1.272 و 1.414 و 1.618 و 2 و2.618.
إمكانية فلترة السيتب باتجاه الفريم الأعلى.

هذه ليست خدمة توصيات ولا تفتح صفقات تلقائيًا. هي أداة بصرية للدراسة.
ماذا يفعل المؤشر
يستخدم قممًا وقيعانًا محورية لتتبع آخر نقاط التأرجح. يُعلَّم CHoCH الصاعد عند كسر آخر قمة محورية بعد انحياز غير صاعد، والهابط عند كسر آخر قاع محوري بعد انحياز غير هابط. يمكن اشتراط الإغلاق أو السماح بكسر الظل.
بعد CHoCH صالح يُثبَّت فيبوناتشي على الموجة، مع منطقة 0.5-0.618 وخط إبطال عند طرف الموجة وأهداف امتداد 1.272 و 1.414 و 1.618 و 2 و 2.618، وكل مستوى يظهر مع سعره.
فلتر الفريم الأعلى اختياري. عند تفعيله يُرسم سيتر الشراء فقط إذا كان الفريم الأعلى صاعدًا، وسيتر البيع فقط إذا كان هابطًا. أحداث CHoCH المخالفة يمكن أن تظهر باهتة وتنتهي بـ x.
لوحة الإعدادات ثنائية اللغة والإنجليزية أولًا. نصوص الشارت افتراضيًا بالإنجليزية ويمكن تحويلها للعربية.
لماذا هذا التجميع
المفاهيم عامة ومعروفة. المؤشر لا يدّعي اختراعها. الغرض جمعها في مسار واحد حتى لا يُرسم الفيبو يدويًا بعد كل CHoCH. الأصالة في التغليف: ربط CHoCH بالفيبو، فلتر الفريم الأعلى، السعر على الأهداف، وواجهة ثنائية اللغة.
طريقة الاستخدام
أضف المؤشر على شارت شموع قياسي، اختر فريم العمل، فعّل الفلتر إن أردت، وانتظر CHoCH مع اتجاه الفريم الأعلى. صندوق 0.5-0.618 منطقة دراسة فقط، والخط الأحمر مرجع إبطال، والأهداف مراجع قياس. أكّد دائمًا بتحليلك وحدود المخاطرة.
القيود
النتيجة تتغير مع طول المحور. النموذج مبسّط ولا يرسم كتل أوامر ولا فجوات قيمة عادلة. انحياز الفريم الأعلى قد يتغير قبل إغلاق شمعة ذلك الفريم. لا توجد نسبة نجاح لأن هذا مؤشر وليس استراتيجية.
إخلاء المسؤولية
هذا المؤشر للتعليم ودراسة الشارت فقط، وليس استشارة استثمارية ولا توصية بشراء أو بيع أي أداة. التداول ينطوي على مخاطر خسارة مرتفعة، والسلوك السابق لا يتنبأ بالنتائج المستقبلية. المستخدم مسؤول عن قراراته وحجم المخاطرة والأنظمة المحلية.
ملاحظة المصدر المفتوح
نُشر السكربت مفتوح المصدر لمراجعة المنطق. إذا أعدت استخدام أجزاء منه في منشور عام، اذكر هذا المنشور وأضف تحسينًا حقيقيًا قبل النشر.

---

## Source Code

````pine
//@version=6
indicator('CHoCH Fib Setup [Almaghamsi]', overlay = true, max_lines_count = 200, max_boxes_count = 30, max_labels_count = 100)

// ═══════════════════════════════════════
// Language  |  اللغة
// ═══════════════════════════════════════
grpLang = 'Language / اللغة'
langSel = input.string('English', 'Chart Language / لغة الشارت', options = ['English', 'العربية'], group = grpLang, tooltip = 'English is the default. Switch to Arabic for on-chart labels and the dashboard.\nالإنجليزية هي الافتراضية. اختر العربية لتغيير النصوص على الشارت.')
isAr = langSel == 'العربية'

// ═══════════════════════════════════════
// Inputs  |  الإعدادات (English default)
// ═══════════════════════════════════════
grpSwing = 'Market Structure / هيكل السوق'
swingLen = input.int(5, 'Pivot Length / طول المحور', minval = 2, group = grpSwing, tooltip = 'Higher value = fewer and stronger signals.\nكلما زاد الرقم قلت الإشارات وأصبحت أقوى.')
useClose = input.bool(true, 'Confirm Break with Close / تأكيد الكسر بالإغلاق', group = grpSwing)

grpHTF = 'Higher Timeframe / الفريم الأعلى'
useHTF = input.bool(true, 'Enable HTF Filter / تفعيل فلتر الفريم الأعلى', group = grpHTF)
htfTF = input.timeframe('60', 'Higher Timeframe / الفريم الأعلى', group = grpHTF, tooltip = 'Example: 60 = 1H, 240 = 4H, D = Daily.\nمثال: 60 = ساعة، 240 = 4 ساعات، D = يومي.')
showHTFbg = input.bool(true, 'HTF Background Tint / تلوين الخلفية حسب الفريم الأعلى', group = grpHTF)
hideAgainst = input.bool(true, 'Hide Counter-Trend Fib / إخفاء فيبو المخالف للاتجاه', group = grpHTF)
showAllCHoCH = input.bool(true, 'Show All CHoCH Labels / إظهار كل علامات CHoCH', group = grpHTF)

grpFib = 'Fibonacci / فيبوناتشي'
showFib = input.bool(true, 'Draw Fibonacci after CHoCH / رسم فيبو بعد CHoCH', group = grpFib)
showZone = input.bool(true, 'Highlight Entry Zone 0.5-0.618 / تظليل منطقة الدخول', group = grpFib)
showTP = input.bool(true, 'Draw Extension Targets / رسم أهداف الامتداد', group = grpFib)
showTP1272 = input.bool(true, 'Target 1.272 / هدف 1.272', group = grpFib)
showTP1414 = input.bool(true, 'Target 1.414 / هدف 1.414', group = grpFib)
showTP1618 = input.bool(true, 'Target 1.618 / هدف 1.618', group = grpFib)
showTP2000 = input.bool(true, 'Target 2.000 / هدف 2.000', group = grpFib)
showTP2618 = input.bool(true, 'Target 2.618 / هدف 2.618', group = grpFib)
extendBars = input.int(40, 'Line Extension (bars) / تمديد الخطوط', minval = 5, group = grpFib)

grpVis = 'Colors / الألوان'
bullColor = input.color(color.new(#00c853, 0), 'Bullish CHoCH / CHoCH صاعد', group = grpVis)
bearColor = input.color(color.new(#ff1744, 0), 'Bearish CHoCH / CHoCH هابط', group = grpVis)
zoneBull = input.color(color.new(#00c853, 80), 'Long Entry Zone / منطقة شراء', group = grpVis)
zoneBear = input.color(color.new(#ff1744, 80), 'Short Entry Zone / منطقة بيع', group = grpVis)
slColor = input.color(color.new(#ff1744, 0), 'Stop Loss / وقف الخسارة', group = grpVis)
tp1272Color = input.color(color.new(#26c6da, 0), 'TP 1.272', group = grpVis)
tp1414Color = input.color(color.new(#42a5f5, 0), 'TP 1.414', group = grpVis)
tp1618Color = input.color(color.new(#7e57c2, 0), 'TP 1.618', group = grpVis)
tp2000Color = input.color(color.new(#ab47bc, 0), 'TP 2.000', group = grpVis)
tp2618Color = input.color(color.new(#ec407a, 0), 'TP 2.618', group = grpVis)

// ═══════════════════════════════════════
// Localized strings  |  النصوص
// ═══════════════════════════════════════
t_chochUp = isAr ? 'CHoCH ▲' : 'CHoCH ▲'
t_chochDn = isAr ? 'CHoCH ▼' : 'CHoCH ▼'
t_chochUpX = isAr ? 'CHoCH ▲ ×' : 'CHoCH ▲ x'
t_chochDnX = isAr ? 'CHoCH ▼ ×' : 'CHoCH ▼ x'
t_sl = isAr ? 'وقف' : 'SL'
t_tp1 = isAr ? 'هدف1 1.272' : 'TP1 1.272'
t_tp2 = isAr ? 'هدف2 1.414' : 'TP2 1.414'
t_tp3 = isAr ? 'هدف3 1.618' : 'TP3 1.618'
t_tp4 = isAr ? 'هدف4 2.000' : 'TP4 2.000'
t_tp5 = isAr ? 'هدف5 2.618' : 'TP5 2.618'
t_htf = isAr ? 'فريم أعلى' : 'HTF'
t_thisTf = isAr ? 'هذا الفريم' : 'This TF'
t_setup = isAr ? 'السيتب' : 'Setup'
t_filter = isAr ? 'الفلتر' : 'Filter'
t_on = isAr ? 'تشغيل' : 'ON'
t_off = isAr ? 'إيقاف' : 'OFF'
t_bull = isAr ? 'صاعد ▲' : 'BULL ▲'
t_bear = isAr ? 'هابط ▼' : 'BEAR ▼'
t_wait = isAr ? 'انتظار' : 'Waiting'
t_sameTf = isAr ? 'إيقاف / نفس الفريم' : 'Off / Same TF'
t_longOk = isAr ? 'سيتب شراء' : 'Long Setup'
t_shortOk = isAr ? 'سيتب بيع' : 'Short Setup'
t_longBlock = isAr ? 'شراء محظور' : 'Long Blocked'
t_shortBlock = isAr ? 'بيع محظور' : 'Short Blocked'

// ═══════════════════════════════════════
// Structure engine
// ═══════════════════════════════════════
f_bias(_useClose, _len) =>
    _ph = ta.pivothigh(high, _len, _len)
    _pl = ta.pivotlow(low, _len, _len)
    var float _lastSH = na
    var float _lastSL = na
    var int _bias = 0
    if not na(_ph)
        _lastSH := _ph
        _lastSH
    if not na(_pl)
        _lastSL := _pl
        _lastSL
    _brkBull = _useClose ? close : high
    _brkBear = _useClose ? close : low
    _bull = not na(_lastSH) and _brkBull > _lastSH and _bias <= 0
    _bear = not na(_lastSL) and _brkBear < _lastSL and _bias >= 0
    if _bull
        _bias := 1
        _bias
    if _bear
        _bias := -1
        _bias
    [_bias, _bull, _bear, _lastSH, _lastSL]

[bias, bullCHoCH, bearCHoCH, lastSH, lastSL] = f_bias(useClose, swingLen)

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)
var int lastSHbar = na
var int lastSLbar = na
if not na(ph)
    lastSHbar := bar_index[swingLen]
    lastSHbar
if not na(pl)
    lastSLbar := bar_index[swingLen]
    lastSLbar

// ═══════════════════════════════════════
// Higher timeframe bias
// ═══════════════════════════════════════
f_htf_bias() =>
    [b, _bu, _be, _sh, _sl] = f_bias(useClose, swingLen)
    b

sameTF = htfTF == '' or htfTF == timeframe.period
htfBiasRaw = request.security(syminfo.tickerid, htfTF, f_htf_bias(), barmerge.gaps_off, barmerge.lookahead_off)
htfBias = useHTF and not sameTF ? htfBiasRaw : bias

htfAlignedLong = not useHTF or sameTF or htfBias == 1
htfAlignedShort = not useHTF or sameTF or htfBias == -1

validLong = bullCHoCH and htfAlignedLong
validShort = bearCHoCH and htfAlignedShort

// ═══════════════════════════════════════
// Last aligned CHoCH swing
// ═══════════════════════════════════════
var float fibLow = na
var float fibHigh = na
var int fibStartBar = na
var int lastDir = 0

if validLong and not na(lastSL)
    fibLow := lastSL
    fibHigh := high
    fibStartBar := lastSLbar
    lastDir := 1
    lastDir

if validShort and not na(lastSH)
    fibHigh := lastSH
    fibLow := low
    fibStartBar := lastSHbar
    lastDir := -1
    lastDir

if lastDir == 1 and not na(fibHigh)
    fibHigh := math.max(fibHigh, high)
    fibHigh
if lastDir == -1 and not na(fibLow)
    fibLow := math.min(fibLow, low)
    fibLow

// ═══════════════════════════════════════
// CHoCH labels
// ═══════════════════════════════════════
if bullCHoCH and (showAllCHoCH or validLong)
    txt = validLong ? t_chochUp : t_chochUpX
    label.new(bar_index, low, txt, style = label.style_label_up, color = validLong ? bullColor : color.new(bullColor, 60), textcolor = color.white, size = size.small)
    line.new(lastSHbar, lastSH, bar_index, lastSH, color = validLong ? bullColor : color.new(bullColor, 70), width = validLong ? 2 : 1, style = validLong ? line.style_solid : line.style_dotted)

if bearCHoCH and (showAllCHoCH or validShort)
    txt = validShort ? t_chochDn : t_chochDnX
    label.new(bar_index, high, txt, style = label.style_label_down, color = validShort ? bearColor : color.new(bearColor, 60), textcolor = color.white, size = size.small)
    line.new(lastSLbar, lastSL, bar_index, lastSL, color = validShort ? bearColor : color.new(bearColor, 70), width = validShort ? 2 : 1, style = validShort ? line.style_solid : line.style_dotted)

// ═══════════════════════════════════════
// Fibonacci + targets
// ═══════════════════════════════════════
var array<line> fibLs = array.new_line()
var array<label> fibLbs = array.new_label()
var box zBox = na
var line slLine = na

f_clearFib() =>
    if array.size(fibLs) > 0
        for i = 0 to array.size(fibLs) - 1 by 1
            line.delete(array.get(fibLs, i))
        array.clear(fibLs)
    if array.size(fibLbs) > 0
        for i = 0 to array.size(fibLbs) - 1 by 1
            label.delete(array.get(fibLbs, i))
        array.clear(fibLbs)
    if not na(zBox)
        box.delete(zBox)
    if not na(slLine)
        line.delete(slLine)

f_px(val) =>
    str.tostring(val, format.mintick)

drawNow = showFib and not na(fibLow) and not na(fibHigh) and fibHigh != fibLow and (validLong or validShort)
if hideAgainst
    drawNow := drawNow and (lastDir == 1 and htfAlignedLong or lastDir == -1 and htfAlignedShort)
    drawNow

if drawNow
    f_clearFib()
    rng = fibHigh - fibLow
    levels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
    cols = array.from(color.gray, color.red, color.orange, color.yellow, color.lime, color.aqua, color.gray)

    isLong = lastDir == 1
    for i = 0 to array.size(levels) - 1 by 1
        lv = array.get(levels, i)
        px = isLong ? fibHigh - rng * lv : fibLow + rng * lv
        ln = line.new(fibStartBar, px, bar_index + extendBars, px, color = array.get(cols, i), width = lv == 0.5 or lv == 0.618 ? 2 : 1, style = line.style_dotted)
        array.push(fibLs, ln)
        lb = label.new(bar_index + extendBars, px, str.tostring(lv) + '  ' + f_px(px), style = label.style_label_left, color = color.new(color.black, 70), textcolor = array.get(cols, i), size = size.small)
        array.push(fibLbs, lb)

    if showZone
        z1 = isLong ? fibHigh - rng * 0.5 : fibLow + rng * 0.5
        z2 = isLong ? fibHigh - rng * 0.618 : fibLow + rng * 0.618
        zBox := box.new(fibStartBar, z1, bar_index + extendBars, z2, bgcolor = isLong ? zoneBull : zoneBear, border_color = color.new(color.white, 100))
        zBox

    slPx = isLong ? fibLow : fibHigh
    slLine := line.new(fibStartBar, slPx, bar_index + extendBars, slPx, color = slColor, width = 2, style = line.style_solid)
    slLb = label.new(bar_index + 2, slPx, t_sl + '  ' + f_px(slPx), style = isLong ? label.style_label_up : label.style_label_down, color = slColor, textcolor = color.white, size = size.small)
    array.push(fibLbs, slLb)

    if showTP
        tps = array.from(1.272, 1.414, 1.618, 2.000, 2.618)
        tpShow = array.from(showTP1272, showTP1414, showTP1618, showTP2000, showTP2618)
        tpCols = array.from(tp1272Color, tp1414Color, tp1618Color, tp2000Color, tp2618Color)
        tpNames = array.from(t_tp1, t_tp2, t_tp3, t_tp4, t_tp5)
        for i = 0 to 4 by 1
            if array.get(tpShow, i)
                ext = array.get(tps, i)
                tpx = isLong ? fibLow + rng * ext : fibHigh - rng * ext
                tln = line.new(fibStartBar, tpx, bar_index + extendBars, tpx, color = array.get(tpCols, i), width = 2, style = line.style_solid)
                array.push(fibLs, tln)
                tlb = label.new(bar_index + extendBars, tpx, array.get(tpNames, i) + '  ' + f_px(tpx), style = label.style_label_left, color = array.get(tpCols, i), textcolor = color.white, size = size.small)
                array.push(fibLbs, tlb)

// ═══════════════════════════════════════
// HTF background
// ═══════════════════════════════════════
bgcolor(showHTFbg and useHTF and not sameTF ? htfBias == 1 ? color.new(bullColor, 93) : htfBias == -1 ? color.new(bearColor, 93) : na : na)

// ═══════════════════════════════════════
// Dashboard
// ═══════════════════════════════════════
var table tb = table.new(position.top_right, 2, 4, bgcolor = color.new(#1e1e1e, 15), border_width = 1)
if barstate.islast
    htfTxt = not useHTF or sameTF ? t_sameTf : htfBias == 1 ? t_bull : htfBias == -1 ? t_bear : t_wait
    htfCol = not useHTF or sameTF ? color.gray : htfBias == 1 ? bullColor : htfBias == -1 ? bearColor : color.gray
    setupTxt = lastDir == 1 ? htfAlignedLong ? t_longOk : t_longBlock : lastDir == -1 ? htfAlignedShort ? t_shortOk : t_shortBlock : t_wait
    setupCol = lastDir == 1 and htfAlignedLong ? bullColor : lastDir == -1 and htfAlignedShort ? bearColor : color.gray

    table.cell(tb, 0, 0, t_htf + ' ' + (sameTF or not useHTF ? '' : htfTF), text_color = color.gray, text_size = size.small)
    table.cell(tb, 1, 0, htfTxt, text_color = htfCol, text_size = size.small)
    table.cell(tb, 0, 1, t_thisTf, text_color = color.gray, text_size = size.small)
    table.cell(tb, 1, 1, bias == 1 ? t_bull : bias == -1 ? t_bear : '—', text_color = bias == 1 ? bullColor : bias == -1 ? bearColor : color.gray, text_size = size.small)
    table.cell(tb, 0, 2, t_setup, text_color = color.gray, text_size = size.small)
    table.cell(tb, 1, 2, setupTxt, text_color = setupCol, text_size = size.small)
    table.cell(tb, 0, 3, t_filter, text_color = color.gray, text_size = size.small)
    table.cell(tb, 1, 3, useHTF and not sameTF ? t_on : t_off, text_color = useHTF and not sameTF ? color.aqua : color.gray, text_size = size.small)

alertcondition(validLong, 'Long CHoCH + HTF / شراء مع الفريم الأعلى', 'Bullish CHoCH aligned with HTF. Watch 0.5-0.618 buy zone. | CHoCH صاعد مع اتجاه الفريم الأعلى — راقب فيبو 0.5-0.618 للشراء')
alertcondition(validShort, 'Short CHoCH + HTF / بيع مع الفريم الأعلى', 'Bearish CHoCH aligned with HTF. Watch 0.5-0.618 sell zone. | CHoCH هابط مع اتجاه الفريم الأعلى — راقب فيبو 0.5-0.618 للبيع')
alertcondition(bullCHoCH and not validLong, 'Counter-trend bullish CHoCH / CHoCH صاعد مخالف', 'Bullish CHoCH but HTF is bearish. | CHoCH صاعد لكن الفريم الأعلى هابط')
alertcondition(bearCHoCH and not validShort, 'Counter-trend bearish CHoCH / CHoCH هابط مخالف', 'Bearish CHoCH but HTF is bullish. | CHoCH هابط لكن الفريم الأعلى صاعد')
````
