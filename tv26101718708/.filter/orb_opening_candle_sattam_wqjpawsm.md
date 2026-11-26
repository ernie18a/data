# ORB Opening Candle | Sattam

- url: https://www.tradingview.com/script/wqJPawSm-ORB-Opening-Candle-Sattam/
- type: indicator
- pine_id: PUB;b43bb3ae3b794da491d0e6b8570784bd
- version: 1.0

## Description

[b]ORB Opening Candle[/b] draws the opening range of the session and reads every candle against it with one rule: a close decides, a touch does not.

The high and low of the first minutes of the session often act as the day's first reference. This script draws that range as a zone, labels what price does at its edges (a real close outside, a wick that fails, a retest that holds), and keeps a simple trade plan with stop, targets and statistics on the loaded history, so you can judge the idea on your own symbol before using it.

[b]HOW THE OPENING RANGE IS BUILT[/b]
• Duration: 5, 15, 30 or 60 minutes (15 by default).
• Session: Auto starts stocks and indices at their official session open (for example 9:30 New York for US stocks, 10:00 Riyadh for Tadawul), and starts forex, metals, crypto and futures at the New York 9:30 open. New York 9:30 and Custom (start, end and time zone) are also available.
• The range is calculated from 5-minute data, so the high and low are the same on any chart timeframe from 1 minute up to 1 hour. On 2 hours and higher the script hides, because the whole range sits inside one candle.

[b]THE ZONE[/b]
The range is drawn as a dark zone with dashed edges. It extends to the end of the session. If price never closed outside it during the session, the zone keeps extending into the following days until the first candle closes outside it, so an untested range stays visible.

[b]THE CLOSE RULE (SIGNALS)[/b]
• Up ▲ / Down ▼: the first candle that closes above the high or below the low.
• Trap ✗: a wick outside the range without a close outside it. This is often a liquidity grab, so watch for a break on the other side.
• Retest ✓: after a close outside, price comes back to the broken edge, touches it and closes on the breakout side again (the broken high acting as support, or the broken low as resistance).

Each signal appears once per side per day. Signals are confirmed at the candle close: on the live candle they can appear and disappear until it closes.

[b]TRADE PLAN: STOP AND TARGETS[/b]
One trade per day, drawn with its entry, stop, target 1 and target 2, each line labelled with its price.
• Entry: the close of the first breakout candle, or of the first retest that holds.
• Stop: inside the opening range, at its middle (default) or at its opposite edge.
• Targets: multiples of the risk (1R and 2R by default, both adjustable).
• The trade ends at the stop, at target 2, or at the session close.

[b]STATISTICS PANEL[/b]
The panel shows the current status (above the high, below the low, inside the range), the range levels, the last signal and the last trade. Under it, the statistics count every trade of the plan above on the loaded chart history: number of trades, the share that reached target 1, reached target 2 or hit the stop, and the net result in R.

[b]How the statistics are counted, so you can read them correctly:[/b]
• They use candle high and low only. When the stop and a target are touched in the same candle, it counts as a stop.
• No commissions, spread or slippage are included.
• The sample is only the history loaded on your chart, and it changes with the symbol and timeframe.

The statistics describe the past on your chart and are not a prediction. Use them to compare settings and symbols, not as an expected result.

[b]SETTINGS[/b]
• Chart language: Arabic or English for every label and the panel. Every setting name is shown in both languages.
• Duration, session (Auto, New York 9:30, Custom) and the number of days shown.
• Each signal type, the trade lines and the statistics can be turned on or off.
• Entry mode, stop placement and the two targets.
• Panel position (nine places) and all colors.

[b]ALERTS[/b]
Four alert conditions: close above the high, close below the low, trap, and retest.

[b]NOTES[/b]
The opening range breakout is a well-known public concept. This script is an independent implementation: its own session handling, close rule, zone extension, trade plan and statistics. It is a tool for studying price around the session open and does not give financial advice. Test any idea on your own symbol and timeframe, and manage your own risk.

————————————————————

المؤشر يرسم نطاق افتتاح الجلسة، ويقرأ كل شمعة على قاعدة وحدة: الإغلاق هو اللي يحسم، مو اللمس.

