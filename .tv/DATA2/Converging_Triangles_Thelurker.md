<!-- tradingview-pine-id: PUB;f22782f0863d418f971dd339bbc44f20 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Converging Triangles [The_lurker]

Source: https://www.tradingview.com/script/USJwxdTS/

## Description

🔻  CONVERGING TRIANGLES — المثلثات المتقاربة  🔺

No repaint. Nothing that appears ever moves, shifts, or disappears.

Converging Triangles identifies contracting price structures built from confirmed swing pivots: a falling resistance line and a rising support line that coexist in time and close on each other. It runs three independent scales at once, freezes each structure the moment it is identified, and reports the two boundary prices and the exact bar they were crossed.

🔶  1 — THE STRUCTURE

A converging triangle here is not a shape matched against a template. It is a state: two independently valid trendlines, alive at the same time, closing on each other.

[*]Upper boundary — anchored on the two most recent confirmed swing highs, sloping down.
[*]Lower boundary — anchored on the two most recent confirmed swing lows, sloping up.

Because the constraint is on the sign of each slope, the detected family covers symmetric triangles and the near-flat ascending and descending variants. Wedges, where both boundaries slope the same way, are excluded by construction and never appear.

🔶  2 — HOW A STRUCTURE IS ADMITTED

Each boundary must pass every test below, and both boundaries must pass simultaneously before a structure is drawn. One failed test drops the whole structure.

🔸 PER BOUNDARY — five conditions

[*]Pivot confirmation — both anchors are swing points confirmed by "length" bars on each side.
[*]Span — at least 3 bars between anchors, at most length × Max span.
[*]Slope direction — the upper boundary must fall, the lower must rise.
[*]Interior containment — no bar between the two anchors violates the line.
[*]Forward containment — no bar from the second anchor to the present violates the line.

🔸 PER STRUCTURE — three conditions

[*]Both sides live — neither boundary has been broken.
[*]Time overlap — the two boundaries share a common bar range, so no line is drawn across a region where it has no anchors.
[*]Convergence horizon — the projected intersection falls inside Min bars to apex … Max bars to apex.

🔒 Once admitted, the geometry is frozen. Anchor points and slopes never change for the life of that structure.

🔶  3 — READING THE DRAWING

Each boundary is drawn in two segments, and the difference is deliberate.

[*]Solid segment — spans the boundary's own two anchors. This is measured containment, confirmed by the market.
[*]Dotted segment — from the last anchor to the present bar. This is pure extrapolation.

You can always see where the confirmed part ends and the projected part begins.

A single fill binds the two boundaries into one object rather than two unrelated strokes. Its corners are the two starting anchors and the two current endpoints, so the left edge is a slant, not a vertical cut, and the wedge tip is filled.

🔸 COLOUR STATES

[*]⚪ Forming — neutral grey. No directional claim is made before resolution.

[image]https://www.tradingview.com/x/FWQjrPWd/[/image]

[*]🟢 Broken up — green. Lines and fill together.

[image]https://www.tradingview.com/x/fb6IBL8K/[/image]

[*]🔴 Broken down — red. Lines and fill together.

[image]https://www.tradingview.com/x/hNupdIX5/[/image]

The structure stays neutral for its entire life. Direction is asserted only after a break is confirmed at bar close.

🔶  4 — BREAK DETECTION

On every confirmed bar, the break source is compared against both boundaries at that bar.

[*]If one boundary is violated, the structure resolves in that direction.
[*]If a single bar violates both boundaries, resolution goes to the side with the larger excursion beyond its line.

The shape is then redrawn in the break colour and frozen at the break bar. It does not extend forward afterward.

🏷️ A break label is placed at the bar, carrying its layer letter and any tags that fired.

🔶  5 — THREE INDEPENDENT SCALES

📏 Large (21) · Mid (14) · Small (5)

Contraction is not a single event. A large structure can be narrowing while a small one narrows inside it, and each can resolve in the opposite direction to the other. That is information worth seeing, not a conflict to hide.

Each layer detects, tracks, and resolves independently. Break labels carry L, M, or S, so the scale is always identifiable. Any layer can be switched off.

🔶  6 — HISTORICAL ARCHIVE

🗂️ Optional, off by default.

When enabled, a resolved structure is not deleted but redrawn at a faded shade. Over time this builds a map of where previous contractions broke on that symbol, under a count cap you control, with oldest-first eviction.

[image]https://www.tradingview.com/x/IaZGZDYy/[/image]

The fade is a separate control: set it to zero and archived structures render identically to live ones.

[*]A structure that expires at the apex without resolving is not archived, since there is no event in it to keep.
[*]Archived structures carry no label. Their colour and position already carry the direction.

🔶  7 — INFORMATION PANEL

[image]https://www.tradingview.com/x/7GUPmANq/[/image]

📋 Reports the nearest live structure, or the nearest recently resolved one if none is live.

[*]Layer — Large / Mid / Small. Coloured by resolution direction once broken.
[*]Upper — the exact upper boundary price, ready to place an order against.
[*]Lower — the same for the lower boundary.
[*]Width (ATR) — current width in ATR units. After a break it becomes "Width at break", measured against the ATR recorded at that same bar, so the number stays fixed for a frozen structure and does not drift as volatility changes.
[*]Projected apex — bars until the two boundaries intersect. After a break it becomes "Since break".
[*]Status — Active · Break pending at close · Broken up · Broken down.

⚠️ The status row alone reads the live bar. It can move between pending and active within a single bar as price crosses back and forth. That is a live readout, labelled as such, not a repaint. The drawn geometry does not move.

🔶  8 — BREAK TAGS

[image]https://www.tradingview.com/x/ukt9e0o3/[/image]

Two optional descriptive measurements, shown on the break bar when they occur.

[*]📊 V — break-bar volume exceeded its moving average by the configured multiplier.
[*]📐 E — break-bar true range exceeded ATR by the configured multiplier.

These describe what happened on that bar. They are not quality scores or confidence grades, and they do not filter anything.

🔶  9 — ALERTS

[*]🔔 Pattern formed — a new structure is admitted.
[*]🔔 Break up — upper boundary broken.
[*]🔔 Break down — lower boundary broken.
[*]🔔 Any resolution — either break.

All alerts fire once per bar close, never before.

🔶  10 — SETTINGS REFERENCE

The icons below match the group headers you see inside the indicator's settings window.

🔸 ⚙️ SETUP

[*]Language — default English. Switching to Arabic changes the entire interface.
[*]Log scale — default Off. Must be matched to your chart's scale manually. See section 12.
[*]ATR length — default 14. Feeds the E tag, the demote distance, and the panel width reading.

🔸 📏 LAYERS

[*]Large L — default On, length 21.
[*]Mid M — default On, length 14.
[*]Small S — default On, length 5.

🔸 🔎 DETECTION

[*]Close-only pivots — default Off. Off anchors on highs and lows; On anchors on closes.
[*]Break source — default Close. One switch governing three things at once: interior containment, forward containment, and break detection.
[*]Max span (× length) — default 5. Ceiling on bars between a boundary's two anchors.
[*]Min side overlap — default 0. Required shared bar range between the two boundaries.
[*]Min bars to apex — default 2.
[*]Max bars to apex — default 200.

