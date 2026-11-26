# Multi-Symbol Volume Anomaly Tape [The_lurker]

- url: https://www.tradingview.com/script/W53rnQU7/
- type: indicator
- pine_id: PUB;caaffb9601b34cf1b5ecfb8f63d323d7
- version: 1.0

## Description

Multi-Symbol Volume Anomaly Tape    شريط شذوذ الحجم متعدّد الرموز

Forty symbols in one live tape, at one-second resolution , It does not show volume. It shows only what is abnormal about it.

⚠ READ FIRST — LIVE MONITOR, NOT A HISTORICAL STUDY

The scan engine runs on the last bar only. Scroll back and you will see nothing, because there is nothing to see: no markers are drawn on price and no history is reconstructed. This is a real-time panel, and backtesting it is not possible by design.

═════════════════════════════════════════════════════════════

▌ THE IDEA

Large volume is not information. Volume that is large for that symbol is.

Common volume tools compare volume to its own average and report "1180% of normal". That is a ratio without a scale. A symbol whose volume routinely swings tenfold produces 1180% on an ordinary day; a stable one produces 300% in a genuinely exceptional moment. The two numbers are not comparable, not across symbols and not even within one symbol across regimes.

MVAT compares against the distribution, not the average:

z = ( ln(value) − mean ) ÷ standard deviation

The logarithm comes first because volume is approximately log-normal; without it the standard deviation is meaningless. z is then computed per symbol against a rolling window of 300 of its own prints.

The result is unit-free, and that is what makes the table possible at all. A print at 3.4σ on Bitcoin is exactly as abnormal as 3.4σ on PEPE, even though one is millions of dollars and the other is thousands. Symbols with completely different size, liquidity and volatility become rankable in a single column.

═════════════════════════════════════════════════════════════

▌ THE PANEL

[image]https://www.tradingview.com/x/9Ahmyeuj/[/image]

Cluster row, then one row per abnormal print, newest on top:

▰▰▰▰▰▰▰▰ 9/9 ▲ XRP SOL SUI ETH +5 · 0.05%

23:26:00 · XRP · ▲█ · 1.0600 · $79.6K · ●● 3.3
23:26:00 · SOL · ▲▄ · 73.25 · $178.5K · ● 2.8
23:25:56 · SUI · ▲▂ · 0.6893 · $18.3K · ● 2.8
23:25:53 · BTC · ▲▂ · 63,562.0 · $153.4K · ● 2.3
23:25:44 · AVAX · ◆▂ · 6.5370 · $5.3K · ● 2.4

Ordinary prints never reach the screen. The tape carries anomalies, not the full flow.

TIME — print time to the second, in exchange time (UTC on Binance). Align it to your chart with the clock-offset input.

SYM — ticker, stripped of exchange prefix and quote suffix.

SIDE — two characters: direction and impact. Detailed below.

PRICE — execution price, formatted adaptively so fractional-priced symbols are not rounded to zero.

VALUE — notional in dollars, compact (K · M · B). This is economic materiality; SCORE is statistical rarity. They are deliberately different: a 4σ print worth ten thousand dollars on a thin market is statistically extreme and economically small, and the reverse happens too.

SCORE — anomaly strength in standard deviations.

═════════════════════════════════════════════════════════════

▌ STRENGTH CHANNEL

[image]https://www.tradingview.com/x/vTbQDcOP/[/image]

● between the first and second threshold
●● between the second and third
●●● above the third

The dot count states the strength on its own; the number beside it gives precision.

The fill is a continuous gradient, not two states: a print at 2.1 does not carry the same colour as one at 2.9. Hue carries side — green for buy, red for sell — while intensity carries strength, so the two channels never compete for the same discrimination.

Note on the third threshold: it is the top of the colour ramp, not a third detection level. Prints above it simply take the hottest shade.

═════════════════════════════════════════════════════════════

▌ SIDE CHANNEL

▲ buy · ▼ sell · ◆ neutral

[image]https://www.tradingview.com/x/3utmNvdC/[/image]

Direction is taken from inside the print's own second, not by comparing it to the one before: close against open first, then the close's position within the bar's range. Whatever neither resolves is shown as neutral.

This deserves a moment. The common tick rule compares close to previous close and leaves exact price ties unresolved — and ties are very common at one-second resolution. When ties are assigned to buy by default, the side balance tilts hard and falsely toward buying.

MVAT does not do that. A second carrying no directional information says so with ◆ and is counted on neither side.

═════════════════════════════════════════════════════════════

▌ IMPACT CHANNEL

[image]https://www.tradingview.com/x/3utmNvdC/[/image]

█ breakthrough — moved price more than twice the usual
▄ ordinary
▂ absorption — barely moved price at all

This channel answers what volume alone cannot: what did this volume do to price? Two prints at 4σ, one that moved price and one that did not, mean opposite things.

▲█ — heavy buying that cut through the book. The opposing liquidity was consumed.

▲▂ — heavy buying eaten by a resting seller. A defended level, and the seller is still there.

Measured as the print's move in basis points relative to that symbol's own average move, computed from prints that actually moved rather than from all prints. The distinction matters: most one-second bars close where they opened, and letting the zeros into the average would make any tick at all look like a breakthrough.

═════════════════════════════════════════════════════════════

▌ THE CLUSTER ROW

[image]https://www.tradingview.com/x/ieo0uzuH/[/image]

The tape shows individual events. The cluster row answers a different question: is this a symbol's news, or the market's event?

Five scattered anomalies across five symbols within an hour is one thing. Five anomalies across five symbols within fifteen seconds is another entirely.

Fired:
▰▰▰▰▰▰▰▰ 9/9 ▲ XRP SOL SUI ETH +5 · 0.05%

Idle:
▰▰▰▰▰▱▱▱ 6/9 · exp 2.6

GAUGE — proximity to the threshold, read at a glance. Always eight cells regardless of the threshold, so raising it from 4 to 12 never widens the table.

COUNT — distinct symbols inside the window, against the minimum.

SIDE — net direction across the cluster, weighted by strength.

SYMBOLS — the four strongest by peak σ, then +k for the rest. This is the most important part of the row. A cluster of XRP, SOL, SUI and ETH is not a cluster of four microcaps, and a count alone cannot tell them apart. Ranking by strength puts the heaviest first, so you can see what carried the move.

PROBABILITY — the chance of this cluster occurring at random. 0.05% is genuinely rare; 5% means you are reading noise.

EXP — in the idle state, the expected number of symbols under independence, computed live from the current scan rates. Use it to tune your threshold: if exp is close to your minimum you are about to read coincidence; if it is far below, a fired row is a real event.

═════════════════════════════════════════════════════════════

▌ WHY A FIFTEEN-SECOND WINDOW

The cluster is calibrated, not set by taste. A window's ability to discriminate collapses quickly as it widens:

15s window · 4 symbols → 24.8× the chance rate
30s window · 4 symbols → 5.7×
60s window · 3 symbols → 1.0× — pure coincidence

A wide window does not capture the event's width; it dissolves it in noise.

The chance probability is computed inside the indicator from each symbol's rate in the current scan, not from a planted constant, so it stays correct at any symbol count and any level of market activity without manual recalibration.

Threshold scaling matters: the expectation is proportional to how many symbols are scanned, so a threshold tuned for ten becomes far too loose at forty.

10 symbols → 4
20 symbols → 5
30 symbols → 6
40 symbols → 9

