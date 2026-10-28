# Liquidity Inflow & Outflow

- url: https://www.tradingview.com/script/ERdbpC5X/
- type: indicator
- pine_id: PUB;e049683c88954d5b8220795321e062cc
- version: 1.0

## Description

لوصف:
يقوم المؤشر باكتشاف دخول السيولة غير الطبيعية إلى السهم أو الأصل المالي من خلال مقارنة حجم التداول الحالي بمتوسط أحجام التداول السابقة، مع التحقق من قوة الحركة السعرية ومدى الشمعة لتقليل الإشارات الكاذبة.

يعتمد المؤشر على ثلاثة عوامل رئيسية:

ارتفاع حجم التداول مقارنة بمتوسط الحجم خلال عدد محدد من الشموع.
اتساع مدى الشمعة مقارنة بالمدى الطبيعي للسوق.
قوة الإغلاق لتحديد ما إذا كانت السيولة ذات طابع شرائي أو مجرد نشاط مرتفع.

الإشارات:

🟢 سيولة شرائية غير طبيعية: عند دخول حجم تداول استثنائي مصحوب بحركة سعرية قوية وإغلاق إيجابي.
🟠 سيولة غير طبيعية: عند وجود نشاط تداول مرتفع بشكل ملحوظ دون اكتمال شروط القوة الشرائية.

الاستخدامات:

اكتشاف بداية تحركات المؤسسات والمحافظ الكبيرة.
رصد الاختراقات قبل اكتمال الاتجاه.
متابعة الأسهم النشطة ذات التدفقات المالية المرتفعة.
فلترة الفرص ذات الزخم والسيولة المرتفعة.

أفضل الفريمات:
15 دقيقة، 30 دقيقة، ساعة، 4 ساعات، ويومي.

التنبيهات:
يمكن إنشاء تنبيه تلقائي عند ظهور إشارة سيولة غير طبيعية أو سيولة شرائية غير طبيعية لمتابعة الفرص فور حدوثها.

## Source Code

````pine
//@version=6
indicator("تنبيه دخول سيولة غير طبيعية", overlay=true)

// الإعدادات
volLen      = input.int(20, "متوسط الحجم")
volMult     = input.float(2.5, "مضاعف الحجم غير الطبيعي")
rangeLen    = input.int(20, "متوسط مدى الشمعة")
rangeMult   = input.float(1.3, "مضاعف توسع المدى")
showLabels  = input.bool(true, "إظهار علامة على الشارت")

// الحسابات
avgVol   = ta.sma(volume, volLen)
avgRange = ta.sma(high - low, rangeLen)

abnormalVolume = volume > avgVol * volMult
wideCandle     = (high - low) > avgRange * rangeMult
bullishClose   = close > open
strongClose    = close > ((high + low) / 2)

// دخول سيولة شرائية غير طبيعية
buyLiquidity = abnormalVolume and wideCandle and bullishClose and strongClose

// سيولة غير طبيعية عامة، حتى لو ليست شرائية
anyLiquidity = abnormalVolume and wideCandle

// الرسم
plotshape(
     buyLiquidity,
     title="سيولة شرائية غير طبيعية",
     style=shape.labelup,
     text="سيولة شراء",
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.small
)

plotshape(
     anyLiquidity and not buyLiquidity,
     title="سيولة غير طبيعية",
     style=shape.labeldown,
     text="سيولة",
     location=location.abovebar,
     color=color.orange,
     textcolor=color.white,
     size=size.small
)

// تنبيهات
alertcondition(
     buyLiquidity,
     title="دخول سيولة شرائية غير طبيعية",
     message="دخول سيولة شرائية غير طبيعية على {{ticker}}"
)

alertcondition(
     anyLiquidity,
     title="سيولة غير طبيعية",
     message="حجم تداول ومدى شمعة غير طبيعي على {{ticker}}"
)
````