🔸 🎨 APPEARANCE

[*]Fill triangle — default On, transparency 78.
[*]Line width 2, line transparency 15.
[*]Colours — grey while forming, green for an upward break, red for a downward break.

🔸 🗂️ HISTORY AND LIFETIME

[*]Keep as current (bars) — default 30. After this the structure is demoted to the archive, or deleted if the archive is off.
[*]Demote beyond (ATR) — default 8.0. Measured against current ATR by design: the question is how far price is now, in today's volatility.
[*]Show historical patterns — default Off.
[*]Historical kept — default 12, a cap across all three layers combined.
[*]Historical fade — default 30, added on top of line and fill transparency.

🔸 🏷️ LABELS

[*]Show labels — default On, 2 kept.
[*]Volume tag V — default On. MA 20, multiplier 1.5.
[*]Range expansion E — default On. Multiplier 1.4.

🔸 📋 PANEL

[*]Show panel — default On, positioned top right.

🔶  11 — ON ACCURACY

Two different things get called accuracy. Only one of them is claimed here.

✅ Structural accuracy is exact and independently verifiable. Every anchor is a confirmed pivot, never a guess. Every line satisfies its containment test at the bar it is drawn. Geometry closes at formation and is never recalculated. A break is settled by a single unambiguous test on a closed bar. Nothing is repainted, backfilled, or silently adjusted. Replay any chart and trace any element yourself.

❌ Predictive accuracy is not claimed. You will find no win rate here, no signal grade, and no price target.

The indicator tells you precisely where the boundaries are and precisely when they were crossed. What that is worth in your strategy, on your instrument, at your timeframe, is yours to determine and yours to risk.

🔶  12 — BEHAVIOUR TO UNDERSTAND BEFORE TRUSTING THE CHART

[*]⚠️ Why a structure appears late. A pivot is not a pivot until its full confirmation bars have passed. That delay is the price of the promise in the first line: nothing appears before its time, and nothing that appears is taken back afterward.
[*]⚠️ A wick may cross a line. By default, anchors sit on highs and lows while containment and break detection are tested on the close. A wick can pierce a boundary while the structure remains valid. Set Break source = Wick for a shape no wick ever touches, and expect noticeably fewer structures from that considerably stricter test.
[*]⚠️ Log scale is manual. Pine cannot read your chart's scale setting. If your chart is logarithmic, enable Log scale. When the two disagree, the computed break level diverges from the drawn line: negligible on narrow structures, material on wide ones. The tell is visible on the chart itself, as the left fill edge separates from the boundary at the second anchor.
[*]⚠️ Where anchors come from. Each boundary is built from the two most recent pivots on its own side. A line that would skip an intermediate pivot is outside the detection scope.
[*]⚠️ Density. Three layers with a full archive weighs the chart down. Disable the layers you do not need, and use the archive cap and the fade to control it.

═════════════════════════════════════════════════════════════
⚠️ DISCLAIMER
═════════════════════════════════════════════════════════════

This indicator is for educational and analytical purposes only. It does not constitute financial, investment, or trading advice. Use it alongside your own strategy and risk management. Neither TradingView nor the developer is responsible for any financial decisions or losses.

═════════════════════════════════════════════════════════════

🔻  المثلثات المتقاربة  —  Converging Triangles 🔺

ما يظهر على الشارت لا يتحرك ولا ينزاح ولا يُسحب لاحقاً. لا إعادة رسم.

يبحث المؤشر عن حالة واحدة لا عن شكل: أن يجتمع خط مقاومة هابط مع خط دعم صاعد في الوقت نفسه، وأن يضيق ما بينهما شمعةً بعد شمعة. فإذا اجتمعا واستوفى كلٌّ منهما شروطه، رُسم النطاق وتجمّدت هندسته في اللحظة نفسها، فلا تتغيّر بعدها مهما فعل السعر.

🔶  أول ما ينبغي أن تعرفه

لأنه لا يبحث عن شكل يطابقه بقالب جاهز، فهو لا يفرض عليك تسمية. هو يعطيك حدّين بسعرين محدّدين، ويخبرك متى عُبر أحدهما بالضبط. أما ما تفعله بذلك فأنت وحدك.

[*]الحد العلوي — مرسي على آخر قمتين مؤكَّدتين، هابط.
[*]الحد السفلي — مرسي على آخر قاعين مؤكَّدين، صاعد.

ولأن الشرط على إشارة كل ميل، فالعائلة المكتشَفة تشمل المثلث المتماثل والنسخ شبه المستوية من الصاعد والهابط. أما الوتدان، حيث يميل الحدّان في اتجاه واحد، فمستبعدان بالبناء ولا يظهران أبداً.

ويعمل على ثلاثة مقاييس في وقت واحد، لكل مقياس نموذجه المستقل.

🔶  متى يُرسم النطاق؟

لا يُرسم شيء ما لم يستوفِ كل حد شروطه الخمسة، ثم يجتمع الحدّان معاً على ثلاثة شروط أخرى. وأي شرط يسقط يُسقط النموذج كله.

🔸 الحد الواحد — خمسة شروط

[*]أن يقوم على محورين مؤكَّدين. والمحور لا يُعدّ مؤكَّداً إلا بعد أن تمرّ عليه شموع التأكيد كاملة على الجانبين.
[*]أن تكون المسافة بين المحورين ثلاث شموع فأكثر، ولا تتجاوز الطول مضروباً في «أقصى مسافة».
[*]أن يكون العلوي هابطاً والسفلي صاعداً.
[*]ألا تخرق أي شمعة الخط في الفترة الواقعة بين المحورين.
[*]ألا تخرقه أي شمعة من المحور الثاني إلى اللحظة الحالية.

🔸 الحدّان معاً — ثلاثة شروط

[*]أن يكون كلاهما سليماً لم يُكسر.
[*]أن يتعايشا على فترة زمنية مشتركة. وهذا الشرط يمنع أن يُرسم خط في منطقة لا محاور له فيها أصلاً.
[*]أن يقع تقاطعهما المتوقَّع ضمن المدى الذي تحدّده بين «أدنى مسافة للرأس» و«أقصاها».

🔒 وبعد القبول تُغلق الهندسة نهائياً: المحاور ثابتة والميلان ثابتان، ولا شيء يُعاد حسابه.

🔶  كيف تقرأ ما تراه

لكل حد مقطعان، والفرق بينهما مقصود لا زخرفي:

[*]المقطع الصلب يمتد بين محوري ذلك الحد، وهو ما تحقّق فعلاً واحتواه السوق.
[*]المقطع المنقّط يمتد من المحور الأخير إلى الشمعة الحالية، وهو استقراء لا أكثر.

فأنت ترى في كل لحظة أين ينتهي المؤكَّد ويبدأ المتوقَّع.

وتربط بين الحدّين تعبئة واحدة تجعلهما كياناً واحداً لا خطّين منفصلين. وقد أُخذت أركانها من محورَي البداية الفعليين، ولذلك جاءت الحافة اليسرى مائلة يمتلئ عندها رأس الشكل، لا مقطوعة عمودياً.

🔸 واللون يحمل الحالة وحدها

