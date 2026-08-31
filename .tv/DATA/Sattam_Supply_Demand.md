<!-- tradingview-pine-id: PUB;adada3b68c2d48d6b049ed84c2c76330 -->
<!-- tradingviewscripts-format: 1 -->
# Sattam Supply | Demand

Source: https://www.tradingview.com/script/V7qt246z-Sattam-Supply-Demand/

## Description

SATTAM Supply | Demand Zones (Multi-Timeframe)

OVERVIEW

This indicator maps supply and demand zones from a timeframe you choose and draws them on your current chart. Instead of marking every swing point, it only accepts a swing that is followed by a genuine displacement move away from that level, measured against volatility (ATR). The goal is a chart with a small number of meaningful zones rather than dozens of overlapping boxes. Zones are drawn as boxes with a 50% midline, extended to the right until price invalidates them.

HOW A ZONE IS CREATED

A zone is created in two stages.

1) Pivot detection
The script looks for a pivot high (for supply) or a pivot low (for demand) on the selected timeframe. A pivot needs "Pivot Length" bars on each side to confirm, so the swing is a completed structural turning point and not a temporary extreme.

2) Displacement confirmation
A confirmed pivot is not enough on its own. After the pivot confirms, the script watches the next few bars ("Displacement Window") for a decisive close away from the level:
- Supply: a close below the pivot candle's low by more than ATR(14) x displacement factor
- Demand: a close above the pivot candle's high by more than ATR(14) x displacement factor

The ATR value used is the one captured at the pivot bar itself, so the confirmation threshold reflects the volatility that existed when the level formed, not the volatility at the moment of the breakout. If no qualifying close appears inside the window, the pivot is discarded and no zone is drawn.

The displacement factor is derived from the "Sensitivity" input: max(0.10, 1.15 - Sensitivity x 0.10). Higher sensitivity means a smaller required move, which produces more zones. Lower sensitivity demands a stronger reaction and produces fewer, more selective zones.

ZONE BOUNDARIES

Each zone is anchored at the pivot candle's own time, so the box starts where the level actually formed.
- Supply: the top is the pivot high, the bottom is the pivot candle's body top, min(open, close).
- Demand: the bottom is the pivot low, the top is the pivot candle's body bottom, max(open, close).

If that body-to-wick distance is unusually thin, the height is expanded to a volatility-based minimum (ATR at the pivot x width factor) so the zone stays usable on quiet candles. The "Width" input scales that minimum.

ZONE MANAGEMENT

Overlap filter: a new zone is rejected if it overlaps an existing zone by more than 45% of the smaller zone's height, or if it forms close in time with a nearly identical midpoint. This prevents clusters of near-duplicate boxes around the same level.
Zone limit: "Max Zones Per Side" caps how many supply and demand zones stay on the chart. When the limit is reached, the oldest zone is removed.
Invalidation: with "Hide Invalidated Zones" enabled, a supply zone is deleted after a close above its top and a demand zone after a close below its bottom. Disable it to keep broken zones visible for context.
Extension: active zones extend to the right by "Zones Offset" bars of the current chart so they stay visible ahead of price.

REPAINTING

Zones are committed only from closed bars of the selected timeframe. When a new higher-timeframe bar opens, the script reads the signal produced by the bar that just closed, and request.security is called with lookahead_off. A zone that has been drawn will not move or disappear on a later refresh, and no zone appears from a still-forming higher-timeframe bar.

Because of this, a zone always appears with a delay of at least "Pivot Length" bars plus the displacement bars on the selected timeframe. That delay is inherent to pivot-based confirmation.

SETTINGS

Source
- Timeframe: the timeframe the zones are calculated from (default 4H). Leave empty to use the chart timeframe.
- Pivot Length: bars required on each side of a swing for it to count as a pivot.
- Sensitivity: 1 to 10. Higher values loosen the displacement filter and allow more zones.
- Displacement Window: how many bars after a pivot confirms the script keeps waiting for a displacement close before discarding the pivot.

Zones
- Width: scales the volatility-based minimum zone thickness.
- Zones Offset: how far zones extend to the right.
- Max Zones Per Side: maximum simultaneous supply and demand zones.
- Hide Invalidated Zones: remove zones after price closes through them.

Style: fill and border colors for supply and demand, plus midline style (dashed, dotted, solid).