قمة وقاع أول دقائق من الجلسة غالباً تكون أول مرجع لحركة اليوم. المؤشر يرسم هالنطاق كمنطقة، ويوضح وش يسوي السعر عند حدودها: إغلاق حقيقي برا، أو ذيل يفشل، أو إعادة اختبار تثبت. وفيه خطة صفقة بسيطة بوقف وأهداف وإحصائيات على التاريخ المحمّل، عشان تحكم على الفكرة بنفسك على الرمز اللي تتداوله قبل ما تعتمد عليها.

كيف يُبنى نطاق الافتتاح
• المدة: 5 أو 15 أو 30 أو 60 دقيقة، والافتراضي 15.
• الجلسة: «تلقائي» يبدأ الأسهم والمؤشرات من افتتاح جلستها الرسمية (مثلاً 9:30 نيويورك للأسهم الأمريكية، و10:00 الرياض لتداول)، ويبدأ الفوركس والمعادن والكريبتو والعقود من افتتاح نيويورك 9:30. وفيه خيار «نيويورك 9:30»، وخيار «مخصص» تحدد فيه البداية والنهاية والمنطقة الزمنية.
• النطاق يُحسب من بيانات 5 دقائق، فالقمة والقاع ثابتين على أي فريم من دقيقة إلى ساعة. وعلى فريم ساعتين وفوق المؤشر يختفي، لأن النطاق كله يصير داخل شمعة وحدة.

المنطقة
النطاق يُرسم كمنطقة داكنة بحدود متقطعة، ويمتد لين نهاية الجلسة. وإذا ما قفلت ولا شمعة برا طول الجلسة، تكمل المنطقة تمتد للأيام اللي بعدها لين أول شمعة تقفل برا، عشان يظل النطاق اللي ما انكسر واضح قدامك.

قاعدة الإغلاق (الإشارات)
• صعود ▲ / هبوط ▼: أول شمعة تقفل فوق القمة أو تحت القاع.
• فخ ✗: ذيل يطلع برا النطاق بدون ما تقفل الشمعة برا. هذا غالباً سحب سيولة، فراقب الكسر من الجهة الثانية.
• اختبار ✓: بعد الإغلاق برا، يرجع السعر للحد المكسور ويلمسه ويقفل مرة ثانية في جهة الكسر، يعني القمة المكسورة صارت دعم أو القاع المكسور صار مقاومة.

كل إشارة تطلع مرة وحدة لكل جهة في اليوم. والإشارات تتأكد مع إغلاق الشمعة، أما على الشمعة الحية فممكن تطلع وتختفي لين تقفل.

خطة الصفقة: الوقف والأهداف
صفقة وحدة في اليوم، تنرسم بخطوط الدخول والوقف والهدف 1 والهدف 2، وعلى كل خط سعره.
• الدخول: إغلاق أول شمعة كسر، أو إغلاق أول إعادة اختبار تثبت.
• الوقف: داخل نطاق الافتتاح، في منتصفه (الافتراضي) أو عند طرفه الثاني.
• الأهداف: مضاعفات المخاطرة، والافتراضي 1R و2R، وتقدر تغيّرهم.
• الصفقة تنتهي عند الوقف أو الهدف 2 أو نهاية الجلسة.

لوحة الإحصائيات
اللوحة تعرض وين السعر الحين (فوق القمة أو تحت القاع أو داخل النطاق)، ومستويات النطاق، وآخر إشارة، وآخر صفقة. وتحتها إحصائيات لكل صفقات الخطة على تاريخ الشارت المحمّل: عدد الصفقات، ونسبة اللي وصلت الهدف 1، واللي وصلت الهدف 2، واللي ضربت الوقف، وصافي النتيجة بالـR.

عشان تقرأ الإحصائيات صح، هذي طريقة حسابها:
• تعتمد على قمة وقاع الشمعة فقط. وإذا لمست الشمعة نفسها الوقف والهدف، تنحسب وقف.
• ما تشمل العمولات ولا السبريد ولا الانزلاق.
• العينة هي التاريخ المحمّل على شارتك بس، وتتغير مع الرمز والفريم.

الإحصائيات تصف اللي صار على شارتك في الماضي، ومو توقع للمستقبل. استخدمها للمقارنة بين الإعدادات والرموز، مو كنتيجة متوقعة.

