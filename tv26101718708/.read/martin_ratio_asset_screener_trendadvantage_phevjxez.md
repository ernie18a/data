# Martin Ratio Asset Screener [TrendAdvantage]

- url: https://www.tradingview.com/script/PHeVjxEZ-Martin-Ratio-Asset-Screener-TrendAdvantage/
- type: indicator
- pine_id: PUB;aa4ff22df06641c1a169d94de7ea0bdd
- version: 2.0

## Description

[b]Martin Ratio Asset Screener[/b]
[i]Advanced Downside & Recovery Profiler[/i]

[b]تقييم الأصول وفقًا لنسبة مارتن[/b]
[i]أداة متقدمة لتحليل الهبوط والتعافي[/i]

English documentation is followed by the Arabic translation below.
الشرح باللغة العربية متوفر في الجزء السفلي من هذه الصفحة


█ [b]OVERVIEW[/b]

This screener is designed to compare multiple assets over an identical observation window. Martin Ratio values are intended for relative ranking within the selected universe rather than as universal standalone scores.


█ [b]WHAT IS THE MARTIN RATIO?[/b]

The Martin Ratio is an advanced, risk-adjusted performance metric that evaluates an asset's return relative to both the magnitude and duration of its historical drawdowns. By utilizing the Ulcer Index (UI) as its risk proxy, it penalizes how deep an asset falls and how long it remains underwater.

It builds on the Ulcer Index, developed by Peter G. Martin and published together with Byron B. McCann in their 1989 book, "The Investor's Guide to Fidelity Funds". This indicator serves as a screening framework to identify assets that historically generated higher returns relative to their drawdown burden, rather than those that subject a portfolio to significant drawdowns, both in magnitude and duration.


█ [b]WHY THE MARTIN RATIO IS DIFFERENT[/b]

Martin recognized a fundamental flaw in the Sharpe Ratio: it uses standard deviation as a proxy for risk, which penalizes all volatility equally — including sudden, sharp moves to the upside. For trend-following strategies or high-growth portfolios, an upward move artificially inflates standard deviation, making the strategy appear riskier than it actually is.

Unlike common risk-adjusted metrics that use standard deviation as a measure of risk, the Martin Ratio uses the Ulcer Index (UI) as its denominator. The Sortino Ratio addresses part of this problem by focusing only on downside volatility. However, downside volatility measures magnitude only, while drawdown has two components: magnitude and duration.

The Ulcer Index measures how far an asset falls below its previous highs and how persistently it remains below those highs. It therefore captures an important dimension of investment risk that conventional volatility measures can miss: the depth and persistence of capital drawdowns.

A portfolio that falls 10% and quickly recovers presents a very different investment from one that falls 10% and remains underwater for an extended period. Because the Ulcer Index is calculated from the sequence of drawdowns from prior peaks, prolonged drawdowns continue contributing to the measure until recovery occurs.

[b]Significance of Drawdown Depth and Persistence[/b]

 •  Capital lock-up risk: Capital tied up in a prolonged drawdown cannot easily be
    redeployed without realizing a loss.

 •  Behavioral risk: The deeper and longer a drawdown persists, the greater the
    possibility that an investor abandons the position before recovery.

 •  Compounding drag: Time spent recovering previous losses is time during which
    capital is not advancing beyond its former peak.

A higher Martin Ratio indicates that an asset generated more return per unit of historical drawdown burden over the selected period.


█ [b]MATHEMATICAL FORMULA[/b]

The traditional Martin Ratio is expressed as:

`Martin Ratio = (Ra - Rf) / Ulcer Index`

Where:
 •  Ra: Annualized return of the portfolio, asset, or strategy.
 •  Rf: Risk-free rate of return.
 •  Ulcer Index: The root mean square of percentage drawdowns from previous
   historical peaks. Lower Ulcer Index values indicate a shallower and/or less
   persistent drawdown profile.


█ [b]IMPLEMENTATION USED IN THIS SCREENER[/b]

The Martin Ratio shown by this screener uses total return over the selected lookback period rather than annualized return:

`Martin Ratio = Lookback Return / Ulcer Index`

The risk-free rate is also excluded. Because every ticker in the screener is evaluated using the same timeframe and identical lookback length, the resulting values can be used for direct comparison and ranking within the selected universe. This simplified implementation is designed primarily as a relative asset-ranking tool, rather than as a reproduction of the traditional annualized Martin Ratio.


█ [b]HOW THE SCREENER COMPARES ASSETS[/b]

Comparison between assets follows a consistent four-step framework:

1 — [b]Use an Identical Lookback Window[/b] — All selected tickers are evaluated
    using the same timeframe and lookback length in days. This is essential for
    meaningful comparison because changing either parameter changes the return
    horizon and the drawdown history being measured. 

2 — [b]Calculate Lookback Return[/b] — The total buy-and-hold return is
    calculated for each ticker over the selected lookback period.

3 — [b]Calculate the Ulcer Index[/b] — For each ticker, the script identifies
    the running historical peak within the calculation sequence, measures each
    closing price's percentage drawdown from that peak, squares those values,
    averages them, and takes the square root. The result is the ticker's Ulcer
    Index over the selected period.

4 — [b]Calculate and Rank the Martin Ratio[/b] — The lookback return is divided
    by the ticker's Ulcer Index. Higher values indicate a more favorable
    combination of return and drawdown over the selected measurement period.


█ [b]OPERATIONAL NOTES[/b]

The lookback period should be sufficiently long to capture a meaningful range of market conditions, such as a drawdown and recovery. Very short windows can produce unstable or misleading ratios, particularly when an asset has experienced little or no meaningful drawdown.

As a general starting point:
 •  Minimum: approximately 180 calendar days (~6 months)
 •  Preferred: 365 calendar days (1 year) or more

These are practical guidelines rather than statistically derived minimums. The appropriate lookback depends on the asset and intended investment horizon. Lookback periods spanning several years or more may exceed the available historical data for some tickers — particularly recently listed assets — resulting in N/A values.

This screener computes each ticker's metrics over an identical calendar-day window — not a fixed bar count — so a given lookback (e.g., 300 days) covers the same 300 calendar days for equities, cryptocurrencies, or forex alike, regardless of how many bars each one produces in that span on a given timeframe. This makes lookback settings directly comparable across asset classes, independent of the chart's timeframe.

One dependency remains: the host chart being viewed governs when the screener's internal calculation updates. If the host chart is a restricted-session equity (or similar), tickers from continuously-traded markets like crypto may not accumulate enough calendar history to populate, and can show N/A even within a supported lookback window. When mixing asset classes in the same table, view the screener from a crypto or forex chart to ensure prices are populated across all assets.


█ [b]MARTIN RATIO THRESHOLD[/b]

The threshold used by the screener is a visual ranking aid, not a statistically validated cutoff. Table colors are interpreted as follows:
 •  Above threshold: Green
 •  Between 0 and the threshold: Grey
 •  Below 0: Red

The threshold is intended solely as a visual aid for ranking assets rather than a universal definition of a "good" Martin Ratio. Martin Ratio values are most meaningful when comparing securities calculated using the same methodology, timeframe, and lookback period. Because the implementation used here is based on non-annualized lookback returns, values should not be treated as universal absolute benchmarks across different timeframe and lookback configurations. For practical use, the threshold can be calibrated to the characteristics of the user's own watch list or investment universe.


█ [b]INTERPRETATION[/b]

Each ticker's row includes the following metrics:
 •  [b]Total Return[/b] — Cumulative percentage return over the selected
    lookback period.

 •  [b]Ann. Ret[/b] — Annualized return (CAGR) over the same period, shown for
    reference only; it does not influence the Martin Ratio or the ranking.

 •  [b]DD (Days)[/b] — The number of calendar days from peak to trough of the
    single largest (deepest) drawdown observed in the window.

 •  [b]DD %[/b] — The magnitude of largest drawdown, expressed as a percentage
    decline from its prior peak.

 •  [b]Time in DD %[/b] — The percentage of calendar days across the entire
    lookback window during which the asset was trading below its prior peaks, in
    any drawdown — not limited to the single largest one.

 •  [b]Ulcer Index[/b] — A measure of drawdown depth and duration combined,
   calculated as the root-mean-square of percentage drawdowns across every day
   in the window. Unlike DD %, which reflects only the single worst decline, the
   Ulcer Index captures the cumulative "pain" of all drawdowns the asset
   experienced — larger and more persistent drawdowns increase the Ulcer Index.

 •  [b]Martin Ratio[/b] — Total Return divided by the Ulcer Index, measuring
   return earned per unit of drawdown intensity.

Within an identically configured comparison:
 •  Higher Martin Ratio → More return relative to the historical drawdown
   burden.

 •  Lower positive Martin Ratio → Positive return, but with a less favorable
   drawdown profile.

 •  Negative Martin Ratio → Negative return over the selected lookback period.

The screener is therefore best used as a cross-sectional ranking tool for identifying which assets have delivered the strongest return relative to the depth and persistence of their drawdowns over the same observation window.


█ [b]DISCLAIMER[/b]

This script is published for educational and informational purposes only and does not constitute financial or investment advice. The Martin Ratio relies entirely on historical price data; past drawdown depth, duration, and recovery speed are not indicative of future results. Always conduct your own research and practice proper risk management before making investment decisions.


═════════════════════════════════════════════════════════════

الشرح باللغة العربية

هذا التطبيق مصمم لمقارنة أصول متعددة عبر فترة حساب متطابقة‏. يُقصد بقيم نسبة مارتن أن تُستخدم للترتيب النسبي داخل مجموعة الأصول المختارة، وليس كقيم مطلقة قائمة بذاتها‏


‏█ [b]‏ما هي نسبة مارتن؟‏[/b]

نسبة مارتن هي مقياس متقدم للأداء، يقيّم عائد الأصول المالية مقارنةً بكلٍ من حجم ومدة تراجعاتها التاريخية‏. ومن خلال استخدام مؤشر شدة التراجع ‏ كمقياس للمخاطر، فإنها تأخذ في الاعتبار مدى عمق هبوط الأصول المالية وطول الفترة التي تظل فيها دون قممها السابقة‏

