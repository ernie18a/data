# Strategy Testing Dashboard  (STD)  

- url: https://www.tradingview.com/script/LQnwSeam-Strategy-Testing-Dashboard-STD/
- type: strategy
- pine_id: PUB;675a8255dafb4705875617a410c955ea
- version: 1.0

## Description

📊 Strategy Testing Dashboard (STD)

Complete User Guide & Inputs

The Strategy Testing Dashboard (STD) is a configurable TradingView strategy that brings RSI, Moving Average (MA), and MACD signals together with unified trade-management controls and an on-chart configuration summary — in a single settings panel. This consolidated structure means traders can test and compare configurations without loading multiple separate strategies and indicators, saving setup time and effort.

The STD is designed to provide a structured framework for strategy testing rather than simply displaying indicator signals. Users can select one or more indicator modules, define how multiple enabled indicators should be combined using AND or OR logic, and determine whether the strategy trades long positions, short positions, or long and short. When multiple indicators are enabled, the dashboard also provides a Combination Assessment that classifies the selected indicator pairing and combination logic, identifying configurations as favorable, weak, potentially redundant, or requiring caution where applicable.

⚙️ User Inputs
The Strategy Testing Dashboard (STD) can be configured through the inputs available in the TradingView settings panel. The inputs are organized into sections that control shared strategy behavior, dashboard display, indicator selection, combination logic, and the parameters of each enabled indicator.

When an indicator is disabled, its inputs become inactive, while settings such as ATR Period are relevant only when ATR Trailing is selected as the stop-loss method.

The following sections explain each user input in the same order in which it appears in the STD settings panel.

🌐 Shared Inputs
Language: Selects English or Arabic for the dashboard's labels and displayed text.  

Trade Direction: Controls which entry directions are allowed: Long only, Short only, or Long & Short, allowing the strategy to reverse between long and short positions; only one net position exists at a time.

Stop Loss: Selects the protective stop method: None, Fixed %, Trailing %, or ATR Trailing. None disables the protective stop and leaves the strategy dependent on its signal-based exit.

Stop Loss Value: Sets the stop value according to the selected method. It is a percentage for Fixed % and Trailing %, or an ATR multiplier for ATR Trailing. It is ignored when Stop Loss is set to None.

ATR Period: Sets the number of bars used to calculate ATR for ATR Trailing stops. The default is 14. Shorter periods react faster to recent volatility, while longer periods produce a smoother value. This input is active only with ATR Trailing.

Show Stop-Loss Line: Shows or hides the live stop-loss level on the chart. Hiding the line does not disable the stop-loss calculation or execution.

Confirmation Bars: Acts as a noise filter by setting the number of consecutive bars for which a signal must remain valid before it fires. It applies to all three signal modules. A value of 1 adds no extra confirmation delay.

🖥️ Display Table
Show Indicator Settings Table: Shows or hides the on-chart Indicator Settings Table containing the active strategy settings and Combination Assessment.

Table Theme Color: Selects the preset table theme: Blue, Teal, Brown, or Dark Theme.

🎯 Indicator Selection
RSI: Enables or disables the RSI signal module. RSI is treated as a mean-reversion/reversal-style module.

MA: Enables or disables the moving-average signal module. MA is treated as a trend-following module.

MACD: Enables or disables the MACD signal module. MACD is treated as a trend-following module and is derived from moving averages.

🔗 Indicator Combination Logic
Combination Logic: Controls how enabled indicator modules are combined for entries. AND requires all enabled modules to agree; OR allows an entry when any enabled module produces the required signal. This setting applies to entries only. Opposite-signal exits remain active independently of this entry-combination setting. So in effect, an opposite signal from any single enabled module is sufficient to close the position, functioning as OR logic regardless of the Combination Logic setting chosen for entries.

🧭 Combination Assessment
The Indicator Settings Table's final row classifies the current Indicator Selection + Combination Logic setup, so you can see at a glance whether the chosen combination is structurally sound, weak, or potentially redundant. A few examples:

✅ Favorable — Strong Confluence: Both indicators confirm each other, with the reversal already confirmed before the trend filter applies.

✅ Favorable — Moderate Confluence: Complementary, but with less confirmation strength, since the reversal signal fires earlier.

⚠️ Weak Confluence — Mixed Signals: OR logic lets a signal fire without true agreement from both indicators, blending different trade styles into one entry stream.

⚠️ Caution — Overly Strict (Near-Duplicate): AND requires two indicators that detect essentially the same event to agree, making entries unnecessarily rare.

⚠️ Potential Redundancy — Near-Duplicate Overlap: OR combines two near-identical indicators, so it behaves almost like using just one.

⚠️ Caution — Overly Strict (High Correlation): AND requires two highly correlated signals to align, adding little independent confirmation.

Favorable combinations indicate confirmed, complementary signals. Configurations flagged as Caution or Potential Redundancy are not necessarily wrong — they simply mean the second indicator may add limited independent information beyond the first, or that the combination logic may be stricter than intended.

The Combination Assessment shown in the on-chart settings table is a rule-based structural classification for guidance only and is not a measured result. It is derived from which indicator types, sub-modes, and combination logic (AND/OR) are selected — it does not reflect actual signal correlation, trade frequency, or backtested performance for any specific symbol, timeframe, or settings. Labels such as "Caution," "Potential Redundancy," or "Favorable" describe structural relationships between the selected modules, not verified outcomes. Evaluate any configuration through backtesting to gain further insight into how it performs.

📈 RSI Indicator
RSI Length: Sets the RSI calculation period. The default is 14.

Price Source: Selects the price series used by RSI: Open, High, Low, or Close. The default is Close.

Low Threshold: Defines the lower RSI threshold used by the selected RSI signal logic. The default is 30.

High Threshold: Defines the upper RSI threshold used by the selected RSI signal logic. The default is 70.

Signal Logic: Selects Threshold Breach or Breach-then-Cross-Back. Threshold Breach reacts when the threshold condition is breached; Breach-then-Cross-Back requires the RSI to breach the threshold and then return across it, providing a more confirmed reversal signal.

📐 MA Indicator
Signal Logic: Selects MA Crossover or Price–MA Crossover.

MA Type: Selects the moving-average calculation: SMA, EMA, WMA, HMA, or RMA. The default is EMA.

Price Source: Selects the price series used for the MA calculation: Open, High, Low, or Close. The default is Close.

Fast MA Length: Sets the fast moving-average period when MA Crossover is selected. The default is 9.

Slow MA Length: Sets the slow moving-average period when MA Crossover is selected. The default is 21.

MA Length: Sets the single moving-average period when Price–MA Crossover is selected. The default is 20.

Crossover Threshold (%): Acts as a noise filter by setting the minimum percentage separation required for a signal to qualify. In MA Crossover mode, this is the percentage difference between the Fast and Slow MA, relative to the Slow MA. In Price–MA Crossover mode, it is the percentage distance between price and the MA, relative to the MA itself. A value of 0 disables the threshold. Applies to both MA signal modes, using the calculation appropriate to each.

📊 MACD Indicator
Fast MA Length: Sets the fast moving-average period used in MACD. The default is 12.

Slow MA Length: Sets the slow moving-average period used in MACD. The default is 26.

Signal MA Length: Sets the signal-line period. The default is 9.

MA Type: Selects the moving-average calculation used by the MACD components: EMA, SMA, WMA, HMA, or RMA. The default is EMA.

Source: Selects the price source used for MACD: Open, High, Low, or Close. The default is Close.

Signal Logic: Selects MACD/Signal Crossover or Zero-Line Crossover.

Crossover Threshold: Acts as a noise filter setting the minimum separation required for the selected MACD crossover condition. The threshold is expressed in price units: histogram magnitude in MACD/Signal Crossover mode, or MACD-line distance from zero in Zero-Line Crossover mode. The default is 0.

🔄 How the Inputs Work Together
The user determines which signal modules are enabled. Their signals are then combined according to the selected AND/OR logic for entries. Confirmation Bars can delay signal activation, while the selected Stop Loss method provides an independent protective exit. Opposite-direction signals provide the strategy's signal-based exit and, when Long & Short directions are enabled,  a close-then-flip sequence is produced.

Signals are generated at bar close and, under the strategy's default calculation behavior, orders are executed on the following bar's open. The strategy also uses an indicator-readiness warm-up rather than a fixed universal warm-up period. The warm-up period adapts to the indicators used, ensuring they have accumulated enough bars before the strategy begins generating signals.

🧪 Validation
STD's signal modules were cross-validated against native/reference TradingView scripts — RSI Strategy, MA Crossover, MA Price Crossover, and MACD Strategy — using exported trade logs across multiple symbols and equity  percentage levels. The RSI, MA Crossover, MA Price Crossover, and MACD modules showed consistent agreement with their respective reference scripts in the testing performed.



📊 لوحة اختبار الاستراتيجيات (STD)

دليل المستخدم الكامل والمدخلات

لوحة اختبار الاستراتيجيات (إس تي دي) هي استراتيجية متعددة الاختيارات  على منصة   (تريدنج فيو)، تجمع إشارات مؤشر القوة النسبية  (آر إس آي)، والمتوسط المتحرك  (إم إيه)، وتقارب وتباعد المتوسطات المتحركة  (إم إيه سي دي)، إلى جانب أدوات موحّدة لإدارة التداول وملخص لإعدادات المؤشرات معروض على الرسم البياني، وذلك ضمن لوحة إعدادات واحدة. ويتيح هذا الهيكل الموحّد للمتداولين اختبار إعدادات مركبة للمؤشرات ومقارنتها دون الحاجة إلى تحميل عدة استراتيجيات ومؤشرات منفصلة.