Timeframe Label: an on-chart label showing which timeframe the zones come from, with position, size and color options.

HOW TO USE IT

Set the Timeframe higher than your chart timeframe, for example 4H zones on a 15m chart, so you keep a structural reference while working on a lower timeframe. Zones mark areas where an imbalance formed and price left the level quickly. They are areas of interest for observing price behaviour, not signals in themselves.

Reduce Sensitivity and raise Pivot Length on noisy or lower timeframes if too many zones appear. Raise Sensitivity on higher timeframes or slow instruments if too few appear.

ALERTS

Two alert conditions are available: New Supply Zone and New Demand Zone. Both fire when a zone is confirmed from a closed higher-timeframe bar.

NOTES AND LIMITATIONS

- The indicator describes structure that has already formed. It does not predict direction and produces no buy or sell signals.
- Zone quality depends on the selected timeframe and instrument. Settings that work on one market will not automatically suit another.
- Very illiquid symbols or timeframes with wide gaps may produce fewer valid displacement confirmations.

This script is published for educational and analytical purposes only. It is not financial advice and does not guarantee any result. Always test any tool on your own instruments and timeframes before relying on it.

مؤشر مناطق العرض والطلب - متعدد الفريمات

نظرة عامة

يرسم المؤشر مناطق العرض والطلب من فريم تختاره أنت ويعرضها على الشارت الحالي. بدلاً من تعليم كل قمة وقاع، لا يقبل المؤشر السوينق إلا إذا تبعته حركة اندفاع حقيقية بعيداً عن المستوى، تُقاس نسبةً إلى تذبذب السوق عبر ATR. الهدف شارت فيه عدد قليل من المناطق المهمة بدل عشرات الصناديق المتداخلة. تُرسم المنطقة على شكل صندوق مع خط منتصف عند 50% ويمتد لليمين حتى يُبطله السعر.

كيف تتكوّن المنطقة

المرحلة الأولى: البحث عن قمة بيفوت للعرض أو قاع بيفوت للطلب على الفريم المختار. يحتاج البيفوت إلى عدد الشموع المحدد في Pivot Length على كل جانب حتى يتأكد، حتى يكون نقطة انعكاس بنيوية مكتملة لا مجرد طرف مؤقت.

المرحلة الثانية: البيفوت وحده لا يكفي. بعد تأكده يراقب المؤشر الشموع التالية خلال Displacement Window بحثاً عن إغلاق حاسم بعيداً عن المستوى:
- العرض: إغلاق أسفل قاع شمعة البيفوت بمسافة أكبر من ATR(14) مضروباً في معامل الاندفاع.
- الطلب: إغلاق أعلى قمة شمعة البيفوت بمسافة أكبر من ATR(14) مضروباً في معامل الاندفاع.

قيمة ATR المستخدمة هي القيمة المسجّلة عند شمعة البيفوت نفسها، أي أن حد التأكيد يعكس التذبذب الذي كان قائماً وقت تكوّن المستوى لا وقت الاختراق. وإذا لم يظهر إغلاق مؤهّل داخل النافذة يُلغى البيفوت ولا تُرسم منطقة.

معامل الاندفاع مشتق من إدخال Sensitivity بالمعادلة: max(0.10, 1.15 - Sensitivity x 0.10). كلما ارتفعت الحساسية قلّت المسافة المطلوبة وزاد عدد المناطق، وكلما انخفضت تطلّب المؤشر رد فعل أقوى وأعطى مناطق أقل وأكثر انتقائية.

حدود المنطقة

المنطقة مثبّتة على وقت شمعة البيفوت نفسها، فيبدأ الصندوق من حيث تكوّن المستوى فعلاً.
- العرض: القمة هي قمة البيفوت، والقاع هو أعلى جسم الشمعة أي min(open, close).
- الطلب: القاع هو قاع البيفوت، والقمة هي أسفل جسم الشمعة أي max(open, close).

وإذا كانت هذه المسافة رفيعة بشكل غير معتاد يُوسَّع الارتفاع إلى حد أدنى مبني على ATR عند البيفوت مضروباً في معامل العرض، حتى تبقى المنطقة قابلة للاستخدام على الشموع الهادئة. ويتحكم إدخال Width في هذا الحد الأدنى.

إدارة المناطق

