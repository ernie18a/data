# Macro Liquidity Waterfall Board [The_lurker]

- url: https://www.tradingview.com/script/HSfqLSRQ/
- type: indicator
- pine_id: PUB;37a06c11415143bf940a11727655dfbb
- version: 1.0

## Description

Macro Liquidity Waterfall Board     لوحة شلال السيولة الكلّية

An integrated monitoring board for the state of macro liquidity across global markets, built to answer one question with precision and clarity: where is liquidity positioned right now, and which market sectors are moving with it?

Unlike traditional liquidity indicators that compress the entire picture into a single composite number that hides its sources, this board displays liquidity as a transparent, interconnected system: every data source is visible, every information channel is separate, and every component can be traced back to its origin. The result is a complete view of the macro context in a single board, instead of scattered numbers across several tools.


🏛️ HIERARCHICAL LIQUIDITY STRUCTURE

The board displays liquidity as a tree flowing top to bottom, revealing how it propagates across market levels:

[image]https://www.tradingview.com/x/fISzur2Z/[/image]

▸ Level 1 — Global Liquidity
Net liquidity is computed from the standard accounting identity: the Federal Reserve balance sheet, minus reverse repo agreements and the Treasury General Account, with an optional M2 money supply component. This is the primary engine from which the rest of the system branches.

[image]https://www.tradingview.com/x/zwdBag6n/[/image]

▸ Level 2 — Asset Classes
Bonds, stocks, crypto, stablecoins, gold, and oil — each as an independent node showing its relative position within the broader landscape.

[image]https://www.tradingview.com/x/m1rOkfOV/[/image]

▸ Level 3 — Crypto Assets
Customizable individual coins (Bitcoin, Ethereum, Ripple, altcoins) with each one's allocation share within the crypto sector.


📊 SEPARATE INFORMATION CHANNELS

The governing design principle: no single composite number that hides the source. Each node displays its channels separately, so the trader sees why liquidity is moving, not merely that it is moving:

[image]https://www.tradingview.com/x/l5UtoHQV/[/image]

◆ Value and Change
The current magnitude and its percentage change over the selected period.

[image]https://www.tradingview.com/x/jMAje7a2/[/image]

◆ Z-Score
The position of the current move against its historical distribution, using either standard or outlier-resistant scaling.

[image]https://www.tradingview.com/x/j21oFI7B/[/image]

◆ Freshness Indicator
A colored dot revealing data age (live / delayed / stale), so you never unknowingly rely on outdated data.

◆ Relative Performance
Each node's color reflects its position against the class average: relatively outperforming or underperforming.

[image]https://www.tradingview.com/x/oy8Hpkf9/[/image]

◆ In-Card Sparkline
The recent value trajectory inside each card at a glance.

[image]https://www.tradingview.com/x/sPMd9sQ3/[/image]

💧 ACCOUNTING WATERFALL PANEL

The most precise element on the board, and the only real flow it displays: the decomposition of the change in global liquidity into its contributing components (Fed, reverse repo, Treasury) via an exact accounting identity — so you see exactly which source injected liquidity and which drained it, in actual dollar figures, with stale components flagged automatically.


⚙️ ANALYTICAL ENGINES

▸ Regime State Classification
The board classifies the instantaneous relationship between liquidity direction and crypto direction into four clear states:

   • Concurrent Expansion — liquidity and price rising together
   • Liquidity Without Price — liquidity rising while price lags
   • Unsupported Rally — price rising without liquidity support
   • Concurrent Contraction — liquidity and price falling together

Along with the current state's age against its historical median, so you know whether the present regime is within its usual duration or has stretched unusually long.

▸ Crypto Breadth
A cross-sectional measure revealing how many crypto assets are actually moving with the direction of liquidity. High breadth means a broad, reliable regime signal; low breadth means movement driven by one or two names — an essential distinction that guards against reading a narrow signal as a general trend.

▸ Hypothesis-Validity Line
A rolling correlation coefficient between liquidity and crypto changes, revealing when the liquidity-market relationship is currently active and when it breaks down — an honesty gauge that prevents blind reliance on the liquidity narrative when it isn't holding.

▸ Edge-Triggered Alerts
Alerts fire on state change only — no repetition, no noise. The board monitors the system on your behalf and notifies you at regime transitions, or when a data gap is detected.

[image]https://www.tradingview.com/x/dxf0LGaf/[/image]

▸ Timeline Ribbon

A row of colored cells showing the regime path across recent periods, so you read the state history at a single glance. Each cell's color reflects that period's state: teal for expansion, red for contraction, amber for divergence (liquidity without price, or an unsupported rally), and gray for the neutral state.

🎯 NATURE AND USE

This board is a concurrent macro-context awareness tool — designed to build a deep understanding of the current liquidity environment before making a decision, not to time specific entry or exit moments. Its natural place in any trader's system is the top layer: reading the general liquidity regime and macro context, upon which precise timing decisions are built with other tools. It answers the question: what is the macro market environment today? with depth and clarity.


🔧 TECHNICAL NOTES

◆ Inter-class flow is a relative representation, not a direct measurement — trading platforms do not provide cross-asset order flow; class color shows relative performance against the average, while the real accounting flow appears in the waterfall panel exclusively.

◆ Required data sources — FRED economic data, CRYPTOCAP, TVC, and NASDAQ; please confirm their availability within your subscription.

◆ Unit calibration — default settings are tuned for raw quoting; check the data window if a unit warning appears, to calibrate the sources.

◆ Context calibration — regime duration metrics and thresholds are built on recent market data, and may require review when the broad macro environment changes.

◆ Technical commitments — no repainting · confirmed data only · a one-period delay is intentional by design to prevent future leakage · efficient per-bar computation.

═════════════════════════════════════════════════════════════
⚠️ DISCLAIMER
═════════════════════════════════════════════════════════════

This indicator is for educational and analytical purposes only. It does not constitute financial, investment, or trading advice. Use it alongside your own strategy and risk management. Neither TradingView nor the developer is responsible for any financial decisions or losses.

══════════════════════════════════════════════════════════
══════════════════════════════════════════════════════════

Macro Liquidity Waterfall Board     لوحة شلال السيولة الكلّية


لوحة رصد متكاملة لحالة السيولة الكلّية عبر الأسواق العالمية، مصمّمة لتُجيب سؤالًا واحدًا بدقّة ووضوح: أين تتموضع السيولة الآن، وأيّ قطاعات السوق تتحرّك معها؟

على عكس مؤشرات السيولة التقليدية التي تختزل الصورة كلّها في رقم واحد مركّب يُخفي مصادره، تعرض هذه اللوحة السيولة كمنظومة مترابطة شفافة: كل مصدر بياناته مرئي، كل قناة معلومات منفصلة، وكل مكوّن يمكن تتبّعه إلى أصله. النتيجة صورة كاملة للسياق الكلّي في لوحة واحدة، بدل أرقام متناثرة عبر عدّة أدوات.


🏛️ البنية الهرمية للسيولة

تعرض اللوحة السيولة كشجرة تتدفّق من الأعلى إلى الأسفل، تكشف كيف تنتقل عبر مستويات السوق:

[image]https://www.tradingview.com/x/8HFedaDf/[/image]

▸ المستوى الأول — السيولة العالمية
يُحتسب صافي السيولة من الهوية المحاسبية القياسية: الميزانية العمومية للاحتياطي الفدرالي، مطروحًا منها اتفاقيات إعادة الشراء العكسية وحساب الخزانة العام، مع خيار إدراج المعروض النقدي M2. هذا هو المحرّك الأساسي الذي تتفرّع منه بقية المنظومة.

[image]https://www.tradingview.com/x/axMtiG3J/[/image]

▸ المستوى الثاني — فئات الأصول
السندات، الأسهم، الكريبتو، العملات المستقرة، الذهب، والنفط — كل فئة كعقدة مستقلّة تُظهر موقعها النسبي داخل المشهد الكلّي.

[image]https://www.tradingview.com/x/9lAYf3mF/[/image]

▸ المستوى الثالث — أصول الكريبتو
عملات فردية قابلة للتخصيص (بيتكوين، إيثريوم، ريبل، البدائل) مع نسبة التخصيص لكل منها داخل قطاع الكريبتو.


📊 قنوات المعلومات المنفصلة

المبدأ التصميمي الحاكم: لا رقم مركّب واحد يُخفي المصدر. كل عقدة تعرض قنواتها منفصلة، فيرى المتداول لماذا تتحرّك السيولة لا مجرّد أنها تتحرّك:

