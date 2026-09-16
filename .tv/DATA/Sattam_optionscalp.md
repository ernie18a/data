<!-- tradingview-pine-id: PUB;f84ef09dbbaf41efba7d0e9982dc5fc5 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sattam | option-scalp

Source: https://www.tradingview.com/script/jmnbhBG1-Sattam-option-scalp/

## Description

Volatility Projection Zones

Every 52 bars the indicator takes a reading of the market and projects where
price could travel next, based on how volatile the market actually is right now.

WORKS ON EVERY MARKET — AND HOLDS UP ON OPTIONS

There is not a single fixed value anywhere in this script: no pip counts, no
point targets, no price assumptions. Every distance it draws is derived from the
instrument's own volatility, so it behaves the same way on futures, forex,
indices, crypto, stocks — and on options contracts, which is where most
ATR-based tools quietly fall apart.

Options are a hostile case: premiums move in cents, a contract can lose half its
value in three bars, sessions are full of gaps, and plenty of bars print with no
trade at all. A pure ATR projection lags badly through moves like that and draws
targets far too tight. This script handles it by taking the LARGER of two
measures — the ATR projection, or the range of the anchor window itself. On
liquid futures the ATR is always the larger one and the floor never shows; on an
option, when a window holds a collapse, the window wins and the projection stays
honest.

HOW IT WORKS

At each cycle the script looks at the last 3 bars and finds the extreme that
price has moved furthest away from — if price is sitting near the top of that
little range, the low becomes the anchor, and vice versa. From that anchor it
projects a distance equal to 3 x ATR(14), or the range of those 3 bars when that
is wider.

Four lines are drawn per cycle:

  - Two thick lines  — the anchor and the full projection target
  - Two thin lines   — the 50% and 61.8% marks in between

Each set extends 49 bars, stopping just before the next cycle begins, and the
last 8 sets stay on the chart.

HOW TO READ IT

The direction of the projection is the cycle's bias. A set projecting upward
means the anchor sits below price as support, with the levels above as upside
reference. The two thin lines are the natural partial targets; the far thick
line is the full measured move.

Because the projection scales with volatility, the levels widen in fast
conditions and tighten in quiet ones automatically.

SETTINGS

  Cycle length     - bars between projections (default 52)
  Anchor window    - bars used to pick the anchor (default 3)
  ATR length/mult  - the projection distance (default 14 / 3.0)
  Inner ratios     - the two intermediate levels (0.5 / 0.618)
  Cycle anchor     - where the cycle starts counting: Session, Week, or a
                     manual phase
  Display          - colors, widths, line length, sets kept

NOTES

This is a levels framework, not a signal system. It draws on every cycle
regardless of trend or range conditions, and it has no entry filter of its own —
combine it with your own read of structure and context.

Not financial advice. Test on your own instruments and timeframes before relying
on it.

خطوط الهدف حسب حركة السوق

المؤشر كل ٥٢ شمعة يوقف ويقيس لك السوق، وبعدين يمد أربعة خطوط تقول لك
وين ممكن يوصل السعر. والمسافة مو رقم كتبته أنا، هي من حركة السوق نفسه
في ذيك اللحظة — سوق هايج يعطيك خطوط بعيدة، وسوق هادي يعطيك خطوط قريبة.

يشتغل على كل الأسواق — وأقوى شي على الاوبشن

ما فيه في المؤشر ولا رقم ثابت. لا نقاط ولا بيبس ولا أهداف محفوظة. كل
مسافة يرسمها يطلعها من حركة الأداة اللي أنت فيها. عشان كذا نفس الشغل
يمشي على الذهب والفوركس والمؤشرات والعملات الرقمية والأسهم، ويمشي على
عقود الاوبشن كمان — وهذي بالذات وين أغلب المؤشرات تخرب وأنت ما تدري.

ليش الاوبشن صعب؟ لأن سعر العقد يتحرك بالسنتات، وممكن العقد يطيح نص
قيمته في ثلاث شموع بس، والجلسات فيها فجوات كثيرة، وشموع تعدي بدون ولا
صفقة. مقياس ATR لحاله يتأخر على حركة زي كذا، فيرسم لك أهداف قريبة ما
تسوى شي.

