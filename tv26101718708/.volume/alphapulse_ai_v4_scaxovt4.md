# AlphaPulse AI v4

- url: https://www.tradingview.com/script/SCAxOVT4-AlphaPulse-AI-v4/
- type: indicator
- pine_id: PUB;41fa005532f044feba69a1c07414ce71
- version: 1.0

## Description

AlphaPulse AI v4 

Overview:
AlphaPulse AI v4 is an advanced technical analysis indicator that combines RSI, MFI, Volume Flow Analysis, and Market Structure to provide comprehensive insights into market momentum, liquidity, and potential trading opportunities.

⚠️ Important Note on RSI Support/Resistance & Trendlines:
The Support/Resistance levels and Trendlines on RSI are optional features (disabled by default) added for traders who use these techniques in their analysis.

Different trading schools have varying approaches to RSI-based S/R and trendlines:

Some traders draw support/resistance directly on RSI oscillator

Others use trendlines on RSI to identify momentum shifts

These are not universally accepted but can be valuable tools for those who incorporate them into their strategy

These features are included for your benefit - enable them if they align with your trading methodology, or leave them disabled if you prefer traditional RSI analysis.

📊 Main Components:
1. RSI Panel (Lower Pane)
Standard RSI (Purple Line):

Measures momentum strength between 0-100

Default Period: 14

Key Levels:

50: Neutral zone

60: Strong bullish momentum

40: Weak/bearish territory

80: Overbought (overheated)

20: Oversold (extreme outflow)

MFI - Money Flow Index (Blue Line):

Volume-weighted RSI that measures buying/selling pressure

Default Period: 14

Uses same threshold levels as RSI

Combines price momentum with volume flow

Daily RSI (White Line - Optional):

Daily timeframe RSI visible on all chart timeframes

Provides longer-term momentum context

Default: OFF

Display Styles: Line / Circles / Dots

Customizable color

RSI-2 (Yellow Line - Optional):

Short-term RSI for faster signals

Default: OFF

Default Period: 9

Multi-Timeframe Support:

Chart timeframe (default)

Custom: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 30, 60 minutes

Display Styles: Line / Circles / Dots

2. Support & Resistance on RSI (Optional - OFF by default)
Purpose: Identify key reversal zones directly on RSI oscillator

Features:

Red Dashed Lines: Resistance levels on RSI

Green Dashed Lines: Support levels on RSI

Timeframe Options:

Chart TF: Based on current chart RSI

Daily: Based on Daily RSI

Period Range: 1 to 30 days (adjustable lookback)

Lookback Bars: Customizable (default 20)

Usage:
When RSI approaches previous highs/lows, these levels can act as psychological resistance/support zones for momentum shifts.

3. RSI Trendlines (Optional - OFF by default)
Ascending Trendline (Green):

Drawn on Daily RSI

Connects higher lows in RSI

Indicates sustained bullish momentum

Descending Trendline (Red):

Drawn on Daily RSI

Connects lower highs in RSI

Indicates sustained bearish momentum

Auto-Detection:
Uses pivot point detection to automatically draw trendlines on Daily RSI based on swing highs and lows.

Note: Trendlines extend to the right to project future momentum direction.

4. Divergence Detection
Bullish Divergence (Label: "Bull Div"):

Price makes a lower low

RSI makes a higher low

Suggests potential bullish reversal

Bearish Divergence (Label: "Bear Div"):

Price makes a higher high

RSI makes a lower high

Suggests potential bearish reversal

Default: ON
Detection Period: 14 bars

🎛️ Dashboard
Location: Bottom Right (customizable to 4 positions)

Default Active Elements:

VWAP (Volume Weighted Average Price):

Shows if price is Above/Below VWAP

Displays percentage distance

Green: Above (bullish position)

Red: Below (bearish position)

U/D Ratio (Up/Down Volume Ratio):

Ratio of buying volume to selling volume

Green: ≥ 1.5 (strong buying pressure)

Red: ≤ 0.8 (strong selling pressure)

Gray: Neutral zone

ATR (Average True Range):

Market volatility measure

Displayed as percentage of price

Helps determine stop-loss distances

RSI/MFI Agreement:

"Agreement Up" (Green): Both RSI and MFI bullish

"Agreement Down" (Red): Both RSI and MFI bearish

"Divergence" (Orange): RSI and MFI conflicting signals

Optional Dashboard Elements (Enable in settings):

Flow Score

RSI Structure

Daily RSI value

RSI-2 value

MFI value

Twiggs Flow

Signal Quality

Market Phase Analysis (Accumulation/Expansion/Distribution/Exhaustion)

📊 Volume Bar
Default Position: Top Center (6 position options)

Displays:

Volume Ratio: Current volume vs 20-period average

Inflow (Green): Buying volume (smoothed)

Outflow (Red): Selling volume (smoothed)

Delta (Green/Red): Difference between inflow and outflow

Size Options: Small / Normal / Large