الإعدادات
• لغة الشارت: عربي أو إنجليزي لكل الملصقات واللوحة. وأسماء الإعدادات نفسها مكتوبة باللغتين.
• المدة، والجلسة (تلقائي، نيويورك 9:30، مخصص)، وعدد الأيام المعروضة.
• تقدر تشغّل أو تطفي كل نوع إشارة، وخطوط الصفقة، والإحصائيات.
• طريقة الدخول، ومكان الوقف، والهدفين.
• مكان اللوحة (تسع أماكن) وكل الألوان.

التنبيهات
أربع تنبيهات: إغلاق فوق القمة، وإغلاق تحت القاع، والفخ، وإعادة الاختبار.

ملاحظات
كسر نطاق الافتتاح فكرة عامة ومعروفة، وهذا المؤشر تنفيذ مستقل لها: بطريقته الخاصة في التعامل مع الجلسات، وقاعدة الإغلاق، وامتداد المنطقة، وخطة الصفقة، والإحصائيات. المؤشر أداة لدراسة حركة السعر عند افتتاح الجلسة، ومو نصيحة مالية. جرّب أي فكرة على الرمز والفريم اللي تتداوله، وأدر مخاطرتك بنفسك.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("ORB Opening Candle", "ORB", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ── الإعدادات · Settings ──────────────────────────────────
const string L_AR   = "العربية"
const string L_EN   = "English"
const string M_AUTO = "Auto · تلقائي"
const string M_NY   = "New York 9:30 · نيويورك"
const string M_CUS  = "Custom · مخصص"
const string E_BRK  = "Breakout close · إغلاق الكسر"
const string E_RT   = "Retest · إعادة الاختبار"
const string S_MID  = "ORB middle · منتصف ORB"
const string S_OPP  = "Opposite edge · الطرف الثاني"

const string G1 = "ORB"
string lang   = input.string(L_AR, "Chart language · لغة الشارت", options = [L_AR, L_EN], group = G1, tooltip = "Language of the labels and the panel on the chart.\n\nلغة العلامات واللوحة على الشارت.")
string durIn  = input.string("15", "ORB duration (min) · مدة ORB (دقيقة)", options = ["5", "15", "30", "60"], group = G1)
string mode   = input.string(M_AUTO, "Session · الجلسة", options = [M_AUTO, M_NY, M_CUS], group = G1, tooltip = "Auto: stocks and indices start at their official session open (US 9:30, Tadawul 10:00); other markets (forex, gold, crypto, futures) start at the New York 9:30 open.\n\nتلقائي: الأسهم والمؤشرات من افتتاح جلستها الرسمية (أمريكا 9:30، تداول 10:00)، وباقي الأسواق (فوركس، ذهب، كريبتو، عقود) من افتتاح نيويورك 9:30.")
int    cH     = input.int(9, "Custom start hour · ساعة البداية", minval = 0, maxval = 23, group = G1, inline = "cs")
int    cM     = input.int(30, "min · دقيقة", minval = 0, maxval = 55, step = 5, group = G1, inline = "cs")
int    ceH    = input.int(16, "Custom end hour · ساعة النهاية", minval = 0, maxval = 23, group = G1, inline = "ce")
int    ceM    = input.int(0, "min · دقيقة", minval = 0, maxval = 55, step = 5, group = G1, inline = "ce")
string cTz    = input.string("America/New_York", "Custom time zone · المنطقة الزمنية", options = ["America/New_York", "Asia/Riyadh", "Europe/London", "UTC"], group = G1)
int    days   = input.int(10, "Days shown · عدد الأيام المعروضة", minval = 1, maxval = 150, group = G1)

const string G2 = "Signals · الإشارات"
bool showBrk  = input.bool(true, "Close outside (up / down) · إغلاق برا (صعود / هبوط)", group = G2)
bool showTrap = input.bool(true, "Wick outside, no close (trap) · ذيل برا بدون إغلاق (فخ)", group = G2)
bool showRt   = input.bool(true, "Retest of the edge after the close · إعادة اختبار الحد بعد الإغلاق", group = G2)
bool showTbl  = input.bool(true, "Panel · اللوحة", group = G2, inline = "pn")
string tblPos = input.string("Bottom right · أسفل يمين", "", options = ["Top right · أعلى يمين", "Top center · أعلى وسط", "Top left · أعلى يسار", "Middle right · وسط يمين", "Middle center · الوسط", "Middle left · وسط يسار", "Bottom right · أسفل يمين", "Bottom center · أسفل وسط", "Bottom left · أسفل يسار"], group = G2, inline = "pn")

const string G4 = "Trade · الصفقة"
bool   showTrd = input.bool(true, "Stop & targets · الوقف والأهداف", group = G4)
string entMode = input.string(E_BRK, "Entry · الدخول", options = [E_BRK, E_RT], group = G4, tooltip = "One trade per day, entered at the close of the signal candle: the first close outside the ORB, or the first retest of the broken edge that holds.\n\nصفقة وحدة في اليوم، الدخول عند إغلاق شمعة الإشارة: أول إغلاق برا ORB، أو أول إعادة اختبار للحد المكسور وثبات.")
string stpMode = input.string(S_MID, "Stop · الوقف", options = [S_MID, S_OPP], group = G4, tooltip = "The stop sits inside the ORB candle: at its middle, or at its opposite edge.\n\nالوقف داخل شمعة ORB: في منتصفها أو عند طرفها الثاني.")
float  tp1R    = input.float(1.0, "Target 1 (R) · الهدف 1", minval = 0.25, step = 0.25, group = G4, inline = "tp")
float  tp2R    = input.float(2.0, "Target 2 (R) · الهدف 2", minval = 0.25, step = 0.25, group = G4, inline = "tp")
bool   showSt  = input.bool(true, "Stats panel · لوحة الإحصائيات", group = G4, tooltip = "Results of every trade on the loaded chart history. A trade ends at the stop, at target 2, or at the session close. If the stop and a target are touched in the same candle it counts as a stop.\n\nنتائج كل الصفقات على تاريخ الشارت المحمّل. الصفقة تنتهي عند الوقف أو الهدف 2 أو نهاية الجلسة. وإذا لمس الوقف والهدف نفس الشمعة تُحسب وقف.")

const string G3 = "Colors · الألوان"
color cFill = input.color(color.new(#1c2b3f, 25), "Range fill · تعبئة النطاق", group = G3)
color cEdge = input.color(#4fc3f7, "Range edges · حدود النطاق", group = G3)
color cUp   = input.color(#3ddc84, "Up · صعود", group = G3, inline = "c")
color cDn   = input.color(#f0566a, "Down · هبوط", group = G3, inline = "c")
color cTrap = input.color(#f5c542, "Trap · فخ", group = G3, inline = "c")
color cTp   = input.color(#3ddc84, "Targets · الأهداف", group = G3, inline = "t")
color cSl   = input.color(#f0566a, "Stop · الوقف", group = G3, inline = "t")
color cEnt  = input.color(#9aa4b2, "Entry · الدخول", group = G3, inline = "t")

bool isAr = lang == L_AR
tr(string ar, string en) => isAr ? ar : en
// علامة اتجاه غير مرئية تمنع انقلاب الأرقام داخل النص العربي
ltr(string x) => isAr ? "‎" + x + "‎" : x

// ── الجلسة ────────────────────────────────────────────────
int    durMs   = int(str.tonumber(durIn)) * 60000
bool   sessTy  = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr" or syminfo.type == "index"
bool   useSess = mode == M_AUTO and sessTy
string tz      = mode == M_CUS ? cTz : "America/New_York"
int    sH      = mode == M_CUS ? cH : 9
int    sM      = mode == M_CUS ? cM : 30
int    eH      = mode == M_CUS ? ceH : 16
int    eM      = mode == M_CUS ? ceM : 0
bool   hidden  = not timeframe.isintraday or timeframe.in_seconds() >= 7200

// تُحسب على بيانات 5 دقائق فتبقى قمة وقاع ORB ثابتة على أي فريم شارت
orbState(int dMs, bool bySess, string zone, int hh, int mm) =>
    var float h  = na
    var float l  = na
    var int   t0 = na
    int  dayT  = timestamp(zone, year(time, zone), month(time, zone), dayofmonth(time, zone), hh, mm)
    bool inWin = time >= dayT and time < dayT + dMs
    bool begin = bySess ? session.isfirstbar_regular : inWin and (na(t0) or t0 != dayT)
    if begin
        t0 := bySess ? time : dayT
        h  := high
        l  := low
    else if not na(t0) and time < t0 + dMs
        h  := math.max(h, high)
        l  := math.min(l, low)
    [h, l, t0]

[oH, oL, oT] = request.security(syminfo.tickerid, "5", orbState(durMs, useSess, tz, sH, sM), lookahead = barmerge.lookahead_off)

int  nowT  = barstate.isrealtime ? timenow : time_close
bool ready = not hidden and not na(oT) and nowT >= oT + durMs

// ── الرسم ─────────────────────────────────────────────────
type Zone
    box          bx
    line         top
    line         bot
    float        hi
    float        lo
    bool         carry = false
    array<line>  tls
    array<label> tlb

setRight(Zone z, int t) =>
    box.set_right(z.bx, t)
    line.set_x2(z.top, t)
    line.set_x2(z.bot, t)

var array<Zone> zones = array.new<Zone>()
var int  drawnT = na
var int  endT   = na
var bool ended  = true
var bool upOn   = false
var bool dnOn   = false
var bool upTest = false
var bool dnTest = false
var bool trapU  = false
var bool trapD  = false
var int  upBar  = na
var int  dnBar  = na
var string lastSig = "—"
var color  lastCol = color.gray

// الصفقة: وحدة في اليوم، والإحصاء على كل التاريخ المحمّل
var int    tDir  = 0
var bool   tOpen = false
var bool   tDone = false
var bool   tHit1 = false
var int    tBar  = na
var float  tEnt  = na
var float  tSl   = na
var float  tT1   = na
var float  tT2   = na
var float  tRisk = na
var string tRes  = ""
var color  tCol  = color.gray
var array<line>  curL = array.new<line>()
var array<label> curB = array.new<label>()
var int   nTr    = 0
var int   nT1    = 0
var int   nT2    = 0
var int   nSl    = 0
var float sumR   = 0.0
var int   firstT = na

float  exitR    = na
string exitKind = ""

// الصندوق يمتد لنهاية الجلسة، وإن بقي السعر داخله ولم يغلق برا يكمل للأيام التالية حتى أول إغلاق برا.
// يُفحص قبل إنشاء صندوق اليوم الجديد حتى يُقفل اليوم السابق أولاً.
if not ended and not na(drawnT)
    bool sessOver = useSess ? (not session.ismarket or (session.isfirstbar_regular and time > drawnT)) : time >= endT
    bool over     = sessOver or (ready and oT != drawnT)
    if over
        ended := true
        if not upOn and not dnOn
            Zone cur = array.last(zones)
            cur.carry := true
        if tOpen
            exitR    := tDir * (close[1] - tEnt) / tRisk
            exitKind := "time"
    else
        setRight(array.last(zones), time_close)

if ready and (na(drawnT) or oT != drawnT)
    drawnT := oT
    int endDay = timestamp(tz, year(oT, tz), month(oT, tz), dayofmonth(oT, tz), eH, eM)
    endT   := endDay <= oT ? endDay + 86400000 : endDay
    ended  := false
    upOn   := false
    dnOn   := false
    upTest := false
    dnTest := false
    trapU  := false
    trapD  := false
    tDone  := false
    lastSig := "—"
    lastCol := color.gray
    box  bx = box.new(oT, oH, time_close, oL, xloc = xloc.bar_time, border_color = na, bgcolor = cFill)
    line lt = line.new(oT, oH, time_close, oH, xloc = xloc.bar_time, color = cEdge, style = line.style_dashed, width = 1)
    line lb = line.new(oT, oL, time_close, oL, xloc = xloc.bar_time, color = cEdge, style = line.style_dashed, width = 1)
    array.push(zones, Zone.new(bx, lt, lb, oH, oL, false, array.new<line>(), array.new<label>()))
    if array.size(zones) > days
        Zone old = array.shift(zones)
        box.delete(old.bx)
        line.delete(old.top)
        line.delete(old.bot)
        for l in old.tls
            line.delete(l)
        for b in old.tlb
            label.delete(b)

for z in zones
    if z.carry
        setRight(z, time_close)
        if close > z.hi or close < z.lo
            z.carry := false

// متابعة الصفقة المفتوحة: الوقف أولاً عند لمسه مع هدف في نفس الشمعة
if tOpen and exitKind == "" and bar_index > tBar
    for l in curL
        line.set_x2(l, time_close)
    for b in curB
        label.set_x(b, time_close)
    bool slHit = tDir == 1 ? low <= tSl : high >= tSl
    bool t1Hit = tDir == 1 ? high >= tT1 : low <= tT1
    bool t2Hit = tDir == 1 ? high >= tT2 : low <= tT2
    if slHit
        exitR    := -1.0
        exitKind := "sl"
    else
        if t1Hit
            tHit1 := true
        if t2Hit
            exitR    := tp2R
            exitKind := "tp2"

// ── الإشارات: الإغلاق مو اللمس ────────────────────────────
bool active = not ended and not na(drawnT) and time >= drawnT + durMs

bool upBrk  = active and not upOn and close > oH
bool dnBrk  = active and not dnOn and close < oL
bool upTrap = active and not upOn and not trapU and high > oH and close <= oH
bool dnTrap = active and not dnOn and not trapD and low < oL and close >= oL
bool upRt   = active and upOn and not upTest and bar_index > upBar and low <= oH and close > oH
bool dnRt   = active and dnOn and not dnTest and bar_index > dnBar and high >= oL and close < oL

if upBrk
    upOn  := true
    upBar := bar_index
    lastSig := tr("إغلاق فوق القمة = صعود ✓", "Close above high = up ✓")
    lastCol := cUp
    if showBrk
        label.new(bar_index, low, tr("صعود ▲", "Up ▲"), style = label.style_label_up, color = cUp, textcolor = #0b0e14, size = size.small)
if dnBrk
    dnOn  := true
    dnBar := bar_index
    lastSig := tr("إغلاق تحت القاع = هبوط ✓", "Close below low = down ✓")
    lastCol := cDn
    if showBrk
        label.new(bar_index, high, tr("هبوط ▼", "Down ▼"), style = label.style_label_down, color = cDn, textcolor = color.white, size = size.small)
if upTrap
    trapU := true
    lastSig := tr("ذيل فوق بدون إغلاق = فخ ✗", "Wick above, no close = trap ✗")
    lastCol := cTrap
    if showTrap
        label.new(bar_index, high, tr("فخ ✗", "Trap ✗"), style = label.style_label_down, color = cTrap, textcolor = #0b0e14, size = size.small)
if dnTrap
    trapD := true
    lastSig := tr("ذيل تحت بدون إغلاق = فخ ✗", "Wick below, no close = trap ✗")
    lastCol := cTrap
    if showTrap
        label.new(bar_index, low, tr("فخ ✗", "Trap ✗"), style = label.style_label_up, color = cTrap, textcolor = #0b0e14, size = size.small)
if upRt
    upTest := true
    lastSig := tr("اختبر القمة وثبت = دخول ✓", "High retested and held = entry ✓")
    lastCol := cUp
    if showRt
        label.new(bar_index, low, tr("اختبار ✓", "Retest ✓"), style = label.style_label_up, color = color.new(cUp, 60), textcolor = color.white, size = size.tiny)
if dnRt
    dnTest := true
    lastSig := tr("اختبر القاع وثبت = دخول ✓", "Low retested and held = entry ✓")
    lastCol := cDn
    if showRt
        label.new(bar_index, high, tr("اختبار ✓", "Retest ✓"), style = label.style_label_down, color = color.new(cDn, 60), textcolor = color.white, size = size.tiny)

// ── فتح الصفقة ────────────────────────────────────────────
bool goLong  = entMode == E_BRK ? upBrk : upRt
bool goShort = entMode == E_BRK ? dnBrk : dnRt
if not tDone and not tOpen and (goLong or goShort)
    tDone := true
    tOpen := true
    tHit1 := false
    tDir  := goLong ? 1 : -1
    tBar  := bar_index
    tEnt  := close
    float mid = (oH + oL) / 2
    tSl   := stpMode == S_MID ? mid : tDir == 1 ? oL : oH
    tRisk := math.abs(tEnt - tSl)
    tT1   := tEnt + tDir * tp1R * tRisk
    tT2   := tEnt + tDir * tp2R * tRisk
    firstT := na(firstT) ? time : firstT
    tRes  := (tDir == 1 ? tr("شراء ▲", "Long ▲") : tr("بيع ▼", "Short ▼")) + " · " + tr("مفتوحة", "open")
    tCol  := color.silver
    array.clear(curL)
    array.clear(curB)
    if showTrd
        Zone zc = array.last(zones)
        array.push(curL, line.new(time, tEnt, time_close, tEnt, xloc = xloc.bar_time, color = cEnt, style = line.style_dotted, width = 1))
        array.push(curL, line.new(time, tSl, time_close, tSl, xloc = xloc.bar_time, color = cSl, width = 1))
        array.push(curL, line.new(time, tT1, time_close, tT1, xloc = xloc.bar_time, color = cTp, style = line.style_dashed, width = 1))
        array.push(curL, line.new(time, tT2, time_close, tT2, xloc = xloc.bar_time, color = cTp, width = 1))
        array.push(curB, label.new(time_close, tEnt, tr("دخول ", "Entry ") + str.tostring(tEnt, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = cEnt, size = size.tiny))
        array.push(curB, label.new(time_close, tSl, tr("وقف ", "SL ") + str.tostring(tSl, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = cSl, size = size.tiny))
        array.push(curB, label.new(time_close, tT1, tr("هدف 1 ", "TP1 ") + str.tostring(tT1, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = cTp, size = size.tiny))
        array.push(curB, label.new(time_close, tT2, tr("هدف 2 ", "TP2 ") + str.tostring(tT2, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = cTp, size = size.tiny))
        for l in curL
            array.push(zc.tls, l)
        for b in curB
            array.push(zc.tlb, b)

// آخر شمعة في الجلسة: يُقفل اليوم وتُغلق الصفقة المفتوحة على إغلاقها
bool lastIn = useSess ? session.islastbar_regular : time_close >= endT
if not ended and not na(drawnT) and lastIn
    ended := true
    if not upOn and not dnOn
        Zone cur = array.last(zones)
        cur.carry := true
    if tOpen and exitKind == ""
        exitR    := tDir * (close - tEnt) / tRisk
        exitKind := "time"

if exitKind != ""
    tOpen := false
    nTr   += 1
    sumR  += exitR
    nT1   += tHit1 ? 1 : 0
    nT2   += exitKind == "tp2" ? 1 : 0
    nSl   += exitKind == "sl" ? 1 : 0
    string side = tDir == 1 ? tr("شراء ▲", "Long ▲") : tr("بيع ▼", "Short ▼")
    string rTxt = ltr((exitR >= 0 ? "+" : "") + str.tostring(exitR, "#.##") + "R")
    string kTxt = exitKind == "tp2" ? tr("الهدف 2 ✓", "Target 2 ✓") : exitKind == "sl" ? (tHit1 ? tr("وقف بعد الهدف 1", "Stop after target 1") : tr("وقف ✗", "Stop ✗")) : tr("نهاية الجلسة", "Session close")
    tRes := side + " · " + kTxt + " " + rTxt
    tCol := exitR > 0 ? cTp : exitR < 0 ? cSl : color.silver

plot(ready ? oH : na, "ORB High", color = cEdge, display = display.data_window)
plot(ready ? oL : na, "ORB Low", color = cEdge, display = display.data_window)

alertcondition(upBrk, "ORB Up · صعود", "ORB: close above the high = up · إغلاق فوق قمة ORB = صعود")
alertcondition(dnBrk, "ORB Down · هبوط", "ORB: close below the low = down · إغلاق تحت قاع ORB = هبوط")
alertcondition(upTrap or dnTrap, "ORB Trap · فخ", "ORB: wick outside without a close = trap, watch the other side · ذيل برا ORB بدون إغلاق = فخ، راقب الكسر من الجهة الثانية")
alertcondition(upRt or dnRt, "ORB Retest · إعادة اختبار", "ORB: price retested the edge and held · السعر رجع اختبر حد ORB وثبت")

// ── اللوحة ────────────────────────────────────────────────
pct(int k, int n) => n > 0 ? str.tostring(100.0 * k / n, "#") + "%" : "—"

posOf(string p) =>
    switch p
        "Top center · أعلى وسط"       => position.top_center
        "Top left · أعلى يسار"        => position.top_left
        "Middle right · وسط يمين"     => position.middle_right
        "Middle center · الوسط"       => position.middle_center
        "Middle left · وسط يسار"      => position.middle_left
        "Bottom right · أسفل يمين"    => position.bottom_right
        "Bottom center · أسفل وسط"    => position.bottom_center
        "Bottom left · أسفل يسار"     => position.bottom_left
        => position.top_right

var table tb = table.new(posOf(tblPos), 2, 11, bgcolor = color.new(#0f141c, 5), border_color = color.new(#2a3446, 0), border_width = 1, frame_color = color.new(#2a3446, 0), frame_width = 1)
if showTbl and barstate.islast
    if hidden
        table.cell(tb, 0, 0, tr("ORB يختفي على فريم ساعتين وفوق", "ORB hides on 2H and higher"), text_color = cTrap, text_size = size.small)
        table.merge_cells(tb, 0, 0, 1, 0)
    else
        string st = tr("بانتظار شمعة ORB", "Waiting for the ORB candle")
        color  sc = color.gray
        if ready and oT == drawnT
            st := close > oH ? tr("فوق القمة ▲", "Above high ▲") : close < oL ? tr("تحت القاع ▼", "Below low ▼") : tr("داخل النطاق ↔", "Inside range ↔")
            sc := close > oH ? cUp : close < oL ? cDn : color.silver
        table.cell(tb, 0, 0, "ORB " + durIn + tr(" دقيقة", " min"), text_color = color.white, text_size = size.small)
        table.cell(tb, 1, 0, st, text_color = sc, text_size = size.small)
        table.cell(tb, 0, 1, tr("القمة", "High"), text_color = color.gray, text_size = size.small)
        table.cell(tb, 1, 1, ready ? str.tostring(oH, format.mintick) : "—", text_color = cEdge, text_size = size.small)
        table.cell(tb, 0, 2, tr("القاع", "Low"), text_color = color.gray, text_size = size.small)
        table.cell(tb, 1, 2, ready ? str.tostring(oL, format.mintick) : "—", text_color = cEdge, text_size = size.small)
        table.cell(tb, 0, 3, tr("آخر إشارة", "Last signal"), text_color = color.gray, text_size = size.small)
        table.cell(tb, 1, 3, lastSig, text_color = lastCol, text_size = size.small)
        table.cell(tb, 0, 4, tr("آخر صفقة", "Last trade"), text_color = color.gray, text_size = size.small)
        table.cell(tb, 1, 4, tDir == 0 ? "—" : tRes, text_color = tCol, text_size = size.small)
        if showSt
            string since = na(firstT) ? "" : " · " + tr("من ", "since ") + str.format_time(firstT, "dd/MM/yy", tz)
            table.cell(tb, 0, 5, tr("الإحصائيات", "Statistics") + since, text_color = color.white, text_size = size.small)
            table.merge_cells(tb, 0, 5, 1, 5)
            table.cell(tb, 0, 6, tr("الصفقات", "Trades"), text_color = color.gray, text_size = size.small)
            table.cell(tb, 1, 6, str.tostring(nTr), text_color = color.white, text_size = size.small)
            table.cell(tb, 0, 7, tr("وصل الهدف 1", "Reached target 1"), text_color = color.gray, text_size = size.small)
            table.cell(tb, 1, 7, pct(nT1, nTr), text_color = cTp, text_size = size.small)
            table.cell(tb, 0, 8, tr("وصل الهدف 2", "Reached target 2"), text_color = color.gray, text_size = size.small)
            table.cell(tb, 1, 8, pct(nT2, nTr), text_color = cTp, text_size = size.small)
            table.cell(tb, 0, 9, tr("ضرب الوقف", "Stopped out"), text_color = color.gray, text_size = size.small)
            table.cell(tb, 1, 9, pct(nSl, nTr), text_color = cSl, text_size = size.small)
            string net = nTr > 0 ? ltr((sumR >= 0 ? "+" : "") + str.tostring(sumR, "#.#") + "R") + " · " + tr("متوسط ", "avg ") + ltr(str.tostring(sumR / nTr, "#.##") + "R") : "—"
            table.cell(tb, 0, 10, tr("صافي الربح", "Net result"), text_color = color.gray, text_size = size.small)
            table.cell(tb, 1, 10, net, text_color = sumR >= 0 ? cTp : cSl, text_size = size.small)
````