الحل اللي فيه: يقارن بين شيئين وياخذ الأكبر — إما مسافة ATR، وإما مدى
الشموع الثلاث اللي طلعت منها نقطة البداية. في الأسواق العادية ATR يطلع
أكبر دايماً وما تحس بهالشي أصلاً؛ وفي الاوبشن لما تصير طيحة قوية، مدى
الشموع يطلع أكبر وياخذه المؤشر — فتطلع الخطوط واقعية مو مضحكة.

كيف يشتغل بالضبط

كل دورة يشوف آخر ٣ شموع، ويشوف السعر حالياً قريب من فوق ولا من تحت:
  - السعر قريب من فوق؟ ياخذ القاع نقطة بداية ويمد الخطوط طالعة
  - السعر قريب من تحت؟ ياخذ القمة نقطة بداية ويمد الخطوط نازلة

يعني دايماً يبدأ من الطرف الأبعد عن السعر.

ومن نقطة البداية هذي يقيس المسافة (٣ أضعاف ATR أو مدى الشموع الثلاث،
أيهم أكبر) ويرسم:

  - خطين سميكين: واحد عند نقطة البداية، وواحد عند الهدف الكامل
  - خطين رفيعين بينهم: عند ٥٠٪ و ٦١.٨٪ من المسافة

كل مجموعة خطوط تمشي ٤٩ شمعة وتوقف قبل ما تبدأ المجموعة الجديدة، ويبقى
لك على الشارت آخر ٨ مجموعات.

كيف تقراه

  - الخطوط طالعة فوق؟ الدورة ميولها صعود، ونقطة البداية تحت تصير دعم
  - الخطوط نازلة تحت؟ الدورة ميولها هبوط، ونقطة البداية فوق تصير مقاومة
  - الخطين الرفيعين: أهداف أولى وثانية، مكان طبيعي تجني فيه جزء
  - الخط السميك البعيد: الهدف الكامل للحركة

الإعدادات

  Cycle length     - كل كم شمعة يرسم مجموعة جديدة (الافتراضي ٥٢)
  Anchor window    - كم شمعة ياخذ منها نقطة البداية (٣)
  ATR length/mult  - مقياس المسافة (١٤ و ٣ أضعاف)
  Inner ratios     - الخطين الرفيعين (٠.٥ و ٠.٦١٨)
  Cycle anchor     - من وين تبدأ الدورة: مع الجلسة، مع الأسبوع، أو يدوي
  Display          - ألوان وسماكات وطول الخطوط وعدد المجموعات

كلام لازم يتقال

المؤشر يعطيك مستويات، مو إشارات دخول وخروج. يرسم كل دورة سواء السوق
ترند أو عرضي، وما فيه فلتر يقول لك ادخل الحين. استخدمه مع قراءتك أنت
للسوق.

وهذا مو توصية شراء ولا بيع. جربه على أدواتك وفريماتك قبل لا تعتمد عليه بصفقاتك.

---

## Source Code

````pine
//@version=6
indicator("Sattam | option-scalp", overlay = true, max_lines_count = 500)

// ---------------------------------------------------------------- inputs
gEngine = "Engine"
cycleLen     = input.int(52, "Cycle length (bars)", minval = 2, group = gEngine)
anchorWindow = input.int(3, "Anchor window (bars)", minval = 1, maxval = 50, group = gEngine)
atrLen       = input.int(14, "ATR length", minval = 1, group = gEngine)
atrMult      = input.float(3.0, "ATR multiplier", minval = 0.1, step = 0.1, group = gEngine)
ratio1       = input.float(0.5, "Inner ratio 1", step = 0.001, group = gEngine)
ratio2       = input.float(0.618, "Inner ratio 2", step = 0.001, group = gEngine)
dirRatio     = input.float(0.618, "Direction threshold", minval = 0.0, maxval = 1.0, step = 0.001, group = gEngine)
cyclePhase   = input.int(39, "Cycle phase", minval = 0, tooltip = "The phase decides which bar the 52-bar cycle starts on. The original indicator's phase belongs to its own chart session and cannot be derived, so nudge this 0..51 until the groups line up with the original's.", group = gEngine)
anchorMode   = input.string("Manual phase", "Cycle anchor", options = ["Manual phase", "Session", "Week"], tooltip = "Manual phase uses the Cycle phase setting above and depends on the chart's history. Switch to Session or Week for a result that is stable across charts and machines instead.", group = gEngine)