The displayed exp makes this table unnecessary — set the threshold clearly above it.

Finally: symbols inside a cluster are listed, not ordered in time. No lead-and-follow sequence is displayed, because displaying one would be invention rather than measurement. The ordering shown is by strength, which is real information.

═════════════════════════════════════════════════════════════

▌ SETTINGS

1 · Signal — the display filter, the σ threshold ladder, tape length. Tier 3 is the colour ceiling, not a detection level.

2 · Universe — forty slots, each with an enable toggle and a text ticker field. Type the ticker only (BTCUSDT); the exchange prefix is added automatically. An unlisted ticker is skipped silently and never breaks the indicator or its settings dialog.

3 · Cluster — show the row, window in seconds, minimum distinct symbols.

4 · Data — lower timeframe, volume measure, scan depth per symbol. Scan depth governs both the tape's time span and reference precision.

5 · Statistics — reference window size, warmup minimum, and an option to admit events only after the window fills so every σ comes from one sample size.

6 · Appearance — language, location, scale, clock offset from UTC.

7 · Colors — a three-stop ramp per side: weak, mid, hot.

═════════════════════════════════════════════════════════════

▌ CHOOSING A VOLUME MEASURE

Dollar Volume (default) — the only measure comparable across symbols in one table. Use it whenever the universe is mixed.

Volume — base units. Use it when watching a single symbol or a set with similar unit scales.

Price Volume — volume multiplied by typical price, an intermediate form.

σ itself is computed on the selected measure, so switching changes both the Score column and which prints qualify.

═════════════════════════════════════════════════════════════

▌ READING IT

Scan the SCORE column first — the eye catches ●●● and the hot shades immediately. Then SIDE: did it break through or was it absorbed? Then VALUE: does it deserve attention economically, or is it a statistical anomaly on a thin market? Above it, the cluster row gives the context: isolated event or market wave.

Patterns worth tracking:

Repeated ▲▂ at the same price — a resting seller absorbing demand at a defined level.

A ▼ cluster with a low probability — synchronised selling pressure across the market rather than news in one symbol.

═════════════════════════════════════════════════════════════

▌ STATUS FLAGS

The indicator does not fail silently. Three flags appear only when needed.

TIME ⚠ — the data budget clipped the requested scan depth.

SYM ⚠ — a configured symbol returned no data.

TF ⚠ — the chart timeframe is too small to feed the reference window.

═════════════════════════════════════════════════════════════

▌ OPERATIONAL REQUIREMENTS

The reference window is rebuilt from the current chart bar only, so the chart timeframe must be large enough to hold the required number of prints. At a 1S lower timeframe use 15 minutes or higher. Below that, TF ⚠ appears and the indicator tells you itself.

Enabling all forty symbols consumes Pine's request allowance in full. Each symbol's share of the data budget is clipped before any computation, so the indicator cannot exceed the platform limit whatever the settings.

Performance: forty simultaneous lower-timeframe requests is a heavy load. On slower machines, or when switching chart timeframes rapidly, expect a noticeable reload. Reducing the universe to 10–20 symbols both speeds this up and buys a deeper scan per symbol.

The engine is stateless: the reference window and the tape are rebuilt on every execution. As a result σ for a given print never changes no matter how long your session runs, and a closed bar's contents never change.

═════════════════════════════════════════════════════════════

▌ SCOPE

MVAT is a measurement instrument, not an entry-signal generator. It emits no alerts, by design.

What it reports: which prints were abnormal by their own symbol's standard, which side carried them, what they did to price, and whether they coincided with others.

What it does not report: the direction price will take next. Volume abnormality relates far more to the size of the coming move than to its direction, and reading the panel as buy signals reads it wrong.

The impact channel ships tagged [Unvalidated]: its thresholds rest on a sound statistical basis but have not been calibrated against forward returns.

The panel is fully bilingual, Arabic and English, switchable in settings.

═════════════════════════════════════════════════════════════
⚠️ DISCLAIMER
═════════════════════════════════════════════════════════════

This indicator is for educational and analytical purposes only. It does not constitute financial, investment, or trading advice. Use it alongside your own strategy and risk management. Neither TradingView nor the developer is responsible for any financial decisions or losses.

═════════════════════════════════════════════════════════════
═════════════════════════════════════════════════════════════

Multi-Symbol Volume Anomaly Tape    شريط شذوذ الحجم متعدّد الرموز

أربعون عملة في تدفّق واحد، بدقّة الثانية ، لا يعرض الحجم، بل يعرض ما هو غير عادي منه فقط.


⚠ اقرأ هذا أولًا — لوحة مراقبة حيّة لا أداة تحليل تاريخي

محرّك المسح يعمل على الشمعة الأخيرة وحدها. إن رجعت بالشارت إلى الوراء لن ترى شيئًا، لأنه لا يوجد ما يُرى: لا علامات تُرسم على السعر ولا تاريخ يُعاد بناؤه. هذه لوحة لحظية، والاختبار التاريخي عليها غير ممكن بحكم التصميم.

═════════════════════════════════════════════════════════════

▌ الفكرة

الحجم الكبير ليس معلومة. الحجم الكبير بالنسبة لطبيعة العملة نفسها هو المعلومة.

المقاييس الشائعة تقارن الحجم بمتوسّطه فتقول «١١٨٠٪ من المعدّل». وهذه نسبة بلا مقياس: عملة يتأرجح حجمها عشرة أضعاف يوميًا تعطي هذا الرقم في يوم عادي تمامًا، وعملة مستقرّة الحجم تعطي ثلاثمئة بالمئة في لحظة استثنائية. الرقمان غير قابلين للمقارنة، لا بين عملتين ولا داخل العملة الواحدة عبر أنظمة السوق.

والمؤشّر يقارن بالتوزيع لا بالمتوسط:

z = ( ln(value) − mean ) ÷ standard deviation

اللوغاريتم أولًا لأن توزيع الحجم لوغاريتمي-طبيعي تقريبًا، وبدونه يكون الانحراف المعياري بلا معنى. ثم تُحسب القيمة لكل رمز مقابل نافذة متدحرجة من ثلاثمئة صفقة من تاريخه هو وحده.

النتيجة كمّية بلا وحدة، وهذا ما يجعل الجدول ممكنًا أصلًا. صفقة عند ٣٫٤ انحراف على البيتكوين شاذّة بنفس القدر تمامًا الذي تشذّ به على عملة صغيرة، رغم أن الأولى بملايين الدولارات والثانية بآلاف. عملات مختلفة القيمة والسيولة والتقلّب تصير قابلة للترتيب في عمود واحد.

═════════════════════════════════════════════════════════════

▌ اللوحة

[image]https://www.tradingview.com/x/9Ahmyeuj/[/image]

صف العنقود، ثم صف لكل صفقة شاذّة، والأحدث في الأعلى:

▰▰▰▰▰▰▰▰ 9/9 ▲ XRP SOL SUI ETH +5 · 0.05%

23:26:00 · XRP · ▲█ · 1.0600 · $79.6K · ●● 3.3
23:26:00 · SOL · ▲▄ · 73.25 · $178.5K · ● 2.8
23:25:53 · BTC · ▲▂ · 63,562.0 · $153.4K · ● 2.3
23:25:44 · AVAX · ◆▂ · 6.5370 · $5.3K · ● 2.4

الصفقات العادية لا تصل إلى الشاشة إطلاقًا. الشريط يحمل الشذوذ لا كل التدفّق.