[*]⚪ رمادي محايد ما دام النطاق حيّاً. فلا اتجاه يُدّعى قبل أن يُحسم.

[image]https://www.tradingview.com/x/FWQjrPWd/[/image]

[*]🟢 أخضر إذا حُسم بالخروج من الأعلى. الخطوط والتعبئة معاً.

[image]https://www.tradingview.com/x/fb6IBL8K/[/image]

[*]🔴 أحمر إذا حُسم بالخروج من الأسفل. الخطوط والتعبئة معاً.

[image]https://www.tradingview.com/x/hNupdIX5/[/image]

فالنطاق يبقى محايداً طوال حياته، ولا يُعلن الاتجاه إلا بعد أن تُغلق الشمعة خارج أحد الحدّين.

🔶  متى يُعدّ النطاق مكسوراً

عند إغلاق كل شمعة يُقاس السعر على الحدّين معاً.

[*]فإن خرج من أحدهما حُسم النطاق في اتجاهه.
[*]وقد تأتي شمعة عنيفة تخرج من الحدّين كليهما، وعندها يُحسم للجهة التي ابتعد عنها السعر أكثر.

ثم يُعاد رسم الشكل بلون الخروج ويُثبَّت عند شمعته، فلا يمتد بعدها إلى الأمام.

🏷️ وتوضع عندها تسمية تحمل حرف المقياس (L أو M أو S) ووسوم الشمعة إن تحقّقت.

🔶  لماذا ثلاثة مقاييس

📏 كبير 21 · متوسط 14 · صغير 5

لأن الانضغاط ليس حدثاً واحداً. فقد يضيق نطاق كبير بينما يضيق داخله نطاق صغير، ويخرج كلٌّ منهما في اتجاه مضاد للآخر. وهذا في نفسه معلومة تستحق أن تُرى، لا تعارضاً يجب إخفاؤه.

ولذلك تعمل الطبقات الثلاث باستقلال تام، ويحمل كل خروج حرف مقياسه فلا يختلط عليك من أين جاء. وتستطيع إطفاء أي طبقة لا تحتاجها.

🔶  النماذج السابقة

🗂️ خيار مطفأ افتراضياً.

إن شغّلته، لم يُمحَ النموذج بعد حسمه، بل بقي مرسوماً بدرجة خافتة. وبمرور الوقت تتكوّن لديك خريطة لمواضع الخروج السابقة على الرمز نفسه، بسقف عددي تحدّده أنت، ويُخلى الأقدم فالأقدم.

[image]https://www.tradingview.com/x/IaZGZDYy/[/image]

ودرجة الخفوت مستقلة بيدك: إن أنزلتها إلى الصفر صارت النماذج القديمة كالحيّة تماماً.

[*]والنموذج الذي انتهى عمره دون خروج لا يدخل الأرشيف، إذ لا حدث فيه يُحفظ.
[*]والنماذج المؤرشفة بلا تسميات، فلونها وموضعها يكفيان.

🔶  لوحة المعلومات

[image]https://www.tradingview.com/x/7GUPmANq/[/image]

📋 تعرض اللوحة أقرب نطاق حيّ إليك، فإن لم يوجد عرضت أقرب نطاق حُسم حديثاً.

[*]الطبقة — كبير أو متوسط أو صغير، وتُلوَّن باتجاه الخروج بعد حسمه.
[*]الحد العلوي — سعره بالضبط، جاهزاً لوضع أمر عليه.
[*]الحد السفلي — كذلك.
[*]العرض بوحدات ATR — وبعد الخروج يصير «العرض عند الكسر»، محسوباً بـ ATR المسجّل في تلك الشمعة نفسها. فالرقم يبقى ثابتاً لنموذج مجمّد ولا ينزاح بتغيّر التقلّب.
[*]الرأس المتوقَّع — كم شمعة تفصل عن تقاطع الحدّين. وبعد الخروج يصير «منذ الكسر».
[*]الحالة — نشط، أو كسر معلّق يثبت بالإغلاق، أو كُسر لأعلى، أو كُسر لأسفل.

⚠️ وسطر الحالة وحده يقرأ الشمعة الجارية، فقد ينتقل داخلها بين «معلّق» و«نشط» كلما دخل السعر وخرج. وهذه قراءة لحظية مكتوب فيها صراحة أنها تثبت بالإغلاق، وليست إعادة رسم: الشكل المرسوم لا يتحرك.

🔶  الوسمان V و E

[image]https://www.tradingview.com/x/ukt9e0o3/[/image]

يظهران على شمعة الخروج إن تحقّقا:

[*]📊 V — تجاوز حجم الشمعة متوسطه بالمضاعف الذي ضبطته.
[*]📐 E — تجاوز مداها الحقيقي مؤشر ATR بالمضاعف الذي ضبطته.

وهما وصفٌ لما جرى في تلك الشمعة، لا حكم على جودة الخروج ولا درجة ثقة فيه. ولا يمنعان ظهور أي نموذج.

🔶  التنبيهات

[*]🔔 تكوّن نموذج
[*]🔔 كسر لأعلى
[*]🔔 كسر لأسفل
[*]🔔 أي حل — يجمع الاثنين

وجميعها تشتعل مرة واحدة عند إغلاق الشمعة لا قبله.

🔶  الإعدادات

الرموز أدناه هي نفسها التي تراها على رؤوس المجموعات داخل نافذة إعدادات المؤشر.

🔸 ⚙️ الإعداد

[*]اللغة — إنجليزي افتراضاً، وتبديلها إلى العربية يغيّر الواجهة كلها.
[*]المقياس اللوغاريتمي — مطفأ افتراضاً. اضبطه ليطابق شارتك، وانظر آخر قسم.
[*]طول ATR — 14. يخدم وسم E ومسافة إخلاء النماذج وقراءة العرض في اللوحة.

🔸 📏 الطبقات

[*]كبير L — مفعّل، بطول 21.
[*]متوسط M — مفعّل، بطول 14.
[*]صغير S — مفعّل، بطول 5.

🔸 🔎 الكشف

[*]محاور على الإغلاق فقط — مطفأ. فتُؤخذ المحاور من القمم والقيعان. وبتشغيله تُؤخذ من الإغلاقات وحدها.
[*]مصدر الكسر — Close. وهو مفتاح واحد يحكم ثلاثة أشياء دفعة واحدة: الاحتواء بين المحورين، والاحتواء بعدهما، وكشف الخروج.
[*]أقصى مسافة مضروبة في الطول — 5. سقف ما بين محورَي الحد الواحد.
[*]أدنى تداخل بين الضلعين — 0. الفترة المشتركة المطلوبة بين الحدّين.
[*]أدنى مسافة للرأس — 2.
[*]أقصى مسافة للرأس — 200.

🔸 🎨 المظهر

[*]تعبئة المثلث — مفعّلة، بشفافية 78.
[*]عرض الخط 2، وشفافيته 15.
[*]الألوان — رمادي للتكوّن، أخضر للخروج علواً، أحمر للخروج هبوطاً.

🔸 🗂️ التاريخ والعمر

