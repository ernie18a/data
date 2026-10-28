# SPX Market Pressure & Momentum Outlook

- url: https://www.tradingview.com/script/6nGOhEPq-SPX-Market-Pressure-Momentum-Outlook/
- type: indicator
- pine_id: PUB;f230bd1c3f254185a2e8f2d910dffd61
- version: 1.0

## Description

SPX Market Pressure is a professional market-reading dashboard designed to help traders understand liquidity pressure, market participation, risk appetite, volatility conditions, and momentum exhaustion probability through a structured intermarket framework.

This indicator is NOT a buy signal, sell signal, strategy, forecasting model, or market prediction tool.

Its purpose is to provide context, market structure awareness, and probability-based decision support by combining multiple market components into a single dashboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDED MARKETS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator was primarily designed for:

• SPX
• ES Futures
• NQ Futures
• SPY
• QQQ
• Other major U.S. index-related instruments

The intermarket logic relies on relationships between SPY, QQQ, IWM, and VIX. Therefore, the most accurate results are generally achieved when used on U.S. equity index markets.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT THE INDICATOR MEASURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The dashboard combines several independent market components:

• Liquidity Pressure
• Market Participation
• Risk Appetite
• Volatility Conditions
• Momentum Condition
• Momentum Exhaustion Probability

Each component contributes information about the current market environment rather than attempting to predict future price direction.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SPY & QQQ LIQUIDITY ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The foundation of the indicator is a proprietary liquidity pressure model built around SPY and QQQ.

The model evaluates:

• Close Location within the candle range
• Candle Body Pressure
• ATR-normalized Momentum
• Relative Volume Participation

The output is converted into directional liquidity pressure scores representing:

• Demand
• Supply
• Neutral Conditions

This creates a structured view of where institutional participation is currently flowing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIGMA (Σ SPY + QQQ)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sigma combines SPY and QQQ liquidity pressure into a single market participation engine.

Rather than using price alone, Sigma evaluates the combined liquidity behavior of both major index ETFs.

Strong Sigma readings indicate broad participation.

Weak or conflicting Sigma readings may indicate deteriorating market participation.

Sigma serves as the primary market pressure reference inside the dashboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IWM RISK APPETITE ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IWM acts as a risk appetite reference.

Strong IWM participation generally suggests:

• Healthy market participation
• Broader market involvement
• Risk-On conditions

Weak IWM participation may suggest:

• Narrow leadership
• Defensive positioning
• Risk-Off behavior

IWM is used as a confirmation component rather than a directional signal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VIX VOLATILITY ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The indicator evaluates volatility conditions using VIX.

Instead of relying only on raw VIX values, the model also evaluates:

• Relative VIX positioning
• Volatility expansion
• Volatility compression
• VIX Bollinger Band location

This helps determine whether market volatility is:

• Normal
• Elevated
• High
• Extreme

Volatility is treated as a market condition measurement, not a directional forecast.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MARKET SUPPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Market Support measures whether current liquidity pressure is supported by the broader market environment.

Inputs used:

• Sigma
• IWM
• VIX

Possible states include:

• Strong Bull Support
• Bull Support
• Neutral
• Bear Support
• Strong Bear Support

Market Support measures participation quality, not future price direction.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CURRENT SYMBOL OUTLOOK ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The Outlook Engine dynamically analyzes the active chart symbol.

The engine automatically adapts to whichever symbol the indicator is attached to.

Examples:

• SPX Outlook
• ES Outlook
• NQ Outlook
• SPY Outlook
• QQQ Outlook

The Outlook Engine is designed to evaluate:

• Momentum Condition
• Momentum Maturity
• Momentum Exhaustion Probability

It does NOT attempt to forecast reversals or predict future trends.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DYNAMIC RSI EXHAUSTION MODEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A major component of the Outlook Engine is the Dynamic RSI Exhaustion Model.

Unlike traditional RSI systems, RSI alignment is NOT treated as a bullish or bearish signal.

Instead, the engine evaluates:

• Current RSI
• Daily RSI
• Distance between both values
• RSI Rate of Change

As Current RSI approaches Daily RSI, the engine measures momentum maturity and potential exhaustion risk.

Examples:

Daily RSI = 75

Current RSI = 45
→ Significant expansion capacity remains.

Current RSI = 68
→ Momentum becoming mature.

Current RSI = 73
→ Elevated exhaustion probability.

Current RSI = 76
→ Very high exhaustion probability.

The model is designed to identify momentum maturity rather than overbought/oversold trading signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ATR EXPANSION ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ATR is used to evaluate movement expansion.

The indicator compares:

• Current ATR
• Long-Term ATR Average

Strong ATR expansion suggests:

• Active participation
• Expanding movement
• Sustained momentum conditions

Weak ATR relative to its historical average may indicate:

• Slowing participation
• Drying liquidity
• Increasing exhaustion probability

ATR is never used as a directional indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VOLATILITY ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The Volatility Engine combines multiple components:

• Current Symbol ATR Expansion
• Current Symbol Range Expansion
• VIX Environment
• Sigma Stability

This allows volatility conditions to adapt dynamically to the chart currently being analyzed.

Possible outputs:

• Normal Volatility
• Elevated Volatility
• High Volatility
• Extreme Volatility

Volatility measures movement intensity, not direction.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OUTLOOK STATES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The Outlook Engine produces five primary states:

• Momentum Building
• Momentum Active
• Momentum Watch
• Exhaustion Watch
• High Exhaustion Probability

These states represent probability-based market conditions rather than trading signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Start with Sigma
Determine whether broad liquidity pressure is favoring Demand or Supply.

2. Review IWM
Evaluate whether broader market participation supports the current environment.

3. Review VIX
Assess volatility conditions and risk environment.

4. Check Market Support
Determine whether the current liquidity environment is supported by broader market participation.

5. Review Outlook
Analyze momentum condition and exhaustion probability for the active chart symbol.

6. Review Volatility
Determine whether the current environment is operating under Normal, Elevated, High, or Extreme volatility conditions.

The strongest environments typically occur when liquidity pressure, market participation, and risk conditions align.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPORTANT DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SPX Market Pressure is a market-reading and decision-support tool.

It is not a trading strategy.

It does not generate buy signals.

It does not generate sell signals.

It does not predict market direction.

It does not forecast future price movement.

All outputs represent market context, participation quality, volatility conditions, momentum condition, and probability-based exhaustion analysis intended to assist traders in making more informed decisions.



 هو داشبورد احترافي لقراءة السوق، تم تصميمه لمساعدة المتداول على فهم ضغط السيولة، مشاركة السوق، شهية المخاطرة، حالة التذبذب، واحتمالية إرهاق الزخم من خلال إطار تحليل مترابط يجمع عدة مكونات سوقية في مكان واحد.