Usage:
Confirms momentum signals by showing actual money flow direction. High inflow with bullish RSI = strong confirmation.

⚙️ How to Use the Indicator:
For Trend Following:
Enable Daily RSI to see long-term momentum

Enable Daily RSI Trendlines to identify trend direction

Use RSI/MFI Agreement in Dashboard for confirmation

Check Volume Bar for liquidity support

For Reversal Trading:
Enable Divergence Detection (ON by default)

Enable RSI S/R to identify reversal zones

Watch for price reaction at S/R levels combined with divergence

Confirm with U/D Ratio shift in Dashboard

For Short-Term Scalping:
Enable RSI-2 on lower timeframes (1-5 minutes)

Use Volume Bar to confirm quick momentum shifts

Watch for rapid RSI-2 moves with volume confirmation

For Multi-Timeframe Analysis:
Keep Daily RSI enabled on lower timeframes

Use RSI-2 with custom higher timeframe

Look for alignment: Daily RSI trend + Short-term RSI-2 signal

Confirm with Volume Bar and Dashboard metrics

🔔 Alerts (Optional):
Bullish Expansion Pressure

Bullish/Bearish Divergence Detected

Strong Bullish/Bearish Flow

✅ Best Practices:
Start with defaults - Enable optional features as you learn the indicator

RSI S/R and Trendlines - Only use if you understand RSI-based technical analysis

Volume confirmation - Always check Volume Bar for liquidity support

Dashboard context - Use VWAP and U/D Ratio for market structure confirmation

Multi-timeframe - Combine Daily RSI with shorter-term signals for higher probability setups

⚠️ Disclaimer:
This indicator is a tool for analysis, not a trading system. Always combine with proper risk management and your own analysis.


نظرة عامة:
AlphaPulse AI v4 هو مؤشر تحليل فني متقدم يجمع بين RSI، MFI، تحليل تدفق السيولة، وهيكل السوق لتوفير رؤية شاملة عن زخم السوق، السيولة، والفرص التداولية المحتملة.

⚠️ ملاحظة مهمة حول الدعم/المقاومة وخطوط الترند على RSI:
مستويات الدعم والمقاومة و خطوط الترند على RSI هي ميزات اختيارية (مغلقة افتراضيًا) تم إضافتها للمتداولين الذين يستخدمون هذه التقنيات في تحليلهم.

المدارس المختلفة في التحليل الفني لها مناهج متباينة تجاه الدعم/المقاومة وخطوط الترند على RSI:

بعض المتداولين يرسمون الدعم والمقاومة مباشرة على مؤشر RSI

آخرون يستخدمون خطوط الترند على RSI لتحديد تحولات الزخم

هذه التقنيات ليست مقبولة عالميًا لكنها يمكن أن تكون أدوات قيمة لمن يدمجها في استراتيجيته

تم تضمين هذه الميزات لفائدتك - فعّلها إذا كانت تتماشى مع منهجية التداول الخاصة بك، أو اتركها مغلقة إذا كنت تفضل التحليل التقليدي للـ RSI.

📊 المكونات الرئيسية:
1. بانيل RSI (الجزء السفلي)
RSI القياسي (الخط البنفسجي):

يقيس قوة الزخم بين 0-100

الفترة الافتراضية: 14

المستويات الرئيسية:

50: منطقة محايدة

60: زخم صاعد قوي

40: منطقة ضعيفة/هابطة

80: تشبع شرائي (Overbought)

20: تشبع بيعي (Oversold)

MFI - مؤشر تدفق الأموال (الخط الأزرق):

RSI مرجح بالحجم يقيس ضغط الشراء/البيع

الفترة الافتراضية: 14

يستخدم نفس مستويات RSI

يجمع بين زخم السعر وتدفق الحجم

Daily RSI (الخط الأبيض - اختياري):

RSI يومي مرئي على جميع الأطر الزمنية

يوفر سياق زخم طويل المدى

افتراضيًا: مغلق

أنماط العرض: خط / دوائر / نقاط

لون قابل للتخصيص

RSI-2 (الخط الأصفر - اختياري):

RSI قصير المدى لإشارات أسرع

افتراضيًا: مغلق

الفترة الافتراضية: 9

دعم الأطر الزمنية المتعددة:

إطار الشارت (افتراضي)

مخصص: 1، 2، 3، 4، 5، 6، 7، 8، 9، 10، 15، 30، 60 دقيقة

أنماط العرض: خط / دوائر / نقاط

2. الدعم والمقاومة على RSI (اختياري - مغلق افتراضيًا)
الغرض: تحديد مناطق الانعكاس الرئيسية مباشرة على مؤشر RSI

الميزات:

خطوط حمراء منقطة: مستويات مقاومة على RSI

خطوط خضراء منقطة: مستويات دعم على RSI

خيارات الإطار الزمني:

إطار الشارت: بناءً على RSI الحالي

يومي: بناءً على RSI اليومي

نطاق المدة: من 1 إلى 30 يوم (lookback قابل للتعديل)