[*]إبقاؤه كالحالي — 30 شمعة، ثم يُنزَّل إلى الأرشيف أو يُحذف إن كان الأرشيف مطفأً.
[*]التنزيل عند البُعد — 8 من ATR. ويُقاس بـ ATR الحالي عن قصد، لأن السؤال هنا عن بُعد السعر الآن بمقياس تقلّب اليوم لا تقلّب الأمس.
[*]إظهار النماذج السابقة — مطفأ.
[*]عدد النماذج المحفوظة — 12، وهو سقف على الطبقات الثلاث مجتمعة.
[*]خفوت التاريخية — 30، تُضاف فوق شفافية الخط والتعبئة.

🔸 🏷️ التسميات

[*]إظهار التسميات — مفعّل، ويُحفظ منها 2.
[*]وسم الحجم V — مفعّل، بمتوسط 20 ومضاعف 1.5.
[*]وسم التمدد E — مفعّل، بمضاعف 1.4.

🔸 📋 اللوحة

[*]مفعّلة، وموضعها أعلى اليمين.

🔶  الدقة: أي دقة؟

تُطلق كلمة «الدقة» على معنيين مختلفين، ولا يُدّعى هنا إلا واحد منهما.

✅ فأما دقة البناء فمضبوطة، وتستطيع التحقق منها بنفسك دون أن تصدّقني: كل محور مؤكَّد لا مظنون، وكل خط يستوفي شرط احتوائه عند الشمعة التي رُسم فيها، والهندسة تُغلق عند التكوّن فلا يُعاد حسابها، والخروج يُحسم باختبار واحد على شمعة مغلقة. لا شيء يُعاد رسمه، ولا يُملأ بأثر رجعي، ولا يُعدَّل في الخفاء. أعد تشغيل أي شارت وتتبّع أي عنصر.

❌ وأما الدقة التنبؤية فغير مُدّعاة، ولن تجد هنا نسبة نجاح ولا درجة إشارة ولا هدفاً سعرياً.

المؤشر يخبرك أين الحدّان ومتى عُبرا، بدقة. أما قيمة ذلك في استراتيجيتك أنت، على أداتك أنت، وفي إطارك الزمني أنت، فتقديرك ومسؤوليتك.

🔶  أمور تعرفها قبل أن تعتمد عليه

[*]⚠️ لماذا يظهر النموذج متأخراً. لأن المحور لا يُعدّ محوراً حتى تمرّ شموع تأكيده كاملة. وهذا التأخّر هو ثمن ما وعدناك به في السطر الأول: لا شيء يظهر قبل أوانه، ولا شيء ظهر يُسحب منك بعد ذلك.
[*]⚠️ قد تجد ذيلاً عابراً للخط. فالمحاور افتراضياً على القمم والقيعان، بينما يُقاس الاحتواء والخروج على الإغلاق. فيجوز أن يخترق ذيلٌ حداً والنموذج ما زال سليماً. وإن أردت شكلاً لا يمسّه ذيل فاضبط مصدر الكسر على Wick، واعلم أنه اختبار أصرم بكثير وأن النماذج ستقلّ بوضوح.
[*]⚠️ المقياس اللوغاريتمي يدوي. فـ Pine لا يستطيع قراءة إعداد شارتك. وإذا كان شارتك لوغاريتمياً فشغّل الخيار. وعند اختلاف الاثنين ينحرف مستوى الخروج المحسوب عن الخط الذي تراه: انحرافاً مهملاً على النماذج الضيّقة، ومادّياً على الواسعة. وعلامته أمام عينك مباشرة، إذ تنفصل حافة التعبئة اليسرى عن الحد عند المحور الثاني.
[*]⚠️ من أين تُؤخذ المحاور. كل حد يُبنى من آخر محورين على جهته. فالخط الذي يتجاوز محوراً وسيطاً خارج عن نطاق الكشف.
[*]⚠️ الكثافة. ثلاث طبقات مع أرشيف ممتلئ تُثقل الشارت. أطفئ ما لا تحتاجه، واستعن بسقف الأرشيف ودرجة الخفوت.

═════════════════════════════════════════════════════════════
⚠️ إخلاء المسؤولية
═════════════════════════════════════════════════════════════

هذا المؤشر لأغراض تعليمية وتحليلية فقط. لا يُمثل نصيحة مالية أو استثمارية أو تداولية. استخدمه بالتزامن مع استراتيجيتك الخاصة وإدارة المخاطر. لا يتحمل TradingView ولا المطور مسؤولية أي قرارات مالية أو خسائر.

═════════════════════════════════════════════════════════════

---

## Source Code

````pine
//@version=6
// The_lurker — Fawaz Al-Enezi | فواز العنزي

indicator('Converging Triangles [The_lurker]', shorttitle = 'Triangles[The_lurker]', overlay = true, max_lines_count = 500, max_labels_count = 20, max_polylines_count = 100, max_bars_back = 600)

const float EPS = 1e-8

// ═══════════════════════════════════════════════════════════════════════════
// 1 · INPUTS | الإدخالات
// ═══════════════════════════════════════════════════════════════════════════

// Setup | الإعداد
string g1 = '⚙️  Setup | الإعداد'
string i_lang   = input.string('English', 'Language | اللغة', options = ['العربية', 'English'], group = g1)
bool   i_log    = input.bool(false, 'Log scale | مقياس لوغاريتمي', group = g1, tooltip = 'Must be matched to the chart scale manually — Pine cannot read the scale setting.\nWhen mismatched, the computed break level differs from the drawn line.\nNegligible on narrow patterns, material on wide ones.\nVisual tell: the left fill edge separates from the side at the second pivot.\n\nيجب أن يطابق مقياس الشارت يدوياً — Pine لا يقرأ إعداد المقياس.\nعند عدم التطابق يخالف مستوى الكسر المحسوبُ الخطَّ المرسوم.\nالخطأ مهمل على النماذج الضيّقة ومادّي على الواسعة.\nعلامة الخلل: حافة التعبئة اليسرى تنفصل عن الضلع عند المحور الثاني.')
int    i_atrLen = input.int(14, 'ATR length | طول ATR', minval = 2, maxval = 100, group = g1, tooltip = 'Used by three things: the E expansion tag, the demote distance, and the width reading in the panel.\n\nيستهلكه ثلاثة: وسم التمدد E، مسافة التنزيل إلى الأرشيف، وقراءة العرض في اللوحة.')

// Layers | الطبقات
string g2 = '📏  Layers | الطبقات'
bool i_showL = input.bool(true, 'Large L | كبير', group = g2)
int  i_lenL  = input.int(21, 'Large length | الطول الكبير', minval = 2, maxval = 50, group = g2)
bool i_showM = input.bool(true, 'Mid M | متوسط', group = g2)
int  i_lenM  = input.int(14, 'Mid length | الطول المتوسط', minval = 2, maxval = 50, group = g2)
bool i_showS = input.bool(true, 'Small S | صغير', group = g2)
int  i_lenS  = input.int(5, 'Small length | الطول الصغير', minval = 2, maxval = 50, group = g2)

