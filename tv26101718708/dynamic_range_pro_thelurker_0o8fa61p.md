# Dynamic Range Pro [The_lurker]

- url: https://www.tradingview.com/script/0o8FA61p/
- type: indicator
- pine_id: PUB;6cce5d5ab1fc42688d6711862c7c7963
- version: 1.0

## Description

Dynamic Range Pro detects horizontal price-consolidation zones and grades
the quality of the breakout that follows — not a plain buy/sell signal, but
a transparent, live verdict on how much to trust it.

It is also a ground-up evolution of my earlier indicator, Dynamic Range Finder

[url=https://www.tradingview.com/script/gB77unpi/]https://www.tradingview.com/script/gB77unpi/[/url]

While that tool relied on volume filters, TP/SL levels, and a stack of optional indicators, Dynamic Range Pro was rebuilt around a single specific question: is this consolidation genuinely real, and how good was the break that followed? Every gate and score below exists to answer one specific part of that question, and each has been tested on real historical data — not just code built on intuition.

🔑 AT A GLANCE

🔹 Four independent formation gates, not just an ATR box
🔹 Two synchronized range definitions — pick which one triggers signals
🔹 A graded breakout verdict instead of a flat buy/sell
🔹 A pre-breakout quality score that updates before any signal fires
🔹 Every claim below is backed by real backtested data

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 WHAT MAKES IT DIFFERENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Most range indicators draw a single box from average price ± ATR and treat any close beyond it as a signal. Dynamic Range Pro adds three things most of them ignore entirely:

1️⃣ Smarter detection
   A four-gate filter that rejects ranges a plain ATR test would wrongly accept — including the exact scenario where a sharp move inflates ATR enough to disguise an unstable window as a valid range.

[image]https://www.tradingview.com/x/NgqxQ27P/[/image]

2️⃣ A second, independent box
   A close-based range you can promote to be the actual breakout trigger instead of the ATR box — no fixed rule, your choice.

[image]https://www.tradingview.com/x/jODLx7F0/[/image]

3️⃣ A graded verdict, not a flat signal
   Every breakout is scored across five factors into Strong / Inconclusive / Likely Trap, so you see the reasoning, not just an arrow.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚦 FOUR-GATE RANGE DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A range is only confirmed when all four of these agree on the same bar:

1️⃣ ATR Containment
   Recent closes stay within average price ± ATR × multiplier. The standard test nearly every range tool uses.

2️⃣ Horizontality
   The correlation between close price and time over the lookback window stays below a threshold, filtering out windows that are quietly trending rather than truly sideways.

3️⃣ Absolute Amplitude Gate
   The gate most tools miss. After a sharp move, ATR itself balloons, which can make gate 1 pass even for a range that clearly isn't one — a wider ATR band is simply easier to stay inside. This gate checks the actual high-to-low spread of the window as a plain percentage of price, independent of ATR, so an inflated ATR reading can no longer disguise a genuinely wide, unstable window as a valid range.

4️⃣ Entry-Slope Gate
   Checks the price move across the first few candles of the window specifically. A window that starts mid-collapse and simply hasn't finished collapsing yet fails this gate even if the rest of the window looks calm.

🔸 Optional: Prior-Trend Filter
   ADX measured at the window's starting edge can further restrict detection to ranges that formed after a genuine trend rather than from a standing start — useful for trend-then-consolidation strategies.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 TWO BOXES, YOUR CHOICE OF TRIGGER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Dynamic Range Pro tracks two boxes at once:

1️⃣ Main Box (ATR-based)
   The standard range: average price ± ATR × multiplier. The classic definition every range tool uses, and the default breakout trigger.

[url=https://www.tradingview.com/x/m5Mm0Upi/]https://www.tradingview.com/x/m5Mm0Upi/[/url]

2️⃣ Inner Box (Close-based)
   A second, independent box built purely from the highest and lowest closing prices reached during formation — ignoring wicks entirely. It gives a tighter, noise-resistant read on where price actually settled.

[image]https://www.tradingview.com/x/LkmzY31f/[/image]

🔀 Box Mode — choosing the trigger
   Display either box, both together, or promote the Inner Box to be the actual breakout trigger instead of the Main Box. Triggering on the Inner Box produces an earlier, narrower breakout definition — useful if you want to react before price clears the full ATR band, at the cost of more frequent signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏆 GRADED BREAK-QUALITY VERDICT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Instead of a plain buy or sell with no context, every confirmed breakout is
scored across five factors:

[image]https://www.tradingview.com/x/LkmzY31f/[/image]

1️⃣ Trend strength (ADX)
   Healthy within a defined range, overheated above it.

2️⃣ Momentum saturation (RSI)
   Near-saturation in the breakout direction counts against the move.

3️⃣ Breach depth
   How far the close cleared the boundary, in box-height units.

4️⃣ Pre-formation dispersion
   How active the range was before the break, frozen at formation.

5️⃣ Directional flow alignment (DI spread)
   Whether the directional-movement spread confirms or contradicts the
   breakout direction.

Each factor votes toward a Strong / Inconclusive / Likely Trap verdict. You see the full breakdown on the chart — live during formation, frozen the moment the break confirms — so you can judge which factors are driving the call rather than trusting a closed label.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏁 READING THE BOTTOM LINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The last row of the table condenses everything above it into one plain-language line that updates live. It only ever shows one of five states:

[image]https://www.tradingview.com/x/DftxgBNY/[/image]

1️⃣ No box currently
   No active or recently broken range exists — nothing to report yet.

2️⃣ Range active — awaiting break
   A valid range currently exists, but price hasn't tested either boundary yet, so there's nothing to score yet.

[image]https://www.tradingview.com/x/YJCV2lA2/[/image]

3️⃣ ✅ Strong break
   The five Break-Quality factors net to a score at or above the "strong" threshold — most factors support continuation.

[image]https://www.tradingview.com/x/Jpfnj17m/[/image]
[image]https://www.tradingview.com/x/QFpyS57O/[/image]

4️⃣ ⚖️ Mixed (score shown)
   The score lands between the strong and trap thresholds — factors are pulling in different directions, worth extra caution.

[image]https://www.tradingview.com/x/q5C6BLE1/[/image]

5️⃣ ⚠️ Likely trap
   The score falls at or below the "trap" threshold — most factors point to exhaustion or reversal risk.

[image]https://www.tradingview.com/x/lV35SQmC/[/image]

🔸 The ◷ symbol
   When ◷ appears before a verdict, price is still breaching the boundary intrabar and the candle hasn't closed yet — a live, unconfirmed preview that can still change. Once the candle closes and the break is confirmed, ◷ disappears and the verdict locks in.

Both the "strong" and "trap" score thresholds are adjustable in settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧬 RANGE INTEGRITY SCORE — before the break happens
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The layer I find most exciting conceptually: a live 0-100 score describing how "clean" a forming range actually looks, computed continuously before any breakout occurs, from four independent angles:

[image]https://www.tradingview.com/x/UYFUtQSX/[/image]

1️⃣ Path noise
   How much the close zigzagged relative to the window's total range.

2️⃣ Candle cohesion
   How large individual candles are relative to the window.

3️⃣ Dispersion trend
   Whether volatility is tightening or loosening over time.

4️⃣ Edge-touch count
   How many times price tested the eventual boundary without breaking it.
This answers a different question than the Break-Quality Verdict does — not "how strong was the break," but "how trustworthy is this range in the first place" — and it updates live as the range develops, well before any signal fires.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 BUILT ON REAL DATA, NOT JUST INTUITION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Every gate and score in this script has been tested against real 4H data across 19-20 Binance pairs, roughly 440-620 historical range/breakout events depending on the test. I publish exactly what that testing found, including where it didn't confirm my expectations:

✅ The prior-trend ADX filter measurably sharpens detection quality on the tested sample.

⚠️ Three of the five Break-Quality factors (RSI level, ADX magnitude, dispersion) did not show a measurable independent relationship with what happened after the break. They remain in the score as a transparent, chart-readable checklist rather than a claimed predictive edge — you see exactly which factors tipped any verdict and weigh them yourself.

📈 The Range Integrity Score showed a small, positive, not-yet-statistically-significant relationship with post-break continuation (r = +0.10, p = 0.20, n = 176) — a promising direction, not a proven signal yet, which is exactly why it's a display-only layer with no influence on alerts or box formation.

This is not a "trust the backtest" pitch — it's the opposite. Everything above is a starting point for your own judgment, not a replacement for it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ PRACTICAL FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 Full Arabic/English toggle for the on-chart table and BUY/SELL labels (settings and alert text are bilingual either way)
🔔 BUY/SELL alerts, plus an optional intrabar "live breach" alert — early, purely informational, before the candle closes
📦 Historical range boxes are preserved cleanly across multiple formations, with no overlapping clutter
🎨 Every color, line width, and line style is customizable
🔒 All signals fire strictly on confirmed candle closes — no repainting, no lookahead

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗣️ INTERFACE LANGUAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Defaults to English. Switch "Table language" to Arabic in settings if you
prefer. Arabic-mode glossary:
Prior trend = الاتجاه السابق
Trend strength (ADX) = قوة الاتجاه
Break direction = اتجاه الكسر
Direction match = مطابقة الاتجاه
Breach depth = عمق الاختراق
Range dispersion = تشتت النطاق
Break verdict = تقييم الكسر
Range/entry % = امتداد/دخول %
Range integrity = تكامل النطاق
Range age = عمر النطاق
BUY/SELL = شراء / بيع

═════════════════════════════════════════════════════════════
⚠️ DISCLAIMER
═════════════════════════════════════════════════════════════

This indicator is for educational and analytical purposes only. It does not constitute financial, investment, or trading advice. Use it alongside your own strategy and risk management. Neither TradingView nor the developer is responsible for any financial decisions or losses.

══════════════════════════════════════════════════════════
══════════════════════════════════════════════════════════

Dynamic Range Pro
 أداة تكتشف مناطق التوحيد السعريّ الأفقيّة ، وتُقيِّم جودة الكسر الذي يليها — لا مجرّد إشارة شراء أو بيع ، بل تقييم حيّ وشفّاف لمدى
الثقة به.

وهو أيضًا تطوير جذري كامل لمؤشّري السابق Dynamic Range Finder

[url=https://ar.tradingview.com/script/gB77unpi/]https://ar.tradingview.com/script/gB77unpi/[/url]

بينما اعتمدت تلك الأداة على فلاتر الحجم ومستويات الجني/الخسارة وحزمة من المؤشرات الاختياريّة ، أُعيد بناء Dynamic Range Pro حول سؤال واحد محدّد: هل هذا التوحيد السعريّ حقيقيّ فعلًا ، وما مدى جودة الكسر الذي تلاه ؟
كل بوابة وكل درجة أدناه وُجدت للإجابة على جزء محدّد من هذا السؤال ، واختُبرت فعليًّا على بيانات تاريخيّة حقيقيّة — لا مجرّد كود مبنيّ على الحدس .

🔑 نظرة سريعة

🔹 أربع بوابات تكوين مستقلّة ، لا مجرّد صندوق ATR
🔹 تعريفا نطاق متزامنان — اختر أيّهما يُطلق الإشارات
🔹 تقييم متدرّج للكسر بدل شراء/بيع مسطّح
🔹 درجة جودة قبل الكسر تتحدّث قبل أيّ إشارة
🔹 كل ادّعاء أدناه مدعوم ببيانات باك-تست حقيقيّة

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 ما الذي يميّزه فعليًّا
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
معظم مؤشّرات النطاق ترسم صندوقًا واحدًا من متوسط السعر ± ATR وتعتبر أيّ إغلاق خارجه إشارة . يضيف Dynamic Range Pro ثلاثة أمور يتجاهلها أغلبها كليًّا :

1️⃣ كشف أذكى
   فلتر بأربع بوابات يرفض النطاقات التي كان اختبار ATR وحده سيقبلها خطأً ، بما في ذلك السيناريو تحديدًا حين تُضخِّم حركة حادّة قيمة ATR بما يكفي لتمويه نافذة غير مستقرّة كنطاق صالح.

[image]https://www.tradingview.com/x/NgqxQ27P/[/image]

2️⃣ صندوق ثانٍ مستقلّ
   نطاق قائم على الإغلاق يمكنك ترقيته ليكون مصدر الكسر الفعليّ بدل صندوق ATR لا بقاعدة ثابتة — باختيارك .

[image]https://www.tradingview.com/x/jODLx7F0/[/image]

3️⃣ تقييم متدرّج، لا إشارة مسطّحة
   كل كسر يُقيَّم عبر خمسة عوامل إلى قوي / غير حاسم / مصيدة محتملة ، فترى السبب لا مجرّد سهم .

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚦 كشف النطاق بأربع بوابات
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
لا يُعتمَد النطاق إلا حين تتّفق البوابات الأربع على نفس الشمعة :

1️⃣ احتواء ATR
   الإغلاقات الحديثة تبقى ضمن متوسط السعر ± ATR × مضاعف. الاختبار المعياريّ الذي تستخدمه كل أدوات النطاق تقريبًا.

2️⃣ الأفقيّة
   الارتباط بين سعر الإغلاق والزمن عبر نافذة النظر للخلف يبقى تحت عتبة محدّدة ، فيستبعد النوافذ التي تتّجه بهدوء بدل أن تكون أفقيّة فعلًا.

3️⃣ بوابة الاتّساع المطلق
   البوابة التي تُفوِّتها أغلب الأدوات. بعد حركة حادّة، يتضخّم ATR نفسه ، ممّا قد يجعل البوابة الأولى تمرّ حتى لو كان النطاق واضحًا أنّه ليس نطاقًا — لأنّ نطاق ATR الأوسع أسهل للبقاء داخله . تفحص هذه البوابة الفارق الفعليّ بين أعلى وأدنى نقطة في النافذة كنسبة مئويّة بسيطة من السعر ، بمعزل عن ATR ، فلا يعود قياس ATR المتضخِّم قادرًا على تمويه نافذة واسعة وغير مستقرّة فعليًّا على أنّها نطاق صالح .

4️⃣ بوابة زاوية الدخول
   تفحص حركة السعر عبر أوّل شموع النافذة تحديدًا. النافذة التي تبدأ في منتصف انهيار سعريّ ولم ينتهِ بعد ترسب في هذه البوابة حتى لو بدت بقيّة النافذة هادئة.

🔸 اختياريّ: فلتر الاتجاه السابق
عند الحافة الأولى للنافذة يمكنه تقييد الكشف أكثر على النطاقات    ADX  التي تكوّنت بعد اتجاه حقيقيّ لا من بداية ساكنة — مفيد لاستراتيجيّات اتجاه - ثم - توحيد .

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 صندوقان، واختيارك لمصدر الكسر
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
يتتبّع Dynamic Range Pro صندوقين في آنٍ واحد:

1️⃣ الصندوق الرئيسيّ (القائم على ATR)
   النطاق المعياريّ: متوسط السعر ± ATR × مضاعف. هذا التعريف الكلاسيكيّ الذي تستخدمه كل أدوات النطاق، ومصدر الكسر الافتراضيّ.

[url=https://www.tradingview.com/x/m5Mm0Upi/]https://www.tradingview.com/x/m5Mm0Upi/[/url]

2️⃣ الصندوق الداخليّ (القائم على الإغلاق)
   صندوق ثانٍ مستقلّ مبنيّ حصرًا من أعلى وأدنى سعر إغلاق خلال التكوّن — متجاهلًا الفتائل كليًّا. يمنح قراءة أضيق ومقاومة للضوضاء لموضع استقرار السعر الفعليّ.

[image]https://www.tradingview.com/x/LkmzY31f/[/image]

🔀 وضع الصندوق — اختيار مصدر الكسر
   اعرض أيّ صندوق، أو كليهما معًا، أو رقِّ الصندوق الداخليّ ليكون مصدر الكسر الفعليّ بدل الرئيسيّ. الكسر عبر الصندوق الداخليّ يُنتج تعريفًا أبكر وأضيق — مفيد إن أردت التفاعل قبل خروج السعر من نطاق ATR كاملًا ، مقابل إشارات أكثر تكرارًا.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏆 تقييم متدرّج لجودة الكسر
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
بدل شراء أو بيع مجرّد بلا سياق ، يُقيَّم كل كسر مؤكَّد عبر خمسة عوامل :

[image]https://www.tradingview.com/x/LkmzY31f/[/image]


1️⃣ قوّة الاتجاه (ADX)
   صحّي ضمن مدى محدّد، محموم فوقه.

2️⃣ اقتراب الزخم من التشبّع (RSI)
   القرب من التشبّع في اتجاه الكسر يُحسب ضدّ الحركة.

3️⃣ عمق الاختراق
   كم ابتعد الإغلاق عن الحدّ، بوحدة ارتفاع الصندوق.

4️⃣ تشتّت ما قبل التكوّن
   مدى نشاط النطاق قبل الكسر، مُجمَّد عند التكوين.

5️⃣ محاذاة تدفّق الاتجاه (فارق DI)
   هل فارق الحركة الاتجاهيّة يؤكّد اتجاه الكسر أم يعاكسه.

كل عامل يصوّت نحو تقييم قوي / غير حاسم / مصيدة محتملة. ترى التفصيل الكامل على الشارت — حيًّا أثناء التكوّن ، ومُجمَّدًا لحظة تأكّد الكسر — فتحكم بنفسك أيّ العوامل قاد القرار بدل الثقة بتصنيف مغلق.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏁 قراءة السطر السفليّ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
الصفّ الأخير في الجدول يُلخِّص كل ما فوقه في سطر واحد بلغة مبسّطة يتحدّث حيًّا . لا يظهر فيه إلّا واحدة من خمس حالات :

[image]https://www.tradingview.com/x/DftxgBNY/[/image]

1️⃣ لا صندوق حاليًّا
   لا يوجد نطاق نشط أو مكسور مؤخّرًا — لا شيء لعرضه بعد.

2️⃣ النطاق نشط — بانتظار الكسر
   يوجد نطاق صالح حاليًّا، لكن السعر لم يختبر أيّ حدّ بعد، فلا شيء لتقييمه بعد.

[image]https://www.tradingview.com/x/YJCV2lA2/[/image]

3️⃣ ✅ كسر قوي
   محصّلة العوامل الخمسة لجودة الكسر عند أو فوق عتبة "القويّ" — أغلب العوامل تدعم الاستمرار.

[image]https://www.tradingview.com/x/Jpfnj17m/[/image]
[image]https://www.tradingview.com/x/QFpyS57O/[/image]

4️⃣ ⚖️ إشارة مختلطة (مع عرض المحصّلة)
   المحصّلة بين عتبتَي القويّ والمصيدة — العوامل متضاربة، تستحقّ حذرًا إضافيًّا.

[image]https://www.tradingview.com/x/q5C6BLE1/[/image]

5️⃣ ⚠️ مصيدة محتملة
   المحصّلة عند أو تحت عتبة "المصيدة" — أغلب العوامل تشير لإنهاك أو خطر انعكاس.

[image]https://www.tradingview.com/x/lV35SQmC/[/image]

🔸 رمز ◷
   حين يظهر ◷ قبل أيّ تقييم، يعني أنّ السعر لا يزال يخترق الحدّ داخل الشمعة ولم تُغلَق بعد — معاينة حيّة غير مؤكَّدة قد تتغيّر. بمجرّد إغلاق الشمعة وتأكّد الكسر، يختفي ◷ ويثبت التقييم.

عتبتا "القويّ" و"المصيدة" كلتاهما قابلتان للتعديل من الإعدادات.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧬 درجة تكامل النطاق — قبل وقوع الكسر
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
الطبقة التي أراها الأكثر إثارة من الناحية المفاهيميّة: درجة حيّة من 0 إلى 100 تصف مدى "نظافة" النطاق المتكوّن فعليًّا، تُحسب باستمرار قبل وقوع أيّ كسر، من أربع زوايا مستقلّة:

[image]https://www.tradingview.com/x/UYFUtQSX/[/image]

1️⃣ تشوّش المسار
   مقدار تعرّج الإغلاق نسبةً لإجمالي امتداد النافذة.

2️⃣ تماسك الشمعة
   حجم الشموع الفرديّة نسبةً للنافذة.

3️⃣ اتجاه التشتّت
   هل التقلّب يتحسّن أم يتّسع عبر الزمن.

4️⃣ عدد لمسات الحافة
   كم مرّة اختبر السعر الحدّ المرتقَب دون كسره.

تجيب عن سؤال مختلف عمّا يجيبه تقييم جودة الكسر — ليس "ما مدى قوّة الكسر" بل "ما مدى مصداقيّة هذا النطاق أصلًا" — وتتحدّث حيًّا مع تطوّر النطاق، قبل أيّ إشارة بوقت طويل.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 مبنيّ على بيانات حقيقيّة، لا الحدس فقط
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
كل بوابة وكل درجة في هذا السكربت اختُبرت فعليًّا على بيانات 4H حقيقيّة عبر 19-20 عملة من Binance، وما يقارب 440-620 حدث نطاق/كسر تاريخيّ حسب الاختبار ، أنشر بالضبط ما وجده ذلك الاختبار، بما في ذلك ما لم يؤكّد توقّعي:

✅ فلتر ADX للاتجاه السابق يُحسِّن جودة الكشف بشكل قابل للقياس على العيّنة المختبَرة.

⚠️ ثلاثة من عوامل جودة الكسر الخمسة (مستوى RSI، مقدار ADX، التشتّت) لم تُظهر علاقة مستقلّة قابلة للقياس بما حدث بعد الكسر. تبقى في التقييم كقائمة تحقّق شفّافة قابلة للقراءة على الشارت لا كميزة تنبّؤيّة مُدَّعاة — ترى بالضبط أيّ العوامل رجّح أيّ تقييم وتزنها بنفسك.

📈 درجة تكامل النطاق أظهرت علاقة موجبة صغيرة، غير دالّة إحصائيًّا بعد، مع استمراريّة ما بعد الكسر (r = +0.10، p = 0.20، n = 176) — اتجاه واعد ، لا إشارة مُثبَتة بعد، وهذا بالضبط سبب كونها طبقة عرض فقط بلا تأثير على التنبيهات أو تكوّن الصندوق.

هذا ليس عرضًا من نوع "ثق بنتائج الباك-تست" — بل عكس ذلك تمامًا. كل ما سبق نقطة انطلاق لحكمك أنت، لا بديل عنه.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ ميزات عمليّة
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 تبديل كامل بين العربيّة والإنجليزيّة لواجهة الجدول وعلامتَي الشراء/البيع (لوحة الإعدادات ورسائل التنبيه ثنائيّة اللغة دومًا)
🔔 تنبيهات شراء/بيع، مع تنبيه اختياريّ للاختراق اللحظيّ — مبكّر، إخباريّ بحت، قبل إغلاق الشمعة
📦 صناديق النطاقات التاريخيّة تُحفَظ بنظافة عبر عدّة تكوينات، بلا تراكب فوضويّ
🎨 كل لون وسماكة ونمط خطّ قابل للتخصيص
🔒 كل الإشارات تُطلَق حصرًا عند إغلاق شمعة مؤكَّد — بلا إعادة رسم، بلا استباق

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🗣️ لغة الواجهة
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
تعرض الإنجليزيّة افتراضيًّا. بدّل "لغة الجدول" للعربيّة من الإعدادات إن فضّلت. دليل الوضع العربيّ:
Prior trend = الاتجاه السابق
Trend strength (ADX) = قوة الاتجاه
Break direction = اتجاه الكسر
Direction match = مطابقة الاتجاه
Breach depth = عمق الاختراق
Range dispersion = تشتت النطاق
Break verdict = تقييم الكسر
Range/entry % = امتداد/دخول %
Range integrity = تكامل النطاق
Range age = عمر النطاق
BUY/SELL = شراء / بيع

═════════════════════════════════════════════════════════════
⚠️ إخلاء المسؤولية
═════════════════════════════════════════════════════════════

هذا المؤشر لأغراض تعليمية وتحليلية فقط. لا يُمثل نصيحة مالية أو استثمارية أو تداولية. استخدمه بالتزامن مع استراتيجيتك الخاصة وإدارة المخاطر. لا يتحمل TradingView ولا المطور مسؤولية أي قرارات مالية أو خسائر.

## Source Code

````pine
//@version=6
indicator(title="Dynamic Range Pro [The_lurker]", overlay=true, max_boxes_count=500, max_bars_back=500)

// ═══ Settings | الإعدادات ═══
string g_lang = "🌐 Language | اللغة"
string i_lang = input.string("English", "Table language | لغة الجدول", options=["English","العربية"], group=g_lang, tooltip="Only affects the table and BUY/SELL labels. Settings and alerts stay bilingual regardless (Pine limitation) | يؤثّر فقط على الجدول وعلامتَي الشراء/البيع. الإعدادات والتنبيهات تبقى ثنائية اللغة دومًا (قيد Pine)")

string g_range = "📊 Range | النطاق"
int    i_rangePeriod     = input.int(20, "Range Period | فترة النطاق", minval=2, maxval=200, group=g_range)
int    i_atrPeriod       = input.int(50, "ATR Period | فترة ATR", minval=1, group=g_range)
float  i_rangeMultiplier = input.float(0.9, "Range Multiplier | مضاعف النطاق", minval=0.1, step=0.1, group=g_range)
string i_maType          = input.string("SMA", "MA Type | نوع المتوسط", options=["SMA", "EMA", "WMA"], group=g_range)
float  i_corrSigma       = input.float(1.5, "Max time-corr (σ units) | أقصى ارتباط زمني (بوحدات σ)", minval=0.5, maxval=4.0, step=0.25, group=g_range, tooltip="Pearson(close,time) threshold = σ ÷ √(period−1). Higher = stricter horizontality | عتبة ارتباط بيرسون(الإغلاق،الزمن) = σ ÷ √(الفترة−1). الأعلى = أفقيّة أصرم")
float  i_maxRangePct     = input.float(6.0, "Max internal range % (reject wide) | أقصى اتّساع داخليّ % (رفض الواسع)", minval=0.5, maxval=100.0, step=0.5, group=g_range, tooltip="ATR-independent gate: (highest−lowest)÷price over the window. Above this ⇒ no box, even if ATR is inflated | بوابة مستقلّة عن ATR: (أعلى−أدنى)÷السعر خلال النافذة. فوق هذا ⇒ لا صندوق، حتى لو تضخّم ATR")
int    i_entryBars       = input.int(3, "Entry-slope bars | شموع زاوية الدخول", minval=2, maxval=30, group=g_range)
float  i_maxEntrySlopePct= input.float(3.0, "Max entry move % (reject steep) | أقصى حركة دخول % (رفض الانحدار)", minval=0.1, maxval=100.0, step=0.25, group=g_range, tooltip="Rejects ranges starting with a steep move over the first Entry-slope bars candles | يرفض النطاقات التي تبدأ بحركة حادّة عبر أوّل شموع زاوية الدخول")
bool   i_showHistorical  = input.bool(true, "Keep Historical Boxes | إبقاء الصناديق التاريخية", group=g_range)
string i_boxMode         = input.string("Both", "Box mode (display & breakout source) | وضع الصندوق (العرض ومصدر الكسر)", options=["Both", "Inner box only", "Main box only"], group=g_range, tooltip="Both: shows both, ATR box triggers breaks. Inner only: close-based box triggers (earlier/narrower). Main only: ATR box only | كلاهما: يُعرَض الصندوقان، الكسر على ATR. الداخليّ فقط: صندوق الإغلاق يُكسَر (أبكر وأضيق). الرئيسيّ فقط: ATR فقط")

string g_trend = "🧭 Prior Trend | الاتجاه السابق"
bool   i_requirePriorTrend = input.bool(true, "Require strong prior trend | يتطلّب اتجاهًا سابقًا قويًا", group=g_trend, tooltip="No box without a strong prior trend (ADX at the window's left edge ≥ Min prior ADX), unless disabled | لا صندوق بلا اتجاه سابق قويّ (ADX عند حافة النافذة اليسرى ≥ أدنى ADX سابق)، إلا إذا عُطِّل")
float  i_minPriorADX = input.float(25.0, "Min prior ADX | أدنى ADX سابق مطلوب", minval=0.0, maxval=100.0, step=1.0, group=g_trend, tooltip="Standard ADX threshold. Measures trend PRESENCE, not magnitude — see Limitations | عتبة ADX معيارية. يقيس وجود الاتجاه لا مقداره — راجع القيود")
int    i_priorLen = input.int(14, "Prior-trend ADX length | طول ADX للاتجاه السابق", minval=2, maxval=100, group=g_trend, tooltip="Frozen at the window's left edge, not re-read at breakout | مُجمَّدة عند الحافة اليسرى للنافذة، لا تُقرأ عند الكسر")

string g_qual = "🎚️ Break Quality | جودة الكسر"
bool   i_qualEnable    = input.bool(true, "Enable break-quality verdict | تفعيل تقييم جودة الكسر", group=g_qual, tooltip="A discretionary chart-readable score, not a statistical predictor — see Limitations | تسجيل اجتهاديّ قابل للقراءة على الشارت، ليس مقياسًا إحصائيًّا — راجع القيود")
int    i_rsiLen        = input.int(14, "RSI length | طول RSI", minval=2, maxval=100, group=g_qual)
float  i_rsiOB         = input.float(60.0, "RSI overbought (near-saturation) | تشبّع شرائي", minval=50.0, maxval=100.0, step=1.0, group=g_qual, tooltip="Up-break near this level ⇒ exhaustion factor (−1) | كسر صعوديّ قرب هذا المستوى ⇒ عامل إنهاك (−1)")
float  i_rsiOS         = input.float(40.0, "RSI oversold (near-saturation) | تشبّع بيعي", minval=0.0, maxval=50.0, step=1.0, group=g_qual, tooltip="Down-break near this level ⇒ exhaustion factor (−1) | كسر هبوطيّ قرب هذا المستوى ⇒ عامل إنهاك (−1)")
float  i_adxHealthyMin = input.float(25.0, "ADX healthy floor | أرضية ADX الصحّي", minval=0.0, maxval=100.0, step=1.0, group=g_qual, tooltip="Within [floor, ceiling] ⇒ healthy (+1); above ceiling ⇒ overheated (−1); below floor ⇒ neutral (0) | ضمن [الأرضية، السقف] ⇒ صحّي (+1)؛ فوق السقف ⇒ محموم (−1)؛ تحت الأرضية ⇒ محايد (0)")
float  i_adxOverheat   = input.float(50.0, "ADX overheated ceiling | سقف ADX المحموم", minval=10.0, maxval=100.0, step=1.0, group=g_qual)
float  i_depthStrong   = input.float(0.50, "Strong breach depth (H) | عمق اختراق قوي", minval=0.0, step=0.05, group=g_qual, tooltip="Depth in box-height (H) units — always the ATR box, regardless of Box Mode | العمق بوحدة ارتفاع الصندوق H — دومًا صندوق ATR بصرف النظر عن وضع الصندوق")
float  i_dispStrong    = input.float(1.50, "Strong range dispersion | تشتّت نطاق قوي", minval=0.0, step=0.1, group=g_qual, tooltip="Mean deviation ÷ ATR, frozen at formation | الانحراف المتوسط ÷ ATR، مُجمَّد عند التكوين")
float  i_diMargin      = input.float(5.0, "Min DI confirm spread | أدنى فارق DI مؤكِّد", minval=0.0, step=1.0, group=g_qual, tooltip="DI spread aligned with break direction. ≥ this ⇒ confirms (+1); ≤0 ⇒ against (−1) | فارق DI المحاذي لاتجاه الكسر. ≥ هذا ⇒ تأكيد (+1)؛ ≤0 ⇒ معاكس (−1)")
int    i_scoreStrong   = input.int(2, "Score ≥ ⇒ strong break | محصّلة ≥ ⇒ كسر قوي", minval=1, maxval=5, group=g_qual)
int    i_scoreTrap     = input.int(-2, "Score ≤ ⇒ likely trap | محصّلة ≤ ⇒ مصيدة", minval=-5, maxval=-1, group=g_qual)
bool   i_showLiveVals  = input.bool(true, "Always show table (live readout) | إبقاء الجدول ظاهرًا دائمًا (قراءة حيّة)", group=g_qual, tooltip="Keeps the table visible with no active box, showing live values at any candle (useful in Bar Replay) | يُبقي الجدول ظاهرًا بلا صندوق نشط، ويعرض القيم الحيّة عند أيّ شمعة (مفيد في Bar Replay)")

string g_integ = "🧬 Range Integrity (Unvalidated) | تكامل النطاق (غير مُحقَّق)"
float  i_integrityHigh = input.float(70.0, "High integrity ≥ | تكامل مرتفع ≥", minval=50.0, maxval=100.0, step=5.0, group=g_integ, tooltip="0-100 score from 4 price-action metrics, tested but not yet statistically significant — display only, see Limitations | درجة 0-100 من 4 مقاييس سعريّة، اختُبرت لكن غير دالّة إحصائيًّا بعد — عرض فقط، راجع القيود")
float  i_integrityLow  = input.float(40.0, "Low integrity ≤ | تكامل منخفض ≤", minval=0.0, maxval=50.0, step=5.0, group=g_integ)

string g_sig = "🎯 Signals & Table | الإشارات والجدول"
bool   i_showSignals = input.bool(true, "Show BUY/SELL labels | إظهار إشارات BUY/SELL", group=g_sig)
bool   i_tblShow     = input.bool(true, "Show prior-trend table | إظهار جدول الاتجاه السابق", group=g_sig)
bool   i_liveBreach  = input.bool(true, "Live breach alert (intrabar) | تنبيه اختراق لحظي (داخل الشمعة)", group=g_sig, tooltip="Informational only — pulses once intrabar, before the candle closes. Fires no BUY/SELL, changes no state | إخباريّ فقط — ينبض مرّة داخل الشمعة قبل إغلاقها. لا يُصدر شراء/بيع ولا يغيّر أيّ حالة")
int    i_retestWindow = input.int(10, "Table visibility after break (bars) | مدّة ظهور الجدول بعد الكسر (شموع)", minval=1, maxval=500, group=g_sig, tooltip="How long the table stays visible after a break before it's removed | مدّة بقاء الجدول ظاهرًا بعد الكسر قبل حذفه")
string i_tblPos      = input.string("Top Right", "Table Position | موضع الجدول", options=["Top Right","Middle Right","Bottom Right","Top Left","Bottom Left"], group=g_sig)
string i_tblSize     = input.string("Small", "Table text size (zoom) | حجم نص الجدول (تكبير/تصغير)", options=["Tiny","Small","Normal","Large"], group=g_sig)

string g_col = "🎨 Colors | الألوان"
color  i_neutralColor = input.color(color.new(#7E57C2, 70), "Active Range (neutral) | النطاق النشط (محايد)", group=g_col)
color  i_upColor      = input.color(color.new(#26A69A, 60), "Break Up (BUY) | كسر صعودي", group=g_col)
color  i_downColor    = input.color(color.new(#EF5350, 60), "Break Down (SELL) | كسر هبوطي", group=g_col)
color  i_buyLabel     = input.color(#26A69A, "BUY label | ليبل الشراء", group=g_col)
color  i_sellLabel    = input.color(#EF5350, "SELL label | ليبل البيع", group=g_col)
color  i_breachColor  = input.color(#FF9800, "Live breach border | حدّ الاختراق اللحظي", group=g_col)
color  i_closeBoxColor = input.color(#FFD54F, "Inner close box color | لون صندوق الإغلاق الداخليّ", group=g_col)
int    i_closeBoxWidth = input.int(1, "Inner close box line width | سماكة خطّ الصندوق الداخليّ", minval=1, maxval=4, group=g_col)
string i_closeBoxStyle = input.string("Solid", "Inner close box line style | نمط خطّ الصندوق الداخليّ", options=["Solid", "Dotted", "Dashed"], group=g_col)

// ═══ Type Definition | تعريف النوع ═══
bool isAr = i_lang == "العربية"
bool showMain  = i_boxMode != "Inner box only"
bool showInner = i_boxMode != "Main box only"
bool innerOp   = i_boxMode == "Inner box only"

type RangeBox
    box    theBox
    float  upperBound
    float  lowerBound
    int    startBar
    bool   active = false
    bool   everFormed = false
    int    lastKeptRight
    bool   priorUp   = false
    float  priorADX  = 0.0
    int    brokeDir  = 0
    float  breachDepth = 0.0
    float  dispersionRatio = 0.0
    float  integrityScore = 0.0
    box    formBox
    float  formHigh = 0.0
    float  formLow  = 0.0
    float  opUpper  = 0.0
    float  opLower  = 0.0
    float  rsiAtBreak     = 0.0
    float  adxAtBreak     = 0.0
    float  plusDIAtBreak  = 0.0
    float  minusDIAtBreak = 0.0
    label  brkLabel

// ═══ Detection Engine | محرّك الكشف ═══
f_ma(float src, int len, string maType) =>
    float maS = ta.sma(src, len)
    float maE = ta.ema(src, len)
    float maW = ta.wma(src, len)
    switch maType
        "SMA" => maS
        "EMA" => maE
        => maW

float averagePrice    = f_ma(close, i_rangePeriod, i_maType)
float priceVolatility = ta.atr(i_atrPeriod) * i_rangeMultiplier

float highestCloseWin = ta.highest(close, i_rangePeriod)
float lowestCloseWin  = ta.lowest(close, i_rangePeriod)
float hiDev = highestCloseWin - averagePrice
float loDev = averagePrice - lowestCloseWin
bool  isInRange = math.max(hiDev, loDev) <= priceVolatility

float pearsonR   = ta.correlation(close, bar_index, i_rangePeriod)
float corrThresh = i_corrSigma / math.sqrt(i_rangePeriod - 1)
bool  isSideways = math.abs(nz(pearsonR)) <= corrThresh

// ═══ Formation Gates | بوابات التكوين ═══
float windowAmplitude = ta.highest(high, i_rangePeriod) - ta.lowest(low, i_rangePeriod)
float rangeAmp  = averagePrice > 0 ? windowAmplitude / averagePrice : 1.0
bool  ampOK     = rangeAmp <= i_maxRangePct / 100.0
int   entryK    = i_entryBars < i_rangePeriod ? i_entryBars : i_rangePeriod
float entryMove = (bar_index >= i_rangePeriod and averagePrice > 0) ? math.abs(close[i_rangePeriod - entryK] - close[i_rangePeriod - 1]) / averagePrice : 1.0
bool  entryOK   = entryMove <= i_maxEntrySlopePct / 100.0

float dispersionRaw = ta.dev(close, i_rangePeriod)

// ═══ Range Integrity Metrics | مقاييس تكامل النطاق ═══
float sumAbsChg      = math.sum(math.abs(ta.change(close)), i_rangePeriod)
float pathNoiseRatio = windowAmplitude > 0 ? sumAbsChg / windowAmplitude : 1.0
float avgCandleRange = math.sum(high - low, i_rangePeriod) / i_rangePeriod
float cohesionRatio  = windowAmplitude > 0 ? avgCandleRange / windowAmplitude : 1.0
int   halfLen         = math.max(2, i_rangePeriod / 2)
float devSecondHalf   = ta.dev(close, halfLen)
float devFirstHalf    = ta.dev(close, halfLen)[halfLen]
float dispTrend       = devFirstHalf > 0 ? (devFirstHalf - devSecondHalf) / devFirstHalf : 0.0
float liveUpperEdge   = averagePrice + priceVolatility
float liveLowerEdge   = averagePrice - priceVolatility
float edgeTol         = priceVolatility * 0.15
float touchesUp       = math.sum((high >= liveUpperEdge - edgeTol and close < liveUpperEdge) ? 1.0 : 0.0, i_rangePeriod)
float touchesDn       = math.sum((low  <= liveLowerEdge + edgeTol and close > liveLowerEdge) ? 1.0 : 0.0, i_rangePeriod)
float edgeTouches     = touchesUp + touchesDn
float scorePathNoise  = math.max(0.0, math.min(100.0, 100.0 - (pathNoiseRatio - 1.0) * 40.0))
float scoreCohesion   = math.max(0.0, math.min(100.0, 100.0 - (cohesionRatio - 0.15) * 150.0))
float scoreDispTrend  = math.max(0.0, math.min(100.0, 50.0 + dispTrend * 100.0))
float scoreEdgeTouch  = math.max(0.0, math.min(100.0, edgeTouches * 20.0))
float integrityRaw    = (scorePathNoise + scoreCohesion + scoreDispTrend + scoreEdgeTouch) / 4.0

float upMove   = ta.change(high)
float dnMove   = -ta.change(low)
float plusDM   = na(upMove) ? 0.0 : (upMove > dnMove and upMove > 0 ? upMove : 0.0)
float minusDM  = na(dnMove) ? 0.0 : (dnMove > upMove and dnMove > 0 ? dnMove : 0.0)
float trur     = ta.rma(ta.tr, i_priorLen)
float rmaPlus  = ta.rma(plusDM,  i_priorLen)
float rmaMinus = ta.rma(minusDM, i_priorLen)
float plusDI   = na(trur) or trur == 0 ? 0.0 : 100 * rmaPlus  / trur
float minusDI  = na(trur) or trur == 0 ? 0.0 : 100 * rmaMinus / trur
float diSum    = plusDI + minusDI
float dxVal    = diSum == 0 ? 0.0 : 100 * math.abs(plusDI - minusDI) / diSum
float adxVal   = ta.rma(dxVal, i_priorLen)
bool  adxUpVal = plusDI > minusDI

float adxLeft  = adxVal[i_rangePeriod]
bool  upLeft   = adxUpVal[i_rangePeriod]
float rsiChg  = ta.change(close)
float rsiGain = rsiChg > 0 ? rsiChg : 0.0
float rsiLoss = rsiChg < 0 ? -rsiChg : 0.0
float avgGain = ta.rma(rsiGain, i_rsiLen)
float avgLoss = ta.rma(rsiLoss, i_rsiLen)
float rsiVal  = (avgGain + avgLoss == 0) ? 50.0 : (avgLoss == 0 ? 100.0 : 100.0 - 100.0 / (1.0 + avgGain / avgLoss))

f_rsiAt(float hypClose, float prevClose, float prevAvgGain, float prevAvgLoss, int len) =>
    float chg = hypClose - prevClose
    float g = chg > 0 ? chg : 0.0
    float l = chg < 0 ? -chg : 0.0
    float ag = (prevAvgGain * (len - 1) + g) / len
    float al = (prevAvgLoss * (len - 1) + l) / len
    (ag + al == 0) ? 50.0 : (al == 0 ? 100.0 : 100.0 - 100.0 / (1.0 + ag / al))

// ═══ Break-Quality Function | دالّة جودة الكسر ═══
f_breakQuality(bool isUp, float qADX, float qRSI, float qDepth, float qDisp, float qPlus, float qMinus) =>
    int   sADX   = qADX > i_adxOverheat ? -1 : (qADX >= i_adxHealthyMin ? 1 : 0)
    int   sRSI   = isUp ? (qRSI >= i_rsiOB ? -1 : 1) : (qRSI <= i_rsiOS ? -1 : 1)
    int   sDepth = qDepth >= i_depthStrong ? 1 : -1
    int   sDisp  = qDisp  >= i_dispStrong  ? 1 : -1
    float diSp   = isUp ? (qPlus - qMinus) : (qMinus - qPlus)
    int   sDI    = diSp >= i_diMargin ? 1 : (diSp <= 0 ? -1 : 0)
    sADX + sRSI + sDepth + sDisp + sDI

// ═══ Box Lifecycle Methods | طرق دورة حياة الصندوق ═══
method create(RangeBox this, float avg, float vol, int period, bool pUp, float pADX, float pDispersion, float fHigh, float fLow, float pIntegrity) =>
    bool prevClosed = this.everFormed and not this.active
    if not (i_showHistorical and prevClosed)
        box.delete(this.theBox)
        box.delete(this.formBox)
        label.delete(this.brkLabel)
    this.everFormed := true
    this.upperBound := avg + vol
    this.lowerBound := avg - vol
    this.opUpper    := innerOp ? fHigh : (avg + vol)
    this.opLower    := innerOp ? fLow : (avg - vol)
    this.startBar   := math.max(0, bar_index - (period - 1))
    this.active     := true
    this.priorUp    := pUp
    this.priorADX   := pADX
    this.brokeDir   := 0
    this.dispersionRatio := pDispersion
    this.integrityScore := pIntegrity
    this.formHigh   := fHigh
    this.formLow    := fLow
    this.theBox     := showMain  ? box.new(this.startBar, this.upperBound, bar_index, this.lowerBound, border_color=color.new(i_neutralColor, 0), bgcolor=i_neutralColor) : na
    this.formBox    := showInner ? box.new(this.startBar, fHigh, bar_index, fLow, border_color=color.new(i_closeBoxColor, 0), bgcolor=color(na), border_width=i_closeBoxWidth, border_style=(i_closeBoxStyle == "Dotted" ? line.style_dotted : i_closeBoxStyle == "Dashed" ? line.style_dashed : line.style_solid)) : na
    this

method update(RangeBox this) =>
    if this.active and not na(this.theBox)
        box.set_right(this.theBox, bar_index)
    if this.active and not na(this.formBox)
        box.set_right(this.formBox, bar_index)
    this

method breakout(RangeBox this, bool isUp, float depth, float rsiV, float adxV, float diPlus, float diMinus) =>
    this.active     := false
    this.brokeDir   := isUp ? 1 : -1
    this.breachDepth := depth
    this.rsiAtBreak := rsiV
    this.adxAtBreak := adxV
    this.plusDIAtBreak  := diPlus
    this.minusDIAtBreak := diMinus
    this.lastKeptRight := bar_index
    color bc = isUp ? i_upColor : i_downColor
    if innerOp
        if not na(this.formBox)
            box.set_border_color(this.formBox, color.new(bc, 0))
    else
        if not na(this.theBox)
            box.set_bgcolor(this.theBox, bc)
            box.set_border_color(this.theBox, color.new(bc, 0))
    this

// ═══ Main Execution | التنفيذ الرئيسي ═══
var RangeBox rangeBox     = RangeBox.new()
var bool     pendingRange = false

bool buyEvent  = false
bool sellEvent = false

bool boxLive       = rangeBox.active
bool liveBreachUp  = boxLive and close > rangeBox.opUpper
bool liveBreachDn  = boxLive and close < rangeBox.opLower
bool liveBreach    = liveBreachUp or liveBreachDn
var bool pulsedUp = false
var bool pulsedDn = false
if barstate.isnew
    pulsedUp := false
    pulsedDn := false
bool liveBreachPulseUp = i_liveBreach and liveBreachUp and not pulsedUp
bool liveBreachPulseDn = i_liveBreach and liveBreachDn and not pulsedDn
if liveBreachPulseUp
    pulsedUp := true
if liveBreachPulseDn
    pulsedDn := true

rangeBox.update()
if rangeBox.active
    if innerOp and not na(rangeBox.formBox)
        box.set_border_color(rangeBox.formBox, liveBreach ? i_breachColor : color.new(i_closeBoxColor, 0))
    if not innerOp and not na(rangeBox.theBox)
        box.set_border_color(rangeBox.theBox, liveBreach ? i_breachColor : color.new(i_neutralColor, 0))

// RSI evaluated AT the box boundary price, not at the (possibly far-overshot) candle close
float rsiAtUpperNow = rangeBox.active ? f_rsiAt(rangeBox.opUpper, close[1], avgGain[1], avgLoss[1], i_rsiLen) : na
float rsiAtLowerNow = rangeBox.active ? f_rsiAt(rangeBox.opLower, close[1], avgGain[1], avgLoss[1], i_rsiLen) : na

if barstate.isconfirmed

    bool bothGatesNow  = isInRange and isSideways and ampOK and entryOK
    bool bothGatesPrev = isInRange[1] and isSideways[1] and ampOK[1] and entryOK[1]
    bool strongPriorTrend = not i_requirePriorTrend or nz(adxLeft) >= i_minPriorADX
    bool edgeNew = bothGatesNow and not bothGatesPrev and bar_index >= i_rangePeriod and not rangeBox.active and strongPriorTrend
    bool retryOk = pendingRange and isInRange and isSideways and ampOK and entryOK and not rangeBox.active and strongPriorTrend
    if edgeNew or retryOk
        int  windowStart = bar_index - i_rangePeriod
        bool cleanWindow = (not i_showHistorical) or na(rangeBox.lastKeptRight) or windowStart > rangeBox.lastKeptRight
        if cleanWindow
            float dispersionRatioAtCreate = priceVolatility > 0 ? dispersionRaw / priceVolatility : 0.0
            rangeBox.create(averagePrice, priceVolatility, i_rangePeriod, upLeft, nz(adxLeft), dispersionRatioAtCreate, highestCloseWin, lowestCloseWin, integrityRaw)
            pendingRange := false
        else
            pendingRange := true
    if not isInRange
        pendingRange := false

    if rangeBox.active
        float boxH = (rangeBox.upperBound - rangeBox.lowerBound) / 2.0
        if close > rangeBox.opUpper
            float depthUp = boxH > 0 ? (close - rangeBox.opUpper) / boxH : 0.0
            rangeBox.breakout(true, depthUp, rsiAtUpperNow, adxVal, plusDI, minusDI)
            buyEvent := true
        else if close < rangeBox.opLower
            float depthDn = boxH > 0 ? (rangeBox.opLower - close) / boxH : 0.0
            rangeBox.breakout(false, depthDn, rsiAtLowerNow, adxVal, plusDI, minusDI)
            sellEvent := true

// ═══ Break-Quality Score | تسجيل جودة الكسر ═══
int  gScore = 0
if rangeBox.brokeDir != 0 and i_qualEnable
    gScore := f_breakQuality(rangeBox.brokeDir > 0, rangeBox.adxAtBreak, rangeBox.rsiAtBreak, rangeBox.breachDepth, rangeBox.dispersionRatio, rangeBox.plusDIAtBreak, rangeBox.minusDIAtBreak)
bool strongBreakEvent = (buyEvent or sellEvent) and i_qualEnable and gScore >= i_scoreStrong
bool trapBreakEvent   = (buyEvent or sellEvent) and i_qualEnable and gScore <= i_scoreTrap

float labelOffset = math.max((high - low) * 0.15, priceVolatility * 0.05)
if i_showSignals and buyEvent
    rangeBox.brkLabel := label.new(bar_index, low - labelOffset, isAr ? "شراء" : "BUY", yloc=yloc.price, color=i_buyLabel, textcolor=color.white, style=label.style_label_up, size=size.small)
if i_showSignals and sellEvent
    rangeBox.brkLabel := label.new(bar_index, high + labelOffset, isAr ? "بيع" : "SELL", yloc=yloc.price, color=i_sellLabel, textcolor=color.white, style=label.style_label_down, size=size.small)

// ═══ Alerts | التنبيهات ═══
alertcondition(buyEvent,  "BUY (break up) | شراء (كسر صعودي)",  "🟢 BUY — close broke above range | شراء — إغلاق فوق النطاق")
alertcondition(sellEvent, "SELL (break down) | بيع (كسر هبوطي)", "🔴 SELL — close broke below range | بيع — إغلاق تحت النطاق")
alertcondition(liveBreachPulseUp, "Live Breach UP (intrabar) | اختراق لحظي صعودي (داخل الشمعة)", "⚡🟢 Price crossed ABOVE range top INTRABAR — informational, may revert before close | السعر تجاوز الحدّ العلوي لحظيًا — إخبار فقط، قد يرتدّ قبل الإغلاق")
alertcondition(liveBreachPulseDn, "Live Breach DOWN (intrabar) | اختراق لحظي هبوطي (داخل الشمعة)", "⚡🔴 Price crossed BELOW range bottom INTRABAR — informational, may revert before close | السعر تجاوز الحدّ السفلي لحظيًا — إخبار فقط، قد يرتدّ قبل الإغلاق")

alertcondition(strongBreakEvent, "Strong break | كسر قوي", "✅ Break quality STRONG — factors confirm continuation | جودة الكسر: قوي — العوامل تؤكّد الاستمرار")
alertcondition(trapBreakEvent, "Likely trap | مصيدة محتملة", "⚠️ Break quality LIKELY TRAP — reversal / stop-hunt risk | جودة الكسر: مصيدة محتملة — خطر انعكاس أو ضرب وقف")

// ═══ Table Display | عرض الجدول ═══
bool tblHasBox         = rangeBox.active
bool tblBroke          = rangeBox.brokeDir != 0
int  tblBarsSinceBreak = tblBroke ? bar_index - rangeBox.lastKeptRight : 0
bool showTableNow      = i_tblShow and (rangeBox.everFormed ? (tblHasBox or (tblBroke and tblBarsSinceBreak <= i_retestWindow)) : i_showLiveVals)

var table tbl = na
if barstate.islast
    if showTableNow
        pos = switch i_tblPos
            "Top Right"    => position.top_right
            "Middle Right" => position.middle_right
            "Bottom Right" => position.bottom_right
            "Top Left"     => position.top_left
            => position.bottom_left
        tblSize = switch i_tblSize
            "Tiny"   => size.tiny
            "Small"  => size.small
            "Normal" => size.normal
            "Large"  => size.large
            => size.small
        tbl := table.new(pos, 2, 15, bgcolor=color.new(#1E1E1E, 10), border_color=color.new(#000000, 50), border_width=1, frame_color=color.new(#000000, 0), frame_width=1)

        color hdrBg = color.new(#7E57C2, 20)
        table.cell(tbl, 0, 0, "Dynamic Range", text_color=color.white, text_size=tblSize, text_halign=text.align_center, bgcolor=hdrBg)
        table.cell(tbl, 1, 0, "", bgcolor=hdrBg)
        table.merge_cells(tbl, 0, 0, 1, 0)

        color cGreen = #26A69A
        color cRed   = #EF5350
        color cGray  = color.gray
        color cAmber = #FF9800

        bool   hasBox  = innerOp ? not na(rangeBox.formBox) : not na(rangeBox.theBox)
        bool   broke   = rangeBox.brokeDir != 0
        bool   pUp     = rangeBox.priorUp
        float  pADX    = rangeBox.priorADX
        float  boxHnow = hasBox ? (rangeBox.upperBound - rangeBox.lowerBound) / 2.0 : na
        int    effDir  = broke ? rangeBox.brokeDir : ((hasBox and close > rangeBox.opUpper) ? 1 : (hasBox and close < rangeBox.opLower) ? -1 : 0)
        bool   canQual = hasBox and effDir != 0
        bool   matched = canQual and ((effDir > 0) == pUp)
        string dash    = "—"
        string sStrong = isAr ? "قوي" : "Strong"
        string sWeak   = isAr ? "ضعيف" : "Weak"

        float  eADX  = broke ? rangeBox.adxAtBreak : adxVal
        float  eRSI  = broke ? rangeBox.rsiAtBreak : (effDir > 0 ? rsiAtUpperNow : (effDir < 0 ? rsiAtLowerNow : rsiVal))
        float  ePlus = broke ? rangeBox.plusDIAtBreak  : plusDI
        float  eMinus= broke ? rangeBox.minusDIAtBreak : minusDI
        float  eDepth= broke ? rangeBox.breachDepth : ((effDir > 0 and not na(boxHnow) and boxHnow > 0) ? (close - rangeBox.opUpper) / boxHnow : ((effDir < 0 and not na(boxHnow) and boxHnow > 0) ? (rangeBox.opLower - close) / boxHnow : na))
        float  eDisp = rangeBox.dispersionRatio
        float  eDiSp = effDir > 0 ? (ePlus - eMinus) : (effDir < 0 ? (eMinus - ePlus) : na)
        float  eIntegrity = (hasBox and broke) ? rangeBox.integrityScore : integrityRaw

        int    scA   = eADX > i_adxOverheat ? -1 : (eADX >= i_adxHealthyMin ? 1 : 0)
        int    scR   = effDir > 0 ? (eRSI >= i_rsiOB ? -1 : 1) : (effDir < 0 ? (eRSI <= i_rsiOS ? -1 : 1) : ((eRSI >= i_rsiOB or eRSI <= i_rsiOS) ? -1 : 1))
        int    scD   = na(eDepth) ? 0 : (eDepth >= i_depthStrong ? 1 : -1)
        int    scDsp = eDisp >= i_dispStrong ? 1 : -1
        int    scDI  = na(eDiSp) ? 0 : (eDiSp >= i_diMargin ? 1 : (eDiSp <= 0 ? -1 : 0))
        int    qScore = scA + scR + scD + scDsp + scDI

        table.cell(tbl, 0, 1, isAr ? "الاتجاه السابق" : "Prior trend", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 1, not hasBox ? dash : (pUp ? (isAr ? "صاعد ↑" : "Up ↑") : (isAr ? "هابط ↓" : "Down ↓")), text_color=not hasBox ? cGray : (pUp ? cGreen : cRed), text_size=tblSize, text_halign=text.align_right)

        table.cell(tbl, 0, 2, isAr ? "قوّة الاتجاه (ADX)" : "Trend strength (ADX)", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 2, not hasBox ? dash : str.tostring(pADX, "0.0"), text_color=pADX >= i_minPriorADX ? color.white : cGray, text_size=tblSize, text_halign=text.align_right)

        table.cell(tbl, 0, 3, isAr ? "اتجاه الكسر" : "Break direction", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 3, not broke ? (isAr ? "نشط —" : "Active —") : (rangeBox.brokeDir > 0 ? (isAr ? "شراء ↑" : "BUY ↑") : (isAr ? "بيع ↓" : "SELL ↓")), text_color=not broke ? cGray : (rangeBox.brokeDir > 0 ? cGreen : cRed), text_size=tblSize, text_halign=text.align_right)

        table.cell(tbl, 0, 4, isAr ? "مطابقة الاتجاه" : "Direction match", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        string matchTxt = not canQual ? dash : (matched ? (isAr ? "✓ مطابق" : "✓ Match") : (isAr ? "✗ عكسي" : "✗ Counter"))
        table.cell(tbl, 1, 4, matchTxt, text_color=not canQual ? cGray : (matched ? color.white : cAmber), text_size=tblSize, text_halign=text.align_right, bgcolor=not canQual ? na : (matched ? color.new(cGreen, 45) : color.new(cAmber, 70)))

        string adxSt = scA > 0 ? (isAr ? "صحّي" : "Healthy") : scA < 0 ? (isAr ? "محموم" : "Overheated") : (isAr ? "ضعيف" : "Weak")
        table.cell(tbl, 0, 5, "ADX", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 5, na(eADX) ? dash : (str.tostring(eADX, "0.0") + " " + adxSt), text_color=na(eADX) ? cGray : (scA > 0 ? cGreen : scA < 0 ? cRed : cGray), text_size=tblSize, text_halign=text.align_right)

        string rsiSt = scR > 0 ? (isAr ? "معتدل" : "Neutral") : (isAr ? "قرب تشبّع" : "Near sat.")
        table.cell(tbl, 0, 6, "RSI", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 6, na(eRSI) ? dash : (str.tostring(eRSI, "0.0") + " " + rsiSt), text_color=na(eRSI) ? cGray : (scR > 0 ? cGreen : cRed), text_size=tblSize, text_halign=text.align_right)

        string depTxt = not hasBox ? dash : (na(eDepth) ? (isAr ? "داخل النطاق" : "Inside range") : (str.tostring(eDepth, "0.00") + "H " + (scD > 0 ? sStrong : sWeak)))
        table.cell(tbl, 0, 7, isAr ? "عمق الاختراق" : "Breach depth", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 7, depTxt, text_color=(not hasBox or na(eDepth)) ? cGray : (scD > 0 ? cGreen : cRed), text_size=tblSize, text_halign=text.align_right)

        table.cell(tbl, 0, 8, isAr ? "تشتّت النطاق" : "Range dispersion", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 8, not hasBox ? dash : (str.tostring(eDisp, "0.00") + " " + (scDsp > 0 ? sStrong : sWeak)), text_color=not hasBox ? cGray : (scDsp > 0 ? cGreen : cRed), text_size=tblSize, text_halign=text.align_right)

        string diSt = effDir != 0 ? (scDI > 0 ? (isAr ? "مؤكِّد" : "Confirm") : scDI < 0 ? (isAr ? "معاكس" : "Against") : (isAr ? "ضعيف" : "Weak")) : (ePlus >= eMinus ? (isAr ? "صعوديّ" : "Bullish") : (isAr ? "هبوطيّ" : "Bearish"))
        color  diCol = na(ePlus) ? cGray : (effDir != 0 ? (scDI > 0 ? cGreen : scDI < 0 ? cRed : cGray) : (ePlus >= eMinus ? cGreen : cRed))
        table.cell(tbl, 0, 9, "DI (+/−)", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 9, na(ePlus) ? dash : (str.tostring(ePlus, "0.0") + "/" + str.tostring(eMinus, "0.0") + " " + diSt), text_color=diCol, text_size=tblSize, text_halign=text.align_right)

        string qVerdict = qScore >= i_scoreStrong ? (isAr ? "كسر قوي ✅" : "Strong break ✅") : (qScore <= i_scoreTrap ? (isAr ? "مصيدة محتملة ⚠️" : "Likely trap ⚠️") : (isAr ? "غير حاسم ⚖️" : "Inconclusive ⚖️"))
        color  qVerCol  = qScore >= i_scoreStrong ? cGreen : (qScore <= i_scoreTrap ? cRed : cAmber)
        string verShow  = not canQual ? dash : ((broke ? "" : "◷ ") + qVerdict + "  (" + (qScore > 0 ? "+" : "") + str.tostring(qScore) + ")")
        table.cell(tbl, 0, 10, isAr ? "تقييم الكسر" : "Break verdict", text_color=color.white, text_size=tblSize, text_halign=text.align_left, bgcolor=not canQual ? na : color.new(qVerCol, 55))
        table.cell(tbl, 1, 10, verShow, text_color=not canQual ? cGray : color.white, text_size=tblSize, text_halign=text.align_right, bgcolor=not canQual ? na : color.new(qVerCol, 35))

        string advice = na
        color  adviceC = cGray
        if not hasBox
            advice := isAr ? "لا صندوق حاليًّا" : "No box currently"
        else if not canQual
            advice := isAr ? "النطاق نشط — بانتظار الكسر لتقييم الجودة" : "Range active — awaiting break to assess quality"
        else
            string tag = broke ? "" : (isAr ? "◷ معاينة حيّة — " : "◷ Live preview — ")
            if qScore >= i_scoreStrong
                advice := tag + (isAr ? "كسر قوي؛ العوامل تؤكّد الاستمرار" : "Strong break; factors confirm continuation")
                adviceC := cGreen
            else if qScore <= i_scoreTrap
                advice := tag + (isAr ? "⚠️ مصيدة محتملة؛ خطر انعكاس أو ضرب وقف" : "⚠️ Likely trap; reversal or stop-hunt risk")
                adviceC := cRed
            else
                advice := tag + (isAr ? "إشارة مختلطة (محصّلة " : "Mixed (score ") + (qScore > 0 ? "+" : "") + str.tostring(qScore) + ")"
                adviceC := cAmber
        string fmtTxt = str.tostring(rangeAmp * 100, "0.0") + "% / " + str.tostring(entryMove * 100, "0.0") + "%"
        table.cell(tbl, 0, 11, isAr ? "امتداد/دخول %" : "Range/entry %", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 11, fmtTxt, text_color=(ampOK and entryOK) ? cGreen : cRed, text_size=tblSize, text_halign=text.align_right)

        string integLabel = eIntegrity >= i_integrityHigh ? (isAr ? "مرتفع" : "High") : (eIntegrity <= i_integrityLow ? (isAr ? "منخفض" : "Low") : (isAr ? "متوسط" : "Medium"))
        color  integCol   = eIntegrity >= i_integrityHigh ? cGreen : (eIntegrity <= i_integrityLow ? cRed : cAmber)
        table.cell(tbl, 0, 12, isAr ? "تكامل النطاق 🧪" : "Range integrity 🧪", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 12, str.tostring(eIntegrity, "0") + " " + integLabel, text_color=integCol, text_size=tblSize, text_halign=text.align_right)

        string ageTxt = not hasBox ? dash : (str.tostring((broke ? rangeBox.lastKeptRight : bar_index) - rangeBox.startBar) + (isAr ? " شمعة" : " bars"))
        table.cell(tbl, 0, 13, isAr ? "عمر النطاق" : "Range age", text_color=cGray, text_size=tblSize, text_halign=text.align_left)
        table.cell(tbl, 1, 13, ageTxt, text_color=cGray, text_size=tblSize, text_halign=text.align_right)

        table.cell(tbl, 0, 14, advice, text_color=color.white, text_size=tblSize, text_halign=text.align_center, bgcolor=color.new(adviceC, 70))
        table.cell(tbl, 1, 14, "", bgcolor=color.new(adviceC, 70))
        table.merge_cells(tbl, 0, 14, 1, 14)
    else if not na(tbl)
        table.delete(tbl)
        tbl := na
````