تعتمد نسبة مارتن على مؤشر شدة التراجع، الذي طوّره بيتر ج‏. مارتن ونُشر بالاشتراك مع بايرون ب‏. ماكان في كتابهما الصادر عام 1989، "دليل المستثمر إلى صناديق فيديليتي"‏. ويعمل هذا المؤشر كإطار لفحص الأصول بهدف تحديد الأصول الأكثر مرونة وقدرةً على تنمية رأس المال بكفاءة، بدلاً من الأصول التي تعرّض المحفظة لتراجعات كبيرة من حيث الحجم والمدة‏


‏█ [b]‏لماذا تختلف نسبة مارتن؟‏[/b]

أدرك مارتن وجود عيب جوهري في نسبة شارب، إذ تستخدم الانحراف المعياري كمقياس للمخاطر، وهو ما يعامل جميع أنواع التقلبات بنفس الأسلوب  بما في ذلك التحركات الصعودية المفاجئة والحادة‏. وفي استراتيجيات تتبع الاتجاه أو المحافظ مرتفعة النمو، قد تؤدي الحركة الصعودية إلى رفع الانحراف المعياري بشكل مصطنع، مما يجعل الاستراتيجية تبدو أكثر خطورة مما هي عليه فعلياً‏

وعلى خلاف المقاييس الشائعة التي تستخدم الانحراف المعياري لقياس المخاطر، تستخدم نسبة مارتن مؤشر شدة التراجع ‏ في المقام‏. وتُعالج نسبة سورتينو جزءاً من هذه المشكلة من خلال التركيز فقط على تقلبات الجانب السلبي، إلا أن تقلبات الجانب السلبي تقيس حجم التقلبات فقط، بينما يتكون التراجع من عنصرين: الحجم والمدة‏

يقيس مؤشر شدة التراجع مدى هبوط الأصول المالية عن قممها السابقة ومدى استمرارها دون تلك القمم‏. ولذلك فهو يلتقط بُعداً مهماً من مخاطر الاستثمار قد لا تعكسه مقاييس التقلب التقليدية، وهو حجم تراجعات رأس المال ومدة الفترة الزمنية للتراجعات‏

وتختلف المحفظة التي تهبط بنسبة 10% ثم تتعافى سريعاً اختلافاً جوهرياً عن محفظة تهبط بالنسبة نفسها وتظل دون قمتها السابقة لفترة ممتدة‏. وبما أن مؤشر شدة التراجع يُحسب من تسلسل التراجعات عن القمم السابقة، فإن التراجعات الممتدة تواصل التأثير في قيمة المؤشر حتى حدوث التعافي‏

‏[b]‏أهمية عمق التراجع واستمراره‏[/b]
‏ •  مخاطر تجميد رأس المال: يصعب إعادة توظيف رأس المال العالق في تراجع ممتد دون تحقيق خسارة فعلية‏
‏ •  المخاطر السلوكية: كلما كان التراجع أعمق وأطول، زادت احتمالية تخلي المستثمر عن المركز قبل حدوث التعافي‏
‏ •  عبء التعافي على النمو المركب: الوقت المستغرق في تعويض الخسائر السابقة هو وقت لا يتجاوز فيه رأس المال قمته السابقة، أي تمتد فترة طويلة قبل تحقيق الأرباح الفعلية‏

تشير نسبة مارتن المرتفعة إلى أن الأصل حقق عائداً أكبر مقابل كل وحدة من عبء التراجع التاريخي خلال الفترة المحددة‏


‏█ [b]‏الصيغة الرياضية‏[/b]

تحسب نسبة مارتن التقليدية كالتالي

‏نسبة مارتن = (العائد السنوي − العائد الخالي من المخاطر) ÷ مؤشر شدة التراجع

حيث
‏ 
مؤشر شدة التراجع: الجذر التربيعي لمتوسط مربعات نسب التراجع عن القمم التاريخية السابقة. وتشير القيم الأقل للمؤشر إلى تراجعات أقل عمقاً و/أو أقصر استمراراً


‏█ [b]‏حساب نسبة مارتن في التطبيق المستخدم الحالي‏[/b]

تستخدم نسبة مارتن المعروضة في هذا التطبيق إجمالي العائد خلال فترة الحساب المحددة بدلاً من العائد السنوي‏

‏`نسبة مارتن = عائد فترة الحساب ÷ مؤشر شدة التراجع`

كما يتم استبعاد معدل العائد الخالي من المخاطر‏. ونظراً إلى أن كل رمز في التطبيق يُقيَّم باستخدام الإطار الزمني (تايم فريم) نفسه وطول فترة الحساب نفسها، يمكن استخدام القيم الناتجة للمقارنة المباشرة والترتيب داخل مجموعة الأصول المختارة‏. صُمم هذا التطبيق المبسط أساساً كأداة للتصنيف النسبي للأصول، وليس كإعادة حساب لنسبة مارتن التقليدية المحسوبة على أساس سنوي‏


‏█ [b]‏كيف تقارن أداة التقييم بين الأصول‏[/b]

تتبع المقارنة بين الأصول إطاراً ثابتاً من أربع خطوات

[list=1]
[*]‏[b]‏استخدام فترة حساب متطابقة‏[/b] — تُقيَّم جميع الرموز المختارة باستخدام الإطار الزمني نفسه وطول فترة الحساب نفسها‏. وهذا ضروري لإجراء مقارنة ذات معنى، لأن تغيير أي من هذين المتغيرين يغيّر أفق العائد وسجل التراجعات محل القياس‏

[*][b]‏حساب عائد فترة الحساب‏[/b] — يُحسب إجمالي عائد الشراء والاحتفاظ لكل رمز خلال فترة الحساب المحددة‏

[*][b]‏حساب مؤشر شدة التراجع‏[/b] — لكل رمز: تحديد القمة التاريخية المتغيرة ضمن تسلسل الحساب، قياس نسبة تراجع كل سعر إغلاق عن تلك القمة، تربيع قيم التراجع، حساب متوسط مربعات التراجعات، ثم أخذ الجذر التربيعي‏. والنتيجة هي قيمة مؤشر شدة التراجع للرمز خلال الفترة المحددة‏

[*][b]‏حساب نسبة مارتن وترتيبها‏[/b] — يُقسم عائد فترة الحساب على مؤشر شدة التراجع الخاص بالرمز‏. تشير القيم الأعلى إلى مزيج أكثر ملاءمة بين العائد والتراجع خلال فترة القياس المحددة‏
[/list]


‏█ [b]‏ملاحظات الاستخدام‏[/b]

ينبغي أن تكون فترة الحساب طويلة بما يكفي لتغطية فترة ذات دلالة من ظروف السوق، مثل فترة تراجع وتعافٍ لاحق‏. فترات الحساب القصيرة جدًا قد تُنتج نسبًا غير مستقرة أو مضللة، خاصة عندما لا يكون الأصل قد شهد تراجعًا ذا دلالة‏

كنقطة بداية عامة
‏ •  الحد الأدنى: نحو 180 يومًا تقويميًا (حوالي 6 أشهر)
‏ •  المُفضَّل: 365 يومًا تقويميًا (سنة واحدة) أو أكثر

هذه إرشادات عملية وليست حدودًا دنيا مُشتقة إحصائيًا‏. تعتمد فترة الحساب المناسبة على فئة الأصل والأفق الاستثماري المقصود‏. قد تتجاوز فترات الحساب الممتدة لعدة سنوات أو أكثر البيانات التاريخية المتاحة لبعض الرموز — خاصة الأصول المُدرجة حديثًا — مما يؤدي إلى ظهور قيم غير متاح‏

يحسب هذا التطبيق مقاييس كل رمز عبر فترة حساب متطابقة من الأيام التقويمية — وليس عددًا ثابتًا من الشموع — بحيث تغطي فترة حساب معينة (مثل 300 يوم) نفس الـ300 يوم التقويمي سواء للسهم أو للعملة الرقمية أو للعملات الفوركس، بصرف النظر عن عدد الشموع التي يُنتجها كل منها خلال تلك الفترة على أي إطار زمني معين‏. وهذا يجعل إعدادات فترة الحساب قابلة للمقارنة مباشرة عبر فئات الأصول المختلفة، بمعزل عن الإطار الزمني للرسم البياني‏

يبقى اعتماد واحد قائمًا: الرسم البياني المعروض الذي تُشاهد الجدول من خلاله هو ما يحدد توقيت تحديث الحساب الداخلي للتطبيق‏. فإذا كان الرسم البياني لسهم ذي جلسات تداول محدودة (أو ما شابه)، فقد لا تتمكن الرموز من أسواق مستمرة التداول مثل العملات الرقمية من تجميع سجل تقويمي كافٍ، وقد تظهر بقيمة "غير متاح" حتى ضمن فترة حساب مدعومة‏. عند الجمع بين فئات أصول مختلفة في الجدول نفسه، يُنصح بمشاهدة الجدول من رسم بياني لعملة رقمية أو فوركس لتجنب هذه المشكلة‏


‏█ [b]‏الحد المرجعي لنسبة مارتن‏[/b]

حد اللون الأخضر لنسبة مارتن المستخدم في التطبيق هو وسيلة بصرية للمساعدة في الترتيب، وليس حداً فاصلاً مثبتاً إحصائياً‏. تُفسَّر ألوان الجدول على النحو التالي
‏ •  أعلى من الحد: أخضر
‏ •  بين الصفر والحد: رمادي
‏ •  أقل من الصفر: أحمر

ينبغي التعامل مع الحد باعتباره مستوى مرجعياً قابلاً للتعديل، وليس تعريفاً عاماً لما يُعد نسبة مارتن جيدة‏. تكون قيم نسبة مارتن أكثر دلالة عند مقارنة أوراق مالية حُسبت باستخدام المنهجية والإطار الزمني وفترة الحساب نفسها‏. ونظراً إلى أن التطبيق المستخدم هنا يعتمد على عوائد فترة الحساب غير محسوبة على أساس سنوي، فلا ينبغي اعتبار القيم معايير مطلقة عامة عبر إعدادات مختلفة للأطر الزمنية وفترات الحساب‏. للاستخدام العملي، يمكن معايرة الحد بما يتناسب مع خصائص الأصول المالية المرصودة أو مجموعة الأصول الاستثمارية الخاصة بالمستخدم‏