فلتر التداخل: تُرفض أي منطقة جديدة تتداخل مع منطقة قائمة بأكثر من 45% من ارتفاع الأصغر بينهما، أو تتكوّن قريباً منها زمنياً بمنتصف شبه مطابق. هذا يمنع تراكم صناديق شبه مكررة حول المستوى نفسه.
حد المناطق: يحدّد Max Zones Per Side أقصى عدد للمناطق على كل جهة، وتُحذف الأقدم عند تجاوز الحد.
الإبطال: مع تفعيل Hide Invalidated Zones تُحذف منطقة العرض بعد إغلاق فوق قمتها، ومنطقة الطلب بعد إغلاق تحت قاعها. ويمكن تعطيله للإبقاء على المناطق المكسورة كسياق.
الامتداد: تمتد المناطق النشطة لليمين بمقدار Zones Offset من شموع الشارت الحالي لتبقى ظاهرة أمام السعر.

إعادة الرسم

تُعتمد المناطق من الشموع المغلقة فقط على الفريم المختار. عند فتح شمعة جديدة على الفريم الأعلى يقرأ المؤشر الإشارة الناتجة عن الشمعة التي أُغلقت للتو، وتُستدعى request.security بخيار lookahead_off. لذلك المنطقة بعد ظهورها لا تتحرك ولا تختفي عند التحديث، ولا تظهر أي منطقة من شمعة لم تُغلق بعد.

ونتيجة لذلك تظهر المنطقة متأخرة بمقدار شموع البيفوت زائد شموع الاندفاع على الفريم المختار، وهو تأخير ملازم لأي تأكيد مبني على البيفوت.

الإعدادات

المصدر
- Timeframe: الفريم الذي تُحسب منه المناطق، والافتراضي 4 ساعات. اتركه فارغاً لاستخدام فريم الشارت.
- Pivot Length: عدد الشموع المطلوبة على كل جانب لاعتماد البيفوت.
- Sensitivity: من 1 إلى 10، والقيم الأعلى تخفف فلتر الاندفاع وتسمح بمناطق أكثر.
- Displacement Window: عدد الشموع التي يواصل المؤشر خلالها انتظار إغلاق الاندفاع بعد تأكد البيفوت قبل إلغائه.

المناطق
- Width: يتحكم في الحد الأدنى لسماكة المنطقة المبني على التذبذب.
- Zones Offset: مدى امتداد المناطق لليمين.
- Max Zones Per Side: أقصى عدد متزامن لمناطق العرض والطلب.
- Hide Invalidated Zones: حذف المناطق بعد إغلاق السعر خلالها.

الستايل: ألوان التعبئة والحدود للعرض والطلب، ونمط خط المنتصف متقطع أو منقّط أو متصل.

مؤشر الفريم: لوحة صغيرة على الشارت تبيّن الفريم الذي جاءت منه المناطق، مع خيارات الموضع والحجم واللون.

طريقة الاستخدام

اجعل الفريم في الإعدادات أعلى من فريم الشارت، مثل مناطق 4 ساعات على شارت 15 دقيقة، لتحتفظ بمرجع بنيوي وأنت تعمل على فريم أصغر. المناطق تعلّم أماكن تكوّن اختلال في التوازن غادر السعر مستواها بسرعة، وهي مناطق اهتمام لمراقبة سلوك السعر لا إشارات بحد ذاتها.

خفّض Sensitivity وارفع Pivot Length على الفريمات الصغيرة أو الأسواق المزعجة إذا ظهرت مناطق كثيرة، وارفع Sensitivity على الفريمات الكبيرة أو الأدوات البطيئة إذا كانت المناطق قليلة.

التنبيهات

تنبيهان متاحان: منطقة عرض جديدة، ومنطقة طلب جديدة، ويُطلقان عند تأكيد المنطقة من شمعة مغلقة على الفريم الأعلى.

ملاحظات وحدود

- المؤشر يصف بنية سعرية تكوّنت بالفعل، ولا يتنبأ بالاتجاه ولا يعطي إشارات شراء أو بيع.
- جودة المناطق تعتمد على الفريم والأداة المختارة، والإعدادات التي تناسب سوقاً لا تناسب غيره تلقائياً.
- الرموز ضعيفة السيولة أو الفريمات ذات الفجوات الواسعة قد تعطي تأكيدات اندفاع أقل.

يُنشر هذا المؤشر لأغراض تعليمية وتحليلية فقط، وليس نصيحة مالية ولا يضمن أي نتيجة. اختبر أي أداة على أدواتك وفريماتك قبل الاعتماد عليها.