عدد الأعمدة: قابل للتخصيص (افتراضي 20)

الاستخدام:
عندما يقترب RSI من القمم/القيعان السابقة، يمكن أن تعمل هذه المستويات كمناطق مقاومة/دعم نفسية لتحولات الزخم.

3. خطوط الترند على RSI (اختياري - مغلق افتراضيًا)
خط الترند الصاعد (أخضر):

يُرسم على RSI اليومي

يربط القيعان الأعلى في RSI

يشير إلى زخم صاعد مستدام

خط الترند الهابط (أحمر):

يُرسم على RSI اليومي

يربط القمم الأدنى في RSI

يشير إلى زخم هابط مستدام

الكشف التلقائي:
يستخدم كشف نقاط المحور لرسم خطوط الترند تلقائيًا على RSI اليومي بناءً على القمم والقيعان المتأرجحة.

ملاحظة: تمتد خطوط الترند إلى اليمين لتوقع اتجاه الزخم المستقبلي.

4. كشف الاختلاف (Divergence)
الاختلاف الصاعد (تسمية: "Bull Div"):

السعر يسجل قاع أدنى

RSI يسجل قاع أعلى

يشير إلى انعكاس صاعد محتمل

الاختلاف الهابط (تسمية: "Bear Div"):

السعر يسجل قمة أعلى

RSI يسجل قمة أدنى

يشير إلى انعكاس هابط محتمل

افتراضيًا: مفعّل
فترة الكشف: 14 عمود

🎛️ الداشبورد
الموقع: أسفل اليمين (قابل للتخصيص إلى 4 مواقع)

العناصر المفعلة افتراضيًا:

VWAP (متوسط السعر المرجح بالحجم):

يعرض ما إذا كان السعر أعلى/أسفل VWAP

يعرض نسبة المسافة المئوية

أخضر: أعلى (موقف صاعد)

أحمر: أسفل (موقف هابط)

U/D Ratio (نسبة الحجم الصاعد/الهابط):

نسبة حجم الشراء إلى حجم البيع

أخضر: ≥ 1.5 (ضغط شراء قوي)

أحمر: ≤ 0.8 (ضغط بيع قوي)

رمادي: منطقة محايدة

ATR (متوسط المدى الحقيقي):

مقياس تقلب السوق

يُعرض كنسبة مئوية من السعر

يساعد في تحديد مسافات وقف الخسارة

RSI/MFI Agreement:

"Agreement Up" (أخضر): كلا RSI و MFI صاعدان

"Agreement Down" (أحمر): كلا RSI و MFI هابطان

"Divergence" (برتقالي): إشارات متضاربة بين RSI و MFI

عناصر الداشبورد الاختيارية (تفعل من الإعدادات):

Flow Score

RSI Structure

قيمة Daily RSI

قيمة RSI-2

قيمة MFI

Twiggs Flow

Signal Quality

تحليل مرحلة السوق (Accumulation/Expansion/Distribution/Exhaustion)

📊 شريط الحجم (Volume Bar)
الموقع الافتراضي: أعلى الوسط (6 خيارات للموقع)

يعرض:

Volume Ratio: الحجم الحالي مقابل متوسط 20 فترة

Inflow (أخضر): حجم الشراء (معدّل)

Outflow (أحمر): حجم البيع (معدّل)

Delta (أخضر/أحمر): الفرق بين التدفق الداخل والخارج

خيارات الحجم: صغير / عادي / كبير

الاستخدام:
يؤكد إشارات الزخم من خلال إظهار اتجاه تدفق الأموال الفعلي. تدفق داخل عالٍ مع RSI صاعد = تأكيد قوي.

⚙️ كيفية استخدام المؤشر:
لمتابعة الاتجاه:
فعّل Daily RSI لرؤية الزخم طويل المدى

فعّل خطوط الترند على Daily RSI لتحديد اتجاه الترند

استخدم RSI/MFI Agreement في الداشبورد للتأكيد

تحقق من شريط الحجم لدعم السيولة

للتداول الانعكاسي:
فعّل Divergence Detection (مفعّل افتراضيًا)

فعّل RSI S/R لتحديد مناطق الانعكاس

راقب رد فعل السعر عند مستويات S/R مع الاختلاف

أكّد مع تحول U/D Ratio في الداشبورد

للسكالبينج قصير المدى:
فعّل RSI-2 على الأطر الزمنية المنخفضة (1-5 دقائق)

استخدم شريط الحجم لتأكيد تحولات الزخم السريعة

راقب تحركات RSI-2 السريعة مع تأكيد الحجم

للتحليل متعدد الأطر الزمنية:
أبقِ Daily RSI مفعّلاً على الأطر الزمنية المنخفضة

استخدم RSI-2 مع إطار زمني أعلى مخصص

ابحث عن التوافق: اتجاه Daily RSI + إشارة RSI-2 قصيرة المدى

أكّد مع شريط الحجم و مقاييس الداشبورد