هذا المؤشر ليس نظام توصيات، وليس استراتيجية تداول، ولا يقدم إشارات شراء أو بيع، ولا يتنبأ بحركة السوق المستقبلية.

الهدف منه هو توفير مرجع بصري منظم يساعد المتداول على فهم البيئة الحالية للسوق واتخاذ قرارات أكثر وعياً بناءً على السياق العام للسوق.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
الأسواق الموصى باستخدام المؤشر عليها
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

تم تصميم المؤشر أساساً لأسواق المؤشرات الأمريكية، ويعطي أفضل نتائجه عند استخدامه على:

• SPX
• ES Futures
• NQ Futures
• SPY
• QQQ

ويعتمد جزء كبير من منطقه التحليلي على العلاقة بين:

• SPY
• QQQ
• IWM
• VIX

لذلك يوصى باستخدامه على الأسواق الأمريكية والمؤشرات المرتبطة بها.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ماذا يقيس المؤشر؟
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يجمع المؤشر عدة عناصر سوقية مختلفة داخل لوحة واحدة:

• ضغط السيولة (Liquidity Pressure)
• مشاركة السوق (Market Participation)
• شهية المخاطرة (Risk Appetite)
• حالة التذبذب (Volatility Conditions)
• حالة الزخم (Momentum Condition)
• احتمالية إرهاق الزخم (Momentum Exhaustion Probability)

المؤشر لا يحاول التنبؤ بالمستقبل، وإنما يقيس حالة السوق الحالية وجودة الحركة القائمة.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
محرك السيولة SPY و QQQ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يعتمد أساس المؤشر على نموذج خاص لقياس ضغط السيولة في SPY و QQQ.

يقوم النموذج بتحليل:

• موقع الإغلاق داخل الشمعة
• قوة جسم الشمعة
• الزخم مقارنة بالـ ATR
• الفوليوم النسبي مقارنة بمتوسط الفوليوم

ثم يتم تحويل هذه البيانات إلى درجات تمثل:

• Demand
• Supply
• Neutral

وذلك بهدف قياس اتجاه السيولة الحالية داخل السوق.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
سيجما Σ SPY + QQQ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

تمثل سيجما الدمج بين قراءات SPY و QQQ داخل مؤشر واحد.

لا تعتمد سيجما على السعر فقط، بل تعتمد على ضغط السيولة الناتج من كلا السوقين.

عندما تكون سيجما قوية فهذا يشير عادة إلى مشاركة واسعة من السوق.

أما ضعف أو تضارب سيجما فقد يدل على تراجع المشاركة أو ضعف البيئة الحالية للحركة.

وتعتبر سيجما المرجع الأساسي لقراءة ضغط السوق داخل المؤشر.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IWM وقياس شهية المخاطرة
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يستخدم IWM كمرجع لقياس شهية المخاطرة داخل السوق.

عندما يكون IWM قوياً فقد يدل ذلك على:

• مشاركة أوسع من السوق
• بيئة Risk-On
• استعداد أكبر للمخاطرة

أما عندما يكون ضعيفاً فقد يدل ذلك على:

• ضعف المشاركة
• تركيز السيولة في عدد محدود من الأسهم
• بيئة Risk-Off

ولا يستخدم IWM كإشارة تداول بل كعامل داعم لقراءة البيئة الحالية.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VIX ومحرك التذبذب
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يقوم المؤشر بتحليل مؤشر الخوف VIX لتقييم حالة التذبذب في السوق.

ولا يعتمد فقط على قيمة VIX الخام، بل يستخدم أيضاً:

• موقع VIX بالنسبة لبولينجر باند
• توسع التذبذب
• انكماش التذبذب
• البيئة العامة للمخاطرة

ويتم تصنيف حالة التذبذب إلى:

• Normal Volatility
• Elevated Volatility
• High Volatility
• Extreme Volatility

ويجب التنبيه إلى أن التذبذب لا يعني صعوداً أو هبوطاً، وإنما يقيس قوة واتساع الحركة فقط.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Market Support
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يقيس Market Support مدى دعم البيئة العامة للحركة الحالية.

ويعتمد على:

• Sigma
• IWM
• VIX

وتظهر النتائج على شكل:

• Strong Bull Support
• Bull Support
• Neutral
• Bear Support
• Strong Bear Support

وهو لا يتنبأ بالاتجاه القادم، بل يقيس مدى توافق البيئة الحالية مع ضغط السوق القائم.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
محرك Outlook للرمز الحالي
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يقوم Outlook بتحليل الرمز المفتوح حالياً بشكل تلقائي.

فإذا كنت تتابع:

• SPX
• ES
• NQ
• SPY
• QQQ

سيقوم المؤشر بإنشاء Outlook خاص بالرمز الحالي.

هدف Outlook هو تقييم:

• حالة الزخم الحالية
• نضج الزخم
• احتمالية إرهاق الزخم

وليس التنبؤ بالانعكاسات أو الاتجاهات المستقبلية.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
نموذج الإرهاق الديناميكي RSI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

أحد أهم أجزاء المؤشر هو نموذج الإرهاق الديناميكي المبني على RSI.

على عكس الأنظمة التقليدية، لا يتم التعامل مع تقارب RSI كإشارة صعود أو هبوط.

بدلاً من ذلك يتم قياس:

• RSI الحالي
• RSI اليومي
• المسافة بينهما
• سرعة تغير RSI

كلما اقترب RSI الحالي من RSI اليومي تبدأ احتمالية نضج الحركة وإرهاق الزخم بالارتفاع.

مثال:

إذا كان RSI اليومي = 75

وكان RSI الحالي = 45
فهذا يعني أن الحركة ما زال أمامها مساحة للتوسع.

أما إذا كان RSI الحالي = 73
فهذا يعني أن الزخم أصبح أكثر نضجاً واحتمالية الإرهاق ارتفعت.

أما إذا تجاوز RSI الحالي RSI اليومي
فقد ترتفع احتمالية الإرهاق بشكل أكبر.

هذا النموذج لا يستخدم للتنبؤ بالانعكاس، بل لقياس درجة نضج الحركة الحالية.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
تحليل ATR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يقوم المؤشر بمقارنة:

• ATR الحالي
• متوسط ATR طويل المدى

عندما يكون ATR الحالي أعلى من متوسطه التاريخي فهذا يدل غالباً على:

• حركة نشطة
• توسع في الحركة
• استمرار الزخم