---

## Source Code

````pine
//@version=6
indicator("Sattam Supply | Demand", overlay=true, max_boxes_count=300, max_lines_count=300, max_labels_count=100)

groupSource = "Source"
groupZones  = "Zones"
groupStyle  = "Style"
groupLabel  = "Timeframe Label"

zoneTfInput     = input.timeframe("240", "Timeframe", group=groupSource)
pivotLen        = input.int(4, "Pivot Length", minval=1, maxval=20, group=groupSource, tooltip="How many candles are required on each side to confirm a pivot on the selected timeframe.")
sensitivity     = input.int(6, "Sensitivity", minval=1, maxval=10, group=groupSource, tooltip="Higher values loosen the displacement filter and allow more zones.")
displaceWindow  = input.int(3, "Displacement Window", minval=0, maxval=20, group=groupSource, tooltip="How many bars after a pivot confirms to keep watching for a displacement close before the pivot is discarded.")
widthInput      = input.float(1.0, "Width", minval=0.3, maxval=3.0, step=0.1, group=groupZones, tooltip="Controls zone thickness.")
zonesOffset     = input.int(250, "Zones Offset", minval=20, maxval=3000, group=groupZones, tooltip="How far zones extend to the right in current-chart bars.")
maxZonesPerSide = input.int(8, "Max Zones Per Side", minval=1, maxval=20, group=groupZones)
hideMitigated   = input.bool(true, "Hide Invalidated Zones", group=groupZones, tooltip="Deletes a supply zone after a close above it, or a demand zone after a close below it.")

supplyFill   = input.color(color.new(color.rgb(226, 61, 103), 58), "Supply Fill", group=groupStyle)
supplyBorder = input.color(color.rgb(226, 61, 103), "Supply Border", group=groupStyle)
demandFill   = input.color(color.new(color.rgb(33, 191, 214), 60), "Demand Fill", group=groupStyle)
demandBorder = input.color(color.rgb(33, 191, 214), "Demand Border", group=groupStyle)
midlineStyle = input.string("Dashed", "Midline Style", options=["Dashed", "Dotted", "Solid"], group=groupStyle)

showTfLabel  = input.bool(true, "Show Timeframe Label", group=groupLabel)
labelPosY    = input.string("Top", "Label Vertical Position", options=["Top", "Bottom"], group=groupLabel)
labelPosX    = input.string("Right", "Label Horizontal Position", options=["Left", "Right"], group=groupLabel)
labelSizeInp = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=groupLabel)
labelBg      = input.color(color.new(color.black, 35), "Label Background", group=groupLabel)
labelTextCol = input.color(color.white, "Label Text", group=groupLabel)

zoneTf = zoneTfInput == "" ? timeframe.period : zoneTfInput

lineStyleFromInput(styleInput) =>
    styleInput == "Dotted" ? line.style_dotted : styleInput == "Solid" ? line.style_solid : line.style_dashed

labelSizeFromInput(sizeInput) =>
    sizeInput == "Tiny" ? size.tiny : sizeInput == "Small" ? size.small : sizeInput == "Large" ? size.large : size.normal

tfLabelText(tf) =>
    secs = timeframe.in_seconds(tf)
    secs >= 86400 and secs % 604800 == 0 ? str.tostring(int(secs / 604800)) + "W" :
     secs >= 86400 ? str.tostring(int(secs / 86400)) + "D" :
     secs >= 3600 ? str.tostring(int(secs / 3600)) + "H" :
     secs >= 60 ? str.tostring(int(secs / 60)) + "m" :
     tf

extendMs = math.max(timeframe.in_seconds(timeframe.period), 60) * zonesOffset * 1000
midStyle = lineStyleFromInput(midlineStyle)
labelSize = labelSizeFromInput(labelSizeInp)

var box[] supplyBoxes = array.new_box()
var line[] supplyMids = array.new_line()
var float[] supplyTops = array.new_float()
var float[] supplyBottoms = array.new_float()
var int[] supplyLeftTimes = array.new_int()

var box[] demandBoxes = array.new_box()
var line[] demandMids = array.new_line()
var float[] demandTops = array.new_float()
var float[] demandBottoms = array.new_float()
var int[] demandLeftTimes = array.new_int()

