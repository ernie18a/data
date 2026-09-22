<!-- tradingview-pine-id: PUB;211f61bf271b4debb15eb930e37d01ef -->
<!-- tradingview-pine-version: 9.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA Ribbon + RSI + Liquidity + Golden Zone [prof]

Source: https://www.tradingview.com/script/az6UgFXt-EMA-Ribbon-prof/

## Description

# EMA Ribbon [prof] —  

## Overview

EMA Ribbon [prof] plots eight Exponential Moving Averages (EMAs) with staggered periods (default 24 down to 10) stacked on top of each other, forming a visual "ribbon" that reflects the current trend's direction and strength. When the eight lines are spread apart and neatly ordered, it signals a strong, clear trend; when the lines tangle and cross each other, it signals a choppy, range-bound market with no clear direction.

The indicator is designed to run directly on the price chart (overlay) and works on any market (stocks, forex, crypto, indices) and any timeframe.

## Key Features

- Eight EMAs with fully adjustable periods from the settings.
- Selectable price source (Close, High, Low, etc.) — defaults to High.
- "Drop first N candles" option to ignore a chosen number of the earliest candles before calculations start.
- "Offset" option to shift the ribbon left or right on the chart without affecting its underlying calculations.
- Automatic buy/sell signals (circles below/above the bar) triggered when price breaks through the entire ribbon to the upside or downside.
- Bar coloring (green/red) based on whether price is above or below the ribbon's midline, for quick at-a-glance trend reading.
- Full control over each line's color and thickness from the Style tab.

## How to Use It

- **Trend direction:** When price is above the ribbon and the lines are stacked with the shortest EMA on top, it supports a continuing uptrend; the mirror image supports a downtrend.
- **Trend strength:** The wider the gap between the lines, the stronger the momentum behind the move.
- **Dynamic support/resistance:** The ribbon itself can act as a dynamic support zone in an uptrend, or a dynamic resistance zone in a downtrend.
- **Signals:** The buy signal fires when price breaks above the highest point of the entire ribbon; the sell signal fires when price breaks below the lowest point. Treat these as additional confirmation, not standalone trade calls.
- It's best used alongside other tools (volume, support/resistance levels, momentum indicators) rather than relied on in isolation.

## Settings

| Setting | Description | Default |
|---|---|---|
| MA-1 to MA-8 period | Periods of the eight EMAs | 24, 22, 20, 18, 16, 14, 12, 10 |
| Source | Price source used for calculations | High |
| Drop first N candles | Number of leading candles excluded from calculations | 0 |
| Offset (Shift Ribbon) | Shifts the ribbon left/right on the chart | 8 |
| Show Buy/Sell Signals | Toggles the buy/sell signal markers | Enabled |
| Color Candles Above/Below Ribbon | Colors bars based on their position relative to the ribbon | Enabled |

## Disclaimer

This indicator is a technical analysis tool, not investment advice or a recommendation to buy or sell. Past performance does not guarantee future results. Users are solely responsible for their own trading decisions and should always apply independent risk and capital management before acting on any signal.

---

## Source Code

````pine
//@version=6
// ==========================================================================
// EMA Ribbon [prof] + RSI on Chart (plan z) + Liquidity Levels + Golden Zone
// --------------------------------------------------------------------------
// دمج 4 مؤشرات في سكربت واحد يعملان فوق نفس الرسم البياني (overlay):
//  1) EMA Ribbon: شريط من 8 متوسطات EMA متدرجة يوضح اتجاه وقوة الترند،
//     مع إشارات شراء/بيع وتلوين للشموع.
//  2) RSI on Chart (plan z): خط EMA تقريبي يمثّل "منطقة RSI = 50" مسقطة
//     على مقياس السعر مباشرة، بدل عرضه في نافذة منفصلة أسفل الشارت.
//  3) Liquidity Levels: يحدد شموع السيولة العالية (أعلى فوليوم) ويلوّنها
//     أصفر، ويرسم خط عند منتصفها يتلون أخضر/أحمر حسب موقع السعر منه.
//  4) Golden Zone: نسخة مبسّطة ومستقلة (مو مأخوذة حرفياً من أي مؤشر هيكلة
//     سوق جاهز) — تكتشف آخر قمة/قاع (Pivot) تلقائياً، ترسم فيبوناتشي بينهم،
//     وتلوّن منطقة الارتداد 0.5-0.618 كـ"منطقة ذهبية".
// كل مؤشر له مجموعة إعدادات منفصلة (Group) في نافذة الإعدادات لسهولة التمييز.
// ملاحظة: تمت إضافة max_lines_count=500 فقط داخل indicator() لأن أجزاء
// السيولة والمنطقة الذهبية ترسم خطوط (line.new) وتحتاجها لتعمل بشكل صحيح.
// ==========================================================================
indicator(title="EMA Ribbon + RSI + Liquidity + Golden Zone [prof]", shorttitle="EMA Ribbon + RSI + Liq + GZ", overlay=true, max_lines_count=500)