TIME
توقيت الصفقة بالثانية، بتوقيت البورصة. يُضبط على توقيت شارتك من مقبض إزاحة الساعة.

SYM
الرمز، مقصوصًا من بادئة المنصّة ولاحقة العملة المقابلة.

SIDE
محرفان: الجانب والأثر، ويُشرحان أدناه.

PRICE
سعر التنفيذ، بتنسيق متكيّف فلا تُقرّب الأسعار الكسرية إلى صفر.

VALUE
القيمة الاسمية بالدولار. هذه المادّية الاقتصادية، والشذوذ الإحصائي في العمود التالي. العمودان يقولان شيئين مختلفين عمدًا: صفقة عند أربعة انحرافات بعشرة آلاف دولار على سوق رقيق شاذّة إحصائيًا وضئيلة اقتصاديًا، والعكس يحدث كذلك.

SCORE
شدّة الشذوذ بوحدة الانحراف المعياري.

═════════════════════════════════════════════════════════════

▌ قناة الشدّة

[image]https://www.tradingview.com/x/vTbQDcOP/[/image]

● بين العتبة الأولى والثانية
●● بين الثانية والثالثة
●●● فوق الثالثة

عدد النقاط يقول القوة بنفسه، والرقم بجانبه يعطي الدقّة.

والخلفية تدرّج لوني متّصل لا حالتين: صفقة عند ٢٫١ لا تُطبع بلون صفقة عند ٢٫٩. الصبغة تحمل الجانب، أخضر للشراء وأحمر للبيع، والشدّة تحمل القوة، فالقناتان لا تتنافسان على التمييز نفسه.

والعتبة الثالثة سقف التدرّج اللوني لا مستوى كشف ثالث. ما فوقها يأخذ أشدّ درجة لونية فقط.

═════════════════════════════════════════════════════════════

▌ قناة الجانب

▲ شراء · ▼ بيع · ◆ محايد

[image]https://www.tradingview.com/x/3utmNvdC/[/image]

الجانب مأخوذ من داخل الثانية نفسها لا من مقارنتها بما قبلها: الإغلاق مقابل الافتتاح أولًا، ثم موضع الإغلاق داخل مدى الشمعة. وما لا يُحسم بأيّ منهما يُعرض محايدًا.

وهذه النقطة تستحق الوقوف. القاعدة الشائعة تقارن الإغلاق بالإغلاق السابق ولا تحسم حالة التعادل السعري، وهي شائعة جدًّا على إطار الثانية. وحين تُسند التعادلات افتراضيًا إلى الشراء يميل ميزان الجانب ميلًا حادًّا وكاذبًا نحو الشراء.

المؤشّر لا يفعل ذلك. الثانية التي لا تحمل معلومة اتجاه تُعلن ذلك بنفسها ولا تُحسب على أي جانب.

═════════════════════════════════════════════════════════════

▌ قناة الأثر

[image]https://www.tradingview.com/x/3utmNvdC/[/image]

█ اختراق — حرّك السعر أكثر من ضعف المعتاد
▄ عادي
▂ امتصاص — لم يحرّك السعر تقريبًا

هذه القناة تجيب سؤالًا لا يجيبه الحجم وحده: ماذا فعل هذا الحجم بالسعر؟ صفقتان عند أربعة انحرافات، إحداهما حرّكت السعر والأخرى لم تحرّكه، معناهما التداولي متعاكس تمامًا.

▲█
حجم شراء ضخم اخترق دفتر الأوامر، فالسيولة المقابلة استُهلكت.

▲▂
حجم شراء ضخم ابتلعه بائع قائم. مستوى مُدافَع عنه، والبائع ما زال هناك.

والقياس بحركة الصفقة بنقاط الأساس منسوبة إلى متوسط حركة ذلك الرمز نفسه، محسوبًا من الصفقات التي تحرّكت فعلًا لا من كل الصفقات. وهذا التمييز جوهري: أغلب شموع الثانية تُغلق حيث فتحت، ولو دخلت الأصفار في المتوسط لصار أي تحرّك مهما صغر اختراقًا.

═════════════════════════════════════════════════════════════

▌ صف العنقود

[image]https://www.tradingview.com/x/ieo0uzuH/[/image]

الشريط يعرض أحداثًا فردية، وصف العنقود يجيب سؤالًا مختلفًا: هل ما تراه خبر عملة أم حدث سوق؟

خمس صفقات شاذّة متفرّقة على خمس عملات خلال ساعة شيء. وخمس صفقات شاذّة على خمس عملات خلال خمس عشرة ثانية شيء آخر تمامًا.

مشتعلًا:
▰▰▰▰▰▰▰▰ 9/9 ▲ XRP SOL SUI ETH +5 · 0.05%

ساكنًا:
▰▰▰▰▰▱▱▱ 6/9 · exp 2.6

المقياس
قربك من العتبة، يُقرأ بلمحة بلا حساب. ثماني خانات دائمًا مهما كانت العتبة، فلا يتمدّد الجدول حين ترفعها.

العدد
الرموز المتمايزة داخل النافذة، مقابل الحدّ المطلوب.

الجانب
صافي الاتجاه المرجّح بالشدّة عبر العنقود كله.

الرموز
أقوى أربعة مرتّبة بذروة الانحراف تنازليًا، ثم عدد الباقي. وهذا أهم ما في الصف: عنقود يضم أربع عملات كبرى ليس عنقودًا يضم أربع عملات صغيرة، والعدد وحده لا يفرّق بينهما. والترتيب بالشدّة يضع الأثقل أولًا فتعرف ما الذي حمل الحركة.

الاحتمال
فرصة وقوع هذا العنقود صدفةً محضة. خمسة من مئة ألف حدث نادر فعلًا، وخمسة بالمئة تعني أنك تقرأ ضجيجًا.

exp
في الحالة الساكنة: العدد المتوقّع من الرموز تحت فرضية الاستقلال، محسوبًا حيًّا من معدّلات المسح الجارية. استعمله لضبط عتبتك، فإن قاربت عتبتَك فأنت على وشك قراءة الصدفة، وإن ابتعدت عنها كثيرًا فاشتعال الصف حدث حقيقي.

═════════════════════════════════════════════════════════════

▌ لماذا نافذة خمس عشرة ثانية

العنقود مُعاير لا مضبوط بالذوق، وقدرة النافذة على التمييز تنهار سريعًا مع اتّساعها:

15s window · 4 symbols → 24.8×
30s window · 4 symbols → 5.7×
60s window · 3 symbols → 1.0×

الأخير يعني صدفة محضة. النافذة الواسعة لا تلتقط عرض الحدث بل تُذيبه في الضجيج.

واحتمال الصدفة يُحسب داخل المؤشّر من معدّلات كل رمز في المسح الجاري لا من ثابت مزروع، فيبقى صحيحًا مع أي عدد رموز وأي مستوى نشاط سوقي بلا إعادة معايرة يدوية.

وضبط العتبة مهم: التوقّع يتناسب طرديًا مع عدد الرموز الممسوحة، فعتبة تناسب عشرة رموز تصير رخوة جدًّا عند أربعين.

10 symbols → 4
20 symbols → 5
30 symbols → 6
40 symbols → 9

وقيمة exp المعروضة تغنيك عن هذا الجدول: اضبط العتبة فوقها بوضوح.