deleteZone(boxes, mids, tops, bottoms, lefts, idx) =>
    bx = array.get(boxes, idx)
    md = array.get(mids, idx)
    box.delete(bx)
    line.delete(md)
    array.remove(boxes, idx)
    array.remove(mids, idx)
    array.remove(tops, idx)
    array.remove(bottoms, idx)
    array.remove(lefts, idx)

zoneExists(tops, bottoms, lefts, top, bottom, leftTime) =>
    exists = false
    if array.size(tops) > 0
        for i = 0 to array.size(tops) - 1
            oldTop = array.get(tops, i)
            oldBottom = array.get(bottoms, i)
            oldLeft = array.get(lefts, i)
            overlapTop = math.min(oldTop, top)
            overlapBottom = math.max(oldBottom, bottom)
            overlap = overlapTop - overlapBottom
            minHeight = math.min(oldTop - oldBottom, top - bottom)
            closeInTime = math.abs(oldLeft - leftTime) <= timeframe.in_seconds(zoneTf) * 1000 * (pivotLen + 2)
            if overlap > minHeight * 0.45 or (closeInTime and math.abs((oldTop + oldBottom) * 0.5 - (top + bottom) * 0.5) <= minHeight * 0.6)
                exists := true
                break
    exists

trimToLimit(boxes, mids, tops, bottoms, lefts, maxCount) =>
    while array.size(boxes) > maxCount
        lastIdx = array.size(boxes) - 1
        deleteZone(boxes, mids, tops, bottoms, lefts, lastIdx)

addZone(isSupply, top, bottom, leftTime) =>
    if not na(top) and not na(bottom) and top > bottom
        targetBoxes = isSupply ? supplyBoxes : demandBoxes
        targetMids = isSupply ? supplyMids : demandMids
        targetTops = isSupply ? supplyTops : demandTops
        targetBottoms = isSupply ? supplyBottoms : demandBottoms
        targetLefts = isSupply ? supplyLeftTimes : demandLeftTimes
        if not zoneExists(targetTops, targetBottoms, targetLefts, top, bottom, leftTime)
            fillColor = isSupply ? supplyFill : demandFill
            borderColor = isSupply ? supplyBorder : demandBorder
            midColor = color.new(borderColor, 0)
            rightTime = time + extendMs
            bx = box.new(leftTime, top, rightTime, bottom, xloc=xloc.bar_time, bgcolor=fillColor, border_color=borderColor, border_width=1)
            md = line.new(leftTime, (top + bottom) * 0.5, rightTime, (top + bottom) * 0.5, xloc=xloc.bar_time, color=color.new(midColor, 5), style=midStyle, width=1)
            array.unshift(targetBoxes, bx)
            array.unshift(targetMids, md)
            array.unshift(targetTops, top)
            array.unshift(targetBottoms, bottom)
            array.unshift(targetLefts, leftTime)
            trimToLimit(targetBoxes, targetMids, targetTops, targetBottoms, targetLefts, maxZonesPerSide)

maintainZones(boxes, mids, tops, bottoms, lefts, isSupply) =>
    if array.size(boxes) > 0
        for i = array.size(boxes) - 1 to 0
            top = array.get(tops, i)
            bottom = array.get(bottoms, i)
            bx = array.get(boxes, i)
            md = array.get(mids, i)
            rightTime = time + extendMs
            box.set_right(bx, rightTime)
            line.set_x2(md, rightTime)
            invalidated = isSupply ? close > top : close < bottom
            if hideMitigated and invalidated
                deleteZone(boxes, mids, tops, bottoms, lefts, i)

widthFactor = 0.12 + widthInput * 0.18
// Linear across the full 1..10 range (no clamping until the very top): higher
// sensitivity => smaller required displacement => more zones.
displacementFactor = math.max(0.10, 1.15 - sensitivity * 0.10)