gDisplay = "Display"
maxGroups = input.int(8, "Groups kept", minval = 1, maxval = 100, group = gDisplay)
lineLen   = input.int(49, "Line length (bars)", minval = 1, tooltip = "How far each line extends to the right, in bars. The original uses cycle length minus anchor window (52 - 3 = 49), so a group's lines stop three bars before the next group starts.", group = gDisplay)
edgeCol   = input.color(#2962FF, "Edge lines", group = gDisplay)
zoneCol   = input.color(#F23645, "Zone lines", group = gDisplay)
edgeWidth = input.int(3, "Edge width", minval = 1, maxval = 10, group = gDisplay)
zoneWidth = input.int(2, "Zone width", minval = 1, maxval = 10, group = gDisplay)

// ---------------------------------------------------------------- engine
levels(float anchor, float r, bool isUp) =>
    s = isUp ? 1.0 : -1.0
    [anchor, anchor + s * ratio1 * r, anchor + s * ratio2 * r, anchor + s * r]

// timeframe.change must be evaluated on EVERY bar, never inside a conditional
dayChange  = timeframe.change("D")
weekChange = timeframe.change("W")
resetHere  = anchorMode == "Session" ? dayChange : anchorMode == "Week" ? weekChange : false

var int cycleCount = 0
cycleCount += 1
if resetHere
    cycleCount := 0
counterFire = cycleCount >= cycleLen
if counterFire
    cycleCount := 0
fire = anchorMode == "Manual phase" ? (bar_index % cycleLen == cyclePhase % cycleLen) : counterFire

hiW = ta.highest(high, anchorWindow)
loW = ta.lowest(low, anchorWindow)

// Direction: where hlc3 sits inside the same window the anchor comes from.
// The first eight groups were equally well explained by the close against the
// window midpoint, but on eighteen groups from three captures that rule calls
// one of them the wrong way. Every down group sits below 0.5170 of the range
// and every up group above 0.6260, so the threshold has room; 0.618 is inside
// the interval implied by the first eight and inside the one implied by the
// later ten, which is why it is 0.618 and not a number fitted to the pooled set.
dirPos = hiW > loW ? (hlc3 - loW) / (hiW - loW) : 0.0
isUp = dirPos > dirRatio

// ta.* must be evaluated on EVERY bar, not inside a conditional branch
atrVal = ta.atr(atrLen)

var array<line> drawn = array.new<line>()

drawGroup(float anchor, float r, bool up) =>
    [l0, l1, l2, l3] = levels(anchor, r, up)
    // The line starts on the firing bar itself, not on the bar the extreme fell
    // on - measured off the original, whose segments run 13->62, 65->114, and so
    // on, always starting exactly where the cycle fires.
    x1 = bar_index
    x2 = x1 + lineLen
    array.push(drawn, line.new(x1, l0, x2, l0, xloc.bar_index, color = edgeCol, width = edgeWidth))
    array.push(drawn, line.new(x1, l1, x2, l1, xloc.bar_index, color = zoneCol, width = zoneWidth))
    array.push(drawn, line.new(x1, l2, x2, l2, xloc.bar_index, color = zoneCol, width = zoneWidth))
    array.push(drawn, line.new(x1, l3, x2, l3, xloc.bar_index, color = edgeCol, width = edgeWidth))
    while array.size(drawn) > maxGroups * 4
        line.delete(array.shift(drawn))

if fire and barstate.isconfirmed
    anchor = isUp ? loW : hiW
    // The span is the ATR projection, but never shorter than the window the
    // anchor came from. On liquid futures the ATR always wins and this floor
    // never shows; on an option a single 3-bar window can hold a collapse the
    // ATR has not caught up with, and there the original follows the window.
    r = math.max(atrMult * atrVal, hiW - loW)
    drawGroup(anchor, r, isUp)

alertcondition(fire, title = "OPTION group", message = "OPTION: new group on {{ticker}} {{interval}}")
````