وأخيرًا: الرموز داخل العنقود تُسرَد ولا تُرتَّب زمنيًا. لا يوجد تسلسل قيادة وتبعية يُعرض، وعرضه سيكون اختراعًا لا قياسًا. الترتيب المعروض بالشدّة، وهو معلومة حقيقية.

═════════════════════════════════════════════════════════════

▌ الإعدادات

1 · Signal
المُرشّح وسلّم العتبات وعدد الصفوف. العتبة الثالثة سقف لوني لا مستوى كشف.

2 · Universe
أربعون خانة، لكل منها مفتاح تفعيل وحقل رمز نصّي. اكتب الرمز فقط وتُضاف بادئة المنصّة تلقائيًا. والرمز غير المدرج يُتجاهل بصمت ولا يُعطّل المؤشّر ولا نافذة إعداداته.

3 · Cluster
إظهار الصف، والنافذة بالثواني، والحدّ الأدنى من الرموز المتمايزة.

4 · Data
الإطار الأدنى، ومقياس الحجم، وعمق المسح لكل رمز. وعمق المسح يحكم امتداد الشريط الزمني ودقّة المرجع معًا.

5 · Statistics
حجم النافذة المرجعية، وأدنى عيّنة قبل الحساب، وخيار قبول الأحداث بعد امتلاء النافذة فقط فتتوحّد دقّة القياس عبر كل الصفوف.

6 · Appearance
اللغة والموقع والحجم وإزاحة الساعة.

7 · Colors
سلّم ثلاثي المحطات لكل جانب: ضعيف ومتوسط وحادّ.

═════════════════════════════════════════════════════════════

▌ اختيار مقياس الحجم

Dollar Volume
الافتراضي، وهو الوحيد القابل للمقارنة بين رموز مختلفة في جدول واحد. استخدمه كلما كانت السلة مختلطة.

Volume
الوحدات الأساسية. لرمز واحد أو سلة متقاربة المقياس.

Price Volume
الحجم مضروبًا في السعر النموذجي، صيغة وسطى.

والقياس الإحصائي يُحسب على المقياس المختار، فتغييره يغيّر عمود الدرجة ويغيّر أي الصفقات تتأهّل أصلًا.

═════════════════════════════════════════════════════════════

▌ كيف تقرأه عمليًّا

امسح عمود الدرجة أولًا، فالعين تلتقط النقاط الثلاث والألوان الحادّة فورًا. ثم انظر الجانب: اخترق أم امتُصّ؟ ثم القيمة: هل يستحق الالتفات اقتصاديًا أم أنه شذوذ إحصائي على سوق رقيق؟ وفي الأعلى صف العنقود يعطيك السياق: حدث فردي أم موجة سوق.

نمطان يستحقّان التتبّع:

علامة الامتصاص متكرّرة على السعر نفسه، وتعني بائعًا قائمًا يمتصّ الطلب عند مستوى محدّد.

عنقود بيع باحتمال منخفض، ويعني ضغط بيع متزامنًا عبر السوق لا خبرًا في عملة بعينها.

═════════════════════════════════════════════════════════════

▌ علامات الحالة

المؤشّر لا يفشل بصمت، وثلاث علامات تظهر عند الحاجة فقط.

TIME ⚠
الميزانية قصّت عمق المسح المطلوب.

SYM ⚠
رمز مُعدّ لم تصل بياناته.

TF ⚠
إطار الشارت أصغر من أن يغذّي النافذة المرجعية.

═════════════════════════════════════════════════════════════

▌ متطلّبات تشغيلية

النافذة المرجعية تُبنى من الشمعة الجارية وحدها، فيجب أن يتّسع إطار الشارت لعدد الصفقات المطلوب. وعند إطار أدنى بالثانية استخدم خمس عشرة دقيقة فأعلى، وما دون ذلك تظهر علامة الإطار ويُبلغك المؤشّر بنفسه.

وتفعيل الأربعين رمزًا يستهلك سقف الطلبات المسموح في المنصّة بالكامل. وحصّة كل رمز من ميزانية البيانات مقصوصة قبل أي حساب، فلا يتجاوز المؤشّر الحد مهما كانت الإعدادات.

الأداء: أربعون طلبًا متزامنًا حمل ثقيل. وعلى الأجهزة الأبطأ أو عند تغيير إطار الشارت بتكرار توقّع إعادة تحميل ملحوظة. وتقليل السلة إلى عشرة أو عشرين رمزًا يسرّع التحميل ويشتري عمق مسح أكبر لكل رمز.

والمحرّك عديم الحالة: النافذة المرجعية والشريط يُعاد بناؤهما في كل تنفيذ. والنتيجة أن قياس أي صفقة لا يتغيّر مهما طالت جلستك، وأن الشمعة المغلقة لا يتغيّر محتواها أبدًا.

═════════════════════════════════════════════════════════════

▌ نطاق الأداة

هذا مؤشّر قياس لا مولّد إشارات دخول، ولا يصدر تنبيهات عمدًا.

ما يبلّغه: أي الصفقات كانت شاذّة بمقياس رمزها، وأي جانب حملها، وماذا فعلت بالسعر، وهل تزامنت مع غيرها.

وما لا يبلّغه: اتجاه السعر القادم. فشذوذ الحجم يرتبط بحجم الحركة القادمة أكثر بكثير مما يرتبط باتجاهها، ومن يقرأ اللوحة كإشارات شراء يقرأها خطأ.

وقناة الأثر تُشحن موسومة بأنها غير مُعايَرة على عوائد أمامية: عتبتاها مضبوطتان على أساس إحصائي سليم، لكنهما لم تُختبَرا مقابل ما يحدث بعدها.

واللوحة كاملة بالعربية والإنجليزية، تُبدَّل من الإعدادات.

═════════════════════════════════════════════════════════════
⚠️ إخلاء المسؤولية
═════════════════════════════════════════════════════════════

هذا المؤشر لأغراض تعليمية وتحليلية فقط. لا يُمثل نصيحة مالية أو استثمارية أو تداولية. استخدمه بالتزامن مع استراتيجيتك الخاصة وإدارة المخاطر. لا يتحمل TradingView ولا المطور مسؤولية أي قرارات مالية أو خسائر.

## Source Code

````pine
//@version=6
// The_lurker Fawaz Al-Enezi فواز العنزي

indicator("Multi-Symbol Volume Anomaly Tape [The_lurker]", "MVAT", overlay = true, dynamic_requests = true)

//  ▌ 01  SIGNAL · الإشارة
var string GA = "1 · Signal | الإشارة"
showMode  = input.string("All liquidity", "Show", ["All liquidity","Liquidity surge","Liquidity entry"], group = GA, display = display.none, tooltip = "All = everything at or above Tier 1. Surge = Tier 2 and above only. Entry = Tier 1 band only, excluding surges. | الكل = كل ما بلغ المستوى الأول. القوي = المستوى الثاني فأعلى. الدخول = نطاق المستوى الأول وحده دون القوي.")
zElev     = input.float(2.0, "Tier 1 — show from  z ≥", 1.0, 3.0, 0.1, group = GA, display = display.none)
zSurge    = input.float(3.0, "Tier 2 — strong from  z ≥", 2.0, 5.0, 0.1, group = GA, display = display.none)
zTop      = input.float(5.0, "Tier 3 — colour saturates at  z ≥", 3.0, 9.0, 0.5, group = GA, display = display.none, tooltip = "Upper end of the colour ramp. Prints at or above it get the hottest shade. | نهاية التدرّج اللوني؛ ما يبلغها أو يتجاوزها يأخذ أشدّ درجة.")
rowLen    = input.int(40, "Rows (tape length)", 5, 100, group = GA, display = display.none)