⚙️ مدخلات المستخدم
يمكن تكوين لوحة اختبار الاستراتيجيات (إس تي دي) من خلال المدخلات المتاحة في لوحة إعدادات (تريدنج فيو). وتُنظّم هذه المدخلات ضمن أقسام تتحكم في سلوك الاستراتيجية المشترك، والبيانات المعروضة على اللوحة، واختيار المؤشرات، ومنهج دمج المؤشرات، واعدادات كل مؤشر مفعّل.

لا يلزم تعديل سوى الإعدادات ذات الصلة بالتكوين المحدد. فعلى سبيل المثال، عندما يكون أحد المؤشرات غير مفعّل، تصبح مدخلاته غير نشطة. وبالمثل، تكون مدخلة فترة (إيه تي آر) ذات صلة فقط عند اختيار طريقة وقف الخسارة المتتبّع وفق (إيه تي آر). ويعكس هذا السلوك آلية تفعيل المدخلات المستخدمة في الكود.

توضح الأقسام التالية كل مدخل من مدخلات المستخدم بالترتيب نفسه الذي يظهر به في لوحة إعدادات (إس تي دي).

🌐 المدخلات المشتركة
اللغة: تتيح اختيارالإنجليزية  أو العربية للوحة والنصوص المعروضة. ويؤثر هذا الإعداد على طريقة العرض فقط، ولا يغيّر الحسابات أو منطق التداول.

اتجاه التداول: يحدد اتجاه التداول: شراء فقط، بيع على المكشوف فقط، أو كلاهما. ويتيح خيار كلاهما للاستراتيجية الانتقال بين مراكز الشراء والبيع على المكشوف؛ ولا يمكن وجود سوى اتجاه صافٍ واحد في أي وقت.

وقف الخسارة: يحدد طريقة واحدة لوقف الخسارة: لا يوجد، نسبة ثابتة %، نسبة الخسارة المتتبّعة %، أو وقف الخسارة المتتبّع وفق (إيه تي آر). ويؤدي اختيار لا يوجد إلى تعطيل وقف الخسارة الوقائي، بحيث تعتمد الاستراتيجية على الخروج عند الإشارة المعاكسة.

قيمة وقف الخسارة  : تُستخدم القيمة وفقًا لطريقة وقف الخسارة المحددة: نسبة مئوية (%) للنسبة الثابتة أو نسبة الخسارة المتتبّعة، أو معامل (إيه تي آر) للوقف المتتبّع وفق (إيه تي آر). وتُتجاهل هذه القيمة عند اختيار لا يوجد.

فترة (إيه تي آر): تحدد عدد الشموع المستخدمة لحساب متوسط المدى الحقيقي (إيه تي آر) لوقف الخسارة المتتبّع وفق (إيه تي آر). والقيمة الافتراضية هي 14. تستجيب الفترات الأقصر بسرعة أكبر للتقلبات الأخيرة، بينما تعطي الفترات الأطول قيمة أكثر سلاسة وثباتًا. وتُفعّل هذه المدخلة فقط عند اختيار طريقة وقف الخسارة المتتبّع وفق (إيه تي آر).

عرض خط وقف الخسارة: يعرض أو يخفي خط مستوى وقف الخسارة الفعلي على الرسم البياني. ولا يؤدي إخفاء الخط إلى تعطيل حساب وقف الخسارة أو تنفيذ أمره. يتتبّع الخط مستوى الخروج الفعلي طوال فترة بقاء الصفقة مفتوحة. ويكون ثابتًا وأفقيًا في حالة النسبة الثابتة %، بينما يتحرك تدريجيًا إلى أعلى في صفقات الشراء أو إلى أسفل في صفقات البيع في حالتي النسبة المتتبّعة % و(إيه تي آر).

شموع التأكيد : يعمل كمرشّح لتقليل الإشارات الكاذبة، حيث يحدد عدد الشموع المتتالية التي يجب أن تبقى فيها الإشارة سارية قبل تفعيلها. ينطبق هذا على جميع وحدات الإشارة الثلاث. القيمة (1) لا تضيف أي تأخير إضافي للتأكيد.

🖥️ جدول العرض
عرض جدول إعدادات المؤشر): يعرض أو يخفي جدول إعدادات المؤشر على الرسم البياني، والذي يعرض إعدادات الاستراتيجية الحالية وتقييم دمج المؤشرَات.

لون الجدول: يحدد سمة الجدول: أزرق، أخضر، بني، أو الوضع الداكن. وهذه هي الخيارات المستخدمة في إعدادات (إس تي دي).

🎯 اختيار المؤشرات
مؤشر القوة النسبية (آر إس آي): يفعّل أو يعطّل وحدة (آر إس آي). ويُعامل (آر إس آي) كمؤشر يعتمد على الارتداد نحو المتوسط/الانعكاس، حيث تعتمد إشاراته على مستويات التشبع الشرائي والبيعي.

المتوسط المتحرك (إم إيه): يفعّل أو يعطّل وحدة (إم إيه). ويُعامل (إم إيه) كمؤشر يعتمد على تتبّع الاتجاه.

تقارب وتباعد المتوسطات المتحركة (إم إيه سي دي): يفعّل أو يعطّل وحدة (إم إيه سي دي). ويُعامل (إم إيه سي دي) كمؤشر يعتمد على تتبّع الاتجاه، وهو مشتق رياضيًا من المتوسطات المتحركة. ويستخدم الكود هذا الاسم العربي في اسم مجموعة إعدادات (إم إيه سي دي).

🔗 منهج دمج المؤشرات
منهج دمج المؤشرات: يتحكم في كيفية دمج المؤشرات المفعّلة لتحديد إشارات الدخول.

•	و (آند): يجب أن تتفق جميع المؤشرات المفعّلة حتى يتم تفعيل الدخول.
•	أو (أور): يمكن لأي مؤشر مفعّل تفعيل الدخول.

وينطبق هذا الإعداد على الدخول فقط. أما الخروج عند الإشارة المعاكسة فيتم تفعيله دائمًا من أي مؤشر مفعّل، بصورة مستقلة عن منهج دمج المؤشرات المستخدم للدخول.