// Detection | الكشف
string g3 = '🔎  Detection | الكشف'
bool   i_closePiv = input.bool(false, 'Close-only pivots | محاور على الإغلاق فقط', group = g3, tooltip = 'OFF: pivots on high/low — sides anchor on wick tips.\nON: pivots on close — pure closing structure.\n\nOFF: المحاور على القمة/القاع — الأضلاع ترتسي على أطراف الذيول.\nON: المحاور على الإغلاق — بنية إغلاق خالصة.')
string i_brkSrc   = input.string('Close', 'Break source | مصدر الكسر', options = ['Close', 'Wick'], group = g3, tooltip = 'Governs three things at once: containment between the pivots, containment after them, and break detection.\nClose: wicks may pierce the line as long as the close stays inside.\nWick: no wick touches the line — far stricter, yields fewer patterns.\n\nيحكم ثلاثة أشياء معاً: الاحتواء بين المحورين، الاحتواء بعدهما، وكشف الكسر.\nClose: يجوز أن تخترق الذيول الخط ما دام الإغلاق داخله.\nWick: لا يلمس الخطَّ أي ذيل — أصرم بكثير وينتج نماذج أقل.')
int    i_spanMult = input.int(5, 'Max span (× length) | أقصى مسافة بين المحورين', minval = 2, maxval = 8, group = g3)
int    i_minOvl   = input.int(0, 'Min side overlap (bars) | أدنى تداخل بين الضلعين', minval = 0, maxval = 200, group = g3, tooltip = 'Overlap of the two sides pivot ranges. Prevents a side with no pivots on its drawn segment.\n\nتداخل مدى المحورين بين الضلعين. يمنع ضلعاً بلا محاور على مقطعه المرسوم.')
int    i_apexMin  = input.int(2, 'Min bars to apex | أدنى مسافة للرأس', minval = 1, maxval = 200, group = g3, tooltip = 'The apex is a geometric projection from frozen geometry, not a confirmed structural date.\n\nالرأس إسقاط هندسي من الهندسة المجمّدة، لا موعد بنيوي مؤكَّد.')
int    i_apexMax  = input.int(200, 'Max bars to apex | أقصى مسافة للرأس', minval = 5, maxval = 500, group = g3)

