<!-- tradingview-pine-id: PUB;755cd4177cda4e5bae8584e94d9cf2be -->
<!-- tradingviewscripts-format: 1 -->
# Universal MA Trend and Sideways Filter

Source: https://www.tradingview.com/script/Cl6A7fB0-MA-Trend-and-Sideways-Filter-RAD-FAD/

## Description

TREND UP DOWN SIDEWAY with colors and moving average that can be changed , nombures of candels and multi time frames

---

## Source Code

````pine
//@version=6
indicator("Universal MA Trend and Sideways Filter", overlay = true)

// ─────────────────────────────────────────────────────────────────────────────
// إعدادات المتوسط المتحرك
// ─────────────────────────────────────────────────────────────────────────────
groupMA = "المتوسط المتحرك"

maType = input.string("EMA", "نوع المتوسط", options = ["EMA", "SMA"], group = groupMA)
maLength = input.int(50, "طول المتوسط", minval = 1, group = groupMA)

useChartTimeframe = input.bool(true, "استخدم فريم الشارت الحالي", group = groupMA)
customTimeframe = input.timeframe("W", "فريم بديل للمتوسط", group = groupMA)

// ─────────────────────────────────────────────────────────────────────────────
// إعدادات السوق الجانبي
// ─────────────────────────────────────────────────────────────────────────────
groupSideways = "السوق الجانبي"

lookbackBars = input.int(20, "عدد الشموع للفحص", minval = 2, group = groupSideways)
minimumTouches = input.int(15, "الحد الأدنى لشموع الملامسة", minval = 1, group = groupSideways)

nearTolerancePct = input.float(
     0.0,
     "هامش القرب من المتوسط (%)",
     minval = 0.0,
     step = 0.01,
     group = groupSideways)

// ─────────────────────────────────────────────────────────────────────────────
// الألوان
// ─────────────────────────────────────────────────────────────────────────────
groupColors = "الألوان"

upColor = input.color(color.lime, "لون الترند الصاعد", group = groupColors)
downColor = input.color(color.red, "لون الترند الهابط", group = groupColors)
sidewaysColor = input.color(color.gray, "لون الترند الجانبي", group = groupColors)

showBackground = input.bool(true, "تلوين خلفية الشارت", group = groupColors)
showLabels = input.bool(true, "إظهار علامات تغير الاتجاه", group = groupColors)

// ─────────────────────────────────────────────────────────────────────────────
// دالة المتوسط المتحرك
// ─────────────────────────────────────────────────────────────────────────────
f_ma(_type, _length) =>
    _type == "EMA" ? ta.ema(close, _length) : ta.sma(close, _length)

// المتوسط على فريم الشارت الحالي
chartMA = f_ma(maType, maLength)

// أو المتوسط على فريم يختاره المستخدم، مثل الأسبوعي
customMA = request.security(
     syminfo.tickerid,
     customTimeframe,
     f_ma(maType, maLength),
     barmerge.gaps_off,
     barmerge.lookahead_off)

// اختيار المتوسط المطلوب
selectedMA = useChartTimeframe ? chartMA : customMA

// ─────────────────────────────────────────────────────────────────────────────
// كشف الشموع الملامسة أو القريبة من المتوسط
// ─────────────────────────────────────────────────────────────────────────────
toleranceValue = selectedMA * nearTolerancePct / 100.0

// إذا دخل المتوسط بين أعلى وأدنى الشمعة، أو ضمن هامش القرب، تعتبر ملامسة.
touchesMA = low <= selectedMA + toleranceValue and high >= selectedMA - toleranceValue

// نحول نتيجة كل شمعة إلى 1 عند الملامسة و0 عند عدمها.
// متوسط آخر N شمعة × N = عدد الشموع الملامسة.
// هذه الطريقة تتجنب خطأ دالة sum.
touchAverage = ta.sma(touchesMA ? 1.0 : 0.0, lookbackBars)
touchCount = int(nz(touchAverage, 0.0) * lookbackBars)

enoughBars = bar_index >= lookbackBars - 1

// مثال افتراضي: 15 شمعة ملامسة من آخر 20 = سوق جانبي.
sidewaysTrend = enoughBars and touchCount >= minimumTouches

// ─────────────────────────────────────────────────────────────────────────────
// تحديد الاتجاه
//
// رمادي: سوق جانبي.
// أخضر: السعر فوق المتوسط.
// أحمر: السعر تحت المتوسط.
// ─────────────────────────────────────────────────────────────────────────────
upTrend = not sidewaysTrend and close > selectedMA
downTrend = not sidewaysTrend and close < selectedMA

trendState = sidewaysTrend ? 0 : upTrend ? 1 : downTrend ? -1 : 0

trendColor = sidewaysTrend ? sidewaysColor : upTrend ? upColor : downColor

trendChanged = trendState != trendState[1]
sidewaysStarted = sidewaysTrend and not sidewaysTrend[1]

// ─────────────────────────────────────────────────────────────────────────────
// العرض على الشارت
// ─────────────────────────────────────────────────────────────────────────────
plot(
     selectedMA,
     title = "المتوسط المتحرك",
     color = trendColor,
     linewidth = 3)

bgcolor(
     showBackground ? color.new(trendColor, 88) : na,
     title = "لون اتجاه السوق")

plotshape(
     showLabels and trendChanged and upTrend,
     title = "بداية ترند صاعد",
     text = "UP",
     style = shape.labelup,
     location = location.belowbar,
     color = upColor,
     textcolor = color.white,
     size = size.tiny)

plotshape(
     showLabels and trendChanged and downTrend,
     title = "بداية ترند هابط",
     text = "DOWN",
     style = shape.labeldown,
     location = location.abovebar,
     color = downColor,
     textcolor = color.white,
     size = size.tiny)

plotshape(
     showLabels and sidewaysStarted,
     title = "بداية سوق جانبي",
     text = "SIDEWAYS",
     style = shape.labeldown,
     location = location.abovebar,
     color = sidewaysColor,
     textcolor = color.white,
     size = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// التنبيهات
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(
     upTrend and not upTrend[1],
     title = "بداية ترند صاعد",
     message = "الترند أصبح صاعدًا فوق المتوسط المتحرك.")

alertcondition(
     downTrend and not downTrend[1],
     title = "بداية ترند هابط",
     message = "الترند أصبح هابطًا تحت المتوسط المتحرك.")

alertcondition(
     sidewaysStarted,
     title = "بداية سوق جانبي",
     message = "تم رصد عدد كبير من الشموع المتقاطعة مع المتوسط: السوق جانبي، تجنب الدخول.")
````