//  ▌ 02  UNIVERSE · السلة
var string GB = "2 · Universe 01–10 | السلة"
var string GC = "2 · Universe 11–20 | السلة"
var string GD = "2 · Universe 21–30 | السلة"
var string GE = "2 · Universe 31–40 | السلة"
u01 = input.bool(true , "", inline = "01", group = GB)
s01 = input.string("BTCUSDT", "", inline = "01", group = GB, tooltip = "All forty are plain text fields, not the symbol picker. The picker validates its default when the settings dialog opens, so a single unlisted ticker breaks the whole window — this list contains at least one. Type the ticker; BINANCE: is added automatically. An unlisted ticker is skipped at runtime and raises the Sym flag. | الأربعون حقول نصّية لا منتقيات: المنتقي يتحقّق من قيمته الافتراضية فيُسقط رمزٌ غير مُدرج النافذةَ كلها، وهذه القائمة تحوي واحدًا على الأقل. الرمز غير المدرج يُتجاهل وتظهر علامة Sym.")
u02 = input.bool(true , "", inline = "02", group = GB)
s02 = input.string("ETHUSDT", "", inline = "02", group = GB)
u03 = input.bool(true , "", inline = "03", group = GB)
s03 = input.string("BNBUSDT", "", inline = "03", group = GB)
u04 = input.bool(true , "", inline = "04", group = GB)
s04 = input.string("XRPUSDT", "", inline = "04", group = GB)
u05 = input.bool(true , "", inline = "05", group = GB)
s05 = input.string("SOLUSDT", "", inline = "05", group = GB)
u06 = input.bool(true , "", inline = "06", group = GB)
s06 = input.string("TRXUSDT", "", inline = "06", group = GB)
u07 = input.bool(true , "", inline = "07", group = GB)
s07 = input.string("DOGEUSDT", "", inline = "07", group = GB)
u08 = input.bool(true , "", inline = "08", group = GB)
s08 = input.string("ADAUSDT", "", inline = "08", group = GB)
u09 = input.bool(true , "", inline = "09", group = GB)
s09 = input.string("AVAXUSDT", "", inline = "09", group = GB)
u10 = input.bool(true , "", inline = "10", group = GB)
s10 = input.string("SHIBUSDT", "", inline = "10", group = GB)
u11 = input.bool(true , "", inline = "11", group = GC)
s11 = input.string("LINKUSDT", "", inline = "11", group = GC)
u12 = input.bool(true , "", inline = "12", group = GC)
s12 = input.string("BCHUSDT", "", inline = "12", group = GC)
u13 = input.bool(true , "", inline = "13", group = GC)
s13 = input.string("DOTUSDT", "", inline = "13", group = GC)
u14 = input.bool(true , "", inline = "14", group = GC)
s14 = input.string("NEARUSDT", "", inline = "14", group = GC)
u15 = input.bool(true , "", inline = "15", group = GC)
s15 = input.string("POLUSDT", "", inline = "15", group = GC)
u16 = input.bool(true , "", inline = "16", group = GC)
s16 = input.string("UNIUSDT", "", inline = "16", group = GC)
u17 = input.bool(true , "", inline = "17", group = GC)
s17 = input.string("PEPEUSDT", "", inline = "17", group = GC)
u18 = input.bool(true , "", inline = "18", group = GC)
s18 = input.string("LTCUSDT", "", inline = "18", group = GC)
u19 = input.bool(true , "", inline = "19", group = GC)
s19 = input.string("SUIUSDT", "", inline = "19", group = GC)
u20 = input.bool(true , "", inline = "20", group = GC)
s20 = input.string("ICPUSDT", "", inline = "20", group = GC)
u21 = input.bool(true , "", inline = "21", group = GD)
s21 = input.string("TAOUSDT", "", inline = "21", group = GD)
u22 = input.bool(true , "", inline = "22", group = GD)
s22 = input.string("FETUSDT", "", inline = "22", group = GD)
u23 = input.bool(true , "", inline = "23", group = GD)
s23 = input.string("RENDERUSDT", "", inline = "23", group = GD)
u24 = input.bool(true , "", inline = "24", group = GD)
s24 = input.string("APTUSDT", "", inline = "24", group = GD)
u25 = input.bool(true , "", inline = "25", group = GD)
s25 = input.string("HBARUSDT", "", inline = "25", group = GD)
u26 = input.bool(true , "", inline = "26", group = GD)
s26 = input.string("XLMUSDT", "", inline = "26", group = GD)
u27 = input.bool(true , "", inline = "27", group = GD)
s27 = input.string("ARBUSDT", "", inline = "27", group = GD)
u28 = input.bool(true , "", inline = "28", group = GD)
s28 = input.string("IMXUSDT", "", inline = "28", group = GD)
u29 = input.bool(true , "", inline = "29", group = GD)
s29 = input.string("FILUSDT", "", inline = "29", group = GD)
u30 = input.bool(true , "", inline = "30", group = GD)
s30 = input.string("OPUSDT", "", inline = "30", group = GD)
u31 = input.bool(true , "", inline = "31", group = GE)
s31 = input.string("ATOMUSDT", "", inline = "31", group = GE)
u32 = input.bool(true , "", inline = "32", group = GE)
s32 = input.string("ENAUSDT", "", inline = "32", group = GE)
u33 = input.bool(true , "", inline = "33", group = GE)
s33 = input.string("INJUSDT", "", inline = "33", group = GE)
u34 = input.bool(true , "", inline = "34", group = GE)
s34 = input.string("SKYUSDT", "", inline = "34", group = GE)
u35 = input.bool(true , "", inline = "35", group = GE)
s35 = input.string("WLDUSDT", "", inline = "35", group = GE)
u36 = input.bool(true , "", inline = "36", group = GE)
s36 = input.string("OGUSDT" , "", inline = "36", group = GE)
u37 = input.bool(true , "", inline = "37", group = GE)
s37 = input.string("AAVEUSDT", "", inline = "37", group = GE)
u38 = input.bool(true , "", inline = "38", group = GE)
s38 = input.string("GRTUSDT", "", inline = "38", group = GE)
u39 = input.bool(true , "", inline = "39", group = GE)
s39 = input.string("ALGOUSDT", "", inline = "39", group = GE)
u40 = input.bool(true , "", inline = "40", group = GE)
s40 = input.string("SUSDT", "", inline = "40", group = GE)