// Appearance | المظهر
string g4 = '🎨  Appearance | المظهر'
bool  i_showFill = input.bool(true, 'Fill triangle | تعبئة المثلث', group = g4)
int   i_fillTr   = input.int(78, 'Fill transparency | شفافية التعبئة', minval = 40, maxval = 95, group = g4, tooltip = 'Raise it if the fill obscures the candles.\n\nارفعها إن حجبت التعبئة قراءة الشموع.')
int   i_lineW    = input.int(2, 'Line width | عرض الخط', minval = 1, maxval = 4, group = g4)
int   i_lineTr   = input.int(15, 'Line transparency | شفافية الخط', minval = 0, maxval = 70, group = g4)
color i_cNeut    = input.color(#B0BEC5, 'Forming | قيد التكوّن', group = g4)
color i_cBull    = input.color(#4CAF50, 'Break up | كسر لأعلى', group = g4)
color i_cBear    = input.color(#F44336, 'Break down | كسر لأسفل', group = g4)

// History & lifetime | التاريخ والعمر
string g5 = '🗂  History & lifetime | التاريخ والعمر'
int   i_keepBars = input.int(30, 'Keep as current (bars) | إبقاؤه كالحالي', minval = 0, maxval = 300, group = g5, tooltip = 'After this many bars the resolved pattern is demoted to the archive — or deleted if the archive is off.\n\nبعد هذا العدد يُنزَّل المحلول إلى الأرشيف — أو يُحذف إن كان الأرشيف مطفأً.')
float i_farATR   = input.float(8.0, 'Demote beyond (ATR) | التنزيل عند البُعد', minval = 1.0, maxval = 50.0, step = 0.5, group = g5, tooltip = 'The resolved pattern is demoted once price moves further than this from its break level.\nMeasured against current ATR by design: the question is how far price is now, in today volatility units.\n\nيُنزَّل المحلول إذا ابتعد السعر عن مستوى كسره أكثر من هذا.\nيقيس بـ ATR الحالي عمداً: السؤال «كم يبعد السعر الآن بوحدات تقلّب اليوم».')
bool  i_showHist = input.bool(false, 'Show historical patterns | إظهار النماذج السابقة', group = g5, tooltip = 'ON: a resolved pattern stays drawn at a faded shade instead of being deleted.\nPatterns that expire at the apex are not archived, and archived patterns carry no label.\nOFF restores the previous behaviour exactly.\n\nعند التفعيل: النموذج المحلول يبقى مرسوماً بدرجة خافتة بدل أن يُحذف.\nالمنتهي عند الرأس لا يُؤرشف، والمؤرشف لا يحمل تسمية.\nعند الإطفاء يعود السلوك كما كان تماماً.')
int   i_histCap  = input.int(12, 'Historical kept | عدد النماذج المحفوظة', minval = 1, maxval = 40, group = g5, tooltip = 'Cap across all layers combined. Oldest is evicted first.\n\nالسقف عبر كل الطبقات مجتمعة. الإخلاء بالأقدم أولاً.')
int   i_histFade = input.int(30, 'Historical fade | خفوت التاريخية', minval = 0, maxval = 60, group = g5, tooltip = 'Added on top of the line and fill transparency for archived patterns. Zero makes the archive identical to the live shape.\n\nدرجة تُضاف فوق شفافية الخط والتعبئة للنماذج المؤرشفة. صفر يجعل الأرشيف مطابقاً للشكل الحيّ.')

// Labels | التسميات
string g6 = '🏷  Labels | التسميات'
bool  i_lblOn   = input.bool(true, 'Show labels | إظهار التسميات', group = g6, tooltip = 'The label carries the layer letter (L/M/S) plus any tags that fired. Archived patterns carry no label.\n\nالتسمية تحمل حرف الطبقة (L/M/S) والوسمين المتحققين إن وُجدا. النماذج المؤرشفة لا تحمل تسميات.')
int   i_lblCap  = input.int(2, 'Labels kept | تسميات محفوظة', minval = 0, maxval = 4, group = g6)
bool  i_useVol  = input.bool(true, 'Volume tag V | وسم الحجم', group = g6, tooltip = 'V means literally: the break bar volume exceeded its moving average by the multiplier below. It is not a quality mark.\n\nV تعني حرفياً: حجم شمعة الكسر تجاوز متوسطه بالمضاعف أدناه. ليست علامة جودة.')
int   i_volLen  = input.int(20, 'Volume MA | متوسط الحجم', minval = 2, maxval = 200, group = g6)
float i_volMult = input.float(1.5, 'Volume × MA | مضاعف الحجم', minval = 1.0, maxval = 5.0, step = 0.1, group = g6)
bool  i_useExp  = input.bool(true, 'Range expansion E | وسم التمدد', group = g6, tooltip = 'E means literally: the break bar true range exceeded ATR by the multiplier below.\n\nE تعني حرفياً: مدى شمعة الكسر الحقيقي تجاوز ATR بالمضاعف أدناه.')
float i_expMult = input.float(1.4, 'TR × ATR | مضاعف المدى', minval = 1.0, maxval = 5.0, step = 0.1, group = g6)

// Panel | اللوحة
string g7 = '📋  Panel | اللوحة'
bool   i_panel = input.bool(true, 'Show panel | إظهار اللوحة', group = g7, tooltip = 'The status row reads the live bar, so it can flicker between Break pending and Active within a bar.\nA live readout, not a repaint — the drawn geometry is frozen.\n\nسطر الحالة يقرأ الشمعة الجارية، فقد يتذبذب داخلها بين «كسر معلّق» و«نشط».\nقراءة لحظية لا إعادة رسم — الهندسة المرسومة مجمّدة.')
string i_pPos  = input.string('Top right', 'Panel position | موضع اللوحة', options = ['Top right', 'Bottom right', 'Bottom left'], group = g7)

// ═══════════════════════════════════════════════════════════════════════════
// 2 · CORE FUNCTIONS | الدوال الأساسية
// ═══════════════════════════════════════════════════════════════════════════

tx(string ar, string en) => i_lang == 'العربية' ? ar : en

calc_price(float p1, int b1, float p2, int b2, int target) =>
    float r = if b2 == b1
        p2
    else if i_log and p1 > 0 and p2 > 0
        p2 * math.exp((math.log(p2) - math.log(p1)) / (b2 - b1) * (target - b2))
    else
        p2 + (p2 - p1) / (b2 - b1) * (target - b2)
    r

src_side(int offset, bool bear) =>
    i_brkSrc == 'Close' ? close[offset] : (bear ? high[offset] : low[offset])

violated(float px, float pj, bool bear) =>
    bear ? px > pj * (1 + EPS) : px < pj * (1 - EPS)

scan_between(int s, float vs, int e, float ve, bool bear) =>
    bool ok = true
    if e - s >= 2
        for off = 1 to (e - s) - 1
            if violated(src_side(bar_index - (s + off), bear), calc_price(vs, s, ve, e, s + off), bear)
                ok := false
                break
    ok

scan_after(int s, float vs, int e, float ve, bool bear) =>
    bool ok = true
    int  d  = bar_index - e
    if d >= 1
        for off = 1 to d
            if violated(src_side(bar_index - (e + off), bear), calc_price(vs, s, ve, e, e + off), bear)
                ok := false
                break
    ok

panel_pos() =>
    switch i_pPos
        'Top right'   => position.top_right
        'Bottom left' => position.bottom_left
        => position.bottom_right

kind_txt(int lay) =>
    switch lay
        0 => tx('كبير', 'Large')
        1 => tx('متوسط', 'Mid')
        => tx('صغير', 'Small')

lay_pfx(int lay) =>
    switch lay
        0 => 'L'
        1 => 'M'
        => 'S'

// ═══════════════════════════════════════════════════════════════════════════
// 3 · TYPES & STATE | الأنواع والحالة
// ═══════════════════════════════════════════════════════════════════════════

type Side
    int   s    = na
    float sv   = na
    int   e    = na
    float ev   = na
    bool  brk  = false
    int   rejS = na
    int   rejE = na

type Tri
    bool     live    = false
    int      apex    = na
    int      brkBar  = na
    int      brkSide = na
    float    brkAtr  = na
    int      us      = na
    float    usv     = na
    int      ue      = na
    float    uev     = na
    int      ls      = na
    float    lsv     = na
    int      le      = na
    float    lev     = na
    line     lnU     = na
    line     lnL     = na
    line     exU     = na
    line     exL     = na
    polyline fill    = na
    label    lbl     = na

var array<Side> sides = array.from(Side.new(), Side.new(), Side.new(), Side.new(), Side.new(), Side.new())
var array<Tri>  tris  = array.from(Tri.new(), Tri.new(), Tri.new())
var array<Tri>  hist  = array.new<Tri>()

var array<int>   aLay = array.from(0, 0, 1, 1, 2, 2)
var array<int>   aLen = array.from(i_lenL, i_lenL, i_lenM, i_lenM, i_lenS, i_lenS)
var array<int>   aS   = array.from(0, 0, 0, 0, 0, 0)
var array<int>   aE   = array.from(0, 0, 0, 0, 0, 0)
var array<float> aSV  = array.from(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
var array<float> aEV  = array.from(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

lay_on(int lay) => lay == 0 ? i_showL : lay == 1 ? i_showM : i_showS

triU(Tri t, int b) => calc_price(t.usv, t.us, t.uev, t.ue, b)
triL(Tri t, int b) => calc_price(t.lsv, t.ls, t.lev, t.le, b)

ref_bar(Tri t) => t.live ? bar_index : t.brkBar

// ═══════════════════════════════════════════════════════════════════════════
// 4 · DRAWING | الرسم
// ═══════════════════════════════════════════════════════════════════════════

method wipe(Tri this) =>
    line.delete(this.lnU)
    line.delete(this.lnL)
    line.delete(this.exU)
    line.delete(this.exL)
    polyline.delete(this.fill)
    this.lnU  := na
    this.lnL  := na
    this.exU  := na
    this.exL  := na
    this.fill := na
    this

method draw(Tri this, int bEnd, color col, int lineTr, int fillTr) =>
    this.wipe()

    float uE = triU(this, bEnd)
    float lE = triL(this, bEnd)

    color cLine = color.new(col, lineTr)
    color cFill = color.new(col, fillTr)

    if i_showFill and uE > lE
        this.fill := polyline.new(array.from(chart.point.from_index(this.us, this.usv), chart.point.from_index(this.ls, this.lsv), chart.point.from_index(bEnd, lE), chart.point.from_index(bEnd, uE)), closed = true, line_color = na, fill_color = cFill)

    this.lnU := line.new(this.us, this.usv, this.ue, this.uev, xloc.bar_index, color = cLine, width = i_lineW, style = line.style_solid)
    this.lnL := line.new(this.ls, this.lsv, this.le, this.lev, xloc.bar_index, color = cLine, width = i_lineW, style = line.style_solid)
    this.exU := line.new(this.ue, this.uev, bEnd, uE, xloc.bar_index, color = cLine, width = i_lineW, style = line.style_dotted)
    this.exL := line.new(this.le, this.lev, bEnd, lE, xloc.bar_index, color = cLine, width = i_lineW, style = line.style_dotted)
    this

method kill(Tri this) =>
    this.wipe()
    label.delete(this.lbl)
    this.lbl     := na
    this.live    := false
    this.brkBar  := na
    this.brkSide := na
    this.brkAtr  := na
    this

method demote(Tri this) =>
    if i_showHist and not na(this.brkBar) and not na(this.lnU)
        color cB = this.brkSide == 0 ? i_cBull : i_cBear
        this.draw(this.brkBar, cB, math.min(i_lineTr + i_histFade, 90), math.min(i_fillTr + i_histFade, 96))
        Tri a = Tri.new()
        a.lnU  := this.lnU
        a.lnL  := this.lnL
        a.exU  := this.exU
        a.exL  := this.exL
        a.fill := this.fill
        array.push(hist, a)
        this.lnU  := na
        this.lnL  := na
        this.exU  := na
        this.exL  := na
        this.fill := na
        while array.size(hist) > i_histCap
            Tri old = array.shift(hist)
            old.wipe()
    this.kill()
    this

// ═══════════════════════════════════════════════════════════════════════════
// 5 · CONTEXT | السياق
// ═══════════════════════════════════════════════════════════════════════════

float priceH = i_closePiv ? close : high
float priceL = i_closePiv ? close : low

float atrV  = ta.atr(i_atrLen)
float volMa = ta.sma(volume, i_volLen)
float trV   = ta.tr

// ═══════════════════════════════════════════════════════════════════════════
// 6 · PIVOTS | المحاور
// ═══════════════════════════════════════════════════════════════════════════

float phL = ta.pivothigh(priceH, i_lenL, i_lenL)
float plL = ta.pivotlow (priceL, i_lenL, i_lenL)
float phM = ta.pivothigh(priceH, i_lenM, i_lenM)
float plM = ta.pivotlow (priceL, i_lenM, i_lenM)
float phS = ta.pivothigh(priceH, i_lenS, i_lenS)
float plS = ta.pivotlow (priceL, i_lenS, i_lenS)

array.set(aE,  0, ta.valuewhen(not na(phL), bar_index[i_lenL], 0))
array.set(aEV, 0, ta.valuewhen(not na(phL), priceH[i_lenL], 0))
array.set(aS,  0, ta.valuewhen(not na(phL), bar_index[i_lenL], 1))
array.set(aSV, 0, ta.valuewhen(not na(phL), priceH[i_lenL], 1))

array.set(aE,  1, ta.valuewhen(not na(plL), bar_index[i_lenL], 0))
array.set(aEV, 1, ta.valuewhen(not na(plL), priceL[i_lenL], 0))
array.set(aS,  1, ta.valuewhen(not na(plL), bar_index[i_lenL], 1))
array.set(aSV, 1, ta.valuewhen(not na(plL), priceL[i_lenL], 1))

array.set(aE,  2, ta.valuewhen(not na(phM), bar_index[i_lenM], 0))
array.set(aEV, 2, ta.valuewhen(not na(phM), priceH[i_lenM], 0))
array.set(aS,  2, ta.valuewhen(not na(phM), bar_index[i_lenM], 1))
array.set(aSV, 2, ta.valuewhen(not na(phM), priceH[i_lenM], 1))

array.set(aE,  3, ta.valuewhen(not na(plM), bar_index[i_lenM], 0))
array.set(aEV, 3, ta.valuewhen(not na(plM), priceL[i_lenM], 0))
array.set(aS,  3, ta.valuewhen(not na(plM), bar_index[i_lenM], 1))
array.set(aSV, 3, ta.valuewhen(not na(plM), priceL[i_lenM], 1))

array.set(aE,  4, ta.valuewhen(not na(phS), bar_index[i_lenS], 0))
array.set(aEV, 4, ta.valuewhen(not na(phS), priceH[i_lenS], 0))
array.set(aS,  4, ta.valuewhen(not na(phS), bar_index[i_lenS], 1))
array.set(aSV, 4, ta.valuewhen(not na(phS), priceH[i_lenS], 1))

array.set(aE,  5, ta.valuewhen(not na(plS), bar_index[i_lenS], 0))
array.set(aEV, 5, ta.valuewhen(not na(plS), priceL[i_lenS], 0))
array.set(aS,  5, ta.valuewhen(not na(plS), bar_index[i_lenS], 1))
array.set(aSV, 5, ta.valuewhen(not na(plS), priceL[i_lenS], 1))

// ═══════════════════════════════════════════════════════════════════════════
// 7 · EVENTS | الأحداث
// ═══════════════════════════════════════════════════════════════════════════

bool evForm = false
bool evUp   = false
bool evDn   = false

// ═══════════════════════════════════════════════════════════════════════════
// 8 · MAIN | المسار الرئيسي
// ═══════════════════════════════════════════════════════════════════════════

if barstate.isconfirmed

    // 8a · Build sides | بناء الأضلاع
    for k = 0 to 5
        int  lay  = array.get(aLay, k)
        bool bear = k % 2 == 0
        if lay_on(lay)
            int   s  = array.get(aS,  k)
            float vs = array.get(aSV, k)
            int   e  = array.get(aE,  k)
            float ve = array.get(aEV, k)
            Side  sd = array.get(sides, k)

            bool haveData = not na(s) and not na(e) and not na(vs) and not na(ve)
            bool sameLine = haveData and s == sd.s and e == sd.e
            bool cached   = haveData and s == sd.rejS and e == sd.rejE

            if haveData and not sameLine and not cached
                int  span = e - s
                int  len  = array.get(aLen, k)
                bool ok   = span >= 3 and span <= len * i_spanMult
                if ok
                    float sl = (ve - vs) / span
                    ok := bear ? sl < 0 : sl > 0
                if ok
                    ok := scan_between(s, vs, e, ve, bear)
                if ok
                    ok := scan_after(s, vs, e, ve, bear)

                if ok
                    sd.s   := s
                    sd.sv  := vs
                    sd.e   := e
                    sd.ev  := ve
                    sd.brk := false
                else
                    sd.rejS := s
                    sd.rejE := e

    // 8b · Side break flags | أعلام كسر الأضلاع
    for k = 0 to 5
        bool bear = k % 2 == 0
        Side sd   = array.get(sides, k)
        if not na(sd.s) and not sd.brk
            if violated(src_side(0, bear), calc_price(sd.sv, sd.s, sd.ev, sd.e, bar_index), bear)
                sd.brk := true

    // 8c · Resolve & demote | الحل والتنزيل
    for lay = 0 to 2
        Tri t = array.get(tris, lay)
        if t.live
            float lu = triU(t, bar_index)
            float ll = triL(t, bar_index)
            bool  bU = violated(src_side(0, true),  lu, true)
            bool  bD = violated(src_side(0, false), ll, false)
            if bU and bD
                if (src_side(0, true) - lu) >= (ll - src_side(0, false))
                    bD := false
                else
                    bU := false

            if bU or bD
                color cB = bU ? i_cBull : i_cBear
                t.draw(bar_index, cB, i_lineTr, i_fillTr)

                if i_lblOn and i_lblCap > 0
                    bool   vOn = i_useVol and not na(volMa) and volume > volMa * i_volMult
                    bool   eOn = i_useExp and not na(atrV) and trV > atrV * i_expMult
                    string tg  = (vOn ? 'V' : '') + (eOn ? 'E' : '')
                    label.delete(t.lbl)
                    t.lbl := label.new(bar_index, bU ? low : high, lay_pfx(lay) + (tg == '' ? '' : ' ' + tg), xloc.bar_index, yloc.price, cB, bU ? label.style_label_up : label.style_label_down, #101010, size.small)

                if bU
                    evUp := true
                else
                    evDn := true
                t.live    := false
                t.brkBar  := bar_index
                t.brkSide := bU ? 0 : 1
                t.brkAtr  := atrV

            else if bar_index > t.apex
                t.kill()

            else
                t.draw(bar_index, i_cNeut, i_lineTr, i_fillTr)

        else if not na(t.brkBar)
            bool  tooOld = bar_index - t.brkBar > i_keepBars
            float lvlR   = t.brkSide == 0 ? triU(t, t.brkBar) : triL(t, t.brkBar)
            bool  tooFar = not na(atrV) and atrV > 0 and math.abs(close - lvlR) > i_farATR * atrV
            if tooOld or tooFar
                t.demote()

    // 8d · Formation | التكوّن
    for lay = 0 to 2
        Tri t = array.get(tris, lay)
        if lay_on(lay) and not t.live
            Side U = array.get(sides, lay * 2)
            Side L = array.get(sides, lay * 2 + 1)
            if not na(U.s) and not na(L.s) and not U.brk and not L.brk
                int  t0 = math.max(U.s, L.s)
                bool ok = math.min(U.e, L.e) - t0 >= i_minOvl

                int apexB = na
                if ok
                    float uNow = calc_price(U.sv, U.s, U.ev, U.e, bar_index)
                    float lNow = calc_price(L.sv, L.s, L.ev, L.e, bar_index)
                    float uNxt = calc_price(U.sv, U.s, U.ev, U.e, bar_index + 1)
                    float lNxt = calc_price(L.sv, L.s, L.ev, L.e, bar_index + 1)
                    float wNow = uNow - lNow
                    float cv   = wNow - (uNxt - lNxt)
                    float toA  = wNow / cv
                    ok := toA >= i_apexMin and toA <= i_apexMax
                    if ok
                        apexB := bar_index + int(math.round(toA))

                if ok
                    t.demote()
                    t.us   := U.s
                    t.usv  := U.sv
                    t.ue   := U.e
                    t.uev  := U.ev
                    t.ls   := L.s
                    t.lsv  := L.sv
                    t.le   := L.e
                    t.lev  := L.ev
                    t.apex := apexB
                    t.live := true
                    t.draw(bar_index, i_cNeut, i_lineTr, i_fillTr)
                    evForm := true

    // 8e · Label cap | سقف التسميات
    if i_lblOn
        int live = 0
        for lay = 0 to 2
            if not na(array.get(tris, lay).lbl)
                live += 1
        while live > i_lblCap
            int oldL = -1
            int oldB = na
            for lay = 0 to 2
                Tri t = array.get(tris, lay)
                if not na(t.lbl)
                    int bx = label.get_x(t.lbl)
                    if na(oldB) or bx < oldB
                        oldB := bx
                        oldL := lay
            if oldL < 0
                live := 0
            else
                Tri t = array.get(tris, oldL)
                label.delete(t.lbl)
                t.lbl := na
                live  -= 1

// ═══════════════════════════════════════════════════════════════════════════
// 9 · PANEL | اللوحة
// ═══════════════════════════════════════════════════════════════════════════

var table pnl = table.new(panel_pos(), 2, 6, border_width = 1, frame_width = 1)

if i_panel and barstate.islast
    color hdr = color.new(#151515, 10)
    color bgc = color.new(#151515, 25)
    int   bl  = -1
    float bd  = 1e18
    for pass = 0 to 1
        if bl < 0
            for lay = 0 to 2
                Tri t = array.get(tris, lay)
                bool elig = pass == 0 ? t.live : not na(t.lnU)
                if elig
                    int   rb = ref_bar(t)
                    float u  = triU(t, rb)
                    float l  = triL(t, rb)
                    float d  = math.min(math.abs(close - u), math.abs(close - l)) / math.max(close, 1e-10)
                    if d < bd
                        bd := d
                        bl := lay

    if bl < 0
        table.cell(pnl, 0, 0, tx('الطبقة', 'Layer'), bgcolor = hdr, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 1, 0, tx('لا يوجد', 'None'), bgcolor = hdr, text_color = i_cNeut, text_size = size.small)
        for r = 1 to 5
            table.cell(pnl, 0, r, '', bgcolor = bgc)
            table.cell(pnl, 1, r, '', bgcolor = bgc)
    else
        Tri   t  = array.get(tris, bl)
        int   rb = ref_bar(t)
        float u  = triU(t, rb)
        float l  = triL(t, rb)
        float rA = t.live ? atrV : t.brkAtr
        float wA = not na(rA) and rA > 0 ? (u - l) / rA : na
        color cS = t.live ? i_cNeut : (t.brkSide == 0 ? i_cBull : i_cBear)

        table.cell(pnl, 0, 0, tx('الطبقة', 'Layer'), bgcolor = hdr, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 1, 0, kind_txt(bl), bgcolor = hdr, text_color = cS, text_size = size.small)
        table.cell(pnl, 0, 1, tx('الحد العلوي', 'Upper'), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 1, 1, str.tostring(u, format.mintick), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 0, 2, tx('الحد السفلي', 'Lower'), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 1, 2, str.tostring(l, format.mintick), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 0, 3, t.live ? tx('العرض (ATR)', 'Width (ATR)') : tx('العرض عند الكسر', 'Width at break'), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 1, 3, na(wA) ? '—' : str.tostring(wA, '#.##'), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)

        table.cell(pnl, 0, 4, t.live ? tx('الرأس المتوقَّع', 'Projected apex') : tx('منذ الكسر', 'Since break'), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 1, 4, t.live ? str.tostring(t.apex - bar_index) + tx(' شمعة', ' bars') : (na(t.brkBar) ? '—' : str.tostring(bar_index - t.brkBar) + tx(' شمعة', ' bars')), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)

        bool   pU   = t.live and violated(src_side(0, true),  u, true)
        bool   pD   = t.live and violated(src_side(0, false), l, false)
        string stat = not t.live ? (t.brkSide == 0 ? tx('كُسر لأعلى', 'Broken up') : tx('كُسر لأسفل', 'Broken down')) : pU ? tx('كسر معلّق ▲ يثبت بالإغلاق', 'Break pending ▲ at close') : pD ? tx('كسر معلّق ▼ يثبت بالإغلاق', 'Break pending ▼ at close') : tx('نشط · الإبطال خارج أي حد', 'Active · invalid beyond either side')
        color  cSt  = not t.live ? cS : pU ? i_cBull : pD ? i_cBear : i_cNeut
        table.cell(pnl, 0, 5, tx('الحالة', 'Status'), bgcolor = bgc, text_color = i_cNeut, text_size = size.small)
        table.cell(pnl, 1, 5, stat, bgcolor = bgc, text_color = cSt, text_size = size.small)

// ═══════════════════════════════════════════════════════════════════════════
// 10 · ALERTS | التنبيهات
// ═══════════════════════════════════════════════════════════════════════════

if evForm
    alert(tx('تكوّن نموذج', 'Pattern formed'), alert.freq_once_per_bar_close)
if evUp
    alert(tx('كسر لأعلى', 'Break up'), alert.freq_once_per_bar_close)
if evDn
    alert(tx('كسر لأسفل', 'Break down'), alert.freq_once_per_bar_close)

alertcondition(evForm, 'Pattern formed | تكوّن نموذج', 'Converging triangle formed | تكوّن مثلث متقارب')
alertcondition(evUp,   'Break up | كسر لأعلى',         'Broken up | كُسر لأعلى')
alertcondition(evDn,   'Break down | كسر لأسفل',       'Broken down | كُسر لأسفل')
alertcondition(evUp or evDn, 'Any resolution | أي حل', 'Pattern resolved | حُلّ النموذج')
````