أما انخفاض ATR مقارنة بمتوسطه فقد يشير إلى:

• ضعف المشاركة
• تباطؤ الحركة
• ارتفاع احتمالية الإرهاق

ولا يستخدم ATR لتحديد الاتجاه وإنما لقياس جودة الحركة واتساعها.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
محرك Volatility
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يقيس محرك التذبذب حالة الحركة الحالية من خلال دمج عدة عناصر:

• توسع ATR للرمز الحالي
• توسع مدى الحركة للرمز الحالي
• بيئة VIX
• استقرار أو تذبذب Sigma

وبذلك تصبح قراءة التذبذب مرتبطة بالرمز المفتوح حالياً وليس بالسوق بشكل عام فقط.

وتظهر النتائج على شكل:

• Normal Volatility
• Elevated Volatility
• High Volatility
• Extreme Volatility

التذبذب يقيس قوة الحركة وليس اتجاهها.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
حالات Outlook
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

يعرض Outlook خمس حالات رئيسية:

• Momentum Building
• Momentum Active
• Momentum Watch
• Exhaustion Watch
• High Exhaustion Probability

وتمثل هذه الحالات احتمالات وظروف سوقية حالية وليست إشارات تداول.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
طريقة استخدام المؤشر
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. ابدأ بقراءة Sigma
لمعرفة ما إذا كانت السيولة الحالية تميل إلى Demand أو Supply.

2. راقب IWM
لتقييم جودة المشاركة واتساع الحركة داخل السوق.

3. راقب VIX
لفهم بيئة المخاطرة والتذبذب الحالية.

4. راجع Market Support
لمعرفة ما إذا كانت البيئة العامة تدعم الحركة الحالية أم لا.

5. راجع Outlook
لتقييم حالة الزخم واحتمالية الإرهاق على الرمز المفتوح حالياً.

6. راجع Volatility
لمعرفة ما إذا كانت الحركة الحالية طبيعية أو مرتفعة التذبذب أو شديدة التذبذب.

أقوى البيئات عادة تكون عندما تتوافق السيولة ومشاركة السوق وشهية المخاطرة مع بعضها البعض.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
إخلاء مسؤولية
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SPX Market Pressure هو أداة لقراءة السوق ومساعدة المتداول على فهم البيئة الحالية للسوق.

المؤشر ليس استراتيجية تداول.

لا يقدم إشارات شراء.

لا يقدم إشارات بيع.

لا يتنبأ باتجاه السوق.

لا يتنبأ بالسعر المستقبلي.

جميع القراءات تمثل ظروفاً واحتمالات وسياقاً سوقياً يساعد المتداول على اتخاذ قرارات أكثر وعياً، ولا تمثل أي ضمان أو توصية استثمارية.

## Source Code

````pine
//@version=6
indicator("SPX Market Pressure", shorttitle="SPX MP", overlay=true, max_labels_count=50, dynamic_requests=true)