[image]https://www.tradingview.com/x/DJ3E2a1Z/[/image]

◆ القيمة والتغيّر
الحجم الحالي ونسبة تغيّره عبر الفترة المختارة.

[image]https://www.tradingview.com/x/hnFl1KoI/[/image]

◆ الدرجة المعيارية (Z-Score)
موقع الحركة الحالية مقابل توزيعها التاريخي، بمقياس قياسي أو مقاوم للقيم الشاذّة.

[image]https://www.tradingview.com/x/WbUQJJ2p/[/image]

◆ مؤشر حداثة البيانات
نقطة ملوّنة تكشف مدى حداثة بيانات كل مصدر (حديثة / متأخّرة / قديمة). بعض المصادر تتحدّث بترددات مختلفة — بيانات الفدرالي أسبوعية، والمعروض النقدي شهري، بينما الكريبتو لحظي — فيكشف هذا المؤشر أيّ الأرقام على اللوحة حيّة الآن وأيّها قديم، حتى لا تبني قرارًا على قيمة لم تُحدَّث منذ فترة.

◆ الأداء النسبي
لون كل عقدة يعكس موقعها مقابل متوسط الفئات: متفوّقة أم متخلّفة نسبيًا.

[image]https://www.tradingview.com/x/mohmTHoC/[/image]

◆ الخط البياني المصغّر
مسار القيمة الأخير داخل كل بطاقة بلمحة.

[image]https://www.tradingview.com/x/WhSQ6Kuc/[/image]

💧 لوحة الشلال المحاسبي

العنصر الأكثر دقّة في اللوحة، ويعرض التدفّق الحقيقي الوحيد فيها: تفكيك تغيّر السيولة العالمية إلى مكوّناته المساهِمة (الفدرالي، إعادة الشراء العكسية، الخزانة) بهوية محاسبية دقيقة — فترى بالضبط أيّ مصدر ضخّ سيولة وأيّها سحبها، بأرقام دولارية فعلية، مع تمييز المكوّنات القديمة تلقائيًا.


⚙️ المحرّكات التحليلية

▸ تصنيف حالة النظام
تُصنّف اللوحة العلاقة اللحظية بين اتجاه السيولة واتجاه الكريبتو إلى أربع حالات واضحة:

   • توسّع متزامن — السيولة والسعر يرتفعان معًا
   • سيولة بلا سعر — السيولة ترتفع بينما السعر يتخلّف
   • رالي غير مدعوم — السعر يرتفع دون دعم السيولة
   • انكماش متزامن — السيولة والسعر ينخفضان معًا

مع عمر الحالة الحالي مقابل وسيطها التاريخي، فتعرف إن كان النظام الراهن ضمن مدّته المعتادة أم امتدّ بشكل غير اعتيادي.

▸ اتّساع الكريبتو
مقياس مقطعي يكشف كم أصلًا من أصول الكريبتو يتحرّك فعليًا مع اتجاه السيولة. اتّساع عالٍ يعني إشارة نظام واسعة يُوثَق بها؛ اتّساع منخفض يعني حركة يقودها أصل أو اثنان — تمييز جوهري يحمي من قراءة إشارة ضيّقة على أنها اتجاه عام.

▸ مؤشر صلاحية الفرضية
معامل ارتباط متدحرج بين تغيّرات السيولة والكريبتو، يكشف متى تكون العلاقة بين السيولة والسوق فاعلة الآن ومتى تتعطّل — أداة تحقّق تمنع الاعتماد الأعمى على سردية السيولة حين لا تكون قائمة.

▸ تنبيهات عند التغيّر فقط
تنبيهات تُطلَق على تغيّر الحالة فقط — لا تكرار ولا ضجيج. اللوحة تراقب المنظومة نيابةً عنك وتُعلمك عند الانتقال بين الأنظمة، أو عند اكتشاف فجوة في البيانات.

[image]https://www.tradingview.com/x/f5Ed4pDw/[/image]

▸ شريط الخط الزمني
صفّ من الخلايا الملوّنة يعرض مسار النظام عبر الفترات الأخيرة، فترى تاريخ الحالة بلمحة بصرية واحدة. لون كل خلية يدلّ على حالة تلك الفترة: أزرق للتوسّع، أحمر للانكماش، برتقالي للتباعد (سيولة بلا سعر أو رالي غير مدعوم)، ورمادي للحالة المحايدة.

🎯 طبيعة اللوحة واستخدامها

هذه اللوحة أداة وعي بالسياق الكلّي المتزامن — تُصمَّم لبناء فهمٍ عميق لبيئة السيولة الراهنة قبل اتّخاذ القرار، لا لتوقيت لحظات دخول أو خروج محدّدة. موقعها الطبيعي في منظومة أي متداول هو الطبقة الأعلى: قراءة نظام السيولة العام والسياق الكلّي، الذي تُبنى فوقه قرارات التوقيت الدقيقة بأدوات أخرى. تُجيب سؤال: ما بيئة السوق الكلّية اليوم؟ بعمق ووضوح.


🔧 ملاحظات فنّية

◆ التدفّق بين فئات الأصول تمثيل نسبي، لا قياس مباشر — منصّات التداول لا توفّر تدفّق أوامر عبر-أصلي؛ لون الفئة يعرض الأداء النسبي مقابل المتوسط، بينما التدفّق المحاسبي الحقيقي يظهر في لوحة الشلال حصريًا.

◆ مصادر البيانات المطلوبة — بيانات FRED الاقتصادية، وCRYPTOCAP، وTVC، وNASDAQ؛ يُرجى التأكّد من توفّرها ضمن اشتراكك.

◆ معايرة الوحدات — الإعدادات الافتراضية مضبوطة على القيم الخام كما ترد من المصدر؛ راجع نافذة البيانات عند ظهور إنذار الوحدات لضبط المصادر.

◆ معايرة السياق — مقاييس مدّة الأنظمة وحدودها مبنية على بيانات السوق الحديثة، وقد تحتاج مراجعة عند تغيّر البيئة الكلّية الكبرى.

◆ الالتزامات التقنية — بلا إعادة رسم · اعتماد على البيانات المؤكّدة فقط · تأخير فترة واحدة مقصود بالتصميم لضمان عدم التسرّب المستقبلي · حساب فعّال لكل شمعة.


═════════════════════════════════════════════════════════════
⚠️ إخلاء المسؤولية
═════════════════════════════════════════════════════════════

هذا المؤشر لأغراض تعليمية وتحليلية فقط. لا يُمثل نصيحة مالية أو استثمارية أو تداولية. استخدمه بالتزامن مع استراتيجيتك الخاصة وإدارة المخاطر. لا يتحمل TradingView ولا المطور مسؤولية أي قرارات مالية أو خسائر.

## Source Code

````pine
//@version=6
// © The_lurker  Fawaz Al-Enezi  فواز العنزي

indicator("Macro Liquidity Waterfall Board [The_lurker] v4", overlay = false,
     max_polylines_count = 100, max_labels_count = 500, max_lines_count = 500,
     max_boxes_count = 500, max_bars_back = 500)

// ── Language ─────────────────────────────────────────────────────────────────
gLg = "🌐 Language"
lang = input.string("EN", "Language (اللغة)", options = ["EN", "AR"], group = gLg)
f_t(string k) =>
    switch k
        "net"    => lang == "AR" ? "صافي التدفّق" : "NET FLOW"
        "price"  => lang == "AR" ? "سعر BTC"      : "BTC PRICE"
        "dom"    => lang == "AR" ? "هيمنة BTC"     : "BTC.D"
        "wf"     => lang == "AR" ? "تركيب Δ السيولة العالمية" : "ΔGLOBAL LIQ — COMPOSITION"
        "neteff" => lang == "AR" ? "المحصّلة"       : "NET"
        "agr"    => lang == "AR" ? "اتّساق"         : "Agr"
        "gap"    => lang == "AR" ? "فجوة بيانات"    : "DATA GAP"
        "state"  => lang == "AR" ? "الحالة"          : "STATE"
        "neu"    => lang == "AR" ? "محايد"           : "NEUTRAL"
        "exp"    => lang == "AR" ? "توسّع متزامن"     : "EXPANSION"
        "lagg"   => lang == "AR" ? "سيولة بلا سعر"    : "LAGGING"
        "uns"    => lang == "AR" ? "رالي غير مدعوم"   : "UNSUPPORTED"
        "con"    => lang == "AR" ? "انكماش متزامن"    : "CONTRACTION"
        "brd"    => lang == "AR" ? "اتّساع"          : "breadth"
        "bBroad" => lang == "AR" ? "إشارة واسعة موثوقة" : "broad — regime reliable"
        "bNarr"  => lang == "AR" ? "إشارة ضيّقة — احذر" : "narrow — carried by few"
        "bMix"   => lang == "AR" ? "اتّساع مختلط"      : "mixed breadth"
        "outperf" => lang == "AR" ? "متفوّق"         : "outperf"
        "underp"  => lang == "AR" ? "متخلّف"          : "underp"
        "proxy"  => lang == "AR" ? "التدفّق وكيل — لا تدفّق أوامر حقيقي · عرض الحافة = |Δ%| لوغاريتمي داخل الطبقة" : "flow = PROXY · edge width = log |Δ%| within tier"
        "legend" => lang == "AR" ? "لون الفئة = أداء نسبي (أزرق متفوّق/أحمر متخلّف vs متوسط الطبقة) · التدفّق الحقيقي في الشلال فقط" : "class color = relative perf (teal out / red under vs tier avg) · real flow = waterfall only"
        => k