‏█ [b]‏تفسير نسبة مارتن‏[/b]

يتضمن الجدول المقاييس التالية لكل رمز

[list]
[*]‏[b]‏العائد الإجمالي‏[/b] — العائد المئوي التراكمي خلال فترة الحساب المحددة‏

[*][b]‏العائد السنوي‏[/b] — عائد النمو السنوي المركب ‏ لنفس الفترة، يُعرض للاطلاع فقط، ولا يؤثر على نسبة مارتن أو على الترتيب‏

[*]‏[b]‏أقصى تراجع (أيام)‏[/b] — عدد الأيام التقويمية من القمة إلى القاع لأكبر (أعمق) تراجع لوحظ خلال الفترة‏

[*][b]‏% أقصى تراجع‏[/b] — حجم التراجع الأكبر، معبَّرًا عنه كنسبة انخفاض مئوية من قمته السابقة‏

[*]‏[b]‏% فترة التراجع‏[/b] — النسبة المئوية للأيام التقويمية عبر فترة الحساب بأكملها التي كان فيها الأصل يتداول دون قمة سابقة، في أي تراجع  وليس مقتصرًا على التراجع الأكبر فقط‏

[*][b]‏مؤشر شدة التراجع ‏‏[/b] — مقياس يجمع بين عمق التراجع ومدته، ويُحسب كجذر تربيعي لمتوسط مربعات نسب التراجع عبر كل يوم في الفترة‏. وخلافًا لـ % أقصى تراجع، الذي يعكس فقط التراجع الأكبر، يعبّر مؤشر شدة التراجع عن التراكم الكلي "لمعاناة" الأصل من كل التراجعات التي مر بها  فكلما كانت التراجعات أكبر وأطول أمدًا، ارتفعت قيمة المؤشر‏
‏
[*][b]‏نسبة مارتن‏[/b] — العائد الإجمالي مقسومًا على مؤشر شدة التراجع، وتقيس العائد المُحقق مقابل كل وحدة من "معاناة" التراجع‏
[/list]

ضمن مقارنة بإعدادات متطابقة
‏ •  نسبة مارتن الأعلى ← عائد أكبر مقارنةً بعبء التراجع التاريخي‏
‏ •  نسبة مارتن الموجبة المنخفضة ← عائد موجب، لكن مع ملف تراجع أقل ملاءمة‏
‏ •  نسبة مارتن السالبة ← عائد سالب خلال فترة الحساب المحددة‏

لذا، يُعد هذا التطبيق أداة مثالية للترتيب المقطعي ‏ لتحديد الأصول التي حققت أقوى عائد مقارنةً بعمق وديمومة تراجعاتها خلال نفس فترة الحساب‏


‏█ [b]‏إخلاء المسؤولية‏[/b]

يُنشر هذا السكربت لأغراض تعليمية ومعلوماتية فقط، ولا يُعد نصيحة مالية أو استثمارية‏. تعتمد نسبة مارتن بالكامل على بيانات الأسعار التاريخية، ولا يُعد عمق التراجع أو مدته أو سرعة التعافي في الماضي مؤشراً على النتائج المستقبلية‏. احرص دائماً على إجراء أبحاثك الخاصة وتطبيق إدارة سليمة للمخاطر قبل اتخاذ أي قرارات استثمارية‏

## Source Code

````pine
//@version=6
indicator("Martin Ratio Asset Screener [TrendAdvantage]", overlay = true)

// Updated publication chart to keep the symbol, timeframe, and script name visible in the chart status lines.

//© TrendAdvantage
// ═══════════════════════════════════════════════════
// Martin Ratio Asset Screener
// ═══════════════════════════════════════════════════
// The Martin Ratio is a risk-adjusted performance metric that
// evaluates an asset's return relative to both the magnitude and
// duration of its historical drawdowns. Using the Ulcer Index (UI)
// as its risk proxy, it penalizes both how deep an asset falls
// and how long it remains underwater.
//
// This indicator screens up to 25 tickers — across asset classes,
// lookback periods, and timeframes — ranking them by Martin Ratio
// in a table. Additional columns include total and annualized returns,
// days to max drawdown, max drawdown %, time underwater %, and Ulcer Index.
//
// ═══════════════════════════════════════════════════
// تصنيف الأصول المالية باستخدام نسبة مارتن
// ═══════════════════════════════════════════════════
// نسبة مارتن هي مقياس يقيّم عائد الأصول المالية مقارنةً بكلٍ من
// حجم ومدة تراجعاتها التاريخية. ومن خلال استخدام مؤشر شدة التراجع
// (Ulcer Index – UI) كمقياس للمخاطر، فإنها تأخذ في الاعتبار مدى عمق
// هبوط الأصول المالية وطول الفترة التي تظل فيها دون قممها السابقة.
//
// يقوم هذا المؤشر بتقييم ما يصل إلى 25 رمزًا — عبر فئات الأصول المختلفة
// .ومدد الحساب والأطر الزمنية — ويرتبها في جدول وفقًا لنسبة مارتن
// ، تشمل الأعمدة الإضافية العائد الإجمالي والعائد السنوي
// وعدد الأيام للوصول إلى أقصى تراجع، ونسبة أقصى تراجع المئوية، ونسبة
// .(Ulcer Index) فترة التراجع الزمنية المئوية، ومؤشر شدة التراجع


// ═══════════════════════════════════════════════════
// License: Mozilla Public License 2.0 (MPL-2.0)
// https://mozilla.org/MPL/2.0/
//
// This source code is subject to the terms of the MPL 2.0.
// Any derivative work must retain this copyright notice.
// ═══════════════════════════════════════════════════
// TradingView: tradingview.com/u/TrendAdvantage
// ============================================================
// HOUSE RULES COMPLIANCE & RISK DISCLAIMER
// ============================================================
// This indicator is an econometric measurement tool.
// Past sequence characteristics do not guarantee
// future market behavior. All outputs are descriptive
// statistical evidence and do not guarantee future results.
//=====================================================
// ─────────────────────────────────────────────
// LANGUAGE SELECTOR
// ─────────────────────────────────────────────

langToggle = input.string("English", "Menu Language / لغة القائمة", options = ["English", "العربية"])
isEn = (langToggle == "English")
isAr = (langToggle == "العربية")

// ─────────────────────────────────────────────
// GENERAL SETTINGS — bilingual active-group pattern
// ─────────────────────────────────────────────

group_en = "General Settings"
group_ar = "الإعدادات العامة"

i_lookback_days_en = input.int(365, "Lookback Period (Calendar Days)", minval = 7, maxval = 3650,
     group = group_en, active = isEn,
     tooltip = "Calendar-day window used for calculations, solved per-ticker so results stay comparable across different trading schedules (e.g. 5-day equities vs 7-day crypto). Recommended minimum lookback: 365 days, to capture a meaningful range of market conditions. Very long windows on fast intraday timeframes can exceed what the indicator can calculate — if so, the table uses the largest supported window and flags it in the subtitle. A ticker can also show N/A within a supported window if TradingView's historical data for that symbol/timeframe doesn't go back far enough.")

i_lookback_days_ar = input.int(365, "فترة الحساب (بالأيام التقويمية)", minval = 7, maxval = 3650,
     group = group_ar, active = isAr,
     tooltip =  ".فترة زمنية بالأيام التقويمية تُستخدم للحسابات، تحسب لكل رمز على حدة لتبقى النتائج قابلة للمقارنة بين فترات التداول المختلفة (مثل 5 أيام للأسهم مقابل 7 أيام للعملات الرقمية). الحد الأدنى الموصى به لفترة الحساب: 365 يومًا، لتغطية مدى ذي دلالة من الظروف السوقية. فترات الحساب الطويلة على الأطر الزمنية القصيرة قد تتجاوز ما يمكن المؤشر حسابه — في هذه الحالة يستخدم الجدول أكبر فترة حساب مدعومة وينبّه لذلك في العنوان الفرعي. قد يظهر الرمز أيضاً بقيمة غير متاح ضمن فترة حساب مدعومة إذا كانت بيانات الأسعار التاريخية لهذا الرمز والإطار الزمني لا تمتد لفترة كافية")

i_mr_threshold_en = input.float(2.0, "Martin Ratio Green Threshold", minval = 0.1, step = 0.1,
     group = group_en, active = isEn,
     tooltip = "Martin Ratio values above this threshold are highlighted in green. Between 0 and threshold: neutral. Negative: red.")

i_mr_threshold_ar = input.float(2.0, " حد نسبة مارتن للون الأخضر", minval = 0.1, step = 0.1,
     group = group_ar, active = isAr,
     tooltip = "قيم نسبة مارتن الأعلى من هذا الحد تُعرض باللون الأخضر. بين الصفر والحد: محايد القيم السالبة: باللون الأحمر")

i_table_pos_en = input.string("Top Right", "Table Position",
     options = ["Bottom Right", "Bottom Left", "Top Right", "Top Left"],
     group = group_en, active = isEn)

i_table_pos_ar = input.string("أعلى يمين", "موضع الجدول",
     options = ["أسفل يمين", "أسفل يسار", "أعلى يمين", "أعلى يسار"],
     group = group_ar, active = isAr)

i_theme_en = input.string("Dark", "Table Theme", options = ["Dark", "Light"],
     group = group_en, active = isEn)

i_theme_ar = input.string("داكن", "مظهر الجدول", options = ["داكن", "فاتح"],
     group = group_ar, active = isAr)

// Table Text Size lets users trade density for fit on small screens.
i_textsize_en = input.string("Normal", "Table Text Size", options = ["Small", "Normal"],
     group = group_en, active = isEn,
     tooltip = "Use Small text on small screens to fit more rows before the table exceeds the visible range.")