// دالة مساعدة تُستخدم مع "Drop first N candles" في مؤشر الشريط
dropn(src, n) =>
    na(src[n]) ? na : src

// ==========================================================================
// ============================  1) EMA Ribbon  ============================
// ==========================================================================
grpRibbon = "EMA Ribbon"

length1 = input.int(24, title="MA-1 period", minval=1, group=grpRibbon)
length2 = input.int(22, title="MA-2 period", minval=1, group=grpRibbon)
length3 = input.int(20, title="MA-3 period", minval=1, group=grpRibbon)
length4 = input.int(18, title="MA-4 period", minval=1, group=grpRibbon)
length5 = input.int(16, title="MA-5 period", minval=1, group=grpRibbon)
length6 = input.int(14, title="MA-6 period", minval=1, group=grpRibbon)
length7 = input.int(12, title="MA-7 period", minval=1, group=grpRibbon)
length8 = input.int(10, title="MA-8 period", minval=1, group=grpRibbon)
src = input.source(high, title="Source", group=grpRibbon)
dropCandles = input.int(0, minval=0, title="Drop first N candles", group=grpRibbon)

// إزاحة الشريط (Offset)
offsetInput = input.int(8, title="Offset (Shift Ribbon)", minval=-500, maxval=500, group=grpRibbon)

// إشارات الشراء والبيع
showSignals = input.bool(true, title="Show Buy/Sell Signals", group=grpRibbon)

// تلوين الشموع حسب موقعها من الشريط
colorCandles = input.bool(true, title="Color Candles Above/Below Ribbon", group=grpRibbon)

price = dropn(src, dropCandles)

ma1 = ta.ema(price, length1)
ma2 = ta.ema(price, length2)
ma3 = ta.ema(price, length3)
ma4 = ta.ema(price, length4)
ma5 = ta.ema(price, length5)
ma6 = ta.ema(price, length6)
ma7 = ta.ema(price, length7)
ma8 = ta.ema(price, length8)