// ── Data / engine ────────────────────────────────────────────────────────────
gD = "Data"
tf       = input.timeframe("D", "Data timeframe", group = gD)
lookback = input.int(5, "Flow lookback (tf bars)", minval = 1, maxval = 200, group = gD)
allocBasis = input.string("Value (cap)", "Crypto allocation basis", options = ["Value (cap)", "Volume"], group = gD)

gU = "Units (FRED) — C1"
uBS  = input.string("Raw", "WALCL unit", options = ["Millions $", "Billions $", "Raw"], group = gU, tooltip = "TradingView quotes FRED series in RAW USD (verified empirically v4.1) — keep Raw unless your vendor differs. Check the RAW plots in the data window to calibrate.")
uRRP = input.string("Raw", "RRP unit",   options = ["Millions $", "Billions $", "Raw"], group = gU)
uTGA = input.string("Raw", "TGA unit",   options = ["Millions $", "Billions $", "Raw"], group = gU)
uM2  = input.string("Raw", "M2 unit",    options = ["Millions $", "Billions $", "Raw"], group = gU)
useM2 = input.bool(false, "Include M2 in identity", group = gU, tooltip = "OFF by default: monthly frequency contaminates a short-window Δ and M2 partially double-counts the Fed balance sheet. Standard net liquidity = BS − RRP − TGA.")

gN = "Normalization"
normMode = input.string("Standard Z", "Method", options = ["Standard Z", "Robust Z"], group = gN, tooltip = "Standard = (x-mean)/std. Robust = (x-median)/(1.4826·MAD). Label marks Z / rZ.")
zLenMkt   = input.int(50, "Z window — market (tf bars)", minval = 5, maxval = 500, group = gN)
zLenMacro = input.int(26, "Z window — macro (tf bars)", minval = 5, maxval = 500, group = gN)

gAg = "Direction agreement — C3"
agrLen = input.int(20, "Window (ACTIVE tf events)", minval = 4, maxval = 400, group = gAg, tooltip = "Counts only bars where the parent actually moved. Effective N is displayed; SE = √(0.25/N).")

gF = "Freshness (confidence channel)"
freshDelay = input.int(2, "DELAYED after (tf bars unchanged)", minval = 1, maxval = 100, group = gF)
freshStale = input.int(7, "STALE after (tf bars unchanged)", minval = 2, maxval = 300, group = gF)
freshFade  = input.float(0.6, "Max fade for stale", minval = 0.0, maxval = 0.95, step = 0.05, group = gF)

gDet = "Detail (progressive disclosure)"
detail = input.string("Standard", "Detail level", options = ["Minimal", "Standard", "Deep"], group = gDet, tooltip = "Minimal: name+value+Δ%+LED. Standard: +Z, sparkline, alloc. Deep: +attribution waterfall + agreement.")

gSp = "Sparklines (replaces ribbon — C2)"
sparkLen = input.int(10, "Sparkline points (tf samples)", minval = 4, maxval = 30, group = gSp)

gStt = "Regime state, persistence & timeline"
tlLen   = input.int(24, "Timeline ribbon length (tf bars)", minval = 6, maxval = 60, group = "Regime state, persistence & timeline")
medExp  = input.int(2, "Median duration — EXPANSION",   minval = 1, maxval = 100, group = "Regime state, persistence & timeline", tooltip = "Declared calibration from board data (daily runs). Override after your own Bar-Replay study on your tf. Absolute value scales with tf; the age÷median ratio is the transferable signal.")
medLag  = input.int(3, "Median duration — LAGGING",     minval = 1, maxval = 100, group = "Regime state, persistence & timeline")
medCon  = input.int(3, "Median duration — CONTRACTION", minval = 1, maxval = 100, group = "Regime state, persistence & timeline")
medUns  = input.int(2, "Median duration — UNSUPPORTED", minval = 1, maxval = 100, group = "Regime state, persistence & timeline")
stEps  = input.float(0.05, "State deadband |Δ%|", minval = 0.0, maxval = 5.0, step = 0.05, group = gStt, tooltip = "Either leg below this → NEUTRAL. Kills sign-flip noise.")
corLen = input.int(60, "Validity window (tf samples)", minval = 10, maxval = 300, group = gStt, tooltip = "Rolling Pearson r between Δ%Global Liq and Δ%CRYPTO. Needs ≥10 samples.")

gBub = "Flow bubbles"
showBub = input.bool(true, "Show bubbles", group = gBub)
bubN    = input.int(3, "Bubbles per edge", minval = 1, maxval = 8, group = gBub)
bubSpd  = input.float(0.25, "Speed", minval = 0.02, maxval = 2.0, step = 0.01, group = gBub)
volLen  = input.int(20, "Volume average window (tf bars)", minval = 5, maxval = 200, group = gBub, tooltip = "Bubble size = child volume ÷ SMA(volume, this window). Sizes: <0.75 tiny, <1.25 small, <2 normal, ≥2 large.")

// ── Symbols ──────────────────────────────────────────────────────────────────
gG = "Global liquidity (top tier)"
symBS  = input.symbol("FRED:WALCL",     "Fed balance sheet", group = gG)
symRRP = input.symbol("FRED:RRPONTSYD", "RRP", group = gG)
symTGA = input.symbol("FRED:WTREGEN",   "TGA", group = gG)
symM2  = input.symbol("FRED:M2SL",      "M2 (US)", group = gG)
sBS  = input.float(1.0, "weight × BS",  group = gG)
sRRP = input.float(1.0, "weight × RRP", group = gG)
sTGA = input.float(1.0, "weight × TGA", group = gG)
sM2  = input.float(1.0, "weight × M2",  group = gG)

gC = "Asset classes"
symBonds = input.symbol("NASDAQ:TLT",     "Bonds (price proxy)", group = gC)
symStock = input.symbol("SP:SPX",         "Stocks", group = gC)
symGold  = input.symbol("TVC:GOLD",       "Gold (spot)", group = gC, tooltip = "Spot index has no volume — use COMEX:GC1! for volume-sized bubbles.")
symOil   = input.symbol("TVC:USOIL",      "Oil (WTI)", group = gC, tooltip = "Spot index has no volume — use NYMEX:CL1! for volume-sized bubbles.")
symStab  = input.symbol("CRYPTOCAP:USDT", "Stablecoin", group = gC)
symCryp  = input.symbol("CRYPTOCAP:TOTAL","Crypto (total)", group = gC)

gA = "Crypto assets"
symA1 = input.symbol("CRYPTOCAP:BTC",    "Asset 1", group = gA)
nmA1  = input.string("BTC",  "Name 1", group = gA)
symA2 = input.symbol("CRYPTOCAP:ETH",    "Asset 2", group = gA)
nmA2  = input.string("ETH",  "Name 2", group = gA)
symA3 = input.symbol("CRYPTOCAP:XRP",    "Asset 3", group = gA)
nmA3  = input.string("XRP",  "Name 3", group = gA)
symA4 = input.symbol("CRYPTOCAP:OTHERS", "Asset 4", group = gA)
nmA4  = input.string("ALTS", "Name 4", group = gA)

gST = "Status bar"
symBTCp = input.symbol("BINANCE:BTCUSDT", "BTC price", group = gST)
symBTCd = input.symbol("CRYPTOCAP:BTC.D", "BTC dominance", group = gST)