i_textsize_ar = input.string("عادي", "حجم خط الجدول", options = ["صغير", "عادي"],
     group = group_ar, active = isAr,
     tooltip = "استخدم الحجم الصغير للنص على الشاشات الصغيرة لعرض عدد أكبر من الصفوف قبل أن يتجاوز الجدول النطاق المرئي")

// Compact Mode caps ticker rows at 10, independent of the legend.
i_compact_en = input.bool(false, "Compact Mode (Limit to Top 10)",
     group = group_en, active = isEn,
     tooltip = "Limits the table to the top 10 ranked tickers, useful for devoices with smaller screens.")

i_compact_ar = input.bool(false, "الوضع المصغر (أفضل 10 رموز فقط)",
     group = group_ar, active = isAr,
     tooltip = "يقتصر الجدول على أفضل 10 رموز من حيث الترتيب وهو ملائم للشاشات الصغيرة")

// Show Metric Legend adds a collapsible bilingual key below the table, default on.
i_legend_en = input.bool(true, "Show Metric Legend",
     group = group_en, active = isEn,
     tooltip = "Adds a compact explanatory key below the table defining each column abbreviation.")

i_legend_ar = input.bool(true, "إظهار شرح المصطلحات",
     group = group_ar, active = isAr,
     tooltip = ".يضيف شرحاً مختصراً أسفل الجدول لتعريف كل عمود من الأعمدة")

// Resolved values — route to whichever language group is active
i_lookback_days = isEn ? i_lookback_days_en : i_lookback_days_ar
i_mr_threshold   = isEn ? i_mr_threshold_en   : i_mr_threshold_ar
i_compact        = isEn ? i_compact_en        : i_compact_ar
i_show_legend    = isEn ? i_legend_en         : i_legend_ar

// ─────────────────────────────────────────────
// CAPACITY SIZING — array-based architecture (see calc_metrics below)
// Metrics are computed from a per-ticker rolling array of (time, close) built up
// bar-by-bar, NOT from close[i]/time[i] historical indexing. That removes the
// max_bars_back / 5000-bar ceiling entirely — the real ceiling becomes Pine's
// hard 100,000-element-per-array limit. ARRAY_SAFETY_CAP stays a margin under
// that wall (per TradingView's own performance guidance to avoid arrays anywhere
// near their true limit). bars_per_day uses a 24/7-session assumption, which is a
// safe overestimate for any session-limited asset (equities need fewer real bars
// per day than this), so the sizing below never under-budgets capacity.
// ─────────────────────────────────────────────
ARRAY_SAFETY_CAP = 90000
BUFFER_DAYS      = 3   // small grace window so trimming never cuts exactly at the boundary

bar_seconds        = timeframe.in_seconds(timeframe.period)
bars_per_day       = bar_seconds > 0 ? 86400.0 / bar_seconds : 1.0
max_supportable_days = math.max(1, int(math.floor(ARRAY_SAFETY_CAP / bars_per_day)) - BUFFER_DAYS)

i_effective_lookback_days = math.min(i_lookback_days, max_supportable_days)
lookback_capped           = i_lookback_days > max_supportable_days
isDark           = isEn ? (i_theme_en == "Dark") : (i_theme_ar == "داكن")

// Resolved text-size input, drives header + all data-row cells.
i_cell_size = isEn ?
     (i_textsize_en == "Small" ? size.small : size.normal) :
     (i_textsize_ar == "صغير"  ? size.small : size.normal)

// Row-budget resolution driven by Compact Mode + Legend toggle.
max_ticker_rows = i_compact ? 10 : 25
legend_rows_n   = i_show_legend ? 2 : 0
// warn_row_n and total_rows are computed further below, after the per-ticker
// request.security() calls, since the warning row depends on each ticker's
// syminfo.type (see HOST-CHART / TICKER ASSET-CLASS MISMATCH CHECK below).

table_position =
     isEn ?
          (i_table_pos_en == "Bottom Right" ? position.bottom_right :
           i_table_pos_en == "Bottom Left"  ? position.bottom_left  :
           i_table_pos_en == "Top Right"    ? position.top_right    :
                                              position.top_left)
     :
          (i_table_pos_ar == "أسفل يمين" ? position.bottom_right :
           i_table_pos_ar == "أسفل يسار" ? position.bottom_left  :
           i_table_pos_ar == "أعلى يمين" ? position.top_right    :
                                          position.top_left)

// ─────────────────────────────────────────────
// TICKER INPUTS — bilingual label, single shared group
// each ticker has an Enable checkbox inline with its symbol picker
// ─────────────────────────────────────────────

group_tickers = "Tickers / الرموز"

i_en1  = input.bool(true, "", inline = "t1",  group = group_tickers)
i_t1   = input.symbol("AAPL",  "Ticker 1 / الرمز ١",   inline = "t1",  group = group_tickers,
     tooltip = "When mixing asset classes in the table, apply the indicator to a crypto or forex chart. Equity charts have limited trading hours that can cause N/A results for non-equity tickers.\nعند دمج فئات أصول مختلفة في الجدول، طبّق المؤشر على رسم بياني لعملة رقمية أو فوركس. ساعات تداول الأسهم المحدودة قد تؤدي إلى ظهور نتائج غير متاح لرموز التداول لغير الأسهم")
i_en2  = input.bool(true, "", inline = "t2",  group = group_tickers)
i_t2   = input.symbol("MSFT",  "Ticker 2 / الرمز ٢",   inline = "t2",  group = group_tickers)
i_en3  = input.bool(true, "", inline = "t3",  group = group_tickers)
i_t3   = input.symbol("GOOGL", "Ticker 3 / الرمز ٣",   inline = "t3",  group = group_tickers)
i_en4  = input.bool(true, "", inline = "t4",  group = group_tickers)
i_t4   = input.symbol("AMZN",  "Ticker 4 / الرمز ٤",   inline = "t4",  group = group_tickers)
i_en5  = input.bool(true, "", inline = "t5",  group = group_tickers)
i_t5   = input.symbol("NVDA",  "Ticker 5 / الرمز ٥",   inline = "t5",  group = group_tickers)
i_en6  = input.bool(true, "", inline = "t6",  group = group_tickers)
i_t6   = input.symbol("TSLA",  "Ticker 6 / الرمز ٦",   inline = "t6",  group = group_tickers)
i_en7  = input.bool(true, "", inline = "t7",  group = group_tickers)
i_t7   = input.symbol("AVGO",  "Ticker 7 / الرمز ٧",   inline = "t7",  group = group_tickers)
i_en8  = input.bool(true, "", inline = "t8",  group = group_tickers)
i_t8   = input.symbol("MU",    "Ticker 8 / الرمز ٨",   inline = "t8",  group = group_tickers)
i_en9  = input.bool(true, "", inline = "t9",  group = group_tickers)
i_t9   = input.symbol("AMD",   "Ticker 9 / الرمز ٩",   inline = "t9",  group = group_tickers)
i_en10 = input.bool(true, "", inline = "t10", group = group_tickers)
i_t10  = input.symbol("TSM",   "Ticker 10 / الرمز ١٠", inline = "t10", group = group_tickers)
i_en11 = input.bool(true, "", inline = "t11", group = group_tickers)
i_t11  = input.symbol("QCOM",  "Ticker 11 / الرمز ١١", inline = "t11", group = group_tickers)
i_en12 = input.bool(true, "", inline = "t12", group = group_tickers)
i_t12  = input.symbol("ORCL",  "Ticker 12 / الرمز ١٢", inline = "t12", group = group_tickers)
i_en13 = input.bool(true, "", inline = "t13", group = group_tickers)
i_t13  = input.symbol("PLTR",  "Ticker 13 / الرمز ١٣", inline = "t13", group = group_tickers)
i_en14 = input.bool(true, "", inline = "t14", group = group_tickers)
i_t14  = input.symbol("CRM",   "Ticker 14 / الرمز ١٤", inline = "t14", group = group_tickers)
i_en15 = input.bool(true, "", inline = "t15", group = group_tickers)
i_t15  = input.symbol("CSCO",  "Ticker 15 / الرمز ١٥", inline = "t15", group = group_tickers)
i_en16 = input.bool(false, "", inline = "t16", group = group_tickers)
i_t16  = input.symbol("",      "Ticker 16 / الرمز ١٦", inline = "t16", group = group_tickers)
i_en17 = input.bool(false, "", inline = "t17", group = group_tickers)
i_t17  = input.symbol("",      "Ticker 17 / الرمز ١٧", inline = "t17", group = group_tickers)
i_en18 = input.bool(false, "", inline = "t18", group = group_tickers)
i_t18  = input.symbol("",      "Ticker 18 / الرمز ١٨", inline = "t18", group = group_tickers)
i_en19 = input.bool(false, "", inline = "t19", group = group_tickers)
i_t19  = input.symbol("",      "Ticker 19 / الرمز ١٩", inline = "t19", group = group_tickers)
i_en20 = input.bool(false, "", inline = "t20", group = group_tickers)
i_t20  = input.symbol("",      "Ticker 20 / الرمز ٢٠", inline = "t20", group = group_tickers)
i_en21 = input.bool(false, "", inline = "t21", group = group_tickers)
i_t21  = input.symbol("",      "Ticker 21 / الرمز ٢١", inline = "t21", group = group_tickers)
i_en22 = input.bool(false, "", inline = "t22", group = group_tickers)
i_t22  = input.symbol("",      "Ticker 22 / الرمز ٢٢", inline = "t22", group = group_tickers)
i_en23 = input.bool(false, "", inline = "t23", group = group_tickers)
i_t23  = input.symbol("",      "Ticker 23 / الرمز ٢٣", inline = "t23", group = group_tickers)
i_en24 = input.bool(false, "", inline = "t24", group = group_tickers)
i_t24  = input.symbol("",      "Ticker 24 / الرمز ٢٤", inline = "t24", group = group_tickers)
i_en25 = input.bool(false, "", inline = "t25", group = group_tickers)
i_t25  = input.symbol("",      "Ticker 25 / الرمز ٢٥", inline = "t25", group = group_tickers)