// Runs on the selected timeframe. A pivot is stored the moment it confirms,
// then displacement is watched for over the next `displaceWindow` bars; the
// pivot is discarded if no qualifying close appears in that window. Every
// ATR-derived measure uses the ATR captured AT the pivot, so the displacement
// filter and the zone height share a single volatility reference.
f_zones() =>
    atr = ta.atr(14)
    ph = ta.pivothigh(high, pivotLen, pivotLen)
    pl = ta.pivotlow(low, pivotLen, pivotLen)

    // ---- Supply: pending pivot-high state ----
    var float sHigh    = na
    var float sLow     = na
    var float sBodyLow = na
    var float sAtr     = na
    var int   sTime    = na
    var int   sCount   = 0
    if not na(ph)
        sHigh    := high[pivotLen]
        sLow     := low[pivotLen]
        sBodyLow := math.min(open[pivotLen], close[pivotLen])
        sAtr     := atr[pivotLen]
        sTime    := time[pivotLen]
        sCount   := displaceWindow + 1
    supplySig   = false
    supplyTopV  = float(na)
    supplyBotV  = float(na)
    supplyLeftV = int(na)
    if sCount > 0 and not na(sHigh)
        if close < sLow - sAtr * displacementFactor
            baseHeight = math.max(sHigh - sBodyLow, syminfo.mintick * 4)
            zoneHeight = math.max(baseHeight, sAtr * widthFactor)
            supplySig   := true
            supplyTopV  := sHigh
            supplyBotV  := sHigh - zoneHeight
            supplyLeftV := sTime
            sCount := 0
            sHigh  := na
        else
            sCount := sCount - 1

    // ---- Demand: pending pivot-low state ----
    var float dLow      = na
    var float dHigh     = na
    var float dBodyHigh = na
    var float dAtr      = na
    var int   dTime     = na
    var int   dCount    = 0
    if not na(pl)
        dLow      := low[pivotLen]
        dHigh     := high[pivotLen]
        dBodyHigh := math.max(open[pivotLen], close[pivotLen])
        dAtr      := atr[pivotLen]
        dTime     := time[pivotLen]
        dCount    := displaceWindow + 1
    demandSig   = false
    demandTopV  = float(na)
    demandBotV  = float(na)
    demandLeftV = int(na)
    if dCount > 0 and not na(dLow)
        if close > dHigh + dAtr * displacementFactor
            baseHeight = math.max(dBodyHigh - dLow, syminfo.mintick * 4)
            zoneHeight = math.max(baseHeight, dAtr * widthFactor)
            demandSig   := true
            demandTopV  := dLow + zoneHeight
            demandBotV  := dLow
            demandLeftV := dTime
            dCount := 0
            dLow   := na
        else
            dCount := dCount - 1

    [supplySig, supplyTopV, supplyBotV, supplyLeftV, demandSig, demandTopV, demandBotV, demandLeftV]

[supplySignal, supplyTop, supplyBottom, supplyLeftTime, demandSignal, demandTop, demandBottom, demandLeftTime] = request.security(
    syminfo.tickerid,
    zoneTf,
    f_zones(),
    barmerge.gaps_off,
    barmerge.lookahead_off
)

// Act only on values from a CLOSED higher-timeframe bar. When a new HTF bar
// opens, the just-closed bar's confirmed signal is the [1] value, so the zone
// never repaints on the still-forming HTF bar.
htfNewBar = ta.change(time(zoneTf)) != 0
newSupplyZone = htfNewBar and supplySignal[1] and not na(supplyLeftTime[1])
newDemandZone = htfNewBar and demandSignal[1] and not na(demandLeftTime[1])

if newSupplyZone
    addZone(true, supplyTop[1], supplyBottom[1], int(supplyLeftTime[1]))

if newDemandZone
    addZone(false, demandTop[1], demandBottom[1], int(demandLeftTime[1]))

maintainZones(supplyBoxes, supplyMids, supplyTops, supplyBottoms, supplyLeftTimes, true)
maintainZones(demandBoxes, demandMids, demandTops, demandBottoms, demandLeftTimes, false)

var table tfLabel = table.new(
    labelPosY == "Top" ? (labelPosX == "Right" ? position.top_right : position.top_left) : (labelPosX == "Right" ? position.bottom_right : position.bottom_left),
    1,
    1
)

if barstate.islast
    if showTfLabel
        table.cell(tfLabel, 0, 0, tfLabelText(zoneTf), text_color=labelTextCol, bgcolor=labelBg, text_size=labelSize)
    else
        table.cell(tfLabel, 0, 0, "", text_color=color.new(labelTextCol, 100), bgcolor=color.new(labelBg, 100), text_size=labelSize)

alertcondition(newSupplyZone, "New Supply Zone", "A new supply zone was detected.")
alertcondition(newDemandZone, "New Demand Zone", "A new demand zone was detected.")
````
