# Exit Map & Rank Regime

- url: https://www.tradingview.com/script/kdoS66j3/
- type: indicator
- pine_id: PUB;a8d50043c17a41598e4b8787eab5b0f5
- version: 2.0

## Description

EXIT MAP & RANK REGIME

A market-agnostic risk tool that answers two practical questions on any chart:
1) If I enter here with this stop and this target, what do the odds and the expectancy actually look like?
2) Does being a recent leader inside my universe mean anything in THIS market, and if so, in which direction?

The script does not assume the answer to either question. It measures both on the chart's own history and shows the result together with its own self-tests.


━━━━━━━━━━━━━━━━━━━━
1) EXIT MAP — zero-drift Monte Carlo
━━━━━━━━━━━━━━━━━━━━
• Each recent bar's close, high and low moves are normalised by the previous bar's ATR.
• The normalised moves are de-meaned (zero drift), so a past uptrend or downtrend is not projected forward as if it were an edge.
• Paths are built with a block bootstrap (consecutive bars drawn together) to keep volatility clustering, then rescaled by the current ATR.
• Stop and target touches are checked on simulated highs and lows, not only closes. If both are touched in the same bar, the stop is counted first (conservative).
• A fixed random seed keeps the output stable between ticks.

Outputs:
• P05 / P50 / P95 cone for the chosen horizon
• P(Target first), P(Stop first), and the share still unresolved at the horizon
• Expectancy in R (target = +T/S R, stop = −1R, unresolved = marked to market) with its standard error
• Verdict: when |expectancy| < 2 standard errors the table says "≈ 0 · R:R alone is not an edge"
• Optional "with-drift" expectancy, shown only to reveal how much of a result comes from the past trend

Why zero drift: with a positive historical drift, any Monte Carlo will show bullish odds simply because the stock went up. Removing the drift isolates what the stop/target geometry itself is worth.


━━━━━━━━━━━━━━━━━━━━
2) RANK REGIME — measured, not assumed
━━━━━━━━━━━━━━━━━━━━
• The chart symbol is ranked inside a universe by its relative return over the lookback (default 21 bars) against the universe's equal-weight basket.
• On every sampled historical bar the script computes the Spearman rank correlation (IC) between that relative rank and the following relative return (default 20 bars).
• The mean IC and an overlap-adjusted t-statistic decide the regime:
  – Reversal: recent leaders tend to lag next → top zone reads "Extension warning", bottom zone "Relative rebound candidate"
  – Momentum: recent leaders tend to keep leading → top zone reads "Leadership", bottom zone "Laggard"
  – No reliable signal: the rank is shown for information only
• 63-bar relative performance is displayed for reference only.

Universe presets:
• Auto (default): picks the universe from the chart's exchange
• EGX (33 liquid names), Saudi Tadawul (25 large caps), US sectors (11 SPDR ETFs), US mega caps (30), or your own Custom list (up to 34 symbols)


━━━━━━━━━━━━━━━━━━━━
3) SELF-TESTS (shown in the table)
━━━━━━━━━━━━━━━━━━━━
• Band coverage: how often the realised close landed inside the P05–P95 band built at that time (target ≈ 90%). Green between 85% and 95%, orange outside. This uses an empirical proxy of the simulated band.
• Rank IC: mean IC, overlap-adjusted t and the number of observations.


━━━━━━━━━━━━━━━━━━━━
4) DATA GATE
━━━━━━━━━━━━━━━━━━━━
Bar moves above a plausible limit are treated as unadjusted corporate actions (splits, bonus shares) and excluded from the sample and from the universe. Auto limits: EGX 20%, Tadawul 10.5%, others 50%, widened on higher timeframes. You can override the limit.


━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━
1. Set your stop and target in ATR multiples.
2. Read the expectancy first. If it is ≈ 0, the stop/target ratio alone gives you nothing; you need a separate reason to take the trade.
3. Use the cone width for position sizing: a wider band means more price risk per share.
4. Read the regime line before the zone. A zone label only carries meaning when the regime is Reversal or Momentum.


━━━━━━━━━━━━━━━━━━━━
LIMITATIONS
━━━━━━━━━━━━━━━━━━━━
• Survivorship bias: the self-test ranks today's universe back through history. Lists of current large caps contain past winners, which tends to overstate momentum. Sector ETFs are cleaner for this reason.
• Use universe symbols from the same market and trading calendar as the chart.
• Up to 36 data requests are used (34 universe symbols + 2 context symbols).
• The cone and the table are recalculated on the last bar. Self-tests use confirmed bars only.
• Some exchanges require a data subscription. Symbols that do not load are skipped automatically.
• Probabilities are model outputs based on historical data. They are not forecasts or win rates.


━━━━━━━━━━━━━━━━━━━━
LANGUAGE
━━━━━━━━━━━━━━━━━━━━
The table can be shown in English or Arabic (Settings → Display → Language). Input tooltips are bilingual.


This script is for education and research. It is not investment advice or a buy/sell signal.

Ahmed Amin, CFTe®, CETA®

خريطة الخروج ونظام الترتيب
Exit Map & Rank Regime

أداة لإدارة المخاطر تعمل على أي سوق، وتجيب عن سؤالين عمليين على أي شارت:
1) لو دخلت هنا بهذا الوقف وهذا الهدف، ما هي الاحتمالات والقيمة المتوقعة فعلاً؟
2) هل لتصدّر السهم لأداء مجموعته مؤخراً أي معنى في هذا السوق تحديداً؟ وإن كان له معنى، ففي أي اتجاه؟

المؤشر لا يفترض الإجابة عن أي من السؤالين، بل يقيسهما على تاريخ الشارت نفسه، ويعرض النتيجة مع اختباراتها الذاتية.


━━━━━━━━━━━━━━━━━━━━
1) خريطة الخروج: محاكاة مونت كارلو دون الاتجاه التاريخي
━━━━━━━━━━━━━━━━━━━━
• حركات الإغلاق والقمة والقاع لكل شمعة حديثة تُطبَّع بقيمة الـ ATR للشمعة السابقة.
• يُطرح متوسط هذه الحركات (Zero-drift)، حتى لا يُسقَط اتجاه صاعد أو هابط سابق على المستقبل وكأنه ميزة.
• تُبنى المسارات بطريقة Block Bootstrap، أي بسحب شموع متتالية معاً للحفاظ على تجمّع التذبذب، ثم يُعاد تحجيمها بالـ ATR الحالي.
• يُفحص لمس الوقف والهدف على القمم والقيعان المُحاكاة، لا على الإغلاق فقط. وإذا لُمسا في الشمعة نفسها يُحتسب الوقف أولاً (افتراض متحفّظ).
• البذرة العشوائية ثابتة، فلا تتغير النتائج مع كل تحديث سعري.