// ─────────────────────────────────────────────
// FUNCTIONS
// ─────────────────────────────────────────────

// Calendar-anchored metrics, anchored to the last confirmed bar (anti-repaint).
// Builds a per-ticker rolling (time, close) buffer bar-by-bar on confirmed bars
// only, trimmed via array.shift() once entries age past the lookback window.
// This removes Pine's max_bars_back ceiling entirely — the real limit becomes
// the array size cap (see CAPACITY SIZING above). Heavy computation (binary
// search + drawdown loop) is gated to barstate.islast, since that's the only
// bar whose values ever reach the table.
// Also returns sym_type (syminfo.type) at no extra cost, used downstream for
// the host-chart / asset-class mismatch warning.
calc_metrics(lookback_days) =>
    var times  = array.new_float(0)
    var prices = array.new_float(0)

    ms_per_day = 86400000.0

    if barstate.isconfirmed
        array.push(times, time)
        array.push(prices, close)

        retention_ms = (lookback_days + 3) * ms_per_day  // +3 buffer days, mirrors BUFFER_DAYS
        cutoff       = time - retention_ms
        while array.size(times) > 1 and array.get(times, 0) < cutoff
            array.shift(times)
            array.shift(prices)

    float t_return = na
    float a_return = na
    float dd_days  = na
    float dd_pct   = na
    float t_in_dd  = na
    float ui_val   = na
    string sym_type = syminfo.type

    if barstate.islast
        n = array.size(times)
        if n >= 2
            anchor_time = array.get(times, n - 1)
            target_time = anchor_time - lookback_days * ms_per_day

            // Binary search: leftmost index with times[idx] >= target_time
            lo = 0
            hi = n - 1
            while lo < hi
                mid = int((lo + hi) / 2)  // v6: int/int returns float — must cast back to int
                if array.get(times, mid) < target_time
                    lo := mid + 1
                else
                    hi := mid
            start_idx = lo

            enough_history = array.get(times, 0) <= target_time

            if enough_history
                start_price  = array.get(prices, start_idx)
                cur_price    = array.get(prices, n - 1)
                elapsed_days = (anchor_time - array.get(times, start_idx)) / ms_per_day

                if elapsed_days > 0 and start_price > 0
                    t_return := (cur_price - start_price) / start_price
                    a_return := math.pow(cur_price / start_price, 365.25 / elapsed_days) - 1

                    running_peak  = start_price
                    peak_pos      = start_idx
                    sum_sq        = 0.0
                    dd_count      = 0
                    worst_dd      = 0.0
                    worst_dd_days = 0.0
                    window_len    = n - start_idx

                    for k = start_idx to n - 1
                        c = array.get(prices, k)
                        if c > running_peak
                            running_peak := c
                            peak_pos := k
                        ddp = (c - running_peak) / running_peak * 100
                        sum_sq += ddp * ddp
                        if ddp < 0
                            dd_count += 1
                        if ddp < worst_dd
                            worst_dd := ddp
                            worst_dd_days := (array.get(times, k) - array.get(times, peak_pos)) / ms_per_day

                    ui_val  := math.sqrt(sum_sq / window_len)
                    dd_pct  := worst_dd
                    dd_days := worst_dd_days
                    t_in_dd := dd_count / window_len * 100

    [t_return, a_return, dd_days, dd_pct, t_in_dd, ui_val, sym_type]

// Skips request.security() entirely when a ticker is disabled, so disabled
// tickers cost nothing computationally — this matters when mixed asset classes
// compete for the same historical-bar budget on long lookbacks.
// Martin Ratio uses raw Total Return, not Annualized Return, to avoid CAGR's
// convex compounding distortion on short windows. Ann. Ret is still computed
// and displayed for reference, but has zero influence on mr or sort order.
compute_mr(sym, en, lookback_days) =>
    if not en or str.length(sym) == 0
        [float(na), float(na), float(na), float(na), float(na), float(na), float(na), string(na)]
    else
        [tr, ar, ddb, ddp, tid, ui, styp] = request.security(sym, timeframe.period,
             calc_metrics(lookback_days), lookahead = barmerge.lookahead_off)
        mr = (not na(ui)) and ui > 1e-6 ? (tr * 100) / ui : na
        [tr, ar, ddb, ddp, tid, ui, mr, styp]

tf_label() =>
    string lbl = na
    if timeframe.isseconds
        lbl := isEn ? timeframe.period + "s" : timeframe.period + " ثانية"
    else if timeframe.isminutes
        mins = str.tonumber(timeframe.period)
        if mins >= 60 and mins % 60 == 0
            hrs = str.tostring(int(mins / 60))
            lbl := isEn ? hrs + "H" : hrs + " ساعة"
        else
            lbl := isEn ? timeframe.period + "m" : timeframe.period + " دقيقة" 
    else if timeframe.isdaily
        lbl := isEn ? "Daily" : "يومي"
    else if timeframe.isweekly
        lbl := isEn ? "Weekly" : "أسبوعي"
    else if timeframe.ismonthly
        lbl := isEn ? "Monthly" : "شهري"
    else
        lbl := timeframe.period
    lbl

_safe(v) => na(v) ? -1e10 : v

// ─────────────────────────────────────────────
// SECURITY CALLS — fixed at compile time.
// Each call passes its matching i_enN flag as a gate.
// ─────────────────────────────────────────────

[tr1,  ar1,  ddb1,  ddp1,  tid1,  ui1,  mr1,  styp1]  = compute_mr(i_t1,  i_en1,  i_effective_lookback_days)
[tr2,  ar2,  ddb2,  ddp2,  tid2,  ui2,  mr2,  styp2]  = compute_mr(i_t2,  i_en2,  i_effective_lookback_days)
[tr3,  ar3,  ddb3,  ddp3,  tid3,  ui3,  mr3,  styp3]  = compute_mr(i_t3,  i_en3,  i_effective_lookback_days)
[tr4,  ar4,  ddb4,  ddp4,  tid4,  ui4,  mr4,  styp4]  = compute_mr(i_t4,  i_en4,  i_effective_lookback_days)
[tr5,  ar5,  ddb5,  ddp5,  tid5,  ui5,  mr5,  styp5]  = compute_mr(i_t5,  i_en5,  i_effective_lookback_days)
[tr6,  ar6,  ddb6,  ddp6,  tid6,  ui6,  mr6,  styp6]  = compute_mr(i_t6,  i_en6,  i_effective_lookback_days)
[tr7,  ar7,  ddb7,  ddp7,  tid7,  ui7,  mr7,  styp7]  = compute_mr(i_t7,  i_en7,  i_effective_lookback_days)
[tr8,  ar8,  ddb8,  ddp8,  tid8,  ui8,  mr8,  styp8]  = compute_mr(i_t8,  i_en8,  i_effective_lookback_days)
[tr9,  ar9,  ddb9,  ddp9,  tid9,  ui9,  mr9,  styp9]  = compute_mr(i_t9,  i_en9,  i_effective_lookback_days)
[tr10, ar10, ddb10, ddp10, tid10, ui10, mr10, styp10] = compute_mr(i_t10, i_en10, i_effective_lookback_days)
[tr11, ar11, ddb11, ddp11, tid11, ui11, mr11, styp11] = compute_mr(i_t11, i_en11, i_effective_lookback_days)
[tr12, ar12, ddb12, ddp12, tid12, ui12, mr12, styp12] = compute_mr(i_t12, i_en12, i_effective_lookback_days)
[tr13, ar13, ddb13, ddp13, tid13, ui13, mr13, styp13] = compute_mr(i_t13, i_en13, i_effective_lookback_days)
[tr14, ar14, ddb14, ddp14, tid14, ui14, mr14, styp14] = compute_mr(i_t14, i_en14, i_effective_lookback_days)
[tr15, ar15, ddb15, ddp15, tid15, ui15, mr15, styp15] = compute_mr(i_t15, i_en15, i_effective_lookback_days)
[tr16, ar16, ddb16, ddp16, tid16, ui16, mr16, styp16] = compute_mr(i_t16, i_en16, i_effective_lookback_days)
[tr17, ar17, ddb17, ddp17, tid17, ui17, mr17, styp17] = compute_mr(i_t17, i_en17, i_effective_lookback_days)
[tr18, ar18, ddb18, ddp18, tid18, ui18, mr18, styp18] = compute_mr(i_t18, i_en18, i_effective_lookback_days)
[tr19, ar19, ddb19, ddp19, tid19, ui19, mr19, styp19] = compute_mr(i_t19, i_en19, i_effective_lookback_days)
[tr20, ar20, ddb20, ddp20, tid20, ui20, mr20, styp20] = compute_mr(i_t20, i_en20, i_effective_lookback_days)
[tr21, ar21, ddb21, ddp21, tid21, ui21, mr21, styp21] = compute_mr(i_t21, i_en21, i_effective_lookback_days)
[tr22, ar22, ddb22, ddp22, tid22, ui22, mr22, styp22] = compute_mr(i_t22, i_en22, i_effective_lookback_days)
[tr23, ar23, ddb23, ddp23, tid23, ui23, mr23, styp23] = compute_mr(i_t23, i_en23, i_effective_lookback_days)
[tr24, ar24, ddb24, ddp24, tid24, ui24, mr24, styp24] = compute_mr(i_t24, i_en24, i_effective_lookback_days)
[tr25, ar25, ddb25, ddp25, tid25, ui25, mr25, styp25] = compute_mr(i_t25, i_en25, i_effective_lookback_days)

// ─────────────────────────────────────────────
// HOST-CHART / TICKER ASSET-CLASS MISMATCH CHECK
// syminfo.type on the host chart is free (no security call). Per-ticker type
// comes from calc_metrics' sym_type output via the request.security() call
// each ticker already makes — no extra calls needed.
// A restricted-session equity host chart (stock/fund/index) starves
// crypto/forex history accumulation for any enabled non-equity ticker, which
// is the root cause of the multi-asset N/A bug. This check surfaces that
// condition directly instead of leaving it a silent, confusing failure.
// ─────────────────────────────────────────────
host_is_restricted_equity = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "index"