//  ▌ 03  CLUSTER · العنقود
var string GF = "3 · Cluster | العنقود"
showClus  = input.bool(true , "Show cluster line", group = GF, tooltip = "One row above the header reporting simultaneous events across symbols. Calibrated on 38 hours of 5S data over 10 symbols: a 15s window with 4 distinct symbols fires on 1.05% of windows at 24.8x the shift-null rate. | صف فوق العناوين يبلّغ عن الأحداث المتزامنة. مُعاير على 38 ساعة: نافذة 15 ثانية و4 رموز = 24.8× معدّل العدم.")
clusWin   = input.int(15, "Cluster window (seconds)", 5, 120, group = GF, display = display.none, tooltip = "Measured lift at 4 distinct symbols: 24.8x at 15s, 5.7x at 30s, 1.9x at 60s. Wider windows dissolve the signal. | المضاعف المقيس عند 4 رموز: 24.8× عند 15ث، 5.7× عند 30ث، 1.9× عند 60ث.")
clusMin   = input.int(9, "Cluster minimum (symbols)", 2, 20, group = GF, display = display.none, tooltip = "Must scale with how many symbols are enabled: chance expectation is proportional to symbol count. Measured null at a 15s window: 10 symbols need 4, 20 need 5, 30 need 6, 40 need 7-8 for the same rarity. The Cluster line prints the live expectation so the setting can be checked against it. | يجب أن يتناسب مع عدد الرموز المفعّلة: 10 رموز تحتاج 4، و20 تحتاج 5، و30 تحتاج 6، و40 تحتاج 7-8 لنفس الندرة.")

//  ▌ 04  DATA · البيانات
var string GG = "4 · Data | البيانات"
ltf       = input.timeframe("1S", "Lower Timeframe", group = GG, display = display.none, tooltip = "Auto-switches to 1S if higher than chart TF. | يتحوّل تلقائيًا إلى 1S إن كان أعلى من إطار الشارت.")
volType   = input.string("Dollar Volume", "Volume Measure", ["Volume","Price Volume","Dollar Volume"], group = GG, display = display.none, tooltip = "Dollar volume reads better when mixing symbols in one table. | القيمة الدولارية أوضح عند خلط رموز مختلفة.")
scanDepth = input.int(900, "Scan depth (prints/symbol)", 300, 5000, 100, group = GG, display = display.none, tooltip = "Controls both tape time-span and reference precision. Auto-capped by the 100K intrabar budget. | يحكم امتداد الشريط ودقّة المرجع؛ يُقصّ تلقائيًا بالميزانية.")

//  ▌ 05  STATISTICS · الإحصاء
var string GH = "5 · Statistics | الإحصاء"
refLen    = input.int(300, "Reference Window", 50, 1000, group = GH, display = display.none, tooltip = "Prints per symbol used to build the reference distribution. | عدد الصفقات لبناء التوزيع المرجعي لكل رمز.")
warmup    = input.int(30, "Warmup Minimum", 10, 200, group = GH, display = display.none)
fullWin   = input.bool(false, "Require full reference window", group = GH, tooltip = "Off: admission starts after Warmup prints, so the scan works within seconds of a new chart bar. On: admission waits for a full refLen window, which makes every sigma come from one sample size but leaves the scan blind for refLen seconds after each chart bar opens. | مُطفأ: القبول يبدأ بعد عدد الإحماء فيعمل المسح خلال ثوانٍ من فتح الشمعة. مُفعّل: ينتظر نافذة كاملة فتتوحّد دقّة σ لكن يعمى المسح refLen ثانية بعد كل شمعة جديدة.")

//  ▌ 06  APPEARANCE · المظهر
var string GI = "6 · Appearance | المظهر"
language  = input.string("English", "Language", ["English","العربية"], group = GI, display = display.none)
tblPos    = input.string("Top Right", "Location", ["Top Right","Middle Right","Bottom Right","Top Center","Middle Center","Bottom Center","Top Left","Middle Left","Bottom Left"], group = GI, display = display.none)
tblScale  = input.string("Small", "Scale", ["Tiny","Small","Normal","Large"], group = GI, display = display.none)
tzOff     = input.int(0, "Clock offset from UTC (hours)", -12, 14, group = GI, display = display.none, tooltip = "Times are exchange time (UTC on Binance). Set to your chart offset. | الأوقات بتوقيت البورصة؛ اضبطه على إزاحة شارتك.")