المخرجات:
• مخروط P05 / P50 / P95 للأفق المختار
• احتمال لمس الهدف أولاً، واحتمال لمس الوقف أولاً، ونسبة الحالات التي لم تُحسم بنهاية الأفق
• القيمة المتوقعة بوحدات R (الهدف = +الهدف/الوقف، الوقف = −1R، غير المحسوم = بسعره في نهاية الأفق) مع خطئها المعياري
• الحكم: إذا كانت القيمة المتوقعة أقل من ضعف الخطأ المعياري يظهر "≈ صفر · نسبة العائد للمخاطرة وحدها ليست ميزة"
• قيمة متوقعة اختيارية "مع الاتجاه التاريخي"، تُعرض فقط لإظهار مقدار ما يأتي من اتجاه الماضي

لماذا نحذف الاتجاه التاريخي؟ مع اتجاه صاعد سابق، ستُظهر أي محاكاة مونت كارلو احتمالات صاعدة لمجرد أن السهم ارتفع من قبل. حذف الاتجاه يعزل القيمة الحقيقية لهندسة الوقف والهدف وحدها.


━━━━━━━━━━━━━━━━━━━━
2) نظام الترتيب: يُقاس ولا يُفترض
━━━━━━━━━━━━━━━━━━━━
• يُرتَّب سهم الشارت داخل مجموعة أسهم حسب عائده النسبي خلال نافذة محددة (افتراضياً 21 شمعة) مقابل سلة متساوية الأوزان من المجموعة نفسها.
• في كل نقطة تاريخية مختارة يحسب المؤشر معامل ارتباط سبيرمان (IC) بين هذا الترتيب والعائد النسبي اللاحق (افتراضياً 20 شمعة).
• متوسط الـ IC وقيمة t بعد تصحيح تداخل النوافذ يحددان النظام:
  – ارتداد: القادة يتراجعون لاحقاً، فتظهر المنطقة العليا "تحذير تمدد" والسفلى "مرشح لارتداد نسبي"
  – زخم: القادة يستمرون، فتظهر المنطقة العليا "قيادة" والسفلى "متأخر"
  – لا توجد إشارة موثوقة: يُعرض الترتيب للعلم فقط
• أداء 63 شمعة النسبي معروض للمرجعية فقط.

مجموعات الأسهم الجاهزة:
• تلقائي (الافتراضي): يختار المجموعة حسب بورصة الشارت
• البورصة المصرية (33 سهماً سائلاً)، تداول السعودية (25 سهماً كبيراً)، قطاعات السوق الأمريكي (11 صندوق SPDR)، أكبر 30 سهماً أمريكياً، أو قائمتك الخاصة (حتى 34 رمزاً)


━━━━━━━━━━━━━━━━━━━━
3) الاختبارات الذاتية (في الجدول)
━━━━━━━━━━━━━━━━━━━━
• تغطية النطاق: كم مرة جاء الإغلاق الفعلي داخل نطاق P05–P95 الذي حُسب في حينه (المستهدف قرابة 90%). أخضر بين 85% و95%، وبرتقالي خارجهما. يعتمد على تقريب تجريبي للنطاق المُحاكى.
• معامل الترتيب IC: المتوسط، وقيمة t بعد التصحيح، وعدد الملاحظات.


━━━━━━━━━━━━━━━━━━━━
4) بوابة البيانات
━━━━━━━━━━━━━━━━━━━━
الحركات التي تتجاوز حداً منطقياً تُعامل كإجراءات شركات غير معدّلة (تجزئة أسهم، أسهم مجانية) وتُستبعد من العينة ومن المجموعة. الحدود التلقائية: البورصة المصرية 20%، تداول 10.5%، غيرها 50%، وتتسع على الأطر الزمنية الأعلى. ويمكنك تعديل الحد يدوياً.


━━━━━━━━━━━━━━━━━━━━
طريقة الاستخدام
━━━━━━━━━━━━━━━━━━━━
1. حدّد الوقف والهدف بمضاعفات الـ ATR.
2. اقرأ القيمة المتوقعة أولاً. إذا كانت ≈ صفر، فنسبة الوقف إلى الهدف وحدها لا تمنحك شيئاً، وتحتاج سبباً مستقلاً لدخول الصفقة.
3. استخدم عرض المخروط في تحديد حجم المركز: النطاق الأوسع يعني مخاطرة سعرية أكبر لكل سهم.
4. اقرأ سطر النظام قبل المنطقة. تسمية المنطقة لا معنى لها إلا إذا كان النظام "ارتداد" أو "زخم".


━━━━━━━━━━━━━━━━━━━━
القيود
━━━━━━━━━━━━━━━━━━━━
• انحياز البقاء (Survivorship bias): الاختبار الذاتي يرجع بقائمة اليوم إلى الماضي. وقوائم الأسهم الكبيرة الحالية تضم رابحي الماضي، فتميل إلى تضخيم الزخم. لهذا تعد صناديق القطاعات أنظف.
• استخدم رموزاً من نفس سوق الشارت ونفس أيام التداول.
• يستخدم المؤشر حتى 36 طلب بيانات (34 رمزاً للمجموعة + رمزان للسياق).
• المخروط والجدول يُعاد حسابهما على الشمعة الأخيرة، والاختبارات الذاتية تستخدم الشموع المكتملة فقط.
• بعض البورصات تتطلب اشتراك بيانات، والرموز التي لا تُحمَّل تُتجاهل تلقائياً.
• الاحتمالات مخرجات نموذج مبنية على بيانات تاريخية، وليست توقعات ولا نسب نجاح.


━━━━━━━━━━━━━━━━━━━━
اللغة
━━━━━━━━━━━━━━━━━━━━
يمكن عرض الجدول بالعربية أو الإنجليزية (الإعدادات ← Display ← Language / اللغة)، والتلميحات في الإعدادات ثنائية اللغة.


هذا المؤشر لأغراض تعليمية وبحثية، وليس نصيحة استثمارية ولا إشارة شراء أو بيع.