plot(ma1, title="MA-1", color=#1f3a93, linewidth=2, offset=offsetInput)
plot(ma2, title="MA-2", color=#2e5fb5, linewidth=2, offset=offsetInput)
plot(ma3, title="MA-3", color=#3d82e0, linewidth=2, offset=offsetInput)
plot(ma4, title="MA-4", color=#6babf0, linewidth=2, offset=offsetInput)
plot(ma5, title="MA-5", color=#a8d4f5, linewidth=2, offset=offsetInput)
plot(ma6, title="MA-6", color=#4dd0c4, linewidth=2, offset=offsetInput)
plot(ma7, title="MA-7", color=#26a69a, linewidth=2, offset=offsetInput)
plot(ma8, title="MA-8", color=#1a8a7a, linewidth=2, offset=offsetInput)

// الحد العلوي والسفلي لكامل الشريط (لأجل إشارات الاختراق)
topBand = math.max(math.max(math.max(ma1, ma2), math.max(ma3, ma4)), math.max(math.max(ma5, ma6), math.max(ma7, ma8)))
bottomBand = math.min(math.min(math.min(ma1, ma2), math.min(ma3, ma4)), math.min(math.min(ma5, ma6), math.min(ma7, ma8)))

// ====== [تعديل] مطابقة الإشارات للإزاحة (الاختراق البصري) ======
offBars       = math.max(offsetInput, 0)
topBandVis    = topBand[offBars]
bottomBandVis = bottomBand[offBars]

buySignal = showSignals and ta.crossover(price, topBandVis)
sellSignal = showSignals and ta.crossunder(price, bottomBandVis)

plotshape(buySignal, title="Buy Signal", style=shape.circle, location=location.belowbar,
     color=color.lime, size=size.tiny)
plotshape(sellSignal, title="Sell Signal", style=shape.circle, location=location.abovebar,
     color=color.red, size=size.tiny)

// ====== تنبيه (Alert): اختراق السعر لكل مستويات شريط الـ EMA ======
alertcondition(buySignal, title="EMA Ribbon Breakout Up (Buy)",
     message="{{ticker}} ({{interval}}): السعر اخترق كل مستويات شريط EMA صعوداً")
alertcondition(sellSignal, title="EMA Ribbon Breakout Down (Sell)",
     message="{{ticker}} ({{interval}}): السعر كسر كل مستويات شريط EMA هبوطاً")

// تلوين الشموع حسب موقعها من متوسط الشريط
midBand = (ma1 + ma2 + ma3 + ma4 + ma5 + ma6 + ma7 + ma8) / 8
candleColor = price > midBand ? color.lime : price < midBand ? color.red : na

barcolor(colorCandles ? candleColor : na, title="Candle Trend Color")

// ==========================================================================
// ========================  2) RSI on Chart (plan z)  =====================
// ==========================================================================
grpRsi = "RSI on Chart (plan z)"

rsiperiod = input.int(250, minval=2, title="RSI Period", inline="RSI", group=grpRsi)
labels    = input.bool(true, title="RSI Labels", inline="RSI", group=grpRsi)
ema_col   = input.color(color.rgb(0, 255, 170), title="EMA", inline="c", group=grpRsi)

// تقريب EMA لفترة الـ RSI
exponential_period    = 2 * rsiperiod - 1
smoothing_coefficient = 2 / (exponential_period + 1)

// حساب مستوى السعر المكافئ لقيمة RSI معينة (هنا level=50) وإسقاطه على السعر
emaresult(level) =>
    averageUp   = 0.0
    averageDown = 0.0
    averageUp   := close > close[1] ? smoothing_coefficient * (close - close[1]) + (1 - smoothing_coefficient) * nz(averageUp[1], 1) : (1 - smoothing_coefficient) * nz(averageUp[1], 1)
    averageDown := close > close[1] ? (1 - smoothing_coefficient) * nz(averageDown[1], 1) : smoothing_coefficient * (close[1] - close) + (1 - smoothing_coefficient) * nz(averageDown[1], 1)
    netValue    = (rsiperiod - 1) * (averageDown * level / (100 - level) - averageUp)
    result      = netValue >= 0 ? close + netValue : close + netValue * (100 - level) / level
    result

ema_result = emaresult(50)

// لون الخط: أخضر إذا كان السعر فوق خط RSI-50، أحمر إذا كان تحته
ema_color = close > ema_result ? color.rgb(130, 229, 133) : color.red

plot(ema_result, color=ema_color, title="RSI 50 on Chart (Optimal EMA)")

// اختراق السعر لخط RSI-50 صعوداً/هبوطاً
rsiCrossUp   = ta.crossover(close, ema_result)
rsiCrossDown = ta.crossunder(close, ema_result)

// إشارات بصرية اختيارية على الشارت عند اختراق خط RSI-50
plotshape(rsiCrossUp, title="RSI 50 Cross Up", style=shape.triangleup, location=location.belowbar,
     color=color.aqua, size=size.tiny)
plotshape(rsiCrossDown, title="RSI 50 Cross Down", style=shape.triangledown, location=location.abovebar,
     color=color.orange, size=size.tiny)

// ====== تنبيه (Alert): اختراق السعر لخط RSI-50 على الشارت ======
alertcondition(rsiCrossUp, title="RSI 50 Cross Up",
     message="{{ticker}} ({{interval}}): السعر اخترق خط RSI 50 صعوداً")
alertcondition(rsiCrossDown, title="RSI 50 Cross Down",
     message="{{ticker}} ({{interval}}): السعر كسر خط RSI 50 هبوطاً")

// تسمية توضيحية بجانب الخط
labelfunc(bool_, n, line_, text_, label_col, text_col, size_) =>
    label l = bool_ ? label.new(bar_index + n, line_, text=text_, color=label_col,
      style=label.style_label_left, textcolor=text_col, size=size_,
      textalign=text.align_left) : na
    label.delete(l[1])

labelfunc(labels, 5, ema_result, "RSI 50", color.blue, color.white, size.small)

// ==========================================================================
// ==========================  3) Liquidity Levels  =========================
// ==========================================================================
grpLiq = "Liquidity Levels"

lookback   = input.int(15, "عدد الشموع للمقارنة (Lookback)", minval=1, group=grpLiq, tooltip="الشمعة تعتبر (سيولة عالية) إذا كان فيها أعلى فوليوم خلال آخر عدد شموع محدد هنا")
extendBars = input.int(5, "امتداد الخط (Extend Bars)", minval=1, group=grpLiq)
lineWidth  = input.int(2, "سماكة الخط", minval=1, maxval=5, group=grpLiq)

useRange     = input.bool(true, "تحديد عدد شموع معيّن فقط (بدل الشارة كاملة)", group=grpLiq)
barsToCheck  = input.int(200, "عدد آخر الشموع للفحص", minval=1, group=grpLiq, tooltip="يفحص فقط آخر عدد شموع من هذا الرقم بدءًا من آخر شمعة بالشارة")

inRange = not useRange or (bar_index >= last_bar_index - barsToCheck)

liquidity            = volume
high_liquidity_candle = liquidity == ta.highest(liquidity, lookback) and inRange

midpoint = (high + low) / 2

var float stored_midpoint = na
if high_liquidity_candle
    stored_midpoint := midpoint

// تلوين الشمعة صفراء عند السيولة العالية
barcolor(high_liquidity_candle ? color.yellow : na, title="Liquidity Candle Color")

// رسم الخط وتلوينه حسب موقع السعر منه
if not na(stored_midpoint)
    line_color = close > stored_midpoint ? color.green : color.red
    line.new(x1=bar_index, y1=stored_midpoint, x2=bar_index + extendBars, y2=stored_midpoint, width=lineWidth, color=line_color)

// ====== [إضافة] تنبيه: فتح أي شمعة فوق/تحت خط منتصف السيولة المرسوم ======
liqOpenAbove = not na(stored_midpoint) and ta.crossover(open, stored_midpoint)
liqOpenBelow = not na(stored_midpoint) and ta.crossunder(open, stored_midpoint)

// علامات بصرية لتأكيد مكان التنبيه
plotshape(liqOpenAbove, title="Open Above Liquidity Mid", style=shape.triangleup,
     location=location.belowbar, color=color.green, size=size.tiny)
plotshape(liqOpenBelow, title="Open Below Liquidity Mid", style=shape.triangledown,
     location=location.abovebar, color=color.red, size=size.tiny)

alertcondition(liqOpenAbove, title="Liquidity Mid - Candle Open Above",
     message="{{ticker}} ({{interval}}): شمعة فتحت فوق خط منتصف السيولة")
alertcondition(liqOpenBelow, title="Liquidity Mid - Candle Open Below",
     message="{{ticker}} ({{interval}}): شمعة فتحت تحت خط منتصف السيولة")

// ==========================================================================
// ===== [إضافة] تنبيه مركّب: اختراق EMA + موقع فتح الشمعة من خط السيولة =====
// ==========================================================================
buyCombo  = ta.crossover(price, topBandVis)     and not na(stored_midpoint) and open > stored_midpoint
sellCombo = ta.crossunder(price, bottomBandVis) and not na(stored_midpoint) and open < stored_midpoint

plotshape(buyCombo, title="Combo Buy (EMA + Liq)", style=shape.labelup,
     location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black,
     text="BUY", size=size.small)
plotshape(sellCombo, title="Combo Sell (EMA + Liq)", style=shape.labeldown,
     location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white,
     text="SELL", size=size.small)

alertcondition(buyCombo, title="Combo BUY (EMA Breakout Up + Open Above Liq)",
     message="{{ticker}} ({{interval}}): شراء — اختراق EMA صعوداً مع فتح الشمعة فوق خط السيولة")
alertcondition(sellCombo, title="Combo SELL (EMA Breakout Down + Open Below Liq)",
     message="{{ticker}} ({{interval}}): بيع — كسر EMA هبوطاً مع فتح الشمعة تحت خط السيولة")

// ==========================================================================
// ============================  4) Golden Zone  ============================
// ==========================================================================
grpGZ = "Golden Zone (Fib 0.5-0.618)"

showGoldenZone = input.bool(true, "Show Golden Zone", group=grpGZ)
gzLookback     = input.int(10, "Swing Lookback (bars)", minval=2, group=grpGZ,
     tooltip="عدد الشموع على كل جهة لتأكيد القمة/القاع (Pivot High/Low)")
gzColor        = input.color(color.new(color.yellow, 80), "Golden Zone Fill Color", group=grpGZ)
showGZLines    = input.bool(true, "Show 0.5 / 0.618 Lines", group=grpGZ)
gzLineColor    = input.color(color.new(color.yellow, 20), "Lines Color", group=grpGZ)

// تحديد آخر قمة وقاع مؤكّدين
var float gzSwingHigh = na
var float gzSwingLow  = na
var int   gzHighIdx   = na
var int   gzLowIdx    = na

gzPvtHi = ta.pivothigh(high, gzLookback, gzLookback)
gzPvtLo = ta.pivotlow(low, gzLookback, gzLookback)

if not na(gzPvtHi)
    gzSwingHigh := gzPvtHi
    gzHighIdx   := bar_index - gzLookback
if not na(gzPvtLo)
    gzSwingLow := gzPvtLo
    gzLowIdx   := bar_index - gzLookback

gzFib(v) =>
    float result = na
    if not na(gzSwingHigh) and not na(gzSwingLow)
        result := gzLowIdx < gzHighIdx ? gzSwingHigh - (gzSwingHigh - gzSwingLow) * v : gzSwingLow + (gzSwingHigh - gzSwingLow) * v
    result

gzLevel50  = gzFib(0.5)
gzLevel618 = gzFib(0.618)

var line     gzLine50  = na
var line     gzLine618 = na
var linefill gzFill    = na

if showGoldenZone and not na(gzLevel50) and not na(gzLevel618)
    gzStartIdx = math.min(gzHighIdx, gzLowIdx)
    if na(gzLine50)
        gzLine50  := line.new(gzStartIdx, gzLevel50, bar_index, gzLevel50, color=gzLineColor, width=1)
        gzLine618 := line.new(gzStartIdx, gzLevel618, bar_index, gzLevel618, color=gzLineColor, width=1)
        gzFill    := linefill.new(gzLine50, gzLine618, gzColor)
    line.set_xy1(gzLine50, gzStartIdx, gzLevel50)
    line.set_xy2(gzLine50, bar_index, gzLevel50)
    line.set_xy1(gzLine618, gzStartIdx, gzLevel618)
    line.set_xy2(gzLine618, bar_index, gzLevel618)
    line.set_color(gzLine50, showGZLines ? gzLineColor : color.new(color.white, 100))
    line.set_color(gzLine618, showGZLines ? gzLineColor : color.new(color.white, 100))

// ==========================================================================
// ==========================  5) Price MA on Chart  ========================
// ==========================================================================
// متوسط متحرك على المصدر المختار يمشي فوق الشموع، يتلوّن أخضر إذا السعر
// فوقه وأحمر إذا تحته. القيم الافتراضية: High / 88 / SMA / Offset 20.
grpPMA = "Price MA on Chart"

pma_src    = input.source(high, "Source", group=grpPMA)
pma_len    = input.int(88, "MA Length", minval=1, group=grpPMA)
pma_type   = input.string("SMA", "MA Type", options=["SMA","EMA","WMA","RMA"], group=grpPMA)
pma_offset = input.int(20, "Offset", group=grpPMA)
pma_up     = input.color(color.rgb(38, 166, 154), "Above / Bullish", group=grpPMA)
pma_down   = input.color(color.rgb(239, 83, 80), "Below / Bearish", group=grpPMA)

pma_line = switch pma_type
    "SMA" => ta.sma(pma_src, pma_len)
    "EMA" => ta.ema(pma_src, pma_len)
    "WMA" => ta.wma(pma_src, pma_len)
    "RMA" => ta.rma(pma_src, pma_len)

pma_color = close >= pma_line ? pma_up : pma_down

plot(pma_line, "Price MA", color=pma_color, linewidth=2, offset=pma_offset)
````