plot(na, title="Hidden Plot", display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Groups
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMain    = "Main Settings / الإعدادات الرئيسية"
groupCalc    = "Volume Pressure / ضغط السيولة"
groupRisk    = "Risk References / مراجع المخاطرة"
groupOutlook = "Outlook Engine / محرك النظرة"
groupVol     = "Volatility Engine / محرك التذبذب"
groupStyle   = "Table Style / شكل الجدول"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Main Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lang = input.string("English", "Language / اللغة", options=["English", "العربية"], group=groupMain)
isAr = lang == "العربية"

spySymbol = input.symbol("AMEX:SPY", "SPY Symbol / رمز SPY", group=groupMain)
qqqSymbol = input.symbol("NASDAQ:QQQ", "QQQ Symbol / رمز QQQ", group=groupMain)

spyWeight = input.float(50.0, "SPY Sigma Weight % / وزن SPY في سيجما", minval=0, maxval=100, step=5, group=groupMain)
qqqWeight = input.float(50.0, "QQQ Sigma Weight % / وزن QQQ في سيجما", minval=0, maxval=100, step=5, group=groupMain)

useExtended = input.bool(true, "Use Extended Session / استخدام البريماركت والافترماركت", group=groupMain)

tf1 = input.timeframe("5", "Timeframe 1 / الفاصل الأول", group=groupMain)
tf2 = input.timeframe("15", "Timeframe 2 / الفاصل الثاني", group=groupMain)
tf3 = input.timeframe("3", "Timeframe 3 / الفاصل الثالث", group=groupMain)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Risk Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showIwmRow = input.bool(true, "Show IWM Row / إظهار IWM", group=groupRisk)
showVixRow = input.bool(true, "Show VIX Row / إظهار VIX", group=groupRisk)

iwmSymbol = input.symbol("AMEX:IWM", "IWM Symbol / رمز IWM", group=groupRisk)
vixSymbol = input.symbol("TVC:VIX", "VIX Symbol / رمز VIX", group=groupRisk)
riskTf    = input.timeframe("15", "IWM/VIX Risk Timeframe / فاصل مراجع المخاطرة", group=groupRisk)

showPrice     = input.bool(true, "Show Last Price / إظهار السعر", group=groupRisk)
showDayChange = input.bool(true, "Show Day % Change / إظهار التغير اليومي", group=groupRisk)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Outlook Engine Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showSymbolOutlook = input.bool(true, "Show Current Symbol Outlook / إظهار نظرة الرمز الحالي", group=groupOutlook)

rsiLen      = input.int(14, "Current RSI Length / طول RSI الحالي", minval=1, group=groupOutlook)
dailyRsiLen = input.int(14, "Daily RSI Length / طول RSI اليومي", minval=1, group=groupOutlook)
rsiRocLen   = input.int(3, "RSI ROC Length / طول تغير RSI", minval=1, group=groupOutlook)

watchTh   = input.float(10.0, "Watch Threshold / حد المراقبة", minval=1, maxval=50, step=0.5, group=groupOutlook)
exhaustTh = input.float(5.0, "Exhaustion Threshold / حد الإرهاق", minval=1, maxval=50, step=0.5, group=groupOutlook)
extremeTh = input.float(2.0, "Extreme Threshold / حد الإرهاق العالي", minval=0.5, maxval=50, step=0.5, group=groupOutlook)

dailyObLevel = input.float(70.0, "Daily RSI Overbought / تشبع اليومي", minval=50, maxval=100, step=1, group=groupOutlook)
dailyOsLevel = input.float(30.0, "Daily RSI Oversold / تشبع بيعي يومي", minval=0, maxval=50, step=1, group=groupOutlook)

outAtrLen    = input.int(14, "Chart ATR Length / طول ATR للشارت", minval=1, group=groupOutlook)
outAtrAvgLen = input.int(50, "ATR Average Length / متوسط ATR", minval=1, group=groupOutlook)

vixBbLen  = input.int(20, "VIX Bollinger Length / طول بولينجر VIX", minval=1, group=groupOutlook)
vixBbMult = input.float(2.0, "VIX Bollinger Multiplier / معامل بولينجر VIX", minval=0.5, maxval=5, step=0.25, group=groupOutlook)

rsiW   = input.float(45.0, "RSI Exhaustion Weight / وزن RSI", minval=0, maxval=100, step=5, group=groupOutlook)
atrW   = input.float(20.0, "ATR Weight / وزن ATR", minval=0, maxval=100, step=5, group=groupOutlook)
sigmaW = input.float(15.0, "Sigma Weight / وزن السيجما", minval=0, maxval=100, step=5, group=groupOutlook)
iwmW   = input.float(10.0, "IWM Weight / وزن IWM", minval=0, maxval=100, step=5, group=groupOutlook)
vixW   = input.float(10.0, "VIX Weight / وزن VIX", minval=0, maxval=100, step=5, group=groupOutlook)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volatility Engine Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volAtrW   = input.float(30.0, "Current Symbol ATR Expansion Weight / وزن ATR للرمز الحالي", minval=0, maxval=100, step=5, group=groupVol)
volRangeW = input.float(20.0, "Current Symbol Range Expansion Weight / وزن مدى الشمعة", minval=0, maxval=100, step=5, group=groupVol)
volVixW   = input.float(30.0, "VIX Environment Weight / وزن بيئة VIX", minval=0, maxval=100, step=5, group=groupVol)
volSigmaW = input.float(20.0, "Sigma Instability Weight / وزن تذبذب السيجما", minval=0, maxval=100, step=5, group=groupVol)

rangeAvgLen = input.int(50, "Range Average Length / متوسط مدى الشمعة", minval=1, group=groupVol)
sigmaInstabilityLen = input.int(3, "Sigma Instability Length / طول تذبذب السيجما", minval=1, group=groupVol)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Calculation Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volLen  = input.int(20, "Volume Average Length / متوسط الفوليوم", minval=1, group=groupCalc)
atrLen  = input.int(14, "ATR Length / طول ATR", minval=1, group=groupCalc)
volCap  = input.float(2.50, "Volume Impact Cap / حد تأثير الفوليوم", minval=1.0, maxval=5.0, step=0.10, group=groupCalc)
showPct = input.bool(true, "Show % / إظهار النسبة", group=groupCalc)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Style Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tablePos = input.string("Top Right", "Table Position / مكان الجدول", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=groupStyle)
txtSizeInput = input.string("Small", "Text Size / حجم الخط", options=["Tiny", "Small", "Normal", "Large"], group=groupStyle)

bullColor     = input.color(color.rgb(0, 220, 90), "Bull Color / لون الصعود", group=groupStyle)
bearColor     = input.color(color.rgb(255, 45, 45), "Bear Color / لون الهبوط", group=groupStyle)
neutralColor  = input.color(color.rgb(85, 85, 85), "Neutral Color / لون الحياد", group=groupStyle)
mixedColor    = input.color(color.rgb(255, 140, 0), "Warning / Mixed Color / لون التحذير", group=groupStyle)
headerColor   = input.color(color.rgb(18, 18, 18), "Header Color / لون العنوان", group=groupStyle)
textColor     = input.color(color.white, "Text Color / لون النص", group=groupStyle)

outBuildColor  = input.color(color.rgb(0, 120, 255), "Outlook Building Color / لون بناء الزخم", group=groupStyle)
outActiveColor = input.color(color.rgb(0, 190, 190), "Outlook Active Color / لون الزخم النشط", group=groupStyle)
outWatchColor  = input.color(color.rgb(190, 155, 0), "Outlook Watch Color / لون مراقبة الزخم", group=groupStyle)
outExhColor    = input.color(color.rgb(255, 140, 0), "Outlook Exhaustion Watch Color / لون مراقبة الإرهاق", group=groupStyle)
outHighColor   = input.color(color.rgb(150, 70, 255), "Outlook High Exhaustion Color / لون الإرهاق العالي", group=groupStyle)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_position(string _pos) =>
    switch _pos
        "Top Right" => position.top_right
        "Top Center" => position.top_center
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_size(string _s) =>
    switch _s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_tfName(string _tf) =>
    switch _tf
        "1S" => "1s"
        "3S" => "3s"
        "5S" => "5s"
        "10S" => "10s"
        "30S" => "30s"
        "45S" => "45s"
        "1" => "1m"
        "2" => "2m"
        "3" => "3m"
        "5" => "5m"
        "10" => "10m"
        "15" => "15m"
        "30" => "30m"
        "60" => "1H"
        "120" => "2H"
        "240" => "4H"
        "D" => "1D"
        => _tf

f_pack() =>
    [open, high, low, close, close[1], volume, ta.sma(volume, volLen), ta.atr(atrLen)]

f_data(string _symbol, string _tf) =>
    request.security(_symbol, _tf, f_pack(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

f_dayPack() =>
    [close, close[1]]

f_dayData(string _symbol) =>
    request.security(_symbol, "D", f_dayPack(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

f_vixBands(string _symbol, string _tf) =>
    request.security(_symbol, _tf, [ta.sma(close, vixBbLen), ta.stdev(close, vixBbLen)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pressure Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_levelFromPct(float _pct) =>
    int lvl = 0
    if not na(_pct)
        lvl := _pct >= 85 ? 5 :
               _pct >= 75 ? 4 :
               _pct >= 70 ? 3 :
               _pct >= 65 ? 2 :
               _pct >= 60 ? 1 : 0
    lvl

f_pressure(float _o, float _h, float _l, float _c, float _pc, float _atr, float _v, float _vma, bool _useVol) =>
    int score = na
    float pct = na
    float edge = na

    if not na(_c)
        float rng = _h - _l
        float closeLocation = rng > 0 ? ((_c - _l) - (_h - _c)) / rng : 0.0
        float bodyPressure  = rng > 0 ? (_c - _o) / rng : 0.0
        float momentumRaw   = not na(_pc) and _atr > 0 ? (_c - _pc) / _atr : 0.0
        float momentum      = math.max(-1.0, math.min(1.0, momentumRaw))

        bool hasVolume = _useVol and not na(_v) and not na(_vma) and _vma > 0
        float volRelative = hasVolume ? math.min(math.max(_v / _vma, 0.0), volCap) : 1.0

        float directionalPressure = closeLocation * 0.55 + bodyPressure * 0.30 + momentum * 0.15
        edge := math.max(-1.0, math.min(1.0, directionalPressure * volRelative))

        pct := 50.0 + math.abs(edge) * 50.0

        int dir = edge > 0 ? 1 : edge < 0 ? -1 : 0
        int lvl = f_levelFromPct(pct)

        score := dir == 0 or lvl == 0 ? 0 : dir * lvl

    [score, pct, edge]

f_weightedEdge(float _spyEdge, float _qqqEdge) =>
    float totalW = spyWeight + qqqWeight
    totalW > 0 ? ((na(_spyEdge) ? 0.0 : _spyEdge) * spyWeight + (na(_qqqEdge) ? 0.0 : _qqqEdge) * qqqWeight) / totalW : na

f_edgeToScore(float _edge) =>
    int score = na
    float pct = na
    if not na(_edge)
        pct := 50.0 + math.abs(_edge) * 50.0
        int dir = _edge > 0 ? 1 : _edge < 0 ? -1 : 0
        int lvl = f_levelFromPct(pct)
        score := dir == 0 or lvl == 0 ? 0 : dir * lvl
    [score, pct]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Text + Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_dirText(int _score, bool _isVix, bool _isIwm) =>
    na(_score) ? "NA" :
     _isVix ? (_score > 0 ? "Fear" : _score < 0 ? "Calm" : "Neutral") :
     _isIwm ? (_score > 0 ? "Risk-On" : _score < 0 ? "Risk-Off" : "Neutral") :
     _score > 0 ? "Demand" : _score < 0 ? "Supply" : "Neutral"

f_scoreLine(int _score, bool _isVix, bool _isIwm) =>
    na(_score) ? "NA" :
     _score > 0 ? "+" + str.tostring(_score) + " " + f_dirText(_score, _isVix, _isIwm) :
     _score < 0 ? str.tostring(_score) + " " + f_dirText(_score, _isVix, _isIwm) :
     "0 Neutral"

f_pctOnly(float _pct) =>
    showPct and not na(_pct) ? str.tostring(_pct, "#.0") + "%" : ""

f_mainCell(int _score, float _pct) =>
    f_scoreLine(_score, false, false) + (showPct and not na(_pct) ? "\n" + f_pctOnly(_pct) : "")

f_riskCell(int _score, float _pct, bool _isVix) =>
    f_scoreLine(_score, _isVix, not _isVix) + (showPct and not na(_pct) ? "\nS:" + f_pctOnly(_pct) : "")

f_priceText(float _x) =>
    not na(_x) ? str.tostring(_x, format.mintick) : "-"

f_dayPctText(float _c, float _pc) =>
    not na(_c) and not na(_pc) and _pc != 0 ? str.tostring(((_c - _pc) / _pc) * 100.0, "+#.##;-#.##") + "%" : "-"

f_bg(int _score, bool _isVix) =>
    if na(_score)
        color.new(neutralColor, 70)
    else if _score == 0
        color.new(neutralColor, 45)
    else
        int strength = math.abs(_score)
        int trans = int(math.max(8.0, 88.0 - strength * 15.0))
        bool green = _isVix ? _score < 0 : _score > 0
        green ? color.new(bullColor, trans) : color.new(bearColor, trans)

f_dayBg(float _c, float _pc, bool _inverse) =>
    float chg = not na(_c) and not na(_pc) and _pc != 0 ? ((_c - _pc) / _pc) * 100.0 : na
    if na(chg)
        color.new(neutralColor, 70)
    else if chg == 0
        color.new(neutralColor, 45)
    else
        bool green = _inverse ? chg < 0 : chg > 0
        float mag = math.min(math.abs(chg), 5.0)
        int trans = int(math.max(20.0, 82.0 - mag * 10.0))
        green ? color.new(bullColor, trans) : color.new(bearColor, trans)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Market Support
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_confirmFlag(int _spxScore, int _refScore, bool _isVix) =>
    int flag = 0
    if not na(_spxScore) and not na(_refScore) and _spxScore != 0 and _refScore != 0
        flag := _isVix ? (((_spxScore > 0 and _refScore < 0) or (_spxScore < 0 and _refScore > 0)) ? 1 : -1) :
                          (((_spxScore > 0 and _refScore > 0) or (_spxScore < 0 and _refScore < 0)) ? 1 : -1)
    flag

f_supportText(int _spxScore, int _iwmFlag, int _vixFlag) =>
    int sum = _iwmFlag + _vixFlag
    if na(_spxScore) or _spxScore == 0
        "Neutral"
    else if _spxScore > 0
        sum >= 2 ? "Strong Bull Support" :
         sum == 1 ? "Bull Support" :
         sum == 0 ? "Mixed Support" :
         sum == -1 ? "Bull Warning" :
         "Strong Bull Conflict"
    else
        sum >= 2 ? "Strong Bear Support" :
         sum == 1 ? "Bear Support" :
         sum == 0 ? "Mixed Support" :
         sum == -1 ? "Bear Warning" :
         "Strong Bear Conflict"

f_supportBg(int _spxScore, int _iwmFlag, int _vixFlag) =>
    int sum = _iwmFlag + _vixFlag
    if na(_spxScore) or _spxScore == 0
        color.new(neutralColor, 45)
    else if _spxScore > 0
        sum >= 2 ? color.new(bullColor, 18) :
         sum == 1 ? color.new(bullColor, 52) :
         sum == 0 ? color.new(neutralColor, 45) :
         sum == -1 ? color.new(mixedColor, 32) :
         color.new(bearColor, 28)
    else
        sum >= 2 ? color.new(bearColor, 18) :
         sum == 1 ? color.new(bearColor, 52) :
         sum == 0 ? color.new(neutralColor, 45) :
         sum == -1 ? color.new(mixedColor, 32) :
         color.new(bullColor, 28)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Outlook + Volatility Engines
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_rsiExhaustion(float _rsi, float _dailyRsi, float _rsiRoc) =>
    float score = na
    if not na(_rsi) and not na(_dailyRsi)
        float dist = math.abs(_rsi - _dailyRsi)

        bool dailyHigh = _dailyRsi >= dailyObLevel
        bool dailyLow  = _dailyRsi <= dailyOsLevel
        bool dailyNeutral = _dailyRsi >= 45 and _dailyRsi <= 55

        float base = 20.0

        if dailyHigh or dailyLow
            base := dist <= extremeTh ? 90.0 :
                 dist <= exhaustTh ? 75.0 :
                 dist <= watchTh ? 55.0 :
                 20.0
        else if dailyNeutral
            base := dist <= extremeTh ? 25.0 :
                 dist <= exhaustTh ? 22.0 :
                 dist <= watchTh ? 20.0 :
                 18.0
        else
            base := dist <= extremeTh ? 45.0 :
                 dist <= exhaustTh ? 40.0 :
                 dist <= watchTh ? 32.0 :
                 22.0

        bool approachingHigh = dailyHigh and _rsi <= _dailyRsi and _rsiRoc > 0
        bool approachingLow  = dailyLow and _rsi >= _dailyRsi and _rsiRoc < 0

        bool coolingHigh = dailyHigh and _rsiRoc < 0
        bool coolingLow  = dailyLow and _rsiRoc > 0

        bool overHigh = dailyHigh and _rsi >= _dailyRsi
        bool overLow  = dailyLow and _rsi <= _dailyRsi

        float adjust = 0.0
        adjust += approachingHigh or approachingLow ? 12.0 : 0.0
        adjust += overHigh or overLow ? 10.0 : 0.0
        adjust -= coolingHigh or coolingLow ? 18.0 : 0.0

        score := math.max(0.0, math.min(100.0, base + adjust))
    score

f_atrExhaustion(float _atr, float _atrAvg) =>
    float score = na
    if not na(_atr) and not na(_atrAvg) and _atrAvg > 0
        float ratio = _atr / _atrAvg
        score := ratio < 0.75 ? 80.0 :
             ratio < 0.90 ? 65.0 :
             ratio < 1.05 ? 45.0 :
             ratio < 1.30 ? 25.0 :
             20.0
    score

f_sigmaExhaustion(int _sigmaScore) =>
    float s = math.abs(_sigmaScore)
    s >= 4 ? 20.0 :
     s >= 3 ? 30.0 :
     s >= 2 ? 45.0 :
     s >= 1 ? 60.0 :
     70.0

f_iwmExhaustion(int _sigmaScore, int _iwmScore) =>
    float score = 45.0
    if not na(_sigmaScore) and not na(_iwmScore)
        if _sigmaScore == 0 or _iwmScore == 0
            score := 45.0
        else
            bool aligned = (_sigmaScore > 0 and _iwmScore > 0) or (_sigmaScore < 0 and _iwmScore < 0)
            score := aligned ? 25.0 : 70.0
    score

f_vixExhaustion(int _vixScore, float _vixClose, float _basis, float _dev) =>
    float score = 45.0
    float upper = not na(_basis) and not na(_dev) ? _basis + _dev * vixBbMult : na
    float lower = not na(_basis) and not na(_dev) ? _basis - _dev * vixBbMult : na
    float width = not na(upper) and not na(lower) ? upper - lower : na
    float pos = not na(width) and width > 0 ? (_vixClose - lower) / width : na

    if not na(_vixScore)
        if _vixScore > 0
            score := not na(pos) and pos >= 1.0 ? 90.0 :
                 not na(pos) and pos >= 0.80 ? 78.0 :
                 65.0
        else if _vixScore < 0
            score := not na(pos) and pos <= 0.25 ? 20.0 : 30.0
        else
            score := 45.0
    score

f_weightedOutlook(float _rsiScore, float _atrScore, float _sigmaScore, float _iwmScore, float _vixScore) =>
    float total = 0.0
    float sum = 0.0

    if not na(_rsiScore) and rsiW > 0
        sum += _rsiScore * rsiW
        total += rsiW
    if not na(_atrScore) and atrW > 0
        sum += _atrScore * atrW
        total += atrW
    if not na(_sigmaScore) and sigmaW > 0
        sum += _sigmaScore * sigmaW
        total += sigmaW
    if not na(_iwmScore) and iwmW > 0
        sum += _iwmScore * iwmW
        total += iwmW
    if not na(_vixScore) and vixW > 0
        sum += _vixScore * vixW
        total += vixW

    total > 0 ? sum / total : na

f_symbolOutlookText(float _score) =>
    na(_score) ? "NA" :
     _score < 30 ? "Momentum Building" :
     _score < 50 ? "Momentum Active" :
     _score < 65 ? "Momentum Watch" :
     _score < 80 ? "Exhaustion Watch" :
     "High Exhaustion Probability"

f_symbolOutlookBg(float _score) =>
    na(_score) ? color.new(neutralColor, 45) :
     _score < 30 ? color.new(outBuildColor, 15) :
     _score < 50 ? color.new(outActiveColor, 25) :
     _score < 65 ? color.new(outWatchColor, 20) :
     _score < 80 ? color.new(outExhColor, 25) :
     color.new(outHighColor, 15)

f_vixVolatility(float _vixClose, float _basis, float _dev) =>
    float score = 30.0
    float upper = not na(_basis) and not na(_dev) ? _basis + _dev * vixBbMult : na
    float lower = not na(_basis) and not na(_dev) ? _basis - _dev * vixBbMult : na
    float width = not na(upper) and not na(lower) ? upper - lower : na
    float pos = not na(width) and width > 0 ? (_vixClose - lower) / width : na

    if not na(pos)
        score := pos >= 1.20 ? 95.0 :
             pos >= 1.00 ? 85.0 :
             pos >= 0.80 ? 70.0 :
             pos >= 0.55 ? 50.0 :
             pos >= 0.25 ? 30.0 :
             20.0
    score

f_ratioVolatility(float _ratio) =>
    na(_ratio) ? na :
     _ratio >= 1.80 ? 95.0 :
     _ratio >= 1.50 ? 80.0 :
     _ratio >= 1.25 ? 65.0 :
     _ratio >= 1.05 ? 45.0 :
     _ratio >= 0.85 ? 30.0 :
     20.0

f_sigmaVolatility(float _spyEdge, float _qqqEdge, float _sigmaEdge) =>
    float disagreement = not na(_spyEdge) and not na(_qqqEdge) ? math.abs(_spyEdge - _qqqEdge) * 50.0 : 0.0
    float instability = not na(_sigmaEdge) and not na(_sigmaEdge[sigmaInstabilityLen]) ? math.abs(_sigmaEdge - _sigmaEdge[sigmaInstabilityLen]) * 100.0 : 0.0
    math.min(100.0, disagreement + instability)

f_weightedVolatility(float _atrVol, float _rangeVol, float _vixVol, float _sigmaVol) =>
    float total = 0.0
    float sum = 0.0

    if not na(_atrVol) and volAtrW > 0
        sum += _atrVol * volAtrW
        total += volAtrW
    if not na(_rangeVol) and volRangeW > 0
        sum += _rangeVol * volRangeW
        total += volRangeW
    if not na(_vixVol) and volVixW > 0
        sum += _vixVol * volVixW
        total += volVixW
    if not na(_sigmaVol) and volSigmaW > 0
        sum += _sigmaVol * volSigmaW
        total += volSigmaW

    total > 0 ? sum / total : na

f_volatilityText(float _score) =>
    na(_score) ? "Volatility: NA" :
     _score < 30 ? "Normal Volatility" :
     _score < 55 ? "Elevated Volatility" :
     _score < 80 ? "High Volatility" :
     "Extreme Volatility"

f_symbolOutlookCell(string _txt, float _score, string _volText) =>
    _txt + (not na(_score) ? "\nExh:" + str.tostring(_score, "#") : "") + "\n" + _volText

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Symbols
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
spyTicker = useExtended ? ticker.modify(spySymbol, session=session.extended) : spySymbol
qqqTicker = useExtended ? ticker.modify(qqqSymbol, session=session.extended) : qqqSymbol
iwmTicker = useExtended ? ticker.modify(iwmSymbol, session=session.extended) : iwmSymbol
vixTicker = vixSymbol

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Data
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[spyO1, spyH1, spyL1, spyC1, spyPC1, spyV1, spyVma1, spyAtr1] = f_data(spyTicker, tf1)
[spyO2, spyH2, spyL2, spyC2, spyPC2, spyV2, spyVma2, spyAtr2] = f_data(spyTicker, tf2)
[spyO3, spyH3, spyL3, spyC3, spyPC3, spyV3, spyVma3, spyAtr3] = f_data(spyTicker, tf3)

[qqqO1, qqqH1, qqqL1, qqqC1, qqqPC1, qqqV1, qqqVma1, qqqAtr1] = f_data(qqqTicker, tf1)
[qqqO2, qqqH2, qqqL2, qqqC2, qqqPC2, qqqV2, qqqVma2, qqqAtr2] = f_data(qqqTicker, tf2)
[qqqO3, qqqH3, qqqL3, qqqC3, qqqPC3, qqqV3, qqqVma3, qqqAtr3] = f_data(qqqTicker, tf3)

[iwmO, iwmH, iwmL, iwmC, iwmPC, iwmV, iwmVma, iwmAtr] = f_data(iwmTicker, riskTf)
[vixO, vixH, vixL, vixC, vixPC, vixV, vixVma, vixAtr] = f_data(vixTicker, riskTf)

[spyD, spyDP] = f_dayData(spyTicker)
[qqqD, qqqDP] = f_dayData(qqqTicker)
[iwmD, iwmDP] = f_dayData(iwmTicker)
[vixD, vixDP] = f_dayData(vixTicker)

[vixBasis, vixDev] = f_vixBands(vixTicker, riskTf)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Scores
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[spyScore1, spyPct1, spyEdge1] = f_pressure(spyO1, spyH1, spyL1, spyC1, spyPC1, spyAtr1, spyV1, spyVma1, true)
[spyScore2, spyPct2, spyEdge2] = f_pressure(spyO2, spyH2, spyL2, spyC2, spyPC2, spyAtr2, spyV2, spyVma2, true)
[spyScore3, spyPct3, spyEdge3] = f_pressure(spyO3, spyH3, spyL3, spyC3, spyPC3, spyAtr3, spyV3, spyVma3, true)

[qqqScore1, qqqPct1, qqqEdge1] = f_pressure(qqqO1, qqqH1, qqqL1, qqqC1, qqqPC1, qqqAtr1, qqqV1, qqqVma1, true)
[qqqScore2, qqqPct2, qqqEdge2] = f_pressure(qqqO2, qqqH2, qqqL2, qqqC2, qqqPC2, qqqAtr2, qqqV2, qqqVma2, true)
[qqqScore3, qqqPct3, qqqEdge3] = f_pressure(qqqO3, qqqH3, qqqL3, qqqC3, qqqPC3, qqqAtr3, qqqV3, qqqVma3, true)

[iwmScore, iwmPct, iwmEdge] = f_pressure(iwmO, iwmH, iwmL, iwmC, iwmPC, iwmAtr, iwmV, iwmVma, true)
[vixScore, vixPct, vixEdge] = f_pressure(vixO, vixH, vixL, vixC, vixPC, vixAtr, vixV, vixVma, false)

sigmaEdge1 = f_weightedEdge(spyEdge1, qqqEdge1)
sigmaEdge2 = f_weightedEdge(spyEdge2, qqqEdge2)
sigmaEdge3 = f_weightedEdge(spyEdge3, qqqEdge3)

[sigmaScore1, sigmaPct1] = f_edgeToScore(sigmaEdge1)
[sigmaScore2, sigmaPct2] = f_edgeToScore(sigmaEdge2)
[sigmaScore3, sigmaPct3] = f_edgeToScore(sigmaEdge3)

iwmFlag = showIwmRow ? f_confirmFlag(sigmaScore2, iwmScore, false) : 0
vixFlag = showVixRow ? f_confirmFlag(sigmaScore2, vixScore, true) : 0

supportText = f_supportText(sigmaScore2, iwmFlag, vixFlag)
supportMarks = "VIX " + (vixFlag > 0 ? "✓" : vixFlag < 0 ? "✕" : "–") + "   IWM " + (iwmFlag > 0 ? "✓" : iwmFlag < 0 ? "✕" : "–")
supportColor = f_supportBg(sigmaScore2, iwmFlag, vixFlag)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Current Symbol Outlook + Volatility
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
chartRsi = ta.rsi(close, rsiLen)
dailyRsi = request.security(syminfo.tickerid, "D", ta.rsi(close, dailyRsiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
rsiRoc = ta.roc(chartRsi, rsiRocLen)

chartAtr = ta.atr(outAtrLen)
chartAtrAvg = ta.sma(chartAtr, outAtrAvgLen)

chartRange = high - low
chartRangeAvg = ta.sma(chartRange, rangeAvgLen)

rsiExh = f_rsiExhaustion(chartRsi, dailyRsi, rsiRoc)
atrExh = f_atrExhaustion(chartAtr, chartAtrAvg)
sigmaExh = f_sigmaExhaustion(sigmaScore2)
iwmExh = f_iwmExhaustion(sigmaScore2, iwmScore)
vixExh = f_vixExhaustion(vixScore, vixC, vixBasis, vixDev)

symbolOutlookScore = f_weightedOutlook(rsiExh, atrExh, sigmaExh, iwmExh, vixExh)
symbolOutlookText = f_symbolOutlookText(symbolOutlookScore)
symbolOutlookColor = f_symbolOutlookBg(symbolOutlookScore)
symbolOutlookTitle = syminfo.ticker + " Outlook"

chartAtrVol = f_ratioVolatility(not na(chartAtrAvg) and chartAtrAvg > 0 ? chartAtr / chartAtrAvg : na)
chartRangeVol = f_ratioVolatility(not na(chartRangeAvg) and chartRangeAvg > 0 ? chartRange / chartRangeAvg : na)
vixVol = f_vixVolatility(vixC, vixBasis, vixDev)
sigmaVol = f_sigmaVolatility(spyEdge2, qqqEdge2, sigmaEdge2)

volatilityScore = f_weightedVolatility(chartAtrVol, chartRangeVol, vixVol, sigmaVol)
volatilityText = f_volatilityText(volatilityScore)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(f_position(tablePos), 6, 10, border_width=1, frame_width=1, frame_color=color.new(color.white, 55), border_color=color.new(color.white, 75))
txtSize = f_size(txtSizeInput)

f_rowFull(int _r, string _name, int _s1, int _s2, int _s3, float _p1, float _p2, float _p3, float _last, float _prev) =>
    table.cell(dash, 0, _r, _name, text_color=textColor, bgcolor=headerColor, text_size=txtSize)
    table.cell(dash, 1, _r, f_mainCell(_s1, _p1), text_color=textColor, bgcolor=f_bg(_s1, false), text_size=txtSize)
    table.cell(dash, 2, _r, f_mainCell(_s2, _p2), text_color=textColor, bgcolor=f_bg(_s2, false), text_size=txtSize)
    table.cell(dash, 3, _r, f_mainCell(_s3, _p3), text_color=textColor, bgcolor=f_bg(_s3, false), text_size=txtSize)
    table.cell(dash, 4, _r, showPrice ? f_priceText(_last) : "-", text_color=textColor, bgcolor=color.new(color.black, 70), text_size=txtSize)
    table.cell(dash, 5, _r, showDayChange ? f_dayPctText(_last, _prev) : "-", text_color=textColor, bgcolor=f_dayBg(_last, _prev, false), text_size=txtSize)

f_rowRisk(int _r, string _name, int _score, float _pct, float _last, float _prev, bool _isVix) =>
    table.cell(dash, 0, _r, _name, text_color=textColor, bgcolor=headerColor, text_size=txtSize)
    table.cell(dash, 1, _r, "-", text_color=textColor, bgcolor=color.new(color.black, 85), text_size=txtSize)
    table.cell(dash, 2, _r, f_riskCell(_score, _pct, _isVix), text_color=textColor, bgcolor=f_bg(_score, _isVix), text_size=txtSize)
    table.cell(dash, 3, _r, "-", text_color=textColor, bgcolor=color.new(color.black, 85), text_size=txtSize)
    table.cell(dash, 4, _r, showPrice ? f_priceText(_last) : "-", text_color=textColor, bgcolor=color.new(color.black, 70), text_size=txtSize)
    table.cell(dash, 5, _r, showDayChange ? f_dayPctText(_last, _prev) : "-", text_color=textColor, bgcolor=f_dayBg(_last, _prev, _isVix), text_size=txtSize)

if barstate.islast
    table.clear(dash, 0, 0, 5, 9)

    table.cell(dash, 0, 0, isAr ? "الأصل" : "Asset", text_color=textColor, bgcolor=headerColor, text_size=txtSize)
    table.cell(dash, 1, 0, f_tfName(tf1), text_color=textColor, bgcolor=headerColor, text_size=txtSize)
    table.cell(dash, 2, 0, f_tfName(tf2), text_color=textColor, bgcolor=headerColor, text_size=txtSize)
    table.cell(dash, 3, 0, f_tfName(tf3), text_color=textColor, bgcolor=headerColor, text_size=txtSize)
    table.cell(dash, 4, 0, isAr ? "السعر" : "Last", text_color=textColor, bgcolor=headerColor, text_size=txtSize)
    table.cell(dash, 5, 0, isAr ? "اليومي %" : "Day %", text_color=textColor, bgcolor=headerColor, text_size=txtSize)

    int r = 1

    f_rowFull(r, "SPY", spyScore1, spyScore2, spyScore3, spyPct1, spyPct2, spyPct3, spyD, spyDP)
    r += 1

    f_rowFull(r, "QQQ", qqqScore1, qqqScore2, qqqScore3, qqqPct1, qqqPct2, qqqPct3, qqqD, qqqDP)
    r += 1

    f_rowFull(r, "Σ SPY+QQQ", sigmaScore1, sigmaScore2, sigmaScore3, sigmaPct1, sigmaPct2, sigmaPct3, float(na), float(na))
    r += 1

    if showIwmRow
        f_rowRisk(r, "IWM " + f_tfName(riskTf), iwmScore, iwmPct, iwmD, iwmDP, false)
        r += 1

    if showVixRow
        f_rowRisk(r, "VIX " + f_tfName(riskTf), vixScore, vixPct, vixD, vixDP, true)
        r += 1

    table.cell(dash, 0, r, isAr ? "دعم السوق" : "MARKET SUPPORT", text_color=textColor, bgcolor=headerColor, text_size=txtSize)
    table.cell(dash, 1, r, supportText, text_color=textColor, bgcolor=supportColor, text_size=txtSize)
    table.cell(dash, 2, r, supportMarks, text_color=textColor, bgcolor=supportColor, text_size=txtSize)
    table.cell(dash, 3, r, "", text_color=textColor, bgcolor=supportColor, text_size=txtSize)
    table.cell(dash, 4, r, "-", text_color=textColor, bgcolor=color.new(color.black, 85), text_size=txtSize)
    table.cell(dash, 5, r, "-", text_color=textColor, bgcolor=color.new(color.black, 85), text_size=txtSize)
    r += 1

    if showSymbolOutlook
        table.cell(dash, 0, r, symbolOutlookTitle, text_color=textColor, bgcolor=headerColor, text_size=txtSize)
        table.cell(dash, 1, r, f_symbolOutlookCell(symbolOutlookText, symbolOutlookScore, volatilityText), text_color=textColor, bgcolor=symbolOutlookColor, text_size=txtSize)
        table.cell(dash, 2, r, "", text_color=textColor, bgcolor=symbolOutlookColor, text_size=txtSize)
        table.cell(dash, 3, r, "", text_color=textColor, bgcolor=symbolOutlookColor, text_size=txtSize)
        table.cell(dash, 4, r, "-", text_color=textColor, bgcolor=color.new(color.black, 85), text_size=txtSize)
        table.cell(dash, 5, r, "-", text_color=textColor, bgcolor=color.new(color.black, 85), text_size=txtSize)
````