Ahmed Amin, CFTe®, CETA®

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ahmed Amin, CFTe®, CETA®
// Exit Map & Rank Regime  ·  v1.2
// -----------------------------------------------------------------------------
// Market-agnostic. Works on any symbol / universe the chart's data plan covers.
//
//  1) EXIT MAP     zero-drift Monte Carlo (block bootstrap, High/Low touch,
//                  same-bar tie = stop, fixed seed). Moves are normalised by
//                  GARCH(1,1) volatility (filtered historical simulation) or
//                  by ATR. Auto = GARCH-FHS on EGX, ATR elsewhere (measured
//                  per market, see tooltip). Stop/target stay in ATR.
//                  -> P05/P50/P95 cone, P(target first), P(stop first),
//                     expectancy in R ± standard error.
//  2) RANK REGIME  ranks the chart symbol inside a universe by its relative
//                  return vs the universe's equal-weight basket, AND measures
//                  on this chart's own history whether that rank has reversed
//                  (reversal regime), persisted (momentum regime) or done
//                  nothing. The zone label follows the measured regime —
//                  it is never assumed.
//  3) SELF-TESTS   band coverage (empirical proxy of the P05–P95 band) and
//                  rank IC (Spearman) with an overlap-adjusted t-stat.
//  4) DATA GATE    bar moves above a plausible limit are treated as
//                  unadjusted corporate actions and excluded.
//
// Descriptive tool, not a buy/sell signal. Probabilities are model outputs
// from historical data and do not guarantee future results.
// -----------------------------------------------------------------------------
//@version=6
indicator("Exit Map & Rank Regime", "EMRR", overlay = true, max_lines_count = 150, max_labels_count = 20, dynamic_requests = true)

// ============================================================================
// INPUTS
// ============================================================================
grpMC = "1 · Exit map (Monte Carlo)"
hzn       = input.int(10, "Horizon (bars)", minval = 2, maxval = 40, group = grpMC, tooltip = "Bars ahead to simulate.\n\nعدد الشموع المستقبلية التي تتم محاكاتها.")
sims      = input.int(2000, "Simulations", minval = 200, maxval = 2500, step = 100, group = grpMC, tooltip = "Number of simulated paths. Horizon × Simulations must stay ≤ 100,000.\n\nعدد المسارات المُحاكاة. حاصل ضرب الأفق في عدد المسارات يجب ألا يتجاوز 100,000.")
lookbk    = input.int(250, "Sample size (bars)", minval = 100, maxval = 1000, group = grpMC, tooltip = "Recent bars whose ATR-normalised moves feed the simulation.\n\nعدد الشموع الأخيرة التي تُستخدم حركاتها (مطبّعة بالـ ATR) في المحاكاة.")
blockL    = input.int(5, "Bootstrap block length", minval = 1, maxval = 20, group = grpMC, tooltip = "Consecutive bars drawn together to preserve volatility clustering.\n\nعدد الشموع المتتالية التي تُسحب معاً للحفاظ على تجمّع التذبذب.")
atrLen    = input.int(14, "ATR length", minval = 2, group = grpMC)
stopM     = input.float(1.5, "Stop (× ATR)", minval = 0.25, step = 0.25, group = grpMC, tooltip = "Stop distance below the last close, in ATR.\n\nمسافة الوقف أسفل آخر إغلاق، بمضاعفات الـ ATR.")
tgtM      = input.float(3.0, "Target (× ATR)", minval = 0.25, step = 0.25, group = grpMC, tooltip = "Target distance above the last close, in ATR.\n\nمسافة الهدف أعلى آخر إغلاق، بمضاعفات الـ ATR.")
showTrend = input.bool(true, "Show 'If trend persists' column", group = grpMC, tooltip = "Second model that keeps the historical drift. Left column = stop/target geometry only (drift removed); right column = outcome if the past trend continues. In walk-forward tests both were informative: the right column matched average outcomes better in trending markets.\n\nنموذج ثانٍ يحتفظ بالاتجاه التاريخي. العمود الأيسر = هندسة الوقف والهدف وحدها (بعد حذف الاتجاه)، والأيمن = النتيجة لو استمر اتجاه الماضي. في اختبارات Walk-forward كان الاثنان مفيدين، والأيمن أقرب للمتوسطات الفعلية في الأسواق ذات الاتجاه.")
bandCov   = input.int(92, "Cone width (nominal %)", minval = 80, maxval = 98, step = 2, group = grpMC, tooltip = "Central share of simulated outcomes drawn as the cone. 92% (P04–P96) realised ≈ 90% coverage in out-of-sample tests on 6 markets.\n\nالنسبة المركزية من النتائج المُحاكاة التي يرسمها المخروط. ‎92% (P04–P96) حققت تغطية فعلية قرابة 90% في اختبارات خارج العينة على 6 أسواق.")
volEng    = input.string("Auto (EGX → GARCH-FHS)", "Volatility engine", options = ["Auto (EGX → GARCH-FHS)", "GARCH-FHS", "ATR (v1.1)"], group = grpMC, tooltip = "Auto: GARCH-FHS on EGX charts, ATR elsewhere. Out-of-sample tests (10-bar horizon, nominal 92% cone): GARCH-FHS improved the interval score on EGX (27 stocks, 2022–2026, t = −2.8) and was the only market where the gain survived a correction for testing five markets. FTSE 100, Tadawul and US sector ETFs: no significant difference. Dow 30: slightly worse (t = +2.2, not significant after correction). Coverage stayed 90–92% with both engines in all markets.\n\nتلقائي: GARCH-FHS على شارتات البورصة المصرية، وATR في غيرها. في اختبارات خارج العينة (أفق 10 شموع، مخروط اسمي 92%) حسّن GARCH-FHS درجة النطاق في البورصة المصرية (27 سهماً، 2022–2026، t = −2.8)، وكانت السوق الوحيدة التي صمد فيها التحسن بعد تصحيح اختبار خمسة أسواق. FTSE 100 وتداول وصناديق القطاعات الأمريكية: لا فرق معنوي. Dow 30: أسوأ قليلاً (t = +2.2، غير معنوي بعد التصحيح). بقيت التغطية بين 90% و92% بالمحركين في كل الأسواق.")
gA        = input.float(0.08, "GARCH α (shock weight)", minval = 0.01, maxval = 0.30, step = 0.01, group = grpMC, tooltip = "Fixed parameters with variance targeting. α = 0.08, β = 0.90 beat a rolling maximum-likelihood GARCH out of sample on EGX30 (Diebold–Mariano t = −3.6). α + β must be < 1.\n\nمعاملات ثابتة مع استهداف التباين. α = 0.08 و β = 0.90 تفوّقا خارج العينة على GARCH مُقدّر بالإمكان الأعظم المتجدد على EGX30. يجب أن يكون مجموعهما أقل من 1.")
gB        = input.float(0.90, "GARCH β (persistence)", minval = 0.50, maxval = 0.98, step = 0.01, group = grpMC)
gLR       = input.int(250, "GARCH long-run window (bars)", minval = 60, maxval = 1000, group = grpMC, tooltip = "Window for the long-run variance the GARCH forecast reverts to.\n\nنافذة حساب التباين طويل الأجل الذي يرتد إليه توقع GARCH.")
seedIn    = input.int(42, "Random seed", group = grpMC, tooltip = "Fixed seed keeps results stable between ticks.\n\nالبذرة الثابتة تمنع تغيّر النتائج مع كل تحديث سعري.")

