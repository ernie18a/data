<!-- tradingview-pine-id: PUB;50184d55809e4d1b933ca94effd2bbf2 -->
<!-- tradingviewscripts-format: 1 -->
# Triple Bottom/Top Patterns [The_lurker]

Source: https://www.tradingview.com/script/Z4I8ONNr/

## Description

╔═══════════════════════════════════════════════════════╗
                                    Triple Bottom/Top Patterns [The_lurker]
╚═══════════════════════════════════════════════════════╝

An indicator that detects Triple Bottom and Triple Top patterns and tracks every pattern from the moment its structure completes until its final resolution — with no repainting, and with symmetry limits that adapt to market volatility instead of fixed numbers.

The core idea: a pattern is not a shape you draw and abandon. It is an event with a beginning, a path, and an end — and this indicator tracks all three.

╔═══════════════════════════════════════════════════════╗
                                   ◆ WHAT SETS THIS INDICATOR APART
╚═══════════════════════════════════════════════════════╝

[image]https://www.tradingview.com/x/OiVQdPef/[/image]

▌ 1 ─ No repainting, by structure rather than by promise

✕ Common: an "in progress" mode draws an unconfirmed third leg, so the shape shifts and is redrawn every time price moves. The pattern you see in history is not what was displayed at the time.

✓ Here: all seven points are confirmed price pivots, and every state change occurs on confirmed bar close. What you see today on an old bar is literally what was displayed when it appeared.

There is no "in progress" mode in this indicator — a deliberate choice, not a missing feature.

▌ 2 ─ Symmetry limits that adapt to volatility

✕ Common: a fixed percentage for the allowed difference between the ends.

The problem is that one percentage means radically different things:

   ▸ 1% on the 15-minute chart ≈ 3.6 volatility units  ← far too loose
   ▸ 1% on the daily chart      ≈ 0.26 volatility units ← far too strict

The same number delivers completely different precision depending on timeframe, while the user believes a single standard has been set.

✓ Here: the difference is measured in units of Average True Range at the moment of formation.

One number means the same thing on every timeframe, every instrument, and every market condition — from Bitcoin to low-priced altcoins, from the 1-minute to the weekly.

▌ 3 ─ A complete eight-state machine

✕ Common: the pattern is drawn, the breakout is announced, and its role ends.

✓ Here: every pattern travels a defined and declared path:

   ⏳ Awaiting breakout
   ✓ Pattern complete
   🎯 Target reached
   ✕ Pattern failed
   🔄 Reverse target reached
   ⌛ Waiting period expired
   ⌛ Complete, no target reached
   ⌛ Failed, no reverse target reached

▌ 4 ─ The two states you will not find elsewhere

✕ Common: the target line extends indefinitely. A pattern that broke out a year ago still has its line crawling across your chart today, with no answer to the question: was it reached or not?

✓ Here: every pattern has a defined time window to reach its target. If the window closes without a hit, the state is declared "Complete, no target" and the line freezes.

This prevents dead lines from accumulating, and gives an explicit answer instead of open silence.

[image]https://www.tradingview.com/x/7EeVDX4I/[/image]

▌ 5 ─ No resolution within the event bar itself

✕ Common: a pattern breaks out and the target is counted as reached in that same bar if price touched it.

The problem: the order of high, low, and close inside a single bar is unknown to any indicator. Price may have reached the target before closing above the neckline — that is, before the entry signal existed at all.

✓ Here: resolution is deferred by a full bar. A target can never be reached on the completion bar itself.

A small detail that separates honest tracking from optimistic tracking.

▌ 6 ─ Every point is a pivot, including the turning point and both mids

✕ Common: the intermediate points and the trend origin are taken as the raw highest or lowest value within a window.

The problem: a single stray wick can become a point in the pattern — and if it defines the neckline, the entire decisive level rests on noise.

✓ Here: all seven points are confirmed pivots. One wick cannot define a neckline.

▌ 7 ─ Tracking continues after failure

✕ Common: the pattern breaks down and is erased from the chart.

✓ Here: it breaks down and is fully recoloured — lines, fill, and labels — and a reverse target is computed and tracked with the same precision and the same time window.

Pattern failure is tradeable information, not the end of tracking.

[image]https://www.tradingview.com/x/msqfCKRL/[/image]

▌ 8 ─ One pattern per zone

✕ Common: several overlapping patterns draw on top of one another, turning the chart into a tangled mesh.

✓ Here: when patterns overlap in time, only the one with the tightest symmetry remains. And a pattern that has completed or failed is never erased retroactively — it blocks a newcomer instead of being replaced by it.

The result: a clean chart, and a history that is not rewritten.

▌ 9 ─ Prior trend gate

A reversal pattern without a prior trend is not a reversal.

✓ The indicator requires the leg from the turning point to the first end to reach a defined multiple of the pattern's own height — and this requirement is what determines which pivot is selected as the turning point, so no arbitrary peak preceding the pattern gets picked up.

╔═══════════════════════════════════════════════════════╗
                                     📐 PATTERN STRUCTURE: SEVEN POINTS
╚═══════════════════════════════════════════════════════╝

   ① Turning point ─ the last opposite pivot before the first end, where the prior trend reversed

   ②④⑥ The three ends ─ B1 · B2 · B3  or  T1 · T2 · T3
        confirmed pivots, aligned within a limit measured in volatility units

   ③⑤ The two mids ─ the separating highs in a Triple Bottom, or the separating lows in a Triple Top

   ▬▬ Neckline ─ the higher of the two mids in a Triple Bottom, the lower in a Triple Top
        this is the level that defines pattern completion

   ⑦ Crossing point ─ where the final leg intersects the neckline on completion

Path: ① → ② → ③ → ④ → ⑤ → ⑥ → ⑦

[image]https://www.tradingview.com/x/c1NyW84S/[/image]

[image]https://www.tradingview.com/x/OiVQdPef/[/image]

╔═══════════════════════════════════════════════════════╗
                                                          🎯 TARGETS
╚═══════════════════════════════════════════════════════╝

The target is purely geometric: the pattern height — the distance between the neckline and the furthest end — projected from the breakout point.

   ▸ Conservative   0.618 of pattern height
   ▸ Balanced       full pattern height
   ▸ Aggressive     1.618 of pattern height

An independent mode for each case: Bottom bullish target · Bottom bearish target on failure · Top bearish target · Top bullish target on failure.

The fill criterion is selectable:
   ▸ Touch ─ matches a limit order resting at the target
   ▸ Close ─ more conservative

╔═══════════════════════════════════════════════════════╗
                                                            ⚙️ SETTINGS
╚═══════════════════════════════════════════════════════╝

▌ Pattern Detection

   ▸ Pivots left and right ─ pivot confirmation sensitivity
   ▸ Min arm length ─ minimum bars between each consecutive pair of points
   ▸ Ends symmetry ×ATR ─ the single most influential parameter
   ▸ Mids symmetry ×ATR ─ same unit, applied to the two intermediate points
   ▸ Min depth ×ATR ─ excludes shallow sideways chop
   ▸ Prior leg ×Pattern height ─ required strength of the preceding trend
   ▸ Trend length and lookback ─ search range for the turning point
   ▸ Extension multiplier ─ breakout waiting period, relative to pattern width

▌ Targets

   ▸ Target window ×Width ─ time allowed to reach the target. Zero = no expiry

▌ Visual

   ▸ Max live patterns per side ─ raise it on lower timeframes
   ▸ Independent colours per side: pattern · fill · text · label background
     Transparency is set from the colour picker itself

╔═══════════════════════════════════════════════════════╗
                                                          🔔 ALERT
╚═══════════════════════════════════════════════════════╝