is_non_equity(t) => t == "forex" or t == "crypto"

any_non_equity_enabled = (i_en1  and is_non_equity(styp1))  or (i_en2  and is_non_equity(styp2))  or
     (i_en3  and is_non_equity(styp3))  or (i_en4  and is_non_equity(styp4))  or
     (i_en5  and is_non_equity(styp5))  or (i_en6  and is_non_equity(styp6))  or
     (i_en7  and is_non_equity(styp7))  or (i_en8  and is_non_equity(styp8))  or
     (i_en9  and is_non_equity(styp9))  or (i_en10 and is_non_equity(styp10)) or
     (i_en11 and is_non_equity(styp11)) or (i_en12 and is_non_equity(styp12)) or
     (i_en13 and is_non_equity(styp13)) or (i_en14 and is_non_equity(styp14)) or
     (i_en15 and is_non_equity(styp15)) or (i_en16 and is_non_equity(styp16)) or
     (i_en17 and is_non_equity(styp17)) or (i_en18 and is_non_equity(styp18)) or
     (i_en19 and is_non_equity(styp19)) or (i_en20 and is_non_equity(styp20)) or
     (i_en21 and is_non_equity(styp21)) or (i_en22 and is_non_equity(styp22)) or
     (i_en23 and is_non_equity(styp23)) or (i_en24 and is_non_equity(styp24)) or
     (i_en25 and is_non_equity(styp25))

host_mismatch_warning = host_is_restricted_equity and any_non_equity_enabled

// The table is recreated fresh each redraw sized to the current total_rows,
// so this row simply doesn't exist at all when neither condition holds.
warn_row_n = (lookback_capped or host_mismatch_warning) ? 1 : 0
total_rows = 2 + warn_row_n + max_ticker_rows + legend_rows_n   // header + subtitle + [warning] + tickers + legend

// ─────────────────────────────────────────────
// SORTING — insertion sort, descending by Martin Ratio.
// ─────────────────────────────────────────────

sort_desc(syms, tr_arr, ar_arr, ddb_arr, ddp_arr, tid_arr, ui_arr, mr_arr) =>
    n = array.size(syms)
    for i = 1 to n - 1
        key_s   = array.get(syms,    i)
        key_tr  = array.get(tr_arr,  i)
        key_ar  = array.get(ar_arr,  i)
        key_ddb = array.get(ddb_arr, i)
        key_ddp = array.get(ddp_arr, i)
        key_tid = array.get(tid_arr, i)
        key_ui  = array.get(ui_arr,  i)
        key_mr  = array.get(mr_arr,  i)
        j = i - 1
        while j >= 0 and array.get(mr_arr, j) < key_mr
            array.set(syms,    j + 1, array.get(syms,    j))
            array.set(tr_arr,  j + 1, array.get(tr_arr,  j))
            array.set(ar_arr,  j + 1, array.get(ar_arr,  j))
            array.set(ddb_arr, j + 1, array.get(ddb_arr, j))
            array.set(ddp_arr, j + 1, array.get(ddp_arr, j))
            array.set(tid_arr, j + 1, array.get(tid_arr, j))
            array.set(ui_arr,  j + 1, array.get(ui_arr,  j))
            array.set(mr_arr,  j + 1, array.get(mr_arr,  j))
            j -= 1
        array.set(syms,    j + 1, key_s)
        array.set(tr_arr,  j + 1, key_tr)
        array.set(ar_arr,  j + 1, key_ar)
        array.set(ddb_arr, j + 1, key_ddb)
        array.set(ddp_arr, j + 1, key_ddp)
        array.set(tid_arr, j + 1, key_tid)
        array.set(ui_arr,  j + 1, key_ui)
        array.set(mr_arr,  j + 1, key_mr)

// ─────────────────────────────────────────────
// TABLE SYSTEM — theme-aware palette
// ─────────────────────────────────────────────