🔔 التنبيهات (اختيارية):
ضغط التوسع الصاعد

كشف الاختلاف الصاعد/الهابط

تدفق صاعد/هابط قوي

✅ أفضل الممارسات:
ابدأ بالإعدادات الافتراضية - فعّل الميزات الاختيارية كلما تعلمت المؤشر

RSI S/R وخطوط الترند - استخدمها فقط إذا كنت تفهم التحليل الفني المبني على RSI

تأكيد الحجم - دائمًا تحقق من شريط الحجم لدعم السيولة

سياق الداشبورد - استخدم VWAP و U/D Ratio لتأكيد هيكل السوق

متعدد الأطر الزمنية - اجمع بين Daily RSI والإشارات قصيرة المدى لإعدادات ذات احتمالية أعلى

⚠️ إخلاء مسؤولية:
هذا المؤشر هو أداة للتحليل، وليس نظام تداول. دائمًا اجمعه مع إدارة المخاطر المناسبة وتحليلك الخاص.

## Source Code

````pine
//@version=5
indicator("AlphaPulse AI v4", overlay=false, max_bars_back=500, max_lines_count=500, max_labels_count=500)

rsiLen = input.int(14, "RSI Length", group="RSI Settings")
rsiBull = input.int(50, "RSI Bull Level", group="RSI Settings")
rsiStrong = input.int(60, "RSI Strong Level", group="RSI Settings")
rsiWeak = input.int(40, "RSI Weak Level", group="RSI Settings")
rsiOverheated = input.int(80, "RSI Overheated Level", group="RSI Settings")
rsiExtremeOutflow = input.int(20, "RSI Extreme Outflow Level", group="RSI Settings")

showDailyRSI = input.bool(false, "Show Daily RSI", group="Daily RSI")
dailyRSIStyle = input.string("Line", "Daily RSI Style", options=["Line", "Circles", "Dots"], group="Daily RSI")
dailyRSIColor = input.color(color.white, "Daily RSI Color", group="Daily RSI")
showDailyTrendlines = input.bool(false, "Show Daily RSI Trendlines", group="Daily RSI")

showRSI2 = input.bool(false, "Show RSI-2", group="RSI-2")
rsi2Length = input.int(9, "RSI-2 Length", group="RSI-2")
rsi2TimeframeType = input.string("Chart", "RSI-2 Timeframe", options=["Chart", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "15", "30", "60"], group="RSI-2")
rsi2Style = input.string("Line", "RSI-2 Style", options=["Line", "Circles", "Dots"], group="RSI-2")
rsi2Color = input.color(color.yellow, "RSI-2 Color", group="RSI-2")

mfiLen = input.int(14, "MFI Length", group="MFI Settings")
mfiBull = input.int(50, "MFI Bull Level", group="MFI Settings")
mfiOverheated = input.int(80, "MFI Overheated Level", group="MFI Settings")
mfiExtremeOutflow = input.int(20, "MFI Extreme Outflow Level", group="MFI Settings")

udBullThreshold = input.float(1.5, "U/D Bullish Threshold", group="U/D Settings")
udBearThreshold = input.float(0.8, "U/D Bearish Threshold", group="U/D Settings")

runRateExpansion = input.int(120, "Run Rate Expansion %", group="Context Settings")
runRateExtreme = input.int(190, "Run Rate Extreme %", group="Context Settings")
expansionPressureLevel = input.int(85, "Expansion Pressure Level", group="Context Settings")

dryVolumeLevel = input.int(70, "Dry Volume Level %", group="Volume Settings")
compressionMax = input.int(100, "Compression Max %", group="Volume Settings")

momentumBuildLevel = input.int(70, "Momentum Build Level", group="Momentum Settings")

showTwiggs = input.bool(true, "Show Twiggs Flow", group="Twiggs Flow")
twiggsLength = input.int(21, "Twiggs Flow Length", group="Twiggs Flow")

showATR = input.bool(true, "Show ATR", group="ATR")
atrLength = input.int(14, "ATR Length", group="ATR")
atrMultiplier = input.float(1.0, "ATR Multiplier", group="ATR")

showSR = input.bool(false, "Show RSI Support & Resistance", group="S/R & Divergence")
srPeriod = input.int(5, "S/R Period (Days)", minval=1, maxval=30, group="S/R & Divergence")
srTimeframe = input.string("Chart", "S/R Timeframe", options=["Chart", "Daily"], group="S/R & Divergence")
srLookback = input.int(20, "S/R Lookback", group="S/R & Divergence")
showDivergence = input.bool(true, "Show Divergence", group="S/R & Divergence")