A single alert: Triple Pattern Complete.

   ▸ Fires when the neckline is broken on confirmed bar close
   ▸ Covers both bottoms and tops
   ▸ Once per pattern
   ▸ The message includes ticker, timeframe, and close price automatically

To create: alarm icon → select the indicator as source → choose the condition → set frequency to "Once Per Bar Close".

⚠ TradingView freezes the indicator settings at the moment the alert is created. If you change any setting afterwards, delete the alert and create it again.

╔═══════════════════════════════════════════════════════╗
                                                      📊 PRACTICAL USE
╚═══════════════════════════════════════════════════════╝

   ▸ The neckline is the decisive level. Before it is broken: a candidate structure. After: a completed event.

   ▸ The furthest end defines the invalidation point — a close below the lowest of the three bottoms, or above the highest of the three tops.

   ▸ The info table shows, for each side: target mode · target price · current state · pattern age in bars.

   ▸ The age field matters: a pattern fifty bars old is not the same as one five hundred bars old.

   ▸ Triple patterns are inherently rarer than double ones. If nothing appears on a higher timeframe, that is expected behaviour rather than a fault — raise the ends symmetry limit first, then review the prior trend gate.

╔═══════════════════════════════════════════════════════╗
                                                 ⚠ DISCLOSURE AND LIMITATIONS
╚═══════════════════════════════════════════════════════╝

   ▸ This indicator is a visual analysis tool that organises how you read the market. It does not provide buy or sell recommendations, and it promises no results.

   ▸ Drawing correctness is one thing; pattern performance is another. The indicator draws patterns and tracks their events precisely, but the predictive ability of the pattern itself has not been tested statistically here and is not claimed.

   ▸ The search scope is limited to the last fifty pivots per side, so a very old pattern may not be detected.

   ▸ When the tracked-pattern budget fills, a live pattern may be replaced by a newer one. Raising "Max live patterns" reduces this.

   ▸ Use it within a complete trading approach that includes risk management, not as a sole source of decisions.

╔═══════════════════════════════════════════════════════╗
                               Triple Bottom/Top Patterns    نماذج القيعان والقمم الثلاثية
╚═══════════════════════════════════════════════════════╝

مؤشر يكتشف نماذج القاع الثلاثي والقمة الثلاثية، ويتابع كل نموذج من لحظة اكتمال بنيته حتى حسمه النهائي — بلا إعادة رسم، وبحدود تماثل تتكيف مع تقلب السوق بدل أرقام ثابتة.

الفكرة المركزية: النموذج ليس شكلًا يُرسم ثم يُترك. هو حدث له بداية ومسار ونهاية، والمؤشر يتتبع الثلاثة.

         ╔═══════════════════════════════════════════════════════╗
                                                 ◆ ما الذي يميز هذا المؤشر
         ╚═══════════════════════════════════════════════════════╝

[image]https://www.tradingview.com/x/OiVQdPef/[/image]

▌ ١ ─ لا إعادة رسم، بضمانة بنيوية لا بوعد نصي

✕ الشائع: وضع "قيد التكوين" يرسم طرفًا ثالثًا غير مؤكد، فيتحرك الشكل ويُعاد رسمه كلما تحرك السعر. النموذج الذي تراه في التاريخ ليس ما كان معروضًا لحظتها.

✓ هنا: النقاط السبع كلها محاور سعرية مؤكدة، وكل تغييرات الحالة تقع تحت إغلاق الشمعة المؤكد. ما تراه اليوم على شمعة قديمة هو حرفيًا ما كان معروضًا وقت ظهوره.

لا يوجد وضع "قيد التكوين" في هذا المؤشر — وهذا اختيار مقصود، لا نقص.

▌ ٢ ─ حدود التماثل تتكيف مع التقلب

✕ الشائع: نسبة مئوية ثابتة للفارق المسموح بين الأطراف.

المشكلة أن النسبة الواحدة تعني أشياء مختلفة جذريًا:

   ▸ 1٪ على فريم 15 دقيقة ≈ 3.6 من وحدات التقلب  ← متساهل جدًا
   ▸ 1٪ على الفريم اليومي  ≈ 0.26 من وحدات التقلب ← صارم جدًا

أي أن نفس الرقم يعطي دقة مختلفة تمامًا حسب الفريم، والمستخدم يظن أنه ثبّت معيارًا واحدًا.

✓ هنا: الفارق يُقاس بوحدات المدى الحقيقي المتوسط عند لحظة التكوين.

الرقم الواحد يعني الشيء نفسه على كل فريم، وكل أصل، وكل حالة سوق — من البيتكوين إلى العملات منخفضة السعر، ومن الدقيقة إلى الأسبوعي.

▌ ٣ ─ آلة حالة كاملة من ثماني حالات

✕ الشائع: يرسم النموذج، يعلن الاختراق، وينتهي دوره.

✓ هنا: كل نموذج يمر بمسار محدد ومعلن:

   ⏳ انتظار الاختراق
   ✓ اكتمال النموذج
   🎯 بلوغ الهدف
   ✕ فشل النموذج
   🔄 بلوغ الهدف العكسي
   ⌛ انتهاء مدة الانتظار
   ⌛ اكتمال بلا بلوغ هدف
   ⌛ فشل بلا بلوغ هدف عكسي

▌ ٤ ─ الحالتان اللتان لا تجدهما في غيره

✕ الشائع: خط الهدف يمتد إلى ما لا نهاية. نموذج اخترق قبل سنة وما زال خطه يزحف على شارتك اليوم، بلا إجابة عن سؤال: هل وصل أم لا؟

✓ هنا: لكل نموذج نافذة زمنية محددة لبلوغ هدفه. إن انقضت بلا وصول، تُعلن الحالة "اكتمال بلا بلوغ هدف" ويتجمد الخط.

هذا يمنع تراكم خطوط ميتة، ويعطي إجابة صريحة بدل صمت مفتوح.

[image]https://www.tradingview.com/x/7EeVDX4I/[/image]

▌ ٥ ─ لا حسم في شمعة الحدث نفسها

✕ الشائع: النموذج يخترق ويُحسب الهدف متحققًا في نفس الشمعة إن لامسه السعر.

المشكلة: ترتيب الأعلى والأدنى والإغلاق داخل الشمعة الواحدة غير معلوم لأي مؤشر. ربما بلغ السعر الهدف قبل أن يغلق فوق العنق، أي قبل وجود إشارة الدخول أصلًا.

✓ هنا: الحسم يُؤجَّل شمعة كاملة. لا يمكن أن يتحقق هدف في شمعة الاكتمال نفسها.

تفصيل صغير يفصل بين متابعة صادقة وأخرى متفائلة.

▌ ٦ ─ كل النقاط محاور، بما فيها نقطة التحول والوسيطتان

✕ الشائع: النقاط الوسيطة ونقطة بداية الاتجاه تُؤخذ كأعلى أو أدنى قيمة خام في نافذة.

المشكلة: ذيل شمعة شارد قد يصبح نقطة في النموذج — وإن كان هو خط العنق، فالمستوى الحاسم كله مبني على ضجيج.

✓ هنا: النقاط السبع محاور مؤكدة. ذيل واحد لا يمكن أن يحدد خط عنق.

▌ ٧ ─ متابعة ما بعد الفشل

✕ الشائع: النموذج ينكسر فيُشطب من الشارت.

✓ هنا: ينكسر فيُعاد تلوينه بالكامل — الخطوط والتضليل والعلامات — ويُحسب له هدف عكسي يُتابع بنفس الدقة والنافذة الزمنية.

فشل النموذج معلومة تداولية، لا نهاية المتابعة.