//  ▌ 07  COLORS · الألوان
var string GJ = "7 · Colors | الألوان"
buyLo   = input.color(#0d3b24, "Buy ramp   weak / mid / hot", group = GJ, inline = "b")
buyMid  = input.color(#00c853, "", group = GJ, inline = "b")
buyHi   = input.color(#aeea00, "", group = GJ, inline = "b")
sellLo  = input.color(#3d0d0d, "Sell ramp  weak / mid / hot", group = GJ, inline = "s")
sellMid = input.color(#ff3d3d, "", group = GJ, inline = "s")
sellHi  = input.color(#ff9100, "", group = GJ, inline = "s")
colHead = input.color(#1a1a2e, "Header BG", group = GJ)
colTxt  = input.color(#ffffff, "Text", group = GJ)

//  ▌ 08  HELPERS · الأدوات
tr(en, ar) => language == "العربية" ? ar : en

locConv(x) =>
    switch x
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right

szConv(x) =>
    switch x
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_qual(s) => str.contains(s, ":") ? s : "BINANCE:" + s

f_short(s) =>
    t = s
    p = str.pos(t, ":")
    if not na(p)
        t := str.substring(t, p + 1)
    qs = array.from("USDT", "FDUSD", "USDC", "TUSD", "BUSD", "USD", "BTC", "ETH")
    for q in qs
        if str.endswith(t, q) and str.length(t) > str.length(q)
            t := str.substring(t, 0, str.length(t) - str.length(q))
            break
    str.length(t) > 8 ? str.substring(t, 0, 8) : t

fmtVol(x) =>
    if volType != "Volume"
        x >= 1e9 ? "$" + str.tostring(x / 1e9, "#.##") + "B" : x >= 1e6 ? "$" + str.tostring(x / 1e6, "#.##") + "M" : x >= 1e3 ? "$" + str.tostring(x / 1e3, "#.#") + "K" : "$" + str.tostring(x, "#,###.##")
    else
        x >= 99999 ? str.tostring(x, format.volume) : x >= 1000 ? str.tostring(x, "#,###") : x >= 1 ? str.tostring(x, "#,##0.###") : str.tostring(x, "0.00000")

gradCol(z, dir) =>
    lo  = dir > 0 ? buyLo  : dir < 0 ? sellLo  : color.new(colTxt, 88)
    md  = dir > 0 ? buyMid : dir < 0 ? sellMid : color.new(colTxt, 66)
    hi  = dir > 0 ? buyHi  : dir < 0 ? sellHi  : color.new(colTxt, 40)
    top = math.max(zTop, zSurge + 0.1)
    z < zSurge ? color.from_gradient(z, zElev, zSurge, lo, md) : color.from_gradient(z, zSurge, top, md, hi)

tierMark(z) =>
    top = math.max(zTop, zSurge + 0.1)
    z >= top ? "●●●" : z >= zSurge ? "●●" : "●"

poisTail(lam, k) =>
    r = 1.0
    if k > 0
        acc  = 0.0
        term = math.exp(-lam)
        for j = 0 to k - 1
            acc  += term
            term := term * lam / (j + 1)
        r := math.max(0.0, 1.0 - acc)
    r

fPrice(x) =>
    x >= 1000 ? str.tostring(x, "#,###.0") : x >= 10 ? str.tostring(x, "#.####") : x >= 0.1 ? str.tostring(x, "#.#####") : str.tostring(x, "0.00000000")

//  ▌ 09  TYPES · الأنواع
type Print
    int   t
    int   si
    int   dir
    float price
    float vol
    float z
    float imp

insByTime(a, e, cap) =>
    n   = a.size()
    pos = n
    if n > 0
        for q = 0 to n - 1
            if e.t > a.get(q).t
                pos := q
                break
    if pos < cap
        if pos >= n
            a.push(e)
        if pos < n
            a.insert(pos, e)
        if a.size() > cap
            a.pop()
    pos

//  ▌ 10  UNIVERSE BUILD · بناء السلة
var array<string> UT = array.new<string>()
var array<string> UD = array.new<string>()
if barstate.isfirst
    RAWS = array.new<string>()
    RAWU = array.new<bool>()
    RAWS.push(s01)
    RAWS.push(s02)
    RAWS.push(s03)
    RAWS.push(s04)
    RAWS.push(s05)
    RAWS.push(s06)
    RAWS.push(s07)
    RAWS.push(s08)
    RAWS.push(s09)
    RAWS.push(s10)
    RAWS.push(s11)
    RAWS.push(s12)
    RAWS.push(s13)
    RAWS.push(s14)
    RAWS.push(s15)
    RAWS.push(s16)
    RAWS.push(s17)
    RAWS.push(s18)
    RAWS.push(s19)
    RAWS.push(s20)
    RAWS.push(s21)
    RAWS.push(s22)
    RAWS.push(s23)
    RAWS.push(s24)
    RAWS.push(s25)
    RAWS.push(s26)
    RAWS.push(s27)
    RAWS.push(s28)
    RAWS.push(s29)
    RAWS.push(s30)
    RAWS.push(s31)
    RAWS.push(s32)
    RAWS.push(s33)
    RAWS.push(s34)
    RAWS.push(s35)
    RAWS.push(s36)
    RAWS.push(s37)
    RAWS.push(s38)
    RAWS.push(s39)
    RAWS.push(s40)
    RAWU.push(u01)
    RAWU.push(u02)
    RAWU.push(u03)
    RAWU.push(u04)
    RAWU.push(u05)
    RAWU.push(u06)
    RAWU.push(u07)
    RAWU.push(u08)
    RAWU.push(u09)
    RAWU.push(u10)
    RAWU.push(u11)
    RAWU.push(u12)
    RAWU.push(u13)
    RAWU.push(u14)
    RAWU.push(u15)
    RAWU.push(u16)
    RAWU.push(u17)
    RAWU.push(u18)
    RAWU.push(u19)
    RAWU.push(u20)
    RAWU.push(u21)
    RAWU.push(u22)
    RAWU.push(u23)
    RAWU.push(u24)
    RAWU.push(u25)
    RAWU.push(u26)
    RAWU.push(u27)
    RAWU.push(u28)
    RAWU.push(u29)
    RAWU.push(u30)
    RAWU.push(u31)
    RAWU.push(u32)
    RAWU.push(u33)
    RAWU.push(u34)
    RAWU.push(u35)
    RAWU.push(u36)
    RAWU.push(u37)
    RAWU.push(u38)
    RAWU.push(u39)
    RAWU.push(u40)
    for i = 0 to 39
        raw = RAWS.get(i)
        if RAWU.get(i) and str.length(raw) > 1
            tid = f_qual(raw)
            if UT.indexof(tid) == -1 and UT.size() < 40
                UT.push(tid)
                UD.push(f_short(raw))

nSym = UT.size()

//  ▌ 11  DATA BUDGET · ميزانية البيانات
nSlots  = math.max((u01?1:0)+(u02?1:0)+(u03?1:0)+(u04?1:0)+(u05?1:0)+(u06?1:0)+(u07?1:0)+(u08?1:0)+(u09?1:0)+(u10?1:0)+(u11?1:0)+(u12?1:0)+(u13?1:0)+(u14?1:0)+(u15?1:0)+(u16?1:0)+(u17?1:0)+(u18?1:0)+(u19?1:0)+(u20?1:0)+(u21?1:0)+(u22?1:0)+(u23?1:0)+(u24?1:0)+(u25?1:0)+(u26?1:0)+(u27?1:0)+(u28?1:0)+(u29?1:0)+(u30?1:0)+(u31?1:0)+(u32?1:0)+(u33?1:0)+(u34?1:0)+(u35?1:0)+(u36?1:0)+(u37?1:0)+(u38?1:0)+(u39?1:0)+(u40?1:0), 1)
budCap  = int(100000 / nSlots)
want    = math.min(scanDepth, budCap)
floorC  = math.min(refLen * 2, budCap)
calcCnt = math.max(want, floorC)
capped  = calcCnt < scanDepth
minK    = fullWin ? refLen : warmup
useTF   = timeframe.in_seconds(ltf) > timeframe.in_seconds() ? "1S" : ltf
barPrints = math.max(int(timeframe.in_seconds() / timeframe.in_seconds(useTF)), 1)
tfShort   = barPrints < refLen
tzStr   = tzOff == 0 ? "GMT" : tzOff > 0 ? "GMT+" + str.tostring(tzOff) : "GMT" + str.tostring(tzOff)

ltfSrc() =>
    v = volType == "Volume" ? volume : volType == "Dollar Volume" ? close * volume : hlc3 * volume
    [time, open, high, low, close, v]

//  ▌ 12  SCAN ENGINE · محرك المسح
var array<float> lamS = array.new<float>()
var array<bool>  seen = array.new<bool>()
var array<float> seenZ = array.new<float>()
var array<float> workZ = array.new<float>()
var array<float> buf  = array.new<float>()
var array<float> bufM = array.new<float>()
var array<Print> tape = array.new<Print>()

nData = 0

if barstate.islast and nSym > 0
    tape.clear()
    lamS.clear()
    for i = 0 to nSym - 1
        [aT, aO, aH, aL, aC, aV] = request.security_lower_tf(UT.get(i), useTF, ltfSrc(), ignore_invalid_symbol = true, ignore_invalid_timeframe = true, calc_bars_count = calcCnt)
        if not na(aV)
            cnt = aV.size()
            if cnt > 0
                nData += 1
                buf.clear()
                bufM.clear()
                head    = 0
                lvSum   = 0.0
                lvSqSum = 0.0
                mvSum   = 0.0
                mvN     = 0
                prevC   = 0.0
                evN     = 0
                t0s     = int(nz(aT.get(0), time))
                t1s     = int(nz(aT.get(cnt - 1), time))
                for j = 0 to cnt - 1
                    v = nz(aV.get(j), 0.0)
                    if v > 0
                        oo = nz(aO.get(j), close)
                        hh = nz(aH.get(j), close)
                        ll = nz(aL.get(j), close)
                        cc = nz(aC.get(j), close)
                        rg = hh - ll
                        ps = rg > 0 ? (cc - ll) / rg : 0.5
                        d0 = cc > oo ? 1 : cc < oo ? -1 : ps > 0.5 ? 1 : ps < 0.5 ? -1 : 0
                        d  = d0 != 0 ? d0 : prevC == 0.0 ? 0 : cc > prevC ? 1 : cc < prevC ? -1 : 0
                        mv = cc > 0 ? math.abs(cc - oo) / cc * 10000.0 : 0.0
                        prevC := cc
                        lnv = math.log(v)
                        k   = buf.size()
                        z   = 0.0
                        ip  = 1.0
                        if k >= minK
                            mean   = lvSum / k
                            varEst = math.max((lvSqSum - lvSum * lvSum / k) / k, 0.0)
                            sd     = math.sqrt(varEst)
                            z := sd > 1e-12 ? (lnv - mean) / sd : 0.0
                            mm = mvN > 0 ? mvSum / mvN : 0.0
                            ip := mm > 1e-9 ? mv / mm : 1.0
                        if k < refLen
                            buf.push(lnv)
                            bufM.push(mv)
                            lvSum   += lnv
                            lvSqSum += lnv * lnv
                            mvSum   += mv
                            if mv > 0
                                mvN += 1
                        if k >= refLen
                            oz = buf.get(head)
                            om = bufM.get(head)
                            buf.set(head, lnv)
                            bufM.set(head, mv)
                            head := head + 1
                            if head >= refLen
                                head := 0
                            lvSum   += lnv - oz
                            lvSqSum += lnv * lnv - oz * oz
                            mvSum   += mv - om
                            if mv > 0
                                mvN += 1
                            if om > 0
                                mvN -= 1
                        adm = showMode == "Liquidity surge" ? z >= zSurge : showMode == "Liquidity entry" ? (z >= zElev and z < zSurge) : z >= zElev
                        if adm
                            tt = int(nz(aT.get(j), time))
                            tn = tape.size()
                            ok = tn < rowLen
                            if not ok
                                ok := tt > tape.get(tn - 1).t
                            evN += 1
                            if ok
                                insByTime(tape, Print.new(tt, i, d, cc, v, z, ip), rowLen)
                spanS = math.max((t1s - t0s) / 1000.0, 1.0)
                lamS.push(evN / spanS)

//  ▌ 13  RENDER · الرسم
clusN = 0
clusNet = 0.0
clusSpan = 0
clusExp = 0.0
if showClus and tape.size() > 0 and lamS.size() > 0
    seen.clear()
    seenZ.clear()
    for q = 0 to nSym - 1
        seen.push(false)
        seenZ.push(0.0)
    tRef = tape.get(0).t
    for e in tape
        if tRef - e.t <= clusWin * 1000
            if not seen.get(e.si)
                seen.set(e.si, true)
                clusN += 1
            if e.z > seenZ.get(e.si)
                seenZ.set(e.si, e.z)
            clusNet += (e.dir >= 0 ? 1.0 : -1.0) * e.z
            clusSpan := math.max(clusSpan, tRef - e.t)
    for q = 0 to lamS.size() - 1
        clusExp += 1.0 - math.exp(-lamS.get(q) * clusWin)
clusOn = showClus and clusN >= clusMin

var int nRows = rowLen + 1 + (showClus ? 1 : 0)
rHead = showClus ? 1 : 0
rData = rHead + 1
var table tbl = table.new(locConv(tblPos), 6, nRows, bgcolor = color.new(#000000, 100), border_color = color.new(#000000, 100), border_width = 0, frame_color = color.new(#000000, 100), frame_width = 0)
var bool tblInit = false

cSet(tb, c, r, txt, tc, bg) =>
    table.cell_set_text(tb, c, r, txt)
    table.cell_set_text_color(tb, c, r, tc)
    table.cell_set_bgcolor(tb, c, r, bg)

if barstate.islast
    if not tblInit
        szx = szConv(tblScale)
        for r = 0 to nRows - 1
            for c = 0 to 5
                al = c == 2 ? text.align_center : c < 2 ? text.align_left : text.align_right
                table.cell(tbl, c, r, "", text_size = szx, text_color = colTxt, bgcolor = color.new(#000000, 100), text_halign = (showClus and r == 0) ? text.align_center : al)
        if showClus
            table.merge_cells(tbl, 0, 0, 5, 0)
        tblInit := true

    nShow = tape.size()
    hBg   = nShow > 0 ? color.new(colHead, 30) : color.new(#000000, 100)
    hTx   = nShow > 0 ? color.new(colTxt, 42) : color.new(colTxt, 70)
    if showClus
        cTx = clusOn ? (clusNet >= 0 ? buyHi : sellHi) : color.new(colTxt, 55)
        cBg = clusOn ? color.new(clusNet >= 0 ? buyMid : sellMid, 62) : color.new(colHead, 55)
        p0  = poisTail(clusExp, clusN)
        gFill = math.min(int(math.round(clusN * 8.0 / math.max(clusMin, 1))), 8)
        gauge = ""
        for q = 1 to 8
            gauge += q <= gFill ? "▰" : "▱"
        symTxt = ""
        shown  = 0
        if clusOn
            workZ.clear()
            for q = 0 to nSym - 1
                workZ.push(seenZ.get(q))
            for pick = 0 to 3
                bi = -1
                bz = 0.0
                for q = 0 to nSym - 1
                    if workZ.get(q) > bz
                        bz := workZ.get(q)
                        bi := q
                if bi >= 0
                    symTxt += (shown > 0 ? " " : "") + UD.get(bi)
                    workZ.set(bi, 0.0)
                    shown += 1
            if clusN > shown
                symTxt += " +" + str.tostring(clusN - shown)
        msg = clusOn ? gauge + "  " + str.tostring(clusN) + "/" + str.tostring(clusMin) + "  " + (clusNet >= 0 ? "▲" : "▼") + "  " + symTxt + "   " + str.tostring(p0 * 100, "0.00") + "%" : gauge + "  " + str.tostring(clusN) + "/" + str.tostring(clusMin) + tr("   exp ", "   متوقّع ") + str.tostring(clusExp, "0.0")
        cSet(tbl, 0, 0, msg, cTx, cBg)
    cSet(tbl, 0, rHead, tfShort ? tr("TF ⚠", "الإطار ⚠") : capped ? tr("TIME ⚠", "الوقت ⚠") : tr("TIME", "الوقت"), hTx, hBg)
    cSet(tbl, 1, rHead, (nSym == 0 or nData < nSym) ? tr("SYM ⚠", "الرمز ⚠") : tr("SYM", "الرمز"), hTx, hBg)
    cSet(tbl, 2, rHead, tr("SIDE", "الجانب"), hTx, hBg)
    cSet(tbl, 3, rHead, tr("PRICE", "السعر"), hTx, hBg)
    cSet(tbl, 4, rHead, volType == "Volume" ? tr("VOLUME", "الحجم") : tr("VALUE", "القيمة"), hTx, hBg)
    cSet(tbl, 5, rHead, tr("SCORE", "الدرجة"), hTx, hBg)

    clr  = color.new(#000000, 100)
    pane = color.new(#0b0b14, 20)
    dim  = color.new(colTxt, 38)
    for r = 0 to rowLen - 1
        rr = r + rData
        if r < nShow
            e   = tape.get(r)
            g   = gradCol(e.z, e.dir)
            tc  = e.z >= zSurge ? #000000 : colTxt
            arw = e.dir > 0 ? "▲" : e.dir < 0 ? "▼" : "◆"
            imk = e.imp >= 1.5 ? "█" : e.imp <= 0.5 ? "▂" : "▄"
            ac  = e.dir > 0 ? buyMid : e.dir < 0 ? sellMid : color.new(colTxt, 45)
            cSet(tbl, 0, rr, str.format_time(e.t, "HH:mm:ss", tzStr), dim, pane)
            cSet(tbl, 1, rr, UD.get(e.si), colTxt, pane)
            cSet(tbl, 2, rr, arw + imk, ac, pane)
            cSet(tbl, 3, rr, fPrice(e.price), colTxt, pane)
            cSet(tbl, 4, rr, fmtVol(e.vol), tc, g)
            cSet(tbl, 5, rr, tierMark(e.z) + " " + str.tostring(e.z, "0.0"), tc, g)
        if r >= nShow
            for c = 0 to 5
                cSet(tbl, c, rr, "", colTxt, clr)
````