gV = "Layout & visuals"
shiftX = input.int(-260, "Horizontal shift (bars)", minval = -1000, maxval = 0, group = gV)
hScale = input.float(0.4, "Horizontal scale", minval = 0.2, maxval = 3.0, step = 0.05, group = gV)
boxW   = input.float(42, "Node half-width", minval = 8, maxval = 200, group = gV)
boxH   = input.float(52, "Node half-height", minval = 20, maxval = 300, group = gV)
maxEdgeW = input.int(5, "Max edge width (px)", minval = 1, maxval = 8, group = gV)
cUp    = input.color(#26c6da, "In / up", group = gV)
cDn    = input.color(#ef5350, "Out / down", group = gV)
cCanvas= input.color(#0b0f14, "Canvas", group = gV)
cTxt   = input.color(#d1d4dc, "Text", group = gV)
cDim   = input.color(#5c6470, "Dim text", group = gV)
showLegend = input.bool(false, "Show color legend on chart", group = gV, tooltip = "Off by default. Explains that tier-1 node color = relative performance vs tier average, and that real inflow/outflow is only in the waterfall.")

// vertical canvas pin
plot(0,    "b", color = color.new(color.black, 100), display = display.pane)
plot(1120, "t", color = color.new(color.black, 100), display = display.pane)
bgcolor(cCanvas)

robustZ = normMode == "Robust Z"
detStd  = detail != "Minimal"
detDeep = detail == "Deep"

// ── Helpers: coords / format ─────────────────────────────────────────────────
f_px(float vx) => bar_index + shiftX + int(vx * hScale)
f_sizeF(int prio) => 0.72 + prio * 0.11

f_money(float v) =>
    if na(v)
        "n/a"
    else
        a = math.abs(v)
        sg = v < 0 ? "-" : ""
        a >= 1e12 ? sg + "$" + str.tostring(a / 1e12, "#.##") + "T" : a >= 1e9 ? sg + "$" + str.tostring(a / 1e9, "#.##") + "B" : a >= 1e6 ? sg + "$" + str.tostring(a / 1e6, "#.##") + "M" : sg + "$" + str.tostring(a, "#.#")
f_smoney(float v) => na(v) ? "n/a" : (v >= 0 ? "+" : "") + f_money(v)
f_pct(float v) => na(v) ? "n/a" : (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "%"
f_dircol(float v) => na(v) ? color.gray : v >= 0 ? cUp : cDn
f_zlabel(float z) => na(z) ? (robustZ ? "rZ —" : "Z —") : (robustZ ? "rZ " : "Z ") + (z >= 0 ? "+" : "") + str.tostring(z, "#.#")
f_conf(float fr) => na(fr) ? (1.0 - freshFade) : math.max(1.0 - freshFade, 1.0 - math.min(1.0, fr / freshStale) * freshFade)
f_freshcol(float fr) => na(fr) ? color.gray : fr <= freshDelay ? #66bb6a : fr <= freshStale ? #ffa726 : #ef5350

// ── Analytics inside security context (tf units by construction) ─────────────
f_ret(simple int lb) => close[lb] == 0 ? 0.0 : (close - close[lb]) / close[lb] * 100.0
f_zscore(float src, simple int len, bool rob) =>
    med = ta.median(src, len)
    mad = ta.median(math.abs(src - med), len)
    m   = ta.sma(src, len)
    sd  = ta.stdev(src, len)
    rz  = 1.4826 * mad == 0 ? 0.0 : (src - med) / (1.4826 * mad)
    sz  = sd == 0 ? 0.0 : (src - m) / sd
    rob ? rz : sz

// C4: lookahead_on + [1] — non-repaint without the extra tf bar of lag
f_d(simple string sym, simple int zl) =>
    request.security(sym, tf, [close[1], close[1 + lookback], volume[1], f_zscore(f_ret(lookback), zl, robustZ)[1], float(ta.barssince(ta.change(close) != 0))[1], (na(volume) ? na : volume / math.max(1e-10, ta.sma(volume, volLen)))[1]], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
f_one(simple string sym) =>
    request.security(sym, tf, close[1], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)

f_chg(float v, float vN) => na(v) or na(vN) or vN == 0 ? na : (v - vN) / vN * 100.0

// ── Fetch ────────────────────────────────────────────────────────────────────
[bsVr, bsNr, bsVol, bsZ, bsF, bsVQ] = f_d(symBS,  zLenMacro)
[rpVr, rpNr, rpVol, rpZ, rpF, rpVQ] = f_d(symRRP, zLenMacro)
[tgVr, tgNr, tgVol, tgZ, tgF, tgVQ] = f_d(symTGA, zLenMacro)
[m2Vr, m2Nr, m2Vol, m2Z, m2F, m2VQ] = f_d(symM2,  zLenMacro)
[boV, boN, boVol, boZ, boF, boVQ] = f_d(symBonds, zLenMkt)
[stV, stN, stVol, stZ, stF, stVQ] = f_d(symStock, zLenMkt)
[gdV, gdN, gdVol, gdZ, gdF, gdVQ] = f_d(symGold,  zLenMkt)
[olV, olN, olVol, olZ, olF, olVQ] = f_d(symOil,   zLenMkt)
[sbV, sbN, sbVol, sbZ, sbF, sbVQ] = f_d(symStab,  zLenMkt)
[crV, crN, crVol, crZ, crF, crVQ] = f_d(symCryp,  zLenMkt)
[a1V, a1N, a1Vol, a1Z, a1F, a1VQ] = f_d(symA1, zLenMkt)
[a2V, a2N, a2Vol, a2Z, a2F, a2VQ] = f_d(symA2, zLenMkt)
[a3V, a3N, a3Vol, a3Z, a3F, a3VQ] = f_d(symA3, zLenMkt)
[a4V, a4N, a4Vol, a4Z, a4F, a4VQ] = f_d(symA4, zLenMkt)
btcPrice = f_one(symBTCp)
btcDom   = f_one(symBTCd)

// ── C1: unit normalization → raw USD before ANY arithmetic ───────────────────
f_uk(string u) => u == "Millions $" ? 1e6 : u == "Billions $" ? 1e9 : 1.0
bsV  = bsVr * f_uk(uBS)
bsN2 = bsNr * f_uk(uBS)
rpV  = rpVr * f_uk(uRRP)
rpN2 = rpNr * f_uk(uRRP)
tgV  = tgVr * f_uk(uTGA)
tgN2 = tgNr * f_uk(uTGA)
m2V  = m2Vr * f_uk(uM2)
m2N2 = m2Nr * f_uk(uM2)

// ── Global liquidity + attribution (C5: M2 optional) ─────────────────────────
gNow  = bsV * sBS - rpV * sRRP - tgV * sTGA + (useM2 ? m2V * sM2 : 0.0)
gPast = bsN2 * sBS - rpN2 * sRRP - tgN2 * sTGA + (useM2 ? m2N2 * sM2 : 0.0)
gChg  = f_chg(gNow, gPast)
dataGap = na(bsVr) or na(rpVr) or na(tgVr) or (useM2 and na(m2Vr))

cFED = (bsV - bsN2) * sBS
cRRP = -((rpV - rpN2) * sRRP)
cTGA = -((tgV - tgN2) * sTGA)
cM2  = useM2 ? (m2V - m2N2) * sM2 : na
netEffect = cFED + cRRP + cTGA + (useM2 ? cM2 : 0.0)

// ── C3: tf-sampled state (gZ, gFresh, sparklines, agreement) ─────────────────
newTF = timeframe.change(tf)

// gZ from tf-sampled Δ% series (array-based; O(n) only on new tf bar)
f_zArr(array<float> a, bool rob) =>
    float z = na
    n = array.size(a)
    if n >= 10
        x = array.get(a, n - 1)
        if rob
            med = array.median(a)
            dev = array.new<float>()
            for i = 0 to n - 1
                array.push(dev, math.abs(array.get(a, i) - med))
            mad = array.median(dev)
            z := mad == 0 ? 0.0 : (x - med) / (1.4826 * mad)
        else
            m = array.avg(a)
            sd = array.stdev(a)
            z := sd == 0 ? 0.0 : (x - m) / sd
    z

var gSamp = array.new<float>()
var gChgA = array.new<float>()
var float gZv = na
var int   gFreshCnt = 0
var float gPrevS = na
if newTF and not na(gNow)
    array.push(gSamp, gNow)
    if array.size(gSamp) > zLenMacro + lookback + 2
        array.shift(gSamp)
    ns = array.size(gSamp)
    if ns > lookback
        base = array.get(gSamp, ns - 1 - lookback)
        if base != 0
            array.push(gChgA, (array.get(gSamp, ns - 1) - base) / base * 100.0)
            if array.size(gChgA) > zLenMacro
                array.shift(gChgA)
    gZv := f_zArr(gChgA, robustZ)
    gFreshCnt := not na(gPrevS) and gNow != gPrevS ? 0 : gFreshCnt + 1
    gPrevS := gNow

// sparkline history: one var array per CALL SITE, sampled once per tf bar (C2)
f_hist(float v, bool nb, simple int cap) =>
    var a = array.new<float>()
    if nb and not na(v)
        array.push(a, v)
        if array.size(a) > cap
            array.shift(a)
    a
histG  = f_hist(gNow, newTF, sparkLen)
histBo = f_hist(boV,  newTF, sparkLen)
histSt = f_hist(stV,  newTF, sparkLen)
histGd = f_hist(gdV,  newTF, sparkLen)
histOl = f_hist(olV,  newTF, sparkLen)
histSb = f_hist(sbV,  newTF, sparkLen)
histCr = f_hist(crV,  newTF, sparkLen)
histA1 = f_hist(a1V,  newTF, sparkLen)
histA2 = f_hist(a2V,  newTF, sparkLen)
histA3 = f_hist(a3V,  newTF, sparkLen)
histA4 = f_hist(a4V,  newTF, sparkLen)

// concurrent direction agreement over ACTIVE tf events; effective N + SE (C3)
f_agree(float pv, float cv, bool nb, simple int n) =>
    var m = array.new<float>()
    var float pp = na
    var float cp = na
    if nb
        dp = pv - pp
        dc = cv - cp
        if not na(dp) and not na(dc) and dp != 0
            array.push(m, math.sign(dp) == math.sign(dc) and dc != 0 ? 1.0 : 0.0)
            if array.size(m) > n
                array.shift(m)
        pp := pv
        cp := cv
    nEff = array.size(m)
    [nEff > 0 ? array.avg(m) * 100.0 : na, nEff]
[agBo, nBo] = f_agree(gNow, boV, newTF, agrLen)
[agSt, nSt] = f_agree(gNow, stV, newTF, agrLen)
[agGd, nGd] = f_agree(gNow, gdV, newTF, agrLen)
[agOl, nOl] = f_agree(gNow, olV, newTF, agrLen)
[agSb, nSb] = f_agree(gNow, sbV, newTF, agrLen)
[agCr, nCr] = f_agree(gNow, crV, newTF, agrLen)
[agA1, nA1] = f_agree(crV, a1V, newTF, agrLen)
[agA2, nA2] = f_agree(crV, a2V, newTF, agrLen)
[agA3, nA3] = f_agree(crV, a3V, newTF, agrLen)
[agA4, nA4] = f_agree(crV, a4V, newTF, agrLen)

// ── Regime state (S1) + hypothesis validity (S3) ─────────────────────────────
cryChg = f_chg(crV, crN)
stateId = na(gChg) or na(cryChg) ? 0 : math.abs(gChg) < stEps or math.abs(cryChg) < stEps ? 0 : gChg > 0 and cryChg > 0 ? 1 : gChg > 0 ? 2 : cryChg > 0 ? 3 : 4
stChg = ta.change(stateId) != 0
var int stAge = 0
stAge := stChg ? 0 : newTF ? stAge + 1 : stAge
f_stName(int s) => s == 1 ? f_t("exp") : s == 2 ? f_t("lagg") : s == 3 ? f_t("uns") : s == 4 ? f_t("con") : f_t("neu")
f_stCol(int s) => s == 1 ? cUp : s == 4 ? cDn : s == 0 ? cDim : #ffa726
f_stMed(int s) => s == 1 ? medExp : s == 2 ? medLag : s == 3 ? medUns : s == 4 ? medCon : 0

// P2: timeline ribbon history (one tf-sample per bar)
var tlStates = array.new<int>()
if newTF
    array.push(tlStates, stateId)
    if array.size(tlStates) > tlLen
        array.shift(tlStates)

var crSamp = array.new<float>()
var float crChgS = na
if newTF and not na(crV)
    array.push(crSamp, crV)
    if array.size(crSamp) > lookback + 2
        array.shift(crSamp)
    ncs = array.size(crSamp)
    if ncs > lookback
        cb = array.get(crSamp, ncs - 1 - lookback)
        crChgS := cb == 0 ? na : (array.get(crSamp, ncs - 1) - cb) / cb * 100.0
var gCorA = array.new<float>()
var cCorA = array.new<float>()
var float liqCorr = na
if newTF
    gLast = array.size(gChgA) > 0 ? array.get(gChgA, array.size(gChgA) - 1) : na
    if not na(gLast) and not na(crChgS)
        array.push(gCorA, gLast)
        array.push(cCorA, crChgS)
        if array.size(gCorA) > corLen
            array.shift(gCorA)
            array.shift(cCorA)
    if array.size(gCorA) >= 10
        sg = array.stdev(gCorA)
        sc = array.stdev(cCorA)
        liqCorr := sg == 0 or sc == 0 ? na : array.covariance(gCorA, cCorA) / (sg * sc)

// ── Crypto breadth (W1): cross-sectional agreement with liquidity sign ────────
f_aChg(float v, float vN) => na(v) or na(vN) or vN == 0 ? na : (v - vN) / vN * 100.0
brdChgA1 = f_aChg(a1V, a1N)
brdChgA2 = f_aChg(a2V, a2N)
brdChgA3 = f_aChg(a3V, a3N)
brdChgA4 = f_aChg(a4V, a4N)
gSign = na(gChg) or math.abs(gChg) < stEps ? 0 : gChg > 0 ? 1 : -1
f_brdOne(float ch) => na(ch) or math.abs(ch) < stEps ? 0 : (math.sign(ch) == gSign ? 1 : -1)
brdActive = (f_brdOne(brdChgA1) != 0 ? 1 : 0) + (f_brdOne(brdChgA2) != 0 ? 1 : 0) + (f_brdOne(brdChgA3) != 0 ? 1 : 0) + (f_brdOne(brdChgA4) != 0 ? 1 : 0)
brdAgree  = (f_brdOne(brdChgA1) == 1 ? 1 : 0) + (f_brdOne(brdChgA2) == 1 ? 1 : 0) + (f_brdOne(brdChgA3) == 1 ? 1 : 0) + (f_brdOne(brdChgA4) == 1 ? 1 : 0)
brdPct = gSign == 0 or brdActive == 0 ? na : brdAgree / brdActive * 100.0

// ── Relative flow (F1): cross-sectional z of tier-1 class Δ% ─────────────────
rfBo = f_chg(boV, boN)
rfSt = f_chg(stV, stN)
rfCr = f_chg(crV, crN)
rfSb = f_chg(sbV, sbN)
rfGd = f_chg(gdV, gdN)
rfOl = f_chg(olV, olN)
f_tierStats() =>
    s = 0.0
    c = 0
    for v in array.from(rfBo, rfSt, rfCr, rfSb, rfGd, rfOl)
        if not na(v)
            s += v
            c += 1
    mn = c > 0 ? s / c : na
    ss = 0.0
    for v in array.from(rfBo, rfSt, rfCr, rfSb, rfGd, rfOl)
        if not na(v)
            ss += (v - mn) * (v - mn)
    sd = c > 1 ? math.sqrt(ss / c) : na
    [mn, sd]
[rfMean, rfStd] = f_tierStats()
f_relZ(float v) => na(v) or na(rfStd) or rfStd == 0 ? na : (v - rfMean) / rfStd

// ── Node model ───────────────────────────────────────────────────────────────
type Node
    string name
    float  vx
    float  vy
    float  val
    float  chg
    float  z
    float  fresh
    float  alloc
    int    parent
    bool   isCap
    int    prio
    float  flow

var nodes = array.new<Node>()
f_vshow(Node n) => n.isCap ? f_money(n.val) : (na(n.val) ? "n/a" : str.tostring(n.val, "#.##"))
f_flowcol(Node n) => na(n.flow) ? f_dircol(n.chg) : n.flow >= 0 ? cUp : cDn
// ── Drawing primitives ───────────────────────────────────────────────────────
f_cols(array<float> h, float vx, float bw, float yBase, float hMax) =>
    n = array.size(h)
    if n >= 3
        mxd = 0.0
        for k = 0 to n - 2
            mxd := math.max(mxd, math.abs(array.get(h, k + 1) - array.get(h, k)))
        cw = 2.0 * bw * 0.88 / (n - 1)
        for k = 0 to n - 2
            d = array.get(h, k + 1) - array.get(h, k)
            hh = mxd == 0 ? 0.15 * hMax : (0.15 + 0.85 * math.min(1.0, math.abs(d) / mxd)) * hMax
            xk = vx - bw * 0.88 + k * cw
            bcol = d > 0 ? cUp : d < 0 ? cDn : cDim
            box.new(f_px(xk), yBase + hh, f_px(xk + cw * 0.68), yBase, border_color = color.new(bcol, 100), bgcolor = color.new(bcol, 25), xloc = xloc.bar_index)

f_node(Node n, array<float> h) =>
    col  = f_flowcol(n)
    conf = f_conf(n.fresh)
    sf   = f_sizeF(n.prio)
    bw   = boxW * sf
    bh   = boxH * sf
    fadeTr = int((1.0 - conf) * 60)
    txtTr  = int((1.0 - conf) * 45)
    xL = f_px(n.vx - bw)
    xR = f_px(n.vx + bw)
    yT = n.vy + bh
    yB = n.vy - bh
    box.new(xL, yT, xR, yB, border_color = color.new(col, math.min(99, 40 + fadeTr)), bgcolor = color.new(col, math.min(99, 84 + int(fadeTr / 4))), border_width = 1, xloc = xloc.bar_index)
    cx = f_px(n.vx)
    tc = color.new(cTxt, math.min(95, txtTr))
    cc = color.new(col, math.min(95, txtTr))
    nm = n.name + (na(n.alloc) ? "" : " " + str.tostring(n.alloc, "#") + "%")
    label.new(cx, n.vy + bh * 0.62, nm, style = label.style_none, textcolor = tc, size = size.normal, xloc = xloc.bar_index)
    label.new(f_px(n.vx + bw * 0.80), n.vy + bh * 0.68, "●", style = label.style_none, textcolor = f_freshcol(n.fresh), size = size.small, xloc = xloc.bar_index)
    label.new(cx, n.vy + bh * 0.10, f_vshow(n) + "  " + f_pct(n.chg), style = label.style_none, textcolor = cc, size = size.small, xloc = xloc.bar_index)
    if detStd
        label.new(cx, n.vy - bh * 0.32, f_zlabel(n.z), style = label.style_none, textcolor = color.new(cDim, txtTr), size = size.small, xloc = xloc.bar_index)
        f_cols(h, n.vx, bw, n.vy - bh * 0.92, bh * 0.37)

f_bsize(float vq) => na(vq) ? size.tiny : vq < 0.75 ? size.tiny : vq < 1.25 ? size.small : vq < 2.0 ? size.normal : size.large

f_bezPt(float x1v, float y1, float x2v, float y2, float t) =>
    u = 1.0 - t
    ym = (y1 + y2) / 2.0
    bxv = u * u * u * x1v + 3 * u * u * t * x1v + 3 * u * t * t * x2v + t * t * t * x2v
    byv = u * u * u * y1 + 3 * u * u * t * ym + 3 * u * t * t * ym + t * t * t * y2
    [f_px(bxv), byv]

// edge: cubic-Bezier ribbon (mockup path form), width px = log-|Δ%| in tier
f_edge(Node p, Node c, float startFrac, int wpx, float agr, int nEff) =>
    pbh = boxH * f_sizeF(p.prio)
    pbw = boxW * f_sizeF(p.prio)
    cbh = boxH * f_sizeF(c.prio)
    x1v = p.vx + startFrac * pbw * 0.65
    y1 = p.vy - pbh
    x2v = c.vx
    y2 = c.vy + cbh
    ym = (y1 + y2) / 2.0
    col = f_flowcol(c)
    conf = f_conf(c.fresh)
    tr = int(math.min(92, 30 + (1.0 - conf) * 55))
    pts = array.new<chart.point>()
    steps = 14
    for i = 0 to steps
        t = i / float(steps)
        u = 1.0 - t
        bxv = u * u * u * x1v + 3 * u * u * t * x1v + 3 * u * t * t * x2v + t * t * t * x2v
        byv = u * u * u * y1 + 3 * u * u * t * ym + 3 * u * t * t * ym + t * t * t * y2
        array.push(pts, chart.point.from_index(f_px(bxv), byv))
    polyline.new(pts, line_color = color.new(col, tr), line_width = wpx, xloc = xloc.bar_index)
    if detDeep and not na(agr) and nEff > 0
        exc = agr - 50.0
        se  = math.sqrt(0.25 / nEff) * 100.0
        acol = math.abs(exc) < se ? cDim : exc > 0 ? cUp : cDn
        label.new(f_px(c.vx), y2 + 16, f_t("agr") + " " + str.tostring(agr, "#") + " · N" + str.tostring(nEff) + " · " + (exc >= 0 ? "+" : "") + str.tostring(exc, "#"), style = label.style_none, textcolor = color.new(acol, 15), size = size.small, xloc = xloc.bar_index)

// ── Attribution waterfall (Deep) — exact accounting identity ─────────────────
f_wfY(float v, float lo, float k) => 18.0 + (v - lo) * k

f_waterfall() =>
    nCols = useM2 ? 5 : 4
    x0v  = 60.0
    barWv = useM2 ? 70.0 : 88.0
    gapv  = useM2 ? 16.0 : 22.0
    H = 110.0
    comps = array.new<float>()
    names = array.new<string>()
    fresh = array.new<float>()
    array.push(comps, cFED)
    array.push(names, "FED")
    array.push(fresh, bsF)
    if useM2
        array.push(comps, cM2)
        array.push(names, "M2")
        array.push(fresh, m2F)
    array.push(comps, cRRP)
    array.push(names, "RRP")
    array.push(fresh, rpF)
    array.push(comps, cTGA)
    array.push(names, "TGA")
    array.push(fresh, tgF)
    nC = array.size(comps)
    levels = array.new<float>()
    array.push(levels, 0.0)
    for i = 0 to nC - 1
        array.push(levels, array.get(levels, i) + nz(array.get(comps, i)))
    lo = math.min(0.0, array.min(levels))
    hi = math.max(0.0, array.max(levels))
    k = hi - lo == 0 ? 0.0 : H / (hi - lo)
    line.new(f_px(x0v - 12), f_wfY(0.0, lo, k), f_px(x0v + (nC + 1) * (barWv + gapv) + 10), f_wfY(0.0, lo, k), color = color.new(cDim, 40), xloc = xloc.bar_index)
    label.new(f_px(x0v + (barWv + gapv) * (nC + 1) / 2.0), 170.0, f_t("wf") + "  (" + str.tostring(lookback) + " tf)", style = label.style_none, textcolor = color.new(cTxt, 20), size = size.small, xloc = xloc.bar_index)
    float prevY = na
    int   prevXR = na
    for i = 0 to nC - 1
        c = nz(array.get(comps, i))
        l0 = array.get(levels, i)
        l1 = array.get(levels, i + 1)
        xL = f_px(x0v + i * (barWv + gapv))
        xR = f_px(x0v + i * (barWv + gapv) + barWv)
        yHi = f_wfY(math.max(l0, l1), lo, k)
        yLo = f_wfY(math.min(l0, l1), lo, k)
        bc = c >= 0 ? cUp : cDn
        box.new(xL, math.max(yHi, yLo + 3), xR, yLo, border_color = color.new(bc, 35), bgcolor = color.new(bc, 55), xloc = xloc.bar_index)
        stale = array.get(fresh, i) > lookback
        label.new(int((xL + xR) / 2), yHi + (i % 2 == 0 ? 14 : 30), array.get(names, i) + " " + f_smoney(c) + (stale ? " ⚠" : ""), style = label.style_none, textcolor = stale ? color.new(#ffa726, 10) : color.new(cTxt, 20), size = size.small, xloc = xloc.bar_index)
        yEnd = f_wfY(l1, lo, k)
        if not na(prevY)
            line.new(prevXR, prevY, xL, prevY, color = color.new(cDim, 30), style = line.style_dashed, xloc = xloc.bar_index)
        prevY := yEnd
        prevXR := xR
    xNl = f_px(x0v + nC * (barWv + gapv))
    xNr = f_px(x0v + nC * (barWv + gapv) + barWv)
    yN0 = f_wfY(0.0, lo, k)
    yN1 = f_wfY(netEffect, lo, k)
    if not na(prevY)
        line.new(prevXR, prevY, xNl, prevY, color = color.new(cDim, 30), style = line.style_dashed, xloc = xloc.bar_index)
    box.new(xNl, math.max(yN0, yN1), xNr, math.min(yN0, yN1), border_color = color.new(f_dircol(netEffect), 15), bgcolor = color.new(f_dircol(netEffect), 35), xloc = xloc.bar_index)
    label.new(int((xNl + xNr) / 2), math.max(yN0, yN1) + 16, f_t("neteff") + " " + f_smoney(netEffect), style = label.style_none, textcolor = color.new(cTxt, 5), size = size.small, xloc = xloc.bar_index)

// ── Metric header (borderless: label / value / delta) ────────────────────────
f_metric(float vx, string lab, string val, string dl, color dc) =>
    label.new(f_px(vx), 1085, lab, style = label.style_none, textcolor = color.new(cDim, 0), size = size.small, xloc = xloc.bar_index)
    label.new(f_px(vx), 1052, val, style = label.style_none, textcolor = color.new(cTxt, 0), size = size.large, xloc = xloc.bar_index)
    if dl != ""
        label.new(f_px(vx), 1024, dl, style = label.style_none, textcolor = dc, size = size.small, xloc = xloc.bar_index)

// ── Build ────────────────────────────────────────────────────────────────────
f_build() =>
    array.clear(nodes)
    array.push(nodes, Node.new("GLOBAL LIQ", 300, 890, gNow, gChg, gZv, float(gFreshCnt), na, -1, true, 5, na))
    array.push(nodes, Node.new("BONDS",  55,  620, boV, f_chg(boV, boN), boZ, boF, na, 0, false, 3, f_relZ(rfBo)))
    array.push(nodes, Node.new("STOCKS", 172, 620, stV, f_chg(stV, stN), stZ, stF, na, 0, false, 3, f_relZ(rfSt)))
    array.push(nodes, Node.new("CRYPTO", 300, 620, crV, f_chg(crV, crN), crZ, crF, na, 0, true, 5, f_relZ(rfCr)))
    array.push(nodes, Node.new("STABLE", 415, 620, sbV, f_chg(sbV, sbN), sbZ, sbF, na, 0, true, 3, f_relZ(rfSb)))
    array.push(nodes, Node.new("GOLD",   522, 620, gdV, f_chg(gdV, gdN), gdZ, gdF, na, 0, false, 2, f_relZ(rfGd)))
    array.push(nodes, Node.new("OIL",    607, 620, olV, f_chg(olV, olN), olZ, olF, na, 0, false, 2, f_relZ(rfOl)))
    array.push(nodes, Node.new(nmA1, 150, 330, a1V, f_chg(a1V, a1N), a1Z, a1F, na, 3, true, 4, na))
    array.push(nodes, Node.new(nmA2, 250, 330, a2V, f_chg(a2V, a2N), a2Z, a2F, na, 3, true, 3, na))
    array.push(nodes, Node.new(nmA3, 350, 330, a3V, f_chg(a3V, a3N), a3Z, a3F, na, 3, true, 2, na))
    array.push(nodes, Node.new(nmA4, 450, 330, a4V, f_chg(a4V, a4N), a4Z, a4F, na, 3, true, 2, na))
    b1 = allocBasis == "Volume" ? a1Vol : a1V
    b2 = allocBasis == "Volume" ? a2Vol : a2V
    b3 = allocBasis == "Volume" ? a3Vol : a3V
    b4 = allocBasis == "Volume" ? a4Vol : a4V
    su = nz(b1) + nz(b2) + nz(b3) + nz(b4)
    if su > 0
        q1 = array.get(nodes, 7)
        q1.alloc := nz(b1) / su * 100.0
        q2 = array.get(nodes, 8)
        q2.alloc := nz(b2) / su * 100.0
        q3 = array.get(nodes, 9)
        q3.alloc := nz(b3) / su * 100.0
        q4 = array.get(nodes, 10)
        q4.alloc := nz(b4) / su * 100.0

// edge line-count within sibling tier (log-scaled |Δ%|) — bounded [1..maxEdgeW]
f_mag(float chg) => na(chg) ? 0.0 : math.log(1.0 + math.abs(chg))
f_nl(float chg, float mx) => na(chg) or mx <= 0 ? 1 : 1 + int(math.round(f_mag(chg) / mx * (maxEdgeW - 1)))

// ── Render: once per chart bar, NOT per tick (all data confirmed-bar) ────────
if (barstate.islast and barstate.isconfirmed) or barstate.islastconfirmedhistory
    for pp in polyline.all
        polyline.delete(pp)
    for ll in line.all
        line.delete(ll)
    for lb in label.all
        label.delete(lb)
    for bx in box.all
        box.delete(bx)


    f_build()

    ch1 = f_chg(boV, boN)
    ch2 = f_chg(stV, stN)
    ch3 = f_chg(crV, crN)
    ch4 = f_chg(sbV, sbN)
    ch5 = f_chg(gdV, gdN)
    ch6 = f_chg(olV, olN)
    mxT1 = math.max(f_mag(ch1), math.max(f_mag(ch2), math.max(f_mag(ch3), math.max(f_mag(ch4), math.max(f_mag(ch5), f_mag(ch6))))))
    ca1 = f_chg(a1V, a1N)
    ca2 = f_chg(a2V, a2N)
    ca3 = f_chg(a3V, a3N)
    ca4 = f_chg(a4V, a4N)
    mxT2 = math.max(f_mag(ca1), math.max(f_mag(ca2), math.max(f_mag(ca3), f_mag(ca4))))

    // edges (order matches node indices 1..9)
    f_edge(array.get(nodes, 0), array.get(nodes, 1), -1.0,  f_nl(ch1, mxT1), agBo, nBo)
    f_edge(array.get(nodes, 0), array.get(nodes, 2), -0.6,  f_nl(ch2, mxT1), agSt, nSt)
    f_edge(array.get(nodes, 0), array.get(nodes, 3),  0.0,  f_nl(ch3, mxT1), agCr, nCr)
    f_edge(array.get(nodes, 0), array.get(nodes, 4),  0.5,  f_nl(ch4, mxT1), agSb, nSb)
    f_edge(array.get(nodes, 0), array.get(nodes, 5),  0.8,  f_nl(ch5, mxT1), agGd, nGd)
    f_edge(array.get(nodes, 0), array.get(nodes, 6),  1.0,  f_nl(ch6, mxT1), agOl, nOl)
    f_edge(array.get(nodes, 3), array.get(nodes, 7), -0.75, f_nl(ca1, mxT2), agA1, nA1)
    f_edge(array.get(nodes, 3), array.get(nodes, 8), -0.25, f_nl(ca2, mxT2), agA2, nA2)
    f_edge(array.get(nodes, 3), array.get(nodes, 9),  0.25, f_nl(ca3, mxT2), agA3, nA3)
    f_edge(array.get(nodes, 3), array.get(nodes, 10), 0.75, f_nl(ca4, mxT2), agA4, nA4)

    // nodes (Pine forbids nested collections → explicit hist per node)
    f_node(array.get(nodes, 0), histG)
    f_node(array.get(nodes, 1), histBo)
    f_node(array.get(nodes, 2), histSt)
    f_node(array.get(nodes, 3), histCr)
    f_node(array.get(nodes, 4), histSb)
    f_node(array.get(nodes, 5), histGd)
    f_node(array.get(nodes, 6), histOl)
    f_node(array.get(nodes, 7), histA1)
    f_node(array.get(nodes, 8), histA2)
    f_node(array.get(nodes, 9), histA3)
    f_node(array.get(nodes, 10), histA4)

    // data-quality guard on GLOBAL
    g0 = array.get(nodes, 0)
    if dataGap
        label.new(f_px(g0.vx), g0.vy + boxH * f_sizeF(g0.prio) + 22, "⚠ " + f_t("gap"), style = label.style_none, textcolor = color.new(#ffa726, 0), size = size.normal, xloc = xloc.bar_index)
    if not dataGap and not na(gNow) and (math.abs(gNow) < 1e11 or math.abs(gNow) > 1e14)
        label.new(f_px(g0.vx), g0.vy + boxH * f_sizeF(g0.prio) + 22, "⚠ UNIT? — calibrate FRED units (see data window RAW plots)", style = label.style_none, textcolor = color.new(#ffa726, 0), size = size.normal, xloc = xloc.bar_index)

    cNb = array.get(nodes, 3)
    cbhb = boxH * f_sizeF(cNb.prio)
    if not na(brdPct)
        bcol = brdPct >= 66 ? cUp : brdPct <= 34 ? cDn : #ffa726
        label.new(f_px(cNb.vx), cNb.vy - cbhb * 0.60, f_t("brd") + " " + str.tostring(brdAgree, "#") + "/" + str.tostring(brdActive, "#") + " ▲ " + str.tostring(brdPct, "#") + "%", style = label.style_none, textcolor = color.new(bcol, 0), size = size.small, xloc = xloc.bar_index)
        noteTxt = stateId == 0 ? "" : brdPct >= 66 ? f_t("bBroad") : brdPct <= 34 ? f_t("bNarr") : f_t("bMix")
        if noteTxt != ""
            label.new(f_px(400), 985, "· " + noteTxt, style = label.style_none, textcolor = color.new(bcol, 10), size = size.small, xloc = xloc.bar_index)
    if detStd
        f_waterfall()

    // P2: regime timeline ribbon
    tlN = array.size(tlStates)
    if tlN >= 2
        tlX0 = 40.0
        tlX1 = 560.0
        tlY = 1006.0
        tlH = 12.0
        cw = (tlX1 - tlX0) / tlLen
        for i = 0 to tlN - 1
            s = array.get(tlStates, i)
            sc = f_stCol(s)
            xk = tlX0 + (tlLen - tlN + i) * cw
            box.new(f_px(xk), tlY + tlH, f_px(xk + cw * 0.86), tlY, border_color = color.new(sc, 100), bgcolor = color.new(sc, s == 0 ? 55 : 20), xloc = xloc.bar_index)
    f_metric(75,  "GLOBAL LIQ", f_money(gNow), f_pct(gChg) + " · " + f_zlabel(gZv), f_dircol(gChg))
    stMed = f_stMed(stateId)
    stretch = stMed > 0 ? stAge / float(stMed) : na
    stSub = stateId == 0 ? str.tostring(stAge) + " × " + tf : "age " + str.tostring(stAge) + " (med " + str.tostring(stMed) + ") ×" + (na(stretch) ? "" : str.tostring(stretch, "#.#"))
    f_metric(235, f_t("state"), f_stName(stateId), stSub, f_stCol(stateId))
    f_metric(395, f_t("price"), na(btcPrice) ? "n/a" : "$" + str.tostring(btcPrice, "#.#"), "", color.new(cDim, 0))
    f_metric(545, f_t("dom"), na(btcDom) ? "n/a" : str.tostring(btcDom, "#.#") + "%", "", color.new(cDim, 0))
    if showLegend
        label.new(f_px(75), 968, f_t("legend"), style = label.style_none, textcolor = color.new(cDim, 20), size = size.small, xloc = xloc.bar_index)
    rTxt = na(liqCorr) ? "LIQ↔CRY r n/a" : "LIQ↔CRY r " + (liqCorr >= 0 ? "+" : "") + str.tostring(liqCorr, "#.##") + " · n" + str.tostring(array.size(gCorA))
    label.new(f_px(75), 985, rTxt, style = label.style_none, textcolor = na(liqCorr) or math.abs(liqCorr) < 0.3 ? color.new(cDim, 0) : liqCorr > 0 ? color.new(cUp, 10) : color.new(cDn, 10), size = size.small, xloc = xloc.bar_index)
    rrpRate = na(rpV) or na(rpN2) ? na : (rpV - rpN2) / lookback
    tgaRate = na(tgV) or na(tgN2) ? na : (tgV - tgN2) / lookback
    g0h = array.get(nodes, 0)
    label.new(f_px(g0h.vx), g0h.vy - boxH * f_sizeF(g0h.prio) - 48, "RRP Δ/tf " + f_smoney(rrpRate) + " · TGA Δ/tf " + f_smoney(tgaRate), style = label.style_none, textcolor = color.new(cDim, 0), size = size.small, xloc = xloc.bar_index)

// ── Flow bubbles: per-tick, bubbles only (cards/edges/waterfall stay static) ─
var bubLbls = array.new<label>()

f_bub(Node p, Node c, float frac, float vq, float phase) =>
    pbh = boxH * f_sizeF(p.prio)
    pbw = boxW * f_sizeF(p.prio)
    cbh = boxH * f_sizeF(c.prio)
    x1v = p.vx + frac * pbw * 0.65
    y1 = p.vy - pbh
    y2 = c.vy + cbh
    col = f_flowcol(c)
    trb = int(math.min(92, 15 + (1.0 - f_conf(c.fresh)) * 60))
    outFlow = not na(c.chg) and c.chg < 0
    for i = 0 to bubN - 1
        ph = phase * bubSpd + i / float(bubN)
        t0 = ph - math.floor(ph)
        t = outFlow ? 1.0 - t0 : t0
        [bxp, byp] = f_bezPt(x1v, y1, c.vx, y2, t)
        array.push(bubLbls, label.new(bxp, byp, "", style = label.style_circle, color = color.new(col, trb), size = f_bsize(vq), xloc = xloc.bar_index))

varip float animT = 0.0
if barstate.islast and showBub and array.size(nodes) > 0
    animT := animT + 0.05
    for lb in bubLbls
        label.delete(lb)
    array.clear(bubLbls)
    f_bub(array.get(nodes, 0), array.get(nodes, 1), -1.0,  boVQ, animT)
    f_bub(array.get(nodes, 0), array.get(nodes, 2), -0.6,  stVQ, animT)
    f_bub(array.get(nodes, 0), array.get(nodes, 3),  0.0,  crVQ, animT)
    f_bub(array.get(nodes, 0), array.get(nodes, 4),  0.5,  sbVQ, animT)
    f_bub(array.get(nodes, 0), array.get(nodes, 5),  0.8,  gdVQ, animT)
    f_bub(array.get(nodes, 0), array.get(nodes, 6),  1.0,  olVQ, animT)
    f_bub(array.get(nodes, 3), array.get(nodes, 7), -0.75, a1VQ, animT)
    f_bub(array.get(nodes, 3), array.get(nodes, 8), -0.25, a2VQ, animT)
    f_bub(array.get(nodes, 3), array.get(nodes, 9),  0.25, a3VQ, animT)
    f_bub(array.get(nodes, 3), array.get(nodes, 10), 0.75, a4VQ, animT)

// ── Alerts (S2): edge-triggered only ─────────────────────────────────────────
unitBad = not na(gNow) and (math.abs(gNow) < 1e11 or math.abs(gNow) > 1e14)
qBad = dataGap or unitBad
alertcondition(stChg, "State transition (any)", "Liquidity regime state changed")
alertcondition(stChg and stateId == 1, "Enter EXPANSION", "Liq↑ & Crypto↑ — concurrent expansion")
alertcondition(stChg and stateId == 2, "Enter LAGGING", "Liq↑ & Crypto↓ — liquidity without price")
alertcondition(stChg and stateId == 3, "Enter UNSUPPORTED", "Liq↓ & Crypto↑ — unsupported rally")
alertcondition(stChg and stateId == 4, "Enter CONTRACTION", "Liq↓ & Crypto↓ — concurrent contraction")
alertcondition(ta.change(qBad ? 1 : 0) > 0, "Data quality", "Board data gap or unit sanity failure")

// ── Data window ──────────────────────────────────────────────────────────────
plot(gNow, "Global liquidity ($)", display = display.data_window)
plot(gZv,  "Global liq Z (tf-sampled)", display = display.data_window)
plot(netEffect, "Net effect ($)", display = display.data_window)
plot(stateId, "Regime state (0..4)", display = display.data_window)
plot(liqCorr, "LIQ↔CRYPTO rolling r", display = display.data_window)
plot(brdPct, "Crypto breadth %", display = display.data_window)
plot(stAge, "State age (tf bars)", display = display.data_window)
plot(f_relZ(rfCr), "Crypto relative-flow z", display = display.data_window)
plot(bsVr, "RAW vendor quote — WALCL", display = display.data_window)
plot(rpVr, "RAW vendor quote — RRP",   display = display.data_window)
plot(tgVr, "RAW vendor quote — TGA",   display = display.data_window)
plot(m2Vr, "RAW vendor quote — M2",    display = display.data_window)
````