[image]https://www.tradingview.com/x/msqfCKRL/[/image]

▌ ٨ ─ نموذج واحد لكل منطقة

✕ الشائع: عدة نماذج متداخلة ترسم فوق بعضها فيتحول الشارت إلى شبكة متشابكة.

✓ هنا: عند تداخل زمني، يبقى الأدقّ تماثلًا فقط. والنموذج الذي اكتمل أو فشل لا يُمحى بأثر رجعي — يمنع ظهور نموذج جديد فوقه بدل أن يُستبدل به.

النتيجة: شارت نظيف، وتاريخ لا يُزوَّر.

▌ ٩ ─ بوابة الاتجاه السابق

النموذج الانعكاسي بلا اتجاه سابق ليس انعكاسًا.

✓ المؤشر يشترط أن يبلغ المسار من نقطة التحول إلى الطرف الأول مضاعفًا محددًا من ارتفاع النموذج نفسه — وهذا الشرط هو ما يحدد أي محور يُختار كنقطة تحول، فلا تُلتقط قمة عشوائية سبقت النموذج.

        ╔═══════════════════════════════════════════════════════╗
                                                  📐 بنية النموذج: سبع نقاط
        ╚═══════════════════════════════════════════════════════╝

   ① نقطة التحول ─ آخر محور مقابل قبل الطرف الأول، حيث انقلب الاتجاه السابق

   ②④⑥ الأطراف الثلاثة ─ B1 · B2 · B3  أو  T1 · T2 · T3
        محاور مؤكدة، متقاربة ضمن حد يُقاس بوحدات التقلب

   ③⑤ الوسيطتان ─ القمتان الفاصلتان في القاع الثلاثي، أو القاعان في القمة الثلاثية

   ▬▬ خط العنق ─ أعلى الوسيطتين في القاع الثلاثي، وأدناهما في القمة الثلاثية
        هو المستوى الذي يحدد اكتمال النموذج

   ⑦ نقطة العبور ─ تقاطع الساق الأخيرة مع خط العنق عند الاكتمال

المسار: ① → ② → ③ → ④ → ⑤ → ⑥ → ⑦

[image]https://www.tradingview.com/x/c1NyW84S/[/image]

[image]https://www.tradingview.com/x/OiVQdPef/[/image]

         ╔═══════════════════════════════════════════════════════╗
                                                            🎯 الأهداف
         ╚═══════════════════════════════════════════════════════╝

الهدف هندسي بحت: ارتفاع النموذج — المسافة بين خط العنق وأبعد الأطراف — يُسقط من نقطة الاختراق.

   ▸ محافظ   0.618 من ارتفاع النموذج
   ▸ متوازن   ارتفاع النموذج كاملًا
   ▸ عدواني   1.618 من ارتفاع النموذج

نمط مستقل لكل حالة: هدف القاع الصاعد · هدف القاع الهابط عند الفشل · هدف القمة الهابط · هدف القمة الصاعد عند الفشل.

معيار التحقق قابل للاختيار:
   ▸ لمسة السعر ─ يطابق تنفيذ أمر معلق عند الهدف
   ▸ إغلاق الشمعة ─ أكثر تحفظًا

        ╔═══════════════════════════════════════════════════════╗
                                                             ⚙️ الإعدادات
        ╚═══════════════════════════════════════════════════════╝

▌ كشف النموذج

   ▸ شموع اليسار واليمين ─ حساسية تأكيد المحاور
   ▸ الحد الأدنى للذراع ─ أقل عدد شموع بين كل نقطتين متتاليتين
   ▸ تماثل الأطراف الثلاثة ×ATR ─ المعامل الأهم في المؤشر
   ▸ تماثل الوسيطين ×ATR ─ نفس الوحدة، للنقطتين الوسيطتين
   ▸ أدنى عمق للنموذج ×ATR ─ يستبعد التذبذبات الجانبية الضحلة
   ▸ ارتفاع الاتجاه ×ارتفاع النموذج ─ قوة المسار السابق المطلوبة
   ▸ طول المسار ومدى البحث ─ نطاق البحث عن نقطة التحول
   ▸ معامل التمدد ─ مدة انتظار الاختراق بدلالة عرض النموذج

▌ الأهداف

   ▸ نافذة الهدف ×العرض ─ المدة المسموحة لبلوغ الهدف. صفر = بلا انتهاء

▌ العرض

   ▸ أقصى نماذج متتبعة لكل جانب ─ ارفعه على الفريمات المنخفضة
   ▸ ألوان مستقلة لكل جانب: النموذج · التضليل · النص · خلفية العلامة
     الشفافية تُضبط من منتقي اللون نفسه

         ╔═══════════════════════════════════════════════════════╗
                                                  🔔 التنبيه
         ╚═══════════════════════════════════════════════════════╝

تنبيه واحد فقط: اكتمال النموذج الثلاثي.

   ▸ يُطلق عند كسر خط العنق بإغلاق شمعة مؤكد
   ▸ للقاع والقمة معًا
   ▸ مرة واحدة لكل نموذج
   ▸ الرسالة تتضمن الرمز والفريم وسعر الإغلاق تلقائيًا

الإنشاء: أيقونة المنبه → المؤشر كمصدر → الشرط → التكرار "مرة عند إغلاق الشمعة".

⚠ TradingView يحفظ إعدادات المؤشر لحظة إنشاء التنبيه. إن غيّرت أي إعداد بعدها، احذف التنبيه وأنشئه من جديد.

         ╔═══════════════════════════════════════════════════════╗
                                       📊 الاستخدام العملي
         ╚═══════════════════════════════════════════════════════╝

   ▸ خط العنق هو المستوى الحاسم. قبل اختراقه: بنية محتملة. بعده: حدث مكتمل.

   ▸ الطرف الأبعد يحدد نقطة إبطال النموذج — إغلاق تحت أدنى القيعان الثلاثة، أو فوق أعلى القمم الثلاث.

   ▸ جدول المعلومات يعرض لكل جانب: نمط الهدف · سعر الهدف · الحالة الراهنة · عمر النموذج بالشموع.

   ▸ حقل العمر مهم: نموذج عمره خمسون شمعة ليس كنموذج عمره خمسمئة.

   ▸ النماذج الثلاثية أندر بطبيعتها من الثنائية. إن لم يظهر شيء على فريم مرتفع فهذا سلوك متوقع لا خلل — ارفع حد تماثل الأطراف أولًا، ثم راجع بوابة ارتفاع الاتجاه.

         ╔═══════════════════════════════════════════════════════╗
                                                 ⚠ الإفصاح والقيود
         ╚═══════════════════════════════════════════════════════╝

   ▸ هذا المؤشر أداة تحليل بصري وتنظيم لرؤية السوق. لا يقدم توصيات شراء أو بيع، ولا يَعِد بنتائج.

   ▸ صحة الرسم شيء وأداء النموذج شيء آخر. المؤشر يرسم النماذج ويتتبع أحداثها بدقة، لكن قدرة النموذج نفسه على التنبؤ لم تُختبر إحصائيًا هنا ولا يُدعى بها.

   ▸ نطاق البحث محدود بآخر خمسين محورًا لكل جانب، فقد لا يُكتشف نموذج قديم جدًا.

   ▸ عند امتلاء ميزانية النماذج المتتبعة، قد يُستبدل نموذج حي بآخر أحدث. رفع "أقصى نماذج متتبعة" يقلل ذلك.

   ▸ استخدمه ضمن منهج تداول متكامل يشمل إدارة المخاطر، لا كمصدر قرار وحيد.

                          ─────────────────────────────────────────────
                                                    The_lurker — Fawaz Al-Enezi | فواز العنزي
                          ─────────────────────────────────────────────