grpU = "2 · Universe & rank regime"
preset    = input.string("Auto (chart exchange)", "Universe preset", options = ["Auto (chart exchange)", "EGX (33)", "Saudi Tadawul (25)", "US sectors (11 SPDR)", "US mega caps (30)", "Custom list"], group = grpU, tooltip = "Auto: EGX → EGX list, TADAWUL → Tadawul list, US exchanges → SPDR sectors, anything else → Custom list.\n\nتلقائي: EGX ← قائمة البورصة المصرية، TADAWUL ← قائمة تداول، البورصات الأمريكية ← قطاعات SPDR، وغير ذلك ← القائمة المخصصة.")
customList = input.text_area("NASDAQ:AAPL,NASDAQ:MSFT,NASDAQ:NVDA,NASDAQ:AMZN,NASDAQ:GOOGL,NASDAQ:META,NASDAQ:AVGO,NASDAQ:TSLA", "Custom list (EXCHANGE:TICKER, comma-separated, max 34)", group = grpU, tooltip = "Use symbols from the same market/calendar as the chart.\n\nاستخدم رموزاً من نفس سوق الشارت ونفس أيام التداول.")
rsLen     = input.int(21, "Rank lookback (bars)", minval = 5, maxval = 252, group = grpU, tooltip = "Window for relative return vs the equal-weight basket.\n\nنافذة حساب العائد النسبي مقابل السلة متساوية الأوزان.")
fwdLen    = input.int(20, "Self-test forward horizon (bars)", minval = 5, maxval = 120, group = grpU, tooltip = "Horizon over which the rank is tested against the following relative return.\n\nالأفق الذي يُختبر عليه الترتيب مقابل العائد النسبي اللاحق.")
testStep  = input.int(5, "Self-test sampling step (bars)", minval = 1, maxval = 20, group = grpU)
zonePct   = input.float(20.0, "Zone size (% of universe)", minval = 5.0, maxval = 40.0, step = 5.0, group = grpU)
minIC     = input.float(0.03, "Min |IC| to call a regime", minval = 0.0, step = 0.01, group = grpU, tooltip = "Minimum absolute rank correlation before a regime is declared.\n\nالحد الأدنى لمعامل ارتباط الترتيب قبل إعلان النظام.")
minUni    = input.int(15, "Min universe size for a regime call", minval = 8, maxval = 34, group = grpU, tooltip = "Smaller universes give noisy rank IC. Below this size the rank is shown for information only.\n\nالمجموعات الأصغر تعطي معامل ترتيب مضطرباً. تحت هذا الحجم يُعرض الترتيب للعلم فقط.")
minT      = input.float(2.0, "Min |t| (overlap-adjusted)", minval = 1.0, step = 0.5, group = grpU, tooltip = "Minimum statistical significance after adjusting for overlapping windows.\n\nالحد الأدنى للدلالة الإحصائية بعد تصحيح تداخل النوافذ.")

grpC = "3 · Context (Custom list only)"
ctx1In    = input.symbol("TVC:DXY", "Context 1", group = grpC)
ctx2In    = input.symbol("TVC:US10Y", "Context 2", group = grpC)

grpG = "4 · Data gate"
gateIn    = input.float(0.0, "Max plausible daily move % (0 = auto)", minval = 0.0, maxval = 100.0, group = grpG, tooltip = "Larger moves are treated as unadjusted corporate actions and excluded. Auto: EGX 20%, Tadawul 10.5%, others 50%, scaled by √days on higher timeframes.\n\nالحركات الأكبر تُعامل كإجراءات شركات غير معدّلة وتُستبعد. تلقائي: البورصة المصرية 20%، تداول 10.5%، غيرها 50%، وتُضبط بالجذر التربيعي لعدد الأيام على الأطر الأعلى.")