showDashboard = input.bool(true, "Show Dashboard", group="Dashboard")
showVWAP = input.bool(true, "Show VWAP in Dashboard", group="Dashboard")
showUDRatio = input.bool(true, "Show U/D Ratio in Dashboard", group="Dashboard")
showFlowScore = input.bool(false, "Show Flow Score", group="Dashboard")
showRSIStructure = input.bool(false, "Show RSI Structure", group="Dashboard")
showMFI = input.bool(false, "Show MFI", group="Dashboard")
showRSIMFI = input.bool(true, "Show RSI/MFI", group="Dashboard")
showTwiggsInDash = input.bool(false, "Show Twiggs Flow in Dashboard", group="Dashboard")
showATRInDash = input.bool(true, "Show ATR in Dashboard", group="Dashboard")
showSignalQuality = input.bool(false, "Show Signal Quality", group="Dashboard")
showPhaseScores = input.bool(false, "Show Phase Scores", group="Dashboard")
dashPosition = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Dashboard")

showVolumeBar = input.bool(true, "Show Volume Bar", group="Volume Bar")
volumeBarPosition = input.string("Top Center", "Volume Bar Position", options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Volume Bar")
volumeBarSize = input.string("Normal", "Volume Bar Size", options=["Small", "Normal", "Large"], group="Volume Bar")
showVolumeDelta = input.bool(true, "Show Volume Delta", group="Volume Bar")

enableAlerts = input.bool(false, "Enable Alerts", group="Alerts")

f_pct(val) => str.tostring(math.round(val, 1)) + "%"
f_textColor(val, bullLevel, bearLevel) => val >= bullLevel ? color.new(color.green, 0) : val <= bearLevel ? color.new(color.red, 0) : color.new(color.gray, 0)
f_qualityFilter(rsiVal, mfiVal) => rsiVal > rsiExtremeOutflow and rsiVal < rsiOverheated and mfiVal > mfiExtremeOutflow and mfiVal < mfiOverheated
f_tablePosition(pos) => pos == "Top Right" ? position.top_right : pos == "Top Left" ? position.top_left : pos == "Top Center" ? position.top_center : pos == "Bottom Right" ? position.bottom_right : pos == "Bottom Left" ? position.bottom_left : position.bottom_center
f_volumeBarSize(size) => size == "Small" ? size.tiny : size == "Normal" ? size.small : size.normal

rsi = ta.rsi(close, rsiLen)
dailyRSI = request.security(syminfo.tickerid, "D", ta.rsi(close, 14), lookahead=barmerge.lookahead_off)
rsi2TF = rsi2TimeframeType == "Chart" ? timeframe.period : rsi2TimeframeType == "1" ? "1" : rsi2TimeframeType == "2" ? "2" : rsi2TimeframeType == "3" ? "3" : rsi2TimeframeType == "4" ? "4" : rsi2TimeframeType == "5" ? "5" : rsi2TimeframeType == "6" ? "6" : rsi2TimeframeType == "7" ? "7" : rsi2TimeframeType == "8" ? "8" : rsi2TimeframeType == "9" ? "9" : rsi2TimeframeType == "10" ? "10" : rsi2TimeframeType == "15" ? "15" : rsi2TimeframeType == "30" ? "30" : "60"
rsi2 = request.security(syminfo.tickerid, rsi2TF, ta.rsi(close, rsi2Length), lookahead=barmerge.lookahead_off)
mfi = ta.mfi(hlc3, mfiLen)
vol = volume
volSma = ta.sma(volume, 20)
volRatio = vol / volSma
volumeInflow = close > open ? volume : 0
volumeOutflow = close < open ? volume : 0
volumeDelta = volumeInflow - volumeOutflow
volumeInflowSmooth = ta.ema(volumeInflow, 14)
volumeOutflowSmooth = ta.ema(volumeOutflow, 14)
volumeDeltaSmooth = volumeInflowSmooth - volumeOutflowSmooth
vwapValue = ta.vwap(hlc3)
vwapDist = ((close - vwapValue) / vwapValue) * 100
atr = ta.atr(atrLength) * atrMultiplier
atrPercent = (atr / close) * 100
twiggsFlow = showTwiggs ? ta.ema((close - open) / (high - low == 0 ? 1 : high - low) * volume, twiggsLength) : 0
upVolume = close > open ? volume : 0
downVolume = close < open ? volume : 0
upVolumeSum = math.sum(upVolume, 14)
downVolumeSum = math.sum(downVolume, 14)
udRatio = downVolumeSum > 0 ? upVolumeSum / downVolumeSum : upVolumeSum
upPressure = math.max(rsi - 50, 0) / 50 * 100
downPressure = math.max(50 - rsi, 0) / 50 * 100
upPressureSmooth = ta.ema(upPressure, 14)
downPressureSmooth = ta.ema(downPressure, 14)
smoothScore = ta.ema(upPressure - downPressure, 14)
smoothPeriod = smoothScore > 0 ? upPressure : downPressure
bullFlowScore = (rsi > rsiBull ? 20 : 0) + (mfi > mfiBull ? 20 : 0) + (udRatio > udBullThreshold ? 20 : 0) + (close > ta.sma(close, 20) ? 20 : 0) + (ta.rising(close, 3) ? 20 : 0)
bearFlowScore = (rsi < rsiWeak ? 20 : 0) + (mfi < 50 ? 20 : 0) + (udRatio < udBearThreshold ? 20 : 0) + (close < ta.sma(close, 20) ? 20 : 0) + (ta.falling(close, 3) ? 20 : 0)
flowMax = math.max(bullFlowScore, bearFlowScore)
flowState = bullFlowScore > bearFlowScore ? "Bullish Flow" : bearFlowScore > bullFlowScore ? "Bearish Flow" : "Neutral"
flowScore = bullFlowScore - bearFlowScore
accumulationScore = math.min((udRatio > udBullThreshold ? 45 : 0) + (mfi > mfiBull ? 25 : 0) + (volRatio < 1.5 ? 30 : 0), 100)
expansionScore = math.min((mfi > mfiBull ? 35 : 0) + (rsi > rsiStrong ? 30 : 0) + (volRatio > 1.5 ? 35 : 0), 100)
distributionScore = math.min((udRatio < udBearThreshold ? 35 : 0) + (mfi < 50 ? 25 : 0) + (rsi < rsiWeak ? 40 : 0), 100)
exhaustionScore = math.min((rsi > rsiOverheated ? 40 : 0) + (mfi > mfiOverheated ? 25 : 0) + (volRatio > 2 ? 35 : 0), 100)
compressionScore = math.min((volRatio < 0.7 ? 50 : 0) + (atrPercent < 2 ? 50 : 0), 100)
congestionScore = math.min((ta.stdev(close, 20) < ta.sma(close, 20) * 0.02 ? 60 : 0) + (volRatio < 1.2 ? 40 : 0), 100)
runRate = (volRatio - 1) * 100
explosionState = upPressureSmooth > expansionPressureLevel and runRate > runRateExpansion ? true : false
marketStrength = upPressureSmooth > expansionPressureLevel and runRate > runRateExpansion ? "Strong Bull" : upPressureSmooth > 50 ? "Bullish" : downPressureSmooth > 50 ? "Bearish" : "Neutral"
tradeContext = upPressureSmooth > expansionPressureLevel and runRate > runRateExpansion ? "Bullish Expansion Pressure" : runRate < compressionMax and volRatio < 0.8 ? "Compression" : "Neutral"
runRateExtreme_val = runRate > runRateExtreme ? true : false
marketPhase = exhaustionScore > momentumBuildLevel ? "Exhaustion" : expansionScore > momentumBuildLevel ? "Expansion" : accumulationScore > momentumBuildLevel ? "Accumulation" : distributionScore > momentumBuildLevel ? "Distribution" : "Neutral"
phaseColor = marketPhase == "Accumulation" ? color.new(color.green, 70) : marketPhase == "Expansion" ? color.new(color.blue, 70) : marketPhase == "Distribution" ? color.new(color.orange, 70) : marketPhase == "Exhaustion" ? color.new(color.red, 70) : color.new(color.gray, 90)
signalQuality = f_qualityFilter(rsi, mfi) ? (flowMax > 60 ? "High Quality" : flowMax > 40 ? "Medium Quality" : "Low Quality") : "Filter OFF"

rsiForSR = srTimeframe == "Daily" ? dailyRSI : rsi
dailyRSIHistory = request.security(syminfo.tickerid, str.tostring(srPeriod) + "D", ta.rsi(close, 14), lookahead=barmerge.lookahead_off)

var line rsiResistanceLine = na
var line rsiSupportLine = na
if showSR
    highestRSI = ta.highest(rsiForSR, srLookback)
    lowestRSI = ta.lowest(rsiForSR, srLookback)
    if not na(rsiResistanceLine)
        line.delete(rsiResistanceLine)
    if not na(rsiSupportLine)
        line.delete(rsiSupportLine)
    rsiResistanceLine := line.new(bar_index - srLookback, highestRSI, bar_index, highestRSI, color=color.new(color.red, 30), width=2, style=line.style_dashed)
    rsiSupportLine := line.new(bar_index - srLookback, lowestRSI, bar_index, lowestRSI, color=color.new(color.green, 30), width=2, style=line.style_dashed)

var line dailyAscendingTrend = na
var line dailyDescendingTrend = na
if showDailyTrendlines and showDailyRSI
    lookbackBars = 50
    var int pivot1 = na
    var int pivot2 = na
    var float pivot1Val = na
    var float pivot2Val = na
    if ta.pivotlow(dailyRSI, 5, 5)
        pivot2 := pivot1
        pivot2Val := pivot1Val
        pivot1 := bar_index[5]
        pivot1Val := dailyRSI[5]
    if not na(pivot1) and not na(pivot2)
        if not na(dailyAscendingTrend)
            line.delete(dailyAscendingTrend)
        dailyAscendingTrend := line.new(pivot2, pivot2Val, pivot1, pivot1Val, extend=extend.right, color=color.new(color.green, 0), width=2, style=line.style_solid)
    var int pivotH1 = na
    var int pivotH2 = na
    var float pivotH1Val = na
    var float pivotH2Val = na
    if ta.pivothigh(dailyRSI, 5, 5)
        pivotH2 := pivotH1
        pivotH2Val := pivotH1Val
        pivotH1 := bar_index[5]
        pivotH1Val := dailyRSI[5]
    if not na(pivotH1) and not na(pivotH2)
        if not na(dailyDescendingTrend)
            line.delete(dailyDescendingTrend)
        dailyDescendingTrend := line.new(pivotH2, pivotH2Val, pivotH1, pivotH1Val, extend=extend.right, color=color.new(color.red, 0), width=2, style=line.style_solid)

priceLow = ta.lowest(low, 14)
rsiLow = ta.lowest(rsi, 14)
bullDiv = showDivergence and low == priceLow and rsi > rsiLow and rsi[14] == rsiLow
priceHigh = ta.highest(high, 14)
rsiHigh = ta.highest(rsi, 14)
bearDiv = showDivergence and high == priceHigh and rsi < rsiHigh and rsi[14] == rsiHigh
if bullDiv
    label.new(bar_index, rsi, "Bull Div", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)
if bearDiv
    label.new(bar_index, rsi, "Bear Div", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.small)

plot(rsi, "RSI", color=color.new(color.purple, 0), linewidth=1)
hline(50, "RSI Mid", color=color.new(color.gray, 50))
hline(rsiBull, "RSI Bull", color=color.new(color.green, 70))
hline(rsiWeak, "RSI Weak", color=color.new(color.red, 70))
hline(rsiOverheated, "RSI Overheated", color=color.new(color.red, 50))
hline(rsiExtremeOutflow, "RSI Extreme", color=color.new(color.green, 50))
plot(mfi, "MFI", color=color.new(color.blue, 0), linewidth=1)
dailyRSIPlot = showDailyRSI ? dailyRSI : na
plot(dailyRSIStyle == "Line" ? dailyRSIPlot : na, "Daily RSI", color=dailyRSIColor, linewidth=2)
plot(dailyRSIStyle == "Circles" ? dailyRSIPlot : na, "Daily RSI Circles", color=dailyRSIColor, style=plot.style_circles, linewidth=3)
plot(dailyRSIStyle == "Dots" ? dailyRSIPlot : na, "Daily RSI Dots", color=dailyRSIColor, style=plot.style_cross, linewidth=2)
rsi2Plot = showRSI2 ? rsi2 : na
plot(rsi2Style == "Line" ? rsi2Plot : na, "RSI-2", color=rsi2Color, linewidth=2)
plot(rsi2Style == "Circles" ? rsi2Plot : na, "RSI-2 Circles", color=rsi2Color, style=plot.style_circles, linewidth=3)
plot(rsi2Style == "Dots" ? rsi2Plot : na, "RSI-2 Dots", color=rsi2Color, style=plot.style_cross, linewidth=2)
bgcolor(showPhaseScores ? phaseColor : na, title="Phase Background")

if showDashboard
    var table dashboard = table.new(f_tablePosition(dashPosition), columns=2, rows=20, border_width=1)
    table.cell(dashboard, 0, 0, "Dashboard", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.normal)
    table.cell(dashboard, 1, 0, "", bgcolor=color.new(color.blue, 30))
    row = 1
    if showVWAP
        vwapText = close > vwapValue ? "Above" : "Below"
        vwapColor = close > vwapValue ? color.green : color.red
        table.cell(dashboard, 0, row, "VWAP", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, vwapText + " (" + f_pct(vwapDist) + ")", text_color=color.new(vwapColor, 0), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showUDRatio
        udText = str.tostring(math.round(udRatio, 2))
        udColor = udRatio >= udBullThreshold ? color.green : udRatio <= udBearThreshold ? color.red : color.gray
        table.cell(dashboard, 0, row, "U/D Ratio", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, udText, text_color=color.new(udColor, 0), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showATRInDash and showATR
        table.cell(dashboard, 0, row, "ATR", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, f_pct(atrPercent), text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showRSIMFI
        rsiMfiText = rsi > rsiBull and mfi > mfiBull ? "Agreement Up" : rsi < rsiWeak and mfi < 50 ? "Agreement Down" : "Divergence"
        rsiMfiColor = rsiMfiText == "Agreement Up" ? color.green : rsiMfiText == "Agreement Down" ? color.red : color.orange
        table.cell(dashboard, 0, row, "RSI/MFI", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, rsiMfiText, text_color=color.new(rsiMfiColor, 0), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showFlowScore
        table.cell(dashboard, 0, row, "Flow Score", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, str.tostring(flowScore), text_color=f_textColor(flowScore, 20, -20), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showRSIStructure
        rsiStructure = rsi > rsiStrong ? "Strong" : rsi > rsiBull ? "Bullish" : rsi < rsiWeak ? "Weak" : "Neutral"
        rsiColor = rsi > rsiStrong ? color.green : rsi > rsiBull ? color.lime : rsi < rsiWeak ? color.red : color.gray
        table.cell(dashboard, 0, row, "RSI Structure", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, rsiStructure, text_color=color.new(rsiColor, 0), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showDailyRSI
        table.cell(dashboard, 0, row, "Daily RSI", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, str.tostring(math.round(dailyRSI, 1)), text_color=f_textColor(dailyRSI, rsiBull, rsiWeak), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showRSI2
        table.cell(dashboard, 0, row, "RSI-2 (" + str.tostring(rsi2Length) + ")", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, str.tostring(math.round(rsi2, 1)), text_color=f_textColor(rsi2, 70, 30), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showMFI
        table.cell(dashboard, 0, row, "MFI", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, str.tostring(math.round(mfi, 1)), text_color=f_textColor(mfi, mfiBull, 50), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showTwiggsInDash and showTwiggs
        twiggsText = twiggsFlow > 0 ? "Positive Flow" : "Negative Flow"
        twiggsColor = twiggsFlow > 0 ? color.green : color.red
        table.cell(dashboard, 0, row, "Twiggs Flow", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, twiggsText, text_color=color.new(twiggsColor, 0), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showSignalQuality
        qualityColor = signalQuality == "High Quality" ? color.green : signalQuality == "Medium Quality" ? color.orange : signalQuality == "Low Quality" ? color.red : color.gray
        table.cell(dashboard, 0, row, "Signal Quality", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, signalQuality, text_color=color.new(qualityColor, 0), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
    if showPhaseScores
        table.cell(dashboard, 0, row, "Market Phase", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, marketPhase, text_color=color.white, bgcolor=phaseColor, text_size=size.small)
        row += 1
        table.cell(dashboard, 0, row, "Accumulation", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, str.tostring(accumulationScore), text_color=f_textColor(accumulationScore, 60, 40), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
        table.cell(dashboard, 0, row, "Expansion", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, str.tostring(expansionScore), text_color=f_textColor(expansionScore, 60, 40), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
        table.cell(dashboard, 0, row, "Exhaustion", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, str.tostring(exhaustionScore), text_color=f_textColor(exhaustionScore, 60, 40), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1
        table.cell(dashboard, 0, row, "Compression", text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
        table.cell(dashboard, 1, row, str.tostring(compressionScore), text_color=f_textColor(compressionScore, 60, 40), bgcolor=color.new(color.gray, 80), text_size=size.small)
        row += 1

if showVolumeBar
    var table volumeTable = table.new(f_tablePosition(volumeBarPosition), columns=4, rows=2, border_width=1)
    textSize = f_volumeBarSize(volumeBarSize)
    table.cell(volumeTable, 0, 0, "Volume", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=textSize)
    table.cell(volumeTable, 1, 0, "Inflow", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=textSize)
    table.cell(volumeTable, 2, 0, "Outflow", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=textSize)
    if showVolumeDelta
        table.cell(volumeTable, 3, 0, "Delta", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=textSize)
    volRatioText = str.tostring(math.round(volRatio, 2))
    volRatioColor = volRatio > 1.5 ? color.green : volRatio < 0.7 ? color.red : color.gray
    table.cell(volumeTable, 0, 1, volRatioText, text_color=color.new(volRatioColor, 0), bgcolor=color.new(color.gray, 80), text_size=textSize)
    inflowText = str.tostring(math.round(volumeInflowSmooth / 1000, 1)) + "K"
    table.cell(volumeTable, 1, 1, inflowText, text_color=color.new(color.green, 0), bgcolor=color.new(color.gray, 80), text_size=textSize)
    outflowText = str.tostring(math.round(volumeOutflowSmooth / 1000, 1)) + "K"
    table.cell(volumeTable, 2, 1, outflowText, text_color=color.new(color.red, 0), bgcolor=color.new(color.gray, 80), text_size=textSize)
    if showVolumeDelta
        deltaText = str.tostring(math.round(volumeDeltaSmooth / 1000, 1)) + "K"
        deltaColor = volumeDeltaSmooth > 0 ? color.green : color.red
        table.cell(volumeTable, 3, 1, deltaText, text_color=color.new(deltaColor, 0), bgcolor=color.new(color.gray, 80), text_size=textSize)

if enableAlerts
    if explosionState and not explosionState[1]
        alert("AlphaPulse: Bullish Expansion Pressure Detected!", alert.freq_once_per_bar)
    if bullDiv
        alert("AlphaPulse: Bullish Divergence Detected!", alert.freq_once_per_bar)
    if bearDiv
        alert("AlphaPulse: Bearish Divergence Detected!", alert.freq_once_per_bar)
    if flowScore > 50 and flowScore[1] <= 50
        alert("AlphaPulse: Strong Bullish Flow!", alert.freq_once_per_bar)
    if flowScore < -50 and flowScore[1] >= -50
        alert("AlphaPulse: Strong Bearish Flow!", alert.freq_once_per_bar)
````