C_HEADER   = isDark ? color.new(#1b2838, 0) : color.new(#E2E8F0, 0)
C_SUBTITLE = isDark ? color.new(#1b2838, 0) : color.new(#E2E8F0, 0)
C_TEXT     = isDark ? color.white : color.new(#1E293B, 0)
C_MUTED    = isDark ? color.new(color.white, 20) : color.new(#1E293B, 30)
C_RANK_DEF = isDark ? color.new(#2c3e50, 0) : color.new(#d7dde3, 0)
C_BAND_A   = isDark ? color.new(#0f1823, 0) : color.new(#ffffff, 0)
C_BAND_B   = isDark ? color.new(#16212e, 0) : color.new(#F8FAFC, 0)
BORDER_COL = isDark ? color.new(#d4af37, 70) : color.new(#CBD5E1, 0)
FRAME_COL  = isDark ? color.new(#d4af37, 40) : color.new(#CBD5E1, 0)

// Sign-based cell fills and text, matching the original theme palette exactly.
C_CELL_GREEN     = isDark ? #0d5c3a : #D1FAE5
C_CELL_RED       = isDark ? #8c1d18 : #FEE2E2
C_CELL_TEXT_POS  = isDark ? color.white : #065F46
C_CELL_TEXT_NEG  = isDark ? color.white : #991B1B

// Dedicated neutral fill for Martin Ratio cells that are neither bearish nor
// above the green threshold, so the neutral zone reads as a deliberate signal
// rather than blank/near-invisible alternating row color.
C_MR_NEUTRAL     = isDark ? color.new(#2c3e50, 0) : color.new(#E2E8F0, 0)

// Table is deleted and recreated fresh on every redraw, sized to the current
// total_rows, so a row-count change (Compact Mode, warning row, etc.) is
// always reflected correctly.
var table leaderboard = na

// Column widths use Pine's normal auto-sizing (no explicit width arguments);
// the capacity-warning text instead wraps onto its own line within its cell.
_header(col, txt) =>
    table.cell(leaderboard, col, 0, txt,
         text_color = C_TEXT, text_size = i_cell_size,
         bgcolor = C_HEADER, text_halign = text.align_center)

var bool firstDraw = true

if barstate.islast and (barstate.isnew or firstDraw)
    firstDraw := false

    if not na(leaderboard)
        table.delete(leaderboard)
    leaderboard := table.new(table_position, columns = 9, rows = total_rows,
         border_width = 1, border_color = BORDER_COL,
         frame_width  = 2, frame_color  = FRAME_COL)

    hdr_rank   = isEn ? "RANK"        : "الترتيب"
    hdr_ticker = isEn ? "TICKER"      : "الرمز"
    hdr_tret   = isEn ? "TOTAL RET"   : "العائد الإجمالي"
    hdr_aret   = isEn ? "ANN. RET"    : "العائد السنوي"
    hdr_ddbars = isEn ? "DD (DAYS)" : "أقصى تراجع (أيام)"
    hdr_ddpct  = isEn ? "DD %"    : "% أقصى تراجع"
    hdr_tind   = isEn ? "TIME IN DD %": "% فترة التراجع"
    hdr_ulcer  = isEn ? "ULCER IDX"   : "مؤشر التراجع"
    hdr_martin = isEn ? "MARTIN R"    : "نسبة مارتن"

    _header(0, hdr_rank)
    _header(1, hdr_ticker)
    _header(2, hdr_tret)
    _header(3, hdr_aret)
    _header(4, hdr_ddbars)
    _header(5, hdr_ddpct)
    _header(6, hdr_tind)
    _header(7, hdr_ulcer)
    _header(8, hdr_martin)

    // ─────────────────────────────────────────────
    // SUBTITLE ROW
    // ─────────────────────────────────────────────
    date_fmt   = timeframe.isintraday ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd"
    tf_str     = tf_label()
    ms_per_day_sub = 86400000.0
    as_of      = str.format_time(time, date_fmt, "UTC")
    begin_date = str.format_time(int(time - i_effective_lookback_days * ms_per_day_sub), date_fmt, "UTC")

    if isEn
        subtitle_en = str.tostring(i_effective_lookback_days) + "-Day Calendar Window   |   " + tf_str + "   |   " + begin_date + " → " + as_of
        table.merge_cells(leaderboard, 0, 1, 8, 1)
        table.cell(leaderboard, 0, 1, subtitle_en,
             text_color = C_MUTED, text_size = size.small,
             bgcolor = C_SUBTITLE, text_halign = text.align_center)
    else
        // Arabic subtitle splits into separate cells per zone (dates / timeframe /
        // lookback text) rather than one merged string, to avoid bidi rendering
        // issues when Arabic and Latin-numeral content are interleaved.
        ar_dates    = "من " + begin_date + " إلى " + as_of
        ar_tf       = tf_str
        ar_lookback = str.tostring(i_effective_lookback_days) + " يوم تقويمي"

        table.merge_cells(leaderboard, 0, 1, 4, 1)
        table.cell(leaderboard, 0, 1, ar_dates,
             text_color = C_MUTED, text_size = size.small,
             bgcolor = C_SUBTITLE, text_halign = text.align_center)

        table.cell(leaderboard, 5, 1, ar_tf,
             text_color = C_MUTED, text_size = size.small,
             bgcolor = C_SUBTITLE, text_halign = text.align_center)

        table.merge_cells(leaderboard, 6, 1, 8, 1)
        table.cell(leaderboard, 6, 1, ar_lookback,
             text_color = C_MUTED, text_size = size.small,
             bgcolor = C_SUBTITLE, text_halign = text.align_center)

    // ─────────────────────────────────────────────
    // CAPACITY / HOST-MISMATCH WARNING ROW — full-width (merged 0-8), drawn
    // only when either condition is active. When both conditions fire at
    // once, they're merged into a single combined message rather than two
    // rows, since only one row is ever reserved for either/both.
    // ─────────────────────────────────────────────
    if lookback_capped or host_mismatch_warning
        warn_row      = 2
        warn_bg       = isDark ? color.new(#3C3F44, 0) : color.new(#FEF3C7, 0)
        warn_txt_col  = isDark ? color.new(#FFC107, 0) : color.new(#92400E, 0)

        lookback_msg_en = "Requested " + str.tostring(i_lookback_days) + "d exceeds capacity at this timeframe — using " + str.tostring(i_effective_lookback_days) + "d"
        lookback_msg_ar = "الفترة المطلوبة (" + str.tostring(i_lookback_days) + " يوم) تتجاوز السعة على هذا الإطار — تم استخدام " + str.tostring(i_effective_lookback_days) + " يوم"

        host_msg_en = "Host chart is equity — forex/crypto tickers may show N/A. Apply the indicator to a crypto or forex chart instead."
        host_msg_ar = ".الرمز الحالي أسهم — قد تظهر رموز العملات الرقمية/الفوركس بقيمة غير متاح. طبّق المؤشر على رسم بياني لعملة رقمية أو فوركس بدلاً من ذلك"

        warn_msg = isEn ?
             "⚠ " + (lookback_capped and host_mismatch_warning ? lookback_msg_en + ". Also, " + host_msg_en :
                     lookback_capped ? lookback_msg_en : host_msg_en) :
             "⚠ " + (lookback_capped and host_mismatch_warning ? lookback_msg_ar + ". كما أن " + host_msg_ar :
                     lookback_capped ? lookback_msg_ar : host_msg_ar)

        table.merge_cells(leaderboard, 0, warn_row, 8, warn_row)
        table.cell(leaderboard, 0, warn_row, warn_msg,
             text_color = warn_txt_col, text_size = size.small,
             bgcolor = warn_bg, text_halign = text.align_center)

    // ─────────────────────────────────────────────
    // PACK + SORT — values are pushed directly with array.push() calls at
    // script scope (not inside a helper function), since only `=>` function
    // definitions are subject to Pine's external-elements limit.
    // ─────────────────────────────────────────────
    syms    = array.new_string(0)
    tr_arr  = array.new_float(0)
    ar_arr  = array.new_float(0)
    ddb_arr = array.new_float(0)
    ddp_arr = array.new_float(0)
    tid_arr = array.new_float(0)
    ui_arr  = array.new_float(0)
    mr_arr  = array.new_float(0)

    if i_en1 and str.length(i_t1) > 0
        array.push(syms, i_t1)
        array.push(tr_arr, tr1)
        array.push(ar_arr, ar1)
        array.push(ddb_arr, ddb1)
        array.push(ddp_arr, ddp1)
        array.push(tid_arr, tid1)
        array.push(ui_arr, ui1)
        array.push(mr_arr, _safe(mr1))
    if i_en2 and str.length(i_t2) > 0
        array.push(syms, i_t2)
        array.push(tr_arr, tr2)
        array.push(ar_arr, ar2)
        array.push(ddb_arr, ddb2)
        array.push(ddp_arr, ddp2)
        array.push(tid_arr, tid2)
        array.push(ui_arr, ui2)
        array.push(mr_arr, _safe(mr2))
    if i_en3 and str.length(i_t3) > 0
        array.push(syms, i_t3)
        array.push(tr_arr, tr3)
        array.push(ar_arr, ar3)
        array.push(ddb_arr, ddb3)
        array.push(ddp_arr, ddp3)
        array.push(tid_arr, tid3)
        array.push(ui_arr, ui3)
        array.push(mr_arr, _safe(mr3))
    if i_en4 and str.length(i_t4) > 0
        array.push(syms, i_t4)
        array.push(tr_arr, tr4)
        array.push(ar_arr, ar4)
        array.push(ddb_arr, ddb4)
        array.push(ddp_arr, ddp4)
        array.push(tid_arr, tid4)
        array.push(ui_arr, ui4)
        array.push(mr_arr, _safe(mr4))
    if i_en5 and str.length(i_t5) > 0
        array.push(syms, i_t5)
        array.push(tr_arr, tr5)
        array.push(ar_arr, ar5)
        array.push(ddb_arr, ddb5)
        array.push(ddp_arr, ddp5)
        array.push(tid_arr, tid5)
        array.push(ui_arr, ui5)
        array.push(mr_arr, _safe(mr5))
    if i_en6 and str.length(i_t6) > 0
        array.push(syms, i_t6)
        array.push(tr_arr, tr6)
        array.push(ar_arr, ar6)
        array.push(ddb_arr, ddb6)
        array.push(ddp_arr, ddp6)
        array.push(tid_arr, tid6)
        array.push(ui_arr, ui6)
        array.push(mr_arr, _safe(mr6))
    if i_en7 and str.length(i_t7) > 0
        array.push(syms, i_t7)
        array.push(tr_arr, tr7)
        array.push(ar_arr, ar7)
        array.push(ddb_arr, ddb7)
        array.push(ddp_arr, ddp7)
        array.push(tid_arr, tid7)
        array.push(ui_arr, ui7)
        array.push(mr_arr, _safe(mr7))
    if i_en8 and str.length(i_t8) > 0
        array.push(syms, i_t8)
        array.push(tr_arr, tr8)
        array.push(ar_arr, ar8)
        array.push(ddb_arr, ddb8)
        array.push(ddp_arr, ddp8)
        array.push(tid_arr, tid8)
        array.push(ui_arr, ui8)
        array.push(mr_arr, _safe(mr8))
    if i_en9 and str.length(i_t9) > 0
        array.push(syms, i_t9)
        array.push(tr_arr, tr9)
        array.push(ar_arr, ar9)
        array.push(ddb_arr, ddb9)
        array.push(ddp_arr, ddp9)
        array.push(tid_arr, tid9)
        array.push(ui_arr, ui9)
        array.push(mr_arr, _safe(mr9))
    if i_en10 and str.length(i_t10) > 0
        array.push(syms, i_t10)
        array.push(tr_arr, tr10)
        array.push(ar_arr, ar10)
        array.push(ddb_arr, ddb10)
        array.push(ddp_arr, ddp10)
        array.push(tid_arr, tid10)
        array.push(ui_arr, ui10)
        array.push(mr_arr, _safe(mr10))
    if i_en11 and str.length(i_t11) > 0
        array.push(syms, i_t11)
        array.push(tr_arr, tr11)
        array.push(ar_arr, ar11)
        array.push(ddb_arr, ddb11)
        array.push(ddp_arr, ddp11)
        array.push(tid_arr, tid11)
        array.push(ui_arr, ui11)
        array.push(mr_arr, _safe(mr11))
    if i_en12 and str.length(i_t12) > 0
        array.push(syms, i_t12)
        array.push(tr_arr, tr12)
        array.push(ar_arr, ar12)
        array.push(ddb_arr, ddb12)
        array.push(ddp_arr, ddp12)
        array.push(tid_arr, tid12)
        array.push(ui_arr, ui12)
        array.push(mr_arr, _safe(mr12))
    if i_en13 and str.length(i_t13) > 0
        array.push(syms, i_t13)
        array.push(tr_arr, tr13)
        array.push(ar_arr, ar13)
        array.push(ddb_arr, ddb13)
        array.push(ddp_arr, ddp13)
        array.push(tid_arr, tid13)
        array.push(ui_arr, ui13)
        array.push(mr_arr, _safe(mr13))
    if i_en14 and str.length(i_t14) > 0
        array.push(syms, i_t14)
        array.push(tr_arr, tr14)
        array.push(ar_arr, ar14)
        array.push(ddb_arr, ddb14)
        array.push(ddp_arr, ddp14)
        array.push(tid_arr, tid14)
        array.push(ui_arr, ui14)
        array.push(mr_arr, _safe(mr14))
    if i_en15 and str.length(i_t15) > 0
        array.push(syms, i_t15)
        array.push(tr_arr, tr15)
        array.push(ar_arr, ar15)
        array.push(ddb_arr, ddb15)
        array.push(ddp_arr, ddp15)
        array.push(tid_arr, tid15)
        array.push(ui_arr, ui15)
        array.push(mr_arr, _safe(mr15))
    if i_en16 and str.length(i_t16) > 0
        array.push(syms, i_t16)
        array.push(tr_arr, tr16)
        array.push(ar_arr, ar16)
        array.push(ddb_arr, ddb16)
        array.push(ddp_arr, ddp16)
        array.push(tid_arr, tid16)
        array.push(ui_arr, ui16)
        array.push(mr_arr, _safe(mr16))
    if i_en17 and str.length(i_t17) > 0
        array.push(syms, i_t17)
        array.push(tr_arr, tr17)
        array.push(ar_arr, ar17)
        array.push(ddb_arr, ddb17)
        array.push(ddp_arr, ddp17)
        array.push(tid_arr, tid17)
        array.push(ui_arr, ui17)
        array.push(mr_arr, _safe(mr17))
    if i_en18 and str.length(i_t18) > 0
        array.push(syms, i_t18)
        array.push(tr_arr, tr18)
        array.push(ar_arr, ar18)
        array.push(ddb_arr, ddb18)
        array.push(ddp_arr, ddp18)
        array.push(tid_arr, tid18)
        array.push(ui_arr, ui18)
        array.push(mr_arr, _safe(mr18))
    if i_en19 and str.length(i_t19) > 0
        array.push(syms, i_t19)
        array.push(tr_arr, tr19)
        array.push(ar_arr, ar19)
        array.push(ddb_arr, ddb19)
        array.push(ddp_arr, ddp19)
        array.push(tid_arr, tid19)
        array.push(ui_arr, ui19)
        array.push(mr_arr, _safe(mr19))
    if i_en20 and str.length(i_t20) > 0
        array.push(syms, i_t20)
        array.push(tr_arr, tr20)
        array.push(ar_arr, ar20)
        array.push(ddb_arr, ddb20)
        array.push(ddp_arr, ddp20)
        array.push(tid_arr, tid20)
        array.push(ui_arr, ui20)
        array.push(mr_arr, _safe(mr20))
    if i_en21 and str.length(i_t21) > 0
        array.push(syms, i_t21)
        array.push(tr_arr, tr21)
        array.push(ar_arr, ar21)
        array.push(ddb_arr, ddb21)
        array.push(ddp_arr, ddp21)
        array.push(tid_arr, tid21)
        array.push(ui_arr, ui21)
        array.push(mr_arr, _safe(mr21))
    if i_en22 and str.length(i_t22) > 0
        array.push(syms, i_t22)
        array.push(tr_arr, tr22)
        array.push(ar_arr, ar22)
        array.push(ddb_arr, ddb22)
        array.push(ddp_arr, ddp22)
        array.push(tid_arr, tid22)
        array.push(ui_arr, ui22)
        array.push(mr_arr, _safe(mr22))
    if i_en23 and str.length(i_t23) > 0
        array.push(syms, i_t23)
        array.push(tr_arr, tr23)
        array.push(ar_arr, ar23)
        array.push(ddb_arr, ddb23)
        array.push(ddp_arr, ddp23)
        array.push(tid_arr, tid23)
        array.push(ui_arr, ui23)
        array.push(mr_arr, _safe(mr23))
    if i_en24 and str.length(i_t24) > 0
        array.push(syms, i_t24)
        array.push(tr_arr, tr24)
        array.push(ar_arr, ar24)
        array.push(ddb_arr, ddb24)
        array.push(ddp_arr, ddp24)
        array.push(tid_arr, tid24)
        array.push(ui_arr, ui24)
        array.push(mr_arr, _safe(mr24))
    if i_en25 and str.length(i_t25) > 0
        array.push(syms, i_t25)
        array.push(tr_arr, tr25)
        array.push(ar_arr, ar25)
        array.push(ddb_arr, ddb25)
        array.push(ddp_arr, ddp25)
        array.push(tid_arr, tid25)
        array.push(ui_arr, ui25)
        array.push(mr_arr, _safe(mr25))

    sort_desc(syms, tr_arr, ar_arr, ddb_arr, ddp_arr, tid_arr, ui_arr, mr_arr)

    n = array.size(syms)
    // Rendering is capped at max_ticker_rows (10 in Compact Mode, 25
    // otherwise). Sorting already ran on the full set, so Compact Mode
    // always shows the top-ranked names, not an arbitrary truncation.
    n_display = math.min(n, max_ticker_rows)
    na_label = isEn ? "N/A" : "غير متاح"

    for i = 0 to n_display - 1
        row    = i + 2 + warn_row_n
        sym    = array.get(syms,    i)
        tr_v   = array.get(tr_arr,  i)
        ar_v   = array.get(ar_arr,  i)
        ddb_v  = array.get(ddb_arr, i)
        ddp_v  = array.get(ddp_arr, i)
        tid_v  = array.get(tid_arr, i)
        ui_v   = array.get(ui_arr,  i)
        mr_raw = array.get(mr_arr,  i)

        mr_disp = mr_raw <= -1e9 ? na : mr_raw

        // Text color is sign-aware, using the contrast-derived colors above
        // so it stays legible against whatever Bullish/Bearish color the
        // user has chosen.
        mr_txt = na(mr_disp) ? C_TEXT : (mr_disp < 0 ? C_CELL_TEXT_NEG : mr_disp >= i_mr_threshold ? C_CELL_TEXT_POS : C_TEXT)
        tr_txt = na(tr_v) ? C_TEXT : (tr_v >= 0 ? C_CELL_TEXT_POS : C_CELL_TEXT_NEG)
        ar_txt = na(ar_v) ? C_TEXT : (ar_v >= 0 ? C_CELL_TEXT_POS : C_CELL_TEXT_NEG)

        band = i % 2 == 0 ? C_BAND_A : C_BAND_B

        // Sign-based background tint for the sign-bearing columns only
        // (Total Ret, Ann. Ret, Martin R). Max DD % is excluded on purpose:
        // it's structurally always <= 0 by construction (a drawdown from a
        // running peak), so tinting it red would just paint every row red
        // regardless of how well or badly that ticker actually performed.
        tr_band = na(tr_v)      ? band : (tr_v >= 0      ? C_CELL_GREEN : C_CELL_RED)
        ar_band = na(ar_v)      ? band : (ar_v >= 0      ? C_CELL_GREEN : C_CELL_RED)
        mr_band = na(mr_disp) ? band : (mr_disp < 0 ? C_CELL_RED : mr_disp >= i_mr_threshold ? C_CELL_GREEN : C_MR_NEUTRAL)

        rank_label = str.tostring(i + 1)

        table.cell(leaderboard, 0, row, rank_label,
             text_color = C_TEXT, text_size = i_cell_size,
             bgcolor = C_RANK_DEF, text_halign = text.align_center)

        ticker_label = sym
        colon_pos = str.pos(sym, ":")
        if not na(colon_pos)
            ticker_label := str.substring(sym, colon_pos + 1, str.length(sym))

        table.cell(leaderboard, 1, row, ticker_label,
             text_color = C_TEXT, text_size = i_cell_size,
             bgcolor = band, text_halign = text.align_center)

        table.cell(leaderboard, 2, row,
             na(tr_v) ? na_label : str.tostring(math.round(tr_v * 100, 2)) + "%",
             text_color = tr_txt, text_size = i_cell_size,
             bgcolor = tr_band, text_halign = text.align_right)

        table.cell(leaderboard, 3, row,
             na(ar_v) ? na_label : str.tostring(math.round(ar_v * 100, 2)) + "%",
             text_color = ar_txt, text_size = i_cell_size,
             bgcolor = ar_band, text_halign = text.align_right)

        table.cell(leaderboard, 4, row,
             na(ddb_v) ? na_label : str.tostring(math.round(ddb_v, 2)),
             text_color = C_TEXT, text_size = i_cell_size,
             bgcolor = band, text_halign = text.align_right)

        table.cell(leaderboard, 5, row,
             na(ddp_v) ? na_label : str.tostring(math.round(ddp_v, 2)) + "%",
             text_color = C_TEXT, text_size = i_cell_size,
             bgcolor = band, text_halign = text.align_right)

        table.cell(leaderboard, 6, row,
             na(tid_v) ? na_label : str.tostring(math.round(tid_v, 2)) + "%",
             text_color = C_TEXT, text_size = i_cell_size,
             bgcolor = band, text_halign = text.align_right)

        table.cell(leaderboard, 7, row,
             na(ui_v) ? na_label : str.tostring(math.round(ui_v, 2)) + "%",
             text_color = C_TEXT, text_size = i_cell_size,
             bgcolor = band, text_halign = text.align_right)

        mr_str = na(mr_disp) ? na_label : str.tostring(math.round(mr_disp, 2))
        table.cell(leaderboard, 8, row, mr_str,
             text_color = mr_txt, text_size = i_cell_size,
             bgcolor = mr_band, text_halign = text.align_right)

    // Padding loop is bounded by max_ticker_rows, not a fixed 25, so Compact
    // Mode doesn't leave dead allocated rows.
    if n_display < max_ticker_rows
        for i = n_display to max_ticker_rows - 1
            row = i + 2 + warn_row_n
            for col = 0 to 8
                table.cell(leaderboard, col, row, "",
                     bgcolor = color.new(color.white, 100),
                     text_color = color.new(color.white, 100))

    // ─────────────────────────────────────────────
    // COLLAPSIBLE METRIC LEGEND — 2 rows, always size.small regardless of the
    // Table Text Size setting, so it isn't clipped off the bottom of the
    // visible chart pane at Normal size. Uses a distinct dark charcoal
    // background so it reads as its own auxiliary panel, and mirrors the
    // actual in-table headers so a reader can match legend term to column
    // directly. Sits immediately below the ticker/padding rows.
    // ─────────────────────────────────────────────
    if i_show_legend
        legend_row1 = 2 + warn_row_n + max_ticker_rows
        legend_row2 = legend_row1 + 1
        legend_bg   = isDark ? color.new(#3C3F44, 0) : color.new(#F1F5F9, 0)

        table.merge_cells(leaderboard, 0, legend_row1, 8, legend_row1)
        table.merge_cells(leaderboard, 0, legend_row2, 8, legend_row2)

        if isEn
            legend_txt_1 = "DD: drawdown, max. decline from prior peak  •  TOTAL RET: cumulative % return\nANN. RET: CAGR, reference only  •  DD (DAYS): days from peak to reach max DD"
            legend_txt_2 = "DD %: largest peak-to-trough decline percentage  •  TIME IN DD %: percentage of days below all peaks\nULCER IDX: drawdown depth & duration; lower = better  •  MARTIN R: Total Return ÷ Ulcer Index"

            table.cell(leaderboard, 0, legend_row1, legend_txt_1,
                 text_color = C_MUTED, text_size = size.small,
                 bgcolor = legend_bg, text_halign = text.align_center, width = 1.0)
            table.cell(leaderboard, 0, legend_row2, legend_txt_2,
                 text_color = C_MUTED, text_size = size.small,
                 bgcolor = legend_bg, text_halign = text.align_center, width = 1.0)
        else
            legend_txt_1_ar = "العائد الإجمالي: العائد التراكمي  •  العائد السنوي: معدل النمو السنوي المركب ، للعرض فقط\nأقصى تراجع: أقصى انخفاض من قمة سابقة  •  أقصى تراجع (أيام): الأيام منذ القمة للوصول لأكبر تراجع"
            legend_txt_2_ar = "أقصى تراجع %: أكبر نسبة انخفاض من قمة لقاع  •  فترة التراجع %: نسبة الأيام تحت جميع القمم\nمؤشر التراجع: عمق ومدة التراجع  •  نسبة مارتن: العائد الإجمالي ÷ مؤشر التراجع"
            
            table.cell(leaderboard, 0, legend_row1, legend_txt_1_ar,
                 text_color = C_MUTED, text_size = size.small,
                 bgcolor = legend_bg, text_halign = text.align_center, width = 1.0)
            table.cell(leaderboard, 0, legend_row2, legend_txt_2_ar, 
                 text_color = C_MUTED, text_size = size.small,
                 bgcolor = legend_bg, text_halign = text.align_center, width = 1.0)
````