وبالتالي، إذا كان أكثر من مؤشر مفعّل، فإن )و( يتطلب توافق جميع المؤشرات، بينما يسمح )أو( لأي مؤشر مفعّل بتفعيل الدخول. أما الإشارة المعاكسة، فلا تتطلب هذا التوافق؛ إذ يكفي أن تصدر عن أي مؤشر مفعّل لإغلاق الصفقة. ويؤكد منطق الكود أن نطاق منهج دمج المؤشرات مفعّل للدخول ولا يتحكم في الخروج.

🧭 تقييم دمج المؤشرَات
يقوم الصف الأخير من جدول إعدادات المؤشر بعرض تقييم دمج المؤشرات وفقًا لاختيار المؤشرات ومنهج دمج المؤشرات الحالي. ويهدف هذا التقييم إلى توضيح ما إذا كان الدمج  إيجابي أو ضعيفًا أو تكراريًا أو يتطلب الانتباه.

يعتمد التصنيف على طبيعة المؤشرات وأنماط إشاراتها. ويعامل الكود (آر إس آي) باعتباره مؤشرًا للارتداد نحو المتوسط، بينما يعامل (إم إيه) و(إم إيه سي دي) باعتبارهما مؤشرين لتتبّع الاتجاه. كما يأخذ في الاعتبار أن (إم إيه سي دي) مشتق رياضيًا من المتوسطات المتحركة، ولذلك تكون علاقته بـ (إم إيه) مرتفعة.

ومن أمثلة التقييم:
✅ إيجابي — تلاقٍ قوي: يؤكد المؤشران أحدهما الآخر، حيث يتم تأكيد الانعكاس قبل تطبيق مرشح الاتجاه.

✅ إيجابي — تلاقٍ متوسط: مكمّلان لبعضهما، لكن بقوة تأكيد أقل، لأن إشارة الانعكاس تصدر مبكرًا.

⚠️ تلاقٍ ضعيف — إشارات مختلطة: يسمح منطق "أو" بإطلاق الإشارة دون اتفاق حقيقي بين المؤشرَين، مما يمزج أساليب تداول مختلفة في سلسلة دخول واحدة.

⚠️ تنبيه — تقييد زائد (شبه مطابق): يتطلب منطق "و" اتفاق مؤشرَين يرصدان في جوهرهما الحدث ذاته تقريبًا، مما يجعل الدخول الدخول أكثر ندرة.

⚠️ احتمال تكرار — تداخل شبه مطابق: يجمع منطق "أو" بين مؤشرَين شبه متطابقَين، فيتصرف النظام تقريبًا كما لو كان يستخدم مؤشرًا واحدًا فقط.

⚠️ تنبيه — تقييد زائد (ارتباط مرتفع): يتطلب منطق "و" اتفاق إشارتين مرتبطتين ارتباطًا عاليًا، مما يضيف تأكيدًا مستقلاً محدودًا.

باختصار: التصنيف "إيجابي" يشير إلى إشارات متسقة ومتكاملة. أما التصنيفات المصنّفة كـ"تنبيه" أو "احتمال تكرار" فليست خاطئة بالضرورة — فهي تعني فقط أن المؤشر الثاني قد يضيف معلومة مستقلة محدودة إلى الأول، أو أن منطق الدمج قد يكون أكثر تشددًا مما كان مقصودًا.

تقييم دمج المؤشرات المعروض في جدول الإعدادات على الرسم البياني هو تصنيف هيكلي قائم على قواعد للإرشاد فقط، وليس نتيجة مقاسة فعليًا. فهو مبني على نوع المؤشرات المختارة ومنهج إشارتها ومنطق الدمج (و/أو)، ولا يعكس الارتباط الفعلي بين الإشارات، أو تواتر الصفقات، أو الأداء الفعلي المُختبر على أي رمز أو إطار زمني أو إعدادات محددة. تصنيفات مثل "تنبيه" أو "احتمال تكرار" أو "إيجابي" تصف علاقات هيكلية بين المؤشرات المختارة، لا نتائج تم التحقق منها. يُرجى تقييم أي دمج للمؤشرات عبر الاختبار الرجعي (باك تيست) للحصول على فهم أعمق لأدائه.

📈 مؤشر القوة النسبية (RSI)
فترة المؤشر: تحدد فترة حساب (آر إس آي). والقيمة الافتراضية هي 14.

مصدر الأسعار: يحدد الأسعار المستخدمة في حساب (آر إس آي): الافتتاح، الأعلى، الأدنى، أو الإغلاق. والقيمة الافتراضية هي الإغلاق.

الحد الأدنى: يحدد الحد الأدنى لـ (آر إس آي) المستخدم في منطق إشارة التداول. والقيمة الافتراضية هي 30.

الحد الأعلى: يحدد الحد الأعلى لـ (آر إس آي) المستخدم في منطق إشارة التداول. والقيمة الافتراضية هي 70.

منهج إشارة التداول: يتيح الاختيار بين اختراق الحد واختراق ثم عودة.
•	اختراق الحد: تصدر الإشارة عند اختراق المؤشر للحد، سواء الحد الأدنى أو الحد الأعلى.
•	اختراق ثم عودة: تصدر الإشارة عند اختراق المؤشر للحد ثم عبوره مجددًا إلى الجهة الأخرى، مما يوفر إشارة انعكاس أكثر تأكيدًا.

📐 المتوسط المتحرك (MA)
منهج إشارة التداول: يتيح الاختيار بين تقاطع المتوسط المتحرك وتقاطع السعر مع المتوسط المتحرك.

نوع المتوسط المتحرك: يحدد طريقة حساب المتوسط المتحرك: (إس إم إيه)، (إي إم إيه)، (دبليو إم إيه)، (إتش إم إيه)، أو (آر إم إيه). والقيمة الافتراضية هي (إي إم إيه).

مصدر الأسعار: يحدد الأسعار المستخدمة في حساب المتوسط المتحرك: الافتتاح، الأعلى، الأدنى، أو الإغلاق. والقيمة الافتراضية هي الإغلاق.

طول المتوسط المتحرك السريع: يحدد فترة المتوسط المتحرك السريع عند اختيار تقاطع المتوسط المتحرك. والقيمة الافتراضية هي 9.

طول المتوسط المتحرك البطيء: يحدد فترة المتوسط المتحرك البطيء عند اختيار تقاطع المتوسط المتحرك. والقيمة الافتراضية هي 21.

طول المتوسط المتحرك: يحدد فترة المتوسط المتحرك الواحد عند اختيار تقاطع السعر مع المتوسط المتحرك. والقيمة الافتراضية هي 20.

الحد الأدنى للتقاطع (%) : يعمل كمرشّح لتقليل الإشارات الكاذبة.  يحدد الحد الأدنى للفارق النسبي المطلوب لاعتبار الإشارة مؤهلة.
في نمط تقاطع المتوسطات، يحدد الحد الأدنى لنسبة الفارق % بين المتوسط المتحرك السريع والمتوسط المتحرك البطيء.
وفي نمط تقاطع السعر مع المتوسط، يحدد الحد الأدنى لنسبة المسافة % بين السعر والمتوسط المتحرك.
وتنطبق هذه المدخلة على كلا النمطين. وتؤدي القيمة 0 إلى عدم فرض حد أدنى إضافي.

📊 تقارب وتباعد المتوسطات المتحركة (MACD)
طول المتوسط المتحرك السريع: يحدد فترة المتوسط المتحرك السريع المستخدمة في (إم إيه سي دي). والقيمة الافتراضية هي 12.

طول المتوسط المتحرك البطيء: يحدد فترة المتوسط المتحرك البطيء المستخدمة في (إم إيه سي دي). والقيمة الافتراضية هي 26.

طول متوسط متحرك الإشارة: يحدد فترة متوسط متحرك الإشارة. والقيمة الافتراضية هي 9.

نوع المتوسط المتحرك: يحدد طريقة حساب المتوسط المتحرك المستخدمة  في المتوسط السريع والمتوسط البطيء ومتوسط الإشارة: (إي إم إيه)، (إس إم إيه)، (دبليو إم إيه)، (إتش إم إيه)، أو (آر إم إيه). والقيمة الافتراضية هي (إي إم إيه). ويعتبر (إي إم إيه) هو الحساب القياسي في (إم إيه سي دي)، بينما يُعد أي اختيار آخر نسخة مختلفة من (إم إيه سي دي).

مصدر الأسعار: يحدد مصدر الأسعار المستخدم في (إم إيه سي دي): الافتتاح، الأعلى، الأدنى، أو الإغلاق. والقيمة الافتراضية هي الإغلاق.

منهج إشارة التداول: يتيح الاختيار بين تقاطع المؤشر مع خط الإشارة وتقاطع خط الصفر.

الحد الأدنى:  يعمل كمرشّح لتقليل الإشارات الكاذبة. يحدد الحد الأدنى المطلوب لاعتبار شرط التقاطع المحدد مؤهلًا.
في نمط تقاطع المؤشر مع خط الإشارة، يحدد الحد الأدنى لقيمة أعمدة المؤشر بوحدات السعر المطلوبة لاعتبار التقاطع صحيحًا.
وفي نمط تقاطع خط الصفر، يحدد الحد الأدنى لمسافة خط المؤشر عن الصفر بوحدات السعر المطلوبة لاعتبار التقاطع صحيحًا.
وينطبق هذا الإعداد على كلا النمطين، والقيمة الافتراضية هي 0 .

## Source Code

````pine
//@version=6
//
//© TrendAdvantage
// ═══════════════════════════════════════════════════
// Strategy Testing Dashboard (STD)
// ═══════════════════════════════════════════════════
// The Strategy Testing Dashboard (STD) is a configurable TradingView strategy that
// brings RSI, Moving Average (MA), and MACD signals together with unified trade-
// management controls and an on-chart indicator settings summary in a single settings
// panel. This consolidated structure allows traders to test and compare indicator
// configurations without loading multiple separate strategies and indicators.

// STD provides a structured framework for strategy testing rather than simply
// displaying indicator signals. Users can select one or more indicator modules, combine
// multiple enabled indicators using AND or OR logic, and choose whether to trade long
// positions, short positions, or both. When multiple indicators are enabled, the
// dashboard also provides a Combination Assessment that evaluates the selected
// configuration as favorable, weak, potentially redundant, or requiring caution, where applicable.
//
// ═══════════════════════════════════════════════════
// (STD) لوحة اختبار الاستراتيجيات 
// ═══════════════════════════════════════════════════
// لوحة اختبار الاستراتيجيات هي استراتيجية متعددة الاختيارات على منصة
// تريدينغ فيو، تجمع إشارات مؤشر القوة النسبية، والمتوسط المتحرك، ومؤشر
// التقارب والتباعد للمتوسطات المتحركة، إلى جانب أدوات موحّدة لإدارة
// التداول وملخص لإعدادات المؤشرات معروض على الرسم البياني، وذلك ضمن
// لوحة إعدادات واحدة. ويتيح هذا الهيكل الموحّد للمتداولين اختبار إعدادات
// مركبة للمؤشرات ومقارنتها دون الحاجة إلى تحميل عدة استراتيجيات ومؤشرات
// منفصلة.
//
// توفر لوحة اختبار الاستراتيجيات إطارًا منظّمًا لاختبار الاستراتيجيات
// بدلًا من الاقتصار على عرض إشارات المؤشرات فقط. ويمكن للمستخدمين اختيار
//  "مؤشر واحد أو أكثر، ودمج المؤشرات المفعّلة باستخدام منطق "و" أو "أو
// وتحديد ما إذا كانوا يرغبون في التداول بصفقات شراء، أو صفقات بيع على المكشوف، أو
// كليهما. وعند تفعيل عدة مؤشرات، توفر اللوحة أيضًا تقييمًا للاختيار
// المركب للمؤشرات، يقوم، حيثما ينطبق ذلك، بتقييم التكوين المحدد باعتباره
//  إيجابي، أو ضعيفًا، أو تكراريًا، أو يتطلب الانتباه.

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
// This Strategy is an econometric measurement tool.
// Past sequence characteristics do not guarantee
// future market behavior. All outputs are descriptive
// statistical evidence and do not guarantee future results.
//=====================================================
strategy("Strategy Testing Dashboard — STD  [TrendAdvantage]", overlay = true,
     pyramiding = 1,
     default_qty_type = strategy.fixed, default_qty_value = 1,
     margin_long = 100, margin_short = 100,
     calc_on_every_tick = false)

// Fixed sizing (1 unit/contract per entry, no leverage) keeps STD aligned
// with the native reference strategies it was validated against.

// -----------------------------------------------------------------------------
// Language (master toggle — drives label lookup only, no calculation impact)
// -----------------------------------------------------------------------------
langChoice = input.string("English", "Language — اللغة", options = ["English", "العربية"],
     group = "SHARED INPUTS — مدخلات مشتركة")

// -----------------------------------------------------------------------------
// Shared / Global Inputs — applies uniformly across modules
// -----------------------------------------------------------------------------
tradeDirection = input.string("Long & Short - شراء و بيع على المكشوف", "Trade Direction — اتجاه التداول",
     options = ["Long only - شراء فقط", "Short only - بيع على المكشوف فقط", "Long & Short - شراء و بيع على المكشوف"], group = "SHARED INPUTS — مدخلات مشتركة",
     tooltip = "Selects entry direction: Long only, Short only, or Long & Short. " +
     "'Long & Short' allows the strategy to reverse between long and short " +
     "positions; only one net position exists at a time." +
     "\n\n" +
     "يحدد اتجاه التداول: شراء فقط ، بيع على المكشوف فقط ، أو " +
     "شراء وبيع على المكشوف . يتيح خيار 'شراء وبيع على المكشوف' للاستراتيجية الانتقال بين مراكز " +
     "الشراء والبيع على المكشوف؛ ولا يمكن وجود سوى إتجاه واحد في أي وقت ما")

// SL — "None" disables the protective stop entirely; the strategy then
// relies solely on exit-on-opposite-signal.
slMode = input.string("Fixed % - نسبة ثابتة %", "Stop Loss - وقف الخسارة",
     options = ["None - لا يوجد", "Fixed % - نسبة ثابتة %", "Trailing % - نسبةالخسارة  المتتبّعة %", "ATR Trailing - المتتبّع ATR حسب"], group = "SHARED INPUTS — مدخلات مشتركة",
     tooltip = "Selects one stop-loss method: Fixed % of entry price, Trailing % running highest high since entry (lowest low for shorts), ATR " +
     "Trailing, or None. 'None' disables the protective stop." +
     "\n\n" +
     "يحدد طريقة واحدة لوقف الخسارة: نسبة ثابتة من سعر الدخول، نسبة وقف " +
     "الخسارة المتتبّع أعلى سعر منذ الدخول (أدنى سعر منذ الدخول عند البيع على المكشوف)، وقف خسارة متتبّع وفق (إيه تي آر)، " +
     "أو لا يوجد. يؤدي اختيار 'لا يوجد' إلى تعطيل وقف الخسارة الوقائي")

slValue = input.float(2.0, "Stop Loss Value — قيمة وقف الخسارة ", minval = 0.0000001, step = 0.1,
     group = "SHARED INPUTS — مدخلات مشتركة",
     tooltip = "Value used according to the selected Stop Loss Mode: " +
     "percentage (%) for Fixed %/Trailing %, or ATR multiplier for ATR " +
     "Trailing. Ignored when Stop Loss Mode = None." +
     "\n\n" +
     "تُستخدم القيمة وفقًا لطريقة وقف الخسارة المحددة: نسبة مئوية (%) " +
     "للنسبة الثابتة/نسبة التتبّع، أو معامل " +
     "لوقف الخسارة المتتبّع وفق (إيه تي آر). تُتجاهل عند اختيار لا يوجد")


slAtrPeriod = input.int(14, "ATR Period — ATR فترة مؤشر ", minval = 1, maxval = 100,
     group = "SHARED INPUTS — مدخلات مشتركة",
     tooltip = "Number of bars used to calculate ATR (Average True Range) " +
     "for ATR Trailing stops. Shorter periods react faster to recent " +
     "volatility; longer periods produce a smoother, steadier value. " +
     "Activated only when Stop Loss Mode = ATR Trailing." +
     "\n\n" +
     "عدد الشموع المستخدمة لحساب  (متوسط المدى الحقيقي) لوقف الخسارة " +
     "المتتبّع وفق (أي تي أر). الفترات الأقصر تستجيب بسرعة أكبر " +
     "للتقلبات الأخيرة، بينما الفترات الأطول تعطي قيمة أكثر سلاسة وثباتًا. " +
     "يُفعّل فقط عند اختيار طريقة وقف الخسارة = وقف الخسارة المتتبّع وفق (أي تي أر)")

// Display-only: toggles the live SL line plot without affecting the SL
// calculation or execution. Default OFF — the line does not render unless
// the user enables it in settings.
showSLLine = input.bool(false, "Show Stop-Loss Line — عرض خط وقف الخسارة",
     group = "SHARED INPUTS — مدخلات مشتركة",
     tooltip = "The red line traces the live stop-loss level while a trade " +
     "is open, so at a glance it is visible where the strategy will exit if price " +
     "moves against the trade. It's flat under Fixed % because the stop is set once " +
     "from the entry price and never moves. Under Trailing %/ATR Trailing, it steps " +
     "upward (for longs) or downward (for shorts)." +
     "\n\n" +
     "الخط الأحمر يتتبّع مستوى وقف الخسارة الفعلي طوال فترة بقاء الصفقة مفتوحة، " +
     "بحيث يمكن رؤية مستوى الخروج الذي ستعتمده الاستراتيجية فورًا إذا تحرك السعر " +
     "عكس اتجاه الصفقة. يكون الخط ثابتًا وأفقيًا في حالة نسبة ثابتة %، لأن وقف " +
     "الخسارة يُحدَّد مرة واحدة انطلاقًا من سعر الدخول ولا يتحرك بعد ذلك. أما في " +
     "حالتي نسبة الخسارة المتتبّعة (أي تي أر) ونسبة الخسارة المتتبّعة %، فيتحرك الخط " +
     "تدريجيًا إلى أعلى في صفقات الشراء أو للأسفل في صفقات البيع")

// Exit on opposite signal is unconditional (no toggle): enter on signal,
// exit on opposite signal (or SL). With Trade Direction = Long & Short this
// produces an immediate same-bar close-then-flip. Fires on any enabled
// module's opposite-direction signal.

confirmationBars = input.int(1, "Confirmation Bars  — شموع التأكيد ", minval = 1,
     group = "SHARED INPUTS — مدخلات مشتركة",
     tooltip = "Number of consecutive bars the signal must hold before it " +
     "fires. Applies to all three modules. Set to 1 for no added delay to " +
     "signal execution." +
     "\n\n" +
     "عدد الشموع المتتالية التي يجب أن تستمر فيها الإشارة قبل تفعيلها. " +
     "ينطبق على المؤشرات الثلاث جميعها. اضبطها على 1 لعدم إضافة أي تأخير " +
     "في تنفيذ أوامر التداول للإشارة")

// Display toggle
showConfigTable = input.bool(true, "Show Indicator Settings Table — عرض جدول اعدادات المؤشر", group = "DISPLAY TABLE — جدول العرض")

tableThemeColor = input.string("Blue - أزرق", "Table Theme Color — لون الجدول",
     options = ["Blue - أزرق", "Teal - أخضر", "Brown - بني", "Dark Theme - الوضع الداكن"],
     group = "DISPLAY TABLE — جدول العرض")

// -----------------------------------------------------------------------------
// Stable English-only keys for bilingual dropdowns.
//
// Every dropdown below uses bilingual "English - Arabic" option strings,
// since Pine dropdown labels are static and can't switch with langChoice on
// their own. f_key() extracts only the English half (the portion before
// " - "), which is stable across translation edits. Every LOGIC-branching
// comparison is done against a `*Key` variable and a plain English literal —
// never against the raw bilingual variable directly. The raw bilingual
// variables are still used wherever the full bilingual text needs to be
// DISPLAYED (Indicator Settings Table cells via f_val()).
// -----------------------------------------------------------------------------
f_key(s) =>
    parts = str.split(s, " - ")
    array.size(parts) > 0 ? str.trim(array.get(parts, 0)) : s

tradeDirectionKey = f_key(tradeDirection)
slModeKey = f_key(slMode)
tableThemeColorKey = f_key(tableThemeColor)

// -----------------------------------------------------------------------------
// Indicator selection — drives Pine v6's active= parameter on each
// indicator's own inputs (dims the inactive indicator's inputs).
// -----------------------------------------------------------------------------
enableRSI   = input.bool(true,  "RSI - مؤشر القوة النسبية",                         group = "INDICATOR SELECTION — اختيار المؤشرات")
enableMA    = input.bool(false, "MA - المتوسط المتحرك",                              group = "INDICATOR SELECTION — اختيار المؤشرات")
enableMACD  = input.bool(false, "MACD - تقارب وتباعد المتوسطات المتحركة",            group = "INDICATOR SELECTION — اختيار المؤشرات")

combinationLogic = input.string("AND - و", "Combination logic (AND/OR) — منهج دمج المؤشرات (و/أو)",
     options = ["AND - و", "OR - أو"], group = "INDICATOR COMBINATION LOGIC — منهج المؤشرات المشتركة",
     tooltip = "AND: all enabled indicators must agree. " +
     "OR: any enabled indicator can trigger an entry. " +
     "Applies to entries only; opposite-signal exits " +
     "always trigger from any enabled module." +
     "\n\n" +
     "و: يجب أن تتفق جميع المؤشرات المفعّلة. " +
     "أو: يمكن لأي مؤشر مفعّل تفعيل الدخول. " +
     "ينطبق على الدخول فقط؛ أما الخروج عند الإشارة المعاكسة " +
     " فيتم تفعيله دائمًا من أي مؤشر مفعّل")
combinationLogicKey = f_key(combinationLogic)

// -----------------------------------------------------------------------------
// Noise Filter Engine (shared across RSI, MA, MACD modules)
//
// f_confirmSignal(cond, confirmBars): fires exactly once, on the Nth
// consecutive bar `cond` has held true. Resets to 0 the instant `cond` goes
// false. With confirmBars = 1, fires on the same bar `cond` first becomes
// true (no added delay).
//
// f_crossoverThresholdPass(excursion, band): generic "is this excursion
// beyond the crossover threshold" check. `excursion` is module-specific (MA
// separation %, MACD histogram price units), computed by each module before
// being passed in. Not used by RSI, which has its own Low/High thresholds.
// -----------------------------------------------------------------------------
f_confirmSignal(cond, confirmBars) =>
    var int count = 0
    count := cond ? count + 1 : 0
    count == confirmBars

f_crossoverThresholdPass(excursion, band) =>
    excursion >= band

// Shared moving-average dispatcher, reused by MA Crossover and MACD.
f_ma(src, len, maType) =>
    switch maType
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        "HMA" => ta.hma(src, len)
        "RMA" => ta.rma(src, len)
        => ta.ema(src, len)

// Maps the bilingual Source dropdown (Open/High/Low/Close) to the OHLC
// price series. Used instead of input.source(), whose native dropdown
// labels can't be translated.
f_src(choice) =>
    switch f_key(choice)
        "Open"  => open
        "High"  => high
        "Low"   => low
        "Close" => close
        => close

// -----------------------------------------------------------------------------
// RSI Indicator
// -----------------------------------------------------------------------------
RSI_GROUP = "RSI Indicator — مؤشر القوة النسبية"

rsiLength = input.int(14, "RSI length — فترة المؤشر", minval = 2, group = RSI_GROUP,
     active = enableRSI)
rsiSourceChoice = input.string("Close - الإغلاق", "Price Source — مصدر الأسعار ",
     options = ["Open - الافتتاح", "High - الأعلى", "Low - الأدنى", "Close - الإغلاق"],
     group = RSI_GROUP, active = enableRSI)
rsiSource = f_src(rsiSourceChoice)
rsiLowThreshold = input.float(30.0, "Low threshold — الحد الأدنى", minval = 0.0, maxval = 100.0,
     group = RSI_GROUP, active = enableRSI)
rsiHighThreshold = input.float(70.0, "High threshold — الحد الأعلى", minval = 0.0, maxval = 100.0,
     group = RSI_GROUP, active = enableRSI)
rsiSignalLogic = input.string("Threshold Breach - اختراق الحد", "Signal logic — منهج إشارة التداول",
     options = ["Threshold Breach - اختراق الحد", "Breach-then-Cross-Back - اختراق ثم عودة"],
     group = RSI_GROUP, active = enableRSI,
     tooltip = "Threshold Breach: signals when RSI breaches the threshold. " +
     "Breach-then-cross-back: signals when RSI breaches the threshold " +
     "and then crosses back to the other side." +
     "\n\n" +
     "اختراق الحد: تصدر الإشارة عند اختراق المؤشر للحد. " +
     "الاختراق ثم العودة: تصدر الإشارة عند اختراق المؤشر للحد " +
     "ثم عبوره مجددًا إلى الجهة الأخرى")
rsiSignalLogicKey = f_key(rsiSignalLogic)

rsiValue = ta.rsi(rsiSource, rsiLength)

// Mode 1: Threshold Breach — qualifying condition is a persistent state. At
// confirmation bars = 1, fires on the same bar RSI first goes beyond the
// threshold, functionally equivalent to a cross.
rsiBreachLongRaw  = rsiValue < rsiLowThreshold
rsiBreachShortRaw = rsiValue > rsiHighThreshold

// Mode 2: Breach-then-Cross-Back — tracks whether RSI has genuinely
// breached the threshold since the last cross-back, then fires on the
// cross-back event itself; the flag resets on fire so the next signal
// requires a fresh breach first.
var bool rsiWasBelowLow  = false
var bool rsiWasAboveHigh = false
if rsiValue < rsiLowThreshold
    rsiWasBelowLow := true
if rsiValue > rsiHighThreshold
    rsiWasAboveHigh := true
rsiCrossUpEvent   = ta.crossover(rsiValue, rsiLowThreshold)
rsiCrossDownEvent = ta.crossunder(rsiValue, rsiHighThreshold)
rsiCrossBackLongRaw  = rsiWasBelowLow  and rsiCrossUpEvent
rsiCrossBackShortRaw = rsiWasAboveHigh and rsiCrossDownEvent
if rsiCrossBackLongRaw
    rsiWasBelowLow := false
if rsiCrossBackShortRaw
    rsiWasAboveHigh := false

rsiLongRaw = rsiSignalLogicKey == "Threshold Breach" ? rsiBreachLongRaw : rsiCrossBackLongRaw
rsiShortRaw = rsiSignalLogicKey == "Threshold Breach" ? rsiBreachShortRaw : rsiCrossBackShortRaw

rsiLongSignal  = f_confirmSignal(rsiLongRaw,  confirmationBars)
rsiShortSignal = f_confirmSignal(rsiShortRaw, confirmationBars)

// -----------------------------------------------------------------------------
// MA Crossover Indicator
//
// Both modes are implemented as a persistent qualifying state fed through
// f_confirmSignal(), rather than a one-bar ta.crossover()/ta.crossunder()
// pulse. This makes the crossover threshold meaningful (a momentary cross
// has ~zero excursion at the instant it fires) and keeps confirmation-bar
// semantics identical across all three modules.
// -----------------------------------------------------------------------------
// Pine v6: `active=` requires an input-qualified expression, and calling a
// user-defined function (e.g. f_key()) downgrades the result to `series`,
// so it can't be used inside active=. The bilingual option literal is
// therefore declared once as a plain constant here for the active=
// comparisons, while real logic branches still go through f_key().
MA_CROSSOVER_OPT = "MA Crossover - تقاطع المتوسط المتحرك"
MA_GROUP = "MA Indicator — مؤشر المتوسط المتحرك"

maSignalLogic = input.string(MA_CROSSOVER_OPT, "Signal logic — منهج إشارة التداول",
     options = [MA_CROSSOVER_OPT, "Price–MA Crossover - تقاطع السعر مع المتوسط المتحرك"],
     group = MA_GROUP, active = enableMA)
maSignalLogicKey = f_key(maSignalLogic)
maType = input.string("EMA", "MA type — نوع المتوسط المتحرك", options = ["SMA", "EMA", "WMA", "HMA", "RMA"],
     group = MA_GROUP, active = enableMA)
maSourceChoice = input.string("Close - الإغلاق", "Price Source — مصدر الأسعار",
     options = ["Open - الافتتاح", "High - الأعلى", "Low - الأدنى", "Close - الإغلاق"],
     group = MA_GROUP, active = enableMA)
maSource = f_src(maSourceChoice)
maFastLength = input.int(9, "Fast MA length — طول المتوسط المتحرك السريع", minval = 2, group = MA_GROUP,
     active = enableMA and maSignalLogic == MA_CROSSOVER_OPT,
     tooltip = "Active only when Signal logic = MA Crossover." +
     "\n\n" +
     "يُفعّل فقط عند اختيار منهج الإشارة = تقاطع المتوسط المتحرك")
maSlowLength = input.int(21, "Slow MA length — طول المتوسط المتحرك البطيء", minval = 2, group = MA_GROUP,
     active = enableMA and maSignalLogic == MA_CROSSOVER_OPT,
     tooltip = "Active only when Signal logic = MA Crossover." +
     "\n\n" +
     "يُفعّل فقط عند اختيار منهج الإشارة = تقاطع المتوسط المتحرك")
maSingleLength = input.int(20, "MA length — طول المتوسط المتحرك", minval = 2, group = MA_GROUP,
     active = enableMA and maSignalLogic != MA_CROSSOVER_OPT,
     tooltip = "Active only when Signal logic = Price–MA " +
     "Crossover (replaces the fast/slow pair)." +
     "\n\n" +
     "يُفعّل فقط عند اختيار منهج الإشارة = تقاطع السعر مع المتوسط المتحرك " +
     "(ويستبدل ثنائي المتوسطات السريع والبطيء)")
maCrossoverThreshold = input.float(0.0, "Crossover Threshold (%) — (%) الحد الأدنى للتقاطع", minval = 0.0,
     group = MA_GROUP, active = enableMA,
     tooltip = "In  MA Crossover mode, sets the minimum % separation between the two MAs. " +
     "In Price–MA  Crossover mode, sets the minimum % distance between price and the MA. " +
     "This setting applies to both modes." +
     "\n\n" +
     "في نمط تقاطع  المتوسطات، يحدد الحد الأدنى لنسبة % الفاصلة بين المتوسطين. " +
     "في نمط  تقاطع السعر مع المتوسط، يحدد الحد الأدنى لنسبة % المسافة بين السعر والمتوسط المتحرك. " +
     "ينطبق هذا الإعداد على كلا النمطين")

maFastMA = f_ma(maSource, maFastLength, maType)
maSlowMA = f_ma(maSource, maSlowLength, maType)
maSingle = f_ma(maSource, maSingleLength, maType)

// Mode 1: MA Crossover — "arm-then-persist" design. A genuine
// ta.crossover()/ta.crossunder() EVENT must occur first to "arm" a
// direction (this can never fire on the first-ready bar, since crossover/
// crossunder need a defined previous bar to compare against). Once armed,
// the direction stays armed (persistent) until the opposite event re-arms
// the other side, so the crossover threshold and Confirmation bars > 1
// still have a genuine ongoing state to measure.
maSepPct = maSlowMA != 0 ? math.abs(maFastMA - maSlowMA) / maSlowMA * 100 : 0.0

maCrossUpEvent   = ta.crossover(maFastMA, maSlowMA)
maCrossDownEvent = ta.crossunder(maFastMA, maSlowMA)

var bool maLongArmed  = false
var bool maShortArmed = false
if maCrossUpEvent
    maLongArmed  := true
    maShortArmed := false
if maCrossDownEvent
    maShortArmed := true
    maLongArmed  := false

maCrossLongRaw  = maLongArmed  and maFastMA > maSlowMA and f_crossoverThresholdPass(maSepPct, maCrossoverThreshold)
maCrossShortRaw = maShortArmed and maFastMA < maSlowMA and f_crossoverThresholdPass(maSepPct, maCrossoverThreshold)

// Mode 2: Price–MA Crossover — persistent state: price beyond MA by >= band%
maDistPct = maSingle != 0 ? math.abs(maSource - maSingle) / maSingle * 100 : 0.0
maPriceCrossLongRaw  = maSource > maSingle and f_crossoverThresholdPass(maDistPct, maCrossoverThreshold)
maPriceCrossShortRaw = maSource < maSingle and f_crossoverThresholdPass(maDistPct, maCrossoverThreshold)

maLongRaw = maSignalLogicKey == "MA Crossover" ? maCrossLongRaw : maPriceCrossLongRaw
maShortRaw = maSignalLogicKey == "MA Crossover" ? maCrossShortRaw : maPriceCrossShortRaw

maLongSignal  = f_confirmSignal(maLongRaw,  confirmationBars)
maShortSignal = f_confirmSignal(maShortRaw, confirmationBars)

// -----------------------------------------------------------------------------
// MACD Indicator
//
// Same design as MA Crossover above: modes 1 and 2 use a persistent
// qualifying state (fed through f_confirmSignal) rather than a literal
// one-bar cross, so the crossover threshold is meaningful for both.
// -----------------------------------------------------------------------------
MACD_GROUP = "MACD Indicator — مؤشر التقارب والتباعد للمتوسطات المتحركة"

macdFastLength = input.int(12, "Fast MA length — طول المتوسط المتحرك السريع", minval = 1, group = MACD_GROUP,
     active = enableMACD)
macdSlowLength = input.int(26, "Slow MA length — طول المتوسط المتحرك البطيء", minval = 1, group = MACD_GROUP,
     active = enableMACD)
macdSignalLength = input.int(9, "Signal MA length — طول متوسط متحرك الإشارة", minval = 1, group = MACD_GROUP,
     active = enableMACD)
macdMaType = input.string("EMA", "MA type: EMA (default) / MACD Variant — نوع المتوسط المتحرك",
     options = ["EMA", "SMA", "WMA", "HMA", "RMA"], group = MACD_GROUP,
     active = enableMACD,
     tooltip = "Applies to fast, slow, and signal smoothing uniformly. EMA is " +
     "standard MACD; any other selection is a MACD variant" +
     "\n\n" +
     "يُطبّق على المتوسط السريع و البطيء و الإشارة. المتوسط " +
     "(اي ام اى) هو القياسي في حساب مؤشر التقارب والتباعد للمتوسطات المتحركة ؛ " +
     "وأي اختيار آخر يُعد نسخة مختلفة")
macdSourceChoice = input.string("Close - الإغلاق", "Source —  مصدر الأسعار",
     options = ["Open - الافتتاح", "High - الأعلى", "Low - الأدنى", "Close - الإغلاق"],
     group = MACD_GROUP, active = enableMACD)
macdSource = f_src(macdSourceChoice)
macdSignalLogic = input.string("MACD/Signal Crossover - تقاطع المؤشر مع خط الإشارة", "Signal logic — منهج إشارة التداول",
     options = ["MACD/Signal Crossover - تقاطع المؤشر مع خط الإشارة", "Zero-Line Crossover - تقاطع خط الصفر"],
     group = MACD_GROUP, active = enableMACD)
macdSignalLogicKey = f_key(macdSignalLogic)
macdCrossoverThreshold = input.float(0.0, "Crossover Threshold (histogram, price units) — الحد الأدنى (أعمدة المؤشر، وحدات السعر)",
     minval = 0.0, group = MACD_GROUP, active = enableMACD,
     tooltip = "In MACD/Signal Crossover mode, sets the minimum histogram magnitude " +
     "in price units required for a crossover to qualify. In Zero-Line Crossover mode, " +
     "sets the minimum MACD-line distance from zero in price units required to qualify. " +
     "This setting applies to both modes." +
     "\n\n" +
     "في نمط تقاطع المؤشر مع خط الإشارة، يحدد الحد الأدنى لقيمة أعمدة المؤشر " +
     "بوحدات السعر المطلوبة لاعتبار التقاطع صحيحا. في نمط تقاطع خط الصفر، " +
     "يحدد الحد الأدنى لمسافة خط المؤشر عن الصفر بوحدات السعر المطلوبة لاعتبار التقاطع صحيحا. " +
     "ينطبق هذا الإعداد على كلا النمطين")

macdFastMA   = f_ma(macdSource, macdFastLength, macdMaType)
macdSlowMA   = f_ma(macdSource, macdSlowLength, macdMaType)
macdLine     = macdFastMA - macdSlowMA
macdSignal   = f_ma(macdLine, macdSignalLength, macdMaType)
macdHist     = macdLine - macdSignal

// Mode 1: MACD/Signal Crossover — "arm-then-persist" (same reasoning as MA
// Module Mode 1). A genuine ta.crossover()/ta.crossunder() EVENT on
// (macdLine, macdSignal) arms a direction; once armed it stays armed
// (persistent) until re-armed the other way.
macdCrossUpEvent   = ta.crossover(macdLine, macdSignal)
macdCrossDownEvent = ta.crossunder(macdLine, macdSignal)

var bool macdCrossLongArmed  = false
var bool macdCrossShortArmed = false
if macdCrossUpEvent
    macdCrossLongArmed  := true
    macdCrossShortArmed := false
if macdCrossDownEvent
    macdCrossShortArmed := true
    macdCrossLongArmed  := false

macdCrossLongRaw  = macdCrossLongArmed  and macdLine > macdSignal and f_crossoverThresholdPass(math.abs(macdHist), macdCrossoverThreshold)
macdCrossShortRaw = macdCrossShortArmed and macdLine < macdSignal and f_crossoverThresholdPass(math.abs(macdHist), macdCrossoverThreshold)

// Mode 2: Zero-Line Crossover — same "arm-then-persist" logic, applied to
// macdLine crossing zero instead of crossing macdSignal. Not routed through
// f_crossoverThresholdPass: this test is direction-signed (macdLine vs.
// +threshold for longs, vs. -threshold for shorts), not the unsigned
// "excursion >= band" pattern that function encodes.
macdZeroUpEvent   = ta.crossover(macdLine, 0)
macdZeroDownEvent = ta.crossunder(macdLine, 0)

var bool macdZeroLongArmed  = false
var bool macdZeroShortArmed = false
if macdZeroUpEvent
    macdZeroLongArmed  := true
    macdZeroShortArmed := false
if macdZeroDownEvent
    macdZeroShortArmed := true
    macdZeroLongArmed  := false

macdZeroLongRaw  = macdZeroLongArmed  and macdLine > macdCrossoverThreshold
macdZeroShortRaw = macdZeroShortArmed and macdLine < -macdCrossoverThreshold

macdLongRaw = macdSignalLogicKey == "MACD/Signal Crossover" ? macdCrossLongRaw : macdZeroLongRaw
macdShortRaw = macdSignalLogicKey == "MACD/Signal Crossover" ? macdCrossShortRaw : macdZeroShortRaw

macdLongSignal  = f_confirmSignal(macdLongRaw,  confirmationBars)
macdShortSignal = f_confirmSignal(macdShortRaw, confirmationBars)

// -----------------------------------------------------------------------------
// Parameter validation (Pine input minval/maxval already narrows most of
// this; re-check cross-field constraints here)
// -----------------------------------------------------------------------------
if barstate.islast
    if not enableRSI and not enableMA and not enableMACD
        runtime.error("At least one indicator (RSI, MA Crossover, MACD) must be enabled.")
    if enableRSI and rsiHighThreshold <= rsiLowThreshold
        runtime.error("RSI: High threshold must be greater than Low threshold.")
    if enableMA and maSignalLogicKey == "MA Crossover" and maSlowLength <= maFastLength
        runtime.error("MA: Slow MA length must be greater than Fast MA length.")
    if enableMACD and macdSlowLength <= macdFastLength
        runtime.error("MACD: Slow length must be greater than Fast length.")

// Signal timing (fixed behavior, no toggle): signals generated at bar close,
// executed at next bar open — Pine's default with calc_on_every_tick = false.

// -----------------------------------------------------------------------------
// Per-module warm-up gate — a data-readiness check, not a fixed bar count.
// ta.rsi(), ta.sma/ema/wma/hma/rma(), and the MACD line/signal all return na
// until they have enough bars behind them to produce a real value — that's
// the ground truth for "is this module ready," rather than estimating a
// convergence buffer, since the right cutoff varies by symbol, timeframe,
// and how far back the chart's data goes.
// -----------------------------------------------------------------------------
rsiModuleReady  = not na(rsiValue)
maModuleReady   = maSignalLogicKey == "MA Crossover" ? (not na(maFastMA) and not na(maSlowMA)) : not na(maSingle)
macdModuleReady = not na(macdSignal)

warmupOk = (not enableRSI  or rsiModuleReady) and
     (not enableMA   or maModuleReady) and
     (not enableMACD or macdModuleReady)

// -----------------------------------------------------------------------------
// AND/OR entry-combination logic. AND requires every currently-ENABLED
// module to agree on the same bar to open a trade; OR requires just one.
// With only one module enabled, both settings are equivalent.
//
// longSignalAny/shortSignalAny ("any enabled module") and longCombined/
// shortCombined ("AND/OR of enabled modules") are both computed here.
// Entries always use the combined condition. Exit-on-opposite-signal always
// uses the permissive "any module" condition — Combination logic scope is
// fixed to Entry only and never gates exits.
// -----------------------------------------------------------------------------
allowLong  = tradeDirectionKey != "Short only"
allowShort = tradeDirectionKey != "Long only"

enabledModuleCount = (enableRSI ? 1 : 0) + (enableMA ? 1 : 0) + (enableMACD ? 1 : 0)
longTrueCount  = (enableRSI and rsiLongSignal  ? 1 : 0) + (enableMA and maLongSignal  ? 1 : 0) + (enableMACD and macdLongSignal  ? 1 : 0)
shortTrueCount = (enableRSI and rsiShortSignal ? 1 : 0) + (enableMA and maShortSignal ? 1 : 0) + (enableMACD and macdShortSignal ? 1 : 0)

longSignalAny  = longTrueCount  > 0
shortSignalAny = shortTrueCount > 0

longCombined  = combinationLogicKey == "AND" ? (enabledModuleCount > 0 and longTrueCount  == enabledModuleCount) : longSignalAny
shortCombined = combinationLogicKey == "AND" ? (enabledModuleCount > 0 and shortTrueCount == enabledModuleCount) : shortSignalAny

// -----------------------------------------------------------------------------
// Exit on opposite signal (unconditional), with Exit Precedence: the
// strategy.close() calls fire before entries, so a same-bar close-then-flip
// (Trade direction = Long & Short) works correctly. There is no time-based
// exit, so no conflict between exit types can occur.
// -----------------------------------------------------------------------------
oppositeSignalCloseLong  = strategy.position_size > 0 and shortSignalAny
oppositeSignalCloseShort = strategy.position_size < 0 and longSignalAny

if oppositeSignalCloseLong
    strategy.close("Long", comment = "Close Long")

if oppositeSignalCloseShort
    strategy.close("Short", comment = "Close Short")

if warmupOk
    if allowLong and longCombined
        strategy.entry("Long", strategy.long)
    if allowShort and shortCombined
        strategy.entry("Short", strategy.short)

// -----------------------------------------------------------------------------
// SL Execution Model
//
// All three SL modes converge on ONE mechanism: a candidate stop price is
// computed every bar, ratcheted against the previously stored stop
// (favorable direction only — math.max for longs, math.min for shorts), and
// resubmitted as an absolute stop= price via strategy.exit(). Fixed % never
// moves since its candidate is constant per trade (entry price never
// changes), so no separate code path is needed for it.
//
// Entries use generic "Long"/"Short" IDs regardless of which module
// triggered them, so this single SL block correctly governs the net
// position no matter which module (or combination) opened it.
//
// Note: pyramiding = 0 and pyramiding = 1 are functionally identical — both
// allow exactly one open entry per direction, with no stacking. Net
// position size stays exactly 1 unit at all times.
// -----------------------------------------------------------------------------
atrValue = ta.atr(slAtrPeriod)

// Running highest-high / lowest-low since entry (anchor for both trailing
// modes; computed but unused by Fixed %).
var float longHighestSinceEntry = na
if strategy.position_size > 0
    longHighestSinceEntry := strategy.position_size[1] <= 0 ? high : math.max(longHighestSinceEntry, high)
else
    longHighestSinceEntry := na

var float shortLowestSinceEntry = na
if strategy.position_size < 0
    shortLowestSinceEntry := strategy.position_size[1] >= 0 ? low : math.min(shortLowestSinceEntry, low)
else
    shortLowestSinceEntry := na

// Candidate SL price for the currently selected mode ("None" -> na, so no
// stop order gets submitted at all).
slCandidateLong = slModeKey == "None" ? na :
     slModeKey == "Fixed %" ? strategy.position_avg_price * (1 - slValue / 100) :
     slModeKey == "Trailing %" ? longHighestSinceEntry * (1 - slValue / 100) :
     longHighestSinceEntry - atrValue * slValue
slCandidateShort = slModeKey == "None" ? na :
     slModeKey == "Fixed %" ? strategy.position_avg_price * (1 + slValue / 100) :
     slModeKey == "Trailing %" ? shortLowestSinceEntry * (1 + slValue / 100) :
     shortLowestSinceEntry + atrValue * slValue

// Ratchet: only moves in the favorable direction, never loosens, since
// stop= overwrites rather than auto-ratcheting the way trail_points/
// trail_offset would. When SL mode = None, longStopPrice/shortStopPrice
// stay na for the whole trade, so strategy.exit() below submits no order.
var float longStopPrice = na
if strategy.position_size > 0 and slModeKey != "None"
    longStopPrice := strategy.position_size[1] <= 0 ? slCandidateLong : math.max(longStopPrice, slCandidateLong)
else
    longStopPrice := na

var float shortStopPrice = na
if strategy.position_size < 0 and slModeKey != "None"
    shortStopPrice := strategy.position_size[1] >= 0 ? slCandidateShort : math.min(shortStopPrice, slCandidateShort)
else
    shortStopPrice := na

// Submit / update the native broker SL order. Re-submitted every bar so the
// stop's current (ratcheted) price stays live.
if strategy.position_size > 0 and not na(longStopPrice)
    strategy.exit("Close Long-SL", from_entry = "Long", stop = longStopPrice)
if strategy.position_size < 0 and not na(shortStopPrice)
    strategy.exit("Close Short-SL", from_entry = "Short", stop = shortStopPrice)

// Visual confirmation of the current SL level — plot breaks (no connecting
// line) whenever the value is na, so SL mode = None shows no line at all.
plot(showSLLine and strategy.position_size > 0 ? longStopPrice : na, title = "Long SL Level",
     color = color.red, style = plot.style_linebr, linewidth = 1)
plot(showSLLine and strategy.position_size < 0 ? shortStopPrice : na, title = "Short SL Level",
     color = color.red, style = plot.style_linebr, linewidth = 1)

// =============================================================================
// On-Chart Displays
// =============================================================================

// -----------------------------------------------------------------------------
// Bilingual label lookup. Arabic keeps standard technical abbreviations
// (RSI, MA, MACD, ATR, SL) in Latin script rather than transliterating
// them, matching how these terms are conventionally written in
// Arabic-language trading content.
//
// Scope: this covers row LABELS (column 0 of the Indicator Settings Table)
// only. Row VALUES (column 1) — tradeDirection, combinationLogic, slMode,
// and each module's Signal logic — are whatever string the corresponding
// input.string() option returns, which is always English regardless of
// langChoice, since Pine input dropdowns can't return a language-dependent
// value; f_val() below handles the English/Arabic split for those.
// -----------------------------------------------------------------------------
f_lbl(key) =>
    var string result = na
    if langChoice == "العربية"
        result := switch key
            "config_title"   => "إعدادات المؤشر"
            "lang"            => "اللغة"
            "direction"       => "اتجاه التداول"
            "combo"           => "منهج دمج المؤشرات"
            "sl_mode"         => "وضع وقف الخسارة"
            "sl_value"        => "قيمة وقف الخسارة"
            "atr_period"      => "فترة ATR"
            "confirm_bars"    => "شموع التأكيد"
            "rsi_module"      => "مؤشر RSI"
            "ma_module"       => "مؤشر المتوسط المتحرك MA"
            "macd_module"     => "مؤشر MACD"
            "inactive"        => "(غير مفعل)"
            "combo_quality"   => "تقييم دمج المؤشرات"
            => key
    else
        result := switch key
            "config_title"   => "Indicator Settings"
            "lang"            => "Language"
            "direction"       => "Trade direction"
            "combo"           => "Combination logic"
            "sl_mode"         => "SL mode"
            "sl_value"        => "SL value"
            "atr_period"      => "ATR Period"
            "confirm_bars"    => "Confirmation bars"
            "rsi_module"      => "RSI Indicator"
            "ma_module"       => "MA Indicator"
            "macd_module"     => "MACD Indicator"
            "inactive"        => "(inactive)"
            "combo_quality"   => "Combination Assessment"
            => key
    result

// -----------------------------------------------------------------------------
// Bilingual VALUE lookup — companion to f_lbl() for column 1 of the Config
// Summary Table. Every dropdown value is already an "English - Arabic"
// string, so this picks the half matching langChoice, keeping the table
// single-language even though the settings panel always shows both. Falls
// through to the original string unchanged if there's no " - " separator.
//
// f_val() is DISPLAY-only (renders whichever half matches the active
// language). f_key() is LOGIC-only (always the English half, for stable
// comparisons). The two are not interchangeable.
// -----------------------------------------------------------------------------
f_val(val) =>
    parts = str.split(val, " - ")
    var string result = na
    if array.size(parts) > 1
        result := langChoice == "العربية" ? array.get(parts, 1) : array.get(parts, 0)
    else
        result := val
    result

// -----------------------------------------------------------------------------
// Combination Assessment classifier — labels every possible Indicator
// Selection + Combination Logic state.
//
// RSI is mean-reversion (fires on oversold/overbought) while MA and MACD
// are both trend-following, and MACD is mathematically derived from moving
// averages, so it is highly correlated with the MA module regardless of
// sub-mode. Resolved at per-sub-mode granularity since RSI's two modes
// differ in confirmation strength, and MA/MACD's mode combinations differ
// in how correlated they are:
//   0 enabled  -> blocked by runtime.error() above, never reaches this code
//   1 enabled  -> SINGLE            (no combination logic in play)
//   2 enabled  -> per pair + per sub-mode + AND/OR (see below)
//   3 enabled  -> NOT_RECOMMENDED   (over-constrained under AND, noisy/
//                                    inconsistent under OR)
// -----------------------------------------------------------------------------
f_comboDetailKey() =>
    string result = "NA"
    if enabledModuleCount == 1
        result := "SINGLE"
    else if enabledModuleCount == 3
        result := "NOT_RECOMMENDED"
    else if enabledModuleCount == 2
        if enableRSI and enableMA
            rMode = rsiSignalLogicKey == "Threshold Breach" ? "R1" : "R2"
            if combinationLogicKey == "AND"
                result := rMode == "R1" ? "VALID_MODERATE" : "VALID_STRONG"
            else
                result := "WEAK"
        else if enableRSI and enableMACD
            rMode = rsiSignalLogicKey == "Threshold Breach" ? "R1" : "R2"
            if combinationLogicKey == "AND"
                result := rMode == "R1" ? "VALID_MODERATE" : "VALID_STRONG"
            else
                result := "WEAK"
        else if enableMA and enableMACD
            mMode = maSignalLogicKey   == "MA Crossover"          ? "M1" : "M2"
            dMode = macdSignalLogicKey == "MACD/Signal Crossover" ? "D1" : "D2"
            // Category folded directly into the key here since Pine v6's
            // switch statement does not support comma-separated
            // multi-value case arms.
            if mMode == "M1" and dMode == "D2"
                result := combinationLogicKey == "AND" ? "REDUND_STRICT_NEARDUP" : "REDUND_NOTHING_NEARDUP"
            else if mMode == "M1" and dMode == "D1"
                result := combinationLogicKey == "AND" ? "REDUND_STRICT_HIGH" : "REDUND_NOTHING_HIGH"
            else
                result := combinationLogicKey == "AND" ? "REDUND_STRICT_MOD" : "REDUND_NOTHING_MOD"
    result

f_comboDetailText(key) =>
    var string result = na
    if langChoice == "العربية"
        result := switch key
            "SINGLE"                 => "لا يوجد"
            "NOT_RECOMMENDED"        => "⚠️ تنبيه — دمج ثلاثي"
            "VALID_MODERATE"         => "✅ إيجابي — تلاقٍ متوسط"
            "VALID_STRONG"           => "✅ إيجابي — تلاقٍ قوي"
            "WEAK"                   => "⚠️ تلاقٍ ضعيف — إشارات مختلطة"
            "REDUND_STRICT_NEARDUP"  => "⚠️ تنبيه — تقييد زائد (شبه مطابق)"
            "REDUND_NOTHING_NEARDUP" => "⚠️ احتمال تكرار — تداخل شبه مطابق"
            "REDUND_STRICT_HIGH"     => "⚠️ تنبيه — تقييد زائد (ارتباط مرتفع)"
            "REDUND_NOTHING_HIGH"    => "⚠️ احتمال تكرار — تداخل مرتفع"
            "REDUND_STRICT_MOD"      => "⚠️ تنبيه — تقييد زائد (ارتباط متوسط)"
            "REDUND_NOTHING_MOD"     => "⚠️ احتمال تكرار — تداخل متوسط"
            => "— لم يتم اختيار أي مؤشر"
    else
        result := switch key
            "SINGLE"                 => "None"
            "NOT_RECOMMENDED"        => "⚠️ Caution — Triple Combination"
            "VALID_MODERATE"         => "✅ Favorable — Moderate Confluence"
            "VALID_STRONG"           => "✅ Favorable — Strong Confluence"
            "WEAK"                   => "⚠️ Weak Confluence — Mixed Signals"
            "REDUND_STRICT_NEARDUP"  => "⚠️ Caution — Overly Strict (Near-Duplicate)"
            "REDUND_NOTHING_NEARDUP" => "⚠️ Potential Redundancy — Near-Duplicate Overlap"
            "REDUND_STRICT_HIGH"     => "⚠️ Caution — Overly Strict (High Correlation)"
            "REDUND_NOTHING_HIGH"    => "⚠️ Potential Redundancy — High Overlap"
            "REDUND_STRICT_MOD"      => "⚠️ Caution — Overly Strict (Moderate Correlation)"
            "REDUND_NOTHING_MOD"     => "⚠️ Potential Redundancy — Moderate Overlap"
            => "— No indicator selected"
    result

// Color is theme-aware: a darker, more saturated set for the light-bodyBg
// themes, and a lighter, brighter set for Dark Theme, so contrast holds
// against both light and dark table backgrounds. The "SINGLE" case takes
// the caller's activeColor (the same text color used by every other row in
// the table) rather than a fixed accent, so it never stands out on its own.
f_comboDetailColor(key, isDarkTheme, activeColor) =>
    color result = color.gray
    if isDarkTheme
        result := switch key
            "VALID_MODERATE"         => color.new(#9CCC65, 0)
            "VALID_STRONG"           => color.new(#66BB6A, 0)
            "WEAK"                   => color.new(#FFB74D, 0)
            "REDUND_STRICT_NEARDUP"  => color.new(#D2946B, 0)
            "REDUND_NOTHING_NEARDUP" => color.new(#D2946B, 0)
            "REDUND_STRICT_HIGH"     => color.new(#E0C068, 0)
            "REDUND_NOTHING_HIGH"    => color.new(#E0C068, 0)
            "REDUND_STRICT_MOD"      => color.new(#EAD98A, 0)
            "REDUND_NOTHING_MOD"     => color.new(#EAD98A, 0)
            "SINGLE"                 => activeColor
            "NOT_RECOMMENDED"        => color.new(#EF5350, 0)
            => color.gray
    else
        result := switch key
            "VALID_MODERATE"         => color.new(#558B2F, 0)
            "VALID_STRONG"           => color.new(#2E7D32, 0)
            "WEAK"                   => color.new(#E65100, 0)
            "REDUND_STRICT_NEARDUP"  => color.new(#8B4513, 0)
            "REDUND_NOTHING_NEARDUP" => color.new(#8B4513, 0)
            "REDUND_STRICT_HIGH"     => color.new(#9C7A0A, 0)
            "REDUND_NOTHING_HIGH"    => color.new(#9C7A0A, 0)
            "REDUND_STRICT_MOD"      => color.new(#B8860B, 0)
            "REDUND_NOTHING_MOD"     => color.new(#B8860B, 0)
            "SINGLE"                 => activeColor
            "NOT_RECOMMENDED"        => color.new(#C62828, 0)
            => color.gray
    result

// -----------------------------------------------------------------------------
// Indicator Settings Table — populated live from input values so it can never
// drift out of sync with actual settings. Inactive module rows are dimmed.
// Gated on (barstate.islastconfirmedhistory or barstate.islast) rather than
// barstate.islast alone: with calc_on_every_tick = false, the script does
// not fully re-execute on a still-forming realtime bar until it closes, so
// on an actively trading symbol islastconfirmedhistory guarantees the table
// gets populated at least once per session even while the market is open;
// it then persists (var table) until the next bar close refreshes it.
// -----------------------------------------------------------------------------
var table configTable = table.new(position.top_right, 2, 11,
     border_width = 1, border_color = color.gray, frame_width = 1, frame_color = color.gray)

if (barstate.islastconfirmedhistory or barstate.islast) and showConfigTable
    color headerBg      = switch tableThemeColorKey
        "Teal"       => #164A4A
        "Brown"      => #6B4A2E
        "Dark Theme" => #1E222D
        => color.navy
    color headerText    = switch tableThemeColorKey
        "Dark Theme" => #D9C7A8
        => color.white
    color bodyBg         = switch tableThemeColorKey
        "Teal"       => #F0F7F6
        "Brown"      => #F8F4EF
        "Dark Theme" => #2A2E39
        => #EDF3FB
    color activeColor   = switch tableThemeColorKey
        "Teal"       => #183B3B
        "Brown"      => color.black
        "Dark Theme" => #6ECFC5
        => color.black
    color inactiveColor = color.gray
    table.cell(configTable, 0, 0, f_lbl("config_title"), text_color = headerText, bgcolor = headerBg, text_size = size.normal, text_halign = text.align_center)
    table.cell(configTable, 1, 0, "", bgcolor = headerBg, text_halign = text.align_center)
    table.merge_cells(configTable, 0, 0, 1, 0)
    table.cell(configTable, 0, 1, f_lbl("direction"), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 1, f_val(tradeDirection), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 0, 2, f_lbl("combo"), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 2, f_val(enabledModuleCount <= 1 ? "None - لا يوجد" : combinationLogic), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 0, 3, f_lbl("sl_mode"), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 3, f_val(slMode), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 0, 4, f_lbl("sl_value"), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 4,
         slModeKey == "None" ? "—" :
         slModeKey == "ATR Trailing" ? str.tostring(slValue) + "× ATR" :
         str.tostring(slValue) + "%",
         text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 0, 5, f_lbl("atr_period"), text_color = slModeKey == "ATR Trailing" ? activeColor : inactiveColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 5, slModeKey == "ATR Trailing" ? str.tostring(slAtrPeriod) : "—", text_color = slModeKey == "ATR Trailing" ? activeColor : inactiveColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 0, 6, f_lbl("confirm_bars"), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 6, str.tostring(confirmationBars), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 0, 7, f_lbl("rsi_module"), text_color = enableRSI ? activeColor : inactiveColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 7, enableRSI ? f_val(rsiSignalLogic) : f_lbl("inactive"), text_color = enableRSI ? activeColor : inactiveColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 0, 8, f_lbl("ma_module"), text_color = enableMA ? activeColor : inactiveColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 8, enableMA ? f_val(maSignalLogic) : f_lbl("inactive"), text_color = enableMA ? activeColor : inactiveColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 0, 9, f_lbl("macd_module"), text_color = enableMACD ? activeColor : inactiveColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 9, enableMACD ? f_val(macdSignalLogic) : f_lbl("inactive"), text_color = enableMACD ? activeColor : inactiveColor, bgcolor = bodyBg, text_size = size.normal)
    comboQKey = f_comboDetailKey()
    isDarkTheme = tableThemeColorKey == "Dark Theme"
    table.cell(configTable, 0, 10, f_lbl("combo_quality"), text_color = activeColor, bgcolor = bodyBg, text_size = size.normal)
    table.cell(configTable, 1, 10, f_comboDetailText(comboQKey), text_color = f_comboDetailColor(comboQKey, isDarkTheme, activeColor), bgcolor = bodyBg, text_size = size.normal)
````