---

## Source Code

````pine
//@version=6
// Triple Bottom/Top Patterns  |  نماذج القيعان والقمم الثلاثية
// The_lurker — Fawaz Al-Enezi | فواز العنزي

indicator("Triple Bottom/Top Patterns [The_lurker]", shorttitle="Triple B/T [The_lurker]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=2000)

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 0: Constants | القسم صفر: الثوابت
// ═══════════════════════════════════════════════════════════════════

int MAXBACK = 2000
int EV_BRK = 0

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 1: Types | القسم الأول: الأنواع
// ═══════════════════════════════════════════════════════════════════

type PatternPoint
    int idx
    float price

type PatternData
    PatternPoint p1
    PatternPoint p2
    PatternPoint p3
    PatternPoint p4
    PatternPoint p5
    PatternPoint p6
    float neck
    float match_atr
    color pattern_color
    int pattern_width
    int max_wait_bars
    int detect_bar
    int state
    bool isBottom
    int breakout_bar
    float target_price
    bool t_touched = false
    bool t_closed = false
    int t_touch_bar
    int t_close_bar
    int reverse_bar
    float reverse_target
    bool r_touched = false
    bool r_closed = false
    int r_touch_bar
    int r_close_bar

type PatternVisuals
    line neckline_left
    line neckline_right
    line l12
    line l23
    line l34
    line l45
    line l56
    line l67
    line roof_12
    line roof_23
    line roof_34
    line roof_45
    line roof_56
    line roof_67
    linefill fill_12
    linefill fill_23
    linefill fill_34
    linefill fill_45
    linefill fill_56
    linefill fill_67
    label lbl1
    label lbl2
    label lbl3
    label lbl4
    label lbl5
    label lbl6
    label lbl7
    label lblX
    line target_vline
    line target_hline
    label target_label
    line reverse_vline
    line reverse_hline
    label reverse_label

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 2: Inputs | القسم الثاني: الإدخالات
// ═══════════════════════════════════════════════════════════════════

string G1 = "═══════ General Settings | الإعدادات العامة ═══════"
i_language = input.string("English | إنجليزي", "Language | اللغة", options=["عربي | Arabic", "English | إنجليزي"], group=G1)
i_max_pat = input.int(3, "Max Live Patterns / Side | أقصى نماذج متتبعة لكل جانب", minval=1, maxval=10, group=G1)

string G2 = "═══════ Pattern Selection | اختيار النماذج ═══════"
i_enable_bot = input.bool(true, "Enable Triple Bottom | تفعيل القاع الثلاثي", group=G2)
i_enable_top = input.bool(true, "Enable Triple Top | تفعيل القمة الثلاثية", group=G2)

string G3 = "═══════ Pattern Detection | كشف النموذج ═══════"
i_left = input.int(5, "Pivots Left | شموع اليسار", minval=1, maxval=20, group=G3)
i_right = input.int(3, "Pivots Right | شموع اليمين", minval=1, maxval=20, group=G3)
i_min_arm = input.int(8, "Min Arm Length | الحد الأدنى للذراع", minval=3, maxval=50, group=G3)
i_tol_ends = input.float(0.6, "Ends Symmetry ×ATR | تماثل الأطراف الثلاثة ×ATR", minval=0.1, maxval=4.0, step=0.1, group=G3)
i_tol_mids = input.float(0.5, "Mids Symmetry ×ATR | تماثل الوسيطين ×ATR", minval=0.1, maxval=4.0, step=0.1, group=G3)
i_min_depth = input.float(1.0, "Min Depth ×ATR | أدنى عمق للنموذج ×ATR", minval=0.0, maxval=10.0, step=0.5, group=G3)
i_trend_h = input.float(1.5, "Prior Leg ×Pattern Height | ارتفاع الاتجاه ×ارتفاع النموذج", minval=0.0, maxval=6.0, step=0.1, group=G3)
i_min_trend = input.int(10, "Min Trend Length | طول المسار", minval=5, maxval=50, group=G3)
i_trend_look = input.int(60, "Trend Lookback | مدى البحث عن المسار", minval=20, maxval=200, group=G3)
i_ext_mult = input.float(1.5, "Extension Multiplier | معامل التمدد", minval=0.5, maxval=5.0, step=0.5, group=G3)

string G6 = "═══════ Targets | الأهداف ═══════"
i_bot_bull = input.string("متوازن | Balanced", "Bottom Bullish Target | هدف القاع الصاعد", options=["محافظ | Conservative", "متوازن | Balanced", "عدواني | Aggressive"], group=G6)
i_bot_bear = input.string("محافظ | Conservative", "Bottom Bearish Target | هدف القاع الهابط", options=["محافظ | Conservative", "متوازن | Balanced", "عدواني | Aggressive"], group=G6)
i_top_bear = input.string("متوازن | Balanced", "Top Bearish Target | هدف القمة الهابط", options=["محافظ | Conservative", "متوازن | Balanced", "عدواني | Aggressive"], group=G6)
i_top_bull = input.string("محافظ | Conservative", "Top Bullish Target | هدف القمة الصاعد", options=["محافظ | Conservative", "متوازن | Balanced", "عدواني | Aggressive"], group=G6)
i_tgt_wait = input.float(3.0, "Target Window ×Width | نافذة الهدف ×العرض", minval=0.0, maxval=20.0, step=0.5, group=G6)
i_tgt_mode = input.string("لمسة | Touch", "Target Fill | معيار تحقق الهدف", options=["لمسة | Touch", "إغلاق | Close"], group=G6)

string G7 = "═══════ Visual Settings | إعدادات العرض ═══════"
i_lbl_size = input.string("صغير | Small", "Label Size | حجم العلامات", options=["صغير | Small", "عادي | Normal", "كبير | Large", "ضخم | Huge"], group=G7)
i_tbl_size = input.string("عادي | Normal", "Table Size | حجم الجدول", options=["صغير | Small", "عادي | Normal", "كبير | Large"], group=G7)
i_tbl_pos = input.string("أعلى يمين | Top Right", "Table Position | موضع الجدول", options=["أعلى يمين | Top Right", "أعلى يسار | Top Left", "أسفل يمين | Bottom Right", "أسفل يسار | Bottom Left"], group=G7)

string G8 = "═══════ Triple Bottom Colors | ألوان القاع الثلاثي ═══════"
i_bot_txt = input.color(color.new(#2962FF, 0), "Text Color | لون النص", group=G8)
i_bot_bg = input.color(color.new(#FFC107, 80), "Label Background | خلفية العلامة", group=G8)
i_bot_col = input.color(color.new(#00BCD4, 0), "Pattern Color | لون النموذج", group=G8)
i_bot_fill = input.color(color.new(#00BCD4, 88), "Fill Color | لون التضليل", group=G8)

string G9 = "═══════ Triple Top Colors | ألوان القمة الثلاثية ═══════"
i_top_txt = input.color(color.new(#FF1744, 0), "Text Color | لون النص", group=G9)
i_top_bg = input.color(color.new(#FF1744, 80), "Label Background | خلفية العلامة", group=G9)
i_top_col = input.color(color.new(#FF5252, 0), "Pattern Color | لون النموذج", group=G9)
i_top_fill = input.color(color.new(#FF5252, 88), "Fill Color | لون التضليل", group=G9)

string G10 = "═══════ Status Colors | ألوان الحالات ═══════"
i_achieved = input.color(color.new(#4CAF50, 0), "Target Achieved | تحقق الهدف", group=G10)
i_bear_rev = input.color(color.new(#FF1744, 0), "Bearish Reversal | انعكاس هبوطي", group=G10)
i_bull_rev = input.color(color.new(#00BCD4, 0), "Bullish Reversal | انعكاس صعودي", group=G10)

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 3: Translation | القسم الثالث: الترجمة
// ═══════════════════════════════════════════════════════════════════

var map<string, string> TXT_AR = map.new<string, string>()
var map<string, string> TXT_EN = map.new<string, string>()

if barstate.isfirst
    TXT_AR.put("triple_bottom", "قاع ثلاثي")
    TXT_AR.put("triple_top", "قمة ثلاثية")
    TXT_AR.put("target_mode", "نمط الهدف")
    TXT_AR.put("target_price", "سعر الهدف")
    TXT_AR.put("status", "الحالة")
    TXT_AR.put("age", "العمر (شمعة)")
    TXT_AR.put("reversal_down", "انعكاس هبوطي")
    TXT_AR.put("reversal_up", "انعكاس صاعد")
    TXT_AR.put("bull_break", "اختراق صاعد")
    TXT_AR.put("bear_break", "كسر هابط")
    TXT_AR.put("waiting", "انتظار الاختراق")
    TXT_AR.put("expired", "انتهت الصلاحية")
    TXT_AR.put("tgt_hit", "✓ تحقق الهدف")
    TXT_AR.put("rev_hit", "✓ تحقق العكسي")
    TXT_AR.put("brk_exp", "⌛ اختراق بلا هدف")
    TXT_AR.put("rev_exp", "⌛ فشل بلا هدف")
    TXT_AR.put("bottom1", "B1")
    TXT_AR.put("bottom2", "B2")
    TXT_AR.put("bottom3", "B3")
    TXT_AR.put("top1", "T1")
    TXT_AR.put("top2", "T2")
    TXT_AR.put("top3", "T3")
    TXT_AR.put("conservative", "محافظ")
    TXT_AR.put("balanced", "متوازن")
    TXT_AR.put("aggressive", "عدواني")
    TXT_EN.put("triple_bottom", "Triple Bottom")
    TXT_EN.put("triple_top", "Triple Top")
    TXT_EN.put("target_mode", "Target Mode")
    TXT_EN.put("target_price", "Target Price")
    TXT_EN.put("status", "Status")
    TXT_EN.put("age", "Age (bars)")
    TXT_EN.put("reversal_down", "Reversal Downward")
    TXT_EN.put("reversal_up", "Reversal Upward")
    TXT_EN.put("bull_break", "Bullish Breakout")
    TXT_EN.put("bear_break", "Bearish Breakout")
    TXT_EN.put("waiting", "Awaiting Break")
    TXT_EN.put("expired", "Expired")
    TXT_EN.put("tgt_hit", "✓ Target Hit")
    TXT_EN.put("rev_hit", "✓ Reverse Hit")
    TXT_EN.put("brk_exp", "⌛ Break, No Target")
    TXT_EN.put("rev_exp", "⌛ Fail, No Target")
    TXT_EN.put("bottom1", "B1")
    TXT_EN.put("bottom2", "B2")
    TXT_EN.put("bottom3", "B3")
    TXT_EN.put("top1", "T1")
    TXT_EN.put("top2", "T2")
    TXT_EN.put("top3", "T3")
    TXT_EN.put("conservative", "Conservative")
    TXT_EN.put("balanced", "Balanced")
    TXT_EN.put("aggressive", "Aggressive")

txt(string key) =>
    (i_language == "عربي | Arabic") ? TXT_AR.get(key) : TXT_EN.get(key)

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 4: Helpers | القسم الرابع: الدوال المساعدة
// ═══════════════════════════════════════════════════════════════════

get_lbl_size() =>
    switch i_lbl_size
        "صغير | Small" => size.small
        "عادي | Normal" => size.normal
        "كبير | Large" => size.large
        => size.huge

get_tbl_pos() =>
    switch i_tbl_pos
        "أعلى يمين | Top Right" => position.top_right
        "أعلى يسار | Top Left" => position.top_left
        "أسفل يمين | Bottom Right" => position.bottom_right
        => position.bottom_left

get_txt_size() =>
    switch i_tbl_size
        "صغير | Small" => size.tiny
        "عادي | Normal" => size.small
        => size.normal

mode_txt(string mode) =>
    (mode == "محافظ | Conservative") ? txt("conservative") : (mode == "متوازن | Balanced") ? txt("balanced") : txt("aggressive")

mult_of(string mode) =>
    (mode == "محافظ | Conservative") ? 0.618 : (mode == "متوازن | Balanced") ? 1.0 : 1.618

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 5: Series | القسم الخامس: السلاسل
// ═══════════════════════════════════════════════════════════════════

atr_val = ta.atr(14)
plv = ta.pivotlow(low, i_left, i_right)
phv = ta.pivothigh(high, i_left, i_right)
bool tgt_touch = i_tgt_mode == "لمسة | Touch"

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 6: Object Methods | القسم السادس: دوال الكائنات
// ═══════════════════════════════════════════════════════════════════

method clear(PatternVisuals v) =>
    if not na(v)
        line.delete(v.neckline_left)
        line.delete(v.neckline_right)
        line.delete(v.l12)
        line.delete(v.l23)
        line.delete(v.l34)
        line.delete(v.l45)
        line.delete(v.l56)
        line.delete(v.l67)
        line.delete(v.roof_12)
        line.delete(v.roof_23)
        line.delete(v.roof_34)
        line.delete(v.roof_45)
        line.delete(v.roof_56)
        line.delete(v.roof_67)
        linefill.delete(v.fill_12)
        linefill.delete(v.fill_23)
        linefill.delete(v.fill_34)
        linefill.delete(v.fill_45)
        linefill.delete(v.fill_56)
        linefill.delete(v.fill_67)
        label.delete(v.lbl1)
        label.delete(v.lbl2)
        label.delete(v.lbl3)
        label.delete(v.lbl4)
        label.delete(v.lbl5)
        label.delete(v.lbl6)
        label.delete(v.lbl7)
        label.delete(v.lblX)
        line.delete(v.target_vline)
        line.delete(v.target_hline)
        label.delete(v.target_label)
        line.delete(v.reverse_vline)
        line.delete(v.reverse_hline)
        label.delete(v.reverse_label)

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 7: Detection | القسم السابع: الكشف
// ═══════════════════════════════════════════════════════════════════

scan_side(bool active, bool isB, float[] pvs, int[] idxs, float[] opv, int[] opi) =>
    bool found = false
    float bestMatch = na
    PatternData best = na
    if active and array.size(pvs) >= 3
        int p6_idx = bar_index - i_right
        int psz = array.size(pvs)
        float p6_p = array.get(pvs, psz - 1)
        float atrRef = atr_val[i_right]
        if not na(atrRef) and atrRef > 0
            float tolE = i_tol_ends * atrRef
            float tolM = i_tol_mids * atrRef
            for i4 = psz - 2 to 1
                float p4_p = array.get(pvs, i4)
                int p4_idx = array.get(idxs, i4)
                if p6_idx - p4_idx < i_min_arm * 2
                    continue
                if math.abs(p6_p - p4_p) > tolE
                    continue
                for i2 = i4 - 1 to 0
                    float p2_p = array.get(pvs, i2)
                    int p2_idx = array.get(idxs, i2)
                    if p4_idx - p2_idx < i_min_arm * 2
                        continue
                    if math.abs(p6_p - p2_p) > tolE or math.abs(p4_p - p2_p) > tolE
                        continue
                    if bar_index - p2_idx + i_trend_look + 1 > MAXBACK
                        continue
                    float hi3 = math.max(math.max(p2_p, p4_p), p6_p)
                    float lo3 = math.min(math.min(p2_p, p4_p), p6_p)
                    if hi3 - lo3 > tolE
                        continue
                    float extv = isB ? lo3 : hi3
                    float m1 = na
                    int m1_idx = -1
                    float m2 = na
                    int m2_idx = -1
                    int osz2 = array.size(opv)
                    if osz2 > 0
                        for q = 0 to osz2 - 1
                            int qi = array.get(opi, q)
                            float qp = array.get(opv, q)
                            if qi > p2_idx and qi < p4_idx
                                if na(m1) or (isB ? qp > m1 : qp < m1)
                                    m1 := qp
                                    m1_idx := qi
                            else if qi > p4_idx and qi < p6_idx
                                if na(m2) or (isB ? qp > m2 : qp < m2)
                                    m2 := qp
                                    m2_idx := qi
                    if na(m1) or na(m2)
                        continue
                    if math.abs(m1 - m2) > tolM
                        continue
                    bool midsOK = isB ? (m1 > hi3 and m2 > hi3) : (m1 < lo3 and m2 < lo3)
                    if not midsOK
                        continue
                    if m1_idx - p2_idx < i_min_arm or p4_idx - m1_idx < i_min_arm
                        continue
                    if m2_idx - p4_idx < i_min_arm or p6_idx - m2_idx < i_min_arm
                        continue
                    float neck = isB ? math.max(m1, m2) : math.min(m1, m2)
                    float h = isB ? neck - extv : extv - neck
                    if h < i_min_depth * atrRef
                        continue
                    bool broken = false
                    for k = p2_idx + 1 to p6_idx - 1
                        int off = bar_index - k
                        if isB ? low[off] < extv : high[off] > extv
                            broken := true
                            break
                    if broken
                        continue
                    bool winBad = false
                    for off = 0 to bar_index - p6_idx - 1
                        if isB ? close[off] > neck : close[off] < neck
                            winBad := true
                            break
                    if winBad
                        continue
                    float p1_p = na
                    int p1_idx = -1
                    int osz = array.size(opv)
                    if osz > 0
                        for m = osz - 1 to 0
                            int oi = array.get(opi, m)
                            if oi > p2_idx - i_min_trend
                                continue
                            if oi < p2_idx - i_trend_look
                                break
                            float op = array.get(opv, m)
                            float reach = isB ? op - p2_p : p2_p - op
                            if reach >= i_trend_h * h
                                p1_p := op
                                p1_idx := oi
                                break
                    if na(p1_p)
                        continue
                    bool isExt = true
                    for chk = p1_idx + 1 to p2_idx - 1
                        int co = bar_index - chk
                        if isB ? low[co] < p2_p : high[co] > p2_p
                            isExt := false
                            break
                    if not isExt
                        continue
                    float mtot = (hi3 - lo3) / atrRef + math.abs(m1 - m2) / atrRef
                    if not found or mtot < bestMatch
                        found := true
                        bestMatch := mtot
                        best := PatternData.new(p1 = PatternPoint.new(p1_idx, p1_p), p2 = PatternPoint.new(p2_idx, p2_p), p3 = PatternPoint.new(m1_idx, m1), p4 = PatternPoint.new(p4_idx, p4_p), p5 = PatternPoint.new(m2_idx, m2), p6 = PatternPoint.new(p6_idx, p6_p), neck = neck, match_atr = mtot, pattern_color = isB ? i_bot_col : i_top_col, pattern_width = p6_idx - p2_idx, max_wait_bars = int(math.round((p6_idx - p2_idx) * i_ext_mult)), detect_bar = bar_index, state = 0, isBottom = isB)
    [found, best]

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 8: Drawing | القسم الثامن: الرسم
// ═══════════════════════════════════════════════════════════════════

draw_side(PatternData d, PatternVisuals v) =>
    bool isB = d.isBottom
    color pc = d.pattern_color
    color fc = isB ? i_bot_fill : i_top_fill
    color invis = color.new(color.white, 100)
    string sz = get_lbl_size()
    color tc = isB ? i_bot_txt : i_top_txt
    color bg = isB ? i_bot_bg : i_top_bg
    float nk = d.neck
    v.l12 := line.new(d.p1.idx, d.p1.price, d.p2.idx, d.p2.price, color = pc, width = 2)
    v.l23 := line.new(d.p2.idx, d.p2.price, d.p3.idx, d.p3.price, color = pc, width = 2)
    v.l34 := line.new(d.p3.idx, d.p3.price, d.p4.idx, d.p4.price, color = pc, width = 2)
    v.l45 := line.new(d.p4.idx, d.p4.price, d.p5.idx, d.p5.price, color = pc, width = 2)
    v.l56 := line.new(d.p5.idx, d.p5.price, d.p6.idx, d.p6.price, color = pc, width = 2)
    float slope = (d.p2.price - d.p1.price) / (d.p2.idx - d.p1.idx)
    int nlx = int(math.round(d.p1.idx + (nk - d.p1.price) / slope))
    nlx := math.max(nlx, d.p1.idx)
    v.neckline_left := line.new(nlx, nk, d.p2.idx, nk, color = pc, width = 1, style = line.style_dotted)
    int init_end = math.min(bar_index, d.detect_bar + d.max_wait_bars)
    v.neckline_right := line.new(d.p2.idx, nk, init_end, nk, color = pc, width = 1, style = line.style_dotted)
    v.roof_12 := line.new(nlx, nk, d.p2.idx, nk, color = invis)
    v.fill_12 := linefill.new(v.l12, v.roof_12, color = fc)
    v.roof_23 := line.new(d.p2.idx, nk, d.p3.idx, nk, color = invis)
    v.fill_23 := linefill.new(v.l23, v.roof_23, color = fc)
    v.roof_34 := line.new(d.p3.idx, nk, d.p4.idx, nk, color = invis)
    v.fill_34 := linefill.new(v.l34, v.roof_34, color = fc)
    v.roof_45 := line.new(d.p4.idx, nk, d.p5.idx, nk, color = invis)
    v.fill_45 := linefill.new(v.l45, v.roof_45, color = fc)
    v.roof_56 := line.new(d.p5.idx, nk, d.p6.idx, nk, color = invis)
    v.fill_56 := linefill.new(v.l56, v.roof_56, color = fc)
    v.lbl1 := label.new(d.p1.idx, d.p1.price, "1", color = invis, style = isB ? label.style_label_down : label.style_label_up, textcolor = tc, size = sz)
    v.lbl2 := label.new(d.p2.idx, d.p2.price, isB ? txt("bottom1") : txt("top1"), color = bg, style = isB ? label.style_label_up : label.style_label_down, textcolor = tc, size = sz)
    v.lbl3 := label.new(d.p3.idx, d.p3.price, "3", color = invis, style = isB ? label.style_label_down : label.style_label_up, textcolor = tc, size = sz)
    v.lbl4 := label.new(d.p4.idx, d.p4.price, isB ? txt("bottom2") : txt("top2"), color = bg, style = isB ? label.style_label_up : label.style_label_down, textcolor = tc, size = sz)
    v.lbl5 := label.new(d.p5.idx, d.p5.price, "5", color = invis, style = isB ? label.style_label_down : label.style_label_up, textcolor = tc, size = sz)
    v.lbl6 := label.new(d.p6.idx, d.p6.price, isB ? txt("bottom3") : txt("top3"), color = bg, style = isB ? label.style_label_up : label.style_label_down, textcolor = tc, size = sz)

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 9: Admission | القسم التاسع: القبول
// ═══════════════════════════════════════════════════════════════════

admit(PatternData d, array<PatternData> pats, array<PatternVisuals> viss) =>
    int dup = -1
    if array.size(pats) > 0
        for j = 0 to array.size(pats) - 1
            PatternData pj = array.get(pats, j)
            if d.p2.idx <= pj.p6.idx
                dup := j
                break
    bool admitted = false
    if dup >= 0
        PatternData pd = array.get(pats, dup)
        if pd.state == 0 and d.match_atr < pd.match_atr
            array.get(viss, dup).clear()
            array.remove(pats, dup)
            array.remove(viss, dup)
            admitted := true
    else
        admitted := true
        if array.size(pats) >= i_max_pat
            int victim = -1
            for j = 0 to array.size(pats) - 1
                PatternData pj = array.get(pats, j)
                if pj.state == 2 or pj.state == 4 or pj.state >= 5
                    victim := j
                    break
            if victim == -1
                victim := 0
            array.get(viss, victim).clear()
            array.remove(pats, victim)
            array.remove(viss, victim)
    if admitted
        PatternVisuals v = PatternVisuals.new()
        draw_side(d, v)
        array.push(pats, d)
        array.push(viss, v)

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 10: State Machine | القسم العاشر: آلة الحالة
// ═══════════════════════════════════════════════════════════════════

upd(PatternData d, PatternVisuals v, bool[] evt) =>
    bool isB = d.isBottom
    color pc = d.pattern_color
    color fc = isB ? i_bot_fill : i_top_fill
    color invis = color.new(color.white, 100)
    color failC = isB ? i_bear_rev : i_bull_rev
    string sz = get_lbl_size()
    float extv = isB ? math.min(math.min(d.p2.price, d.p4.price), d.p6.price) : math.max(math.max(d.p2.price, d.p4.price), d.p6.price)
    float nk = d.neck
    int tw = i_tgt_wait > 0 ? int(math.round(d.pattern_width * i_tgt_wait)) : 0
    if d.state == 0
        bool failHit = isB ? close < extv : close > extv
        bool brkHit = isB ? close > nk : close < nk
        float hgt = isB ? nk - extv : extv - nk
        if failHit
            d.state := 3
            d.reverse_bar := bar_index
            float m = mult_of(isB ? i_bot_bear : i_top_bull)
            d.reverse_target := isB ? math.max(extv - hgt * m, syminfo.mintick) : extv + hgt * m
            line.set_color(v.l12, failC)
            line.set_color(v.l23, failC)
            line.set_color(v.l34, failC)
            line.set_color(v.l45, failC)
            line.set_color(v.l56, failC)
            line.set_color(v.neckline_left, failC)
            line.set_x2(v.neckline_right, bar_index)
            line.set_color(v.neckline_right, failC)
            color ffc = color.new(failC, color.t(fc))
            linefill.delete(v.fill_12)
            v.fill_12 := linefill.new(v.l12, v.roof_12, color = ffc)
            linefill.delete(v.fill_23)
            v.fill_23 := linefill.new(v.l23, v.roof_23, color = ffc)
            linefill.delete(v.fill_34)
            v.fill_34 := linefill.new(v.l34, v.roof_34, color = ffc)
            linefill.delete(v.fill_45)
            v.fill_45 := linefill.new(v.l45, v.roof_45, color = ffc)
            linefill.delete(v.fill_56)
            v.fill_56 := linefill.new(v.l56, v.roof_56, color = ffc)
            label.set_color(v.lbl2, color.new(failC, 80))
            label.set_textcolor(v.lbl2, failC)
            label.set_color(v.lbl4, color.new(failC, 80))
            label.set_textcolor(v.lbl4, failC)
            label.set_color(v.lbl6, color.new(failC, 80))
            label.set_textcolor(v.lbl6, failC)
            label.set_textcolor(v.lbl1, failC)
            label.set_textcolor(v.lbl3, failC)
            label.set_textcolor(v.lbl5, failC)
            v.lblX := label.new(bar_index, close, "✖", color = failC, style = isB ? label.style_label_up : label.style_label_down, textcolor = color.white, size = sz)
            v.reverse_vline := line.new(bar_index, close, bar_index, d.reverse_target, color = failC, width = 1, style = line.style_dotted)
            v.reverse_hline := line.new(bar_index, d.reverse_target, bar_index, d.reverse_target, color = failC, width = 2, style = line.style_dashed)
            v.reverse_label := label.new(bar_index, d.reverse_target, "🔄 " + str.tostring(d.reverse_target, format.mintick), color = color.new(failC, 20), style = label.style_label_left, textcolor = color.white, size = sz)
        else if brkHit
            d.state := 1
            d.breakout_bar := bar_index
            float m = mult_of(isB ? i_bot_bull : i_top_bear)
            d.target_price := isB ? nk + hgt * m : math.max(nk - hgt * m, syminfo.mintick)
            line.set_x2(v.neckline_right, bar_index)
            v.l67 := line.new(d.p6.idx, d.p6.price, bar_index, nk, color = pc, width = 2)
            v.roof_67 := line.new(d.p6.idx, nk, bar_index, nk, color = invis)
            v.fill_67 := linefill.new(v.l67, v.roof_67, color = fc)
            v.lbl7 := label.new(bar_index, nk, "7", color = invis, style = isB ? label.style_label_down : label.style_label_up, textcolor = isB ? i_bot_txt : i_top_txt, size = sz)
            v.target_vline := line.new(bar_index, nk, bar_index, d.target_price, color = pc, width = 1, style = line.style_dotted)
            v.target_hline := line.new(bar_index, d.target_price, bar_index, d.target_price, color = pc, width = 2, style = line.style_dashed)
            v.target_label := label.new(bar_index, d.target_price, "🎯 " + str.tostring(d.target_price, format.mintick), color = color.new(pc, 20), style = label.style_label_left, textcolor = color.white, size = sz)
            array.set(evt, EV_BRK, true)
        else if bar_index - d.detect_bar >= d.max_wait_bars
            d.state := 5
            line.set_x2(v.neckline_right, d.detect_bar + d.max_wait_bars)
            line.set_color(v.neckline_right, color.new(pc, 60))
        else
            line.set_x2(v.neckline_right, bar_index)
    if (d.state == 1 or d.state == 2) and d.breakout_bar != bar_index and (tw == 0 or bar_index - d.breakout_bar <= tw)
        float tp = d.target_price
        bool tt = isB ? high >= tp : low <= tp
        bool tcl = isB ? close >= tp : close <= tp
        if tt and not d.t_touched
            d.t_touched := true
            d.t_touch_bar := bar_index
        if tcl and not d.t_closed
            d.t_closed := true
            d.t_close_bar := bar_index
        if d.state == 1
            bool doneT = tgt_touch ? d.t_touched : d.t_closed
            if doneT
                d.state := 2
                line.set_x2(v.target_hline, bar_index)
                line.set_color(v.target_hline, i_achieved)
                label.set_x(v.target_label, bar_index)
                label.set_text(v.target_label, "✓ " + str.tostring(tp, format.mintick))
                label.set_color(v.target_label, color.new(i_achieved, 20))
            else
                line.set_x2(v.target_hline, bar_index)
                label.set_x(v.target_label, bar_index)
    if d.state == 1 and tw > 0 and bar_index - d.breakout_bar >= tw
        d.state := 6
        line.set_x2(v.target_hline, bar_index)
        line.set_color(v.target_hline, color.new(pc, 60))
        line.set_style(v.target_hline, line.style_dotted)
        label.set_x(v.target_label, bar_index)
        label.set_text(v.target_label, "⌛ " + str.tostring(d.target_price, format.mintick))
        label.set_color(v.target_label, color.new(color.gray, 30))
    if (d.state == 3 or d.state == 4) and d.reverse_bar != bar_index and (tw == 0 or bar_index - d.reverse_bar <= tw)
        float rt = d.reverse_target
        bool rtt = isB ? low <= rt : high >= rt
        bool rtc = isB ? close <= rt : close >= rt
        if rtt and not d.r_touched
            d.r_touched := true
            d.r_touch_bar := bar_index
        if rtc and not d.r_closed
            d.r_closed := true
            d.r_close_bar := bar_index
        if d.state == 3
            bool doneR = tgt_touch ? d.r_touched : d.r_closed
            if doneR
                d.state := 4
                line.set_x2(v.reverse_hline, bar_index)
                line.set_color(v.reverse_hline, i_achieved)
                label.set_x(v.reverse_label, bar_index)
                label.set_text(v.reverse_label, "✓ " + str.tostring(rt, format.mintick))
                label.set_color(v.reverse_label, color.new(i_achieved, 20))
            else
                line.set_x2(v.reverse_hline, bar_index)
                label.set_x(v.reverse_label, bar_index)
    if d.state == 3 and tw > 0 and bar_index - d.reverse_bar >= tw
        d.state := 7
        line.set_x2(v.reverse_hline, bar_index)
        line.set_color(v.reverse_hline, color.new(failC, 60))
        line.set_style(v.reverse_hline, line.style_dotted)
        label.set_x(v.reverse_label, bar_index)
        label.set_text(v.reverse_label, "⌛ " + str.tostring(d.reverse_target, format.mintick))
        label.set_color(v.reverse_label, color.new(color.gray, 30))

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 11: Runtime State | القسم الحادي عشر: حالة التشغيل
// ═══════════════════════════════════════════════════════════════════

var array<float> bot_pv = array.new_float()
var array<int> bot_pi = array.new_int()
var array<float> top_pv = array.new_float()
var array<int> top_pi = array.new_int()
var array<PatternData> bot_pats = array.new<PatternData>()
var array<PatternVisuals> bot_viss = array.new<PatternVisuals>()
var array<PatternData> top_pats = array.new<PatternData>()
var array<PatternVisuals> top_viss = array.new<PatternVisuals>()
var table info_tbl = na

bool[] evt_b = array.new_bool(1, false)
bool[] evt_t = array.new_bool(1, false)

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 12: Pipeline | القسم الثاني عشر: خط الأنابيب
// ═══════════════════════════════════════════════════════════════════

if barstate.isconfirmed
    if array.size(bot_pats) > 0
        for j = 0 to array.size(bot_pats) - 1
            upd(array.get(bot_pats, j), array.get(bot_viss, j), evt_b)
    if array.size(top_pats) > 0
        for j = 0 to array.size(top_pats) - 1
            upd(array.get(top_pats, j), array.get(top_viss, j), evt_t)
    if not na(plv)
        array.push(bot_pv, plv)
        array.push(bot_pi, bar_index - i_right)
        if array.size(bot_pv) > 50
            array.shift(bot_pv)
            array.shift(bot_pi)
    if not na(phv)
        array.push(top_pv, phv)
        array.push(top_pi, bar_index - i_right)
        if array.size(top_pv) > 50
            array.shift(top_pv)
            array.shift(top_pi)

bool scanB = barstate.isconfirmed and i_enable_bot and not na(plv)
bool scanT = barstate.isconfirmed and i_enable_top and not na(phv)
[fb, db] = scan_side(scanB, true, bot_pv, bot_pi, top_pv, top_pi)
[ft, dt] = scan_side(scanT, false, top_pv, top_pi, bot_pv, bot_pi)

if scanB and fb
    admit(db, bot_pats, bot_viss)
if scanT and ft
    admit(dt, top_pats, top_viss)

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 13: Alerts | القسم الثالث عشر: التنبيهات
// ═══════════════════════════════════════════════════════════════════

bool pattern_complete = array.get(evt_b, EV_BRK) or array.get(evt_t, EV_BRK)

alertcondition(pattern_complete, "Triple Pattern Complete | اكتمال النموذج الثلاثي", "Triple pattern complete: neckline broken on bar close | اكتمال نموذج ثلاثي: كسر خط العنق بإغلاق مؤكد — {{ticker}} {{interval}} @ {{close}}")

// ═══════════════════════════════════════════════════════════════════
// 📌 Section 14: Info Table | القسم الرابع عشر: جدول المعلومات
// ═══════════════════════════════════════════════════════════════════

fill_info(table t, int r0, PatternData d) =>
    bool isB = d.isBottom
    string ts = get_txt_size()
    color hc = isB ? color.new(#2962FF, 30) : color.new(#FF1744, 30)
    color failC = isB ? i_bear_rev : i_bull_rev
    table.cell(t, 0, r0, isB ? txt("triple_bottom") : txt("triple_top"), text_color = color.white, text_size = ts, bgcolor = hc)
    table.cell(t, 1, r0, "", text_color = color.white, text_size = ts, bgcolor = hc)
    table.merge_cells(t, 0, r0, 1, r0)
    string md = (d.state == 3 or d.state == 4 or d.state == 7) ? (isB ? i_bot_bear : i_top_bull) : (isB ? i_bot_bull : i_top_bear)
    table.cell(t, 0, r0 + 1, txt("target_mode"), text_color = color.white, text_size = ts, text_halign = text.align_right)
    table.cell(t, 1, r0 + 1, mode_txt(md), text_color = color.white, text_size = ts)
    float tp = (d.state == 1 or d.state == 2 or d.state == 6) ? d.target_price : (d.state == 3 or d.state == 4 or d.state == 7) ? d.reverse_target : na
    table.cell(t, 0, r0 + 2, txt("target_price"), text_color = color.white, text_size = ts, text_halign = text.align_right)
    table.cell(t, 1, r0 + 2, na(tp) ? "—" : str.tostring(tp, format.mintick), text_color = color.white, text_size = ts)
    string st = d.state == 0 ? txt("waiting") : d.state == 1 ? (isB ? txt("bull_break") : txt("bear_break")) : d.state == 2 ? txt("tgt_hit") : d.state == 3 ? (isB ? txt("reversal_down") : txt("reversal_up")) : d.state == 4 ? txt("rev_hit") : d.state == 6 ? txt("brk_exp") : d.state == 7 ? txt("rev_exp") : txt("expired")
    color stc = (d.state == 2 or d.state == 4) ? i_achieved : d.state == 3 ? failC : d.state >= 5 ? color.gray : color.white
    table.cell(t, 0, r0 + 3, txt("status"), text_color = color.white, text_size = ts, text_halign = text.align_right)
    table.cell(t, 1, r0 + 3, st, text_color = stc, text_size = ts)
    table.cell(t, 0, r0 + 4, txt("age"), text_color = color.white, text_size = ts, text_halign = text.align_right)
    table.cell(t, 1, r0 + 4, str.tostring(bar_index - d.detect_bar), text_color = color.new(color.gray, 20), text_size = ts)
    r0 + 5

build_info() =>
    table t = table.new(get_tbl_pos(), 2, 10, bgcolor = color.new(#131722, 15), frame_width = 2, frame_color = color.new(color.gray, 40), border_width = 1, border_color = color.new(color.gray, 70))
    int r = 0
    if i_enable_bot and array.size(bot_pats) > 0
        r := fill_info(t, r, array.get(bot_pats, array.size(bot_pats) - 1))
    if i_enable_top and array.size(top_pats) > 0
        r := fill_info(t, r, array.get(top_pats, array.size(top_pats) - 1))
    t

if barstate.islast
    table.delete(info_tbl)
    info_tbl := build_info()
````
