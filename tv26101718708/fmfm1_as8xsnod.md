# fmfm1

- url: https://www.tradingview.com/script/aS8xsnoD/
- type: indicator
- pine_id: PUB;b89324d9beee40f48c9a03e68289e07e
- version: 1.0

## Description

FMFM1 هو مذبذب متعدد المكونات يدمج ضفيرة MA (EMA 3/7/14) مع مرشح ضوضاء يعتمد على ATR، وMACD (26/12/9)، وميل اتجاه TMA، وRSI(14)، وضغط المشتري/البائع المرجح بالحجم في لوحة موحدة واحدة. الأعمدة الخضراء فوق الصفر تشير إلى انحياز الشراء (المشتري)؛ الأعمدة الحمراء تحت الصفر تشير إلى انحياز بيع (بيع)؛ تشير الأعمدة الرمادية إلى حركة سعرية متقطعة وغير اتجاهية. مثلثات الانعكاس (▲▼) تطلق عندما يتغير اتجاه ميل TMA. جدول لوحة تحكم حي في الزاوية اليمنى السفلية يعرض دائما نوع الإشارة الحالي، وانتشار الضفائر، وقيمة الفلتر.

Let me know if you want to add it in Arabic too, or if you want a specific section expanded.

## Source Code

````pine
//@version=6
indicator("fmfm1", overlay=false, scale=scale.right)

posFromString(pos) =>
    switch pos
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        => position.bottom_right

// ────── القيم الثابتة ──────
maType            = "EMA"
Period1           = 3
Period2           = 7
Period3           = 14
PipsMinSepPercent = input.int(80, title="فلتر الفصل %", minval=1, maxval=200)
tmaLen            = 10
fastLen           = 12
slowLen           = 26
sigLen            = 9
rsiLength         = 14
pressurePos       = "bottom_right"

// ────── RSI ──────
rsiValue = ta.rsi(close, rsiLength)

// ────── قوة المشترين والبائعين ──────
candleRange = high - low
avgRange    = ta.sma(candleRange, 20)
weight      = candleRange / math.max(avgRange, 0.000001)

buyingBase  = close >= open ? volume : volume * (close - low)  / math.max(candleRange, 0.000001)
sellingBase = close <  open ? volume : volume * (high - close) / math.max(candleRange, 0.000001)

buyingBase  := candleRange == 0 ? volume / 2 : buyingBase
sellingBase := candleRange == 0 ? volume / 2 : sellingBase

bullPowerRaw = buyingBase  * weight
bearPowerRaw = sellingBase * weight
bullPower    = ta.sma(bullPowerRaw, 7)
bearPower    = ta.sma(bearPowerRaw, 7)

totalPower       = bullPower + bearPower
bullPowerPercent = totalPower > 0 ? bullPower / totalPower * 100 : 50
bearPowerPercent = totalPower > 0 ? bearPower / totalPower * 100 : 50

// ────── MA Braid & Filter ──────
ma(type, src_ma, len) =>
    if type == "SMA"
        ta.sma(src_ma, len)
    else
        ta.ema(src_ma, len)

ma1 = ma(maType, close, Period1)
ma2 = ma(maType, open,  Period2)
ma3 = ma(maType, close, Period3)

dif    = math.max(math.max(ma1,ma2),ma3) - math.min(math.min(ma1,ma2),ma3)
filter = ta.atr(14) * PipsMinSepPercent / 100

difAboveFilter = dif > filter
isCall = ma1 > ma2 and difAboveFilter
isPut  = ma2 > ma1 and difAboveFilter
isGray = not isCall and not isPut

// ────── TMA للمثلثات ──────
tma  = ta.sma(hl2, tmaLen)
bull = tma > tma[1]

// ────── MACD ──────
fastMA     = ta.ema(close, fastLen)
slowMA     = ta.ema(close, slowLen)
macdLine   = fastMA - slowMA
signalLine = ta.ema(macdLine, sigLen)
macdAbove  = macdLine >= signalLine

// ────── Round Helper ──────
f_round(val) =>
    factor = syminfo.mintick <= 0.0001 ? 10000 :
             syminfo.mintick <= 0.001  ? 1000  :
             syminfo.mintick <= 0.01   ? 100   :
             syminfo.mintick <= 0.1    ? 10    : 1
    math.round(val * factor) / factor

dif_rounded    = f_round(dif)
filter_rounded = f_round(filter)

// ────── Dashboard ──────
if barstate.islast
    var table t = table.new(posFromString(pressurePos), 2, 3,
         bgcolor=color.new(#1e1e1e,80), border_width=1, border_color=color.yellow)
    table.cell(t, 1, 0,
         isCall ? "كول" : isPut ? "بوت" : "تذبذب",
         bgcolor    = isCall ? color.new(#44b148, 24) :
                      isPut  ? color.new(#f33333, 50) :
                               color.new(#787b86, 57),
         text_color = color.white, text_size = size.tiny)
    table.cell(t, 1, 1, str.tostring(dif_rounded, "#.###"),
         bgcolor    = isCall ? color.new(color.green,60) :
                      isPut  ? color.new(color.red,60)   :
                               color.new(color.gray,60),
         text_color = color.white)
    table.cell(t, 1, 2, str.tostring(filter_rounded, "#.###"),
         bgcolor=color.new(color.blue,60), text_color=color.white)

// ────── مثلثات التحول ──────
var label bullLabel = na
var label bearLabel = na

if bull and not bull[1]
    if not na(bearLabel)
        label.delete(bearLabel)
    bullLabel := label.new(bar_index, -filter * 1.3, "▲",
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_up,
         color=color.new(color.green,100),
         textcolor=color.green, size=size.large)

if not bull and bull[1]
    if not na(bullLabel)
        label.delete(bullLabel)
    bearLabel := label.new(bar_index, filter * 1.3, "▼",
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_down,
         color=color.new(color.red,100),
         textcolor=color.red, size=size.large)

// ────── Plots: الأعمدة ──────
plot(isCall ? dif  : na,
     title="موجة خضراء", color=color.new(#00e676,0),
     style=plot.style_columns, linewidth=4)

plot(isPut  ? -dif : na,
     title="موجة حمراء", color=color.new(#ff1744,0),
     style=plot.style_columns, linewidth=4)

plot(isGray and bull     ? dif  : na,
     title="رمادي صاعد", color=color.new(#9e9e9e,14),
     style=plot.style_columns, linewidth=4)

plot(isGray and not bull ? -dif : na,
     title="رمادي هابط", color=color.new(#9e9e9e,18),
     style=plot.style_columns, linewidth=4)

// ────── خطوط الفلتر — نفس الصورة ──────
plot(filter,
     title="الفلتر العلوي",
     color=color.new(#ff1744, 0),
     linewidth=2,
     style=plot.style_line)

plot(-filter,
     title="الفلتر السفلي",
     color=color.new(#00e676, 0),
     linewidth=2,
     style=plot.style_line)

hline(0, "Zero", color=color.new(color.gray,50), linestyle=hline.style_dotted, linewidth=1)

// ────── MACD + Signal ──────
plot(macdLine,
     title="MACD",
     color=macdAbove ? color.new(#00e676,25) : color.new(#ff1744,25),
     style=plot.style_line, linewidth=2)

plot(signalLine,
     title="Signal",
     color=color.new(#ffeb3b, 25),
     style=plot.style_line, linewidth=2)
````