grpV = "5 · Display"
lang      = input.string("English", "Language / اللغة", options = ["English", "العربية"], group = grpV)
tblPos    = input.string("top_right", "Table position", options = ["top_right", "top_left", "middle_right", "bottom_right", "bottom_left"], group = grpV)
txtSize   = input.string("small", "Text size", options = ["tiny", "small", "normal"], group = grpV)
showCone  = input.bool(true, "Draw P05 / P50 / P95 cone", group = grpV)
showLvls  = input.bool(true, "Draw stop / target lines", group = grpV)
cBand     = input.color(color.new(#9aa0a6, 0), "Band", group = grpV)
cMid      = input.color(color.new(#2962ff, 0), "Median", group = grpV)
cTgt      = input.color(color.new(#089981, 0), "Target", group = grpV)
cStp      = input.color(color.new(#f23645, 0), "Stop", group = grpV)

// ============================================================================
// PRESETS
// ============================================================================
string LIST_EGX = "EGX:COMI,EGX:TMGH,EGX:HRHO,EGX:EAST,EGX:ETEL,EGX:SWDY,EGX:ABUK,EGX:FWRY,EGX:EFIH,EGX:ORAS,EGX:AMOC,EGX:MFPC,EGX:PHDC,EGX:OCDI,EGX:CIEB,EGX:HELI,EGX:JUFO,EGX:EMFD,EGX:ADIB,EGX:ISPH,EGX:CLHO,EGX:EFID,EGX:ALCN,EGX:GBCO,EGX:BTFH,EGX:ORWE,EGX:EGAL,EGX:SKPC,EGX:MASR,EGX:RAYA,EGX:CCAP,EGX:EGCH,EGX:SUGR"
string LIST_KSA = "TADAWUL:2222,TADAWUL:1120,TADAWUL:1180,TADAWUL:2010,TADAWUL:7010,TADAWUL:1150,TADAWUL:1211,TADAWUL:1010,TADAWUL:2082,TADAWUL:1060,TADAWUL:2280,TADAWUL:1140,TADAWUL:1080,TADAWUL:5110,TADAWUL:7020,TADAWUL:4013,TADAWUL:2020,TADAWUL:1050,TADAWUL:4190,TADAWUL:2050,TADAWUL:4280,TADAWUL:2310,TADAWUL:4030,TADAWUL:8210,TADAWUL:4002"
string LIST_SEC = "AMEX:XLK,AMEX:XLF,AMEX:XLE,AMEX:XLV,AMEX:XLY,AMEX:XLP,AMEX:XLI,AMEX:XLB,AMEX:XLU,AMEX:XLRE,AMEX:XLC"
string LIST_MEGA = "NASDAQ:AAPL,NASDAQ:MSFT,NASDAQ:NVDA,NASDAQ:AMZN,NASDAQ:GOOGL,NASDAQ:META,NASDAQ:AVGO,NASDAQ:TSLA,NASDAQ:COST,NASDAQ:NFLX,NASDAQ:PEP,NASDAQ:AMD,NYSE:BRK.B,NYSE:JPM,NYSE:V,NYSE:LLY,NYSE:UNH,NYSE:XOM,NYSE:MA,NYSE:JNJ,NYSE:PG,NYSE:HD,NYSE:WMT,NYSE:ABBV,NYSE:BAC,NYSE:KO,NYSE:ORCL,NYSE:CVX,NYSE:MRK,NYSE:CRM"

// Market detection: the exchange prefix alone failed on live EGX charts (Auto picked the custom list, a 50% gate
// and the ATR engine on EGX:COMI), so the quote currency is checked as well. EGP / SAR are unambiguous.
bool egEx = syminfo.prefix == "EGX" or syminfo.currency == "EGP"
bool saEx = syminfo.prefix == "TADAWUL" or syminfo.currency == "SAR"
bool usEx = syminfo.prefix == "NASDAQ" or syminfo.prefix == "NYSE" or syminfo.prefix == "AMEX" or syminfo.prefix == "BATS" or syminfo.prefix == "CBOE" or syminfo.prefix == "SP"
string pre = preset != "Auto (chart exchange)" ? preset : egEx ? "EGX (33)" : saEx ? "Saudi Tadawul (25)" : usEx ? "US sectors (11 SPDR)" : "Custom list"

string listStr = switch pre
    "EGX (33)"             => LIST_EGX
    "Saudi Tadawul (25)"   => LIST_KSA
    "US sectors (11 SPDR)" => LIST_SEC
    "US mega caps (30)"    => LIST_MEGA
    => customList

string ctx1 = switch pre
    "EGX (33)"           => "EGX:EGX30"
    "Saudi Tadawul (25)" => "TADAWUL:TASI"
    "Custom list"        => ctx1In
    => "SP:SPX"
string ctx2 = switch pre
    "EGX (33)"             => "FX_IDC:USDEGP"
    "Saudi Tadawul (25)"   => "TVC:UKOIL"
    "US sectors (11 SPDR)" => "TVC:US10Y"
    "US mega caps (30)"    => "TVC:DXY"
    => ctx2In

float gateBase = gateIn > 0 ? gateIn : pre == "EGX (33)" ? 20.0 : pre == "Saudi Tadawul (25)" ? 10.5 : egEx ? 20.0 : saEx ? 10.5 : 50.0
float tfDays   = math.max(1.0, timeframe.in_seconds() / 86400.0)
float gate     = math.min(100.0, gateBase * (timeframe.isintraday ? 1.0 : math.sqrt(tfDays)))

var array<string> syms = str.split(str.replace_all(listStr, " ", ""), ",")
int nU = math.min(array.size(syms), 34)     // 34 + 2 context = 36 requests (limit 40)
int gateWin = math.max(63, fwdLen + rsLen) + 1
float qLoP = (100 - bandCov) / 2.0
float qHiP = 100 - qLoP

// ============================================================================
// HELPERS
// ============================================================================
bool isAr = lang == "العربية"
tx(string en, string a) => isAr ? a : en

f_pos() =>
    switch tblPos
        "top_left"     => position.top_left
        "middle_right" => position.middle_right
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        => position.top_right

f_size() =>
    switch txtSize
        "tiny"   => size.tiny
        "normal" => size.normal
        => size.small

f_pct(float v) => na(v) ? "—" : str.tostring(v, "+#.0;-#.0") + "%"
f_p(float v)   => na(v) ? "—" : str.tostring(v * 100, "#.0") + "%"
f_pair(string g, string t) => showTrend ? g + "  |  " + t : g

// average-rank transform (ties share the mean rank)
f_rank(array<float> x) =>
    int m = array.size(x)
    array<float> r = array.new<float>(m, 0.0)
    for i = 0 to m - 1
        float xi    = array.get(x, i)
        float below = 0.0
        float ties  = 0.0
        for j = 0 to m - 1
            float xj = array.get(x, j)
            if xj < xi
                below += 1
            else if xj == xi and j != i
                ties += 1
        array.set(r, i, below + ties / 2 + 1)
    r

f_spearman(array<float> x, array<float> y) =>
    array<float> rx = f_rank(x)
    array<float> ry = f_rank(y)
    float sx = array.stdev(rx)
    float sy = array.stdev(ry)
    sx > 0 and sy > 0 ? array.covariance(rx, ry) / (sx * sy) : na

f_demean(array<float> x) =>
    float m = array.avg(x)
    array<float> out = array.new<float>()
    for v in x
        array.push(out, v - m)
    out

// ============================================================================
// DATA GATE + NORMALISED SAMPLE (confirmed bars only)
// ============================================================================
float atrV    = ta.atr(atrLen)
float pc      = close[1]
float a1      = atrV[1]
float barMove = na(pc) or pc == 0 ? na : math.abs(close / pc - 1) * 100
bool  corp    = not na(barMove) and barMove > gate
bool  useG    = volEng == "GARCH-FHS" or (volEng == "Auto (EGX → GARCH-FHS)" and egEx)
float gAlpha  = math.min(gA, 0.999 - gB)                    // enforce alpha + beta < 1

// GARCH(1,1), variance targeting. gNext = variance forecast for the NEXT bar,
// so on any bar the value carried in from the previous bar uses no same-bar info.
var array<float> rWin  = array.new<float>()
var float        gNext = na
float gPrevF  = gNext                                      // forecast made at previous close, for this bar
float lrBar   = na(pc) or pc <= 0 ? na : math.log(close / pc)
if barstate.isconfirmed and not na(lrBar) and not corp
    array.push(rWin, lrBar)
    if array.size(rWin) > gLR
        array.shift(rWin)
    if array.size(rWin) >= 20
        float lvU = array.variance(rWin)
        gNext := na(gNext) ? lvU : (1 - gAlpha - gB) * lvU + gAlpha * lrBar * lrBar + gB * gNext
float lvNow   = array.size(rWin) >= 20 ? array.variance(rWin) : na
// average per-bar variance over the horizon (GARCH term structure, mean-reverting)
f_hVar(float v1, float lv) =>
    float acc = 0.0
    float p   = gAlpha + gB
    for k = 0 to hzn - 1
        acc += lv + math.pow(p, k) * (v1 - lv)
    acc / hzn
float unitPrev = useG ? (na(gPrevF) or gPrevF <= 0 ? na : pc * math.sqrt(gPrevF)) : a1          // divisor for this bar's move
float unitNow  = useG ? (na(gNext) or na(lvNow) ? na : close * math.sqrt(math.max(f_hVar(gNext, lvNow), 1e-12))) : atrV

var array<float> sC    = array.new<float>()
var array<float> sH    = array.new<float>()
var array<float> sL    = array.new<float>()
var array<float> hSums = array.new<float>()
var int corpIdx  = na
var int corpTime = na

if barstate.isconfirmed and not na(unitPrev) and unitPrev > 0
    if corp
        corpIdx  := bar_index
        corpTime := time
    else
        array.push(sC, (close - pc) / unitPrev)
        array.push(sH, (high  - pc) / unitPrev)
        array.push(sL, (low   - pc) / unitPrev)
        if array.size(sC) > lookbk
            array.shift(sC)
            array.shift(sH)
            array.shift(sL)
        int sz = array.size(sC)
        if sz >= hzn
            float hs = 0.0
            for k = sz - hzn to sz - 1
                hs += array.get(sC, k)
            array.push(hSums, hs)
            if array.size(hSums) > lookbk
                array.shift(hSums)

bool corpRecent = not na(corpIdx) and bar_index - corpIdx <= lookbk

// ============================================================================
// SELF-TEST A · band coverage (empirical proxy of the MC P05–P95 band)
// ============================================================================
var array<int>   qIdx = array.new<int>()
var array<float> qLo  = array.new<float>()
var array<float> qHi  = array.new<float>()
var int covHit = 0
var int covN   = 0

if barstate.isconfirmed
    while array.size(qIdx) > 0 and bar_index - array.get(qIdx, 0) >= hzn
        float lo0 = array.shift(qLo)
        float hi0 = array.shift(qHi)
        array.shift(qIdx)
        covN   += 1
        covHit += close >= lo0 and close <= hi0 ? 1 : 0
    if bar_index % testStep == 0 and array.size(hSums) >= 100 and not na(unitNow) and unitNow > 0
        float drift = hzn * array.avg(sC)
        array.push(qIdx, bar_index)
        array.push(qLo, close + (array.percentile_linear_interpolation(hSums, qLoP) - drift) * unitNow)
        array.push(qHi, close + (array.percentile_linear_interpolation(hSums, qHiP) - drift) * unitNow)

// ============================================================================
// UNIVERSE · current rank inputs + SELF-TEST B (rank IC)
// ============================================================================
array<string> uName = array.new<string>()
array<float>  uSig  = array.new<float>()
array<float>  u63   = array.new<float>()
array<float>  lagS  = array.new<float>()
array<float>  fwdR  = array.new<float>()
int excl = 0

if nU > 0
    for i = 0 to nU - 1
        string s = array.get(syms, i)
        [sig, lagSig, fwd, r63, mx] = request.security(s, timeframe.period, [math.log(close / close[rsLen]), math.log(close[fwdLen] / close[fwdLen + rsLen]), math.log(close / close[fwdLen]), math.log(close / close[63]), ta.highest(math.abs(close / close[1] - 1) * 100, gateWin)], ignore_invalid_symbol = true)
        bool bad = not na(mx) and mx > gate
        if bad
            excl += 1
        else
            if not na(sig) and not na(r63)
                array.push(uName, s)
                array.push(uSig, sig)
                array.push(u63, r63)
            if not na(lagSig) and not na(fwd)
                array.push(lagS, lagSig)
                array.push(fwdR, fwd)

var float icS  = 0.0
var float icS2 = 0.0
var int   icN  = 0
if barstate.isconfirmed and bar_index % testStep == 0 and array.size(lagS) >= 8
    float ic = f_spearman(f_demean(lagS), f_demean(fwdR))
    if not na(ic)
        icS  += ic
        icS2 += ic * ic
        icN  += 1

float icMean = icN > 0 ? icS / icN : na
float icSd   = icN > 1 ? math.sqrt(math.max(0.0, icS2 / icN - icMean * icMean)) : na
float tAdj   = icN > 1 and icSd > 0 ? icMean / (icSd / math.sqrt(icN)) / math.sqrt(math.max(1.0, fwdLen / float(testStep))) : na
int uCount   = array.size(uSig)
int regime   = uCount < minUni ? 8 : icN < 30 or na(tAdj) ? 9 : icMean <= -minIC and tAdj <= -minT ? -1 : icMean >= minIC and tAdj >= minT ? 1 : 0   // -1 reversal · 1 momentum · 0 none · 9 insufficient

[c1Now, c1Then] = request.security(ctx1, timeframe.period, [close, close[rsLen]], ignore_invalid_symbol = true)
[c2Now, c2Then] = request.security(ctx2, timeframe.period, [close, close[rsLen]], ignore_invalid_symbol = true)

float ownSig = math.log(close / close[rsLen])
float own63  = math.log(close / close[63])
bool  ownBad = ta.highest(nz(barMove), gateWin) > gate

// ============================================================================
// MONTE CARLO ENGINE
// ============================================================================
f_mc(bool demean, float p0, float unitM, float atrNow) =>
    int   n        = array.size(sC)
    float mu       = demean ? array.avg(sC) : 0.0
    float tgt      = p0 + tgtM * atrNow
    float stp      = p0 - stopM * atrNow
    float rUnit    = stopM * atrNow
    int   maxStart = math.max(1, n - blockL)
    matrix<float> paths = matrix.new<float>(hzn, sims, na)
    int   nT    = 0
    int   nS    = 0
    float sumR  = 0.0
    float sumR2 = 0.0
    for s = 0 to sims - 1
        float price = p0
        int   start = 0
        int   state = 0
        for k = 0 to hzn - 1
            if k % blockL == 0
                start := int(math.floor(math.random(0, maxStart, seedIn)))
            int   j    = math.min(start + k % blockL, n - 1)
            float prev = price
            price := prev + (array.get(sC, j) - mu) * unitM
            if state == 0
                float lo = prev + (array.get(sL, j) - mu) * unitM
                float hi = prev + (array.get(sH, j) - mu) * unitM
                if lo <= stp
                    state := -1
                else if hi >= tgt
                    state := 1
            matrix.set(paths, k, s, price)
        float r = state == 1 ? tgtM / stopM : state == -1 ? -1.0 : (price - p0) / rUnit
        nT    += state == 1 ? 1 : 0
        nS    += state == -1 ? 1 : 0
        sumR  += r
        sumR2 += r * r
    float m  = sumR / sims
    float sd = math.sqrt(math.max(0.0, sumR2 / sims - m * m))
    [paths, nT / float(sims), nS / float(sims), m, sd / math.sqrt(sims), tgt, stp]

// ============================================================================
// OUTPUT
// ============================================================================
var array<line>  drawn = array.new<line>()
var array<label> labs  = array.new<label>()
var table tb = table.new(f_pos(), 2, 27, bgcolor = color.new(#131722, 0), border_color = color.new(#2a2e39, 0), border_width = 1, frame_color = color.new(#2a2e39, 0), frame_width = 1)

f_row(int r, string k, string v, color vc) =>
    table.cell(tb, 0, r, k, text_color = color.new(#b2b5be, 0), text_size = f_size(), text_halign = text.align_left)
    table.cell(tb, 1, r, v, text_color = vc, text_size = f_size(), text_halign = text.align_right)

f_head(int r, string t) =>
    table.cell(tb, 0, r, t, text_color = color.white, bgcolor = color.new(#2a2e39, 0), text_size = f_size(), text_halign = text.align_left)
    table.merge_cells(tb, 0, r, 1, r)

if barstate.islast
    table.clear(tb, 0, 0, 1, 26)
    for l in drawn
        line.delete(l)
    array.clear(drawn)
    for lb in labs
        label.delete(lb)
    array.clear(labs)

    int row = 0
    table.cell(tb, 0, row, tx("Exit Map & Rank Regime", "خريطة الخروج ونظام الترتيب"), text_color = color.white, bgcolor = color.new(#1e3a8a, 0), text_size = f_size())
    table.merge_cells(tb, 0, row, 1, row)
    row += 1

    if array.size(sC) < 100 or na(atrV) or atrV <= 0 or na(unitNow) or unitNow <= 0
        f_row(row, tx("Data", "البيانات"), tx("Need ≥ 100 clean bars", "يلزم 100 شمعة نظيفة على الأقل"), color.orange)
    else
        // ---------------------------------------------------- 0) VOL ENGINE
        string engTxt = (volEng == "Auto (EGX → GARCH-FHS)" ? tx("Auto · ", "تلقائي · ") : "") + (useG ? "GARCH-FHS · σ " + str.tostring(unitNow / close * math.sqrt(hzn) * 100, "#.0") + "% / " + str.tostring(hzn) + tx(" bars", " شمعة") : "ATR")
        f_row(row, tx("Vol engine", "محرك التذبذب"), engTxt, color.white)
        row += 1
        // ---------------------------------------------------- 1) EXIT MAP
        [paths, pT, pS, eR, se, tgt, stp] = f_mc(true, close, unitNow, atrV)
        array<float> termRow = matrix.row(paths, hzn - 1)
        float p05 = array.percentile_linear_interpolation(termRow, qLoP)
        float p50 = array.percentile_linear_interpolation(termRow, 50)
        float p95 = array.percentile_linear_interpolation(termRow, qHiP)

        if showCone
            float prev05 = close
            float prev50 = close
            float prev95 = close
            for k = 0 to hzn - 1
                array<float> rowK = matrix.row(paths, k)
                float q05 = array.percentile_linear_interpolation(rowK, qLoP)
                float q50 = array.percentile_linear_interpolation(rowK, 50)
                float q95 = array.percentile_linear_interpolation(rowK, qHiP)
                array.push(drawn, line.new(bar_index + k, prev05, bar_index + k + 1, q05, color = cBand, width = 1))
                array.push(drawn, line.new(bar_index + k, prev50, bar_index + k + 1, q50, color = cMid, width = 2))
                array.push(drawn, line.new(bar_index + k, prev95, bar_index + k + 1, q95, color = cBand, width = 1))
                prev05 := q05
                prev50 := q50
                prev95 := q95
            array.push(labs, label.new(bar_index + hzn + 1, p95, "P" + str.tostring(qHiP, "#") + " " + str.tostring(p95, format.mintick), style = label.style_label_left, color = color.new(cBand, 70), textcolor = color.white, size = size.small))
            array.push(labs, label.new(bar_index + hzn + 1, p50, "P50 " + str.tostring(p50, format.mintick), style = label.style_label_left, color = color.new(cMid, 60), textcolor = color.white, size = size.small))
            array.push(labs, label.new(bar_index + hzn + 1, p05, "P" + str.tostring(qLoP, "00") + " " + str.tostring(p05, format.mintick), style = label.style_label_left, color = color.new(cBand, 70), textcolor = color.white, size = size.small))

        if showLvls
            array.push(drawn, line.new(bar_index, tgt, bar_index + hzn, tgt, color = cTgt, style = line.style_dashed))
            array.push(drawn, line.new(bar_index, stp, bar_index + hzn, stp, color = cStp, style = line.style_dashed))

        float pTd = na
        float pSd = na
        float eRd = na
        if showTrend
            [_p2, tT, tS, tR, _se2, _g2, _x2] = f_mc(false, close, unitNow, atrV)
            pTd := tT
            pSd := tS
            eRd := tR

        f_head(row, tx("Exit map · ", "خريطة الخروج · ") + str.tostring(hzn) + tx(" bars", " شمعة"))
        row += 1
        f_row(row, tx("Model", "النموذج"), f_pair(tx("Geometry only", "الوقف والهدف وحدهما"), tx("If trend persists", "لو استمر الاتجاه")), color.new(#787b86, 0))
        row += 1
        f_row(row, tx("Cone ", "المخروط ") + "P" + str.tostring(qLoP, "00") + " → P" + str.tostring(qHiP, "#"), f_pct((p05 / close - 1) * 100) + "  →  " + f_pct((p95 / close - 1) * 100), color.white)
        row += 1
        f_row(row, tx("Stop / Target", "الوقف / الهدف"), str.tostring(stp, format.mintick) + "  /  " + str.tostring(tgt, format.mintick), color.white)
        row += 1
        f_row(row, tx("P(Target first)", "احتمال لمس الهدف أولاً"), f_pair(f_p(pT), f_p(pTd)), cTgt)
        row += 1
        f_row(row, tx("P(Stop first)", "احتمال لمس الوقف أولاً"), f_pair(f_p(pS), f_p(pSd)), cStp)
        row += 1
        f_row(row, tx("Unresolved at horizon", "لم يُحسم في نهاية الأفق"), f_pair(f_p(1 - pT - pS), f_p(1 - pTd - pSd)), color.new(#b2b5be, 0))
        row += 1
        bool  noEdge = math.abs(eR) < 2 * se
        color eCol   = noEdge ? color.new(#b2b5be, 0) : eR > 0 ? cTgt : cStp
        f_row(row, tx("Expectancy (R)", "القيمة المتوقعة (R)"), f_pair(str.tostring(eR, "+0.00;-0.00") + " ± " + str.tostring(se, "0.00"), na(eRd) ? "—" : str.tostring(eRd, "+0.00;-0.00")), eCol)
        row += 1
        f_row(row, tx("Verdict (geometry)", "الحكم (الوقف والهدف)"), noEdge ? tx("≈ 0 · R:R alone is not an edge", "≈ صفر · نسبة العائد للمخاطرة وحدها ليست ميزة") : eR > 0 ? tx("Positive", "إيجابية") : tx("Negative", "سلبية"), eCol)
        row += 1
        float cov    = covN > 0 ? covHit / float(covN) : na
        bool  covOk  = not na(cov) and cov * 100 >= bandCov - 6 and cov * 100 <= bandCov + 3
        f_row(row, tx("Cone self-test (realised)", "اختبار المخروط (الفعلي)"), na(cov) ? tx("building…", "جارٍ البناء…") : f_p(cov) + "  ·  n=" + str.tostring(covN), na(cov) ? color.new(#787b86, 0) : covOk ? cTgt : color.orange)
        row += 1

        // ---------------------------------------------------- 2) RANK REGIME
        int cnt = array.size(uSig)
        f_head(row, tx("Rank regime · ", "نظام الترتيب · ") + str.tostring(rsLen) + tx(" bars", " شمعة"))
        row += 1
        string regTxt = regime == -1 ? tx("Reversal (leaders fade)", "ارتداد (القادة يتراجعون)") : regime == 1 ? tx("Momentum (leaders persist)", "زخم (القادة يستمرون)") : regime == 0 ? tx("No reliable signal", "لا توجد إشارة موثوقة") : regime == 8 ? tx("Universe < ", "المجموعة أقل من ") + str.tostring(minUni) + tx(" · rank for info", " · الترتيب للعلم") : tx("Insufficient history", "تاريخ غير كافٍ")
        string icTxt  = na(icMean) ? "—" : "IC " + str.tostring(icMean, "+0.00;-0.00") + " · t " + str.tostring(tAdj, "+0.0;-0.0") + " · n=" + str.tostring(icN)
        f_row(row, tx("Measured on this market", "مقيس على هذا السوق"), regTxt, regime == -1 or regime == 1 ? color.white : color.new(#787b86, 0))
        row += 1
        f_row(row, tx("Self-test", "الاختبار الذاتي"), icTxt, color.new(#787b86, 0))
        row += 1
        if cnt < 8 or ownBad or na(ownSig)
            f_row(row, tx("Status", "الحالة"), ownBad ? tx("Excluded: corporate action suspected", "مستبعد: إجراء شركة محتمل") : tx("Universe data insufficient", "بيانات العينة غير كافية"), color.orange)
            row += 1
        else
            float ew     = array.avg(uSig)
            float ew63   = array.avg(u63)
            float ownRel = ownSig - ew
            int   above  = 0
            int   others = 0
            for i = 0 to cnt - 1
                string nm = array.get(uName, i)
                array<string> nmParts = str.split(nm, ":")
                string nmTicker = array.size(nmParts) > 1 ? array.get(nmParts, 1) : nm
                bool isSelf = nm == syminfo.tickerid or nm == syminfo.prefix + ":" + syminfo.ticker or nmTicker == syminfo.ticker
                if not isSelf
                    others += 1
                    above  += array.get(uSig, i) - ew > ownRel ? 1 : 0
            int  nAll = others + 1
            int  rank = above + 1
            int  zone = math.max(1, int(math.ceil(nAll * zonePct / 100)))
            bool inTop = rank <= zone
            bool inBot = rank > nAll - zone
            string zTxt = regime == -1 ? (inTop ? tx("EXTENSION WARNING", "تحذير تمدد") : inBot ? tx("Relative rebound candidate", "مرشح لارتداد نسبي") : tx("Neutral", "محايد")) : regime == 1 ? (inTop ? tx("Leadership (momentum)", "قيادة (زخم)") : inBot ? tx("Laggard (momentum)", "متأخر (زخم)") : tx("Neutral", "محايد")) : tx("Rank only · no regime", "ترتيب فقط · بدون نظام")
            color  zCol = regime == -1 ? (inTop ? color.orange : inBot ? color.new(#26a69a, 0) : color.new(#b2b5be, 0)) : regime == 1 ? (inTop ? color.new(#26a69a, 0) : inBot ? color.orange : color.new(#b2b5be, 0)) : color.new(#787b86, 0)
            f_row(row, tx("Relative vs EW basket", "الأداء مقابل السلة"), f_pct((math.exp(ownRel) - 1) * 100), color.white)
            row += 1
            f_row(row, tx("Rank in universe", "الترتيب في العينة"), str.tostring(rank) + " / " + str.tostring(nAll), color.white)
            row += 1
            f_row(row, tx("Zone", "المنطقة"), zTxt, zCol)
            row += 1
            f_row(row, tx("63-bar vs basket (info)", "أداء 63 شمعة (للعلم)"), f_pct((math.exp(own63 - ew63) - 1) * 100), color.new(#787b86, 0))
            row += 1
        if excl > 0
            f_row(row, tx("Excluded by data gate", "مستبعد ببوابة البيانات"), str.tostring(excl), color.new(#787b86, 0))
            row += 1

        // ---------------------------------------------------- 3) CONTEXT
        f_head(row, tx("Context · ", "السياق · ") + str.tostring(rsLen) + tx(" bars", " شمعة"))
        row += 1
        f_row(row, ctx1, f_pct(na(c1Then) or c1Then == 0 ? na : (c1Now / c1Then - 1) * 100), color.white)
        row += 1
        f_row(row, ctx2, f_pct(na(c2Then) or c2Then == 0 ? na : (c2Now / c2Then - 1) * 100), color.white)
        row += 1

        // ---------------------------------------------------- 4) DATA GATE
        if corpRecent
            f_row(row, tx("Data gate", "بوابة البيانات"), tx("Jump > ", "قفزة > ") + str.tostring(gate, "#") + "% · " + str.format_time(corpTime, "yyyy-MM-dd") + tx(" excluded", " مستبعدة"), color.orange)
            row += 1

        table.cell(tb, 0, row, tx("Model output from history · not a recommendation", "مخرجات نموذج من بيانات تاريخية · ليست توصية"), text_color = color.new(#787b86, 0), text_size = size.tiny)
        table.merge_cells(tb, 0, row, 1, row)
        row += 1
        table.cell(tb, 0, row, "Ahmed Amin, CFTe®, CETA®", text_color = color.new(#787b86, 0), text_size = size.tiny)
        table.merge_cells(tb, 0, row, 1, row)
````
